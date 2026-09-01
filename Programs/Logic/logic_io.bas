10 REM Configuration
20 LET IP = 1 : REM Digital I/O port
30 LET PV = -1 : REM Previous input state
40 REM Display instructions and LED assignments
50 PRINT ""
60 PRINT "LOGIC GATE DEMONSTRATOR - DIGITAL I/O"
70 PRINT "====================================="
80 PRINT ""
90 PRINT "Hold button 0 for input A and button 1 for input B."
100 PRINT "The five lowest LEDs show the gate outputs:"
110 PRINT ""
120 PRINT "LED 0 = A AND B"
130 PRINT "LED 1 = A OR B"
140 PRINT "LED 2 = A XOR B"
150 PRINT "LED 3 = NOT A"
160 PRINT "LED 4 = NOT B"
170 PRINT ""
180 PRINT "Press button 7 to finish."
190 PRINT ""
200 PRINT "A B | AND OR XOR NOT-A NOT-B"
210 PRINT "-----------------------------"
220 REM Read inputs until the exit button is pressed
230 LET K = INP(IP)
240 IF (K AND 128) <> 0 THEN GOTO 440
250 LET A = K AND 1
260 LET B = (K AND 2) / 2
270 LET IV = A + 2 * B
280 IF IV = PV THEN GOTO 230
290 LET PV = IV
300 REM Calculate the five gate results
310 LET GA = A AND B
320 LET GO = A OR B
330 LET GX = GO - GA
340 LET NA = 1 - A
350 LET NB = 1 - B
360 REM Pack the results into the five lowest output bits
370 LET OV = GA + 2 * GO + 4 * GX + 8 * NA + 16 * NB
380 OUT IP, OV
390 PRINT CHR$(48 + A); " "; CHR$(48 + B); " |   ";
400 PRINT CHR$(48 + GA); "  "; CHR$(48 + GO); "   ";
410 PRINT CHR$(48 + GX); "     "; CHR$(48 + NA); "     ";
420 PRINT CHR$(48 + NB)
430 GOTO 230
440 REM Clear the LEDs before returning to BASIC
450 OUT IP, 0
460 PRINT ""
470 PRINT "Outputs cleared."
480 END
