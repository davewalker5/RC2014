using Renumber.Logic.Configuration;

namespace Renumber.Tests
{
    [TestClass]
    public class RenumberSettingsBuilderTest
    {
        [TestMethod]
        public void DefaultConfigTest()
        {
            var builder = new RenumberSettingsBuilder();
            builder.BuildSettings([], "appsettings.json");

            Assert.IsFalse(builder.Settings.InPlace);
            Assert.AreEqual(32, builder.Settings.StartAt);
            Assert.AreEqual(19, builder.Settings.IncrementBy);
        }

        [TestMethod]
        public void ProvideFileNameTest()
        {
            var args = new string[] { "--renumber", "myprogram.bas" };
            var builder = new RenumberSettingsBuilder();
            builder.BuildSettings(args, "appsettings.json");
            Assert.AreEqual("myprogram.bas", builder.FileName);
        }

        [TestMethod]
        public void OverrideInPlaceTest()
        {
            var args = new string[] { "--inplace", "true" };
            var builder = new RenumberSettingsBuilder();
            builder.BuildSettings(args, "appsettings.json");
            Assert.IsTrue(builder.Settings.InPlace);
        }

        [TestMethod]
        public void OverrideStartAtTest()
        {
            var args = new string[] { "--start", "3128"};
            var builder = new RenumberSettingsBuilder();
            builder.BuildSettings(args, "appsettings.json");
            Assert.AreEqual(3128, builder.Settings.StartAt);
        }

        [TestMethod]
        public void OverrideIncrementByTest()
        {
            var args = new string[] { "--increment", "67"};
            var builder = new RenumberSettingsBuilder();
            builder.BuildSettings(args, "appsettings.json");
            Assert.AreEqual(67, builder.Settings.IncrementBy);
        }
    }
}
