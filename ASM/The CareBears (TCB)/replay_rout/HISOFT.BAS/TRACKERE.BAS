' ****************************************************
' *   Replay program in Power/HiSoft Basic adapted   *
' *       by Jason Brunt 19/9/90 (STE version)       *
' ****************************************************

' Define space for module & replay routine
DIM rbuff&(18000),mbuff&(54500)
' Get start addresses of buffers
rptr& = VARPTR ( rbuff&(0) )
mptr& = VARPTR ( mbuff&(0) )
PRINT "Please wait, loading data..."
' Load module and replay routines from disk
BLOAD "A:\REPLAY\TRACKERE.ROT",rptr&
BLOAD "A:\MODULES.MOD\VICTOR.MOD",mptr&
' Tell replay routine where in memory the module is (pointer to module)
POKEL rptr& + &h1C , mptr&
PRINT
PRINT "-TCB TRACKER- is playing 'VICTOR'."
PRINT "Press [SPACE] to exit."
' Execute replay routine
CALL LOC rptr& + &h28
' Exit program
SYSTEM
