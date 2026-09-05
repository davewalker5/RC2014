using MIDIConverter.Entities.Conversion;
using MIDIConverter.Entities.Exceptions;
using MIDIConverter.Entities.Interfaces;
using MIDIConverter.Entities.MIDI;
using MIDIConverter.Logic.SID;

namespace MIDIConverter.Logic.Conversion
{
    /// <summary>
    /// Quantises MIDI notes and arranges them for three SID voices.
    /// </summary>
    public sealed class MIDIArranger
    {
        private readonly SIDPitchConverter _pitchConverter;

        public MIDIArranger(SIDPitchConverter pitchConverter)
        {
            _pitchConverter = pitchConverter;
        }

        /// <summary>
        /// Produces compressed SID playback steps and conversion diagnostics.
        /// </summary>
        public ArrangementResult Arrange(MIDIFileData midi, IMIDIConverterAppSettings settings)
        {
            ArgumentNullException.ThrowIfNull(midi);
            ArgumentNullException.ThrowIfNull(settings);
            if (midi.Notes.Count == 0)
            {
                throw new MIDIConversionException("The MIDI file contains no pitched notes to convert.");
            }

            // Quantised note boundaries are the only points at which the audible
            // SID state can change. Including zero preserves leading silence.
            var notes = midi.Notes.Select(x => Quantise(x, midi, settings)).ToList();
            var boundaries = notes
                .SelectMany(x => new[] { x.StartTick, x.EndTick })
                .Append(0)
                .Distinct()
                .Order()
                .ToList();
            var assignments = new int?[3];
            var discarded = new HashSet<int>();
            var clamped = new HashSet<int>();
            var steps = new List<PlaybackStep>();

            for (var boundaryIndex = 0; boundaryIndex < boundaries.Count - 1; boundaryIndex++)
            {
                // Determine the complete source polyphony throughout this interval.
                var tick = boundaries[boundaryIndex];
                var nextTick = boundaries[boundaryIndex + 1];
                var active = notes.Where(x => x.StartTick <= tick && x.EndTick > tick).ToList();
                var activeIds = active.Select(x => x.Source.Id).ToHashSet();

                // Release assignments only when their source note has ended. This
                // keeps sustained notes on stable SID voices across boundaries.
                for (var voice = 0; voice < assignments.Length; voice++)
                {
                    if (assignments[voice] is int id && !activeIds.Contains(id))
                    {
                        assignments[voice] = null;
                    }
                }

                // Reduce excess polyphony once per interval and count discarded
                // source notes only once even if they span several intervals.
                var selected = SelectNotes(active, assignments);
                foreach (var note in active.Where(x => selected.All(y => y.Source.Id != x.Source.Id)))
                {
                    discarded.Add(note.Source.Id);
                }

                // A selected-set change can displace a note before its source end;
                // make that SID voice available before assigning new candidates.
                var selectedIds = selected.Select(x => x.Source.Id).ToHashSet();
                for (var voice = 0; voice < assignments.Length; voice++)
                {
                    if (assignments[voice] is int id && !selectedIds.Contains(id))
                    {
                        assignments[voice] = null;
                    }
                }

                // Remember the previous identities so a newly assigned note can
                // request a gate cycle, including repeated notes of the same pitch.
                var previousAssignments = assignments.ToArray();
                foreach (var note in selected
                    .Where(x => !assignments.Contains(x.Source.Id))
                    .OrderBy(x => x.Source.StartTick)
                    .ThenBy(x => x.Source.Channel)
                    .ThenBy(x => x.Source.NoteNumber)
                    .ThenBy(x => x.Source.Id))
                {
                    var freeVoice = Array.FindIndex(assignments, x => x is null);
                    if (freeVoice >= 0)
                    {
                        assignments[freeVoice] = note.Source.Id;
                    }
                }

                var frequencies = new int[3];
                var activeMask = 0;
                var retriggerMask = 0;

                // Convert the selected notes to SID words and encode voice state in
                // compact masks that are inexpensive for BASIC to interpret.
                for (var voice = 0; voice < assignments.Length; voice++)
                {
                    if (assignments[voice] is not int id)
                    {
                        continue;
                    }

                    var note = selected.Single(x => x.Source.Id == id);
                    frequencies[voice] = _pitchConverter.Convert(
                        note.Source.NoteNumber,
                        settings.SIDClockHertz,
                        out var wasClamped);
                    if (wasClamped)
                    {
                        clamped.Add(note.Source.NoteNumber);
                    }

                    activeMask |= 1 << voice;
                    if (previousAssignments[voice] != assignments[voice])
                    {
                        retriggerMask |= 1 << voice;
                    }
                }

                // Convert each pair of musical boundaries independently through
                // the tempo map, avoiding accumulated duration-rounding error.
                var startMilliseconds = TickToMilliseconds(tick, midi, settings);
                var endMilliseconds = TickToMilliseconds(nextTick, midi, settings);
                var duration = Math.Max(
                    1,
                    (int)Math.Round(endMilliseconds - startMilliseconds, MidpointRounding.AwayFromZero));
                AddOrMerge(steps, new PlaybackStep
                {
                    DurationMilliseconds = duration,
                    Frequency1 = frequencies[0],
                    Frequency2 = frequencies[1],
                    Frequency3 = frequencies[2],
                    ActiveMask = activeMask,
                    RetriggerMask = retriggerMask
                });
            }

            // Collate parser warnings with one warning for each distinct pitch that
            // exceeded the SID's representable frequency range.
            var warnings = new List<string>(midi.Warnings);
            foreach (var noteNumber in clamped.Order())
            {
                warnings.Add($"MIDI note {noteNumber} was clamped to the SID frequency-word range.");
            }

            return new ArrangementResult(steps, discarded.Count, warnings);
        }

        private static QuantisedNote Quantise(
            MIDINote note,
            MIDIFileData midi,
            IMIDIConverterAppSettings settings)
        {
            // Quantise starts and ends independently to the configured musical grid.
            var start = QuantiseTick(note.StartTick, midi.TicksPerQuarterNote, settings.StepsPerQuarterNote);
            var end = QuantiseTick(note.EndTick, midi.TicksPerQuarterNote, settings.StepsPerQuarterNote);
            if (end <= start)
            {
                // Preserve very short notes by extending them to one complete step.
                end = NextGridTick(start, midi.TicksPerQuarterNote, settings.StepsPerQuarterNote);
            }

            return new QuantisedNote(note, start, end);
        }

        private static long QuantiseTick(long tick, int ticksPerQuarter, int stepsPerQuarter)
        {
            // Decimal arithmetic and an explicit midpoint rule make grid placement
            // reproducible without cumulative binary floating-point drift.
            var stepIndex = decimal.Round(
                (decimal)tick * stepsPerQuarter / ticksPerQuarter,
                0,
                MidpointRounding.AwayFromZero);
            return (long)decimal.Round(
                stepIndex * ticksPerQuarter / stepsPerQuarter,
                0,
                MidpointRounding.AwayFromZero);
        }

        private static long NextGridTick(long tick, int ticksPerQuarter, int stepsPerQuarter)
        {
            // Work in grid indices so non-divisible PPQN resolutions still advance
            // to the next representable quantised position.
            var index = decimal.Floor((decimal)tick * stepsPerQuarter / ticksPerQuarter) + 1;
            return (long)decimal.Round(
                index * ticksPerQuarter / stepsPerQuarter,
                0,
                MidpointRounding.AwayFromZero);
        }

        private static List<QuantisedNote> SelectNotes(
            IReadOnlyList<QuantisedNote> active,
            IReadOnlyList<int?> assignments)
        {
            if (active.Count <= 3)
            {
                return active.OrderBy(x => x.Source.Id).ToList();
            }

            // Retain already sounding notes first to avoid audible voice hopping.
            var selected = active
                .Where(x => assignments.Contains(x.Source.Id))
                .OrderBy(x => Array.IndexOf(assignments.ToArray(), x.Source.Id))
                .Take(3)
                .ToList();

            // Fill remaining voices with melody, bass, then the strongest inner
            // note. Each ordering contains deterministic tie breakers.
            AddCandidate(selected, active
                .OrderByDescending(x => x.Source.NoteNumber)
                .ThenBy(x => x.Source.StartTick)
                .ThenBy(x => x.Source.Channel)
                .ThenBy(x => x.Source.Id));
            AddCandidate(selected, active
                .OrderBy(x => x.Source.NoteNumber)
                .ThenBy(x => x.Source.StartTick)
                .ThenBy(x => x.Source.Channel)
                .ThenBy(x => x.Source.Id));
            AddCandidate(selected, active
                .OrderByDescending(x => x.Source.Velocity)
                .ThenBy(x => x.Source.StartTick)
                .ThenBy(x => x.Source.Channel)
                .ThenBy(x => x.Source.NoteNumber));
            return selected.Take(3).ToList();
        }

        private static void AddCandidate(
            ICollection<QuantisedNote> selected,
            IEnumerable<QuantisedNote> candidates)
        {
            if (selected.Count >= 3)
            {
                return;
            }

            // A candidate may occur in several priority sequences, so exclude any
            // source note already selected for another SID voice.
            var candidate = candidates.FirstOrDefault(x => selected.All(y => y.Source.Id != x.Source.Id));
            if (candidate is not null)
            {
                selected.Add(candidate);
            }
        }

        private static double TickToMilliseconds(
            long tick,
            MIDIFileData midi,
            IMIDIConverterAppSettings settings)
        {
            if (settings.TempoBeatsPerMinute is double overrideTempo)
            {
                // An override deliberately replaces every source tempo segment.
                return tick * (60000d / overrideTempo) / midi.TicksPerQuarterNote;
            }

            // Integrate each complete tempo segment up to the requested tick. MIDI
            // defaults to 500,000 microseconds per quarter note (120 BPM).
            var elapsedMicroseconds = 0d;
            var previousTick = 0L;
            var currentTempo = 500000;
            foreach (var change in midi.TempoChanges.Where(x => x.Tick <= tick))
            {
                elapsedMicroseconds +=
                    (change.Tick - previousTick) * (double)currentTempo / midi.TicksPerQuarterNote;
                previousTick = change.Tick;
                currentTempo = change.MicrosecondsPerQuarterNote;
            }

            elapsedMicroseconds += (tick - previousTick) * (double)currentTempo / midi.TicksPerQuarterNote;
            return elapsedMicroseconds / 1000d;
        }

        private static void AddOrMerge(ICollection<PlaybackStep> steps, PlaybackStep step)
        {
            // Run-length encode unchanged states. A retrigger must remain a separate
            // row because it represents an audible new attack at the same pitch.
            var previous = steps.LastOrDefault();
            if (previous is not null &&
                step.RetriggerMask == 0 &&
                previous.Frequency1 == step.Frequency1 &&
                previous.Frequency2 == step.Frequency2 &&
                previous.Frequency3 == step.Frequency3 &&
                previous.ActiveMask == step.ActiveMask)
            {
                previous.DurationMilliseconds = checked(previous.DurationMilliseconds + step.DurationMilliseconds);
                return;
            }

            steps.Add(step);
        }

        private sealed record QuantisedNote(MIDINote Source, long StartTick, long EndTick);
    }

    /// <summary>
    /// Contains the output of three-voice arrangement.
    /// </summary>
    public sealed record ArrangementResult(
        IReadOnlyList<PlaybackStep> Steps,
        int DiscardedNoteCount,
        IReadOnlyList<string> Warnings);
}
