using Renumber.Entities.Configuration;
using Renumber.Entities.Interfaces;
using Renumber.Entities.Renumberer;
using Renumber.Logic.Renumberer;
using System.IO;
using System.Reflection;

namespace Renumber.Tests
{
    [TestClass]
    public class ProgramWriterTest
    {
        private IRenumberer<ProgramLine> _renumberer;
        private readonly string _assemblyPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);

        [TestInitialize]
        public void Initialise()
        {
            // Load the example program
            var file = Path.Combine(_assemblyPath, "Example.bas");
            IProgramReader<ProgramLine> reader = new ProgramReader<ProgramLine>();
            reader.ReadLines(file);
            
            // Construct some application settings for renumbering
            var settings = new RenumberAppSettings
            {
                StartAt = 10,
                IncrementBy = 10
            };
    
            // Renumber the test program
            _renumberer = new Renumberer<ProgramLine>(settings, reader.Lines);
            _renumberer.Renumber();
        }

        [TestMethod]
        public void RewrittenProgramHasCorrectContent()
        {
            // Write the previously renumbered file to a temporary file
            var file = Path.GetTempFileName();
            var settings = new RenumberAppSettings { InPlace = false };
            var writer = new ProgramWriter<ProgramLine>(settings);
            writer.WriteLines(_renumberer.Lines, file);

            // Read it
            var reader = new ProgramReader<ProgramLine>();
            reader.ReadLines(file);

            // Check the line count is correct
            Assert.AreEqual(_renumberer.Lines.Count, reader.Lines.Count);

            // Convert the expected and actual line numbers to lists so we can use indexing
            // during the comparison
            var expectedLineNumbers = _renumberer.Lines.ToList();
            var actualLineNumbers = reader.Lines.ToList();

            // Check the line numbers and code
            for (int i = 0; i < reader.Lines.Count; i++)
            {
                Assert.AreEqual(expectedLineNumbers[i].NewNumber, actualLineNumbers[i].Number);
                Assert.AreEqual(expectedLineNumbers[i].Text, actualLineNumbers[i].Text);
            }

            File.Delete(file);
        }

        [TestMethod]
        public void RewriteInPlaceDoesNotGenerateABackupFile()
        {
            var source = Path.Combine(_assemblyPath, "Example.bas");
            var file = Path.GetTempFileName();

            var settings = new RenumberAppSettings { InPlace = true };
            var writer = new ProgramWriter<ProgramLine>(settings);
            writer.WriteLines(_renumberer.Lines, file);

            Assert.IsTrue(File.Exists(file));
            Assert.IsFalse(File.Exists($"{file}.bak"));

            File.Delete(file);
        }

        [TestMethod]
        public void RewriteNotInPlaceGeneratesABackupFile()
        {
            var source = Path.Combine(_assemblyPath, "Example.bas");
            var file = Path.GetTempFileName();

            var settings = new RenumberAppSettings { InPlace = false };
            var writer = new ProgramWriter<ProgramLine>(settings);
            writer.WriteLines(_renumberer.Lines, file);

            Assert.IsTrue(File.Exists(file));
            Assert.IsTrue(File.Exists($"{file}.bak"));

            File.Delete(file);
            File.Delete($"{file}.bak");
        }
    }
}
