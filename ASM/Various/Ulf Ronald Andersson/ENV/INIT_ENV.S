;----------------------------------------------------------------------------
;File name:	INIT_ENV.S			Revision date:	1995.07.02
;Creator:	Ulf Ronald Andersson		Creation date:	1994.08.31
;(c)1994 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE		(NB: commercial sales forbidden!)
;----------------------------------------------------------------------------
;
	output	.PRG
;
;----------------------------------------------------------------------------
;
	include URAn_DOS.S
	include URAn_XB.S
	include URAn_ENV.S
	include	URAn_JAR.S
;
;----------------------------------------------------------------------------
;
	SECTION	text
;
;----------------------------------------------------------------------------
;
start:
	bra	main
;
;----------------------------------------------------------------------------
;
main:
	move.l	4(sp),a5
	move.l	a5,basepage_p
	move	#$100,a4
	add.l	bp_textlen(a5),a4
	add.l	bp_datalen(a5),a4
	move.l	a4,tsr_size
	add.l	bp_bss_len(a5),a4
	lea	local_top(pc),sp
	gemdos	Mshrink,!,(a5),a4
;
	gemdos	Cconws,title_s(pc)
;
	gemdos	Super,!
	move.l	d0,-(sp)
	make_cookie	#'SEnv',#SEnv_struct
	move.l	d0,d3
	gemdos	Super,()
	tst.l	d3
	bmi	already_installed
	XB_install	nu_exec_os(pc),(exec_os).w
;
	lea	auto_name_s(pc),a3	;a3 -> name in auto folder
	bsr	get_boot_drv
	add.b	d0,(a3)
	gemdos	Fopen,(a3),!
	move	d0,d3			;d3 = handle
	bpl.s	.is_open
	lea	inf_name_s(pc),a3	;a3 -> name in current folder (root)
	gemdos	Fopen,(a3),!
	move	d0,d3
	bmi	.exit
.is_open:
	gemdos	Fseek,!,d3,#2		;seek end of file
	move.l	d0,d4			;d4 =  file size
	bmi	.file_exit
	add.l	#$400,d4		;reserve 1Kbyte extra
	move.l	d4,init_buf_size
	gemdos	Malloc,d4
	move.l	d0,a4			;a4 -> environment addition buffer
	move.l	d0,init_env_p
	ble.s	.file_exit
	gemdos	Fseek,!,d3,!		;seek start of file
	gemdos	Fread,d3,d4,(a4)	;read file to future environment
;Here the environment additions are in buffer, but need format normalization
	move.l	d0,d7
	subq.l	#1,d7
	move.l	init_env_p(pc),a0
	move.l	a0,a1
	swap	d7
.loop_1:
	swap	d7
.loop_2:
	move.b	(a0)+,d0
	beq.s	.next
	cmp.b	#CR,d0
	beq.s	.next
	cmp.b	#LF,d0
	bne.s	.keep_it
	clr	d0
.keep_it:
	move.b	d0,(a1)+
.next:
	dbra	d7,.loop_2
	swap	d7
	dbra	d7,.loop_1
	clr.b	(a1)+
	clr.b	(a1)+
;Here init_env_p -> environment additions, which have normalized format
	move.l	init_env_p(pc),a0
	measure_env
	move.l	d0,init_env_size
	clr.l	d0
.file_exit:
	move.l	d0,d7
	gemdos	Fclose,d3		;close file
	move.l	d7,d0
.exit
	gemdos	Ptermres,tsr_size,d0
;
;
already_installed:
	gemdos	Cconws,already_installed_s
	gemdos	Pterm,#E_ERROR
;
;----------------------------------------------------------------------------
;
	XB_define	nu_exec_os,'SEnv'
	move.l	4(sp),basepage_p	;basepage_p -> own remote basepage
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	basepage_p(pc),a0	;a0 -> own remote basepage
	old_env_base			;d0 -> oldest basepage
	move.l	d0,a0			;a0 -> oldest basepage
	move.l	a0,old_basepage_p	;store basepage pointer for future use
;
	lea	bp_environ_p(a0),a1	;a1 -> env ptr in oldest basepage
	move.l	a1,old_env_p_p		;store -> -> oldest environment
	move.l	(a1),a1			;a1 -> oldest environment
	move.l	a1,old_env_p		;store -> oldest environment
;
	lea	path_var_s(pc),a0
	find_env_var
	tst.l	d0
	ble.s	.done_path		;LE means not found, so then exit
	move.l	d0,a0			;a0 -> found 'PATH=' string
	next_value			;d0 -> found 'PATH=' value string
	tst.l	d0
	ble.s	.done_path		;LE means not found, so then exit
	move.l	d0,a3			;a3 -> found value string
	tst.b	(a3)
	bne.s	.done_path		;NE means already ok, so then exit
	tst.b	1(a3)
	beq.s	.done_path		;EQ means no value, so then exit
	move.b	#';',(a3)		;change erroneous NUL to ';'
	cmp.b	#'A',1(a3)
	bne.s	.done_path
	cmp.b	#':',2(a3)
	bne.s	.done_path
	bsr	get_boot_drv
	add.b	d0,1(a3)
.done_path:
	move.l	init_buf_size(pc),d0	;d0 =  size of environment buffer
	ble.s	.exit
	move.l	old_env_p(pc),a0	;a0 -> current environment
	move.l	init_env_p(pc),a1	;a1 -> future environment
	move.l	init_buf_size(pc),d5	;d5 = max size for environment
.init_loop:
	move.l	a0,d0			;normal string ?
	ble.s	.exit_loop
	tst.b	(a0)			;next string empty (end) ?
	beq.s	.exit_loop
	find_env_var
	tst.l	d0
	bpl.s	.next_loop		;ignore old variable that has new definition
	measure_var
	add.l	init_env_size(pc),d0
	cmp.l	d5,d0
	bhi.s	.exit_loop		;skip rest if max exceeded
	add.l	d0,init_env_size
	make_env_var			;redefine old variable into new environment
.next_loop:
	next_env_var
	move.l	d0,a0
	bra.s	.init_loop
;
.exit_loop:
	move.l	old_env_p_p(pc),a0
	move.l	a1,(a0)			;store -> environment in old basepage
	move.l	a1,old_env_p
	move.l	a1,cur_env_p
	move.l	a1,a0
	measure_env
	move.l	d0,cur_env_size
	move.l	init_buf_size(pc),cur_buf_size
.exit:
	movem.l	(sp)+,d0-d7/a0-a6
;
	XB_gonext_d	nu_exec_os	;start older system
;
;----------------------------------------------------------------------------
;Entry:	a0 -> environment additions
;
add_env:
	movem.l	d1-d7/a1-a6,-(sp)
	move.l	cur_env_p(pc),a1
.add_var_lp:
	move.l	a0,d0
	ble	.exit
	tst.b	(a0)
	beq	.exit
	find_env_var			;seek var to add in environment
	tst.l	d0
	bmi.s	.done_old
	kill_env_var
.done_old:
	exg	a0,a1
	measure_env
	move.l	d0,cur_env_size
	exg	a0,a1
	move.l	d0,d3			;d3 =  current size of env
	measure_var
	add.l	d3,d0			;d0 =  size needed incl new var
	cmp.l	cur_buf_size(pc),d0
	blo.s	.keep_buf
	measure_env			;d0 = size of remaining additions
	add.l	d0,d3			;d3 = needed size
	add.l	#$400,d3		;d3 = needed size + 1 Kbyte
	move.l	a0,a3			;a3 -> remaining additions
	gemdos	Malloc,d3
	tst.l	d0
	bmi.s	.error			;exit if Malloc failed
	move.l	cur_env_p(pc),a0	;a0 -> current buffer
	move.l	a0,a4			;a4 -> current buffer
	move.l	d0,a1			;a1 -> new buffer
	move.l	d0,a5			;a5 -> new buffer
.copy_loop:
	move.b	(a0)+,(a1)+
	bne.s	.copy_loop
	move.b	(a0)+,(a1)+
	bne.s	.copy_loop
;Here the new buffer contains a copy of the environment
;
;;;	gemdos	Mfree,(a4)		;release current buffer
;
	move.l	old_env_p_p(pc),a0
	move.l	a5,(a0)			;store -> environment in old basepage
	move.l	a5,old_env_p
	move.l	a5,cur_env_p		;use new buffer as current environment
	move.l	a5,a0
	measure_env
	move.l	d0,cur_env_size		;store new environment size
	move.l	d3,cur_buf_size		;store new buffer size
	move.l	a3,a0			;a0 -> remaining additions
	move.l	a5,a1			;a1 -> current environment
.keep_buf:
;Here we know that the buffer is sufficiently large
	make_env_var
	next_env_var
	move.l	d0,a0
	bra	.add_var_lp
;
.error:
.exit:
	move.l	cur_env_p(pc),a0	;a0 -> current environment
	movem.l	(sp)+,d1-d7/a1-a6
	rts
;
;----------------------------------------------------------------------------
;
get_boot_drv:
	movem.l	d1-d2/d7/a0-a2,-(sp)
	gemdos	Super|_ind,#1
	move.l	d0,d7
	bmi.s	.keep_super_1
	gemdos	Super,!
	move.l	d0,d7
.keep_super_1:
	move	(_bootdev).w,d0
	exg	d0,d7
	tst.l	d0
	bmi.s	.keep_super_2
	gemdos	Super|_ind,d0
.keep_super_2:
	move	d7,d0
	movem.l	(sp)+,d1-d2/d7/a0-a2
	rts
;
;----------------------------------------------------------------------------
;
	make	ENV_links
	make	JAR_links
;
;----------------------------------------------------------------------------
;
	SECTION	data
;
;----------------------------------------------------------------------------
;
SEnv_struct:
		dc.l	'SEnv'			;Identifier
		dc.l	SEnv_end-SEnv_struct	;Structure size
		dc.l	$0100			;Version number
;
		dc.l	add_env			;-> environment adder func
;
cur_env_p:	ds.l	1	;Malloc -> current environment
cur_env_size:	ds.l	1	;size of current environment
cur_buf_size:	ds.l	1	;Malloc size of current environment
;
old_basepage_p:	ds.l	1	;-> oldest basepage
old_env_p_p:	ds.l	1	;-> oldest environment ptr in oldest basepage
old_env_p:	ds.l	1	;-> old/new environment for oldest basepage
;
SEnv_end:
;
title_s:
	dc.b	ESC,'q',CR,LF
	dc.b	CR,LF
	dc.b	HT,ESC,'p','                    ',ESC,'q',CR,LF
	dc.b	HT,ESC,'p',' _____INIT_ENV_____ ',ESC,'q',CR,LF
	dc.b	HT,ESC,'p','                    ',ESC,'q',CR,LF
	dc.b	HT,ESC,'p','         by         ',ESC,'q',CR,LF
	dc.b	HT,ESC,'p','                    ',ESC,'q',CR,LF
	dc.b	HT,ESC,'p','     Ulf Ronald     ',ESC,'q',CR,LF
	dc.b	HT,ESC,'p','     Andersson      ',ESC,'q',CR,LF
	dc.b	HT,ESC,'p','                    ',ESC,'q',CR,LF
	dc.b	CR,LF
	dc.b	NUL
	even
;
already_installed_s:
	dc.b	'INIT_ENV was already installed,',CR,LF
	dc.b	'so this time nothing was changed.',CR,LF
	dc.b	NUL
	even
;
path_var_s:
	dc.b	'PATH=',NUL
	even
;
auto_name_s:
	dc.b	'A:\AUTO\'
inf_name_s:
	dc.b	'INIT_ENV.INF',NUL
;
init_env_p:	ds.l	1	;Malloc -> initial environment
init_env_size:	ds.l	1	;initial size for environment
init_buf_size:	ds.l	1	;Malloc size for initial environment
;
;
;----------------------------------------------------------------------------
;
	SECTION	bss
;
;----------------------------------------------------------------------------
;
basepage_p:	ds.l	1
tsr_size:	ds.l	1
;
		ds.l	$100
local_top:	ds.l	4
;
;----------------------------------------------------------------------------
;End of file:	INIT_ENV.S
;----------------------------------------------------------------------------
