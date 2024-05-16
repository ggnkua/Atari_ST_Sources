	lea	buf,a0
	move.l	#64<<16/48,d0
	clr.w	d1
	clr.w	d2
	moveq	#33-1,d7
loop:	move.w	#$1159,(a0)+			; move.b (a1)+,x(a0)
	move.w	d2,(a0)+
	add.w	d0,d1
	bcc.s	.skip
	move.w	#$5249,(a0)+			; addq.w #1,a1
.skip:	addi.w	#160,d2
	dbf	d7,loop


	clr.w	-(sp)
	trap	#1

	bss

buf:	ds.l	10000




;	move.b	(a1)+,0(a0)			; $1159
;	move.b	d0,0(a0)			; $1140
;	move.b	1(a1),2(a0)			; $1169
;	addq.w	#1,a1				; $5249
