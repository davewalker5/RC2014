10 REM Density altitude calculator
20 LET LR = .0019812 : REM ISA lapse rate, C/foot
30 LET CF = 120 : REM Density correction, feet/C
100 PRINT "DENSITY ALTITUDE CALCULATOR"
110 PRINT "==========================="
120 PRINT ""
200 REM Read and validate inputs
210 PRINT "Pressure altitude (-2000 to 36089 feet)"
220 INPUT PA
230 IF PA < -2000 OR PA > 36089 THEN PRINT "Invalid pressure altitude" : GOTO 210
240 PRINT "Outside-air temperature (-80 to 60 degrees C)"
250 INPUT OT
260 IF OT < -80 OR OT > 60 THEN PRINT "Invalid temperature" : GOTO 240
300 REM Calculate ISA temperature and density altitude
310 LET IT = 15 - LR * PA
320 LET DA = PA + CF * (OT - IT)
400 REM Round values for display
410 IF IT < 0 THEN LET IT = -INT(-IT * 10 + .5) / 10 : GOTO 430
420 LET IT = INT(IT * 10 + .5) / 10
430 IF DA < 0 THEN LET DA = -INT(-DA + .5) : GOTO 500
440 LET DA = INT(DA + .5)
500 PRINT ""
510 PRINT "ISA temperature: "; IT; " degrees C"
520 PRINT "Density altitude: "; DA; " feet"
600 REM Offer another calculation
610 PRINT ""
620 PRINT "More? (Y/N) ";
630 INPUT M$
640 IF M$ = "Y" OR M$ = "y" THEN GOTO 120
650 IF M$ <> "N" AND M$ <> "n" THEN PRINT "Enter Y or N" : GOTO 620
660 END
