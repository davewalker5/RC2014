using SerialSender.Entities.Serial;
using SerialSender.Entities.Events;
using SerialSender.Entities.Exceptions;
using SerialSender.Entities.Interfaces;
using SerialSender.Logic;
using SerialSender.Logic.Configuration;
using SerialSender.Logic.Reader;
using System.Diagnostics;
using System.Reflection;

namespace SerialSender
{
    public class Program
    {
        private static int _count = 0;
        private static ISerialSenderAppSettings _settings = null;

        public static void Main(string[] args)
        {
            SerialPortWriter writer = null;

            // Get the version number and application title
            Assembly assembly = Assembly.GetExecutingAssembly();
            FileVersionInfo info = FileVersionInfo.GetVersionInfo(assembly.Location);
            var title = $"Serial Port File Sender v{info.FileVersion}";

            try
            {
                // Read the application settings and parse the command line to yield the settings for
                // this run
                var builder = new SerialSenderSettingsBuilder();
                builder.BuildSettings(args, "appsettings.json");
                _settings = builder.Settings;

                // Check the user's provided the name of a file to transfer
                if (string.IsNullOrEmpty(builder.FileName))
                {
                    var message = "No file name provided";
                    throw new MissingFileNameException(message);
                }

                // Log the startup messages
                Console.WriteLine($"{title}\n");
                Console.WriteLine($"File to send: {builder.FileName}");
                Console.WriteLine($"Serial port: {_settings.PortName}");
                Console.WriteLine($"Baud rate: {_settings.BaudRate}");
                Console.WriteLine($"Parity: {_settings.Parity}");
                Console.WriteLine($"Data bits: {_settings.DataBits}");
                Console.WriteLine($"Stop bits: {_settings.StopBits}");
                Console.WriteLine($"Handshake: {_settings.Handshake}");
                Console.WriteLine($"Block Size: {_settings.BlockSize} characters");
                Console.WriteLine($"Block Delay: {_settings.BlockDelay} ms");
                Console.WriteLine($"Line Delay: {_settings.LineDelay} ms");
                Console.WriteLine($"Send reset command: {_settings.SendResetCommand}");
                Console.WriteLine($"Verbose Output: {_settings.Verbose}\n");

                // Read the file
                var reader = new SourceFileReader(new FileWrapper());
                reader.Read(builder.FileName);

                // Create an instance of the serial port writer and subscribe to the "string written" event
                var port = new SerialSenderSerialPort(_settings);
                writer = new SerialPortWriter(port, _settings);
                writer.StringWritten += OnStringWritten;

                // Send the file
                writer.Open();
                writer.WriteStrings(reader.Lines, reader.FileType);

                // Unsubscribe from the "string written" event
                writer.StringWritten -= OnStringWritten;

                // Log the completion message
                Console.WriteLine($"\n\n{_count} lines of data sent");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
            finally
            {
                if (writer != null) writer.Close();
            }
        }

        /// <summary>
        /// Handler for the "string written" event
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private static void OnStringWritten(object sender, StringWrittenEventArgs e)
        {
            _count = e.Count;
            if (_settings.Verbose)
            {
                Console.WriteLine(e.Data);
            }
            else
            {
                Console.Write(".");
            }
        }
    }
}
