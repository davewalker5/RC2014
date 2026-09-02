10 REM Aviation unit converter
20 REM Factors use international nautical mile, mile and foot
30 LET NK = 1.852 : REM Nautical miles to kilometres
40 LET NM = 1.15077945 : REM Nautical miles to statute miles
50 LET FM = .3048 : REM Feet to metres
60 LET KM = 1.15077945 : REM Knots to miles per hour
70 LET KK = 1.852 : REM Knots to kilometres per hour
100 PRINT "AVIATION UNIT CONVERTER"
110 PRINT "======================="
120 PRINT ""
130 PRINT "1  Nautical miles to statute miles"
140 PRINT "2  Statute miles to nautical miles"
150 PRINT "3  Nautical miles to kilometres"
160 PRINT "4  Kilometres to nautical miles"
170 PRINT "5  Feet to metres"
180 PRINT "6  Metres to feet"
190 PRINT "7  Knots to miles per hour"
200 PRINT "8  Miles per hour to knots"
210 PRINT "9  Knots to kilometres per hour"
220 PRINT "10 Kilometres per hour to knots"
230 PRINT "11 Celsius to Fahrenheit"
240 PRINT "12 Fahrenheit to Celsius"
250 PRINT "0  Exit"
260 PRINT ""
270 PRINT "Choice"
280 INPUT C
290 IF C <> INT(C) OR C < 0 OR C > 12 THEN PRINT "Enter a whole number from 0 to 12" : GOTO 270
300 IF C = 0 THEN END
310 IF C = 1 THEN GOSUB 1000
320 IF C = 2 THEN GOSUB 1100
330 IF C = 3 THEN GOSUB 1200
340 IF C = 4 THEN GOSUB 1300
350 IF C = 5 THEN GOSUB 1400
360 IF C = 6 THEN GOSUB 1500
370 IF C = 7 THEN GOSUB 1600
380 IF C = 8 THEN GOSUB 1700
390 IF C = 9 THEN GOSUB 1800
400 IF C = 10 THEN GOSUB 1900
410 IF C = 11 THEN GOSUB 2000
420 IF C = 12 THEN GOSUB 2100
430 PRINT ""
440 PRINT "Press RETURN for the menu"
450 INPUT A$
460 GOTO 100
900 REM Round R to three decimal places
910 IF R < 0 THEN LET R = -INT(-R * 1000 + .5) / 1000 : RETURN
920 LET R = INT(R * 1000 + .5) / 1000
930 RETURN
1000 PRINT "Nautical miles"
1010 INPUT V
1020 IF V < 0 THEN PRINT "Distance cannot be negative" : GOTO 1000
1030 LET R = V * NM : GOSUB 900
1040 PRINT R; " statute miles"
1050 RETURN
1100 PRINT "Statute miles"
1110 INPUT V
1120 IF V < 0 THEN PRINT "Distance cannot be negative" : GOTO 1100
1130 LET R = V / NM : GOSUB 900
1140 PRINT R; " nautical miles"
1150 RETURN
1200 PRINT "Nautical miles"
1210 INPUT V
1220 IF V < 0 THEN PRINT "Distance cannot be negative" : GOTO 1200
1230 LET R = V * NK : GOSUB 900
1240 PRINT R; " kilometres"
1250 RETURN
1300 PRINT "Kilometres"
1310 INPUT V
1320 IF V < 0 THEN PRINT "Distance cannot be negative" : GOTO 1300
1330 LET R = V / NK : GOSUB 900
1340 PRINT R; " nautical miles"
1350 RETURN
1400 PRINT "Feet"
1410 INPUT V
1420 LET R = V * FM : GOSUB 900
1430 PRINT R; " metres"
1440 RETURN
1500 PRINT "Metres"
1510 INPUT V
1520 LET R = V / FM : GOSUB 900
1530 PRINT R; " feet"
1540 RETURN
1600 PRINT "Knots"
1610 INPUT V
1620 IF V < 0 THEN PRINT "Speed cannot be negative" : GOTO 1600
1630 LET R = V * KM : GOSUB 900
1640 PRINT R; " miles per hour"
1650 RETURN
1700 PRINT "Miles per hour"
1710 INPUT V
1720 IF V < 0 THEN PRINT "Speed cannot be negative" : GOTO 1700
1730 LET R = V / KM : GOSUB 900
1740 PRINT R; " knots"
1750 RETURN
1800 PRINT "Knots"
1810 INPUT V
1820 IF V < 0 THEN PRINT "Speed cannot be negative" : GOTO 1800
1830 LET R = V * KK : GOSUB 900
1840 PRINT R; " kilometres per hour"
1850 RETURN
1900 PRINT "Kilometres per hour"
1910 INPUT V
1920 IF V < 0 THEN PRINT "Speed cannot be negative" : GOTO 1900
1930 LET R = V / KK : GOSUB 900
1940 PRINT R; " knots"
1950 RETURN
2000 PRINT "Degrees Celsius"
2010 INPUT V
2020 IF V < -273.15 THEN PRINT "Temperature is below absolute zero" : GOTO 2000
2030 LET R = V * 9 / 5 + 32 : GOSUB 900
2040 PRINT R; " degrees Fahrenheit"
2050 RETURN
2100 PRINT "Degrees Fahrenheit"
2110 INPUT V
2120 IF V < -459.67 THEN PRINT "Temperature is below absolute zero" : GOTO 2100
2130 LET R = (V - 32) * 5 / 9 : GOSUB 900
2140 PRINT R; " degrees Celsius"
2150 RETURN
