* routine de calcul d'ensemble de Malderbrot
* pour Falk'mag 5 par Golio Junior

Video_mode		equ %000101100	* 80 col, 200 lig, Tc, TV Pal
Taille_ecran	equ 640*200*2/4
ecran_hauteur	equ 200
ecran_largeur	equ 640

MATH_offset	equ 2^24		* puissance de 2 qui sert de multiplication
				* donc 24 bits pour la partie d‚cimale
				* donc 8 bits pour la partie entiŠre
calcul_largeur	equ 640
calcul_hauteur	equ 200
* paramŠtre pour le dessin de Malderbrot
	include	"m_05.dat"		* remplacer par m_XX.dat

* constantes pr‚calcul‚es
mag	equ	Xright-Xleft	* largeur
xscale	equ	mag/calcul_largeur	* pas en x
yscale	equ	mag/calcul_hauteur	* pas en y

	* Rq. : les constantes sont d‚ja dans la bonne repr‚sentation !

	include	"principa.s"

		* initialisation
prg_init
	bsr	PLOT_init
	move.w	#calcul_hauteur-1,y_count	* compteur y = coordonn‚es y … l'‚cran
	move.l	#Ytop,cy		* coordonn‚es y en virgule fixe
	rts

				* calcul et affichage d'une ligne
prg
	move.w	y_count,d0
	bmi	prg_fin		* on a fini de dessiner!

				* calcul de l'adresse de la ligne
	lea	PLOT_base,a0
	movea.l	(0,a0,d0.w*4),a0	* a0 pointe sur le d‚but de la ligne

	movea.l	#tabcoul,a1	* table des couleurs

	move.l	cy,d7		* Cy
	move.l	#calcul_largeur-1,d0	* compteur x : pour affiche un ligne
	move.l	#Xleft,d6		* Cx
prg_bouc_x
	move.l	#0,d1		* compteur d'it‚ration
	move.l	d6,d5		* Zx = Cx : 1‚re it‚ration
	move.l	d7,d4		* Zy = Cy : 1‚re it‚ration
do_while
		* R‚sum‚ d'utilisation des registres
		* d0 : compteur des points en x
		* d1 : compteur du nombre d'it‚rations
		* d2 : calcul interm‚diaire
		* d3 : calcul interm‚diaire
		* d4 : Zy
		* d5 : Zx
		* d6 : Cx
		* d7 : Cy
		* a0 : adresse du point courant
		* a1 : adresse de la palette

				* calcul de Zx
	move.l	d5,d2
	muls.l	d5,d3:d2		* d3:d2 = Zx*Zx en 2^48
				* soit 16 bits en entiers dans le
				* mot long de poid fort
				* donc on multiplie par 2^8 pour
				* obtenir le poid fort correct dans d3
	asl.l	#8,d3		* mais il nous manque 8 bits
	swap	d2		* qui se trouve dans les poids forts
	lsr.w	#8,d2		* de d2
	move.b	d2,d3		* d3 contient donc Zx*Zx
	movea.l	d3,a2		* sauvegarde dans un registre d'adresse!

	move.l	d4,d2
	muls.l	d4,d3:d2		* d3:d2 = Zy*Zy
	asl.l	#8,d3		* mˆme op‚ration
	swap	d2
	lsr.w	#8,d2
	move.b	d2,d3		* d3 contient Zy*Zy

	sub.l	d3,a2		* a2 contient Zx*Zx-Zy*Zy
	adda.l	d6,a2		* a2 contient Zx*Zx-Zy*Zy+Cx
				* soit la nouvelle valeur de Zx

				* calcul  de Zy
	muls.l	d5,d3:d4		* d3:d4 = Zx*Zy
	asl.l	#8,d3
	swap	d4
	lsr.w	#8,d4
	move.b	d4,d3
	asl.l	#1,d3		* d3 contient donc Zx*Zy*2
	add.l	d7,d3		* d3 contient Zx*Zy*2+Cy
	
				* pr‚paration des registres
				* pour la prochaine it‚ration
	move.l	a2,d5		* Zx
	move.l	d3,d4		* Zy
	
				* test de fin d'it‚ration
				* plus … it‚rer?
	addq.w	#1,d1
	cmp.w	#Nb_iter,d1
	beq	fin_iter
				* abs(Zx)+abs(Zy)<2 ?
	tst.l	d3		* Zy n‚gatif? d3 contient aussi Zy!
	bpl	zy_positif		* Non alors test de Zx
	neg.l	d3		* sinon -Zy
zy_positif
	tst.l	d5		* Zx n‚gatif?
	bpl	zx_positif		* Non alors addition de d3 et a2
	sub.l	a2,d3		* d3 = |Zx|+|Zy|
	bra fin_test_abs
zx_positif
	add.l	a2,d3		* d3 = |Zx|+|Zy|
fin_test_abs
	cmp.l	#2*MATH_offset,d3
	bpl	do_while

fin_iter
	andi.w	#511,d1
	move.w	(0,a1,d1.w*2),d1	* on r‚cupŠre la couleur
	move.w	d1,(a0)+		* et on affiche le point

				* calcul du nouveau Cx
	add.l	#xscale,d6

	dbra	d0,prg_bouc_x

				* pr‚paration pour la prochaine ligne
	add.l	#yscale,d7
	move.l	d7,cy
	sub.w	#1,y_count
prg_fin
	rts

				* routine d'initialisation de la routine de point
PLOT_init 	
 	move.l adr_ecran,d0
	movea.l #PLOT_base,a0
	move.w #ecran_hauteur,d1
PLOT_init_b1
	move.l d0,(a0)+
	addi.l #ecran_largeur*2,d0
	dbra d1,PLOT_init_b1
	rts

	section data
tabcoul	incbin	"fract_tc.pal"
	
	section bss
PLOT_base	ds.l	ecran_hauteur
y_count	ds.w	1
cy	ds.l	1

	include	"principh.s"