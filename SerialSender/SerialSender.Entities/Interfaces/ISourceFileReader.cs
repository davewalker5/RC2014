using SerialSender.Entities.Reader;

namespace SerialSender.Entities.Interfaces
{
    public interface ISourceFileReader
    {
        IList<string> Lines { get; }
        SourceFileType FileType { get; }
        void Read(string path);
    }
}
