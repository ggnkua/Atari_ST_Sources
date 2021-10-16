start	pea		$100000
		move.w	#$20,-(a7)
		trap		#1
		addq.l	#6,a7
		move.l	d0,-(a7)
		bsr		menu
		move.w	#$20,-(a7)
		trap		#1
		addq.l	#6,a7
		clr.w	-(a7)
		trap		#1

menu		bsr		shiftbbc
		bsr		setscreen
		bsr		music
		move.b	#0,$fffffa1b.w
		move.b	#1,$fffffa07.w
		bset		#0,$fffffa13.w
		move.b	#$40,$fffffa09.w
		bsr		vblon
.readkey
		move.w	#7,-(a7)
		trap		#1
		addq.l	#2,a7
		cmp.w	#'0',d0
		bne.s	.key1
		bchg		#1,$ffff820a.w
		bra		.readkey
.key1	bsr		vbloff
		move.w	#$25,-(a7)
		trap		#14
		addq.l	#2,a7
		move.w	#$777,$ff8240
		clr.w	$ff8246
		rts

setscreen	move.w	#2,-(a7)
		trap		#14
		addq.l	#2,a7
		move.l	d0,a0
		move.l	d0,screen
		move.w	#$1f3f,d0
.clear	clr.l	(a0)+
		dbf		d0,.clear
		move.l	#grafs+34+32*160,a0
		sub.l	a1,a1		
		move.w	#20*160/4-1,d0
		bsr		scrncopy
		move.l	#grafs+34+52*160,a0
		move.l	#108*160,a1
		move.w	#8*160/4-1,d0
		bsr		scrncopy
		move.l	#grafs+34,a0
		move.l	#124*160,a1
		move.w	#32*160/4-1,d0

scrncopy	add.l	screen,a1
.copy	move.l	(a0)+,(a1)+
		dbf		d0,.copy
		rts


shiftbbc
		LEA		bbc_posn,A0
		LEA		bbcs,A2
		CLR.W	D0
		MOVE.W	#$10,D1
shift4
		MOVE.L	A2,(A0)+
		LEA		bbc_graf,A1
		MOVE.W	#$45,D2
shift3
		CLR.L	(A2)+
		CLR.L	(A2)+
		MOVE.W	#6,D3
shift2
		LEA		0(A1,D3.W),A3
		LEA		0(A2,D3.W),A4
		MOVE.W	(A3),D5
		LSR.W	D0,D5
		MOVE.W	D5,(A4)
		ADDQ.W	#8,A4
		MOVE.W	#$A,D4
shift1
		MOVE.W	(A3),D5
		ADDQ.W	#8,A3
		MOVE.W	(A3),D6
		LSL.W	D1,D5
		LSR.W	D0,D6
		OR.W		D5,D6
		MOVE.W	D6,(A4)
		ADDQ.W	#8,A4
		DBF		D4,shift1
		MOVE.W	(A3),D5
		LSL.W	D1,D5
		MOVE.W	D5,(A4)
		SUBQ.W	#2,D3
		BPL.S	shift2
		ADDA.W	#$68,A2
		CLR.L	(A2)+
		CLR.L	(A2)+
		ADDA.W	#$60,A1
		DBF		D2,shift3
		ADDQ.W	#1,D0
		SUBQ.W	#1,D1
		BNE		shift4

		lea		bbc_posn,a2
		move.l	60(a2),a0
		lea		$20d0(a0),a0
		move.l	a0,bbc_off
		move.l	a0,bbc_off_pos
		lea		bbc_pts,a1
shiftpts	move.w	(a1)+,d0
		bmi.s	ptsdone
		move.w	d0,d1
		and.w	#$f,d0
		and.w	#$f0,d1
		lsl.w	#2,d0
		move.l	0(a2,d0.w),(a0)+
		lsr.w	#1,d1
		move.w	d1,(a0)+
		move.w	#$98,d0
		sub.w	d1,d0
		move.w	d0,(a0)+
		bra.s	shiftpts		
ptsdone	move.l	#-1,(a0)+
		rts

vblon	move.l	$4ce,oldvbl
		move.l	#vbl,$4ce
		clr.b	$ff8260
		movem.l	bbc_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts

vbloff	move.l	oldvbl,$4ce
		move.b	#0,$fffa07
		move.b	$fffa15,$fffa09
		move.b	#8,$ff8800
		clr.b	$ff8802
		move.b	#9,$ff8800
		clr.b	$ff8802
		move.b	#10,$ff8800
		clr.b	$ff8802
		rts


oldvbl	dc.l		0



vbl		movem.l	d0-d7/a0-a6,-(a7)
		clr.b	$fffffa1b.w
		move.b	#20,$fffffa21.w
		move.l	#mfp1,$120.w
		move.b	#8,$fffffa1b.w
		move.b	#75,$fffffa21.w
		subq.w	#1,wong_del
		bpl.s	no_wong
		move.w	#5,wong_del
		move.w	grafs+4,d0
		add.w	wong_add,d0
		cmp.w	#$100,d0
		beq.s	rev_wong
		cmp.w	#$700,d0
		bne.s	no_rev_w
rev_wong	neg.w	wong_add
no_rev_w	move.w	d0,grafs+4
no_wong	movem.l	grafs+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.w	#31,mfp_cnt
		move.l	mfp_col1,a0
		addq.l	#2,a0
		cmp.l	#mfp_rept,a0
		bne.s	mfp_ok
		lea		mfp_cols,a0
mfp_ok	move.l	a0,mfp_col1
		move.l	a0,mfp_col2
		bsr		bbc
		bsr		scroll
		bsr		circles
		btst		#1,$ffff820a.w
		bne.s	gomusic
		subq.w	#1,musiccnt
		bpl.s	gomusic
		move.w	#5,musiccnt
		bra.s	nomusic
gomusic	bsr		music+$a8
nomusic	movem.l	(a7)+,d0-d7/a0-a6
		rts

musiccnt	dc.w	5

mfp1		movem.l	d0-d7,-(a7)
		movem.l	bbc_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		movem.l	(a7)+,d0-d7
		move.b	#30,$fffffa21.w
		move.l	#mfp2,$120.w
		bclr		#0,$fffffa0f.w
		rte
mfp2		movem.l	d0-d7,-(a7)
		movem.l	grafs+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		movem.l	(a7)+,d0-d7
		move.b	#1,$fffffa21.w
		move.l	#mfp3,$120.w
		bclr		#0,$fffffa0f.w
		rte
mfp3		move.l	a0,-(a7)
		move.l	mfp_col2,a0
		move.w	(a0)+,$ffff8242.w
		move.l	a0,mfp_col2
		move.l	(a7)+,a0
		subq.w	#1,mfp_cnt
		bpl.s	end_mfp
		move.b	#$3,$fffffa21.w
		move.l	#mfp4,$120.w
end_mfp	bclr		#0,$fffffa0f.w
		rte
mfp4		move.l	#mfp5,$120.w
		bclr		#0,$fffffa0f.w
		rte
mfp5		movem.l	d0-d7,-(a7)
		movem.l	char_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		movem.l	(a7)+,d0-d7
		clr.b	$fffffa1b.w
		bclr		#0,$fffffa0f.w
		rte


*********************************
************  B B C  ************
*********************************

bbc		move.l	bbc_off_pos,a2
		addq.l	#8,a2
		tst.l	70*8(a2)
		bpl.s	.ok_pos
		move.l	bbc_off,a2
.ok_pos	move.l	a2,bbc_off_pos
		sub.l	a0,a0
		move.l	screen,a1
		lea		25*160-8(a1),a1
		move.w	#69,d0
.doline	move.l	a0,a3
		add.l	(a2)+,a3
		add.w	(a2)+,a1
		clr.l	(a1)+
		clr.l	(a1)+
		movem.l	(a3)+,d1-d7/a4-a6
		movem.l	d1-d7/a4-a6,(a1)
		movem.l	(a3)+,d1-d7/a4-a6
		movem.l	d1-d7/a4-a6,$28(a1)
		movem.l	(a3),d1-d7/a4-a5
		movem.l	d1-d7/a4-a6,$50(a1)
		clr.l	$70(a1)
		clr.l	$74(a1)
		lea		$78(a0),a0
		add.w	(a2)+,a1
		dbf		d0,.doline
		rts

*********************************
******** S C R O L L E R ********
*********************************

scroll	subq.w	#4,scrlpos
		move.w	scrlpos,d0
		and.w	#$1f,d0
		jmp		scrltab(pc,d0.w)

scrlpos	dc.w		32
scrloff	dc.w		32
		
scrltab
		bra		scroll1
		bra		scroll2
		bra		scroll3
		bra		scroll4
		bra		scroll5
		bra		scroll6
		bra		scroll7
		bra		scroll8

scrollp1	equ		$f8000-$230*$80
scrollp2	equ		$f8000-$230*$60
scrollp3	equ		$f8000-$230*$40
scrollp4	equ		$f8000-$230*$20
		
scroll1
		lea		scrollp1+8,a0
		bsr		show
		lea		scrollp1+$23f0,a0
		move.l	chargraf,a1
		add.w	#$100,a1
		moveq	#0,d0
		bsr		addlet
		move.l	messpos,a0
		moveq	#0,d0
		move.b	(a0)+,d0
		bpl.s	okchar
		moveq	#32,d0
		lea		message,a0
okchar	move.l	a0,messpos
		sub.w	#32,d0
		moveq	#9,d1
		lsl.w	d1,d0
		add.l	#charset,d0
		move.l	d0,chargraf
		add.w	#$10,scrloff
		cmp.w	#$130,scrloff
		bne.s	nooffrpt
		move.w	#$20,scrloff
nooffrpt
		rts

scroll2
		lea		scrollp2+8,a0
		bsr		show
		lea		scrollp2+$23f0,a0
		move.l	chargraf,a1
		add.w	#$100,a1
		moveq	#4,d0
		bra		addlet
scroll3
		lea		scrollp3+8,a0
		bsr		show
		lea		scrollp3+$23f0,a0
		move.l	chargraf,a1
		add.w	#$100,a1
		moveq	#8,d0
		bra		addlet
scroll4
		lea		scrollp4+8,a0
		bsr		show
		lea		scrollp4+$23f0,a0
		move.l	chargraf,a1
		add.w	#$100,a1
		moveq	#12,d0
		bra		addlet
scroll5
		lea		scrollp1,a0
		bsr		show
		lea		scrollp1+$f0,a0
		move.l	chargraf,a1
		moveq	#0,d0
		bra		addlet
scroll6
		lea		scrollp2,a0
		bsr		show
		lea		scrollp2+$f0,a0
		move.l	chargraf,a1
		moveq	#4,d0
		bra		addlet
scroll7
		lea		scrollp3,a0
		bsr		show
		lea		scrollp3+$f0,a0
		move.l	chargraf,a1
		moveq	#8,d0
		bra		addlet
scroll8
		lea		scrollp4,a0
		bsr		show
		lea		scrollp4+$f0,a0
		move.l	chargraf,a1
		moveq	#12,d0
		bra		addlet

show
		add.w	scrloff,a0
		move.l	screen,a1
		lea		168*160(a1),a1
		rept		32
		movem.l	(a0)+,d0-d7/a2-a3
		movem.l	d0-d7/a2-a3,(a1)
		movem.l	(a0)+,d0-d7/a2-a3
		movem.l	d0-d7/a2-a3,40(a1)
		movem.l	(a0)+,d0-d7/a2-a3
		movem.l	d0-d7/a2-a3,80(a1)
		movem.l	(a0)+,d0-d7/a2-a3
		movem.l	d0-d7/a2-a3,120(a1)
		lea		$190(a0),a0
		lea		160(a1),a1
		endr
		rts

addlet	add.w	scrloff,a0
		moveq	#15,d3
addone	rept		4
		moveq	#0,d2
		move.w	(a1)+,d1
		swap		d1
		move.w	6(a1),d1
		move.w	d1,d2
		swap 	d2
		lsr.l	d0,d1
		lsr.l	d0,d2
		move.w	d1,8(a0)
		move.w	d1,8-$110(a0)
		move.w	d2,16(a0)
		move.w	d2,16-$110(a0)
		swap		d1
		or.w		d1,(a0)+
		move.w	-2(a0),-$112(a0)
		endr
		lea		$228(a0),a0
		addq.l	#8,a1
		dbf		d3,addone
		rts


*********************************
********  C I R C L E S  ********
*********************************

circles	lea		grafs+40+60*160,a0
		move.l	screen,a1
		lea		168*160+6(a1),a1
		rept		4		
		move.w	(a0),(a1)
		move.w	8(a0),8(a1)
		move.w	16(a0),144(a1)
		move.w	24(a0),152(a1)
		move.w	160(a0),160(a1)
		move.w	168(a0),168(a1)
		move.w	176(a0),304(a1)
		move.w	184(a0),312(a1)
		move.w	320(a0),320(a1)
		move.w	328(a0),328(a1)
		move.w	336(a0),464(a1)
		move.w	344(a0),472(a1)
		move.w	480(a0),480(a1)
		move.w	488(a0),488(a1)
		move.w	496(a0),624(a1)
		move.w	504(a0),632(a1)
		move.w	640(a0),640(a1)
		move.w	648(a0),648(a1)
		move.w	656(a0),784(a1)
		move.w	664(a0),792(a1)
		move.w	800(a0),800(a1)
		move.w	808(a0),808(a1)
		move.w	816(a0),944(a1)
		move.w	824(a0),952(a1)
		move.w	960(a0),960(a1)
		move.w	968(a0),968(a1)
		move.w	976(a0),1104(a1)
		move.w	984(a0),1112(a1)
		move.w	1120(a0),1120(a1)
		move.w	1128(a0),1128(a1)
		move.w	1136(a0),1264(a1)
		move.w	1144(a0),1272(a1)
		lea		1280(a0),a0
		lea		1280(a1),a1
		endr
		rts


screen	dc.l		$f8000

char_pal	dc.w		0,$220,$330,$440,$550,$660,$770,$555,0,0,0,0,0,0,0,0

chargraf	dc.l		charset
messpos	dc.l		startmess

startmess	dcb.b	10,' '
message	include	'scrltxt1.s'

wong_del	dc.w		7
wong_add	dc.w		$ff00

bbc_off	dc.l		0
bbc_off_pos  dc.l	0
bbc_posn	ds.l		16

mfp_cnt	dc.w		31
mfp_col1	dc.l		mfp_cols
mfp_col2	dc.l		mfp_cols
mfp_cols	dc.w		0,$111,$222,$333,$444,$555,$666,$777,$767,$757,$747,$737,$727,$717
		dc.w		$707,$607,$507,$407,$307,$207,$107,6,5,4,3,2,1
mfp_rept	dc.w		0,$111,$222,$333,$444,$555,$666,$777,$767,$757,$747,$737,$727,$717
		dc.w		$707,$607,$507,$407,$307,$207,$107,6,5,4,3,2,1
		dc.w		0,$111,$222,$333,$444,$555,$666,$777,$767,$757,$747,$737,$727,$717

music	incbin	'sapiens.mus'
charset	incbin	'phalanx.dat'
bbc_pal	incbin	'bbc_pal.dat'
bbc_pts	incbin	'bbc_pts.dat'
		dc.w		-1
bbc_graf	incbin	'bbc.dat'
grafs	incbin	'menu240a.pi1'
		
bbcs		dc.w		0	