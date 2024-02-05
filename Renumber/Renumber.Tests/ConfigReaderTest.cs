using Renumber.Entities.Configuration;
using Renumber.Logic.Configuration;

namespace Renumber.Tests
{
    [TestClass]
    public class ConfigReaderTest
    {
        [TestMethod]
        public void ReadAppSettingsTest()
        {
            var settings = new ConfigReader<RenumberAppSettings>().Read("appsettings.json");

            Assert.IsFalse(settings.InPlace);
            Assert.AreEqual(32, settings.StartAt);
            Assert.AreEqual(19, settings.IncrementBy);
        }
    }
}
