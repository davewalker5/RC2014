namespace MIDIConverter.Entities.Conversion
{
    /// <summary>
    /// Contains generated BASIC source and conversion diagnostics.
    /// </summary>
    public sealed class ConversionResult
    {
        public required string BasicSource { get; init; }
        public required string OutputPath { get; init; }
        public int MIDIFormat { get; init; }
        public int TrackCount { get; init; }
        public int SourceNoteCount { get; init; }
        public int PlaybackStepCount { get; init; }
        public int BasicLineCount { get; init; }
        public int DiscardedPitchedNotes { get; init; }
        public int IgnoredPercussionNotes { get; init; }
        public int IgnoredControllerEvents { get; init; }
        public double DurationSeconds { get; init; }
        public IReadOnlyList<string> Warnings { get; init; } = [];
    }
}
