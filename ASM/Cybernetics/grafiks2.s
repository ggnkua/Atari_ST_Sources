*-------------------------------------------------------------------------*
*									  *
*	GRAFIK SOUND II				- CYBERNETICS 1992 -	  * 
*									  *
*-------------------------------------------------------------------------*

MVOL:	EQU $80
					
LEN:	EQU 250				* 12.5 Khz
FREQ:	EQU 1
INC:	EQU $011DF989
*-------------------------------------------------------------------------*
		opt		o+

graves:		set		10
aigus:		set		6
cpu:		set		0
esc:		set		0
system:		set		0

	ifne	system
	output	e:\code\effects.grx\relaps_f\grafik_s.prg
	else
	output	e:\code\effects.grx\nosystem\grafik_s.inl
	endc

*-------------------------------------------------------------------------*
*	EFFETS:		- Logo Curve					  *
*			- 3D Curve					  *
*			- Color Equalizer				  *
*			- Sonic Plasma					  *
*			- Psyche Vu Meters				  *
*			- Circular curves				  *
*			- Full images					  *
*			- Sonic vectors					  *
*			- Circular echo					  *
*			- Sound valley					  *
*-------------------------------------------------------------------------*
	
	ifne		system
	move.w		#1,-(sp)
	move.l		#fich,-(sp)
	move.w		#61,-(sp)
	trap		#1
	move.w		d0,tch
	
	move.w		#1,-(sp)
	move.w		tch(pc),-(sp)
	move.l		#28,-(sp)
	move.w		#66,-(sp)
	trap		#1

	move.l		#prg,-(sp)
	move.l		#10000,-(sp)
	move.w		tch(pc),-(sp)
	move.w		#63,-(sp)
	trap		#1

	lea		30(sp),sp
	
	clr.l		-(sp)			* Superviseur
	move.w		#32,-(sp)
	trap		#1
	addq.w		#6,sp

	clr.b		$ffff8260.w		* Synchro
	move.b		#2,$ffff820a.w		* Synchro
	endc

	move.l		#buffer_ec,d0		
	clr.b		d0
	move.l		d0,bufferec
	move.l		d0,physb
	move.l		d0,ecran

	ifeq	system
	move.l		d0,a0
	move.w		#74240/4-1,d0
effbss:	clr.l		(a0)+
	dbra.w		d0,effbss
	endc

*---------------------- No System after this

	jsr	initsound

	jsr		muson			* Zik on

	clr.b		$fffffa1b.w		* Init timer B
	bset.b		#0,$fffffa07.w		
	bset.b		#0,$fffffa13.w

	*------------------------*
	* Inits Blitter		 *
	*------------------------*
		
	move.w		#-1,$ffff8a2a.w		* Masque
	move.w		#-1,$ffff8a28.w		* Masque
	move.w		#-1,$ffff8a2c.w		* Masque

	jsr		create4			* Blitter test & autogeneration

	lea		$ffff8240.w,a0		* Met les couleurs … zero
	rept		8
	clr.l		(a0)+
	endr

	move.b		#-1,break

*-------------------------------------------------------------------------*
*  Boucle  Principale							  *
*-------------------------------------------------------------------------*
main:	move.w		#-1,vsync		* Vsynchro
temp:	tst.w		vsync
	bne.s		temp

	ifne		cpu			* Cpu time
	move.w		#4,$ffff8240.w
	endc

	subq.w		#1,change		* On teste si il faut 
	bne.s		nochange		* changer d'effet 
	lea		$ffff8240.w,a0		* Palette … z‚ro
	rept		8		
	clr.l		(a0)+
	endr
	clr.b		$fffffa1b.w		* Timer B off
	clr.l		vbl			* Vbl rout off
	clr.w		init			* Screen Init = False
	lea		prg1,a0			* Base programme +
	cmp.w		#4,$210.w
	bne.s		second
	lea		prg2,a0			* Base programme +
second:	add.w		instruct,a0		* Offset instruction
	move.w		(a0)+,d1		* Instruction: nb effect * 4
	move.w		(a0)+,change		* Nb vbl pour effect
	move.w		d1,effect		* Nb effect note pour appel
	lea		tabinit,a1		
	move.l		(a1,d1.w),a1
	jsr		(a1)			* run instruction: jsr rout init
nochange:

	move.w		effect,d0		* Choix de l'effet & go
	lea		tabeffect,a0
	move.l		(a0,d0.w),a0
	jsr		(a0)

	ifne		cpu			* Cpu time
	clr.w		$ffff8240.w
	endc

	tst.w		exit
	bne.s		fin
	tst.w		$206.w
	beq.s		defile
	cmp.b		#57,tch			* Test touche
	bne		main			* & boucle 
	bra.s		fin
defile: cmp.b		#$62,tch
	bne		main
	move.w		#-1,$206.w
	
	*--------------------------------------------*
	* Reinit & fin 		 		     *
	*--------------------------------------------*

fin:	clr.b		$fffffa1b.w
	clr.l		vbl
	lea		$ffff8240.w,a0
	rept		8
	clr.l		(a0)+	
	endr

	jsr		fadesound
	jsr		musoff			* Zik off
	
	ifne		system
	move.w		#$555,$ffff8246.w
	clr.b		$ffff820a.w		
	clr.w		-(sp)			* Fin
	trap		#1
	else
	illegal
	endc


tch:	dc.w		0
exit:	dc.w		0
*-------------------------------------------------------------------------*
*	EFFET 1:	Curve logo					  *
*-------------------------------------------------------------------------*
curve:	macro
	move.b		(a0)+,d4
	ext.w		d4
	add.w		d4,d4
	move.w		(a2,d4.w),d4
	endm

curvebis:	macro
	move.b		(a0)+,d4
	addq.w		#2,a0
	ext.w		d4
	add.w		d4,d4
	move.w		(a2,d4.w),d4
	endm
*-------------------------------------------------------------------------*	
effect1:	
	move.l		bufferec,a0			* Flip ec
	not.w		flip_ec
	move.w		flip_ec,d0
	and.w		#32000,d0	
	add.w		d0,a0
	move.l		a0,ecran
	move.l		a0,physb
	
	tst.w		init				* INITIALISATION 
	bne		init1mad

	tst.w		param
	bne.s		ok111
	move.w		#5,y1
	move.w		#45,y2
ok111:

	move.l	physb,physb1
	move.w	y1(pc),d0
	mulu.w	#160,d0
	add.l	d0,physb
	move.w	y2(pc),d0
	add.w	#100,d0
	mulu.w	#160,d0
	add.l	d0,physb1

	move.b	physb1+3(pc),$ffff8209.w
	move.b	physb1+2(pc),$ffff8207.w
	move.b	physb1+1(pc),$ffff8205.w

	move.l		#buffer_ec+73256,a1		* Construit la table
	move.l		a1,a2
	moveq.l		#128/4-1,d0
	moveq.l		#0,d1
	move.w		#-160,d2
maketab:rept	4
	move.w		d1,(a1)+		
	move.w		d2,-(a2)
	endr
	add.w		#160,d1
	sub.w		#160,d2
	dbra.w		d0,maketab
	
	lea		img1(pc),a0			* Decompacte image
	move.l		bufferec,a1
	lea		0.w,a2
	move.w		#199,d0
	jsr		decomp	

	lea		32000(a1),a2			* Copie sur les deux ecrans
	move.w		#7999,d0
copy2:	move.l		(a1)+,(a2)+
	dbra.w		d0,copy2

	move.w		#1999,d0	
effend:	clr.l		(a2)+
	dbra.w		d0,effend

	move.l		#vbl1,vbl
	not.w		init				* Init ok
	rts						* Return

init1mad:	

	addq.w		#6,a0				* EFFACAGE 3 EM PLAN AU BLITTER
	lea		$ffff8a20.w,a5	
	move.w		#8,$8a2e-$8a20(a5)		* Increment horizontal dest
	move.w		#4000,$8a36-$8a20(a5)		* Horizontal size
	clr.b		$8a3a-$8a20(a5)			* Mode demi-teinte & combinaison logique
	clr.b		$8a3b-$8a20(a5)			* Mode demi-teinte & combinaison logique
	clr.b		$8a3d-$8a20(a5)			* Mode demi-teinte & combinaison logique
	move.l		a0,$8a32-$8a20(a5)		* Adresse dest
	move.w		#1,$8a38-$8a20(a5)		* Vertical size
	move.b		#%1000000,$8a3c-$8a20(a5)	* Pas de partage de bus
	or.b		#%10000000,$8a3c-$8a20(a5)	* Go

	ifne		cpu
	move.w		#$30,$ffff8240.w
	endc						* TRACE DES COURBES
	
	move.l		samp1,a0			* Adr sample courant
	
	move.l		ecran,a1			* Adr affichage
	lea		160*75+6(a1),a1			* (sur 3em plan)
	lea		100*160(a1),a3			* 
	move.l		#buffer_ec+73256,a2		
	lea		160(a1),a4
	lea		160(a3),a5
	moveq.l		#19,d1				* Longueur courbe

	moveq.l		#-1,d0				* Pr‚chargement registres
	move.w		#%11000000,d0
	move.w		#%00110000,d5
	move.w		#%00001100,d6
	move.w		#%00000011,d7
aff:

var:	set		0
	rept		2
	curvebis
	move.b		d0,var(a1,d4.w)
	move.b		d0,var(a4,d4.w)
	curve
	move.b		d0,var(a3,d4.w)
	move.b		d0,var(a5,d4.w)

	curvebis
	or.b		d5,var(a1,d4.w)
	or.b		d5,var(a4,d4.w)
	curve
	or.b		d5,var(a3,d4.w)
	or.b		d5,var(a5,d4.w)

	curvebis
	or.b		d6,var(a1,d4.w)
	or.b		d6,var(a4,d4.w)
	curve
	or.b		d6,var(a3,d4.w)
	or.b		d6,var(a5,d4.w)

	curvebis
	or.b		d7,var(a1,d4.w)
	or.b		d7,var(a4,d4.w)
	curve
	or.b		d7,var(a3,d4.w)
	or.b		d7,var(a5,d4.w)

var:	set		1
	endr
	
	addq.w		#8,a1
	addq.w		#8,a3
	addq.w		#8,a4
	addq.w		#8,a5
	dbra.w		d1,aff
	
	rts


*-------------------------------------------------------------------------*
*	ROUTINE VBL LOGO CURVE		 				  *
*-------------------------------------------------------------------------*

vbl1:	clr.b	$fffffa1b.w
	move.b	#100,$fffffa21.w
	move.l	#timer1,$120.w
	move.b	#8,$fffffa1b.w
	rts

*-------------------------------------------------------------------------*
*	ROUTINES TIMER B LOGO CURVE	 				  *
*-------------------------------------------------------------------------*

timer1:
	move.b	physb1+3(pc),$ffff8209.w
	move.b	physb1+2(pc),$ffff8207.w
	move.b	physb1+1(pc),$ffff8205.w
	clr.b	$fffffa1b.w

	move.l	d0,-(sp)
	move.l	a0,-(sp)
	move.l	a1,-(sp)
	move.l	physb,physb1
	move.w	y1(pc),d0
	mulu.w	#160,d0
	add.l	d0,physb
	move.w	y2(pc),d0
	add.w	#100,d0
	mulu.w	#160,d0
	add.l	d0,physb1
	
	tst.w	param
	beq.s	fintimer1
	move.w	icy1,d0
	add.w	d0,y1
	cmp.w	#1,y1
	bne.s	ok1111
	neg.w	icy1
ok1111:	cmp.w	#49,y1
	bne.s	ok1112
	neg.w	icy1
ok1112:
	move.w	icy2,d0
	add.w	d0,y2
	cmp.w	#1,y2
	bne.s	ok1113
	neg.w	icy2
ok1113:	cmp.w	#49,y2
	bne.s	ok1114
	neg.w	icy2
ok1114:
	
fintimer1:
	
	lea	img1+2,a0	* Fixe la palette
	lea	$ffff8240.w,a1	
	rept	8
	move.l	(a0)+,(a1)+
	endr
	
	move.l	(sp)+,a1
	move.l	(sp)+,a0
	move.l	(sp)+,d0

	rte
*----------------------- Datas & Buffer Logo Curve
physb1:		dc.l	buffer_ec
icy1:		dc.w	-1
icy2:		dc.w	1
y1:		dc.w	5
y2:		dc.w	45
img1:		incbin	e:\code\effects.grx\grafik_s\images\grafik1.dat
*-------------------------------------------------------------------------*

*-------------------------------------------------------------------------*
*	EFFET 2:	3D Curve 					  *
*-------------------------------------------------------------------------*
effect2:
	move.l		bufferec,a0		*********** Flip ec
	not.w		flip_ec
	move.w		flip_ec,d0
	ext.l		d0
	and.l		#32000+28*160,d0
	add.l		d0,a0
	move.l		a0,ecran
	move.l		a0,physb	
	addq.w		#6,a0			

	tst.w		init			*********** Init
	bne.s		initmad2
	lea		img2(pc),a0		* Decompacte image
	move.l		bufferec,a1
	lea		0.w,a2
	move.w		#199,d0
	jsr		decomp

	move.l		a1,a2
	add.l		#32000+28*160,a2	* Copie sur les deux ecrans
	move.w		#7999,d0
copy3:	move.l		(a1)+,(a2)+
	dbra.w		d0,copy3

	move.l		#vbl2,vbl		

	not.w		init			* Valide l'initialisation

	rts					* Return

initmad2:
						********** EFFECT 2
	* EFFACAGE AU BLITTER
	
	lea		$ffff8a20.w,a5
	move.w		#8,$8a2e-$8a20(a5)	* Increment horizontal dest
	move.w		#4000,$8a36-$8a20(a5)	* Horizontal size
	move.w		#-1,$8a2a-$8a20(a5)	* Masque
	clr.b		$8a3a-$8a20(a5)		* Mode demi-teinte & combinaison logique
	clr.b		$8a3B-$8a20(a5)		* Mode demi-teinte & combinaison logique
	move.l		a0,$8a32-$8a20(a5)	* Adresse dest
	move.w		#1,$8a38-$8a20(a5)	* Vertical size
	move.b		#%1000000,$8a3c-$8a20(a5)	* Go
	or.b		#%10000000,$8a3c-$8a20(a5)	* Go

	ifne		cpu
	move.w		#$30,$ffff8240.w
	endc

	move.l		samp1,a0		* a0: Adresse du buffer sample
	move.l		ecran,a1		* Adresse ecran

	move.w		ic(pc),d0		* Gestion  zoom
	add.w		d0,x
	move.w		x(pc),d1
	cmp.w		#250,d1
	bne.s		ok3
	neg.w		ic	
ok3:	cmp.w		#2,d1
	bne.s		ok4
	neg.w		ic
ok4:	
	move.w		#250,d3			* Adr affichage courbe
	sub.w		d1,d3			* selon zoom
	add.w		#73,d3
	lsr.w		#1,d3
	move.w		d3,d2
	and.w		#15,d2
	and.w		#$fff0,d3
	lsr.w		#1,d3
	add.w		d3,a1

	lea		16000+6(a1),a1		* A1: adresse courbe 1
	move.l		a1,a3			* A3: adresse courbe 2
	move.l		#buffer_ec+73256,a2	* A2: table d'offsets 160 pour affichage
	move.l		a2,a4
	move.w		x(pc),d0		* On modifie la hauteur selon le zoom
	lsr.w		#2,d0
	mulu.w		#160,d0
	add.w		d0,a3
	sub.w		d0,a1

	move.w		#250,d0			* Size Depart
	
	moveq.l		#0,d7			* Init bit tournant
	neg.w		d2
	add.w		#15,d2
	bset.l		d2,d7			* D7: bit tournant

	move.l		#65536,d6
	divu.w		d0,d6
	ext.l		d0
	divu.w		d1,d0			* D0: coef de reduction
	swap		d0
	mulu.w		d0,d6			* D6: taux d'erreur
	swap		d0
	add.w		d0,d0
	moveq.l		#0,d3			* D3: accumulateur
	
	lea		160.w,a5
	lea		160.w,a6
	moveq.l		#127,d2
	move.w		d0,d5
calc2:	move.w		a5,(a2)+
	move.w		a6,-(a4)
	add.w		d6,d3
	bcc.s		ok2_4
	subq.w		#1,d5
ok2_4:	subq.w		#1,d5
	bgt.s		ok2_5
	move.w		d0,d5
	lea		-160(a5),a5		
	lea		160(a6),a6
ok2_5:	dbra.w		d2,calc2
	
	move.l		#buffer_ec+73256,a2
	moveq.l		#0,d3			* D3: accumulateur
	moveq.l		#0,d4			* D4: offset adresse
	moveq.l		#1,d2			* D2: prechargement
	add.w		d0,d0

	ifne	cpu
	move.w	#$300,$ffff8240.w
	endc

aff2:	add.w		d0,d4
	add.w		d6,d3			* tx d'erreur
	dc.w		$6402		
	addq.w		#4,d4	
	move.b		(a0,d4.w),d5
	ext.w		d5
	add.w		d5,d5
	move.w		(a2,d5.w),d5
	or.w		d7,(a1,d5.w)

	move.b		1(a0,d4.w),d5
	ext.w		d5
	add.w		d5,d5
	move.w		(a2,d5.w),d5
	or.w		d7,(a3,d5.w)
	ror.w		d2,d7
	bcc.s		ok2
	addq.w		#8,a1
	addq.w		#8,a3
ok2:	dbra.w		d1,aff2
	
	lea		tableyp,a0
	lea		tablexp,a1
	move.w		x(pc),d0
	lsr.w		#1,d0
	add.w		d0,d0
	add.w		d0,a1
	mulu.w		#20,d0
	add.w		d0,a0

	ifne		cpu
	move.w		#$50,$ffff8240.w
	endc

	* AFFICHAGE GRILLE VERTICALE AU BLITTER

	lea		$ffff8a20.w,a5
	move.w		#2,(a5)				* Inc X source
	move.w		#-38,$8a22-$8a20(a5)		* Inc Y source
	move.l		a0,$8a24-$8a20(a5)		* Adr source
	move.w		#8,$8a2e-$8a20(a5)		* Inc X dest
	move.w		#8,$8a30-$8a20(a5)		* Inc Y dest
	move.l		ecran,a0
	addq.w		#4,a0
	move.l		a0,$8a32-$8a20(a5)		* Adr dest
	move.w		#20,$8a36-$8a20(a5)		* X size
	move.w		#200,$8a38-$8a20(a5)		* Y size
	move.b		#2,$8a3a-$8a20(a5)		* Hog
	move.b		#3,$8a3b-$8a20(a5)		* Combi
	move.b		#%1000000,$8a3c-$8a20(a5)	* Go
	or.b		#%10000000,$8a3c-$8a20(a5)	* Go
	
	ifne		cpu
	move.w		#$30,$ffff8240.w
	endc

	* AFFICHAGE GRILLE HORIZONTALE AU BLITTER

	move.b		#0,$8a3a-$8a20(a5)		* Hog
	move.b		#15,$8a3b-$8a20(a5)		* Combi
	
	move.l		ecran,a4
	lea		16004(a4),a4
	move.w		(a1),d2
	moveq.l		#0,d0
	moveq.l		#0,d1
grillex:	
	lea		(a4,d0.w),a3
	move.w		#1,$8a38-$8a20(a5)		* Y size
	move.l		a3,$8a32-$8a20(a5)		* Adr dest
	move.b		#%1000000,$8a3c-$8a20(a5)	* Go
	or.b		#%10000000,$8a3c-$8a20(a5)	* Go
	
	lea		(a4,d1.w),a3
	move.w		#1,$8a38-$8a20(a5)		* Y size
	move.l		a3,$8a32-$8a20(a5)		* Adr dest
	or.b		#%1000000,$8a3c-$8a20(a5)	* Go
	or.b		#%10000000,$8a3c-$8a20(a5)	* Go
	
	sub.w		d2,d0
	add.w		d2,d1
	cmp.w		#16000,d1
	blt.s		grillex

	rts

*-------------------------------------------------------------------------*
*	ROUTINE VBL 3D CURVES		 				  *
*-------------------------------------------------------------------------*

vbl2:	move.w		x(pc),d5		* Palette
	lsr.w		#4,d5
	add.w		d5,d5
	lea		pal1(pc),a4		* pointe sur couleur grille
	add.w		d5,a4			
	lea		$ffff8240.w,a2		* registres shifter
	move.w		(a4),16(a2)
	move.w		(a4),18(a2)
	move.w		(a4),20(a2)
	move.w		(a4),22(a2)
	move.w		(a4),24(a2)
	move.w		(a4),26(a2)
	move.w		(a4),28(a2)
	move.w		(a4),30(a2)
	lea		32(a4),a4
	move.w		(a4),10(a2)
	move.w		(a4),12(a2)
	move.w		(a4),14(a2)
	move.w		(a4),8(a2)

	move.w		mode2,d0
	beq.s		palgr
	tst.w		appa
	bne.s		evit
	lea		vox1-2,a0
	add.w		d0,a0
	tst.w		(a0)
	beq.s		palgr
	move.w		#7,appa
evit:
	subq.w		#1,appa
	lea		deg(pc),a3		* Palette image		
	move.w		appa(pc),d0
	mulu.w		#6,d0
	add.w		d0,a3
	move.l		(a3),2(a2)
	move.w		4(a3),6(a2)
	
	rts

palgr:	clr.l		(a2)
	clr.l		4(a2)
	rts

*---------------------------- Datas & variables 3D curves
appa:		dc.w	0
x:		dc.w	100
ic:		dc.w	2
mode2:		dc.w	0
pal1:		incbin	pal2.bin
pal3:		incbin	pal3.bin
deg:		incbin	deg.dat
tablexp:		
var:		set	5*160
		rept	200
		dc.w	var
var:		set	var+160
		endr
tableyp:	incbin		tabley.bin
img2:		incbin		e:\code\effects.grx\grafik_s\images\grafik2.dat
*----------------------------

*-------------------------------------------------------------------------*
*	EFFET 3:	Colors equalizers 				  *
*-------------------------------------------------------------------------*
effect3:

	move.l		bufferec,physb
	tst.w		init
	bne.s		notinit3
	move.l		physb,a0
	moveq.l		#0,d1
	move.w		#15999,d0
eff3:	move.l		d1,(a0)+
	dbra.w		d0,eff3

	move.l		#timer3,$120.w
	move.l		#vbl3,vbl
	not.w		init
	rts
notinit3:

	ifne 	cpu	
	move.w	#$70,$ffff8240.w
	endc

	move.l		bufferec,a1
	add.l		#32000+64*165*2,a1		* Adr affichage barres
	lea		tabcolor+64*165*2,a3
	lea		tabvox(pc),a0			* Table voix
	lea		equa(pc),a5

	move.w		vox1,d1				* Note voix 1
	beq.s		novx1
	bsr.s		aff_rout
novx1:	
	move.w		vox2,d1				* Note voix 2
	beq.s		novx2
	bsr.s		aff_rout
novx2:	
	move.w		vox3,d1				* Note voix 3
	beq.s		novx3
	bsr.s		aff_rout
novx3:	
	move.w		vox4,d1				* Note voix 4
	beq.s		novx4
	bsr.s		aff_rout
novx4:	
	ifne 	cpu	
	move.w	#$50,$ffff8240.w
	endc

	move.w		#128,d2
	moveq.l		#0,d4
	moveq.l		#63,d7
gerebar:	
	tst.w		(a0)
	beq.s		nodes
	add.w		d2,(a0)
nodes:	move.w		(a0)+,d0
	move.w		d4,(a1,d0.w)
	addq.w		#2,a1
	dbra.w		d7,gerebar

	rts

aff_rout:
	sub.w	#$30,d1
	add.w	d1,d1
	move.w	(a5,d1.w),d0
	move.w	#-165*128,(a0,d0.w)	* Elem dans tab voice … -120*128
	lea	(a1,d0.w),a2		* Buffer+32000+120*128 + nb freq elem dans a2
	lea	(a3,d0.w),a4
var:	set	0
	rept	165			* Affiche une barre au max
	move.w	var(a4),var(a2)
var:	set	var-64*2
	endr
	rts

*-------------------------------------------------------------------------*	
*	ROUTINE TIMER B COLOR EQUALIZER					  *
*-------------------------------------------------------------------------*

timer3:
	move.w		#$476,$ffff8240.w

	movem.l		d0-a6,-(sp)			* Sauve registres
	
	move.w		#$2700,sr
	clr.b		$fffffa1b.w			* Stop Timer B 

	rept		95
	nop
	endr
	
	clr.w		$ffff8240.w

	move.l		physb,d0			* Synchro en bout
	add.l		#160*22,d0			* de ligne
	lea		$ffff8203.w,a0
	move.l		#$ffffff,d2
sync1:	movep.l		(a0),d1
	and.l		d2,d1
	cmp.l		d1,d0
	bgt.s		sync1
		
sync2:	move.b		$ffff8209.w,d0			* Synchro en 
	cmp.b		d0,d1				* debut de ligne
	beq.s		sync2

	moveq.l		#16,d1				* Synchro Lsl
	sub.w		d0,d1
	lsl.w		d1,d0	

	rept	30
	nop
	endr
	
	lea		$ffff8a00.w,a5			* Adresse blitter
	move.w		#2,$8a20-$8a00(a5)		* Inc X source
	move.l		bufferec,d0
	add.l		#32000,d0
	move.l		d0,$8a24-$8a00(a5)* Adr source
	clr.w		$8a2e-$8a00(a5)			* Inc X Dest
	move.l		#$ffff8240,$8a32-$8a00(a5)	* Adr dest
	move.w		#64*165,$8a36-$8a00(a5)		* Hori size
	move.w		#1,$8a38-$8a00(a5)		* Vert size
	move.b		#2,$8a3a-$8a00(a5)		* Mode demi teinte
	move.b		#3,$8a3b-$8a00(a5)		* Replace
	clr.b		$8a3d-$8a00(a5)			* No decalage
	move.b		#%1000000,$8a3c-$8a00(a5)	* No partage
	bset.b		#7,$8a3c-$8a00(a5)		* Go !

	move.w		#$476,$ffff8240.w
	rept		90
	nop
	endr
	movem.l		(sp)+,d0-a6			* Restaure registres
	clr.w		$ffff8240.w

	rte

*-------------------------------------------------------------------------*	
*	ROUTINE VBL COLOR EQUALIZER					  *
*-------------------------------------------------------------------------*

vbl3:	clr.b	$fffffa1b.w
	move.b	#16,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rts

*------------------- Datas & variables equalizer
vox1:		dc.w	0
vox2:		dc.w	0
vox3:		dc.w	0
vox4:		dc.w	0
tabvox:		ds.w	64
equa:		incbin	conv.tab
tabcolor:	incbin	colortab.dat
*-------------------------------------------------------------------------*

*-------------------------------------------------------------------------*
*	BLITTER TEST & AUTOCREATION ROUTINE SONIC PLASMA		  *
*-------------------------------------------------------------------------*
	
create4:					* Routine d'autogeneration
	move.l		#ctimerb4,$120.w	
	move.l		#vbl4,vbl
	moveq.l		#2,d0
o4:	move.w		#-1,vsync
temp4:	tst.w		vsync
	bne.s		temp4
	dbra.w		d0,o4
	clr.l		vbl
	clr.b		$fffffa1b.w
	lea		plasma(pc),a1
	move.w		#164,d0
	move.w		synchrotest(pc),d1
	add.w		#48,d1
	asr.w		#4,d1
	subq.w		#1,d1
autogen:
	lea		tramecode(pc),a0
	rept	3
	move.l		(a0)+,(a1)+
	endr
	move.w		d1,d2
g_nop:	move.w		#$4e71,(a1)+
	dbra.w		d2,g_nop

	dbra.w		d0,autogen
	
	move.w		#$4e75,(a1)+

	rts

synchrotest:	dc.w	0	
tramecode:	move.l	(a0)+,d0		* Charge le decalage
		lsl.w	d0,d0			* Decalage 0/4
		swap	d0			*
		move.w	d0,(a5)			* Inc Y source: deca >=8
		move.w	d6,(a6)			* Vert size
		move.b	d5,(a4)			* No partage & Go

ctimerb4:					* Routine de test blitter
	movem.l		d0-a6,-(sp)		* Sauve registres
	move.w		#$2700,sr
	clr.b		$fffffa1b.w		* Stop Timer B 

	move.l		physb,d0		* Synchro en bout
	add.l		#160*21,d0		* de ligne
	lea		$ffff8203.w,a0
	move.l		#$ffffff,d2
sync3_:	movep.l		(a0),d1
	and.l		d2,d1
	cmp.l		d1,d0
	bgt.s		sync3_

sync4_:	move.b		$ffff8209.w,d0			* Synchro en 
	cmp.b		d0,d1				* debut de ligne
	beq.s		sync4_	

	moveq.l		#16,d1				* Synchro Lsl
	sub.w		d0,d1
	lsl.w		d1,d0	

	moveq.l		#31,d0
nopblc:	dbra.w		d0,nopblc

	move.l		bufferec,$ffff8a24.w		* Adresse source
	lea		plasmatab(pc),a0		* Table plasma (decalages)
	moveq.l		#1,d6				*
	move.b		#%11000000,d5			*
	lea		$ffff8a22.w,a5			* Adresse Inc Y Dest blitter
	lea		$ffff8a38.w,a6			* Adresse Vert size blitter	
	lea		$ffff8a3c.w,a4			* Adresse Run blitter
	moveq.l		#7,d1				* Precharge registres

hori:	set	55
	
	lea	$ffff8209.w,a2
	move.b	(a2),d7
plasma_:	
	move.l	(a0)+,d0		* Charge le decalage
	lsl.w	d0,d0			* Decalage 0/4
	swap	d0			*
	move.w	d0,(a5)			* Inc Y source: deca >=8
	move.w	d6,(a6)			* Vert size
	move.b	d5,(a4)			* No partage & Go
	dbra.w	d1,plasma_		*

	sub.b	(a2),d7

	ext.w	d7
	move.w	d7,synchrotest
	
	movem.l		(sp)+,d0-a6	* Sauve registres
	
	rte

*-------------------------------------------------------------------------*
*	EFFECT 4 : SONIC PLASMA						  *
*-------------------------------------------------------------------------*

effect4:
	tst.w	init			* INIT
	bne.s	initmad4
	move.l	bufferec,a1
	move.l	a1,physb
	lea	32000(a1),a0
	lea	tabcolor(pc),a2
		
	move.w	#165,d0
plasminit:
	lea	128(a2),a2
	move.l	a2,a3
	moveq.l	#63,d1
copyx1:	move.w	-(a3),(a0)+
	dbra.w	d1,copyx1
	addq.w	#2,a3
	moveq.l	#63,d1
copyx2:	move.w	(a3)+,(a0)+
	dbra.w	d1,copyx2
	dbra.w	d0,plasminit
		
	moveq.l	#0,d1
	move.w	#7999,d0
eff4:	move.l	d1,(a1)+
	dbra.w	d0,eff4
	move.l	#timerb4,$120.w	
	move.l	#vbl4,vbl
	clr.w	voice_1
	clr.w	voice_2
	clr.w	voice_3
	clr.w	voice_4
	not.w	init
	rts
initmad4:

	tst.w	vox1
	beq.s	novoice1
	move.w	#31,voice_1		
novoice1:	
	tst.w	vox2
	beq.s	novoice2
	move.w	#31,voice_2		
novoice2:	
	tst.w	vox3
	beq.s	novoice3
	move.w	#31,voice_3
novoice3:	
	tst.w	vox4
	beq.s	novoice4
	move.w	#31,voice_4
novoice4:	

	tst.w	voice_1
	ble.s	okv1
	subq.w	#1,voice_1
okv1:	tst.w	voice_2
	ble.s	okv2
	subq.w	#1,voice_2
okv2:	tst.w	voice_3
	ble.s	okv3
	subq.w	#1,voice_3
okv3:	tst.w	voice_4
	ble.s	okv4
	subq.w	#1,voice_4
okv4:					* Gestion d‚calages dans plasma
	
	lea	plasmatab(pc),a0	
	lea	plasmacurve(pc),a1
	lea	voice_1(pc),a2
	
	moveq.l	#3,d7
makepl:	move.w	(a2)+,d0
	mulu.w	#168,d0
	lea	(a1,d0.w),a3
	rept	42
	move.l	(a3)+,(a0)+
	endr
	dbra.w	d7,makepl
	
	rts
*------------------------------*
voice_1:		dc.w	0
voice_2:		dc.w	0
voice_3:		dc.w	0
voice_4:		dc.w	0
plasmacurve:		incbin	"plasmacb.dat"

*-------------------------------------------------------------------------*	
*	ROUTINE TIMER B SONIC PLASMA					  *
*-------------------------------------------------------------------------*
timerb4:
	movem.l		d0-a6,-(sp)			* Sauve registres
	move.w		#$2700,sr
	clr.b		$fffffa1b.w			* Stop Timer B 

	move.l		physb,d0			* Synchro en bout
	add.l		#160*21,d0			* de ligne
	lea		$ffff8203.w,a0
	move.l		#$ffffff,d2
sync3:	movep.l		(a0),d1
	and.l		d2,d1
	cmp.l		d1,d0
	bgt.s		sync3

	rept	10
	nop
	endr
	move.w		#$476,$ffff8240.w
		
sync4:	move.b		$ffff8209.w,d0			* Synchro en 
	cmp.b		d0,d1				* debut de ligne
	beq.s		sync4	

	moveq.l		#16,d1				* Synchro Lsl
	sub.w		d0,d1
	lsl.w		d1,d0	

	move.l		bufferec,a0
	lea		32000(a0),a0
	move.l		a0,$ffff8a24.w			* Adresse source
	lea		plasmatab(pc),a0		* Table plasma (decalages)
	moveq.l		#1,d6
	move.b		#%11000000,d5
	lea		$ffff8a22.w,a5			* Adresse Inc Y Dest blitter
	lea		$ffff8a38.w,a6			* Adresse Vert size blitter	
	lea		$ffff8a3c.w,a4			* Adresse Run blitter
	move.w		#164,d1				* Precharge registres

	rept		39
	nop
	endr

hori:	set	55
	
	tst.w	mega
	bsr	plasma

ret:	move.w		#$476,$ffff8240.w
	rept	90
	nop
	endr
	movem.l		(sp)+,d0-a6	* Restaure registres
	clr.w		$ffff8240.w

	rte

plasma:	ds.b	3300

	rts
*-------------------------------------------------------------------------*	
*	ROUTINE VBL SONIC PLASMA					  *
*-------------------------------------------------------------------------*

vbl4:	clr.b	$fffffa1b.w
	move.b	#16,$fffffa21.w
	move.b	#8,$fffffa1b.w

	lea		$ffff8a00.w,a5			* Adresse blitter
	move.w		#2,$8a20-$8a00(a5)		* Inc X source
	clr.w		$8a2e-$8a00(a5)			* Inc X Dest
	clr.w		$8a30-$8a00(a5)			* Inc Y Dest
	move.b		#2,$8a3a-$8a00(a5)		* Mode demi teinte
	move.b		#3,$8a3b-$8a00(a5)		* Replace
	clr.b		$8a3d-$8a00(a5)			* No decalage
	move.w		#hori,$8a36-$8a00(a5)		* Hori size
	move.l		#$ffff8240,$8a32-$8a00(a5)	* Adr dest

	rts
*------------------- Datas & variables plasma
plasmatab:	rept	168
		dc.w	-(hori-1)*2+256
		dc.w	4
		endr
*-------------------------------------------------------------------------*

*-------------------------------------------------------------------------*
*	EFFET 5:	Psyche Vu Meters 				  *
*-------------------------------------------------------------------------*

effect5:
	move.l	bufferec,a0

	tst.w	init
	bne.s	initmad5
	move.l	a0,ecran
	move.l	a0,physb	
	moveq.l	#0,d0
	move.w	#15999,d1
eff5_1:	move.l	d0,(a0)+
	dbra.w	d1,eff5_1	
	clr.l	voice
	clr.l	voice+4
	move.l	#vbl5,vbl
	not.w	init
	rts
initmad5:

	lea		$ffff8a00.w,a6			* Adresse blitter
	move.w		#2,$8a20-$8a00(a6)		* Inc X source
	move.w		#122,$8a22-$8a00(a6)		* Inc Y Dest
	move.w		#2,$8a2e-$8a00(a6)		* Inc X Dest
	move.w		#122,$8a30-$8a00(a6)		* Inc Y Dest
	clr.b		$8a3d-$8a00(a6)			* No decalage
	move.w		#20,$8a36-$8a00(a6)		* Hori size
	
	lea		20*160(a0),a0	
	lea		vox1,a1
	lea		voice(pc),a2
	lea		crystalm(pc),a3
	moveq.l		#3,d0
equafish:
	tst.w		(a1)+
	beq.s		novoice
	move.b		#2,$8a3a-$8a00(a6)	* Mode demi teinte
	move.b		#3,$8a3b-$8a00(a6)	* Replace
	move.w		#160,$8a38-$8a00(a6)	* Vert size
	move.w		#162/2,(a2)+		*
	move.l		a3,$8a24-$8a00(a6)	* Adr source
	move.l		a0,$8a32-$8a00(a6)	* Adr dest
	move.b		#%11000000,$8a3c-$8a00(a6) * No partage & go
	bra.s		noeffish
novoice:
	move.w		(a2)+,d1
	ble.s		noeffish
	clr.b		$8a3a-$8a00(a6)		* Mode demi teinte
	clr.b		$8a3b-$8a00(a6)		* '0' bits
	subq.w		#1,d1
	move.w		d1,-2(a2)
	mulu.w		#160,d1
	lea		(a0,d1.w),a4
	lea		16000-20*160(a4),a4
	move.l		a4,$8a32-$8a00(a6)	* Adr dest
	move.w		#1,$8a38-$8a00(a6)	* Vert size
	move.b		#%11000000,$8a3c-$8a00(a6) * No partage & go
	neg.w		d1
	lea		(a0,d1.w),a4
	lea		16000-20*160(a4),a4
	move.l		a4,$8a32-$8a00(a6)	* Adr dest
	move.w		#1,$8a38-$8a00(a6)	* Vert size
	move.b		#%11000000,$8a3c-$8a00(a6) * No partage & go
noeffish:
	lea		40(a0),a0
	lea		40(a3),a3
	
	dbra.w		d0,equafish

	rts

*-------------------------------------------------------------------------*
*	VBL	Psyche Vu Meters 				  	  *
*-------------------------------------------------------------------------*

vbl5:		addq.w	#2,poscycle
		cmp.w	#30*6,poscycle
		bne.s	okcol
		clr.w	poscycle
okcol:		move.w	poscycle(pc),d0
		lea	$ffff8242.w,a1
		lea	cycling(pc,d0.w),a0
		rept	7
		move.l	(a0)+,(a1)+
		endr
		move.w	(a0)+,(a1)+
 		rts

*------------------- Datas & variables plasma
poscycle:	dc.w	0
cycling:	incbin	e:\code\effects.grx\grafik_s\cycling.dat
crystalm:	incbin	optique2.dat
voice:		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
*-------------------------------------------------------------------------*

*-------------------------------------------------------------------------*
*	EFFET 6:	Circle curves	 				  *
*-------------------------------------------------------------------------*

effect6:
	move.l		bufferec,a0		*********** Flip ec
	not.w		flip_ec
	move.w		flip_ec,d0
	ext.l		d0
	and.l		#32000,d0
	add.l		d0,a0
	move.l		a0,ecran
	move.l		a0,physb	
	addq.w		#6,a0			

	tst.w		init			*********** INIT
	bne.s		init6mad

	lea		img3(pc),a0
	move.l		bufferec,a1		
	lea		0.w,a2
	move.w		#199,d0
	jsr		decomp

	move.w		#7999,d0
	lea		32000(a1),a2
aff6_1:	move.l		(a1)+,(a2)+
	dbra.w		d0,aff6_1

	lea		img3+2(pc),a0
	lea		$ffff8240.w,a1
	moveq.l		#7,d0
pal6_1:	move.l		(a0)+,(a1)+
	dbra.w		d0,pal6_1

	not.w		init
	rts
init6mad:

	lea		$ffff8a20.w,a5		********** EFFACAGE BLITTER
	move.w		#8,$8a2e-$8a20(a5)	* Increment horizontal dest
	move.w		#4000,$8a36-$8a20(a5)	* Horizontal size
	move.w		#-1,$8a2a-$8a20(a5)	* Masque
	clr.b		$8a3a-$8a20(a5)		* Mode demi-teinte & combinaison logique
	clr.b		$8a3B-$8a20(a5)		* Mode demi-teinte & combinaison logique
	move.l		a0,$8a32-$8a20(a5)	* Adresse dest
	move.w		#1,$8a38-$8a20(a5)	* Vertical size
	move.b		#%11000000,$8a3c-$8a20(a5)	* Go

	ifne	cpu
	move.w	#$40,$ffff8240.w
	endc
	
	move.l		samp1,a1		* Pointe sur sample
	lea		offdat+32(pc),a2
	lea		bitdat+16(pc),a6	* Pointe sur table 2
	move.l		a0,a3			* Adresse ecran dans A3
	move.w		#249,d0			* Longueur sample
	move.w		#$fffe,d4		* Prechargements
	moveq.l		#2,d5
	moveq.l		#1,d6
	lea		80(a3),a5
	
affcircle:
	move.b		(a1),d1			* Selon sample
	ext.w		d1
	asr.w		d5,d1
	and.w		d4,d1
	move.w		(a2,d1.w),d3		* va chercher pos & bitmap point
	asr.w		d6,d1
	move.b		(a6,d1.w),d2
	or.b		d2,(a3,d3.w)		* Affiche point

	move.w		(a1)+,d1		* Selon sample
	ext.w		d1
	asr.w		d5,d1
	and.w		d4,d1
	move.w		(a2,d1.w),d3		* va chercher pos & bitmap point
	asr.w		d6,d1
	move.b		(a6,d1.w),d2
	or.b		d2,(a5,d3.w)		* Affiche point

	lea		32*2(a2),a2
	lea		32(a6),a6
	addq.w		#2,a1

	dbra.w		d0,affcircle

	rts

*------------------- Datas & variables circular curves
offdat:		incbin	e:\code\effects.grx\grafik_s\effect61.dat
bitdat:		incbin	e:\code\effects.grx\grafik_s\effect62.dat
img3:		incbin	e:\code\effects.grx\grafik_s\images\equascr.dat
		even
*-------------------------------------------------------------------------*

*-------------------------------------------------------------------------*
*	EFFET 7:	Full images 					  *
*-------------------------------------------------------------------------*

effect7:
	move.l	bufferec,physb
	
	tst.w	init
	bne.s	initmad7	

	move.w	param,d7
	add.w	d7,d7
	add.w	d7,d7
	lea	overimg(pc),a0
	move.l	(a0,d7.w),a0
	move.l	bufferec,a1
	lea	0.w,a2
	move.w	#230+48/4-1,d0
eff71:	clr.l	(a1)+
	dbra.w	d0,eff71
	move.w	#199,d0	
	jsr	decomp2	
	move.l	#vbl7,vbl	
	not.w	init
initmad7:
	
	rts


vbl7:	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.l 	#timer7,$120.w
	move.b	#8,$fffffa1b.w
	rts

timer7:	
	movem.l	a0-a1/d0-d2,-(sp)
	move.w	#$2700,sr
	clr.b	$fffffa1b.w				* Stop Timer B 

	move.l	physb,d0				* Synchro en bout
	add.l	#160*2,d0				* de ligne
	lea	$ffff8203.w,a0
	move.l	#$ffffff,d2
sync73:	movep.l	(a0),d1
	and.l	d2,d1
	cmp.l	d1,d0
	bgt.s	sync73

	rept	10
	nop
	endr

	move.w		#$476,$ffff8240.w
		
sync74:	move.b		$ffff8209.w,d0			* Synchro en 
	cmp.b		d0,d1				* debut de ligne
	beq.s		sync74	

	moveq.l		#16,d1				* Synchro Lsl
	sub.w		d0,d1
	lsl.w		d1,d0	
	
	lea	$ffff820a.w,a0	; Overscan haut registre synchro ecran
	lea	$ffff8260.w,a1	; registre resolution
	moveq.l	#0,d0		; Prepare le 60 Hz
	moveq.l	#2,d1		; Prepare le 50 Hz

	rept	41+14
	nop
	endr
		
	move.b	d0,(a0)
	move.b	d1,(a0)
	
	rept	13
	nop
	endr

	move.b	d1,(a1)
	nop
	move.b	d0,(a1)

	rept	12-4
	nop
	endr

	move.w	#0,$ffff8240.w
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)

	nop	
	move.w	#196,d2

full1:
	rept	86
	nop
	endr
	
	move.b	d0,(a0)
	move.b	d1,(a0)
	
	rept	13
	nop
	endr
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	
	rept	12
	nop
	endr
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	
	dbra.w	d2,full1

	rept	86
	nop
	endr
	
	move.b	d0,(a0)
	move.b	d1,(a0)
	
	rept	13
	nop
	endr
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	
	rept	12-4  
	nop
	endr

	move.w	#$476,$8240-$820a(a0)
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)

	lea	$ffff8242.w,a1
 	move.w	param,d7
	add.w	d7,d7
	add.w	d7,d7
	lea	overimg(pc),a0
	move.l	(a0,d7.w),a0
 	lea	4(a0),a0
	rept	7
	move.l	(a0)+,(a1)+
	endr	
	move.w	(a0)+,(a1)+
	movem.l	(sp)+,a0-a1/d0-d2
	rept	50
	nop
	endr

	clr.w	$ffff8240.w

	rte

*------------------- Datas & full images
overimg:	dc.l	overimg1
		dc.l	overimg2
overimg1	incbin	e:\code\effects.grx\grafik_s\images\logo1.dat
		even
overimg2:	incbin	e:\code\effects.grx\grafik_s\images\logo2.dat
		even
*-------------------------------------------------------------------------*

*-------------------------------------------------------------------------*
*	EFFET 8:	Sonic Vectors 					  *
*-------------------------------------------------------------------------*
	
ORIGINE_X	EQU (320/2)	* -> 160
ORIGINE_Y	EQU (200/2)	* -> 100

TYPE_ASM 	EQU 0	* 0=SOUS ASMONE / 1= POUR MEGADEMO
TIME_VBL 	EQU 1	* VISUALISER TEMPS MACHINE 0=OFF / 1=ON
TRACKER	EQU 0

CLIP_X1	EQU 0
CLIP_Y1	EQU 0
CLIP_X2	EQU 319
CLIP_Y2	EQU 199
*******************************************************************************

effect8:	
	move.l		bufferec,a0		*********** Flip ec
	not.w		flip_ec
	move.w		flip_ec,d0
	ext.l		d0
	and.l		#32000,d0
	add.l		d0,a0
	move.l		a0,ecran
	move.l		a0,physb	

	tst.w		init
	bne		initmad8
	lea		linefond+32(pc),a0
	move.l		bufferec,a1
	lea		32000(a1),a2
	move.w		#3999,d0
copy81:	move.l		(a0),(a1)+
	move.l		(a0)+,(a2)+
	dbra.w		d0,copy81
	move.w		#1999,d0
copy81b:move.l		-(a0),d1
	move.l		-(a0),d2
	move.l		d2,(a1)+
	move.l		d2,(a2)+
	move.l		d1,(a1)+
	move.l		d1,(a2)+
	dbra.w		d0,copy81b
	lea		linefond(pc),a0
	lea		$ffff8240.w,a1
	rept		8
	move.l		(a0)+,(a1)+
	endr	
	move.w		param,d0
	lsl.w		#3,d0
	lea		tabobject(pc),a0
	move.L		(a0,d0.W),object
	move.L		4(a0,d0.W),object+4
	addq.w		#1,param
	cmp.w		#9,param
	bne.s		okob
	clr.w		param
okob:	not.w		init
	rts
initmad8:

  *-----* EFFACEMENT DU PLAN AVEC LE BLITTER *-----*

	MOVE.L	ECRAN,$FFFF8A32.W
	*ADDQ.w	#6,$FFFF8A32.W
	MOVE.W	#8,$FFFF8A2E.W
	MOVE.W	#4000,$FFFF8A36.W
	MOVE.W	#1,$FFFF8A38.W
	MOVE.B	#0,$FFFF8A3A.W
	MOVE.B	#0,$FFFF8A3B.W
	BSET.B	#6,$FFFF8A3C.W
	BSET.B	#7,$FFFF8A3C.W		

	ifne	cpu
	move.w	#$70,$ffff8240.w
	endc
	
	*-----* *-----*

	BSR	CALCULE

	LEA	X_ANGLE(PC),A0		* ROTATION X
	MOVE.W	SPEED_X(PC),D0
	ADD.W	D0,(A0)
	CMPI.W	#720,(A0)
	BNE.S	.OL1
	CLR.W	(A0)
.OL1	MOVE.W	SPEED_Y(PC),D0
	ADD.W	D0,2(A0)			* ROTATION Y
	CMPI.W	#720,2(A0)
	BNE.S	.OL2
	CLR.W	2(A0)
.OL2	MOVE.W	SPEED_Z(PC),D0
	ADD.W	D0,4(A0)			* ROTATION Z
	CMPI.W	#720,4(A0)
	BNE.S	.OL3
	CLR.W	4(A0)

.OL3	*BSR.W	Z_AV			* ANIMATION EN Z !!!

	ifne	cpu
	move.w	#$770,$ffff8240.w
	endc

PASANIM	LEA	COOR(PC),A5
	move.l	object+4(PC),A1
	MOVE.W	(A1)+,D6
					******		
NB_LINE	MOVE.W	(A1)+,D7
	MOVE.W	(A5,D7.W),D0
	MOVE.W	2(A5,D7.W),D1
	MOVE.W	(A1)+,D7
	MOVE.W	0(A5,D7.W),D2
	MOVE.W	2(A5,D7.W),D3

	MOVE.L	ECRAN,A0

	MOVEM.L	D0-D7/A0-A6,-(sp)
	BSR.W	DROITE
	MOVEM.L	(SP)+,D0-D7/A0-A6
	DBF	D6,NB_LINE

	rts

*******************************************************************************

RAY	DC.W 1
SVBL	DC.L 0
AZ1	DC.L 0
AZ2	DC.L 0

*******************************************************************************

SPEED_X	  DC.W 2	* VITESSE POUR LA ROTATION (PAIR)
SPEED_Y     DC.W 2
SPEED_Z	  DC.W 2

	*-----* TRACER UNE DROITE SUR UN PLAN *-----*
	
DROITE  	*-----* CLIPPING SPECIAL RENFROGNEMENT !!! *-----*

*-----* CLIPPING SPECIAL RENFROGNEMENT !!! *-----*
		
	CMPI.W	#CLIP_X1,D0
	BGT.S	.OK_X1
	MOVE.W	#CLIP_X1,D0
.OK_X1	CMPI.W	#CLIP_X2,D0
	BLT.S	.OK_X1B
	MOVE.W	#CLIP_X2,D0
.OK_X1B	CMPI.W	#CLIP_X1,D2
	BGT.S	.OK_X2
	MOVE.W	#CLIP_X1,D2
.OK_X2	CMPI.W	#CLIP_X2,D2
	BLT.S	.OK_X2B
	MOVE.W	#CLIP_X2,D2
.OK_X2B	CMPI.W	#CLIP_Y1,D1
	BGT.S	.OK_Y1
	MOVE.W	#CLIP_Y1,D1
.OK_Y1	CMPI.W	#CLIP_Y2,D1
	BLT.S	.OK_Y1B
	MOVE.W	#CLIP_Y2,D1
.OK_Y1B	CMPI.W	#CLIP_Y1,D3
	BGT.S	.OK_Y2
	MOVE.W	#CLIP_Y1,D3
.OK_Y2	CMPI.W	#CLIP_Y2,D3
	BLT.S	.OK_Y2B
	MOVE.W	#CLIP_Y2,D3
.OK_Y2B	
			
*-------------------------------------------------------------------------*
*
* 	LINE ROUT
*
*-------------------------------------------------------------------------*
*	A0: Adr ecran
*	D0: X1
*	D1: Y1
* 	D2: X2
*	D3: Y2
*----------------------------- CUT HERE ----------------------------------*


	move.w	d2,d4			* Determination routine a appeler
	sub.w	d0,d4			* d4: largeur
	beq	vert			*
	bpl.s	ok			*
	exg.l	d0,d2			*
	exg.l	d1,d3			*
	neg.w	d4			*
ok:	move.w	d3,d5			* 
	lea	160.w,a6
	sub.w	d1,d5			* d5: hauteur
	* beq	hline			*
	bpl.s	okh			*
	neg.w	d5			*	
	lea	-160.w,a6		*
okh:	
	cmp.w	d4,d5			* Dx>Dy => rout1
	beq	diago			* Dx=Dy => diago
	bgt	rout2			* sinon rout2
	
	****** Dx > Dy

	lea	tabley(pc),a1		* Y2*160 + adr affichage
	add.w	d1,d1			*
	add.w	(a1,d1.w),a0		*
					
	lea	tablex-tabley(a1),a1	* (X2 and $fff0)/2 + adr affichage
	add.w	d0,d0			*
	add.w	(a1,d0.w),a0		*
	and.w	#31,d0			* 

	move.l	d5,d1			* Calcul taux d'erreur
	swap	d1			*
	sub.w	d1,d1			* 
	divu.w	d4,d1			* d1: increment dy*65536/dx 

	lea	map-tablex(a1),a1	* calcul saut variable
	lea	loop1(pc),a2		* en entree: depend de l'offset
	move.l	a2,a3			*
	add.w	(a1,d0.w),a2		* pixel

	add.w	d4,d4			* calcul retour variable
	add.w	d0,d4			* selon longueur ligne
	add.w	(a1,d4.w),a3		*
	move.w	(a3),a5			* sauve instruction 
	move.w	#$4e75,(a3)		* et la remplace par rts
					
	moveq.l	#1,d0			* Registres precharges
	moveq.l	#4,d2			* (plus de bit tournant)		
	moveq.l	#8,d3
	moveq.l	#0,d4
	moveq.l	#32,d5
	moveq.l	#64,d6
	moveq.l	#128,d7

	jsr	(a2)			* go
	move.w	a5,(a3)			* restaure instruction ecrasee
					* par rts
	rts				* go

loop1:	
	rept	20

	or.b	d7,(a0)			* Affiche le point
	add.w	d1,d4			* On ajoute le taux d'erreur (dy*65536/dx)
	dc.w	$6402			* Si bit carry => on depasse l'unite (65356)
	add.l	a6,a0			* la mise a zero se fait automatiquement 

	or.b	d6,(a0)			
	add.w	d1,d4			
	dc.w	$6402
	add.l	a6,a0			

	or.b	d5,(a0)			
	add.w	d1,d4			
	dc.w	$6402
	add.l	a6,a0			

	bset.b	d2,(a0)			
	add.w	d1,d4			
	dc.w	$6402
	add.l	a6,a0			

	or.b	d3,(a0)			
	add.w	d1,d4			
	dc.w	$6402
	add.l	a6,a0			

	or.b	d2,(a0)			
	add.w	d1,d4			
	dc.w	$6402
	add.l	a6,a0			

	bset.b	d0,(a0)			
	add.w	d1,d4			
	dc.w	$6402
	add.l	a6,a0			

	or.b	d0,(a0)+		
	add.w	d1,d4			
	dc.w	$6402
	add.l	a6,a0			

	or.b	d7,(a0)			
	add.w	d1,d4			
	dc.w	$6402
	add.l	a6,a0			

	or.b	d6,(a0)			
	add.w	d1,d4			
	dc.w	$6402
	add.l	a6,a0			

	or.b	d5,(a0)			
	add.w	d1,d4			
	dc.w	$6402
	add.l	a6,a0			

	bset.b	d2,(a0)			
	add.w	d1,d4			
	dc.w	$6402
	add.l	a6,a0			

	or.b	d3,(a0)			
	add.w	d1,d4			
	dc.w	$6402
	add.l	a6,a0			

	or.b	d2,(a0)			
	add.w	d1,d4			
	dc.w	$6402
	add.l	a6,a0			

	bset.b	d0,(a0)			
	add.w	d1,d4			
	dc.w	$6402
	add.l	a6,a0			

	or.b	d0,(a0)			
	add.w	d1,d4			
	dc.w	$6402
	add.l	a6,a0			 

	addq.w	#7,a0
	
	endr
	
	**************	DY > DX

rout2:	
	lea	tabley(pc),a1		* Y2*160 + adr affichage
	add.w	d3,d3			*
	add.w	(a1,d3.w),a0		*
					
	lea	tablex2-tabley(a1),a1	* (X2 and $fff0)/2 + adr affichage
	moveq.l	#15,d6			*
	sub.w	d2,d6			*
	add.w	d2,d2			*
	add.w	(a1,d2.w),a0		*
	and.w	#15,d6			*
	moveq.l	#0,d0			*
	bset.l	d6,d0			* Init bit tournant

	move.w	d4,d1			* Calcul taux d'erreur
	swap	d1			*
	sub.w	d1,d1			* 
	divu.w	d5,d1			* d1: increment dy*65536/dx 

	move.w	#200,d2			*
	sub.w	d5,d2			*
	lsl.w	#4,d2			*
	lea	loop2(pc,d2.w),a1	*
	moveq.l	#0,d2			* erreur de depart a zero
	jmp	(a1)			*
 
loop2:	
	rept	200
	or.w	d0,(a0)			* Affichage point
	sub.l	a6,a0			* adr affichage-160 (trace a l'envers)
	add.w	d1,d2			* Incremente le taux d'erreur
	dc.w	$6408			* Si bit carry , taux > 1 unite (65536)
	add.w	d0,d0			* on decale de 1 le bit tournant
	dc.w	$6404			* Si abscisse bit > 15
	subq.w	#8,a0			* adr affichage-8 (trace a l'envers)
	moveq.l	#1,d0
	endr		
	
	rts

	*********** DIAGO 		(non optimisee)

diago:	
	lea	tabley(pc),a1		* Adr affichage + Y * 160
	add.w	d3,d3			*
	add.w	(a1,d3.w),a0		*		

	moveq.l	#15,d6			* 
	sub.w	d2,d6			*
	lea	tablex2-tabley(a1),a1	* Adr affichage + (x2 and $fff0)/2
	add.w	d2,d2			*
	add.w	(a1,d2.w),a0		*
	
	and.w	#15,d6			* Bit tournant
	moveq.l	#0,d4			*
	bset.l	d6,d4			*

tdiago:	or.w	d4,(a0)			* Affiche le point
	sub.l	a6,a0			* Mvt vert
	add.w	d4,d4			* Mvt hori
	bcc.s	lsaut			* Incremente adr si abscisse mod 16 = 0
	subq.w	#8,a0			*
	moveq.l	#1,d4			*
lsaut:
	dbra.w	d5,tdiago		* Longueur

	rts	
	
	*********** VERTLINE	(non optimisee)

vert:	
	cmp.w	d3,d1			* Si Y1>Y2
	bgt.s	vsaut
	exg	d3,d1			* Echange Y1 & Y2
vsaut:
	sub.w	d3,d1			* Hauteur

	add.w	d3,d3			* Y1*160 + adr affichage
	lea	tabley(pc),a1
	add.w	(a1,d3.w),a0

	moveq.l	#15,d0
	sub.w	d2,d0
	lea	tablex2-tabley(a1),a1
	add.w	d2,d2			* (X1 and $fff0)/2 + adr affichage
	add.w	(a1,d2.w),a0

	moveq.l	#0,d4			* Init bit 
	and.w	#15,d0
	bset.l 	d0,d4

	move.w	#160,d3			* Precharge registre
	
lvert:	or.w	d4,(a0)			* Affiche point
	add.w	d3,a0			* Mvt vert
	dbra.w	d1,lvert		* Longueur
	
	rts

	*******************************************
	*	TABLES				  *
	*******************************************


tabley:		* Pour eviter les mulu.w ds le calcul de l'offset y*160
		* sur l'adresse

i:	set	0
	rept	200
	dc.w	i
i:	set 	i+160
	endr
	
tablex:		* Calcul offset adresse selon x en octet

i:	set	0
	rept	20
	dc.w	i,i,i,i,i,i,i,i
i:	set	i+1
	dc.w	i,i,i,i,i,i,i,i
i:	set	i+7
	endr

tablex2:	* Calcul offset adresse selon x en mot

i:	set	0
	rept	20
	dc.w	i,i,i,i,i,i,i,i,i,i,i,i,i,i,i,i
i:	set	i+8
	endr

map:		

i:	set 	0
	rept	20
	dc.w	i,i+8,i+16,i+24,i+32,i+40,i+48,i+56,i+64,i+72,i+80,i+88,i+96,i+104,i+112,i+120
i:	set	i+8*16+2
	endr

*-------------------------------------------------------------------------*
*
*	CIRCLE ROUT
*
*-------------------------------------------------------------------------*
*	D0:	X centre
*	D1:	Y centre
*	D2:	Rayon
*	A0:	ecran
*------------------------------ CUT HERE ---------------------------------*

bitgauche:	macro
		ror.w	d0,d6
		dc.w	$6404
		addq.w	#8,a4
		addq.w	#8,a0
		endm	
bitdroit:	macro
		add.w	d1,d1
		dc.w	$6406
		moveq.l	#1,d1
		subq.w	#8,a5
		subq.w	#8,a1
		endm	

CERCLE:	move.w	d2,d5 			* Delta = r

	lea	tabley,a6
	move.w	d0,d3			* xc And $fff0 + adr Affichage
	and.w	#$fff0,d3
	lsr.w	#1,d3
	add.w	d3,a0

	add.w	d1,d1
	add.w	(a6,d1.w),a0
	
	move.w	d2,d3

	add.w	d3,d3
	move.w	(a6,d3.w),d3
	
	lea	(a0,d3.w),a4
	sub.w	d3,a0	
	move.l	a0,a1
	move.l	a4,a5
	
	and.w	#15,d0			* Init bit tournant
	neg.w	d0
	add.w	#15,d0
	moveq.l	#0,d6
	bset.l	d0,d6
	move.w	d6,d1

	moveq.l	#1,d0
	moveq.l	#-1,d3			* X: d3 = -1
					* Y: d2 = r
deb:	tst.w	d2			* While y>= 0
	bge.s	.ok
	rts
.ok:
	or.w	d6,(a0)			* Affichage
	or.w	d6,(a4)			* Affichage
	or.w	d1,(a1)			* Affichage
	or.w	d1,(a5)			* Affichage

	move.w	d5,d4			* delta: D5
	add.w	d4,d4			* d: D4  	d = delta * 2
	
	bge.s	else			* Si d < 0
	subq.w	#1,d2		
	lea	160(a0),a0			
	lea	160(a1),a1
	lea	-160(a4),a4	
	lea	-160(a5),a5
	add.w	d3,d4			* d = d + x
	bge.s	else1			* Si d < 0
	add.w	d2,d5			* delta = delta + y	
	bra.s	deb
else1:					* Sinon
	addq.w	#1,d3			* Inc x
	bitgauche			
	bitdroit			
	add.w	d2,d5			* 
	sub.w	d3,d5			* delta = delta + y - x
	bra.s	deb
else:					* Sinon
	addq.w	#1,d3			* Inc x
	bitgauche			
	bitdroit
	sub.w	d2,d4			* d = d - y
	blt.s	else2			* Si y >= 0
	sub.w	d3,d5			* delta = delta - x
	bra.s	deb
else2:					* Sinon
	subq.w	#1,d2			* Dec y
	lea	160(a0),a0	
	lea	160(a1),a1
	lea	-160(a4),a4	
	lea	-160(a5),a5
	sub.w	d3,d5			* delta = delta + y - x
	add.w	d2,d5
	bra.s	deb

	
	*-----* *-----*

PONG	DC.W 1
CPT	DC.W 0
	
Z_AV	TST.W	CPT		* COMPTEUR VIDE ?
	BEQ.S	.OK
	SUBQ.W	#1,CPT
	RTS
.OK	LEA	ZDEP(PC),A0
	TST.W	PONG
	BEQ.S	.NN
	ADDI.W	#30,(A0)
	BRA.S	.S
.NN	SUBI.W	#-30,(A0)
	CMPI.W	#-900,(A0)
	BGT.S	.RT
	MOVE.W	#1,PONG
	RTS
.S	TST.W	(A0)
	BLT.B	.RT
	CLR.W	PONG
	MOVE.W	#100,CPT
.RT	RTS

	*-----* PARTIE DES CALCULS TRIGONOMETRIQUES *-----*
					
CALCULE	LEA COS_TAB(PC),A4
	LEA SIN_TAB(PC),A5
	LEA X_ANGLE(PC),A6
	MOVE.W (A6)+,D2	
	MOVE.W (A6)+,D1	
	MOVE.W (A6)+,D0
	MOVE.W 0(A5,D2.W),D5
	MOVE.W 0(A4,D2.W),D4
	MOVE.W 0(A5,D1.W),D3
	MOVE.W 0(A4,D1.W),D2
	MOVE.W 0(A5,D0.W),D1
	MOVE.W 0(A4,D0.W),D0
	LEA VAR_3D(PC),A6
	MOVEQ #9,D7
	MOVE.W D3,D6	
	NEG.W D6	
	MOVE.W D6,(A6)+	
	MOVE.W D2,D6	 
	MULS D5,D6	
	ASR.L D7,D6	
	MOVE.W D6,(A6)+	
	MOVE.W D2,D6	
	MULS D4,D6	
	ASR.L D7,D6	
	MOVE.W D6,(A6)+	
	MOVE.W D0,D6	
	MULS D2,D6	
	ASR.L D7,D6	
	MOVE.W D6,(A6)+	
	MOVE.W D1,D6	
	MULS D4,D6	
	ASR.L D7,D6	
	MOVEA.W D6,A4	
	MOVE.W D0,D6	
	MULS D3,D6	
	ASR.L D7,D6
	MULS D5,D6	
	ASR.L D7,D6	
	SUB.W A4,D6	
	MOVE.W D6,(A6)+	
	MOVE.W D1,D6	
	MULS D5,D6	
	ASR.L D7,D6	
	MOVEA.W D6,A4	
	MOVE.W D0,D6	
	MULS D3,D6	
	ASR.L D7,D6	
	MULS D4,D6	
	ASR.L D7,D6	
	ADD.W A4,D6	
	MOVE.W D6,(A6)+	
	MOVE.W D1,D6	
	MULS D2,D6	
	ASR.L D7,D6	
	MOVE.W D6,(A6)+	
	MOVE.W D0,D6	
	MULS D4,D6	
	ASR.L D7,D6	
	MOVEA.W D6,A4	
	MOVE.W D1,D6	
	MULS D3,D6	
	ASR.L D7,D6	
	MULS D5,D6	
	ASR.L D7,D6	
	ADD.W A4,D6	
	MOVE.W D6,(A6)+	
	MOVE.W D0,D6	
	MULS D5,D6	
	ASR.L D7,D6	
	MOVEA.W D6,A4	
	MOVE.W D1,D6
	MULS D3,D6	
	ASR.L D7,D6	
	MULS D4,D6	
	ASR.L D7,D6
	SUB.W A4,D6
	MOVE.W D6,(A6)+	
	
	*---* *---*

	move.l	OBJEcT(PC),A0
	LEA	COOR(PC),A1
	MOVE.W	(A0)+,D0

WHILE	MOVE.W	(A0)+,D1		* X
	MOVE.W	(A0)+,D2		* Y
	MOVE.W	(A0)+,D3		* Z

    *-----* TRANSFORMATION COORDONNEES 3D EN COORDONNEES PLANAIRES *-----*
	
 	MOVEM.L A1/D0,-(SP)
	
	MOVE.W	D1,D0
	MOVE.W	D2,D1
	MOVE.W	D3,D2
		
	LEA XDEP(PC),A3
	MOVE.W (A3)+,D3	
	MOVE.W (A3)+,D4	
	MOVE.W (A3)+,D5	
	EXT.L D3
	EXT.L D4
	EXT.L D5
	MOVEQ #9,D6
	ASL.L D6,D3 	
	ASL.L D6,D4	
	ASL.L D6,D5	
	MOVEA.L D3,A1	
	MOVEA.L D4,A2
	MOVEA.L D5,A3
	
	LEA VAR_3D(PC),A6

	MOVE.W D0,D3	
	MOVE.W D1,D4	
	MOVE.W D2,D5	

	MULS (A6)+,D3	
	MULS (A6)+,D4
	MULS (A6)+,D5
	ADD.L D4,D5
	ADD.L D3,D5
	ADD.L A3,D5
	MOVE.L D5,A5

	MOVEQ	#9,D7
	LSR.L	D7,D5
	
	MOVE.W #512,D7
	SUB.W D5,D7	
	
	MOVE.W D0,D3
	MOVE.W D1,D4	
	MOVE.W D2,D5
		
	MULS (A6)+,D3
	MULS (A6)+,D4
	MULS (A6)+,D5
	ADD.L D4,D5	
	ADD.L D3,D5	
	ADD.L A1,D5	
	MOVE.L D5,A4	
	DIVS D7,D5	
	
	MULS (A6)+,D0	
	MULS (A6)+,D1	
	MULS (A6)+,D2
	ADD.L D0,D1	
	ADD.L D1,D2	
	ADD.L A2,D2
	MOVE.L D2,D6	
	DIVS D7,D2	
	
	ADDI.W 	#ORIGINE_X,D5
	ADDI.W	#ORIGINE_Y,D2
	MOVE.W	D5,D7
	MOVE.W	D2,D6
	
	MOVEM.L (SP)+,A1/D0

	*---* *---*
	
	MOVE.W	D7,(A1)+
	MOVE.W	D6,(A1)+
	DBF	D0,WHILE
	RTS

*----------------------- Datas & Buffer Sonic Vectors

		include		objects.s	

object:		dc.l	0
		dc.l	0
tabobject:	dc.l	objet_1
		dc.l	table_1
		dc.l	objet_2
		dc.l	table_2
		dc.l	objet_3
		dc.l	table_3
		dc.l	objet_4
		dc.l	table_4
		dc.l	objet_5
		dc.l	table_5
		dc.l	objet_6
		dc.l	table_6
		dc.l	objet_7
		dc.l	table_7
		dc.l	objet_8
		dc.l	table_8
		dc.l	objet_9
		dc.l	table_9

COS_TAB:	INCBIN e:\code\effects.grx\grafik_s\3D\COSINUS.TAB
SIN_TAB:	EQU COS_TAB+720

XDEP	DC.W 0
YDEP	DC.W 0
ZDEP	DC.W -300
X_ANGLE	DC.W 0
Y_ANGLE	DC.W 0
Z_ANGLE	DC.W 0

VAR_3D	DCB.W 9,0
COOR	DCB.W 1024,0		* TAILLE ARBITRAIRE !

*--------------------- Buffers & Datas  3D curves
linefond:	incbin	e:\code\effects.grx\grafik_s\images\linefond.dat
*-------------------------------------------------------------------------*

*-------------------------------------------------------------------------*
*	EFFET 9:	CIRCULAR ECHO					  *
*-------------------------------------------------------------------------*

effect9:	move.l		bufferec,a0		* Flip ec
		not.w		flip_ec
		move.w		flip_ec,d0
		and.w		#32000,d0
		add.w		d0,a0
		move.l		a0,ecran
		move.l		a0,physb

		tst.w	init
		bne.s	initmad9
		move.l	bufferec,a0
		moveq.l	#0,d1
		move.w	#15999,d0
copy9:		move.l	d1,(a0)+
		dbra.w	d0,copy9

		not.w	init
		rts
initmad9:	
ray2:		set	70
		
		lea	paleff9,a0		* Fixe palette
		lea	$ffff8240.w,a1
		rept	4
		move.l	(a0)+,(a1)+
		endr

		move.l		ecran,a0	* adr ecran
		moveq.l		#3,d3		* nb de cercles
		moveq.l		#100,d4		* abscisse
		lea		final,a1	* final buffer
			
effcircle:	move.w		(a1)+,d2	
		blt.s		db2
	
		movem.l		a0-a1/d3-d4,-(sp)
				
		move.w		(a1)+,d0
		move.w		(a1)+,d1
		jsr		effcirc
		
		movem.l		(sp)+,a0-a1/d3-d4
db2:		
		addq.w		#4,a1
		add.w		#40,d4
		addq.w		#2,a0
				
		dbra.w		d3,effcircle

		lea		oldpos(pc),a0
		lea		final(pc),a1
		moveq.l		#24/4-1,d0
copye9:		move.l		(a0)+,(a1)+
		dbra.w		d0,copye9

		move.l		ecran,a0	* adr ecran
		moveq.l		#3,d3		* 4 voix = 4 cercles
		moveq.l		#100,d4		* Position de depart en x
		lea		vox1,a1		* Pointe sur cpt sndtrack
		lea		poscirc,a2	* Pointe sur buffer etat cercle
		lea		oldpos,a3	* Pointe sur buffer keep ray
		lea		paleff9+2,a4
		lea		aleo9,a5
		add.w		aleocpt,a5
		moveq.l		#2,d5
		
		ifne	cpu
		move.w	#$70,$ffff8240.w
		endc
			
tracircle:	tst.w		(a1)+		* Test la voix
		beq.s		nothing		* si zero: on laisse
		move.w		#ray2-10,(a2)	* sinon init cercle
		move.l		(a5)+,2(a2)	* abscisse & ordonnee
		addq.w		#4,aleocpt
nothing:	
		move.w		#-1,(a3)+	* oldray = -1
		tst.w		(a2)+		* si rayon cercle <> 0
		ble.s		db
		
		moveq.l		#ray2,d2	* 
		sub.w		-2(a2),d2	* inverse rayon
		subq.w		#1,-2(a2)	* dec rayon
		move.w		d2,-2(a3)	* note rayon en keep ray
		
		move.w		d2,d7
		add.w		d7,d7
		move.w		raycl-10*2(pc,d7.w),(a4)
		
		movem.w		d3-d5,-(sp)	* sauve les registres
		movem.l		a0-a5,-(sp)

		move.w		(a2)+,d0	* abscisse
		move.w		(a2)+,d1	* ordonnee
		move.w		d0,(a3)+
		move.w		d1,(a3)+
		jsr		cercle		* go : trace cercle
		
		movem.l		(sp)+,a0-a5	* restaure les registres
		movem.w		(sp)+,d3-d5
db:
		addq.w		#4,a2
		addq.w		#4,a3
		add.w		#40,d4
		addq.w		#2,a0
		add.w		d5,a4
		add.w		d5,d5
				
		dbra.w		d3,tracircle

		and.w		#128*4-1,aleocpt

		rts

raycl:		incbin	tableff9.dat

poscirc:	dc.w	-1,160,100,-1,160,100
		dc.w	-1,160,100,-1,160,100

oldpos:		dc.w	10,160,100,10,160,100
		dc.w	10,160,100,10,160,100

final:		dc.w	-1,160,100,-1,160,100
		dc.w	-1,160,100,-1,160,100

bitgauche2:	macro
		subq.w	#1,d6
		dc.w	$6c06
		moveq.l	#15,d6
		addq.w	#8,a4
		addq.w	#8,a0
		endm	
bitdroit2:	macro
		subq.w	#1,d1
		dc.w	$6c06
		moveq.l	#15,d1
		subq.w	#8,a5
		subq.w	#8,a1
		endm	

effcirc:
	move.w	d2,d5 			* Delta = r
	
	lea	tabley,a6
	move.w	d0,d3			* xc And $fff0 + adr Affichage
	and.w	#$fff0,d3
	lsr.w	#1,d3
	add.w	d3,a0

	add.w	d1,d1
	add.w	(a6,d1.w),a0
	move.w	d2,d3

	add.w	d3,d3
	move.w	(a6,d3.w),d3

	lea	(a0,d3.w),a4		
	sub.w	d3,a0
	move.l	a0,a1
	move.l	a4,a5
	
	and.w	#15,d0
	move.w	d0,d1
	neg.w	d0
	add.w	#15,d0			* Init bit tournant
	move.w	d0,d6

	moveq.l	#1,d0
	moveq.l	#-1,d3			* X: d3 = -1
	moveq.l	#0,d7	
					* Y: d2 = r
deb2:	tst.w	d2			* While y>= 0
	bge.s	.ok2
	rts
.ok2:
	move.w	d7,(a0)			* Affichage
	move.w	d7,(a4)			* Affichage
	move.w	d7,(a1)			* Affichage
	move.w	d7,(a5)			* Affichage

	move.w	d5,d4			* delta: D5
	add.w	d4,d4			* d: D4  	d = delta * 2
	
	bge.s	else22			* Si d < 0
	subq.w	#1,d2		
	lea	160(a0),a0			
	lea	160(a1),a1
	lea	-160(a4),a4	
	lea	-160(a5),a5
	add.w	d3,d4			* d = d + x
	bge.s	else12			* Si d < 0
	add.w	d2,d5			* delta = delta + y	
	bra.s	deb2
else12:					* Sinon
	addq.w	#1,d3			* Inc x
	bitgauche2
	bitdroit2			
	add.w	d2,d5			* 
	sub.w	d3,d5			* delta = delta + y - x
	bra.s	deb2
else22:					* Sinon
	addq.w	#1,d3			* Inc x
	bitgauche2	
	bitdroit2
	sub.w	d2,d4			* d = d - y
	blt.s	else21			* Si y >= 0
	sub.w	d3,d5			* delta = delta - x
	bra.s	deb2
else21:					* Sinon
	subq.w	#1,d2			* Dec y
	lea	160(a0),a0	
	lea	160(a1),a1
	lea	-160(a4),a4	
	lea	-160(a5),a5
	sub.w	d3,d5			* delta = delta + y - x
	add.w	d2,d5
	bra.s	deb2

paleff9:	dc.w	0
		dcb.w	15,$343
aleocpt:	dc.w	0
aleo9:		incbin	aleoeff9.dat

*-------------------------------------------------------------------------*
*	EFFET 10:	Sound Valley					  *
*-------------------------------------------------------------------------*

effect10:	
		move.l		ecran,ecran2
		move.l		bufferec,a0		* Flip ec
		not.w		flip_ec
		move.w		flip_ec,d0
		and.w		#32000,d0	
		add.w		d0,a0
		move.l		a0,ecran
		move.l		a0,physb

		tst.w	init
		bne.s	initmad10
		
		lea		img9(pc),a0		* Decompacte image
		move.l		bufferec,a1
		lea		0.w,a2
		move.w		#199,d0
		jsr		decomp	

		lea		32000(a1),a0
		move.w		#7999,d0
copy10:		move.l		(a1)+,(a0)+
		dbra.w		d0,copy10

		move.l		#buffer_ec+73256,a1		* Construit la table
		move.l		a1,a2
		moveq.l		#128/2-1,d0
		moveq.l		#0,d1
		move.w		#-160,d2
maketab2:	rept	2
		move.w		d1,(a1)+		
		move.w		d2,-(a2)
		endr
		add.w		#160,d1
		sub.w		#160,d2
		dbra.w		d0,maketab2
			
		lea		img9+2(pc),a0
		lea		$ffff8240.w,a1
		rept		8
		move.l		(a0)+,(a1)+
		endr
			
		not.w	init
		rts
initmad10:	
	move.w	#8,$ffff8a20.w
	move.w	#8,$ffff8a22.w
	move.l	ecran,d0
	add.w	#480*2+6,d0
	move.l	d0,$ffff8a24.w
	move.w	#8,$ffff8a2e.w
	move.w	#8,$ffff8a30.w
	move.l	ecran,d0
	addq.l	#6,d0
	move.l	d0,$ffff8a32.w
	move.b	#2,$ffff8a3a.w
	move.b	#3,$ffff8a3b.w
	move.b	#6,$ffff8a3d.w
	move.w	#20,$ffff8a36.w
	move.w	#194,$ffff8a38.w
	move.b	#%11000000,$ffff8a3c.w
	
	tst.l	vox1
	bne.s	trac
	tst.l	vox3
	bne.s	trac
	rts
trac:
	ifne	cpu
	move.w	#$700,$ffff8240.w
	endc
	
	move.l		samp1,a0			* Adr sample courant
	move.l		#buffer_ec+73256,a2		
	move.l		ecran2,a1			* Adr affichage
	lea		31840-64*160+6(a1),a1		* 
	move.l		ecran(pc),a3
	lea		31840-64*160-480+6(a3),a3	*
	move.w		#159,d1				* Longueur courbe

	moveq.l		#1,d7
	move.w		#4096,d6
	move.w		#32768,d0
	moveq.l		#0,d3	

aff9_1:
	move.b		(a0)+,d2
	move.b		(a0)+,d4
	addq.w		#2,a0
	ext.w		d2
	ext.w		d4
	add.w		d2,d4
	bclr.l		d3,d4
	move.w		(a2,d4.w),d4

	or.w		d0,(a1,d4.w)
	or.w		d6,(a3,d4.w)
	
	ror.w		d7,d0
	dc.w		$6402
	addq.w		#8,a1

	ror.w		d7,d6
	dc.w		$6402
	addq.w		#8,a3

	dbra.w		d1,aff9_1
	
	rts

ecran2:		dc.l	0
img9:		incbin	e:\code\effects.grx\grafik_s\images\spectral.dat
		even


*-------------------------------------------------------------------------*
*	PROCEDURES GENERALES						  *
*-------------------------------------------------------------------------*

	include		e:\code\routines.asm\decompac.s
	include		e:\code\routines.asm\decompa2.s

initsound:
	move.w		#$7ff,$ffff8924.w		* Init microwire
	move.w		#%10011101000,d0		* Volume max
	bsr.s		microwrite
	move.w		#%10010000000+aigus,d0		* Aigus 
	bsr.s		microwrite
	move.w		#%10001000000+graves,d0		* Graves
	bsr.s		microwrite
	rts

microwrite:
	move.w		d0,$ffff8922.w
	moveq.l		#127,d0
waitdma:dbra.w		d0,waitdma
	rts


fadesound:	
	moveq.l		#20,d0
temp2:	move.w		#$4c0,d2
	or.w		d0,d2
	add.w		#20,d2
	move.w		d2,$ffff8922.w
	move.w		#10000,d1
temp1:	move.l		4(sp),4(sp)
	dbra.w		d1,temp1
	dbra.w		d0,temp2
	rts

*-------------------------------------------------------------------------*	
*-------------------------------------------------------------------------*	
save:		dc.w		0
vsync:		dc.w		0
ecran:		dc.l		buffer_ec
flipaff:	dc.w		0
flip_ec:	dc.w		0
bufferec:	dc.l		buffer_ec
mega:		dc.w		0
*-------------------------------------------------------------------------*	
param:		dc.w	0
effect:		dc.w	0
init:		dc.w	0
vbl:		dc.l	0

none:		rts

tabeffect:	dc.l	effect1
		dc.l	effect2
		dc.l	effect3
		dc.l	effect4
		dc.l	effect5
		dc.l	effect6
		dc.l	effect7
		dc.l	effect8
		dc.l	effect9
		dc.l	effect10
		dc.l	none
		dc.l	none

change:		dc.w	1
instruct:	dc.w	0

tabinit:	dc.l	einit7
		dc.l	einit2
		dc.l	einit1
		dc.l	einit1
		dc.l	einit1
		dc.l	einit1
		dc.l	einit7
		dc.l	einit7
		dc.l	einit1
		dc.l	einit1
		dc.l	finprg
		dc.l	einit1

einit1:		addq.w	#4,instruct
		rts

einit2:		add.w	#10,instruct
		move.w	(a0)+,x
		move.w	(a0)+,ic
		move.w	(a0)+,mode2
		rts

einit7:		addq.w	#6,instruct
		move.w	(a0)+,param
		rts

finprg:		clr.w	instruct
		rts

*-------------------------------------------------------------------------*
*
*	NOYAU DE CONTROLE 
*
*-------------------------------------------------------------------------*
				*
				*	PARAMETRES
				*
logocurve:	set	0	*	Nb Vbl,Mode
gridcurve:	set	4	*	Nb Vbl,Prof dep,Sens,Voice (nb voix*2) Logo (0 = logo off) 
equalizer:	set	8	*	Nb Vbl
plasmason:	set	12	*	Nb Vbl
psyche_vm:	set	16	*	Nb Vbl
circlecur:	set	20	*	Nb Vbl
fullimage:	set	24	*	Nb Vbl,Nb of image 
sonicvect:	set	28	*	Nb Vbl,Nb of object
circlecho:	set	32	*	Nb Vbl
soundvall:	set	36	*	Nb Vbl
endproc:	set	40	*       1
waitstate:	set	44	*	Nb vbl

prg1:		dc.w		logocurve,188,0		
		dc.w		circlecur,188
		dc.w		gridcurve,60,10,4,0
		dc.w		fullimage,100,0
		dc.w		plasmason,174
		dc.w		gridcurve,206,246,-2,0
		dc.w		psyche_vm,186
		dc.w		circlecur,50
		dc.w		logocurve,40,0
		dc.w		circlecur,48
		dc.w		fullimage,80,1
		dc.w		gridcurve,60,10,4,0
		dc.w		circlecur,65
		dc.w		sonicvect,200,6
		dc.w		logocurve,180,1
		dc.w		sonicvect,180,4
		dc.w		sonicvect,178,0
		dc.w		soundvall,120
		dc.w		psyche_vm,90
		dc.w		plasmason,93
		dc.w		psyche_vm,90
		dc.w		gridcurve,90,10,2,0
		dc.w		fullimage,86,1
		dc.w		equalizer,184
		dc.w		circlecho,180
		dc.w		plasmason,84
		dc.w		psyche_vm,102	
		dc.w		plasmason,86	
		dc.w		psyche_vm,120
		dc.w		circlecho,160
		dc.w		plasmason,86
		dc.w		psyche_vm,100
		dc.w		circlecho,150
		dc.w		plasmason,32
		dc.w		gridcurve,130,10,2,2
		dc.w		fullimage,45,0
		dc.w		gridcurve,45,10,2,2
		dc.w		fullimage,40,1
		dc.w		gridcurve,60,10,2,2
		dc.w		plasmason,35
		dc.w		sonicvect,175,4
		dc.w		equalizer,190
		dc.w		logocurve,180,1
		dc.w		fullimage,180,1
		dc.w		sonicvect,190,4
		dc.w		fullimage,140,0
		dc.w		plasmason,50
		dc.w		circlecur,190
		dc.w		logocurve,85,0
		dc.w		circlecur,35
		dc.w		plasmason,45
		dc.w		circlecur,328
		dc.w		plasmason,90
		dc.w		waitstate,32000
		dc.w		endproc


prg2:		dc.w		logocurve,21*6,0
		dc.w		fullimage,32,0
		dc.w		logocurve,31*6,1
		dc.w		gridcurve,31*8,10,2,2
		dc.w		soundvall,140
		dc.w		psyche_vm,90
		dc.w		gridcurve,96,10,2,0
		dc.w		sonicvect,90,0 	
		dc.w		circlecho,90
		dc.w		plasmason,184
		dc.w		fullimage,92,1
		dc.w		sonicvect,90,4
		dc.w		fullimage,90,0
		dc.w		plasmason,96
		dc.w		sonicvect,184,8
		dc.w		psyche_vm,100
		dc.w		circlecur,82
		dc.w		logocurve,96,0
		dc.w		gridcurve,472,246,2,4
		dc.w		equalizer,380
		dc.w		sonicvect,90,3
		dc.w		sonicvect,92,6
		dc.w		sonicvect,94,1
		dc.w		sonicvect,92,6
		dc.w		logocurve,92,0
		dc.w		plasmason,90
		dc.w		circlecho,91*2
		dc.w		logocurve,92,0
		dc.w		plasmason,90
		dc.w		circlecho,91*2
		dc.w		equalizer,364
		dc.w		gridcurve,374,2,4,0
		dc.w		circlecur,382
		dc.w		circlecho,382
		dc.w		psyche_vm,380
		dc.w		plasmason,376
		dc.w		fullimage,186,1
		dc.w		logocurve,186,1
		dc.w		fullimage,186,0
		dc.w		circlecur,186
		dc.w		gridcurve,860,246,2,8
		dc.w		waitstate,32000
		dc.w		endproc
		
*-------------------------------------------------------------------------*	
*-------------------------------------------------------------------------*	
*-------------------------------------------------------------------------*	
*-------------------------------------------------------------------------*	
*	REPLAY ROUTINE							  *
*-------------------------------------------------------------------------*	
*-------------------------------------------------------------------------*	

muson:	bsr	vol			; Calculate volume tables
	bsr	incrcal			; Calculate tonetables
                 
	jsr	init2			; Initialize music
	jsr	prepare			; Prepare samples

	move.w	#$2700,sr
	ifne	system
	move.l	$fffffa06.w,oldmfp1
	move.l	$70.w,oldvbl
	endc
	clr.l	$fffffa06.w
	bclr.b	#3,$fffffa17.w		* Auto vectors
	move.l	#stereo,$70.w
	move.b	#FREQ+1,$FFFF8921.w	; Frequency
	lea	$FFFF8907.w,a0
	move.l	#sample1,d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)
	move.l	#sample1+LEN*4,d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)
	move.b	#1,$FFFF8901.w		; Start DMA
	move	#$2300,sr

	rts

musoff:
	move.w	#$2700,sr
	ifne	system
	move.l	oldmfp1(pc),$fffffa06.w
	move.l	oldvbl(pc),$70.w	; Restore everything
	endc
	clr.b	$FFFF8901.w		; Stop DMA
	move.w	#$2300,sr
	rts

	ifne	system
oldmfp1:	DC.l 	0
oldvbl:		dc.l	0
	endc
physb:		dc.l	0
;--------------------------------------------------------- Volume table --
vol:	moveq.l	#64,d0
	lea	vtabend(pc),a0

.ploop:	move.w	#255,d1
.mloop:	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	divs	#MVOL,d2		; <---- Master volume
	move.b	d2,-(a0)
	dbra	d1,.mloop
	dbra	d0,.ploop

	rts

vtab:	DS.B 65*256
vtabend:

;------------------------------------------------------ Increment-table --
incrcal:lea	stab(pc),a0
	move.w	#$30,d1
	move.w	#$039F-$30,d0
	move.l	#INC,d2

recalc:	swap	d2
	moveq.l	#0,d3
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	swap	d4

	swap	d2
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	move.l	d4,(a0)+

	addq.w	#1,d1
	dbra	d0,recalc
	rts

itab:	DS.L $30
stab:	DS.L $03A0-$30

;-------------------------------------------------------- DMA interrupt --
stereo:	

	move.b	#1,$FFFF8901.w		; Start DMA

	movem.l	d0-a6,-(sp)

	move.l	physb,d0
	lea	$ffff8203.w,a0
	movep.l	d0,(a0)

	tst.l	vbl
	beq.s	novbl
	move.l	vbl,a0
	jsr	(a0)
novbl:
	clr.w	vsync

	ifne	cpu
	move.w	#$7,$ffff8240.w
	endc

	move.l	samp2(pc),d0
	move.l	samp1(pc),samp2
	move.l	d0,samp1

	lea	$FFFF8907.w,a0

	move.l	d0,d1
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)
	
	add.l	#LEN*4,d1
	move.b	d1,12(a0)
	lsr.w	#8,d1
	move.l	d1,7(a0)
	
	bsr	music

	lea	itab(pc),a5
	lea	vtab(pc),a3
	moveq.l	#0,d0
	moveq.l	#0,d4

v1:	movea.l	wiz2lc(pc),a0

	move.w	wiz2pos(pc),d0
	move.w	wiz2frc(pc),d1

	move.w	aud2per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2

	movea.w	2(a5,d7.w),a4

	move.w	aud2vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2

	movea.l	wiz3lc(pc),a1

	move.w	wiz3pos(pc),d4
	move.w	wiz3frc(pc),d5

	move.w	aud3per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5

	move.w	aud3vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a3

	movea.l	samp1(pc),a6
	moveq.l	#0,d3

	REPT LEN
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	move.w	d7,(a6)+
	ENDR

	cmp.l	wiz2len(pc),d0
	blt.s	.ok2
	sub.w	wiz2rpt(pc),d0

.ok2:	move.w	d0,wiz2pos
	move.w	d1,wiz2frc

	cmp.l	wiz3len(pc),d4
	blt.s	.ok3
	sub.w	wiz3rpt(pc),d4

.ok3:	move.w	d4,wiz3pos
	move.w	d5,wiz3frc

	lea	itab,a5
	lea	vtab,a3
	moveq.l	#0,d0
	moveq.l	#0,d4

v2:	movea.l	wiz1lc(pc),a0

	move.w	wiz1pos(pc),d0
	move.w	wiz1frc(pc),d1

	move.w	aud1per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2
	movea.w	2(a5,d7.w),a4

	move.w	aud1vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2


	movea.l	wiz4lc(pc),a1

	move.w	wiz4pos(pc),d4
	move.w	wiz4frc(pc),d5

	move.w	aud4per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5

	move.w	aud4vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a3

	movea.l	samp1(pc),a6
	moveq.l	#0,d3

var:	set	0
	REPT LEN
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,var(a6)
var:	set	var+2
	move.b	d7,var(a6)
var:	set	var+2
	ENDR

	cmp.l	wiz1len(pc),d0
	blt.s	.ok1
	sub.w	wiz1rpt(pc),d0

.ok1:	move.w	d0,wiz1pos
	move.w	d1,wiz1frc

	cmp.l	wiz4len(pc),d4
	blt.s	.ok4
	sub.w	wiz4rpt(pc),d4

.ok4:	move.w	d4,wiz4pos
	move.w	d5,wiz4frc

	movem.l	(sp)+,d0-a6
	
	ifne	cpu
	move.w	#$2,$ffff8240.w
	endc

	move.b	$fffffc02.w,tch
	
	ifne	esc
	cmp.b	#1,tch
	bne.s	nofin
	jmp	fin
nofin:
	endc
	
	rte

;-------------------------------------------- Hardware-registers & data --
wiz1lc:		DC.L sample1
wiz1len:	DC.L 0
wiz1rpt:	DC.W 0
wiz1pos:	DC.W 0
wiz1frc:	DC.W 0

wiz2lc:		DC.L sample1
wiz2len:	DC.L 0
wiz2rpt:	DC.W 0
wiz2pos:	DC.W 0
wiz2frc:	DC.W 0

wiz3lc: 	DC.L sample1
wiz3len:	DC.L 0
wiz3rpt:	DC.W 0
wiz3pos:	DC.W 0
wiz3frc:	DC.W 0

wiz4lc: 	DC.L sample1
wiz4len:	DC.L 0
wiz4rpt:	DC.W 0
wiz4pos:	DC.W 0
wiz4frc:	DC.W 0

aud1lc: 	DC.L dummy
aud1len:	DC.W 0
aud1per:	DC.W 0
aud1vol:	DC.W 0
		DS.W 3

aud2lc: 	DC.L dummy
aud2len:	DC.W 0
aud2per:	DC.W 0
aud2vol:	DC.W 0
		DS.W 3

aud3lc:		DC.L dummy
aud3len:	DC.W 0
aud3per:	DC.W 0
aud3vol:	DC.W 0
		DS.W 3

aud4lc:		DC.L dummy
aud4len:	DC.W 0
aud4per:	DC.W 0
aud4vol:	DC.W 0

dmactrl:	DC.W 0

dummy:		DC.L 0

samp1:		DC.L sample1
samp2:		DC.L sample2

sample1:	DS.W 	LEN*2+1
sample2:	DS.W 	LEN*2+1

;========================================================= EMULATOR END ==

prepare:lea	workspc,a6
	movea.l	samplestarts(pc),a0
	movea.l	end_of_samples(pc),a1

tostack:move.w	-(a1),-(a6)
	cmpa.l	a0,a1			; Move all samples to stack
	bgt.s	tostack

	lea	samplestarts(pc),a2
	lea	data(pc),a1		; Module
	movea.l	(a2),a0			; Start of samples
	movea.l	a0,a5			; Save samplestart in a5

	moveq	#30,d7

roop:	move.l	a0,(a2)+		; Sampleposition

	tst.w	$2A(a1)
	beq.s	samplok			; Len=0 -> no sample

	tst.w	$2E(a1)			; Test repstrt
	bne.s	repne			; Jump if not zero


repeq:	move.w	$2A(a1),d0		; Length of sample
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a0,a4
fromstk:move.w	(a6)+,(a0)+		; Move all samples back from stack
	dbra	d0,fromstk

	bra.s	rep



repne:	move.w	$2E(a1),d0
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a6,a4
get1st:	move.w	(a4)+,(a0)+		; Fetch first part
	dbra.w	d0,get1st

	adda.w	$2A(a1),a6		; Move a6 to next sample
	adda.w	$2A(a1),a6



rep:	movea.l	a0,a5
	moveq.l	#0,d1
toosmal:movea.l	a4,a3
	move.w	$30(a1),d0
	subq.w	#1,d0
moverep:move.w	(a3)+,(a0)+		; Repeatsample
	addq.w	#2,d1
	dbra.w	d0,moverep
	cmp.w	#320*5,d1		; Must be > 320
	blt.s	toosmal

	move.w	#320*5/2-1,d2
last320:move.w	(a5)+,(a0)+		; Safety 320 bytes
	dbra.w	d2,last320

done:	add.w	d4,d4

	move.w	d4,$2A(a1)		; length
	move.w	d1,$30(a1)		; Replen
	clr.w	$2E(a1)

samplok:lea	$1E(a1),a1
	dbra.w	d7,roop

	cmp.l	#workspc,a0
	bgt.s	.nospac

	rts

.nospac: illegal

end_of_samples:	DC.L 0

;------------------------------------------------------ Main replayrout --
init2:	lea	data(pc),a0
	lea	$03B8(a0),a1

	moveq.l	#$7F,d0
	moveq.l	#0,d1
loop:	move.l	d1,d2
	subq.w	#1,d0
lop2:	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	loop
	dbra.w	d0,lop2
	addq.b	#1,d2

	lea	samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$043C,d2
	add.l	a0,d2
	movea.l	d2,a2

	moveq.l	#$1E,d0
lop3:	clr.l	(a2)
	move.l	a2,(a1)+
	moveq.l	#0,d1
	move.w	42(a0),d1
	add.l	d1,d1
	adda.l	d1,a2
	adda.l	#$1E,a0
	dbra.w	d0,lop3

	move.l	a2,end_of_samples	;
	rts

music:	lea	data(pc),a0
	addq.w	#$01,counter
	move.w	counter(pc),d0
	cmp.w	speed(pc),d0
	blt.s	nonew
	clr.w	counter
	bra	getnew

nonew:	lea	voice1(pc),a4
	lea	aud1lc(pc),a3
	bsr	checkcom
	lea	voice2(pc),a4
	lea	aud2lc(pc),a3
	bsr	checkcom
	lea	voice3(pc),a4
	lea	aud3lc(pc),a3
	bsr	checkcom
	lea	voice4(pc),a4
	lea	aud4lc(pc),a3
	bsr	checkcom
	lea	vox1,a5
	clr.l	(a5)	
	clr.l	4(a5)
	bra	endr

arpeggio:
	moveq.l	#0,d0
	move.w	counter(pc),d0
	divs.w	#$03,d0
	swap	d0
	tst.w	d0
	beq.s	arp2
	cmp.w	#$02,d0
	beq.s	arp1

	moveq.l	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	bra.s	arp3

arp1:	moveq.l	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	bra.s	arp3

arp2:	move.w	$10(a4),d2
	bra.s	arp4

arp3:	add.w	d0,d0
	moveq.l	#0,d1
	move.w	$10(a4),d1
	lea	periods(pc),a0
	moveq.l	#$24,d4
arploop:move.w	0(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	arp4
	addq.w	#2,a0
	dbra.w	d4,arploop
	rts

arp4:	move.w	d2,$06(a3)
	rts

getnew:	lea	data+$043C(pc),a0
	lea	-$043C+$0C(a0),a2
	lea	-$043C+$03B8(a0),a1

	moveq.l	#0,d0
	move.l	d0,d1
	move.b	songpos(pc),d0
	move.b	0(a1,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	pattpos(pc),d1
	clr.w	dmacon

	lea	aud1lc(pc),a3
	lea	voice1(pc),a4
	lea	vox1,a5
	bsr.s	playvoice
	lea	aud2lc(pc),a3
	lea	voice2(pc),a4
	addq.w	#2,a5
	bsr.s	playvoice
	lea	aud3lc(pc),a3
	lea	voice3(pc),a4
	addq.w	#2,a5
	bsr.s	playvoice
	lea	aud4lc(pc),a3
	lea	voice4(pc),a4
	addq.w	#2,a5
	bsr.s	playvoice
	bra	setdma

playvoice:
	move.l	0(a0,d1.l),(a4)
	addq.l	#4,d1
	moveq.l	#0,d2
	move.b	$02(a4),d2
	and.b	#$F0,d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$F0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	setregs
	moveq.l	#0,d3
	lea	samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$01,d2
	asl.l	#2,d2
	mulu.w	#$1E,d4
	move.l	0(a1,d2.l),$04(a4)
	move.w	0(a2,d4.l),$08(a4)
	move.w	$02(a2,d4.l),$12(a4)
	move.w	$04(a2,d4.l),d3
	tst.w	d3
	beq.s	noloop
	move.l	$04(a4),d2
	add.w	d3,d3
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$04(a2,d4.l),d0
	add.w	$06(a2,d4.l),d0
	move.w	d0,8(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
	bra.s	setregs

noloop:	move.l	$04(a4),d2
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
setregs:move.w	(a4),d0
	and.w	#$0FFF,d0
	beq	checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$03,d0
	bne.s	setperiod
	bsr	setmyport
	bra	checkcom2

setperiod:
	move.w	(a4),$10(a4)
	andi.w	#$0FFF,$10(a4)
	move.w	$14(a4),d0
	move.w	d0,dmactrl
	clr.b	$1B(a4)

	move.l	$04(a4),(a3)
	move.w	$08(a4),$04(a3)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	move.w	d0,(a5)
	move.w	$14(a4),d0
	or.w	d0,dmacon
	bra	checkcom2

setdma:	move.w	dmacon(pc),d0

	btst.l	#0,d0			;-------------------
	beq.s	wz_nch1			;
	move.l	aud1lc(pc),wiz1lc	;
	moveq.l	#0,d1			;
	moveq.l	#0,d2			;
	move.w	aud1len(pc),d1		;
	move.w	voice1+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz1len		;
	move.w	d2,wiz1rpt		;
	clr.w	wiz1pos			;

wz_nch1:btst.l	#1,d0			;
	beq.s	wz_nch2			;
	move.l	aud2lc(pc),wiz2lc	;
	moveq.l	#0,d1			;
	moveq.l	#0,d2			;
	move.w	aud2len(pc),d1		;
	move.w	voice2+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz2len		;
	move.w	d2,wiz2rpt		;
	clr.w	wiz2pos			;

wz_nch2:btst.l	#2,d0			;
	beq.s	wz_nch3			;
	move.l	aud3lc(pc),wiz3lc	;
	moveq.l	#0,d1			;
	moveq.l	#0,d2			;
	move.w	aud3len(pc),d1		;
	move.w	voice3+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz3len		;
	move.w	d2,wiz3rpt		;
	clr.w	wiz3pos			;

wz_nch3:btst.l	#3,d0			;
	beq.s	wz_nch4			;
	move.l	aud4lc(pc),wiz4lc	;
	moveq.l	#0,d1			;
	moveq.l	#0,d2			;
	move.w	aud4len(pc),d1		;
	move.w	voice4+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz4len		;
	move.w	d2,wiz4rpt		;
	clr.w	wiz4pos			;-------------------

wz_nch4:addi.w	#$10,pattpos
	cmpi.w	#$0400,pattpos
	bne.s	endr
nex:	clr.w	pattpos
	clr.b	break
	addq.b	#1,songpos
	andi.b	#$7F,songpos
	move.b	songpos(pc),d1
	cmp.b	data+$03B6(pc),d1
	bne.s	endr
	move.b	data+$03B7(pc),songpos

	move.w	#1,change		* <---------------
	clr.w	instruct		* <---------------

endr:	tst.b	break
	bne.s	nex
	rts

setmyport:
	move.w	(a4),d2
	and.w	#$0FFF,d2
	move.w	d2,$18(a4)
	move.w	$10(a4),d0
	clr.b	$16(a4)
	cmp.w	d0,d2
	beq.s	clrport
	bge.s	rt
	move.b	#$01,$16(a4)
	rts

clrport:clr.w	$18(a4)
rt:	rts

myport:	move.b	$03(a4),d0
	beq.s	myslide
	move.b	d0,$17(a4)
	clr.b	$03(a4)
myslide:tst.w	$18(a4)
	beq.s	rt
	moveq.l	#0,d0
	move.b	$17(a4),d0
	tst.b	$16(a4)
	bne.s	mysub
	add.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)

myok:	move.w	$10(a4),$06(a3)
	rts

mysub:	sub.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	blt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)
	move.w	$10(a4),$06(a3)
	rts

vib:	move.b	$03(a4),d0
	beq.s	vi
	move.b	d0,$1A(a4)

vi:	move.b	$1B(a4),d0
	lea	sin(pc),a1
	lsr.w	#$02,d0
	and.w	#$1F,d0
	moveq.l	#0,d2
	move.b	0(a1,d0.w),d2
	move.b	$1A(a4),d0
	and.w	#$0F,d0
	mulu	d0,d2
	lsr.w	#$06,d2
	move.w	$10(a4),d0
	tst.b	$1B(a4)
	bmi.s	vibmin
	add.w	d2,d0
	bra.s	vib2

vibmin:	sub.w	d2,d0
vib2:	move.w	d0,$06(a3)
	move.b	$1A(a4),d0
	lsr.w	#$02,d0
	and.w	#$3C,d0
	add.b	d0,$1B(a4)
	rts

nop:	move.w	$10(a4),$06(a3)
	rts

checkcom:
	move.w	$02(a4),d0
	and.w	#$0FFF,d0
	beq.s	nop
	move.b	$02(a4),d0
	and.b	#$0F,d0
	tst.b	d0
	beq	arpeggio
	cmp.b	#$01,d0
	beq.s	portup
	cmp.b	#$02,d0
	beq	portdown
	cmp.b	#$03,d0
	beq	myport
	cmp.b	#$04,d0
	beq	vib
	cmp.b	#$05,d0
	beq	port_toneslide
	cmp.b	#$06,d0
	beq	vib_toneslide
	move.w	$10(a4),$06(a3)
	cmp.b	#$0A,d0
	beq.s	volslide
	rts

volslide:
	moveq.l	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	voldown
	add.w	d0,$12(a4)
	cmpi.w	#$40,$12(a4)
	bmi.s	vol2
	move.w	#$40,$12(a4)
vol2:	move.w	$12(a4),$08(a3)
	rts

voldown:moveq.l	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	sub.w	d0,$12(a4)
	bpl.s	vol3
	clr.w	$12(a4)
vol3:	move.w	$12(a4),$08(a3)
	rts

portup:	moveq.l	#0,d0
	move.b	$03(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$71,d0
	bpl.s	por2
	andi.w	#$F000,$10(a4)
	ori.w	#$71,$10(a4)
por2:	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

port_toneslide:
	bsr	myslide
	bra.s	volslide

vib_toneslide:
	bsr	vi
	bra.s	volslide

portdown:
	clr.w	d0
	move.b	$03(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$0358,d0
	bmi.s	por3
	andi.w	#$F000,$10(a4)
	ori.w	#$0358,$10(a4)
por3:	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

checkcom2:
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$0D,d0
	beq.s	pattbreak
	cmp.b	#$0B,d0
	beq.s	posjmp
	cmp.b	#$0C,d0
	beq.s	setvol
	cmp.b	#$0F,d0
	beq.s	setspeed
	rts

pattbreak:
	st	break
	rts

posjmp:	move.b	$03(a4),d0
	subq.b	#$01,d0
	move.b	d0,songpos
	st	break

	tst.w	$206.w
	beq.s	defile2
	move.w	#1,change		* <---------------
	clr.w	instruct		* <---------------
	rts
defile2:move.w	#-1,exit
	rts

setvol:	moveq.l	#0,d0
	move.b	$03(a4),d0
	cmp.w	#$40,d0
	ble.s	vol4
	move.b	#$40,$03(a4)
vol4:	move.b	$03(a4),$09(a3)
	move.b	$03(a4),$13(a4)
	rts

setspeed:
	cmpi.b	#$1F,$03(a4)
	ble.s	sets
	move.b	#$1F,$03(a4)
sets:	move.b	$03(a4),d0
	beq.s	rts2
	move.w	d0,speed
	clr.w	counter
rts2:	rts

sin:	DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
	DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18

periods:DC.W $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0
	DC.W $01C5,$01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$FE
	DC.W $F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97,$8F,$87
	DC.W $7F,$78,$71,$00,$00

speed:	DC.W $06
counter:DC.W $00
songpos:DC.B $00
break:	DC.B $00
pattpos:DC.W $00

dmacon:		DC.W $00
samplestarts:	DS.L $1F

voice1:	DS.W 10
	DC.W $01
	DS.W 3
voice2:	DS.W 10
	DC.W $02
	DS.W 3
voice3:	DS.W 10
	DC.W $04
	DS.W 3
voice4:	DS.W 10
	DC.W $08
	DS.W 3

	Section		data

data:
	ifne	system
	incbin	d:\sndtrack\modules\tcn\new_tec7.mod
	incbin	d:\sndtrack\modules\tcn\grafik.mod
fich:	dc.b	"e:\code\effects.grx\grafik_s\script2.dat",0
	else
	dc.l	'Here'
	endc
	
	Section 	bss

		DS.B	50000+(1-system)*116000
workspc:	DS.W	1
 
*-------------------------------------------------------------------------* 
*	Buffer ecran							  *
*-------------------------------------------------------------------------* 

		ds.b	256
buffer_ec:	ds.b	74240
