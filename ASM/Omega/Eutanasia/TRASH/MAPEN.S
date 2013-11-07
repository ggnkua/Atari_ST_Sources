FAST_B          equ 4

; $10 $40 $50

                movea.l BLOCKSTART(pc),a0 ; ## Temp block fix
                lea     4(a0),a0
                move.l  a0,BLOCKSTART
                move.l  a0,BLOCKPOS
                movea.l a0,a2

                movea.l BLOCKSLUT(pc),a1
                move.l  a1,d1
                move.l  a0,d0
                sub.l   d0,d1
                lsr.w   #1,d1
                movea.l a1,a3
                suba.w  d1,a3
                move.l  a3,BLOCKSLUT

ANUE:           move.w  (a0)+,d0
                cmp.w   #256,d0
                blo.s   URKA
                and.w   #255,d0
                add.w   #FAST_B,d0
                bra.s   ARAB
URKA:           cmp.b   #$40,d0
                bne.s   NOTE1
                moveq   #2,d0
NOTE1:          cmp.b   #$10,d0
                bne.s   NOTE2
                moveq   #1,d0
NOTE2:          cmp.b   #$50,d0
                bne.s   NOTE3
                moveq   #3,d0
NOTE3:

ARAB:           move.b  d0,(a2)+
                cmpa.l  a0,a1
                bne.s   ANUE
                moveq   #5*15-1,d0
HEJHEJ:         clr.l   (a2)+
                dbra    d0,HEJHEJ

                movea.l BLOCKSTART(pc),a0
                movea.l BLOCKSLUT(pc),a1
                rts


                path 'K:\'

BLOCKSTART:     dc.l MAP
BLOCKSLUT:      dc.l MAPEND
BLOCKPOS:       dc.l 0

MAP:            ibytes 'PREVIEW1.MED'
MAPEND:
                end
