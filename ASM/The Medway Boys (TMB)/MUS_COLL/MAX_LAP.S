*************************************
*  Use this routine to play all the *
*  LAP,MAD MAX and AN COOL tunes!   *
*************************************
  
	pea	0
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	moveq	#1,d0
	jsr	sound
	move.l	#sound+8,$4d2.w

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

sound:
	incbin	MAX_1.MUS; MADMAX 1-32  ANCOOL 1-2  LAP 1-5 
	even