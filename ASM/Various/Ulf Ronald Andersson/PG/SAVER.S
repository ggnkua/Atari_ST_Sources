;----------------------------------------------------------------------------
;File name:	SAVER.S			Revision date:	1994.12.30
;Disassembler:	Ulf Ronald Andersson	Disassembled:	1994.12.30
;----------------------------------------------------------------------------
	output	.TOS
;----------------------------------------------------------------------------
	include	URAn_DOS.S
	include	URAn_LA.S
	include	URAn_XB.S
;----------------------------------------------------------------------------
	SECTION	text
;----------------------------------------------------------------------------
begin:
	move.l	4(sp),a5
	lea	loc_stack_end(pc),sp
	move.l	bp_textlen(a5),a0
	add.l	bp_datalen(a5),a0
	add.l	bp_bss_len(a5),a0
	add	#$100,a0
	gemdos	Mshrink,!,(a5),a0
	_a_init
	_a_hide_c
	gemdos	Super,!
	move.l	d0,entry_ssp
	clr	current_pic_x
;
	move.l	(resvalid).w,d0
	cmp.l	#$31415926,d0
	bne.s	.pg_absent
	move.l	(resvector).w,a0
	lea	-12(a0),a0
	cmp.l	#'XBRA',(a0)
	bne.s	.pg_absent
	move.l	4(a0),d0
	cmp.l	PGRA_id(pc),d0
	bne.s	.pg_absent
	lea	-14(a0),a0		;a0 -> resident screensave pointers
.pg_present:
	st	PG_present_f
	move.l	(a0)+,PGRA_base
	move.l	(a0)+,a1		;a1 -> now_saved count
	move.l	(a0)+,a2		;a2 -> max_saved_f flag
	clr.l	d0
	move	(a1),d0
	tst	(a2)
	beq.s	.keep_count	;keep count unless buffer circular
	move	(a0),d0		;d0 = max count when buffer is circular
.keep_count:
	subq	#1,d0
	bmi.s	exit_no_pictures
	move	d0,maximum_pic_x
	bra	use_pictures
;
.pg_absent:
	clr	PG_present_f
	move.l	(phystop).w,a0
	move.l	a0,PGRA_base
	lea	32032(a0),a0
	lea	grabber_id,a1
	moveq	#$f,d0
.test_id_lp:
	cmpm.b	(a0)+,(a1)+
	dbne	d0,.test_id_lp
	beq.s	found_picture
exit_no_pictures:
	lea	no_pictures_s,a6
	bsr	cconws_a6
	bsr	crawcin_sub
exit_program:
	_a_show_c
	gemdos	Super|_ind,entry_ssp
	gemdos	Pterm,#'PG'
;
;
found_picture:
	move.l	PGRA_id(pc),d0
	cmp.l	(a0)+,d0
	beq.s	.use_PGRA
	move.l	PGRA_id(pc),-4(a0)
	move.l	(phystop).w,a1
	add.l	#$8000,a1
	move.l	a1,(a0)
.use_PGRA:
	move.l	(a0),a0
	move.l	a0,PGRA_limit
	sub.l	PGRA_base(pc),a0
	move.l	a0,d0
	lsl.l	#1,d0
	swap	d0
	subq	#1,d0			;d0 = (PGRA_limit-PGRA_base)/32768-1
	bmi	exit_no_pictures
	move	d0,maximum_pic_x
use_pictures:
	move	(_bootdev).w,d0
	gemdos	Dsetdrv,d0
	move	(_bootdev).w,d0
	add.b	d0,default_path_s
	gemdos	Dsetpath,default_path_s
	lea	prog_title_s,a6
	bsr	cconws_a6
	bsr	crawcin_sub
	lea	gem_palette_t,a4
	moveq	#$f,d3
save_gempal_lp:
	moveq	#$f,d0
	sub.l	d3,d0
	xbios	setcolor,d0,?
	move.w	d0,(a4)+
	dbra	d3,save_gempal_lp
;;;
show_picture:
	clr.l	d0
	move	current_pic_x(pc),d0
	bpl.s	.pic_x_pos
	move	maximum_pic_x(pc),d0
.pic_x_pos:
	cmp	maximum_pic_x(pc),d0
	ble.s	.pic_x_legal
	clr	d0
.pic_x_legal:
	move	d0,current_pic_x
	swap	d0
	lsr.l	#1,d0
	add.l	PGRA_base(pc),d0
	move.l	d0,current_pic_p
	xbios	Physbase
	movea.l	d0,a2
	movea.l	current_pic_p(pc),a0			;a0->picture base
	move.l	#32000/2-1,d0
	lea	picture_bf_1,a1
.copy_picture_lp:
	move.w	(a0),(a1)+
	move.w	(a0)+,(a2)+
	dbra	d0,.copy_picture_lp
	moveq	#$f,d0
	lea	picture_pal_1,a1
.copy_palette_lp:
	move.w	(a0)+,(a1)+
	dbra	d0,.copy_palette_lp
	xbios	Setpalette,picture_pal_1
	bsr	crawcin_sub
	lea	picture_resolution_q_s,a6
	bsr	cconws_a6
cmd_loop_1:
	bsr	crawcin_sub
	cmp.b	#'+',d0
	beq.s	next_picture
	cmp.b	#'-',d0
	beq.s	prev_picture
	cmp.b	#'L',d0
	beq.s	save_low
	cmp.b	#'M',d0
	beq	save_degas_medium
	cmp.b	#'H',d0
	beq	save_degas_high
	cmp.b	#'Q',d0
	beq.s	cmd_Q_quit
	bra.s	cmd_loop_1
;
;
next_picture:
	addq	#1,current_pic_x
	bra	show_picture
;
;
prev_picture:
	subq	#1,current_pic_x
	bra	show_picture
;
;
cmd_Q_Quit:
	xbios	Setpalette,gem_palette_t
	tst.b	PG_present_f
	bne	exit_program
	lea	release_mem_q_s,a6
	bsr	cconws_a6
.l0007:
	bsr	crawcin_sub
	cmp.b	#'N',d0
	beq	exit_program
	cmp.b	#'Y',d0
	bne.s	.l0007
	move.l	PGRA_limit(pc),(phystop).w
	bra	exit_program
;
;
save_low:
	lea	picture_format_q_s,a6
	bsr	cconws_a6
.l000b:
	bsr	crawcin_sub
	cmp.b	#'D',d0
	beq.s	save_degas_low
	cmp.b	#'N',d0
	beq.s	.save_neochrome
	bra.s	.l000b
;
.save_neochrome:
	lea	l002b,a1
	lea	picture_pal_1,a0
	moveq	#$f,d0
.l000d:
	move.w	(a0)+,(a1)+
	dbra	d0,.l000d
	lea	picture_bf_1,a0
	lea	picture_bf_2,a1
	move.l	#32000/2-1,d0
.l000e:
	move.w	(a0)+,(a1)+
	dbra	d0,.l000e
	lea	filename_prompt_s,a6
	bsr	cconws_a6
	move.l	#$7d80,d5
	bsr.s	l0015
	bra	show_picture
;
;
save_degas_low:
	lea	file_start,a1
	clr.w	(a1)+
	bsr.s	save_degas_general
	bra	show_picture
;
save_degas_medium:
	lea	file_start,a1
	move.w	#1,(a1)+
	bsr.s	save_degas_general
	bra	show_picture
;
save_degas_high:
	lea	file_start,a1
	move.w	#2,(a1)+
	bsr.s	save_degas_general
	bra	show_picture
;
save_degas_general:
	lea	picture_pal_1,a0
	moveq	#$f,d0
.l0013:
	move.w	(a0)+,(a1)+
	dbra	d0,.l0013
	lea	picture_bf_1,a0
	move.l	#32000/2-1,d0
.l0014:
	move.w	(a0)+,(a1)+
	dbra	d0,.l0014
	lea	filename_prompt_s,a6
	bsr	cconws_a6
	move.l	#$7d22,d5
	bsr.s	l0015
	rts
;
;
l0015:
	lea	cconrs_buff,a0
	move.b	#$28,(a0)
	gemdos	Cconrs,cconrs_buff
	gemdos	Fsetdta,local_dta
	gemdos	Fsfirst,cconrs_text,?
	tst.w	d0
	bmi.s	.l0017
	lea	file_exists_s,a6
	bsr	cconws_a6
.l0016:
	bsr	crawcin_sub
	cmp.b	#'O',d0
	beq.s	.l0017
	cmp.b	#'Q',d0
	beq.s	.l0018
	cmp.b	#'N',d0
	bne.s	.l0016
	lea	filename_prompt_s,a6
	bsr.s	cconws_a6
	bra.s	l0015
;
.l0017:
	_a_show_c
	gemdos	Fcreate,cconrs_text,!
	tst.w	d0
	bmi.s	create_error
	move.w	d0,d3
	gemdos	Fwrite,d3,d5,file_start
	tst.w	d0
	bmi.s	write_error
	gemdos	Fclose,d3
	_a_hide_c
.l0018:
	rts
;
;
create_error:
	lea	create_err_s,a6
	bsr.s	cconws_a6
	bsr.s	crawcin_sub
	_a_hide_c
	rts
;
;
write_error:
	lea	write_err_s,a6
	bsr.s	cconws_a6
	bsr.s	crawcin_sub
	gemdos	Fclose,d3
	_a_hide_c
	rts
;
;
cconws_a6:
	gemdos	Cconws,(a6)
	rts
;
;
crawcin_sub:
	gemdos	Crawcin
	cmp.b	#'a',d0
	blt.s	.gotcha
	cmp.b	#'z',d0
	bgt.s	.gotcha
	and	#$5F,d0
.gotcha:
	rts
;
;
;----------------------------------------------------------------------------
	SECTION	data
;----------------------------------------------------------------------------
;
grabber_id:
	dc.b	'Picture Grabber!'
;
no_pictures_s:
	dc.b	ESC,'E'
	dc.b	'Are you sure you have grabbed a',CR,LF
	dc.b	'picture ? There are no pictures',CR,LF
	dc.b	'in the correct location... ',CR,LF
	dc.b	NUL
;
prog_title_s:
	dc.b	ESC,'E'
	dc.b	'************* Saver v. 2.0 *************',CR,LF
	dc.b	CR,LF
	dc.b	'Press A Key!',CR,LF
	dc.b	NUL
;
picture_resolution_q_s:
	dc.b	ESC,'H'
	dc.b	'Save = L M H   Step = + -   Quit = Q',ESC,'K',CR,LF
	dc.b	'Please enter one of these 6 commands:',ESC,'K'
	dc.b	NUL
;
picture_format_q_s:
	dc.b	CR,LF
	dc.b	'What picture format ? ',ESC,'K',CR,LF
	dc.b	'(N)eochrome or (D)egas',ESC,'K'
	dc.b	NUL
;
	dc.b	ESC,'E',$00
;
create_err_s:
	dc.b	ESC,'E'
	dc.b	'File creation failed !!!',CR,LF
	dc.b	NUL
;
write_err_s:
	dc.b	ESC,'E'
	dc.b	'Writing to file failed !!!',CR,LF
	dc.b	NUL
;
filename_prompt_s:
	dc.b	CR,LF
	dc.b	'Boot drive is default for save if no',ESC,'K',CR,LF
	dc.b	'path is entered. Enter path\filename:',ESC,'K',CR,LF
	dc.b	ESC,'K'
	dc.b	NUL
;
file_exists_s:
	dc.b	CR,LF
	dc.b	'The file specified exists !!!',ESC,'K',CR,LF
	dc.b	'(O)verwrite (N)ew Name or (Q)uit',ESC,'K'
	dc.b	NUL
;
default_path_s:
	dc.b	'A:\',$00
;
release_mem_q_s:
	dc.b	ESC,'E'
	dc.b	'Goodbye & Thank you for using me',CR,LF
	dc.b	'Release memory used by picture ?',CR,LF
	dc.b	'(Y)es or (N)o'
	dc.b	NUL
;
	dc.b	'Disk is write protected.',ESC,'K',CR,LF
	dc.b	'(R)etry or (C)ancel',ESC,'K'
	dc.b	NUL
;
	EVEN
;
PGRA_id:
	dc.l	'PGRA'
;
;----------------------------------------------------------------------------
	SECTION	bss
;----------------------------------------------------------------------------
;
PG_present_f:
	ds.w	1
;
PGRA_base:
	ds.l	1
current_pic_p:
	ds.l	1
PGRA_limit:
	ds.l	1
;
current_pic_x:
	ds.w	1
maximum_pic_x:
	ds.w	1
;
entry_ssp:
	ds.l	1
gem_palette_t:
	ds.b	32
picture_pal_1:
	ds.b	32
;
cconrs_buff:
	ds.w	1
cconrs_text:
	ds.b	128+2
;
local_dta:
	ds.b	44
;
loc_stack_beg:
	ds.b	1000
loc_stack_end:
	ds.b	14
;
file_start:
	ds.l	1
l002b:
	ds.b	124
picture_bf_2:
	ds.b	32000
;
picture_bf_1:
	ds.b	32000
;
bss_end:
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	SAVER.S
;----------------------------------------------------------------------------
