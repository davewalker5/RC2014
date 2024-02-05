using Renumber.Entities.Events;
using System.Collections.Generic;

namespace Renumber.Entities.Interfaces
{
    public interface IRenumberer<T> where T : IProgramLine
    {
        IReadOnlyCollection<T> Lines { get; }
        void Renumber();
        void AssignNewLineNumbers(int startAt, int increment);
        void ReplaceAllJumpStatementTargets();
        string ReplaceJumpStatementTargets(string line, int oldNumber, int newNumber);
    }
}
