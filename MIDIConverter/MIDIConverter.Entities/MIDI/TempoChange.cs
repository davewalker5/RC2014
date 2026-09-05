namespace MIDIConverter.Entities.MIDI
{
    /// <summary>
    /// Describes a MIDI tempo change in microseconds per quarter note.
    /// </summary>
    public sealed class TempoChange
    {
        public long Tick { get; init; }
        public int MicrosecondsPerQuarterNote { get; init; }
        public int Track { get; init; }
        public int Order { get; init; }
    }
}
