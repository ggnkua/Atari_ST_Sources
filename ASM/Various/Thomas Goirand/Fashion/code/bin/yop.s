	text
	move.l	#super_texte,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	XREF	wait_key
	bsr	wait_key

	clr	-(sp)
	trap	#1

	data
super_texte	dc.b	"Super le texte !",10,13,0
