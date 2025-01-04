			move.l 	sp,sav_sp

			jmp	yeah
			
			
			rept 300
			nop
			endr
			
yeah			pea	text(pc)
			move.w  #9,-(sp)
			trap 	#1
			addq.l 	#6,sp
			
			move.l  sav_sp,sp
			
			rts
sav_sp			dc.l 0			
			
text			dc.b   "kurwa.....................................",13,10
			dc.b   "kurwa.....................................",13,10,0

			