	text
	include	gemdos.i
	include	structs.s
	include	util.i
	include	..\memory.s
	include	..\macro.i
	include	hrd.i
	include	zlib.i

	text
save_a_label	macro	; commentaire,label,chaine_a_parser,valeur
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move.l	\4,-(sp)
	bsr	save_a_label_rout
	lea	16(sp),sp
	endm
********************************************************
*** Sauvegarde un fichier pour un language generique ***
********************************************************
	XDEF	save_4_inc
save_4_inc
	movem.l		d1-a6,-(sp)
	move.l		60+12(sp),a4	; string a parser pour connaitre le format du language
	move.l		60+8(sp),d7	; extention du fichier
	move.l		60+0(sp),a5	; structure mrsc

	string_copy	60+4(sp),#file_name

	Malloc		#128*1024	; 128k devrait suffire
	move.l		d0,d5		; adresse de base
	move.l		d0,a3

	moveq.l		#0,d4	; compteur d'arbre
	move.l		mrsc_ptrnbr(a5),d6
	lea		mrsc_ptr(a5),a6

lp_save_labels
	move.l		(a6)+,a5
	cmp.l		#rptt_dial,mtree_type(a5)
	beq		save_dial_labels
	cmp.l		#rptt_menu,mtree_type(a5)
	beq		save_dial_labels
	cmp.l		#rptt_alrt,mtree_type(a5)
	beq		save_alert_label
	bra		end_tree_label


save_dial_labels
	lea		mtree_label(a5),a0
	lea		mtree_comment(a5),a1
	save_a_label	a1,a0,a4,d4

	moveq.l		#0,d3	; compteur d'objet
	lea		mtree_objets(a5),a2
.lp_save_objs
	get_indirect	a2,d3,#"LABL"
	cmp.l		#0,a0
	beq		.no_label

	lea		obck_string(a0),a0
	move.l		a0,d2

	get_indirect	a2,d3,#"COMT"
	cmp.l		#0,a0
	beq		.no_coment

	lea		obck_string(a0),a0

.no_coment

	save_a_label	a0,d2,a4,d3

.no_label
	trouve_objc	a2,d3
	addq.l		#1,d3
	btst		#LASTOB,ob_flags+1(a0)
	beq		.lp_save_objs
	bra		end_tree_label
save_alert_label
	lea		mtree_label(a5),a0
	lea		mtree_comment(a5),a1
	save_a_label	a1,a0,a4,d4


end_tree_label
	addq.l		#1,d4
	subq.l		#1,d6
	bne		lp_save_labels

* Update l'extention de la chaine
	lea		file_name,a0
.lp_find_end
	tst.b		(a0)+
	bne		.lp_find_end

.lp_find_extend
	cmp.b		#".",-(a0)
	bne		.lp_find_extend
	move.l		d7,(a0)

* Sauve le fichier
	Fcreate		#0,#file_name
	move.l		d0,d7

	move.l		a3,d0
	sub.l		d5,d0
	Fwrite		d5,d0,d7

	Fclose		d7

	movem.l		(sp)+,d1-a6
	rts

*************************************************************************
*** Ajoute une ligne contenant une definition dans le buffer a sauver ***
*************************************************************************
* Ajoute a la fin de a3
save_a_label_rout
	movem.l	d7/a4-a6,-(sp)
	move.l	20+12(sp),a4	; adresse du commentaire (0 = pas de commentaire)
	move.l	20+8(sp),a5	; adresse du label
	move.l	20+4(sp),a6	; adresse de la chaine a parser
	move.l	20+0(sp),d7	; numero de l'objet

	*---------*
.lp_parse
	cmp.b	#"%",(a6)
	beq	.special
	move.b	(a6)+,(a3)+
	bne	.lp_parse
	subq.l	#1,a3
	move.b	#10,(a3)+
	move.b	#13,(a3)+

	movem.l	(sp)+,d7/a4-a6
	rts
	*---------*
.special
	addq.l	#1,a6
	cmp.b	#"c",(a6)
	beq	.commentaire
	cmp.b	#"l",(a6)
	beq	.label
	cmp.b	#"v",(a6)
	beq	.valeur
	illegal
	dc.b	"valeur incoerente dans la chaine de definition du language"
	even
	*---------*
.commentaire
	tst.l	a4
	beq	.end_special

.lp_add_comment
	move.b	(a4)+,(a3)+
	bne	.lp_add_comment
	subq.l	#1,a3

	bra	.end_special
	*---------*
.label
	move.b	(a5)+,(a3)+
	bne	.label
	subq.l	#1,a3
	bra	.end_special
	*---------*
.valeur
	long_2_chaine	d7,a3,#3
	lea		3(a3),a3

.end_special
	addq.l	#1,a6
	bra	.lp_parse
	*---------*
	bss
file_handle	ds.w	1
file_name	ds.b	1024
	text
