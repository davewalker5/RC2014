using SpeechConverter.Logic;
using SpeechConverter.Logic.Basic;
using SpeechConverter.Logic.Pronunciation;

namespace SpeechConverter
{
    /// <summary>
    /// Command-line entry point for MG005 speech conversion.
    /// </summary>
    public static class Program
    {
        /// <summary>
        /// Converts typed text or --text input to a BASIC file.
        /// </summary>
        /// <param name="args">Options: --text and --output.</param>
        /// <returns>Zero on success or a nonzero error code.</returns>
        public static int Main(string[] args)
        {
            try
            {
                string? message = null;
                string outputPath = "speech.bas";
                for (var index = 0; index < args.Length; index++)
                {
                    if ((args[index] is "--text" or "-t") && index + 1 < args.Length)
                    {
                        message = args[++index];
                    }
                    else if ((args[index] is "--output" or "-o") && index + 1 < args.Length)
                    {
                        outputPath = args[++index];
                    }
                    else if (args[index] is "--help" or "-h")
                    {
                        Console.WriteLine("Usage: SpeechConverter [--text \"message\"] [--output file.bas]");
                        return 0;
                    }
                    else
                    {
                        throw new ArgumentException($"Unrecognised or incomplete option: {args[index]}");
                    }
                }

                if (message is null)
                {
                    Console.Write("Message: ");
                    message = Console.ReadLine();
                }

                var service = new SpeechConverterService(
                    new EnglishPronunciationConverter(),
                    new BasicProgramGenerator());
                var listing = service.Convert(message ?? "");
                File.WriteAllText(outputPath, listing);
                Console.WriteLine($"BASIC program: {Path.GetFullPath(outputPath)}");
                return 0;
            }
            catch (Exception exception)
            {
                Console.Error.WriteLine($"Error: {exception.Message}");
                return 1;
            }
        }
    }
}
