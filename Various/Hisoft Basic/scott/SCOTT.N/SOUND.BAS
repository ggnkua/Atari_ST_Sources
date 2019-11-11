
REM            SOUND.BAS
REM     SOUND,channel(1-3),volume,note,octave,duration.
REM
PRINT "                 S O U N D ."
PRINT "         Press a key to stop."
SOUND 1,15,10,3,5   ' Short note
SOUND 1,15,12,3,20   ' longer,higher note
SOUND 1,15,8,3,20    ' lower
SOUND 1,15,8,2,24    ' much lower
SOUND 1,15,3,3,60    ' lower still, longer.
SOUND 1,15,6,4,20    ' higher ocatave (4)
SOUND 1,15,2,4,30    ' final lower note
SOUND 1,0            ' stop



