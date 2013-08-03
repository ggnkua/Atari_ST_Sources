; 48 colour demo by Galgan

	opt	x-,o+

	dc.l	$a000a00a
start:
	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.w	#6,a7
	clr.w	-(a7)
	pea	$78000
	pea	$78000
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7
	bsr.s	t
	bsr	u
main:
	movem.l	d0-d1/a5,-(a7)
	bsr	faluj
	movem.l	(a7)+,d0-d1/a5
	bsr	scroll
	bsr	g
	bsr	a
	bsr	l
	bsr	g1
	bsr	a1
	bsr	n
	bsr	n1
	bsr	equ
 	bsr	vbl
	cmp.b	#$39,$fffffc02.w
	bne.s	main
	clr.l	$4d2.w
	move.b	#$08,$fffffc02.w
	lea	save_reg(pc),a0
	move.l	(a0)+,$120.w
	move.b	(a0)+,$fffffa17.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa1b.w
	move.b	(a0)+,$fffffa21.w
	move.w	#-1,$ffff8240.w
	clr.w	$ffff8246.w
	clr.l	-(a7)
	trap	#1
	illegal
t:
	pea	$78000
	move.w	#6,-(a7)
	trap	#14
	addq.w	#6,a7
	lea	picture00(pc),a2
	lea	$7d020-$60*$a0,a3
	lea	sin,a4
	movem.l	d4/a2-a4,save_g
	lea	picture00(pc),a2
	lea	$7d030-$60*$a0,a3
	lea	sin1,a4
	movem.l	d4/a2-a4,save_a
	lea	picture00(pc),a2
	lea	$7d040-$60*$a0,a3
	lea	sin2,a4
	movem.l	d4/a2-a4,save_l
	lea	picture00(pc),a2
	lea	$7d050-$60*$a0,a3
	lea	sin3,a4
	movem.l	d4/a2-a4,save_g1
	lea	picture00(pc),a2
	lea	$7d060-$60*$a0,a3
	lea	sin4,a4
	movem.l	d4/a2-a4,save_a1
	lea	picture00(pc),a2
	lea	$7d070-$60*$a0,a3
	lea	sin5,a4
	movem.l	d4/a2-a4,save_n
	lea	picture00(pc),a2
	lea	$7d080-$60*$a0,a3
	lea	sin6,a4
	movem.l	d4/a2-a4,save_n1
	lea	picture_2(pc),a0
	lea	$78000+$60*160,a1
	move.w	#$fee/4,d7
copyr:
	move.l	(a0)+,(a1)
	addq.w	#8,a1
	dbf	d7,copyr
	rts
vbl:
;	clr.w	$ffff8240.w
	addq	#1,count
	cmp.w	#$fa,count
	bne.s	dalej
	move.l	#data,rast
	move	#0,count
dalej:
	move.l	rast,a5
	addq.l	#4,rast
	move.l	$466.w,d0
sync:
	cmp.l	$466.w,d0
	beq.s	sync
;	move.w	#-1,$ffff8240.w
	rts
picture_2:
	incbin	\data\pic2.pak
u:
	move.b	#$12,$fffffc02.w
	lea	save_reg(pc),a0
	move.l	$120.w,(a0)+
	move.b	$fffffa17.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa1b.w,(a0)+
	move.b	$fffffa21.w,(a0)+
	lea	picture(pc),a0
 	lea	$78018+8,a1
	moveq	#$17,d1
next:
	moveq	#$5f/4,d0
copy:
	move.l	(a0)+,(a1)+
	dbf	d0,copy
	lea	-$60(a1),a1
	lea	160(a1),a1
	dbf	d1,next
	lea	$78018+8,a0
	lea	save_16,a1
	moveq	#$17,d2
all:
	moveq.w	#$0f,d1
lu:
	moveq	#159/4,d0
copy_16:
	move.l	(a0)+,(a1)+
	dbf	d0,copy_16
	lea	-$a0(a0),a0
	moveq	#3,d0
	moveq	#159/8,d4
l1:
	roxr	(a0)
	addq.w	#8,a0
	dbf	d4,l1
	lea	-$a0(a0),a0
	moveq	#159/8,d4	
	addq.w	#2,a0
	dbf	d0,l1
	subq.w	#8,a0
	dbf	d1,lu
	lea	$a0(a0),a0
	dbf	d2,all
	moveq	#1,d0
	bsr	music
	and.b	#$df,$fffffa09.w
	move.l	#vbli,$4d2.w
	move.b	#64,$fffffa17.w
	stop	#$2300
	move.l	#data,rast
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d5
	rts
picture:
	dc.w	$007F,$007F,$00FF,$01FF,$FFF0,$FFF0,$FFF8,$FFFC
	dc.w	$007F,$007F,$00FF,$01FF,$FFE0,$FFE0,$FFF0,$FFF8
	dc.w	$0040,$0040,$0000,$00E0,$0000,$0000,$0000,$0000
	dc.w	$003F,$003F,$007F,$00FF,$FFF8,$FFF8,$FFFC,$FFFE
	dc.w	$003F,$003F,$007F,$00FF,$FFF0,$FFF0,$FFF8,$FFFC
	dc.w	$0040,$0040,$0000,$00E0,$00F8,$00F8,$01FC,$03FE
	dc.w	$03FF,$03FF,$01FF,$03FF,$FFF8,$FFF8,$FFFC,$FFFC
	dc.w	$03FF,$03FF,$01FF,$03FF,$FFF8,$FFF8,$FFF8,$FFFC
	dc.w	$01C0,$01C0,$00E0,$01E0,$0000,$0000,$0000,$0000
	dc.w	$01FF,$01FF,$00FF,$01FF,$FFFC,$FFFC,$FFFE,$FFFE
	dc.w	$01FF,$01FF,$00FF,$01FF,$FFFC,$FFFC,$FFFC,$FFFE
	dc.w	$01F0,$01F0,$00E0,$01F0,$01FC,$01FC,$03FE,$03FE
	dc.w	$07FF,$07FF,$07FF,$07FF,$FFFC,$FFFC,$FFFC,$FFFC
	dc.w	$07FF,$07FF,$07FF,$07FF,$FFF8,$FFF8,$FFFC,$FFFC
	dc.w	$03E0,$03E0,$03E0,$03E0,$0000,$0000,$0000,$0000
	dc.w	$03FF,$03FF,$03FF,$03FF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$03FF,$03FF,$03FF,$03FF,$FFFC,$FFFC,$FFFE,$FFFE
	dc.w	$03F8,$03F8,$03F8,$03F8,$03FE,$03FE,$03FE,$03FE
	dc.w	$0FFF,$0FFF,$0FFF,$0FFF,$FFFC,$FFFC,$FFFC,$FFFC
	dc.w	$0FFF,$0FFF,$0FFF,$0FFF,$FFFC,$FFFC,$FFFC,$FFFC
	dc.w	$07E0,$07E0,$07E0,$07E0,$0000,$0000,$0000,$0000
	dc.w	$07FF,$07FF,$07FF,$07FF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$07FF,$07FF,$07FF,$07FF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$07FC,$07FC,$07FC,$07FC,$03FE,$03FE,$03FE,$03FE
	dc.w	$1FFF,$1FFF,$1FFF,$1FFF,$FFFC,$FFFC,$FFFC,$FFFC
	dc.w	$1FFF,$1FFF,$1FFF,$1FFF,$FFFC,$FFFC,$FFFC,$FFFC
	dc.w	$0FE0,$0FE0,$0FE0,$0FE0,$0000,$0000,$0000,$0000
	dc.w	$0FFF,$0FFF,$0FFF,$0FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$0FFF,$0FFF,$0FFF,$0FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$0FFE,$0FFE,$0FFE,$0FFE,$03FE,$03FE,$03FE,$03FE
	dc.w	$3FFF,$3FFF,$1FFF,$3FFF,$FFFC,$FFFC,$FFFC,$FFFC
	dc.w	$3FFF,$3FFF,$1FFF,$3FFF,$FFFC,$FFFC,$FFFC,$FFFC
	dc.w	$1FE0,$1FE0,$0FE0,$1FE0,$0000,$0000,$0000,$0000
	dc.w	$1FFF,$1FFF,$0FFF,$1FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$1FFF,$1FFF,$0FFF,$1FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$1FFF,$1FFF,$0FFF,$1FFF,$03FE,$03FE,$03FE,$03FE
	dc.w	$3FFF,$3FFF,$3FFF,$7FFF,$FFF8,$FFF8,$FFFC,$FFFC
	dc.w	$3FFF,$3FFF,$3FFF,$7FFF,$FFFC,$FFFC,$FFFC,$FFFC
	dc.w	$1FE0,$1FE0,$1FE0,$3FE0,$0000,$0000,$0000,$0000
	dc.w	$1FFF,$1FFF,$1FFF,$3FFF,$FFFC,$FFFC,$FFFE,$FFFE
	dc.w	$1FFF,$1FFF,$1FFF,$3FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$1FFF,$1FFF,$1FFF,$3FFF,$83FE,$83FE,$83FE,$83FE
	dc.w	$3FFF,$3FFF,$7FFF,$7FFF,$FFF0,$FFF0,$FFF8,$FFFC
	dc.w	$3F80,$3F80,$7FA0,$7FC0,$03FC,$03FC,$0BFC,$07FC
	dc.w	$1FE0,$1FE0,$3FE1,$3FE3,$E000,$E000,$F000,$F800
	dc.w	$1FFF,$1FFF,$3FFF,$3FFF,$FFF8,$FFF8,$FFFC,$FFFE
	dc.w	$1FC0,$1FC0,$3FD0,$3FE0,$01FE,$01FE,$05FE,$03FE
	dc.w	$1FFF,$1FFF,$3FFF,$3FFF,$C3FE,$C3FE,$C3FE,$C3FE
	dc.w	$7FF0,$7FF0,$7FE0,$7FC0,$0000,$0000,$0000,$0000
	dc.w	$7F80,$7F80,$7FA0,$7FC0,$03FC,$03FC,$0BFC,$07FC
	dc.w	$3FE7,$3FE7,$3FFB,$3FE7,$F800,$FC00,$F800,$FC00
	dc.w	$3FF8,$3FF8,$3FF0,$3FE0,$0000,$0000,$0000,$0000
	dc.w	$3FC0,$3FC0,$3FD0,$3FE0,$01FE,$01FE,$05FE,$03FE
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$E3FE,$E3FE,$E3FE,$E3FE
	dc.w	$7FE0,$7FE0,$7FC0,$7FC0,$0000,$0000,$0000,$0000
	dc.w	$7FFF,$7FFF,$7FFF,$7FFF,$FFFC,$FFFC,$FFFC,$FFFC
	dc.w	$3FEF,$3FFF,$3FEF,$3FFF,$FC00,$FE00,$FE00,$FC00
	dc.w	$3FF0,$3FF0,$3FE0,$3FE0,$0000,$0000,$0000,$0000
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$F3FE,$F3FE,$FFFE,$F3FE
	dc.w	$7FC0,$7FC0,$7FC0,$7FC0,$0000,$0000,$0000,$0000
	dc.w	$7FFF,$7FFF,$7FFF,$7FFF,$FFFC,$FFFC,$FFFC,$FFFC
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$FC00,$FC00,$F800,$FC00
	dc.w	$3FE0,$3FE0,$3FE0,$3FE0,$0000,$0000,$0000,$0000
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$FBFE,$FFFE,$FBFE,$FFFE
	dc.w	$7FC0,$7FC0,$7FC0,$7FC0,$01F0,$01F0,$03F8,$07FC
	dc.w	$7FFF,$7FFF,$7FFF,$7FFF,$FFFC,$FFFC,$FFFC,$FFFC
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$F800,$F800,$F800,$F800
	dc.w	$3FE0,$3FE0,$3FE0,$3FE0,$00F8,$00F8,$01FC,$03FE
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$7FC0,$7FC0,$7FC0,$7FC0,$03F8,$03F8,$07FC,$07FC
	dc.w	$7FFF,$7FFF,$7FFF,$7FFF,$FFFC,$FFFC,$FFFC,$FFFC
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$F000,$F000,$F000,$F000
	dc.w	$3FE0,$3FE0,$3FE0,$3FE0,$01FC,$01FC,$03FE,$03FE
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$3FEF,$3FFF,$3FEF,$3FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$7FE0,$7FE0,$7FC0,$7FC0,$0FFC,$0FFC,$07FC,$07FC
	dc.w	$7FFF,$7FFF,$7FFF,$7FFF,$FFFC,$FFFC,$FFFC,$FFFC
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$E000,$E000,$F000,$E000
	dc.w	$3FF0,$3FF0,$3FE0,$3FE0,$07FE,$07FE,$03FE,$03FE
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$3FE7,$3FE7,$3FFF,$3FE7,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$7FF0,$7FF0,$7FE0,$7FC0,$1FFC,$1FFC,$0FFC,$07FC
	dc.w	$7FFF,$7FFF,$7FFF,$7FFF,$FFFC,$FFFC,$FFFC,$FFFC
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$C000,$E000,$D000,$E000
	dc.w	$3FF8,$3FF8,$3FF0,$3FE0,$0FFE,$0FFE,$07FE,$03FE
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$3FE3,$3FE3,$3FE3,$3FE3,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$7FFF,$7FFF,$7FFF,$7FFF,$FFFC,$FFFC,$FFFC,$FFFC
	dc.w	$7FFF,$7FFF,$7FFF,$7FFF,$FFFC,$FFFC,$FFFC,$FFFC
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$FFF8,$FFF8,$FFFC,$FFFE
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$3FE1,$3FE1,$3FE1,$3FE1,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$7FFF,$7FFF,$7FFF,$7FFF,$FFFC,$FFFC,$FFFC,$FFFC
	dc.w	$7FF0,$7FF0,$7FE0,$7FC0,$1FFC,$1FFC,$0FFC,$07FC
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$FFFC,$FFFC,$FFFE,$FFFE
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$3FF8,$3FF8,$3FF0,$3FE0,$0FFE,$0FFE,$07FE,$03FE
	dc.w	$3FE0,$3FE0,$3FE0,$3FE0,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$7FFF,$7FFF,$7FFF,$7FFF,$FFFC,$FFFC,$FFFC,$FFFC
	dc.w	$7FE0,$7FE0,$7FC0,$7FC0,$0FFC,$0FFC,$07FC,$07FC
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$3FF0,$3FF0,$3FE0,$3FE0,$07FE,$07FE,$03FE,$03FE
	dc.w	$3FE0,$3FE0,$3FE0,$3FE0,$7FFE,$7FFE,$7FFE,$7FFE
	dc.w	$7FFF,$7FFF,$7FFF,$7FFF,$FFFC,$FFFC,$FFFC,$FFFC
	dc.w	$7FC0,$7FC0,$7FC0,$7FC0,$07FC,$07FC,$07FC,$07FC
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$3FE0,$3FE0,$3FE0,$3FE0,$03FE,$03FE,$03FE,$03FE
	dc.w	$3FE0,$3FE0,$3FE0,$3FE0,$3FFE,$3FFE,$3FFE,$3FFE
	dc.w	$7FFF,$7FFF,$7FFF,$7FFF,$FFFC,$FFFC,$FFFC,$FFFC
	dc.w	$7FC0,$7FC0,$7FC0,$7FC0,$07FC,$07FC,$07FC,$07FC
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$3FE0,$3FE0,$3FE0,$3FE0,$03FE,$03FE,$03FE,$03FE
	dc.w	$3FE0,$3FE0,$3FE0,$3FE0,$1FFE,$1FFE,$1FFE,$1FFE
	dc.w	$3FFF,$3FFF,$7FFF,$7FFF,$FFF8,$FFF8,$FFFC,$FFFC
	dc.w	$7FC0,$7FC0,$7FC0,$7FC0,$07FC,$07FC,$07FC,$07FC
	dc.w	$3FFF,$3FFF,$3FFF,$3FFF,$FFFE,$FFFE,$FFFE,$FFFE
	dc.w	$1FFF,$1FFF,$3FFF,$3FFF,$FFFC,$FFFC,$FFFE,$FFFE
	dc.w	$3FE0,$3FE0,$3FE0,$3FE0,$03FE,$03FE,$03FE,$03FE
	dc.w	$3FE0,$3FE0,$3FE0,$3FE0,$0FFE,$0FFE,$0FFE,$0FFE
	dc.w	$3FFF,$3FFF,$3FFF,$7FFF,$FFF8,$FFF8,$FFF8,$FFFC
	dc.w	$3F80,$3F80,$7FC0,$7FC0,$03F8,$03F8,$07FC,$07FC
	dc.w	$1FFF,$1FFF,$3FFF,$3FFF,$FFFC,$FFFC,$FFFE,$FFFE
	dc.w	$1FFF,$1FFF,$1FFF,$3FFF,$FFFC,$FFFC,$FFFC,$FFFE
	dc.w	$1FC0,$1FC0,$3FE0,$3FE0,$01FC,$01FC,$03FE,$03FE
	dc.w	$1FC0,$1FC0,$3FE0,$3FE0,$07FC,$07FC,$03FE,$07FE
	dc.w	$0FFF,$0FFF,$1FFF,$3FFF,$FFE0,$FFE0,$FFF0,$FFF8
	dc.w	$1F00,$1F00,$3F80,$7FC0,$01F0,$01F0,$03F8,$07FC
	dc.w	$0FFF,$0FFF,$1FFF,$3FFF,$FFF8,$FFF8,$FFFC,$FFFE
	dc.w	$07FF,$07FF,$0FFF,$1FFF,$FFF0,$FFF0,$FFF8,$FFFC
	dc.w	$0F80,$0F80,$1FC0,$3FE0,$00F8,$00F8,$01FC,$03FE
	dc.w	$0F80,$0F80,$1FC0,$3FE0,$00F8,$00F8,$01FC,$03FE
	ds.b	160
faluj:
	lea	$78018+8,a1
	lea	tab(pc),a2
	lea	line(pc),a5
	move.w	(a5),d3
	lea	(a2,d3.w),a2
	addq.w	#2,(a5)
	lea	save_16,a3
	move.l	a3,a4
	moveq	#$16,d7
l2:	
	cmp.w	#-1,(a2)
	bne.s	dal
	moveq	#0,d1
	move	#0,(a5)
	lea	tab(pc),a2
dal:
	lea	(a4),a3
	add.w	(a2)+,a3
	lea	16*160(a4),a4
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	dbf	d7,l2	
	rts
tabequ:
	dc.b	16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.b	16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.b	16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.b	16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.b	16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.b	16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.b	16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.b	16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.b	16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.b	16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.b	16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.b	16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.b	16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.b	16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.b	16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.b	16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.b	16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
tab:
	dc.w	800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800
	dc.w	800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800
	dc.w	800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800
	dc.w	800,800,800,800,800,800
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,1120,1440,1600,1600,1440,1120,800
	dc.w	480,320,160,160,320,480
	dc.w	800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800
	dc.w	800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800
	dc.w	800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800
	dc.w	800,800,800,800,800,800
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	640,960,480,1120,320,1280,160,1440,0,1600	
	dc.w	0,1600,160,1440,320,1280,480,1120,640,960
	dc.w	800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800
	dc.w	800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800
	dc.w	800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800,800
	dc.w	800,800,800,800,800,800
	dc.w	-1
sin:	dc.w	160,160,160,160,160,160,160,160,160,160
	dc.w	160,160,160,160,160,160,160,160,160,160
	dc.w	-160,-160,-160,-160,-160,-160,-160,-160,-160,-160
	dc.w	-160,-160,-160,-160,-160,-160,-160,-160,-160,-160,-1
sin1:	dc.w	0
 	dc.w	160,160,160,160,160,160,160,160,160,160
	dc.w	160,160,160,160,160,160,160,160,160,160
	dc.w	-160,-160,-160,-160,-160,-160,-160,-160,-160,-160
	dc.w	-160,-160,-160,-160,-160,-160,-160,-160,-160,-160,-1
sin2:	dc.w	0,0
	dc.w	160,160,160,160,160,160,160,160,160,160
	dc.w	160,160,160,160,160,160,160,160,160,160
	dc.w	-160,-160,-160,-160,-160,-160,-160,-160,-160,-160
	dc.w	-160,-160,-160,-160,-160,-160,-160,-160,-160,-160,-1
sin3:	dc.w	0,0,0
	dc.w	160,160,160,160,160,160,160,160,160,160
	dc.w	160,160,160,160,160,160,160,160,160,160
	dc.w	-160,-160,-160,-160,-160,-160,-160,-160,-160,-160
	dc.w	-160,-160,-160,-160,-160,-160,-160,-160,-160,-160,-1
sin4:	dc.w	0,0,0,0
	dc.w	160,160,160,160,160,160,160,160,160,160
	dc.w	160,160,160,160,160,160,160,160,160,160
	dc.w	-160,-160,-160,-160,-160,-160,-160,-160,-160,-160
	dc.w	-160,-160,-160,-160,-160,-160,-160,-160,-160,-160,-1
sin5:	dc.w	0,0,0,0,0
	dc.w	160,160,160,160,160,160,160,160,160,160
	dc.w	160,160,160,160,160,160,160,160,160,160
	dc.w	-160,-160,-160,-160,-160,-160,-160,-160,-160,-160
	dc.w	-160,-160,-160,-160,-160,-160,-160,-160,-160,-160,-1
sin6:	dc.w	0,0,0,0,0,0
	dc.w	160,160,160,160,160,160,160,160,160,160
	dc.w	160,160,160,160,160,160,160,160,160,160
	dc.w	-160,-160,-160,-160,-160,-160,-160,-160,-160,-160
	dc.w	-160,-160,-160,-160,-160,-160,-160,-160,-160,-160,-1
	dc.w	0
g:
	movem.l	save_g(pc),d4/a2-a4
	move.l	a3,a6
	moveq	#$15,d7	
copy_9:
	movem.l	(a2)+,d0-d3
	movem.l	d0-d3,(a3)
	add.w	#$a0,a3
	dbf	d7,copy_9
	addq.w	#2,d4  
	move.l	a6,a3
	cmp.w   #-1,(a4,d4.w)
	bne.s	daley
	moveq	#0,d4
daley:
	add.w	(a4,d4.w),a3
	lea	picture00(pc),a2
	movem.l	d4/a2-a4,save_g
	rts
a:
	movem.l	save_a(pc),d4/a2-a4
	move.l	a3,a6
	moveq	#$15,d7	
copy_90:
	movem.l	(a2)+,d0-d3
	movem.l	d0-d3,(a3)
	add.w	#$a0,a3
	dbf	d7,copy_90
	addq.w	#2,d4
	move.l	a6,a3
	cmp.w   #-1,(a4,d4.w)
	bne.s	daley1
	moveq	#0,d4
daley1:
	add.w	(a4,d4.w),a3
 	lea	picture00(pc),a2
	movem.l	d4/a2-a4,save_a
	rts
l:
	movem.l	save_l(pc),d4/a2-a4
	move.l	a3,a6
	moveq	#$15,d7	
copy_91:
	movem.l	(a2)+,d0-d3
	movem.l	d0-d3,(a3)
	add.w	#$a0,a3
	dbf	d7,copy_91
	addq.w	#2,d4  
	move.l	a6,a3
	cmp.w   #-1,(a4,d4.w)
	bne.s	daley2
	moveq	#0,d4
daley2:
	add.w	(a4,d4.w),a3
	lea	picture00(pc),a2
	movem.l	d4/a2-a4,save_l
	rts
g1:
	movem.l	save_g1(pc),d4/a2-a4
	move.l	a3,a6
	moveq	#$15,d7	
copy_93:
	movem.l	(a2)+,d0-d3
	movem.l	d0-d3,(a3)
	add.w	#$a0,a3
	dbf	d7,copy_93
	addq.w	#2,d4  
	move.l	a6,a3
	cmp.w   #-1,(a4,d4.w)
	bne.s	daley3
	moveq	#0,d4
daley3:
	add.w	(a4,d4.w),a3
	lea	picture00(pc),a2
	movem.l	d4/a2-a4,save_g1
	rts
a1:
	movem.l	save_a1(pc),d4/a2-a4
	move.l	a3,a6
	moveq	#$15,d7	
copy_94:
	movem.l	(a2)+,d0-d3
	movem.l	d0-d3,(a3)
	add.w	#$a0,a3
	dbf	d7,copy_94
	addq.w	#2,d4  
	move.l	a6,a3
	cmp.w   #-1,(a4,d4.w)
	bne.s	daley4
	moveq	#0,d4
daley4:
	add.w	(a4,d4.w),a3
	lea	picture00(pc),a2
	movem.l	d4/a2-a4,save_a1
	rts
n:
	movem.l	save_n(pc),d4/a2-a4
	move.l	a3,a6
	moveq	#$15,d7	
copy_95:
	movem.l	(a2)+,d0-d3
	movem.l	d0-d3,(a3)
	add.w	#$a0,a3
	dbf	d7,copy_95
	addq.w	#2,d4  
	move.l	a6,a3
	cmp.w   #-1,(a4,d4.w)
	bne.s	daley5
	moveq	#0,d4
daley5:
	add.w	(a4,d4.w),a3
	lea	picture00(pc),a2
	movem.l	d4/a2-a4,save_n
	rts
n1:
	movem.l	save_n1(pc),d4/a2-a4
	move.l	a3,a6
	moveq	#$15,d7	
copy_96:
	movem.l	(a2)+,d0-d3
	movem.l	d0-d3,(a3)
	lea	$a0(a3),a3
	dbf	d7,copy_96
	addq.w	#2,d4  
	move.l	a6,a3
	cmp.w   #-1,(a4,d4.w)
	bne.s	daley6
	moveq	#0,d4
daley6:
	add.w	(a4,d4.w),a3
	lea	picture00(pc),a2
	movem.l	d4/a2-a4,save_n1
	rts
equ:
	lea	$ffff8800.w,a1
	lea	tabequ(pc),a2
	moveq	#0,d1
	moveq	#0,d4
	moveq	#0,d7
	moveq.l	#-1,d2
	moveq.l	#-2,d6
	move.w	#$a0,d3
	moveq	#$0f,d5
	moveq	#8,d4
	lea	$7d000-19*160,a0
	bsr.s	equal
	moveq	#9,d4
	moveq	#0,d1
	lea	$7d010-19*160,a0
	bsr.s	equal
	moveq	#10,d4
	moveq	#0,d1
	lea	$7d020-19*160,a0
	bsr.s	equal
	moveq	#0,d4
	moveq	#0,d1
	lea	$7d030-19*160,a0
	bsr.s	equal
	moveq	#1,d4
	moveq	#0,d1
	lea	$7d040-19*160,a0
	bsr.s	equal
	moveq	#2,d4
	moveq	#0,d1
	lea	$7d050-19*160,a0
	bsr.s	equal
	moveq	#3,d4
	moveq	#0,d1
	lea	$7d060-19*160,a0
	bsr.s	equal
	moveq	#4,d4
	moveq	#0,d1
	lea	$7d070-19*160,a0
	bsr.s	equal
	moveq	#5,d4
	moveq	#0,d1
	lea	$7d080-19*160,a0
	bsr.s	equal
	moveq	#6,d4
	moveq	#0,d1
	lea	$7d090-19*160,a0
	bsr.s	equal
	rts
equal:
	move.b	d4,(a1)
	move.b	(a1),d1
	cmp.b	#8,d4
	bge.s	plot
	move.b	(a2,d1.w),d1
plot:
	move.l	d2,(a0)
	move.l	d2,4(a0)
	move.l	d2,8(a0)
	move.l	d6,12(a0)
	sub.w	d3,a0
	dbf	d1,plot
	moveq	#15,d0
clr:
	move.l	d7,(a0)
	move.l	d7,4(a0)
	move.l	d7,8(a0)
	move.l	d7,12(a0)
	sub.w	d3,a0
	dbf	d0,clr
	rts	
vbli:
	clr.b	$fffffa1b.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.b	#1,$fffffa21.w
	move.w	#0,$ffff8240.w
	move.l	#0,$ffff8242.w
	move.w	#0,$ffff824e.w
	move.l	#hbl_0,$120.w
	move.b	#7,$fffffa1b.w
	bsr	(music+8)
	rts
picture00:
	ds.l	4
	dc.w	$02F4,$0606,$01F8,$0000,$0000,$0000,$0000,$0000
	dc.w	$0D9B,$0B9D,$079E,$0060,$0000,$0000,$0000,$0000
	dc.w	$1C02,$1403,$0C03,$03FC,$0000,$0000,$8000,$0000
	dc.w	$3408,$2C1C,$1C00,$03FF,$0000,$8000,$C000,$0000
	dc.w	$0402,$5C12,$3C0C,$03FF,$2000,$6000,$4000,$8000
	dc.w	$6414,$1C01,$3C0E,$03FF,$6000,$5000,$6000,$8000
	dc.w	$8203,$BE09,$7E06,$01FF,$1000,$3000,$2000,$C000
	dc.w	$C205,$BE05,$7E02,$01FF,$2000,$2000,$3000,$C000
	dc.w	$4200,$3E03,$7E00,$01FF,$3000,$2000,$3000,$C000
	dc.w	$4001,$3E00,$FE00,$01FF,$1000,$0000,$1000,$E000
	dc.w	$4100,$3F00,$7F00,$00FF,$3000,$2000,$3000,$C000
	dc.w	$C100,$BF00,$7F00,$00FF,$2000,$2000,$3000,$C000
	dc.w	$0081,$BF82,$7F80,$007F,$1000,$3000,$2000,$C000
	dc.w	$2000,$9F87,$7F80,$007F,$6000,$5000,$6000,$8000
	dc.w	$0044,$5FC2,$3FC0,$003F,$2000,$6000,$4000,$8000
	dc.w	$3020,$2FE0,$1FE0,$001F,$0000,$8000,$C000,$0000
	dc.w	$1422,$13E3,$0FE3,$001C,$0000,$0000,$8000,$0000
	dc.w	$0103,$08FD,$07FE,$0000,$0000,$0000,$0000,$0000
	dc.w	$0504,$0306,$00F8,$0000,$0000,$0000,$0000,$0000
	ds.b	$20
	ds.l	10
save_reg: ds.l	10
save_g:	ds.l	4
save_a:	ds.l	4
save_l:	ds.l	4
save_g1: ds.l	4
save_a1: ds.l	4
save_n:	ds.l	4
save_n1: ds.l	4
scroll:
	moveq	#0,d0
	tst.w	kolej
	bne.s	jeszcze
	clr.w	ile
	lea	(fonty+34)(pc),a1
	lea	txt(pc),a2
	lea	przesun(pc),a4
	move.w	tabble(pc),d1
	move.b	(a2,d1.w),d0
	tst.b	d0
	bne.s	c
	clr.w	kolej
	clr.w	tabble
	bra.s	scroll
c:
	move.w	#32,d1
	moveq	#08,d5
	sub.w	d1,d0
	move.w	d0,d2
	roxr.w	d5,d0
	move.w	d0,d3
	move.w	d0,d4
	roxr.w	d5,d0	
	sub.w	(a4,d0.w),d3
	add.w	d3,a1
	addq.w	#1,tabble
	move.w	#16,kolej
	move.l	a1,scan_line
jeszcze:
	lea	$78000+160*158,a0
	movea.l	scan_line,a1
	addq.l	#1,scan_line
	move.w	#160,d4
loopscr:
	rept	32
	movep.l	1(a0),d0
	movep.l	d0,(a0)
	movep.l	8(a0),d0
	movep.l	d0,1(a0)
	movep.l	9(a0),d0
	movep.l	d0,8(a0)
	movep.l	16(a0),d0
	movep.l	d0,9(a0)
	movep.l	17(a0),d0
	movep.l	d0,16(a0)
	movep.l	24(a0),d0
	movep.l	d0,17(a0)
	movep.l	25(a0),d0
	movep.l	d0,24(a0)
	movep.l	32(a0),d0
	movep.l	d0,25(a0)
	movep.l	33(a0),d0
	movep.l	d0,32(a0)
	movep.l	40(a0),d0
	movep.l	d0,33(a0)
	movep.l	41(a0),d0
	movep.l	d0,40(a0)
	movep.l	48(a0),d0
	movep.l	d0,41(a0)
	movep.l	49(a0),d0
	movep.l	d0,48(a0)
	movep.l	56(a0),d0
	movep.l	d0,49(a0)
	movep.l	57(a0),d0
	movep.l	d0,56(a0)
	movep.l	64(a0),d0
	movep.l	d0,57(a0)
	movep.l	65(a0),d0
	movep.l	d0,64(a0)
	movep.l	72(a0),d0
	movep.l	d0,65(a0)
	movep.l	73(a0),d0
	movep.l	d0,72(a0)
	movep.l	80(a0),d0
	movep.l	d0,73(a0)
	movep.l	81(a0),d0
	movep.l	d0,80(a0)
	movep.l	88(a0),d0
	movep.l	d0,81(a0)
	movep.l	89(a0),d0
	movep.l	d0,88(a0)
	movep.l	96(a0),d0
	movep.l	d0,89(a0)
	movep.l	97(a0),d0
	movep.l	d0,96(a0)
	movep.l	104(a0),d0
	movep.l	d0,97(a0)
	movep.l	105(a0),d0
	movep.l	d0,104(a0)
	movep.l	112(a0),d0
	movep.l	d0,105(a0)
	movep.l	113(a0),d0
	movep.l	d0,112(a0)
	movep.l	120(a0),d0
	movep.l	d0,113(a0)
	movep.l	121(a0),d0
	movep.l	d0,120(a0)
	movep.l	128(a0),d0
	movep.l	d0,121(a0)
	movep.l	129(a0),d0
	movep.l	d0,128(a0)
	movep.l	136(a0),d0
	movep.l	d0,129(a0)
	movep.l	137(a0),d0
	movep.l	d0,136(a0)
	movep.l	144(a0),d0
	movep.l	d0,137(a0)
	movep.l	145(a0),d0
	movep.l	d0,144(a0)
	movep.l	152(a0),d0
	movep.l	d0,145(a0)
	movep.l	153(a0),d0
	movep.l	d0,152(a0)
 	movep.l	(a1),d0
	movep.l	d0,153(a0)
	add.w	d4,a0
	add.w	d4,a1
	endr
	addq.w	#1,ile
	cmp.w	#2,ile
	bne.s	znowu
	addq.l	#6,scan_line
znowu:	subq.w	#4,kolej
	rts
hbl_0:
	movem.l	d0-d7/a1-a2,-(a7)
	clr.b	$fffffa1b.w
	move.b	#32,$fffffa21.w
	move.b	#8,$fffffa1b.w
	lea	palette(pc),a1
	lea	$ffff8240.w,a2
	movem.l	(a1),d0-d7
	movem.l	d0-d7,(a2)
	movem.l	(a7)+,d0-d7/a1-a2
	move.l	#hbl_1p,$120.w
	rte
hbl_1p:	
	movem.l	d0-d7/a1-a2,-(a7)
	clr.b	$fffffa1b.w
	move.b	#59,$fffffa21.w
	move.b	#8,$fffffa1b.w
	lea	palette2(pc),a1
	lea	$ffff8240.w,a2
	movem.l	(a1),d0-d7
	movem.l	d0-d7,(a2)
	movem.l	(a7)+,d0-d7/a1-a2
	move.l	#hbl_1,$120.w
	rte
hbl_1:	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	(a5),$ffff8242.w
	move.l	#hbl_2,$120.w
	rte
hbl_2:	move.l	4(a5),$ffff8242.w
	move.l	#hbl_3,$120.w
	rte
hbl_3:	move.l	8(a5),$ffff8242.w
	move.l	#hbl_4,$120.w
	rte
hbl_4:	move.l	12(a5),$ffff8242.w
	move.l	#hbl_5,$120.w
	rte
hbl_5:	move.l	16(a5),$ffff8242.w
	move.l	#hbl_6,$120.w
	rte
hbl_6:	move.l	20(a5),$ffff8242.w
	move.l	#hbl_7,$120.w
	rte
hbl_7:	move.l	24(a5),$ffff8242.w
	move.l	#hbl_8,$120.w
	rte
hbl_8:	move.l	28(a5),$ffff8242.w
	move.l	#hbl_9,$120.w
	rte
hbl_9:	move.l	32(a5),$ffff8242.w
	move.l	#hbl_10,$120.w
	rte
hbl_10:	move.l	36(a5),$ffff8242.w
	move.l	#hbl_11,$120.w
	rte
hbl_11:	move.l	40(a5),$ffff8242.w
	move.l	#hbl_12,$120.w
	rte
hbl_12:	move.l	44(a5),$ffff8242.w
	move.l	#hbl_13,$120.w
	rte
hbl_13:	move.l	48(a5),$ffff8242.w
	move.l	#hbl_14,$120.w
	rte
hbl_14:	move.l	52(a5),$ffff8242.w
	move.l	#hbl_15,$120.w
	rte
hbl_15:	move.l	56(a5),$ffff8242.w
	move.l	#hbl_16,$120.w
	rte
hbl_16:	move.l	60(a5),$ffff8242.w
	move.l	#hbl_17,$120.w
	rte
hbl_17:	move.l	64(a5),$ffff8242.w
	move.l	#hbl_18,$120.w
	rte
hbl_18:	move.l	68(a5),$ffff8242.w
	move.l	#hbl_19,$120.w
	rte
hbl_19:	move.l	72(a5),$ffff8242.w
	move.l	#hbl_20,$120.w
	rte
hbl_20:	move.l	76(a5),$ffff8242.w
	move.l	#hbl_21,$120.w
	rte
hbl_21:	move.l	80(a5),$ffff8242.w
	move.l	#hbl_22,$120.w
	rte
hbl_22:	move.l	84(a5),$ffff8242.w
	move.l	#hbl_23,$120.w
	rte
hbl_23:	move.l	88(a5),$ffff8242.w
	move.l	#hbl_24,$120.w
	rte
hbl_24:	move.l	92(a5),$ffff8242.w
	move.l	#hbl_25,$120.w
	rte
hbl_25:	move.l	96(a5),$ffff8242.w
	move.l	#hbl_26,$120.w
	rte
hbl_26:	move.l	100(a5),$ffff8242.w
	move.l	#hbl_27,$120.w
	rte
hbl_27:	move.l	104(a5),$ffff8242.w
	move.l	#hbl_28,$120.w
	rte
hbl_28:	move.l	108(a5),$ffff8242.w
	move.l	#hbl_29,$120.w
	rte
hbl_29:	move.l	112(a5),$ffff8242.w
	move.l	#hbl_30,$120.w
	rte
hbl_30:	move.l	116(a5),$ffff8242.w
	move.l	#hbl_31,$120.w
	rte
hbl_31:	move.l	120(a5),$ffff8242.w
	move.l	#hbl_32,$120.w
	rte
hbl_32:	move.l	124(a5),$ffff8242.w
	move.l	#hbl_33,$120.w
	rte
hbl_33:	move.l	128(a5),$ffff8242.w
	move.l	#hbl_34,$120.w
	rte
hbl_34:	move.l	132(a5),$ffff8242.w
	move.l	#hbl_35,$120.w
	rte
hbl_35:	move.l	136(a5),$ffff8242.w
	move.l	#hbl_36,$120.w
	rte
hbl_36:	move.l	140(a5),$ffff8242.w
	move.l	#hbl_37,$120.w
	rte
hbl_37:	move.l	144(a5),$ffff8242.w
	move.l	#hbl_38,$120.w
	rte
hbl_38:	move.l	148(a5),$ffff8242.w
	move.l	#hbl_39,$120.w
	rte
hbl_39:	move.l	152(a5),$ffff8242.w
	move.l	#hbl_40,$120.w
	rte
hbl_40:	move.l	156(a5),$ffff8242.w
	move.l	#hbl_41,$120.w
	rte
hbl_41:	move.l	160(a5),$ffff8242.w
	move.l	#hbl_42,$120.w
	rte
hbl_42:	move.l	164(a5),$ffff8242.w
	move.l	#hbl_43,$120.w
	rte
hbl_43:	move.l	168(a5),$ffff8242.w
	move.l	#hbl_44,$120.w
	rte
hbl_44:	move.l	172(a5),$ffff8242.w
	move.l	#hbl_45,$120.w
	rte
hbl_45:	move.l	176(a5),$ffff8242.w
	move.l	#hbl_46,$120.w
	rte
hbl_46:	move.l	180(a5),$ffff8242.w
	move.l	#hbl_47,$120.w
	rte
hbl_47:	move.l	184(a5),$ffff8242.w
	move.l	#hbl_48,$120.w
	rte
hbl_48:	move.l	188(a5),$ffff8242.w
	move.l	#hbl_49,$120.w
	rte
hbl_49:	move.l	192(a5),$ffff8242.w
	move.l	#hbl_50,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_50:	move.l	196(a5),$ffff8242.w
	move.l	#hbl_51,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_51:	move.l	200(a5),$ffff8242.w
	move.l	#hbl_52,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_52:	move.l	204(a5),$ffff8242.w
	move.l	#hbl_53,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_53:	move.l	208(a5),$ffff8242.w
	move.l	#hbl_54,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_54:	move.l	212(a5),$ffff8242.w
	move.l	#hbl_55,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_55:	move.l	214(a5),$ffff8242.w
	move.l	#hbl_56,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_56:	movem.l	a1-a2,-(a7)
	clr.b	$fffffa1b.w
	move.b	#70,$fffffa21.w
	move.b	#7,$fffffa1b.w
	lea	fonty+2,a1
	lea	$ffff8240.w,a2
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	movem.l	(a7)+,a1-a2
	move.l	#hbl_57,$120.w
	bclr	#0,$fffffa0f.w
	rte
hbl_57:
	moveq	#0,d6
	move.l	d6,$ffff8240.w
	move.l	d6,$ffff8244.w
	move.l	d6,$ffff8248.w
	move.l	d6,$ffff824c.w
	move.l	d6,$ffff8250.w
	move.l	d6,$ffff8254.w
	move.l	d6,$ffff8258.w
	move.l	d6,$ffff825c.w
	rte
data:
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$07770007
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
	dc.l	$00070777
palette:
	dc.w    $0000,$0800,$0100,$0900,$0208,$0A08,$0308,$0B08
	dc.w    $0B08,$0408,$0C08,$0508,$0D01,$0601,$0E01,$0701
palette1:
	dc.w	$0000,$0000,$0010,$0010,$0120,$0120,$0130,$09B0
	dc.w	$0130,$0240,$0240,$0250,$0250,$0260,$0360,$0370
palette2:
	dc.w    $0000,$0888,$0111,$0999,$0222,$0AAA,$0333,$0BBB
	dc.w    $0444,$0CCC,$0555,$0DDD,$0666,$0EEE,$0777,$0FFF
scan_line:
	ds.l	1
tabble:	ds.w	1
kolej:	ds.w	1
ile:	ds.w	1
line:	ds.w	1
count:	ds.w	1
rast:	ds.l	1
przesun:
	dc.w	0,$200-16,$400-32,$600-48,$800-64,$a00-80,$c00-96
	dc.w	$e00-112,$1000-128,$1200-144
	dc.w	0,16+3*160,32+6*160,48+9*160,64+12*160,80+15*160
	dc.w	96+18*160,112+21*160,128+24*160,144+27*160
	dc.w	0,16+3*160,32+6*160,48+9*160,64+12*160,80+15*160
	dc.w	96+18*160,112+21*160,128+24*160,144+27*160
	dc.w	0,16+3*160,32+6*160,48+9*160,64+12*160,80+15*160
	dc.w	96+18*160,112+21*160,128+24*160,144+27*160
	dc.w	0,16+3*160,32+6*160,48+9*160,64+12*160,80+15*160
	dc.w	96+18*160,112+21*160,128+24*160,144+27*160
	dc.w	0,16+3*160,32+6*160,48+9*160,64+12*160,80+15*160
	dc.w	96+18*160,112+21*160,128+24*160,144+27*160
txt:	
	dc.b	'    HI ATARIANS !   NOW MEGA FUCK TO ALL MOTHER FUCKERS FROM IBM AND INTEL (FUCK..., FUCK..., FUCK OFFFFF!)          '
	dc.b	'GRETINGS TO: VAT MC 68K CODER, PERVERT, ANDREAS, CIAPKI, WOJCIECH, WRONEK (THE BEST OF MUSICIANS IN POLAND !), '
	dc.b	'HENIU (BEST FRIEND), HAIL TO ALL NAPALM DEATH FANS AND ALL DEATH METAL AND GRINDCORE  MANIACS .................'
	dc.b	'                      ',0
	even
music:	incbin	a:\data\storml1.dat
	even
fonty:	incbin	a:\data\bbc_font.pi1
	even
save_16	equ *
