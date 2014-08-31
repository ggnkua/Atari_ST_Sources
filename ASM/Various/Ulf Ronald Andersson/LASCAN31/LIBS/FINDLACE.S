;----------------------------------------------------------------------------
;File name:	FINDLACE.S			Revision date:	1994.08.22
;Created by:	Ulf Ronald Andersson		Creation date:	1994.08.19
;Code purpose:	Lib to simplify access to Lace Parameter Table
;----------------------------------------------------------------------------
;
	IFND	lpt_sizeof
	INCLUDE	l_struct.s
	ENDC
;
;----------------------------------------------------------------------------
;
;Use the macro 'find_lace' to seek the LaceScan Parameter Table structure.
;It will create a subroutine 'find_lace_sub' when first called, and then
;call that routine.
;
;At exit d0 = 0 if no compatible structure was found.
;Otherwise d0 is a pointer to the LPT structure defined in file 'L_STRUCT.S'.
;No registers except D0 and CCR are altered
;
;
find_lace	MACRO
		IFND	find_lace_def	;generate subroutine once per pass
find_lace_def	SET	1
;
	bra.s	past_find_lace_sub
;
find_lace_sub:	;this subroutine alters only d0 & CCR
	movem.l	d1-d3/a0-a2,-(sp)	;push registers
;
;We must enter Supervisor mode to access '_cookies' in protected RAM
;	
	clr.l	-(sp)			;super-mode request
	move	#$20,-(sp)		;gemdos	Super code
	trap	#1			;call gemdos
	addq	#6,sp			;clean stack
	move.l	d0,-(sp)		;push old SSP
	move.l	($5A0).w,a0		;a0 = cookie jar ptr 
;
;NB: stay super just in case some idiot put the jar itself in protected RAM
;
	move.l	a0,d0			;does jar exist ?
	beq.s	.done_cookies		;if not, skip search
	subq	#8,a0			;step a0 2 longs back
.seek_loop:
	addq	#8,a0			;step a0 2 longs ahead
	move.l	(a0),d0			;any cookie left untested ?
	beq.s	.done_cookies		;if not, exit search
	cmp.l	#'Lace',d0		;found 'Lace' cookie ?
	bne.s	.seek_loop		;if not, loop back to test rest
	move.l	4(a0),d0		;d0 = value of 'Lace' cookie
.done_cookies:
	move.l	d0,d3			;d3 = Null or value of 'Lace' cookie
	move	#$20,-(sp)		;gemdos	Super code
	trap	#1			;restore old SSP and exit super mode
	addq	#6,sp			;clean stack
;
;We're back in user mode, with d3 = Null or pointer to Lace Parameter Table
;
	move.l	d3,d0			;d0 = Null or -> Lace Parameter Table
	beq.s	.exit			;exit with failure if no table found
	move.l	d0,a0			;a0 -> Lace Parameter Table (we hope)
	clr.l	d0			;pre_clear d0 in case of failure
	cmp.l	#'Lace',-4(a0)		;Does table header confirm identity ?
	bne.s	exit			;if not, exit with failure
.found_lace:				;Here we do have an LPT pointer
	move	#interface_ver,d0	;d0 = version of our interface
	cmp	lpt_interface(a0),d0	;same as found interface version ?
	bne.s	exit			;if not, exit with failure
;
;Here we know a compatible LaceScan version is active
;
	move.l	a0,d0			;d0 -> LPT structure
.exit:
	movem.l	(sp)+,d1-d3/a0-a2	;pull registers
	tst.l	d0			;flag NE if found, otherwise EQ
	rts
;
past_find_lace_sub:
	ENDC
;
	bsr	find_lace_sub
	ENDM
;
;
;----------------------------------------------------------------------------
;End of file:	FINDLACE.S
;----------------------------------------------------------------------------
