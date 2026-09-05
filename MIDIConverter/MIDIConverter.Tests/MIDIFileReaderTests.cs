using MIDIConverter.Entities.Exceptions;
using MIDIConverter.Logic.MIDI;

namespace MIDIConverter.Tests
{
    [TestClass]
    public sealed class MIDIFileReaderTests
    {
        [TestMethod]
        public void ParseReadsFormatZeroNoteAndTempo()
        {
            var reader = new MIDIFileReader();
            var midi = reader.Parse(CreateScaleNote());

            Assert.AreEqual(0, midi.Format);
            Assert.AreEqual(480, midi.TicksPerQuarterNote);
            Assert.HasCount(1, midi.Notes);
            Assert.AreEqual(60, midi.Notes[0].NoteNumber);
            Assert.AreEqual(480, midi.Notes[0].EndTick);
            Assert.HasCount(1, midi.TempoChanges);
            Assert.AreEqual(500000, midi.TempoChanges[0].MicrosecondsPerQuarterNote);
        }

        [TestMethod]
        public void ParseRejectsSmpteDivision()
        {
            var bytes = CreateScaleNote();
            bytes[12] = 0xE7;
            bytes[13] = 0x28;

            Assert.Throws<UnsupportedMIDIFileException>(() => new MIDIFileReader().Parse(bytes));
        }

        internal static byte[] CreateScaleNote()
            =>
            [
                0x4D, 0x54, 0x68, 0x64, 0x00, 0x00, 0x00, 0x06,
                0x00, 0x00, 0x00, 0x01, 0x01, 0xE0,
                0x4D, 0x54, 0x72, 0x6B, 0x00, 0x00, 0x00, 0x14,
                0x00, 0xFF, 0x51, 0x03, 0x07, 0xA1, 0x20,
                0x00, 0x90, 0x3C, 0x64,
                0x83, 0x60, 0x80, 0x3C, 0x00,
                0x00, 0xFF, 0x2F, 0x00
            ];
    }
}
