# ANSI Colour Code Test

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/ANSI/ansi.png" alt="ANSI Code Test" width="600">

This program tests the standard ANSI colour codes for changing colour and applying effects when printing text.

## Hardware

The program requires:

- An RC2014 computer running BASIC
- A serial terminal

No additional hardware is required.

## Program Files

| File          | Description                             |
| ------------- | --------------------------------------- |
| ansi_test.bas | Implementation of the ANSI test program |

## Running the Program

- The terminal emulator used to connect to the RC2014 must be configured to handle ANSI codes for the program to work.
- Load `ansi_test.bas` into BASIC and enter `RUN`.

## ANSI Codes

### Colour Codes

The following table summarises the colour codes:

| Colour                                     | Foreground | Background | Bright Foreground |
| ------------------------------------------ | ---------- | ---------- | ----------------- |
| Black                                      | 30         | 40         | 90                |
| <span style="color:Red">Red</span>         | 31         | 41         | 91                |
| <span style="color:Green">Green</span>     | 32         | 42         | 92                |
| <span style="color:Yellow">Yellow</span>   | 33         | 43         | 93                |
| <span style="color:Blue">Blue</span>       | 34         | 44         | 94                |
| <span style="color:Magenta">Magenta</span> | 35         | 45         | 95                |
| <span style="color:Cyan">Cyan</span>       | 36         | 46         | 96                |
| <span style="color:White">White</span>     | 37         | 47         | 97                |

### Effects

The following table summarises the codes used to apply effects:

| Effect        | On  | Off |
| ------------- | --- | --- |
| Bold          | 1   |     |
| Underline     | 4   | 24  |
| Blink         | 5   | 25  |
| Reverse video | 7   | 27  |
| Overline      | 53  | 55  |

To reset all effects, send code 0.

## References

- [ANSI Tools](https://ansi.tools)
