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
120 IF N$ = "END" THEN GOTO 200
130 REM Read the colour/effect code
140 READ C$
150 REM Print the colour/effect name using that effect
160 PRINT CHR$(27);"[";C$;"m";N$;
170 REM Clear colours and effects
180 PRINT CHR$(27);"[0m"
190 GOTO 90
200 END
