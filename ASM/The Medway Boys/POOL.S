start	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	move.w #$2700,sr
	clr.b $fffffa07
	clr.b $fffffa09
	lea go,a0
	lea $80000,a1
.1	move.w (a0)+,(a1)+
	cmp.l #$82000,a1
	bne.s .1
	jmp $80000
go	lea 8,a0
	lea $80000,a1
.2	clr.l (a0)+
	cmp.l a0,a1
	bne.s .2
	lea $90000,sp
incbin	l:\internal
.3	bra.s .3
