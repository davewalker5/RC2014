10 REM Analyse pulse-level bat call data to identify
20 REM search, approach and feeding buzz phases
30 PRINT
40 PRINT "BAT BEHAVIOURAL PHASE ANALYSIS"
50 PRINT "=============================="
60 PRINT
70 REM Initialise and tabulate the data
80 GOSUB 1000 : REM GOSUB 4000
90 REM Create an array of valid PRI values then sort them
100 REM and calculate the median of the more relaxed
110 REM (search phase) intervals to use as a baseline
120 GOSUB 2000 : GOSUB 2100
130 PRINT "Number of valid pulse intervals ="; NV
140 IF NV > 0 THEN GOSUB 2300
150 REM The upper median is now in UM
160 PRINT "Upper median PRI = "; UM
170 REM Detect phases and print the resulting regions
180 GOSUB 3300
190 IF NR = 0 THEN GOTO 210
200 GOSUB 5300
210 GOSUB 4500
220 PRINT : PRINT "Classification: "; FC$
230 END
