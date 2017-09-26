	text
	include	trnf.rs
	XREF	_SYS_DAC
icon_trans
	movem.l	d1-a6,-(sp)

	lea	trnf_tx_struct,a4
	move.l	60+4(sp),a5
	move.l	a5,_TX_SPTR(a4)	; adresse du bitmap source
	move.l	60+0(sp),a6
	move.l	a6,_TX_DPTR(a4)	; adresse du bitmap destination

	moveq.l	#0,d0
	move.w	mfdb_w(a5),d0
	move.l	d0,_TX_SW(a4)
	move.l	d0,_TX_DW(a4)
	move.w	mfdb_h(a5),d0
	move.l	d0,_TX_SH(a4)
	move.l	d0,_TX_DH(a4)

	move.w	mfdb_planes(a5),_TX_SBPP(a4)
	move.w	mfdb_format(a5),_TX_SFORM(a4)

	move.w	screen_mfdb+mfdb_planes,_TX_DBPP(a4)
	move.w	screen_mfdb+mfdb_format,_TX_DFORM(a4)

	move.l	#_SYS_PALETTE,_TX_SPALOB(a4)
	move.l	#_SYS_PALETTE,_TX_DPALOB(a4)

	move.w	#7,_TX_DIT(a4)

	move.l	#$7FFFFFFF,_TX_SPEED(a4)

	pea	(a4)
	jsr	tx_bin
	addq.l	#4,sp

	movem.l	(sp)+,d1-a6
	rts

tx_bin	incbin	dav\txmaster.bin

	bss
trnf_tx_struct	ds.b	_TX_STRUCTSIZE
	text
