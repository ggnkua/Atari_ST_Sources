;---------------------------------------------------------------------
; THE ST ASSEMBLY LANGUAGE WORKSHOP
; PROGRAM 3
;
; COPYRIGHT 1991 BY CLAYTON WALNUM
;---------------------------------------------------------------------

        text

get_number:
        move.l  #prompt,-(sp)           ; print "Type a single digit..."
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp

        move.w  #1,-(sp)                ; get a char from the console.
        trap    #1
        addq.l  #2,sp

        cmp.b   #NUM_0,d0               ; is the character less than "0"?
        blt     get_number              ; yep, go try again.
        cmp.b   #NUM_9,d0               ; is the character greater than "9"?
        bgt     get_number              ; yep, no good, so get another.

        move.b  d0,key_msg+14           ; add digit to string.
        move.b  d0,d1                   ; save contents of d0.

        move.l  #key_msg,-(sp)          ; print "You Pressed..."
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp

        subi.b  #NUM_0,d1               ; change from ASCII to int.
        add.b   d1,d1                   ; double the number.

        subi.b  #10,d1                  ; is number > 10?
        bmi     one_digit               ; no, only one digit.
        move.b  #NUM_1,add_msg+14       ; place "1" in 10s place.
        addi.b  #NUM_0,d1               ; convert remainder to ASCII.
        move.b  d1,add_msg+15           ; add final digit to string.
        bra     prnt_strg               ; go print the string.

one_digit:
        addi.b  #NUM_0+10,d1            ; convert number to ASCII.
        move.b  d1,add_msg+15           ; add number to string.

prnt_strg:
        move.l  #add_msg,-(sp)          ; print "The total is: "
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp

        move.w  #1,-(sp)                ; get a character.
        trap    #1
        addq.l  #2,sp

        move.w  #0,-(sp)                ; exit program.
        trap    #1

        data

NUM_0           equ     48
NUM_1           equ     49
NUM_9           equ     57
prompt:         dc.b    "Type a single digit number: ",0
key_msg:        dc.b    13,10,"You pressed  .",13,10,0
add_msg:        dc.b    "The total is:   .",13,10,0


