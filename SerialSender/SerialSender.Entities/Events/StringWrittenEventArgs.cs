using System.Diagnostics.CodeAnalysis;

namespace SerialSender.Entities.Events
{
    [ExcludeFromCodeCoverage]
    public class StringWrittenEventArgs : EventArgs
    {
        public int Count { get; private set; }
        public string Data { get; private set; }

        public StringWrittenEventArgs(int count, string data)
        {
            Count = count;
            Data = data;
        }
    }
}
