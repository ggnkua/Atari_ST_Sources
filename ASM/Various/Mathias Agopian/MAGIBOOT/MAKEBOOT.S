; Installe boot secteur
	opt	x+

	move.l	#FinPrg,d0
	sub.l	#Prg,d0
	cmp.w	#452,d0
	bgt	Fin
	
	move.w	#1,-(sp)
	move.w	#0,-(sp)
	move.w	#0,-(sp)
	move.w	#1,-(sp)
	move.w	#0,-(sp)
	clr.l	-(sp)
	move.l	#buffer,-(sp)
	move.w	#8,-(sp)
	trap	#14
	lea	20(sp),sp
	
	lea	buffer,a0
	move.w	#$601c,(a0)
	move.w	#'  ',2(a0)
	move.l	#'MAGI',4(a0)
	
	lea	Prg,a1
	lea	FinPrg,a2
	lea	30(a0),a3
Bcl	move.b	(a1)+,(a3)+
	cmp.l	a1,a2
	bhi	Bcl

	clr.w	510(a0)
	lea	buffer,a1
	move.w	#$ff,d7
	moveq	#0,d0
checksum
	add.w	(a1)+,d0
	dbf	d7,checksum
	move.w	#$1234,d1
	sub.w	d0,d1
	move.w	d1,510(a0)

	move.w	#1,-(sp)
	move.w	#0,-(sp)	
	move.w	#0,-(sp)	
	move.w	#1,-(sp)	
	move.w	#0,-(sp)	
	clr.l	-(sp)
	move.l	#buffer,-(sp)
	move.w	#9,-(sp)
	trap	#14
	lea	20(sp),sp
	
Fin	clr.w	-(sp)
	trap	#1
	
	section	BSS
buffer	ds.b	512

	
	