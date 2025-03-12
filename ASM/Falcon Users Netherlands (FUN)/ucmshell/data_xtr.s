	OUTPUT	D:\CODING\UCMSHELL\DATA_XTR.TOS
	COMMENT	HEAD=%111
	OPT	D-,P=68000

	bra	START

archivemode:	=	1
	INCLUDE	INCLOAD.I
	TEXT

START:	Fopen	.dataname_txt(pc)
	move.w	d0,d0
	bmi	.error
	movem.l	a0-a1,-(sp)
	Fread	d0,dir_tbl,#maxlinkfiles*linkentrysize
	lea	dir_tbl,a1

.loop:	tst.b	(a1)
	beq.s	.end_loop

	lea	.dataname_txt(pc),a0
	movea.l	a1,a2
.chloop:
	move.b	(a1)+,d0
	beq.s	.endstring
	andi.b	#$df,d0
	cmp.b	(a0)+,d0
	beq.s	.chloop
	bra.s	.fix
.endstring:
	movea.l	a2,a1
	tst.b	(a0)
	beq.s	.skip
.fix:	movea.l	a2,a1

	move.l	a1,-(sp)
	lea	file_buf(pc),a0
	bsr	LOAD_INCFILETOBUF
	movea.l	(sp),a1
	exg	a0,a1
	bsr	save
	move.l	d0,d0
	bmi.s	.error
	movea.l	(sp)+,a1

.skip:	lea	linkentrysize(a1),a1
	bra.s	.loop
.end_loop:
.error:

	clr.w	-(sp)
	trap	#1

.dataname_txt:
	DC.B	"DATA",0
	EVEN

	BSS

filename_buf:
	DS.B	128
file_buf:
	DS.B	512*1024			* 512KB buffer