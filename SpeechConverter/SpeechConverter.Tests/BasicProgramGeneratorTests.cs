using SpeechConverter.Entities;
using SpeechConverter.Logic.Basic;

namespace SpeechConverter.Tests
{
    /// <summary>
    /// Checks the generated RC2014 BASIC player.
    /// </summary>
    [TestClass]
    public sealed class BasicProgramGeneratorTests
    {
        /// <summary>
        /// Includes annotated DATA and the ready-bit handshake.
        /// </summary>
        [TestMethod]
        public void GeneratesAnnotatedPlayableListing()
        {
            var generator = new BasicProgramGenerator();

            var listing = generator.Generate([new Allophone("HH1", 27), new Allophone("EH", 7)], "Hello");

            StringAssert.Contains(listing, "20 FOR I=1 TO 2");
            StringAssert.Contains(listing, "40 IF (INP(31) AND 2)=0 THEN GOTO 40");
            StringAssert.Contains(listing, "50 OUT 31,A");
            StringAssert.Contains(listing, "80 REM PHRASE: Hello");
            StringAssert.Contains(listing, "90 REM HH1 EH");
            StringAssert.Contains(listing, "100 DATA 27,7");
        }

        [TestMethod]
        public void LongPhraseUsesMultipleRemLinesBeforeAllophones()
        {
            var phrase = new string('A', 205);
            var listing = new BasicProgramGenerator().Generate([new Allophone("AY", 6)], phrase);
            var lines = listing.Split('\n', StringSplitOptions.RemoveEmptyEntries);

            Assert.AreEqual($"80 REM PHRASE: {new string('A', 100)}", lines[7]);
            Assert.AreEqual($"90 REM PHRASE: {new string('A', 100)}", lines[8]);
            Assert.AreEqual("100 REM PHRASE: AAAAA", lines[9]);
            Assert.AreEqual("110 REM AY", lines[10]);
            Assert.AreEqual("120 DATA 6", lines[11]);
            Assert.IsTrue(lines.All(line => line.Length <= 120));
        }
    }
}
