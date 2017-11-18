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
	clr.w couleur
	rts

prg
	move.l adr_ecran,a0
	adda.l #(117*ecran_largeur+89)*2,a0
	move.w (a0),d0
	move.w couleur,d1
	bsr remplir
	add.w #%0001000001000011,couleur
	and.w #%1111111111011111,couleur
	rts

remplir
	cmp.w (a0),d0
	bne pas_exploration
	move.w d1,(a0)
	move.l a0,-(sp)
	lea (a0,2),a0		* … droite
	bsr remplir
	move.l (sp),a0

	lea (a0,-2),a0		* … gauche
	bsr remplir
	move.l (sp),a0

	lea (a0,ecran_largeur*2),a0	* en bas
	bsr remplir
	move.l (sp)+,a0

	lea (a0,-ecran_largeur*2),a0	* en haut
	bsr remplir

pas_exploration
	rts

	section DATA
Fond	incbin "68030.tpi"

	section BSS
couleur	ds.w 1

	include "principh.s"