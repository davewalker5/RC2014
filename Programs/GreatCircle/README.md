# Great Circle Distance Calculator

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/GreatCircle/great_circle.png" alt="Great Circle Distance Calculator" width="600">

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/GreatCircle/airports.png" alt="Airport Distance Calculator" width="600">

Calculate the shortest distance over the Earth's surface between two positions, or list distances from one position to a selection of airports.

## Hardware

The programs require:

- An RC2014 Mini II running BASIC
- A serial terminal

No additional hardware is required.

## Program Files

| File               | Description                                                        |
| ------------------ | ------------------------------------------------------------------ |
| `great_circle.bas` | Manual great circle distance calculator for two entered positions  |
| `airports.bas`     | Lists distances from an entered position to 19 embedded airports   |

The supplied `airports.csv` contains the source airport data used by `airports.bas`.

## Running the Programs

Load either `great_circle.bas` or `airports.bas` into BASIC and enter `RUN`.

Enter latitudes in decimal degrees from -90 to 90 and longitudes in decimal degrees from -180 to 180. North and east are positive; south and west are negative.

The manual calculator displays the distance in nautical miles and kilometres. The airport calculator displays a table in nautical miles.

## Mathematics

Both programs use the haversine formula. For latitudes $\varphi_1$ and $\varphi_2$ and longitude difference $\Delta\lambda$, all expressed in radians:

$$a = \sin^2\left(\frac{\varphi_2-\varphi_1}{2}\right) + \cos(\varphi_1)\cos(\varphi_2)\sin^2\left(\frac{\Delta\lambda}{2}\right)$$

$$c = 2\tan^{-1}\left(\sqrt{\frac{a}{1-a}}\right)$$

Distance is $3440.065c$ nautical miles, using a mean Earth radius of 3440.065 nautical miles. One nautical mile is 1.852 kilometres.

## Implementation Notes

`airports.bas` reads and processes one `DATA` record at a time. It does not use an array, so all 19 airports from the supplied CSV fit without reserving memory for the complete table.

Small floating-point rounding errors can place the haversine intermediate just outside its valid range of zero to one. Both programs clamp it to that range before calculating the angular distance.

The programs still require transfer and verification on a physical RC2014 Mini II, including a final check of available memory.

## References

- [Great-circle distance](https://en.wikipedia.org/wiki/Great-circle_distance), Wikipedia
- [Calculate distance and bearing between two Latitude/Longitude points](https://www.movable-type.co.uk/scripts/latlong.html), Movable Type Scripts
