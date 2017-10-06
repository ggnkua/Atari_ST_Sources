10    '**************************************************************
20    '**             A MIDI PROGRAM THAT PLAYS SILENT NIGHT       **
30    '**                        WRITTEN BY                        **
40    '**                    JAMES M. MAYFIELD                     **
50    '**                    NOVEMBER 17, 1985                     **
60    '**************************************************************
70    ' The note values change by 1 half step for each change in number
80    ' Middle C = 60
90    ' The length is determined by the following numbers:
100   '     2 = sixteenth note
110   '     3 = dotted sixteenth note
120   '     4 = eighth note
130   '     5 = dotted eighth note
140   '     6 = quarter note
150   '     7 = dotted quarter note
160   '     8 = half note
170   '     9 = dotted half note
180   '    10 = whole note
190   INPUT "ENTER TEMPO";TEMPO%
200   FOR COUNT% = 1 TO 46
210   READ N1%,N2%,N3%,N4%,LENGTH%
220   OUT 3,&H90:'   STATUS BYTE TO TURN NOTES ON
230   OUT 3,N1%:OUT 3,64:OUT 3,N2%:OUT 3,64:OUT 3,N3%:OUT 3,64:OUT 3,N4%:OUT 3,64
240   FOR Y = 1 TO LENGTH% * TEMPO% * 2:NEXT: ' DELAY WHILE CHORD PLAYS
250   OUT 3,&H80:'  STATUS BYTE TO TURN NOTES OFF
260   OUT 3,N1%:OUT 3,64:OUT 3,N2%:OUT 3,64:OUT 3,N3%:OUT 3,64:OUT 3,N4%:OUT 3,64
270   NEXT: '  GO AND PLAY NEXT CHORD
280   ' DATA FOR NOTES AND LENGTH (N1%,N2%,N3%,N4%,LENGTH%)
290   DATA 65,62,58,46,5,67,63,58,46,2,65,62,58,46,4,62,58,53,46,7
300   DATA 65,62,58,46,5,67,63,58,46,2,65,62,58,46,4,62,58,53,46,7
310   DATA 72,63,57,53,6,72,63,57,53,4,69,60,53,53,7
320   DATA 70,62,53,46,6,70,62,53,46,4,65,62,58,46,7
330   DATA 67,63,58,51,6,67,63,58,51,4,70,67,55,51,5,69,65,57,51,2,67,63,58,51,4
340   DATA 65,62,58,46,5,67,63,58,46,2,65,62,58,46,4,62,58,53,46,7
350   DATA 67,63,58,51,6,67,63,58,51,4,70,67,55,51,5,69,65,57,51,2,67,63,58,51,4
360   DATA 65,62,58,46,5,67,63,58,46,2,65,62,58,46,4,62,58,53,46,7
370   DATA 72,63,57,53,6,72,63,57,53,4,75,69,60,53,5,72,63,57,53,2,69,60,53,53,4
380   DATA 70,62,53,46,7,74,53,58,46,7
390   DATA 70,62,58,53,5,65,62,58,53,2,62,58,53,53,4,65,62,53,41,5,58,60,53,41,2,60,57,51,41,4
400   DATA 58,58,50,46,9
