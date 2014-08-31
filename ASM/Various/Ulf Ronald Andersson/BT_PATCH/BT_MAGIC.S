;----------------------------------------------------------------------------
;File name:	BT_MAGIC.S			Revision date:	1997.10.26
;Created by:	Ulf Ronald Andersson		Creation date:	1996.10.13
;Copyright:	(C)1996 Ulf Ronald Andersson	Version:	1.0
;----------------------------------------------------------------------------
;
	output	.PRG
;
	include	URAn_SYS.S
	include	URAn_DOS.S
	include	URAn_JAR.S
;
;
	text
;
	opt	a+
	opt	o+
;	
;----------------------------------------------------------------------------
;
start:
	move.l	4(sp),a5		;a5->BP
	lea	loc_stack_top(pc),sp
	move.l	bp_bss_beg_p(a5),a0
	add.l	bp_bss_len(a5),a0
	sub.l	a5,a0			;a0 = total size of program
	gemdos	Mshrink,!,(a5),a0	;returns RAM to OS
	gemdos	Super,!
	move.l	d0,-(sp)
	move	(_bootdev).w,d0
	add	#'A',d0
	move.b	d0,x_auto_bt_magic_inf_s
	eval_cookie	#'MagX'
	move.l	d0,d3
	gemdos	Super,()
	tst.l	d3
	bmi	.simulate_force_reset
	gemdos	Fopen,x_auto_bt_magic_inf_s(pc),!
	move.l	d0,d4
	bpl.s	.have_inf_file
	gemdos	Fcreate,x_auto_bt_magic_inf_s,!
	move.l	d0,d4
	bmi.s	.exit_program
	gemdos	Fclose,d4
	bra.s	.force_reset
;
.have_inf_file:
	gemdos	Fread,d4,#1,bt_magic_inf
	move.l	d0,d3
	gemdos	Fclose,d4
	cmp.l	#1,d3
	bne.s	.exit_program
	cmp.b	#'0',bt_magic_inf
	bne.s	.unforce_reset
.force_reset:
	move.b	#'1',bt_magic_inf
	bsr.s	save_inf
	bmi.s	.exit_program
	gemdos	Super,!
	or	#$0700,SR
	move.l	(_sysbase).w,a0
	move.l	os_selfbeg_p(a0),a0
	move.l	os_reset_p(a0),a0
	jmp	(a0)
;	
.unforce_reset:
	move.b	#'0',bt_magic_inf
	bra.s	.save_inf_and_exit
;
.simulate_force_reset:
	move.b	#'1',bt_magic_inf
.save_inf_and_exit:
	bsr.s	save_inf
.exit_program:
	clr.l	d0
	gemdos	Pterm,d0
;
;----------------------------------------------------------------------------
;
save_inf:
	gemdos	Fopen,x_auto_bt_magic_inf_s(pc),#2
	move.l	d0,d4
	bpl.s	.file_is_open
	gemdos	Fcreate,x_auto_bt_magic_inf_s(pc),!
	move.l	d0,d4
	bmi.s	.exit
.file_is_open:
	gemdos	Fwrite,d4,#1,bt_magic_inf
	move.l	d0,d3
	gemdos	Fclose,d4
	cmp.l	#1,d3
	beq.s	.exit
	moveq	#E_ERROR,d0
.exit:
	tst.l	d0
	rts
;
;----------------------------------------------------------------------------
;
	make	JAR_links
;
;----------------------------------------------------------------------------
;
bt_magic_inf:
	dc.b	'0'
	even
;
x_auto_bt_magic_inf_s:
	dc.b	'A:\AUTO\BT_MAGIC.INF',NUL
	even
;
	ds.l	$100	;allow 256 longwords on minimum stack
loc_stack_top:
;
;----------------------------------------------------------------------------
;End of file:	BT_MAGIC.S
;----------------------------------------------------------------------------
