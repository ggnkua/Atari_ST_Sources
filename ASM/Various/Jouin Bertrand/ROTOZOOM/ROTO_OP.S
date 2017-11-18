* Rotozoom et d‚formation (version optimis‚e)
* Routine en True Color (320*200)
* par Golio Junior pour Falk'mag 7

* D‚finition de l'image
Video_mode		equ %000100100	* 40 col, 200 lig, 65536 cou, TV Pal
Taille_ecran	equ 320*200*2
ecran_largeur	equ 320
ecran_hauteur	equ 200
Pas_Fond		equ 0

* d‚finition du sprite
largeur	equ 128				* attention le sprite est r‚p‚t‚
hauteur	equ 128				* 4 fois !
m_largeur	equ 127			* masque des bits significatifs
m_hauteur	equ 127			* masque des bits significatifs

* d‚finition de la rotation
rotation_ok	equ	1
init_angle	equ	8
x_centre	equ	160		* coordonn‚es du point fixe
y_centre	equ	100		* … l'‚cran

* d‚finition du zoom
zoom_ok		equ	1		* 1 : zoom actif, 0 : zoom inactif
max_zoom	equ	5*65536		* borne max du zoom : 5 max
min_zoom	equ	65536/5		* borne min du zoom : 1/5 min
init_pas_zoom	equ	65536/16	* pas du zoom de 1/16

* d‚fintion de la d‚formation lin‚aire
deform_lin_ok	equ	1
max_x_zoom	equ	2*65536		* borne max du zoom en x
min_x_zoom	equ	65536/5		* borne min du zoom en x
init_pas_x_zoom	equ	65536/16	* pas du zoom en x
max_y_zoom	equ	2*65536		* borne max du zoom en y
min_y_zoom	equ	65536/5		* borne min du zoom en y
init_pas_y_zoom	equ	65536/32	* pas du zoom en y

* d‚finition de la d‚formation quadratique
deform_quad_ok	equ	1		* indique l'utilisation de la d‚formation quadratique

* d‚finition de l'utilisation du caches donn‚es
cache_ok	equ	1		* indique qu'on utilise le cache

* les calculs se font en virgules fixes sur 32 bits : 
*	16 bits partie entiŠre
*	16 bits partie d‚cimale

	include "principa.s"

* routine d'initialisation
prg_init
	move.w	#init_angle,angle	* initialisation de l'angle de rotation
	move.l	#1*65536,zoom		* zoom … 1 (pas de zoom)
	move.l	#1*65536,zoom_x
	move.l	#1*65536,zoom_y
	move.l	#init_pas_zoom,pas_zoom	* pas du zoom positif
	move.l	#init_pas_x_zoom,pas_x_zoom
	move.l	#init_pas_y_zoom,pas_y_zoom

	move.l	adr_ecran,a0
	move.w	#ecran_largeur*ecran_hauteur*2/16-1,d0
prg_init_b1
	rept	4
	clr.l	(a0)+
	endr
	dbra	d0,prg_init_b1

	rts

prg
					* calcul des pas
	move.w	angle,d0
	move.l	(cos,d0.w*4),d6		* cosinus de l'angle
	move.l	(sin,d0.w*4),d7		* sinus de l'angle

	ifne	deform_quad_ok		* calcul des pas de d‚formations
	move.l	d7,d4			* pour la d‚formation, on prend
	lsr.l	#6,d4			* quelque chose de proportionnel
	move.l	d4,deform_cos		* au cosinus/sinus de l'angle
	move.l	d6,d4			* ici 64 fois plus petit que le cosinus/sinus
	lsr.l	#6,d4
	move.l	d4,deform_sin
	endc

					* application des zooms
	muls.l	zoom,d5:d6		* les pas se trouvent
	move.w	d5,d6			* multipli‚s par le zoom
	swap	d6			* les deux se trouvent en virgules fixe
	muls.l	zoom,d5:d7		* donc seuls les 32 bits du milieu
	move.w	d5,d7			* nous interressent
	swap	d7

	move.l	d6,cosinus
	move.l	d7,sinus

	ifne	deform_lin_ok
	muls.l	zoom_x,d5:d6
	move.w	d5,d6
	swap	d6
	muls.l	zoom_y,d5:d7
	move.w	d5,d7
	swap	d7
	move.l	cosinus,d0
	muls.l	zoom_y,d1:d0
	move.w	d1,d0
	swap	d0
	move.l	d0,cosinus
	move.l	sinus,d1
	muls.l	zoom_x,d2:d1
	move.w	d2,d1
	swap	d1
	move.l	d1,sinus
	endc

					* calcul des offsets de d‚part pour la translation
	move.l	d6,d4			* la formule est : 
	muls.l	#x_centre,d4		* debut_x=-x_centre*cos(angle)-y_centre*sin(angle)+x_centre
	move.l	d1,d5			* le r‚sutat est en virgule fixe (16/16)
	muls.l	#y_centre,d5		* mais je le rappelle, lorsque l'on multiplie
	add.l	d5,d4			* par un entier, il n'y a pas de correction … apporter
	neg.l	d4
	add.l	#x_centre*65536,d4	* ajout de x_centre (c'est un entier , donc multiplier
	move.l	d4,debut_x		* par 2^16 (65536)

	move.l	d0,d4			* meme raisonnement mais pour debut_y
	muls.l	#y_centre,d4		* debut_y=-y_centre*cos(angle)+x_centre*sin(angle)+y_centre
	neg.l	d4
	move.l	d7,d5
	muls.l	#x_centre,d5
	add.l	d5,d4
	add.l	#y_centre*65536,d4
	move.l	d4,debut_y
	
					* calcul de la table des offsets
	lea	offset,a0
	clr.l	d4			* coordonn‚e x dans le sprite … 0
	clr.l	d5			* coordonn‚e y dans le sprite … 0
	move.w	#ecran_largeur-1,d0
prg_b3
	add.l	d6,d4			* interpolation en x
	bpl	.s1			* saut si positif
	add.l	#largeur*65536,d4	* sinon ajout de la largeur
					* on retombe forc‚ment dans le
					* sprite
.s1	sub.l	d7,d5			* interpolation en y
	bpl	.s2			* saut si positif
	add.l	#hauteur*65536,d5	* sinon ajout de la hauteur
.s2
					* calcul du point du sprite
	move.l	d5,d2			* on prend la partie entiŠre
	swap	d2			* de la hauteur
	andi.w	#m_hauteur,d2		* que l'on masque (comprise entre 0 et m_hauteur)
	mulu.w	#largeur*2,d2		* et que l'on multiplie par le double de la largeur du sprite
					* car il y a 4 fois le meme sprite
	move.l	d4,d3			* de meme pour la largeur
	swap	d3
	andi.l	#m_largeur,d3		* masquage
	add.l	d3,d2			* d‚placement en pixels par rapport
					* au d‚but du sprite
	lsl.l	#1,d2			* offset en octet
	move.l	d2,(a0)+		* stockage de l'offset

	ifne	deform_quad_ok
	add.l	deform_cos,d6		* modification des coefficients
	add.l	deform_sin,d7		* pour la d‚formation
	endc

	dbra	d0,prg_b3

	ifne	cache_ok		* on vire les caches
	movec.l	cacr,d0
	bclr.l	#8,d0
	movec.l	d0,cacr
	endc
					* d‚but du rotozoom
	move.l	debut_x,d4		* coordonn‚e x dans le sprite
	move.l	debut_y,d5		* coordonn‚e y dans le sprite
	move.l	adr_ecran,a0		* adresse ‚cran
	move.w	#ecran_hauteur-1,d0	* … faire sur toutes les lignes
prg_b1
	lea	offset,a1

	add.l	sinus,d4		* ajout du d‚placement en x
	add.l	cosinus,d5		* ajout du d‚placement en y
					* ceci pour connaitre le point de d‚part de la ligne
					* dans le sprite
					* calcul du point de d‚part du sprite
	move.l	d5,d2			* on prend la partie entiŠre
	swap	d2			* de la hauteur
	addi.w	#-y_centre,d2
	andi.w	#m_hauteur,d2		* que l'on masque (comprise entre 0 et m_hauteur)
	mulu.w	#largeur*2,d2		* et que l'on multiplie par le double de la largeur du sprite
					* car il y a 4 fois le meme sprite
	move.l	d4,d3			* de meme pour la largeur
	swap	d3
	addi.w	#-x_centre,d3
	andi.l	#m_largeur,d3		* masquage
	add.l	d3,d2			* d‚placement en pixels par rapport
					* au d‚but du sprite
	lsl.l	#1,d2			* offset en octet
	addi.l	#sprite,d2
					* ici on effectue une translation dans le sprite
					* pour que le centre de rotation coincide
					* avec le coin haut gauche du sprite
					* d2 contient l'adresse du 1er point de la ligne

	move.w	#ecran_largeur/32-1,d1	* pour toute la ligne
prg_b2
	move.w	([a1],d2.l),(a0)+
	move.w	([a1,4],d2.l),(a0)+
	move.w	([a1,8],d2.l),(a0)+
	move.w	([a1,12],d2.l),(a0)+
	move.w	([a1,16],d2.l),(a0)+
	move.w	([a1,20],d2.l),(a0)+
	move.w	([a1,24],d2.l),(a0)+
	move.w	([a1,28],d2.l),(a0)+
	move.w	([a1,32],d2.l),(a0)+
	move.w	([a1,36],d2.l),(a0)+
	move.w	([a1,40],d2.l),(a0)+
	move.w	([a1,44],d2.l),(a0)+
	move.w	([a1,48],d2.l),(a0)+
	move.w	([a1,52],d2.l),(a0)+
	move.w	([a1,56],d2.l),(a0)+
	move.w	([a1,60],d2.l),(a0)+
	move.w	([a1,64],d2.l),(a0)+
	move.w	([a1,68],d2.l),(a0)+
	move.w	([a1,72],d2.l),(a0)+
	move.w	([a1,76],d2.l),(a0)+
	move.w	([a1,80],d2.l),(a0)+
	move.w	([a1,84],d2.l),(a0)+
	move.w	([a1,88],d2.l),(a0)+
	move.w	([a1,92],d2.l),(a0)+
	move.w	([a1,96],d2.l),(a0)+
	move.w	([a1,100],d2.l),(a0)+
	move.w	([a1,104],d2.l),(a0)+
	move.w	([a1,108],d2.l),(a0)+
	move.w	([a1,112],d2.l),(a0)+
	move.w	([a1,116],d2.l),(a0)+
	move.w	([a1,120],d2.l),(a0)+
	move.w	([a1,124],d2.l),(a0)+
	lea	(a1,128.w),a1

	dbra	d1,prg_b2		* pixel suivant

	dbra	d0,prg_b1		* ligne suivante

	ifne	cache_ok		* on remet les caches
	movec.l	cacr,d0
	bset.l	#8,d0
	movec.l	d0,cacr
	endc

	ifne	rotation_ok
	move.w	angle,d0		* passage … l'angle suivant
	addq.w	#1,d0			* il y 256 angles diff‚rents
	andi.w	#$00FF,d0		* donc masquage avec 255
	move.w	d0,angle
	endc

	ifne	zoom_ok
	move.l	zoom,d0			* passage au coefficient de zoom
	add.l	pas_zoom,d0		* suivant
	cmp.l	#max_zoom,d0		* le zoom est compris entre deux bornes
	blt	.zoom_pas_sup		* max_zoom
	move.l	#max_zoom,d0		* si on est sup‚rieur, alors max_zoom
	neg.l	pas_zoom		* et changement du signe du pas du zoom
.zoom_pas_sup
	cmp.l	#min_zoom,d0		* et la borne min_zoom
	bgt	.zoom_pas_inf		* si on est inf‚rieur
	move.l	#min_zoom,d0		* le zoom de vient min_zoom
	neg.l	pas_zoom		* et on change le signe du pas
.zoom_pas_inf
	move.l	d0,zoom
	endc

	ifne	deform_lin_ok
	move.l	zoom_x,d0			* passage au coefficient de zoom
	add.l	pas_x_zoom,d0		* suivant
	cmp.l	#max_x_zoom,d0		* le zoom est compris entre deux bornes
	blt	.zoom_x_pas_sup		* max_zoom
	move.l	#max_x_zoom,d0		* si on est sup‚rieur, alors max_zoom
	neg.l	pas_x_zoom		* et changement du signe du pas du zoom
.zoom_x_pas_sup
	cmp.l	#min_x_zoom,d0		* et la borne min_zoom
	bgt	.zoom_x_pas_inf		* si on est inf‚rieur
	move.l	#min_x_zoom,d0		* le zoom de vient min_zoom
	neg.l	pas_x_zoom		* et on change le signe du pas
.zoom_x_pas_inf
	move.l	d0,zoom_x

	move.l	zoom_y,d0			* passage au coefficient de zoom
	add.l	pas_y_zoom,d0		* suivant
	cmp.l	#max_y_zoom,d0		* le zoom est compris entre deux bornes
	blt	.zoom_y_pas_sup		* max_zoom
	move.l	#max_y_zoom,d0		* si on est sup‚rieur, alors max_zoom
	neg.l	pas_y_zoom		* et changement du signe du pas du zoom
.zoom_y_pas_sup
	cmp.l	#min_y_zoom,d0		* et la borne min_zoom
	bgt	.zoom_y_pas_inf		* si on est inf‚rieur
	move.l	#min_y_zoom,d0		* le zoom de vient min_zoom
	neg.l	pas_y_zoom		* et on change le signe du pas
.zoom_y_pas_inf
	move.l	d0,zoom_y
	endc

	rts

	include "principh.s"
	
	section DATA

cos	include "cosin.dat"
	include "cosin.dat"

sin	equ	cos+48*4
sprite_bin	incbin "rotozoom.tpi"
sprite	equ sprite_bin+128

	section BSS
angle	ds.w	1
cosinus	ds.l	1
sinus	ds.l	1
zoom	ds.l	1
zoom_x	ds.l	1
zoom_y	ds.l	1
pas_zoom	ds.l	1
pas_x_zoom	ds.l	1
pas_y_zoom	ds.l	1
debut_x	ds.l	1
debut_y	ds.l	1
deform_cos	ds.l	1
deform_sin	ds.l	1
offset	ds.l	ecran_largeur