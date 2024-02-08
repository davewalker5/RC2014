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
200 IF LEN(A$) = 0 THEN GOTO 410
210 T$ = ""
220 CA = ASC("a") : CZ = ASC("z")
230 REM Loop over the input message and add 7 spaces between words
240 Y = 0
250 FOR I = 1 TO LEN(A$)
260 B$ = MID$(A$, I, 1)
270 IF B$ = " " THEN PRINT "       "; : GOTO 370
280 REM Convert the character to uppercase
290 Y = Y + 1
300 C = ASC(B$)
310 IF C >= CA AND C <= CZ THEN B$ = CHR$(C - 32)
320 REM Add one space between characters and 3 spaces between
330 REM letters
340 FOR J = 1 TO N
350 IF B$ = L$(J) THEN PRINT M$(J); "   "; : GOTO 370
360 NEXT J
370 NEXT I
380 IF Y = 0 THEN PRINT "Input was blank" : GOTO 180
390 REM Print an empty string to move to the next line after the message
400 PRINT ""
410 Z$ = "": PRINT "More? ";: INPUT Z$
420 IF Z$ = "Y" OR Z$ = "y" THEN GOTO 170
430 END
