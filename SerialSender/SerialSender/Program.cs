using SerialSender.Entities.Communications;
using SerialSender.Entities.Configuration;
using SerialSender.Entities.Events;
using SerialSender.Logic;
using SerialSender.Logic.Configuration;
using System.Diagnostics;
using System.Reflection;

namespace SerialSender
{
    public class Program
    {
        private static int _count = 0;

        public static void Main(string[] args)
        {
            // Get the version number and application title
            Assembly assembly = Assembly.GetExecutingAssembly();
            FileVersionInfo info = FileVersionInfo.GetVersionInfo(assembly.Location);
            var title = $"Serial Port File Sender v{info.FileVersion}";

            // Read the configuration settings
            var settings = new ConfigReader<SerialSenderAppSettings>().Read("appsettings.json");

            // Log the startup messages
            Console.WriteLine($"{title}\n");
            Console.WriteLine($"Serial port: {settings.PortName}");
            Console.WriteLine($"Baud rate: {settings.BaudRate}");
            Console.WriteLine($"Parity: {settings.Parity}");
            Console.WriteLine($"Data bits: {settings.DataBits}");
            Console.WriteLine($"Stop bits: {settings.StopBits}");
            Console.WriteLine($"Delay: {settings.Delay} ms\n");

            // Check the user's provided the name of a file to transfer
            if (args.Length != 1)
            {
                Console.WriteLine("Warning: No file name provided\n");
                Console.WriteLine($"Usage: {AppDomain.CurrentDomain.FriendlyName} <filename>");
                return;
            }

            // Create an instance of the serial port writer and subscribe to the "string written" event
            var port = new SerialSenderSerialPort(settings);
            var writer = new SerialPortWriter(port, settings);
            writer.StringWritten += OnStringWritten;

            // Send the file
            Console.WriteLine($"Sending file {args[0]} to serial port {settings.PortName} at {settings.BaudRate} baud.");
            writer.Open();
            writer.WriteFile(args[0]);
            writer.Close();

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
            Console.Write(".");
        }
    }
}
