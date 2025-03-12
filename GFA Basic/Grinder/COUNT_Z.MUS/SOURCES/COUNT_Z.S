* COUNT ZERO MUSIC REPLAYER

                OPT D+

test            EQU 1

                IF test
                pea     super
                move.w  #$26,-(SP)
                trap    #14
                addq.l  #6,-(SP)

                clr.w   -(SP)
                trap    #1

super:          moveq   #1,D0           * MUSIC NUMMER
                bsr     music           * INIT MUSIC
                move.l  #music+6,$04D2  * INIT VBL



m2:             move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP


                bsr.s   music+2         * MUSIC OFF

                clr.l   $04D2
                rts
                ENDC


music:          PATH 'A:\'
                IBYTES 'COUNT_Z2.MUS'

                END
