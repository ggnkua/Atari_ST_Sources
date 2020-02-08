******************************************
*  ™ffnen des unteren Rands auf ST/STE   *
******************************************

*initialise interrupt



                move.w  #3,-(SP)
                trap    #14
                addq.l  #2,-(SP)
                sub.l   #7500,D0
                clr.b   D0
                move.w  #-1,-(SP)
                move.l  D0,-(SP)
                move.l  D0,-(SP)
                move.w  #5,-(SP)
                trap    #14
                lea     10(SP),SP
                move.l  #-1,-(SP)       ;alten Vector mit Betriebssystemfunktion
                move.w  #28,-(SP)
                move.w  #5,-(SP)        ;
                trap    #13             ;Bios 5
                addq.l  #8,SP
                lea     oldvec(PC),A1
                move.l  D0,(A1)         ;alten Vector retten

                pea     nvbl(PC)
                move.w  #28,-(SP)
                move.w  #5,-(SP)
                trap    #13
                addq.l  #8,SP

                pea     interupt(PC)    ;eigenen Vector Installieren
                move.w  #190,-(SP)
                move.w  #8,-(SP)
                move.w  #1,-(SP)
                move.w  #$1F,-(SP)
                trap    #14
                lea     12(SP),SP

test:           bra.s   test


                clr.w   -(SP)
                move.l  #10000,-(SP)
                move.w  #$31,-(SP)
                trap    #1
interupt:

                move.l  D0,-(SP)
twait:          cmpi.b  #180,$FFFFFA21.w
                bne.s   twait
                andi.b  #%11111101,$FFFF820A.w
*                move.w  #1,D0
*wait:           nop
*                dbra    D0,wait
                REPT 14
                nop
                ENDR
                ori.b   #2,$FFFF820A.w  ;Syncmode
                move.l  (SP)+,D0
                move.b  #0,$FFFFFA1B.w
                bclr    #0,$FFFFFA0F.w
                rte
nvbl:
                move.l  A0,-(SP)
                lea     bildvec(PC),A0
                addq.l  #1,A0
                movea.l (SP)+,A0
                move.b  #190,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                move.l  oldvec(PC),-(SP)
                rts


oldvec:         DS.L 1
bildvec:        DS.L 1
                END
