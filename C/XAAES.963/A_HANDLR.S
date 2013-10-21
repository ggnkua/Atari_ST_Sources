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
; - Made XBRA compliant [13/2/96] by Martin Koeling.
; - AES trap code streamlined [980629] by Johan Klockars.
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
	lea	8(a7),a7
	move.l	d0,_old_trap2_vector
	movem.l	(a7)+,d0-d2/a0-a1
	rts

; XBRA structure immediately before the new vector address:
	dc.b	'XBRA'
	dc.b	'XaAE'		; XBRA id (just a proposal)
_old_trap2_vector:
	dc.l	0
	
;Exception vector goes to here...
@handler:

	cmp.w	#$c9,d0		; Special case: implement the test for installed AES
	beq.s	_end_handler

	cmp.w	#$c8,d0		; Both $fffe (vq_gdos) and $73 (vdi calls) are less than $c8
	blt.s	_not_aes	
	
	move.l	a1,-(a7)	; Lattice C destroys d0-d1/a0-a1, but AES should keep a1

	move.l	d1,a0		; Place d1 arg in a0 as Lattice __regargs expects pointer to be
				; in a0 not d1

	jsr	@XA_handler	; Call the real handler written in C

	move.l	(a7)+,a1

	clr.w	d0		; Ordinary GEM does this - so we do it as well...

_end_handler:
	rte

; New version of the call to the original VDI/AES vector
; [13/2/96] - Martin Koehling
; This is a jump to the old VDI/AES vector. No self-modifieng code
; here - _old_trap_vector is data, not code... :-)
_not_aes:
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

; The stuff below is not in the oAESis assembly binding	

;	movem.l	d0-d3/a0-a3,-(a7)
;	move.l	$c(a0),d0
;	add.l	$14(a0),d0
;	add.l	$1c(a0),d0
;	add.l	#512,d0
;	move.l	d0,-(a7)
;	move.l	a0,-(a7)
;	clr.w	-(a7)
;	move.w	#$4a,-(a7)
;	trap	#1
;	lea	12(a7),a7
;	movem.l	(a7)+,d0-d3/a0-a3
	
	jmp (a1)

	
	end
