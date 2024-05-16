' ****************************************************
' *   Replay program in Power/HiSoft Basic adapted   *
' *       by Jason Brunt  19/9/90 (ST version)       *
' ****************************************************

' Define space for module & replay routine
DIM rbuff&(48000/4),mbuff&(109000/4)
' Get start addresses of buffers
rptr& = VARPTR ( rbuff&(0) )
mptr& = VARPTR ( mbuff&(0) )
PRINT "Please wait, loading data..."
' Load module and replay routines from disk
BLOAD "A:\REPLAY\TRACKER.ROT",rptr&
BLOAD "A:\MODULES.MOD\VICTOR.MOD",mptr&
' Tell replay routine where in memory the module is
POKEL rptr& + &h1C , mptr&
' Set loudness; on=-1 off=0
POKEL rptr& + &h20 , -1
PRINT
PRINT "-TCB TRACKER- is playing 'VICTOR'."
PRINT "Press [SPACE] to exit."
' Execute replay routine
CALL LOC rptr& + &h2C
' Exit program
SYSTEM
