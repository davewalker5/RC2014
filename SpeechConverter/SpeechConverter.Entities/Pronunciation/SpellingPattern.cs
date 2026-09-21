namespace SpeechConverter.Entities.Pronunciation
{
    /// <summary>
    /// A spelling fragment and its corresponding allophone names.
    /// </summary>
    public sealed class SpellingPattern
    {
        /// <summary>
        /// The English letters to match.
        /// </summary>
        public string Spelling { get; init; } = "";

        /// <summary>
        /// Space-separated SP0256-AL2 allophone names.
        /// </summary>
        public string Sounds { get; init; } = "";
    }
}
