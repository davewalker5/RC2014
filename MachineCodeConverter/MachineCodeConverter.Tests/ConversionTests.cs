using MachineCodeConverter.Entities.Configuration;
using MachineCodeConverter.Logic;
using MachineCodeConverter.Logic.Basic;
using MachineCodeConverter.Logic.Configuration;

namespace MachineCodeConverter.Tests
{
    [TestClass]
    public class ConversionTests
    {
        [TestMethod]
        public void ExampleProducesMagazineData()
        {
            CollectionAssert.AreEqual(new[] { "1000 DATA 62,42,50,0,241,201" },
                new BasicDataGenerator().Generate(new byte[] { 62, 42, 50, 0, 241, 201 }, new MachineCodeConverterAppSettings()));
        }

        [TestMethod]
        public void AllByteValuesRoundTripAcrossPartialLines()
        {
            var bytes = Enumerable.Range(0, 256).Select(x => (byte)x).ToArray();
            var lines = new BasicDataGenerator().Generate(bytes, new MachineCodeConverterAppSettings { BytesPerLine = 7 });
            var recovered = lines.SelectMany(x => x.Split(" DATA ")[1].Split(',')).Select(byte.Parse).ToArray();
            CollectionAssert.AreEqual(bytes, recovered);
            Assert.AreEqual(37, lines.Length);
            Assert.AreEqual("1360 DATA 252,253,254,255", lines.Last());
        }

        [TestMethod]
        public void HexUsesPaddedUppercaseBytesAndCustomNumbering()
        {
            var settings = new MachineCodeConverterAppSettings
                { Hexadecimal = true, BytesPerLine = 2, BasicStartLineNumber = 20, BasicLineNumberIncrement = 5 };
            CollectionAssert.AreEqual(new[] { "20 DATA &H00,&H0A", "25 DATA &HFF" },
                new BasicDataGenerator().Generate(new byte[] { 0, 10, 255 }, settings));
        }

        [TestMethod]
        public void EmptyInputAndLineOverflowAreRejected()
        {
            var generator = new BasicDataGenerator();
            Assert.Throws<InvalidDataException>(() => generator.Generate(Array.Empty<byte>(), new MachineCodeConverterAppSettings()));
            var settings = new MachineCodeConverterAppSettings { BasicStartLineNumber = 65529, BytesPerLine = 1 };
            Assert.AreEqual("65529 DATA 1", generator.Generate(new byte[] { 1 }, settings)[0]);
            Assert.Throws<ArgumentException>(() => generator.Generate(new byte[] { 1, 2 }, settings));
        }

        [TestMethod]
        [DataRow(0)]
        [DataRow(17)]
        public void InvalidByteCountsAreRejected(int count)
        {
            Assert.Throws<ArgumentException>(() => BasicDataGenerator.Validate(new MachineCodeConverterAppSettings { BytesPerLine = count }));
        }

        [TestMethod]
        public void CommandLineOverridesJsonDefaults()
        {
            var builder = new MachineCodeConverterSettingsBuilder();
            builder.BuildSettings(new[] { "-c", "example.bin", "-o", "result.bas", "-sl", "200", "-li", "5", "-b", "8", "-x", "true", "-f", "true" },
                Path.Combine(AppContext.BaseDirectory, "appsettings.json"));
            Assert.AreEqual("example.bin", builder.FileName);
            Assert.AreEqual("result.bas", builder.OutputFileName);
            Assert.AreEqual(200, builder.Settings.BasicStartLineNumber);
            Assert.AreEqual(5, builder.Settings.BasicLineNumberIncrement);
            Assert.AreEqual(8, builder.Settings.BytesPerLine);
            Assert.IsTrue(builder.Settings.Hexadecimal);
            Assert.IsTrue(builder.Settings.OverwriteOutputFile);
        }

        [TestMethod]
        public void MissingInputAndMalformedSettingsFail()
        {
            var config = Path.Combine(AppContext.BaseDirectory, "appsettings.json");
            var builder = new MachineCodeConverterSettingsBuilder();
            Assert.Throws<ArgumentException>(() => builder.BuildSettings(Array.Empty<string>(), config));
            Assert.Throws<ArgumentException>(() => builder.BuildSettings(new[] { "-c", "a.bin", "-b", "abc" }, config));
            Assert.Throws<ArgumentException>(() => builder.BuildSettings(new[] { "-c", "a.bin", "-x", "yes" }, config));
            builder.BuildSettings(new[] { "--help" }, "/nonexistent/config.json");
            Assert.IsTrue(builder.ShowHelp);
        }

        [TestMethod]
        public void ServiceProtectsFilesAndWritesPlainText()
        {
            var directory = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString());
            Directory.CreateDirectory(directory);
            try
            {
                var input = Path.Combine(directory, "test.bin");
                var output = Path.Combine(directory, "test.bas");
                var bytes = new byte[] { 0, 255, 201 };
                File.WriteAllBytes(input, bytes);
                var service = new MachineCodeConverterService();
                var settings = new MachineCodeConverterAppSettings();
                Assert.AreEqual(output, service.Convert(input, "", settings));
                Assert.AreEqual("1000 DATA 0,255,201\n", File.ReadAllText(output));
                Assert.AreEqual((byte)'1', File.ReadAllBytes(output)[0]);
                Assert.Throws<IOException>(() => service.Convert(input, output, settings));
                settings.OverwriteOutputFile = true;
                Assert.Throws<ArgumentException>(() => service.Convert(input, input, settings));
                CollectionAssert.AreEqual(bytes, File.ReadAllBytes(input));
                settings.Hexadecimal = true;
                service.Convert(input, output, settings);
                Assert.AreEqual("1000 DATA &H00,&HFF,&HC9\n", File.ReadAllText(output));
                File.WriteAllBytes(input, Array.Empty<byte>());
                Assert.Throws<InvalidDataException>(() => service.Convert(input, output, settings));
                Assert.AreEqual("1000 DATA &H00,&HFF,&HC9\n", File.ReadAllText(output));
                Assert.AreEqual(2, Directory.GetFiles(directory).Length);
            }
            finally { Directory.Delete(directory, true); }
        }
    }
}
