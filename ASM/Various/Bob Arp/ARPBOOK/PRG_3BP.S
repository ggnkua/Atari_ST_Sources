 ; Program Name: PRG_3BP.S

 ; Assembly Instructions:

 ;    Assemble in PC-relative mode and save with a TOS extension.

 ; Program Function:

 ;    Illustrates the use of GEMDOS function $4A to return to GEMDOS all
 ; memory except that required by this program.

 ; Execution Instructions:

 ;    Double click on PRG_3BP.TOS from the desktop.  After viewing the
 ; program's output, press the Return key to terminate execution.
 
 ; Because base page information is needed by this program, if it is to
 ; be executed in the AssemPro debugger, it must be loaded with the
 ; "Execute program" function.

 ; MAJOR NOTE:

 ;    Whenever a program which processes base page information is to be
 ; executed in the AssemPro debugger, special attention must be paid to the
 ; process by which the program is loaded into the debugger.

 ;    If the program is loaded into the debugger with the "Execute program"
 ; function, the entire program can be executed.

 ;    If, however, the program is loaded into the debugger as a result of
 ; just having been assembled, the instructions which process basepage
 ; information cannot be executed because there is no basepage when a program
 ; is loaded by that process.

 ;    For this particular program you would procede as follows: relocate the
 ; program by clicking on the Relocate button, then execute one, and only
 ; one, of the initialization instructions.  That is instruction four of the
 ; program:
 ;
 ;             lea  stack, a7

 ;    To accomplish this, move the PC cursor in the disassembly output field
 ; to the fourth instruction, and execute the instruction by single stepping.
 ; Then, move the PC cursor to the line containing the label "mainline".
 ; Now, execution may proceed via the "Run program" or "Single step" buttons.

 ;    A program that used a default stack provided by the system would
 ; require only that the PC cursor be moved beyond the initialization
 ; sequence, which includes the return_memory algorithm.

calculate_program_size:
 lea        program_end, a0     ; Put "end of program" address in A0.
 movea.l    4(a7), a1           ; Put basepage address in A1.
 suba.l     a1, a0              ; Subtract basepage address from program's
                                ; ending address.
 lea        stack, a7           ; Point A7 to this program's stack.

return_memory:                  ; Return unused memory to operating system.
 move.l     a0, -(sp)           ; Store total program length in stack.
 move.l     a1, -(sp)           ; Store basepage address in stack.
 move.l     #$4A0000, -(sp)     ; Function = m_shrink = GEMDOS $4A0000.
 trap       #1                  ; GEMDOS call.
 lea        $C(a7), sp          ; Reset stack pointer to top of stack.

 ; Note: When the stack pointer must be moved 8 bytes or less, use 
 ;       addq.l #n, sp, where n is the number of bytes.  When it must
 ;       be moved more than 8 bytes, addq.l can't be used.

 ;       Although you may be tempted to use adda.l #n, sp in that case, a
 ;       better choice is lea n(a7), sp because it is twice as fast and
 ;       requires 2 bytes less of memory.  Program LEA_ADDA.TOS verifies
 ;       these claims.

mainline:                       ; Marks the beginning of program proper.
 lea        newline, a0
 bsr.s      print_string

 ; The above instructions prevent damage to the debugger screen and skip a
 ; line for printer output.  Skipping a line on the printer separates the
 ; program output from a listing which precedes execution, or it will 
 ; separate the results of repeated executions.

print_declared_string:
 lea        string, a0          ; Put address of the label "string" in A0.
 bsr.s      print_string

wait_for_keypress: 
 move.w     #8, -(sp)           ; Function = c_necin = GEMDOS $8.
 trap       #1                
 addq.l     #2, sp            

terminate:
 move.w    #0, -(sp)            ; Function = p_term_old = GEMDOS $0.
 trap      #1                 

 ; SUBROUTINES

print_string:                   ; Expects address of string to be in A0.
 pea        (a0)                ; Push address of string onto stack.
 move.w     #9, -(sp)           ; Function = c_conws = GEMDOS $9.
 trap       #1                
 addq.l     #6, sp
 rts

 data
newline: dc.b $D,$A,0  ; All strings must be NULL terminated because the
                       ; function we are using to print them requires it.

                       ; Note that the ASCII code for a NULL character is $0,
                       ; which is equal to decimal 0.

                       ; The ASCII code for a carriage return is $D; that for
                       ; a linefeed is $A.

string:  dc.b 'This string will not overwrite the AssemPro debugger screen.'
         dc.b $D,$A,0  ; The string is continued on this line.  Here, we
                       ; declare a carriage return, linefeed and terminate
                       ; the entire string with a NULL = $0 = 0.

 bss
 align                          ; Align storage on a word boundary.
                 ds.l     16    ; Stack.
stack:           ds.l      0    ; Address of stack.
program_end:     ds.l      0    ; Marks the end of program memory.
 end               

