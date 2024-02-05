# RC2014 Digital I/O Card

<img src="https://github.com/davewalker5/RC2014/blob/main/Applications/DigitalIO/led.gif" alt="LED Pattern Display" width="600">

_Digital I/O card mounted on the RC2014 Mini II running the LED pattern display program_

The Digital I/O card is an additional kit plugging into the 40 pin bus header of the RC2014 Mini II and providing 8 lines of digial input via keys mounted on the card and 8 lines of digital output via LEDs, also mounted on the card (see the referencesfor details).

This folder contains applications that make use of the RC2014 digital I/O card:

| Filename     | Application                                                                                                   |
| ------------ | ------------------------------------------------------------------------------------------------------------- |
| pattern.bas  | Enter a pattern of 1s and 0s to determine the value to write to the I/O card to match the pattern on the LEDs |
| keypress.bas | Read keypresses on the I/O card to toggle on/off the corresponding LED                                        |
| led.bas      | Given a set of DATA statements defining the LED pattern sequence, repeatedly display that pattern             |

## References

- [RC204 Digital I/O](https://rc2014.co.uk/modules/digital-io/), RC2014
