 ; Program Name: PRG_2CP.S
 ;      Version: 1.002
 ; Assembly Instructions:

 ;     Assemble in PC-relative mode and save with a TOS extension, then
 ; change the name to PRG_2CR, assemble in Relocatable mode and save as
 ; PRG_2CR.TOS.  This will allow you to prepare two object code files from
 ; the same source file.

 ; Execution Instructions:

 ;     Execute program SPEEDTST.TTP and type PRG_2CP.TOS on the input
 ; parameter line.  SPEEDTST.TTP will produce a data file named PRG_2CP.DAT
 ; on disk.  You will be able to compare the data for this program to that
 ; produced for programs PRG_2CC.TOS and PRG_2CR.TOS.

 ;     Do the same with PRG_2CR.TOS to produce a data file named PRG_2CR.DAT.
 ; You can view the DAT files with an editor, from the desktop using the Show
 ; function or by printing them.

 ; Program Function:

 ;     Statements within a nested loop structure are executed 50,000 times
 ; so that the load and execution time of this program can be compared with
 ; similar programs assembled in the Relocatable and Combo modes.

store_after_load_time:
 trap       #3                  ; Returns value of system clock in D0.      
 lea        after_load_time, a0 
 move.w     d0, (a0)            ; Store time in variable "after_load_time".

 move.w     #9, d1              ; Initialize outer loop counter.
outer_loop:                     ; Loop ten times.
 move.w     #49999, d0          ; Initialize inner loop counter.
inner_loop:                     ; Loop 50,000 times.
 move.l     #label, a0
 lea        label, a0   
 move.l     label, a0
 move.l     #label, -(sp)
 pea        label
 move.l     label, -(sp)
 lea        $C(sp), sp          ; Reposition stack pointer to top of stack.
 dbra       d0, inner_loop      ; Loop back until D0 = -1.
 dbra       d1, outer_loop      ; Loop back until D1 = -1.

terminate:
 move.w     after_load_time, -(sp) ; Pass after load time to SPEEDTST.TTP.
 move.w     #$4C, -(sp)            ; Function = p_term = GEMDOS $4C.
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

label:     dc.l after_load_time ; This does not give desired response for
 bss                            ; PC-relative assembly, it works for
after_load_time: ds.w 1         ; Relocatable assembly.
 end
