;----------------------------------------------------------------------------
; File name:	LACESCAN.S			Revised:	1998.10.16
; Author:	Ulf Ronald Andersson		Created:	1992.02.13
; Credits:	Inspired by OVERSCAN.PRG by:
;  - " -	Karsten Isakovic, B. Gebauer, and R. Seitel
; Purpose:	Screen driver for Atari ST	Version:	4.0
;----------------------------------------------------------------------------
	include RA_STRUC.I
	include RA_SYS.I
	include RA_TOS.I
	include	RA_JAR.I
	include	RA_LA.I
	include	RA_XB.I
	include L_STRUCT.I
;----------------------------------------------------------------------------
lace_version	=	$0400		;version 4.0
frame_size	=	512
frame_limit	=	8
debug_keys	=	1		;enables debugging hotkeys '*'
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
	_unilab	rz	;relative zero for local ref's
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
;----------------------------------------------------------------------------
;	MACRO definitions
;----------------------------------------------------------------------------
set_mon	MACRO	modevar
	move	sr,-(sp)
	or	#$0700,sr
	bclr	#7,(hw_ddr).w
	btst	#1,\1
	bne.s	.need_mono_0
	btst	#7,(hw_gpip).w
	bne.s	.keep_bit
	bset	#7,(hw_ddr).w
	bset	#7,(hw_gpip).w
	bra.s	.keep_bit
;
.need_mono_0:
	btst	#7,(hw_gpip).w
	beq.s	.keep_bit
	bset	#7,(hw_ddr).w
	bclr	#7,(hw_gpip).w
.keep_bit:
	move	(sp)+,sr
	ENDM	;set_mon
;----------------------------------------------------------------------------
main_0:
	bra	main_1
lace_mark:
	dc.l	'Lace'
;----------------------------------------------------------------------------
;	LaceScan Parameter table
;
LPT:	dc.w	lace_version,interface_ver   ;new version, interface version
	dc.w	lpt_SCD,lpt_sizeof	     ;parm size, total structure size
	ds.b	lpt_SCD-4*2
;
conf_buff	=	LPT+lpt_SCD
;
SCD:	ds.b	sc_sizeof
SCREEN_tab:
;NB:	sc_reen_bytes = sc_bytewidth * sc_reen_lines
;NB:	sc_reen_lines may be somewhat boosted relative to physical format
;NB:	thus one may set height 410 in un-overscanned mono !!!
;-----------  00 = ST_L Normal ----------------------------------------------
	dc.w	320,200		;Xrez,Yrez
	dc.w	160,208		;line_bytes,reen_lines
	dc.l	32000,0		;reen_bytes,log_offs
	dc.w	$01,0		;def_mark,rez
	dc.b	-1,0		;emu_rez,hardc_f
	dc.b	0,0		;backg_f,intfx_f
	dc.w	320,200,4,160	;Emu Xrez,Yrez,planes,bytewid
;-----------  01 = ST_M Normal ----------------------------------------------
	dc.w	640,200		;Xrez,Yrez
	dc.w	160,208		;line_bytes,reen_lines
	dc.l	32000,0		;reen_bytes,log_offs
	dc.w	$01,1		;def_mark,rez
	dc.b	-1,0		;emu_rez,hardc_f
	dc.b	0,0		;backg_f,intfx_f
	dc.w	640,200,2,160	;Emu Xrez,Yrez,planes,bytewid
;-----------  02 = ST_H Normal ----------------------------------------------
	dc.w	640,400		;Xrez,Yrez
	dc.w	80,416		;line_bytes,reen_lines
	dc.l	32000,0		;reen_bytes,log_offs
	dc.w	$01,2		;def_mark,rez
	dc.b	-1,0		;emu_rez,hardc_f
	dc.b	0,0		;backg_f,intfx_f
	dc.w	640,400,1,80	;Emu Xrez,Yrez,planes,bytewid
;-----------  03 = Undefined ------------------------------------------------
	dc.w	0,0		;Xrez,Yrez
	dc.w	0,0		;line_bytes,reen_lines
	dc.l	0,0		;reen_bytes,log_offs
	dc.w	0,0		;def_mark,rez
	dc.b	0,0		;emu_rez,hardc_f
	dc.b	0,0		;backg_f,intfx_f
	dc.w	0,0,0,0		;Emu Xrez,Yrez,planes,bytewid
;-----------  04 = TT_M Normal ----------------------------------------------
	dc.w	640,480		;Xrez,Yrez
	dc.w	320,512		;line_bytes,reen_lines
	dc.l	153600,0	;reen_bytes,log_offs
	dc.w	$01,4		;def_mark,rez
	dc.b	-1,0		;emu_rez,hardc_f
	dc.b	0,0		;backg_f,intfx_f
	dc.w	640,480,4,320	;Emu Xrez,Yrez,planes,bytewid
;-----------  05 = Undefined ------------------------------------------------
	dc.w	0,0		;Xrez,Yrez
	dc.w	0,0		;line_bytes,reen_lines
	dc.l	0,0	;reen_bytes,log_offs
	dc.w	0,0		;def_mark,rez
	dc.b	0,0		;emu_rez,hardc_f
	dc.b	0,0		;backg_f,intfx_f
	dc.w	0,0,0,0		;Emu Xrez,Yrez,planes,bytewid
;-----------  06 = TT_H Normal ----------------------------------------------
	dc.w	1280,960	;Xrez,Yrez
	dc.w	160,1024	;line_bytes,reen_lines
	dc.l	153600,0	;reen_bytes,log_offs
	dc.w	$01,6		;def_mark,rez
	dc.b	-1,0		;emu_rez,hardc_f
	dc.b	0,0		;backg_f,intfx_f
	dc.w	1280,960,1,160	;Emu Xrez,Yrez,planes,bytewid
;-----------  07 = TT_L Normal ----------------------------------------------
	dc.w	320,480		;Xrez,Yrez
	dc.w	320,512		;line_bytes,reen_lines
	dc.l	153600,0	;reen_bytes,log_offs
	dc.w	$01,7		;def_mark,rez
	dc.b	-1,0		;emu_rez,hardc_f
	dc.b	0,0		;backg_f,intfx_f
	dc.w	320,480,8,320	;Emu Xrez,Yrez,planes,bytewid
;-----------  08 = ST_L Overscan --------------------------------------------
	dc.w	400,280		;Xrez,Yrez
	dc.w	236,310		;line_bytes,reen_lines
	dc.l	73160,6120	;reen_bytes,log_offs
	dc.w	-1,0		;def_mark,rez
	dc.b	-1,0		;emu_rez,hardc_f
	dc.b	1,$40		;backg_f,intfx_f
	dc.w	400,280,4,236	;Emu Xrez,Yrez,planes,bytewid
;-----------  09 = ST_M Overscan --------------------------------------------
	dc.w	800,280		;Xrez,Yrez
	dc.w	236,310		;line_bytes,reen_lines
	dc.l	73160,6120	;reen_bytes,log_offs
	dc.w	-1,1		;def_mark,rez
	dc.b	-1,0		;emu_rez,hardc_f
	dc.b	1,$40		;backg_f,intfx_f
	dc.w	800,280,2,236	;Emu Xrez,Yrez,planes,bytewid
;-----------  0A = ST_H Overscan --------------------------------------------
	dc.w	672,480		;Xrez,Yrez
	dc.w	100,520		;line_bytes,reen_lines
	dc.l	52000,2002	;reen_bytes,log_offs
	dc.w	-1,2		;def_mark,rez
	dc.b	-1,0		;emu_rez,hardc_f
	dc.b	1,$40		;backg_f,intfx_f
	dc.w	704,480,1,100	;Emu Xrez,Yrez,planes,bytewid
;-----------  0B = Undefined ------------------------------------------------
	dc.w	0,0		;Xrez,Yrez
	dc.w	0,0		;line_bytes,reen_lines
	dc.l	0,0		;reen_bytes,log_offs
	dc.w	0,0		;def_mark,rez
	dc.b	0,0		;emu_rez,hardc_f
	dc.b	0,0		;backg_f,intfx_f
	dc.w	0,0,0,0		;Emu Xrez,Yrez,planes,bytewid
;-----------  0C = TT_M Overscan --------------------------------------------
	dc.w	640,480		;Xrez,Yrez
	dc.w	320,512		;line_bytes,reen_lines
	dc.l	153600,0	;reen_bytes,log_offs
	dc.w	-1,4		;def_mark,rez
	dc.b	-1,0		;emu_rez,hardc_f
	dc.b	0,0		;backg_f,intfx_f
	dc.w	640,480,4,320	;Emu Xrez,Yrez,planes,bytewid
;-----------  0D = Undefined ------------------------------------------------
	dc.w	0,0		;Xrez,Yrez
	dc.w	0,0		;line_bytes,reen_lines
	dc.l	0,0		;reen_bytes,log_offs
	dc.w	0,0		;def_mark,rez
	dc.b	0,0		;emu_rez,hardc_f
	dc.b	0,0		;backg_f,intfx_f
	dc.w	0,0,0,0		;Emu Xrez,Yrez,planes,bytewid
;-----------  0E = TT_H Overscan --------------------------------------------
	dc.w	1280,960	;Xrez,Yrez
	dc.w	160,1024	;line_bytes,reen_lines
	dc.l	153600,0	;reen_bytes,log_offs
	dc.w	-1,6		;def_mark,rez
	dc.b	-1,0		;emu_rez,hardc_f
	dc.b	0,0		;backg_f,intfx_f
	dc.w	1280,960,1,160	;Emu Xrez,Yrez,planes,bytewid
;-----------  0F = TT_L Overscan --------------------------------------------
	dc.w	320,480		;Xrez,Yrez
	dc.w	320,512		;line_bytes,reen_lines
	dc.l	153600,0	;reen_bytes,log_offs
	dc.w	-1,7		;def_mark,rez
	dc.b	-1,0		;emu_rez,hardc_f
	dc.b	0,0		;backg_f,intfx_f
	dc.w	320,480,8,320	;Emu Xrez,Yrez,planes,bytewid
;-----------  10 = ST_L Overscan Normalized ---------------------------------
	dc.w	320,200		;Xrez,Yrez
	dc.w	236,310		;line_bytes,reen_lines
	dc.l	73160,15576	;reen_bytes,log_offs
	dc.w	-1,0		;def_mark,rez
	dc.b	-1,0		;emu_rez,hardc_f
	dc.b	0,$40		;backg_f,intfx_f
	dc.w	320,200,4,236	;Emu Xrez,Yrez,planes,bytewid
;-----------  11 = ST_M Overscan Normalized ---------------------------------
	dc.w	640,200		;Xrez,Yrez
	dc.w	236,310		;line_bytes,reen_lines
	dc.l	73160,15576	;reen_bytes,log_offs
	dc.w	-1,1		;def_mark,rez
	dc.b	-1,0		;emu_rez,hardc_f
	dc.b	0,$40		;backg_f,intfx_f
	dc.w	640,200,2,236	;Emu Xrez,Yrez,planes,bytewid
;-----------  12 = ST_H Overscan Normalized ---------------------------------
	dc.w	640,400		;Xrez,Yrez
	dc.w	100,520		;line_bytes,reen_lines
	dc.l	52000,3806	;reen_bytes,log_offs
	dc.w	-1,2		;def_mark,rez
	dc.b	-1,0		;emu_rez,hardc_f
	dc.b	0,$40		;backg_f,intfx_f
	dc.w	640,400,1,100	;Emu Xrez,Yrez,planes,bytewid
;-----------  13 = Undefined ------------------------------------------------
	dc.w	0,0		;Xrez,Yrez
	dc.w	0,0		;line_bytes,reen_lines
	dc.l	0,0		;reen_bytes,log_offs
	dc.w	0,0		;def_mark,rez
	dc.b	0,0		;emu_rez,hardc_f
	dc.b	0,0		;backg_f,intfx_f
	dc.w	0,0,0,0		;Emu Xrez,Yrez,planes,bytewid
;-----------  14 = TT_M Overscan Normalized ---------------------------------
	dc.w	640,480		;Xrez,Yrez
	dc.w	320,512		;line_bytes,reen_lines
	dc.l	153600,0	;reen_bytes,log_offs
	dc.w	-1,4		;def_mark,rez
	dc.b	-1,0		;emu_rez,hardc_f
	dc.b	0,0		;backg_f,intfx_f
	dc.w	640,480,4,320	;Emu Xrez,Yrez,planes,bytewid
;-----------  15 = Undefined ------------------------------------------------
	dc.w	0,0		;Xrez,Yrez
	dc.w	0,0		;line_bytes,reen_lines
	dc.l	0,0		;reen_bytes,log_offs
	dc.w	0,0		;def_mark,rez
	dc.b	0,0		;emu_rez,hardc_f
	dc.b	0,0		;backg_f,intfx_f
	dc.w	0,0,0,0		;Emu Xrez,Yrez,planes,bytewid
;-----------  16 = TT_H Overscan Normalized ---------------------------------
	dc.w	1280,960	;Xrez,Yrez
	dc.w	160,1024		;line_bytes,reen_lines
	dc.l	153600,0	;reen_bytes,log_offs
	dc.w	-1,6		;def_mark,rez
	dc.b	-1,0		;emu_rez,hardc_f
	dc.b	0,0		;backg_f,intfx_f
	dc.w	1280,960,1,160	;Emu Xrez,Yrez,planes,bytewid
;-----------  17 = TT_L Overscan Normalized ---------------------------------
	dc.w	320,480		;Xrez,Yrez
	dc.w	320,512		;line_bytes,reen_lines
	dc.l	153600,0	;reen_bytes,log_offs
	dc.w	-1,7		;def_mark,rez
	dc.b	-1,0		;emu_rez,hardc_f
	dc.b	0,0		;backg_f,intfx_f
	dc.w	320,480,8,320	;Emu Xrez,Yrez,planes,bytewid
;----------- XX -------------------------------------------------------------
	ds.b	(slot_limit-3*norm_slots)*sc_sizeof
;----------------------------------------------------------------------------
conf_size	= *-conf_buff
;----------------------------------------------------------------------------
main_1:
	move.l	4(sp),a5		;a5->basepage
	lea	init_stack_end(pc),sp
	lea	frame_p_tab(pc),a1
	lea	frame_base+frame_size(pc),a0
	moveq	#frame_limit-1,d0
iz_frame_lp:
	move.l	a0,(a1)+
	add	#frame_size,a0
	dbra	d0,iz_frame_lp
	bsr	link_local
	move.l	bp_bss_beg_p(a5),d0
	add.l	bp_bss_len(a5),d0
	sub.l	a5,d0
	gemdos	Mshrink,#0,(a5),d0
	gemdos	Super,0.w
	move.l	d0,-(sp)		;save old SSP on stack
;
	gemdos	Cconws,title_mess_s(pc)
	bsr	init_check_supx		;here most is initialized
	move	init_err_f(pc),d0
	tst	d0
	bne.s	not_ok
;
	gemdos	Dgetdrv
	lea	self_fpath_s(pc),a0
	add.b	d0,(a0)
	bsr	test_size_supx
	bsr	refix_supx
;
	bsr	patch_mouse
	and	lpt_setup_mask+LPT(pc),d0
	cmp	lpt_setup_keys+LPT(pc),d0
	bne.s	.use_selfset
	bsr	user_setup
	bra.s	.setup_done
;
.use_selfset:
	bsr	self_setup
.setup_done:
	bsr	unpatch_mouse
	sf	int_protect_f			;enable LaceScan interrupts
	bsr	clear_blit_sub
	bsr	copy_orig_screen
	gemdos	Cconws,installed_mess_s(pc)
;
	gemdos.1	Super,()		;restore old SSP
	bsr	unlk_local
	move.l	bp_bss_beg_p(a5),d0
	add.l	bp_bss_len(a5),d0
	sub.l	a5,d0
	gemdos	Ptermres,d0,#0
;
;
not_ok:
	gemdos	Cconws,clear_screen_ESC_s(pc)
	gemdos	Cconws,title_mess_s(pc)
	move	init_err_f(pc),d0
main_2:
	lea	bad_TOS_s(pc),a0
	cmpi	#2,d0
	beq.s	ask_return_Pterm_exit
	lea	already_in_s(pc),a0
	cmpi	#3,d0
	beq.s	ask_return_Pterm_exit
; error 4 (Auto_only) has been abolished
; error 5 (Bad_mpb) has been abolished
	lea	no_ram_s(pc),a0
	cmpi	#6,d0
	bne.s	Pterm_exit
ask_return_Pterm_exit:
	bsr	mess_press
Pterm_exit:
	gemdos.1	Super,()		;restore old SSP
	bsr	unlk_local
	gemdos	Pterm0
;
;
init_check_supx:
	move	sr,-(sp)
	movem.l	d0-d7/a0-a6,-(sp)
	move	#3,init_err_f		;prep err 3
	eval_cookie	#'Lace'
	bpl	exit_init_check
;
	moveq	#0,d3			;assume 68000 CPU as default
	eval_cookie	#'_CPU'		;get _CPU cookie
	bmi.s	.have_CPU		;go use default if no _CPU cookie
	move.l	d0,d3			;use the found _CPU value
.have_CPU:
	move.l	d3,_CPU_cookie		;store _CPU value
;
	moveq	#0,d3			;assume ST machine type as default
	eval_cookie	#'_MCH'		;get _MCH cookie
	bmi.s	.have_MCH		;go use default if no _MCH cookie
	move.l	d0,d3			;use the found _MCH value
.have_MCH:
	move.l	d3,_MCH_cookie		;store _MCH value
;
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
	lea	set_rez_ST(pc),a0	;a0 -> routine to set (hw_rez).w
	lea	get_rez_ST(pc),a1	;a1 -> routine to get (hw_rez).w
	cmp	#2*4,d0			;ST/STE VDO type ?
	blo.s	.have_mask_maxrez	;if so, go use ST/STE mask.maxrez
	move.l	#$70007,d1		;d1 = TT/F030 rez mask.maxrez
	moveq	#6,d2			;d2 = high_rez of TT
	lea	set_rez_TT(pc),a0	;a0 -> routine to set (hw_rez_tt).w
	lea	get_rez_TT(pc),a1	;a1 -> routine to get (hw_rez_tt).w
.have_mask_maxrez:
	move.l	d1,VDO_rez_mask_max	;store rez mask and max rez
	move	d2,VDO_high_rez		;store high_rez (for special monitor)
	move.l	a0,set_rez_p		;store -> routine to set hardware rez
	move.l	a1,get_rez_p		;store -> routine to get hardware rez
;
	_a_init		;LINE-A
	move.l	d0,line_a_base_p
;
	move	#2,init_err_f		;prep err 2
	eval_cookie	#'MiNT'
	move.l	d0,MiNT_ver
	eval_cookie	#'MagX'
	spl	MagX_f		;MagX_f = $0000(absent)  $FF00(present)
	move.l	d0,MagX_p
	xbios	Keytbl,-1.w,-1.w,-1.w
	move.l	d0,a0
	lea	-1(a0),a0	;NB: this assumes Kbshift stored at Keytbl-1
	move.l	a0,kbshift_p	;NB: which is used by ALL TOS older than 1.04
	move.l	(_sysbase).w,a1
	move.l	os_selfbeg_p(a1),a0
	move	os_version(a0),d0
	cmp	#$104,d0
	blo.s	.done_kbshift_p
	move.l	os_kbshift_p(a0),kbshift_p
.done_kbshift_p:
;
	cmp	#$102,d0
	blo.s	.found_ancient_TOS
	bhi.s	test_modern
	cmp	#$D3C1,$008A(a1)
	beq	TOS_taken
.found_ancient_TOS:
	st	ancient_TOS_f
	gemdos	Cconws,ancient_TOS_s(pc)
proceed_query_lp:
	gemdos	Crawcin
	and	#$DF,d0
	cmp	#'X',d0
	beq	exit_init_check
	cmp	#'P',d0
	bne.s	proceed_query_lp
	bra.s	TOS_taken
;
test_modern:
	tst	MagX_f
	bne.s	TOS_taken		;MagiX !
	cmp	#$104,d0		;TOS 1.04 or KAOS 1.4.x ?
	beq.s	TOS_taken
	cmp	#$106,d0		;TOS 1.06 ?
	beq.s	TOS_taken
	cmp	#$162,d0		;TOS 1.62
	beq.s	TOS_taken
	cmp	#$205,d0		;TOS 2.05 ?
	beq.s	TOS_taken
	cmp	#$206,d0		;TOS 2.06 ?
	beq.s	TOS_taken
	cmp	#$300,d0
	blo.s	.unknown_TOS
	cmp	#$307,d0
	blo.s	TOS_taken
	cmp	#$400,d0
	blo.s	.unknown_TOS
	cmp	#$405,d0
	blo.s	TOS_taken
.unknown_TOS:
	gemdos	Cconws,unknown_TOS_s(pc)
	bra.s	proceed_query_lp
;
VDO_max_size_t:
	dc.l	$12100,$8000,$28000,$28000	;ST,STE,TT,F030
;
TOS_taken:
	move.l	(_v_bas_ad).w,orig_screen_p
	move.l	line_a_base_p(pc),a0
	move.l	la_v_cur_xy(a0),orig_cur_xy
	move	la_v_rez_hz(a0),orig_rez_xy
	move	la_v_rez_vt(a0),orig_rez_xy+2
	move	la_bytes_lin(a0),orig_bytes_lin
	move	orig_bytes_lin(pc),d0
	mulu	orig_rez_xy+2(pc),d0		;d0 = original screen size
	move.l	d0,original_size		;store original_size
	move	VDO_l_index(pc),d0
	move.l	VDO_max_size_t(pc,d0.w),d0	;d0 = rounded size to lock
	move.l	d0,lockbase_size		;store lockbase_size
;
prot_screen:
	move.l	lockbase_size(pc),d0		;d0  = max size for a frame screen
	add.l	d0,d0				;we may need TWO of those screens
	sub.l	original_size(pc),d0		;d0  = growth size for screen
	ble.s	malloc_screen			;if growth negative, use malloc
.have_ram_need:
	lsr.l	#8,d0
	lsr	#2,d0
	lea	prot_struct(pc),a0
	clr.l	prot_ramloss(a0)
	move.l	(phystop).w,-(sp)		;save original phystop
	move	d0,-(sp)		;request d0 kilobytes
	bsr	protallo		;this reserves screen RAM
	addq	#2,sp
	move.l	(sp)+,d1		;d1 = old phystop
	move.l	d1,(phystop).w		;restore original phystop
	tst.l	d0
	beq.s	malloc_screen
	clr	init_err_f
	move.l	(_memtop).w,d0
	bra.s	init_lockbase_d0
;
malloc_screen:
	move	#6,init_err_f		;flag ram error
	move.l	lockbase_size(pc),a0
	adda	#$1FE,a0
	gemdos	Malloc,a0
	tst.l	d0
	ble	exit_init_check
	move.l	d0,lock_mem_p		;store memory block base
init_lockbase_d0:
	add.l	#$1FE,d0
	and	#-$200,d0
	move.l	d0,lockbase_p		;store unalterable screen base
	add.l	lockbase_size,d0
	move.l	d0,ext_base_p		;store extra screen base (interlace)
;
	move	#6,init_err_f		;flag ram error
	gemdos	Malloc,original_size(pc)
	tst.l	d0
	ble	exit_init_check
	move.l	d0,save_screen_p
;
	lea	blit_parm_t(pc),a6
	move.l	(_v_bas_ad).w,blt_s_form(a6)
	move.l	save_screen_p(pc),blt_d_form(a6)
	move	orig_bytes_lin(pc),d0
	move	d0,blt_s_nxln(a6)
	move	d0,blt_d_nxln(a6)
	bsr	orig_blit_sub		;save contents of original screen
	bsr	clear_blit_sub
	bsr	sync_lace_supx
;
	or	#$0700,sr		;disable interrupts until exit
	clr	init_err_f		;flag successful initialization
;
	tst	ancient_TOS_f
	bne.s	skip_scrollfix
	tst	MagX_f
	bne.s	skip_scrollfix		;no scroll_fix in Magix !
	bsr	install_scrollfix
skip_scrollfix:
;
	move.l	lockbase_p(pc),d0
	move.l	d0,lpt_lockbase_p+LPT	;store future screen base
	move.l	d0,lpt_physbase_p+LPT
	move.l	d0,logbphys_p
	move.l	d0,logbase_p
	xbios	Setscreen|_ind,d0,d0,#-1
	bsr	get_rez_sub		;d0 = hard rez code
	move	d0,hard_rez
	move	d0,mon_rez
	move.b	(sshiftmd).w,d0		;d0 = soft rez code
	move	d0,emu_rez
	addq	#norm_slots,d0		;d0 = prel rez slot code
	move	d0,lace_rez
	mulu	#sc_sizeof,d0
	lea	SCREEN_tab(pc),a0
	add.l	d0,a0				;a0 -> prel rez slot struct
	move.l	lpt_physbase_p+LPT(pc),d0	;d0 -> physical screen base
	add.l	sc_log_offs(a0),d0		;d0 -> log start of phys screen
	move.l	d0,logbase_p			;store d0 as logbase ptr
	lea	SCD(pc),a1			;a1 -> action slot
	REPT	sc_sizeof/4
	move.l	(a0)+,(a1)+			;copy slot to action slot
	ENDR
	st	fixed_rez		;flag no rez fixed yet
;
	bsr	test_size_supx
	bsr	refix_supx
	bsr	clear_blit_sub
;
;The CPU stack frame size is measured below
;
	move.l	(ev_trap5).w,a0
	move.l	#.do_trap,(ev_trap5).w
	move.l	sp,d0
	trap	#5				;process exception at .do_trap
.do_trap:
	sub.l	sp,d0			;d0 = frame size
	add	d0,sp			;sp = pre_exception SSP
	move	d0,stackframe_len	;store stackframe_len
	move.l	a0,(ev_trap5).w		;restore original trap5_handler
;
	lea	LPT(pc),a0
	moveq	#-1,d0
	move	d0,opnwk_rez
	move	d0,lpt_slot_req(a0)
	move	d0,lpt_screen_lock(a0)
	move	d0,lpt_phys_mask(a0)
	move	#$003F,lpt_setup_mask(a0)	;\/ Left Shift, alone
	move	#$0002,lpt_setup_keys(a0)	;/\ => LaceScan Setup
	lea	fix_pbase(pc),a1
	move.l	a1,lpt_fix_pbase(a0)
	lea	refix_d0(pc),a1
	move.l	a1,lpt_refix(a0)
	lea	lace_auto_sense(pc),a1
	move.l	a1,lpt_auto_sense(a0)
	lea	lace_auto_switch(pc),a1
	clr.l	lpt_reserve(a0)
	move.l	a1,lpt_auto_switch(a0)
	xbios	Iorec,#1
	move.l	d0,kb_iorec_p
;
	st	int_protect_f		;prevent premature interrupt work
	move	(nvbls).w,d0
	lsl	#2,d0			;d0 = word index for end of vblqueue
	move.l	(_vblqueue).w,a0	;a0 -> _vblqueue area
	moveq	#4,d1
.test_vbl_1:
	tst.l	0(a0,d1)
	beq.s	.keep_queue		;Keep _vblqueue if empty slot found
	addq	#4,d1
	cmp	d0,d1
	blo.s	.test_vbl_1		;check entire queue
	move	(nvbls).w,d3		;d3 = old entry limit
	move	d3,d4
	addq	#4,d4			;d4 = new entry limit (old+4)
	move	d4,d0
	lsl	#2,d0
	ext.l	d0			;d0 = long size of new _vblqueue
	gemdos	Malloc,d0		;Malloc new queue area
	move.l	(_vblqueue).w,a0	;a0 -> old queue area
	move.l	d0,a1			;a1 -> new queue area
	clr	d0			;d0 = index for first entry
.move_vbl_lp:
	move.l	0(a0,d0),0(a1,d0)
	addq	#4,d0			;d0 = index for next entry
	cmp	d3,d0
	blo.s	.move_vbl_lp
	move	d0,d1			;d1 = word index for new entry
	move.l	a1,a0			;a0 = a1 -> new queue
	move.l	a1,(_vblqueue).w	;set new queue
	move	d4,(nvbls).w		;set new queue size
.keep_queue:
;d1 =  word index for new long entry in _vblqueue
;a0 -> _vblqueue, which may be original or new
	lea	nu_vbl_sub+12(pc),a1	;\ link nu_vbl_sub into vblqueue
	move.l	a1,0(a0,d1)		;/
	lea	nu_GEMDOS+8(pc),a1	;\
	move.l	(ev_gemdos).w,(a1)+	; > link nu_GEMDOS into ev_gemdos chain
	move.l	a1,(ev_gemdos).w	;/
	lea	nu_xbios+8(pc),a1	;\
	move.l	(ev_xbios).w,(a1)+	; > link nu_xbios into ev_xbios chain
	move.l	a1,(ev_xbios).w		;/
	lea	nu_LINE_A+8(pc),a1	;\
	move.l	(ev_a_line).w,(a1)+	; > link nu_LINE_A into ev_a_line chain
	move.l	a1,(ev_a_line).w	;/
	lea	nu_scr_dump+8(pc),a1	;\
	move.l	(scr_dump).w,(a1)+	; > link nu_scr_dump into scr_dump chain
	move.l	a1,(scr_dump).w		;/
	lea	nu_XGEM+8(pc),a1	;\
	move.l	(ev_xgem).w,(a1)+	; > link nu_XGEM into ev_xgem chain
	move.l	a1,(ev_xgem).w		;/
	lea	swv_vec_XB+8(pc),a1	;\
	move.l	(swv_vec).w,(a1)+	; > link swv_vec_XB into swv_vec chain
	move.l	a1,(swv_vec).w		;/
	xbios	Kbdvbase
	move.l	d0,a0
	lea	kv_ikbd_vec(a0),a0	;a0 = ikbd_vec
	lea	nu_ikbd_vec+8(pc),a1	;\
	move.l	(a0),(a1)+		; > link nu_ikbd_vec into ikbd_vec chain
	move.l	a1,(a0)			;/
	make_cookie	#'Lace',#LPT
	move.l	(_frclock).w,shsh_worktime
	clr	rez_lock_f
exit_init_check:
	movem.l	(sp)+,d0-d7/a0-a6
	move	(sp)+,sr
	rts
;----------------------------------------------------------------------------
;End of:	Init test routine
;----------------------------------------------------------------------------
;		XGEM functions with XBRA
;----------------------------------------------------------------------------
	dc.l		'LPT:',LPT
	XB_define	nu_XGEM,'Lace'
	cmpi	#$73,d0		;VDI call ?
	bne.s	go_old_XGEM	;if not VDI, old GEM
	move.l	d1,a0		;a0->vdipb
	move.l	(a0),a0		;a0->contrl
;
	cmp	#$6D,(a0)	;vro_cpyfm ?
	bge.s	.test_GE_6D
	cmp	#2,(a0)		;v_clswk ?
	bhi.s	go_old_XGEM
	beq	nu_v_clswk
	cmp	#1,(a0)		;v_opnwk ?
	beq.s	nu_v_opnwk
	XB_gonext_d	nu_XGEM(pc)
;
;
.test_GE_6D:
	beq.s	nu_vro_cpyfm
	cmp	#$79,(a0)	;vrt_cpyfm ?
	beq.s	nu_vrt_cpyfm
go_old_XGEM:
	XB_gonext_d	nu_XGEM(pc)
;
;
nu_vro_cpyfm:
	tst	MagX_f
	bne.s	go_old_XGEM		;no vro_cpyfm patch for MagiX
	movem.l	d0/a1,-(sp)
	move.l	14(a0),a1
	move.l	(a1),d0
	cmp.l	(_v_bas_ad).w,d0
	bne.s	.s_form_ok
	clr.l	(a1)
.s_form_ok:
	move.l	18(a0),a1
	move.l	(a1),d0
	cmp.l	(_v_bas_ad).w,d0
	bne.s	.d_form_ok
	clr.l	(a1)
.d_form_ok:
	movem.l	(sp)+,d0/a1
	XB_gonext_d	nu_XGEM(pc)
;
;
nu_vrt_cpyfm:
	tst	MagX_f
	bne.s	go_old_XGEM		;no vrt_cpyfm patch for MagiX
	movem.l	d0/a1,-(sp)
	move.l	14(a0),a1
	move.l	(a1),d0
	cmp.l	(_v_bas_ad).w,d0
	bne.s	.s_form_ok
	clr.l	(a1)
.s_form_ok:
	move.l	18(a0),a1
	move.l	(a1),d0
	cmp.l	(_v_bas_ad).w,d0
	bne.s	.d_form_ok
	clr.l	(a1)
.d_form_ok:
	movem.l	(sp)+,d0/a1
	XB_gonext_d	nu_XGEM(pc)
;
;
nu_v_opnwk:
	bsr	link_local
	movem.l	d0-d7/a0-a6,-(sp)
;
	move.l	d1,a0			;a0->vdipb
	move.l	12(a0),intout_p
	move.l	4(a0),a0		;a0->intin
	move.l	a0,intin_p
	cmp	#10,(a0)		;device < 10 ? (2..4/5..9 == rez 0..2/3..7)
	bhs	go_old_XGEM		;else go old GEM (probably GDOS)
	st	opnwk_flag		;Mark opnwk_flag
;
;This segment ensures a valid dev_code in intin[0]  (at (a0))
	move	VDO_b_index(pc),d0	;\
	mulu	#10,d0			; > d0 = 10*VDO_index + dev_code
	add	(a0),d0			;/
	move.b	.dev_code_t(pc,d0),d0
	bpl.s	.force_d0	;go force valid dev_code d0
.force_soft:			;else force dev_code by current software rez
	move	VDO_high_rez(pc),d1	;d1 = rez code for 'special-mon'
	move	d1,d0
	addq	#2,d0			;d0 = dev code for 'special-mon'
	cmp.b	(sshiftmd).w,d1		;is active mode for 'special-mon' ?
	beq.s	.force_d0		;then go use its dev code as-is
	move.b	(defshiftmd).w,d0	;d0 = default rez for 'normal-mon'
	addq	#2,d0			;d0 = default dev for 'normal-mon'
.force_d0:
	move	d0,(a0)		;force dev_code intin[0] = d0
	bra.s	.dev_code_valid
;
.dev_code_t:		;ST valid resolutions
	dc.b	-1,-1		;dev_code 0 & 1 are undefined
	dc.b	2,3,4		;dev_code 2..4 == ST rez 0..2
	dc.b	-1		;dev_code 5 == rez 3 == gfx board rez 1
	dc.b	2		;dev_code 6 == rez 4 == TT medium (emu in ST low)
	dc.b	-1		;dev_code 7 == rez 5 == gfx board rez 2
	dc.b	4		;dev_code 8 == rez 6 == TT high (emu in ST high)
	dc.b	2		;dev_code 9 == rez 7 == TT low rez (emu in ST low)
.dev_code_t_1:		;STE valid resolutions
	dc.b	-1,-1		;dev_code 0 & 1 are undefined
	dc.b	2,3,4		;dev_code 2..4 == ST rez 0..2
	dc.b	-1		;dev_code 5 == rez 3 == gfx board rez 1
	dc.b	2		;dev_code 6 == rez 4 == TT medium (emu in ST low)
	dc.b	-1		;dev_code 7 == rez 5 == gfx board rez 2
	dc.b	4		;dev_code 8 == rez 6 == TT high (emu in ST high)
	dc.b	2		;dev_code 9 == rez 7 == TT low rez (emu in ST low)
;
.dev_code_t_2:		;TT valid resolutions
	dc.b	-1,-1		;dev_code 0 & 1 are undefined
	dc.b	2,3,4		;dev_code 2..4 == ST rez 0..2
	dc.b	-1		;dev_code 5 == rez 3 == gfx board rez 1
	dc.b	6		;dev_code 6 == rez 4 == TT medium (emu in ST low)
	dc.b	-1		;dev_code 7 == rez 5 == gfx board rez 2
	dc.b	8		;dev_code 8 == rez 6 == TT high (emu in ST high)
	dc.b	9		;dev_code 9 == rez 7 == TT low rez (emu in ST low)
;
.dev_code_t_3:		;F030 valid resolutions
	dc.b	-1,-1		;dev_code 0 & 1 are undefined
	dc.b	2,3,4		;dev_code 2..4 == ST rez 0..2
	dc.b	-1		;dev_code 5 == rez 3 == gfx board rez 1
	dc.b	6		;dev_code 6 == rez 4 == TT medium (emu in ST low)
	dc.b	-1		;dev_code 7 == rez 5 == gfx board rez 2
	dc.b	8		;dev_code 8 == rez 6 == TT high (emu in ST high)
	dc.b	9		;dev_code 9 == rez 7 == TT low rez (emu in ST low)
;
.dev_code_valid:
;
	tst.b	opnwk_flag+1
	bne.s	.done_initial
;code here will execute only at initial v_opnwk
	cmp	#2,VDO_b_index		;TT or better ?
	bhi.s	.done_forcing		;F030 should not need forcing here
	move	VDO_high_rez(pc),d2
	move.b	(sshiftmd).w,d1		;d1 = soft rez active
	move	(a0),d0			;d0 = dev_code from intin[0]
	subq	#2,d0			;d0 = rez code
	cmp	d2,d0			;is d0 the 'special-mon' rez ?
	beq.s	.want_special_mon
.want_normal_mon:
	cmp.b	d2,d1			;is current rez for 'special-mon'
	beq	.force_soft		;if so, we need to force the rez
	bra.s	.done_forcing
;
.want_special_mon:
	cmp.b	d2,d1			;is current rez for 'special-mon'
	bne	.force_soft		;if not, we need to force the rez
.done_forcing:
.done_initial:
;
	bsr	test_size_supx
	bsr	patch_mouse
	and	lpt_setup_mask+LPT(pc),d0
	cmp	lpt_setup_keys+LPT(pc),d0	;LaceScan setup request ?
	bne.s	.auto_setup			;else go .auto_setup
;start lacescan setup sequence, always using HARD rez
	move.l	intin_p(pc),a0
	bsr	get_rez_sub		;d0 = hard rez code
	addq	#2,d0			;d0 = active hard dev code
	move	d0,(a0)			;force dev_code to follow hard rez
	subq	#2,d0			;d0 = slot_code = hardware rez
	add	#norm_slots,d0		;translate slot_code to slot_pos
	cmp	#slot_limit,d0
	blo.s	.set_lace_1
	sub	#slot_limit,d0	;fix rez_codes 0..3 for slot_codes 13..15
.set_lace_1:
	move	d0,lace_rez
	st	fixed_rez
	bsr	refix_supx
	bsr	user_setup
	move	lace_rez(pc),d0
	sub	#norm_slots,d0
	bpl.s	.set_opnwk_slot_1
	add	#slot_limit,d0
.set_opnwk_slot_1:
	move	d0,opnwk_slot
	bra.s	.done_setup
;
.auto_setup:
	move.l	lpt_opnwk_lk_1+LPT(pc),d0
	ble.s	.done_emu_opnwk_1
	move.l	d0,a1
	movem.l	(sp),d0-d1		;revive entry d0-d1, but leave them on stack
	move.l	intin_p(pc),a0		;a0 -> intin == workin -> screen_id...
	jsr	(a1)			;call emulator: a0->intin=work_in d1->vdipb
;Here emulator may have changed the dev request !
.done_emu_opnwk_1:
	move	lpt_slot_req+LPT(pc),d0
	bpl.s	.set_rez_2
	move.l	intin_p(pc),a0
	move	(a0),d0
	subq	#2,d0
	blo.s	.force_rez_2
	cmp	#norm_slots,d0
	blo.s	.set_rez_2
.force_rez_2:
	bsr	get_rez_sub		;d0 = hard rez code
.set_rez_2:
	move	d0,opnwk_slot
	add	#norm_slots,d0
	cmp	#slot_limit,d0
	blo.s	.set_lace_2
	sub	#slot_limit,d0
.set_lace_2:
	move	d0,lace_rez
.done_setup:
	bsr	unpatch_mouse
;
	lea	SCREEN_tab(pc),a0	;a0 -> screen slot structure table
	move	lace_rez(pc),d0
	asl	#sc_log2size,d0		;d0 = index for requested slot
	lea	(a0,d0),a0		;a0 -> requested slot data
	clr	d0
	move.b	sc_emu_rez(a0),d0
	bpl.s	.have_opnwk_rez
	move	sc_rez(a0),d0
.have_opnwk_rez:
	move	d0,opnwk_rez
;
	move	sc_rez(a0),d0
	bsr	set_rez_sub		;hard rez code = d0
	bsr	sync_fall_supx
;
	bsr	test_size_supx
	st	fixed_rez
	bsr	refix_supx
	bsr	fix_la_workout
	move	emu_rez(pc),d0
	add	#2,d0
	move.l	intin_p(pc),a0
	move	d0,(a0)			;patch device code
;
	movem.l	(sp),d0-d7/a0-a6	;revive all registers, but keep them stacked
;
	tst	(_longframe).w
	beq.s	.done_frame
	clr	-(sp)
.done_frame:
	pea	.end_v_opnwk
	move	SR,-(sp)
	moveq	#$73,d0
	XB_gonext_d	nu_XGEM(pc)	;link to next v_opnwk routine in chain
;
.end_v_opnwk:
	bsr	fix_v_fnt_ad
	bsr	sync_lace_supx
	bsr	refix_supx
	bsr	fix_la_workout
	move.l	intout_p(pc),a0
	move.l	line_a_base_p(pc),a1
	lea	la_wk_xmax(a1),a1
	move.l	(a1),(a0)		;max X,Y coords
	move.l	6(a1),6(a0)		;pixel width,height
	move	26(a1),26(a0)		;palette registers
	move	70(a1),70(a0)		;colour flag
	move	78(a1),78(a0)		;palette colours
	bsr	clear_screen_supx
;
;Below we call emulator, to allow it to complete its initialization
	move.l	lpt_opnwk_lk_2+LPT(pc),d0
	ble.s	.done_emu_opnwk_2
	move.l	d0,a2
	jsr	(a2)		;call with a0,a1 -> gem,line_a work_out
.done_emu_opnwk_2:
	or	#$0081,opnwk_flag	;flag opnwk as new and old
	sf	opnwk_flag
	movem.l	(sp)+,d0-d7/a0-a6
	bsr	unlk_local
	rte
;------------------------------------
nu_v_clswk:		;closing workstation, reinit some data
	moveq	#-1,d0
	move	d0,lpt_screen_lock+LPT	;re_enable screen locking
	move	d0,lpt_phys_mask+LPT	;re_enable physbase masking
	moveq	#$73,d0
	XB_gonext_d	nu_XGEM(pc)
;------------------------------------
send_ikbd_sub:
	clr	d0
	move.b	(a0)+,d0
	xbios	Ikbdws,d0,(a0)
	rts
;------------------------------------
send_ikbd	MACRO	string
	lea	\1,a0
	bsr	send_ikbd_sub
	ENDM	send_ikbd
;------------------------------------
status_ikbd_sub:
	clr	d0
	move.b	(a0)+,d0
	move.l	#-1,ik_status_t
	xbios	Ikbdws,d0,(a0)
	lea	ik_status_t(pc),a0
.await_ik_stat_lp:
	cmp.l	#-1,(a0)
	beq.s	.await_ik_stat_lp
	clr	d0
	move.b	(a0),d0
	rts
;------------------------------------
status_ikbd	MACRO	string
	lea	\1,a0
	bsr	status_ikbd_sub
	ENDM	status_ikbd
;------------------------------------
patch_mouse:
	movem.l	d1-d2/a0-a2,-(sp)
	xbios	Kbdvbase
	move.l	d0,a0
	move.l	12(a0),nu_ik_stat+8	;save -> status packet handler
	move.l	#nu_ik_stat+12,12(a0)
	move.l	16(a0),nu_mouse+8	;save -> mouse packet handler
	move.l	#nu_mouse+12,16(a0)
	move	sr,d0
	move	d0,patch_mouse_SR
	and	#$0700,d0
	cmp	#$0600,d0
	blo.s	.interrupts_ok
	move	sr,d0
	and	#$F8FF,d0
	or	#$0500,d0
	move	d0,sr			;enable MFP interrupts
.interrupts_ok:
	status_ikbd	stop_mouse_status_ikbd(pc)
	move.b	d0,stop_mouse_f
	cmp.b	#$12,d0			;$12 means mouse was stopped
	beq.s	.need_start
	status_ikbd	start_mouse_status_ikbd(pc)
	move.b	d0,start_mouse_f
	cmp.b	#$08,d0
	beq.s	.have_start
.need_start:
	send_ikbd	start_mouse_ikbd(pc)
.have_start:
	clr	lace_mouse_bt
	send_ikbd	fast_mouse_ikbd(pc)
	send_ikbd	norm_mouse_ikbd(pc)
.wait_mouse:
	move	lace_mouse_bt(pc),d0	;d0 = $00 or ikbd code $F8..FB
	beq.s	.wait_mouse		;await ikbd mouse response
	xbios	Vsync
	xbios	Vsync
	bios	Kbshift,#-1
	move	d0,d1
	move	lace_mouse_bt(pc),d0
	and	#3,d0			;bits 1,0 = left,right mouse buttons
	asl	#4,d0			;shift buttons to bits 5,4
	and	#$0F,d1			;mask keys to bits 3..0
	or	d1,d0			;combine with mouse buttons to 6 bits
	movem.l	(sp)+,d1-d2/a0-a2
	rts
;------------------------------------
unpatch_mouse:
	movem.l	d1-d2/a0-a2,-(sp)
	cmp.b	#$12,stop_mouse_f
	bne.s	.skip_stop
	send_ikbd	stop_mouse_ikbd(pc)
.skip_stop:
	xbios	Kbdvbase
	move.l	d0,a0
	move.l	nu_mouse+8(pc),16(a0)	;restore -> mouse packet handler
	move.l	nu_ik_stat+8(pc),12(a0)	;restore -> status packet handler
	move	patch_mouse_SR(pc),sr	;restore pre_patch interrupt mask
	movem.l	(sp)+,d1-d2/a0-a2
	rts
;------------------------------------
fix_v_fnt_ad:
	movem.l	a0/a1,-(sp)
	move.l	line_a_base_p(pc),a0
	tst	la_v_cel_ht(a0)
	bne.s	.keep_vt52_font
	move.l	la_def_font(a0),a1
	move.l	fnt_fbase(a1),la_v_fnt_ad(a0)
	move	fnt_lasc(a1),la_v_fnt_st(a0)
	move	fnt_hasc(a1),la_v_fnt_nd(a0)
	move	fnt_fwidth(a1),la_v_fnt_wd(a0)
	move.l	fnt_chr_tp(a1),la_v_off_ad(a0)
	move	fnt_fheight(a1),la_v_cel_ht(a0)
.keep_vt52_font:
	movem.l	(sp)+,a0/a1
	rts
;------------------------------------
fix_la_workout:
	movem.l	d0-d1/a1,-(sp)
	move	SR,-(sp)		;push interrupt mask
	or	#$0700,SR		;disable interrupts
	move.l	line_a_base_p(pc),a1
	lea	la_wk_xmax(a1),a1
	move.l	sc_emu_Xrez+SCD(pc),d0
	sub.l	#$00010001,d0
	move.l	d0,(a1)		;max X,Y coords
	move	sc_emu_planes+SCD(pc),d1
	move	d1,la_planes-la_wk_xmax(a1)
	move	d1,la_inq_tab+8-la_wk_xmax(a1)
	cmp	#1,d1
	beq.s	.fix_mono
.fix_colour:
	move	#1,70(a1)	;colour flag
	move	#512,78(a1)	;palette colours
	bra.s	.done_colour
;
.fix_mono:
	clr	70(a1)		;colour flag
	move	#2,78(a1)	;palette colours
.done_colour:
	moveq	#1,d0
	asl	d1,d0
	move	d0,26(a1)			;palette registers
	move	emu_rez(pc),d0
	asl	#2,d0
	move.l	pix_size_t(pc,d0.w),6(a1)	;store pixel sizes
;
	move	(sp)+,SR	;pull interrupt mask
	movem.l	(sp)+,d0-d1/a1
	rts
;
pix_size_t:
	dc.l	$22C022C,$116022C,$1160116,$1160116
	dc.l	$1160116,$1160116,$08B008B,$22C0116
;----------------------------------------------------------------------------
;End of:	XGEM functions with XBRA
;----------------------------------------------------------------------------
;		Mouse packet patch with XBRA
;----------------------------------------------------------------------------
;
	XB_define	nu_mouse,'Lace'
	movem.l	d0/a0/a1,-(sp)
	move.l	16(sp),a0
	cmp.b	#$F8,(a0)
	blo.s	.go_old_mouse
	cmp.b	#$FC,(a0)
	bhs.s	.go_old_mouse
	move.b	(a0),d0
	move	d0,lace_mouse_bt
	asl	#1,d0
	bclr	#2,d0
	beq.s	.done_lmb
	bset	#0,d0
.done_lmb:
	move.l	line_a_base_p(pc),a1
	and	#3,d0
	move	d0,la_mouse_bt(a1)
.go_old_mouse:
	movem.l	(sp)+,d0/a0/a1
	XB_gonext_d	nu_mouse(pc)
;
;----------------------------------------------------------------------------
;End of:		Mouse packet patch with XBRA
;----------------------------------------------------------------------------
;		Status packet patch with XBRA
;----------------------------------------------------------------------------
;
	XB_define	nu_ik_stat,'Lace'
	movem.l	a0/a1,-(sp)
	move.l	12(sp),a0
	lea	ik_status_t(pc),a1
	move.b	(a0)+,(a1)+	;v0   = active function code (or zero)
	move.b	(a0)+,(a1)+	;v1
	move.b	(a0)+,(a1)+	;v2
	move.b	(a0)+,(a1)+	;v3
	move.b	(a0)+,(a1)+	;v4
	move.b	(a0)+,(a1)+	;v5
	move.b	(a0)+,(a1)+	;v6
	movem.l	(sp)+,a0/a1
	XB_gonext_d	nu_ik_stat(pc)
;
;----------------------------------------------------------------------------
;End of:		Status packet patch with XBRA
;----------------------------------------------------------------------------
;		GEMDOS functions with XBRA
;----------------------------------------------------------------------------
user_called_gemdos:
	move.l	USP,a0
	bra.s	have_gemdos_args_a0
;-------
	dc.l		'LPT:',LPT
	XB_define	nu_GEMDOS,'Lace'
;-------
	btst	#5,(sp)
	beq.s	user_called_gemdos
	move.l	sp,a0
	adda	stackframe_len(pc),a0
have_gemdos_args_a0:
	move	(a0),d0			;d0 = function opcode
	move.b	gemdos_f_t(pc,d0),d0	;d0 = implementation flag of function
	bne.s	nu_gemdos_funcs		;if implemented, go to internal func
	XB_gonext_a0	nu_GEMDOS(pc)	;exit with minimum delay for unimplemented ops
;-------
Pexec_f_t:
	dc.b	1,0,0,0,1,0,1,0		;we only want modes which start programs
;-------
nu_gemdos_funcs:
	cmp	#END_GEMDOS_F,(a0)	;was the opcode too high for our table
	bhs.s	go_old_gemdos		;if so, we got here by mistake...
.prog_change_test:			;Here for Pexec, Pterm, Pterm0, Ptermres
	subq.b	#1,d0			;Pexec ?  (it uses index 0 in the table)
	bne.s	.prog_change_fix	;if not, then it must be some Pterm...
	move	2(a0),d0		;d0 = Pexec mode
	cmp	#6,d0			;new exotic mode ?
	bhi.s	go_old_gemdos		;if so, skip these fixes
	move.b	Pexec_f_t(pc,d0),d0	;is it one we want (0,4,6)
	beq.s	go_old_gemdos		;if not, skip these fixes
.prog_change_fix:			;Here to fix screen for program switch
	move	SR,d0
	or	#$0700,SR
	bsr	link_local		;allocate local area for super stack
	move	d0,SR
	movem.l	d0-d7/a0-a6,-(sp)
;-------
	bsr	test_size_supx
	move	SR,-(sp)
	or	#$0700,SR
	bclr	#7,opnwk_flag+1
	beq.s	.done_font
	bsr	fix_v_fnt_ad
.done_font:
	st	prev_slot
	bsr	refix_supx
	bsr	fix_la_workout
	move	(sp)+,SR
	bsr	blank_border_supx
	movem.l	(sp)+,d0-d7/a0-a6
	move	SR,d0
	or	#$0700,SR
	bsr	unlk_local		;release local super stack
	move	d0,SR
go_old_gemdos:
	XB_gonext_a0	nu_GEMDOS(pc)
;-------
gemdos_f_t:
	dc.b	2,0,0,0,0,0,0,0		;$00-$07 includes Pterm0
	dc.b	0,0,0,0,0,0,0,0		;$08-$0F
	dc.b	0,0,0,0,0,0,0,0		;$10-$17
	dc.b	0,0,0,0,0,0,0,0		;$18-$1F
	dc.b	0,0,0,0,0,0,0,0		;$20-$27
	dc.b	0,0,0,0,0,0,0,0		;$28-$2F
	dc.b	0,2,0,0,0,0,0,0		;$30-$37 includes Ptermres
	dc.b	0,0,0,0,0,0,0,0		;$38-$3F
	dc.b	0,0,0,0,0,0,0,0		;$40-$47
	dc.b	0,0,0,1,2,0,0,0		;$48-$4F includes Pexec, Pterm
	dcb.b	256,0			;$50-$14F are not implemented in LaceScan
END_GEMDOS_F	=	*-gemdos_f_t
;----------------------------------------------------------------------------
;End of:	GEMDOS functions with XBRA
;----------------------------------------------------------------------------
;		XBIOS functions with XBRA
;----------------------------------------------------------------------------
user_called_xbios:
	move.l	USP,a0
	bra.s	have_xbios_args_a0
;-------
	dc.l		'LPT:',LPT
	XB_define	nu_xbios,'Lace'
nu_xbios_entry:
	btst	#5,(sp)
	beq.s	user_called_xbios
	move.l	sp,a0
	adda	stackframe_len(pc),a0
have_xbios_args_a0:
	move	(a0),d0			;d0 = function opcode
	move.b	xbios_f_t(pc,d0),d0	;d0 = implementation flag of function
	bne.s	nu_xbios_funcs		;if implemented, go to internal func
go_old_xbios:
	XB_gonext_a0	nu_xbios(pc)	;exit with minimum delay for unimplemented ops
;-------
nu_xbios_funcs:
	cmp	#END_XBIOS_F,(a0)	;was the opcode too high for our table
	bhs.s	go_old_xbios		;if so, we got here by mistake...
	and	#$FF,d0			;eliminate high bits of jump table index
	move.l	xbios_p_t(pc,d0),-(sp)	;push -> function code
	rts				;go to function code
;-------
xbios_p_t:
	dc.l	go_old_xbios		;this index, 0, is not used
	dc.l	xbios_Physbase		;index 1 => Physbase
	dc.l	xbios_Getrez		;index 2 => Getrez
	dc.l	xbios_Setscreen		;index 3 => Setscreen
	dc.l	xbios_Setpalette	;index 4 => Setpalette
	dc.l	xbios_Vsync		;index 5 => Vsync
	dc.l	xbios_EsetShift		;index 6 => EsetShift
;-------
xbios_f_t:
	dcb.b	2,0			;$00-$01 are not used
	dc.b	1*4			;--- $02 = Physbase using long index 1
	dcb.b	1,0			;$03-$03 are not used
	dc.b	2*4			;--- $04 = Getrez using long index 2
	dc.b	3*4			;--- $05 = Setscreen using long index 3
	dc.b	4*4			;--- $06 = Setpalette using long index 4
	dcb.b	$25-$07			;$07-$24 are not used
	dc.b	5*4			;--- $25 = Vsync using long index 5
	dcb.b	$50-$26			;$26-$4F are not used
	dc.b	6*4			;--- $50 = EsetShift using long index 6
LIM_XBIOS_F	=	*-xbios_f_t
	dcb.b	256-LIM_XBIOS_F,0	;$51-$FF are not implemented in LaceScan
END_XBIOS_F	=	*-xbios_f_t
;------------------------------------
xbios_Vsync:
	bsr	sync_fall_supx
	rte
;------------------------------------
xbios_Getrez:
	clr.l	d0
	move	emu_rez(pc),d0
	rte
;------------------------------------
xbios_Physbase:
	eval_cookie	#'MiNT'
	move.l		d0,MiNT_ver
	move.l	lpt_emu_phys_p+LPT(pc),d0
	tst	lpt_emu_type_ix+LPT
	bne.s	.done_physbase			;emulation => emulated physbase
	move.l	lpt_physbase_p+LPT(pc),d0	;get real physbase
	move	lpt_phys_mask+LPT(pc),d1
	beq.s	.done_physbase			;skip masking if it is disabled
	move	lacesize_f(pc),d1
	beq.s	.done_offset			;skip masking in old modes
	add.l	sc_log_offs+SCD(pc),d0		;mask physbase to logbase equivalent
.done_offset:
	tst	d1
	bne.s	.done_physbase	;skip kludge in overscan modes
	btst	#0,opnwk_flag+1
	bne.s	.done_physbase	;skip kludge after desktops initial init
	tst	MiNT_ver
	bmi.s	.done_physbase	;avoid MiNT without MiNT
	or.l	#$10000000,d0	;Force MiNT to leave screen alone
.done_physbase:
	rte
;------------------------------------
xbios_Setpalette:
	tst.b	opnwk_flag
	beq.s	go_old_xbios_2
	move.l	2(a0),-(sp)
	move	#Setpalette&$FF,-(sp)
	push_ex	fixed_palette(pc)
go_old_xbios_2:
	XB_gonext_a0	nu_xbios(pc)
;
fixed_palette:
	addq	#6,sp
	move	opnwk_slot(pc),-(sp)
	moveq	#-1,d0
	move.l	d0,-(sp)
	move.l	d0,-(sp)
	move	#Setscreen&$FF,-(sp)
	push_ex	fixed_setpalscreen(pc)
	bra	nu_xbios_entry
;
fixed_setpalscreen:
	lea	12(sp),sp		;clean stack
	rte
;------------------------------------
xbios_EsetShift:
	move	2(a0),d0
	bmi	go_old_xbios
	move	(hw_rez_tt).w,-(sp)
	lsr	#8,d0
	and	#7,d0
	move	d0,-(sp)
	moveq	#-1,d0
	move.l	d0,-(sp)
	move.l	d0,-(sp)
	move	#Setscreen&$FF,-(sp)
	push_ex	fixed_EsetShift(pc)
	bra	nu_xbios_entry
;
fixed_EsetShift:
	lea	12(sp),sp		;clean stack
	move	(sp)+,d0		;return old value of (hw_rez_tt).w
	rte
;------------------------------------
xbios_Setscreen:
	clr.l	setscr_flags
	bsr	test_size_supx
	bsr	fix_screen_supx		;fix old screen parameters
	bset	#setscreen_b,int_protect_f
	bset	#setscreen_b,rez_lock_f	;lock rez variables (home_emu_f)
.calc_rez:
	move	lace_rez(pc),setscr_rez	;preliminarily assume kept rez
	move	10(a0),d0		;d0 = slot_code from argument
	bmi.w	.ready_rez		;keep old slot if argument negative
	btst	#user_setup_b,int_protect_f
	bne.s	.done_slot_req		;skip defaulting on user setup
	tst.b	opnwk_flag
	beq.s	.test_arg_slot		;test argument if not called by v_opnwk
	st	setscr_flags+2		;Note rez update need for v_opnwk
	move	opnwk_slot(pc),d0
	bra.s	.done_slot_req
;
.test_arg_slot:
	cmp	#slot_limit,d0		;codes $20..$3F enforce new slot
	blo.s	.test_def_slot
.force_rez:
	st	setscr_flags+2		;Note rez update need to force slot
	and	#slot_limit-1,d0
	bra.s	.done_slot_req
;
.test_def_slot:
	cmp	opnwk_rez(pc),d0
	bne.s	.done_slot_req
	move	opnwk_slot(pc),d0	;same rez as opnwk, forces same slot
.done_slot_req:				;d0 = slot_code from argument or v_opnwk
	cmp	#slot_limit,d0
	bhs.s	.force_rez		;refuse non_existent slots
	addq	#norm_slots,d0		;alter slot_code 0-31 to slot# 8-39
	cmp	#slot_limit,d0
	blo.s	.try_rez_d0		;use slot_code 0-23 as slot# 8-31
	sub	#slot_limit,d0		;adjust slot_code 24-31 to slot# 0-8
.try_rez_d0:				;d0 = slot# 0-15
	lea	SCREEN_tab(pc),a1
	move	d0,d1			;d1 = wanted lacescan slot position
	asl	#sc_log2size,d0
	add	d0,a1			;a1 -> parameters of selected slot
	tst	sc_def_mark(a1)
	bne.s	.rez_defd		;keep parameters of selected slot if defined
	lea	SCD(pc),a2
	moveq	#sc_sizeof/4-1,d2
.rez_def_lp:				;loop to copy slot parameters last used
	move.l	(a2)+,(a1)+
	dbra	d2,.rez_def_lp		;loop back until new slot complete
	lea	-sc_sizeof(a1),a1	;a1 -> parameters of created slot
	bsr	get_rez_sub		;d0 = hard rez code  (for garbage slot)
	tst	sc_def_mark(a1)
	beq.s	.force_rez		;refuse garbage slot
.rez_defd:				;a1 -> legal slot
	move	d1,setscr_rez		;this is the slot we will attempt to set
.ready_rez:
	move	setscr_rez(pc),d2
	cmp	lace_rez(pc),d2
	beq.s	.got_lace_rez
	st	setscr_flags+2		;Note rez update need
	st	fixed_rez		;Note rez slot update need
.got_lace_rez:
	move	d2,lace_rez		;This decision is final ! (and mandatory)
	bsr	refix_supx		;refix screen parameters
	bsr	fix_la_workout
	move	#-1,10(a0)
	tst.b	setscr_flags+2
	beq.s	.rez_ready
	move	emu_rez(pc),10(a0)	;rez seen by system (possibly emulated)
	st	fixed_rez		;Note rez slot update need
.rez_ready:
	move.l	2(a0),d0		;d0 -> argument logbase
	spl	setscr_flags+0
	move.l	6(a0),d1		;d1 -> argument physbase
	spl	setscr_flags+1
;
	tst.b	sc_emu_rez+SCD
	bmi.s	.calc_base_lace
.calc_base_emu:
	move	sc_emu_bytewid+SCD(pc),d2
	mulu	sc_emu_Yrez+SCD(pc),d2
	move.l	lpt_emu_phys_p+LPT(pc),-(sp)
	bsr	test_base_emu			;test and adjust new screen bases
	move.l	lpt_emu_phys_p+LPT(pc),-(sp)
	move.l	lpt_emu_recalc+LPT(pc),a1
	jsr	(a1)
	addq	#8,sp
	bra.s	.base_calced
;
.calc_base_lace:
	move.l	sc_reen_bytes+SCD(pc),d2	;d2.l = lace screen bytes
	bsr	test_base_lace			;test and adjust new screen bases
.base_calced:
;
	move.l	sc_log_offs+SCD(pc),d2		;d2.l = log_offs
	tst.b	setscr_flags+0
	beq.s	.done_logb
	move.l	d0,2(a0)		;finalize logbase argument
	spl	setscr_flags+0
	bmi.s	.done_logb
	move	SR,-(sp)		;push interrupt mask
	or	#$0700,SR		;disable interrupts
	move.l	d0,logbase_p
	move.l	d0,(_v_bas_ad).w
	tst.b	sc_emu_rez+SCD
	bpl.s	.set_logbphys
	sub.l	d2,d0
.set_logbphys:
	move.l	d0,logbphys_p
	move	(sp)+,SR		;pull interrupt mask
.done_logb:
	tst.b	setscr_flags+1
	beq.s	.done_physb
	move.l	d1,6(a0)		;finalize physbase argument
	spl	setscr_flags+1
	bmi.s	.done_physb
	move	SR,-(sp)		;push interrupt mask
	or	#$0700,SR		;disable interrupts
	move.l	d1,lpt_physbase_p+LPT
	lsr	#8,d1
	move.l	d1,(hw_vbase2-1).w
	move	(sp)+,SR		;pull interrupt mask
.done_physb:
.done_bases:
	tst.b	setscr_flags+2
	beq.s	.done_wait_1
	bset	#setscreen_b,hw_rez_block_f
	move	emu_rez(pc),d0
	move	d0,mon_rez
	move.b	d0,(sshiftmd).w
	bsr	set_rez_sub		;hard rez code = d0
.do_wait_1:
	bsr	sync_fall_supx
	bsr	sync_fall_supx
.done_wait_1:
	move	10(a0),-(sp)
	move.l	6(a0),-(sp)
	move.l	2(a0),-(sp)
	move	#Setscreen&$FF,-(sp)
	push_ex	.done_sub_setscreen(pc)
	XB_gonext_a0	nu_xbios(pc)
;
.done_sub_setscreen:
	lea	12(sp),sp
;TT;	set_mon	hard_rez+1
	move.b	emu_rez+1(pc),(sshiftmd).w
	bclr	#setscreen_b,hw_rez_block_f
	tst.b	setscr_flags+2		;changed rez ?
	beq.s	.done_wait_2		;skip synclace if rez kept
	bsr	sync_fall_supx
	bsr	sync_lace_supx
.done_wait_2:
	move	setscr_rez(pc),lace_rez
	st	fixed_rez		;Note rez slot update need
	st	prev_slot		;Note base update needs
	bsr	refix_supx
	tst.b	setscr_flags+2		;changed rez ?
	beq.s	.done_wait_3		;skip extra work, if rez kept
	bsr	fix_la_workout
	bsr	blank_border_supx
.done_wait_3:
;Here entry conditions are active again
.exit_setscreen:
	bclr	#setscreen_b,int_protect_f
	bclr	#setscreen_b,rez_lock_f		;unlock rez variables
	clr.l	setscr_flags
	rte
;--------------------------------------
test_base_emu:	;d0->logbase\-1  d1->physbase\-1  d2=screensize
.fix_logbase_d0:
	tst.b	opnwk_flag
	bne	.lock_d0_d1		;_ALWAYS_ lock _BOTH_ during v_opnwk
	tst.l	d0
	spl	setscr_flags+0
	bmi.s	.fixed_d0		;skip logbase tests if no new logbase wanted
	cmp.l	#32000,d2		;standard ST size logical screen ?
	beq.s	.take_logb		;go take new logbase if emulating ST standards
	tst.b	lpt_screen_lock+LPT
	beq.s	.test_logb		;go test new logbase if screen_lock = 0
.lock_logb:
	move.l	d1,a1
	bsr	test_screen_d0_a1	;is bad logbase in area of new physbase ?
	beq.s	.lock_d0_d1		;if so, go lock both bases
	move.l	lpt_emu_phys_p+LPT(pc),a1
	bsr	test_screen_d0_a1	;is bad logbase in current physbase area ?
	beq.s	.lock_d0_d1		;if so, go lock both bases
	move.l	lpt_emu_lock_p+LPT(pc),a1
	bsr	test_screen_d0_a1	;is bad logbase in locked area ?
	beq.s	.lock_d0_d1		;if so, go lock both bases
;	-----				;else lock logbase
.lock_d0:
	move.l	lpt_emu_lock_p+LPT(pc),d0
	bra.s	.fixed_d0
;
.test_logb:
	move.l	lpt_emu_lock_p+LPT(pc),a1	;a1 -> locked emu physbase
	cmp.l	a1,d0				;new base <= locked area (permitted)
	bls.s	.take_logb			;if so go try taking it
	bsr	test_screen_d0_a1		;is new logbase in locked physbase area ?
	beq.s	.lock_d0_d1			;if so, go lock _BOTH_
.take_logb:
.fixed_d0:
.fix_physbase_d1:
	tst.l	d1
	spl	setscr_flags+1
	bmi.s	.fixed_d1		;skip physbase tests if no new physbase wanted
	cmp.l	#32000,d2		;standard ST size logical screen ?
	beq.s	.take_phys		;go take new physbase if emulating ST standards
	tst.b	lpt_screen_lock+LPT
	beq.s	.test_phys		;go test new physbase if screen_lock = 0
.lock_phys:
	move.l	d0,a1
	bsr	test_screen_d1_a1	;is bad physbase in area of new logbase ?
	beq.s	.lock_d0_d1		;if so, go lock both bases
	move.l	logbase_p(pc),a1
	bsr	test_screen_d1_a1	;is bad physbase in current logbase area ?
	beq.s	.lock_d0_d1		;if so, go lock both bases
	move.l	lpt_emu_lock_p+LPT(pc),a1
	bsr	test_screen_d1_a1	;is bad physbase in locked area ?
	bne.s	.lock_d1		;if not, go lock physbase
;	-----				;else lock both bases
.lock_d0_d1:
	move.l	lpt_emu_lock_p+LPT(pc),d0
	st	setscr_flags+0
.lock_d1:
	move.l	lpt_emu_lock_p+LPT(pc),lpt_emu_phys_p+LPT
	move.l	lpt_lockbase_p+LPT(pc),d1
	st	setscr_flags+1
	bra.s	.fixed_d0_d1
;
.test_phys:
	move.l	lpt_emu_lock_p+LPT(pc),a1	;a1 -> locked physbase
	cmp.l	a1,d1				;new base <= locked area (permitted)
	bls.s	.take_phys			;if so go try taking it
	bsr	test_screen_d1_a1		;is new physbase in locked physbase area ?
	beq.s	.lock_d0_d1			;if so, go lock _BOTH_
.take_phys:
	move.l	d1,lpt_emu_phys_p+LPT
	move.l	lpt_lockbase_p+LPT(pc),d1
.fixed_d1:
.fixed_d0_d1:
	rts
;--------------------------------------
test_base_lace:	;d0->logbase\-1  d1->physbase\-1  d2=screensize
.fix_logbase_d0:
	tst.b	opnwk_flag
	bne	.lock_d0_d1		;_ALWAYS_ lock _BOTH_ during v_opnwk
	tst.l	d0
	spl	setscr_flags+0
	bmi.s	.fixed_d0		;skip logbase tests if no new logbase wanted
	cmp.l	#32000,d2		;standard ST size logical screen ?
	beq.s	.take_logb		;go take new logbase if emulating ST standards
	tst.b	lpt_screen_lock+LPT
	beq.s	.test_logb		;go test new logbase if screen_lock = 0
.lock_logb:
	move.l	d1,a1
	bsr	test_screen_d0_a1	;is bad logbase in area of new physbase ?
	beq.s	.lock_d0_d1		;if so, go lock both bases
	move.l	lpt_physbase_p+LPT(pc),a1
	bsr	test_screen_d0_a1	;is bad logbase in current physbase area ?
	beq.s	.lock_d0_d1		;if so, go lock both bases
	move.l	lpt_lockbase_p+LPT(pc),a1
	bsr	test_screen_d0_a1	;is bad logbase in locked area ?
	beq.s	.lock_d0		;if so, go lock both bases
;	-----				;else lock logbase
.lock_d0:
	move.l	lpt_lockbase_p+LPT(pc),d0
	add.l	sc_log_offs+SCD(pc),d0
	bra.s	.fixed_d0
;
.test_logb:
	move.l	lpt_lockbase_p+LPT(pc),a1	;a1 -> locked physbase
	add.l	sc_log_offs+SCD(pc),a1	;offset a1 like logbase
	cmp.l	a1,d0			;new base <= locked area (permitted)
	bls.s	.take_logb		;if so go try taking it
	bsr.s	test_screen_d0_a1	;is new logbase in locked physbase area ?
	beq.s	.lock_d0		;if so, go lock logbase
.take_logb:
	cmp.b	sc_log_offs+SCD(pc),d0	;legal offset ?
	beq.s	.fixed_d0		;if so, go accept it as-is
	add.l	sc_log_offs+SCD(pc),d0	;offset d0 as logbase
	cmp.b	sc_log_offs+SCD(pc),d0	;legal offset ?
	bne.s	.lock_d0_d1		;if not, value is illegal, go lock _BOTH_
.fixed_d0:
.fix_physbase_d1:
	tst.l	d1
	spl	setscr_flags+1
	bmi.s	.fixed_d1		;skip physbase tests if no new physbase wanted
	cmp.l	#32000,d2		;standard ST size logical screen ?
	beq.s	.take_phys		;go take new physbase if emulating ST standards
	tst.b	lpt_screen_lock+LPT
	beq.s	.test_phys		;go test new physbase if screen_lock = 0
.lock_phys:
	move.l	d0,a1
	bsr.s	test_screen_d1_a1	;is bad physbase in area of new logbase ?
	beq.s	.lock_d0_d1		;if so, go lock both bases
	move.l	logbase_p(pc),a1
	bsr.s	test_screen_d1_a1	;is bad physbase in current logbase area ?
	beq.s	.lock_d0_d1		;if so, go lock both bases
	move.l	lpt_lockbase_p+LPT(pc),a1
	bsr.s	test_screen_d1_a1	;is bad physbase in locked area ?
	bne.s	.lock_d1		;if not, go lock physbase
;	-----				;else lock both bases
.lock_d0_d1:
	move.l	lpt_lockbase_p+LPT(pc),d0
	add.l	sc_log_offs+SCD(pc),d0
	st	setscr_flags+0
.lock_d1:
	move.l	lpt_lockbase_p+LPT(pc),d1
	st	setscr_flags+1
	bra.s	.fixed_d0_d1
;
.test_phys:
	move.l	lpt_lockbase_p+LPT(pc),a1		;a1 -> locked physbase
	cmp.l	a1,d1				;new base <= locked area (permitted)
	bls.s	.take_phys			;if so go try taking it
	bsr.s	test_screen_d1_a1		;is new physbase in locked physbase area ?
	beq.s	.lock_d1			;if so, go lock physbase
.take_phys:
	tst.b	d1				;new physbase at page boundary ?
	beq.s	.fixed_d1			;if so, go accept it as-is
	sub.l	sc_log_offs+SCD(pc),d1		;remove offset like logbase
	tst.b	d1				;physbase offset from page boundary ?
	bne.s	.lock_d0_d1			;if not, value is illegal, go lock _BOTH_
.fixed_d1:
.fixed_d0_d1:
	rts
;--------------------------------------
test_screen_d0_a1:
	exg	d0,d1
	bsr.s	test_screen_d1_a1
	exg	d0,d1
	rts
;--------------------------------------
test_screen_d1_a1:
;tests if a1 & d1 -> parts of same screen  (abs(diff) < d2)
;alters no register except CCR
	move.l	a1,-(sp)
	exg	d1,a1
	sub.l	a1,d1
	bpl.s	.abs_diff
	neg.l	d1
.abs_diff:
	cmp.l	d2,d1		;same => flag LS  	diff => flag HI
	shs	d1		;same => d1.b = $00	diff => d1.b = $FF
	tst.b	d1		;same => flag EQ	diff => flag NE
	exg	a1,d1		;d1 = entry d1, without affecting flags
	movea.l	(sp)+,a1	;a1 = entry d1, without affecting flags
	rts		;flags:  EQ = same screen,  NE = different screens
;----------------------------------------------------------------------------
;End of:	XBIOS functions with XBRA
;----------------------------------------------------------------------------
;		LINE_A functions with XBRA
;----------------------------------------------------------------------------
	dc.l		LPT
	XB_define	nu_LINE_A,'Lace'
	move.l	2(sp),a1
	cmpi	#$A007,(a1)		;BITBLT ?
	bne.s	LDCC
nu_line_A_BITBLT:
	tst	MagX_f
	bne.s	go_old_line_a		;no _a_bitblt patch for MagiX
	move.l	(_v_bas_ad).w,d2	;d2 = _v_bas_ad
	cmp.l	18(a6),d2		;source base == _v_bas_ad ?
	bne.s	.LDB8
	move	SCD+sc_emu_bytewid(pc),24(a6)	;source bytes/line = SCD+sc_emu_bytewid
.LDB8:
	cmp.l	32(a6),d2		;dest base == _v_bas_ad ?
	bne.s	LDF4
	move	SCD+sc_emu_bytewid(pc),38(a6)	;dest bytes/line = SCD+sc_emu_bytewid
go_old_line_a:
	XB_gonext_d	nu_LINE_A(pc)
;
LDCC:
	cmpi	#$A00E,(a1)		;CPYFM ?
	bne.s	LDF4			;else old line_A
nu_line_A_CPYFM:
	tst	MagX_f
	bne.s	go_old_line_a		;no _a_cpyfm patch for MagiX
	move.l	(_v_bas_ad).w,d2	;d2 = _v_bas_ad
	move.l	line_a_base_p(pc),a1
	move.l	la_contrl_p(a1),a1
	move.l	14(a1),a0		;a0->source MFDB
	cmp.l	(a0),d2			;MFDB == _v_bas_ad ?
	bne.s	LDE8
	clr.l	(a0)
LDE8:
	move.l	18(a1),a0		;a0->dest MFDB
	cmp.l	(a0),d2			;MFDB == _v_bas_ad ?
	bne.s	LDF4
	clr.l	(a0)
LDF4:
	XB_gonext_d	nu_LINE_A(pc)
;
;----------------------------------------------------------------------------
;End of:	LINE_A functions with XBRA
;----------------------------------------------------------------------------
;		IKBD functions with XBRA
;		also separately linked as
;		TIMER functions with XBRA
;----------------------------------------------------------------------------
	dc.l		'LPT:',LPT
	XB_define	nu_ikbd_vec,'Lace'
	tas	int_protect_f
	bmi.s	.go_old_ikbd_vec
	bne.s	.use_old_ikbd_vec
	move	shsh_command(pc),d0
	beq.s	.use_new_ikbd_vec
.use_old_ikbd_vec:
	bclr	#interrupt_b,int_protect_f
.go_old_ikbd_vec:
	XB_gonext_d	nu_ikbd_vec(pc)
;
;
.use_new_ikbd_vec:
	XB_donext_d	nu_ikbd_vec(pc)
;-------
	move	SR,-(sp)	
	or	#$0700,SR
	move.l	kb_iorec_p(pc),a0
	move	io_tail_ix(a0),d1	;tail index
	cmp	old_tail_ix(pc),d1	;test if changed
	beq	.not_shsh_command
	move	d1,old_tail_ix		;save tail index at old_tail_ix
	cmp	io_head_ix(a0),d1
	beq	.not_shsh_command
	move.l	kbshift_p(pc),a1
	move.b	(a1),d2			;get kbshifts (** TOS independent **)
	and	#$0F,d2
	cmp	hot_keys(pc),d2		;correct for command ?
	bne	.not_shsh_command
	move.l	io_buffer_p(a0),a2	;get address of io-buffer
	move	(a2,d1),d0		;get 1'st word for this key = key code
	and	#$FF,d0			;mask key code
	cmp	#$01,d0			;<Escape> key ?
	beq.s	.got_shsh_command
	cmp	#$0E,d0			;<Backspace> key ?
	beq.s	.got_shsh_command
	cmp	#$47,d0			;<Clr/Home> key ?
	blt.s	.not_shsh_command	;take none lower
	beq.s	.got_shsh_command
	cmp	#$62,d0			;<Help> key ?
	bgt.s	.not_shsh_command	;take none higher
	beq.s	.got_shsh_command
	cmp	#$61,d0			;<Undo> key ?
	beq.s	.got_shsh_command
	cmp	#$53,d0			;<Delete> key ?
	beq.s	.got_shsh_command
	cmp	#$52,d0			;<Insert> key ?
	beq.s	.got_shsh_command
	cmp	#$48,d0			;<up_arrow> key ?
	beq.s	.got_shsh_command
	cmp	#$4B,d0			;<lt_arrow> key ?
	beq.s	.got_shsh_command
	cmp	#$4D,d0			;<rt_arrow> key ?
	beq.s	.got_shsh_command
	cmp	#$50,d0			;<dn_arrow> key ?
	beq.s	.got_shsh_command
	cmp	#$4E,d0			;<+> numkey ?
	beq.s	.got_shsh_command
	cmp	#$4A,d0			;<-> numkey ?
	beq.s	.got_shsh_command
	IFNE	debug_keys
	cmp	#$66,d0			;<*> numkey ?
	beq.s	.got_shsh_command
	ENDC
	move.b	3(a2,d1),d0		;get 4'th byte for this key = ASCII
	and	#$FF,d0			;mask ASCII
	or	#$0100,d0		;flag ASCII
;Add ASCII based key tests here
	bra.s	.not_shsh_command
;
.got_shsh_command:
	move	d0,shsh_command
	subq	#4,d1
	bge.s	.tail_shrunk
	move	io_size_ix(a0),d1
	subq	#4,d1
.tail_shrunk:
	move	d1,io_tail_ix(a0)
	move	d1,old_tail_ix
.not_shsh_command:
	sf	int_protect_f
	move	(sp)+,SR
	rts
;----------------------------------------------------------------------------
;End of:	IKBD functions with XBRA
;----------------------------------------------------------------------------
;		SWV subroutine with XBRA
;----------------------------------------------------------------------------
; swv_vec_XB replaces RESET on monitor swap
; and so does NOT execute the older XBRA chain
; NB: on STE/TT DMA sound interrupt also affects this 
;
	XB_define	swv_vec_XB,'Lace'
;TT;	set_mon		mon_rez+1
	rts
;----------------------------------------------------------------------------
;End of:	SWV subroutine with XBRA
;----------------------------------------------------------------------------
;Start of:	VBL subroutine with XBRA
;----------------------------------------------------------------------------
	dc.l		'LPT:',LPT
	XB_define	nu_vbl_sub,'Lace'
	tas	int_protect_f
	bmi	.busy_vbl
	bne	.block_vbl
	move	shsh_command(pc),d0
	ble.s	.not_command
	move.l	(_frclock).w,d1
	sub.l	shsh_worktime(pc),d1
	cmp.l	#25,d1			;enough time since last ?
	blo.s	.not_command		;demand time between commands
	bsr	key_command_d0		;execute command
	move.l	(_frclock).w,shsh_worktime
.not_command:
	tas	rez_lock_f
	bne.s	.mini_vbl
	move.b	sc_intfx_f+SCD(pc),d0
	beq.s	.mini_vbl
	bmi.s	.blank_vbl
	move	lacesize_f(pc),d0
	beq.s	.mini_vbl
	tst	test_scan_p
	beq.s	.mini_vbl
	bsr	rez_mask_supx
.testscan:
	move.l	test_scan_p(pc),a0
	adda.l	test_downstep(pc),a0
	cmp.l	test_maxpos,a0
	blt.s	.keep_a0
	move.l	test_base_p(pc),a0
.keep_a0:
	move.l	a0,test_scan_p
	cmp	(a0),d0			;test right edge
	bne.s	.blank_vbl
	adda.l	test_horoffs,a0
	cmp	(a0),d0			;test left edge
	beq.s	.mini_vbl
.blank_vbl:
	bclr	#7,sc_intfx_f+SCD
;;;	beq.s	.just_blank
;;;	bsr	sync_lace_supx		;resynchronize video shifter
;;;.just_blank:
	bsr	refix_supx
	bsr	blank_border_supx
	move.l	(_frclock).w,shsh_worktime
.mini_vbl:
	bclr	#interrupt_b,rez_lock_f
.block_vbl:
	bclr	#interrupt_b,int_protect_f
.busy_vbl:
	rts
;----------------------------------------------------------------------------
;End of:	VBL subroutine with XBRA
;----------------------------------------------------------------------------
;Start of:	subroutine for keyboard commands	SUPER
;----------------------------------------------------------------------------
key_command:
	tas	shsh_command
	bmi	command_rts
	move	shsh_command(pc),d0
	bclr	#15,d0
key_command_d0:
	cmp	#$01,d0			;<Escape> key
	beq.s	.got_escape
	cmp	#$52,d0			;<insert> key ?
	beq.s	.got_insert
	cmp.b	#$47,d0			;<clr/home> key ?
	beq.s	.got_clrhome
	cmp.b	#$61,d0			;<undo> key ?
	beq.s	.got_undo
	cmp	#$53,d0			;<Delete> key ?
	beq.s	.got_delete
	cmp	#$0E,d0			;<Backspace> key ?
	beq.s	.got_backspace
	cmp	#$62,d0
	beq.s	.got_help		;<Help> key ?
	cmp	#$4B,d0
	beq.s	.got_left		;<left-arrow> key ?
	cmp	#$4D,d0
	beq.s	.got_right		;<right-arrow> key ?
	cmp	#$48,d0
	beq.s	.got_up			;<up-arrow> key ?
	cmp	#$50,d0
	beq.s	.got_down		;<down-arrow> key ?
	cmp	#$4E,d0
	beq.s	.got_plus		;<+> numkey ?
	cmp	#$4A,d0
	beq.s	.got_minus		;<-> numkey ?
	IFNE	debug_keys
	cmp	#$66,d0
	beq	hot_num_asterix	;<*> numkey ?
	ENDC
	bra	exit_command
;
;
.got_escape:
	addq	#2,hot_flag
	move	hot_flag(pc),d0
	and	#2,d0
	lea	hot_keys(pc),a0
	move	2(a0,d0),(a0)
	bra.s	exit_command
;
.got_insert:				;invert blank colour & blank
	bchg	#0,sc_backg_f+SCD
	bra.s	.set_blank
;
.got_clrhome:				;toggle interrupt fix & blank
	bchg	#6,sc_intfx_f+SCD
	bra.s	.set_blank
;
.got_undo:				;toggle auto-switch & blank
	bsr	auto_switch_supx
.set_blank:
	bset	#7,sc_intfx_f+SCD
	bra.s	exit_command
;
.got_delete:
	move.l	lpt_emu_newmode+LPT(pc),a0
	moveq	#2,d0			;request toggled mode
	bra.s	.call_emu_a0
;
.got_backspace:
	move.l	lpt_emu_home+LPT(pc),a0
	bra.s	.call_emu_a0
;
.got_help:
	move.l	lpt_emu_center+LPT(pc),a0
	bra.s	.call_emu_a0
;
.got_left:
	move.l	lpt_emu_left+LPT(pc),a0
	bra.s	.call_emu_a0
;
.got_right:
	move.l	lpt_emu_right+LPT(pc),a0
	bra.s	.call_emu_a0
;
.got_up:
	move.l	lpt_emu_up+LPT(pc),a0
	bra.s	.call_emu_a0
;
.got_down:
	move.l	lpt_emu_down+LPT(pc),a0
	bra.s	.call_emu_a0
;
.got_plus:
	moveq	#2,d0		;emu command set_next_filt
	bra.s	.call_emu_command
;
.got_minus:
	moveq	#1,d0		;emu command set_prev_filt
.call_emu_command:
	move.l	lpt_emu_command+LPT(pc),a0
.call_emu_a0:
	move.l	a0,d1
	ble.s	exit_command
	move.l	a0,-(sp)
	move.l	lpt_emu_block_p+LPT(pc),a0
	btst	#lace_2_lemu_b,(a0)
	bne.s	exit_command
	bset	#lace_2_lemu_b,(a0)
	move.l	(sp)+,a0
	jsr	(a0)
	move.l	lpt_emu_block_p+LPT(pc),a0
	bclr	#lace_2_lemu_b,(a0)
exit_command:
	clr	shsh_command
command_rts:
	rts
;
	IFNE	debug_keys
hot_num_asterix:
	move.l	lpt_emu_block_p+LPT(pc),a0
	move.b	#$80,d0
	move.b	d0,int_protect_f
	move.b	d0,(a0)
	bra	exit_command
	ENDC
;----------------------------------------------------------------------------
;End of:	subroutine for keyboard commands
;----------------------------------------------------------------------------
;		Scroll_fix routine with XBRA
;----------------------------------------------------------------------------
;
;at entry d1 == number of the text line which is scroll destination
;
	dc.l		'LPT:',LPT
	XB_define	nu_scroller,'Lace'
	move	la_v_cel_my+6(a4),d3	;d3 = max text line to scroll
	move	d3,d7
	sub	d1,d7			;d7 = text lines to scroll
	beq	.nomove
	move	la_v_cel_wr+6(a4),d0	;d0 = bytes per text line
	move.l	(_v_bas_ad).w,a3	;a3 ->screen base
	mulu	d0,d1			;d1 = offset to scroll destination
	add.l	d1,a3		;a3 -> scroll destination in screen RAM
	move.l	a3,a2
	add	d0,a2		;a2 -> scroll source in screen RAM
	mulu	d0,d7		;d7 = bytes to move in scroll
	clr.l	d0
	move.b	d7,d0		;d0 = bytes to move in segment less than a page
	jsr	word_mover	;move the short segment
	lsr.l	#8,d7		;d7 = pages remaining to move
	beq	.nomove		;skip loop if no pages remain
	subq	#1,d7		;d7 adjusted for dbra
.page_move_lp:				;start loop to move one page per pass
	REPT	256/4
	move.l	(a2)+,(a3)+
	ENDR
	dbra	d7,.page_move_lp	;loop back to move any remaining pages
.nomove:
	clr	d0
	move	la_v_cel_mx+6(a4),d2
	move	d3,d1
	move.l	$86+6(a4),a2
	jmp	(a2)
;
;
;The code below is entered at various places by word_mover
	REPT	256/2
	move	(a2)+,(a3)+
	ENDR
word_move_base:
	rts
;
word_mover:	;this sub moves up to one page of 16-bit words
	neg	d0
	bclr	#0,d0			;forces even count
	jmp	word_move_base(pc,d0)
;
;----------------------------------------------------------------------------
;End of:	Scroll_fix routine with XBRA
;----------------------------------------------------------------------------
;		Blitter link table with XBRA & installation subroutine
;----------------------------------------------------------------------------
;
	dc.l		'LPT:',LPT
	XB_define	nu_pasblit_tb,'Lace'
	ds.l	12	;will hold patched copy of table @(la_pasblit_p)
;
;
install_scrollfix:
	xbios	Blitmode,#0		;deactivate blitter
	move	d0,-(sp)		;push prev blitmode
	move.l	(_sysbase).w,a0
	move.l	os_selfbeg_p(a0),a0
	move.l	a0,d1
	add.l	#$30000,d1
	cmp	#$206,os_version(a0)
	blt.s	.get_blit
	add.l	#$10000,d1
	cmp	#$400,os_version(a0)
	blt.s	.get_blit
	add.l	#$40000,d1
.get_blit:
	move.l	line_a_base_p(pc),a1
	lea	la_curblit_tb(a1),a1
	lea	nu_pasblit_tb+12(pc),a2
	moveq	#12-1,d2
.get_blit_lp:
	move.l	(a1)+,d0
	cmp.l	a0,d0
	ble.s	.install_exit
	cmp.l	d1,d0
	bge.s	.install_exit
	btst	#0,d0
	bne.s	.install_exit
	move.l	d0,(a2)+
	dbra	d2,.get_blit_lp
	lea	la_lk_scroller-la_curblit_tb+nu_pasblit_tb+12(pc),a0
	lea	nu_scroller+8(pc),a1
	move.l	(a0),(a1)+
	move.l	a1,(a0)
	move.l	line_a_base_p(pc),a0
	move.l	a1,la_lk_scroller(a0)
	lea	la_pasblit_p(a0),a0
	lea	nu_pasblit_tb+8(pc),a1
	move.l	(a0),(a1)+
	move.l	a1,(a0)
.install_exit:
	xbios	Blitmode,()		;restore entry blitmode
	rts
;
;----------------------------------------------------------------------------
;End of:	Blitter link table with XBRA & installation subroutine
;----------------------------------------------------------------------------
;		HARDCOPY routine with XBRA
;----------------------------------------------------------------------------
;
	dc.l		'LPT:',LPT
	XB_define	nu_scr_dump,'Lace'
	tst.b	sc_hardc_f+SCD
	bne.s	.try_dump
.refuse_it:
	XB_gonext_d	nu_scr_dump
;
.try_dump:
	bios	Kbshift,#-1
	btst	#0,d0
	bne.s	.refuse_it	;use other drivers if right shift pressed
	cmp.b	#1,sc_hardc_f+SCD
	beq	.hard_paper
	cmp	#2,emu_rez
	bne	.hard_paper
.hard_file:
	gemdos	Dgetdrv
	add.b	#'A',d0
	move.b	d0,image_name_s
	moveq	#26-1,d3
.try_create:
	subq	#1,d3
	bmi.s	.refuse_it
	gemdos	Fcreate,image_name_s(pc),#0
	move.b	image_patch_s(pc),d1
	and.b	#$1F,d1
	add.b	#$41,d1
	cmp.b	#'Z',d1
	bls.s	.keep_fchar_d1
	moveq	#'A',d1
.keep_fchar_d1:
	move.b	d1,image_patch_s
	move	d0,screen_img_handle
	tst.l	d0
	bmi.s	.try_create
	move.l	line_a_base_p(pc),a0
	move.l	la_wk_pixwidth(a0),image_pixsize	;pixel width,height  [microns]
	move.l	SCD+sc_Xrez(pc),image_imgsize		;X,Y resolution
	gemdos	Fwrite,d0,#16,image_head(pc)
	cmp.l	#16,d0
	bne.s	.scr_dump_error
	clr.l	d6
	move	SCD+sc_emu_bytewid(pc),d5		;d5 = bytes per line incl garbage
	move	SCD+sc_emu_Xrez(pc),d6			;d6 = X resolution
	asr.w	#3,d6
	move	d6,d7					;d7 = d6 = pure bytes per planeline
	addi	#$8000,d7
	move	d7,image_rlecode
	move	SCD+sc_emu_Yrez(pc),d7			;d7 = Y resolution (pure lines)
	move.l	(_v_bas_ad).w,a6
.scr_dump_loop_1:
	gemdos	Fwrite,screen_img_handle(pc),#2,image_rlecode(pc)
	cmp.l	#2,d0
	bne.s	.scr_dump_error
	gemdos	Fwrite,screen_img_handle(pc),d6,(a6)
	cmp.l	d6,d0
	bne.s	.scr_dump_error
	adda.l	d5,a6
	dbra	d7,.scr_dump_loop_1
.scr_dump_error:
	gemdos	Fclose,screen_img_handle(pc)
	move	#-1,(_prt_cnt).w
	rts
;
.hard_paper:
	subi.l	#$2E,(savptr).w
	xbios	Setprt,#-1
	lea	screen_prt_buf_1(pc),a0
	move.l	(_v_bas_ad).w,(a0)
	move	d0,d1
	lsr.w	#3,d0
	andi	#1,d0
	move	d0,16(a0)
	move	d1,d0
	lsr.w	#4,d0
	andi	#1,d0
	move	d0,24(a0)
	andi	#7,d1
	move.b	screen_prt_buf_2(pc,d1.w),d0
	move	d0,22(a0)
	move	SCD+sc_emu_Xrez(pc),6(a0)
	move	SCD+sc_emu_Yrez(pc),8(a0)
	move	emu_rez(pc),14(a0)
	move	SCD+sc_emu_bytewid(pc),d1
	addq.b	#1,d0
	lsl.w	d0,d1
	sub	SCD+sc_Xrez(pc),d1
	move	d1,12(a0)
	move	#1,(_prt_cnt).w
	xbios	Prtblk,(a0)
	addi.l	#$2E,(savptr).w
	rts
;
;
screen_prt_buf_1:
	dc.w	$0
	dc.w	$0
	dc.w	$0
	dc.w	$0
	dc.w	$0
	dc.w	$0
	dc.w	$0
	dc.w	$2
	dc.w	$0
	dc.w	$FF
	dc.w	$8240
	dc.w	$3
	dc.w	$0
	dc.w	$0
	dc.w	$0
screen_prt_buf_2:
	dc.w	$2
	dc.w	$1FF
	dc.w	$3FF
	dc.w	$FFFF
;
;----------------------------------------------------------------------------
;End of:	HARDCOPY routine with XBRA
;----------------------------------------------------------------------------
;		Here end the XBRA routines
;----------------------------------------------------------------------------
;		Diverse routines follow
;----------------------------------------------------------------------------
;Start of:	'refix' subs
;----------------------------------------------------------------------------
refix_d0:
	move	d0,lace_rez
	st	fixed_rez
	st	home_emu_f
	bsr.s	refix_supx
	clr	home_emu_f
	rts
;
refix_supx:
	movem.l	d0-d2/a0,-(sp)
	move	SR,d2			;save interrupt mask in d2
	or	#$0700,SR		;disable interrupts
	bsr	fix_screen_supx
	move	sc_rez+SCD(pc),d0
	move	d0,hard_rez
	tst	hw_rez_block_f
	bne.s	.hw_rez_done
	move	d0,mon_rez
	move	d0,d1			;d1 = wanted hard rez
	bsr	get_rez_sub		;d0 = hard rez code
	cmp	d0,d1
	beq.s	.hw_rez_done
	exg	d0,d1			;d0 = wanted hard rez  d1 = active hard rez
	bsr	set_rez_sub		;hard rez code = d0
.hw_rez_done:
	move.b	sc_emu_rez+SCD(pc),d1
	bmi.s	.use_emu_rez_d0
	move.b	d1,d0
.use_emu_rez_d0:
	move	d0,emu_rez
	move.b	d0,(sshiftmd).w
	cmp	VDO_high_rez(pc),d0
	beq.s	.keep_defmd
	move.b	d0,(defshiftmd).w
.keep_defmd:
	move	sizefail_f(pc),d0
	beq.s	.done_sizefail
	st	prev_slot		;ensure bases will be stored
	move	lacesize_f(pc),d0
	beq.s	.done_sizefail		;keep physbase if no overscan
	move.l	lpt_lockbase_p+LPT(pc),a0
	move.l	a0,lpt_physbase_p+LPT
.done_sizefail:
	move	new_emu_f(pc),d0	;test emulation state transitions
	beq.s	.done_new_emu		;jump if emulation state unchanged
	bpl.s	.deactivated_emu	;jump if emulation deactivated
.activated_emu:				;emulation was activated
	move.l	lpt_emu_phys_p+LPT(pc),a0
	move.l	a0,logbphys_p
	move.l	a0,logbase_p
	bra.s	.set_lockbase
;
.deactivated_emu:
.lock_bases:
	move.l	lpt_lockbase_p+LPT(pc),a0
	move.l	a0,logbphys_p
	add.l	sc_log_offs+SCD(pc),a0
	move.l	a0,logbase_p
.set_lockbase:
	move.l	lpt_lockbase_p+LPT(pc),lpt_physbase_p+LPT
	move	lace_rez(pc),prev_slot
	bra.s	.new_slot		;ensure bases will be stored
;
.done_new_emu:
	move	prev_slot(pc),d0
	move	lace_rez(pc),prev_slot
	cmp	lace_rez(pc),d0
	beq.s	.old_slot
.new_slot:
	cmp	#1,VDO_b_index
	bhi.s	.keep_HZ
	tst	lacesize_f
	beq.s	.keep_HZ
	cmpi	#2,hard_rez
	beq.s	.keep_HZ		;PATCH bra to allow 60Hz but beq to forbid it
	move.b	#2,(hw_syn).w		;force 50 Hz mode
.keep_HZ:
.set_bases:
	move.l	logbase_p(pc),(_v_bas_ad).w
	move.l	lpt_physbase_p+LPT(pc),d0
	lsr	#8,d0
	move.l	d0,(hw_vbase2-1).w
.old_slot:
	move	home_emu_f(pc),d0
	ble.s	.done_home_emu
	btst	#setscreen_b,rez_lock_f
	bne.s	.homed_emu		;never home emu here in setscreen calls
.home_emu:
	move	lace_rez(pc),d0		;d0 = active slot pos	(new for filter changes)
	cmp	#fail_slot,d0
	bne.s	.keep_slot
	move	replace_rez(pc),d0
.keep_slot:
	move.l	lpt_emu_sethome+LPT(pc),a0
	jsr	(a0)			;home emu
.homed_emu:
	clr	home_emu_f		;flag emu homed
.done_home_emu:
	clr	new_emu_f
	move	d2,SR			;restore interrupt mask
.fix_div_vars:
	move	SR,d2			;save interrupt mask in d2
	or	#$0700,SR		;disable interrupts
	move.l	line_a_base_p(pc),a0
	move.l	sc_emu_Xrez+SCD(pc),d0	;d0 = sc_emu_xrez.sc_emu_yrez
	move	d0,la_v_rez_vt(a0)	;store vertical pixel rez
	subq	#1,d0			;d0 = xrez.yrez-1
	move	d0,la_wk_ymax(a0)	;store max pixel Y coord
	move.l	la_gcurx(a0),d1		;d1 = gcurx.gcury
	cmp	d0,d1
	bls.s	.keep_mouse_y
	move	d0,d1			;d1 = gcurx.min(gcury,wk_ymax)
.keep_mouse_y:
	addq	#1,d0			;d0 = xrez.yrez
	swap	d0			;d0 = yrez.xrez
	move	d0,la_v_rez_hz(a0)	;store horizontal pixel rez
	subq	#1,d0			;d0 = yrez.xrez-1
	move	d0,la_wk_xmax(a0)	;store max pixel X coord
	swap	d1			;d1 = min(gcury,wk_ymax).gcurx
	cmp	d0,d1
	bls.s	.keep_mouse_x
	move	d0,d1			;d1 = min(gcury,wk_ymax).min(gcurx,wk_xmax)
.keep_mouse_x:
	swap	d1			;d1 = min(gcurx,wk_xmax).min(gcury,wk_ymax)
	move.l	d1,la_gcurx(a0)		;store limited mouse position
	addq	#1,d0			;d0 = yrez.xrez
	lsr	#3,d0			;d0 = yrez.xrez/(char_width)
	subq	#1,d0			;d0 = yrez.xrez/8-1
	move	d0,la_v_cel_mx(a0)	;store max text cursor pixel offset
	clr	d0			;d0 = yrez.0
	swap	d0			;d0 = yrez
	move	la_v_cel_ht(a0),d1
	bne.s	.keep_cel_ht
	moveq	#8,d1			;assume 8pix height if none defined
	cmp	#400,d0
	blo.s	.keep_cel_ht
	moveq	#16,d1
.keep_cel_ht:
	divu	d1,d0
	subq	#1,d0
	move	d0,la_v_cel_my(a0)		;store max text cursor Y coord
	move	sc_emu_bytewid+SCD(pc),d0	;d0 = GEM bytes per line
	move	d0,la_bytes_lin(a0)
	move	d0,la_width(a0)
	mulu	la_v_cel_ht(a0),d0
	move	d0,la_v_cel_wr(a0)	;store distance between text lines
;fix la_v_cur_ad			;NB: vt52 only supports 8pix char width
	clr.l	d0
	move	la_v_cur_xy(a0),d0	;d0 = column = byte index in mono line
	ror.l	#1,d0			;d0 = word index in mono line (hiword=byteflag)
	move	la_planes(a0),d1
	mulu	d0,d1			;d1 = word index in real line
	add	d1,d1			;d1 = byte offset of real line word
	clr	d0
	rol.l	#1,d0			;d0 = byte index in word
	add	d0,d1			;d1 = byte offset in line
	move	la_v_cur_xy+2(a0),d0	;d0 = row
	mulu	la_v_cel_wr(a0),d0	;d0 = row byte offset
	add.l	d0,d1			;d1 = byte offset of character
	clr.l	d0
	move	la_v_cur_of(a0),d0
	add.l	d0,d1			;d1 = adj byte offset
	add.l	(_v_bas_ad).w,d1	;d1 -> screen byte
	move.l	d1,la_v_cur_ad(a0)	;store screen adr of text cursor
;
	move	d2,SR			;restore interrupt mask
	bsr	prep_testscan
	movem.l	(sp)+,d0-d2/a0
	rts
;----------------------------------------------------------------------------
;End of:	'refix' subs
;----------------------------------------------------------------------------
;Start of:	'fix_screen' sub
;----------------------------------------------------------------------------
fix_screen_supx:			;affects no register except CCR
	movem.l	d0-d1/a0-a1,-(sp)
	move	SR,-(sp)		;save interrupt mask
	or	#$0700,SR		;disable interrupts
	lea	SCREEN_tab(pc),a1	;a1 -> screen slot structure table
	move	lace_rez(pc),d0		;d0 = requested slot
	move	d0,d1
	asl	#sc_log2size,d1		;d1 = offset to requested slot
	tst	sc_def_mark(a1,d1)	;need overscan ?
	bpl.s	.fix_thin
.fix_wide:				;lace_rez needs overscan
	tst	lacesize_f
	bne	.fix_it_ok
.fix_wide_bad:				;lace_rez wants missing overscan
	move	sc_rez(a1,d1),d0	;d0 = hard rez of lost rez
	and	VDO_rez_mask(pc),d0	;lock to slot_pos 0..7 at disable 
	bra.s	.fix_it_up
;
.fix_thin:				;lace_rez is a non_overscan type
	tst	lacesize_f
	beq	.fix_it_ok
.fix_thin_bad:				;lace_rez doesn't want present overscan
	move	sc_rez(a1,d1),d0	;d0 = hard rez of lost rez
	and	VDO_rez_mask(pc),d0	;lock to existing slot_pos
	addq	#norm_slots,d0		;relock to overscan slot_pos 8..15 at enable 
.fix_it_up:				;here d0 = needed replacement slot pos
	st	sizefail_f		;flag size failure
	cmp	#fail_slot,lace_rez
	bne.s	.accept_fail
.negate_fail:				;This failure is actually a late success!
	move	fail_rez(pc),d0		;d0 = slot pos of old failure
	move	d0,lace_rez		;this becomes new lace_rez !
	lea	SCREEN_tab(pc),a1	;a1 -> screen slot structure table
	asl	#sc_log2size,d0		;d0 = index for requested slot
	lea	(a1,d0),a1		;a1 -> requested slot data
	bra.s	.copy_fail_data
	
.accept_fail:
	move	lace_rez(pc),fail_rez	;new fail_rez = lace_rez
	move	#fail_slot,lace_rez	;new lace_rez = fail_slot
	move	d0,replace_rez
	asl	#sc_log2size,d0		;d0 = index for replacement slot
	lea	sc_sizeof(a1,d0),a0	;a0 -> beyond replacement data
	lea	sc_sizeof+fail_slot*sc_sizeof(a1),a1	;a1 -> beyond fail_slot data
	REPT	sc_sizeof/4
	move.l	-(a0),-(a1)		;copy data to fail_slot
	ENDR				;a1 -> fail_slot, filled with new phys data
;
	move	fail_rez(pc),d0
	lea	SCREEN_tab(pc),a0	;a0 -> screen slot structure table
	asl	#sc_log2size,d0		;d0 = index for requested slot
	lea	(a0,d0),a0		;a0 -> requested slot data
	move.b	sc_emu_rez(a0),sc_emu_rez(a1)
	bmi.s	.keep_rep_data
	move.l	sc_emu_Xrez(a0),sc_emu_Xrez(a1)
	move.l	sc_emu_planes(a0),sc_emu_planes(a1)
.keep_rep_data:
;Here a1 -> slot defining both physical and logical rez
.copy_fail_data:
	lea	sc_sizeof+SCD(pc),a0	;a0 -> beyond SCD data
	lea	sc_sizeof(a1),a1	;a1 -> beyond fail_slot data
	move.b	sc_emu_rez+SCD(pc),d1	;save current sc_emu_rez in d1
	REPT	sc_sizeof/4
	move.l	-(a1),-(a0)		;copy data to SCD
	ENDR
;
	move	fail_rez(pc),d0
	cmp	fixed_rez(pc),d0	
	bne.s	.new_failed
.old_failed:				;The failed rez was recently active
	tst.b	sc_emu_rez(a0)		;test new sc_emu_rez
	bmi.s	.flag_non_activation
	st	home_emu_f+1		;flag filter homing need
.flag_non_deactivation:
	sf	new_emu_f+1
	bra.s	.done_fail_rez
;
.flag_non_activation:
	sf	new_emu_f
	bra.s	.done_fail_rez
;
.new_failed:				;The failed rez was not recently active
	tst.b	sc_emu_rez(a0)		;test new sc_emu_rez
	bmi.s	.flag_new_non_emu
.flag_new_emu:
	st	home_emu_f+1		;flag filter homing need
	tst.b	d1			;test old sc_emu_rez
	bpl	.flag_non_deactivation
.flag_activation:
	st	new_emu_f
	bra.s	.done_fail_rez
;
.fix_it_ok:
	sf	sizefail_f		;flag size success
	cmp	fixed_rez(pc),d0
	beq.s	.norm_exit
;
	lea	sc_sizeof+SCD(pc),a0	;a0 -> beyond SCD data
	lea	sc_sizeof(a1,d1),a1	;a1 -> beyond requested slot data
	move.b	sc_emu_rez+SCD(pc),d1	;save current sc_emu_rez in d1
	REPT	sc_sizeof/4
	move.l	-(a1),-(a0)		;copy data from requested slot
	ENDR
;
	tst.b	sc_emu_rez(a0)		;test new sc_emu_rez
	bpl.s	.flag_new_emu
.flag_new_non_emu:
	tst.b	d1			;test old sc_emu_rez
	bmi	.flag_non_activation
.flag_deactivation:
	st	new_emu_f+1
.done_fail_rez:
	move.l	logbphys_p(pc),d0
	tst.b	sc_emu_rez(a0)		;test new sc_emu_rez
	bpl.s	.set_logbase
	add.l	sc_log_offs(a0),d0
.set_logbase:
	move.l	d0,logbase_p
;
	bset	#7,sc_intfx_f(a0)	;mark border unblanked
.norm_exit:
	move	lace_rez(pc),fixed_rez
	move	(sp)+,SR		;restore interrupt mask
	movem.l	(sp)+,d0-d1/a0-a1
	rts
;----------------------------------------------------------------------------
;End of:	'fix_screen' sub
;----------------------------------------------------------------------------
;Start of:	'fix_pbase' sub
;----------------------------------------------------------------------------
fix_pbase:
	tst	d0
	bmi.s	.base_query
	tst.b	sc_emu_rez+SCD		;test sc_emu_rez
	bmi.s	.even_base		;force even frame in non-emu modes
	btst	#0,d0
	bne.s	.odd_base
.even_base:
	move.l	lockbase_p(pc),d0
	bra.s	.set_base
;
.odd_base:
	move.l	ext_base_p(pc),d0
.set_base:
	sub.l	lpt_lockbase_p+LPT(pc),d0
	add.l	d0,lpt_lockbase_p+LPT
	add.l	d0,lpt_physbase_p+LPT
	tst	test_scan_p
	beq.s	.done_test
	add.l	d0,test_base_p
	add.l	d0,test_scan_p
.done_test
	move.l	lpt_lockbase_p+LPT(pc),d0
	lsr	#8,d0
	move.l	d0,(hw_vbase2-1).w
	rts
;
.base_query:
	btst	#0,d0
	beq.s	.ret_even_base
.ret_odd_base:
	move.l	ext_base_p(pc),d0
	rts
;
.ret_even_base:
	move.l	lockbase_p(pc),d0
	rts
;
;End of	'fix_pbase' sub
;----------------------------------------------------------------------------
blank_border_supx:
	bclr	#7,sc_intfx_f+SCD	;flag border blanked
	bsr	rez_mask_supx
	move.l	d0,d4			;d4 = blank_mask  (-1 or 0)
	move.l	lpt_lockbase_p+LPT(pc),a0	;a0 -> top garbage
	cmp.l	lpt_physbase_p+LPT(pc),a0
	bne	.blanked_bot		;refuse if another screen is active
	move.l	sc_log_offs+SCD(pc),d1	;d1 = byte moves needed
	beq.s	.blanked_top		;branch if no top garbage
	lsr.l	#1,d1			;d1 = 2 * long moves needed = word moves needed
	move.l	d1,d0
	lsr.l	#6,d0			;d0 = loops needed - 1
	and	#$3F,d1			;d1 = 2 * moves for first loop
	bclr	#0,d1
	beq.s	.no_extra_word
	move	d4,(a0)+
.no_extra_word:
	neg	d1			;d1 = negative offset for first move
	jmp	.blank_top_0(pc,d1)
;
.blank_top_lp:
	REPT	32
	move.l	d4,(a0)+
	ENDR
.blank_top_0:
	dbra	d0,.blank_top_lp
.blanked_top:
;Here a0 -> first visible useful pixel
	move	sc_bytewidth+SCD(pc),d0
	move	sc_Xrez+SCD(pc),d1
	move	hard_rez(pc),d2
	move.b	.log2_t(pc,d2),d2	;d2 = log2(pix/byte)
	lsr	d2,d1			;d1 = useful bytes/line
	sub	d1,d0			;d0 = garbage bytes/line
	and	#-2,d0			;enforce word boundary
	bgt.s	.blank_ltrt_start	;go blank garbage parts of useful lines
	move	sc_bytewidth+SCD(pc),d0
	mulu	sc_Yrez+SCD(pc),d0
	add.l	d0,a0			;a0 -> first bottom garbage line
	bra	.blanked_ltrt		;go blank bottom garbage lines
;
.log2_t:
	dc.b	1,2,3,0,1,2,3,0
;
.blank_ltrt_start:
;Here d0 = garbage bytes/line == 2 * garbage words/line
	lea	.blank_ltrt_0(pc),a1
	suba	d0,a1			;a1 -> loop target to blank garbage of one line
	move	sc_Yrez+SCD(pc),d2	;d2 = useful line count
	subq	#2,d2			;d2 = dbra, but excluding last line
.blank_ltrt_lp:
	adda	d1,a0			;a0-> garbage beyond useful part of line
	jmp	(a1)
;
	REPT	80
	move	d4,(a0)+
	ENDR
.blank_ltrt_0:
	dbra	d2,.blank_ltrt_lp
	adda	d1,a0			;a0-> garbage beyond useful part of last line
.blanked_ltrt:
;Here a0 -> bottom garbage, possibly including right garbage of last visible line
;
	move.l	lpt_lockbase_p+LPT(pc),d1	;d1 -> start of screen, incl top garbage
	add.l	sc_reen_bytes+SCD(pc),d1	;d1 -> end of screen, incl bottom garbage
	sub.l	a0,d1				;d1 = bytes of bottom garbage
	asr.l	#1,d1				;d1 = 2 * long moves needed
	move.l	d1,d0
	ble.s	.blanked_bot
	lsr.l	#6,d0			;d0 = loops needed (passes -1)
	and	#$3E,d1			;d1 = 2 * moves for first loop
	neg	d1
	jmp	.blank_bot_0(pc,d1)
;
.blank_bot_lp:
	REPT	32
	move.l	d4,(a0)+
	ENDR
.blank_bot_0:
	dbra	d0,.blank_bot_lp
.blanked_bot:
	rts
;----------------------------------------------------------------------------
clear_screen_supx:
	bsr	blank_border_supx
	bra	clear_blit_sub
;----------------------------------------------------------------------------
clear_locked_screen:
	moveq	#-1,d0
	move	hard_rez(pc),d1
	cmpi	#6,d1
	beq.s	.clear_mono
	cmpi	#2,d1
	bne.s	.clear_locked_start
.clear_mono:
	btst	#0,(hw_pal+1).w
	bne.s	.clear_locked_start
	clr.l	d0
.clear_locked_start:
	move.l	lpt_lockbase_p+LPT(pc),a0
	move.l	lockbase_size(pc),d1
	and.l	#-$100,d1
	lsr.l	#4,d1
	subq.l	#1,d1			;d1 = (rounded size)/16 - 1
	swap	d1
.clear_locked_lp_1:
	swap	d1
.clear_locked_lp_2:
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbra	d1,.clear_locked_lp_2
	swap	d1
	dbra	d1,.clear_locked_lp_1
	rts
;----------------------------------------------------------------------------
rez_mask_supx:
	move	hard_rez(pc),d1
	move.b	.mono_flag_t(pc,d1),d0
	bne.s	.rez_mask_mono
.rez_mask_color:
	tst.b	sc_backg_f+SCD
	bne.s	.rez_mask_ones
.rez_mask_zeros:
	moveq	#0,d0
	rts
;
.mono_flag_t:
	dc.b	0,0,1,0,0,0,1,0
;
.rez_mask_mono:
	btst	#0,(hw_pal+1).w
	beq.s	.rez_mask_zeros
.rez_mask_ones:
	moveq	#-1,d0
	rts
;----------------------------------------------------------------------------
prep_testscan:
	clr.l	d0
	move	sc_bytewidth+SCD(pc),d0	;d0 = total bytes/line
	moveq	#43,d1
	mulu	d0,d1			;d1 = 43 * bytes/line
	move.l	d1,test_downstep
;
	clr.l	d1
	move	sc_Xrez+SCD(pc),d1	;d1 = visible pix/line
	move	sc_rez+SCD(pc),d2	;d2 = physical rez
	move.b	.log2_t(pc,d2),d2	;d2 = log2(pix/byte) of active rez
	lsr	d2,d1			;d1 = visible bytes/line for used rez (hard)
;
	move.l	d0,test_horoffs
	sub.l	d1,test_horoffs
	subq.l	#2,test_horoffs		;test_horoffs = invis bytes/line - 2
	ble.s	.refuse_test
;
	move.l	lpt_lockbase_p+LPT(pc),a0	;a0 -> physical screen base (incl invis lines)
	move.l	sc_log_offs+SCD(pc),d2	;d2 = log_offs
	add.l	d2,a0			;a0 -> logbase
	adda	d1,a0			;a0 -> logbase + visibytes/ln
	move.l	a0,a1			;a1 -> logbase + visibytes/ln
	divu	d0,d2			;d2 = whole invis lines in log_offs
	mulu	d0,d2			;d2 = bytes of whole lines in log_offs
	suba.l	d2,a1	;a1 -> logbase + visib/ln - bytes of whole lines in log_offs
;a1 -> 1'st byte in 1'st whole line of log_offs that would be invisible (right border)
;      even if that line was based at logbase, which it is aligned to
;      This will be used as base for the bit corruption test scan
	move.l	a1,test_base_p
	move.l	a1,test_scan_p
	move	sc_Yrez+SCD(pc),d1		;d1 = visib_lines
	addi	#10,d1				;d1 = visib_lines + 10
	mulu	d1,d0		;d0 = total bytes for (visible + 10) lines
	adda.l	d0,a0		;a0 -> logbase + bytes for ( visible + 11 ) lines
	move.l	a0,test_maxpos
	rts
.log2_t:
	dc.b	1,2,3,0,1,2,3,0		;log2(pix/byte) of each rez
;So:
;test_base_p	-> Beyond 'visible' pixels of top invisible line
;test_scan_p	-> Initially = test_base_p,  and reset to that at cycle end
;test_downstep	steps test_scan_p forward (down) 43 lines until passing
;test_maxpos	-> base of twelfth invisible line below screen (ends cycle)
;all unless the test is needless, which nulls test_scan_p
;
.refuse_test:
	clr.l	test_scan_p
	rts
;----------------------------------------------------------------------------
;link_local changes no registers except SP & CCR.
;
link_local:
	movem.l	d0/a0,-(sp)			;push entry d0/a0
	lea	frame_f_tab+frame_limit(pc),a0
	moveq	#frame_limit-1,d0
.link_lp:
	tas	-(a0)				;reserve area flag
	dbpl	d0,.link_lp			;loop until free found
	bpl.s	.link_it			;exit if all taken
	movem.l	(sp)+,d0/a0			;restore entry d0/a0
	rts			;exit MI with old stack active
;
.link_it:
	lea	frame_p_tab(pc),a0
	lsl	#2,d0
	move.l	(a0,d0),a0			;a0 -> new frame end
	exg	a0,sp				;sp -> frame_end,  a0 -> old stack
	pea	12(a0)				;push precall sp
	move.l	8(a0),-(sp)			;repush retadr
	movem.l	(a0),d0/a0			;restore entry d0/a0
	rts			;exit PL with new stack,  top -> precall stack
;------------------------------------
;unlk_local changes no registers except SP & CCR.
;
unlk_local:
	movem.l	d0/a0,-(sp)			;push entry d0/a0
	move.l	sp,d0
	sub.l	#frame_base,d0
	blo.s	.unlk_exit
	cmp.l	#frame_size*frame_limit,d0
	bhs.s	.unlk_exit
	divu	#frame_size,d0
	lea	frame_f_tab(pc),a0
	tst.b	(a0,d0)
	bpl.s	.unlk_exit
	lsl	#2,d0
	lea	frame_p_tab(pc),a0
	move.l	(a0,d0),a0			;a0 -> old frame end
	move.l	-4(a0),a0			;a0 = old sp to be restored
	exg	a0,sp				;sp = restored,  a0 -> recent stack
	move.l	8(a0),-(sp)			;repush retadr
	move.l	4(a0),-(sp)			;repush entry a0
	move.l	(a0),-(sp)			;repush entry d0
	lsr	#2,d0
	lea	frame_f_tab(pc),a0
	bclr	#7,(a0,d0)			;release area flag
.unlk_exit:
	movem.l	(sp)+,d0/a0			;restore entry d0/a0
	rts	;exit with restored stack, unchanged registers (except CCR)
;----------------------------------------------------------------------------
;End of	Diverse routines
;----------------------------------------------------------------------------
;	Setup Routines follow
;----------------------------------------------------------------------------
self_setup:
	bsr	test_size_supx
	bsr	refix_supx
	xbios	Setscreen,-1.w,-1.w,hard_rez(pc)
	bsr	refix_supx
	bsr	blank_border_supx
	xbios	Dosound,selfset_sound(pc)
	rts
;----------------------------------------------------------------------------
copy_orig_screen:
	movem.l	d0-d7/a0-a6,-(sp)
	st	fixed_rez
	st	prev_slot
	bsr	refix_supx
	move.l	line_a_base_p(pc),a3
	lea	blit_parm_t(pc),a6
	move.l	save_screen_p(pc),d0
	ble.s	.skip_content
	move.l	d0,blt_s_form(a6)
	move	orig_bytes_lin(pc),blt_s_nxln(a6)
	move.l	(_v_bas_ad).w,blt_d_form(a6)
	move	la_bytes_lin(a3),blt_d_nxln(a6)
	bsr.s	orig_blit_sub		;restore contents of original screen
	gemdos	Mfree|_ind,save_screen_p(pc)
	clr.l	save_screen_p
.skip_content:
	move.l	orig_cur_xy(pc),la_v_cur_xy(a3)
	bsr	refix_supx
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;----------------------------------------------------------------------------
orig_blit_sub:
	movem.l	d0-d2/a0-a2/a6,-(sp)
	move.l	line_a_base_p(pc),a3
	lea	blit_parm_t(pc),a6
	move.l	orig_rez_xy(pc),blt_b_wd(a6)	;block width & height
	move	la_planes(a3),blt_plane_ct(a6)
	move.l	#$03030303,blt_op_tab(a6)	;op for simple move
	clr.l	blt_s_xmin(a6)			;s xmin = ymin = 0
	clr.l	blt_d_xmin(a6)			;d xmin = ymin = 0
	move	la_planes(a3),d0
	add	d0,d0
	move	d0,blt_s_nxwd(a6)
	move	d0,blt_d_nxwd(a6)
	cmp	#1,la_planes(a3)
	sne	d0
	and	#2,d0
	move	d0,blt_s_nxpl(a6)
	move	d0,blt_d_nxpl(a6)
	clr.l	blt_p_addr(a6)
	_a_bitblt	;move old screen content to new screen
	movem.l	(sp)+,d0-d2/a0-a2/a6
	rts
;----------------------------------------------------------------------------
clear_blit_sub:
	movem.l	d0-d2/a0-a2/a6,-(sp)
	move.l	line_a_base_p(pc),a3
	lea	blit_parm_t(pc),a6
	move	la_v_rez_hz(a3),blt_b_wd(a6)	;block width
	move	la_v_rez_vt(a3),blt_b_ht(a6)	;block height
	move	la_planes(a3),blt_plane_ct(a6)
	move.l	#0,blt_op_tab(a6)		;op to clear area to colour 0
	clr.l	blt_s_xmin(a6)			;s xmin = ymin = 0
	clr.l	blt_d_xmin(a6)			;d xmin = ymin = 0
	move.l	(_v_bas_ad).w,d0
	move.l	d0,blt_s_form(a6)
	move.l	d0,blt_d_form(a6)
	move	la_planes(a3),d0
	add	d0,d0
	move	d0,blt_s_nxwd(a6)
	move	d0,blt_d_nxwd(a6)
	move	la_bytes_lin(a3),d0
	move	d0,blt_s_nxln(a6)
	move	d0,blt_d_nxln(a6)
	cmp	#1,la_planes(a3)
	sne	d0
	and	#2,d0
	move	d0,blt_s_nxpl(a6)
	move	d0,blt_d_nxpl(a6)
	clr.l	blt_p_addr(a6)
	_a_bitblt	;move old screen content to new screen
	movem.l	(sp)+,d0-d2/a0-a2/a6
	rts
;----------------------------------------------------------------------------
user_setup:
	move	opnwk_flag(pc),-(sp)
	sf	opnwk_flag
	move.l	lpt_emu_block_p+LPT(pc),a0
	move.l	a0,d0
	ble.s	.emu_blocked
	bset	#lace_2_lemu_b,(a0)
.emu_blocked:
	bset	#user_setup_b,int_protect_f
	bsr	save_2_colors_supx
	xbios	Setscreen,-1.w,-1.w,hard_rez(pc)
	move	hard_rez(pc),setent_rez
	move	emu_rez(pc),setent_emu_rez
setup_reentry:
	clr	cmd_retval
	bsr	help_cmd
.setup_loop:
	bsr	clear_locked_screen
	bsr	init_setup_limits
	clr.l	d0
	bsr	draw_screenbox
	bsr	disp_SCD_info
	bsr	get_setup_char
	bsr	setup_command
	tst	cmd_retval
	beq.s	.setup_loop
exit_user_setup:
	bsr	fix_screen_supx
	gemdos	Cconws,clear_screen_ESC_s(pc)
	move	cmd_retval,d0
	cmp	#1,d0
	beq.s	.exit_normal
	cmp	#2,d0
	bne.s	.exit_saved
	gemdos	Cconws,self_fpath_s(pc)
	lea	not_found_s(pc),a0
	bra.s	.exit_wait
;
.exit_saved:
	lea	set_saved_s(pc),a0
.exit_wait:
	bsr	mess_bl_press
.exit_normal:
	move	emu_rez(pc),d0
	cmp	setent_emu_rez(pc),d0
	beq.s	exit_rest_2_colors
	gemdos	Cconws,exitwarn_s(pc)
	bsr.s	get_setup_char
	cmp	#'X',d0
	bne	setup_reentry
	bra.s	exit_setup
;
exit_rest_2_colors:
	bsr	rest_2_colors_supx
exit_setup:
	bclr	#user_setup_b,int_protect_f
	move.l	lpt_emu_block_p+LPT(pc),a0
	move.l	a0,d0
	ble.s	.emu_unblocked
	bclr	#lace_2_lemu_b,(a0)
.emu_unblocked:
	move	(sp)+,opnwk_flag
	rts
;
;
get_setup_char:
	gemdos	Cnecin
	cmp	#'a',d0
	blo.s	.exit
	cmp	#'z',d0
	bhi.s	.exit
	and	#$5F,d0
.exit:
	move.l	d0,setup_char
	rts
;----------------------------------------------------------------------------
;	Setup command interpreter
;----------------------------------------------------------------------------
setup_command:
	move.l	setup_char(pc),d0
	lea	.setup_cmd_tab(pc),a0
	clr.l	d1
	moveq	#-1,d2
.setup_cmd_lp_1:
	addq	#1,d2
.setup_cmd_lp_2:
	move.b	(a0)+,d1
	beq	.try_scan_codes
	cmp.b	d1,d0
	bne.s	.setup_cmd_lp_1
	asl	#2,d2
	move.l	.setup_sub_tab(pc,d2),a0
	jmp	(a0)
;
.setup_cmd_tab:
	dc.b	'QS/*-+ABLMH'
	dc.b	'0123456789'
	dc.b	'CI'
	dc.b	0
	dc.b	$62,$4B,$4D,$48,$50
	dc.b	0
	even
;
.setup_sub_tab:
	dc.l	quit_cmd,save_conf_cmd,move_left_cmd,move_right_cmd
	dc.l	move_up_cmd,move_down_cmd,auto_switch_cmd,bitimage_cmd
	dc.l	rez_l_cmd,rez_m_cmd,rez_h_cmd
	dc.l	slot_cmd,slot_cmd,slot_cmd,slot_cmd
	dc.l	slot_cmd,slot_cmd,slot_cmd,slot_cmd
	dc.l	slot_cmd,slot_cmd
	dc.l	color_cmd,intfix_cmd
;
	dc.l	help_cmd,shrink_left_cmd,grow_right_cmd,shrink_up_cmd
	dc.l	grow_down_cmd
;
;
.try_scan_codes:
	clr	d0
	swap	d0
	tst	d0
	bne	.setup_cmd_lp_2
	rts
;
;----------------------------------------------------------------------------
;End of	Setup command interpreter
;----------------------------------------------------------------------------
;
;----------------------------------------------------------------------------
;	Setup command subroutines
;----------------------------------------------------------------------------
;
save_conf_cmd:
	bsr	clear_locked_screen
	move	#2,cmd_retval
	gemdos	Fopen,self_fpath_s(pc),#1
	tst	d0
	bmi.s	.exit
	move	#3,cmd_retval
	move	d0,conf_handle
	gemdos	Fseek,#ph_textbeg+conf_buff-rz,conf_handle(pc),#0
	gemdos	Fwrite,conf_handle(pc),#conf_size,conf_buff(pc)
	gemdos	Fclose,conf_handle(pc)
.exit:
null_cmd:
	rts
;
;
help_cmd:
	bsr	clear_locked_screen
	gemdos	Cconws,home_inv_s
	gemdos	Cconws,title_mess_s(pc)
	gemdos	Cconws,setup_help_s(pc)
	bra	get_setup_char
;
;
shrink_left_cmd:
	move	#320,d0
	cmp	sc_Xrez+SCD(pc),d0
	bge	null_cmd
	sub	#16,sc_Xrez+SCD
	bra.s	refix_cmd
;
;
grow_right_cmd:
	move	temp_maxwidth,d0
	cmp	sc_Xrez+SCD(pc),d0
	ble	null_cmd
	add	#16,sc_Xrez+SCD
	bra.s	refix_cmd
;
;
shrink_up_cmd:
	move	#200,d0
	cmp	sc_Yrez+SCD(pc),d0
	bge	null_cmd
	move	temp_highstep,d0
	sub	d0,sc_Yrez+SCD
	bra.s	refix_cmd
;
;
grow_down_cmd:
	move	temp_maxheight,d0
	sub	temp_highstep,d0
	cmp	sc_Yrez+SCD(pc),d0
	blt	null_cmd
	move	temp_highstep,d0
	add	d0,sc_Yrez+SCD
	bra	refix_cmd
;
;
refix_cmd:
	movem.l	d0/a0/a1,-(sp)
	lea	SCD(pc),a0
	move.l	sc_Xrez(a0),sc_emu_Xrez(a0)
	move	sc_bytewidth(a0),sc_emu_bytewid(a0)
	move	lace_rez(pc),d0
	cmp	#fail_slot,d0
	bne.s	.good_refix
	move	sc_rez(a0),d0
.good_refix:
	move	d0,lace_rez
	mulu	#sc_sizeof,d0
	lea	SCREEN_tab(pc),a1
	add.l	d0,a1
	move	#sc_sizeof-1,d0
.move_lp:
	move.b	(a0)+,(a1)+
	dbra	d0,.move_lp
	movem.l	(sp)+,d0/a0/a1
	bsr	test_size_supx
	st	fixed_rez
	st	prev_slot
	bra	refix_supx
;
;
move_left_cmd:
	move.l	temp_offsstep,d0
	neg.l	d0
	bra.s	move_log_offs_cmd
;
;
move_right_cmd:
	move.l	temp_offsstep,d0
	bra.s	move_log_offs_cmd
;
;
move_up_cmd:
	move	sc_bytewidth+SCD(pc),d0
	neg.l	d0
	bra.s	move_log_offs_cmd
;
;
move_down_cmd:
	move	sc_bytewidth+SCD(pc),d0
move_log_offs_cmd:
	ext.l	d0
	add.l	d0,sc_log_offs+SCD
	add.l	d0,logbase_p
	bra	refix_cmd
;
;
auto_switch_cmd:
	xbios	Supexec,auto_switch_supx
	move	sc_rez+SCD(pc),d3		;d3 = wanted rez
	bra	set_slot_sub
;
;
lace_auto_sense:
	bsr	test_size_supx
	bsr	fix_screen_supx
	move.b	lacesize_f(pc),d0
	rts	;$00 == Normal screen  $FF == Overscan screen
;
;
lace_auto_switch:
auto_switch_supx:
	bsr	test_size_supx
	bsr	fix_screen_supx
	tst	lacesize_f
	beq.s	.set_large
.set_small:
	bsr	small_lace_supx
	bra.s	.done_switch
;
.set_large:
	bsr	large_lace_supx
.done_switch:
	bsr	sync_fall_supx
	bsr	sync_lace_supx
	bsr	refix_supx
	bsr	fix_la_workout
	bsr	blank_border_supx
	rts
;
;
bitimage_cmd:
	clr.l	d0
	move.b	sc_hardc_f+SCD(pc),d0
	addq	#1,d0
	divu	#3,d0
	swap	d0
	move.b	d0,sc_hardc_f+SCD
	bra	refix_cmd
;
;
slot_cmd:
	move.l	setup_char(pc),d3
	sub	#'0',d3			;d3 = prel slot code
	move	d3,d0
	addq	#norm_slots,d0
	cmp	#slot_limit,d0
	blo.s	.got_index
	sub	#slot_limit,d0
.got_index:
	move	d0,d4			;d4 = slot index
	mulu	#sc_sizeof,d0
	lea	SCREEN_tab(pc),a3
	add.l	d0,a3			;a3 -> slot data
	move	hard_rez(pc),d0
	cmp	VDO_high_rez(pc),d0
	beq.s	slot_h_cmd
	lea	slotwarn_color_s(pc),a0
	bra.s	slotwarn_common
;
slot_h_cmd:
	lea	slotwarn_mono_s(pc),a0
slotwarn_common:
	tst	sc_def_mark(a3)		;slot defined ?
	beq.s	slot_cmd_sub		;else go force definition
	move	hard_rez,d0
	move	sc_rez(a3),d1
	and	VDO_rez_mask(pc),d1
	cmp	VDO_high_rez(pc),d1
	beq.s	.want_high_rez
.want_normal_rez:
	cmp	VDO_high_rez(pc),d0
	bne.s	slot_cmd_sub
	bra.s	.want_wrong_rez
;
.want_high_rez:
	cmp	VDO_high_rez(pc),d0
	beq.s	slot_cmd_sub
.want_wrong_rez:	
	bsr	show_ia0
	lea	slotwarn_com1_s(pc),a0
;
	bsr	show_ia0
	bsr	get_setup_char
	cmp	#'U',d0
	beq.s	set_slot_newrez
	cmp	#'E',d0
	bne	null_cmd
;
	cmp	#3*norm_slots,d4
	bhs.s	slot_erase
	lea	slotwarn_com2_s(pc),a0
	bsr	show_ia0
	bsr	get_setup_char
	bra	null_cmd
;
slot_erase:
	clr	sc_def_mark(a3)
	bra.s	set_slot_sub
;
slot_cmd_sub:
	gemdos	Cconws,slot_sure_s(pc)
	bsr	get_setup_char
	cmp	#'Y',d0
	bne	null_cmd
set_slot_sub:
	add	#slot_limit,d3		;force Setscreen to take slot code
	xbios	Setscreen,-1.w,-1.w,d3
	rts
;
set_slot_newrez:
	bsr	set_slot_sub
	bsr	refix_cmd
	bra	set_slot_sub
;
;
rez_l_cmd:
	move	#0,d3
	lea	rezwarn_mono_s(pc),a0
	bra.s	rez_cmd_common	
;
rez_m_cmd:
	move	#1,d3
	lea	rezwarn_mono_s(pc),a0
	bra.s	rez_cmd_common	
;
rez_h_cmd:
	move	#2,d3
	lea	rezwarn_color_s(pc),a0
rez_cmd_common:
	cmp	sc_rez+SCD(pc),d3	;wanted rez already active ?
	beq	null_cmd
	move	lace_rez,d4		;d4 = pre_cmd slot index
	cmp	#norm_slots*3,d4	;is it legal to change rez of this slot ?
	bge.s	.rez_cmd_legal
.rez_fixslot:
	lea	slot_fix_s(pc),a0
	bra	mess_bl_press
;
.rez_cmd_legal:				;d4 = pre_cmd slot index [9..12]
	move	d4,d5
	subq	#norm_slots,d5		;d5 = pre_cmd slot code [6..9]
	move	hard_rez(pc),d0
	cmp	VDO_high_rez(pc),d3
	beq.s	.want_high_rez
.want_normal_rez:
	cmp	VDO_high_rez(pc),d0
	bne.s	.change_rez
	bra.s	.want_wrong_rez
;
.want_high_rez:
	cmp	VDO_high_rez(pc),d0
	beq.s	.change_rez
.want_wrong_rez:	
;
	bsr	show_ia0		;show specific change warning
	lea	rezwarn_common_s(pc),a0
	bsr	show_ia0		;show general change warning
	bsr	get_setup_char
	cmp	#'C',d0
	bne	null_cmd
	bra.s	change_rez_sub
;
.change_rez:
	gemdos	Cconws,rez_sure_s(pc)
	bsr	get_setup_char
	cmp	#'Y',d0
	bne	null_cmd
change_rez_sub:				;d3 = new rez  d4 = slot index  d5 = slot code
	addq	#norm_slots,d3		;d3 = slot index for norm slot of new rez
	mulu	#sc_sizeof,d3		;d3 = offset of norm slot of new rez
	mulu	#sc_sizeof,d4		;d4 = offset of pre_cmd slot
	lea	SCREEN_tab(pc),a1
	lea	(a1,d3),a0		;a0 -> norm slot data of new rez
	lea	(a1,d4),a1		;a1 -> pre_cmd slot data
;
	REPT	sc_sizeof/4
	move.l	(a0)+,(a1)+		;copy data from SCD to slot
	ENDR
;
	move	d5,d3			;d3 = slot code
	bra	set_slot_newrez		;activate slot
;
;
quit_cmd:
	move	#1,cmd_retval
	rts
;
;
color_cmd:
	bchg	#0,sc_backg_f+SCD
	bra	refix_cmd
;
;
intfix_cmd:
	bchg	#6,sc_intfx_f+SCD
	bra	refix_cmd
;
;----------------------------------------------------------------------------
;End of	Setup command subroutines
;----------------------------------------------------------------------------
;
;----------------------------------------------------------------------------
;	Various setup subroutines
;----------------------------------------------------------------------------
;
save_2_colors_supx:
	move	(hw_pal+6).w,temp_color_3
	move	(hw_pal+30).w,temp_color_15
	clr	(hw_pal+6).w
	clr	(hw_pal+30).w
	rts
;
;
rest_2_colors_supx:
	move	temp_color_3,(hw_pal+6).w
	move	temp_color_15,(hw_pal+30).w
	rts
;
;
init_setup_limits:
	move	emu_rez(pc),d0
	move	#4,temp_highstep		;lo = mid = 4
	moveq	#8,d1
	asr.l	d0,d1				;d1: lo = 8   mid = 4  hi = 2
	move.l	d1,temp_offsstep
	move	SCD+sc_bytewidth(pc),d1
	addq	#1,d0				;d0: lo = 1   mid = 2   hi = 3
	asl	d0,d1				;d1: lo*= 2   mid*= 4   hi*= 8
	and	#-16,d1				;d1 = max legal pix width for GEM
	move	d1,temp_maxwidth
	clr.l	d0
	move	sc_bytewidth+SCD(pc),d0
	subq	#1,d0
	add.l	sc_log_offs+SCD(pc),d0
	divu	sc_bytewidth+SCD(pc),d0	;d0 = lines affected by log_offs
	clr.l	d1
	move	sc_reen_lines+SCD(pc),d1
	sub.l	d0,d1				;d1 = max legal pix height for GEM
	move	d1,temp_maxheight
	cmp	sc_Yrez+SCD(pc),d1
	bge.s	.keep_Yrez
.shrink_Yrez:
	move	temp_highstep(pc),d0
	sub	d0,sc_Yrez+SCD
	cmp	sc_Yrez+SCD(pc),d1
	blt.s	.shrink_Yrez
	bsr	refix_cmd
.keep_Yrez:
	rts
;
;
set_la_colbits_d0:
	move.l	line_a_base_p(pc),a0
	move	d0,la_colbit0(a0)
	move	d0,la_colbit1(a0)
	move	d0,la_colbit2(a0)
	move	d0,la_colbit3(a0)
	rts
;
draw_box_edges:	;diagonal d0,d1 to d2,d3
	move.l	line_a_base_p(pc),a0
	clr	la_wmode(a0)
	move	#-1,la_lnmask(a0)
	move	#1,la_lstlin(a0)
	move	d0,la_x1(a0)
	move	d1,la_y1(a0)
	move	d2,la_x2(a0)
	move	d1,la_y2(a0)
	movem.l	d0-d7/a0-a6,-(sp)
	_a_line				;LINE-A
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	line_a_base_p(pc),a0
	move	d2,la_x1(a0)
	move	d1,la_y1(a0)
	move	d2,la_x2(a0)
	move	d3,la_y2(a0)
	movem.l	d0-d7/a0-a6,-(sp)
	dc.w	$A003	;LINE-A LINE
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	line_a_base_p(pc),a0
	move	d2,la_x1(a0)
	move	d3,la_y1(a0)
	move	d0,la_x2(a0)
	move	d3,la_y2(a0)
	movem.l	d0-d7/a0-a6,-(sp)
	_a_line				;LINE-A
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	line_a_base_p(pc),a0
	move	d0,la_x1(a0)
	move	d1,la_y1(a0)
	move	d0,la_x2(a0)
	move	d3,la_y2(a0)
	movem.l	d0-d7/a0-a6,-(sp)
	_a_line				;LINE-A
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;
draw_box_diagonals:	;diagonal d0,d1 to d2,d3 & d2,d1 to d0,d3
	move.l	line_a_base_p(pc),a0
	move	d0,la_x1(a0)
	move	d1,la_y1(a0)
	move	d2,la_x2(a0)
	move	d3,la_y2(a0)
	movem.l	d0-d7/a0-a6,-(sp)
	_a_line				;LINE-A
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	line_a_base_p(pc),a0
	move	d2,la_x1(a0)
	move	d1,la_y1(a0)
	move	d0,la_x2(a0)
	move	d3,la_y2(a0)
	movem.l	d0-d7/a0-a6,-(sp)
	_a_line				;LINE-A
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;
;
L1A64:
	dc.w	-1
;
sub_recfl:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	line_a_base_p(pc),a0
	move	#1,la_mfill(a0)
	clr	la_wmode(a0)
	move	d0,la_x1(a0)
	move	d1,la_y1(a0)
	move	d2,la_x2(a0)
	move	d3,la_y2(a0)
	lea	L1A64(pc),a1
	move.l	a1,la_patptr(a0)
	move	#1,la_patmsk(a0)
	clr	la_clip(a0)
	_a_recfl			;LINE-A
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;
;
draw_screenbox:
	bsr	set_la_colbits_d0
	clr	d0
	clr	d1
	move	SCD+sc_Xrez(pc),d2
	subq	#1,d2
	move	SCD+sc_Yrez(pc),d3
	subq	#1,d3
	bsr	draw_box_edges
	bra	draw_box_diagonals
;
;
disp_SCD_info:
	lea	setup_X_s(pc),a1
	move	sc_Xrez+SCD(pc),d0
	bsr	show_dec
	lea	setup_Y_s(pc),a1
	move	sc_Yrez+SCD(pc),d0
	bsr	show_dec
	lea	setup_Off_s(pc),a1
	move.l	sc_log_offs+SCD(pc),d0
	bsr	show_hex
	move	lace_rez(pc),d0
	sub	#norm_slots,d0
	bpl.s	.show_slot
	add	#slot_limit,d0
.show_slot:
	lea	setup_slot_s(pc),a1
	bsr.s	show_dec
	lea	setup_mode_s(pc),a1
	move	sc_rez+SCD(pc),d0
	bsr.s	show_dec
	lea	intfix_on_s(pc),a1
	lea	intfix_off_s(pc),a0
	btst	#6,sc_intfx_f+SCD(pc)
	bsr	show_test
	lea	black_s(pc),a1
	lea	white_s(pc),a0
	cmp	#6,hard_rez
	beq.s	.non_color
	cmp	#2,hard_rez
	bne.s	.keep_color
.non_color:
	move.l	a1,a0
.keep_color:
	btst	#0,sc_backg_f+SCD(pc)
	bsr	show_test
	lea	get_hardon_s(pc),a0
	bsr	show_ia0
	cmp	#2,emu_rez
	bne.s	.no_hardfile
	lea	hard_file_s(pc),a1
	cmp.b	#1,sc_hardc_f+SCD
	bhi.s	.show_hardon
.no_hardfile:
	lea	hard_paper_s(pc),a1
	lea	no_hardon_s(pc),a0
	tst.b	sc_hardc_f+SCD
.show_hardon:
	bsr	show_test
	rts
;
;
show_dec:
	movem.l	d0-d7,-(sp)
	lea	convend_set_s(pc),a0
	move	#3,d2
.conv_lp_1:
	move.b	#' ',-(a0)
	dbra	d2,.conv_lp_1
	lea	convend_set_s(pc),a0
	swap	d0
	clr	d0
	swap	d0
.conv_lp_2:
	divu	#$A,d0
	swap	d0
	move	d0,d1
	clr	d0
	swap	d0
	addi	#'0',d1
	move.b	d1,-(a0)
	tst.l	d0
	bne.s	.conv_lp_2
	gemdos	Cconws,(a1)
	gemdos	Cconws,convbeg_set_s(pc)
	movem.l	(sp)+,d0-d7
	rts
;
;
show_hex:
	movem.l	d0-d7,-(sp)
	lea	convend_set_s(pc),a0
	move	#3,d2
.conv_lp:
	move.b	d0,d1
	andi	#$F,d1
	cmpi	#9,d1
	ble.s	.conv_lo
	addi	#'A'-$A,d1
	bra.s	.conv_ok
;
.conv_lo:
	addi	#$30,d1
.conv_ok:
	move.b	d1,-(a0)
	ror	#4,d0
	dbra	d2,.conv_lp
	gemdos	Cconws,(a1)
	gemdos	Cconws,convbeg_set_s(pc)
	movem.l	(sp)+,d0-d7
	rts
;
;
show_test:
	beq.s	show_ia0
	move.l	a1,a0
show_ia0:
	gemdos	Cconws,(a0)
	rts
;
;
mess_press:
	bsr.s	show_ia0
	bra.s	get_return
;
mess_bl_press:
	bsr.s	show_ia0
	bsr.s	warn_fix
get_return:
	lea	press_RETURN_s(pc),a0
	bsr	show_ia0
.return_loop:
	gemdos	Cnecin
	cmp	#CR,d0
	bne.s	.return_loop
	rts
;
;
warn_fix:
	bsr	blank_border_supx
	rts
;----------------------------------------------------------------------------
;End of	Various setup subroutines
;----------------------------------------------------------------------------
set_rez_sub:
	move.l	set_rez_p(pc),-(sp)
	rts
;------------------------------------
get_rez_sub:
	move.l	get_rez_p(pc),-(sp)
	rts
;------------------------------------
set_rez_ST:
	and	#3,d0
	move.b	d0,(hw_rez).w
	rts
;------------------------------------
set_rez_TT:
	and	#7,d0
	move.b	d0,(hw_rez_tt).w
.exit:
	rts
;------------------------------------
get_rez_ST:
	move.b	(hw_rez).w,d0
	and	#3,d0
	rts
;------------------------------------
get_rez_TT:
	move.b	(hw_rez_tt).w,d0
	and	#7,d0
	rts
;----------------------------------------------------------------------------
	include	lace_lib.s
;----------------------------------------------------------------------------
	make	JAR_links
;----------------------------------------------------------------------------
;	include code for system screen reallocation
;----------------------------------------------------------------------------
	include	FIND_MPB.S
	include	PROTALLO.S
;----------------------------------------------------------------------------
;	End of the code segment
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
title_mess_s:
	dc.b	CR,LF
	dc.b	'ô  LaceScan Version 4.0  (Aug 1998)  ô',CR,LF
	dc.b	'|  Shareware  by   U. R. Andersson   |',CR,LF
	dc.b	'|------------------------------------|',CR,LF
	dc.b	'|            Inspired by:            |',CR,LF
	dc.b	'|       OverScan Version 2.01a       |',CR,LF
	dc.b	'| K. Isakovic, B. Gebauer, R. Seitel |',CR,LF
	dc.b	'|------------------------------------|',CR,LF
	dc.b	NUL
;
ancient_TOS_s:
	dc.b	'| Your TOS is very old, and unlikely |',CR,LF,BEL,BEL
	dc.b	'| to  support  LaceScan  operation.  |',CR,LF
	dc.b	'| Type [X] to exit,  [P] to proceed. |',CR,LF
	dc.b	'|------------------------------------|',CR,LF
	dc.b	NUL
;
unknown_TOS_s:
	dc.b	'| Your TOS seems to be modern enough |',CR,LF,BEL,BEL
	dc.b	'| to  support  LaceScan  operation,  |',CR,LF
	dc.b	"| even though I don't recognize it.  |",CR,LF
	dc.b	'| Type [X] to exit,  [P] to proceed. |',CR,LF
	dc.b	'|------------------------------------|',CR,LF
	dc.b	NUL
;
installed_mess_s:
	dc.b	'|                                    |',CR,LF
	dc.b	'|     LaceScan is now installed.     |',CR,LF
	dc.b	'|                                    |',CR,LF
	dc.b	'õ                                    õ',CR,LF
	dc.b	NUL
;
bad_TOS_s:
	dc.b	'|                                    |',CR,LF
	dc.b	'|       LaceScan NOT installed       |',CR,LF,BEL,BEL
	dc.b	'|       due to unsuitable TOS.       |',CR,LF
	dc.b	'|                                    |',CR,LF
	dc.b	'õ                                    õ',CR,LF
	dc.b	NUL
;
already_in_s:
	dc.b	'|                                    |',CR,LF
	dc.b	'|       LaceScan NOT installed       |',CR,LF,BEL,BEL
	dc.b	"|       due to cookie = 'Lace'       |",CR,LF
	dc.b	'|                                    |',CR,LF
	dc.b	'õ                                    õ',CR,LF
	dc.b	NUL
;
;
no_ram_s:
	dc.b	'|                                    |',CR,LF
	dc.b	'|       LaceScan NOT installed       |',CR,LF,BEL,BEL
	dc.b	'|       due to lack of free RAM      |',CR,LF
	dc.b	'|                                    |',CR,LF
	dc.b	'õ                                    õ',CR,LF
	dc.b	NUL
;
clear_screen_ESC_s:
	dc.b	ESC,'q',ESC,'E',NUL
setup_X_s:
	dc.b	ESC,'Y!#',ESC,'pXrez:',NUL
setup_Y_s:
	dc.b	' Yrez:',NUL
setup_Off_s:
	dc.b	' Off:',NUL
setup_slot_s:
	dc.b	ESC,'Y"#','Slot:',NUL
setup_mode_s:
	dc.b	' Mode:',NUL
intfix_off_s:
	dc.b	ESC,'Y##','Border: Int-fix= Off,',NUL
white_s:
	dc.b	' Colour= white.',NUL
intfix_on_s:
	dc.b	ESC,'Y##','Border: Int-fix= On, ',NUL
black_s:
	dc.b	' Colour= black.',NUL
get_hardon_s:
	dc.b	ESC,'Y$#','Bitimage is ',NUL
no_hardon_s:
	dc.b	'not active',NUL
hard_paper_s:
	dc.b	'linked to printer',NUL
hard_file_s:
	dc.b	'linked to files',NUL
convbeg_set_s:
	dc.b	'    '
convend_set_s:
	dc.b	' ',NUL
rezwarn_color_s:
	dc.b	ESC,'E'
	dc.b	ESC,'Y## Switching to mono mode from colour  '
	dc.b	NUL
rezwarn_mono_s:
	dc.b	ESC,'E'
	dc.b	ESC,'Y## Switching to colour from mono mode  '
	dc.b	NUL
rezwarn_common_s:
	dc.b	ESC,'Y$# could cause a computer RESET.       '
	dc.b	ESC,'Y%# LaceScan only prevents TOS from this'
	dc.b	ESC,'Y&# but other software may RESET anyway.'
	dc.b	ESC,"Y'# Type 'C' to continue, or type any   "
	dc.b	ESC,"Y(# other key to keep current rez.      "
	dc.b	NUL
slotwarn_color_s:
	dc.b	ESC,'E'
	dc.b	ESC,'Y## This slot is already set for  mono  '
	dc.b	NUL
slotwarn_mono_s:
	dc.b	ESC,'E'
	dc.b	ESC,'Y## This slot is already set for colour '
	dc.b	NUL
slotwarn_com1_s:
	dc.b	ESC,'Y$# mode. It may be erased to reuse it, '
	dc.b	ESC,'Y%# or used as-is (at risk of RESET)    '
	dc.b	ESC,"Y&# Type 'E' to erase, 'U' to use as-is,"
	dc.b	ESC,"Y'# or another key to keep current slot."
	dc.b	NUL
slotwarn_com2_s:
	dc.b	ESC,'Y## !!! Ooops, this is a fixed slot !!! '
	dc.b	ESC,'Y$# I absolutely refuse to erase it !!! '
	dc.b	ESC,'Y%# Please try something else.          '
	dc.b	ESC,'Y&#                                     '
	dc.b	ESC,"Y'#Now press a key to continue !        "
	dc.b	NUL
exitwarn_s:
	dc.b	ESC,'E'
	dc.b	ESC,'Y## Exit in a different resolution mode '
	dc.b	ESC,'Y$# from that in which you entered may  '
	dc.b	ESC,'Y%# disturb some system software...!!!  '
	dc.b	ESC,"Y&# Type 'X' to exit that way (risky!), "
	dc.b	ESC,"Y'# or any other key to avoid it (safe)."
	dc.b	NUL
rez_sure_s:
	dc.b	CR,LF,LF
	dc.b	ESC,'C Change resolution MODE.',CR,LF
	dc.b	ESC,'C Are you sure (y/n) ?   '
	dc.b	NUL
slot_fix_s:
	dc.b	CR,LF,LF
	dc.b	ESC,'C This  resolution SLOT has ',CR,LF
	dc.b	ESC,'C fixed resolution MODE.    ',CR,LF
	dc.b	ESC,'C Please try something else.',CR,LF
	dc.b	NUL
slot_sure_s:
	dc.b	CR,LF,LF
	dc.b	ESC,'C Change resolution SLOT.',CR,LF
	dc.b	ESC,'C Are you sure (y/n) ?   '
	dc.b	NUL
;
home_inv_s:
	dc.b	ESC,'H',ESC,'p',NUL
;
setup_help_s:
	dc.b	'|        S E T U P   M E N U         |',CR,LF
	dc.b	'|                                    |',CR,LF
	dc.b	'| Cursorkeys : Width & Height        |',CR,LF
	dc.b	'| Block  / * : Edge left/right       |',CR,LF
	dc.b	'| Block  - + : Edge up/down          |',CR,LF
	dc.b	'|                                    |',CR,LF
	dc.b	'|    0 - 9   : resolution slot       |',CR,LF
	dc.b	'|    L M H   : resolution mode       |',CR,LF
	dc.b	'|      A     : Auto-switch toggle    |',CR,LF
	dc.b	'|      B     : Bitimage hardcopy     |',CR,LF
	dc.b	'|      C     : Color of border       |',CR,LF
	dc.b	'|      I     : Interrupt-fix border  |',CR,LF
	dc.b	'|      S     : Save & Quit           |',CR,LF
	dc.b	'|      Q     : Quit without saving   |',CR,LF
	dc.b	'|     Help   : This page             |',CR,LF
	dc.b	'|------------------------------------|',CR,LF
	dc.b	'õ   Press Return...                  õ',NUL
;
self_fpath_s:
	dc.b	'A:\AUTO\LACESCAN.PRG'
	dc.b	NUL
conf_fpath_s:
	dc.b	'A:\AUTO\LACESCAN.INF'
	dc.b	NUL
set_saved_s:
	dc.b	CR,LF
	dc.b	'  Setup saved...'
	dc.b	NUL
not_found_s:
	dc.b	' not found !'
	dc.b	NUL
press_RETURN_s:
	dc.b	CR,LF
	dc.b	ESC,'C',ESC,'C',' press < Return > '
crlf_s:
	dc.b	CR,LF,NUL
home_s:
	dc.b	ESC,'H'
selfset_sound:
	dc.b	$00,$70,$01,$04,$02,$08,$03,$02
	dc.b	$04,$1C,$05,$01,$06,$14,$07,$00
	dc.b	$08,$10,$09,$10,$0A,$10,$0B,$00
	dc.b	$0C,$10,$0D,$04,$FF,$10,$07,$3F
	dc.b	$FF,$04,$0B,$00,$0C,$20,$0D,$00
	dc.b	$07,$38,$FF,$32,$07,$3F,$FF,$00
cleanup_sound:
	dc.b	$06,$00,$07,$37,$08,$10,$09,$00
	dc.b	$0A,$00,$0B,$00,$0C,$03,$0D,$04
	dc.b	$FF,$00
image_name_s:
	dc.b	'#:\SCREEN_'
image_patch_s:
	dc.b		  'A.IMG',NUL
	even
;
start_mouse_ikbd:
	dc.b	0,$08
start_mouse_status_ikbd:
	dc.b	0,$88
fast_mouse_ikbd:
	dc.b	2,$0B,0,0
norm_mouse_ikbd:
	dc.b	2,$0B,1,1
stop_mouse_ikbd:
	dc.b	0,$12
stop_mouse_status_ikbd:
	dc.b	0,$92
	even
;
hot_flag:	dc.w	0	;bit 1 flags standard/alternative keys
hot_keys:	dc.w	3,3,1	;current,standard,alternative hot Kbshifts
;
image_head:	dc.w	1,8,1,2
image_pixsize:	dc.w	0,0
image_imgsize:	dc.w	0,0
image_rlecode:	dc.w	$8000
	even
;----------------------------------------------------------------------------
;	End of data segment
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
ancient_TOS_f:	ds.w	1
;
	_unilab	MagX_p
	IFNE	_uni_flag
		dc.l	0	;PL->MagX_struct  MI==err_code
	ENDC
	_unilab	MagX_f
	IFNE	_uni_flag
		dc.w	0	;$FF00 == MagX  $0000 == no_MagX
	ENDC
;
MiNT_ver:	ds.l	1	;MiNT cookie, version in low word
;
stop_mouse_f:	ds.b	1	;= $12 if mouse reports were stopped
start_mouse_f:	ds.b	1	;= $08 if mouse mode was relative
ik_status_t:	ds.b	8	;copy of ikbd status packets
patch_mouse_SR:	ds.w	1	;saves interrupt mask during mouse patch
test_base_p:	ds.l	1
test_scan_p:	ds.l	1
test_maxpos:	ds.l	1
test_downstep:	ds.l	1
test_horoffs:	ds.l	1
stackframe_len:	ds.w	1
hard_rez:	ds.w	1	;hardware rez 0..2
emu_rez:	ds.w	1	;software rez 0..2
mon_rez:	ds.w	1	;monitor rez 0..2  (for swv_vec)
lace_rez:	ds.w	1	;slot index for wanted/current rez before/after fix_screen
replace_rez:	ds.w	1	;slot index for rez replacing wanted rez at scanmode failure
fail_rez:	ds.w	1	;slot index for a rez failed due to wrong scanmode
fixed_rez:	ds.w	1	;last lace_rez updating SCD via fix_screen_supx
setscr_rez:	ds.w	1	;slot index for setscreen
setscr_flags:	ds.l	1	;4 bytes = set_logbase,set_physbase,set_rez,changed_rez
opnwk_slot:	ds.w	1	;slot code chosen by v_opnwk
opnwk_rez:	ds.w	1	;soft rez code active at end of v_opnwk
line_a_base_p:	ds.l	1
intin_p:	ds.l	1
intout_p:	ds.l	1
original_size:	ds.l	1	;original size of screen (bytes) at startup
lockbase_size:	ds.l	1	;total size of LaceScan screen area (bytes)
lockbase_p:	ds.l	1	;locked base of physical screen
ext_base_p:	ds.l	1	;extra base for odd frame screens in interlace modes
lock_mem_p:	ds.l	1	;-> system memory block containing screen
loglock_p:	ds.l	1
logbase_p:	ds.l	1
logbphys_p:	ds.l	1	;== 	logbase - log_offs  init == lockbase
orig_screen_p:	ds.l	1
save_screen_p:	ds.l	1
orig_cur_xy:	ds.l	1
orig_rez_xy:	ds.l	1
orig_bytes_lin:	ds.w	1
opnwk_flag:	ds.w	1	;$FFxx = opnwk_ing bit, b00 flags old, b7 flags new 
opnwk_retad_p:	ds.l	1
xbios_retad_p:	ds.l	1
old_tail_ix:	ds.w	1
kb_iorec_p:	ds.l	1
kbshift_p:	ds.l	1
shsh_command:	ds.w	1
shsh_worktime:	ds.l	1	;ensures Dosound delay
sizefail_f:	ds.w	1	;NE = fix_screen size failure (or changed size)
immovable_f:	ds.l	1	;flag bit for immovable address (used by MiNT)
int_protect_f:	ds.w	1	;prevents ikbd/vbl conflicts
new_emu_f:	ds.w	1	;high byte = Emu activation, low byte = deactivation
home_emu_f:	ds.w	1	;EQ = OK,  GT = requires homing,  LT = Emu is homing
rez_lock_f:	ds.w	1
hw_rez_block_f:	ds.w	1	;flag to inhibit hw_rez updating (in 'refix')
prev_slot:	ds.w	1	;lace_rez of last 'refix'
temp_highstep:	ds.w	1
temp_offsstep:	ds.l	1
temp_maxwidth:	ds.w	1
temp_maxheight:	ds.w	1
temp_color_3:	ds.w	1
temp_color_15:	ds.w	1
setent_rez:	ds.w	1
setent_emu_rez:	ds.w	1
setup_char:	ds.l	1	;NB: long
cmd_retval:	ds.w	1
conf_handle:	ds.w	1
init_err_f:	ds.w	1
lace_mouse_bt:	ds.w	1	;bits 1,0 = left,right mouse button for opnwk
screen_img_handle:	ds.w	1
;
_CPU_cookie:	ds.l	1
_MCH_cookie:	ds.l	1
_VDO_cookie:	ds.l	1
VDO_b_index:	ds.w	1
VDO_w_index:	ds.w	1
VDO_l_index:	ds.w	1
VDO_rez_mask_max:	;alias for two words below together as one longword
VDO_rez_mask:	ds.w	1
VDO_rez_max:	ds.w	1
VDO_high_rez:	ds.w	1
set_rez_p:	ds.l	1	;-> routine to set hardware rez
get_rez_p:	ds.l	1	;-> routine to get hardware rez
;
blit_parm_t:	ds.b	blt_size
;
frame_f_tab:
	ds.b	frame_limit
frame_p_tab:
	ds.l	frame_limit
frame_base:
	ds.l	frame_size*frame_limit/4
init_stack:
	ds.l	frame_size/8
init_stack_end:
	ds.l	frame_size/8
int_savptr_bf_end:
;
;--------------------------------------
;	End of BSS segment
;----------------------------------------------------------------------------
;	End of file:	LACESCAN.S
;----------------------------------------------------------------------------
