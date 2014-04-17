                DC.W        0
                dc.l        0
                dc.l        'XBRA'
                dc.l        'test'
old_switch_2:   dc.l        0
user_switch_2:  bchg        #0,$ffff8241.W
                move.l      old_switch_2(pc),-(sp)
                rts
