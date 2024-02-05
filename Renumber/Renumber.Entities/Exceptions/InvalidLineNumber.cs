using System.Diagnostics.CodeAnalysis;

namespace Renumber.Entities.Exceptions
{
    [ExcludeFromCodeCoverage]
    public class InvalidLineNumberException : Exception
    {
        public InvalidLineNumberException()
        {
        }

        public InvalidLineNumberException(string message) : base(message)
        {
        }

        public InvalidLineNumberException(string message, Exception inner) : base(message, inner)
        {
        }
    }
}
