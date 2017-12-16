* routine d'affichage de plasma d'interference
* routine uniquement au 68030
* par Golio Junior

Video_mode	equ %000100011	* 40 col, 200 lig, 256 cou, TV Pal
Taille_ecran	equ 320*200/4

	include "principa.s"
* coordonn‚es du coin haut gauche des sprites et taille du sprite
x1	equ 160		* multiple de 16
y1	equ 100
x2	equ 320
y2	equ 200
largeur	equ 320
hauteur	equ 200

prg_init	* initialisation de la palette
	wait_sys
	lea palette,a0
	move.l #$ff9800,a1
	move.l #$ff9800+64*4,a2
	move.l #$ff9800+128*4,a3
	move.l #$ff9800+192*4,a4
	move.w #64-1,d0
prg_init_b1
	move.l (a0)+,d1
	move.l d1,(a1)+
	move.l d1,(a2)+
	move.l d1,(a3)+
	move.l d1,(a4)+
	dbra d0,prg_init_b1
	rts
prg
	move.l adr_ecran,a0
	lea sprite,a1	* adresse du 1er sprite
	adda.l #y1*640+x1,a1	* calcul de l'adresse du coin haut gauche du sprite
	lea sprite,a2
	adda.l #y2*640+x2,a2
	move.w #hauteur-1,d0
prg_bouc_y
	move.w #largeur/16-1,d1
prg_bouc_x
	clr.w d3
	REPT 8
		* chargement dans d4/d5
	move.w (a1)+,d4	* 1 mot du 1er sprite
	move.w d3,d2	* d2 : ancienne retenue
	eor.w  d4,d2	* addition sans retenue de la precedente retenue
	move.w (a2)+,d5	* 1 mot du 2nd sprite
		* addition avec retenue : resultat dans d2
	eor.w  d5,d2
		* affichage du resultat
	move.w d2,(a0)+
		* nouvelle retenue dans d3
	move.w d4,d6	* voir explication dans l'article
	or.w d5,d6		* OU entre les mots des sprites
	and.w d3,d6	* suivit du ET avec la retenue
	move.w d4,d3	* Calcul du mot du 1er sprite
	and.w d5,d3	* ET du mot du second
	or.w d6,d3		* suivit du OU : Nouvelle retenue
	ENDR
	
	dbra d1,prg_bouc_x
	adda.w #640-largeur,a1	* passage a la ligne suivante du sprite
	adda.w #640-largeur,a2
	dbra d0,prg_bouc_y
	rts

	section DATA
	even
sprite	incbin "inter.dat" 		* lancer gene_dat.prg 1 fois
palette	include "inter.pal"

	include "principh.s"