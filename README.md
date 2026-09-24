[![Build Status](https://github.com/davewalker5/RC2014/workflows/.NET%20tests%20and%20coverage/badge.svg)](https://github.com/davewalker5/RC2014/actions/)
[![GitHub issues](https://img.shields.io/github/issues/davewalker5/RC2014)](https://github.com/davewalker5/RC2014/issues)
[![Releases](https://img.shields.io/github/v/release/davewalker5/RC2014.svg?include_prereleases)](https://github.com/davewalker5/RC2014/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/davewalker5/RC2014/blob/master/LICENSE)
[![Language](https://img.shields.io/badge/language-BASIC-blue.svg)](https://github.com/davewalker5/RC2014)
[![Language](https://img.shields.io/badge/language-c%23-blue.svg)](https://github.com/davewalker5/RC2014/)
[![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/davewalker5/RC2014)](https://github.com/davewalker5/RC2014/)

# RC2014

A collection of programs, experiments and utilities written for the **RC2014 Mini II**, a Zilog Z80-based 8-bit computer.

<img src="https://github.com/davewalker5/RC2014/blob/main/Images/rc2014-workbench.jpg" alt="The completed experimental RC2014 hardware configuration" width="600">

*The completed experimental RC2014 hardware configuration*

## About

The [RC2014](https://rc2014.co.uk) is a family of modular Z80 computers inspired by the simplicity and accessibility of early home and hobbyist computing.

This repository began as a place for small programs and utilities written for my RC2014 Mini II, but has grown into a broader collection of experiments exploring what can be done with a small 8-bit machine and Microsoft BASIC.

The emphasis is deliberately on programs that are **interesting to write, understandable to read and enjoyable to run** rather than on recreating modern software on old hardware.

The collection now includes:

* **Aviation** — great-circle calculations, bearings, wind correction, atmospheric calculations and unit conversion
* **Games & simulations** — including Blackjack, Bulls and Cows, lunar descent, cave exploration and an autonomous virtual octopus
* **Mathematics & science** — cellular automata, Conway's Game of Life, barycentres, Fibonacci numbers and lunar phases
* **Computing & algorithms** — logic gates, stacks, queues and Z80 assembly experiments
* **Hardware experiments** — programs using Digital I/O, LCD, sound and speech synthesis
* **Music** — music for the SID-Ulator, including programs generated from Standard MIDI Files
* **Utilities & converters** — including base conversion, Morse code, Roman numerals and terminal tests

The complete and current list is maintained in the **[Program Catalogue](Programs/README.md)**.

## The 1979 Machine

The RC2014 used for this project has gradually developed into what I think of as **the 1979 machine**.

It is not intended to be a historically exact recreation of a computer that existed in 1979. Instead, it is my interpretation of the simple, accessible and experimental character of hobby computing around that time, and reflects some of my own earliest experiences of personal computing.

The completed hardware combines a Z80 with a serial terminal, physical buttons and LEDs, a character LCD, programmable sound and hardware speech synthesis. The emphasis is on keeping the relationship between software and hardware visible and understandable.

That also provides a deliberate constraint. This machine is not intended to accumulate every available RC2014 expansion or evolve into a more modern general-purpose computer. Future development will concentrate primarily on finding new ways to use and combine the capabilities already present.

Other directions remain interesting but they will become separate RC2014 projects, each exploring a different aspect of what can be built around the Z80 platform.

For this machine, the hardware is finished.

The more interesting question remains:

> **What can I make this thing do?**

## Programs

All of the programs are written in **BASIC** and are intended to run directly on the RC2014.

Each program has its own directory and README describing what it does, how it works and how to run it. Where appropriate, the documentation also covers configuration for optional hardware such as the Digital I/O card.

Some programs are practical. Some demonstrate algorithms or computing concepts. Others exist simply because making a Z80 do something unexpected is fun.

<img src="https://github.com/davewalker5/RC2014/blob/main/Images/rc2014-mini-ii-pc.jpg" alt="RC2014 Mini II connected to a PC and running the Roman Numerals program" width="600">

*RC2014 Mini II connected to a PC and running the Roman Numerals program*

## Exploring the Repository

A good place to start is the **[Programs](Programs/)** directory.

The programs are grouped in the catalogue into:

* Aviation
* Games & Simulations
* Mathematics & Science
* Computing & Algorithms
* Hardware & Digital I/O
* Utilities & Converters

Individual program directories contain their own documentation, source code and any supporting material.

## Hardware

The machine used for development is an [**RC2014 Mini II**](https://rc2014.co.uk/full-kits/rc2014-mini-ii/).

A number of programs also make use of expansion hardware, including:

* [RC2014 Digital I/O card](https://rc2014.co.uk/modules/digital-io/)
* [RC2014 LCD Driver Module](https://rc2014.co.uk/modules/lcd-driver-module/)
* [SID-Ulator sound module](https://z80kits.com/shop/sid-ulator-sound-module/)
* [MG005 SP0256-AL2 speech synthesiser](https://www.tindie.com/products/mrgelee/mg005-speech-synthesiser-designed-for-rc2014/)

Together these provide physical input and output through buttons and LEDs, a dedicated character display, programmable sound and music, and hardware speech synthesis.

Programs requiring additional hardware are identified in their individual documentation.

## Getting Started

Browse the **[Program Catalogue](Programs/README.md)** and choose something that looks interesting.

Each program's README contains the relevant instructions for running it and, where necessary, configuring it for the hardware being used.

For more information about RC2014 computers, kits and expansion modules, see:

https://rc2014.co.uk

## Licences

Unless otherwise noted, this repository is licensed under the [MIT licence](LICENSE). Individual file and third-party notices take precedence.

[EmulatorSupport](EmulatorSupport/README.md) contains components under separate GPL and BSD licences, alongside MIT-licensed support files. See its [licence map](EmulatorSupport/LICENSE.md) for the exceptions and included licence texts. The repository's MIT licence does not relicense these components or downloaded firmware.

## Authors

* **Dave Walker** — initial work and ongoing development

## Feedback

Issues, suggestions and ideas are welcome.

Please use the project's [Issues](https://github.com/davewalker5/RC2014/issues) page on GitHub.
