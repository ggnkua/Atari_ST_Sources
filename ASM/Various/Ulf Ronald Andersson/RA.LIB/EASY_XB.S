;----------------------------------------------------------------------------
;File name:	EASY_XB.S			Revision date:	1998.08.11
;Creator:	Ulf Ronald Andersson		Creation date:	1996.01.26
;(c)1996 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE			(commercial sales forbidden!)
;----------------------------------------------------------------------------
;File purpose:	code library for three subroutines that ease XBRA usage
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	IFND	EASY_XB_defined
EASY_XB_defined	set	1
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
;seek_XB  a0->root  d0=id            =>  d0 = (link->code)\E_SEEK\E_CRC
;kill_XB  a0->root  d0=id            =>  d0 = E_OK\E_SEEK\E_CRC
;init_XB  a0->root  a1->XBRA_struct  =>  d0 = E_OK\E_ACCDN
;
;All above flag EQ and PL on success, but flag NE and MI on failure.
;They also preserve all entry register values except d0.
;Processor must be in supervisor state when calling these routines.
;
;E_CRC means that the XBRA chain was 'smashed'
;E_SEEK means that an XBRA 'next' link was less than or equal to zero
;E_ACCDN means that an XBRA identifier is refused if already in the chain
;Note that search for absent id should normally lead to 'smash' (E_CRC)
;----------------------------------------------------------------------------
;Start of:	Supexec subroutine	'seek_XB'
;----------------------------------------------------------------------------
;entry:	a0 -> XBRA chain root
;  "	d0 =  XBRA id
;exit:	d0 = (link->xb_code)/E_SEEK/E_CRC for success/unfound/smash
;
seek_XB:
	movem.l	a0/a1,-(sp)		;push entry registers
	tst.l	(a0)
	ble.s	.smashed		;branch if chain smashed at root
.loop:
	move.l	(a0),a1			;a1 -> xb_code of next vector
	lea	-xb_code(a1),a1		;a1 -> XBRA structure
	cmp.l	#'XBRA',xb_magic(a1)
	bne.s	.smashed		;branch on 'smash'
	cmp.l	xb_id(a1),d0
	beq.s	.found			;branch if same id found
	lea	xb_next(a1),a0		;a0 -> xb_next -> next xb_code
	tst.l	(a0)			;test if chain exhausted yet
	bgt.s	.loop			;loop back to try next in chain
.unused:
	moveq	#E_SEEK,d0		;d0 = error code flagging NE,MI
	bra.s	.exit
;
.smashed:
	moveq	#E_CRC,d0		;d0 = error code flagging NE,MI
	bra.s	.exit
;
.found:
	move.l	a0,d0		;d0 = address of link ptr to found struct
	cmp.l	a0,d0		;ensure flagging EQ,PL
.exit:
	movem.l	(sp)+,a0/a1		;pull entry registers
	rts
;----------------------------------------------------------------------------
;End of:	Supexec subroutine	'seek_XB'
;----------------------------------------------------------------------------
;Start of:	Supexec subroutine	'kill_XB'
;----------------------------------------------------------------------------
;entry:	a0 -> XBRA chain root
;  "	d0 =  XBRA id  to remove
;exit:	d0 = E_OK/E_SEEK/E_CRC (flagged) for success/unfound/smash
;
kill_XB:
	movem.l	a0/a1,-(sp)		;push entry registers
	tst.l	(a0)
	ble.s	.smashed		;branch if chain smashed at root
.loop:
	move.l	(a0),a1			;a1 -> xb_code of next vector
	lea	-xb_code(a1),a1		;a1 -> XBRA structure
	cmp.l	#'XBRA',xb_magic(a1)
	bne.s	.smashed		;branch on 'smash'
	cmp.l	xb_id(a1),d0
	beq.s	.found			;branch if same id found
	lea	xb_next(a1),a0		;a0 -> xb_next -> next xb_code
	tst.l	(a0)			;test if chain exhausted yet
	bgt.s	.loop			;loop back to try next in chain
.unused:
	moveq	#E_SEEK,d0		;d0 = error code flagging NE,MI
	bra.s	.exit
;
.smashed:
	moveq	#E_CRC,d0		;d0 = error code flagging NE,MI
	bra.s	.exit
;
.found:
	move.l	xb_next(a1),(a0)	;remove found entry from chain
	moveq	#E_OK,d0		;d0 = E_OK flagging EQ,PL
.exit:
	movem.l	(sp)+,a0/a1		;pull entry registers
	rts
;----------------------------------------------------------------------------
;End of:	Supexec subroutine	'kill_XB'
;----------------------------------------------------------------------------
;Start of:	Supexec subroutine	'init_XB'
;----------------------------------------------------------------------------
;entry:	a0 -> XBRA chain root
;  "	a1 -> XBRA structure to install
;exit:	d0 = E_OK/E_ACCDN (flagged) for success/conflict
;
init_XB:
	movem.l	a0-a3,-(sp)		;push entry registers
	move	sr,-(sp)		;push entry interrupt mask
	ori	#$0700,sr		;disable all interrupts
;
;NB: disabled interrupts prevent multiple simultaneous tampering in a chain
;
	move.l	a0,a3			;a3 = chain root ptr
	tst.l	(a0)
	ble.s	.smashed		;branch if chain smashed at root
	move.l	xb_id(a1),d0		;d0 = XBRA id of new entry
.loop:
	move.l	(a0),a2			;a2 -> xb_code of next vector
	lea	-xb_code(a2),a2		;a2 -> XBRA structure of old entry
	cmp.l	#'XBRA',xb_magic(a2)
	bne.s	.smashed		;branch on 'smash'
	cmp.l	xb_id(a2),d0
	beq.s	.found			;branch if same id found
	lea	xb_next(a2),a0		;a0 -> xb_next -> next xb_code
	tst.l	(a0)			;test if chain exhausted yet
	bgt.s	.loop			;loop back to try next in chain
.unused:
.smashed:
	move.l	a3,a0			;a0 = chain root ptr
	move.l	(a0),xb_next(a1)	;link new entry to old chain
	lea	xb_code(a1),a1		;a1 -> code of new entry
	move.l	a1,(a0)			;install new entry in chain root
	moveq	#E_OK,d0		;d0 = E_OK flagging EQ,PL
	bra.s	.exit
;
.found:
	moveq	#E_ACCDN,d0		;d0 = error code flagging NE,MI
.exit:
	move	(sp)+,sr		;pull entry interrupt mask
	tst.l	d0			;ensure correct result flagging
	movem.l	(sp)+,a0-a3		;pull entry registers
	rts
;
;----------------------------------------------------------------------------
;End of:	Supexec subroutine	'init_XB'
;----------------------------------------------------------------------------
	ENDC	;EASY_XB_defined
;----------------------------------------------------------------------------
; End of file:	EASY_XB.S
;----------------------------------------------------------------------------
