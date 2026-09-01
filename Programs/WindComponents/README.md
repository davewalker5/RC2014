# Wind Component Calculator

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/WindComponents/wind_components.png" alt="Headwind, Tailwind and Crosswind Calculation" width="600">

Calculate the headwind or tailwind component and the left or right crosswind component for an entered runway heading and wind.

This program is educational and recreational. It is not suitable for operational flight planning or navigation.

## Hardware

The program requires:

- An RC2014 Mini II running BASIC
- A serial terminal

No additional hardware is required.

## Program Files

| File                  | Description                                               |
| --------------------- | --------------------------------------------------------- |
| `wind_components.bas` | Calculates wind components for an entered runway and wind |

The supplied `runways.csv` contains reference headings for the four runway directions at London Heathrow. The BASIC program is not limited to those runways and does not load the CSV file.

## Running the Program

Load `wind_components.bas` into BASIC and enter `RUN`.

Enter:

1. The runway magnetic heading from 0 to 359 degrees.
2. The direction from which the wind is blowing, from 0 to 359 degrees.
3. The wind speed in knots.

For example, for Heathrow runway 09L, wind 180 degrees at 20 knots, enter a runway heading of 89, a wind direction of 180, and a wind speed of 20. The result is approximately 0.3 knots of tailwind and 20 knots of crosswind from the right.

## Mathematics

Let $R$ be the runway heading, $W$ the reported wind direction, and $V$ the wind speed. The relative wind angle is:

$$A = W - R$$

The components are:

$$\text{headwind} = V\cos(A)$$

$$\text{crosswind} = V\sin(A)$$

A positive longitudinal result is a headwind and a negative result is a tailwind. A positive crosswind result is wind from the right; a negative result is wind from the left.

The program converts degrees to radians before using BASIC's `SIN` and `COS` functions. Displayed component magnitudes are rounded to the nearest tenth of a knot.

## Verification

Representative test cases are:

| Runway | Wind      | Expected result                                      |
| ------ | --------- | ---------------------------------------------------- |
| 090    | 090 at 20 | 20.0-knot headwind; no crosswind                     |
| 090    | 270 at 20 | 20.0-knot tailwind; no crosswind                     |
| 090    | 180 at 20 | No headwind/tailwind; 20.0-knot crosswind from right |
| 090    | 000 at 20 | No headwind/tailwind; 20.0-knot crosswind from left  |
| 270    | 225 at 20 | 14.1-knot headwind; 14.1-knot crosswind from left    |

Very small floating-point residuals may round to zero. Exact displayed formatting may vary with the target BASIC.

## Implementation Notes

Runway heading and wind direction must be at least 0 and less than 360 degrees. Wind speed must not be negative. Decimal values are accepted.

The wind direction follows the aviation convention: it states where the wind is coming from. Runway headings and wind directions must use the same reference, normally magnetic values taken from an aerodrome chart and an aviation weather report.

## References

- [FAA Airplane Flying Handbook, Chapter 9: Approaches and Landings](https://www.faa.gov/sites/faa.gov/files/regulations_policies/handbooks_manuals/aviation/airplane_handbook/10_afh_ch9.pdf), crosswind component chart
- [UK NATS Type A Charts](https://nats-uk.ead-it.com/cms-nats/opencms/en/Charts/type-a-charts/), source for the Heathrow runway headings in `runways.csv`
