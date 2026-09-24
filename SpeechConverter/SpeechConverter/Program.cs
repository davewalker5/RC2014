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
        /// Converts typed text, --text input or a text file to a BASIC file.
        /// </summary>
        /// <param name="args">A text file path, or options: --file, --text and --output.</param>
        /// <returns>Zero on success or a nonzero error code.</returns>
        public static int Main(string[] args)
        {
            try
            {
                string? message = null;
                string? inputPath = null;
                string outputPath = "speech.bas";
                for (var index = 0; index < args.Length; index++)
                {
                    if ((args[index] is "--text" or "-t") && index + 1 < args.Length)
                    {
                        message = args[++index];
                    }
                    else if ((args[index] is "--file" or "-f") && index + 1 < args.Length)
                    {
                        if (inputPath is not null)
                        {
                            throw new ArgumentException("Specify only one input file.");
                        }

                        inputPath = args[++index];
                    }
                    else if ((args[index] is "--output" or "-o") && index + 1 < args.Length)
                    {
                        outputPath = args[++index];
                    }
                    else if (args[index] is "--help" or "-h")
                    {
                        Console.WriteLine("Usage: SpeechConverter [file.txt | --file file.txt | --text \"message\"] [--output file.bas]");
                        Console.WriteLine("Short options: -f (file), -t (text), -o (output), -h (help).");
                        return 0;
                    }
                    else if (!args[index].StartsWith('-'))
                    {
                        if (inputPath is not null)
                        {
                            throw new ArgumentException("Specify only one input file.");
                        }

                        inputPath = args[index];
                    }
                    else
                    {
                        throw new ArgumentException($"Unrecognised or incomplete option: {args[index]}");
                    }
                }

                if (inputPath is not null)
                {
                    if (message is not null)
                    {
                        throw new ArgumentException("Specify either --text or an input file, not both.");
                    }

                    message = File.ReadAllText(inputPath);
                }
                else if (message is null)
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
