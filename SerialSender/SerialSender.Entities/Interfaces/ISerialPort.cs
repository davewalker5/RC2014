namespace SerialSender.Entities.Interfaces
{
    public interface ISerialPort
    {
        bool IsOpen { get; }
        void Open();
        void Close();
        void Write(string text);
    }
}
