__davewalker5:__ Can you write me a program in ANSI BASIC  to calculate the phase of the moon?

__GitHub Copilot:__ Sure, here's a simple program in ANSI BASIC to calculate the phase of the moon. This program uses John Conway's algorithm for calculating the moon phase.

```vb
10 INPUT "Enter year: ", Y
20 INPUT "Enter month: ", M
21 INPUT "Enter day: ", D
30 LET Y = Y - 2000
40 IF M < 3 THEN LET Y = Y - 1: LET M = M + 12
50 LET A = INT(Y / 100)
60 LET B = 2 - A + INT(A / 4)
70 LET J = INT(365.25 * Y) + INT(30.6001 * (M + 1)) + D + 1720994.5 + B
80 LET IP = (J - 2451550.1) / 29.53058867
90 LET IP = IP - INT(IP)
100 LET AG = IP * 29.53058867
110 IF AG < 0 THEN LET AG = AG + 29.53058867
120 PRINT "The age of the moon is "; AG; " days"
130 END
```

This program asks for a date (year, month, day) and calculates the Julian date for that day. Then it calculates the number of New Moons that have occurred since the New Moon of 1/6/2000. The fractional part of this number is used to compute the age of the moon in days.

Please note that this is a simplified version of the algorithm and it may not give accurate results for dates far in the past or future.

__davewalker5:__ Can you add comments to the program to explain how it works?

__GitHub Copilot:__ Sure, here's the program with added comments to explain how it works:

```vb
10 INPUT "Enter year: ", Y ' Ask the user for the year
20 INPUT "Enter month: ", M ' Ask the user for the month
21 INPUT "Enter day: ", D ' Ask the user for the day
30 LET Y = Y - 2000 ' Normalize the year by subtracting 2000
40 IF M < 3 THEN LET Y = Y - 1: LET M = M + 12 ' Adjust year and month for January and February
50 LET A = INT(Y / 100) ' Calculate A as the integer part of year/100
60 LET B = 2 - A + INT(A / 4) ' Calculate B based on A
70 LET J = INT(365.25 * Y) + INT(30.6001 * (M + 1)) + D + 1720994.5 + B ' Calculate the Julian date
80 LET IP = (J - 2451550.1) / 29.53058867 ' Calculate the number of New Moons since the New Moon of 1/6/2000
90 LET IP = IP - INT(IP) ' Get the fractional part of the number of New Moons
100 LET AG = IP * 29.53058867 ' Convert the fractional part to days to get the age of the moon
110 IF AG < 0 THEN LET AG = AG + 29.53058867 ' If the age is negative, adjust it by adding the length of a lunar month
120 PRINT "The age of the moon is "; AG; " days" ' Print the age of the moon in days
130 END ' End the program
```

This program calculates the phase of the moon for a given date using John Conway's algorithm. It first calculates the Julian date for the given date, then calculates the number of New Moons that have occurred since the New Moon of 1/6/2000. The fractional part of this number is used to compute the age of the moon in days.

__davewalker5:__ Can you convert the comments to use REM statements instead

__GitHub Copilot:__ Sure, here's the program with comments converted to use REM statements:

```vb
10 INPUT "Enter year: ", Y: REM Ask the user for the year
20 INPUT "Enter month: ", M: REM Ask the user for the month
21 INPUT "Enter day: ", D: REM Ask the user for the day
30 LET Y = Y - 2000: REM Normalize the year by subtracting 2000
40 IF M < 3 THEN LET Y = Y - 1: LET M = M + 12: REM Adjust year and month for January and February
50 LET A = INT(Y / 100): REM Calculate A as the integer part of year/100
60 LET B = 2 - A + INT(A / 4): REM Calculate B based on A
70 LET J = INT(365.25 * Y) + INT(30.6001 * (M + 1)) + D + 1720994.5 + B: REM Calculate the Julian date
80 LET IP = (J - 2451550.1) / 29.53058867: REM Calculate the number of New Moons since the New Moon of 1/6/2000
90 LET IP = IP - INT(IP): REM Get the fractional part of the number of New Moons
100 LET AG = IP * 29.53058867: REM Convert the fractional part to days to get the age of the moon
110 IF AG < 0 THEN LET AG = AG + 29.53058867: REM If the age is negative, adjust it by adding the length of a lunar month
120 PRINT "The age of the moon is "; AG; " days": REM Print the age of the moon in days
130 END: REM End the program
```

In ANSI BASIC, the REM statement is used for adding comments. The statement REM (short for REMARK) allows you to add a comment that the computer will ignore when running the program.

__davewalker5:__ Can you place the REM comments on separate lines, just before the line they refer to?

__GitHub Copilot:__ Sure, here's the program with REM comments placed on separate lines, just before the line they refer to:

```vb
REM Ask the user for the year
10 INPUT "Enter year: ", Y
REM Ask the user for the month
20 INPUT "Enter month: ", M
REM Ask the user for the day
21 INPUT "Enter day: ", D
REM Normalize the year by subtracting 2000
30 LET Y = Y - 2000
REM Adjust year and month for January and February
40 IF M < 3 THEN LET Y = Y - 1: LET M = M + 12
REM Calculate A as the integer part of year/100
50 LET A = INT(Y / 100)
REM Calculate B based on A
60 LET B = 2 - A + INT(A / 4)
REM Calculate the Julian date
70 LET J = INT(365.25 * Y) + INT(30.6001 * (M + 1)) + D + 1720994.5 + B
REM Calculate the number of New Moons since the New Moon of 1/6/2000
80 LET IP = (J - 2451550.1) / 29.53058867
REM Get the fractional part of the number of New Moons
90 LET IP = IP - INT(IP)
REM Convert the fractional part to days to get the age of the moon
100 LET AG = IP * 29.53058867
REM If the age is negative, adjust it by adding the length of a lunar month
110 IF AG < 0 THEN LET AG = AG + 29.53058867
REM Print the age of the moon in days
120 PRINT "The age of the moon is "; AG; " days"
REM End the program
130 END
```

This way, each comment directly precedes the line of code it explains, making it easier to understand the purpose of each line.

__davewalker5:__ Can you add line numbers to the REM statements and renumber the program starting at line 10?

__GitHub Copilot:__ Sure, here's the program with REM comments placed on separate lines, each with its own line number, and the program renumbered starting at line 10:

```vb
10 REM Ask the user for the year
20 INPUT "Enter year: ", Y
30 REM Ask the user for the month
40 INPUT "Enter month: ", M
50 REM Ask the user for the day
60 INPUT "Enter day: ", D
70 REM Normalize the year by subtracting 2000
80 LET Y = Y - 2000
90 REM Adjust year and month for January and February
100 IF M < 3 THEN LET Y = Y - 1: LET M = M + 12
110 REM Calculate A as the integer part of year/100
120 LET A = INT(Y / 100)
130 REM Calculate B based on A
140 LET B = 2 - A + INT(A / 4)
150 REM Calculate the Julian date
160 LET J = INT(365.25 * Y) + INT(30.6001 * (M + 1)) + D + 1720994.5 + B
170 REM Calculate the number of New Moons since the New Moon of 1/6/2000
180 LET IP = (J - 2451550.1) / 29.53058867
190 REM Get the fractional part of the number of New Moons
200 LET IP = IP - INT(IP)
210 REM Convert the fractional part to days to get the age of the moon
220 LET AG = IP * 29.53058867
230 REM If the age is negative, adjust it by adding the length of a lunar month
240 IF AG < 0 THEN LET AG = AG + 29.53058867
250 REM Print the age of the moon in days
260 PRINT "The age of the moon is "; AG; " days"
270 REM End the program
280 END
```

This way, each comment and each line of code has its own line number, making it easier to refer to specific lines. The program now starts at line 10 and increments by 10 for each new line.

__davewalker5:__ Can you take the MoonPhase.bas file as it is and renumber from line 10 in increments of 10?

__GitHub Copilot:__ Sure, here's the MoonPhase.bas file renumbered from line 10 in increments of 10:

```vb
10 REM This program calculates the phase of the moon for a given date using John Conway's algorithm.
20 REM It first calculates the Julian date for the given date, then calculates the number of New Moons
30 REM since the New Moon of 1/6/2000. The fractional part of this number is the age of the moon in days.
40 REM If the age is negative, it is adjusted by adding the length of a lunar month.
50 REM The program was written by Lee Hart, 1/2019.
60 INPUT "Enter year: ", Y
70 INPUT "Enter month: ", M
80 INPUT "Enter day: ", D
90 REM Normalize the year by subtracting 2000
100 LET Y = Y - 2000
110 REM Adjust year and month for January and February
120 IF M < 3 THEN LET Y = Y - 1: LET M = M + 12
130 REM Calculate the Julian date
140 LET A = INT(Y / 100)
150 LET B = 2 - A + INT(A / 4)
160 LET J = INT(365.25 * Y) + INT(30.6001 * (M + 1)) + D + 1720994.5 + B
170 REM Calculate the number of New Moons since the New Moon of 1/6/2000
180 REM Convert the fractional part to days to get the age of the moon
190 LET IP = (J - 2451550.1) / 29.53058867
200 LET IP = IP - INT(IP)
210 LET AG = IP * 29.53058867
220 REM If the age is negative, adjust it by adding the length of a lunar month
230 IF AG < 0 THEN LET AG = AG + 29.53058867
240 REM Print the age of the moon in days
250 PRINT "The age of the moon is "; AG; " days"
260 END
```

This way, each line of code and each comment has its own line number, starting from 10 and incrementing by 10 for each new line.

__davewalker5:__ At the end, can you make it output the descriptive phase name for the moon's age?

__GitHub Copilot:__ Sure, we can add a series of IF statements to output the descriptive phase name for the moon's age. Here's the updated code:

```vb
10 REM This program calculates the phase of the moon for a given date using John Conway's algorithm.
20 REM It first calculates the Julian date for the given date, then calculates the number of New Moons
30 REM since the New Moon of 1/6/2000. The fractional part of this number is the age of the moon in days.
40 REM If the age is negative, it is adjusted by adding the length of a lunar month.
50 REM The program was written by Lee Hart, 1/2019.
60 INPUT "Enter year: ", Y
70 INPUT "Enter month: ", M
80 INPUT "Enter day: ", D
90 REM Normalize the year by subtracting 2000
100 LET Y = Y - 2000
110 REM Adjust year and month for January and February
120 IF M < 3 THEN LET Y = Y - 1: LET M = M + 12
130 REM Calculate the Julian date
140 LET A = INT(Y / 100)
150 LET B = 2 - A + INT(A / 4)
160 LET J = INT(365.25 * Y) + INT(30.6001 * (M + 1)) + D + 1720994.5 + B
170 REM Calculate the number of New Moons since the New Moon of 1/6/2000
180 REM Convert the fractional part to days to get the age of the moon
190 LET IP = (J - 2451550.1) / 29.53058867
200 LET IP = IP - INT(IP)
210 LET AG = IP * 29.53058867
220 REM If the age is negative, adjust it by adding the length of a lunar month
230 IF AG < 0 THEN LET AG = AG + 29.53058867
240 REM Print the age of the moon in days
250 PRINT "The age of the moon is "; AG; " days"
260 REM Determine the phase of the moon based on its age
270 IF AG < 1 THEN PRINT "New Moon"
280 IF AG >= 1 AND AG < 7.4 THEN PRINT "First Quarter - Waxing Crescent"
290 IF AG >= 7.4 AND AG < 14.8 THEN PRINT "First Quarter - Waxing Gibbous"
300 IF AG >= 14.8 AND AG < 22.1 THEN PRINT "Full Moon"
310 IF AG >= 22.1 AND AG < 29.5 THEN PRINT "Last Quarter - Waning Gibbous"
320 IF AG >= 29.5 THEN PRINT "Last Quarter - Waning Crescent"
330 END
```

This code will output the descriptive phase name for the moon's age. The moon's age is divided into six ranges, each corresponding to a different phase of the moon.