; d0 contains  0RRR0GGG0BBB .w
; convert to true colour word.
convcol:        move.l d2,-(sp)
.do_r:          move.w  D6,D2
                and.w   #$0700,D2
                lsl.W   #5,D2
                move.w   D2,D7
.do_g:          move.w  D6,D2
                and.w   #$70,D2
		lsl.w	#4,d2
                or.w    D2,D7
.do_b:          and.w   #$07,D6
                lsl.w   #2,D6
                or.w    D6,D7
		move.l (sp)+,d2
                rts

