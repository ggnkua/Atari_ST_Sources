;----------------------------------------------------------------------------
;File name:	CUT_BS.S			Revision date:	1999.01.22
;Created by:	Ulf Ronald Andersson		Creation date:	1998.07.27
;----------------------------------------------------------------------------
	output	.TTP
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
	TEXT
;----------------------------------------------------------------------------
_max_args	=	16
;----------------------------------------------------------------------------
_startup:
	move.l	4(sp),a5
	move.l	bp_bss_beg_p(a5),a0
	add.l	bp_bss_len(a5),a0
	move.l	a0,sp
	sub.l	a5,a0
	gemdos	Mshrink,#0,(a5),a0
	lea	static(pc),a4
	clr	_argc-static(a4)
	lea	_argv-static(a4),a2
	lea	_argcopy-static(a4),a1
	move.l	a1,(a2)+
	clr.b	(a1)+
	lea	bp_argstring(a5),a3
	move.b	bp_arglen(a5),d7
	and	#$7F,d7
	clr	d6
	subq	#1,d7
	bmi.s	.gotargs
.getarg_lp_1:
	cmpi.b	#' ',(a3)+
	dbgt	d7,.getarg_lp_1
	ble.s	.gotargs
	subq	#1,a3
	addq	#1,d6			;_argc += 1
	move.l	a1,(a2)+		;_argv[d6] = a1
.getarg_lp_2:
	move.b	(a3)+,(a1)+
	cmpi.b	#' ',(a3)
	dble	d7,.getarg_lp_2
	bgt.s	.gotargs
	clr.b	(a1)+
	cmpi	#_max_args,d6
	blt.s	.getarg_lp_1
.gotargs:
	move.l	a4,a5
	pea	_argv-static(a5)
	move	d6,_argc-static(a5)
	move	d6,-(sp)
	bsr.s	main
	gemdos	Pterm,d0
;----------------------------------------------------------------------------
	DATA
;----------------------------------------------------------------------------
_argc:		ds.w	1
_argv:		ds.l	_max_args+1
_argcopy:	dcb.b	128,0
;
;
static:
;
source:		dcb.b	140,NUL
dest:		dcb.b	140,NUL
buffer:		dc.l	0
buf_size:	dc.l	0
crlf:		dc.b	CR,LF,NUL
		EVEN
;----------------------------------------------------------------------------
	BSS
;----------------------------------------------------------------------------
	ds.l	$100	;allow 256 longwords on minimum stack
;----------------------------------------------------------------------------
	TEXT
;----------------------------------------------------------------------------
printi	MACRO	s1,s2,s3,s4,s5,s6,s7,s8
	DATA
printi_\@:
	IFNC	'','\1'
	dc.b	\1
	IFNC	'','\2'
	dc.b	\2
	IFNC	'','\3'
	dc.b	\3
	IFNC	'','\4'
	dc.b	\4
	IFNC	'','\5'
	dc.b	\5
	IFNC	'','\6'
	dc.b	\6
	IFNC	'','\7'
	dc.b	\7
	IFNC	'','\8'
	dc.b	\8
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	dc.b	NUL
	EVEN
	TEXT
	movem.l	d0-d2/a0-a2,-(sp)
	lea	printi_\@,a0
	gemdos	Cconws,(a0)
	movem.l	(sp)+,d0-d2/a0-a2
	ENDM	;printi
;----------------------------------------------------------------------------
prints	MACRO	string
	movem.l	d0-d2/a0-a2,-(sp)
	gemdos	Cconws,\1
	movem.l	(sp)+,d0-d2/a0-a2
	ENDM	;prints
;----------------------------------------------------------------------------
main:						;main(argc,argv)
	lv_init		a6
	lv_arg.w	__argc
	lv_arg.l	__argv
;
	printi	CR,LF,<'CUT_BS: starting up.'>,CR,LF,ESC,'w'
;
	cmpi	#1,__argc(a6)		; if (argc>=1)
	blt	main_bad_args
	move.l	__argv(a6),a0
	move.l	4(a0),-(sp)
	pea	source-static(a5)
	bsr	strcpy				;   strcpy(source,argv[1]);
	addq	#8,sp
	move.l	__argv(a6),a0
	move.l	4(a0),-(sp)
	pea	dest-static(a5)
	bsr	strcpy				;   strcpy(source,argv[1]);
	addq	#8,sp
;
	cmpi	#2,__argc(a6)		; if (argc=<2)
	bgt	main_bad_args
	blt.s	main_got_args
	move.l	__argv(a6),a0
	move.l	8(a0),-(sp)
	pea	dest-static(a5)
	bsr	strcpy				;   strcpy(dest,argv[2]);
	addq	#8,sp
main_got_args:
	move	#1024,d0
	move.l	d0,buf_size-static(a5)
	gemdos	Malloc,d0			; buffer=Malloc(buf_size);
	move.l	d0,buffer-static(a5)
;
	bsr	cut_file
;
	move.l	d0,d3
	bmi.s	main_error_exit
	printi	<'CUT_BS: Boot sector file saved.'>,CR,LF
	clr.l	d0
	bra.s	main_exit
;
main_error_exit:
	printi	CR,LF,<'Press a key to continue.'>,CR,LF
	gemdos	Crawcin
main_exit:					; }
	printi	<'CUT_BS: exiting.'>,CR,LF
	gemdos	Mfree|_ind,buffer-static(a5)
	lv_exit	a6
	rts
;
main_bad_args:
	gemdos	Cconws,bad_args_s
	clr.l	d0
	bra	main_error_exit
;----------------------------------------------------------------------------
bad_args_s:
	dc.b	'Argument 1 is required = Source file name \/ Paths',CR,LF
	dc.b	'Argument 2 is optional = Destination name /\ included',CR,LF
	dc.b	'With a single argument, cut file overwrites original',CR,LF
	dc.b	NUL
	even
;----------------------------------------------------------------------------
cut_file:
	lv_init		a6
	lv_arg.w	_fd_source
	lv_arg.w	_fd_dest
;
	gemdos	Fopen,source-static(a5),#0
	move	d0,_fd_source(a6)
	bpl.s	cutf_open_in_ok
cutf_open_s_error:
	printi	<"CUT_BS: OPEN error on source = ">
	prints	source-static(a5)
	bra	cutf_error_exit_1
;
cutf_open_in_ok:
	gemdos	Fread|_ind,_fd_source(a6),#544,buffer(pc)
	cmp.l	#544,d0
	beq.s	cutf_read_ok
cutf_read_error:
	printi	<'CUT_BS: READ error occurred in source file'>
cutf_error_exit_2:
	gemdos	Fclose,_fd_source(a6)
	moveq	#-1,d0
	bra	cutf_error_exit_1
;
cutf_read_ok:
	gemdos	Fclose,_fd_source(a6)
;!!! patch destination disk room test here later !!!
;
	gemdos	Fcreate,dest-static(a5),#0
	move	d0,_fd_dest(a6)
	bpl.s	cutf_create_ok
	printi	<'CUT_BS: CREATE error on dest = '>
	prints	dest-static(a5)
	bra	cutf_error_exit_1
;
cutf_create_ok:
	move	_fd_dest(a6),d4
	move.l	buffer(pc),a0
	gemdos	Fwrite,d4,#512,ph_size(a0)
	tst.l	d0
	bmi	cutf_write_error
	gemdos	Fclose,d4
cutf_exit_ok:
	clr.l	d0
cutf_exit_d0:
	lv_exit	a6
	rts
;
cutf_write_error:
	printi	<'CUT_BS: WRITE error occurred in destination file'>
cutf_error_exit_1:
	bra.s	cutf_exit_d0
; ----------------------------------------------------------------------------
strcpy:
	movea.l	4(sp),a1
	movea.l	8(sp),a0
	move	#255-1,d0		;limit move
.loop:
	move.b	(a0)+,(a1)+
	dbeq	d0,.loop
	beq.s	.exit
	clr.b	(a1)
.exit:
	rts
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	CUT_BS.S
;----------------------------------------------------------------------------
