# Charles the Feisty Octopus

<img src="https://github.com/davewalker5/RC2014/blob/charles/Programs/Charles/charles.gif" alt="Charles" width="600">

Charles is a small virtual octopus for the RC2014. The Phase 5 text version provides needs, moods, opinions, interaction, memory, personality, spontaneous behaviour, and diagnostics. Phase 6 adds his LCD habitat and animation.

## Hardware

The text version requires:

- An RC2014 Mini II running BASIC
- A serial terminal for diagnostic output

The LCD version additionally requires:

- An RC2014 LCD Driver Module
- A compatible two-line character LCD, configured for 16 characters per line

## Program Files

| File               | Description                             |
| ------------------ | --------------------------------------- |
| `charles_text.bas` | Complete text implementation of Charles |
| `charles_lcd.bas`  | Phase 6 LCD implementation of Charles   |

## Running the Program

Load the required program, from the table above, into BASIC and enter `RUN`.

For the LCD version, connect the LCD Driver Module, load `charles_lcd.bas`, and enter `RUN`. Continue to enter actions through the serial terminal.

At startup, the program displays its title,  and the available controls. At each action prompt, enter one of these letters:

| Key | Action                                        |
| --- | --------------------------------------------- |
| F   | Feed Charles                                  |
| P   | Play with Charles                             |
| T   | Pet Charles                                   |
| A   | Annoy Charles                                 |
| W   | Wait without interacting                      |
| D   | Show a snapshot of the current internal state |
| Q   | Quit cleanly                                  |

Uppercase and lowercase letters are accepted. Invalid input displays the valid choices and repeats the prompt.

Charles normally displays concise mood updates, actions, and opinions. Press `D` to print the complete internal state at that moment. The snapshot is shown once; subsequent output remains concise. Each need value is kept in the range 0 to 255.

The timing is approximate because it uses processor delay loops. In the LCD version, `DL` on line 30 controls the delay between animation frames and `DI` on line 40 controls how many simulation ticks occur between action prompts. `MI` on line 50 adjusts the normal interval between Charles's messages.

## State Model

Hunger and boredom rise over time, while energy falls at a slower interval. Happiness initially settles towards a neutral value and then falls when hunger or boredom remains high. Irritation normally fades, but prolonged hunger makes it rise.

The displayed conditions use configurable thresholds near the start of the
program. Charles becomes cross when he is both very hungry and unhappy.

## Behaviour and Messages

Charles selects one of six explicit moods: content, bored, hungry, cross, feisty, or sleepy. Feisty represents high irritation while Charles still has enough energy to argue. Low energy ultimately makes him sleepy. A mood change produces an immediate message; otherwise Charles speaks at the configured message interval.

Each state has three context-sensitive messages. A pseudo-random choice varies what Charles says, while the previous state and message number prevent an immediate repeat within the same mood.

## Interaction

Feeding reduces hunger and usually improves happiness and energy, but Charles refuses food when he is already full. Playing reduces boredom and improves happiness at an energy cost, although Charles may refuse when hungry or tired. Petting usually improves happiness and reduces irritation, but a cross Charles objects. Annoying him reduces happiness and sharply increases irritation.

Responses use Charles's mood and needs from before the action, so the same choice can produce a different result as his condition changes. Updated values and mood are displayed immediately after an action.

## Memory and Personality

Charles remembers the most recent action, how many times it has been repeated, and how many annoy actions occurred recently. Waiting or choosing a different action breaks a repetition chain. Recent annoyance fades gradually, rather than being forgotten immediately.

Repeated petting eventually crosses Charles's randomly chosen patience limit and produces `STOP THAT`. Repeated play can also exhaust his patience. Annoying him repeatedly causes progressively larger happiness and irritation changes, with escalating responses.

At startup, narrow pseudo-random ranges determine Charles's base feistiness, patience, appetite, and sociability. These biases affect his cross threshold, food acceptance, tolerance for repetition, and response to petting while keeping him recognisably Charles.

## Spontaneous Behaviour

Every 15 simulation ticks Charles experiences one pseudo-random event. He may notice something interesting, disapprove for no stated reason, find a tiny crab, or perform a somersault. Events make small changes to his needs.

Small pseudo-random variations also affect metabolism and the consequences of accepted interactions. Need thresholds and mood priorities still dominate, so randomness modifies understandable behaviour rather than replacing it.

## Debug Snapshot

The one-shot debug table shows:

- Simulation tick and current mood
- Active needs
- Hunger, happiness, energy, boredom, and irritation
- Last action number, repetition count, and recent annoyance count
- Feistiness, patience, appetite, and sociability biases

The output is divided into current state, memory, and personality sections.

Action numbers are `1` feed, `2` play, `3` pet, and `4` annoy. Pressing `W` clears the repeated-action chain but does not immediately erase recent annoyance.

## Configuration and Tuning

Configuration values are grouped at the beginning of the program:

- `DL` controls the text-version delay or LCD animation-frame delay.
- `DI` controls the number of ticks between action prompts.
- `MI` controls periodic messages.
- `SI` controls spontaneous events.
- `NH`, `NB`, and `NE` are the hungry, bored, and low-energy thresholds.
- `CH` and `CM` define need-driven crossness.
- `FI` is the irritation threshold for feisty behaviour.

The delay is processor-based and approximate. It may need adjustment for a particular RC2014 clock speed. Personality-adjusted `CI` is calculated during startup and should not be configured directly.

## Hardware Guidance

The text version uses only a serial terminal and does not access hardware I/O ports. The LCD version uses port 218 (`0xDA`) for commands and port 219 (`0xDB`) for character data. These values are assigned to `LR` and `LD` on line 290 of `charles_lcd.bas` and can be changed for another configuration.

Digital I/O controls are deferred to the final hardware-input phase. Phase 6 continues to use terminal keyboard input.

## LCD Display

Only Charles's output is sent to the LCD:

- Line one shows the current mood and animated octopus.
- Line two shows Charles's comments and reactions.

The title, instructions, action menu, validation errors, wait confirmation, debug snapshots, and quit confirmation remain on the serial terminal. Comments longer than 16 characters are shortened or clipped to the display width.

At startup, the LCD version loads the existing three octopus frames into custom character slots 0 to 2. Animation cycles through all three frames during each simulation update. Charles also moves between positions 10 and 15 on the first line, without overwriting the mood text. His position, direction, and animation frame are tracked separately.

For responsiveness, normal animation updates rewrite only the octopus cell. The previous cell is also cleared when Charles moves. The complete first line is redrawn only when his mood changes. The default action interval is two simulation ticks, or six animation frames.

The LCD is configured for an eight-bit interface, two lines, a 5-by-8 font, incrementing writes, and no visible cursor. A conservative delay follows each command and data write.

## Implementation Notes

The simulation clock, diagnostic display, energy update, and message timing use separate counters. The action prompt uses standard `INPUT` for compatibility with both RC2014 Microsoft BASIC and command-line BASIC interpreters. The simulation pauses while that prompt is waiting; choose `W` to let time continue.
