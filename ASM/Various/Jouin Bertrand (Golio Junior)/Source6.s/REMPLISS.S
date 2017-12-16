* remplissage de surface grace … un germe
* par Golio Junior pour Falk'mag 6

* D‚finition de l'image
Video_mode		equ %000100100	* 40 col, 200 lig, 65536 cou, TV Pal
Taille_ecran	equ 320*200*2
ecran_largeur	equ 320
ecran_hauteur	equ 200
Pas_Fond		equ 1
Fond_offset	equ 128

	include "principa.s"

prg_init
	clr.w couleur		* couleur de remplissage
	rts

prg
	move.l adr_ecran,a0		* adresse ‚cran
	adda.l #(117*ecran_largeur+89)*2,a0	* adresse du germe de remplissage
	move.w (a0),d0		* d0 : couleur de la surface … colorier
	move.w couleur,d1		* d1 : couleur de remplissage
	bsr remplir		* coloriage !

	add.w #%0001000001000011,couleur	* passage … la couleur suivante
	and.w #%1111111111011111,couleur
	rts

remplir
	cmp.w (a0),d0		* le point courant est-il … colorier?
	bne pas_exploration		* non alors c'est fini!
	move.w d1,(a0)		* sinon on le colorie

	move.l a0,-(sp)		* sauvegarde de l'adresse du point courant
	lea (a0,2),a0		* point … droite
	bsr remplir		* coloriage
	move.l (sp)+,a0		* r‚cup‚ration de l'adresse du point courant

	move.l a0,-(sp)		* ....
	lea (a0,-2),a0		* point … gauche
	bsr remplir
	move.l (sp)+,a0

	move.l a0,-(sp)		* ....
	lea (a0,ecran_largeur*2),a0	* point en bas
	bsr remplir
	move.l (sp)+,a0

	move.l a0,-(sp)		* ....
	lea (a0,-ecran_largeur*2),a0	* point en haut
	bsr remplir
	move.l (sp)+,a0

pas_exploration
	rts

	section DATA
Fond	incbin "68030.tpi"		* fond d'‚cran

	section BSS
couleur	ds.w 1			* couleur de remplissage

	include "principh.s"