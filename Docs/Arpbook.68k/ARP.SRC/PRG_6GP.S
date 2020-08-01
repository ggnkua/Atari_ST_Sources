 ; Program Name: PRG_6GP.S
 ;      Version: 1.001

 ; Assembly Instructions:

 ;     Assemble in PC-relative mode and save with a TOS extension.

 ; Execution Instructions:

 ;     Execute from the desktop.

 ; Program Function:

 ; Within a subroutine addressed by XBIOS function $26, does the following:

 ;   1. Turns off keyclick sound.
 ;   2. Prints a string with GEMDOS function $9.
 ;   3. Prints a string with BIOS function $3.

 ; See programs PRG_6DP and PRG_6EP for further documentation.

 ; Program Purpose:

 ;   Illustrate the use of XBIOS function $26 to execute a subroutine in
 ;   the supervisor mode, even though the subroutine contains GEMDOS and
 ;   BIOS function calls.  This example shows that these function calls
 ;   can be executed within the subroutine, a contradiction to information
 ;   contained in some of the references (See page 3-13 of the Peel book,
 ;   for example.).

mainline:
 lea        stack, a7           ; Point A7 to this program's stack.

execute_subroutine_in_supervisor_mode:
 pea        subroutine          ; Push address of subroutine onto stack.
 move.w     #$26, -(sp)         ; Function = superexec = XBIOS $26 (dec 38).
 trap       #14                 ; XBIOS call.
 addq.l     #6, sp

terminate:
 move.w     #0, -(sp)           ; Function = p_term_old = GEMDOS $0.
 trap       #1                  ; GEMDOS call.
 
subroutine:         
 move.b     #6, $484
 pea        message             ; Push address of first string.
 move.w     #$9, -(sp)          ; GEMDOS function $9 = c_conws.
 trap       #1                  ; Print first string.
 addq.l     #6, sp
 lea        message_2, a3       ; Load address of second string.
print_string:
 move.b     (a3)+, d3
 beq.s      wait_for_keypress
 move.w     d3, -(sp)
 move.w     #2, -(sp)
 move.w     #3, -(sp)           ; BIOS function $3 = bconout.
 trap       #13
 addq.l     #6, sp
 bra.s      print_string        ; Branch until NULL detected.
wait_for_keypress: 
 move.w     #8, -(sp)           ; Function = c_necin = GEMDOS $8.
 trap       #1                  ; GEMDOS call.
 addq.l     #2, sp              ; Reposition stack pointer at top of stack.
 rts
 
 data
message:     dc.b 'This string printed with GEMDOS function $9.',$D,$A,0
message_2:   dc.b 'This string printed with BIOS function $3.',$D,$A,0
 align
 bss
             ds.l    48         ; Stack.  Must be large enough for system
                                ; use when the switch to supervisor mode
                                ; is accomplished by GEMDOS $26.
stack:       ds.l     0         
program_end: ds.l     0
 end
