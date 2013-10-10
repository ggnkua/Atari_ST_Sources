start	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	move.l d0,old
	lea dump,a0
	lea $7f230,a1
.1	move.w (a0)+,(a1)+
	cmp.l #end,a0
	bne.s .1
	move.w #$6004,$7f2c8
	move.w #$6004,$7f2fa
	move.w #$ffff,d7
	lea buffer,a6
	moveq #0,d1
.2	move.w d1,d0
	lea var1,a0
	lea var2,a1
	jsr $7f31e
	move.b d0,(a6)+
	addq.w #1,d1
	dbf d7,.2
	move.l old,-(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	clr.w -(sp)
	trap #1
	
var1	dc.l space
var2	dc.l $fb0000
old	dc.l 0	
dump	incbin l:\7f230
end	ds.l 20
space	ds.l 10
buffer	ds.l $8000
