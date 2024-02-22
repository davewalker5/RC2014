using SerialSender.Entities.Interfaces;
using SerialSender.Entities.Reader;

namespace SerialSender.Logic.Reader
{
    public class SourceFileReader : ISourceFileReader
    {
        private readonly IFileWrapper _fileWrapper;

        public IList<string> Lines { get; private set; } = new List<string>();
        public SourceFileType FileType { get; private set; }

        public SourceFileReader(IFileWrapper fileWrapper)
        {
            _fileWrapper = fileWrapper;
        }

        /// <summary>
        /// Read the source file and identify its type
        /// </summary>
        /// <param name="path">The path to the file to read</param>
        public void Read(string path)
        {
            // Read the file content then iterate through them and replace the ESCAPE
            // placeholder with an escape character to build the final collection
            var rawLines = _fileWrapper.ReadAllLines(path);
            foreach (var line in rawLines)
            {
                Lines.Add(line.Replace("<ESC>", "\x1B"));
            }

            // Get the extension of the file and use it to determine the file type
            var extension = Path.GetExtension(path).ToLower();
            FileType = extension switch
            {
                ".bas" => SourceFileType.Basic,
                ".asm" => SourceFileType.Assembly,
                _ => SourceFileType.Unknown
            };
        }
    }
}