# Atmospheric Calculators

Calculate International Standard Atmosphere (ISA) conditions for an altitude, or estimate pressure altitude from field elevation and QNH.

This program is educational and recreational. It is not suitable for operational flight planning, navigation, or aircraft performance calculations.

## Hardware

The program requires:

- An RC2014 Mini II running BASIC
- A serial terminal

No additional hardware is required.

## Program Files

| File                    | Description                                                |
| ----------------------- | ---------------------------------------------------------- |
| `isa_atmosphere.bas`    | Calculates standard temperature, pressure, and air density |
| `pressure_altitude.bas` | Estimates pressure altitude from field elevation and QNH   |

## Running the Programs

Load the required program from the table, above, into BASIC and enter `RUN`.

### ISA Atmosphere

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Atmosphere/isa_atmosphere.png" alt="ISA Atmosphere Calculation" width="600">

Enter an altitude in feet between -2,000 and 36,089. The program displays:

- Standard temperature in degrees Celsius
- Standard pressure in hectopascals (hPa)
- Standard density in kilograms per cubic metre (kg/m3)

After displaying the result, enter `Y` to perform another calculation or `N` to finish.

### Pressure Altitude

Pressure altitude is the altitude at which the same pressure would occur in the International Standard Atmosphere. Another practical way to describe it is the approximate altitude that an aircraft altimeter would indicate if it were set to the standard pressure setting of 1013.25 hPa rather than the current local QNH.

For example, consider an airfield at a location with an elevation of 210 feet and a QNH of 1020 hPa. The airfield really is 210 feet above mean sea level, but 1020 hPa is higher than standard sea-level pressure. Its atmospheric pressure therefore corresponds to a lower altitude in the standard atmosphere. Using this program's approximation, the pressure altitude is about 11 feet.

This does **not** mean that the airfield or aircraft is only 11 feet above sea level. It means that, in pressure terms, the atmosphere at the airfield resembles the standard atmosphere at approximately that altitude.

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Atmosphere/pressure_altitude.png" alt="Pressure Altitude Calculation" width="600">

When prompted, enter the field elevation in feet between -2,000 and 20,000, followed by the QNH pressure setting in hPa between 800 and 1,100. The program displays the estimated pressure altitude rounded to the nearest foot.

Pressure altitude is higher than field elevation when QNH is below standard pressure, and lower than field elevation when QNH is above standard pressure.

Pilots use pressure altitude when calculating aircraft performance and when referring to flight levels with the standard pressure setting selected. It also provides the starting point for density altitude, which additionally accounts for non-standard temperature. Actual aircraft performance depends on the applicable aircraft data and current conditions, not this educational calculator.

## Mathematics

### ISA Atmosphere

The program uses the ISA equations for the troposphere, where temperature decreases at a constant rate with altitude. Altitude in feet is first converted to metres:

$$h = h_{ft} \times 0.3048$$

For sea-level temperature $T_0 = 288.15\ \mathrm{K}$, sea-level pressure $p_0 = 1013.25\ \mathrm{hPa}$, and lapse rate $L = 0.0065\ \mathrm{K/m}$, temperature is:

$$T = T_0 - Lh$$

Pressure is calculated using the tropospheric barometric formula:

$$p = p_0 \left(\frac{T}{T_0}\right)^{5.25588}$$

Density follows from the ideal gas law using the specific gas constant for dry air, $R = 287.05\ \mathrm{J/(kg\,K)}$:

$$\rho = \frac{100p}{RT}$$

The factor of 100 converts pressure from hPa to pascals.

### Pressure Altitude

The pressure-altitude program uses the common aviation approximation of 1,000 feet per inch of mercury. As one inch of mercury is approximately 33.864 hPa, this is about 29.53 feet per hPa.

For field elevation $E$ in feet and QNH pressure setting $Q$ in hPa, pressure altitude is estimated as:

$$h_p = E + (1013.25 - Q) \times 29.53$$

Standard pressure is $1013.25\ \mathrm{hPa}$. A lower QNH therefore adds to pressure altitude, while a higher QNH subtracts from it.

## Verification

### ISA Atmosphere

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

### Pressure Altitude

Representative values calculated from the documented approximation are:

| Field elevation (feet) | QNH (hPa) | Pressure altitude (feet) |
| ---------------------- | --------- | ------------------------ |
| 0                      | 1013.25   | 0                        |
| 500                    | 1000      | 891                      |
| 1,500                  | 1020      | 1,301                    |
| 5,000                  | 980       | 5,982                    |
| -100                   | 1030      | -595                     |

Results are rounded to the nearest foot.

## Implementation Notes

### ISA Atmosphere

The calculation covers only the ISA troposphere, from -2,000 to 36,089 feet. It treats the entered altitude directly as model altitude; it does not convert geometric altitude to geopotential altitude. This small approximation is appropriate to the program's educational purpose.

ISA values describe an idealised standard atmosphere, not observed weather. The program does not account for local pressure, humidity, temperature variation, or changing conditions, and must not be used to determine aircraft performance or safe operating limits.

### Pressure Altitude

The pressure-altitude calculation is a rule-of-thumb estimate based on QNH, not an exact conversion of measured station pressure through the full ISA model. It assumes the entered pressure is a correctly determined QNH setting and does not account for non-standard temperature, humidity, or local weather variation.

The accepted input limits catch likely entry errors; they do not define safe aircraft or altimeter operating limits.

## References

- [International Civil Aviation Organization, Manual of the ICAO Standard Atmosphere, Doc 7488](https://store.icao.int/en/manual-of-the-icao-standard-atmosphere-extended-to-80-kilometres-262-500-feet-doc-7488)
- [NASA Glenn Research Center, Earth Atmosphere Model](https://www.grc.nasa.gov/www/k-12/airplane/atmosmet.html)
- [U.S. Standard Atmosphere, 1976](https://ntrs.nasa.gov/citations/19770009539)
- [FAA Pilot's Handbook of Aeronautical Knowledge, Chapter 8: Flight Instruments](https://www.faa.gov/sites/faa.gov/files/10_phak_ch8.pdf)
