using MIDIConverter.Entities.Configuration;
using MIDIConverter.Entities.MIDI;
using MIDIConverter.Logic.Conversion;
using MIDIConverter.Logic.SID;

namespace MIDIConverter.Tests
{
    [TestClass]
    public sealed class MIDIArrangerTests
    {
        [TestMethod]
        public void ArrangeProducesOneHalfSecondPlaybackStep()
        {
            var midi = new MIDIFileData
            {
                Format = 0,
                TrackCount = 1,
                TicksPerQuarterNote = 480,
                LastTick = 480,
                Notes =
                [
                    new MIDINote
                    {
                        Id = 1,
                        NoteNumber = 69,
                        Velocity = 100,
                        StartTick = 0,
                        EndTick = 480
                    }
                ]
            };

            var result = new MIDIArranger(new SIDPitchConverter())
                .Arrange(midi, new MIDIConverterAppSettings());

            Assert.HasCount(1, result.Steps);
            Assert.AreEqual(500, result.Steps[0].DurationMilliseconds);
            Assert.AreEqual(7382, result.Steps[0].Frequency1);
            Assert.AreEqual(1, result.Steps[0].ActiveMask);
            Assert.AreEqual(1, result.Steps[0].RetriggerMask);
        }

        [TestMethod]
        public void ArrangeReducesFourNoteChordToThreeVoices()
        {
            var notes = new[] { 48, 60, 64, 72 }
                .Select((number, id) => new MIDINote
                {
                    Id = id,
                    NoteNumber = number,
                    Velocity = number == 64 ? 120 : 80,
                    StartTick = 0,
                    EndTick = 480
                })
                .ToList();
            var midi = new MIDIFileData
            {
                Format = 0,
                TrackCount = 1,
                TicksPerQuarterNote = 480,
                LastTick = 480,
                Notes = notes
            };

            var result = new MIDIArranger(new SIDPitchConverter())
                .Arrange(midi, new MIDIConverterAppSettings());

            Assert.AreEqual(1, result.DiscardedNoteCount);
            Assert.AreEqual(7, result.Steps[0].ActiveMask);
        }
    }
}
