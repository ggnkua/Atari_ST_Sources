 ; Program Name: LEA_MOVE.S
 ;      Version: 1.003

 ; Assembly Instructions:

 ;    Assemble in Relocatabe mode and save with a TOS extension.

 ; Program Function:

 ;    Compares the relative speed and memory requirements of

 ;                      lea     label(pc), Am
 ;                      move.l  An, (Am)

 ;    and               lea     label, Am
 ;                      move.l  An, (Am)
 
 ;    to                move.l  An, label
 
 ; The execution time reported is for 50,000 executions of each algorithm.

 ;    In addition, this program's first AUT can disrupt the adaptive algorithm
 ; because the address that is loaded in register A2 depends on the displacement
 ; between the instruction "lea label(pc), a2" and the label it references.

 ;    When that instruction is executed in the adaptive algorithm, whatever
 ; address is the "displacement" distance away from the instruction will be
 ; loaded into register A2.  Then the instruction following, "move.l a0, (a2)
 ; will write whatever is in register A0 into that memory location.

 ;    If the address stored in register A2 while the AUT is being executed by
 ; the adaptive algorithm happens to be within the adaptive algorithm's program
 ; or data space, the results could be unpleasant.

 ;    In fact, an undisciplined store of this type is capable of corrupting any
 ; instruction or data that happens to be separated from the LEA instruction by
 ; an amount equal to the displacement, and the results could be catastrophic.
  
calculate_program_size:
 lea        -$102(pc), a1       ; Fetch basepage start address.
 lea        program_end, a0     ; Fetch program end = array address.
 trap       #6                  ; Return unused memory to op system.
 lea        stack, a7

initialize_registers_1:
 lea        header_1, a0       
 lea        header_2, a1
 lea        lea_move_start, a3
 lea        lea_move_end, a4
 lea        heading, a5
 move.w     #50000, d7
 trap       #9

initialize_registers_2:
 lea        header_3, a0       
 lea        header_4, a1
 lea        long_lea_start, a3
 lea        long_lea_end, a4
 lea        heading, a5
 move.b     #0, (a5)            ; Store a NULL in first byte to create a
 move.w     #50000, d7          ; null string so that heading gets printed
 trap       #9                  ; only once.

initialize_registers_3:
 lea        header_5, a0       
 lea        header_6, a1
 lea        move_start, a3
 lea        move_end, a4
 lea        heading, a5
 move.w     #50000, d7     
 trap       #9             

terminate:
 trap       #8

lea_move_start:                  ; This algorithm is potentially nocuous to
 lea        label(pc), a2        ; the adaptive algorithm because a displacement 
 move.l     a0, (a2)             ; will be stored in A2, not an address.
lea_move_end:

long_lea_start:                  ; This algorithm poses no threat because an
 lea        label, a2            ; address in this program's data area will be
 move.l     a0, (a2)             ; stored in A2.
long_lea_end:

move_start:                      ; This algorithm poses no threat because an
 move.l     a0, label            ; address in this program's data area will be
move_end:                        ; stored in A2.
         
 data
heading:      dc.b       "LEA_MOVE Program Results",$D,$A,$D,$A,0
header_1:     dc.b       "  Elapsed time for lea    label(pc), Am ",$D,$A
              dc.b       "                   move.l An, (Am):      ",0
header_2:     dc.b       "  Memory required for first algorithm:      ",0
header_3:     dc.b $D,$A,"  Elapsed time for lea    label, Am ",$D,$A
              dc.b       "                   move.l An, (Am):      ",0
header_4:     dc.b       "  Memory required for second algorithm:     ",0
header_5:     dc.b $D,$A,"  Elapsed time for move.l An, label:     ",0
header_6:     dc.b       "  Memory required for third algorithm:      ",0
 bss
 align
label:        ds.l  1
              ds.l 96
stack:        ds.l  0
program_end:  ds.l  0 
 end

