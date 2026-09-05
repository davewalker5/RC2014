using MIDIConverter.Entities.Interfaces;
using System.Diagnostics.CodeAnalysis;

namespace MIDIConverter.Entities.Configuration
{
    [ExcludeFromCodeCoverage]
    public sealed class MIDIConverterAppSettings : IMIDIConverterAppSettings
    {
        /// <summary>
        /// Gets or sets the number of quantisation steps in each quarter note.
        /// </summary>
        public int StepsPerQuarterNote { get; set; } = 4;

        /// <summary>
        /// Gets or sets the optional tempo override in beats per minute; null preserves the MIDI tempo map.
        /// </summary>
        public double? TempoBeatsPerMinute { get; set; }

        /// <summary>
        /// Gets or sets the SID clock frequency used to calculate frequency words, in hertz.
        /// </summary>
        public int SIDClockHertz { get; set; } = 1000000;

        /// <summary>
        /// Gets or sets the SID master volume from 0 to 15.
        /// </summary>
        public int MasterVolume { get; set; } = 10;

        /// <summary>
        /// Gets or sets the waveform used by all three pitched SID voices.
        /// </summary>
        public SIDWaveform Waveform { get; set; } = SIDWaveform.Triangle;

        /// <summary>
        /// Gets or sets the 12-bit pulse width used when the pulse waveform is selected.
        /// </summary>
        public int PulseWidth { get; set; } = 2048;

        /// <summary>
        /// Gets or sets the number of BASIC delay-loop iterations representing one millisecond.
        /// </summary>
        public int DelayLoopIterationsPerMillisecond { get; set; } = 1;

        /// <summary>
        /// Gets or sets the line number assigned to the first generated BASIC statement.
        /// </summary>
        public int BasicStartLineNumber { get; set; } = 10;

        /// <summary>
        /// Gets or sets the increment between generated BASIC line numbers.
        /// </summary>
        public int BasicLineNumberIncrement { get; set; } = 10;

        /// <summary>
        /// Gets or sets whether an existing BASIC output file may be replaced.
        /// </summary>
        public bool OverwriteOutputFile { get; set; }

        /// <summary>
        /// Gets or sets whether detailed conversion diagnostics are displayed.
        /// </summary>
        public bool Verbose { get; set; }
    }
}
