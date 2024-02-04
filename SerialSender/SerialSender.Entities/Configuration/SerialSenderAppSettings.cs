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
        public int Delay { get; set; }
        public string LineEnding { get; set; }
        public bool SendNewCommand { get; set; }
        public bool Verbose { get; set; }
    }
}
