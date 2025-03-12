	OUTPUT	FIL.PRG
FINAL = 0	;0=CODE FINAL
SPEED=	200
PROF1 = 500*25
PROF2 = 500*50
minimum = 40	;empeche bouclage sur 5 anims
;
	OPT	O+
PLAN3D = 3
PLANSTAR = 0	;0 ET 1
PLANSCROLL = 2
LARGEUR = 320
HAUTEUR = 200
NBSTAR = 80
;
ECRAN1 = $80000-160*200
ECRAN0 = ECRAN1-160*200
;ABS_DRAW = $800

CPU	MACRO
	IFNE	FINAL
	CMP.B	#$F,$FFFFFC02.W
	BNE.S	.\@
	MOVE	#\1,$FFFF8240.W
.\@
	ENDC
	ENDM

	OFFSET	$7E00
ECRAN:	DS.L	1
SYNC:	DS.W	1
OBJET:	DS.W	1
PTROBJET:DS.L	1
CUROBJ:	DS.L	1
NEW:	DS.W	9
BUFFER	DS.L	1
SWAPBUF	DS.L	1
MUL160	DS.W	HAUTEUR
XMIN:	DS.W	1
XMAX:	DS.W	1
YMIN:	DS.W	1
YMAX:	DS.W	1
XMIN2:	DS.W	1
XMAX2:	DS.W	1
YMIN2:	DS.W	1
YMAX2:	DS.W	1
DIST	DS.W	1
ptrmus:	ds.l	1
finmus:	ds.l	1
;
; VARIABLES POUR SCROLLER
;
SHIFT1:	DS.W	1
L5E9A:	DS.W	1
BUFSCR:	DS.L	1
L5EA6:	DS.W	1
LETTRE1:DS.L	1
LETTRE2:DS.L	1
PTRTXT:	DS.L	1
CURTEXT:DS.L	1
;
; VARIABLES 3D
;
WAITING:DS.W	1
PTRANIM:DS.L	1
COEFZOOM:DS.W	1
VITZOOM:DS.W	1
ROTATEX:DS.B	1
ROTATEY:DS.B	1
ROTATEZ:DS.B	1
ROTX	DS.B	1
ROTY	DS.B	1
ROTZ	DS.B	1
	EVEN
	LIST

	NOLIST
	SECTION	TEXT

	MOVE	SR,D0
	AND	#$2000,D0
	BNE.S	SUPER
	CLR.L	-(SP)
	MOVE	#$20,-(SP)
	TRAP	#1
	ADDQ	#6,SP
SUPER:
	MOVE	#$2700,SR

	LEA	ENDDRAW-10,A7		;NOUVEAU POINTEUR DE PILE !!!

	IFNE	FINAL
	MOVEQ	#0,D0
	MOVE.L	D0,A0
	MOVEP.L	D0,$FFFFFA01(A0)
	MOVEP.L	D0,$FFFFFA09(A0)
	MOVEP.L	D0,$FFFFFA11(A0)
	MOVEP.L	D0,$FFFFFA19(A0)
	JSR	DEBUGGER
	ELSEIF
	CLR.B	$FFFFFA07.W		;COUPE INTERRUPTS
	CLR.B	$FFFFFA09.W
	ENDC

	LEA	ECRAN0,A0
	MOVE.L	A0,D0
	LSR	#8,D0
	MOVE.L	D0,$FFFF8200.W
	MOVE	#($80000-ECRAN0)/8-1,D0
	MOVEQ	#0,D1
.BIGCLS:MOVE.L	D1,(A0)+
	MOVE.L	D1,(A0)+
	DBRA	D0,.BIGCLS

	MOVE.L	#VBL2,$70.W
	MOVE	#$2300,SR
	CLR	SYNC.W
.WVBL
	TST	SYNC.W
	BEQ.S	.WVBL
	CLR.B	$FFFF8260.W
	MOVEM.L	PALETTE,D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W	;AFFICHE EN ROUGE

	LEA	MUL160\W,A0
	MOVEQ	#0,D0
	MOVE	#HAUTEUR-1,D1
.MUL160	MOVE	D0,(A0)+
	ADD	#160,D0
	DBRA	D1,.MUL160

	MOVE.L	#ECRAN1,ECRAN\W

	JSR	CALCMUS

	BSR	INITSCROLL

	JSR	INITSTAR

	MOVE	#LARGEUR-1,XMIN.W
	MOVE	#0,XMAX.W
	MOVE	#HAUTEUR-1,YMIN.W
	MOVE	#0,YMAX.W

	MOVE	#LARGEUR-1,XMIN2.W
	MOVE	#0,XMAX2.W
	MOVE	#HAUTEUR-1,YMIN2.W
	MOVE	#0,YMAX2.W

	BSR	INITANIM
BOUCLE
	CLR	SYNC\W

	BSR	ANIME

	IFNE	FINAL
	CLR	D0
	MOVE.B	$FFFFFC02.W,D0
	SUB.B	#$3B,D0
	CMP.B	#10,D0
	BHS.S	.SAME
	MOVE	D0,OBJET\W
.SAME
	ENDC

	MOVE	OBJET\W,D0
	ADD	D0,D0
	ADD	D0,D0
	LEA	ALL_OBJETS,A0
	ADD.L	(A0,D0.W),A0
	MOVE.L	A0,CUROBJ\W

	CPU	$007

	MOVE.L	ECRAN\W,A0
	IFNE	PLAN3D
	ADDQ	#PLAN3D*2,A0
	ENDC
	MOVE.L	A0,USP
	MOVEQ	#0,D0
	LEA	.RET(PC),A1
	JMP	FASTCLS
.RET:
	CPU	$070
	MOVE.L	ECRAN\W,D0	;CHANGE L'ADRESSE ECRAN
	LSR	#8,D0
	MOVE.L	D0,$FFFF8200.W
;
; TRACAGE DES SEGMENTS
;
	BSR	CALCOBJ

	MOVE.L	A2,A0
	LEA	MUL160\W,A1
;	LEA	ABS_DRAW+2\W,A5
	LEA	DRAW_IT+2,A5
	MOVE	#$4ED7,D6		;=JMP (A7)
;
; A2 EST LIBRE !!!!
;
	LEA	INFINI,A2
	JMP	(A0)
RITURN:
	IFNE	FINAL
	CLR	$FFFF8240.W
	ENDC

STMAC	MACRO
	MOVE.L	(A0),A2
	MOVE	(A2)+,D0
	BPL.S	\@
	MOVE.L	NBSTAR*4(A0),A2
	MOVE	(A2)+,D0
\@
	MOVE.L	(A2)+,D1
	OR.L	D1,(A3,D0.W)
	MOVE	D0,(A1)+
	MOVE.L	A2,(A0)+
	ENDM

;AFFICHE_STAR:
	MOVE.L	ECRAN\W,A3
	MOVE.L	BUFFER\W,A1
	MOVEQ	#0,D1
	REPT	NBSTAR
	MOVE	(A1)+,D0
	MOVE.L	D1,(A3,D0.W)
	ENDR

	LEA	PTRS,A0
	LEA	-NBSTAR*2(A1),A1	;A1=BUFFER
	REPT	NBSTAR
	STMAC
	ENDR

	MOVE.L	BUFFER\W,D0
	MOVE.L	SWAPBUF\W,BUFFER\W
	MOVE.L	D0,SWAPBUF\W

	MOVEM.L	XMIN.W,D0/D1
	MOVEM.L	XMIN2.W,D2/D3
	MOVEM.L	D2/D3,XMIN.W
	MOVEM.L	D0/D1,XMIN2.W

	BSR	SCROLLER

	IFNE	FINAL
	TST.B	PAUSE
	BEQ.S	.NOP
	MOVE.L	ECRAN\W,A6
	MOVE	DIST\W,D7
	BSR.S	print
.NOP
	ADD	#65536/4,RALENTI
	BCC.S	.zoom
	cmp.b	#$61,$fffffc02.w
	bne.s	.pazoom			;UNDO
	addq	#1,DIST.W
.pazoom
	cmp.b	#$62,$fffffc02.w
	bne.s	.zoom			;HELP
	subq	#1,DIST.W
.zoom
	MOVE.B	$FFFFFC02.W,D0
	CMP.B	LASTKEY,D0
	BEQ.S	.papause
	MOVE.B	D0,LASTKEY
	cmp.b	#$39,D0
	bne.s	.papause
	NOT.B	PAUSE
.papause
	ENDC

	EOR.L	#ECRAN0^ECRAN1,ECRAN\W

	IFNE	FINAL
	MOVEQ	#-1,D7
.WW2
	ADDQ.L	#1,D7		;8 CYCLES
	TST	SYNC\W		;12 CYCLES
	BEQ.S	.WW2		;12 CYCLES

	CMP.L	MINIMUM,D7
	BHS.S	.NOTMIN
	MOVE.L	D7,MINIMUM
.NOTMIN
	CMP.L	MAXIMUM,D7
	BLS.S	.NOTMAX
	MOVE.L	D7,MAXIMUM
.NOTMAX
	BRA	BOUCLE
MINIMUM:DC.L	-1	;NB CYCLES LIBRES
MAXIMUM:DC.L	0
	ELSEIF
.WW2
	TST	SYNC\W		;12 CYCLES
	BEQ.S	.WW2		;12 CYCLES
	CMP.B	#$39,$FFFFFC02.W
	BNE	BOUCLE
	CLR	-(SP)
	TRAP	#1
	ENDC

	IFNE	FINAL
PAUSE:	DC.B	0
LASTKEY:DC.B	0
RALENTI:DC.W	0
print:
	bsr.w	digit
	bsr.w	digit
	bsr.w	digit
digit:
	rol	#4,d7
	moveq	#$f,d0
	and	d7,d0
	asl	#3,d0
	lea	fonte,a0
	add	d0,a0
x	set	6
	rept	8
	move.b	(a0)+,x(a6)
x	set	x+160
	endr
	addq	#1,a6
	move	a6,d0
	lsr	#1,d0
	bcs.s	.pair
	addq	#6,a6
.pair	rts
	ENDC

VBL:
	MOVEM.L	A0-A2,-(SP)
;
; PLAY MUSIQUE
;
	move.l	ptrmus\w,a0
	lea	$ffff8800.w,a1
	lea	$ffff8802.w,a2
x	set	0
	rept	11
	move.b	#x,(a1)
	move.b	(a0)+,(a2)
x	set	x+1
	endr
	TST.b	(a0)+
	beq.s	1$
	MOVE.B	#$B,(a1)
	move.b	-1(a0),(a2)
	move.l	#$0C0C0000,(a1)
	move.l	#$0D0D0A0A,(a1)
1$
	cmp.l	finmus.w,a0
	blo.s	2$
	lea	startmus,a0
2$	move.l	a0,ptrmus\w

	MOVEM.L	(SP)+,A0-A2
VBL2:
	ADDQ	#1,SYNC\W
	RTE
CALCOBJ:
;
; CALCUL OPTIMISE DES POINTS PROJETES
;
NXTANG	MACRO
	CLR	D0
	MOVE.B	\1.W,D0		;ROT
	ADD.B	\2.W,D0
	MOVE.B	D0,\2.W
	ADD	D0,D0
	ADD	D0,D0
	MOVEM	(A0,D0.W),\3
	ENDM
;
; CALCUL DE LA MATRICE CONSTANTE DE PROJECTION
;
; CHANGE L'ANGLE DE ROTATION ET CALCULE LES SINUS ET COSINUS ASSOCIES
;
; SX=SIN/COS ANGLE X,SY=SIN/COS ANGLE Y,SZ=SIN/COS ANGLE Z
; L14=ANGLE ROT X,L16=ANGLE ROT Y,L3C=ANGLE ROT Z
; ROTX,ROTY,ROTZ=ANGLES COURANTS
;
SX	EQUR	D2
CX	EQUR	D3
SY	EQUR	D4
CY	EQUR	D5
SZ	EQUR	D6
CZ	EQUR	D7

;
; CHANGEMENT D'ANGLE DE ROTATION
;   (CONSTANTES POUR L'INSTANT)
;
	LEA	SINCOS(PC),A0
	NXTANG	ROTATEX,ROTX,SX/CX	;SX
	NXTANG	ROTATEY,ROTY,SY/CY	;SY
	NXTANG	ROTATEZ,ROTZ,SZ/CZ	;SZ
;
; CALCULE LA MATRICE DE PROJECTION
;
	LEA	NEW\W,A0

	MOVE	CY,D0
	MULS	CZ,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVE	D0,(A0)+

	MOVE	SY,(A0)+

	MOVE	CY,D0
	MULS	SZ,D0
	ADD.L	D0,D0
	SWAP	D0
	NEG	D0
	MOVE	D0,(A0)+

	MOVE	SX,D1
	MULS	SZ,D1
	MOVE	CX,D0
	MULS	SY,D0
	ADD.L	D0,D0
	SWAP	D0
	MULS	CZ,D0
	SUB.L	D0,D1
	ADD.L	D1,D1
	SWAP	D1
	MOVE	D1,(A0)+

	MOVE	CX,D0
	MULS	CY,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVE	D0,(A0)+	;$10

	MOVE	SX,D1
	MULS	CZ,D1
	MOVE	CX,D0
	MULS	SY,D0
	ADD.L	D0,D0
	SWAP	D0
	MULS	SZ,D0
	ADD.L	D1,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVE	D0,(A0)+	;$14

	MOVE	CX,D1
	MULS	SZ,D1
	MOVE	SX,D0
	MULS	SY,D0
	ADD.L	D0,D0
	SWAP	D0
	MULS	CZ,D0
	ADD.L	D1,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVE	D0,(A0)+	;$18

	MOVE	SX,D0
	MULS	CY,D0
	ADD.L	D0,D0
	SWAP	D0
	NEG	D0
	MOVE	D0,(A0)+	;$1C

	MOVE	CX,D1
	MULS	CZ,D1
	MOVE	SX,D0
	MULS	SY,D0
	ADD.L	D0,D0
	SWAP	D0
	MULS	SZ,D0
	SUB.L	D0,D1
	ADD.L	D1,D1
	SWAP	D1
	MOVE	D1,(A0)+	;$20

	LEA	INFINI,A1
	MOVE.L	CUROBJ\W,A2
	MOVE	(A2)+,D4
	LEA	NEW\W,A6
;
; REGISTRES UTILISES :
;	A0-A6 SAUF A1
;	A2 PEUT ETRE LIBERE
;
; 	D1-D7 SAUF D4
;
; registres libres :
;
;	A1,D0,D4
;
; REGISTRES UTILISES
;
; A6,A4,A2,A1
; D1,D2,D3,D6,D0,D7,D4
;
; D5/A0/A3/A5
;
RXMIN	EQUR	D5
RXMAX	EQUR	A0
RYMIN	EQUR	A3
RYMAX	EQUR	A5

	MOVE	#LARGEUR-1,RXMIN
	MOVE	#0,RXMAX
	MOVE	#HAUTEUR-1,RYMIN
	MOVE	#0,RYMAX
BCPTS:
	MOVE.L	A6,A4
	MOVEM	(A2)+,D1/D2/D3

	MOVE	D1,D6		;X
	MULS	(A4)+,D6
	MOVE	D2,D0
	MULS	(A4)+,D0
	ADD.L	D0,D6
	MOVE	D3,D0
	MULS	(A4)+,D0
	ADD.L	D0,D6

	MOVE	D1,D7		;Y
	MULS	(A4)+,D7
	MOVE	D2,D0
	MULS	(A4)+,D0
	ADD.L	D0,D7
	MOVE	D3,D0
	MULS	(A4)+,D0
	ADD.L	D0,D7

	MULS	(A4)+,D1	;Z
	MULS	(A4)+,D2
	ADD.L	D2,D1
	MULS	(A4)+,D3
	ADD.L	D3,D1

	SWAP	D1
	SUB	DIST\W,D1

	ASR.L	#8,D6
	ASR.L	#8,D7
	DIVS	D1,D6
	DIVS	D1,D7

	ADD	#LARGEUR/2,D6
	ADD	#HAUTEUR/2,D7

	IFNE	FINAL
	CMP	#LARGEUR,D6
	BLO.S	.1
	SGE	D6
	EXT	D6
	AND	#LARGEUR-1,D6
	ADDQ	#7,$FFFF8240.W
.1
	ENDC

	MOVE	D6,(A1)+
	MOVE	D7,(A1)+

	CMP	RXMIN,D6
	BGE.S	.NOX1
	MOVE	D6,RXMIN
.NOX1
	CMP	RXMAX,D6
	BLE.S	.NOX2
	MOVE	D6,RXMAX
.NOX2
	CMP	RYMIN,D7
	BGE.S	.NOX3
	MOVE	D7,RYMIN
.NOX3
	CMP	RYMAX,D7
	BLE.S	.NOX4
	MOVE	D7,RYMAX
.NOX4
	DBRA	D4,BCPTS
;	MOVE	RXMIN,XMIN.W
;	MOVE	RXMAX,XMAX.W
;	MOVE	RYMIN,YMIN.W
;	MOVE	RYMAX,YMAX.W
	MOVEM	RXMIN/RXMAX/RYMIN/RYMAX,XMIN.W
	RTS
SINCOS		;TABLE DE SINUS/COSINUS
	dc.w	$0,$7FFF,$324,$7FF5,$647,$7FD7,$96A,$7FA6
	dc.w	$C8B,$7F61,$FAB,$7F08,$12C7,$7E9C,$15E1,$7E1C
	dc.w	$18F8,$7D89,$1C0B,$7CE2,$1F19,$7C29,$2223,$7B5C
	dc.w	$2527,$7A7C,$2826,$7989,$2B1E,$7883,$2E10,$776B
	dc.w	$30FB,$7640,$33DE,$7503,$36B9,$73B5,$398C,$7254
	dc.w	$3C56,$70E1,$3F16,$6F5E,$41CD,$6DC9,$447A,$6C23
	dc.w	$471C,$6A6C,$49B3,$68A5,$4C3F,$66CE,$4EBF,$64E7
	dc.w	$5133,$62F1,$539A,$60EB,$55F4,$5ED6,$5842,$5CB3
	dc.w	$5A81,$5A81,$5CB3,$5842,$5ED6,$55F4,$60EB,$539A
	dc.w	$62F1,$5133,$64E7,$4EBF,$66CE,$4C3F,$68A5,$49B3
	dc.w	$6A6C,$471C,$6C23,$447A,$6DC9,$41CD,$6F5E,$3F16
	dc.w	$70E1,$3C56,$7254,$398C,$73B5,$36B9,$7503,$33DE
	dc.w	$7640,$30FB,$776B,$2E10,$7883,$2B1E,$7989,$2826
	dc.w	$7A7C,$2527,$7B5C,$2223,$7C29,$1F19,$7CE2,$1C0B
	dc.w	$7D89,$18F8,$7E1C,$15E1,$7E9C,$12C7,$7F08,$FAB
	dc.w	$7F61,$C8B,$7FA6,$96A,$7FD7,$647,$7FF5,$324
	dc.w	$7FFF,$0,$7FF5,$FCDB,$7FD7,$F9B8,$7FA6,$F695
	dc.w	$7F61,$F374,$7F08,$F054,$7E9C,$ED38,$7E1C,$EA1E
	dc.w	$7D89,$E707,$7CE2,$E3F4,$7C29,$E0E6,$7B5C,$DDDC
	dc.w	$7A7C,$DAD8,$7989,$D7D9,$7883,$D4E1,$776B,$D1EF
	dc.w	$7640,$CF04,$7503,$CC21,$73B5,$C946,$7254,$C673
	dc.w	$70E1,$C3A9,$6F5E,$C0E9,$6DC9,$BE32,$6C23,$BB85
	dc.w	$6A6C,$B8E3,$68A5,$B64C,$66CE,$B3C0,$64E7,$B140
	dc.w	$62F1,$AECC,$60EB,$AC65,$5ED6,$AA0B,$5CB3,$A7BD
	dc.w	$5A81,$A57E,$5842,$A34C,$55F4,$A129,$539A,$9F14
	dc.w	$5133,$9D0E,$4EBF,$9B18,$4C3F,$9931,$49B3,$975A
	dc.w	$471C,$9593,$447A,$93DC,$41CD,$9236,$3F16,$90A1
	dc.w	$3C56,$8F1E,$398C,$8DAB,$36B9,$8C4A,$33DE,$8AFC
	dc.w	$30FB,$89BF,$2E10,$8894,$2B1E,$877C,$2826,$8676
	dc.w	$2527,$8583,$2223,$84A3,$1F19,$83D6,$1C0B,$831D
	dc.w	$18F8,$8276,$15E1,$81E3,$12C7,$8163,$FAB,$80F7
	dc.w	$C8B,$809E,$96A,$8059,$647,$8028,$324,$800A
	dc.w	$0,$8001,$FCDB,$800A,$F9B8,$8028,$F695,$8059
	dc.w	$F374,$809E,$F054,$80F7,$ED38,$8163,$EA1E,$81E3
	dc.w	$E707,$8276,$E3F4,$831D,$E0E6,$83D6,$DDDC,$84A3
	dc.w	$DAD8,$8583,$D7D9,$8676,$D4E1,$877C,$D1EF,$8894
	dc.w	$CF04,$89BF,$CC21,$8AFC,$C946,$8C4A,$C673,$8DAB
	dc.w	$C3A9,$8F1E,$C0E9,$90A1,$BE32,$9236,$BB85,$93DC
	dc.w	$B8E3,$9593,$B64C,$975A,$B3C0,$9931,$B140,$9B18
	dc.w	$AECC,$9D0E,$AC65,$9F14,$AA0B,$A129,$A7BD,$A34C
	dc.w	$A57E,$A57E,$A34C,$A7BD,$A129,$AA0B,$9F14,$AC65
	dc.w	$9D0E,$AECC,$9B18,$B140,$9931,$B3C0,$975A,$B64C
	dc.w	$9593,$B8E3,$93DC,$BB85,$9236,$BE32,$90A1,$C0E9
	dc.w	$8F1E,$C3A9,$8DAB,$C673,$8C4A,$C946,$8AFC,$CC21
	dc.w	$89BF,$CF04,$8894,$D1EF,$877C,$D4E1,$8676,$D7D9
	dc.w	$8583,$DAD8,$84A3,$DDDC,$83D6,$E0E6,$831D,$E3F4
	dc.w	$8276,$E707,$81E3,$EA1E,$8163,$ED38,$80F7,$F054
	dc.w	$809E,$F374,$8059,$F695,$8028,$F9B8,$800A,$FCDB
	dc.w	$8001,$FFFF,$800A,$324,$8028,$647,$8059,$96A
	dc.w	$809E,$C8B,$80F7,$FAB,$8163,$12C7,$81E3,$15E1
	dc.w	$8276,$18F8,$831D,$1C0B,$83D6,$1F19,$84A3,$2223
	dc.w	$8583,$2527,$8676,$2826,$877C,$2B1E,$8894,$2E10
	dc.w	$89BF,$30FB,$8AFC,$33DE,$8C4A,$36B9,$8DAB,$398C
	dc.w	$8F1E,$3C56,$90A1,$3F16,$9236,$41CD,$93DC,$447A
	dc.w	$9593,$471C,$975A,$49B3,$9931,$4C3F,$9B18,$4EBF
	dc.w	$9D0E,$5133,$9F14,$539A,$A129,$55F4,$A34C,$5842
	dc.w	$A57E,$5A81,$A7BD,$5CB3,$AA0B,$5ED6,$AC65,$60EB
	dc.w	$AECC,$62F1,$B140,$64E7,$B3C0,$66CE,$B64C,$68A5
	dc.w	$B8E3,$6A6C,$BB85,$6C23,$BE32,$6DC9,$C0E9,$6F5E
	dc.w	$C3A9,$70E1,$C673,$7254,$C946,$73B5,$CC21,$7503
	dc.w	$CF04,$7640,$D1EF,$776B,$D4E1,$7883,$D7D9,$7989
	dc.w	$DAD8,$7A7C,$DDDC,$7B5C,$E0E6,$7C29,$E3F4,$7CE2
	dc.w	$E707,$7D89,$EA1E,$7E1C,$ED38,$7E9C,$F054,$7F08
	dc.w	$F374,$7F61,$F695,$7FA6,$F9B8,$7FD7,$FCDB,$7FF5


;
; GESTION DE L'ANIMATION
;
INITANIM
	CLR	WAITING\W
	MOVE.L	#STARTANIM,PTRANIM\W
	CLR	COEFZOOM\W
	CLR	VITZOOM\W
	MOVE	#256,DIST\W
	CLR	OBJET\W
	RTS
ANIME:
	TST	WAITING\W
	BEQ.S	.CHANGE
	IFNE	FINAL
	TST.B	PAUSE
	BNE.S	.NODEC
	ENDC
	SUBQ	#1,WAITING\W
.NODEC
	MOVE	VITZOOM\W,D0
	BEQ.S	.RTS
	BPL.S	.POSIT

	ADD	DIST\W,D0
	CMP	COEFZOOM\W,D0
	BGE.S	.SUP
	MOVE	COEFZOOM\W,D0
	CLR	WAITING\W
	CLR	VITZOOM\W
.SUP
	MOVE	D0,DIST\W
.RTS	RTS
.POSIT
	ADD	DIST\W,D0
	CMP	COEFZOOM\W,D0
	BLE.S	.SUP2
	MOVE	COEFZOOM\W,D0
	CLR	WAITING\W
	CLR	VITZOOM\W
.SUP2
	MOVE	D0,DIST\W
	RTS
.CHANGE
	MOVE.L	PTRANIM\W,A6
.NEWANIM
	MOVE	(A6)+,D0
	JMP	.ANIMS(PC,D0.W)
.ANIMS
	BRA.W	.RESTART	;0=RESTART
	BRA.W	.INITOBJ	;1=APPARITION OBJET
	BRA.W	.ZOOM		;2=CHANGE ZOOMING
	BRA.W	.ROTATE		;3=CHANGE ROTATIONS
	BRA.W	.WAIT		;4=WAIT
.RESTART
	LEA	STARTANIM,A6
	BRA.S	.NEWANIM
.INITOBJ
	MOVE	(A6)+,OBJET\W
	BRA.S	.NEWANIM
.ZOOM	MOVE	(A6)+,COEFZOOM\W
	MOVE	(A6)+,VITZOOM\W
	MOVE	#-1,WAITING\W
	MOVE.L	A6,PTRANIM\W
	RTS
.ROTATE
	MOVE.B	(A6)+,ROTATEX\W
	MOVE.B	(A6)+,ROTATEY\W
	MOVE.B	(A6)+,ROTATEZ\W
	CLR.B	ROTX.W
	CLR.B	ROTY.W
	CLR.B	ROTZ.W
	ADDQ	#1,A6
	BRA.S	.NEWANIM
.WAIT
	MOVE	(A6)+,WAITING\W
	MOVE.L	A6,PTRANIM\W
	RTS

OBJECT	MACRO
	DC.W	1*4,\1
	ENDM
ZOOM	MACRO
	DC.W	2*4,\1,\2
	ENDM
ROT	MACRO
	DC.W	3*4
	DC.B	\1,\2,\3,0
	ENDM
ROT0	MACRO
	DC.W	3*4
	DC.B	1,3,2,0
	ENDM
WAIT	MACRO
	DC.W	4*4,\1
	ENDM
MINZOOM = 450
STARTANIM
	OBJECT	0		;CUBE
	ROT0
	ZOOM	$6E,-2		;ZOOM AVANT
	WAIT	400
	ZOOM	MINZOOM,+2	;ZOOM ARRIERE

	OBJECT	1		;DISK
	ROT0
	ZOOM	$53,-2		;ZOOM AVANT
	WAIT	400
	ZOOM	MINZOOM,+2	;ZOOM ARRIERE

	OBJECT	2		;VAISSEAU 1
	ROT0
	ZOOM	$53,-2		;ZOOM AVANT
	WAIT	400
	ZOOM	MINZOOM,+2	;ZOOM ARRIERE

	OBJECT	3		;VAISSEAU 2
	ROT0
	ZOOM	$80,-2		;ZOOM AVANT
	WAIT	400
	ZOOM	MINZOOM,+2	;ZOOM ARRIERE

	OBJECT	4		;VAISSEAU 3
	ROT0
	ZOOM	$4F,-2		;ZOOM AVANT
	WAIT	400
	ZOOM	MINZOOM,+2	;ZOOM ARRIERE

	OBJECT	5		;VOYAGER
	ROT0
	ZOOM	$63,-2		;ZOOM AVANT
	WAIT	400
	ZOOM	MINZOOM,+2	;ZOOM ARRIERE

	OBJECT	6		;HORLOGE
	ROT0
	ZOOM	$8E,-2		;ZOOM AVANT
	WAIT	400
	ZOOM	MINZOOM,+2	;ZOOM ARRIERE

	OBJECT	7		;POELE
	ROT0
	ZOOM	$86,-2		;ZOOM AVANT
	WAIT	400
	ZOOM	MINZOOM,+2	;ZOOM ARRIERE

	OBJECT	8		;MONDE
	ROT0
	ZOOM	$C3,-2		;ZOOM AVANT
	WAIT	400
	ZOOM	MINZOOM,+2	;ZOOM ARRIERE

	OBJECT	9		;FRANCE
	ROT0
	ZOOM	$A2,-2		;ZOOM AVANT
	WAIT	400
	ZOOM	MINZOOM,+2	;ZOOM ARRIERE

	OBJECT	10		;VAISSEAU 4
	ROT0
	ZOOM	$D0,-2		;ZOOM AVANT
	WAIT	400
	ZOOM	MINZOOM,+2	;ZOOM ARRIERE

	OBJECT	11		;ASSIETTE
	ROT0
	ZOOM	$9A,-2		;ZOOM AVANT
	WAIT	400
	ZOOM	MINZOOM,+2	;ZOOM ARRIERE

	OBJECT	12		;TINTIN
	ROT0
	ZOOM	$7C,-2		;ZOOM AVANT
	WAIT	400
	ZOOM	MINZOOM,+2	;ZOOM ARRIERE

	OBJECT	13		;MAISON
	ROT	3,2,1
	ZOOM	$8B,-2		;ZOOM AVANT
	WAIT	400
	ZOOM	MINZOOM,+2	;ZOOM ARRIERE

	OBJECT	14		;CUBE+OCTOGONE
	ROT0
	ZOOM	$C0,-2		;ZOOM AVANT
	WAIT	400
	ZOOM	MINZOOM,+2	;ZOOM ARRIERE

	OBJECT	15		;VILLE
	ROT	0,0,-2
	ZOOM	$80,-2		;ZOOM AVANT
	WAIT	400
	ZOOM	MINZOOM,+2	;ZOOM ARRIERE

	OBJECT	16		;SALLE A MANGER
	ROT	0,2,2
	ZOOM	$B8,-2		;ZOOM AVANT
	WAIT	400
	ZOOM	MINZOOM,+2	;ZOOM ARRIERE

	OBJECT	17		;DISQUETTE
	ROT0
	ZOOM	$108,-2		;ZOOM AVANT
	WAIT	400
	ZOOM	MINZOOM,+2	;ZOOM ARRIERE

	OBJECT	18		;MAIN
	ROT0
	ZOOM	$7F,-2		;ZOOM AVANT
	WAIT	400
	ZOOM	MINZOOM,+2	;ZOOM ARRIERE
	DC.W	0
;
; replay COSO
;
; ce qu'il faut rajouter :
;	compteur de notes (permet de calculer la longueur des musiques)
;	cf count
;	calculer fin des musiques … sauver (cf L930)
;	cf endvoice
;	TFMX->COSO
;
; ‚diteur :
;	MadMax n'utilise pas les fonctions de vibrato de Whittaker
;	 ni sa batterie !!!
;
; optimisations en minuscules
; … faire :
;
; a2->a1
;
CALCMUS:
	LEA	MUSLOAD,A0
	moveq	#1,d0
	bsr.s	initmus

	move.l	#startmus,finmus.w
	move.l	#startmus,ptrmus.w
PUSHMUS:
	clr	voicefin
	clr.b	flagmus
;	addq	#1,$ffff8240.w
	BSR	PLAYMUS
	tst	voicefin
	bne.s	finito
	move.l	finmus.w,a0
	moveq	#11-1,d0
.1	move.b	2(a6),(a0)+
	addq	#4,a6
	dbra	d0,.1
	move.b	flagmus,(a0)+
	move.l	a0,finmus.w
	MOVE.L	#VBL,$70.W
	bra.s	PUSHMUS
finito:
	rts
voicefin:dc.w	0
flagmus:dc.w	0

off22 = 0	;rs.l	1	;ptr courant dans pattern
off0 = 4	;rs.l	1	;ptr base patterns
off34 = 8	;rs.l	1	;ptr fin musique

off4 = 12	;rs.w	1	;ptr patterns (.W au lieu de .L)
offa = 14	;rs.l	1	;ptr base modulation volume
offe = 18	;rs.w	1	;ptr modulation volume (.W au lieu de .L)
off12 = 20	;rs.l	1	;ptr base modulation fr‚quence
off30 = 24	;rs.w	1	;ptr modulation fr‚quence (.W au lieu de .L)

off38 = 26	;rs.l	1	;incr‚ment pour crescendo

off8 = 30	;rs.b	1
off9 = 31	;rs.b	1

off16 = 32	;rs.b	1
off17 = 33	;rs.b	1
off18 = 34	;rs.b	1
off19 = 35	;rs.b	1
off1a = 36	;rs.b	1
off1b = 37	;rs.b	1
off1c = 38	;rs.b	1
off1d = 39	;rs.b	1
off1e = 40	;rs.b	1
off1f = 41	;rs.b	1
off21 = 42	;rs.b	1

off26 = 43	;rs.b	1
off27 = 44	;rs.b	1
off28 = 45	;rs.b	1	;15-volume sonore de la voix
off2a = 46	;rs.b	1	;0,1 ou 2 = type de son
off2b = 47	;rs.b	1
off2c = 48	;rs.b	1
off2d = 49	;rs.b	1	;volume sonore calcul‚
off2e = 50	;rs.b	1
off3c = 52	;equ	(__RS+1)&-2
;
; init musique
;
; entr‚e :
;	A0=pointe sur le texte 'COSO'
;	D0=num‚ro de la musique … jouer
;
initmus:
	TST	D0		;musique=0 -> cut mus
	BEQ	LCA
	subq	#1,d0

	LEA	PSGREG(PC),A6
	MOVE.L	A0,L934-PSGREG(A6)
	MOVE.L	4(A0),A1
	ADD.L	A0,A1
	MOVE.L	A1,L938-PSGREG(A6)
	MOVE.L	8(A0),A1
	ADD.L	A0,A1
	MOVE.L	A1,L93C-PSGREG(A6)
	MOVE.L	$C(A0),A1
	ADD.L	A0,A1
	MOVE.L	A1,L91A-PSGREG(A6)
	MOVE.L	$10(A0),A1
	ADD.L	A0,A1
	MOVE.L	A1,L916-PSGREG(A6)
	MOVE.L	$14(A0),A1
	ADD.L	A0,A1
	ADD	D0,D0
	MOVE	D0,D1
	ADD	D0,D0
	ADD	D1,D0
	ADD	D0,A1
	MOVEQ	#$C,D7
	MULU	(A1)+,D7	;PREMIER PATTERN
	MOVE	(A1)+,D6
	ADDQ	#1,D6
	MULU	#$C,D6		;DERNIER PATTERN
	MOVE	(A1)+,D0
	IFNE	FINAL
	bne.s	notfin
	illegal
notfin:
	ENDC
	MOVE.B	D0,L810-PSGREG(A6)

	MOVEQ	#0,D0
	LEA	voice0(PC),A0
	LEA	L7C6(PC),A1
L658:	MOVE.L	A1,offa(a0)
	clr	offe(a0)
	CLR.B	off2d(A0)
	CLR.B	off8(a0)
	CLR.B	off9(a0)
	MOVE.L	A1,off12(A0)
	clr	off30(a0)
	MOVE.B	#1,off17(A0)
	MOVE.B	#1,off18(A0)
	CLR.B	off19(A0)
	clr.b	off1a(a0)
	clr.b	off1b(a0)
	clr.b	off1c(a0)
	clr.b	off1d(a0)
	clr.b	off1e(A0)
	clr.b	off1f(a0)
	move.l	d0,d3
	MOVE.B	d3,off21(A0)
	ADD	D3,D3
	ADD	D3,D3
	MOVE.L	L916(PC),d1
	add.l	D7,d1
	add.l	D3,d1
	move.l	d1,off0(A0)
	move.l	d1,a3
	MOVE.L	L916(PC),d1
	add.l	d6,d1
	add.l	d3,d1
	move.l	d1,off34(A0)
	move	#$C,off4(a0)
	moveq	#0,d1
	move.b	(A3)+,D1
	ADD	D1,D1
	MOVE.L	L91A(PC),A4
	MOVE	(A4,D1.W),A4
	ADD.L	L934(PC),A4
	MOVE.L	A4,off22(A0)
	clr.b	off26(A0)
	clr.b	off27(A0)
	MOVE.B	#2,off2a(A0)
	move.b	(A3)+,off2c(A0)
	CLR.B	off2b(A0)
	move.b	(A3)+,off16(A0)
	moveq	#$10,d1
	add.B	(A3),D1
	bcs.s	L712
	moveq	#0,d1
L712:
	MOVE.B	D1,off28(A0)
	CLR.L	off38(A0)
	lea	off3c(a0),A0
	addq	#1,d0
	cmp	#3,d0
	blo	L658
	MOVE.B	#1,L80E-PSGREG(A6)
	CLR	L812-PSGREG(A6)

	clr.B	$22(A6)
	clr.B	$26(A6)
	clr.B	$2A(A6)
	MOVEM.L	$1C(A6),D0-D3
	MOVEM.L	D0-D3,$FFFF8800.W
	RTS
LCA:	LEA	L812(PC),A0
	ST	(A0)
;	BRA	L12C
PLAYMUS:
L12C:
	LEA	PSGREG(PC),A6
	TST.B	L812-PSGREG(A6)
	BEQ.S	L160
	TAS	L813-PSGREG(A6)
	BNE.S	L15E
	clr.B	$22(A6)
	clr.B	$26(A6)
	clr.B	$2A(A6)
	move	#3,voicefin
;	MOVEM.L	$1C(A6),D0-D3
;	MOVEM.L	D0-D3,$FFFF8800.W
L15E:	RTS
L160:	SUBQ.B	#1,L80E-PSGREG(A6)
	BNE.S	L180
	MOVE.B	L810-PSGREG(A6),L80E-PSGREG(A6)
	MOVEQ	#0,D5
	LEA	voice0(PC),A0
	BSR.s	L25C
	LEA	voice1(PC),A0
	BSR.s	L25C
	LEA	voice2(PC),A0
	BSR.s	L25C
L180:	move.b	#$C0,$1E(A6)
	LEA	voice0(PC),A0
	BSR	L39A
	move	d0,6(A6)
	MOVE.B	D0,2(A6)
	MOVE.B	D1,$22(A6)
	LEA	voice1(PC),A0
	BSR	L39A
	move	d0,$E(A6)
	MOVE.B	D0,$A(A6)
	MOVE.B	D1,$26(A6)
	LEA	voice2(PC),A0
	BSR	L39A
	move	d0,$16(A6)
	MOVE.B	D0,$12(A6)
	MOVE.B	D1,$2A(A6)

;	MOVEM.L	(A6),D0-D7/A0-A2
;	MOVEM.L	D0-D7/A0-A2,$FFFF8800.W
L25A:	RTS
;
; calcule nouvelle note
;
L25C:	SUBQ.B	#1,off26(A0)
	BPL.S	L25A
	MOVE.B	off27(A0),off26(A0)
	MOVE.L	off22(A0),A1
L26C:	MOVE.B	(A1)+,D0
	CMP.B	#$FF,D0
	BNE.S	L2E2
	MOVE.L	off0(a0),a1
	add	off4(a0),a1
	cmp.l	off34(a0),a1
	blo.S	L288
	addq	#1,voicefin
	move	d5,off4(a0)
	MOVE.L	off0(a0),a1
L288:	MOVEQ	#0,D1
	move.b	(a1)+,D1
	move.b	(a1)+,off2c(A0)
	move.b	(a1)+,off16(A0)
	moveq	#$10,d0
	add.b	(a1)+,D0
	bcc.s	L2B4
	move.b	d0,off28(A0)		;F0-FF=volume … soustraire
	BRA.S	L2C4
L2B4:	add.b	#$10,d0
	bcc.S	L2C4
	move.B	d0,L810-PSGREG(A6)	;E0-EF=vitesse
L2C4:	ADD	D1,D1
	MOVE.L	L91A(PC),A1
	MOVE	(A1,D1.W),A1
	ADD.L	L934(PC),A1
	MOVE.L	A1,off22(A0)
	add	#$C,off4(a0)
	BRA.s	L26C
L2E2:	CMP.B	#$FE,D0
	BNE.S	L2F4
	MOVE.B	(A1)+,d0
	move.b	d0,off27(A0)
	MOVE.B	d0,off26(A0)
	BRA.s	L26C
L2F4:	CMP.B	#$FD,D0
	BNE.S	L308
	MOVE.B	(A1)+,d0
	move.b	d0,off27(A0)
	MOVE.B	d0,off26(A0)
	MOVE.L	A1,off22(A0)
	RTS
L308:	MOVE.B	D0,off8(a0)
	MOVE.B	(A1)+,D1
	MOVE.B	D1,off9(a0)
	AND	#$E0,D1			;d1=off9&$E0
	BEQ.S	L31C
	MOVE.B	(A1)+,off1f(A0)
L31C:	MOVE.L	A1,off22(A0)
	MOVE.L	D5,off38(A0)
	TST.B	D0
	BMI.S	L398
	MOVE.B	off9(a0),D0
	eor.b	d0,d1			;d1=off9&$1F
	ADD.B	off16(A0),D1

	MOVE.L	L93C(PC),a1
	ADD	D1,D1
	MOVE	(a1,D1.W),a1
	ADD.L	L934(PC),a1
	move	d5,offe(A0)
	MOVE.B	(a1)+,d1
	move.b	d1,off17(A0)
	MOVE.B	d1,off18(A0)
	MOVEQ	#0,D1
	MOVE.B	(a1)+,D1
	MOVE.B	(a1)+,off1b(A0)
;	MOVE.B	#$40,off2e(A0)
	clr.b	off2e(a0)
	MOVE.B	(a1)+,D2
	MOVE.B	D2,off1c(A0)
	MOVE.B	D2,off1d(A0)
	MOVE.B	(a1)+,off1e(A0)
	MOVE.L	a1,offa(A0)
	add.b	d0,d0			;test bit 6
	bpl.s	L37A
	MOVE.B	off1f(A0),D1
L37A:	MOVE.L	L938(PC),a1
	ADD	D1,D1
	MOVE	(a1,D1.W),a1
	ADD.L	L934(PC),a1
	MOVE.L	a1,off12(A0)
	move	d5,off30(A0)
	MOVE.B	D5,off1a(A0)
	MOVE.B	D5,off19(A0)
L398:	RTS
;
; calcul de la note … jouer
;
L39A:	MOVEQ	#0,D7
	MOVE	off30(a0),d6
L3A0:	TST.B	off1a(A0)
	BEQ.S	L3AE
	SUBQ.B	#1,off1a(A0)
	BRA	L4C01
L3AE:	MOVE.L	off12(A0),A1
	add	d6,a1
L3B6:	move.b	(a1)+,d0
	cmp.b	#$E1,d0
	BEQ	L4C01
	cmp.b	#$E0,d0
	BNE.S	L3D8
	moveq	#$3f,d6
	and.B	(A1),D6
	MOVE.L	off12(A0),A1
	add	d6,A1
	move.b	(a1)+,d0
L3D8:	cmp.b	#$E2,d0
	BNE.S	L3EE
	clr	offe(a0)
	MOVE.B	#1,off17(A0)
	addq	#1,d6
	bra.s	L3B6
L3EE:	cmp.b	#$E9,d0
	BNE.s	L422
;	MOVE.B	#$B,$FFFF8800.W
;	move.b	(A1)+,$FFFF8802.W
;	move.l	#$0C0C0000,$FFFF8800.W
;	move.l	#$0D0D0A0A,$FFFF8800.W
	move.b	(a1)+,flagmus
	addq	#2,d6
	bra.s	L3B6
L422:	cmp.b	#$E7,d0
	BNE.S	L44A
	clr	d0
	move.b	(A1),D0
	ADD	D0,D0
	MOVE.L	L938(PC),A1
	MOVE	(A1,D0.W),A1
	ADD.L	L934(PC),A1
	MOVE.L	A1,off12(A0)
	clr	d6
	BRA.s	L3B6
L44A:	cmp.b	#$E8,d0
	BNE.S	L45E
	move.b	(A1)+,off1a(A0)
	addq	#2,d6
	BRA	L3A0
L45E:	cmp.b	#$E4,d0
	BNE.S	L474
	clr.b	off2a(A0)
	MOVE.B	(A1)+,d7
	addq	#2,d6
	BRA.S	L4AE
L474:	cmp.b	#$E5,d0
	BNE.S	L488
	MOVE.B	#1,off2a(A0)
	addq	#1,d6
	BRA	L3B6
L488:	cmp.b	#$E6,d0
	BNE.S	L49A
	MOVE.B	#2,off2a(A0)
	addq	#1,d6
	BRA.S	L4AE
L49A:	cmp.b	#$E3,d0
	BNE.S	L4B0
	addq	#3,d6
	move.b	(A1)+,off1b(A0)
	move.b	(A1)+,off1c(A0)
L4AE:	move.b	(a1)+,d0
L4B0:
	MOVE.B	d0,off2b(A0)
	addq	#1,d6
L4C01:	move	d6,off30(a0)
;
; modulation volume
;
	move	offe(a0),d6
L4C0:	TST.B	off19(A0)
	BEQ.S	L4CC
	SUBQ.B	#1,off19(A0)
	BRA.S	L51A
L4CC:	SUBQ.B	#1,off17(A0)
	BNE.S	L51A
	MOVE.B	off18(A0),off17(A0)

	MOVE.L	offa(A0),A1
	add	d6,a1
	move.b	(A1)+,D0
	CMP.B	#$E0,D0
	BNE.S	L512
	moveq	#$3f,d6
	and.b	(A1),D6
	subq	#5,D6
	move.l	offa(a0),a1
	add	d6,a1
	move.b	(a1)+,d0
L512:
	CMP.B	#$E8,D0
	BNE.S	L4F4
	addq	#2,d6
	move.b	(A1)+,off19(A0)
	BRA.S	L4C0
L4F4:	CMP.B	#$E1,D0
	BEQ.S	L51A
	MOVE.B	d0,off2d(A0)
	addq	#1,d6
L51A:	move	d6,offe(a0)

	clr	d5
	MOVE.B	off2b(A0),D5
	BMI.S	L528
	ADD.B	off8(a0),D5
	ADD.B	off2c(A0),D5
L528:
	LEA	L94E(PC),A1
	add.b	D5,D5
	MOVE	(A1,d5.w),D0

	move.b	off2a(A0),D2	;0,1 ou 2
	beq.S	L57E

	MOVE.B	off21(A0),D3
	ADDQ	#3,D3

	subq.b	#1,D2
	BNE.S	L578
	subq	#3,d3
	MOVE.B	off2b(A0),D7
	bclr	#7,d7
	bne.s	L578
	add.b	off8(a0),d7
L578:	BSET	D3,$1E(A6)
L57E:
	tst.b	d7
	BEQ.S	L594
	not.b	d7
	and.b	#$1F,D7
	MOVE.B	D7,$1A(A6)
L594:
	MOVE.B	off2e(A0),d6
	TST.B	off1e(A0)
	BEQ.S	L5A4
	SUBQ.B	#1,off1e(A0)
	BRA.S	L5FA
L5A4:
	clr	d4
	MOVE.B	off1c(A0),D4
	clr	d1
	MOVE.B	off1d(A0),D1
	tst.b	d6
	bmi.S	L5CE
	SUB.B	off1b(A0),D1
	BCC.S	L5DC
	tas	d6
	MOVEQ	#0,D1
	BRA.S	L5DC
L5CE:	ADD.B	off1b(A0),D1
	ADD.B	D4,D4
	CMP.B	D4,D1
	BCS.S	L5DA
	bclr	#7,d6
	MOVE.B	D4,D1
L5DA:	lsr.b	#1,d4
L5DC:	MOVE.B	D1,off1d(A0)
L5E0:
	sub	D4,D1

	ADD.B	#$A0,D5
	BCS.S	L5F8
	moveq	#$18,d4

	add	d1,d1
	add.b	d4,d5
	bcs.s	L5F8
	add	d1,d1
	add.b	d4,d5
	bcs.s	L5F8
	add	d1,d1
	add.b	d4,d5
	bcs.s	L5F8
	add	d1,d1
L5F8:	ADD	D1,D0
L5FA:	EOR.B	#1,d6
	MOVE.B	d6,off2e(A0)
	BTST	#5,off9(a0)
	BEQ.s	L628
	moveq	#0,D1
	MOVE.B	off1f(A0),D1
	EXT	D1
	swap	d1
	lsr.l	#4,d1		;asr.l #4,d1 corrige bug ???
	add.l	d1,off38(a0)
	SUB	off38(a0),D0
L628:	MOVE.B	off2d(A0),D1
	SUB.B	off28(A0),D1
	BPL.S	L634
	MOVEQ	#0,D1
L634:
	RTS

L94E:	DC.W	$EEE,$E17,$D4D,$C8E
	DC.W	$BD9,$B2F,$A8E,$9F7
	DC.W	$967,$8E0,$861,$7E8
	DC.W	$777,$70B,$6A6,$647
	DC.W	$5EC,$597,$547,$4FB
	DC.W	$4B3,$470,$430,$3F4
	DC.W	$3BB,$385,$353,$323
	DC.W	$2F6,$2CB,$2A3,$27D
	DC.W	$259,$238,$218,$1FA
	DC.W	$1DD,$1C2,$1A9,$191
	DC.W	$17B,$165,$151,$13E
	DC.W	$12C,$11C,$10C,$FD
	DC.W	$EE,$E1,$D4,$C8
	DC.W	$BD,$B2,$A8,$9F
	DC.W	$96,$8E,$86,$7E
	DC.W	$77,$70,$6A,$64
	DC.W	$5E,$59,$54,$4F
	DC.W	$4B,$47,$43,$3F
	DC.W	$3B,$38,$35,$32
	DC.W	$2F,$2C,$2A,$27
	DC.W	$25,$23,$21,$1F
	DC.W	$1D,$1C,$1A,$19
	DC.W	$17,$16,$15,$13
	DC.W	$12,$11,$10,$F
L7C6:	DC.B	1,0,0,0,0,0,0,$E1
PSGREG:	DC.W	0,0,$101,0
	DC.W	$202,0,$303,0
	DC.W	$404,0,$505,0
	DC.W	$606,0,$707,$FFFF
	DC.W	$808,0,$909,0
	DC.W	$A0A,0

L80E:	DC.B	4
L810:	DC.B	4
L812:	DC.B	-1
L813:	DC.B	0

voice0:	ds.B	off3c
voice1:	ds.B	off3c
voice2:	ds.B	off3c
L916:	DC.L	0
L91A:	DC.L	0
L934:	DC.L	0
L938:	DC.L	0
L93C:	DC.L	0
;
; SCROLLER
;
LONGFONTE = 472+8
;
TAILLE = 8		;HAUTEUR DU SCROLLER
STEP = 2		;PAS DU SCROLLER
;
INITSCROLL:
;
; PREDECALE LA FONTE
;
	MOVEQ	#32,D1
	LEA	PREDEC,A1
NXTDEC:
	LEA	FONTE,A0
NXTCAR:
	MOVEQ	#8-1,D7
DECAL:
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	SWAP	D0
	ROR.L	D1,D0
	MOVE.L	D0,(A1)+
	DBRA	D7,DECAL

	CMP.L	#FINFONTE,A0
	BLO.S	NXTCAR

	SUBQ	#STEP,D1
	BHI.S	NXTDEC

	IFNE	FINAL
	CMP.L	#FINPREDEC,A1
	BLS.S	L1
	ILLEGAL
L1:
	ENDC

	LEA	TEXTE1,A0
	MOVE.L	A0,CURTEXT\W
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	ASL	#5,D0
	ADD.L	#PREDEC,D0
	MOVE.L	D0,LETTRE1.w
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	ASL	#5,D0
	ADD.L	#PREDEC,D0
	MOVE.L	D0,LETTRE2.w
	MOVE.L	A0,PTRTXT.w

	CLR	SHIFT1.w
	CLR	L5E9A.w
	MOVE.L	#L6ECC,BUFSCR.w
	CLR	L5EA6.w

	LEA	L6ECC,A0
	MOVEQ	#0,D0
	MOVE	#(16/STEP)*TAILLE*80/4-1,D1
L84C8:	MOVE.L	D0,(A0)+
	DBF	D1,L84C8
	RTS
;
; A2=ADRESSE ECRAN
;
SCROLLER:
	MOVE.L	ECRAN.W,A2
;
; SCROLLEUR 1 PLAN !!!!
;
	MOVE	SHIFT1.w,D0
	ADD	#(LONGFONTE)*16,D0
	MOVE.L	LETTRE1.w,A0		;PTR FONTE PREMIERE LETTRE
	ADD	D0,A0
	MOVE.L	LETTRE2.w,A3		;PTR FONTE SECONDE LETTRE
	ADD	SHIFT1.w,A3

	MOVE.L	BUFSCR.w,A1
	ADD	L5E9A.w,A1

Y2	SET	(200-TAILLE)*160+PLANSCROLL*2
X2	SET	0
	REPT	TAILLE*152/8

	MOVE	(A1)+,X2+Y2(A2)
X2	SET	X2+8

	IFEQ	X2-X2/160*160-152

	MOVE.L	(A0)+,D0
	OR.L	(A3)+,D0
	OR	(A1),D0
	MOVE	D0,X2+Y2(A2)
	SWAP	D0
	MOVE.L	D0,-40(A1)
	MOVE.L	D0,(A1)
X2	SET	X2+8

	IFNE	X2-TAILLE*160
	LEA	40-2+4(A1),A1
	ENDC

	ENDC
	ENDR

	ADD.L	#TAILLE*80,BUFSCR.w
	ADD	#(LONGFONTE)*4,SHIFT1.w
	CMP	#(LONGFONTE)*4*(16/STEP),SHIFT1.w	;SCROLLER 4 EN 4
	BLO.S	L5102
	CLR	SHIFT1.w
	MOVE.L	#L6ECC,BUFSCR.w

	ADDQ	#2,L5E9A.w
	CMP	#40,L5E9A.w
	BNE.S	L50BC
	CLR	L5E9A.w
L50BC:
	MOVE.L	PTRTXT.w,A0
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	BPL.S	L50F8
	MOVE.L	CURTEXT\W,A0
	MOVE.B	(A0)+,D0
L50F8:
	ASL	#5,D0
	ADD.L	#PREDEC,D0
	MOVE.L	D0,LETTRE1.w
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	BPL.S	L50F82
	MOVE.L	CURTEXT\W,A0
	MOVE.B	(A0)+,D0
L50F82:
	ASL	#5,D0
	ADD.L	#PREDEC,D0
	MOVE.L	D0,LETTRE2.w
	MOVE.L	A0,PTRTXT.w
L5102:
	RTS
FONTE:	DS.B	8
fonte:	incbin	fonte3.img
FINFONTE:
;
; ETOILES
;
PROF=	32767

STARS_EF_X:	DC.W	4
STARS_EF_Y:	DC.W	4

; X (140 - 396)
; Y (40 -  220)


INITSTAR
	MOVE.L	#BUFFER1,BUFFER\W
	MOVE.L	#BUFFER2,SWAPBUF\W

	BSR	INIT_STARS
	LEA	ETOILES,A3
	LEA	PTRS,A6
	MOVE.W	#NBSTAR-1,D7
E:
	MOVE.L	A3,NBSTAR*4(A6)
	move.l	a3,(a6)+
REF:	CLR	CPTS
DE:
	ADDQ	#1,CPTS
	BSR.S	F
	BEQ.S	DE
	cmp	#minimum,CPTS
	bhs.s	.ok
	move.l	-4(a6),a3
	bra.s	REF
.ok
	MOVE.W	#-1,(A3)+
	DBRA	D7,E
	IFNE	FINAL
	CMP.L	#FINETOILES,A3
	BLS.S	.OK
	ILLEGAL
.OK
	ENDC
	RTS
CPTS:	DC.W	0

F:
	MOVEM.W	STARS_EF_X(PC),D0/D1
	ADD.W	D0,DEGX
	ADD.W	D1,DEGY
	BGE.S	DXOK0
	ADD.W	#720,DEGX
	BRA.S	DXOK1
DXOK0:
	CMP.W	#720,DEGX
	BLT.S	DXOK1
	SUB.W	#720,DEGX
DXOK1:
	TST.W	DEGY
	BGE.S	T2_Y
	ADD.W	#720,DEGY
T2_Y:	CMP.W	#360*2,DEGY
	BLT.S	AAA
	SUB.W	#720,DEGY
AAA:
	LEA	TABLE_3D_STARS,A0
	LEA	SIN(PC),A4
STARS_LOOP2:	
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	MOVE.W	(A0),D2
	BMI	NO_STARS
	SUB.W	#SPEED,(A0)

	EXT.L	D0
	EXT.L	D1

	SWAP	D0
	ASR.L	#4,D0
	DIVS	D2,D0

	SWAP	D1
	ASR.L	#4,D1
	DIVS	D2,D1	;---- Y

;-----------------------------------------;
;             R O T A T I O N             ;
;-----------------------------------------;

	MOVE.W	DEGX(PC),D6
	MOVE.W	COS(PC,D6.W),D5
	MOVE.W	DEGY(PC),D6
	MOVE.W	0(A4,D6.W),D6

	MOVE.W	D0,D3
	MOVE.W	D1,D4

	MULS	D5,D3	;X COS
	MULS	D6,D4	;Y SIN
	MULS	D5,D1	;Y COS
	MULS	D6,D0	;X SIN

	SUB.L	D4,D3
	ADD.L	D0,D1

	MOVE.L	D3,D0

	ASR.L	#8,D0
	ASR.L	#8,D1

	ADD.W	#320/2,D0
	ADD.W	#200/2,D1

	BRA	DEK_POINT
;------------------- TABLE COS/SIN ----------------------;

COS:
 dc.w 256,256,256,256,255,255,255,254,254,253,252,251,250
 dc.w 249,248,247,246,245,243,242,241,239,237,236,234,232
 dc.w 230,228,226,224,222,219,217,215,212,210,207,204,202
 dc.w 199,196,193,190,187,184,181,178,175,171,168,165,161
 dc.w 158,154,150,147,143,139,136,132,128,124,120,116,112
 dc.w 108,104,100,96,92,88,83,79,75,71,66,62,58
 dc.w 53,49,44,40,36,31,27,22,18,13,9,4
SIN:
 dc.w 0,-4,-9,-13,-18,-22,-27,-31,-36,-40,-44,-49,-53,-58
 dc.w -62,-66,-71,-75,-79,-83,-88,-92,-96,-100,-104,-108,-112
 dc.w -116,-120,-124,-128,-132,-136,-139,-143,-147,-150,-154,-158,-161
 dc.w -165,-168,-171,-175,-178,-181,-184,-187,-190,-193,-196,-199,-202
 dc.w -204,-207,-210,-212,-215,-217,-219,-222,-224,-226,-228,-230,-232
 dc.w -234,-236,-237,-239,-241,-242,-243,-245,-246,-247,-248,-249,-250
 dc.w -251,-252,-253,-254,-254,-255,-255,-255,-256,-256,-256,-256,-256
 dc.w -256,-256,-255,-255,-255,-254,-254,-253,-252,-251,-250,-249,-248
 dc.w -247,-246,-245,-243,-242,-241,-239,-237,-236,-234,-232,-230,-228
 dc.w -226,-224,-222,-219,-217,-215,-212,-210,-207,-204,-202,-199,-196
 dc.w -193,-190,-187,-184,-181,-178,-175,-171,-168,-165,-161,-158,-154
 dc.w -150,-147,-143,-139,-136,-132,-128,-124,-120,-116,-112,-108,-104
 dc.w -100,-96,-92,-88,-83,-79,-75,-71,-66,-62,-58,-53,-49
 dc.w -44,-40,-36,-31,-27,-22,-18,-13,-9,-4,0,4,9
 dc.w 13,18,22,27,31,36,40,44,49,53,58,62,66
 dc.w 71,75,79,83,88,92,96,100,104,108,112,116,120
 dc.w 124,128,132,136,139,143,147,150,154,158,161,165,168
 dc.w 171,175,178,181,184,187,190,193,196,199,202,204,207
 dc.w 210,212,215,217,219,222,224,226,228,230,232,234,236
 dc.w 237,239,241,242,243,245,246,247,248,249,250,251,252
 dc.w 253,254,254,255,255,255,256,256,256
 dc.w 256,256,256,256,255,255,255,254,254,253,252,251,250
 dc.w 249,248,247,246,245,243,242,241,239,237,236,234,232
 dc.w 230,228,226,224,222,219,217,215,212,210,207,204,202
 dc.w 199,196,193,190,187,184,181,178,175,171,168,165,161
 dc.w 158,154,150,147,143,139,136,132,128,124,120,116,112
 dc.w 108,104,100,96,92,88,83,79,75,71,66,62,58
 dc.w 53,49,44,40,36,31,27,22,18,13,9,4

DEK_POINT:
	CMP	#320,D0
	BHS.S	NO_STARS
	CMP	#200,D1
	BHS.S	NO_STARS

	MOVEQ	#$F,D3
	EOR	D3,D0
	AND	D0,D3
	EOR	D3,D0
	MOVEQ	#0,D4
	BSET	D3,D4
	CMP	#PROF1,D2
	BLT.S	.SOMB
	SWAP	D4
	CMP	#PROF2,D2
	BLT.S	.SOMB
	BSET	D3,D4
.SOMB
	LSR	#1,D0
	MULU	#160,D1
	ADD	D0,D1
	MOVE.W	D1,(A3)+	;offset ecran
	MOVE.L	D4,(A3)+	;couleur
	ADDQ.W	#2,A0
	MOVEQ	#0,D0
	RTS

NO_STARS:
	BSR.S	RND_VAL
	MOVE.W	D1,-4(A0)
	BSR.S	RND_VAL
	MOVE.W	D1,-2(A0)
	MOVE.W	#PROF,(A0)+
	MOVEQ	#-1,D0
	RTS

DEGX:	DC.W	0
DEGY:	DC.W	0


INIT_STARS:
	LEA	TABLE_3D_STARS,A0
	MOVE.W	#NBSTAR-1,D0
	MOVEQ	#0,D6
	LEA	COS(PC),A1
	LEA	SIN(PC),A2
	MOVEQ	#0,D2
INIT_STARS_3D:
	MOVE.W	D2,D1
	ADD.W	D1,D1
	MOVE.W	0(A1,D1.W),D1
	ASR.W	#1,D1
	MOVE.W	D1,(A0)+

	MOVE.W	D2,D1
	ADD.W	D1,D1
	MOVE.W	0(A2,D1.W),D1
	MOVE.W	D1,(A0)+

	ADDQ.W	#1,D2

	BSR.S	RND_VAL
	MOVE.W	D1,D7
	ADD.W	#2000,D7
	ADD.W	D6,D7
	ADD.W	#1232,D6
	LSL.W	#8,D7
	BGT.S	Z_800	
	SUB.W	#PROF,D7
Z_800:
	MOVE.W	D7,(A0)+
	DBRA	D0,INIT_STARS_3D
	RTS


;---------- RND VAL renvoye dans D1 ----------;

RND2:	DC.W	$6789
RND_VAL:
	ADD	#$1234,RND2
	EOR	#$4567,RND2
	MOVE	RND2,D1
	ADD.W	D1,RND
	ADD.W	RND(PC),D1
	ADD.W	D1,RND
	AND.W	#$3FF,D1
	CMP.W	#720,D1
	BLT.S	RND_VAL2
	SUB.W	#720,D1
RND_VAL2:
	RTS

RND:	DC.W	0

;
; FAST CLS
;
	opt	ow-
FASTCLS:
	movem	XMIN,d4-d7

	cmp	#200,d6
	blo.s	.1
	sge	d6
	ext	d6
	and	#200-1,d6
.1
	cmp	#200,d7
	blo.s	.2
	sge	d7
	ext	d7
	and	#200-1,d7
.2
;
; d4=xmin
; d5=xmax
; d6=ymin
; d7=ymax
;
	ADD	#16,d5
	MOVEQ	#-16,D1
	and	d1,d5
	AND	d4,d1
	sub	d1,d5		;d5=nb pixels … effacer (multiple de 16)
	ble.s	.nocls
	asr	#1,d1
	move.l	usp,a6
	add	d1,a6

	moveq	#0,d0
	lsr	#2,d5		;nbpixels … effacer/4
	sub	d6,d7		;d7=nb lignes-1
	add	d6,d6
	lea	MUL160.W,A2
	add	(a2,d6.w),a6
	JMP	.ONEPLANE-4(PC,D5.W)
.nocls	jmp	(a1)
.ONEPLANE
	bra.w	.eff16
	bra.w	.eff32
	bra.w	.eff48
	bra.w	.eff64
	bra.w	.eff80
	bra.w	.eff96
	bra.w	.eff112
	bra.w	.eff128
	bra.w	.eff144
	bra.w	.eff160
	bra.w	.eff176
	bra.w	.eff192
	bra.w	.eff208
	bra.w	.eff224
	bra.w	.eff240
	bra.w	.eff256
	bra.w	.eff272
	bra.w	.eff288
	bra.w	.eff304
	bra.w	.eff320
	DCB.W	10,$4AFC
.eff16
	move	d0,(a6)
	lea	160(a6),a6
	dbra	d7,.eff16
	JMP	(A1)
.eff32
	move	d0,(a6)
	move	d0,8(a6)
	lea	160(a6),a6
	dbra	d7,.eff32
	JMP	(A1)
.eff48
x	set	0
	rept	3
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff48
	JMP	(A1)
.eff64
x	set	0
	rept	4
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff64
	JMP	(A1)
.eff80
x	set	0
	rept	5
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff80
	JMP	(A1)
.eff96
x	set	0
	rept	6
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff96
	JMP	(A1)
.eff112
x	set	0
	rept	7
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff112
	JMP	(A1)
.eff128
x	set	0
	rept	8
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff128
	JMP	(A1)
.eff144
x	set	0
	rept	9
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff144
	JMP	(A1)
.eff160
x	set	0
	rept	10
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff160
	JMP	(A1)
.eff176
x	set	0
	rept	11
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff176
	JMP	(A1)
.eff192
x	set	0
	rept	12
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff192
	JMP	(A1)
.eff208
x	set	0
	rept	13
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff208
	JMP	(A1)
.eff224
x	set	0
	rept	14
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff224
	JMP	(A1)
.eff240
x	set	0
	rept	15
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff240
	JMP	(A1)
.eff256
x	set	0
	rept	16
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff256
	JMP	(A1)
.eff272
x	set	0
	rept	17
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff272
	JMP	(A1)
.eff288
x	set	0
	rept	18
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff288
	JMP	(A1)
.eff304
x	set	0
	rept	19
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff304
	JMP	(A1)
.eff320
x	set	0
	rept	20
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff320
	JMP	(A1)

	section	data
PALETTE:
;	DC.W	0,$667,$556,$445
;	DC.W	0,$445,$667,$223
	DC.W	0,$566,$777,$344
;	DC.W	0,$700,$070,$007
	DCB.W	4,$007
	DCB.W	8,$700
TEXTE1:
	INCBIN	MESSAGE.BIN
	DC.W	-1
MUSLOAD:INCBIN	NY3.IMG
	even
DRAW_IT
	INCBIN	DRAW17.BIN
ENDDRAW
	IFNE	FINAL
DEBUGGER:INCBIN	DEBUGGER.BIN
	ENDC
ALL_OBJETS
	INCBIN	OBJETS.BIN
	JMP	RITURN

	SECTION	BSS

TABLE_3D_STARS:	DS.W	NBSTAR*3

PREDEC:	DS.B	2*4*(16/STEP)*(LONGFONTE)
FINPREDEC:
L6ECC:	DS.B	(16/STEP)*TAILLE*80	;BUFFER POUR SCROLLER

startmus:ds.b	$6c00

BUFFER1	DS.W	NBSTAR		;OFFSETS ECRAN
BUFFER2	DS.W	NBSTAR		;OFFSETS ECRAN
PTRS	DS.L	NBSTAR*2
ETOILES	DS.B	100000
FINETOILES
INFINI:	DS.B	$15000
FININFINI:
;
; BUFFER POUR LES ETOILES
;
