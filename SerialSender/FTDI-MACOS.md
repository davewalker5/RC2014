# Using an FTDI USB-to-Serial Cable on MacOS

## Determining the Device Name

### Based on the Serial Number

From the Apple menu, select "About This Mac" then select "System Report..." from the resulting dialog and on the system report window select "USB" under the "Hardware" list. This should list the USB devices on the system and include an entry for the FTDI connection:

<img src="https://github.com/davewalker5/RC2014/blob/main/Images/ftdi-device-details.png" alt="FTDI Device Details" width="600">

Make a note of the serial number and use the following as the serial device to connect to:

```
/dev/tty.usbserial-XXXX
```

Replacing "XXXX" with the device serial number. In the above example, the device would be:

```
/dev/tty.usbserial-AB80DARE
```

### Detecting Available Serial Devices

Available serial devices can be listed using the following command:

```bash
ls -1 /dev/tty*
```

Run this command once with the FTDI cable unplugged, redirecting the result to a file, and again with the FTDI cable plugged in, redirecting to a different file. Use the diff command to list the differences in the two files and they should include the name of the serial device.

## Connecting to the RC2014 Mini II

Use the following command to connect to the RC2014 Mini II:

```bash
screen /dev/tty.usbserial-XXXX 115200
```

Replacing _tty.usbserial-XXXX_ with the device name identified, above. This should connect and allow you to issue the commands appropriate to whichever option you've booted into:

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

## Disconnecting from the RC2014 Mini II

To disconnect, use CTRL+A+D. The output should look similar to the following:

```bash
user@mac ~% screen /dev/tty.usbserial-AB80DARE 115200
[detached]
user@mac ~%
```

This will leave a connection running that will prevent further connections either via _screen_ or from the file transfer applications. To list the connection, using the following:

```bash
screen -list
```

The output should be similar to the following:

```bash
There is a screen on:
	96424.ttys000.mac	(Detached)
1 Socket in /var/folders/4x/3xd5wtl93pggh7cltbd4nshm0000gn/T/.screen.
```

Use the following command to close that connection and free up the serial device:

```bash
screen -X -S XXXX quit
```

Replacing XXXX with the number given in the output from the list command, in the above example 96424.
