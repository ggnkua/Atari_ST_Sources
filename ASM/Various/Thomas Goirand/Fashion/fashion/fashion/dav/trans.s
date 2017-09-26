		
		; exemple d'utilisation du transformeur 
		
		; on suppose un gpix point‚ par A5
		; structure PIX associ‚e point‚e par A1
		
		; (screen_mfdb est le mfdb d‚crivant l'‚cran
		; et ne sert que pour exemple)
		
blougou		
		lea 	structure,a4	; et un petit buffer en A4
		
		lea	_PIX_MFDB(a1),a2
		move.l	mfdb_addr(a2),_TX_SPTR(a4)
		move.l	mfdb_addr(a2),_TX_DPTR(a4)
		
		moveq	#0,d0
		move.w	mfdb_w(a2),d0
		move.l	d0,_TX_SW(a4)
		move.l	d0,_TX_DW(a4)
		move.w	mfdb_h(a2),d0
		move.l	d0,_TX_SH(a4)
		move.l	d0,_TX_DH(a4)
		
		move.w	mfdb_planes(a2),_TX_SBPP(a4)
		move.w	mfdb_format(a2),_TX_SFORM(a4)
		
		move.w	SCREEN_MFDB+mfdb_planes,_TX_DBPP(a4)
		move.w	SCREEN_MFDB+mfdb_format,_TX_DFORM(a4)
		
		; le r‚sultat sera-t-il plus grand que la source ?
		
		move.w	_TX_DBPP(a4),d0
		cmp.w	_TX_SBPP(a4),d0
		ble.s	.OkSize
		
		; si c'est le cas il faut allouer un bloc pour la cible
		
		mulu.w	mfdb_wordw(a2),d0
		mulu.w	mfdb_h(a2),d0
		add.l	d0,d0
		
		; allocation
		
		movem.l	d0-d2/a0-a2,-(sp)
		move.l	d0,-(sp)
		GEM	MALLOC
		move.l	d0,_TX_DPTR(a4)
		movem.l	(sp)+,d0-d2/a0-a2
		
.OkSize		
		move.l	_PIX_PALETTE(a1),_TX_SPALOB(a4)
		move.l	#_SYS_PALETTE,_TX_DPALOB(a4)
		
		; mettre ici le mode de tramage d‚sir‚ (7,8,9)
		
		move.w	mode_de_tramage,_TX_DIT(a4)
		
		; mettre ici le nombre de lignes … traiter
		; … chaque invocation ($7FFFFFFF si traitement
		; en une seule fois...
		
		move.l	speed_factor,_TX_SPEED(a4)
		
		; conversion / tramage
		
		pea	(a4)
		jsr	trans_thomas
		lea	4(sp),sp
		
		move.w	_GPIX_FLAGS(a5),d1
		btst	#3,d1
		bne.s	.okthr
		
		***
		
		move.l	a6,-(sp)
		move.l	d0,a6
.ythr		
		jsr	([_TX_PROC.w,a6])
		
		cmp.w	#3,_TX_STATUS(a6)
		bne.s	.ythr
		
		move.l	(sp)+,a6
.okthr		
		***
		
		; on d‚salloue l'ancien bloc si la translation
		; l'a relog‚ ailleurs ...
		
		lea	_PIX_MFDB(a1),a2
		move.l	_TX_DPTR(a4),d0
		move.l	mfdb_addr(a2),d1
		
		move.l	d0,mfdb_addr(a2)
		cmp.l	d0,d1
		beq.s	.okaddr
		
		movem.l	d0-d2/a0-a2,-(sp)
		move.l	d0,-(sp)
		GEM	MALLOC
		movem.l	(sp)+,d0-d2/a0-a2
		
		***
.okaddr		
		move.w	SCREEN_MFDB+mfdb_planes,_PIX_MFDB+mfdb_planes(a1)
		move.w	#0,_PIX_MFDB+mfdb_format(a1)
		
		move.l	_PIX_NEXT(a1),a1
		cmp.l	a3,a1
		bne	.Another
		
		***

		; ici un petit buffer pour la structure TX
structure		
		dcb.b	_TX_STRUCTSIZE,0
		
		; ici l'inclusion du binaire

trans_thomas	incbin	\wlib\bin\txmaster.bin
		
		***
