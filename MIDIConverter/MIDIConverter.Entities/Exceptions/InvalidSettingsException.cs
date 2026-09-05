using System.Diagnostics.CodeAnalysis;

namespace MIDIConverter.Entities.Exceptions
{
    /// <summary>
    /// Indicates that the effective converter settings are invalid.
    /// </summary>
    [ExcludeFromCodeCoverage]
    public sealed class InvalidSettingsException : Exception
    {
        public InvalidSettingsException(string message)
            : base(message)
        {
        }
    }
}
