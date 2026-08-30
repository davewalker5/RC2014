10 REM Blackjack for RC2014 Microsoft BASIC
20 DIM DK(52), PH(12), DH(12)
30 PRINT ""
40 PRINT "BLACKJACK"
50 PRINT "========="
60 PRINT "Try to beat the dealer without going over 21."
70 PRINT "The dealer stands on 17."
80 PRINT ""
100 REM Build and shuffle a standard 52-card deck
110 FOR I = 1 TO 52
120 LET DK(I) = I - 1
130 NEXT I
140 FOR I = 52 TO 2 STEP -1
150 LET J = 1 + INT(RND(1) * I)
160 LET C = DK(I) : LET DK(I) = DK(J) : LET DK(J) = C
170 NEXT I
180 LET DP = 1 : LET PN = 0 : LET DN = 0
200 REM Deal two cards to the player and dealer
210 LET PN = PN + 1 : LET PH(PN) = DK(DP) : LET DP = DP + 1
220 LET DN = DN + 1 : LET DH(DN) = DK(DP) : LET DP = DP + 1
230 LET PN = PN + 1 : LET PH(PN) = DK(DP) : LET DP = DP + 1
240 LET DN = DN + 1 : LET DH(DN) = DK(DP) : LET DP = DP + 1
250 GOSUB 1000
260 LET H = 1 : GOSUB 2000 : LET PS = T
270 LET H = 2 : GOSUB 2000 : LET DS = T
280 IF PS = 21 AND DS = 21 THEN PRINT "Both have blackjack - push!" : GOTO 800
290 IF PS = 21 THEN PRINT "Blackjack! You win!" : GOTO 800
300 IF DS = 21 THEN GOSUB 1500 : PRINT "Dealer has blackjack." : GOTO 800
400 REM Player's turn
410 PRINT "Hit or stand (H/S) ";
420 INPUT A$
430 IF A$ = "S" OR A$ = "s" THEN GOTO 550
440 IF A$ <> "H" AND A$ <> "h" THEN PRINT "Please enter H or S." : GOTO 410
450 LET PN = PN + 1 : LET PH(PN) = DK(DP) : LET DP = DP + 1
460 PRINT "You draw "; : LET C = PH(PN) : GOSUB 3000 : PRINT ""
470 LET H = 1 : GOSUB 2000 : LET PS = T
480 PRINT "Your total: "; PS
490 IF PS > 21 THEN PRINT "Bust! Dealer wins." : GOTO 800
500 IF PS = 21 THEN GOTO 550
510 GOTO 410
550 REM Dealer's turn
560 GOSUB 1500
570 LET H = 2 : GOSUB 2000 : LET DS = T
580 IF DS >= 17 THEN GOTO 680
590 LET DN = DN + 1 : LET DH(DN) = DK(DP) : LET DP = DP + 1
600 PRINT "Dealer draws "; : LET C = DH(DN) : GOSUB 3000 : PRINT ""
610 LET H = 2 : GOSUB 2000 : LET DS = T
620 PRINT "Dealer total: "; DS
630 IF DS > 21 THEN PRINT "Dealer busts. You win!" : GOTO 800
640 GOTO 580
680 REM Compare hands after both stand
690 PRINT ""
700 PRINT "Your total: "; PS; "  Dealer total: "; DS
710 IF PS > DS THEN PRINT "You win!" : GOTO 800
720 IF PS < DS THEN PRINT "Dealer wins." : GOTO 800
730 PRINT "Push - the hand is tied."
800 REM Offer another hand
810 PRINT ""
820 PRINT "Play again (Y/N) ";
830 INPUT A$
840 IF A$ = "Y" OR A$ = "y" THEN GOTO 100
850 IF A$ <> "N" AND A$ <> "n" THEN GOTO 820
860 PRINT "Thanks for playing."
870 END
1000 REM Show initial hands, keeping dealer's second card hidden
1010 PRINT "Dealer: ";
1020 LET C = DH(1) : GOSUB 3000
1030 PRINT ", [hidden]"
1040 PRINT "You: ";
1050 FOR K = 1 TO PN
1060 LET C = PH(K) : GOSUB 3000
1070 IF K < PN THEN PRINT ", ";
1080 NEXT K
1090 LET H = 1 : GOSUB 2000
1100 PRINT "  ("; T; ")"
1110 RETURN
1500 REM Reveal and display the dealer's complete hand
1510 PRINT "Dealer reveals: ";
1520 FOR K = 1 TO DN
1530 LET C = DH(K) : GOSUB 3000
1540 IF K < DN THEN PRINT ", ";
1550 NEXT K
1560 LET H = 2 : GOSUB 2000
1570 PRINT "  ("; T; ")"
1580 RETURN
2000 REM Score hand H: 1 is player, 2 is dealer
2010 LET T = 0 : LET AC = 0
2020 IF H = 1 THEN LET N = PN
2030 IF H = 2 THEN LET N = DN
2040 FOR K = 1 TO N
2050 IF H = 1 THEN LET C = PH(K)
2060 IF H = 2 THEN LET C = DH(K)
2070 LET R = C - 13 * INT(C / 13) + 1
2080 IF R = 1 THEN LET T = T + 11 : LET AC = AC + 1 : GOTO 2110
2090 IF R > 10 THEN LET T = T + 10 : GOTO 2110
2100 LET T = T + R
2110 NEXT K
2120 IF T > 21 AND AC > 0 THEN LET T = T - 10 : LET AC = AC - 1 : GOTO 2120
2130 RETURN
3000 REM Print card C as rank and suit
3010 LET S = INT(C / 13)
3020 LET R = C - 13 * S + 1
3030 IF R = 1 THEN PRINT "A";
3040 IF R > 1 AND R < 11 THEN PRINT R;
3050 IF R = 11 THEN PRINT "J";
3060 IF R = 12 THEN PRINT "Q";
3070 IF R = 13 THEN PRINT "K";
3080 IF S = 0 THEN PRINT "S";
3090 IF S = 1 THEN PRINT "H";
3100 IF S = 2 THEN PRINT "D";
3110 IF S = 3 THEN PRINT "C";
3120 RETURN
