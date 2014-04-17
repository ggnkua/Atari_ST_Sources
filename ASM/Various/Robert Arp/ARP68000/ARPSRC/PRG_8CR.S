 ; Program Name: PRG_8CR.S
 ;      Version: 1.003

 ; Assembly Instructions:

 ;      Assemble in Relocatable mode and save with a PRG extension.  From
 ; the desktop, change the extension to ACC.

 ; Function:

 ;      Identical to that of PRG_8BR.S, but this program uses a group of
 ; predeclared, function named arrays that are substituted for 'control' in
 ; the aes_pb, as each AES function is invoked.  In addition, a path for the
 ; data file is chosen via the AES file selector function.  An additional
 ; array set is provided after the fsel_input function is invoked, then a
 ; final set is printed when the message handler is entered the second time.

 ; Execution Instructions:

 ;      Place PRG_8CR.ACC in the root directory of your boot disk.  During the
 ; next power-up cycle, the desk accessory will be installed.  From the desktop
 ; select 'Accessory Arrays' two times in order to store the pertinent data in
 ; the file buffer.  At the first selection, the file selector will appear so
 ; that a path and filename can be chosen for the data file; the buffer contents
 ; are written to the file when the accessory is chosen the second time.

 lea        stack, a7            ; This must be the first instruction.

initialize_register_variables:
 move.w     #$C8, d3             ; *** D3 is variable for AES call number.
 lea        buffer(pc), a5       ; A5 is pointer to buffer.
 lea        aes_pb(pc), a4       ; A4 is pointer for aes pointer array.
 lea        hex_table(pc), a3    ; A3 points to hexadecimal ASCII digits.

 ; For each test point, the contents of each AES array are printed.

 ;                           
 ;                 TEST POINT 0: Before appl_init     
 ;                           
 bsr        print_arrays

initialize_application:          ; COMPUTE! AES book page 223.

 ; Application identification = apid returned in int_out[0] and global[2].

 ; Since the address of the predeclared appl_init array is already stored in
 ; aes_pb, only the trap 2 invocation need be done here.

 bsr        aes                  ; Invoke trap #2 AES exception.
 ;
 ;          TEST POINT 1: After appl_init, before menu_register
 ;
 bsr        print_arrays

menu_installation:               ; COMPUTE! AES book page 248.

 ; Menu identification number returned in int_out[0].

 move.l     #menu_register, (a4) ; Store address of next 'control' array.             
 lea        global(pc), a0       ; Fetch address of global array.
 move.w     4(a0), int_in        ; Application identification to int_in[0].
 move.l     #menu_text, addr_in  ; Menu text address to addr_in[0].
 bsr        aes                 
 move.w     int_out(pc), menu_id ; Store menu identification number.

 ; MAIN ACCESSORY LOOP

 ;
 ;          TEST POINT 2: After menu_register, before evnt_mesag
 ;
 bsr        print_arrays


wait_for_message:                ; Relinquish processor control.
 move.l     #evnt_mesag, (a4)    ; Store address of next 'control' array.
 move.l     #message, addr_in    ; Address of message array to addr_in.

 ; The above instruction must be executed each time evnt_mesag is invoked
 ; because the fsel_input function must store addresses in addr_in also.
 ; Furthermore, the evnt_mesag "control" array must be restored in aes_pb
 ; because it is replaced by the fsel_input "control" array whenever that
 ; function is invoked.  If these alterations did not take place, then the
 ; evnt_mesag setup could be simplified as was done in PRG_8BR.S.

 bsr        aes

 ; When a message is received it is placed in array 'message'.

 ; ****************************************************************************
 ; ****************************************************************************

message_handler:                 ; Entrance point when message is received.
 lea        message(pc), a0      ; Fetch address of array 'message'.
 cmpi.w     #$28, (a0)           ; Compare ACCESSORY OPEN code with message[0].
 bne.s      wait_for_message     ; Execute the evnt