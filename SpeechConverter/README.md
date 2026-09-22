# Speech Converter

Speech Converter turns a typed English message into a Microsoft BASIC program for the MG005 speech synthesiser. The generated program contains numbered `DATA` statements and matching `REM` statements naming each SP0256-AL2 allophone. It waits for the module's ready bit before sending each code.

## Running the Converter

The converter accepts the following command line arguments:

| Setting           | Long option | Short option |                                          Default |
| ----------------- | ----------- | ------------ | -----------------------------------------------: |
| Phrase to convert | `--text`    | `-t`         | If omitted, the application prompts for a phrase |
| Output file path  | `--output`  | `-o`         |               `speech.bas` in the current folder |

For example, from the project root:

```sh
dotnet run --project SpeechConverter/SpeechConverter -- --text "Hello Z80" --output hello-z80.bas
```

This produces the following output:

```basic
10 REM MG005 SP0256-AL2 SPEECH
20 FOR I=1 TO 13
30 READ A
40 IF (INP(31) AND 2)=0 THEN GOTO 40
50 OUT 31,A
60 NEXT I
70 END
80 REM HH1 EH LL OW PA3 ZZ EH DD1 PA3 EY TT2 IY
90 DATA 27,7,45,53,2,43,7,21,2,20,13,19
100 REM PA1
110 DATA 0
```

The `DATA` statements contain the allophone codes; each preceding `REM` statement names the corresponding sounds.

## How It Works

### Pronunciation Configuration

The file `pronunciation.json` provides pronunciation configuration as follows:

| Section      | Purpose                                                                                  |
| ------------ | ---------------------------------------------------------------------------------------- |
| `allophones` | All 64 SP0256-AL2 names and their numeric codes, including pauses                        |
| `words`      | Whole-word pronunciations, expressed as space-separated allophone names                  |
| `units`      | Number names for indexes 0 through 19; index 0 is unused because zero uses `words.ZERO`  |
| `tens`       | Names for indexes 0 through 9, representing multiples of ten; indexes 0 and 1 are unused |
| `patterns`   | Ordered spelling fragments and their allophones; the first matching fragment wins        |
| `letters`    | Single-letter fallback sounds for A through Z                                            |

The loader checks that the code table contains 64 distinct codes, that the number and letter tables are complete, and that configured sound names exist. It reports invalid mappings before generating BASIC. Longer or more specific spelling rules appear before broader ones in `patterns`.

### From Message to Sounds

The message is split into English letter groups, decimal numbers and punctuation (`. , ! ? ; :`). Case does not matter. For example:

| Phrase      | Tokens             |
| ----------- | ------------------ |
| `Hello Z80` | `HELLO`, `Z`, `80` |

Other characters, including apostrophes, are not pronunciation instructions and instead act as separators where they divide two recognised groups.

A small word list in the published [pronunciation.json](SpeechConverter.Logic/Pronunciation/pronunciation.json) supplies hand-chosen allophones for common words, number names and a few project terms. `HELLO` becomes `HH1 EH LL OW`, and `Z` becomes `ZZ EH DD1` (“zed”).

A decimal number from 0 to 9999 is spoken as an English number: `80` becomes `EIGHTY`; `120` becomes `ONE HUNDRED TWENTY`. The converter rejects larger numbers. Each number word then goes through the same word lookup or spelling rules. Numbers embedded in a name are separate tokens, so `Z80` becomes “zed eighty.”

A word absent from the built-in list uses approximate spelling rules. The converter removes a final `E` from words longer than two letters, then scans left to right. It tries letter groups such as `SH`, `TH`, `EE`, `TION` and `OUGH` before falling back to individual letters. For example, `SH` maps to the `SH` allophone and `PH` maps to `FF`.

Note that these rules are intentionally simple and cannot reliably choose English vowel sounds, stress, or the pronunciation of every name.

Each allophone name maps to the SP0256-AL2's numeric code, from 0 to 63. These are sounds rather than character codes: `HH1 EH LL OW` maps to `27,7,45,53` for “hello.” The converter keeps both forms so the `REM` lines identify the sounds behind the `DATA` values.

### Pauses and Punctuation

The application applies pauses according to the following rules:

| Context                                                                                | Allophone | Code | Pause Length |
| -------------------------------------------------------------------------------------- | --------- | ---- | ------------ |
| Between ordinary tokens                                                                | PA3       | 2    | 50 ms        |
| Within a number spoken as several words                                                | PA2       | 1    | 30 ms        |
| A comma, full stop, exclamation mark, question mark, colon or semicolon between tokens | PA5       | 4    | 200ms        |
| At the end of every message                                                            | PA1       | 0    | 10ms         |

Punctuation at the very end does not create another pause.

For `Hello Z80`, the resulting sequence is:

```text
HH1 EH LL OW | PA3 | ZZ EH DD1 | PA3 | EY TT2 IY | PA1
27  7  45 53 | 2   | 43 7  21  | 2   | 20 13  19 | 0
```

### Limitations

The word list and spelling rules are deliberately modest.

For unfamiliar words, abbreviations, contractions and names, it is advisable to inspect the `REM` lines and listen to the result.

A permanent pronunciation amendment can be made in `pronunciation.json` without changing C# code. Add a word to `words`, using space-separated allophone names from `allophones`. Dictionary entries may contain apostrophes, such as `"I'M": "AY MM"`. Straight and curly apostrophes in input both match that entry; contractions without an entry are split and processed by the existing word rules. For example:

`"HELLO": "HH1 EH LL OW"`.

There is currently no pronunciation override option in the command line.
