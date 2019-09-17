 ; Program Name: PRG_3CP.S

 ; Assembly Instructions:

 ;    Assemble in PC-relative mode and save with a TOS extension.

 ; Execution Instructions:

 ;    Execute from the desktop.  Terminate execution by pressing the Return
 ; key.

 ; Function:

 ;    This program is divided into two parts.  Part 1 verifies that the
 ; results from two binary to ASCII decimal conversion algorithms are
 ; identical.  The first conversion algorithm is called the "repeated
 ; division" method; the number to be converted is repeatedly divided by 10.
 ; The second algorithm is called the "repeated subtraction" method; powers
 ; of ten are repeatedly subtracted from the number to be converted.

 ;    Part 2 compares the two algorithms to determine which is the faster.

 ;    Part 1 contains three sections.  Section 1 confirms that both algorithms
 ; yield the same result for a positive number; section 2 confirms identical
 ; results for a negative number; section 3 confirms identical results for
 ; the number zero.

 ; A FEW NOTES:

 ; 1 - "clr.w  Dn" is one of the fastest ways to clear only the lower word
 ;     of a data register.

 ; 2 - The stack used in the program is small enough to permit easy access
 ;     to its contents via the AssemPro debugger.

 ; 3 - In the "repeated division" algorithm, a null character must be stored
 ;     in the array "reversed" for proper operation of the
 ;     "reversed_to_decimal" loop when the program is executed from AssemPro.
 ;     This is true because AssemPro will not necessarily clear the array to
 ;     zeroes.

 ;     When the program is executed from the desktop, however, the operating
 ;     system will clear the array.  Therefore, if the program were intended
 ;     for use such as it is, the instruction which stores the null at the
 ;     end of the array "reversed" could be eliminated.

 ;     This is only one of the many types of adjustments
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

 ; NOTE: The above instruction is a combination of two that are often seen
 ;       in references:

 ;       move.w     d0, -(sp)   ; Dummy value, can be anything.
 ;       move.w     #$4a, -(sp) ; Function = m_shrink = GEMDOS $4A.

 trap       #1                  ; GEMDOS call.
 lea        $C(sp), sp          ; Reset stack pointer to top of stack.

mainline:                       ; Marks the beginning of program proper.
 lea        heading, a0         ; Print heading for program's output.
 bsr        print_string
 
 ;
 ; PART 1, SECTION 1: Conversion of a positive binary number to ASCII decimal.
 ;

 lea        part_1_head, a0     ; Print PART 1 heading.
 bsr        print_string
 lea        sect_1_head, a0     ; Print SECTION 1 heading.
 bsr        print_string
                               
repeated_division_1:
 lea        division_head, a0   ; Print heading for division results.      
 bsr        print_string       
 move.l     #2147483647, d1     ; Number to be converted must be in D1.
 bsr        bin_to_dec_1        ; ASCII decimal string stored in "decimal".
 lea        decimal, a0         ; Print ASCII decimal string.     
 bsr        print_string     

 ; NOTE: Remember, although the number we store in D1 appears to our eyes
 ;       to be a very familiar decimal number, the computer does not see
 ;       it that way.  It is the assembler that lets us see things that
 ;       are palatable to us while we are programming, and which, during
 ;       assembly, converts that which we like to something the computer
 ;       likes.  And the computer likes binary.

repeated_subtraction_1:
 lea        subtract_head, a0   ; Print heading for subtraction results.
 bsr        print_string 
 move.l     #2147483647, d1     ; Number to be converted must be in D1.
 bsr        bin_to_dec_2        ; ASCII decimal string stored in "decimal". 
 lea        decimal, a0         ; Print ASCII decimal string.
 bsr        print_string 
 bsr        print_newlines

 ;
 ; PART 1, SECTION 2: Conversion of a negative binary number to ASCII decimal.
 ;

 lea        sect_2_head, a0     ; Print SECTION 2 heading.
 bsr        print_string

repeated_division_2:
 lea        division_head, a0   ; Print heading for division results.      
 bsr        print_string 
 move.l     #-7483647, d1      
 bsr        bin_to_dec_1       
 lea        decimal, a0        
 bsr        print_string       

repeated_subtraction_2:
 lea        subtract_head, a0   ; Print heading for subtraction results.
 bsr        print_string
 move.l     #-7483647, d1 
 bsr        bin_to_dec_2  
 lea        decimal, a0
 bsr        print_string
 bsr        print_newlines

 ;
 ; PART 1, SECTION 3: Conversion of binary number zero to ASCII decimal.
 ;

 lea        sect_3_head, a0     ; Print SECTION 3 heading.
 bsr        print_string

repeated_division_3:
 lea        division_head, a0   ; Print heading for division results.      
 bsr        print_string 
 move.l     #0, d1         
 bsr        bin_to_dec_1   
 lea        decimal, a0    
 bsr        print_string   

repeated_subtraction_3:
 lea        subtract_head, a0   ; Print heading for subtraction results.
 bsr        print_string
 move.l     #0, d1           
 bsr        bin_to_dec_2     
 lea        decimal, a0      
 bsr        print_string     
 bsr        print_newlines

 ;
 ; PART 2: Repeated division algorithm versus repeated subtraction algorithm
 ;         execution speed comparision.  Each algorithm is executed 1000 times.
 ;

 lea        part_2_head, a0     ; Print PART 2 heading.
 bsr        print_string

repeated_division_method:
 lea        div_time_head, a0
 bsr        print_string
 move.l     #9999, d7           ; D7 is counter for the push loop.
 bsr        get_time            ; Value of system clock returned in D5.
 move.l     d5, d6              ; Save time in scratch register.
division_loop:
 move.l     #1928374650, d1     ; Number to be converted to ASCII decimal.
 bsr        bin_to_dec_1 
 dbra       d7, division_loop   ; Loop 1000 times.
 bsr        get_time            ; Get current value of system clock.
 sub.l      d6, d5              ; Subtract beginning value from ending value.
 mulu       #5, d5              ; Convert to milliseconds.
 move.l     d5, d1              ; Transfer value for conversion to ASCII decimal.
 bsr       bin_to_dec_2        ; Convert.
 lea        decimal, a0         ; Print repeated division algorithm time.
 bsr.s      print_string
 lea        units_label, a0     ; Print time label.
 bsr.s      print_string

repeated_subtraction_method:
 lea        sub_time_head, a0
 bsr.s      print_string
 move.l     #9999, d7           ; D7 is counter for the push loop.
 bsr        get_time            ; Value of system clock returned in D5.
 move.l     d5, d6              ; Save time in scratch register.
subtraction_loop:
 move.l     #1928374650, d1     ; Number to be converted to ASCII decimal.
 bsr        bin_to_dec_2 
 dbra       d7, subtraction_loop; Loop 1000 times.
 bsr        get_time            ; Get current value of system clock.
 sub.l      d6, d5              ; Subtract beginning value from ending value.
 mulu       #5, d5              ; Convert to milliseconds.
 move.l     d5, d1              ; Transfer value for conversion to ASCII decimal.
 bsr        bin_to_dec_2        ; Convert.
 lea        decimal, a0         ; Print repeated division algorithm time.
 bsr.s      print_string
 lea        units_label, a0     ; Print time label.
 bsr.s      print_string

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

print_newlines:                 ; Prints 2 carriage returns and linefeeds.
 pea        newlines            ; Push address of string onto stack.
 move.w     #9, -(sp)           ; Function = c_conws = GEMDOS $9.
 trap       #1                  ; GEMDOS call
 addq.l     #6, sp
 rts

 ; Get_time subroutine.  Returns current value of system clock in D5.

 ; The get_time subroutine obtains the current value of the system variable
 ; _hz_200 (memory location $4BA).  This variable is incremented every 200
 ; hertz, which means that the period between increments is 5 milliseconds
 ; (1/200 = .005).  In turn, this means that the variable measures time with 
 ; a resolution of 5 milliseconds.

 ; Use this subroutine to measure the elapsed time of an event as follows:
 
 ; 1. Read and store the content of $4BA at the beginning of the event.
 ; 2. At the conclusion of the event, read the content of $4BA again.
 ; 3. Subtract the first value from the second.  This yields the number of
 ;    5 millisecond intervals which occurred during the event.
 ; 4. Multiply the difference by 5 to convert the elapsed time to milliseconds.

get_time:                       ; Get number of 5 msec periods.
 move.l     #0, -(sp)           ; The zero turns on supervisor mode.
 move.w     #$20, -(sp)         ; Function = super = GEMDOS $20.
 trap       #1                  ; Go to supervisor mode.
 addq.l     #6, sp              ; Supervisor stack pointer returned in D0.
 move.l     $4BA, d5            ; Copy system time into register D5
 move.l     d0, -(sp)           ; Restore supervisor stack pointer.
 move.w     #$20, -(sp)         ; Function = super = GEMDOS $20.
 trap       #1                  ; Go to user mode.
 addq.l     #6, sp              ; Reset stack pointer to top of stack.
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
 bra.s      _division_loop
_positive:                      ; Branch to here when number is positive.
 move.b     #$20, (a0)+         ; Store a space in array decimal.
_division_loop:
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
 bne.s      _division_loop      ; Continue until content of D1 is zero.
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
 ; See documentation in program PRG_3AP.S.
 
bin_to_dec_2:                  
 lea        decimal, a0         ; Put address of array "decimal" in A0.
 lea        subtrahend, a1      ; Put address of subtrahend table in A1.
 move.l     (a1)+, d0           ; Put first subtrahend in D0.
 move.b     #$30, d2            ; Initialize subtractions counter to ASCII zero.
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
 move.b     d2, (a0)+           ; Store the ASCII digit in array "decimal".
loop_setup:
 add.l      d0, d1              ; Restore the minuend.
 move.b     #$2F, d2            ; Pre-initialize subtractions counter to $30-1.
 move.l     (a1)+, d0           ; Get next subtrahend.
 bne.s      subtract            ; Loop back until subtrahend = 0.
 move.b     #0, (a0)            ; Terminate decimal string with a null.
 rts
zero_passed:
 move.b     #$20, (a0)+         ; Store a space in array "decimal".
 move.b     d2, (a0)+           ; Store an ASCII zero in array "decimal".
 move.b     #0, (a0)            ; Terminate ASCII decimal string with a null.
 rts

 data
subtrahend:    dc.l $3B9ACA00,$5F5E100,$989680,$F4240,$186A0,$2710,$3E8
               dc.l $64,$A,$1,$0
heading:       dc.b 'PRG_3CP Execution Results',$D,$A,$D,$A,0
part_1_head:   dc.b '  Part 1: Conversion Verification',$D,$A,$D,$A,0
sect_1_head:   dc.b '    Section 1: Positive Number Conversion',$D,$A,$D,$A,0
sect_2_head:   dc.b '    Section 2: Negative Number Conversion',$D,$A,$D,$A,0
sect_3_head:   dc.b '    Section 3: Converson for Zero',$D,$A,$D,$A,0
division_head: dc.b '      Decimal value by repeated division method:    ',0
subtract_head: dc.b $D,$A
               dc.b '      Decimal value by repeated subtraction method: ',0
part_2_head:   dc.b '  Part 2: Execution Speed Results',$D,$A,$D,$A,0
time_head:     dc.b '    Times for 1000 executions of each conversion method.',0
div_time_head: dc.b '      Elapsed time for repeated division method:    ',0
sub_time_head: dc.b '      Elapsed time for repeated subtraction method: ',0
units_label:   dc.b ' milliseconds',$D,$A,0
newlines:      dc.b $D,$A,$D,$A,0
 bss
 align                  ; Align storage on a word boundary.
reversed:    ds.l    3  ; Temp buffer for the repeated division method.
decimal:     ds.l    3  ; Output buffer, must be NULL terminated.
             ds.l   24  ; Program stack, short enough for examination.
stack:       ds.l    0  ; Address of program stack.
program_end: ds.l    0  ; Marks the end of program memory.
 end
 