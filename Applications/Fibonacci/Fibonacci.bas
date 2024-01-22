10 PRINT "How many Fibonacci numbers do you want to print? "
15 INPUT n
20 LET a = 0
30 LET b = 1
40 PRINT a
50 PRINT b
60 FOR i = 3 TO n
70 LET c = a + b
80 PRINT c
90 LET a = b
100 LET b = c
110 NEXT i
120 END
