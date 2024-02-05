using Renumber.Entities.Configuration;
using Renumber.Entities.Exceptions;
using Renumber.Entities.Interfaces;
using Renumber.Entities.Renumberer;
using Renumber.Logic.Renumberer;
using System.IO;
using System.Reflection;

namespace Renumber.Tests
{
    [TestClass]
    public class ProgramReaderTest
    {
        private IProgramReader<ProgramLine> _reader;
        private readonly string _assemblyPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);

        [TestInitialize]
        public void Initialise()
        {
            _reader = new ProgramReader<ProgramLine>();
        }

        [TestMethod]
        public void ProgramContainsCorrectNumberOfLinesTest()
        {
            var expected = ReadTestFile().Count;
            var file = Path.Combine(_assemblyPath, "Example.bas");
            _reader.ReadLines(file);
            Assert.AreEqual(expected, _reader.Lines.Count);
        }

        [TestMethod]
        public void ProgramContainsCorrectLineNumberingTest()
        {
            var file = Path.Combine(_assemblyPath, "Example.bas");
            _reader.ReadLines(file);

            var lineNumber = 1;
            foreach (var line in _reader.Lines)
            {
                Assert.AreEqual(lineNumber, line.Number);
                lineNumber++;
            }
        }

        [TestMethod]
        public void ProgramContainsCorrectCodeTest()
        {
            var file = Path.Combine(_assemblyPath, "Example.bas");
            _reader.ReadLines(file);

            var index = 0;
            var expectedLines = ReadTestFile();
            foreach (var line in _reader.Lines)
            {
                var expectedText = expectedLines[line.Number];
                Assert.AreEqual(expectedText, line.Text);
                index++;
            }
        }

        [TestMethod]
        [ExpectedException(typeof(FileNotFoundException))]
        public void MissingFileRaisesExceptionTest()
        {
            _reader.ReadLines("missing.bas");
        }

        [TestMethod]
        [ExpectedException(typeof(InvalidLineFormatException))]
        public void LineWithNoSpacesRaisesExceptionTest()
        {
            _reader.ParseLine("10GOTO100", 1);
        }

        [TestMethod]
        [ExpectedException(typeof(InvalidLineFormatException))]
        public void LineWithLeadingSpacesAndNoNumberRaisesExceptionTest()
        {
            _reader.ParseLine("   GOTO 100", 1);
        }

        [TestMethod]
        [ExpectedException(typeof(InvalidLineFormatException))]
        public void LineWithNoNumberRaisesExceptionTest()
        {
            _reader.ParseLine("GOTO 100", 1);
        }

        [TestMethod]
        [ExpectedException(typeof(InvalidLineNumberException))]
        public void LineWithZeroNumberRaisesExceptionTest()
        {
            _reader.ParseLine("0 GOTO 100", 1);
        }

        [TestMethod]
        [ExpectedException(typeof(InvalidLineNumberException))]
        public void LineWithNegativeNumberRaisesExceptionTest()
        {
            _reader.ParseLine("-1 GOTO 100", 1);
        }

        [TestMethod]
        [ExpectedException(typeof(InvalidLineFormatException))]
        public void LineWithFloatingPointNumberRaisesExceptionTest()
        {
            _reader.ParseLine("10.1 GOTO 100", 1);
        }

        private SortedDictionary<int, string> ReadTestFile()
        {
            var file = Path.Combine(_assemblyPath, "Example.bas");
            var lines = File.ReadAllLines(file);

            var content = new SortedDictionary<int, string>();
            foreach (var line in lines)
            {
                var tokens = line.Split(new[] { ' ', '\t' }, 2);
                var number = int.Parse(tokens[0].Trim());
                content.Add(number, tokens[1].Trim());
            }

            return content;
        }
    }
}
