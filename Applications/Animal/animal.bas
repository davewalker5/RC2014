10 REM Declare and read the initial dataset
20 DIM A$(100), Q$(100)
30 DATA "Fish", "Does it swim", "END"
40 NA = 0
50 READ A$ : IF A$ = "END" THEN GOTO 70
60 NA = NA + 1 : A$(NA) = A$ : READ Q$(NA) : GOTO 50
70 REM Start the game
80 PRINT "Are you thinking of an animal? (Y/N) ";
90 INPUT R$ : IF R$ = "N" OR R$ = "n" THEN GOTO 270
100 REM Loop through the questions, asking each in turn
110 L = 0
120 FOR I = 1 TO NA
130 PRINT Q$(I); "? (Y/N) "; : INPUT R$
140 IF R$ = "N" OR R$ = "n" THEN GOTO 210
150 REM Question applies to this animal, but is it the
160 REM one the user is thinking of?
170 PRINT "Is it a(n) "; A$(I); "? (Y/N) "; : INPUT R$
180 IF R$ = "Y" OR R$ = "y" THEN GOTO 270
190 REM Remember the wrong guess, then try other animals
200 L = I
210 NEXT I
220 REM Run out of questions without guessing the animal
230 PRINT "You win! I don't know the animal"
240 Q$ = "What question can I ask to identify it?"
250 IF L > 0 THEN LET D$ = A$(L)
260 GOSUB 270
270 M$ = "": PRINT "Do you want to play again (Y/N) "; : INPUT M$
280 IF M$ = "Y" OR M$ = "y" THEN GOTO 80
290 END
300 REM Add a new animal to the dataset
310 IF NA = 100 THEN GOTO 270
320 NA = NA + 1
330 PRINT "What is the name of the animal?"
340 INPUT A$(NA)
350 PRINT "How can I distinguish it from a(n) "; D$; " ?"
360 INPUT Q$(NA) : RETURN
370 REM No more space for animals
380 PRINT "I can't store any more animals" : RETURN
390 END
