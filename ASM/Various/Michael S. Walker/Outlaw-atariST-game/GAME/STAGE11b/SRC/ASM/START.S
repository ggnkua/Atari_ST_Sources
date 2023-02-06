*  Michael S. Walker <mwalk762@mtroyal.ca>
* 	    _    _
*        | |  | |	OUTLAW. 
*       -| |  | |- 
*   _    | |- | |
* -| |   | |  | |- 	
*  |.|  -| ||/  |
*  | |-  |  ___/ 
* -|.|   | | |
*  |  \_|| |
*   \____  |
*    |   | |- 
*        | |
*       -| |
*        |_| Copyleft !(c) 2020 All Rights Unreserved in all Federations, including Alpha Centauris.

                xref       _init,_main
                xdef       __trap_1_wl,_do_super

OS_ROM_START    equ $FC0030
OS_ROM_END      equ $FF0000
OS_RAM_START    equ $000800

MEM_CONFIG_REG  equ $FF8001
VIDEO_BASE_REG  equ $FF8201
VIDEO_SYNC_REG  equ $FF820A
VIDEO_PAL0_REG  equ $FF8240
VIDEO_REZ_REG   equ $FF8260

RAM_4M          equ $0A

VIDEO_BASE      equ $3F8000
MONO            equ $02

SUPER_STACK_TOP equ $000800
USER_STACK_TOP  equ VIDEO_BASE

start:          move.w     #$2700,sr
                reset

                move.b     #RAM_4M,MEM_CONFIG_REG

                move.l     #VIDEO_BASE,d0
                lsr.l      #8,d0
                movea.l    #VIDEO_BASE_REG,a0
                movep.w    d0,0(a0)
                clr.b      VIDEO_SYNC_REG
                move.w     #1,VIDEO_PAL0_REG
                move.b     #MONO,VIDEO_REZ_REG

                movea.l    #OS_ROM_START,a0
                move.l     #OS_ROM_END,d0
                movea.l    #OS_RAM_START,a1
reloc:          cmp.l      a0,d0
                bls.s      reloc_done
                move.l     (a0)+,(a1)+
                bra.s      reloc

reloc_done:     jmp        relocated

relocated:      movea.l    #0,a6
                movea.l    #SUPER_STACK_TOP,sp
                jsr        _init

                move.w     #$0700,sr
                movea.l    #USER_STACK_TOP,sp
                jsr        _main
                jmp        OS_ROM_START

; note: if we attempt to reboot in user mode, a privilege violation will
;       cause the CPU to vector to "start" in supervisor mode

__trap_1_wl:    move.l     6(sp),-(sp)
                move.w     8(sp),-(sp)
                trap       #1
                addq.l     #6,sp
                rts

S_BIT           equ 5
SUPER           equ $20
QUERY           equ 1

_do_super:      btst.b     #S_BIT,(sp)
                bne.s      from_super
from_user:      move.l     usp,a1
                cmpi.w     #SUPER,(a1)
                bne.s      reboot
                move.l     2(a1),d1
                beq.s      to_super
                cmp.l      #QUERY,d1
                bne.s      to_super_chng
                clr.l      d0
                rte
to_super_chng:  move.l     d1,a1
to_super:       move.l     2(sp),-(a1)
                move.w     (sp),-(a1)
                move.l     sp,d0
                addq.l     #6,d0
                movea.l    a1,sp
                bset.b     #S_BIT,(sp)
                rte
from_super:     cmpi.w     #SUPER,6(sp)
                bne.s      reboot
                cmpi.l     #QUERY,8(sp)
                bne.s      to_user
                move.l     #-1,d0
                rte
to_user:        move.l     8(sp),a1
                move.l     2(sp),-(a1)
                move.w     (sp),-(a1)
                movea.l    a1,sp
                bclr.b     #S_BIT,(sp)
                rte
reboot:         jmp        OS_ROM_START
