;----------------------------------------------------------------------------
;File name:	LACE_MUS.S			Revision date:	1997.02.11
;Created by:	Ulf Ronald Andersson		Creation date:	1993.11.11
;Purpose:	Large screen oriented mouse	Version:	3.5
;----------------------------------------------------------------------------
;Remarks:
;
;----------------------------------------------------------------------------
;
	include	URAn_DOS.S
	include	URAn_XB.S
	include	URAn_LA.S
	include	URAn_JAR.S
	include	URAn_REL.S
;
;----------------------------------------------------------------------------
;
	rel_define	LMus		;local reference relocation group
	rel_define	Ln_A		;line_A reference relocation group
	rel_define	KbdV		;Kbdvbase reference relocation group
;
;----------------------------------------------------------------------------
;
LM_version_c	=	$0305	;version 3.5
ref_X_c:	=	320
ref_Y_c:	=	200
max_X_c:	=	960	;max X speeding factor = 3
max_Y_c:	=	600	;max Y speeding factor = 3
;
;----------------------------------------------------------------------------
;
	section	text
;
;----------------------------------------------------------------------------
;
start:
	bra	install
;
;----------------------------------------------------------------------------
;Here is the resident portion of the TSR.
;It is backed halfway into basepage to occupy minimum runtime memory.
;All code MUST therefore be position independent or patched to adapt
;addresses to the final location.
;
reside_beg:
rref:
;
;----------------------------------------------------------------------------
;
	XB_define	nu_xbios,'LMus'
	Pass_Frame	a0
	move	(a0),d0			;Initmous ?
	beq.s	.nu_initmous
	cmp	#Ikbdws&$ff,d0		;Ikbdws
	bne.s	.go_old_xbios
.nu_ikbdws:
	move.l	4(a0),a1		;a1 -> ikbd string
	cmp.b	#$80,(a0)			;char = reset command ?
	beq.s	.clr_mous
	cmp.b	#$13,(a0)			;char > mouse commands ?
	bhi.s	.go_old_xbios
	cmp.b	#$07,(a0)			;char < mouse commands ?
	blo.s	.go_old_xbios
.clr_mous:
	lea	rref(pc),a2
	clr.l	mouse_Xstep-rref(a2)
	clr.l	Xremnant-rref(a2)
	move.b	#$F8,ikbd_m_list-rref(a2)
	bra.s	.go_old_xbios
;
.nu_initmous:
	lea	rref(pc),a2
	clr.l	mouse_Xstep-rref(a2)
	clr.l	Xremnant-rref(a2)
	move.b	#$F8,ikbd_m_list-rref(a2)
	cmp	#1,2(a0)		;relative mode ?
	bne.s	.go_old_xbios		;only chain to relative mice
	lea	nu_mouse+8(pc),a2
	move.l	8(a0),(a2)+
	move.l	a2,8(a0)
.go_old_xbios:
	XB_gonext_d	nu_xbios(pc)
;
;----------------------------------------------------------------------------
;
calc_step	macro	mouse_pack,mouse_steps
;
	movem	\2,d0-d1
.fix_Xstep:
	tst	d0
	beq.s	.got_Xstep
	bpl.s	.pos_Xstep
.neg_Xstep:
	cmp	#-128,d0
	bge.s	.got_Xstep
	moveq	#-128,d0
	bra.s	.got_Xstep
;
.pos_Xstep:
	cmp	#127,d0
	ble.s	.got_Xstep
	moveq	#127,d0
.got_Xstep:
.fix_Ystep:
	tst	d1
	beq.s	.got_Ystep
	bpl.s	.pos_Ystep
.neg_Ystep:
	cmp	#-128,d1
	bge.s	.got_Ystep
	moveq	#-128,d1
	bra.s	.got_Ystep
;
.pos_Ystep:
	cmp	#127,d1
	ble.s	.got_Ystep
	moveq	#127,d1
.got_Ystep:
;
.take_steps:
	move.b	d0,1+\1
	sub	d0,0+\2
	move.b	d1,2+\1
	sub	d1,2+\2
;
		endm	;calc_step
;
;----------------------------------------------------------------------------
;
	XB_define	nu_mouse,'LMus'
	lea	rref(pc),a2
	btst	#1,(kbshift_p).l	;patched -> kbshift at boot
kbshift_p:	=	*-4
	bne.s	.no_acc_mouse		;skip acceleration if left shift pressed
	tas	LM_block_f-rref(a2)
	beq.s	.use_acc_mouse		;use acceleration if wanted and free
.no_acc_mouse:
	clr.l	mouse_Xstep-rref(a2)
	XB_gonext_d	nu_mouse(pc)
;
;
.use_acc_mouse:
	move.b	(a0),ikbd_m_list-rref(a2)
;
	move.b	1(a0),d0		;d0 = Xstep byte
	clr.b	1(a0)			;zero Xstep byte
	ext	d0			;d0 = unscaled Xstep
	beq.s	.done_Xstep
	move	(la_v_rez_hz).l,d1
	rel_ref	Ln_A,*-4
	cmp	LM_max_X(pc),d1
	blo.s	.keep_rez_hz
	move	LM_max_X(pc),d1
.keep_rez_hz:
	muls	d1,d0			;d0 = d0 * min(la_v_rez_hz,LM_max_X)
	move	Xremnant(pc),d1
	ext.l	d1
	add.l	d1,d0			;d0 = Xstep + old remnant
	divs	LM_ref_X(pc),d0		;d0 = d0 / LM_ref_X = scaled Xstep
	add	d0,mouse_Xstep-rref(a2)	;Xstep += d0
	swap	d0
	move	d0,Xremnant-rref(a2)	;store Xremnant
.done_Xstep:
;
	move.b	2(a0),d0		;d0 = Ystep byte
	clr.b	2(a0)			;zero Ystep byte
	ext	d0			;d0 = unscaled Ystep
	beq.s	.done_Ystep
	move	(la_v_rez_vt).l,d1
	rel_ref	Ln_A,*-4
	cmp	LM_max_Y(pc),d1
	blo.s	.keep_rez_vt
	move	LM_max_Y(pc),d1
.keep_rez_vt:
	muls	d1,d0			;d0 = d0 * min(la_v_rez_vt,LM_max_Y)
	move	Yremnant(pc),d1
	ext.l	d1
	add.l	d1,d0			;d0 = Ystep + old remnant
	divs	LM_ref_Y(pc),d0		;d0 = d0 / LM_ref_Y = scaled Ystep
	add	d0,mouse_Ystep-rref(a2)	;Ystep += d0
	swap	d0
	move	d0,Yremnant-rref(a2)	;store Yremnant
.done_Ystep:
;
	calc_step	0(a0),mouse_Xstep-rref(a2)
;
	bclr	#7,LM_block_f-rref(a2)
	XB_gonext_d	nu_mouse(pc)
;
;----------------------------------------------------------------------------
;	Resident data
;
frame_size:	dc.w	6	;changed to 8 for 68020 or newer CPU
os_base_p:	dc.l	0
keytbl_ptp:	dc.l	0
line_a_p:	dc.l	0
Xremnant:	dc.w	0
Yremnant:	dc.w	0
mouse_Xstep:	dc.w	0
mouse_Ystep:	dc.w	0
ikbd_m_list:	dc.b	$F8
ikbd_m_Xstep:	dc.b	0
ikbd_m_Ystep:	dc.b	0
		dc.b	0,0,0
;
		even
;
		dc.l	'LMus'
LMus_cookie:
LM_version:	dc.w	LM_version_c
LM_interface:	dc.w	$0104	;Version 1.4 defined interface
LM_block_f:	dc.w	0
LM_ref_X:	dc.w	ref_X_c
LM_ref_Y:	dc.w	ref_Y_c
LM_max_X:	dc.w	max_X_c
LM_max_Y:	dc.w	max_Y_c
;
;----------------------------------------------------------------------------
;	Resident cookie jar routines & data
;
	_uniref	reset_old_jar
	make	JAR_links
;
reside_end:
;
;----------------------------------------------------------------------------
;
	rel_generate	LMus,rref,2
	rel_generate	Ln_A,rref,2
	rel_generate	KbdV,rref,2
;
;----------------------------------------------------------------------------
;
install:
	move.l	4(sp),a6		;a6 -> basepage
	lea	stack_end(pc),sp
	move.l	sp,d0
	sub.l	a6,d0
	gemdos	Mshrink,!,(a6),d0
;
	xbios	Keytbl,?,?,?
	move.l	d0,keytbl_ptp
;
	gemdos	Super,!
	move.l	d0,-(sp)
;
	_a_init
	move.l	d0,line_a_p
	move.l	(_sysbase).w,a0
	move.l	os_selfbeg_p(a0),a0
	move.l	a0,os_base_p
	move.l	$24(a0),a1	;->kbshift variable in all TOS >= 1.2
	cmp	#$0102,2(a0)	;check OS version
	bhs.s	insta_OS
	move.l	keytbl_ptp,a1
	subq	#1,a1		;NB: This assumes Kbshift stored at Keytbl-1.
;				;NB: All early TOS have Kbshift data there !!!
insta_OS:
	move.l	a1,kbshift_p
;
	lea	bp_arglen+2(a6),a4	;a4 -> argument buffer+2, destination, loc_base
	move.l	a4,a3			;a3 -> argument buffer+2, destination
	lea	reside_beg(pc),a1	;a1 -> reside_beg,	  source
	sub.l	a1,a3			;a3 = distance of move = ref_offs
;
	lea	LMus_cookie-rref(a4),a0
	make_cookie	#'LMus',a0
	bmi	error_exit
;
	lea	reside_beg(pc),a1	;a1 -> reside_beg,	  source
	move.l	a4,a2			;a2 -> argument buffer+2, destination
	move	#(reside_end-reside_beg+3)/4-1,d0		; dbra count
.move_loop:
	move.l	(a1)+,(a2)+
	dbra	d0,.move_loop		;loop to move code to arg buffer+2
;
	relocate	LMus,(pc),(a4),(a3),4
	relocate	Ln_A,(pc),a4,(line_a_p-rref)(a4),4,_ind
	xbios		Kbdvbase
	relocate	KbdV,(pc),a4,d0,4,_ind
;
	move.l		(resvector).w,d0
	cmp.l		#uncookie_reset,d0
	bne.s		.done_resvector
	add.l		a3,d0
	move.l		d0,(resvector).w	;relocate resvector UnCk link
.done_resvector:
	XB_install	(nu_xbios-rref)(a4),(ev_xbios).w
;
	gemdos	Super,()
;
	gemdos	Cconws,initmess_s(pc)
	moveq	#50,d3
.show_dly_loop:
	xbios	Vsync
	dbra	d3,.show_dly_loop
	move.l	#reside_end-reside_beg+bp_arglen+2,d0
	cmp.l	#$0100,d0
	bhs.s	.exit
	move.l	#$0100,d0
.exit:
	gemdos	Ptermres,d0,!
;
error_exit:
	move.l	d0,d7
	gemdos	Super,()
	lea	old_cookie_s(pc),a3
	cmp	#E_ACCDN,d7		;old cookie had same name ?
	beq.s	.disp_error
	lea	ram_failure_s(pc),a3
.disp_error:
	gemdos	Cconws,initmess_s(pc)
	gemdos	Cconws,(a3)
	gemdos	Cconws,prompt_s(pc)
	gemdos	Crawcin
	gemdos	Pterm,d7
;
;----------------------------------------------------------------------------
;	non-resident cookie jar routines
;
	make	JAR_links
;
;----------------------------------------------------------------------------
;
	section	data
;
;----------------------------------------------------------------------------
;
initmess_s:
	dc.b	ESC,'q',HT,ESC,'K',CR,LF
	dc.b	ESC,'K',HT,ESC,'p','                              ',ESC,'q',CR,LF
	dc.b	ESC,'K',HT,ESC,'p','    Lace_Mouse Version 3.5    ',ESC,'q',CR,LF
	dc.b	ESC,'K',HT,ESC,'p','    Shareware  (c)1997 by:    ',ESC,'q',CR,LF
	dc.b	ESC,'K',HT,ESC,'p','    Ulf  Ronald  Andersson    ',ESC,'q',CR,LF
	dc.b	ESC,'K',HT,ESC,'p','                              ',ESC,'q',CR,LF
	dc.b	CR,LF,LF,NUL
	even
;
old_cookie_s:
	dc.b	"A cookie named 'LMus' already existed,",CR,LF
	dc.b	"so no new installation was now made.",CR,LF
	dc.b	"Hopefully this means you have installed",CR,LF
	dc.b	"'Lace_Mus' previously...",CR,LF
	dc.b	NUL
	even
;
ram_failure_s:
	dc.b	"Allocation of RAM for new cookie jar",CR,LF
	dc.b	"failed, so installation was aborted.",CR,LF
	dc.b	NUL
;
prompt_s:
	dc.b	CR,LF
	dc.b	"Please press a key to continue...",CR,LF
	dc.b	CR,LF,NUL
	even
;
;----------------------------------------------------------------------------
;
	section	bss
;
;----------------------------------------------------------------------------
;
stack_base:
	ds.b	2048
stack_end:
;
;----------------------------------------------------------------------------
	end
;----------------------------------------------------------------------------
;End of file:	LACE_MUS.S
;----------------------------------------------------------------------------
