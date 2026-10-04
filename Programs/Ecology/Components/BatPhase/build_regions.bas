3000 REM Build phase regions from the phases PH$(). Each
3010 REM region is defined as a classification, CL$(), a
3020 REM start pulse index, PS(), and end pulse index,
3030 REM PE() and a region length, PL()
3040 REM Classification is one of SEARCH, APPROACH, BUZZ
3050 REM or EXIT
3060 REM Outputs: NR, CL$(), PS(), PE(), PL()
3070 REM Start/end pulse numbers are one-based, inclusive
3080 REM Caller dimensions all arrays to at least NP
3090 LET NR = 0
3100 IF NP < 1 THEN RETURN
3110 LET CP$ = PH$(1) : LET SP = 1
3120 IF NP = 1 THEN GOTO 3190
3130 FOR X = 2 TO NP
3140 IF PH$(X) = CP$ THEN GOTO 3180
3150 LET NR = NR + 1 : LET CL$(NR) = CP$
3160 LET PS(NR) = SP : LET PE(NR) = X - 1 : LET PL(NR) = X - SP
3170 LET SP = X : LET CP$ = PH$(X)
3180 NEXT X
3190 LET NR = NR + 1 : LET CL$(NR) = CP$
3200 LET PS(NR) = SP : LET PE(NR) = NP : LET PL(NR) = NP - SP + 1
3210 RETURN
