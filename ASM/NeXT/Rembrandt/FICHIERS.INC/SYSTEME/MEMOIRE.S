max_malloc = 300
; REMBRANDT 3.0 - ½  Dbug II/MIT
;
; Module de gestion m‚moire. (1.2)
;
; - Toutes les fonctions commencent par tester l'existance du bloc (1ere
;   adresse non nulle).
;
; M‚thode … utiliser:
; - R‚server un gros bloc de m‚moire (Taille maximale param‚trable via la
; ressource)
; - On conserve la m‚thode d'allocation (passage d'un pointeur sur un
; bloc de d‚finition).
;
; Pour une facilit‚ de gestion ‚vidente, chaque bloc de la m‚moire allou‚e.
; devra commencer … une adresse multiple de 4.
; Si l'on souhaite utiliser OUTSIDE, il faut utiliser MXALLOC... La m‚moire
; ®OUTSIDE¯ ne peut-ˆtre utilis‚e que pour les images. Le bloc destin‚ … la
; m‚moire ‚cran DOIT rester absolument en m‚moire principale.
;
; Structure de la table de gestion des blocs:
; .W	Nombre de blocs en m‚moire
; .L	Adresse de d‚part de la m‚moire allou‚e.
; .L	Taille totale de la m‚moire allou‚e.

; .L	Adresse du bloc m‚moire No 1
; .L	Taille du bloc m‚moire No 1
; .L	Adresse de fin du bloc m‚moire No 1




; fontion realloc
; si 0 libere_bloc, retour 0 si libere bloc effectue
; si <0 libŠre bloc, retour 0 si libere bloc effectue
; si >0 realloue, 0 si reussite



; adresse
; longueur
; pointeur sur variable adresse
; signed MIT

 section TEXT


; R‚servation d'un gros bloc de m‚moire lors du d‚marrage.
; On d‚coupera ensuite ce bloc en petits morceaux r‚allou‚s
; dynamiquement en fonction des besoins.

r‚serve_m‚moire_globale
 move.l #-1,-(sp)
 move #$48,-(sp)
 trap #1
 addq #6,sp
 sub.l #40000,d0		On laisse g‚n‚reusement 40000 octets pour le systŠme...
 bmi.s .pas_de_m‚moire
 move.l d0,d1
 subq.l #4,d1
 and.b #$fc,d2
 move.l d1,taille_memoire	Taille allou‚e (multiple de 4)
 move.l d1,memoire_libre
 clr.l memoire_occupe		Toute la m‚moire est encore libre
 move.l d0,-(sp)
 move #$48,-(sp)
 trap #1
 addq #6,sp
 addq.l #3,d0			On fait en sorte que l'adresse renvoy‚e
 and.b #$fc,d0			par le GEMDOS soit d‚ja un multiple de 4
 move.l d0,adr_memoire		Ca simplifie un peu pour plus tard...
 move.l #-1,adr_malloc
 moveq #0,d0
 rts
.pas_de_m‚moire
 moveq #-1,d0
 rts




; La notion de ®bloc de d‚finition¯ suppose que l'adresse o— mettre la
; valeur retourn‚e doit etre compos‚e de 3 mots long. Ex:
;
;    mon_pointeur:	+0 ds.l 1	Adresse … utiliser allign‚e sur 4
;			+4 ds.l 1	Taille du bloc demand‚
combien_m‚moire
 move.l memoire_libre,d0
 rts

 
*
*	En entr‚e:
* D0=Nombre d'octets
* A0=Adresse du bloc de d‚finition
*	En retour:
* D0=Code d'erreur ou 0 si tout va bien.
*
* - Le bloc r‚serv‚ est effac‚ automatiquement lors de la r‚servation de
*   m‚moire.
* - Le bloc courant n'est pas r‚allou‚ si le bloc courant est de la meme
*   taille que le bloc demand‚.
*
r‚serve_bloc
 tst.l (a0)			Y'a t'il d‚ja un bloc … cette adresse ?
 beq.s .le_bloc_est_libre
 movem.l d0/a0,-(sp)
 bsr libŠre_bloc		Si y'a un bloc, on le d‚truit.
 movem.l (sp)+,d0/a0
.le_bloc_est_libre
 bsr kalloc
 tst.l d0
 ble.s .ya_un_problŠme
 move.l d0,(a0)		M‚morise l'adresse allign‚e sur un multiple de 4
 bsr efface_bloc	On fait un peu de nettoyage !
 moveq #0,d0
 rts
 
.ya_un_problŠme 
 clr.l (a0)
 moveq #-1,d0
 rts

r‚serve_bloc_jpg
 tst.l (a0)			Y'a t'il d‚ja un bloc … cette adresse ?
 beq.s .le_bloc_est_libre
 movem.l d0/a0,-(sp)
 bsr libŠre_bloc_jpg		Si y'a un bloc, on le d‚truit.
 movem.l (sp)+,d0/a0
.le_bloc_est_libre
 bsr kalloc
 tst.l d0
 ble.s .ya_un_problŠme
 moveq #0,d0
 rts
.ya_un_problŠme 
 clr.l (a0)
 moveq #-1,d0
 rts

*
*	 En entr‚e:
* A0=adresse du bloc de d‚finition
*	 En retour:
* D0=0 si tout va bien (Autre chose n‚gatif sinon, disons -1 !)
*
*    mon_pointeur:	+0 ds.l 1	Adresse … utiliser allign‚e sur 4
* 			+4 ds.l 1	Taille du bloc en octets
libŠre_bloc
 tst.l (a0)
 beq.s .fin_lib‚ration
 move.l (a0),d0
 bsr kmfree
 clr.l (a0)
.fin_lib‚ration
 moveq #0,d0		On suppose qu'une lib‚ration est toujours bonne...
 rts

libŠre_bloc_jpg
 tst.l (a0)
 beq.s .fin_lib‚ration
 move.l (a0),d0
 bsr kmfree
 clr.l (a0)
.fin_lib‚ration
 moveq #0,d0		On suppose qu'une lib‚ration est toujours bonne...
 rts




 
*
*	En entr‚e:
* A0=Adresse du champ de d‚finition de bloc.
*
efface_bloc
 movem.l d0-a6,-(sp)

 tst.l (a0)			On n'efface pas une bloc inexistant !
 beq.s .fin_effacement
 move.l (a0),a6

 lea adr_malloc,a1
 move.l #max_malloc,d7
.loop_calcul_lieu_malloc
 subq.l #1,d7
 bmi	.fin_effacement
 tst.l 	(a1)
 bmi	.fin_effacement
 
 move.l (a1)+,d2
 addq #8,a1
 cmp.l a6,d2
 bne.s .loop_calcul_lieu_malloc
 
 lea -12(a1),a0
 move.l 4(a0),d0 
 move.l (a0),a0			L'adresse de d‚but du bloc 
 add.l d0,a0			-> Adresse de la fin du bloc ! (CQFD)
 move.l d0,d1
 lsr.l #8,d1			Effacement par blocs de 256 octets
 beq.s .fin_movem

 move.l d1,d2

 lsl.l #8,d2
 sub.l d2,d0 				D0=Nombre d'octets restants … effacer
 movem.l buffer_vide,d2-d7/a1-a6	6+6=12*4=48 octets
  
.efface_bloc
 movem.l d2-d7/a1-a6,-(a0)		On efface !
 movem.l d2-d7/a1-a6,-(a0)		sauvagement
 movem.l d2-d7/a1-a6,-(a0)		par blocs de 256
 movem.l d2-d7/a1-a6,-(a0)		octets, en partant
 movem.l d2-d7/a1-a6,-(a0)		de la fin du bloc.
 movem.l d2-d5,-(a0)			C'est fini ?
 subq.l #1,d1
 bne.s .efface_bloc    
.fin_movem

 tst.l d0
 beq.s .fin_effacement
 subq #1,d0
.efface_octets
 clr.b -(a0)
 dbra d0,.efface_octets
.fin_effacement 

 movem.l (sp)+,d0-a6
 rts



; a0 -> Adresse du bloc de d‚finition
; d0 -> Taille du bloc demand‚
;
kalloc
 movem.l d1-a6,-(sp)
 move.l a0,a6

; Commence par v‚rifier s'il reste de la m‚moire de disponible...
 move.l memoire_libre,d1
 cmp.l d0,d1
 bgt.s .m‚moire_suffisante

.plus_de_memoire_disponible
 movem.l (sp)+,d1-a6
 moveq #-1,d0
 rts

; Il en reste, donc on cherche o— on va la mettre

.m‚moire_suffisante
 lea adr_malloc,a0
 move.l #max_malloc,d7
 moveq #0,d1
.loop_calcul_lieu_malloc
 subq.l #1,d7
 bmi.s	.plus_de_memoire_disponible
 tst.l (a0)
 bmi.s .fin_calcul_lieu_malloc
 move.l (a0)+,d2
 addq #8,a0
 cmp.l d1,d2
 blt.s .loop_calcul_lieu_malloc
 move.l d2,d1
 lea -12(a0),a1
 bra.s .loop_calcul_lieu_malloc

.fin_calcul_lieu_malloc
 tst.l d1
 bne.s .pas_premier_malloc

 move.l adr_memoire,d2	L'adresse de d‚but est d‚ja allign‚e correctement.
 bra.s .malloc_fini

.pas_premier_malloc
 move.l (a1)+,d2	Adresse du bloc pr‚c‚dent
 add.l (a1)+,d2		+ Longueur du bloc pr‚c‚dent
 addq.l #3,d2		On arrondie au prochain multiple
 and.b #$fc,d2

.malloc_fini
 move.l d2,(a0)+	M‚morise l'adresse de d‚part...
 move.l d0,(a0)+	La longueur (quelconque) du bloc...
 move.l a6,(a0)+	L'adresse du bloc de d‚finition...
 move.l d2,(a6)		Et renvoie l'adresse allou‚e dans le bloc !
 move.l #-1,(a0)+	-> Indique la fin de la liste

 addq.l #3,d0		Puis met … jour les compteur de m‚moire.
 and.b #$fc,d0
 add.l d0,memoire_occupe
 sub.l d0,memoire_libre

 move.l d2,d0		Renvoie l'adresse allou‚e
 movem.l (sp)+,d1-a6
 rts


; fontion realloc
; si 0 libere_bloc retour 0 si libere bloc effectue
; si <0 libŠre bloc retour 0 si libere bloc effectue
; si >0 realloue 0 si reussite

realloc
; a0 pointeur
; d0 nouvelle taille

	tst.l	d0
	beq.s .libere	
	bpl.s .no_prob
 	bsr libŠre_bloc
	rts
.libere
 	bsr libŠre_bloc
	rts

.no_prob

 movem.l d1-a6,-(sp)
 move.l a0,a6

 lea adr_malloc,a0
 move.l #max_malloc,d7
.loop_calcul_lieu_malloc
 subq.l #1,d7
 bmi	.plus_de_memoire_disponible
 tst.l (a0)
 bmi	.plus_de_memoire_disponible
 addq #8,a0
 move.l (a0)+,d2
 cmp.l a6,d2
 bne.s .loop_calcul_lieu_malloc
; okay on a trouve la structure du bloc .....
	move.l	a0,a1
	lea	-12(a0),a0
	move.l	4(a0),d6
	sub.l	d0,d6
	neg.l	d6
	move.l memoire_libre,d1
 	cmp.l d1,d6
 	bgt .plus_de_memoire_disponible

  	tst.l	d6
	beq	.end_realloc
	bpl.s	.augmente_taille

; reduit taille
	neg.l	d6
	
	move.l 4(a0),d0
	
	sub.l	d6,4(a0)
	sub.l d6,memoire_occupe
	add.l d6,memoire_libre
	
	and.l	#$3,d0
	sub.l	d6,d0
	bpl	.end_realloc

	neg.l	d0
	addq.l #3,d0		
	and.b #$fc,d0
	
	

	lea	12(a0),a0
.loop_deplace_bloc_reduction
	subq.l #1,d7
	bmi.s	.bloc_is_at_the_end_reduction
	cmp.l	#-1,(a0)
	beq.s	.bloc_is_at_the_end_reduction
		
	move.l  (a0),a2		; source
	
	move.l	a2,a1
	sub.l  d0,a1
	move.l a1,(a0)

	move.l	4(a0),d5
	addq.l	#3,d5		
	and.b	#$fc,d5

	lsr.l	#2,d5
.loop_reduit
	move.l	(a2)+,(a1)+		
	subq.l #1,d5	
	bne.s .loop_reduit	

	lea	12(a0),a0
	bra.s	.loop_deplace_bloc_reduction
.bloc_is_at_the_end_reduction
   	bra .end_realloc



.augmente_taille


	move.l d6,d2
	addq.l #3,d6		
	and.b #$fc,d6   ; multiple de 4 !!!!!

	add.l d6,memoire_occupe	
 	sub.l d6,memoire_libre
	
	move.l  a0,a6
	lea	12(a0),a0

	moveq 	#0,d4
.loop_how_many_blocks
	subq.l #1,d7
	bmi.s	.bloc_computed
	cmp.l	#-1,(a0)
        beq.s	.bloc_computed
	addq	#1,d4
	lea	12(a0),a0
	bra.s	.loop_how_many_blocks
.bloc_computed
	lea	-12(a0),a0
	subq	#1,d4
	bmi.s	.rien_a_bouge
.loop_augmente
	move.l (a0),a1
	add.l d6,(a0)
	move.l 4(a0),d0
	addq.l #3,d0
	and.b #$fc,d0
	add.l d0,a1
	move.l a1,a2
	add.l	d6,a2
	lsr.l	#2,d0
.loop_copy
	move.l -(a1),-(a2)
	subq.l #1,d0
	bne.s .loop_copy
	


	move.l 8(a0),a1
	move.l (a0),(a1)
	lea	-12(a0),a0
	dbra  d4,.loop_augmente
.rien_a_bouge

; efface le petit bloc en plus
	move.l (a6),a1
	move.l 4(a6),d0
	add.l  d0,a1
	add.l  d2,4(a6)	; met a jour la taille
	move.l	d2,d5
.loop_clear
	clr.b (a1)+		
	subq.l #1,d5
	bne.s .loop_clear


.end_realloc
 movem.l (sp)+,d1-a6
 moveq	#0,d0
 rts
 
.plus_de_memoire_disponible
 movem.l (sp)+,d1-a6
 moveq	#-1,d0
 rts




; a0 -> Adresse du bloc de d‚finition
; d0 -> Adresse du bloc allou‚

kmfree
 movem.l d1-a6,-(sp)
 
 lea adr_malloc,a0
.boucle_recherche_bloc
 tst.l (a0)		Si on trouve -1, on a atteind la fin de la liste... -> BUG
 bmi .error_mfree
 move.l (a0)+,d1	Adresse du bloc
 move.l (a0)+,d2	Longueur (quelconque)
 addq #4,a0
 cmp.l d0,d1
 bne.s .boucle_recherche_bloc
 addq.l #3,d2		Puis met … jour les compteur de m‚moire.
 and.b #$fc,d2
 sub.l d2,memoire_occupe
 add.l d2,memoire_libre
 tst.l (a0)		Teste le bloc suivant, pour voir si c'est le dernier.
 bpl.s .d‚salloue_bloc_quelconque
;
; On a trouv‚ le bloc en question, c'est le dernier de la liste
;
.d‚salloue_bloc_final
 move.l #-1,-12(a0)	D‚place l'indicateur de fin de liste
 movem.l (sp)+,d1-a6
 moveq #0,d0
 rts
;
; On a trouv‚ le bloc en question, et ce n'est pas le dernier. Donc,
; on va faire scroller tous les m‚moires vers le d‚but...
;
.d‚salloue_bloc_quelconque
 move.l d1,a2		Adresse du bloc … supprimer -> a2
 lea -12(a0),a1		Pointe dans la liste
.loop_scroll_blocs
 tst.l (a0)		Tant que l'on est pas … la fin
 bmi .fin_mfree_scroll

 move.l (a0)+,a4	Adresse du bloc	actuel -> a4
 move.l a2,(a1)+
 move.l (a0)+,d1	Longueur du bloc
 move.l d1,(a1)+
 move.l (a0)+,a5	Adresse du bloc de definition -> a5
 move.l a5,(a1)+
 move.l a2,(a5)		Note la nouvelle adresse du bloc en m‚moire

 move.l d1,d2		Adresse de d‚but du bloc courant
 addq.l #3,d2
 and.b #$fc,d2		+ longueur (corrig‚e) du bloc
 lea (a2,d2.l),a3	= adresse de d‚but du bloc suivant

;
; a4 -> source
; a2 -> dest
; d1 -> longueur du bloc
;
 move.l d1,d2		Taille … recopier
 and #15,d1		Octets restants
 beq.s .fin_d‚placement_par_octet

.d‚place_par_octet
 move.b (a4)+,(a2)+
 subq #1,d1
 bne.s .d‚place_par_octet
.fin_d‚placement_par_octet

 lsr.l #4,d2		Nombre de blocs de 16 octets
 beq.s .fin_d‚placement_par_16
.d‚place_par_16
 move.l (a4)+,(a2)+	Plus rapide que le MOVEM+LEA
 move.l (a4)+,(a2)+
 move.l (a4)+,(a2)+
 move.l (a4)+,(a2)+
 subq.l #1,d2
 bne.s .d‚place_par_16
.fin_d‚placement_par_16

 move.l a3,a2
 bra.s .loop_scroll_blocs


.fin_mfree_scroll
 move.l #-1,(a1)

.fin_mfree
 movem.l (sp)+,d1-a6
 moveq #0,d0
 rts

.error_mfree
 movem.l (sp)+,d1-a6
 moveq #-1,d0
 rts


	BSS

memoire_libre		ds.l 1
memoire_occupe		ds.l 1
taille_memoire		ds.l 1
adr_memoire		ds.l 1
adr_malloc		ds.l (max_malloc+1)*3
