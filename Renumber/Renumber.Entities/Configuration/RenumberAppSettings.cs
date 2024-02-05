using Renumber.Entities.Interfaces;

namespace Renumber.Entities.Configuration
{
    public class RenumberAppSettings : IRenumberAppSettings
    {
        public bool InPlace { get; set; }
        public int StartAt { get; set; }
        public int IncrementBy { get; set; }
    }
}
