using System.Text;
using MachineCodeConverter.Entities.Interfaces;
using MachineCodeConverter.Logic.Basic;

namespace MachineCodeConverter.Logic
{
    public class MachineCodeConverterService
    {
        public string Convert(string inputFileName, string outputFileName, IMachineCodeConverterAppSettings settings)
        {
            BasicDataGenerator.Validate(settings);
            var input = Path.GetFullPath(inputFileName);
            var output = Path.GetFullPath(string.IsNullOrWhiteSpace(outputFileName)
                ? Path.ChangeExtension(input, ".bas") : outputFileName);
            if (string.Equals(input, output, StringComparison.OrdinalIgnoreCase))
                throw new ArgumentException("Input and output must be different files.");
            if (File.Exists(output) && !settings.OverwriteOutputFile)
                throw new IOException($"Output file already exists: {output}. Use --overwrite true to replace it.");

            var lines = new BasicDataGenerator().Generate(File.ReadAllBytes(input), settings);
            // Write beside the destination, then rename, so conversion failures leave existing output intact.
            var temporary = Path.Combine(Path.GetDirectoryName(output)!, $".machinecode-{Guid.NewGuid():N}.tmp");
            try
            {
                File.WriteAllText(temporary, string.Join("\n", lines) + "\n", new UTF8Encoding(false));
                File.Move(temporary, output, settings.OverwriteOutputFile);
            }
            finally
            {
                if (File.Exists(temporary)) File.Delete(temporary);
            }
            return output;
        }
    }
}
