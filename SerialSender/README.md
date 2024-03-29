# Serial Sender

## Overview

The RC2014 Mini II doesn't include persistent storage so the program to run must be copied to it each time it is either reset or powered on from a powered off state.

The serial sender application is a C# application that can send the contents of a text file containing commands or program source code to the serial port to which the RC2014 is connected.

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
- This will be copied to the output folder when the project is built and should be modified so the settings match the machine on which the sender will be run
- The defaults can be overwritten using the command line arguments indicated in the table, below

| Setting          | Default | CLI               | Purpose                                                                                        |
| ---------------- | ------- | ----------------- | ---------------------------------------------------------------------------------------------- |
| PortName         | COM3    | --port, -p        | Name of the serial port to connect to                                                          |
| BaudRate         | 115200  | --baud, -b        | Transfer rate, in bits per second                                                              |
| Parity           | None    | --parity, -pa     | Number of parity bits sent with each package of data, for error checking                       |
| DataBits         | 8       | --data, -d        | Number of data bits                                                                            |
| StopBits         | 1       | --stop, -st       | Number of stop bits sent after the data bits                                                   |
| Handshake        | None    | --handshake, -h   | Flow control handshake, one of None, XOnXOff, RequestToSend or RequestToSendXOnXOff            |
| BlockSize        | 10      | --blocksize, -bs  | Number of characters to send before waiting for the block delay                                |
| BlockDelay       | 60      | --blockdelay, -bd | Delay between each block of characters, in ms                                                  |
| LineDelay        | 250     | --linedelay, -ld  | Delay between each line, in ms                                                                 |
| LineEnding       | \r\n    | --lineending, -le | Line ending sent at the end of each line                                                       |
| SendResetCommand | true    | --sendreset, -sr  | Send a NEW or RESET command before sending the file                                            |
| Verbose          | false   | --verbose, -v     | Track progress by echoing the content of each line sent rather than using a progress indicator |

- Note that "default" refers to the value in the appsettings.json file that is part of the repository

## File Types and "SCM" Files

### File Types and the Reset Command

- The file sender uses the file extension to identify the type of file being sent
- This is used to decide what "reset" command to send, if that option is enabled (see above)
- Recognised file types, the expected state of the RC2014 and the reset command are shown below:

| File Type                       | Extension | RC2014 Booted Into | Command sent by SendResetCommand |
| ------------------------------- | --------- | ------------------ | -------------------------------- |
| BASIC program                   | bas       | BASIC              | NEW                              |
| Small Computer Monitor commands | scm       | SCM                | RESET                            |

- Note that "SCM" files aren't an officially supported file type!
- File extensions are not case-sensitive so, for example, "bas" and "BAS" are equivalent
- Files with unrecognised extensions are still sent but no reset command is sent

### Small Computer Monitor Files

- The following is an example SCM file that sends the "hello world" program and associated data, given as an example in the SCM tutorial (see references, below):

```
E 8100
"Hello World!
0
<ESC>
A 8000
LD HL,$8100
LD A,(HL)
CP $00
RET Z
LD C,$02
PUSH HL
CALL $0030
POP HL
INC HL
JP $8003
<ESC>
```

- The first four lines write the zero-terminated data to be printed into memory starting at location 8100
- Note that the &lt;ESC&gt; placeholder is replaced with \x1B when sent, which is an escape character and breaks out of the memory editor
- The remaining lines send the assembly program, writing it from memory location 8000 onwards

## Transferring a Program

- Clear the current program from the RC2014 by:
  - Resetting it
  - Using a terminal emulator to enter the NEW command (when running BASIC)
  - Setting the "SendResetCommand" property in appsettings.json to true (when running BASIC or the SCM)
  - Using the --sendreset command line option
- Make sure the terminal emulator is disconnected
- Assuming the application has been compiled to \target\folder, per the instructions above, enter the following command:

```bash
\target\folder\SerialSender.exe --send \path\to\program.bas
```

- Replace "\path\to\program.bas" with the path to a file to send to the device
- The output should look similar to the following:

```
Serial Port File Sender v1.4.0.0

File to send: morse_translate.bas
Serial port: COM3
Baud rate: 115200
Parity: None
Data bits: 8
Stop bits: One
Handshake: None
Block Size: 10 characters
Block Delay: 50 ms
Line Delay: 200 ms
Send reset command: True
Verbose Output: False

......................................................

54 lines of data sent
```

## Example Settings

The baud rate, parity and numbers of data and stop bits are determined by the hardware and the defaults, listed above, are approriate for the RC2014 Mini II. The block size, block delay and line delay implement simplistic flow control that avoids loss of data and corruption of the transferred program that occurs if the data is sent too quickly.

Below are example settings for transferring different file types:

| Setting          | BASIC | SCM  |
| ---------------- | ----- | ---- |
| Handshake        | None  | None |
| BlockSize        | 1     | 1    |
| BlockDelay       | 5     | 5    |
| LineDelay        | 200   | 200  |
| LineEnding       | \r\n  | \r\n |
| SendResetCommand | true  | true |

## Troubleshooting

If the data transferred to the RC2014 is corrupted or incomplete, experiment by changing the block size, block delay and line delay properties.

## References

- [Small Computer Monitor Tutorial](https://smallcomputercentral.files.wordpress.com/2018/05/scmon-v1-0-tutorial-e1-0-0.pdf), Stephen C. Cousins, Edition 1.0.0
