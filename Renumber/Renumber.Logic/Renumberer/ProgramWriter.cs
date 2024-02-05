using Renumber.Entities.Events;
using Renumber.Entities.Interfaces;

namespace Renumber.Logic.Renumberer
{
    public class ProgramWriter<T> : IProgramWriter<T> where T : IProgramLine, new()
    {
        private readonly IRenumberAppSettings _settings;

        // Define the event that will be triggered when a line is written
        public event EventHandler<LineWrittenEventArgs> LineWritten;

        public ProgramWriter(IRenumberAppSettings settings)
        {
            _settings = settings;
        }

        /// <summary>
        /// Write the specified lines to the specified file
        /// </summary>
        /// <param name="path">The path to the file to write</param>
        /// <param name="lines">The lines to write</param>
        public void WriteLines(IEnumerable<T> lines, string path)
        {
            // If the file exists, back it up, first, if required
            if (File.Exists(path) && !_settings.InPlace)
            {
                var backupPath = $"{path}.bak";
                File.Copy(path, backupPath, true);
            }

            // Write the updated file content
            using (var writer = new StreamWriter(path))
            {
                int count = 0;
                foreach (var line in lines)
                {
                    count++;
                    writer.WriteLine($"{line.NewNumber} {line.Text}");
                    LineWritten?.Invoke(this, new LineWrittenEventArgs(count, line.NewNumber, line.Text));
                }
            }
        }
    }
}