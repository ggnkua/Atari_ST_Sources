	text
	include	gemdos.i
	include	structs.s
	include	..\memory.s
	include	..\macro.i
	include	hrd.i
	include	zlib.i

	text
add_a_label	macro	; type.w,tree_idx.w,obj_idx.w,name.l
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	move.w	\3,-(sp)
	move.l	\4,-(sp)
	bsr	add_a_label_rout
	lea	10(sp),sp
	endm
*******************************************************************
*** Sauvegarde du fichier header associe a un fichier ressource ***
*******************************************************************
	XDEF		hrd_save
hrd_save
	movem.l		d1-a6,-(sp)
	move.l		60+4(sp),d7	; path du fichier hrd
	move.l		60+0(sp),a5	; structure mrsc

	Malloc		#128*1024	; 128k devrait suffire
	move.l		d0,a4
	move.l		d0,d5		; adresse de base

* Fabrique le header
	move.w		#1,hrdhd_version(a4)
	move.b		#0,hrdhd_autonaming(a4)
	move.b		#%110001,hrdhd_langflag(a4)
	move.b		#0,hrdhd_autosnap(a4)
	move.b		#0,hrdhd_casing(a4)
	move.b		#0,hrdhd_autosizing(a4)
	lea		sizeof_hrdhd(a4),a4

	*----------*
	moveq.l		#0,d4	; compteur d'arbre
	move.l		mrsc_ptrnbr(a5),d6
	lea		mrsc_ptr(a5),a6
lp_save_labels
	move.l		(a6)+,a5
	cmp.l		#rptt_dial,mtree_type(a6)
	beq		save_dial_labels
	cmp.l		#rptt_menu,mtree_type(a6)
	beq		save_dial_labels
	cmp.l		#rptt_alrt,mtree_type(a6)
	beq		save_alert_label
	bra		end_tree_label

	*----------*
save_dial_labels
	add_a_label	#HRDTYP_FORM,d4,#0,a5	; label de l'arbre

* Commence a sauver les labels des objets
	moveq.l		#0,d3	; compteur d'objet
	lea		mtree_objets(a5),a3
.lp_sauve_labels
	get_indirect	a3,d3,#"LABL"
	cmp.l		#0,a0
	beq		.no_label

	lea		obck_string(a0),a2
	add_a_label	#HRDTYP_OBJ,d4,d3,a2
.no_label
	trouve_objc	a3,d3
	addq.l		#1,d3
	btst		#LASTOB,ob_flags+1(a0)
	beq		.lp_sauve_labels

	bra		end_tree_label
	*----------*
save_alert_label

	bra		end_tree_label
	*----------*
end_tree_label
	addq.l		#1,d4
	subq.l		#1,d6
	bne		lp_save_labels
	*----------*
	move.b		#6,(a4)+	; dernier enregistrement : fin du fichier
	clr.b		(a4)+
	clr.w		(a4)+
	clr.w		(a4)+
	clr.b		(a4)+

	Fcreate		#0,d7
	move.w		d0,d4
	bmi		.end

	move.l		a4,d0
	sub.l		d5,d0	; taille fichier

	Fwrite		d5,d0,d4
	Fclose		d4
.end
	Mfree		d5

	movem.l		(sp)+,d1-a6
	rts

*************************************************************************
*** Ajoute un label au fichier a sauver (pointeur du fichier dans a4) ***
*************************************************************************
* params :
* type.w,tree_idx.w,obj_idx.w,name.l
add_a_label_rout
	movem.l	d5-d7/a6,-(sp)
	move.w	20+8(sp),d5	;type
	move.w	20+6(sp),d6	; tree
	move.w	20+4(sp),d7	; obj
	move.l	20+0(sp),a6	; name

	move.b	d5,(a4)+	; type
	clr.b	(a4)+		; reserved
	move.w	d6,(a4)+	; tree_idx
	move.w	d7,(a4)+	; obj_idx
.lp_cp_name
	move.b	(a6)+,(a4)+
	bne	.lp_cp_name

	movem.l	(sp)+,d5-d7/a6
	rts
