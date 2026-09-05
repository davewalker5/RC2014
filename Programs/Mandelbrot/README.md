# Mandelbrot Set

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Mandelbrot/mandelbrot.png" alt="The Mandelbrot Set" width="600">

A BASIC program that draws the Mandelbrot set in a serial terminal using character shading. The default view is 64 characters wide and 24 rows high, with up to 32 iterations per point. Each character appears as it is calculated.

## Hardware

The program requires:

- An RC2014 Mini II running BASIC
- A serial terminal with a monospaced font and at least 64 columns

No additional hardware is required. The output uses plain text and does not require ANSI screen control. The heading and completion message add lines beyond the image; terminal scrollback can be used to view or copy the complete output.

## Program Files

| File             | Description                                                        |
| ---------------- | ------------------------------------------------------------------ |
| `mandelbrot.bas` | Draws a configurable text Mandelbrot set using escape-time shading |

## Running the Program

Load `mandelbrot.bas` into BASIC and enter `RUN`.

The program renders the image immediately and returns to BASIC on completion. Enter `RUN` again to redraw it. Calculation is slower near the set, where points often need the full iteration limit; the time between rows can therefore vary.

To change the output, edit the settings near the start of the program before running it:

| Line | Setting    | Default     | Purpose                                                            |
| ---- | ---------- | ----------- | ------------------------------------------------------------------ |
| 20   | `W`, `H`   | `64`, `24`  | Image width (2-79) and height (2-100), both integers               |
| 20   | `LM`       | `32`        | Maximum iterations per point, an integer from 1 to 255             |
| 30   | `XL`, `XR` | `-2`, `1`   | Left and right coordinates on the real axis; `XR` must exceed `XL` |
| 40   | `AR`       | `2`         | Positive ratio of terminal character height to width               |
| 50   | `P$`       | ` .:-=+*#%` | Non-empty sequence of escape shades, from light to dense           |

For a quicker preview, try `W = 40`, `H = 16`, and `LM = 16`. Increasing `LM` improves the classification of slow-escaping points but increases calculation time. Keep the terminal wider than the image to avoid automatic wrapping at the right edge.

## Mandelbrot Calculation

Each character samples a complex number `c = CR + CI * i`. Starting from `z = 0`, the program repeatedly applies:

```text
z = z squared + c
```

Using real and imaginary components, this becomes:

```text
new real      = old real squared - old imaginary squared + CR
new imaginary = 2 * old real * old imaginary + CI
```

A point escapes when the sum of the squared components exceeds 4, meaning its distance from the origin exceeds 2. Escapes on iterations 1 through 9 select successive characters in the default palette; later escapes use `%`. Points that have not escaped after `LM` iterations use `@`. This finite calculation approximates the set: `@` does not prove that a point will never escape.

## Implementation Notes

The view is centred vertically on the real axis. Horizontal sample spacing is `(XR - XL) / (W - 1)`; vertical spacing is that value multiplied by `AR`. The default ratio assumes characters twice as tall as they are wide, keeping the plotted shape approximately proportional. Changing the number of rows changes the vertical extent of the view. Adjust `AR` if the terminal font has different proportions.

The calculation uses BASIC's floating-point arithmetic and caches the squared components between iterations. The escape test runs before the iteration-limit test, so a point escaping on the final permitted iteration still receives an escape shade.

The `@` marker is generated with `CHR$(64)` rather than included literally in the BASIC source. Literal `@` characters disrupted line entry during transfer on the target machine; generating the character at runtime preserves the display without sending it as part of a source line.

Each character is printed directly with a trailing semicolon to stay on the same line. A newline follows each completed row. No row string or image array is needed, keeping string storage small. Building a row by repeated string concatenation exhausted the available string space on the RC2014, producing `?OS Error`; direct output avoids that growing allocation. BASIC's numeric precision and the finite character grid limit the detail available when narrowing the view.

## References

- Robert L. Devaney, Boston University, [“The Mandelbrot Set”](https://math.bu.edu/eap/DYSYS/FRACGEOM/node2.html) — an introduction to the set's definition and why a distance greater than 2 provides an escape test.
- Cleve Moler, [“Mandelbrot Set”](https://www.mathworks.com/content/dam/mathworks/mathworks-dot-com/moler/exm/chapters/mandelbrot.pdf), Chapter 13 of *Experiments with MATLAB* — a practical explanation of iteration, escape counts, image generation, and the trade-off between detail and computation time. The examples use MATLAB, but the underlying method also applies to this BASIC program.
- Wolfram MathWorld, [“Mandelbrot Set”](https://mathworld.wolfram.com/MandelbrotSet.html) — a broader mathematical overview, with illustrations, properties, historical background, and further reading.
