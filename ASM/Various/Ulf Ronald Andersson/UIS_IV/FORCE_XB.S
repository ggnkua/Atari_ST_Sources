;----------------------------------------------------------------------------
;Start of:	Supexec subroutine	'force_XB'
;----------------------------------------------------------------------------
;size:	50 bytes
;entry:	a0 -> XBRA chain root
;  "	a1 -> XBRA structure to retop
;exit:	all regs preserved
;
force_XB:
	movem.l	d0-d1/a1-a3,-(sp)
	move	sr,-(sp)
	ori	#$0700,sr
	move.l	a0,a2
	move.l	(a1)+,d0		;d0 = xb_magic of new structure
	move.l	(a1)+,d1		;d1 = xb_id  :  a1 -> xb_next
.loop:
	tst.l	(a2)			;does a2 -> a valid vector
	ble.s	.install		;end of chain, none found, so install
	move.l	a2,a3			;a3 -> vector -> next possible xb_code
	move.l	(a2),a2			;a2 -> xb_code of possible XBRA
	lea	xb_magic-xb_code(a2),a2	;a2 -> possible XBRA structure
	cmp.l	(a2)+,d0		;is xb_magic correct ?  (also a2 -> xb_id)
	bne.s	.install
	cmp.l	(a2)+,d1		;is xb_id correct ?  (also a2 -> xb_next)
	bne.s	.loop
	move.l	(a2),(a3)		;remove found code from chain by replacing with xb_next
.install:
	move.l	(a0),(a1)+		;hook old chain into new xb_next  (also a1 -> xb_code)
	move.l	a1,(a0)			;store it in chain root
.exit:
	move	(sp)+,sr
	movem.l	(sp)+,d0-d1/a1-a3
	rts
;
;----------------------------------------------------------------------------
;End of:	Supexec subroutine	'force_XB'
;----------------------------------------------------------------------------
