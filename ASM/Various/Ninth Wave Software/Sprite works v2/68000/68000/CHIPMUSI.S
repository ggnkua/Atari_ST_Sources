;
; Music players. The code here doesn't physically play the music, it
; simply installs the inbuilt player in the music itself.
;
;	~C: 'type' (tune,L:music)
;	~C:music_off()
;
; ------- Copyright Terry King Ninth Wave Software 1993-95 -------

	bra	play_bigalec
	bra	play_countzero
	bra	play_madmax
	bra	play_megatizer
	bra	play_sentry
	bra	music_off

play_bigalec
	movem.l	d1-7/a0-6,-(a7)
	moveq	#0,d6
	moveq	#4,d7
	bra.s	play
play_countzero
	movem.l	d1-7/a0-6,-(a7)
	moveq	#1,d6
	moveq	#6,d7
	bra.s	play
play_megatizer
	movem.l	d1-7/a0-6,-(a7)
	moveq	#2,d6
	moveq	#8,d7
	bra.s	play
play_sentry
	movem.l	d1-7/a0-6,-(a7)
	moveq	#3,d6
	moveq	#2,d7
	bra.s	play
play_madmax
	movem.l	d1-7/a0-6,-(a7)
	moveq	#4,d6
	moveq	#8,d7

play	move	60(a7),d5
	move.l	62(a7),a6		; music
	lea	setup(pc),a0
	move	#1,(a0)
	moveq	#0,d0
	move	d5,d0
	bsr	super_on
	movem.l	d6-7,-(a7)
	jsr	(a6)
	movem.l	(a7)+,d6-7
	lea	type(pc),a0
	move	d6,(a0)+
	move.l	a6,(a0)
	add	d7,a6
	move.l	a6,$4da.w
	bsr	super_off
	movem.l	(a7)+,d1-7/a0-6
	rts

music_off
	movem.l	d1-7/a0-6,-(a7)
	lea	setup(pc),a0
	tst	(a0)
	beq.s	.exit
	clr	(a0)
	bsr.s	super_on
	move	type(pc),d0
	lea	off_tab(pc),a0
	add	d0,d0
	move	(a0,d0.w),d0
	jsr	(a0,d0.w)
	bsr.s	super_off
.exit	movem.l	(a7)+,d1-7/a0-6
	rts
	
off_tab	dc.w	alec_off-off_tab
	dc.w	countz_off-off_tab
	dc.w	megatizer_off-off_tab
	dc.w	sentry_off-off_tab
	dc.w	madmax_off-off_tab
	
alec_off
countz_off
sentry_off
madmax_off
	lea	type(pc),a0
	move.l	2(a0),a0	; get music address
	moveq	#0,d0
	jsr	(a0)		; turn off 
	clr.l	$4da.w		; clear vbl entry
	bra.s	sound_off

megatizer_off
	lea	type(pc),a0
	move.l	2(a0),a0
	moveq	#0,d0
	jsr	4(a0)	
	clr.l	$4da.w	

sound_off
	moveq	#2,d0		; Silence soundchip
	moveq	#8,d1
.stop	move.b	d1,$ffff8800.w
	clr.b	$ffff8802.w
	addq.l	#1,d1
	dbf	d0,.stop
	rts
	
super_on
	clr.l	-(a7)
	move	#32,-(a7)
	trap	#1	
	addq.l	#6,a7
	lea	old_sp(pc),a0
	move.l	d0,(a0)
	rts
super_off
	move.l	old_sp(pc),d0
	move.l	d0,-(a7)	
	move	#32,-(a7)
	trap	#1	
	addq.l	#6,a7
	rts		

setup	ds.w	1
old_sp	ds.l	1
type	ds.w	1
	ds.l	1	