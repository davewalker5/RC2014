# Ordinary Differential Equation (ODE) Solver

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/ODE/dyay-rk4-chart.png" alt="Charted Solution to dy/dt = Ay" width="600">

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/ODE/dyay-rk4-table.png" alt="Tabulated Solution to dy/dt = Ay" width="600">

A set of programs for solving Ordinary Differential Equations (ODEs) using the Euler, Euler Predictor-Corrector and 4th-Order Runge-Kutta methods.

## Hardware

The program requires:

- An RC2014 Mini II running Microsoft BASIC
- A serial terminal

No additional hardware is required. The display uses plain text and does not require ANSI terminal support.

## Program Files

| File / Folder                        | Description                                                                       |
| ------------------------------------ | --------------------------------------------------------------------------------- |
| `Components`                         | Separate files for each subroutine for independent amendment and numbering        |
| `euler_fixed_step.bas`               | Solve `dy/dt = Ay` using the Euler method and fixed step size                     |
| `predictor_corrector_fixed_step.bas` | Solve `dy/dt = Ay` using the Euler Predictor-Corrector method and fixed step size |
| `runge_kutta_4k_fixed_step.bas`      | Solve `dy/dt = Ay` using the 4th-Order Runge-Kutta method and fixed step size     |
| `fixed_step_solver.bas`              | Solve `dy/dt = Ay` using a choice of method and fixed step size                   |
| `adaptive_step_solver.bas`           | Solve `dy/dt = Ay` using a choice of method and adaptive step size support        |

## Running the Program

Load the required `fixed_step` program or `adaptive_step_solver.bas` from the table, above, into BASIC and enter `RUN`

## The Differential Equation

The programs use the following first-order Ordinary Differential Equation (ODE) as theirå test problem:

$$
\frac{dy}{dt}=Ay
$$

Where:

- $y$ is the dependent variable.
- $t$ is the independent variable.
- $A$ is a constant that determines the rate of change.

This equation describes exponential growth or decay, depending on the value of $A$. It has numerous applications in science and engineering, including population growth, radioactive decay and simplified models of electrical circuits.

### The Analytical Solution

One particularly useful property of this equation is that it has a straightforward analytical solution. Given the initial condition:

$$
y(0)=y_0
$$

The exact solution is:

$$
\boxed{y(t)=y_0e^{At}}
$$

The behaviour of the solution depends on the value of $A$:

| Condition | Behaviour          |
| --------- | ------------------ |
| $A>0$   | Exponential growth |
| $A=0$   | Constant solution  |
| $A<0$   | Exponential decay  |

For example, with $A=-1$ and $y_0=1$, the exact solution becomes:

$$
y(t)=e^{-t}
$$

### Why This Equation?

The existence of an analytical solution makes the equation an excellent test problem.

Rather than simply trusting the results produced by a numerical integration algorithm, we can compare them directly with the mathematically exact solution.

For a numerical approximation $y_n$, calculated at time $t_n$, the absolute error can be expressed as:

$$
E_n=\left|y_n-y_0e^{At_n}\right|
$$

This allows us to investigate several important properties of numerical integration:

- **Accuracy:** How closely does each numerical method approximate the analytical solution?
- **Convergence:** How does reducing the integration step size affect the numerical error?
- **Computational efficiency:** How much computational effort does each method require to achieve a particular level of accuracy?
- **Adaptive integration:** How effectively can the solver adjust its step size to control estimated numerical error?
- **Numerical stability:** How do different integration methods and step sizes behave, particularly for rapidly decaying solutions?

By varying $A$, the initial condition and the integration interval, we can investigate these properties without changing the underlying differential equation.

The analytical solution provides a reference against which the numerical results can be evaluated. Importantly, it also allows us to distinguish between the *estimated local error* used by an adaptive integration algorithm and the *actual error* observed in its numerical solution.

Although the solver has been designed so that other differential equations can be substituted, this simple equation provides a particularly useful foundation for developing, testing and comparing numerical integration algorithms.

## Implementation Notes

The programs are split into distinct subroutines, as follows:

| Line Numbers | Purpose                                                                                                                                            |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0001 - 0999  | Main program flow                                                                                                                                  |
| 1000 - 1999  | Initialise parameters used by the function to be solved                                                                                            |
| 2000 - 2999  | Calculate the function to be solved from the current independent and dependent variables, T(I) and Y(I), and any parameters set on lines 1000-1999 |
| 3000 - 3999  | Integration methods                                                                                                                                |
| 4000 - 4999  | Text table implementation                                                                                                                          |
| 5000 - 5999  | Text chart implementation                                                                                                                          |

For the programs that offer a choice of integration method, lines 3000 - 3999 are further sub-divided as follows:

| Line Numbers | Purpose                          |
| ------------ | -------------------------------- |
| 3000 - 3099  | Euler Method                     |
| 3100 - 3199  | Euler Predictor-Corrector Method |
| 3200 - 3399  | 4th-Order Runge-Kutta Method     |

For the programs that support adaptive step-size, the following are also present in the line number range 3000-3999:

| Line Numbers | Purpose                        |
| ------------ | ------------------------------ |
| 3400 - 3999  | Adaptive step-size calculation |

## References

- **Ordinary Differential Equations:** [Differential Equations — Definitions](https://tutorial.math.lamar.edu/Classes/DE/Definitions.aspx), Paul’s Online Notes. An introduction to differential equations, their order, solutions and initial-value problems.
- **Euler Method:** [Euler’s Method](https://tutorial.math.lamar.edu/classes/de/EulersMethod.aspx), Paul’s Online Notes. Explains the method from tangent-line approximations, with worked examples, pseudocode and comparisons against exact solutions.
- **Euler Predictor-Corrector Method (Heun’s Method):** [Heun’s Method](https://math.libretexts.org/Bookshelves/Differential_Equations/Numerically_Solving_Ordinary_Differential_Equations_%28Brorson%29/04%3A_Predictor-corrector_methods_and_Runge-Kutta/4.01%3A_Heuns_method), Stuart Brorson, Mathematics LibreTexts. Explains how an Euler prediction is corrected by averaging the starting and predicted endpoint slopes, with a diagram and algorithm.
- **4th-Order Runge-Kutta Method (RK4):** [Runge-Kutta Methods](https://math.libretexts.org/Bookshelves/Differential_Equations/Numerically_Solving_Ordinary_Differential_Equations_%28Brorson%29/04%3A_Predictor-corrector_methods_and_Runge-Kutta/4.06%3A_Runge-Kutta_methods), Stuart Brorson, Mathematics LibreTexts. Introduces classical RK4 through its four slope estimates and weighted update formula.