;---------------------------------------------------------------------
; THE ST ASSEMBLY-LANGUAGE WORKSHOP
; PROGRAM 2
;
; COPYRIGHT 1991 BY CLAYTON WALNUM
;---------------------------------------------------------------------
        text

get_letter:
        move.l  #prompt,-(sp)           ; put string address on stack.
        move.w  #9,-(sp)                ; function # to display string.
        trap    #1                      ; call the operating system.
        addq.l  #6,sp                   ; clean up the stack.

        move.w  #1,-(sp)                ; function # to get a character.
        trap    #1                      ; call the OS.
        addq.l  #2,sp                   ; clean up stack.

        cmp.b   #LET_A,d0               ; is the letter "A"?
        beq     do_a                    ; Yep!
        cmp.b   #LET_B,d0               ; not "A"; is it a "B"?
        beq     do_b                    ; sure is.
        cmp.b   #LET_C,d0               ; not "B"; is it a "C"?
        beq     do_c                    ; yes.
        bra     get_letter              ; invalid input; try again.
do_a:
        move.b  #LET_A,key_msg+14       ; add "A" to string.
        bra     prnt_strg               ; go print the string.

do_b:
        move.b  #LET_B,key_msg+14       ; add "B" to string.
        bra     prnt_strg               ; go print the string.

do_c:
        move.b  #LET_C,key_msg+14       ; add "C" to string.

prnt_strg:
        move.l  #key_msg,-(sp)          ; put string address on stack.
        move.w  #9,-(sp)                ; function # to display string.
        trap    #1                      ; call the operating system.
        addq.l  #6,sp                   ; clean up stack.

        move.w  #1,-(sp)                ; function # to get a character.
        trap    #1                      ; call the OS.

        move.w  #0,-(sp)                ; function # to exit program.
        trap    #1                      ; call the operating system.

        data

LET_A           equ     65
LET_B           equ     66
LET_C           equ     67
prompt:         dc.b    13,10,"Press A, B, or C: ",13,10,0
key_msg:        dc.b    13,10,"You pressed  .",13,10,0


