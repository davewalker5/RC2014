using Renumber.Entities.Events;
using System.Collections.Generic;

namespace Renumber.Entities.Interfaces
{
    public interface IProgramReader<T> where T : IProgramLine, new()
    {
        event EventHandler<LineReadEventArgs> LineRead;
        IReadOnlyCollection<T> Lines { get; }
        void ReadLines(string path);
        T ParseLine(string line, int fileLineNumber);
    }
}
