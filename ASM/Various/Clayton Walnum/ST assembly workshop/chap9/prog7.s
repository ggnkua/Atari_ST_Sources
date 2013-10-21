;---------------------------------------------------------------------
; THE ST ASSEMBLY LANGUAGE WORKSHOP
; PROGRAM 7
;
; COPYRIGHT 1991 BY CLAYTON WALNUM
;---------------------------------------------------------------------

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
get_filename:
        print   msg1                    ; "Enter name of file..."
        input_s filename,64             ; get filename
        print   crlf
        move.l  #filename,a3            ; add a null to...
        jsr     add_null                ; the filename.
        
        move.w  #READ_ONLY,-(sp)        ; open the requested...
        move.l  #filename+2,-(sp)       ; file for read-only...
        move.w  #FOPEN,-(sp)            ; access.
        trap    #1
        addq.l  #8,sp
        
        tst.l   d0                      ; error opening file?
        bge     read_file               ; nope, go read file.
                                        ; yep, we got an error.
        print   msg2                    ; "File open error!"
        print   msg3                    ; "Exit (y/n)?"
        get_char                        ; get user's answer.
        move.l  d0,d3                   ; save character typed.
        print   crlf                    ; next screen line.
        cmp.w   #UC_Y,d3                ; user typed "Y"?
        beq     out                     ; yep, we're outta here.
        cmp.w   #LC_Y,d3                ; user typed "y"?
        beq     out                     ; sure did.
        bra     get_filename            ; try for filename again.

read_file:
        move.w  d0,handle               ; save file handle.

check_printer:
        move.w  #CPRNOS,-(sp)           ; check printer's status.
        trap    #1
        addq.l  #2,sp
        
        tst     d0                      ; is printer ready?
        bmi     printer_ready           ; yep, go print.
                                        ; no, printer didn't respond.
        print   msg5                    ; "Printer not responding!"
        print   msg6                    ; "Want to try again?"
        get_char                        ; get user's answer.
        move.l  d0,d3                   ; save answer.
        print   crlf                    ; got to next screen line.
        cmp.w   #UC_Y,d3                ; check character typed...
        beq     check_printer;          ; and go back for...
        cmp.w   #LC_Y,d3                ; another try if user...
        beq     check_printer           ; typed "Y" or "y".
        bra     close_file              ; else, exit program.
        
printer_ready:
        move.l  #buffer,-(sp)           ; get address of buffer.
        move.l  #256,-(sp)              ; # of bytes to read.
        move.w  handle,-(sp)            ; file handle.
        move.w  #FREAD,-(sp)            ; function #.
        trap    #1                      ; read from file.
        add.l   #12,sp                  ; fix stack.

        tst.l   d0                      ; did we read anything?
        bgt     print_buffer            ; yep, go print it.
        beq     eof                     ; no, reached eof, or...
                                        ; got an error.
        print   msg4                    ; "File read error!"
        get_char                        ; wait for user to...
        bra     close_file              ; press key, then exit.

print_buffer:
        move.l  d0,d5                   ; save read count.
        move.l  #buffer,a3              ; get address of buffer.
        clr.l   d3                      ; init char storage.
        clr.w   d4                      ; init loop counter.
        
next_char:
        move.b  0(a3,d3),d4             ; move char to register...
        move.w  d4,-(sp)                ; then to stack as word.
        move.w  #CPRNOUT,-(sp)          ; function #.
        trap    #1                      ; send char to printer.
        addq.l  #4,sp                   ; correct stack.

        tst     d0                      ; was there an error?
        beq     timeout                 ; yep.
        addq.l  #1,d3                   ; no. increment count.
        cmp.l   d3,d5                   ; last character?
        beq     printer_ready           ; yes. go refill buffer.
        bra     next_char               ; no. go print next char.
        
timeout:                                ; handle printer time out.
        print   msg7                    ; "Printer timed out."
        print   msg6                    ; "Want to try again?" 
        get_char                        ; give the user...
        move.l  d0,d3                   ; a chance to fix...
        print   crlf                    ; the problem...
        cmp.w   #UC_Y,d3                ; and try again.
        beq     next_char
        cmp.w   #LC_Y,d3
        beq     next_char               ; go try again to print.
        bra     close_file              ; or exit the program.
eof:
        print   msg8                    ; "All done."
close_file:
        move    handle,-(sp)            ; close file
        move    #FCLOSE,-(sp)
        trap    #1
        addq.l  #4,sp
        
        print   msg9                    ; "Press any key"
        get_char                        ; wait for keypress.
        
out:
        move.w  #PTERM0,-(sp)           ; adios.
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
FOPEN           equ     61
FCLOSE          equ     62
FREAD           equ     63

msg1:   dc.b    "Enter name of file to print: ",0
msg2:   dc.b    "File open error!",13,10,0
msg3:   dc.b    "Exit (y/n)?",0
msg4:   dc.b    "File read error!",13,10,0
msg5:   dc.b    "Printer not responding!",13,10,0
msg6:   dc.b    "Want to try again (y/n)? ",0
msg7:   dc.b    "Printer timed out.",13,130,0
msg8:   dc.b    "All Done.",13,10,0
msg9:   dc.b    "Press any key:",13,10,0
crlf:   dc.b    13,10,0

        bss

        even
handle:         ds.w    1
filename:       ds.b    67
buffer:         ds.b    256
