 ; Program Name: COMPARE.S
 ;      Version: 1.003

 ; Assembly Instructions:

 ;    Assemble in PC-relative mode and save with a TOS extension.

 ; Program Function:

 ;    Compares the relative speed and memory requirements of

 ;                         cmpi.l #d8, dn
 
 ;    to                   moveq #d8, dm
 ;                         cmp.l dm, dn

 ; in an effort to confirm or refute the assertion on page 202 of the
 ; Kelly-Bootle book that the second algorithm is a faster.  The execution
 ; time reported is for 50,000 executions of each algorithm.
  
calculate_program_size:
 lea        -$102(pc), a1       ; Fetch basepage start address.
 lea        program_end, a0     ; Fetch program end = array address.
 trap       #6                  ; Return unused memory to op system.
 lea        stack, a7

initialize_registers_1:
 lea        header_1, a0       
 lea        header_2, a1
 lea        cmpi_start, a3
 lea        cmpi_end, a4
 lea        heading, a5
 move.w     #50000, d7
 trap       #9

initialize_registers_2:
 lea        header_3, a0       
 lea        header_4, a1
 lea        moveq_cmp_start, a3
 lea        moveq_cmp_end, a4
 lea        heading, a5
 move.b     #0, (a5)            ; Store a NULL in first byte to create a
 move.w     #50000, d7          ; null string so that heading gets printed
 trap       #9                  ; only once.

terminate:
 trap       #8

cmpi_start:                
 cmpi.l     #0, d1
cmpi_end:

moveq_cmp_start:        
 moveq      #0, d0
 cmp.l      d0, d1  
moveq_cmp_end:

 data
heading:      dc.b       "COMPARE Program Results",$D,$A,$D,$A,0
header_1:     dc.b       "  Elapsed time for cmpi.l #d8, dn:    ",0
header_2:     dc.b       "  Memory required for first algorithm:   ",0
header_3:     dc.b $D,$A,"  Elapsed time for moveq  #d8, dm",$D,$A
              dc.b       "                   cmp.l   dm, dn:    ",0
header_4:     dc.b       "  Memory required for second algorithm:  ",0
 bss
 align
label:        ds.l  1
              ds.l 96
stack:        ds.l  0
program_end:  ds.l  0 
 end
