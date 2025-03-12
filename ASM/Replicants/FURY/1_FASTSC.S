	bra	nodebug
	pea	0
	move	#$20,-(a7)
	trap	#1
	addq	#6,a7
	
	move	#$777,$ffff8240.w
	
	pea	0
	trap	#1

screen	equ	$f8000
	
	opt	d+
	
	text
	
nodebug	pea	0
	move	#$20,-(a7)
	trap	#1
	addq	#6,a7
	
	clr.b	$ffff8260.w
	move.l	#screen,d0
	lea	$ffff8200.w,a0
	lsr.l	#8,d0
	movep	d0,1(a0)
	
main	move	#$25,-(a7)
	trap	#14
	addq	#2,a7
	
	move	#1000,d0
aa	dbra	d0,aa

	clr	$ffff8240.w
		
	bsr	scroller
	
	move	#$777,$ffff8240.w
	
	cmp.b	#$39,$fffffc02.w
	bne.s	main
	
	clr	$ffff8246.w
	
	pea	0
	trap	#1

speed_scroll	equ	1
scroller
	lea	c_buf,a0
	cmp.l	#(16/speed_scroll),(a0)
	blt.s	.ca_roule
	addq.l	#1,pos
.ca_roule
	and.l	#(16/speed_scroll)-1,(a0)
	move.l	(a0),d0
	addq.l	#1,(a0)
	lea	t_buf,a0
	add.l	d0,d0
	add.l	d0,d0
	move.l	0(a0,d0.l),a0
	lea	(a0),a2

	lea	pos,a0
	cmp.l	#20,(a0)
	bge	raz_pos
	bra	suite_pos
raz_pos	move.l	#0,(a0)
suite_pos
	move.l	(a0),d0
	add.l	d0,d0
	add.l	d0,d0
	lea	scroll,a0
	move.l	0(a0,d0),a6
	move.l	a2,a0
	move.l	a0,d7
	jsr	(a6)

	rts

pos	dc.l	0

scr0	lea	screen,a1
	move	#32-1,d0
off	set	0
.scr0	
off	set	0
	rept	20
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	add.l	#160,a1
	dbra	d0,.scr0
	jsr	decal_letter
	rts

scr1	lea	screen,a1
	addq.l	#2,a0
	move	#32-1,d0
off	set	0
.scr1	rept	19
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	-40(a0),a0
	move.w	(a0)+,off(a1)
off	set	off+8
	lea	40(a0),a0
	lea	160(a1),a1
	dbra	d0,.scr1
	jsr	decal_letter
	rts

scr2	lea	screen,a1
	addq.l	#4,a0
	move	#32-1,d0
off	set	0
.scr2	rept	18
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	-40(a0),a0
	rept	2
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	40(a0),a0
	lea	160(a1),a1
	dbra	d0,.scr2
	jsr	decal_letter
	rts

scr3	lea	screen,a1
	add.l	#6,a0
	move	#32-1,d0
off	set	0
.scr3	rept	17
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	-40(a0),a0
	rept	3
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	40(a0),a0
	lea	160(a1),a1
	dbra	d0,.scr3
	jsr	decal_letter
	rts

scr4	lea	screen,a1
	add.l	#8,a0
	move	#32-1,d0
off	set	0
.scr4	rept	16
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	-40(a0),a0
	rept	4
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	40(a0),a0
	lea	160(a1),a1
	dbra	d0,.scr4
	jsr	decal_letter
	rts

scr5	lea	screen,a1
	add.l	#10,a0
	move	#32-1,d0
off	set	0
.scr5	rept	15
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	-40(a0),a0
	rept	5
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	40(a0),a0
	lea	160(a1),a1
	dbra	d0,.scr5
	jsr	decal_letter
	rts

scr6	lea	screen,a1
	add.l	#12,a0
	move	#32-1,d0
off	set	0
.scr6	rept	14
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	-40(a0),a0
	rept	6
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	40(a0),a0
	lea	160(a1),a1
	dbra	d0,.scr6
	jsr	decal_letter
	rts

scr7	lea	screen,a1
	add.l	#14,a0
	move	#32-1,d0
off	set	0
.scr7	rept	13
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	-40(a0),a0
	rept	7
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	40(a0),a0
	lea	160(a1),a1
	dbra	d0,.scr7
	jsr	decal_letter
	rts

scr8	lea	screen,a1
	add.l	#16,a0
	move	#32-1,d0
off	set	0
.scr8	rept	12
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	-40(a0),a0
	rept	8
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	40(a0),a0
	lea	160(a1),a1
	dbra	d0,.scr8
	jsr	decal_letter
	rts

scr9	lea	screen,a1
	add.l	#18,a0
	move	#32-1,d0
off	set	0
.scr9	rept	11
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	-40(a0),a0
	rept	9
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	40(a0),a0
	lea	160(a1),a1
	dbra	d0,.scr9
	jsr	decal_letter
	rts

scr10	lea	screen,a1
	add.l	#20,a0
	move	#32-1,d0
off	set	0
.scr10	rept	10
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	-40(a0),a0
	rept	10
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	40(a0),a0
	lea	160(a1),a1
	dbra	d0,.scr10
	jsr	decal_letter
	rts

scr11	lea	screen,a1
	add.l	#22,a0
	move	#32-1,d0
off	set	0
.scr11	rept	9
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	-40(a0),a0
	rept	11
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	40(a0),a0
	lea	160(a1),a1
	dbra	d0,.scr11
	jsr	decal_letter
	rts

scr12	lea	screen,a1
	add.l	#24,a0
	move	#32-1,d0
off	set	0
.scr12	rept	8
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	-40(a0),a0
	rept	12
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	40(a0),a0
	lea	160(a1),a1
	dbra	d0,.scr12
	jsr	decal_letter
	rts

scr13	lea	screen,a1
	add.l	#26,a0
	move	#32-1,d0
off	set	0
.scr13	rept	7
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	-40(a0),a0
	rept	13
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	40(a0),a0
	lea	160(a1),a1
	dbra	d0,.scr13
	jsr	decal_letter
	rts

scr14	lea	screen,a1
	add.l	#28,a0
	move	#32-1,d0
off	set	0
.scr14	rept	6
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	-40(a0),a0
	rept	14
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	40(a0),a0
	lea	160(a1),a1
	dbra	d0,.scr14
	jsr	decal_letter
	rts

scr15	lea	screen,a1
	add.l	#30,a0
	move	#32-1,d0
off	set	0
.scr15	rept	5
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	-40(a0),a0
	rept	15
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	40(a0),a0
	lea	160(a1),a1
	dbra	d0,.scr15
	jsr	decal_letter
	rts

scr16	lea	screen,a1
	add.l	#32,a0
	move	#32-1,d0
off	set	0
.scr16	rept	4
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	-40(a0),a0
	rept	16
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	40(a0),a0
	lea	160(a1),a1
	dbra	d0,.scr16
	jsr	decal_letter
	rts

scr17	lea	screen,a1
	add.l	#34,a0
	move	#32-1,d0
off	set	0
.scr17	rept	3
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	-40(a0),a0
	rept	17
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	40(a0),a0
	lea	160(a1),a1
	dbra	d0,.scr17
	jsr	decal_letter
	rts

scr18	lea	screen,a1
	lea	36(a0),a0
	move	#32-1,d0
off	set	0
.scr18	rept	2
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	-40(a0),a0
	rept	18
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	40(a0),a0
	lea	160(a1),a1
	dbra	d0,.scr18
	jsr	decal_letter
	rts

scr19	lea	screen,a1
	add.l	#38,a0
	move	#32-1,d0
off	set	0
.scr19	rept	1
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	-40(a0),a0
	rept	19
	move.w	(a0)+,off(a1)
off	set	off+8
	endr
	lea	40(a0),a0
	lea	160(a1),a1
	dbra	d0,.scr19
	jsr	decal_letter
	rts

scroll	dc.l	scr0
	dc.l	scr1
	dc.l	scr2
	dc.l	scr3
	dc.l	scr4
	dc.l	scr5
	dc.l	scr6
	dc.l	scr7
	dc.l	scr8
	dc.l	scr9
	dc.l	scr10
	dc.l	scr11
	dc.l	scr12
	dc.l	scr13
	dc.l	scr14
	dc.l	scr15
	dc.l	scr16
	dc.l	scr17
	dc.l	scr18
	dc.l	scr19

c	dc.l	0

*****************************
*   insertion du decalage   *
*  pour la rout dom_scroll  *
*****************************

****** ici le decal !

* ‡a craint mais ..
* ‡a marche .. alors bon ...

decal_letter

* recherche du caractere
* ou decalage

	lea	cv,a0
	addq.l	#1,(a0)
	cmp.l	#32/speed_scroll,(a0)
	bge	raz_cv
	bra	ok_cv
raz_cv	clr.l	(a0)
	lea	ct,a0
	move.l	(a0),d0

	addq.l	#1,(a0)
	lea	texte,a0
	move.b	0(a0,d0.l),d0

	tst.b	d0
	ble	raz_ct
	bra	ok_ct
raz_ct	move.l	#1,ct
	lea	texte,a0
	move.b	(a0),d0
ok_ct	and.l	#$ff,d0
	lea	table,a2
	add.l	d0,d0
	add.l	d0,d0

	move.l	0(a2,d0.l),d0
	lea	fonte,a0
	add.l	d0,a0
	lea	decal+2,a1

.recopi
off1	set	0
off2	set	0
	rept	32
	move.w	off1(a0),off2(a1)
	move.w	off1+2(a0),off2+2(a1)
off2	set	off2+6
off1	set	off1+40

	endr
ok_cv
	lea	decal,a0

	moveq	#speed_scroll-1,d1
.decal_8
	move.l	#31,d0
.decal_1
	roxl.w	4(a0)
	roxl.w	2(a0)
	roxl.w	(a0)
	addq.l	#6,a0

	dbra	d0,.decal_1
	lea	decal,a0
	dbra	d1,.decal_8

	lea	decal,a0
	move.l	pos,d0
	add.l	d0,d0
	add.l	d0,d7
	move.l	d7,a1

off1	set	0
off2	set	0

	rept	32
	move.w	off1(a0),off2(a1)
off1	set	off1+6
off2	set	off2+40
	endr
	rts
	
decal	dcb.b	40*32,0
	data
table	dcb.l	33,40*32*3+4*9
*!
	dc.l	40*32*3+4*6
	dcb.l	11,40*32*3+4*9
*-
	dc.l	40*32*3+4*7
	dcb.l	2,40*32*3+4*9
	dc.l	40*32*2+4*6
	dc.l	40*32*2+4*7
	dc.l	40*32*2+4*8
	dc.l	40*32*2+4*9
	dc.l	40*32*3+4*0
	dc.l	40*32*3+4*1
	dc.l	40*32*3+4*2
	dc.l	40*32*3+4*3
	dc.l	40*32*3+4*4
	dc.l	40*32*3+4*5
	dcb.l	5,40*32*3+4*9
*?
	dc.l	40*32*3+4*8
	dc.l	40*32*3+4*9
*A a J
	dc.l	0
	dc.l	4
	dc.l	8
	dc.l	12
	dc.l	16
	dc.l	20
	dc.l	24
	dc.l	28
	dc.l	32
	dc.l	36
*K a T
	dc.l	0+32*40
	dc.l	4+32*40
	dc.l	8+32*40
	dc.l	12+32*40
	dc.l	16+32*40
	dc.l	20+32*40
	dc.l	24+32*40
	dc.l	28+32*40
	dc.l	32+32*40
	dc.l	36+32*40
*U a 3
	dc.l	0+32*40*2
	dc.l	4+32*40*2
	dc.l	8+32*40*2
	dc.l	12+32*40*2
	dc.l	16+32*40*2
	dc.l	20+32*40*2
	dcb.l	6,40*32*3+4*9
*cracking is good for you
	dc.l	40*32*4+4*0
	dc.l	40*32*4+4*1
	dc.l	40*32*4+4*2
	dc.l	40*32*4+4*3
	dc.l	40*32*4+4*4
	dc.l	40*32*4+4*5
	dc.l	40*32*4+4*6
	dc.l	40*32*4+4*7
	dc.l	40*32*4+4*8
	dc.l	40*32*4+4*9

	dcb.l	180,40*32*3+4*9

texte	DC.B	"GAZOBO"
	dc.b	-1
ct	dc.l	0
cv	dc.l	0
*******************
	
fonte	incbin	ballisti.cpt

c_buf	dc.l	0

t_buf	dc.l	buf1
	dc.l	buf2
	dc.l	buf3
	dc.l	buf4
	dc.l	buf5
	dc.l	buf6
	dc.l	buf7
	dc.l	buf8
	dc.l	buf9
	dc.l	buf10
	dc.l	buf11
	dc.l	buf12
	dc.l	buf13
	dc.l	buf14
	dc.l	buf15
	dc.l	buf16


	section	bss
buf1	ds.b	32*40
buf2	ds.b	32*40
buf3	ds.b	32*40
buf4	ds.b	32*40
buf5	ds.b	32*40
buf6	ds.b	32*40
buf7	ds.b	32*40
buf8	ds.b	32*40
buf9	ds.b	32*40
buf10	ds.b	32*40
buf11	ds.b	32*40
buf12	ds.b	32*40
buf13	ds.b	32*40
buf14	ds.b	32*40
buf15	ds.b	32*40
buf16	ds.b	32*40

