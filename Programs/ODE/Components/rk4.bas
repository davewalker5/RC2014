3000 REM 4th-Order Runge-Kutta integration
3010 LET OY = Y(I) : LET OT = T(I)
3020 GOSUB 2000 : LET K1 = ST * F
3030 LET T(I) = OT + ST / 2.0 : LET Y(I) = OY + K1 / 2.0
3040 GOSUB 2000 : LET K2 = ST * F
3050 LET T(I) = OT + ST / 2.0 : LET Y(I) = OY + K2 / 2.0
3060 GOSUB 2000 : LET K3 = ST * F
3070 LET T(I) = OT + ST : LET Y(I) = OY + K3
3080 GOSUB 2000 : LET K4 = ST * F
3090 LET Y(I + 1) = OY + (K1 + 2 * K2 + 2 * K3 + K4) / 6.0
3100 LET T(I) = OT : LET Y(I) = OY : LET I = I + 1
3110 RETURN
