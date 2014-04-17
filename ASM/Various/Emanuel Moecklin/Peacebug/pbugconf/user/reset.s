                dc.w        0
                dc.l        0
                dc.l        'XBRA'
                dc.l        'test'
old_reset:      dc.l        0
user_reset:     clr.l       $05a0.W         ; Cookie l”schen
                move.l      old_reset(pc),-(sp)
                rts
