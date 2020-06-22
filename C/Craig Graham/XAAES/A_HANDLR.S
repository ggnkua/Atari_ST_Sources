	xdef	@handler

;-------------------------------------------------------------------------------------
; AES/VDI (Trap 2)  Handler
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

	section trap_handler,CODE

	xref	@XA_handler
	xdef	_asm_hook_into_vector
	xdef	_accstart

; The hook is now done in assembler....
_asm_hook_into_vector:
	movem.l	d0-d2/a0-a1,-(a7)
	pea		@handler(pc)
	move.w	#$22,-(a7)
	move.w	#5,-(a7)
	trap	#13
	lea		8(a7),a7
	move.l	d0,_old_trap2_vector
	movem.l	(a7)+,d0-d2/a0-a1
	rts

; XBRA structure immediately before the new vector address:
	dc.b	'XBRA'
	dc.b	'XaAE'		; XBRA id (just a proposal)
_old_trap2_vector:
	dc.l	0
	
;Exception vector goes to here....
@handler:

	btst	#7,d0			; Is this a VDI call? AES calls all have bit 7 of d0 set.
	beq.s	_is_vdi_call	; - if so, we should call the old vector as we haven't replaced
							;   the VDI and have to rely on the existing one.

	cmp.w	#$fffe,d0		; Bloody inconvenient vq_gdos() call - what's wrong with the normal VDI magic?
	beq.s	_is_vdi_call
	
	cmp.w	#$c9,d0			; Special case : implement the test for installed AES
	beq.s	_end_handler
	
	movem.l	d0-d7/a0-a6,-(a7)

	move.l	d1,a0			; Place d1 arg in a0 as Lattice __regargs expects pointer to be
							; in a0 not d1

	jsr		@XA_handler		; Call the real handler written in C

	movem.l	(a7)+,d0-d7/a0-a6

	clr.w	d0				; Ordinary GEM does this - so we do it as well.....

_end_handler:
	rte

; New version of the call to the original VDI/AES vector
; [13/2/96] - Martin Koehling
; This is a jump to the old VDI/AES vector. No self-modifieng code
; here - _old_trap_vector is data, not code... :-)
_is_vdi_call:
	move.l	_old_trap2_vector(pc),-(sp)
	rts

; Accessory startup code poached from oAESis
_accstart:
	move.l 4(sp),a0
	move.l 16(a0),a1
	move.l a1,8(a0)
	add.l  12(a0),a1
	move.l a1,16(a0)
	move.l 8(a0),a1
	jmp (a1)

	
	END