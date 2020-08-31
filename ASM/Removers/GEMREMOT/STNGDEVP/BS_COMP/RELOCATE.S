;----------------------------------------------------------------------------
;File name:	RELOCATE.S			Revision date:	1999.01.22
;Created by:	Ulf Ronald Andersson		Creation date:	1998.06.25
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
relocate:				;a0 -> textbeg  a1 -> program header
	lea	(a1),a3			;a3 -> program header
	lea	(a0),a2			;a2 -> textbeg
	add.l	ph_textlen(a3),a2	;a2 -> databeg
	add.l	ph_datalen(a3),a2	;a2 -> symbbeg (== bss_beg)
	lea	(a2),a1			;a1 -> symbbeg (== bss_beg)
	add.l	ph_symblen(a3),a1	;a1 -> relocation data
	move.l	(a1)+,d1		;d1 = start offset for relocation
	beq.s	done_reloc		;if none, relocation done
	move.l	a0,d2			;d2 -> textbeg, as relocation increment
	add.l	d1,a0			;a0 -> start position for relocation
	clr.l	d1			;d1 = 0  (to clear high bits
patch_loop:			;loop start to patch positions
	add.l	d2,(a0)		    ;patch relocation at current position
offset_loop:			    ;loop start to calculate offsets
	move.b	(a1)+,d1		;d1 = next offset byte
	beq.s	done_reloc		;if none, relocation done
	cmpi.b	#1,d1			;is it 1 ?  (impossible real offset)
	bne.s	next_offset		;if not, go use it
	lea	254(a0),a0		;else step ahead 254 bytes
	bra.s	offset_loop	    ;loop back for another offset
;
next_offset:
	adda.w	d1,a0		    ;step ahead by d1 bytes
	bra.s	patch_loop	;loop back to patch at position
;
done_reloc:
	lea	(a2),a1			;a1 -> bss_beg
	move.l	ph_bss_len(a3),d0	;d0 =  bss_len
	tst.l	d0			;BSS empty ?
	ble.s	done_BSS		;then goto done_BSS
	lea	(a1,d0.l),a0		;a0 -> bss_end
clear_BSS_lp:				;loop start to clear BSS
	clr.l	(a1)+				;clear a long
	cmpa.l	a0,a1				;a1 past or at end ?
	blt.s	clear_BSS_lp		;loop back to clear all of BSS
done_BSS:
	rts
;----------------------------------------------------------------------------
;End of file:	RELOCATE.S
;----------------------------------------------------------------------------
