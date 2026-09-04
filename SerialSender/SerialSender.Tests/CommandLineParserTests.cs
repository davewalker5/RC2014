using SerialSender.Entities.Configuration;
using SerialSender.Entities.Exceptions;
using SerialSender.Logic.Configuration;

namespace SerialSender.Tests
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
        public void TooFewArgumentsFailsTest()
        {
            string[] args = ["-s"];
            Assert.ThrowsExactly<TooFewValuesException>(() => _parser.Parse(args));
        }

        [TestMethod]
        public void TooManyArgumentsFailsTest()
        {
            string[] args = ["-s", "myprogram.bas", "extra argument"];
            Assert.ThrowsExactly<TooManyValuesException>(() => _parser.Parse(args));
        }

        [TestMethod]
        public void MultipleInstancesAppendValues()
        {
            string[] args = ["-s", "myprogram.bas", "-s", "myotherprogram.bas"];
            Assert.ThrowsExactly<TooManyValuesException>(() => _parser.Parse(args));
        }

        [TestMethod]
        public void UnrecognisedOptionNameFailsTest()
        {
            string[] args = ["--oops", "myprogram.bas"];
            Assert.ThrowsExactly<UnrecognisedCommandLineOptionException>(() => _parser.Parse(args));
        }

        [TestMethod]
        public void UnrecognisedOptionShortNameFailsTest()
        {
            string[] args = ["-o", "myprogram.bas"];
            Assert.ThrowsExactly<UnrecognisedCommandLineOptionException>(() => _parser.Parse(args));
        }

        [TestMethod]
        public void MalformedCommandLineFailsTest()
        {
            string[] args = ["myprogram.bas", "--send", "myotherprogram.bas"];
            Assert.ThrowsExactly<MalformedCommandLineException>(() => _parser.Parse(args));
        }

        [TestMethod]
        public void DuplicateOptionTypeFailsTest()
        {
            Assert.ThrowsExactly<DuplicateOptionException>(() =>
                _parser.Add(CommandLineOptionType.Send, true, "--other-lookup", "-ol", "Duplicate option type", 2, 2));
        }

        [TestMethod]
        public void DuplicateOptionNameFailsTest()
        {
            Assert.ThrowsExactly<DuplicateOptionException>(() =>
                _parser.Add(CommandLineOptionType.Unknown, true, "--send", "-unk", "Duplicate option name", 2, 2));
        }

        [TestMethod]
        public void DuplicateOptionShortNameFailsTest()
        {
            Assert.ThrowsExactly<DuplicateOptionException>(() =>
                _parser.Add(CommandLineOptionType.Unknown, true, "--unknown", "-s", "Duplicate option shortname", 2, 2));
        }

        [TestMethod]
        public void MultipleOperationsFailsTest()
        {
            string[] args = ["--send", "myprogram.bas", "--port", "COM3" ];
            Assert.ThrowsExactly<MultipleOperationsException>(() => _parser.Parse(args));
        }
    }
}
