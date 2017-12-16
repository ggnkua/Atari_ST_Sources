* impl‚mentation du crible d'EratosthŠne
* … l'aide des instructions de manipulation de champs de bit
* par Golio Junior pour Falk'mag 7

VAL_MAX	equ 10000		* multiple de 32


	bsr init_crible
	bsr era_crible
	bsr extrait_crible
	
			* attendre une touche
	move.w #7,-(sp)	* fonction crawcin
	trap #1		* du gemdos
	addq.l #2,sp

			* fin du programme
	move.w #0,-(sp)
	trap #1

init_crible
			* mise … 1 des bits du crible
			* pour une recherche des ‚l‚ment … 1
			* dans la recherche des nombres premiers
	move.w #VAL_MAX/32-1,d0
	lea crible,a0
init_crible_b1
	move.l #-1,(a0)+
	dbra d0,init_crible_b1
	rts
	
era_crible
	lea crible,a0
	moveq.l #2,d0	* module de d‚part
			* il vaut commencer par 2, car tous les
			* nombres sont des multiples de 1
			* (x=x*1 : 1 : ‚l‚ment neutre pour la multiplication)
era_crible_b1
	move.l d0,d1	* mise … 2*module de l'accu
	lsl.l #1,d1	* car, un nombre est toujours multiple de lui mˆme
era_crible_b2
	bfclr (a0){d1:1}	* la valeur de d1 n'est pas un nombre premier
			* car elle est multiple de d0!
	add.l d0,d1	* multiple suivant
	cmp.l #VAL_MAX,d1
	ble era_crible_b2
	addq.l #1,d0	* nombre suivant
	cmp.l #VAL_MAX,d0
	ble era_crible_b1
	rts

extrait_crible
	lea crible,a6
	move.l #0,d6	* indice de d‚but de la recherche
extrait_crible_b1
	bfffo (a6){d6:32},d5
	beq extrait_crible_s1
	cmp.l #VAL_MAX,d5	* a t'on d‚pass‚ la valeur max?
	bgt extrait_crible_s2	* oui, alors c'est fini !
			* d5 : contient un nombre premier
			* l'afficher !
	bsr affd5
extrait_crible_s1
	move.l d5,d6
	addq.l #1,d6	* bit suivant, car celui-ci est d‚j… test‚
	cmp.l #VAL_MAX,d6	* on est rendu … la fin ?
	ble extrait_crible_b1	* non alors, on continu!
extrait_crible_s2
	rts

			* affichage de d5 en base 10
affd5
	move.l d5,d2
	move.w #10-1,d0	* nombre de chiffres … convertir (ici 10)
	lea affichage+10,a0	* on commence par les poids faibles !
affd5_b1
	divul.l #10,d1:d2
	add.b #'0',d1
	move.b d1,-(a0)
	dbra d0,affd5_b1
	move.l #(13*256+10)*65536+0*256+0,affichage+10
			* mise en place du retour chariot, du saut de ligne
			* et de l'indicateur de fin de chaine!
			* on voit o— mŠne la fain‚antise!
	pea affichage	* affichage gr…ce … la
	move.w #9,-(sp)	* fonction C_conws
	trap #1		* du Gemdos
	addq.l #6,sp
	rts

	section BSS
affichage	ds.b 20		* tableau pour l'affichage
crible	ds.l VAL_MAX/32	* tableau pour la crible