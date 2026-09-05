using MIDIConverter.Entities.Configuration;
using MIDIConverter.Logic;
using MIDIConverter.Logic.Basic;
using MIDIConverter.Logic.Conversion;
using MIDIConverter.Logic.MIDI;
using MIDIConverter.Logic.SID;

namespace MIDIConverter.Tests
{
    [TestClass]
    public sealed class MIDIConverterServiceTests
    {
        [TestMethod]
        public async Task ConvertAsyncWritesCompleteBasicProgram()
        {
            var directory = Path.Combine(Path.GetTempPath(), $"midi-converter-{Guid.NewGuid():N}");
            Directory.CreateDirectory(directory);
            try
            {
                var input = Path.Combine(directory, "note.mid");
                var output = Path.Combine(directory, "note.bas");
                await File.WriteAllBytesAsync(input, MIDIFileReaderTests.CreateScaleNote());
                var service = new MIDIConverterService(
                    new MIDIFileReader(),
                    new MIDIArranger(new SIDPitchConverter()),
                    new BasicProgramGenerator());

                var result = await service.ConvertAsync(
                    input,
                    output,
                    new MIDIConverterAppSettings());

                Assert.IsTrue(File.Exists(output));
                Assert.AreEqual(1, result.SourceNoteCount);
                Assert.AreEqual(0.5d, result.DurationSeconds, 0.001d);
                StringAssert.Contains(await File.ReadAllTextAsync(output), "DATA 500,4389,0,0,1,1");
            }
            finally
            {
                Directory.Delete(directory, true);
            }
        }
    }
}
