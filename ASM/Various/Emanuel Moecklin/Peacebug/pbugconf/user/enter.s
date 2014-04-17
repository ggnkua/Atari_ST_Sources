                dc.w        0
                dc.l        0
                dc.l        'XBRA'
                dc.l        'test'
old_enter:      dc.l        0
user_enter:     movem.l     d0-a6,-(sp)
                aline       #10             ; Hidem
                movem.l     (sp)+,d0-a6
                move.l      old_enter(pc),-(sp)
                rts
