10 PRINT "Enter year: ";: INPUT Y
20 PRINT "Enter month: ";: INPUT M
30 PRINT "Enter day: ";: INPUT D
40 REM Normalize the year by subtracting 2000
50 LET Y = Y - 2000
60 REM Adjust year and month for January and February
70 IF M < 3 THEN LET Y = Y - 1: LET M = M + 12
80 REM Calculate the Julian date
90 LET A = INT(Y / 100)
100 LET B = 2 - A + INT(A / 4)
110 LET J = INT(365.25 * Y) + INT(30.6001 * (M + 1)) + D + 1720994.5 + B
120 REM Calculate the number of New Moons since the New Moon of 1/6/2000
130 REM Convert the fractional part to days to get the age of the moon
140 LET IP = (J - 2451550.1) / 29.53058867
150 LET IP = IP - INT(IP)
160 LET AG = IP * 29.53058867
170 REM If the age is negative, adjust it by adding the length of a lunar month
180 IF AG < 0 THEN LET AG = AG + 29.53058867
190 REM Print the age of the moon in days
200 PRINT "The age of the moon is "; AG; " days"
210 REM Determine the phase of the moon based on its age
220 IF AG < 1 THEN PRINT "New Moon"
230 IF AG >= 1 AND AG < 7.4 THEN PRINT "First Quarter: Waxing Crescent"
240 IF AG >= 7.4 AND AG < 14.8 THEN PRINT "First Quarter: Waxing Gibbous"
250 IF AG >= 14.8 AND AG < 22.1 THEN PRINT "Full Moon"
260 IF AG >= 22.1 AND AG < 29.5 THEN PRINT "Last Quarter: Waning Gibbous"
270 IF AG >= 29.5 THEN PRINT "Last Quarter: Waning Crescent"
280 M$ = "" : PRINT "More (Y/N): ";: INPUT M$
290 IF M$ = "Y" OR M$ = "y" THEN GOTO 10
300 END
