;	This routine fills a square on the screen...
;	It's not very fast, it can be optimized a lot.
;
;	Feel free to use this source.
;
;	If you want to contact with me then write to:
;
;	Fredrik Egeberg
;	Hasselgatan 22
;	614 33 S”derk”ping
;	SWEDEN
;
;
;	Code by Deez!!!

start	clr.l	-(sp)			; Enter Supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#2,sp
	move.l	d0,super
	bclr	#0,$484.w		; Get rid of the fuckin' keyclick
	dc.w	$a00a			; Hide mousepointer

	move.w	#0,-(sp)
	move.l	#$78000,-(sp)
	move.l	#$78000,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	move.l	#$70000,a1		; Erase both screens
	jsr	clr_scr
	move.l	#$78000,a1
	jsr	clr_scr

	movem.l	$ff8240,d0-d7		; Install new palette
	movem.l	d0-d7,oldpal
	movem.l	palett,d0-d7
	movem.l	d0-d7,$ff8240

main	jsr	square
	clr.w	$ff8240
	jsr	waitvbl
	move.w	#$400,$ff8240
	cmp.b	#1,$fffc02		; Somebody pressed <ESC>?
	bne.s	main			; If not so back to Main

restore	movem.l	oldpal,d0-d7		; Restore old palette
	movem.l	d0-d7,$ff8240

	move.l	super,-(sp)		; Back into User mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)			; Quit program
	trap	#1

;	Here are all the subroutines

waitvbl	move.w	#37,-(sp)		; Wait for Vertical Blank
	trap	#14
	addq.l	#2,sp
	rts

square	move.l	screen,a1
	move.w	yp1,d0
	move.w	yp2,d1
	cmp.w	d0,d1
	bgt.s	no_chg1
	exg.l	d0,d1
	move.w	d1,yp2
	move.w	d0,yp1
no_chg1	move.w	xp1,d0
	move.w	xp2,d1
	cmp.w	d0,d1
	bgt.s	no_chg2
	exg.l	d0,d1
no_chg2	move.w	d0,d2
	move.w	d1,d5
	and.w	#$000f,d0
	and.w	#$000f,d1
	and.w	#$fff0,d2
	and.w	#$fff0,d5
	asr.w	d2
	asr.w	d5
	move.w	#$ffff,d3
	move.w	#%1000000000000000,d4
	lsr.w	d0,d3
	asr.w	d1,d4
	move.w	d5,d6
	move.w	yp1,d0
	mulu.w	#160,d0
	add.w	d0,a1
	move.w	yp2,d1
	sub.w	yp1,d1
	move.l	a1,a2
	move.w	d1,d0
.line1	or.w	d3,(a1,d2)
	or.w	d4,(a1,d6)
	and.w	d3,(a1,d2)
	and.w	d4,(a1,d6)
	lea.l	160(a1),a1
	dbra	d1,.line1
	move.l	a2,a1
	add.w	d2,a1
	move.l	a1,a2
	move.w	d0,d3
	sub.w	d2,d5
	asr.w	#3,d5
	subq.w	#2,d5
	blt.s	no_more
	move.w	d5,d0
	move.w	#$ffff,d7
.line3	move.w	d0,d5
.line2	lea.l	8(a1),a1
	move.w	d7,(a1)
	dbra	d5,.line2
	lea.l	160(a2),a2
	move.l	a2,a1
	dbra	d3,.line3
no_more	rts

clr_scr	move.w	#40*200,d0		; Clear whole screen,
clr	clr.l	(a1)+			; all 4 bitplanes
	dbra	d0,clr
	rts

	section	data
super	dc.l	0
screen	dc.l	$78000
xp1	dc.w	0			; coords...
yp1	dc.w	0
xp2	dc.w	320
yp2	dc.w	200
palett	dc.w	$000,$777,$555,$444,$222,$555,$666,$777
	dc.w	$007,$017,$027,$037,$047,$057,$067,$777

	section	bss
oldpal	ds.l	8
