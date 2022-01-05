	move.b	#14,$ffff8800.w
	move.b	$ffff8800.w,d0
	bset	#4,d0
	move.b	d0,$ffff8802.w
	bclr	#4,d0
	move.b	#14,$ffff8800.w
	move.b	d0,$ffff8802.w
	
	