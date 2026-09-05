10 REM SID-Ulator laser shots - ports D4/D5
20 RP = 212 : DP = 213 : DL = 5 : NS = 5
30 REM Clear all writable SID registers
40 FOR R = 0 TO 24
50 OUT RP, R : OUT DP, 0
60 NEXT R
70 REM Voice 1: fast attack, full sustain, short release
80 OUT RP, 5 : OUT DP, 0
90 OUT RP, 6 : OUT DP, 240
100 OUT RP, 24 : OUT DP, 10
110 PRINT "LASER SHOTS"
120 FOR N = 1 TO NS
130 PRINT "PEW!"
140 F = 24000 : GOSUB 500
150 REM Sawtooth waveform with gate on
160 OUT RP, 4 : OUT DP, 33
170 REM Sweep from high to low pitch
180 FOR F = 24000 TO 1000 STEP -1000
190 GOSUB 500
200 FOR T = 1 TO DL : NEXT T
210 NEXT F
220 REM Gate off, then pause between shots
230 OUT RP, 4 : OUT DP, 32
240 FOR T = 1 TO 500 : NEXT T
250 NEXT N
260 OUT RP, 4 : OUT DP, 0
270 OUT RP, 24 : OUT DP, 0
280 PRINT "LASER SHOTS COMPLETE"
290 END
500 REM Write the frequency word to voice 1
510 H = INT(F / 256) : L = F - 256 * H
520 OUT RP, 0 : OUT DP, L
530 OUT RP, 1 : OUT DP, H
540 RETURN
