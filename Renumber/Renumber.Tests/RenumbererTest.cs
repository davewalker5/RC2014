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
    public class RenumbererTest
    {
        private readonly string _assemblyPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);

        [TestMethod]
        public void ProgramContainsCorrectLineNumberingTest()
        {
            var file = Path.Combine(_assemblyPath, "Example.bas");
            var reader = new ProgramReader<ProgramLine>();
            reader.ReadLines(file);

            var renumberer = CreateRenumberer(reader.Lines);
            renumberer.Renumber();

            var lineNumber = 10;
            foreach (var line in renumberer.Lines)
            {
                Assert.AreEqual(lineNumber, line.NewNumber);
                lineNumber += 10;
            }
        }

        [TestMethod]
        public void RenumberLowercaseTest()
        {
            var renumberer = CreateRenumberer(null);
            var renumbered = renumberer.ReplaceJumpStatementTargets("goto 10 : REM Jump", 10, 20);
            Assert.AreEqual("goto 20 : REM Jump", renumbered);
        }

        [TestMethod]
        public void RenumberGotoAtStartOfLineTest()
        {
            var renumberer = CreateRenumberer(null);
            var renumbered = renumberer.ReplaceJumpStatementTargets("GOTO 10 : REM Jump", 10, 20);
            Assert.AreEqual("GOTO 20 : REM Jump", renumbered);
        }

        [TestMethod]
        public void RenumberGotoAtEndOfLineTest()
        {
            var renumberer = CreateRenumberer(null);
            var renumbered = renumberer.ReplaceJumpStatementTargets("X = 10 : GOTO 10", 10, 20);
            Assert.AreEqual("X = 10 : GOTO 20", renumbered);
        }

        [TestMethod]
        public void RenumberGosubAtStartOfLineTest()
        {
            var renumberer = CreateRenumberer(null);
            var renumbered = renumberer.ReplaceJumpStatementTargets("GOSUB 123 : REM Jump", 123, 200);
            Assert.AreEqual("GOSUB 200 : REM Jump", renumbered);
        }

        [TestMethod]
        public void RenumberGosubAtEndOfLineTest()
        {
            var renumberer = CreateRenumberer(null);
            var renumbered = renumberer.ReplaceJumpStatementTargets("X = 10 : GOSUB 123", 123, 200);
            Assert.AreEqual("X = 10 : GOSUB 200", renumbered);
        }

        private IRenumberer<ProgramLine> CreateRenumberer(IEnumerable<ProgramLine> lines)
        {
            var settings = new RenumberAppSettings
            {
                InPlace = false,
                StartAt = 10,
                IncrementBy = 10
            };

            return new Renumberer<ProgramLine>(settings, lines);
        }
    }
}