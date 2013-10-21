;---------------------------------------------------------------------
; THE ST ASSEMBLY LANGUAGE WORKSHOP
; PROGRAM 6
;
; COPYRIGHT 1991 BY CLAYTON WALNUM
;---------------------------------------------------------------------

;--------------------------------------------------------------------
; This macro prints a string to the screen, using the Cconws GEMDOS
; function. It requires one parameter, the address of the string
; to print.
;--------------------------------------------------------------------
print   macro
        move.l  #\1,-(sp)
        move.w  #CCONWS,-(sp)
        trap    #1
        addq.l  #6,sp
        endm

;--------------------------------------------------------------------
; MAIN PROGRAM
;--------------------------------------------------------------------
        text
        jsr     get_date                ; get system date.

        print   msg1                    ; "The current date is..."
        subi.l  #1,d2                   ; calculate offset of string.
        mulu    #4,d2                   ; convert to long word count.
        move.l  #months,a0              ; get address of first string.
        move.l  0(a0,d2),-(sp)          ; print current month string.
        move.w  #CCONWS,-(sp)
        trap    #1
        addq.l  #6,sp
        
        move.l  #buffer,a3              ; convert day to string.
        move.l  d1,d0
        jsr     int2ascii16

        move.l  #buffer,a0              ; get address of string...
find_null:
        cmp.b   #0,(a0)+                ; and look for end.
        bne     find_null
        move.b  #COMMA,-(a0)            ; add comma to string.
        move.b  #SPACE,1(a0)            ; add space to string.
        move.b  #0,2(a0)                ; add null to string.
        
        print   buffer                  ; print day string.

        move.l  d3,d0                   ; convert year to string.
        jsr     int2ascii16
        
        print   buffer                  ; print year string.
        print   crlf                    ; move to next line.
        print   msg2                    ; "Would you like to change it?"

        move.w  #CCONIN,-(sp)           ; get answer from user.
        trap    #1
        addq.l  #2,sp
        move.l  d0,d3
        print   crlf                    ; go to new line.
        
        cmp.w   #UC_Y,d3                ; is answer "Y"?
        beq     change_date             ; yep, go change date.
        cmp.w   #LC_Y,d3                ; is answer "y"?
        bne     time                    ; no, go do time.

change_date:
        print   msg3                    ; "Enter new date..."
        move.b  #9,buffer               ; number of chars to input.
        move.l  #buffer,-(sp)           ; get date string from user.
        move.w  #CCONRS,-(sp)
        trap    #1
        addq.l  #6,sp
        print   crlf

        clr.l   d3                      ; init register for date.
        move.b  buffer+8,buf2           ; get first digit of year.
        move.b  buffer+9,buf2+1         ; get second digit of year.
        move.b  #0,buf2+2               ; add null.
        move.l  #buf2,a3                ; get address of string.
        bsr     ascii2int16             ; convert year to integer.
        cmpi.w  #-1,d0                  ; did number convert ok?
        beq     date_no_good            ; nope, generate error.
        cmpi.l  #91,d0                  ; if year < 91, then...
        blt     year_2000               ; assume it's 21st century.
        subi.l  #80,d0                  ; convert to GEMDOS year format.
        bra     store_year
year_2000:
        addi.l  #20,d0                  ; convert to GEMDOS year format.
store_year:
        move.l  d0,d3                   ; store year and...
        lsl.l   #8,d3                   ; shift it to...
        lsl.l   #1,d3                   ; its correct position.

        move.b  buffer+2,buf2           ; get first digit of month.
        move.b  buffer+3,buf2+1         ; get second digit of month.
        bsr     ascii2int16             ; convert month to integer.
        cmpi.w  #1,d0                   ; if value < 1, the month...
        blt     date_no_good            ; is invalid.
        cmpi.w  #12,d0                  ; and if value > 12 the...
        bgt     date_no_good            ; month is invalid.
        lsl.l   #5,d0                   ; shift month to correct position.
        or.l    d0,d3                   ; add month to date.

        move.b  buffer+5,buf2           ; get first digit of day.
        move.b  buffer+6,buf2+1         ; get the second digit of day.
        bsr     ascii2int16             ; convert day to integer.
        cmpi.w  #1,d0                   ; The day value can't...
        blt     date_no_good            ; be less than 1 or...
        cmpi.w  #31,d0                  ; greater than 31.
        bgt     date_no_good
        or.l    d0,d3                   ; add day to date.
        
        move.w  d3,-(sp)                ; move date onto stack.
        move.w  #TSETDATE,-(sp)         ; GEMDOS function #.
        trap    #1
        addq.l  #4,sp
        print   msg5                    ; "New date set."
        bra     time
        
date_no_good:
        print   msg4                    ; "Not a valid date!"
        bra     change_date
        
time:
        jsr     get_time
        
        print   msg6                    ; "The system time is..."
        move.l  #buffer,a3              ; get address of string buffer.
        move.l  d3,d0                   ; change integer hours...
        jsr     int2ascii16             ; to ascii string.

        move.l  #buffer,a0              ; get address of hour string.
        move.l  #-1,d4                  ; init character count.
find_null2:
        addq.l  #1,d4                   ; increment character count.
        cmpi.b  #0,(a0)+                ; found null yet?
        bne     find_null2              ; nope.

        move.l  #buffer,a0              ; reset pointer to string.
        cmpi.l  #1,d4                   ; only one character?
        bne     no_leading_zero         ; nope, don't need the "0".
        move.b  (a0),1(a0)              ; move character over.
        move.b  #ZERO,(a0)              ; add "0".
no_leading_zero:        
        move.b  #COLON,2(a0)            ; add ":" to string.
        move.l  #buffer+3,a3            ; addr of minutes part of string.
        move.l  d2,d0                   ; convert the integer...
        jsr     int2ascii16             ; minutes to ascii string.
        move.l  #buffer+3,a0            ; adr of start of minutes.
        move.l  #-1,d4                  ; init character count.
find_null3:
        addq.l  #1,d4                   ; increment character count.
        cmpi.b  #0,(a0)+                ; found null yet?
        bne     find_null3              ; no.
        move.l  #buffer+3,a0            ; reset pointer.
        cmpi.l  #1,d4                   ; only one character?
        bne     no_leading_zero2        ; no, don't need "0".
        move.b  (a0),1(a0)              ; move character over.
        move.b  #ZERO,(a0)              ; add "0".
no_leading_zero2:
        move.b  #0,2(a0)                ; add null.
        print   buffer
        print   crlf
        
        print   msg2                    ; "Would you like to change..."
        move.w  #CCONIN,-(sp)           ; get answer from user.
        trap    #1
        addq.l  #2,sp
        move.l  d0,d3                   ; save keystroke.
        print   crlf                    ; go to new line.
                
        cmpi.w  #UC_Y,d3                ; is answer "Y"?
        beq     change_time             ; yep, go change time.
        cmpi.w  #LC_Y,d3                ; is answer "y"?
        bne     out                     ; no, leave program.

change_time:
        print   msg7                    ; "Enter new time..."
        move.b  #6,buffer               ; set # of chars to input.
        move.l  #buffer,-(sp)           ; get date from user.
        move.w  #CCONRS,-(sp)
        trap    #1
        addq.l  #6,sp
        print   crlf

        clr.l   d3                      ; clear register for new time.
        move.b  buffer+2,buf2           ; move first char of hour.
        move.b  buffer+3,buf2+1         ; move second char of hour.
        move.b  #0,buf2+2               ; add null to hour string.
        move.l  #buf2,a3                ; get addr of hour string.
        jsr     ascii2int16             ; convert to integer.
        cmpi.w  #0,d0                   ; if value < 0...
        blt     time_no_good            ; hour value is invalid.
        cmpi.w  #23,d0                  ; if value > 23...
        bgt     time_no_good            ; hour value no good.
        lsl.l   #8,d0                   ; shift hours into place.
        lsl.l   #3,d0
        move.l  d0,d3                   ; add hours to new time.
        
        move.b  buffer+5,buf2           ; move first char of minutes.
        move.b  buffer+6,buf2+1         ; move second char of minutes.
        jsr     ascii2int16             ; convert minutes to integer.
        cmpi.w  #0,d0                   ; minutes value can't...
        blt     time_no_good            ; less than 0. nor...
        cmpi.w  #59,d0                  ; can it be...
        bgt     time_no_good            ; greater than 59.
        lsl.l   #5,d0                   ; shift minutes into place.
        or      d0,d3                   ; add minutes to new time.
        print   msg9                    ; "Press Return on minute..."
        
        move.w  #CCONIN,-(sp)           ; wait for keypress.
        trap    #1
        addq.l  #2,sp
        
        move.w  d3,-(sp)                ; move new time onto the stack.
        move.w  #TSETTIME,-(sp)         ; put function # on stack.
        Trap    #1                      ; set new time.
        addq.l  #4,sp
        bra     out

time_no_good:
        print   msg8                    ; "Not a valid time!"
        bra     change_time
        
out:    
        move.w  #PTERM0,-(sp)           ; back to desktop.
        trap    #1

;--------------------------------------------------------------------
; This subroutine gets the system date and separates it into the
; year, month, and day portions.
;
; Input: None.
; Output: Raw GEMDOS date in d0, day in d1, month in d2, and
;         year in d3.
; Registers changed: d0, d1, d2, and d3.
;--------------------------------------------------------------------
get_date:
        movem.l a0-a7/d4-d7,-(sp)       ; save registers.
        
        move.w  #TGETDATE,-(sp)         ; get system date.
        trap    #1
        addq.l  #2,sp
        
        move.l  d0,d1                   ; get copy of date.
        andi.l  #$1f,d1                 ; mask out all but day bits.
        
        move.l  d0,d2                   ; get copy of date.
        lsr.l   #5,d2                   ; shift month into low bits.
        andi.l  #$f,d2                  ; mask out all but month bits.
        
        move.l  d0,d3                   ; get copy of date.
        lsr.l   #8,d3                   ; shift year into low bits.
        lsr.l   #1,d3
        andi.l  #$7f,d3                 ; mask out all but year bits.
        addi.l  #1980,d3                ; convert from GEMDOS year.
        
        movem.l (sp)+,a0-a7/d4-d7       ; restore registers.
        rts

;--------------------------------------------------------------------
; This subroutine gets the system time and separates it into its
; hour and minute portions.  The seconds are ignored.
;
; Input: None.
; Output: Raw GEMDOS time in d0, seconds in d1, minutes in d2,
;         and hours in d3.
; Registers changed: d0, d1, d2, and d3.
;--------------------------------------------------------------------
get_time:
        movem.l a0-a7/d4-d7,-(sp)       ; save registers.
        move.w  #TGETTIME,-(sp)         ; get system time.
        trap    #1
        addq.l  #2,sp

        move.l  d0,d1                   ; get copy of time.
        andi.l  #$1f,d1                 ; mask all bits but seconds.
        
        move.l  d0,d2                   ; get copy of time.
        lsr.l   #5,d2                   ; shift minutes into low bits.
        andi.l  #$3f,d2                 ; clear all but minutes.
        
        move.l  d0,d3                   ; get copy of time.
        lsr.l   #8,d3                   ; shift hours to low bits.
        lsr.l   #3,d3
        andi.l  #$1f,d3                 ; mask out unneeded bits.
        
        movem.l (sp)+,a0-a7/d4-d7       ; Restore registers.
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

SPACE           equ     32
COMMA           equ     44
SLASH           equ     47
ZERO            equ     48
ONE             equ     49
TWO             equ     50
THREE           equ     51
FIVE            equ     53
NINE            equ     57
COLON           equ     58
UC_Y            equ     89
LC_Y            equ     121

PTERM0          equ     0
CCONIN          equ     1
CCONWS          equ     9
CCONRS          equ     10
TGETDATE        equ     42
TSETDATE        equ     43
TGETTIME        equ     44
TSETTIME        equ     45

months: dc.l    jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec

jan:    dc.b    "January ",0
feb:    dc.b    "February ",0
mar:    dc.b    "March ",0
apr:    dc.b    "April ",0
may:    dc.b    "May ",0
jun:    dc.b    "June ",0
jul:    dc.b    "July ",0
aug:    dc.b    "August ",0
sep:    dc.b    "September ",0
oct:    dc.b    "October ",0
nov:    dc.b    "November ",0
dec:    dc.b    "December ",0

msg1:   dc.b    "The current system date is ",0
msg2:   dc.b    "Would you like to change it?",13,10,0
msg3:   dc.b    "Enter new sytem date (mm/dd/yy): ",0
msg4:   dc.b    "Not a valid date!",13,10,0
msg5:   dc.b    "New date set.",13,10,0
msg6:   dc.b    "The current system time is ",0
msg7:   dc.b    "Enter new system time (hh:mm): ",0
msg8:   dc.b    "Not a valid time!",13,10,0
msg9:   dc.b    "Press RETURN at exact minute.",13,10,0
crlf:   dc.b    13,10,0

        bss

buffer: ds.b    10
buf2:   ds.b    3
