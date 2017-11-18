* affichage de sprite en monochrome
* utilisation des instruction de manipulation de champ de bit
* par Golio Junior pour Falk'mag 7

* D‚finition de l'image
Video_mode		equ %100101000	* 80 col, 400 lig, 2 cou, TV Pal
Taille_ecran	equ 640*400/8
ecran_largeur	equ 640
ecran_hauteur	equ 400
Pas_Fond		equ 0

* donn‚es pour le sprite
pos_x	equ 130
pos_y	equ 56
largeur	equ 160
hauteur	equ 100

	include "principa.s"
prg_init
	movea.l adr_ecran,a0		* adresse du d‚but de l'‚cran
	move.w #Taille_ecran/16-1,d0	* pour un effacage
prg_init_b1			* de tout l'‚cran
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	dbra d0,prg_init_b1

	rts

prg
	movea.l adr_ecran,a0		* adresse du d‚but de l'‚cran
	move.l #pos_y,d0
	mulu.w #ecran_largeur/8,d0	* adresse du premier pixel (au mot long pres)
	add.w #(pos_x/32)*4,d0	* (pos_x/32 : No du mot long contenant les premiers pixels)
	adda.l d0,a0		* dans a0
	
	movea.l #sprite,a1		* adresse du sprite dans a1
	move.w #hauteur-1,d0
prg_b1
				* calcul du d‚calage
	move.l #-(pos_x&31),d7
	move.w #largeur/32-1,d1
prg_b2
	bfextu (a1){d7:32},d6		* lecture du mot long … afficher
	move.l d6,(a0)+		* affichage
	add.l #32,d7		* pixels suivants
	dbra d1,prg_b2
	
	adda.l #ecran_largeur/8-largeur/8,a0	* passage … la ligne de l'‚cran suivante
	adda.l #largeur/8,a1			* passage … la ligne du sprite suivante
	dbra d0,prg_b1
	rts

	include "principh.s"
	
	section DATA
sprite_bin	incbin "sprite.tpi"
sprite	equ sprite_bin+140