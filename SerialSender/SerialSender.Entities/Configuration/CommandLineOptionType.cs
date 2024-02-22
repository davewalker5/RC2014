namespace SerialSender.Entities.Configuration
{
    public enum CommandLineOptionType
    {
        Unknown,
        Send,
        PortName,
        BaudRate,
        Parity,
        DataBits,
        StopBits,
        Handshake,
        BlockSize,
        BlockDelay,
        LineDelay,
        LineEnding,
        SendResetCommand,
        Verbose
    }
}
