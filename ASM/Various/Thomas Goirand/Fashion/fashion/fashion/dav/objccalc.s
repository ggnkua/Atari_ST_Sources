****************************************************************
		
		****
		
		; aes_objc_calc (object,array)
		; calcule les dimensions d'un objet
		
		; object: pointeur sur objet aes
		; array: pointeur sur tableau de retour (8 short)
		
		; (cf. vq_extent)
		
		****
		
		rsset	8
_oca_obj		rs.l	1
_oca_array	rs.l	1
		
		****
AesObjcCalc
		link	a6,#0
		movem.l	d0-d5/a0-a4,-(sp)
		
		move.l	_oca_obj(a6),a0
		
		****
		
		; il faut retrouver les paramŠtres
		; du cadre selon le type d'objet...
		
		moveq	#0,d0
		move.b	ob_type+1(a0),d0
		sub.w	#20,d0
		
		jsr	([.get_spec.w,pc,d0.w*4])
		
		; retour des paramŠtres en d4
		
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		
		; calcul x2,y2
		
		move.w	ob_w(a0),d2
		subq.w	#1,d2
		
		move.w	ob_h(a0),d3
		subq.w	#1,d3
		
		move.w	d0,a1
		move.w	d1,a2
		move.w	d2,a3
		move.w	d3,a4
		
		; %100=fond3d %110=activateur %010=indicateur
		
		moveq	#%110,d5
		and.b	ob_flags(a0),d5
		beq.s	.no_3d
		
		subq	#%100,d5
		beq	.no_3d
		
		; petit ajustement 3d
		
		subq.w	#2,d0
		subq.w	#2,d1
		addq.w	#2,d2
		addq.w	#2,d3
.no_3d
		****
		
		; calcul pour le cadre
		
		tst.w	d4
		beq.s	.cadre_nul
		bmi.s	.cadre_ext
.cadre_int
		add.w	d4,a1
		sub.w	d4,a3
		add.w	d4,a2
		sub.w	d4,a4
		bra.s	.cadre_ok
.cadre_ext
		add.w	d4,d0
		add.w	d4,d1
		sub.w	d4,d2
		sub.w	d4,d3
.cadre_ok
		****
.cadre_nul
		; teste si effet 'outline'
		
		btst.b	#4,ob_state+1(a0)
		beq.s	.ok_cadre
		
		; si le cadre est interne on clippe 
		; sur l'effet 'outline' et si le cadre
		; est externe ET plus ‚pais on clippe sur
		; celui-ci ...
		
		moveq	#4,d5
		add.w	d4,d5
		bmi.s	.ok_cadre
		
		subq.w	#2,d0
		subq.w	#2,d1
		addq.w	#2,d2
		addq.w	#2,d3
.ok_cadre
		****
		
		; coordonn‚es internes dans a1-a4
		; coordonn‚es externes dans d0-d3
		
		move.l	_oca_array(a6),a0
		movem.w	d0-d3/a1-a4,(a0)
		
		****
.fin
		movem.l	(sp)+,d0-d5/a0-a4
		unlk	a6
		rts
		
		****
		****
.get_spec:
		dc.l	.cas_1	; gbox
		dc.l	.cas_2	; gtext
		dc.l	.cas_2	; gboxtext
		dc.l	.cas_3	; gimage
		dc.l	.cas_3	; guserdef
		dc.l	.cas_1	; gibox
		dc.l	.cas_4	; gbutton
		dc.l	.cas_1	; gboxchar
		dc.l	.cas_3	; gstring
		dc.l	.cas_2	; gftext
		dc.l	.cas_2	; gfboxtext
		dc.l	.cas_3	; gicon
		dc.l	.cas_3	; gtitle
		dc.l	.cas_3	; gcicon
		dc.l	.cas_3	; gbounding
		dc.l	.cas_3	; gbounded
		dc.l	.cas_3	; gpix
		dc.l	.cas_3	; gline
		dc.l	.cas_3	; gcheck
		
		****
		
		; cas #1
		; lecture cadre depuis l'obspec
.cas_1
		move.b	ob_spec+1(a0),d4
		extb.l	d4
		
		rts
		
		****
		
		; cas #2
		; lecture cadre depuis ted-info
.cas_2
		move.w	([ob_spec.w,a0],te_thickness.w),d4
		ext.l	d4
		rts
		
		****
		
		; cas #3
		; pas de cadre
.cas_3		
		moveq	#0,d4
		rts
		
		****
		
		; cas #4
		; cadre implicite du bouton standard
.cas_4
		moveq	#-1,d4
		rts		
		
		****
	
********************************************************************
