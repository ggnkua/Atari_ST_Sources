                dc.w        0
                dc.l        0
                dc.l        'XBRA'
                dc.l        'test'
old_quit:       dc.l        0
user_quit:      movem.l     d0-a6,-(sp)
                aline       #9              ; Showm
                movem.l     (sp)+,d0-a6
                move.l      old_quit(pc),-(sp)
                rts
