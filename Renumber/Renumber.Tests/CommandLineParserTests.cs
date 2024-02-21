using Renumber.Entities.Configuration;
using Renumber.Entities.Exceptions;
using Renumber.Logic.Configuration;

namespace Renumber.Tests.Tests
{
    [TestClass]
    public class CommandLineParserTest
    {
        private CommandLineParser _parser;

        [TestInitialize]
        public void TestInitialise()
        {
            _parser = new CommandLineParser();
            _parser.Add(CommandLineOptionType.Renumber, true, "--renumber", "-r", "Path to the file to renumber", 1, 1);
            _parser.Add(CommandLineOptionType.InPlace, true, "--inplace", "-i", "Option misconfigured as an operation for testing purposes", 1, 1);
        }

        [TestMethod]
        public void ValidUsingNamesTest()
        {
            string[] args = ["--renumber", "myprogram.bas"];
            _parser.Parse(args);

            var values = _parser.GetValues(CommandLineOptionType.Renumber);
            Assert.IsNotNull(values);
            Assert.AreEqual(1, values.Count);
            Assert.AreEqual("myprogram.bas", values[0]);
        }

        [TestMethod]
        public void ValidUsingShortNamesTest()
        {
            string[] args = ["-r", "myprogram.bas"];
            _parser.Parse(args);

            var values = _parser.GetValues(CommandLineOptionType.Renumber);
            Assert.IsNotNull(values);
            Assert.AreEqual(1, values.Count);
            Assert.AreEqual("myprogram.bas", values[0]);
        }

        [TestMethod]
        [ExpectedException(typeof(TooFewValuesException))]
        public void TooFewArgumentsFailsTest()
        {
            string[] args = ["-r"];
            _parser.Parse(args);
        }

        [TestMethod]
        [ExpectedException(typeof(TooManyValuesException))]
        public void TooManyArgumentsFailsTest()
        {
            string[] args = ["-r", "myprogram.bas", "extra argument"];
            _parser.Parse(args);
        }

        [TestMethod]
        [ExpectedException(typeof(TooManyValuesException))]
        public void MultipleInstancesAppendValues()
        {
            string[] args = ["-r", "myprogram.bas", "-r", "myotherprogram.bas"];
            _parser.Parse(args);
        }

        [TestMethod]
        [ExpectedException(typeof(UnrecognisedCommandLineOptionException))]
        public void UnrecognisedOptionNameFailsTest()
        {
            string[] args = ["--oops", "myprogram.bas"];
            _parser.Parse(args);
        }

        [TestMethod]
        [ExpectedException(typeof(UnrecognisedCommandLineOptionException))]
        public void UnrecognisedOptionShortNameFailsTest()
        {
            string[] args = ["-o", "myprogram.bas"];
            _parser.Parse(args);
        }

        [TestMethod]
        [ExpectedException(typeof(MalformedCommandLineException))]
        public void MalformedCommandLineFailsTest()
        {
            string[] args = ["myprogram.bas", "--renumber", "myotherprogram.bas"];
            _parser.Parse(args);
        }

        [TestMethod]
        [ExpectedException(typeof(DuplicateOptionException))]
        public void DuplicateOptionTypeFailsTest()
        {
            _parser.Add(CommandLineOptionType.Renumber, true, "--other-lookup", "-ol", "Duplicate option type", 2, 2);
        }

        [TestMethod]
        [ExpectedException(typeof(DuplicateOptionException))]
        public void DuplicateOptionNameFailsTest()
        {
            _parser.Add(CommandLineOptionType.Unknown, true, "--renumber", "-unk", "Duplicate option name", 2, 2);
        }

        [TestMethod]
        [ExpectedException(typeof(DuplicateOptionException))]
        public void DuplicateOptionShortNameFailsTest()
        {
            _parser.Add(CommandLineOptionType.Unknown, true, "--unknown", "-r", "Duplicate option shortname", 2, 2);
        }

        [TestMethod]
        [ExpectedException(typeof(MultipleOperationsException))]
        public void MultipleOperationsFailsTest()
        {
            string[] args = ["--renumber", "myprogram.bas", "--inplace", "true" ];
            _parser.Parse(args);
        }
    }
}
