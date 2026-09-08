# Machine code from BASIC

This example follows the classic retro-computing magazine-style workflow of the late 1970s and early 1980s:

1. Write a small Z80 assembly-language routine
2. Assemble it into machine code
3. Convert the machine-code bytes into BASIC `DATA` statements
4. Reserve a safe area of RAM
5. `READ` and `POKE` the bytes into memory
6. Configure BASIC's `USR` function to call the routine
7. Execute the machine code
8. Read the result back from memory

The final result is deliberately simple:

```text
RESULT = 42
```

There are considerably easier ways of making a computer print 42, but that is not the point!

This README describes the complete process, including how the assembly origin relates to the load address, how to identify and reserve suitable RAM, how the SCM version of Microsoft BASIC implements `USR`, and why BASIC uses negative numbers when accessing some addresses with `PEEK` and `POKE`.

The example assumes that an Apple Mac is being used to assemble the Z80 source into machine code using a cross-assembler. The RC2014 itself runs the resulting BASIC loader and machine code. The same general process can be used with suitable assembler and conversion tools on other development platforms.

## The Assembly Program

The example begins with _example.asm_:

```asm
ORG 0F000H
LD A,42
LD (0F100H),A
RET
```

It does three things:

- `LD A,42` loads decimal 42 into the Z80 accumulator.
- `LD (0F100H),A` writes that byte to memory address `F100` hexadecimal (61700 decimal).
- `RET` returns control to BASIC.

The routine leaves BC, DE, HL and the stack balanced. It changes only A and the result byte at `F100`.

The result is deliberately returned through memory rather than as the numeric value of `USR`.

Loading A with 42 does **not** make `USR(0)` return 42 as a BASIC numeric value. Returning a value directly through `USR` would require following the interpreter's numeric return convention.

In this example, BASIC ignores the value returned by the `USR` function and instead retrieves the result with:

```basic
PEEK(...)
```

### Why `ORG` is there

The first line is:

```asm
ORG 0F000H
```

`ORG` is an **assembler directive**, not a Z80 instruction.

It tells the assembler to calculate addresses as though the first instruction will be placed at `F000` hexadecimal (61440 decimal).

It does **not**:

- Emit an instruction
- Allocate RAM on the RC2014
- Load anything into memory
- Tell BASIC where the program is

The BASIC loader must actually place the assembled bytes at the address for which they were assembled.

The leading zero and trailing `H` are hexadecimal notation accepted by `z80asm`.

This particular routine contains no references to labels in its own code, so changing its origin alone would not change these particular machine-code bytes. `ORG` becomes significant when instructions refer to code or data labels whose addresses depend upon where the routine is loaded.

The explicit result address:

```asm
0F100H
```

is fixed independently of `ORG`.

### What the assembled program looks like

The complete routine occupies only six bytes:

| Address | Hex bytes  | Instruction     |
| ------- | ---------- | --------------- |
| `F000`  | `3E 2A`    | `LD A,42`       |
| `F002`  | `32 00 F1` | `LD (0F100H),A` |
| `F005`  | `C9`       | `RET`           |

The address operand is stored low byte first, so:

```text
00 F1
```

represents address `F100`.

The assembled binary therefore contains six bytes. It is **not** padded with empty data up to address `F000`.

## Install the Z80 Assembler

On the Mac, this example uses `z80asm`.

Check whether it is already installed:

```sh
command -v z80asm
z80asm --version
```

If it is missing, install it using [Homebrew](https://brew.sh/).

If Homebrew itself is not installed, follow its installation instructions first, including any shell setup steps printed by the installer.

Then run:

```sh
brew install z80asm
```

The Homebrew `z80asm` package used here is the standalone assembler. It is distinct from z88dk's similarly named assembler.

## Assemble the Binary

From the RC2014 repository root, run:

```sh
z80asm -o Programs/MachineCode/example.bin Programs/MachineCode/example.asm
```

This produces:

```text
Programs/MachineCode/example.bin
```

A raw `.bin` file contains bytes only. It contains no load-address header telling the RC2014 that those bytes belong at `F000`.

That is why the assembly origin and the address used by the BASIC loader must remain in agreement.

### Inspect the Machine Code

The generated binary can be inspected on the Mac with:

```sh
od -An -tx1 Programs/MachineCode/example.bin
```

The expected result is:

```text
3e 2a 32 00 f1 c9
```

Those are the six bytes shown in the assembly table above.

## Convert the Binary into BASIC DATA

The next step is wonderfully old-fashioned: turn those six machine-code bytes into numbers which BASIC can `READ`.

With the .NET 10 SDK installed, run the following from the repository root:

```sh
dotnet run --project MachineCodeConverter/MachineCodeConverter -- \
  --convert Programs/MachineCode/example.bin \
  --output Programs/MachineCode/example.bas \
  --overwrite true
```

The `--overwrite` option deliberately replaces the existing generated example. Omit it when existing output should be protected.

Using the converter's supplied defaults produces _example.bas_ containing:

```basic
1000 DATA 62,42,50,0,241,201
```

These are exactly the same six machine-code bytes expressed in decimal:

| Hex  | Decimal |
| ---- | ------: |
| `3E` |      62 |
| `2A` |      42 |
| `32` |      50 |
| `00` |       0 |
| `F1` |     241 |
| `C9` |     201 |

For this tutorial, retain the decimal output and line 1000 shown above.

See the [MachineCodeConverter README](../../MachineCodeConverter/README.md) for its numbering and formatting options.

The converter generates the `DATA` statements only. It does not generate the BASIC code which reserves memory, loads the bytes or executes them.

Before doing any of those things, the RC2014's BASIC memory layout must be established.

## Identify the BASIC Memory Layout

Before loading or `POKE`ing machine code, identify the interpreter, derive its workspace addresses from its documentation, and check those addresses using `PEEK`.

The supplied [loader.bas](loader.bas) targets:

```text
SCM-launched Z80 BASIC Ver 4.7b
workspace at 8000 hexadecimal
```

Other BASIC or SCM builds may use different addresses.

### Identify the interpreter

Note:

- How BASIC is started
- Its version banner
- The available-memory figure

On the machine used for this example, entering:

```text
BASIC
```

at SCM's `*` prompt with the default memory limit produces:

```text
Z80 BASIC Ver 4.7b
Copyright (C) 1978 by Microsoft
31427 Bytes free
```

This is consistent with the SCM build whose workspace starts at `8000`.

The banner alone does not identify every build, and the free-memory count changes when memory is reserved. Use the firmware documentation to confirm the layout before choosing addresses.

Other SCM builds use workspace at `4000` or `A000`; the standalone Mini II BASIC ROM has a different layout again.

The official [SCM source distribution](https://smallcomputercentral.com/small-computer-workshop/) contains:

```text
SCMonitor/Apps/MSBASIC_adapted_by_GSearle/SCMon_BASIC.asm
```

which defines the workspace offsets used below.

### Derive the workspace addresses

The SCM source defines:

- The `USR` jump at workspace + `03`
- Its two-byte destination at workspace + `04`
- The memory-top word (`LSTRAM`) at workspace + `AF`

For a workspace beginning at `8000`:

| Item                        | Calculation in hex | Address |
| --------------------------- | ------------------ | ------- |
| USR jump opcode             | `8000 + 03`        | `8003`  |
| USR destination, low byte   | `8000 + 04`        | `8004`  |
| USR destination, high byte  | `8000 + 05`        | `8005`  |
| BASIC memory top, low byte  | `8000 + AF`        | `80AF`  |
| BASIC memory top, high byte | `8000 + B0`        | `80B0`  |

The destination follows the jump opcode and therefore occupies the next two memory locations.

Both the `USR` addresses and memory-top addresses must agree with the selected BASIC build.

Changing only the loader's `USR` guard would leave its other workspace accesses incorrect.

For another interpreter, establish its offsets from its own source or documentation rather than assuming that all Microsoft BASIC-derived builds use these addresses.

## Understand BASIC's Signed Addresses

`PEEK(address)` reads one byte of memory and returns a value from 0 to 255.

`POKE address,value` writes one byte.

The Z80 has 65536 addressable byte locations:

```text
0–65535
```

This BASIC's memory commands can use signed 16-bit representations for addresses in the upper half of that range.

For an unsigned address of 32768 or greater:

```text
signed address = unsigned address - 65536
```

For example:

```text
8003 hex = 32771 decimal; 32771 - 65536 = -32765
8004 hex = 32772 decimal; 32772 - 65536 = -32764
80AF hex = 32943 decimal; 32943 - 65536 = -32593
80B0 hex = 32944 decimal; 32944 - 65536 = -32592
```

The negative value refers to exactly the same physical address. It does **not** mean an address below physical memory.

For this example the important addresses are:

| Purpose                         | Hex address | Signed decimal |
| ------------------------------- | ----------- | -------------: |
| USR jump opcode                 | `8003`      |         -32765 |
| USR destination, low byte       | `8004`      |         -32764 |
| BASIC memory-top word, low byte | `80AF`      |         -32593 |
| Machine code                    | `F000`      |          -4096 |
| Result byte                     | `F100`      |          -3840 |

The memory-top response entered when BASIC starts is a positive decimal number. Signed addresses are used later by `PEEK` and `POKE`.

## Check the Workspace Before Changing Anything

Once workspace `8000` has been confirmed from the firmware documentation, use `PEEK` to inspect the relevant locations without modifying them.

The checks are also available in [peeks.bas](peeks.bas).

At BASIC's `Ok` prompt enter:

```basic
PRINT PEEK(-32765),PEEK(-32764),PEEK(-32763)
PRINT PEEK(-32593)+256*PEEK(-32592)
```

The first command reads:

```text
8003
8004
8005
```

and therefore displays the opcode and two bytes of BASIC's current `USR` jump.

At `8003`, expect decimal:

```text
195
```

which is hexadecimal:

```text
C3
```

the Z80 opcode for an unconditional `JP`.

If it differs, stop and recheck the selected firmware layout before running the loader.

A matching byte is a useful consistency check, not complete ROM identification. Searching RAM for an arbitrary occurrence of decimal 195 cannot identify the `USR` entry.

The two destination bytes depend upon the current `USR` setting. They do not need to contain `0,240` before running this example, and the loader restores their original values afterwards.

### Reading a 16-bit value

The second command reads BASIC's stored memory-top address:

```basic
PRINT PEEK(-32593)+256*PEEK(-32592)
```

A 16-bit word occupies two bytes, low byte first:

```text
word = low byte + 256 * high byte
```

This same calculation will later explain why:

```basic
POKE U,0:POKE U+1,240
```

represents:

```text
0 + 256 * 240 = 61440 = F000 hexadecimal
```

### Rejecting Incorrect Layouts

For comparison, these read-only commands inspect locations used by two other BASIC layouts:

```basic
PRINT PEEK(-32253),PEEK(-32252),PEEK(-32251)
PRINT PEEK(-32696),PEEK(-32695),PEEK(-32694)
```

They read `8203`–`8205` and `8048`–`804A` respectively.

On the machine used for this example they returned:

```text
90   0   130
20   0   0
```

Neither begins with 195, so neither location matches the expected `USR` jump on this machine.

Those results reject the proposed locations. They do not identify the correct location by themselves. The bytes may simply be ordinary BASIC data and may change while BASIC runs.

The loader repeats the expected-opcode check before writing anything and emits this error id the consistency check fails:

```text
UNSUPPORTED USR VECTOR
```

If it appears, complete the identification above rather than removing the guard.

## Reserve RAM for the Machine Code

The machine-code routine cannot simply be `POKE`d into arbitrary memory being used by BASIC.

For this example:

```text
code:   F000–F005
result: F100
```

Both must remain outside BASIC's allocation area and must also avoid memory used by SCM or other resident software.

In other words, reserving memory from BASIC establishes the **lower boundary** of the available machine-code area, but that does not mean that all RAM above that boundary is available. SCM itself occupies part of high RAM, establishing an **upper boundary** which the machine-code routine must not cross.

### Determining the Top of Free Memory

The SCM itself provides an API call specifically for the purpose of returning the top of free memory, API function $28. The [SCM User Guide](https://smallcomputercentral.com/wp-content/uploads/2018/05/scmon-v1-0-userguide-e1-0-0.pdf) states the top of free memory is _typically_ FBFF.

At the SCM `*` prompt, enter:

```text
API 28
```

The output should look similar to this:

```text
28 FBFF
```

In this example, the memory layout would be:

```text
    BASIC allocation           Machine code/data            SCM

... -------------------- | -------------------------- | FC00 ........ FFFF
```

For this small example, the six code bytes at `F000`–`F005` and the result byte at `F100` fit safely within the available region.

For a larger routine, however, the entire machine-code program and all of its private data must fit between BASIC's reserved top and SCM's own memory usage. This means checking both ends of the proposed memory area before choosing `ORG`:

- The **lowest address** used by the routine determines how far BASIC's memory allocation must be reduced
- The **highest address** used by the routine must remain below memory reserved by SCM or other resident software

If a program assembled at `F000` became large enough to extend into SCM's own memory, simply reserving more memory from BASIC would not solve the problem. The routine would need to be relocated lower in RAM — for example, by choosing a lower `ORG` — so that the complete program and its data fit within the available window.

Note that whenever `ORG` is changed, the BASIC load address and `USR` destination must be changed to match.

### Choose the Memory Limit

Before choosing BASIC's memory limit, confirm that the proposed machine-code routine fits within the free RAM reported by SCM. For this example, `API 28` returns:

```text
28 FBFF
```

so `FBFF` is the highest address SCM reports as available. The machine code begins at its assembly origin:

```text
F000
```

The total address window available from the load address up to SCM's reported limit is therefore:

```text
FBFF - F000 + 1 = 0C00 bytes = 3072 bytes
```

The `+ 1` is required because both `F000` and `FBFF` are included in the available range.

This does **not** mean that the example itself occupies 3072 bytes. Its machine-code binary is only six bytes long. The calculation establishes the maximum address range available to the routine and any private data beginning at `F000`.

Next determine the highest address actually used by the routine.

In this example:

```text
machine code: F000–F005
result byte:  F100
```

Although the binary itself ends at `F005`, the result byte means that the highest address used by the complete routine is `F100`.

Compare that with the value returned by SCM:

```text id="05jb58"
highest address used = F100
SCM top of free RAM  = FBFF
F100 <= FBFF
```

The complete routine therefore fits safely below SCM's reserved memory.

For a simple contiguous machine-code program containing `N` bytes and loaded at `ORG`, its final address can be calculated as:

```text
last address = ORG + N - 1
```

For example, this six-byte binary loaded at `F000` ends at:

```text
F000 + 6 - 1 = F005
```

If the routine also uses buffers, tables, result locations or other private data outside the binary itself, include those addresses as well. The **highest address used anywhere by the routine**, rather than merely the end of the `.bin` file, must be no greater than the top of free memory returned by `API 28`.

Having established the upper boundary, determine BASIC's lower boundary.

Start with the **lowest address occupied by the machine-code routine or any of its private data**. Do not simply calculate the end of the binary.

In this example, code starts at `F000` and the result is written to `F100`, so the lowest address is `F000`, or 61440 decimal.

A conservative memory-top response is therefore:

```text id="e00ejf"
61440 - 1 = 61439
```

and 61439 should be entered at BASIC's _Memory top?_ prompt.

This keeps BASIC's allocation below the first machine-code byte while the earlier `API 28` check confirms that the routine also remains below SCM's reserved memory.

For another machine-code routine:

1. Use SCM `API 28` to determine the highest currently free RAM address
2. Identify the lowest and highest addresses used by the routine, including code, buffers, tables and result locations
3. Confirm that the highest address used is no greater than the value returned by `API 28`
4. Set BASIC's memory limit below the lowest address used
5. Ensure the `ORG`, BASIC load address and `USR` destination agree

If the routine will not fit below the SCM limit, reserving additional memory from BASIC will not help: the routine must instead be relocated lower in RAM or made smaller.

### Why BASIC Must be Cold-Started

Make the reservation with a fresh `BASIC` start from SCM **before** loading the program.

`WBASIC` resumes the previous allocation.

`CLEAR` by itself is not a substitute for choosing a new memory top.

The startup `Bytes free` figure is BASIC's available capacity after its own overheads. It is not an address to enter or `POKE`.

### Verify the Stored Memory Limit

After BASIC starts, check its stored memory-top value:

```basic
PRINT PEEK(-32593)+256*PEEK(-32592)
```

The inspected SCM BASIC source decrements an explicitly entered address once in `TSTMEM` and again in `SETTOP` before storing `LSTRAM`.

Consequently, this source build stores:

```text
61437
```

or hexadecimal:

```text
EFFD
```

after an entry of 61439.

A read-back two bytes below the number entered is therefore expected on this build.

The example deliberately retains that small extra margin. Its loader requires the stored top to be _below_ 61440 rather than equal to the number entered.

Do not assume that this adjustment applies to every BASIC dialect or ROM revision.

The machine-code area is now ready for the loader.

## How BASIC Calls the Machine Code

Before looking at the complete loader, it is useful to understand what `USR` actually does here.

`USR` is BASIC's function for calling a user-supplied machine-code routine.

In this example:

```basic
R=USR(0)
```

does **not** mean:

> Run the routine at address zero

The argument `0` is a parameter to `USR`, not the address of the routine.

This machine-code routine ignores that parameter.

The address to execute is instead configured through BASIC's `USR` jump.

### The USR jump

For this SCM BASIC build, the `USR` entry is a three-byte Z80 jump instruction stored in RAM.

After the loader configures it for this example, the bytes are:

| Address | Byte | Meaning               |
| ------- | ---- | --------------------- |
| `8003`  | `C3` | Z80 `JP` opcode       |
| `8004`  | `00` | destination low byte  |
| `8005`  | `F0` | destination high byte |

Together they represent:

```asm
JP 0F000H
```

The Z80 stores the low byte first, so:

```text
00 F0
```

represents address `F000`.

The loader changes only the two destination bytes:

```basic
POKE U,0:POKE U+1,240
```

where `U` represents address `8004`.

Decimal 240 is hexadecimal `F0`.

The existing `C3` opcode at `8003` remains unchanged.

When BASIC evaluates:

```basic
USR(0)
```

execution reaches this jump instruction, which transfers control to the machine-code routine at `F000`.

The routine executes:

```asm
LD A,42
LD (0F100H),A
RET
```

and `RET` returns control to BASIC.

BASIC can then retrieve the result from `F100`.

### Preserve the Existing USR Destination

The loader does not permanently commandeer BASIC's existing `USR` destination.

Before changing it, it saves the original low and high bytes:

```basic
OL=PEEK(U):OH=PEEK(U+1)
```

- `OL` saves the old low byte at `8004`.
- `OH` saves the old high byte at `8005`.

It then installs the address `F000` and calls the routine:

```basic
POKE U,0:POKE U+1,240
R=USR(0)
```

After the machine code returns, it restores the original destination:

```basic
POKE U,OL:POKE U+1,OH
```

This leaves BASIC's `USR` destination as it was before the example ran.

Saving and restoring it is not strictly necessary for this tiny example, but it is desirable housekeeping. Without doing so, subsequent `USR` calls would continue to jump to the example routine at `F000`.

## Load and Execute the Program

Everything is now in place.

Transfer _loader.bas_ to the RC2014, including the generated `DATA` line:

```basic
10 REM SCM BASIC WORKSPACE 8000 - COLD START MEMORY TOP 61439
20 IF PEEK(-32765)<>195 THEN PRINT "UNSUPPORTED USR VECTOR":END
30 MT=PEEK(-32593)+256*PEEK(-32592)
40 IF MT>61439 THEN PRINT "COLD START WITH MEMORY TOP 61439":END
50 C=-4096:P=-3840:U=-32764
60 RESTORE
70 FOR I=0 TO 5
80 READ B:POKE C+I,B
90 NEXT I
100 POKE P,0
110 IF PEEK(P)<>0 THEN PRINT "RESULT RAM NOT WRITABLE":END
120 OL=PEEK(U):OH=PEEK(U+1)
130 POKE U,0:POKE U+1,240
140 R=USR(0)
150 POKE U,OL:POKE U+1,OH
160 PRINT "RESULT =";PEEK(P)
170 END
1000 DATA 62,42,50,0,241,201
```

Use this as a standalone program. `RESTORE` causes the subsequent `READ` to begin at the first `DATA` statement.

### What the Loader Does

The loader performs the complete RC2014 side of the process:

1. It checks that `8003` contains decimal 195 (`C3`), the expected `JP` opcode
2. It reads BASIC's stored memory top and verifies that the machine-code area has been reserved
3. It sets:
   - `C` to `F000`, the code address
   - `P` to `F100`, the result address
   - `U` to `8004`, the first byte of the `USR` destination
4. It reads the six decimal values from the `DATA` statement
5. It `POKE`s those bytes into `F000`–`F005`
6. It clears the result byte at `F100` and verifies that the location is writable
7. It saves BASIC's existing `USR` destination
8. It changes the destination to `F000`
9.  It evaluates `USR(0)`, executing the machine-code routine
10. It restores BASIC's previous `USR` destination
11. It reads the result from `F100` with `PEEK`

Enter:

```basic
RUN
```

The machine-code routine is called, writes decimal 42 to `F100`, returns to BASIC, and BASIC prints:

```text
RESULT = 42
```

And there it is: Z80 assembly converted into six machine-code bytes, encoded as decimal numbers in a BASIC `DATA` statement, `POKE`d into RAM and executed with `USR`.

Just as nature intended!

## If the Program Is Interrupted

The loader normally restores BASIC's original `USR` destination immediately after the machine-code routine returns.

If BASIC is interrupted after the new destination has been installed but before it has been restored, and `OL` and `OH` still contain their saved values, restore the destination in immediate mode with:

```basic
POKE -32764,OL:POKE -32763,OH
```

If those variables have been lost, cold-start BASIC again.

The memory reservation remains in effect until another cold start.

## Modifying the Example

If _example.asm_ is changed:

1. Reassemble it
2. Regenerate the BASIC `DATA` statements
3. Update the loader's byte count
4. Update its exact-byte verification checks
5. Ensure that all code and private data still lie within memory reserved from BASIC

If the code origin changes, keep these three addresses consistent:

- The `ORG 0F000H` instruction in the assembly code
- The address where the BASIC loading loop puts the machine-code bytes into RAM, `F000`
- The temporary assignment to BASIC's `USR` destination, `F000`

If the routine uses additional buffers or result locations, include those when calculating the required memory reservation.

Remember that the **lowest** address used by the routine or its private data determines where BASIC's allocation must end.

Also verify the highest address used, so that the routine does not collide with SCM or other resident software.

For a different BASIC interpreter or SCM build, derive its workspace addresses from the appropriate documentation or source rather than reusing the `8000`-workspace offsets assumed by this loader.

## Verified Configuration

The assembly and `DATA` conversion were checked on the Mac.

The corrected loader was also run successfully on the SCM-launched BASIC described here and produced:

```text
RESULT = 42
```

The verified configuration is therefore:

```text
BASIC:          Z80 BASIC Ver 4.7b launched from SCM
Workspace:      8000
USR jump:       8003
USR destination:8004–8005
Memory top word:80AF–80B0
Code origin:    F000
Result byte:    F100
Startup limit:  61439
Machine code:   3E 2A 32 00 F1 C9
```

## References

- [Homebrew](https://brew.sh/)
- [SCM User Guide](https://smallcomputercentral.com/wp-content/uploads/2018/05/scmon-v1-0-userguide-e1-0-0.pdf)
- [SCM Source Distribution](https://smallcomputercentral.com/small-computer-workshop/)
