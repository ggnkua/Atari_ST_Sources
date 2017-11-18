* routine d'affichage de plasma d'interference en True Colors
* routine uniquement au 68030
* par Golio Junior

Video_mode	equ %000100100	* 40 col, 200 lig, 256 cou, TV Pal
Taille_ecran	equ 320*200*2/4

	include "principa.s"
* coordonn‚es du coin haut gauche des sprites et taille du sprite
x1	equ 160
y1	equ 100
x2	equ 320
y2	equ 200
largeur	equ 320
hauteur	equ 200

prg_init
	rts

prg
	move.l adr_ecran,a0
	lea sprite,a1	* adresse du 1er sprite
	adda.l #y1*640+x1,a1	* calcul de l'adresse du coin haut gauche du sprite
	lea sprite,a2
	adda.l #y2*640+x2,a2
	lea palette+32768*4,a3
	move.w #hauteur-1,d0
prg_bouc_y
	move.w #largeur/4-1,d1
prg_bouc_x
	move.l (a1)+,d2
	add.l (a2)+,d2
	swap d2
	move.l (0.w,a3,d2.w*4),(a0)+
	swap d2
	move.l (0.w,a3,d2.w*4),(a0)+
	dbra d1,prg_bouc_x
	adda.w #640-largeur,a1	* passage a la ligne suivante du sprite
	adda.w #640-largeur,a2
	dbra d0,prg_bouc_y
	rts

	section DATA
	even
sprite	incbin "inter_tc.dat"		* lancer gene_da2.prg 1 fois
palette	incbin "inter_tc.pal"

	include "principh.s"