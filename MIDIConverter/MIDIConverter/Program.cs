using System.Diagnostics;
using System.Reflection;
using MIDIConverter.Logic;
using MIDIConverter.Logic.Basic;
using MIDIConverter.Logic.Configuration;
using MIDIConverter.Logic.Conversion;
using MIDIConverter.Logic.MIDI;
using MIDIConverter.Logic.SID;

namespace MIDIConverter
{
    /// <summary>
    /// Provides the MIDI Converter command-line entry point.
    /// </summary>
    public static class Program
    {
        /// <summary>
        /// Converts the MIDI file named on the command line.
        /// </summary>
        /// <param name="args">Command-line options controlling the conversion.</param>
        /// <returns>A process exit code indicating success, failure, or cancellation.</returns>
        public static async Task<int> Main(string[] args)
        {
            // Convert Ctrl+C into cooperative cancellation so file operations and
            // the conversion workflow can stop without terminating mid-write.
            using var cancellation = new CancellationTokenSource();
            Console.CancelKeyPress += (_, eventArgs) =>
            {
                eventArgs.Cancel = true;
                cancellation.Cancel();
            };

            try
            {
                // Resolve appsettings.json beside the executable so behaviour does
                // not depend on the directory from which the command was launched.
                var builder = new MIDIConverterSettingsBuilder();
                var configPath = Path.Combine(AppContext.BaseDirectory, "appsettings.json");
                builder.BuildSettings(args, configPath);

                // Program is the composition root: construct the concrete services
                // here while keeping parsing and conversion logic out of the UI.
                var service = new MIDIConverterService(
                    new MIDIFileReader(),
                    new MIDIArranger(new SIDPitchConverter()),
                    new BasicProgramGenerator());
                var result = await service.ConvertAsync(
                    builder.InputFileName,
                    builder.OutputFileName,
                    builder.Settings,
                    cancellation.Token);

                // Report the conversion outcome only after the output file has been
                // written successfully by the coordinating service.
                WriteTitle();
                Console.WriteLine($"Output: {result.OutputPath}");
                Console.WriteLine($"MIDI format: {result.MIDIFormat}; tracks: {result.TrackCount}");
                Console.WriteLine(
                    $"Notes: {result.SourceNoteCount}; playback records: {result.PlaybackStepCount}; " +
                    $"duration: {result.DurationSeconds:0.###} seconds");
                Console.WriteLine($"Generated BASIC lines: {result.BasicLineCount}");
                Console.WriteLine(
                    $"Discarded notes: {result.DiscardedPitchedNotes}; " +
                    $"ignored percussion: {result.IgnoredPercussionNotes}; " +
                    $"ignored controllers: {result.IgnoredControllerEvents}");

                // Warnings describe recoverable simplifications or source issues;
                // they do not change a successful process exit code.
                foreach (var warning in result.Warnings)
                {
                    Console.WriteLine($"Warning: {warning}");
                }

                return 0;
            }
            catch (OperationCanceledException)
            {
                // Keep cancellation distinct from conversion failure for scripts
                // and other callers that inspect the process exit code.
                Console.Error.WriteLine("Conversion cancelled.");
                return 2;
            }
            catch (Exception exception)
            {
                // This command-line boundary converts expected and unexpected
                // failures into concise output rather than displaying a stack trace.
                Console.Error.WriteLine($"Error: {exception.Message}");
                return 1;
            }
        }

        private static void WriteTitle()
        {
            // Read the file version embedded by the build so displayed versioning
            // stays aligned with the executable being run.
            var assembly = Assembly.GetExecutingAssembly();
            var version = FileVersionInfo.GetVersionInfo(assembly.Location).FileVersion;
            Console.WriteLine($"MIDI Converter v{version}");
            Console.WriteLine();
        }
    }
}
