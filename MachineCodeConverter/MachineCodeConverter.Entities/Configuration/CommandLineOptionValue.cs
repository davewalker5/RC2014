using System.Diagnostics.CodeAnalysis;

namespace MachineCodeConverter.Entities.Configuration
{
    [ExcludeFromCodeCoverage]
    public class CommandLineOptionValue
    {
        public CommandLineOption Option { get; set; }
        public List<string> Values { get; private set; } = new();
    }
}
