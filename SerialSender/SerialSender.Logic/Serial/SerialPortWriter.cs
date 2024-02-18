using SerialSender.Entities.Events;
using SerialSender.Entities.Interfaces;
using System.IO.Ports;

namespace SerialSender.Logic
{
    /// <summary>
    /// Class for writing to a serial port.
    /// </summary>
    public class SerialPortWriter : ISerialPortWriter
    {
        private readonly ISerialPort _serialPort;
        private readonly ISerialSenderAppSettings _settings;

        // Define the event that will be triggered when a string is written
        public event EventHandler<StringWrittenEventArgs> StringWritten;

        /// <summary>
        /// Initializes a new instance of the SerialPortWriter class.
        /// </summary>
        /// <param name="port">The port instance to use to write data</param>
        /// <param name="settings">The current application settings</param>
        public SerialPortWriter(ISerialPort port, ISerialSenderAppSettings settings)
        {
            _serialPort = port;
            _settings = settings;
        }

        /// <summary>
        /// Opens the serial port for communications.
        /// </summary>
        public void Open()
        {
            if (!_serialPort.IsOpen)
            {
                _serialPort.Open();
            }
        }

        /// <summary>
        /// Closes the serial port.
        /// </summary>
        public void Close()
        {
            if (_serialPort.IsOpen)
            {
                _serialPort.Close();
            }
        }

        /// <summary>
        /// Writes a collection of strings to the serial port.
        /// </summary>
        /// <param name="strings">Strings to write</param>
        public void WriteStrings(IEnumerable<string> strings)
        {
            var count = 0;
            var charCount = 0;

            // If required, send the NEW command first
            var stringsToWrite = _settings.SendNewCommand ? strings.Prepend("NEW") : strings;

            foreach (var str in stringsToWrite)
            {
                foreach (var character in str)
                {
                    // Write the next character
                    _serialPort.Write(character.ToString());

                    charCount++;
                    if ((_settings.BlockDelay > 0) && (charCount % _settings.BlockSize == 0))
                    {
                        // Wait for the specified delay to avoid swamping the receiver
                        Thread.Sleep(_settings.BlockDelay);
                    }
                }

                // Write the line ending after each string
                _serialPort.Write(_settings.LineEnding);
                if (_settings.LineDelay > 0)
                {
                    Thread.Sleep(_settings.LineDelay);
                }

                count++;

                // Trigger the event notifying subscribers
                OnStringWritten(new StringWrittenEventArgs(count, str));
            }
        }

        /// <summary>
        /// Write all lines in the specified file to the serial port.
        /// </summary>
        /// <param name="path"></param>
        public void WriteFile(string path)
        {
            var lines = File.ReadAllLines(path);
            WriteStrings(lines);
        }   

        /// <summary>
        /// Invoke the event handler method to notify subscribers that the next
        /// string has been written
        /// </summary>
        /// <param name="e"></param>
        protected virtual void OnStringWritten(StringWrittenEventArgs e)
        {
            StringWritten?.Invoke(this, e);
        }
    }
}