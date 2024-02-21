using System.Diagnostics.CodeAnalysis;

namespace Renumber.Entities.Exceptions
{
    [ExcludeFromCodeCoverage]
    public class DuplicateOptionException : Exception
    {
        public DuplicateOptionException()
        {
        }

        public DuplicateOptionException(string message) : base(message)
        {
        }

        public DuplicateOptionException(string message, Exception inner) : base(message, inner)
        {
        }
    }
}