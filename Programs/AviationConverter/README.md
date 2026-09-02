# Aviation Unit Converter

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/AviationConverter/aviation_converter.png" alt="Aviation Unit Converter" width="600">

Convert commonly encountered aviation distances, altitudes, speeds, and temperatures between aviation, imperial, and metric units.

This program is educational and recreational. It is not suitable for operational flight planning or navigation.

## Hardware

The program requires:

- An RC2014 Mini II running BASIC
- A serial terminal

No additional hardware is required.

## Program Files

| File                     | Description                                      |
| ------------------------ | ------------------------------------------------ |
| `aviation_converter.bas` | Menu-driven converter for aviation-related units |

## Running the Program

Load `aviation_converter.bas` into BASIC and enter `RUN`.

Choose a conversion by entering its menu number, then enter the value to convert. Press Return after a result to return to the menu, or choose `0` to exit.

The program provides conversions in both directions for:

- Nautical miles and statute miles
- Nautical miles and kilometres
- Feet and metres
- Knots and miles per hour
- Knots and kilometres per hour
- Degrees Celsius and degrees Fahrenheit

## Conversion Factors

The program uses the international definitions:

| Conversion            | Factor or formula         |
| --------------------- | ------------------------- |
| 1 nautical mile       | 1.852 kilometres          |
| 1 nautical mile       | 1.15077945 statute miles  |
| 1 foot                | 0.3048 metres             |
| 1 knot                | 1.15077945 miles per hour |
| 1 knot                | 1.852 kilometres per hour |
| Celsius to Fahrenheit | `(C * 9 / 5) + 32`        |
| Fahrenheit to Celsius | `(F - 32) * 5 / 9`        |

Results are rounded to three decimal places. BASIC may omit trailing zeroes when displaying a number.

## Verification

Representative test cases are:

| Conversion | Input | Expected output |
| ---------- | ----: | --------------: |
| NM to km   |     1 |        1.852 km |
| km to NM   | 1.852 |        1.000 NM |
| NM to mi   |   100 |      115.078 mi |
| ft to m    |  1000 |       304.800 m |
| m to ft    |  1000 |     3280.840 ft |
| kt to mph  |   100 |     115.078 mph |
| kt to km/h |   100 |    185.200 km/h |
| C to F     |     0 |        32.000 F |
| F to C     |   212 |       100.000 C |

These results follow directly from the exact international definitions and the temperature formulae above, rounded to three decimal places.

## Implementation Notes

Distances and speeds cannot be negative. Feet and metres accept negative values because aviation altitudes and elevations may be below their reference datum. Temperature input is checked against absolute zero.

The program uses a shared rounding subroutine and keeps all conversion constants near the beginning of the source. Its text-only menu permits repeated conversions without reloading the program.

## References

- [BIPM SI Brochure, 9th edition](https://www.bipm.org/en/publications/si-brochure), definitions of the metre and accepted non-SI units
- [NIST Handbook 44, Appendix C](https://www.nist.gov/pml/owm/si-units-information), general tables of units of measurement
- [International Civil Aviation Organization, Units of Measurement to be Used in Air and Ground Operations](https://store.icao.int/en/annex-5-units-of-measurement-to-be-used-in-air-and-ground-operations)
