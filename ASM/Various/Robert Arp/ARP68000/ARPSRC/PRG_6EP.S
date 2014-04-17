 ; Program Name: PRG_6EP.S
 ;      Version: 1.001

 ; Assembly Instructions:

 ;     Assemble in PC-relative mode and save with a PRG extension.

 ; Execution Instructions:

 ;     Execute from the desktop.

 ; Program Function:

 ;     Turns off keyclick sound.  Refer to PRG_6DP.S for documentation.

 ; Program Purpose:

 ;   1. Illustrate the use of XBIOS function $26.  This function forces a
 ;      subroutine to be executed in the supervisor mode.  The subroutine
 ;      may be located at any address in memory.  Function $26 expects the
 ;      address of the subroutine to be on the stack.

 ;   2. Point out error in Internals book (The example in the Internals
 ;      book is garbage).  The "address" which must be pushed on the stack 
 ;      is the address of a subroutine that is terminated with an RTS
 ;      instruction.  See page 3-13 of the Peel book.

 ;   3. Illustrate the confusion created by writers of reference books when
 ;      they are not consistent in their usage of number bases.  To wit:
 ;      in the Internals book, GEMDOS function numbers are presented in
 ;      hexadecimal.  The index of these functions are immediately followed
 ;      by the BIOS and XBIOS functions, which are numbered in decimal.  I
 ;      will try remember to use the following notation to express the BIOS
 ;      and XBIOS in both number bases so that it will be easier for you to
 ;      look them up in the Internals book:

 ;      Function = superexec = XBIOS $26 (dec 38).

 ;      Where (dec 38) indicates that the digits 38 are the decimal 
 ;      equivalent of the hexadecimal number 26.

mainline:
 lea        stack, a7           ; Point A7 to this program's stack.

execute_subroutine_in_supervisor_mode:
 pea        turn_key_click_off  ; Push address of subroutine onto stack.
 move.w     #$26, -(sp)         ; Function = superexec = XBIOS $26 (dec 38).
 trap       #14                 ; XBIOS call.
 addq.l     #6, sp

terminate:
 move.w     #0, -(sp)           ; Function = p_term_old = GEMDOS $0.
 trap       #1                  ; GEMDOS call.
 
turn_key_click_off:             ; Subroutine to be executed in supervisor
 move.b     #6, $484            ; mode.  
 rts
     
             ds.l    24         ; Stack.
stack:       ds.l     0         ; Address of stack.
program_end: ds.l     0
 end
