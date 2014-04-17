                dc.w        0
                dc.l        message
                dc.l        'XBRA'
                dc.l        'test'
                dc.l        0
user_trace:     cmpi.l      #-1,d0      ; Dies die erste Mîglichkeit
                sne         -(sp)       ; um die Flags richtig
                tst.b       (sp)+       ; zu setzen
                rts
message:        dc.b        'Einsprung Åber Usertrace, D0.l = -1',0
