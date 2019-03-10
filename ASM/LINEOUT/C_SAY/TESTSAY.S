ENGLISH:=	1

; set supervisor
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1

; set rate and pitch
	move.w	#70,-(sp)
	bsr	set_rate
	addq	#2,sp
	move.w	#120,-(sp)
	bsr	set_pitch
	addq	#2,sp

	ifne	ENGLISH

; convert english to phonetic text..
	lea	english_txt(pc),a0
	movea.l	a0,a1
	bsr	TEXTIN

; say phonemes..
	pea	PHOBUFF
	move.w	#1,-(sp)
	bsr	say
	addq	#6,sp

	else

; say something..
	pea	txt(pc)
	move.w	#1,-(sp)
	bsr	say	
	addq	#6,sp

	endc

; wait till ready..
loop:	move.w	#3,-(sp)
	bsr	say
	addq	#2,sp
	tst.b	d0
	bne.s	loop

	clr.w	-(sp)
	trap	#1

english_txt:
	dc.b	"aTaRi RulEs",0 ;blablabla atari rules",0
txt:	dc.b	"AY AY AY SAY SAY SAY FAY FAY SHAYT",0
	even

	include sayspl.s

