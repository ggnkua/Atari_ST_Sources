	
	clr.w	-(a7)
	pea	-1
	pea	-1
	move.w	#5,-(a7)
	trap	#14
	add.l	#12,a7

	pea	message(pc)
	move.w	#9,-(a7)
	trap	#1
	addq	#6,a7


	move.w	#7,-(a7)
	trap	#1
	addq	#2,a7



	rts

message	dc.b	27,"E"
	dc.b	27,"Y",32+4,32+15,"BALLISTIX"
	dc.b	27,"Y",32+6,32+13,"520K VERSION"
	dc.b	27,"Y",32+8,32+7,"CRACKED, FILED AND PACKED"
	dc.b	27,"Y",32+10,32+15,"BY KRAZYK"
	dc.b	27,"Y",32+13,32+14,"BASH SPACE"
	dc.b	0
