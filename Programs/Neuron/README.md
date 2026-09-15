# Single Input Artificial Neuron

## Overview

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Neuron/neuron.gif" alt="Single One-Input Neuron" width="600">

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

No additional hardware is required.

## Program Files

| Filename      | Content                                     |
| ------------- | ------------------------------------------- |
| neuron.bas | Implementation of the single-input neuron |

## Running the Program

Load `neuron.bas` into BASIC and enter `RUN`.

The program first runs the demonstration inputs: `0`, `2`, `3`, `4` and `6`. For each input it prints the input, weighted input, bias, sum and
final output.

Afterwards, enter `Y` to try another numeric input or `N` to
finish.

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

<img src="https://github.com/davewalker5/NeuralNetwork/blob/main/diagrams/single-neuron-forward.png" width="100%">

The weight and bias are not adjusted during this process. A forward pass only evaluates the neuron using its fixed parameters.

## BASIC Implementation

The implementation is in [`neuron.bas`](neuron.bas).

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

The demonstration reads its five inputs from the `DATA` statement at line 3000. The interactive section then accepts further inputs and uses the same calculation and display subroutines.

### Trying a Different Activation

To try an identity activation, which returns _z_ unchanged, replace line 1030 with:

```basic
1030 LET Y = Z
```

Delete line 1040 by entering its line number alone at the BASIC prompt. Also change the introductory text at line 150 and the output label at line 2060 to describe the identity activation rather than the step function.

With the default weight and bias, input `4` then produces output `2`. This exposes the raw pre-activation value instead of a binary classification. Restore the original lines to return to the step activation.

## Checking the Results

With the original step activation and default parameters, compare the initial five results with the worked-example table above. Then try `2.9`, `3` and `3.1`: the outputs should be `0`, `0` and `1` respectively.

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
