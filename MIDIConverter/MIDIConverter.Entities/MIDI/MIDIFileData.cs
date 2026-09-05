namespace MIDIConverter.Entities.MIDI
{
    /// <summary>
    /// Contains the library-independent musical content read from a MIDI file.
    /// </summary>
    public sealed class MIDIFileData
    {
        /// <summary>
        /// Gets the Standard MIDI File format number.
        /// </summary>
        public int Format { get; init; }

        /// <summary>
        /// Gets the number of MIDI track chunks declared by the file.
        /// </summary>
        public int TrackCount { get; init; }

        /// <summary>
        /// Gets the pulses-per-quarter-note timing resolution.
        /// </summary>
        public int TicksPerQuarterNote { get; init; }

        /// <summary>
        /// Gets the greatest absolute tick position encountered in any track.
        /// </summary>
        public long LastTick { get; init; }

        /// <summary>
        /// Gets the completed, non-percussion notes ordered on the merged timeline.
        /// </summary>
        public IReadOnlyList<MIDINote> Notes { get; init; } = [];

        /// <summary>
        /// Gets the tempo changes ordered by tick and deterministic source order.
        /// </summary>
        public IReadOnlyList<TempoChange> TempoChanges { get; init; } = [];

        /// <summary>
        /// Gets the non-empty track and sequence names found in metadata events.
        /// </summary>
        public IReadOnlyList<string> TrackNames { get; init; } = [];

        /// <summary>
        /// Gets non-fatal problems discovered while reading the MIDI file.
        /// </summary>
        public IReadOnlyList<string> Warnings { get; init; } = [];

        /// <summary>
        /// Gets the number of percussion note-on events omitted from conversion.
        /// </summary>
        public int IgnoredPercussionNotes { get; init; }

        /// <summary>
        /// Gets the number of unsupported controller, pressure, and pitch-bend events ignored.
        /// </summary>
        public int IgnoredControllerEvents { get; init; }
    }
}
