********************************************************************
		TEXT
********************************************************************
		
		********
		
		; fonction de gestion des champs ‚ditables
		; de bas niveau ...
		
		; parametres:
		; Addrin[0] => adresse de l'arbre contenant le champ
		; Intin[0]  => index du champ dans l'arbre
		; Intin[1]  => caractŠre … prendre en compte
		; Intin[2]  => index courant (-1=auto)
		; Intin[3]  => type d'op‚ration
		
		; retour:
		; Intout[0] => 0=erreur
		; Intout[1] => nouvel index courant
		
		********
AesObjcEdit:
		movem.l	d0-a6,-(sp)
		
		moveq	#0,d0
		move.w	_A_INTIN+3*2,d0
		
		subq	#1,d0
		beq.s	.EdInit
		subq	#1,d0
		beq	.EdChar
		subq	#1,d0
		beq.s	.EdEnd
		
		********
.EdInit
		move.l	_A_ADDRIN,a0
		move.w	_A_INTIN,d0
		bmi	.End
		
		mulu.w	#24,d0
		lea	(a0,d0.l),a0
		
;		cmp.b	#G_FTEXT,ob_type+1(a0)
;		beq.s	.ok_editable
;		cmp.b	#G_FBOXTEXT,ob_type+1(a0)
;		bne	.End

;.Ok_editable

		move.l	ob_spec(a0),a1
		
		btst.b	#0,ob_flags+1(a0)
		beq.s	.Direct1
		
		move.l	(a1),a1
.Direct1
		bset.b	#7,te_resvd1(a1)		; ! Utilisation zarb des bits

		move.w	#1,_A_INTOUT
		move.w	te_resvd1(a1),_A_INTOUT+2
		bra	.End
		
		********
.EdEnd
		move.l	_A_ADDRIN,a0
		move.w	_A_INTIN,d0
		bmi	.End
		
		mulu.w	#24,d0
		lea	(a0,d0.l),a0
		
		move.l	ob_spec(a0),a1
		
		btst.b	#0,ob_flags+1(a0)
		beq.s	.Direct2
		
		move.l	(a1),a1
.Direct2
		bclr.b	#7,te_resvd1(a1)
		
		move.w	#3,_A_INTOUT
		move.w	te_resvd1(a1),_A_INTOUT+2
		bra	.End
		
		********************
.EdChar
		move.l	_A_ADDRIN,a0
		move.w	_A_INTIN,d0
		bmi	.End
		
		move	d0,d1
		add	d0,d1
		add	d0,d1
		lea	(a0,d1.w*8),a0
		
		btst.b	#0,ob_flags(a0)
		beq.s	.Direct3
		
		move.l	([ob_spec.w,a0]),a1
		bra.s	.OkSpec3
.Direct3
		move.l	ob_spec(a0),a1
.OkSpec3
		movem.l	te_ptext(a1),a2/a3/a4
		
		move	te_txtlen(a1),d5
		subq	#2,d5
		
		move	_A_INTIN+2,d3
		tst.b	d3
		beq	.Error
		
		move.l	a3,a5
		moveq	#0,d4
		
		move	_A_INTIN+4,d1
		bpl.s	.Tmplt1
		
		move	te_resvd1(a1),d1
		and	#$7fff,d1
.Tmplt1	
		move.b	(a5)+,d2
		beq.s	.EndTmplt
		cmp.b	#"_",d2
		bne.s	.NotUscore
		addq	#1,d4
.NotUscore
		cmp.b	d3,d2
		bne.s	.Tmplt1
		
		cmp	d1,d4
		ble.s	.Tmplt1
		
		move	te_resvd1(a1),d2
		and	#$8000,d2
		or	d4,d2
		move	d2,te_resvd1(a1)
		
		lea	(a2,d1.w),a5
		subq	#1,d4
.Tmplt2
		move.b	#" ",(a5)+
		dbf	d4,.Tmplt2
.EndTmplt
		********************
		
		move.b	(a4,d1.w),d2
		
		cmp.b	#"9",d2
		beq	.Cas1
		cmp.b	#"A",d2
		beq	.Cas2
		cmp.b	#"a",d2
		beq	.Cas3
		cmp.b	#"N",d2
		beq	.Cas4
		cmp.b	#"n",d2
		beq	.Cas5
		cmp.b	#"F",d2
		beq	.Cas6
		cmp.b	#"P",d2
		beq	.Cas7
		cmp.b	#"p",d2
		beq	.Cas8
		cmp.b	#"X",d2
		beq	.OkChar
		cmp.b	#"x",d2
		beq	.OkChar
		
		bra	.End
		
		*------------*
.Cas1		
		cmp.b	#"0",d3
		blt	.End
		
		cmp.b	#"9",d3
		ble	.OkChar
		
		bra	.End
		
		*------------*
.Cas2
		cmp.b	#" ",d3
		beq	.OkChar
		
		cmp.b	#"A",d3
		blt	.End
		
		cmp.b	#"Z",d3
		bgt	.End
		
		bra	.OkChar
		
		*------------*
.Cas3
		cmp.b	#" ",d3
		beq	.OkChar
		
		cmp.b	#"A",d3
		blt	.End
		
		cmp.b	#"Z",d3
		ble	.OkChar
		
		cmp.b	#"a",d3
		blt	.End
		
		cmp.b	#"z",d3
		bgt	.End
		
		bra	.OkChar
		
		*------------*
.Cas4
		cmp.b	#" ",d3
		beq	.OkChar
		
		cmp.b	#"0",d3
		blt	.End
		
		cmp.b	#"Z",d3
		bgt	.End
		
		cmp.b	#"A",d3
		bge	.OkChar
		
		cmp.b	#"9",d3
		ble	.OkChar
		
		bra	.End
		
		*------------*
.Cas5
		cmp.b	#" ",d3
		beq	.OkChar
		
		cmp.b	#"0",d3
		blt	.End
		
		cmp.b	#"z",d3
		bgt	.End
		
		cmp.b	#"a",d3
		bge	.OkChar
		
		cmp.b	#"Z",d3
		bgt	.End
		
		cmp.b	#"A",d3
		bge	.OkChar
		
		cmp.b	#"9",d3
		ble	.OkChar
		
		bra	.End
		
		*------------*
.Cas6
		
		*------------*
.Cas7
		
		*------------*
.Cas8
		
		*------------*
.OkChar:
		cmp	d1,d5
		bgt.s	.GoWrite
		move.b	d3,(a2,d1.w)
		bra.s	.End
.GoWrite
		addq	#1,d1
		move	d1,_A_INTOUT+2
		
		move	te_resvd1(a1),d2
		and	#$8000,d2
		or	d1,d2
		move	d2,te_resvd1(a1)
		
		tst.b	_FLAG_INSERT
		bne.s	.ModeInsert
		
		move.b	d3,-1(a2,d1.w)
		bra	.End
.ModeInsert
		lea	(a2,d5.w),a5
		lea	1(a5),a4
		sub	d1,d5
.Copy
		move.b	-(a5),-(a4)
		dbf	d5,.Copy
		
		move.b	d3,-1(a2,d1.w)

		move	#2,_A_INTOUT
		
		********************
.End		
		movem.l	(sp)+,d0-a6
		rts
		
		********************
.Error
		clr.l	_A_INTOUT
		bra	.End
		
		********************
		SECTION DATA
		********************

_FLAG_INSERT	dc.b	$ff
		even

		********************
		
********************************************************************
		
		********************
		
		; fonction g‚rant les touches sp‚ciales
		; pour les champs ‚ditables...
		
		; parametres:
		; LONG: Pointeur sur la structure du formulaire
		;       contenant le champ ‚ditable courant...
		; WORD: code clavier + code ascii de la touche.
		
		; retour d0.l:
		; -1 => la touche n'‚tait pas sp‚ciale
		; -2 => aucun changement produit
		;  0 => R.A.S.
		; >0 => index du nouveau champ courant
		
		********************
		
		rsset	8
_EOK_KEY		rs.w	1
_EOK_FORM		rs.l	1
		
		********************
_EDOBJ_KEYS:
		link	a6,#0
		movem.l	d1-a5,-(sp)
		
		move.l	_EOK_FORM(a6),a0
		
		move	_FRM_NEDIT(a0),d0
		move	d0,d1
		add	d0,d1
		add	d0,d1
		
		lea	([_FRM_TREE,a0],d1.w*8),a0
		
		btst.b	#0,ob_flags(a0)
		beq.s	.Direct3
		
		move.l	([ob_spec.w,a0]),a1
		bra.s	.OkSpec3
.Direct3
		move.l	ob_spec(a0),a1
.OkSpec3
		********************
		
		move	_EOK_KEY(a6),d4
		lsr	#8,d4
		
		cmp.b	#$e,d4
		beq	.Backspace
		
		cmp.b	#$53,d4
		beq	.Delete
		
		cmp.b	#$52,d4
		beq	.Insert
		
		cmp.b	#$4b,d4
		beq	.Left
		
		cmp.b	#$4d,d4
		beq	.Right
		
		cmp.b	#$1,d4
		beq	.Escape
		
		cmp.b	#$48,d4
		beq	.FindPrev
		
		cmp.b	#$50,d4
		beq	.FindNext
		
		cmp.b	#$f,d4
		beq	.FindNext
		
		moveq	#-1,d0
		
		********************
.Exit:
		movem.l	(sp)+,d1-a5
		unlk	a6
		rtd	#6
		
		********************
.Insert
		not.b	_FLAG_INSERT
		moveq	#-2,d0
		bra	.Exit
		
		********************
.FindPrev
		move	d0,d1
.Prv1
		subq	#1,d1
		beq.s	.NoPrev
		
		lea	-24(a0),a0
		
		btst.b	#3,ob_flags+1(a0)
		beq.s	.Prv1
		
		bclr.b	#7,te_resvd1(a1)
		
		btst.b	#0,ob_flags(a0)
		beq.s	.Prv2
		
		move.l	([ob_spec.w,a0]),a1
		bra.s	.Prv3
.Prv2
		move.l	ob_spec(a0),a1
.Prv3
		bset.b	#7,te_resvd1(a1)
		
		clr.l	d0
		move	d1,d0
		bra	.Exit
.NoPrev		
		moveq	#-2,d0
		bra	.Exit
		
		********************
.FindNext
		move	d0,d1
.Nxt1
		btst.b	#5,ob_flags+1(a0)
		bne.s	.NoNxt
		
		addq	#1,d1
		lea	24(a0),a0
		
		btst.b	#3,ob_flags+1(a0)
		beq.s	.Nxt1
		
		bclr.b	#7,te_resvd1(a1)
		
		btst.b	#0,ob_flags(a0)
		beq.s	.Nxt2
		
		move.l	([ob_spec.w,a0]),a1
		bra.s	.Nxt3
.Nxt2
		move.l	ob_spec(a0),a1
.Nxt3
		bset.b	#7,te_resvd1(a1)
		
		clr.l	d0
		move	d1,d0
		bra	.Exit
.NoNxt
		moveq	#-2,d0
		bra	.Exit
		
		********************
.Delete
		move.l	te_ptext(a1),a2
		
		move	te_resvd1(a1),d1
		and	#$7fff,d1
		
		lea	(a2,d1.w),a5
		tst.b	(a5)
		bne.s	.OkDel
		
		moveq	#-2,d0
		bra	.Exit
.OkDel		
		lea	1(a5),a4
.Del1
		move.b	(a4)+,(a5)+
		bne.s	.Del1
		
		moveq	#0,d0
		bra	.Exit
		
		********************
.Backspace
		move.l	te_ptext(a1),a2
		
		move	te_resvd1(a1),d1
		move	d1,d2
		and	#$7fff,d1
		bne.s	.OkBak
		
		moveq	#-2,d0
		bra	.Exit
.OkBak		
		lea	(a2,d1.w),a5
		lea	-1(a5),a4
.Back1
		move.b	(a5)+,(a4)+
		bne.s	.Back1
		
		subq	#1,d1
		and	#$8000,d2
		or	d1,d2
		move	d2,te_resvd1(a1)
		
		moveq	#0,d0
		bra	.Exit
		
		********************
.Left
		move	te_resvd1(a1),d1
		move	d1,d2
		and	#$7fff,d1
		bne.s	.OkLeft
		
		moveq	#-2,d0
		bra	.Exit
.okLeft		
		subq	#1,d1
		
		and	#$8000,d2
		or	d1,d2
		move	d2,te_resvd1(a1)
		
		moveq	#0,d0
		bra	.Exit
		
		********************
.Right
		move	te_resvd1(a1),d1
		move	d1,d2
		and	#$7fff,d1
		
		move.l	te_ptext(a1),a2
		tst.b	(a2,d1.w)
		bne.s	.OkRight
		
		moveq	#-2,d0
		bra	.Exit
.OkRight		
		move	te_txtlen(a1),d5
		subq	#2,d5
		
		addq	#1,d1
		cmp	d1,d5
		bge.s	.DoRight
		
		moveq	#-2,d0
		bra	.Exit
.DoRight		
		and	#$8000,d2
		or	d1,d2
		move	d2,te_resvd1(a1)
		
		moveq	#0,d0
		bra	.Exit
		
		********************
.Escape
		move	te_txtlen(a1),d5
		subq	#2,d5
		
		move.l	te_ptext(a1),a2
		
		and	#$8000,te_resvd1(a1)
.Esc1
		clr.b	(a2)+
		dbf	d5,.Esc1
		
		moveq	#0,d0
		bra	.Exit

		********************

********************************************************************
		