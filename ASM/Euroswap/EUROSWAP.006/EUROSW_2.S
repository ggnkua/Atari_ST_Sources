p_tbase	movem.l	a4-a7,save_reg+$30
	move.l	4(a7),base+2
	lea	pile+$140,sp
	pea	intro
	move	#$26,-(sp)
	trap	#14
	addq	#6,sp
	move.l	save_reg+$3c,sp
char	bra	run
quit	clr.l	-(sp)
	trap	#1
		
intro	bsr	save_all
	bsr	col_off
	bsr	set_scr
	moveq	#1,d0
	jsr	music
	bsr	inter_on
	bsr	att_tche
	bsr	inter_off
	bsr	col_on
	rts
	
att_tche	move	#$25,-(sp)
	trap	#14
	addq	#2,sp
f1	cmpi.b	#$3b,$fffffc02.w
	bne.s	f2
	move.l	#nom1,nom+2
	rts
f2	cmpi.b	#$3c,$fffffc02.w
	bne.s	esc
	move.l	#nom2,nom+2
	rts
esc	cmpi.b	#$01,$fffffc02.w
	bne.s	att_tche
	rts

col_off	move.l	#$777,d5
	moveq	#7,d7
col0	lea	$ffff8240.w,a5
	moveq	#15,d6
	move	#$25,-(sp)
	trap	#14
	addq	#2,sp
subcol	move.w	d5,(a5)+
	dbf	d6,subcol
	sub.w	#$111,d5
	dbf	d7,col0
	rts
	
col_on	clr.l	d5
	moveq	#7,d7
col777	lea	$ffff8240.w,a5
	moveq	#15,d6
	move	#$25,-(sp)
	trap	#14
	addq	#2,sp
addcol	move.w	d5,(a5)+
	dbf	d6,addcol
	add.w	#$111,d5
	dbf	d7,col777
	movem.l	pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

set_scr	dc.w	$a00a
	move.b	#6,$484.w
	clr.b	$ffff8260.w
	move.b	#2,$ffff820a.w
	move.b	#$07,$ffff8201.w
	move.b	#$00,$ffff8203.w
	lea	$60000,a0
	move.l	#$8000-1,d0
eff_zob	clr.l	(a0)+
	dbf	d0,eff_zob
	lea	pic+34,a0
	lea	$70000,a1
	move.l	#$1f40-1,d0
cop_im	move.l	(a0)+,(a1)+
	dbf	d0,cop_im
	lea	logo+34,a0
	lea	188*160(a0),a1
	move.l	#187,d0
cop_logo	move.w	(a0),(a1)
	move.w	8(a0),8(a1)
	move.w	16(a0),16(a1)
	move.w	24(a0),24(a1)
	move.w	32(a0),32(a1)
	move.w	40(a0),40(a1)
	lea	160(a0),a0
	lea	160(a1),a1
	dbf	d0,cop_logo
	rts

new_vbl	bsr	init_vbl
	bsr	over_high
	bsr	init_col
	bsr	scroll
	bsr	rouleau
	jsr	music+$8
	bsr	vu_metre
	rte

init_vbl	clr.w	pt_line
	move.l	#hbl1,$120.w
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

init_col	addq.l	#2,pt_col
	cmp.l	#84,pt_col
	bne.s	col_cont
	clr.l	pt_col
col_cont	move.l	pt_col,d0
	mulu	#2,d0
	lea	bufcol2,a0
	adda.l	d0,a0
	move.l	a0,scro+2
	move.l	#bufcol1,vu+2
	move.l	#bufcol3,der+2
	move.l	#bufcol4,dev+2
	rts
	
over_high	move.l	#$584,d0
att1	dbf	d0,att1
	clr	$ffff820a.w
	moveq	#1,d0
att2	dbf	d0,att2
	move.b	#2,$ffff820a.w
	rts

hbl1	cmpi.w	#202,pt_line
	bne.s	ret1	
	move.w	#$000,$ffff8240.w
	move.l	#hbl2,$120.w
ret1	addq.w	#1,pt_line
	rte
	
hbl2	
vu	move.w	bufcol1,$ffff8250.w
scro	move.w	bufcol2,$ffff8254.w
	move.w	$ffff8254.w,$ffff8244.w
	move.w	$ffff8254.w,$ffff8246.w
der	move.w	bufcol3,$ffff8242.w
dev	move.w	bufcol4,$ffff8248.w
	move.w	$ffff8248.w,$ffff824a.w
	move.l	$ffff8248.w,$ffff824c.w
	cmpi.w	#227,pt_line
	bne.s	ret2
	move.l	d0,save_d0
nbr	moveq	#22,d0
att4	dbf	d0,att4
	clr.b	$ffff820a.w
	moveq	#1,d0
att5	dbf	d0,att5
	move.b	#2,$ffff820a.w
	move.l	save_d0,d0
ret2	addq.l	#2,vu+2
	addq.l	#2,scro+2
	addq.l	#2,der+2
	addq.l	#2,dev+2
	addq.w	#1,pt_line
	rte
	
vu_metre	lea	$ffff8800.w,a4
	lea	$70000+160*208,a3
	clr.l	d0
	move.b	#8,(a4)
	move.b	(a4),d0
	andi.b	#$f,d0
	cmp.b	#8,d0
	bge.s	v1
	moveq	#8,d0
v1	subq	#7,d0
	mulu	#3*160,d0
	lea	6+8(a3),a0
	lea	160*8*3(a0),a1
	sub.l	d0,a1
	bsr	aff_vu
	
	clr.l	d0
	move.b	#9,(a4)
	move.b	(a4),d0
	andi.b	#$f,d0
	cmp.b	#8,d0
	bge.s	v2
	moveq	#8,d0
v2	subq	#7,d0
	mulu	#3*160,d0
	lea	6+8*2(a3),a0
	lea	160*8*3(a0),a1
	sub.l	d0,a1
	bsr	aff_vu
	
	clr.l	d0
	move.b	#10,(a4)
	move.b	(a4),d0
	andi.b	#$f,d0
	cmp.b	#8,d0
	bge.s	v3
	moveq	#8,d0
v3	subq	#7,d0
	mulu	#3*160,d0
	lea	6+8*3(a3),a0
	lea	160*8*3(a0),a1
	sub.l	d0,a1
	bsr	aff_vu
	rts

aff_vu	moveq	#24,d0
	lea	160*8*6(a0),a2
zob2	cmpa.l	a1,a0
	bge.s	aff_li
	clr.b	(a0)
	clr.b	120(a0)
	clr.b	(a2)
	clr.b	120(a2)
	bra.s	sui_vu
aff_li	move.b	#$ff,(a0)
	move.b	#$ff,120(a0)
	move.b	#$ff,(a2)
	move.b	#$ff,120(a2)
sui_vu	lea	160(a0),a0
	lea	-160(a2),a2
	dbra	d0,zob2
	rts


rouleau	lea	logo+34,a0
	lea	pt_roul,a1
	cmp.l	#160*188,(a1)
	bne.s	pt_roul_ct
	clr.l	pt_roul
pt_roul_ct	adda.l	(a1),a0
	lea	188*160(a0),a3
	add.l	#160*1,(a1)
	lea	$70000+160*204+8*7,a1
	lea	cos_roul,a2
	move.l	#60-1,d0
roul_bcle	clr.l	d1
	move.b	(a2)+,d1
	mulu	#160,d1
	adda.l	d1,a0
	suba.l	d1,a3
	move.w	(a0),4(a1)
	move.w	8(a0),8+4(a1)
	move.w	16(a0),16+4(a1)
	move.w	24(a0),24+4(a1)
	move.w	32(a0),32+4(a1)
	move.w	40(a0),40+4(a1)
	move.w	(a3),(a1)
	move.w	8(a3),8(a1)
	move.w	16(a3),16(a1)
	move.w	24(a3),24(a1)
	move.w	32(a3),32(a1)
	move.w	40(a3),40(a1)
	lea	160(a1),a1
	dbf	d0,roul_bcle
	rts

scroll	bsr	test_let
	bsr	cos_set
	bsr	decal
	bsr	aff_let
	rts
	
cos_set	lea	cos,a0
	adda.l	pt_cos,a0
	cmp.b	#$ff,(a0)
	bne.s	cos_ct
	clr.l	pt_cos
	lea	cos,a0
cos_ct	addq.l	#1,pt_cos
	rts

test_let	lea	text,a0
	adda.l	pt_text,a0
	clr.l	d0
	move.b	(a0),d0
	tst	d0
	bne.s	space
	clr.l	pt_text
	bra.s	test_let
space	cmpi.b	#$20,d0
	bne.s	excla1
	lea	font+34+160*21*4+16*4,a1
	bra	suite_1
excla1	cmpi.b	#$21,d0
	bne.s	inter1
	lea	font+34+160*21*3+16*9,a1
	bra	suite_1
inter1	cmpi.b	#$3f,d0
	bne.s	dx_pts1
	lea	font+34+160*21*3+16*8,a1
	bra	suite_1
dx_pts1	cmpi.b	#$3a,d0
	bne.s	pt_virg1
	lea	font+34+160*21*3+16*7,a1
	bra	suite_1
pt_virg1	cmpi.b	#$3b,d0
	bne.s	virg1
	lea	font+34+160*21*4+16*1,a1
	bra	suite_1
virg1	cmpi.b	#$2c,d0
	bne.s	par_g1
	lea	font+34+160*21*4+16*5,a1
	bra	suite_1
par_g1	cmpi.b	#$28,d0
	bne.s	par_d1
	lea	font+34+160*21*4+16*6,a1
	bra	suite_1
par_d1	cmpi.b	#$29,d0
	bne.s	tiret1
	lea	font+34+160*21*4+16*7,a1
	bra	suite_1
tiret1	cmpi.b	#$2d,d0
	bne.s	pnt1
	lea	font+34+160*21*4+16*0,a1
	bra	suite_1
pnt1	cmpi.b	#$2e,d0
	bne.s	etoi
	lea	font+34+160*21*3+16*6,a1
	bra	suite_1
etoi	cmpi.b	#$2a,d0
	bne.s	guill1
	lea	font+34+160*21*4+16*2,a1
	bra	suite_1
guill1	cmpi.b	#$27,d0
	bne.s	lettres_11
	lea	font+34+160*21*4+16*3,a1
	bra	suite_1
lettres_11	cmpi.b	#$41,d0
	blt.s	chiffres_1
	cmpi.b	#$4b,d0
	bge.s	lettres_12
	subi.b	#$41,d0
	mulu	#$10,d0
	lea	font+34+160*21*1,a1
	adda.l	d0,a1
	bra.s	suite_1
lettres_12	cmpi.b	#$55,d0
	bge.s	lettres_13
	subi.b	#$4b,d0
	mulu	#$10,d0
	lea	font+34+160*21*2,a1
	adda.l	d0,a1
	bra.s	suite_1
lettres_13	subi.b	#$55,d0
	mulu	#$10,d0
	lea	font+34+160*21*3,a1
	adda.l	d0,a1
	bra.s	suite_1
chiffres_1	subi.b	#$30,d0
	mulu	#$10,d0
	lea	font+34,a1
	adda.l	d0,a1
suite_1	adda.l	pt_plan,a1
plus_0	cmp.l	#0,pt_plan
	bne.s	plus_1
	move.l	#1,pt_plan
	bra	suite_2
plus_1	cmp.l	#1,pt_plan
	bne.s	plus_8
	move.l	#8,pt_plan
	bra	suite_2
plus_8	cmp.l	#8,pt_plan
	bne.s	plus_9
	move.l	#9,pt_plan
	bra	suite_2
plus_9	move.l	#0,pt_plan
	add.l	#1,pt_text
suite_2	rts

decal	lea	adr_pos,a2
	move.l	#39,d0
loop_txt	move.l	4(a2),a3
	clr.l	d1
	move.b	(a0)+,d1
	mulu	#160,d1
	sub.l	#160,d1
	add.l	d1,(a2)
	move.l	(a2)+,a4
	move.b	160*0(a3),160*0(a4)
	move.b	160*1(a3),160*1(a4)
	move.b	160*2(a3),160*2(a4)
	move.b	160*3(a3),160*3(a4)
	move.b	160*4(a3),160*4(a4)
	move.b	160*5(a3),160*5(a4)
	move.b	160*6(a3),160*6(a4)
	move.b	160*7(a3),160*7(a4)
	move.b	160*8(a3),160*8(a4)
	move.b	160*9(a3),160*9(a4)
	move.b	160*10(a3),160*10(a4)
	move.b	160*11(a3),160*11(a4)
	move.b	160*12(a3),160*12(a4)
	move.b	160*13(a3),160*13(a4)
	move.b	160*14(a3),160*14(a4)
	move.b	160*15(a3),160*15(a4)
	move.b	160*16(a3),160*16(a4)
	move.b	160*17(a3),160*17(a4)
	move.b	160*18(a3),160*18(a4)
	move.b	160*19(a3),160*19(a4)
	move.b	160*20(a3),160*20(a4)
	clr.b	-160(a4)
	clr.b	160*21(a4)
	cmp.b	#$ff,(a0)
	bne.s	cos_ct2
	lea	cos,a0
cos_ct2	dbf	d0,loop_txt
	rts
	
aff_let	move.b	160*0(a1),160*0(a4)
	move.b	160*1(a1),160*1(a4)
	move.b	160*2(a1),160*2(a4)
	move.b	160*3(a1),160*3(a4)
	move.b	160*4(a1),160*4(a4)
	move.b	160*5(a1),160*5(a4)
	move.b	160*6(a1),160*6(a4)
	move.b	160*7(a1),160*7(a4)
	move.b	160*8(a1),160*8(a4)
	move.b	160*9(a1),160*9(a4)
	move.b	160*10(a1),160*10(a4)
	move.b	160*11(a1),160*11(a4)
	move.b	160*12(a1),160*12(a4)
	move.b	160*13(a1),160*13(a4)
	move.b	160*14(a1),160*14(a4)
	move.b	160*15(a1),160*15(a4)
	move.b	160*16(a1),160*16(a4)
	move.b	160*17(a1),160*17(a4)
	move.b	160*18(a1),160*18(a4)
	move.b	160*19(a1),160*19(a4)
	move.b	160*20(a1),160*20(a4)
	clr.b	-160(a4)
	clr.b	160*21(a4)
	rts

save_all	move.b	$ffff8260.w,rez+1
	move.b	$ffff820a.w,hz
	move.l	$44e.w,screen
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,pal
	lea	$fffffa01.w,a0
	lea	mfp,a1
	moveq	#$e,d0
cop_mfp	move.b	(a0)+,(a1)+
	lea	1(a0),a0
	dbf	d0,cop_mfp
	move.b	8(a0),(a1)+
	move.b	10(a0),(a1)+
	move.b	12(a0),(a1)+
	move.b	14(a0),(a1)+
	move.b	16(a0),(a1)+
	lea	$8.w,a0
	lea	vecs,a1
	move.l	#252,d0
cop_vecs	move.l	(a0)+,(a1)+
	dbf	d0,cop_vecs
       	rts

inter_on	move	#$2700,sr
	move	#$25,-(sp)
	trap	#14
	addq	#2,sp
	move.b	#$12,$fffffc02.w
	and.b	#$fe,$fffffa13.w
	and.b	#$fe,$fffffa0f.w
	and.b	#$fe,$fffffa0b.w
	and.b	#$fe,$fffffa07.w
	clr.b	$fffffa09.w
	move.b 	#$8,$fffffa1b.w
	move.b 	#1,$fffffa21.w
	move.l	#hbl1,$120.w
	move.l	#new_vbl,$70.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	bclr	#5,$fffffa09.w
	bclr	#4,$fffffa09.w
	bclr	#3,$fffffa17.w
	move.w	#$2300,sr
	rts

inter_off	move	#$2700,sr
	move.b	#$06,$ffff8201.w
	move.b	#$00,$ffff8203.w
	lea	vecs,a0
	lea	$8.w,a1
	move.l	#252,d0
set_vecs	move.l	(a0)+,(a1)+
	dbf	d0,set_vecs
	lea	mfp,a0
	lea	$fffffa01.w,a1
	moveq	#$e,d0
set_mfp	move.b	(a0)+,(a1)+
	lea	1(a1),a1
	dbf	d0,set_mfp
	move.b	(a0)+,8(a1)
	move.b	(a0)+,10(a1)
	move.b	(a0)+,12(a1)
	move.b	(a0)+,14(a1)
	move.b	(a0)+,16(a1)
	lea	$ffff8800.w,a0
	move.l	#$08080000,(a0)
	move.l	#$09090000,(a0)
	move.l	#$0a0a0000,(a0)
	move.b	#$8,$fffffc02.w
	move.b	hz,$ffff820a.w
	move	rez,-(sp)
	move.l	screen,-(sp)
	move.l	(sp),-(sp)
	move	#$5,-(sp)
	trap	#14
	lea	$c(sp),sp
	move.b	#7,$484.w
	dc.w	$a009
	move.w	#$2300,sr
	rts

tst_fic	move	#2,-(sp)
nom 	pea	0
 	move	#$3d,-(sp)
 	trap	#1
 	lea	8(sp),sp
 	move.l	d0,d7
 	tst	d0
 	bmi	quit
 	rts
 	
run 	jsr	tst_fic
	lea	rel_8,a0
 	lea	rel_1,a1
cop4 	move.l	-(a0),-(a7)
 	cmpa.l	a0,a1
 	ble.s	cop4
 	jmp	(a7)
 	nop
 	nop
rel_1	lea	p_tbase,a5
	lea	-$1c(a5),a6
	move.l	a6,a0
	lea	rel_1(pc),a2
rel_2	clr.l	(a0)+
	cmpa.l	a0,a2
	bge.s	rel_2
	move.l	a6,-(sp)
 	pea	$ffffff
 	move	d7,-(sp)
 	move	#$3f,-(sp)
 	trap	#1
 	lea	12(sp),sp
 	move	d7,-(sp)
 	move	#$3e,-(sp)
 	trap	#1
 	lea	4(sp),sp
	cmpi.w	#$60fe,(a5)
	bne.s	rel_3
	move.w	4(a6),(a5)
	move.w	(a6),4(a6)
rel_3	tst	$1a(a6)
	bne.s	rel_4
	move.l	a5,a2
	adda.l	2(a6),a2
	adda.l	6(a6),a2
	adda.l	14(a6),a2
	clr.l	d1
	move.l	a5,d6
	move.l	(a2)+,d0
	beq.s	rel_4
rel_5	add.l	d6,0(a5,d0.l)
rel_6	move.b	(a2)+,d1
	beq.s	rel_4
	add.l	d1,d0
	cmp.b	#1,d1
	bne.s	rel_5
	addi.l	#$fd,d0
	bra.s	rel_6
rel_4	lea	-$100(a5),a0
	move.l	a5,d0
	move.l	2(a6),12(a0)
	add.l	12(a0),d0
	move.l	d0,16(a0)
	move.l	6(a6),20(a0)
	add.l	20(a0),d0
	move.l	d0,24(a0)
	move.l	10(a6),28(a0)
	lea	rel_7(pc),a0
	lea	8(a6),a1
	move.l	#4,d0
rel_9	move.l	(a0)+,(a1)+
	dbra	d0,rel_9	
	movem.l	save_reg(pc),d0-d7/a0-a7
base	move.l	#0,4(a7)
	lea	rel_1(pc),a0
	lea	-$50(a0),a0
	lea	rel_8(pc),a1
	jmp	p_tbase-20
rel_7	clr.l	(a0)+
	cmpa.l	a0,a1
	bge.s	rel_7
	move.l	#0,a0
	move.l	#0,a1
	nop
save_reg	ds.l	16
rel_8

pt_col	ds.l	1
pt_line	ds.w	1
	even
bufcol1	dc.w	$000,$000,$000,$000
          dc.w	$FFF,$FFF,$FFF,$FFF,$FFF,$777,$BFF,$377
          dc.w      $8FF,$077,$8EE,$066,$8DD,$055,$8CC,$044
	dc.w      $8BB,$033,$8AA,$022,$899,$011,$888,$000
          dc.w      $000,$001,$889,$002,$88A,$003,$88B,$004
          dc.w      $88C,$005,$88D,$006,$88E,$007,$88F,$017
	dc.w	$89F,$027,$8AF,$037,$8BF,$047,$8CF,$057
	dc.w	$000,$000,$000,$000
	even
bufcol2	rept	3
          dc.w	$777,$777,$777,$777,$777,$777,$777
          dc.w	$EFE,$676,$DFD,$575,$CFC,$474,$BFB
	dc.w	$373,$AFA,$272,$9F9,$171,$8F8,$161
	dc.w	$8E8,$151,$8D8,$141,$8C8,$131,$8B8
	dc.w      $121,$8A8,$111,$898,$111,$120,$131
	dc.w	$141,$151,$161,$171,$373,$575,$777
	endr
bufcol4	dc.w	$222,$AAA,$AAA,$333,$333,$BBB,$BBB,$BBB
          dc.w      $444,$444,$444,$CCC,$CCC,$CCC,$555,$555 
          dc.w      $555,$DDD,$DDD,$DDD,$666,$666,$666,$EEE
          dc.w      $EEE,$EEE,$777,$777,$777,$FFF,$FFF,$FFF
          dc.w      $777,$777,$EEE,$EEE,$666,$666,$DDD,$DDD
          dc.w      $555,$555,$CCC,$CCC,$444,$444,$BBB,$BBB
          dc.w      $333,$333,$AAA,$AAA,$222,$222,$999,$999
          dc.w      $111,$111,$888,$888      
	
bufcol3	dc.w      $C90,$410,$410,$B80,$B80,$B80,$300,$300
          dc.w      $300,$300,$A00,$A00,$A00,$A00,$A00,$200
          dc.w      $200,$200,$200,$200,$200,$900,$900,$900
          dc.w      $900,$900,$900,$900,$900,$900,$900,$900
          dc.w      $900,$900,$900,$900,$100,$200,$200,$200
          dc.w      $200,$200,$200,$A00,$A00,$A00,$A00,$A00
          dc.w      $300,$300,$300,$300,$B80,$B80,$B80,$410
          dc.w      $410,$C90,$C90,$222
	
	even
text      DC.B	" ;* HE GUY !    EUROSWAP  CD 963   ZAP  " 
          DC.B      " ;* F1 ALBATOR   ;* F2 GOLDORAK  AND  ;* ESC  FOR SOMES DOCS "                                                                
	DC.B	" THE TWO GAMES WERE CRACKED BY ....... FROM ........, AND ......... WAS PACKED BY .. ....     PRESS ESCAPE TO SEE THE LIST OF OUR LAST COMPILS AND SOMES DOCS ....  "
	DC.B	" CREDITS GO TO : VERRY OLD INTRO CODED BY ;* ORION FROM FUZION      GRAPHX AND DESIGN BY ;* SKYWALKER FROM EXO7     FONTS BY ;* MACDOS ,REMISED BY SKYWALKER OF EXO7      MUSIX BY ;* ANTICRHIST OF SECTOR ONE    "
	DC.B	" THE MEMBERS THIS ALLIANCE OF EUROSWAP ARE :     - PASSWORDS (THE WAY TO FUNLAND !) -      - SELECT -      - EXO7 - "
	DC.B	" SPEED GREETINGS BY SKYWALKER FOR ;  AXYLAN (AND HIS MEGA ST ! HA HA!)"
	dc.b	" - LAURENZO ( VERRY GOOD SWAP !) - WARRIOR (GOOD SWAP) - DR TRAP (VERRY GOOD CRACKER) - GUICHE (VERRY GOOD CODER) - R-BOY (ZZZZZ....) - SARK (COOL GUY) - WINNER "
	DC.B	" ALLEZ L'OM !!!) - CORPO (INTRO IS DEAD ???....ZZZ...) - GOOFY (FOR WHEN THE CODING PARTY OF EXO7 ?) - OXYD (THE BEST RIPPER HAHA!!) - AND YOU THE FANS ONE ST ..."
	DC.B	" FOR CONTACT EXO7 (ONLY DEMOMAKERS !!!) WRITE TO : ;* GEBLEUX  JL  -  LA RESPELIDO  -  CAMPAGNE TRONC  -  13140 MIRAMAS  -  FRANCE.   OR MINITEL ;   36 15 , RTEL , BAL  E X O 7   "
	DC.B	" "                                                                       "
	DC.B      " "
	DC.B      ""
	DC.B	0
	even
save_d0	ds.l	1
pile	ds.l	$80
	even
pal	ds.l	8
vecs	ds.l	253
mfp	ds.b	20
	even
screen	ds.l	1
rez	ds.w	1
hz	ds.b	1
	even
pt_text	ds.l	1
	even
pt_plan	ds.l	1
	even
cos	rept	40
	dc.b	1
	endr
	rept	4
	dc.b	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	endr
	rept	4
	dc.b	2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0
	endr
	rept	4
	dc.b	2,1,2,2,1,2,2,2,1,2,2,2,2,1,1,0,0,0,0,1,0,0,0,1,0,0,1,0
	endr
	dc.b	$ff
	even
pt_cos	ds.l	1
cos_roul	dc.b	0,2,3,2,2,2,2,2,2,2,2,2,2,2,2,1,2,2,1,2,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,2,1,2,2,2,1,2,2,2,2,2,2,2,2,2,2,2,2,2
	even
pt_roul	ds.l	1
adr_pos	dc.l	0+$70000+160*222+2
	dc.l	1+$70000+160*222+2
	dc.l	8+$70000+160*222+2
	dc.l	9+$70000+160*222+2
	dc.l	16+$70000+160*222+2
	dc.l	17+$70000+160*222+2
	dc.l	24+$70000+160*222+2
	dc.l	25+$70000+160*222+2
	dc.l	32+$70000+160*222+2
	dc.l	33+$70000+160*222+2
	dc.l	40+$70000+160*222+2
	dc.l	41+$70000+160*222+2
	dc.l	48+$70000+160*222+2
	dc.l	49+$70000+160*222+2
	dc.l	56+$70000+160*222+2
	dc.l	57+$70000+160*222+2
	dc.l	64+$70000+160*222+2
	dc.l	65+$70000+160*222+2
	dc.l	72+$70000+160*222+2
	dc.l	73+$70000+160*222+2
	dc.l	80+$70000+160*222+2
	dc.l	81+$70000+160*222+2
	dc.l	88+$70000+160*222+2
	dc.l	89+$70000+160*222+2
	dc.l	96+$70000+160*222+2
	dc.l	97+$70000+160*222+2
	dc.l	104+$70000+160*222+2
	dc.l	105+$70000+160*222+2
	dc.l	112+$70000+160*222+2
	dc.l	113+$70000+160*222+2
	dc.l	120+$70000+160*222+2
	dc.l	121+$70000+160*222+2
	dc.l	128+$70000+160*222+2
	dc.l	129+$70000+160*222+2
	dc.l	136+$70000+160*222+2
	dc.l	137+$70000+160*222+2
	dc.l	144+$70000+160*222+2
	dc.l	145+$70000+160*222+2
	dc.l	152+$70000+160*222+2
	dc.l	153+$70000+160*222+2
	dc.l	160+$70000+160*222+2
	even
nom1	dc.b	"1",0
	even
nom2	dc.b	"2",0
	even	
font	incbin	a:\sky.pi1
	even
logo	incbin	a:\logo.pi1
	ds.b	160*188 
	even
pic	incbin	a:\euroswap.pi1
	even
music	incbin	a:\robocop.mus
	even
	end