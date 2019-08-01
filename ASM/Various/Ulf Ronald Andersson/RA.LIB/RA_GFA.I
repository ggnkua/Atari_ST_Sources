;----------------------------------------------------------------------------
;File name:	RA_GFA.I			Revision date:	1998.08.15
;Creator:	Ulf Ronald Andersson		Creation date:	1993.05.05
;(c)1993 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE			(commercial sales forbidden!)
;----------------------------------------------------------------------------
;File purpose:	Code library for GFA_BASIC compatibility adaption
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	IFND	RA_GFA_defined
RA_GFA_defined	set	1
; ----------------------------------------------------------------------------
; Three macros are defined:
;
;gfa_fix		=> installs subroutines needed by the other macros
;gfa_func arg_spec	=> adapts subroutine for GFA function call
;gfa_proc arg_spec	=> adapts subroutine for GFA procedure call
; ----------------------------------------------------------------------------
;	GFA_BASIC uses PASCAL-style stacking order for all arguments, but
;	has two different ways of cleaning them off the stack after a call.
;
;	Functions must clean out the arguments themselves, like in PASCAL,
;	but GFA_BASIC will clean out arguments after procedures, like in C.
;
; NB:	The documentation falsely claims that C convention is always used !!!
;
;
;	A series of procedures: gfafix_... ;
;	are used to circumvent GFA BASIC's weird argument handling.
;	This also serves to protect registers a3-a5 from corruption.
;
;	The C compatible code is entered with return address = "gfapop".
;	At function exit "gfapop" first cleans out arguments (if needed),
;	then restores a3-a5 of latest "gfafix_..." and returns to caller.
;	A local stack is used for this purpose, to avoid reentrancy errors.
;
;	By properly using the DEVPAC facilities of conditional assembly,
;	and macros, it now becomes simple to use the same source file to
;	generate code libraries for either GFA_BASIC or PURE_C (TURBO_C).
;	The language used can be set simply by assigning a value to assembly
;	variable "language", as shown here
; ----------------------------------------------------------------------------
	IFND	GFA_BASIC
GFA_BASIC	set	1	;Nonzero activates GFA_BASIC mode
	ENDC
; ----------------------------------------------------------------------------
;	Thus, "GFA_BASIC = 0" before this point will prevent generation of
;	any GFA_BASIC-specific code, whereas "GFA_BASIC = 1" will cause all
;	functions or procedures that use the macros "gfafunc" or "gfaproc"
;	to become fully adapted to GFA_BASIC's (rather odd) requirements.
;
;	If "GFA_BASIC" is not defined at this point, it will be possible
;	to switch back and forth between the languages, simply by using:
;	"GFA_BASIC set 0" and "GFA_BASIC set 1".
;	The latter facility will usually be used only at the start of code.
;
;	The functions can be written to use either data registers or stack
;	for argument transfer, since "gfafix" caters to both kinds.
;	They may even be created in PURE_C and reached by jumps to their
;	XREF'd labels, although the adapted form must be XDEF'd in assembly.
;
;	This is a neat way of making old C libraries GFA_BASIC compatible !!!
;
;
;	An adapting procedure head should begin with the macro "gfaproc".
;	If the procedure has parameters the macro should have an argument
;	that shows the individual parameter sizes (see examples further on).
;
;	An adapting function head should begin with the macro "gfafunc",
;	with a macro argument that shows the sum of parameter sizes.
;	If the function has parameters the macro should have a 2'nd argument
;	that shows the individual parameter sizes (see examples further on).
;
;	Thus, the following are some legal forms:
;
;	gfaproc			;for procedures without arguments
;	gfafunc	0		;for functions without arguments
;	gfaproc w		;for procedures with single 16-bit arg
;	gfafunc	4,l		;for functions with single 32-bit arg
;	gfaproc	wl		;for eg: void v_bar(int wshand,VRECT *xyptr)
;	gfafunc	8,ll		;for eg: int strcmp(char *s1,char *s2)
;	gfafunc	10,llw		;for eg: char *ltoa(long v,char *ds,int base)
; ----------------------------------------------------------------------------
gfafunc	macro	argsize,suffix
	moveq	#\1,d7
	ifne	GFA_BASIC
	bsr	gfafix_\2
	elseif
	bsr	gfafix_
	endc
	endm
; -----------------------------------
gfaproc	macro	suffix
	moveq	#0,d7
	ifne	GFA_BASIC
	bsr	gfafix_\1
	elseif
	bsr	gfafix_
	endc
	endm
; -----------------------------------
gfa_fix	MACRO
	ifne	GFA_BASIC	;some code below is used only for GFA_BASIC
;
gfafix_w:
	movem.w	8(sp),d0
	bra	gfafix_
;
gfafix_ww:
	movem.w	8(sp),d0-d1
	exg	d0,d1
	movem.w	d0-d1,8(sp)
	bra	gfafix_
;
gfafix_l:
	move.l	8(sp),d0
	bra	gfafix_
;
gfafix_www:
	movem.w	8(sp),d0-d2
	exg	d0,d2
	movem.w	d0-d2,8(sp)
	bra.s	gfafix_
;
gfafix_wl:
	movem.w	12(sp),d0
	move.l	8(sp),d1
	move.l	d1,10(sp)
	move	d0,8(sp)
	bra.s	gfafix_
;
gfafix_lw:
	move.l	10(sp),d0
	movem.w	8(sp),d1
	move	d1,12(sp)
	move.l	d0,8(sp)
	bra.s	gfafix_
;
gfafix_wwww:
	movem.w	8(sp),d0-d3
	exg	d0,d3
	exg	d1,d2
	movem.w	d0-d3,8(sp)
	bra.s	gfafix_
;
gfafix_wwl:
	move.l	8(sp),d0
	movem.w	12(sp),d1-d2
	exg	d0,d2
	move.l	d2,12(sp)
	movem.w	d0-d1,8(sp)
	bra.s	gfafix_
;
gfafix_wllwwww:
	movem.w	8(sp),d0-d3
	movem.l	16(sp),d4-d5
	movem.w	24(sp),d6
	exg	d0,d6
	exg	d1,d5
	exg	d2,d4
	movem.w	d3-d6,18(sp)
	movem.l	d1-d2,10(sp)
	move.w	d0,8(sp)
;
	endc			;some routines above exist only in GFA_BASIC mode
;
gfafix_:
	addq.l	#1,gfafix_entry_ct
	move.l	gfafix_sp(pc),a0
	move.l	4(sp),-(a0)
	move.l	#gfapop,4(sp)
	movem.l	a3-a5,-(a0)
	move	d7,-(a0)
	move.l	a0,gfafix_sp
	rts
;
	ifne	GFA_BASIC	;some code below is used only for GFA_BASIC
;
gfafix_wlw:
	movem.w	8(sp),d0-d3
	exg	d0,d3
	movem.w	d0-d3,8(sp)
	swap	d1
	move	d2,d1
	move	d3,d2
	bra.s	gfafix_
;
gfafix_lww:
	move.l	12(sp),d2
	movem.w	8(sp),d0-d1
	exg	d0,d2
	move.l	d0,8(sp)
	movem.w	d1-d2,12(sp)
	bra.s	gfafix_
;
gfafix_ll:
	movem.l	8(sp),d0-d1
	exg	d0,d1
	movem.l	d0-d1,8(sp)
	bra.s	gfafix_
;
gfafix_wwwww:
	movem.w	8(sp),d0-d4
	exg	d0,d4
	exg	d1,d3
	movem.w	d0-d4,8(sp)
	bra.s	gfafix_
;
gfafix_wwwl:
	move.l	8(sp),d0
	movem.w	12(sp),d1-d3
	exg	d0,d3
	exg	d1,d2
	movem.w	d0-d2,8(sp)
	move.l	d3,8(sp)
	bra	gfafix_
;
gfafix_wll:
	movem.l	8(sp),d0-d1
	movem.w	16(sp),d2
	exg	d0,d2
	move.w	d0,8(sp)
	movem.l	d1-d2,10(sp)
	bra	gfafix_
;
	endc			;some routines above exist only in GFA_BASIC mode
;
;
gfapop:
	move.l	gfafix_sp(pc),a0
	add	(a0)+,sp
	movem.l	(a0)+,a3-a5
	move.l	(a0)+,-(sp)	;restore return address
	move.l	a0,gfafix_sp
	addq.l	#1,gfafix_exit_ct
	rts			;exit to original caller
;
;
gfafix_st:
	ds.l	8*(2+3*4+4)		;allows 8 level reentrancy (norm: 1 used)
gfafix_st_end:
gfafix_sp:
	dc.l	gfafix_st_end
;
gfafix_entry_ct:
	dc.l	0
gfafix_exit_ct:
	dc.l	0
	ENDM			;gfa_fix
; ----------------------------------------------------------------------------
	ENDC	;RA_GFA_defined
; ----------------------------------------------------------------------------
;End of file:	RA_GFA.I
; ----------------------------------------------------------------------------
