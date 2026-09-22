using SpeechConverter.Entities;

namespace SpeechConverter.Logic.Basic
{
    /// <summary>
    /// Renders MG005 allophones as a Microsoft BASIC program.
    /// </summary>
    public interface IBasicProgramGenerator
    {
        /// <summary>
        /// Builds a program that waits for the MG005 ready bit before each sound.
        /// </summary>
        /// <param name="allophones">Sounds to play.</param>
        /// <param name="phrase">Original phrase to include in REM statements.</param>
        /// <returns>A numbered BASIC listing.</returns>
        string Generate(IReadOnlyList<Allophone> allophones, string phrase);
    }
}
