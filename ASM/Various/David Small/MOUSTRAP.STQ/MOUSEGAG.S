***************************************************************************
*                                                                         *
*  MouseTrap!  Written by Daniel L. Moore and David Small.                *
*       --MOUSEGAG modification by Matthew Loveless (7 July 1986)         *
*                                                                         *
*  START magazine, Fall 1986.      Copyright 1986 by Antic Publishing.    *
*                                                                         *
***************************************************************************
* 

* Install the new mouse packet handler.  This is done by having the program
* in the AUTO folder.  Unfortunately AES hasn't been inited, so the GEM
* mouse handler isn't resident yet.  We get around this by stealing the
* TRAP 14 vector so we can handle the initmouse function.  (This could all
* be avoided by running as a desk accessory, but that uses up one of the
* precious desk accessory slots.)  It actually isn't nearly as bad as it 
* sounds.  


* These are the system mouse work variables.  They are NOT guaranteed to 
* remain the same in future version of TOS.  But they are the only way
* to get the data need so we use them anyway.
IGNORE:     equ     $27e7         ; non zero means ignore packet from mouse 
MOUSEX:     equ     $26e0         ; mouse X position                        
MOUSEY:     equ     $26e2         ; mouse Y position                        
MAXX:       equ     $2686         ; maximum X coordinate on screen          
MAXY:       equ     $2688         ; maximum Y coordinate on screen    

* This is the pointer to the BIOS register save area.  It is guaranteed to
* stay the same in future TOS versions.
SAVEPTR    equ      $04a2     

* We need the address of the TRAP 14 jump table.  The easy way to get it is
* to execute an illegal XBIOS command (func # > 39).  On exit A0 will point
* to the table start + 2.  (How convenient.)
goforit:  move.w    #127, -(A7)         ; allow for new function #'s
          trap      #14                 ; do the trap
          adda.l    #2, A7              ; clear the stack
          suba.l    #2, A0              ; get the table start
          move.l    A0, trap14table

* now we need to install our trap 14 handler in place of the system one.
* the trap 14 vector is at $b8, which is in protected memory.  Must be in
* super mode to change it.

          pea       setmytrap           ; the address of the routine to run
          move.w    #38, -(A7)          ; supexec
          trap      #14  
          adda.l    #6, A7

* as of now  all TRAP #14 calls are being handle by our code
term:
          movea.l   4(A7), A0           ; get the start of the basebage
          move.l    $c(A0), D0          ; the length of the text segment
          add.l     #256, D0            ; plus the base page
          clr.l     -(A7)               ; no error (we think)
          move.l    D0,-(a7)            ; memory to keep
          move.w    #$31,-(a7)          ; ptermres
          trap      #1                  ; whoopee
*
* we'd better not end up here.  major **** up otherwise.
*

* Install mytrap14 as the new system TRAP 14 handler
setmytrap:
          lea       mytrap14, A0
          move.l    A0, $B8             ; the trap 14 vector
          rts                           ; short ain't it.

*-----------------------------------------------------------------------
* This is the new TRAP 14 handler.  It does almost the exact same thing as
* the system TRAP handler, but it also checks for initmous commands. 

mytrap14:      movea.l   SAVEPTR, A1         ; register save area.
               move.w    (A7)+, D0           ; SR from trap
               move.w    D0, -(A1)           ; save it
               move.l    (A7)+, -(A1)        ; save return address
               movem.l   D3-D7/A3-A7, -(A1)  ; save the registers
               move.l    A1, SAVEPTR
               
* Check whether the BIOS call was from user or super mode.  And set the
* correct stack.
               btst      #13, D0
               bne       supermode           ; all is fine and dandy
               move.l    USP, A7             ; get user stack
supermode:     movea.l   trap14table, A0     ; the system trap jump table

               move.w    (A7)+, D0           ; get the function number
               cmp.w     (A0)+, D0           ; out of range?
               bge       done                ; yes, done

* check if initmous function
               cmpi.w    #0, D0
               bne       doit                ; nope, just treat it normally
* Yes it is.  Check if it is a enable mouse relative mode command
               cmpi.w    #1, (A7)            ; type parameter
               bne       doit                ; nope, we don't want it then
* This is the function call and type we want.  Lets 'lie' to the system
* about the call.  We do this by telling it to install our mouse handler
* instead of the one requested.  We set the chain thru from out handler
* to the new one.
               movea.l   6(A7), A3
               move.l    A3, sysjmp          ; save their routine address
               lea       doit_toit, A3       ; our routine address
               move.l    A3, 6(A7)           ; in place of theirs in the call
* now we fall thru to the standard TRAP handler code

* figure out which vector to use
doit:          lsl.w     #2, D0              ; long index
               move.l    0(A0, D0.w), D0     ; pointer to function
               movea.l   D0, A0              ; check for negative
               bpl       direct
               movea.l   (A0), A0            ; indirect refernece
direct:        movea.l   #0, A5              ; A5 points to zero page
again:         jsr       (A0)                ; go do it

* clean up and exit.
done:          movea.l   SAVEPTR, A1         ; get the save area
               movem.l   (A1)+, D3-D7/A3-A7
               move.l    (A1)+, -(A7)        ; return address
               move.w    (A1)+, -(A7)        ; SR
               move.l    A1, SAVEPTR
               rte                           ; all done, go home

*-----------------------------------------------------------------------

* The bottom Y coordinate for the menu.  Need to tell where we should stop
* letting the mouse move.
menuy:         dc.w      0

* This is the address of the system TRAP 14 jump table.
trap14table    dc.l      0

*-----------------------------------------------------------------------
*MOUSE_GAG CODE
*         Intercepts mouse packet and decrements the delta-y by one.
*         Gem interprets this as an upward movement of the mouse.  Every
*         mouse movement forces the mouse one position upward which
*         causes the mouse to creep towards the top of the screen.
*
*
* On entry to this routine A0 points to a 3 byte mouse packet.  First byte
* is button status, 2nd is delta X, 3rd is delta Y.  Really nice of them.
doit_toit:
          tst.b     IGNORE         ; check if watch mouse
          bne       here           ; go to next routine
          
          move.l    D0, -(A7)      ; get work register

          move.b    2(A0), D0      ; get the delta Y value
          subq.b    #1, D0         ; force mouse upwards
          move.b    D0, 2(A0)      ; and put it back
*
leave     move.l    (A7)+, D0      ; original stack
here:     jmp       $12345678      ; go to system mouse handler
sysjmp:   equ       here+2

codeend: 
          end
