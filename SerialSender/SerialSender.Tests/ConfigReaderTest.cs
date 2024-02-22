using SerialSender.Entities.Configuration;
using SerialSender.Logic.Configuration;
using System.IO.Ports;

namespace SerialSender.Tests
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
            Assert.AreEqual(Handshake.None, settings.Handshake);
            Assert.AreEqual(10, settings.BlockSize);
            Assert.AreEqual(50, settings.BlockDelay);
            Assert.AreEqual(200, settings.LineDelay);
            Assert.AreEqual("\r\n", settings.LineEnding);
            Assert.IsTrue(settings.SendResetCommand);
            Assert.IsFalse(settings.Verbose);
        }
    }
}
