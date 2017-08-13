
TDLAVA_YW       EQU 44

TD_LAVA_POS     EQU 268-TDLAVA_YW

copy_td_lava:
                lea     td_lava+34,A0
                adda.l  #(200-TDLAVA_YW)*160,A0
                movem.l screen0,A1-A2

                move.w  #268-TDLAVA_YW,D0 ; linepos
                mulu    #160,D0
                adda.l  D0,A1
                adda.l  D0,A2

                moveq   #TDLAVA_YW-1,D6
ctdl_y:
                REPT 160/16
                movem.l (A0)+,D0-D3
                movem.l D0-D3,(A1)
                movem.l D0-D3,(A2)
                lea     16(A1),A1
                lea     16(A2),A2
                ENDR
                dbra    D6,ctdl_y
                rts

