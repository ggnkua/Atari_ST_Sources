;##########################################
;#                                        #
;# Sam-Edit 2                             #
;#              Version 2.00 (22/04/1998) #
;# (C) 1998 Knight Industries             #
;#                                        #
;##########################################

	include	d:\samedit2\source\samedit2.h

	SECTION	text

	bra	initProgram

	include	d:\develop\new_libs\init.s
	include	d:\samedit2\samedit2.i

	SECTION	text

beginProgram
	rsrc_load	#resourceFile
	tst.w	intout
	beq	resourceError

	cmpi.w	#minX,screenW
	blt	resError

	cmpi.w	#minY,screenH
	blt	resError

	bsr	setDetails

** Load inf file **

	bsr	loadOptions

** Specific program initialisation **

	bsr	checkFalconSoundSystem
	bsr	falcSoundPatch
	bsr	loadModules
	bsr	getInfoAddresses

; placing this before the main windows are created allows for a switch to say that
; no visual feedback is required.
	jsr	cliHandler
	tst.w	noWindows
	bne	.loadInitialFile

; create and open the main windows

	wind_create	#19999,screenW,screenH,screenW,screenH

	move.w	intout,mainWindowHandle
		
; set window height for correct res
	move.w	#200,d7	; default for high resolutions
	
	cmpi.w	#300,screenH
	bgt	.not_medium

	move.w	#100,d7

.not_medium

	wind_open	intout,#0,screenY,#640,d7

	rsrc_gaddr	#5,#MAINWINDOWTITLE
	move.l	addrout,intin+4
	wind_set	mainWindowHandle,#2

	move.l	#mainWindowInfo,intin+4
	wind_set	mainWindowHandle,#3

	bsr	toolbar

	rsrc_gaddr	#0,#MENUBAR
	menu_bar	#1,addrout

.loadInitialFile
	tst.w	vaStart
	beq	mainLoop
	move.w	#OPEN,d0
	graf_mkstate
	move.w	intout+8,d0
	andi.w	#8,d0	; alt held down?
	beq	.noAlt
	move.w	#OPEND2D,d0
.noAlt
	bsr	openFile
	clr.w	vaStart

mainLoop	; this is the loop of the program
	bsr	events

	tst.w	d2dNext
	beq	mainLoop

	jsr	d2dPlayNext

	bra	mainLoop
;----------------------------------------------------------
quitRoutine	; Always call to exit the program

	jsr	stopSampleReplay
	bsr	closeAllDialogs
	bsr	releaseModules

	wind_close	mainWindowHandle
	wind_delete	mainWindowHandle

	lea	sampleInfoTable,a0
	tst.w	sampleLoaded(a0)
	beq	.end

	m_free	sampleAddress(a0)
.end
	tst.l	D2DBuffer
	beq	.end2

	m_free	D2DBuffer

.end2
	rsrc_free
	v_clsvwk	wsHandle

	cmpi.l	#$30000,machine
	bne	.exit

	move.w	#129,-(sp)
	trap	#xbios
	addq.w	#2,sp
.exit
	p_term	#0
;----------------------------------------------------------
programMoveWindow	; special cases for moving
		; non dialog windows
	tst.w	noWindows	; is there a gui?
	beq	.gui
	rts	; no redraw
.gui	; not really needed as no move message can be recieved
	cmp.w	mainWindowHandle,d0
	beq	blockMoved

	rts
;----------------------------------------------------------
programCloseWindow	; special cases for closing
		; non dialog windows

	wind_close	d0
	wind_delete	d0
	rts
;----------------------------------------------------------
programIconiseWindow	; special cases for iconsing
		; non dialog windows
	tst.w	noWindows	; is there a gui?
	beq	.gui
	rts	; no redraw
.gui	; not really needed as no iconise message can be received
	cmp.w	mainWindowHandle,d0
	beq	.iconiseMainWindow

	rts

.iconiseMainWindow
	eor.w	#1,mainWindowIconise
	rts
;----------------------------------------------------------
programRedraw
	tst.w	noWindows	; is there a gui?
	beq	.gui
	rts	; no redraw
.gui	; not really needed as no redraw messages should be received
	cmp.w	mainWindowHandle,d0
	beq	mainWindowRedraw

	rts
;----------------------------------------------------------
programClick
	tst.w	noWindows	; is there a gui?
	beq	.gui
	rts	; no redraw
.gui
	wind_find	mouseX,mouseY
	move.w	intout,d0

	cmp.w	mainWindowHandle,d0
	beq	markBlock

	rts
;----------------------------------------------------------
programBubbleGem

	rts
;----------------------------------------------------------
programKeys
	cmpi.w	#$180f,d0
	beq	openFile

	cmpi.w	#$1f13,d0
	beq	saveFile

	cmpi.w	#$2e00,d0
	beq	clearBuffer

	rts
;----------------------------------------------------------
programInput
	rts
;----------------------------------------------------------
programMenuHandler	; d0 holds menu item

	cmpi.w	#MAINOPTIONS,d0
	beq	editOptions
	cmpi.w	#SAVEOPTIONS,d0
	beq	saveOptions

	cmpi.w	#NEW,d0
	beq	create
	cmpi.w	#OPEN,d0
	beq	openFile
	cmpi.w	#OPEND2D,d0
	beq	openFile
	cmpi.w	#SAVE,d0
	beq	saveFile
	cmpi.w	#SAVEAS,d0
	beq	saveFileAs

	cmpi.w	#SAMINFO,d0
	beq	sampleInfo

	cmpi.w	#CLEARBUFFER,d0
	beq	clearBuffer

	cmpi.w	#CUT,d0
	beq	stepingStone
	cmpi.w	#COPY,d0
	beq	stepingStone
	cmpi.w	#DELETE,d0
	beq	stepingStone
	cmpi.w	#TRIM,d0
	beq	stepingStone
	cmpi.w	#PASTE,d0
	beq	stepingStone
	cmpi.w	#OVERLAY,d0
	beq	stepingStone
	cmpi.w	#BLOCKRESET,d0
	beq	stepingStone
	cmpi.w	#ALTERINFO,d0
	beq	stepingStone
	cmpi.w	#CLIPLOAD,d0
	beq	stepingStone
	cmpi.w	#CLIPSAVE,d0
	beq	stepingStone
	cmpi.w	#CLIPCLEAR,d0
	beq	stepingStone
	cmpi.w	#GEMCLIP,d0
	beq	stepingStone

	cmpi.w	#SIGNUNSIGN,d0
	beq	signUnsign
	cmpi.w	#REVERSE,d0
	beq	reverseSample
	cmpi.w	#AMPLIFYSAMPLE,d0
	beq	amplifySample
	cmpi.w	#FADESAMPLE,d0
	beq	fadeSample
	cmpi.w	#RESAMPLESAMPLE,d0
	beq	resampleSample
	cmpi.w	#CONVERTFORMAT,d0
	beq	stepingStone

	rts
;----------------------------------------------------------
programVaStart
	lea	messageBuffer,a0
	move.l	6(a0),a0
	stringCopy	a0,#samplePath
	clr.b	(a1)
	move.w	#OPEN,d0

	graf_mkstate
	move.w	intout+8,d0
	andi.w	#8,d0	; alt held down?
	beq	.noAlt

	move.w	#OPEND2D,d0

.noAlt
	move.w	#1,vaStart
	bsr	openFile
	clr.w	vaStart
	rts
;----------------------------------------------------------
setMainInfoBar
	tst.w	noWindows	; is there a gui?
	beq	.gui
	rts	; no redraw
.gui
	lea	mainWindowInfo,a0
	lea	sampleInfoTable,a3

	clr.w	(a0)

	tst.w	sampleLoaded(a3)
	beq	.done
.done
	rts
;----------------------------------------------------------
	include	redraw.s
	include	editopts.s
	include	toolbar.s
	include	saminfo.s
	include	module.s
	include	block.s

	include	new.s
	include	open.s
	include	save.s
	include	clear.s

	include	d2d.s

	include	sign.s
	include	reverse.s
	include	amplify.s

	include	step1.s

	include	fade.s
	include	resample.s
	include	convert.s

	include	8to16.s
	include	16to8.s
	include	st2mo.s
	include	mo2st.s
	include	l2lr.s
	include	r2lr.s

	include	replay.s
	include	stop.s
	include	recmeth.s
	include	setfreq.s

	include	delblock.s
	include	cutblock.s
	include	trim.s
	include	pasteblk.s
	include	alter.s

	include	cli.s
	include	falcnrec.s