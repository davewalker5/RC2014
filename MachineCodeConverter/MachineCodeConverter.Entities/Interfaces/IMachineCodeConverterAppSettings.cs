namespace MachineCodeConverter.Entities.Interfaces
{
    public interface IMachineCodeConverterAppSettings
    {
        int BasicStartLineNumber { get; set; }
        int BasicLineNumberIncrement { get; set; }
        int BytesPerLine { get; set; }
        bool Hexadecimal { get; set; }
        bool OverwriteOutputFile { get; set; }
    }
}
