# Charles the Feisty Octopus

Charles is a small virtual octopus for the RC2014. Phases 1 and 2 implement
his autonomous internal needs, behavioural states, and opinions.

## Hardware

The program requires:

- An RC2014 Mini II running BASIC
- A serial terminal for diagnostic output

No additional hardware is required for Phases 1 and 2.

## Program Files

| File               | Description                                     |
| ------------------ | ----------------------------------------------- |
| `charles_text.bas` | Simulates Charles's needs, states, and messages |

## Running the Program

Load `charles_text.bas` into BASIC and enter `RUN`. The program needs no input and continues until interrupted with Ctrl-C.

At startup, the program displays its title, the implemented phase, and the
available controls. Phases 1 and 2 are autonomous, so there are currently no
user actions other than pressing Ctrl-C to stop. Feed, play, pet, and annoy
controls are planned for Phase 3.

Every five simulation ticks, it prints Charles's hunger, happiness, energy,
boredom, irritation, and current behavioural state. Each need value is kept in
the range 0 to 255. The `NEEDS` line shows when the values imply that Charles
is hungry, bored, tired, or cross.

The timing is approximate because it uses a processor delay loop. Change `DL`
on line 30 to adjust the interval between simulation ticks, `DI` on line 40 to
adjust how often the state is printed, or `MI` on line 50 to adjust the normal
interval between Charles's messages.

## State Model

Hunger and boredom rise over time, while energy falls at a slower interval. Happiness initially settles towards a neutral value and then falls when hunger or boredom remains high. Irritation normally fades, but prolonged hunger makes it rise.

The displayed conditions use configurable thresholds near the start of the
program. Charles becomes cross when he is both very hungry and unhappy.

## Behaviour and Messages

Charles selects one of five explicit states: content, bored, hungry, cross, or
sleepy. More urgent conditions take priority, with low energy ultimately making
him sleepy. A state change produces an immediate message; otherwise Charles
speaks at the configured message interval.

Each state has three context-sensitive messages. A pseudo-random choice varies
what Charles says, while the previous state and message number prevent an
immediate repeat within the same state.

## Implementation Notes

The simulation clock, diagnostic display, energy update, and message timing use
separate counters. This keeps the rates independent and allows later phases to
add animation and interaction on their own schedules.
