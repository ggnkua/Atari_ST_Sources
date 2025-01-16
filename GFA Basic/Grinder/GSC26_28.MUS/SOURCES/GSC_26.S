* GSC 26 REPLAYER

                OPT D+

test            EQU 1

                IF test
                pea     super
                move.w  #$26,-(SP)
                trap    #14
                addq.l  #6,-(SP)

                clr.w   -(SP)
                trap    #1

super:          moveq   #0,D0           * MUSIC HAT 2 STUECKE
                jsr     music+226       * INIT MUSIC (GEHT AUCH $E2)
                move.l  #music,$04D2    * INIT VBL



m2:             move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP


                bsr.s   music+224       * MUSIC OFF

                clr.l   $04D2
                rts
                ENDC


music:          PATH 'A:\'
                IBYTES 'GSC_26.MUS'

                END
