10 DATA "A", ".-", "B", "-...", "C", "-.-.", "D", "-..", "E", "."
20 DATA "F", "..-.", "G", "--.", "H", "....", "I", "..", "J", ".---"
30 DATA "K", "-.-", "L", ".-..", "M", "--", "N", "-.", "O", "---"
40 DATA "P", ".--.", "Q", "--.-", "R", ".-.", "S", "...", "T", "-"
50 DATA "U", "..-", "V", "...-", "W", ".--", "X", "-..-", "Y", "-.--"
60 DATA "Z", "--..", "1", ".----", "2", "..---", "3", "...--"
70 DATA "4", "....-", "5", ".....", "6", "-....", "7", "--..."
80 DATA "8", "---..", "9", "----.", "0", "-----", "END"
90 DIM L$(50), M$(50)
100 REM Read the Morse code table
110 N = 1
120 READ X$ : IF X$ = "END" THEN GOTO 170
130 L$(N) = X$
140 READ M$(N)
150 N = N + 1
160 GOTO 120
170 REM Prompt for a message and translate it to Morse code
180 PRINT "Enter a message to be translated to Morse code (ENTER to quit):"
190 INPUT A$
200 IF LEN(A$) = 0 THEN GOTO 510
210 T$ = ""
220 CA = ASC("a") : CZ = ASC("z")
230 REM Loop over the input message
240 Y = 0
250 REM Handle the start and end of Prosigns. This doesn't validate
260 REM the Prosigns - it just removes the gap between characters
270 PS = 0
280 FOR I = 1 TO LEN(A$)
290 B$ = MID$(A$, I, 1)
300 IF B$ = "<" THEN PS = 1 : GOTO 470
310 IF B$ = ">" THEN PS = 0 : GOTO 470
320 REM Print 7 spaces between words
330 IF B$ = " " THEN PRINT "       "; : GOTO 470
340 REM Convert the character to uppercase
350 Y = Y + 1
360 C = ASC(B$)
370 IF C >= CA AND C <= CZ THEN B$ = CHR$(C - 32)
380 REM Print the Mosrse code for the current character, followed by
390 REM 3 spaces unless we're in a Prosign in which case don't print
400 REM the spaces
410 FOR J = 1 TO N
420 IF B$ <> L$(J) THEN goto 460
430 PRINT M$(J);
440 IF PS = 0 THEN PRINT "   ";
450 GOTO 470
460 NEXT J
470 NEXT I
480 IF Y = 0 THEN PRINT "Input was blank" : GOTO 180
490 REM Print an empty string to move to the next line after the message
500 PRINT ""
510 Z$ = "": PRINT "More? ";: INPUT Z$
520 IF Z$ = "Y" OR Z$ = "y" THEN GOTO 170
530 END
