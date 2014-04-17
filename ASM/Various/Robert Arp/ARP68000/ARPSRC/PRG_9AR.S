 ; Program Name: DONGLE.S
 ;      Version: 1.003

 ;     Version 1.003 added (pc) to the following instruction:

 ; move.w    int_out(pc), d4      ; Store menu identification number in D4.

 ; Assembly Instructions:

 ;     Assemble in Relocatable mode and save with a PRG extension.  From
 ; the desktop, change the extension to ACC and copy DONGLE.ACC to the
 ; C partition of the hard disk.

 ; Execution Instructions:

 ;     Before this program is executed, trap 11 must be installed via the
 ; execution of program DONGTRAP.PRG.  Execute this program by selecting
 ; it from the accessory menu.

program_start:
 lea       stack(pc), a7        ; A7 points to program's stack address.
 lea       aes_pb(pc), a3       ; aes_pb = AES parameter block.
 lea       control(pc), a4      ; A4 is pointer for array "control".
 move.w    #$C8, d3             ; *** AES call number in D3.

initialize_application:
 move.w    #$A, (a4)            ; Function = appl_init = AES $A.
 move.w    #1, 4(a4)            ; Return one int_out parameter.
 move.l    a3, d1               ; A3 contains address of aes parameter block.
 move.w    d3, d0               ; D3 contains AES call number.
 trap      #2                   ; apid returned in int_out[0] and global[2].

menu_installation:             
 move.w    #$23, (a4)           ; Function = menu_register = AES $23.
 move.w    #1, 2(a4)            ; Pass one int_in parameter.         
 move.w    #1, 6(a4)            ; Pass one addr_in parameter.
 move.w    int_out(pc), int_in  ; Application identification to int_in[0].
 move.l    #menu_text, addr_in  ; Menu text address to addr_in[0].
 move.l    a3, d1               ; Address of aes parameter block to D1.
 move.w    d3, d0               ; D3 contains AES call number.
 trap      #2                   ; Menu identification number returned
                                ; in int_out[0].
 move.w    int_out(pc), d4      ; Store menu identification number in D4.

 ; MAIN ACCESSORY LOOP

wait_for_message:               ; Relinquish processor control.
 move.w    #$17, (a4)           ; Function = evnt_mesag = AES $17.
 move.w    #0, 2(a4)
 move.l    #message, addr_in    ; Address of message array to addr_in.
 move.l    a3, d1               ; Address of aes parameter block to D1.
 move.w    d3, d0               ; AES call number to D0.
 trap      #2                   ; Message received is placed in array
                                ; "message".

; Enters here only when a message is received.

message_handler:                ; Entrance point when message is received.
 cmpi.w    #$28, message        ; Compare AC OPEN code with message[0].
 bne.s     wait_for_message     ; Execute the evnt_mesag function.
 move.w    message+8, d0        ; id_selected (message[4]) = menu ID of
                                ; item user selected.
 cmp.w     d4, d0               ; Was this application selected.
 bne.s     wait_for_message     ; Execute the evnt_mesag function.

invoke_software_dongle:
 trap       #11
 bra        wait_for_message

 data
menu_text:       dc.b '  DONGLE  ',0
 align                    ; Align storage on a word boundary.
 ;
 ; AES PARAMETER BLOCK
 ; 
aes_pb:          dc.l   control,global,int_in,int_out,addr_in,addr_out
 ;
 ; AES CONTROL TABLE
 ;
 bss
control:          ds.w    5
global:           ds.w    3
                  ds.l    6
int_in:           ds.w    1     ; Input parameter.
int_out:          ds.w    1     ; Output parameter.
addr_in:          ds.l    1     ; Input address.
addr_out:         ds.l    1     ; Output address.
 ;
 ; OTHER VARIABLES
 ;
message:          ds.w    8
                  ds.l   48
stack:            ds.l    0
program_end:      ds.l    0
 end

