;----------------------------------------------------------------------------
;File name:	MAKEBOOT.S			Revision date:	2000.02.04
;Created by:	Ulf Ronald Andersson		Creation date:	1997.03.14
;----------------------------------------------------------------------------
	output	.TTP
;----------------------------------------------------------------------------
	include	RA_TOS.I
	include	RA_ARG.I
;----------------------------------------------------------------------------
	TEXT
;----------------------------------------------------------------------------
start:
	move.l	4(sp),a5
	move.l	a5,basepage_p
	lea	loc_st_top(pc),sp
;-------
	move.l	bp_bss_beg_p(a5),d0
	add.l	bp_bss_len(a5),d0
	sub.l	a5,d0
	gemdos	Mshrink,#0,(a5),d0
;-------
	start_arg
;-------
	gemdos	Cconws,title_msg_s(pc)
	lea	boot_sec_bs_s(pc),a4
	cmp	#2,arg_cnt
	blo.s	.have_fname
	move.l	arg_ptr(pc),a3
.pass_str_loop:
	tst.b	(a3)+
	bne.s	.pass_str_loop
	lea	fname_s(pc),a4
	move.l	a3,a0
	move.l	a4,a1
	moveq	#128-1,d0
.copy_fname_loop:
	move.b	(a0)+,(a1)+
	dbeq	d0,.copy_fname_loop
	beq.s	.have_fname
	clr.b	(a1)
.have_fname:
	gemdos	Cconws,using_fname_s(pc)
	gemdos	Cconws,(a4)
	gemdos	Cconws,CRLF_s(pc)
	gemdos	Fopen,(a4),!
	move.l	d0,d7
	ble.s	file_error
	gemdos	Fread,d7,#$300,file_data(pc)
	move.l	d0,d6
	gemdos	Fclose,d7
	move.l	d6,d0
	ble.s	file_error
	cmp.l	#$200,d0
	beq.s	file_ok
file_error:
	gemdos	Cconws,file_error_s(pc)
.space_wait:
	gemdos	Crawcin
	cmp.b	#' ',D0
	bne.s	.space_wait
	bra.s	end_program
;-------
file_ok:
	gemdos	Cconws,file_ok_s(pc)
	gemdos	Cconws,(a4)
	gemdos	Cconws,post_fname_s(pc)
main_loop:
	gemdos	Cconws,main_msg_s(pc)
command_loop:
	gemdos	Crawcin
	cmp.b	#$2A,D0
	beq.s	go_ahead		;<*> => write bootsector on A:
	cmp.b	#ESC,D0
	bne.s	command_loop		;unrecognized => loop
end_program:
	gemdos	Cconws,prog_end_s(pc)
	gemdos	Pterm0			;<escape> => exit program
;------------------------------------
go_ahead:
	lea	file_data(pc),a0
	lea	new_sector(pc),a1
	moveq	#512/4-1,d0
.copy_file_data_loop:
	move.l	(a0)+,(a1)+
	dbra	d0,.copy_file_data_loop
	xbios	Floprd,old_sector(pc),#0,#0,#1,#0,#0,#1
	tst.w	D0
	bne.s	.failure
	lea	old_sector+bs_filler(pc),a0
	lea	new_sector+bs_filler(pc),a1
	moveq	#28-1,d5
.copy_disk_bpb:
	move.b	(A0)+,(A1)+		;copy old medium defining data
	dbra	D5,.copy_disk_bpb
;
	xbios	Protobt,new_sector(pc),#-1,#-1,#1
	xbios	Flopwr,new_sector(pc),#0,#0,#1,#0,#0,#1
;
	tst.w	D0
	beq.s	.success
.failure:
	gemdos	Cconws,error_msg_s(pc)
	bra.s	.space_wait
;
.success:
	gemdos	Cconws,success_msg_s(pc)
.space_wait:
	gemdos	Crawcin
	cmp.b	#' ',D0
	bne.s	.space_wait
	bra	main_loop
;----------------------------------------------------------------------------
title_msg_s:
	dc.b	ESC,'k'		;pull any old push position
	dc.b	ESC,'E'		;clear screen and home position at top left
	dc.b	ESC,'p'
	dc.b	'     MakeBoot Version 1.1 running      ',ESC,'q',CR,LF
	dc.b	CR,LF
	dc.b	ESC,'j'		;push reference position
	dc.b	NUL
;----------------------------------------------------------------------------
using_fname_s:
	dc.b	ESC,'k'		;pull reference position
	dc.b	ESC,'j'		;push reference position
	dc.b	ESC,'J'		;clear to end of screen
	dc.b	'Trying to read boot_sector file, using ',CR,LF
	dc.b	'the file: '
	dc.b	NUL
;----------------------------------------------------------------------------
file_error_s:
	dc.b	CR,LF
	dc.b	ESC,'p'
	dc.b	'     A file error has occured, please  ',ESC,'q',CR,LF
	dc.b	ESC,'p'
	dc.b	'     use a proper 512 byte file.       ',ESC,'q',CR,LF
	dc.b	CR,LF
	dc.b	'Press ',ESC,'p','<space>',ESC,'q',' when done reading.',CR,LF
	dc.b	NUL
;----------------------------------------------------------------------------
prog_end_s:
	dc.b	ESC,'k'		;pull reference position
	dc.b	ESC,'j'		;push reference position
	dc.b	ESC,'J'		;clear to end of screen
	dc.b	'MakeBoot program terminating',CR,LF
	dc.b	NUL
;----------------------------------------------------------------------------
file_ok_s:
	dc.b	ESC,'k'		;pull reference position
	dc.b	ESC,'J'		;clear to end of screen
	dc.b	'Boot_sector file:'
	dc.b	NUL
;----------------------------------------------------------------------------
post_fname_s
	dc.b	CR,LF
	dc.b	'is now loaded in RAM, ready for use.',CR,LF
	dc.b	CR,LF
	dc.b	ESC,'j'		;push reference position
	dc.b	NUL
;----------------------------------------------------------------------------
main_msg_s:
	dc.b	ESC,'k'		;pull reference position
	dc.b	ESC,'j'		;push reference position
	dc.b	ESC,'J'		;clear to end of screen
	dc.b	'This program places a  bootsector on',CR,LF
	dc.b	'diskettes in drive A when you  press',CR,LF
	dc.b	'the asterisk key  ',ESC,'p','<*>',ESC,'q','  to do so, but',CR,LF
	dc.b	'you can exit  without  affecting any',CR,LF
	dc.b	'diskette by pressing escape key ',ESC,'p','<Esc>',ESC,'q',CR,LF
	dc.b	CR,LF
CRLF_s:
	dc.b	CR,LF
	dc.b	NUL
;----------------------------------------------------------------------------
error_msg_s:
	dc.b	ESC,'k'		;pull reference position
	dc.b	ESC,'j'		;push reference position
	dc.b	ESC,'J'		;clear to end of screen
	dc.b	'     An error has occured, please      ',ESC,'q',CR,LF
	dc.b	ESC,'p'
	dc.b	'     check the disk in drive A.        ',ESC,'q',CR,LF
	dc.b	'An error happens if your disk is write',CR,LF
	dc.b	'protected, unformatted or faulty.',CR,LF
	dc.b	CR,LF
	dc.b	'Press ',ESC,'p','<space>',ESC,'q',' when done reading.',CR,LF
	dc.b	NUL
;----------------------------------------------------------------------------
;
success_msg_s:
	dc.b	ESC,'k'		;pull reference position
	dc.b	ESC,'j'		;push reference position
	dc.b	ESC,'J'		;clear to end of screen
	dc.b	'Bootsector written without error.',CR,LF,CR,LF
	dc.b	'Press ',ESC,'p','<space>',ESC,'q',' to continue.',CR,LF
	dc.b	NUL
;----------------------------------------------------------------------------
boot_sec_bs_s:
	dc.b	'boot_sec.bs',NUL
	EVEN
;----------------------------------------------------------------------------
	BSS
;----------------------------------------------------------------------------
fname_s:	ds.b	130
basepage_p:	ds.l	1
new_sector:	ds.l	2048/4
		ds.l	512/4
file_data:	ds.l	768/4
old_sector:	ds.l	512/4
;
local_stack:	ds.l	256
loc_st_top:
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	MAKEBOOT.S
;----------------------------------------------------------------------------
