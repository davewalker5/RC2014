using System.Globalization;
using MachineCodeConverter.Entities.Interfaces;

namespace MachineCodeConverter.Logic.Basic
{
    /// <summary>Formats raw bytes as numbered BASIC DATA statements without changing their order.</summary>
    public class BasicDataGenerator
    {
        public string[] Generate(byte[] bytes, IMachineCodeConverterAppSettings settings)
        {
            ArgumentNullException.ThrowIfNull(bytes);
            Validate(settings);
            if (bytes.Length == 0) throw new InvalidDataException("The binary file is empty.");
            var count = (bytes.Length - 1) / settings.BytesPerLine + 1;
            var lastLine = settings.BasicStartLineNumber + (long)(count - 1) * settings.BasicLineNumberIncrement;
            if (lastLine > 65529)
                throw new ArgumentException("Generated BASIC line numbers exceed 65529. Reduce the start line or increment.");

            var lines = new string[count];
            for (var i = 0; i < count; i++)
            {
                var values = bytes.Skip(i * settings.BytesPerLine).Take(settings.BytesPerLine)
                    .Select(b => settings.Hexadecimal ? "&H" + b.ToString("X2", CultureInfo.InvariantCulture)
                        : b.ToString(CultureInfo.InvariantCulture));
                var number = settings.BasicStartLineNumber + i * settings.BasicLineNumberIncrement;
                lines[i] = number.ToString(CultureInfo.InvariantCulture) + " DATA " + string.Join(",", values);
            }
            return lines;
        }

        public static void Validate(IMachineCodeConverterAppSettings settings)
        {
            ArgumentNullException.ThrowIfNull(settings);
            if (settings.BasicStartLineNumber is < 1 or > 65529)
                throw new ArgumentException("The first BASIC line must be from 1 to 65529.");
            if (settings.BasicLineNumberIncrement is < 1 or > 65529)
                throw new ArgumentException("The BASIC line increment must be from 1 to 65529.");
            // Sixteen hex bytes fit comfortably within the other converters' 120-character limit.
            if (settings.BytesPerLine is < 1 or > 16)
                throw new ArgumentException("Bytes per line must be from 1 to 16.");
        }
    }
}
