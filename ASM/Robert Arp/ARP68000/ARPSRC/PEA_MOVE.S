 ; Program Name: PEA_MOVE.S
 ;      Version: 1.001

 ; Assembly Instructions:

 ;    Assemble in PC-relative mode and save with a TOS extension.

 ; Program Function:

 ;    Compares the relative speed and memory requirements of "pea (a0)" to
 ; that of "move.l a0, -(sp)".  The execution time reported is for
 ; 50,000 executions of each instruction.

 ; Execution Note:

 ;    Invokes traps that are installed by CUSTOM.PRG during boot.

calculate_program_size:
 lea        -$102(pc), a1       ; Fetch basepage start address.
 lea        program_end, a0     ; Fetch program end = array address.
 adda.l     #200512, a0         ; Add in extra large stack space.
 movea.l    a0, a7              ; Point A7 to this program's stack.
 trap       #6                  ; Return unused memory to op system.

initialize_registers_1:
 lea        header_1, a0       
 lea        header_2, a1
 lea        pea_algorithm_start, a3
 lea        pea_algorithm_end, a4
 lea        heading, a5
 move.w     #50000, d7
 trap       #9

initialize_registers_2:
 lea        header_3, a0       
 lea        header_4, a1
 lea        move_algorithm_start, a3
 lea        move_algorithm_end, a4
 lea        heading, a5
 move.b     #0, (a5)            ; Store a NULL in first byte to create a
 move.w     #50000, d7          ; null string so that heading gets printed
 trap       #9                  ; only once.

terminate:
 trap       #8

pea_algorithm_start:
 pea        (a0)                ; Instruction in the loop.
pea_algorithm_end:

move_algorithm_start:
 move.l     a0, -(sp)           ; Instruction in the loop.
move_algorithm_end:
         
 data
heading:      dc.b       "PEA_MOVE Program Results",$D,$A,$D,$A,0
header_1:     dc.b       "  Elapsed time for pea (a0):         ",0
header_2:     dc.b       "  Memory required for pea (a0):         ",0
header_3:     dc.b $D,$A,"  Elapsed time for move.l a0, -(sp): ",0
header_4:     dc.b       "  Memory for move.l a0, -(sp)           ",0
 bss
 align                       
program_end:  ds.l  0 
 end

