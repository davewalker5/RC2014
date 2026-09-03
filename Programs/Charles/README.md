# Charles the Feisty Octopus

Charles is a small virtual octopus for the RC2014. Phase 1 implements his internal needs and lets them change autonomously over time.

## Hardware

The program requires:

- An RC2014 Mini II running BASIC
- A serial terminal for diagnostic output

No additional hardware is required for Phase 1.

## Program Files

| File          | Description                                      |
| ------------- | ------------------------------------------------ |
| `charles.bas` | Simulates Charles's changing internal need state |

## Running the Program

Load `charles.bas` into BASIC and enter `RUN`. The program needs no input and continues until interrupted with Ctrl-C.

Every five simulation ticks, it prints Charles's hunger, happiness, energy, boredom, and irritation. Each value is kept in the range 0 to 255. The `NEEDS` line shows when the values imply that Charles is hungry, bored, tired, or cross.

The timing is approximate because it uses a processor delay loop. Change `DL` on line 30 to adjust the interval between simulation ticks, or `DI` on line 40 to adjust how often the state is printed.

## State Model

Hunger and boredom rise over time, while energy falls at a slower interval. Happiness initially settles towards a neutral value and then falls when hunger or boredom remains high. Irritation normally fades, but prolonged hunger makes it rise.

The displayed conditions use configurable thresholds near the start of the program. Charles becomes cross when he is both very hungry and unhappy. These derived conditions expose the Phase 1 model without introducing the behavioural state machine and messages planned for Phase 2.

## Implementation Notes

The simulation clock, display interval, and energy interval use separate counters. This keeps the rate of state change independent from the diagnostic output frequency and allows later phases to add animation and interaction on their own schedules.
