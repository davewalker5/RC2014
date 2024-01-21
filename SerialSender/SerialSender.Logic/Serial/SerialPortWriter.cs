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
        /// <param name="portName">The name of the serial port.</param>
        /// <param name="baudRate">The baud rate at which the communications device operates.</param>
        /// <param name="parity">One of the Parity values.</param>
        /// <param name="dataBits">The data bits value.</param>
        /// <param name="stopBits">One of the StopBits values.</param>
        /// <param name="delay">The delay between writes to the serial port.</param>
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

            foreach (var str in strings)
            {
                // Write the next string
                _serialPort.WriteLine($"{str}{_settings.LineEnding}");
                count++;

                // Trigger the event notifying subscribers
                OnStringWritten(new StringWrittenEventArgs(count, str));

                // Wait for the specified delay to avoid swamping the receiver  
                if (_settings.Delay > 0)
                {
                    Thread.Sleep(_settings.Delay);
                }
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