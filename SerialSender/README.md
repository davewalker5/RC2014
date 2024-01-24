# Serial Sender

## Overview

The RC2014 Mini II doesn't include persistent storage so the program to run must be copied to it each time it is either reset or powered on from a powered off state.

The serial sender application is a C# application that can send the contents of a file containing commands or program source code to the serial port to which the RC2014 is connected.

This has the same effect as connecting to the RC2014 using a terminal emulator and typing the content manually.

## Building the Sender

While the sender can be run from source each time, it is recommended to publish it to a standalone executable.

### Pre-Requisites

The .NET 8 SDK should be installed from https://dotnet.microsoft.com/en-us/download/dotnet/8.0

### Building the Applications

- Check out a working copy of the sender application
- From the root folder of the working copy (the folder containing the .sln solution file), enter the following command:

```bash
dotnet publish SerialSender\SerialSender.csproj -c Release -r rid --self-contained -o \target\folder
```

- Replace "\target\folder" with the path to the folder to which the compiled application should be published
- Replace "rid" with the runtime identifier for the system on which the application will be run
- Further information on .NET RIDs is available at https://learn.microsoft.com/en-us/dotnet/core/rid-catalog

### Application Settings

- The connection properties are defined in the "appsettings.json" file in the "SerialSender" project
- This will be copied to the output folder when the project is built and should be modified so the settings match the machine on which the sender will be run:

| Setting    | Default | Purpose                                  |
| ---------- | ------- | ---------------------------------------- |
| PortName   | COM3    | Name of the serial port to connect to    |
| Delay      | 100     | Delay between sending each line, in ms   |
| LineEnding | \r\n    | Line ending sent at the end of each line |

The remaining properties are set for the RC2014 Mini II and should not be changed.

## Transferring a Program

- Clear the current program from the RC2014 by:
  - Resetting it
  - Using a terminal empulator to enter the NEW command (when running BASIC)
  - Making sure the file to transer begins with an un-numbered line containing the NEW command (when runing BASIC)
- Make sure the terminal emulator is disconnected
- Assuming the application has been compiled to \target\folder, per the instructions above, enter the following command:

```bash
\target\folder\SerialSender.exe \path\to\program.bas
```

- Replace "\path\to\program.bas" with the path to a file to send to the device
- The output should look similar to the following:

```
Serial Port File Sender v1.0.0.0

Serial port: COM3
Baud rate: 115200
Parity: None
Data bits: 8
Stop bits: One
Delay: 100 ms

Sending file RomanNumerals.bas to serial port COM3 at 115200 baud.
.............................................

45 lines of data sent
```

## Troubleshooting

If the data transferred to the RC2014 is corrupted or incomplete, experiment by increasing the "Delay" setting until the issue is resolved.
