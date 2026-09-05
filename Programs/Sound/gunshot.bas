10 REM SID-Ulator gunshots - ports D4/D5
20 RP = 212 : DP = 213 : DL = 5000 : NE = 5
30 VL = 10 : RL = 10
40 REM Clear all writable SID registers
50 FOR R = 0 TO 24
60 OUT RP, R : OUT DP, 0
70 NEXT R
80 REM Voice 1: fast attack, full sustain, long release
90 OUT RP, 5 : OUT DP, 0
100 OUT RP, 6 : OUT DP, 240 + RL
110 PRINT "GUNSHOTS"
120 FOR N = 1 TO NE
130 PRINT "BANG!"
140 F = 6000 : GOSUB 500
150 OUT RP, 24 : OUT DP, VL
160 REM Noise waveform with gate on
170 OUT RP, 4 : OUT DP, 129
180 REM Brief initial blast, then trigger envelope release
190 FOR T = 1 TO 100 : NEXT T
200 OUT RP, 4 : OUT DP, 128
210 REM Let the SID fade the noise with master volume fixed
220 REM Wait for the release tail before the next blast
230 FOR T = 1 TO DL : NEXT T
290 NEXT N
300 OUT RP, 4 : OUT DP, 0
310 OUT RP, 24 : OUT DP, 0
320 PRINT "GUNSHOTS COMPLETE"
330 END
500 REM Write the noise frequency word to voice 1
510 H = INT(F / 256) : L = F - 256 * H
520 OUT RP, 0 : OUT DP, L
530 OUT RP, 1 : OUT DP, H
540 RETURN
