;----------------------------------------------------------------------------
;File name:	RA_XGEM.I			Revision date:	1999.10.03
;Creator:	Ulf Ronald Andersson		Creation date:	1998.10.12
;(c)1998 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE			(commercial sales forbidden!)
;----------------------------------------------------------------------------
;Purpose:	Macro library for XGEM function extension
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	IFND	RA_XGEM_defined
RA_XGEM_defined	set	1
;----------------------------------------------------------------------------
	include	RA_XB.I
;----------------------------------------------------------------------------
;	Library macros
;
;id_XGEM	xbstruct	contact => 0.EQ.PL  unreachable => -1.NE.MI
;ck_XGEM	xbstruct	generates XGEM dispatcher code for -'id' ops
;
;XGEM_define		xbname,xbid,xbnext	;defines XGEM dispatcher head
;XGEM_BIOS_define	xbname,xbid,xbnext	;defines BIOS dispatcher head
;XGEM_patch					;defines code for a subroutine
;
;XB_list	a0->root a1->list d0=MAX=> d0 = count of xb_code entries copied
;XB_tail	a0->root		=> d0 -> last entry in chain or NULL if none
;XB_retail	a0->root a1->old d0->new=> cut & correct chain and link new tail
;----------------------------------------------------------------------------
;'id_XGEM' is for use by any code wanting to test if a specific XBRA linked
;XGEM function dispatcher is currently reachable through the trap #2 call.
;Unlike normal XGEM calls this one should always be safe to use...
;Normally it will be used by a BIOS dispatcher for Setexc calls concerning
;'etv_critic', since that signals XGEM vectors may have been changed. You
;do not need to use this macro directly if you have used 'XGEM_BIOS_define'
;(shown further below) to define the header of your BIOS dispatcher.
;
;It is needed because TOS and NVDI etc sometimes smash the XBRA chains, and
;many GEM enhancers are written so as to do that as well.  This can not just
;be tested in the manner normal for most XBRA chains, because some programs
;(eg: debuggers) often smash the chains *WITHOUT* breaking contact with the
;previously linked routines (by the method used before XBRA was invented).
;Linking up again in normal XBRA manner will then lead to an eternal loop
;in the dispatchers, with total system lockup resulting.
;
;'id_XGEM' and some other macros make it possible to gain full control of
;this process, such that most enhancers can coexist peacefully with each
;other as well as with debuggers and other software.
;----------------------------------------------------------------------------
id_XGEM	MACRO	xbstruct	;For use by those looking for dispatcher
	pea	-1.w		;push error flag for id_blk on stack
	pea	\1		;push XGEM_p for id_blk on stack
	lea	(sp),a0		;a0 -> id_blk,  (XGEM_p, flag)
	move.l	a0,d1		;d1 -> id_blk
	move.l	#-'id',d0	;d0 = -'id' as XGEM opcode
	trap	#2
	move.l	(sp)+,a0	;a0 -> struct
	move.l	(sp)+,d0	;d0 = result, found=>zero, unfound=>E_ERROR
	ENDM
;----------------------------------------------------------------------------
;'ck_XGEM' generates the dispatcher code needed to allow 'id_XGEM' (above)
;to find out if the dispatcher can be reached through the traps. This code
;should be jumped to when the XGEM opcode (in D0) is one that the dispatcher
;does not implement.  The code will then check if that opcode is -'id',
;and if that is the case it will perform as needed.  If the xbstruct sought
;does not match the address of the dispatcher's xbstruct it will pass the
;call on to others in the XGEM XBRA chain.
;
;This macro is not needed if you use 'XGEM_define' as shown further below.
;----------------------------------------------------------------------------
ck_XGEM	MACRO	xbstruct	;For use inside dispatcher
	cmp	#-'id',d0	;is XGEM opcode -'id'
	bne.s	.use_old_\@
	lea	\1,a0		;a0 -> local XGEM
	exg	d1,a0		;d1 -> local XGEM  a0 -> id_blk, (XGEM_p, flag)
	cmp.l	(a0),d1		;is this the sought XGEM dispatcher ?
	bne.s	.use_old_\@	;if not, go let others try
	clr.l	4(a0)		;clr error flag
	rte			;exit from trap
;-------
.use_old_\@:
	move.l	a0,d1		;d1 -> id_blk again
	move.l	8+\1,a0		;\/ Use older xgem
	jmp	(a0)		;/\
	ENDM
;----------------------------------------------------------------------------
;'XGEM_define' below may be used to create the initial segment of an
;XGEM dispatcher.  This will call XB_define to create its XBRA header,
;and will itself contain all code needed for the -'id' implementation.
;At the point below the macro call you must add your actual dispatcher,
;just as if you had used XB_define to create the header.
;
;Before the XGEM dispatcher defined this way can be activated, you must
;also have created and activated the associated BIOS dispatcher code,
;which is used to relink XGEM dispatchers as and when needed. For the
;creation of that code, use 'XGEM_BIOS_define' further below.
;----------------------------------------------------------------------------
XGEM_define	MACRO	xbstruct_name,xbra_id,init_link
	IIF	(XB_seek_code_defined=0)	XB_seek_code
	IIF	(XB_retail_defined=0)		XB_retail
;-------
try_id_\1:
	lea	\1,a0		;a0 -> local XGEM
	exg	d1,a0		;d1 -> local XGEM  a0 -> id_blk, (XGEM_p, flag)
	cmp.l	(a0),d1		;is this the sought XGEM dispatcher ?
	bne.s	.use_old_XGEM	;if not, go let others try
	clr.l	4(a0)		;clr error flag
	rte			;exit from trap
;-------
.use_old_XGEM:
	move.l	a0,d1		;d1 -> id_blk again
	move.l	8+\1,a0		;\/ Use older xgem
	jmp	(a0)		;/\
;-------------------------------------
	illegal				;Mark code-data transition
	XB_define	\1,\2,\3
	cmp	#-'id',d0		;XGEM opcode = -'id' call ?
	beq.s	try_id_\1
	tst.b	XGEM_smash_f
	beq.s	skip_unsmash_\1
	movem.l	d0/a1,-(sp)
	lea	(ev_xgem).w,a0		;a0 -> ev_xgem
	lea	\1(pc),a1
	XB_seek_code
	bmi.s	done_unsmash_\1
	move.l	bad_XGEM_tail(pc),a1	;a1 -> bad terminating XGEM xb_code
	move.l	good_XGEM_tail(pc),d0	;d0 -> good terminating XGEM xb_code
	XB_retail			;replace bad struct with good
	sf	XGEM_smash_f
done_unsmash_\1:
	movem.l	(sp)+,d0/a1
skip_unsmash_\1:
	ENDM
;----------------------------------------------------------------------------
;'XGEM_BIOS_define' below may be used to create the initial segment of a
;BIOS dispatcher.  This will call XB_define to create its XBRA header,
;and will itself contain all code needed for the -'id' implementation,
;used for Setexc calls concerning 'etv_critic'.
;
;It will call a user-supplied subroutine 'patch_XGEM_sub', which must be
;hand-tailored to fit the requirements of the XGEM dispatcher involved.
;If needs are 'simple', most code of that subroutine may also be generated
;by the macro 'XGEM_patch' shown further below.
;----------------------------------------------------------------------------
XGEM_BIOS_define	MACRO	xbstruct_name,xbra_id,init_link
	illegal				;Mark code-data transition
XGEM_smash_f:	dc.w	0		;flags smashed state
bad_XGEM_tail:	dc.l	0		;tail XGEM xb_code in smashed state
good_XGEM_tail:	dc.l	0		;tail XGEM xb_code in normal state
	XB_define	\1,\2,\3
	Pass_Frame	a0		;a0 -> arguments
	cmp	#Setexc&$ff,(a0)
	bne.s	exit_XGEM_BIOS_head
	cmp	#etvn_critic,2(a0)
	bne.s	exit_XGEM_BIOS_head
	move.l	4(a0),-(sp)		;\/ repush the 8
	move.l	(a0),-(sp)		;/\ argument bytes
	push_ex	end_set_critic_\1	;Push a simulated exception stack frame
	move.l	\1+xb_next(pc),a0	;\/ Let older BIOS dispatchers
	jmp	(a0)			;/\ do their normal work first
;-------------------------------------
end_set_critic_\1:			;Normal Setexc work is completed.
	addq	#8,sp			;remove argument copy from stack
	move.l	d0,-(sp)
	bsr.s	patch_XGEM_sub
	move.l	(sp)+,d0
	rte				;exit to caller
exit_XGEM_BIOS_head:
	ENDM
;----------------------------------------------------------------------------
;'XGEM_patch' below creates code for the subroutine 'patch_XGEM_sub', needed
;by 'XGEM_BIOS_define' above.  The arguments are defined as follows.
;
;linked_XGEM_p	long pointer in RAM -> XBRA struct of the XGEM dispatcher
;		you expect to be in the chain at this time, or <= 0 if none.
;		This will be updated if the routine relinks or unlinks any.
;
;wanted_XGEM_p	long pointer in RAM -> XBRA struct of the XGEM dispatcher
;		you want active from this time on. This must be valid, and
;		may of course be identical to that in 'linked_XGEM_p' when
;		that is valid.
;
;When different valid structs are used, an attempt will be made to remove
;'(linked_XGEM_p)' from the XGEM chain and replace it by '(wanted_XGEM_p)'.
;----------------------------------------------------------------------------
XGEM_patch	MACRO	linked_XGEM_p,wanted_XGEM_p
	IFNE	(0=(XB_init_defined&XB_seek_code_defined&XB_kill_code_defined&XB_tail_defined&XB_retail_defined))
	bra	XGEM_patch_code
	IIF	(XB_init_defined=0)		XB_init
	IIF	(XB_seek_code_defined=0)	XB_seek_code
	IIF	(XB_kill_code_defined=0)	XB_kill_code
	IIF	(XB_tail_defined=0)		XB_tail
	IIF	(XB_retail_defined=0)		XB_retail
	ENDC
;-------
XGEM_patch_code:
	move.l	\1(pc),a1		;a1 -> XGEM linked before
	move.l	a1,d0			;was there any in use ?
	bmi.s	.new_linkup		;if not, we must link one now
	lea	(ev_xgem).w,a0		;a0 -> ev_xgem
	move.l	\2(pc),a1
	lea	xb_code(a1),a1		;a1 -> xb_code of XGEM now wanted
	cmp.l	(a0),a1
	beq	.exit			;exit if already topped
	move.l	\1(pc),a1		;a1 -> XGEM linked before
	XB_kill_code			;if found, unlink it
	bpl.s	.new_linkup		;on success, go link it up again
	id_XGEM	(a1)			;is late XGEM reachable through smashed chain ?
	bne.s	.new_linkup		;if not, we can just relink normally
;---------;Here chain is smashed, but calls to late nu_XGEM are still coming through
;---------;This means we can't relink now, since that would cause a lockup loop
	lea	(ev_xgem).w,a0		;a0 -> ev_xgem
	XB_tail				;d0 -> xb_code of terminating XGEM
	move.l	d0,bad_XGEM_tail	;store -> bad XGEM tail
	move.l	\1(pc),a0	;a0 -> nu_XGEM linked before
	lea	xb_next(a0),a0		;a0 -> link as root
	move.l	d0,a1			;a1 -> bad XGEM tail
	move.l	good_XGEM_tail(pc),d0	;d0 -> good XGEM tail
	XB_retail			;clean our own house !
	st	XGEM_smash_f
	bra.s	.exit			;exit for now, we can't relink safely yet
;
.new_linkup:
	tst.b	XGEM_smash_f
	beq.s	.done_unsmash
	lea	(ev_xgem).w,a0		;a0 -> ev_xgem
	move.l	bad_XGEM_tail(pc),a1	;a1 -> bad terminating XGEM struct
	move.l	good_XGEM_tail(pc),d0	;d0 -> good terminating XGEM struct
	XB_retail			;clean up the currently installed structs
.done_unsmash:
	st	\1			;Here no XGEM of ours is active
	lea	(ev_xgem).w,a0		;a0 -> ev_xgem
	move.l	\2(pc),a1		;a1 -> nu_XGEM now wanted
	XB_init				;install wanted XGEM in XBRA chain
	bmi.s	.exit			;exit on E_ACCDN (XBRA name conflict)
	move.l	a1,\1			;Here a new XGEM has been activated
	tst.b	XGEM_smash_f
	beq.s	.done_linkup
	lea	xb_next(a1),a0		;a0 -> link as root
	move.l	bad_XGEM_tail(pc),a1	;a1 -> bad XGEM tail
	move.l	good_XGEM_tail(pc),d0	;d0 -> good XGEM tail
	XB_retail			;clean up the currently installed structs
	sf	XGEM_smash_f
.done_linkup:
	lea	(ev_xgem).w,a0		;a0 -> ev_xgem
	XB_tail				;d0 -> xb_code of terminating XGEM
	move.l	d0,good_XGEM_tail	;store -> bad terminating XGEM struct
.exit:
XGEM_patch_end:
	ENDM
;----------------------------------------------------------------------------
;'XB_tail' finds the last entry in a given XBRA chain, and returns a
;pointer to that xb_code entry. Normally this will not have any XBRA header.
;----------------------------------------------------------------------------
;entry:	a0 -> XBRA chain root
;exit:	a0 = preserved
;  "	d0 -> xb_code of tail entry in chain unless NULL (invalid root)
;----------------------------------------------------------------------------
XB_tail_defined	set	0
;----------------------------------------------------------------------------
XB_tail	MACRO	xbname,root
	IFNE	XB_tail_defined
	bsr	XB_tail_code
	ELSE
	bsr.s	XB_tail_code
	bra.s	XB_tail_code_end
;-------
XB_tail_code:
	movem.l	a0/a2,-(sp)		;push registers
	move.l	a0,d0			;test -> root
	ble.s	.exit_d0		;return 0 if not valid
	move.l	(a0),d0			;d0 -> first entry
	ble.s	.exit_d0		;return it if not valid
	move.l	d0,a2			;a2 -> first entry
.loop:
	move.l	d0,a0			;a0 -> current entry
	cmp.l	#'XBRA',xb_magic-xb_code(a0)
	bne.s	.exit_a0		;exit at end of chain
	move.l	xb_next-xb_code(a0),d0	;d0 -> next entry
	ble.s	.exit_a0		;exit at invalid entry
	cmp.l	a2,d0			;is next entry looped ?
	bne.s	.loop			;loop back for unlooped entries
.exit_a0:
	move.l	a0,d0			;d0 = last valid ptr
.exit_d0:
	movem.l	(sp)+,a0/a2		;pull registers
	rts
XB_tail_code_end:
	ENDC
XB_tail_defined	set	XB_tail_defined+1
	ENDM
;----------------------------------------------------------------------------
;'XB_retail' removes the last xb_code entry of the given XBRA chain (a0) and
;replaces that by the one specified by (d0).  It also cuts the chain at any
;occurence of a 'bad' xb_code tail specified by (a0), and also cuts the chain
;at any looping to either of the first two entries.  The new 'tail' xb_code
;that was specified in d0 will be linked in after either type of cut.
;
;This is the macro that enables us to survive vector smashups by debuggers...
;It prevents dispatcher loops from arising that would lock up the system,
;and allows the restoration of lost links to the XGEM of TOS.  For that
;it is naturally dependent on other code having saved those links.
;----------------------------------------------------------------------------
;entry:	a0 -> XBRA chain root		or simulated by xb_next (et al.)
;  "	a1 -> xb_code of old tail
;  "	d0 -> xb_code of new tail
;exit:	a0 = preserved
;  "	d0 = preserved
;----------------------------------------------------------------------------
XB_retail_defined	set	0
;----------------------------------------------------------------------------
XB_retail	MACRO	xbname,root
	IFNE	XB_retail_defined
	bsr	XB_retail_code
	ELSE
	bsr.s	XB_retail_code
	bra.s	XB_retail_code_end
;-------
XB_retail_code:
	movem.l	d0-d2/a1-a4,-(sp)
	lea	xb_code-xb_next(a0),a2	;a2 -> simulated xb_code of root
	lea	(a1),a3			;a3 -> xb_code of old tail
	move.l	d0,a4			;a4 -> xb_code of new tail
	move.l	a2,a0			;a0 -> simulated xb_code of root
	move.l	xb_next-xb_code(a0),d0	;d0 -> xb_code of first entry or is NULL
	ble.s	.trunc_1_at_a0		;cut chain at invalid entry
	move.l	d0,d2			;d2 -> first entry
.loop_1:
	move.l	d0,a1			;a1 -> current entry
	cmp.l	#'XBRA',xb_magic-xb_code(a1)
	bne.s	.trunc_1_at_a0		;cut chain at end of chain
	cmp.l	a2,d0			;is current entry same as root ?
	beq.s	.trunc_1_at_a0		;then cut chain here
	cmp.l	a3,d0			;is current entry same as old tail ?
	beq.s	.trunc_1_at_a0		;then cut chain here
	cmp.l	a4,d0			;is current entry same as new tail ?
	beq.s	.trunc_1_at_a0		;then cut chain here
	move.l	a1,a0			;a0 -> current entry
	move.l	xb_next-xb_code(a1),d0	;d0 -> next entry
	ble.s	.trunc_1_at_a0		;cut chain at invalid entry
	cmp.l	d2,d0			;is next entry same as first entry ?
	bne.s	.loop_1			;loop back for unlooped entries
;Here we must cut chain due to chain loop (to first entry)
.trunc_1_at_a0:
	move.l	a4,xb_next-xb_code(a0)	;link new tail at cut end of chain
.exit:
	movem.l	(sp)+,d0-d2/a1-a4
	rts
XB_retail_code_end:
	ENDC
XB_retail_defined	set	XB_retail_defined+1
	ENDM
;----------------------------------------------------------------------------
;'XB_list' removes the last xb_code entry of the given XBRA chain (a0) and
;replaces that by the one specified by (d0).  It also cuts the chain at any
;occurence of a 'bad' xb_code tail specified by (a0), and also cuts the chain
;at any looping to either of the first two entries.  The new 'tail' xb_code
;that was specified in d0 will be linked in after either type of cut.
;----------------------------------------------------------------------------
;entry:	a0 -> XBRA chain root
;  "    a1 -> space for list
;  "	d0 =  Max count of entries in the list (each -> an xb_code area)
;exit:	a0 = preserved
;  "	d0 = count of entries stored
;----------------------------------------------------------------------------
XB_list_defined	set	0
;----------------------------------------------------------------------------
XB_list	MACRO	xbname,root
	IFNE	XB_list_defined
	bsr	XB_list_code
	ELSE
	bsr.s	XB_list_code
	bra.s	XB_list_code_end
;-------
XB_list_code:
	movem.l	d1-d2/a0-a2,-(sp)
	move	d0,d1			;d1 = MAX count
	clr.l	d0			;d0 = count, initially zero
	move.l	a1,d2			;test -> list
	ble.s	.exit
	move.l	a0,d2			;test d2 -> root
	ble.s	.exit
	move.l	(a0),a0			;a0 -> first entry, unless NULL
	move.l	a0,a2			;a2 -> first entry
.loop:
	cmp	d1,d0			;reached MAX count ?
	bhs.s	.exit			;exit if list full
	move.l	a0,d2			;test current entry
	ble.s	.exit			;exit if current entry invalid ptr
	move.l	a0,(a1)+		;store entry in list
	addq	#1,d0			;increment count
	cmp.l	#'XBRA',xb_magic-xb_code(a0)	;valid xb_magic ?
	bne.s	.exit			;exit at end of chain
	move.l	xb_next-xb_code(a0),a0	;a0 -> next entry
	cmp.l	a2,a0			;is next entry looped ?
	bne.s	.loop			;loop back for unlooped entries
;-------
.exit:
	movem.l	(sp)+,d1-d2/a0-a2
	rts
XB_list_code_end:
	ENDC
XB_list_defined	set	XB_list_defined+1
	ENDM
;----------------------------------------------------------------------------
	ENDC	;RA_XGEM_defined
;----------------------------------------------------------------------------
; End of file:	RA_XGEM.I
;----------------------------------------------------------------------------
