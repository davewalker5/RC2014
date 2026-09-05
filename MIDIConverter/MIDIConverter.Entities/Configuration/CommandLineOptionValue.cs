using System.Diagnostics.CodeAnalysis;

namespace MIDIConverter.Entities.Configuration
{
    [ExcludeFromCodeCoverage]
    public sealed class CommandLineOptionValue
    {
        public required CommandLineOption Option { get; set; }
        public List<string> Values { get; } = [];
    }
}
