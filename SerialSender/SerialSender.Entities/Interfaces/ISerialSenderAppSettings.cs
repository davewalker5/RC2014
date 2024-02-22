using System.IO.Ports;

namespace SerialSender.Entities.Interfaces
{
    public interface ISerialSenderAppSettings
    {
        int BaudRate { get; set; }
        int DataBits { get; set; }
        int BlockSize { get; set; }
        int BlockDelay { get; set; }
        int LineDelay { get; set; }
        Parity Parity { get; set; }
        string PortName { get; set; }
        StopBits StopBits { get; set; }
        string LineEnding { get; set; }
        bool SendResetCommand { get; set; }
        bool Verbose { get; set; }
        Handshake Handshake { get; set; }
    }
}