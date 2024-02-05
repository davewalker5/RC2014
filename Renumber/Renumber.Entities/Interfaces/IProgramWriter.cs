using System.Collections.Generic;

namespace Renumber.Entities.Interfaces
{
    public interface IProgramWriter<T> where T : IProgramLine, new()
    {
        void WriteLines(IEnumerable<T> lines, string path);
    }
}
