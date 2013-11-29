	SECTION	text
markBlock
	cmpi.w	#1,mouseClick
	bne	.done

	lea	sampleInfoTable,a3

	tst.w	sampleLoaded(a3)
	beq	.done

	tst.w	mainWindowIconise
	bne	.done

; get window work area

	wind_get	mainWindowHandle,#4

	movem.w	intout+2,d1-d4

	addq.w	#8,d1
	sub.w	#8,d3
	add.w	d1,d3
	sub.w	#8,d3
	add.w	d2,d4
	subq.w	#1,d4

	move.w	mouseX,d0

	cmp.w	d0,d1	; < windStart
	bgt	.done
	cmp.w	d0,d3	; > windEnd
	blt	.done

	move.w	mouseY,d0
	
	cmp.w	d0,d2	; < top
	bgt	.done
	
	cmp.w	d0,d4	; > bottom
	blt	.done

	move.l	a7,a6	; store stack pointer

	move.w	d1,-(sp)	; windStart: -2(a6)
	move.w	d3,-(sp)	; windEnd: -4(a6)

; set draw mode to XOR

	vswr_mode	wsHandle,#3

; hide mouse + lock screen
	graf_mouse	#256,#0
	wind_update	#1

	vsf_color	wsHandle,#1	; colour=black

; is there a block already defined?
	lea	blockArea,a0
	tst.w	blockDefined(a0)
	beq	.noPreviousBlock

	v_bar	wsHandle,blockX(a0),blockY(a0),blockX2(a0),blockY2(a0)
	clr.l	blockX(a0)
	clr.l	blockX2(a0)
.noPreviousBlock

	move.w	mouseX,d1

; draw the starting block
	v_bar	wsHandle,d1,d2,d1,d4

; show mouse + unlock screen
	graf_mouse	#257,#0
	wind_update	#0

; Begin marking loop

.markingLoop
	graf_mkstate

	;intout+2     x mouse coord
             ;intout+4     y mouse coord
             ;intout+6      mouse  button   state;

	movem.w	intout+2,d5-d7

	tst.w	d7	; button no longer down?
	beq	.marked

	move.w	-2(a6),d0
	cmp.w	d5,d0	; less than windStart?
	blt	.noStart
	move.w	d0,d5
.noStart
	move.w	-4(a6),d0
	cmp.w	d5,d0
	bgt	.noEnd
	move.w	d0,d5
.noEnd
	cmp.w	d1,d5	; has the mouse moved?
	beq	.markingLoop

; hide mouse + lock screen
	graf_mouse	#256,#0
	wind_update	#1

; remove old block
	v_bar	wsHandle,mouseX,d2,d1,d4
; draw new block
	v_bar	wsHandle,mouseX,d2,d5,d4

	move.w	d5,d1

; show mouse + unlock screen
	graf_mouse	#257,#0
	wind_update	#0

; store block coords
	move.w	mouseX,blockX(a0)
	move.w	d2,blockY(a0)
	move.w	d5,blockX2(a0)
	move.w	d4,blockY2(a0)
	bra	.markingLoop

.marked	; Set draw mode back to replace
	vswr_mode	wsHandle,#1

	move.w	blockX(a0),d1
	move.w	blockX2(a0),d2

	cmp.w	d1,d2	; end < start?
	bgt	.noSwap
	exg	d1,d2	; yes so swap start and end
	move.w	d1,blockX(a0)
	move.w	d2,blockX2(a0)
.noSwap
	cmp.w	d1,d2
	bne	.noReset

	move.w	mainWindowHandle,d0
	move.w	blockX(a0),d1
	move.w	blockY(a0),d2
	move.w	blockX2(a0),d3
	move.w	blockY2(a0),d4

	jsr	generalRedrawHandler
	clr.l	blockX(a0)
	clr.l	blockX2(a0)
	clr.w	blockDefined(a0)
	clr.l	blockStart
	move.l	sampleDataSize(a3),d0
	move.l	d0,blockEnd
	move.l	d0,blockSize

	move.w	mainWindowHandle,d0
	wind_get	#4,d0
	movem.w	intout+2,d1-d4
	jsr	generalRedrawHandler

	bra	.blockDefinitionDone
.noReset

; calculate sample offsets of the block points

; blockX - windStart    blockX2 - windStart
	sub.w	-2(a6),d1
	sub.w	-2(a6),d2
	subq.w	#1,d1
	bpl	.ok
	moveq.w	#0,d1
.ok
	subq.w	#1,d2

	move.l	sampleDataSize(a3),d0
	divu	#620,d0
	ext.l	d0
	move.l	d0,d3

	jsr	long_mul
	exg	d0,d3
	move.l	d2,d1
	jsr	long_mul
	move.l	d3,d1
	exg	d0,d1

	cmpi.w	#2,sampleChannels(a3)
	bne	.notStereo

.notStereo
; d0 = start offset, d1 = end offset
	move.l	d0,blockStart
	move.l	d1,blockEnd
	sub.l	d0,d1
	move.l	d1,blockSize
	move.w	#1,blockDefined(a0)

.blockDefinitionDone
	move.l	a6,a7	; restore stack pointer
.done
	rts
;------------------------------------------------------------
blockMoved
	move.w	mainWindowHandle,d0

	wind_get	d0,#6	; previous
	move.w	intout+2,d1

	lea	blockArea,a0
	move.w	blockX(a0),d3
	move.w	blockX2(a0),d4

	sub.w	d1,d3
	sub.w	d1,d4

	wind_get	d0,#4	; current
	movem.w	intout+2,d1-d2/d5-d6

	add.w	d1,d3
	add.w	d1,d4

	add.w	d2,d6
	subq.w	#1,d6

	subq.w	#1,d3
	subq.w	#1,d4

	move.w	d3,blockX(a0)
	move.w	d2,blockY(a0)
	move.w	d4,blockX2(a0)
	move.w	d6,blockY2(a0)

	rts
;------------------------------------------------------------
blockReset
	lea	blockArea,a0
	clr.l	blockX(a0)
	clr.l	blockX2(a0)
	clr.w	blockDefined(a0)
	clr.l	blockStart

	lea	sampleInfoTable,a3
	move.l	sampleDataSize,d0
	move.l	d0,blockEnd
	move.l	d0,blockSize

	clr.w	redrawCached
	move.w	mainWindowHandle,d0

	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	jsr	generalRedrawHandler

	rts
;------------------------------------------------------------
redrawMarkedBlock
	lea	blockArea,a0
	tst.w	blockDefined(a0)
	beq	.done
	vswr_mode	wsHandle,#3
	v_bar	wsHandle,blockX(a0),blockY(a0),blockX2(a0),blockY2(a0)
	vswr_mode	wsHandle,#1
.done
	rts
;------------------------------------------------------------
loadBlock
	clr.w	defaultFile
	stringLength	#samplePath
	ext.l	d1
	lea	samplePath,a0
	add.l	d1,a0
	stringTruncate	a0,#'\'

	cmpi.w	#$140,aesVersion
	bgt	.extended

	fsel_input	#samplePath,#defaultFile
	bra	.fileSelected

.extended
	rsrc_gaddr	#5,#LOADCLIP
	fsel_exinput	#samplePath,#defaultFile,addrout

.fileSelected
	tst.w	intout
	beq	.noLoad

	tst.w	intout+2
	beq	.noLoad

	stringLength	#samplePath
	ext.l	d1
	lea	samplePath,a3
	add.l	d1,a3
	stringTruncate	a3,#'\'	
	lea	samplePath,a3
	stringLength	a3
	ext.l	d1
	add.l	d1,a3
	stringCopy	#defaultFile,a3
	clr.b	(a1)

	tst.l	clipSize
	beq	.noCurrent

	m_free	clipAddress

.noCurrent
	f_sfirst	#%11111,#samplePath
	move.l	dta+26,d4	; filesize

	m_xalloc	#3,d4
	tst.l	d0
	beq	noMemoryForClipBuffer
	move.l	d0,clipAddress

	f_open	#0,#samplePath
	move.w	d0,d3
	f_read	clipAddress,d4,d3
	f_close	d3
	move.l	d4,clipSize
.noLoad
	rts
;------------------------------------------------------------
saveBlock
	tst.l	clipSize
	beq	.noSave

	clr.w	defaultFile
	stringLength	#samplePath
	ext.l	d1
	lea	samplePath,a0
	add.l	d1,a0
	stringTruncate	a0,#'\'

	cmpi.w	#$140,aesVersion
	bgt	.extended

	fsel_input	#samplePath,#defaultFile
	bra	.fileSelected

.extended
	rsrc_gaddr	#5,#SAVECLIP
	fsel_exinput	#samplePath,#defaultFile,addrout

.fileSelected
	tst.w	intout
	beq	.noSave

	tst.w	intout+2
	beq	.noSave

	stringLength	#samplePath
	ext.l	d1
	lea	samplePath,a3
	add.l	d1,a3
	stringTruncate	a3,#'\'	
	lea	samplePath,a3
	stringLength	a3
	ext.l	d1
	add.l	d1,a3
	stringCopy	#defaultFile,a3
	clr.b	(a1)

	c_conws	#samplePath
	evnt_keybd

	f_create	#0,#samplePath
	move.w	d0,d3
	f_write	clipAddress,clipSize,d3
	f_close	d3

.noSave
	rts
;------------------------------------------------------------
clearBlock
	tst.l	clipSize
	beq	.noClear

	m_free	clipAddress

.noClear
	rts
;------------------------------------------------------------
toggleGEMClipboard
	eor.w	#1,GEMClip
	rsrc_gaddr	#0,#MENUBAR
	menu_icheck	#GEMCLIP,GEMClip,addrout
	rts
;------------------------------------------------------------
	SECTION	bss

topLeftCursor	ds.w	1
topRightCursor	ds.w	1

bottomLeftCursor	ds.w	1
bottomRightCursor	ds.w	1

GEMClip

	rsreset
blockX	rs.w	1
blockY	rs.w	1
blockX2	rs.w	1
blockY2	rs.w	1
blockDefined	rs.w	1

blockArea	ds.w	5
blockStart	ds.l	1
blockEnd	ds.l	1
blockSize	ds.l	1