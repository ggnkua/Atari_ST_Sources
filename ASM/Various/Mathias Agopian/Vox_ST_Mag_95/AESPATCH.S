
	.EXPORT PatchAes
	.EXPORT UnpatchAes
	.EXPORT menutree

PatchAes:
	movem.l	d0-a6,-(sp)
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,-(sp)
	move.w	#$20,-(sp)
	move.l	$88.w,oldaes
	move.l	#newaes,$88.w
	trap	#1
	addq.l	#6,sp
	movem.l	(sp)+,d0-a6
	rts

UnpatchAes:
	movem.l	d0-a6,-(sp)
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,-(sp)
	move.w	#$20,-(sp)
	move.l	oldaes,$88.w
	trap	#1
	addq.l	#6,sp
	movem.l	(sp)+,d0-a6
	rts

		dc.l	'XBRA'
		dc.l	'VOX!'
oldaes:	dc.l	0
newaes:
	cmp.w	#$c8,d0
	bne.s	.aes
	move.l	d1,a0
	cmp.w	#30,([a0])
	bne.s	.aes
	cmp.w	#1,([8,a0])
	bne.s	.aes
	move.l	([16,a0]),menutree
.aes:
	jmp		([oldaes])

			data
menutree:	dc.l	0

	