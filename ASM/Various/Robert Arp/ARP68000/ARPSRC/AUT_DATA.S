 ; Program Name: AUT_DATA.S
 ;      Version: 1.001

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

 ;    In this program, a data area is declared before the AUT's so that the
 ; first AUT can't disrupt the adaptive algorithm.  The address of the data
 ; area is passed to the adaptive algorithm in register A2.

 ;    A branch statement is included in each AUT so that the adaptive algorithm
 ; will jump over the data area.
  
 ;    Of course, this calls for a redesign of the adaptive algorithm.

calculate_program_size:
 lea        -$102(pc), a1       ; Fetch basepage start address.
 lea        program_end, a0     ; Fetch program end = array address.
 trap       #6                  ; Return unused memory to op system.
 lea        stack, a7

initialize_registers_1:
 lea        header_1, a0       
 lea        header_2, a1
 lea        lea_data_area, a2
 lea        lea_move_start, a3
 lea        lea_move_end, a4
 lea        heading, a5
 move.w     #50000, d7
 trap       #9

initialize_registers_2:
 lea        header_3, a0       
 lea        header_4, a1
 lea        long_data_area, a2
 lea        long_lea_start, a3
 lea        long_lea_end, a4
 lea        heading, a5
 move.b     #0, (a5)            ; Store a NULL in first byte to create a
 move.w     #50000, d7          ; null string so that heading gets printed
 trap       #9                  ; only once.

initialize_registers_3:
 lea        header_5, a0       
 lea        header_6, a1
 lea        move_data_area, a2
 lea        move_start, a3
 lea        move_end, a4
 lea        heading, a5
 move.w     #50000, d7     
 trap       #9             

terminate:
 trap       #8

lea_data_area:
 bra.s      lea_move_start
label_1:    ds.l 1
lea_move_start:                
 lea        label_1(pc), a2      
 move.l     a0, (a2)           
lea_move_end:

long_data_area:
 bra.s      long_lea_start
label_2:    ds.l 1
long_lea_start:              
 lea        label_2, a2        
 move.l     a0, (a2)         
long_lea_end:

move_data_area:
 bra.s      move_start
label_3:    ds.l 1
move_start:                  
 move.l     a0, label_3        
move_end:                    
         
 data
heading:      dc.b       "AUT_DATA Program Results",$D,$A,$D,$A,0
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
              ds.l 96
stack:        ds.l  0
program_end:  ds.l  0 
 end
