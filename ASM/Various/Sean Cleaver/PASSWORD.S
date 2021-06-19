* This month's Screenfull submission is supplied by programmer
* Sean Cleaver of East Hoathly in Sussex. It's a password program
* written in 68000 assembly language using Devpac 2. Assemble it
* and store save it in the AUTO folder of your boot disk. When the
* ST is booted up the program prompts you for a password (458, but
* it can be changed to any numbers or digits), and won't continue
* unless you enter the correct one.

*  The protection method is quite primitive, but the idea is sound
* and you could build on the idea. How about storing the directory
* on track 81 and then copying it to its correct place when you enter
* the correct password. You'd also need a protector to put it back on
* track 80 afterwards. Or the utility could de-scramble a file that
* had been encrypted for security.

** A password program by Sean Cleaver
** Written in 68000 assembly language using Devpac 2
** Password = 458
** Put this program first in an AUTO folder
** Atari ST User September 1990.

start  PEA mess(PC)     stack address of message
       MOVE #9,-(A7)     c_conws...print a string
       TRAP #1          GEM BDOS
       ADDQ.L #6,A7     tidy stack
input  BSR key          get keypress
       CMP #'4',D0     is it a '4' ?
       BNE input     if not equal then branch to input
       BSR key          get keypress
       CMP #'5',D0     is it a '5' ?
       BNE input     if not equal then branch to input
       BSR key          get keypress
       CMP #'8',D0     is it an '8' ?
       BNE input     if not equal then branch to input
exit   MOVE #$4C,-(A7)     p_term...finished!
       TRAP #1          GEM BDOS
key    MOVE #8,-(A7)     c_necin...get a keypress
       TRAP #1          GEM BDOS
       ADDQ.L #2,A7     tidy stack
       RTS          return from subroutine
mess   DC.B 27,69,13,10,27,89,35,40,27,112,"Enter Password: "
       DC.B 27,113,27,89,37,37,"By Sean Cleaver ",189," 1990",0

