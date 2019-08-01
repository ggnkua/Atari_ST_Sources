;----------------------------------------------------------------------------
;File name:	RA_XB.I				Revision date:	2000.07.02
;Creator:	Ulf Ronald Andersson		Creation date:	1991.05.07
;(c)1991 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE			(commercial sales forbidden!)
;----------------------------------------------------------------------------
;Purpose:	Macro library for XBRA operations
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	IFND	RA_XB_defined
RA_XB_defined	set	1
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
;	Library macros
;
;   The first 4 alter no registers
;XB_define	xbname,xbra_id	Defines header for routine code
;XB_gonext	xbname		Smart Link to next routine in chain
;XB_gonext_d	xbname		FAST Link to next routine in chain
;XB_donext_d	xbname		FAST Call to next routine in chain
;
;   The next 2 alter only register a0
;XB_gonext_a0	xbname		BEST Link to next routine in chain
;XB_donext_a0	xbname		BEST Call to next routine in chain
;
;   The next 2 alter only the choosen "areg"
;Pass_Frame	areg		areg->exception argument
;XB_donext	xbname,areg	Smart Call to next routine in chain
;
;   The next 7 are for XBRA manipulation in Super mode only
;
;XB_seek_name		a0->root d0=id		=> d0 = (link->xb_code)\E_SEEK\E_CRC
;XB_seek_code		a0->root a1->xb_magic	=> d0 = (link->xb_code)\E_SEEK\E_CRC
;XB_kill_name		a0->root d0=id		=> d0 = E_OK\E_SEEK\E_CRC
;XB_kill_code		a0->root a1->xb_magic	=> d0 = E_OK\E_SEEK\E_CRC
;XB_lift_name		a0->root a1->xb_magic	=> d0 = preserved
;XB_lift_code		a0->root a1->xb_magic	=> d0 = E_OK\E_ACCDN
;XB_init		a0->root a1->xb_magic	=> d0 = E_OK\E_ACCDN (fails if id in chain)
;
;   The next 3 affect d0-d2/a0-a2, since they may use GEMDOS Super
;XB_check	xbname,root	d0= found/last vector  flagged PL/MI
;XB_install	xbname,root	as XB_check + Installs xbname in chain(root)
;XB_remove	xbname,root	as XB_check + Removes xbname from chain(root)
;
;Legal forms for xbname & root here are mostly the same as for LEA & PEA,
;except that for XB_define "xbname" is a free name for the new structure.
;In all other cases it must be the name of an existing such structure.
;"xbname" always refers to the first byte of the entire structure, so it
;does not point to the code or data itself, but 12 bytes before that.
;"xbra_id" is a 4-character (longword) string
;"areg" is a free address register of your choice (of a0-a6).
;XB_gonext_d & XB_donext_d are faster versions of XB_gonext & XB_donext,
;but can only handle address modes where "xbname" begins with identifier.
;eg: "XB_donext_d  my_ikbd_sub(pc)"  but  "XB_donext  (a5)+")
;XB_gonext_a0 & XB_donext_a0 are even faster, but destroy value in a0.
;
;Pass_Frame makes exception routines (eg: gemdos etc.) 68030-compatible,
;by setting "areg" = stack pointer before exception (SSP or USP).
;This allows 'vector benders' to access function arguments easily.
;
;XB_define may (optionally) have a third argument which, if present, will be
;placed in the link pointer as its initial value.
;
;XB_cpu_mode is used to control Supervisor mode testing/setting of the three
;macros  XB_check,  XB_install,  XB_remove,  and is normally 2.  This can be
;changed _before_ any of those macros is invoked as follows:
;
;XB_cpu_mode	set	0	=> never test, always call Super(0)
;XB_cpu_mode	set	1	=> never test, never call Super
;XB_cpu_mode	set	2	=> test with Super(1), maybe use Super(0)
;
;In all these cases the routines exit in same mode as entered provided that
;mode 1 is only used with cpu in Super mode, and mode 0 is only used with
;cpu in User mode.  Mode 2 is for code needing both capabilities, but this
;mode (2) can not be used in interrupt routines, or inside TOS trap code.
;
;Note that many of these macros generate subroutines with global labels
;when called for the first time, so those calls must be in code which
;does not use local labels in references passing that point in code.
;----------------------------------------------------------------------------
	IFND	XB_cpu_mode
XB_cpu_mode	set	2
	ENDC
;----------------------------------------------------------------------------
	IFND	xb_magic
	RSRESET
xb_magic:	rs.l	1
xb_id:		rs.l	1
xb_next:	rs.l	1
xb_code:	rs.w	0
xb_size:	rs.w	0
	ENDC
;----------------------------------------------------------------------------
;	Macro definitions (with support variables)
;----------------------------------------------------------------------------
Pass_Frame	MACRO	areg
	btst	#5,(sp)
	beq.s	.user\@
.super\@:
	tst	(_longframe).w
	bne.s	.new_cpu\@
.old_cpu\@:
	lea	6(sp),\1
	bra.s	.have_arg\@
.new_cpu\@:
	lea	8(sp),\1
	bra.s	.have_arg\@
.user\@:
	move.l	USP,\1
.have_arg\@:
	ENDM
;----------------------------------------------------------------------------
XB_define	MACRO	xbname,xbra_id,init_link
\1:	dc.l	'XBRA',\2
	ifc	'','\3'
	dc.l	0
	elseif
	dc.l	\3
	ENDC
	ENDM
;----------------------------------------------------------------------------
XB_donext_a0	MACRO	xbname
	move.l	8+\1,a0
	jsr	(a0)
	ENDM
;----------------------------------------------------------------------------
XB_donext_d	MACRO	xbname
	pea	.l\@(pc)
	move.l	8+\1,-(sp)
	rts
.l\@:
	ENDM
;----------------------------------------------------------------------------
XB_donext	MACRO	xbname,areg
	lea	\1,\2
	move.l	8(\2),\2
	jsr	(\2)
	ENDM
;----------------------------------------------------------------------------
XB_gonext_a0	MACRO	xbname
	move.l	8+\1,a0
	jmp	(a0)
	ENDM
;----------------------------------------------------------------------------
XB_gonext_d	MACRO	xbname
	move.l	8+\1,-(sp)
	rts
	ENDM
;----------------------------------------------------------------------------
XB_gonext	MACRO	xbname
	movem.l	a0-a1,-(sp)
	lea	\1,a0
	move.l	8(a0),4(sp)
	move.l	(sp)+,a0
	rts
	ENDM
;----------------------------------------------------------------------------
;Macro function:	XB_seek_name	;seek for XBRA by xb_id name
;------------------------------------
;entry:	a0 -> XBRA chain root
;  "	d0 =  XBRA id
;exit:	a0 = preserved
;  "	d0 = (link->xb_code)/E_SEEK/E_CRC (flagged) for: success/unfound/vector_smash
;------------------------------------
XB_seek_name_defined	set	0
;------------------------------------
XB_seek_name	MACRO
	IFNE	XB_seek_name_defined
	bsr	XB_seek_name_code
	ELSE
	bsr.s	XB_seek_name_code
	bra.s	XB_seek_name_code_end
;
XB_seek_name_code:
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
XB_seek_name_code_end:
	ENDC
XB_seek_name_defined	set	XB_seek_name_defined+1
	ENDM
;----------------------------------------------------------------------------
;Macro function:	XB_seek_code	;seek for XBRA by xb_code code address
;------------------------------------
;entry:	a0 -> XBRA chain root
;  "	a1 -> XBRA structure to seek	;may be simulated by code_adr-xb_code or similar
;exit:	a0 = preserved
;  "	d0 = (link->xb_code)/E_SEEK/E_CRC (flagged) for: success/unfound/vector_smash
;------------------------------------
XB_seek_code_defined	set	0
;------------------------------------
XB_seek_code	MACRO
	IFNE	XB_seek_code_defined
	bsr	XB_seek_code_code
	ELSE
	bsr.s	XB_seek_code_code
	bra.s	XB_seek_code_code_end
;
XB_seek_code_code:
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
XB_seek_code_code_end:
	ENDC
XB_seek_code_defined	set	XB_seek_code_defined+1
	ENDM
;----------------------------------------------------------------------------
;Macro function:	XB_kill_name	;kill XBRA found by xb_id name
;------------------------------------
;entry:	a0 -> XBRA chain root
;  "	d0 =  XBRA id  to remove
;exit:	a0 = used link/garbage/garbage  \/ depending on
;  "	d0 = 0/E_SEEK/E_CRC (flagged)   /\ success/unfound/vector_smash
;------------------------------------
XB_kill_name_defined	set	0
;----------------------------------------------------------------------------
XB_kill_name	MACRO
	IFNE	XB_kill_name_defined
	bsr	XB_kill_name_code
	ELSE
	bsr.s	XB_kill_name_code
	bra.s	XB_kill_name_code_end
;
XB_kill_name_code:
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
XB_kill_name_code_end:
	ENDC
XB_kill_name_defined	set	XB_kill_name_defined+1
	ENDM
;----------------------------------------------------------------------------
;Macro function:	XB_kill_code	;kill XBRA found by xb_code code address
;------------------------------------
;entry:	a0 -> XBRA chain root
;  "	a1 -> XBRA structure to remove
;exit:	a0 = used link/garbage/garbage  \/ depending on
;  "	d0 = 0/E_SEEK/E_CRC (flagged)   /\ success/unfound/vector_smash
;------------------------------------
XB_kill_code_defined	set	0
;----------------------------------------------------------------------------
XB_kill_code	MACRO
	IFNE	XB_kill_code_defined
	bsr	XB_kill_code_code
	ELSE
	bsr.s	XB_kill_code_code
	bra.s	XB_kill_code_code_end
;
XB_kill_code_code:
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
XB_kill_code_code_end:
	ENDC
XB_kill_code_defined	set	XB_kill_code_defined+1
	ENDM
;----------------------------------------------------------------------------
;Macro function:	XB_init		;init XBRA with unique name in chain
;------------------------------------
;entry:	a0 -> XBRA chain root
;  "	a1 -> XBRA structure to install
;exit:	a0 = used link/garbage/garbage  \/ depending on
;  "	d0 = E_OK/E_ACCDN (flagged)     /\ success/conflict
;------------------------------------
XB_init_defined	set	0
;----------------------------------------------------------------------------
XB_init	MACRO
	IFNE	XB_init_defined
	bsr	XB_init_code
	ELSE
	bsr.s	XB_init_code
	bra.s	XB_init_code_end
;
XB_init_code:
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
XB_init_code_end:
	ENDC
XB_init_defined	set	XB_init_defined+1
	ENDM
;----------------------------------------------------------------------------
;Macro function:	XB_lift_name	;Lift XBRA found by name to chain root
;------------------------------------
;entry:	a0 -> XBRA chain root
;  "	a1 -> XBRA structure to retop
;exit:	all regs preserved
;------------------------------------
XB_lift_name_defined	set	0
;----------------------------------------------------------------------------
XB_lift_name	MACRO
	IFNE	XB_lift_name_defined
	bsr	XB_lift_name_code
	ELSE
	bsr.s	XB_lift_name_code
	bra.s	XB_lift_name_code_end
;
XB_lift_name_code:
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
XB_lift_name_code_end:
	ENDC
XB_lift_name_defined	set	XB_lift_name_defined+1
	ENDM
;----------------------------------------------------------------------------
;Macro function:	XB_lift_code	;Lift XBRA found by name to chain root
;------------------------------------
;entry:	a0 -> XBRA chain root
;  "	a1 -> XBRA structure to retop
;exit:	d0 = E_OK/E_ACCDN  depending on  Success/Conflict
;------------------------------------
XB_lift_code_defined	set	0
;----------------------------------------------------------------------------
XB_lift_code	MACRO
	IFNE	XB_lift_code_defined
	bsr	XB_lift_code_code
	ELSE
	bsr.s	XB_lift_code_code
	bra.s	XB_lift_code_code_end
;
XB_lift_code_code:
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
XB_lift_code_code_end:
	ENDC
XB_lift_code_defined	set	XB_lift_code_defined+1
	ENDM
;----------------------------------------------------------------------------
XB_check_defined	set	0
;----------------------------------------------------------------------------
XB_check	MACRO	xbname,root
	pea	\2
	pea	\1
	IFNE	XB_check_defined
	bsr	XB_check_code
	addq	#8,sp
	ELSE
	bsr.s	XB_check_code
	addq	#8,sp
	bra.s	XB_check_code_end
;
XB_check_code:
	movem.l	a3/a4,-(sp)
	movem.l	12(sp),a3/a4	;a3 -> struct  a4 -> chain root
;
	ifne	XB_cpu_mode=2
	subq	#4,sp		;reserve result storage on stack
	gemdos	Super,1.w	;User or Super mode call ?
	tst.l	d0
	bmi.s	.done_super_1
	gemdos	Super,!
.done_super_1:			;here CPU is in supervisor state
	move.l	d0,-(sp)	;push -1 or previous SSP
	endc
;
	ifne	XB_cpu_mode=0
	subq	#4,sp		;reserve result storage on stack
	gemdos	Super,!
	move.l	d0,-(sp)	;push previous SSP
	endc
;
	move	SR,d2		;d2 = entry interrupt mask
	or	#$0700,SR	;disable interrupts
.search_lp:
	move.l	a4,d0
	bset	#31,d0			;flag vector missing as MI
	move.l	(a4),d1
	beq.s	.done_search		;exit if vector missing
	move.l	d1,a4
	subq	#xb_code-xb_next,a4
	cmpi.l	#'XBRA',xb_magic-xb_next(a4)
	bne.s	.done_search		;exit if chain broken
	move.l	xb_id-xb_next(a4),d1	;d1 = current id
	cmp.l	xb_id(a3),d1		;d1 == sought id ?
	bne.s	.search_lp		;loop back to check remaining chain
	bclr	#31,d0		;flag vector found as PL
.done_search:
	move	d2,SR		;restore entry interrupt mask
;
	ifne	XB_cpu_mode=2
	move.l	d0,4(sp)	;store search result in stack
	move.l	(sp)+,d0
	bmi.s	.done_super_2
	gemdos	Super|_ind,d0
.done_super_2:			;here CPU is back in entry state
	move.l		(sp)+,d0	;d0 = search result from stack
	endc
;
	ifne	XB_cpu_mode=1
	tst.l	d0
	endc
;
	ifne	XB_cpu_mode=0
	move.l		d0,4(sp)	;store search result in stack
	gemdos.1	Super,__ARG__on_stack
	move.l		(sp)+,d0	;d0 = search result from stack
	endc
;
	movem.l	(sp)+,a3/a4
	rts	;d0=found_vector  or  (last_chain_vector+1<<31)
XB_check_code_end:
	ENDC
XB_check_defined	set	XB_check_defined+1
	ENDM	;d0=found_vector/(last_chain_vector+1<<31) flagged PL/MI
;----------------------------------------------------------------------------
XB_install_defined	set	0
;----------------------------------------------------------------------------
XB_install	MACRO	xbname,root
	pea	\2
	pea	\1
	IFNE	XB_install_defined
	bsr	XB_install_code
	addq	#8,sp
	ELSE
	bsr.s	XB_install_code
	addq	#8,sp
	bra.s	XB_install_code_end
;
XB_install_code:
	movem.l	a3/a4,-(sp)
	movem.l	12(sp),a3/a4	;a3 -> struct  a4 -> chain root
;
	ifne	XB_cpu_mode=2
	subq	#4,sp		;reserve result storage on stack
	gemdos	Super,1.w	;User or Super mode call ?
	tst.l	d0
	bmi.s	.done_super_1
	gemdos	Super,!
.done_super_1:			;here CPU is in supervisor state
	move.l	d0,-(sp)	;push -1 or previous SSP
	endc
;
	ifne	XB_cpu_mode=0
	subq	#4,sp		;reserve result storage on stack
	gemdos	Super,!
	move.l	d0,-(sp)	;push previous SSP
	endc
;
	move.l	a3,a1
	move.l	a4,a2
	move	SR,d2		;d2 = entry interrupt mask
	or	#$0700,SR	;disable interrupts
.search_lp:
	move.l	a4,d0
	bset	#31,d0			;flag vector missing as MI
	move.l	(a4),d1
	beq.s	.done_search		;exit if vector missing
	move.l	d1,a4
	subq	#xb_code-xb_next,a4
	cmpi.l	#'XBRA',xb_magic-xb_next(a4)
	bne.s	.done_search		;exit if chain broken
	move.l	xb_id-xb_next(a4),d1	;d1 = current id
	cmp.l	xb_id(a3),d1		;d1 == sought id ?
	bne.s	.search_lp		;loop back to check remaining chain
	bclr	#31,d0		;flag vector found as PL
.done_search:
	tst.l	d0
	bpl.s	.done_install	;branch if already installed
	lea	xb_next(a1),a1
	move.l	(a2),(a1)+	;link new XBRA to old chain
	move.l	a1,(a2)		;store -> new XBRA as chain root
.done_install:
	move	d2,SR		;restore entry interrupt mask
;
	ifne	XB_cpu_mode=2
	move.l	d0,4(sp)	;store search result in stack
	move.l	(sp)+,d0
	bmi.s	.done_super_2
	gemdos	Super|_ind,d0
.done_super_2:			;here CPU is back in entry state
	move.l		(sp)+,d0	;d0 = search result from stack
	endc
;
	ifne	XB_cpu_mode=1
	tst.l	d0		;flag result in CCR
	endc
;
	ifne	XB_cpu_mode=0
	move.l		d0,4(sp)	;store search result in stack
	gemdos.1	Super,__ARG__on_stack
	move.l		(sp)+,d0	;d0 = search result from stack
	endc
;
	movem.l	(sp)+,a3/a4
	rts	;d0=found_vector  or  (last_chain_vector+1<<31)
XB_install_code_end:
	ENDC
XB_install_defined	set	XB_install_defined+1
	ENDM	;XB_install
;----------------------------------------------------------------------------
XB_remove_defined	set	0
;----------------------------------------------------------------------------
XB_remove	MACRO	xbname,root
	pea	\2
	pea	\1
	IFNE	XB_remove_defined
	bsr	XB_remove_code
	addq	#8,sp
	ELSE
	bsr.s	XB_remove_code
	addq	#8,sp
	IFNE	XB_cpu_mode=2
	bra	XB_remove_code_end
	ELSEIF
	bra.s	XB_remove_code_end
	ENDC
;
XB_remove_code:
	movem.l	a3/a4,-(sp)
	movem.l	12(sp),a3/a4	;a3 -> struct  a4 -> chain root
;
	ifne	XB_cpu_mode=2
	subq	#4,sp		;reserve result storage on stack
	gemdos	Super,1.w	;User or Super mode call ?
	tst.l	d0
	bmi.s	.done_super_1
	gemdos	Super,!
.done_super_1:			;here CPU is in supervisor state
	move.l	d0,-(sp)	;push -1 or previous SSP
	endc
;
	ifne	XB_cpu_mode=0
	subq	#4,sp		;reserve result storage on stack
	gemdos	Super,!
	move.l	d0,-(sp)	;push previous SSP
	endc
;
	move.l	a3,a1
	move.l	a4,a2
	move	SR,d2		;d2 = entry interrupt mask
	or	#$0700,SR	;disable interrupts
.search_lp:
	move.l	a4,d0
	bset	#31,d0			;flag vector missing as MI
	move.l	(a4),d1
	beq.s	.done_search		;exit if vector missing
	move.l	d1,a4
	subq	#xb_code-xb_next,a4
	cmpi.l	#'XBRA',xb_magic-xb_next(a4)
	bne.s	.done_search		;exit if chain broken
	move.l	xb_id-xb_next(a4),d1	;d1 = current id
	cmp.l	xb_id(a3),d1		;d1 == sought id ?
	bne.s	.search_lp		;loop back to check remaining chain
	bclr	#31,d0		;flag vector found as PL
.done_search:
	tst.l	d0
	bmi.s	.done_remove
	move.l	d0,a0				;a0 -> link -> found XBRA
	move.l	(a0),a1				;a1 -> xb_code of found XBRA
	move.l	xb_next-xb_code(a1),(a0)	;unlink found XBRA from chain
.done_remove:
	move	d2,SR		;restore entry interrupt mask
;
	ifne	XB_cpu_mode=2
	move.l	d0,4(sp)	;store search result in stack
	move.l	(sp)+,d0
	bmi.s	.done_super_2
	gemdos	Super|_ind,d0
.done_super_2:			;here CPU is back in entry state
	move.l		(sp)+,d0	;d0 = search result from stack
	endc
;
	ifne	XB_cpu_mode=1
	tst.l	d0		;flag result in CCR
	endc
;
	ifne	XB_cpu_mode=0
	move.l		d0,4(sp)	;store search result in stack
	gemdos.1	Super,__ARG__on_stack
	move.l		(sp)+,d0	;d0 = search result from stack
	endc
;
	movem.l	(sp)+,a3/a4
	rts	;d0=found_vector  or  (last_chain_vector+1<<31)
;
XB_remove_code_end:
	ENDC
XB_remove_defined	set	XB_remove_defined+1
	ENDM	;XB_remove
;----------------------------------------------------------------------------
	ENDC	;RA_XB_defined
;----------------------------------------------------------------------------
; End of file:	RA_XB.I
;----------------------------------------------------------------------------
