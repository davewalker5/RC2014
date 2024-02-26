# Minesweeper

<img src="https://github.com/davewalker5/RC2014/blob/main/Applications/Minesweeper/Minesweeper.png" alt="Minesweeper" width="600">

| Filename             | Content                                           |
| -------------------- | ------------------------------------------------- |
| minesweeper_text.bas | Text-based implementation of Minesweeper          |
| minesweeper_ansi.bas | Version that uses ANSI escape codes to add colour |

Cells are represented as follows:

| Contents                     | Text Version | ANSI Version                |
| ---------------------------- | ------------ | --------------------------- |
| Non-revealed cell            | Blank        | White square                |
| Empty revealed cell          | .            | Green square                |
| Empty cell next to 1 mine    | 1            | Blue 1 on black background  |
| Empty cell next to 2 mines   | 2            | Green 2 on black background |
| Empty cell next to > 2 mines | n            | Red n on black background   |
| Mine                         | \*           | White \* on red background  |

## References

- [History of Minesweeper](https://www.247minesweeper.com/news/history-of-minesweeper/), 24x7 Minesweeper
- [Mined Out](https://en.wikipedia.org/wiki/Mined-Out), Wikipedia
- [Microsoft Minesweeper](https://en.wikipedia.org/wiki/Microsoft_Minesweeper), Wikipedia
