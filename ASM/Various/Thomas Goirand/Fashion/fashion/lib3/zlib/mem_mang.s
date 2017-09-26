	include	gemdos.i
	include	zlib.i
;	include	util.i
	text
	XDEF	blk_tete	; Pointeur vers la tete de la liste chainee
	XDEF	xaloc_init_rout
	XDEF	xaloc_aloc_rout
	XDEF	xaloc_free_rout
	XDEF	xaloc_moveptr_rout
	XDEF	blk_nbr_ptr,blk_tbl	; permet au source tst_mem.s d'afficher des infos sur le gestionnaire de memoire
MAX_XALOC	equ	32768

********************************************************
*** Definition d'un bloc memoire de la liste chainee ***
********************************************************
	rsreset
blk_next	rs.l	1	; pointeur sur bloc suivant
blk_prec	rs.l	1	; pointeur sur bloc precedent
blk_num		rs.l	1	; "principale" pointeur sur pointeur du bloc
blk_size	rs.l	1	; taille du bloc
blk_state	rs.b	1	; etat du bloc (0 = vide, 1 = occupe)
blk_numref	rs.b	1	; Nombre de reference faite au bloc memoire autre que le pointeur principal
blk_struc_size	rs.w	1
*--------------------------------------------------------------------------------------------------------------------------*
*****************************************************
*** Permet de changer la taille d'un bloc memoire ***
*****************************************************
	XDEF	xaloc_gow_rout
xaloc_gow_rout
	movem.l	d6/d7/a2-a4/a6,-(sp)
	move.l	28+0(sp),a6	; adresse du pointeur
	move.l	28+4(sp),d7	; taille du nouveau bloc

	move.l	(a6),a3
	lea	-blk_struc_size(a3),a3

	move.l	d7,-(sp)
	move.l	#temp_grow_ptr,-(sp)
	bsr.l	xaloc_aloc_rout
	addq.l	#8,sp

	move.l	d0,a2
	move.l	d0,temp_grow_ptr

	movem.l	d1-a6,-(sp)
	lea	-blk_struc_size(a2),a2
	bsr	update_les_ptrs
	movem.l	(sp)+,d1-a6

	move.l	blk_size(a3),d6
	cmp.l	d6,d7
	bge	.le_plus_petit_des_deux
	move.l	d7,d6
.le_plus_petit_des_deux
	bloc_move	d6,(a6),a2

	clr.b	blk_numref(a3)
	move.l	a6,-(sp)
	bsr.l	xaloc_free_rout
	addq.l	#4,sp


	move.l	#temp_grow_ptr,-(sp)
	move.l	a6,-(sp)
	move.l	temp_grow_ptr,-(sp)
	bsr.l	xaloc_moveptr_rout
	lea	12(sp),sp

	bsr	xaloc_sort_ptr
	movem.l	(sp)+,d6/d7/a2-a4/a6
	rts
	bss
temp_grow_ptr	ds.l	1
	text
*--------------------------------------------------------------------------------------------------------------------------*
*********************************************************************************
*** Permet d'informer le gestionnaire de memoire qu'on a deplacer un pointeur ***
*********************************************************************************
	XDEF	xaloc_moveptr_rout
xaloc_moveptr_rout
	movem.l	a4-a6,-(sp)
	move.l	16+8(sp),a4	; ancienne adresse
	move.l	16+4(sp),a5	; nouvelle adresse
	move.l	16+0(sp),a6	; adresse pointe

	cmp.l	a4,a5
	bne	.suite_mvp
	movem.l	(sp)+,a4-a6
	rts

.suite_mvp

	move.l	a6,(a4)
	move.l	a6,(a5)

	sub.l	#blk_struc_size,a6	; et maintenant le header du bloc

* Le pointeur que l'on veut bouger est-il le pointeur principale ?
	cmp.l	blk_num(a6),a4
	bne	.pas_bloc_principal
	move.l	a5,blk_num(a6)	; si oui, on a juste a updater blk_num
	movem.l	(sp)+,a4-a6
	rts
.pas_bloc_principal

* Si non, il faut effacer un pointeur, puis en ajouter 1
* Note : optimisable en faisant une recherche (ou est le pointeur dans la table)
* puis en updatant la valeur directement
	move.l	a4,-(sp)
	bsr	xaloc_supptr_rout
	addq.l	#4,sp
	move.l	a5,-(sp)
	bsr	xaloc_addptr_rout
	addq.l	#4,sp
	movem.l	(sp)+,a4-a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
********************************************************************************
*** Dit si un pointeur est principale ou non (0 = secondaire, 1 = principale ***
********************************************************************************
	XDEF	xaloc_is_main_rout
xaloc_is_main_rout
	move.l	a6,-(sp)
	move.l	a5,-(sp)
	move.l	12(sp),a6
	move.l	(a6),a5
	cmp.l	blk_num-blk_struc_size(a5),a6
	beq.s	ouaip_principale
	moveq.l	#0,d0
	move.l	(sp)+,a5
	move.l	(sp)+,a6
	rts
ouaip_principale
	moveq.l	#1,d0
	move.l	(sp)+,a5
	move.l	(sp)+,a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
*******************************************************
*** Routine de fusion de deux bloc libre consecutif ***
*******************************************************
xaloc_fusion	macro	; bloc1,bloc2
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	bsr	xaloc_fusion_rout
	addq.l	#8,sp
	endm

xaloc_fusion_rout
	movem.l	d0/a4/a5/a6,-(sp)
	move.l	20+4(sp),a5
	move.l	20+0(sp),a6

	cmp.l	blk_lastblok,a6
	bne	.not_last

	move.l	a5,blk_lastblok

.not_last
	move.l	blk_next(a6),blk_next(a5)

	move.l	#blk_struc_size,d0
	add.l	blk_size(a6),d0
	add.l	d0,blk_size(a5)

	move.l	blk_next(a6),a4
	tst.l	a4
	beq	fin_liste_chaine
	move.l	a5,blk_prec(a4)
fin_liste_chaine
	movem.l	(sp)+,d0/a4/a5/a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
***********************************************************
*** Routine d'initialisation du gestionnaire de memoire ***
***********************************************************
xaloc_init_rout
	movem.l	d1-a6,-(sp)
	move.l	60+4(sp),blk_suplem_size
	move.l	60(sp),d7

;* Reservation d'un bloc principale de la taille demande en parametre
	move.l	d7,d6
	add.l	#blk_struc_size,d6

	Malloc	d6
	move.l	d0,a0
;* Initialisation des variables globales du gestionnaire de memoire
	move.l	d7,free_mem
	move.l	d0,blk_tete
	move.l	d0,blk_lastblok
	move.l	#1,blk_free_nbr
	clr.l	blk_occup_nbr

;* Initialisation du bloc vide principale (liste chaine)
	clr.l	blk_next(a0)
	clr.l	blk_prec(a0)
	move.l	d7,blk_size(a0)
	clr.w	blk_state(a0)

;* Effacement du tableau de bloc vide
	move.l	#0,blk_nbr_ptr
	movem.l	(sp)+,d1-a6
	rts

*--------------------------------------------------------------------------------------------------------------------------*
************************************************
*** Routine de reservation d'un bloc memoire ***
************************************************
xaloc_aloc_rout
	movem.l	d1-a6,-(sp)
	move.l	60+4(sp),d7	; taille du bloc
	move.l	60(sp),a6	; adresse du pointeur vers le bloc a reserver (app_ptr)
	add.l	#1,d7
	and.l	#-2,d7		; taille arrondi a 2 par exes

	cmp.l	blk_suplem_size,d7
	blt	xaloc_start_search

	illegal

xaloc_start_search
	move.l	d7,d6
	add.l	#blk_struc_size,d6	; on recherche un bloc de taille d6 !

	move.l	blk_lastblok,a5
	tst.b	blk_state(a5)
	bne	recherche_encore
	cmp.l	blk_size(a5),d6
	ble	bloc_libre_trouve

recherche_encore
;* Reste-t-il de la ram dans le gestionnaire ***
	cmp.l	free_mem,d6
	blt	xaloc_recherche_blk_vide
	bra	plus_de_ram_libre
	clr.l	d0		; le gestionnaire pour qu'il reserve un nouveau gros block
	movem.l	(sp)+,d1-a6
	rts
xaloc_recherche_blk_vide
	move.l	blk_tete,a5

	tst.b	blk_state(a5)	; le bloc est-il vide ?
	bne	go_suivant
	cmp.l	blk_size(a5),d6	; le bloc est-il de la bonne taille ?
	bgt	go_suivant

	bra	bloc_libre_trouve

go_suivant
	cmp.w	#-1,a5
	bne	.suite
	illegal
.suite
	move.l	blk_next(a5),a5
	tst.l	blk_next(a5)
	beq	grabage_colection
	move.l	blk_next(a5),a5

	tst.b	blk_state(a5)	; bloc vide ?
	bne	go_suivant
	cmp.l	blk_size(a5),d6	; bonne taille ?
	bgt	go_suivant

bloc_libre_trouve
	move.l	a5,a4	; calcul de l'adr du nouveau bloc libre
	add.l	d6,a4	; en fin du bloc que l'on reserve

;	move.l	blk_size(a5),d0							; !!!
;	sub.l	#blk_struc_size,d0						; !!!
;	cmp.l	d0,d6	; assez grand pour fabriquer un nouveau bloc vide ?	; !!!
;	bgt	pas_de_nouveau_bloc						; !!!

;*Update du bloc libre suivant le bloc aloue
	cmp.l	blk_lastblok,a5
	bne	.not_last
	move.l	a4,blk_lastblok

.not_last
	clr.b	blk_state(a4)
	move.l	blk_next(a5),a0
	move.l	a0,blk_next(a4)
	move.l	a5,blk_prec(a4)

	move.l	blk_size(a5),blk_size(a4)
	sub.l	d6,blk_size(a4)			; taille du nouveau bloc libre


	tst.l	a0
	beq	pas_de_bloc_suivant

	move.l	a4,blk_prec(a0)

pas_de_bloc_suivant
;* On initialise le bloc occupe
	move.l	a4,blk_next(a5)
	move.l	d7,blk_size(a5)
;pas_de_nouveau_bloc								; !!!
	move.b	#1,blk_state(a5)
	clr.b	blk_numref(a5)	; Pas encore de reference a une partie de ce block

	move.l	a6,blk_num(a5)	; placement de l'adr du pointeur de l'app dans la structure
				; ce qui permet de le modifier si un block est deplace
	sub.l	d7,free_mem
	add.l	#1,blk_occup_nbr

	move.l	a5,d0
	add.l	#blk_struc_size,d0

;	move.l	d0,d1
;	sub.l	blk_tete,d1
;	sub.l	#2000000,d1	; permet de verifier si on sort une mauvaise adresse
;	bmi.s	.OK0
;	illegal
;.OK0

	movem.l	(sp)+,d1-a6

	rts

******************************************************************************************************
* Ici, la memoire est trop fragmente : on la defragment jusqu'a trouver un bloc de taille suffisante *
******************************************************************************************************
* Des qu'on deplace un bloc en memoire, il faut updater les pointeurs vers les adresse de ce bloc.   *
* Les adresses des pointeurs vers ce bloc sont contenues dans le tableau blk_tbl range par ordre     *
* d'adresse vers le gros bloc                                                                        *
******************************************************************************************************
grabage_colection		; Note : j'ai apeler ca grabage au lieu de garbage... amusant non ?
	move.l	blk_tete,a2

;* On recherche le premier bloc vide
boucle_recherche_vide
	tst.b	blk_state(a2)
	beq	bloc_vide_trouve
	move.l	blk_next(a2),a2
	tst.l	a2
	beq	plus_de_ram_libre

	bra	boucle_recherche_vide

;* On teste si les bloc sont consecutifs
bloc_vide_trouve
	move.l	blk_next(a2),a3
	tst.l	a3
	beq	plus_de_ram_libre
	move.l	blk_size(a2),d0
	add.l	a2,d0
	add.l	#blk_struc_size,d0
	cmp.l	d0,a3
	beq	bloc_suivant_consecutif

	move.l	a3,a2
	bra	boucle_recherche_vide
bloc_suivant_consecutif
;* On sauve les infos qu'on a besoin de conserver avant le deplacement
	move.l	blk_size(a2),d5
	move.l	blk_next(a3),d4

	bsr	update_les_ptrs

***************************************************************************************************************************
;* On deplace le bloc suivant (occupe) dans le bloc vide courant
* On commence par updater le pointeur "principal"
	move.l	a3,d0
	sub.l	a2,d0
	move.l	blk_num(a3),a0
	sub.l	d0,(a0)

	move.l	blk_num(a3),blk_num(a2)

	move.l	blk_size(a3),d3
	move.l	a2,d1
	move.l	a3,d2
	add.l	#blk_struc_size,d1
	add.l	#blk_struc_size,d2
	bloc_move	d3,d2,d1	; realise grace a une macro de Sacha

;* On update les infos des deux blocs
	move.l	a2,a4
	add.l	d3,a4
	add.l	#blk_struc_size,a4	; calcul de l'adresse du bloc suivant (le vide maintenant)

	;* Bloc vide (suivant)
	move.l	a2,blk_prec(a4)		; update des infos de celui-ci
	move.l	d4,blk_next(a4)
	clr.b	blk_state(a4)
	move.l	d5,blk_size(a4)

	;* Bloc occupe (courant)
	move.l	a4,blk_next(a2)
	move.l	d3,blk_size(a2)
	move.b	#1,blk_state(a2)

;* Maintenant, il faut verifier qu'on a pas deux bloc consecutif fusionnable (vide)
	move.l	a4,a2	; le suivant devient courant
	move.l	blk_next(a4),a4		; nouveau bloc suivant vide ?
	tst.l	a4
	beq	plus_de_ram_libre
	tst.b	blk_state(a4)
	bne	boucle_recherche_vide

	move.l	a2,d0
	add.l	blk_size(a2),d0
	add.l	#blk_struc_size,d0
	cmp.l	d0,a4
	bne	boucle_recherche_vide

	xaloc_fusion	a2,a4

	cmp.l	blk_size(a2),d7
	bgt	boucle_recherche_vide

	move.l	a2,a5

	bra	bloc_libre_trouve

;* Ici, il n'y a plus de memoire disponible : on doit faire un nouveau gros malloc et le chainer
plus_de_ram_libre

	move.l	blk_suplem_size,d6
	Malloc	d6
	move.l	d0,a5

	move.l	blk_lastblok,a6
	move.l	a5,blk_next(a6)

	move.l	a6,blk_prec(a5)
	clr.l	blk_next(a5)
	clr.l	blk_num(a5)
	move.l	d6,d0
	sub.l	#blk_struc_size,d0
	move.l	d0,blk_size(a5)
	clr.b	blk_state
	clr.b	blk_numref
	add.l	d0,free_mem
	add.l	#1,blk_free_nbr

	move.l	a6,a4
	add.l	#blk_struc_size,a4
	add.l	blk_size(a6),a4
	cmp.l	d0,a4
	bne	no_fusion

	xaloc_fusion	a6,a5
	bra	xaloc_start_search

no_fusion
	move.l	a5,blk_lastblok

	bra	xaloc_start_search

****************************************************************************************************************************
;* Puisque le bloc vat se deplacer, il faut updater les pointeurs sur des zones memoires dans ce bloc avant de deplacer
; bloc pointe par a3 a deplacer a l'adresse pointe par a2
; Libre : d0-d3,a0-a1

update_les_ptrs
	tst.b	blk_numref(a3)	; Y a-t-il des pointeur vers le bloc pointe par a3 ?
	beq	ok_cest_update

	move.l	a3,d0		; Adresse de debut de bloc : a3
	add.l	blk_size(a3),d0	; adresse de fin : d0
	add.l	#blk_struc_size,d0
* Recherche dicotomique de l'adresse du 1er pointeur vers le bloc a deplacer
	lea	blk_tbl,a0
	move.l	blk_nbr_ptr,d3	; borne sup
	cmp.l	#1,d3
	beq	un_seul_pointeur
	subq.l	#1,d3
	moveq.l	#0,d2		; borne inf

loop_cherche_ptr
	move.l	d3,d1
	sub.l	d2,d1
	cmp.l	#1,d1
	ble	end_cherche_ptr

	lsr.l	#1,d1		; mileu de la zone entre d2 et d3 (d1 = (d2+d3) /2)
	add.l	d2,d1

	move.l	(a0,d1.l*4),a1	; on prend le pointeur vers pointeur
	cmp.l	(a1),a3
	bgt	trop_bas

	cmp.l	(a1),d0
	blt	trop_haut
	bra	trouved		; Si c'est ni trop bas, ni trop haut, alors c'est trouv‚ !
trop_bas
	move.l	d1,d2
	bra	loop_cherche_ptr
trop_haut
	move.l	d1,d3
	bra	loop_cherche_ptr
un_seul_pointeur
	clr.l	d2
	clr.l	d3
end_cherche_ptr
	move.l	(a0,d2.l*4),a1	; on prend le pointeur vers pointeur
	move.l	d2,d1
	cmp.l	(a1),a3
	ble	trouved

	move.l	(a0,d3.l*4),a1	; on prend le pointeur vers pointeur
	move.l	d3,d1
	cmp.l	(a1),d0
	bgt	trouved
	illegal		; Erreur interne puisqu'on a pas trouv‚ de pointeur alors que num_ref en indique un !
* On a trouve une adresse contenant un pointeur vers le bloc que l'on veut deplacer
* il faut verifier si une autre adresse n'est pas declarer avant dans le tableau
trouved
	tst.l	d1
	beq	trouved_first	; cas ou on est deja en debut de tableau. C'est donc forcement le 1er pointeur de la serie
	subq.l	#1,d1
	move.l	(a0,d1.l*4),a1
	cmp.l	(a1),a3
	ble	trouved

	add.l	#1,d1
* On a trouver le premier pointeur, il faut maintenant iterer jusqu'a avoir tout updater
trouved_first
	moveq.l	#0,d2
	move.b	blk_numref(a3),d2	; Nombre de pointeur a updater (normalement, ils sont consecutifs, puisque le tableau est trie)
	subq.l	#1,d2
	move.l	a3,d0			; calcul de la taille du deplacement
	sub.l	a2,d0
loop_update
	move.l	(a0,d1.l*4),a1
	sub.l	d0,(a1)
	addq.l	#1,d1
	dbf	d2,loop_update
***************************************************************************************************************************
ok_cest_update
* Derniere operation avant deplacement, il faut verifier que aucun
* pointeur n'est contenu dans le bloc que l'on veut deplacer
; Libre : d0-d3,a0-a1
	move.l	blk_nbr_ptr,d3
	beq	end_ptrupdate		; cas ou il n'y a pas de pointeurs

	lea	blk_tbl,a0
	move.l	a3,d0			; adresse mini ds a3
	add.l	blk_size(a3),d0
	add.l	#blk_struc_size,d0	; adresse maxi ds d0
	move.l	a3,d1
	sub.l	a2,d1			; taille du deplacement

* On ne peut pas faire de recherche dicotomique, le tableau est idexe sur
* autre chose que l'adresse ou est le pointeur (sur l'adresse contenue par ce pointeur)
* Il faut donc faire une recherche dans TOUT le tableau
leptr_suivant
	cmp.l	(a0),a3		; si le pointeur est localise entre l'adresse mini du bloc...
	bgt	.suite
	cmp.l	(a0),d0		; ... et l'adresse maxi, alors...
	blt	.suite
	sub.l	d1,(a0)		; ... on update son adresse dans le tableau
.suite
	addq.l	#4,a0
	subq.l	#1,d3
	bne	leptr_suivant

end_ptrupdate
	rts
*--------------------------------------------------------------------------------------------------------------------------*
********************************************************
*** Fonction de MFREE (desalouage d'un bloc memoire) ***
********************************************************
* Parametre : pointeur vers le 1er octet util du bloc a effacer
xaloc_free_rout
	movem.l	d1-a6,-(sp)
	move.l	60(sp),a5
	move.l	(a5),a5
	move.l	a5,a1
	sub.l	#blk_struc_size,a5

	tst.b	blk_numref(a5)		; Plusieurs pointeurs ?
	beq	suite_free_rout
		*---------------------------*

	move.l	a5,-(sp)
	bsr	trouve_ptr_index	; Si oui, un pointeur sur le 1er octet doit exister
	addq.l	#4,sp			; on cherche donc le 1er qui nous tombe sous la main dans le tableau

	lea	blk_tbl,a4
	move.l	(a4,d0.l*4),a0
	cmp.l	(a0),a1
	bne	.error

	move.l	a0,blk_num(a5)		; On le place donc en temps que pointeur "principal"

* Et on suprime le pointeur du tableau
	move.l	blk_nbr_ptr,d2
	sub.l	d0,d2
	move.l	d0,d1
	addq.l	#4,d1
.loop
	move.l	(a4,d1.l*4),(a4,d0.l*4)
	addq.l	#1,d0
	addq.l	#1,d1
	subq.l	#1,d2
	bne	.loop

	sub.b	#1,blk_numref(a5)
	sub.l	#1,blk_nbr_ptr

	movem.l	(sp)+,d1-a6
	rts

.error
	illegal
	dc.b	"On a pas repecter la precondition, a savoir le parametre"
	dc.b	"est un pointeur vers le 1er octet d'un bloc",0
	even
		*---------------------------*
suite_free_rout
	move.l	blk_size(a5),d0
	add.l	d0,free_mem
	clr.b	blk_state(a5)

	add.l	#1,blk_free_nbr		; les variables du mem_mangager
	sub.l	#1,blk_occup_nbr

;* Update du bloc precedent avec eventuellement fusion
	move.l	blk_prec(a5),a4	; adr du bloc precedent
	tst.l	a4
	beq	pas_de_precedent
	tst.b	blk_state(a4)
	bne	pas_de_precedent
	move.l	a4,d0
	add.l	#blk_struc_size,d0
	add.l	blk_size(a4),d0
	cmp.l	d0,a5
	bne	pas_de_precedent

	add.l	#blk_struc_size,free_mem
	sub.l	#1,blk_free_nbr
	xaloc_fusion	a4,a5
	move.l	a4,a5

pas_de_precedent
;* Update du bloc suivant avec eventuellement fusion
	move.l	blk_next(a5),a0		; adr du bloc precedent
	tst.l	a0
	beq	pas_de_suivant
	tst.b	blk_state(a0)
	bne	pas_de_suivant
	move.l	a5,d0
	add.l	#blk_struc_size,d0
	add.l	blk_size(a5),d0
	cmp.l	d0,a0
	bne	pas_de_suivant

	add.l		#blk_struc_size,free_mem
	sub.l		#1,blk_free_nbr
	xaloc_fusion	a5,a0

pas_de_suivant
	movem.l	(sp)+,d1-a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
*********************************************************************************************************
*** Fonction permettant l'enregistrement d'un nouveau pointeur vers une adresse apartenant a un bloc. ***
*** Si le bloc est deplacer, le pointeur vers ce bloc est automatiquement updater.                    ***
*** Pour ameliorer le rendement, on utilise un trie par insertion.                                    ***
*********************************************************************************************************
* Parametres : adresse du pointeur vers le bloc, ce pointeur etant rempli avec la bonne adresse
	XDEF	xaloc_addptr_rout
xaloc_addptr_rout
	movem.l	d5-d7/a5-a6,-(sp)
	move.l	24(sp),a6

* Cas particulier de 0 ou 1 pointeur dans le tableau
	move.l	blk_nbr_ptr,d0
	beq	.suite
	cmp.l	#1,d0
	bne	.suite2
	subq.l	#1,d0
	bra	.suite3

.suite2
* Cas general
	move.l	(a6),-(sp)
	bsr	trouve_ptr_index	; Trouve l'index le plus approchant...
	addq.l	#4,sp

.suite3
	lea	blk_tbl,a5
	move.l	(a5,d0.l*4),a0		; On place notre nouveau pointeur avant ou apres ?
	move.l	(a0),a1
	cmp.l	(a6),a1
	bge	.suite
	addq.l	#1,d0
.suite
***************************************************************************
* L'index a partir duquel il faut placer le pointeur est maintenant dans d0
* on procede alors a une insertion a l'index d0 dans le tableau blk_tbl[]
	lea	blk_tbl,a5
	move.l	blk_nbr_ptr,d7
	lea	(a5,d0.l*4),a5
	move.l	(a5),d6
	move.l	a6,(a5)+
	sub.l	d0,d7
	ble	endinsertloop
loop_insert
	move.l	(a5),d5
	move.l	d6,(a5)+
	move.l	d5,d6
	subq.l	#1,d7
	bne	loop_insert

endinsertloop
	add.l	#1,blk_nbr_ptr

* Maintenant on recherche le bloc pointe par (a6) et on incremente sont nombre de pointeur
	move.l	(a6),-(sp)
	bsr	search_blk_ptr
	addq.l	#4,sp

	move.l	d0,a5
	add.b	#1,blk_numref(a5)
	movem.l	(sp)+,d5-d7/a5-a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
*********************************************************************************************
*** Fonction permettant de supprimer un pointeur vers une adresse dans un bloc en memoire ***
*********************************************************************************************
	XDEF	xaloc_supptr_rout
xaloc_supptr_rout
	movem.l	d7/a5-a6,-(sp)
	move.l	16(sp),a6

	move.l	(a6),-(sp)
	bsr	trouve_ptr_index
	addq.l	#4,sp

	lea	blk_tbl,a5
	move.l	blk_nbr_ptr,d7
	move.l	d0,d1
	sub.l	d0,d7		; nombre d'objet apres notre pointeur a enlever
	add.l	#1,d1
supptr_loop
	move.l	(a5,d1.l*4),(a5,d0.l*4)
	add.l	#1,d0
	add.l	#1,d1
	subq.l	#1,d7
	bne	supptr_loop

	move.l	(a6),-(sp)
	bsr	search_blk_ptr
	addq.l	#4,sp
	move.l	d0,a6
	sub.l	#1,blk_numref(a6)

	sub.l	#1,blk_nbr_ptr

	movem.l	(sp)+,d7/a5-a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
**************************************************************************
*** Fonction permettant de trouver le bloc correspondant a un pointeur ***
**************************************************************************
* Parametre : adresse vers lequel on pointe
search_blk_ptr
	movem.l	d7/a5-a6,-(sp)
	move.l	16(sp),a6

	move.l	blk_tete,a5
loop_add_ptr_num
	tst.l	a5
	beq	err_interne

	tst.b	blk_state(a5)
	beq	bloc_suivant
	move.l	a5,d7
	add.l	#blk_struc_size,d7
	add.l	blk_size(a5),d7
	cmp.l	a6,d7
	blt	bloc_suivant

	move.l	a5,d0
	movem.l	(sp)+,d7/a5-a6
	rts

bloc_suivant
	move.l	blk_next(a5),a5
	bra	loop_add_ptr_num

err_interne		; on nous demande de rajouter un pointeur vers un bloc qui n'existe pas !
	illegal
*--------------------------------------------------------------------------------------------------------------------------*
*********************************************************************
*** Recherche dicotomique d'un pointeur dans la table de pointeur ***
*********************************************************************
* Parametre d'entree : adresse point‚e
*             retour : index dans le tableau ou devrai se trouver le pointeur
trouve_ptr_index
	movem.l	d5-d7/a5-a6,-(sp)
	move.l	24(sp),a6	; adresse vers lequel le pointeur pointe...
	lea	blk_tbl,a5
	move.l	blk_nbr_ptr,d7	; borne sup
	beq	no_pointeur
	cmp.w	#1,d7
	beq	one_only_pointeur
	subq.l	#1,d7
	moveq.l	#0,d6		; borne inf

loop_search_index
	move.l	d7,d5
	sub.l	d6,d5
	cmp.l	#1,d5
	ble	end_search_index

	lsr.l	#1,d5		; mileu de la zone entre d6 et d7 (d5 = (d6+d7) /2)
	add.l	d6,d5

	move.l	(a5,d5.l*4),a0
	cmp.l	(a0),a6
	bgt	is_trop_bas
	bne	.suite
	move.l	d6,d0
	movem.l	(sp)+,d5-d7/a5-a6
.suite
	move.l	(a5,d7.l*4),a0	; on prend le pointeur vers pointeur
	cmp.l	(a0),a6
	blt	is_trop_haut
	move.l	d7,d0
	movem.l	(sp)+,d5-d7/a5-a6
	rts			; Si le pointeur est entre d6 et d7, ou avec la meme adresse que d6
				; alors on doit le placer a partir de d7
is_trop_bas
	move.l	d5,d6
	bra	loop_search_index
is_trop_haut
	move.l	d5,d7
	bra	loop_search_index

end_search_index
	move.l	(a5,d6.l*4),a0	; on prend le pointeur vers pointeur
	cmp.l	(a0),a6
	bgt	.suite1
	move.l	d6,d0
	movem.l	(sp)+,d5-d7/a5-a6
	rts
.suite1
	move.l	d7,d0
	movem.l	(sp)+,d5-d7/a5-a6
	rts

* Il n'existe pas encore de pointeur sur pointeur dans la table
no_pointeur
	moveq.l	#0,d0
	movem.l	(sp)+,d5-d7/a5-a6
	rts

* La table ne compte qu'un seul pointeur sur pointeur
one_only_pointeur	; si un seul pointeur, on regarde si celui a placer est avant ou apres
	cmp.l	(a5),a6
	bgt	.suite1
	moveq.l	#0,d0
	movem.l	(sp)+,d5-d7/a5-a6
	rts
.suite1	moveq.l	#1,d0
	movem.l	(sp)+,d5-d7/a5-a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
***************************************************************
*** Permet de retrier les pointeur si on a deplacer un bloc ***
***************************************************************
xaloc_sort_ptr
	movem.l	d0/d1/d5-d7/a0/a1/a4-a6,-(sp)
	move.l	blk_nbr_ptr,d7
	beq	.pas_besoin
	subq.l	#1,d7		; nombre d'iteration dans la boucle
	beq	.pas_besoin
	lea	blk_tbl,a6

.lp_tribul
	move.l	d7,d6
	move.l	a6,a5
	lea	4(a6),a4
	moveq.l	#1,d5

.tribul_lp
	move.l	(a5),a0
	move.l	(a4),a1
	move.l	(a0),d0
	move.l	(a1),d1
	cmp.l	d0,d1
	bge	.ok

	moveq.l	#0,d5
	move.l	a0,(a4)
	move.l	a1,(a5)

.ok
	addq.l	#4,a4
	addq.l	#4,a5

	subq.l	#1,d6
	bne	.tribul_lp

	tst.l	d5
	bne	.pas_besoin

	subq.l	#1,d7
	bne	.lp_tribul

.pas_besoin
	movem.l	(sp)+,d0/d1/d5-d7/a0/a1/a4-a6
	rts

****************************************************************************************************************************
	bss
temp_entete	ds.b	blk_struc_size
free_mem	ds.l	1	; Taille memoire restant dans le gestionnaire
blk_free_nbr	ds.l	1	; Nombre de bloc libre
blk_occup_nbr	ds.l	1	; Nombre de bloc occupe
blk_tete	ds.l	1	; Pointeur vers le premier block
blk_lastblok	ds.l	1	; Pointeur vers le dernier block du gestionnaire
blk_nbr_ptr	ds.l	1	; Nombre de pointeur vers une adresse du gros bloc contenu dans le tableau blk_tbl
blk_tbl		ds.l	MAX_XALOC
blk_suplem_size	ds.l	1	; taille des bloc a ajoute quand plus de memoire
	text
