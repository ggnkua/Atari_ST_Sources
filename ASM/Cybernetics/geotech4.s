*-------------------------------------------------------------------------*
*									  *
*	GEOTECH   V 1.5				- CYBER SECTOR  1993 -	  *
*									  *
*-------------------------------------------------------------------------*

	output	g:\code\effects\fractal\geotech.prg

	opt 	o+

*-------------------------------------------------------------------------*
sat:		set	10
ambient:	set	128
size_tab:	set	5763
nb_coul_sup:	set	100
*-------------------------------------------------------------------------*

r:	set	12
v:	set	30
b:	set	18

r2:	set	8
v2:	set	23
b2:	set	14
*-------------------------------------------------------------------------*

	*-----------------------------------------------
	* Macros
	*-----------------------------------------------

rand:	macro					* Routine random
	move.w	(a6)+,d7
	cmp.l	#random_tab+size_tab*2,a6
	blt.s	.cont1
	lea	random_tab,a6
.cont1	subq.w	#1,d6
	and.w	d6,d7
	addq.w	#1,d6
	sub.w	d5,d7
	endm

	*-----------------------------------------------
	* Programme
	*-----------------------------------------------
	
	bra.l	image			* Datas image en debut de code 
help:	incbin	help.bin		
					* becoz relatif pc
image:

	clr.l	-(sp)			* Superviseur
	move.w	#32,-(sp)		*
	trap	#1			*
	addq.l	#6,sp			*

	move.l	#ecran1+4,d0
	and.l	#$fffffffc,d0
	move.l	d0,base

	move.w	#-1,-(sp)		* Test mode graphique
	move.w	#88,-(sp)		*
	trap	#14			*
	addq.l	#4,sp			*
	move.w	d0,oldrez		*

	bset.l	#5,d0			* 50 hz
	move.w	d0,-(sp)		*
	move.w	#88,-(sp)		*
	trap	#14			*
	addq.l	#4,sp			*

	move.w	#2,-(sp)		* Adresse phybase
	trap	#14			*
	addq.l	#2,sp			*
	move.l	d0,oldadr		*

	move.w	#%100,-(sp)		* Fixe mode graphique et 
	move.w	#3,-(sp)		* nouvelle adresse
	move.l	base(pc),-(sp)		*
	move.l	base(pc),-(sp)		*
	move.w	#5,-(sp)		*
	trap	#14			*
	lea	14(sp),sp		*

	dc.w	$a00a			* no mouse	

	move.w	#89,-(sp)		* Test type de moniteur
	trap	#14			* si VGA on saute
	addq.l	#2,sp			*
	cmp.w	#2,d0			*
	beq.s	border			* Sinon
	move.w	#60,$ffff82a6.w		*   no border
	move.w	#60+259*2,$ffff82a4.w	*
	move.w	#60,$ffff82a8.w		*   no border
	move.w	#60+259*2,$ffff82aa.w	*
border:
	clr.l	$ffff9800.w		* Couleur de bordure a zero

	bsr	efface			* Efface l'ecran

	*-----------------------------------------------
	* Genere table de nombres aleatoires
	*-----------------------------------------------
	
	lea	random_tab(pc),a6	* Pointe sur table de chiffres
	move.w	#size_tab-1,d0		* aleatoires
b_rand:	movem.l	d0-a5,-(sp)
	move.w	#17,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,(a6)+	
	movem.l	(sp)+,d0-a5
	dbf.w	d0,b_rand

	*-----------------------------------------------
	* Genere table de cos vecteurs
	*-----------------------------------------------

	lea	pal(pc),a4		* Pointe sur palette degradee 
	lea	koef(pc),a0		* generale

	moveq.l	#-15,d6			* Delta 1
calcos1:moveq.l	#-15,d7			* Delta 2
calcos2:
	move.w	d6,d0
	move.w	d7,d1
	move.w	d0,d2			* Calcul scalaire
	move.w	d1,d3			*
	muls.w	xl(pc),d3		*
	muls.w	yl(pc),d2		*
	add.l	d2,d3			*
	add.l	zl(pc),d3		* d3 = produit scalaire * 64 * 64

	muls.w	d0,d0			* Calcul norme
	muls.w	d1,d1			*
	add.w	d1,d0			*
	addq.w	#1,d0			*
	move.w	(sqr_tab-pal,a4,d0.w*2),d1
					* => Norme * 256 dans d1
	
	divs.w	d1,d3			* => Cos * 64
	add.w	#64+ambient+sat,d3	* + light ambient + saturation 
	and.l	#$ffff,d3		* 	
	divu.w	#(ambient+64+64)/64,d3	* on ramene ceci sur 6 bits 
	
	cmp.w	#64,d3			* Limite max a 63 (6 bits)
	blt.s	popo			*
	moveq.l	#63,d3			*
popo:					*
	lsl.w	#1,d3			* On prÇmultiplie par deux pour
	move.w	d3,(a0)+		* eviter les coefficients d'echelle
					* Ö l'affichage du lightsourced

	addq.w	#1,d7			* Gestion boucle
	cmp.w	#17,d7
	bne.s	calcos2	
	
	addq.w	#1,d6			* Gestion boucle
	cmp.w	#16,d6
	bne.s	calcos1

	*-----------------------------------------------
	* Genere table de palette pre-degradee
	*-----------------------------------------------

	lea	predeg,a0	* Pointe sur table de predegrade
	lea	pal(pc),a4	* Pointe sur table de couleurs

	move.w	#319+nb_coul_sup,d0	
coul:	moveq.l	#0,d1		* Coef de degrade
	
deg:	move.w	(a4),d2		* On recupäre
	moveq.l	#31,d4
	and.w	d2,d4		* B
	moveq.l	#63,d5
	lsr.w	#5,d2
	and.w	d2,d5		* V
	lsr.w	#6,d2
	moveq.l	#31,d6
	and.w	d2,d6		* R

	mulu.w	d1,d4		* Composante * coef
	mulu.w	d1,d5		* 
	mulu.w	d1,d6		*

	lsr.l	#6,d4		* decale
	lsr.l	#6,d5		*
	lsr.l	#6,d6		* 

	lsl.w	#6,d6		* Recompose la couleur en 16 bits
	or.w	d5,d6		* Falcon
	lsl.w	#5,d6		*
	or.w	d4,d6		*
	move.w	d6,(a0)+	* et la place dans la table

	addq.w	#1,d1		* 64 niveaux de coef
	cmp.w	#64,d1	
	bne.s	deg
	addq.l	#2,a4		* Couleur suivante
	dbra.w	d0,coul		* Gestion boucle

	*-----------------------------------------------
	* Precharge registres
	*-----------------------------------------------		

	lea	random_tab(pc),a6	* Pointe sur table random
	lea	figure(pc),a0		* table vals initiales
	move.l	a0,usp

	*-----------------------------------------------
	* Main loop
	*-----------------------------------------------		

	bsr	genere			* Intro: map 2d
	bsr	affiche			* en non light source
	bsr	helpaff			* + boite d'aide

main:	move.b	$fffffc02.w,tch		*--------- Main loop ---------*

	cmp.b	#$1f,tch		* Help case
	bne.s	.next
	bsr	SaveImage
	bra	loop_tst
.next:
	cmp.b	#$62,tch		* Help case
	bne.s	tch_tst
	bsr	helpaff
	bra	loop_tst
tch_tst:
	cmp.b	#59,tch			* Else
	blt	loop_tst		*
	cmp.b	#64,tch			*
	bgt	loop_tst		*

	cmp.b	#59,tch			* F1
	bne.s	map_something		*
	bsr	genere			* Genere
	move.w	choix(pc),d0		*
	move.w	#-1,choix		*
	bra.s	no_get_ch		*
map_something:
	moveq.l	#0,d0			* F2 Ö F6
	move.b	tch(pc),d0		*
	sub.b	#60,d0			*
no_get_ch:
	cmp.w	choix(pc),d0		*
	beq.s	loop_tst		*
	tst.w	d0			* F2: 2D view
	sne.b	test			* pas d'effacement
	cmp.w	#3,d0			* F5: 2D view + lightsource
	bne.s	.aff2			*
	clr.b	test			* pas d'effacement
.aff2:	cmp.w	#4,d0			* F6: 3D view + lightsource
	bne.s	.aff3			*
	cmp.w	#2,choix		* Si choix
	sne.b	test			*
.aff3:	cmp.w	#2,d0			* F2: 3D view 
	bne.s	.aff4			*
	cmp.w	#4,choix		*	
	sne.b	test			*
.aff4:	cmp.w	#1,choix		* F3: Isometric
	bne.s	.aff5			*
	move.b	#-1,test		*
.aff5					*	
	tst.b	test			*
	beq.s	aff_something		*
	bsr	efface			*
aff_something:
	move.w	d0,choix		* Dernier choix
	lea	mode_aff(pc),a0		*
	and.w	#$ff,d0			*
	jsr	([a0,d0.w*4])		* Jump to correct routine

loop_tst:
	cmp.b	#57,tch
	beq.s	fin
	bra	main

fin:	move.w	oldrez(pc),-(sp)	* Retablit le mode graphique
	move.w	#3,-(sp)		*
	move.l	oldadr(pc),-(sp)	*
	move.l	oldadr(pc),-(sp)	*
	move.w	#5,-(sp)		*
	trap	#14			*
	lea	14(sp),sp		*

	dc.w	$a009			* et Hop mouse	
	
	clr.w	-(sp)			* Fin
	trap	#1

*-------------------------------------------------------------------------*
	*-----------------------------------------------
	* Genere le tableau
	*-----------------------------------------------
genere:
	move.w	#-1,test
	
	lea	pointer(pc),a5		* Table de pointer

	*-----------------------------------------------
	*  init les vals du tableau
	*-----------------------------------------------

	move.l	usp,a0
	move.w	(a0)+,([a5])		*tab(0,0)
	move.w	(a0)+,(128*2,[a5])	*tab(128,0)
	move.w	(a0)+,(256*2,[a5])	*tab(256,0)
	move.w	(a0)+,([128*4,a5]) 	*tab(0,128)
	move.w	(a0)+,(128*2,[128*4,a5]) *tab(128,128)
	move.w	(a0)+,(256*2,[128*4,a5]) *tab(256,128)
	move.w	(a0)+,([256*4,a5]) 	 *tab(0,256)
	move.w	(a0)+,(128*2,[256*4,a5]) *tab(128,256)
	move.w	(a0)+,(256*2,[256*4,a5]) *tab(256,256)

	cmp.l	#f_figure,a0		* test depassement tableau
	bne.s	suivant
	lea	figure(pc),a0		
suivant: 
	move.l	a0,usp	

	moveq.l	#0,d5
	moveq.l	#0,d6
	move.w	#256,d6			* Inc2 * 2
	move.w	#128,d5			* Inc1 * 2
	lea	512.w,a1

incloop:				********
					* 1 ere PASSE
	moveq.l	#0,d4			* Y = 0
loop1_1:
	move.w	d5,d3			* X = Ic1 * 2
	move.l	(a5,d4.w*2),a4		* A4 = Pointer sur ligne Y
	move.w	(a4),d2			* Old
	add.l	d5,a4			* Pointe en X (cad ic1)
	lea	(a4,d5.w),a3		* A3 = Pointe en X + ic1 
loop1_2:			
	move.w	d2,d0			* old dans acc
	move.w	(a3),d2			* old = new
	add.w	d2,d0			* new + old
	asr.w	#1,d0			* div 2
	rand				* + nombre alÇatoire
	add.w	d7,d0			* 
	move.w	d0,(a4)			* Tab(x,y)=...
	add.l	d6,a3			* Incremente adresse
	add.l	d6,a4			* Incremente adresse
	add.w	d6,d3			* Add x,ic2

	cmp.w	a1,d3			* Gestion boucles
	blt.s	loop1_2			*
	add.w	d6,d4			*
	cmp.w	a1,d4			*
	ble.s	loop1_1			*


					* 2 em PASSE
	moveq.l	#0,d3			* X = 0
loop2_1:
	move.w	d5,d4			* Y = Ic1 * 2
	move.w	([a5],d3.w),d2		* old = tab(0,X)
	lea	(a5,d6.w),a4		* Pointe sur pointer Y (ic1)
	lea	(a4,d6.w),a3		* Pointe sur pointer Y + ic1
loop2_2:			
	move.w	d2,d0			* old dans acc
	move.w	([a3],d3.w),d2		* new
	add.w	d2,d0			* new + old
	asr.w	#1,d0			* div 2
	rand				* + nombre alÇatoire
	add.w	d7,d0			* 
	move.w	d0,([a4],d3.w)		* Tab(x,y)=...
	lea	(a3,d6.w*2),a3		* Gestion adresses
	lea	(a4,d6.w*2),a4

	add.w	d6,d4			* Add y,ic2

	cmp.w	a1,d4			* Gestion boucles
	blt.s	loop2_2			*
	add.w	d6,d3			*
	cmp.w	a1,d3			*
	ble.s	loop2_1			*

					* 3 em PASSE
	move.w	d5,d4			* Y = Ic1
loop3_1:
	move.w	d5,d3			* X = Ic1
	lea	(a5,d4.w*2),a4		* Pointe sur pointer ligne Y
	lea	([a4,d6.w]),a3		* Pointe sur 0,Y+ic1
	move.w	(a3),d1			* old2
	add.l	d6,a3			* X+ic1,Y+ic1

	neg.w	d6			*
	lea	([a4,d6.w]),a2		* Pointe sur 0,Y-ic1 
	neg.w	d6			*
	move.w	(a2),d2			* old
	add.l	d6,a2			* X+ic1,Y-ic1
	lea	([a4],d3.w),a4		* Pointe sur X,Y
	
loop3_2:			
	move.w	d2,d0			* new +
	move.w	(a2),d2			* new = tab(x,y+ic1) 
	add.w	d2,d0			* old
	
	add.w	d1,d0
	move.w	(a3),d1
	add.w	d1,d0	

	asr.w	#2,d0
	rand				* + nombre alÇatoire
	add.w	d7,d0			* 

	move.w	d0,(a4)			* Tab(x,y)=...

	add.l	d6,a2			* Gestion adresses
	add.l	d6,a3	
	add.l	d6,a4
	add.w	d6,d3			* Add y,ic2
	
	cmp.w	a1,d3			* Gestion boucles
	blt.s	loop3_2			*
	add.w	d6,d4			*
	cmp.w	a1,d4			*
	ble.s	loop3_1			*

	move.w	d5,d6			* Inc2 = Inc1
	lsr.w	#1,d5			* Div Inc1,2
	and.w	#-2,d5
	bne	incloop			* Boucle increments
	rts

	*-----------------------------------------------
	* Affiche la carte contenu dans map en 2D
	*-----------------------------------------------

affiche:lea	pal(pc),a2		* Pointe sur palette simple
	lea	pointer(pc),a5		* Pointe sur table de pointeurs
	lea	ecran1+(640-256*2)/2+640,a1
	move.w	#255,d0

loopy:	move.l	(a5)+,a0		* Pointeur sur table ligne dans a0
	moveq.l	#7,d3			*
loopx:	rept	32			*
	move.w	(a0)+,d2		* Hauteur dans map
	move.w	(a2,d2.w*2),(a1)+	* Affiche sur l'ecran
	endr				*
	dbra.w	d3,loopx		*
	lea	640-256*2(a1),a1	*
	dbra.w	d0,loopy		*
	rts				*

	*----------------------------------------------------------
	* Affiche la carte contenu dans map en 2D avec lightsource
	*----------------------------------------------------------

aff_light:
	move.l	a6,-(sp)		* Sauve pointeur sur table aleatoire
	lea	pal(pc),a4		* Pointe sur palette simple 
	lea	pointer(pc),a5		* Pointe sur table de pointeurs
	lea	ecran1+(640-256*2)/2+640,a1
	move.w	#255,d6			* Hauteur table - 1 (car 2 points
					* necessaires pour 1 pixel 
					* lightsource)

lloopy:	move.l	(a5)+,a3		* Pointe sur ligne
	move.l	(a5),a6			* Pointe sur ligne suivante
	move.w	#255,d7			* Largeur table -1 (car ...)
lloopx:	
	moveq.l	#0,d4			* Mot de poids fort Ö zero
	move.w	(a3)+,d4
					* Calcul lightsource
	move.w	(a6)+,d0		* tab(x,y+1)
	move.w	(a3),d1			* tab(x+1,y)
	sub.w	d4,d0			* tab(x,y+1)-tab(x,y)
	sub.w	d4,d1			* tab(x+1,y)-tab(x,y)

	tst.w	d4			* Limite d4 en positif
	bpl.s	posit
	moveq.l	#0,d4
posit:			

	lea	(coef+16*2-pal,a4,d1.w*2),a0
	asl.w	#6,d0			* Delta1*2+Delta2*64 = position
	move.w	(a0,d0.w),d3		* Coef lightsource dans d3
	lsl.l	#7,d4			* Hauteur * 128 + coef = position
	lea	(predeg-pal,a4,d4.l),a0	* dans la table de predegradÇ
	move.w	(a0,d3.w),(a1)+		* Affiche

	dbra.w	d7,lloopx		* Boucle largeur
	lea	640-256*2(a1),a1	* Offset ecran
	dbra.w	d6,lloopy		* Boucle hauteur

	move.l	(sp)+,a6		* Restaure registre (pointeur sur 
					* table aleatoire)
	rts

	*-----------------------------------------------
	* Efface l'ecran
	*-----------------------------------------------

efface:
	lea	ecran1,a0		* Efface l'ecran
	moveq.l #0,d1			*
	move.w	#258*2-1,d2		*
eff:	rept	80			*
	move.l	d1,(a0)+		*
	endr				*
	dbra.w	d2,eff			*
	rts

	*-----------------------------------------------
	* Visualisation isometrique de la map
	*-----------------------------------------------

isometric:	
	
	move.l	a6,-(sp)		* Sauve le pointeur sur table
					* aleatoire
	lea	sequence(pc),a6		* Table de commande incrementations
	lea	pointer(pc),a5		* Pointe sur table de pointeurs
	lea	pal(pc),a4		* Pointe sur palette 
	lea	ecran1+320+100*640,a1	* Pointe sur ecran

	moveq.l	#0,d6			* Registres a zero
	moveq.l	#0,d5			* 
	moveq.l	#7,d2			* Precharge registres
	moveq.l	#127,d3			*
	move.w  	#256,d0			*
	
loopt:	move.w	#255,d1			*
	move.l	(a5)+,a0			* 
	move.l	a1,a2			*
loopi:
	move.w	(a0)+,d4			*	
	move.w	d4,d7			*
	sub.w	d3,d7			*	
	bgt.s	okette			*
	moveq.l	#0,d7			*
okette:	lsr.w	#3,d7			*
	move.w	(a4,d4.w*2),d4		* Couleur
	
	move.l	a2,a3			* Vline
line:	move.w	d4,(a3)			*
	lea	-640(a3),a3		*
	dbra.w	d7,line			*

	add.w	(a6,d6.w),a2		*
	addq.w	#2,d6			*
	and.w	d2,d6			*

	dbra.w	d1,loopi
	
	move.w	(a0)+,d7		*
	sub.w	d3,d7			*	
	bgt.s	oket3			*
	moveq.l	#0,d7			*
oket3:	lsr.w	#3,d7			*
	
	lea	640*8(a2),a3		* Affichage bord + 8 pixel de haut
	addq.w	#8,d7			* pour la base
line3:	move.w	#r2*2048+v2*32+b2,(a3)	* Vline
	lea	-640(a3),a3		*
	dbra.w	d7,line3		*

	add.w	seq2-sequence(a6,d5.w),a1
	addq.w	#2,d5			*
	and.w	d2,d5			*

	dbra.w	d0,loopt		*

	move.l	-(a5),a0		*** Affichage du bord
	move.l	a1,a2			*
	move.w	#256,d1
loopi2: move.w	(a0)+,d7		* 
	sub.w	d3,d7			*	
	bgt.s	oket			*
	moveq.l	#0,d7			*
oket:	lsr.w	#3,d7			*

	lea	640*8(a2),a3		* + 8 pixels haut pour la base

	addq.w	#8,d7
line2:	move.w	#r*2048+v*32+b,(a3)	* Vline
	lea	-640(a3),a3		*
	dbra.w	d7,line2		*

	add.w	(a6,d6.w),a2		*
	addq.w	#2,d6			*
	and.w	d2,d6			*

	dbra.w	d1,loopi2

	move.l	(sp)+,a6		* Restaure pointeur sur table
					* aleatoire
	rts

	*-----------------------------------------------
	* Visualisation 3D de la map
	*-----------------------------------------------

aff_3d:
	lea	pointer(pc),a5		* Pointe sur pointeurs map
	lea	pal(pc),a4		* Pointe sur palette	
	lea	ecran1,a0
	move.w	#512,d7			* d7 = Z
	moveq.l	#0,d4			* Mot de poids fort a zero

loop1:	move.l	#200*256,d6		* d6 = Y1 (= 256*200/z)
	divu.w	d7,d6			*
	mulu.w	#640,d6			*
	lea	(a0,d6.l),a2		*

	move.l	(a5)+,a3		* Pointeur sur ligne

	move.w	#-128*256,d5
loop2:	move.w	(a3)+,d4		* Valeur dans z
	move.l	d4,d3			*
	sub.w	#127,d3			* Hauteur de l'eau
	bpl.s	oke			*
	moveq.l	#0,d3			*
oke:	mulu.w	#40,d3			*
	divu.w	d7,d3			* Bordel / z
	
	move.w	d5,d2			* Xp
	ext.l	d2			*
	divs.w	d7,d2			*
	add.w	#160,d2			*

	move.w	(a4,d4.w*2),d4		* Couleur

	lea	(a2,d2.w*2),a1		* Vertical line
vline:	move.w	d4,(a1)			* 
	lea	-640(a1),a1		*
	dbra.w	d3,vline		*

	add.w	#256,d5			* Gestion boucle
	bvc.s	loop2			*

	subq.w	#1,d7			* Gestion boucle
	cmp.w	#255,d7
	bne.s	loop1

	add.l	#128000,a0		**** Affichage bord
	move.l	-(a5),a3
	move.w	#-128*256,d5

loop21:	move.w	(a3)+,d3		* Valeur dans z
	sub.w	#127,d3			*
	bpl.s	oke1			*
	moveq.l	#0,d3			*
oke1:	mulu.w	#40,d3			*
	divu.w	d7,d3			* Bordel / z
	
	move.w	d5,d2			* Xp
	ext.l	d2			*
	divs.w	d7,d2			*
	add.w	#160,d2			*

	lea	(a0,d2.w*2,5120),a1	* + 8 pixel haut pour base
	addq.w	#8,d3			*
vline1:	move.w	#r*2048+v*32+b,(a1)	*
	lea	-640(a1),a1		*
	dbra.w	d3,vline1		*

	add.w	#256,d5			*
	bvc.s	loop21			*

	rts

	*-----------------------------------------------
	* Visualisation 3D de la map avec lightsource
	*-----------------------------------------------


aff_3d_light:

	move.l	a6,-(sp)		* Sauvegarde pointeur sur table
					* aleatoire
	lea	pointer(pc),a5		* Pointe sur pointeurs map
	lea	pal(pc),a4		* Pointe sur palette	
	lea	ecran1,a0		* Pointe sur ecran
	move.w	#512,d7			* d7 = Z

lloop1:
	move.l	#200*256,d6		* d6 = Y1 (= 256*200/z)
	divu.w	d7,d6			*
	mulu.w	#640,d6			*
	lea	(a0,d6.l),a2		*

	move.l	(a5)+,a3		* Pointe sur ligne
	move.l	(a5),a6			* Pointe sur ligne suivante

	move.w	#-128*256,d5		*
lloop2:	moveq.l	#0,d4			* Mot de poids fort a zero
	move.w	(a3)+,d4		* Hauteur
	move.l	d4,d3			*
	sub.w	#127,d3			* Hauteur de l'eau a zero
	bpl.s	loke			*
	moveq.l	#0,d3			* 
loke:	mulu.w	#40,d3			*
	divu.w	d7,d3			* Bordel / z
	
	move.w	d5,d2			* Xp
	ext.l	d2			*
	divs.w	d7,d2			*
	add.w	#160,d2			*

	cmp.w	#50,d4			* Eau non lightsource point par 
	bge.s	okli			* point en dessous de 50

	tst.w	d4			* Limite en positif
	bpl.s	popom			*
	moveq.l	#0,d4			*
popom:
	move.w	(coef+16*2-pal,a4),d1	* Coef general d'incidence par
	lsl.l	#7,d4			* rapport a l'eau
	lea	(predeg-pal,a4,d4.l),a1	* Pointe sur couleur correspondante 
	move.w	(a1,d1.w),d4		* Affiche

	addq.l	#2,a6			* Suivant
	bra.s	laff			* Go to vline


okli:					** Calcul lightsource
	move.w	(a6)+,d0		* tab(x,y+1)
	move.w	(a3),d1			* tab(x+1,y)
	sub.w	d4,d0			* tab(x,y+1)-tab(x,y)
	sub.w	d4,d1			* tab(x+1,y)-tab(x,y)
	
	lea	(coef+16*2-pal,a4,d1.w*2),a1
	asl.w	#6,d0			* Coef selon Delta1 et Delta2
	move.w	(a1,d0.w),d1		*

	lsl.l	#7,d4			* Couleur dans table predegrade 
	lea	(predeg-pal,a4,d4.l),a1 * selon hauteur et coef
	move.w	(a1,d1.w),d4		*

laff:	lea	(a2,d2.w*2),a1		* Vertical line
lvline:	move.w	d4,(a1)			*
	lea	-640(a1),a1		*
	dbra.w	d3,lvline		*

	add.w	#256,d5			* Gestion boucle
	bvc.s	lloop2			* 

	subq.w	#1,d7			* Gestion boucle
	cmp.w	#256,d7			*
	bne	lloop1			* 


	add.l	#128000,a0		** Affiche bord
	move.l	-(a5),a3
	move.w	#-128*256,d5

lloop21:	
	move.w	(a3)+,d3		* Valeur dans z	
	sub.w	#127,d3			*
	bpl.s	loke1			*
	moveq.l	#0,d3			*
loke1:	mulu.w	#40,d3			*
	divu.w	d7,d3			* Bordel / z
	
	move.w	d5,d2			* Xp
	ext.l	d2			*
	divs.w	d7,d2			*
	add.w	#160,d2			*

	lea	(a0,d2.w*2,5120),a1	*
	addq.w	#8,d3			*
lvline1:move.w	#r*2048+v*32+b,(a1)	*
	lea	-640(a1),a1		*
	dbra.w	d3,lvline1		*

	add.w	#256,d5			*
	bvc.s	lloop21			*

	move.l	(sp)+,a6		* Restaure pointeur aleatoire

	rts


	*-----------------------------------------------
	* Fractozoom 
	*-----------------------------------------------

*zoom:	
*	* d7	: X insertion	=>  d7<>0
*	* d6	: Y insertion	=>  d6<>0
*
*	lea	pointer+4(pc),a0
*	lea	-4(a0),a1
*	lea	pointer+257*4(pc),a3
*	lea	-4(a3),a4
*	
*	move.w	d7,d5
*	subq.w	#1,d5
*	move.l	(a1),a2			* Sauvegarde du pointeur sortant haut
*	move.l	(a4),a5			* Sauvegarde du pointeur sortant bas
*
*v_ins_h:				* Decalage de la table de pointeurs
*	move.l	(a0)+,(a1)+		* en haut
*	move.l	-(a3),-(a4)
*	dbra.w	d5,v_ins_h
*
*	move.l	a2,(a0)			* On reinsäre les pointeurs sortant
*	move.l	a5,(a4)		
*
*	bsr	affiche
*
*	rts

	*-----------------------------------------------
	* Help
	*-----------------------------------------------

helpaff:	
	lea	help,a0			* Pointe sur image
	lea	ecran1+84+60*640,a1
	move.w	#139,d0			* 199 lignes de haut
lopy:	move.w	#117,d1			* 270 lignes de large
lopx:	move.l	(a0)+,(a1)+			* Copy
	dbra.w	d1,lopx			*
	lea	640-236*2(a1),a1		*
	dbra.w	d0,lopy			*

	or.w	#$100,choix

	rts

SaveImage:
	clr.w	-(sp)
	pea	.Name(pc)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp

	move.w	#1,-(sp)
	pea	.Name(pc)
	move.w	#$3d,-(sp)
	trap	#1	
	addq.l	#8,sp
	move.w	d0,.Handle

	pea	.Size(pc)
	move.l	#4,-(sp)
	move.w	.Handle(pc),-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	
	pea	ecran1
	move.l	#320*256*2,-(sp)
	move.w	.Handle(pc),-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp

	move.w	.Handle(pc),-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp

	addq.b	#1,.Name+7		
	cmp.b	#65+26,.Name+7	
	bne.s	.Ok
	move.b	#65,.Name+7
.Ok:	
	rts

.Handle:	dc.w	0
.Size:	dc.w	320,256
.Name:	dc.b	"GEOTEK_A.16B",0

*-------------------------------------------------------------------------*
	Section	data	
*-------------------------------------------------------------------------*
choix:		ds.w	1

xl:		dc.w	170*8		* -xp
yl:		dc.w	-170*8		* yp
zl:		dc.l	85*8		* zp avec ||lum||=1

sequence:	dc.w	642
		dc.w	0
		dc.w	2
		dc.w	0

seq2:		dc.w	640
		dc.w	-2
		dc.w    0
		dc.w	-2

mode_aff:	dc.l	affiche
		dc.l	isometric
		dc.l	aff_3d
		dc.l	aff_light
		dc.l	aff_3d_light


sqr_tab:	incbin	"sqr_tab.bin"

		dcb.w	320,10		* Table de couleur simple 
pal:		incbin	pal.bin
		dcb.w	nb_coul_sup,-1

var:		set	0		* Table de pointeurs sur map 
pointer:	rept	257	
		dc.l	map+var*257*2
var:		set	var+1
		endr	

figure:					* Predefs cartes
 	dc.w	200
 	dc.w	100
 	dc.w	10
 	dc.w	200
 	dc.w	100
 	dc.w	0
 	dc.w	200
 	dc.w	100
 	dc.w	0
	
 	dc.w	200
 	dc.w	200
 	dc.w	200
 	dc.w	200
 	dc.w	0
 	dc.w	200
 	dc.w	200
 	dc.w	200
 	dc.w	200
	
 	dc.w	200
 	dc.w    200
 	dc.w	200
 	dc.w	200
 	dc.w	0
 	dc.w	0
 	dc.w	200
 	dc.w	0
 	dc.w	0
	
 	dc.w	0
 	dc.w	0
 	dc.w	0
 	dc.w	0
 	dc.w	350
 	dc.w	0
 	dc.w	0
 	dc.w	0
 	dc.w	0
		
 	dc.w	150
 	dc.w	200
 	dc.w	100
 	dc.w	150
 	dc.w	200
 	dc.w	100
 	dc.w	150
 	dc.w	200
 	dc.w	100

 	dc.w	200
 	dc.w	200
 	dc.w	200
 	dc.w	200
 	dc.w	150
 	dc.w	150
 	dc.w	150
 	dc.w	100
 	dc.w	50
	
 	dc.w	0
 	dc.w	50
 	dc.w	0
 	dc.w	100
 	dc.w	100
 	dc.w	100
 	dc.w	200
 	dc.w	200
 	dc.w	200
	
 	dc.w	200
 	dc.w	0
 	dc.w	200
 	dc.w	200
 	dc.w	0
 	dc.w	200
 	dc.w	200
 	dc.w	0
 	dc.w	200
	
	dc.w	30
	dc.w	30
	dc.w	30
	dc.w	30
	dc.w	200
	dc.w	30
	dc.w	30
	dc.w	30
	dc.w	30
	
	dc.w	200
	dc.w	200
	dc.w	200
	dc.w	200
	dc.w	200
	dc.w	200
	dc.w	200
	dc.w	200
	dc.w	200

	dc.w	100
	dc.w	100
	dc.w	100
	dc.w	200
	dc.w	300
	dc.w	200
	dc.w	100
	dc.w	100
	dc.w	100
f_figure:
	

*-------------------------------------------------------------------------*
	Section	bss
*-------------------------------------------------------------------------*
	ds.w	1

oldrez:		ds.w	1
oldadr:		ds.l	1
tch:		ds.w	1
test:		ds.w	1
base:		ds.l	1
koef:		ds.w	32*15
coef:		ds.w	32*16
random_tab	ds.w	size_tab
predeg:		ds.b	128*(320+nb_coul_sup)
map:		ds.b	257*257*2
ecran1:		ds.b	260*640

	End