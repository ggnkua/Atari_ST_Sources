;---------------------------------------------------------------------
; THE ST ASSEMBLY LANGUAGE WORKSHOP
; PROGRAM 9
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
        jsr     get_filename            ; Get source filename.
        open_file READ_ONLY,filename+2,handle ; Open source file.       
        tst.l   handle                  ; Error opening file?
        bge     read_rez                ; Nope, go read file.
        print   msg3                    ; "File open error!"
        print   msg4                    ; "Exit (y/n)?"
        jsr     get_answer
        bne     out                     ; User typed "Y".
        bra     get_source              ; Try for filename again.

read_rez:
        read_file pic_rez,2,handle      ; Read picture resolution. 
        cmp.w   #2,d0                   ; Read 2 bytes OK?
        beq     get_rez                 ; Yep.
        print   msg5                    ; "File read error!"
        print   msg4                    ; "Exit? (Y/N)"
        jsr     get_answer
        bne     out                     ; User typed "Y".
        close_file handle
        bra     get_source

get_rez:        
        move.w  #GETREZ,-(sp)           ; Get system resolution.
        trap    #14
        addq.l  #2,sp
        
        cmp.w   pic_rez,d0              ; Pic & system rez the same?
        beq     read_palette            ; Yep.
        print   msg2                    ; "Wrong resolution!"
        print   msg4                    ; "Exit? (Y/N)"
        jsr     get_answer
        bne     out
        close_file handle
        bra     get_source
        
read_palette:
        read_file new_palette,32,handle ; Read picture palette.
        cmp.w   #32,d0                  ; Got all 32 bytes?
        beq     set_boundary            ; Sure did.
        print   msg5                    ; "File read error!"
        print   msg4                    ; "Exit? (Y/N)"
        jsr     get_answer
        bne     out
        close_file handle
        bra     get_source

set_boundary:
        move.l  #buffer,d0              ; Get address of buffer.
        andi.l  #$ffffff00,d0           ; Set buffer address...
        addi.l  #256,d0                 ; to 256-byte boundary.
        move.l  d0,a3                   ; Save recalculated address.
        
read_pic:
        read_file (a3),32000,handle     ; Read picture data.
        cmp.w   #32000,d0               ; Got 32,000 bytes?
        beq     show_pic                ; Yes.
        print   msg5                    ; "File read error!"
        print   msg4                    ; "Exit? (Y/N)"
        jsr     get_answer
        bne     out
        close_file handle
        bra     get_source

show_pic:
        move.w  #PHYSBASE,-(sp)         ; Get addr of screen mem.
        trap    #14
        addq.l  #2,sp
        move.l  d0,a4                   ; Save screen address.

        move.l  #old_palette,a6         ; Get addr of buffer.
        move.l  #15,d3                  ; Init loop counter.
        move.l  #30,d4                  ; Init address index.
color_loop:
        move.w  #-1,-(sp)               ; Get value of color reg.
        move.w  d3,-(sp)
        move.w  #SETCOLOR,-(sp)
        trap    #14
        addq.l  #6,sp

        move.w  d0,0(a6,d4)             ; Save color value in buffer.
        subi.w  #2,d4                   ; Calculate next addr index.
        dbra    d3,color_loop           ; Loop for next color value.
        
        move.l  #new_palette,-(sp)      ; Set to picture colors.
        move.w  #SETPALETTE,-(sp)
        trap    #14
        addq.l  #6,sp

        move.w  #-1,-(sp)               ; Set screen to picture.
        move.l  a3,-(sp)
        move.l  a3,-(sp)
        move.w  #SETSCREEN,-(sp)
        trap    #14
        add.l   #12,sp
        
        get_char
        
        move.w  #-1,-(sp)               ; Set back to old screen.
        move.l  a4,-(sp)
        move.l  a4,-(sp)
        move.w  #SETSCREEN,-(sp)
        trap    #14
        add.l   #12,sp

        move.l  #old_palette,-(sp)      ; Restore old palette.
        move.w  #SETPALETTE,-(sp)
        trap    #14
        addq.l  #6,sp

out:
        close_file handle               ; close picture file.
        move.w  #PTERM0,-(sp)           ; Back to desktop.
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
; Output:       Null-terminated filename in filename.
; Regs changed: NONE.
; Calls:        print, input_s, add_null
; Data used:    msg1, filename, crlf
;--------------------------------------------------------------------
get_filename:
        print   msg1                            ; "Enter name of file..."
        input_s filename,64                     ; get filename
        print   crlf
        move.l  #filename,a3                    ; add a null to...
        jsr     add_null                        ; the filename.
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
PHYSBASE        equ     2
GETREZ          equ     4
SETSCREEN       equ     5
SETPALETTE      equ     6
SETCOLOR        equ     7
CCONWS          equ     9
CCONRS          equ     10
FOPEN           equ     61
FCLOSE          equ     62
FREAD           equ     63

msg1:   dc.b    "Enter name of DEGAS file: ",0
msg2:   dc.b    "Wrong resolution!",13,10,0
msg3:   dc.b    "File open error!",13,10,0
msg4:   dc.b    "Exit (y/n)?",0
msg5:   dc.b    "File read error!",13,10,0
crlf:   dc.b    13,10,0

        bss

        even
handle:         ds.w    1
filename:       ds.b    67
pic_rez:        ds.w    1
new_palette:    ds.w    16
old_palette:    ds.w    16
buffer:         ds.b    32256
