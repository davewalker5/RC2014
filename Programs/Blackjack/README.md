# Blackjack

<img src="https://github.com/davewalker5/RC2014/blob/main/Programs/Blackjack/blackjack.png" alt="Blackjack" width="600">

Blackjack is a compact, text-only implementation of the card game for the RC2014. Play against a computer dealer and try to reach 21 without going over.

## Hardware

The program requires:

- An RC2014 computer running Microsoft BASIC
- A serial terminal

No additional hardware is required.

## Program Files

| Filename        | Content                         |
| --------------- | ------------------------------- |
| `blackjack.bas` | Blackjack game implementation   |

## Running the Program

Load `blackjack.bas` into BASIC and enter `RUN`.

## How to Play

The player and dealer are each dealt two cards. One of the dealer's cards remains hidden until the player's turn is over.

- Enter `H` to hit and receive another card
- Enter `S` to stand and let the dealer play
- Number cards are worth their face value
- Jacks, queens and kings are worth 10
- Aces are worth 11 unless that would make the hand exceed 21, in which case they are worth 1
- Going over 21 is a bust and loses the hand
- The dealer draws until reaching 17 or more, including a soft 17
- The higher hand at or below 21 wins; equal totals are a push
- A two-card 21 is reported as blackjack and wins immediately, unless both player and dealer have blackjack

After each hand, enter `Y` to play again with a newly shuffled deck or `N` to quit.

## Card Display

Cards use a short rank-and-suit notation suitable for a text terminal. For example, `AS` is the ace of spades, `10H` is the ten of hearts and `QD` is the queen of diamonds.

| Letter | Suit     |
| ------ | -------- |
| `S`    | Spades   |
| `H`    | Hearts   |
| `D`    | Diamonds |
| `C`    | Clubs    |

## Implementation Notes

- Each hand starts with a complete 52-card deck represented by unique values from 0 to 51
- The deck is shuffled in place using the Fisher-Yates algorithm
- Cards are dealt sequentially from the shuffled deck, so a card cannot appear twice in one hand
- The scoring routine initially counts every ace as 11, then changes aces to 1 as needed until the total is 21 or less
- The dealer stands on every total of 17 or more

As with the other programs in this catalogue, randomness is supplied by BASIC's `RND` function. Its sequence depends on the BASIC implementation and machine state.
