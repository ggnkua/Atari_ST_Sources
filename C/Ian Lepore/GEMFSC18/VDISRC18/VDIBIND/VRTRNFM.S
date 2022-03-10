;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Transform form.
;*------------------------------------------------------------------------

_vr_trnfm::
	.cargs	#8,.handle.w,.psource.l,.pdest.l
	link	a6,#0

	move.l	.pdest(a6),-(sp)	;* contrl[9-10] -> dest mfdb.
	move.l	.psource(a6),-(sp)	;* contrl[7-8]  -> source mfdb.
	VContrl	#110		;* function code, no intin/ptsin

	pea	(sp)		;* -> contrl

	jmp	vdicall

	end
