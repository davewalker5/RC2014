using MIDIConverter.Entities.MIDI;

namespace MIDIConverter.Entities.Interfaces
{
    /// <summary>
    /// Reads a Standard MIDI File into library-independent entities.
    /// </summary>
    public interface IMIDIFileReader
    {
        /// <summary>
        /// Reads and validates a Standard MIDI File.
        /// </summary>
        Task<MIDIFileData> ReadAsync(string path, CancellationToken cancellationToken = default);
    }
}
