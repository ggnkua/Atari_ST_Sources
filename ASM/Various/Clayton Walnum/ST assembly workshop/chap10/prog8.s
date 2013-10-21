;---------------------------------------------------------------------
; THE ST ASSEMBLY LANGUAGE WORKSHOP
; PROGRAM 8
;
; COPYRIGHT 1991 BY CLAYTON WALNUM
;---------------------------------------------------------------------

;--------------------------------------------------------------------
; This macro opens a file using the unbuffered, Fopen GEMDOS
; function. It requires three parameters: the file mode, the address
; of the filename, and the address for file-handle storage.
;--------------------------------------------------------------------
open_file macro
        ifc     '','\3'
        fail    Missing parameters!
        mexit
        endc
        move.w  #\1,-(sp)
        pea     \2
        move.w  #FOPEN,-(sp)
        trap    #1
        addq.l  #8,sp
        move.w  d0,\3
        endm

;--------------------------------------------------------------------
; This macro creates a file using the unbuffered, Fcreate GEMDOS
; function. It requires three parameters: the file attribute, the 
; address of the filename, and the address for file-handle storage.
;--------------------------------------------------------------------
create_file macro
        ifc     '','\3'
        fail    Missing parameters!
        mexit
        endc
        move.w  #\1,-(sp)
        pea     \2
        move.w  #FCREATE,-(sp)
        trap    #1
        addq.l  #8,sp
        move.w  d0,\3
        endm

;--------------------------------------------------------------------
; This macro reads a file using the unbuffered, Fread GEMDOS
; function. It requires three parameters: the buffer address,
; the number of bytes to read, and the file handle.
;--------------------------------------------------------------------
read_file macro
        ifc     '','\3'
        fail    Missing parameters!
        mexit
        endc
        pea     \1
        move.l  #\2,-(sp)
        move.w  \3,-(sp)
        move.w  #FREAD,-(sp)
        trap    #1
        add.l   #12,sp
        endm
        
;--------------------------------------------------------------------
; This macro writes to a file using the unbuffered, Fwrite GEMDOS
; function. It requires three parameters: the buffer address,
; the address of the number of bytes to write, and the file handle.
;--------------------------------------------------------------------
write_file macro
        ifc     '','\3'
        fail    Missing parameters!
        mexit
        endc
        pea     \1
        move.l  \2,-(sp)
        move.w  \3,-(sp)
        move.w  #FWRITE,-(sp)
        trap    #1
        add.l   #12,sp
        endm
        
;--------------------------------------------------------------------
; This macro closes a file using the unbuffered, Fclose GEMDOS
; function. It requires one parameter: the file handle.
;--------------------------------------------------------------------
close_file macro
        ifc     '','\1'
        fail    Missing parameter!
        mexit
        endc
        move.w  \1,-(sp)
        move.w  #FCLOSE,-(sp)
        trap    #1
        addq.l  #4,sp
        endm

;--------------------------------------------------------------------
; This macro prints a string to the screen, using the Cconws GEMDOS
; function. It requires one parameter, the address of the string
; to print.
;--------------------------------------------------------------------
print   macro
        ifc     '','\1'
        fail    Missing parameter!
        mexit
        endc
        move.l  #\1,-(sp)
        move.w  #CCONWS,-(sp)
        trap    #1
        addq.l  #6,sp
        endm

;--------------------------------------------------------------------
; This macro gets a string from the keyboard using the Cconrs GEMDOS
; function. It requires two parameters: the address of the buffer
; in which to store the string and the max number of characters
; to read.
;--------------------------------------------------------------------
input_s macro
        ifc     '','\2'
        fail    Missing parameters!
        mexit
        endc
        move.b  #\2,\1
        move.l  #\1,-(sp)
        move.w  #CCONRS,-(sp)
        trap    #1
        addq.l  #6,sp
        endm

;--------------------------------------------------------------------
; This macro gets a single character from the keyboard, using the
; Cconin GEMDOS function.
;--------------------------------------------------------------------
get_char        macro
        move.w  #CCONIN,-(sp)
        trap    #1
        addq.l  #2,sp
        endm

;--------------------------------------------------------------------
; MAIN PROGRAM
;--------------------------------------------------------------------
        text
get_source:
        jsr     get_filename1                   ; get source filename.
        open_file READ_ONLY,filename1+2,handle1 ; open source file.
        
        tst.l   handle1                         ; error opening file?
        bge     get_dest                        ; nope, go read file.

        print   msg3                            ; "File open error!"
        print   msg4                            ; "Exit (y/n)?"
        jsr     get_answer
        bne     out                             ; User typed "Y".
        bra     get_source                      ; try for filename again.

get_dest:
        jsr     get_filename2                   ; get destination file.
        open_file READ_ONLY,filename2+2,handle2 ; open destination file.
        tst     handle2                         ; does file already exist?
        bmi     make_file                       ; nope, okay to create it.
        print   msg6                            ; "File already exists!"
        print   msg7                            ; "Delete it?"
        jsr     get_answer
        beq     get_dest                        ; try for filename again.
        
make_file:
        create_file 0,filename2+2,handle2       ; create new file.
        tst     handle2                         ; Error?
        bge     copy                            ; Nope, go copy file.
        print   msg8                            ; "Error creating file."
        print   msg9                            ; "Program aborting."
        get_char                                ; wait for keypress.
        close_file handle1                      ; close file.
        bra     out                             ; skidaddle.

copy:
        read_file buffer,1024,handle1           ; read source file.
        tst.l   d0                              ; did we read anything?
        bgt     write_buffer                    ; yep, go write it out.
        beq     eof                             ; nothing read, so eof.
        
        print   msg5                            ; "File read error!"
        print   msg9                            ; "Program aborting."
        get_char                                ; wait for keypress.
        bra     out                             ; abort.
        
write_buffer:
        write_file buffer,d0,handle2            ; write buffer to dest. file.
        bra     copy                            ; read next bufferful.

eof:
        print   msg10                           ; "All done."
        get_char                                ; wait for keypress.

out:
        close_file handle1                      ; close source file.
        close_file handle2                      ; close destination file.
        move.w  #PTERM0,-(sp)                   ; adios.
        trap    #1

;--------------------------------------------------------------------
; This subroutine adds a null to the string retrieved with a call
; to the GEMDOS function Cconrs.
;
; Input: Address of string buffer in a3.
; Output: Null after last character in string.
; Registers changed: NONE.
;--------------------------------------------------------------------
add_null:
        movem.l a3/d3,-(sp)
        clr.l   d3
        move.b  1(a3),d3
        move.b  #0,2(a3,d3)
        movem.l (sp)+,a3/d3
        rts

;--------------------------------------------------------------------
; This subroutine retrieves the name of the source file.
;
; Input:        NONE.
; Output:       Null-terminated filename in filename1.
; Regs changed: NONE.
; Calls:        print, input_s, add_null
; Data used:    msg1, filename1, crlf
;--------------------------------------------------------------------
get_filename1:
        print   msg1                            ; "Enter name of file..."
        input_s filename1,64                    ; get filename
        print   crlf
        move.l  #filename1,a3                   ; add a null to...
        jsr     add_null                        ; the filename.
        rts

;--------------------------------------------------------------------
; This subroutine retrieves the name of the destination file.
;
; Input:        NONE.
; Output:       Null-terminated filename in filename2.
; Regs changed: NONE.
; Calls:        print, input_s, add_null
; Data used:    msg1, filename1, crlf
;--------------------------------------------------------------------
get_filename2:
        print   msg2                            ; "Enter new filename:"
        input_s filename2,64
        print   crlf
        move.l  #filename2,a3
        jsr     add_null
        rts

;--------------------------------------------------------------------
; This subroutine retrieves a one-character response from the
; keyboard and compares it against Y and N.
;
; Input:        NONE.
; Output:       1->D0 if Y typed. 0->D0 if any other key typed.
; Regs changed: D0.
; Calls:        get_char
; Data used:    UC_Y, LC_Y
;--------------------------------------------------------------------
get_answer:
        get_char                                ; get user's answer.
        move.l  d0,d3
        print   crlf
        cmp.w   #UC_Y,d3                        ; user typed "Y"?
        beq     .yes                            ; yep.
        cmp.w   #LC_Y,d3                        ; user typed "y"?
        beq     .yes                            ; yep.
        clr.l   D0
        bra     .out
.yes:
        moveq.l #1,D0
.out:
        rts
end_get_answer:

        
;---------------------------------------------------------------------

        data

READ_ONLY       equ     0
UC_Y            equ     89
LC_Y            equ     121

PTERM0          equ     0
CCONIN          equ     1
CPRNOUT         equ     5
CCONWS          equ     9
CCONRS          equ     10
CPRNOS          equ     17
FCREATE         equ     60
FOPEN           equ     61
FCLOSE          equ     62
FREAD           equ     63
FWRITE          equ     64

msg1:   dc.b    "Enter name of file to copy: ",0
msg2:   dc.b    "Enter new filename: ",0
msg3:   dc.b    "File open error!",13,10,0
msg4:   dc.b    "Exit (y/n)?",0
msg5:   dc.b    "File read error!",13,10,0
msg6:   dc.b    "File already exists!",13,10,0
msg7:   dc.b    "Delete it (y/n)? ",0
msg8:   dc.b    "Error creating file.",13,10,0
msg9:   dc.b    "Program aborting.",13,10,0
msg10:  dc.b    "All Done.",13,10,0
crlf:   dc.b    13,10,0

        bss

        even
handle1:        ds.w    1
handle2:        ds.w    1
filename1:      ds.b    67
filename2:      ds.b    67
buffer:         ds.b    1024
