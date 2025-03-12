* GSC 28 REPLAYER

                OPT D+

test            EQU 1

                IF test
                pea     super
                move.w  #$26,-(SP)
                trap    #14
                addq.l  #6,-(SP)

                clr.w   -(SP)
                trap    #1

super:          moveq   #0,D0
                bsr.s   music                     * INIT MUSIC
                move.l  #music+32,$04D2           * INIT VBL


m2:             move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP


                bsr.s   music                     * MUSIC OFF

                clr.l   $04D2
                rts
                ENDC


music:          PATH 'A:\'
                IBYTES 'GSC_28.MUS'

                END
