10 PRINT "Enter the required state of the LEDs"
20 PRINT "by clicking on the corresponding button"
30 PRINT "on the the I/O card to toggle each one"
40 PRINT "on or off"
50 REM Initialise the output value
60 B = 0
70 REM Output the current value
80 PRINT "Output value is "; B
90 OUT 0, B
100 REM Wait for a key press on the I/O card
110 GOSUB 300
120 REM Toggle the corresponding bit
130 GOSUB 400
140 GOTO 70
300 REM Wait for a key press on the I/O card
310 K = INP(0) : IF K = 0 THEN GOTO 310
320 REM Wait for the key to be released
330 X = INP(0) : IF X <> 0 THEN GOTO 330
340 RETURN
400 REM Determine the change to the output value
410 S = B AND K
420 IF S = 0 THEN B = B + K
430 IF S > 0 THEN B = B - K
440 RETURN
