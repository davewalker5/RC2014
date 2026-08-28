10 REM The data consists of up to 100 bytes specifying
20 REM the pattern of the LEDs to switch on. It's
30 REM terminated by 999
40 DATA 129, 66, 36, 24, 36, 66, 129, 999
50 DIM LED(100)
60 REM Read the display patterns
70 GOSUB 200
80 IF N > 0 THEN GOTO 300
90 PRINT "No LED patterns specified"
100 END
200 REM Read the data
210 N = 0
220 READ B
230 IF B = 999 THEN RETURN
240 N = N + 1 : LED(N) = B : GOTO 220
300 REM Display the pattern repeatedly, with a pause
310 REM between each byte
320 FOR I = 1 TO N
330 OUT 0, LED(I)
340 FOR X = 1 TO 150 : NEXT X
350 NEXT I
360 GOTO 320
