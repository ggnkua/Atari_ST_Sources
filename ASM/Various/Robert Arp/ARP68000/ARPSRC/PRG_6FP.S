 ; Program Name: PRG_6FP.S
 ;      Version: 1.001

 ; Assembly Instructions:

 ;     Assemble in PC-relative mode and save with a PRG extension.

 ; Execution Instructions:

 ;     Execute from the desktop.

 ; Program Function:

 ; Turns on keyclick sound so that the programs that turn it off can be
 ; tested.  See programs PRG_6DP and PRG_6EP for further documentation.

mainline:
 lea        stack, a7           ; Point A7 to this program's stack.

execute_subroutine_in_supervisor_mode:
 pea        turn_key_click_on   ; Push address of subroutine onto stack.
 move.w     #$26, -(sp)         ; Function = superexec = XBIOS $26 (dec 38).
 trap       #14                 ; XBIOS call.
 addq.l     #6, sp

terminate:
 move.w     #0, -(sp)           ; Function = p_term_old = GEMDOS $0.
 trap       #1                  ; GEMDOS call.
 
turn_key_click_on:              ; Subroutine to be executed in supervisor
 move.b     #7, $484            ; mode.
 rts
     
             ds.l    24         ; Stack.
stack:       ds.l     0         ; Address of stack.
program_end: ds.l     0
 end
