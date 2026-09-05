using System.Globalization;
using MIDIConverter.Entities.Configuration;
using MIDIConverter.Entities.Exceptions;
using MIDIConverter.Entities.Interfaces;

namespace MIDIConverter.Logic.Configuration
{
    /// <summary>
    /// Combines JSON defaults with command-line overrides.
    /// </summary>
    public sealed class MIDIConverterSettingsBuilder
    {
        public IMIDIConverterAppSettings Settings { get; private set; } = new MIDIConverterAppSettings();
        public string InputFileName { get; private set; } = "";
        public string OutputFileName { get; private set; } = "";

        /// <summary>
        /// Builds and validates the settings for one conversion.
        /// </summary>
        public void BuildSettings(IEnumerable<string> args, string configJsonPath)
        {
            Settings = new ConfigReader<MIDIConverterAppSettings>().Read(configJsonPath);
            var parser = CreateParser();
            parser.Parse(args);

            InputFileName = Value(parser, CommandLineOptionType.Convert) ?? "";
            OutputFileName = Value(parser, CommandLineOptionType.Output) ?? "";
            ApplyInteger(parser, CommandLineOptionType.StepsPerQuarterNote, x => Settings.StepsPerQuarterNote = x);
            ApplyDouble(parser, CommandLineOptionType.TempoBeatsPerMinute, x => Settings.TempoBeatsPerMinute = x);
            ApplyInteger(parser, CommandLineOptionType.SIDClockHertz, x => Settings.SIDClockHertz = x);
            ApplyInteger(parser, CommandLineOptionType.MasterVolume, x => Settings.MasterVolume = x);
            ApplyInteger(parser, CommandLineOptionType.PulseWidth, x => Settings.PulseWidth = x);
            ApplyInteger(
                parser,
                CommandLineOptionType.DelayLoopIterationsPerMillisecond,
                x => Settings.DelayLoopIterationsPerMillisecond = x);
            ApplyInteger(parser, CommandLineOptionType.BasicStartLineNumber, x => Settings.BasicStartLineNumber = x);
            ApplyInteger(
                parser,
                CommandLineOptionType.BasicLineNumberIncrement,
                x => Settings.BasicLineNumberIncrement = x);
            ApplyBoolean(parser, CommandLineOptionType.OverwriteOutputFile, x => Settings.OverwriteOutputFile = x);
            ApplyBoolean(parser, CommandLineOptionType.Verbose, x => Settings.Verbose = x);

            var waveform = Value(parser, CommandLineOptionType.Waveform);
            if (waveform is not null)
            {
                if (!Enum.TryParse<SIDWaveform>(waveform, true, out var parsedWaveform))
                {
                    throw new InvalidSettingsException(
                        $"Invalid value for --waveform: '{waveform}'. Expected Triangle, Sawtooth or Pulse.");
                }

                Settings.Waveform = parsedWaveform;
            }

            Validate();
        }

        private static CommandLineParser CreateParser()
        {
            var parser = new CommandLineParser();
            parser.Add(CommandLineOptionType.Convert, true, "--convert", "-c", "Convert a MIDI file", 1, 1);
            parser.Add(CommandLineOptionType.Output, false, "--output", "-o", "Output BASIC file", 1, 1);
            parser.Add(CommandLineOptionType.StepsPerQuarterNote, false, "--steps", "-q", "Steps per quarter note", 1, 1);
            parser.Add(CommandLineOptionType.TempoBeatsPerMinute, false, "--tempo", "-t", "Tempo override", 1, 1);
            parser.Add(CommandLineOptionType.SIDClockHertz, false, "--sidclock", "-sc", "SID clock in hertz", 1, 1);
            parser.Add(CommandLineOptionType.MasterVolume, false, "--volume", "-v", "Master volume", 1, 1);
            parser.Add(CommandLineOptionType.Waveform, false, "--waveform", "-w", "Pitched waveform", 1, 1);
            parser.Add(CommandLineOptionType.PulseWidth, false, "--pulsewidth", "-pw", "Pulse width", 1, 1);
            parser.Add(CommandLineOptionType.DelayLoopIterationsPerMillisecond, false, "--delayfactor", "-df", "Delay loop calibration", 1, 1);
            parser.Add(CommandLineOptionType.BasicStartLineNumber, false, "--startline", "-sl", "First BASIC line", 1, 1);
            parser.Add(CommandLineOptionType.BasicLineNumberIncrement, false, "--lineincrement", "-li", "BASIC line increment", 1, 1);
            parser.Add(CommandLineOptionType.OverwriteOutputFile, false, "--overwrite", "-f", "Overwrite output", 1, 1);
            parser.Add(CommandLineOptionType.Verbose, false, "--verbose", "-d", "Verbose diagnostics", 1, 1);
            return parser;
        }

        private static string? Value(CommandLineParser parser, CommandLineOptionType option)
            => parser.GetValues(option)?.Single();

        private static void ApplyInteger(
            CommandLineParser parser,
            CommandLineOptionType option,
            Action<int> apply)
        {
            var text = Value(parser, option);
            if (text is null)
            {
                return;
            }

            if (!int.TryParse(text, NumberStyles.Integer, CultureInfo.InvariantCulture, out var value))
            {
                throw new InvalidSettingsException($"Invalid whole-number value '{text}'.");
            }

            apply(value);
        }

        private static void ApplyDouble(
            CommandLineParser parser,
            CommandLineOptionType option,
            Action<double> apply)
        {
            var text = Value(parser, option);
            if (text is null)
            {
                return;
            }

            if (!double.TryParse(text, NumberStyles.Float, CultureInfo.InvariantCulture, out var value))
            {
                throw new InvalidSettingsException($"Invalid numeric value '{text}'.");
            }

            apply(value);
        }

        private static void ApplyBoolean(
            CommandLineParser parser,
            CommandLineOptionType option,
            Action<bool> apply)
        {
            var text = Value(parser, option);
            if (text is null)
            {
                return;
            }

            if (!bool.TryParse(text, out var value))
            {
                throw new InvalidSettingsException($"Invalid Boolean value '{text}'. Expected true or false.");
            }

            apply(value);
        }

        private void Validate()
        {
            if (string.IsNullOrWhiteSpace(InputFileName))
            {
                throw new InvalidSettingsException("No MIDI file was supplied. Use --convert or -c.");
            }

            if (Settings.StepsPerQuarterNote is < 1 or > 32)
            {
                throw new InvalidSettingsException("Steps per quarter note must be from 1 to 32.");
            }

            if (Settings.TempoBeatsPerMinute is double tempo &&
                (!double.IsFinite(tempo) || tempo <= 0))
            {
                throw new InvalidSettingsException("Tempo must be a finite value greater than zero.");
            }

            if (Settings.SIDClockHertz <= 0)
            {
                throw new InvalidSettingsException("SID clock frequency must be greater than zero.");
            }

            if (Settings.MasterVolume is < 0 or > 15)
            {
                throw new InvalidSettingsException("Master volume must be from 0 to 15.");
            }

            if (Settings.PulseWidth is < 0 or > 4095)
            {
                throw new InvalidSettingsException("Pulse width must be from 0 to 4095.");
            }

            if (Settings.DelayLoopIterationsPerMillisecond <= 0 ||
                Settings.BasicStartLineNumber <= 0 ||
                Settings.BasicLineNumberIncrement <= 0)
            {
                throw new InvalidSettingsException("Delay and BASIC line-number settings must be positive.");
            }
        }
    }
}
