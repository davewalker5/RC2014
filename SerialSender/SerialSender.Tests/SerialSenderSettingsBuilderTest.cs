using SerialSender.Logic.Configuration;
using System.IO.Ports;

namespace SerialSender.Tests
{
    [TestClass]
    public class SerialSenderSettingsBuilderTest
    {
        [TestMethod]
        public void DefaultConfigTest()
        {
            var builder = new SerialSenderSettingsBuilder();
            builder.BuildSettings([], "appsettings.json");

            Assert.IsTrue(string.IsNullOrEmpty(builder.FileName));
            Assert.AreEqual("COM3", builder.Settings.PortName);
            Assert.AreEqual(115200, builder.Settings.BaudRate);
            Assert.AreEqual(Parity.None, builder.Settings.Parity);
            Assert.AreEqual(8, builder.Settings.DataBits);
            Assert.AreEqual(StopBits.One, builder.Settings.StopBits);
            Assert.AreEqual(Handshake.None, builder.Settings.Handshake);
            Assert.AreEqual(10, builder.Settings.BlockSize);
            Assert.AreEqual(50, builder.Settings.BlockDelay);
            Assert.AreEqual(200, builder.Settings.LineDelay);
            Assert.AreEqual("\r\n", builder.Settings.LineEnding);
            Assert.IsTrue(builder.Settings.SendNewCommand);
            Assert.IsFalse(builder.Settings.Verbose);
        }

        [TestMethod]
        public void ProvideFileNameTest()
        {
            var args = new string[] { "--send", "myprogram.bas" };
            var builder = new SerialSenderSettingsBuilder();
            builder.BuildSettings(args, "appsettings.json");
            Assert.AreEqual("myprogram.bas", builder.FileName);
        }

        [TestMethod]
        public void OverridePortTest()
        {
            var args = new string[] { "--port", "COM1" };
            var builder = new SerialSenderSettingsBuilder();
            builder.BuildSettings(args, "appsettings.json");
            Assert.AreEqual("COM1", builder.Settings.PortName);
        }

        [TestMethod]
        public void OverrideBaudRateTest()
        {
            var args = new string[] { "--baud", "1200"};
            var builder = new SerialSenderSettingsBuilder();
            builder.BuildSettings(args, "appsettings.json");
            Assert.AreEqual(1200, builder.Settings.BaudRate);
        }

        [TestMethod]
        public void OverrideParityTest()
        {
            var args = new string[] { "--parity", "Even"};
            var builder = new SerialSenderSettingsBuilder();
            builder.BuildSettings(args, "appsettings.json");
            Assert.AreEqual(Parity.Even, builder.Settings.Parity);
        }

        [TestMethod]
        public void OverrideDataBitsTest()
        {
            var args = new string[] { "--data", "16" };
            var builder = new SerialSenderSettingsBuilder();
            builder.BuildSettings(args, "appsettings.json");
            Assert.AreEqual(16, builder.Settings.DataBits);
        }

        [TestMethod]
        public void OverrideStopBitsTest()
        {
            var args = new string[] { "--stop", "Two" };
            var builder = new SerialSenderSettingsBuilder();
            builder.BuildSettings(args, "appsettings.json");
            Assert.AreEqual(StopBits.Two, builder.Settings.StopBits);
        }

        [TestMethod]
        public void OverrideHandshakeTest()
        {
            var args = new string[] { "--handshake", "RequestToSend" };
            var builder = new SerialSenderSettingsBuilder();
            builder.BuildSettings(args, "appsettings.json");
            Assert.AreEqual(Handshake.RequestToSend, builder.Settings.Handshake);
        }

        [TestMethod]
        public void OverrideBlockSizeTest()
        {
            var args = new string[] { "--blocksize", "20" };
            var builder = new SerialSenderSettingsBuilder();
            builder.BuildSettings(args, "appsettings.json");
            Assert.AreEqual(20, builder.Settings.BlockSize);
        }

        [TestMethod]
        public void OverrideBlockDelayTest()
        {
            var args = new string[] { "--blockdelay", "100" };
            var builder = new SerialSenderSettingsBuilder();
            builder.BuildSettings(args, "appsettings.json");
            Assert.AreEqual(100, builder.Settings.BlockDelay);
        }

        [TestMethod]
        public void OverrideLineDelayTest()
        {
            var args = new string[] { "--linedelay", "500" };
            var builder = new SerialSenderSettingsBuilder();
            builder.BuildSettings(args, "appsettings.json");
            Assert.AreEqual(500, builder.Settings.LineDelay);
        }

        [TestMethod]
        public void OverrideLineEndingTest()
        {
            var args = new string[] { "--lineending", "LF" };
            var builder = new SerialSenderSettingsBuilder();
            builder.BuildSettings(args, "appsettings.json");
            Assert.AreEqual("LF", builder.Settings.LineEnding);
        }

        [TestMethod]
        public void OverrideSendNewCommandTest()
        {
            var args = new string[] { "--sendnew", "false" };
            var builder = new SerialSenderSettingsBuilder();
            builder.BuildSettings(args, "appsettings.json");
            Assert.IsFalse(builder.Settings.SendNewCommand);
        }

        [TestMethod]
        public void OverrideVerboseTest()
        {
            var args = new string[] { "--verbose", "true" };
            var builder = new SerialSenderSettingsBuilder();
            builder.BuildSettings(args, "appsettings.json");
            Assert.IsTrue(builder.Settings.Verbose);
        }
    }
}
