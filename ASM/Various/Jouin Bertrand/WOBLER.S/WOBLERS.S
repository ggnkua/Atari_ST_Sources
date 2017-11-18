* affichage de wobller en soft
* par Golio Junior pour Falk'mag 7

* D‚finition de l'image
Video_mode		equ %000101100	* 80 col, 200 lig, 65536 cou, TV Pal
Taille_ecran	equ 640*200*2
ecran_largeur	equ 640
ecran_hauteur	equ 200
Pas_Fond		equ 0

* information pour le wobller
pas_1	equ 3
pas_2	equ 5

	include "principa.s"
prg_init
	rts

prg
				* calcul et affichage du wobller
	movea.l adr_ecran,a0
	lea data1,a1
	lea data2,a2
	move.w #ecran_hauteur-1,d0
	move.w posit_1,d1		* point de d‚part de la table
	move.w posit_2,d2
prg_b1
	move.w (a1,d1.w*2),d3		* valeur de la table 1
	move.w (a2,d2.w*2),d4		* valeur de la table 2
	subq.b #3,d1		* passage au ‚l‚ments suivant
	addq.b #1,d2		* modulo 256 !
	add.w d3,d4		* largeur de la ligne
	move.l #wobller,a3		* calcul de l'adresse de la ligne correspondante
	mulu.w #ecran_largeur*2,d4
	add.l d4,a3
				* affichage de la ligne
	move.w #ecran_largeur/8-1,d3
prg_b2
	rept 4
	move.l (a3)+,(a0)+
	endr
	dbra d3,prg_b2
	dbra d0,prg_b1
				* passage … la prochaine animation
	move.w posit_1,d0
	add.w #pas_1,d0
	andi.w #$FF,d0		* modulo 256
	move.w d0,posit_1

	move.w posit_2,d0
	add.w #pas_2,d0
	andi.w #$FF,d0		* modulo 256
	move.w d0,posit_2

	rts

	include "principh.s"
	
	section DATA
wobller_bin	incbin "wobler.tpi"	* graph contenant toutes les lignes
wobller	equ wobller_bin+128

data1	include "dat1.dat"		* table de pre-calcul
data2	include "dat2.dat"		* il faut faire attention a ce que
				* la somme de deux valeurs ne soit 
				* pas sup‚rieur … 200

	section BSS
posit_1	ds.w 1			* indice de d‚part dans les tables
posit_2	ds.w 1
