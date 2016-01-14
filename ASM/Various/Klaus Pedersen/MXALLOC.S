*	MXALLOC is written by Klaus Pedersen (micro@imada.dk), and
*	distributed, together with "NT_COMP" - the NoiseTracker Compiler
*	for Atari [MEGA] ST, STe and TT computers.
*

MXALLOC         EQU $44
MALLOC          EQU $48
GemDos          EQU 1

                GLOBL Mxalloc
                
; void *Mxalloc(long amount, int type);
;   type : 
;     0 - ST ram needed (DMA sound/ACSI/VIDEO)
;     1 - TT ram needed...
;     2 - ST ram if possible else TT...
;     3 - TT ram if possible else ST (SCSI/LAN)

; TC passes :
;   'amount' in D0.l
;   'type'   in D1.w

                TEXT

Mxalloc:        move.w   D1,-(SP)
                move.l   D0,-(SP)
                move.w   #MXALLOC,-(SP)
                trap     #GemDos
                moveq    #-$20,D1     ; Test for "Unknown Gemdos function"
                cmp.l    D1,D0
                bne.b    return

                move.w   #MALLOC,(SP) ; If no Mxalloc then use Malloc
                trap     #GemDos

return:         addq.l   #8,SP        ; Tidy stack
                movea.l  D0,A0        ; Pointers in Address regs.
                rts

                END
                