 ; Program Name: DONGTRAP.S

 ; Assembly Instructions:

 ;   Assemble in PC-relative and save the assembled program with a PRG suffix.
 ; Copy DONGTRAP.PRG to the AUTO folder on the C partition of the hard disk.

 ; Program Function:

 ;   This program installs the custom trap invoke by DONGLE.ACC, the
 ; SWITCH/BACK software dongle.

program_start:                  ; Calculate program size and retain result.
 lea        program_end, a3     ; Fetch program end address.
 suba.l     4(a7), a3           ; Subtract basepage address.

enter_supervisor_mode:
 move.l    #0, -(sp)
 move.w    #$20, -(sp)          ; Function = SUPER.
 trap      #1                   ; Supervisor mode is active after TRAP.
 addq.l    #6, sp               ; D0 = SSP.

install_trap_11_routine:        ; Note: pointer = vector = pointer.
 lea        trap_11_routine, a0 ; Fetch address of trap #11 routine.
 move.l     a0, $AC             ; Store trap address at pointer address.
 
enter_user_mode:
 move.l    d0, -(sp)            ; D0 contains SSP.
 move.w    #$20, -(sp)          ; Function = SUPER.
 trap      #1                   ; User mode is active after TRAP.
 addq.l    #6, sp

relinquish_processor_control:   ; Maintain memory residency.
 move.w     #0, -(sp)           ; Exit code.
 move.l     a3, -(sp)           ; Program size.
 move.w     #$31, -(sp)         ; Function = ptermres = GEMDOS $31.
 trap       #1

trap_11_routine:
 move.w     SR, -(a7)
 move.w     #$2700, SR
 movem.l    d0-a6, -(a7)
 move.l     usp, a0
 move.l     a0, -(a7)
 lea        $D42C, a0
 jmp        (a0)

program_end:  ds.l       0
 end
