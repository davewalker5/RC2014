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
        public void TooFewArgumentsFailsTest()
        {
            string[] args = ["-r"];
            Assert.ThrowsExactly<TooFewValuesException>(() => _parser.Parse(args));
        }

        [TestMethod]
        public void TooManyArgumentsFailsTest()
        {
            string[] args = ["-r", "myprogram.bas", "extra argument"];
            Assert.ThrowsExactly<TooManyValuesException>(() => _parser.Parse(args));
        }

        [TestMethod]
        public void MultipleInstancesAppendValues()
        {
            string[] args = ["-r", "myprogram.bas", "-r", "myotherprogram.bas"];
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
            string[] args = ["myprogram.bas", "--renumber", "myotherprogram.bas"];
            Assert.ThrowsExactly<MalformedCommandLineException>(() => _parser.Parse(args));
        }

        [TestMethod]
        public void DuplicateOptionTypeFailsTest()
        {
            Assert.ThrowsExactly<DuplicateOptionException>(() =>
                _parser.Add(CommandLineOptionType.Renumber, true, "--other-lookup", "-ol", "Duplicate option type", 2, 2));
        }

        [TestMethod]
        public void DuplicateOptionNameFailsTest()
        {
            Assert.ThrowsExactly<DuplicateOptionException>(() =>
                _parser.Add(CommandLineOptionType.Unknown, true, "--renumber", "-unk", "Duplicate option name", 2, 2));
        }

        [TestMethod]
        public void DuplicateOptionShortNameFailsTest()
        {
            Assert.ThrowsExactly<DuplicateOptionException>(() =>
                _parser.Add(CommandLineOptionType.Unknown, true, "--unknown", "-r", "Duplicate option shortname", 2, 2));
        }

        [TestMethod]
        public void MultipleOperationsFailsTest()
        {
            string[] args = ["--renumber", "myprogram.bas", "--inplace", "true" ];
            Assert.ThrowsExactly<MultipleOperationsException>(() => _parser.Parse(args));
        }
    }
}
