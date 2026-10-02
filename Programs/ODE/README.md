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