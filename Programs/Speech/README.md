# Hello Z80 Speech Demo

This BASIC program makes the MG005 speech synthesiser say “Hello Z80,” with
“Z80” pronounced “zed eighty.” It sends allophone codes to the SP0256-AL2 chip
and waits for the chip to be ready before sending each one.

## Hardware

The programs require:

- An RC2014 Mini II running BASIC
- An MG005 speech synthesiser

## Program Files

| File                   | Description                                                                      |
| ---------------------- | -------------------------------------------------------------------------------- |
| `allophone_player.bas` | Prompts for a string of space-separate allophones and plays them on the MG005    |
| `exterminate.bas`      | Says the Dalek catch-phrase, “Exterminate”, through the MG005 speech synthesiser |
| `hello_z80.bas`        | Says “Hello Z80” through the MG005 speech synthesiser                            |

## Running the Program

Load the required program from the table, above, into BASIC and enter `RUN`. The phrase is spoken once.

## Acknowledgements

The MG005 port and ready-bit protocol follow
[Kevin's SP0256A-AL2 BASIC example](https://diyelectromusic.com/2025/08/02/sp0256a-al2-speech-synthesis/)

## References

- [SP0256-AL2 allophone codes](https://fddrsn.net/pcomp/examples/SP0256/sp0256code-allophones.html)
