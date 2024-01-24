using SerialSender.Entities.Configuration;
using SerialSender.Logic.Configuration;
using System.IO.Ports;

namespace BaseStationReader.Tests
{
    [TestClass]
    public class ConfigReaderTest
    {
        [TestMethod]
        public void ReadAppSettingsTest()
        {
            var settings = new ConfigReader<SerialSenderAppSettings>().Read("appsettings.json");

            Assert.AreEqual("COM3", settings.PortName);
            Assert.AreEqual(115200, settings.BaudRate);
            Assert.AreEqual(Parity.None, settings.Parity);
            Assert.AreEqual(8, settings.DataBits);
            Assert.AreEqual(StopBits.One, settings.StopBits);
            Assert.AreEqual(0, settings.Delay);
            Assert.AreEqual("\r\n", settings.LineEnding);
        }
    }
}
