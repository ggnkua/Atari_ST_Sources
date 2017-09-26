	include	zlib.i
	include	structs.s

	XDEF	efface_tree_rout
efface_tree_rout
	move.l	a6,-(sp)
	move.l	8+0(sp),a6
	lea	-24(a6),a6
efface_tree_loop
	lea	24(a6),a6
	move.l	a6,-(sp)
	bsr	free_obj_rout
	addq.l	#4,sp
	btst	#LASTOB,ob_flags+1(a6)
	beq	efface_tree_loop
	movem.l	(sp)+,a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
***********************************************************************************************
*** Desalou tout ce qui est utilise par un objet (exp : la tedinfo et ce qu'elle pointe...) ***
***********************************************************************************************
* Parametre : adresse de l'objet
	XDEF	free_obj_rout
free_obj_rout
	move.l	a6,-(sp)
	move.l	a5,-(sp)
	move.l	a0,-(sp)
	move.l	16(sp),a6
	moveq.l	#0,d0
	lea	ob_spec(a6),a5
	btst	#INDIRECT-8,ob_flags(a6)
	beq	.not_indirect
	move.l	(a5),a5
.not_indirect
	moveq.l	#0,d0
	move.b	ob_type+1(a6),d0
	sub.w	#20,d0
	jmp	([del_obj_tbl.w,pc,d0.w*4])
*-----------------------------------*
efface_obj_g_text	; 21 g_text
efface_obj_g_boxtext	; 22 g_boxtext
	move.l		(a5),a0
	xaloc_free	a0
	xaloc_free	a5
	bra		efface_obj_end
*-----------------------------------*
efface_obj_g_button	; 26 g_button
efface_obj_g_string	; 28 g_string
efface_obj_g_title	; 32 g_title
	xaloc_free	a5
	bra		efface_obj_end
*-----------------------------------*
efface_obj_g_ftext	; 29 g_ftext
efface_obj_g_fboxtext	; 30 g_fboxtext
	move.l		(a5),a0
	xaloc_free	a0
	addq.l		#4,a0
	xaloc_free	a0
	addq.l		#4,a0
	xaloc_free	a0
	xaloc_free	a5
	bra		efface_obj_end
*-----------------------------------*
efface_obj_g_image	; 23 g_image
	move.l		(a5),a0
	xaloc_free	a0
	xaloc_free	a5
	bra	efface_obj_end
*-----------------------------------*
efface_obj_g_icon	; 31 g_icon
	move.l		(a5),a0
	xaloc_free	a0
	addq.l		#4,a0
	xaloc_free	a0
	addq.l		#4,a0
	xaloc_free	a0
	xaloc_free	a5
	bra	efface_obj_end
*-----------------------------------*
efface_obj_g_cicon	; 33 g_cicon
	move.l		a4,-(sp)
	move.l		a3,-(sp)
	move.l		(a5),a3
	move.l		ib_resvd(a3),a4
	xaloc_free	a3
	addq.l		#4,a3
	xaloc_free	a3
	addq.l		#4,a3
	xaloc_free	a3
efface_cicon_loop
	tst		a4
	beq		.suite2
	lea		col_data(a4),a3
	xaloc_free	a3
	lea		col_mask(a4),a3
	xaloc_free	a3
	tst.l		sel_data(a4)
	beq		.suite
	lea		sel_data(a4),a3
	xaloc_free	a3
	lea		sel_mask(a4),a3
	xaloc_free	a3
.suite	move.l		next_res(a4),a4
	bra		efface_cicon_loop
.suite2
	xaloc_free	a5
	move.l		(sp)+,a3
	move.l		(sp)+,a4
	bra	efface_obj_end
efface_obj_g_pix
	move.l		(a5),a0
	xaloc_free	a0
	xaloc_free	a5
	bra	efface_obj_end
*-----------------------------------*
efface_obj_g_boxchar	; 27 g_boxchar
efface_obj_g_ibox	; 25 g_ibox
efface_obj_g_progdef	; 24 g_progdef
efface_obj_g_box	; 20 g_box
efface_obj_g_line	; 37 g_line
efface_obj_end
	btst		#INDIRECT-8,ob_flags(a6)
	beq		.not_indirect
	lea		ob_spec(a6),a5
	xaloc_free	a5
.not_indirect
	move.l		(sp)+,a0
	move.l		(sp)+,a5
	move.l		(sp)+,a6
	rts
*-----------------------------------*
del_obj_tbl
	dc.l	efface_obj_g_box	; 20 g_box
	dc.l	efface_obj_g_text	; 21 g_text
	dc.l	efface_obj_g_boxtext	; 22 g_boxtext
	dc.l	efface_obj_g_image	; 23 g_image
	dc.l	efface_obj_g_progdef	; 24 g_progdef
	dc.l	efface_obj_g_ibox	; 25 g_ibox
	dc.l	efface_obj_g_button	; 26 g_button
	dc.l	efface_obj_g_boxchar	; 27 g_boxchar
	dc.l	efface_obj_g_string	; 28 g_string
	dc.l	efface_obj_g_ftext	; 29 g_ftext
	dc.l	efface_obj_g_fboxtext	; 30 g_fboxtext
	dc.l	efface_obj_g_icon	; 31 g_icon
	dc.l	efface_obj_g_title	; 32 g_title
	dc.l	efface_obj_g_cicon	; 33 g_cicon

	dc.l	0		efface_obj_g_bounding
	dc.l	0		efface_obj_g_bounded
	dc.l	efface_obj_g_pix
	dc.l	efface_obj_g_line
	dc.l	0		efface_obj_g_check
