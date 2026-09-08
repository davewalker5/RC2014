using MachineCodeConverter.Logic;
using MachineCodeConverter.Logic.Configuration;

namespace MachineCodeConverter
{
    public class Program
    {
        public static int Main(string[] args)
        {
            try
            {
                var builder = new MachineCodeConverterSettingsBuilder();
                builder.BuildSettings(args, Path.Combine(AppContext.BaseDirectory, "appsettings.json"));
                if (builder.ShowHelp)
                {
                    Console.WriteLine("""
                        MachineCodeConverter --convert input.bin [options]
                          --convert       -c   Input raw binary file (required)
                          --output        -o   Output file (default: input name with .bas)
                          --startline     -sl  First BASIC line (default: 1000)
                          --lineincrement -li  Line increment (default: 10)
                          --bytesperline  -b   Bytes per DATA line, 1-16 (default: 16)
                          --hex           -x   true/false: use &H hex bytes (default: false)
                          --overwrite     -f   true/false: replace output (default: false)
                          --help          -h   Show this help
                        Defaults can be changed in appsettings.json beside the executable.
                        """);
                    return 0;
                }
                var output = new MachineCodeConverterService().Convert(builder.FileName, builder.OutputFileName, builder.Settings);
                Console.WriteLine($"Output: {output}");
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
