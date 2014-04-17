 ; Program Name: PRG_5AP.S
 ; Version 1.003

 ; Assembly Instructions:

 ;    Assemble in PC-relative mode and save with a TOS extension.

 ; Execution Note:

 ;    This program invokes custom traps which must be installed by
 ; TRAPS.PRG prior to its execution.

 ; Program Function:

 ;    This program illustrates the use of custom traps #3, #6 and #8.
 ; If the program is executed from the desktop, trap #8 will execute the
 ; wait_for_keypress algorithm, then, when a key is pressed it will execute
 ; GEMDOS function 0.

 ;    If, instead, this program is executed by typing its name on
 ; SPEEDTST.TTP's input parameter line, trap #8 will not execute the
 ; wait_for_keypress algorithm, but it will immediately execute GEMDOS
 ; function $4C.

 ;    Trap #3 returns, in D0, the value of the system clock as it is
 ; immediately after this program has been loaded.  The value in D0 is not
 ; corrupted before trap #6 is invoked, therefore, it is still valid when
 ; the trap #6 routine begins to execute.  Trap #6 saves the "after-load"
 ; value of the system clock in its own local variable, where it is available
 ; for processing during the execution of trap #8.

 ;    Trap #6 also calculates the memory occupied by this program and releases
 ; the memory not occupied by this program to the operating system.
  
fetch_load_time:              
 trap       #3                  ; Returns value of system clock in D0.
release_excess_memory:          ; Also stores after-load time in TRAPS bss.
 lea        program_end, a0     ; Put "end of program" address in A0.
 movea.l    4(a7), a1           ; Put "basepage" address in A1.
 trap       #6                  ; Calculate program size and release memory.

waste_time:
 move.l     #$1, d0
outer_loop:
 move.l     #$FDE8, d1
inner_loop:
 move.l     #$FDE8, d2
 dbra       d1, inner_loop
 dbra       d0, outer_loop

 lea        heading, a0
 bsr.s      print_string
 lea        string, a0
 bsr.s      print_string

 trap       #8                  ; Terminate.

print_string:
 pea        (a0)
 move.w     #9, -(sp)
 trap       #1
 addq.l     #6, sp
 rts

 data
heading:     dc.b 'PRG_5AP.TOS Execution Results',$D,$A,$D,$A,0
string:      dc.b '  When executed from the desktop, this program will print '
             dc.b 'this string on the',$D,$A
             dc.b '  video screen and pause for a keypress.  But, when this '
             dc.b 'program is spawned by',$D,$A
             dc.b '  SPEED_1, SPEED_2, SPEED_3 or SPEEDTST, the string will '
             dc.b 'be stored in a file ',$D,$A
             dc.b '  named PRG_5AP.DAT and the program will not pause for a '
             dc.b ' keypress.',$D,$A,0
 bss
 align
program_end: ds.l 0
 end                            ; Assembler pseudo-op.

