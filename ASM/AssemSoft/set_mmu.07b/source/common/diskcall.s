		text

	;A0 = Address of filename
	;D0 = Mode
Fopen:		movem.l	d1-2/a0-2,-(sp)
 		move.w	d0,-(sp)
		move.l	a0,-(sp)
		move.w	#$3d,-(sp)
		trap	#1
		addq.l	#8,sp
		tst.l	d0
		movem.l	(sp)+,d1-2/a0-2
		rts

	;D0 = Handle number
Fclose:		movem.l	d1-2/a0-2,-(sp)
		move.w	d0,-(sp)
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp
		tst.l	d0
		movem.l	(sp)+,d1-2/a0-2
		rts

	;A0 = Address of data buffer
	;D0 = File handle
	;D1 = Number of bytes
Fread:		movem.l	d1-2/a0-2,-(sp)
		move.l	a0,-(sp)
		move.l	d1,-(sp)
		move.w	d0,-(sp)
		move.w	#$3f,-(sp)
		trap	#1
		lea	12(sp),sp
		tst.l	d0
		movem.l	(sp)+,d1-2/a0-2
		rts

	;A0 = Address of data buffer
	;D0 = File handle
	;D1 = Number of bytes
Fwrite:		movem.l	d1-2/a0-2,-(sp)

		move.l	a0,-(sp)
		move.l	d1,-(sp)
		move.w	d0,-(sp)
		move.w	#$40,-(sp)
		trap	#1
		lea	12(sp),sp
		tst.l	d0
		movem.l	(sp)+,d1-2/a0-2
		rts

	;A0 = Address of filename
	;D1 = File status
Fcreate:	movem.l	d1-2/a0-2,-(sp)
		move.w	d1,-(sp)
		move.l	a0,-(sp)
		move.w	#$3c,-(sp)
		trap	#1
		addq.l	#8,sp
		tst.l	d0
		movem.l	(sp)+,d1-2/a0-2
		rts

	;A0 = Address of filename
Fdelete:	movem.l	d1-2/a0-2,-(sp)
		move.l	a0,-(sp)
		move.w	#$41,-(sp)
		trap	#1
		addq.l	#6,sp
		tst.l	d0
		movem.l	(sp)+,d1-2/a0-2
		rts

	;A0 = Address of DTA buffer
Fsetdta:	movem.l	d1-2/a0-2,-(sp)
		move.l	a0,-(sp)
		move.w	#$1a,-(sp)
		trap	#1
		addq.l	#6,sp
		tst.l	d0
		movem.l	(sp)+,d1-2/a0-2
		rts

Fgetdta:	movem.l	d1-2/a0-2,-(sp)
		move.w	#$2f,-(sp)
		trap	#1
		addq.l	#2,sp
		tst.l	d0
		movem.l	(sp)+,d1-2/a0-2
		rts

	;A0 = Address of filename
	;d0 = File attribute
Fsfirst:	movem.l	d1-2/a0-2,-(sp)
		move.w	d0,-(sp)
		move.l	a0,-(sp)
		move.w	#$4e,-(sp)
		trap	#1
		addq.l	#8,sp
		tst.l	d0
		movem.l	(sp)+,d1-2/a0-2
		rts

Fsnext:		movem.l	d1-2/a0-2,-(sp)
		move.w	#$4f,-(sp)
		trap	#1
		addq.l	#2,sp
		tst.l	d0
		movem.l	(sp)+,d1-2/a0-2
		rts

	;D0 = File handle
	;D1 = Seek mode
	;d2 = Seek offset
Fseek:		movem.l	d1-2/a0-2,-(sp)
		move.w	d1,-(sp)
		move.w	d0,-(sp)
		move.l	d2,-(sp)
		move.w	#$42,-(sp)
		trap	#1
		lea	10(sp),sp
		tst.l	d0
		movem.l	(sp)+,d1-2/a0-2
		rts

	;D0 = Drive select
	;A0 = Address of pathname buffer
Dgetpath:	movem.l	d1-2/a0-2,-(sp)
		move.w	d0,-(sp)
		move.l	a0,-(sp)
		move.w	#$47,-(sp)
		trap	#1
		addq.l	#8,sp
		tst.l	d0
		movem.l	(sp)+,d1-2/a0-2
		rts

	;A0 = Address of pathname
Dsetpath:	movem.l	d1-2/a0-2,-(sp)
		move.l	a0,-(sp)
		move.w	#$3b,-(sp)
		trap	#1
		addq.l	#6,sp
		tst.l	d0
		movem.l	(sp)+,d1-2/a0-2
		rts

Dgetdrv:	movem.l	d1-2/a0-2,-(sp)
		move.w	#$19,-(sp)
		trap	#1
		addq.l	#2,sp
		tst.l	d0
		bmi.s	.error
		add.b	#65,d0
.error:		movem.l	(sp)+,d1-2/a0-2
		rts

	;D0 = Drive select
Dsetdrv:	movem.l	d1-2/a0-2,-(sp)
		move.w	d0,-(sp)
		move.w	#$e,-(sp)
		trap	#1
		addq.l	#4,sp
		tst.l	d0
		movem.l	(sp)+,d1-2/a0-2
		rts

	;A0 = Address to foldername
Dcreate:	movem.l	d1-2/a0-2,-(sp)
		move.l	a0,-(sp)
		move.w	#$39,-(sp)
		trap	#1
		addq.l	#6,sp
		tst.l	d0
		movem.l	(sp)+,d1-2/a0-2
		rts

Ddelete:	movem.l	d1-2/a0-2,-(sp)
		move.l	a0,-(sp)
		move.w	#$3a,-(sp)
		trap	#1
		addq.l	#6,sp
		tst.l	d0
		movem.l	(sp)+,d1-2/a0-2
		rts
