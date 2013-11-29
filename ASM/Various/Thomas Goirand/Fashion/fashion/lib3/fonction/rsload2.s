	TEXT
; chargement/relogement du ressource sp‚cifi‚.
; parametre:
; LONG: pointeur sur le nom du fichier.

; retour en D0.L du pointeur sur le ressource.
; ( n‚gatif signale une erreur )
reloge_ressource	macro	adresse_du_ressource
	move.l	\1,d0
	bsr		reloge_ressource_routine
	endm

	rts
*** un peu de place sur la pile pour mes variables...
		rsset	8
_RSL_NAME		rs.l	1
	rsset	-(9*2+3*4)
_RSL_FSIZE		rs.l	1
_RSL_START		rs.l	1
_RSL_ICONPTRS	rs.l	1
_RSL_HANDLE		rs.w	1
_RSL_TRNBLOC	rs.w	8
		
********************
reloge_ressource_routine
	link	a6,#-(9*2+3*4)
	movem.l	d1-a5,-(sp)
	move.l	d0,_RSL_START(a6)
* reloge les structures 'classiques'
	move.l	d0,a0
	move.l	d0,d6
	moveq	#9,d0
	lea		.Data,a1
.Loop1
	move	(a1)+,d1
	move	(a0,d1.w),d1
	add		(a1)+,d1
	move	(a1)+,d2
	move	(a0,d2.w),d2
	move	(a1)+,d3
	bra.s	.Hop
.Loop2		
	add.l	d6,(a0,d1.w)
	add		d3,d1
.Hop		
	dbf		d2,.Loop2
		
	dbf		d0,.Loop1
		
********************
	move.l	a0,a4
	add.l	_RSL_FSIZE(a6),a4
		
	move	(a0),d0
	btst	#2,d0
	beq		.FixObjects
		
	*------------*
		
; les icones couleur !
	move.l	a0,a1
	add		34(a0),a1
	lea		([a1,4.w],a0.l),a1
		
	move.l	a1,_RSL_ICONPTRS(a6)
	move.l	a1,a3
	moveq	#-2,d0
.Count
	addq.l	#1,d0
	tst.l	(a3)+
	bpl.s	.Count
		
	tst.l	d0
	bmi		.FixObjects
		
		*------------*
		
	move.l	_RSL_ICONPTRS(a6),a1
.YopIcons
; stocke pointeur C_ICONBLK
	move.l	a3,(a1)+
		
; calcul taille d'1 plan en octets
	move	ib_wicon(a3),d1
	addq	#7,d1
	lsr	#3,d1
	mulu	ib_hicon(a3),d1
		
; y'a-t-il plusieurs r‚solutions ?
	move.l	ib_resvd(a3),d2
	subq	#1,d2
	bmi		.EndIcon
		
; calcul pointeurs mono
	lea		ib_resvd+4(a3),a2
	move.l	a2,ib_pdata(a3)
		
	add.l	d1,a2
	move.l	a2,ib_pmask(a3)
		
	add.l	d1,a2
	move.l	a2,ib_ptext(a3)
		
	lea		12(a2),a2
	move.l	a2,ib_resvd(a3)
		
		*------------*
.YopRez
; calcul taille bitmap en n plans
	move	(a2),d3
	mulu	d1,d3
		
	lea		22(a2),a3
	move.l	a3,2(a2)
		
	add.l	d3,a3
	move.l	a3,6(a2)
		
	add.l	d1,a3
		
	tst.l	10(a2)
	beq.s	.NoAnim
		
	move.l	a3,10(a2)
	add.l	d3,a3
	move.l	a3,14(a2)
	add.l	d1,a3
.NoAnim
	tst.l	18(a2)
	beq.s	.EndIcon
		
	move.l	a3,18(a2)
	move.l	a3,a2
		
	dbf		d2,.YopRez
.EndIcon
	dbf	d0,.YopIcons
		
*------------*
; transformation VDI > Hardware
	move	SCREEN_MFDB+mfdb_planes,d0
	cmp	#1,d0
	beq	.FixObjects

	lea	_RSL_TRNBLOC(a6),a0
	move	d0,_TRN_DREZ(a0)

	move.l	_RSL_ICONPTRS(a6),a5
.YopTrn
	move.l	(a5)+,a2
	tst.l	a2
	bmi		.FixObjects
		
	move	ib_wicon(a2),_TRN_W(a0)
	move	ib_hicon(a2),_TRN_H(a0)
		
	move.l	ib_resvd(a2),a3
	tst.l	a3
	beq		.FixObjects
.Color
	move	(a3),d0
	cmp		_TRN_DREZ(a0),d0
	ble.s	.Ok1
		
	moveq	#0,d0
.Ok1
	move.l	a3,a2
.YoColor
	move	(a3),d1
	cmp		_TRN_DREZ(a0),d1
	bgt.s	.Next

	cmp		d1,d0
	bgt.s	.Next

	move	d1,d0
	move.l	a3,a2
.Next
	move.l	18(a3),a3
	tst.l	a3
	bne.s	.YoColor
		
		*------------*
.Convert
	cmp	_TRN_DREZ(a0),d0
	bgt.s	.FixObjects
		
	move	_TRN_W(a0),d1
	addq	#7,d1
	lsr		#3,d1
	mulu	_TRN_DREZ(a0),d1
	mulu	_TRN_H(a0),d1
		
	move	d0,_TRN_SREZ(a0)
	move.l	2(a2),_TRN_SMAP(a0)
	move.l	a4,_TRN_DMAP(a0)

	pea		(a0)
	jsr		_TRNF_HARD

	move	_TRN_DREZ(a0),(a2)
	move.l	a4,2(a2)

	add.l	d1,a4

	tst.l	10(a2)
	beq.s	.YopTrn

	move.l	10(a2),_TRN_SMAP(a0)
	move.l	a4,_TRN_DMAP(a0)

	pea		(a0)
	jsr		_TRNF_HARD

	move.l	a4,10(a2)
	add.l	d1,a4

	bra		.YopTrn
		
		****************
.FixObjects
	move.l	a4,a2
	move.l	_RSL_START(a6),a0
	move.l	_RSL_ICONPTRS(a6),a5
	move.l	a0,a1
	move.l	a0,d6

; reloge objets (ob_spec)

	add		2(a1),a1
	move	20(a0),d0

	subq	#1,d0
.ObjLoop		
	moveq	#$7f,d1
	and		OB_TYPE(a1),d1
	sub		#20,d1

	jmp		([.FIX_TABLE.w,pc,d1.w*4])
		
		****************
.FIX_GBOX
	bra		.fix_xywh
.FIX_GTEXT
	move.l	ob_spec(a1),a3
	add.l	d6,a3
	clr		te_resvd1(a3)
	clr		te_resvd2(a3)
	move.l	a3,ob_spec(a1)
	bra.s	.fix_xywh
.FIX_GBOXTEXT
	move.l	ob_spec(a1),a3
	add.l	d6,a3
	clr		te_resvd1(a3)
	clr		te_resvd2(a3)
	move.l	a3,ob_spec(a1)
	bra.s	.fix_xywh
.FIX_GIMAGE
	add.l	d6,ob_spec(a1)
	bra.s	.fix_xywh
.FIX_GUSERDEF
	add.l	d6,ob_spec(a1)
	move.l	#X_OBJECTS,([a1,ob_spec.w])
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
	clr		te_resvd1(a3)
	clr		te_resvd2(a3)
	move.l	a3,ob_spec(a1)
	bra.s	.fix_xywh
.FIX_GFBOXTEXT
	move.l	ob_spec(a1),a3
	add.l	d6,a3
	clr		te_resvd1(a3)
	clr		te_resvd2(a3)
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
	bra.s	.fix_xywh

		****************
.fix_xywh
	clr		d2
	clr		d3
	move.b	OB_X+0(a1),d2
	move.b	OB_X+1(a1),d3
	lsl		#3,d3
	add		d2,d3
	move	d3,OB_X(a1)

	clr		d2
	clr		d3
	move.b	OB_Y+0(a1),d2
	move.b	OB_Y+1(a1),d3
	lsl		#4,d3
	add		d2,d3
	move	d3,OB_Y(a1)

	clr		d2
	clr		d3
	move.b	OB_W+0(a1),d2
	move.b	OB_W+1(a1),d3
	lsl		#3,d3
	add		d2,d3
	move	d3,OB_W(a1)

	clr		d2
	clr		d3
	move.b	OB_H+0(a1),d2
	move.b	OB_H+1(a1),d3
	lsl		#4,d3
	add		d2,d3
	move	d3,OB_H(a1)

	lea		24(a1),a1

	dbf		d0,.ObjLoop

****************
	move.l	_RSL_START(a6),d6
	sub.l	d6,a2

	move.l	a2,-(sp)
	move.l	d6,-(sp)
	clr		-(sp)
	GEM		MSHRINK

	move.l	d6,d0
****************
.End
	movem.l	(sp)+,d1-a5
	unlk	a6
	rtd	#4
****************
.FileError:
	move.l	#.Erreur1,_A_ADDRIN
	move	#1,_A_INTIN
	AES	FORM_ALERT

	moveq	#-1,d0
	bra		.End
****************
.MemoryError
	move	#8,_A_INTIN
	AES	FORM_ERROR

	moveq	#-2,d0
	bra		.End

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
********************************************************************
