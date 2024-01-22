10 REM This program calculates the phase of the moon for a given date using John Conway's algorithm.
20 REM It first calculates the Julian date for the given date, then calculates the number of New Moons
30 REM since the New Moon of 1/6/2000. The fractional part of this number is the age of the moon in days.
40 REM If the age is negative, it is adjusted by adding the length of a lunar month.
50 REM The program was written by Lee Hart, 1/2019.
60 PRINT "Enter year:"
65 INPUT Y
70 PRINT "Enter month: "
75 INPUT M
80 PRINT "Enter day: "
85 INPUT D
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
280 IF AG >= 1 AND AG < 7.4 THEN PRINT "First Quarter: Waxing Crescent"
290 IF AG >= 7.4 AND AG < 14.8 THEN PRINT "First Quarter: Waxing Gibbous"
300 IF AG >= 14.8 AND AG < 22.1 THEN PRINT "Full Moon"
310 IF AG >= 22.1 AND AG < 29.5 THEN PRINT "Last Quarter: Waning Gibbous"
320 IF AG >= 29.5 THEN PRINT "Last Quarter: Waning Crescent"
330 END
