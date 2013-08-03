*
* SHRTONES.S
*
*	@super
*	 enter supervisor mode  gemdos($20)
*
*	@user
*	 returns to user mode  gemdos($20)
*
*	@waitvbl
*	 waits for a vertical blank  xbios(#37)
*
*	@waitkey
*	 waits for a keypress, no echo  gemdos(#7)
* Out	 d0.b=ascii value
*
*	@exitifkey
*	 quits if a key has been pressed
*	 gemdos(#11), gemdos(#7)
*
*	@quit
*	 terminate process  gemdos(#0)
*


@super	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,savedsp0673
	rts
savedsp0673
	ds.l	1

@user	move.l	savedsp0673,-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

@waitvbl
	move	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	rts

@waitkey
	move	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

@exitifkey
	move	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	blt	.ut
	rts
.ut	bsr	@waitkey
	move.l	#@quit,(sp)
	rts

@quit	clr	-(sp)
	trap	#1
