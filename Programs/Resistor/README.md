# Resistor Colour Code Calculator

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Resistor/resistor.png" alt="Resistor Colour Code Calculator" width="600">

Resistor Colour Code Calculator is a terminal utility for decoding and creating three-, four-, five- and six-band resistor colour codes. It can also display the colour mappings relevant to the selected resistor type.

## Hardware

The program requires:

- An RC2014 Mini II running BASIC
- A serial terminal for instructions and results

No additional hardware is required.

## Program Files

| File           | Description                                               |
| -------------- | --------------------------------------------------------- |
| `resistor.bas` | Interactive resistor colour-code reference and calculator |

## Running the Program

Load `resistor.bas` into BASIC and enter `RUN`.

The program starts in four-band mode and immediately displays the applicable reference table. Then choose an operation:

- Show the applicable colour tables.
- Enter a resistance in ohms and produce its colour bands.
- Enter colour bands and calculate the resistance.

Colour-to-value mode displays the applicable colour-code table again before prompting for the first band.

Enter `B` at the main menu to select a three-, four-, five- or six-band resistor. The program displays the new reference table immediately after the selection. Enter `Q` to return to BASIC.

## Entering Colours

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Resistor/bands-to-value.png" alt="Converting Colour Bands to a Value" width="600">

Colour codes are case-insensitive. The codes avoid the ambiguity between black and blue and between green and grey.

| Code | Colour | Code | Colour |
| ---- | ------ | ---- | ------ |
| `BK` | Black  | `BU` | Blue   |
| `BR` | Brown  | `VT` | Violet |
| `RD` | Red    | `GY` | Grey   |
| `OR` | Orange | `WH` | White  |
| `YL` | Yellow | `GD` | Gold   |
| `GN` | Green  | `SR` | Silver |

Enter `?` at a colour prompt to display the code list. The program rejects colours that are not valid for the requested band position.

## Band Meanings

| Bands | Meaning from left to right                                        |
| ----- | ----------------------------------------------------------------- |
| 3     | Two digits, multiplier; tolerance is implicitly plus or minus 20% |
| 4     | Two digits, multiplier, tolerance                                 |
| 5     | Three digits, multiplier, tolerance                               |
| 6     | Three digits, multiplier, tolerance, temperature coefficient      |

For example, red-green-orange-gold is 25,000 ohms with plus or minus 5% tolerance. Yellow-blue-black-orange-brown is 460,000 ohms with plus or minus 1% tolerance.

## Value Conversion

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Resistor/value-to-bands.png" alt="Converting a Value to Colour Bands" width="600">

Enter resistance as a positive value in ohms. Three- and four-band codes represent values from 0.1 to 990,000,000 ohms. Five- and six-band codes represent values from 1 to 9,990,000,000 ohms.

When the input contains more significant digits than the selected band count can hold, the program rounds it to the nearest representable value and displays that represented value. Results are shown in ohms and in a compact form using `K`, `M` or `G` where appropriate.

At the tolerance prompt, enter a listed colour code or press Return to omit the tolerance band. When it is omitted, the result does not display or report a tolerance. In six-band mode the temperature-coefficient prompt is also skipped, because a temperature coefficient is the sixth band and requires the tolerance band before it.

The multiplier choices follow the supplied project reference and include silver and gold through violet. Grey and white multiplier bands are not included.

## Implementation Notes

Colour names and codes are read from a compact `DATA` table. Shared routines perform case-insensitive lookup, validate each band according to its purpose, translate multiplier exponents and format results. Value conversion scales the entered resistance until it obtains the two or three significant digits required by the selected resistor type.

The reference uses one row per colour, with digit, multiplier, tolerance and, for six-band resistors, temperature-coefficient columns shown together. It uses fixed text and semicolon-separated output, so it does not depend on ANSI support or terminal tab settings.

## References

- [IEC 60062:2016 — Marking codes for resistors and capacitors](https://webstore.iec.ch/en/publication/25395), International Electrotechnical Commission
