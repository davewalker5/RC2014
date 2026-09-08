using System.Globalization;
using MachineCodeConverter.Entities.Configuration;
using MachineCodeConverter.Entities.Interfaces;

namespace MachineCodeConverter.Logic.Configuration
{
    /// <summary>Combines JSON defaults with command-line overrides.</summary>
    public class MachineCodeConverterSettingsBuilder
    {
        public IMachineCodeConverterAppSettings Settings { get; private set; } = new MachineCodeConverterAppSettings();
        public string FileName { get; private set; } = "";
        public string OutputFileName { get; private set; } = "";
        public bool ShowHelp { get; private set; }

        public void BuildSettings(IEnumerable<string> args, string configJsonPath)
        {
            var parser = new CommandLineParser();
            parser.Add(CommandLineOptionType.Convert, true, "--convert", "-c", "Input binary file", 1, 1);
            parser.Add(CommandLineOptionType.Output, false, "--output", "-o", "Output BASIC file", 1, 1);
            parser.Add(CommandLineOptionType.StartLine, false, "--startline", "-sl", "First BASIC line", 1, 1);
            parser.Add(CommandLineOptionType.LineIncrement, false, "--lineincrement", "-li", "BASIC line increment", 1, 1);
            parser.Add(CommandLineOptionType.BytesPerLine, false, "--bytesperline", "-b", "Bytes per DATA line", 1, 1);
            parser.Add(CommandLineOptionType.Hexadecimal, false, "--hex", "-x", "Hexadecimal bytes", 1, 1);
            parser.Add(CommandLineOptionType.Overwrite, false, "--overwrite", "-f", "Replace existing output", 1, 1);
            parser.Add(CommandLineOptionType.Help, false, "--help", "-h", "Show usage", 0, 0);
            parser.Parse(args);
            ShowHelp = parser.IsPresent(CommandLineOptionType.Help);
            if (ShowHelp) return;

            Settings = new ConfigReader<MachineCodeConverterAppSettings>().Read(configJsonPath)
                ?? throw new InvalidDataException("Missing ApplicationSettings configuration section.");
            FileName = Value(CommandLineOptionType.Convert) ?? "";
            OutputFileName = Value(CommandLineOptionType.Output) ?? "";
            if (string.IsNullOrWhiteSpace(FileName))
                throw new ArgumentException("No binary file supplied. Use --convert or -c. Use --help for usage.");

            ApplyInteger(CommandLineOptionType.StartLine, x => Settings.BasicStartLineNumber = x);
            ApplyInteger(CommandLineOptionType.LineIncrement, x => Settings.BasicLineNumberIncrement = x);
            ApplyInteger(CommandLineOptionType.BytesPerLine, x => Settings.BytesPerLine = x);
            ApplyBoolean(CommandLineOptionType.Hexadecimal, x => Settings.Hexadecimal = x);
            ApplyBoolean(CommandLineOptionType.Overwrite, x => Settings.OverwriteOutputFile = x);
            Basic.BasicDataGenerator.Validate(Settings);

            string Value(CommandLineOptionType option) => parser.GetValues(option)?.Single();
            void ApplyInteger(CommandLineOptionType option, Action<int> apply)
            {
                var text = Value(option);
                if (text == null) return;
                if (!int.TryParse(text, NumberStyles.Integer, CultureInfo.InvariantCulture, out var value))
                    throw new ArgumentException($"Invalid whole-number value '{text}' for {option}.");
                apply(value);
            }
            void ApplyBoolean(CommandLineOptionType option, Action<bool> apply)
            {
                var text = Value(option);
                if (text == null) return;
                if (!bool.TryParse(text, out var value))
                    throw new ArgumentException($"Invalid value '{text}' for {option}. Expected true or false.");
                apply(value);
            }
        }
    }
}
