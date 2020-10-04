' *************************************
' *    STEREO PLAYBACK DEMO           *
' *    HISOFT/POWER BASIC ROUTINES    *
' *  (C) AUDIO VISUAL RESEARCH 1991   *
' *************************************
' THIS PROGRAM PLAYS A MONO SAMPLE ON THE LEFT AND RIGHT CHANNELS.
' THE PROGRAM THEN PLAYS A STEREO SAMPLE THROUGH THE REPLAY STEREO HARDWARE.
'
'
' MAKE SPACE FOR SAMPLE AND CODE
DIM c%(2000),s%(7000),s1%(31000)
'
' *****************************
' * LOAD MACHINE CODE ROUTINE *
' *****************************
code&=VARPTR(c%(0))
BLOAD "PLAYBACK.PRG",code&
code&=code&+28
'
play&=code&
back&=code&+4
halt&=code&+8
wait&=code&+12
'
' *****************************
' * LOAD UNSIGNED MONO SAMPLE *
' *****************************
PRINT "LOADING MONO SAMPLE...."
sample&=VARPTR(s%(0))
BLOAD "WELCOME.AVR",sample&

'
' *********************************
' * LOAD SIGNED STEREO AVR SAMPLE *
' *********************************
PRINT "LOADING STEREO SAMPLE...."
sample1&=VARPTR(s1&(0))
BLOAD "one2.avr",sample1&
'
' PLAY UNSIGNED MONO SAMPLE
'
' POKE START ADDRESS OF SAMPLE + offset for AVR header
POKEL code&+20,sample&+128
' POKE LENGTH OF SAMPLE
POKEL code&+24,6700
' POKE SAMPLE FREQUENCY
POKEW code&+28,6
' POKE LOOP OFF
'
POKEW code&+30,0
' POKE PLAY LEFT MODE
POKEW code&+32,4
PRINT "PLAYING MONO SAMPLE ON LEFT CHANNEL...."
CALL LOC play&
CALL LOC wait&
'
' POKE PLAY RIGHT MODE
POKEW code&+32,5
PRINT "PLAYING MONO SAMPLE ON RIGHT CHANNEL...."
CALL LOC play&
CALL LOC wait&
'
' POKE BOTH CHANNEL MODE
POKEW code&+32,6
PRINT "PLAYING MONO SAMPLE ON BOTH CHANNELS...."
' POKE MODE
CALL LOC play&
CALL LOC wait&
PRINT
PRINT
'
' PLAY STEREO AVR SAMPLE
'
' POKE START ADDRESSES OF STEREO SAMPLE
POKEL code&+20,sample1&+128
' POKE LENGTH OF SAMPLE
POKEL code&+24,30000-128
' POKE LOOP OFF
POKEW code&+30,0
' POKE STEREO PLAY MODE
POKEW code&+32,7
'
FOR x%=0 TO 4
  ' POKE SAMPLE FREQUENCY
  POKEW code&+28,x%+4
  CALL LOC  play&
  PRINT "PLAYING STEREO AVR SAMPLE AT FREQUENCY ";x%+4
  CALL LOC wait&
NEXT x%
