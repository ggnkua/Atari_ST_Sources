 ; Program Name: PRG_2CC.S
 ;      Version: 1.002

 ; Assembly Instructions:

 ;     Assemble in Relocatable mode and save with a TOS extension.

 ; Execution Instructions:

 ;     Execute program SPEEDTST.TTP and type PRG_2CC.TOS on the input
 ; parameter line.  SPEEDTST.TTP will produce a data file named PRG_2CC.DAT
 ; on disk.  You will be able to compare the data for this program to that
 ; produced for programs PRG_2CP.TOS and PRG_2CR.TOS.

 ; Program Function:

 ;     Statements within a nested loop structure are executed 50,000 times
 ; so that the load and execution time of this program can be compared with
 ; similar programs assembled in the PC-relative and Relocatable modes.
    
store_after_load_time:
 trap       #3                  ; Returns value of system clock in D0. 
 lea        after_load_time(pc), a0   
 move.w     d0, (a0)

 move.w     #9, d1              ; Initialize outer loop counter.
outer_loop:                     ; Loop ten times.
 move.w     #49999, d0          ; Initialize inner loop counter.
inner_loop:                     ; Loop 50,000 times.
 move.l     #label, a0          ; Can't use (pc) here.
 lea        label(pc), a0   
 move.l     label(pc), a0
 move.l     #label, -(sp)       ; Can't use (pc) here.
 pea        label(pc)
 move.l     label(pc), -(sp)
 lea        $C(sp), sp          ; Reposition stack pointer to top of stack.
 dbra       d0, inner_loop      ; Loop back until D0 = -1.
 dbra       d1, outer_loop      ; Loop back until D1 = -1.

terminate:
 move.w    after_load_time(pc), -(sp) ; Pass after load time to SPEEDTST.TTP.
 move.w     #$4C, -(sp)               ; Function = p_term = GEMDOS $4C.
 trap       #1        

 data

 ; NOTE: Below, the variable "label" is supposed to be a pointer to the
 ;       variable "after_load_time".  If this program is assembled in
 ;       Relocatable mode, the "run time" address of "after_load_time" will be
 ;       stored in the 4 bytes declared at "label" when the program is loaded
 ;       from disk to ram.

 ;       But, if the program is assembled in PC-relative mode, the "run time"
 ;       address will not be stored there; instead, the "assembly time" address
 ;       will be stored in the 4 bytes.  That is undesirable.
 
label:           dc.l after_load_time     ; This works for COMBO assembly.
 bss
after_load_time: ds.w 1
 end
