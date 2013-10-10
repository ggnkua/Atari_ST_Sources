****************************************************************

ZIGO_SRC	equ	1

		ifd	ZIGO_SRC
		bss
AesDitheringMode	ds.w	1
		text
		include	gemdos.i
		include	aes.i
		include	structs.s
		include	zlib.i
		XDEF	_RSC_LOAD
		XREF	screen_mfdb
		XREF	_sys_palette
		XREF	_tx_master
		endc

****************************************************************

		****
		text
		****

		ifnd	ZIGO_SRC
_rsrc_load:
		move.w	#$6666,([a0,a_global.w],0.w)
		clr.w	([a0,a_intout.w])
		
		move.l	([a0,a_addrin.w]),-(sp)
		jsr	_rsc_load
		
		move.l	d0,([a0,a_global.w],5*2.w)
		beq.s	.out
		
		move.w	#1,([a0,a_intout.w])
.out		
		rts
		
		endc
		****
		
****************************************************************
		
		****
		
		; chargement/relogement du ressource sp‚cifi‚.
		
		; parametre:
		; LONG: pointeur sur le nom du fichier.
		
		; retour en D0.L du pointeur sur le ressource.
		; ( n‚gatif signale une erreur )
		
		****
		
		rsset	8
_RSL_NAME		rs.l	1

		rsset	-(32)
_RSL_FSIZE	rs.l	1
_RSL_START	rs.l	1
_RSL_ICONPTRS	rs.l	1
_rsl_tx		rs.l	1
_rsl_pix		rs.l	1
_rsl_zlika	rs.l	1
_RSL_HANDLE	rs.w	1
_rsl_bpp		rs.w	1
		
		****
_RSC_LOAD:
		link	a6,#-(32)
		movem.l	d1-a5,-(sp)
		
		****

		move.w	#7,AesDitheringMode

		; malloc pour les structures
		; servant aux conversions de bitmap
		
		pea	tx_sizeof+pix_sizeof
		move.w	#$48,-(sp)		; malloc
		trap	#1
		addq.l	#6,sp
		
		move.l	d0,_rsl_tx(a6)
		beq	.error
		
		add.l	#tx_sizeof,d0
		move.l	d0,_rsl_pix(a6)
		
		move.l	#_sys_palette,([_rsl_pix,a6],pix_palette)
		
		****
		
		; ouverture fichier sp‚cifi‚
		
		clr.w	-(sp)
		move.l	_RSL_NAME(a6),-(sp)	; fopen
		move.w	#$3d,-(sp)
		trap	#1
		addq.l	#8,sp
		
		move.w	d0,_RSL_HANDLE(a6)
		bmi	.error
		
		; d‚termination de la taille
		
		move.w	#2,-(sp)
		move.w	_RSL_HANDLE(a6),-(sp)
		clr.l	-(sp)
		move.w	#$42,-(sp)		; fseek
		trap	#1
		lea	10(sp),sp
		
		move.l	d0,_RSL_FSIZE(a6)
		
		clr.w	-(sp)
		move	_RSL_HANDLE(a6),-(sp)
		clr.l	-(sp)
		move.w	#$42,-(sp)		; fseek
		trap	#1
		lea	10(sp),sp
		
		; r‚servation de toute la ram sauf 128 ko
		
		moveq	#-1,d0
		move.l	d0,-(sp)
		move.w	#$48,-(sp)	; malloc
		trap	#1
		addq.l	#6,sp
		
		sub.l	#128*1024,d0
		
		cmp.l	_RSL_FSIZE(a6),d0
		ble	.error
		
		move.l	d0,-(sp)
		move.w	#$48,-(sp)	; malloc
		trap	#1
		addq.l	#6,sp
		
		move.l	d0,_RSL_START(a6)
		beq	.error
		
		; chargement fichier
		
		move.l	_RSL_START(a6),-(sp)
		move.l	_RSL_FSIZE(a6),-(sp)
		move.w	_RSL_HANDLE(a6),-(sp)
		move.w	#$3f,-(sp)	; fread
		trap	#1
		lea	12(sp),sp
		
		; fermeture
		
		move.w	_RSL_HANDLE(a6),-(sp)
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp
		
		****

		move.l	_RSL_START(a6),a0
		
		; determination du format
		
		cmp.l	#"DLMN",(a0)
		bne	.no_dlmn_format

		cmp.l	#"RSRC",4(a0)
		bne	.error
		
		****
		
		move.l	a0,-(sp)
		jsr	newrsc_reloc
		lea	4(sp),sp
		
		****
		
		move.l	d0,a2
		move.l	a0,d0

		bra	.eok
.no_dlmn_format
		**************
		* format tos *
		**************
		
		; reloge les structures 'classiques'
		move.l	_RSL_START(a6),a0
		move.l	a0,d6
		
		moveq	#10-1,d0
		moveq	#0,d3
		
		lea	.table_offsets,a1
		
		****
		
		; attention format long ou court ?
		
		cmp.w	#3,(a0)
		bne.s	.short
		
		****
.long
		moveq	#0,d1
		move.w	(a1)+,d1
		
		move.l	(a0,d1.l*2),d1
		
		moveq	#0,d2
		move.w	(a1)+,d2
		
		add.l	d2,d1
		
		move.w	(a1)+,d2
		move.l	(a0,d2.l*2),d2
		
		move.w	(a1)+,d3
		beq.s	.long_nobj
.long_obj		
		add.l	d6,(a0,d1.l)
		add.l	d3,d1
		
		subq.l	#1,d2
		bgt.s	.long_obj
.long_nobj		
		dbf	d0,.long
		
		bra	.okrelo
		
		****
.short
		moveq	#0,d1
		move.w	(a1)+,d1
		
		move.w	(a0,d1.l),d1
		
		moveq	#0,d2
		move.w	(a1)+,d2
		
		add.l	d2,d1
		
		move.w	(a1)+,d2
		move.w	(a0,d2.l),d2
		
		move.w	(a1)+,d3
		
		bra.s	.short3
.short2		
		add.l	d6,(a0,d1.l)
		add.l	d3,d1
.short3		
		dbf	d2,.short2
		dbf	d0,.short
		
		****
.okrelo		
		move.l	a0,a4
		add.l	_RSL_FSIZE(a6),a4
		
		cmp.w	#3,(a0)
		blt	.fixobj
		
		****
		
		; les icones couleur !
		
		move.l	a0,a1
		
		moveq	#0,d0
		move.w	$22(a0),d0
		
		cmp.w	#3,(a0)
		bne.s	.okoff
		
		move.l	$44(a0),d0
.okoff		
		add.l	d0,a1
		move.l	4(a1),a1
		add.l	a0,a1
		
		move.l	a1,_RSL_ICONPTRS(a6)
		
		move.l	a1,a3
		moveq	#-1,d6
.count
		addq.l	#1,d6	; comptage des ciconblk
		tst.l	(a3)+
		bpl.s	.count
		
		tst.l	d6
		ble	.fixobj
		
		****
		
		move.l	d6,d7
		move.l	_RSL_ICONPTRS(a6),a1
.yopicons
		; stocke pointeur C_ICONBLK dans la table
		
		move.l	a3,(a1)+
		
		moveq	#0,d0
		
		; taille 1 plan en octets
		
		move.w	ib_wicon(a3),d1
		addq.w	#7,d1
		lsr.w	#3,d1
		mulu.w	ib_hicon(a3),d1
		
		; relogement pointeurs mono
		
		lea	ib_resvd+4(a3),a2
		move.l	a2,ib_pdata(a3)
		
		add.l	d1,a2
		move.l	a2,ib_pmask(a3)
		
		add.l	d1,a2
		move.l	a2,ib_ptext(a3)
		
		lea	12(a2),a2
		
		; y'a-t-il plusieurs r‚solutions ?
		
		tst.l	ib_resvd(a3)
		beq	.endicon
		
		; relogement de toutes les r‚solutions
		
		move.l	a2,ib_resvd(a3)
		move.l	a2,a3
		
		; taille bitmap en octets
.cic_reloc
		move.w	cic_planes(a3),d4
		mulu.w	d1,d4
		
		lea	cic_next+4(a2),a2
		move.l	a2,cic_pdata(a3)
		add.l	d4,a2
		
		move.l	a2,cic_pmask(a3)
		add.l	d1,a2
		
		tst.l	cic_psdata(a3)
		beq.s	.nosel
		
		move.l	a2,cic_psdata(a3)
		add.l	d4,a2
		
		move.l	a2,cic_psmask(a3)
		add.l	d1,a2
.nosel		
		tst.l	cic_next(a3)
		beq.s	.endicon
		
		move.l	a2,cic_next(a3)
		move.l	a2,a3
		
		bra.s	.cic_reloc
		
		****
.endicon
		move.l	a2,a3
		
		subq.l	#1,d7
		bgt	.yopicons
		
		****
		
		move.l	d6,-(sp)			; nombre d'icones
		move.l	_RSL_ICONPTRS(a6),-(sp)	; table des icones (ptrs)
		move.l	a4,-(sp)			; pointeur m‚moire dispo
		
		jsr	trans_icons		; icones vers format ‚cran
		
		lea	12(sp),sp
		
		move.l	d0,a4			; nouveau pointeur m‚moire dispo
		
		****
.fixobj
		move.l	a4,a2
		move.l	_RSL_START(a6),a0
		move.l	_RSL_ICONPTRS(a6),a5
		move.l	a0,a1
		move.l	a0,d6
		
		; reloge objets (ob_spec)
		; (attn aux 2 formats)
		
		cmp.w	#3,(a0)
		bne.s	.notlong
		
		move.l	4(a1),d0
		add.l	d0,a1
		
		move.l	40(a0),d0
		subq.l	#1,d0
		bra.s	.ObjLoop
.notlong		
		moveq	#0,d0
		move.w	2(a1),d0
		add.l	d0,a1
		
		move.w	20(a0),d0
		subq.w	#1,d0
		
		****
.ObjLoop		
		moveq	#$7f,d1
		and.w	ob_type(a1),d1
		sub.w	#20,d1
		
		move.l	(.FIX_TABLE.w,pc,d1.l*4),a0
		jmp	(a0)
		
		********
.FIX_GBOX
		bra	.fix_xywh
.FIX_GTEXT
		move.l	ob_spec(a1),a3
		add.l	d6,a3
		clr	te_resvd1(a3)
		clr	te_resvd2(a3)
		move.l	a3,ob_spec(a1)
		bra.s	.fix_xywh
.FIX_GBOXTEXT
		move.l	ob_spec(a1),a3
		add.l	d6,a3
		clr	te_resvd1(a3)
		clr	te_resvd2(a3)
		move.l	a3,ob_spec(a1)
		bra.s	.fix_xywh
.FIX_GIMAGE
		add.l	d6,ob_spec(a1)
		bra.s	.fix_xywh
.FIX_GUSERDEF
		add.l	d6,ob_spec(a1)
		move.l	#.void,([ob_spec.w,a1])
		bra.s	.fix_xywh
.FIX_GIBOX
		bra.s	.fix_xywh
.FIX_GBUTTON
		add.l	d6,ob_spec(a1)
		bra.s	.fix_xywh
.FIX_GBOXCHAR
		bra.s	.fix_xywh
.FIX_GSTRING
		add.l	d6,ob_spec(a1)
		bra.s	.fix_xywh
.FIX_GFTEXT
		move.l	ob_spec(a1),a3
		add.l	d6,a3
		clr	te_resvd1(a3)
		clr	te_resvd2(a3)
		move.l	a3,ob_spec(a1)
		bra.s	.fix_xywh
.FIX_GFBOXTEXT
		move.l	ob_spec(a1),a3
		add.l	d6,a3
		clr	te_resvd1(a3)
		clr	te_resvd2(a3)
		move.l	a3,ob_spec(a1)
		bra.s	.fix_xywh
.FIX_GICON
		add.l	d6,ob_spec(a1)
		bra.s	.fix_xywh
.FIX_GTITLE
		add.l	d6,ob_spec(a1)
		bra.s	.fix_xywh
.FIX_GCICON
		move.l	ob_spec(a1),d3
		move.l	(a5,d3.l*4),ob_spec(a1)
		
		****************
.fix_xywh
		clr	d2
		clr	d3
		move.b	ob_x+0(a1),d2
		move.b	ob_x+1(a1),d3
		lsl	#3,d3
		add	d2,d3
		move	d3,ob_x(a1)
		
		clr	d2
		clr	d3
		move.b	ob_y+0(a1),d2
		move.b	ob_y+1(a1),d3
		lsl	#4,d3
		add	d2,d3
		move	d3,ob_y(a1)
		
		clr	d2
		clr	d3
		move.b	ob_w+0(a1),d2
		move.b	ob_w+1(a1),d3
		lsl	#3,d3
		add	d2,d3
		move	d3,ob_w(a1)
		
		clr	d2
		clr	d3
		move.b	ob_h+0(a1),d2
		move.b	ob_h+1(a1),d3
		lsl	#4,d3
		add	d2,d3
		move	d3,ob_h(a1)
		
		lea	24(a1),a1

		dbf	d0,.ObjLoop
						
		*****
.eok		
		move.l	_RSL_START(a6),d6
		sub.l	d6,a2
		
		move.l	a2,-(sp)
		move.l	d6,-(sp)
		clr	-(sp)
		move.w	#$4a,-(sp)
		trap	#1
		lea	12(sp),sp
		
		*****
.end
		move.l	_rsl_tx(a6),-(sp)
		move.w	#$49,-(sp)
		trap	#1
		addq.l	#6,sp
		
		move.l	_RSL_START(a6),d0
.out		
		movem.l	(sp)+,d1-a5
		unlk	a6
		rtd	#4
		
		****
.error
		move.l	_rsl_tx(a6),-(sp)		; mfree
		move.w	#$49,-(sp)
		trap	#1
		addq.l	#6,sp
		
		move.l	_RSL_START(a6),-(sp)	; mfree
		move.w	#$49,-(sp)
		trap	#1
		addq.l	#6,sp
		
		moveq	#0,d0
		bra.s	.out
		
		********
		****
.table_offsets:
		dc.w	18,0,22,4		* trees
		dc.w	4,0,24,28		* ted infos (te_ptext)
		dc.w	4,4,24,28		* ted infos (te_pvalid)
		dc.w	4,8,24,28		* ted infos (te_ptmplt)
		dc.w	6,0,26,34		* icon blks (mask)
		dc.w	6,4,26,34		* icon blks (data)
		dc.w	6,8,26,34		* icon blks (text)
		dc.w	8,0,28,14		* bit blks
		dc.w	10,0,30,4		* free strings
		dc.w	16,0,32,4		* free images

		****
.FIX_TABLE:
		dc.l	.FIX_GBOX
		dc.l	.FIX_GTEXT
		dc.l	.FIX_GBOXTEXT
		dc.l	.FIX_GIMAGE
		dc.l	.FIX_GUSERDEF
		dc.l	.FIX_GIBOX
		dc.l	.FIX_GBUTTON
		dc.l	.FIX_GBOXCHAR
		dc.l	.FIX_GSTRING
		dc.l	.FIX_GFTEXT
		dc.l	.FIX_GFBOXTEXT
		dc.l	.FIX_GICON
		dc.l	.FIX_GTITLE
		dc.l	.FIX_GCICON
		
		****
.void
		moveq	#0,d0
		rts
		
		****
	
********************************************************************

		****
		
		; pix_to_screen ( pix,buff,tx )
		; fonction simplifi‚e adaptant un pix
		; au mode video de l'‚cran courant.
		
		****
		
		rsset	8
_pts_pix		rs.l	1	; pointe sur le pix … adapter
_pts_buff		rs.l	1	; adresse du bloc bitmap final
_pts_tx		rs.l	1	; pointe sur la tructure tx qui sera utilis‚e
		
		****
pix_to_screen
		link	a6,#0
		movem.l	d0/a4-a5,-(sp)
		
		
		move.l	_pts_pix(a6),a5
		move.l	_pts_tx(a6),a4
		
		move.l	pix_addr(a5),tx_sptr(a4)
		move.l	_pts_buff(a6),tx_dptr(a4)
		
		move.l	pix_w(a5),d0
		move.l	d0,tx_sw(a4)
		move.l	d0,tx_dw(a4)
		
		move.l	pix_h(a5),d0
		move.l	d0,tx_sh(a4)
		move.l	d0,tx_dh(a4)
		
		move.w	pix_bpp(a5),tx_sbpp(a4)
		move.w	pix_type(a5),tx_sform(a4)
		
		move.w	screen_mfdb+mfdb_planes,tx_dbpp(a4)
		move.w	screen_mfdb+mfdb_format,tx_dform(a4)
		
		move.l	pix_palette(a5),tx_spalob(a4)
		move.l	#_sys_palette,tx_dpalob(a4)
		
		move.l	#$7fffffff,tx_speed(a4)
		
		move.w	AesDitheringMode,tx_dit(a4)
		
		; conversion / tramage
		
		pea	(a4)
		jsr	_tx_master
		lea	4(sp),sp
		
		move.l	a6,-(sp)
		move.l	a4,a6
.yoptx		
		jsr	([tx_proc.w,a6])
		
		cmp.w	#3,tx_status(a6)
		bne.s	.yoptx
		
		move.l	(sp)+,a6
		
		****
		
		move.l	tx_dptr(a4),pix_addr(a5)
		move.w	tx_dbpp(a4),pix_bpp(a5)
		move.w	tx_dform(a4),pix_type(a5)
		
		****
.end		
		movem.l	(sp)+,d0/a4-a5
		unlk	a6
		rts
		
		****

********************************************************************

	***********************************************
	* Routine de relocation pour le format Dolmen *
	***********************************************

		****
newrsc_reloc:
		movem.l	d6-d7/a2-a5,-(sp)
	
		move.l	28(sp),a5
		
		move.l	nrsh_naddr(a5),d7
		
		move.l	a5,a4
		add.l	nrsh_reloc(a5),a4
		
		move.l	a5,d6
.loop		
		move.l	(a4)+,a3
		add.l	d6,(a3,d6.l)
		
		subq.l	#1,d7
		bgt.s	.loop


		****

		; on construit une table ciconblk
		; afin d'utiliser la meme routine de
		; transformation vers ‚cran qu'en tos...
		
		move.l	a5,a4
		add.l	_RSL_FSIZE(a6),a4
		move.l	a4,a3
		
		move.l	nrsh_objs(a5),a2
		move.l	nrsh_nobj(a5),d7
		moveq	#0,d6
		
		; pour chaque objet de type icone couleur
		; on cr‚e une entr‚e dans la table
.hop		
		cmp.b	#G_CICON,ob_type+1(a2)
		bne.s	.notic
		
			move.l	ob_spec(a2),(a3)+
			addq.l	#1,d6
.notic
		lea	24(a2),a2
		subq.l	#1,d7
		bgt.s	.hop
		
		****
		
		; maintenant on peut appeler 'trans_icons'
		
		tst.l	d6
		beq	.noicn
		
		move.l	d6,-(sp)
		move.l	a4,-(sp)
		move.l	a3,-(sp)
		
		jsr	trans_icons
		
		lea	12(sp),sp
		
.noicn
		****
		
		movem.l	(sp)+,d6-d7/a2-a5
		rts
		
		****
		

********************************************************************

		****
		
		; trans_icons (buf,tab,num)
		
		; transforme des icones de format rsc vers ‚cran
		
		; (retourne pointeur sur fin de la m‚moire utilis‚e)
		
		****
		
		rsset	13*4
_tic_buf		rs.l	1	; pointeur courant m‚moire dispo
_tic_tab		rs.l	1	; pointe table de pointeurs de cicon
_tic_num		rs.l	1	; nombre d'icones … mouliner

		****
trans_icons		
		movem.l	d1-d7/a0-a4,-(sp)
		
		move.l	_tic_buf(sp),a4
		move.l	_tic_tab(sp),a1
		move.l	_tic_num(sp),d7
		
		****
.hop		
		move.l	(a1)+,a0
		
		moveq	#0,d0
		moveq	#0,d1
		
		move.w	ib_wicon(a0),d0
		move.w	ib_hicon(a0),d1
		
		move.l	d0,([_rsl_pix.w,a6],pix_w.w)
		move.l	d1,([_rsl_pix.w,a6],pix_h.w)
		
		addq.l	#7,d0
		lsr.l	#3,d0
		mulu.w	d0,d1	; taille 1 plan en octets
		
		
		move.l	ib_resvd(a0),d0
		
		; recherche de la plus jolie
		; pour le mode ‚cran courant
		
		moveq	#1,d2
		move.l	d0,d5
		moveq	#0,d3
		move.w	screen_mfdb+mfdb_planes,d3
.lijo		
		move.l	d0,a0
		
		cmp.w	cic_planes(a0),d3
		blt.s	.pabo
		
			cmp.w	cic_planes(a0),d2
			bgt.s	.pabo
			
				move.l	a0,d5
				move.w	cic_planes(a0),d2
.pabo		
		move.l	cic_next(a0),d0
		bne.s	.lijo
		
		****
		
		move.l	d5,a0
		
		; on a trouv‚ une jolie on va l'adapter
		
		move.w	cic_planes(a0),d0
		move.w	d0,_rsl_bpp(a6)
		
		cmp.w	#1,d0
		beq	.okiblk
		
		; cr‚ation nouvelle structure ciconblk
		; pour la r‚solution ‚cran courante
		
		move.l	a4,a3
		lea	22(a4),a4
		
		move.l	([a1,-4.w],ib_resvd.w),cic_next(a3)
		move.l	a3,([a1,-4.w],ib_resvd.w)
		
		move.w	d3,cic_planes(a3)
		
		move.l	d1,d5
		mulu.l	d3,d5
		
		clr.l	cic_psdata(a3)
		clr.l	cic_psmask(a3)
		
		; cas de transformation de bitmap couleur
		; (les masques restent inchang‚s)
		
		move.l	cic_pdata(a0),([_rsl_pix.w,a6],pix_addr.w)	; adresse bitmap source
		move.w	#1,([_rsl_pix.w,a6],pix_type.w)		; format vdi
		move.w	_rsl_bpp(a6),([_rsl_pix.w,a6],pix_bpp.w)	; bits/pixel source
		
		; appel du tx_master
		; attention , il ne faut pas diffuser
		; l'erreur de conversion car sinon le masque
		; de l'icone devrait etre recalcul‚ !
		
		move.l	_rsl_tx(a6),-(sp)
		move.l	a4,-(sp)
		move.l	_rsl_pix(a6),-(sp)
		jsr	pix_to_screen
		lea	12(sp),sp
		
		move.l	a4,cic_pdata(a3)
		add.l	d5,a4
		
		move.l	cic_pmask(a0),cic_pmask(a3)
		
		****
		
		tst.l	cic_psdata(a0)	; anim selection ??
		beq.s	.okiblk
		
		move.l	cic_psdata(a0),([_rsl_pix.w,a6],pix_addr.w)	; adresse bitmap source
		move.w	#1,([_rsl_pix.w,a6],pix_type.w)		; format vdi
		move.w	_rsl_bpp(a6),([_rsl_pix.w,a6],pix_bpp.w)	; bits/pixel source
		
		move.l	_rsl_tx(a6),-(sp)
		move.l	a4,-(sp)
		move.l	_rsl_pix(a6),-(sp)
		jsr	pix_to_screen
		lea	12(sp),sp
		
		move.l	a4,cic_psdata(a3)
		add.l	d5,a4
		
		move.l	cic_psmask(a0),cic_psmask(a3)
		
		****
.okiblk		
		subq.l	#1,d7
		bgt	.hop
		
		; retourne le nouveau pointeur m‚moire dispo
		
		move.l	a4,d0
		
		movem.l	(sp)+,d1-d7/a0-a4
		rts
		
		****

********************************************************************
		