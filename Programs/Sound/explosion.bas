10 REM SID-Ulator layered noise explosions - ports D4/D5
20 RP = 212 : DP = 213 : DL = 8000 : NE = 5
30 VL = 10 : RL = 11
40 REM Clear all writable SID registers
50 FOR R = 0 TO 24
60 OUT RP, R : OUT DP, 0
70 NEXT R
80 REM Voice 1: quieter impact noise with a short release
90 OUT RP, 5 : OUT DP, 0
100 OUT RP, 6 : OUT DP, 135
110 REM Voice 2: coarse rumble noise with a longer release
120 OUT RP, 12 : OUT DP, 0
130 OUT RP, 13 : OUT DP, 240 + RL
140 OUT RP, 24 : OUT DP, VL
150 PRINT "NOISE EXPLOSIONS"
160 FOR N = 1 TO NE
170 PRINT "BOOM!"
180 REM Bright noise for the initial crack
190 R = 0 : F = 16000 : GOSUB 500
200 REM Slower noise gives a coarse rumbling tail
210 R = 7 : F = 1500 : GOSUB 500
220 OUT RP, 11 : OUT DP, 129
230 OUT RP, 4 : OUT DP, 129
240 REM Brief impact with both noise voices sounding
250 FOR T = 1 TO 100 : NEXT T
290 REM Release both voices: crack dies before the rumble
300 OUT RP, 4 : OUT DP, 128
310 OUT RP, 11 : OUT DP, 128
320 REM Let the envelopes finish before the next blast
330 FOR T = 1 TO DL : NEXT T
340 NEXT N
350 OUT RP, 4 : OUT DP, 0
360 OUT RP, 11 : OUT DP, 0
370 OUT RP, 24 : OUT DP, 0
380 PRINT "EXPLOSIONS COMPLETE"
390 END
500 REM Write frequency to voice base register R
510 H = INT(F / 256) : L = F - 256 * H
520 OUT RP, R : OUT DP, L
530 OUT RP, R + 1 : OUT DP, H
540 RETURN
