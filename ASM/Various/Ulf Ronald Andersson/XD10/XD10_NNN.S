;----------------------------------------------------------------------------
; File name:	XD10_nnn.S		Revision date:	1996.03.04
; Created by:	URAn of Munin		Creation date:	1991.07.01
; Version:	1.3
;----------------------------------------------------------------------------
;
;
	INCLUDE	URAn_SYS.S
	INCLUDE	URAn_DOS.S
	INCLUDE	URAn_XB.S
;
;----------------------------------------------------------------------------
;
	section	text
;
;----------------------------------------------------------------------------
start:
	bra	bootprog	;this is to avoid wasting TSR space
;
;
init_fun:	;word at 4(sp) = 400 * XD_logic + 100 * XD_selectcode + XD_ratecode
;  where:	XD_logic:  0 = positive logic, 1 = negative logic  (to PSG pA6)
;& where:	XD_selflg:  0 = none,  1 = A:,  2 = B:,  3 = both
;& where:	XD_ratecode = 2, 3, 6, 12 in milliseconds
;  BUT:		if value is > 800 the XD_selectcode is really step rate for non_XD
	gemdos	Super|_ind,#1
	move.l	d0,-(sp)
	bmi.s	.stay_super_1
	gemdos	Super,!
	move.l	d0,(sp)
.stay_super_1:
	bsr.s	init_fun_S
	move.l	(sp),d0
	bmi.s	.stay_super_2
	gemdos	Super|_ind,d0
.stay_super_2:
	addq	#4,sp
	rts
;
;
init_fun_S:
	clr.l	d0
	move	12(sp),d0
	move.l	a6,-(sp)			;Push entry a6
	lea	localp,a6
	move	d0,curr_setcode-localp(a6)	;save entry value for possible disp
	divu	#100,d0
	bclr	#3,d0				;>= 800 ?
	sne	XD_default-localp(a6)
	bne.s	.keep_curr_sel
	bclr	#2,d0				;>=400 (polarity bit)
	sne	XD_logic-localp(a6)
	move	d0,XD_selflg-localp(a6)
	move	curr_setcode(pc),curr_setting-localp(a6)
.keep_curr_sel:
	clr	d0
	swap	d0
	divu	#3,d0
	cmp	#5,d0
	blo.s	.rate_ok
	moveq	#4,d0
.rate_ok:
	lea	rate_table,a0
	move.b	(a0,d0),d0
	tst.b	XD_default-localp(a6)		;is this XD_rate or default_rate ?
	beq.s	.store_rate
	move	d0,default_rate-localp(a6)
	bra.s	.keep_rate
;
.store_rate:
	move	d0,XD_rate-localp(a6)
.keep_rate:
	bsr.s	norm_rates		;first normalize rates
	tst	XD_selflg-localp(a6)	;any drives use XD ?
	bne.s	.init_active
	bsr.s	clr_PSG_pA6		;clear XD output if no drive uses XD ?
	bra.s	.init_done
;
.init_active:
	bsr	set_rates		;set rates for XD and default drives
.init_done:
	movem.l	(sp)+,a6		;pull entry a6
	rts
;
;
norm_rates:
	move	XD_rate(pc),-(sp)
	move	XD_selflg(pc),-(sp)
	move	default_rate,XD_rate-localp(a6)
	move	#3,XD_selflg-localp(a6)
	bsr	set_rates
	move	(sp)+,XD_selflg-localp(a6)
	move	(sp)+,XD_rate-localp(a6)
	rts
;
;
set_PSG_pA6:
	st	d0
	bra.s	fix_PSG_pA6
;
;
clr_PSG_pA6:
	sf	d0
fix_PSG_pA6:
	move.b	XD_logic(pc),d1
	eor.b	d1,d0
	and.b	#$40,d0
	lea	(hw_psgsel).w,a0
	move	SR,-(sp)
	move.b	#14,(a0)
	move.b	(a0),d1
	and.b	#$BF,d1
	or.b	d0,d1
	move.b	d1,hw_psgwr-hw_psgsel(a0)
	move	(sp)+,SR
	rts
;
;----------------------------------------------------------------------------
;
	dc.l	init_fun	;allows external programs to call init_fun
	XB_define	hdv_bpb_XB,'XD10'
	move.l	hdv_bpb_XB+8(pc),-(sp)
	move	8(sp),d0
	bra.s	fix_drive
;
;-------------------------------------
;
	XB_define	hdv_mediach_XB,'XD10'
	move.l	hdv_mediach_XB+8(pc),-(sp)
	move	8(sp),d0
	bra.s	fix_drive
;
;-------------------------------------
;
	XB_define	hdv_rw_XB,'XD10'
	move.l	hdv_rw_XB+8(pc),-(sp)
	move	18(sp),d0
fix_drive:
	movem.l	d1/a6,-(sp)
	lea	localp(pc),a6
	tst	XD_selflg-localp(a6)
	beq.s	fix_non_XD
	cmpi	#2,d0		;drive >= "C:" ?
	bhs.s	fix_non_XD	;goto fix_non_XD for "C:" or higher drives
	move	d0,late_fix-localp(a6)
	cmp	#3,XD_selflg-localp(a6)
	beq.s	fix_set_XD	;goto fix_set_XD if both A: & B: are XD
	addq	#1,d0
	cmp	XD_selflg(pc),d0
	bne.s	fix_non_XD	;also fix_non_XD for A:/B: not selected as XD
fix_set_XD:
	bsr	set_PSG_pA6
	bra.s	fix_d_exit
;
fix_non_XD:
	bsr	clr_PSG_pA6
fix_d_exit:
	movem.l	(sp)+,d1/a6
fix_d_rts:
	rts		;NB: for XBRA's this jumps to next older chain link
;
;----------------------------------------------------------------------------
;
set_rates:
	lea	$A06.w,a0		;TOS 1.0 value
	move.l	(_sysbase).w,a1
	cmpi	#$100,2(a1)
	bls.s	ancient_TOS
	lea	$A4C.w,a0		;value for old non-1.0 TOS
	cmp	#$104,2(a1)
	bhs.s	new_rates
ancient_TOS:
	cmp	#2,XD_selflg-localp(a6)
	bhi.s	set_rate_BA
	blo.s	set_rate_nonB
set_rate_B:
	move	d0,6(a0)
	rts
;
set_rate_BA:
	bsr.s	set_rate_B
	bra.s	set_rate_A
;
set_rate_nonB:
	tst	XD_selflg-localp(a6)
	beq.s	set_rate_rts
set_rate_A:
	move	d0,2(a0)
	move	d0,(seekrate).w
set_rate_rts:
	rts
;
new_rates:
	cmp	#2,XD_selflg-localp(a6)
	bhi.s	new_rate_BA
	blo.s	new_rate_nonB
new_rate_B:
	xbios	Floprate,#1,XD_rate(pc)
	rts
;
new_rate_BA:
	bsr.s	new_rate_B
	bra.s	new_rate_A
;
new_rate_nonB:
	tst	XD_selflg-localp(a6)
	beq.s	new_rate_rts
new_rate_A:
	xbios	Floprate,!,XD_rate(pc)
	move	XD_rate(pc),(seekrate).w
new_rate_rts:
	rts
;
;
rate_table:	;1 byte per multiple of 3 ms (only 0, 1, 2, 4, valid = 2,3,6,12 )
	dc.b	2,3,0,0,1,1,1,1
time_table:	;1 byte value [ms] for each legal rate code
	dc.b	6,12,2,3
;
late_fix:	dc.w	-1
XD_rate:	dc.w	0
XD_selflg:	dc.l	0
XD_logic:	dc.w	0
XD_default:	dc.w	0
default_rate:	dc.w	3
curr_setcode:	dc.w	3
curr_setting:	dc.w	3
localp:
tsr_end:
;
;
bootprog:
	move.l	4(sp),a5
	lea	stacktop(pc),sp			;sp->local stack top
	lea	localp(pc),a6
	move.l	a5,basepage_p-localp(a6)
	lea	bss_end(pc),a4
	sub.l	a5,a4
	gemdos	Mshrink,!,(a5),a4
	pea	s_myself_auto(pc)
	pea	bp_arglen(a5)
	pea	s_myself(pc)
	bsr	calc_nnn
	add	#12,sp
	tst.l	d0
	bmi	init_bad
	move	d0,nnn_word-localp(a6)
	XB_check	hdv_bpb_XB,(hdv_bpb).w
	bpl	non_boot
	move	nnn_word,-(sp)
	bsr	init_fun
	addq	#2,sp
	XB_install	hdv_bpb_XB(pc),(hdv_bpb).w
	XB_install	hdv_rw_XB(pc),(hdv_rw).w
	XB_install	hdv_mediach_XB(pc),(hdv_mediach).w
	gemdos	Cconws,s_booted_OK(pc)
	bsr.s	show_setting
	lea	tsr_end(pc),a4
	sub.l	basepage_p(pc),a4
	gemdos	Ptermres,a4,!
;
non_boot:
	move.l	a0,a3
	gemdos	Super,!
	move.l	d0,-(sp)
	move.l	(a3),a3
	move.l	-16(a3),a3
	move	nnn_word(pc),-(sp)
	jsr	(a3)
	addq	#2,sp
	gemdos	Super,()
	gemdos	Cconws,s_rebooted(pc)
	bsr.s	show_setting
	gemdos	Pterm,!
;
;
show_setting:
	gemdos	Cconws,s_setting_1(pc)
	move	curr_setting(pc),-(sp)
	bsr	show_nnn
	addq	#2,sp
	gemdos	Cconws,s_setting_2(pc)
	move	default_rate(pc),d0
	lea	time_table(pc),a0
	move.b	(a0,d0),d0
	move	d0,-(sp)
	bsr	show_nnn
	addq	#2,sp
	gemdos	Cconws,s_setting_3(pc)
	rts
;
init_bad:
	gemdos	Cconws,s_badboot(pc)
	gemdos	Pterm,d0
;
;----------------------------------------------------------------------------
;
	INCLUDE	PROG_NNN.S
;
;----------------------------------------------------------------------------
;
	section	data	;resident during init only
;
;----------------------------------------------------------------------------
;
s_myself_auto:	dc.b	'\AUTO\'
s_myself:	dc.b	'XD10_???.PRG',NUL
;
s_booted_OK:	dc.b	'XD10: High Density 10 MHz utility',CR,LF
		dc.b	'XD10: Version 1.3 is now installed.',CR,LF
		dc.b	'XD10: (c)1996 Munin Datakonsult.',CR,LF
		dc.b	'XD10: Author: Ulf Ronald Andersson.',CR,LF
		dc.b	'XD10: This is FREEWARE, but not PD!',CR,LF
		dc.b	CR,LF,NUL
;
s_rebooted:	dc.b	'XD10: High Density 10 MHz utility',CR,LF
		dc.b	'XD10: Command accepted.',CR,LF
		dc.b	NUL
;
s_setting_1:	dc.b	'XD10: Active setting code  = '
		dc.b	NUL
s_setting_2:	dc.b	CR,LF
		dc.b	'XD10: Step rate for non_XD = '
		dc.b	NUL
s_setting_3:	dc.b	' ms',CR,LF
		dc.b	NUL
;
s_badboot:	dc.b	'XD10: High Density 10 MHz utility',CR,LF
		dc.b	'XD10: Cannot find XD10_???.PRG,',CR,LF
		dc.b	'XD10: in current path or \AUTO\.',CR,LF
		dc.b	'XD10: Please rename the file,',CR,LF
		dc.b	'XD10: or use CLI argument.'
s_CRLF:		dc.b	CR,LF
		dc.b	NUL
;
	even
;
;----------------------------------------------------------------------------
;
	section	bss	;resident during init only
;
;----------------------------------------------------------------------------
;
basepage_p:	ds.l	1
nnn_word:	ds.w	1
stackbase:	ds.l	128
stacktop:	ds.l	1
bss_end:
;
;----------------------------------------------------------------------------
	end	;of file:	XD10_nnn.S
