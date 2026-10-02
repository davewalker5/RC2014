# Ecology Modelling

## Hardware

The programs require:

- An RC2014 Mini II running Microsoft BASIC
- A serial terminal

No additional hardware is required. The display uses plain text and does not require ANSI terminal support.

## Program Files

| File / Folder                | Description                                                                                                                                                                         |
| ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Components`                 | Separate files for each subroutine for independent amendment and numbering                                                                                                          |
| `seasonal_presence.bas`      | Seasonal presence model, describing detectability for species where activity is confined to a bounded window                                                                        |
| `winter_visitor.bas`         | Winter visitor model, describing detectability for species whose seasonal activity extends across the year boundary, typically arriving in autumn and departing in spring           |
| `resident_detectability.bas` | Resident detectability model, describing detectability for species present throughout the year but whose likelihood of being observed varies with seasonal conditions and behaviour |

## Running the Programs

Load the required program from the table, above, into BASIC and enter `RUN`

## Seasonal Modelling

These programs explore three complementary approaches to seasonal modelling:

- **Seasonal presence:** Species whose observable activity is confined to a particular part of the year, such as spring flowers and migratory birds
- **Resident detectability:** Species present throughout the year but whose likelihood of being observed varies with seasonal conditions and behaviour
- **Winter visitor:** Species whose seasonal activity extends across the year boundary, typically arriving in autumn and departing in spring

The models are deliberately simplified. Their purpose is to investigate how a small number of interacting processes might produce patterns resembling those found in observational data, rather than to provide detailed biological simulations or predict future observations.

Implementing them on the RC2014 provides an opportunity to explore numerical methods, particularly the use of ordinary differential equations (ODEs) and adaptive numerical integration, on an 8-bit computer.

### Seasonal Presence Model

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Ecology/bluebell-presence.png" alt="Bluebell Seasonal Presence" width="600">

The Seasonal Presence Model represents species whose observable presence is restricted to a particular part of the year. Examples include spring flowers, migratory birds and butterflies with relatively short annual flight periods.

The model uses an ordinary differential equation (ODE) to simulate the appearance, seasonal peak and subsequent disappearance of a species. It combines four simple processes:

- **Seasonal forcing:** Represents changing environmental conditions that encourage seasonal activity.
- **Seasonal availability:** Defines the period during which the species can be observed.
- **Baseline decay:** Limits the persistence of activity throughout the season.
- **Post-season suppression:** Accelerates the decline in activity as the season ends.

Together, these processes produce a seasonal curve that can rise gradually, reach a peak and then decline relatively rapidly. Adjustable parameters control the timing, duration and shape of the resulting seasonal pattern.

The program uses numerical integration to solve the model, with a choice of integration methods and optional adaptive step sizing. Results can be displayed as either a numerical table or a plain-text chart, allowing the model to be explored using a simple serial terminal.

The illustrated example simulates the seasonal presence of the bluebell (_Hyacinthoides non-scripta_), run using the following parameters:

| Parameter          | Value                 |
| ------------------ | --------------------- |
| Method             | 4th-Order Runge-Kutta |
| Adaptive Step Size | Yes                   |
| Tolerance          | 0.005                 |
| Initial Y          | 0.0                   |
| Limit of T         | 12.0                  |
| Step Size          | 0.1                   |

For a more detailed explanation of the model, its parameters and its relationship to observed wildlife data, see [Wildlife Seasonal Modelling](https://fieldnotesjournal.uk/wildlife/modelling/) in Field Notes Journal.

### Winter Visitor Model

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Ecology/redwing-presence.png" alt="Redwing Seasonal Presence" width="600">

The Winter Visitor Model represents species whose observable presence is concentrated in the winter months, extending across the calendar year boundary. Examples include migratory birds such as redwings, which typically arrive during autumn, reach peak presence during winter and depart during spring.

The model uses an ordinary differential equation (ODE) to simulate seasonal changes in observable activity. It defines a seasonal target towards which the modelled activity adjusts over time, combining three components:

- **Winter component:** Represents the main period of winter presence and determines the timing and strength of peak activity
- **Autumn component:** Optionally represents a distinct arrival phase, allowing activity to increase before the main winter peak
- **Summer suppression:** Reduces activity during the off-season, producing an extended period of near-absence through spring and summer

The seasonal target is constructed from smooth, periodic functions operating over a continuous 12-month cycle. Separate growth and decay rates control how quickly the modelled activity responds to the target as it rises and falls.

Together, these processes produce a winter-centred seasonal curve, with activity increasing through autumn, peaking during winter and declining into spring. Adjustable parameters control the timing, duration and shape of the resulting pattern, including the strength of the autumn arrival phase and the extent of summer suppression.

The program uses numerical integration to solve the model, with a choice of integration methods and optional adaptive step sizing. Results can be displayed as either a numerical table or a plain-text chart, allowing the model to be explored using a simple serial terminal.

The illustrated example simulates the seasonal presence of the redwing (_Turdus iliacus_), run using the following parameters:

| Parameter          | Value                 |
| ------------------ | --------------------- |
| Method             | 4th-Order Runge-Kutta |
| Adaptive Step Size | Yes                   |
| Tolerance          | 0.005                 |
| Initial Y          | 0.953                 |
| Limit of T         | 12.0                  |
| Step Size          | 0.1                   |

For a more detailed explanation of the model, its parameters and its relationship to observed wildlife data, see [Wildlife Seasonal Modelling](https://fieldnotesjournal.uk/wildlife/modelling/) in Field Notes Journal.

### Resident Detectability Model

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Ecology/blackbird-detectability.png" alt="Blackbird Resident Detectability" width="600">

The Resident Detectability Model represents species that remain present throughout the year but whose likelihood of being observed varies with seasonal conditions, behaviour and activity. Examples include resident birds such as blackbirds, whose visibility and activity can change considerably between seasons without the species becoming absent.

The model uses an ordinary differential equation (ODE) to simulate changes in detectability over a continuous annual cycle. It defines a seasonal target towards which modelled detectability adjusts over time, combining five components:

- **Persistent baseline:** Represents continuous year-round detectability, ensuring that seasonal variation does not imply seasonal absence
- **Winter component:** Represents increased visibility or activity during winter or early spring
- **Autumn component:** Optionally represents a distinct increase in detectability during autumn or early winter
- **Summer suppression:** Reduces detectability during the summer months without implying that the species is absent
- **Spring carry-over:** Optionally allows elevated detectability to persist into late spring or early summer before declining

The seasonal target is constructed from smooth, periodic functions operating over a continuous 12-month cycle. Separate growth and decay rates control how quickly modelled detectability responds to changes in the target, allowing seasonal increases and decreases to occur at different rates.

Additional optional mechanisms allow the model to reproduce more complex seasonal behaviour, including delayed summer decline, extended spring persistence and sharper reductions in detectability during late summer.

Together, these processes produce a continuous seasonal curve in which detectability typically increases towards winter or early spring, declines during summer and recovers during autumn. Adjustable parameters control the timing, strength and duration of these variations, allowing the model to represent different patterns of year-round activity.

The program uses numerical integration to solve the model, with a choice of integration methods and optional adaptive step sizing. Results can be displayed as either a numerical table or a plain-text chart, allowing the model to be explored using a simple serial terminal.

The illustrated example simulates the resident detectability of the blackbird (_Turdus merula_), run using the following parameters:

| Parameter          | Value                 |
| ------------------ | --------------------- |
| Method             | 4th-Order Runge-Kutta |
| Adaptive Step Size | Yes                   |
| Tolerance          | 0.005                 |
| Initial Y          | 0.944                 |
| Limit of T         | 12.0                  |
| Step Size          | 0.1                   |

For a more detailed explanation of the model, its parameters and its relationship to observed wildlife data, see [Wildlife Seasonal Modelling](https://fieldnotesjournal.uk/wildlife/modelling/) in Field Notes Journal.

## Implementation Notes

### Seasonal Modelling Programs

The programs are split into distinct subroutines, as follows:

| Line Numbers | Purpose                               |
| ------------ | ------------------------------------- |
| 0001 - 0999  | Main program flow                     |
| 1000 - 1999  | Initialise parameters used by the ODE |
| 2000 - 2999  | Implementation of the model ODE       |
| 3000 - 3099  | Euler Method                          |
| 3100 - 3199  | Euler Predictor-Corrector Method      |
| 3200 - 3399  | 4th-Order Runge-Kutta Method          |
| 3400 - 3999  | Adaptive step-size calculation        |
| 4000 - 4999  | Text table implementation             |
| 5000 - 5999  | Text chart implementation             |

## References

- [Differential Equations — Definitions](https://tutorial.math.lamar.edu/Classes/DE/Definitions.aspx), Paul’s Online Notes. An introduction to differential equations, their order, solutions and initial-value problems.
- [Euler’s Method](https://tutorial.math.lamar.edu/classes/de/EulersMethod.aspx), Paul’s Online Notes. Explains the method from tangent-line approximations, with worked examples, pseudocode and comparisons against exact solutions.
- [Heun’s Method](https://math.libretexts.org/Bookshelves/Differential_Equations/Numerically_Solving_Ordinary_Differential_Equations_%28Brorson%29/04%3A_Predictor-corrector_methods_and_Runge-Kutta/4.01%3A_Heuns_method), Stuart Brorson, Mathematics LibreTexts. Explains how an Euler prediction is corrected by averaging the starting and predicted endpoint slopes, with a diagram and algorithm.
- [Runge-Kutta Methods](https://math.libretexts.org/Bookshelves/Differential_Equations/Numerically_Solving_Ordinary_Differential_Equations_%28Brorson%29/04%3A_Predictor-corrector_methods_and_Runge-Kutta/4.06%3A_Runge-Kutta_methods), Stuart Brorson, Mathematics LibreTexts. Introduces classical RK4 through its four slope estimates and weighted update formula.
- [Wildlife Seasonal Modelling](https://fieldnotesjournal.uk/wildlife/modelling/), Dave Walker, Field Notes Journal
