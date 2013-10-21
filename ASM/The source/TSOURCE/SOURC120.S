*************************************
*GOR INTRO... RIPPED BY ALCHEMY 1992*
*                                   *
* (BUT MENTOR GOT IT WORKING ...)   *
*************************************

;	opt	d+

	movea.l	4(sp),A5
	move.l	#$200,-(sp) 
	move.l	A5,-(sp)
	pea	$4A0000 
	trap	#1
	adda.l	#$C,sp

	clr.l	-(sp) 		; into supervisor
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp 
	move.l	D0,old_sp

	movea.l	$42E.L,A0	;
	lea	-8(A0),sp 
	bsr	l0002 

	move.l	old_sp,-(sp) 
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp 

	pea		null
	pea		null
	move.l	filename,-(SP)
	move.w	#0,-(sp)
	move.w	#$4B,-(sp)
	trap	#1
	adda.l	#$12,sp 

	move.w	#$4C,-(sp) 	; quit menu (from wherever)
	trap	#1

null	dc.l	1
	even

filename	dc.l	1
	even

file1	dc.b	'justice.src',0
	even
file2	dc.b	'summon.src',0
	even
file3	dc.b	'spheres.src',0
	even
file4	dc.b	'teserae+.src',0
	even
file5	dc.b	'droid.src',0
	even

l0002	move.l	$44E.L,old_scr
	move.b	$ffff8260.W,old_rez
	move.b	$ffff820A.W,old_scan
	move.w	#$777,$ffff8240.W
	movem.l	$ffff8240.W,D0-D7
	movem.l	D0-D7,old_pal 
	lea	$80000,A0 
	move.l	(A0),D0 
	move.l	#'FUCK',(A0) 
	CMPI.L	#'FUCK',(A0) 
	bne.S	l0003 
	move.l	#$F8000,l0041 
	move.l	#$F0000,l0042 
	move.l	#$F8000,l0043 
	move.l	D0,(A0) 
l0003	subi.l	#$2800,l0043

	jsr	MUSIX

	bsr	l001D 
	moveq	#$12,D1 
	bsr	l001F 
	move.l	l0043,D7
	bsr	l0022 
	move.b	#0,$ffff8260.W 	; Low rez
	movea.l	l0043,A0
	bsr	l0026 
	move.l	#font,D0 
	moveq	#0,D1 
	lea	l004A,A0
	move.w	#3,D6 
l0004	move.l	D0,D1 
	move.w	#$27,D7 
l0005	move.l	D1,(A0)+
	addq.l	#1,D1 
	dbf	D7,l0005
	ADDI.L	#$140,D0
	dbf	D6,l0004
	clr.w	l0048 
	move.w	#$C8,l0049
	lea	l0051,A6
	bsr	l0017 
	clr.w	l0048 
	move.w	#4,l0049
	bra	l0008 

l0006	bsr	l0024 
	lea	l0050,A0
	moveq	#0,D0 
	move.w	#$63,D7 
l0007	movea.l	(A0)+,A1
	move.l	D0,(A1) 
	dbf	D7,l0007
l0008	lea	l004F,A0
	lea	l0050,A1
	move.w	#$63,D7 
l0009	moveq	#1,D5 
	ADD.W	(A0),D5 
	move.w	2(A0),D0
	ADD.W	(A0),D0 
	addq.w	#1,D0 
	CMP.W	#$13F,D0
	BLT.S	l000A 
	subi.w	#$13F,D0
	subi.w	#$13F,2(A0) 
l000A	move.w	D0,2(A0)
	move.w	4(A0),D1
	addq.w	#4,D1 
	bsr	l0014 
	addq.l	#6,A0 
	move.l	A6,(A1)+
	dbf	D7,l0009
	addq.w	#1,l0058
	cmpi.w	#2,l0058
	BLT.S	l000D 
	clr.w	l0058 
	EORI.W	#1,l0057
	bne.S	l000C 
	movea.l	l0054,A0
	moveq	#0,D0 
	move.b	(A0)+,D0
	TST.B	D0
	bne.S	l000B 
	lea	l0053,A0
	move.b	(A0)+,D0
l000B	move.l	A0,l0054
	move.b	D0,l0052
	lea	l0052,A6
	bsr	l0017 
	bra	l000D 
l000C	movea.l	l0056,A0
	moveq	#0,D0 
	move.b	D0,(A0) 
	move.b	D0,160(A0)
	move.b	D0,320(A0)
	move.b	D0,480(A0)
	move.b	D0,640(A0)
	move.b	D0,800(A0)
	move.b	D0,960(A0)
	move.b	D0,1120(A0) 
l000D	lea	l005D,A5
	movea.l	l0043,A6
	adda.l	#$6D64,A6 
	moveq	#7,D7 
l000E	move.w	(A5),(A6) 
	move.w	8(A5),8(A6) 
	move.w	16(A5),16(A6) 
	move.w	24(A5),24(A6) 
	move.w	32(A5),32(A6) 
	move.w	40(A5),40(A6) 
	move.w	48(A5),48(A6) 
	move.w	56(A5),56(A6) 
	move.w	64(A5),64(A6) 
	move.w	72(A5),72(A6) 
	move.w	80(A5),80(A6) 
	move.w	88(A5),88(A6) 
	move.w	96(A5),96(A6) 
	move.w	104(A5),104(A6) 
	move.w	112(A5),112(A6) 
	move.w	120(A5),120(A6) 
	move.w	128(A5),128(A6) 
	move.w	136(A5),136(A6) 
	move.w	144(A5),144(A6) 
	move.w	152(A5),152(A6) 
	lea	168(A5),A5
	lea	160(A6),A6
	dbf	D7,l000E
	addq.w	#2,l005C
	cmpi.w	#8,l005C
	BLT.S	l0010 
	clr.w	l005C 
	lea	l005E,A6
	movea.l	scrollp,A5
	moveq	#0,D7 
	move.b	(A5)+,D7
	TST.B	D7
	BPL.S	l000F 
	lea	scrolly,A5
	move.b	(A5)+,D7
l000F	move.l	A5,scrollp
	SUBI.B	#$20,D7 
	lea	l004A,A5
	lsl.w	#2,D7 
	movea.l	0(A5,D7.W),A5 
	move.b	(A5),(A6) 
	move.b	40(A5),168(A6)
	move.b	80(A5),336(A6)
	move.b	120(A5),504(A6) 
	move.b	160(A5),672(A6) 
	move.b	200(A5),840(A6) 
	move.b	240(A5),1008(A6)
	move.b	280(A5),1176(A6)
l0010	bsr	l0012 
	bsr	l0012 
	jsr	MUSIX+8


try_f1	CMPI.B	#$3B,$ffffFC02.W	; F1
	bne.S	try_f2
	move.l	#file1,filename
	bra	exit

try_f2	CMPI.B	#$3C,$ffffFC02.W	; F2
	bne.S	try_f3
	move.l	#file2,filename
	bra	exit

try_f3	CMPI.B	#$3D,$ffffFC02.W	; F3
	bne.S	try_f4
	move.l	#file3,filename
	bra	exit

try_f4	CMPI.B	#$3E,$ffffFC02.W	; F4
	bne	try_f5
	move.l	#file4,filename
	bra	exit

try_f5	CMPI.B	#$3F,$ffffFC02.W	; F5
	bne.S	try_sp
	move.l	#file5,filename
	bra.s	exit
;
;try_f7	CMPI.B	#$41,$ffffFC02.W	; F7
;	bne	l0006
;	move.l	#file7,filename

;	bra.s	exit

try_sp	CMPI.B	#$39,$ffffFC02.W	; space bar exits
	bne	l0006 

exit	move.l	old_scr,D7
	bsr	l0022 
	move.b	old_rez,$ffff8260.W
	moveq	#8,D1 
	bsr	l001F 
	bsr	l001E 

	jsr	MUSIX+4

	move.w	#-1,$4EE.L
	movem.l	old_pal,D0-D7 
	movem.l	D0-D7,$ffff8240.W	; reset palette
	move.b	old_scan,$ffff820A.W	; reset hertz

	movea.l	old_scr,A0	; clear screen
	move.w	#$1F3F,D7 
l0011	clr.l	(A0)+ 
	dbf	D7,l0011
	rts 

l0012	lea	l005D,A5
	moveq	#7,D7 
l0013	roxl	160(A5) 
	roxl	152(A5) 
	roxl	144(A5) 
	roxl	136(A5) 
	roxl	128(A5) 
	roxl	120(A5) 
	roxl	112(A5) 
	roxl	104(A5) 
	roxl	96(A5)
	roxl	88(A5)
	roxl	80(A5)
	roxl	72(A5)
	roxl	64(A5)
	roxl	56(A5)
	roxl	48(A5)
	roxl	40(A5)
	roxl	32(A5)
	roxl	24(A5)
	roxl	16(A5)
	roxl	8(A5) 
	roxl	(A5)
	lea	168(A5),A5
	dbf	D7,l0013
	rts 
l0014	mulu	#$A0,D1 
	move.w	D0,D2 
	ANDI.L	#-$10,D0
	LSR.W	#1,D0 
	ADD.L	D0,D1 
	ANDI.L	#$F,D2
	move.w	#-$8000,D3
	LSR.W	D2,D3 
	movea.l	l0043,A6
	adda.l	D1,A6 
	btst	#0,D5 
	beq.S	l0015 
	OR.W	D3,(A6) 
l0015	btst	#1,D5 
	beq.S	l0016 
	OR.W	D3,2(A6)
l0016	rts 
l0017	move.w	l0048,D0
	move.w	l0049,D1
	moveq	#0,D2 
	move.b	(A6)+,D2
	ANDI.B	#$7F,D2 
	TST.B	D2
	beq.S	l001A 
	CMP.B	#$A,D2
	bne	l0018 
	clr.w	l0048 
	addi.w	#9,l0049
	bra.S	l0019 
l0018	SUBI.B	#$20,D2 
	bsr	l001B 
	addq.w	#8,l0048
l0019	TST.B	(A6)
	bne	l0017 
l001A	rts 
l001B	lea	l004A,A1
	ANDI.L	#$fff8,D0 
	mulu	#$140,D1
	ADD.L	D0,D1 
	LSR.L	#1,D1 
	ANDI.L	#$fff8,D1 
	btst	#3,D0 
	beq	l001C 
	addq.w	#1,D1 
l001C	ADD.L	l0043,D1
	movea.l	D1,A0 
	lsl.w	#2,D2 
	movea.l	0(A1,D2.W),A1 
	addq.l	#4,A0 
	move.b	(A1),(A0) 
	move.b	40(A1),160(A0)
	move.b	80(A1),320(A0)
	move.b	120(A1),480(A0) 
	move.b	160(A1),640(A0) 
	move.b	200(A1),800(A0) 
	move.b	240(A1),960(A0) 
	move.b	280(A1),1120(A0)
	addq.l	#2,A0 
	move.b	(A1),(A0) 
	move.b	40(A1),160(A0)
	move.b	80(A1),320(A0)
	move.b	120(A1),480(A0) 
	move.b	160(A1),640(A0) 
	move.b	200(A1),800(A0) 
	move.b	240(A1),960(A0) 
	move.b	280(A1),1120(A0)
	move.l	A0,l0056
	rts 
l001D	move	#$2700,SR 
	move.b	$fffa09.L,old_a09 
	move.b	$fffa07.L,old_a07 
	move.b	$fffa13.L,old_a13 
	clr.b	$fffa07.L 
	clr.b	$fffa09.L 
	move.l	$120.L,old_120
	move.l	$70.L,old_70 
	move.l	#new_120,$120.L 
	move.l	#new_70,$70.L
	bset	#0,$fffa07.L
	bset	#0,$fffa13.L
	move	#$2300,SR 
	rts 

l001E	move	#$2700,SR 
	move.b	old_a09,$fffa09.L 
	move.b	old_a07,$fffa07.L 
	move.b	old_a13,$fffa13.L 
	move.l	old_120,$120.L
	move.l	old_70,$70.L 
	move	#$2300,SR 
	rts 

l001F	lea	$fffffc00,A0
l0020	move.b	(A0),D2 
	btst	#1,D2 
	beq	l0020 
	move.b	D1,2(A0)
	rts 
	EORI.W	#1,l0044
	bne	l0021 
	move.l	l0042,D7
	move.l	l0041,l0043 
	bra	l0022 
l0021	move.l	l0041,D7
	move.l	l0042,l0043 
l0022	LSR.L	#8,D7 
	move.b	D7,-$7DFD.W 
	LSR.L	#8,D7 
	move.b	D7,-$7DFF.W 
	move.w	l0038,D0
l0023	CMP.W	l0038,D0
	beq	l0023 
	rts 
l0024	move.w	l0039,D0
l0025	CMP.W	l0039,D0
	beq	l0025 
	rts 
l0026	move.w	#$293F,D0 
	moveq	#0,D7 
l0027	move.l	D7,(A0)+
	dbf	D0,l0027
	rts 
l0028	clr.b	$fffa1B.L 
	movem.l	A0-A6/D0-D7,-(sp) 
	move	SR,-(sp)
	move	#$2700,SR 
	lea	l004E,A3
	ADDA.W	l004C,A3
	lea	$ffff8240.L,A4
	lea	$FF8209.L,A5
	lea	l002A,A6
	moveq	#0,D0 
l0029	TST.B	(A5)
	beq.S	l0029 
	move.b	(A5),D0 
	adda.l	D0,A6 
	JMP	(A6)
l002A	rept	172
	NOP 
	endr

	rept	42
	move.w    (A3)+,(A4)
	endr

	move.w	#0,(A4) 
	move	(sp)+,SR
	movem.l	(sp)+,A0-A6/D0-D7 
	clr.b	$fffa1B.L 
	move.l	#l002B,$120.L 
	move.b	#1,$fffa21.L
	move.b	#8,$fffa1B.L
	bclr	#0,$fffa0F.L
	rte 

l002B	clr.b	$fffa1B.L 
	move.l	A0,-(sp)
	movea.l	PAL_2_POINT,A0
	move.l	(A0),$ffff8248.W 
	move.l	(A0)+,$ffff824C.W
	move.l	A0,PAL_2_POINT
	movea.l	(sp)+,A0
	addq.w	#1,l0059
	cmpi.w	#$BF,l0059
	BLT.S	l002C 
	move.l	#l002D,$120.L 
l002C	bclr	#0,$fffa0F.L
	move.b	#8,$fffa1B.L
	rte 
l002D	clr.b	$fffa1B.L 
	movem.l	A0-A6/D0-D7,-(sp) 
	move	SR,-(sp)
	move	#$2700,SR 
	lea	l004E,A3
	ADDA.W	l004D,A3
	lea	$ffff8240.L,A4
	lea	$FF8209.L,A5
	lea	l002F,A6
	moveq	#0,D0 
l002E	TST.B	(A5)
	beq.S	l002E 
	move.b	(A5),D0 
	adda.l	D0,A6 
	JMP	(A6)
l002F
	rept	214
	nop 
	endr
	rept	42
	move.w	(A3)+,(A4)
	endr
	move.w	#0,(A4) 
	addq.w	#1,l0039
	move	(sp)+,SR
	movem.l	(sp)+,A0-A6/D0-D7 
	bclr	#0,$fffa0F.L
	move.l	#l0030,$120.L 
	move.b	#1,$fffa21.L
	move.b	#8,$fffa1B.L
	rte 
l0030	clr.b	$fffa1B.L 
	movem.l	A0/D0,-(sp) 
	lea	$fffa21.L,A0
	move.b	#-$38,(A0)
	move.b	#8,$fffa1B.L
	move.b	(A0),D0 
l0031	CMP.B	(A0),D0 
	beq	l0031 
	clr.b	$ffff820A.W
	moveq	#3,D0 
l0032	nop 
	dbf	D0,l0032
	move.b	#2,$ffff820A.W 
	movem.l	(sp)+,A0/D0 
	bclr	#0,$fffa0F.L
	move.b	#0,$fffa1B.L
	move.l	#l0033,$120.L 
	move.b	#$A,$fffa21.L 
	move.b	#8,$fffa1B.L
	rte 
l0033	clr.b	$fffa1B.L 
	move.l	A0,-(sp)
	movea.l	l0061,A0
	move.w	(A0)+,$ffff8240.W
	move.l	A0,l0061
	movea.l	(sp)+,A0
	bclr	#0,$fffa0F.L
	move.b	#1,$fffa21.L
	move.b	#8,$fffa1B.L
	rte 

new_120	clr.b	$fffa1B.L 
	move.w	#7,$ffff8240.W 
	bclr	#0,$fffa0F.L
	rte 

new_70	addq.w	 #1,l0038
	movem.l	A0-A6/D0-D7,-(sp) 
	clr.b	$fffa1B.L 
	move.b	#1,$fffa21.L
	move.l	#l0028,$120.L 
	move.b	#8,$fffa1B.L
	clr.w	l0059 
	move.l	#PALETTE_2,PAL_2_POINT
	move.l	#PAL_TAB,l0061
	addi.w	#2,l004C
	cmpi.w	#$190,l004C 
	BLT.S	l0036 
	clr.w	l004C 
l0036	subi.w	#2,l004D
	tst.w	l004D 
	BPL.S	l0037 
	move.w	#$18E,l004D 
l0037	move.l	#$333,$ffff8240.W
	move.l	#$5550777,$ffff8244.W
	lea	$ffff8250.W,A0 
	move.l	#$7770777,D0
	move.l	D0,(A0)+
	move.l	D0,(A0)+
	move.l	D0,(A0)+
	move.l	D0,(A0)+
	movem.l	(sp)+,A0-A6/D0-D7 
	rte 


	section	data

l0038	dc.w	0
l0039	dc.w	0
old_70	DS.L	1
old_120	DS.L	3 
old_a09	dc.b	  0 
old_a07	dc.b	  0 
old_a13	dc.b	  0 
old_rez	dc.b	0 
old_sp	DS.L	1
l0041	dc.l	$78000
l0042	dc.l	$70000
l0043	dc.l	$78000
l0044	dc.w	0
old_scr	DS.L	1
old_pal	ds.W	32
old_scan	ds.W		 3 
l0048	dc.w	0
l0049	dc.w	0
l004A	ds.W	320

font	incbin	'mouse.fnt'
	even

; Font Options:-
;
; BROADWAY	DATA	DESCEND	KEFREN
; LUSH		MOUSE	STONEY	TAIL

l004C	dc.w	$0000
l004D	dc.w	$00F0 
l004E	ds.W	64
	dc.w	$101,$202,$303,$404,$505,$606,$707,$706 
	dc.w	$705,$704,$703,$702,$701,$700,$710,$720 
	dc.w	$730,$740,$750,$760,$770,$771,$772,$773 
	dc.w	$774,$775,$776,$777,$776,$775,$774,$773 
	dc.w	$772,$771,$770,$760,$750,$740,$730,$720 
	dc.w	$710,$700,$701,$702,$703,$704,$705,$706 
	dc.w	$707,$606,$505,$404,$303,$202,$101,$000 

	ds.W		 127 

l004F	dc.b	$00,$01,$00,$D8,$00,')',$00,$02 
	dc.b	$00,'9',$00,'b',$00,$01,$00,$9F 
	dc.b	$00,$06,$00,$00,$00,'~',$00,'$' 
	dc.b	$00,$00,$00,'N',$00,$B2,$00,$01 
	dc.b	$00,$FC,$00,'@',$00,$02,$00,$99 
	dc.b	$00,$B5,$00,$00,$00,$BD,$00,'\' 
	dc.b	$00,$02,$00,'`',$00,$8E,$00,$00 
	dc.b	$00,$FC,$00,'&',$00,$01,$00,'h' 
	dc.b	$00,'P',$00,$00,$00,$19,$00,$11 
	dc.b	$00,$02,$00,'G',$00,'J',$00,$02 
	dc.b	$00,'N',$00,$0D,$00,$02,$00,$B8 
	dc.b	$00,'F',$00,$00,$00,$C3,$00,'h' 
	dc.b	$00,$02,$00,$E8,$00,'(',$00,$00 
	dc.b	$00,$99,$00,';',$00,$00,$00,$E6 
	dc.b	$00,'/',$00,$00,$00,'m',$00,$12 
	dc.b	$00,$01,$01,'1',$00,$AE,$00,$00 
	dc.b	$00,':',$00,$AF,$00,$02,$00,$C9 
	dc.b	$00,$BE,$00,$01,$00,'h',$00,$8C 
	dc.b	$00,$02,$00,'3',$00,'Y',$00,$00 
	dc.b	$00,$EA,$00,$BB,$00,$02,$01,$27 
	dc.b	$00,'U',$00,$00,$00,$D6,$00,$9B 
	dc.b	$00,$01,$00,$09,$00,$82,$00,$02 
	dc.b	$01,'+',$00,'p',$00,$02,$00,$C9 
	dc.b	$00,$8F,$00,$00,$00,$98,$00,$00 
	dc.b	$00,$00,$00,$90,$00,'r',$00,$02 
	dc.b	$00,$00,$00,'I',$00,$02,$00,$8E 
	dc.b	$00,$96,$00,$01,$00,'I',$00,$08 
	dc.b	$00,$02,$00,'}',$00,$A6,$00,$02 
	dc.b	$00,$8D,$00,'`',$00,$01,$00,$8F 
	dc.b	$00,'j',$00,$00,$00,'G',$00,'U' 
	dc.b	$00,$02,$00,'"',$00,$96,$00,$01 
	dc.b	$00,'U',$00,'[',$00,$02,$00,$0B 
	dc.b	$00,'(',$00,$01,$00,'S',$00,$1F 
	dc.b	$00,$00,$01,$0D,$00,'d',$00,$00 
	dc.b	$00,$C9,$00,'_',$00,$02,$00,$A7 
	dc.b	$00,$BF,$00,$01,$00,$CD,$00,$AA 
	dc.b	$00,$01,$00,$FE,$00,$A0,$00,$02 
	dc.b	$00,$F8,$00,$0C,$00,$02,$00,$B7 
	dc.b	$00,'J',$00,$00,$00,'@',$00,'S' 
	dc.b	$00,$00,$01,'9',$00,',',$00,$02 
	dc.b	$00,$02,$00,$A5,$00,$01,$00,$98 
	dc.b	$00,'#',$00,$01,$01,')',$00,'O' 
	dc.b	$00,$01,$00,'M',$00,'M',$00,$02 
	dc.b	$01,'3',$00,'Q',$00,$02,$01,'"' 
	dc.b	$00,'C',$00,$00,$00,$8B,$00,'(' 
	dc.b	$00,$01,$00,$BD,$00,'P',$00,$02 
	dc.b	$00,$8A,$00,$B5,$00,$01,$00,$D9 
	dc.b	$00,$98,$00,$00,$00,'R',$00,$9E 
	dc.b	$00,$01,$00,$BE,$00,$AE,$00,$02 
	dc.b	$00,$B1,$00,'8',$00,$01,$00,$CD 
	dc.b	$00,'U',$00,$00,$00,$FD,$00,'"' 
	dc.b	$00,$02,$00,$98,$00,'C',$00,$01 
	dc.b	$00,$10,$00,$0F,$00,$01,$00,$EA 
	dc.b	$00,'>',$00,$01,$00,'r',$00,$05 
	dc.b	$00,$00,$00,'C',$00,$15,$00,$02 
	dc.b	$01,$1A,$00,'=',$00,$00,$01,$0A 
	dc.b	$00,'K',$00,$01,$00,$DA,$00,'P' 
	dc.b	$00,$02,$00,$E0,$00,$A0,$00,$00 
	dc.b	$00,$95,$00,$09,$00,$02,$01,'#' 
	dc.b	$00,'^',$00,$02,$00,$F5,$00,'N' 
	dc.b	$00,$02,$01,$1B,$00,'O',$00,$02 
	dc.b	$00,'s',$00,$B7,$00,$01,$00,$D1 
	dc.b	$00,'h',$00,$00,$01,'5',$00,'a' 
	dc.b	$00,$02,$00,'`',$00,'m',$00,$00 
	dc.b	$00,$0C,$00,$AB,$00,$02,$00,$A7 
	dc.b	$00,$A8,$00,$00,$00,$F3,$00,$0C 
	dc.b	$00,$02,$00,$A5,$00,$9C,$00,$00 
	dc.b	$00,'1',$00,$92,$00,$02,$01,'7' 
	dc.b	$00,'D',$00,$01,$00,$96,$00,'\' 
	dc.b	$00,$00,$00,$83,$00,'0',$00,$00 
	dc.b	$00,$89,$00,'+',$00,$01,$00,'H' 
	dc.b	$00,$84,$00,$01,$01,':',$00,$09 
	dc.b	$00,$02,$00,'E',$00,'p',$00,$00 
	dc.b	$00,$12,$00,'#',$00,$02,$01,$1A 
	dc.b	$00,$05,$00,$01,$00,'A',$00,$96 
l0050	ds.W	200 
l0051	dc.b	'      Release date: 31st August 1992',0,0
l0052	dc.w	0
l0053	dc.w	0

l0054	dc.l	SCRTEXT 
SCRTEXT	dc.b	'          The Source Menu 120',$a
	dc.b	'          -------------------',$a,$a
	dc.b	'       F1 - Digital Justice Demo',$a
	dc.b	'      F2 - Summoning Of The Spawn',$a
	dc.b	'           F3 - Spheres Demo',$a
	dc.b	'            F4 - Teserae +',$a
	dc.b	'              F5 - Droid',$a
	dc.b	'           Space Bar - ZAP +',$a,$a 

	dc.b	'               Credits:',$a
	dc.b	'               --------',$a,$a
	dc.b	'Coding: GOR+TUF     Menu Rip: Special FX',$a,$a
	dc.b	'  Music: Composed with Megatizer v2.4',$a
	dc.b	'  (from Hemoroids Beach Party Dentro)',$a
	dc.b	0

l0056	DS.L	1 
l0057	dc.w	1
l0058	dc.w	0 
l0059	dc.w	0 

;
; This is the colour scheme for the main menu contents text
;

PAL_2_POINT	dc.l	  PALETTE_2 

PALETTE_2	
	rept	19
	dc.w	$777,$777,$766,$766,$755,$755,$744,$744 
	dc.w	$733,$733,$722,$722,$711,$711,$700,$700 
	dc.w	$600,$600
	endr

	dc.w	$777,$777 
	dc.w	$767,$767,$757,$757,$747,$747,$737,$737 
	dc.w	$727,$727,$717,$717,$707 

l005C	dc.w	0
l005D	ds.w	80
l005E	ds.w	592 
scrollp	dc.l	scrolly

scrolly	dc.b	'Oh Boy!  He is using this menu again ......'
	dc.b	'                            '
	dc.b	'Welcome to another menu by MUG U.K(tm) for The Source !!  This is '
	dc.b	'"The Source Menu 120 (The Link-filed Menu ??)"           '

	dc.b	'What should every menu contain ???'
	dc.b	'                      '
	dc.b	'The Credits !!'
	dc.b	'                      '
	dc.b	'Credits to:-   Menu Coding by: GOR+TUF    Menu Ripping by: Alchemy of Special FX    '
	dc.b	'Music Composed With: Megatizer    Music Ripped from the Hemoroids "Beach Dentro" by MUG U.K(tm) '
	dc.b	'- this dentro will be appearing on Menu 124 - '
	dc.b	'and lastly, Menu Compilation: MUG U.K(tm)  !!     '

	dc.b	'On this disk of veritable delights and delictations, we offer you the following sumptious goodies ...... '
	dc.b	'                  '

	dc.b	'First off we have two demos by Digital Justice.  First there is the aptly named "Digital Justice" demo and then '
	dc.b	'there is the "Summoning Of The Spawn" (or "Come Here" for the perverted !!).  Both demos have been link-filed, so '
	dc.b	"there is no need for loads of files wasting the disk space like there's no tomorrow !!  "

	dc.b	'Next up on this lump of magnetic media we have the "Spheres Demo" by MUG U.K(tm) !!!  Yes, it is one of my VERY first '
	dc.b	'attempts at writing a screen demo (circa 1989 !!) - but I have to admit that someone else wrote the original demo and I just purloined '
	dc.b	'various bits and pieces (like all the screens) and then I recently link-filed the demo (as a test for the link-filer) and '
	dc.b	'I thought I may as well release it !!  And there is no doubt that my demo-writing skills HAVE NOT improved more than 1% since '
	dc.b	'I originally wrote this demo !!  '

	dc.b	'The next three jolly items are games that I had lying around on my hard-drive waiting for some space in which to release them !!  '
	dc.b	'"Teserae" and "Zap" both have trainer options, whilst "Droid" was going to have a trainer option, but the damn thing kept on crashing '
	dc.b	'when you lost a life (when you selected Infinite Lives from my cheat version), so I left off the trainer and link-filed the game instead. '
	dc.b	'The docs for "Droid" and "Teserae" are in the root directory, which is where you will find the game "Zap".  '


	dc.b	'Before the general greetings section scrolls past you on this conveyor-message (?), I would like to '
	dc.b	'bore you to death with my own few personal greetings ....................'
	dc.b	'                      '
	
	dc.b	'MUG U.K sends his greetings to:  Other members of The Source (IWWWTTI, Speed, JJF, Mr.X and Egon), MSD of POV, '
	dc.b	'Slasher Bog (and everyone else in Special FX), TGA of NPG (nice bits & pieces you sent, keep them coming), '
	dc.b	'Mr.X (nice catalogue disk), Eddie of THB (hope "All Around The World" is a success !!), L.A.P.D., '
	dc.b	'Keith Frisby, Mark Matts, MSL, and finally Mat (of Untouchables).      '

	dc.b	'The Source greetings go to:  '
	
	dc.b	'The other demo CD makers:-  P.O.V    Ripped Off    NPG (Sadly no more ??)    Public Enemies (New to the scene are you ??'
	dc.b	'  Try packing the stuff when you put it on a menu !!)    Animal Mine (Nice Demo & Utility CDs)         '

	dc.b	'And now the other crews without whom we would probably have nothing to pack !!     '

	dc.b	'Aenigmatica    Agression    Avengers    Animal Mine    ACF    '
	dc.b	'(The German) Alliance    Axxis (or Aura ?)     Admirables    ALF   '
	dc.b	'ACO and Flair (Nice Cunning Demos)    '
	dc.b	'BMT    BBC     (The) Black Cats   (The) Bald Eagle    '
	dc.b	'Cybernetics (Synthy v2.25 is brilliant !!)    Cynix    Chaos    '
	dc.b	'D-Bug (Thanks for the greeting regards the music hacks !!)   Delta Force DNT    DBA (Thanks for Issue 6)   '
	dc.b	'Dal Snuffs    Dynamic Duo    '
	dc.b	'Electra    Electronic Images    Elite    Equinox    Electricity    The Empire    '
	dc.b	'Eternal    (The) Exterminators (nice Demo Ripper - any updates ready yet ??)   '
	dc.b	'Flytox (Nice TCB Tracker Replay program !!)    Frosty    '
	dc.b	'Fuzion    Futur Minds    Factory    Fingerbobs   Flatliners    Firehawks '
	dc.b	'Galtan 6    Genesis Inc.    G-Force    '
	dc.b	'Inner Circle (All members)    Impact    Imagina    '
	dc.b	'JSD    '
	dc.b	'Kruz    Kaos    '
	dc.b	'Light Team    Lord Hackbear    Lightnings    (The) Lost Boys      Legacy    '
	dc.b	'Mad Vision    MJJ    '
	dc.b	'Naos    NATO    Newline    NEXT    NPG (esp. TGA)    '
	dc.b	'Orion    Omega    Oxygen (nice "Genius" Demo)   '
	dc.b	'Paulo Simoes    Pompey Pirates    (The) Pixel Twins    Poltergeists    '
	dc.b	'Quartex    '
	dc.b	'Replicants    R.I.P    '
	dc.b	'Superior    ST Connexion    Stonaction    Special FX (Hi! Mentor)      (The) Syndicate    '
	dc.b	'Slaytanic Cult    Sync    The Supervisors    Sentry    '
	dc.b	'TLS    TSB     TCB   THK (The Megatizer Is Brilliant - and it works on TOS v1.2 !!)    TVI    Torque    '
	dc.b	'ULM    Undead    Union (All members of this massive crew)     Untouchables    U-TOS    '
	dc.b	'V-Max    Vlad (of Lynx)    '
	dc.b	'(The) Watchmen    (The) Wild Boys      '
	dc.b	'Xenex    X-Tream'
	dc.b	'                      '
	
	dc.b	'That is all the greetings for now, so I will see you all on the next Source Menu that '
	dc.b	'I compile !!  This is MUG U.K(tm) signing off .........'
	dc.b	'                  '

	dc.b	'Now doing a wrap ... hold on tight ....................'
	dc.b	'                  '

	dc.b	-1	; end of scrolltext marker

;
; This is the palette for the 'ground' at the bottom of 
; the screen.  It is currently set to various shades of red

l0061	dc.l	PAL_TAB
PAL_TAB	dc.w	$100,$000,$100,$100 
	dc.w	$200,$100,$200,$200 
	dc.w	$300,$200,$300,$300 
	dc.w	$400,$300,$400,$400 
	dc.w	$500,$400,$500,$500 
	dc.w	$600,$500,$600,$600 
	dc.w	$700,$600,$700,$700 
	dc.w	$711,$700,$711,$711 
	dc.w	$722,$711,$722,$722 
	dc.w	$733,$722,$733,$733 
	dc.w	$744,$733,$744,$744 
	dc.w	$755,$744,$755,$755 

MUSIX	INCBIN	'BEACH.THK'
	EVEN
