# RC2014 Moon Descent

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/MoonDescent/moon_descent.png" alt="RC2014 Moon Descent" width="600">

Moon Descent is a turn-based descent simulation for the RC2014. Control the lander's thrust, conserve its limited fuel and reach the surface at a safe velocity.

## Hardware

The program requires:

- An RC2014 Mini II running Microsoft BASIC
- A serial terminal

No additional hardware is required. The display uses plain text and does not require ANSI terminal support.

## Program Files

| File               | Description                             |
| ------------------ | --------------------------------------- |
| `moon_descent.bas` | RC2014 Moon Descent simulation and game |

## Running the Program

Load `moon_descent.bas` into BASIC and enter `RUN`.

## How to Play

The lander begins 500 altitude units above the surface with 120 fuel units. On each turn the program displays altitude, downward velocity and remaining fuel, then asks for a whole-number thrust setting from 0 to 10.

- Gravity adds 5 velocity units per turn
- Thrust subtracts its setting from that acceleration
- A setting of 5 holds velocity steady
- A setting above 5 slows the descent
- The chosen setting is consumed from the remaining fuel
- If no fuel remains, thrust is automatically set to 0

The aim is to balance braking against fuel use. Waiting too long can leave too little altitude to slow down, while thrusting too early can waste fuel or send the lander upwards.

## Landing Assessment

The touchdown velocity determines the result:

| Downward velocity | Result                              |
| ----------------- | ----------------------------------- |
| 0 to 2            | Perfect landing                     |
| Over 2 to 5       | Good landing; the crew is safe      |
| Over 5 to 10      | Hard landing; the lander is damaged |
| Over 10           | Crash                               |

When a turn crosses the surface, the program estimates the velocity at the touchdown point within that turn rather than using the velocity at the end of the full turn.

## Implementation Notes

The simulation uses simple constant acceleration for one turn at a time. If `A` is altitude, `V` is downward velocity and `G` is the net acceleration, the next altitude is calculated as `A - V - G / 2`, and the next velocity as `V + G`. Net acceleration is gravity minus the selected thrust.

All input ranges are checked before fuel or flight state is changed. After the landing assessment, the player may start another flight or leave the program.

## Acknowledgements

RC2014 Moon Descent acknowledges the long history of computerised moon-landing simulations, from the early text-based programs of the late 1960s and 1970s to Atari's 1979 arcade game. Those works helped establish limited fuel, player-set thrust and landing velocity as enduring ideas in this genre.

## Independence and Trademarks

RC2014 Moon Descent is an original, independently written RC2014 program. It is not affiliated with, endorsed by or sponsored by Atari Interactive, Inc. or any other publisher of a moon-landing game.

The program contains no Atari source code, artwork, logos, sounds, screen or cabinet designs, messages, wording or other creative assets. Its BASIC source, plain-text presentation, numerical model, rules text and documentation were written specifically for this project. Atari and its game titles and marks remain the property of their respective owners.

## References

- [Lunar Lander (video game genre)](https://en.wikipedia.org/wiki/Lunar_Lander_(video_game_genre)), Wikipedia
- [Equations for a falling body](https://www.grc.nasa.gov/www/k-12/airplane/mofall.html), NASA Glenn Research Center
