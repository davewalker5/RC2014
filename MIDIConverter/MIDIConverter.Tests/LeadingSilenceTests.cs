using MIDIConverter.Entities.Configuration;
using MIDIConverter.Entities.MIDI;
using MIDIConverter.Logic.Conversion;
using MIDIConverter.Logic.SID;

namespace MIDIConverter.Tests
{
    [TestClass]
    public sealed class LeadingSilenceTests
    {
        [TestMethod]
        public void ArrangePreservesSilenceBeforeFirstNote()
        {
            var midi = new MIDIFileData
            {
                Format = 0,
                TrackCount = 1,
                TicksPerQuarterNote = 480,
                LastTick = 960,
                Notes =
                [
                    new MIDINote
                    {
                        Id = 1,
                        NoteNumber = 69,
                        Velocity = 100,
                        StartTick = 480,
                        EndTick = 960
                    }
                ]
            };

            var result = new MIDIArranger(new SIDPitchConverter())
                .Arrange(midi, new MIDIConverterAppSettings());

            Assert.HasCount(2, result.Steps);
            Assert.AreEqual(500, result.Steps[0].DurationMilliseconds);
            Assert.AreEqual(0, result.Steps[0].ActiveMask);
            Assert.AreEqual(1, result.Steps[1].ActiveMask);
        }
    }
}
