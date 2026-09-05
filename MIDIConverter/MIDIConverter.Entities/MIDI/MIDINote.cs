namespace MIDIConverter.Entities.MIDI
{
    /// <summary>
    /// Describes one completed MIDI note in absolute MIDI ticks.
    /// </summary>
    public sealed class MIDINote
    {
        public int Id { get; init; }
        public int Track { get; init; }
        public int Channel { get; init; }
        public int NoteNumber { get; init; }
        public int Velocity { get; init; }
        public long StartTick { get; init; }
        public long EndTick { get; init; }
    }
}
