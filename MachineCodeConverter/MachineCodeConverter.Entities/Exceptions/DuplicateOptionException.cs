using System.Diagnostics.CodeAnalysis;

namespace MachineCodeConverter.Entities.Exceptions
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