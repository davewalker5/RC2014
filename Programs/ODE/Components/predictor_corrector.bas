3000 REM Predict : Euler integration: y = y + st * f(t, y)
3010 LET OY = Y(I) : LET FY = F : LET Y(I) = Y(I) + ST * F
3020 REM Correct
3030 LET T(I) = T(I) + ST : GOSUB 2000
3040 LET Y(I + 1) = OY + ST * (FY + F) / 2.0
3050 LET Y(I) = OY : LET T = T - ST : LET I = I + 1
3060 RETURN
