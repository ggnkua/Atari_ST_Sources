 ; Program Name: PRG_6HP.S
 ;      Version: 1.001

 ; Assembly Instructions:

 ;     Assemble in PC-relative mode and save with a TOS extension.

 ; Execution Instructions:

 ;     Execute from the desktop.

 ; Program Function:

 ; A shorter version of PRG_6GP.S.  In addition this program provides a way
 ; to verify that the trap #13 system function corrupts the stack.

 ; Just before the trap #13 function is invoked to print a character, three
 ; words of data must be pushed onto the stack.  This having been done once,
 ; it should thenceforth be sufficient to simply move character data into the
 ; appropriate location within the stack to continue printing characters, as
 ; long as the stack pointer is not altered by the program.

 ; Unfortunately, the location at which the trap #13 function number is
 ; pushed or stored is corrupted by the trap when it is invoked, therefore,
 ; it is necessary to restore the function number each time, just before the
 ; trap is invoked again.  So we lose an advantage.
 
 ; But the device to which the character is printed is not changed, so we
 ; can take advantage of that to store it once, before we start printing 
 ; characters.

 ; Only after all characters are printed is the stack repositioned to the
 ; top of the stack.  In fact, in this program, I wait until after the
 ; wait_for_keypress algorithm has been executed before repositioning the
 ; stack pointer.

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
 move.b     #6, $484            ; Turn keyclick off.
 pea        message             ; Push address of first string.
 move.w     #$9, -(sp)          ; GEMDOS function $9 = c_conws.
 trap       #1                  ; Print first string.
 addq.l     #6, sp
 lea        message_2, a3       ; Load address of second string.
SET_UP_STACK:                   ; DO THIS BEFORE CHARACTER PRINTING COMMENCES.
 MOVE.W     #0, -(SP)           ; MAKE ROOM FOR CHARACTER TO BE PRINTED.
 MOVE.W     #2, -(SP)           ; OUTPUT DEVICE = SCREEN.
 MOVE.W     #3, -(SP)           ; FUNCTION = BIOS #3.
 MOVE.W     #3, D4              ; BECAUSE TRAP #13 CORRUPTS STACK.
print_string:
 move.b     (a3)+, d3
 beq.s      wait_for_keypress
 move.w     d4, (sp)            ; Restore BIOS function number because
 move.w     d3, 4(sp)           ; Trap #13 corrupts stack.
 trap       #13
 bra.s      print_string        ; Branch until NULL detected.
wait_for_keypress: 
 move.w     #8, -(sp)           ; Function = c_necin = GEMDOS $8.
 trap       #1                  ; GEMDOS call.
 addq.l     #8, sp              ; Reposition stack pointer at top of stack.
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
