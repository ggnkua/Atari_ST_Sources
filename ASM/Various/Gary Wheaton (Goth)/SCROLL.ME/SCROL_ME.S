W EQU 4


 CLR.L -(SP)
 MOVE #$20,-(SP)
 TRAP #1
 ADDQ.L #6,SP
 MOVE.L D0,SV



getrez	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,res

setlowrez
	CLR.W	-(A7)		0=low res
	MOVE.L	$44e,-(A7)	-1=ignore physbase
	MOVE.L	$44e,-(A7)	-1=ignore logbase
	MOVE.W	#5,-(A7)
	TRAP	#14		
	LEA	$0C(A7),A7	


 MOVE.L #CPAL,A0
 MOVE.L #$FF8240,A1
 MOVE #15,D0
	move.w	sr,stat

 MOVE.L #l_2d87a,l_2da2c
KJI MOVE (A0)+,(A1)+
 DBRA D0,KJI

 move.l $44e,a0
 move.l a0,skreen
 add.l #28000-160,skreen
	MOVE #7999,D0
TTTR	CLR.L (A0)+
	DBRA D0,TTTR

	move.l	#dta,-(sp)	set up dta section to find size
	move.w	#$1a,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#0,-(sp)	normal file
	move.l	#name,-(sp)	look up attribute
	move.w	#$4e,-(sp)
	trap	#1
	addq.l	#8,sp

	tst	d0		file found?
	bne	getkey		exit

	lea	dta,a0
	move.l	26(a0),d5	size
	move.l	d5,txt_size


* load a file
	MOVE.W	#0,-(A7)	open a file
	pea	name(pc)
	MOVE.W	#$3D,-(A7)
	TRAP	#1
	add.l	#8,sp
	MOVE.W	D0,d7		handle


	MOVE.L	#txt,-(sp)	load	at this address 
	MOVE.L	d5,-(A7)	size
	MOVE.W	d7,-(A7)	handle
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	ADDA.L	#$C,A7


	MOVE.W 	d7,-(SP)	close
	MOVE.W 	#$3E,-(SP)
	TRAP 	#1
	ADDQ.L 	#4,SP



 move.b $469,d0
sxx cmp.b $469,d0
 beq.s sxx
* move.b #0,$ff8260




 BSR tart
 ;\\\\\\\\INIT SCROLL\\\\\\\
 MOVE.L #TXT,A6
 MOVE.L #CHR,A5
 ;****************************
 ;****** A6 IS RESERVED ******
 ;******    SO IS A5    ******
 ;****************************
 ;\\\\\\\\\\SCROLL\\\\\\\\\
LP2 MOVE.B $469,D0
KK CMP.B $469,D0
 BEQ KK
 MOVE.L SKREEN,A1
 MOVE #23,D7
 MOVE.L A1,A2
 MOVE #W,D6

MSTART
 ;\\\\\\\\\LEFT END\\\\\\
P1 MOVE (A1),D0
 ASL D6,D0
P2 MOVE 2(A1),D1
 ASL.L D6,D1
P3 MOVE 4(A1),D2
 ASL.L D6,D2
 MOVE D0,(A1)
 MOVE D1,2(A1)
 MOVE D2,4(A1)
 MOVE #2,D5
 ;\\\\\\\\\\MIDDLE SCROLL\\\\\\\\\\\
MIDLP
 CLR.L D0
 CLR.L D1
 CLR.L D2
 MOVE 8(A1),D0
 ASL.L D6,D0
 MOVE 10(A1),D1
 ASL.L D6,D1
 MOVE 12(A1),D2
 ASL.L D6,D2
 MOVE D0,8(A1)
 SWAP D0
 OR D0,(A1)
 MOVE D1,10(A1)
 SWAP D1
 OR D1,2(A1)
 MOVE D2,12(A1)
 SWAP D2
 OR D2,4(A1)
 CLR.L D0
 CLR.L D1
 CLR.L D2
 MOVE 16(A1),D0
 ASL.L D6,D0
 MOVE 18(A1),D1
 ASL.L D6,D1
 MOVE 20(A1),D2
 ASL.L D6,D2
 MOVE D0,16(A1)
 SWAP D0
 OR D0,8(A1)
 MOVE D1,18(A1)
 SWAP D1
 OR D1,10(A1)
 MOVE D2,20(A1)
 SWAP D2
 OR D2,12(A1)
 CLR.L D0
 CLR.L D1
 CLR.L D2
 MOVE 24(A1),D0
 ASL.L D6,D0
 MOVE 26(A1),D1
 ASL.L D6,D1
 MOVE 28(A1),D2
 ASL.L D6,D2
 MOVE D0,24(A1)
 SWAP D0
 OR D0,16(A1)
 MOVE D1,26(A1)
 SWAP D1
 OR D1,18(A1)
 MOVE D2,28(A1)
 SWAP D2
 OR D2,20(A1)
 CLR.L D0
 CLR.L D1
 CLR.L D2
 MOVE 32(A1),D0
 ASL.L D6,D0
 MOVE 34(A1),D1
 ASL.L D6,D1
 MOVE 36(A1),D2
 ASL.L D6,D2
 MOVE D0,32(A1)
 SWAP D0
 OR D0,24(A1)
 MOVE D1,34(A1)
 SWAP D1
 OR D1,26(A1)
 MOVE D2,36(A1)
 SWAP D2
 OR D2,28(A1)
 CLR.L D0
 CLR.L D1
 CLR.L D2
 MOVE 40(A1),D0
 ASL.L D6,D0
 MOVE 42(A1),D1
 ASL.L D6,D1
 MOVE 44(A1),D2
 ASL.L D6,D2
 MOVE D0,40(A1)
 SWAP D0
 OR D0,32(A1)
 MOVE D1,42(A1)
 SWAP D1
 OR D1,34(A1)
 MOVE D2,44(A1)
 SWAP D2
 OR D2,36(A1)
 CLR.L D0
 CLR.L D1
 CLR.L D2
 MOVE 48(A1),D0
 ASL.L D6,D0
 MOVE 50(A1),D1
 ASL.L D6,D1
 MOVE 52(A1),D2
 ASL.L D6,D2
 MOVE D0,48(A1)
 SWAP D0
 OR D0,40(A1)
 MOVE D1,50(A1)
 SWAP D1
 OR D1,42(A1)
 MOVE D2,52(A1)
 SWAP D2
 OR D2,44(A1)
 ADD.L #48,A1
 DBRA D5,MIDLP
 ADD.L #160,A2
 MOVE.L A2,A1
 DBRA D7,MSTART

TROLLY MOVE #22,D6   HEIGHT
 MOVE.L SKREEN,A2
 ADD #153-8,A2
 MOVE TXTPNT,D1
 CLR D4
 MOVE.B (A6,D1),D4  ;CHR
	clr.l	d5
	move.l	#table,a4
	move.b	0(a4,d4),d5
	clr.l	d4
	move.b	d5,d4

 MULU #300,D4
 CLR D1
 CLR D0
 MOVE.B NIB,D0
 MOVE.B PAK(PC,D0),D1
 ADD D1,D4
 ;\\\\\\\\\\\\\\\\\
PK
 MOVE.B (A5,D4),D1
 MOVE.B 2(A5,D4),D2
 MOVE.B 4(A5,D4),D3
 CMP.B #0,FLIK
 BEQ CONF
 LSR.B #4,D1
 LSR.B #4,D2
 LSR.B #4,D3
 BRA RIDE
PAK DC.B 0,1,6,7
CONF AND.B #15,D1
 AND.B #15,D2
 AND.B #15,D3
RIDE
 OR.B D1,(A2)
 OR.B D2,2(A2)
 OR.B D3,4(A2)
 ADD #12,D4
 ADD.L #160,A2
 DBRA D6,PK
 EOR.B #1,FLIK
 BEQ OINK
 ADD.B #1,NIB
 CMP.B #4,NIB
 BNE OINK
 CLR.B NIB
 ADD #1,TXTPNT
 ;MOVE.B #1,FLIK+1
	MOVE TXTPNT,D0
	move.l	txt_size,d1
	cmp.w	d0,d1
	bgt	oink
	clr.w	txtpnt
* CMP #NIP-TXT,D0
* BNE OINK
* CLR TXTPNT
OINK CMP.B #97,$FFFC02
 BNE LP2

 BSR fred

;	move.w	stat,sr
	move.w	#$007,$ff8240

getkey	MOVE.W	#$07,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	ANDI.W	#$DF,D0		force upper case


	move.w	res,-(A7)		0=low res
	MOVE.L	$44e,-(A7)	-1=ignore physbase
	MOVE.L	$44e,-(A7)	-1=ignore logbase
	MOVE.W	#5,-(A7)
	TRAP	#14		
	LEA	$0C(A7),A7	

 MOVE.L SV,-(SP)
 MOVE #$20,-(SP)
 TRAP #1
 ADDQ.L #6,SP
	CLR.W	-(SP)
	TRAP	#1

res	dc.w 	0
stat	dc.w 0
* RTS
tart
 MOVE.L #XX,A0
 BSR save_mfp
	RTS

save_mfp
 MOVE.B $FFFA09,l_2d9ee
 MOVE.B $FFFA07,l_2d9ef
 MOVE.B $FFFA13,l_2d9f0
 MOVE.L $118,l_2d9f2
 MOVE.L $120,l_2d9f6
 MOVE.L $70,l_2d9fa
 MOVE.L $118,nick+2
 MOVE.L #TYny,$118
 ANDI.B  #$DF,$FFFA09
 ANDI.B #$FE,$FFFA07
 MOVE.L #jack,$120
 ORI.B #1,$FFFA07
 ORI.B #1,$FFFA13
 MOVE.L $70,lou+2
 MOVE.L #mfp,$70
 MOVE.W #0,l_2da22
 RTS
fred
 TST.W l_2da22
 BEQ RE_mfp
 RTS
freddy
RE_mfp
 MOVE.B l_2d9ee,$FFFA09
 MOVE.B l_2d9ef,$FFFA07
 MOVE.B l_2d9f0,$FFFA13
 MOVE.L l_2d9f2,$118
 MOVE.L l_2d9f6,$120
 MOVE.L l_2d9fa,$70
 RTS

mfp
 MOVE.B #0,$FFFA1B
 ;timer B control (this routine is ..
st15
 MOVE.B #49,$FFFA21
 ;timer B data ..slotted in $70)
 CMPI.B #49,$FFFA21
 BNE.S st15
 MOVE.L #jack,$120
ggf
 MOVE.L l_2da2c,l_2da24
 MOVE.B #8,$FFFA1B
 SUBQ.B #1,NANCY
 BPL.S FOL
 ADDQ.L #2,l_2da2c
 MOVE.B #1,NANCY
 CMP.L #XX+(126*2),l_2da2c
 BNE.S FOL
 MOVE.L #XX,l_2da2c
FOL 
 CLR VCN
 ADD.L #1,$466
 RTE
lou JMP $0
  ;receives $70 address
TYny
 MOVE.W #$2500,SR
  ;enable level 6 INTERRupt
nick JMP $0
 ;receives $118 address
jack
 MOVE.L A0,-(SP)  
 MOVE.L #sid,$120
     ;after Jack, now Sid
 BRA.S st16    

sid
 MOVE.L A0,-(SP)
 ADDQ #1,VCN
 CMP #40,VCN
 BLT.S st16
  
 MOVEA.L l_2da24,A0
 MOVE.W (A0),$FF8240+14
 ADDQ.L #2,l_2da24
st16
 MOVE.B #0,$FFFA1B
 ;TIMEr B control
st17
 MOVE.B #2,$FFFA21
 ;TIMEr B DATA
  
 CMPI.B #2,$FFFA21       
 BNE.S st17            
 BCLR #0,$FFFA0F
      ;interr in service A
 MOVE.B #8,$FFFA1B
 ;TIMEr B control
 MOVE.L (SP)+,A0 
 RTE
l_2d9ee
 DC.B 0
 ;mfp
l_2d9ef
 DC.B 0
l_2d9f0
 DC.B 0
  ;b mfp
FLAG
 DC.B 0
 EVEN
l_2d9f2
 DC.L 0
 ;l ($118)
l_2d9f6
 DC.L 0
 ;l ($120)
l_2d9fa
 DC.L 0
 ;l ($70)
l_2da24
 DC.L 0
 ;l
l_2da22
 DC.W 0
 ;w
l_2da2c
 DC.L 0
 ;l
VCN DC.B 0,0
l_2d87a
l_2d940
XX INCBIN	a:\scroll.me\COLORS.DLI
* DS.W 126
YY DS.W 40

SV DC.L 0
FLIK DC.B 0,1
number	dc.b 38
	even
CPAL DC.W 1,$777,$666,$555,$444,$333,$222,$111
 Dc.W $777,$777,$777,$777,$777,$777,$777,$777,$777
SKREEN DC.L $78000
name	dc.b	"a:\scroll.me\text.asc",0
	even
 DC.B 45,45
	even

NIP
TXTPNT DC.W 0
NIB DC.B 0,0
NANCY DC.B 0,0
	even
CHR INCBIN a:\scroll.me\GOLDFONT.*

* a=0  25=z  26 excl   27 face   28  matches  29;
* 30=0  39=9   40="   41(  42)  43'   44_   45.   46,
* 47?   48:   49 space
	even
table
	
	dc.b	49,49,49,49,49,49,49,49,49,49  ascii 0 to 9

	dc.b	49,49,49,49,49,49,49,49,49,49  ascii 10 to 19

	dc.b	49,49,49,49,49,49,49,49,49,49  ascii 20 to 29
	dc.b	49,49,49
	dc.b	26,40,28     33/34/35  are ! " # with # as fags
	dc.b	49,49,49,43  43 is '
	dc.b    41,42        ()
	dc.b    27            * is happy face
	dc.b    49,46        46 is ,
	dc.b	49,45        45 is .
	dc.b    49
	dc.b	30,31,32,33,34,35,36,37,38,39  numerals
	dc.b	48,43,49,49,49,47     47 is ?
	dc.b	49
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
	dc.b	19,20,21,22,23,24,25     a-z
	dc.b	49,49,49,49,49,49
 	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
	dc.b	19,20,21,22,23,24,25     a-z  l/case
	dc.b	41,49,42,27,28     up to ascii 127
	even
txt_size	dc.l 0
handle	dc.w	0
dta	ds.b	66
txt	ds.w	2000  where file will go