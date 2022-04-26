*
*
*
screen	equ $30000

	jsr	start

	tst.l	fptr
	beq	no_start

setblock	move.l	a7,a5
	move.l	#stack,a7
	move.l	4(a5),a5
	move.l	a5,begin_bse
	move.l	#pend,a4
	sub.l	#setblock,a4    * andrad: #start->#setblock
	add.l	#$100,a4
	move.l	a4,prglength
	move.l	prglength,-(sp)
	move.l	begin_bse,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp



* execute prog
	clr.l	-(sp)
	clr.l	-(sp)
	move.l	fptr,-(sp)
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
stop	bra	stop


no_start	clr.w	-(sp)
	trap	#1


	even
fptr	ds.l 1
	even
file1	dc.b "APT.PRG",0
	even
file2	dc.b "REVEL.PRG",0
	even
file3	dc.b "TCB.PRG",0
	even
begin_bse	ds.l 1
prglength	ds.l 1
	ds.w $100
stack	dc.w 0
pend



* INTO SUPERVISOR MODE
start	CLR.L	-(A7)
	MOVE.W	#32,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	MOVE.L	D0,save_usp
	
	
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,physbase
	
	
	move.w	#0,-(sp)
	move.l	#screen,-(sp)
	move.l	#screen,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea.l	12(sp),sp
	

	lea.l	tab,a0
	lea.l	tabend,a1
nextval	move.w	(a0),d0
	add.w	#84,d0
	mulu.w	#160,d0
	move.w	d0,(a0)+
	cmp.l	a1,a0
	blo.s	nextval
	
	
	

* SAVE VECTORS AND OTHER SHIT
	LEA	STORAGE,A0
	MOVE.L	$70.W,(A0)+
	MOVE.L	$120.W,(A0)+
	MOVE.B	$FFFFFA1B.W,(A0)+
	MOVE.B	$FFFFFA21.W,(A0)+
	MOVE.B	$FFFFFA07.W,(A0)+
	MOVE.B	$FFFFFA09.W,(A0)+
	MOVE.B	$FFFFFA13.W,(A0)+
	ADDQ.L	#1,A0			MAKE ADDRESS EVEN


	move.l	#1,d0
	jsr	music(pc)
	

	movem.l	bild+2,d0-d7
	movem.l	d0-d7,$ff8240

	lea.l	bild+34+(160*140),a0
	move.l	#screen+(160*199),a1
	move.w	#40*44-1,d0
putpict	move.l	(a0)+,(a1)+
	dbra	d0,putpict
	
	lea.l	bild+34,a0
	move.l	#screen,a1
	move.w	#40*90-1,d0
puttext	move.l	(a0)+,(a1)+
	dbra	d0,puttext
	
	
* SET UP NEW VECTORS
	MOVE.W	#$2700,SR		STOP INTERRUPTS
	MOVE.L	#VBL,$70.W		NEW VBL VECTOR
	MOVE.L	#myhbl1,$120.W	NEW TIMER B INTERRUPT HANDLER
	CLR.B	$FFFFFA07.W		MFP RESET
	CLR.B	$FFFFFA09.W
	ORI.B	#1,$FFFFFA07.W	ENABLE TIMER B
	ORI.B	#1,$FFFFFA13.W
	CLR.B	$FFFFFA1B.W		STOP TIMER B
	MOVE.W	#$2300,SR		ENABLE INTERRUPTS
	
	
WAIT	tst.b	vblflag
	beq	WAIT
	sf.b	vblflag
	move.b	$fffffc02.w,d0
	cmp.b	#130,d0
	bne	not_k1
	move.l	#file1,fptr
	bra	outofit
not_k1	cmp.b	#131,d0
	bne	not_k2
	move.l	#file2,fptr
	bra	outofit
not_k2	cmp.b	#132,d0
	bne	not_k3
	move.l	#file3,fptr
	bra	outofit
not_k3	
	CMPI.B	#133,d0
	BNE	WAIT

outofit


	
* RESTORE VECTORS AND SHIT
	move.l	#$ff8240,a0
	move.w	#8-1,d0
	MOVE.W	#$2700,SR
nextcol	clr.l	(a0)+
	dbra	d0,nextcol
	LEA	STORAGE,A0
	MOVE.L	(A0)+,$70.W
	MOVE.L	(A0)+,$120.W
	MOVE.B	(A0)+,$FFFFFA1B.W
	MOVE.B	(A0)+,$FFFFFA21.W
	MOVE.B	(A0)+,$FFFFFA07.W
	MOVE.B	(A0)+,$FFFFFA09.W
	MOVE.B	(A0)+,$FFFFFA13.W
	ADDQ.L	#1,A0

	move.l	#$08000000,$ff8800
	move.l	#$09000000,$ff8800
	move.l	#$0a000000,$ff8800
	
;	move.l	#screen,a0
;	move.l	#8000-1,d0
;clearlong	clr.l	(a0)+
;	dbra	d0,clearlong
	
	move.w	#-1,-(sp)
	move.l	physbase,-(sp)
	move.l	physbase,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea.l	12(sp),sp



;	move.w	#$000,$ff8240
;	move.w	#$777,$ff8246

	
	MOVE.W	#$2300,SR

	
	
	MOVE.L	save_usp,-(A7)
	MOVE.W	#32,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7

	rts

save_usp	ds.l 1
physbase	ds.l 1

* VBL INTERRUPT HANDLER
VBL	CLR.B	$FFFFFA1B.W		STOP TIMER B
	MOVE.B	#198,$FFFFFA21		OCCUR ON LAST SCANLINE
	MOVE.B	#8,$FFFFFA1B.W		START TIMER B
	move.l	#myhbl1,$120
	movem.l	bild+2,d0-d7
	movem.l	d0-d7,$ff8240

	lea.l	checkpal+2(pc),a0
	move.w	(a0),d0
	move.w	#13-1,d1
rotpal	move.w	2(a0),(a0)+
	dbra	d1,rotpal
	move.w	d0,(a0)

	jsr	jump(pc)
	jsr	scroll(pc)
	jsr	music+8(pc)
	st.b	vblflag

	RTE				PISS OFF


************************************************
*
* HBL ROUT...
*
myhbl1	CLR.B	$FFFFFA1B.W		STOP TIMER B
	MOVE.B	#1,$FFFFFA21	OCCUR ON LAST SCANLINE
	MOVE.B	#8,$FFFFFA1B.W	START TIMER B
	and.b	#$fe,$fffa0f
	move.l	#myhbl2,$120
	movem.l	checkpal,d0-d7
	movem.l	d0-d7,$ff8240
	rte


myhbl2	CLR.B 	$FFFFFA1B.W		STOP TIMER
	MOVEM.L 	D0/A0,-(a7)
	MOVEA.W 	#$FA21,A0
	MOVE.B 	#200,(A0)
	MOVE.B 	#8,$FFFFFA1B.W		START TIMER
	MOVE.B	(A0),D0
WAIT2	CMP.B	(A0),D0			
	BEQ	WAIT2
	CLR.B	$FFFF820A.W		INTO 60 HZ
	MOVEQ.W	#2,D0
LOOP1	NOP
	DBF	D0,LOOP1
	MOVE.B	#2,$FFFF820A.W		INTO 50 HZ
	MOVEM.L	(A7)+,D0/A0
	BCLR	#0,$FFFFFA0F.W		ACKNOWLEDGE
	RTE				BUGGER OFF
		

vblflag	ds.w 1
STORAGE	DS.B 18
	DS.L 63

	even
music	incbin a:\FLETCH.mus
	even

jump	move.l	#screen,a1
	move.l	tabptr,a6
	add.w	(a6)+,a1
	cmp.l	#tabend,a6
	blo	conttab
	lea.l	tab,a6
conttab	move.l	a6,tabptr
	move.w	#40*3-1,d0
clrtop	clr.l	160*45(a1)
	clr.l	(a1)+
	dbra	d0,clrtop

	
	
	move.l	#screen,a1
	add.w	(a6),a1
	lea.l	bild+34+(160*90),a0
	rept 48
	movem.l	(a0),d0-d7/a2-a6
	movem.l	d0-d7/a2-a6,(a1)

	movem.l	52(a0),d0-d7/a2-a6
	movem.l	d0-d7/a2-a6,52(a1)

	movem.l	104(a0),d0-d7/a2-a6
	movem.l	d0-d7/a2-a6,104(a1)
	
	move.l	156(a0),156(a1)

	lea.l	160(a0),a0
	lea.l	160(a1),a1
	endr
	
	rts



	even
tabptr	dc.l tab
tab
; dc.w 0,0,1,3,6,9,13,18,23,29,35,41,48,54,60
; dc.w 66,72,78,83,87,91,94,97,98,99,99,99,97,95,92
; dc.w 88,84,79,73,68,62,55,49,43,36,30,25,19,14,10
; dc.w 7,4,1,0,0

; dc.w 0,0,1,2,4,6,9,12,16,20,25,29,34,39,45
; dc.w 50	*,55,60,65,70,75,79,83,87,90,93,95,97,99,99
; dc.w 99,99,98,97,95,92,89,86,82,78,74,69,64,59,54
; dc.w 48,43,38,33,28,23,19,15,11,8,5,3,1,0,0

	dc.w 0,0,0,0,0,0,1,1,2,2,3,3,4,5,6,7,8,9,10,11
	dc.w 12,13,15,16,18,19,21,22,24,26,27,29,31,33,35,37,39,41,44,46
	dc.w 48,50,53,55,58,60,63,65	*,68,70,73,76,79,81,84,87,90,93,96,99
;	dc.w 102,105,108,111,114,117,120,123,126,129	*,132,135,139	*,142,145,148,151,155,158,161
;	dc.w 164,167,171,174,177,180,183,186,190,193,196,199,202,205,208,211,214,217,220,223
;	dc.w 226,229,232,235,237,240,243,246,248,251,254,256,259,261,264,266,268,271,273,275
;	dc.w 277,280,282,284,286,288,290,291,293,295,297,298,300,301,303,304,305,307,308,309
;	dc.w 310,311,312,313,314,315,316,316,317,317,318,318,319,319,319,319,319,319,319,319
;	dc.w 319,319,319,318,318,317,317,316,316,315,314,313,312,311,310,309,308,307,306,304
;	dc.w 303,302,300,298,297,295,293,292,290,288,286,284,282,280,278,276,273,271,269,266
;	dc.w 264,262,259,257,254,251,249,246,243,241,238,235,232,229,227,224,221,218,215,212
;	dc.w 209,206,203,199,196,193,190,187,184,181,177,174,171,168,165,161
;	dc.w 158,155,152,149
;	dc.w 146,142,
;	dc.w 139,136,133,130,
;	dc.w 127,123,120,117,114,111,108,105,102,
;	dc.w 99,96,93,90,87
;	dc.w 85,82,79,76,73,71,68
	dc.w 66,63,60,58,55,53,51,48,46,44,42,40,37
	dc.w 35,33,31,30,28,26,24,23,21,19,18,16,15,14,12,11,10,9,8,7
	dc.w 6,5,4,3,3,2,2,1,1,0,0,0,0,0,0

tabend

****************************************
* Nifty little scroll rout...
scroll	lea.l	bild+34+(160*143),a0
	move.l	#screen+(160*202),a1

	rept	16
	movem.l	(a0),d0-d7/a2-a6
	movem.l	d0-d7/a2-a6,(a1)

	movem.l	52(a0),d0-d7/a2-a6
	movem.l	d0-d7/a2-a6,52(a1)

	movem.l	104(a0),d0-d7/a2-a6
	movem.l	d0-d7/a2-a6,104(a1)
	
	move.l	156(a0),d0
	move.l	d0,156(a1)
	
	lea.l	160(a0),a0
	lea.l	160(a1),a1

	endr
	
	
	lea.l	scrollbuf,a0
	move.l	#screen+(160*202),a1
	move.w	#20-1,d0
putline	move.w	(a0),d7
	or.w	d7,(a1)
	or.w	d7,2(a1)
	or.w	d7,4(a1)
	or.w	d7,6(a1)
	
	move.w	40*1(a0),d7
	or.w	d7,160*1(a1)
	or.w	d7,160*1+2(a1)
	or.w	d7,160*1+4(a1)
	or.w	d7,160*1+6(a1)
	
	move.w	40*2(a0),d7
	or.w	d7,160*2(a1)
	or.w	d7,160*2+2(a1)
	or.w	d7,160*2+4(a1)
	or.w	d7,160*2+6(a1)
	
	move.w	40*3(a0),d7
	or.w	d7,160*3(a1)
	or.w	d7,160*3+2(a1)
	or.w	d7,160*3+4(a1)
	or.w	d7,160*3+6(a1)
	
	move.w	40*4(a0),d7
	or.w	d7,160*4(a1)
	or.w	d7,160*4+2(a1)
	or.w	d7,160*4+4(a1)
	or.w	d7,160*4+6(a1)
	
	move.w	40*5(a0),d7
	or.w	d7,160*5(a1)
	or.w	d7,160*5+2(a1)
	or.w	d7,160*5+4(a1)
	or.w	d7,160*5+6(a1)
	
	move.w	40*6(a0),d7
	or.w	d7,160*6(a1)
	or.w	d7,160*6+2(a1)
	or.w	d7,160*6+4(a1)
	or.w	d7,160*6+6(a1)
	
	move.w	40*7(a0),d7
	or.w	d7,160*7(a1)
	or.w	d7,160*7+2(a1)
	or.w	d7,160*7+4(a1)
	or.w	d7,160*7+6(a1)
	
	move.w	40*8(a0),d7
	or.w	d7,160*8(a1)
	or.w	d7,160*8+2(a1)
	or.w	d7,160*8+4(a1)
	or.w	d7,160*8+6(a1)
	
	move.w	40*9(a0),d7
	or.w	d7,160*9(a1)
	or.w	d7,160*9+2(a1)
	or.w	d7,160*9+4(a1)
	or.w	d7,160*9+6(a1)
	
	move.w	40*10(a0),d7
	or.w	d7,160*10(a1)
	or.w	d7,160*10+2(a1)
	or.w	d7,160*10+4(a1)
	or.w	d7,160*10+6(a1)
	
	move.w	40*11(a0),d7
	or.w	d7,160*11(a1)
	or.w	d7,160*11+2(a1)
	or.w	d7,160*11+4(a1)
	or.w	d7,160*11+6(a1)
	
	move.w	40*12(a0),d7
	or.w	d7,160*12(a1)
	or.w	d7,160*12+2(a1)
	or.w	d7,160*12+4(a1)
	or.w	d7,160*12+6(a1)
	
	move.w	40*13(a0),d7
	or.w	d7,160*13(a1)
	or.w	d7,160*13+2(a1)
	or.w	d7,160*13+4(a1)
	or.w	d7,160*13+6(a1)
	
	move.w	40*14(a0),d7
	or.w	d7,160*14(a1)
	or.w	d7,160*14+2(a1)
	or.w	d7,160*14+4(a1)
	or.w	d7,160*14+6(a1)
	
	move.w	40*15(a0),d7
	or.w	d7,160*15(a1)
	or.w	d7,160*15+2(a1)
	or.w	d7,160*15+4(a1)
	or.w	d7,160*15+6(a1)
	
	
	addq.l	#2,a0
	addq.l	#8,a1
	
	dbra	d0,putline
	
	move.w	#2-1,d6
x2	lea.l	scrollbuf,a0
	move.w	#15-1,d0
nlin	and.w	#$ff00,sr
	roxl.w	2*19(a0)
	roxl.w	2*18(a0)
	roxl.w	2*17(a0)
	roxl.w	2*16(a0)
	roxl.w	2*15(a0)
	roxl.w	2*14(a0)
	roxl.w	2*13(a0)
	roxl.w	2*12(a0)
	roxl.w	2*11(a0)
	roxl.w	2*10(a0)
	roxl.w	2*9(a0)
	roxl.w	2*8(a0)
	roxl.w	2*7(a0)
	roxl.w	2*6(a0)
	roxl.w	2*5(a0)
	roxl.w	2*4(a0)
	roxl.w	2*3(a0)
	roxl.w	2*2(a0)
	roxl.w	2*1(a0)
	roxl.w	(a0)
	lea.l	40(a0),a0
	dbra	d0,nlin



	lea.l	bit(pc),a6
	move.l	(a6),d7
	dbra	d7,nbit
	lea.l	messptr(pc),a1
	move.l	(a1),a0
readchar	move.b	(a0)+,d0
	bne.s	contchar
	lea.l	message(pc),a0
	bra.s	readchar
	
contchar	move.l	a0,(a1)
	lea.l	font(pc),a0
	and.w	#$00ff,d0
	asl.w	#5,d0
	add.w	d0,a0
	lea.l	charaddr(pc),a1
	move.l	a0,(a1)
	move.l	#16-1,d7

nbit	move.l	d7,(a6)
	move.l	charaddr(pc),a0
	lea.l	scrollbuf,a1
	move.w	#16-1,d0
nextlin2	move.w	(a0)+,d1
	btst.l	d7,d1
	beq	not_set
	bset.b	#0,39(a1)
	bra	setcont
not_set	bclr.b	#0,39(a1)
setcont	lea.l	40(a1),a1
	dbra	d0,nextlin2
	dbra	d6,x2
	
	rts

bit	ds.l 1
messptr	dc.l message
message	
 DC.B "FOLKE IN ACTION!  "
 DC.B 0
charaddr	ds.l 1
font	incbin a:\nibble2.fnt
	even
scrollbuf	ds.b 40*16

checkpal	dc.w $000,$4,$5,$6,$7,$6,$5,$4
	dc.w $044,$055,$066,$077,$066,$055,$044,$777

bild	incbin a:\tsc7.pi1
		