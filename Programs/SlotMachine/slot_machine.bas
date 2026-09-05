10 REM LCD Slot Machine - three animated reels and play credits
20 LET LR = 218 : LET LD = 219 : REM LCD register and data ports
30 LET W = 16 : REM Visible columns, minimum 16, two-line display
40 LET CD = 100 : REM Delay after each LCD command or data write
50 LET DL = 100 : REM Base animation delay, approximate loop units
60 LET SF = 12 : LET SG = 8 : REM First stop frame and stop gap
70 LET IC = 20 : LET MX = 9999 : REM Starting credits and ceiling
80 DIM RV(3), ST(3), SN$(6)
90 REM RV holds symbols 0-5; ST holds each reel's last frame
100 DATA "CHERRY","LEMON","BELL","DIAMOND","HEART","SEVEN"
110 REM Eight pixel rows per glyph, in the same order as the names
120 DATA 2,4,10,21,21,10,0,0
130 DATA 4,14,31,31,31,14,4,0
140 DATA 4,14,14,14,31,0,4,0
150 DATA 4,10,17,17,17,10,4,0
160 DATA 0,10,31,31,14,4,0,0
170 DATA 31,1,2,4,8,8,8,0
200 REM Initialise names, custom characters and credit balance
210 FOR I = 1 TO 6 : READ SN$(I) : NEXT I
220 GOSUB 3000
230 PRINT : PRINT "LCD SLOT MACHINE" : PRINT "================"
232 PRINT
234 PRINT "Each spin costs 1 play credit"
236 PRINT "Pair pays 2, triple pays 8 and three SEVENs pay 20"
237 PRINT "Payouts include the stake"
238 PRINT
280 LET CR = IC
290 LET AD = 128 : LET TX$ = "  [ ] [ ] [ ]" : GOSUB 3200
300 GOSUB 3400
310 IF CR = 0 THEN GOTO 600
320 PRINT : PRINT "Credits:"; CR : PRINT
322 PRINT "S) Spin" : PRINT "Q) Quit"
324 PRINT
330 INPUT "What do you want to do"; A$
340 IF A$ = "Q" OR A$ = "q" THEN GOTO 800
350 IF A$ = "S" OR A$ = "s" THEN GOTO 400
360 PRINT "Enter S or Q" : GOTO 330
400 REM Debit once, animate, then score only the stopped symbols
410 LET CR = CR - 1
420 LET AD = 192 : LET TX$ = "Spinning ..." : GOSUB 3200
430 GOSUB 1000
440 GOSUB 2000
450 LET CR = CR + PY
460 IF CR > MX THEN LET CR = MX
470 LET AD = 192 : GOSUB 3200
480 PRINT SN$(RV(1) + 1); " / "; SN$(RV(2) + 1);
490 PRINT " / "; SN$(RV(3) + 1)
500 PRINT TX$; "  Payout:"; PY; "  Credits:"; CR
510 IF CR = MX THEN GOTO 650
520 REM Leave the result visible until the next terminal choice
530 IF CR = 0 THEN GOTO 600
540 GOTO 320
600 LET AD = 192 : LET TX$ = "No credits" : GOSUB 3200
610 PRINT "No credits left." : GOTO 700
650 LET AD = 192 : LET TX$ = "Credit limit!" : GOSUB 3200
660 PRINT "Credit ceiling reached!"
700 INPUT "New game (Y/N) "; A$
710 IF A$ = "Y" OR A$ = "y" THEN GOTO 280
720 IF A$ = "N" OR A$ = "n" THEN GOTO 800
730 PRINT "Enter Y or N." : GOTO 700
800 REM Leave the final reels and credit balance on the LCD
810 GOSUB 3400
830 END
1000 REM Animate three independent symbols with staggered stops
1010 FOR I = 1 TO 3
1020 LET RV(I) = INT(RND(1) * 6)
1030 LET ST(I) = SF + (I - 1) * SG
1040 NEXT I
1050 FOR F = 1 TO ST(3)
1060 FOR I = 1 TO 3
1070 IF F > ST(I) THEN GOTO 1130
1080 REM Non-zero random step ensures a visible change each frame
1090 LET RV(I) = RV(I) + 1 + INT(RND(1) * 5)
1100 IF RV(I) > 5 THEN LET RV(I) = RV(I) - 6
1110 OUT LR, 128 + 3 + (I - 1) * 4 : GOSUB 3500
1120 OUT LD, RV(I) : GOSUB 3500
1130 NEXT I
1140 REM Gradually slow down; stopped reels are never rewritten
1150 FOR Z = 1 TO DL + F * 5 : NEXT Z
1160 NEXT F
1170 RETURN
2000 REM Return gross payout PY and result message TX$
2010 LET PY = 0 : LET TX$ = "No match"
2020 IF RV(1) <> RV(2) THEN GOTO 2070
2030 IF RV(2) <> RV(3) THEN GOTO 2100
2040 LET PY = 8 : LET TX$ = "Triple +8"
2050 IF RV(1) = 5 THEN LET PY = 20 : LET TX$ = "Jackpot +20"
2060 RETURN
2070 IF RV(1) = RV(3) THEN GOTO 2100
2080 IF RV(2) = RV(3) THEN GOTO 2100
2090 RETURN
2100 LET PY = 2 : LET TX$ = "Pair +2"
2110 RETURN
3000 REM Initialise LCD and load six glyphs into CGRAM slots 0-5
3010 OUT LR, 56 : GOSUB 3500 : REM 8 bit, two lines, 5x8 font
3020 OUT LR, 12 : GOSUB 3500 : REM Display on, cursor off
3030 OUT LR, 6 : GOSUB 3500 : REM Increment address, no shift
3040 OUT LR, 1 : GOSUB 3500 : REM Clear and reset display shift
3050 OUT LR, 64 : GOSUB 3500 : REM Select CGRAM address zero
3060 FOR G = 1 TO 48
3070 READ BV
3080 OUT LD, BV : GOSUB 3500
3090 NEXT G
3100 OUT LR, 128 : GOSUB 3500 : REM Return to display RAM
3110 RETURN
3200 REM Write TX$ at command address AD, padded to W columns
3210 OUT LR, AD : GOSUB 3500
3220 FOR LC = 1 TO W
3230 LET BV = 32
3240 IF LC <= LEN(TX$) THEN LET BV = ASC(MID$(TX$, LC, 1))
3250 OUT LD, BV : GOSUB 3500
3260 NEXT LC
3270 RETURN
3400 REM Display credits without BASIC's leading numeric space
3410 LET N$ = STR$(CR)
3420 IF LEFT$(N$, 1) = " " THEN LET N$ = MID$(N$, 2)
3430 LET TX$ = "CREDITS " + N$ : LET AD = 192
3440 GOSUB 3200
3450 RETURN
3500 REM Conservative LCD delay; uses only Q
3510 FOR Q = 1 TO CD : NEXT Q
3520 RETURN
