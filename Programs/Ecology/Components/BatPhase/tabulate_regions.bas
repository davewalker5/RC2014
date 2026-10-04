5300 REM Tabulate the regions
5310 LET CW = 15 : PRINT
5320 REM Print region table column headers
5330 LET PD$ = " "
5340 LET V$ = "Phase" : GOSUB 6030 : PRINT " ";
5350 LET V$ = "Start" : GOSUB 6030 : PRINT " ";
5360 LET V$ = "End" : GOSUB 6030 : PRINT " ";
5370 LET V$ = "Length" : GOSUB 6030 : PRINT
5380 REM Print table header separator
5390 LET PD$ = "-"
5400 LET V$ = "-" : GOSUB 6030 : PRINT " ";
5410 LET V$ = "-" : GOSUB 6030 : PRINT " ";
5420 LET V$ = "-" : GOSUB 6030 : PRINT " ";
5430 LET V$ = "-" : GOSUB 6030 : PRINT
5440 LET PD$ = " "
5450 REM Iterate over and tabulate the regions
5460 FOR X = 1 TO NR
5470 LET V$ = CL$(X) : GOSUB 6030 : PRINT " ";
5480 LET V$ = STR$(PS(X)) : GOSUB 6000 : PRINT " ";
5490 LET V$ = STR$(PE(X)) : GOSUB 6000 : PRINT " ";
5500 LET V$ = STR$(PL(X)) : GOSUB 6000 : PRINT
5510 NEXT X
5520 RETURN
