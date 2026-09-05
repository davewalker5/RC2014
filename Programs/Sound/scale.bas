10 REM SID-Ulator C major scale - ports D4/D5
20 RP = 212 : DP = 213 : DL = 500
30 REM Clear all writable SID registers
40 FOR R = 0 TO 24
50 OUT RP, R : OUT DP, 0
60 NEXT R
70 REM Voice 1: fast attack, full sustain, short release
80 OUT RP, 5 : OUT DP, 0
90 OUT RP, 6 : OUT DP, 240
100 REM Master volume (0-15), no filter
110 OUT RP, 24 : OUT DP, 10
120 PRINT "C MAJOR SCALE: C4 TO C5"
130 RESTORE
140 FOR N = 1 TO 8
150 READ N$, F
160 PRINT N$;
170 H = INT(F / 256) : L = F - 256 * H
180 OUT RP, 0 : OUT DP, L
190 OUT RP, 1 : OUT DP, H
200 REM Triangle waveform with gate on
210 OUT RP, 4 : OUT DP, 17
220 FOR T = 1 TO DL : NEXT T
230 REM Gate off, then leave a gap for release
240 OUT RP, 4 : OUT DP, 16
250 FOR T = 1 TO DL / 4 : NEXT T
260 NEXT N
270 OUT RP, 4 : OUT DP, 0
280 OUT RP, 24 : OUT DP, 0
290 PRINT : PRINT "SCALE COMPLETE"
300 END
310 REM Frequency words for a nominal 1 MHz SID clock
320 DATA "C4 ",4389,"D4 ",4927,"E4 ",5530,"F4 ",5859
330 DATA "G4 ",6577,"A4 ",7382,"B4 ",8286,"C5 ",8779
