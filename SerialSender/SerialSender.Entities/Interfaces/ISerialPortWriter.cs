using SerialSender.Entities.Events;

namespace SerialSender.Entities.Interfaces
{
    public interface ISerialPortWriter
    {
        event EventHandler<StringWrittenEventArgs> StringWritten;
        void Close();
        void Open();
        void WriteStrings(IEnumerable<string> strings);
        void WriteFile(string path);
    }
}