using System.Diagnostics.CodeAnalysis;

namespace Renumber.Entities.Exceptions
{
    [ExcludeFromCodeCoverage]
    public class MultipleOperationsException : Exception
    {
        public MultipleOperationsException()
        {
        }

        public MultipleOperationsException(string message) : base(message)
        {
        }

        public MultipleOperationsException(string message, Exception inner) : base(message, inner)
        {
        }
    }
}

