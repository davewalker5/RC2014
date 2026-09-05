using MIDIConverter.Entities.Conversion;
using MIDIConverter.Entities.Exceptions;
using MIDIConverter.Entities.Interfaces;
using MIDIConverter.Logic.Basic;
using MIDIConverter.Logic.Conversion;

namespace MIDIConverter.Logic
{
    /// <summary>
    /// Coordinates MIDI reading, arrangement, BASIC rendering and safe output.
    /// </summary>
    public sealed class MIDIConverterService
    {
        private readonly IMIDIFileReader _reader;
        private readonly MIDIArranger _arranger;
        private readonly BasicProgramGenerator _generator;

        public MIDIConverterService(
            IMIDIFileReader reader,
            MIDIArranger arranger,
            BasicProgramGenerator generator)
        {
            _reader = reader;
            _arranger = arranger;
            _generator = generator;
        }

        /// <summary>
        /// Converts a MIDI file and safely writes the generated BASIC program.
        /// </summary>
        public async Task<ConversionResult> ConvertAsync(
            string inputPath,
            string? outputPath,
            IMIDIConverterAppSettings settings,
            CancellationToken cancellationToken = default)
        {
            var input = Path.GetFullPath(inputPath);
            if (!File.Exists(input))
            {
                throw new FileNotFoundException("The MIDI input file was not found.", input);
            }

            if (!IsExtension(input, ".mid") && !IsExtension(input, ".midi"))
            {
                throw new InvalidSettingsException("The input file must have a .mid or .midi extension.");
            }

            var output = Path.GetFullPath(string.IsNullOrWhiteSpace(outputPath)
                ? Path.ChangeExtension(input, ".bas")
                : outputPath);
            if (!IsExtension(output, ".bas"))
            {
                throw new InvalidSettingsException("The output file must have a .bas extension.");
            }

            var comparison = OperatingSystem.IsWindows()
                ? StringComparison.OrdinalIgnoreCase
                : StringComparison.Ordinal;
            if (string.Equals(input, output, comparison))
            {
                throw new InvalidSettingsException("The input and output paths must be different.");
            }

            if (File.Exists(output) && !settings.OverwriteOutputFile)
            {
                throw new IOException(
                    $"The output file '{output}' already exists. Use --overwrite true to replace it.");
            }

            var directory = Path.GetDirectoryName(output);
            if (string.IsNullOrWhiteSpace(directory) || !Directory.Exists(directory))
            {
                throw new DirectoryNotFoundException($"The output directory does not exist: '{directory}'.");
            }

            var midi = await _reader.ReadAsync(input, cancellationToken).ConfigureAwait(false);
            var arrangement = _arranger.Arrange(midi, settings);
            var basic = _generator.Generate(Path.GetFileName(input), arrangement.Steps, settings);
            await WriteSafelyAsync(output, basic, settings.OverwriteOutputFile, cancellationToken)
                .ConfigureAwait(false);

            return new ConversionResult
            {
                BasicSource = basic,
                OutputPath = output,
                MIDIFormat = midi.Format,
                TrackCount = midi.TrackCount,
                SourceNoteCount = midi.Notes.Count,
                PlaybackStepCount = arrangement.Steps.Count,
                BasicLineCount = basic.Count(x => x == '\n'),
                DiscardedPitchedNotes = arrangement.DiscardedNoteCount,
                IgnoredPercussionNotes = midi.IgnoredPercussionNotes,
                IgnoredControllerEvents = midi.IgnoredControllerEvents,
                DurationSeconds = arrangement.Steps.Sum(x => (long)x.DurationMilliseconds) / 1000d,
                Warnings = arrangement.Warnings
            };
        }

        private static bool IsExtension(string path, string expected)
            => string.Equals(Path.GetExtension(path), expected, StringComparison.OrdinalIgnoreCase);

        private static async Task WriteSafelyAsync(
            string output,
            string content,
            bool overwrite,
            CancellationToken cancellationToken)
        {
            var directory = Path.GetDirectoryName(output)!;
            var temporary = Path.Combine(directory, $".{Path.GetFileName(output)}.{Guid.NewGuid():N}.tmp");
            try
            {
                await File.WriteAllTextAsync(temporary, content, cancellationToken).ConfigureAwait(false);
                File.Move(temporary, output, overwrite);
            }
            finally
            {
                if (File.Exists(temporary))
                {
                    File.Delete(temporary);
                }
            }
        }
    }
}
