using MIDIConverter.Entities.Configuration;
using MIDIConverter.Entities.Conversion;
using MIDIConverter.Logic.Basic;

namespace MIDIConverter.Tests
{
    [TestClass]
    public sealed class BasicProgramGeneratorTests
    {
        [TestMethod]
        public void GenerateIncludesPlayerDataSentinelAndMute()
        {
            var program = new BasicProgramGenerator().Generate(
                "test.mid",
                [new PlaybackStep
                {
                    DurationMilliseconds = 500,
                    Frequency1 = 7382,
                    ActiveMask = 1,
                    RetriggerMask = 1
                }],
                new MIDIConverterAppSettings());

            StringAssert.Contains(program, "DATA 500,7382,0,0,1,1");
            StringAssert.Contains(program, "DATA 0,0,0,0,0,0");
            StringAssert.Contains(program, "OUT RP,24:OUT DP,0");
            StringAssert.Contains(program, "70 RP=212:DP=213:REM SET SID REGISTER AND DATA PORTS");
            StringAssert.Contains(program, "260 PRINT \"PLAYBACK COMPLETE\":END:REM FINISH");
            Assert.IsFalse(program.Contains("@LOOP@", StringComparison.Ordinal));
        }
    }
}
