using SpeechConverter.Entities;

namespace SpeechConverter.Logic.Pronunciation
{
    /// <summary>
    /// Converts written text to chip allophones.
    /// </summary>
    public interface IPronunciationConverter
    {
        /// <summary>
        /// Converts a message to allophones, including word and sentence pauses.
        /// </summary>
        /// <param name="message">The message to speak.</param>
        /// <returns>The ordered allophones.</returns>
        IReadOnlyList<Allophone> Convert(string message);
    }
}
