using SpeechConverter.Logic.Pronunciation;
using System.Text.Json.Nodes;

namespace SpeechConverter.Tests
{
    /// <summary>
    /// Checks the speech sounds produced from representative text.
    /// </summary>
    [TestClass]
    public sealed class EnglishPronunciationConverterTests
    {
        /// <summary>
        /// Keeps the existing demonstration's pronunciation stable.
        /// </summary>
        [TestMethod]
        public void HelloZ80MatchesExistingBasicExample()
        {
            var converter = new EnglishPronunciationConverter();

            var codes = converter.Convert("Hello Z80").Select(allophone => allophone.Code);

            CollectionAssert.AreEqual(
                new[] { 27, 7, 45, 53, 2, 43, 7, 21, 2, 20, 13, 19, 0 },
                codes.ToArray());
        }

        /// <summary>
        /// Spelling rules permit words outside the small built-in dictionary.
        /// </summary>
        [TestMethod]
        public void UnknownWordProducesValidCodes()
        {
            var converter = new EnglishPronunciationConverter();

            var sounds = converter.Convert("robot!");

            Assert.IsTrue(sounds.Count > 1);
            Assert.IsTrue(sounds.All(sound => sound.Code is >= 0 and <= 63));
            Assert.AreEqual("PA1", sounds[^1].Name);
        }

        /// <summary>
        /// Rejects input that cannot produce speech.
        /// </summary>
        [TestMethod]
        public void PunctuationOnlyIsRejected()
        {
            var converter = new EnglishPronunciationConverter();

            Assert.ThrowsExactly<ArgumentException>(() => converter.Convert("?!"));
        }

        /// <summary>
        /// Confirms the published JSON can change a word without recompiling logic.
        /// </summary>
        [TestMethod]
        public void CustomConfigurationChangesPronunciation()
        {
            var configuration = JsonNode.Parse(File.ReadAllText(
                Path.Combine(AppContext.BaseDirectory, "pronunciation.json")))!;
            configuration["words"]!["HELLO"] = "HH1 AY";
            var path = Path.Combine(Path.GetTempPath(), $"pronunciation-{Guid.NewGuid():N}.json");

            try
            {
                File.WriteAllText(path, configuration.ToJsonString());
                var converter = new EnglishPronunciationConverter(path);

                CollectionAssert.AreEqual(
                    new[] { 27, 6, 0 },
                    converter.Convert("hello").Select(sound => sound.Code).ToArray());
            }
            finally
            {
                File.Delete(path);
            }
        }

        [TestMethod]
        public void KnownContractionUsesDictionaryForStraightAndCurlyApostrophes()
        {
            var converter = new EnglishPronunciationConverter();

            foreach (var message in new[] { "I'm", "I’m" })
            {
                CollectionAssert.AreEqual(
                    new[] { 6, 16, 0 },
                    converter.Convert(message).Select(sound => sound.Code).ToArray());
            }
        }

        [TestMethod]
        public void UnknownContractionUsesExistingSplitWordBehavior()
        {
            var converter = new EnglishPronunciationConverter();

            CollectionAssert.AreEqual(
                new[] { 6, 2, 35, 7, 0 },
                converter.Convert("I'VE").Select(sound => sound.Code).ToArray());
        }

        /// <summary>
        /// Rejects references to allophones missing from the mapping.
        /// </summary>
        [TestMethod]
        public void InvalidConfigurationReportsUnknownSound()
        {
            var configuration = JsonNode.Parse(File.ReadAllText(
                Path.Combine(AppContext.BaseDirectory, "pronunciation.json")))!;
            configuration["words"]!["HELLO"] = "NOT_A_SOUND";
            var path = Path.Combine(Path.GetTempPath(), $"pronunciation-{Guid.NewGuid():N}.json");

            try
            {
                File.WriteAllText(path, configuration.ToJsonString());

                Assert.ThrowsExactly<InvalidDataException>(
                    () => new EnglishPronunciationConverter(path));
            }
            finally
            {
                File.Delete(path);
            }
        }
    }
}
