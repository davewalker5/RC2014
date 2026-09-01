# Bearing Calculators

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Bearings/initial_bearing.png" alt="Bearing Between Start and End Points" width="600">

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Bearings/airport_bearing_distance.png" alt="Airport-to-Airport Bearing and Distance" width="600">

Calculate the initial great-circle bearing between entered positions, or calculate the bearing and distance between two built-in airports.

These programs are educational and recreational. They are not suitable for operational flight planning or navigation.

## Hardware

The programs require:

- An RC2014 Mini II running BASIC
- A serial terminal

No additional hardware is required.

## Program Files

| File                           | Description                                                        |
| ------------------------------ | ------------------------------------------------------------------ |
| `initial_bearing.bas`          | Calculates the initial bearing between two entered positions       |
| `airport_bearing_distance.bas` | Calculates distance and initial bearing between selected airports  |

## Running the Programs

Load either BASIC file and enter `RUN`.

For `initial_bearing.bas`, enter two positions in decimal degrees. Latitudes must be from -90 to 90 and longitudes from -180 to 180. North and east are positive; south and west are negative.

For `airport_bearing_distance.bas`, enter the three-letter uppercase IATA codes of the departure and destination airports. The program displays the available codes. Its 19-airport list and coordinates are identical to those in `Programs/GreatCircle/airports.bas`.

Results are reported in degrees true and, for the airport program, nautical miles. The bearing describes the direction on departure; it generally changes while following a great-circle route.

## Mathematics

For latitudes $\varphi_1$ and $\varphi_2$ and longitude difference $\Delta\lambda$, all expressed in radians, the initial bearing is:

$$\theta = \operatorname{atan2}(\sin(\Delta\lambda)\cos(\varphi_2),\cos(\varphi_1)\sin(\varphi_2)-\sin(\varphi_1)\cos(\varphi_2)\cos(\Delta\lambda))$$

The result is converted to degrees and normalised to the range 0 to less than 360 degrees. Because RC2014 Microsoft BASIC provides `ATN` rather than `atan2`, the programs explicitly select the correct quadrant.

The airport program calculates distance using the haversine formula and a mean Earth radius of 3440.065 nautical miles, matching the Great Circle programs.

## Verification

Representative reference results, calculated with double-precision spherical formulae, are:

| Route       | Distance       | Initial bearing |
| ----------- | -------------- | --------------- |
| LHR to CDG  | 187.7 NM       | 140.8 degrees   |
| LHR to DUB  | 242.6 NM       | 301.3 degrees   |
| MAN to AMS  | 262.9 NM       | 100.9 degrees   |

Exact displayed values may differ slightly because of the target BASIC's floating-point precision.

## Implementation Notes

The airport program reads the `DATA` table from the beginning for each lookup and retains only the selected coordinates. This avoids reserving arrays for the full table.

An initial bearing is undefined when both positions are identical or exactly antipodal. The programs report this rather than displaying an arbitrary direction.

## References

- [Calculate distance and bearing between two Latitude/Longitude points](https://www.movable-type.co.uk/scripts/latlong.html), Movable Type Scripts
- [Great-circle navigation](https://en.wikipedia.org/wiki/Great-circle_navigation), Wikipedia
