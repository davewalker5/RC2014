using Castle.DynamicProxy.Generators;
using Moq;
using SerialSender.Entities.Events;
using SerialSender.Entities.Interfaces;
using SerialSender.Logic;

namespace SerialSender.Tests
{
    [TestClass]
    public class SerialPortWriterTests
    {
        private Mock<ISerialPort> _mockSerialPort;
        private Mock<ISerialSenderAppSettings> _mockSettings;
        private SerialPortWriter _writer;
        private List<string> _dataSent;

        /// <summary>
        /// Handler for the "string written" event
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void OnStringWritten(object sender, StringWrittenEventArgs e)
        {
            _dataSent.Add(e.Data);
        }

        /// <summary>
        /// Confirm that the data actually sent matches the expected data
        /// </summary>
        /// <param name="expected"></param>
        private void ConfirmExpectedDataWasSent(List<string> expected)
        {
            var expectedStrings = (_mockSettings.Object.SendNewCommand) ? expected.Prepend("NEW").ToList() : expected;

            Assert.AreEqual(expectedStrings.Count, _dataSent.Count);

            for (int i = 0; i < expectedStrings.Count; i++)
            {
                Assert.AreEqual(expectedStrings[i], _dataSent[i]);
            }
        }

        [TestInitialize]
        public void TestInitialize()
        {
            _dataSent = new List<string>();
            _mockSerialPort = new Mock<ISerialPort>();
            _mockSettings = new Mock<ISerialSenderAppSettings>();
            _writer = new SerialPortWriter(_mockSerialPort.Object, _mockSettings.Object);
            _writer.StringWritten += OnStringWritten;
        }

        [TestCleanup]
        public void TestCleanup()
        {
            _writer.StringWritten -= OnStringWritten;
        }

        [TestMethod]
        public void OpenShouldOpenPortWhenItIsNotOpen()
        {
            _mockSerialPort.Setup(sp => sp.IsOpen).Returns(false);
            _writer.Open();
            _mockSerialPort.Verify(sp => sp.Open(), Times.Once);
        }

        [TestMethod]
        public void CloseShouldClosePortWhenItIsOpen()
        {
            _mockSerialPort.Setup(sp => sp.IsOpen).Returns(true);
            _writer.Close();
            _mockSerialPort.Verify(sp => sp.Close(), Times.Once);
        }

        [TestMethod]
        public void WriteShouldWriteAllStringsToThePortWhenTheDelayIsZero()
        {
            var strings = Generators.GenerateRandomAlphanumericStrings(10, 10);
            _mockSettings.Setup(s => s.Delay).Returns(0);
            _writer.WriteStrings(strings);
            ConfirmExpectedDataWasSent(strings);
        }

        [TestMethod]
        public void WriteShouldWriteAllStringsToThePortWhenTheDelayIsNotZero()
        {
            var strings = Generators.GenerateRandomAlphanumericStrings(10, 10);
            _mockSettings.Setup(s => s.Delay).Returns(1);
            _writer.WriteStrings(strings);
            ConfirmExpectedDataWasSent(strings);
        }

        [TestMethod]
        public void WriteFileShouldWriteAllLinesInTheFile()
        {
            _mockSettings.Setup(s => s.Delay).Returns(1);
            _writer.WriteFile("HelloWorld.bas");

            var lines = File.ReadAllLines("HelloWorld.bas").ToList();
            ConfirmExpectedDataWasSent(lines);
        }

        [TestMethod]
        public void NewCommandShouldBeSentFirstWhenEnabled()
        {
            var strings = Generators.GenerateRandomAlphanumericStrings(10, 10);
            _mockSettings.Setup(s => s.SendNewCommand).Returns(true);
            _writer.WriteStrings(strings);
            ConfirmExpectedDataWasSent(strings);
        }
    }
}
