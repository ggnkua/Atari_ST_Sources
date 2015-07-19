	OPT	O+,OW2-		;,D+
	OUTPUT	PRG1.PRG
;
; RESTENT 13 LIGNES RASTER !!!
;
FINAL=0			;0=FINAL
floplock=$42e
loaded=floplock+1

NBBOULES=112
HAUTEUR_LOGO=$38
DISTANCE=$90
NBSINUS=256
VITESSE=3
MUSIC=1			;0=pas de musique,1,2,3
topram=$80000
ecran0=topram-(216*160)
ecran1=ecran0-(232*160)
ramtop=ecran1-15*160	;EVITONS LES BUGS
;
	offset	$140
VITX:		DS.W	1
PTRSCROLL:	DS.L	1
ecran:		DS.L	1
ptbuf:		DS.L	1
num1:		ds.w	1
num2:		ds.w	1
FINSCROLLING:	DS.L	1
	LIST

	NOLIST
	section	text

	ORG	$68000
initscroll:
;	lea	message(pc),a0

	CMP	#2,$4FE.W
	BHS.S	.GOODMESS
	LEA	FUCKMESS(PC),A0
.GOODMESS:

	lea	SCROLLING,A6
	MOVE.L	A6,PTRSCROLL.w

	moveq	#16*7-1,d0
.clr1	clr.b	(a6)+
	dbra	d0,.clr1

.aff1
	clr	d0
	move.b	(a0)+,d0
	bmi.s	.fini

	lea	convert(pc),a1
	moveq	#-2,d2
.conv
	addq	#2,d2
	move.b	(a1)+,d1
	bmi.s	.aff1
	cmp.b	d1,d0
	bne.s	.conv
	lea	fonte(pc),a1
	add	d2,a1

	clr	d7
	move.b	(a1)+,d7
	subq	#1,d7

	clr	d0
	move.b	(a1)+,d0

	lea	fonte+$68(pc),a1
	add	d0,a1
.loop
	move.b	(a1)+,d1
	moveq	#7-1,d0
.lop1
	add.b	d1,d1
	subx	d2,d2
	AND	#4,D2
	move.b	d2,(a6)+
	dbra	d0,.lop1
	dbra	d7,.loop
	rept	7
	clr.b	(a6)+
	endr
	bra.s	.aff1

.fini
	moveq	#16*7-1,d0
.clr2
	clr.b	(a6)+
	dbra	d0,.clr2

	MOVE.L	A6,FINSCROLLING.w

	IFNE	FINAL
	CMP.L	#ramtop,a6
	BLS.S	.OK
	ILLEGAL
.OK
	ENDC

	clr	num1.w
	clr	num2.w
	move.l	#buffer1,ptbuf.w
	move.l	#ecran0,ecran.w
	move	#-2,VITX.w

; RAM ALREADY CLEARED
;	lea	ramtop,a0
;	MOVE	#(topram-ramtop)/4-1,D0
;	MOVEQ	#0,D1
;CLS	MOVE.L	D1,(A0)+
;	DBRA	D0,CLS

	IFNE	MUSIC
	moveq	#1,d0
	lea	musique(pc),a0
	bsr	replay
	ENDC
	MOVE.L	#vbl,$70.W
	RTS
;
vbl:
	MOVEM.L	D0-D7/A0-A6,-(SP)
	movem.l	palette(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w

	TST.b	floplock.w
	BNE.S	.NOSTOP
	MOVE	$FFFF8604.W,D0
	TST.B	D0
	BMI.S	.NOSTOP
	MOVE.L	#$0E0E0707,$FFFF8800.W
	TAS.B	floplock.w		;$80=arret du moteur
.NOSTOP
	IFNE	MUSIC
	BSR	replay+4
	ENDC
	MOVE.L	ecran.w,a0
	MOVE.L	A0,USP
	move.l	A0,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w
;
; 1) effacement minimal de l'‚cran
;
	move.l	ptbuf.w,a1
;
; EFFACEMENT DU LOGO PRECEDENT
;
	ADD	(A1)+,A0
	MOVEQ	#0,D0

	tst.b	loaded.w
	beq	.nologo

	MOVE.L	D0,D1
	MOVE.L	D0,D2
	MOVE.L	D0,D3
	MOVE.L	D0,D4
	MOVE.L	D0,D5
	MOVE.L	D0,D6
	MOVE.L	D0,D7

X	SET	0
	REPT	HAUTEUR_LOGO
	MOVEM.L	D0-D7,X(A0)
X	SET	X+160
	ENDR
.nologo
;
; effacement des boules
;
;	MOVEQ	#0,D0			;D0=0 ICI !!!
;	MOVEQ	#NBBOULES-1,D1
	LEA	RETOUR(PC),A5
	LEA	CODEEFF(PC),A2
	move	num1.w,d1
	beq.s	FINEFF
	subq	#1,d1
MINCLS
	MOVE.L	USP,A6
	ADD	(A1)+,A6
	MOVE	(A1)+,D2
	JMP	(A2,D2.W)
RETOUR:
	DBRA	D1,MINCLS
FINEFF:
;
;
; 2) calcul des points
;
;	move	#$007,$ffff8240.w
;
savd4	equr	d4
savd5	equr	d5
inx	equr	d6
iny	equr	d7
coordx	equr	a1
coordy	equr	a2

	MOVE	ROTX(PC),D0
	LEA	SINUS(PC),A0
	MOVE	(A0,D0.W),D7		;COSINUS
	ADD	#NBSINUS/4*2,D0
	AND	#(NBSINUS-1)*2,D0
	MOVE	(A0,D0.W),D6		;SINUS

	MOVE	ROTX(PC),D0
	CMP	#NBSINUS,D0
	BLO.S	.OK0
	SUB	#NBSINUS*2,D0
.OK0
	ADD	#32+2,D0
	CMP	#32*2+4,D0
	BLO.S	.NOREV0
	CLR	VITX.w
.NOREV0

	cmp.b	#$4b,$fffffc02.w
	bne.s	.nogau
	move	#-2,VITX.w
.nogau
	cmp.b	#$4d,$fffffc02.w
	bne.s	.nodro
	move	#2,VITX.w
.nodro

	MOVE	ROTX(PC),D0
	ADD	VITX.w,D0
	AND	#(NBSINUS-1)*2,D0
	MOVE	D0,ROTX

	CMP	#NBSINUS,D0
	BLO.S	.OK
	SUB	#NBSINUS*2,D0
.OK
	ADD	#32,D0
	CMP	#32*2,D0
	BLO.S	.NOREV
	NEG	VITX.w
.NOREV

	MOVE	#-$408,d5	;premier X
	SUB	AVANCEX(PC),d5
	MOVE	#-$1b0,d4	;premier Y
	MOVE	d5,d3
	MOVE	d4,d2
	MULS	D6,d4
	MULS	D6,d5
	MULS	D7,d3
	MULS	D7,d2
	ADD.L	d3,d4
	SUB.L	d2,d5

	asr.l	#2,d4
	asr.l	#2,d5

	muls	#DISTANCE/4,d6
;	move.l	d6,inx
	muls	#DISTANCE/4,d7
;	move.l	d7,iny

	ADD.L	#(320/2-8)<<16,d4
	neg.l	d5
	ADD.L	#(200/2+15)<<16,d5

	ADD	#DISTANCE/VITESSE,AVANCEX
	CMP	#DISTANCE,AVANCEX
	BNE.S	LB0
	CLR	AVANCEX
LB0:

	MOVE.L	PTRSCROLL.w,A3
	CMP	#VITESSE,CPTREFRESH
	BNE.S	LC3
	ADDQ	#7,A3
	CLR	CPTREFRESH
LC3:	ADDQ	#1,CPTREFRESH

	move.l	ptbuf.w,a0
	addq	#2,a0
	LEA	CODEAFF(PC),A4

CALC	MACRO
	move.l	coordy,d1
	swap	d1		;Y

;	CMP	#200+15-1,d1
	cmp	d3,d1
	BHS.S	.\@
	add	d1,d1

	move.l	coordx,d0
	swap	d0		;X

	MOVEQ	#15,D2
	AND	D0,D2
	EOR	D2,D0
	ASR	#1,D0
	ADD	muls160-CODEAFF(A4,D1.W),D0
	OR.B	(A3)+,D0
	MOVE	D0,(A0)+
	move.l	usp,a6
	ADD	D0,A6
	ADD	D2,D2
	ADD	D2,D2
	MOVE	D2,(A0)+
	LEA	.\@2(PC),A5
	JMP	(A4,D2.W)
.\@	ADDQ	#1,A3
.\@2

	add.l	inx,coordx
	add.l	iny,coordy
	ENDM

CALC2	MACRO

	tst.b	(a3)+
	beq.s	.\@

	move.l	coordy,d1
	swap	d1		;Y

;	CMP	#200+15-1,d1
	cmp	d3,d1
	BHS.S	.\@
	add	d1,d1

	move.l	coordx,d0
	swap	d0		;X

	MOVEQ	#15,D2
	AND	D0,D2
	EOR	D2,D0
	ASR	#1,D0
	ADD	muls160-CODEAFF(A4,D1.W),D0
	addq	#4,d0
	MOVE	D0,(A0)+
	move.l	usp,a6
	ADD	D0,A6
	ADD	D2,D2
	ADD	D2,D2
	MOVE	D2,(A0)+
	LEA	.\@(PC),A5
	JMP	(A4,D2.W)
.\@

	add.l	inx,coordx
	add.l	iny,coordy
	ENDM


;	move.l	d4,savd4
;	move.l	d5,savd5

	move	#200+15-1,d3
	move	#NBBOULES/7,-(SP)

	tst.b	loaded.w
	bne	loop1

loop2
	move.l	savd4,coordx
	move.l	savd5,coordy

	REPT	7
	CALC2
	ENDR

	add.l	iny,savd4
	sub.l	inx,savd5

	subq	#1,(sp)
	bne	loop2
	addq	#2,sp
	bra	endloop
loop1
	move.l	savd4,coordx
	move.l	savd5,coordy

	REPT	7
	CALC
	ENDR

	add.l	iny,savd4
	sub.l	inx,savd5

	subq	#1,(sp)
	bne	loop1
	addq	#2,sp
endloop

	move.l	a0,d0
	sub.l	ptbuf.w,d0
	subq.l	#2,d0
	lsr	#2,d0
	move	d0,num1.w

;	cmp	#NBBOULES,d0
;	bls.s	.ok
;	illegal
;.ok
	CMP.L	FINSCROLLING.w,A3
	BNE.S	LC4
	LEA	SCROLLING+NBBOULES(PC),A3	;le scrolling reboucle
LC4:
	lea	-NBBOULES(a3),A3
	MOVE.L	A3,PTRSCROLL.w
;
; remplissage de la VBL !!!!
;
	MOVE	movey(pc),d0
	add	vity(pc),d0
	move	d0,movey
	cmp	#(200-HAUTEUR_LOGO)*160+64,d0
	blo.s	.good
	neg	vity
.good
	move.l	ptbuf.w,a0
	MOVE	D0,(A0)+

	tst.b	loaded.w
	beq	.nologo

	MOVE.L	USP,A6
	ADD	D0,A6

	INCBIN	MAIN2.COD
.nologo
	eor.l	#ecran0^ecran1,ecran.w
	eor.l	#buffer1^buffer2,ptbuf.w
	move	num1.w,d0
	move	num2.w,num1.w
	move	d0,num2.w

	tst.b	loaded.w
	beq	.nofade
	move.b	fade(pc),d0
	bne	.nofade

	add.b	#$20,fade+1	;une fois toutes les 4 VBLs !!!
	bcc.s	.nofade

	lea	palette(pc),a0
	lea	newpal(pc),a1
	moveq	#16-1,d7
.chpal
	move	(a0),d0
	move	(a1)+,d1

	move	#$700,d2
	move	d2,d3
	and	d0,d2
	and	d1,d3
	cmp	d3,d2
	beq.s	.okr
	bhs.s	.decr
	add	#$100,d0
	bra.s	.okr
.decr
	sub	#$100,d0
.okr
	moveq	#$70,d2
	move	d2,d3
	and	d0,d2
	and	d1,d3
	cmp	d3,d2
	beq.s	.okv
	bhs.s	.decv
	add	#$10,d0
	bra.s	.okv
.decv
	sub	#$10,d0
.okv
	moveq	#$7,d2
	move	d2,d3
	and	d0,d2
	and	d1,d3
	cmp	d3,d2
	beq.s	.okb
	bhs.s	.decb
	addq	#$1,d0
	bra.s	.okb
.decb
	subq	#$1,d0
.okb
	move	d0,(a0)+
	dbra	d7,.chpal

	addq.b	#1,fade+1
	cmp.b	#8,fade+1
	blo.s	.nofade
	st	fade
	move	#3*160,vity
.nofade:
	IFNE	FINAL
	cmp.b	#$f,$fffffc02.w
	bne.s	.nocpu
	move	#$444,$ffff8240.w
.nocpu
	ENDC

	MOVEM.L	(SP)+,D0-D7/A0-A6
	rte

CODEEFF:INCLUDE	EFF6.S
CODEAFF:INCLUDE	NOMASK6.S

	IFNE	MUSIC
replay:	incbin	replay.bin
musique:
	incbin	synter5.mus
	ENDC
;
; LISTE DES TABLEAUX
;
palette:
	DC.W	0
	dcb.w	3,0
;	DC.W	$004,$006,$777		;$70,$70,$70
	DC.W	$440			;$70
	dcb.w	3,$777
;	DC.W	$123,$234,$345
	DC.W	$660			;$70
	dcb.w	3,$777
;	DC.W	$556,$667,$204
	DC.W	$777			;$70
	dcb.w	3,$777
;	DC.W	$315,$426,$777
newpal:
	DC.W	0
	DC.W	$004,$006,$777		;$70,$70,$70
	DC.W	$440			;$70
	DC.W	$012,$234,$345
;	DC.W	$123,$234,$345
	DC.W	$660			;$70
	DC.W	$556,$667,$204
;	DC.W	$556,$667,$204
	DC.W	$777			;$70
	DC.W	$315,$426,$777
;	DC.W	$315,$426,$777
;
; LISTE DES VARIABLES
;
fade:		dc.w	0
vity:		dc.w	0
movey:		dc.w	(200-HAUTEUR_LOGO)/2*160+64
AVANCEX:	DC.W	0
ROTX:		DC.W	0
CPTREFRESH:	DC.W	0
buffer1:	DS.W	NBBOULES*2+1
buffer2:	DS.W	NBBOULES*2+1

SINUS:	INCBIN	SINUS.BIN
fonte:	INCBIN	NEWFNT.BIN

convert:dc.b	"'()&!!-.$0123456789:=+.#? ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	dc.b	-1

FUCKMESS:
	dc.b	"LOADING THE KICK ASS MAIN MENU. CREDITS AND OWNER'S MANUAL ARE TOO "
	dc.b	"LONG TO BE DISPLAYED HERE, SO PRESS HELP WHEN DECRUNCHED FOR USEFUL "
	dc.b	"INFO...",-1
	EVEN

	ifeq	1
message:DC.B	"    NO IT'S NOT ANOTHER INTRODUCTION... "
	DC.B	"    IT'S THE LOADER SCREEN !!!   "
	DC.B	"  CREDITS : CODE BY MCODER, ORIGINAL IDEA "
	DC.B	"BY SPREADPOINT, MUSIC BY MADMAX.  "
	DC.B	"THIS SCROLLING IS NOT PRECALCULATED !!!  "
	DC.B	"PRESS THE LEFT AND RIGHT ARROW KEYS...   "
	DC.B	0
	endc
	EVEN
SCROLLING:
	LIST
