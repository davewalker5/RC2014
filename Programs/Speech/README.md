# Hello Z80 Speech Demo

This BASIC program makes the MG005 speech synthesiser say “Hello Z80,” with
“Z80” pronounced “zed eighty.” It sends allophone codes to the SP0256-AL2 chip
and waits for the chip to be ready before sending each one.

## Hardware

The programs require:

- An RC2014 Mini II running BASIC
- An MG005 speech synthesiser

## Program Files

| File            | Description                                           |
| --------------- | ----------------------------------------------------- |
| `hello_z80.bas` | Says “Hello Z80” through the MG005 speech synthesiser |

## Running the Program

Load `hello_z80.bas` into BASIC and enter `RUN`. The phrase is spoken once.

## Implementation Notes

The `DATA` statement contains the allophone sequence `HH1 EH LL OW`, `ZZ EH DD1`, `EY TT2 IY`, with pause codes between words and at the end. The loop reads each code, waits until the ready bit is set, then writes the code.

## Acknowledgements

The MG005 port and ready-bit protocol follow
[Kevin's SP0256A-AL2 BASIC example](https://diyelectromusic.com/2025/08/02/sp0256a-al2-speech-synthesis/)

## References

- [SP0256-AL2 allophone codes](https://fddrsn.net/pcomp/examples/SP0256/sp0256code-allophones.html)
