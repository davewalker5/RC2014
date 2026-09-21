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

            var listing = generator.Generate([new Allophone("HH1", 27), new Allophone("EH", 7)]);

            StringAssert.Contains(listing, "20 FOR I=1 TO 2");
            StringAssert.Contains(listing, "40 IF (INP(31) AND 2)=0 THEN GOTO 40");
            StringAssert.Contains(listing, "50 OUT 31,A");
            StringAssert.Contains(listing, "80 REM HH1 EH");
            StringAssert.Contains(listing, "90 DATA 27,7");
        }
    }
}
