	OUTPUT	MAINMENU.PRG
;
	OPT	O+
;
FINAL = 0		;0=CODE FINAL

HAUTEUR = 264
ECRAN1 = $80000-160*HAUTEUR
ECRAN0 = ECRAN1-160*HAUTEUR

NBLIG1 = 68
NBLIG2 = 64
NBLIG3 = 68
NBLIGS = NBLIG1+NBLIG2+NBLIG3

CPU	MACRO
	IFNE	FINAL
	tst.b	tabkey+$f.w
	beq.s	.\@
	MOVE	#\1,$FFFF8240.W
.\@
	ENDC
	ENDM

	OFFSET	$7D00
STARTOFF
ECRAN:	DS.L	1
SYNC:	DS.W	1
MUL160	DS.W	HAUTEUR
effbuf1	ds.l	1
effbuf2	ds.l	1
tabkey	ds.b	128
xmouse	ds.w	1
ymouse	ds.w	1
stick0	ds.b	1
stick1	ds.b	1
lastclk	ds.b	1
	even
push1	ds.b	16
push2	ds.b	16

parite:	ds.w	1
ptrtxt1:ds.l	1
ptrtxt2:ds.l	1
largeur1:ds.w	1
largeur2:ds.w	1
hauteur1:ds.w	1
hauteur2:ds.w	1
ptr1	ds.l	1
ptr2	ds.l	1
modulo1	ds.w	1
modulo2	ds.w	1

ENDOFF
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

	LEA	ECRAN0,SP
	MOVEQ	#0,D0
	MOVE.L	D0,A0
	MOVEP.L	D0,$FFFFFA01(A0)
	MOVEP.L	D0,$FFFFFA09(A0)
	MOVEP.L	D0,$FFFFFA11(A0)
	MOVEP.L	D0,$FFFFFA19(A0)

	LEA	STARTOFF.w,A0
	LEA	ENDOFF.w,A1
.CLROFF	CLR	(A0)+
	CMP.L	A1,A0
	BLO.S	.CLROFF

	IFNE	FINAL
	JSR	DEBUGGER
	ENDC

	MOVEQ	#0,D0
	LEA	$FFFF8240.W,A0
	REPT	16/2
	MOVE.L	D0,(A0)+
	ENDR

	CLR.B	$FFFFFA1B.W
	OR.B	#1,$FFFFFA13.W
	OR.B	#1,$FFFFFA07.W
	MOVE.B	#$40,$FFFFFA17.W

	bsr	initkbd

	LEA	MUL160\W,A0
	MOVEQ	#0,D0
	MOVE	#HAUTEUR-1,D1
.MUL160	MOVE	D0,(A0)+
	ADD	#160,D0
	DBRA	D1,.MUL160

	MOVEQ	#1,D0
	BSR	INITMUSIC
	MOVE.L	#RET,$70.W
	MOVE	#$2300,SR

	move	#320/2,xmouse.w
	move	#(200-66)/2,ymouse.w

	LEA	ECRAN0,A0
	MOVE	#($80000-ECRAN0)/8-1,D0
	MOVEQ	#0,D1
BIGCLS:	MOVE.L	D1,(A0)+
	MOVE.L	D1,(A0)+
	DBRA	D0,BIGCLS

	bsr	predecale

	LEA	ECRAN0,A5
	LEA	ECRAN1,A6
	LEA	SCREEN,A4
	MOVE	#NBLIGS,-(SP)
.COPY
	MOVEM.L	(A4)+,D0-D7/A0-A3	;48
	MOVEM.L	D0-D7/A0-A3,(A5)
	MOVEM.L	D0-D7/A0-A3,(A6)
	MOVEM.L	(A4)+,D0-D7/A0-A3	;48+48=96
	MOVEM.L	D0-D7/A0-A3,48(A5)
	MOVEM.L	D0-D7/A0-A3,48(A6)
	MOVEM.L	(A4)+,D0-D7/A0-A3	;48+48+48=144
	MOVEM.L	D0-D7/A0-A3,48*2(A5)
	MOVEM.L	D0-D7/A0-A3,48*2(A6)
	MOVEM.L	(A4)+,D0-D3
	MOVEM.L	D0-D3,48*3(A5)
	MOVEM.L	D0-D3,48*3(A6)
	LEA	160(A5),A5
	LEA	160(A6),A6
	SUBQ	#1,(SP)
	BNE.S	.COPY
	ADDQ	#2,SP

	MOVE.L	#ECRAN0,ECRAN\W
	MOVE.L	#ECRAN1,D0
	LSR	#8,D0
	MOVE.L	D0,$FFFF8200.W

	move.l	#push1,effbuf1\w
	move.l	#push2,effbuf2\w
	moveq	#-1,d0
	move.l	d0,push1.w
	move.l	d0,push2.w

	BSR	INITSCROLL

	CLR	SYNC\W
WAITSYNC
	TST	SYNC\W
	BEQ.S	WAITSYNC
	CLR.B	$FFFF8260.W
	MOVE.B	#2,$FFFF820A.W
;	MOVEM.L	PALETTE,D0-D7
;	MOVEM.L	D0-D7,$FFFF8240.W
	MOVE.L	#VBL,$70.W
BOUCLE
;
	CLR	SYNC\W
	CPU	$700
	BSR	SCROLL
	CPU	$077
	move.l	effbuf1.w,a6
	bsr	efface_sprite
	CPU	$007
	move.l	effbuf1.w,a6
	BSR	affiche_sprite
	CPU	$070

	MOVE.L	ECRAN\W,D0	;CHANGE L'ADRESSE ECRAN
	LSR	#8,D0
	MOVE.L	D0,$FFFF8200.W
	EOR.L	#ECRAN0^ECRAN1,ECRAN\W

	move.l	effbuf1.w,d0
	move.l	effbuf2.w,effbuf1.w
	move.l	d0,effbuf2.w

	IFNE	FINAL
	CLR	$FFFF8240.W
	ENDC

.WW2
	TST	SYNC\W		;12 CYCLES
	BEQ.S	.WW2		;12 CYCLES
	bsr	MOVEKBD
	bsr	TESTCLICK
	BRA.S	BOUCLE

VBL:
	MOVEM.L	D0-D7/A0-A6,-(SP)
	CLR.B	$FFFFFA1B.W
	MOVE.B	#NBLIG1,$FFFFFA21.W
	MOVE.L	#HBL1,$120.W
	MOVE.B	#8,$FFFFFA1B.W
	MOVEM.L	PALETTE(PC),D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W
;	LEA	PAL1(PC),A0
;	LEA	$FFFF8248.W,A1
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE	(A0)+,(A1)+

	moveq	#0,d0

	tst.b	tabkey+$3b.w
	beq.s	.paf1
	moveq	#1,d0
.paf1
	tst.b	tabkey+$3c.w
	beq.s	.paf2
	moveq	#2,d0
.paf2
	tst.b	tabkey+$3d.w
	beq.s	.paf3
	moveq	#3,d0
.paf3
	tst.b	tabkey+$3e.w
	beq.s	.paf4
	moveq	#4,d0
.paf4
	IFEQ	1
	tst.b	tabkey+$3f.w
	beq.s	.paf5
	moveq	#5,d0
.paf5
	tst.b	tabkey+$40.w
	beq.s	.paf6
	moveq	#6,d0
.paf6
	tst.b	tabkey+$41.w
	beq.s	.paf7
	moveq	#7,d0
.paf7
	tst.b	tabkey+$42.w
	beq.s	.paf8
	moveq	#8,d0
.paf8
	tst.b	tabkey+$43.w
	beq.s	.paf9
	moveq	#9,d0
.paf9
	tst.b	tabkey+$44.w
	beq.s	.paf10
	moveq	#10,d0
.paf10
	ENDC

	cmp	lastmusic,d0
	beq.s	.same
	move	d0,lastmusic
	beq.s	.same
	BSR	INITMUSIC
	bra.s	.notsame
.same
	BSR	PLAYMUSIC
.notsame

	MOVEM.L	(SP)+,D0-D7/A0-A6
RET:
	ADDQ	#1,SYNC\W
	RTE
lastmusic:dc.w	0
HBL1:
	PEA	(A0)
	PEA	(A1)
	LEA	PAL2(PC),A0
	LEA	$FFFF8248.W,A1
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE	(A0)+,(A1)+
	CLR.B	$FFFFFA1B.W
	MOVE.L	#HBL2,$120.W
	MOVE.B	#NBLIG2,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	MOVE.L	(SP)+,A1
	MOVE.L	(SP)+,A0
	RTE
HBL2:
	PEA	(A0)
	PEA	(A1)
	LEA	PAL3(PC),A0
	LEA	$FFFF8248.W,A1
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE	(A0)+,(A1)+
	CLR.B	$FFFFFA1B.W
	MOVE.L	#HBL3,$120.W
	MOVE.B	#199-NBLIG1-NBLIG2,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	MOVE.L	(SP)+,A1
	MOVE.L	(SP)+,A0
	RTE
HBL3:
	CLR.B	$FFFFFA1B.W
	MOVE.L	D0,-(SP)
	PEA	(A0)
	LEA	$FFFF8209.W,A0
.1	MOVE.B	(A0),D0
	CMP.B	(A0),D0
	BEQ.S	.1
.2	move.b	(A0),d0
	cmp.b	(A0),d0
	bne.s	.2
	move.b	#0,$ffff820a.w
	MOVE.L	PALFNT(PC),$FFFF8244.W
	MOVE.L	PALFNT+4(PC),$FFFF8248.W
	MOVE.L	PALFNT+8(PC),$FFFF824C.W
;	nop
;	nop
;	nop
;	nop				;4 NOPs oblig‚s !!!
	move.b	#2,$ffff820a.w
	move.l	(sp)+,A0
	move.l	(sp)+,d0
	MOVE.B	#2,$FFFFFA21.W
	MOVE.L	#DEGR1,$120.W
	MOVE.L	PTRDEG,DEGRADONS
	MOVE	#HAUT/2,COMPTEURDEG
	ADDQ.L	#2,PTRDEG
	CMP.L	#FINDEG,PTRDEG
	BLO.S	.NOCYC
	MOVE.L	#DEGRADE,PTRDEG
.NOCYC
	MOVE.B	#8,$FFFFFA1B.W
	rte
COMPTEURDEG:DC.W	0
PTRDEG:	DC.L	DEGRADE
DCW	MACRO
	DC.W	\1,\1,\2,\2,\3,\3,\4,\4,\5,\5,\6,\6,\7,\7
	ENDM
DEGRADE:
	DCW	$700,$710,$720,$730,$740,$750,$760
	DCW	$770,$670,$570,$470,$370,$270,$170
	DCW	$070,$071,$072,$073,$074,$075,$076
	DCW	$077,$067,$057,$047,$037,$027,$017
	DCW	$007,$106,$205,$304,$403,$502,$601
FINDEG
	DCW	$700,$710,$720,$730,$740,$750,$760
	DCW	$770,$670,$570,$470,$370,$270,$170
	DCW	$070,$071,$072,$073,$074,$075,$076
	DCW	$077,$067,$057,$047,$037,$027,$017
	DCW	$007,$106,$205,$304,$403,$502,$601
DEGR1:
DEGRADONS:EQU	*+2
	MOVE	DEGRADE,$FFFF8244.W
	SUBQ	#1,COMPTEURDEG
	BEQ.S	.CLR
	ADDQ.L	#4,DEGRADONS
	RTE
.CLR	CLR.B	$FFFFFA1B.W
	RTE

initkbd
	move.b	#%11,$fffffc00.w
	move.b	#%10+$94,$fffffc00.w
1$
	btst	#1,$fffffc00.w
	beq.s	1$
	move.b	#$1a,$fffffc02.w	;disable joysticks

	move.l	#midikey,veckey\w	;initkey
	or.b	#$40,$fffffa09.w	;autorise interruptions clavier
	or.b	#$40,$fffffa15.w
	lea	tabkey.w,a0
	moveq	#128/4-1,d0
.clrkey	clr.l	(a0)+
	dbra	d0,.clrkey
	rts
;
veckey	equ	$100+$18

midikey:
	move	#$2500,sr
	tst.b	$fffffc00.w
	bpl.s	aciaexit
	move	d0,-(sp)
	clr	d0
	move.b	$fffffc02.w,d0
	addq.b	#8,d0
	bcs.s	pakey
;
; clavier
;
	pea	(a0)
	lea	tabkey-8\w,a0
	bclr	#7,d0
	seq	0(a0,d0.w)
	move.l	(sp)+,a0
	move	(sp)+,d0
	rte
aciaexit
keyfc:
keyfd:
bugge:
	addq	#7,$ffff8240.w
	bra.s	bugge
pakey
;
;+si $f6 (+7 octets)	etat ikbd
;+si $f7 (+5)		position absolue souris
; si $f8 (+2)		position relative souris (+aucun clic)
; si $f9 (+2)		meme chose +clic bouton droit
; si $fa (+2)		meme chose +clic bouton gauche
; si $fb (+2)		meme chose +les 2 clics
;+si $fc (+6)		date interne
;+si $fd (+2)		etat manettes
; si $fe (+1)		manette 0
; si $ff (+1)		manette 1
;
	add	d0,d0
	jmp	fastkeys(pc,d0.w)
fastkeys
	bra.s	keyf8
	bra.s	keyf9
	bra.s	keyfa
	bra.s	keyfb
	bra.s	keyfc
	bra.s	keyfd
	bra.s	keyfe
	bra.s	keyff
keyf8
	move.b	d0,setclk		;d0=0
	move.l	#mouse1,veckey\w
	move	(sp)+,d0
	rte
keyf9
	move.b	#1,setclk		;d0=$10
	move.l	#mouse1,veckey\w
	move	(sp)+,d0
	rte
keyfa	move.b	#2,setclk		;d0=$20
	move.l	#mouse1,veckey\w
	move	(sp)+,d0
	rte
keyfb	move.b	#3,setclk		;d0=$30
	move.l	#mouse1,veckey\w
	move	(sp)+,d0
	rte
keyfe
	move	#stick0,setstick	;d0=$60
	move.l	#joy,veckey\w
	move	(sp)+,d0
	rte
keyff
	move	#stick1,setstick	;d0=$70
	move.l	#joy,veckey\w
	move	(sp)+,d0
	rte

mouse1	move	#$2500,sr
	move.b	$FFFFFC02.w,setx	;gain d'octets
	move.l	#mouse2,veckey\w
	rte
joy	move	#$2500,sr
setstick	equ	*+4
	move.b	$FFFFFC02.w,stick0\w	;code automodifiable
;
; manette: x000yyyy
; x=fire
; yyyy=position manette
;	bit 0=haut si 1
;	bit 1=bas si 1
;	bit 2=gauche si 1
;	bit 3=droite si 1
;
	move.l	#midikey,veckey\w
	rte

mouse2	move	#$2500,sr
	move	d0,-(sp)
	move.b	$FFFFFC02.w,d0
	ext	d0
	add	ymouse\w,d0
	cmp	#NBLIGS,d0
	blo.s	.yok
	sge	d0
	ext	d0
	and	#NBLIGS-1,d0
.yok
	move	d0,ymouse\w

setx	equ	*+3
	move	#0,d0		;code automodifiable
	ext	d0
setclk	equ	*+3
	move.b	#0,lastclk\w	;code automodifiable

	add	xmouse\w,d0
	cmp	#320,d0
	blo.s	.xok
	sge	d0
	ext	d0
	and	#320-1,d0
.xok
	move	d0,xmouse.w

	move	(sp)+,d0
	move.l	#midikey,veckey\w
	rte

;
; affichage d'un sprite clipp‚
;
; entr‚e :
;	d1=coordx
;	d2=coordy
;	d3=largeur
;	d4=hauteur
;
CLIPPE:	MACRO
	move	d1,d5
	and	#$f,d5
	add	d5,d3		;nb pixels de largeur
	move	d5,d0
	sub	d5,d1

	add	d0,d0
	add	d0,d0
	lea	tabspr,a0
	move.l	(a0,d0.w),a0

	add	#15,d3
	and	#$FFF0,d3
	lsr	#1,d3		;d3=nboctets/ligne … afficher

	cmp	#NBLIGS,d2
	blo.s	\@1
	bge.s	\@6

	neg	d2
	sub	d2,d4
	bls.s	\@6
	mulu	d3,d2
	add	d2,a0
	lsr	#1,d2
	add	d2,a0		;+1/2 pour les masques
	moveq	#0,d2
	bra.s	\@2
\@1
	move	d2,d0
	add	d4,d0

	lea	MUL160.w,a1
	add	d2,d2
	move	(a1,d2.w),d2

	sub	#NBLIGS,d0
	bls.s	\@2
	sub	d0,d4
\@2
	asr	#1,d1
	cmp	#160,d1
	blo.s	\@3
	bge.s	\@6
	neg	d1
	sub	d1,d3
	bls.s	\@6
	move	d1,a3		;coefficient de clipping
	lsr	#1,d1
	add	d1,a3		;a3=multiple de 12 !!!
	add	a3,a0		;+1/2 pour mask
	bra.s	\@4
\@3
	sub.l	a3,a3
	add	d1,d2		;offset ‚cran
	add	d3,d1
	sub	#160,d1
	blo.s	\@4
	move	d1,a3
	sub	d1,d3
	lsr	#1,d1
	add	d1,a3		;a3=multiple de 12 !!!
\@4
;
; calcul de la nouvelle adresse de branchement
;
; ici :
;
;	d2=offset ‚cran
;	d3=nb plans*8
;	d4=nb lignes
;
	lea	branche-8(pc),a1
	add	d3,a1

	move.l	(a1)+,a4	;offset affichage
	move.l	(a1)+,d6	;offset effacement

	move.l	d6,(a6)+	;offset effacement
	move	d2,(a6)+	;poke offset ‚cran
	move	d4,(a6)+	;poke nb lignes

	move.l	ECRAN.w,a1
	add	d2,a1		;adresse ‚cran
	move	d4,-(sp)
	jmp	(a4)
\@6	rts
	ENDM

affiche_sprite
	move.l	#-1,(a6)

	move	xmouse.w,d1
	move	ymouse.w,d2

	SUB	#33,D1
	moveq	#66,d3
	moveq	#64,d4

	CLIPPE
;
efface_sprite
	move.l	(a6)+,d0	;offset ‚cran <32000
	bmi.s	effscr1
	move.l	d0,a3		;adresse effacement
	move	(a6)+,d0	;offset ‚cran
	lea	SCREEN,a0	;source
	add	d0,a0
	move.l	ECRAN.w,a1	;dest
	add	d0,a1
	move	(a6)+,-(sp)
	jmp	(a3)
effscr1
	rts
;
;	LA ROUTINE DE SPRITES !!!!
;
; toujours le meme principe...
;
msk	macro
	move.l	(a0)+,\2
	move.l	(a1)+,\1
	and.l	\2,\1
	or.l	(a0)+,\1
	and.l	(a1)+,\2
	or.l	(a0)+,\2
	endm
;
branche
	dc.l	sp16,eff16
	dc.l	sp32,eff32
	dc.l	sp48,eff48
	dc.l	sp64,eff64
	dc.l	sp80,eff80
	dc.l	sp96,eff96
;
; routines de sprite
;
; a0=pointeur en lecture (BITMAP)
; a1=pointeur en ‚criture (ECRAN)
;
sp16					;sprite 16 de large
	msk	d0,d1
	movem.l	d0-d1,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160(a1),a1
	subq	#1,(sp)
	bne.s	sp16
	addq	#2,sp
	rts
sp32					;sprite 32 de large
	msk	d0,d1
	msk	d2,d3
	movem.l	d0-d3,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160(a1),a1
	subq	#1,(sp)
	bne.s	sp32
	addq	#2,sp
	rts
sp48					;sprite 48 de large
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	movem.l	d0-d5,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160(a1),a1
	subq	#1,(sp)
	bne.s	sp48
	addq	#2,sp
	rts
sp64					;sprite 64 de large
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160(a1),a1
	subq	#1,(sp)
	bne.s	sp64
	addq	#2,sp
	rts
sp80					;sprite 80 de large
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	movem.l	d0/d1,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160-32(a1),a1
	subq	#1,(sp)
	bne.s	sp80
	addq	#2,sp
	rts
sp96					;sprite 96 de large
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	msk	d2,d3
	movem.l	d0-d3,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160-32(a1),a1
	subq	#1,(sp)
	bne.s	sp96
	addq	#2,sp
	rts
;
; d0=adresse effacement du sprite
; a0=‚cran source
; a1=‚cran destination
;
lgeff16	equ	12
lgeff32	equ	12
lgeff48	equ	12
lgeff64	equ	12
lgeff80	equ	12
lgeff96	equ	12

eff16
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	lea	160-8(a0),a0
	lea	160-8(a1),a1
	subq	#1,(sp)
	bne.s	eff16
	addq	#2,sp
	rts

eff32
	movem.l	(a0),d0-d3
	movem.l	d0-d3,(a1)
	lea	160(a0),a0
	lea	160(a1),a1
	subq	#1,(sp)
	bne.s	eff32
	addq	#2,sp
	rts

eff48
	movem.l	(a0),d0-d5
	movem.l	d0-d5,(a1)
	lea	160(a0),a0
	lea	160(a1),a1
	subq	#1,(sp)
	bne.s	eff48
	addq	#2,sp
	rts
eff64
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	lea	160(a0),a0
	lea	160(a1),a1
	subq	#1,(sp)
	bne.s	eff64
	addq	#2,sp
	rts
eff80
	movem.l	(a0),d0-d7/a2/a3
	movem.l	d0-d7/a2/a3,(a1)
	lea	160(a0),a0
	lea	160(a1),a1
	subq	#1,(sp)
	bne.s	eff80
	addq	#2,sp
	rts
eff96
	movem.l	(a0),d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,(a1)
	lea	160(a0),a0
	lea	160(a1),a1
	subq	#1,(sp)
	bne.s	eff96
	addq	#2,sp
	rts


;	rsreset

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
off2a = 46	;rs.b	1	;0,1 ou 2=type de son
off2b = 47	;rs.b	1
off2c = 48	;rs.b	1
off2d = 49	;rs.b	1	;volume sonore calcul‚
off2e = 50	;rs.b	1
off3c = 52	;equ	(__RS+1)&-2

INITMUSIC:
	LEA	MUZAK1,A0
	CMP	#1,D0
	BEQ.S	.OK
	SUBQ	#1,D0
	LEA	MUZAK2,A0
.OK
;	MOVEQ	#1,D0
;
; init musique
;
; entr‚e :
;	A0=pointe sur le texte 'COSO'
;	D0=num‚ro de la musique … jouer
;
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
PLAYMUSIC:
	LEA	PSGREG(PC),A6
	TST.B	L812-PSGREG(A6)
	BEQ.S	L160
	TAS	L813-PSGREG(A6)
	BNE.S	L15E
	clr.B	$22(A6)
	clr.B	$26(A6)
	clr.B	$2A(A6)
	MOVEM.L	$1C(A6),D0-D3
	MOVEM.L	D0-D3,$FFFF8800.W
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
	move	D0,$16(A6)
	MOVE.B	D0,$12(A6)
	MOVE.B	D1,$2A(A6)

	MOVEM.L	(A6),D0-D7/A0-A2
	MOVEM.L	D0-D7/A0-A2,$FFFF8800.W
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
	MOVE.B	#$B,$FFFF8800.W
	move.b	(A1)+,$FFFF8802.W
	move.l	#$0C0C0000,$FFFF8800.W
	move.l	#$0D0D0A0A,$FFFF8800.W
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

HAUT	EQU	43		;HAUTEUR SCROLL

SCROLL:
	MOVE.L	#SUPER2,$10.W
	MOVE	#$300,SR

	MOVE.L	ECRAN\W,A7
	LEA	NBLIGS*160+8(A7),A7

X	SET	0
	REPT	(HAUT*160-8)/15/4
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVEM.L	D0-D7/A0-A6,-15*4-8(A7)
X	SET	X+15*4
	ENDR
	MOVEM.L	(A7)+,D0-D7
	MOVEM.L	D0-D7,-8*4-8(A7)
X	SET	X+4*8

	IFNE	X-(HAUT*160-8)
	LIST
	DC.L	X
	DC.L	(43*160-8)-X
	NOLIST
	ENDC

	ILLEGAL
SUPER2:	ADDQ	#6,SP
	bra.s	refresh


INITSCROLL:
	LEA	FONTE,A0
	LEA	FASTFONTE,A1
	moveq	#29-1,d5
MOVEIT:
	MOVE	(A0)+,D6	;X
	MOVE	(A0)+,D7	;Y
	ADDQ	#1,D7

	ADD	#16,D6
	AND	#-16,D6

	MOVE	D6,(A1)+
	MOVE	D7,(A1)+
	LSR	#1,D6
	MULU	D6,D7
	MOVE.L	A0,(A1)+
	ADD.L	D7,A0
	dbra	d5,MOVEIT

	MOVE	#32,(A1)+	;ESPACE=32 PIXELS DE LARGEUR !!!
	CLR	(A1)+
	MOVE.L	A1,(A1)		;N'IMPORTE OU
	clr	parite.w
	lea	texte,a0
	move.l	a0,ptrtxt1.w
	move.l	a0,ptrtxt2.w
	clr	largeur1.w
	clr	largeur2.w
	RTS
refresh:
	not	parite.w
	bpl.s	refresh2
	move.l	ECRAN.W,a6
	lea	NBLIGS*160+152(a6),a6
	move.l	ptrtxt1.w,a0
	bsr	refcol1
	bsr.s	nextcar1
	move.l	ECRAN.W,a6
	lea	NBLIGS*160+152+1(a6),a6
	bsr	refcol1
	bsr.s	nextcar1
	move.l	a0,ptrtxt1.w
	rts
refresh2:
	move.l	ECRAN.W,a6
	lea	NBLIGS*160+152(a6),a6
	move.l	ptrtxt2.w,a0
	bsr.s	nextcar2
	bsr	refcol2
	move.l	ECRAN.W,a6
	lea	NBLIGS*160+152+1(a6),a6
	bsr.s	nextcar2
	bsr	refcol2
	move.l	a0,ptrtxt2.w
	rts
nextcar1:
	subq	#8,largeur1.w
	bhs.s	.ret
	addq	#1,a0
	tst.b	(a0)
	bpl.s	.ok
	lea	texte,a0
.ok
	clr	d0
	move.b	(a0),d0
	bsr.s	convert
	ASL	#3,D0
	lea	FASTFONTE,A1
	ADD	D0,A1
	MOVE	(A1)+,d0
	move	d0,largeur1.w
	lsr	#1,d0
	move	d0,modulo1.w
	move	(a1)+,hauteur1.w
	move.l	(a1)+,ptr1.w
	bra.s	nextcar1
.ret	rts
nextcar2:
	subq	#8,largeur2.w
	bhs.s	.ret
	addq	#1,a0
	tst.b	(a0)
	bpl.s	.ok
	lea	texte,a0
.ok
	clr	d0
	move.b	(a0),d0
	bsr.s	convert
	ASL	#3,D0
	lea	FASTFONTE,A1
	ADD	D0,A1
	MOVE	(A1)+,d0
	move	d0,largeur2.w
	lsr	#1,d0
	move	d0,modulo2.w
	move	(a1)+,hauteur2.w
	move.l	(a1)+,ptr2.w
	bra.s	nextcar2
.ret	rts

convert:
	cmp.b	#'A',d0
	blo.s	.low1
	cmp.b	#'Z',d0
	bhi.s	.low1
	sub	#'A',d0
	rts
.low1
	cmp.b	#'!',d0
	beq.s	.excla
	cmp.b	#'.',d0
	beq.s	.point
	cmp.b	#',',d0
	beq.s	.virg
	moveq	#29,d0
	rts

.excla	move	#26,d0
	rts
.point	moveq	#27,d0
	rts
.virg	moveq	#28,d0
	rts

refcol1:
	bsr	effcol
	move.l	ptr1.w,a1	;source
	move	#HAUT,d0
	sub	hauteur1.w,d0
	mulu	#160,d0
	add	d0,a6		;a6=dest

	move	hauteur1.w,d7
	subq	#1,d7
	bmi.s	.rien
.1
	movep.l	(a1),d0
	movep.l	d0,(a6)
	add	modulo1.w,a1
	lea	160(a6),a6
	dbra	d7,.1
.rien
	move.l	ptr1.w,d0
	addq.l	#1,d0
	btst	#0,d0
	bne.s	.2
	addq.l	#6,d0
.2	move.l	d0,ptr1.w
	rts
refcol2:
	bsr.s	effcol
	move.l	ptr2.w,a1	;source
	move	#HAUT,d0
	sub	hauteur2.w,d0
	mulu	#160,d0
	add	d0,a6		;a6=dest

	move	hauteur2.w,d7
	subq	#1,d7
	bmi.s	.rien
.1
	movep.l	(a1),d0
	movep.l	d0,(a6)
	add	modulo2.w,a1
	lea	160(a6),a6
	dbra	d7,.1
.rien
	move.l	ptr2.w,d0
	addq.l	#1,d0
	btst	#0,d0
	bne.s	.2
	addq.l	#6,d0
.2	move.l	d0,ptr2.w
	rts
effcol
	moveq	#0,d0
x	set	0
	rept	HAUT
	movep.l	d0,x(a6)
x	set	x+160
	endr
	rts

lastdir:dc.w	0
direction:dc.w	0
ptrdir	dc.w	0
MOVEKBD
	clr	direction
	tst.b	tabkey+$39.w
	beq.s	.noclick
	clr.b	tabkey+$39.w
	st	lastclk.w
.noclick
	tst.b	tabkey+$48.w
	beq.s	.noup
	addq	#8,direction	;haut
.noup
	tst.b	tabkey+$50.w
	beq.s	.nodwn
	addq	#4,direction	;bas
.nodwn
	tst.b	tabkey+$4b.w
	beq.s	.noleft
	addq	#2,direction	;gauche
.noleft
	tst.b	tabkey+$4d.w
	beq.s	.norgt
	addq	#1,direction	;gauche
.norgt
	moveq	#8+4,d0
	and	direction,d0
	cmp	#8+4,d0
	bne.s	.nos1
	sub	d0,direction
.nos1
	moveq	#2+1,d0
	and	direction,d0
	cmp	#2+1,d0
	bne.s	.nos2
	sub	d0,direction
.nos2
	move	direction,d0
	beq.s	.zero
	cmp	lastdir,d0
	beq.s	.samedir
.zero	move	d0,lastdir
	clr	ptrdir
.samedir
	cmp	#findir-debdir,ptrdir
	blo.s	.1
	move	#findir-debdir-1,ptrdir
.1
	move	ptrdir,d0
	lea	debdir,a0
	add	d0,a0
	move.b	(a0),d0
	ext	d0

	move	direction,d1
	btst	#3,d1
	beq.s	.no1
	sub	d0,ymouse.w
.no1
	btst	#2,d1
	beq.s	.no2
	add	d0,ymouse.w
.no2
	btst	#1,d1
	beq.s	.no3
	sub	d0,xmouse.w
.no3
	btst	#0,d1
	beq.s	.no4
	add	d0,xmouse.w
.no4
	cmp	#320,xmouse.w
	blo.s	.lowx
	sge	d0
	ext	d0
	and	#320-1,d0
	move	d0,xmouse.w
.lowx
	cmp	#200,ymouse.w
	blo.s	.lowy
	sge	d0
	ext	d0
	and	#200-1,d0
	move	d0,ymouse.w
.lowy
	addq	#1,ptrdir
	rts
debdir:
	dc.b	1,1,1,1,2,2,2,3,2,3,4,3,4
;	dc.b	1,1,1,1,2,2,2,3,2,3,4,3,4,5,4,5,6,5,6,7,6,7,8
findir
	even
TESTCLICK
	TST.B	lastclk.w
	beq.s	.noclick
	clr.b	lastclk.w
	move	xmouse.w,d6
	move	ymouse.w,d7
	lea	collisions,a0
.nocol	move	(a0)+,d0
	bmi.s	.noclick

	movem	(a0)+,d1/d2/d3/d4
	cmp	d1,d6
	blt.s	.nocol
	cmp	d3,d6
	bgt.s	.nocol
	cmp	d2,d7
	blt.s	.nocol
	cmp	d4,d7
	bgt.s	.nocol

	MOVE	D0,$4FE.W
	JMP	$500.W

.noclick:rts
;
; structure :
;	0.W=num‚ro de la d‚mo
;	.W=coordonn‚es
;
collisions:
	dc.w	3,11,101,172,129	;Mad Vision
	dc.w	4,30,159,193,183	;Phenix
	dc.w	5,37,37,145,63		;Fuzion
	dc.w	6,197,36,308,61		;Equinox
	dc.w	7,230,76,285,90		;Ovr
	dc.w	8,200,142,314,161	;Mcoder
	dc.w	9,57,74,203,91		;Hmd
	dc.w	-1
;
; routine efficace de pr‚d‚calage de sprites...
;
; entr‚e :
;	d0=nb sprites … pr‚d‚caler
;	a5=adresse bitmap lecture
;
predecale
	LEA	START2,A4
	lea	sprite,a5
	lea	corps,a6
;
	moveq	#0,d6
1$
	move.l	a6,(a4)+	;poke pointeur
	move.l	a5,a3
	MOVEQ	#$3F,D1			;TAILLE EN Y
2$
	MOVEQ	#($41/16),d7	;TAILLE EN X
	moveq	#0,d4
	moveq	#0,d5
3$
	move	(a3)+,d4
	ror.l	d6,d4
	move	(a3)+,d5
	ror.l	d6,d5

	move	d4,d0
	or	d5,d0
	not	d0
	move	d0,(a6)+
	move	d0,(a6)+
	move	d4,(a6)+
	move	d5,(a6)+
	CLR.l	(a6)+

	clr	d4
	rol.l	d6,d4
	swap	d4
	clr	d5
	rol.l	d6,d5
	swap	d5

	dbra	d7,3$

	cmp	#16-($41&$f),d6		;est-ce que ‡a rajoute un plan ??
	blo.s	5$

	ror.l	d6,d4
	ror.l	d6,d5

	move	d4,d0
	or	d5,d0
	not	d0
	move	d0,(a6)+
	move	d0,(a6)+
	move	d4,(a6)+
	move	d5,(a6)+
	clr.l	(a6)+
5$
	dbra	d1,2$

	addq	#1,d6
	and	#15,d6
	bne.s	1$
	rts
sprite:
	incbin	REDUIT.bin

texte:
	DC.B	"             "
	DC.B	"WELCOME TO THE TRANSBEAUCE MAIN MENU. "
	DC.B	"MOVE YOUR MOUSE AND CLICK TO SELECT ONE OF THE DEMOS. "
	DC.B	"YOU CAN ALSO USE THE ARROW KEYS AND SPACE. "
	DC.B	"PRESS FUNCTION KEYS I TO IV TO CHANGE THE MUSIC. "
	DC.B	"GREETINGS ARE SENT TO EVERYBODY WHO PARTICIPATED TO THIS "
	DC.B	"DEMO PARTY.  "
	DC.B	"CREDITS FOR THIS SCREEN : CODING BY MCODER, "
	DC.B	"GRAPHIX BY THE SERGEANT, THIS FONT BY ALCATRAZ, "
	DC.B	"MUZAX BY MAD MAX...    "
	DC.B	-1
;	dc.b	"          ABCDEFGHIJKLMNOPQRSTUVWXYZ ! , .",-1
	even

	SECTION	DATA
PALETTE:DC.W	$000,$111,$333,$555,$521,$030,$050,$070
	DC.W	$300,$400,$510,$520,$630,$640,$750,$777
;PAL1:	DC.W	$521,$030,$050,$070,$300,$400,$510,$520,$630,$640,$750
PAL2:	DC.W	$521,$030,$050,$070,$202,$313,$424,$005,$027,$147,$772
PAL3:	DC.W	$005,$027,$044,$076,$401,$110,$221,$332,$200,$311,$422

PALFNT:	DC.W	$111,$222,$322,$333,$435,$777
SCREEN:	INCBIN	SCREEN.BIN
FINSCREEN:
DEBUGGER:INCBIN	DEBUGGER.BIN
MUZAK1	INCBIN	THAL6.PAK
MUZAK2	INCBIN	THAL1.PAK
FONTE:	INCBIN	FONTE.SPR
	section	bss
tabspr:
START2:	ds.L	16
corps:
	ds.b	65536
FASTFONTE:
