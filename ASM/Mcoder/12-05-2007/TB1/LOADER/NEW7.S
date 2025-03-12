	output	NEWDOS.PRG
STOREMENU = $80200		;POUR STOCKAGE MAIN MENU SUR 1040
DEBUG = 1		;0=DEBUGGER
;
; loader d‚mo se charge en $500
;
; DEMO 0 = MAIN MENU
;
	OPT	O+
;
; ATTEND QUE LA VBL SOIT FINIE
;
WAITVBL:MOVE	$FFFF8240.W,D0
	AND	#$777,D0
	BNE.S	WAITVBL
	MOVE	#$2700,SR

	LEA	CODE(PC),A0
	LEA	FIRSTTRANS\W,A1
	MOVE	#(FINLOADER-FIRSTTRANS+3)/4-1,D0
MOVEIT	MOVE.L	(A0)+,(A1)+
	DBRA	D0,MOVEIT
	JMP	LOADER\W
	DC.B	"HELLO, WHAT ARE YOU DOING IN MY CODE ? "
	DC.B	"TRYING TO RIP MY SHITTY SCREENS OR "
	DC.B	"MAKING A DEMO-BREAKER ? "
	DC.B	"SHAME ON YOU COZ THIS DEMO ISN'T REALLY A BIG "
	DC.B	"WORK, IT'S MUCH MORE A BIG MESS... "
	DC.B	"SOME GOOD DEMOS SHOULD APPEAR IN SEPTEMBER "
	DC.B	"AND ONE OF THEM WILL CONTAIN MY LAST FILLED "
	DC.B	"3D ROUTINES : ANIMATION OF THE WHOLE SCREEN IN 1 VBL !!! "
	EVEN
CODE:
	ORG	$4FE
FIRSTTRANS:
DEMO:	DC.W	0

LOADER:
	MOVE	#$2700,SR
	LEA	$400.W,SP		;POSITIONNE LA PILE SUPERVISEUR
	MOVE.L	#$08080000,$FFFF8800.W
	MOVE.L	#$09090000,$FFFF8800.W
	MOVE.L	#$0A0A0000,$FFFF8800.W

	IFEQ	DEBUG
	BSR	DEBUGGER
	ELSEIF
	LEA	8.W,A0
	LEA	RESET(PC),A1
	MOVEQ	#($140-8)/4-1,D0
.SETVEC	MOVE.L	A1,(A0)+
	DBRA	D0,.SETVEC
	ENDC

	MOVE.L	#$31415926,$426.W
	MOVE.L	#RESET,$42A.W

	MOVE.L	#HBL,$68.W
	MOVE.L	#TRAP1,$80+1*4.W
	MOVE.L	#TRAP13,$80+13*4.W
	MOVE.L	#TRAP14,$80+14*4.W
	MOVE.L	#LINEA,$28.W

	MOVE.L	#VBLVEC,$70.W
	CLR.L	$4D2.W
	move.l	#interdisk,$11c.w

	moveq	#0,d0
	MOVE.L	D0,A0
	MOVEP.L	D0,$FFFFFA01(A0)
	MOVEP.L	D0,$FFFFFA09(A0)
	MOVEP.L	D0,$FFFFFA11(A0)
	MOVEP.L	D0,$FFFFFA19(A0)
	MOVE.B	#$48,$FFFFFA17.W
	or.b	#$80,$fffffa09.w	;autorise disk
	or.b	#$80,$fffffa15.w

	MOVE	#$2300,SR
;
; INIT KBD
;
;.IKB1	BTST	#1,$FFFFFC00.W
;	BEQ.S	.IKB1
;	MOVE.B	#$1A,$FFFFFC02.W	;CUT JOYSTICKS
;.IKB2	BTST	#1,$FFFFFC00.W
;	BEQ.S	.IKB2
;	MOVE.B	#$12,$FFFFFC02.W	;CUT MOUSE
;
	MOVE.L	#$07078080,$FFFF8200.W
	MOVEQ	#0,D0
	LEA	$FFFF8240.W,A0
	MOVE.L	d0,(A0)+
	MOVE.L	d0,(A0)+
	MOVE.L	d0,(A0)+
	MOVE.L	d0,(A0)+
	MOVE.L	d0,(A0)+
	MOVE.L	d0,(A0)+
	MOVE.L	d0,(A0)+
	MOVE.L	d0,(A0)+

	LEA	FINLOADER\W,A0
	LEA	$80000,A1
.CLS	MOVE.L	d0,(A0)+
	CMP.L	A1,A0
	BLO.S	.CLS
;
; D1.W :
;	SECTEUR LOGIQUE
; D2.W :
;	NB SECTEURS A CHARGER
; A0.L :
;	ADRESSE DEBUT CHARGEMENT
;
	MOVE	DEMO.W,D0
	CMP	#2,D0
	BNE.S	.PAMENU
	CMP.L	#'MENU',STOREMENU-8
	BEQ	TRANSFEREMENU
.PAMENU
	MULU	#12,D0
	MOVEM.L	REFERENCES(PC,D0.W),D1/D2/A0
	PEA	(A0)
	lea	$40000,a0
	BSR	ENTRY
	BRA	DEPACK		;DEPACKE ET BRANCHE AU DEBUT
;
; 0.L = SECTEUR LOGIQUE
; 4.L = NB SECTEURS A CHARGER
; 8.L = ADRESSE DEBUT PRG
;
LONG	MACRO
	DC.L	X,\1,$8000
X	SET	X+\1
	ENDM

X	SET	1
REFERENCES:
	LONG	182		;INTRO 1
	LONG	64		;INTRO 2
	LONG	75		;MAIN MENU
	LONG	29
	LONG	53
	LONG	73
	LONG	41
	LONG	113
	LONG	38
	LONG	72
HBL:
	MOVE	D0,-(SP)	;DEBUGGAGE OVERLANDERS !!!
	MOVE	2(SP),D0
	AND	#$700,D0
	BNE.S	.NO
	OR	#$300,2(SP)
.NO:
	MOVE	(SP)+,D0
	RTE

TRAP14:
	CMP	#5,6(SP)
	BEQ.S	.SETSCREEN
	CMP	#6,6(SP)
	BEQ.S	.SETPALETTE
	cmp	#3,6(sp)
	beq.s	.getlog
	cmp	#4,6(sp)
	beq.s	.getrez
	cmp	#2,6(sp)
	beq.s	.getphys
	CMP	#$1F,6(SP)
	BEQ.S	.SETTIMER
	CMP	#$26,6(SP)
	BEQ	.SUPEXEC
	CMP	#$25,6(SP)
	BEQ	.WAITVBL
	CMP	#$23,6(SP)
	BEQ.S	.RIEN
	ILLEGAL
.getphys:move.l	#$78000,d0
	rte
.getlog	move.l	#$70000,d0
	rte
.getrez	moveq	#0,d0
	rte
.SETSCREEN
	MOVE.L	8+4(SP),D0
	BMI.S	.RIEN
	LSR	#8,D0
	MOVE.L	D0,$FFFF8200.W
.RIEN
	RTE
.SETPALETTE
	MOVE.L	8(SP),A0
	MOVEM.L	D0-D7,-(SP)
	MOVEM.L	(A0),D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W
	MOVEM.L	(SP)+,D0-D7
	RTE
.SETTIMER
	CMP	#1,8(SP)
	BNE.S	PLANTAGE
	CLR.B	$FFFFFA1B.W
	and.B	#$fe,$FFFFFA13.W
	and.B	#$fe,$FFFFFA07.W
	AND.B	#$FE,$FFFFFA0F.W
	AND.B	#$FE,$FFFFFA0B.W
	MOVE.L	14(SP),$120.W
	MOVE.B	13(SP),$FFFFFA21.W
	OR.B	#1,$FFFFFA13.W
	OR.B	#1,$FFFFFA07.W
	MOVE.B	11(SP),$FFFFFA1B.W
	RTE
.SUPEXEC
	MOVE.L	8(SP),A0
	JSR	(A0)
	RTE
.WAITVBL
	MOVE.L	$466.W,D0
.WW1	CMP.L	$466.W,D0
	BEQ.S	.WW1
	RTE
TRAP13:
PLANTAGE:
	ILLEGAL

TRAP1:
	TST	6(SP)
	BEQ	LOADER		;QUIT ???
	CMP	#9,6(SP)
	BEQ.S	.PRINT
	CMP	#$20,6(SP)
	BNE.S	PLANTAGE
.PRINT	RTE
LINEA:	ADDQ.L	#2,2(SP)
	RTE
;
; mini-dos
;
; V1.4 10/09/89 optimisation de place avec move (A7)+,d0
;
;	- g‚rer sur VBL l'extinction de la diode
;	- variables DRIVE et NBSIDE en $100 (r‚sistent au RESET)
;
step	equ	3

adload	ds.l	1	;adresse de chargement
track	ds.w	1	;piste courante ou destination
sector	ds.w	1	;secteur … charger
nbsec	ds.w	1	;nb secteurs … charger

*****************************************************************
*								*
* NE PAS TOUCHER AUX 4 VARIABLES SUIVANTES (RUSE AVEC MOVE.L)	*
*								*
*****************************************************************

nberr	ds.b	1	;nbr d'erreurs avant restore
;			prend les valeurs :
;			0,$20,$40,$60,$80,$a0,$c0,$e0
nbrest	ds.b	1	;nbr de restore autoris‚s
;			prend les valeurs :
;			0,$40,$80,$C0
;
errdisk	ds.b	1	;num‚ro erreur
type	ds.b	1

initialise	ds.b	1	;0=faire restore avant tout (avec ROM)
	even
;
; type :
;	0=load sector
;	$ff=goto track
;	1=crc correction (restore et seek)
;
; errdisk :
;	0=chargement en cours
;	1=CRC error
;	2=record not found
;	-1=chargement termin‚ sans erreur
;
;
; MINI-DOS TRES RAPIDE
;
; D1.L :
;	SECTEUR LOGIQUE
; D2.L :
;	NB SECTEURS A CHARGER
; A0.L :
;	ADRESSE DE CHARGEMENT
;
ENTRY:
	CLR	D0
	CMP	#10*80,D1
	BLO.S	.1
	SUB	#10*80,D1
	ADDQ	#1,D0
.1
	AND	#3,$440.W		;DEJA FAIT DANS BOOT SECTEUR !!!
	ST	$43E.W			;ON EMPECHE ARRET DU MOTEUR
	MOVEQ	#1,D3			;DRIVE BOOTANT (0 ou 1)
	SUB	$446.W,D3
	ADD	D3,D3
	ADDQ	#3,D3
	EOR	D3,D0
	MOVE	SR,-(SP)
	OR	#$700,SR
	MOVE.B	#$E,$FFFF8800.W
	MOVEQ	#-8,D3
	AND.B	$FFFF8800.W,D3
	OR	D3,D0
	MOVE.B	D0,$FFFF8802.W
	MOVE	(SP)+,SR
.restart
	move.l	a0,adload.w
	move	d2,nbsec.w

	move	#$90,$FFFF8606.W
	move	#$190,$FFFF8606.W
	move	#$90,$FFFF8606.W
	move.b	adload+3\w,$FFFF860D.W
	move.b	adload+2\w,$FFFF860B.W
	move.b	adload+1\w,$FFFF8609.W

	move.l	d1,d3
	DIVU	#10,D3
	move	d3,track.w		;num‚ro de piste
	SWAP	D3
	ADDQ	#1,D3			;NUMERO DE SECTEUR (1 A 10)
	move	d3,sector.w

	tst.b	initialise\w
	beq.s	reinit
	move	#$86,$FFFF8606.W
	move	track\w,$FFFF8604.W
	move	#$80,$FFFF8606.W
;	st	type\w
;	clr.b	errdisk\w
;	clr.b	nbrest\w
;	clr.b	nberr\w
	move.l	#$000000FF,nberr\w

	move	#$14+step,$ffff8604.w
	RTS
reinit
	move	#$80,$FFFF8606.W
;	move.b	#1,type\w
;	clr.b	errdisk\w
;	clr.b	nbrest\w
;	clr.b	nberr\w
;	move.l	#$00000001,nberr\w
	moveq	#1,d0
	move.l	d0,nberr\w

	move	#step,$ffff8604.w
	RTS
erreur1
	move.b	#1,errdisk\w
	rte
crccorec
	move	(A7)+,d0
	add.b	#$20,nberr\w
	bcs.s	erreur1
	move.b	adload+3\w,$FFFF860D.W
	move.b	adload+2\w,$FFFF860B.W
	move.b	adload+1\w,$FFFF8609.W
	add.b	#$40,nbrest\w
	bcc.s	reload
	move.b	#1,type\w
	move	#step,$FFFF8604.W
	rte
stepin
	st	type\w
	move	#1,sector\w
	cmp	#82,track\w
	bhs.s	erreur2

	move	#$50+step,$FFFF8604.W
	addq	#1,track\w
	rte
interdisk
	move	d0,-(A7)
	move.b	#$7f,$fffffa11.w

	move	$FFFF8604.W,d0
	asl.b	#4,d0
	bcs.s	erreur3

	tst.b	type\w
	bne.s	paload

	tst.b	d0
	bmi.s	crccorec

	move	(A7)+,d0

	add.l	#$200,adload\w
	subq	#1,nbsec\w
	beq.s	finload
;	clr.b	nbrest\w
;	clr.b	nberr\w
	clr.w	nberr\w

	addq	#1,sector\w
	cmp	#11,sector\w
	bhs.s	stepin
reload
	move	#$84,$FFFF8606.W
	move	sector\w,$FFFF8604.W
	move	#$90,$FFFF8606.W
	move	#1,$FFFF8604.W		;512 octets par secteur...
	move	#$80,$FFFF8606.W
	clr.b	type\w
	move	#$80,$FFFF8604.W
	rte
finload	st	errdisk\w
	clr	$43e.w
	rte
erreur3	move	(A7)+,d0
erreur2	move.b	#2,errdisk\w
	rte
paload
	tst.b	d0
	bmi.s	erreur3

	move	(A7)+,d0

	tst.b	type\w
	bmi.s	reload
	move	#$86,$FFFF8606.W
	move	track\w,$FFFF8604.W
	st	initialise\w
	move	#$80,$FFFF8606.W
	st	type\w
	move	#$14+step,$FFFF8604.W
	rte

VBLVEC:
	ADDQ.L	#1,$466.W
	TST	$43E.W
	BNE.S	.NOCHG

	MOVE	D0,-(SP)
	MOVE	$FFFF8604.W,D0
	TST.B	D0
	BMI.S	.NOSTOP
	MOVE.L	#$0E0E0707,$FFFF8800.W
	TAS	$43E.W			;$80=arret du moteur
.NOSTOP
	MOVE	(SP)+,D0
.NOCHG
	TST.L	$4D2.W
	BEQ.S	.NOVEC
	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.L	$4D2.W,A0
	JSR	(A0)
	MOVEM.L	(SP)+,D0-D7/A0-A6
.NOVEC
	RTE

DEBUG2:	DC.L	0

DEPACK:
	MOVE.L	(SP),A1
	lea	$40000,a0
	lea	FINLOADER,A2
;
;	a0=source
;	a1=destination
;	a2=adresse de d‚but de l'arbre (1026+256 octets)
;
	BSR	decrunch

	MOVE	A1,D0
	LSR	#1,D0
	BCC.S	.PAIR
	CLR.B	(A1)+
.PAIR
	MOVE.L	A1,DEBUG2.W
	MOVE.L	(SP),A3
	BSR	RELOGEUR

	MOVE.L	DEBUG2.W,A0
	MOVE.L	#$07078080,$FFFF8200.W
	MOVE.L	#$78000,$44E.W

	CMP	#2,DEMO.W
	BNE.S	.PAMENU

	MOVE.L	#'MENU',STOREMENU-8
	CMP.L	#'MENU',STOREMENU-8
	BNE.S	.PAMENU
	LEA	STOREMENU-4,A1
	MOVE.L	A0,(A1)+
	LEA	$8000,A2
.COPYMEN
	MOVE.L	(A2)+,(A1)+
	CMP.L	A0,A2
	BLO.S	.COPYMEN
.PAMENU
	lea	$80000,a1
	moveq	#0,d0
.cls	move.l	d0,(a0)+		;cleare zone BSS
	cmp.l	a1,a0
	blo.s	.cls

	move.l	(sp)+,a0
	move.l	a0,a7

	TST	DEMO.W
	SEQ	D0
	EXT	D0
	ADDQ	#2,D0
	MOVE	D0,DEMO.W

.waiteteint
	tst	$43e.w
	beq.s	.waiteteint
	CLR	$FFFF8242.W
	jmp	(a0)

TRANSFEREMENU
	LEA	STOREMENU-4,A0	;SOURCE
	MOVE.L	(A0)+,A2
	LEA	$8000,A1	;DESTINATION
	MOVE.L	A1,SP
.MOVEIT	MOVE.L	(A0)+,(A1)+
	CMP.L	A2,A1
	BLO.S	.MOVEIT
	JMP	(SP)

RELOGEUR:
	TST	$1A(A3)
	BNE.S	.NORELOC
	MOVE.L	2(A3),A0
	ADD.L	6(A3),A0
	LEA	$1C(A3),A1
	add.l	a1,a0
	MOVE.L	A0,DEBUG2.W
	MOVE.L	(A0)+,D0
	BEQ.S	.L9FE
	ADD.L	D0,A1
	MOVEQ	#$1C,D0
	ADD.L	A3,D0
	MOVEQ	#0,D1
.L9DE	ADD	D1,A1
	SUBQ.B	#1,D1
	BNE.S	.L9DF
	LEA	$FE-1(A1),A1
	BRA.S	.L9E0
.L9DF	ADD.L	D0,(A1)
.L9E0	MOVE.B	(A0)+,D1
	BNE.S	.L9DE
.L9FE
.NORELOC
	RTS
;
; nouveau d‚packer optimis‚ et relogeur !!!
;
; 10/04/90
;
TOPO8 = 1		;0=topo 8 bits, 1=topo 9 bits
ajuste = 12		;12 pour Ivanho‚

WAITDMA	MACRO
.\@
	cmp.l	adload.w,a0
	bhs.s	.\@
	move	(a0)+,d2
	addx	d2,d2
	ENDM
RDBYTE	macro
	move.l	a2,a5
	move	d1,d0
.\@1	add	d2,d2
	bne.s	.\@2
	WAITDMA
.\@2	bcc.s	.\@3
	add	d0,a5
.\@3	move	(a5)+,d0
	bpl.s	.\@1
	endm

nbmeth = 12
;
; DECRUNCHER MIXTE (HUFFMANN+PACK)
;
;	a0=source
;	a1=destination
;	a2=adresse de d‚but de l'arbre (1026+256 octets)
;
decrunch:
;
; AFFICHE PLEASE WAIT !!!
;
TAILLEX = ($3E+1+15)&-16
TAILLEY = $12+1
	LEA	LOADING,A3
	LEA	$78000+(100-TAILLEY/2)*160+80-TAILLEX/4,A4
	MOVEQ	#TAILLEY-1,D1
.AFF2
	MOVEQ	#TAILLEX/16-1,D0
.AFFICHE
	MOVE	(A3)+,(A4)
	ADDQ	#8,A4
	DBRA	D0,.AFFICHE
	LEA	160-TAILLEX/2(A4),A4
	DBRA	D1,.AFF2
	MOVE	#$777,$FFFF8242.W

	TAS	D0
	NEG	D0

	MOVE.L	a2,a3
	BSR	.DECODE0
	MOVE	(a2)+,D1
	moveq	#0,d4
	move.l	a3,a4
	moveq	#256/4-1,d0
.clear:	move.l	d4,(a4)+
	dbra	d0,.clear
	lea	.codes2+12(pc),a4
	moveq	#nbmeth-1,d3
.copy:
	bsr	.byte
	move.b	d0,d4
	move.b	-(a4),(a3,d4.w)
	dbra	d3,.copy
	bra.s	.traduit
.sure:
	rts
.base:
	move.b	d0,(a1)+
.traduit:
	RDBYTE

	cmp.l	a3,a5
	bhs.s	.sure
	move.b	d0,d4
	move.b	(a3,d4.w),d4
	jmp	.base(pc,d4.w)
.meth0:
	bsr	.byte
	bra.s	.base
.meth1:
	bsr	.byte
	move.b	d0,d6
.meth3:
	moveq	#0,d3
.meth2xx:
	bsr	.byte
	move.b	d0,d3
	move.b	d6,(a1)+
	move.b	d6,(a1)+
.meth2x:
	move.b	d6,(a1)+
	dbra	d3,.meth2x
	bra.s	.traduit
.meth2:
	bsr	.byte
	move.b	d0,d6

	bsr	.byte8
	bra.s	.meth2xx
.meth4:
	moveq	#0,d3
.cnt8:
	bsr	.byte
	move.b	d0,d3
	neg	d3
	lea	-2(a1,d3.w),a4
	moveq	#0,d3
.copy4:
	bsr	.byte
	move.b	d0,d3
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
.meth4x:move.b	(a4)+,(a1)+
	dbra	d3,.meth4x
	bra.S	.traduit
.meth5:
	moveq	#0,d3
.cnt16:
	bsr.s	.byte
	move.b	d0,d3
	neg	d3
	lea	-2(a1,d3.w),a4
	bsr.s	.byte8
	bra.s	.copy4
.meth6:
	bsr.s	.byte8
	bra.s	.cnt8
.meth7:
	bsr.s	.byte8
	bra.s	.cnt16
.meth8:
	bsr.s	.byte
	and	#$ff,d0
	neg	d0
	lea	-2(a1,d0.w),a4

	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+

	bra	.traduit
.meth9:
	bsr.s	.byte
	move.b	d0,d5
	bsr.s	.byte
	move.b	d0,d4
	bsr.s	.byte
	and	#$ff,d0
	addq	#4,d0
.meth9x:
	move.b	d5,(a1)+
	add.b	d4,d5
	dbra	d0,.meth9x
	bra	.traduit
.meth10:
	bsr.s	.byte
	move.b	d0,d7
.meth11:
	ifne	TOPO8
	move.b	d7,(a1)+
	endc
	bsr.s	.byte
	move.b	d0,d4
	moveq	#8-1,d3
.meth10x:
	move.b	d7,d0
	add.b	d4,d4
	bcc.s	.nomsk1
	bsr.s	.byte
.nomsk1:
	move.b	d0,(a1)+
	dbra	d3,.meth10x
	bra	.traduit
.byte8:
	bsr.s	.byte
	addq.b	#1,d0
	move.b	d0,d3
	asl	#8,d3
	rts
.byte:
	MOVE.L	a2,a5
	MOVE	D1,D0
.X1:	ADD	D2,D2
	BEQ.S	.X2
	BCC.S	.X3
	ADD	D0,a5
.X3:	MOVE	(a5)+,D0
	BPL.S	.X1
	rts
.X2:
	WAITDMA
	BCC.S	.X4
	ADD	D0,a5
.X4:	MOVE	(a5)+,D0
	BPL.S	.X1
	RTS
.DECODE3:
	ADDQ	#2,a3
	PEA	(a3)
	BSR.S	.DECODE
	MOVE.L	(sp)+,a5
	MOVE	a3,D0
	SUB	a5,D0
	MOVE	D0,-(a5)
.DECODE:
	ADD	D2,D2
	BNE.S	.TSTCARY2
.DECODE0:
	WAITDMA
.TSTCARY2:
	BCC.S	.DECODE3

	MOVE	#$8001,D0
.L1F2EE:ADD	D2,D2
	BNE.S	.TSTCARY3
	WAITDMA
.TSTCARY3:
	ADDX.B	D0,D0
	BCC.S	.L1F2EE
	MOVE	D0,(a3)+
	rts
.codes2:
	dc.b	.meth0-.base,.meth1-.base,.meth2-.base,.meth3-.base
	dc.b	.meth4-.base,.meth5-.base,.meth6-.base,.meth7-.base
	dc.b	.meth8-.base,.meth9-.base,.meth10-.base,.meth11-.base

LOADING:INCBIN	LOADING.BIN

SECONDVBL:
	ADDQ	#1,$466.W
	RTE
RESET	MOVE	#$2700,SR
	LEA	$400.W,SP
	MOVE.L	#$07078080,$FFFF8200.W
	MOVEQ	#0,D0
	LEA	$FFFF8240.W,A0
	MOVE.L	d0,(A0)+
	MOVE.L	d0,(A0)+
	MOVE.L	d0,(A0)+
	MOVE.L	d0,(A0)+
	MOVE.L	d0,(A0)+
	MOVE.L	d0,(A0)+
	MOVE.L	d0,(A0)+
	MOVE.L	d0,(A0)+

	MOVE.L	#SECONDVBL,$70.W
	MOVE	#$2300,SR
	CLR	$466.W
.SYNC	TST	$466.W
	BEQ.S	.SYNC
	CLR.B	$FFFF8260.W
	MOVE.B	#2,$FFFF820A.W

	MOVEQ	#0,D0
	MOVE.L	#FINRESETDEMO,adload.w

	LEA	FINLOADER\W,A0
	LEA	$80000,A1
.CLS	MOVE.L	d0,(A0)+
	CMP.L	A1,A0
	BLO.S	.CLS
	lea	$8000,A1
	lea	RESETDEMO,a0
	lea	FINLOADER,A2
;
;	a0=source
;	a1=destination
;	a2=adresse de d‚but de l'arbre (1026+256 octets)
;
	BSR	decrunch
	LEA	$8000,A3
	BSR	RELOGEUR
	CLR.L	$426.W
	CLR	$FFFF8242.W
	MOVE.L	#$0E0E0707,$FFFF8800.W
	jmp	$8000

RESETDEMO
	INCBIN	NORTH.CMP
FINRESETDEMO
	IFEQ	DEBUG
DEBUGGER
	INCBIN	DEBUGGER.BIN
	ENDC
FINLOADER:
