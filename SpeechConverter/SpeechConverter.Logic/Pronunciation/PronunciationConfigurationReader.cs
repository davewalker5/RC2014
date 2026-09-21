using System.Text.Json;
using SpeechConverter.Entities.Pronunciation;

namespace SpeechConverter.Logic.Pronunciation
{
    /// <summary>
    /// Loads and validates the published pronunciation mappings.
    /// </summary>
    public sealed class PronunciationConfigurationReader
    {
        /// <summary>
        /// Reads a JSON pronunciation configuration from disk.
        /// </summary>
        /// <param name="path">Path to the published configuration file.</param>
        /// <returns>Validated pronunciation settings.</returns>
        public PronunciationSettings Read(string path)
        {
            ArgumentException.ThrowIfNullOrWhiteSpace(path);
            var settings = JsonSerializer.Deserialize<PronunciationSettings>(
                File.ReadAllText(path),
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            if (settings is null || settings.Allophones is null || settings.Words is null ||
                settings.Units is null || settings.Tens is null || settings.Patterns is null ||
                settings.Letters is null)
            {
                throw new InvalidDataException("Pronunciation configuration has a missing section.");
            }

            if (settings.Allophones.Count != 64 ||
                settings.Allophones.Values.Any(code => code is < 0 or > 63) ||
                settings.Allophones.Values.Distinct().Count() != 64 ||
                settings.Units.Count != 20 || settings.Tens.Count != 10 ||
                settings.Letters.Count != 26 || settings.Words.Count == 0 ||
                settings.Patterns.Count == 0)
            {
                throw new InvalidDataException("Pronunciation configuration has invalid or incomplete mappings.");
            }

            var codes = new Dictionary<string, int>(settings.Allophones, StringComparer.OrdinalIgnoreCase);
            foreach (var name in new[] { "PA1", "PA2", "PA3", "PA5" })
            {
                if (!codes.ContainsKey(name))
                {
                    throw new InvalidDataException($"Pronunciation configuration is missing {name}.");
                }
            }

            foreach (var entry in settings.Words.Concat(settings.Letters))
            {
                if (string.IsNullOrWhiteSpace(entry.Key))
                {
                    throw new InvalidDataException("Pronunciation configuration contains an empty key.");
                }

                ValidateSounds(entry.Value, codes);
            }

            foreach (var letter in "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
            {
                if (!settings.Letters.ContainsKey(letter.ToString()))
                {
                    throw new InvalidDataException($"Pronunciation configuration is missing letter {letter}.");
                }
            }

            foreach (var pattern in settings.Patterns)
            {
                if (pattern is null || string.IsNullOrWhiteSpace(pattern.Spelling))
                {
                    throw new InvalidDataException("Pronunciation configuration contains an empty spelling pattern.");
                }

                ValidateSounds(pattern.Sounds, codes);
            }

            foreach (var name in new[] { "ZERO", "HUNDRED", "THOUSAND" })
            {
                if (!settings.Words.ContainsKey(name))
                {
                    throw new InvalidDataException($"Pronunciation configuration is missing number word {name}.");
                }
            }

            return settings;
        }

        /// <summary>
        /// Ensures a configured sound sequence names only defined allophones.
        /// </summary>
        /// <param name="sounds">Space-separated allophone names.</param>
        /// <param name="codes">Defined allophone codes.</param>
        private static void ValidateSounds(string sounds, IReadOnlyDictionary<string, int> codes)
        {
            if (string.IsNullOrWhiteSpace(sounds) ||
                sounds.Split(' ', StringSplitOptions.RemoveEmptyEntries).Any(name => !codes.ContainsKey(name)))
            {
                throw new InvalidDataException($"Pronunciation configuration contains unknown sounds: {sounds}");
            }
        }
    }
}
