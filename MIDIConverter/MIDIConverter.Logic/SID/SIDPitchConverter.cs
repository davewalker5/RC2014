namespace MIDIConverter.Logic.SID
{
    /// <summary>
    /// Converts equal-tempered MIDI note numbers to SID frequency words.
    /// </summary>
    public sealed class SIDPitchConverter
    {
        /// <summary>
        /// Converts a MIDI note number using the configured SID clock.
        /// </summary>
        public int Convert(int noteNumber, int sidClockHertz, out bool wasClamped)
        {
            if (noteNumber is < 0 or > 127)
            {
                throw new ArgumentOutOfRangeException(nameof(noteNumber));
            }

            ArgumentOutOfRangeException.ThrowIfNegativeOrZero(sidClockHertz);

            // MIDI uses equal temperament with A4 at note 69 and 440 Hz.
            var frequency = 440d * Math.Pow(2d, (noteNumber - 69d) / 12d);

            // A SID phase accumulator advances through 2^24 positions, producing
            // the documented 16-bit frequency word after scaling by its clock.
            var unbounded = Math.Round(
                frequency * 16777216d / sidClockHertz,
                MidpointRounding.AwayFromZero);

            // Zero is silence and values above 65535 cannot fit the SID registers,
            // so report whenever a musically valid MIDI note needs saturation.
            var bounded = Math.Clamp(unbounded, 1d, 65535d);
            wasClamped = bounded != unbounded;
            return (int)bounded;
        }
    }
}
