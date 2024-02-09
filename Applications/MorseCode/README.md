# Morse Code Translator

<img src="https://github.com/davewalker5/RC2014/blob/main/Applications/MorseCode/morse.gif" alt="Morse Code Sender" width="600">

_Digital I/O card mounted on the RC2014 Mini II running the Morse Code sender program. The message is "Hi" (.... ..) and the animation repeats in a loop_

Two Morse Code applications are included:

| Filename            | Description                                                                                   |
| ------------------- | --------------------------------------------------------------------------------------------- |
| morse_translate.bas | Prompt for a message then convert it to morse code using the rules outlined below             |
| morse_sender.bas    | As per the translator but uses the Digital I/O card to display the resulting code on the LEDs |

The following timing rules are used to determine the lengths of dots, dashes and spaces:

- Dots are 1 time unit long
- Dashes are 3 time units long
- Spaces between . or - within a word are 1 time unit long
- Spaces between characters are 3 time units long
- Spaces between words are 7 time units long

In the text-based output, a single space corresponds to 1 time unit.

## References

- [International Morse Code](https://morsecode.world/international/morse2.html), Morse Code World, Stephen C. Phillips
- [Recommendation ITU-R M.1677-1](https://www.itu.int/dms_pubrec/itu-r/rec/m/R-REC-M.1677-1-200910-I!!PDF-E.pdf), International Telecommunications Union, 2009
- [Recommendation ITU-R M.1172](https://www.itu.int/dms_pubrec/itu-r/rec/m/R-REC-M.1172-0-199510-I!!PDF-E.pdf), International Telecommunications Union
