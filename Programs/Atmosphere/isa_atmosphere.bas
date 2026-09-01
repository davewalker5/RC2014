10 REM ISA atmosphere calculator
20 REM Troposphere model: -2000 to 36089 feet
30 LET T0 = 288.15 : REM Sea-level temperature, kelvin
40 LET P0 = 1013.25 : REM Sea-level pressure, hPa
50 LET LR = .0065 : REM Temperature lapse rate, K/m
60 LET EX = 5.25588 : REM Pressure exponent
70 LET FC = .3048 : REM Feet to metres
100 PRINT "ISA ATMOSPHERE CALCULATOR"
110 PRINT "========================="
120 PRINT ""
130 PRINT "Standard troposphere model"
140 PRINT "Altitude range: -2000 to 36089 feet"
200 REM Read and validate altitude
210 PRINT ""
220 PRINT "Altitude (feet)"
230 INPUT AL
240 IF AL < -2000 OR AL > 36089 THEN PRINT "Altitude is outside model range" : GOTO 220
300 REM Calculate ISA conditions
310 LET HM = AL * FC
320 LET TK = T0 - LR * HM
330 LET TC = TK - 273.15
340 LET PR = P0 * (TK / T0) ^ EX
350 LET DN = PR * 100 / (287.05 * TK)
400 REM Round values for display
410 IF TC < 0 THEN LET TC = -INT(-TC * 10 + .5) / 10 : GOTO 430
420 LET TC = INT(TC * 10 + .5) / 10
430 LET PR = INT(PR * 10 + .5) / 10
440 LET DN = INT(DN * 1000 + .5) / 1000
500 PRINT ""
510 PRINT "Standard temperature: "; TC; " degrees C"
520 PRINT "Standard pressure: "; PR; " hPa"
530 PRINT "Standard density: "; DN; " kg/m3"
600 REM Offer another calculation
610 PRINT ""
620 PRINT "More? (Y/N) ";
630 INPUT M$
640 IF M$ = "Y" OR M$ = "y" THEN GOTO 120
650 IF M$ <> "N" AND M$ <> "n" THEN PRINT "Enter Y or N" : GOTO 620
660 END
