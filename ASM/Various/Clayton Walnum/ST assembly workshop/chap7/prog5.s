;---------------------------------------------------------------------
; THE ST ASSEMBLY LANGUAGE WORKSHOP
; PROGRAM 5
;
; COPYRIGHT 1991 BY CLAYTON WALNUM
;---------------------------------------------------------------------
        text
        move.l  #100,d3                 ; get random # from 0 to 99.
        jsr     rand
        addq.l  #1,d0                   ; convert range to 1 to 100.
        move.l  d0,d2                   ; save random number.

        clr.l   d4                      ; init turn counter.
                        
get_number:
        addq.w  #1,d4                   ; increment counter.
        cmpi.l  #7,d4                   ; game over?
        beq     loser                   ; yep.
        move.l  #buffer,a1              ; get address of buffer.
        move.w  #6,d1                   ; init loop counter.
clr_str:
        move.b  #0,(a1)+                ; zero out buffer.
        dbra    d1,clr_str

        move.l  #prompt,-(sp)           ; print "Guess a number..."
        move.w  #CCONWS,-(sp)
        trap    #1
        addq.l  #6,sp

        move.b  #3,buffer               ; init character count.
        move.l  #buffer,-(sp)           ; get string from keyboard.
        move.w  #CCONRS,-(sp)
        trap    #1
        addq.l  #6,sp

        move.l  #buffer+2,a3            ; address of first char in buffer.
        jsr     ascii2int16             ; convert to integer.

        cmpi.l  #-1,d0
        bne     no_error

        move.l  #msg1,-(sp)             ; print "Did not type number."
        move.w  #CCONWS,-(sp)
        trap    #1
        addq.l  #6,sp
        bra     get_number              ; go get another number.

no_error:
        cmp.w   d2,d0                   ; was the number guessed?
        beq     guessed                 ; yes.
        bgt     too_high                ; nope, number was too low.

        move.l  #msg2,-(sp)             ; "Too low."
        bra     prnt_str                ; go print the string.
too_high:
        move.l  #msg3,-(sp)             ; "Too high."
prnt_str:
        move.w  #CCONWS,-(sp)           ; print string.
        trap    #1
        addq.l  #6,sp
        bra     get_number              ; go get another number.
        
guessed:                
        move.l  #msg4,-(sp)             ; print "You guessed it!"
        move.w  #CCONWS,-(sp)
        trap    #1
        addq.l  #6,sp
        bra     out
        
loser:
        move.l  #msg5,-(sp)             ; print "Too many guesses..."
        move.w  #CCONWS,-(sp)
        trap    #1
        addq.l  #6,sp
        
        move.l  d2,d0                   ; move random # to d0.
        move.l  #buffer,a3              ; get address of string buffer.
        jsr     int2ascii16             ; convert # to string.
        
        move.l  #buffer,-(sp)           ; print correct number.
        move.w  #CCONWS,-(sp)
        trap    #1
        addq.l  #6,sp
        
out:
        move.w  #CCONIN,-(sp)           ; wait for keypress.
        trap    #1
        addq.l  #2,sp
                                
        move.w  #PTERM0,-(sp)           ; back to desktop.
        trap    #1

;--------------------------------------------------------------------
; This subroutine returns a 16-bit random number from 0 to n-1.
;
; Input: High number+1 (n) of range in d3. (A value of 10 yields a
;        random number from 0 to 9.)
; Output: d0 will contain 16-bit random number in the requested
;         range.
; Registers changed: d0.
;--------------------------------------------------------------------
rand:
        movem.l a0-a7/d1-d7,-(sp)       ; save registers.
        move.w  #RANDOM,-(sp)           ; get 24-bit random number.
        trap    #14
        addq.l  #2,sp
        andi.l  #$0000FFFF,d0           ; clear high word.
        divu    d3,d0                   ; convert to requested range.
        andi.l  #$FFFF0000,d0           ; clear the quotient.
        swap    d0                      ; place the remainder in low word.
        movem.l (sp)+,a0-a7/d1-d7       ; restore registers.
        rts
        
;--------------------------------------------------------------------
; This subroutine converts a 16-bit unsigned integer into a 
; null-terminated string.
;
; Input: Address of buffer in a3.
;        Integer to convert in d0.
; Output: The buffer will contain the resultant null-terminated string.
; Registers changed: NONE.
;--------------------------------------------------------------------
int2ascii16:
        movem.l a0-a7/d0-d7,-(sp)       ; save registers.
        clr.l   d3                      ; init leading-zero flag.
        move.l  #10000,d1               ; init divisor.
.convrt:
        divu    d1,d0                   ; calculate place value.
        cmpi.l  #1,d1                   ; are we at the one's place?
        beq     .zero_ok                ; if so, "0" always ok.
        tst.w   d3                      ; already have a non-zero char?
        bne     .zero_ok                ; yes, so zeroes okay.
        tst.w   d0                      ; is result zero?
        beq     .next_digit             ; yes.
        moveq   #1,d3                   ; set leading-zero flag.
.zero_ok:
        move.b  d0,(a3)                 ; move result to buffer.
        add.b   #ZERO,(a3)+             ; change digit to ascii.
.next_digit:
        divu    #10,d1                  ; calculate next divisor.
        tst.w   d1                      ; are we done yet?
        beq     .add_null               ; sure are.
        move.w  #0,d0                   ; clear result from low word.
        swap    d0                      ; put remainder in low word.
        bra     .convrt                 ; convert next digit.
.add_null:
        move.b  #0,(a3)+                ; add null to string.
        movem.l (sp)+,a0-a7/d0-d7       ; restore registers.
        rts
end_int2ascii16:

;---------------------------------------------------------------------
; This subroutine converts a string of ascii digits into a 16-bit
; unsigned integer.
;
; Input: Address of 0-terminated string in a3.
; Output: 16-bit integer in d0. A return of -1 signifies an error.
; Registers changed: d0.
;---------------------------------------------------------------------
ascii2int16:
        movem.l a0-a7/d1-d7,-(sp)

        clr.l   d0                      ; clear accumulator
        clr.l   d3                      ; clear work reg.
.cnvt_digit:
        cmp.b   #ZERO,(a3)              ; char < "0"
        blt     .digit_error            ; yep. error.
        cmp.b   #NINE,(a3)              ; char > "9"
        bgt     .digit_error            ; yep.  error.
        move.b  (a3)+,d3                ; get digit.
        sub.w   #ZERO,d3                ; convert to integer.
        add.l   d3,d0                   ; add to accumulator.
        tst.b   (a3)                    ; end of string?
        beq     .out                    ; yep.
        mulu    #10,d0                  ; nope.
        bra     .cnvt_digit             ; go do next digit.

.digit_error:
        move.l  #-1,d0                  ; set error condition.
.out:
        movem.l (sp)+,a0-a7/d1-d7       ; restore registers.
        rts
end_ascii2int16:

;---------------------------------------------------------------------

        data

ZERO    equ     48
NINE    equ     57
RANDOM  equ     17
PTERM0  equ     0
CCONIN  equ     1
CCONWS  equ     9
CCONRS  equ     10

prompt: dc.b    13,10,"Guess a number from 1 to 100:",13,10,0
msg1:   dc.b    13,10,"You did not type a number. "
        dc.b    "Please try again.",13,10,0
msg2:   dc.b    13,10,"Too low.",13,10,0
msg3:   dc.b    13,10,"Too high.",13,10,0
msg4:   dc.b    13,10,"You got it!",13,10,0
msg5:   dc.b    13,10,"Too many guesses.  The number was: ",0

        bss

buffer: ds.b    10
