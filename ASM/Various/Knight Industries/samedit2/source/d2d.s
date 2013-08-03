	SECTION	text
;---------------------------------------------------------------
allocateD2DBuffer
	movem.l	d0-d1/a0,-(sp)

; free previous buffer if it exists
	tst.l	D2DBuffer
	beq	.noPrevious

	m_free	D2DBuffer
	clr.l	D2DBuffer
.noPrevious
	lea	optionsTable,a0
	move.w	optionD2DSize(a0),d0
	ext.l	d0
	move.l	#1024,d1
	bsr	long_mul

	tst.l	d0
	ble	.done

	move.l	d0,D2DBuffer+4
	m_xalloc	#0,d0

	move.l	d0,D2DBuffer
	movem.l	(sp)+,d0-d1/a0

	tst.l	D2DBuffer
	beq	cantAllocateD2D
	rts
.done
	movem.l	(sp)+,d0-d1/a0
	rts
;---------------------------------------------------------------
clearD2DBuffer

	tst.l	D2DBuffer
	beq	cantAllocateD2D

	movem.l	d0-d1/a0,-(sp)

	lea	optionsTable,a0
	move.w	optionD2DSize(a0),d0
	ext.l	d0
	move.l	#1024,d1
	bsr	long_mul

	graf_mouse	#2,#0
	move.l	D2DBuffer,a0
.loop
	clr.b	(a0)+
	subq.l	#1,d0
	bgt	.loop

	graf_mouse	#0,#0
	movem.l	(sp)+,d0-d1/a0
	rts

;---------------------------------------------------------------
cantAllocateD2D
	rsrc_gaddr	#5,#NOD2D
	form_alert	#1,addrout

	rts
;---------------------------------------------------------------
generalD2DOperation

; d0 holds op code:  0 = read + write,  1 = read,   2 = write  ???
; a4 holds address of routine to perform

	move.w	d0,d7

	bsr	initD2DFunction

.process
	cmp.l	d2,d3
	bge	.noSizeAlter
	move.l	d3,d2
.noSizeAlter
	movem.l	d0-d2/a0-a2,-(sp)
	f_read	D2DBuffer,d2,d4	; read next part
	movem.l	(sp)+,d0-d2/a0-a2

	movem.l	d2-d7/a2-a6,-(sp)
	callModule	#2		; process
	movem.l	(sp)+,d2-d7/a2-a6
	move.l	D2DBuffer,a0		; store address
				; of buffer in a0
	move.l	d2,d0		; size to process
; jump to D2D operation address here
	movem.l	d0-d7/a0-a6,-(sp)
	pea	.write
	jmp	(a4)
.write
	movem.l	(sp)+,d0-d7/a0-a6
	cmpi.w	#1,d7		; write needed?
	beq	.noWrite
	
	movem.l	d2-d7/a2-a6,-(sp)
	callModule	#3		; process
	movem.l	(sp)+,d2-d7/a2-a6

	movem.l	d1-d2/a0-a2,-(sp)
	f_write	D2DBuffer,d2,d5	; write part
	movem.l	(sp)+,d1-d2/a0-a2

	cmp.l	d2,d0		; written the whole
	bne	diskFull		; buffer?
.noWrite
	sub.l	d2,d3		; filesize-=buffer size
	bgt	.process

endD2DFunction
	lea	sampleInfoTable,a3
	move.l	sampleDataSize(a3),d6
	sub.l	blockEnd,d6	; d6 holds size of rest of file
	ble	.close

	lea	optionsTable,a0
	move.w	optionD2DSize(a0),d0
	ext.l	d0
	move.l	#1024,d1
	bsr	long_mul
	move.l	d0,d3

.writeEnd
	cmp.l	d3,d6
	bgt	.noAlter
	move.l	d6,d3
.noAlter
	f_read	D2DBuffer,d3,d4
	f_write	D2DBuffer,d3,d5
	cmp.l	d3,d0
	bne	diskFull
	sub.l	d3,d6
	bgt	.writeEnd
.close
	f_close	d4
	f_close	d5

*	lea	samplePathname(a3),a3
*	f_delete	a3
*	f_rename	a3,#tempPath
	bsr	copyFileD2D
	rts

diskFull
	rsrc_gaddr	#5,#DISKFULL
	form_alert	#1,addrout

	f_close	d4
	f_close	d5
	f_delete	#tempPath	; remove temp file

	rts
;---------------------------------------------------------------
initD2DFunction

; on return d2 = D2D Buffer Size
;           d3 = size of block to process
;           d4 = read file handle
;           d5 = write file handle

	move.l	blockSize,d3
	lea	optionsTable,a0
	move.w	optionD2DSize(a0),d0
	ext.l	d0
	move.l	#1024,d1
	bsr	long_mul

	tst.l	d0
	beq	cantAllocateD2D

	move.l	d0,d2
	move.l	d3,d1

; d0 holds d2d size

	lea	sampleInfoTable,a3
	move.l	a3,a5
	add.l	#samplePathname,a5

; open the file
	movem.l	d0-d2/a0-a2,-(sp)
	f_open	#0,a5
	move.w	d0,d4		; read handle
	movem.l	(sp)+,d0-d2/a0-a2

	movem.l	d0-d4/a0-a6,-(sp)
	stringCopy	#optionsTable+optionTempPath,#tempPath
	move.l	a1,a5
	lea	sampleInfoTable,a3
	lea	samplePathname(a3),a3
	stringCopy	a3,#samplePath
	clr.b	(a1)
	stringLength	#samplePath
	subq.l	#1,a0
	stringTruncate	a0,#'\'

	stringLength	#samplePath
	ext.l	d1
	move.l	d1,d3
	stringLength	a3
	ext.l	d1
	sub.l	d3,d1
	addq.l	#1,d1
	sub.l	d1,a0	; a0 points to sample file name

	stringCopy	a0,a5
	clr.b	(a1)

	stringLocate	a5,#'.'	; find extension
	tst.w	d0
	bne	.noExtension
	subq.l	#1,a0
.noExtension
	move.b	#'t',(a0)+
	move.b	#'m',(a0)+
	move.b	#'p',(a0)+
	clr.b	(a0)

	f_create	#0,#tempPath
	move.w	d0,d5	; write handle

	movem.l	(sp)+,d0-d4/a0-a6

; read passed the header of the file
; and write a new header

	move.w	sampleHeaderSize(a3),d6
	beq	.blockSet
	ext.l	d6

	movem.l	d0-d2/a0-a2,-(sp)
	f_seek	#0,d4,d6
	movem.l	(sp)+,d0-d2/a0-a2

	movem.l	d1-d7/a0-a6,-(sp)
	callModule	#4
	movem.l	(sp)+,d1-d7/a0-a6

	movem.l	d0-d2/a0-a2,-(sp)
	f_write	#sampleHeader,d6,d5
	movem.l	(sp)+,d0-d2/a0-a2

	movem.l	d0-d3/d6/a0-a2,-(sp)
	move.l	d2,d6
	move.l	blockStart,d3
	beq	.blockStartSet
	cmp.l	d6,d3
	bgt	.blockSet
	move.l	d3,d6
.blockSet	; set pointers to start of block to edit

	f_read	D2DBuffer,d6,d4
	f_write	D2DBuffer,d6,d5

	sub.l	d6,d3
	bgt.s	.blockSet
.blockStartSet
	movem.l	(sp)+,d0-d3/d6/a0-a2

	rts
;-----------------------------------------------------------------------------
copyFileD2D
	lea	optionsTable,a0
	move.w	optionD2DSize(a0),d0
	ext.l	d0
	move.l	#1024,d1
	bsr	long_mul

; buffer size in d0
	move.l	d0,d3
	lea	tempPath,a3
	lea	sampleInfoTable,a4
	move.l	sampleDataSize(a4),d6	; size
	lea	samplePathname(a4),a4

	f_open	#0,a3	; temp path
	move.w	d0,d4	; temp handle
	f_create	#0,a4	; actual file
	move.w	d0,d5	; actual handle
.loop
	cmp.l	d3,d6
	bgt	.noFix
	move.l	d6,d3
.noFix
	f_read	D2DBuffer,d3,d4
	f_write	D2DBuffer,d3,d5
	sub.l	d3,d6
	bgt	.loop
	f_close	d3
	f_close	d4
	f_delete	a3	; remove temp file
	rts
;-----------------------------------------------------------------------------
	SECTION	bss
D2DBuffer	ds.l	2
