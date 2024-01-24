# Roman Numeral to Decimal Converter

This implementation is based on [this Gist](https://gist.github.com/davewalker5/4dee6b24ff02928d46a88a974b401766)

## Roman Numerals

Using only characters with no additional annotations (such as bars above) the system of Roman numerals can represent numbers between 1 and 3,999 using combinations of the following:

|     | Thousands | Hundreds | Tens | Units |
| --- | --------- | -------- | ---- | ----- |
| 1   | M         | C        | X    | I     |
| 2   | MM        | CC       | XX   | II    |
| 3   | MMM       | CCC      | XXX  | III   |
| 4   |           | CD       | XL   | IV    |
| 5   |           | D        | L    | V     |
| 6   |           | DC       | LX   | VI    |
| 7   |           | DCC      | LXX  | VII   |
| 8   |           | DCCC     | LXXX | VIII  |
| 9   |           | CM       | XC   | IX    |

For example, the number 1,965 is represented as MCMLXV, which is the concatenation of the numerals for 1000, 900, 60 and 5.

# Parser

Armed with this information, a parser can be constructed by:

- Looking for the numeral for the units on the right hand end of the string
  - The search is done in _decreasing_ order of numeral length i.e. VIII, VII, IX etc.
  - This ensures that, for example, if the string ends with III it will correctly determine the units as 3 rather than 1
- If found, trim the numeral from the end of the string and add the value associated with the numeral to the results
- Repeat the process for tens, then hundreds and thousands
- At the end of the process, the string should be zero length - if not, then there is a formatting issue with the string

# Worked Example

| Step | String | Detect    | Found | Decimal | Running Total | Resulting String |
| ---- | ------ | --------- | ----- | ------- | ------------- | ---------------- |
| 1    | MCMLXV | Units     | V     | 5       | 5             | MCMLX            |
| 2    | MCMLX  | Tens      | LX    | 60      | 65            | MCM              |
| 3    | MCM    | Hundreds  | CM    | 900     | 965           | M                |
| 4    | M      | Thousands | M     | 1000    | 1965          | Empty            |
