using System.Diagnostics.CodeAnalysis;

namespace MIDIConverter.Entities.Exceptions
{
    /// <summary>
    /// Indicates that a MIDI file uses a well-formed but unsupported feature.
    /// </summary>
    [ExcludeFromCodeCoverage]
    public sealed class UnsupportedMIDIFileException : Exception
    {
        public UnsupportedMIDIFileException(string message)
            : base(message)
        {
        }
    }
}
