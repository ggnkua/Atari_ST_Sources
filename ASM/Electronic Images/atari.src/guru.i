Push	macro
	ifc	"\1","All"
	movem.l	d0-a6,-(sp)
	else	
	movem.l	\1,-(sp)
	endc
	endm

Pull	macro
	ifc	"\1","All"
	movem.l	(sp)+,d0-a6
	else	
	movem.l	(sp)+,\1
	endc
	endm

CALL	macro
	jsr	_LVO\1(a6)
	endm

CLIB	macro
	ifc	"\1","Exec"
	move.l	4.w,a6
	else
	move.l	_\1Base,a6
	endc
	jsr	_LVO\2(a6)
	endm

CPLIB	macro
	ifc	"\1","Exec"
	move.l	4.w,a6
	else
	move.l	_\1Base(pc),a6
	endc
	jsr	_LVO\2(a6)
	endm

C5LIB	macro
	ifc	"\1","Exec"
	move.l	4.w,a6
	else
	move.l	_\1Base(a5),a6
	endc
	jsr	_LVO\2(a6)
	endm

OLIB	macro	*LIB_ID,CLEANUP	openlib Dos, cleanup
D\1	set	1
	move.l	4.w,a6
	lea	_\1Lib(pc),a1
	moveq	#0,d0
	jsr	_LVOOpenLibrary(a6)
	ifd	RELATIVE
	move.l	d0,_\1Base(a5)
	endc
	ifnd	RELATIVE
	move.l	d0,_\1Base
	endc
	ifnc	'\2',''
	beq	\2
	endc
	endm

CLLIB	macro	*LIB_ID		closlib Dos
	ifd	RELATIVE
	move.l	_\1Base(a5),a1
	endc
	ifnd	RELATIVE
	move.l	_\1Base(pc),a1
	endc
	move.l	a1,d0
	beq	cLIB\@
	move.l	4,a6
	jsr	_LVOCloseLibrary(a6)
cLIB\@		
	ifd	RELATIVE
	clr.l	_\1Base(a5)
	endc
	ifnd	RELATIVE
	clr.l	_\1Base
	endc
	endm

libnames	macro
		ifd	DClist
_ClistLib	dc.b	'clist.library',0
		cnop	0,2
		ifnd	_ClistBase
_ClistBase	dc.l	0
		endc
		endc

		ifd	DGFX
_GFXLib		dc.b	'graphics.library',0
		cnop	0,2
		ifnd	_GFXBase
_GFXBase	dc.l	0
		endc
		endc

		ifd	DLayers
_LayersLib	dc.b	'layers.library',0
		cnop	0,2
		ifnd	_LayersBase
_LayersBase	dc.l	0
		endc
		endc

		ifd	DInt
_IntLib		dc.b	'intuition.library',0
		cnop	0,2
		ifnd	_IntBase
_IntBase	dc.l	0
		endc
		endc

		ifd	DMath
_MathLib	dc.b	'mathffp.library',0
		cnop	0,2
		ifnd	_MathBase
_MathBase	dc.l	0
		endc
		endc

		ifd	DMathTrans
_MathTransLib	dc.b	'mathtrans.library',0
		cnop	0,2
		ifnd	_MathTransBase
_MathTransBase	dc.l	0
		endc
		endc

		ifd	DMathIeeeDoubBas
_MathIeeeDoubBasLib	dc.b	'mathieeedoubbas.library',0
		cnop	0,2
		ifnd	_MathIeeeDoubBasBase
_MathIeeeDoubBasBase	dc.l	0
		endc
		endc

		ifd	DDos
_DosLib		dc.b	'dos.library',0
		cnop	0,2
		ifnd	_DosBase
_DosBase	dc.l	0
		endc
		endc

		ifd	DPP
_PPLib		dc.b	'powerpacker.library',0
		cnop	0,2
		ifnd	_PPBase
_PPBase		dc.l	0
		endc
		endc

		ifd	DRT
_RTLib		dc.b	'reqtools.library',0
		cnop	0,2
		ifnd	_RTBase
_RTBase		dc.l	0
		endc
		endc

		ifd	DTranslator
_TranslatorLib	dc.b	'translator.library',0
		cnop	0,2
		ifnd	_TranslatorBase
_TranslatorBase	ds.l	1
		endc
		endc

		ifd	DIcon
_IconLib	dc.b	'icon.library',0
		cnop	0,2
		ifnd	_IconBase
_IconBase	dc.l	0
		endc
		endc

		ifd	DDiskfont
_DiskfontLib	dc.b	'diskfont.library',0
		cnop	0,2
		ifnd		_DiskfontBase
_DiskfontBase	dc.l	0
		endc
		endc
		endm

