	COMMENT	HEAD=%111

	bra	START

	INCLUDE	SOUNDSYS.I
	TEXT

START:	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp

	move.l	$70.w,old70
	move.l	#NEWVBL,$70.w

	bsr	dspmod32_start
	lea	fuzzy_mod,a0
	bsr	dspmod32_play_module
	lea	vbl_msx,a0
	bsr	install_dspmod32irq

	move.w	#1,-(sp)
	trap	#1
	addq	#2,sp

	move.l	old70,$70.w
	bsr.l	dspmod32_stop

	clr.w	-(sp)
	trap	#1

NEWVBL:	addq.l	#1,$466.w
	movem.l	d0-a6,-(sp)
	move.l	vbl_msx(pc),a0
	jsr	(a0)
	movem.l	(sp)+,d0-a6
	rte

vbl_msx:
	DC.L	rts

rts:	rts

	DATA

fuzzy_mod:
	INCBIN	FUZZY.MOD
	EVEN

	BSS

old70:	DS.L	1
