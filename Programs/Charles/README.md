# Charles the Feisty Octopus

Charles is a small virtual octopus for the RC2014. Phases 1 to 3 implement his
internal needs, behavioural moods, opinions, and keyboard interaction.

## Hardware

The program requires:

- An RC2014 Mini II running BASIC
- A serial terminal for diagnostic output

No additional hardware is required for Phases 1 to 3.

## Program Files

| File               | Description                                     |
| ------------------ | ----------------------------------------------- |
| `charles_text.bas` | Simulates Charles's needs, moods, and interaction |

## Running the Program

Load `charles_text.bas` into BASIC and enter `RUN`. The program runs until it
is interrupted with Ctrl-C at an action prompt.

At startup, the program displays its title, the implemented phase, and the
available controls. At each action prompt, enter one of these letters:

| Key | Action |
| --- | ------ |
| F   | Feed Charles |
| P   | Play with Charles |
| T   | Pet Charles |
| A   | Annoy Charles |
| W   | Wait without interacting |

Uppercase and lowercase letters are accepted. Invalid input displays the valid
choices and repeats the prompt.

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

Charles selects one of five explicit moods: content, bored, hungry, cross, or
sleepy. More urgent conditions take priority, with low energy ultimately making
him sleepy. A state change produces an immediate message; otherwise Charles
speaks at the configured message interval.

Each state has three context-sensitive messages. A pseudo-random choice varies
what Charles says, while the previous state and message number prevent an
immediate repeat within the same mood.

## Interaction

Feeding reduces hunger and usually improves happiness and energy, but Charles
refuses food when he is already full. Playing reduces boredom and improves
happiness at an energy cost, although Charles may refuse when hungry or tired.
Petting usually improves happiness and reduces irritation, but a cross Charles
objects. Annoying him reduces happiness and sharply increases irritation.

Responses use Charles's mood and needs from before the action, so the same
choice can produce a different result as his condition changes. Updated values
and mood are displayed immediately after an action.

## Implementation Notes

The simulation clock, diagnostic display, energy update, and message timing use
separate counters. The action prompt uses standard `INPUT` for compatibility
with both RC2014 Microsoft BASIC and command-line BASIC interpreters. The
simulation pauses while that prompt is waiting; choose `W` to let time continue.
