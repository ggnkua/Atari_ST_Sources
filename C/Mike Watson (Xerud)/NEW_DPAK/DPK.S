	EXPORT	f4pak_prog

	EXPORT	auto_dat,auto2_prog,auto501_prog,auto_chunk,auto_chunk2

	EXPORT	a35_data,a31_prog,a33_prog,bmt_prog,a35_prog
	EXPORT	a31_data,a33_data

	EXPORT	bkill2_prog,bkill3_prog,bkillrp_prog,bkilljpm_data
	EXPORT	bkilljpm_prog

	EXPORT	bras_prog

	EXPORT	deg_data

	EXPORT	fir1_data,fir2_data,fir1_prog,fir2_prog

	EXPORT	gol_prog,golh_prog

	EXPORT	gremlin_data

	EXPORT	happy_prog

	EXPORT	ice2_3_4_data,ice1_1_prog,ice2_0_prog,ice2_2_prog
	EXPORT	ice1_1_data,ice2_2_3_4_prog,ice2_0_data,ice2_2_data

	EXPORT	idrag_data

	EXPORT	imp_data

	EXPORT	jpak_prog

	EXPORT	jam1_prog,jam3_prog,jam4_v2_prog,jam4_ice_prog
	EXPORT	jam4_lzw_prog,jam4_lzh_prog,jam_lzh_data,jam_lzw_data

	EXPORT	lecr_data

	EXPORT	lsd1_2_prog
	EXPORT	lsdjek_data

	EXPORT	mcode1_prog,mcode2_prog,mcode3_prog

	EXPORT	pa_prog

	EXPORT	pfxget_length,pfx_prog

	EXPORT	pomp1_5_data,pomp1_9_data

	EXPORT	pomp1_5_prog,pomp1_9_prog,pomp1_9_prog1,pomp1_9_prog2
	EXPORT	pomp2_3_prog,pomp2_6_prog,pomp3_0_prog

	EXPORT	ppget_length,pp2_data

	EXPORT	qp2_data

	EXPORT	rnc2_data,rnc2_prog,rncc_prog
	EXPORT	rnc1_data1,rnc1_data2

	EXPORT	speed2_prog,speed2_data
	EXPORT	speed3_prog,speed3_grz_prog,speed3_2_prog,speed3_data

	EXPORT	sup_prog

	EXPORT	squish1_prog,squish1_24_prog,squish2_prog

	EXPORT	sent2_5_data,sent2_5_prog,sent2_11_prog

	EXPORT	stos_prog

	EXPORT	thun1_data,thun2_data,thun1_prog

	EXPORT	unknown_prog2,unknown_prog3,unknown_prog4
	EXPORT	unknown_prog5

	EXPORT	vic2_data

;	IMPORT	buffer,buf00,freespace2
**********************************************************************
* Depack 4Pak Progfile
**********************************************************************
f4pak_prog:
	movem.l	d1-a6,-(a7)
	move.l	a1,a6
	move.l	a0,a5
	lea	$1c(a5),a0
	move.l	30(a5),d0
	add.l	d0,a0	
	lea	$1c(a1),a3
	lea	66(a5),a1
	lea	-116(a0),a2
	move.l	#$43ebffe4,(a2)+
	move.l	#$32fc601a,(a2)+
	addq	#8,a2
	move.l	#$4e714e71,(a2)+
	move.w	#$4e71,(a2)+
	addq	#8,a2
	move.l	#$4e714e71,(a2)+
	move.w	#$4e71,(a2)+
	addq	#8,a2
	move.w	#$4e75,(a2)+
	
	jsr	-162(a0)
	move.l	a0,d0
	sub.l	a6,d0
	movem.l	(a7)+,d1-a6
	rts
	
**********************************************************************
* Depack Atomic 3.1 datafile
**********************************************************************
a31_data:
	include	"d:\new_dpak\depacker.s\atm3_1.s"
**********************************************************************
* Depack Atomic 3.3 datafile
**********************************************************************
a33_data:
	include	"d:\new_dpak\depacker.s\atm3_3.s"
**********************************************************************
* Depack Atomic 3.5 datafile
**********************************************************************
a35_data:
	include	"d:\new_dpak\depacker.s\atm3_5.s"
**********************************************************************
* Depack Atomic 3.1 program
**********************************************************************
a31_prog:
	movem.l	a0-a6/d0-d7,-(a7)
	move.l	#$4e714e71,234(a0)	
	move.w	#$4e75,98(a0)
	move.l	a1,a5
	jsr	88(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	rts
**********************************************************************
* Depack Atomic 3.3 program
**********************************************************************
a33_prog:
	movem.l	a0-a6/d0-d7,-(a7)
	move.l	#$4e714e71,224(a0)	
	move.w	#$4e75,86(a0)
	move.l	a1,a5
	jsr	76(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	rts
**********************************************************************
* Depack Atomic 3.5 program
**********************************************************************
a35_prog:
	movem.l	a0-a6/d0-d7,-(a7)
	move.l	#$4e714e71,226(a0)	
	move.w	#$4e75,86(a0)	; modify depack code
	move.l	a1,a5
	jsr	76(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	rts
**********************************************************************
* Depack atomic3.3 bmt program
**********************************************************************

bmt_prog:
	MOVEM.L	D0-A6,-(A7)
	MOVE.L	#$4E714E71,$E0(A0)
	MOVE.W	#$4E75,$32(A0)
	MOVEA.L	A1,A5
	JSR	$28(A0)
	MOVEM.L	(A7)+,D0-a6
	RTS

**********************************************************************
* Depack BRAS program
**********************************************************************
bras_prog:
	movem.l	a0-a6/d0-d7,-(a7)
	move.l	64(a7),a4
	move.l	a4,a3
	move.w	#$4e71,154(a0)
	move.w	#$4e71,164(a0)
	move.w	#$4e75,340(a0)
	lea	448(a0),a5

	move.w	#$601a,(a1)
	move.l	52(a0),2(a1)
	move.l	56(a0),6(a1)
	move.l	60(a0),10(a1)
	move.l	64(a0),14(a1)
	lea	$1c(a1),a6

	jsr	146(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	rts
**********************************************************************
* Depack Bytekiller 2 program
**********************************************************************
bkill2_prog:
	movem.l	a0-a6/d0-d7,-(a7)
	move.l	a1,a5
	lea		426(a0),a6
	bsr	bkill_dp
	movem.l	(a7)+,a0-a6/d0-d7
	rts

**********************************************************************
* Depack Bytekiller 3 program
**********************************************************************
bkill3_prog:
	movem.l	a0-a6/d0-d7,-(a7)
	move.l	a1,a5
	lea		416(a0),a6
	bsr	bkill_dp
	movem.l	(a7)+,a0-a6/d0-d7
	rts
	
bkill_dp:
	include	"d:\new_dpak\depacker.s\bkill.s"

**********************************************************************
* Depack Bytekiller program - Russ Paynes
**********************************************************************
bkillrp_prog:
	movem.l	a0-a6/d0-d7,-(a7)
	move.l	#$4e714e71,204(a0)
	move.l	#$4e714e71,208(a0)
	move.w	#$4e71,212(a0)
	move.w	#$4e71,254(a0)
	move.w	#$4e71,284(a0)
	move.w	#$4e71,290(a0)
	jsr	200(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	rts
**********************************************************************
* Depack Bytekiller datafile - JPM
**********************************************************************
bkilljpm_data:
	include	"d:\new_dpak\depacker.s\jpm_bite.s"

**********************************************************************
* Depack Bytekiller program - JPM
**********************************************************************
bkilljpm_prog:
	movem.l	d0-a6,-(a7)
	move.l	a0,a6
	move.l	a1,a2
	move.l	#$4e714e71,68(a6)
	move.l	#$4e714e71,72(a6)
	move.w	#$4e71,178(a6)
	move.w	#$4e75,184(a6)
	move.l	64(a7),a0
	jsr	62(a6)
	movem.l	(a7)+,d0-a6
	rts

**********************************************************************
* Depack Automation v2.x datafile
**********************************************************************
auto_dat:
	include	"d:\new_dpak\depacker.s\auto.s"
**********************************************************************
* Depack Automation v2.x chunkfile
**********************************************************************
auto_chunk:
	movem.l	d0-a6,-(a7)
	move.l	a0,a4	; save file address
	lea	12(a0),a6	; get table of offsets
.2:	move.l	(a6)+,d0	; get file offset
	cmp.l	#'LSD!',d0
	beq.s	.1
	lea	(a4,d0.l),a0
	cmp.l	#'LSD!',(a0)
	beq.s	.3
	move.l	8(a4),d0
.4:	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	.4
	bra.s	.2
.3:	movem.l	a0-a6,-(a7)
	bsr	auto_dat
	movem.l	(a7)+,a0-a6
	add.l	4(a0),a1	; depack to here now
	bra.s	.2	
.1:	movem.l	(a7)+,d0-a6
	rts
**********************************************************************
* Depack Automation v5.01 chunkfile
**********************************************************************
auto_chunk2:
	movem.l	d0-a6,-(a7)
	move.l	a0,a4	; save file address
	lea	12(a0),a6	; get table of offsets
.2:	move.l	(a6)+,d0	; get file offset
	cmp.l	#'AU5!',d0
	beq.s	.1
	lea	(a4,d0.l),a0
	cmp.l	#'AU5!',(a0)
	beq.s	.3
	move.l	8(a4),d0
.4:	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	.4
	bra.s	.2
.3:	movem.l	a0-a6,-(a7)
	bsr	ice2_3_4_data
	movem.l	(a7)+,a0-a6
	add.l	8(a0),a1	; depack to here now
	bra.s	.2	
.1:	movem.l	(a7)+,d0-a6
	rts


**********************************************************************
* Depack Automation v2.x progfile
**********************************************************************
auto2_prog:
	move.w	#$4e75,170(a0)
	move.l	#$4e714e71,142(a0)
	move.w	#$4e71,146(a0)
	move.l	#$4e714e71,604(a0)
	move.w	#$4e71,608(a0)
	move.l	#$4e714e71,160(a0)
	move.w	#$4e71,164(a0)
	jsr	148(a0)
	rts
**********************************************************************
* Depack Automation v5.01 progfile
**********************************************************************
auto501_prog:
	movem.l	a0-a6/d0-d7,-(a7)
	move.w	#$4e75,170(a0)
	move.l	#$4e714e71,142(a0)
	move.w	#$4e71,146(a0)
	move.l	#$4e714e71,626(a0)
	move.l	#$4e714e71,160(a0)
	move.w	#$4e71,164(a0)
	jsr	148(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	rts

**********************************************************************
* Depack FIRE 1.0 program
**********************************************************************
fir1_prog:
	movem.l	a0-a6/d0-d7,-(a7)
	move.l	a1,a6
	move.l	#$4e714e71,66(a0)
	move.w	#$4e75,74(a0)
	jsr	54(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	rts
**********************************************************************
* Depack Degas elite picture
**********************************************************************
deg_data:
	include	"d:\new_dpak\depacker.s\degas.s"
**********************************************************************
* Depack Fire 1 datafile
**********************************************************************
fir1_data:
	include	"d:\new_dpak\depacker.s\fir1.s"
**********************************************************************
* Depack FIRE 2.0 data
**********************************************************************
fir2_data:
	include	"d:\new_dpak\depacker.s\fir2_0.s"
**********************************************************************
* Depack FIRE 2.0 program
**********************************************************************
fir2_prog:
	movem.l	a0-a6/d0-d7,-(a7)
	move.l	a1,a6
	move.w	#$204e,52(a0)
	move.w	#$4e75,64(a0)
	jsr	(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	rts
**********************************************************************
* Depack gollum prog
**********************************************************************
gol_prog:
	include	"d:\new_dpak\depacker.s\gol.s"
**********************************************************************
* Depack gollum prog - huffmans
**********************************************************************
golh_prog:
	include	"d:\new_dpak\depacker.s\gol_huff.s"

**********************************************************************
* Depack Gremlin datafile
**********************************************************************
gremlin_data:
	include	"d:\new_dpak\depacker.s\fungus.s"
**********************************************************************
* Depack ICE 1.1 datafile
**********************************************************************
ice1_1_data:
	include	"d:\new_dpak\depacker.s\ice1_1.s"
**********************************************************************
* Depack ICE 2.0 datafile
**********************************************************************
ice2_0_data:
	include	"d:\new_dpak\depacker.s\ice2_0.s"
**********************************************************************
* Depack ICE 2.2 datafile
**********************************************************************
ice2_2_data:
	include	"d:\new_dpak\depacker.s\ice2_2.s"
**********************************************************************
* Depack ICE 2.3/4 datafile
**********************************************************************
ice2_3_4_data:
	include	"d:\new_dpak\depacker.s\ice2_3_4.s"
**********************************************************************
* Depack ICE 1.1 program
**********************************************************************
ice1_1_prog:
	movem.l	a0-a6/d0-d7,-(a7)
	move.l	a1,a6
	move.l	#$4e714e71,66(a0)
	move.w	#$4e75,74(a0)
	jsr	54(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	rts
**********************************************************************
* Depack ICE 2.0 program
**********************************************************************
ice2_0_prog:
	movem.l	a0-a6/d0-d7,-(a7)
	move.l	a1,a6
	move.l	#$204e4e71,50(a0)
	move.w	#$4e75,64(a0)
	jsr	(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	rts
**********************************************************************
* Depack ICE 2.2/3/4 program
**********************************************************************
ice2_2_3_4_prog:
	movem.l	a0-a6/d0-d7,-(a7)
	move.l	a1,a6
	move.w	#$284e,50(a0)
	move.w	#$4e75,62(a0)
	jsr	(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	rts
**********************************************************************
* Depack SUPERIOR program
**********************************************************************
sup_prog:
	movem.l	a0-a6/d0-d7,-(a7)
	move.l	a1,a5
	move.l	#$4e714e71,178(a0)
	move.w	#$4e75,38(a0)
	jsr	(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	rts
**********************************************************************
* Depack Happy Progfile 
**********************************************************************
happy_prog:
	include	"d:\new_dpak\depacker.s\happy.s"

**********************************************************************
* Depack IMP datafile
**********************************************************************
imp_data:
	include	"d:\new_dpak\depacker.s\imp.s"
**********************************************************************
* Depack Ivory dragon data program
**********************************************************************
idrag_data:
	movem.l	a0-a6/d0-d7,-(a7)
	bsr	idd	
	movem.l	(a7)+,a0-a6/d0-d7
	rts
idd:
	include	"d:\new_dpak\depacker.s\dragon.s"
**********************************************************************
* Depack Jpak program
**********************************************************************
jpak_prog:
	movem.l	d0-a6,-(a7)
	move.l	#$4bf10800,178(a0)
	move.w	#$4e75,38(a0)
	jsr	(a0)
	movem.l	(a7)+,d0-a6
	rts
**********************************************************************
* Depack jam1 program
**********************************************************************
jam1_prog:
	movem.l	a0-a6/d0-d7,-(a7)
	move.l	#$4e714e71,440(a0)
	move.l	#$4e714e71,430(a0)
	move.w	#$4e71,434(a0)
	move.l	#$4e714e71,518(a0)
	move.w	#$4e71,522(a0)
	move.l	a0,634(a0)
	subq.l	#4,d0
	add.l	d0,634(a0)
	jsr	426(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	rts
**********************************************************************
* Depack jam3 lzh/v2 program
**********************************************************************
jam3_prog:
	movem.l	a0-a6/d0-d7,-(a7)
	move.l	a1,a6
	move.l	#$4e714e71,124(a0)
	move.l	#$4e714e71,128(a0)
	move.l	#$4e714e71,800(a0)
	move.w	#$4e71,804(a0)
	move.w	#$4e75,142(a0)
	jsr	120(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	rts
**********************************************************************
* Depack jam4 v2 program
**********************************************************************
jam4_v2_prog:
	movem.l	a0-a6/d0-d7,-(a7)
	move.l	#$4e714e71,126(a0)
	move.l	#$4e714e71,130(a0)
	move.l	#$4e714e71,426(a0)
	move.w	#$4e75,144(a0)
	jsr	122(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	rts
**********************************************************************
* Depack jam4 lzh program
**********************************************************************
jam4_lzh_prog:
	movem.l	a0-a6/d0-d7,-(a7)
	move.l	a1,a6
	move.l	#$4e714e71,126(a0)
	move.l	#$4e714e71,130(a0)
	move.l	#$4e714e71,822(a0)
	move.w	#$4e75,144(a0)
	jsr	122(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	rts
**********************************************************************
* Depack jam4 lzw program
**********************************************************************
jam4_lzw_prog:
	movem.l	a0-a6/d0-d7,-(a7)
	move.l	#$4e714e71,126(a0)
	move.l	#$4e714e71,130(a0)
	move.l	#$4e714e71,452(a0)
	move.w	#$4e75,144(a0)
	jsr	122(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	rts
**********************************************************************
* Depack jam4 ice program
**********************************************************************
jam4_ice_prog:
	movem.l	a0-a6/d0-d7,-(a7)
	move.l	#$4e714e71,126(a0)
	move.l	#$4e714e71,130(a0)
	move.l	#$4e714e71,442(a0)
	move.w	#$4e75,144(a0)
	jsr	122(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	rts
**********************************************************************
* Depack Jam LZH datafile
**********************************************************************
jam_lzh_data:
	include	"d:\new_dpak\depacker.s\jam_lzh.s"
**********************************************************************
* Depack Jam LZW datafile
**********************************************************************
jam_lzw_data:
	include	"d:\new_dpak\depacker.s\jam_lzw.s"
**********************************************************************
* Depack Le Crunch datafile
**********************************************************************
lecr_data:
	include	"d:\new_dpak\depacker.s\le_cr.s"

**********************************************************************
* Depack lsd 1.2 program
**********************************************************************
lsd1_2_prog:
	movem.l	a0-a6/d0-d7,-(a7)
	move.l	a0,a4
	lea	-4(a4,d0.l),a0
	move.l	#$4e714e71,426(a4)
	move.w	#$4e71,430(a4)
	jsr	404(a4)
	movem.l	(a7)+,a0-a6/d0-d7
	rts
**********************************************************************
* Depack LSD/JEK datafile
**********************************************************************
lsdjek_data:
	include	"d:\new_dpak\depacker.s\lsdjek.s"
**********************************************************************
* Depack Mpack 1.9 type 1 progfile
**********************************************************************
mcode1_prog:
	movem.l	d0-a6,-(a7)
	bsr	zap_regs
	move.l	a0,a6
	lea	604(a6),a0
	move.l	64(a7),a2
	jsr	230(a6)
	movem.l	(a7)+,d0-a6
	rts
**********************************************************************
* Depack Mpack 1.9 type 2 progfile
**********************************************************************
mcode2_prog:
	movem.l	d0-a6,-(a7)
	bsr	zap_regs
	move.l	a0,a6
	lea	320(a6),a0
	move.l	64(a7),a2
	jsr	228(a6)
	movem.l	(a7)+,d0-a6
	rts
**********************************************************************
* Depack Mpack 1.9 type 3 progfile
**********************************************************************
mcode3_prog:
	movem.l	d0-a6,-(a7)
	bsr	zap_regs
	move.l	a0,a6
	lea	452(a6),a0
	move.l	64(a7),a2
	jsr	230(a6)
	movem.l	(a7)+,d0-a6
	rts

zap_regs:	moveq	#0,d0
	move.l	d0,d1
	move.l	d1,d2
	move.l	d2,d3
	move.l	d3,d4
	move.l	d4,d5
	move.l	d5,d6
	move.l	d6,d7
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	rts
**********************************************************************
* Depack PA progfile
**********************************************************************
pa_prog:
	movem.l	d1-a6,-(a7)
	move.l	a1,a6
	move.w	#$601a,(a1)+
	lea	124(a0),a2
	movem.l	(a2)+,d3/d5/d7
	movem.l	d3/d5/d7,(a1)
	lea	12(a1),a1
	moveq	#0,d0
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.w	d0,(a1)+
	bsr	pa_dpk
	sub.l	a6,a1
	move.l	a1,d0
	movem.l	(a7)+,d1-a6
	rts
pa_dpk:	
	include	"d:\new_dpak\depacker.s\papack.s"
	
**********************************************************************
* Get length of PFX progfile
**********************************************************************
pfxget_length:
	move.l	a0,-(a7)
	movep.w	$E(a0),d0
	move.b	$D(a0),d0
	swap	d0
	movep.w	$C(a0),d0
	move.b	$B(a0),d0
	movem.l	(a7)+,a0
	rts
**********************************************************************
* Depack PFX progfile
**********************************************************************
pfx_prog:
	movem.l	d0-a6,-(a7)
	move.l	a1,a6
	move.l	a0,a4
	movep.w	$e(a4),d4
	move.b	$d(a4),d4
	swap	d4
	movep.w	$c(a4),d4
	move.b	$B(a4),d4
	moveq	#2,d0
	add.b	(a4),d0
	adda.w	d0,a4
	movea.l	a6,a3
	moveq	#0,d7
	move.l	a6,d5
	sub.l	#$FED,d5
	move.w	#$FFF,d3
	dbf	d7,.pfx08
.pfx07:	move.b	(a4)+,d6
	moveq	#7,d7
.pfx08:	lsr.b	#1,d6
	bcc.s	.pfx09
	move.b	(a4)+,(a6)+
	subq.l	#1,d4
	ble.s	.exit
	dbf	d7,.pfx08
	bra.s	.pfx07
.pfx09:	movep.w	1(a4),d0
	lsr.w	#4,d0
	move.b	(a4)+,d0
	move.l	a6,d1
	sub.l	d5,d1
	and.w	d3,d1
	sub.w	d1,d0
	neg.w	d0
	and.w	d3,d0
	neg.w	d0
	lea	-1(a6,d0.W),a0
	moveq	#$F,d1
	and.b	(a4)+,d1
	addq.w	#2,d1
	moveq	#1,d0
	add.w	d1,d0
.pfx0A:	move.b	(a0)+,(a6)+
	dbf	d1,.pfx0A
	sub.l	d0,d4
	ble.s	.exit
	dbf	d7,.pfx08
	bra.s	.pfx07
.exit:	movem.l	(a7)+,d0-a6
	rts
**********************************************************************
* Depack Pompey Pirates 1.5 datafile
**********************************************************************
pomp1_5_data:
	move.l	a1,a2
	include	"d:\new_dpak\depacker.s\pomp1_5.s"
**********************************************************************
* Depack Pompey Pirates 1.9 datafile
**********************************************************************
pomp1_9_data:
	move.l	a0,a4
	move.l	a4,a3
	move.l	a1,a2
	include	"d:\new_dpak\depacker.s\pomp1_9.s"
**********************************************************************
* Depack Pompey Pirates 1.5 progfile
**********************************************************************
pomp1_5_prog:
	movem.l	d0-a6,-(a7)
	move.l	64(a7),a4
	lea		462(a0),a2
	move.w	#$2649,58(a0)
	move.w	#$4e75,290(a0)
	move.w	#$d3e0,62(a0)
	move.l	#$24494e71,68(a0)
	move.l	#$4e714e71,72(a0)
	move.l	#$4e714e71,148(a0)
	jsr		56(a0)
	movem.l	(a7)+,d0-a6
	rts
**********************************************************************
* Depack Pompey Pirates 1.9 progfile
**********************************************************************
pomp1_9_prog:
	movem.l	d0-a6,-(a7)
	move.l	64(a7),a4
	move.w	#$2649,58(a0)
	move.w	#$4e71,64(a0)
	move.w	#$2449,66(a0)
	move.l	#$4e714e71,72(a0)
	move.w	#$4e71,76(a0)
	move.l	#$4e714e71,150(a0)
	move.w	#$4e75,292(a0)
	jsr		56(a0)
	movem.l	(a7)+,d0-a6
	rts
**********************************************************************
* Depack Pompey Pirates 1.9 progfile variation1
**********************************************************************
pomp1_9_prog1:
	movem.l	d0-a6,-(a7)
	move.l	a1,a2
	move.l	64(a7),a4
	move.l	#$4e714e71,124(a0)
	move.l	#$4e714e71,128(a0)
	move.l	#$4e714e71,204(a0)
	move.w	#$4e75,346(a0)
	jsr		112(a0)
	movem.l	(a7)+,d0-a6
	rts
**********************************************************************
* Depack Pompey Pirates 1.9 progfile variation2
**********************************************************************
pomp1_9_prog2:
	movem.l	d0-a6,-(a7)
	move.l	a1,a2
	move.l	64(a7),a4
	move.l	#$4e714e71,456(a0)
	move.l	#$4e714e71,460(a0)
	move.l	#$4e714e71,534(a0)
	jsr		444(a0)
	movem.l	(a7)+,d0-a6
	rts
**********************************************************************
* Depack Pompey Pirates 2.3 progfile
**********************************************************************
pomp2_3_prog:
	movem.l	d0-a6,-(a7)
	move.l	a1,a2
	move.l	64(a7),a4
	move.l	#$4e714e71,72(a0)
	move.w	#$4e71,76(a0)
	move.l	#$4e714e71,146(a0)
	move.w	#$4e75,154(a0)
	jsr		60(a0)
	movem.l	(a7)+,d0-a6
	rts
**********************************************************************
* Depack Pompey Pirates 2.6 progfile variation
**********************************************************************
pomp2_6_prog:
	movem.l	d0-a6,-(a7)
	move.l	a1,a2
	move.l	64(a7),a4
	move.l	#$4e714e71,70(a0)
	move.w	#$4e71,74(a0)
	move.l	#$4e714e71,142(a0)
	move.w	#$4e75,150(a0)
	jsr		60(a0)
	movem.l	(a7)+,d0-a6
	rts
**********************************************************************
* Depack Pompey Pirates 3.0 progfile
**********************************************************************
pomp3_0_prog:
	movem.l	d0-a6,-(a7)
	move.l	a1,a2
	move.l	64(a7),a4
	move.l	#$4e714e71,86(a0)
	move.l	#$4e714e71,60(a0)
	move.w	#$4e71,58(a0)
	move.w	#$4e71,90(a0)
	move.w	#$4e75,306(a0)
	jsr		56(a0)
	movem.l	(a7)+,d0-a6
	rts
**********************************************************************
* Get length of Power Packer2 datafile
**********************************************************************
ppget_length:
	movem.l	d1/a0,-(a7)
	moveq	#1,d1
	move.l	-(a0),d0
	tst.b	d0
	beq.s	.NoEmptyBits
	bsr.s	.ReadBit
	subq.b	#1,d0
	lsr.l	d0,d1
.NoEmptyBits:
	lsr.l	#8,d0
	movem.l	(a7)+,d1/a0
	rts

.ReadBit:	lsr.l	#1,d1
	beq.s	.GetNextLong
	rts

.GetNextLong:
	move.l	-(a0),d1
	roxr.l	#1,d1
	rts
**********************************************************************
* Depack Power Packer2 datafile
**********************************************************************
pp2_data:
	include	"d:\new_dpak\depacker.s\pp2.s"
**********************************************************************
* Depack Qpack2 datafile
**********************************************************************
qp2_data:
	include	"d:\new_dpak\depacker.s\qp2.s"
**********************************************************************
* Depack RNC1 datafile type 1
**********************************************************************
rnc1_data1:
	include	"d:\new_dpak\depacker.s\rnc_1_1.s"
**********************************************************************
* Depack RNC1 datafile type 2
**********************************************************************
rnc1_data2:
	include	"d:\new_dpak\depacker.s\rnc_1_2.s"
**********************************************************************
* Depack RNC copylock progfile
**********************************************************************
rncc_prog:
	movem.l	d0-a6,-(a7)
	lea	(a1),a2
	move.w	#$4e75,126(a0)
	move.l	#$4e7145f2,50(a0)
	clr.w	60(a0)
	jsr	32(a0)
	movem.l	(a7)+,d0-a6
	rts
**********************************************************************
* Depack RNC2 progfile
**********************************************************************
rnc2_prog:
	movem.l	d0-a6,-(a7)
	move.w	#$601a,(a1)+
	movem.l	624(a0),d0-d3
	movem.l	d0-d3,(a1)
	lea	16(a1),a1
	clr.l	(a1)+
	clr.l	(a1)+
	clr.w	(a1)+
	lea	642(a0),a0
	bsr	rnc2_data
	movem.l	(a7)+,d0-a6
	rts
**********************************************************************
* Depack RNC2 datafile
**********************************************************************
rnc2_data:
	include	"d:\new_dpak\depacker.s\rnc_2.s"
**********************************************************************
* Depack Sentry2 datafile
**********************************************************************
sent2_5_data:
	include	"d:\new_dpak\depacker.s\sent_2.s"
**********************************************************************
* Depack Sentry2.5 progfile
**********************************************************************
sent2_5_prog:
	movem.l	d0-a6,-(a7)
	move.l	a0,a4
	lea	$1c(a4),a6
	add.l	2(a0),a0
	lea	$1c(a0),a0
	move.w	#$4e75,106(a4)
	move.l	a1,a3
	jsr	102(a4)
	movem.l	(a7)+,d0-a6
	rts
**********************************************************************
* Depack Sentry2.11 progfile
**********************************************************************
sent2_11_prog:
	movem.l	d0-a6,-(a7)
	move.l	a0,a4
	lea	$1c(a4),a6
	add.l	2(a0),a0
	lea	$1c(a0),a0
	move.w	#$4e75,136(a4)
	move.l	a1,a3
	jsr	132(a4)
	movem.l	(a7)+,d0-a6
	rts
**********************************************************************
* Depack Speed Packer2 progfile
**********************************************************************
speed2_prog:
	movem.l	d0-a6,-(a7)
	lea	542(a0),a5
	move.l	#$4e714e71,212(a0)
	move.l	#$4e714e71,236(a0)
	move.w	#$6014,250(a0)
	jsr	212(a0)
	movem.l	(a7)+,d0-a6
	rts
**********************************************************************
* Depack Speed Packer2 datafile
**********************************************************************
speed2_data:
	include	"d:\new_dpak\depacker.s\speed2.s"
**********************************************************************
* Depack Speed Packer3 progfile
**********************************************************************
speed3_prog:
	movem.l	d0-a6,-(a7)
	move.l	#'SPv3',(a0)
	bsr	speed3_data
	lea	-$1c(a0),a1
	addq	#2,a1
	add.l	d0,a0
	move.l	-(a0),(a1)+
	move.l	-(a0),(a1)+
	move.l	-(a0),(a1)+
	movem.l	(a7)+,d0-a6
	rts
**********************************************************************
* Depack Speed Packer3 progfile
**********************************************************************
speed3_2_prog:
	movem.l	d0-a6,-(a7)
	move.b	#'S',(a0)
	move.b	#'P',1(a0)
	bsr	speed3_data	
	lea	-$1c(a0),a1
	move.w	#$601a,(a1)+
	add.l	d0,a0
	move.l	-(a0),(a1)+
	move.l	-(a0),(a1)+
	move.l	-(a0),(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.w	(a1)+
	movem.l	(a7)+,d0-a6
	rts
**********************************************************************
* Depack Speed Packer2 datafile
**********************************************************************
speed3_data:
	include	"d:\new_dpak\depacker.s\speed3.s"
**********************************************************************
* Depack Squish V1 progfile
**********************************************************************
squish1_prog:
	movem.l	d0-a6,-(a7)
	lea		752(a0),a3
	move.l	a1,a5
	move.l	a5,a2
	move.l	a3,d2
	add.l	d0,d2
	move.w	#$4e75,532(a0)
	jsr	458(a0)
	movem.l	(a7)+,d0-a6
	rts
**********************************************************************
* Depack Squish V1.2/4 progfile
**********************************************************************
squish1_24_prog:
	movem.l	d0-a6,-(a7)
	lea		900(a0),a3
	move.l	a1,a5
	move.w	#$4e75,530(a0)
	jsr	448(a0)	
	movem.l	(a7)+,d0-a6
	rts
**********************************************************************
* Depack Squish V2 progfile
**********************************************************************
squish2_prog:
	include	"d:\new_dpak\depacker.s\squish2.s"
**********************************************************************
* Depack STOS progfile
**********************************************************************
stos_prog:
	include	"d:\new_dpak\depacker.s\stos.s"
**********************************************************************
* Depack Thunder V1 datafile
**********************************************************************
thun1_data:
	include	"d:\new_dpak\depacker.s\thunder1.s"
**********************************************************************
* Depack Thunder V1.1/2.0 datafile
**********************************************************************
thun2_data:
	include	"d:\new_dpak\depacker.s\thunder2.s"
**********************************************************************
* Depack Thunder V1 progfile
**********************************************************************
thun1_prog:
	movem.l	d0-a6,-(a7)
	lea	422+12(a0),a2
	move.w	#$4e75,130(a0)
	lea	(a1),a4
	jsr	64(a0)
	movem.l	(a7)+,d0-a6
	rts
**********************************************************************
* Depack Unknown progfile
**********************************************************************
unknown_prog2:
	movem.l	d0-a6,-(a7)
	lea	(a1),a3
	move.l	64(a7),a6
	jsr	248(a6)	
	movem.l	(a7)+,d0-a6
	rts
unknown_prog3:
	movem.l	d0-a6,-(a7)
	move.w	#$284e,50(a0)
	move.w	#$4e75,62(a0)
	lea	(a1),a6
	jsr	38(a0)
	movem.l	(a7)+,d0-a6
	rts
unknown_prog4:
	movem.l	d0-a6,-(a7)
	move.l	#$4bf10800,204(a0)
	move.w	#$4e75,64(a0)	
	jsr	54(a0)
	movem.l	(a7)+,d0-a6
	rts
unknown_prog5:
	movem.l	d0-a6,-(a7)
	move.l	64(a7),a6
	jsr	354(a6)
	movem.l	(a7)+,d0-a6
	rts

**********************************************************************
* Depack Vic 2 datafile
**********************************************************************
vic2_data:
	include	"d:\new_dpak\depacker.s\vic2.s"
	even
buffer:	ds.b	160
	even
buf00:	ds.b	1536
	even
freespace2:	ds.b	644
	even