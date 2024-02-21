using System.Diagnostics.CodeAnalysis;

namespace Renumber.Entities.Exceptions
{
    [ExcludeFromCodeCoverage]
    public class MissingFileNameException : Exception
    {
        public MissingFileNameException()
        {
        }

        public MissingFileNameException(string message) : base(message)
        {
        }

        public MissingFileNameException(string message, Exception inner) : base(message, inner)
        {
        }
    }
}
