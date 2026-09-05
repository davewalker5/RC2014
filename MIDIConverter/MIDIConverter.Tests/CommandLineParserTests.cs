using MIDIConverter.Entities.Configuration;
using MIDIConverter.Entities.Exceptions;
using MIDIConverter.Logic.Configuration;

namespace MIDIConverter.Tests
{
    [TestClass]
    public sealed class CommandLineParserTests
    {
        [TestMethod]
        public void ParseMatchesOptionsCaseInsensitively()
        {
            var parser = new CommandLineParser();
            parser.Add(CommandLineOptionType.Convert, true, "--convert", "-c", "Convert", 1, 1);

            parser.Parse(["--CONVERT", "music.mid"]);

            Assert.AreEqual("music.mid", parser.GetValues(CommandLineOptionType.Convert)![0]);
        }

        [TestMethod]
        public void ParseRejectsDuplicateOptionOccurrence()
        {
            var parser = new CommandLineParser();
            parser.Add(CommandLineOptionType.Convert, true, "--convert", "-c", "Convert", 1, 1);

            Assert.Throws<DuplicateOptionException>(() =>
                parser.Parse(["--convert", "one.mid", "-c", "two.mid"]));
        }
    }
}
