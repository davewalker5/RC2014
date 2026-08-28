# Animal Guessing Game

<img src="https://github.com/davewalker5/RC2014/blob/main/Applications/Animal/animal.png" alt="Animal Guessing Game" width="600">

Animal is a simple guessing game for Microsoft BASIC. The player thinks of an animal and answers a series of yes-or-no questions while the computer tries to identify it.

The game begins knowing only about a fish. When it cannot identify an animal, it asks the player for its name and for a question that can be used to recognise it. The new animal and question are added to the game's knowledge for subsequent rounds.

## Requirements

- An RC2014 computer running BASIC
- A serial terminal

No additional hardware is required.

## Playing the Game

1. Load and run `animal.bas`
2. Think of an animal and answer `Y` when prompted
3. Answer each question with `Y` or `N`
4. If the computer guesses correctly, answer `Y` and choose whether to play again
5. If the computer cannot identify the animal, enter its name and a question that distinguishes it from the computer's last incorrect guess

For example, if the computer guesses **Fish** when the animal is a dolphin, enter `dolphin` as the animal and a question such as `Does it breathe air`. On a later round, the computer can use that question to distinguish a dolphin from a fish.

## How Learning Works

Each animal is stored with a yes-or-no question that applies to it. During a round, the program works through the stored questions. When the answer to a question is yes, it proposes the associated animal. If that guess is wrong, it remembers the animal and continues checking the rest of its knowledge before asking the player to teach it something new.

The program can hold up to 100 animals. Learned animals are kept only while the BASIC program remains running; restarting the program restores the initial dataset.

Questions should:

- Have `Y` as the correct answer for the new animal
- Describe a useful characteristic rather than name the animal directly
- Be short enough to read comfortably in the terminal

## Files

| Filename     | Content                          |
| ------------ | -------------------------------- |
| `animal.bas` | Animal guessing game source code |
| `animal.png` | Example game session             |

## Acknowledgements

This is an original implementation inspired by _Animal_, credited to Arthur Luehrmann, Nathan Teichholtz, and Steve North in _BASIC Computer Games_, edited by David H. Ahl (1978).
