
;*********************************************************************
;*                                                                   *
;*     Konfiguration der Seriellen Schnittstellen                    *
;*                                                                   *
;*                                                                   *
;*      CPX-Version 0.10                   vom 17. August 1997       *
;*                                                                   *
;*      zu assemblieren mit dem Pure Assembler                       *
;*                                                                   *
;*********************************************************************


             .export   do_Rsconf                 ;" Function for calling MAPTAB.Rsconf
             .export   flush                     ;" Function for flushing input buffers


;-------------------------------------------------------------------------------------)

do_Rsconf:
             movem.l d1-d7/a0-a6, cpu_regs       ;" Save CPU registers
             move.l  (sp)+, address              ;" Save return address
             move.l  (sp)+, a0                   ;" Get address of MAPTAB
             move.l  16(a0), a0                  ;" To find Rsconf pointer
             jsr     (a0)                        ;" Call it
             clr.l   -(sp)                       ;" Push dummy address
             move.l  address, -(sp)              ;" Restore return address
             movem.l cpu_regs, d1-d7/a0-a6       ;" Restore CPU registers
             rts

;-------------------------------------------------------------------------------------)

flush:
             move.l  a0, address                 ;" Save pointer to MAPTAB
             movem.l d0-d7/a0-a6, cpu_regs       ;" Save CPU registers
flush_lp:    move.l  address, a0                 ;" Get address of MAPTAB
             move.l  0(a0), a0                   ;" To find Bconstat pointer
             clr.w   -(sp)                       ;" Pass zero on stack
             jsr     (a0)                        ;" And call Bconstat function
             addq.l  #2, sp                      ;" Stack correction
             tst.w   d0                          ;" Still byte(s) waiting ?
             beq     flush_ok                    ;" No : Done
             move.l  address, a0                 ;" Get address of MAPTAB
             move.l  4(a0), a0                   ;" To find Bconin pointer
             clr.w   -(sp)                       ;" Pass zero on stack
             jsr     (a0)                        ;" And call Bconin function
             addq.l  #2, sp                      ;" Stack correction
             jmp     flush_lp                    ;" Do loop
flush_ok:    movem.l cpu_regs, d0-d7/a0-a6       ;" Restore CPU registers
             rts

;-------------------------------------------------------------------------------------)

cpu_regs:    .ds.l   15                          ;" Save area for CPU registers
address:     .ds.l   1                           ;" Save area for pointer parameter

;-------------------------------------------------------------------------------------)

             .end
