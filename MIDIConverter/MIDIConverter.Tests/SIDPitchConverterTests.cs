using MIDIConverter.Logic.SID;

namespace MIDIConverter.Tests
{
    [TestClass]
    public sealed class SIDPitchConverterTests
    {
        [TestMethod]
        public void ConvertReturnsNominalA4Word()
        {
            var result = new SIDPitchConverter().Convert(69, 1000000, out var clamped);

            Assert.AreEqual(7382, result);
            Assert.IsFalse(clamped);
        }
    }
}
