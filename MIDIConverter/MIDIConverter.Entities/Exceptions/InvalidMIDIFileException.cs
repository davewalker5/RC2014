using System.Diagnostics.CodeAnalysis;

namespace MIDIConverter.Entities.Exceptions
{
    /// <summary>
    /// Indicates that MIDI input is malformed or truncated.
    /// </summary>
    [ExcludeFromCodeCoverage]
    public sealed class InvalidMIDIFileException : Exception
    {
        public InvalidMIDIFileException(string message)
            : base(message)
        {
        }
    }
}
