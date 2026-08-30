# Moon Phase Calculator

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/MoonPhase/MoonPhase.png" alt="Moon Phase Calculator" width="600">

Calculate the phase of the moon for a specified date.

## Hardware

The program requires:

- An RC2014 computer running BASIC
- A serial terminal

No additional hardware is required.

## Program Files

| Filename      | Content                                     |
| ------------- | ------------------------------------------- |
| MoonPhase.bas | Implementation of the moon phase calculator |

Load `MoonPhase` into BASIC and enter `RUN`

## Lunar Phase Calculation

The following method is used to calculate the phase of the moon:

1. Calculate the Julian date for the date entered
2. Subtract the Julian date for a known reference date when there was a New Moon
3. Calculate the number of lunar cycles represented by the remainder
4. The fractional part of the answer represents the fraction of the current lunar cycle
5. Use this to calculate the lunar age
6. Map the lunar age onto a description of the Moon's phase

## References

- [What Are the Moon's Phases?](https://spaceplace.nasa.gov/moon-phases/en/), NASA
- [Calculate the Moon Phase](https://www.subsystems.us/uploads/9/8/9/4/98948044/moonphase.pdf), SubsySTEMs.us
