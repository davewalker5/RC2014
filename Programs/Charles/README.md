# Charles the Feisty Octopus

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Charles/charles.jpg" alt="Charles" width="600">

Charles is a small virtual octopus for the RC2014 with needs, moods, opinions, interaction, memory, personality, spontaneous behaviour, and diagnostics.

Three versions are provided: a text-only implementation; an LCD-based version that gives Charles an animated habitat on the LCD display; and an LCD + Digital I/O version that adds physical button controls and LED feedback.

## Inspiration

Charles was inspired by Peter Godfrey-Smith's *Other Minds*, and in particular its discussion of experiments investigating octopus behaviour and intelligence.

The name comes from Charles, one of three octopuses used in an early learning experiment by Peter Dews. While the other octopuses learned to operate a lever for food reasonably cooperatively, Charles took a rather different approach: he applied enough force to bend and eventually break the lever, repeatedly interfered with a lamp above the tank, and had a tendency to direct jets of water out of the tank.

Other anecdotes in *Other Minds* reinforce this picture of curious, individual and sometimes decidedly uncooperative animals. One captive octopus in New Zealand apparently took a dislike to a particular member of the laboratory staff and would direct around half a gallon of water at the back of her neck when she passed its tank.

That combination of curiosity, individuality, unpredictability and apparent mischief provided the inspiration for this Charles.

The program makes no attempt to simulate real octopus cognition or behaviour. Instead, it borrows the idea of an opinionated and somewhat unpredictable octopus as the basis for a deliberately playful RC2014 application built around state, memory, personality, spontaneous behaviour, interaction and an animated LCD character.

## Hardware

| File                     | RC2014 (*) | Digital I/O | LCD Driver | SID-Ulator Sound Card |
| ------------------------ | ---------- | ----------- | ---------- | --------------------- |
| `charles_text.bas`       | Yes        | No          | No         | No                    |
| `charles_lcd.bas`        | Yes        | No          | Yes        | No                    |
| `charles_lcd_io.bas`     | Yes        | Yes         | Yes        | No                    |
| `charles_lcd_sid.bas`    | Yes        | No          | Yes        | Yes                   |
| `charles_lcd_io_sid.bas` | Yes        | Yes         | Yes        | Yes                   |

(*) The RC2014 should be running BASIC

## Program Files

| File                     | Description                                                                       |
| ------------------------ | --------------------------------------------------------------------------------- |
| `charles_text.bas`       | Complete text implementation of Charles                                           |
| `charles_lcd.bas`        | Implementation that shows habitat and animation on the LCD display                |
| `charles_lcd_io.bas`     | Implementation that, additionally, accepts user input via the Digital I/O card    |
| `charles_lcd_sid.bas`    | Implementation of `charles_lcd.bas` with sound support via the SID-Ulator card    |
| `charles_lcd_io.bas`     | Implementation that, additionally, accepts user input via the Digital I/O card    |
| `charles_lcd_io_sid.bas` | Implementation of `charles_lcd_io.bas` with sound support via the SID-Ulator card |

## Running the Program

Load the required program, from the table above, into BASIC and enter `RUN`.

For the LCD version, connect the LCD Driver Module, load `charles_lcd.bas`, and enter `RUN`. Continue to enter actions through the serial terminal.

For physical controls, connect both hardware modules, load
`charles_lcd_io.bas`, and enter `RUN`. This version runs continuously and does
not display an action prompt. Use the quit button for a clean exit, or press
Ctrl-C at the terminal to interrupt it.

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

The four lowest Digital I/O input bits are used for input via the Digital I/O card:

| Input value | Action                                |
| ----------- | ------------------------------------- |
| 1           | Feed Charles                          |
| 2           | Play with Charles                     |
| 4           | Pet Charles                           |
| 8           | Annoy Charles                         |
| 65          | Show a debug snapshot on the terminal |
| 128         | Quit cleanly                          |

Press only one button at a time. The program waits for release and applies a
short debounce delay before accepting another action. A simultaneous press is
ignored and reported on the serial terminal.

Charles normally displays concise mood updates, actions, and opinions. Press `D` to print the complete internal state at that moment. The snapshot is shown once; subsequent output remains concise. Each need value is kept in the range 0 to 255.

The timing is approximate because it uses processor delay loops. In the LCD version, `DL` on line 30 controls the delay between animation frames and `DI` on line 40 controls how many simulation ticks occur between action prompts. `MI` on line 50 adjusts the normal interval between Charles's messages.

## State Model

Hunger and boredom rise over time, while energy falls at a slower interval. Happiness initially settles towards a neutral value and then falls when hunger or boredom remains high. Irritation normally fades, but prolonged hunger makes it rise.

The displayed conditions use configurable thresholds near the start of the program. Charles becomes cross when he is both very hungry and unhappy.

Mood is derived from these underlying needs rather than stored independently, allowing several competing conditions to exist at the same time while one dominates Charles's current behaviour.

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

The result is that separate runs produce slightly different versions of Charles without turning his behaviour into unrestricted randomness.

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

The LCD version continues to use terminal keyboard input while the LCD + Digital I/O version reads physical buttons from port 1, assigned to `IP` on line 290 of `charles_lcd_io.bas`. The program writes zero to this port during startup so the card's LEDs remain off.

## LCD Display

Only Charles's output is sent to the LCD:

- Line one shows the current mood and animated octopus.
- Line two shows Charles's comments and reactions.

The title, instructions, action menu, validation errors, wait confirmation, debug snapshots, and quit confirmation remain on the serial terminal. Comments longer than 16 characters are shortened or clipped to the display width.

At startup, the LCD version loads the existing three octopus frames into custom character slots 0 to 2. Animation cycles through all three frames during each simulation update. Charles also moves between positions 10 and 15 on the first line, without overwriting the mood text. His position, direction, and animation frame are tracked separately.

For responsiveness, normal animation updates rewrite only the octopus cell. The previous cell is also cleared when Charles moves. The complete first line is redrawn only when his mood changes. The default action interval is two simulation ticks, or six animation frames.

The LCD is configured for an eight-bit interface, two lines, a 5-by-8 font, incrementing writes, and no visible cursor. A conservative delay follows each command and data write.

## Digital I/O Input

The LCD + Digital I/O version processes Digital I/O during every animation frame, so Charles continues to animate and his needs continue changing when the user does nothing.

To avoid missing a short press while BASIC is writing to the comparatively slow LCD, the program also samples the input four times during every LCD delay. A valid value is stored in a one-byte software latch and processed at the next animation poll, even if the button has already been released.

The button is captured, mapped to an action, processed using the same rules as the earlier versions, and then held until release. The latch is cleared after release so a held button cannot accidentally produce a second action. Repeated-action memory is cleared after ten simulation ticks without an action. Recent annoyance still fades according to its own timer.

When a valid button is accepted, the corresponding LED is illuminated using the same byte value as the input. It remains visible while Charles processes the action, then all LEDs are cleared after the button is released. A short latched press therefore still produces a visible feedback flash.

Debug value 65 and quit value 128 use the same feedback mechanism. The debug button prints the one-shot state table without leaving a persistent mode. The quit button gives Charles a final LCD comment, clears every Digital I/O LED, prints `GOODBYE` on the terminal, and ends the program.

Change `IP` on line 290 if the Digital I/O card uses another port. Change `DD` on line 40 if physical testing shows that the release debounce should be longer or shorter.

## Inspiration and Further Reading

- Peter Godfrey-Smith, *Other Minds: The Octopus, the Sea, and the Deep Origins of Consciousness* (2016).

## SID-Ulator sound versions

`charles_lcd_sid.bas` copies the LCD/terminal version, and
`charles_lcd_io_sid.bas` copies the LCD/Digital I/O version, adding the
rising triangle chirp from `Programs/Sound/chirp.bas` and the falling pulse
grumble from `Programs/Sound/grumble.bas`. The original versions
remain available. Load the chosen SID version and enter `RUN` as usual.
These versions additionally require the SID-Ulator configured for D4/D5
(decimal 212/213).

Charles chirps every 24 animation frames while his mood is `CONTENT`
(the program's happy state), and immediately when another mood changes back
to `CONTENT`. A startup chirp also plays as the first LCD comment is written. Each
sound resets the periodic counter. Charles grumbles when he enters `CROSS`
or `FEISTY` (including transitions between those two moods), and every 48
animation frames while he remains in either mood. Actions such as annoyance
can trigger a grumble by causing those mood changes. Hungry, bored and sleepy
moods are quiet. Any mood change releases the previous sound before starting
the new one, if applicable.

Small routines at lines 9200 onwards initialise, start, advance and release
voice 1. Pitch advances within short slices of existing LCD delays and during
frame delays, rather than waiting for a complete LCD write or animation frame.
This keeps the rising notes close together. The chirp sweep uses 2000-unit steps,
ending at 16000, to make it faster than the original integration. Pitch
register values are prepared once at startup; playback writes the stored bytes
directly, avoiding frequency arithmetic and nested subroutine calls between notes. The total LCD delay-loop iteration
count is preserved, although the additional BASIC checks add some overhead.
There are no separate waits for sound playback. The Digital I/O version also advances sound
while waiting for button release. Timing depends on CPU speed and the work
being done, so the integrated chirp may differ in duration from the standalone
example. No interrupt handler is required.

The grumble uses the prototype's 25 percent pulse width, attack and release,
and 2400-to-1000 frequency sweep in steps of 100. It advances every second
sound-service call for a slower growl. Line 9616 controls this spacing.
Both effects share voice 1, with the waveform and envelope restored each time
an effect starts. A new mood sound replaces the previous effect.

The terminal version releases sound before `INPUT`, allowing its fade to
finish while waiting for an answer; an unfinished chirp can therefore be
shortened by a prompt. Periodic chirps count animation frames, not time spent
waiting for terminal input. Both versions mute the SID on a clean quit.
Ctrl-C bypasses that cleanup; use `OUT 212,24 : OUT 213,0` to mute manually.

Set `SV` on line 9210 for volume (0-15), and `SP` on line 9220 for the number
of happy animation frames between chirps. `SG` on line 9225 sets cross/feisty
frames between grumbles. Both intervals must be positive whole numbers.
Startup clears the SID registers, and these versions use voice 1 for sound.
