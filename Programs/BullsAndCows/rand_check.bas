10 REM Generate 1000 random numbers between 1 and 9
20 DIM C(10)
30 FOR I = 1 TO 1000
40 R = 1 + INT(RND(1) * 9.0)
50 C(R) = C(R) + 1
60 NEXT I
70 REM Display the distribution
80 FOR I = 0 TO 10
90 PRINT I, C(I)
100 NEXT I
110 END
