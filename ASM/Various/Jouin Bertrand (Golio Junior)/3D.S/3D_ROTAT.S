* projection 3D centrale avec rotations
* Routine en True Color (320*200)
* par Golio Junior pour Falk'mag 6

* D‚finition de l'image
Video_mode		equ %000100100	* 40 col, 200 lig, 65536 cou, TV Pal
Taille_ecran	equ 320*200*2
ecran_largeur	equ 320
ecran_hauteur	equ 200
Pas_Fond		equ 0

	include "principa.s"

* structure d'un point en 3d
	rsreset
coor_x	rs.w 1
coor_y	rs.w 1
coor_z	rs.w 1
t_coor	equ __rs

* point de fuite
p	equ	256/200 

* offset de l'ecran
offset_x	equ 160
offset_y	equ 100

* pas des rotations
offset_ang_x	equ 2*256/2
offset_ang_y	equ 2*256/1
offset_ang_z	equ 2*256/3

* routine d'initialisation
prg_init
				* initialisation des angles de rotation
	clr.w angle_x
	clr.w angle_y
	clr.w angle_z
	rts

prg
	move.l #-1,couleur		* effacage de la position pr‚c‚dente
	bsr trace_3d

	add.w #offset_ang_x,angle_x	* angles suivants
	add.w #offset_ang_y,angle_y
	add.w #offset_ang_z,angle_z

	move.l #0,couleur
	bsr trace_3d		* tracage de la nouvel position
	rts

trace_3d
	lea cos,a4			* table des cosinus
	lea sin,a5			* table des sinus
	
				* remplissage des sinus/cosinus des angles
	clr.w d0
	move.b angle_x,d0
	move.w (0,a4,d0.w*2),cos_x
	move.w (0,a5,d0.w*2),sin_x
	move.b angle_y,d0
	move.w (0,a4,d0.w*2),cos_y
	move.w (0,a5,d0.w*2),sin_y
	move.b angle_z,d0
	move.w (0,a4,d0.w*2),cos_z
	move.w (0,a5,d0.w*2),sin_z
	
				* precal des coefficients multiplicateur
				* coefficient de x pour x !
	move.w sin_x,d0
	muls.w sin_y,d0		* d0 en 16 bits decimal
	lsr.l #8,d0		* d0 en 8 bits decimal
	muls.w sin_z,d0		* d0 en 16 bits decimal
	move.w cos_x,d1
	muls.w cos_y,d1		* d1 en 16 bits decimal
	add.l d0,d1
	lsr.l #8,d1		* d1 en 8 bits decimal
	move.w d1,x_coef_x

				* coefficient de y pour x
	move.w cos_z,d0
	muls.w sin_x,d0
	lsr.l #8,d0
	move.w d0,x_coef_y
	
				* coefficient de z pour x
	move.w cos_y,d0
	muls.w sin_x,d0
	lsr.l #8,d0
	muls.w sin_z,d0
	move.w cos_x,d1
	muls.w sin_y,d1
	sub.l d1,d0
	lsr.l #8,d0
	move.w d0,x_coef_z
	
				* coefficient de x pour y
	move.w cos_x,d0
	muls.w sin_y,d0
	lsr.l #8,d0
	muls.w sin_z,d0
	move.w cos_y,d1
	muls.w sin_x,d1
	sub.l d1,d0
	lsr.l #8,d0
	move.w d0,y_coef_x
	
				* coefficient de y pour y
	move.w cos_x,d0
	muls.w cos_z,d0
	lsr.l #8,d0
	move.w d0,y_coef_y

				* coefficient de z pour y
	move.w cos_x,d0
	muls.w cos_y,d0
	lsr.l #8,d0
	muls.w sin_z,d0
	move.w sin_x,d1
	muls.w sin_y,d1
	add.l d1,d0
	lsr.l #8,d0
	move.w d0,y_coef_z
	
				* coefficient de x pour z
	move.w cos_y,d0
	muls.w sin_x,d0
	lsr.l #8,d0
	muls.w sin_z,d0
	move.w cos_x,d1
	muls.w sin_y,d1
	sub.l d1,d0
	lsr.l #8,d0
	move.w d0,z_coef_x
	
				* coefficient de y pour z
	move.w sin_z,d0
	neg.w d0
	move.w d0,z_coef_y
	
				* coefficient de z pour z
	move.w cos_y,d0
	muls.w cos_z,d0
	lsr.l #8,d0
	move.w d0,z_coef_z
	
	lea objet,a6		* adresse de la premiere arete
trave_3d_boucle1
				* rotation et projection du premier point
				* calcul du nouveau z
	move.w (coor_x,a6),d7
	muls.w z_coef_x,d7
	move.w (coor_y,a6),d6
	muls.w z_coef_y,d6
	move.w (coor_z,a6),d5
	muls.w z_coef_z,d5
	add.l d6,d7
	add.l d5,d7
	lsr.l #8,d7		* z

				* calcul de q
	muls.w #p,d7		* z/p en 2^16 bits
	asr.l #8,d7
	sub.l #1*256,d7		* z/p-1 en 2^8 bits
	neg.l d7			* 1-z/p en 2^8 bits
	move.l #1*65536,d4
	divs.l d7,d4		* 1/(1-z/p) en 2^8 bits
				* calcul du nouveau x
	move.w (coor_x,a6),d0
	muls.w x_coef_x,d0
	move.w (coor_y,a6),d6
	muls.w x_coef_y,d6
	move.w (coor_z,a6),d5
	muls.w x_coef_z,d5
	add.l d6,d0
	add.l d5,d0
	lsr.l #8,d0		* x
	muls.w d4,d0
	swap d0			* division par 2^16
				* calcul du nouveau y
	move.w (coor_x,a6),d1
	muls.w y_coef_x,d1
	move.w (coor_y,a6),d6
	muls.w y_coef_y,d6
	move.w (coor_z,a6),d5
	muls.w y_coef_z,d5
	add.l d6,d1
	add.l d5,d1
	lsr.l #8,d1		* y
	muls.w d4,d1
	swap d1
	
	adda.l #t_coor,a6		* point suivant

				* projection du second point
				* calcul du nouveau z
	move.w (coor_x,a6),d7
	muls.w z_coef_x,d7
	move.w (coor_y,a6),d6
	muls.w z_coef_y,d6
	move.w (coor_z,a6),d5
	muls.w z_coef_z,d5
	add.l d6,d7
	add.l d5,d7
	lsr.l #8,d7		* z
				* calcul de q
	muls.w #p,d7		* z/p en 2^16 bits
	asr.l #8,d7
	sub.l #1*256,d7		* z/p-1 en 2^8 bits
	neg.l d7			* 1-z/p en 2^8 bits
	move.l #1*65536,d4
	divs.l d7,d4		* 1/(1-z/p) en 2^8 bits
				* calcul du nouveau x
	move.w (coor_x,a6),d2
	muls.w x_coef_x,d2
	move.w (coor_y,a6),d6
	muls.w x_coef_y,d6
	move.w (coor_z,a6),d5
	muls.w x_coef_z,d5
	add.l d6,d2
	add.l d5,d2
	lsr.l #8,d2		* x
	muls.w d4,d2
	swap d2			* division par 2^16
				* calcul du nouveau y
	move.w (coor_x,a6),d3
	muls.w y_coef_x,d3
	move.w (coor_y,a6),d6
	muls.w y_coef_y,d6
	move.w (coor_z,a6),d5
	muls.w y_coef_z,d5
	add.l d6,d3
	add.l d5,d3
	lsr.l #8,d3		* y
	muls.w d4,d3
	swap d3
	
	adda.l #t_coor,a6		* point suivant

		* appel de la routine de ligne
		* D0 : X de d‚part
		* D1 : Y de d‚part
		* D2 : X de d'arriv‚
		* D3 : Y de d'arriv‚
		* D4 : couleur
		* D0-D7/A0 : modifi‚
	add.w #offset_x,d0
	add.w #offset_x,d2
	add.w #offset_y,d1
	add.w #offset_y,d3
	move.l couleur,d4
	bsr ligne			* trace la ligne    

	tst.w (a6)
	bpl trave_3d_boucle1
	rts

* routine de ligne en 65536 couleurs
* recoit en D0 : X, D1 : Y : de d‚part
*           D2 : X, D3 : Y : d'arriv‚e
* D4 : couleur sur 32 bits !!
* modifie D0-D7, A0
ligne
	move.l #ecran_largeur*2,d7	* stockage de yinc
	move.w d2,d5		* calcul de dx dans D5
	sub.w d0,d5
	beq rout5	
	bpl xpasneg1		* si dx est nul, ligne verticale !!
				* si dx negatif, donc d2<d0
				* donc le premier point devient d2,d3
	neg.w d5
	exg.l d2,d0
	exg.l d3,d1
xpasneg1
				* on trace toujours vers les x croissants
				* calcul de dy
	move.w d3,d6
	sub.w d1,d6
	beq rout4			
				* dy est nul, ligne horizontal	
	bpl ypasneg1
				* dy n‚gatif, donc d4<d1
	neg.w d6
				* trac‚ en montant vers la droite
				* donc d7=-ecran_largeur*2
	neg.l d7
ypasneg1
	cmp.w d5,d6
				* comparaison dx et dy
	bmi rout2			* <0
	beq rout3			* =0 : une diagonale !!!

				* … la fin : d5 : dx
				*            d6 : dy
	* routine 1
	* ici dx>0, dy>0 et dy>dx
	* a pus besoin de d2, d3, et dx aprŠs division
rout1
				* si dx = 1 : 2 pixels de large !!
				* donc il faut rajouter 1 … chaque d
	addq.w #1,d5
	addq.w #1,d6
				* d‚calage de 16 bits pour la division
	swap d5
	clr.w d5
	divu.w d6,d5		
				* division de dx par dy + division par 16 bits
				* d5 contient la pente : r‚sultat sur 16 bits
				* boucle sur d6
	subq.w #1,d6
				* calcul d'adresse du 1er point dans a0
	movea.l adr_ecran,a0
	add.w d0,d0
	adda.w d0,a0
	mulu.w #ecran_largeur*2,d1
	adda.l d1,a0
				* somme = 0
	moveq.l #0,d3	
				* rappels des valeur des regsitres a ce point : 
				* d0 : 
				* d1 : 
				* d2 : 
				* d3 : somme
				* d4 : couleur
				* d5 : pente
				* d6 : delta y
				* d7 : offset pour changement de ligne 
ligneb1
	add.w d5,d3
	bcs lignenx1
				* pas de d‚placement suivant x
	move.w d4,(a0)
	adda.l d7,a0
	dbra d6,ligneb1
	rts
lignenx1
	move.w d4,(a0)+
	adda.l d7,a0
	dbra d6,ligneb1
	rts

	* routine 2
	* ici dx>0, dy>0 et dy<dx
	* a pus besoin de d2, d3, et dy aprŠs division
rout2
				* correction de d
	addq.w #1,d5
	addq.w #1,d6
				* d‚calage de 16 bits
	swap d6
	clr.w d6
	divu.w d5,d6
				* division de dy par dx + division par 16 bits
				* d6 contient la pente : r‚sultat sur 16 bits
				* boucle sur d5
	subq.w #1,d5
				* calcul d'adresse du 1er point dans a0
	movea.l adr_ecran,a0
	add.w d0,d0
	adda.w d0,a0
	mulu.w #ecran_largeur*2,d1
	adda.l d1,a0
				* somme = 0
	moveq.l #0,d3
				* d0 : 
				* d1 : 
				* d2 : 
				* d3 : somme
				* d4 : couleur
				* d5 : delta x
				* d6 : pente
				* d7 : offset pour changement de ligne et de pixel
ligneb2
	move.w d4,(a0)+
	add.w d6,d3
	bcc ligneny2			
				* pas de d‚placement suivant y 
	adda.l d7,a0
ligneny2
	dbra d5,ligneb2
	rts

	* ici dx>0, dy>0 et dx=dy
	* une diagonale!!
rout3
				* calcul d'adresse du 1er point dans a0
	movea.l adr_ecran,a0
	add.w d0,d0
	adda.w d0,a0
	mulu.w #ecran_largeur*2,d1
	adda.l d1,a0
				* division par 2 de d5
	lsr.w #1,d5
	bcc ligneb3
				* si retenue alors nombre impair
	move.w d4,(a0)+
	adda.l d7,a0
				* ce qui permet d'afficher 2 points par 2 points
ligneb3
	move.w d4,(a0)+
	adda.l d7,a0
	move.w d4,(a0)+
	adda.l d7,a0
	dbra d5,ligneb3
	rts

	* ici dy est nul
	* et dx positif
	* ligne horizontale
rout4
				* calcul d'adresse du 1er point dans a0
	movea.l adr_ecran,a0
	add.w d0,d0
	adda.w d0,a0
	mulu.w #ecran_largeur*2,d1
	adda.l d1,a0
				* division de d5 par 2
	lsr.w #1,d5
	bcc ligneb4
				* d5 : nombre impaire
	move.w d4,(a0)+
ligneb4
	move.l d4,(a0)+		* 2 pixels d'un coup !
	dbra d5,ligneb4
	rts

	* ici dx est nul
	* et dy est inconnu
	* ligne verticale
rout5
	move.w d3,d6
	sub.w d1,d6
	bmi rout5_yneg
	beq rout6
				* calcul d'adresse du 1er point dans a0
	movea.l adr_ecran,a0
	add.w d0,d0
	adda.w d0,a0
	mulu.w #ecran_largeur*2,d1
	adda.l d1,a0
				* division par 2 de d6
	lsr.w #1,d6
	bcc ligneb5
				* d6 : nombre impaire
	move.w d4,(a0)
	adda.l d7,a0
ligneb5
	move.w d4,(a0)
	adda.l d7,a0
	move.w d4,(a0)
	adda.l d7,a0
	dbra d6,ligneb5
	rts
rout5_yneg
	neg.w d6
	neg.l d7
				* calcul d'adresse du 1er point dans a0
	movea.l adr_ecran,a0
	add.w d0,d0
	adda.w d0,a0
	mulu.w #ecran_largeur*2,d1
	adda.l d1,a0
				* division par deux de d6
	lsr.w #1,d6
	bcc ligneb5_yneg
				* d6 : nombre impair
	move.w d4,(a0)
	adda.l d7,a1
ligneb5_yneg
	move.w d4,(a0)
	adda.l d7,a0
	move.w d4,(a0)
	adda.l d7,a0
	dbra d6,ligneb5_yneg
	rts

	* deltax est nul
	* deltay est nul
	* c'est un point
	* OK
rout6
				* calcul d'adresse du 1er point dans a0
	movea.l adr_ecran,a0
	add.w d0,d0
	adda.w d0,a0
	mulu.w #ecran_largeur*2,d1
	adda.l d1,a0
	move.w d4,(a0)
	rts

	include "principh.s"
	
	section DATA
objet
	* Struture de l'objet
	* liste d'aretes d‚finies par les coordonn‚es des points
	* extremes.
	* Structure d'un point : coordonn‚es x, y, z.
	* Coordonn‚es representer en virgule fixe : 
	*	8 bits partie entiŠre
	*	8 bits partie d‚cimale

			* base de la pyramide tronqu‚e
 	dc.w $0000, $0000, $0000		* premier point de l'arete
	dc.w $2800, $0000, $0000		* second point de l'arete

	dc.w $2800, $0000, $0000
	dc.w $2800, $2800, $0000
	
	dc.w $2800, $2800, $0000
	dc.w $0000, $2800, $0000
	
	dc.w $0000, $2800, $0000
	dc.w $0000, $0000, $0000

			* sommet de la pyramide tronqu‚e
	dc.w $0A00, $0A00, $0A00
	dc.w $1E00, $0A00, $0A00
	
	dc.w $1E00, $0A00, $0A00
	dc.w $1E00, $1E00, $0A00
	
	dc.w $1E00, $1E00, $0A00
	dc.w $0A00, $1E00, $0A00
	
	dc.w $0A00, $1E00, $0A00
	dc.w $0A00, $0A00, $0A00

			* aretes de la pyramide
	dc.w $0000, $0000, $0000
	dc.w $0A00, $0A00, $0A00
	
	dc.w $2800, $0000, $0000
	dc.w $1E00, $0A00, $0A00
	
	dc.w $2800, $2800, $0000
	dc.w $1E00, $1E00, $0A00
	
	dc.w $0000, $2800, $0000
	dc.w $0A00, $1E00, $0A00
	
	dc.w -1, -1, -1
	
sin	include "sin.dat"

cos	include "cos.dat"

	section BSS
couleur	ds.l 1		* couleur de tracage
			* valeur des angles de rotations
angle_x	ds.w 1
angle_y	ds.w 1
angle_z	ds.w 1
			* valeur des sinus/cosinus
sin_x	ds.w 1
cos_x	ds.w 1
sin_y	ds.w 1
cos_y	ds.w 1
sin_z	ds.w 1
cos_z	ds.w 1
			* valeur des precalcs
x_coef_x	ds.w 1
x_coef_y	ds.w 1
x_coef_z	ds.w 1
y_coef_x	ds.w 1
y_coef_y	ds.w 1
y_coef_z	ds.w 1
z_coef_x	ds.w 1
z_coef_y	ds.w 1
z_coef_z	ds.w 1