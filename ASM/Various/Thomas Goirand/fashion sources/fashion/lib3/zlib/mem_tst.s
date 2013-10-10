*****************************************************************
*** Programme permettant de tester le gestionnaire de memoire ***
*****************************************************************
*** Quick & dirty test rullez ! ***
***********************************
	include	zlib.i
	include	util.i
	include	gemdos.i

* Pointeur sur la tete de la liste chaine
	XREF	blk_tete	; Pointeur vers le debut de la liste chainee de block memoire
* Quelques variables importes du gestionnaire de memoire
	XREF	blk_tbl		; la table de pointeur sur pointeur
	XREF	blk_nbr_ptr	; Nombre de pointeur dans cette table
******************************************************************************************************************
*** !!!!!!!!!!! Attention ! La structure suivante existe aussi dans MEM_MANG.S, verifier qu'elle corresponde ! ***
******************************************************************************************************************
	rsreset
blk_next	rs.l	1	; pointeur sur bloc suivant
blk_prec	rs.l	1	; pointeur sur bloc precedent
blk_num		rs.l	1
blk_size	rs.l	1	; taille du bloc
blk_state	rs.b	1	; etat du bloc (0 = vide, 1 = occupe)
blk_numref	rs.b	1	; Nombre de reference faite au bloc memoire autre que le pointeur principal
blk_struc_size	rs.w	1

***************************************
* On demande la taille du gros malloc *
***************************************
	XDEF	xaloc_debug_rout
xaloc_debug_rout
	cconws		#intro
	clr_zone	#input,#16
	cconrs		#input2
	chaine_2_long	#input
	xaloc_init	#512*1024,d0

*********************************
* Puis on rentre dans la boucle *
*********************************
do_a_small_boucle
	cconws	#txt_menu

	cconin

	cmp.b	#"1",d0
	beq	do_a_small_malloc
	cmp.b	#"2",d0
	beq	do_a_small_mfree
	cmp.b	#"3",d0
	beq	do_a_small_print
	cmp.b	#"4",d0
	beq	do_a_small_addptr
	cmp.b	#"5",d0
	beq	do_a_small_supptr
	cmp.b	#"6",d0
	beq	do_a_small_grow
	cmp.b	#"7",d0
	beq	do_a_small_quit
	bra	do_a_small_boucle
******************************
* Change la taille d'un bloc *
******************************
do_a_small_grow
	cconws	#intro_mfree
* Boucle d'affichage !
	lea	mlptr_tbl,a6
	move.l	startml_ptr,d7
	beq	end_print_grow
	moveq.l	#0,d6
lp_print_grow
	clr_zone	#decimal_to_print,#10
	long_2_chaine	d6,#decimal_to_print,#3		; affichage du numero
	cconws		#decimal_to_print
	cconws		#tab_to_print			; d'une tabulation
	long_2_chaine	(a6)+,#decimal_to_print,#9	; de l'adresse point‚e
	cconws		#decimal_to_print
	cconws		#cr_to_print			; d'un CR,LF
	addq.l		#1,d6
	subq.l		#1,d7
	bne		lp_print_grow

	cconws		#demande_grow			; d'une chaine de demande
	clr_zone	#input,#16
	cconrs		#input2
	chaine_2_long	#input

	lea		mlptr_tbl,a6
	lea		(a6,d0.l*4),a6

	cconws		#demande_size_g			; d'une chaine de demande
	clr_zone	#input,#16
	cconrs		#input2
	chaine_2_long	#input

	xaloc_grow	d0,a6

end_print_grow
	bra		do_a_small_boucle

	data
demande_grow	dc.b	10,13,"Numero bloc : ",0		; d'une chaine de demande
demande_size_g	dc.b	10,13,"Taille du bloc : ",0
	text
*************************
* On ajoute un pointeur *
*************************
do_a_small_addptr
	clr_zone	#input,#16
	cconws		#chaine_addptr
	cconrs		#input2
	chaine_2_long	#input
	lea		ptr_tbl,a6
	move.l		nbptr_tbl,d7
	lea		(a6,d7.l*4),a6
	add.l		#1,nbptr_tbl
	move.l		d0,(a6)
	xaloc_addptr	a6
	bra	do_a_small_boucle
	data
chaine_addptr	dc.b	10,13,"Adresse vers laquel on doit pointer : ",0
	text
*************************
* On efface un pointeur *
*************************
do_a_small_supptr
	cconws		#chaine_supptr
	move.l		nbptr_tbl,d7
	beq		do_a_small_boucle
	moveq.l		#0,d6
	lea		ptr_tbl,a6
loop_supptr
	clr_zone	#decimal_to_print,#4
	long_2_chaine	d6,#decimal_to_print,#3		; affichage du numero
	cconws		#decimal_to_print
	cconws		#tab_to_print
	clr_zone	#decimal_to_print,#10
	long_2_chaine	(a6)+,#decimal_to_print,#9	; affichage de l'adresse pointe
	cconws		#decimal_to_print
	cconws		#cr_to_print
	addq.l		#1,d6
	subq.l		#1,d7
	bne		loop_supptr

	cconws		#chaine2_supptr
	clr_zone	#input,#16
	cconrs		#input2
	chaine_2_long	#input
	lea		ptr_tbl,a6
	lea		(a6,d0.l*4),a6
	xaloc_supptr	a6
	move.l		#0,(a6)
	bra	do_a_small_boucle
	data
chaine_supptr	dc.b	10,13,"Numero",9,"Adresse pointe",10,13,0
	even
chaine2_supptr	dc.b	10,13,"Numero du pointeur a deplacer : ",0
	even
nbptr_tbl	dc.l	0	; Nombre de pointeur actuellement dans la table
	bss
ptr_tbl		ds.l	64	; Quelques pointeur pour faire une simulation
	text
*********************
* On fait un malloc *
*********************
do_a_small_malloc
	clr_zone	#input,#16

	cconws		#demande_malloc
	cconrs		#input2
	chaine_2_long	#input
	lea		mlptr_tbl,a6
	move.l		startml_ptr,d1
	lea		(a6,d1.l*4),a6
	xaloc_aloc	d0,a6
	move.l		d0,(a6)

	add.l		#1,startml_ptr
	bra		do_a_small_boucle

********************
* On fait un mfree *
********************
do_a_small_mfree
	cconws	#intro_mfree
* Boucle d'affichage !
	lea	mlptr_tbl,a6
	move.l	startml_ptr,d7
	beq	end_print_mfree
	moveq.l	#0,d6
loop_print_mfree
	clr_zone	#decimal_to_print,#10
	long_2_chaine	d6,#decimal_to_print,#3		; affichage du numero
	cconws		#decimal_to_print
	cconws		#tab_to_print			; d'une tabulation
	long_2_chaine	(a6)+,#decimal_to_print,#9	; de l'adresse point‚e
	cconws		#decimal_to_print
	cconws		#cr_to_print			; d'un CR,LF
	addq.l		#1,d6
	subq.l		#1,d7
	bne		loop_print_mfree
end_print_mfree

	cconws		#demande_mfree			; d'une chaine de demande
	clr_zone	#input,#16
	cconrs		#input2
	chaine_2_long	#input

	lea		mlptr_tbl,a6
	lea		(a6,d0.l*4),a6
	xaloc_free	a6

	bra	do_a_small_boucle
	data
intro_mfree	dc.b	10,13,"Pointeurs d'allocation : ",10,13,0
demande_mfree	dc.b	10,13,"Numero du bloc a d‚salouer : ",0
	text
*****************************************
* On affiche la liste chainee et les    *
* pointeurs du gestionnnaire de memoire *
*****************************************
do_a_small_print
;	XREF	xaloc_print_mem
	bsr.l	xaloc_print_mem
	bra	do_a_small_boucle
**********
* Quitte *
**********
do_a_small_quit
	clr.w	-(sp)
	trap	#1
***************************
* Fin des options du menu *
***************************
	bss
mlptr_tbl	ds.l	64

	data
startml_ptr	dc.l	0
demande_malloc	dc.b	10,13,"Taille du Malloc : ",0
intro	dc.b	27,"ETaille du gros Malloc : ",0
	data
input2	dc.b	15	; Nombre de caractere maxi a entre lors de l'apel de cconrs
	dc.b	0	; Nombre de caractere frappe au clavier
input	ds.b	16
	data
txt_menu
	dc.b	10,13
	dc.b	"***********************",10,13
	dc.b	"*** GESTION MEMOIRE ***",10,13
	dc.b	"***********************",10,13
	dc.b	"*** 1 - Malloc      ***",10,13
	dc.b	"*** 2 - Mfree       ***",10,13
	dc.b	"*** 3 - Affichage   ***",10,13
	dc.b	"*** 4 - Ajout ptr   ***",10,13
	dc.b	"*** 5 - Supr ptr    ***",10,13
	dc.b	"*** 6 - Grow        ***",10,13
	dc.b	"*** 7 - Quitter     ***",10,13
	dc.b	"***********************",10,13,0
	bss
	text

****************************************************************************************************************************
	XDEF	xaloc_print_mem
xaloc_print_mem
	movem.l	d1-a6,-(sp)
	move.l	blk_tete,a6

	cconws	#to_print

boucle_daffichage_mem
;* Print de l'adresse du debut de la zone utilisable
	move.l		a6,d5
	add.l		#blk_struc_size,d5
	clr_zone	#decimal_to_print,#10
	long_2_chaine	d5,#decimal_to_print,#9
	cconws	#decimal_to_print
	cconws	#tab_to_print

;* De la taille
	move.l		blk_size(a6),d5
	clr_zone	#decimal_to_print,#10
	long_2_chaine	d5,#decimal_to_print,#9
	cconws		#decimal_to_print
	cconws		#tab_to_print

;* De son adresse de pointeur principal
	move.l		blk_num(a6),d5
	clr_zone	#decimal_to_print,#10
	long_2_chaine	d5,#decimal_to_print,#9
	cconws		#decimal_to_print
	cconws		#tab_to_print

;* De l'adresse que pointe le pointeur pointe par le pointeur principal (normalement le debut du bloc)
	tst.b		blk_state(a6)
	beq		no_ptr_on_ptr
	move.l		blk_num(a6),a0
	move.l		(a0),d5
	clr_zone	#decimal_to_print,#10
	long_2_chaine	d5,#decimal_to_print,#9
	cconws		#decimal_to_print
	clr_zone	#decimal_to_print,#10
	cconws		#tab_to_print
	bra		yes_ptr_on_ptr
no_ptr_on_ptr
	cconws		#tab_to_print
	cconws		#tab_to_print
yes_ptr_on_ptr

;* De son etat
	tst.b	blk_state(a6)
	beq	libre_bloc

	cconws	#occupe_to_print
	bra	ok_occupe
libre_bloc
	cconws	#libre_to_print
ok_occupe
	move.l	blk_next(a6),a6
	tst.l	a6
	bne	boucle_daffichage_mem
****************************************************
*** Maintenant on affiche le tableau de pointeur ***
****************************************************
	cconws	#to_print2
	lea	blk_tbl,a6
	move.l	blk_nbr_ptr,d7
	beq	end_aff_ptr
boucle_aff_ptr
	move.l		(a6)+,a5
	clr_zone	#decimal_to_print,#10
	long_2_chaine	a5,#decimal_to_print,#9
	cconws		#decimal_to_print
	cconws		#tab_to_print
	cconws		#tab_to_print
	clr_zone	#decimal_to_print,#10
	long_2_chaine	(a5),#decimal_to_print,#9
	cconws		#decimal_to_print
	cconws		#cr_to_print
	subq.l	#1,d7
	bne	boucle_aff_ptr

end_aff_ptr
	movem.l	(sp)+,d1-a6
	rts
	data
to_print	dc.b	10,13,"Liste des blocs :"
		dc.b	10,13,"Adresse",9,9,"Taille",9,9,"Pointeur",9,"Point‚",9,"Etat",10,13,0
	even
to_print2	dc.b	"Adresse pointeur",9,"Adresse point‚e :",10,13,0
	even
decimal_to_print	ds.b	16
	even
tab_to_print	dc.b	9,0
	even
cr_to_print	dc.b	10,13,0
	even
libre_to_print	dc.b	"Libre",10,13,0
	even
occupe_to_print	dc.b	"Occupe",10,13,0
	even
	text
