using System.Diagnostics.CodeAnalysis;

namespace Renumber.Entities.Exceptions
{
    [ExcludeFromCodeCoverage]
    public class InvalidLineFormatException : Exception
    {
        public InvalidLineFormatException()
        {
        }

        public InvalidLineFormatException(string message) : base(message)
        {
        }

        public InvalidLineFormatException(string message, Exception inner) : base(message, inner)
        {
        }
    }
}
