** Memory Controler by MARTIN LIESEN 1991 10 31
**  Written for use in EUTANASIA ((C) Martin Liesen 1990,1991)

** Handles fragmented memory but still excepts quick use of memory by
** just taking the address in MEM_END and increase MEM_END by the number
** of byte you wish to steal. Or, one can go the long way by using the
** subroutines for getting memory, that way you can use released "gaps".
** Memory anywere on the computer can be marked FREE, it don't have to
** be grabbed by GET_FRG_MEM to be able to be released by FREE_FRG_MEM.
** In fact GET_FRG_MEM steals memory from MEM_END if there is no
** fragmented memory which is big enough.

** Just call INIT_FRG_MEM at startup and your'r ready to blast off!

** There is no control whatsoever about passing memory end.. It's up to
** you to check if MEM_END passes your upper limit.
** If you happens to create more gaps than MAX_MEMFRG the programm will
** do an ILLEGAL. Just increase in MAX_MEMFRG (can't see how anybody can
** reach more than about 15-20 fragmention gaps...)



* Diagram for Example (Please check it with a debuger.. I have!)

* ++ = Free memory
* == = Gap/Fragmented Memory
* ## = Reserved Memory
*
*   ++   ##   ##   ##   ##   ##   ##   ==   ++
*   ++   ##   ##   ##   ##   ##   ##   ==   ++
*   ++   ++   ##   ##   ==   ##   ##   ##   ++
*   ++   ++   ##   ##   ==   ==   ++   ++   ++
*   ++   ++   ++   ##   ##   ##   ++   ++   ++
*   ++   ++   ++   ##   ##   ##   ++   ++   ++
*   1    2    3    4    5    6    7    8    9

*   1 Start (all Memory Free)
*   2 Reserves A $100
*   3 Reserves B $100
*   4 Reserves C $100
*   5 Free B $100
*   6 Reserves D $40  (Wrong Scale)
*   7 Free C $100
*   8 Free A $100
*   9 Free D $40

                bsr     INIT_FRG_MEM
                move.l  #$00000100,d0   ; Example creates only ONE gap.
                bsr.s   GET_FRG_MEM     ; (2)
                movea.l a0,a6
                bsr.s   GET_FRG_MEM     ; (3)
                movea.l a0,a5
                bsr.s   GET_FRG_MEM     ; (4)
                movea.l a0,a4           ; MEM_END is now MEMORY+$300

                movea.l a5,a0           ; (5) Free memory ibn the midle
                bsr     FREE_FRG_MEM    ;  MEM_END+$300, Gap of $100
                moveq   #$40,d0         ; (6) Reserve a Smaller Area ($40)
                bsr.s   GET_FRG_MEM     ;  MEM_END+$300, Gap of $C0
                movea.l a0,a3

                move.l  #$00000100,d0
                movea.l a4,a0           ; (7) Free Closest to MEM_END
                bsr.s   FREE_FRG_MEM    ;  MEM_END+$140, No Gap
                movea.l a6,a0           ; (8) Free First Taken, enlarges Gap
                bsr.s   FREE_FRG_MEM    ;  MEM_END+$140, Gap of $100

                moveq   #$40,d0         ; (9) Free the $40 Area in the middle
                movea.l a3,a0           ;  MEM_END=$0 (=MEMORY), No Gap
                bsr.s   FREE_FRG_MEM
                rts





******************************************
**     MEMORY CONTROLER  (31/10-91)
******************************************
MAX_MEMFRG      equ 64

GET_FRG_MEM:    >PART 'Get Mem From Fragment List'
* D0.L   = Amount
* Out A0 =Address to memory
*  NOTE:  * Always ask for even number of bytes
*         * This is a quite time consuming rutin, get from MEM_END if
*           time is a problem.

                movem.l d1/d5-d7/a1/a5-a6,-(a7)
                movea.l MEM_TAB_PEK(pc),a6
                move.w  #MAX_MEMFRG-1,d7

                lea     -1.w,a5         ; Address on MEM_TAB to best found
                move.l  #$7F000000,d6   ; Size of best found

.FINDSUIT:      movea.l (a6)+,a1
                move.l  (a6)+,d1
                bmi.s   .NICHT
                cmp.l   d0,d1           ; Big enough?
                blt.s   .NICHT
                cmp.l   d6,d1           ; Smaller than old best?
                bge.s   .NICHT
                move.l  d1,d6
                lea     -8(a6),a5
.NICHT:         dbra    d7,.FINDSUIT

                cmpa.l  #-1,a5
                beq.s   .NOFRAG_MEM

                movea.l (a5),a0
                move.l  4(a5),d7
                cmp.l   d7,d0
                bne.s   .CHG_FRG
                move.l  #-1,(a5)        ; FRG removed
                move.l  #-1,4(a5)
                bra.s   .MEM_DONE
.CHG_FRG:       move.l  a0,(a5)         ; Fix new FRG
                add.l   d0,(a5)
                sub.l   d0,d7
                move.l  d7,4(a5)
                bra.s   .MEM_DONE

.NOFRAG_MEM:    movea.l MEM_END(pc),a0  ; Get normal mem
                add.l   d0,MEM_END

.MEM_DONE:      movem.l (a7)+,d1/d5-d7/a1/a5-a6
                rts
                endpart
FREE_FRG_MEM:   >PART 'Free Mem and put it on FRG tab'
* A0=Start Address
* D0=Lenght
*     NOTE:  * Only free even number of bytes
*            * This routine eats time!, don't release memory in your IRQ's!

                movem.l d7/a6,-(a7)

                movea.l MEM_TAB_PEK(pc),a6
                move.w  #MAX_MEMFRG-1,d7

.FIND_FREE_FRG: tst.l   4(a6)
                bpl.s   .NOT_FREE_FRG
                move.l  a0,(a6)
                move.l  d0,4(a6)
                bsr.s   CLEAN_FRG_TAB
                bra.s   .FREE_DONE
.NOT_FREE_FRG:  addq.l  #8,a6
                dbra    d7,.FIND_FREE_FRG
                illegal

.FREE_DONE:     movem.l (a7)+,d7/a6
                rts
                endpart
CLEAN_FRG_TAB:  >PART 'Clean up FRG tab'
* This rutines finds different fragmentions that actually is
* one and links them together. It also checks if fragmented memory is
* directly linked to MEM_END and then transfares the memory to free mem.
* (that is memory above MEM_END)
* This routine is called from FREE_FRG_MEM and thereby will the MEM_TAB
* always be clean.

                movem.l d0-d1/d6-a1/a4-a6,-(a7)
                movea.l MEM_TAB_PEK(pc),a4
                movea.l a4,a6

                move.w  #MAX_MEMFRG-1,d7
.LX_1:          movea.l (a6)+,a0
                move.l  (a6)+,d0
                bmi.s   .LY_1

                adda.l  d0,a0

                cmpa.l  MEM_END(pc),a0  ; Memory just below Mem_End
                bne.s   .NOT_MEM_END
                move.l  #-1,-8(a6)
                move.l  #-1,-4(a6)
                sub.l   d0,MEM_END


.NOT_MEM_END:   movea.l a4,a5
                move.w  #MAX_MEMFRG-1,d6
.LX_2:          movea.l (a5)+,a1
                move.l  (a5)+,d1
                bmi.s   .LY_2

                cmpa.l  a1,a0
                bne.s   .LY_2

                move.l  #-1,-(a5)       ; Found a link
                move.l  #-1,-(a5)
                add.l   d1,-(a6)
                subq.l  #4,a6
                bra.s   .LX_1

.LY_2:          dbra    d6,.LX_2
.LY_1:          dbra    d7,.LX_1


                movem.l (a7)+,d0-d1/d6-a1/a4-a6
                rts
                endpart
INIT_FRG_MEM:   >PART 'Init Framgment Mem Tab'
* This Resets the Fragmented memory map

                movem.l d6-d7/a6,-(a7)
                movea.l MEM_TAB_PEK(pc),a6
                move.w  #MAX_MEMFRG-1,d7
                moveq   #-1,d6
.IN_MEM:        move.l  d6,(a6)+
                move.l  d6,(a6)+
                dbra    d7,.IN_MEM

                movem.l (a7)+,d6-d7/a6
                rts
                endpart

MEM_TAB_PEK:    dc.l MEM_TAB
MEM_END:        dc.l MEMORY

                bss
MEM_TAB:        ds.b MAX_MEMFRG*8
MEMORY:         ds.b 4*1024
                end
