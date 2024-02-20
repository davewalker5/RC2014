using SerialSender.Entities.Configuration;
using SerialSender.Entities.Exceptions;
using SerialSender.Logic.Configuration;

namespace MusicCatalogue.Tests
{
    [TestClass]
    public class CommandLineParserTest
    {
        private CommandLineParser _parser;

        [TestInitialize]
        public void TestInitialise()
        {
            _parser = new CommandLineParser();
            _parser.Add(CommandLineOptionType.Send, true, "--send", "-s", "Send a file to the serial port", 1, 1);
            _parser.Add(CommandLineOptionType.PortName, true, "--port", "-p", "Option misconfigured as an operation for testing purposes", 1, 1);
        }

        [TestMethod]
        public void ValidUsingNamesTest()
        {
            string[] args = ["--send", "myprogram.bas"];
            _parser.Parse(args);

            var values = _parser.GetValues(CommandLineOptionType.Send);
            Assert.IsNotNull(values);
            Assert.AreEqual(1, values.Count);
            Assert.AreEqual("myprogram.bas", values[0]);
        }

        [TestMethod]
        public void ValidUsingShortNamesTest()
        {
            string[] args = ["-s", "myprogram.bas"];
            _parser.Parse(args);

            var values = _parser.GetValues(CommandLineOptionType.Send);
            Assert.IsNotNull(values);
            Assert.AreEqual(1, values.Count);
            Assert.AreEqual("myprogram.bas", values[0]);
        }

        [TestMethod]
        [ExpectedException(typeof(TooFewValuesException))]
        public void TooFewArgumentsFailsTest()
        {
            string[] args = ["-s"];
            _parser.Parse(args);
        }

        [TestMethod]
        [ExpectedException(typeof(TooManyValuesException))]
        public void TooManyArgumentsFailsTest()
        {
            string[] args = ["-s", "myprogram.bas", "extra argument"];
            _parser.Parse(args);
        }

        [TestMethod]
        [ExpectedException(typeof(TooManyValuesException))]
        public void MultipleInstancesAppendValues()
        {
            string[] args = ["-s", "myprogram.bas", "-s", "myotherprogram.bas"];
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
            string[] args = ["myprogram.bas", "--send", "myotherprogram.bas"];
            _parser.Parse(args);
        }

        [TestMethod]
        [ExpectedException(typeof(DuplicateOptionException))]
        public void DuplicateOptionTypeFailsTest()
        {
            _parser.Add(CommandLineOptionType.Send, true, "--other-lookup", "-ol", "Duplicate option type", 2, 2);
        }

        [TestMethod]
        [ExpectedException(typeof(DuplicateOptionException))]
        public void DuplicateOptionNameFailsTest()
        {
            _parser.Add(CommandLineOptionType.Unknown, true, "--send", "-unk", "Duplicate option name", 2, 2);
        }

        [TestMethod]
        [ExpectedException(typeof(DuplicateOptionException))]
        public void DuplicateOptionShortNameFailsTest()
        {
            _parser.Add(CommandLineOptionType.Unknown, true, "--unknown", "-s", "Duplicate option shortname", 2, 2);
        }

        [TestMethod]
        [ExpectedException(typeof(MultipleOperationsException))]
        public void MultipleOperationsFailsTest()
        {
            string[] args = ["--send", "myprogram.bas", "--port", "COM3" ];
            _parser.Parse(args);
        }
    }
}
