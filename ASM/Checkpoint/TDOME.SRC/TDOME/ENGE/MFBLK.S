;-------------------------------------------------------------------------------
make_fade_blocks:>PART

*  DC.L $4AFC4E71


                lea     sintab,A0
                lea     mfb_sin,A1
                moveq   #30-1,D7
mfb_sinc:
                moveq   #30-1,D0
                sub.w   D7,D0
                mulu    #COS*2,D0
                divu    #30-1,D0
                and.w   #SIN_MASK,D0
                move.w  0(A0,D0.w),D0

*   muls    D0,D0
*   asl.l   #2,D0
*   swap    D0
                add.w   #$1000,D0
                move.w  D0,(A1)+

                dbra    D7,mfb_sinc

                lea     mfb_list,A6
                moveq   #32-1,D7
mfb:
                moveq   #32-1,D5
                sub.w   D7,D5
                asl.w   #2,D5

                lea     mfb_sin,A0
                lea     fade_list,A1
                moveq   #30-1,D6
mfb2:
                move.w  (A0)+,D0
                muls    D5,D0
                swap    D0
                add.w   D0,D0
                add.w   D0,D0
                bpl.s   *+2
                moveq   #0,D0
                cmp.w   #8*4,D0
                ble.s   *+2
                moveq   #8*4,D0
                move.l  0(A1,D0.w),(A6)+
                dbra    D6,mfb2

                dbra    D7,mfb

                rts
                ENDPART
;-------------------------------------------------------------------------------

