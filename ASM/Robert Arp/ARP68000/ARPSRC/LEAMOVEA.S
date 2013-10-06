 ; Program Name: LEAMOVEA.S
 ;      Version: 1.001

 ; Assembly Instructions:

 ;    Assemble with ASSEMPRO and save with a TOS extension.

 ; Execution Instructions:

 ;     Execute from the desktop; or execute SPAWN.TTP, type LEAMOVEA.TOS on
 ; its command line and view this program's output in LEAMOVEA.DAT.

 ; Program Function:
 
 ;    Confirms (or refutes) the statement on page 113 of the Stan Kelly-
 ; Bootle book, to wit: MOVEA.Z #<label>, A0 is equivalent to LEA, and
 ; faster.

 ;    For each of the two methods of loading the address of a string into
 ; and address register, calculates the memory occupied by each method, and
 ; calculates the execution time in milliseconds required for 50,000
 ; executions of each.

 ; PROGRAM RESULTS:

 ;      When the program containing the two instructions under discussion
 ; is assembled in AssemPro's Relocatable mode, the instructions are
 ; equivalent in speed and requisite memory.

 ;      However, when the program is assembled in AssemPro's PC-relative
 ; mode, the LEA instruction is faster and requires less memory.  The claim
 ; that the MOVEA.Z instruction is faster than the LEA instruction is,
 ; therefore, soundly refuted.

 ;      But, when the program is assembled in PC-relative mode, the MOVEA.Z
 ; instruction does not move the correct value into the address register,
 ; so there is really no choice when either pc-relative addressing or
 ; PC-relative assembly is used--LEA must be used then.

calculate_program_size:
 lea        -$102(pc), a1       ; Fetch basepage start address.
 lea        program_end, a0     ; Fetch program end = array address.
 trap       #6                  ; Return unused memory to op system.
 lea        stack, a7

initialize_registers_1:
 lea        header_1, a0       
 lea        header_2, a1
 lea        lea_start, a3
 lea        lea_end, a4
 lea        heading, a5
 move.w     #50000, d7
 trap       #9

initialize_registers_2:
 lea        header_3, a0       
 lea        header_4, a1
 lea        movea_start, a3
 lea        movea_end, a4
 lea        heading, a5
 move.b     #0, (a5)            ; Store a NULL in first byte to create a
 move.w     #50000, d7          ; null string so that heading gets printed
 trap       #9                  ; only once.

terminate:
 trap       #8

lea_start:
 lea        newline, a2         ; Instruction in the loop.
lea_end:

movea_start:
 movea.l     #newline, a2       ; Instruction in the loop.
movea_end:

 data
heading:      dc.b       'LEAMOVEA Execution Results',$D,$A,$D,$A,0
header_1:     dc.b       '  Elapsed time for LEA:    ',0
header_2:     dc.b       '  Memory required for LEA:    ',0
header_3:     dc.b $D,$A,'  Elapsed time for MOVEA:  ',0
header_4:     dc.b       '  Memory required for MOVEA:  ',0
newline:      dc.b $D,$A,0
 bss
 align
              ds.l 96
stack:        ds.l  0
program_end:  ds.l  0
 end

