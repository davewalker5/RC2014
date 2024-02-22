using SerialSender.Entities.Interfaces;
using System.IO;

namespace SerialSender.Logic.Reader
{
    /// <summary>
    /// Wrapper for the File class to allow for mocking in unit tests
    /// </summary>
    public class FileWrapper : IFileWrapper
    {
        public string[] ReadAllLines(string path)
        {
            return File.ReadAllLines(path);
        }
    }
}
