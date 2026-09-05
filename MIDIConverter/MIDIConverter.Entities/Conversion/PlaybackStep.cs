namespace MIDIConverter.Entities.Conversion
{
    /// <summary>
    /// Describes one timed state of the three SID voices.
    /// </summary>
    public sealed class PlaybackStep
    {
        public int DurationMilliseconds { get; set; }
        public int Frequency1 { get; init; }
        public int Frequency2 { get; init; }
        public int Frequency3 { get; init; }
        public int ActiveMask { get; init; }
        public int RetriggerMask { get; init; }

        public IReadOnlyList<int> Frequencies
            => [Frequency1, Frequency2, Frequency3];
    }
}
