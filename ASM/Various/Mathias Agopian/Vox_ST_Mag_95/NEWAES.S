
	.EXPORT menutree
	.EXPORT oldaes
	.EXPORT newaes

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

	