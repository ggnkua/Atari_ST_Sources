* RESIDENT RESET PROGRAM

; (Originally done when I was in Blue Harvest. Now I'm in Digitech!)

; Stays in memory and displays pic and plays music upon reset.
; Press space to reset again.
; You can run this in devpac by setting RUN_DEVPAC to 1. Otherwise,
; nothing will happen, but when you press reset it will....
; All code here is by AGRAJAG. Credit me if you use it!

; Quite obviously this is not exactly Falcon compatible!

; (c) Agrajag October 1992.

RUN_DEVPAC	equ	1	0 = run on reset, 1 = run from Devpac

start	pea	0			into supervisor mode
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,d7			save stack
	bsr	saveints		save old interrupts
	IFEQ	RUN_DEVPAC
	move.l	#reset,$42a.w		my routine in reset vector
	move.l	#$31415926,$426.w	validate it
	move.l	d7,-(sp)		old stack
	move	#$20,-(sp)
	trap	#1			into normal mode.
	addq.l	#6,sp
	move.l	#end_code,d0		get end of program.
	move.l	4(a7),d1		get start of program.
	sub.l	d1,d0			now d0 = length of program
	clr	-(sp)
	move.l	d0,-(sp)		keep program length in memory.
	move	#$31,-(sp)		KEEP PROCESS
	trap	#1			program exits, but still in memory!
	ELSE
	bclr	#0,$484.w
	move.l	d7,ustack
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,cols
	ENDC

* This is the routine we go to when reset is pressed.

reset	move.b	#2,$ffff820a.w		best to do 50hz on a vbl - avoids sync errors
	lea	agrastack,a7		new stack is set
	move	#$2700,sr		all interrupts off (probably are anyway!)
	IFEQ	RUN_DEVPAC
	move.b	#$48,$fffffa17.w	re-enable interrupts
	bsr	retints			restore old vectors
	clr.l	$426.w			next reset is normal one
	ENDC
	moveq	#0,d0
	move.l	d0,d1
	move.l	d1,d2
	move.l	d2,d3
	move.l	d3,d4
	move.l	d4,d5
	move.l	d5,d6
	move.l	d6,d7
	movem.l	d0-d7,$ffff8240.w	no colours on screen yet
	lea	pic+$22,a5		degas pic
	move.l	$ffff8200.w,d1
	lsl.w	#8,d1
	move.l	d1,a1
	move.l	a1,a6
	IFNE	RUN_DEVPAC
	move.l	a1,d1
	clr	-(sp)
	pea	(a1)
	pea	(a1)
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	ENDC
	move.l	#($7d00/4)-1,d0
.loop	move.l	(a5)+,(a6)+		copy onto screen
	dbf	d0,.loop
	moveq	#0,d0
	bsr	music
	move.l	#vbl,$70.w		Don't need to save $70.w
	move	#$2300,sr		all interrupts on!
.key	cmp.b	#$39,$fffffc02.w	Wait for space bar....
	bne.s	.key
	IFEQ	RUN_DEVPAC
	move.l	4,a0
	jmp	(a0)			Reset!
	ELSE
	move	#$2700,sr
	bsr	retints
	move	#$2300,sr
	bset	#0,$484.w
	lea	$ffff8800.w,a0
	move.l	#$08080000,(a0)		clear channel A
	move.l	#$09090000,(a0)		clear channel B
	move.l	#$0a0a0000,(a0)		clear channel C
	movem.l	cols,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	ustack,-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	clr	-(sp)
	trap	#1
	
ustack	ds.l	1
cols	ds.l	8
	ENDC

vbl
	IFEQ	RUN_DEVPAC
	pea	(a0)			only a0 needs saving
	ELSE
	movem.l	d0-a6,-(sp)
	ENDC
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240		display pic colours
	bsr	music+8			play music
	IFEQ	RUN_DEVPAC
	move.l	(sp)+,a0
	ELSE
	movem.l	(sp)+,d0-a6
	ENDC
	rte

* Saves all the vectors.

saveints
	lea	vars,a0
	move.l	#16-1,d0
	lea	$fffffa07,a1
.loop	move.b	(a1)+,(a0)+
	addq.l	#1,a1
	dbf	d0,.loop
	move.l	$70,(a0)+
	move.l	$68,(a0)+
	move.l	$118,(a0)+
	move.l	$120,(a0)+
	move.l	$134,(a0)+
	rts

* Restores them.

retints
	lea	vars(pc),a0
	move.l	#16-1,d0
	lea	$fffffa07,a1
.loop	move.b	(a0)+,(a1)+
	addq.l	#1,a1
	dbf	d0,.loop
	move.l	(a0)+,$70
	move.l	(a0)+,$68
	move.l	(a0)+,$118
	move.l	(a0)+,$120
	move.l	(a0)+,$134
	rts

vars		ds.b	16
		ds.l	5

pic		incbin	hello.pi1		can be any degas pic
	even
music		incbin	blueh1.mus		can be any music

	even

* My own stack.

		ds.l	50 
agrastack	ds.l	1

end_code	; need this to find length of program.
