	lea	0(a5),a5			; $4BED

	move.b	(a1)+,0(a0)			; $1159
	move.b	(a1),0(a0)			; $1151
	move.b	d0,0(a0)			; $1140
	move.b	1(a1),2(a0)			; $1169
	addq.w	#1,a1				; $5249

	nop

	move.b	(a1)+,0(a6)			; $1D59
	move.b	(a1),0(a6)			; $1D51
	move.b	d0,0(a6)			; $1D40
	move.b	1(a1),2(a6)			; $1D69

	nop

	move.b	(a5)+,0(a6)			; $1D5D
	move.b	(a5),0(a6)			; $1D55
	move.b	1(a5),2(a6)			; $1D6D
	addq.w	#1,a5				; $524D
