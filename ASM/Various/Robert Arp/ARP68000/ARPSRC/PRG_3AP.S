 ; Program Name: PRG_3CP.S

 ; Assembly Instructions:

 ;    Assemble in PC-relative mode and save with a TOS extension.

 ; Execution Instructions:

 ;    Execute from the desktop.  Terminate execution by pressing the Return
 ; key.

 ; Function:

 ;    Verifies that the results from two binary to ASCII decimal conversion
 ; algorithms are identical.  The first conversion algorithm is called the
 ; "repeated division" method; the number to be converted is repeatedly
 ; divided by 10.  The second algorithm is called the "repeated subtraction"
 ; method; powers of ten are repeatedly subtracted from the number to be
 ; converted.

 ; Notes: 1 - "clr.w  Dn" is one of the fastest ways to clear only the
 ;            lower word of a data register.
 ;        2 - The stack used in the program is small enough to permit easy
 ;            access to its contents via the AssemPro debugger.
 ;        3 - In the "repeated division" algorithm, a null character must
 ;            be stored in the array "reversed" for proper operation of
 ;            the "reversed_to_decimal" loop, when the program is
 ;            executed from AssemPro.  This is true because AssemPro will
 ;            not necessarily clear the array to zeroes.

 ;            When the program is executed from the desktop, however, the
 ;            operating system will clear the array.  Therefore, if the
 ;            program were intended for use such as it is, the instruction
 ;            which stores the null at the end of the array "reversed"
 ;            could be eliminated.

 ;            Note that this is only one of the many types of adjustments
 ;            which must be made when executing programs from debuggers.

calculate_program_size:
 lea        program_end, a0     ; Put "end of program" address in A0.
 movea.l    4(a7), a1           ; Put "basepage" address in A1.
 suba.l     a1, a0              ; Subtract basepage address from A0.
 lea        stack, a7           ; Point A7 to this program's stack.

return_memory:                  ; Return unused memory to operating system.
 pea        (a0)                ; Store total program length in stack.
 pea        (a1)                ; Store basepage address in stack.
 move.l     #$4A0000, -(sp)     ; Function = m_shrink = GEMDOS $4A.

 ; NOTE: The above instruction is a combination of two most often seen
 ;       in references:

 ;       move.w     d0, -(sp)   ; Dummy value, can be anything.
 ;       move.w     #$4a, -(sp) ; Function = m_shrink = GEMDOS $4A.

 trap       #1                  ; GEMDOS call.
 lea        $C(sp), sp          ; Reset stack pointer to top of stack.

mainline:                       ; Marks the beginning of program proper.
 lea        heading, a0         ; Print heading for program's output.
 bsr        print_string
                            
repeated_division_method_1:
 lea        message_1, a0      
 bsr        print_string       
 move.l     #2147483647, d1     ; Number to be converted to ASCII decimal.
 bsr        bin_to_dec_1        ; Routine expects number to be in D1.
 lea        decimal, a0         ; to print_string alters the stack by pushing
 bsr        print_string        ; the return address onto the stack.

 ; NOTE: Remember, although the number we store in D1 appears to our eyes
 ;       to be a very familiar decimal number, the computer does not see
 ;       it that way.  It is the assembler that lets us see things that
 ;       are palatable to us while we are programming, and which, during
 ;       assembly, converts that which we like to something the computer
 ;       likes.  And the computer likes binary.

repeated_subtraction_1:
 move.l     #2147483647, d1     ; Number to be converted to ASCII decimal.
 bsr        bin_to_dec_2        ; Routine expects number to be in D1.
 lea        message_2, a0
 bsr        print_string 
 lea        decimal, a0  
 bsr.s      print_string 
 bsr        print_newline

repeated_division_method_2:
 move.l     #-7483647, d1       ; Binary number to be converted to decimal.
 bsr        bin_to_dec_1        ; Routine expects number to be in D1.
 lea        message_1, a0       ; Address of string cannot be pushed onto
 bsr.s      print_string        ; stack here because the subroutine call
 lea        decimal, a0         ; to print_string alters the stack by pushing
 bsr.s      print_string        ; the return address onto the stack.

repeated_subtraction_method_2:
 move.l     #-7483647, d1       ; Number to be converted to ASCII decimal.
 bsr        bin_to_dec_2        ; Routine expects number to be in D1.
 lea        message_2, a0       ; Address of string cannot be pushed onto
 bsr.s      print_string        ; stack here because the subroutine call
 lea        decimal, a0         ; to print_string alters the stack by pushing
 bsr.s      print_string        ; the return address onto the stack.
 bsr.s      print_newline

repeated_division_method_3:
 move.l     #0, d1              ; Number to be converted to ASCII decimal.
 bsr.s      bin_to_dec_1        ; Routine expects number to be in D1.
 lea        message_1, a0       ; Address of string cannot be pushed onto
 bsr.s      print_string        ; stack here because the subroutine call
 lea        decimal, a0         ; to print_string alters the stack by pushing
 bsr.s      print_string        ; the return address onto the stack.

repeated_subtraction_method_3:
 move.l     #0, d1              ; Number to be converted to ASCII decimal.
 bsr        bin_to_dec_2        ; Routine expects number to be in D1.
 lea        message_2, a0       ; Address of string cannot be pushed onto
 bsr.s      print_string        ; stack here because the subroutine call
 lea        decimal, a0         ; to print_string alters the stack by pushing
 bsr.s      print_string        ; the return address onto the stack.
 bsr.s      print_newline

wait_for_keypress:
 move.w     #8, -(sp)           ; Function = c_necin = GEMDOS $8.
 trap       #1                  ; GEMDOS call.
 addq.l     #2, sp              ; Reposition stack pointer at top of stack.

terminate:
 move.w     #0, -(sp)           ; Function = p_term_old = GEMDOS $0.
 trap       #1                  ; GEMDOS call.
 
 ;
 ; SUBROUTINES
 ;

print_string:                   ; Expects address of string to be in A0.
 move.l     a0, -(sp)           ; Push address of string onto stack.
 move.w     #9, -(sp)           ; Function = c_conws = GEMDOS $9.
 trap       #1                  ; GEMDOS call
 addq.l     #6, sp              ; Reposition stack pointer.
 rts

print_newline:                  ; Prints a carriage return and linefeed.
 pea        newline             ; Push address of string onto stack.
 move.w     #9, -(sp)           ; Function = c_conws = GEMDOS $9.
 trap       #1                  ; GEMDOS call
 addq.l     #6, sp
 rts

 ; The binary to ASCII decimal conversion subroutine uses an algorithm
 ; based on the "repeated division" algorithm discussed in chapter 9 of the
 ; Ford & Topp book; however, the algorithm used here is not limited to a
 ; 16-bit binary number.  There is a similar algorithm in the Atari section
 ; of appendix B in the Skinner book. The divisor is decimal 10.

bin_to_dec_1:                   ; Converts 32-bit binary number in D1 to
                                ; ASCII decimal.
 lea        decimal, a0         ; Point to beginning of array "decimal".
 lea        reversed + 10, a1   ; Point to end of array "reversed".
 move.b     #0, (a1)            ; Put a null at the end of the array.
_get_sign:
 tst.l      d1                  ; Is binary number positive, negative or zero?
 beq.s      _zero_passed        ; Branch if number is 0.
 bpl.s      _positive           ; Branch if positive.
 move.b     #$2D, (a0)+         ; Store a minus sign in array decimal.
 neg.l      d1                  ; Change number from negative to positive.
 bra.s      division_loop
_positive:                      ; Branch to here when number is positive.
 move.b     #$20, (a0)+         ; Store a space in array decimal.
division_loop:                 
 move.w     d1, d2              ; Store lower word in temp register D2.
 clr.w      d1                  ; Clear lower word.  
 swap       d1                  ; Move higher word to lower word.
 divu       #10, d1             ; Divide full 32 bits by ten.
 move.w     d1, d3              ; Store quotient in temp register D3.
 move.w     d2, d1              ; Combine lower word with remainder.
 divu       #10, d1             ; Divide full 32 bits by ten.
 swap       d1                  ; Swap quotient and remainder words.
_convert_to_ascii:              ; Convert digit to ASCII and store it.
 addi.b     #$30, d1            ; Convert digit to ASCII.
 move.b     d1, -(a1)           ; Store the digit in array "reversed".
 move.w     d3, d1              ; Bring in higher word quotient. 
 swap       d1                  ; Swap high and low word quotients.
 tst.l      d1                  ; Is content of D1 zero yet?
 bne.s      division_loop       ; Continue until content of D1 is zero.
reversed_to_decimal:            ; Transfer contents of "reversed" to "decimal".
 move.b     (a1)+, (a0)+        ; Loop until the null is transfered.
 bne.s      reversed_to_decimal
 rts
_zero_passed:
 move.b     #$20, (a0)+         ; Store a space in array "decimal".
 move.b     #$30, (a0)+         ; Store the zero in array "decimal".
 move.b     #0, (a0)            ; Terminate the decimal string with a null.
 rts

 ; Conversion from binary to ASCII decimal using repeated subtraction.
 ; See documentation in program PRG_3AP.S
 
bin_to_dec:                  
 lea        decimal, a0         ; Put address of array "decimal" in A0.
 lea        subtrahend, a1      ; Put address of subtrahend table in A1.
 move.l     (a1)+, d0           ; Put first subtrahend in D0.
 moveq      #0, d2              ; Initialize subtractions counter to zero.
get_sign:
 tst.l      d1                  ; Is binary number positive, negative or zero?
 beq.s      zero_passed         ; Branch if number is 0.
 bpl.s      positive            ; Branch if positive.
 move.b     #$2D, (a0)+         ; Store a minus sign in array "decimal".
 neg.l      d1                  ; Change binary number from neg to pos.
 bra.s      discard_leading_zeroes
positive:                       ; Branch to here when number is positive.
 move.b     #$20, (a0)+         ; Store a space in array decimal.
discard_leading_zeroes:         ; Subtract subtrahend from minuend.
 sub.l      d0, d1              ; Loop till difference is positive,
 bpl.s      subtract            ; indicating that digit is not zero.
 add.l      d0, d1              ; Restore minuend.
 move.l     (a1)+, d0           ; Get next subtrahend.
 bra.s      discard_leading_zeroes
subtract:
 addq.b     #1, d2              ; Increment subtractions counter.
 sub.l      d0, d1              ; Subtract subtrahend from D1.
 bpl.s      subtract            ; Loop until D1 becomes negative.
convert_to_ascii:
 addi.b     #$30, d2            ; Converts binary number to ASCII code.
 move.b     d2, (a0)+           ; Store the ASCII digit in array "decimal".
loop_setup:
 add.l      d0, d1              ; Restore the minuend.
 moveq      #-1, d2             ; Pre-initialize subtractions counter to -1.
 move.l     (a1)+, d0           ; Get next subtrahend.
 bne.s      subtract            ; Loop back until subtrahend = 0.
 move.b     #0, (a0)            ; Terminate decimal string with a null.
 rts
zero_passed:
 move.b     #$20, (a0)+         ; Store a space in array "decimal".
 move.b     #$30, (a0)+         ; Store an ASCII zero in array "decimal".
 move.b     #0, (a0)            ; Terminate ASCII decimal string with a null.
 rts

 data
subtrahend:  dc.l   $3B9ACA00,$5F5E100,$989680,$F4240,$186A0,$2710,$3E8
             dc.l   $64,$A,$1,$0
heading:     dc.b   $D,$A,'PRG_3CP Execution Results',$D,$A,$D,$A,0
message_1:   dc.b         '   Decimal value by repeated division method:    ',0
message_2:   dc.b   $D,$A,'   Decimal value by repeated subtraction method: ',0
newline:     dc.b $D,$A,0
 bss
 align                  ; Align storage on a word boundary.
reversed:    ds.l    3  ; Temp buffer for the repeated division method.
decimal:     ds.l    3  ; Output buffer, must be NULL terminated.
             ds.l   24  ; Program stack, short enough for examination.
stack:       ds.l    0  ; Address of program stack.
program_end: ds.l    0  ; Marks the end of program memory.
 end
