;----------------------------------------------------------------------------
;File name:	MEDIA_CH.S		Revision date:	1996.08.05
;Creator:	Ulf Ronald Andersson	Creation date:	1994.02.10
;(c)1992 by:	Ulf Ronald Andersson	All rights reserved
;Released as:	FREEWARE		(NB: commercial sales forbidden!)
;----------------------------------------------------------------------------
;
	output	.APP
;
_deblev	set	0
;
	include	URAn_XB.S
;
;----------------------------------------------------------------------------
;
	SECTION	TEXT
;
	_unilab	rz	;unique zero ref
;
	bra.s	startup
;
;----------------------------------------------------------------------------
;	MChg cookie structure with pointer
;
mc_cookie:
	dc.l	'URAn'
	dc.l	'MChg'
	dc.l	'0100'
	dc.l	mc_par_end-mc_par_beg
mc_par_beg:
mc_drvbits:		;1.00 L extra media change flags for max 32 drives
	dc.l	0
mc_par_end:
;
mc_cookie_p:		;initialized at runtime
	dc.l	-1
;
;----------------------------------------------------------------------------
;	XBRA vector for hdv_mediach
;
	dc.l		mc_cookie
	XB_define	new_mediach,'MChg'
new_mediach_sub:
	move	4(sp),d0
	move.l	(_drvbits).w,d1
	btst	d0,d1
	beq.s	.make_change
	move.l	mc_drvbits(pc),d1
	bclr	d0,d1
	bne.s	.take_change
	XB_gonext_d	new_mediach
;
.make_change:
	move.l	mc_drvbits(pc),d1
	bset	d0,d1
.take_change:
	move.l	d1,mc_drvbits
	moveq	#2,d0
	rts
;
;----------------------------------------------------------------------------
;
mini_tsr_end:
;
;This is the end of the resident segment of the installed TSR
;
;----------------------------------------------------------------------------
;
startup:
;
	include	URAn_APP.S
;
;----------------------------------------------------------------------------
;
init_app:
	include	URAN_ARG.S
	rts
;
exec_app:
	bsr	install_xb
	bmi.s	.got_old_xb
.got_new_xb:			;new XBRAs were installed, possibly TSR
	tst	d7		;TOS/TTP/boot_PRG type program ?
	bmi	main_exit	;make no media changes at TSR installation
.got_old_xb:			;non_TSR must force media changes via TSR
	bsr	find_mc_cookie
	bmi	main_exit
;
	lea	drive_s(pc),a5
	gemdos	Fgetdta
	move.l	d0,old_dta_p-drive_s(a5)
	gemdos	Fsetdta,new_dta(pc)
;
	tst.l	d7
	bmi.s	.do_all		;no arguments for ACCs
	move	arg_cnt(pc),d5	;d5 = arg_cnt
	cmp	#1,d5
	bgt.s	.do_args
;
.do_all:
	bsr	get_drvbits
	move.l	d0,d3
	moveq	#32-1,d4
.loop_all:
	bclr	d4,d3
	beq.s	.next_all
	move	d4,d0
	add	#'A',d0
	move.b	d0,(a5)
	move.l	a5,a0
	bsr.s	do_mediach
.next_all:
	dbra	d4,.loop_all
	bra.s	.done_mediach
;
.do_args:
	move.l	arg_ptr(pc),a4	;a4 = arg_ptr
	subq	#1,d5		;prep for dbra
	clr	d4
.loop_args:
	move.b	(a4),d0
	and.b	#$DF,d0
	move.b	d0,(a5)
.loop_char:
	move.b	(a4)+,d0
	cmp.b	#' ',d0
	bhi.s	.loop_char
	tst	d4
	beq.s	.next_args	;skip command name
	move.b	(a5),d0
	cmp.b	#' ',d0
	bls.s	.next_args	;refuse empty args
	move.l	a5,a0
	bsr.s	do_mediach
.next_args:
	addq	#1,d4
	dbra	d5,.loop_args
;
.done_mediach:
	gemdos	Fsetdta|_ind,old_dta_p(pc)
main_exit:
	tst	d7
	bpl.s	.main_return	;GEM programs can never be TSR
	tst	xb_error_f
	bmi.s	.main_return	;uninstalled must not be TSR
	move.l	#$100+mini_tsr_end-rz,d1
	move.l	#$ADD1,d0
	rts
;
;
.main_return:
	bsr	remove_xb
	clr.l	d0
	rts
;
;
do_mediach:
	movem.l	d3-d4/a3,-(sp)
	move.l	a0,a3
	clr	d3
	move.b	(a3),d3
	sub	#'A',d3
	cmp	#32,d3
	bhs.s	.skip_mediach
	bsr.s	get_drvbits
	move.l	d0,d4
	btst	d3,d4
	beq.s	.skip_mediach
;
	gemdos	Super,!
	move.l	d0,-(sp)
	move.l	mc_cookie_p(pc),a0
	move.l	mc_drvbits-mc_cookie(a0),d0
	bset	d3,d0
	move.l	d0,mc_drvbits-mc_cookie(a0)	;smudge media flag
	gemdos	Super,()
;
	gemdos	Fsfirst,(a3),!
;
.skip_mediach:
	movem.l	(sp)+,d3-d4/a3
	rts
;
get_drvbits:
	move.l	d3,-(sp)
	bios	Drvmap
	move.l	d0,d3
	gemdos	Super,!
	move.l	d0,-(sp)
	cmp	#2,(_nflops).w
	bge.s	.keep_b
	bclr	#1,d3
.keep_b:
	gemdos	Super,()
	move.l	d3,d0
	move.l	(sp)+,d3
	rts
;
;----------------------------------------------------------------------------
;	MChg cookie XBRA search routine
;
find_mc_cookie:
	XB_check	new_mediach(pc),(hdv_mediach).w
	bpl.s		.test_xb
	move.l	a3,-(sp)
	move.l	d0,a3		;a3 -> last vector
	gemdos	Super,!
	move.l	d0,-(sp)
	move.l	(a3),a3		;a3 == last vector
	gemdos	Super,()
	move.l	a3,a0
	move.l	(sp)+,a3
.not_found:
	move.l		a0,d0
	bset		#31,d0
	move.l		d0,mc_cookie_p
	rts		;d0 == erroneous vector + 1<<31 flagged MI
;
.test_xb:
	movem.l	d3/a3,-(sp)
	move.l	d0,a3		;a3 -> vector -> MChg XBRA
	gemdos	Super,!
	move.l	d0,-(sp)
	move.l	(a3),a3		;a3 == vector -> MChg XBRA
	move.l	(phystop).w,d3
	gemdos	Super,()
	move.l	a3,a0		;a0 -> MChg XBRA
	move.l	d3,d0		;d0 == phystop
	movem.l	(sp)+,d3/a3
	move.l	-16(a0),a0	;a0 -> MChg cookie (if correct)
	cmp.l	d0,a0
	bhs.s	.not_found	;too high ?
	cmp	#$800,a0
	blo.s	.not_found	;too low ?
	lea	mc_cookie(pc),a1
	move.l	0(a0),d0
	cmp.l	0(a1),d0
	bne.s	.not_found	;wrong author ?
	move.l	4(a0),d0
	cmp.l	4(a1),d0
	bne.s	.not_found	;wrong id ?
	move.l	8(a0),d0
	cmp.l	8(a1),d0
	blo.s	.not_found	;too low version ?
	and.l	#$F0F0F0F0,d0
	cmp.l	#'0000',d0
	bne.s	.not_found	;illegal version ?	
	st	mc_found_f
	move.l	a0,d0
	move.l	d0,mc_cookie_p
	rts	;d0 == MChg vector flagged PL
;
mc_found_f:
	dc.w		0
;
;----------------------------------------------------------------------------
;	XBRA installation and removal routines
;
install_xb:
	st		xb_error_f
	XB_check	new_mediach(pc),(hdv_mediach).w
	bpl		i_keep_xb
	XB_install	new_mediach(pc),(hdv_mediach).w
	clr		xb_error_f
i_keep_xb:
	move		xb_error_f,d0
	ext.l		d0
	rts
;
xb_error_f:
	dc.w		0
;
remove_xb:
	tst		xb_error_f
	bmi		r_keep_xb
	XB_remove	new_mediach(pc),(hdv_mediach).w
r_keep_xb:
	tst		xb_error_f
	rts
;
;----------------------------------------------------------------------------
;
	data
;
;----------------------------------------------------------------------------
;
acc_name:	dc.b	'  Media changer',NUL
	even
;
drive_s:	dc.b	'A:\*.*',NUL
	even
;
;----------------------------------------------------------------------------
;
	bss
;
;----------------------------------------------------------------------------
;
old_dta_p:	ds.l	1
new_dta:	ds.b	dta_size
;
intin:		ds.w	30
intout:		ds.w	45
ptsin:		ds.w	30
ptsout:		ds.w	12
message:	ds.b	16
		ds.l	$100
mystack:	ds.l	4
;
;----------------------------------------------------------------------------
	End	;of file:	MEDIA_CH.S
