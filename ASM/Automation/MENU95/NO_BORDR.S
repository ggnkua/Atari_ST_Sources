* No Top + Bottom Border Menu Source
* Written By ***Neil*** Of Cor Blimey

* 0 = Toggles 50/60 Hz
* 1...9 = Select Program


	MOVE.L	$4(A7),A5
	MOVE.L	#$100,-(A7)
	MOVE.L	A5,-(A7)
	MOVE.W	#$0,-(A7)
	MOVE.W	#$4A,-(A7)
	TRAP	#$01
	ADD.L	#12,A7

	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	MOVE.L	D0,savesp
	lea	$70000,A7

	clr.w	-(a7)
	pea.l	$70000
	pea.l	$70000
	move.w	#5,-(a7)
	trap	#$e
	lea.l	12(a7),a7

	lea.l	$70000,a0
loop	clr.l	(a0)+
	cmp.l	#$80000,a0
	bne.s	loop

	movem.l	piccols,d0-d7
	movem.l	d0-d7,$ffff8240.w
	swap.w	d0
	lea.l	hz_col(pc),a0
loop2	move.w	d0,(a0)+
	cmp.l	#end_hz,a0
	bne.s	loop2

	movem.l	$70000,d0-d7

	lea.l	pic,a0
	lea.l	$712c0,a1
	move.w	#$1f3f,d0
copypic	move.l	(a0)+,(a1)+
	dbra.w	d0,copypic

	bsr.w	intscra
	bsr.w	intscrb

	move.w	#5,-(a7)
	move.w	#26,-(a7)
	trap	#$e
	addq.l	#4,a7

	move.w	#6,-(a7)
	move.w	#26,-(a7)
	trap	#$e
	addq.l	#4,a7

	pea.l	my120_2(pc)
	move.w	#1,-(a7)
	move.w	#8,-(a7)
	move.w	#1,-(a7)
	move.w	#31,-(a7)
	trap	#$e
	lea.l	12(a7),a7

	clr.b	$fffffa1b.w

	move.l	$70.w,$40.w
	move.l	#my70,$70.w
	move.l	#$01,d0
	BSR	music

mainlp	move.w	clock,d7
mainlp2	move.w	#$200,d1
mainlp3	nop
	dbra.w	d1,mainlp3
	cmp.w	clock,d7
	beq.s	mainlp2

	move.b	$fffffc02,d7
	cmp.b	oldkey,d7
	beq.s	mainlp
	move.b	d7,oldkey

	cmp.b	#11,d7	* '0' ?
	beq	tog_hz

	cmp.b	#2,d7	* Spacebar ?
	bne.s	nextkey
	lea	g1(pc),a5
	bra	doload
	
nextkey	cmp.b	#3,d7
	bne.s	mainlp
	lea	g2(pc),a5

doload	move.l	$40.w,$70.w
	clr.b	$fffffa1b.w

	move.w	#5,-(a7)
	move.w	#27,-(a7)
	trap	#$e
	addq.l	#4,a7

	move.w	#6,-(a7)
	move.w	#27,-(a7)
	trap	#$e
	addq.l	#4,a7

	move.b	#7,$ffff8800.w
	move.b	$ffff8800.w,d1
	or.b	#$3f,d1
	moveq.w	#12,d0
clrsnd	move.b	d0,$ffff8800.w
	clr.b	$ffff8802.w
	dbra	d0,clrsnd
	move.b	#7,$ffff8800.w
	move.b	d1,$ffff8802.w

	move.w	#$777,$ffff8240.w
	clr.w	$ffff825e.w
	move.b	hz50_60,$ffff820a.w

* YOUR LOAD FILE STUFF HERE...
		clr.w	-(a7)
		pea	$78000
		move.l	(a7),-(a7)
		move.w	#$5,-(a7)
		trap	#14
		add.l	#$c,a7
		lea	$78000,a0
clrup		clr.l	(a0)+
		cmp.l	#$7fd00,a0
		bne.s	clrup

		move.l	a5,fadd+2
		move.l	#$77ff0,a7
		move.l	savesp,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
tt1		nop
tt4		clr.l $60000
		clr.w -(sp)
		pea $60000
		pea $60000
fadd		move.l #$ffffffff,-(sp)
		move.l #$4b0000,-(sp)
		trap #1
g1		dc.b "PIRATE.WAS",0,0,0
g2		dc.b "HOSTAGE.WAS",0

savesp		dc.l	0
		

tog_hz	lea.l	hz_col(pc),a0
tog_hz2	eor.w	#$111,(a0)+
	cmp.l	#end_hz,a0
	bne.s	tog_hz2
	eor.b	#2,hz50_60
	bra.w	mainlp

my70	move.w	#1076,d0
notop	nop
	dbra.w	d0,notop
	clr.b	$ffff820a.w
	nop
	nop
	nop
	move.b	#2,$ffff820a.w
	move.w	#41,bordcnt
	move.l	#colours,$30.w
	move.l	#my120,$120.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	addq.w	#1,clock

	bsr.w	_scrola
	bsr.w	_scrolb
	bsr.w	music+$2a
	rte

my118	clr.b	$fffffa11.w
	rte

my120	move.l	a0,$140.w
	move.l	$30.w,a0
	tst.w	(a0)
	beq.s	my120_1
	bmi.s	my120_end
	move.l	(a0)+,$ffff8240.w
	move.l	a0,$30.w
	move.l	$140.w,a0
	clr.b	$fffffa0f.w
	rte

my120_end
	clr.w	$ffff8240.w
	clr.b	$fffffa0f.w
	clr.b	$fffffa1b.w
	rte

my120_1	move.l	piccols,a0
	move.l	a0,$ffff8240.w

	move.l	$140.w,a0
	addq.l	#2,$30.w

	move.l	#my120_2,$120.w
	move.b	#5,$fffffa21.w
	clr.b	$fffffa0f.w
	rte

my120_2	move.l	a0,$140.w
	move.l	$30.w,a0
	move.w	(a0)+,$ffff8240.w
	move.l	a0,$30.w
	move.l	$140.w,a0
	clr.b	$fffffa0f.w
	subq.w	#1,bordcnt
	beq.s	my120_3
	rte

my120_3	rept	90
	nop
	endr
	clr.b	$ffff820a.w
	rept	18
	nop
	endr
	move.b	#2,$ffff820a.w
	move.b	#1,$fffffa21.w
	move.l	#my120,$120.w
	rte

_scrola	move.w	#3,d7
scr2a	move.l	scdat2a,a6
	lea.l	$70140,a0
	move.b	scdataa,d3
	addq.b	#1,d3
	moveq.w	#24,d6
scr3a	move.b	(a6)+,d2
	asl.b	d3,d2
	roxl	$98(a0)
	roxl	$90(a0)
	roxl	$88(a0)
	roxl	$80(a0)
	roxl	$78(a0)
	roxl	$70(a0)
	roxl	$68(a0)
	roxl	$60(a0)
	roxl	$58(a0)
	roxl	$50(a0)
	roxl	$48(a0)
	roxl	$40(a0)
	roxl	$38(a0)
	roxl	$30(a0)
	roxl	$28(a0)
	roxl	$20(a0)
	roxl	$18(a0)
	roxl	$10(a0)
	roxl	$8(a0)
	roxl	(a0)
	lea.l	160(a0),a0
	dbra.w	d6,scr3a

	lea.l	-25(a6),a6
	cmp.b	#8,d3
	bne.w	screxa

	clr.b	d3
	lea.l	25(a6),a6
	subq.b	#1,scshfta
	bne.w	screxa

scr4a	move.b	#4,scshfta
	move.l	sctptra,a0
scr5a	clr.l	d6
	move.b	(a0)+,d6
	move.b	intrpra-32(pc,d6),d6
	bmi.w	intscra
	bra.w	scr6a

intrpra	dc.b	44,28,44,44,44,44,44,30,33,34,44,44,26,31,27,44
	dc.b	14,35,36,37,38,39,40,41,42,43,44,32,33,44,34,29
	dc.b	44,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,45,46,47,48,-1

scr6a	move.l	a0,sctptra
	mulu.w	#100,d6
	lea.l	font(pc),a6
	add.w	d6,a6

screxa	move.b	d3,scdataa
	move.l	a6,scdat2a
	dbra.w	d7,scr2a

	rts	

intscra	move.l	#text,sctptra
	clr.l	d7
	clr.b	d3
	bra.w	scr4a

_scrolb	move.w	#1,d7
scr2b	move.l	scdat2b,a6
	lea.l	$79240,a0
	move.b	scdatab,d3
	addq.b	#1,d3
	moveq.w	#24,d6
scr3b	move.b	(a6)+,d2
	asl.b	d3,d2
	roxl	$98(a0)
	roxl	$90(a0)
	roxl	$88(a0)
	roxl	$80(a0)
	roxl	$78(a0)
	roxl	$70(a0)
	roxl	$68(a0)
	roxl	$60(a0)
	roxl	$58(a0)
	roxl	$50(a0)
	roxl	$48(a0)
	roxl	$40(a0)
	roxl	$38(a0)
	roxl	$30(a0)
	roxl	$28(a0)
	roxl	$20(a0)
	roxl	$18(a0)
	roxl	$10(a0)
	roxl	$8(a0)
	roxl	(a0)
	lea.l	160(a0),a0
	dbra.w	d6,scr3b

	lea.l	-25(a6),a6
	cmp.b	#8,d3
	bne.w	screxb

	clr.b	d3
	lea.l	25(a6),a6
	subq.b	#1,scshftb
	bne.w	screxb

scr4b	move.b	#4,scshftb
	move.l	sctptrb,a0
scr5b	clr.l	d6
	move.b	(a0)+,d6
	move.b	intrprb-32(pc,d6),d6
	bmi.w	intscrb
	bra.w	scr6b

intrprb	dc.b	44,28,44,44,44,44,44,30,33,34,44,44,26,31,27,44
	dc.b	14,35,36,37,38,39,40,41,42,43,44,32,33,44,34,29
	dc.b	44,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,45,46,47,48,-1

scr6b	move.l	a0,sctptrb
	mulu.w	#100,d6
	lea.l	font(pc),a6
	add.w	d6,a6

screxb	move.b	d3,scdatab
	move.l	a6,scdat2b
	dbra.w	d7,scr2b

	rts	

intscrb	move.l	#text2,sctptrb
	clr.l	d7
	clr.b	d3
	bra.w	scr4b


colours	dc.w	$200,$20,$300,$30,$400,$40,$500,$50,$600,$60,$700,$70,$700,$170,$700,$270,$700,$370,$700,$470,$700,$570,$700,$670,$700,$770
	dc.w	$700,$770,$700,$670,$700,$570,$700,$470,$700,$370,$700,$270,$700,$170,$700,$70,$600,$60,$500,$50,$400,$40,$300,$30,$200,$20,0

hz_col	ds.w	41
end_hz
	dc.w	$202,$777,$303,$666,$404,$555,$505,$444,$606,$333,$707,$222,$707,$111,$707,$001,$707,$002,$707,$003,$707,$004,$707,$005,$707,$006
	dc.w	$707,$006,$707,$005,$707,$004,$707,$003,$707,$002,$707,$001,$707,$111,$707,$222,$606,$333,$505,$444,$404,$555,$303,$666,$202,$777
	dc.l	-1

clock	dc.w	0
bordcnt	dc.w	0

sctptra	dc.l	0
scdat2a	dc.l	0
scshfta	dc.b	4
scdataa	dc.b	0

sctptrb	dc.l	0
scdat2b	dc.l	0
scshftb	dc.b	4
scdatab	dc.b	0

oldkey	dc.b	0
hz50_60	dc.b	2

text	DC.B	"AUTOMATION PRESENT YET ANOTHER COMPACT DISK   NUMBER 95     -     "
	DC.B	"THIS NO TOP AND BOTTOM BORDER INTRO WAS CODED BY NEIL OF COR BLIMEY - "
	DC.B	"THE MUSIC WAS RIPPED FROM OBLITERATOR BY NEIL OF COR BLIMEY     -     "
	DC.B	"AUTOMATION NOW CONSISTS OF... WAS (NOT WAS) - THE L.S.D - SHARAZ JEK - COR BLIMEY NOT 'ARF - THE UN-NAMEABLES - IAN C. AND BOB M.     -     "
	DC.B	"       WELL HERE WE ARE AGAIN!    WE GOT HOLD OF A DISK DONE BY A BUNCH OF WAGS "
	DC.B	"CALLING THEMSELVES WORKING GAMES    UNFORTUNATELY THE CARRIER COMMAND ON THEIR DISK "
	DC.B	"DID NOT WORK!  SOMEBODY FORGOT ABOUT THE CHECKSUMS!!                  BYE BYE        " 
	DC.B	"_"


text2	DC.B	"       HI TO      HAL , SERVO , THE PRESIDENT , EDITMAN , THE REPLICANTS , SPECIAL FX , "
	DC.B	"THE MEDWAY BOYS , REVOLUTION , SEWER SOFTWARE , PIRASOFT/ACU , CLIMAX , A-HA , "
	DC.B	"TURNIP , AND ALL ELSE WHO KNOW US!      "
	DC.B	"_"

	even

music	incbin	"oblit.mus"
font	incbin	"charset.nel"
piccols	dc.w	$000,$012,$710,$631,$123,$742,$234,$753
	dc.w	$345,$764,$456,$775,$666,$776,$777,$567
pic	incbin	"testmenu.pic"