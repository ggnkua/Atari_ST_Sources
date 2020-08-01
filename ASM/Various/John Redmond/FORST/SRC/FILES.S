; FILES: file access words.
; Copyright <C> John Redmond 1989, 1990
; Public domain for non-commercial use.
;
	section	text
	even
;
_filemod: dc.w	14			;14 headers in module
	dc.w	savea7-_fmake		;length of module
;
_fmake: pop	d0			;file mode
	pop	d1			;^file name
	movem.l d2/a2/a3/a6,-(a7) 	;data stack ptr
	move.w	d0,-(a7)
	move.l	d1,-(a7)
	move.w	#$3c,-(a7)
	trap	#1
	add.l	#8,a7
	movem.l (a7)+,d2/a2/a3/a6
	push	d0			;returned value
	rts
;
_open:	pop	d0			;file mode
	pop	d1			;^file name
	movem.l	d2/a2/a3/a6,-(a7)	;data stack ptr
	move.w	d0,-(a7)
	move.l	d1,-(a7)
	move.w	#$3d,-(a7)
	trap	#1
	add.l	#8,a7
	movem.l (a7)+,d2/a2/a3/a6
	cmp.l	#-32,d0
	bgt	.opx
	lea	operror,a0
	bra	_error
.opx:	push	d0			;returned value
	rts
;
_close: pop	d0
	movem.l	d2/a2/a3/a6,-(a7)
	move.w	d0,-(a7)		;handle
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	movem.l (a7)+,d2/a2/a3/a6
	cmp.l	#-32,d0
	bgt	.clx
	lea	clerror,a0
	bra	_error
.clx:	rts
;
_seek:	movem.l d2,-(a7)
	pop	d0			;offset
	pop	d1			;seek mode
	pop	d2			;handle
	movem.l d2/a2/a3/a6,-(a7)
	move.w	d1,-(a7)
	move.w	d2,-(a7)
	move.l	d0,-(a7)
	move.w	#$42,-(a7)
	trap	#1
	add.l	#10,a7
	movem.l (a7)+,d2/a2/a3/a6
	push	d0			;position in file
	move.l	(a7)+,d2
	rts
;
_read:	move.l	d2,-(a7)
	movem.l (a6)+,d0-d2
	movem.l	d2/a2/a3/a6,-(a7)
	move.l	d1,-(a7)		;^buffer
	move.l	d0,-(a7)		;count
	move.w	d2,-(a7)		;handle
	move.w	#$3f,-(a7)
	trap	#1
	add.l	#12,a7
	movem.l (a7)+,d2/a2/a3/a6
	push	d0
	move.l	(a7)+,d2
	rts
;
_write: move.l	d2,-(a7)
	movem.l (a6)+,d0-d2
	movem.l d2/a2/a3/a6,-(a7)
	move.l	d2,-(a7)		;^buffer
	move.l	d0,-(a7)		;count
	move.w	d1,-(a7)		;handle
	move.w	#$40,-(a7)
	trap	#1
	add.l	#12,a7
	movem.l (a7)+,d2/a2/a3/a6
	push	d0
	move.l	(a7)+,d2
	rts
;
_malloc: pop	d0
	movem.l d2/a2/a3/a6,-(a7)
	move.l	d0,-(a7)
	move.w	#$48,-(a7)
	trap	#1
	addq.l	#6,a7
	movem.l (a7)+,d2/a2/a3/a6
	push	d0
	rts
;
_mfree: pop	d0
	movem.l d2/a2/a3/a6,-(a7)
	move.l	d0,-(a7)
	move.w	#$49,-(a7)
	trap	#1
	addq.l	#6,a7
	movem.l (a7)+,d2/a2/a3/a6
	push	d0
	rts
;
_fopen: pop	a1			;^name
	pop	d0			;fmode
	move.l	(a6),a0			;^file
	move.l	d0,16(a0)
	push	a1
	push	#0
	tst.l	d0			;fmode
	bne	.fo5			;create if non-zero
	bsr	_open			;open in read mode
	bra	.fo6
.fo5:	bsr	_fmake			;create new r/w file
.fo6:	pop	d0			;handle
	move.l	(a6),a0			;^file
	move.l	d0,12(a0)		;save handle in file
	push	#1024
	bsr	_malloc
	pop	d0			;^buffer
	pop	a0			;^file
	move.l	d0,4(a0)		;^next char
	move.l	d0,8(a0)		;^buffer
	clr.l	(a0)			;0 chars in buffer
	clr.l	20(a0)			;no chars so far written or read
	rts
;
_fclose: pop	a0			;^file
	move.l	16(a0),d0		;fmode
	beq	.fc5
	bsr	pblock
.fc5:	push	a0
	push	8(a0)			;^buffer
	bsr	_mfree
	addq.l	#4,a6			;drop result
	pop	a0
	push	12(a0)			;handle
	bsr	_close
	rts
;
_getc:	pop	d0
	cmp.l	#5,d0
	bgt	gc1			;get from file buffer
	asl.l	#2,d0
	lea	inp,a0
	move.l	0(a0,d0.l),d0		;get routine offset address
	jmp	(a5,d0.l)
bgetc:	pop	d0			;source
gc1:	move.l	d0,a0
	move.l	(a0),d1			;#chars in buffer
	bne	.gc6
	bsr	gblock
	tst.l	d1
	bne	.gc6
	move.l	#-1,d0			;return error
	bra	.gcx
.gc6:	clr.l	d0
	move.l	4(a0),a1
	move.b	(a1)+,d0
	move.l	a1,4(a0)
	subq.l	#1,d1
	move.l	d1,(a0)			;#chars still in buffer
.gcx:	push	d0			;return char
	rts
;
_putc:	pop	d0			;file handle
	cmp.l	#5,d0			;standard handle?
	bgt	.pc1
	asl.l	#2,d0
	lea	outp,a0
	move.l	0(a0,d0.l),d0		;get routine offset address
	jmp	(a5,d0.l)
.pc1:	move.l	d0,a0			;non-standard file address
	move.l	(a0),d1			;#chars in buffer
	cmp.l	#1024,d1		;full
	blt	.pc5
	bsr	pblock
.pc5:	pop	d0			;char
	move.l	4(a0),a1		;char pointer
	move.b	d0,(a1)+		;store char
	move.l	a1,4(a0)		;return pointer
	addq.l	#1,d1			;#chars there now
	move.l	d1,(a0)
	rts
;
bwrite: bsr	_write			;write with built-in check
	pop	d0
	bgt	.bwx
	lea	wrerror,a0
	bra	_error
.bwx:	rts
;
gblock: move.l	8(a0),4(a0)		;reset char pointer
	push	a0
	push	12(a0)			;handle
	push	8(a0)			;buffer address
	push	#1024			;buffer size
	bsr	_read
	pop	d1			;#chars read
	pop	a0			;^file
	move.l	d1,(a0)			;#chars read this time
	add.l	d1,20(a0)		;update total #chars read
	rts
;
pblock: move.l	(a0),d1			;a0 points to file
	beq	.pbx
	clr.l	(a0)			;0 chars to be left in buffer
	push	a0
	move.l	8(a0),4(a0)		;reset char pointer
	push	8(a0)			;^buffer
	push	12(a0)			;handle
	add.l	d1,20(a0)		;update #chars so far written
	push	d1			;#chars to write now
	bsr	_write
	addq.l	#4,a6			;drop result
	pop	a0
	clr.l	d1			;0 chars now in buffer
.pbx:	rts
;
_lseek: move.l	8(a6),a0		;^file
	move.l	12(a0),8(a6)		;file handle
	move.l	a0,-(a7)		;save ^file
	bsr	_seek
	move.l	(a7)+,a0
	clr.l	(a0)			;0 chars in buffer
	pop	20(a0)			;position in file
	rts
;
_ftell: pop	a0			;^file
	move.l	20(a0),d0
	tst.l	16(a0)			;get mode
	beq	.rd			;read mode
	add.l	(a0),d0			;else write mode
	bra	.posx
.rd:	sub.l	(a0),d0
.posx:	push	d0			;#chars read or written
	rts
;
savea7:	ds.l	1
;
dummy:	push	#0			;dummy input
	rts
;
_rename: pop	d0			;^ new name
	pop	d1			;^ old name
	movem.l	d2/a2/a3/a6,-(a7)
	move.l	d0,-(a7)
	move.l	d1,-(a7)
	move.w	#0,-(a7)		;dummy
	move.w	#$56,-(a7)
	trap	#1
	add.l	#12,a7
	movem.l (a7)+,d2/a2/a3/a6
	push	d0
	rts
;
_delete: pop	d0			;^name
	movem.l	d2/a2/a3/a6,-(a7)
	move.l	d0,-(a7)
	move.w	#$41,-(a7)
	trap	#1
	addq.l	#6,a7
	movem.l (a7)+,d2/a2/a3/a6
	push	d0
	rts
;
_chmod:	 movem.l (a6)+,d0/d1/a0		;^name,flag,attrib
	movem.l	d2/a2/a3/a6,-(a7)
	move.w	d0,-(a7)		;attrib
	move.w	d1,-(a7)		;mode
	move.l	a0,-(a7)		;^name
	move.w	#$43,-(a7)
	trap	#1
	add.l	#10,a7
	movem.l (a7)+,d2/a2/a3/a6
	push	d0
	rts
;
_setdrv: pop	d0			;drive
	movem.l	d2/a2/a3/a6,-(a7)
	move.w	d0,-(a7)		;drive
	move.w	#$0e,-(a7)
	trap	#1
	addq.l	#4,a7
	movem.l (a7)+,d2/a2/a3/a6
	push	d0			;bitmap of drives present
	rts
;
_getdrv: movem.l d2/a2/a3/a6,-(a7)
	move.w	#$19,-(a7)
	trap	#1
	addq.l	#2,a7
	movem.l (a7)+,d2/a2/a3/a6
	push	d0			;current drive
	rts
;

_chdir: pop	d0			;address of path
	movem.l	d2/a2/a3/a6,-(a7)
	move.l	d0,-(a7)		;path
	move.w	#$3b,-(a7)
	trap	#1
	addq.l	#6,a7
	movem.l (a7)+,d2/a2/a3/a6
	push	d0
	rts
;
_fdup:	pop	d0
	movem.l d2/a2/a3/a6,-(a7)
	move.w	d0,-(a7)		;standard handle
	move.w	#$45,-(a7)
	trap	#1
	addq.l	#4,a7
	movem.l (a7)+,d2/a2/a3/a6
	push	d0
	rts
;
_force: pop	d0			;standard handle
	pop	d1			;nonstandard handle
	movem.l d2/a2/a3/a6,-(a7)
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	trap	#1
	addq.l	#6,a7
	movem.l (a7)+,d2/a2/a3/a6
	push	d0
	rts
;
_setblock: pop	d0			;length
	pop	d1			;start of block
	movem.l d2/a2/a3/a6,-(a7)
	move.l	d0,-(a7)
	move.l	d1,-(a7)
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	add.l	#12,a7
	movem.l (a7)+,d2/a2/a3/a6
	push	d0
	rts
;
_sfirst: pop	d0			;attribute
	pop	d1			;^name
	movem.l d2/a2/a3/a6,-(a7)
	move.w	d0,-(a7)
	move.l	d1,-(a7)
	move.w	#$4e,-(a7)
	trap	#1
	addq.l	#8,a7
	movem.l (a7)+,d2/a2/a3/a6
	push	d0
	rts
;
_snext: movem.l d2/a2/a3/a6,-(a7)
	move.w	#$4f,-(a7)
	trap	#1
	addq.l	#2,a7
	movem.l (a7)+,d2/a2/a3/a6
	push	d0
	rts
;
_getdta: movem.l d2/a2/a3/a6,-(a7)
	move.w	#$2f,-(a7)
	trap	#1
	addq.l	#2,a7
	movem.l (a7)+,d2/a2/a3/a6
	push	d0
	rts
;
_setdta: pop	d0			;^dta
	movem.l d2/a2/a3/a6,-(a7)
	move.l	d0,-(a7)
	move.w	#$1a,-(a7)
	trap	#1
	addq.l	#6,a7
	movem.l (a7)+,d2/a2/a3/a6
	push	d0
	rts
;
_exec:	movem.l d2-d7/a2-a6,-(a7)
	lea	savea7,a0
	move.l	a7,(a0)
	pop	d0			;mode
	pop	d1			;file name
	pop	d2			;command line
	pop	d3			;environment

	move.l	d3,-(a7)
	move.l	d2,-(a7)
	move.l	d1,-(a7)
	move.w	d0,-(a7)
	move.w	#$4b,-(a7)
	trap	#1

	lea	savea7,a0
	move.l	(a0),a7
	movem.l	(a7)+,d2-d7/a2-a6
	add.l	#16,a6			;drop 4 parameters from data stack
	rts
;
open1:	bsr	getbuff			;(--^file,filehandle)
	clr.l	-(a6)			;file mode
	bsr	name
	add.l	#1,(a6)
	bsr	_fopen
	move.l	(a6),a0			;copy ^file
	push	12(a0)			;file handle
	rts
;
_load:	bsr	open1
	pop	d0			;get resulting handle
	bpl	.ldx
	lea	operror,a0
	bra	_error
.ldx:	bsr	pushin			;redirect & save old source
	rts
;
_run:	lea	.null,a0
	push	a0			;environment

	bsr	name			;BL WORD with check
	pop	a0
	moveq.l	#0,d0
	move.b	(a0)+,d0
	addq.l	#2,d0			;file name length
	
	push	a0
	push	d0
	bsr	_pad
	pop	d1
	move.l	d1,-(a7)		;save pad
	
	pop	d0
	push	d1			;pad
	push	d0			;length
	bsr	_cmove
	
	push	#13
	bsr	_word
	
	push	(a7)+			;file name
	
	push	#0			;mode
	bsr	_exec
	bsr	_key
	bsr	_drop
	rts
;
.null	dc.w	0
;
_save:	bsr	name
	add.l	#1,(a6)
	push	#0			;read-write mode
	bsr	_fmake
	pop	d0			;get result
	bpl	.sv5
	lea	operror,a0
	bra	_error
.sv5:	move.l	d0,-(a7)		;save file handle
;
	lea	cp,a0
	move.l	(a0),2(a5)		;code length into file header
	move.l	rstck(pc),d0
	add.l	heads(pc),d0
	add.l	work(pc),d0
	move.l	d0,10(a5)		;bss length
	bsr	_there
	pop	d0			;top of headers
	lea	stack,a0
	move.l	(a0),a1			;start of headers
	sub.l	a1,d0			;data length (headers)
	move.l	d0,6(a5)		;header length into file header
;
	push	a1			;start of headers
	push	(a7)			;file handle
	push	d0			;length of headers
;
	push	a5			;code start
	push	(a7)			;file handle
	push	2(a5)
;
	push	a5			;start of code
	push	(a7)			;file handle
	push	#28			;file header length
;
	bsr	bwrite			;file header
	bsr	bwrite			;code
	bsr	bwrite			;headers
;
	move.l	(a7)+,-(a6)		;file handle
	bsr	_close
	rts
;
	section	data
	even
;
	dc.b	$c7,'FILEMO','D'!$80
	vptrs	_filemod,20
;
	dc.b	$85,'FMAK','E'!$80
	ptrs	_fmake,18
;
	dc.b	$84,'OPEN',$a0
	ptrs	_open,18
;
	dc.b	$85,'CLOS','E'!$80
	ptrs	_close,18
;
	dc.b	$84,'SEEK',$a0
	ptrs	_seek,18
;
	dc.b	$84,'READ',$a0
	ptrs	_read,18
;
	dc.b	$85,'WRIT','E'!$80
	ptrs	_write,18
;
	dc.b	$85,'LSEE','K'!$80
	ptrs	_lseek,18
;
	dc.b	$85,'FTEL','L'!$80
	ptrs	_ftell,18
;
	dc.b	$85,'FOPE','N'!$80
	ptrs	_fopen,18
;
	dc.b	$86,'FCLOSE',$a0
	ptrs	_fclose,20
;
	dc.b	$84,'GETC',$a0
	ptrs	_getc,18
;
	dc.b	$84,'PUTC',$a0
	ptrs	_putc,18
;
	dc.b	$86,'MALLOC',$a0
	ptrs	_malloc,20
;
	dc.b	$85,'MFRE','E'!$80
	ptrs	_mfree,18
;
	dc.b	$84,'FDUP',$a0
	ptrs	_fdup,18
;
	dc.b	$85,'FORC','E'!$80
	ptrs	_force,18
;
	dc.b	$88,'SETBLOCK',$a0
	ptrs	_setblock,22
;
	dc.b	$86,'SETDRV',$a0
	ptrs	_setdrv,20
;
	dc.b	$86,'GETDRV',$a0
	ptrs	_getdrv,20
;
	dc.b	$85,'CHDI','R'!$80
	ptrs	_chdir,18
;
	dc.b	$84,'EXEC',$a0
	ptrs	_exec,18
;
	dc.b	$86,'DELETE',$a0
	ptrs	_delete,20
;
	dc.b	$86,'RENAME',$a0
	ptrs	_rename,20
;
	dc.b	$85,'CHMO','D'!$80
	ptrs	_chmod,18
;
	dc.b	$86,'SFIRST',$a0
	ptrs	_sfirst,20
;
	dc.b	$85,'SNEX','T'!$80
	ptrs	_snext,18
;
	dc.b	$86,'GETDTA',$a0
	ptrs	_getdta,20
;
	dc.b	$86,'SETDTA',$a0
	ptrs	_setdta,20
;
	dc.b	$84,'LOAD',$a0
	ptrs	_load,18
;
	dc.b	$83,'RU','N'!$80
	ptrs	_run,16
;
