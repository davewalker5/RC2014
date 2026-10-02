3000 REM Predict : Euler integration: y = y + st * f(t, y)
3010 LET OT = T(I)
3020 LET OY = Y(I)
3030 LET FY = F
3040 LET Y(I) = Y(I) + ST * F
3050 REM Correct
3060 LET T(I) = T(I) + ST : GOSUB 2000
3070 LET Y(I + 1) = OY + ST * (FY + F) / 2.0
3080 LET Y(I) = OY : LET T(I) = OT : LET I = I + 1
3090 RETURN
