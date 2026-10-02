3000 REM Euler integration: y = y + st * f(t, y)
3010 LET I = I + 1
3020 LET Y(I) = Y(I - 1) + ST * F
3030 RETURN