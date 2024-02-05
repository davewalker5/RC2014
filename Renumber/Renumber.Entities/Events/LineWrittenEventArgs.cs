using System.Diagnostics.CodeAnalysis;

namespace Renumber.Entities.Events
{
    [ExcludeFromCodeCoverage]
    public class LineWrittenEventArgs : EventArgs
    {
        public int Count { get; private set; }
        public int Number { get; private set; }
        public string Text { get; private set; }

        public LineWrittenEventArgs(int count, int number, string text)
        {
            Count = count;
            Number = number;
            Text = text;
        }
    }
}
