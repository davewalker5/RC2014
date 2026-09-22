using System.Text;
using System.Text.RegularExpressions;
using SpeechConverter.Entities;

namespace SpeechConverter.Logic.Basic
{
    /// <summary>
    /// Renders an allophone sequence as a self-contained RC2014 BASIC listing.
    /// </summary>
    public sealed class BasicProgramGenerator : IBasicProgramGenerator
    {
        /// <inheritdoc />
        public string Generate(IReadOnlyList<Allophone> allophones, string phrase)
        {
            ArgumentNullException.ThrowIfNull(allophones);
            ArgumentException.ThrowIfNullOrWhiteSpace(phrase);
            if (allophones.Count == 0)
            {
                throw new ArgumentException("At least one allophone is required.", nameof(allophones));
            }

            var lines = new List<string>
            {
                "10 REM MG005 SP0256-AL2 SPEECH",
                $"20 FOR I=1 TO {allophones.Count}",
                "30 READ A",
                "40 IF (INP(31) AND 2)=0 THEN GOTO 40",
                "50 OUT 31,A",
                "60 NEXT I",
                "70 END"
            };

            var lineNumber = 80;
            var phraseText = Regex.Replace(phrase.Trim(), @"\s+", " ");
            for (var offset = 0; offset < phraseText.Length; offset += 100)
            {
                var length = Math.Min(100, phraseText.Length - offset);
                lines.Add($"{lineNumber} REM PHRASE: {phraseText.Substring(offset, length)}");
                lineNumber += 10;
                if (lineNumber > 65529)
                {
                    throw new ArgumentException("The message is too long for BASIC line numbers.", nameof(phrase));
                }
            }

            // Keep REM labels and DATA records aligned so the spoken sequence can
            // be inspected without changing the player's fixed-length loop.
            foreach (var group in allophones.Chunk(12))
            {
                var names = string.Join(' ', group.Select(allophone => allophone.Name));
                var codes = string.Join(',', group.Select(allophone => allophone.Code));
                lines.Add($"{lineNumber} REM {names}");
                lineNumber += 10;
                lines.Add($"{lineNumber} DATA {codes}");
                lineNumber += 10;
                if (lineNumber > 65529)
                {
                    throw new ArgumentException("The message is too long for BASIC line numbers.", nameof(allophones));
                }
            }

            foreach (var line in lines)
            {
                if (line.Length > 120)
                {
                    throw new ArgumentException("A generated BASIC line exceeds 120 characters.", nameof(allophones));
                }
            }

            var listing = new StringBuilder();
            foreach (var line in lines)
            {
                listing.AppendLine(line);
            }

            return listing.ToString();
        }
    }
}
