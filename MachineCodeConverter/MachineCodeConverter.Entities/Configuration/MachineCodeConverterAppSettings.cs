using MachineCodeConverter.Entities.Interfaces;

namespace MachineCodeConverter.Entities.Configuration
{
    public class MachineCodeConverterAppSettings : IMachineCodeConverterAppSettings
    {
        public int BasicStartLineNumber { get; set; } = 1000;
        public int BasicLineNumberIncrement { get; set; } = 10;
        public int BytesPerLine { get; set; } = 16;
        public bool Hexadecimal { get; set; } = false;
        public bool OverwriteOutputFile { get; set; } = false;
    }
}
