;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Copy raster transparent.
;* Copy raster opaque.
;*  These functions are pretty similar, so they're kludged together here.
;*------------------------------------------------------------------------

_vrt_cpyfm::
	.cargs	#8,.handle.w,.wrmode.w,.pxy.l,.psource.l,.pdest.l,.color.l
	link	a6,#0

	moveq.l	#121,d0		;* Function code = copy transparent
	moveq.l	#3,d1		;* Number of intin words = 3.
	move.l	.color(a6),a0	;* Get the pointer to the 2-word
	move.l	(a0),-(sp)	;* color array, copy values to the
	move.w	.wrmode(a6),-(sp)	;* stack, add the writing mode.
	move.l	sp,a0		;* Save a pointer to intin.
	bra.s	vr_cpyfm		;* Continue at common point below.

_vro_cpyfm::

	.cargs	#8,.handle.w,.wrmode.w,.pxy.l,.psource.l,.pdest.l
	link	a6,#0

	moveq.l	#109,d0		;* Function code = copy opaque.
	moveq.l	#1,d1		;* Number of intin words = 1.
	lea	.wrmode(a6),a0	;* Save a pointer to intin.
vr_cpyfm:
	.cargs	#8,.handle.w,.wrmode.w,.pxy.l,.psource.l,.pdest.l ;* This is dup'd here due to local symbol scope being trashed by the vr_cpyfm label.

	move.l	.pdest(a6),-(sp)	;* contrl[9-10] -> dest mfdb.
	move.l	.psource(a6),-(sp)	;* contrl[7-8]  -> source mfdb.

	VContrl	d0,,#4,d1 	;* Setup the rest of the contrl stuff.

	subq.l	#8,sp		;* -> ptsout, intout
	move.l	.pxy(a6),-(sp)	;* -> ptsin
	move.l	a0,-(sp)		;* -> intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
