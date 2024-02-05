using System.Diagnostics.CodeAnalysis;

namespace Renumber.Entities.Events
{
    [ExcludeFromCodeCoverage]
    public class LineReadEventArgs : EventArgs
    {
        public int Count { get; private set; }
        public int Number { get; private set; }
        public string Text { get; private set; }

        public LineReadEventArgs(int count, int number, string text)
        {
            Count = count;
            Number = number;
            Text = text;
        }
    }
}
