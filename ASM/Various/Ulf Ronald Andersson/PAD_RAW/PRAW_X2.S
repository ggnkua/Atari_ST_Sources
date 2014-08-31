;----------------------------------------------------------------------------
;File name:	PRAW_X2.S		Revision date:	1994.06.20
;Created by:	Ulf Ronald Andersson	Creation date:	1992.06.20
;----------------------------------------------------------------------------
;
;
	output	.TTP
;
;
	include	URAn_SYS.S
	include	URAn_DOS.S
;
;
	text
;
	opt	a+
	opt	o+
	opt	p+
;
;
_max_args	= 16
;	
;
;----------------------------------------------------------------------------
;
_startup:
	move.l	4(sp),a5
	move.l	bp_bss_beg_p(a5),a0
	add.l	bp_bss_len(a5),a0
	move.l	a0,sp
	sub.l	a5,a0
	gemdos	Mshrink,!,(a5),a0
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
;
;
	data
;
_argc:		ds.w	1
_argv:		ds.l	_max_args+1
_argcopy:	dcb.b	128,0
;
;
static:
;
source:		dcb.b	140,NUL
dest:		dcb.b	140,NUL
head_len:	dc.l	0
head_buf:	dcb.b	16,NUL
null_buf:	dcb.b	1280*3,nul
buffer:		dc.l	0
buf_size:	dc.l	0
crlf:		dc.b	CR,LF,NUL
		even
;
;
	bss
;
;
	ds.l	$100	;allow 256 longwords on minimum stack
;
;
	text
;
;
printi	macro	string
	bra.s	.skip\@
.string\@:	dc.b	\1,NUL
	even
.skip\@:
	movem.l	d0-d2/a0-a2,-(sp)
	gemdos	Cconws,.string\@(pc)
	movem.l	(sp)+,d0-d2/a0-a2
	endm	;printi
;
;
prints	macro	string
	movem.l	d0-d2/a0-a2,-(sp)
	gemdos	Cconws,\1
	movem.l	(sp)+,d0-d2/a0-a2
	endm	;prints
;
;
main:						;main(argc,argv)
	RSRESET
;NB: if locals were used they would be declared here, above .aut1
.aut1	rs.l	2
.argc	rs.w	1				;int argc;
.argv	rs.l	1				;char *argv[];
	link	a6,#-.aut1			;{
	printi	<CR,LF,'PRAW_X1: RAW padder now starting.',CR,LF,ESC,'w'>
;
	cmpi	#1,.argc-.aut1(a6)		; if (argc>=1)
	blt	.bad_args
	move.l	.argv-.aut1(a6),a0
	move.l	4(a0),-(sp)
	pea	source-static(a5)
	bsr	strcpy				;   strcpy(source,argv[1]);
	addq	#8,sp
	move.l	.argv-.aut1(a6),a0
	move.l	4(a0),-(sp)
	pea	dest-static(a5)
	bsr	strcpy				;   strcpy(source,argv[1]);
	addq	#8,sp
;
	cmpi	#2,.argc-.aut1(a6)		; if (argc=<2)
	bgt	.bad_args
	blt.s	.got_args
	move.l	.argv-.aut1(a6),a0
	move.l	8(a0),-(sp)
	pea	dest-static(a5)
	bsr	strcpy				;   strcpy(dest,argv[2]);
	addq	#8,sp
.got_args:
;
	gemdos	Malloc,?			; buf_size=Malloc(-1l);
	move.l	d0,buf_size-static(a5)
	gemdos	Malloc,d0			; buffer=Malloc(buf_size);
	move.l	d0,buffer-static(a5)
;
	bsr	pad_file			; if (copy_dir())
;
	move.l	d0,d3
	bmi.s	.error_exit
	printi	<' RAW successfully padded.',CR,LF>
	clr.l	d0
	bra.s	.exit
;
.error_exit:
	printi	<CR,LF,'Press a key to continue.',CR,LF>
	gemdos	Crawcin				;   Cconin();
.exit:					; }
	printi	<'PRAW_X1: RAW padder now exiting.',CR,LF>
	gemdos	Mfree|_IND,buffer-static(a5)	; Mfree(buffer);
	unlk	a6				;}
	rts
;
.bad_args:
	gemdos	Cconws,bad_args_s
	clr.l	d0
	bra	.error_exit
;
bad_args_s:
	dc.b	'Argument 1 is required = Source file name \/ Paths',CR,LF
	dc.b	'Argument 2 is optional = Destination name /\ included',CR,LF
	dc.b	'With a single argument, padded file overwrites original',CR,LF
	dc.b	NUL
	even
;
;
pad_file:	;pad_file()
	RSRESET
.source_len	rs.l	1
.dest_len	rs.l	1
.fd_source	rs.w	1
.fd_dest	rs.w	1
.s_pic_width	rs.l	1
.s_pic_height	rs.l	1
.s_pix_total	rs.l	1
.s_map_width	rs.l	1
.s_map_total	rs.l	1
.d_pic_width	rs.l	1
.d_pic_height	rs.l	1
.d_pix_total	rs.l	1
.d_map_width	rs.l	1
.d_map_total	rs.l	1
.d_left_pad	rs.l	1
.d_right_pad	rs.l	1
.d_upper_pad	rs.l	1
.d_lower_pad	rs.l	1
.buff_ix	rs.l	1
.buff_p		rs.l	1
.aut2		rs.l	2
;NB: if arguments were used they would be declared here, below .aut2
	link	a6,#-.aut2
	gemdos	Fopen,source-static(a5),!
	move	d0,.fd_source-.aut2(a6)
	bpl.s	.open_in_ok
.open_s_error:
	printi	<"OPEN error on source = ">
	prints	source-static(a5)
	bra	.error_exit_1
;
.open_in_ok:
	gemdos	Fseek,!,.fd_source-.aut2(a6),#2
	move.l	d0,.source_len-.aut2(a6)
	bmi.s	.seek_error
	gemdos	Fseek,!,.fd_source-.aut2(a6),#0
	tst.l	d0
	bpl.s	.seek_ok
.seek_error:
	printi	<'SEEK error occurred in source file'>
	bra.s	.error_exit_2
;
.seek_ok:
	gemdos	Fread|_ind,.fd_source-.aut2(a6),#20,buffer
	cmp.l	#20,d0
	beq.s	.read_ok
.read_error:
	printi	<'READ error occurred in source file'>
.error_exit_2:
	gemdos	Fclose,.fd_source-.aut2(a6)
	moveq	#-1,d0
	bra	.error_exit_1
;
.read_ok:
	gemdos	Fclose,.fd_source-.aut2(a6)
	move.l	buffer-static(a5),a0
	clr.l	d0
	bsr	get_int
	move.l	d0,.s_pic_width-.aut2(a6)
	ble.s	.area_error
	mulu	#3,d0
	move.l	d0,.s_map_width-.aut2(a6)
	clr.l	d0
	bsr	get_int
	move.l	d0,.s_pic_height-.aut2(a6)
	bgt	.area_legal
.area_error:
	printi	<'Source file has illegal pixel area,CR,LF'>
.raw_error:
	printi	<'This does not seem to be a QRT-RAW file'>
	moveq	#-1,d0
	bra	.error_exit_1
;
.area_legal:
	move.l	a0,.buff_p-.aut2(a6)
	sub.l	buffer-static(a5),a0
	move.l	a0,.buff_ix-.aut2(a6)
	mulu	.s_pic_width+2-.aut2(a6),d0
	move.l	d0,.s_pix_total-.aut2(a6)
	move.l	d0,d1
	swap	d0
	mulu	#3,d1
	mulu	#3,d0
	swap	d0
	clr	d0
	add.l	d1,d0
	move.l	d0,.s_map_total-.aut2(a6)
	add.l	.buff_ix-.aut2(a6),d0
	cmp.l	.source_len-.aut2(a6),d0
	beq	.area_correct
	bgt.s	.too_small
.too_large:
	printi	<'Source file is larger than pixel area'>
	bra	.raw_error
;
.too_small:
	printi	<'Source file is smaller than pixel area'>
	bra	.raw_error
;
.area_correct:
	movem.l	.s_pic_width-.aut2(a6),d0/d1
	cmp	#640,d0
	blt.s	.pad_d_w
	cmp	#1,_argc-static(a5)
	beq	.exit_ok
	bra.s	.area_ok
;
.pad_d_w:
	move.l	#640,d0
.area_ok:					;here d0=d_pic_width  d1=d_pic_height
	move.l	d0,.d_pic_width-.aut2(a6)
	move.l	d0,d2
	mulu	#3,d2
	move.l	d2,.d_map_width-.aut2(a6)
	move.l	d1,.d_pic_height-.aut2(a6)
	sub.l	.s_pic_width-.aut2(a6),d0	;d0 = d_pic_width_pad
	sub.l	.s_pic_height-.aut2(a6),d1	;d1 = d_pic_height_pad
	move.l	d0,d2
	lsr.l	#1,d0
	sub.l	d0,d2
	mulu	#3,d0
	mulu	#3,d2
	move.l	d0,.d_left_pad-.aut2(a6)
	move.l	d2,.d_right_pad-.aut2(a6)
	move.l	d1,d3
	lsr.l	#1,d1
	sub.l	d1,d3
	move.l	d1,.d_upper_pad-.aut2(a6)
	move.l	d3,.d_lower_pad-.aut2(a6)
	movem.l	.d_pic_width-.aut2(a6),d0-d1
	mulu	d1,d0
	move.l	d0,.d_pix_total-.aut2(a6)
	move.l	d0,d1
	swap	d0
	mulu	#3,d1
	mulu	#3,d0
	swap	d0
	clr	d0
	add.l	d1,d0
	move.l	d0,.d_map_total-.aut2(a6)
;
;!!! patch destination disk room test here later !!!
;
	gemdos	Fopen,source-static(a5),!
	move	d0,.fd_source-.aut2(a6)
	bmi	.open_s_error
	move.l	buf_size-static(a5),d0
	cmp.l	.source_len-.aut2(a6),d0
	bge.s	.buffer_ok
	printi	<'Source file is larger than free memory'>
	bra	.error_exit_2
;
.buffer_ok:
	gemdos	Fread|_ind,.fd_source-.aut2(a6),.source_len-.aut2(a6),buffer
	cmp.l	.source_len-.aut2(a6),d0
	bne	.read_error
	gemdos	Fclose,.fd_source-.aut2(a6)
;
	lea	head_buf-static(a5),a0
	move.l	a0,a1
	move.l	.d_pic_width-.aut2(a6),d0
	bsr	put_digs
	move.b	#' ',(a0)+
	move.l	.d_pic_height-.aut2(a6),d0
	bsr	put_digs
	move.b	#LF,(a0)+
	sub.l	a1,a0
	move.l	a0,head_len-static(a5)
;
	gemdos	Fcreate,dest-static(a5),!
	move	d0,.fd_dest-.aut2(a6)
	bpl.s	.create_ok
	printi	<'CREATE error on dest = '>
	prints	dest-static(a5)
	bra	.error_exit_1
;
.create_ok:
	move	.fd_dest-.aut2(a6),d4
	lea	head_buf-static(a5),a3
	gemdos	Fwrite,d4,head_len-static(a5),(a3)
	tst.l	d0
	bmi	.write_error
	lea	null_buf-static(a5),a3
	move.l	.d_map_width-.aut2(a6),d7
	move.l	.d_upper_pad-.aut2(a6),d3
	beq.s	.upper_pad_ok
	subq	#1,d3
.upper_loop:
	gemdos	Fwrite,d4,d7,(a3)
	tst.l	d0
	bmi.s	.write_error
	dbra	d3,.upper_loop
.upper_pad_ok:
	move.l	.buff_p-.aut2(a6),a4
	move.l	.d_left_pad-.aut2(a6),d5
	move.l	.s_map_width-.aut2(a6),d6
	move.l	.s_pic_height-.aut2(a6),d3
	subq	#1,d3
.center_loop:
	lea	(a3,d5),a2
	move	d6,d2
	subq	#1,d2
.center_move:
	move.b	(a4)+,(a2)+
	dbra	d2,.center_move
	gemdos	Fwrite,d4,d7,(a3)	;copy original image in center of black area
	tst.l	d0
	bmi.s	.write_error
	dbra	d3,.center_loop
	lea	(a3,d5),a2
	move	d6,d2
	subq	#1,d2
.lower_move:
	clr.b	(a2)+
	dbra	d2,.lower_move
	move.l	.d_lower_pad-.aut2(a6),d3
	beq.s	.lower_pad_ok
	subq	#1,d3
.lower_loop:
	gemdos	Fwrite,d4,d7,(a3)
	tst.l	d0
	bmi.s	.write_error
	dbra	d3,.lower_loop
.lower_pad_ok:
	gemdos	Fclose,d4
.exit_ok:
	clr.l	d0
	unlk	a6
	rts
;
.write_error:
	printi	<'WRITE error occurred in destination file'>
.error_exit_1:
	unlk	a6
	rts
;
;
strlen:
	movea.l	4(sp),a0
	move	#256-1,d0		;limit test
.loop:
	tst.b	(a0)+
	dbeq	d0,.loop
	subq.l	#1,a0
	sub.l	4(sp),a0
	move.l	a0,d0
	rts
;
;
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
;
;
strcat:
	movea.l	4(sp),a1
	movea.l	8(sp),a0
	move	#255-1,d0		;limit test & move
.loop_1:
	tst.b	(a1)+
	dbeq	d0,.loop_1
	bne.s	.exit
	subq	#1,a1
.loop:
	move.b	(a0)+,(a1)+
	dbeq	d0,.loop
	beq.s	.exit
	clr.b	(a1)
.exit:
	rts
;
;
showint8:
	link	a6,#-10
	clr.l	d2
	move.w	8(a6),d2
	lea	(a6),a0
	clr.b	-(a0)
.loop_1:
	divu	#10,d2
	swap	d2
	addi.b	#'0',d2
	move.b	d2,-(a0)
	clr	d2
	swap	d2
	bne.s	.loop_1
	lea	-9(a6),a1
.loop_2:
	move.b	#' ',-(a0)
	cmpa.l	a1,a0
	bgt.s	.loop_2
	gemdos	Cconws,(a0)
	unlk	a6
	rts
;
;
get_int:
	move.l	d1,-(sp)
.loop:
	move.b	(a0)+,d1
	sub.b	#'0',d1
	blt.s	.exit
	cmp	#9,d1
	bgt.s	.exit
	mulu	#10,d0
	add	d1,d0
	bra.s	.loop
;
.exit:
	move.l	(sp)+,d1
	tst.l	d0
	rts
;
;
put_digs:
	movem.l	d1-d2/a1,-(sp)
	lea	.num_buf_end-static(a5),a1
	clr.b	-(a1)
.loop_1:
	divu	#10,d0
	swap	d0
	add	#'0',d0
	move.b	d0,-(a1)
	clr	d0
	swap	d0
	tst	d0
	bne.s	.loop_1
.loop_2:
	move.b	(a1)+,(a0)+
	bne.s	.loop_2
	subq	#1,a0
	movem.l	(sp)+,d1-d2/a1
	rts
;
.num_buf:
	ds.b	16
.num_buf_end:
;
;
	end
;----------------------------------------------------------------------------
;End of file:	PRAW_X2.S
;----------------------------------------------------------------------------
