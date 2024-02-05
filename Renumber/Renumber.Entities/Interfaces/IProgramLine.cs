namespace Renumber.Entities.Interfaces
{
    public interface IProgramLine
    {
        int Number { get; set; }
        int NewNumber { get; set; }
        string Text { get; set; }
    }
}