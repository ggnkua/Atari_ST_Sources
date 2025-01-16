* MADMAX DIGIDRUM REPLAYER

                opt D+

test            equ 1

                if test
                pea     super
                move.w  #$26,-(sp)
                trap    #14
                addq.l  #6,-(sp)

                clr.w   -(sp)
                trap    #1

super:          moveq   #1,d0
                bsr.s   music+8         * INIT MUSIC
                moveq   #1,d0
                bsr.s   music           * INIT DIGIDRUMS
                move.l  #music+4,$04d2  * INIT VBL


m2:             move.w  #7,-(sp)
                trap    #1
                addq.l  #2,sp


                bsr.s   music+$0c

                clr.l   $04d2
                rts
                endc


music:          path 'A:\'
                ibytes 'DEATH.MUS'

                end
