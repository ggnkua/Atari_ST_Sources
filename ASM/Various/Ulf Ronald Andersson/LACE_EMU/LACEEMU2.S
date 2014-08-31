;----------------------------------------------------------------------------
; File name:	LACE_EMU.S			Revision date:	2000.07.11
; Created by:	U.R. Andersson			Creation date:	1994.07.02
; Project:	Lace_Emu			Version:	4.1
;----------------------------------------------------------------------------
	nolist
	include	L_STRUCT.I
	include	RA_SYS.I
	include	RA_LA.I
	include	RA_TOS.I
	include	RA_XB.I
	include	RA_JAR.I
;----------------------------------------------------------------------------
emu_version	=	$41		;version:	4.1
M_VERSION	MACRO
		dc.b	'4.1'
		ENDM
;----------------------------------------------------------------------------
	ifnd	emu_unique_defined
emu_unique_defined	set	1
emu_unique	=	6		;emu_id:	6
maxrez_size	=	(1280*960/8)	;Bytes used for emu screen
TABLE_mode	=	0		;0 = small  1 = large
	endc
;----------------------------------------------------------------------------
	section	TEXT
;----------------------------------------------------------------------------
;	Flag bits for int_protect_f of LaceScan and emu_block_f of Lace_Emu
;	'emu_block_f' can be accessed via lpt_emu_block_p+LPT
;
interrupt_b	=	7
user_setup_b	=	6
setscreen_b	=	5
opnwk_b		=	4
emu_off_b	=	3
external_b	=	2
lace_2_lemu_b	=	1
;
;NB:	bits 1 & 0 are reserved for LaceScan use
;----------------------------------------------------------------------------
	_unilab	rz		;relative zero for local ref's
	jmp	(init_emu).l
emu_mark:
	dc.l	'LEmu'
emu_id:
	dc.b	emu_unique,emu_version
;----------------------------------------------------------------------------
;		emu_command	Subroutine for 'Set_Lace' control of Emu
;
emu_command:
	movem.l	d1-d3/a0-a3,-(sp)
	move	d0,d3			;d3 = command
	gemdos	Super,1
	move.l	d0,-(sp)
	bmi.s	.keep_super
	gemdos	Super,()
	move.l	d0,-(sp)
.keep_super:
	lea	(vz).l,a0
	move.l	LPT_p-vz(a0),a3
	move	#E_INVFN,d0
	tst	lpt_emu_type_ix(a3)
	beq	exit_emu_command	
	move	d3,d0			;d0 = command
	bmi	check_speed		;command < 0 => check_speed
	cmp	#10,d0
	bhs.s	set_speed		;command > 9 => set_speed
	cmp	#filt_ix_lim,d0
	bhs	check_filt		;command >= filt_ix_lim => check_filt
set_filt:				;command < filt_ix_lim => set_filt
	cmp	#1,d0
	blo	check_filt		;command = 0 => check_filt
	beq.s	.set_prev_filt		;command = 1 => .set_prev_filt
	cmp	#2,d0
	bhi.s	check_filt		;command > 2 => check_filt
.set_next_filt:				;command = 2 => .set_next_filt
	lea	next_leg_t-vz(a0),a1
	bra.s	.step_filt
;
.set_prev_filt:
	lea	prev_leg_t-vz(a0),a1
.step_filt:
	clr	d1
	move.b	sc_emu_rez+lpt_SCD(a3),d1
	cmp	#7,d1
	bhi.s	check_filt
.test_leg:
	move	sc_rez+lpt_SCD(a3),d0
	cmp	#7,d0
	bhi.s	check_filt
	asl	#3,d0
	or	d1,d0
	asl	#2,d0
	move.l	(a1,d0),a1		;a1 -> filter step table of emulation
	move	emu_filt_ix-vz(a0),d0
	cmp	#filt_ix_lim,d0
	bhs.s	check_filt
	add	d0,d0
	move	(a1,d0),d0		;d0 = new filter index
	move	d0,emu_filt_ix-vz(a0)
	asl	#2,d0
	lea	emu_filt_t-vz(a0),a1
	move.l	(a1,d0),emu_link_p
	move	d0,ref_filt_ix-vz(a0)
	jsr	init_filt-vz(a0)
	move	(hw_pal).w,background-vz(a0)
	jsr	fix_colour
	bsr	emu_center
	bra.s	check_filt
;
set_speed:
	lea	max_spd_t+2-vz(a0),a1
	add	ref_filt_ix-vz(a0),a1
	cmp	(a1),d0
	bls.s	set_speed_1
	move	(a1),d0
set_speed_1:
	move	d0,emu_spd-vz(a0)
check_speed:
	move	emu_spd-vz(a0),d0
	bra.s	return_word
;
check_filt:
	move	emu_filt_ix-vz(a0),d0
return_word:
	and.l	#$FFFF,d0
exit_emu_command:
	move.l	d0,d3
	move.l	(sp)+,d1
	bmi.s	.keep_super
	gemdos	Super|_ind,d1
.keep_super:
	move.l	d3,d0
	movem.l	(sp)+,d1-d3/a0-a3
	rts
;
;end of:	emu_command
;----------------------------------------------------------------------------
;		emu_newmode	subroutine to set Emu scroll mode
;
emu_newmode:
	cmp	#2,d0
	bne.s	.set_mode
	move	(scan_mode).l,d0
	not	d0
.set_mode:
	tst	d0
	sne	d0
	ext	d0
	move	d0,scan_mode
	rts
;
;end of:	emu_newmode
;----------------------------------------------------------------------------
;		emu_sethome	SUPER subroutine to reset & home screen
;
emu_sethome:
	movem.l	d0-d2/a0-a2,-(sp)
	lea	(vz).l,a2
	move.l	LPT_p-vz(a2),a1
	bset	#external_b,emu_block_f-vz(a2)
	cmp	#emu_slot,d0
	bne.s	.set_slot
	move	work_slot-vz(a2),d0	;d0 = slot pos requested at opnwk
.set_slot:
	move	d0,lace_slot-vz(a2)	;d0 = active slot pos
	bsr	fix_filter
	bsr	calc_extra
	clr	mscan_Xpos-vz(a2)
	clr	mscan_Ypos-vz(a2)
	bra	center_mouse
;
;end of:	emu_sethome
;----------------------------------------------------------------------------
;		emu_home	SUPER subroutine to home screen
;
emu_home:
	movem.l	d0-d2/a0-a2,-(sp)
	lea	(vz).l,a2
	move.l	LPT_p-vz(a2),a1
	bset	#external_b,emu_block_f-vz(a2)
	clr	mscan_Xpos-vz(a2)
	clr	mscan_Ypos-vz(a2)
	bra	center_mouse
;
;end of:	emu_home
;----------------------------------------------------------------------------
;		emu_left	SUPER subroutine to pull screen left
;
emu_left:
	movem.l	d0-d2/a0-a2,-(sp)
	lea	(vz).l,a2
	move.l	LPT_p-vz(a2),a1
	bset	#external_b,emu_block_f-vz(a2)
	clr	mscan_Xpos-vz(a2)
	bra	center_mouse
;
;end of:	emu_left
;----------------------------------------------------------------------------
;		emu_right	SUPER subroutine to pull screen right
;
emu_right:
	movem.l	d0-d2/a0-a2,-(sp)
	lea	(vz).l,a2
	move.l	LPT_p-vz(a2),a1
	bset	#external_b,emu_block_f-vz(a2)
	move	extra_Xrez-vz(a2),mscan_Xpos-vz(a2)
	bra.s	center_mouse
;
;end of:	emu_right
;----------------------------------------------------------------------------
;		emu_up		SUPER subroutine to pull screen up
;
emu_up:
	movem.l	d0-d2/a0-a2,-(sp)
	lea	(vz).l,a2
	move.l	LPT_p-vz(a2),a1
	bset	#external_b,emu_block_f-vz(a2)
	clr	mscan_Ypos-vz(a2)
	bra.s	center_mouse
;
;end of:	emu_up
;----------------------------------------------------------------------------
;		emu_down	SUPER subroutine to pull screen down
;
emu_down:
	movem.l	d0-d2/a0-a2,-(sp)
	lea	(vz).l,a2
	move.l	LPT_p-vz(a2),a1
	bset	#external_b,emu_block_f-vz(a2)
	bsr.s	calc_extra
	move	extra_Yrez,mscan_Ypos-vz(a2)
	bra.s	center_mouse
;
;end of:	emu_down
;----------------------------------------------------------------------------
;		emu_center	SUPER subroutine to center screen
;
emu_center:
	movem.l	d0-d2/a0-a2,-(sp)
	lea	(vz).l,a2
	move.l	LPT_p-vz(a2),a1
	bset	#external_b,emu_block_f-vz(a2)
	move	extra_Yrez-vz(a2),d0
	lsr	#1,d0			;Ypos = half of extra_Yrez
	move	d0,mscan_Ypos-vz(a2)	;center screen vertically
	move	extra_Xrez-vz(a2),d0
	lsr	#1,d0			;Xpos = half of extra_Xrez
	and	#-16,d0			;force to 16-pix boundary
	move	d0,mscan_Xpos-vz(a2)	;center screen horizontally
center_mouse:
	move.l	line_a_base_p-vz(a2),a0
	move	mscan_Xrez-vz(a2),d0
	lsr	#1,d0
	add	mscan_Xpos-vz(a2),d0
	swap	d0
	move	mscan_Yrez-vz(a2),d0
	lsr	#1,d0
	add	mscan_Ypos-vz(a2),d0
	move.l	d0,la_gcurx(a0)		;store centred mouse x,y position
	clr	lpt_emu_ypos(a1)	;force filter to physical home
	clr.l	emu_base_p		;demand recalc of screen address
	bclr	#external_b,emu_block_f-vz(a2)
	movem.l	(sp)+,d0-d2/a0-a2
	rts
;
;end of:	emu_center
;----------------------------------------------------------------------------
;		calc_extra	subroutine to calculate extra resolution
;
calc_extra:
	move	sc_Yrez+lpt_SCD(a1),d2	;d2 = visible lace lines
	move	scan_Yscale-vz(a2),d0	;d0 = 2log(emu compression to lace)
	bpl.s	.pos_Yscale
	neg	d0
	lsr	d0,d2			;d2 = visible emu lines
	bra.s	.done_Yscale
;
.pos_Yscale:
	asl	d0,d2			;d2 = visible emu lines
.done_Yscale:
	move	d2,mscan_Yrez-vz(a2)	;mscan_Yrez = sc_Yrez scaled for filter
	move	sc_emu_Yrez+lpt_SCD(a1),d1
	sub	d2,d1			;d1 = extra_Yrez
	bge.s	.use_extra_Yrez
	clr	d1			;use zero, if no extra
.use_extra_Yrez:
	move	d1,extra_Yrez-vz(a2)
;
	move	sc_Xrez+lpt_SCD(a1),d2	;d2 = visible lace pixels/line
	move	scan_Xscale-vz(a2),d0	;d0 = 2log(emu compression to lace)
	bpl.s	.pos_Xscale
	neg	d0
	lsr	d0,d2			;d2 = visible emu lines
	bra.s	.done_Xscale
;
.pos_Xscale:
	asl	d0,d2			;d2 = visible emu pixels/line
.done_Xscale:
	move	d2,mscan_Xrez-vz(a2)	;mscan_Xrez = sc_Xrez scaled for filter
	move	sc_emu_Xrez+lpt_SCD(a1),d0
	sub	d2,d0			;d0 = extra_Xrez
	bge.s	.use_extra_Xrez
	clr	d0			;use zero, if no extra
.use_extra_Xrez:
	move	d0,extra_Xrez-vz(a2)
	rts			;return d0 = extra_Xrez,  d1 = extra_Yrez
;
;end of:	calc_extra
;----------------------------------------------------------------------------
;	Subroutines executed at start & end of v_opnwk function (rez change)
;
;opnwk_fix_1 is called by LaceScan at start of v_opnwk, in supervisor mode
;a0 -> intin == work_in,  work_in[0] == device id  2..4 for rez 0..2
;d1 -> vdipb contrl_p,intin_p,ptsin_p,intout_p,ptsout_p
;all registers are free for unprotected use
;all bios, xbios, and gemdos calls are allowed
opnwk_fix_1:
	bset	#opnwk_b,(emu_block_f).l
	st	opnwk_flag
user_setup:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	d1,a1
	move.l	(a1),a4			;a4 -> contrl,  contrl[12] = device 0(init)/1
	lea	(vz).l,a6		;static variables
	move.l	LPT_p-vz(a6),a5		;LaceScan variables
;
	bset	#user_setup_b,emu_block_f-vz(a6)
;
	bios	Kbshift,?
	move	d0,d1
	move.l	line_a_base_p-vz(a6),a0
	move	la_mouse_bt(a0),d0
	and	#3,d0
	asl	#5,d0
	bclr	#6,d0
	beq.s	.done_rmb
	bset	#4,d0
.done_rmb:			;Here d0 bits 5,4 hold left,right mouse buttons
	and	#$0F,d1			;mask keys to d1 bits 3..0
	or	d1,d0			;combine with mouse buttons to 6 bits
	addq	#1,d0			;increment to make default legal
	move	d0,lpt_emu_type_ix(a5)	;store the index
;
	move	lpt_emu_type_ix(a5),d0
	mulu	#6*2,d0
	lea	emu_type_t-vz(a6),a0
	lea	(a0,d0),a0
	cmp	#320/2,(a0)		;Xrez < 320/2 is not legal
	bhs.s	.legal_ix
	clr	lpt_emu_type_ix(a5)
.legal_ix:
	tst	lpt_emu_type_ix(a5)
	bne.s	.set_tables
	bset	#emu_off_b,emu_block_f-vz(a6)
	bra	.done_tables
;
.set_tables:
	bclr	#emu_off_b,emu_block_f-vz(a6)
	move	(a0)+,d0		;d0 = emulated Xrez
	move	(a0)+,d1		;d1 = emulated Yrez
	move	(a0)+,d2		;d2 = emulated planes
	move	(a0)+,d3		;d3 = emulated rez
	move	(a0)+,d4		;d4 = slot# of emulating rez
	move	(a0)+,d5		;d5 = filter type
;
	lea	lpt_screen_tab(a5),a1
	lea	sc_sizeof*emu_slot(a1),a3	;a3 -> Emulator slot
	move	d0,sc_emu_Xrez(a3)
	move	d1,sc_emu_Yrez(a3)
	move	d2,sc_emu_planes(a3)
	move	d0,d7
	mulu	d2,d7
	lsr.l	#3,d7			;d7 = total bytes per emulated line
	move	d7,sc_emu_bytewid(a3)
	move.b	d3,sc_emu_rez(a3)
	move	d4,work_slot-vz(a6)
	move	d4,lace_slot-vz(a6)
	asl	#sc_log2size,d4
	lea	(a1,d4),a2			;a2 -> physical rez slot
;
	lea	filt_leg_t-vz(a6),a1
	clr	d1
	move.b	sc_emu_rez(a3),d1	;d1 = emulated rez
	cmp	#7,d1
	bhi.s	.bad_filt
	move	sc_rez(a2),d0		;d0 = emulating rez
	cmp	#7,d0
	bhi.s	.bad_filt
	asl	#3,d0
	or	d1,d0
	asl	#2,d0
	move.l	(a1,d0),a1		;a1 -> filter step table of emulation
	move.l	a1,d0
	bmi.s	.bad_filt
	move	d5,d0
	cmp	#filt_ix_lim,d0
	bhs.s	.bad_filt
	add	d0,d0
	move	(a1,d0),d0		;d0 = new filter index
	bra.s	.have_filt
;
.bad_filt:
	clr	d0
.have_filt:
	move	d0,emu_filt_ix-vz(a6)
	asl	#2,d0
	move	d0,ref_filt_ix-vz(a6)
	lea	emu_filt_t-vz(a6),a0
	move.l	(a0,d0),emu_link_p		; set up filter type vector
	move	#$0777,background-vz(a6)
	jsr	fix_colour-vz(a6)
	move	(hw_pal).w,background-vz(a6)
;
	jsr	init_filt-vz(a6)		;initialize filter mode
;
.done_tables:
;
	tst	lpt_emu_type_ix(a5)
	beq.s	.disable_emu
	move.b	#'V',VSCR_cookie-vz(a6)		;Enable VSCR cookie
	move	#emu_slot-norm_slots,lpt_slot_req(a5)
	tst	emu_filt_ix-vz(a6)
	bne.s	.done_setup
	move.b	#'W',VSCR_cookie-vz(a6)		;disable VSCR cookie
	clr	lpt_emu_type_ix(a5)
	bra.s	.done_setup
;
.disable_emu:
	move.b	#'W',VSCR_cookie-vz(a6)		;disable VSCR cookie
	moveq	#-1,d0
	move	d0,lpt_slot_req(a5)
.done_setup:
	bclr	#user_setup_b,emu_block_f-vz(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;
;
;opnwk_fix_2 is called by LaceScan after end of v_opnwk, in supervisor mode
;a0 -> GEM intout,  a1 -> line_a intout,  intout = work_out
;all registers are free for unprotected use
;all bios, xbios, and gemdos calls are allowed
opnwk_fix_2:
	lea	(vz).l,a6		;static variables
	move.l	LPT_p-vz(a6),a5		;LaceScan variables
;
	move	#-1,lpt_slot_req(a5)
;
	jsr	fix_colour-vz(a6)
;
	st	opnwk_done
	addq.b	#1,opnwk_done+1
	sf	opnwk_flag-vz(a6)
	bclr	#opnwk_b,emu_block_f-vz(a6)
	rts
;
;----------------------------------------------------------------------------
;Start of:	fix_filter
;----------------------------------------------------------------------------
fix_filter:
	movem.l	d0-d2/a0-a2/a5-a6,-(sp)
	lea	(vz).l,a6
	move.l	LPT_p-vz(a6),a5
	move	lace_slot-vz(a6),d0
	asl	#sc_log2size,d0
	lea	lpt_screen_tab(a5),a0
	lea	(a0,d0),a0					;a0 -> slot of emulating rez
	lea	lpt_screen_tab+sc_sizeof*emu_slot(a5),a1	;a1 -> Emulator slot
	move.b	sc_emu_rez(a1),d0		;save old sc_emu_rez in d0
	lea	sc_emu_mark(a0),a0		;a0 -> beyond non_emu data
	lea	sc_emu_mark(a1),a1		;a1 -> beyond non_emu data
	move	#sc_emu_mark/4-1,d1		;copy non_emu parameters for filter > 0
	tst	emu_filt_ix-vz(a6)
	bne.s	.parm_loop
	moveq	#sc_sizeof/4-1,d1		;copy all parameters for filter 0
	lea	sc_sizeof-sc_emu_mark(a0),a0	;a0 -> beyond slot data
	lea	sc_sizeof-sc_emu_mark(a1),a1	;a1 -> beyond slot data
.parm_loop:
	move.l	-(a0),-(a1)		;copy slot parameters, but not emu data unless passive
	dbra	d1,.parm_loop		;at exit a0 -> emulating rez slot  a1 -> Emulator slot
	tst	emu_filt_ix-vz(a6)
	beq	.fixed_exit		;skip rest of work for filter 0
	move.b	d0,sc_emu_rez(a1)	;restore old sc_emu_rez into emulator slot
;
	move	ref_filt_ix-vz(a6),d0
	lea	XY_scale_t-vz(a6),a0
	move.l	(a0,d0),scan_Xscale-vz(a6)	;scan_Xscale & scan_Yscale
;
	move	sc_emu_Xrez(a1),d0
	move	scan_Xscale-vz(a6),d2	;d2 = 2log(emu compression to lace)
	bpl.s	.pos_Xscale
	neg	d2
	lsl	d2,d0			;d0 = horizontal lace pixels per emu width
	bra.s	.done_Xscale
;
.pos_Xscale:
	lsr	d2,d0			;d0 = horizontal lace pixels per emu width
.done_Xscale:
	clr.l	d1
	move	sc_Xrez(a1),d1
	cmp	d1,d0
	bge.s	.done_sc_Xrez
	move	d0,sc_Xrez(a1)		;sc_Xrez = min(sc_Xrez,d0) => may adjust
	sub	d0,d1			;d1 = pix_diff
	lsr	#1,d1			;d1 = pix_diff/2 for left_offset
	and	#-16,d1			;d1 forced to match whole 16_pix groups
	move	sc_rez(a1),d0		;d0 = rez
	move.b	.log2_tab(pc,d0),d0	;d0 = log2(pix/byte)
	lsr	d0,d1			;d1 = byte_offs
	add.l	d1,sc_log_offs(a1)	;adjust sc_log_offs to retain centering
.done_sc_Xrez:
	move	sc_emu_Yrez(a1),d0
	move	scan_Yscale-vz(a6),d2	;d2 = 2log(emu compression to lace)
	bpl.s	.pos_Yscale
	neg	d2
	lsl	d2,d0			;d0 = vertical lace pixels per emu height
	bra.s	.done_Yscale
;
.log2_tab:
	dc.b	1,2,3,0,1,2,3,0		;ST_L,ST_M,ST_H,----,TT_M,----,TT_H,TT_L
;
.pos_Yscale:
	lsr	d2,d0			;d0 = vertical lace pixels per emu height
.done_Yscale:
	move	sc_Yrez(a1),d1
	cmp	d1,d0
	bge.s	.done_sc_Yrez		;sc_Yrez = min(sc_Yrez,d0) => may adjust
	move	d0,sc_Yrez(a1)		;adjust sc_Yrez to smaller size
	sub	d0,d1			;d1 = line_diff
	lsr	#1,d1			;d1 = line_diff/2 for top offset
	mulu	sc_bytewidth(a1),d1	;d1 = byte_offset
	add.l	d1,sc_log_offs(a1)	;adjust sc_log_offs to retain centering
.done_sc_Yrez:
;
	tst	opnwk_flag-vz(a6)
	bne.s	.done_refix
	move.l	lpt_refix(a5),a0
	move	#emu_slot,d0
	jsr	(a0)
.done_refix:
;
.fixed_exit:
	movem.l	(sp)+,d0-d2/a0-a2/a5-a6
	rts
;----------------------------------------------------------------------------
;End of:	fix_filter
;----------------------------------------------------------------------------
;Start of:	emu_vbi_XB	The main VBI interrupt routine
;----------------------------------------------------------------------------
	XB_define	emu_vbi_XB,'LEmu'
	tst	ref_filt_ix
	beq.s	.goto_old_vbi
	movem.l	d0/a0,-(sp)		;push d0/a0
	lea	framed_filt_t,a0
	move	ref_filt_ix,d0
	tst.l	(a0,d0)
	beq.s	.done_frame_fix
	not.b	hard_frame_f
	move.b	hard_frame_f,d0
	move.l	LPT_p,a0
	move.l	lpt_fix_pbase(a0),a0
	jsr	(a0)			;call fix_pbase in LaceScan
.done_frame_fix:
	tas	emu_block_f
	bmi.s	.emu_busy
	bne.s	.emu_blocked
	move.l	(_hz_200).w,d0			;d0 = current time tic
	sub.l	emu_work_time,d0		;d0 = elapsed time tics
	cmp.l	emu_work_delay,d0		;sufficient time ?
	blo.s	.emu_blocked
	move.l	(_hz_200).w,emu_work_time	;note emu work time tic
	movem.l	(sp)+,d0/a0
	push_ex	emu_main(pc)		;Push exception frame for emu_main
	XB_gonext_d	emu_vbi_XB
;-------------------------------------
; Above we ensure that VBI chain is exhausted before the main emulator
; work is performed, so that no interrupt conflict will arise.
;-------------------------------------
.emu_blocked:
	bclr	#interrupt_b,emu_block_f
.emu_busy:
	movem.l	(sp)+,d0/a0
.goto_old_vbi:
	XB_gonext_d	emu_vbi_XB
;
;----------------------------------------------------------------------------
; At entry to "emu_main" the stack is exactly as at vbi entry
;
emu_main:
	movem.l	d0-d7/a0-a6,-(sp)
	move	15*4(sp),d0		;fetch pre_vbi SR
	or	#$2000,d0		;mix supervisor bit with pre_vbi SR
	move	d0,SR			;enable future vbi's
	lea	(vz).l,a2		;a2 -> vz for variable refs
	move.l	LPT_p-vz(a2),a3		;a3 -> LaceScan Parameter Table
	move.l	(_hz_200).w,d7		;d7 = current tic
;-------
	move.b	sc_emu_rez+lpt_SCD(a3),d0
	cmp	#1,sc_emu_planes+lpt_SCD(a3)
	bne.s	.done_check		;skip colour check if not emulating mono
	cmp	sc_rez+lpt_SCD(a3),d0
	beq.s	.done_check		;skip colour check if phys rez = emu rez
	move.l	d7,d0			;d0 = current tic
	sub.l	col_check_time-vz(a2),d0	;d0 = elapsed tics
	cmp.l	#67,d0			;1/3 seconds passed ?
	blo.s	.done_check		;make colour check thrice per second
	move.l	d7,col_check_time-vz(a2)
	move	(hw_pal).w,d0		;d0 = palette colour 0
	move	background-vz(a2),d1
	eor	d0,d1
	and	#1,d1			;test for changed LSB of colour 0
	beq.s	.safe_check
	move	d0,background-vz(a2)	;save new value
	jsr	fix_colour-vz(a2)		;make changes as needed
	bra.s	.done_check
;
.safe_check:
	move.l	emu_pal_p-vz(a2),a0
	move.l	(a0)+,(hw_pal).w
	move.l	(a0)+,(hw_pal+4).w
.done_check:
	tst	(flock).w		;test 'flock'  (drive access lock flag)
	bne.s	.filter1		;if locked, use default speed & remember
	move.l	d7,d0			;d0 = current tic
	sub.l	emu_flock_time-vz(a2),d0	;d0 = tics since last 'flock' detection
	cmp.l	#200,d0			;tics >= 200 ?  (1 seconds)
	blo.s	.filter2		;if remembering 'flock', use default speed
	clr.l	d0
	move	emu_spd-vz(a2),d0	;otherwise get preset speed delay
	bra.s	.have_speed_d0
;
.filter1:
	move.l	d7,emu_flock_time	;remember 'flock' time tic
.filter2:
	moveq	#80,d0
.have_speed_d0:
	move.l	d0,emu_work_delay
	tst	scan_mode-vz(a2)
	beq.s	.done_calc		;skip mouse scan in key mode
	add	#$10000/4,mouse_cnt	;scan mouse once per 4 vbi's
	bcc.s	.done_calc
	move.l	line_a_base_p-vz(a2),a0
	move.l	la_gcurx(a0),d0
	cmp.l	scan_gcurxy-vz(a2),d0
	beq.s	.done_calc		;skip mouse scan if gcurx unchanged
.do_calc:
	jsr	calc_disp-vz(a2)	;calc new virtual display area
.done_calc:
	move.l	emu_base_p,d0
	beq.s	.do_calc		;rescan if pointer zeroed
	move.l	d0,a0			;a0 -> top visible line of Emulated Screen
	move.l	LPT_p-vz(a2),a2		;a2 -> LaceScan Parameter Table
	move.l	lpt_physbase_p(a2),a1	;a1 -> LaceScan Screen
	add.l	sc_log_offs+lpt_SCD(a2),a1	;a1 -> top vis-line of lace screen
	move.l	a1,lace_base_p
	move	sc_Yrez+lpt_SCD(a2),d0
	move	d0,lace_Yrez
	subq	#1,d0			;d0 = dbra for phys Yrez
	move.l	emu_link_p(pc),a6
	jsr	(a6)			;call emulation filter subroutine
	movem.l	(sp)+,d0-d7/a0-a6
	bclr	#interrupt_b,emu_block_f
	rte
;----------------------------------------------------------------------------
;End of:	emu_main
;----------------------------------------------------------------------------
emu_link_p:	dc.l	emu_f0
;----------------------------------------------------------------------------
emu_f0:		rts
;----------------------------------------------------------------------------
; here: a0 -> emulated,  a1 -> physical,  a2 -> LPT
;	d0 = dbra for phys Yrez
;-------------------------------------
emu_f1:		;compresses 2 mono lines per resulting medium line
	move	sc_emu_bytewid+lpt_SCD(a2),d2	;d2 = bytes/emu_line
	move	sc_bytewidth+lpt_SCD(a2),d3	;d3 = total bytes/lace_line
	move	d2,d7
	add	d7,d7				;d7 = 2 * bytes/emu_line
;-------
	move	sc_Xrez+lpt_SCD(a2),d4	;d4 = visible pix/lace_line
	move	sc_rez+lpt_SCD(a2),d5	;d5 = physical rez
	move.b	f1_log_tab(pc,d5),d5	;d5 = log2(pix/byte) = log2((pix/long)/4) 
	lsr	d5,d4			;d4 = 4*longs/lace_line = emu_f1_ref byte offset
	lea	emu_F1_ref(pc),a6
	sub	d4,a6			;a6-> loop target for line emu
;-------
emu_F1_loop:
	lea	(a0,d2),a3		;a3 -> odd mono lines
	move.l	a0,a4
	move.l	a1,a5
	jmp	(a6)
;
f1_log_tab:
	dc.b	1,2,3,0,1,2,3,0		;ST_L,ST_M,ST_H,----,TT_M,----,TT_H,TT_L
;
emu_F1_beg:
	rept	128			;max 512 bytes per physical line
	move	(a0)+,(a1)+
	move	(a3)+,(a1)+
	endr
emu_F1_ref:
emu_F1_next:
	lea	(a4,d7),a0
	lea	(a5,d3),a1
	dbra	d0,emu_F1_loop
	rts
;-------------------------------------
; here: a0->emulated  a1->physical  a2->LPT
;	d0 = dbra for phys Yrez
;-------------------------------------
emu_f2:
	move	sc_Xrez+lpt_SCD(a2),d2		;d2 = pix/line
	lsr	#4,d2			;d2 = longs/lace_line (visible)
	move	d2,d3			;d3 = longs/lace_line (visible)
	lsr	#3,d2			;d2 = 8_longs/lace_line (visible)
	move	d2,d4			;d4 = 8_longs/lace_line (visible)
	mulu	#emu_F2_32x_stp,d2	;d2 = byte offset from emu_F2_32x_ref
	lea	emu_F2_32x_ref(pc),a5
	sub	d2,a5			;a5-> loop target for 8_long emu
	lsl	#3,d4			;d4 = DIV(longs/line,8)*8
	sub	d4,d3			;d3 = MOD(longs/line,8)
	mulu	#emu_F2_add_stp,d3	;d3 = byte offset from emu_F2_add_ref
	lea	emu_F2_add_ref(pc),a6
	sub	d3,a6			;a6-> loop target for additional emu
	swap	d0
	move	#32,d0
	swap	d0
emu_F2_loop:
	swap	d0
	movem.l	a0-a1,-(sp)
	jmp	(a5)
;
emu_F2_32x_beg:
	rept	16			;max 512 bytes per physical line
	movem	(a0)+,d2-d7/a3-a4
	movem.l	d2-d7/a3-a4,(a1)
	add	d0,a1			;step a1 past the stored data
	endr
emu_F2_32x_ref:
	jmp	(a6)
emu_F2_32x_stp	=	(emu_F2_32x_ref-emu_F2_32x_beg)/8
;
emu_F2_add_28:
	movem	(a0)+,d2-d7/a3
	movem.l	d2-d7/a3,(a1)
	lea	7*4(a1),a1
	bra.s	emu_F2_add_ref
emu_F2_add_24:
	movem	(a0)+,d2-d7
	movem.l	d2-d7,(a1)
	lea	6*4(a1),a1
	bra.s	emu_F2_add_ref
emu_F2_add_20:
	movem	(a0)+,d2-d6
	movem.l	d2-d6,(a1)
	lea	5*4(a1),a1
	bra.s	emu_F2_add_ref
emu_F2_add_16:
	movem	(a0)+,d2-d5
	movem.l	d2-d5,(a1)
	lea	4*4(a1),a1
	bra.s	emu_F2_add_ref
emu_F2_add_12:
	movem	(a0)+,d2-d4
	movem.l	d2-d4,(a1)
	lea	3*4(a1),a1
	bra.s	emu_F2_add_ref
emu_F2_add_8:
	movem	(a0)+,d2-d3
	movem.l	d2-d3,(a1)
	lea	2*4(a1),a1
	bra.s	emu_F2_add_ref
emu_F2_add_4:
	movem	(a0)+,d2
	movem.l	d2,(a1)
	lea	1*4(a1),a1
	nop
emu_F2_add_0:
emu_F2_add_ref:
emu_F2_add_stp	=	emu_F2_add_0-emu_F2_add_4
emu_F2_next:
	movem.l	(sp)+,a0-a1
	add	sc_emu_bytewid+lpt_SCD(a2),a0
	add	sc_bytewidth+lpt_SCD(a2),a1
	swap	d0
	dbra	d0,emu_F2_loop
	rts
;-------------------------------------
; here: a0->emulated  a1->physical  a2->LPT
;	d0 = dbra for phys Yrez
;-------------------------------------
emu_f3:	;simply copies wide data to lace screen, so it assumes same rez
	move	sc_emu_bytewid+lpt_SCD(a2),d2	;d2 = total bytes/emu_line
	move	sc_bytewidth+lpt_SCD(a2),d3	;d3 = total bytes/lace_line
;
	move	sc_Xrez+lpt_SCD(a2),d4	;d4 = visible pix/lace_line
	move	sc_rez+lpt_SCD(a2),d5	;d5 = physical rez
	move.b	f3_log_tab(pc,d5),d5	;d5 = log2(pix/byte)+1 = log2((pix/long)/2) 
	lsr	d5,d4			;d4 = 2*longs/lace_line = emu_f3_ref byte offset
;NB: the above relies on emu_f3_stp being 2.  Patch here if that changes...
	lea	emu_f3_ref(pc),a6
	sub	d4,a6			;a6 -> loop target for long moves
emu_f3_loop:
	move.l	a0,a4
	move.l	a1,a5
	jmp	(a6)
;
f3_log_tab:
	dc.b	2,3,4,1,2,3,4,1		;ST_L,ST_M,ST_H,----,TT_M,----,TT_H,TT_L
;
emu_f3_rept	=	128	;max 128 longs == 512 bytes per lace_line
;
emu_f3_beg:
	rept	emu_f3_rept
	move.l	(a0)+,(a1)+
	endr
emu_f3_ref:
emu_f3_stp	=	(emu_f3_ref-emu_f3_beg)/emu_f3_rept
emu_f3_next:
	lea	(a4,d2),a0
	lea	(a5,d3),a1
	dbra	d0,emu_f3_loop
	rts
;-------------------------------------
; here: a0->emulated  a1->physical  a2->LPT
;	d0 = dbra for phys Yrez
;-------------------------------------
emu_f4:	;combines colour line pairs to single colour lines
	move	sc_emu_bytewid+lpt_SCD(a2),d2	;d2 = total emu bytes/line
	move	sc_bytewidth+lpt_SCD(a2),d3	;d3 = total lace bytes/line
	move	d2,d7
	add	d7,d7				;d7 = total emu bytes/2_lines
;
	move	sc_Xrez+lpt_SCD(a2),d4	;d4 = visible pix/lace_line
	move	sc_rez+lpt_SCD(a2),d5	;d5 = physical rez
	move.b	f4_log_tab(pc,d5),d5	;d5 = log2(pix/byte)+2 = log2(pix/long)
	lsr	d5,d4			;d4 = visible longs/lace_line
	mulu	#emu_f4_stp,d4		;d4 = byte offset from emu_f4_ref
	lea	emu_f4_ref(pc),a6
	sub	d4,a6			;a6 -> loop target for long moves
emu_f4_loop:
	lea	(a0,d2),a3		;a3 -> odd emu line
	move.l	a0,a4			;a4 = a0  -> even emu line
	move.l	a1,a5			;a5 = a1  -> lace_line
	jmp	(a6)
;
f4_log_tab:
	dc.b	3,4,5,2,3,4,5,2		;ST_L,ST_M,ST_H,----,TT_M,----,TT_H,TT_L
;
emu_f4_rept	=	128	;max 128 longs == 512 bytes per lace_line
;
emu_f4_beg:
	rept	emu_f4_rept
	move.l	(a0)+,d4		;d4 = E.e  long from even emu line
	move.l	(a3)+,d5		;d5 = O.o  long from odd emu line
	move.l	d5,d6			;d6 = O.o
	and.l	d4,d5			;d5 = (E & O).(e & o)
	or.l	d4,d6			;d6 = (E | O).(e | o)
	move	d6,d4			;d4 = E.(e | o)
	swap	d6			;d6 = (e | o).(E | O)
	and	d6,d4			;d4 = E.(E|O)&(e|o)
	swap	d4			;d4 = (E|O)&(e|o).E
	move	d5,d4			;d4 = (E|O)&(e|o).(e&o)
	swap	d5			;d5 = (e & o).(E & O)
	or	d5,d4			;d4 = (E|O)&(e|o).(E&O)|(e&o)
	move.l	d4,(a1)+		;store long in lace_line
	endr
emu_f4_ref:
emu_f4_stp	=	(emu_f4_ref-emu_f4_beg)/emu_f4_rept
emu_f4_next:
	lea	(a4,d7),a0		;a0 -> next even emu_line
	lea	(a5,d3),a1		;a1 -> next lace_line
	dbra	d0,emu_f4_loop
	rts
;-------------------------------------
; here: a0->emulated  a1->physical  a2->LPT
;	d0 = dbra for phys Yrez
;-------------------------------------
emu_f5:	;copies half of 8 planes to a lorez lace screen to simulate TT-low
	move	sc_emu_bytewid+lpt_SCD(a2),d2	;d2 = total emu bytes/line
	move	sc_bytewidth+lpt_SCD(a2),d3	;d3 = total lace bytes/line
;
	move	sc_Xrez+lpt_SCD(a2),d4	;d4 = pix/lace_line
	move	sc_rez+lpt_SCD(a2),d5	;d5 = physical rez
	move.b	f5_log_tab(pc,d5),d5	;d5 = log2(pix/byte)+3 = log2(pix/2_long) 
	lsr	d5,d4			;d4 = 2_longs/lace_line
	mulu	#emu_f5_stp,d4		;d4 = byte offset from emu_f5_32x_ref
	lea	emu_f5_ref(pc),a6
	sub	d4,a6			;a6-> loop target for 2_long emu
emu_f5_loop:
	move.l	a0,a4
	move.l	a1,a5
	jmp	(a6)
;
f5_log_tab:
	dc.b	4,5,6,3,4,5,6,3		;ST_L,ST_M,ST_H,----,TT_M,----,TT_H,TT_L
;
emu_f5_beg:
	rept	64			;max 512 bytes per physical line
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	addq	#8,a0
	endr
emu_f5_ref:
emu_f5_stp	=	(emu_f5_ref-emu_f5_beg)/32
emu_f5_next:
	lea	(a4,d2),a0
	lea	(a5,d3),a1
	dbra	d0,emu_f5_loop
	rts
;-------------------------------------
; here: a0->emulated  a1->physical  a2->LPT
;	d0 = dbra for phys Yrez
;-------------------------------------
emu_f6:	;combines mono line pairs to single mono lines
	move.l	#$55555555,d7		;d7 = mask for even lace lines
;
	move	sc_emu_bytewid+lpt_SCD(a2),d2	;d2 = total emu bytes/line
	move	sc_bytewidth+lpt_SCD(a2),d3	;d3 = total lace bytes/line
	move	d2,a4
	add	a4,a4				;a4 = total emu bytes/2_lines
;
	move	sc_Xrez+lpt_SCD(a2),d4	;d4 = pix/lace_line
	move	sc_rez+lpt_SCD(a2),d5	;d5 = physical rez
	move.b	f6_log_tab(pc,d5),d5	;d5 = log2(pix/byte)+2 = log2(pix/long) 
	lsr	d5,d4			;d4 = longs/lace_line
	mulu	#emu_f6_stp,d4		;d4 = byte offset from emu_f6_ref
	lea	emu_f6_ref(pc),a6
	sub	d4,a6			;a6-> loop target for emu of 2 long => 1 long
emu_f6_loop:
	movem.l	a0-a1,-(sp)		;push a0/a1
	lea	(a0,d2),a3		;a3 -> next odd emu line
	jmp	(a6)
;
f6_log_tab:
	dc.b	3,4,5,2,3,4,5,2		;ST_L,ST_M,ST_H,----,TT_M,----,TT_H,TT_L
;
emu_f6_beg:
	rept	64			;max 256 bytes per physical line
;
	move.l	(a3)+,d5		;d5 = next long from odd emu line
	move.l	(a0)+,d4		;d4 = next long from even emu line
	move.l	d4,d6
	or.l	d5,d6			;d6 = all bits not zero in both pairs
	and.l	d7,d6			;d6 = certified set by mask in d7
	and.l	d5,d4			;d4 = unanimous set bits
	or.l	d6,d4			;d4 = result long after vertical filter
	move.l	d4,(a1)+
;
	endr
emu_f6_ref:
emu_f6_stp	=	(emu_f6_ref-emu_f6_beg)/64
emu_f6_next:
	movem.l	(sp)+,a0-a1		;pull a0/a1
	lea	(a0,a4),a0		;a0 -> next even emu line
	lea	(a1,d3),a1		;a1 -> next lace line
	not.l	d7			;d7 = mask for next lace line
	dbra	d0,emu_f6_loop
	rts
;-------------------------------------
; here: a0->emulated  a1->physical  a2->LPT
;	d0 = dbra for phys Yrez
;-------------------------------------
emu_f7:	;compresses mono lines to half width
	move.l	#$55555555,d3		;d3 = mask for horizontal compression
	move.l	d3,d7			;d7 = mask for vertical dithering
;
	move	sc_emu_bytewid+lpt_SCD(a2),a4	;a4 = total emu bytes/line
	move	sc_bytewidth+lpt_SCD(a2),a5	;a5 = total lace bytes/line
;
	move	sc_Xrez+lpt_SCD(a2),d4	;d4 = pix/lace_line
	move	sc_rez+lpt_SCD(a2),d5	;d5 = physical rez
	move.b	f7_log_tab(pc,d5),d5	;d5 = log2(pix/byte)+1 = log2(pix/word) 
	lsr	d5,d4			;d4 = words/lace_line
	mulu	#emu_f7_stp,d4		;d4 = byte offset from emu_f7_ref
	lea	emu_f7_ref(pc),a6
	sub.l	d4,a6			;a6-> loop target for emu of 2_long => 1 word
	lea	horcom_t,a3		;a3-> horizontal compression tables
emu_f7_loop:
	movem.l	a0-a1,-(sp)		;push a0/a1
	jmp	(a6)
;
f7_log_tab:
	dc.b	2,3,4,1,2,3,4,1		;ST_L,ST_M,ST_H,----,TT_M,----,TT_H,TT_L
;
emu_f7_rept	= 128			;max 256 bytes per physical line
;
emu_f7_beg:
	rept	emu_f7_rept	;max 256 bytes to LaceScan Screen
	move.l	(a0)+,d4	;d4 = next long from emu line
;
	move.l	d4,d5
	move.l	d4,d6
	lsr.l	#1,d4
	and.l	d4,d5		;d5 = combined certain bits at even positions + odd garbage
	or.l	d4,d6		;d6 = combined dubious bits at even positions + odd garbage
	and.l	d3,d5		;d5 = freed of garbage
	and.l	d3,d6		;d6 = freed of garbage
	swap	d6
	move.b	(a3,d6),d4	;d4 = aligned left byte of dubious bits
	ror	#8,d4
	swap	d6
	move.b	(a3,d6),d4	;d4 = aligned word of dubious bits
	and	d7,d4		;d4 = certified word of bits that were dubious
	swap	d5
	move.b	(a3,d5),d6	;d6 = aligned left byte of certain bits
	ror	#8,d6
	swap	d5
	move.b	(a3,d5),d6	;d6 = aligned word of certain bits
	or	d6,d4		;d4 = result word of horizontal filter
;
	move	d4,(a1)+	;store data in lacescan screen
	endr
emu_f7_ref:
emu_f7_stp	=	(emu_f7_ref-emu_f7_beg)/emu_f7_rept
emu_f7_next:
	movem.l	(sp)+,a0-a1		;pull a0/a1
	lea	(a0,a4),a0		;a0 -> next even emu line
	lea	(a1,a5),a1		;a1 -> next lace line
	not.l	d7			;d7 = mask for next lace line
	dbra	d0,emu_f7_loop
	rts
;-------------------------------------
emu_base_p:	dc.l	0
emu_bytewidth:	dc.w	0
emu_step:	dc.w	0
lace_base_p:	dc.l	0
lace_bytewidth:	dc.w	0
lace_step:	dc.w	0
lace_Yrez:	dc.w	0
;-------------------------------------
; here: a0->emulated  a1->physical  a2->LPT
;	d0 = dbra for phys Yrez
;-------------------------------------
emu_f8:	;combines mono line pairs to single mono lines with horizontal compression
	move.l	#$55555555,d3		;d3 = mask for horizontal compression
	move.l	d3,d7			;d7 = mask for vertical compression
;
	move	sc_emu_bytewid+lpt_SCD(a2),d2	;d2 = total emu bytes/line
	move	d2,a4
	add	a4,a4				;a4 = total emu bytes/2_lines
	move	sc_bytewidth+lpt_SCD(a2),a5	;a5 = total lace bytes/line
;
	move	sc_Xrez+lpt_SCD(a2),d4	;d4 = pix/lace_line
	move	sc_rez+lpt_SCD(a2),d5	;d5 = physical rez
	move.b	f8_log_tab(pc,d5),d5	;d5 = log2(pix/byte)+1 = log2(pix/word) 
	lsr	d5,d4			;d4 = words/lace_line
	mulu	#emu_f8_stp,d4		;d4 = byte offset from emu_f8_ref
	lea	emu_f8_ref(pc),a6
	sub.l	d4,a6			;a6-> loop target for emu of 2_long => 1 word
	lea	horcom_t,a3		;a3-> horizontal compression tables
emu_f8_loop:
	movem.l	a0-a1,-(sp)		;push a0/a1
	jmp	(a6)
;
f8_log_tab:
	dc.b	2,3,4,1,2,3,4,1		;ST_L,ST_M,ST_H,----,TT_M,----,TT_H,TT_L
;
emu_f8_rept	= 128			;max 256 bytes per physical line
;
emu_f8_beg:
	rept	emu_f8_rept		;max 256 bytes to LaceScan Screen
	move.l	(a0,d2),d5		;d5 = next long from odd emu line
	move.l	(a0)+,d4		;d4 = next long from even emu line
;
	move.l	d4,d6
	or.l	d5,d6			;d6 = all bits not zero in both pairs
	and.l	d7,d6			;d6 = certified set by mask in d7
	and.l	d5,d4			;d4 = unanimous set bits
	or.l	d6,d4			;d4 = result long after vertical filter
;
	move.l	d4,d5
	move.l	d4,d6
	lsr.l	#1,d4
	and.l	d4,d5		;d5 = combined certain bits at even positions + odd garbage
	or.l	d4,d6		;d6 = combined dubious bits at even positions + odd garbage
	and.l	d3,d5		;d5 = freed of garbage
	and.l	d3,d6		;d6 = freed of garbage
	swap	d6
	move.b	(a3,d6),d4	;d4 = aligned left byte of dubious bits
	ror	#8,d4
	swap	d6
	move.b	(a3,d6),d4	;d4 = aligned word of dubious bits
	and	d7,d4		;d4 = certified word of bits that were dubious
	swap	d5
	move.b	(a3,d5),d6	;d6 = aligned left byte of certain bits
	ror	#8,d6
	swap	d5
	move.b	(a3,d5),d6	;d6 = aligned word of certain bits
	or	d6,d4		;d4 = result word of horizontal filter
;
	move	d4,(a1)+	;store data in lacescan screen
	endr
emu_f8_ref:
emu_f8_stp	=	(emu_f8_ref-emu_f8_beg)/emu_f8_rept
emu_f8_next:
	movem.l	(sp)+,a0-a1		;pull a0/a1
	lea	(a0,a4),a0		;a0 -> next even emu line
	lea	(a1,a5),a1		;a1 -> next lace line
	not.l	d7			;d7 = mask for next lace line
	dbra	d0,emu_f8_loop
	rts
;-------------------------------------
; here: a0->emulated  a1->physical  a2->LPT
;	d0 = dbra for phys Yrez
;-------------------------------------
emu_f9:	;combines lorez lines to midrez lines
	move	sc_emu_bytewid+lpt_SCD(a2),a4	;a4 = total emu bytes/line
	move	sc_bytewidth+lpt_SCD(a2),a5	;a5 = total lace bytes/line
;
	move	sc_Xrez+lpt_SCD(a2),d4	;d4 = pix/lace_line
	move	sc_rez+lpt_SCD(a2),d5	;d5 = physical rez
	move.b	f9_log_tab(pc,d5),d5	;d5 = log2(pix/byte)+2 = log2(pix/long)
	lsr	d5,d4			;d4 = longs/lace_line
	mulu	#emu_f9_stp,d4		;d4 = byte offset from emu_f9_ref
	lea	emu_f9_ref(pc),a6
	sub.l	d4,a6			;a6-> loop target for emu of 2_long => 1 long
	lea	horcom_t,a3		;a3-> horizontal compression tables
emu_f9_loop:
	movem.l	a0-a1,-(sp)		;push a0/a1
	jmp	(a6)
;
f9_log_tab:
	dc.b	3,4,5,2,3,4,5,2		;ST_L,ST_M,ST_H,----,TT_M,----,TT_H,TT_L
;
emu_f9_rept	= 128			;max 512 bytes per physical line
;
emu_f9_beg:
	rept	emu_f9_rept		;max 256 bytes to LaceScan Screen
	movem	(a0)+,d2-d5		;get four planes of 16 pix
	move	d2,d6
	and	d5,d2
	and	d4,d2
	and	d3,d2			;d2 = AND of all 4 bitplanes
	or	d6,d3
	or	d5,d3
	or	d4,d3			;d3 = OR of all 4 bitplanes
	move	d2,(a1)+
	move	d3,(a1)+
	endr
emu_f9_ref:
emu_f9_stp	=	(emu_f9_ref-emu_f9_beg)/emu_f9_rept
emu_f9_next:
	movem.l	(sp)+,a0-a1		;pull a0/a1
	lea	(a0,a4),a0		;a0 -> next emu line
	lea	(a1,a5),a1		;a1 -> next lace line
	dbra	d0,emu_f9_loop
	rts
;-------------------------------------
; here: a0->emulated  a1->physical  a2->LPT
;	d0 = dbra for phys Yrez
;-------------------------------------
emu_f10:	;splits low rez lines to mono lines
	move	sc_emu_bytewid+lpt_SCD(a2),d7
	move	d7,emu_bytewidth
	move	d7,emu_step
;
	addq	#2,d0			;adjust from dbra & prep to round up if odd
	lsr	#1,d0			;halve speed count (2 lace lines per loop)
	subq	#1,d0			;adjust for dbra
;
	move	sc_bytewidth+lpt_SCD(a2),d7	;d7 = total lace bytes/line
	move	d7,lace_bytewidth
	add	d7,d7				;d7 = step size for two lace lines
	move	d7,lace_step
;
	move	sc_Xrez+lpt_SCD(a2),d4	;d4 = visible pix/lace_line
	move	sc_rez+lpt_SCD(a2),d5	;d5 = physical rez
	move.b	f10_log_tab(pc,d5),d5	;d5 = log2(pix/byte)+2 = log2(pix/long)
	lsr	d5,d4			;d4 = longs/lace_line
	mulu	#emu_f10_stp,d4		;d4 = byte offset from emu_f10_ref
	lea	emu_f10_ref(pc),a6
	sub.l	d4,a6			;a6-> loop target for emu of 2_long => 2 long
	move.l	a6,d7
	lea	(horexp_t).l,a3		;a3 -> a_b_c_d_
	lea	$100(a3),a4		;a4 -> e_f_g_h_
	lea	$200(a3),a5		;a5 -> _a_b_c_d
	lea	$300(a3),a6		;a6 -> _e_f_g_h
	clr	d2
	clr	d3
	clr	d4
	clr	d5
emu_f10_loop:
	movem.l	a0/a1,-(sp)		;push a0/a1
	move.l	a1,a2			;a2 -> next even lace line
	add	lace_bytewidth(pc),a2	;a2 -> next odd lace line
	clr	d6
	move.l	d7,-(sp)		;\/ simulate
	rts				;/\ jmp (d7)
;
f10_log_tab:
	dc.b	3,4,5,2,3,4,5,2		;ST_L,ST_M,ST_H,----,TT_M,----,TT_H,TT_L
;
emu_f10_rept	= 64			;max 256 bytes = 64 longs
;
emu_f10_beg:
	rept	emu_f10_rept		;max 256 bytes per physical line
	move.b	(a0)+,d2		;d2 = abcdefgh plane 0
	move.b	(a0)+,d3		;d3 = ijklmnop plane 0
	move.b	(a0)+,d4		;d4 = abcdefgh plane 1
	move.b	(a0)+,d5		;d5 = ijklmnop plane 1
;
	move.b	(a3,d2),d6		;d6 = a_b_c_d_ plane 0
	or.b	(a5,d4),d6		;d6 = aabbccdd planes 0,1
	move.b	d6,(a1)+		;(even line)+ = aabbccdd planes 0,1
	move.b	(a4,d2),d6		;d6 = e_f_g_h_ plane 0
	or.b	(a6,d4),d6		;d6 = eeffgghh planes 0,1
	move.b	d6,(a1)+		;(even line)+ = eeffgghh planes 0,1
	move.b	(a3,d3),d6		;d6 = i_j_k_l_ plane 0
	or.b	(a5,d5),d6		;d6 = iijjkkll planes 0,1
	move.b	d6,(a1)+		;(even line)+ = iijjkkll planes 0,1
	move.b	(a4,d3),d6		;d6 = m_n_o_p_ plane 0
	or.b	(a6,d5),d6		;d6 = mmnnoopp planes 0,1
	move.b	d6,(a1)+		;(even line)+ = mmnnoopp planes 0,1
;
	move.b	(a0)+,d2		;d2 = abcdefgh plane 2
	move.b	(a0)+,d3		;d3 = ijklmnop plane 2
	move.b	(a0)+,d4		;d4 = abcdefgh plane 3
	move.b	(a0)+,d5		;d5 = ijklmnop plane 3
;
	move.b	(a3,d2),d6		;d6 = a_b_c_d_ plane 2
	or.b	(a5,d4),d6		;d6 = aabbccdd planes 2,3
	move.b	d6,(a2)+		;(odd line)+ = aabbccdd planes 2,3
	move.b	(a4,d2),d6		;d6 = e_f_g_h_ plane 2
	or.b	(a6,d4),d6		;d6 = eeffgghh planes 2,3
	move.b	d6,(a2)+		;(odd line)+ = eeffgghh planes 2,3
	move.b	(a3,d3),d6		;d6 = i_j_k_l_ plane 2
	or.b	(a5,d5),d6		;d6 = iijjkkll planes 2,3
	move.b	d6,(a2)+		;(odd line)+ = iijjkkll planes 2,3
	move.b	(a4,d3),d6		;d6 = m_n_o_p_ plane 2
	or.b	(a6,d5),d6		;d6 = mmnnoopp planes 2,3
	move.b	d6,(a2)+		;(odd line)+ = mmnnoopp planes 2,3
;
	endr
emu_f10_ref:
emu_f10_stp	=	(emu_f10_ref-emu_f10_beg)/emu_f10_rept
emu_f10_next:
	movem.l	(sp)+,a0/a1		;pull a0/a1
	add	emu_step(pc),a0		;a0 -> next emu line
	add	lace_step(pc),a1	;a1 -> next even lace line
	dbra	d0,emu_f10_loop
	rts
;-------------------------------------
; here: a0->emulated  a1->physical  a2->LPT
;	d0 = dbra for phys Yrez
;-------------------------------------
emu_f11:	;translates low rez lines to mono lines
	move.l	#f11_mask_t_0,f11_mask_t_p
	bra.s	emu_f11_f13
;
emu_f12:	;translates low rez lines to mono lines
	move.l	#f11_mask_t_1,f11_mask_t_p
	bra.s	emu_f11_f13
;
emu_f13:	;translates low rez lines to mono lines
	move.l	#f11_mask_t_2,f11_mask_t_p
emu_f11_f13:
;
	move	sc_emu_bytewid+lpt_SCD(a2),d7
	move	d7,emu_bytewidth
	move	d7,emu_step
;
	move	sc_bytewidth+lpt_SCD(a2),d7	;d7 = total lace bytes/line
	move	d7,lace_bytewidth
	move	d7,lace_step
;
	move	sc_Xrez+lpt_SCD(a2),d4	;d4 = visible pix/lace_line
	move	sc_rez+lpt_SCD(a2),d5	;d5 = physical rez
	move.b	f11_log_tab(pc,d5),d5	;d5 = log2(pix/byte)+2 = log2(pix/long)
	lsr	d5,d4			;d4 = longs/lace_line
	mulu	#emu_f11_stp,d4		;d4 = byte offset from emu_f11_ref
	lea	emu_f11_ref(pc),a6
	sub.l	d4,a6			;a6-> loop target for emu of 2_long => 1 word
	move	lpt_emu_ypos(a2),d7	;init unscaled mask index
	and	#7,d7			;limit unscaled mask index for 8 rows
	lsl	#3,d7			;scale mask index for 2 longs
	move.l	f11_mask_t_p(pc),a3
emu_f11_loop:
	movem.l	d7/a0/a1,-(sp)		;push a0/a1
	movem.l	(a3,d7),d6/d7		;load current bitplane masks
	jmp	(a6)
;
f11_log_tab:
	dc.b	3,4,5,2,3,4,5,2		;ST_L,ST_M,ST_H,----,TT_M,----,TT_H,TT_L
;
emu_f11_rept	= 64			;max 256 bytes = 64 longs
;
emu_f11_beg:
	rept	emu_f11_rept		;max 256 bytes to LaceScan Screen
;
	movem.l	(a0)+,d2-d5	;d2-d5 = plane 0-3 of 32 pix
	and.l	d6,d2		;mask planes 0,1 of group 0
	and.l	d7,d3		;mask planes 2,3 of group 0
	or.l	d3,d2		;d2 = group 0: pl0_or_pl2,pl1_or_pl3
	move	d2,d3
	swap	d2
	or	d3,d2		;d2 = x,monogroup_0
	swap	d2		;d2 = monogroup_0,x
	and.l	d6,d4		;mask planes 0,1 of group 1
	and.l	d7,d5		;mask planes 2,3 of group 1
	or.l	d5,d4		;d4 = group 1: pl0_or_pl2,pl1_or_pl3
	move	d4,d2
	swap	d4
	or	d4,d2		;d2 = monogroup_0,monogroup_1
	move.l	d2,(a1)+	;store 32 pix
;
	endr
emu_f11_ref:
emu_f11_stp	=	(emu_f11_ref-emu_f11_beg)/emu_f11_rept
emu_f11_next:
	movem.l	(sp)+,d7/a0/a1		;pull d7/a0/a1
	add	emu_step(pc),a0		;a0 -> next emu line
	add	lace_step(pc),a1	;a1 -> next even lace line
	addq	#8,d7			;increment mask index by 2 longs
	and	#$38,d7			;limit mask index for 8 rows
	dbra	d0,emu_f11_loop
	rts
;-------------------------------------
; here: a0->emulated  a1->physical  a2->LPT
;	d0 = dbra for phys Yrez
;-------------------------------------
emu_f14:	;splits medium lines to mono lines
	move	sc_emu_bytewid+lpt_SCD(a2),d6
	move	sc_bytewidth+lpt_SCD(a2),d7
	move	d7,lace_bytewidth
	add	d7,d7				;d7 = step size for two lace lines
;
	addq	#2,d0			;adjust from dbra & prep to round up if odd
	lsr	#1,d0			;halve speed count (2 lace lines per loop)
	subq	#1,d0			;adjust for dbra
;
	move	sc_Xrez+lpt_SCD(a2),d4	;d4 = visible pix/lace_line
	move	sc_rez+lpt_SCD(a2),d5	;d5 = physical rez
	move.b	f14_log_tab(pc,d5),d5	;d5 = log2(pix/byte)+2 = log2(pix/long)
	lsr	d5,d4			;d4 = longs/lace_line
	mulu	#emu_f14_stp,d4		;d4 = byte offset from emu_f14_ref
	lea	emu_f14_ref(pc),a6
	sub.l	d4,a6			;a6-> loop target for emu of 2_long => 2 long
emu_f14_loop:
	movem.l	a0/a1,-(sp)		;push a0/a1
	move.l	a1,a3			;a3 -> next even lace line
	add	lace_bytewidth(pc),a3	;a3 -> next odd lace line
	jmp	(a6)
;
f14_log_tab:
	dc.b	3,4,5,2,3,4,5,2		;ST_L,ST_M,ST_H,----,TT_M,----,TT_H,TT_L
;
emu_f14_rept	= 64			;max 256 bytes = 64 longs
;
emu_f14_beg:
	rept	emu_f14_rept		;max 256 bytes per physical line
	movem	(a0)+,d2-d5		;get two planes of 32 pix
	move	d2,(a1)+
	move	d3,(a3)+
	move	d4,(a1)+
	move	d5,(a3)+
	endr
emu_f14_ref:
emu_f14_stp	=	(emu_f14_ref-emu_f14_beg)/emu_f14_rept
emu_f14_next:
	movem.l	(sp)+,a0/a1		;pull a0/a1
	add	d6,a0			;a0 -> next emu line
	add	d7,a1			;a1 -> next even lace line
	dbra	d0,emu_f14_loop
	rts
;-------------------------------------
; here: a0->emulated  a1->physical  a2->LPT
;	d0 = dbra for phys Yrez
;-------------------------------------
emu_f15:	;translates mid rez lines to mono lines
	move.l	#f15_mask_t_0,f15_mask_t_p
	bra.s	emu_f15_f17
;
emu_f16:	;translates mid rez lines to mono lines
	move.l	#f15_mask_t_1,f15_mask_t_p
	bra.s	emu_f15_f17
;
emu_f17:	;translates mid rez lines to mono lines
	move.l	#f15_mask_t_2,f15_mask_t_p
emu_f15_f17:
	move	sc_emu_bytewid+lpt_SCD(a2),d7
	move	d7,emu_bytewidth
	move	d7,emu_step
;
	move	sc_bytewidth+lpt_SCD(a2),d7	;d7 = total lace bytes/line
	move	d7,lace_bytewidth
	move	d7,lace_step
;
	move	sc_Xrez+lpt_SCD(a2),d4	;d4 = visible pix/lace_line
	move	sc_rez+lpt_SCD(a2),d5	;d5 = log2(pix/byte)-1
	move.b	f15_log_tab(pc,d5),d5	;d5 = log2(pix/byte)+2 = log2(pix/long)
	lsr	d5,d4			;d4 = longs/lace_line
	mulu	#emu_f15_stp,d4		;d4 = byte offset from emu_f15_ref
	lea	emu_f15_ref(pc),a6
	sub.l	d4,a6			;a6-> loop target for emu of 2_long => 1 word
	move	lpt_emu_ypos(a2),d7	;init unscaled mask index
	and	#3,d7			;limit unscaled mask index for 4 rows
	lsl	#2,d7			;scale mask index for 2 words
	move.l	f15_mask_t_p(pc),a3
emu_f15_loop:
	movem.l	d7/a0/a1,-(sp)		;push a0/a1
	movem	(a3,d7),d6/d7		;load current bitplane masks
	jmp	(a6)
;
f15_log_tab:
	dc.b	3,4,5,2,3,4,5,2		;ST_L,ST_M,ST_H,----,TT_M,----,TT_H,TT_L
;
emu_f15_rept	= 64			;max 256 bytes = 64 longs
;
emu_f15_beg:
	rept	emu_f15_rept		;max 256 bytes per physical line
;
	movem	(a0)+,d2-d5	;d2-d5 = plane 0-1 of 32 pix
	and	d6,d2		;mask plane 0 of group 0
	and	d7,d3		;mask plane 1 of group 0
	or	d3,d2		;d2 = x,monogroup_0
	swap	d2		;d2 = monogroup_0,x
	and	d6,d4		;mask plane 0 of group 1
	and	d7,d5		;mask plane 1 of group 1
	or	d5,d4		;d4 = y,monogroup_1
	move	d4,d2		;d2 = monogroup_0,monogroup_1
	move.l	d2,(a1)+	;store 32 pix
;
	endr
emu_f15_ref:
emu_f15_stp	=	(emu_f15_ref-emu_f15_beg)/emu_f15_rept
emu_f15_next:
	movem.l	(sp)+,d7/a0/a1		;pull d7/a0/a1
	add	emu_step(pc),a0		;a0 -> next emu line
	add	lace_step(pc),a1	;a1 -> next even lace line
	addq	#4,d7			;increment mask index by 2 words
	and	#$0C,d7			;limit mask index for 4 rows
	dbra	d0,emu_f15_loop
	rts
;-------------------------------------
; here: a0->emulated  a1->physical  a2->LPT
;	d0 = dbra for phys Yrez
;-------------------------------------
emu_f18:	;interlaces pixel column pairs to halve physical width
	lea	horcom_even_r,a3
	move.l	olock_base_p,a1
	not.b	soft_frame_f
	bpl.s	.done_frame_prep
	lea	horcom_odd_r,a3
	move.l	extra_base_p,a1
.done_frame_prep:
	add.l	sc_log_offs+lpt_SCD(a2),a1	;a1 -> top vis-line of lace screen
;
	move	sc_emu_bytewid+lpt_SCD(a2),d7
	move	d7,emu_step
;
	move	sc_bytewidth+lpt_SCD(a2),d7	;d7 = total lace bytes/line
	move	d7,lace_step
;
	move	sc_Xrez+lpt_SCD(a2),d4	;d4 = visible pix/lace_line
	lsr	#4,d4			;d4 = groups of 16 physical pixels
	move	sc_rez+lpt_SCD(a2),d5	;d5 = physical rez
	add	d5,d5
	move	f18_rez_t(pc,d5),d5
	jmp	f18_rez_t(pc,d5)
;
f18_rez_t:
.tr:	dc.w	f18_4p-.tr,f18_2p-.tr,f18_1p-.tr,f18_8p-.tr
	dc.w	f18_4p-.tr,f18_2p-.tr,f18_1p-.tr,f18_8p-.tr
;------------------------------------
f18_1p:
	mulu	#emu_f18_1p_stp,d4	;d4 = byte offset from emu_f18_1p_ref
	lea	emu_f18_1p_ref(pc),a6
	sub.l	d4,a6			;a6-> loop target for emu of 2_long => 1 word
	movem.l	a0/a1,-(sp)		;push a0/a1
	jmp	(a6)
;
emu_f18_1p_rept	= 128			;max 256 bytes = 128 16_pixel groups
;
emu_f18_1p_beg:
	REPT	emu_f18_1p_rept		;produces one 16_pixel group per repetition
	move	(a0)+,d2
	move.b	(a3,d2),(a1)+
	move	(a0)+,d2
	move.b	(a3,d2),(a1)+
	ENDR
emu_f18_1p_ref:
emu_f18_1p_stp	=	(emu_f18_1p_ref-emu_f18_1p_beg)/emu_f18_1p_rept
	bra	emu_f18_next
;------------------------------------
f18_2p:
	mulu	#emu_f18_2p_stp,d4	;d4 = byte offset from emu_f18_2p_ref
	lea	emu_f18_2p_ref(pc),a6
	sub.l	d4,a6			;a6-> loop target for emu of 2_long => 1 word
	movem.l	a0/a1,-(sp)		;push a0/a1
	jmp	(a6)
;
emu_f18_2p_rept	= 128			;max 512 bytes = 128 16_pixel groups
;
emu_f18_2p_beg:
	REPT	emu_f18_2p_rept		;produces one 16_pixel group per repetition
	movem	(a0)+,d2-d5
	move.b	(a3,d2),(a1)+
	move.b	(a3,d4),(a1)+
	move.b	(a3,d3),(a1)+
	move.b	(a3,d5),(a1)+
	ENDR
emu_f18_2p_ref:
emu_f18_2p_stp	=	(emu_f18_2p_ref-emu_f18_2p_beg)/emu_f18_2p_rept
	bra	emu_f18_next
;------------------------------------
f18_4p:
	mulu	#emu_f18_4p_stp,d4	;d4 = byte offset from emu_f18_4p_ref
	lea	emu_f18_4p_ref(pc),a6
	sub.l	d4,a6			;a6-> loop target for emu of 2_long => 1 word
	movem.l	a0/a1,-(sp)		;push a0/a1
	jmp	(a6)
;
emu_f18_4p_rept	= 64			;max 512 bytes = 64 16_pixel groups
;
emu_f18_4p_beg:
	REPT	emu_f18_4p_rept		;produces one 16_pixel group per repetition
	movem	(a0)+,d2-d7/a4-a5
	move.b	(a3,d2),(a1)+
	move.b	(a3,d6),(a1)+
	move.b	(a3,d3),(a1)+
	move.b	(a3,d7),(a1)+
	move.b	(a3,d4),(a1)+
	move.b	(a3,a4),(a1)+
	move.b	(a3,d5),(a1)+
	move.b	(a3,a5),(a1)+
	ENDR
emu_f18_4p_ref:
emu_f18_4p_stp	=	(emu_f18_4p_ref-emu_f18_4p_beg)/emu_f18_4p_rept
	bra	emu_f18_next
;------------------------------------
f18_8p:
	mulu	#emu_f18_8p_stp,d4	;d4 = byte offset from emu_f18_8p_ref
	lea	emu_f18_8p_ref(pc),a6
	sub.l	d4,a6			;a6-> loop target for emu of 2_long => 1 word
emu_f18_loop:
	movem.l	a0/a1,-(sp)		;push a0/a1
	jmp	(a6)
;
emu_f18_8p_rept	= 32			;max 512 bytes = 32 16_pixel groups
;
emu_f18_8p_beg:
	REPT	emu_f18_8p_rept		;produces one 16_pixel group per repetition
	movem	(a0)+,d2-d7/a4-a5	;get entire 1st group of 8 words
	move.b	(a3,d2),(a1)+
	move	(a0)+,d2		;get 1st word of 2nd group
	move.b	(a3,d2),(a1)+
	move.b	(a3,d3),(a1)+
	move	(a0)+,d3		;get 2nd word of 2nd group
	move.b	(a3,d3),(a1)+
	move.b	(a3,d4),(a1)+
	move	(a0)+,d4		;get 3rd word of 2nd group
	move.b	(a3,d4),(a1)+
	move.b	(a3,d5),(a1)+
	move	(a0)+,d5		;get 4th word of 2nd group
	move.b	(a3,d5),(a1)+
	movem	(a0)+,d2-d5		;get 2nd half of 2nd group (4 words)
	move.b	(a3,d6),(a1)+
	move.b	(a3,d2),(a1)+
	move.b	(a3,d7),(a1)+
	move.b	(a3,d3),(a1)+
	move.b	(a3,a4),(a1)+
	move.b	(a3,d4),(a1)+
	move.b	(a3,a5),(a1)+
	move.b	(a3,d5),(a1)+
	ENDR
emu_f18_8p_ref:
emu_f18_8p_stp	=	(emu_f18_8p_ref-emu_f18_8p_beg)/emu_f18_8p_rept
emu_f18_next:
	movem.l	(sp)+,a0/a1		;pull a0/a1
	add	emu_step(pc),a0		;a0 -> next emu line
	add	lace_step(pc),a1	;a1 -> next even lace line
	dbra	d0,emu_f18_loop	;loop back for all lines
	rts
;-------------------------------------
; here: a0->emulated  a1->physical  a2->LPT
;	d0 = dbra for phys Yrez
;-------------------------------------
emu_f19:	;double lines, to adjust proportions (mainly for TT low)
	move	sc_emu_bytewid+lpt_SCD(a2),emu_step
;
	move	sc_bytewidth+lpt_SCD(a2),d7	;d7 = total lace bytes/line
	move	d7,lace_bytewidth
	add	d7,d7				;d7 = step size for two lace lines
	move	d7,lace_step
;
	addq	#2,d0			;adjust from dbra & prep to round up if odd
	lsr	#1,d0			;halve speed count (2 lace lines per loop)
	subq	#1,d0			;adjust for dbra
;
	move	sc_Xrez+lpt_SCD(a2),d4	;d4 = visible pix/lace_line
	lsr	#4,d4			;d4 = groups of 16 physical pixels
	move	sc_rez+lpt_SCD(a2),d5	;d5 = physical rez
	add	d5,d5
	move	f19_rez_t(pc,d5),d5
	jmp	f19_rez_t(pc,d5)
;
f19_rez_t:
.tr:	dc.w	f19_4p-.tr,f19_2p-.tr,f19_1p-.tr,f19_8p-.tr
	dc.w	f19_4p-.tr,f19_2p-.tr,f19_1p-.tr,f19_8p-.tr
;------------------------------------
f19_1p:
	mulu	#emu_f19_1p_stp,d4	;d4 = byte offset from emu_f19_1p_ref
	lea	emu_f19_1p_ref(pc),a6
	sub.l	d4,a6			;a6-> loop target for emu of 2_long => 1 word
	bra	emu_f19_loop
;
emu_f19_1p_rept	= 128			;max 256 bytes = 128 16_pixel groups
;
emu_f19_1p_beg:
	REPT	emu_f19_1p_rept		;copies one 16_pixel group per repetition
	move	(a0)+,d2
	move	d2,(a1)+
	move	d2,(a3)+
	ENDR
emu_f19_1p_ref:
emu_f19_1p_stp	=	(emu_f19_1p_ref-emu_f19_1p_beg)/emu_f19_1p_rept
	bra	emu_f19_next
;------------------------------------
f19_2p:
	mulu	#emu_f19_2p_stp,d4	;d4 = byte offset from emu_f19_2p_ref
	lea	emu_f19_2p_ref(pc),a6
	sub.l	d4,a6			;a6-> loop target for emu of 2_long => 1 word
	bra	emu_f19_loop
;
emu_f19_2p_rept	= 128			;max 512 bytes = 128 16_pixel groups
;
emu_f19_2p_beg:
	REPT	emu_f19_2p_rept		;copies one 16_pixel group per repetition
	move.l	(a0)+,d2
	move.l	d2,(a1)+
	move.l	d2,(a3)+
	ENDR
emu_f19_2p_ref:
emu_f19_2p_stp	=	(emu_f19_2p_ref-emu_f19_2p_beg)/emu_f19_2p_rept
	bra	emu_f19_next
;------------------------------------
f19_4p:
	mulu	#emu_f19_4p_stp,d4	;d4 = byte offset from emu_f19_4p_ref
	lea	emu_f19_4p_ref(pc),a6
	sub.l	d4,a6			;a6-> loop target for emu of 2_long => 1 word
	movem.l	a0/a1,-(sp)		;push a0/a1
	jmp	(a6)
;
emu_f19_4p_rept	= 64			;max 512 bytes = 64 16_pixel groups
;
emu_f19_4p_beg:
	REPT	emu_f19_4p_rept		;copies one 16_pixel group per repetition
	move.l	(a0)+,d2
	move.l	d2,(a1)+
	move.l	d2,(a3)+
	move.l	(a0)+,d2
	move.l	d2,(a1)+
	move.l	d2,(a3)+
	ENDR
emu_f19_4p_ref:
emu_f19_4p_stp	=	(emu_f19_4p_ref-emu_f19_4p_beg)/emu_f19_4p_rept
	bra	emu_f19_next
;------------------------------------
f19_8p:
	mulu	#emu_f19_8p_stp,d4	;d4 = byte offset from emu_f19_8p_ref
	lea	emu_f19_8p_ref(pc),a6
	sub.l	d4,a6			;a6-> loop target for emu of 2_long => 1 word
emu_f19_loop:
	movem.l	a0/a1,-(sp)		;push a0/a1
	move.l	a1,a3			;a3 -> next even lace line
	add	lace_bytewidth,a3	;a3 -> next odd lace line
	jmp	(a6)
;
emu_f19_8p_rept	= 32			;max 512 bytes = 32 16_pixel groups
;
emu_f19_8p_beg:
	REPT	emu_f19_8p_rept		;copies one 16_pixel group per repetition
	movem.l	(a0)+,d2-d5
	move.l	d2,(a1)+
	move.l	d2,(a3)+
	move.l	d3,(a1)+
	move.l	d3,(a3)+
	move.l	d4,(a1)+
	move.l	d4,(a3)+
	move.l	d5,(a1)+
	move.l	d5,(a3)+
	ENDR
emu_f19_8p_ref:
emu_f19_8p_stp	=	(emu_f19_8p_ref-emu_f19_8p_beg)/emu_f19_8p_rept
emu_f19_next:
	movem.l	(sp)+,a0/a1		;pull a0/a1
	add	emu_step,a0		;a0 -> next emu line
	add	lace_step,a1		;a1 -> next even lace line
	dbra	d0,emu_f19_loop
	rts
;-------------------------------------
; here: a0->emulated  a1->physical  a2->LPT
;	d0 = dbra for phys Yrez
;-------------------------------------
emu_f20:	;interlaces pixel column pairs to halve physical width
	move.l	olock_base_p,a1
	not.b	soft_frame_f
	bpl.s	.done_frame_prep
	add	sc_emu_bytewid+lpt_SCD(a2),a0	;offset for odd emu lines
	move.l	extra_base_p,a1
.done_frame_prep:
	add.l	sc_log_offs+lpt_SCD(a2),a1	;a1 -> top vis-line of lace screen
;
	move	sc_emu_bytewid+lpt_SCD(a2),d7	;d7 = total bytes/emu_line
	add	d7,d7				;d7 = 2*(bytes/emu_line)
	move	d7,emu_step			;set emu step for 2 lines
;
	move	sc_bytewidth+lpt_SCD(a2),d7	;d7 = total bytes/lace_line
	move	d7,lace_step
;
	move	sc_Xrez+lpt_SCD(a2),d4	;d4 = visible pix/lace_line
	lsr	#4,d4			;d4 = groups of 16 physical pixels
	move	sc_rez+lpt_SCD(a2),d5	;d5 = physical rez
	add	d5,d5
	move	f20_rez_t(pc,d5),d5
	jmp	f20_rez_t(pc,d5)
;
f20_rez_t:
.tr:	dc.w	f20_4p-.tr,f20_2p-.tr,f20_1p-.tr,f20_8p-.tr
	dc.w	f20_4p-.tr,f20_2p-.tr,f20_1p-.tr,f20_8p-.tr
;------------------------------------
f20_1p:
	mulu	#emu_f20_1p_stp,d4	;d4 = byte offset from emu_f20_1p_ref
	lea	emu_f20_1p_ref(pc),a6
	sub.l	d4,a6			;a6-> loop target for emu of 2_long => 1 word
	movem.l	a0/a1,-(sp)		;push a0/a1
	jmp	(a6)
;
emu_f20_1p_rept	= 128			;max 256 bytes = 128 16_pixel groups
;
emu_f20_1p_beg:
	REPT	emu_f20_1p_rept		;produces one 16_pixel group per repetition
	move	(a0)+,(a1)+
	ENDR
emu_f20_1p_ref:
emu_f20_1p_stp	=	(emu_f20_1p_ref-emu_f20_1p_beg)/emu_f20_1p_rept
	bra	emu_f20_next
;------------------------------------
f20_2p:
	mulu	#emu_f20_2p_stp,d4	;d4 = byte offset from emu_f20_2p_ref
	lea	emu_f20_2p_ref(pc),a6
	sub.l	d4,a6			;a6-> loop target for emu of 2_long => 1 word
	movem.l	a0/a1,-(sp)		;push a0/a1
	jmp	(a6)
;
emu_f20_2p_rept	= 128			;max 512 bytes = 128 16_pixel groups
;
emu_f20_2p_beg:
	REPT	emu_f20_2p_rept		;produces one 16_pixel group per repetition
	move.l	(a0)+,(a1)+
	ENDR
emu_f20_2p_ref:
emu_f20_2p_stp	=	(emu_f20_2p_ref-emu_f20_2p_beg)/emu_f20_2p_rept
	bra	emu_f20_next
;------------------------------------
f20_4p:
	mulu	#emu_f20_4p_stp,d4	;d4 = byte offset from emu_f20_4p_ref
	lea	emu_f20_4p_ref(pc),a6
	sub.l	d4,a6			;a6-> loop target for emu of 2_long => 1 word
	movem.l	a0/a1,-(sp)		;push a0/a1
	jmp	(a6)
;
emu_f20_4p_rept	= 64			;max 512 bytes = 64 16_pixel groups
;
emu_f20_4p_beg:
	REPT	emu_f20_4p_rept		;produces one 16_pixel group per repetition
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	ENDR
emu_f20_4p_ref:
emu_f20_4p_stp	=	(emu_f20_4p_ref-emu_f20_4p_beg)/emu_f20_4p_rept
	bra	emu_f20_next
;------------------------------------
f20_8p:
	mulu	#emu_f20_8p_stp,d4	;d4 = byte offset from emu_f20_8p_ref
	lea	emu_f20_8p_ref(pc),a6
	sub.l	d4,a6			;a6-> loop target for emu of 2_long => 1 word
emu_f20_loop:
	movem.l	a0/a1,-(sp)		;push a0/a1
	jmp	(a6)
;
emu_f20_8p_rept	= 32			;max 512 bytes = 32 16_pixel groups
;
emu_f20_8p_beg:
	REPT	emu_f20_8p_rept		;produces one 16_pixel group per repetition
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	ENDR
emu_f20_8p_ref:
emu_f20_8p_stp	=	(emu_f20_8p_ref-emu_f20_8p_beg)/emu_f20_8p_rept
emu_f20_next:
	movem.l	(sp)+,a0/a1		;pull a0/a1
	add	emu_step,a0		;a0 -> next emu line
	add	lace_step,a1		;a1 -> next even lace line
	dbra	d0,emu_f20_loop		;loop back for all lines
	rts
;----------------------------------------------------------------------------
;End of:	main filter routine
;----------------------------------------------------------------------------
;Start of:	Filter initialization routines
;----------------------------------------------------------------------------
init_filt:
	movem.l	d0-d2/a0-a2,-(sp)
	lea	vz(pc),a2
	move.b	emu_block_f-vz(a2),d0
	and	#(1<<lace_2_lemu_b)+(1<<user_setup_b),d0
	bne.s	.no_delay
.delay_1:
	tas	emu_block_f-vz(a2)
	bmi.s	.delay_1
.no_delay:
	move	d0,-(sp)
;
	move	ref_filt_ix(pc),d0
	lea	def_spd_t(pc),a0
	move.l	(a0,d0),d1
	move	d1,emu_spd-vz(a2)	;set emulation speed (lines/vbi)
;
	move	lace_slot,d0		;d0 = active slot pos
	jsr	emu_sethome
	tst.l	extra_Xrez
	sne	d0			;full_screen => 0  virtual_screen => -1
	add.b	#'W',d0			;full_screen => W  virtual_screen => V
	move.b	d0,VSCR_cookie-vz(a2)
;
	tst	(sp)+
	bne.s	.done_block
	bclr	#interrupt_b,emu_block_f-vz(a2)
.done_block:
	movem.l	(sp)+,d0-d2/a0-a2
	rts
;----------------------------------------------------------------------------
fix_colour:
	movem.l	d0/a0-a3,-(sp)
	move.l	LPT_p(pc),a3			;a3 -> LPT
	tst	lpt_emu_type_ix(a3)
	beq	.done_colours			;skip fix for NULL filter
	lea	vz(pc),a2			;a2 -> vz
	lea	(hw_pal).w,a1			;a1 -> hw_pal
	clr	d0
	move	sc_emu_planes+lpt_SCD(a3),d0	;d0 = bit planes of emulated rez
	move	sc_rez+lpt_SCD(a3),d1
	and	#7,d1
	move.b	.planes_t(pc,d1),d1		;d1 = bit planes of physical rez
	cmp	#2,d0
	bhs.s	.real_colours			;jump if emulating colour rez
	cmp	#2,d1
	bhi	.1p_emu_in_4p			;set colours for mono_emu  in 4 planes or more
	blo.s	.done_colours			;skip colours for true mono
.1p_emu_in_2p:			;fix colours to emulate in medium
	btst	#0,background+1-vz(a2)
	beq.s	.high_invert
	lea	h_nrm_col_p_t(pc),a0
	bra.s	.high_setcolor
;
.planes_t:
	dc.b	4,2,1,8,4,2,1,8			;ST_L,ST_M,ST_H,----,TT_M,----,TT_H,TT_L
;
.high_invert:
	lea	h_inv_col_p_t(pc),a0
.high_setcolor:
	move	ref_filt_ix(pc),d0
	move.l	(a0,d0),d0
	ble.s	.set_16_colours_if_needed
	move.l	d0,a0
	move.l	a0,emu_pal_p-vz(a2)
	st	need_colours_f
	bra.s	.set_4_colours
;
.real_colours:				;emulating some colour rez
	cmp	#1,d1			;one physical bitplane ?
	beq.s	.colour_emu_in_1p	;skip colours for colour_emu in mono
	lea	m_f4_col_t(pc),a0	;a0 -> greyscales for filter 4
	cmp	#4,emu_filt_ix-vz(a2)
	beq.s	.set_16_colour_need	;set greyscales for filter 4
	cmp	#4,d1			;four physical bitplanes or more
	bhs.s	.low_colours
	lea	normcol_2p_t(pc),a0	;a0 -> normal medium colours
	bra.s	.set_16_colours_if_needed
;
.set_16_colour_need:
	st	need_colours_f
	bra.s	.set_16_colours
;
.low_colours:				;try 16 colours
	lea	normcol_4p_t(pc),a0	;a0 -> normal low rez colours
.set_16_colours_if_needed:
	tst.b	need_colours_f
	beq.s	.done_colours
	sf	need_colours_f
.set_16_colours:
	move.l	a0,emu_pal_p-vz(a2)
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
.set_4_colours:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
.colour_emu_in_1p:
.1p_emu_in_4p:
.done_colours:
	movem.l	(sp)+,d0/a0-a3
	rts
;----------------------------------------------------------------------------
;End of:	Filter initialization routines
;----------------------------------------------------------------------------
;	Mouse scanner to be called in some regular vbi's
;
extra_Xrez:	dc.w	0
extra_Yrez:	dc.w	0
scan_Xscale:	dc.w	0
scan_Yscale:	dc.w	0
scan_mode:	dc.w	-1
scan_gcurxy:	dc.l	0
;
emu_recalc:
	move.l	emu_base_p,d2
	beq.s	.done_recalc
	add.l	4(sp),d2
	sub.l	8(sp),d2
	move.l	d2,emu_base_p
.done_recalc:
	rts
;
;
calc_disp:	
;uses:	d0-d2/a0-a2
;needs: a2 -> vz
	move.l	LPT_p(pc),a1
	move.l	line_a_base_p(pc),a0
	move	mscan_step(pc),d2
;
	move	extra_Yrez(pc),d1	;d1 = extra_Yrez
	ble.s	.zero_Yscan		;if no extra height, go reset to top margin
	tst	scan_mode-vz(a2)
	beq.s	.no_Yscan
	move	la_gcury(a0),d0
	move	d0,scan_gcurxy+2-vz(a2)
	bclr	#0,d0			;force to even line
	sub	mscan_Ypos(pc),d0
	cmp	d2,d0			;near top ?
	blt.s	.scan_up
.scan_down:
	add	d2,d0
	sub	mscan_Yrez(pc),d0	;near bottom ?
	blt.s	.no_Yscan		;skip if not near borders
	add	d2,d0			;d0 = new screen adjustment
	add	mscan_Ypos(pc),d0
.limit_Yscan:
	cmp	d1,d0			;Ypos > extra_Yrez ?
	bgt.s	.max_Yscan
	move	d0,mscan_Ypos-vz(a2)	;store new Ypos
	bra.s	.Yscan_ok
;
.max_Yscan:
	move	d1,mscan_Ypos-vz(a2)	;limit Ypos to extra_Yrez
	bra.s	.Yscan_ok
;
.zero_Yscan:
	clr	mscan_Ypos-vz(a2)
	bra.s	.no_Yscan
;
.scan_up:
	add	mscan_Ypos(pc),d0	;d0 = mouse Ypos
	sub	d2,d0
	sub	d2,d0			;d0 = new screen Ypos
	bgt.s	.limit_Yscan
.scan_top:
	clr	mscan_Ypos-vz(a2)
.Yscan_ok:
	clr.l	emu_base_p		;this clr happens for valid Ypos changes
.no_Yscan:
;
	move	extra_Xrez(pc),d1	;d1 = extra_Xrez
	ble.s	.zero_Xscan		;if no extra width, go reset to left margin
	tst	scan_mode-vz(a2)
	beq.s	.no_Xscan
	move	la_gcurx(a0),d0
	move	d0,scan_gcurxy-vz(a2)
	sub	mscan_Xpos(pc),d0
	cmp	d2,d0			;near left ?
	blt.s	.scan_left
.scan_right:
	add	d2,d0
	sub	mscan_Xrez(pc),d0	;near right ?
	blt.s	.no_Xscan
	add	d2,d0
	add	mscan_Xpos(pc),d0
.limit_Xscan:
	add	#31,d0
	and	#-32,d0			;d0 = new screen Xpos
	cmp	d1,d0			;Xpos > extra_Xrez ?
	bgt.s	.max_Xscan
	move	d0,mscan_Xpos-vz(a2)	;store new Xpos
	bra.s	.Xscan_ok
;
.max_Xscan:
	move	d1,mscan_Xpos-vz(a2)	;limit Xpos to extra_Xrez
	bra.s	.Xscan_ok
;
.zero_Xscan:
	clr	mscan_Xpos-vz(a2)
	bra.s	.no_Xscan
;
.scan_left:
	add	mscan_Xpos(pc),d0	;d0 = mouse Xpos
	sub	d2,d0
	sub	d2,d0			;d0 = new screen Xpos
	bgt.s	.limit_Xscan
.scan_lmarg:
	clr	mscan_Xpos-vz(a2)
.Xscan_ok:
	clr.l	emu_base_p		;this clr happens for valid Xpos changes
.no_Xscan:
;
	move.l	emu_base_p,d0
	bne.s	.keep_pos
	move.l	lpt_emu_phys_p(a1),a0	;a0 -> emulated screen
	move	mscan_Ypos(pc),d0
	mulu	sc_emu_bytewid+lpt_SCD(a1),d0
	add.l	d0,a0			;a0 -> first visible emulated line
	move	mscan_Xpos(pc),d2
	mulu	sc_emu_planes+lpt_SCD(a1),d2
	lsr	#3,d2
	add	d2,a0			;a0 -> first visible emulated pixel
	move.l	a0,emu_base_p		;emu_base_p = a0
.keep_pos:
	rts
;
;----------------------------------------------------------------------------
;
loc_load_inf:
	lea	inf_path_s(pc),a3
	gemdos	Fopen,(a3),!
	move.l	d0,d7
	bpl.s	loc_info_found
	lea	auto_inf_path_s(pc),a3
	bra.s	loc_load_info_file
;
loc_load_def:
	lea	def_path_s(pc),a3
	gemdos	Fopen,(a3),!
	move.l	d0,d7
	bpl.s	loc_info_found
	lea	auto_def_path_s(pc),a3
loc_load_info_file:
	clr	info_err_f
	gemdos	Fopen,(a3),!
	move.l	d0,d7
	bmi.s	loc_done_info
loc_info_found:
	gemdos	Fclose,d7
	move.l	a3,d0
	bra.s	load_info
;
loc_done_info:
	moveq	#-1,d0		;exit with:  d0 = E_ERROR,  d7 = file error code
	rts
;
;
load_info:
	movem.l	d1-d7/a0-a6,-(sp)
	lea	vz(pc),a6
	clr	info_err_f-vz(a6)
	move.l	d0,infopath_s_p-vz(a6)
	gemdos	Fopen|_ind,d0,!
	move.l	d0,d7
	bmi	.done_info
.read_info:
	move.l	LPT_p(pc),a4
	clr	inf_buf_cnt-vz(a6)
.info_loop:
	bsr	get_info
	bmi	.info_exit
	cmp	#'S',d0
	bne.s	.info_non_setup
.info_fn_setup:
	bsr	get_info
	bmi	.info_syntax_err
	cmp	#'=',d0
	bne	.info_syntax_err
	bsr	get_binary
	bmi	.info_syntax_err
	move	d0,d1
	bsr	get_binary
	bmi	.info_syntax_err
	move	d0,setup_keys-vz(a6)
	move	d1,setup_mask-vz(a6)
	bra.s	.info_loop
;
.info_non_setup:
	bsr	back_info
	bsr	get_binary
	bmi	.info_syntax_err
.info_fn_define:
	lea	emu_def_buf(pc),a0
	move	d0,(a0)+		;buff emu_slot number
	bsr	get_info
	bmi	.info_syntax_err
	cmp	#'=',d0
	bne	.info_syntax_err
	moveq	#6-1,d1
.info_define_loop_1:			;loop start for 6 parameters
	bsr	get_decimal		;get a decimal number
	bmi.s	.info_syntax_err	;refuse remaining file on error
	move	d0,(a0)+		;buff parameter
	dbra	d1,.info_define_loop_1	;loop back for 6 parameters
	lea	emu_def_buf(pc),a0	;a0 -> buffered definition
	move	2(a0),d0
	mulu	6(a0),d0
	cmp.l	#$10000,d0
	bhs.s	.info_syntax_err		;limit planes*xrez to 65535
	mulu	4(a0),d0		;d0 = planes*xrez*yrez
	beq.s	.info_syntax_err		;demand non_zero xrez, yrez, planes
	lsr.l	#3,d0			;d0 = planes*xrez*yrez/8 == bytes for screen
	cmp.l	#maxrez_size,d0
	bhi.s	.info_syntax_err		;limit RAM cost to maxrez_size bytes
	cmp	#16,6(a0)
	bhi.s	.info_syntax_err		;limit planes to 1..16
	cmp	#7,8(a0)
	bhi.s	.info_syntax_err		;limit rez to 0..7
	cmp	#slot_limit,10(a0)
	bhs.s	.info_syntax_err
	add	#norm_slots,10(a0)
	cmp	#slot_limit,10(a0)
	blo.s	.keep_lace_slot
	sub	#slot_limit,10(a0)
.keep_lace_slot:
	cmp	#filt_ix_lim,12(a0)
	bhs.s	.info_syntax_err		;limit filter to 0..filt_ix_lim-1
	move	(a0)+,d0		;d0 = emu_slot number,  a0 -> data
	cmp	#16*4,d0
	bhs.s	.info_syntax_err		;limit emu_slot to 0..63
	addq	#1,d0			;increment to make default legal
	mulu	#6*2,d0
	lea	emu_type_t(pc),a1
	lea	(a1,d0),a1		;a1 -> emu_slot storage
	moveq	#6-1,d1
.info_define_loop_2:			;loop start for 6 words
	move	(a0)+,(a1)+		;move a word from buffer to storage
	dbra	d1,.info_define_loop_2	;loop back for 6 words
	bra	.info_loop
;
.info_syntax_err:
	moveq	#-1,d0
	move	d0,info_err_f-vz(a6)
.info_exit:
	gemdos	Fclose,d7
.done_info:
	clr.l	d0
	tst.l	d7
	bmi.s	.flag_err
	move	info_err_f(pc),d0
	beq.s	.info_flagged
.flag_err:
	moveq	#-1,d0
.info_flagged:
	move	setup_keys(pc),lpt_setup_keys(a4)
	move	setup_mask(pc),lpt_setup_mask(a4)
	movem.l	(sp)+,d1-d7/a0-a6
	rts
;
;	The INFO-file routines below assume d7=file handle, a6->vz
;
back_info:
	subq.l	#1,inf_buf_pos_p-vz(a6)
	addq	#1,inf_buf_cnt-vz(a6)
	rts
;
get_info:
	bsr.s	get_char
	bmi.s	.done_get_info
	cmp	#' ',d0
	beq.s	get_info
	cmp	#HT,d0
	beq.s	get_info
	cmp	#CR,d0
	beq.s	get_info
	cmp	#LF,d0
	beq.s	get_info
	cmp	#';',d0
	bne.s	.take_get_info
.remark_loop:
	bsr.s	get_char
	bmi.s	.done_get_info
	cmp	#CR,d0
	beq.s	get_info
	cmp	#LF,d0
	beq.s	get_info
	bra.s	.remark_loop
;
.take_get_info:
	tst.l	d0
.done_get_info:
	rts
;
get_char:
	bsr.s	read_char
	bmi.s	.done_get_char
	cmp	#'a',d0
	blo.s	.no_low_case
	cmp	#'z',d0
	bhi.s	.no_low_case
	and	#$DF,d0
.no_low_case:
	tst.l	d0
.done_get_char:
	rts
;
read_char:
	tst	inf_buf_cnt-vz(a6)
	bne.s	.read_buf
	movem.l	d1-d2/a0-a2,-(sp)
	lea	inf_buf_beg(pc),a0
	move.l	a0,inf_buf_pos_p-vz(a6)
	gemdos	Fread,d7,#inf_buf_end-inf_buf_beg,(a0)
	movem.l	(sp)+,d1-d2/a0-a2
	tst.l	d0
	bmi.s	.done_read_char
	move	d0,inf_buf_cnt-vz(a6)
	bne.s	.read_buf
	moveq	#-1,d0
	rts
;
.read_buf:
	move.l	a0,-(sp)
	move.l	inf_buf_pos_p(pc),a0
	clr.l	d0
	move.b	(a0)+,d0
	move.l	a0,inf_buf_pos_p-vz(a6)
	subq	#1,inf_buf_cnt-vz(a6)
	movea.l	(sp)+,a0
	tst.l	d0
.done_read_char:
	rts
;
get_binary:	;Failure to find 6-digit binary does NOT allow alternate testing as yet
	bsr	get_info
	bmi.s	.done_get_binary
	cmp	#'0',d0
	blo.s	.no_binary
	cmp	#'1',d0
	bhi.s	.no_binary
	movem.l	d1/d2,-(sp)
	move	d0,d1
	and.l	#1,d1
	move	#5-1,d2
.binary_loop:
	bsr	get_char
	bmi.s	.err_binary
	cmp	#'0',d0
	blo.s	.bad_binary
	cmp	#'1',d0
	bhi.s	.bad_binary
	lsr	#1,d0
	roxl	#1,d1
	dbra	d2,.binary_loop
	move.l	d1,d0
.err_binary:
	movem.l	(sp)+,d1/d2
	tst.l	d0
	rts
;
.bad_binary:
	moveq	#-1,d0
	bra.s	.err_binary
;
.no_binary:
	moveq	#-1,d0
.done_get_binary:
	rts
;
;
get_decimal:
	bsr	get_info
	bmi.s	.done_get_decimal
	cmp	#'0',d0
	blo.s	.no_decimal
	cmp	#'9',d0
	bhi.s	.no_decimal
	move.l	d1,-(sp)
	move	d0,d1
	and.l	#$000F,d1
.decimal_loop:
	bsr	get_char
	bmi.s	.err_decimal
	sub	#'0',d0
	blo.s	.end_decimal
	cmp	#9,d0
	bhi.s	.end_decimal
	mulu	#10,d1
	add.l	d0,d1
	cmp.l	#9999,d1
	bhi.s	.bad_decimal
	bra.s	.decimal_loop
;
.end_decimal:
	move.l	d1,d0
.err_decimal:
	move.l	(sp)+,d1
	tst.l	d0
	rts
;
.bad_decimal:
	moveq	#-1,d0
	bra.s	.err_decimal
;
.no_decimal:
	moveq	#-1,d0
.done_get_decimal:
	rts
;
basepage_p:	ds.l	1
info_err_f:	ds.w	1
infopath_s_p:	ds.l	1
inf_buf_beg:	ds.b	128
inf_buf_end:
inf_buf_pos_p:	ds.l	1
inf_buf_cnt:	ds.w	1
emu_def_buf:	ds.w	16
;
init_exit_d0:
	lea	exit_stack_top(pc),sp	;ensure valid stack for exit
;
	lea	horcom_t(pc),a0		;a0 -> horcom_t for initialization
	lea	horexp_t(pc),a1
	lea	$100(a1),a2
	lea	$200(a1),a3
	lea	$300(a1),a4
	move	#256-1,d3		;prep to init 256 bytes per table
.iz_horcom_t:
;
	move	d3,d2
	REPT	8
	asl	d1
	lsl.b	d2
	roxl	d1
	ENDR
;
;Here d1 is an index similar to those used for horcom_t access in
;filters and corresponding to the byte lookup position of d3
;so with  d3 = abcdefgh  we have  d1 = _a_b_c_d_e_f_g_h
;
	move.b	d3,(a0,d1)		;allow translation bit-interlaced word => byte
;
	move.b	d1,(a4,d3)		;_e_f_g_h
	rol	#1,d1
	move.b	d1,(a2,d3)		;e_f_g_h_
	rol	#7,d1
	move.b	d1,(a3,d3)		;_a_b_c_d
	rol	#1,d1
	move.b	d1,(a1,d3)		;a_b_c_d_
;
	dbra	d3,.iz_horcom_t
;
	lea	horcom_odd_r,a1
	lea	horcom_even_r,a2
	moveq	#-1,d3			;d3 = dbra for 65536 loops
.iz_fast_horcom_t:
	move	d3,d1
	REPT	8
	lsl.l	d1	;shift odd bit into high word of d1
	lsl.w	d1	;shift even bit into X
	roxl	d2	;shift even bit into d2
	ENDR
	swap	d1	;d1 = byte of odd bits in word d3
;Here the word d3 has been separated into two bytes, with all
;odd bits in d1 and the even bits in d2
	move.b	d1,(a1,d3)
	move.b	d2,(a2,d3)
	dbra	d3,.iz_fast_horcom_t
;
	gemdos	Ptermres,d0,!
;----------------------------------------------------------------------------
;
	_uniref	set_new_jar
	make	JAR_links
;
;----------------------------------------------------------------------------
;	Resident data in TEXT section	(DATA section is erased after init)
;----------------------------------------------------------------------------
; the	emu_slot table structure:
;
;short	Xrez
;short	Yrez
;short	planes
;short	rez
;short	slot
;short	filter
;
;---------------------------------------
setup_keys:
	dc.w	$2		;default = demand left shift for lacescan setup
setup_mask:
	dc.w	$F		;default = ignore mouse for lacescan setup
;
emu_type_t:
	dc.w	0,0,0,0,0,0	 ;Dummy
emu_slot_0_t:	;Xrez,Yrez,Planes,Rez,Slot,Filter
	ds.w	4*16*6		;allow 64 entries
;
mscan_step:	dc.w	16
mouse_cnt:	dc.w	0
;
LPT_p:		dc.l 0	;-> LaceScan parameter table
lace_slot:	dc.w 0	;LaceScan slot number for emulating rez
work_slot:	dc.w 0	;LaceScan slot number for emulating rez requested at opnwk
;
loc_physbase_p:	dc.l 0	;unalterable -> start of logbase screen
loc_physbend_p:	dc.l 0	;unalterable -> end of logbase screen
emu_spd:	dc.w 0	;tics/screen
emu_filt_ix:	dc.w 0	;index for filter type 0..3
ref_filt_ix:	dc.w 0	;4 * index for latest non-zero type
emu_block_f:	dc.w 0	;flags emulation block
emu_work_delay:	dc.l 0	;tics per screen (ensure vbi slots for other work)
emu_work_time:	dc.l 0	;_hz_200 tic of emu filter work
emu_flock_time:	dc.l 0	;_hz_200 tic of 'flock' detection in emu filter
col_check_time:	dc.l 0	;_hz_200 tic of last mono_emu colour check
opnwk_done:	dc.w 0	;high byte flags GEM booted, low byte counts rez changes
opnwk_flag:	dc.w 0	;high byte flags ongoing v_opnwk
;
line_a_base_p:	dc.l 0	;-> line_a variable structure
kbshift_p:	dc.l 0	;-> system variable byte = kbshift bits
;
;----------------------------------------------------------------------------
;To add a new filter, update all tables and increment 'filt_ix_lim'
;
filt_ix_lim	= 21	;1+the number of the last filter existing
;
filt_leg_t:
	dc.l	filt_l0_t,-1,-1,-1,filt_l0_t,-1,-1,filt_70_t			;ST low
	dc.l	filt_l1_t,filt_m1_t,filt_h1_t,-1,-1,-1,-1,-1			;ST medium
	dc.l	filt_l2_t,filt_m2_t,filt_h2_t,-1,filt_l2_t,-1,filt_h2_t,-1	;ST high
	dc.l	-1,-1,-1,-1,-1,-1,-1,-1						;undefined
	dc.l	filt_l0_t,-1,-1,-1,filt_l0_t,-1,-1,filt_70_t			;TT medium
	dc.l	-1,-1,-1,-1,-1,-1,-1,-1						;undefined
	dc.l	filt_l2_t,filt_m2_t,filt_h2_t,-1,filt_l2_t,-1,filt_h2_t,-1	;TT high
	dc.l	-1,-1,-1,-1,-1,-1,-1,filt_77_t					;TT low
;
next_leg_t:
	dc.l	next_l0_t,-1,-1,-1,next_l0_t,-1,-1,next_70_t			;ST low
	dc.l	next_l1_t,next_m1_t,next_h1_t,-1,-1,-1,-1,-1			;ST medium
	dc.l	next_l2_t,next_m2_t,next_h2_t,-1,next_l2_t,-1,next_h2_t,-1	;ST high
	dc.l	-1,-1,-1,-1,-1,-1,-1,-1						;undefined
	dc.l	next_l0_t,-1,-1,-1,next_l0_t,-1,-1,next_70_t			;TT medium
	dc.l	-1,-1,-1,-1,-1,-1,-1,-1						;undefined
	dc.l	next_l2_t,next_m2_t,next_h2_t,-1,next_l2_t,-1,next_h2_t,-1	;TT high
	dc.l	-1,-1,-1,-1,-1,-1,-1,next_77_t					;TT low
;
prev_leg_t:
	dc.l	prev_l0_t,-1,-1,-1,prev_l0_t,-1,-1,prev_70_t			;ST low
	dc.l	prev_l1_t,prev_m1_t,prev_h1_t,-1,-1,-1,-1,-1			;ST medium
	dc.l	prev_l2_t,prev_m2_t,prev_h2_t,-1,prev_l2_t,-1,prev_h2_t,-1	;ST high
	dc.l	-1,-1,-1,-1,-1,-1,-1,-1						;undefined
	dc.l	prev_l0_t,-1,-1,-1,prev_l0_t,-1,-1,prev_70_t			;TT medium
	dc.l	-1,-1,-1,-1,-1,-1,-1,-1						;undefined
	dc.l	prev_l2_t,prev_m2_t,prev_h2_t,-1,prev_l2_t,-1,prev_h2_t,-1	;TT high
	dc.l	-1,-1,-1,-1,-1,-1,-1,prev_77_t					;TT low
;
;-----------------------00.01.02.03.04.05.06.07.08.09.10.11.12.13.14.15.16.17.18.19.20
filt_l0_t:	dc.w	00,03,03,03,04,03,03,03,03,03,03,03,03,03,03,03,03,03,18,03,20
filt_70_t:	dc.w	00,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05
filt_l1_t:	dc.w	00,09,09,09,09,09,09,09,09,09,09,09,09,09,09,09,09,09,09,09,09
filt_m1_t:	dc.w	00,03,03,03,04,03,03,03,03,03,03,03,03,03,03,03,03,03,18,03,20
filt_h1_t:	dc.w	00,01,02,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01
filt_h2_t:	dc.w	00,03,03,03,03,03,06,07,08,03,03,03,03,03,03,03,03,03,18,03,20
filt_m2_t:	dc.w	00,15,15,15,15,15,15,15,15,15,15,15,15,15,14,15,16,17,15,15,15
filt_l2_t:	dc.w	00,11,11,11,11,11,11,11,11,11,10,11,12,13,11,11,11,11,11,11,11
filt_77_t:	dc.w	00,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,18,19,20
;
;-----------------------00.01.02.03.04.05.06.07.08.09.10.11.12.13.14.15.16.17.18.19.20
next_l0_t:	dc.w	03,03,03,04,18,18,18,18,18,18,18,18,18,18,18,18,18,18,20,20,03
next_70_t:	dc.w	05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05
next_l1_t:	dc.w	09,09,09,09,09,09,09,09,09,09,09,09,09,09,09,09,09,09,09,09,09
next_m1_t:	dc.w	03,03,03,04,18,18,18,18,18,18,18,18,18,18,18,18,18,18,20,20,03
next_h1_t:	dc.w	01,02,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01
next_h2_t:	dc.w	03,03,03,06,06,06,07,08,18,18,18,18,18,18,18,18,18,18,20,20,03
next_m2_t:	dc.w	14,14,14,14,14,14,14,14,14,14,14,14,14,14,15,16,17,14,14,14,14
next_l2_t:	dc.w	10,10,10,10,10,10,10,10,10,10,11,12,13,10,10,10,10,10,10,10,10
next_77_t:	dc.w	03,03,03,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,19,20,03
;
;-----------------------00.01.02.03.04.05.06.07.08.09.10.11.12.13.14.15.16.17.18.19.20
prev_l0_t:	dc.w	20,20,20,20,03,04,04,04,04,04,04,04,04,04,04,04,04,04,04,18,18
prev_70_t:	dc.w	05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05,05
prev_l1_t:	dc.w	09,09,09,09,09,09,09,09,09,09,09,09,09,09,09,09,09,09,09,09,09
prev_m1_t:	dc.w	20,20,20,20,03,04,04,04,04,04,04,04,04,04,04,04,04,04,04,18,18
prev_h1_t:	dc.w	02,02,01,02,02,02,02,02,02,02,02,02,02,02,02,02,02,02,02,02,02
prev_h2_t:	dc.w	20,20,20,20,03,03,03,06,07,08,08,08,08,08,08,08,08,08,08,18,18
prev_m2_t:	dc.w	17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,14,15,16,17,17,17
prev_l2_t:	dc.w	13,13,13,13,13,13,13,13,13,13,13,10,11,12,13,13,13,13,13,13,17
prev_77_t:	dc.w	20,20,20,20,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,18,19
;
emu_filt_t:
	dc.l	emu_f0,emu_f1,emu_f2,emu_f3
	dc.l	emu_f4,emu_f5,emu_f6,emu_f7
	dc.l	emu_f8,emu_f9,emu_f10,emu_f11
	dc.l	emu_f12,emu_f13,emu_f14,emu_f15
	dc.l	emu_f16,emu_f17,emu_f18,emu_f19
	dc.l	emu_f20
framed_filt_t:
	dc.l	00,00,00,00
	dc.l	00,00,00,00
	dc.l	00,00,00,00
	dc.l	00,00,00,00
	dc.l	00,00,-1,00
	dc.l	-1
def_spd_t:		;tics/screen =>	;frames/second
	dc.l	00,25,25,20	;---, 08, 08, 10
	dc.l	40,40,40,67	; 05, 05, 05, 03
	dc.l	99,25,99,50	; 02, 08, 02, 04
	dc.l	50,50,33,40	; 04, 04, 06, 05
	dc.l	40,40,50,33	; 05, 05, 04, 06
	dc.l	25		; 08
max_spd_t:
	dc.l	100,100,100,100
	dc.l	100,100,100,100
	dc.l	100,100,100,100
	dc.l	100,100,100,100
	dc.l	100,100,100,100
	dc.l	100
XY_scale_t:	;-1=emu expanded to lace  0=normal  +1=emu compressed to lace
	dc.w	0,0	;f0
	dc.w	0,1	;f1
	dc.w	0,0	;f2
	dc.w	0,0	;f3
	dc.w	0,1	;f4
	dc.w	0,0	;f5
	dc.w	0,1	;f6
	dc.w	1,0	;f7
	dc.w	1,1	;f8
	dc.w	0,0	;f9
	dc.w	-1,-1	;f10
	dc.w	0,0	;f11
	dc.w	0,0	;f12
	dc.w	0,0	;f13
	dc.w	0,-1	;f14
	dc.w	0,0	;f15
	dc.w	0,0	;f16
	dc.w	0,0	;f17
	dc.w	1,0	;f18
	dc.w	0,-1	;f19
	dc.w	0,1	;f20
h_nrm_col_p_t:
	dc.l	0,h_nrm_col_1,h_nrm_col_2,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0
h_inv_col_p_t:
	dc.l	0,h_inv_col_1,h_inv_col_2,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	0
;
background:
	dc.w	$0777
;
emu_pal_p:
	dc.l	normcol_2p_t
;
h_nrm_col_1:
	dc.l	$FFF0444,$CCC0000
h_nrm_col_2:
	dc.l	$FFF0FFF,$0000000
h_inv_col_1:
	dc.l	$0000CCC,$4440FFF
h_inv_col_2:
	dc.l	$0000000,$FFF0FFF
;
normcol_2p_t:
	dc.l	$FFF0F00,$0F00000
	dc.l	$00F0F0F,$0FF0666
	dc.l	$4440500,$0500550
	dc.l	$0050505,$0550000
;
normcol_4p_t:
	dc.l	$FFF0F00,$0F00FF0
	dc.l	$00F0F0F,$0FF0666
	dc.l	$4440500,$0500550
	dc.l	$0050505,$0550000
;
m_f4_col_t:
	dc.l	$FFF0444,$CCC0000
	dc.l	$CCC0444,$CCC0444
	dc.l	$CCC0444,$CCC0444
	dc.l	$CCC0444,$CCC0000
;
f11_mask_t_0:
	dc.l	$10100000,$4141AEAE
	dc.l	$00008888,$22225555
	dc.l	$01010000,$1414EAEA
	dc.l	$00002222,$88885555
	dc.l	$10100000,$4141AEAE
	dc.l	$00008888,$22225555
	dc.l	$01010000,$1414EAEA
	dc.l	$00002222,$88885555
;
f11_mask_t_1:
	dc.l	$11110000,$4444AAAA
	dc.l	$00008888,$22225555
	dc.l	$00000000,$1111EEEE
	dc.l	$00002222,$88885555
	dc.l	$44440000,$1111AAAA
	dc.l	$00002222,$88885555
	dc.l	$00000000,$4444BBBB
	dc.l	$00008888,$22225555
;
f11_mask_t_2:
	dc.l	$11110000,$4444AAAA
	dc.l	$00008888,$22225555
	dc.l	$00000000,$1111EEEE
	dc.l	$00002222,$88885555
	dc.l	$11110000,$4444AAAA
	dc.l	$00008888,$22225555
	dc.l	$00000000,$1111EEEE
	dc.l	$00002222,$88885555
;
f15_mask_t_0:
	dc.w	$4444,$BBBB
	dc.w	$1111,$EEEE
	dc.w	$4444,$BBBB
	dc.w	$1111,$EEEE
;
f15_mask_t_1:
	dc.w	$5555,$AAAA
	dc.w	$0000,$FFFF
	dc.w	$AAAA,$5555
	dc.w	$0000,$FFFF
;
f15_mask_t_2:
	dc.w	$5555,$AAAA
	dc.w	$0000,$FFFF
	dc.w	$5555,$AAAA
	dc.w	$0000,$FFFF
;
;----------------------------------------------------------------------------
f11_mask_t_p:
	dc.l	0
f15_mask_t_p:
	dc.l	0
;----------------------------------------------------------------------------
_VDO_cookie:	ds.l	1
VDO_b_index:	ds.l	1
VDO_w_index:	ds.l	1
VDO_l_index:	ds.l	1
VDO_rez_mask_max:	;alias for two words below together as one longword
VDO_rez_mask:	ds.w	1
VDO_rez_max:	ds.w	1
VDO_high_rez:	ds.w	1
VDO_max_size:	ds.l	1
olock_base_p:	ds.l	1
extra_base_p:	ds.l	1
;----------------------------------------------------------------------------
need_colours_f:	dc.b	0
soft_frame_f:	dc.b	0
hard_frame_f:	dc.b	0
		even
;----------------------------------------------------------------------------
;	VSCR cookie and associated data
;
VSCR_p:
	dc.l	VSCR_cookie
;
VSCR_cookie:
	dc.l	'WSCR'	;WSCR = passive  VSCR = active
	dc.l	'LEmu'
	dc.w	$0001
mscan_Xpos:	dc.w	0
mscan_Ypos:	dc.w	0
mscan_Xrez:	dc.w	0
mscan_Yrez:	dc.w	0
;----------------------------------------------------------------------------
;NB: all stuff beyond this point is used only for initialization
;NB: and will be reclaimed for variable use at program exit
;
var_base:
vz		= var_base
reserved	set	0
;
exit_stack	= var_base+reserved
reserved	set	reserved+$100
exit_stack_top	= var_base+reserved
;
horcom_t	= var_base+reserved
hc_size		=	$5555+1
reserved	set	reserved+hc_size
;
horexp_t	= var_base+reserved
hx_size		=	$400
reserved	set	reserved+hx_size
;
horcom_odd_t	= var_base+reserved
reserved	set	reserved+$10000
horcom_odd_r	= horcom_odd_t+$8000
;
horcom_even_t	= var_base+reserved
reserved	set	reserved+$10000
horcom_even_r	= horcom_even_t+$8000
;
var_size	= reserved
;----------------------------------------------------------------------------
init_emu:
	lea	vz(pc),a6
	move.l	4(sp),a5
	move.l	a5,basepage_p-vz(a6)
	move.l	sp,d6				;d1 = original SP
	lea	iz_stack_end(pc),sp
	gemdos	Super,!
	move.l	d0,d7
	move.l	sp,d0
	sub.l	a5,d0
	add.l	#var_size+maxrez_size,d0
	lea	low_mem_s(pc),a3		;a3 -> low memory error message
	sub.l	d0,d6				;d6 = Extra RAM available
	bls.s	term_error
	cmp.l	#128*Kb,d6			;demand 128 Kb extra
	blo.s	term_error
	gemdos	Mshrink,!,(a5),d0
	lea	not_again_s(pc),a3
	eval_cookie	#'LEmu'
	bmi.s	self_not_present
term_error:
	gemdos	Super|_ind,d7
	gemdos	Cconws,message_s(pc)
	gemdos	Cconws,(a3)
	gemdos	Cconws,press_key_s(pc)
	gemdos	Cnecin
	gemdos	Cconws,cr_lf_s(pc)
	gemdos	Pterm,#-1
;
self_not_present:
	lea	no_lace_s(pc),a3
	eval_cookie	#'Lace'
	bmi.s	term_error
.found_LPT:
	move.l	d0,a5		;a5 -> Lace parameter table
	move.l	a5,LPT_p-vz(a6)
	move	#interface_ver,d0
	cmp	lpt_interface(a5),d0
	lea	too_new_lace_s(pc),a3
	blo	term_error
	lea	too_old_lace_s(pc),a3
	bhi	term_error
;Here we know a compatible LaceScan version is active
.init_vscr:
	lea	vs_conflict_s(pc),a3
	make_cookie	#'VSCR',VSCR_p(pc)
	bpl.s	.init_vectors
	gemdos	Cconws,(a3)
	lea	vs_refusal_s(pc),a3
	gemdos	Cnecin
	gemdos	Cconws,cr_lf_s(pc)
	cmp.b	#'Y',d0
	bne	term_error
	edit_cookie	#'VSCR',VSCR_p(pc)
	bmi.s	.init_vscr
;
.init_vectors:			;Here legal installation is definite
	moveq	#0,d3			;assume ST video hardware as default
	eval_cookie	#'_VDO'		;get _VDO cookie
	bmi.s	.have_VDO		;go use default if no _VDO cookie
	move.l	d0,d3			;use the found _VDO value
.have_VDO:
	move.l	d3,_VDO_cookie		;store _VDO value
	move.l	#$30000,d0		;d0 = normal F030 _VDO value
	cmp.l	d0,d3			;d3 higher than F030 value ?
	bhi.s	.have_VDO_index		;if so, go use F030 index
	move.l	d3,d0			;use found index
.have_VDO_index:
	swap	d0
	move	d0,VDO_b_index		;store video hardware type index [0..3]
	add	d0,d0
	move	d0,VDO_w_index		;store same as prescaled word index
	add	d0,d0
	move	d0,VDO_l_index		;store same as prescaled long index
	move.l	#$30002,d1		;d1 = ST/STE rez mask.maxrez
	moveq	#2,d2			;d2 = high_rez of ST/STE
	cmp	#2*4,d0			;ST/STE VDO type ?
	blo.s	.have_mask_maxrez	;if so, go use ST/STE mask.maxrez
	move.l	#$70007,d1		;d1 = TT/F030 rez mask.maxrez
	moveq	#6,d2			;d2 = high_rez of TT
.have_mask_maxrez:
	lea	VDO_max_size_t(pc),a0
	move.l	(a0,d0),d0		;d0 = max physical screen size
	move.l	d0,VDO_max_size		;store physical screen size (bytes)
	move.l	d1,VDO_rez_mask_max	;store rez mask and max rez
	move	d2,VDO_high_rez		;store high_rez (for special monitor)
;
	lea	(opnwk_fix_1).l,a1
	move.l	a1,lpt_opnwk_lk_1(a5)
	lea	(opnwk_fix_2).l,a1
	move.l	a1,lpt_opnwk_lk_2(a5)
	lea	load_info(pc),a1
	move.l	a1,lpt_emu_reload(a5)
	lea	(emu_command).l,a1
	move.l	a1,lpt_emu_command(a5)
	lea	emu_block_f(pc),a1
	move.l	a1,lpt_emu_block_p(a5)
	lea	(emu_sethome).l,a1
	move.l	a1,lpt_emu_sethome(a5)
	lea	(emu_home).l,a1
	move.l	a1,lpt_emu_home(a5)
	lea	(emu_center).l,a1
	move.l	a1,lpt_emu_center(a5)
	lea	(emu_left).l,a1
	move.l	a1,lpt_emu_left(a5)
	lea	(emu_right).l,a1
	move.l	a1,lpt_emu_right(a5)
	lea	(emu_up).l,a1
	move.l	a1,lpt_emu_up(a5)
	lea	(emu_down).l,a1
	move.l	a1,lpt_emu_down(a5)
	lea	(emu_newmode).l,a1
	move.l	a1,lpt_emu_newmode(a5)
	lea	emu_recalc(pc),a1
	move.l	a1,lpt_emu_recalc(a5)
;
	lea	var_base+var_size,a0
	move.l	a0,d0				;d0 = a0 = start of free memory
	add.l	#$1ff,d0			;\/ force it to a 512 byte boundary
	and.l	#-$200,d0			;/\ by rounding up
	move.l	d0,a0
	move.l	a0,loc_physbase_p-vz(a6)	;store locked physbase pointer
	move.l	a0,lpt_emu_lock_p(a5)		;store LPT pointer for locked screen
	move.l	a0,lpt_emu_phys_p(a5)		;store LPT pointer for normal screen
	add.l	#maxrez_size,a0			;reserv normal screen (virtual screen)
	move.l	a0,loc_physbend_p-vz(a6)	;store total RAM need
	move	emu_id,lpt_emu_id(a5)
;
	move.l	lpt_lockbase_p(a5),a0		;a0 -> original locked physical base
	move.l	a0,olock_base_p			;init ptr to original locked base
	move.l	lpt_fix_pbase(a5),a0
	moveq	#-1,d0
	jsr	(a0)				;ask LaceScan for odd frame screen base
	move.l	d0,extra_base_p
;
	xbios	Keytbl,?,?,?
	move.l	d0,a0
	lea	-1(a0),a0		;NB: this assumes Kbshift stored at Keytbl-1
	move.l	a0,kbshift_p-vz(a6)	;NB: So all early TOS have Kbshift data at Keytbl-1 !!!
	move.l	(_sysbase).w,a1
	move.l	os_selfbeg_p(a1),a0
	move	os_version(a0),d0
	cmp	#$104,d0
	blo.s	.keep_kbshift_p
	move.l	os_kbshift_p(a0),kbshift_p-vz(a6)
.keep_kbshift_p:
;
	_a_init
	move.l	a0,line_a_base_p-vz(a6)
;
	bset		#emu_off_b,emu_block_f-vz(a6)
	XB_install	(emu_vbi_XB).l,(ev_VBI).w	;set emu vbi handler
;
	make_cookie	#'LEmu',LPT_p-vz(a6)
;
	gemdos	Super!_ind,d7
	gemdos	Cconws,message_s(pc)		;Tell user what's up
;
	bsr	loc_load_inf
	bsr.s	disp_info_result
	bsr	loc_load_def
	bsr.s	disp_info_result
;
	move.l	loc_physbend_p(pc),d0
	sub.l	basepage_p(pc),d0			;d0 = Total program ram need
	bra	init_exit_d0
;----------------------------------------------------------------------------
VDO_max_size_t:
	dc.l	$12100,$8000,$28000,$28000	;ST,STE,TT,F030
;----------------------------------------------------------------------------
disp_info_result:
	cmp	info_err_f(pc),d0			;diff means missing file
	bne.s	.done_disp
	gemdos	Cconws,info_head_s(pc)
	gemdos	Cconws|_ind,infopath_s_p(pc)
	lea	info_good_s(pc),a0
	tst	info_err_f-vz(a6)
	beq.s	.disp_result
	lea	info_bad_s(pc),a0
.disp_result:
	gemdos	Cconws,(a0)
.done_disp:
	rts
;----------------------------------------------------------------------------
	make	JAR_links
;----------------------------------------------------------------------------
;
;NB: some of the above code must be moved if the emulator is to be able
;    to start emulation directly, instead of waiting for desktop init.
;NB: I no longer consider direct emulation to be a good idea !!!
;
;----------------------------------------------------------------------------
	section	DATA
;----------------------------------------------------------------------------
vs_conflict_s:
	dc.b	CR,LF
	dc.b	"Sorry, but another driver has already",CR,LF
	dc.b	"taken the virtual screen cookie VSCR.",CR,LF
	dc.b	"Shall I steal it anyway...?"
	dc.b	NUL
;
vs_refusal_s:
	dc.b	CR,LF
	dc.b	"Installation cancelled du to conflict",CR,LF
	dc.b	"with another virtual screen driver.",CR,LF
	dc.b	NUL
;
low_mem_s:
	dc.b	CR,LF
	dc.b	"Sorry, there is not enough memory in",CR,LF
	dc.b	"the system to make Lace_Emu useful.",CR,LF
	dc.b	"Installation is therefore cancelled.",CR,LF
	dc.b	NUL
;
not_again_s:
	dc.b	CR,LF
	dc.b	"Sorry, Cookie = 'LEmu' already exists,",CR,LF
	dc.b	"So Lace_Emu cannot be installed now.",CR,LF
	dc.b	"( May be installed already ! )",CR,LF
	dc.b	NUL
;
no_lace_s:
	dc.b	CR,LF
	dc.b	"Sorry, LaceScan appears to be missing.",CR,LF
	dc.b	"This emulator reqires LaceScan, and so",CR,LF
	dc.b	"could not be installed at this time.",CR,LF
	dc.b	NUL
;
too_new_lace_s:
	dc.b	CR,LF
	dc.b	"This emulator was made for version "
	M_VERSION				;   x.y
	dc.b	                                      " of LaceScan.",CR,LF
	dc.b	"Your LaceScan version uses a newer interface,",CR,LF
	dc.b	"that this emulator has no knowledge about.",CR,LF
	dc.b	"For reasons of safety, installation is refused.",CR,LF
	dc.b	"Please try a newer emulator version instead.",CR,LF
	dc.b	NUL
;
too_old_lace_s:
	dc.b	CR,LF
	dc.b	"This emulator was made for version "
	M_VERSION				;   x.y
	dc.b	                                      " of LaceScan.",CR,LF
	dc.b	"Your LaceScan version uses an older interface,",CR,LF
	dc.b	"that this emulator is not compatible with.",CR,LF
	dc.b	"For reasons of safety, installation is refused.",CR,LF
	dc.b	"Please update your LaceScan version.",CR,LF
	dc.b	NUL
;
press_key_s:
	dc.b	CR,LF
	dc.b	'Lace_Emu has failed to be installed!',CR,LF
	dc.b	'Press a key to continue boot.',CR,LF
	dc.b	NUL
;
message_s:
	dc.b	ESC,'q',ESC,'E'
	dc.b	CR,LF
	dc.b	CR,LF,ESC,'p'
	dc.b	" ------------------------------------- ",CR,LF
	dc.b	" LACE_EMU: Lace Emulator version: "
	M_VERSION				;  x.y
	dc.b	                                     "  ",CR,LF
	dc.b	" ------------------------------------- ",CR,LF
	dc.b	" (c)1994 Ulf Ronald Andersson          ",CR,LF
	dc.b	"         All rights reserved           ",CR,LF
	dc.b	" ------------------------------------- ",CR,LF
	dc.b	" Send ideas, requests, info on piracy, ",CR,LF
	dc.b	" bugs etc... to my home address:       ",CR,LF
	dc.b	"                                       ",CR,LF
	dc.b	"           U. R. Andersson             ",CR,LF
	dc.b	"           H”ders V„g 7                ",CR,LF
	dc.b	"           S-145 70 Norsborg           ",CR,LF
	dc.b	"           Sweden                      ",CR,LF
	dc.b	" ------------------------------------- ",CR,LF
	dc.b	ESC,'q'
cr_lf_s:
	dc.b	CR,LF
	dc.b	NUL
	even
;
info_head_s:
	dc.b	CR,LF
	dc.b	'Lace_Emu file "',NUL
info_good_s:
	dc.b	'" ',CR,LF
	dc.b	'was loaded without errors.',CR,LF
	dc.b	CR,LF,NUL
info_bad_s:
	dc.b	'" ',CR,LF,BEL
	dc.b	'contained some errors !!!',CR,LF,BEL
	dc.b	CR,LF,BEL,NUL
;
auto_inf_path_s:
	dc.b	'\AUTO\'
inf_path_s:
	dc.b	'LACE_EMU.INF'
	dc.b	NUL
	even
;
auto_def_path_s:
	dc.b	'\AUTO\'
def_path_s:
	dc.b	'LACE_EMU.DEF'
	dc.b	NUL
	even
;
xbralace_s:
	dc.l	'XBRA'
lace_s:
	dc.l	'Lace'
	dc.b	NUL
	even
;----------------------------------------------------------------------------
	section	BSS
;----------------------------------------------------------------------------
iz_stack:
	ds.b	1024
iz_stack_end:
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	LACE_EMU.S
;----------------------------------------------------------------------------
