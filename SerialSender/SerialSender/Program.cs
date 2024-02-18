using SerialSender.Entities.Serial;
using SerialSender.Entities.Configuration;
using SerialSender.Entities.Events;
using SerialSender.Entities.Interfaces;
using SerialSender.Logic;
using SerialSender.Logic.Configuration;
using System.Diagnostics;
using System.Reflection;

namespace SerialSender
{
    public class Program
    {
        private static int _count = 0;
        private static ISerialSenderAppSettings _settings = new ConfigReader<SerialSenderAppSettings>().Read("appsettings.json");

        public static void Main(string[] args)
        {
            // Get the version number and application title
            Assembly assembly = Assembly.GetExecutingAssembly();
            FileVersionInfo info = FileVersionInfo.GetVersionInfo(assembly.Location);
            var title = $"Serial Port File Sender v{info.FileVersion}";

            // Log the startup messages
            Console.WriteLine($"{title}\n");
            Console.WriteLine($"Serial port: {_settings.PortName}");
            Console.WriteLine($"Baud rate: {_settings.BaudRate}");
            Console.WriteLine($"Parity: {_settings.Parity}");
            Console.WriteLine($"Data bits: {_settings.DataBits}");
            Console.WriteLine($"Stop bits: {_settings.StopBits}");
            Console.WriteLine($"Handshake: {_settings.Handshake}");
            Console.WriteLine($"Block Size: {_settings.BlockSize} characters");
            Console.WriteLine($"Block Delay: {_settings.BlockDelay} ms");
            Console.WriteLine($"Line Delay: {_settings.LineDelay} ms");
            Console.WriteLine($"Send NEW command: {_settings.SendNewCommand}");
            Console.WriteLine($"Verbose Output: {_settings.Verbose}\n");

            // Check the user's provided the name of a file to transfer
            if (args.Length != 1)
            {
                Console.WriteLine("Warning: No file name provided\n");
                Console.WriteLine($"Usage: {AppDomain.CurrentDomain.FriendlyName} <filename>");
                return;
            }

            // Create an instance of the serial port writer and subscribe to the "string written" event
            var port = new SerialSenderSerialPort(_settings);
            var writer = new SerialPortWriter(port, _settings);
            writer.StringWritten += OnStringWritten;

            // Send the file
            Console.WriteLine($"Sending file {args[0]} to serial port {_settings.PortName} at {_settings.BaudRate} baud.");
            try
            {
                writer.Open();
                writer.WriteFile(args[0]);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
                return;
            }
            finally
            {
                writer.Close();
            }

            // Unsubscribe from the "string written" event
            writer.StringWritten -= OnStringWritten;

            // Log the completion message
            Console.WriteLine($"\n\n{_count} lines of data sent");    
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
