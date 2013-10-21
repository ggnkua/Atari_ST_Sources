;---------------------------------------------------------------------
; THE ST ASSEMBLY LANGUAGE WORKSHOP
; PROGRAM 1
;
; COPYRIGHT 1991 BY CLAYTON WALNUM
;---------------------------------------------------------------------
        text

        move.l  #string,-(sp)           ; put string address on stack.
        move.w  #9,-(sp)                ; function # to display string.
        trap    #1                      ; call the operating system.
        addq.l  #6,sp                   ; clean up the stack.

        move.w  #1,-(sp)                ; function # to wait for keypress.
        trap    #1                      ; call the operating system.

        move.w  #0,-(sp)                ; function # to exit program.
        trap    #1                      ; call the operating system.

        data

string:         dc.b    "Our first program!",13,10,0

