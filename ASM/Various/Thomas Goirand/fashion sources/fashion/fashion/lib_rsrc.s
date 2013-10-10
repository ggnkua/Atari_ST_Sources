		TEXT
;**************************************************
; chargement/relogement du ressource sp‚cifi‚.    *
; parametre:                                      *
; LONG: pointeur sur le nom du fichier.           *
; retour                                          *
; D0.L du pointeur sur le ressource.              *
; ( n‚gatif signale une erreur )                  *
;**************************************************
	include	gemdos.i
	include	aes.i
	include	structs.s
	include	zlib.i
	include	lib_trnf.s

	XDEF	_RSC_LOAD
	XREF	screen_mfdb

		rsset	8
_RSL_NAME		rs.l	1

		rsset	-(9*2+3*4)
_RSL_FSIZE	rs.l	1
_RSL_START	rs.l	1
_RSL_ICONPTRS	rs.l	1
_RSL_HANDLE	rs.w	1
_RSL_TRNBLOC	rs.w	8
		
		********
_RSC_LOAD:
		link	a6,#-(9*2+3*4)
		movem.l	d1-a5,-(sp)
		
		Fopen	#0,_RSL_NAME(a6)
		move	d0,_RSL_HANDLE(a6)
		bmi	.FileError
		
		Fseek	#2,_RSL_HANDLE(a6),#0
		move.l	d0,_RSL_FSIZE(a6)
		
		Fseek	#0,_RSL_HANDLE(a6),#0
		Malloc	#-1
		
		sub.l	#128*1024,d0
		cmp.l	_RSL_FSIZE(a6),d0
		ble	.MemoryError
		
		Malloc	d0
		move.l	d0,_RSL_START(a6)
		beq	.MemoryError
		
		Fread	_RSL_START(a6),_RSL_FSIZE(a6),_RSL_HANDLE(a6)
		
		Fclose	_RSL_HANDLE(a6)

		move.l	_RSL_START(a6),a0
		cmp.l	#"DLMN",(a0)
		bne	.no_dlmn_format

		cmp.l	#"RSRC",4(a0)
		bne	.FileError

		XREF	newrsc_reloc
		move.l	a0,-(sp)
		jsr	newrsc_reloc

		bra	.End
		
.no_dlmn_format
		********************
		
		; reloge les structures 'classiques'
		
		move.l	_RSL_START(a6),a0
		move.l	a0,d6
		moveq	#9,d0
		moveq	#0,d3
		lea	.Data,a1
.Loop1
		moveq	#0,d1
		moveq	#0,d2
		
		move	(a1)+,d1
		move	(a0,d1.l),d1
		move	(a1)+,d2
		add.l	d2,d1
		move	(a1)+,d2
		move	(a0,d2.l),d2
		move	(a1)+,d3
		bra.s	.Hop
.Loop2		
		add.l	d6,(a0,d1.l)
		add.l	d3,d1
.Hop		
		dbf	d2,.Loop2
		
		dbf	d0,.Loop1
		
		*------------*
		
		move.l	a0,a4
		add.l	_RSL_FSIZE(a6),a4
		
		move	(a0),d0
		btst	#2,d0
		beq	.fixobj
		
		********************
		
		; les icones couleur !
		
		move.l	a0,a1
		
		moveq	#0,d0
		move	34(a0),d0
		add.l	d0,a1
		
		move.l	4(a1),a1
		
		cmp.l	#$ffffffff,a1
		beq	.yanapa
		
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
		
		********
		
		move.l	_RSL_ICONPTRS(a6),a1
.yopicons
		; stocke pointeur C_ICONBLK dans la table
		
		move.l	a3,(a1)+
		
		; calcul taille d'1 plan en octets
		
		move.w	ib_wicon(a3),d1
		addq.w	#7,d1
		lsr.w	#3,d1
		mulu.w	ib_hicon(a3),d1
		
		; calcul pointeurs mono
		
		lea	ib_resvd+4(a3),a2
		move.l	a2,ib_pdata(a3)
		move.l	a2,d7		; mem bitmap
		
		add.l	d1,a2
		move.l	a2,ib_pmask(a3)
		
		add.l	d1,a2
		move.l	a2,ib_ptext(a3)
		lea	12(a2),a0
		
		; y'a-t-il plusieurs r‚solutions ?
		
		move.l	ib_resvd(a3),d2
		ble	.endicon
		
		; inits du trnbloc
		
		move.w	screen_mfdb+mfdb_planes,d3
		move.w	d3,_TRN_DREZ+_RSL_TRNBLOC(a6)
		
		move.w	ib_wicon(a3),_TRN_W+_RSL_TRNBLOC(a6)
		move.w	ib_hicon(a3),_TRN_H+_RSL_TRNBLOC(a6)
		
		****
		
		; recherche de la plus jolie pour ce mode ‚cran
		
		moveq	#1,d0		; au moins mono
		;;cmp.w	#1,d3
		;;ble	.endicon
.lijo		
		move.l	a0,a2
		move.w	(a2),d4
		
		cmp.w	d3,d4
		bgt	.pabo
		
		move.w	d4,d0	; mem bitmap
		moveq	#22,d7
		add.l	a2,d7
.pabo		
		mulu.w	d1,d4		; taille en n plans
		
		lea	22(a2),a0
		add.l	d4,a0
		add.l	d1,a0
		
		tst.l	10(a2)
		beq.s	.noanim
		
		add.l	d4,a0
		add.l	d1,a0
.noanim
		tst.l	18(a2)
		bne.s	.lijo
		
		bsr	.joli
		
		****
.endicon
		move.l	a0,a3
		
		subq.w	#1,d6
		bgt	.yopicons
		bra	.fixobj
		
		****
.joli
		; on a trouv‚ une jolie on va l'adapter
		
		; structure icone couleur:
		; word : plans
		; long : p_data
		; long : p_mask
		; long : p_data s‚lection
		; long : p_mask s‚lection
		; long : next
		
		rsreset
cic_planes	rs.w	1
cic_pdata		rs.l	1
cic_pmask		rs.l	1
cic_psdata	rs.l	1
cic_psmask	rs.l	1
cic_next		rs.l	1
		
		move.l	-4(a1),a2
		clr.l	ib_resvd(a2)
		
		cmp.w	#1,d0
		ble.s	.okiblk
		move.l	a4,ib_resvd(a2)
		
		move.w	d0,_TRN_SREZ+_RSL_TRNBLOC(a6)
		
		move.w	d3,d4
		mulu.w	d1,d4
		mulu.w	d1,d0
		
		move.l	a4,a3
		lea	22(a4),a4
		
		move.w	d3,cic_planes(a3)
		clr.l	cic_next(a3)
		
		move.l	a4,cic_pdata(a3)
		add.l	d4,a4
		
		****
		
		; cas de transformation de bitmap couleur
		; le masque est derriere les data dans la
		; structure d'origine ,il suffit de pointer
		; dessus...
		
		move.l	d7,d5
		add.l	d0,d5
		move.l	d5,cic_pmask(a3)
		
		move.l	d7,_TRN_SMAP+_RSL_TRNBLOC(a6)
		move.l	cic_pdata(a3),_TRN_DMAP+_RSL_TRNBLOC(a6)
		
		pea	_RSL_TRNBLOC(a6)
		jsr	_TRNF_HARD
		
		move.l	d7,a2
		tst.l	-12(a2)	; anim selection ??
		bne.s	.aniblk
		
		clr.l	cic_psdata(a3)
		clr.l	cic_psmask(a3)
		bra.s	.okiblk
.aniblk		
		move.l	a4,cic_psdata(a3)
		add.l	d4,a4
		
		add.l	d1,d5
		move.l	d5,_TRN_SMAP+_RSL_TRNBLOC(a6)
		move.l	cic_psdata(a3),_TRN_DMAP+_RSL_TRNBLOC(a6)
		
		pea	_RSL_TRNBLOC(a6)
		jsr	_TRNF_HARD
		
		add.l	d0,d5
		move.l	d5,cic_psmask(a3)
		
		****
.okiblk		
		rts
		
		****************
.yanapa
.fixobj
		move.l	a4,a2
		move.l	_RSL_START(a6),a0
		move.l	_RSL_ICONPTRS(a6),a5
		move.l	a0,a1
		move.l	a0,d6
		
		; reloge objets (ob_spec)
		
		moveq	#0,d0
		move	2(a1),d0
		add.l	d0,a1
		move	20(a0),d0
		
		subq	#1,d0
.ObjLoop		
		moveq	#$7f,d1
		and	ob_type(a1),d1
		sub	#20,d1
		
		add	d1,d1
		add	d1,d1
		move.l	(.FIX_TABLE.w,pc,d1.w),a0
		jmp	(a0)
		
		****************
.FIX_GLINE
.FIX_GBOX
		bra	.fix_xywh
.FIX_GTEXT
		move.l	ob_spec(a1),a3
		add.l	d6,a3
		move.l	a3,ob_spec(a1)
		bra.s	.fix_xywh
.FIX_GBOXTEXT
		move.l	ob_spec(a1),a3
		add.l	d6,a3
		move.l	a3,ob_spec(a1)
		bra.s	.fix_xywh
.FIX_GIMAGE
		add.l	d6,ob_spec(a1)
		bra.s	.fix_xywh
.FIX_GUSERDEF
		add.l	d6,ob_spec(a1)
;		move.l	#X_OBJECTS,([a1,ob_spec.w])
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
		move.l	a3,ob_spec(a1)
		bra.s	.fix_xywh
.FIX_GFBOXTEXT
		move.l	ob_spec(a1),a3
		add.l	d6,a3
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
;		bra.s	.fix_xywh
		
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
						
		****************
		
		move.l	_RSL_START(a6),d6
		sub.l	d6,a2
		
		mshrink	a2,d6
		
		move.l	d6,d0
		
		****************
.End
		movem.l	(sp)+,d1-a5
		unlk	a6
		rtd	#4
		
		****************
.FileError:
		form_alert	#1,#.Erreur1
		
		moveq	#-1,d0
		bra	.End
		
		****************
.MemoryError
		form_error	#8
		
		moveq	#-2,d0
		bra	.End
		
		****************
.Erreur1:
		dc.b	"[3][ |"
		dc.b	" Le fichier ressource |"
		dc.b	" n'a pu etre ouvert !"
		dc.b	"][ annuler ]",0
		even
		
		****************
.Data:
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

		****************
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
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	.FIX_GLINE
		****************
	
********************************************************************

		********
		
		; renvoie l'adresse d'un ‚l‚ment du ressource
		
		; parametres:
		; LONG: pointeur sur UNE ressource
		; (le meme que renvoy‚ par _RSC_LOAD)
		; WORD: type d'‚l‚ment recherch‚
		; WORD: index de l'‚l‚ment...
		
		; retour en D0.L (n‚gatif=erreur)

		********
		
		; _rsc_gaddr tree,type,index
		
_rsc_gaddr	MACRO
		
		move.l	\1,-(sp)
		move.w	\2,-(sp)
		move.w	\3,-(sp)
		jsr	_irsc_gaddr
		addq.w	#8,sp
		
		ENDM
		
		********
		
		rsset	3*4
_rsg_idx		rs.w	1
_rsg_type		rs.w	1
_rsg_ptr		rs.l	1
		
		********
_irsc_gaddr:	
		movem.l	a0-a1,-(sp)
		
		move.w	_rsg_type(sp),d0
		lea	.jgad(pc),a0
		add.w	(a0,d0.w*2),a0
		
		move.l	_rsg_ptr(sp),a1
		move.w	_rsg_idx(sp),d0
		
		jsr	(a0)
.end		
		movem.l	(sp)+,a0-a1
		rts
		
		********
.gtre
		add.w	rsh_trindex(a1),a1
		move.l	(a1,d0.w*4),d0
		rts
		
		****
.gobj
		add.w	rsh_object(a1),a1
		mulu.w	#24,d0
		add.l	a1,d0
		rts
		
		****
.gted		
		add.w	rsh_tedinfo(a1),a1
		mulu.w	#28,d0
		add.l	a1,d0
		rts
		
		****
.gicb		
		add.w	rsh_iconblk(a1),a1
		mulu.w	#36,d0
		add.l	a1,d0
		rts
		
		****
.gbib		
		add.w	rsh_bitblk(a1),a1
		mulu.w	#14,d0
		add.l	a1,d0
		rts
		
		****
.gfst		
		add.w	rsh_frstr(a1),a1
		move.l	(a1,d0.w*4),d0
		rts
		
		****
.gfri
		add.w	rsh_frimg(a1),a1
		move.l	(a1,d0.w*4),d0
		rts
		
		********
.jgad:
		dc.w	.gtre-.jgad
		dc.w	.gobj-.jgad
		dc.w	.gted-.jgad
		dc.w	.gicb-.jgad
		dc.w	.gbib-.jgad
		dc.w	.gfst-.jgad
		dc.w	.gfri-.jgad
		
		****
		
		; 0=tree
		; 1=object
		; 2=tedinfo
		; 3=iconblk
		; 4=bitblk
		; 5=free string
		; 6=free image
		
		****************

********************************************************************
