# ISA Atmosphere Calculator

Calculate International Standard Atmosphere (ISA) temperature, pressure, and density for an altitude in the troposphere.

This program is educational and recreational. It is not suitable for operational flight planning, navigation, or aircraft performance calculations.

## Hardware

The program requires:

- An RC2014 Mini II running BASIC
- A serial terminal

No additional hardware is required.

## Program Files

| File                 | Description                                                   |
| -------------------- | ------------------------------------------------------------- |
| `isa_atmosphere.bas` | Calculates standard temperature, pressure, and air density    |

## Running the Programs

Load the required program from the table, above, into BASIC and enter `RUN`.

### ISA Atmosphere

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Atmosphere/isa_atmosphere.png" alt="ISA Atmosphere Calculation" width="600">

Enter an altitude in feet between -2,000 and 36,089. The program displays:

- Standard temperature in degrees Celsius
- Standard pressure in hectopascals (hPa)
- Standard density in kilograms per cubic metre (kg/m3)

After displaying the result, enter `Y` to perform another calculation or `N` to finish.

## Mathematics

The program uses the ISA equations for the troposphere, where temperature decreases at a constant rate with altitude. Altitude in feet is first converted to metres:

$$h = h_{ft} \times 0.3048$$

For sea-level temperature $T_0 = 288.15\ \mathrm{K}$, sea-level pressure $p_0 = 1013.25\ \mathrm{hPa}$, and lapse rate $L = 0.0065\ \mathrm{K/m}$, temperature is:

$$T = T_0 - Lh$$

Pressure is calculated using the tropospheric barometric formula:

$$p = p_0 \left(\frac{T}{T_0}\right)^{5.25588}$$

Density follows from the ideal gas law using the specific gas constant for dry air, $R = 287.05\ \mathrm{J/(kg\,K)}$:

$$\rho = \frac{100p}{RT}$$

The factor of 100 converts pressure from hPa to pascals.

## Verification

Representative values from the ISA troposphere equations are:

| Altitude (feet) | Temperature (C) | Pressure (hPa) | Density (kg/m3) |
| --------------- | --------------- | -------------- | --------------- |
| 0               | 15.0            | 1013.3         | 1.225           |
| 5,000           | 5.1             | 843.1          | 1.056           |
| 10,000          | -4.8            | 696.8          | 0.905           |
| 20,000          | -24.6           | 465.6          | 0.653           |
| 30,000          | -44.4           | 300.9          | 0.458           |
| 36,089          | -56.5           | 226.3          | 0.364           |

Displayed values are rounded to the nearest 0.1 degree Celsius, 0.1 hPa, and 0.001 kg/m3. Exact results may differ slightly because of the target BASIC's floating-point precision.

## Implementation Notes

### ISA Atmosphere

The calculation covers only the ISA troposphere, from -2,000 to 36,089 feet. It treats the entered altitude directly as model altitude; it does not convert geometric altitude to geopotential altitude. This small approximation is appropriate to the program's educational purpose.

ISA values describe an idealised standard atmosphere, not observed weather. The program does not account for local pressure, humidity, temperature variation, or changing conditions, and must not be used to determine aircraft performance or safe operating limits.

## References

- [International Civil Aviation Organization, Manual of the ICAO Standard Atmosphere, Doc 7488](https://store.icao.int/en/manual-of-the-icao-standard-atmosphere-extended-to-80-kilometres-262-500-feet-doc-7488)
- [NASA Glenn Research Center, Earth Atmosphere Model](https://www.grc.nasa.gov/www/k-12/airplane/atmosmet.html)
- [U.S. Standard Atmosphere, 1976](https://ntrs.nasa.gov/citations/19770009539)
