using System.Diagnostics.CodeAnalysis;

namespace MIDIConverter.Entities.Exceptions
{
    [ExcludeFromCodeCoverage]
    public class TooFewValuesException : Exception
    {
        public TooFewValuesException()
        {
        }

        public TooFewValuesException(string message) : base(message)
        {
        }

        public TooFewValuesException(string message, Exception inner) : base(message, inner)
        {
        }
    }
}