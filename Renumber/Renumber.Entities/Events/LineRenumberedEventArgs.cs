using System.Diagnostics.CodeAnalysis;

namespace Renumber.Entities.Events
{
    [ExcludeFromCodeCoverage]
    public class LineRenumberedEventArgs : EventArgs
    {
        public int Count { get; private set; }
        public int OriginalNumber { get; private set; }
        public int NewNumber { get; private set; }
        public string Text { get; private set; }

        public LineRenumberedEventArgs(int count, int originalNumber, int newNumber, string text)
        {
            Count = count;
            OriginalNumber = originalNumber;
            NewNumber = newNumber;
            Text = text;
        }
    }
}
