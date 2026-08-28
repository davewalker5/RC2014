10 REM Define the ANSI escape codes for the colours/effects
20 REM to test along with the colour/effect names
30 DATA "Red", "31", "Green", "32"
40 DATA "Yellow", "33", "Blue", "34"
50 DATA "Magenta", "35", "Cyan", "36"
60 DATA "White", "37", "Bold", "1"
70 DATA "Underline", "4", "Reverse", "7"
80 DATA "Overline", "53", "END"
90 REM Read the colour/effect name and if it is "END"
100 REM then stop
110 READ N$
120 IF N$ = "END" THEN END
130 REM Read the colour/effect code
140 READ C$
150 PRINT "" : PRINT "Code ";C$; " ";
160 REM Print the colour/effect name using that effect
170 GOSUB 330
180 REM If this is an effect, rather than a colour, move
190 REM to the next one
200 LET C = VAL(C$)
210 IF C < 30 OR C > 37 THEN GOTO 90
220 REM Output the "background" colour effect. Note that
230 REM the string conversion of the new code adds a leading
240 REM space that must be removed
250 LET C = C + 10 : LET C$ = STR$(C)
260 LET C$ = RIGHT$(C$, LEN(C$) - 1)
270 PRINT " ";C$;" "; : GOSUB 330
280 REM Output the "bright foreground" effect
290 LET C = C + 50 : LET C$ = STR$(C)
300 LET C$ = RIGHT$(C$, LEN(C$) - 1)
310 PRINT " ";C$;" "; : GOSUB 330
320 GOTO 90
330 REM Output the current colour/effect
340 PRINT CHR$(27);"[";C$;"m";N$;
350 REM Clear all effects
360 PRINT CHR$(27);"[0m";
370 RETURN
