*** please note screens must be consecutive ...
***                     ----
	opt	o+,c-
screen1	equ	$c8000
screen2	equ	screen1+32000
screen3	equ	screen2+32000
screen4	equ	screen3+32000
top	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp
	clr.b	$ff8260
	MOVE.B	#$12,$FFFC02
	lea	eop,a0
	move.w	#8000,d0
.clp	clr.l	(a0)+
	dbf	d0,.clp
	BSR	CREATE_SINTABLE_CLEAR
	move.w	#-1,$ff8250
	move.w	#-1,$ff8252
	move.w	#-1,$ff8254
create_sprites
	lea	txt_dat,a0
	lea	eop+5100,a1
	lea	offsets,a2
	moveq	#15,d0
.mv_ov	moveq	#0,d1
	move.b	(a2)+,d1
	moveq	#6,d3
.plo	move.b	(a0,d1.w),d2
	lsl.l	#8,d2
	swap	d2
	move.l	d2,(a1)+
	add.w	#40,d1
	dbf	d3,.plo
	dbf	d0,.mv_ov
	lea	eop+5100,a0
	lea	eop+5548,a1
	move.w	#$6ff,d0
.ror	move.l	(a0)+,d1
	ror.l	d1
	move.l	d1,(a1)+
	dbf	d0,.ror
	lea	dd_log,a0
	move.l	#screen1,a2
	move.l	#screen3,a3
	moveq	#15,d7
.lp	move.l	16(a0),d1
	move.l	(a0)+,d0
	moveq	#19,d6
.lp2	move.l	d0,(a2)+
	clr.l	(a2)+
	move.l	d1,(a3)+
	clr.l	(a3)+
	dbf	d6,.lp2
	dbf	d7,.lp
	move.l	#screen1,a0
	move.l	#screen3,a1
	move	#((64000-(160*16))/4)-1,d1	
.loop1	move.l	(a0)+,(160*16)-4(a0)
	move.l	(a1)+,(160*16)-4(a1)
	dbf	d1,.loop1
	
sinit	move	#$2700,sr
	andi.b	#%11011111,$fffffa09.w
	andi.b	#%11111110,$fffffa07.w
	move.l	#vec120,$120.w
	bclr.b	#3,$fffffa17.w	
	ori.b	#1,$fffffa07.w
	ori.b	#1,$fffffa13.w
	move.b	$fffffa17.w,res1
	move.b	$fffffa07.w,res2
	move.b	$fffffa13.w,res3
	move.l	#vec70,$70.w
	move.w	#$2000,sr
rerun	move.l	#$31415926,$426.w
	move.l	#reset,$42a.w
NEVER_END	BRA.S	NEVER_END
reset	move.l	#screen1,sp
	move.b	#%10,$ffff820a.w
	move.w	#$2700,sr
	move.l	#vec70,$70.w
	move.l	#vec120,$120.w
	bclr	#0,$fffffa0f.w
	move.b	res1,$fffffa17.w
	move.b	res2,$fffffa07.w
	move.b	res3,$fffffa13.w
	andi.b	#%11011111,$fffffa09.w
	andi.b	#%11111110,$fffffa07.w
	move.l	#vec120,$120.w
	bclr.b	#3,$fffffa17.w	
	ori.b	#1,$fffffa07.w
	ori.b	#1,$fffffa13.w
	move.w	#$2300,sr
	bra.s	rerun
res1	dc.b	0		
res2	dc.b	0		
res3	dc.b	0,0		
offsets	dc.b	3,24,13,0,12,8,2,3,21,14,17,20,11,4,14,10
	even
phy	dc.l	screen1
log	dc.l	screen3
dum1	dc.l	screen2
dum2	dc.l	screen4
dd_log	DC.B	0,0,$FF,$FF,$80,0,$7F,$FF
	DC.B	$FF,$FC,$3F,$FF,$FF,$FC,$21,$FF
	DC.B	$F0,$FC,$2F,$FF,$F7,$7C,$2E,$FF
	DC.B	$F7,$7C,$2E,$FF,$F7,$7C,$28,$9F
	DC.B	$F0,$C,$3F,$FF,$FF,$74,$3E,$EF
	DC.B	$FF,$74,$3E,$EF,$FF,$74,$3E,$9F
	DC.B	$FF,$C,$3F,$FF,$FF,$FC,$3F,$FF
	DC.B	$FF,$FE,0,1,$ff,$ff,$ff,$ff
	DC.B	0,0,$FF,$FF,$80,0,$7F,$FF
	DC.B	$FF,$FC,$3F,$FF,$FF,$FC,$21,$FF
scrolly	addq.w	#1,counter
	cmp.w	#8,counter
	bne.s	.noadd
	clr.w	counter
	addq.l	#1,t_pos		
	move.l	t_pos,a0
	cmpi.b	#-1,(a0)
	bne.s	.ok
	move.l	#text,a0
	move.l	#text,t_pos
.ok	moveq	#0,d0
	move.b	(a0),d0
	cmp.b	#32,d0
	beq.s	.noadd
	sub.w	#65,d0
	lea	txt_dat,a0
	lea	eop+5003,a1
	add.l	d0,a0
	moveq	#6,d0
.mc	move.b	(a0),(a1)
	lea	4(a1),a1
	lea	40(a0),a0
	dbf	d0,.mc
.noadd	move.l	log,a0
	lea	1600(a0),a0
	move.w	#%0001100000011000,d5
	move.w	#%0111111001111110,d6
	moveq	#-1,d7
	moveq	#0,d4
	lea	eop+5000,a1
	moveq.w	#6,d2	
.dep	roxl.w	2(a1)
	roxl.w	(a1)
	move.l	(a1)+,d0
	moveq	#19,d1
.loop	move.w	#0,ccr
	rol.l	#1,d0
	bcc.s   	.no_fill	
.fill	move.w	d5,160*01+4(a0)
	move.w	d6,160*02+4(a0)
	move.w	d6,160*03+4(a0)
	move.w	d7,160*04+4(a0)
	move.w	d7,160*05+4(a0)
	move.w	d6,160*06+4(a0)
	move.w	d6,160*07+4(a0)
	move.w	d5,160*08+4(a0)
	move.w	d5,160*10+4(a0)
	move.w	d6,160*11+4(a0)
	move.w	d6,160*12+4(a0)
	move.w	d7,160*13+4(a0)
	move.w	d7,160*14+4(a0)
	move.w	d6,160*15+4(a0)
	move.w	d6,160*16+4(a0)
	move.w	d5,160*17+4(a0)
	bra.s	.nb
.no_fill	move.w	d4,160*01+4(a0)
	move.w	d4,160*02+4(a0)
	move.w	d4,160*03+4(a0)
	move.w	d4,160*04+4(a0)
	move.w	d4,160*05+4(a0)
	move.w	d4,160*06+4(a0)
	move.w	d4,160*07+4(a0)
	move.w	d4,160*08+4(a0)
	move.w	d4,160*10+4(a0)
	move.w	d4,160*11+4(a0)
	move.w	d4,160*12+4(a0)
	move.w	d4,160*13+4(a0)
	move.w	d4,160*14+4(a0)
	move.w	d4,160*15+4(a0)
	move.w	d4,160*16+4(a0)
	move.w	d4,160*17+4(a0)
.nb	lea	8(a0),a0
	dbf	d1,.loop
	lea	17*160(a0),a0
	dbf	d2,.dep
	move.l	a0,a1
	lea	11*160(a1),a1
	moveq	#40,d0
.loop_c	
count	set	0
	rept	20
	move.w	count+4-(320)(a0),count+4(a1)
count	set	count+8
	endr
	lea	160(a1),a1
	lea	-480(a0),a0	
	dbf	d0,.loop_c	
	rts	
counter	dc.w	7
txt_dat	incbin	txt.dat
	even
t_pos	dc.l	text-1
text	dc.b	"YO CUM ON DOWN DUDES THIS IS THE MEGA MIGHTY DYNAMIC DUO "
	DC.B	"WITH THEIR COMPETITION ENTRY  SO SMEG HEADS WHAT DO YER THINK "
	DC.B	"OF THIS EH ^^^^^ PRETTY GOOD FOR THREE AND HALF KILOBYTES AND NO "
	DC.B	"PREPLANNING WHATSOEVER  UNLIKE OTHER GROUPS ]]]]] SEE YOU SOON[ ",-1
pal_pnt	dc.l	pal
pal	dc.w	0,$100,$200,$300,$400,$500,$600,$700
	dc.w	$710,$720,$730,$740,$750,$760,$770
	dc.w	$660,$550,$440,$330,$220,$110,0
	dc.w	$070,$060,$050,$040,$030,$040,$050,$060
	dc.w	$070,$060,$050,$040,$030,$040,$050,$060
	dc.w	$070,$060,$050,$040,$030,$040,$050,$060
	dc.w	$070,$060,$050,$040,$030,$040,$050,$060

spos	dc.w	160,224,-4,4
	dc.w	172,212,-4,4
	dc.w	184,200,-4,4
	dc.w	188,188,4,4
	dc.w	176,176,4,4
	dc.w	164,164,4,4
	dc.w	152,152,4,4
	
	dc.w	128,128,4,4
	dc.w	116,116,4,4
	dc.w	104,104,4,4
	
	dc.w	80,80,4,4
	dc.w	68,68,4,4
	dc.w	56,56,4,4
	dc.w	44,44,4,4
	
	dc.w	20,20,4,4
	dc.w	8,8,4,4
sprites	lea	eop+5100,a0	* shift sprite pos
	lea	eop+21000,a5
	moveq	#0,d1
	moveq	#15,d0
.loop	move.l	80(a5),a1
	move.l	(a5)+,76(a5)
	cmp.l	#0,a1
	beq.s	.no_clr
	moveq	#6,d2
.lp	move.w	d1,6(a1)
	move.w	d1,14(a1)
	lea	160(a1),a1
	dbf	d2,.lp
.no_clr	dbf	d0,.loop		
 	lea	eop+21000,a5
	lea	spos,a1
	moveq	#15,d0
.sp_no	move.w	4(a1),d1
	move.w	6(a1),d2
	add.w	d1,(a1)
	add.w	d2,2(a1)
	cmpi.w	#0,(a1)
	bgt.s	.no1
	neg.w	4(a1)
.no1	cmpi.w	#0,2(a1)
	bgt.s	.no2
	neg.w	6(a1)
.no2	cmpi.w	#192,(a1)
	blt.s	.no3
	neg.w	4(a1)
.no3	cmpi.w	#310,2(a1)
	blt.s	.no4
	neg.w	6(a1)
.no4	moveq	#0,d1
	moveq	#0,d2
	move.w	(a1),d1
	move.w	2(a1),d2
	lea	8(a1),a1	
	move.l	log,a2
	mulu	#160,d1
	add.l	d1,a2
	move.w	d2,d1
	and.w	#%0000000000001111,d1
	and.w	#%1111111111110000,d2
	lsr.w	d2
	add.w	d2,a2
	mulu	#448,d1
	move.w	#6,d7
	move.l	a2,(a5)+
.plo	move.w	(a0,d1.w),d2
	or.w	d2,6(a2)
	move.w	2(a0,d1.w),d2
	or.w	d2,14(a2)
	lea	160(a2),a2
	addq.l	#4,d1
	dbf	d7,.plo
	lea	28(a0),a0
	dbf	d0,.sp_no
	rts
	
vec120	move.l	d0,-(sp)
	move.l	a0,-(sp)
	move.l	pal_pnt,a0
	move.w	(a0),d0
	move.w	d0,$ffff8248.w
	move.w	d0,$ffff824a.w
	move.w	d0,$ffff824c.w
	move.w	d0,$ffff824e.w
	move.w	44(a0),d0
	move.w	d0,$ffff8250.w
	move.w	d0,$ffff8252.w
	move.w	d0,$ffff8254.w
	move.w	d0,$ffff8256.w
	move.w	d0,$ffff8258.w
	move.w	d0,$ffff825a.w
	move.w	d0,$ffff825c.w
	move.w	d0,$ffff825e.w
	addq.l	#2,pal_pnt
	move.l	(sp)+,a0
	move.l	(sp)+,d0
	move.b	#0,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	move.b	#9,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte
vec70	move.l	#$00000002,$ffff8240.w
	move.l	#$00050007,$ffff8244.w
	move.b	#0,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	movem.l	d0-a6,-(sp)
	move.l	#pal,pal_pnt
	bsr	scrolly
	MOVEQ	#0,D1
	MOVE.L	LOG(PC),A0
	LEA	(160*50)+40(A0),A0
	MOVE.L	CLEAR_ADDRESS(PC),A1
	JSR	(A1)
	bsr	sprites
	ADDq	#2,ANGLES
	ADDq	#4,ANGLES+2
	ADDq	#6,ANGLES+4
	BSR	ROTATE
	BSR	FUCK_ME_THATS_GOOD
	BSR	WHAT_SHAPE
	move.l	phy,a0
	movem.l	log,a1-a3
	movem.l	a1-a3,phy
	move.l	a0,dum2
	move.b	phy+1,$ffff8201.w
	move.b	phy+2,$ffff8203.w
	movem.l	(sp)+,d0-a6
	rte

ANGLES	DC.W	0,0,0
X0	DC.W	160
Y0	DC.W	100
STORAGE	DC.L	0
COORDS_1	DC.W	6
	DC.W	-50,-50,0
	DC.W	10,-50,0
	DC.W	50,-20,0
	DC.W	50,20,0
	DC.W	10,50,0
	DC.W	-50,50,0
COORDS_2	DC.W	4
	DC.W	-50,-50,0
	DC.W	50,-50,0
	DC.W	50,50,0
	DC.W	-50,50,0
COORDS_3	DC.W	3
	DC.W	0,-60,0
	DC.W	60,60,0
	DC.W	-60,60,0
CNT_PNT	DC.L	COORDS
COORDS	DC.L	COORDS_1,COORDS_2,COORDS_3,-1
COORD_P	DC.L	COORDS_1+2
NO_CORD	DC.W	6
MY_CUNT	DC.W	0
WHAT_SHAPE	
	ADDQ.W	#1,MY_CUNT
	CMP.W	#500,MY_CUNT
	BNE.S	.EOR
	CLR.W	MY_CUNT
	ADDQ.L	#4,CNT_PNT
	MOVE.L	CNT_PNT,A0
	CMP.L	#-1,(A0)
	BNE.S	.OK_SH
	MOVE.L	#COORDS,CNT_PNT
	MOVE.L	#COORDS,A0
.OK_SH	MOVE.L	(A0),A0
	MOVE.W	(A0),NO_CORD
	ADDQ.L	#2,A0
	MOVE.L	A0,COORD_P	
.EOR	RTS	

FUCK_ME_THATS_GOOD
	MOVE.L	STORAGE(PC),A0
	LEA	1000(A0),A1
	MOVE	NO_CORD,D7
.LOOP
	MOVE.L	(A0)+,(A1)
	MOVE.L	(A0),4(A1)
	
	MOVEM.L	A0/A1/D7,-(SP)
	BSR	Draw_Line
	MOVEM.L	(SP)+,A0/A1/D7

	DBF	D7,.LOOP
	RTS

* -- ROTATE
* INPUTS	
*	A0 = OBJECT

ROTATE	LEA	ANGLES(PC),A3
	
	CMPI	#720,(A3)
	BLT.S	.XOK
	SUBI	#720,(A3)
.XOK	CMPI	#720,2(A3)
	BLT.S	.YOK
	SUBI	#720,2(A3)
.YOK	CMPI	#720,4(A3)
	BLT.S	.ZOK
	SUBI	#720,4(A3)
.ZOK	MOVE.L	STORAGE(PC),A1
	MOVE	NO_CORD,D7
		
	MOVE.L	#COORD_P,A6
	MOVE.L	(A6),A6
	LEA	SINCOS_TABLE(PC),A2
	LEA	180(A2),A4
	MOVEQ	#9,D2	
	BRA	.ITERATE
.LOOP
	MOVEM	(A6),D0/D3/D5
	MOVEM	D0/D3/D5,(A1)	

	MOVE	4(A1),D5		;Z
	MOVE	(A1),D3		;X
	MOVE	2(A3),D0		;YANGLE
	MOVE	(A2,D0),D1		;SIN
	MOVE	(A4,D0),D0		;COS
	MULS	D0,D3
	MULS	D1,D5
	SUB.L	D5,D3
	LSL.L	#2,D3
	SWAP	D3		;X1
	MOVE	4(A1),D5		;Z
	MOVE	(A1),D6		;X
	MULS	D0,D5
	MULS	D1,D6
	ADD.L	D5,D6
	LSL.L	#2,D6
	SWAP	D6		;Z1
	MOVE	D3,(A1)
	MOVE	D6,4(A1)
* -- D4 = Y1 D3 = X1 D6 = Z1

	MOVEM	2(A1),D4/D5		;Y,Z
	MOVE	(A3),D0		;XANGLE
	MOVE	(A2,D0),D1		;SIN
	MOVE	(A4,D0),D0		;COS
	MULS	D0,D4
	MULS	D1,D5
	SUB.L	D5,D4
	LSL.L	#2,D4
	SWAP	D4		;Y1
	MOVEM	2(A1),D5/D6		;Y,Z
	MULS	D0,D6
	MULS	D1,D5
	ADD.L	D6,D5
	LSL.L	#2,D5
	SWAP	D5		;Z1
	MOVEM	D4/D5,2(A1)
* -- D4 = Y1 D5 = Z1

	MOVEM	(A1),D3/D4		;X,Y
	MOVE	4(A3),D0		;XANGLE
	MOVE	(A2,D0),D1		;SIN
	MOVE	(A4,D0),D0		;COS
	MULS	D0,D3
	MULS	D1,D4
	SUB.L	D4,D3
	LSL.L	#2,D3
	SWAP	D3		;X1
	MOVEM	(A1),D4/D5		;X,Y
	MULS	D0,D5
	MULS	D1,D4
	ADD.L	D4,D5
	LSL.L	#2,D5
	SWAP	D5		;Y1
	MOVE	4(A1),D6 
		
	ADD	#-1000,D6
		
	EXT.L	D3
	EXT.L	D5
	ASL.L	D2,D3
	ASL.L	D2,D5
	NEG	D6
	DIVS	D6,D3
	DIVS	D6,D5
	
	ADD	X0,D3
	ADD	Y0,D5

	MOVEM	D3/D5,(A1)	;SAVE X,Y,Z

	LEA	4(A1),A1	
	LEA	6(A6),A6	
.ITERATE	DBRA	D7,.LOOP
	MOVE.L	STORAGE(PC),A2
	MOVE.L	(A2),(A1)
	MOVE.L	4(A2),4(A1)
	RTS

***************************************************************
* Routine to draw a line.
* A1 points to two co-ords.D7 col.
* D0-D6/A0/A2-A5 smashed.		
***************************************************************
Draw_Line		MOVE.L 	LOG(PC),A0	screen base
		ADDQ	#6,A0
		MOVE.L	#-1,A3
		SUB.L	A4,A4
		MOVE.L 	(A1),D0
		CMP 	6(A1),D0
		BEQ 	Horiz_case
		BLT.S 	coord_ok
		MOVE.L 	4(A1),(A1)
		MOVE.L 	D0,4(A1)
coord_ok		MOVE 	2(A1),D1
		MOVE 	D1,D2
		LSL 	#2,D1
		ADD 	D2,D1
		LSL 	#5,D1
		ADDA 	D1,A0
Gradient		MOVEQ 	#0,D5
		MOVE 	4(A1),D5
		SUB 	(A1),D5
		BEQ.S 	Vert_case
		MOVE 	6(A1),D4
		SUB 	2(A1),D4
		MOVE 	D4,D6
		ADDQ 	#1,D4
		TST 	D5
		BMI.S 	neg_grad
		ADDQ 	#1,D5
accrt_div1		MOVE.L 	D5,D0
		DIVU 	D4,D0
		MOVE 	D0,D5
		SWAP 	D5
		CLR 	D0
		DIVU 	D4,D0
		MOVE 	D0,D5		
		MOVE.L 	(A1),D4
		CLR 	D4
		BRA.S 	next_line
neg_grad		NEG 	D5
		ADDQ 	#1,D5
accrt_div2		MOVE.L 	D5,D0
		DIVU 	D4,D0
		MOVE 	D0,D5
		SWAP 	D5
		CLR 	D0
		DIVU 	D4,D0
		MOVE 	D0,D5		
		NEG.L 	D5
* Draw a normal sloped line.
		MOVE.L 	(A1),D4
		CLR 	D4
		BRA.S 	next_line
line_lp		MOVE.L 	D4,D0
		SWAP 	D0
		ADD.L 	D5,D4
		MOVE.L 	D4,D1
		SWAP 	D1
		BSR.S 	LHline
		LEA 	160(A0),A0
next_line		DBRA 	D6,line_lp
		SWAP 	D4
		MOVE 	D4,D0
		MOVE 	4(A1),D1
		BRA.S 	LHline

* Vertical line case.

Vert_case		MOVEM 	2(A1),D0/D1/D6
		SUB 	D0,D6
		MOVE 	D1,D0
		LSR 	#1,D0
		AND 	#$FFF8,D0
		LEA 	0(A0,D0),A2
		AND 	#$F,D1
		MOVE 	#$8000,D3
		LSR 	D1,D3
		MOVE 	D3,D2
		NOT 	D3
v_write		OR 	D2,(A2)+
		LEA 	158(A2),A2
		DBRA 	D6,v_write
		RTS

* Horizontal line case.

Horiz_case		MOVE 	D0,D1
		LSL 	#2,D0
		ADD 	D1,D0
		LSL 	#5,D0
		ADDA 	D0,A0
		MOVE 	(A1),D0
		MOVE 	4(A1),D1
LHline		CMP 	D0,D1
		BGE.S 	order_ok
		EXG 	D0,D1
order_ok		SUB 	D0,D1
		MOVE 	D0,D2
		LSR 	#1,D2
		AND 	#$FFF8,D2
		LEA 	0(A0,D2),A2
		AND 	#$F,D0
		MOVEQ 	#-1,D2
		LSR 	D0,D2
		ADD 	D1,D0
		SUB 	#16,D0
		BPL.S 	.multi_chunk
		NOT 	D0
		MOVEQ 	#-1,D1
		LSL 	D0,D1
		AND 	D1,D2
		MOVE 	D2,D3
		NOT 	D3
		OR 	D2,(A2)
		LEA	8(A2),A2
		RTS
.multi_chunk	MOVE 	D2,D3
		NOT	D3
write_2		OR 	D2,(A2)
		LEA	8(A2),A2
		ADDQ 	#1,D0
		MOVE 	D0,D1
		BEQ.S 	.miss_main
		LSR	#2,D0
		AND.B 	#%11111100,D0
		NEG 	D0
		JMP 	.miss_main(PC,D0)
	REPT 20
		MOVE 	A3,(A2)
		ADDQ	#8,A2
	ENDR		
.miss_main	MOVEQ 	#-1,D2
		ANDI	#$F,D1
		LSR 	D1,D2
		MOVE 	D2,D3
		NOT 	D2
write_3		OR 	D2,(A2)
		RTS


CREATE_SINTABLE_CLEAR	LEA	SINCOS_TABLE+180(PC),A0
		LEA	2(A0),A1
		MOVE	#90-1,D7
.ALOOP		MOVE	-(A0),(A1)+
		DBF	D7,.ALOOP
		LEA	-2(A1),A1
		MOVE	#180-1,D7
.BLOOP		MOVE	(A0)+,(A1)+
		NEG	-2(A1)
		DBF	D7,.BLOOP
		LEA	SINCOS_TABLE(PC),A0
		MOVE	#360-1,D7
.CLOOP		MOVE	(A0)+,(A1)+
		DBF	D7,.CLOOP
		
		MOVE.L	A1,CLEAR_ADDRESS

		LEA	INSTRUCTION(PC),A0
		MOVEQ	#0,D7
.DLOOP		MOVE	D7,2(A0)
		ADDq	#6,2(A0)
		MOVE.L	(A0),(A1)+
		ADDQ	#8,D7
		
		MOVE.L	D7,D6
		DIVU	#160,D6
		SWAP	D6
		
		CMPI	#72,D6
		BLT.S	.DLOOP
		ADDI	#88,D7
		
		CMPI	#160*102,D7
		BLT.S	.DLOOP
		MOVE	#$4E75,(A1)+
		MOVE.L	A1,STORAGE
		RTS
		
INSTRUCTION	MOVE	D1,100(A0)
CLEAR_ADDRESS	DC.L	0

SINCOS_TABLE	DC.W 0,286,572,857,1143,1428,1713,1997
		DC.W 2280,2563,2845,3126,3406,3686,3964,4240
		DC.W 4516,4790,5063,5334,5604,5872,6138,6402
		DC.W 6664,6924,7182,7438,7692,7943,8192,8438
		DC.W 8682,8923,9162,9397,9630,9860,10087,10311
		DC.W 10531,10749,10963,11174,11381,11585,11786,11982
		DC.W 12176,12365,12551,12733,12911,13085,13255,13421
		DC.W 13583,13741,13894,14044,14189,14330,14466,14598
		DC.W 14726,14849,14968,15082,15191,15296,15396,15491
		DC.W 15582,15668,15749,15826,15897,15964,16026,16083
		DC.W 16135,16182,16225,16262,16294,16322,16344,16362
		DC.W 16374,16382,16384


eop	*** please note that
	*** all kinds of data
	*** follow at this point

