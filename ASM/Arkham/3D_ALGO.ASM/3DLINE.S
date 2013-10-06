;-------------------------------;
; routine de ligne assez rapide ;
;-------------------------------;

 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 lea.l 12(a7),sp

 BSR INIT_LINE_ROUT

 pea 0.w
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,rpile+2

 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
 move.w #$777,$ffff8242.w

prog
 move.w #37,-(sp)  
 trap #14
 addq.l #2,sp
 clr.w $ffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end

; efface l'ancien objet

 movea.l ecr2,a0
 adda.l #50*$a0,a0
 moveq.l #0,d0
 move.w #120*160/4-1,d1
clr_object
 move.l d0,(a0)+
 dbf d1,clr_object

; traite les points de l'objet

 lea.l object,a0
 lea.l new_object,a1
 lea.l cosinus,a2
 move.w #3,d0
calcul_object
 move.w (a0)+,d1
 move.w (a0)+,d2
 move.w (a0)+,d3

; ici,on a les rotations

 move.w alpha,d7

; rotation X
 
 move.w d2,d4
 move.w d3,d5
 muls.w (a2,d7.w),d2
 muls.w 2(a2,d7.w),d3
 add.w d3,d2
 asr.w #7,d2
 muls.w (a2,d7.w),d5
 muls.w 2(a2,d7.w),d4
 sub.w d4,d5
 asr.w #7,d5
 move.w d5,d3

; rotation Y

 move.w d1,d4
 move.w d3,d5

 muls.w (a2,d7.w),d1
 muls.w 2(a2,d7.w),d3
 add.w d3,d1
 asr.w #7,d1

 muls.w (a2,d7.w),d5
 muls.w 2(a2,d7.w),d4
 sub.w d4,d5
 asr.w #7,d5
 move.w d5,d3

; projection

 addi.w #160,d1
 addi.w #100,d2
 move.w d1,(a1)+
 move.w d2,(a1)+

 dbf d0,calcul_object

; on affiche l'objet avec les lignes

 lea.l new_object,a2
 lea.l line_data,a1
aff_object
 move.w (a1)+,d0
 lea.l (a2,d0.w),a3
 move.w (a3)+,d0
 move.w (a3)+,d1

 move.w (a1)+,d2
 lea.l (a2,d2.w),a3
 move.w (a3)+,d2
 move.w (a3)+,d3
 movea.l ecr2,a0

 movem.l d0-a6,-(sp)
 bsr line
 movem.l (sp)+,d0-a6

 cmpa.l #line_data2,a1
 bne aff_object

 addq.w #4,alpha
 cmpi.w #360*4,alpha
 blo nofin_alpha
 move.w #0,alpha
nofin_alpha

 move.b ecr2+1,$ffff8201.w
 move.b ecr2+2,$ffff8203.w

 move.l ecr1,a0
 move.l ecr2,ecr1
 move.l a0,ecr2

 cmpi.b #$36,$fffffc02.w
 bne no_shift
 move.w #$452,$ffff8240.w
no_shift

 bra prog

end
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
rpile pea 0
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 clr  -(sp) 
 trap #1

INIT_LINE_ROUT:
* ROUTINE HORIZONTALE * 20
	LEA	DEB_1(PC),A1
	LEA	FIN_1(PC),A2
	MOVE.W	#18,D1
.0:	MOVE.W	#((FIN_1-DEB_1)/2)-1,D0
	MOVE.L	A1,A3
.1:	MOVE.W	(A3)+,(A2)+
	DBRA.W	D0,.1
	DBRA.W	D1,.0
* REPERTORATION DES 320 OR ET BSET
	LEA	DEB_1(PC),A0
	LEA	FIN_H(PC),A2
	LEA	TAB320(PC),A1
.2:	MOVE.W	(A0)+,D0
	CMPI.W	#$DE4A,D0
	BNE.S	.3
	LEA	-4(A0),A3
	MOVE.L	A3,(A1)+
.3:	CMP.L	A0,A2
	BNE.S	.2
* ROUTINE VERTICALE * 200
	LEA	DEB_2(PC),A1
	LEA	FIN_2(PC),A2
	MOVE.W	#198,D1
.4:	MOVE.W	#((FIN_2-DEB_2)/2)-1,D0
	MOVE.L	A1,A3
.5:	MOVE.W	(A3)+,(A2)+
	DBRA.W	D0,.5
	DBRA.W	D1,.4
* REPERTORATION DES 200 BSET
	LEA	DEB_2(PC),A0
	LEA	FIN_V(PC),A2
	LEA	TAB200(PC),A1
.6:	MOVE.W	(A0)+,D0
	CMPI.W	#$DC4A,D0
	BNE.S	.7
	LEA	-4(A0),A3
	MOVE.L	A3,(A1)+
.7:	CMP.L	A0,A2
	BNE.S	.6
* TABLE DE MULTIPLICATION DE 160
	LEA	TAB160(PC),A0
	CLR.W	D1
	MOVE.W	#199,D0
.9:	MOVE.W	D1,(A0)+
	ADD.W	#160,D1
	DBRA.W	D0,.9
* ROUTINE D'EFFACEMENT 1
	LEA	SC_FILL1(PC),A0
	MOVE.W	#(200*20)-2,D0
	CLR.W	D6
.A:	MOVE.W	#$3140,(A0)+
	ADDQ.W	#8,D6
	MOVE.W	D6,(A0)+
	DBRA.W	D0,.A
* ROUTINE D'EFFACEMENT 2
	LEA	SC_FILL2(PC),A0
	MOVE.W	#99,D0
	MOVE.W	#(50*160)+32,D6
.D:	MOVE.W	#9,D1
.C:	MOVE.W	#$3140,(A0)+
	ADDQ.W	#8,D6
	MOVE.W	D6,(A0)+
	DBRA.W	D1,.C
	ADD.L	#80,D6
	DBRA.W	D0,.D
	RTS
***************************************
* ADRESSE ECRAN: A0                   *
* POINT 1 :      X1: D0  / Y1: D1     *
* POINT 2 :      X2: D2  / Y2: D3     *
***************************************
line
* ON S'ASSURE QUE X1 < X2
	CMP.W	D0,D2
	BPL.S	.NEXT1
	EXG	D0,D2
	EXG	D1,D3
.NEXT1:	LEA	TAB160(PC),A6
	LEA	160.W,A3	* A3=160 (ON DESCEND)
* DX
	MOVE.W	D2,A1	* A1=X2-X1
	SUB.W	D0,A1
* ON MONTE OU ON DESCEND ?
	CMP.W	D1,D3
	BPL.S	.NEXT2
	LEA	-160.W,A3	* A3=-160 (ON MONTE)
* DY (ON MONTE)
	MOVE.W	D1,A2	* A2=Y1-Y2
	SUB.W	D3,A2
	BRA.S	.NEXT3
.NEXT2:
* DY (ON DESCEND)
	MOVE.W	D3,A2	* A2=Y2-Y1
	SUB.W	D1,A2
* DX > DY ?
.NEXT3:	CMP.W	A1,A2
	BLS.S	XVERSION
YVERSION:
* DETERMINATION DE LA LIGNE DE DEPART
	MOVE.W	D1,D4
	LSL.W	#1,D4
	MOVE.W	(A6,D4.W),D4
	ADD.W	D4,A0
* DE L'OCTET EXACTE DE DEPART
	MOVE.W	D0,D4
	AND.W	#$FFF0,D4
	LSR.W	#1,D4
	ADD.W	D4,A0
	MOVE.W	D0,D4
	AND.W	#$000F,D4
	CMPI.W	#8,D4
	BMI.S	.NEXT4
	ADDQ.L	#1,A0
	SUBQ.W	#8,D4	
* ON POSE LE RTS ET ON CALCUL L'ADRESSE DE BRANCHEMENT
.NEXT4:	MOVE.W	#7,-(SP)
	SUB.W	D4,(SP)
	MOVE.W	A3,D4
	BPL.S	.NEXT6
	EXG	D1,D3
.NEXT6:	LEA	TAB200(PC),A4
	MOVE.W	D1,D4
	LSL.W	#2,D4
	MOVE.L	(A4,D4.W),A5
	MOVE.W	D3,D4
	LSL.W	#2,D4
	MOVE.L	(A4,D4.W),A4
	ADDQ.L	#2,A4
	MOVE.W	(A4),A6
	MOVE.W	#$4E75,(A4)
* ON CALCULE LE PAS
	CLR.L	D7
	MOVE.W	A1,D7
	SWAP	D7
	MOVE.W	A2,D1
	BEQ.S	.NEXT5
	DIVU	D1,D7
	MOVE.W	D7,A2
	BRA.S	CONT1
.NEXT5:	MOVE.W	#0,A2
* ON PREPARE LES REGISTRES
CONT1:	
	MOVE.W	(SP)+,D7
	MOVE.L	#$00070001,D0
	MOVE.W	A0,D1
	AND.W	#1,D1
	BEQ.S	CONT5
	SWAP	D0
CONT5	MOVE.W	#$7FFF,D6
	JSR	(A5)
	MOVE.W	A6,(A4)
	RTS
XVERSION:
* DETERMINATION DE LA LIGNE DE DEPART
	MOVE.W	D1,D4
	LSL.W	#1,D4
	MOVE.W	(A6,D4.W),D4
	ADD.W	D4,A0
* DE L'OCTET EXACTE DE DEPART
	MOVE.W	D0,D4
	AND.W	#$FFF0,D4
	LSR.W	#1,D4
	ADD.W	D4,A0
	MOVE.W	D0,D4
	AND.W	#$000F,D4
	CMPI.W	#8,D4
	BMI.S	.NEXT6
	ADDQ.L	#1,A0
* ON POSE LE RTS ET ON CALCUL L'ADRESSE DE BRANCHEMENT
.NEXT6:	LEA	TAB320(PC),A4
	MOVE.W	D0,D4
	LSL.W	#2,D4
	MOVE.L	(A4,D4.W),A5
	MOVE.W	D2,D4
	LSL.W	#2,D4
	MOVE.L	(A4,D4.W),A4
	ADDQ.L	#2,A4
	MOVE.W	(A4),A6
	MOVE.W	#$4E75,(A4)
* ON CALCULE LE PAS
	CMP.W	A2,A1
	BEQ.S	.NEXT8
	CLR.L	D7
	MOVE.W	A2,D7
	SWAP	D7
	MOVE.W	A1,D1
	BEQ.S	.NEXT7
	DIVU	D1,D7
	MOVE.W	D7,A2
	BRA.S	CONT2
.NEXT8:	MOVE.W	#-1,A2
	BRA.S	CONT2
.NEXT7:	MOVE.W	#0,A2
* ON PREPARE LES REGISTRES
CONT2:	MOVE.W	#001,D0	* D0 SERT 2 FOIS
	MOVE.W	#004,D1
	MOVE.W	#008,D2
	MOVE.W	#016,D3
	MOVE.W	#032,D4
	MOVE.W	#064,D5
	MOVE.W	#128,D6
	MOVE.W	#$7FFF,D7
	JSR	(A5)
	MOVE.W	A6,(A4)
	RTS
* LET'S GO !
* ROUTINE DE LIGNE HORIZONTALE
DEB_1:	OR.B	D6,(A0)
	ADD.W	A2,D7
	BCC.S	.CONT1
	ADD.W	A3,A0
.CONT1:	OR.B	D5,(A0)
	ADD.W	A2,D7
	BCC.S	.CONT2
	ADD.W	A3,A0
.CONT2:	OR.B	D4,(A0)
	ADD.W	A2,D7
	BCC.S	.CONT3
	ADD.W	A3,A0
.CONT3:	OR.B	D3,(A0)
	ADD.W	A2,D7
	BCC.S	.CONT4
	ADD.W	A3,A0
.CONT4:	OR.B	D2,(A0)
	ADD.W	A2,D7
	BCC.S	.CONT5
	ADD.W	A3,A0
.CONT5:	OR.B	D1,(A0)
	ADD.W	A2,D7
	BCC.S	.CONT6
	ADD.W	A3,A0
.CONT6:	BSET.B	D0,(A0)
	ADD.W	A2,D7
	BCC.S	.CONT7
	ADD.W	A3,A0
.CONT7:	OR.B	D0,(A0)+
	ADD.W	A2,D7
	BCC.S	.CONT8
	ADD.W	A3,A0
.CONT8:	OR.B	D6,(A0)
	ADD.W	A2,D7
	BCC.S	.CONT9
	ADD.W	A3,A0
.CONT9:	OR.B	D5,(A0)
	ADD.W	A2,D7
	BCC.S	.CONT10
	ADD.W	A3,A0
.CONT10:	OR.B	D4,(A0)
	ADD.W	A2,D7
	BCC.S	.CONT11
	ADD.W	A3,A0
.CONT11:	OR.B	D3,(A0)
	ADD.W	A2,D7
	BCC.S	.CONT12
	ADD.W	A3,A0
.CONT12:	OR.B	D2,(A0)
	ADD.W	A2,D7
	BCC.S	.CONT13
	ADD.W	A3,A0
.CONT13:	OR.B	D1,(A0)
	ADD.W	A2,D7
	BCC.S	.CONT14
	ADD.W	A3,A0
.CONT14:	BSET.B	D0,(A0)
	ADD.W	A2,D7
	BCC.S	.CONT15
	ADD.W	A3,A0
.CONT15:	OR.B	D0,(A0)
	ADD.W	A2,D7
	BCC.S	.CONT16
	ADD.W	A3,A0
.CONT16:	ADDQ.W	#7,A0
FIN_1:	DS.B	(FIN_1-DEB_1)*19
FIN_H:	RTS
DEB_2:	BSET	D7,(A0)
	ADD.W	A2,D6
	BCC.S	JUMP
	DBF.W	D7,JUMP
	ADDA.W	D0,A0
	SWAP	D0
	MOVEQ.W	#7,D7
JUMP:	ADDA.W	A3,A0
FIN_2:	DS.B	(FIN_2-DEB_2)*199
FIN_V:	RTS
* L'ADRESSE DES 320 OR ET BSET POUR LA ROUTINE HORIZONTALE
TAB320:	DS.L	320
* L'ADRESSE DES 320 BSET POUR LA ROUTINE VERTICALE
TAB200:	DS.L	320
* TABLE DE MULTIPLICATION DE 160
TAB160:	DS.W	200


SPEED_CLEAR1:	CLR.W	D0
	MOVE.W	D0,(A0)
SC_FILL1:	DS.L	(200*20)-1	* $3140 + OFFSET
	RTS

SPEED_CLEAR2:	CLR.W	D0
SC_FILL2:	DS.L	(100*10)	* $3140 + OFFSET
	RTS

;;;;;;;;;;;;;;;;
; section data ;
;;;;;;;;;;;;;;;;

object even
 dc.w -50,-50,0
 dc.w -50,50,0
 dc.w 50,50,0
 dc.w 50,-50,0

new_object even
 ds.w 200

line_data even
 dc.w 0*4,1*4,1*4,2*4,2*4,3*4,3*4,0*4
line_data2

alpha even
 dc.w 0

ecr1 even
 dc.l $1f8000
ecr2
 dc.l $1f0300

clr_buf even
 ds.w 1000
clr_buf2 even

cosinus even
 incbin cosinus.dat


