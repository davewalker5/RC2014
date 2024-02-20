using SerialSender.Entities.Configuration;
using SerialSender.Entities.Interfaces;
using System.IO.Ports;

namespace SerialSender.Logic.Configuration
{
    public class SerialSenderSettingsBuilder
    {
        public ISerialSenderAppSettings Settings {get; private set;}
        public string FileName {get; private set;}

        /// <summary>
        /// Build the settings for the application from the configuration file, that provides the
        /// default values, and the command line options, that provide the overrides.
        /// </summary>
        /// <param name="args"></param>
        /// <param name="configJsonPath"></param>
        public void BuildSettings(IEnumerable<string> args, string configJsonPath)
        {
            // Read the default settings from the configuration file
            Settings = new ConfigReader<SerialSenderAppSettings>().Read(configJsonPath);

            // Parse the command line
            CommandLineParser parser = new();
            parser.Add(CommandLineOptionType.Send, true, "--send", "-s", "Send a file via the serial port", 1, 1);
            parser.Add(CommandLineOptionType.PortName, false, "--port", "-p", "Serial port name", 1, 1);
            parser.Add(CommandLineOptionType.BaudRate, false, "--baud", "-b", "Transfer rate (baud)", 1, 1);
            parser.Add(CommandLineOptionType.Parity, false, "--parity", "-pa", "Number of parity bits sent with each package of data", 1, 1);
            parser.Add(CommandLineOptionType.DataBits, false, "--data", "-d", "Number of data bits in each package", 1, 1);
            parser.Add(CommandLineOptionType.StopBits, false, "--stop", "-st", "Number of stop bits in each package", 1, 1);
            parser.Add(CommandLineOptionType.Handshake, false, "--handshake", "-h", "Flow control handshake, one of None, XOnXOff, RequestToSend or RequestToSendXOnXOff", 1, 1);
            parser.Add(CommandLineOptionType.BlockSize, false, "--blocksize", "-bs", "Number of characters to send in each block", 1, 1);
            parser.Add(CommandLineOptionType.BlockDelay, false, "--blockdelay", "-bd", "Delay in milliseconds between sending each block", 1, 1);
            parser.Add(CommandLineOptionType.LineDelay, false, "--linedelay", "-ld", "Delay in milliseconds between sending each line", 1, 1);
            parser.Add(CommandLineOptionType.LineEnding, false, "--lineending", "-le", "Line ending sent at the end of each line (quoted string)", 1, 1);
            parser.Add(CommandLineOptionType.SendNewCommand, false, "--sendnew", "-sn", "Send a NEW command before sending the file", 1, 1);
            parser.Add(CommandLineOptionType.Verbose, false, "--verbose", "-v", "Verbose output", 1, 1);
            parser.Parse(args);

            // Capture the file name to send
            var values = parser.GetValues(CommandLineOptionType.Send);
            if (values != null) FileName = values[0];

            // Apply the command line values over the defaults
            values = parser.GetValues(CommandLineOptionType.PortName);
            if (values != null) Settings.PortName = values[0];

            values = parser.GetValues(CommandLineOptionType.BaudRate);
            if (values != null) Settings.BaudRate = int.Parse(values[0]);

            values = parser.GetValues(CommandLineOptionType.Parity);
            if (values != null) Settings.Parity = (Parity)Enum.Parse(typeof(Parity), values[0]);

            values = parser.GetValues(CommandLineOptionType.DataBits);
            if (values != null) Settings.DataBits = int.Parse(values[0]);

            values = parser.GetValues(CommandLineOptionType.StopBits);
            if (values != null) Settings.StopBits = (StopBits)Enum.Parse(typeof(StopBits), values[0]);

            values = parser.GetValues(CommandLineOptionType.Handshake);
            if (values != null) Settings.Handshake = (Handshake)Enum.Parse(typeof(Handshake), values[0]);

            values = parser.GetValues(CommandLineOptionType.BlockSize);
            if (values != null) Settings.BlockSize = int.Parse(values[0]);

            values = parser.GetValues(CommandLineOptionType.BlockDelay);
            if (values != null) Settings.BlockDelay = int.Parse(values[0]);

            values = parser.GetValues(CommandLineOptionType.LineDelay);
            if (values != null) Settings.LineDelay = int.Parse(values[0]);

            values = parser.GetValues(CommandLineOptionType.LineEnding);
            if (values != null) Settings.LineEnding = values[0];
    
            values = parser.GetValues(CommandLineOptionType.SendNewCommand);
            if (values != null) Settings.SendNewCommand = bool.Parse(values[0]);
            
            values = parser.GetValues(CommandLineOptionType.Verbose);
            if (values != null) Settings.Verbose = bool.Parse(values[0]);
        }
    }
}