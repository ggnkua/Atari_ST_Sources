;
; nouveau sourceur de d‚cors plus puissant :
;
;	lit directement un fichier IFF quelconque et extrait
;	 les blocs de dessin dispos‚s … certaines coordonn‚es
;
load:	equ	$40000		;adresse de chargement
ecran2:	equ	$60000		;adresse temporaire de d‚compression
ecran:	equ	$80000		;adresse finale de d‚compression
dest:	equ	$60000		;d‚but bitmap … sauver
;
; transfert IFF
;
	lea	load,a5

	move.l	a5,a0
ifbmhd:
	cmp.l	#'BMHD',(A0)+
	bne.s	ifbmhd
	cmp	#320,4(a0)
	bne.s	erreif
	move	6(a0),d0
	move	d0,nblig
	mulu	#160,d0
	move.l	d0,long

ifcmap:
	cmp.l	#'CMAP',(a0)+
	bne.s	ifcmap
	cmp.l	#48,(a0)+
	bne.s	erreif
iffpaer:
	lea	palette(pc),a1
	moveq	#16-1,d2	;nb couleurs !!
setcolif:
	move.b	(a0)+,d1
	asl	#8-5,d1
	and	#$700,d1
	move.b	(a0)+,d0
	lsr	#5-4,d0
	and	#$070,d0
	or	d0,d1
	move.b	(a0)+,d0
	lsr	#5,d0
	and	#7,d0
	or	d0,d1
	move	d1,(a1)+
	dbra	d2,setcolif

ifbody:
	cmp.l	#'BODY',(A5)+
	BNE.S	ifbody
	addq	#4,a5		;NB OCTETS DU BODY (INUTILE)

	bsr	decomp
	bsr	source

	lea	ecran,a0
cp:	tst.l	(a0)+
	beq.s	cp

	moveq	#0,d0		;pas d'erreur
	illegal
erreif:	moveq	#-1,d0
	illegal

;
; routine de d‚compression IFF et PC1 !!!!
;
decomp:
	lea	ecran2,a4
	move.l	long(pc),d1
pcline1:
	moveq	#0,d0
	move.b	(a5)+,d0
	bmi.s	pcline3
pcline4:
	move.b	(a5)+,(a4)+
	subq.l	#1,d1
	dbeq	d0,pcline4
	bne.s	pcline1		;D1<0 ?
	bra.s	IFF6
pcline3:
	neg.b	d0
	move.b	(a5)+,d2
pcline5:
	move.b	d2,(a4)+
	subq.l	#1,d1
	dbeq	d0,pcline5
	bne.s	pcline1		;D1<0 ?
IFF6:
	lea	ecran2,a3
	lea	ecran,a0
	move	nblig(pc),d0
	subq	#1,d0
IFF7:	MOVEQ	#20-1,D1
IFF8:	MOVE	(A3)+,(A0)+
	MOVE	38(A3),(A0)+
	MOVE	78(A3),(A0)+
	MOVE	118(A3),(A0)+
	DBF	D1,IFF8
	lea	160-40(a3),a3
	DBF	D0,IFF7
	rts

source:
	lea	dest,a6		;ptr dest
	moveq	#1,d6		;coord Y
so0:
	moveq	#0,d5		;coord X
so1:
	moveq	#32-1,d4
	add	#32,d6		;on les source … l'envers !!!
car0:
	subq	#1,d6
	moveq	#31,d7
	clr.l	byte0
	clr.l	byte1
	clr.l	byte2
	clr.l	byte3
car1:
	lea	ecran,a0
	move	d6,d0
	mulu	#160,d0
	add.l	d0,a0
	move	d5,d0
	move	d0,d1
	and	#$fff0,d0
	eor	d0,d1
	lsr	#1,d0
	add	d0,a0

	eor	#$f,d1
	moveq	#0,d0
	bset	d1,d0
	move	d0,d2
	not	d2

	addq	#1,d5		;coord X

	move	(a0),d1
	and	d2,(a0)+
	and	d0,d1
	beq.s	n0
	move.l	byte0,d1
	bset	d7,d1
	move.l	d1,byte0
n0:
	move	(a0),d1
	and	d2,(a0)+
	and	d0,d1
	beq.s	n1
	move.l	byte1,d1
	bset	d7,d1
	move.l	d1,byte1
n1:
	move	(a0),d1
	and	d2,(a0)+
	and	d0,d1
	beq.s	n2
	move.l	byte2,d1
	bset	d7,d1
	move.l	d1,byte2
n2:
	move	(a0),d1
	and	d2,(a0)+
	and	d0,d1
	beq.s	n3
	move.l	byte3,d1
	bset	d7,d1
	move.l	d1,byte3
n3:
	dbra	d7,car1

	move	byte0(pc),(a6)+
	move	byte1(pc),(a6)+
	move	byte2(pc),(a6)+
	move	byte3(pc),(a6)+
	move	byte0+2(pc),(a6)+
	move	byte1+2(pc),(a6)+
	move	byte2+2(pc),(a6)+
	move	byte3+2(pc),(a6)+

	sub	#32,d5
	dbra	d4,car0

	lea	-32*16(a6),a0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
comp:
	cmp.l	(a0)+,d1	;on ne prend pas les motifs r‚p‚titifs
	bne.s	pas
	cmp.l	(a0)+,d2
	bne.s	pas
	cmp.l	a6,a0
	bne.s	comp
	lea	-32*16(a6),a6
pas:
	add	#33,d5
	cmp	#320-32,d5
	blo	so1

	move	nblig,d0
	sub	#32,d0
	add	#33,d6
	cmp	d0,d6
	blo	so0
	rts

byte0:	dc.l	0
byte1:	dc.l	0
byte2:	dc.l	0
byte3:	dc.l	0
long:	dc.l	0
nblig:	dc.w	0
palette:
;	ds.w	16
