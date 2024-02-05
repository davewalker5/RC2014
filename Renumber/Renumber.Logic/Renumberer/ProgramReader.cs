using Renumber.Entities.Renumberer;
using Renumber.Entities.Events;
using Renumber.Entities.Exceptions;
using Renumber.Entities.Interfaces;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Collections.Generic;

namespace Renumber.Logic.Renumberer
{
    public class ProgramReader<T> : IProgramReader<T> where T : IProgramLine, new()
    {
        private List<T> _lines = null;

        public IReadOnlyCollection<T> Lines { get {return _lines.AsReadOnly(); } }

        // Define the event that will be triggered when a line is read
        public event EventHandler<LineReadEventArgs> LineRead;

        /// <summary>
        /// Reads the lines from the specified file, extracts the line number and code
        // and returns a collection of program line objects
        /// </summary>
        /// <param name="path">The path to the file to read</param>
        /// <returns>A collection of ProgramLine objects</returns>
        /// <exception cref="FileNotFoundException">Thrown when the file does not exist</exception>
        /// <exception cref="InvalidLineFormatException">Thrown when the line is not in the expected format</exception>
        /// <exception cref="InvalidLineNumberException">Thrown when the line number is not valid</exception>
        public void ReadLines(string path)
        {
            var rawLines = new List<T>();

            // Read the program lines into the local "raw" collection, parsing each line
            // as it's read into a ProgramLine object
            using (var reader = new StreamReader(path))
            {
                var count = 0;
                while (!reader.EndOfStream)
                {
                    count++;
                    var line = reader.ReadLine().Trim();
                    var programLine = ParseLine(line, count);
                    rawLines.Add(programLine);
                }
            }

            // Now sort the lines by number and assign them to the private field backing
            // the public lines property
            _lines = rawLines.OrderBy(l => l.Number).ToList();
        }

        /// <summary>
        /// Parses the specified line into a ProgramLine object
        /// </summary>
        /// <param name="line">The line to parse</param>
        /// <param name="fileLineNumber">The file line</param>
        /// <returns>A ProgramLine object</returns>
        /// <exception cref="InvalidLineFormatException">Thrown when the line is not in the expected format</exception>
        /// <exception cref="InvalidLineNumberException">Thrown when the line number is not valid</exception>
        public T ParseLine(string line, int fileLineNumber)
        {
            // Break the line into tokens. The expectation is the first token
            // is the line number and the remainder contains the code
            var tokens = line.Split(new[] { ' ', '\t' }, 2);
            if (tokens.Length < 2)
            {
                var message = $"Invalid line at line {fileLineNumber}";
                throw new InvalidLineFormatException(message);
            }

            // Parse the line number out of the first token
            if (!int.TryParse(tokens[0], out var programLineNumber))
            {
                var message = $"Unable to determine line number at line {fileLineNumber}";
                throw new InvalidLineFormatException(message);
            }

            // Line numbers must be +ve
            if (programLineNumber <= 0)
            {
                var message = $"Line number must be positive at line {fileLineNumber}";
                throw new InvalidLineNumberException(message);
            }

            // Create a new ProgramLine object and notify subscribers
            var programLine =  new T
            {
                Number = programLineNumber,
                Text = tokens[1]
            };

            LineRead?.Invoke(this, new LineReadEventArgs(fileLineNumber, programLine.Number, programLine.Text));
            return programLine;
        }
    }
}
