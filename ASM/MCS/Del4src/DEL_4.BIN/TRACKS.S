	text
	
drive	equ	0
face	equ	0
piste	equ	36
sect	equ	7
nbsec	equ	60

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp
	
	lea	code,a0

	move.w	#nbsec-1,d7
	move.w	#piste,d1
	move.w	#sect,d2
loop_sect
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#1,-(sp)		* 1 secteur
	move.w	#face,-(sp)
	move.w	d1,-(sp)		* piste
	move.w	d2,-(sp)		* secteur
	move.w	#drive,-(sp)
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
code
	incbin	a:\load2.bin