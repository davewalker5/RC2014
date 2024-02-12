# Cellular Automaton

<img src="https://github.com/davewalker5/RC2014/blob/main/Applications/Automaton/automaton.png" alt="Rule 30 Automaton" width="600">

_Rule 30 nearest neighbour one-dimensional cellular automaton_

An implementation of nearest-neighbour one-dimensional cellular automata, also known as "elementary cellular automata". Each generation in this class of automaton consists of a single row of cells each of which may be in one of two possible states, alive (1) or dead (0).

This folder contains both hard-coded "rule 30" implementations (see the references for more information) and a generic implementation where the rules for calculating the next generation are configurable.

## Example - Rule 30

For the rule 30 automaton, if the current cell and the cells to the left and right of it follow one of the patterns shown in the following table in the current generation, with the status of the current cell indicated by the middle digit of each pattern, the current cell will be alive in the next generation:

| Generation         | Pattern 1 | Pattern 2 | Pattern 3 | Pattern 4 |
| ------------------ | --------- | --------- | --------- | --------- |
| Current generation | 100       | 011       | 010       | 001       |

"1" represents a living cell and "0" a dead cell.

All other combinations result in the current cell being dead in the next generation.

Pattern 1 can therefore be expressed as:

> If the cell to the left of the current cell is alive and the current cell and cell to the right are dead in the current generation, then in the next generation the current cell will be alive

## Program Files

| File                  | Rule | Description                                                                                                 |
| --------------------- | ---- | ----------------------------------------------------------------------------------------------------------- |
| automaton_generic.bas | Any  | Configurable patterns in the DATA statements. Uses ANSI colour codes to output the state of each generation |
| automaton_ansi.bas    | 30   | Uses ANSI colour codes to output the state of each generation                                               |
| automaton_text.bas    | 30   | Uses plain text to output the state of each generation                                                      |

Both implementations require the terminal emulator to use a fixed-width font to ensure proper alignment of the output.

## References

- [Cellular Automaton](https://mathworld.wolfram.com/CellularAutomaton.html), Wolfram Math World
- [Elementary Cellular Automata](https://mathworld.wolfram.com/ElementaryCellularAutomaton.html), Wolfram Math World
- [Stephen Wolfram](https://www.stephenwolfram.com/)
