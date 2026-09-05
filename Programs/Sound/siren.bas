10 REM SID-Ulator rising and falling siren - ports D4/D5
20 RP = 212 : DP = 213 : DL = 20 : NC = 5
30 FL = 6000 : FH = 18000 : FS = 300
40 REM Clear all writable SID registers
50 FOR R = 0 TO 24
60 OUT RP, R : OUT DP, 0
70 NEXT R
80 REM Voice 1: fast attack, full sustain, short release
90 OUT RP, 5 : OUT DP, 0
100 OUT RP, 6 : OUT DP, 240
110 OUT RP, 24 : OUT DP, 10
120 PRINT "RISING AND FALLING SIREN"
130 F = FL : GOSUB 500
140 REM Triangle waveform, gate stays on during sweeps
150 OUT RP, 4 : OUT DP, 17
160 FOR N = 1 TO NC
170 FOR F = FL TO FH STEP FS
180 GOSUB 500
190 FOR T = 1 TO DL : NEXT T
200 NEXT F
210 FOR F = FH - FS TO FL STEP -FS
220 GOSUB 500
230 FOR T = 1 TO DL : NEXT T
240 NEXT F
250 NEXT N
260 REM Release the note before muting
270 OUT RP, 4 : OUT DP, 16
280 FOR T = 1 TO 100 : NEXT T
290 OUT RP, 4 : OUT DP, 0
300 OUT RP, 24 : OUT DP, 0
310 PRINT "SIREN COMPLETE"
320 END
500 REM Write the frequency word to voice 1
510 H = INT(F / 256) : L = F - 256 * H
520 OUT RP, 0 : OUT DP, L
530 OUT RP, 1 : OUT DP, H
540 RETURN
