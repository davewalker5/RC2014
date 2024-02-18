using SerialSender.Entities.Interfaces;
using System.Diagnostics.CodeAnalysis;
using System.IO.Ports;

namespace SerialSender.Entities.Serial
{
    /// <summary>
    /// Mockable wrapper around the SerialPort class
    /// </summary>
    [ExcludeFromCodeCoverage]
    public class SerialSenderSerialPort : ISerialPort
    {
        private SerialPort _serialPort;

        public SerialSenderSerialPort(ISerialSenderAppSettings settings)
        {
            _serialPort = new()
            {
                PortName = settings.PortName,
                BaudRate = settings.BaudRate,
                Parity = settings.Parity,
                DataBits = settings.DataBits,
                StopBits = settings.StopBits,
                Handshake = settings.Handshake
            };
        }

        /// <summary>
        /// Return true if the port is open
        /// </summary>
        /// <returns></returns>
        public bool IsOpen { get { return _serialPort.IsOpen; } }

        /// <summary>
        /// Open the serial port for communications.
        /// </summary>
        public void Open() => _serialPort.Open();

        /// <summary>
        /// Close the serial connection
        /// </summary>
        public void Close() => _serialPort.Close();

        /// <summary>
        /// Write a string to the serial port
        /// </summary>
        /// <param name="text"></param>
        public void Write(string text) => _serialPort.WriteLine(text);
    }
}
