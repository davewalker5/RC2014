# Trainable Single Input Artificial Neuron

## Overview

These programs let the RC2014 learn a weight and bias from labelled examples, then use the learned values to classify new inputs. Training runs entirely in BASIC on the RC2014.

They build on the fixed [single-input neuron](../Neuron/README.md). There is still one input, one weight and one bias, but the step activation is replaced with **sigmoid**, and a loss function and gradient-descent loop provide learning.

## Hardware

| File                          | RC2014 (*) | Digital I/O | LCD Driver | SID-Ulator Sound Card |
| ----------------------------- | ---------- | ----------- | ---------- | --------------------- |
| `trainable_neuron.bas`        | Yes        | No          | No         | No                    |
| `trainable_neuron_io.bas`     | Yes        | Yes         | No         | No                    |
| `trainable_neuron_io_lcd.bas` | Yes        | Yes         | Yes        | No                    |

(*) The RC2014 should be running BASIC

## Program Files

| Filename                                                   | Content                                                         |
| ---------------------------------------------------------- | --------------------------------------------------------------- |
| [trainable_neuron.bas](trainable_neuron.bas)               | Terminal-only training and predictions                          |
| [trainable_neuron_io.bas](trainable_neuron_io.bas)         | Same training, with the predicted class on Digital I/O LEDs     |
| [trainable_neuron_io_lcd.bas](trainable_neuron_io_lcd.bas) | Same training, with LEDs and LCD progress/results               |
| [tests/test_programs.py](tests/test_programs.py)           | Optional host-side execution checks; not loaded onto the RC2014 |

---

## Training

### Workflow

<img src="https://github.com/davewalker5/RC2014/blob/main/diagrams/epoch-workflow.png" width="100%">

Training adjusts the neuron's **weight** and **bias** so that its predictions become closer to the expected answers. The diagram shows how the examples, predictions and parameter updates flow through this process.

An **epoch** is one complete pass through the training examples. Here, the neuron processes all examples together as a **batch**, then updates its weight and bias once per epoch.

#### 1. Read the examples

Each training example provides an **input**, `x`, and a **target**, `t`. The input is the value given to the neuron; the target is the answer we want it to produce.

The examples are read before training begins and reused in each epoch.

#### 2. Calculate logits and predictions

The neuron combines each input with its current **weight**, `w`, and **bias**, `b`, to produce a **logit**, `z`.

The weight controls how strongly the input affects the result. The bias shifts the result independently of the input.

The logit is the neuron's raw score. An **activation function** converts that score into a **prediction**, `p`, which can be compared with the target. This step produces a logit and a prediction for every example in the batch.

#### 3. Calculate gradients

The neuron uses the inputs, predictions and targets to calculate the **weight gradient**, `dw`, and **bias gradient**, `db`.

A gradient describes how the **loss** — a measure of how far the predictions are from the targets — would change if a parameter changed slightly. These gradients guide the adjustments to the weight and bias.

#### 4. Calculate the new weight and bias

The neuron uses the gradients and the **learning rate** to calculate a **new weight**, `wn`, and **new bias**, `bn`.

The learning rate controls the size of each adjustment. The updates move the parameters in the direction indicated to reduce the loss.

At this point, the new values have been calculated but have not yet replaced the current weight and bias.

#### 5. Print a checkpoint when needed

If a **checkpoint** is due, the neuron calculates the **mean loss**, `L`, across the batch and prints the checkpoint values.

The mean loss summarises the prediction errors across all examples as a single value, making it easier to follow training progress.

This checkpoint uses the predictions from the current epoch, before the new weight and bias are applied. If no checkpoint is needed, training skips this step.

#### 6. Apply the new weight and bias

The neuron replaces its current weight and bias with the newly calculated values.

If more epochs remain, training returns to the prediction step. The same examples are processed again, this time using the updated parameters.

#### 7. Recalculate the final predictions and loss

After the last update, the neuron calculates the predictions and loss once more using its final weight and bias.

This final calculation ensures that the reported results describe the trained neuron after its last parameter update.

### Training Performance

Training takes time on the Z80.

The initial implementation used 2,000 full-batch updates, with checkpoints every 200 updates. As each batch contains six examples, and including the initial evaluation, the original training routine performed 12,006 individual example evaluations.

To reduce the runtime, the following changes have been made:

- **200 updates by default instead of 2,000:** about 90% fewer training example evaluations
- **Loss only when needed:** initial, checkpoint and final losses are calculated
- **A smaller inner loop and immediate feedback:** training calculates probabilities directly, without the general forward-pass subroutine's display-only values and class calculation

All six examples still classify correctly, but the reduction in training evaluations means the probabilities are less confident.

Loss values are useful for reporting but the parameter updates only need the gradients, so skipping undisplayed losses does not change the learning rule and reduces the number of loss calculations from 12,006 to 72.

To return to the original training parameters, replace line 30, as follows, and run again:

```basic
30 LET RA = .1 : LET NE = 2000 : LET NF = 200
RUN
```

To restore the faster defaults:

```basic
30 LET RA = .1 : LET NE = 200 : LET NF = 20
RUN
```

---

## Loading and Running the Programs

Load the required program from the table, above, into BASIC and enter `RUN`.

### Program Workflow

All versions automatically:

1. Load the six input/target pairs from line 5000
2. Start with weight and bias both zero
3. Perform 200 training updates at learning rate 0.1
4. Print a dot after each completed update, and details for update 1 and every 20th update
5. Print the final loss, learned parameters and threshold
6. Evaluate all six training examples with the learned parameters
7. Ask whether you want to try your own numeric inputs

Answer `Y` to enter another input, or `N` to finish. New inputs only make predictions - they do not supply labels or retrain the neuron.

### Digital I/O Output

Inputs and answers come from the serial terminal. The Digital I/O card displays the **predicted class**, not the floating-point probability:

| Predicted class | Binary output | LEDs                   |
| --------------- | ------------- | ---------------------- |
| 0               | `00000000`    | All off                |
| 1               | `00000001`    | LED 0 on; LEDs 1–7 off |

The LEDs remain off during training. Once training finishes, both hardware versions pause after each example: press RETURN to see the next result. This gives you time to inspect the LEDs and LCD. During interactive use, the latest result stays visible while you answer the next prompt.

Line 50 sets `IP`, the Digital I/O port. The program clears the LEDs at startup and on normal exit. After a manual interruption or interpreter error, clear them with `OUT 1, 0`, substituting your configured port if necessary.

### LCD and Digital I/O Version

The LCD initially displays:

```text
TRAINABLE NEURON
TRAINING...
```

At the same checkpoints as the terminal, it shows the update about to be applied, for example:

```text
UPDATE 20
OF 200
```

After training, it shows each prediction's class and probability:

```text
CLASS: 1
P: .836465
```

The exact digits and spacing depend on BASIC's number formatting. Each row is padded or truncated to 16 characters; the terminal shows the more detailed calculation. The display stays visible between inputs.

---

## Trainable Neuron Deep-Dive

### Input, Weight, Bias and Pre-Activation

These retain their roles from the [single-input artificial neuron](../Neuron/README.md).

For an input _x_, the neuron calculates the pre-activation value, or _logit_ as follows:

$$
z = wx + b
$$

The weight _w_ scales the input, and the bias _b_ shifts the result.

The difference between this implementation and the non-trainable neuron lies in how the weight and bias are chosen.

The non-trainable neuron uses values supplied by the caller throughout the demonstration. This implementation starts with zero-values and calculates updated values from the training examples.

### Target, Probability and Class

In contrast to the non-trainable neuron, the sigmoid neuron in this implementation outputs a _probability_ between 0.0 and 1.0 that is then turned into **on (1) or off (0)** using a threshold, set to 0.5 in this example.

Each training input has a _target label_ which is the desired output state, _t_, and must be either zero or one in this example. The neuron's prediction, _p_, is a probability of _class_ one.

| Term            | Meaning                                                                          |
| --------------- | -------------------------------------------------------------------------------- |
| Class           | One of the possible categories — off(0) or on(1)                                 |
| Target label, t | The correct class supplied with a training example                               |
| Prediction, p   | The neuron’s output between 0 and 1, interpreted as the probability of class one |
| Predicted class | The on/off decision obtained by checking whether `p > 0.5`                       |

For example:

| Input | Target label      | Neuron’s prediction | Predicted class |
| ----- | ----------------- | ------------------- | --------------- |
| 4     | 1 — should be on  | 0.94                | 1 — on          |
| 2     | 0 — should be off | 0.12                | 0 — off         |

### Sigmoid Activation

The method used by the trainable neuron to guide updates to the weight and bias during training is called _gradient descent_ and, as the name suggests, it uses derivatives of the loss with respect to the weight and bias. The sigmoid’s derivative, the rate of change of _p_ with _z_, contributes to those gradients.

The step function used in the non-trainable neuron is either on or off, has zero derivative away from its threshold and is not differentiable at the threshold, so it is not suitable.

In contrast, the sigmoid activation function converts the _logit_ into a probability that changes smoothly as _z_ changes. For example:

| Pre-activation _z_ | Approximate probability _p_ |
| -----------------: | --------------------------: |
|                 -2 |                      0.1192 |
|                  0 |                      0.5000 |
|                  2 |                      0.8808 |

The sigmoid activation function is defined as:

$$
p = \sigma(z) = \frac{1}{1+e^{-z}}
$$

And its derivative with respect to _z_ is:

$$
\frac{dp}{dz}=p(1-p)
$$

This gives _gradient descent_ a usable signal.

### Loss: How Good Was the Prediction?

_Binary cross-entropy_ is the method used to measure how well a predicted probability matches a correct yes/no answer.

It produces a _loss_, with a smaller value indicating a better prediction.

In plain language, it asks the question ...

> “How much probability did the neuron give to the correct answer?”

... and penalises it when that probability is low.

The loss function defines what training aims to minimise. Its derivatives determine the gradients used to update the weight and bias.

In this implementation, the gradients can be calculated directly without first calculating the numerical loss.

The loss value is calculated only for reporting progress and final results.

#### 1. Score the Probability Given to the Correct Answer

The neuron predicts _p_, the probability of class one (“on”).

- If the correct label is _1_, the probability assigned to the correct answer is _p_
- If the correct label is _0_, the probability assigned to the correct answer is _1 − p_

For example:

| Prediction p | Correct label | Probability Assigned to the Correct Answer |
| -----------: | ------------: | -----------------------------------------: |
|          0.9 |        1 — on |                                        0.9 |
|          0.9 |       0 — off |                                        0.1 |
|          0.2 |       0 — off |                                        0.8 |

That last column should be as close to **1** as possible.

#### 2. Turn the Probability Into a Loss

Binary cross-entropy uses:

$$
\text{loss} = -\ln(\text{probability assigned to the correct answer})
$$

Besides strongly penalising confidently wrong predictions, logarithms give a useful way to combine probabilities across examples.

- We want the model to assign high probabilities to all the correct labels
- Multiplying those probabilities expresses that objective
- Taking logarithms turns the product into a sum
- The minus sign turns _maximise the probability_ into _minimise the loss_

The natural logarithm is the conventional choice for binary cross-entropy and gives the loss derivative used below.

The effect is:

| Probability assigned to the correct answer |  Loss |
| -----------------------------------------: | ----: |
|                                   **0.99** | 0.010 |
|                                       0.90 | 0.105 |
|                                   **0.50** | 0.693 |
|                                       0.10 | 2.303 |
|                                       0.01 | 4.605 |

Notice the behaviour:

| Result  | Confidence | Loss     |
| ------- | ---------- | -------- |
| Correct | Confident  | Small    |
| -       | Uncertain  | Moderate |
| Wrong   | Confident  | Large    |

This is more informative than simply counting correct classifications.

If the target is one, predictions of **0.51** and **0.99** both classify it correctly, but the loss distinguishes them.

#### 3. Combine both Possible Labels Into One Formula

$$
\ell = -t\ln(p) - (1-t)\ln(1-p)
$$

The first term handles the case where the label is 1.0 and the second where it is 0.0. In practice since _t_ is always either _0_ or _1_, one term always drops out:

When the target is 1:

$$
\ell = -\ln(p)
$$

When the target is 0:

$$
\ell = -\ln(1-p)
$$

This is the calculation for a single example. The implementation averages it across all the training examples, i.e. the whole _batch_:

$$
L = \frac{1}{n}\sum_{i=1}^{n}\ell_i
$$

This mean loss is the objective the training loop attempts to minimise by adjusting the weight and bias.

#### 4. How Loss Guides the Updates

The updates use the _gradients_ of the mean loss, rather than the numerical loss itself. A gradient describes how the loss would change if a parameter changed slightly.

For sigmoid activation combined with binary cross-entropy, the derivative of a single example's loss with respect to its logit simplifies to:

$$
\frac{\partial \ell}{\partial z} = p-t
$$

Using this result, the gradients for the weight and bias across the whole batch are:

$$
dw = \frac{1}{n}\sum_{i=1}^{n}(p_i-t_i)x_i
$$

$$
db = \frac{1}{n}\sum_{i=1}^{n}(p_i-t_i)
$$

Here, _n_ is the number of training examples, and _i_ identifies each example. The weight gradient uses the inputs as well as the predictions and targets; the bias gradient uses just the predictions and targets.

The program therefore calculates these gradients directly on every training pass. It calculates the numerical loss only for the initial report, checkpoints and final report. Skipping undisplayed loss calculations does not change the gradients or parameter updates.

These gradient formulas follow from the choice of sigmoid activation and binary cross-entropy. Choosing a different activation or loss function can change the formulas. The derivation can be considered separately from the calculation of the reported loss.

### Learning Rate and Parameter Updates

The **learning rate**, _η_, controls how far the weight and bias move in response to their gradients:

$$
w_{\text{next}} = w - \eta\frac{\partial L}{\partial w}
$$

$$
b_{\text{next}} = b - \eta\frac{\partial L}{\partial b}
$$

For either parameter, a negative gradient increases its value; a positive gradient decreases it. A zero gradient leaves it unchanged.

A small learning rate can make progress slow. A large one can overshoot and increase the loss.

Both gradients are calculated across the whole batch using the same current weight and bias. The program then calculates `NW` and `NB` before assigning both new parameters. This is a **full-batch gradient-descent update**: the parameters change once per epoch, rather than after each individual example.

### Interpreting the Learned Threshold

When the weight is non-zero, the input where the prediction reaches 0.5 is:

$$
x=-\frac{b}{w}
$$

This is the **decision boundary**. With a positive weight, inputs above it predict class 1; with a negative weight, inputs below it predict class 1. At exactly 0.5, the program chooses class 0.

The training data requires a boundary that separates inputs labelled zero from those labelled one, but does not determine a unique boundary. Its position can change as training continues.

With zero weight, the prediction depends only on the bias, so there is no input-dependent decision boundary.

### Worked Example: One Training Update

For this example, take two input/target pairs from the program’s training data:

| Input, x | Target, t |
| -------: | --------: |
|        2 |   0 — off |
|        4 |    1 — on |

Treat these as a small batch, so _n = 2_. The actual program trains on all six examples, so its updates differ from those calculated here.

Start with the program’s initial settings: weight _w = 0_, bias _b = 0_, and learning rate _η = 0.1_.

#### 1. Calculate the Logits and Predictions

Using the equation from **Input, Weight, Bias and Pre-Activation**:

$$
z = wx+b
$$

Both logits are zero because the weight and bias are zero. From **Sigmoid Activation**, a zero logit gives a prediction of 0.5:

$$
p = \sigma(0) = 0.5
$$

| Input, x | Target, t | Logit, z | Prediction, p | Predicted class |
| -------: | --------: | -------: | ------------: | --------------: |
|        2 |         0 |        0 |           0.5 |               0 |
|        4 |         1 |        0 |           0.5 |               0 |

As described in **Target, Probability and Class**, the program chooses class 1 only when _p > 0.5_. A tie therefore gives class 0.

#### 2. Calculate the Initial Loss

Using **Loss: How Good Was the Prediction?**, each example assigns probability 0.5 to its correct answer. Both sample losses are therefore:

$$
\ell = -\ln(0.5) \approx 0.693147
$$

Their mean is:

$$
L = \frac{0.693147+0.693147}{2} \approx 0.693147
$$

This value reports the initial performance. It is not an input to the parameter-update calculation.

#### 3. Calculate the Gradients

Using **How Loss Guides the Updates**, first calculate the prediction-minus-target value, _p − t_, for each example:

| Input, x | Target, t | Prediction, p | p − t | (p − t)x |
| -------: | --------: | ------------: | ----: | -------: |
|        2 |         0 |           0.5 |   0.5 |        1 |
|        4 |         1 |           0.5 |  −0.5 |       −2 |

The weight gradient is the average of the last column:

$$
dw = \frac{1+(-2)}{2} = -0.5
$$

The bias gradient is the average of _p − t_:

$$
db = \frac{0.5+(-0.5)}{2} = 0
$$

The bias contributions cancel. The weight contributions do not, because they are multiplied by different inputs.

#### 4. Update the Weight and Bias

Using **Learning Rate and Parameter Updates**:

$$
w_{\text{next}} = 0 - 0.1(-0.5) = 0.05
$$

$$
b_{\text{next}} = 0 - 0.1(0) = 0
$$

The negative weight gradient increases the weight. The zero bias gradient leaves the bias unchanged.

Both new values are calculated from the same pre-update state, then applied together.

#### 5. Evaluate the Updated Neuron

With _w = 0.05_ and _b = 0_, calculate the predictions and losses again:

| Input, x | Target, t | Logit, z | Prediction, p | Predicted class | Sample loss |
| -------: | --------: | -------: | ------------: | --------------: | ----------: |
|        2 |         0 |      0.1 |      0.524979 |               1 |    0.744397 |
|        4 |         1 |      0.2 |      0.549834 |               1 |    0.598139 |

The new mean loss is:

$$
L \approx \frac{0.744397+0.598139}{2} = 0.671268
$$

The mean loss has fallen from approximately **0.693147** to **0.671268**. The class-1 example improved enough to outweigh the worsening of the class-0 example.

The number of correct classifications is still one out of two. This illustrates why loss gives more information than simply counting correct classifications, and why an update need not improve every example individually.

#### 6. What Happens Next?

The updated predictions no longer produce cancelling bias contributions:

$$
db \approx \frac{0.524979+(0.549834-1)}{2} = 0.037407
$$

The next update therefore decreases the bias. It also recalculates the weight gradient using these new predictions.

Training repeats this process: calculate predictions, calculate batch gradients, and apply a parameter update. Numerical loss is calculated when needed to report progress.

---

## Training Behaviour and Expected Results

The worked example used two examples to illustrate an update. The actual program trains on all six input/target pairs:

| Input, x | Target, t |
| -------: | --------: |
| 0        | 0         |
| 1        | 0         |
| 2        | 0         |
| 4        | 1         |
| 5        | 1         |
| 6        | 1         |

Starting with weight and bias both zero, every prediction is initially 0.5 and the mean loss is approximately 0.693147.

Across this full batch, the first weight gradient is −1 and the first bias gradient is zero. With learning rate 0.1, the first update therefore sets the weight to 0.1 and leaves the bias at zero.

### Comparing Training Durations

Using the same initial parameters and learning rate, expect approximately:

| Result            | 200 updates | 2,000 updates |
| ----------------- | ----------: | ------------: |
| Final mean loss   | 0.184100    | 0.035555      |
| Learned weight    | 1.006394    | 2.356745      |
| Learned bias      | −2.393418   | −6.692371     |
| Decision boundary | 2.378212    | 2.839667      |

The resulting predictions are:

| Input | Target | Probability after 200 updates | Probability after 2,000 updates | Class in both runs |
| ----: | -----: | ----------------------------: | ------------------------------: | -----------------: |
| 0     | 0      | 0.0837                        | 0.0012                          | 0                  |
| 1     | 0      | 0.1999                        | 0.0129                          | 0                  |
| 2     | 0      | 0.4060                        | 0.1214                          | 0                  |
| 4     | 1      | 0.8365                        | 0.9390                          | 1                  |
| 5     | 1      | 0.9333                        | 0.9939                          | 1                  |
| 6     | 1      | 0.9745                        | 0.9994                          | 1                  |

Both runs classify every training example correctly. Longer training lowers the loss and moves the probabilities closer to their targets, even though the predicted classes remain unchanged.

Both decision boundaries separate the training examples correctly. However, an input between the two boundaries can receive different classifications depending on how long training runs.

### Reading the Checkpoints

Checkpoint loss and gradients describe the neuron **before** the numbered update. `Next W` and `Next B` show the proposed parameter values.

The final loss describes the neuron **after** the last update. Small differences in the displayed digits may occur because of BASIC's floating-point arithmetic and number formatting.

---

## Implementation

### Overview and Configuration

| Lines            | Purpose                                                       |
| ---------------- | ------------------------------------------------------------- |
| 20               | Initial weight `W` and bias `B`                               |
| 30               | Learning rate `RA`, updates `NE`, checkpoint interval `NF`    |
| 40               | Number of training pairs `N`                                  |
| 50–70            | Hardware configuration/initialisation, where present          |
| 80               | Input and target arrays `XX()` and `TT()`                     |
| 170–230          | Validate settings and read training pairs                     |
| 260–350          | Initial evaluation and training loop                          |
| 390–530          | Final evaluation report and example predictions               |
| 600–700          | Interactive predictions with the learned parameters           |
| 800–840          | Normal exit and hardware cleanup                              |
| 1000             | Forward pass; produces `V`, `Z`, `Q`, `P`, `Y`                |
| 1200             | Batch gradients `DW`, `DB`; also mean loss `LS` when `FL = 1` |
| 1400             | Stable sample loss `SL`                                       |
| 1600             | Pre-update checkpoint display                                 |
| 2000             | Prediction display                                            |
| 3000, 3500, 3900 | LCD initialisation, padded rows and delays                    |
| 4000, 4500       | Configuration checks and invalid-data exit                    |
| 5000             | Interleaved input/target pairs in a `DATA` statement          |

The arrays reserve space for up to 100 examples, indexed from 1. The program checks these demonstration limits:

- `N`: integer from 1 to 100
- `NE`: integer from 0 to 10,000
- `NF`: integer from 1 to 10,000
- `RA`: greater than 0 and at most 10
- Initial weight and bias: each between −1,000 and 1,000
- Training and interactive inputs: between −1,000 and 1,000
- Training targets: exactly 0 or 1

These bounds keep arithmetic within a modest range; they do not guarantee convergence for every dataset or learning rate. Detected invalid settings or data print a message and exit through hardware cleanup. Out-of-range interactive inputs are requested again.

When editing the dataset, set `N` to its number of pairs. Add further `DATA` lines after 5000 for longer datasets, keeping each source line at most 72 characters. Too few values cause BASIC's `OUT OF DATA` error; extra values are ignored. Non-numeric data and values too large for BASIC to parse are handled by the interpreter, not by custom exception handling. Interpreter errors or manual breaks can bypass cleanup.

### Experiments to Try

Change one setting at a time and run the program again. Each `RUN` starts training from the initial weight and bias specified in line 20.

1. Reduce `NE` to 20, or increase it to 2,000 - compare the final loss, probabilities and decision boundary
2. Reduce `RA` to 0.01 while keeping the same update count - compare how far training progresses
3. Increase `RA` within the supported range and inspect the checkpoint losses - larger steps may overshoot and increase the loss
4. Reduce `NF` to see more checkpoints. The parameter updates remain unchanged, but more frequent terminal/LCD output adds runtime
5. Reverse all target labels - bserve the learned negative weight and the reversed classification direction
6. Change the initial weight and bias in line 20 - inspect the first gradients and proposed update
7. Add an example at input three and increase `N` to match - train once with its target set to zero, then again with it set to one and compare the resulting decision boundaries
8. Set `NE` to zero - inspect the initial neuron's predictions and loss without applying any updates

### Stable Calculations in BASIC

The sigmoid and loss formulas in the deep dive are mathematically correct, but evaluating them directly can cause problems in BASIC's finite-precision arithmetic. In the sigmoid formula, `EXP(-Z)` can overflow when _z_ is a large negative number. The resulting probability can also round to exactly zero or one, so calculating loss from that rounded probability could attempt `LOG(0)`.

To evaluate the sigmoid safely, the BASIC programs use the following equivalent form, subject to the small approximations described below:

$$
q=e^{-|z|},\qquad
p=\begin{cases}
1/(1+q) & z\geq0\\
q/(1+q) & z<0
\end{cases}
$$

The exponential's argument is never positive, so its result never exceeds one. Both branches give the same sigmoid probability as the original formula, without needing an exponential of a large positive number.

For loss, let _s = -z_ when the target is 1 and _s = z_ when it is 0. For either target, binary cross-entropy can be written as _ln(1 + e^s)_. Evaluating that expression directly could also overflow, so the program uses the equivalent stable form:

$$
\ell=\max(0,s)+\ln(1+q)
$$

Here, _q_ is the same value used for the sigmoid calculation, since _|s| = |z|_. BASIC's `LOG` calculates the natural logarithm, and the program implements _max(0,s)_ by adding _s_ only when it is positive.

This calculates loss from the _logit_ without taking the logarithm of a rounded probability. For example, _z = 1000_ with target zero gives loss approximately 1000 even when the probability has rounded to one.

As explained in **How Loss Guides the Updates**, this numerical loss is only needed for reporting. The gradients are still calculated directly from _p - t_, with the input included for the weight gradient.

There are two small numerical adaptations:

1. When _|z|>50_, use `Q = 0` without calling `EXP`. The omitted exponential is below about _1.93 x 10^-22_. This avoids relying on how a particular BASIC ROM handles extreme exponential underflow. The prediction becomes exactly zero or one, and the logarithmic loss correction becomes zero.
2. When `Q < .0001`, approximate _ln(1+q)_ by _q-q^2/2_. Otherwise use `LOG(1+Q)`. The approximation avoids losing a small correction when `1+Q` rounds to one; its mathematical truncation error is below _3.34 x 10^-13_ over this interval, before allowing for floating-point rounding.

These approximations keep the calculations practical for this demonstration. The small-_q_ logarithm approximation affects only the reported loss; the exponential cutoff also affects the predictions used in the gradients, but changes them by less than about _1.93 x 10^-22_ before floating-point rounding.

### Host-side Checks

The optional host-side tests require Python 3.10 or later. To run the execution checks, `cbmbasic` must also be installed and available on your `PATH`.

On macOS with Homebrew installed, use the [official Homebrew package](https://formulae.brew.sh/formula/cbmbasic):

```sh
brew install cbmbasic
```

For source code and other platform options, see the [cbmbasic project](https://github.com/mist64/cbmbasic).

From the RC2014 repository root, run:

```sh
python3 -m unittest discover -s Programs/TrainableNeuron/tests -v
```

`cbmbasic` is an implementation of Commodore’s version of Microsoft BASIC. In temporary copies of the programs, `OUT` statements are replaced with printed port-write records so that hardware output can be inspected without physical devices. Tests also modify settings or training data where needed for individual scenarios.

The checks cover:

- Training results, gradients and parameter updates
- Loss reporting, progress output and numerical stability
- Input validation, interactive predictions and hardware cleanup
- Simulated LED output, LCD formatting and BASIC source constraints

The individual scenarios and expected results are documented in [tests/test_programs.py](tests/test_programs.py).

Without `cbmbasic`, execution checks are skipped; source checks still run. The tests do not emulate the RC2014 ROM, measure Z80 runtime, or validate physical ports and LCD timing. Testing on the actual RC2014 remains necessary.

---

## Limitations

This is a single-input binary classifier with one decision boundary. It cannot classify a middle interval as one while classifying inputs on both sides as zero.

For data that can be perfectly separated by a threshold, loss can continue falling as the weight and bias grow in magnitude. The fixed update count determines when training stops; it does not mean the program has found finite optimal parameters. Correct classifications on the training examples also do not establish accuracy on unseen inputs.

Learned parameters are not saved automatically. To reuse them, record the final weight and bias, enter those values in line 20, and set `NE = 0` in line 30. The program will then evaluate that neuron without applying further training updates.

---

## References

- [Fixed Neuron programs](../Neuron/README.md)
- [RC2014 Microsoft BASIC documentation and ROM source](https://github.com/RC2014Z80/RC2014/tree/master/ROMs/MSBASIC) — background on the target BASIC
