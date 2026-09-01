# Wind Correction and Groundspeed Calculators

Calculate the heading required to maintain a desired track in wind, or calculate the ground track and groundspeed produced by a selected aircraft heading and wind.

These programs are educational and recreational. They are not suitable for operational flight planning or navigation.

## Hardware

The programs require:

- An RC2014 Mini II running BASIC
- A serial terminal

No additional hardware is required.

## Program Files

| File                  | Description                                                         |
| --------------------- | ------------------------------------------------------------------- |
| `wind_correction.bas` | Calculates heading and groundspeed for a desired track              |
| `groundspeed.bas`     | Calculates resulting ground track and speed for an aircraft heading |

## Running the Programs

Load either BASIC file and enter `RUN`.

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/WindCorrection/wind_correction.png" alt="Wind Correction Calculator" width="600">

For `wind_correction.bas`, enter the desired true track, true airspeed, wind direction, and wind speed. The program reports the signed wind-correction angle, required true heading, and groundspeed. A negative correction means steer left of track; a positive correction means steer right.

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/WindCorrection/groundspeed.png" alt="Groundspeed Calculator" width="600">

For `groundspeed.bas`, enter the aircraft's true heading and true airspeed, followed by wind direction and speed. The program reports the resulting true ground track and groundspeed.

Directions must be from 0 to less than 360 degrees. Speeds are entered in knots. Wind direction follows the aviation convention and states where the wind comes from. All directions must use the same reference; these programs use true directions in their prompts.

## Mathematics

For desired track $T$, true airspeed $A$, wind-from direction $W$, and wind speed $V$, the wind-correction angle is:

$$C = \arcsin\left(\frac{V}{A}\sin(W-T)\right)$$

The required heading and resulting groundspeed are:

$$H = T+C$$

$$G = A\cos(C)-V\cos(W-T)$$

The correction program reports that the track cannot be maintained if the required crosswind correction exceeds the aircraft's true airspeed or if the resulting forward groundspeed is not positive.

The groundspeed program treats the aircraft and wind as north/east vectors. Because reported wind direction is where the wind comes from, its velocity vector points in the opposite direction:

$$N=A\cos(H)+V\cos(W+180^\circ)$$

$$E=A\sin(H)+V\sin(W+180^\circ)$$

$$G=\sqrt{N^2+E^2}$$

The ground track is $\operatorname{atan2}(E,N)$, normalised from 0 to less than 360 degrees. The BASIC programs implement inverse sine and `atan2` using the available `ATN` function.

## Verification

Representative results calculated independently from the vector formulae are:

| Inputs                               | Expected result                        |
| ------------------------------------ | -------------------------------------- |
| Track 090, TAS 100, wind 000 at 20   | Heading 078.5; groundspeed 98.0 knots  |
| Track 090, TAS 100, wind 090 at 20   | Heading 090.0; groundspeed 80.0 knots  |
| Track 000, TAS 100, wind 180 at 20   | Heading 000.0; groundspeed 120.0 knots |
| Heading 090, TAS 100, wind 000 at 20 | Track 101.3; groundspeed 102.0 knots   |
| Heading 090, TAS 100, wind 270 at 20 | Track 090.0; groundspeed 120.0 knots   |

Displayed values are rounded to the nearest tenth. Exact results may differ slightly because of the target BASIC's floating-point precision.

## Implementation Notes

The programs reject directions outside the supported range, non-positive airspeeds, and negative wind speeds. If equal and opposite aircraft and wind vectors produce zero groundspeed, `groundspeed.bas` reports that the ground track is undefined.

The calculations assume steady wind, constant true airspeed, and motion over a flat local plane. They do not account for magnetic variation, wind changes, aircraft performance, or navigation errors.

## References

- [FAA Pilot's Handbook of Aeronautical Knowledge, Chapter 16: Navigation](https://www.faa.gov/sites/faa.gov/files/18_phak_ch16.pdf), wind triangle and flight planning
- [Wind triangle](https://en.wikipedia.org/wiki/Wind_triangle), vector relationship between air and ground velocities
