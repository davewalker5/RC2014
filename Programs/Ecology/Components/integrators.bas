3000 REM Euler integration: y = y + st * f(t, y)
3010 LET I = I + 1
3020 LET Y(I) = Y(I - 1) + ST * F
3030 RETURN
3100 REM Predict : Euler integration: y = y + st * f(t, y)
3110 LET OT = T(I)
3120 LET OY = Y(I)
3130 LET FY = F
3140 LET Y(I) = Y(I) + ST * F
3150 REM Correct
3160 LET T(I) = T(I) + ST : GOSUB 2000
3170 LET Y(I + 1) = OY + ST * (FY + F) / 2.0
3180 LET Y(I) = OY : LET T(I) = OT : LET I = I + 1
3190 RETURN
3200 REM 4th-Order Runge-Kutta integration
3210 LET OY = Y(I) : LET OT = T(I)
3220 GOSUB 2000 : LET K1 = ST * F
3230 LET T(I) = OT + ST / 2.0 : LET Y(I) = OY + K1 / 2.0
3240 GOSUB 2000 : LET K2 = ST * F
3250 LET T(I) = OT + ST / 2.0 : LET Y(I) = OY + K2 / 2.0
3260 GOSUB 2000 : LET K3 = ST * F
3270 LET T(I) = OT + ST : LET Y(I) = OY + K3
3280 GOSUB 2000 : LET K4 = ST * F
3290 LET Y(I + 1) = OY + (K1 + 2 * K2 + 2 * K3 + K4) / 6.0
3300 LET T(I) = OT : LET Y(I) = OY : LET I = I + 1
3310 RETURN
