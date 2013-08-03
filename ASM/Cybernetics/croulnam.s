	output	e:\code\effects.grx\flexi\flexi.prg

	opt	o+

long:	equ	320
haut:	equ	16		* 320 * 160 = 5120 Points
aigus:	set	8
graves:	set	10
cpu:	set	0

*-------------------------------------------------------------------------*
*   FLEXISCROLL V 3.0							  *
*									  *
*   Alias  'CYBERNETICS ROULENT'					  *
*									  *
*   CAN DISPLAY 7500 POINTS PER VBL - ERASE WITH BLITTER		  *
*-------------------------------------------------------------------------*

*	Infos Autogeneration:
*
*	move.w	(a0)+,d4:		$3818
*	or.b	Dx,Off(a1):		$81290000 +$2000000*x +Off
*	move.b	Dx,Off(a1):		$13400000 +$10000*x   +Off
*	bset.b	D2,Off(a1):		$05E90000             +Off			
*	add.w	D4,D4:			$D844
*	bcc.s	Deplacement (court)	$6400     +Deplacement
*	rts				$4E75
*	addq.l	#4,a0			$5888

*-------------------------------------------------------------------------*
*    Inits           							  *
*-------------------------------------------------------------------------*	

	move.l		#buffer_ec,d0		* Buffer ecran
	clr.w		d0			* Multiple de 65536
	add.l		#$10000,d0		* pour ne pas ecraser ce kil y a avant
	move.l		d0,ec			* Dans ec
	move.l		ec(pc),ecran		* Dans ecran
	addq.w		#6,d0			
	move.l		d0,affp
	move.l		d0,affp2
	move.l		d0,affp3

	move.w		#2,-(sp)		* Phybase
	trap		#14
	addq.l		#2,sp	
	move.l		d0,oldscr

	pea.l		0.w			* Superviseur
	move.w		#32,-(sp)
	trap		#1
	addq.l		#6,sp
	move.l		d0,stack

	lea		$ffff8240.w,a0
	rept		8
	clr.l		(a0)+
	endr

	move.b		#2,$ffff820a.w		* Synchro
	
	clr.w		-(sp)			* Resolution
	move.l		ec(pc),-(sp)
	move.l		ec(pc),-(sp)
	move.w		#5,-(sp)
	trap		#14
	lea		12(sp),sp

	move.b		#48,$ffff820f.w		* Init registres ste
	clr.b		$ffff8265.w		

	move.w		#511,d0			* Affichage du fond
	move.l		ecran(pc),a1
line:	lea		datline(pc),a0
	rept		64
	move.l		(a0)+,(a1)+
	endr
	dbra.w		d0,line
	addq.l		#6,ecran
	
	move.b		#48,$820f-$8242(a6)	* Registres STE du shifter
	clr.b		$8265-$8242(a6)
	
	bsr		initsound

	lea		$ffff8900.w,a0
	move.l		#sample,d0
	move.w		d0,6(a0)
	lsr.w		#8,d0
	move.w		d0,4(a0)
	swap		d0
	move.w		d0,2(a0)
	move.l		#sample+56555,d0
	move.w		d0,$12(a0)
	lsr.w		#8,d0
	move.w		d0,$10(a0)
	swap		d0
	move.w		d0,$e(a0)
	move.w		#%10000010,$20(a0)
	move.w		#3,(a0)

	lea		$ffff8242.w,a6	
	lea		rasters,a5
	lea		curve(pc),a3

	move.w		#$2700,sr		* Init inters
	move.l		$70.w,oldvbl 		* Init my Vbl
	move.b		$fffffa07.w,stim1		
	move.b		$fffffa09.w,stim2
	clr.b		$fffffa1b.w	
	move.b		#1,$fffffa07.w		* Arret tous niveaux MFP
	clr.b		$fffffa09.w		* sauf timer B
	move.l		#vbl,$70.w
	move.l		#hbl,$120.w
	move.b		#1,$fffffa21.w
	move.b		#8,$fffffa1b.w	
	bset.b		#0,$fffffa13.w		* sauf timer B
	bclr.b		#3,$fffffa17.w		* End mode 
	move.w		#$2300,sr		* Go (only vbl)		

*-------------------------------------------------------------------------*
*   Boucle principale							  *
*-------------------------------------------------------------------------*	
	
main:	
	clr.b		$ffff8265.w
	move.b		#48,$ffff820f.w	

   *----------------------------------------------------------------------*
   *    Gestion numero courbe & text 					  *
   *----------------------------------------------------------------------*	
   
   *----------------------------------------------------------------------*
   *    Autogeneration							  *
   *----------------------------------------------------------------------*	
	
	clr.w		x		* Initialise les vars utilisees
	clr.w		y		* durant l'autogeneration
	move.w		#319,minx
	move.w		#199,miny
	clr.w		maxx
	clr.w		maxy

	lea.l		work,a0		* Efface le buffer de test
	move.w		#1999,d0	* pour effacement
eff:	clr.l		(a0)+
	dbra.w		d0,eff

	lea.l		autogen,a0	* buffer pour le code
	lea.l		work,a1		* buffer de travail
	move.w		#haut*long-1,d7	* 5000 points

gen:		* Boucle de generation

	*--------------------------------------------------------*
	* Gestion de la courbe:   renvoit les valeurs de x2 & y2 *
	* sur la courbe selon x1 & y1 sur le scrolltext          *
	*--------------------------------------------------------*
	
	move.l	a1,-(sp)

	move.w	x(pc),d0
	add.w	d0,d0
	move.l	#198,d1
	sub.w	y(pc),d1
	sub.w	y(pc),d1
	
	lea	cs,a1
	move.w	(a1,d0.w),d2
	muls.w	d1,d2
	swap	d2
	add.l	#160,d2
	move.w	d2,x2

	lea	sn,a1
	move.w	(a1,d0.w),d2
	muls.w	d1,d2
	swap	d2
	add.l	#100,d2
	move.w	d2,y2
		
	move.l	(sp)+,a1

	*--------------------------------------------------------*
	* Generation code selon x2 & y2				 *
	*--------------------------------------------------------*	
	
	move.w		maxx(pc),d0	* Gestion coordonnnees
	cmp.w		x2(pc),d0	* maximale pour parametrer
	bge.s		ok4		* le blitter de maniere 
	move.w		x2(pc),maxx	* optimale
ok4:	
	move.w		maxy(pc),d0
	cmp.w		y2(pc),d0
	bge.s		ok5
	move.w		y2(pc),maxy
ok5:	
	move.w		minx(pc),d0
	cmp.w		x2(pc),d0
	ble.s		ok6
	move.w		x2(pc),minx
ok6:	
	move.w		miny(pc),d0
	cmp.w		y2(pc),d0
	ble.s		ok7
	move.w		y2(pc),miny
ok7:	

	move.w		x(pc),d0
	and.w		#15,d0		* Si and(x,15)=0
	bne.s		nocharge	* on charge d4 avec du scrolltext
	move.w		#$3818,(a0)+	* Move.w (a0)+,d4
nocharge:
	move.w		#$d844,(a0)+	* Add.w	d4,d4
	move.w		#$6404,(a0)+	* Bcc.s	pc+4
	
	move.w		y2(pc),d1	* Calcul offset par rapport
	ext.l		d1		*
	lsl.l		#4,d1		*
	lsl.l		#4,d1		*
	move.w		x2(pc),d2	* au debut ecran selon x2 & y2 
	and.l		#$fff0,d2	* 
	lsr.w		#1,d2		*
	add.l		d2,d1		*

	move.l		d1,d3		* Offset sur buffer de travail
	lsr.l		#2,d3		* = Offset sur ecran / 4

	move.w		x2,d0		* Offset pixel
	and.w		#15,d0

	cmp.w		#8,d0		* Si pixel de destination sur
	blt.s		ok1		* le deuxieme octet du plan
	and.w		#7,d0		* adr dest + 1
	addq.w		#1,d1
	addq.w		#1,d3
ok1:
	neg.w		d0
	addq.w		#7,d0

	cmp.w		#4,d0		* Si and(x2,7)=4
	beq.s		spec		* methode Bset.b 
		
		****** Emploi de Or

	tst.b		(a1,d3.w)	* Octet deja adresse ?
	beq.s		movd	

	move.w		#$8129,(a0)	* sinon methode normale: Or.b
	lsl.w		#8,d0		* ou Move.b
	add.w		d0,d0
	add.w		d0,(a0)+
	bra.s		nospec

movd:	move.w		#$1340,(a0)	* Move.b
	add.w		d0,(a0)+
	move.b		#-1,(a1,d3.w)	* on signale que deja adresse
	bra.s		nospec

		***** Emploi de Bset
spec:	
	move.w		#$5e9,(a0)+	
	move.b		#-1,(a1,d3.w)	* on signale que deja adresse

nospec:
	sub.l		#32000,d1
	move.w		d1,(a0)+	* offset

	addq.w		#1,x
	cmp.w		#long,x
	bne.s		noincy
	move.w		#$5888,(a0)+
	clr.w		x
	addq.w		#1,y
noincy: 
	
	dbra.w		d7,gen		* encore et toujours des points

	move.w		#$4e75,(a0)+	* Rts

*-------------------------------------------------------------------------*
*   Animation								  *
*-------------------------------------------------------------------------*	
   *----------------------------------------------------------------------*
   *    Init blitter							  *
   *----------------------------------------------------------------------*	
	
	move.w	maxy(pc),d0	
	sub.w	miny(pc),d0		
	addq.w	#1,d0			* Hauteur en pixels
	move.w	d0,bhaut
	move.w	miny(pc),d0
	ext.l	d0
	lsl.l	#8,d0
	move.l	d0,offy	

	move.w	maxx(pc),d0		* Largeur en considerant
	and.w	#$fff0,d0		* l'ecran par paves de 16 pixels 
	move.w	minx(pc),d1		*
	and.w	#$fff0,d1		*
	move.w	d1,offblit		*
	sub.w	d1,d0			* Max - min
	lsr.w	#1,d0			* En octet (en considerant les 
	addq.w	#8,d0			*  4 plans )
	move.w	d0,d1			*
	lsr.w	#3,d0			*
	move.w	d0,blarg		* Largeur en nb de mots
	move.w	#264,d0			* Calcul increment vert dest
	sub.w	d1,d0
	
	move.w	d0,$ffff8a30.w		* increment vert dest
	move.w	#2,$ffff8a20.w		* increment hori source
	clr.w	$ffff8a22.w		* increment vert source
	move.b	#14,$ffff8a3d.w		* Decalage

anim:	move.w	#-1,flag		* Synchro Vbl
temp:	tst.w	flag
	bne.s	temp
	
	ifne	cpu
	clr.w	$ffff8240.w
	endc	
	
	move.l	ecran(pc),d0		* VIDEO BASE
	movep.l	d0,$8203-$8242(a6)
	bchg.b	#0,flip+1		* Gestion flipping
	move.l	flip(pc),d0
	add.l	ec(pc),d0
	move.l	d0,ecran

			***** GESTION DEFORMATION Z

	move.w		yzcurve(pc),d0		* Pointeur sur courbe Z
	add.w		iczcurve(pc),d0		
	beq		nega
	cmp.w		#199,d0			* Bouclage
	beq		nega
ok10:	move.w		d0,yzcurve
	mulu.w		#200,d0
	lea		(a2,d0.l),a2		
		
			***** GESTION MVT FLEXI
	
	move.w		point(pc),d0		* Pointeur sur courbe
	lea		xycurve(pc),a0		*
	move.l		2(a0,d0.w),d1		* Offset adr pour affichage
	add.l		ecran(pc),d1		* du flexi
	move.l		affp2(pc),affp3
	move.l		affp(pc),affp2
	move.l		d1,affp
	move.b		off(pc),$820f-$8242(a6)	* Offset VBL prec actif
	move.b		#44,off			* Calcul offset de ligne
	move.w		(a0,d0.w),d1		* pour VBL suivante
	bne.s		ok2
	addq.b		#4,off			* Offset de ligne + 4  
ok2:						* si offset pixel = 0
	move.w		pix(pc),d0	        * Offset pixel VBL prec
	move.b		d0,$8265-$8242(a6) 	* Offset pixel VBL prec
	move.w		d1,pix			* Offset pixel for next VBL	
	mulu.w		#2800,d0		* Table de couleur selon
	lea		(a5,d0.l),a5		* offset pixel
 
 	addq.w		#6,point		* de deplacement
	cmp.w		#360*6,point		*
	bne.s		ok8			*
	clr.w		point			*
ok8:	
			***** EFFACAGE AU BLITTER

	move.w		#8,$ffff8a2e.w		* Increment horiz dest	
	move.w		blarg(pc),$ffff8a36.w	* Horiz size
	clr.b		$ffff8a3a.w		* Mode demi teinte
	clr.b		$ffff8a3b.w		* Mode de superposition
	move.w		offblit(pc),d0
	ext.l		d0
	lsr.w		#1,d0
	move.l		affp3(pc),$ffff8a32.w 	* Dest
	add.l		d0,$ffff8a32.w
	move.l		offy(pc),d0
	add.l		d0,$ffff8a32.w	
	move.w		bhaut(pc),$ffff8a38.w	* Vert size
	bset.b		#6,$ffff8a3c.w		* Pas de partage de bus
	bset.b		#7,$ffff8a3c.w		* Go

			***** AFFICHAGE 

	lea		scroll,a0 
	move.l		affp(pc),a1		* Precharge les registres
	lea		32000(a1),a1		* Contrebalance offset
	movem.w		reg(pc),d0-d7		* translate durant generat
	jsr		autogen			* Routine de deformation

	addq.l		#1,general
	cmp.l		#10,general
	bne.s		yoyo
	lea		$ffff8240+16.w,a0
	rept	4
	move.l		#$7740774,(a0)+
	endr
yoyo:
	cmp.b		#57,$fffffc02.w		* Sortie si touche
	beq		ex

			***** GESTION DU SCROLL

	move.w		#2,$ffff8a2e.w		* Increment horiz dest	
	move.w		#22*16+2,$ffff8a36.w	* Horiz size
	move.b		#2,$ffff8a3a.w		* Mode demi teinte
	move.b		#3,$ffff8a3b.w		* Mode de superposition
	move.l		#scroll,$ffff8a24.w 	* Source
	move.l		#scroll-2,$ffff8a32.w 	* Dest
	move.w		#1,$ffff8a38.w		* Vert size
	bset.b		#6,$ffff8a3c.w		* Pas de partage de bus
	bset.b		#7,$ffff8a3c.w		* Go

	ifne	cpu
	move.w	#$7,$ffff8240.w
	endc	

	move.l		cpt(pc),d0		* Compteur general
	move.w		d0,d1			
	addq.l		#1,cpt			* On l'incremente
	and.w		#15,d1			* Si and(cpt,15)=0
	bne		anim			* Nouveau caractere
	lsr.l		#3,d0			*
	sub.l		a0,a0			*
	lea		text(pc),a1		* On repique l'offset du 
	move.w		(a1,d0.w),a0		* nouveau caractere dans
	cmp.w		#1920,a0		* (si caractere joker ->
	beq.s		ex			* on sort) la table du text
	add.l		#fnt,a0			* Adr caractere = 
						* offset+adr fnt 
	lea		scroll+40,a1		* Affichage sur buffer scroll
	rept		16	
	move.l		(a0)+,(a1)
	lea		44(a1),a1
	endr

	bra		anim			* Boucle

*-------------------------------------------------------------------------*
*    Reinits								  *
*-------------------------------------------------------------------------*	
	
ex:	lea	$ffff8240+16.w,a0
	rept	4
	clr.l	(a0)+
	endr

	move.w		#$2700,sr		* Restaure inters
	move.l		oldvbl(pc),$70.w	* Restaure vbl systeme
	clr.b		$fffffa1b.w	
	move.b		stim1(pc),$fffffa07.w	* Restaure tous niveaux MFP
	move.b		stim2(pc),$fffffa09.w
	move.w		#$2300,sr	
	
	moveq.l		#20,d0
temp2:	move.w		#$4c0,d2
	or.w		d0,d2
	add.w		#20,d2
	move.w		d2,$ffff8922.w
	move.w		#25000,d1
temp1:	move.l		4(sp),4(sp)
	dbra.w		d1,temp1
	dbra.w		d0,temp2

	clr.w		$ffff8900.w		* DMA off
	clr.b		$820f-$8242(a6)
	clr.b		$8265-$8242(a6)

	clr.w		$ffff8240.w		* Restaure couleurs
	move.w		#$666,$ffff8240+6.w

	clr.b		$ffff820a.w		* Synchro
		
	move.l		stack(pc),-(sp)		* Superviseur
	move.w		#32,-(sp)
	trap		#1
	addq.l		#6,sp
		
	clr.w		-(sp)
	move.l		oldscr(pc),-(sp)
	move.l		oldscr(pc),-(sp)
	move.w		#5,-(sp)
	trap		#14
	lea		12(sp),sp
		
	clr.w		-(sp)			* Fin
	trap		#1

nega:	neg.w		iczcurve
	bra		ok10

initsound:
	move.w		#$7ff,$ffff8924.w		* Init microwire
dmwr:	cmp.w		#$7ff,$ffff8924.w
	bne.s		dmwr
	move.w		#%10011101000,d0		* Volume max
	bsr		microwrite
	move.w		#%10010000000+aigus,d0		* Aigus 
	bsr		microwrite
	move.w		#%10001000000+graves,d0		* Graves
	bsr		microwrite
	rts

microwrite:
	move.w		d0,$ffff8922.w
	moveq.l		#127,d0
waitdma:dbra.w		d0,waitdma
	rts

*-------------------------------------------------------------------------*
*    Inters								  *
*-------------------------------------------------------------------------*	

vbl:	clr.w		flag
	lea		rasters,a5
	lea		zcurve,a2
	lea		curve(pc),a3
	addq.w		#2,ycurve
	cmp.w		#360*4,ycurve
	bne.s		noboucle
	clr.w		ycurve
noboucle:
	add.w		ycurve(pc),a3
	rte

hbl:	
	move.b		(a2)+,$8207-$8242(a6)
	move.w		(a3)+,a4
	lea		(a5,a4.w),a4
	move.l		(a4)+,(a6)+
	move.l		(a4)+,(a6)+
	move.l		(a4)+,(a6)+
	move.w		(a4)+,(a6)
	lea		14(a5),a5
	lea		-12(a6),a6
	rte

	Section 	data

*-------------------------------------------------------------------------*
*    Variables								  *
*-------------------------------------------------------------------------*	

stack:	dc.l	0
oldvbl:	dc.l	0
stim1:	dc.b	0
stim2:	dc.b	0
	even

offblit:	dc.w	0
ec:	dc.l	0
pix:	dc.w	0
off:	dc.w	48
point:	dc.w	0
affp:	dc.l	buffer_ec+6
affp2:	dc.l	buffer_ec+6
affp3:	dc.l	buffer_ec+6
flip:	dc.l	0
ecran:	dc.l	buffer_ec
x:	dc.w	0
y:	dc.w	0
x2:	dc.w	0
y2:	dc.w	0
flag:	dc.w	0
ycurve:	dc.w	0
cpt:	dc.l	0
oldscr: dc.l	0
posx:	dc.w	0
posy:	dc.w	0
maxx:	dc.w	0
maxy:	dc.w	0
minx:	dc.w	0
miny:	dc.w	0
offy:	dc.l	0
blarg:	dc.w	0
bhaut:	dc.w	0
general:	dc.l	0	
iczcurve:	dc.w	1
yzcurve:	dc.w	0

*-------------------------------------------------------------------------*
*    Buffers & Datas								  *
*-------------------------------------------------------------------------*	
reg:	dc.w	1
	dc.w	2
	dc.w	4
	dc.w	8
	dc.w	0
	dc.w	32
	dc.w	64
	dc.w	128

datline:incbin	"line.dat"

curve:	rept	360
	dc.w	0
	endr
	incbin  "hori_ras.dat"
	rept	360
	dc.w	0
	endr

xycurve:incbin	"xycurve.dat"

text:		incbin	"text.dat"  
	
fnt:		incbin	"fnt.dat"
zcurve:		incbin 	"zcurve2.dat"
rasters:	incbin	"raster3.dat"
cs:		incbin	"cos.dat"
sn:		incbin	"sin.dat"
sample:		incbin	"man.sam"

	Section		bss

scroll:		ds.w	22*16+2
work:		ds.l	4096
autogen:	ds.b	40000
buffer_ec:	ds.b	196608
