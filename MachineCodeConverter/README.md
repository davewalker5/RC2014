# MachineCodeConverter

`MachineCodeConverter` converts raw machine-code binaries into numbered BASIC `DATA` statements suitable for loading into an RC2014 from BASIC.

For example, the six machine-code bytes:

```text
3E 2A 32 00 F1 C9
```

can be converted into:

```basic
1000 DATA 62,42,50,0,241,201
```

A BASIC program can then `READ` those values and `POKE` them into RAM before calling the machine-code routine.

There are considerably easier ways of getting software onto a modern computer but that is not the point!

## Why Would You Want To Do This?

One of the pleasures of an RC2014 is that the boundary between a high-level language and the machine underneath it is remarkably visible.

A classic technique from the late 1970s and early 1980s was to combine BASIC with small machine-code routines:

1. Write a routine in assembly language
2. Assemble it into machine code
3. Express the resulting bytes as BASIC `DATA` statements
4. Use `READ` and `POKE` to copy those bytes into RAM
5. Call the machine-code routine from BASIC

Computer magazines frequently published machine-code routines in exactly this form: long sequences of numbers which the reader typed into BASIC and `POKE`d into memory.

`MachineCodeConverter` automates the particularly tedious part of that process.

Instead of manually translating:

```text
3E 2A 32 00 F1 C9
```

into:

```basic
1000 DATA 62,42,50,0,241,201
```

the converter reads the assembled binary directly and generates the BASIC statements.

This makes it practical to use assembly language for the parts of an RC2014 program where it is useful while retaining BASIC for the rest.

Possible reasons include:

- Experimenting with Z80 assembly and machine code
- Calling small assembly-language routines from BASIC
- Accessing hardware more directly
- Implementing operations which are awkward or slow in BASIC
- Exploring how BASIC, RAM and the Z80 interact
- Recreating the wonderfully old-fashioned `DATA` / `READ` / `POKE` programming techniques used on early home computers

## Where the Converter Fits

The complete workflow looks like this:

```text
Z80 assembly source
        |
        | assembler
        v
Raw machine-code binary (.bin)
        |
        | MachineCodeConverter
        v
BASIC DATA statements
        |
        | READ / POKE
        v
Machine code in RC2014 RAM
        |
        | USR or another suitable entry mechanism
        v
Z80 executes the routine
```

`MachineCodeConverter` performs only the conversion in the middle.

It does **not*- assemble Z80 source, decide where the resulting code should live in memory, load it onto the RC2014 or execute it.

Those decisions belong to the assembly program and the BASIC loader.

See the example in `Programs/MachineCode` for a complete worked example showing assembly, conversion, RAM reservation, loading with `READ`/`POKE` and execution using BASIC's `USR` function.

## Running the Converter

From the repository root:

```sh
dotnet run --project MachineCodeConverter/MachineCodeConverter -- \
  --convert Programs/MachineCode/example.bin
```

By default this creates:

```text
Programs/MachineCode/example.bas
```

Use `--output` to select a different destination.

Existing output files are protected unless:

```text
--overwrite true
```

is supplied.

For the binary containing:

```text
3E 2A 32 00 F1 C9
```

the default output is:

```basic
1000 DATA 62,42,50,0,241,201
```

The values are the machine-code bytes expressed in decimal:

| Hex  | Decimal |
| ---- | ------: |
| `3E` |      62 |
| `2A` |      42 |
| `32` |      50 |
| `00` |       0 |
| `F1` |     241 |
| `C9` |     201 |

No information is lost or interpreted during conversion. The converter simply preserves the binary byte sequence and changes its textual representation.

## Hexadecimal Output

Decimal is the default because it is widely accepted by BASIC implementations.

Where the target BASIC supports hexadecimal literals in `DATA` statements, hexadecimal output can instead be requested with:

```text
--hex true
```

For example:

```sh
dotnet run --project MachineCodeConverter/MachineCodeConverter -- \
  --convert Programs/MachineCode/example.bin \
  --output /tmp/example-hex.bas \
  --hex true \
  --bytesperline 4
```

produces:

```basic
1000 DATA &H3E,&H2A,&H32,&H00
1010 DATA &HF1,&HC9
```

Hexadecimal output can be particularly useful when comparing the generated BASIC against assembler listings or hexadecimal dumps of the binary.

## BASIC Line Numbering

The generated statements are numbered so that they can be incorporated directly into a traditional BASIC program.

The defaults are:

```text
first line:      1000
line increment:    10
bytes per line:    16
```

For example, a larger binary might produce:

```basic
1000 DATA 62,42,50,0,241,201,...
1010 DATA ...
1020 DATA ...
```

The starting line, increment and number of bytes per statement can all be changed from the command line.

Keeping machine-code data at relatively high line numbers also makes it convenient to place the BASIC loader and application logic earlier in the program.

## Options

| Long option       | Short option | Meaning                              | Default                          |
| ----------------- | ------------ | ------------------------------------ | -------------------------------- |
| `--convert`       | `-c`         | Input raw binary file                | Required                         |
| `--output`        | `-o`         | Output BASIC file                    | Input path with `.bas` extension |
| `--startline`     | `-sl`        | First BASIC line number              | 1000                             |
| `--lineincrement` | `-li`        | Line number increment                | 10                               |
| `--bytesperline`  | `-b`         | Bytes per `DATA` statement, 1–16     | 16                               |
| `--hex`           | `-x`         | Use hexadecimal `&H00`–`&HFF` values | false                            |
| `--overwrite`     | `-f`         | Replace an existing output file      | false                            |
| `--help`          | `-h`         | Show usage without converting        |                                  |

Boolean options require:

```text
true
```

or:

```text
false
```

Option names are case-sensitive.

Quote paths containing spaces.

For filenames beginning with a hyphen, use an absolute path or prefix the filename with `./`.

## Configuration

Defaults are stored under `ApplicationSettings` in:

```text
appsettings.json
```

The file is copied beside the executable during build and publish.

Command-line options override these settings.

Configuration is located independently of the current working directory.

## What the Converter Does

The converter:

- Reads every byte from a raw binary file
- Preserves the bytes in their original order
- Converts each byte to decimal or hexadecimal BASIC syntax
- Groups the values into numbered `DATA` statements
- Writes the resulting BASIC source file

Zero bytes are preserved, no padding is added and no terminator or sentinel value is inserted.

The converter therefore makes no assumptions about the meaning of the machine code.

## What the Converter Does Not Do

The converter deliberately has a narrow responsibility.

It does **not**:

- Assemble `.asm` source files
- Read Intel HEX or other structured executable formats
- Determine where machine code should be loaded
- Reserve RAM on the RC2014
- Generate a BASIC `READ`/`POKE` loader
- Configure BASIC's `USR` function
- Call the machine-code routine
- Know which ROM, monitor or BASIC implementation is running
- Add padding to make a binary appear at its assembly origin

An assembly-language source file must therefore first be assembled into a raw `.bin` file.

The generated `DATA` statements must then be incorporated into a BASIC program which understands where and how that binary should be loaded.

## The Load Address Matters

A raw binary contains bytes only. It does **not*- normally contain information saying:

> Load these bytes at address `F000`

That information comes from the relationship between the assembly program and the loader.

If assembly source contains:

```asm
ORG 0F000H
```

and the resulting raw binary is intended to execute at `F000`, the BASIC loader must place its first byte at `F000`.

For example:

```basic
FOR I=0 TO 5
READ B
POKE C+I,B
NEXT I
```

requires `C` to represent the address for which the program was assembled.

The converter cannot determine or enforce this relationship because the load address is not present in the raw binary.

## Reserve the RAM First

Machine code must not simply be `POKE`d into memory that BASIC, a monitor, ROM workspace or other software is already using.

Before loading a converted routine:

1. Determine the memory layout of the target RC2014 configuration
2. Identify the addresses required by the machine-code routine and any private data it uses
3. Reserve that area from BASIC where necessary
4. Ensure that the code does not collide with monitor or other resident memory
5. Load the bytes at the address corresponding to their assembly origin

The `Programs/MachineCode` example demonstrates this process for a specific SCM-launched Microsoft BASIC configuration.

Other RC2014 ROM, SCM and BASIC configurations can have different memory layouts and must be treated accordingly.

## Output Format

Output is:

- UTF-8 without a BOM
- LF line endings
- Terminated by a final newline

The default maximum of sixteen bytes per `DATA` statement keeps both decimal and hexadecimal output below 120 characters per line.

Decimal output is the portable default.

Hexadecimal output requires a BASIC dialect which accepts `&H` numeric literals inside `DATA` statements.

## Safe Output Handling

The generated output is first written to a temporary file beside the requested destination.

After successful conversion, the temporary file is renamed into place.

Existing destination files are not replaced unless:

```text
--overwrite true
```

is specified.

## In Short

`MachineCodeConverter` exists to turn this:

```text
3E 2A 32 00 F1 C9
```

into this:

```basic
1000 DATA 62,42,50,0,241,201
```

so that BASIC can turn it back into this:

```text
3E 2A 32 00 F1 C9
```

inside the RC2014's memory.

Which is, admittedly, a slightly roundabout journey.

But if `READ`, `POKE`, machine code and `USR` seem like an entirely reasonable way to spend an afternoon, you are probably in the right repository.
