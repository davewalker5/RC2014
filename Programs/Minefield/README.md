# Minefield

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Minefield/Minefield.png" alt="Minefield" width="600">

An original BASIC implementation of the traditional minesweeper puzzle for the RC2014. It is not affiliated with or endorsed by Microsoft.

## Hardware

The program requires:

- An RC2014 computer running BASIC
- A serial terminal

No additional hardware is required.

## Program Files

| Filename           | Content                                           |
| ------------------ | ------------------------------------------------- |
| minefield_text.bas | Text-based implementation of Minefield            |
| minefield_ansi.bas | Version that uses ANSI escape codes to add colour |

## Running the Program

Load the selected program file, from the table above, into BASIC and enter `RUN`

## Appearance

Cells are represented as follows:

| Contents                     | Text Version | ANSI Version                |
| ---------------------------- | ------------ | --------------------------- |
| Non-reveled cell             | Blank        | White square                |
| Empty revealed cell          | .            | Green square                |
| Empty cell next to 1 mine    | 1            | Blue 1 on black background  |
| Empty cell next to 2 mines   | 2            | Green 2 on black background |
| Empty cell next to > 2 mines | n            | Red n on black background   |
| Mine                         | \*           | White \* on red background  |

## References

- [History of Minesweeper](https://www.247minesweeper.com/news/history-of-minesweeper/), 24x7 Minesweeper
- [Mined Out](https://en.wikipedia.org/wiki/Mined-Out), Wikipedia
- [Microsoft Minesweeper](https://en.wikipedia.org/wiki/Microsoft_Minesweeper), Wikipedia
