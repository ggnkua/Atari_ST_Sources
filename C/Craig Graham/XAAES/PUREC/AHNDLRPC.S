	super
	mc68000

	xdef	handler

;-------------------------------------------------------------------------------------
; AES/VDI (Trap 2)  Handler
; Version for Pure Assembler by Thomas Binder
; Better solution would of course be to use something like the .spp-
; files for the MiNT-kernel.
;-------------------------------------------------------------------------------------
; This mini handler just calls the main handler (written in C) or fields VDI
; commands out to the old vector (which was saved when we hooked trap 2 in the first
; place).
; Perhaps the whole trap handler should be in assembler, but really, it's fast enough
; for me just written in C with this small kludge routine to handle the actual
; exception itself. If anyone wants to recode it totally in assembler, the main Trap
; to pipe interface in in HANDLER.C - I'll happily put the mods into a new release.
; - Self modifying code removed [13/2/96] by Martin koeling.
; - Made XBRA compliant [13/2/96] by Martin koeling.
;-------------------------------------------------------------------------------------

	xref	XA_handler
	xdef	old_trap2_vector

; XBRA structure immediately before the new vector address:
	dc.b	'XBRA'
	dc.b	'XaAE'		; XBRA id (just a proposal)
old_trap2_vector:
	dc.l	0

	
;Exception vector goes to here....
handler:

	btst	#7,d0			; Is this a VDI call? AES calls all have bit 7 of d0 set.
	beq.s	_is_vdi_call	; - if so, we should call the old vector as we haven't replaced
							;   the VDI and have to rely on the existing one.

	cmp.w	#$fffe,d0		; Bloody inconvenient vq_gdos() call - what's wrong with the normal VDI magic?
	beq.s	_is_vdi_call
	
	cmp.w	#$c9,d0			; Special case : implement the test for installed AES
	beq.s	_end_handler
	
	movem.l	d0-d7/a0-a6,-(a7)

	move.l	d1,a0			; Place d1 arg in a0 as Lattice __regargs expects pointer to be
							; in a0 not d1 (same for Pure C)

	jsr		XA_handler		; Call the real handler written in C

	movem.l	(a7),d0-d7/a0-a6

	clr.w	d0				; Ordinary GEM does this - so we do it as well.....

_end_handler:
	rte


; New version of the call to the original VDI/AES vector
; [13/2/96] - Martin Koehling
; This is a jump to the old VDI/AES vector. No self-modifieng code
; here - _old_trap_vector is data, not code... :-)
_is_vdi_call:
	move.l	old_trap2_vector(pc),-(sp)
	rts
	
	END
