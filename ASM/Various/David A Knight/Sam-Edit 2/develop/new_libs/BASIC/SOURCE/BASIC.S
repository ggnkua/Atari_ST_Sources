****************
*
* Basic program skeleton
*
*
	include	d:\develop\new_libs\basic\source\basic.h

	SECTION	text

	bra	initProgram

	include	d:\develop\new_libs\init.s
	include	d:\develop\new_libs\basic\basic.i

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

** Specific program initialisation **

	bsr	checkFalconSoundSystem
	bsr	falcSoundPatch
	bsr	showProgramInfo

	rsrc_gaddr	#0,#MENUBAR
	menu_bar	#1,addrout

mainLoop	; this is the loop of the program
	bsr	events
	bra	mainLoop
;----------------------------------------------------------
quitRoutine	; Always call to exit the program

	bsr	closeAllDialogs

	rsrc_free
	p_term	#0
;----------------------------------------------------------
programMoveWindow	; special cases for moving
		; non dialog windows
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
	rts
;----------------------------------------------------------
programRedraw

	rts
;----------------------------------------------------------
programClick

	rts
;----------------------------------------------------------
programBubbleGem

	rts
;----------------------------------------------------------
programKeys
	rts
;----------------------------------------------------------
programInput
	rts
;----------------------------------------------------------
programMenuHandler

	rts
;----------------------------------------------------------
programVaStart

	rts
;----------------------------------------------------------