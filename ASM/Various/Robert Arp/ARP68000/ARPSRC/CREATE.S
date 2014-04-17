 ; Program Name: CREATE.S
 ;      Version: 1.001

 ; Assembly Instructions:

 ;    Assemble in PC-relative mode and save with a TOS suffix.

 ; Execution Instructions:

 ;    This program is spawned by PRG_8BR.ACC.  Both programs must reside in
 ; the same directory.

 ; Function:

 ;    This program creates disk file E:\PRG_8\PRG_8BR.DAT and stores therein
 ; the data contained in PRG_8BR.ACC's buffer.  The purpose of this exercise
 ; is to illustrate an elegant method of creating a disk file for a desk
 ; accessory, writing data to the file and invoking proper file closure.

fetch_command_line_address:
 lea        -$82(pc), a3

 ; The data in the command line is a string of eight ASCII hexadecimal digits
 ; passed from PRG_8CR.ACC when that program spawned this one.  There are no
 ; characters before that string and none following.  The string is the address
 ; of PRG_8CR.ACC's buffer, in which data that is to be written to a disk file
 ; has been stored.  The address must be converted from an ASCII hexadecimal
 ; string to a binary longword.

process_command_line:            ; Convert ASCII hexadecimal string to binary.
 moveq.l    #0, d0               ; Accumulator.
 moveq.l    #7, d2               ; Loop counter.
convert_string:
 move.b     (a3)+, d1            ; D1 is used for each character conversion.
 cmpi.b     #$39, d1             ; Character greater than 9 test.
 bgt        not_decimal
 cmpi.b     #$30, d1             ; Character less than 0 test.
 blt        not_valid
 subi.b     #$30, d1             ; Convert ASCII hex character to binary.
 bra.s      accumulate
not_decimal:
 cmpi.b     #$41, d1             ; Character less than A test.
 blt        not_valid
 cmpi.b     #$46, d1             ; Character greater than F test.
 bgt        not_valid
 subi.b     #$37, d1             ; Convert ASCII hex character to binary.
accumulate:
 lsl.l      #4, d0               ; Shift one nibble = one hex character.
 add.b      d1, d0
 dbra       d2, convert_string
 move.l     d0, a3               ; Address of buffer is in D0.
 movea.l    a3, a0               ; Copy for buffer byte count.

count_bytes_in_buffer:
 moveq.l    #0, d0               ; NULL byte test register.
 moveq.l    #0, d3               ; Byte count accumulator.
count:
 move.b     (a0)+, d0            ; Look at each character in buffer and
 beq        create_file          ; accumulate count until NULL is found at
 addq.l     #1, d3               ; end of buffer.
 bra.s      count

create_file:                     ; COMPUTE! TOS book page 270.
 move.w     #0, -(sp)            ; File attribute = read/write.
 pea        filename(pc)
 move.w     #$3C, -(sp)          ; Function = f_create = GEMDOS $3C.
 trap       #1                   ; File handle is returned in D0.
 addq.l     #8, sp
 move.w     d0, d4               ; Save file handle in D4.

write_buffer_to_file:            ; Function = f_write.  COMPUTE! TOS p.274.
 pea        (a3)                 ; Push buffer's address.
 move.l     d3, -(sp)            ; Push byte count length.
 move.w     d4, -(sp)            ; COMPUTE!'s TOS book incorrectly specifies
 move.w     #$40, -(sp)          ; a longword operation here; see page 274.
 trap       #1
 lea        $C(sp), sp

close_output_file:               ; COMPUTE! TOS book page 272.
 move.w     d4, -(sp)            ; Push file handle. 
 move.w     #$3E, -(sp)          ; Function = GEMDOS $3E = f_close.
 trap       #1
 addq.l     #4, sp

not_valid:
terminate:
 move.w     #0, -(sp)
 trap       #1

 data
filename:     dc.b  'E:\PRG_8\PRG_8BR.DAT',0
 align
 bss
program_end:  ds.l  0
 end
