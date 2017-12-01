	text

face	equ	0
piste	equ	15
secteur	equ	10
nbsec	equ	293

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp

	move.w	#$0,$ffff8240.w
	move.w	#$444,$ffff8246.w

	lea	code,a0
	bsr	codage

	lea	code,a0
	move.w	#nbsec,d7
	move.w	#piste,d1
	move.w	#secteur,d2
loop_sect
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#1,-(sp)		* 1 secteur
	move.w	#face,-(sp)
	move.w	d1,-(sp)		* piste
	move.w	d2,-(sp)		* secteur
	move.w	#0,-(sp)
	clr.l	-(sp)
	move.l	a0,-(sp)		* adr save
	move.w	#9,-(sp)
	trap	#$e
	lea	20(sp),sp
	movem.l	(sp)+,d0-d7/a0-a6
	lea	512(a0),a0
	addq	#1,d2
	cmp.w	#11,d2
	bne.s	go_on
	moveq	#1,d2
	addq	#1,d1
go_on
	dbra	d7,loop_sect
	clr.l	-(sp)
	trap	#1
my_vbl:
	clr.b	$ffff8260.w
	rte
old_70
	ds.l	1
codage
	move.l	8(a0),-(sp)
	lea	10(a0),a1
	move.l	a0,-(sp)
	bsr	decode
	move.l	(sp)+,a0
	move.l	(sp)+,d0
	lea	12(a0),a0
	move.l	a0,a1
	add.l	d0,a1
	lea	$100(a1),a1
	bsr	decode
	rts
decode
	movem.l	zero,d0-d7/a2-a6
	lea	crypt(pc),a3
	lea	fcrypt(pc),a4
crypt
	move.l	(a0),d1
	move.l	(a3)+,d0
	eor.l	d0,d1
	move.l	d1,(a0)+
	cmp.l	a4,a3
	ble.s	pas_fcrypt
	lea	crypt(pc),a3
pas_fcrypt
	cmp.l	a0,a1
	bge.s	crypt
	rts
fcrypt
zero
	dcb.l	16,0
code
	incbin	intro.bin
fcode