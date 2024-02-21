using System.Diagnostics.CodeAnalysis;

namespace Renumber.Entities.Configuration
{
    [ExcludeFromCodeCoverage]
    public class CommandLineOption
    {
        public CommandLineOptionType OptionType { get; set; }
        public bool IsOperation { get; set; }
        public string Name { get; set; } = "";
        public string ShortName { get; set; } = "";
        public string Description { get; set; } = "";
        public int MinimumNumberOfValues { get; set; } = 0;
        public int MaximumNumberOfValues { get; set; } = 0;
    }
}
