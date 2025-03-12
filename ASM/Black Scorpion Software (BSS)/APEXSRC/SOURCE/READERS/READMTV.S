*-----------------------------------------------------------------------*
*	68030 True-colour TARGA file loader & decompressor			*
*-----------------------------------------------------------------------*

mtv_space		=	12*2000	

*-----------------------------------------------------------------------*

examine_mtv:
	move.l	mtv_name,a0
	jsr		get_filesize
	move.l	d0,mtv_size
	move.l	mtv_name,a0
	bsr		OpenFile
	move.w	d0,mtv_handle
	bpl.s		.cont
	moveq		#-1,d0
	rts
.cont	lea		mtv_header,a0
.next	move.w	mtv_handle,d0
	moveq		#1,d1
	move.l	a0,-(sp)
	jsr		ReadFile
	move.l	(sp)+,a0
	subq.l	#1,mtv_size
	addq		#1,a0
	cmp.b		#10,-1(a0)
	bne.s		.next
	lea		mtv_header,a0
	moveq		#0,d0
	moveq		#0,d1
.nx	move.b	(a0)+,d0
	cmp.b		#' ',d0
	beq.s		.gx
	sub.w		#'0',d0
	mulu		#10,d1
	add.l		d0,d1
	bra.s		.nx
.gx	moveq		#0,d0
	moveq		#0,d2
.ny	move.b	(a0)+,d0
	cmp.b		#10,d0
	beq.s		.gy
	sub.w		#'0',d0
	mulu		#10,d2
	add.l		d0,d2
	bra.s		.ny
.gy	move.w	d1,mtv_width
	move.w	d2,mtv_height
	moveq		#0,d0
	rts

*-----------------------------------------------------------------------*

mtv_error:
	move.w	mtv_handle,d0
	bsr		CloseFile
	moveq		#-1,d0
	rts

*-----------------------------------------------------------------------*

read_mtv:
	move.w	mtv_width,d0
	mulu		mtv_height,d0
	move.l	d0,pixels
	bsr		decrunch_mtv
	move.w	mtv_handle,d0
	bsr		CloseFile
	moveq		#0,d0
	rts

*-----------------------------------------------------------------------*

decrunch_mtv:
	push.l	mtv
.loop	jsr		read_mtv_block
	move.l	mtv,a1
	move.l	CIRCULAR_BUFFER,a0
	move.l	counter,d7
.rdlp	move.b	(a0)+,d1
	move.b	(a0)+,d2
	move.b	(a0)+,d3
	bfins		d1,d0{16:8}
	bfins		d2,d0{21:8}
	bfins		d3,d0{27:8}
	move.w	d0,(a1)+
	subq.l	#3,d7
	bgt.s		.rdlp
	move.l	a1,mtv
	tst.l		mtv_size
	ble.s		.stop
	tst.l		pixels
	bgt.s		.loop
.stop	pop.l		mtv
	rts	

*-----------------------------------------------------------*

read_mtv_block:
	move.l	mtv_size,d0
	move.l	mtv_chunksize,d1
	sub.l		d1,d0
	bpl.s		.cont
	moveq		#0,d0
	move.l	mtv_size,d1
.cont	move.l	d0,mtv_size
	move.l	d1,counter
	move.w	mtv_handle,d0
	move.l	CIRCULAR_BUFFER,a0
	jsr		ReadFile
	rts

mtv_chunksize:	dc.l	mtv_space

*-----------------------------------------------------------*
			bss
*-----------------------------------------------------------*

mtv_header:		ds.b	20

mtv_handle:		ds.w	1
mtv_name:		ds.l	1
mtv_size:		ds.l	1

mtv:			ds.l	1
mtv_width:		ds.w	1
mtv_height:		ds.w	1
			even

*-----------------------------------------------------------*
			text
*-----------------------------------------------------------*
