10 DATA "A", ".-", "B", "-...", "C", "-.-.", "D", "-..", "E", "."
20 DATA "F", "..-.", "G", "--.", "H", "....", "I", "..", "J", ".---"
30 DATA "K", "-.-", "L", ".-..", "M", "--", "N", "-.", "O", "---"
40 DATA "P", ".--.", "Q", "--.-", "R", ".-.", "S", "...", "T", "-"
50 DATA "U", "..-", "V", "...-", "W", ".--", "X", "-..-", "Y", "-.--"
60 DATA "Z", "--..", "1", ".----", "2", "..---", "3", "...--"
70 DATA "4", "....-", "5", ".....", "6", "-....", "7", "--..."
80 DATA "8", "---..", "9", "----.", "0", "-----", "END"
90 DIM L$(50), M$(50)
100 REM Get the ASCII code range for lowercase letters, for uppercase conversion
110 CA = ASC("a") : CZ = ASC("z")
120 REM Read the Morse code table
130 N = 1
140 READ X$ : IF X$ = "END" THEN GOTO 170
150 L$(N) = X$ : READ M$(N) : N = N + 1
160 GOTO 140
170 REM Prompt for a message and translate it to Morse code
180 PRINT "Enter a message to be translated to Morse code (ENTER to quit):"
190 INPUT A$
200 IF LEN(A$) = 0 THEN GOTO 890
210 REM Loop over the input message
220 Y = 0
230 FOR I = 1 TO LEN(A$)
240 B$ = MID$(A$, I, 1)
250 REM Handle spaces between words
260 IF B$ = " " THEN GOSUB 810 : GOTO 370
270 REM Not a space. Increment the character count and convert
280 REM it to uppercase for comparison
290 Y = Y + 1
300 C = ASC(B$)
310 IF C >= CA AND C <= CZ THEN B$ = CHR$(C - 32)
320 REM Look for ths character in the Morse code table and, if
330 REM found, send the Morse code for the character
340 FOR J = 1 TO N
350 IF B$ = L$(J) THEN GOSUB 470 : GOTO 370
360 NEXT J
370 NEXT I
380 REM Check for empty input and try again if necessary
390 IF Y = 0 THEN PRINT "Input was blank" : GOTO 180
400 REM Print an empty string to move to the next line after the message
410 REM has been displayed and printed then ask if the user wants to
420 REM translate and send another message
430 PRINT ""
440 Z$ = "": PRINT "More? ";: INPUT Z$
450 IF Z$ = "Y" OR Z$ = "y" THEN GOTO 180
460 GOTO 890
470 REM Send a single morse character. At this point, J contains
480 REM the index of the Morse code for the character in B$
490 REM Print the character we're about to send
500 PRINT B$;" ";
510 FOR K = 1 TO LEN(M$(J))
520 B$ = MID$(M$(J), K, 1)
530 IF B$ = "." THEN GOSUB 600
540 IF B$ = "-" THEN GOSUB 660
550 GOSUB 720
560 NEXT K
570 GOSUB 760
580 PRINT ""
590 RETURN
600 REM Dots are 1 time unit long
610 PRINT ".";
620 OUT 0, 255
630 U = 1 : GOSUB 860
640 OUT 0, 0
650 RETURN
660 REM Dashes are 3 time units long
670 PRINT "-";
680 OUT 0, 255
690 U = 3 : GOSUB 860
700 OUT 0, 0
710 RETURN
720 REM Spaces between . or - within a word are 1 time unit long
730 OUT 0, 0
740 U = 1 : GOSUB 860
750 RETURN
760 REM Spaces between characters are 3 time units long
770 PRINT "   ";
780 OUT 0, 0
790 U = 4 : GOSUB 860
800 RETURN
810 REM Spaces between words are 7 time units long
820 PRINT "      "
830 OUT 0, 0
840 U = 7 : GOSUB 860
850 RETURN
860 REM Wait for "U" units of time
870 FOR Z = 1 TO U * 250 : NEXT Z
880 RETURN
890 END
