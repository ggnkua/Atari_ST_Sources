***************************************************************************
		SECTION TEXT
***************************************************************************

	************************************


		****************
		
		; l'appel "_TRN_GETNEXT" renvoie dans d5
		; lindex de couleur du pixel courant pour les
		; bitmaps indexes ...
		
		; NB: cette sous-routine se charge d'arreter
		; au bon moment !
		
		; l'appel "_TRN_PUTNEXT" prend dans d5.w l'index
		; de couleur du pixel … ‚crire dans le MF' cible
		; et est synchronis‚ avec le pr‚c‚dent...
		
		****************

		; routine d'exemple ...
TramageMode0:

		; lisons un pixel
.NextPixel
		jsr	([_TRN_GETNEXT.w,a6])
		
		****************
		
		nop
		
		****************
		
		; ‚crivons le pixel dans la cible
		
		jsr	([_TRN_PUTNEXT.w,a6])
		
		; et on recommence betement vu que 'GETNEXT'
		; stopera le travail de lui meme :-)
		
		bra	.NextPixel

		****************


	************************************

***************************************************************************

	************************************
		
		****************

		; niveaux de gris sans diffusion ...
		; attention la palette destination sera ‚cras‚e
		
		****************
TramageMode1:
		; construction de la palette cible en gris
		
		move.l	a5,-(sp)
		
		move	_TRN_DCOLNUM(a6),d0
		lea	([_TRN_DPAL,a6],d0.w*4),a5
		
		move.l	#256,d1
		divu.w	d0,d1
		
		move.w	#255,d2
.yo_pal
		move.b	d2,-(a5)
		subq	#1,a5
		move.b	d2,-(a5)
		move.b	d2,-(a5)
		
		sub.w	d1,d2
		bpl.s	.yo_pal
		
		move.l	(sp)+,a5
		
		; la source est-elle ind‚x‚e ou truecolor ??
		
		cmp	#16,mfdb_planes(a5)
		blt.s	.index‚
		
	************************************
		
		****************
		
		; … la diff‚rence des modes index‚s
		; les modes tc sortent r/v/b en d0/d1/d2
		
.truecolor
		move	mfdb_planes(a4),d0
		
		cmp	#8,d0
		beq	.true_to_256
		cmp	#4,d0
		beq	.true_to_16
		
		
		****************
.true_to_16
		jsr	([_TRN_GETNEXT.w,a6])
		
		clr.l	d5
		
		add.w	d0,d5
		add.w	d1,d5
		add.w	d2,d5
		
		divu.w	#48,d5
		
		jsr	([_TRN_PUTNEXT.w,a6])
		
		bra.s	.true_to_16
		
		****************
.true_to_256
		jsr	([_TRN_GETNEXT.w,a6])
		
		clr.l	d5
		
		add.w	d0,d5
		add.w	d1,d5
		add.w	d2,d5
		
		divu.w	#3,d5
		
		jsr	([_TRN_PUTNEXT.w,a6])
		
		bra.s	.true_to_256
		
		****************
	
	************************************
		
		; les modes index‚s sortent l'index de couleur en d5
		
		****************
.index‚
		jsr	([_TRN_GETNEXT.w,a6])
		
		****************
		
		movem.l	d6/d7/a5,-(sp)
		
		lea	([_TRN_SPAL,a6],d5.w*4),a5
		
		clr.l	d6
		clr.l	d7
		move.b	(a5),d6
		move.b	1(a5),d7
		add	d7,d6
		move.b	3(a5),d7
		add	d7,d6
		
		divu	#48,d6
		
		move	d6,d5
		
		movem.l	(sp)+,d6/d7/a5
		
		****************
		
		; ‚crivons le pixel dans la cible
		
		jsr	([_TRN_PUTNEXT.w,a6])
		
		; et on recommence betement vu que 'GETNEXT'
		; stopera le travail de lui meme :-)
		
		bra	.index‚

		****************


	************************************

***************************************************************************
***************************************************************************

	************************************
		
		****************

		; tramage d'aprŠs la palette de destination
		; sans diffusion d'erreur ...
		
		****************
TramageMode2:
		; la source est-elle ind‚x‚e ou truecolor ??
		
		cmp	#16,mfdb_planes(a5)
		blt	.index‚
		
	************************************
		
		****************
		
		; … la diff‚rence des modes index‚s
		; les modes tc sortent r/v/b en d0/d1/d2
		
		****************
.truecolor
		move.l	#$10000000,d0
		clr.l	d1
		clr.l	d2
		
		jsr	([_TRN_GETNEXT.w,a6])
		
		****
		
		movem.l	d0-4/d6-7/a5,-(sp)
		
		move	_TRN_DCOLNUM(a6),d7
		move.l	_TRN_DPAL(a6),a5
		
		****
.loop
		clr.w	d3
		move.b	(a5),d3
		clr.w	d4
		move.b	1(a5),d4
		clr.w	d5
		move.b	3(a5),d5
		
		addq	#4,a5
		
		****
		
		sub.w	d0,d3
		bpl.s	.posr
		neg.w	d3
.posr
		sub.w	d1,d4
		bpl.s	.posv
		neg.w	d4
.posv
		sub.w	d2,d5
		bpl.s	.posb
		neg.w	d5
.posb
		****
		
		swap	d0
		swap	d1
		swap	d2
		
		clr	d6
		add	d0,d6
		add	d1,d6
		add	d2,d6
		sub	d3,d6
		sub	d4,d6
		sub	d5,d6
		
		bmi.s	.ngco
		
		move	d3,d0
		move	d4,d1
		move	d5,d2
		swap	d6
		move	_TRN_DCOLNUM(a6),d6
		sub	d7,d6
		swap	d6
.ngco
		swap	d0
		swap	d1
		swap	d2
		
		subq	#1,d7
		bne.s	.loop
		
		swap	d6
		move	d6,d5
		
		movem.l	(sp)+,d0-4/d6-7/a5
		
		****************
		
		jsr	([_TRN_PUTNEXT.w,a6])
		
		bra	.truecolor
		
		****************
	
	************************************
		
		; les modes index‚s sortent l'index de couleur en d5
		
		****************
.index‚
		movem.l	d0-a6,-(sp)
		
		move.l	_TRN_SPAL(a6),a5
		move.l	_TRN_WRKSPC(a6),a3
		move	_TRN_SCOLNUM(a6),d7
.sloop
		move.l	#$00ff0000,d0
		move.l	d0,d1
		move.l	d1,d2
		moveq	#0,d6
		
		move.b	(a5)+,d0
		move.b	(a5)+,d1
		addq	#1,a5
		move.b	(a5)+,d2
		
		move.l	_TRN_DPAL(a6),a4
		swap	d7
		move	_TRN_DCOLNUM(a6),d7
.dloop
		clr.l	d3
		clr.l	d4
		clr.l	d5
		
		move.b	(a4)+,d3
		move.b	(a4)+,d4
		addq	#1,a4
		move.b	(a4)+,d5
		
		sub.w	d0,d3
		bpl.s	.posdr
		neg.w	d3
.posdr
		sub.w	d1,d4
		bpl.s	.posdv
		neg.w	d4
.posdv
		sub.w	d2,d5
		bpl.s	.posdb
		neg.w	d5
.posdb
		swap	d0
		swap	d1
		swap	d2
		
		clr	d6
		add	d0,d6
		add	d1,d6
		add	d2,d6
		sub	d3,d6
		sub	d4,d6
		sub	d5,d6
		
		bmi.s	.ngc
		
		move	d3,d0
		move	d4,d1
		move	d5,d2
		swap	d6
		move	_TRN_DCOLNUM(a6),d6
		sub	d7,d6
		swap	d6
.ngc
		swap	d0
		swap	d1
		swap	d2
		
		subq	#1,d7
		bne.s	.dloop
		
		swap	d6
		move	d6,(a3)+
		
		swap	d7
		subq	#1,d7
		bne.s	.sloop
		
		movem.l	(sp)+,d0-a6
		
		****************
.idx_loop		
		jsr	([_TRN_GETNEXT.w,a6])
		
		move	([_TRN_WRKSPC,a6],d5.w*2),d5
		
		jsr	([_TRN_PUTNEXT.w,a6])
		
		bra.s	.idx_loop

		****************


	************************************

***************************************************************************
***************************************************************************

	************************************
		
		****************

		; avec palette id‚ale sans diffusion ...
		
		****************
TramageMode3:
		
		; la source est-elle ind‚x‚e ou truecolor ??
		
		cmp	#16,mfdb_planes(a5)
		blt	.index‚
		
	************************************
		
		****************
		
		; … la diff‚rence des modes index‚s
		; les modes tc sortent r/v/b en d0/d1/d2
		
.truecolor
		; construction de la palette id‚ale
		
		movem.l	d0-a6,-(sp)
		
		move.l	_TRN_DPAL(a6),a5
		lea		_SYS_DAC,a4
		
		rept	16
		move.l	(a4)+,(a5)+
		endr
		
		moveq	#10,d1
		
		moveq	#23,d0
.yogri		
		move.b	d1,(a5)+
		move.b	d1,(a5)+
		addq	#1,a5
		move.b	d1,(a5)+
		
		add	#10,d1
		dbf	d0,.yogri
		
		moveq	#0,d0
		moveq	#5,d3
.cloop1		
		moveq	#0,d1
		moveq	#5,d4
.cloop2		
		moveq	#0,d2
		moveq	#5,d5
.cloop3		
		move.b	d0,(a5)+
		move.b	d1,(a5)+
		addq	#1,a5
		move.b	d2,(a5)+
		
		add	#51,d2
		dbf	d5,.cloop3
		
		add	#51,d1
		dbf	d4,.cloop2
		
		add	#51,d0
		dbf	d3,.cloop1
		
		clr.l	-4(a5)
		
		movem.l	(sp)+,d0-a6
		
		****************
.trueloop
		move.l	#$00ff0000,d0
		move.l	#$00ff0000,d1
		move.l	#$00ff0000,d2
		
		****************
		
		jsr	([_TRN_GETNEXT.w,a6])
		
		****************
		
		movem.l	d0-4/d6-7/a5,-(sp)
		move	_TRN_DCOLNUM(a6),d7
		move.l	_TRN_DPAL(a6),a5
.loop
		clr.l	d3
		clr.l	d4
		clr.l	d5
		
		move.b	(a5)+,d3
		move.b	(a5)+,d4
		addq	#1,a5
		move.b	(a5)+,d5
		
		sub.w	d0,d3
		bpl.s	.posr
		neg.w	d3
.posr
		sub.w	d1,d4
		bpl.s	.posv
		neg.w	d4
.posv
		sub.w	d2,d5
		bpl.s	.posb
		neg.w	d5
.posb
		swap	d0
		swap	d1
		swap	d2
		
		clr	d6
		add	d0,d6
		add	d1,d6
		add	d2,d6
		sub	d3,d6
		sub	d4,d6
		sub	d5,d6
		
		bmi.s	.ngco
		
		move	d3,d0
		move	d4,d1
		move	d5,d2
		swap	d6
		move	_TRN_DCOLNUM(a6),d6
		sub	d7,d6
		swap	d6
.ngco
		swap	d0
		swap	d1
		swap	d2
		
		subq	#1,d7
		bne.s	.loop
		
		swap	d6
		move	d6,d5
		
		movem.l	(sp)+,d0-4/d6-7/a5
		
		****************
		
		jsr	([_TRN_PUTNEXT.w,a6])
		
		bra	.trueloop
		
		****************
	
	************************************
		
		; les modes index‚s sortent l'index de couleur en d5
		
		****************
.index‚
		movem.l	d0-a6,-(sp)
		
		move.l	_TRN_SPAL(a6),a5
		move.l	_TRN_WRKSPC(a6),a3
		move	_TRN_SCOLNUM(a6),d7
.sloop
		move.l	#$00ff0000,d0
		move.l	d0,d1
		move.l	d1,d2
		moveq	#0,d6
		
		move.b	(a5)+,d0
		move.b	(a5)+,d1
		addq	#1,a5
		move.b	(a5)+,d2
		
		move.l	_TRN_DPAL(a6),a4
		swap	d7
		move	_TRN_DCOLNUM(a6),d7
.dloop
		clr.l	d3
		clr.l	d4
		clr.l	d5
		
		move.b	(a4)+,d3
		move.b	(a4)+,d4
		addq	#1,a4
		move.b	(a4)+,d5
		
		sub.w	d0,d3
		bpl.s	.posdr
		neg.w	d3
.posdr
		sub.w	d1,d4
		bpl.s	.posdv
		neg.w	d4
.posdv
		sub.w	d2,d5
		bpl.s	.posdb
		neg.w	d5
.posdb
		swap	d0
		swap	d1
		swap	d2
		
		clr	d6
		add	d0,d6
		add	d1,d6
		add	d2,d6
		sub	d3,d6
		sub	d4,d6
		sub	d5,d6
		
		bmi.s	.ngc
		
		move	d3,d0
		move	d4,d1
		move	d5,d2
		swap	d6
		move	_TRN_DCOLNUM(a6),d6
		sub	d7,d6
		swap	d6
.ngc
		swap	d0
		swap	d1
		swap	d2
		
		subq	#1,d7
		bne.s	.dloop
		
		swap	d6
		move	d6,(a3)+
		
		swap	d7
		subq	#1,d7
		bne.s	.sloop
		
		movem.l	(sp)+,d0-a6
		
		****************
.idx_loop		
		jsr	([_TRN_GETNEXT.w,a6])
		
		move	([_TRN_WRKSPC,a6],d5.w*2),d5
		
		jsr	([_TRN_PUTNEXT.w,a6])
		
		bra.s	.idx_loop

		****************


	************************************

***************************************************************************
***************************************************************************
***************************************************************************

	************************************
		
		****************

		; floyd-steinberg avec palette avec diffusion stricte ...
		
		****************
TramageMode4:
		
		; la source est-elle ind‚x‚e ou truecolor ??
		
		cmp	#16,mfdb_planes(a5)
		blt	.index‚
		
	************************************
		
		****************
		
		; … la diff‚rence des modes index‚s
		; les modes tc sortent r/v/b en d0/d1/d2
.truecolor
		****************
		
		move.l	_TRN_WRKSPC(a6),a5
		
		move.l	a5,_TRN_PTR1(a6)
		clr.w	(a5)+
		clr.w	(a5)+
		clr.w	(a5)+
		move.l	a5,_TRN_PTR2(a6)
		
		move	#1024,d0
.clr_yop
		clr.l	(a5)+
		clr.l	(a5)+
		clr.l	(a5)+
		
		subq	#1,d0
		bne.s	.clr_yop
		
		move.l	a5,_TRN_PTR3(a6)
		
		move.l	_TRN_PTR2(a6),_TRN_PTR4(a6)
		move.l	_TRN_PTR3(a6),_TRN_PTR5(a6)
		
		addq.l	#6,_TRN_PTR2(a6)
		
		****************
.trueloop
		move.l	#$10000000,d0
		move.l	d0,d1
		move.l	d1,d2
		
		; lecture du pixel … traiter
		
		jsr	([_TRN_GETNEXT.w,a6])
		
		****************
		
		movem.l	d0-4/d6-7/a5,-(sp)
		
		; prise en compte de l'erreur diffuse de gauche
		
		move.l	_TRN_PTR1(a6),a5
		add	(a5)+,d0
		add	(a5)+,d1
		add	(a5),d2
		
		; prise en compte de l'erreur diffuse d'au dessus
		
		move.l	_TRN_PTR2(a6),a5
		add	(a5)+,d0
		add	(a5)+,d1
		add	(a5)+,d2
		move.l	a5,_TRN_PTR2(a6)
		
		move	_TRN_DCOLNUM(a6),d7
		move.l	_TRN_DPAL(a6),a5
		
		clr.l	d6
.loop
		clr	d3
		move.b	(a5),d3
		clr	d4
		move.b	1(a5),d4
		clr	d5
		move.b	3(a5),d5
		
		addq	#4,a5
		
		sub.w	d0,d3
		bpl.s	.posr
		neg.w	d3
.posr
		sub.w	d1,d4
		bpl.s	.posv
		neg.w	d4
.posv
		sub.w	d2,d5
		bpl.s	.posb
		neg.w	d5
.posb		
		swap	d0
		swap	d1
		swap	d2
		
		clr	d6
		add	d0,d6
		add	d1,d6
		add	d2,d6
		sub	d3,d6
		sub	d4,d6
		sub	d5,d6
		
		bmi.s	.ngco
		
		move	d3,d0
		move	d4,d1
		move	d5,d2
		swap	d6
		move	_TRN_DCOLNUM(a6),d6
		sub	d7,d6
		swap	d6
.ngco
		swap	d0
		swap	d1
		swap	d2
		
		subq	#1,d7
		bne.s	.loop
		
		swap	d6
		
		; calcul de l'erreur sign‚e
		
		lea	([_TRN_DPAL,a6],d6*4),a5
		
		clr.w	d3
		move.b	0(a5),d3
		sub.w	d3,d0
		
		clr.w	d4
		move.b	1(a5),d4
		sub.w	d4,d1
		
		clr.w	d5
		move.b	3(a5),d5
		sub.w	d5,d2
		
		; diffusion de l'erreur d'approximation
		
		; diffusion horizontale de 7/16 (rouge)
		
		move.l	_TRN_PTR1(a6),a5
		
		move.w	d0,d7
		muls.w	#7,d7
		asr.w	#4,d7
		move.w	d7,(a5)+
		
		; diffusion horizontale de 7/16 (vert)
		
		move.w	d1,d7
		muls.w	#7,d7
		asr.w	#4,d7
		move.w	d7,(a5)+
		
		; diffusion horizontale de 7/16 (bleu)
		
		move.w	d2,d7
		muls.w	#7,d7
		asr.w	#4,d7
		move.w	d7,(a5)
		
		; diffusion bas/gauche de 3/16 (rouge)
		
		move.l	_TRN_PTR3(a6),a5
		
		move.w	d0,d7
		muls.w	#3,d7
		asr.w	#4,d7
		add.w	d7,(a5)+
		
		; diffusion bas/gauche de 3/16 (vert)
		
		move.w	d1,d7
		muls.w	#3,d7
		asr.w	#4,d7
		add.w	d7,(a5)+
		
		; diffusion bas/gauche de 3/16 (bleu)
		
		move.w	d2,d7
		muls.w	#3,d7
		asr.w	#4,d7
		add.w	d7,(a5)+
		
		; diffusion bas de 5/16 (rouge)
		
		move.w	d0,d7
		muls.w	#5,d7
		asr.w	#4,d7
		add.w	d7,(a5)
		
		; diffusion bas de 5/16 (vert)
		
		move.w	d1,d7
		muls.w	#5,d7
		asr.w	#4,d7
		add.w	d7,2(a5)
		
		; diffusion bas de 5/16 (bleu)
		
		move.w	d2,d7
		muls.w	#5,d7
		asr.w	#4,d7
		add.w	d7,4(a5)
		
		; diffusion bas/droite de 1/16 (rouge/vert/bleu)
		
		asr.w	#4,d0
		move.w	d0,6(a5)
		asr.w	#4,d1
		move.w	d1,8(a5)
		asr.w	#4,d2
		move.w	d2,10(a5)
		
		move.l	a5,_TRN_PTR3(a6)
		
		; r‚cup la couleur dans d5.w
		
		move	d6,d5
		
		movem.l	(sp)+,d0-4/d6-7
		
		; teste la fin d'une ligne
		
		tst.l	d4
		bne.s	.lignepasfinie
		
		; remettre les pointeurs au debut
		
		move.l	_TRN_PTR4(a6),_TRN_PTR3(a6)
		move.l	_TRN_PTR5(a6),_TRN_PTR2(a6)
		
		addq.l	#6,_TRN_PTR2(a6)
		move.l	_TRN_PTR3(a6),a5
		clr.l	(a5)+
		clr.l	(a5)+
		clr.l	(a5)
		
		; ‚change de tampon
		
		move.l	_TRN_PTR2(a6),_TRN_PTR4(a6)
		move.l	_TRN_PTR3(a6),_TRN_PTR5(a6)
.lignepasfinie
		move.l	(sp)+,a5
		
		****************
		
		jsr	([_TRN_PUTNEXT.w,a6])
		
		bra	.trueloop
		
		****************
	
	************************************
		
		; les modes index‚s sortent l'index de couleur en d5
		
		****************
.index‚
		movem.l	d0-a6,-(sp)
		
		move.l	_TRN_SPAL(a6),a5
		move.l	_TRN_WRKSPC(a6),a3
		move	_TRN_SCOLNUM(a6),d7
.sloop
		move.l	#$00ff0000,d0
		move.l	d0,d1
		move.l	d1,d2
		moveq	#0,d6
		
		move.b	(a5)+,d0
		move.b	(a5)+,d1
		addq	#1,a5
		move.b	(a5)+,d2
		
		move.l	_TRN_DPAL(a6),a4
		swap	d7
		move	_TRN_DCOLNUM(a6),d7
.dloop
		clr.l	d3
		clr.l	d4
		clr.l	d5
		
		move.b	(a4)+,d3
		move.b	(a4)+,d4
		addq	#1,a4
		move.b	(a4)+,d5
		
		sub.w	d0,d3
		bpl.s	.posdr
		neg.w	d3
.posdr
		sub.w	d1,d4
		bpl.s	.posdv
		neg.w	d4
.posdv
		sub.w	d2,d5
		bpl.s	.posdb
		neg.w	d5
.posdb
		swap	d0
		swap	d1
		swap	d2
		
		clr	d6
		add	d0,d6
		add	d1,d6
		add	d2,d6
		sub	d3,d6
		sub	d4,d6
		sub	d5,d6
		
		bmi.s	.ngc
		
		move	d3,d0
		move	d4,d1
		move	d5,d2
		swap	d6
		move	_TRN_DCOLNUM(a6),d6
		sub	d7,d6
		swap	d6
.ngc
		swap	d0
		swap	d1
		swap	d2
		
		subq	#1,d7
		bne.s	.dloop
		
		swap	d6
		move	d6,(a3)+
		
		swap	d7
		subq	#1,d7
		bne.s	.sloop
		
		movem.l	(sp)+,d0-a6
		
		****************
.idx_loop		
		jsr	([_TRN_GETNEXT.w,a6])
		
		move	([_TRN_WRKSPC,a6],d5.w*2),d5
		
		jsr	([_TRN_PUTNEXT.w,a6])
		
		bra.s	.idx_loop

		****************


	************************************

***************************************************************************
***************************************************************************
***************************************************************************
***************************************************************************

	************************************
		
		****************

		; floyd-steinberg avec niveaux de gris avec diffusion ...
		
		****************
TramageMode5:
		movem.l	d0-a5,-(sp)
		
		; initialisation de l'espace de travail
		
		move.l	_TRN_WRKSPC(a6),a5
		
		; r‚serve largeur source en 24 bits
		
		move.l	a5,_TRN_SLINE(a6)
		
		move.l	_TRN_SMFDB(a6),a4
		moveq	#0,d0
		move	mfdb_w(a4),d0
		add	#$000f,d0
		and	#$fff0,d0
		
		move.l	d0,d1	; * 3
		add.l	d0,d1
		add.l	d0,d1
		
		add.l	a5,d1
		
		; arrondi sur 16 octets (favorise les caches)
		
		add.l	#$0000000f,d1
		and.l	#$fffffff0,d1
		move.l	d1,a5
		
		; r‚serve largeur cible en 8 bits
		
		move.l	a5,_TRN_DLINE(a6)
		
		move.l	_TRN_DMFDB(a6),a3
		
		moveq	#0,d0
		move	mfdb_w(a3),d0
		add	#$000f,d0
		and	#$fff0,d0
		
		add.l	a5,d0
		
		; arrondi sur 16 octets (favorise les caches)
		
		add.l	#$0000000f,d0
		and.l	#$fffffff0,d0
		move.l	d0,a5
		
		; r‚serve pour la table d'interpolation
		
		move.l	a5,_TRN_PTR1(a6)
		lea	256(a5),a5
		
		; r‚serve pour la diffusion horizontale
		
		move.l	a5,_TRN_PTR2(a6)
		clr.l	(a5)+
		clr.l	(a5)+
		clr.l	(a5)+
		clr.l	(a5)+
		
		; r‚serve pour la diffusion verticale
		
		move.l	a5,_TRN_PTR3(a6)
		
		move	mfdb_w(a4),d0
		addq	#2,d0
.ClrBuff2		
		clr.w	(a5)+
		
		subq	#1,d0
		bne.s	.ClrBuff2
		
		; arrondi sur 16 octets (favorise les caches)
		
		move.l	a5,d0
		add.l	#$0000000f,d0
		and.l	#$fffffff0,d0
		move.l	d0,a5
		
		move.l	a5,_TRN_PTR4(a6)
		clr.l	(a5)+
		clr.l	(a5)+
		clr.l	(a5)+
		clr.l	(a5)+
		
		move.l	_TRN_PTR3(a6),_TRN_PTR5(a6)
		move.l	_TRN_PTR4(a6),_TRN_PTR6(a6)
		addq.l	#2,_TRN_PTR3(a6)
		
		; calcul de la table d'interpolation rapide
		; il est sous-entendu que la palette destination
		; est en niveaux de gris bien entendu !
		
		move.l	_TRN_PTR1(a6),a5
		lea	256(a5),a5
		
		move.l	#256,d1
		divu.w	_TRN_DCOLNUM(a6),d1
		
		moveq	#0,d0
		move	_TRN_DCOLNUM(a6),d3
.yopal2		
		move.w	d1,d2
.yopal1
		move.b	d0,-(a5)
		subq	#1,d2
		bgt.s	.yopal1
		
		addq	#1,d0
		subq	#1,d3
		bgt.s	.yopal2
		
		****************
		
		; d‚but du tramage ...
		
		move.l	_TRN_GETNEXT(a6),a5
		move.l	_TRN_PUTNEXT(a6),a4
		move.l	_TRN_DPAL(a6),a2
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		
		; acquisition d'une ligne source !
.ZeBigLoop
		jsr	(a5)
		
		move.l	_TRN_SLINE(a6),a3
		move.l	_TRN_DLINE(a6),a0
		move	_TRN_XCOUNT(a6),d7
.LoopX
		moveq	#0,d0
		move.b	(a3)+,d0
		move.b	(a3)+,d1
		add.w	d1,d0
		move.b	(a3)+,d1
		add.w	d1,d0
		
		; prise en compte de l'erreur diffus‚e de gauche
		
		add.w	([_TRN_PTR2.w,a6]),d0
		
		; prise en compte de l'erreur diffus‚e d'au dessus
		
		move.l	_TRN_PTR3(a6),a1
		add.w	(a1),d0
		clr.w	(a1)+
		move.l	a1,_TRN_PTR3(a6)
		
		****
		
		; approximation en gris
		
		cmp.w	#255*3,d0
		blt.s	.oksat
		move.w	#255,d0
.oksat		
		move.b	(_TRN_DIV_3,d0.w),d1
		
		; recherche de l'index correspondant dans
		; la palette niveaux de gris theorique
		
		move.b	([_TRN_PTR1.w,a6],d1.w),d2
		move.b	d2,(a0)+
		
		; calcul de l'erreur vraie (basee sur le vert)
		
		move.w	d1,d0
		move.b	2(a2,d2.w*4),d1
		sub.w	d1,d0
		
		; diffusion horizontale de 7/16
		
		move.w	(_TRN_STEIN_716.w,pc,d0.w*2),([_TRN_PTR2,a6])
		
		; diffusion bas/gauche de 3/16
		
		move.l	_TRN_PTR4(a6),a1
		
		move	(a1),d3
		add.w	(_TRN_STEIN_316.w,pc,d0.w*2),d3
		move	d3,(a1)+
		
		; diffusion bas de 5/16
		
		move	(a1),d3
		add.w	(_TRN_STEIN_516.w,pc,d0.w*2),d3
		move	d3,(a1)
		
		; diffusion bas/droite de 1/16 (rouge/vert/bleu)
		
		asr.w	#4,d0
		move.w	d0,2(a1)
		
		move.l	a1,_TRN_PTR4(a6)
		
		subq	#1,d7
		bne	.LoopX
		
		; la ligne est finie !
		; remettre les pointeurs … jour ...
		
		move.l	_TRN_PTR5(a6),_TRN_PTR4(a6)
		move.l	_TRN_PTR6(a6),_TRN_PTR3(a6)
		addq.l	#2,_TRN_PTR3(a6)
		
		move.l	_TRN_PTR4(a6),a1
		clr.w	(a1)
		move.l	_TRN_PTR2(a6),a1
		clr.w	(a1)
		
		; ‚change de tampon
		
		move.l	_TRN_PTR3(a6),_TRN_PTR5(a6)
		move.l	_TRN_PTR4(a6),_TRN_PTR6(a6)
		
		; on transfŠre la ligne en format destination !
		
		jsr	(a4)
		
		subq	#1,_TRN_YCOUNT(a6)
		bne	.ZeBigLoop
		
		movem.l	(sp)+,d0-a5
		rts
		

		****************


	************************************

***************************************************************************
***************************************************************************
***************************************************************************
***************************************************************************

	************************************
		
		****************

		; WAS: floyd-steinberg … propagation r‚duite ...
		
		****************
TramageMode6:
		


	************************************

***************************************************************************
***************************************************************************
***************************************************************************
***************************************************************************
***************************************************************************
***************************************************************************

	************************************
		
		****************

		; Algorithme sans diffusion d'erreur
		; Recherche de couleur par interpolation rapide ...
		
		****************
TramageMode7:
		movem.l	d0-a5,-(sp)
		
		; initialisation de l'espace de travail
		
		move.l	_TRN_WRKSPC(a6),a5
		
		; r‚serve largeur source en 24 bits
		
		move.l	a5,_TRN_SLINE(a6)
		
		move.l	_TRN_SMFDB(a6),a4
		moveq	#0,d0
		move	mfdb_wordw(a4),d0
		lsl.l	#4,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a5
		
		; r‚serve largeur cible en 8 bits
		
		move.l	a5,_TRN_DLINE(a6)
		
		move.l	_TRN_DMFDB(a6),a3
		moveq	#0,d0
		move	mfdb_wordw(a3),d0
		lsl.l	#4,d0
		add.l	d0,a5
		
		; r‚serve pour la table d'interpolation
		
		move.l	a5,_TRN_PTR1(a6)
		lea	256(a5),a5
		
		; r‚serve pour la diffusion horizontale
		
		move.l	a5,_TRN_PTR2(a6)
		clr.l	(a5)+
		clr.w	(a5)+
		
		; r‚serve pour la diffusion verticale
		
		move.l	a5,_TRN_PTR3(a6)
		
		move	mfdb_wordw(a4),d0
		add	d0,d0
.ClrBuff2		
		rept	12
		clr.l	(a5)+
		endr
		
		subq	#1,d0
		bne.s	.ClrBuff2
		
		move.l	a5,_TRN_PTR4(a6)
		
		move.l	_TRN_PTR3(a6),_TRN_PTR5(a6)
		move.l	_TRN_PTR4(a6),_TRN_PTR6(a6)
		
		; calcul de la table d'interpolation rapide :
		
		move.l	_TRN_PTR1(a6),a5
		lea	216(a5),a4
		
		move.l	_TRN_DPAL(a6),a3
		move	_TRN_DCOLNUM(a6),d6
		add	d6,d6
		add	d6,d6
		lea	(a3,d6.w),a3
		
		; commencons par le blanc ...
		
		move.l	#$000000ff,d0
.YoRed		
		move.l	#$000000ff,d1
.YoGreen		
		move.l	#$000000ff,d2
.YoBlue
		; erreur au maximum !
		
		move.l	#(255*255*3),d5
		
		move	_TRN_DCOLNUM(a6),d7
		subq	#1,d7
		move.l	a3,a2
		moveq	#0,d6
.Cloop1
		; on calcule les distances dans l'espace
		
		clr.l	d3
		move.b	-(a2),d3
		sub.w	d2,d3
		muls.w	d3,d3
		move.l	d3,d4
		
		clr.l	d3
		move.b	-(a2),d3
		sub.w	d1,d3
		muls.w	d3,d3
		add.l	d3,d4
		
		clr.l	d3
		move.b	-(a2),d3
		sub.w	d0,d3
		muls.w	d3,d3
		add.l	d3,d4
		
		cmp.l	d4,d5
		ble.s	.Bad
		
		move.l	d4,d5
		move.w	d7,d6
.Bad
		subq	#1,a2
		subq	#1,d7
		bpl.s	.Cloop1
		
		; d6 = couleur la plus proche trouv‚e
		; on met l' entr‚e qui va bien dans la table
		
		move.b	d6,-(a4)
		
		sub	#51,d2
		bpl	.YoBlue
		
		sub	#51,d1
		bpl	.YoGreen
		
		sub	#51,d0
		bpl	.YoRed
		
		; correction pour 217e index
		
		move.b	215(a4),216(a4)
		
		****************
		
		; d‚but du tramage ...
		
		move.l	_TRN_GETNEXT(a6),a5
		move.l	_TRN_PUTNEXT(a6),a4
		move.l	_TRN_PTR1(a6),a2
		
		clr	d0
		clr	d1
		clr	d2
		clr	d4
		
		; acquisition d'une ligne source !
.ZeBigLoop
		jsr	(a5)
		
		move.l	_TRN_SLINE(a6),a3
		move.l	_TRN_DLINE(a6),a0
		
		move	_TRN_XCOUNT(a6),d7
		
		****
.LoopX
		move.b	(a3)+,d0
		move.b	(a3)+,d1
		move.b	(a3)+,d2
		
		move.w	(_TRN_MAGIC_R,pc,d0.w*2),d4
		add.w	(_TRN_MAGIC_V,pc,d1.w*2),d4
		add.w	(_TRN_MAGIC_B,pc,d2.w*2),d4
		
		; recherche de la couleur par la table
		
		move.b	(a2,d4.w),(a0)+
		
		subq	#1,d7
		bne	.LoopX
		
		****
		
		; la ligne est finie !
		; on transfŠre la ligne en format destination !
		
		jsr	(a4)
		
		subq	#1,_TRN_YCOUNT(a6)
		bne	.ZeBigLoop
		
		movem.l	(sp)+,d0-a5
		rts
		
		****

	************************************

***************************************************************************
***************************************************************************
***************************************************************************
***************************************************************************

	************************************
		
		****************

		; algorithme a recherche de couleur ULTRA-rapide ...
		; methode de diffusion d'erreur floyd-steinberg simplifi‚e ...
		
		****************
TramageMode8:
		movem.l	d0-a5,-(sp)
		
		; initialisation de l'espace de travail
		
		move.l	_TRN_WRKSPC(a6),a5
		
		; r‚serve largeur source en 24 bits
		
		move.l	a5,_TRN_SLINE(a6)
		
		move.l	_TRN_SMFDB(a6),a4
		moveq	#0,d0
		move	mfdb_wordw(a4),d0
		lsl.l	#4,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a5
		
		; r‚serve largeur cible en 8 bits
		
		move.l	a5,_TRN_DLINE(a6)
		
		move.l	_TRN_DMFDB(a6),a3
		moveq	#0,d0
		move	mfdb_wordw(a3),d0
		lsl.l	#4,d0
		add.l	d0,a5
		
		; r‚serve pour la table d'interpolation
		
		move.l	a5,_TRN_PTR1(a6)
		lea	256(a5),a5
		
		; r‚serve pour la diffusion horizontale
		
		move.l	a5,_TRN_PTR2(a6)
		clr.l	(a5)+
		clr.w	(a5)+
		
		; r‚serve pour la diffusion verticale
		
		move.l	a5,_TRN_PTR3(a6)
		
		move	mfdb_wordw(a4),d0
		add	d0,d0
.ClrBuff2		
		rept	12
		clr.l	(a5)+
		endr
		
		subq	#1,d0
		bne.s	.ClrBuff2
		
		move.l	a5,_TRN_PTR4(a6)
		
		move.l	_TRN_PTR3(a6),_TRN_PTR5(a6)
		move.l	_TRN_PTR4(a6),_TRN_PTR6(a6)
		
		; calcul de la table d'interpolation rapide :
		
		move.l	_TRN_PTR1(a6),a5
		lea	216(a5),a4
		
		move.l	_TRN_DPAL(a6),a3
		move	_TRN_DCOLNUM(a6),d6
		add	d6,d6
		add	d6,d6
		lea	(a3,d6.w),a3
		
		; commencons par le blanc ...
		
		move.l	#$000000ff,d0
.YoRed		
		move.l	#$000000ff,d1
.YoGreen		
		move.l	#$000000ff,d2
.YoBlue
		; erreur au maximum !
		
		move.l	#(255*255*3),d5
		
		move	_TRN_DCOLNUM(a6),d7
		subq	#1,d7
		move.l	a3,a2
		moveq	#0,d6
.Cloop1
		; on calcule l'erreur cumul‚e...
		; somme des carr‚s pour faire plaisir a parx :-)
		
		clr.l	d3
		move.b	-(a2),d3
		sub.w	d2,d3
		muls.w	d3,d3
		move.l	d3,d4
		
		clr.l	d3
		move.b	-(a2),d3
		sub.w	d1,d3
		muls.w	d3,d3
		add.l	d3,d4
		
		clr.l	d3
		move.b	-(a2),d3
		sub.w	d0,d3
		muls.w	d3,d3
		add.l	d3,d4
		
		cmp.l	d4,d5
		ble.s	.Bad
		
		move.l	d4,d5
		move.w	d7,d6
.Bad
		subq	#1,a2
		subq	#1,d7
		bpl.s	.Cloop1
		
		; d6 = couleur la plus proche trouv‚e
		; on met l' entr‚e qui va bien dans la table
		
		move.b	d6,-(a4)
		
		sub	#51,d2
		bpl	.YoBlue
		
		sub	#51,d1
		bpl	.YoGreen
		
		sub	#51,d0
		bpl	.YoRed
		
		; correction pour 217e index
		
		move.b	215(a4),216(a4)
		
		****************
		
		; d‚but du tramage ...
		
		move.l	_TRN_GETNEXT(a6),a5
		move.l	_TRN_PUTNEXT(a6),a4
		move.l	_TRN_DPAL(a6),a2
		
		; acquisition d'une ligne source !
.ZeBigLoop
		jsr	(a5)
		
		move.l	_TRN_SLINE(a6),a3
		move.l	_TRN_DLINE(a6),a0
		
		move	_TRN_XCOUNT(a6),d7
.LoopX
		clr.l	d0
		move.b	(a3)+,d0
		clr.l	d1
		move.b	(a3)+,d1
		clr.l	d2
		move.b	(a3)+,d2
		
		; prise en compte de l'erreur diffus‚e de gauche
		
		move.l	_TRN_PTR2(a6),a1
		add.w	(a1)+,d0
		add.w	(a1)+,d1
		add.w	(a1),d2
		
		; prise en compte de l'erreur diffus‚e d'au dessus
		
		move.l	_TRN_PTR3(a6),a1
		add.w	(a1)+,d0
		add.w	(a1)+,d1
		add.w	(a1)+,d2
		move.l	a1,_TRN_PTR3(a6)
		
		****
		
		lea	_TRN_CLIP_ERROR,a1
		
		move	(a1,d0.w*2),d0
		move	(a1,d1.w*2),d1
		move	(a1,d2.w*2),d2
		
		****

		move.w	(_TRN_MAGIC_R,pc,d0.w*2),d5
		add.w	(_TRN_MAGIC_V,pc,d1.w*2),d5
		add.w	(_TRN_MAGIC_B,pc,d2.w*2),d5
		
		****
		
		; recherche de la couleur par la table
		
		move.l	_TRN_PTR1(a6),a1
		clr	d6
		move.b	(a1,d5.w),d6
		
		move.b	d6,(a0)+
		
		; calcul de l'erreur sign‚e
		
		lea	1(a2,d6.w*4),a1
		
		clr.w	d3
		move.b	(a1)+,d3
		sub.w	d3,d0
		asr	#1,d0
		
		clr.w	d4
		move.b	(a1)+,d4
		sub.w	d4,d1
		asr	#1,d1
		
		clr.w	d5
		move.b	(a1),d5
		sub.w	d5,d2
		asr	#1,d2
		
		; diffusion de l'erreur d'approximation
		; diffusion horizontale de 1/2
		
		move.l	_TRN_PTR2(a6),a1
		move	d0,(a1)+
		move	d1,(a1)+
		move	d2,(a1)
		
		; diffusion bas de 1/2
		
		move.l	_TRN_PTR4(a6),a1
		
		move.w	d0,(a1)+
		move.w	d1,(a1)+
		move.w	d2,(a1)+
		
		move.l	a1,_TRN_PTR4(a6)
		
		subq	#1,d7
		bne	.LoopX
		
		; la ligne est finie !
		; remettre les pointeurs … jour ...
		
		move.l	_TRN_PTR5(a6),_TRN_PTR4(a6)
		move.l	_TRN_PTR6(a6),_TRN_PTR3(a6)
		
		move.l	_TRN_PTR4(a6),a1
		clr.l	(a1)+
		clr.w	(a1)
		move.l	_TRN_PTR2(a6),a1
		clr.l	(a1)+
		clr.w	(a1)
		
		; ‚change de tampon
		
		move.l	_TRN_PTR3(a6),_TRN_PTR5(a6)
		move.l	_TRN_PTR4(a6),_TRN_PTR6(a6)
		
		; on transfŠre la ligne en format destination !
		
		jsr	(a4)
		
		subq	#1,_TRN_YCOUNT(a6)
		bne	.ZeBigLoop
		
		movem.l	(sp)+,d0-a5
		rts
		
	************************************

***************************************************************************
***************************************************************************
***************************************************************************
***************************************************************************
***************************************************************************
***************************************************************************

	************************************
		
		****************

		; Algorithme … recherche de couleur ULTRA-rapide ...
		; m‚thode de diffusion d'erreur floyd-steinberg pr‚cise !
		
		****************
TramageMode9:
		movem.l	d0-a5,-(sp)
		
		; initialisation de l'espace de travail
		
		move.l	_TRN_WRKSPC(a6),a5
		
		; r‚serve largeur source en 24 bits
		
		move.l	a5,_TRN_SLINE(a6)
		
		move.l	_TRN_SMFDB(a6),a4
		moveq	#0,d0
		move	mfdb_w(a4),d0
		add	#$000f,d0
		and	#$fff0,d0
		
		move.l	d0,d1	; * 3
		add.l	d0,d1
		add.l	d0,d1
		
		add.l	a5,d1
		
		; arrondi sur 16 octets (favorise les caches)
		
		add.l	#$0000000f,d1
		and.l	#$7ffffff0,d1
		move.l	d1,a5
		
		; r‚serve largeur cible en 8 bits
		
		move.l	a5,_TRN_DLINE(a6)
		
		move.l	_TRN_DMFDB(a6),a3
		
		moveq	#0,d0
		move	mfdb_w(a3),d0
		add	#$000f,d0
		and	#$fff0,d0
		
		add.l	a5,d0
		
		; arrondi sur 16 octets (favorise les caches)
		
		add.l	#$0000000f,d0
		and.l	#$7ffffff0,d0
		move.l	d0,a5
		
		; r‚serve pour la table d'interpolation
		
		move.l	a5,_TRN_PTR1(a6)
		lea	512(a5),a5
		
		; r‚serve pour la diffusion horizontale
		
		move.l	a5,_TRN_PTR2(a6)
		clr.l	(a5)+
		clr.l	(a5)+
		clr.l	(a5)+
		clr.l	(a5)+
		
		; r‚serve pour la diffusion verticale
		
		move.l	a5,_TRN_PTR3(a6)
		
		move	mfdb_w(a4),d0
		addq	#2,d0
.ClrBuff2		
		rept	3
		clr.w	(a5)+
		endr
		
		subq	#1,d0
		bne.s	.ClrBuff2
		
		; arrondi sur 16 octets (favorise les caches)
		
		move.l	a5,d0
		add.l	#$0000000f,d0
		and.l	#$7ffffff0,d0
		move.l	d0,a5
		
		move.l	a5,_TRN_PTR4(a6)
		clr.l	(a5)+
		clr.l	(a5)+
		clr.l	(a5)+
		clr.l	(a5)+
		
		move.l	_TRN_PTR3(a6),_TRN_PTR5(a6)
		move.l	_TRN_PTR4(a6),_TRN_PTR6(a6)
		
		; calcul du cube d'approximation
		
		**illegal
		
		move.l	_TRN_PTR1(a6),a5
		lea	512(a5),a4
		
		lea	_TRN_SQ,a1
		
		move.l	_TRN_DPAL(a6),a3
		move	_TRN_DCOLNUM(a6),d6
		lea	(a3,d6.w*4),a3
		
		; commencons par le blanc ...
		
		move.l	#$000000ff,d0
.YoRed		
		move.l	#$000000ff,d1
.YoGreen		
		move.l	#$000000ff,d2
.YoBlue
		; erreur au maximum !
		
		move.l	#(255*255*3),d5
		
		move	_TRN_DCOLNUM(a6),d7
		subq	#1,d7
		move.l	a3,a2
		moveq	#0,d6
.Cloop1
		; on calcule les distances dans l'espace RVB
		
		moveq	#0,d3
		move.b	-(a2),d3
		sub.w	d2,d3
		
		moveq	#0,d4
		move.w	(a1,d3.w*2),d4
		
		;muls.w	d3,d3
		;move.l	d3,d4
		
		moveq	#0,d3
		move.b	-(a2),d3
		sub.w	d1,d3
		
		move.w	(a1,d3.w*2),d3
		add.l	d3,d4
		
		;muls.w	d3,d3
		;add.l	d3,d4
		
		moveq	#0,d3
		move.b	-(a2),d3
		sub.w	d0,d3
		
		;muls.w	d3,d3
		;add.l	d3,d4
		
		move.w	(a1,d3.w*2),d3
		add.l	d3,d4
		
		cmp.l	d4,d5
		ble.s	.Bad
		
		move.l	d4,d5
		move.w	d7,d6
.Bad
		subq	#1,a2
		subq	#1,d7
		bpl.s	.Cloop1
		
		; d6 = couleur la plus proche trouv‚e
		; on met l' entr‚e qui va bien dans la table
		
		move.b	d6,-(a4)
		
		sub	#36,d2
		bpl	.YoBlue
		
		sub	#36,d1
		bpl	.YoGreen
		
		sub	#36,d0
		bpl	.YoRed
		
		****************
		
		; d‚but du tramage ...
		
		**illegal
		
		move.l	_TRN_PTR1(a6),a4
		move.l	_TRN_DPAL(a6),a2
		moveq	#0,d6
		
		; acquisition d'une ligne source !
.ZeBigLoop
		jsr	([_TRN_GETNEXT.w,a6])
		
		move.l	_TRN_SLINE(a6),a3
		move.l	_TRN_PTR3(a6),a1
		addq.l	#6,a1
		move.l	_TRN_DLINE(a6),a0
		move.w	_TRN_XCOUNT(a6),d7
		
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		
		****
.LoopX
		clr.w	d0
		move.b	(a3)+,d0
		lsl.w	#4,d0
		
		add.w	(a1)+,d3
		add.w	d0,d3
		
		clr.w	d0
		move.b	(a3)+,d0
		lsl.w	#4,d0
		
		add.w	(a1)+,d4
		add.w	d0,d4
		
		clr.w	d0
		move.b	(a3)+,d0
		lsl.w	#4,d0
		
		add.w	(a1)+,d5
		add.w	d0,d5
		
		asr	#4,d3
		asr	#4,d4
		asr	#4,d5
		
		****
		
		lea	_TRN_CLIP_ERROR,a5
		move.w	(a5,d3.w*2),d3
		move.w	(a5,d4.w*2),d4
		move.w	(a5,d5.w*2),d5
		
		move.w	(_TRN_MAGIK_R,pc,d3.w*2),d1
		add.w	(_TRN_MAGIK_V,pc,d4.w*2),d1
		add.w	(_TRN_MAGIK_B,pc,d5.w*2),d1
		
		****
		
		; recherche de la couleur par la table
		
		move.b	(a4,d1.w),d6
		move.b	d6,(a0)+
		
		; calcul de l'erreur sign‚e
		
		lea	1(a2,d6.w*4),a5
		
		clr.w	d0
		move.b	(a5)+,d0
		sub.w	d3,d0
		neg.w	d0
		
		clr.w	d1
		move.b	(a5)+,d1
		sub.w	d4,d1
		neg.w	d1
		
		clr.w	d2
		move.b	(a5),d2
		sub.w	d5,d2
		neg.w	d2
		
		; diffusion de l'erreur d'approximation
		
		; bas/droite de 1/16
		
		move.l	_TRN_PTR4(a6),a5
		
		move.w	d0,12(a5)
		move.w	d1,14(a5)
		move.w	d2,16(a5)
		
		; bas/gauche de 3/16
		
		move.w	d0,d3
		add.w	d0,d3
		add.w	d0,d3
		add.w	d3,(a5)+
		
		move.w	d1,d4
		add.w	d1,d4
		add.w	d1,d4
		add.w	d4,(a5)+
		
		move.w	d2,d5
		add.w	d2,d5
		add.w	d2,d5
		add.w	d5,(a5)+
		
		; bas de 5/16
		
		add.w	d0,d3
		add.w	d0,d3
		add.w	d3,(a5)
		
		add.w	d1,d4
		add.w	d1,d4
		add.w	d4,2(a5)
		
		add.w	d2,d5
		add.w	d2,d5
		add.w	d5,4(a5)
		
		move.l	a5,_TRN_PTR4(a6)
		
		; diffusion horizontale de 7/16
		
		add.w	d0,d3
		add.w	d0,d3
		
		add.w	d1,d4
		add.w	d1,d4
		
		add.w	d2,d5
		add.w	d2,d5
		
		subq.w	#1,d7
		bne	.LoopX
		
		; la ligne est finie !
		; remettre les pointeurs … jour ...
		
		move.l	_TRN_PTR5(a6),_TRN_PTR4(a6)
		move.l	_TRN_PTR6(a6),_TRN_PTR3(a6)
		
		move.l	_TRN_PTR4(a6),a1
		clr.l	(a1)+
		clr.l	(a1)+
		clr.l	(a1)+
		
		; ‚change de tampon
		
		move.l	_TRN_PTR3(a6),_TRN_PTR5(a6)
		move.l	_TRN_PTR4(a6),_TRN_PTR6(a6)
		
		; on transfŠre la ligne en format destination !
		
		jsr	([_TRN_PUTNEXT.w,a6])
		
		subq	#1,_TRN_YCOUNT(a6)
		bne	.ZeBigLoop
		
		movem.l	(sp)+,d0-a5
		rts
		
	************************************
		
***************************************************************************
***************************************************************************
***************************************************************************
***************************************************************************
***************************************************************************
***************************************************************************
***************************************************************************

	************************************
		
		****************

		; Algorithme … recherche de couleur ULTRA-rapide ...
		; m‚thode de diffusion d'erreur floyd-steinberg originale !
		
		****************
TramageMode10:
		movem.l	d0-a5,-(sp)
		
		; initialisation de l'espace de travail
		
		move.l	_TRN_WRKSPC(a6),a5
		
		; r‚serve largeur source en 24 bits
		
		move.l	a5,_TRN_SLINE(a6)
		
		move.l	_TRN_SMFDB(a6),a4
		moveq	#0,d0
		move	mfdb_w(a4),d0
		add	#$000f,d0
		and	#$fff0,d0
		
		move.l	d0,d1	; * 3
		add.l	d0,d1
		add.l	d0,d1
		
		add.l	a5,d1
		
		; arrondi sur 16 octets (favorise les caches)
		
		add.l	#$0000000f,d1
		and.l	#$fffffff0,d1
		move.l	d1,a5
		
		; r‚serve largeur cible en 8 bits
		
		move.l	a5,_TRN_DLINE(a6)
		
		move.l	_TRN_DMFDB(a6),a3
		
		moveq	#0,d0
		move	mfdb_w(a3),d0
		add	#$000f,d0
		and	#$fff0,d0
		
		add.l	a5,d0
		
		; arrondi sur 16 octets (favorise les caches)
		
		add.l	#$0000000f,d0
		and.l	#$fffffff0,d0
		move.l	d0,a5
		
		; r‚serve pour la table d'interpolation
		
		move.l	a5,_TRN_PTR1(a6)
		lea	256(a5),a5
		
		; r‚serve pour la diffusion horizontale
		
		move.l	a5,_TRN_PTR2(a6)
		clr.l	(a5)+
		clr.l	(a5)+
		clr.l	(a5)+
		clr.l	(a5)+
		
		; r‚serve pour la diffusion verticale
		
		move.l	a5,_TRN_PTR3(a6)
		
		move	mfdb_wordw(a4),d0
		add	d0,d0
.ClrBuff2		
		rept	12
		clr.l	(a5)+
		endr
		
		subq	#1,d0
		bne.s	.ClrBuff2
		
		; arrondi sur 16 octets (favorise les caches)
		
		move.l	a5,d0
		add.l	#$0000000f,d0
		and.l	#$fffffff0,d0
		move.l	d0,a5
		
		move.l	a5,_TRN_PTR4(a6)
		clr.l	(a5)+
		clr.l	(a5)+
		clr.l	(a5)+
		clr.l	(a5)+
		
		move.l	_TRN_PTR3(a6),_TRN_PTR5(a6)
		move.l	_TRN_PTR4(a6),_TRN_PTR6(a6)
		addq.l	#6,_TRN_PTR3(a6)
		
		; calcul de la table d'interpolation rapide :
		
		move.l	_TRN_PTR1(a6),a5
		lea	216(a5),a4
		
		move.l	_TRN_DPAL(a6),a3
		move	_TRN_DCOLNUM(a6),d6
		add	d6,d6
		add	d6,d6
		lea	(a3,d6.w),a3
		
		; commencons par le blanc ...
		
		move.l	#$000000ff,d0
.YoRed		
		move.l	#$000000ff,d1
.YoGreen		
		move.l	#$000000ff,d2
.YoBlue
		; erreur au maximum !
		
		move.l	#(255*255*3),d5
		
		move	_TRN_DCOLNUM(a6),d7
		subq	#1,d7
		move.l	a3,a2
		moveq	#0,d6
.Cloop1
		; on calcule l'erreur cumul‚e...
		
		clr.l	d3
		move.b	-(a2),d3
		sub.w	d2,d3
		muls.w	d3,d3
		move.l	d3,d4
		
		clr.l	d3
		move.b	-(a2),d3
		sub.w	d1,d3
		muls.w	d3,d3
		add.l	d3,d4
		
		clr.l	d3
		move.b	-(a2),d3
		sub.w	d0,d3
		muls.w	d3,d3
		add.l	d3,d4
		
		cmp.l	d4,d5
		ble.s	.Bad
		
		move.l	d4,d5
		move.w	d7,d6
.Bad
		subq	#1,a2
		subq	#1,d7
		bpl.s	.Cloop1
		
		; d6 = couleur la plus proche trouv‚e
		; on met l' entr‚e qui va bien dans la table
		
		move.b	d6,-(a4)
		
		sub	#51,d2
		bpl	.YoBlue
		
		sub	#51,d1
		bpl	.YoGreen
		
		sub	#51,d0
		bpl	.YoRed
		
		
		****************
		
		; d‚but du tramage ...
		
		move.l	_TRN_GETNEXT(a6),a5
		move.l	_TRN_PUTNEXT(a6),a4
		move.l	_TRN_DPAL(a6),a2
		
		; acquisition d'une ligne source !
.ZeBigLoop
		jsr	(a5)
		
		move.l	_TRN_SLINE(a6),a3
		move.l	_TRN_DLINE(a6),a0
		
		move	_TRN_XCOUNT(a6),d7
.LoopX
		clr.l	d0
		move.b	(a3)+,d0
		clr.l	d1
		move.b	(a3)+,d1
		clr.l	d2
		move.b	(a3)+,d2
		
		; prise en compte de l'erreur diffus‚e de gauche
		
		move.l	_TRN_PTR2(a6),a1
		add.w	(a1)+,d0
		add.w	(a1)+,d1
		add.w	(a1),d2
		
		; prise en compte de l'erreur diffus‚e d'au dessus
		
		move.l	_TRN_PTR3(a6),a1
		add.w	(a1)+,d0
		add.w	(a1)+,d1
		add.w	(a1)+,d2
		move.l	a1,_TRN_PTR3(a6)
		
		clr.l	-6(a1)
		clr.w	-2(a1)
		
		****
		
		lea	_TRN_CLIP_ERROR,a1
		
		add	d0,d0
		move	(a1,d0.w),d0
		add	d1,d1
		move	(a1,d1.w),d1
		add	d2,d2
		move	(a1,d2.w),d2
		
		****

		clr	d4
		clr	d5
		
		lea	_TRN_MAGIC_R,a1
		move.b	(a1,d0.w),d5
		
		lea	_TRN_MAGIC_V,a1
		move.b	(a1,d1.w),d4
		add	d4,d5
		
		lea	_TRN_MAGIC_B,a1
		move.b	(a1,d2.w),d4
		add	d4,d5
		
		****
		
		; recherche de la couleur par la table
		
		move.l	_TRN_PTR1(a6),a1
		clr	d6
		move.b	(a1,d5.w),d6
		move.b	d6,(a0)+
		
		; calcul de l'erreur sign‚e
		
		add	d6,d6
		add	d6,d6
		lea	1(a2,d6.w),a1
		
		clr.w	d3
		move.b	(a1)+,d3
		sub.w	d3,d0
		
		clr.w	d4
		move.b	(a1)+,d4
		sub.w	d4,d1
		
		clr.w	d5
		move.b	(a1),d5
		sub.w	d5,d2
		
		; diffusion de l'erreur d'approximation
		; diffusion horizontale de 3/8
		
		move.l	_TRN_PTR2(a6),a1
		move.w	(_TRN_STEIN_716.w,pc,d0.w*2),0(a1)
		move.w	(_TRN_STEIN_716.w,pc,d1.w*2),2(a1)
		move.w	(_TRN_STEIN_716.w,pc,d2.w*2),4(a1)
		
		; diffusion bas/gauche de 3/16
		
		move.l	_TRN_PTR4(a6),a1
		
		move	(a1),d3
		add.w	(_TRN_STEIN_316.w,pc,d0.w*2),d3
		move	d3,(a1)+
		
		move	(a1),d3
		add.w	(_TRN_STEIN_316.w,pc,d1.w*2),d3
		move	d3,(a1)+
		
		move	(a1),d3
		add.w	(_TRN_STEIN_316.w,pc,d2.w*2),d3
		move	d3,(a1)+
		
		; diffusion bas de 5/16
		
		move	(a1),d3
		add.w	(_TRN_STEIN_516.w,pc,d0.w*2),d3
		move	d3,(a1)
		
		move	2(a1),d3
		add.w	(_TRN_STEIN_516.w,pc,d1.w*2),d3
		move	d3,2(a1)
		
		move	4(a1),d3
		add.w	(_TRN_STEIN_516.w,pc,d2.w*2),d3
		move	d3,4(a1)
		
		; diffusion bas/droite de 1/16 (rouge/vert/bleu)
		
		asr.w	#4,d0
		move.w	d0,6(a1)
		
		asr.w	#4,d1
		move.w	d1,8(a1)
		
		asr.w	#4,d2
		move.w	d2,10(a1)
		
		move.l	a1,_TRN_PTR4(a6)
		
		subq	#1,d7
		bne	.LoopX
		
		; la ligne est finie !
		; remettre les pointeurs … jour ...
		
		move.l	_TRN_PTR5(a6),_TRN_PTR4(a6)
		move.l	_TRN_PTR6(a6),_TRN_PTR3(a6)
		addq.l	#6,_TRN_PTR3(a6)
		
		move.l	_TRN_PTR4(a6),a1
		clr.l	(a1)+
		clr.w	(a1)
		move.l	_TRN_PTR2(a6),a1
		clr.l	(a1)+
		clr.w	(a1)
		
		; ‚change de tampon
		
		move.l	_TRN_PTR3(a6),_TRN_PTR5(a6)
		move.l	_TRN_PTR4(a6),_TRN_PTR6(a6)
		
		; on transfŠre la ligne en format destination !
		
		jsr	(a4)
		
		subq	#1,_TRN_YCOUNT(a6)
		bne	.ZeBigLoop
		
		movem.l	(sp)+,d0-a5
		rts
		
	************************************

		****************
_TRN_MAGIC_R:
		dcb.w	28,0*36
		dcb.w	50,1*36
		dcb.w	50,2*36
		dcb.w	50,3*36
		dcb.w	50,4*36
		dcb.w	28,5*36
_TRN_MAGIC_V:
		dcb.w	28,0*6
		dcb.w	50,1*6
		dcb.w	50,2*6
		dcb.w	50,3*6
		dcb.w	50,4*6
		dcb.w	28,5*6
_TRN_MAGIC_B:
		dcb.w	28,0
		dcb.w	50,1
		dcb.w	50,2
		dcb.w	50,3
		dcb.w	50,4
		dcb.w	28,5
		
		****************
		
		; table de division par 3 rapide
		; (valeurs 0 a 765) (768 bytes)
_TRN_DIV_3:
i		set	0
		rept	766
		dc.b	i/3
i		set	i+1
		endr
		
		dc.w	0
		
		****************
		
		; table des carr‚s de -255 a +255
		; (1022 bytes)

i		set	-255
		rept	255
		dc.w	i*i
i		set	i+1
		endr
_TRN_SQ:		
		rept	256
		dc.w	i*i
i		set	i+1
		endr
		
		dc.w	0
		
		**********
		
		; table magique pour cube 9x9x9
		
i		set	0		
_TRN_MAGIK_R:
		rept	256
		dc.w	(i/36)<<6
i		set	i+1
		endr

i		set	0		
_TRN_MAGIK_V:
		rept	256
		dc.w	(i/36)<<3
i		set	i+1
		endr

i		set	0		
_TRN_MAGIK_B:
		rept	256
		dc.w	(i/36)
i		set	i+1
		endr
		
		**********
		
		; tables de limitation dans 0<x<255
		
		dcb.w	256,0
_TRN_CLIP_ERROR:
i		set	0
		rept	256
		dc.w	i
i		set	i+1
		endr
		
		dcb.w	256,255
		
		****************
		
		even
		
		; table de seiziŠmes pour floyd steinberg pr‚cis
		
x		set	-255
		rept	256
		dc.w	(x*7)/16
x		set	x+1
		endr
_TRN_STEIN_716:
		rept	256
		dc.w	(x*7)/16
x		set	x+1
		endr
		
x		set	-255
		rept	256
		dc.w	(x*5)/16
x		set	x+1
		endr
_TRN_STEIN_516:
		rept	256
		dc.w	(x*5)/16
x		set	x+1
		endr
		
x		set	-255
		rept	256
		dc.w	(x*3)/16
x		set	x+1
		endr
_TRN_STEIN_316:
		rept	256
		dc.w	(x*3)/16
x		set	x+1
		endr
		
		****************


	************************************

***************************************************************************
***************************************************************************
		SECTION DATA
***************************************************************************

	************************************

		****************

_TRN_MAX		dc.w	0

		****************
		
	************************************

***************************************************************************
***************************************************************************
