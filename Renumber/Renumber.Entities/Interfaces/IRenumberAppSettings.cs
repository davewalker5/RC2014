namespace Renumber.Entities.Interfaces
{
    public interface IRenumberAppSettings
    {
        bool InPlace { get; set; }
        int StartAt { get; set; }
        int IncrementBy { get; set; }
    }
}
