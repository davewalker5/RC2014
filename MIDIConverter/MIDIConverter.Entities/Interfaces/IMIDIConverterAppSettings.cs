using MIDIConverter.Entities.Configuration;

namespace MIDIConverter.Entities.Interfaces
{
    public interface IMIDIConverterAppSettings
    {
        int StepsPerQuarterNote { get; set; }
        double? TempoBeatsPerMinute { get; set; }
        int SIDClockHertz { get; set; }
        int MasterVolume { get; set; }
        SIDWaveform Waveform { get; set; }
        int PulseWidth { get; set; }
        int DelayLoopIterationsPerMillisecond { get; set; }
        int BasicStartLineNumber { get; set; }
        int BasicLineNumberIncrement { get; set; }
        bool OverwriteOutputFile { get; set; }
        bool Verbose { get; set; }
    }
}
