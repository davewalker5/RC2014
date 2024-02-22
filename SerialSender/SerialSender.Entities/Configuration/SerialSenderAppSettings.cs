using SerialSender.Entities.Interfaces;
using System.Diagnostics.CodeAnalysis;
using System.IO.Ports;

namespace SerialSender.Entities.Configuration
{
    [ExcludeFromCodeCoverage]
    public class SerialSenderAppSettings : ISerialSenderAppSettings
    {
        public string PortName { get; set; }
        public int BaudRate { get; set; }
        public Parity Parity { get; set; }
        public int DataBits { get; set; }
        public StopBits StopBits { get; set; }
        public int BlockSize { get; set; }
        public int BlockDelay { get; set; }
        public int LineDelay { get; set; }
        public string LineEnding { get; set; }
        public bool SendResetCommand { get; set; }
        public bool Verbose { get; set; }
        public Handshake Handshake { get; set; }
    }
}
