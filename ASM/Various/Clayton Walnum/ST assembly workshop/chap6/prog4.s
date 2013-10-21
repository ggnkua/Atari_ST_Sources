;---------------------------------------------------------------------
; THE ST ASSEMBLY LANGUAGE WORKSHOP
; PROGRAM 4
;
; COPYRIGHT 1991 BY CLAYTON WALNUM
;---------------------------------------------------------------------
        text

        move.l  #s_adr,a1               ; load table address.
        move.w  s_cnt,d1                ; load string count.
        bsr     print                   ; go print strings.

        move.w  #1,-(sp)                ; wait for keypress.
        trap    #1
        addq.l  #2,sp

        move.w  #0,-(sp)                ; back to desktop.
        trap    #1

;---------------------------------------------------------------------
; This subroutine prints a string array to the screen.
;
; Input: a1--address of string-address table.
;        d1--number of strings in table.
;
; Registers changed: None
;---------------------------------------------------------------------
print:
        movem.l a0-a1/d0-d1,-(sp)       ; save registers onto stack.
        subq.l  #1,d1                   ; convert string count for loop.
loop:
        move.l  (a1)+,-(sp)             ; print string to screen.
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp

        dbra    d1,loop                 ; branch back for next string.
        movem.l (sp)+,a0-a1/d0-d1       ; restore registers.
        rts                             ; exit subroutine.

;---------------------------------------------------------------------

        data
        even

s_cnt:  dc.w    6

s_adr:  dc.l    s1
        dc.l    s2
        dc.l    s3
        dc.l    s4
        dc.l    s5
        dc.l    s6

s1:     dc.b    13,10,"If you ever want to print a",13,10,0
s2:     dc.b    "series of strings to the screen,",13,10,0
s3:     dc.b    "you can use a table of string",13,10,0
s4:     dc.b    "addresses, and move from one",13,10,0
s5:     dc.b    "string to the next by using an",13,10,0
s6:     dc.b    "assembly language loop.",13,10,0

