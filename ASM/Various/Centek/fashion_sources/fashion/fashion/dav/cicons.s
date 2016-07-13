
		****
		text
		****
		
		; translation d'icones couleur au format rsc
		; en format correspondant au mode video courant
		
		****
		
		; get_icons ( rsc , mfdb ,pal )
		
		; rsc  = pointeur sur rsc en ram
		; mfdb = pointeur sur mfdb d‚crivant l'‚cran
		; pal  = pointeur sur palette systŠme
		
		****
		
.get_icons
		****
		
		; conversion/tramage
		
		move.l	a0,a1
		move.l	a0,a3
		lea	_TX_STACK,a2
.yup		
		move.l	(a2)+,a4
		tst.l	_TX_PROC(a4)
		bne.s	.yup
.Another
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
		
		* passer en paramŠtre
		*move.l	#_SYS_PALETTE,_TX_DPALOB(a4)
		
		move.w	#8,_TX_DIT(a4)
		move.l	#99999,_TX_SPEED(a4)
		
		; conversion / tramage
		
		pea	(a4)
		jsr	_TX_MASTER
		lea	4(sp),sp
		
		***
		
		; on d‚salloue l'ancien bloc si la translation
		; l'a relog‚ ailleurs ...
		
		move.l	_TX_DPTR(a4),d0
		
		move.l	d0,_PIX_MFDB+mfd_addr(a1),a2
		
		***
.okaddr		
		move.w	SCREEN_MFDB+mfdb_planes,_PIX_MFDB+mfdb_planes(a1)
		move.w	#0,_PIX_MFDB+mfdb_format(a1)
		
		***
		