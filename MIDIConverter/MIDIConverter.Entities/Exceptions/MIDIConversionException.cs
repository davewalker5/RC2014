namespace MIDIConverter.Entities.Exceptions
{
    /// <summary>
    /// Identifies MIDI content that cannot produce a usable BASIC program.
    /// </summary>
    public sealed class MIDIConversionException : Exception
    {
        public MIDIConversionException(string message) : base(message)
        {
        }
    }
}
