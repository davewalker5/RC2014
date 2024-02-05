using Renumber.Entities.Events;
using Renumber.Entities.Interfaces;

namespace Renumber.Logic.Renumberer
{
    public class Renumberer<T> : IRenumberer<T> where T : IProgramLine
    {
        private readonly IRenumberAppSettings _settings;
        private readonly IEnumerable<T> _lines;
        private readonly List<string> _jumpCommands = new List<string> { "GOTO", "GOSUB", "goto", "gosub" };

        public IReadOnlyCollection<T> Lines { get {return _lines.OrderBy(l => l.NewNumber).ToList().AsReadOnly(); } }

        // Define the event that will be triggered when a line is renumbered
        public event EventHandler<LineRenumberedEventArgs> LineRenumbered;

        public Renumberer(IRenumberAppSettings settings, IEnumerable<T> lines)
        {
            _settings = settings;
            _lines = lines;
        }

        /// <summary>
        /// Renumber the collection of lines currently in state
        /// </summary>
        /// <param name="lines"></param>
        /// <returns></returns>
        public void Renumber()
        {  
            // Perform the renumbering operations
            AssignNewLineNumbers(_settings.StartAt, _settings.IncrementBy);
            ReplaceAllJumpStatementTargets();

            // Raise the events to subscribers
            var count = 0;
            foreach (var line in _lines)
            {
                count++;
                LineRenumbered?.Invoke(this, new LineRenumberedEventArgs(count, line.Number, line.NewNumber, line.Text));
            }
        }

        /// <summary>
        /// Assign new line numbers to the collection of lines currently in state
        /// </summary>
        /// <param name="lines">The collection of lines to renumber</param>
        /// <param name="startAt">The line number to start at</param>
        /// <param name="increment">The increment to use</param>
        public void AssignNewLineNumbers(int startAt, int increment)
        {
            var currentLineNumber = startAt;
            foreach (var line in _lines)
            {
                line.NewNumber = currentLineNumber;
                currentLineNumber += increment;
            }
        }

        /// <summary>
        /// Replace all jump statement targets in the collection of lines currently in state
        /// </summary>
        public void ReplaceAllJumpStatementTargets()
        {
            // This has to be done in *descending* order of the old line number to ensure
            // cases where one line number is a substring of a larger line number
            // e.g. 10 and 100
            foreach (var targetLine in _lines.OrderByDescending(l => l.Number))
            {
                foreach (var line in _lines)
                {
                    line.Text = ReplaceJumpStatementTargets(line.Text, targetLine.Number, targetLine.NewNumber);
                }
            }
        }

        /// <summary>
        /// If the specified line contains a jump statement, replace the old line number
        /// </summary>
        /// <param name="line">The line to replace the line number in</param>
        /// <param name="oldNumber">The old line number</param>
        /// <param name="newNumber">The new line number</param>
        public string ReplaceJumpStatementTargets(string line, int oldNumber, int newNumber)
        {
            foreach (var command in _jumpCommands)
            {
                var pattern = $"{command} {oldNumber}";
                var replacement = $"{command} {newNumber}";
                line = line.Replace(pattern, replacement);
            }

            return line;
        }
    }
}
