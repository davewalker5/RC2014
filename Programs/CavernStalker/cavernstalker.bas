10 REM Cavern Stalker - a cave exploration game
20 DIM C(20,3),R(3)
30 GOSUB 7000
40 GOSUB 6000
50 GOSUB 100
60 GOTO 1000
100 REM Prepare a new hunt
110 LET A=5:LET E=0
120 GOSUB 8000:LET L=X
130 GOSUB 8000:IF X=L THEN GOTO 130
140 LET M=X
150 GOSUB 8000
160 IF X=L OR X=M THEN GOTO 150
170 LET B1=X
180 GOSUB 8000
190 IF X=L OR X=M OR X=B1 THEN GOTO 180
200 LET B2=X
210 GOSUB 8000
220 IF X=L OR X=M OR X=B1 OR X=B2 THEN GOTO 210
230 LET P1=X
240 GOSUB 8000
250 IF X=L OR X=M OR X=B1 OR X=B2 OR X=P1 THEN GOTO 240
260 LET P2=X
270 PRINT "":PRINT "Your search is under way.":PRINT ""
280 RETURN
1000 REM Play one turn
1010 PRINT "You stand in chamber ";L;"."
1020 PRINT "Tunnels reach ";C(L,1);", ";C(L,2);" AND ";C(L,3);"."
1030 FOR I=1 TO 3
1040 LET N=C(L,I)
1050 IF N=M THEN PRINT "Heavy footsteps echo close by."
1060 IF N=P1 OR N=P2 THEN PRINT "Dust drifts toward a nearby tunnel."
1070 IF N=B1 OR N=B2 THEN PRINT "A rush of wings disturbs the air."
1080 NEXT I
1090 PRINT "Bolts remaining: ";A
1100 PRINT "Walk, Fire OR Leave (W/F/L)";
1110 INPUT A$
1120 IF A$="W" OR A$="w" THEN GOTO 1200
1130 IF A$="F" OR A$="f" THEN GOTO 1220
1140 IF A$="L" OR A$="l" THEN GOTO 5000
1150 PRINT "Please enter W, F OR L.":GOTO 1100
1200 GOSUB 2000
1210 GOTO 1250
1220 GOSUB 3000
1250 IF E=0 THEN GOTO 1000
1260 GOTO 4500
2000 REM Walk through a neighbouring tunnel
2010 PRINT "Which chamber";
2020 INPUT N
2030 IF N=C(L,1) OR N=C(L,2) OR N=C(L,3) THEN GOTO 2060
2040 PRINT "That chamber is not joined to this one."
2050 RETURN
2060 LET L=N
2070 IF L=M THEN GOTO 2200
2080 IF L=P1 OR L=P2 THEN GOTO 2220
2090 IF L<>B1 AND L<>B2 THEN RETURN
2100 PRINT "Gloomwings seize your pack and drag you away!"
2110 GOSUB 8000:LET L=X
2120 PRINT "You tumble into chamber ";L;"."
2130 IF L=M THEN GOTO 2240
2140 IF L=P1 OR L=P2 THEN GOTO 2260
2150 IF L=B1 OR L=B2 THEN GOTO 2100
2160 RETURN
2200 PRINT "You have walked into the creature's lair."
2210 LET E=1:RETURN
2220 PRINT "The floor gives way beneath you."
2230 LET E=1:RETURN
2240 PRINT "The Gloomwings deliver you to the creature."
2250 LET E=1:RETURN
2260 PRINT "The Gloomwings drop you into an abyss."
2270 LET E=1:RETURN
3000 REM Fire through one to three connected chambers
3010 PRINT "Number of chambers in the shot (1-3)";
3020 INPUT K
3030 IF K<1 OR K>3 THEN GOTO 3400
3040 LET T=L:LET V=0
3050 FOR I=1 TO K
3060 PRINT "Chamber ";I;
3070 INPUT R(I)
3080 NEXT I
3090 FOR I=1 TO K
3100 LET N=0
3102 IF R(I)=C(T,1) THEN LET N=1
3104 IF R(I)=C(T,2) THEN LET N=1
3106 IF R(I)=C(T,3) THEN LET N=1
3108 IF N=0 THEN LET V=1
3110 IF N=1 THEN LET T=R(I)
3111 NEXT I
3112 IF V=1 THEN GOTO 3420
3114 LET A=A-1:LET F=0
3120 FOR I=1 TO K
3130 IF F=0 AND R(I)=M THEN LET F=1
3140 IF F=0 AND R(I)=L THEN LET F=2
3150 NEXT I
3160 IF F=1 THEN GOTO 3300
3170 IF F=2 THEN GOTO 3320
3180 PRINT "The bolt clatters somewhere out of sight."
3190 IF RND(1)>=.75 THEN GOTO 3240
3200 LET D=1+INT(RND(1)*3)
3210 LET M=C(M,D)
3220 PRINT "A distant scramble follows the noise."
3230 IF M=L THEN GOTO 3340
3240 IF A>0 THEN RETURN
3250 GOTO 3360
3300 PRINT "The creature falls. The caverns are safe!"
3310 LET E=1:RETURN
3320 PRINT "The bolt circles home. Your hunt is over."
3330 LET E=1:RETURN
3340 PRINT "The startled creature finds you first."
3350 LET E=1:RETURN
3360 PRINT "Your launcher is empty. The hunt is over."
3370 LET E=1:RETURN
3400 PRINT "Choose 1, 2 OR 3.":GOTO 3010
3420 PRINT "Those chambers do not form a continuous route."
3430 RETURN
4500 REM Offer another game after an ending
4510 PRINT "":PRINT "Search again (Y/N)";
4520 INPUT A$
4530 IF A$="Y" OR A$="y" THEN GOTO 4600
4540 IF A$="N" OR A$="n" THEN GOTO 5000
4550 PRINT "Please enter Y OR N.":GOTO 4510
4600 GOSUB 100
4610 GOTO 1000
5000 PRINT "Thanks for exploring Cavern Stalker."
5010 END
6000 REM Introduction
6010 PRINT "":PRINT "Cavern Stalker":PRINT "--------------":PRINT ""
6020 PRINT "A dangerous creature roams twenty chambers."
6030 PRINT "You carry five bolts and a bolt launcher."
6040 PRINT "Two abysses and two Gloomwing roosts are hidden."
6050 PRINT "Clues reveal dangers one tunnel away."
6060 PRINT "A bolt can follow up to three joined chambers."
6070 PRINT "A failed attack may disturb your quarry."
6080 PRINT ""
6090 RETURN
7000 REM Load three tunnel destinations for every chamber
7010 FOR I=1 TO 20
7020 FOR J=1 TO 3
7030 READ C(I,J)
7040 NEXT J
7050 NEXT I
7060 RETURN
7100 DATA 2,5,8,1,3,10,2,4,12,3,5,14,1,4,6
7110 DATA 5,7,15,6,8,17,1,7,9,8,10,18,2,9,11
7120 DATA 10,12,19,3,11,13,12,14,20,4,13,15,6,14,16
7130 DATA 15,17,20,7,16,18,9,17,19,11,18,20,13,16,19
8000 REM Put a random chamber number in X
8010 LET X=1+INT(RND(1)*20)
8020 RETURN
