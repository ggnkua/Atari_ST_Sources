 ; Program Name: PRG_8AR.S
 ;      Version: 1.006

 ; MAJOR NOTE:

 ;      THIS PROGRAM MAY NOT FUNCTION CORRECTLY IF TURBO ST IS INSTALLED.

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
 ; during the execution of AES functions.  Data is output into a file which
 ; assumes the name declared at the variable "filename".  You may wish to
 ; alter the file's path to something like "A:\PRG_8DR.DAT" if you decide to
 ; assemble and execute the program.

 ;      The program's output data is written with GEMDOS function $9, the write
 ; string to screen function.  But the data is redirected to the file with
 ; GEMDOS function $46, the f_force function.

 ; Execution Instructions:

 ;      Place PRG_8AR.ACC in the root directory of your boot disk.  During
 ; the next power-up cycle, the program will be installed in memory as a desk
 ; accessory; assuming that it is not blocked by a program that permits desk
 ; accessory loading selections.  Of course, if you use MultiDesk, you need
 ; not power up to use PRG_8AR.ACC immediately.

 ;      The desk accessory is identified as a menu selection by the name
 ; Accessory Arrays.  Choose the desk accessory twice so that the contents
 ; of the arrays will be printed twice from within the message handler.  The
 ; message handler is disabled after it has been invoked twice.

 ; MAJOR NOTE:

 ;      Although accessories such as MultiDesk add significant power to a ST
 ; system; and although initial testing of a desk accessory program can be
 ; accomplished via MultiDesk loading of the program, thereby alleviating the
 ; the testing process, the program under test cannot be pronounced correct
 ; until it has been permitted to load normally from the boot disk.

 ;      For example, if the first statement of this program, which loads the
 ; stack's address into A7, is moved to a location following any instruction
 ; that requires stack usage, the accessory will function perfectly when it is
 ; loaded and executed via MultiDesk; but it will bomb during boot because, at
 ; that time, no default stack has yet been assigned by the system.

 ; REMEMBER:  Programs executed during boot MUST provide their own stacks.

 ; NOTE: Within the program, registers are used as variables as much as
 ;       possible to speed things up.

 lea        stack(pc), a7        ; This must be the first instruction.

create_output_file:              ; COMPUTE! TOS book page 270.
 move.w     #0, -(sp)            ; File attribute = read/write.
 pea        filename(pc)
 move.w     #$3C, -(sp)          ; Function = f_create = GEMDOS $3C.
 trap       #1                   ; File handle is returned in D0.
 addq.l     #8, sp
 move.w     d0, handle

redirect_output_bound_for_screen:

 ; NOTE: If the output file's handle is exchanged with the video screen's
 ;       handle, then the printline function = GEMDOS $9 can be used to 
 ;       write to the file.

redirect_output:                 ; Exchange file handle with screen's handle.
 move.w     handle(pc), -(sp)    ; This is the disk file's handle.
 move.w     #1, -(sp)            ; This is the video screen's handle.
 move.w     #$46, -(sp)          ; Function = f_force = GEMDOS $46.
 trap       #1
 addq.l     #6, sp

initialize_register_variables:
 move.w     #$C8, d3             ; *** D3 is variable for AES call number.
 lea        aes_pb(pc), a5       ; A5 is pointer to array address block.
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
 move.w     #0, 2(a4)            ; Input no 16-bit integer parameters.
 move.w     #1, 4(a4)            ; Return one 16-bit integer parameter.
 move.w     #0, 6(a4)            ; Input no 32-bit pointer parameters.
 move.w     #0, 8(a4)            ; Return no 32-bit pointer parameters.
 bsr        aes                  ; Invoke trap #2 AES exception.

 ;
 ;          TEST POINT 1: After appl_init, before menu_register
 ;
 bsr        print_arrays

menu_installation:               ; COMPUTE! AES book page 248.

 ; Menu identification number returned in int_out[0].
             
 move.w     #$23, (a4)           ; Function = menu_register = AES $23.
 move.w     #1, 2(a4)            ; Input one 16-bit integer parameter.
 move.w     #1, 4(a4)            ; Return one 16-bit integer parameter.    
 move.w     #1, 6(a4)            ; Input one 32-bit pointer parameter.
 move.w     #0, 8(a4)            ; Return no 32-bit pointer parameters.
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
wait_for_message:                ; COMPUTE! AES book page 235.
 move.w     #$17, (a4)           ; Function = evnt_mesag = AES $17.
 move.w     #0, 2(a4)            ; Input one 16-bit integer parameter.
 move.w     #1, 4(a4)            ; Return one 16-bit integer parameter.    
 move.w     #1, 6(a4)            ; Input one 32-bit pointer parameter.
 move.w     #0, 8(a4)            ; Return no 32-bit pointer parameters.
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

 cmpi.w     #5, test             ; Have five array groups been printed?
 beq        wait_for_message     ; Disable message handler if true.
 ;
 ;          TEST POINT 3: In message handler, before evnt_mesag
 ;
 bsr        print_arrays
 cmpi.w     #5, test             ; Branch after 2nd entrance in message handler.
 beq.s      close_file         
 bra        wait_for_message     ; Execute the evnt_mesag function.

close_file:
 move.w     handle(pc), -(sp) 
 move.w     #$3E, -(sp)          ; Function = GEMDOS $3E = f_close.
 trap       #1
 addq.l     #4, sp
redirect_screen_output:
 move.w     #1, -(sp)            ; This is the screen's handle.
 move.w     handle(pc), -(sp)    ; This is the file's handle.
 move.w     #$46, -(sp)          ; Function = f_force = GEMDOS $46.
 trap       #1
 addq.l     #6, sp
 bra        wait_for_message

 ;
 ; SUBROUTINES
 ;
 
print_arrays:
 lea        newline(pc), a0       
 bsr        print_line        
 lea        test_header(pc), a0  ; Setup to fetch test point header.
 move.w     test(pc), d0         ; Load test point number into D0.
 lsl.w      #2, d0               ; Multiply by 4 to reach next pointer slot.     
 movea.l    0(a0,d0.w), a0       ; Print test point header.
 bsr        print_line
 lea        pre_spaces(pc), a0   ; Print spaces before column headers.
 bsr        print_line
 lea        aes_names(pc), a0    ; Print AES array column headers.
 bsr        print_line
 lea        pre_spaces(pc), a0   ; Print spaces before underline.
 bsr        print_line
 lea        aes_underline(pc), a0; Print AES underline.
 bsr        print_line
 moveq.l    #0, d7               ; D7 is up counter to print 5 rows.
 moveq.l    #4, d6               ; D6 is down counter to print 5 elements.
put_row:
 lea        buffer(pc), a0       ; Buffer is an 80 byte line buffer.
 movea.l    a5, a6               ; Copy aes parameter block address.
 move.w     #5, d5               ; D5 is array counter for 6 arrays.
 move.w     #11, d0              ; Print beginning spaces to line up columns.
put_space:
 move.b     #$20, (a0)+
 dbra       d0, put_space
put_element:                     ; Print contents of array element.
 move.w     d7, d0               ; Print array element number.
 andi.b     #$F, d0              ; Mask most significant nibble.
 move.b     0(a3,d0.w), d0       ; Store appropriate hex character in D0.
 move.b     d0, (a0)+
 move.b     #$3A, (a0)+          ; A colon.
 move.b     #$20, (a0)+          ; A space.
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
 move.b     d1, (a0)+
 dbra       d2, convert_digit    ; Loop until D2 = -1.
_put_spaces:
 move.b     #$20, (a0)+
 move.b     #$20, (a0)+
 dbra       d5, put_element
 move.b     #0, (a0)             ; Store NULL at end of string.
 lea        buffer(pc), a0
 bsr        print_line
 lea        newline(pc), a0      ; Print a newline.
 bsr        print_line
 addi.w     #1, d7               ; Increment up counter.
 dbra       d6, put_row
 add.w      #1, test             ; Increment test for next test point.
 rts

aes:                             ; COMPUTE! AES book page 13,
 move.l     a5, d1               ; Address of aes_pb.
 move.w     d3, d0               ; AES identifier = $C8.
 trap       #2
 rts

print_line:
 move.l     a0, -(sp)            ; Push string onto stack.
 move.w     #9, -(sp)            ; Function = c_conws.
 trap       #1
 addq.l     #6, sp
 rts
 
 data
aes_pb:       dc.l  control,global,int_in,int_out,addr_in,addr_out
test_header:  dc.l  zero,one,two,three,four
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

hex_table:    dc.b   '0123456789ABCDEF'
newline:      dc.b   $D,$A,0
aes_header:   dc.b   '                                AES ARRAYS',$D,$A,0
aes_names:    dc.b   'CONTROL  GLOBAL   INT_IN   INT_OUT  ADDR_IN  '
              dc.b   'ADDR_OUT',$D,$A,0
aes_underline:dc.b   '-------  -------  -------  -------  -------  '
              dc.b   '--------',$D,$A,0
pre_spaces:   dc.b   '            ',0
spaces:       dc.b   '  ',0
menu_text:    dc.b   '  Accessory Arrays ',0
filename:     dc.b   'E:\PRG_8\PRG_8AR.DAT',0

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

handle:       ds.w     1
test:         ds.w     1
message:      ds.l     4  ; 16 byte array.
menu_id:      ds.w     1
buffer:       ds.b    80
              ds.l   300  ; Program stack.
stack:        ds.l     0  ; Address of program stack.
 end

