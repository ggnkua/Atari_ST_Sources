;----------------------------------------------------------------------------
;File name:	XB_SUBS.S			Revision date:	1998.10.11
;Creator:	Ulf Ronald Andersson		Creation date:	1996.01.26
;(c)1996 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE		(NB: commercial sales forbidden!)
;----------------------------------------------------------------------------
;File purpose:	code library for XBRA operations
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	IFND	XB_SUBS_defined
XB_SUBS_defined	set	1
;----------------------------------------------------------------------------
	include	RA_ERR.I	;this defines standard error codes
;----------------------------------------------------------------------------
	IFND	xb_magic
xb_magic	=	0
xb_id		=	4
xb_next		=	8
xb_code		=	12
	ENDC
;----------------------------------------------------------------------------
;seek_XB_name		a0->root d0=id		=> d0 = (link->xb_code)\E_SEEK\E_CRC
;seek_XB_code		a0->root a1->xb_magic	=> d0 = (link->xb_code)\E_SEEK\E_CRC
;remove_XB_name		a0->root d0=id		=> d0 = (link->xb_code)\E_SEEK\E_CRC
;remove_XB_code		a0->root a1->xb_magic	=> d0 = (link->xb_code)\E_SEEK\E_CRC
;retop_XB_name		a0->root a1->xb_magic	=> d0 = preserved
;retop_XB_code		a0->root a1->xb_magic	=> d0 = E_OK\E_ACCDN
;install_XB		a0->root a1->xb_magic	=> d0 = E_OK\E_ACCDN
;----------------------------------------------------------------------------
;Start of:	Supexec subroutine	'seek_XB_name'
;----------------------------------------------------------------------------
;entry:	a0 -> XBRA chain root
;  "	d0 =  XBRA id
;exit:	a0 = preserved
;  "	d0 = (link->xb_code)/E_SEEK/E_CRC (flagged) for: success/unfound/vector_smash
;----------------------------------------------------------------------------
seek_XB_name:
	movem.l	a0/a1,-(sp)
	tst.l	(a0)
	ble.s	.smashed
.loop:
	move.l	(a0),a1			;a1 -> xb_code of next vector
	lea	-xb_code(a1),a1		;a1 -> XBRA structure
	cmp.l	#'XBRA',xb_magic(a1)
	bne.s	.smashed
	cmp.l	xb_id(a1),d0
	beq.s	.found
	lea	xb_next(a1),a0		;a0 -> xb_next -> next xb_code
	tst.l	(a0)
	bgt.s	.loop
.unused:
	moveq	#E_SEEK,d0
	bra.s	.exit
;
.smashed:
	moveq	#E_CRC,d0
	bra.s	.exit
;
.found:
	move.l	a0,d0
	bclr	#31,d0
	tst.l	d0
.exit:
	movem.l	(sp)+,a0/a1
	rts
;----------------------------------------------------------------------------
;End of:	Supexec subroutine	'seek_XB_name'
;----------------------------------------------------------------------------
;Start of:	Supexec subroutine	'seek_XB_code'
;----------------------------------------------------------------------------
;entry:	a0 -> XBRA chain root
;  "	a1 -> XBRA structure to seek
;exit:	a0 = preserved
;  "	d0 = (link->xb_code)/E_SEEK/E_CRC (flagged) for: success/unfound/vector_smash
;----------------------------------------------------------------------------
seek_XB_code:
	movem.l	a1-a2,-(sp)
	tst.l	(a0)
	ble.s	.smashed
	lea	xb_code(a1),a2
.loop:
	move.l	(a0),a1			;a1 -> xb_code of next vector
	cmp.l	a1,a2
	beq.s	.found
	cmp.l	#'XBRA',xb_magic-xb_code(a1)
	bne.s	.smashed
	lea	xb_next-xb_code(a1),a0		;a0 -> xb_next -> next xb_code
	tst.l	(a0)
	bgt.s	.loop
.unused:
	moveq	#E_SEEK,d0
	bra.s	.exit
;
.smashed:
	moveq	#E_CRC,d0
	bra.s	.exit
;
.found:
	move.l	a0,d0
	bclr	#31,d0
	tst.l	d0
.exit:
	movem.l	(sp)+,a1-a2
	rts
;----------------------------------------------------------------------------
;End of:	Supexec subroutine	'seek_XB_code'
;----------------------------------------------------------------------------
;Start of:	Supexec subroutine	'remove_XB_name'
;----------------------------------------------------------------------------
;entry:	a0 -> XBRA chain root
;  "	d0 =  XBRA id  to remove
;exit:	a0 = used link/garbage/garbage  \/ depending on
;  "	d0 = 0/E_SEEK/E_CRC (flagged)   /\ success/unfound/vector_smash
;----------------------------------------------------------------------------
remove_XB_name:
	movem.l	a1,-(sp)
	tst.l	(a0)
	ble.s	.smashed
.loop:
	move.l	(a0),a1			;a1 -> xb_code of next vector
	lea	-xb_code(a1),a1		;a1 -> XBRA structure
	cmp.l	#'XBRA',xb_magic(a1)
	bne.s	.smashed
	cmp.l	xb_id(a1),d0
	beq.s	.found
	lea	xb_next(a1),a0		;a0 -> xb_next -> next xb_code
	tst.l	(a0)
	bgt.s	.loop
.unused:
	moveq	#E_SEEK,d0
	bra.s	.exit
;
.smashed:
	moveq	#E_CRC,d0
	bra.s	.exit
;
.found:
	move.l	xb_next(a1),(a0)
	moveq	#E_OK,d0
.exit:
	movem.l	(sp)+,a1
	rts
;----------------------------------------------------------------------------
;End of:	Supexec subroutine	'remove_XB_name'
;----------------------------------------------------------------------------
;Start of:	Supexec subroutine	'remove_XB_code'
;----------------------------------------------------------------------------
;entry:	a0 -> XBRA chain root
;  "	a1 -> XBRA structure to remove
;exit:	a0 = used link/garbage/garbage  \/ depending on
;  "	d0 = 0/E_SEEK/E_CRC (flagged)   /\ success/unfound/vector_smash
;----------------------------------------------------------------------------
remove_XB_code:
	movem.l	a1-a2,-(sp)
	move	sr,-(sp)
	ori	#$0700,sr
	tst.l	(a0)
	ble.s	.smashed
	move.l	xb_id(a1),d0
.loop:
	move.l	(a0),a2			;a2 -> xb_code of next vector
	lea	-xb_code(a2),a2		;a2 -> XBRA structure
	cmp.l	a1,a2			;is this the one ?
	beq.s	.found
	cmp.l	#'XBRA',xb_magic(a2)
	bne.s	.smashed
	lea	xb_next(a2),a0		;a0 -> xb_next -> next xb_code
	tst.l	(a0)
	bgt.s	.loop
.unused:
	moveq	#E_SEEK,d0
	bra.s	.exit
;
.smashed:
	moveq	#E_CRC,d0
	bra.s	.exit
;
.found:
	move.l	xb_next(a2),(a0)
	moveq	#E_OK,d0
.exit:
	move	(sp)+,sr
	tst.l	d0
	movem.l	(sp)+,a1-a2
	rts
;----------------------------------------------------------------------------
;End of:	Supexec subroutine	'remove_XB_code'
;----------------------------------------------------------------------------
;Start of:	Supexec subroutine	'retop_XB_code'
;----------------------------------------------------------------------------
;entry:	a0 -> XBRA chain root
;  "	a1 -> XBRA structure to retop
;exit:	d0 = E_OK/E_ACCDN  depending on  Success/Conflict
;----------------------------------------------------------------------------
retop_XB_code:
	movem.l	a2-a3,-(sp)
	move	sr,-(sp)
	ori	#$0700,sr
	move.l	a0,a3
	move.l	xb_id(a1),d0
.loop:
	tst.l	(a3)
	ble.s	.install		;end of chain, none found, so install
	move.l	(a3),a2			;a2 -> xb_code of next vector
	lea	-xb_code(a2),a2		;a2 -> XBRA structure
	cmp.l	a1,a2			;is this the one ?
	beq.s	.found
	cmp.l	#'XBRA',xb_magic(a2)
	bne.s	.install		;smashed chain, none found, so install
	cmp.l	xb_id(a2),d0
	beq.s	.conflict
	lea	xb_next(a2),a3		;a3 -> xb_next -> next xb_code
	bra.s	.loop
;
.conflict:
	moveq	#E_ACCDN,d0		;deny access in case of conflict
	bra.s	.exit
;
.found:
	move.l	xb_next(a1),(a3)	;remove found link from chain
.install:
	move.l	(a0),xb_next(a1)	;hook chain to this link
	lea	xb_code(a1),a2		;a2 -> code of new root link
	move.l	a2,(a0)			;store it in chain root
	moveq	#E_OK,d0
.exit:
	move	(sp)+,sr
	movem.l	(sp)+,a2-a3
	rts
;----------------------------------------------------------------------------
;End of:	Supexec subroutine	'retop_XB_code'
;----------------------------------------------------------------------------
;Start of:	Supexec subroutine	'retop_XB_name'	(used to be 'force_XB')
;----------------------------------------------------------------------------
;size:	50 bytes
;entry:	a0 -> XBRA chain root
;  "	a1 -> XBRA structure to retop
;exit:	all regs preserved
;----------------------------------------------------------------------------
retop_XB_name:
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
;----------------------------------------------------------------------------
;End of:	Supexec subroutine	'retop_XB_name'
;----------------------------------------------------------------------------
;Start of:	Supexec subroutine	'install_XB'
;----------------------------------------------------------------------------
;entry:	a0 -> XBRA chain root
;  "	a1 -> XBRA structure to install
;exit:	a0 = used link/garbage/garbage  \/ depending on
;  "	d0 = E_OK/E_ACCDN (flagged)     /\ success/conflict
;----------------------------------------------------------------------------
install_XB:
	movem.l	a1-a3,-(sp)
	move	sr,-(sp)
	ori	#$0700,sr
	move.l	a0,a3
	tst.l	(a0)
	ble.s	.smashed
	move.l	xb_id(a1),d0
.loop:
	move.l	(a0),a2			;a2 -> xb_code of next vector
	lea	-xb_code(a2),a2		;a2 -> XBRA structure
	cmp.l	#'XBRA',xb_magic(a2)
	bne.s	.smashed
	cmp.l	xb_id(a2),d0
	beq.s	.found
	lea	xb_next(a2),a0		;a0 -> xb_next -> next xb_code
	tst.l	(a0)
	bgt.s	.loop
.unused:
.smashed:
	move.l	a3,a0
	move.l	(a0),xb_next(a1)
	lea	xb_code(a1),a1
	move.l	a1,(a0)
	moveq	#E_OK,d0
	bra.s	.exit
;
.found:
	moveq	#E_ACCDN,d0
.exit:
	move	(sp)+,sr
	tst.l	d0
	movem.l	(sp)+,a1-a3
	rts
;----------------------------------------------------------------------------
;End of:	Supexec subroutine	'install_XB'
;----------------------------------------------------------------------------
	ENDC	;XB_SUBS_defined
;----------------------------------------------------------------------------
; End of file:	XB_SUBS.S
;----------------------------------------------------------------------------
