
;**************************************
;* get_zufall_256
;**************************************

; gebrauchte register werden gerettet ...
; rueckgabe: d1.b : Zufallszahl zwischen 0 und 255

get_zufall_256
		move.l	a0,-(sp)
		lea	zuf256_pos,a0
		move.w	(a0),d1
		addq.b	#1,d1
		move.w	d1,(a0)
		lea	zufall_256_tab,a0
		moveq	#0,d1
		move.b	(a0,d1.w),d1
		movea.l	(sp)+,a0

		rts



