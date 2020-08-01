 ; Program Name: PRG_8BR.S
 ;      Version: 1.002

 ; Assembly Instructions:

 ;      Assemble in Relocatable mode and save with a PRG extension.  From
 ; the desktop, change the extension to ACC.  Programs that are to function
 ; as desk accessories MUST be assembled in Relocatable mode.  If you design
 ; a desk accessory so that it can be assembled in PC-relative mode, and if
 ; you attempt to load that accessory via MultiDesk, you will receive an
 ; error pertaining to the attempt to read in the accessory.  If you place
 ; that accessory in the boot directory, the system will reset every time
 ; it attempts to load the accessory.  Sei gewarnt! 

 ; Function:

 ;      This program is used to observe system corruption of AES arrays
 ; during the execution of AES functions, as does PRG_8AR.S, and this program
 ; also creates a file in which to store its output data, but this program
 ; does not write its data via GEMDOS function $9 and redirection; instead it
 ; stores the data in a buffer, then writes the contents of the buffer to the
 ; file using GEMDOS function $40.

 ;      Also note some of the short cuts taken to prepare the control array
 ; for each AES function.

 ; Execution Instructions:

 ;      Place PRG_8BR.ACC in the root directory of your boot disk.  During the
 ; next power-up cycle, the desk accessory will be installed.  From the desktop
 ; select 'Accessory Arrays' two times in order to store the pertinent data in
 ; the file buffer.  After the second selection, the file will be created and
 ; the buffer's contents will be written thereto.  You can execute the desk
 ; accessory from within MultiDesk if you desire.  You may want to change the
 ; path for the file so that it is created on another disk or partition.

 lea        stack, a7            ; This must be the first instruction.

initialize_register_variables:
 lea        buffer(pc), a5       ; A5 is pointer to buffer.
 lea        control(pc), a4      ; A4 is pointer for array 'control'.
 lea        hex_table(pc), a3    ; A3 points to hexadecimal ASCII digits.

 ; For each test point, the contents of each AES array are printed.

 ;                           
 ;                 TEST POINT 0: Before appl_init     
 ;                           
 bsr        print_arrays

initialize_application:          ; COMPUTE! AES book page 223.

 ; Application identification = apid returned in int_out[0] and global[2].

 move.w     #$A, (a4)            ; Function = appl_init = AES $A.
 move.w     #1, 4(a4)            ; Return one 16-bit integer parameter.
 bsr        aes                  ; Invoke trap #2 AES exception.

 ;
 ;          TEST POINT 1: After appl_init, before menu_register
 ;
 bsr        print_arrays

menu_installation:               ; COMPUTE! AES book page 248.

 ; Menu identification number returned in int_out[0].
             
 move.w     #$23, (a4)           ; Function = menu_register = AES $23.
 move.w     #1, 2(a4)            ; Input one 16-bit integer parameter.
 move.w     #1, 6(a4)            ; Input one 32-bit pointer parameter.
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

 move.l     #message, addr_in    ; Address of message array to addr_in. 
 move.w     #$17, (a4)           ; Function = evnt_mesag = AES $17.
 move.w     #0, 2(a4)            ; Input one 16-bit integer parameter.
 move.w     #1, 4(a4)            ; Return one 16-bit integer parameter.    
 move.w     #1, 6(a4)            ; Input one 32-bit pointer parameter.
wait_for_message:
 bsr        aes

 ; When a message is received it is placed in array 'message'.

 ; ****************************************************************************
 ; ****************************************************************************

message_handler:                 ; Entrance point when message is received.
 lea        message(pc), a0      ; Fetch address of array 'message'.
 cmpi.w     #$28, (a0)           ; Compare ACCESSORY OPEN code with message[0].
 bne.s      wait_for_message     ; Execute the evnt_mesag function.
 move.w     8(a0), d0            ; The menu item selected is stored in element
                                 ; four (message[4]) of array 'message'.  This
                                 ; application's id # is in menu_id.
 cmp.w      menu_id(pc), d0      ; Was this application selected.
 bne.s      wait_for_message     ; Execute the evnt_mesag function.

 ; ****************************************************************************
 ; ****************************************************************************

 ; Execution proceeds past this point only when this application has been
 ; selected from the menu.

 ;
 ;          TEST POINT 3: In message handler, before evnt_mesag
 ;
 cmpi.w     #5, test             ; Have five array groups been printed.
 beq        wait_for_message     ; This effectively disables the handler.
 bsr        print_arrays
 cmpi.w     #5, test             ; Branch after 2nd entrance in message handler.
 beq.s      store_in_file        ; Create file and store buffer contents.
 bra        wait_for_message     ; Execute the evnt_mesag function.

store_in_file:
 lea        buffer(pc), a6       ; Fetch start address.
 suba.l     a6, a5               ; Calculate number of bytes stored in buffer.

create_file:                     ; COMPUTE! TOS book page 270.
 move.w     #0, -(sp)            ; File attribute = read/write.
 pea        filename(pc)
 move.w     #$3C, -(sp)          ; Function = f_create = GEMDOS $3C.
 trap       #1                   ; File handle is returned in D0.
 addq.l     #8, sp
 move.w     d0, d4               ; Save file handle in D4.

write_buffer_to_file:            ; Function = f_write.  COMPUTE! TOS p.274.
 pea        (a6)                 ; Push buffer's address.
 move.l     a5, -(sp)            ; Push byte count length.
 move.w     d4, -(sp)            ; COMPUTE!'s TOS book incorrectly specifies
 move.w     #$40, -(sp)          ; a longword operation here; see page 274.
 trap       #1
 lea        $C(sp), sp

close_output_file:               ; COMPUTE! TOS book page 272.
 move.w     d4, -(sp)            ; Push file handle. 
 move.w     #$3E, -(sp)          ; Function = GEMDOS $3E = f_close.
 trap       #1
 addq.l     #4, sp
 bra        wait_for_message     ; Execute the evnt_mesag function.

 ;
 ; SUBROUTINES
 ;
 
print_arrays:
 lea        newline(pc), a0       
 bsr        store_line        
 lea        test_header(pc), a0  ; Setup to fetch test point header.
 move.w     test(pc), d0         ; Load test point number into D0.
 lsl.w      #2, d0               ; Multiply by 4 to reach next pointer slot.     
 movea.l    0(a0,d0.w), a0       ; Print test point header.
 bsr        store_line
 lea        pre_spaces(pc), a0   ; Print spaces before column headers.
 bsr        store_line
 lea        aes_names(pc), a0    ; Print AES array column headers.
 bsr        store_line
 lea        pre_spaces(pc), a0   ; Print spaces before underline.
 bsr        store_line
 lea        aes_underline(pc), a0; Print AES underline.
 bsr        store_line
 moveq.l    #0, d7               ; D7 is up counter to print 5 rows.
 moveq.l    #4, d6               ; D6 is down counter to print 5 elements.
put_row:
 lea        aes_pb(pc), a6       ; Fetch parameter block address.
 move.w     #5, d5               ; D5 is array counter for 6 arrays.
 move.w     #11, d0              ; Print beginning spaces to line up columns.
put_space:
 move.b     #$20, (a5)+
 dbra       d0, put_space
put_element:                     ; Print contents of array element.
 move.w     d7, d0               ; Print array element number.
 andi.b     #$F, d0              ; Mask most significant nibble.
 move.b     0(a3,d0.w), d0       ; Store appropriate hex character in D0.
 move.b     d0, (a5)+
 move.b     #$3A, (a5)+          ; A colon.
 move.b     #$20, (a5)+          ; A space.
 move.w     d7, d0               ; Multiply contents of D7 by 2 in D0 to
 lsl.w      #1, d0               ; obtain offset for next array element.
 movea.l    (a6)+, a1            ; Copy array address into A1 and increment
                                 ; A6 to point to next array address.
 move.w     0(a1,d0.w), d0       ; Fetch contents of array element.
 moveq      #3, d2               ; D2 is loop counter for ASCII conversion.
convert_digit:                   ; Convert a nibble, then print it.
 rol.w      #4, d0               ; Rotate most significant nibble to the
                                 ; least significant nibble position.
 move.b     d0, d1               ; Copy least significant byte of D0 to D1.
 andi.b     #$F, d1              ; Mask out most significant nibble of D1.
 ext.w      d1                   ; Extend to word length.
 move.b     0(a3,d1.w), d1       ; Fetch ASCII hex digit to D1.
put_digit:
 move.b     d1, (a5)+
 dbra       d2, convert_digit    ; Loop until D2 = -1.
_put_spaces:
 move.b     #$20, (a5)+
 move.b     #$20, (a5)+
 dbra       d5, put_element
 lea        newline(pc), a0      ; Print a newline.
 bsr        store_line
 addi.w     #1, d7               ; Increment up counter.
 dbra       d6, put_row
 add.w      #1, test             ; Increment test for next test point.
 rts

aes:                             ; COMPUTE! AES book page 13,
 move.l     #aes_pb, d1          ; Address of aes_pb.
 move.w     #$C8, d0             ; AES identifier = $C8.
 trap       #2
 rts

store_line:
 move.b     (a0)+, d0
 beq.s      end_of_string
 move.b     d0, (a5)+            ; Store byte in buffer.
 bra.s      store_line
end_of_string:
 rts
 
 data
aes_pb:          dc.l control,global,int_in,int_out,addr_in,addr_out
test_header:     dc.l zero,one,two,three,four
zero:
 dc.b $D,$A,'TEST POINT 0: Before appl_init',$D,$A,$D,$A,0
one:
 dc.b $D,$A,'TEST POINT 1: After appl_init, before menu_register',$D,$A,$D,$A,0
two:
 dc.b $D,$A,'TEST POINT 2: After menu_register, before evnt_mesag',$D,$A,$D,$A,0
three:
 dc.b $D,$A,'TEST POINT 3: In message handler, before evnt_mesag',$D,$A,$D,$A,0
four:
 dc.b $D,$A,'TEST POINT 4: In message handler second time',$D,$A,$D,$A,0

hex_table:      dc.b  '0123456789ABCDEF'
newline:        dc.b  $D,$A,0
aes_header:     dc.b  '                                AES ARRAYS',$D,$A,0
aes_names:      dc.b  'CONTROL  GLOBAL   INT_IN   INT_OUT  ADDR_IN  '
                dc.b  'ADDR_OUT',$D,$A,0
aes_underline:  dc.b  '-------  -------  -------  -------  -------  '
                dc.b  '--------',$D,$A,0
pre_spaces:     dc.b  '            ',0
spaces:         dc.b  '  ',0
menu_text:      dc.b  '  Accessory Arrays ',0
filename:       dc.b  'E:\PRG_8\PRG_8BR.DAT',0

 bss
 align
 ;
 ; AES ARRAYS:
 ;
 
 ;     The addresses of the arrays declared below will be stored in the pointer
 ; array 'aes_pb'.  That happens because the program is assembled in Relocatable
 ; mode.  The sizes declared for the arrays are identical simply because I am
 ; making it easy to line up the program's output.
 
control:      ds.w     5  ; Control parameters.
global:       ds.w     5  ; Global parameters.
int_in:       ds.w     5  ; Input parameters.
int_out:      ds.w     5  ; Output parameters.
addr_in:      ds.w     5  ; Input addresses.
addr_out:     ds.w     5  ; Output addresses.

 ;
 ; APPLICATION VARIABLES
 ;

file_handle:  ds.w     1
test:         ds.w     1
message:      ds.l     4  ; 16 byte array.
menu_id:      ds.w     1
buffer:       ds.l $2000
              ds.l   300  ; Program stack.
stack:        ds.l     0  ; Address of program stack.
 end


