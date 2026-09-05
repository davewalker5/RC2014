using System.Buffers.Binary;
using System.Text;
using MIDIConverter.Entities.Exceptions;
using MIDIConverter.Entities.Interfaces;
using MIDIConverter.Entities.MIDI;

namespace MIDIConverter.Logic.MIDI
{
    /// <summary>
    /// Reads format 0 and format 1 Standard MIDI Files with PPQN timing.
    /// </summary>
    public sealed class MIDIFileReader : IMIDIFileReader
    {
        /// <inheritdoc />
        public async Task<MIDIFileData> ReadAsync(
            string path,
            CancellationToken cancellationToken = default)
        {
            ArgumentException.ThrowIfNullOrWhiteSpace(path);

            // Load once so parsing can enforce every chunk boundary against a
            // stable, contiguous view of the source file.
            var bytes = await File.ReadAllBytesAsync(path, cancellationToken).ConfigureAwait(false);
            return Parse(bytes);
        }

        /// <summary>
        /// Parses the supplied Standard MIDI File bytes.
        /// </summary>
        public MIDIFileData Parse(ReadOnlySpan<byte> bytes)
        {
            // Standard MIDI fields are big-endian, so all primitive reads pass
            // through the bounds-checked ByteReader below.
            var reader = new ByteReader(bytes);
            RequireChunk(ref reader, "MThd");
            var headerLength = reader.ReadInt32();
            if (headerLength < 6 || headerLength > reader.Remaining)
            {
                throw new InvalidMIDIFileException("The MIDI header has an invalid length.");
            }

            var format = reader.ReadUInt16();
            var declaredTrackCount = reader.ReadUInt16();
            var division = reader.ReadUInt16();
            reader.Skip(headerLength - 6);

            // Validate features that affect interpretation before reading tracks.
            if (format is not 0 and not 1)
            {
                throw new UnsupportedMIDIFileException($"MIDI format {format} is not supported.");
            }

            if (format == 0 && declaredTrackCount != 1)
            {
                throw new InvalidMIDIFileException("A format 0 MIDI file must declare exactly one track.");
            }

            if ((division & 0x8000) != 0)
            {
                throw new UnsupportedMIDIFileException("SMPTE MIDI time division is not supported.");
            }

            if (division == 0)
            {
                throw new InvalidMIDIFileException("MIDI ticks per quarter note cannot be zero.");
            }

            var notes = new List<MIDINote>();
            var tempos = new List<TempoChange>();
            var names = new List<string>();
            var warnings = new List<string>();
            var ignoredPercussion = 0;
            var ignoredControllers = 0;
            var lastTick = 0L;
            var trackIndex = 0;
            var noteId = 0;

            // Skip unknown top-level chunks safely, but count only MTrk chunks
            // against the track total declared by the header.
            while (reader.Remaining > 0 && trackIndex < declaredTrackCount)
            {
                var chunkName = reader.ReadText(4);
                var chunkLength = reader.ReadInt32();
                if (chunkLength < 0 || chunkLength > reader.Remaining)
                {
                    throw new InvalidMIDIFileException($"Chunk '{chunkName}' has an invalid length.");
                }

                var chunk = reader.ReadSpan(chunkLength);
                if (!string.Equals(chunkName, "MTrk", StringComparison.Ordinal))
                {
                    continue;
                }

                var result = ParseTrack(chunk, trackIndex, noteId);
                notes.AddRange(result.Notes);
                tempos.AddRange(result.Tempos);
                names.AddRange(result.Names);
                warnings.AddRange(result.Warnings);
                ignoredPercussion += result.IgnoredPercussion;
                ignoredControllers += result.IgnoredControllers;
                lastTick = Math.Max(lastTick, result.LastTick);
                noteId += result.Notes.Count;
                trackIndex++;
            }

            // A short file must not be accepted simply because all available bytes
            // were individually well formed.
            if (trackIndex != declaredTrackCount)
            {
                throw new InvalidMIDIFileException(
                    $"The MIDI file declares {declaredTrackCount} tracks but contains {trackIndex}.");
            }

            // Same-tick tempo events retain deterministic track and source order;
            // later entries at that tick consequently become the effective tempo.
            var orderedTempos = tempos
                .OrderBy(x => x.Tick)
                .ThenBy(x => x.Track)
                .ThenBy(x => x.Order)
                .ToList();

            return new MIDIFileData
            {
                Format = format,
                TrackCount = declaredTrackCount,
                TicksPerQuarterNote = division,
                LastTick = lastTick,
                Notes = notes.OrderBy(x => x.StartTick).ThenBy(x => x.Id).ToList(),
                TempoChanges = orderedTempos,
                TrackNames = names,
                Warnings = warnings,
                IgnoredPercussionNotes = ignoredPercussion,
                IgnoredControllerEvents = ignoredControllers
            };
        }

        private static TrackResult ParseTrack(ReadOnlySpan<byte> bytes, int track, int firstNoteId)
        {
            var reader = new ByteReader(bytes);
            var notes = new List<MIDINote>();
            var tempos = new List<TempoChange>();
            var names = new List<string>();
            var warnings = new List<string>();
            var active = new Dictionary<(int Channel, int Note), Queue<ActiveNote>>();
            var absoluteTick = 0L;
            var runningStatus = -1;
            var order = 0;
            var ignoredPercussion = 0;
            var ignoredControllers = 0;
            var reachedEnd = false;

            // Track event times are delta encoded, so accumulate an absolute tick
            // before interpreting each event body.
            while (reader.Remaining > 0 && !reachedEnd)
            {
                absoluteTick = checked(absoluteTick + reader.ReadVariableLength());
                var first = reader.PeekByte();
                int status;

                // A data byte at the event boundary reuses the most recent channel
                // status. Meta and system events cancel that running status.
                if ((first & 0x80) != 0)
                {
                    status = reader.ReadByte();
                    if (status < 0xF0)
                    {
                        runningStatus = status;
                    }
                    else
                    {
                        runningStatus = -1;
                    }
                }
                else
                {
                    if (runningStatus < 0)
                    {
                        throw new InvalidMIDIFileException(
                            $"Track {track + 1} uses running status before a channel status byte.");
                    }

                    status = runningStatus;
                }

                // Meta events have a type and variable-length payload. Only timing,
                // names, and end-of-track affect this converter.
                if (status == 0xFF)
                {
                    var type = reader.ReadByte();
                    var length = reader.ReadVariableLengthAsInt();
                    var data = reader.ReadSpan(length);
                    if (type == 0x2F)
                    {
                        reachedEnd = true;
                    }
                    else if (type == 0x51)
                    {
                        if (length != 3)
                        {
                            throw new InvalidMIDIFileException("A tempo event must contain three bytes.");
                        }

                        var tempo = (data[0] << 16) | (data[1] << 8) | data[2];
                        if (tempo == 0)
                        {
                            throw new InvalidMIDIFileException("A MIDI tempo value cannot be zero.");
                        }

                        tempos.Add(new TempoChange
                        {
                            Tick = absoluteTick,
                            MicrosecondsPerQuarterNote = tempo,
                            Track = track,
                            Order = order
                        });
                    }
                    else if (type is 0x03 or 0x00)
                    {
                        var name = Encoding.UTF8.GetString(data).Trim();
                        if (!string.IsNullOrWhiteSpace(name))
                        {
                            names.Add(name);
                        }
                    }

                    order++;
                    continue;
                }

                // System-exclusive payloads are length-prefixed in MIDI files and
                // can be skipped without interpreting manufacturer-specific data.
                if (status is 0xF0 or 0xF7)
                {
                    var length = reader.ReadVariableLengthAsInt();
                    reader.Skip(length);
                    order++;
                    continue;
                }

                if (status >= 0xF0)
                {
                    throw new UnsupportedMIDIFileException(
                        $"System status 0x{status:X2} is not supported in a MIDI track.");
                }

                var command = status & 0xF0;
                var channel = status & 0x0F;
                var data1 = reader.ReadByte();
                var data2 = command is 0xC0 or 0xD0 ? 0 : reader.ReadByte();

                // Channel 10 is conventionally percussion and is counted rather
                // than paired because the initial SID arranger handles pitches only.
                if (command == 0x90 && data2 > 0)
                {
                    if (channel == 9)
                    {
                        ignoredPercussion++;
                    }
                    else
                    {
                        var key = (channel, data1);
                        if (!active.TryGetValue(key, out var queue))
                        {
                            queue = new Queue<ActiveNote>();
                            active.Add(key, queue);
                        }

                        // A queue preserves overlapping repetitions of the same
                        // pitch and channel until corresponding note-offs arrive.
                        queue.Enqueue(new ActiveNote(absoluteTick, data2));
                    }
                }
                else if (command == 0x80 || command == 0x90)
                {
                    if (channel != 9 &&
                        active.TryGetValue((channel, data1), out var queue) &&
                        queue.Count > 0)
                    {
                        var started = queue.Dequeue();
                        notes.Add(CreateNote(
                            firstNoteId + notes.Count,
                            track,
                            channel,
                            data1,
                            started,
                            absoluteTick));
                    }
                    else if (channel != 9)
                    {
                        warnings.Add(
                            $"Track {track + 1}: unmatched note-off for channel {channel + 1}, note {data1} at tick {absoluteTick}.");
                    }
                }
                else if (command is 0xA0 or 0xB0 or 0xD0 or 0xE0)
                {
                    ignoredControllers++;
                }

                order++;
            }

            // Close hanging notes at the track boundary so recoverable source data
            // remains convertible, while retaining a diagnostic for each repair.
            foreach (var pair in active.OrderBy(x => x.Key.Channel).ThenBy(x => x.Key.Note))
            {
                while (pair.Value.Count > 0)
                {
                    var started = pair.Value.Dequeue();
                    var endTick = Math.Max(absoluteTick, started.Tick + 1);
                    notes.Add(CreateNote(
                        firstNoteId + notes.Count,
                        track,
                        pair.Key.Channel,
                        pair.Key.Note,
                        started,
                        endTick));
                    warnings.Add(
                        $"Track {track + 1}: note {pair.Key.Note} on channel {pair.Key.Channel + 1} was closed at end of track.");
                }
            }

            return new TrackResult(
                notes,
                tempos,
                names,
                warnings,
                absoluteTick,
                ignoredPercussion,
                ignoredControllers);
        }

        private static MIDINote CreateNote(
            int id,
            int track,
            int channel,
            int note,
            ActiveNote started,
            long endTick)
        {
            // Enforce a positive duration even for malformed same-tick note pairs.
            return new MIDINote
            {
                Id = id,
                Track = track,
                Channel = channel,
                NoteNumber = note,
                Velocity = started.Velocity,
                StartTick = started.Tick,
                EndTick = Math.Max(endTick, started.Tick + 1)
            };
        }

        private static void RequireChunk(ref ByteReader reader, string expected)
        {
            // Chunk identifiers are fixed four-byte ASCII strings.
            var actual = reader.ReadText(4);
            if (!string.Equals(actual, expected, StringComparison.Ordinal))
            {
                throw new InvalidMIDIFileException($"Expected MIDI chunk '{expected}', found '{actual}'.");
            }
        }

        private sealed record ActiveNote(long Tick, int Velocity);

        private sealed record TrackResult(
            IReadOnlyList<MIDINote> Notes,
            IReadOnlyList<TempoChange> Tempos,
            IReadOnlyList<string> Names,
            IReadOnlyList<string> Warnings,
            long LastTick,
            int IgnoredPercussion,
            int IgnoredControllers);

        private ref struct ByteReader
        {
            private readonly ReadOnlySpan<byte> _bytes;
            private int _position;

            public ByteReader(ReadOnlySpan<byte> bytes)
            {
                _bytes = bytes;
            }

            public int Remaining => _bytes.Length - _position;

            public byte PeekByte()
            {
                // Peeking supports running-status detection without consuming the
                // first data byte of the event.
                Require(1);
                return _bytes[_position];
            }

            public byte ReadByte()
            {
                Require(1);
                return _bytes[_position++];
            }

            public ushort ReadUInt16()
            {
                // MIDI stores multi-byte integers most-significant byte first.
                Require(2);
                var value = BinaryPrimitives.ReadUInt16BigEndian(_bytes[_position..]);
                _position += 2;
                return value;
            }

            public int ReadInt32()
            {
                // Signed storage lets negative or oversized chunk lengths fail the
                // caller's range validation before slicing the input.
                Require(4);
                var value = BinaryPrimitives.ReadInt32BigEndian(_bytes[_position..]);
                _position += 4;
                return value;
            }

            public string ReadText(int length)
                => Encoding.ASCII.GetString(ReadSpan(length));

            public ReadOnlySpan<byte> ReadSpan(int length)
            {
                // Return a view rather than copying event payload bytes.
                Require(length);
                var value = _bytes.Slice(_position, length);
                _position += length;
                return value;
            }

            public void Skip(int length)
            {
                Require(length);
                _position += length;
            }

            public long ReadVariableLength()
            {
                // MIDI variable-length quantities contain seven payload bits per
                // byte and are limited by the file format to four bytes.
                long value = 0;
                for (var index = 0; index < 4; index++)
                {
                    var next = ReadByte();
                    value = (value << 7) | (uint)(next & 0x7F);
                    if ((next & 0x80) == 0)
                    {
                        return value;
                    }
                }

                throw new InvalidMIDIFileException("A MIDI variable-length quantity exceeds four bytes.");
            }

            public int ReadVariableLengthAsInt()
            {
                // Payload lengths index an in-memory span and must fit Int32.
                var value = ReadVariableLength();
                if (value > int.MaxValue)
                {
                    throw new InvalidMIDIFileException("A MIDI event length is too large.");
                }

                return (int)value;
            }

            private void Require(int length)
            {
                // Centralised bounds checking turns every truncated primitive,
                // payload, or skipped chunk into the same domain-specific error.
                if (length < 0 || length > Remaining)
                {
                    throw new InvalidMIDIFileException("The MIDI file is truncated.");
                }
            }
        }
    }
}
