****************************************************************

checksum	equ	1	*1=checksum, 0=pas de checksum

test_chk	equ	0	*1=calcul du cheksum, 0=rien

music	equ	1	*1=musique, 0= pas de musique

exec	equ	1	*1=exec prg, 0=quit

valeur	equ	$E12C	*valeur du checksum

****************************************************************


	include	dsp_play.inc
lg_lgn	equ	640*2
nb_lgn	equ	100
ht_img	equ	nb_lgn*lg_lgn
nb_rept	equ	24
nb_tours	equ	5
color_font	equ	$ffff

	OPT	O+

	TEXT
	
debut	pea	all
	move.w	#$26,-(a7)
	trap	#14
	addq.l	#6,a7

	ifne	test_chk
	clr.w	-(a7)
	trap	#1
	endc
	ifne	exec
	jmp	new_prg
	else
	clr.w	-(a7)
	trap	#1
	endc

	dc.b	"Intro v1 by Corpo/Supremacy."
	dc.b	"Code Chaos/sanity, Corpo, Nullos/Dnt."
	dc.b	"Get out of here!"
	even
all	nop
	ifne	checksum
	move.w	#valeur,-(a7)
	endc
	
	MOVE.L	#$3111,D0
	MOVEC	D0,CACR
	BSR	SAVE_OLDSCRN
	bsr	MON_TYPE
	tst.w	vga
	bne.s	.rvb
	MOVE.W	#$134,D0
	bra.s	.vga
.rvb	move.w	#$24,d0
.vga	BSR	SET_SCRN
	tst.w	vga
	beq.s	.vga2
	sub.w	#$28,$ffff82a8.w
	add.w	#$28,$ffff82aa.w
.vga2	
.rvb2	bsr	copy_image
	MOVEA.L	SCREEN,A0
	bsr	clr_scrn
	move.l	SCREEN2,a0
	bsr	clr_scrn
	bsr	copy_logo

	BSR	INIT_INT
	MOVE.W	#$400,zoom_y
	MOVE.W	#$400,zoom_x
	MOVE.W	#$100,sin_rot
	MOVE.W	#750,tempo_deform	*(15 secondes)
	move.l	SCREEN,a1
	bsr	aff_text
	move.l	SCREEN2,a1
	bsr	aff_text
	bsr	fill_text_buffer

	ifne	checksum
	move.l	#end_data,d0
	sub.l	#start_data,d0
	lsr.l	#1,d0
	moveq	#0,d1
	lea	start_data,a0
chk	add.w	(a0)+,d1
	dbra	d0,chk
	swap	d0
	subq.w	#1,d0
	bmi.s	tst
	swap	d0
	bra.s	chk
tst	
	ifne	test_chk
	clr.l	d0
	move.w	d1,d0
	endc
	sub.w	(a7)+,d1

	ifne	test_chk
	illegal
	jmp	EXIT
	endc

verif	beq.s	MAIN_LOOP
	move.l	d1,err+2
	endc

MAIN_LOOP	BSR	SWAP_SCRN
	BSR.S	ROT_FIG
	BSR	AFF_FIG
	bsr	aff_text_buffer
.TST	CMPI.B	#$3A,$FFFFFC02.W	*caps lock=pause
	BEQ.S	.TST
	CMPI.B	#$B9,$FFFFFC02.W
	BNE.s	MAIN_LOOP
	ifne	checksum
	lea	debut,a0
	move.w	((all+4)-debut,a0),d0
	neg.w	d0
	cmp.w	#-valeur,d0
verif2	beq.s	err
	bra.s	*+100
	endc
err	JMP	EXIT

ROT_FIG	MOVE.W	zoom_y,D0
	ADDI.W	#$5,D0	elargissement en Y
	ANDI.W	#$FFF,D0
	MOVE.W	D0,zoom_y
	MOVE.W	(TAB_SIN,D0.W*2),D1
	EXT.L	D1
	ADDI.L	#$4000,D1
	BPL.S	ROT_FIGS1
	MOVEQ	#0,D1
ROT_FIGS1	ASR.L	#7,D1
	ADDI.L	#20,D1
	MOVE.L	D1,sin_zy
	MOVE.W	zoom_x,D0
	ADDI.W	#$5,D0	elargissement en X
	ANDI.W	#$FFF,D0
	MOVE.W	D0,zoom_x
	MOVE.W	(TAB_SIN,D0.W*2),D1
	EXT.L	D1
	ADDI.L	#$4000,D1
	BPL.S	ROT_FIGS2
	MOVEQ	#0,D1
ROT_FIGS2	ASR.L	#7,D1
	ADDI.L	#20,D1
	MOVE.L	D1,sin_zx

	TST.W	tempo_deform
	BNE.S	ROT_FIGS3
	ADDI.W	#$14,zoom_y
	ADDI.W	#$11,zoom_x
	BRA.S	ROT_FIGS4
ROT_FIGS3	SUBQ.W	#1,tempo_deform
ROT_FIGS4	MOVE.W	crd_x,D0
	ADDQ.W	#2,D0	sinusoid en X (up down)
	ANDI.W	#$FFF,D0
	MOVE.W	D0,crd_x
	MOVE.W	(TAB_SIN,D0.W*2),D1
	ASR.W	#3,D1
	MOVE.W	D1,sin_cx
	MOVE.W	crd_y,D0
	ADDQ.W	#3,D0	sinusoid en Y (up down)
	ANDI.W	#$FFF,D0
	MOVE.W	D0,crd_y
	MOVE.W	(TAB_SIN,D0.W*2),D1
	ASR.W	#3,D1
	MOVE.W	D1,sin_cy
	MOVE.W	rotation,D0
	ADDQ.W	#2,D0	rotation image
	ANDI.W	#$FFF,D0
	MOVE.W	D0,rotation
	MOVE.W	(TAB_SIN,D0.W*2),D1
	ASR.W	#8,D1
	ASR.W	#1,D1
	ADD.W	D1,sin_rot
	RTS

AFF_FIG	MOVE.W	sin_rot,sin_rot2
	LEA	TMP_PIC16B,A2
	MOVEA.L	SCREEN2,A3
	add.l	#(160-(nb_tours*nb_rept))*2,A3

	LEA	TAB_SIN,A0
	MOVE.W	sin_rot2,D0
	ANDI.W	#$FFF,D0
	MOVE.W	(0,A0,D0.W*2),D1
	EXT.L	D1
	MULS.L	sin_zx,D1
	ASR.L	#4,D1
	MOVE.L	D1,const_1
	MOVEA.W	D1,A4
	SWAP	D1
	MOVE.W	D1,D4
	SUBI.W	#$400,D0
	ANDI.W	#$FFF,D0
	MOVE.W	(0,A0,D0.W*2),D1
	EXT.L	D1
	MULS.L	sin_zx,D1
	ASR.L	#4,D1
	MOVE.L	D1,const_3
	MOVE.W	D1,D7
	SWAP	D1
	MOVE.W	D1,D5
	MOVE.W	sin_rot2,D0
	ADDI.W	#$400,D0
	ANDI.W	#$FFF,D0
	MOVE.W	(0,A0,D0.W*2),D1
	EXT.L	D1
	MULS.L	sin_zy,D1
	ASR.L	#4,D1
	ASR.L	#8,D1
	CLR.L	const_2
	MOVE.W	D1,const_2
	MOVEA.W	D1,A5
	SUBI.W	#$400,D0
	ANDI.W	#$FFF,D0
	MOVE.W	(0,A0,D0.W*2),D1
	EXT.L	D1
	MULS.L	sin_zy,D1
	ASR.L	#4,D1
	ASR.L	#8,D1
	CLR.L	const_4
	MOVE.W	D1,const_4
	MOVEA.W	D1,A6
	MOVE.L	const_1,D1
	MULS.L	#nb_rept,D1
	MOVE.L	D1,const_5
	MOVE.L	const_2,D1
	MULS.L	#nb_rept,D1
	MOVE.L	D1,const_6
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D6
	MOVE.L	const_3,D1
	MULS.L	#$60,D1
	MOVE.W	D1,D6
	SWAP	D1
	ADD.W	sin_cx,D1
	MOVE.L	const_4,D2
	MULS.L	#-$60,D2
	SWAP	D2
	MOVE.W	sin_cy,D3
	LSL.W	#8,D3
	ADD.W	D3,D2
	MOVEA.W	const_2,A5
	MOVE.W	const_1,D4
	MOVEA.W	const_1+2,A4
	LEA	AFF_FIGS4+2,A0
	MOVE.W	D2,D0
	MOVE.B	D1,D0
	ADD.W	A5,D2
	ADD.W	A4,D6
	ADDX.W	D4,D1
	MOVEQ	#0,D3
	MOVE.W	D0,D3
	ANDI.W	#-2,D3
	MOVE.W	D3,(A0)
	ADDQ.W	#4,A0
	MOVE.W	#nb_rept-1,D7
AFF_FIGS1	MOVE.W	D2,D0
	MOVE.B	D1,D0
	ADD.W	A5,D2
	ADD.W	A4,D6
	ADDX.W	D4,D1
	MOVE.W	D0,D3
	ANDI.W	#-2,D3
	*ori.w	#1,d3
	MOVE.W	D3,(A0)
	ADDQ.W	#6,A0
	DBF	D7,AFF_FIGS1

	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D6
	MOVEQ	#nb_tours-1,D7
AFF_FIGS2	MOVE.W	D7,-(A7)
	MOVEA.L	D1,A0
	MOVEA.L	D2,A1
	SWAP	D6
	MOVEA.W	const_4,A5
	MOVE.W	const_3,D4
	MOVEA.W	const_3+2,A4
	MOVE.L	#lg_lgn-(nb_rept*4),D5
	MOVEQ	#0,D0
	MOVEQ	#0,D7
	MOVE.L	#$FFFE,D0
	MOVE	#nb_lgn-1,D3
AFF_FIGS3	MOVE.W	D2,D7
	MOVE.B	D1,D7
	AND.L	D0,D7
	MOVEA.L	A2,A6
	ADDA.L	D7,A6
	moveq	#0,d7
AFF_FIGS4	bra.s	.next
	nop
.next	
	rept	nb_rept
	MOVE.w	2(A6),D7
	move.l	D7,(A3)+
	endr

	ADD.W	A5,D2
	ADD.W	A4,D6
	ADDX.W	D4,D1
	ADD.W	D5,A3	lgn suivante
	DBF	D3,AFF_FIGS3
	SUBA.L	#ht_img-(nb_rept*4),A3
	SWAP	D6
	MOVE.W	A0,D1
	MOVE.W	A1,D2
	MOVE.W	const_5,D4
	ADD.W	const_6,D2
	ADD.W	const_5+2,D6
	ADDX.W	D4,D1
	MOVE.W	(A7)+,D7
	DBF	D7,AFF_FIGS2
	RTS

clr_scrn	CLR.L	D1
	MOVE.L	#$95ff,D0
.CLR_SCRN	MOVE.L	D1,(A0)+
	DBF	D0,.CLR_SCRN
	rts

aff_text	lea	text,a0
	lea	82(a1),a1
	lea	FONT,a2
	move.w	#color_font,d5
	swap	d5
	move.w	#color_font,d5
	moveq	#0,d4
	moveq	#24,d2
.bcl	moveq	#29,d3
.bcl2	move.b	(a0)+,d4
	beq.s	.fin
	cmp.b	#$d,d4
	beq.s	.next_line
	cmp.b	#$20,d4
	beq.s	.space
	lea	(0,a2,d4.w*8),a3
	lea	(a1),a4
	bsr.s	aff_chr
.space	lea	16(a1),a1
	dbra	d3,.bcl2
	cmp.b	#$d,(a0)
	bne.s	.ok
	addq.w	#1,a0
.ok	lea	7*640+160(a1),a1
	dbra	d2,.bcl
.fin	rts

.next_line	addq.w	#1,d3
	lsl.w	#1,d3
	lea	(0,a1,d3.w*8),a1
	lea	7*640+160(a1),a1
	dbra	d2,.bcl
	rts

aff_chr	moveq	#7,d7	*a3=chr dans fonte
.bcl	move.b	(a3)+,d0	*a4=ecran plac‚
	bsr.s	aff_line
	lea	640-16(a4),a4
	dbra	d7,.bcl
	rts

aff_line	moveq	#7,d1
.bcl	btst	d1,d0
	beq.s	.vide
	move.w	d5,(a4)+
	dbra	d1,.bcl
	rts
.vide	clr.w	(a4)+
	dbra	d1,.bcl
	rts

MON_TYPE	move.w	#89,-(a7)
	trap	#14
	addq.l	#2,a7
	tst.w	d0
	beq	EXIT
	cmp.b	#2,d0
	beq.s	.vga
	move.w	#1,vga	*rvb
	rts
.vga	clr.w	vga	*vga
	rts

fill_text_buffer
	lea	text_buffer,a1
	move.l	SCREEN,a0
	lea	80(a0),a0
	moveq	#80,d2	
	move	#99,d0
.bcl	move	#239,d1
.pix	move.w	(a0)+,d3
	beq	.repeat
	tst.l	d2
	beq.s	.empty

	cmp.l	#2,d2
	bne.s	.non2
	move.w	#$5448,(a1)+
	bra.s	.empty

.non2	cmp.l	#4,d2
	bne.s	.non4
	move.w	#$5848,(a1)+
	bra.s	.empty

.non4	cmp.l	#6,d2
	bne.s	.non6
	move.w	#$5c48,(a1)+
	bra.s	.empty

.non6	cmp.l	#8,d2
	bne.s	.non8
	move.w	#$5048,(a1)+
	bra.s	.empty
	
.non8	cmp.l	#$8000,d2
	bge.s	.noncourt
	move.w	#$d0fc,(a1)+
	move.w	d2,(a1)+
	bra.s	.empty

.noncourt	move.w	#$d1fc,(a1)+
	move.l	d2,(a1)+

.empty	moveq	#0,d2
	cmp.w	#$30c0,-2(a1)
	bne.s	.court
	move.w	#$20c0,-2(a1)
	bra.s	.ret
.court	move.w	#$30c0,(a1)+
.ret	dbra	d1,.pix

	add.l	#640+160,d2
	lea	160+640(a0),a0
	dbra	d0,.bcl
	move.w	#$4e75,(a1)
	rts

.repeat	addq.l	#2,d2
	bra.s	.ret


aff_text_buffer
	move.w	#color_font,d0
	swap	d0
	move.w	#color_font,d0
	move.l	SCREEN2,a0
	jmp	text_buffer

copy_logo	move.l	SCREEN,a0
	move.l	SCREEN2,a1
	lea	logo+18,a2
	move.l	#640*(240-57),d0
	adda.l	d0,a0
	adda.l	d0,a1
	move	#((57*640)/4)-1,d0
.bcl	move.l	(a2),(a0)+
	move.l	(a2)+,(a1)+
	dbra	d0,.bcl
	rts

SAVE_OLDSCRN	MOVE.B	$484.W,OLD_484
	CLR.B	$484.W
	BSR	GET_MODE
	MOVE.W	D0,OLD_MODE
	BSR	GET_SLOG
	MOVE.L	D0,OLD_SLOG
	BSR	GET_PHYS
	MOVE.L	D0,OLD_PHYS
	ADDI.L	#$F,SCREEN2
	ADDI.L	#$F,SCREEN
	*ADDI.L	#$F,SCREEN3
	ANDI.L	#-$10,SCREEN2
	ANDI.L	#-$10,SCREEN
	*ANDI.L	#-$10,SCREEN3
	RTS

SET_SCRN	MOVE.W	D0,-(A7)
	MOVE.W	D0,-(A7)
	MOVE.W	#3,-(A7)
	MOVE.L	SCREEN,-(A7)
	MOVE.L	SCREEN,-(A7)
	MOVE.W	#5,-(A7)
	BSR.S	VSYNC
	BSR.S	VSYNC
	TRAP	#$E
	ADDA.W	#$E,A7
	MOVE.W	#$58,-(A7)
	TRAP	#$E
	ADDQ.W	#4,A7
	clr.l	$ffff9800.w
	RTS

VSYNC	MOVE.W	#$25,-(A7)
	TRAP	#$E
	ifne	checksum
	cmp.b	#$67,verif
	bne.s	.fuck
	endc
	ADDQ.W	#2,A7
.fuck	RTS

GET_MODE	MOVE.W	#-1,-(A7)
	MOVE.W	#$58,-(A7)
	TRAP	#$E
	ifne	checksum
	cmp.b	#$67,verif2
	bne.s	.fuck
	endc
	ADDQ.W	#4,A7
.fuck	RTS

GET_PHYS	MOVE.W	#3,-(A7)
	TRAP	#$E
	ADDQ.W	#2,A7
	RTS

GET_SLOG	MOVE.W	#2,-(A7)
	TRAP	#$E
	ADDQ.W	#2,A7
	RTS

INIT_INT	MOVE.B	#$12,$FFFFFC02.W
	ifne	music
	lea	mod,a0
	lea	freq_buf,a1
	jsr	dsp_play

	move.l	dsp_play+8,a0
	MOVE.b	#1,dma2dsp(a0)
	clr.b	song_stop(a0)
	endc

	LEA	TMP_OLDINT,A0
	MOVE	USP,A1
	MOVE.L	A1,(A0)+
	MOVE.L	$4D2.W,(A0)+
	MOVE.L	$70.W,(A0)+
	MOVE.L	$120.W,(A0)+
	move.l	$110.w,(a0)+
	MOVE.B	$FFFFFA1D.W,(A0)+
	MOVE.B	$FFFFFA25.W,(A0)+
	MOVE.B	$FFFFFA15.W,(A0)+
	MOVE.B	$FFFFFA17.W,(A0)+
	MOVE.B	$FFFFFA13.W,(A0)+
	MOVE.B	$FFFFFA07.W,(A0)+
	MOVE.B	$FFFFFA09.W,(A0)+
	MOVE.w	#$2700,SR
	MOVE.L	#VBL,$70.W
*	MOVE.L	#HBL,$120.W
	ORI.B	#1,$FFFFFA13.W
	ORI.B	#1,$FFFFFA07.W
	ANDI.B	#$21,$FFFFFA07.W
	ANDI.B	#$40,$FFFFFA09.W
	ifne	music
	bclr	#3,$fffffa17.w
	andi.b	#$f0,$fffffa1d.w
	move.l	#play,$110.w
	bset	#4,$fffffa09.w
	bset	#4,$fffffa15.w
	move.b	#246,$fffffa25.w
	ori.b	#7,$fffffa1d.w
	endc
	MOVE	#$2300,SR
	RTS

EXIT	MOVE.W	#7,-(A7)
	TRAP	#1
	ADDQ.L	#2,A7
	BSR	RESTORE_INT
	BSR.S	RESTORE_SCRN
	rts

RESTORE_SCRN
	MOVE.B	OLD_484,$484.W
	MOVE.W	OLD_MODE,D0
	MOVE.W	D0,-(A7)
	MOVE.W	D0,-(A7)
	MOVE.W	D0,-(A7)
	MOVE.W	#3,-(A7)
	MOVE.L	OLD_SLOG,-(A7)
	MOVE.L	OLD_PHYS,-(A7)
	MOVE.W	#5,-(A7)
	BSR	VSYNC
	BSR	VSYNC
	TRAP	#$E
	ADDA.W	#$E,A7
	MOVE.W	#$58,-(A7)
	BSR	VSYNC
	BSR	VSYNC
	TRAP	#$E
	ADDQ.W	#4,A7
	MOVE.W	#3,-(A7)
	MOVE.L	OLD_SLOG,-(A7)
	MOVE.L	OLD_PHYS,-(A7)
	MOVE.W	#5,-(A7)
	BSR	VSYNC
	BSR	VSYNC
	TRAP	#$E
	ADDA.W	#$E,A7
	BSR	VSYNC
	BSR	VSYNC
	MOVEM.W	OLD_PAL,D0-D7
	MOVEM.W	D0-D7,$FFFF8240.W
	move.l	#-1,$ffff9800.w
	clr.w	$ffff8246.w
	clr.w	$ffff825e.w
	move.w	#-1,$ffff8240.w
	RTS

RESTORE_INT	
	LEA	TMP_OLDINT,A0
	MOVEA.L	(A0)+,A1
	MOVE	A1,USP
	MOVE	#$2700,SR
	MOVE.L	(A0)+,$4D2.W
	MOVE.L	(A0)+,$70.W
	MOVE.L	(A0)+,$120.W
	move.l	(a0)+,$110.w
	move.b	(a0)+,$fffffa1d.w
	move.b	(a0)+,$fffffa25.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa17.w
	MOVE.B	(A0)+,$FFFFFA13.W
	MOVE.B	(A0)+,$FFFFFA07.W
	MOVE.B	(A0)+,$FFFFFA09.W
	ifne	music
	move.l	dsp_play+8,a0
	st.b	song_stop(a0)
	MOVE	#$2300,SR
	clr.b	$ffff8901.w
	clr.l	-(a7)
	move.w	#$89,-(a7)
	trap	#14
	addq.l	#6,a7
	endc
	MOVE.B	#8,$FFFFFC02.W
	RTS

	ifne	music
play	jsr	dsp_play+12
	rte
	endc

SWAP_SCRN	MOVE.W	#1,PT_VBL
.tst	TST.W	PT_VBL
	BNE.s	.tst
	LEA	SCREEN,A0
	MOVE.L	4(A0),D0
	MOVE.L	(A0),4(A0)
	MOVE.L	D0,(A0)
	MOVE.B	D0,D1
	LSR.W	#8,D0
	MOVE.L	D0,$FFFF8200.W
	MOVE.B	D1,$FFFF820D.W
	RTS

VBL	MOVE.B	#0,$FFFFFA1B.W
	*MOVE.B	#$1F,$FFFFFA21.W
	*MOVE.L	#HBL,$120.W
	*MOVE.B	#8,$FFFFFA1B.W
	TST.W	PT_VBL
	BLE.s	VBLS1
	SUBQ.W	#1,PT_VBL
VBLS1	RTE

*HBL	MOVE	#$2700,SR
*HBLS1	CMPI.B	#$1F,$FFFFFA21.W
*	BEQ	HBLS1
*	MOVE.B	SCREEN+3,$FFFF8209.W
*	MOVE.B	SCREEN+2,$FFFF8207.W
*	MOVE.B	SCREEN+1,$FFFF8205.W
*	MOVE.B	#0,$FFFFFA1B.W
*	MOVE.B	#$43,$FFFFFA21.W
*	MOVE.L	#HBL2,$120.W
*	MOVE.B	#8,$FFFFFA1B.W
*	BCLR	#0,$FFFFFA0F.W
*	RTE
*
*HBL2	MOVE	#$2700,SR
*HBL2S1	CMPI.B	#$43,$FFFFFA21.W
*	BEQ	HBL2S1
*	MOVE.B	SCREEN+3,$FFFF8209.W
*	MOVE.B	SCREEN+2,$FFFF8207.W
*	MOVE.B	SCREEN+1,$FFFF8205.W
*	MOVE.B	#0,$FFFFFA1B.W
*	BCLR	#0,$FFFFFA0F.W
*	RTE

copy_image	lea	image+18,a0
	lea	TMP_PIC16B,a1
	move	#$3fff,d0
.bcl	move.l	(a0)+,d1
	move.l	d1,(-$10000.l,a1)
	move.l	d1,($10000.l,a1)
	move.l	d1,(a1)+
	dbra	d0,.bcl
	rts

	ifne	exec
new_prg	bsr	reloc
	lea	debut-$100,a0	*basepage
	lea	prg,a1		*prg a reloger
	move.l	2(a1),$c(a0)	*text size
	move.l	6(a1),$14(a0)	*data size
	move.l	10(a1),$1c(a0)
	move.l	8(a0),d0
	add.l	$c(a0),d0
	move.l	d0,$10(a0)
	add.l	$14(a0),d0
	move.l	d0,$18(a0)
	move.l	$1c(a0),d0		*taille bss
	lea	prg+$1c,a1
	move.l	$c(a0),d1
	add.l	$14(a0),d1
	lea	$100(a0),a0
	subq.l	#1,d0
	bmi.s	.fuck
.ret	subq.l	#1,d1

	lea	copy,a2
	movem.l	80(a2),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a7)
	movem.l	40(a2),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a7)
	movem.l	(a2),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a7)
	jmp	(a7)

.fuck	moveq	#0,d0
	bra.s	.ret

copy	move.b	(a1)+,(a0)+
	dbra	d1,copy
	swap	d1
	subq.w	#1,d1
	bmi.s	.clrbss
	swap	d1
	bra.s	copy
.clrbss	clr.b	(a0)+
	dbra	d0,.clrbss
	swap	d0
	subq.w	#1,d0
	bmi.s	.ok
	swap	d0
	bra.s	.clrbss
.ok	lea	120(a7),a7
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	clr.l	d7
	suba.l	a0,a0
	suba.l	a1,a1
	suba.l	a2,a2
	suba.l	a3,a3
	move.l	debut-$e8,a4	*bss
	move.l	debut-$f0,a5	*data
	lea	debut,a6		*text
	move.l	#debut-$100,4(a7)	*basepage
	jmp	(a6)
	
	dcb.w	120+copy-*,$4e71

reloc	lea	prg,a0
	move.l	2(a0),d5
	move.l	6(a0),d6
	add.l	d5,d6
	move.l	d6,d0
	addq.l	#3,d0
	lea	$1c(a0),a0	*debut prog
	move.l	#debut,d1	*adresse de reloc
	move.l	a0,a1
	add.l	d0,a1
	moveq	#0,d0
reloc0	move.b	(a1)+,d0
	beq.s	reloc_end
	cmp.w	#1,d0
	bne.s	reloc1
	add.w	#254,a0
	bra.s	reloc0
reloc1	add.w	d0,a0
	add.l	d1,(a0)
	bra.s	reloc0
reloc_end rts
	endc

	section	DATA

SCREEN	DC.L	ECRAN1
SCREEN2	DC.L	ECRAN2

TAB_SIN	incbin	sinus.tab
	even

FONT	INCBIN	font8.b
	even

	ifne	music
fuckin_bug	incbin	dsp_play.bin
	even

dsp_play	equ	fuckin_bug+$1c

mod	incbin	 DASBOOT.ntk
	even
	endc

image	incbin suprem.tg1
	even

start_data

	*********************** hop le texte

text	***	*              **              * max line
	***	*              **              *
	***	*              **              *
	***	*              **              *

	*	ne pas depasser max line
	*	$d pour passer … la ligne

	DC.B	$d,$d,$d
	dc.b	"       SUPREMACY PRESENTE",$d
	
		
	dc.b	$d,$d,$d,$d,$d
	dc.b	"          DA'S PICTURE",$d
	dc.b	"        "
	
		dc.b	$d,$d,$d,$d,$d
	dc.b	"        Cracked by ZARMI",$d
	dc.b	$d,$d,$d,$d,$d,$d,$d
	dc.b	"         Press <Space>"
	
	dc.b	0
	EVEN

logo	incbin	supremac.tg1
	even

	****************************** le prg inclus
	ifne	exec
prg	incbin	GRF.DAT
	dcb.b	5,0
	even
	endc
	********************************************

end_data
	section BSS
	
freq_buf	ds.l	1024
vga	ds.w	1
sin_rot	ds.w	1
sin_zy	ds.l	1
sin_zx	ds.l	1
zoom_y	ds.w	1
zoom_x	ds.w	1
rotation	ds.w	1
crd_x	ds.w	1
crd_y	ds.w	1
sin_cx	ds.l	1
sin_cy	ds.l	1
sin_rot2	ds.W	1

const_1	ds.l	1
const_2	ds.l	1
const_3	ds.l	1
const_4	ds.l	1
const_5	ds.l	1
const_6	ds.l	1

tempo_deform	ds.w	1

L0042	ds.w	1
L0043	ds.w	1
L0044	ds.w	1
L0045	ds.w	1

PT_VBL	ds.w	1
OLD_PAL	ds.b	32
TMP_OLDINT	ds.b	28
OLD_SLOG	ds.l	1
OLD_PHYS	ds.l	1
OLD_MODE	ds.w	1
OLD_484	ds.w	1
	even
	ds.b	512
MY_STACK	ds.l	1
	even

	ds.b	$10000 
TMP_PIC16B	ds.b	$10000
	ds.b	$10000

text_buffer
	ds.b	(480*100)+2	*code g‚n‚r‚

	ds.b	64
ECRAN1	DS.B	(640*240)+16
	ds.b	64
ECRAN2	DS.B	(640*240)+16

end_bss
	END