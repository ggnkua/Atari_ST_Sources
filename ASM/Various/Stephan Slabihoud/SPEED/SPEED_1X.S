* Loader fÅr ST-SPEED V1.x
*
* Dieses Ladeprogramm basiert auf einer einer c't - Lîsung 
* Ausgabe 6/89 "Residenter Wachhund"
*

mymagic:	equ	$10293847

	output	\st_speed.tos

	lea		$10000,a0
	lea		$70000,a1
ht_im0:
	cmp.l	#$12123456,(a0)
	beq.s	hier
n_hier:
	lea		512(a0),a0
	cmp.l	a1,a0
	ble.s	ht_im0
	bra.s	insta
hier:
	cmp.l	4(a0),a0
	bne.s	n_hier
	cmp.l	#mymagic,12(a0)
*termy:
	bne.s	n_hier
termy:
	clr.w	-(sp)
	trap		#1
insta:
	move.l	#$10000,a0
	lea		tot_end(pc),a1
inst_g0:
	cmp.l	a0,a1
	ble.s	inst_g1
	lea		512(a0),a0
	bra.s	inst_g0
inst_g1:
	move.l	a0,a5
	lea		t_inf(pc),a0
	bsr		pr_strg
	clr.w	-(sp)
	pea		t_datna(pc)
	move.w	#$3d,-(sp)
	trap		#1
	addq.l	#8,sp
	move.w	d0,d6
	bmi		fehler
	addq.l	#2,a5
fl_l0:
	move.w	(a5),-2(a5)
	moveq.l	#2,d0
	bsr.s	fread
	tst.l	d0
	bmi		fehler
	cmp.l	#$12123456,-2(a5)
	bne.s	fl_l0
	addq.l	#2,a5
	move.l	#80000,d0
	bsr.s	fread
	tst.l	d0
	bmi		fehler
	subq.l	#4,a5
	move.w	d6,-(sp)
	move.w	#62,-(sp)
	trap		#1
	addq.l	#4,sp
	move.l	a5,4(a5)
	move.l	a5,a0
	clr.w	d0
	move.w	#$ff,d1
itpol:
	add.w	(a0)+,d0
	dbra		d1,itpol
	move.w	#$5678,d1
	sub.w	d0,d1
	move.w	d1,10(a5)
	jsr		16(a5)
	move.l	4(sp),a1
	sub.l	a1,a0
	clr.w	-(sp)
	move.l	a0,-(sp)
	move.w	#$31,-(sp)
	trap		#1
fread:
	move.l	a5,-(sp)
	move.l	d0,-(sp)
	move.w	d6,-(sp)
	move.w	#63,-(sp)
	trap		#1
	lea		12(sp),sp
	rts
fehler:
	lea		t_nles(pc),a0
	bsr.s	pr_strg
	move.w	#7,-(sp)
	trap		#1
	addq.l	#2,sp
	bra		termy
pr_strg:
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap		#1
	addq.l	#6,sp
	rts

	section data

t_datna:	dc.b	'st_speed.bin',0
t_nles:	dc.b	27,'E',13,10,' Diskerror !   *** Not installed *** ',0
t_inf:	dc.b	27,'E',13,10
		dc.b	' ST-SPEED Version 1.x installed.',13,10
		dc.b	13,10
		dc.b	' (c) 1987,88,89,90 by Stephan Slabihoud',13,10
		dc.b 0

		even
tot_end:	end