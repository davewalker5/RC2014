using Renumber.Entities.Interfaces;

namespace Renumber.Entities.Renumberer
{
    public class ProgramLine : IProgramLine
    {
        public int Number { get; set; }
        public int NewNumber { get; set; }
        public string Text { get; set; }
    }
}
