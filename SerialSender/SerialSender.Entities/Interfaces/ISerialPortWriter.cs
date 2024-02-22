using SerialSender.Entities.Events;
using SerialSender.Entities.Reader;

namespace SerialSender.Entities.Interfaces
{
    public interface ISerialPortWriter
    {
        event EventHandler<StringWrittenEventArgs> StringWritten;
        void Close();
        void Open();
        void WriteStrings(IEnumerable<string> strings, SourceFileType fileType);
    }
}