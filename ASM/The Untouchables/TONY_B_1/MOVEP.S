; The mega MOVEP scroller routine !


_movep:	macro
	movep.l	\1(a0),d0
	movep.l	d0,\1-7(a0)
	movep.l	\1+1(a0),d0
	movep.l	d0,\1(a0)
	endm


;------------------
	pea	xxx(pc)
	move	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	
	clr	-(sp)
	trap	#1


;------------------
xxx	clr	-(sp)
	pea	-1.w
	pea	-1.w
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.b	#$12,$fffffc02.w

	move.l	#fontpal,$45a.w

	lea	text(pc),a0	; set up scroller message
	move.l	a0,scrolline
	bsr	nextlet		; init scroller

	move.l	#vbl,$70.w


scan:	cmpi.b	#57,$fffffc02.w
	bne.s	scan


exit:	move.l	#gempal,$45a.w
	move.l	#$fc06de,$70.w
	move.b	#8,$fffffc02.w
	
	rts
	

;------------------
vbl:	bsr.s	scroll
	jmp	$fc06de


;------------------
; movep byte scroller !!!!
scroll:	movem.l	d0-d1/a0-a1,-(sp)
	tst.b	times		; scrolled a letter yet?
	bne.s	.ok		; no!
	bsr	nextlet
.ok:	lea	$f8000+(160*140),a0
	move.l	fptr(pc),a1
	moveq	#24,d1
.here
	rept	2
	movep.l	1(a0),d0
	movep.l	d0,(a0)
	_movep	8
	_movep	16
	_movep	24
	_movep	32
	_movep	40
	_movep	48
	_movep	56
	_movep	64
	_movep	72
	_movep	80
	_movep	88
	_movep	96
	_movep	104
	_movep	112
	_movep	120
	_movep	128
	_movep	136
	_movep	144
	_movep	152
	move.l	(a1),d0
	movep.l	d0,153(a0)
	lea	160(a0),a0
	endr
	lea	16(a1),a1
	dbra	d1,.here
	addq.l	#4,fptr
	subq.b	#1,times
	movem.l	(sp)+,d0-d1/a0-a1
	rts

; movep byte scroller routines !
nextlet:	movem.l	d0/a0,-(sp)	; next letter routine
movelet:	move.l	scrolline(pc),a0	; address of next letter
	addq.l	#1,scrolline	; pointer to next letter
	clr.l	d0
	move.b	(a0),d0		; get char from text
	cmpi.b	#$ff,d0		; end of scroll
	bne.s	go_go
	lea	text(pc),a0	; scroll text start
	move.l	a0,scrolline	; address of letter
	move.b	(a0),d0		; get letter
go_go:	sub.l	#32,d0		; calculate font pointer
	mulu	#400,d0
	lea	font(pc),a0
	adda.l	d0,a0
	move.l	a0,fptr		; store font pointer
	move.b	#4,times
	movem.l	(sp)+,d0/a0
	rts

	

	DATA
fontpal:	dc.w	$000,$770,$760,$650,$540,$530,$310,$700
 	dc.w	$000,$777,$666,$555,$444,$555,$666,$500
text:	dc.b	"              "
	dc.b	"MOVEP SCROLLER ORIGINALLY CODED BY THE SHAOLIN MASTERS"
	DC.B	"         THIS MUCH IMPROVED VERSION BY STORMLORD!       "
	dc.b	"      WRAP..WRAP..WRAP..WRAP..WRAP..             "
	dc.b	$ff
font:	incbin	b:movep.fon
gempal:	dc.w	$777,$700,$070,$000,$007,$707,$077,$555
	dc.w	$333,$733,$373,$773,$337,$737,$377,$000

	BSS
fptr:	ds.l	1
scrolline:ds.l	1
times:	ds.b	1
