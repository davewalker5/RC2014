using System.Globalization;
using MIDIConverter.Entities.Configuration;
using MIDIConverter.Entities.Conversion;
using MIDIConverter.Entities.Exceptions;
using MIDIConverter.Entities.Interfaces;

namespace MIDIConverter.Logic.Basic
{
    /// <summary>
    /// Renders SID playback steps as a self-contained Microsoft BASIC program.
    /// </summary>
    public sealed class BasicProgramGenerator
    {
        private const string DefaultTemplateName = "SIDPlayer.bas.template";
        private readonly string _templatePath;

        /// <summary>
        /// Initialises a generator using the player template deployed with the application.
        /// </summary>
        public BasicProgramGenerator()
            : this(Path.Combine(AppContext.BaseDirectory, "Templates", DefaultTemplateName))
        {
        }

        /// <summary>
        /// Initialises a generator using a specific player template.
        /// </summary>
        /// <param name="templatePath">Path to the unnumbered BASIC player template.</param>
        public BasicProgramGenerator(string templatePath)
        {
            ArgumentException.ThrowIfNullOrWhiteSpace(templatePath);
            _templatePath = templatePath;
        }

        /// <summary>
        /// Generates a line-numbered BASIC player and its DATA records.
        /// </summary>
        public string Generate(
            string sourceName,
            IReadOnlyList<PlaybackStep> steps,
            IMIDIConverterAppSettings settings)
        {
            ArgumentException.ThrowIfNullOrWhiteSpace(sourceName);
            ArgumentNullException.ThrowIfNull(steps);
            ArgumentNullException.ThrowIfNull(settings);

            // SID control registers use one bit for each waveform. The gate bit is
            // deliberately omitted here because the emitted player controls it.
            var waveform = settings.Waveform switch
            {
                SIDWaveform.Triangle => 16,
                SIDWaveform.Sawtooth => 32,
                SIDWaveform.Pulse => 64,
                _ => throw new InvalidSettingsException($"Unsupported waveform: {settings.Waveform}.")
            };

            // Load the fixed player first, then append the variable-length music
            // data and a zero-duration sentinel understood by the read loop.
            var statements = LoadPlayerTemplate(sourceName, settings, waveform);
            foreach (var step in steps)
            {
                statements.Add(new(null,
                    $"DATA {step.DurationMilliseconds},{step.Frequency1},{step.Frequency2}," +
                    $"{step.Frequency3},{step.ActiveMask},{step.RetriggerMask}"));
            }

            statements.Add(new(null, "DATA 0,0,0,0,0,0"));

            // Resolve symbolic targets only after the complete statement list is
            // known, allowing custom start lines and increments to work safely.
            var labelLines = statements
                .Select((statement, index) => (statement.Label, Line: LineNumber(index, settings)))
                .Where(x => x.Label is not null)
                .ToDictionary(x => x.Label!, x => x.Line, StringComparer.Ordinal);
            var lines = new List<string>(statements.Count);

            for (var index = 0; index < statements.Count; index++)
            {
                // Validate target-dialect limits while materialising each numbered
                // line so an unusable program is never returned to the caller.
                var lineNumber = LineNumber(index, settings);
                if (lineNumber > 65529)
                {
                    throw new MIDIConversionException(
                        "The generated BASIC program exceeds the available line-number range.");
                }

                var text = statements[index].Text;
                foreach (var label in labelLines)
                {
                    text = text.Replace($"@{label.Key}@", label.Value.ToString(CultureInfo.InvariantCulture));
                }

                var line = $"{lineNumber} {text}";
                if (line.Length > 120)
                {
                    throw new MIDIConversionException(
                        $"Generated BASIC line {lineNumber} exceeds the 120-character compatibility limit.");
                }

                lines.Add(line);
            }

            return string.Join(Environment.NewLine, lines) + Environment.NewLine;
        }

        private List<Statement> LoadPlayerTemplate(
            string sourceName,
            IMIDIConverterAppSettings settings,
            int waveform)
        {
            // MIDI metadata is untrusted input. Restrict the source-name comment
            // to printable ASCII and remove quotes that could alter BASIC syntax.
            var safeName = new string(sourceName
                .Where(x => x is >= ' ' and <= '~' && x != '"')
                .Take(60)
                .ToArray());

            // SID pulse width occupies twelve bits split over two registers for
            // each voice, even though these writes are harmless for other waves.
            var pulseLow = settings.PulseWidth % 256;
            var pulseHigh = settings.PulseWidth / 256;

            if (!File.Exists(_templatePath))
            {
                throw new FileNotFoundException("The BASIC player template was not found.", _templatePath);
            }

            // Replace configuration tokens before parsing labels. Values are
            // converter-controlled, apart from the already sanitised source name.
            var replacements = new Dictionary<string, string>(StringComparer.Ordinal)
            {
                ["{{SOURCE_NAME}}"] = safeName,
                ["{{SID_CLOCK_HERTZ}}"] = settings.SIDClockHertz.ToString(CultureInfo.InvariantCulture),
                ["{{WAVEFORM_NAME}}"] = settings.Waveform.ToString(),
                ["{{WAVEFORM_VALUE}}"] = waveform.ToString(CultureInfo.InvariantCulture),
                ["{{STEPS_PER_QUARTER_NOTE}}"] = settings.StepsPerQuarterNote.ToString(CultureInfo.InvariantCulture),
                ["{{MASTER_VOLUME}}"] = settings.MasterVolume.ToString(CultureInfo.InvariantCulture),
                ["{{DELAY_FACTOR}}"] = settings.DelayLoopIterationsPerMillisecond.ToString(CultureInfo.InvariantCulture),
                ["{{PULSE_LOW}}"] = pulseLow.ToString(CultureInfo.InvariantCulture),
                ["{{PULSE_HIGH}}"] = pulseHigh.ToString(CultureInfo.InvariantCulture)
            };
            var statements = new List<Statement>();
            foreach (var templateLine in File.ReadAllLines(_templatePath))
            {
                var text = templateLine.Trim();
                if (string.IsNullOrWhiteSpace(text))
                {
                    continue;
                }

                foreach (var replacement in replacements)
                {
                    text = text.Replace(replacement.Key, replacement.Value, StringComparison.Ordinal);
                }

                // A [[LABEL]] prefix marks a statement as a branch target without
                // emitting template-only syntax into the generated BASIC program.
                string? label = null;
                if (text.StartsWith("[[", StringComparison.Ordinal))
                {
                    var labelEnd = text.IndexOf("]]", StringComparison.Ordinal);
                    if (labelEnd < 2)
                    {
                        throw new InvalidDataException($"Malformed label in BASIC player template: '{text}'.");
                    }

                    label = text[2..labelEnd];
                    text = text[(labelEnd + 2)..].TrimStart();
                }

                if (text.Contains("{{", StringComparison.Ordinal) || string.IsNullOrWhiteSpace(text))
                {
                    throw new InvalidDataException($"Unresolved or empty line in BASIC player template: '{text}'.");
                }

                statements.Add(new Statement(label, text));
            }

            if (statements.Count == 0)
            {
                throw new InvalidDataException("The BASIC player template contains no statements.");
            }

            return statements;
        }

        private static int LineNumber(int index, IMIDIConverterAppSettings settings)
        {
            // Checked arithmetic prevents a wrapped line number from producing a
            // syntactically valid-looking but incorrectly ordered BASIC program.
            return checked(settings.BasicStartLineNumber + (index * settings.BasicLineNumberIncrement));
        }

        private sealed record Statement(string? Label, string Text);
    }
}
