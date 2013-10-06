 ; Program Name: LEA_ADDA.S
 ; Version 1.004

 ; Assembly Instructions:

 ;    Assemble in PC-relative mode and save with a TOS extension.

 ; Execution Instructions:

 ;     Execute from the desktop; or execute SPAWN.TTP, type LEA_ADDA.TOS on
 ; its command line and view this program's output in LEA_ADDA.DAT.

 ; Program Function:
 
 ;    Confirms (or refutes) the contention that lea $C(An), An is faster
 ; than adda.l #$C(An), where n = 1 - 7.  Reference: "68000 Tricks and Traps",
 ; by Mike Morton, p.166, Byte, September, 1986.  See the paragraph which
 ; begins "Small adjustments to the stack pointer...".

calculate_program_size:
 lea        -$102(pc), a1       ; Fetch basepage start address.
 lea        program_end, a0     ; Fetch program end address.
 trap       #6                  ; Return unused memory to op system.
 lea        stack, a7           ; Point A7 to this program's stack.

print_heading:
 lea        heading, a0
 bsr        print_string

lea_method:
 lea        lea_time_msg, a0    ; Print label for lea execution results.
 bsr        print_string
 move.l     #49999, d7          ; D7 is counter for the loop.
 trap       #3                  ; Value of system clock returned in D0.
 move.l     d0, d1              ; Save time in scratch register.

lea_loop:                       ; Marks start of instruction in the loop.
 lea        $C(a2), a2          ; Instruction in the loop.
memory_1:                       ; Marks end of instruction in the loop.
 dbra       d7, lea_loop        ; Loop 50000 times.
 trap       #3                  ; Get current value of system clock.
 sub.l      d1, d0              ; Subtract beginning value from ending value.
 mulu       #5, d0              ; Convert to milliseconds.
 sub.l      #80, d0             ; Subtract dbra time and "error".
                                ; See Timing Note below.
 move.l     d0, d1              ; Transfer time for trap #4 call.
convert_lea_time_to_ASCII_decimal:
 trap       #4                  ; Address of decimal string returned in A0.
print_lea_time:
 bsr.s      print_string        ; Print the decimal string.
 lea        time_msg, a0        ; Print units label.
 bsr.s      print_string

 ; Timing Note:

 ;   Until the count has expired, each dbra instruction requires 10 clock
 ; periods to execute.  49,999 dbra instructions require that amount of
 ; time.  When the last dbra instruction is executed, the count has expired
 ; and that instruction requires 14 clock periods.

 ;   Total clock periods consumed by the dbra instruction is 

 ;                  49,999 X 10 + 14 = 500,004.

 ;   Each clock period is .000000125 second.  Total time consumed by the
 ; dbra instructions is

 ;        500,004 X .000000125 = .0625 second = 62.5 milliseconds.

 ;   If we assume that the 8 clock period execution time given in the
 ; Motorola reference manual for the lea d(An) instruction is correct,
 ; then 50,000 executions of lea $C(a2), a2 require 

 ;            50,000 X 8 X .000000125 = 50 milliseconds

 ;   Total time for the lea loop is 62.5 + 50 = 112.5 milliseconds.

 ;   When no adjustment is made for "overhead" time, such as attendant
 ;   instructions, which includes the dbra instruction, trap invocations and
 ;   a few others, this program reports a lea loop execution time of 130
 ;   milliseconds.  We can assume that the excess 17.5 milliseconds (130-112.5)
 ;   is partially due to the "overhead" time and partially due to a system
 ;   clock frequency different from 8 mhz.  We can simply combine both
 ;   components into "overhead" time.

 ;   With no adjustment for "overhead" time this program reports a loop
 ;   execution time of 180 milliseconds for the adda.l #$C, a2 loop.  We
 ;   subtract the 17.5 milliseconds "overhead" from this to obtain the true
 ;   loop time of 162.5 milliseconds.

 ;   From this we subtract the dbra execution time of 62.5 milliseconds to
 ;   get 100 milliseconds for 50,000 adda.l instruction..

 ;       62.5 milliseconds / 50,000 = .000002 second per instruction.

 ;         .000002 / .000000125 = 16 clock periods per instruction 

 ;   The execution time given in the Motorola manual for the adda.l #d, An 
 ;   instruction is 16 clock periods.

 ;   These calculations validate the method and justify subtracting the
 ;   "overhead" time from the total loop execution times before printing the
 ;   execution time for 50,000 executions of each of the two instructions of
 ;   interest.  Finally, we can combine dbra time and "overhead" time into
 ;   a "new" overhead time that is 17.5 + 62.5 = 80 milliseconds.

 ;   When the adjustments are made to the recorded loop times, the program
 ;   prints out the correct time for 50,000 executions of each instruction,
 ;   and the output correctly indicates that the lea instruction used in
 ;   the program is twice as fast as the adda.l instruction used.  The 
 ;   execution results of the program agree with the timing data given in
 ;   the Motorola reference guide.

adda_method:
 lea        adda_time_msg, a0   ; Print label for adda execution results.
 bsr.s      print_string
 move.l     #49999, d7          ; D7 is counter for the loop.
 trap       #3                  ; Value of system clock returned in D0.
 move.l     d0, d1              ; Save time in scratch register.

adda_loop:                      ; Marks start of instruction in the loop.   
 adda.l     #$C, a2             ; Instruction in the loop.
memory_2:                       ; Marks end of instruction in the loop.
 dbra       d7, adda_loop       ; Loop 50000 times.
 trap       #3                  ; Get current value of system clock.
 sub.l      d1, d0              ; Subtract beginning value from ending value.
 mulu       #5, d0              ; Convert to milliseconds.
 sub.l      #80, d0             ; Subtract dbra time and "error".
 move.l     d0, d1              ; Transfer time for trap #4 call.
convert_adda_time_to_ASCII_decimal:
 trap       #4                  ; Address of decimal string returned in A0.
print_adda_time:
 bsr.s      print_string        ; Print the decimal string.
 lea        time_msg, a0        ; Print units label.
 bsr.s      print_string

print_lea_requisite_memory:
 lea        lea_memory_msg, a0
 bsr.s      print_string
 lea        memory_1, a0        ; Calculate number of bytes occupied by the
 lea        lea_loop, a1        ; instruction in the loop.
 bsr.s      print_requisite_memory

print_adda_requisite_memory:
 lea        adda_memory_msg, a0
 bsr.s      print_string
 lea        memory_2, a0        ; Calculate number of bytes occupied by the
 lea        adda_loop, a1       ; instruction in the loop.
 bsr.s      print_requisite_memory

terminate:
 trap       #8

 ; SUBROUTINES

print_requisite_memory:
 suba.l     a1, a0
 move.l     a0, d1
 trap       #4                  ; Returns address of decimal string in A0.
 bsr.s      print_string
 lea        memory_msg, a0
 bsr.s      print_string
 rts

print_string:                   ; Expects address of string to be in A0.
 pea        (a0)                ; Push address of string onto stack.
 move.w     #9, -(sp)           ; Function = c_conws = GEMDOS $9.
 trap       #1                  ; GEMDOS call
 addq.l     #6, sp              ; Reset stack pointer to top of stack.
 rts

 data
heading:         dc.b $D,$A,'LEA_ADDA Execution Results',$D,$A,$D,$A,0
lea_time_msg:    dc.b '   Time for 50,000 lea instructions:     ',0
adda_time_msg:   dc.b '   Time for 50,000 adda.l instructions: ',0
time_msg:        dc.b ' milliseconds',$D,$A,0
lea_memory_msg:  dc.b $D,$A,'   LEA requisite memory:    ',0
adda_memory_msg: dc.b       '   ADDA.L requisite memory: ',0
memory_msg:      dc.b ' bytes',$D,$A,0
 bss
 align                          ; Align storage on a word boundary.
                 ds.l     96
stack:           ds.l      0
program_end:     ds.l      0    ; Marks the end of program memory.
 end

