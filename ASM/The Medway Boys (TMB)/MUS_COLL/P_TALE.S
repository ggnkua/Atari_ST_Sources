; Loader for PREHISTORIC TALE INTRO Sound
; Done by JOCHEN HIPPEL
; Ripped by JACKY of ACF/Alliance (great work!)

	pea	0
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	moveq	#1,d0
	jsr	sound
	jsr	sound+8
	move.l	#sound+4,$4d2.w

	move	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	clr.l	$4d2.w
	jsr	sound+12
	move	#$8800,a0
	move.l	#$08000000,(a0)
	move.l	#$09000000,(a0)
	move.l	#$0a000000,(a0)
	move.b	#7,$484.w

	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr	-(sp)
	trap	#1

sound:
	incbin	P_TALE.MUS
	even