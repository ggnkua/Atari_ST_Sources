**********************************************************
* TAO Tunes ( Jacky hat mich ja nicht in Ruhe gelassen ) *
**********************************************************
                pea     0.w
                move.w  #32,-(SP)
                trap    #1
                addq.l  #6,SP

                moveq   #1,D0
                bsr     s
                move.l  #s+4,$04E2.w

c:              cmpi.b  #$39,$FFFFFC02.w
                bne.s   c
                bsr     s
                pea     0
                trap    #1

s:              IBYTES 'M*.SND'
                END
