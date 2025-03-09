;----------------------------------------------------------------------------
;File name:	FINDVFNT.S			Revision date:	1995.10.04
;Created by:	Ulf Ronald Andersson		Creation date:	1995.10.04
;Code purpose:	Lib to simplify access to VDIFont cookie parameters
;----------------------------------------------------------------------------
;
	IFND	VF_size
	INCLUDE	VDIFONT.SH
	ENDC
;
;----------------------------------------------------------------------------
;
;Use the macro 'find_VFnt' to seek the VDIFont cookie parameter structure.
;It will create a subroutine 'find_VFnt_sub' when first called, and then
;call that routine.
;
;This macro should be called with CPU in 'user' state, not 'supervisor'.
;
;At exit d0 = 0 if no compatible structure was found.
;Otherwise d0 is a pointer to the structure defined in file 'VDIFONT.SH'.
;No registers except D0 and CCR are altered
;
;
find_VFnt	MACRO
		IFND	find_VFnt_def	;generate subroutine once per pass
find_VFnt_def	SET	1
;
	bra.s	past_find_VFnt_sub
;
find_VFnt_sub:				;this subroutine alters only d0 & CCR
	movem.l	d1-d3/a0-a2,-(sp)	;push registers
;
;We must enter Supervisor mode to access '_cookies' in protected RAM
;
	pea	1.w		;\
	move	#$20,-(sp)	; \/ inquire CPU mode
	trap	#1		; /\ User => 0,  Super => -1
	addq	#6,sp		;/
;
	tst.l	d0
	bmi.s	.stay_super_1
;
	clr.l	-(sp)		;\
	move	#$20,-(sp)	; \/ Enter Super mode
	trap	#1		; /\ with SSP = old USP
	addq	#6,sp		;/
.stay_super_1:
	move.l	d0,-(sp)	;push entry SSP, or -1 if SSP unchanged
;
	move.l	($5A0).w,a0	;a0 = cookie jar ptr 
;
;NB: stay Super just in case some idiot put the jar itself in protected RAM
;
	move.l	a0,d0		;does jar exist ?
	beq.s	.done_cookies	;if not, skip search
	subq	#8,a0		;step a0 2 longs back
.seek_loop:
	addq	#8,a0		;step a0 2 longs ahead
	move.l	(a0),d0		;any cookie left untested ?
	beq.s	.done_cookies	;if not, exit search
	cmp.l	#VF_magic_con,d0	;found 'VFnt' cookie ?
	bne.s	.seek_loop	;if not, loop back to test rest
	move.l	4(a0),d0	;d0 = value of 'VFnt' cookie
.done_cookies:
	move.l	d0,d3		;d3 = Null or value of 'VFnt' cookie
;
	move.l	(sp)+,d0	;d0 = entry SSP, or -1
	bmi.s	.stay_super_2
;
	move.l	d0,-(sp)	;\
	move	#$20,-(sp)	; \/ Exit Super mode
	trap	#1		; /\ restoring entry SSP
	addq	#6,sp		;/
.stay_super_2:
;
;We're back in entry mode, with d3 = Null or pointer to VFnt Parameter Table
;
	move.l	d3,d0			;d0 = Null or -> VFnt Parameter Table
	beq.s	.exit			;exit with failure if no table found
	move.l	d0,a0			;a0 -> VFnt Parameter Table (we hope)
	clr.l	d0			;pre_clear d0 in case of failure
	cmp.l	#VF_magic_con,(a0)	;Does table header confirm identity ?
	bne.s	.exit			;if not, exit with failure
.found_VFnt:				;Here we do have an LPT pointer
	move	#VF_int_con,d0		;d0 = version of our interface
	cmp	VF_interface(a0),d0	;same as found interface version ?
	bne.s	.exit			;if not, exit with failure
;
;Here we know a compatible VDIFONT version is active
;
	move.l	a0,d0			;d0 -> VFnt structure
.exit:
	movem.l	(sp)+,d1-d3/a0-a2	;pull registers
	tst.l	d0			;flag NE if found, otherwise EQ
	rts
;
past_find_VFnt_sub:
	ENDC
;
	bsr	find_VFnt_sub
	ENDM
;
;
;----------------------------------------------------------------------------
;End of file:	FINDVFnt.S
;----------------------------------------------------------------------------
