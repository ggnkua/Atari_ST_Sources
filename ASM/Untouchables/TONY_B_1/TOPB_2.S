; top border using timer a
; tony B!

; set up following as usual .....

timer_a	clr.b	$fffffa19.w
	clr.b	$ffff820a.w
	rept	80
	nop
	endr
	move.b	#2,$ffff820a.w
	bclr	#5,$fffffa0f.w
	rte

**
newvbl:	clr.b	$fffffa19.w	; set timer A
	move.b	#104,$fffffa1f.w
	move.b	#4,$fffffa19.w
	rte


**
install	move.l	#vbl,$70.w	;etc.......
	move.l	#timer_a,$134.w
	bset	#5,$fffffa07.w	; timer A on
	bset	#5,$fffffa13.w
