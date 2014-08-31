;----------------------------------------------------------------------------
;File name:	F_CHANGE.S		Revision date:	1995.08.16
;Creator:	Ulf Ronald Andersson	Creation date:	1992.12.11
;(c)1992 by:	Ulf Ronald Andersson	All rights reserved
;Released as:	FREEWARE		(NB: commercial sales forbidden!)
;----------------------------------------------------------------------------
;
	output	.GTP
;
;----------------------------------------------------------------------------
	SECTION	text
;----------------------------------------------------------------------------
;
	include	URAn_APP.S
	include	URAn_SIM.S
;
;----------------------------------------------------------------------------
;
init_app:
	include	URAN_ARG.S
	rts
;
;----------------------------------------------------------------------------
;
exec_app:
	move.l	arg_ptr(pc),a4	;a4 = arg_ptr
	move	arg_cnt(pc),d0	;d0 = arg_cnt
	move	d0,d5
	subq	#2,d5			;prep for dbra without progname
	blt	usage_error
loop_1:
	tst.b	(a4)+			;pass arg 0 (progname or dummy)
	bne.s	loop_1
main_loop:			;conversion process for each argument font_file
	lea	fontpath_s(pc),a0
loop_2:
	move.b	(a4)+,(a0)+
	bne.s	loop_2
	gemdos	Fopen,fontpath_s(pc),#2
	move.l	d0,d7
	bmi	open_error
	gemdos	Fseek,!,d7,!
	tst.l	d0
	bmi	read_error
	gemdos	Fread,d7,#$58,fonthead_t(pc)
	move.l	d0,d6
	bmi	read_error
	cmp	#$58,d6
	bne	font_error
	lea	fonthead_t(pc),a0
	move	fnt_flag(a0),font_flag
	move	fnt_lasc(a0),font_lasc
	move	fnt_hasc(a0),font_hasc
	move.l	fnt_hor_tp(a0),font_hor_tp
	move.l	fnt_chr_tp(a0),font_chr_tp
	move.l	fnt_fbase(a0),font_fbase
	move	fnt_fwidth(a0),font_fwidth
	move	fnt_fheight(a0),font_fheight
	move	font_flag(pc),d0
	move	d0,font_flag
	btst	#2,d0
	bne.s	conv_68000_2_intel_1
	rol	#8,d0			;reverse bytes of font_flag
	btst	#2,d0
	bne	font_error	;flags 68000 mode in Intel format !!!
	move	d0,font_flag
flag_is_intel:			;d0 has 68000/intel flag = 0, in 68000 format
	move	font_lasc,d0
	rol	#8,d0		;reverse bytes of font_lasc
	move	d0,font_lasc
	move	font_hasc,d0
	rol	#8,d0		;reverse bytes of font_hasc
	move	d0,font_hasc
	move	font_fwidth,d0
	rol	#8,d0		;reverse bytes of font_fwidth
	move	d0,font_fwidth
	move	font_fheight,d0
	rol	#8,d0		;reverse bytes of font_fheigth
	move	d0,font_fheight
;
	move.l	font_hor_tp(pc),d0
	rol	#8,d0		;\
	swap	d0		; X Reverse bytes of font_hor_tp
	rol	#8,d0		;/
	move.l	d0,font_hor_tp
	move.l	font_chr_tp(pc),d0
	rol	#8,d0		;\
	swap	d0		; X Reverse bytes of font_chr_tp
	rol	#8,d0		;/
	move.l	d0,font_chr_tp
	move.l	font_fbase(pc),d0
	rol	#8,d0		;\
	swap	d0		; X Reverse bytes of font_fbase
	rol	#8,d0		;/
	move.l	d0,font_fbase
conv_intel_2_68000_1:
	bra	conv_common_1
;
conv_68000_2_intel_1:
conv_common_1:
	clr.l	d0
	move	font_hasc(pc),d0
	sub	font_lasc(pc),d0
	blt	font_error
	cmp	#255,d0
	bgt	font_error
	addq	#1,d0		;d0 = total characters in font
	move	d0,font_size
	addq	#1,d0		;chr_tp table needs 1 more entry
	add	d0,d0		;and each entry uses 2 bytes
	move.l	d0,chr_t_size
	move	font_fwidth(pc),d0
	mulu	font_fheight(pc),d0
	move.l	d0,font_bytes
	tst.l	fontdata_p
	ble.s	allocate
	movem.l	d0-d2/a0-a2,-(sp)
	gemdos	Mfree|_ind,fontdata_p(pc)
	movem.l	(sp)+,d0-d2/a0-a2
allocate:
	gemdos	Malloc,font_bytes(pc)
	move.l	d0,fontdata_p
	bmi	malloc_error
;
	lea	fonthead_t(pc),a0
	move	fnt_id(a0),d0	;\
	rol	#8,d0		; X Reverse bytes of fnt_id
	move	d0,fnt_id(a0)	;/
	move	fnt_pts(a0),d0	;\
	rol	#8,d0		; X Reverse bytes of fnt_pts
	move	d0,fnt_pts(a0)	;/
;
	lea	fnt_lasc(a0),a0	; Pass fnt_name unchanged
	moveq	#(fnt_next+4-fnt_lasc)/2-1,d1	;prep d1 for dbra loop for the rest
fixloop_1:
	move	(a0),d0		;\
	rol	#8,d0		; X Reverse bytes of another word
	move	d0,(a0)+	;/
	dbra	d1,fixloop_1
;
	lea	fonthead_t(pc),a0
	move	font_flag(pc),d0
	move.l	font_chr_tp(pc),d1
	cmp.l	font_hor_tp(pc),d1
	bne.s	keep_horoff
	bclr	#1,d0		;remove erroneous horoff flag
keep_horoff:
	move.l	#$58,d1			;d1 = new chr_tp  ==  new hor_tp
	move.l	d1,d2
	add.l	chr_t_size(pc),d2	;d2 = new fbase
	move	d0,font_flag
	bchg	#2,d0
	beq.s	conv_intel_2_68000_2
	rol	#8,d0		;reverse flag bytes going from 68000 to intel
	move	d0,fnt_flag(a0)
conv_68000_2_intel_2:
	rol	#8,d1		;\
	swap	d1		; X Reverse bytes of fnt_hor_tp == fnt_chr_tp
	rol	#8,d1		;/
	rol	#8,d2		;\
	swap	d2		; X Reverse bytes of fnt_fbase
	rol	#8,d2		;/
	bra.s	conv_common_2
;
conv_intel_2_68000_2:		;keep 68000 order going from intel to 68000
	move	d0,fnt_flag(a0)
conv_common_2:
	move.l	d1,fnt_hor_tp(a0)
	move.l	d1,fnt_chr_tp(a0)
	move.l	d2,fnt_fbase(a0)
	clr.l	fnt_next(a0)
;
; Here fonthead_t is completely converted and ready for writing
;
	gemdos	Fseek,font_chr_tp,d7,!
	tst.l	d0
	bmi	read_error
	gemdos	Fread,d7,chr_t_size(pc),chr_off_t(pc)
	move.l	d0,d6
	bmi	read_error
	cmp.l	chr_t_size(pc),d6
	bne	font_error
	move	font_size(pc),d1	;d1 = entry_count - 1
	lea	chr_off_t(pc),a0
fixloop_2:
	move	(a0),d0		;\
	rol	#8,d0		; X Reverse another chr_off word
	move	d0,(a0)+	;/
	dbra	d1,fixloop_2
;
; Here chr_off_t is completely converted and ready for writing
;
	btst	#1,font_flag+1(pc)
	beq.s	done_horoff
	gemdos	Fseek,font_hor_tp(pc),d7,!
	tst.l	d0
	bmi	read_error
	move	font_size(pc),d3	;d3 = entry count for hor_tp table
	add	d3,d3			;and each entry uses 2 bytes
	gemdos	Fread,d7,d3,hor_off_t(pc)
	move.l	d0,d6
	bmi	read_error
	cmp	d3,d6
	bne	font_error
	move	font_size(pc),d1
	subq	#1,d1			;d1 = entry_count - 1
	lea	hor_off_t(pc),a0
fixloop_3:
	move	(a0),d0		;\
	rol	#8,d0		; X Reverse another hor_off word
	move	d0,(a0)+	;/
	dbra	d1,fixloop_3
done_horoff:
;
; Here hor_off_t is completely converted and ready for writing
;
	gemdos	Fseek,font_fbase(pc),d7,!
	tst.l	d0
	bmi	read_error
	gemdos	Fread|_ind,d7,font_bytes(pc),fontdata_p(pc)
	cmp.l	font_bytes(pc),d0
	bne.s	write_error
;
;
converted:
;
; Now we must write fonthead_t, chr_off_t, and eliminate hor_off_t
;
	gemdos	Fseek,!,d7,!
	tst.l	d0
	bmi.s	read_error
	gemdos	Fwrite,d7,#$58,fonthead_t(pc)
	cmp.l	#$58,d0
	bne.s	write_error
;
; Here fonthead_t has been successfully written to font file
;
	gemdos	Fwrite,d7,chr_t_size(pc),chr_off_t(pc)
	cmp.l	chr_t_size(pc),d0
	bne.s	write_error
;
; Here chr_off_t has been successfully written to font file
;
	gemdos	Fwrite|_ind,d7,font_bytes(pc),fontdata_p(pc)
	cmp.l	font_bytes(pc),d0
	bne.s	write_error
;
; Here fontdata has been successfully written to font file
;
completed:
;
; Here the current file has been completely converted and written
;
	gemdos	Fclose,d7
	dbra	d5,main_loop
	clr.l	d0
	bra.s	main_exit
;
malloc_error:
write_error
font_error:
read_error:
	move.l	d0,d6
	gemdos	Fseek,!,d7,#2
	gemdos	Fclose,d7
	bra.s	test_error
;
open_error:
	move.l	d0,d6
test_error:
	move.l	d6,d0
	bmi.s	error_d0
general_error:
	moveq	#-1,d0
error_d0:
	move.l	d0,d6
	sim_aes	form_alert,#1,error_alert_s(pc)
	move.l	d6,d0
	bra.s	main_exit
;
usage_error:
	sim_aes	form_alert,#1,usage_alert_s(pc)
	moveq	#-1,d0
main_exit:
	move.l	d0,d7
	tst.l	fontdata_p
	ble.s	exit_d7
	gemdos	Mfree|_ind,fontdata_p(pc)
exit_d7:
	move.l	d7,d0
	rts
;
;----------------------------------------------------------------------------
;
	make	SIM_links
;
;----------------------------------------------------------------------------
	SECTION	data
;----------------------------------------------------------------------------
;
acc_name:	dc.b	'  F_CHANGE is no ACC !',NUL
crlf_s:		dc.b	CR,LF,NUL
;
usage_alert_s:
	dc.b	'[1]['
	dc.b	'F_CHANGE usage:|'
	dc.b	'Each  font  file named in the|'
	dc.b	'argument will be converted.  |'
	dc.b	'68000 format =>  Intel format|'
	dc.b	'Intel format =>  68000 format]'
	dc.b	'[ Exit ]',NUL
	even
;
error_alert_s:
	dc.b	'[1]['
	dc.b	'F_CHANGE error:|'
	dc.b	'  Something has gone wrong ! ]'
	dc.b	'[ Exit ]',NUL
	even
;
;----------------------------------------------------------------------------
	SECTION	bss
;----------------------------------------------------------------------------
;
font_lasc:	ds.w	1
font_hasc:	ds.w	1
font_flag:	ds.w	1
font_hor_tp:	ds.l	1
font_chr_tp:	ds.l	1
font_fbase:	ds.l	1
font_fwidth:	ds.w	1
font_fheight:	ds.w	1
;
font_size:	ds.w	1
;
chr_t_size:	ds.l	1
font_bytes:	ds.l	1
fontdata_p:	ds.l	1
;
fontpath_s:	ds.b	140
;
fonthead_t:	ds.b	$58
chr_off_t:	ds.w	$101
hor_off_t:	ds.w	$101
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
	End
;----------------------------------------------------------------------------
;End of file:	F_CHANGE.S
;----------------------------------------------------------------------------
