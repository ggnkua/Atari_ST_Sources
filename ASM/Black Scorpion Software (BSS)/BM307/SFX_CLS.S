*
*	THIS IS VERY TEMPORARY!!!c
*

sound_shutdown:
	tst.b	sound_on
	bne.s	.go
	rts
.go:	sf	sound_on

	move.l	sfx_VBL2+2,$70.w	; restore VBL
	move.b	#0,$ffff8901.w
	rts