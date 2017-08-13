;-------------------------------------------------------------------------------
;D7
;A4...sample_pointer
;A5...ym_table
;A6...$FF8800
;-----------------------
timer_play_fast:>PART
                move.b  (A4)+,D7        ; sample  0A|sample
                lsl.w   #3,D7           ; (0A|sample)*8
                move    USP,A5          ; ym_table
                adda.w  D7,A5
                move.l  (A5)+,(A6)
                move.l  (A5)+,D7
                movep.l D7,0(A6)
                rte
                ENDPART

