# Single Input Artificial Neuron

## Overview

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Neuron/neuron.png" alt="Single One-Input Neuron" width="600">

This implements the smallest useful artificial neuron: one numeric input, one weight, one bias and one activation function.

The neuron is deliberately simple. Its purpose is to make every part of a forward pass visible before progressing to multiple inputs, training and multilayer networks. It does not learn yet; its weight and bias are set at the start of the BASIC program.

The calculation has two distinct steps:

1. Calculate a weighted input and add the bias to produce the pre-activation value, _z_
2. Pass _z_ to an activation function to produce the neuron's output, _y_

In mathematical notation:

$$
z = wx + b
$$

$$
y = f(z)
$$

## Hardware

The program requires:

- An RC2014 computer running Microsoft BASIC
- A serial terminal

The terminal-only version needs no additional hardware. `neuron_io.bas` also requires an RC2014 Digital I/O card configured for port 1.

`neuron_io_lcd.bas` requires both the Digital I/O card and an RC2014 LCD Driver Module with a 16-character, two-line display. The LCD uses command port 218 and data port 219.

## Program Files

| Filename            | Content                                                 |
| ------------------- | ------------------------------------------------------- |
| `neuron.bas`        | Terminal-only single-input neuron                       |
| `neuron_io.bas`     | Same neuron with binary output on the Digital I/O LEDs  |
| `neuron_io_lcd.bas` | User inputs only, with Digital I/O LEDs and LCD results |

## Running the Program

Load your chosen `.bas` file into BASIC and enter `RUN`.

The `neuron.bas` and `neuron_io.bas` programs first run the demonstration inputs: `2`, `3` and `4`. For each input it prints the input, weighted input, bias, sum and final output.

Afterwards, enter `Y` to try another numeric input or `N` to finish.

### Digital I/O Output

`neuron_io.bas` writes the output to the card after every calculation:

| Output | Binary (bits 7 to 0) | LEDs                   |
| ------ | -------------------- | ---------------------- |
| 0      | `00000000`           | All off                |
| 1      | `00000001`           | LED 0 on; LEDs 1–7 off |

The demonstration pauses after each example; press RETURN to continue. Inputs still come from the serial terminal. During interactive use, the LEDs hold the latest result while you enter another input. Answering `N` clears all LEDs before the program finishes. The LEDs are also cleared at startup.

To use another port, change `IP` on line 40. The display subroutine writes `Y` with `OUT IP, Y` on line 2005. If you interrupt the program manually, you can clear the card by entering `OUT 1, 0` (substitute your configured port).

### LCD and Digital I/O Version

`neuron_io_lcd.bas` goes straight to the numeric input prompt, with no predefined examples. Enter an input on the serial terminal; the program prints the calculation stages there and shows the output on both the LEDs and LCD. For an input of `4`, the LCD shows:

```text
NEURON OUTPUT: 1
BINARY: 00000001
```

For inputs at or below `3`, both displayed outputs are zero. The result stays visible while you answer `Y` to enter another input. Answer `N` to finish and clear both the LEDs and LCD. Lowercase answers also work.

The LCD initially displays `SINGLE NEURON` and `ENTER X ON PC`. Change `IP` on line 40 for a different Digital I/O port, or `LR` and `LD` on line 60 for different LCD ports. Each LCD row is padded to 16 characters so old text is erased. A short delay follows every LCD write, following the other LCD examples in this repository.

## Parts of the Neuron

### Input

The input, _x_, is the value presented to the neuron. This implementation accepts one numeric value at a time, within BASIC's floating-point range.

### Weight

The weight, _w_, controls how strongly the input affects the result:

$$
\text{weighted input} = wx
$$

The magnitude of the weight controls the scale of the input's effect. Its sign controls the direction:

- A positive weight makes _z_ increase as _x_ increases.
- A negative weight makes _z_ decrease as _x_ increases.
- A zero weight means the input has no effect and the result depends entirely on the bias.

### Bias

The bias, _b_, is added after the input has been weighted:

$$
z = wx + b
$$

It shifts the calculation independently of the input. With a step activation, this has the useful interpretation of moving the point at which the neuron switches on or off.

When _w_ is not zero, the switching point is found by setting _z_ to zero:

$$
wx + b = 0
$$

$$
x = -\frac{b}{w}
$$

The weight and bias therefore work together: the weight determines the scale and direction of the response, while the bias moves its threshold.

### Pre-activation Value

The value _z_ is the weighted input plus bias, before an activation function is applied:

$$
z = wx + b
$$

Strictly, this is an affine calculation (scaling followed by an offset); it is linear when the bias is zero.

Calculating _z_ is not the activation function. Keeping these operations separate becomes important when different activation functions are introduced later.

### Activation Function

An activation function takes _z_ and converts it into the neuron's output:

$$
y = f(z)
$$

The activation in this BASIC implementation is a step function:

$$
f(z) =
\begin{cases}
1 & \text{if } z > 0 \\
0 & \text{if } z \le 0
\end{cases}
$$

This gives the neuron binary on-or-off behaviour. A pre-activation value of exactly zero produces an output of zero in this implementation.

The step function is coded directly in lines 1030–1040. To use a different activation, edit that part of the BASIC program; there is no activation-selection parameter.

## Worked Example

The demonstration creates a neuron with:

$$
w = 2
$$

$$
b = -6
$$

Its pre-activation calculation is therefore:

$$
z = 2x - 6
$$

The step activation changes from zero to one when _z_ becomes positive:

$$
2x - 6 > 0
$$

$$
x > 3
$$

The neuron is consequently off for inputs up to and including 3, and on for inputs greater than 3.

| Input _x_ | Weighted input _wx_ | Bias _b_ | Pre-activation _z_ | Output _y_ |
| --------: | ------------------: | -------: | -----------------: | ---------: |
|         0 |                   0 |       -6 |                 -6 |          0 |
|         2 |                   4 |       -6 |                 -2 |          0 |
|         3 |                   6 |       -6 |                  0 |          0 |
|         4 |                   8 |       -6 |                  2 |          1 |
|         6 |                  12 |       -6 |                  6 |          1 |

For example, when _x = 4_:

$$
z = (2 \times 4) - 6 = 2
$$

Since 2 is greater than zero, the step activation returns 1.

## Forward-pass Behaviour

A forward pass moves information in one direction, from input to output:

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Neuron/single-neuron-forward.png" width="100%">

The weight and bias are not adjusted during this process. A forward pass only evaluates the neuron using its fixed parameters.

## BASIC Implementation

The implementations are in [`neuron.bas`](neuron.bas) and [`neuron_io.bas`](neuron_io.bas). The LCD variant is in [`neuron_io_lcd.bas`](neuron_io_lcd.bas). All three use the same calculation subroutine.

### Setting the Weight and Bias

Lines 20 and 30 set the parameters:

```basic
20 LET W = 2
30 LET B = -6
```

Edit these lines and enter `RUN` to experiment with different values. They stay fixed during each run; editing them manually is not training.

### Calculating an Output

The subroutine at line 1000 performs the forward pass:

```basic
1000 REM Forward pass: X in, weighted input V, sum Z, output Y
1010 LET V = W * X
1020 LET Z = V + B
1030 LET Y = 0
1040 IF Z > 0 THEN LET Y = 1
1050 RETURN
```

It takes the input `X`, weight `W` and bias `B`, then produces the weighted input `V`, pre-activation value `Z` and output `Y`. Assigning `0` and `1` explicitly avoids relying on BASIC's numeric representation of a true comparison.

### Inspecting Every Value

The display subroutine at line 2000 prints `X`, `V`, `B`, `Z` and `Y`. For input `4` with the default parameters, these values are `4`, `8`, `-6`, `2` and `1` respectively.

The demonstration reads its three inputs from the `DATA` statement at line 3000. The interactive section then accepts further inputs and uses the same calculation and display subroutines.

### Trying a Different Activation

Use the terminal-only `neuron.bas` for this experiment: both Digital I/O versions expect a binary output of `0` or `1`.

To try an identity activation, which returns _z_ unchanged, replace line 1030 with:

```basic
1030 LET Y = Z
```

Delete line 1040 by entering its line number alone at the BASIC prompt. Also change the introductory text at line 150 and the output label at line 2060 to describe the identity activation rather than the step function.

With the default weight and bias, input `4` then produces output `2`. This exposes the raw pre-activation value instead of a binary classification. Restore the original lines to return to the step activation.

## Checking the Results

With the original step activation and default parameters, compare the initial three results with the worked-example table above. Then try `2.9`, `3` and `3.1`: the outputs should be `0`, `0` and `1` respectively.

Numeric input is handled by BASIC's `INPUT` statement. The program does not add the Python version's explicit checks for non-finite values. Very large values may cause BASIC overflow errors, and floating-point rounding can affect inputs extremely close to the switching point.

## Experiments to Try

Start each experiment from the original program. Edit the weight on line 20 or the bias on line 30, then enter `RUN`:

1. Change the bias from `-6.0` to `-4.0`. The activation threshold moves from \(x>3\) to \(x>2\)
2. Keep the bias at `-6.0` and change the weight from `2.0` to `3.0`. The threshold moves to \(x>2\)
3. Use a negative weight and observe that increasing the input eventually switches the neuron off rather than on
4. Set the weight to zero. Every input then produces the same \(z=b\), demonstrating that the input has no influence
5. Make the identity-activation edits described above and observe the raw pre-activation output

## Limitations

- This neuron has only one input and fixed parameters
- It does not calculate a loss, derive gradients or update itself from examples
- The step activation is helpful for demonstrating a threshold, but its lack of a useful derivative makes it unsuitable for gradient-based training

## References

- [Michael Nielsen — Neural Networks and Deep Learning, Chapter 1](https://neuralnetworksanddeeplearning.com/chap1): An approachable introduction to perceptrons, weights, bias and thresholds. Its step activation uses the same convention as this program: output 1 when the weighted input plus bias is strictly greater than zero, and 0 otherwise.
- [Dive into Deep Learning — Linear Regression](https://classic.d2l.ai/chapter_linear-networks/linear-regression.html): Explains weighted sums and bias, including the distinction between a linear transformation and an affine transformation with an added bias.
- [Dive into Deep Learning — Multilayer Perceptrons](https://en.d2l.ai/chapter_multilayer-perceptrons/mlp.html): Further reading on activation functions and how individual neurons are combined into multilayer networks.
