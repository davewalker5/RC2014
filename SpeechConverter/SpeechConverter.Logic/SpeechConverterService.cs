using SpeechConverter.Logic.Basic;
using SpeechConverter.Logic.Pronunciation;

namespace SpeechConverter.Logic
{
    /// <summary>
    /// Coordinates pronunciation and BASIC listing generation.
    /// </summary>
    public sealed class SpeechConverterService
    {
        private readonly IPronunciationConverter _pronunciationConverter;
        private readonly IBasicProgramGenerator _basicProgramGenerator;

        /// <summary>
        /// Creates the conversion service from its replaceable components.
        /// </summary>
        /// <param name="pronunciationConverter">English pronunciation service.</param>
        /// <param name="basicProgramGenerator">BASIC listing generator.</param>
        public SpeechConverterService(
            IPronunciationConverter pronunciationConverter,
            IBasicProgramGenerator basicProgramGenerator)
        {
            _pronunciationConverter = pronunciationConverter;
            _basicProgramGenerator = basicProgramGenerator;
        }

        /// <summary>
        /// Converts a typed message into a BASIC program.
        /// </summary>
        /// <param name="message">Text to speak.</param>
        /// <returns>The complete BASIC listing.</returns>
        public string Convert(string message)
            => _basicProgramGenerator.Generate(_pronunciationConverter.Convert(message), message);
    }
}
