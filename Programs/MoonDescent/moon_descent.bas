10 REM RC2014 Moon Descent - a turn-based descent simulation
20 LET GR = 5 : REM Downward gravity per turn
30 LET MT = 10 : REM Maximum thrust per turn
40 LET SF = 120 : REM Fuel supplied for each flight
50 GOSUB 1000
60 GOTO 100
100 REM Prepare a new flight
110 LET AL = 500 : LET VE = 0 : LET FU = SF : LET TU = 0
120 PRINT "":PRINT "The landing site is 500 units below."
130 PRINT "Use thrust carefully: hovering requires 5 units."
140 PRINT ""
200 REM Display flight state and obtain the next thrust setting
210 PRINT "ALTITUDE ";INT(AL + .5);"  VELOCITY ";INT(VE * 10 + .5) / 10
220 PRINT "FUEL ";FU
230 IF FU = 0 THEN LET TU = 0 : PRINT "Fuel exhausted - thrust is 0." : GOTO 300
240 PRINT "Thrust (0-";MT;")";
250 INPUT TU
260 IF TU < 0 OR TU > MT THEN PRINT "Enter a value from 0 to ";MT;"." : GOTO 240
270 IF TU <> INT(TU) THEN PRINT "Enter a whole number." : GOTO 240
280 IF TU > FU THEN PRINT "Only ";FU;" fuel units remain." : GOTO 240
300 REM Advance the simulation by one turn
310 LET FU = FU - TU
320 LET AC = GR - TU
330 LET NA = AL - VE - AC / 2
340 IF NA <= 0 THEN GOTO 500
350 LET VE = VE + AC
360 LET AL = NA
370 PRINT ""
380 GOTO 200
500 REM Estimate velocity at the instant the surface is crossed
510 LET FR = AL / (AL - NA)
520 LET IV = VE + AC * FR
530 IF IV < 0 THEN LET IV = 0
540 PRINT "":PRINT "TOUCHDOWN VELOCITY ";INT(IV * 10 + .5) / 10
550 IF IV <= 2 THEN PRINT "Perfect landing!" : GOTO 700
560 IF IV <= 5 THEN PRINT "Good landing. The crew is safe." : GOTO 700
570 IF IV <= 10 THEN PRINT "Hard landing. The lander is damaged." : GOTO 700
580 PRINT "CRASH! The lander struck too fast."
700 REM Offer another flight
710 PRINT "":PRINT "Fly again (Y/N)";
720 INPUT A$
730 IF A$ = "Y" OR A$ = "y" THEN GOTO 100
740 IF A$ = "N" OR A$ = "n" THEN GOTO 800
750 PRINT "Please enter Y or N." : GOTO 710
800 PRINT "Mission control signing off."
810 END
1000 REM Display instructions
1010 PRINT ""
1012 PRINT "RC2014 MOON DESCENT"
1015 PRINT "==================="
1018 PRINT ""
1020 PRINT "Guide the lander to the surface with limited fuel."
1030 PRINT "Velocity is downward: a larger value means a faster fall."
1040 PRINT "Each turn, enter whole-number thrust from 0 to 10."
1050 PRINT "Gravity adds 5 velocity units; thrust subtracts its setting."
1060 PRINT "Touch down at velocity 5 or less for a safe landing."
1070 RETURN
