# Conway's Game of Life

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Life/life.gif" alt="Conway's Game of Life" width="600">

_Conway's Game of Life running the 'Glider' pattern_

An original BASIC implementation of Conway's Game of Life for the RC2014 Mini II. Life is a two-dimensional cellular automaton in which simple local rules produce evolving patterns.

This implementation uses a modest configurable grid to keep successive generations responsive on the target computer. It provides both plain-text output and optional ANSI in-place animation.

## Hardware

The program requires:

- An RC2014 Mini II running BASIC
- A serial terminal

No additional hardware is required. ANSI mode requires a terminal that supports ANSI cursor-control sequences; plain-text mode does not.

## Program Files

| File       | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| `life.bas` | Game of Life with plain-text and optional ANSI display modes |

## Running the Program

Load `life.bas` into BASIC and enter `RUN`.

The program asks whether to use ANSI display mode, which starting pattern to use, and how many generations to show. The initial state is generation zero and is included in that number. The supplied patterns are a glider, blinker, toad, and beacon. Select manual entry to define another pattern by entering each live cell as `row,column`; enter `0,0` when the pattern is complete.

In plain-text mode, each generation is printed below the preceding generation. In ANSI mode, the display is cleared once and each new generation replaces the previous one.

## Rules

Each cell is either alive (`#`) or dead (a space). All cells are updated simultaneously for the next generation:

- A live cell survives when it has two or three live neighbours.
- A dead cell becomes alive when it has exactly three live neighbours.
- Every other cell is dead in the next generation.

The eight horizontally, vertically, and diagonally adjacent cells are the neighbours. Cells beyond the edge of the finite grid are always dead; the grid does not wrap around.

## Implementation Notes

The current and next generations are held in separate numeric arrays. An extra permanently dead cell surrounds the active grid, allowing the program to count all eight neighbours without performing boundary tests for every cell.

The grid width (`W`) and height (`H`) are configured on line 10. Array bounds, display borders, manual-entry prompts, and supplied pattern positions are derived from those values. A grid of at least 6 by 6 is required for every supplied pattern to fit. Increasing the dimensions increases memory use and the calculation time for every generation.

For display, an entire row is assembled in a string before it is printed. This considerably reduces the number of `PRINT` statements compared with printing each cell separately. ANSI mode moves the cursor to the top-left corner once per generation rather than sending a cursor-control sequence for every cell.

There is no artificial delay between generations. The actual update rate depends on the RC2014 and BASIC configuration. The program stops early when a generation is identical to the preceding generation. Oscillators continue until the requested generation count is reached.

## Acknowledgements and Attribution

The Game of Life was devised by British mathematician John Horton Conway and introduced to a wide audience by Martin Gardner in his October 1970 *Mathematical Games* column in *Scientific American*. This program gratefully acknowledges Conway's creation and Gardner's account.

The BASIC source and documentation in this folder are an independent implementation written for this project. They do not copy source code or descriptive text from another implementation. The names of well-known patterns are used descriptively. This project is not affiliated with or endorsed by the estate of John Horton Conway, Martin Gardner, or *Scientific American*.

Copyright protects original expression rather than an underlying idea, procedure, method of operation, or mathematical concept, as explained by the World Intellectual Property Organization. This attribution is included to credit the origin and history of the published concept; it is not a claim of endorsement and is not legal advice.

## References

- Martin Gardner, [“Mathematical Games: The fantastic combinations of John Conway's new solitaire game ‘Life’”](https://www.scientificamerican.com/article/mathematical-games-1970-10/), *Scientific American*, volume 223, number 4, October 1970, page 120, DOI: 10.1038/scientificamerican1070-120
- Scientific American, [“Math Games of Martin Gardner Still Spur Innovation”](https://www.scientificamerican.com/article/math-games-of-martin-gardner-still-spur-innovation/), including a history and description of Conway's Game of Life
- Scholarpedia, [“Game of Life”](https://www.scholarpedia.org/article/Game_of_Life), overview of the cellular automaton and its history
- World Intellectual Property Organization, [“What Can I Protect with a Copyright?”](https://www.wipo.int/en/web/copyright/protection), distinction between an idea or method and its particular expression
