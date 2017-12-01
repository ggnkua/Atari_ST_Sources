
 opt O+

* ------------------------------------------------------------------- *
* The Black Cats corp.			      			      *
* Screen Ecran MCS version II (3d hors vbl, merci Jean)		      *
* Date : 20/8/91					              *
* Code: Sharp Man - Doc Prof - Gfx: Es	    			      *
*								      *
* Members of TBC are : DocProf - Sharp Man - Conan - M.L.M. -         *
* The Beyonder, Chamalow, Bonon, Enculator, Double Jack		      *
* ------------------------------------------------------------------- *

* En cas de problŠme, 3614 Rtel2 bal Sharp Man
	
* superviseur
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	MOVE.W	#$2700,SR

* installe la nouvelle pile

	move.l	#new_pile,a7

* adresse ecran courant

	moveq.l	#0,d0
	move.b	$ffff8201.w,d0
	lsl.w	#8,d0
	move.b	$ffff8203.w,d0
	lsl.l	#8,d0
	move.l	d0,anc_ecran

* init ecran

	move.l	adimg,ecran

* Installe la vbl compteur

	move.l	$70.w,anc_vbl
	move.l	#vbl_compteur,$70.w
	move.w	#$2300,sr

* basse resolution

	move.b	$ffff8260.w,old_rez
	bsr	wait_vbl
	move.b	#0,$ffff8260.w

* souris off

	dc.w 	$a00a
	move.b	#$12,$fffffc02.w
	
* sauve palette 

	lea	old_pal,a0
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)

* couleurs noires

	lea	gabon,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

* presentation

	bsr	presentation
	
* initialisations

*	scroll

	move.b	#8,nb_bit

*	muzik

	moveq.l	#1,d0
	jsr	musique

*	3d

	move.l 	#routine,a0			* dans a0 se trouve toutes
	move.l 	#tbc,(a0)+			* les adresses des objets
	move.l 	#mcs,(a0)+			* 
	move.l 	#vas,(a0)+	
	move.l	#fig,(a0)+
	move.l	#hiboux,(a0)+	
	move.l	#pol,(a0)+
	move.l  #fle,(a0)+
	move.l	#hel,(a0)+
	move.l	#mas,(a0)+
	move.l	#con,(a0)+
	move.l	#soc,(a0)+
	move.l	#sab,(a0)+
	move.l	#vad,(a0)+		*  (methode sharpman)
	move.l	#squ,(a0)+
	move.l	#end,(a0)+

	lea	tbc,a0
	lea	cube,a1
	move.w	#35,d0
cop1	move.l	(a0)+,(a1)+
	dbf	d0,cop1

* efface les ‚crans

	move.l	cache,a0
	move.l	adimg,a1
	move.w	#7999+(50*160)/4,d0
	moveq.l	#0,d1
noir	move.l	d1,(a0)+
	move.l	d1,(a1)+
	dbf	d0,noir

* calcul de la table des ‚toiles

	bsr	calc_stars
	bsr	ini_etoiles

* recopie le motif … la con

	lea	f_adr+34+(160*56),a0
	move.l	#$6bd00-32000+(160*220),a1
	move.l	#$79f00-32000+(160*220),a2
	move.w	#(7*160)/4,d0
recop	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d0,recop

	move.w	#6,dec_coule

* installe la palette du haut.

	move.w	#$666,$ffff8248.w
	move.w	#$222,$ffff8250.w
	move.w	#$444,$ffff8258.w

* sauve registres timer & its

	move.w	#$2700,sr

	move.b	$fffffa07.w,mfp1
	move.b	$fffffa09.w,mfp2
	move.b	$fffffa0f.w,mfp3
	move.b	$fffffa13.w,mfp4
	move.b	$fffffa1b.w,mfp5
	move.b	$fffffa21.w,mfp6
	move.l	$120.w,anc_tb
	move.l	$118.w,anc_tc

* Installe la vbl & coupe timers

	move.l	#vbl,$70.w
	move.l	$118.w,fin_118
	move.l	#new_118,$118.w
	move.l	#new_120,$120.w
	move.b	#0,$fffffa07.w
	move.b	#0,$fffffa09.w
	bset	#0,$fffffa07.w
	bset	#0,$fffffa13.w

	move.w	#$2300,sr

* Boucle principale
	
boucle

	move.l	vvvbl,d0	* attends la fin de la vbl
cv	cmp.l	vvvbl,d0
	beq.s	cv

	bsr	swap		* swappe les ecrans
	bsr	efface		* efface l'‚cran
	bsr	la_3d		* 3d

	tst.w	fin_demo	* attends la fin de la d‚mo
	bne.s	fin		
	bra.s	boucle

* Reinstalle la Vbl & timers

fin:
	move.w	#$2700,sr
	move.l	anc_tb,$120.w
	move.l	anc_tc,$118.w
	move.b	mfp1,$fffffa07.w
	move.b	mfp2,$fffffa09.w
	move.b	mfp3,$fffffa0f.w
	move.b	mfp4,$fffffa13.w
	move.b	mfp5,$fffffa1b.w
	move.b	mfp6,$fffffa21.w
	move.l	#vbl_compteur,$70.w
	move.w	#$2300,sr

* Ecran 50 Hz
	
	bsr	wait_vbl           
	move.b	#2,$ffff820a.w
	move.b	old_rez,$ffff8260.w

* Reinstalle la vbl normale

	move.w	#$2700,sr
	move.l	anc_vbl,$70.w

* son off

	move.b	#8,$ffff8800.w
	move.b	#0,$ffff8802.w
	move.b	#9,$ffff8800.w
	move.b	#0,$ffff8802.w
	move.b	#10,$ffff8800.w
	move.b	#0,$ffff8802.w

* vielle palette

	lea	old_pal,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w


* ancien ‚cran

	move.l 	anc_ecran,d0
	lsr.l 	#8,d0
  	move.w 	#$8200,a0
  	movep.w d0,1(a0)

	ILLEGAL

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* sous programmes
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* --------------------------------------------------------------
* swap + init routine etoiles
* --------------------------------------------------------------

swap:

	move.l 	cache,adimg
	move.l 	ecran,cache
	move.l 	adimg,ecran
	move.l 	ecran,d0
	lsr.l 	#8,d0
  	move.w 	#$8200,a0
  	movep.w d0,1(a0)

* selon l'‚cran courant, selection de la routine d'‚toiles

	cmpi.l	#$6bd00-32000,ecran
	beq.s	rout_2

	move.l	#vbl_star_debut_1,routine_haut
	move.l	#vbl_star_1,routine_vbl
	rts
	
rout_2	move.l	#vbl_star_debut_2,routine_haut
	move.l	#vbl_star_2,routine_vbl
	rts

* --------------------------------------------------------------
* effacement de l'‚cran
* --------------------------------------------------------------

efface:

	move.l	ecran,a0			
	moveq	#0,d1				

t	set	160
	rept	200
	move.w	d1,(3*8)+t(a0)			
	move.w	d1,(4*8)+t(a0)			
	move.w	d1,(5*8)+t(a0)			
	move.w	d1,(6*8)+t(a0)			
	move.w	d1,(7*8)+t(a0)
	move.w	d1,(8*8)+t(a0)
	move.w	d1,(9*8)+t(a0)
	move.w	d1,(10*8)+t(a0)
	move.w	d1,(11*8)+t(a0)
	move.w	d1,(12*8)+t(a0)
	move.w	d1,(13*8)+t(a0)
	move.w	d1,(14*8)+t(a0)
	move.w	d1,(15*8)+t(a0)
	move.w	d1,(16*8)+t(a0)
	move.w	d1,(17*8)+t(a0)
t	set	t+160
	endr					
	rts

* -------------------------------------------------------------------
* la presentation
* -------------------------------------------------------------------

presentation:

* installe l'‚cran

	move.l 	ecran,d0
	lsr.l 	#8,d0
  	move.w 	#$8200,a0
  	movep.w d0,1(a0)
	
* le nettoie

	move.l	ecran,a0
	move.w	#(230*200)/4,d0
	moveq	#0,d1
raz	move.l	d1,(a0)+
	dbf	d0,raz
	
* palette image

	lea	image1+2,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

* recopie de l'image 1 … gauche de l'ecran

	lea	image1+34,a0
	move.l	ecran,a1
	lea	390(a1),a1
	lea	8(a1),a1
	move.w	#170,d0			
ingres	move.w	#39,d1
pci	move.l	(a0)+,(a1)+
	dbf	d1,pci
	lea	70(a1),a1
	dbf	d0,ingres

* la 2 a droite

	lea	image2+34,a0
	move.l	ecran,a1
	lea	390(a1),a1
	lea	104(a1),a1
	move.w	#150,d0			
ingres2	move.w	#29,d1
pci2	move.l	(a0)+,(a1)+
	dbf	d1,pci2
	lea	110(a1),a1
	lea	40(a0),a0
	dbf	d0,ingres2

* le bas normal

	lea	image1+34+(167*160),a0
	move.l	ecran,a1
	lea	390(a1),a1
	add.l	#(167*230)+72-2,a1
	move.w	#(160*34)/4,d0
haj	move.l	(a0)+,(a1)+
	dbf	d0,haj

* Installe Vbl

	move.w	#$2700,sr
	move.l	$70.w,memvbl
	move.l	#vbl_full,$70.w
	move.w	#$2300,sr

* Attends

attend_full
	cmpi.b	#$39,$fffffc02.w
	bne.s	attend_full

* Vide buffer clavier

bc2	cmpi.b	#$39,$fffffc02.w
	beq.s	bc2

* Coupe VBL
	
	move.w	#$2700,sr
	move.l	memvbl,$70.w
	move.w	#$2300,sr

* repasse les couleurs en noir

	lea	gabon,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

* sync

	bsr	wait_vbl
	move.b	#2,$ffff820a.w
	rts

* vbl full

vbl_full

	movem.l	d0-d7/a0-a6,-(a7)
	bsr.s	full 
	movem.l	(a7)+,d0-d7/a0-a6
	rte

* ---------------------------------------------------------------
* Full screen
* ---------------------------------------------------------------

full	
	move.l	#$FFFF8209,a3	* a3 = compteur video pour synchro au debut
	move.l	#$FFFF8260,a1	* a1 = registre r‚solution (70Hz)
	move.l	#$FFFF820a,a0	* a0 = registre synchro couleur (50, 60Hz)
	move.w	#168,d0		* d0 = nombre de ligne de full screen
	moveq	#0,d1		
	moveq	#0,d4
	moveq	#2,d3
	moveq	#$10,d6
	move.w	#$2700,sr

* Les lignes vir‚es

synchro	move.b	(a3),d7         * On se synchronise sur la 1Šre ligne
	beq.s	synchro
	sub.w	d7,d6		
	lsl.w	d6,d1		

	move.l	#image1+2,a6
	move.l	(a6)+,$ffff8240.w
	move.l	(a6)+,$ffff8244.w
	move.l	(a6)+,$ffff8248.w
	move.l	(a6)+,$ffff824C.w

	rept	97-24-3
	nop			
	endr
	
fullscreen

	move.b	d3,(a1)				* haute r‚solution 
	nop
	move.b	d4,(a1)				* basse r‚solution 
	rept	77+12
	nop					
	endr
	move.b	d4,(a0)				* 60 HZ	
	move.b	d3,(a0)				* 50 HZ	
	rept	13		
	nop
	endr
	move.b	d3,(a1)				* haute
	nop
	move.b	d4,(a1)				* basse 
	rept	9
	nop			 
	endr
	dbf	d0,fullscreen	

* allez on change la palette

	lea	palette2,a0
	movem.l	(a0),d0-d3
	movem.l	d0-d3,$ffff8240.w
	rts

palette2
	dc.w	0,7,6,5,4,3,2,1

* --------------------------------------------------------------
* attente de vbl normale du st 
* --------------------------------------------------------------

wait_vbl
	move.l	cp_466,d7
wait2	cmp.l	cp_466,d7
	beq.s	wait2
	rts

* -----------------------------------------------------------------
* vbl compteur
* -----------------------------------------------------------------

vbl_compteur:
	
	movem.l	d0-d7/a0-a6,-(a7)
	addq.l	#1,cp_466
	movem.l	(a7)+,d0-d7/a0-a6
	rte

* -----------------------------------------------------------------
* Routine VBL.
* -----------------------------------------------------------------

VBL	
	movem.l	d0-d7/a0-a6,-(a7)
	move.w	#$2700,sr

	addq.l	#1,vvvbl		* compteur vbl

* On reinstalle le timer b

	move.b	#0,$fffffa1b.w		
	move.l	#new_120,$120.w		
	move.b	#199,$fffffa21.w		
	move.b	#8,$fffffa1b.w		

* couleur etoiles + 3d

	move.w	#0,$ffff8240.w
	move.w	#$761,$ffff8242.w
	move.w	#$666,$ffff8248.w
	move.w	#$222,$ffff8250.w
	move.w	#$444,$ffff8258.w

* routines d'‚toiles 

	move.l	routine_haut,a0		* <- dur‚e fixe
	jsr	(a0)
	move.l	routine_vbl,a0		* <- dur‚e variable
	jsr	(a0)

* scroll 1 plan
	
	bsr	scroll_vbl		* <- dur‚e fixe
	bsr	fin_scroll		* <- dur‚e variable

* d‚goulinures dans le scroll

	bsr.s	fait_couler

* Musique mad max 

	jsr	musique+8
		
* Adieu ma poule...
		
	movem.l	(a7)+,d0-d7/a0-a6
	rte

* --------------------------------------------------------------------
* les degoulinures … la mords-moi-le-noeud
* --------------------------------------------------------------------

fait_couler

	subq.w	#1,vbl_coule
	bne.s	fin_coule
	move.w	#2,vbl_coule
	subq.w	#1,dec_coule
	blt.s	reinit_coule
	add.l	#32,ad_coule

fin_coule
	rts

reinit_coule
	move.l	#coule1,ad_coule
	move.w	#6,dec_coule
	rts

* --------------------------------------------------------------------
* la 3d
* --------------------------------------------------------------------

la_3d
	tst.w	variable		* si variable = 1
	bne	go			* transformation en cours

la_3d_suite:

	moveq	#24-1,d2		* 3 * 8 lignes
	lea	cube,a6
	lea	buffer,a5
	bsr	rotate
	lea	buffer,a5
	move.w	(a5),d0
	move.w	2(a5),d1
	move.w	6(a5),d2
	move.w	8(a5),d3
	bsr	trace
	move.w	6(a5),d0
	move.w	8(a5),d1
	move.w	12(a5),d2
	move.w	14(a5),d3
	bsr	trace
	move.w	12(a5),d0
	move.w	14(a5),d1
	move.w	18(a5),d2
	move.w	20(a5),d3
	bsr	trace
	move.w	18(a5),d0
	move.w	20(a5),d1
	move.w	0+24(a5),d2
	move.w	2+24(a5),d3
	bsr	trace
	move.w	0+24(a5),d0
	move.w	2+24(a5),d1
	move.w	6+24(a5),d2
	move.w	8+24(a5),d3
	bsr	trace
	move.w	6+24(a5),d0
	move.w	8+24(a5),d1
	move.w	12+24(a5),d2
	move.w	14+24(a5),d3
	bsr	trace
	move.w	12+24(a5),d0
	move.w	14+24(a5),d1
	move.w	18+24(a5),d2
	move.w	20+24(a5),d3
	bsr	trace
	move.w	18+24(a5),d0
	move.w	20+24(a5),d1
	move.w	(a5),d2
	move.w	2(a5),d3
	bsr	trace
	move.w	0+48(a5),d0
	move.w	2+48(a5),d1
	move.w	6+48(a5),d2
	move.w	8+48(a5),d3
	bsr	trace
	move.w	6+48(a5),d0
	move.w	8+48(a5),d1
	move.w	12+48(a5),d2
	move.w	14+48(a5),d3
	bsr	trace
	move.w	12+48(a5),d0
	move.w	14+48(a5),d1
	move.w	18+48(a5),d2
	move.w	20+48(a5),d3
	bsr	trace
	move.w	18+48(a5),d0
	move.w	20+48(a5),d1
	move.w	0+24+48(a5),d2
	move.w	2+24+48(a5),d3
	bsr	trace
	move.w	0+24+48(a5),d0
	move.w	2+24+48(a5),d1
	move.w	6+24+48(a5),d2
	move.w	8+24+48(a5),d3
	bsr	trace
	move.w	6+24+48(a5),d0
	move.w	8+24+48(a5),d1
	move.w	12+24+48(a5),d2
	move.w	14+24+48(a5),d3
	bsr	trace
	move.w	12+24+48(a5),d0
	move.w	14+24+48(a5),d1
	move.w	18+24+48(a5),d2
	move.w	20+24+48(a5),d3
	bsr	trace
	move.w	18+24+48(a5),d2
	move.w	20+24+48(a5),d3
	move.w	0+48(a5),d0
	move.w	2+48(a5),d1
	bsr	trace
	move.w	0+96(a5),d0
	move.w	2+96(a5),d1
	move.w	6+96(a5),d2
	move.w	8+96(a5),d3
	bsr	trace
	move.w	6+96(a5),d0
	move.w	8+96(a5),d1
	move.w	12+96(a5),d2
	move.w	14+96(a5),d3
	bsr	trace
	move.w	12+96(a5),d0
	move.w	14+96(a5),d1
	move.w	18+96(a5),d2
	move.w	20+96(a5),d3
	bsr	trace
	move.w	18+96(a5),d0
	move.w	20+96(a5),d1
	move.w	0+24+96(a5),d2
	move.w	2+24+96(a5),d3
	bsr	trace
	move.w	0+24+96(a5),d0
	move.w	2+24+96(a5),d1
	move.w	6+24+96(a5),d2
	move.w	8+24+96(a5),d3
	bsr	trace
	move.w	6+24+96(a5),d0
	move.w	8+24+96(a5),d1
	move.w	12+24+96(a5),d2
	move.w	14+24+96(a5),d3
	bsr	trace
	move.w	12+24+96(a5),d0
	move.w	14+24+96(a5),d1
	move.w	18+24+96(a5),d2
	move.w	20+24+96(a5),d3
	bsr	trace
	move.w	18+24+96(a5),d0
	move.w	20+24+96(a5),d1
	move.w	0+96(a5),d2
	move.w	2+96(a5),d3
	bsr	trace
	
* calcul du nouvel angle

	move.w 	angle+2,d1		* angle de rotation y
	add.w 	yplus,d1		* d1=d1+yplus
	cmp.w 	#360,d1			* d1>= 360 ???
	bge.s 	tesfin2			* alors d1=d1-360
	tst     d1			* d1<= -360 ???
	ble.s 	tesfin3			* alors d1=d1+360
	bra.s 	tesfin4			* sinon on continue...

tesfin2:
	sub.w 	#360,d1			* d1=d1-360 (0'=360')
	bra.s 	tesfin4

tesfin3:
	add.w 	#360,d1			* d1=d1+360 (0'=360')

tesfin4:
	move.w 	d1,angle+2		* angly prend sa nouvelle valeur
	move.w 	angle,d1		* meme chose avec anglx
	add.w 	xplus,d1
	cmp.w 	#360,d1
	bge.s 	tesfin5
	tst 	d1
	ble.s 	tesfin6
	bra.s 	tesfin7

tesfin5:
	sub.w 	#360,d1
	bra.s 	tesfin7

tesfin6:
	add.w 	#360,d1

tesfin7:
	move.w 	d1,angle		* anglx prend sa nouvelle valeur
	move 	angle+4,d1		* meme chose avec anglz
	add.w 	zplus,d1
	cmp.w 	#360,d1
	bge.s 	tesfin8			
	tst.w 	d1
	ble.s 	tesfin9
	bra.s 	tesfi10

tesfin8:
	sub.w 	#360,d1
	bra.s 	tesfi10

tesfin9:
	add.w 	#360,d1

tesfi10:
	move.w 	d1,angle+4
	
* test de touches v.2.0

	moveq	#0,d0
	move.b	$fffffc02.w,d0
	cmp.b	old_key,d0
	beq.s	fin_3d

	move.b	d0,old_key
	lea	key_rout,a0
	lsl	#2,d0
	move.l	(a0,d0),a1
	jmp	(a1)

fin_3d	rts

* --------------------------------------------------------------------
* tests de touche
* --------------------------------------------------------------------

* routines des touches

droite:	addq.w	#1,yplus
	rts
	
gauche:	subq.w	#1,yplus
	rts

bas:	addq.w	#1,xplus
	rts

haut:	subq.w	#1,xplus
	rts

help:	addq.w	#1,zplus
	rts

undo:	subq.w	#1,zplus
	rts

moins:	tst.w	variable
	bne.s	fin_3d

	subq.w 	#4,index			* on soustrait 1 a l'index
	bge.s	moins1
	move.w	#0,index
	rts

moins1:	
	move.w	#1,variable
	move.w 	index,d0
	lea 	routine,a0			* a0=routine
	move.l	(a0,d0),noucoord
	rts
	
plus:	tst.w	variable
	bne.s	fin_3d
	move.w	#1,variable

	cmpi.w	#14*4,index
	bge	fin_3d
	addq.w 	#4,index

plus1:  move.w 	index,d0
	lea 	routine,a0			* a0=routine
	move.l	(a0,d0),noucoord
	rts

sortie	move.w	#1,fin_demo
	rts

rotinit:
	move.w 	#0,d1			* parametre de depart
	move.w 	d1,xplus
	move.w 	d1,yplus
	move.w 	d1,zplus
	move.w 	d1,angle
	move.w 	d1,angle+2
	move.w 	d1,angle+4
	rts

* --------------------------------------------------------------------
* calcul de rotation
* --------------------------------------------------------------------

rotate:	

* routine de rotation x,y,z

* en entree nb_points        --> d2
*           coordonnees      --> a6
*           buffer de calcul --> a5

	movem.w	angle,d3-d5
	
	add.w	d3,d3
	add.w	d4,d4
	add.w	d5,d5
	lea	sinus_ro,a0
	lea	sin_x_ro(pc),a1
	move.w	(a0,d3.w),(a1)
	move.w	(a0,d4.w),4(a1)
	move.w	(a0,d5.w),8(a1)
	lea	sin_x_ro+180,a0
	lea	cos_x_ro(pc),a2
	move.w	(a0,d3.w),(a2)
	move.w	(a0,d4.w),4(a2)
	move.w	(a0,d5.w),8(a2)
	lea	sin_y_ro(pc),a3
	lea	sin_z_ro(pc),a4
calcul_ro
	move.w	d2,nb
	movem.w	(a6)+,d0-d2
	movem.w	(a1),d3-d4
	muls	d0,d4
	neg.w	d3
	muls	d1,d3
	add.l	d3,d4
	add.l	d4,d4
	swap	d4
	movem.w	(a1),d5-d6
	muls	d0,d5
	muls	d1,d6
	add.l	d6,d5
	add.l	d5,d5
	swap	d5
	movem.w	(a3),d0-d1
	muls	d4,d1
	neg.w	d0
	muls	d2,d0
	add.l	d1,d0
	add.l	d0,d0	
	swap	d0
	movem.w	(a3),d1/d3
	muls	d4,d1
	muls	d2,d3
	add.l	d1,d3
	add.l	d3,d3
	swap	d3
	movem.w	(a4),d6-d7
	muls	d5,d7
	neg.w	d3
	muls	d3,d6
	add.l	d6,d7
	add.l	d7,d7
	swap	d7
	movem.w	(a4),d1/d4
	muls	d5,d1
	muls	d3,d4
	add.l	d1,d4
	add.l	d4,d4
	swap	d4
	add.w	#160,d0
	add.w	#100,d7
	move.w	d0,(a5)+
	move.w	d7,(a5)+
	move.w	d4,(a5)+
	move.w	nb,d2
	dbra	d2,calcul_ro
	rts

* --------------------------------------------------------------------
* transformation
* --------------------------------------------------------------------

*********************************
* calcul transformation...      *
* start code : 31/8/91 at 23h00 *
* end code : 01/9/91 at 02h15   *
* Code by docprof 		*
* Idea by Vortex (thanks)	*
*********************************

go:
	movem.l	d0-d7/a0-a6,-(a7)
    	moveq.w	#0,d6
    	move.l	#cube,a0		* anciennes coord.
    	move.l  noucoord,a1
    	moveq.w	#71,d0			* soit 3*24 points

night:
	move.w	(a0),d1
	move.w	(a1)+,d2
	cmp.w	d1,d2
	beq.s	idem
	bmi.s	cond1
	addq.w	#1,d6			* modificatif d6<>0
	addq.w	#1,d1
	move.w	d1,(a0)+
	dbra	d0,night
	bra.s	aff
	
cond1:
	addq.w	#1,d6			* modificatif d6<>0
	subq.w	#1,d1
	move.w	d1,(a0)+
	dbra	d0,night
	bra.s	aff
	
idem:	MOVE.W	D1,(A0)+
	dbra	d0,night


aff:	tst.w	d6			* on test d6
	bne.s	nonfin			* tri non fini
	move.w	#0,variable
	movem.l	(a7)+,d0-d7/a0-a6
	bra	la_3d_suite
	
nonfin:
	movem.l	(a7)+,d0-d7/a0-a6
	bra	la_3d_suite

adresse:
	dc.l	tbc,mcs,vas,fig,hiboux,pol,fle,hel,mas,con,soc,sab,vad,squ,end

* ---------------------------------------------------------------------
* trace de droite
* ---------------------------------------------------------------------

* Trace d'une droite en ASM
* (C) 1991 Doc Prof 

* it's a lame code...    	
* routine droite classique
* inspiration by equinox
* code by docprof
* this routine was coded in 3h.
* for the screen of mcs.
* no opt.
    
trace:
	movem.l	d0-d7/a0-a6,-(a7)
    	move.w	d2,a2
    	move.w	d3,a3
    	move.w	d0,d2
    	move.w	d1,d3

	move.w 	a2,d6           	* d6 = x1
        sub.w 	d2,d6            	* d6 = x1-x0 = pente de la droite en X
        blt.s 	OUGA              	* si la droite monte en X -> dxpos
	EXG.L	D2,A2
	EXG.L	D3,A3
	NEG.W	D6
OUGA    neg.w 	d6               	* d6 = -dx donc d6>0 (la pente X est positive)

*	C'EST CE CAS LA
	
	move.w 	a3,d7           	* d7 = y1
 	sub.w 	d3,d7            	* d7 = y1-y0  = pente en Y
 	bLT.s 	OUGA2	           	* dy > 0 alors on dessine
	move.w	#1,d5			* offset Y = 160 -> A5
	move.w	#160,a5
	BRA.S	DUR 	
 	
OUGA2 	neg.w 	d7               	* sinon d7 = -dy donc d7>0 (la pente est positive)
	move.w	#0,d5			* on descent : offset = -160
	move.w  #-160,a5
	
dur:	MOVEQ.W	#1,D4
        
*	on calcule la position en mot sur l'‚cran du centre

*	Initialisation Y

	move.l	ecran,a0		* a0 = ecran
	lea	ordonnee,a3		* a1 = tableau ordonnee
	add.w	d3,d3			* mulu #2,d5
	add.w	(a3,d3.W),a0		* on se positionne sur le screen


*	Initialisation X

	lea	abscisse,a3		* a3 = tableau des abscisses
	add.w	d2,d2			* mulu #4,d1
	add.w	d2,d2			* mulu #4,d1
	add.w	(a3,d2.W),a0		* on se positionne sur le mot
	move.w	2(a3,d2.W),d2		* d2 = motif de bits 
	
suite_merde

*	ici l'on trace !  /  on choisit la routine...
	
	CMP.W	D7,D6
	BGE.s	non
	tst.w	d5
	bne	nonyz
	BRA	nony
	
* Trace de la droite (tox be improved)
	

*	Incrementation X


NON:	move.w	d6,d1
	move.w #320,d5
	sub.w	d1,d5
	add.w d5,d5
	move.w	d5,d1
	add.w d5,d5
	add.w d5,d5
	add.w d5,d5
	add.w d1,d5
	jmp   ha200(pc,d5.w)

HA200:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA201 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA201:add.w   d2,d2 
      bcc.s   HA202 
      moveq   #1,d2 
      subq.l  #8,a0 
HA202:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA203 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA203:add.w   d2,d2 
      bcc.s   HA204 
      moveq   #1,d2 
      subq.l  #8,a0 
HA204:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA205 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA205:add.w   d2,d2 
      bcc.s   HA206 
      moveq   #1,d2 
      subq.l  #8,a0 
HA206:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA207 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA207:add.w   d2,d2 
      bcc.s   HA208 
      moveq   #1,d2 
      subq.l  #8,a0 
HA208:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA209 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA209:add.w   d2,d2 
      bcc.s   HA20A 
      moveq   #1,d2 
      subq.l  #8,a0 
HA20A:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA20B 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA20B:add.w   d2,d2 
      bcc.s   HA20C 
      moveq   #1,d2 
      subq.l  #8,a0 
HA20C:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA20D 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA20D:add.w   d2,d2 
      bcc.s   HA20E 
      moveq   #1,d2 
      subq.l  #8,a0 
HA20E:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA20F 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA20F:add.w   d2,d2 
      bcc.s   HA210 
      moveq   #1,d2 
      subq.l  #8,a0 
HA210:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA211 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA211:add.w   d2,d2 
      bcc.s   HA212 
      moveq   #1,d2 
      subq.l  #8,a0 
HA212:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA213 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA213:add.w   d2,d2 
      bcc.s   HA214 
      moveq   #1,d2 
      subq.l  #8,a0 
HA214:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA215 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA215:add.w   d2,d2 
      bcc.s   HA216 
      moveq   #1,d2 
      subq.l  #8,a0 
HA216:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA217 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA217:add.w   d2,d2 
      bcc.s   HA218 
      moveq   #1,d2 
      subq.l  #8,a0 
HA218:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA219 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA219:add.w   d2,d2 
      bcc.s   HA21A 
      moveq   #1,d2 
      subq.l  #8,a0 
HA21A:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA21B 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA21B:add.w   d2,d2 
      bcc.s   HA21C 
      moveq   #1,d2 
      subq.l  #8,a0 
HA21C:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA21D 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA21D:add.w   d2,d2 
      bcc.s   HA21E 
      moveq   #1,d2 
      subq.l  #8,a0 
HA21E:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA21F 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA21F:add.w   d2,d2 
      bcc.s   HA220 
      moveq   #1,d2 
      subq.l  #8,a0 
HA220:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA221 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA221:add.w   d2,d2 
      bcc.s   HA222 
      moveq   #1,d2 
      subq.l  #8,a0 
HA222:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA223 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA223:add.w   d2,d2 
      bcc.s   HA224 
      moveq   #1,d2 
      subq.l  #8,a0 
HA224:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA225 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA225:add.w   d2,d2 
      bcc.s   HA226 
      moveq   #1,d2 
      subq.l  #8,a0 
HA226:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA227 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA227:add.w   d2,d2 
      bcc.s   HA228 
      moveq   #1,d2 
      subq.l  #8,a0 
HA228:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA229 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA229:add.w   d2,d2 
      bcc.s   HA22A 
      moveq   #1,d2 
      subq.l  #8,a0 
HA22A:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA22B 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA22B:add.w   d2,d2 
      bcc.s   HA22C 
      moveq   #1,d2 
      subq.l  #8,a0 
HA22C:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA22D 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA22D:add.w   d2,d2 
      bcc.s   HA22E 
      moveq   #1,d2 
      subq.l  #8,a0 
HA22E:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA22F 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA22F:add.w   d2,d2 
      bcc.s   HA230 
      moveq   #1,d2 
      subq.l  #8,a0 
HA230:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA231 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA231:add.w   d2,d2 
      bcc.s   HA232 
      moveq   #1,d2 
      subq.l  #8,a0 
HA232:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA233 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA233:add.w   d2,d2 
      bcc.s   HA234 
      moveq   #1,d2 
      subq.l  #8,a0 
HA234:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA235 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA235:add.w   d2,d2 
      bcc.s   HA236 
      moveq   #1,d2 
      subq.l  #8,a0 
HA236:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA237 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA237:add.w   d2,d2 
      bcc.s   HA238 
      moveq   #1,d2 
      subq.l  #8,a0 
HA238:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA239 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA239:add.w   d2,d2 
      bcc.s   HA23A 
      moveq   #1,d2 
      subq.l  #8,a0 
HA23A:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA23B 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA23B:add.w   d2,d2 
      bcc.s   HA23C 
      moveq   #1,d2 
      subq.l  #8,a0 
HA23C:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA23D 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA23D:add.w   d2,d2 
      bcc.s   HA23E 
      moveq   #1,d2 
      subq.l  #8,a0 
HA23E:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA23F 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA23F:add.w   d2,d2 
      bcc.s   HA240 
      moveq   #1,d2 
      subq.l  #8,a0 
HA240:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA241 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA241:add.w   d2,d2 
      bcc.s   HA242 
      moveq   #1,d2 
      subq.l  #8,a0 
HA242:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA243 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA243:add.w   d2,d2 
      bcc.s   HA244 
      moveq   #1,d2 
      subq.l  #8,a0 
HA244:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA245 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA245:add.w   d2,d2 
      bcc.s   HA246 
      moveq   #1,d2 
      subq.l  #8,a0 
HA246:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA247 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA247:add.w   d2,d2 
      bcc.s   HA248 
      moveq   #1,d2 
      subq.l  #8,a0 
HA248:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA249 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA249:add.w   d2,d2 
      bcc.s   HA24A 
      moveq   #1,d2 
      subq.l  #8,a0 
HA24A:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA24B 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA24B:add.w   d2,d2 
      bcc.s   HA24C 
      moveq   #1,d2 
      subq.l  #8,a0 
HA24C:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA24D 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA24D:add.w   d2,d2 
      bcc.s   HA24E 
      moveq   #1,d2 
      subq.l  #8,a0 
HA24E:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA24F 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA24F:add.w   d2,d2 
      bcc.s   HA250 
      moveq   #1,d2 
      subq.l  #8,a0 
HA250:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA251 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA251:add.w   d2,d2 
      bcc.s   HA252 
      moveq   #1,d2 
      subq.l  #8,a0 
HA252:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA253 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA253:add.w   d2,d2 
      bcc.s   HA254 
      moveq   #1,d2 
      subq.l  #8,a0 
HA254:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA255 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA255:add.w   d2,d2 
      bcc.s   HA256 
      moveq   #1,d2 
      subq.l  #8,a0 
HA256:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA257 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA257:add.w   d2,d2 
      bcc.s   HA258 
      moveq   #1,d2 
      subq.l  #8,a0 
HA258:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA259 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA259:add.w   d2,d2 
      bcc.s   HA25A 
      moveq   #1,d2 
      subq.l  #8,a0 
HA25A:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA25B 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA25B:add.w   d2,d2 
      bcc.s   HA25C 
      moveq   #1,d2 
      subq.l  #8,a0 
HA25C:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA25D 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA25D:add.w   d2,d2 
      bcc.s   HA25E 
      moveq   #1,d2 
      subq.l  #8,a0 
HA25E:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA25F 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA25F:add.w   d2,d2 
      bcc.s   HA260 
      moveq   #1,d2 
      subq.l  #8,a0 
HA260:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA261 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA261:add.w   d2,d2 
      bcc.s   HA262 
      moveq   #1,d2 
      subq.l  #8,a0 
HA262:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA263 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA263:add.w   d2,d2 
      bcc.s   HA264 
      moveq   #1,d2 
      subq.l  #8,a0 
HA264:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA265 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA265:add.w   d2,d2 
      bcc.s   HA266 
      moveq   #1,d2 
      subq.l  #8,a0 
HA266:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA267 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA267:add.w   d2,d2 
      bcc.s   HA268 
      moveq   #1,d2 
      subq.l  #8,a0 
HA268:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA269 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA269:add.w   d2,d2 
      bcc.s   HA26A 
      moveq   #1,d2 
      subq.l  #8,a0 
HA26A:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA26B 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA26B:add.w   d2,d2 
      bcc.s   HA26C 
      moveq   #1,d2 
      subq.l  #8,a0 
HA26C:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA26D 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA26D:add.w   d2,d2 
      bcc.s   HA26E 
      moveq   #1,d2 
      subq.l  #8,a0 
HA26E:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA26F 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA26F:add.w   d2,d2 
      bcc.s   HA270 
      moveq   #1,d2 
      subq.l  #8,a0 
HA270:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA271 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA271:add.w   d2,d2 
      bcc.s   HA272 
      moveq   #1,d2 
      subq.l  #8,a0 
HA272:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA273 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA273:add.w   d2,d2 
      bcc.s   HA274 
      moveq   #1,d2 
      subq.l  #8,a0 
HA274:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA275 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA275:add.w   d2,d2 
      bcc.s   HA276 
      moveq   #1,d2 
      subq.l  #8,a0 
HA276:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA277 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA277:add.w   d2,d2 
      bcc.s   HA278 
      moveq   #1,d2 
      subq.l  #8,a0 
HA278:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA279 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA279:add.w   d2,d2 
      bcc.s   HA27A 
      moveq   #1,d2 
      subq.l  #8,a0 
HA27A:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA27B 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA27B:add.w   d2,d2 
      bcc.s   HA27C 
      moveq   #1,d2 
      subq.l  #8,a0 
HA27C:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA27D 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA27D:add.w   d2,d2 
      bcc.s   HA27E 
      moveq   #1,d2 
      subq.l  #8,a0 
HA27E:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA27F 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA27F:add.w   d2,d2 
      bcc.s   HA280 
      moveq   #1,d2 
      subq.l  #8,a0 
HA280:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA281 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA281:add.w   d2,d2 
      bcc.s   HA282 
      moveq   #1,d2 
      subq.l  #8,a0 
HA282:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA283 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA283:add.w   d2,d2 
      bcc.s   HA284 
      moveq   #1,d2 
      subq.l  #8,a0 
HA284:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA285 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA285:add.w   d2,d2 
      bcc.s   HA286 
      moveq   #1,d2 
      subq.l  #8,a0 
HA286:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA287 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA287:add.w   d2,d2 
      bcc.s   HA288 
      moveq   #1,d2 
      subq.l  #8,a0 
HA288:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA289 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA289:add.w   d2,d2 
      bcc.s   HA28A 
      moveq   #1,d2 
      subq.l  #8,a0 
HA28A:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA28B 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA28B:add.w   d2,d2 
      bcc.s   HA28C 
      moveq   #1,d2 
      subq.l  #8,a0 
HA28C:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA28D 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA28D:add.w   d2,d2 
      bcc.s   HA28E 
      moveq   #1,d2 
      subq.l  #8,a0 
HA28E:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA28F 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA28F:add.w   d2,d2 
      bcc.s   HA290 
      moveq   #1,d2 
      subq.l  #8,a0 
HA290:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA291 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA291:add.w   d2,d2 
      bcc.s   HA292 
      moveq   #1,d2 
      subq.l  #8,a0 
HA292:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA293 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA293:add.w   d2,d2 
      bcc.s   HA294 
      moveq   #1,d2 
      subq.l  #8,a0 
HA294:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA295 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA295:add.w   d2,d2 
      bcc.s   HA296 
      moveq   #1,d2 
      subq.l  #8,a0 
HA296:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA297 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA297:add.w   d2,d2 
      bcc.s   HA298 
      moveq   #1,d2 
      subq.l  #8,a0 
HA298:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA299 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA299:add.w   d2,d2 
      bcc.s   HA29A 
      moveq   #1,d2 
      subq.l  #8,a0 
HA29A:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA29B 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA29B:add.w   d2,d2 
      bcc.s   HA29C 
      moveq   #1,d2 
      subq.l  #8,a0 
HA29C:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA29D 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA29D:add.w   d2,d2 
      bcc.s   HA29E 
      moveq   #1,d2 
      subq.l  #8,a0 
HA29E:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA29F 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA29F:add.w   d2,d2 
      bcc.s   HA2A0 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2A0:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2A1 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2A1:add.w   d2,d2 
      bcc.s   HA2A2 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2A2:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2A3 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2A3:add.w   d2,d2 
      bcc.s   HA2A4 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2A4:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2A5 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2A5:add.w   d2,d2 
      bcc.s   HA2A6 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2A6:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2A7 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2A7:add.w   d2,d2 
      bcc.s   HA2A8 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2A8:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2A9 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2A9:add.w   d2,d2 
      bcc.s   HA2AA 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2AA:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2AB 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2AB:add.w   d2,d2 
      bcc.s   HA2AC 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2AC:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2AD 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2AD:add.w   d2,d2 
      bcc.s   HA2AE 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2AE:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2AF 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2AF:add.w   d2,d2 
      bcc.s   HA2B0 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2B0:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2B1 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2B1:add.w   d2,d2 
      bcc.s   HA2B2 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2B2:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2B3 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2B3:add.w   d2,d2 
      bcc.s   HA2B4 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2B4:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2B5 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2B5:add.w   d2,d2 
      bcc.s   HA2B6 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2B6:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2B7 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2B7:add.w   d2,d2 
      bcc.s   HA2B8 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2B8:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2B9 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2B9:add.w   d2,d2 
      bcc.s   HA2BA 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2BA:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2BB 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2BB:add.w   d2,d2 
      bcc.s   HA2BC 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2BC:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2BD 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2BD:add.w   d2,d2 
      bcc.s   HA2BE 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2BE:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2BF 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2BF:add.w   d2,d2 
      bcc.s   HA2C0 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2C0:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2C1 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2C1:add.w   d2,d2 
      bcc.s   HA2C2 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2C2:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2C3 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2C3:add.w   d2,d2 
      bcc.s   HA2C4 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2C4:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2C5 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2C5:add.w   d2,d2 
      bcc.s   HA2C6 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2C6:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2C7 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2C7:add.w   d2,d2 
      bcc.s   HA2C8 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2C8:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2C9 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2C9:add.w   d2,d2 
      bcc.s   HA2CA 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2CA:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2CB 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2CB:add.w   d2,d2 
      bcc.s   HA2CC 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2CC:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2CD 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2CD:add.w   d2,d2 
      bcc.s   HA2CE 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2CE:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2CF 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2CF:add.w   d2,d2 
      bcc.s   HA2D0 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2D0:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2D1 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2D1:add.w   d2,d2 
      bcc.s   HA2D2 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2D2:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2D3 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2D3:add.w   d2,d2 
      bcc.s   HA2D4 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2D4:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2D5 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2D5:add.w   d2,d2 
      bcc.s   HA2D6 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2D6:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2D7 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2D7:add.w   d2,d2 
      bcc.s   HA2D8 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2D8:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2D9 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2D9:add.w   d2,d2 
      bcc.s   HA2DA 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2DA:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2DB 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2DB:add.w   d2,d2 
      bcc.s   HA2DC 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2DC:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2DD 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2DD:add.w   d2,d2 
      bcc.s   HA2DE 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2DE:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2DF 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2DF:add.w   d2,d2 
      bcc.s   HA2E0 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2E0:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2E1 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2E1:add.w   d2,d2 
      bcc.s   HA2E2 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2E2:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2E3 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2E3:add.w   d2,d2 
      bcc.s   HA2E4 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2E4:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2E5 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2E5:add.w   d2,d2 
      bcc.s   HA2E6 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2E6:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2E7 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2E7:add.w   d2,d2 
      bcc.s   HA2E8 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2E8:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2E9 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2E9:add.w   d2,d2 
      bcc.s   HA2EA 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2EA:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2EB 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2EB:add.w   d2,d2 
      bcc.s   HA2EC 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2EC:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2ED 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2ED:add.w   d2,d2 
      bcc.s   HA2EE 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2EE:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2EF 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2EF:add.w   d2,d2 
      bcc.s   HA2F0 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2F0:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2F1 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2F1:add.w   d2,d2 
      bcc.s   HA2F2 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2F2:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2F3 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2F3:add.w   d2,d2 
      bcc.s   HA2F4 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2F4:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2F5 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2F5:add.w   d2,d2 
      bcc.s   HA2F6 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2F6:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2F7 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2F7:add.w   d2,d2 
      bcc.s   HA2F8 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2F8:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2F9 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2F9:add.w   d2,d2 
      bcc.s   HA2FA 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2FA:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2FB 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2FB:add.w   d2,d2 
      bcc.s   HA2FC 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2FC:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2FD 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2FD:add.w   d2,d2 
      bcc.s   HA2FE 
      moveq   #1,d2 
      subq.l  #8,a0 
HA2FE:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA2FF 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA2FF:add.w   d2,d2 
      bcc.s   HA300 
      moveq   #1,d2 
      subq.l  #8,a0 
HA300:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA301 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA301:add.w   d2,d2 
      bcc.s   HA302 
      moveq   #1,d2 
      subq.l  #8,a0 
HA302:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA303 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA303:add.w   d2,d2 
      bcc.s   HA304 
      moveq   #1,d2 
      subq.l  #8,a0 
HA304:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA305 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA305:add.w   d2,d2 
      bcc.s   HA306 
      moveq   #1,d2 
      subq.l  #8,a0 
HA306:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA307 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA307:add.w   d2,d2 
      bcc.s   HA308 
      moveq   #1,d2 
      subq.l  #8,a0 
HA308:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA309 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA309:add.w   d2,d2 
      bcc.s   HA30A 
      moveq   #1,d2 
      subq.l  #8,a0 
HA30A:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA30B 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA30B:add.w   d2,d2 
      bcc.s   HA30C 
      moveq   #1,d2 
      subq.l  #8,a0 
HA30C:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA30D 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA30D:add.w   d2,d2 
      bcc.s   HA30E 
      moveq   #1,d2 
      subq.l  #8,a0 
HA30E:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA30F 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA30F:add.w   d2,d2 
      bcc.s   HA310 
      moveq   #1,d2 
      subq.l  #8,a0 
HA310:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA311 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA311:add.w   d2,d2 
      bcc.s   HA312 
      moveq   #1,d2 
      subq.l  #8,a0 
HA312:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA313 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA313:add.w   d2,d2 
      bcc.s   HA314 
      moveq   #1,d2 
      subq.l  #8,a0 
HA314:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA315 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA315:add.w   d2,d2 
      bcc.s   HA316 
      moveq   #1,d2 
      subq.l  #8,a0 
HA316:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA317 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA317:add.w   d2,d2 
      bcc.s   HA318 
      moveq   #1,d2 
      subq.l  #8,a0 
HA318:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA319 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA319:add.w   d2,d2 
      bcc.s   HA31A 
      moveq   #1,d2 
      subq.l  #8,a0 
HA31A:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA31B 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA31B:add.w   d2,d2 
      bcc.s   HA31C 
      moveq   #1,d2 
      subq.l  #8,a0 
HA31C:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA31D 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA31D:add.w   d2,d2 
      bcc.s   HA31E 
      moveq   #1,d2 
      subq.l  #8,a0 
HA31E:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA31F 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA31F:add.w   d2,d2 
      bcc.s   HA320 
      moveq   #1,d2 
      subq.l  #8,a0 
HA320:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA321 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA321:add.w   d2,d2 
      bcc.s   HA322 
      moveq   #1,d2 
      subq.l  #8,a0 
HA322:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA323 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA323:add.w   d2,d2 
      bcc.s   HA324 
      moveq   #1,d2 
      subq.l  #8,a0 
HA324:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA325 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA325:add.w   d2,d2 
      bcc.s   HA326 
      moveq   #1,d2 
      subq.l  #8,a0 
HA326:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA327 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA327:add.w   d2,d2 
      bcc.s   HA328 
      moveq   #1,d2 
      subq.l  #8,a0 
HA328:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA329 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA329:add.w   d2,d2 
      bcc.s   HA32A 
      moveq   #1,d2 
      subq.l  #8,a0 
HA32A:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA32B 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA32B:add.w   d2,d2 
      bcc.s   HA32C 
      moveq   #1,d2 
      subq.l  #8,a0 
HA32C:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA32D 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA32D:add.w   d2,d2 
      bcc.s   HA32E 
      moveq   #1,d2 
      subq.l  #8,a0 
HA32E:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA32F 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA32F:add.w   d2,d2 
      bcc.s   HA330 
      moveq   #1,d2 
      subq.l  #8,a0 
HA330:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA331 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA331:add.w   d2,d2 
      bcc.s   HA332 
      moveq   #1,d2 
      subq.l  #8,a0 
HA332:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA333 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA333:add.w   d2,d2 
      bcc.s   HA334 
      moveq   #1,d2 
      subq.l  #8,a0 
HA334:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA335 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA335:add.w   d2,d2 
      bcc.s   HA336 
      moveq   #1,d2 
      subq.l  #8,a0 
HA336:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA337 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA337:add.w   d2,d2 
      bcc.s   HA338 
      moveq   #1,d2 
      subq.l  #8,a0 
HA338:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA339 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA339:add.w   d2,d2 
      bcc.s   HA33A 
      moveq   #1,d2 
      subq.l  #8,a0 
HA33A:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA33B 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA33B:add.w   d2,d2 
      bcc.s   HA33C 
      moveq   #1,d2 
      subq.l  #8,a0 
HA33C:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA33D 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA33D:add.w   d2,d2 
      bcc.s   HA33E 
      moveq   #1,d2 
      subq.l  #8,a0 
HA33E:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA33F 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA33F:add.w   d2,d2 
      bcc.s   HA340 
      moveq   #1,d2 
      subq.l  #8,a0 
HA340:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA341 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA341:add.w   d2,d2 
      bcc.s   HA342 
      moveq   #1,d2 
      subq.l  #8,a0 
HA342:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA343 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA343:add.w   d2,d2 
      bcc.s   HA344 
      moveq   #1,d2 
      subq.l  #8,a0 
HA344:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA345 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA345:add.w   d2,d2 
      bcc.s   HA346 
      moveq   #1,d2 
      subq.l  #8,a0 
HA346:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA347 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA347:add.w   d2,d2 
      bcc.s   HA348 
      moveq   #1,d2 
      subq.l  #8,a0 
HA348:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA349 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA349:add.w   d2,d2 
      bcc.s   HA34A 
      moveq   #1,d2 
      subq.l  #8,a0 
HA34A:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA34B 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA34B:add.w   d2,d2 
      bcc.s   HA34C 
      moveq   #1,d2 
      subq.l  #8,a0 
HA34C:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA34D 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA34D:add.w   d2,d2 
      bcc.s   HA34E 
      moveq   #1,d2 
      subq.l  #8,a0 
HA34E:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA34F 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA34F:add.w   d2,d2 
      bcc.s   HA350 
      moveq   #1,d2 
      subq.l  #8,a0 
HA350:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA351 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA351:add.w   d2,d2 
      bcc.s   HA352 
      moveq   #1,d2 
      subq.l  #8,a0 
HA352:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA353 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA353:add.w   d2,d2 
      bcc.s   HA354 
      moveq   #1,d2 
      subq.l  #8,a0 
HA354:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA355 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA355:add.w   d2,d2 
      bcc.s   HA356 
      moveq   #1,d2 
      subq.l  #8,a0 
HA356:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA357 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA357:add.w   d2,d2 
      bcc.s   HA358 
      moveq   #1,d2 
      subq.l  #8,a0 
HA358:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA359 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA359:add.w   d2,d2 
      bcc.s   HA35B 
      moveq   #1,d2 
      subq.l  #8,a0 
HA35B:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA35C 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA35C:add.w   d2,d2 
      bcc.s   HA35D 
      moveq   #1,d2 
      subq.l  #8,a0 
HA35D:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA35E 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA35E:add.w   d2,d2 
      bcc.s   HA35F 
      moveq   #1,d2 
      subq.l  #8,a0 
HA35F:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA360 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA360:add.w   d2,d2 
      bcc.s   HA361 
      moveq   #1,d2 
      subq.l  #8,a0 
HA361:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA362 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA362:add.w   d2,d2 
      bcc.s   HA363 
      moveq   #1,d2 
      subq.l  #8,a0 
HA363:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA364 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA364:add.w   d2,d2 
      bcc.s   HA365 
      moveq   #1,d2 
      subq.l  #8,a0 
HA365:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA366 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA366:add.w   d2,d2 
      bcc.s   HA367 
      moveq   #1,d2 
      subq.l  #8,a0 
HA367:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA368 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA368:add.w   d2,d2 
      bcc.s   HA369 
      moveq   #1,d2 
      subq.l  #8,a0 
HA369:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA36A 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA36A:add.w   d2,d2 
      bcc.s   HA36B 
      moveq   #1,d2 
      subq.l  #8,a0 
HA36B:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA36C 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA36C:add.w   d2,d2 
      bcc.s   HA36D 
      moveq   #1,d2 
      subq.l  #8,a0 
HA36D:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA36E 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA36E:add.w   d2,d2 
      bcc.s   HA36F 
      moveq   #1,d2 
      subq.l  #8,a0 
HA36F:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA370 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA370:add.w   d2,d2 
      bcc.s   HA371 
      moveq   #1,d2 
      subq.l  #8,a0 
HA371:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA372 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA372:add.w   d2,d2 
      bcc.s   HA373 
      moveq   #1,d2 
      subq.l  #8,a0 
HA373:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA374 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA374:add.w   d2,d2 
      bcc.s   HA375 
      moveq   #1,d2 
      subq.l  #8,a0 
HA375:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA376 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA376:add.w   d2,d2 
      bcc.s   HA377 
      moveq   #1,d2 
      subq.l  #8,a0 
HA377:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA378 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA378:add.w   d2,d2 
      bcc.s   HA379 
      moveq   #1,d2 
      subq.l  #8,a0 
HA379:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA37A 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA37A:add.w   d2,d2 
      bcc.s   HA37B 
      moveq   #1,d2 
      subq.l  #8,a0 
HA37B:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA37C 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA37C:add.w   d2,d2 
      bcc.s   HA37D 
      moveq   #1,d2 
      subq.l  #8,a0 
HA37D:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA37E 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA37E:add.w   d2,d2 
      bcc.s   HA37F 
      moveq   #1,d2 
      subq.l  #8,a0 
HA37F:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA380 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA380:add.w   d2,d2 
      bcc.s   HA381 
      moveq   #1,d2 
      subq.l  #8,a0 
HA381:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA382 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA382:add.w   d2,d2 
      bcc.s   HA383 
      moveq   #1,d2 
      subq.l  #8,a0 
HA383:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA384 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA384:add.w   d2,d2 
      bcc.s   HA385 
      moveq   #1,d2 
      subq.l  #8,a0 
HA385:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA386 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA386:add.w   d2,d2 
      bcc.s   HA387 
      moveq   #1,d2 
      subq.l  #8,a0 
HA387:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA388 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA388:add.w   d2,d2 
      bcc.s   HA389 
      moveq   #1,d2 
      subq.l  #8,a0 
HA389:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA38A 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA38A:add.w   d2,d2 
      bcc.s   HA38B 
      moveq   #1,d2 
      subq.l  #8,a0 
HA38B:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA38C 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA38C:add.w   d2,d2 
      bcc.s   HA38D 
      moveq   #1,d2 
      subq.l  #8,a0 
HA38D:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA38E 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA38E:add.w   d2,d2 
      bcc.s   HA38F 
      moveq   #1,d2 
      subq.l  #8,a0 
HA38F:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA390 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA390:add.w   d2,d2 
      bcc.s   HA391 
      moveq   #1,d2 
      subq.l  #8,a0 
HA391:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA392 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA392:add.w   d2,d2 
      bcc.s   HA393 
      moveq   #1,d2 
      subq.l  #8,a0 
HA393:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA394 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA394:add.w   d2,d2 
      bcc.s   HA395 
      moveq   #1,d2 
      subq.l  #8,a0 
HA395:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA396 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA396:add.w   d2,d2 
      bcc.s   HA397 
      moveq   #1,d2 
      subq.l  #8,a0 
HA397:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA398 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA398:add.w   d2,d2 
      bcc.s   HA399 
      moveq   #1,d2 
      subq.l  #8,a0 
HA399:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA39A 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA39A:add.w   d2,d2 
      bcc.s   HA39B 
      moveq   #1,d2 
      subq.l  #8,a0 
HA39B:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA39C 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA39C:add.w   d2,d2 
      bcc.s   HA39D 
      moveq   #1,d2 
      subq.l  #8,a0 
HA39D:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA39E 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA39E:add.w   d2,d2 
      bcc.s   HA39F 
      moveq   #1,d2 
      subq.l  #8,a0 
HA39F:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3A0 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3A0:add.w   d2,d2 
      bcc.s   HA3A1 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3A1:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3A2 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3A2:add.w   d2,d2 
      bcc.s   HA3A3 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3A3:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3A4 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3A4:add.w   d2,d2 
      bcc.s   HA3A5 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3A5:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3A6 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3A6:add.w   d2,d2 
      bcc.s   HA3A7 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3A7:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3A8 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3A8:add.w   d2,d2 
      bcc.s   HA3A9 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3A9:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3AA 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3AA:add.w   d2,d2 
      bcc.s   HA3AB 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3AB:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3AC 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3AC:add.w   d2,d2 
      bcc.s   HA3AD 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3AD:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3AE 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3AE:add.w   d2,d2 
      bcc.s   HA3AF 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3AF:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3B0 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3B0:add.w   d2,d2 
      bcc.s   HA3B1 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3B1:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3B2 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3B2:add.w   d2,d2 
      bcc.s   HA3B3 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3B3:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3B4 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3B4:add.w   d2,d2 
      bcc.s   HA3B5 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3B5:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3B6 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3B6:add.w   d2,d2 
      bcc.s   HA3B7 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3B7:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3B8 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3B8:add.w   d2,d2 
      bcc.s   HA3B9 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3B9:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3BA 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3BA:add.w   d2,d2 
      bcc.s   HA3BB 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3BB:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3BC 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3BC:add.w   d2,d2 
      bcc.s   HA3BD 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3BD:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3BE 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3BE:add.w   d2,d2 
      bcc.s   HA3BF 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3BF:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3C0 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3C0:add.w   d2,d2 
      bcc.s   HA3C1 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3C1:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3C2 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3C2:add.w   d2,d2 
      bcc.s   HA3C3 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3C3:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3C4 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3C4:add.w   d2,d2 
      bcc.s   HA3C5 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3C5:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3C6 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3C6:add.w   d2,d2 
      bcc.s   HA3C7 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3C7:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3C8 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3C8:add.w   d2,d2 
      bcc.s   HA3C9 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3C9:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3CA 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3CA:add.w   d2,d2 
      bcc.s   HA3CB 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3CB:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3CC 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3CC:add.w   d2,d2 
      bcc.s   HA3CD 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3CD:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3CE 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3CE:add.w   d2,d2 
      bcc.s   HA3CF 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3CF:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3D0 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3D0:add.w   d2,d2 
      bcc.s   HA3D1 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3D1:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3D2 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3D2:add.w   d2,d2 
      bcc.s   HA3D3 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3D3:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3D4 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3D4:add.w   d2,d2 
      bcc.s   HA3D5 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3D5:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3D6 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3D6:add.w   d2,d2 
      bcc.s   HA3D7 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3D7:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3D8 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3D8:add.w   d2,d2 
      bcc.s   HA3D9 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3D9:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3DA 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3DA:add.w   d2,d2 
      bcc.s   HA3DB 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3DB:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3DC 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3DC:add.w   d2,d2 
      bcc.s   HA3DD 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3DD:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3DE 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3DE:add.w   d2,d2 
      bcc.s   HA3DF 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3DF:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3E0 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3E0:add.w   d2,d2 
      bcc.s   HA3E1 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3E1:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3E2 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3E2:add.w   d2,d2 
      bcc.s   HA3E3 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3E3:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3E4 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3E4:add.w   d2,d2 
      bcc.s   HA3E5 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3E5:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3E6 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3E6:add.w   d2,d2 
      bcc.s   HA3E7 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3E7:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3E8 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3E8:add.w   d2,d2 
      bcc.s   HA3E9 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3E9:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3EA 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3EA:add.w   d2,d2 
      bcc.s   HA3EB 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3EB:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3EC 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3EC:add.w   d2,d2 
      bcc.s   HA3ED 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3ED:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3EE 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3EE:add.w   d2,d2 
      bcc.s   HA3EF 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3EF:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3F0 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3F0:add.w   d2,d2 
      bcc.s   HA3F1 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3F1:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3F2 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3F2:add.w   d2,d2 
      bcc.s   HA3F3 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3F3:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3F4 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3F4:add.w   d2,d2 
      bcc.s   HA3F5 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3F5:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3F6 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3F6:add.w   d2,d2 
      bcc.s   HA3F7 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3F7:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3F8 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3F8:add.w   d2,d2 
      bcc.s   HA3F9 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3F9:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3FA 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3FA:add.w   d2,d2 
      bcc.s   HA3FB 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3FB:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3FC 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3FC:add.w   d2,d2 
      bcc.s   HA3FD 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3FD:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA3FE 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA3FE:add.w   d2,d2 
      bcc.s   HA3FF 
      moveq   #1,d2 
      subq.l  #8,a0 
HA3FF:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA400 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA400:add.w   d2,d2 
      bcc.s   HA401 
      moveq   #1,d2 
      subq.l  #8,a0 
HA401:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA402 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA402:add.w   d2,d2 
      bcc.s   HA403 
      moveq   #1,d2 
      subq.l  #8,a0 
HA403:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA404 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA404:add.w   d2,d2 
      bcc.s   HA405 
      moveq   #1,d2 
      subq.l  #8,a0 
HA405:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA406 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA406:add.w   d2,d2 
      bcc.s   HA407 
      moveq   #1,d2 
      subq.l  #8,a0 
HA407:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA408 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA408:add.w   d2,d2 
      bcc.s   HA409 
      moveq   #1,d2 
      subq.l  #8,a0 
HA409:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA40A 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA40A:add.w   d2,d2 
      bcc.s   HA40B 
      moveq   #1,d2 
      subq.l  #8,a0 
HA40B:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA40C 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA40C:add.w   d2,d2 
      bcc.s   HA40D 
      moveq   #1,d2 
      subq.l  #8,a0 
HA40D:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA40E 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA40E:add.w   d2,d2 
      bcc.s   HA40F 
      moveq   #1,d2 
      subq.l  #8,a0 
HA40F:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA410 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA410:add.w   d2,d2 
      bcc.s   HA411 
      moveq   #1,d2 
      subq.l  #8,a0 
HA411:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA412 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA412:add.w   d2,d2 
      bcc.s   HA413 
      moveq   #1,d2 
      subq.l  #8,a0 
HA413:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA414 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA414:add.w   d2,d2 
      bcc.s   HA415 
      moveq   #1,d2 
      subq.l  #8,a0 
HA415:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA416 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA416:add.w   d2,d2 
      bcc.s   HA417 
      moveq   #1,d2 
      subq.l  #8,a0 
HA417:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA418 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA418:add.w   d2,d2 
      bcc.s   HA419 
      moveq   #1,d2 
      subq.l  #8,a0 
HA419:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA41A 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA41A:add.w   d2,d2 
      bcc.s   HA41B 
      moveq   #1,d2 
      subq.l  #8,a0 
HA41B:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA41C 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA41C:add.w   d2,d2 
      bcc.s   HA41D 
      moveq   #1,d2 
      subq.l  #8,a0 
HA41D:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA41E 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA41E:add.w   d2,d2 
      bcc.s   HA41F 
      moveq   #1,d2 
      subq.l  #8,a0 
HA41F:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA420 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA420:add.w   d2,d2 
      bcc.s   HA421 
      moveq   #1,d2 
      subq.l  #8,a0 
HA421:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA422 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA422:add.w   d2,d2 
      bcc.s   HA423 
      moveq   #1,d2 
      subq.l  #8,a0 
HA423:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA424 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA424:add.w   d2,d2 
      bcc.s   HA425 
      moveq   #1,d2 
      subq.l  #8,a0 
HA425:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA426 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA426:add.w   d2,d2 
      bcc.s   HA427 
      moveq   #1,d2 
      subq.l  #8,a0 
HA427:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA428 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA428:add.w   d2,d2 
      bcc.s   HA429 
      moveq   #1,d2 
      subq.l  #8,a0 
HA429:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA42A 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA42A:add.w   d2,d2 
      bcc.s   HA42B 
      moveq   #1,d2 
      subq.l  #8,a0 
HA42B:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA42C 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA42C:add.w   d2,d2 
      bcc.s   HA42D 
      moveq   #1,d2 
      subq.l  #8,a0 
HA42D:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA42E 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA42E:add.w   d2,d2 
      bcc.s   HA42F 
      moveq   #1,d2 
      subq.l  #8,a0 
HA42F:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA430 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA430:add.w   d2,d2 
      bcc.s   HA431 
      moveq   #1,d2 
      subq.l  #8,a0 
HA431:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA432 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA432:add.w   d2,d2 
      bcc.s   HA433 
      moveq   #1,d2 
      subq.l  #8,a0 
HA433:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA434 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA434:add.w   d2,d2 
      bcc.s   HA435 
      moveq   #1,d2 
      subq.l  #8,a0 
HA435:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA436 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA436:add.w   d2,d2 
      bcc.s   HA437 
      moveq   #1,d2 
      subq.l  #8,a0 
HA437:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA438 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA438:add.w   d2,d2 
      bcc.s   HA439 
      moveq   #1,d2 
      subq.l  #8,a0 
HA439:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA43A 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA43A:add.w   d2,d2 
      bcc.s   HA43B 
      moveq   #1,d2 
      subq.l  #8,a0 
HA43B:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA43C 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA43C:add.w   d2,d2 
      bcc.s   HA43D 
      moveq   #1,d2 
      subq.l  #8,a0 
HA43D:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA43E 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA43E:add.w   d2,d2 
      bcc.s   HA43F 
      moveq   #1,d2 
      subq.l  #8,a0 
HA43F:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA440 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA440:add.w   d2,d2 
      bcc.s   HA441 
      moveq   #1,d2 
      subq.l  #8,a0 
HA441:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA442 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA442:add.w   d2,d2 
      bcc.s   HA443 
      moveq   #1,d2 
      subq.l  #8,a0 
HA443:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA444 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA444:add.w   d2,d2 
      bcc.s   HA445 
      moveq   #1,d2 
      subq.l  #8,a0 
HA445:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA446 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA446:add.w   d2,d2 
      bcc.s   HA447 
      moveq   #1,d2 
      subq.l  #8,a0 
HA447:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA448 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA448:add.w   d2,d2 
      bcc.s   HA449 
      moveq   #1,d2 
      subq.l  #8,a0 
HA449:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA44A 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA44A:add.w   d2,d2 
      bcc.s   HA44B 
      moveq   #1,d2 
      subq.l  #8,a0 
HA44B:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA44C 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA44C:add.w   d2,d2 
      bcc.s   HA44D 
      moveq   #1,d2 
      subq.l  #8,a0 
HA44D:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA44E 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA44E:add.w   d2,d2 
      bcc.s   HA44F 
      moveq   #1,d2 
      subq.l  #8,a0 
HA44F:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA450 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA450:add.w   d2,d2 
      bcc.s   HA451 
      moveq   #1,d2 
      subq.l  #8,a0 
HA451:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA452 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA452:add.w   d2,d2 
      bcc.s   HA453 
      moveq   #1,d2 
      subq.l  #8,a0 
HA453:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA454 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA454:add.w   d2,d2 
      bcc.s   HA455 
      moveq   #1,d2 
      subq.l  #8,a0 
HA455:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA456 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA456:add.w   d2,d2 
      bcc.s   HA457 
      moveq   #1,d2 
      subq.l  #8,a0 
HA457:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA458 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA458:add.w   d2,d2 
      bcc.s   HA459 
      moveq   #1,d2 
      subq.l  #8,a0 
HA459:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA45A 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA45A:add.w   d2,d2 
      bcc.s   HA45B 
      moveq   #1,d2 
      subq.l  #8,a0 
HA45B:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA45C 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA45C:add.w   d2,d2 
      bcc.s   HA45D 
      moveq   #1,d2 
      subq.l  #8,a0 
HA45D:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA45E 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA45E:add.w   d2,d2 
      bcc.s   HA45F 
      moveq   #1,d2 
      subq.l  #8,a0 
HA45F:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA460 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA460:add.w   d2,d2 
      bcc.s   HA461 
      moveq   #1,d2 
      subq.l  #8,a0 
HA461:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA462 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA462:add.w   d2,d2 
      bcc.s   HA463 
      moveq   #1,d2 
      subq.l  #8,a0 
HA463:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA464 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA464:add.w   d2,d2 
      bcc.s   HA465 
      moveq   #1,d2 
      subq.l  #8,a0 
HA465:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA466 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA466:add.w   d2,d2 
      bcc.s   HA467 
      moveq   #1,d2 
      subq.l  #8,a0 
HA467:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA468 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA468:add.w   d2,d2 
      bcc.s   HA469 
      moveq   #1,d2 
      subq.l  #8,a0 
HA469:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA46A 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA46A:add.w   d2,d2 
      bcc.s   HA46B 
      moveq   #1,d2 
      subq.l  #8,a0 
HA46B:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA46C 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA46C:add.w   d2,d2 
      bcc.s   HA46D 
      moveq   #1,d2 
      subq.l  #8,a0 
HA46D:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA46E 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA46E:add.w   d2,d2 
      bcc.s   HA46F 
      moveq   #1,d2 
      subq.l  #8,a0 
HA46F:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA470 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA470:add.w   d2,d2 
      bcc.s   HA471 
      moveq   #1,d2 
      subq.l  #8,a0 
HA471:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA472 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA472:add.w   d2,d2 
      bcc.s   HA473 
      moveq   #1,d2 
      subq.l  #8,a0 
HA473:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA474 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA474:add.w   d2,d2 
      bcc.s   HA475 
      moveq   #1,d2 
      subq.l  #8,a0 
HA475:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA476 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA476:add.w   d2,d2 
      bcc.s   HA477 
      moveq   #1,d2 
      subq.l  #8,a0 
HA477:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA478 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA478:add.w   d2,d2 
      bcc.s   HA479 
      moveq   #1,d2 
      subq.l  #8,a0 
HA479:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA47A 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA47A:add.w   d2,d2 
      bcc.s   HA47B 
      moveq   #1,d2 
      subq.l  #8,a0 
HA47B:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA47C 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA47C:add.w   d2,d2 
      bcc.s   HA47D 
      moveq   #1,d2 
      subq.l  #8,a0 
HA47D:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA47E 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA47E:add.w   d2,d2 
      bcc.s   HA47F 
      moveq   #1,d2 
      subq.l  #8,a0 
HA47F:or.w    d2,(a0) 
      add.w   d7,d4 
      ble.s   HA480 
      sub.w   d6,d4 
      adda.w  a5,a0 
HA480:add.w   d2,d2 
      bcc.s   HA481 
      moveq   #1,d2 
      subq.l  #8,a0 
HA481:*or.w    d2,(a0) 
      movem.l	(a7)+,d0-d7/a0-a6
      rts


	**************************************************************
	*        DEUXIEME ROUTINE................                    *
	**************************************************************

*	Incrementation Y

NONy:  	
	

	*add.w	a5,a0		* on passe a la ligne suivante
	move.w	 d7,d1
	
	lea	ordonnee,a3		* a1 = tableau ordonnee
	add.w	d1,d1			* mulu #2,d5
	move.w	(a3,d1.W),a1		* on se positionne sur le screen
	sub.w	a1,a0
	move.w	 d7,d1
	move.w #200,d5
	sub.w	 d1,d5
	add.w    d5,d5
	move.w   d5,d1
	add.w    d5,d5
	add.w    d5,d5
	add.w    d5,d5
	add.w	 d1,d5
	jmp	ho(pc,d5.w)

ho	or.w	d2,32000(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho1
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho1
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho1	or.w	d2,31840(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho2
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho2
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho2	or.w	d2,31680(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho3
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho3
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho3	or.w	d2,31520(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho4
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho4
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho4	or.w	d2,31360(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho5
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho5
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho5	or.w	d2,31200(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho6
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho6
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho6	or.w	d2,31040(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho7
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho7
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho7	or.w	d2,30880(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho8
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho8
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho8	or.w	d2,30720(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho9
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho9
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho9	or.w	d2,30560(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho10
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho10
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho10	or.w	d2,30400(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho11
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho11
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho11	or.w	d2,30240(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho12
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho12
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho12	or.w	d2,30080(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho13
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho13
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho13	or.w	d2,29920(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho14
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho14
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho14	or.w	d2,29760(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho15
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho15
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho15	or.w	d2,29600(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho16
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho16
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho16	or.w	d2,29440(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho17
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho17
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho17	or.w	d2,29280(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho18
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho18
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho18	or.w	d2,29120(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho19
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho19
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho19	or.w	d2,28960(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho20
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho20
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho20	or.w	d2,28800(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho21
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho21
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho21	or.w	d2,28640(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho22
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho22
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho22	or.w	d2,28480(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho23
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho23
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho23	or.w	d2,28320(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho24
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho24
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho24	or.w	d2,28160(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho25
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho25
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho25	or.w	d2,28000(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho26
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho26
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho26	or.w	d2,27840(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho27
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho27
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho27	or.w	d2,27680(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho28
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho28
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho28	or.w	d2,27520(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho29
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho29
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho29	or.w	d2,27360(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho30
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho30
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho30	or.w	d2,27200(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho31
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho31
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho31	or.w	d2,27040(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho32
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho32
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho32	or.w	d2,26880(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho33
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho33
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho33	or.w	d2,26720(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho34
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho34
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho34	or.w	d2,26560(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho35
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho35
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho35	or.w	d2,26400(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho36
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho36
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho36	or.w	d2,26240(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho37
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho37
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho37	or.w	d2,26080(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho38
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho38
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho38	or.w	d2,25920(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho39
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho39
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho39	or.w	d2,25760(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho40
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho40
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho40	or.w	d2,25600(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho41
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho41
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho41	or.w	d2,25440(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho42
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho42
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho42	or.w	d2,25280(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho43
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho43
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho43	or.w	d2,25120(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho44
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho44
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho44	or.w	d2,24960(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho45
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho45
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho45	or.w	d2,24800(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho46
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho46
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho46	or.w	d2,24640(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho47
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho47
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho47	or.w	d2,24480(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho48
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho48
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho48	or.w	d2,24320(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho49
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho49
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho49	or.w	d2,24160(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho50
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho50
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho50	or.w	d2,24000(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho51
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho51
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho51	or.w	d2,23840(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho52
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho52
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho52	or.w	d2,23680(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho53
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho53
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho53	or.w	d2,23520(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho54
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho54
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho54	or.w	d2,23360(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho55
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho55
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho55	or.w	d2,23200(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho56
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho56
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho56	or.w	d2,23040(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho57
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho57
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho57	or.w	d2,22880(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho58
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho58
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho58	or.w	d2,22720(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho59
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho59
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho59	or.w	d2,22560(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho60
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho60
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho60	or.w	d2,22400(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho61
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho61
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho61	or.w	d2,22240(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho62
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho62
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho62	or.w	d2,22080(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho63
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho63
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho63	or.w	d2,21920(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho64
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho64
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho64	or.w	d2,21760(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho65
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho65
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho65	or.w	d2,21600(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho66
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho66
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho66	or.w	d2,21440(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho67
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho67
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho67	or.w	d2,21280(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho68
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho68
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho68	or.w	d2,21120(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho69
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho69
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho69	or.w	d2,20960(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho70
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho70
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho70	or.w	d2,20800(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho71
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho71
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho71	or.w	d2,20640(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho72
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho72
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho72	or.w	d2,20480(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho73
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho73
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho73	or.w	d2,20320(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho74
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho74
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho74	or.w	d2,20160(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho75
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho75
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho75	or.w	d2,20000(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho76
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho76
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho76	or.w	d2,19840(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho77
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho77
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho77	or.w	d2,19680(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho78
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho78
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho78	or.w	d2,19520(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho79
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho79
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho79	or.w	d2,19360(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho80
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho80
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho80	or.w	d2,19200(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho81
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho81
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho81	or.w	d2,19040(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho82
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho82
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho82	or.w	d2,18880(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho83
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho83
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho83	or.w	d2,18720(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho84
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho84
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho84	or.w	d2,18560(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho85
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho85
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho85	or.w	d2,18400(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho86
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho86
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho86	or.w	d2,18240(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho87
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho87
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho87	or.w	d2,18080(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho88
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho88
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho88	or.w	d2,17920(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho89
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho89
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho89	or.w	d2,17760(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho90
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho90
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho90	or.w	d2,17600(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho91
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho91
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho91	or.w	d2,17440(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho92
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho92
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho92	or.w	d2,17280(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho93
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho93
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho93	or.w	d2,17120(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho94
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho94
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho94	or.w	d2,16960(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho95
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho95
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho95	or.w	d2,16800(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho96
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho96
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho96	or.w	d2,16640(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho97
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho97
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho97	or.w	d2,16480(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho98
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho98
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho98	or.w	d2,16320(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho99
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho99
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho99	or.w	d2,16160(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho100
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho100
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho100	or.w	d2,16000(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho101
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho101
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho101	or.w	d2,15840(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho102
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho102
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho102	or.w	d2,15680(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho103
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho103
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho103	or.w	d2,15520(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho104
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho104
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho104	or.w	d2,15360(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho105
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho105
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho105	or.w	d2,15200(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho106
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho106
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho106	or.w	d2,15040(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho107
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho107
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho107	or.w	d2,14880(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho108
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho108
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho108	or.w	d2,14720(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho109
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho109
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho109	or.w	d2,14560(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho110
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho110
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho110	or.w	d2,14400(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho111
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho111
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho111	or.w	d2,14240(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho112
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho112
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho112	or.w	d2,14080(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho113
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho113
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho113	or.w	d2,13920(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho114
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho114
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho114	or.w	d2,13760(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho115
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho115
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho115	or.w	d2,13600(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho116
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho116
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho116	or.w	d2,13440(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho117
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho117
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho117	or.w	d2,13280(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho118
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho118
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho118	or.w	d2,13120(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho119
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho119
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho119	or.w	d2,12960(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho120
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho120
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho120	or.w	d2,12800(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho121
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho121
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho121	or.w	d2,12640(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho122
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho122
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho122	or.w	d2,12480(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho123
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho123
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho123	or.w	d2,12320(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho124
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho124
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho124	or.w	d2,12160(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho125
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho125
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho125	or.w	d2,12000(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho126
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho126
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho126	or.w	d2,11840(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho127
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho127
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho127	or.w	d2,11680(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho128
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho128
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho128	or.w	d2,11520(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho129
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho129
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho129	or.w	d2,11360(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho130
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho130
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho130	or.w	d2,11200(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho131
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho131
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho131	or.w	d2,11040(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho132
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho132
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho132	or.w	d2,10880(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho133
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho133
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho133	or.w	d2,10720(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho134
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho134
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho134	or.w	d2,10560(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho135
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho135
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho135	or.w	d2,10400(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho136
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho136
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho136	or.w	d2,10240(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho137
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho137
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho137	or.w	d2,10080(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho138
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho138
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho138	or.w	d2,9920(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho139
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho139
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho139	or.w	d2,9760(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho140
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho140
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho140	or.w	d2,9600(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho141
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho141
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho141	or.w	d2,9440(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho142
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho142
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho142	or.w	d2,9280(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho143
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho143
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho143	or.w	d2,9120(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho144
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho144
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho144	or.w	d2,8960(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho145
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho145
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho145	or.w	d2,8800(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho146
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho146
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho146	or.w	d2,8640(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho147
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho147
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho147	or.w	d2,8480(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho148
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho148
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho148	or.w	d2,8320(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho149
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho149
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho149	or.w	d2,8160(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho150
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho150
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho150	or.w	d2,8000(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho151
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho151
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho151	or.w	d2,7840(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho152
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho152
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho152	or.w	d2,7680(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho153
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho153
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho153	or.w	d2,7520(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho154
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho154
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho154	or.w	d2,7360(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho155
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho155
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho155	or.w	d2,7200(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho156
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho156
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho156	or.w	d2,7040(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho157
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho157
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho157	or.w	d2,6880(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho158
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho158
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho158	or.w	d2,6720(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho159
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho159
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho159	or.w	d2,6560(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho160
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho160
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho160	or.w	d2,6400(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho161
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho161
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho161	or.w	d2,6240(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho162
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho162
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho162	or.w	d2,6080(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho163
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho163
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho163	or.w	d2,5920(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho164
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho164
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho164	or.w	d2,5760(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho165
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho165
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho165	or.w	d2,5600(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho166
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho166
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho166	or.w	d2,5440(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho167
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho167
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho167	or.w	d2,5280(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho168
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho168
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho168	or.w	d2,5120(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho169
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho169
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho169	or.w	d2,4960(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho170
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho170
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho170	or.w	d2,4800(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho171
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho171
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho171	or.w	d2,4640(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho172
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho172
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho172	or.w	d2,4480(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho173
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho173
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho173	or.w	d2,4320(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho174
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho174
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho174	or.w	d2,4160(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho175
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho175
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho175	or.w	d2,4000(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho176
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho176
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho176	or.w	d2,3840(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho177
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho177
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho177	or.w	d2,3680(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho178
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho178
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho178	or.w	d2,3520(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho179
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho179
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho179	or.w	d2,3360(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho180
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho180
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho180	or.w	d2,3200(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho181
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho181
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho181	or.w	d2,3040(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho182
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho182
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho182	or.w	d2,2880(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho183
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho183
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho183	or.w	d2,2720(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho184
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho184
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho184	or.w	d2,2560(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho185
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho185
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho185	or.w	d2,2400(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho186
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho186
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho186	or.w	d2,2240(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho187
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho187
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho187	or.w	d2,2080(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho188
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho188
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho188	or.w	d2,1920(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho189
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho189
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho189	or.w	d2,1760(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho190
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho190
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho190	or.w	d2,1600(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho191
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho191
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho191	or.w	d2,1440(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho192
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho192
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho192	or.w	d2,1280(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho193
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho193
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho193	or.w	d2,1120(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho194
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho194
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho194	or.w	d2,960(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho195
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho195
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho195	or.w	d2,800(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho196
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho196
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho196	or.w	d2,640(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho197
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho197
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho197	or.w	d2,480(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho198
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho198
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho198	or.w	d2,320(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho199
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho199
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho199	or.w	d2,160(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	ho200
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	ho200
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
ho200	or.w	d2,(a0)
	*sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	*bge.s	ho201
	*add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	*ADD.W	D2,D2
	*bcc.s	ho201
	*MOVEQ.W	#1,D2
	*SUBQ.w	#8,a0
ho201	movem.l	(a7)+,d0-d7/a0-a6
	rts


NONyz:  	
	move.w	 d7,d1
	
	lea	ordonnee,a3		* a1 = tableau ordonnee
	add.w	d1,d1			* mulu #2,d5
	move.w	(a3,d1.W),a1		* on se positionne sur le screen
	add.w	a1,a0

	move.w	 d7,d1
	move.w   #200,d5
	sub.w	 d1,d5
	add.w    d5,d5
	move.w   d5,d1
	add.w    d5,d5
	add.w    d5,d5
	add.w    d5,d5
	add.w	 d1,d5
	jmp	hoy(pc,d5.w)

hoy	or.w	d2,-32000(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy1
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy1
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy1	or.w	d2,-31840(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy2
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy2
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy2	or.w	d2,-31680(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy3
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy3
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy3	or.w	d2,-31520(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy4
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy4
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy4	or.w	d2,-31360(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy5
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy5
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy5	or.w	d2,-31200(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy6
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy6
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy6	or.w	d2,-31040(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy7
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy7
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy7	or.w	d2,-30880(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy8
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy8
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy8	or.w	d2,-30720(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy9
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy9
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy9	or.w	d2,-30560(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy10
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy10
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy10	or.w	d2,-30400(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy11
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy11
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy11	or.w	d2,-30240(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy12
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy12
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy12	or.w	d2,-30080(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy13
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy13
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy13	or.w	d2,-29920(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy14
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy14
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy14	or.w	d2,-29760(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy15
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy15
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy15	or.w	d2,-29600(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy16
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy16
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy16	or.w	d2,-29440(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy17
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy17
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy17	or.w	d2,-29280(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy18
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy18
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy18	or.w	d2,-29120(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy19
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy19
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy19	or.w	d2,-28960(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy20
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy20
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy20	or.w	d2,-28800(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy21
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy21
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy21	or.w	d2,-28640(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy22
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy22
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy22	or.w	d2,-28480(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy23
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy23
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy23	or.w	d2,-28320(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy24
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy24
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy24	or.w	d2,-28160(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy25
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy25
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy25	or.w	d2,-28000(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy26
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy26
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy26	or.w	d2,-27840(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy27
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy27
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy27	or.w	d2,-27680(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy28
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy28
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy28	or.w	d2,-27520(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy29
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy29
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy29	or.w	d2,-27360(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy30
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy30
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy30	or.w	d2,-27200(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy31
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy31
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy31	or.w	d2,-27040(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy32
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy32
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy32	or.w	d2,-26880(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy33
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy33
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy33	or.w	d2,-26720(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy34
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy34
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy34	or.w	d2,-26560(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy35
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy35
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy35	or.w	d2,-26400(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy36
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy36
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy36	or.w	d2,-26240(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy37
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy37
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy37	or.w	d2,-26080(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy38
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy38
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy38	or.w	d2,-25920(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy39
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy39
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy39	or.w	d2,-25760(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy40
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy40
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy40	or.w	d2,-25600(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy41
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy41
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy41	or.w	d2,-25440(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy42
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy42
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy42	or.w	d2,-25280(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy43
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy43
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy43	or.w	d2,-25120(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy44
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy44
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy44	or.w	d2,-24960(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy45
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy45
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy45	or.w	d2,-24800(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy46
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy46
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy46	or.w	d2,-24640(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy47
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy47
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy47	or.w	d2,-24480(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy48
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy48
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy48	or.w	d2,-24320(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy49
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy49
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy49	or.w	d2,-24160(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy50
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy50
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy50	or.w	d2,-24000(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy51
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy51
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy51	or.w	d2,-23840(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy52
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy52
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy52	or.w	d2,-23680(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy53
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy53
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy53	or.w	d2,-23520(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy54
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy54
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy54	or.w	d2,-23360(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy55
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy55
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy55	or.w	d2,-23200(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy56
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy56
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy56	or.w	d2,-23040(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy57
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy57
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy57	or.w	d2,-22880(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy58
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy58
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy58	or.w	d2,-22720(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy59
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy59
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy59	or.w	d2,-22560(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy60
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy60
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy60	or.w	d2,-22400(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy61
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy61
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy61	or.w	d2,-22240(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy62
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy62
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy62	or.w	d2,-22080(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy63
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy63
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy63	or.w	d2,-21920(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy64
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy64
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy64	or.w	d2,-21760(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy65
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy65
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy65	or.w	d2,-21600(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy66
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy66
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy66	or.w	d2,-21440(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy67
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy67
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy67	or.w	d2,-21280(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy68
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy68
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy68	or.w	d2,-21120(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy69
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy69
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy69	or.w	d2,-20960(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy70
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy70
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy70	or.w	d2,-20800(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy71
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy71
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy71	or.w	d2,-20640(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy72
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy72
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy72	or.w	d2,-20480(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy73
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy73
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy73	or.w	d2,-20320(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy74
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy74
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy74	or.w	d2,-20160(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy75
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy75
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy75	or.w	d2,-20000(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy76
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy76
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy76	or.w	d2,-19840(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy77
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy77
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy77	or.w	d2,-19680(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy78
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy78
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy78	or.w	d2,-19520(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy79
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy79
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy79	or.w	d2,-19360(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy80
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy80
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy80	or.w	d2,-19200(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy81
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy81
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy81	or.w	d2,-19040(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy82
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy82
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy82	or.w	d2,-18880(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy83
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy83
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy83	or.w	d2,-18720(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy84
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy84
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy84	or.w	d2,-18560(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy85
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy85
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy85	or.w	d2,-18400(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy86
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy86
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy86	or.w	d2,-18240(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy87
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy87
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy87	or.w	d2,-18080(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy88
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy88
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy88	or.w	d2,-17920(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy89
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy89
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy89	or.w	d2,-17760(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy90
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy90
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy90	or.w	d2,-17600(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy91
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy91
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy91	or.w	d2,-17440(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy92
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy92
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy92	or.w	d2,-17280(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy93
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy93
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy93	or.w	d2,-17120(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy94
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy94
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy94	or.w	d2,-16960(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy95
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy95
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy95	or.w	d2,-16800(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy96
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy96
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy96	or.w	d2,-16640(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy97
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy97
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy97	or.w	d2,-16480(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy98
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy98
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy98	or.w	d2,-16320(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy99
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy99
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy99	or.w	d2,-16160(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy100
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy100
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy100	or.w	d2,-16000(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy101
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy101
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy101	or.w	d2,-15840(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy102
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy102
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy102	or.w	d2,-15680(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy103
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy103
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy103	or.w	d2,-15520(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy104
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy104
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy104	or.w	d2,-15360(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy105
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy105
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy105	or.w	d2,-15200(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy106
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy106
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy106	or.w	d2,-15040(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy107
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy107
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy107	or.w	d2,-14880(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy108
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy108
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy108	or.w	d2,-14720(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy109
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy109
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy109	or.w	d2,-14560(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy110
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy110
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy110	or.w	d2,-14400(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy111
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy111
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy111	or.w	d2,-14240(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy112
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy112
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy112	or.w	d2,-14080(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy113
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy113
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy113	or.w	d2,-13920(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy114
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy114
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy114	or.w	d2,-13760(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy115
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy115
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy115	or.w	d2,-13600(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy116
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy116
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy116	or.w	d2,-13440(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy117
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy117
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy117	or.w	d2,-13280(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy118
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy118
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy118	or.w	d2,-13120(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy119
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy119
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy119	or.w	d2,-12960(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy120
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy120
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy120	or.w	d2,-12800(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy121
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy121
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy121	or.w	d2,-12640(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy122
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy122
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy122	or.w	d2,-12480(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy123
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy123
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy123	or.w	d2,-12320(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy124
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy124
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy124	or.w	d2,-12160(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy125
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy125
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy125	or.w	d2,-12000(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy126
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy126
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy126	or.w	d2,-11840(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy127
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy127
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy127	or.w	d2,-11680(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy128
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy128
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy128	or.w	d2,-11520(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy129
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy129
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy129	or.w	d2,-11360(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy130
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy130
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy130	or.w	d2,-11200(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy131
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy131
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy131	or.w	d2,-11040(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy132
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy132
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy132	or.w	d2,-10880(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy133
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy133
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy133	or.w	d2,-10720(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy134
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy134
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy134	or.w	d2,-10560(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy135
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy135
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy135	or.w	d2,-10400(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy136
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy136
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy136	or.w	d2,-10240(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy137
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy137
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy137	or.w	d2,-10080(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy138
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy138
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy138	or.w	d2,-9920(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy139
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy139
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy139	or.w	d2,-9760(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy140
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy140
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy140	or.w	d2,-9600(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy141
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy141
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy141	or.w	d2,-9440(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy142
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy142
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy142	or.w	d2,-9280(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy143
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy143
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy143	or.w	d2,-9120(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy144
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy144
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy144	or.w	d2,-8960(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy145
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy145
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy145	or.w	d2,-8800(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy146
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy146
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy146	or.w	d2,-8640(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy147
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy147
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy147	or.w	d2,-8480(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy148
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy148
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy148	or.w	d2,-8320(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy149
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy149
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy149	or.w	d2,-8160(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy150
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy150
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy150	or.w	d2,-8000(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy151
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy151
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy151	or.w	d2,-7840(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy152
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy152
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy152	or.w	d2,-7680(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy153
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy153
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy153	or.w	d2,-7520(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy154
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy154
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy154	or.w	d2,-7360(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy155
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy155
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy155	or.w	d2,-7200(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy156
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy156
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy156	or.w	d2,-7040(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy157
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy157
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy157	or.w	d2,-6880(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy158
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy158
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy158	or.w	d2,-6720(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy159
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy159
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy159	or.w	d2,-6560(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy160
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy160
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy160	or.w	d2,-6400(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy161
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy161
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy161	or.w	d2,-6240(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy162
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy162
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy162	or.w	d2,-6080(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy163
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy163
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy163	or.w	d2,-5920(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy164
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy164
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy164	or.w	d2,-5760(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy165
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy165
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy165	or.w	d2,-5600(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy166
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy166
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy166	or.w	d2,-5440(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy167
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy167
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy167	or.w	d2,-5280(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy168
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy168
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy168	or.w	d2,-5120(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy169
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy169
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy169	or.w	d2,-4960(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy170
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy170
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy170	or.w	d2,-4800(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy171
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy171
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy171	or.w	d2,-4640(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy172
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy172
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy172	or.w	d2,-4480(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy173
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy173
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy173	or.w	d2,-4320(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy174
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy174
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy174	or.w	d2,-4160(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy175
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy175
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy175	or.w	d2,-4000(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy176
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy176
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy176	or.w	d2,-3840(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy177
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy177
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy177	or.w	d2,-3680(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy178
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy178
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy178	or.w	d2,-3520(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy179
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy179
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy179	or.w	d2,-3360(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy180
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy180
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy180	or.w	d2,-3200(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy181
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy181
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy181	or.w	d2,-3040(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy182
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy182
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy182	or.w	d2,-2880(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy183
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy183
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy183	or.w	d2,-2720(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy184
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy184
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy184	or.w	d2,-2560(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy185
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy185
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy185	or.w	d2,-2400(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy186
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy186
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy186	or.w	d2,-2240(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy187
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy187
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy187	or.w	d2,-2080(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy188
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy188
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy188	or.w	d2,-1920(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy189
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy189
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy189	or.w	d2,-1760(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy190
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy190
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy190	or.w	d2,-1600(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy191
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy191
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy191	or.w	d2,-1440(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy192
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy192
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy192	or.w	d2,-1280(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy193
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy193
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy193	or.w	d2,-1120(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy194
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy194
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy194	or.w	d2,-960(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy195
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy195
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy195	or.w	d2,-800(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy196
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy196
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy196	or.w	d2,-640(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy197
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy197
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy197	or.w	d2,-480(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy198
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy198
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy198	or.w	d2,-320(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy199
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy199
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy199	or.w	d2,-160(a0)
	sub.w 	d6,d4            	* E=E-DX SOIT D4=D4-D6
	bge.s	hoy200
	add.w	d7,d4			* d4=(dy/dx)-(ay/ax)
	ADD.W	D2,D2
	bcc.s	hoy200
	MOVEQ.W	#1,D2
	SUBQ.w	#8,a0
hoy200	or.w	d2,(a0)
hoy201	movem.l	(a7)+,d0-d7/a0-a6
	rts


* --------------------------------------------------------------------
* detournement 118 (routine clavier)
* --------------------------------------------------------------------

new_118	
	move.w	#$2500,sr
	bclr	#6,$fffffa11.w	* <- ca ne sert … rien
	dc.w	$4ef9
fin_118	dc.l	0

* -------------------------------------------------------------------
* timer b
* -------------------------------------------------------------------

* Enlevons la bordure bas mes frŠres...

new_120
	move.l	d0,-(a7)
	move.l	a0,-(a7)
	move.w	#$fa21,a0
	move.b	(a0),d0
haha	cmp.b	(a0),d0
	beq.s	haha
	move.b	#0,$ffff820a.w
	rept	16
	nop
	endr
	move.b	#2,$ffff820a.w
	move.b	#0,$fffffa1b.w		* on coupe le timer
	move.l	#yo,$120.w		* on installe le suivant
	move.b	#19,$fffffa21.w		* 19 lignes plus bas
	move.b	#8,$fffffa1b.w		* c'est reparti
	bclr	#0,$fffffa0f.w		* on se casse.
	move.l	(a7)+,a0
	move.l	(a7)+,d0
	rte

yo	move.l	a2,-(a7)		* la d‚goulinure
	move.l	ad_coule,a2
	move.l  (a2)+,$ffff8240.w
	move.l	(a2)+,$ffff8244.w
	move.l	(a2)+,$ffff8248.w
	move.l	(a2)+,$ffff824c.w
	move.l	(a2)+,$ffff8250.w
	move.l	(a2)+,$ffff8254.w
	move.l	(a2)+,$ffff8258.w
	move.l	(a2)+,$ffff825c.w
	move.l	(a7)+,a2
	move.b	#0,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte


* -------------------------------------------------------------------
* scroll 1 plan
* -------------------------------------------------------------------

* je scrolle en m‚moire sur F_ADR en vbl.
* et je recopie les 20 lignes situ‚es en f_adr + 80*160 sur l'‚cran

scroll_vbl:

	bsr	scroll
	bsr	scroll
	
	move.l	ecran,a5
	add.l	#160*220,a5
	lea	f_adr+34+80*160,a4

i	set	0
	rept	140
	move.w	i(a4),i(a5)
i	set	i+8
	endr
	rts
		
* scroll proprement dit, m‚thode dite "ancestrale" par roxl.w

scroll	move.w	#6,d0			* 7 lignes
	lea	char_dat,a5
	lea	f_adr+34+80*160,a4

scroll1	roxl	(a5)+
	roxl	152(a4)
	roxl	144(a4)
	roxl	136(a4)
	roxl	128(a4)
	roxl	120(a4)
	roxl	112(a4)
	roxl	104(a4)
	roxl	96(a4)
	roxl	88(a4)
	roxl	80(a4)
	roxl	72(a4)
	roxl	64(a4)
	roxl	56(a4)
	roxl	48(a4)
	roxl	40(a4)
	roxl	32(a4)
	roxl	24(a4)
	roxl	16(a4)
	roxl	8(a4)
	roxl	(a4)

	lea	160(a4),a4
	dbf	d0,scroll1
	rts
	
* fin du scroll : dur‚e variable
	
fin_scroll
	subq.b	#2,nb_bit
	beq.s	nextchar
	rts
	
* recup‚ration du caractŠre suivant

nextchar:
	move.b	#8,nb_bit
	move.l	mespoint,a0
	moveq	#0,d0
	move.b	(a0)+,d0
	blt.s	mesagain
	move.l	a0,mespoint
	
	lea	tab_car,a5
	lsl.w	#1,d0
	lea	f_adr+34,a1
	add.w	(a5,d0),a1
	
	lea	char_dat,a0
	rept	7
	move.w	(a1),(a0)+
	lea	160(a1),a1
	endr
	rts

* reinitialisation du scroll lorsqu'il est fini.

mesagain:
	move.l	#mes,mespoint
	bra.s	nextchar

* ------------------------------------------------------------------
* calcul des ‚toiles
* les gars, en minuscule le programme, en minuscule !!!
* ------------------------------------------------------------------

CALC_STARS

	move.l	#TABLE_STAR,A2
	move.l	#DOTS,A0
	move.w	#199,D0
GOOO	MOVEQ	#0,D1
	MOVEQ	#0,D2
	move.w	(A0)+,D1
	move.w	(A0)+,D2
	EXT.L	D1
	EXT.L	D2
	move.l	#DOTS+800,A1
	MOVEQ	#69,D3
GOP	move.l	D1,D4
	move.l	D2,D5
	MULS	(A1),D4
	MULS	(A1)+,D5
	DIVS	#32767,D4
	DIVS	#32767,D5
	AND.L	#$FFFF,D4
	EXT.L	D5
	CMP.W	#159,D4
	BGT.S	CAR
	CMP.W	#-160,D4
	BLT.S	CAR
	CMP.W	#99,d5
	BGT.S	CAR
	CMP.W	#-100-20,D5
	BLT.S	CAR
	ADD.W	#160,D4
	MULS	#160,D5
	DIVU	#16,D4
	move.l	D4,D6
	SWAP	D6
	AND.L	#$FFFF,D4
	LSL.W	#3,D4	
	ADD.W	D4,D5	*OU AFF
	move.w	D5,(A2)+
	move.l	#%1000000000000000,D5
	LSR.W	D6,D5
	CMP.W	#55,D3
	BLT.S	GREY
BLACK
	move.l	D5,(A2)+
	BRA.S	JUMP	
GREY	
	CMP.W	#35,D3
	BLT.S	WHITE
	move.w	D5,D6
	SWAP	D5
	OR.W	D6,D5
	move.l	D5,(A2)+
	BRA.S	JUMP	
WHITE
	SWAP	D5
	move.l	D5,(A2)+
JUMP	
	DBRA	D3,GOP
CAR	
	CMP.W	#0,FLAG
	BEQ.S	CARO
	move.w	#0,FLAG
	move.w	#$0,(A2)+
	BRA.S	LE
CARO    move.w	#1,FLAG
LE	DBRA	D0,GOOO
	RTS

INI_ETOILES
	LEA	TABLE_STAR,A0
	LEA	TRAJECTOIRES(PC),A1
	MOVEQ	#$62,D0
	move.l	A0,(A1)+
	move.l	A0,(A1)+
INI_STARS
	LEA	6(A0),A0
	CMPI.W	#$0,(A0)
	BNE.S	INI_STARS
	LEA	2(A0),A0
	move.l	A0,(A1)+
	move.l	A0,(A1)+
	DBRA	D0,INI_STARS
	move.l	#plus_tub,A0
	move.l	#TRAJECTOIRES,A1
	MOVEQ	#99,D0
DECO	move.l	(A1),D1
	MOVEQ	#0,D2
	move.w	(A0)+,D2
	ADD.L	D2,D1
	move.l	D1,(A1)
	LEA	8(A1),A1
	DBRA	D0,DECO
	RTS

* ------------------------------------------------------------------
* affichage des ‚toiles
* ------------------------------------------------------------------

VBL_STAR_DEBUT_1
	LEA	$6bd00-32000+120*160+4,A0	
	LEA	SAVE_EF1(PC),A1		
	MOVEQ	#0,D6			
	REPT	16
	MOVEM.W	(A1)+,D0-D5		
	move.l	D6,(A0,D0.W)		
	move.l	D6,(A0,D1.W)		
	move.l	D6,(A0,D2.W)		
	move.l	D6,(A0,D3.W)		
	move.l	D6,(A0,D4.W)		
	move.l	D6,(A0,D5.W)		
	ENDR				
        MOVEM.W	(A1)+,D0-D3
	move.l	D6,(A0,D0.W)
	move.l	D6,(A0,D1.W)
	move.l	D6,(A0,D2.W)
	move.l	D6,(A0,D3.W)
	RTS

VBL_STAR_1
	move.l	#$6bd00-32000+120*160+4,A1
	LEA	SAVE_EF1(PC),A4
	LEA	TRAJECTOIRES(PC),A3
	REPT	100
	move.l	(A3),A5
	move.w	(A5)+,D1
	DC.W	$6608	*BNE.S	NO_LOOPSTARS
	move.l	4(A3),(A3)
	move.l	(A3),A5
	move.w	(A5)+,D1
	move.l	(A5)+,D2
	OR.L	D2,(A1,D1.W)
	move.w	D1,(A4)+
	move.l	A5,(A3)
	ADDQ.L	#8,A3
	ENDR
	RTS


VBL_STAR_DEBUT_2
	LEA	$79f00-32000+120*160+4,A0
	LEA	SAVE_EF2(PC),A1
	MOVEQ	#0,D6
	REPT	16
	MOVEM.W	(A1)+,D0-D5
	move.l	D6,(A0,D0.W)
	move.l	D6,(A0,D1.W)
	move.l	D6,(A0,D2.W)
	move.l	D6,(A0,D3.W)
	move.l	D6,(A0,D4.W)
	move.l	D6,(A0,D5.W)
	ENDR	
        MOVEM.W	(A1)+,D0-D3
	move.l	D6,(A0,D0.W)
	move.l	D6,(A0,D1.W)
	move.l	D6,(A0,D2.W)
	move.l	D6,(A0,D3.W)
	RTS

VBL_STAR_2
	move.l	#$79f00-32000+120*160+4,A1
	LEA	SAVE_EF2(PC),A4
	LEA	TRAJECTOIRES(PC),A3
	REPT	100
	move.l	(A3),A5
	move.w	(A5)+,D1
	DC.W	$6608	
	move.l	4(A3),(A3)
	move.l	(A3),A5
	move.w	(A5)+,D1
	move.l	(A5)+,D2
	OR.L	D2,(A1,D1.W)
	move.w	D1,(A4)+
	move.l	A5,(A3)
	ADDQ.L	#8,A3
	ENDR
	RTS

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* DATAS 
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

memvbl		ds.l	1
gabon		ds.w	16
fin_demo	dc.w	0			* flag d‚mo finie
old_pal		ds.l	16			* buffer vieille palette
anc_ecran	ds.l 	1			* adresse ancien ‚cran
ecran 		ds.l 	1			* ecran courant
pile		ds.l 	1			* pile
anc_vbl		ds.l	1			* ancienne vbl
anc_tb		ds.l	1			* ancien timer b
anc_tc		ds.l	1			* ancien timer c
mfp1		ds.l	1			* sauve registres mfp
mfp2		ds.l	1
mfp3		ds.l	1
mfp4		ds.l	1
mfp5		ds.l	1
mfp6		ds.l	1

old_rez		ds.w	1			* vieille resolution
		ds.l	100
new_pile					* pile
s_courbx	ds.l	1			* etoiles
s_courby	ds.l	1

index:		ds.w 	1			* objet 3d
routine:	ds.l 	80			* routines 3d
noucoord	ds.l 	1			* coord 3d

adimg	 	dc.l	$6bd00-32000		* ecran 1
cache		dc.l	$79f00-32000		* ecran 2
routine_vbl	dc.l	vbl_star_1		* routine 1 ‚toiles
routine_haut	dc.l	vbl_star_debut_1	* routine 2 ‚toiles
flag		dc.w	0
trajectoires	ds.l	200
save_ef1	ds.w	100
save_ef2	ds.w	100
mespoint	dc.l	mes			* pointeur texte
nb_bit		dc.b	7			* nb pixels scroll‚s
		even
char_dat	ds.w	20			* buffer new caractere

tab_car: 					* position des lettres
		ds.w	32
  		dc.w	19200,3496,0,0,0,0,0,6760,6744,6752,6736,6720,3512,3504
  		dc.w	3488,0
  		dc.w  	3408,3416,3424,3432,3440,3448,3456
  		dc.w  	3464,3472,3480,6768,0,0,0,0,6728,0
  		dc.w  	0,8,16,24,32,40,48,56,64
  		dc.w 	72,80,88,96,104,112,120,128
  		dc.w  	136,144,152
  		dc.w  	3360,3368,3376,3384,3392,3400
  		ds.w	100

* objets 3d

tbc	dc.w	-50,0,50
	dc.w	-20,0,50
	dc.w	-20,10,50
	dc.w	-30,10,50
	dc.w	-30,50,50
	dc.w	-40,50,50
	dc.w	-40,10,50
	dc.w	-50,10,50

	dc.w	-15,25,0
	dc.w	10,25,0
	dc.w	15,15,0
	dc.w	10,0,0
	dc.w	15,-15,0
	dc.w	10,-25,0
	dc.w	-15,-25,0
	dc.w	-15,-25,0

	dc.w	20,0,-50
	dc.w	50,0,-50
	dc.w	50,-10,-50
	dc.w	30,-10,-50
	dc.w	30,-40,-50
	dc.w	50,-40,-50
	dc.w	50,-50,-50
	dc.w	20,-50,-50

mcs	dc.w	-50,50,50
	dc.w	-35,0,50
	dc.w	-25,25,50
	dc.w	-15,0,50
	dc.w	0,50,50
	dc.w	-15,20,50
	dc.w	-25,40,50
	dc.w	-35,20,50

	dc.w	50,-50,-50
	dc.w	0,-35,-50
	dc.w	30,-15,-50
	dc.w	0,0,-50
	dc.w	50,-15,-50
	dc.w	20,-35,-50
	dc.w	50,-50,-50
	dc.w	50,-50,-50

	dc.w	25,25,0
	dc.w	-25,0,0
	dc.w	25,-25,0
	dc.w	-5,0,0
	dc.w	25,25,0
	dc.w	25,25,0
	dc.w	25,25,0
	dc.w	25,25,0

vas	dc.w	-30,0,50
	dc.w	-15,15,50
	dc.w	-15,0,-43
	dc.w	-30,0,50
	dc.w	-15,-15,50
	dc.w	-15,0,-43
	dc.w	-30,0,50
	dc.w	-30,0,50

	dc.w	-15,15,50
	dc.w	15,15,50
	dc.w	15,0,-43
	dc.w	15,-15,50
	dc.w	-15,-15,50
	dc.w	-15,0,-43
	dc.w	15,0,-43
	dc.w	-15,0,-43

	dc.w	30,0,50
	dc.w	15,15,50
	dc.w	15,0,-43
	dc.w	30,0,50
	dc.w	15,-15,50
	dc.w	15,0,-43
	dc.w	30,0,50
	dc.w	30,0,50

fig	dc.w	-19,0,40
	dc.w	-40,0,40
	dc.w	-40,0,50
	dc.w	-50,0,40
	dc.w	-50,0,-40
	dc.w	-40,0,20
	dc.w	-7,0,-20
	dc.w	-20,0,40

	dc.w	-20,0,50
	dc.w	0,25,50
	dc.w	20,0,50
	dc.w	0,0,-50
	dc.w	0,25,50
	dc.w	-20,0,50
	dc.w	0,0,-50
	dc.w	20,0,50

	dc.w	19,0,40
	dc.w	40,0,40
	dc.w	40,0,50
	dc.w	50,0,40
	dc.w	50,0,-40
	dc.w	40,0,20
	dc.w	7,0,-20
	dc.w	20,0,40


hiboux	dc.w	-35,-35,35
	dc.w	-35,35,35
	dc.w	35,35,35
	dc.w	35,-35,35
	dc.w	-35,-35,35
	dc.w	-35,-35,-35
	dc.w	-35,35,-35
	dc.w	-35,35,35

	dc.w	35,-35,-35
	dc.w	35,35,-35
	dc.w	-35,35,-35
	dc.w	-35,-35,-35
	dc.w	35,-35,-35
	dc.w	35,-35,35
	dc.w	35,35,35
	dc.w	35,35,-35

	dc.w	-15,15,15
	dc.w	0,0,-15
	dc.w	15,15,15
	dc.w	0,-15,15
	dc.w	0,0,-15
	dc.w	-15,15,15
	dc.w	0,-15,15
	dc.w	15,15,15

pol	dc.w	-30,-15,0
	dc.w	-30,15,0
	dc.w	-15,30,0
	dc.w	15,30,0
	dc.w	30,15,0
	dc.w	30,-15,0
	dc.w	15,-30,0
	dc.w	-15,-30,0

	dc.w	-24,-12,20
	dc.w	-24,12,20
	dc.w	-12,24,20
	dc.w	12,24,20
	dc.w	24,12,20
	dc.w	24,-12,20
	dc.w	12,-24,20
	dc.w	-12,-24,20
	
	dc.w	-24,-12,-20
	dc.w	-24,12,-20
	dc.w	-12,24,-20
	dc.w	12,24,-20
	dc.w	24,12,-20
	dc.w	24,-12,-20
	dc.w	12,-24,-20
	dc.w	-12,-24,-20

fle	dc.w	-20,-20,-20
	dc.w	0,20,-20
	dc.w	20,-20,-20
	dc.w	0,0,-40
	dc.w	0,20,-20
	dc.w	-20,-20,-20
	dc.w	0,0,-40
	dc.w	20,-20,-20

	dc.w	-20,-20,-20
	dc.w	0,20,-20
	dc.w	20,-20,-20
	dc.w	0,0,30
	dc.w	0,20,-20
	dc.w	-20,-20,-20
	dc.w	0,0,30
	dc.w	20,-20,-20

	dc.w	20,40,30
	dc.w	40,20,30
	dc.w	40,-20,30
	dc.w	20,-40,30
	dc.w	-20,-40,30
	dc.w	-40,-20,30
	dc.w	-40,20,30
	dc.w	-20,40,30

hel	dc.w	-20,-20,-10
	dc.w	0,10,-10
	dc.w	20,-20,-10
	dc.w	0,0,-50
	dc.w	0,10,-10
	dc.w	-20,-20,-10
	dc.w	0,0,-50
	dc.w	20,-20,-10

	dc.w	0,10,-10
	dc.w	-20,10,30
	dc.w	-40,10,10
	dc.w	40,10,-30
	dc.w	20,10,-50
	dc.w	0,10,-10
	dc.w	0,-20,40
	dc.w	0,-20,-10

	dc.w	-20,-20,-10
	dc.w	0,-20,40
	dc.w	0,-10,40
	dc.w	0,-20,30
	dc.w	0,-20,50
	dc.w	0,-30,40
	dc.w	0,-20,40
	dc.w	20,-20,-10

mas	dc.w	-40,-20,20
	dc.w	-40,20,20
	dc.w	40,20,20
	dc.w	40,-20,20
	dc.w	-40,-20,20
	dc.w	-40,-20,-20
	dc.w	-40,20,-20
	dc.w	-40,20,20

	dc.w	40,-20,-20
	dc.w	40,20,-20
	dc.w	-40,20,-20
	dc.w	-40,-20,-20
	dc.w	40,-20,-20
	dc.w	40,-20,20
	dc.w	40,20,20
	dc.w	40,20,-20

	dc.w	-40,20,-20
	dc.w	40,20,-20
	dc.w	40,40,0
	dc.w	40,20,20
	dc.w	-40,20,20
	dc.w	-40,40,0
	dc.w	40,40,0
	dc.w	-40,40,0

con	dc.w	-10,-10,60
	dc.w	-10,10,60
	dc.w	10,10,60
	dc.w	10,-10,60
	dc.w	-10,-10,60
	dc.w	-20,-10,0
	dc.w	-20,10,0
	dc.w	-10,10,60

	dc.w	-10,-10,-60
	dc.w	-10,10,-60
	dc.w	-20,10,0
	dc.w	-20,-10,0
	dc.w	-10,-10,-60
	dc.w	10,-10,-60
	dc.w	10,10,-60
	dc.w	-10,10,-60

	dc.w	20,-10,0
	dc.w	20,10,0
	dc.w	10,10,-60
	dc.w	10,-10,-60
	dc.w	20,-10,0
	dc.w	10,-10,60
	dc.w	10,10,60
	dc.w	20,10,0

soc	dc.w	-40,-20,20
	dc.w	-20,20,10
	dc.w	20,20,10
	dc.w	40,-20,20
	dc.w	-40,-20,20
	dc.w	-40,-20,-20
	dc.w	-20,20,-10
	dc.w	-20,20,10

	dc.w	40,-20,-20
	dc.w	20,20,-10
	dc.w	-20,20,-10
	dc.w	-40,-20,-20
	dc.w	40,-20,-20
	dc.w	40,-20,20
	dc.w	20,20,10
	dc.w	20,20,-10

	dc.w	0,20,0
	dc.w	-5,40,0
	dc.w	-15,42,0
	dc.w	-5,44,0
	dc.w	0,50,0
	dc.w	5,44,0
	dc.w	15,42,0
	dc.w	5,40,0

sab	dc.w	-20,-40,20
	dc.w	20,40,-20
	dc.w	-20,40,-20
	dc.w	20,-40,20
	dc.w	20,-40,-20
	dc.w	-20,-40,-20
	dc.w	-20,-40,20
	dc.w	20,-40,20

	dc.w	20,40,20
	dc.w	-20,-40,-20
	dc.w	20,-40,-20
	dc.w	-20,40,20
	dc.w	-20,40,-20
	dc.w	20,40,-20
	dc.w	20,40,20
	dc.w	-20,40,20

	dc.w	-30,0,-15
	dc.w	-30,0,15
	dc.w	-15,0,30
	dc.w	15,0,30
	dc.w	30,0,15
	dc.w	30,0,-15
	dc.w	15,0,-30
	dc.w	-15,0,-30

vad	dc.w	0,0,-20
	dc.w	0,50,0
	dc.w	0,0,20
	dc.w	0,-50,0
	dc.w	0,0,-20
	dc.w	-50,0,0
	dc.w	0,0,20
	dc.w	50,0,0

	dc.w	0,0,-20
	dc.w	-40,40,0
	dc.w	0,0,20
	dc.w	40,-40,0
	dc.w	0,0,-20
	dc.w	40,40,0
	dc.w	0,0,20
	dc.w	-40,-40,0

	dc.w	0,50,0
	dc.w	40,40,0
	dc.w	50,0,0
	dc.w	40,-40,0
	dc.w	0,-50,0
	dc.w	-40,-40,0
	dc.w	-50,0,0
	dc.w	-40,40,0
	
squ	dc.w	0,0,0
	dc.w	0,0,0
	dc.w	0,0,0
	dc.w	0,0,0
	dc.w	0,0,0
	dc.w	0,0,0
	dc.w	0,0,0
	dc.w	0,0,0

	dc.w	0,0,0
	dc.w	0,0,0
	dc.w	0,0,0
	dc.w	0,0,0
	dc.w	0,0,0
	dc.w	0,0,0
	dc.w	0,0,0
	dc.w	0,0,0

	dc.w	40,40,0
	dc.w	40,40,0
	dc.w	40,-40,0
	dc.w	40,-40,0
	dc.w	-40,-40,0
	dc.w	-40,-40,0
	dc.w	-40,40,0
	dc.w	-40,40,0

end	dc.w	-50,0,50
	dc.w	0,25,50
	dc.w	-25,5,50
	dc.w	0,0,50
	dc.w	-25,-5,50
	dc.w	0,-25,50
	dc.w	-50,0,50
	dc.w	-50,0,50

	dc.w	0,25,-50
	dc.w	50,0,-50
	dc.w	0,-25,-50
	dc.w	0,25,-50
	dc.w	0,25,-50
	dc.w	0,25,-50
	dc.w	0,25,-50
	dc.w	0,25,-50

	dc.w	-25,25,0
	dc.w	-25,-25,0
	dc.w	15,5,0
	dc.w	25,-25,0
	dc.w	25,25,0
	dc.w	-15,-5,0
	dc.w	-25,25,0
	dc.w	-25,25,0
	

buffer		ds.w	3*24
cube		ds.w	3*24
angle		dc.w	0,0,0	

vvvbl		dc.l	0			* compteur vbl
cp_466		dc.l	0			* idem

sin_x_ro	ds.w	1
cos_x_ro	ds.w	1
sin_y_ro	ds.w	1
cos_y_ro	ds.w	1
sin_z_ro	ds.w	1
cos_z_ro	ds.w	1
xplus		dc.w	1
yplus		dc.w 	1
zplus		dc.w	1
nb		ds.w 	1

sinus_ro	incbin	sinus.tab

ordonnee:

i	set	0
	rept	201
	dc.w	i
i	set	i+160
	endr

abscisse

i	set	0
	rept	25
	dc.w	i,32768,i,16384,i,8192,i,4096,i,2048,i,1024,i,512
	dc.w    i,256,i,128,i,64,i,32,i,16,i,8,i,4,i,2,i,1
i	set	i+8
	endr

dec_coule	ds.w	1
ad_coule	dc.l	coule1
vbl_coule	dc.w	4
coule1		dc.w	0,$077,0,$100,0,$200,0,$300,0,$400,0,$500,0,$600,0,$700
		dc.w	0,$077,0,$200,0,$300,0,$400,0,$500,0,$600,0,$700,0,$100
		dc.w	0,$077,0,$300,0,$400,0,$500,0,$600,0,$700,0,$100,0,$200
		dc.w	0,$077,0,$400,0,$500,0,$600,0,$700,0,$100,0,$200,0,$300
		dc.w	0,$077,0,$500,0,$600,0,$700,0,$100,0,$200,0,$300,0,$400
		dc.w	0,$077,0,$600,0,$700,0,$100,0,$200,0,$300,0,$400,0,$500
		dc.w	0,$077,0,$700,0,$100,0,$200,0,$300,0,$400,0,$500,0,$600

* Damned fait chier ce texte … refaire...

mes:	
 DC.B "                                       "
 DC.B "YO BOYZ ! THE BLACK CATS ARE PROUD (WHY ?) TO PRESENT YOU THIS "
 DC.B "NEW SCREEN (BEGUN LAST YEAR !) FOR THE DELIRIOUS IV DEMO OF M.C.S. "
 DC.B "CODE BY THE BLACK CATS, CHARACTERS SET BY ES OF TEX AND MUZAK BY "
 DC.B "MAD MAX OF TEX. BEFORE GREETINGS, LET ME INTRODUCE YOU THE CURRENT "
 DC.B "MEMBERS OF THE BLACK CATS. WE ARE AGAIN NUMEROUS !! MEMBERS ARE : "
 DC.B "DOCPROF (-JEAN- : CODER, BOSS), SHARP MAN (- THIERRY - : CODER, RIPPER, TEXT), "
 DC.B "CONAN (- HAROLD - : CODER, TT MAN), M.L.M. (- MICHEL - : CODER, MAIN MENU CODER !), "
 DC.B "THE BEYONDER (- JEROME - : CODER, TT MAN), BONO (- DAVID - : CODER, GFX), "
 DC.B "CHAMALOW (- PASCAL - : PUBLIC RELATIONS), ENCULATOR (- STEPHANE - : GRAPHIXX MAN) AND "
 DC.B "DOUBLE JACK (- JAN - : GRAPHIXX MAN). OK THAT'S ALL FOR NOW. WE DECIDED TO SEND "
 DC.B "GREETINGS ONLY TO OUR FRIENDS AND PEOPLE WE ARE IN TOUCH WITH (NO STUPID "
 DC.B "GREETINGS TO PEOPLE WE NEVER SEE...), SO GREETINGS ARE SENT (IN SHARP MAN'S ORDER) TO : "
 DC.B "EQUINOX (OUR BEST FRIENDS ON ST, TO ALL MEMBERS : STARLION, KRUEGER, CHECKSUM, "
 DC.B "STEPRATE, MENTA, EDY, AL COOL, SLIDE), CLONE (NOBODY AND MAJOR PARVUUS), "
 DC.B "M.C.S. (ALL MEMBERS), PHENIX, THE LIGHTNINGS, ST CONNEXION, ABCS 85 (HI TO "
 DC.B "CENTAUR, FLOTSAM AND CODEMASTER !), THE ART OF CODE (THE BEST ONES !), "
 DC.B "THE MISFITS (NICE SCREEN IN THE RIPDIS MEGADEMO), FUZION, D.M.A. (ESPECIALLY "
 DC.B "JINX), CHUD (ARE YOU STILL ALIVE ???), CYCLONE (THE AMIGA CREW), OXYGENE ("
 DC.B "ESPECIALLY LESTER : DIS LESTER ? TU T'ES VU QUAND T'AS BU ??), NEXT, PAT "
 DC.B "CASH (THANKS FOR ALL !), MR BEE AND ZIGGY STARDUST OF OVERLANDERS (IT'S "
 DC.B "PRETTY STRANGE, BUT I CAN'T REMEMBER THE NAME OF THE OTHER MEMBERS OF THIS "
 DC.B "CREW...), CYBORG AND FEROCE LAPIN. OK THAT'S ALL FOR FRENCH GREETINGS, EXTRA "
 DC.B "GREETINGS ARE SENT TO : THE LOST BOYS, U.L.M., T.D.A., ELECTRA, DELTA FORCE, "
 DC.B "THE EXCEPTIONS, GERMAN ALLIANCE (ALL MEMBERS !), FLEXIBLE FRONT (IF THEY STILL "
 DC.B "EXIST...). - THE END - . AS USUAL, THE SOURCE OF THIS SCREEN IS IN PUBLIC "
 DC.B "DOMAIN, IF YOU'RE INTERESTED WITH IT OR OLD TBC SCREENS, YOU CAN WRITE TO "
 DC.B "(TAKE PENCIL AND PAPER) : T.B.C. - CHALET DE RIQUEVAL - 02420 BELLICOURT - "
 DC.B "FRANCE - (YOU CAN WRITE US FOR SOMETHING ELSE !!), EXCUSE US IF WE DON'T "
 DC.B "ANSWER QUICKLY BUT SOMETIMES THERE'S LOT OF LETTERS... TEXT IS FINISHED ... "
 DC.B "ALL MEMBERS OF THE BLACK CATS SAY YOU GOOD BYE ... SEE YA SOON ... (C)1990-91 "
 DC.B "THE BLACK CATS."
 DC.B -1
        even

variable	ds.w	1

* tableau de routines associ‚es aux touches

old_key	ds.b	1
	even

key_rout:

	rept	$39
	dc.l	fin_3d
	endr
	dc.l	sortie		
	rept	$e
	dc.l	fin_3d
	endr
	dc.l	haut
	dc.l	fin_3d
	dc.l	moins
	dc.l	gauche
	dc.l	fin_3d
	dc.l	droite
	dc.l	plus
	dc.l	fin_3d
	dc.l	bas
	rept	$f
	dc.l	fin_3d
	endr
	dc.l	undo
	dc.l	help
	rept	4
	dc.l	fin_3d
	endr
	dc.l	rotinit
	rept	$9d-4
	dc.l	fin_3d
	endr

* incbins

image1		incbin	p1.pi1"
image2		incbin	p2.pi1"
dots		incbin	dotssin.bin
plus_tub	incbin	plus.bin
musique		incbin	ashtray.mus
		even
f_adr		incbin	alpha.pi1

TABLE_STAR


	end

