*************************************************************************
*			PSG TRACKER V2.0 REPLAY				*
*			-----------------------				*
*									*
* Written by MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
* Date: 18th April 1992							*								*
*									*
*************************************************************************
*
* Please credit me if you use it..... TA!
*
*
*
* HISS PLAYER VERSION.....
*
*
*
*
	clr.l	-(sp)		;set super
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,old_stack

	bsr	play



here	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	bsr	stop

	move.l	old_stack,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1



play	lea	tune_data,a6
	bsr	psg_play
	move.l	a6,play_isr	;return ISR address

;	move.b	$fffffa17.w,olda17
;	move.b	$fffffa1d.w,olda1d
;	move.b	$fffffa25.w,olda25
;	move.b	$fffffa09.w,olda09
;	pea	isr
;	move.w	#0,-(sp)
;	move.w	#1,-(sp)
;	move.w	#3,-(sp)
;	move.w	#$1f,-(sp)
;	trap	#14
;	add.l	#12,sp
;	bclr	#3,$fffffa17.w	;auto ISR enable
;	bset	#4,$fffffa09.w

	move.b	$484.w,old484
	bclr	#0,$484.w
	move.l	#isr,$4d2.w

;	move.b	#$12,$fffffc02.w
;	dc.w	$a00a
	rts

stop
;		move.b	olda17,$fffffa17.w
;		move.b	olda1d,$fffffa1d.w
;		move.b	olda25,$fffffa25.w
;		move.b	olda09,$fffffa09.w
;		dc.w	$a009
;		move.b	#8,$fffffc02.w
		move.b	old484,$484.w
		clr.l	$4d2.w
;		move.w	#$2700,sr
;		bclr	#5,$fffffa07.w
;		bclr	#5,$fffffa0b.w
;		bclr	#5,$fffffa0f.w
;		bclr	#5,$fffffa13.w
;		move.w	#$2300,sr
		move.l	#$8000000,$ffff8800.w
		move.l	#$9000000,$ffff8800.w
		move.l	#$a000000,$ffff8800.w
		rts


********************************************
isr
;	addq.w	#1,count
;	cmpi.w	#$2f,count
;	bhi	.play
;	rte
.play
;	clr.w	count
	movem.l	d0-a6,-(sp)
	move.l	play_isr,a6
	jsr	(a6)
	movem.l	(sp)+,d0-a6
	rts

count	dc.w	0
********************************************





********************************************
	SECTION DATA
********************************************

psg_play	incbin	replay.psg

tune_data	incbin	A:\BLAZER.psg

*Tunes playable by this code...
* 
;	DESPAIR.PSG
;	DOZEN.PSG
;	HEROES.PSG
;	JAPANESE.PSG
;	LEAVIN.PSG
;	NINJA.PSG
;	NOWAYOUT.PSG
;	RINGSMIX.PSG
;	STREET.PSG

;RIPPED BY MUG UK...
;	BLAZER.PSG
;	BEDTIME.PSG


********************************************
	SECTION BSS
********************************************
play_isr	ds.l	1
old_stack	ds.l	1
olda09		ds.b	1
olda17		ds.b	1
olda1d		ds.b	1
olda25		ds.b	1
old484		ds.w	1
