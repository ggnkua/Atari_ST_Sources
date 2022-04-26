;MUSIC BY LORD D OF CAC, THIS CODE BY CORNY OF CAC

	pea	0
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	moveq	#1,d0
	jsr	music
	move.l	#music+8,$4d2.w

	move	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	clr.l	$4d2.w
	move	#$8800,a0
	move.l	#$08000000,(a0)
	move.l	#$09000000,(a0)
	move.l	#$0a000000,(a0)
	move.b	#7,$484.w

	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr	-(sp)
	trap #1

music:	incbin	fastbeat.thk 	try the tune called harmonic.thk
