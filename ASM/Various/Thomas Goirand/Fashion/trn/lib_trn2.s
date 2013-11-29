***************************************************************************
		SECTION TEXT
***************************************************************************

	************************************
		
		****************
		
		; fonction PRINCIPALE de transformation graphique !
		
		; parametres:
		; LONG: MFDB source
		; LONG: MFDB destination
		; LONG: palette source
		; LONG: palette destination
		; LONG: espace de travail
		; WORD: index du proc‚d‚
		
		; resultat D0.L
		; n‚gatif=erreur
		
		; NB: la transformation est destructive si les MFDB
		; pointent sur le meme bitmap ,c'est au d‚veloppeur de
		; s'occuper des problŠmes de m‚moire (non mais...)
		
		****************
		
		rsset	8
_TRN_MODE		rs.w	1
_TRN_WRKSPC	rs.l	1
_TRN_DPAL		rs.l	1
_TRN_SPAL		rs.l	1
_TRN_DMFDB	rs.l	1
_TRN_SMFDB	rs.l	1

		****************
		
		rsset	-96

_TRN_GETNEXT	rs.l	1	; pointe sur la routine de lecture
_TRN_PUTNEXT	rs.l	1	; pointe sur la routine d'‚criture

_TRN_SLINE	rs.l	1	; adresse buffer de 1 ligne en r/v/b 24 bits
_TRN_DLINE	rs.l	1	; adresse buffer de 1 ligne en ind‚x‚ (8  bits)

_TRN_SNXTLPTR	rs.l	1	; pointe sur la prochaine ligne source
_TRN_SNXTLOFF	rs.l	1	; espace entre les d‚buts de 2 lignes source
_TRN_DNXTLPTR	rs.l	1	; pointe sur la prochaine ligne destination
_TRN_DNXTLOFF	rs.l	1	; espace entre les d‚buts de 2 lignes cible

_TRN_XCOUNT	rs.w	1	; compteur horizontal
_TRN_YCOUNT	rs.w	1	; compteur vertical

_TRN_SCOLNUM	rs.w	1	; nombre d'index dans la palette source
_TRN_DCOLNUM	rs.w	1	; nombre d'index dans la palette destination

_TRN_PTR1		rs.l	1	; pointeurs … usage multiple
_TRN_PTR2		rs.l	1
_TRN_PTR3		rs.l	1
_TRN_PTR4		rs.l	1
_TRN_PTR5		rs.l	1
_TRN_PTR6		rs.l	1

_TRN_COUNT1	rs.l	1	; compteurs suppl‚mentaires
_TRN_COUNT2	rs.l	1

_TRN_SBITOFF	rs.l	1	; offset de plan source (utile en vdi)
_TRN_DBITOFF	rs.l	1	; offset de plan cible (utile en vdi)

_TRN_OFF1		rs.l	1	; offsets suppl‚mentaires
_TRN_OFF2		rs.l	1
		
	************************************
		
		****************
_TRNF_MULTI:
		link	a6,#-96
		movem.l	d1-a5,-(sp)
		
		move.l	_TRN_SMFDB(a6),a5
		move.l	_TRN_DMFDB(a6),a4
				
		move	mfdb_planes(a4),d7
		move	mfdb_planes(a5),d6
		
		move	mfdb_w(a5),_TRN_XCOUNT(a6)
		move	mfdb_h(a5),_TRN_YCOUNT(a6)
		
		; tramage & remapping
		
		; permet de convertir une image source dans
		; n'importe quel format en image destination
		; de n'importe quel format (de meme taille) en
		; tramant la source d'aprŠs la palette de destination...
		; ( si n‚c‚ssaire ...)
		
		****************
		
		move.l	mfdb_addr(a5),a0
		move.l	a0,_TRN_SNXTLPTR(a6)
		move.l	mfdb_addr(a4),a1
		move.l	a1,_TRN_DNXTLPTR(a6)
		
		; s‚lection de la routine de lecture
		
		move	mfdb_format(a5),d0
		beq	.SourceVidel
		subq	#1,d0
		beq	.SourceVdi
		subq	#1,d0
		beq	.SourceChunky
		bra	.Fin
.SourceVdi
		clr.l	d0
		move	mfdb_wordw(a5),d0
		add.l	d0,d0
		move.l	d0,_TRN_SNXTLOFF(a6)
		mulu	mfdb_h(a5),d0
		move.l	d0,_TRN_SBITOFF(a6)
		
		lea	.TableGetVdi,a2
		bra	.OkSource
.SourceVidel
		clr.l	d0
		move	mfdb_wordw(a5),d0
		mulu	d6,d0
		add.l	d0,d0
		move.l	d0,_TRN_SNXTLOFF(a6)
		
		lea	.TableGetVidel,a2
		bra	.OkSource
.SourceChunky
		clr.l	d0
		move	mfdb_wordw(a5),d0
		mulu	d6,d0
		add.l	d0,d0
		move.l	d0,_TRN_SNXTLOFF(a6)
		
		lea	.TableGetChunky,a2
		bra	.OkSource
.OkSource
		add	d6,d6
		add	d6,d6
		move.l	-4(a2,d6.w),_TRN_GETNEXT(a6)
		beq	.Fin
		
		****************
		
		; cas particulier de cible en truecolor ...
		
		cmp	#16,d7
		bge	.TrueColor
		
		; s‚lection de la routine d'‚criture de pixel
		
		move	mfdb_format(a4),d1
		beq	.CibleVidel
		subq	#1,d1
		beq	.CibleVdi
		bra	.Fin
.CibleVdi
		clr.l	d0
		move	mfdb_wordw(a4),d0
		add.l	d0,d0
		move.l	d0,_TRN_DNXTLOFF(a6)
		mulu	mfdb_h(a4),d0
		move.l	d0,_TRN_DBITOFF(a6)
		
		lea	.TablePutV,a3
		bra	.OkCible
.CibleVidel
		clr.l	d0
		move	mfdb_wordw(a4),d0
		mulu	d7,d0
		add.l	d0,d0
		move.l	d0,_TRN_DNXTLOFF(a6)
		
		lea	.TablePutH,a3
.OkCible
		add	d7,d7
		add	d7,d7
		move.l	-4(a3,d7.w),_TRN_PUTNEXT(a6)
		beq	.Fin
		
		****************
		
		moveq	#1,d0
		move	mfdb_planes(a5),d1
		lsl	d1,d0
		move	d0,_TRN_SCOLNUM(a6)
		
		moveq	#1,d0
		move	mfdb_planes(a4),d1
		lsl	d1,d0
		move	d0,_TRN_DCOLNUM(a6)
		
		****************
		
		move	_TRN_MODE(a6),d0
		add	d0,d0
		add	d0,d0
		
		lea	.TableM‚thodes,a0
		move.l	(a0,d0.w),a0
		jsr	(a0)
		
		
		****************
.Fin
		movem.l	(sp)+,d1-a5
		unlk	a6
		rts

		****************
		SECTION DATA
		****************
.TableM‚thodes:
		dc.l	TramageMode0
		dc.l	TramageMode1
		dc.l	TramageMode2
		dc.l	TramageMode3
		dc.l	TramageMode4
		dc.l	TramageMode5
		dc.l	TramageMode6
		dc.l	TramageMode7
		dc.l	TramageMode8
		dc.l	TramageMode9
		
		****************
		
***************************************************************************
***************************************************************************

	************************************
		
		****************
		SECTION TEXT
		****************

		; routines de lecture de pixels de la source
		; la ligne … lire est point‚e par _TRN_SNXTLPTR
		; la sortie se fait en 24 bits en _TRN_SLINE.
		
		; Rappel:
		; la palette devra etre au format xbios [xRGB]

		****************
		
		; routine lecture 1 plan vdi
.GetV1:
		; comment ‡… inutile ???

		****************
	************************************
		****************
		
		; routine lecture 2 plans vdi
.GetV2:
		movem.l	d0-d4/a0-a3/a5,-(sp)
		
		move.l	_TRN_SNXTLPTR(a6),a0
		move.l	_TRN_SBITOFF(a6),a1
		add.l	a0,a1
		
		move.l	_TRN_SPAL(a6),a2
		move.l	_TRN_SLINE(a6),a3
		
		move.l	_TRN_SMFDB(a6),a5
		move	mfdb_wordw(a5),d0
.GV2line		
		move	(a0)+,d1
		move	(a1)+,d2
		
		moveq	#16,d4
.GV2word		
		clr	d3
		add	d1,d1
		addx	d3,d3
		add	d2,d2
		addx	d3,d3
		
		add	d3,d3
		add	d3,d3
		move.b	1(a2,d3.w),(a3)+
		move.b	2(a2,d3.w),(a3)+
		move.b	3(a2,d3.w),(a3)+
		
		subq	#1,d4
		bne.s	.GV2word
		
		subq	#1,d0
		bne.s	.GV2line
		
		move.l	a0,_TRN_SNXTLPTR(a6)
		
		movem.l	(sp)+,d0-d4/a0-a3/a5
		rts
		
		****************
	************************************
		****************

		; routine lecture 4 plans vdi
.GetV4:
		movem.l	d0-d6/a0-a5,-(sp)
		
		move.l	_TRN_SNXTLPTR(a6),a0
		move.l	_TRN_SBITOFF(a6),a1
		move.l	a1,a2
		move.l	a2,a3
		add.l	a0,a1
		add.l	a1,a2
		add.l	a2,a3
		
		move.l	_TRN_SPAL(a6),a4
		
		move.l	_TRN_SMFDB(a6),a5
		move	mfdb_wordw(a5),d0
		
		move.l	_TRN_SLINE(a6),a5
.GV4line		
		move	(a0)+,d1
		move	(a1)+,d2
		move	(a2)+,d3
		move	(a3)+,d4
		
		moveq	#16,d5
.GV4word		
		clr	d6
		add	d1,d1
		addx	d6,d6
		add	d2,d2
		addx	d6,d6
		add	d3,d3
		addx	d6,d6
		add	d4,d4
		addx	d6,d6
		
		add	d6,d6
		add	d6,d6
		move.b	1(a4,d6.w),(a5)+
		move.b	2(a4,d6.w),(a5)+
		move.b	3(a4,d6.w),(a5)+
		
		subq	#1,d5
		bne.s	.GV4word
		
		subq	#1,d0
		bne.s	.GV4line
		
		move.l	a0,_TRN_SNXTLPTR(a6)
		
		movem.l	(sp)+,d0-d6/a0-a5
		rts
		
		****************
	************************************
		****************

		; routine lecture 4 plans videl
.GetH4:
		movem.l	d0-d6/a0/a4/a5,-(sp)
		
		move.l	_TRN_SNXTLPTR(a6),a0
		
		move.l	_TRN_SPAL(a6),a4
		
		move.l	_TRN_SMFDB(a6),a5
		move	mfdb_wordw(a5),d0
		
		move.l	_TRN_SLINE(a6),a5
.GH4line		
		movem	(a0)+,d1-4
		
		moveq	#16,d5
.GH4word		
		clr	d6
		add	d1,d1
		addx	d6,d6
		add	d2,d2
		addx	d6,d6
		add	d3,d3
		addx	d6,d6
		add	d4,d4
		addx	d6,d6
		
		add	d6,d6
		add	d6,d6
		move.b	1(a4,d6.w),(a5)+
		move.b	2(a4,d6.w),(a5)+
		move.b	3(a4,d6.w),(a5)+
		
		subq	#1,d5
		bne.s	.GH4word
		
		subq	#1,d0
		bne.s	.GH4line
		
		move.l	a0,_TRN_SNXTLPTR(a6)
		
		movem.l	(sp)+,d0-d6/a0/a4/a5
		rts
		
		****************
	************************************
		****************

		; routine lecture 8 plans vdi
.GetV8:
		movem.l	d0-a5,-(sp)
		
		move.l	_TRN_SNXTLPTR(a6),a0
		move.l	_TRN_SBITOFF(a6),a1
		move.l	a1,d7
		add.l	a1,a1
		move.l	a1,a2
		move.l	a2,a3
		add.l	a0,a1
		add.l	a1,a2
		add.l	a2,a3
		
		move.l	_TRN_SPAL(a6),a4
		
		move.l	_TRN_SMFDB(a6),a5
		move	mfdb_wordw(a5),d0
		
		move.l	_TRN_SLINE(a6),a5
.GV8line		
		move	(a0,d7.l),d1
		swap	d1
		move	(a0)+,d1
		
		move	(a1,d7.l),d2
		swap	d2
		move	(a1)+,d2
		
		move	(a2,d7.l),d3
		swap	d3
		move	(a2)+,d3
		
		move	(a3,d7.l),d4
		swap	d4
		move	(a3)+,d4
		
		moveq	#16,d5
.GV8word		
		clr	d6
		
		add	d1,d1
		addx	d6,d6
		swap	d1
		add	d1,d1
		addx	d6,d6
		swap	d1
		
		add	d2,d2
		addx	d6,d6
		swap	d2
		add	d2,d2
		addx	d6,d6
		swap	d2
		
		add	d3,d3
		addx	d6,d6
		swap	d3
		add	d3,d3
		addx	d6,d6
		swap	d3
		
		add	d4,d4
		addx	d6,d6
		swap	d4
		add	d4,d4
		addx	d6,d6
		swap	d4
		
		add	d6,d6
		add	d6,d6
		move.b	1(a4,d6.w),(a5)+
		move.b	2(a4,d6.w),(a5)+
		move.b	3(a4,d6.w),(a5)+
		
		subq	#1,d5
		bne.s	.GV8word
		
		subq	#1,d0
		bne.s	.GV8line
		
		move.l	a0,_TRN_SNXTLPTR(a6)
		
		movem.l	(sp)+,d0-a5
		rts
		
		****************
	************************************
		****************

		; routine lecture 8 plans videl
.GetH8:
		movem.l	d0-6/a0/a4/a5,-(sp)
		
		move.l	_TRN_SNXTLPTR(a6),a0
		
		move.l	_TRN_SPAL(a6),a4
		
		move.l	_TRN_SMFDB(a6),a5
		move	mfdb_wordw(a5),d0
		
		move.l	_TRN_SLINE(a6),a5
.GH8line		
		movem.l	(a0)+,d1-4
		
		moveq	#16,d5
.GH8word		
		clr	d6
		
		swap	d1
		add	d1,d1
		addx	d6,d6
		swap	d1
		add	d1,d1
		addx	d6,d6
		
		swap	d2
		add	d2,d2
		addx	d6,d6
		swap	d2
		add	d2,d2
		addx	d6,d6
		
		swap	d3
		add	d3,d3
		addx	d6,d6
		swap	d3
		add	d3,d3
		addx	d6,d6
		
		swap	d4
		add	d4,d4
		addx	d6,d6
		swap	d4
		add	d4,d4
		addx	d6,d6
		
		add	d6,d6
		add	d6,d6
		move.b	1(a4,d6.w),(a5)+
		move.b	2(a4,d6.w),(a5)+
		move.b	3(a4,d6.w),(a5)+
		
		subq	#1,d5
		bne.s	.GH8word
		
		subq	#1,d0
		bne.s	.GH8line
		
		move.l	a0,_TRN_SNXTLPTR(a6)
		
		movem.l	(sp)+,d0-6/a0/a4/a5
		rts
		
		****************
	************************************
		****************

		; routine lecture 8 bits 'chunky'
.GetChunk8:
		movem.l	d0-a5,-(sp)
		
		move.l	_TRN_SNXTLPTR(a6),a0
		move.l	_TRN_SPAL(a6),a4
		
		move.l	_TRN_SMFDB(a6),a5
		move	mfdb_wordw(a5),d0
		lsl	#4,d0
		
		move.l	_TRN_SLINE(a6),a5
		moveq	#0,d6
.GC8line		
		rept	4
		
		move.b	(a0)+,d6
		move.l	1(a4,d6.w*4),(a5)
		addq	#3,a5
		
		endr
		
		subq	#4,d0
		bgt.s	.GC8line
		
		move.l	a0,_TRN_SNXTLPTR(a6)
		
		movem.l	(sp)+,d0-a5
		rts
		
		****************
	************************************
		****************

		; routine lecture 16bits falcon
.GetH16:
		movem.l	d0/d6/a0/a4/a5,-(sp)
		
		move.l	_TRN_SNXTLPTR(a6),a0
		
		move.l	_TRN_SMFDB(a6),a5
		move	mfdb_wordw(a5),d0
		lsl	#3,d0
		
		move.l	_TRN_SLINE(a6),a5
		
		move	#%11111000,d1
		move	#%11111100,d2
.GH16line		
		rept	2
		
		move	(a0)+,d6
		move	d6,d5
		move	d5,d4
		
		rol.w	#8,d6
		and.w	d1,d6
		move.b	d6,(a5)+
		
		lsr	#3,d5
		and	d2,d5
		move.b	d5,(a5)+
		
		lsl.w	#3,d4
		and.w	d1,d4
		move.b	d4,(a5)+
		
		endr
		
		subq	#1,d0
		bne.s	.GH16line
		
		move.l	a0,_TRN_SNXTLPTR(a6)
		
		movem.l	(sp)+,d0/d6/a0/a4/a5
		rts
		
		****************
	
***************************************************************************
***************************************************************************
***************************************************************************
		
		****************
		
		; Routines d'‚criture de pixels de cible,
		; pour les modes ind‚x‚s (palette),
		; (Entr‚e standard 8 bits chunky),
		
		; La ligne ou ‚crire est point‚e par _TRN_DNXTLPTR
		; L'entr‚e est en index‚ 1 byte en _TRN_DLINE.
		
		****************

		; routine ‚criture 1 plan videl/vdi
.PutV1:
		movem.l	d0/d1/a0/a1/a5,-(sp)
		
		move.l	_TRN_DLINE(a6),a0
		move.l	_TRN_DNXTLPTR(a6),a1
		
		move.l	_TRN_DMFDB(a6),a5
		move	mfdb_wordw(a5),d0
.PV1loop
		moveq	#0,d1
		move.b	(a0)+,d1
		
		rept	15
		add.w	d1,d1
		add.b	(a0)+,d1
		endr
		
		move.w	d1,(a1)+
		
		subq	#1,d0
		bne.s	.PV1loop
		
		move.l	a1,_TRN_DNXTLPTR(a6)
		
		movem.l	(sp)+,d0/d1/a0/a1/a5
		rts
		
		****************

		; routine ‚criture 2 plans videl
.PutH2:
		movem.l	d0-d3/a0/a1/a5,-(sp)
		
		move.l	_TRN_DLINE(a6),a0
		move.l	_TRN_DNXTLPTR(a6),a1
		
		move.l	_TRN_DMFDB(a6),a5
		move	mfdb_wordw(a5),d0
		moveq	#0,d1
.PH2loop
		moveq	#0,d2
		moveq	#0,d3
		
		move.b	(a0)+,d1
		lsr.w	#1,d1
		addx.w	d2,d2
		move.w	d1,d3
		
		rept	15
		move.b	(a0)+,d1
		lsr.w	#1,d1
		addx.w	d2,d2
		add.w	d3,d3
		or.w	d1,d3
		endr
		
		move.w	d2,(a1)+
		move.w	d3,(a1)+
		
		subq	#1,d0
		bne	.PH2loop
		
		move.l	a1,_TRN_DNXTLPTR(a6)
		
		movem.l	(sp)+,d0-d3/a0/a1/a5
		rts
		
		****************

		; routine ‚criture 4 plans videl
.PutH4:
		movem.l	d0-d6/a0/a1/a5,-(sp)
		
		move.l	_TRN_DLINE(a6),a0
		move.l	_TRN_DNXTLPTR(a6),a1
		
		move.l	_TRN_DMFDB(a6),a5
		move	mfdb_wordw(a5),d0
.PH4loop
		moveq	#8,d6
.PH4loop2
		move.w	(a0)+,d1
		
		lsl.b	#4,d1
		lsr.w	#4,d1
		
		rept	2
		
		add.b	d1,d1
		addx	d2,d2
		add.b	d1,d1
		addx	d3,d3
		add.b	d1,d1
		addx	d4,d4
		add.b	d1,d1
		addx	d5,d5
		
		endr
		
		subq	#1,d6
		bne	.PH4loop2
		
		move.w	d5,(a1)+
		move.w	d4,(a1)+
		move.w	d3,(a1)+
		move.w	d2,(a1)+
		
		subq	#1,d0
		bne	.PH4loop
		
		move.l	a1,_TRN_DNXTLPTR(a6)
		
		movem.l	(sp)+,d0-d6/a0/a1/a5
		rts
		
		****************

		; routine ‚criture 8 plans videl
.PutH8:
		movem.l	d0-a5,-(sp)
		
		move.l	_TRN_DLINE(a6),a0
		move.l	_TRN_DNXTLPTR(a6),a1
		
		move.l	_TRN_DMFDB(a6),a5
		move	mfdb_wordw(a5),d0
.PH8loop
		moveq	#4,d6
.PH8loop2		
		move.l	(a0)+,d1
		
		rept	4
		
		swap	d2
		add.l	d1,d1
		addx	d2,d2
		swap	d2
		add.l	d1,d1
		addx	d2,d2
		
		swap	d3
		add.l	d1,d1
		addx	d3,d3
		swap	d3
		add.l	d1,d1
		addx	d3,d3
		
		swap	d4
		add.l	d1,d1
		addx	d4,d4
		swap	d4
		add.l	d1,d1
		addx	d4,d4
		
		swap	d5
		add.l	d1,d1
		addx	d5,d5
		swap	d5
		add.l	d1,d1
		addx	d5,d5
		
		endr
		
		subq	#1,d6
		bne	.PH8loop2
		
		swap	d5
		move.l	d5,(a1)+
		swap	d4
		move.l	d4,(a1)+
		swap	d3
		move.l	d3,(a1)+
		swap	d2
		move.l	d2,(a1)+
		
		subq	#1,d0
		bne	.PH8loop
		
		move.l	a1,_TRN_DNXTLPTR(a6)
		
		movem.l	(sp)+,d0-a5
		
		rts
		
		****************
		
***************************************************************************

	************************************
		
		****************

		; Ici c'est le cas particulier du TrueColor ...
		; En effet il n'y a pas de tramage pr‚vu dans ces cas !
		; Et de plus ,il faut traiter ici le problŠme des
		; cartes video plus ou moins exotiques ...
.TrueColor:		
		; initialisation de l'espace de travail
		; (largeur source en 24 bits)
		; arrondi sur 16 octets (favorise les caches)
		
		move.l	_TRN_WRKSPC(a6),d0
		add.l	#$0000000f,d0
		and.l	#$fffffff0,d0
		move.l	d0,_TRN_SLINE(a6)
		
		; S‚lection de la routine de sortie TrueColor.
		
		; pour l'instant disons falcon 16 bits
		move.l	#.PutFalcon16,_TRN_PUTNEXT(a6)
		
		move.l	_TRN_GETNEXT(a6),a0
		move.l	_TRN_PUTNEXT(a6),a1
		move	_TRN_YCOUNT(a6),d0
		
		; standardisation d'une ligne source
.Map		
		jsr	(a0)
		
		; ‚criture dans le format truecolor cible
		
		jsr	(a1)
		
		subq	#1,d0
		bne.s	.Map
		
		bra	.Fin	; gn‚ finieuuu , lalalŠreuu !
		
		****************
		
		; Routines d'‚criture de pixels cible,
		; pour les modes truecolor , l'entr‚e
		; est standardis‚e en R/V/B 24 bits...
.PutFalcon16:
		move.l	_TRN_SLINE(a6),a5
		move.l	_TRN_DNXTLPTR(a6),a4
		
		move	_TRN_XCOUNT(a6),d7
		add	#$000f,d7
		and	#$fff0,d7
		
		move	#%1111100000000000,d6
		move	#%0000011111100000,d5
		moveq	#0,d1
.houp		
		move.b	(a5)+,d3
		lsl.w	#8,d3
		and.w	d6,d3
		
		move.b	(a5)+,d2
		lsl.w	#3,d2
		and.w	d5,d2
		
		move.b	(a5)+,d1
		lsr.w	#3,d1
		or.w	d1,d2
		or.w	d2,d3
		
		move.w	d3,(a4)+
		
		subq.w	#1,d7
		bne.s	.houp
		
		move.l	a4,_TRN_DNXTLPTR(a6)
		rts
		
		****************

***************************************************************************
		
	************************************
		
		****************
		SECTION DATA
		****************
		
*.GetH4		dc.l	"RIEN"
.GetH2		dc.l	"RIEN"
*.GetH16		dc.l	"RIEN"
.GetH24		dc.l	"RIEN"

;.PutV1		dc.l	"RIEN"
.PutV2		dc.l	"RIEN"
.PutV4		dc.l	"RIEN"
.PutV8		dc.l	"RIEN"
;.PutH2		dc.l	"RIEN"
.PutH16		dc.l	"RIEN"
.PutH24		dc.l	"RIEN"
		
		
		****************
		
		; routines de lecture source vdi
.TableGetVdi:
		dc.l	.GetV1	; 1 plan
		dc.l	.GetV2	; 2 plans
		dc.l	0
		dc.l	.GetV4	; 4 plans
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	.GetV8	; 8 plans
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	.GetH16	; True 16bits
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	.GetH24	; True 24bits
		
		; routines de lecture source videl
.TableGetVidel:
		dc.l	.GetV1
		dc.l	.GetH2
		dc.l	0
		dc.l	.GetH4
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	.GetH8
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	.GetH16
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	.GetH24
		
		; routines de lecture source 'chunky'
.TableGetChunky:
		dc.l	.GetV1
		dc.l	.GetH2
		dc.l	0
		dc.l	.GetH4
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	.GetChunk8
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	.GetH16
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	.GetH24
		
		****************
		
		; routines d'‚criture cible vdi
.TablePutV:
		dc.l	.PutV1
		dc.l	.PutV2
		dc.l	0
		dc.l	.PutV4
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	.PutV8
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	.PutH16
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	.PutH24
		
		; routines d'‚criture cible videl
.TablePutH:
		dc.l	.PutV1
		dc.l	.PutH2
		dc.l	0
		dc.l	.PutH4
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	.PutH8
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	.PutH16
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	.PutH24
		
		****************
		
		
	************************************

***************************************************************************
