	include	gemdos.i
	include	..\memory.s
	include	..\macro.i
	include	hrd.i

*******************************************************************
*** Chargement du fichier header associe a un fichier ressource ***
*******************************************************************
	XDEF		hrd_load
hrd_load
	movem.l		d1-a6,-(sp)
	move.l		60+4(sp),d0	; path du fichier hrd
	move.l		60+0(sp),a5	; structure mrsc

* Chargement du fichier dans un Malloc()
	Fopen		#0,d0
	move.w		d0,d5
	bmi		no_hrd

	Fseek		#SEEK_END,d5,#0
	move.l		d0,d6
	Fseek		#SEEK_SET,d5,#0

	Malloc		d6
	tst.l		d0
	beq		no_hrd
	move.l		d0,d7

	Fread		d7,d6,d5

	Fclose		d5

	move.l		d7,a6
	add.l		#sizeof_hrdhd,a6

	add.l		#mrsc_ptr,a5

* Ajout des labels aux structures deja existantes
boucle_load_labels
	moveq.l		#0,d6
	move.b		(a6),d6
	jmp		([jump_table.w,pc,d6.w*4])
* Table de saut en fonction du type rencontre
jump_table
	dc.l	hrd_form
	dc.l	hrd_menu
	dc.l	hrd_alert
	dc.l	hrd_freestring
	dc.l	hrd_freeimg
	dc.l	hrd_object
	dc.l	hrd_eof
	dc.l	hrd_prefix

	*------------*
hrd_form
hrd_menu
	move.w	hrdrec_treeidx(a6),d0
	move.l	(a5,d0*4),a4
	lea	hrdrec_name(a6),a3
.lp_cp_treename
	move.b	(a3)+,(a4)+
	bne	.lp_cp_treename
	bra	next_object
	*------------*
hrd_alert
	bra	next_object
	*------------*
hrd_freestring
	bra	next_object
	*------------*
hrd_freeimg
	bra	next_object
	*------------*
hrd_object
	lea	hrdrec_name(a6),a3
	move.w	hrdrec_treeidx(a6),d0
	move.l	(a5,d0*4),a4
	add.l	#mtree_objets,a4
	set_indirect	a4,hrdrec_objidx(a6),#"LABL",a3

	bra	next_object
	*------------*
hrd_prefix

next_object
	add.l	#hrdrec_name,a6
.lp_end_chaine
	tst.b	(a6)+
	bne	.lp_end_chaine

	bra	boucle_load_labels

hrd_eof
	Mfree		d7

no_hrd
	movem.l		(sp)+,d1-a6
	rts
