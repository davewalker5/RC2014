namespace SpeechConverter.Entities
{
    /// <summary>
    /// A sound or pause accepted by the SP0256-AL2.
    /// </summary>
    public sealed record Allophone(string Name, int Code);
}
