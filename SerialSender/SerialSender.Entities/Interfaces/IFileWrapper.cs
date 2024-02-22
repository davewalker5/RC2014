namespace SerialSender.Entities.Interfaces
{
    public interface IFileWrapper
    {
        string[] ReadAllLines(string path);
    }
}