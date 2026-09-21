using System.Text.RegularExpressions;
using SpeechConverter.Entities;
using SpeechConverter.Entities.Pronunciation;

namespace SpeechConverter.Logic.Pronunciation
{
    /// <summary>
    /// Converts English words using a small pronunciation lexicon and approximate spelling rules.
    /// </summary>
    public sealed partial class EnglishPronunciationConverter : IPronunciationConverter
    {
        private readonly IReadOnlyDictionary<string, int> _codes;
        private readonly IReadOnlyDictionary<string, string> _words;
        private readonly IReadOnlyList<string> _units;
        private readonly IReadOnlyList<string> _tens;
        private readonly IReadOnlyList<SpellingPattern> _patterns;
        private readonly IReadOnlyDictionary<string, string> _letters;

        /// <summary>
        /// Loads the pronunciation file published beside the application.
        /// </summary>
        public EnglishPronunciationConverter()
            : this(Path.Combine(AppContext.BaseDirectory, "pronunciation.json"))
        {
        }

        /// <summary>
        /// Loads a specified pronunciation file.
        /// </summary>
        /// <param name="configurationPath">Path to the JSON mappings.</param>
        public EnglishPronunciationConverter(string configurationPath)
        {
            var settings = new PronunciationConfigurationReader().Read(configurationPath);
            _codes = new Dictionary<string, int>(settings.Allophones, StringComparer.OrdinalIgnoreCase);
            _words = new Dictionary<string, string>(settings.Words, StringComparer.OrdinalIgnoreCase);
            _units = settings.Units;
            _tens = settings.Tens;
            _patterns = settings.Patterns;
            _letters = new Dictionary<string, string>(settings.Letters, StringComparer.OrdinalIgnoreCase);
        }

        /// <inheritdoc />
        public IReadOnlyList<Allophone> Convert(string message)
        {
            ArgumentException.ThrowIfNullOrWhiteSpace(message);
            var result = new List<Allophone>();
            var pendingPause = 0;

            foreach (Match match in TokenPattern().Matches(message))
            {
                if (char.IsPunctuation(match.Value[0]))
                {
                    pendingPause = Math.Max(pendingPause, 4);
                    continue;
                }

                if (result.Count > 0)
                {
                    AddSound(result, pendingPause == 0 ? "PA3" : "PA5");
                }

                pendingPause = 0;
                if (char.IsDigit(match.Value[0]))
                {
                    foreach (var word in ExpandNumber(match.Value))
                    {
                        if (result.Count > 0 && result[^1].Code > 4)
                        {
                            AddSound(result, "PA2");
                        }

                        AddWord(result, word);
                    }
                }
                else
                {
                    AddWord(result, match.Value.ToUpperInvariant());
                }
            }

            if (result.Count == 0)
            {
                throw new ArgumentException("The message contains no words or numbers.", nameof(message));
            }

            AddSound(result, "PA1");
            return result;
        }

        /// <summary>
        /// Adds a known or approximately pronounced word.
        /// </summary>
        /// <param name="result">Output sequence.</param>
        /// <param name="word">Uppercase English word.</param>
        private void AddWord(List<Allophone> result, string word)
        {
            if (_words.TryGetValue(word, out var known))
            {
                foreach (var sound in known.Split(' '))
                {
                    AddSound(result, sound);
                }

                return;
            }

            var spelling = word.EndsWith('E') && word.Length > 2 ? word[..^1] : word;
            for (var index = 0; index < spelling.Length;)
            {
                var pattern = _patterns.FirstOrDefault(item => spelling.AsSpan(index).StartsWith(item.Spelling));
                if (pattern is not null)
                {
                    foreach (var sound in pattern.Sounds.Split(' '))
                    {
                        AddSound(result, sound);
                    }

                    index += pattern.Spelling.Length;
                }
                else
                {
                    foreach (var sound in _letters[spelling[index].ToString()].Split(' '))
                    {
                        AddSound(result, sound);
                    }

                    index++;
                }
            }
        }

        /// <summary>
        /// Adds a named chip sound to the output sequence.
        /// </summary>
        /// <param name="result">Output sequence.</param>
        /// <param name="name">SP0256-AL2 allophone name.</param>
        private void AddSound(List<Allophone> result, string name)
            => result.Add(new Allophone(name, _codes[name]));

        /// <summary>
        /// Expands an unsigned integer into English words.
        /// </summary>
        /// <param name="digits">Decimal digits.</param>
        /// <returns>Words to pronounce.</returns>
        private IReadOnlyList<string> ExpandNumber(string digits)
        {
            if (!int.TryParse(digits, out var number) || number > 9999)
            {
                throw new ArgumentException("Numbers must be between 0 and 9999.", nameof(digits));
            }

            if (number == 0)
            {
                return ["ZERO"];
            }

            var words = new List<string>();
            if (number >= 1000)
            {
                words.Add(_units[number / 1000]);
                words.Add("THOUSAND");
                number %= 1000;
            }

            if (number >= 100)
            {
                words.Add(_units[number / 100]);
                words.Add("HUNDRED");
                number %= 100;
            }

            if (number >= 20)
            {
                words.Add(_tens[number / 10]);
                number %= 10;
            }

            if (number > 0)
            {
                words.Add(_units[number]);
            }

            return words;
        }

        /// <summary>
        /// Matches English words, unsigned integers and pause punctuation.
        /// </summary>
        /// <returns>The compiled token expression.</returns>
        [GeneratedRegex(@"[A-Za-z]+|[0-9]+|[.,!?;:]")]
        private static partial Regex TokenPattern();
    }
}
