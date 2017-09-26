	text
MAX_XALOC	equ	4
	rsreset
blk_next	rs.l	1
blk_prec	rs.l	1
blk_num		rs.l	1
blk_size	rs.l	1
blk_state	rs.w	1
blk_struc_size	rs.w	1

	lea	yop,a2
	lea	yop2,a3

	move.l	a3,d0
	sub.l	a2,d0
	move.l	a3,d1
	add.l	#blk_struc_size,d1
	move.l	d1,d2
	add.l	#250,d2
	lea	blk_tbl-4,a0
	move.l	#MAX_XALOC,d3
	subq.l	#1,d1
boucle_verifi
	move.l	(a0,d3.l*4),a1
	tst.l	a1
	beq	goto_decremente
	cmp.l	(a1),d1
	blt	au_dessus
goto_decremente
	sub.l	#1,d3
	bne	boucle_verifi

	bra	ok_cest_update

au_dessus
	cmp.l	(a1),d2
	bgt	au_dessous
	sub.l	#1,d3
	bne	boucle_verifi

	bra	ok_cest_update

au_dessous
	sub.l	#1,d3
	bne	boucle_verifi

ok_cest_update
	clr.w	-(sp)
	trap	#1
	data
blk_tbl	dc.l	0,yop4,0,0
yop4	dc.l	yop3
	bss
yop	ds.l	100
yop2	ds.l	50
yop3	ds.l	50