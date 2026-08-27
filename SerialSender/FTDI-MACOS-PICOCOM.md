# Using an FTDI USB-to-Serial Cable on macOS with picocom

## Installing picocom

[Homebrew](https://brew.sh/) must be installed before installing picocom. Once Homebrew is available, install picocom with:

```bash
brew install picocom
```

Confirm that it has been installed successfully with:

```bash
picocom --version
```

## Determining the Device Name

### Based on the Serial Number

From the Apple menu, select "About This Mac", then select "System Report..." from the resulting dialog. In the System Information window, select "USB" under the "Hardware" list. This should list the USB devices on the system and include an entry for the FTDI connection:

<img src="https://github.com/davewalker5/RC2014/blob/main/Images/ftdi-device-details.png" alt="FTDI Device Details" width="600">

Make a note of the serial number and use the following as the serial device to connect to:

```
/dev/tty.usbserial-XXXX
```

Replace `XXXX` with the device serial number. In the example above, the device would be:

```
/dev/tty.usbserial-AB80DARE
```

### Detecting Available Serial Devices

Available serial devices can be listed using the following command:

```bash
ls -1 /dev/tty*
```

Run this command once with the FTDI cable unplugged and again with the FTDI cable plugged in, then compare the output. The differences should include the name of the serial device.

## Connecting to the RC2014 Mini II

Use the following command to connect to the RC2014 Mini II at 115200 baud:

```bash
picocom --baud 115200 /dev/tty.usbserial-XXXX
```

Replace `/dev/tty.usbserial-XXXX` with the device name identified above. Picocom defaults to eight data bits, no parity and one stop bit, which are the settings required by the RC2014 Mini II.

After connecting, press Enter if a prompt is not immediately visible. You should then be able to issue the commands appropriate to whichever option the RC2014 has booted into:

```
*HELP
Small Computer Monitor by Stephen C Cousins (www.scc.me.uk)
Version 1.0.0 configuration R4 for Z80 based RC2014 systems

Monitor commands:
A [<address>]  = Assemble        |  D [<address>]   = Disassemble
M [<address>]  = Memory display  |  E [<address>]   = Edit memory
R [<name>]     = Registers/edit  |  F [<name>]      = Flags/edit
B [<address>]  = Breakpoint      |  S [<address>]   = Single step
I <port>       = Input from port |  O <port> <data> = Output to port
G [<address>]  = Go to program
BAUD <device> <rate>             |  CONSOLE <device>
FILL <start> <end> <byte>        |  API <function> [<A>] [<DE>]
DEVICES, DIR, HELP, RESET
BASIC    Grant Searle's adaptation of Microsoft BASIC
WBASIC   Warm start BASIC (retains BASIC program)
CPM      Load CP/M from Compact Flash (requires prepared CF card)
*
```

Picocom's command key is `Ctrl+A`. Press `Ctrl+A`, then `Ctrl+H`, to display its available commands while connected.

## Disconnecting from the RC2014 Mini II

To exit picocom, press `Ctrl+A`, then `Ctrl+X`.

The output should look similar to the following:

```text
Terminating...
Thanks for using picocom
user@mac ~%
```

Unlike detaching from a Screen session, exiting picocom closes the connection and releases the serial device. Make sure picocom has been exited before using SerialSender or another terminal application with the same device.

