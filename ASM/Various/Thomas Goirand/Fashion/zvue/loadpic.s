		include	d:\code\include\structs.s
		include	d:\code\include\gemdos.i
		include	d:\code\imgload\lib_trn2.s

		XREF	screen_mfdb

		XDEF	load_image
		XDEF	_TOS_DAC
load_image
		;move.l	_GPIX_LIST(a5),a0	; le chemin DU fichier
		move.l	a0,-(sp)	; chemin complet sur la pile
.chdot		
		cmp.b	#".",(a0)+
		bne.s	.chdot
		
		move.l	(a0)+,d0
		and.l	#$5f5f5f00,d0	; conversion majuscule (!)
		
		cmp.l	#"GIF"<<8,d0
		beq	.is_gif
		cmp.l	#"APX"<<8,d0
		beq	.is_apx
		cmp.l	#"JPG"<<8,d0
		beq	.is_jpg
		cmp.l	#"FTC"<<8,d0
		beq	.is_ftc
		cmp.l	#"NEO"<<8,d0
		beq	.is_neo
		cmp.l	#"BMP"<<8,d0
		beq	.is_bmp
		
		bra	.badpix
.is_apx		
		bsr	AesLoadApx
		bra	.chkpic
.is_gif
		bsr	AesLoadGif
		bra	.chkpic
.is_jpg
		bsr	AesLoadJpeg
		bra	.chkpic
.is_ftc
		bsr	AesLoadFtc
		bra	.chkpic
.is_neo
		bsr	AesLoadNeo
		bra	.chkpic
.is_bmp
		bsr	AesLoadBmp
		
		****
.chkpic		
		lea	4(sp),sp
		cmp.l	#$deadface,a0
		bne	.okpic
.badpix		
;		bra	.NoPix
		
		****
.okpic		
		; attention, etant donn‚ que la finalit‚ est de les porter
		; … l'‚cran les images seront converties suivant le nombre
		; de bits/pixel contenu dans le mfdb de base qu'il serait de
		; bon ton de faire correspondre … celui du mode video courant !
		
		move.l	a0,a1  ; retour de "bsr lod" (=structure pix)
		
		move.l	a0,a3
		lea	_TX_STACK,a2
.yup		
		move.l	(a2)+,a4
		tst.l	_TX_PROC(a4)
		bne.s	.yup
.Another
		
		; a2=mfdb source
		
		lea	pix_mfdb(a1),a2
		
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
		
		
		move.w	screen_mfdb+mfdb_planes,_TX_DBPP(a4)
		move.w	screen_mfdb+mfdb_format,_TX_DFORM(a4)
		
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
		Malloc	d0
		move.l	d0,_TX_DPTR(a4)
		movem.l	(sp)+,d0-d2/a0-a2
		
.OkSize		
		
		move.l	pix_palette(a1),_TX_SPALOB(a4)
		move.l	#_SYS_PALETTE,_TX_DPALOB(a4)
		
		move.w	#9,_TX_DIT(a4)   ; mode de tramage (9 = floid chtinberg)
		move.l	speed_factor,_TX_SPEED(a4) ; speed_factor (7fff... = super rapide et blokan)
		
		; conversion / tramage
		
		pea	(a4)
		jsr	_TX_MASTER
		lea	4(sp),sp
		
		;move.w	_GPIX_FLAGS(a5),d1
		;btst	#3,d1
		;bne.s	.okthr
		
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
		
		lea	pix_mfdb(a1),a2
		move.l	_TX_DPTR(a4),d0
		move.l	mfdb_addr(a2),d1
		
		move.l	d0,mfdb_addr(a2)
		cmp.l	d0,d1
		beq.s	.okaddr
		
		movem.l	d0-d2/a0-a2,-(sp)
		Malloc	d0
		movem.l	(sp)+,d0-d2/a0-a2
		
		***
.okaddr		
		lea	pix_mfdb(a1),a1
		move.w	screen_mfdb+mfdb_planes,mfdb_planes(a1)
		move.w	#0,mfdb_format(a1)
		rts

		****************
.ok_data
AesLoadApx:
		incbin	d:\code\imgload\mib\APXOBJ.MIB
AesLoadJpeg:
		incbin	d:\code\imgload\mib\JPEGOBJ.MIB
AesLoadGif:
		incbin	d:\code\imgload\mib\GIFOBJ.MIB
AesLoadFtc:
		incbin	d:\code\imgload\mib\FTC.MIB
AesLoadNeo:
		incbin	d:\code\imgload\mib\NEO.MIB
AesLoadBmp:
		incbin	d:\code\imgload\mib\BMP.MIB
		
		****************
;_TX_SPACE:
;		ds.b	8*_TX_STRUCTSIZE
speed_factor	dc.l	$7fffffff
_TOS_DAC:
		incbin	d:\code\lib3\XLIB\BIN\NETSCAPE.DAC
		
_SYS_COLORS:
		dc.l	2

		; ‚l‚ment palette systŠme
_SYS_PALETTE:
		dc.l	_TOS_DAC
		dc.l	0
		XDEF	nbr_color
nbr_color	dc.w	16
