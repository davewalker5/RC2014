namespace SpeechConverter.Entities.Pronunciation
{
    /// <summary>
    /// Data-driven mappings used by the English pronunciation converter.
    /// </summary>
    public sealed class PronunciationSettings
    {
        /// <summary>
        /// SP0256-AL2 names and their numeric codes.
        /// </summary>
        public Dictionary<string, int> Allophones { get; init; } = [];

        /// <summary>
        /// Known English words and their sound sequences.
        /// </summary>
        public Dictionary<string, string> Words { get; init; } = [];

        /// <summary>
        /// Names for the numbers zero through nineteen; zero is supplied by Words.
        /// </summary>
        public List<string> Units { get; init; } = [];

        /// <summary>
        /// Names for tens multiples from zero to ninety.
        /// </summary>
        public List<string> Tens { get; init; } = [];

        /// <summary>
        /// Ordered multi-letter spelling rules.
        /// </summary>
        public List<SpellingPattern> Patterns { get; init; } = [];

        /// <summary>
        /// Single-letter fallback sounds.
        /// </summary>
        public Dictionary<string, string> Letters { get; init; } = [];
    }
}
