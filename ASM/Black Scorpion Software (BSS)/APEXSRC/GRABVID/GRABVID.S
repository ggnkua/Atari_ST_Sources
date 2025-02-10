
	COMMENT		HEAD=7

	include		video.s
	include		macros.s
	include		clipping.inc

debug


cookie_jar		=	$5a0

trap13			=	$b4
trap14			=	$b8

sclock200		=	$4BA	

decimal_places		=	3	; maximum of 4 places after point
decimal_format		=	1000	; format word for 4 places after point 

*-------------------------------------------------------*
*	System configuration constants			*
*-------------------------------------------------------*

user_stacksize		=	1024
super_stacksize		=	4096

ext_isp_stacksize	=	1024
ext_usp_stacksize	=	8192

*-------------------------------------------------------*

			rsreset
bp_lowtpa		rs.l	1
bp_hitpa		rs.l	1
bp_tbase		rs.l	1
bp_tlen			rs.l	1
bp_dbase		rs.l	1
bp_dlen			rs.l	1
bp_bbase		rs.l	1
bp_blen			rs.l	1
bp_dtaptr		rs.l	1
bp_parentbp		rs.l	1
bp_reserved1		rs.l	1
bp_environ		rs.l	1
bp_reserved2		rs.b	80
bp_cli_len		rs.b	1
bp_cli_string		rs.b	127
bp_slen			rs.b	0

*-------------------------------------------------------*
			rsreset	
*-------------------------------------------------------*
dta_rsv			rs.b	21
dta_attrib		rs.b	1
dta_time		rs.b	2
dta_date		rs.b	2
dta_size		rs.l	1
dta_name		rs.b	14

*-------------------------------------------------------*
			rsreset	
*-------------------------------------------------------*
overlay_crc		rs.l	1
overlay_size		rs.l	1
overlay_slen		rs.b	0

*-------------------------------------------------------*
*	Mark TEXT, DATA & BSS reference sections	*
*-------------------------------------------------------*
	bss
*-------------------------------------------------------*
	ds.b		8192
*-------------------------------------------------------*
bss_start:
*-------------------------------------------------------*
	data
*-------------------------------------------------------*
data_start:
*-------------------------------------------------------*
	text
*-------------------------------------------------------*
text_start:
*-------------------------------------------------------*
*	Retrieve basepage pointer			*
*-------------------------------------------------------*
	move.l		4(sp),a5
	move.l		a5,basepage_ptr
*-------------------------------------------------------*
*	Retrieve command string pointer			*
*-------------------------------------------------------*
	lea		bp_cli_len(a5),a4
	move.l		a4,cli_ptr
*-------------------------------------------------------*
*	MShrink						*
*-------------------------------------------------------*
	move.l		bp_tlen(a5),d0
	add.l		bp_dlen(a5),d0
	add.l		bp_blen(a5),d0
	add.l		#bp_slen,d0
	lea		usp_stack,sp
	move.l		d0,-(sp)
	move.l		a5,-(sp)
	clr.w		-(sp)
	move.w		#$4a,-(sp)
	trap		#1
	lea		12(sp),sp
*-------------------------------------------------------*
*	Find size of desktop				*
*-------------------------------------------------------*
	jsr		appl_init
	jsr		graf_handle
	jsr		v_opnvwk
	jsr		v_clsvwk
	jsr		appl_exit
*-------------------------------------------------------*
*	Flush unwanted keypresses			*
*-------------------------------------------------------*
	jsr		flush_keybuffer
*-------------------------------------------------------*
*	Sign on						*
*-------------------------------------------------------*
	Cconws		#msg_start
*-------------------------------------------------------*
*	Initialise state variables			*
*-------------------------------------------------------*
	move.l		#-1,os_dta
	move.l		#register_file,file_buffer
	move.l		#patch_slen,file_bytes
	move.l		#-1,file_handle
*-------------------------------------------------------*
*	Replace DTA buffer				*
*-------------------------------------------------------*
	jsr		initialise_dta
*-------------------------------------------------------*
*	Grab register file				*
*-------------------------------------------------------*
	move.l		#register_file,patch_struct_ptr
	pea		grab
	push.w		#38
	trap		#14
	addq.l		#6,sp
*-------------------------------------------------------*
*	Write new file to disk				*
*-------------------------------------------------------*
	lea		file_name,a0
	bsr		create_file
	lea		err_no_write,a6
	ext.l		d0
	move.l		d0,file_handle
	ble		fatal_error
	move.l		file_buffer,a0
	move.l		file_bytes,d1
	bsr		write_file
	jsr		close_active_file
*-------------------------------------------------------*
*	Sign off					*
*-------------------------------------------------------*
	lea		msg_done,a6
*-------------------------------------------------------*
fatal_error:
*-------------------------------------------------------*
	Cconws		a6
*-------------------------------------------------------*
user_return:
*-------------------------------------------------------*
	Cconws		#msg_presskey
	Crawcin
*-------------------------------------------------------*
	jsr		restore_dta
*-------------------------------------------------------*
*	Flush unwanted keypresses			*
*-------------------------------------------------------*
	jsr		flush_keybuffer
*-------------------------------------------------------*
*	Terminate program				*
*-------------------------------------------------------*
	clr.w		-(sp)
	trap		#1	

grab:	bsr		read_registers
	rts

*-------------------------------------------------------*
close_active_file:
*-------------------------------------------------------*
	move.l		file_handle,d0
	bmi.s		.skip
	move.l		#-1,file_handle
	jsr		close_file
.skip:	rts

*---------------------------------------------------------------*
appl_init:
*---------------------------------------------------------------*
	lea		ctrl_APPL_INIT,a0
	jsr		fastaescall
	rts

*---------------------------------------------------------------*
appl_exit:
*---------------------------------------------------------------*
	clr.w		int_out
	lea		ctrl_APPL_EXIT,a0
	jsr		fastaescall
.wait:	tst.w		int_out
	beq.s		.wait
	rts

*---------------------------------------------------------------*
graf_handle:
*---------------------------------------------------------------*
	lea		ctrl_GRAF_HANDLE,a0
	jsr		fastaescall
	move.w		int_out,grafhandle
	rts

*---------------------------------------------------------------*
v_opnvwk:
*---------------------------------------------------------------*
	lea		int_in,a0
	moveq		#1,d0
	moveq		#10-1,d1
.fill:	move.w		d0,(a0)+
	dbra		d1,.fill
	move.w		#2,(a0)+
	lea		ctrl_v_opnvwk,a0
	jsr		fastvdicall
	lea		ctrl_v_opnvwk,a0
	move.w		12(a0),vwkhandle
	lea		int_out,a0
	move.w		(a0)+,d1
	move.w		(a0)+,d2
	addq.l		#2,a0
;	move.w		(a0)+,pwim
;	move.w		(a0)+,phim
	addq.w		#1,d1
	addq.w		#1,d2
	move.w		d1,vwork_w
	move.w		d2,vwork_h
	rts

*---------------------------------------------------------------*
v_clsvwk:
*---------------------------------------------------------------*
	lea		ctrl_v_clsvwk,a0
	move.w		vwkhandle,12(a0)
	jsr		fastvdicall_nohandle
	rts

*---------------------------------------------------------------*
v_extnd:
*---------------------------------------------------------------*
	move.w		#1,int_in
	lea		ctrl_vq_extnd,a0
	jsr		fastvdicall
	lea		int_out,a0
	move.w		8(a0),vwork_c
	rts

*---------------------------------------------------------------*
v_hidemouse:
*---------------------------------------------------------------*
	move.w		#1,int_in
	lea		ctrl_v_hide_c,a0
	jsr		fastvdicall
	rts

*---------------------------------------------------------------*
v_showmouse:
*---------------------------------------------------------------*
	move.w		#1,int_in
	lea		ctrl_v_show_c,a0
	jsr		fastvdicall
	rts

*-------------------------------------------------------*
initialise_dta:
*-------------------------------------------------------*
	push.w		#47
	trap		#1
	addq.l		#2,sp
	move.l		d0,os_dta
	pea		new_dta
	push.w		#26
	trap		#1
	addq.l		#6,sp
	rts


*-------------------------------------------------------*
turbo_memcpy:
*-------------------------------------------------------*
	movem.l		d0-d1/a0-a1,-(sp)	
*-------------------------------------------------------*
	tst.l		d0
	ble		.copy_complete
	move.l		a0,d1
	sub.l		a1,d1
	and.w		#16-1,d1
	beq.s		.line_copy
*-------------------------------------------------------*
.long_copy:
*-------------------------------------------------------*
	moveq		#16-1,d1
	add.l		a0,d1
	and.w		#-16,d1
	sub.l		a0,d1
	sub.l		d1,d0	
	bpl.s		.no_cliplong
	add.l		d0,d1
	moveq		#0,d0
.no_cliplong:
*-------------------------------------------------------*
*	0->15 byte preamble				*
*-------------------------------------------------------*
	lsr.l		d1
	bcc.s		.prelong_0
	move.b		(a0)+,(a1)+
.prelong_0:
	lsr.l		d1
	bcc.s		.prelong_1
	move.w		(a0)+,(a1)+
.prelong_1:
	dbra		d1,.prelong_loop
	bra.s		.prelong_done
.prelong_loop:
	move.l		(a0)+,(a1)+
	dbra		d1,.prelong_loop
.prelong_done:
*-------------------------------------------------------*
*	Aligned long-transfer				*
*-------------------------------------------------------*
	move.l		d0,d1
	and.w		#-16,d1
	beq.s		.long_done	
	sub.l		d1,d0
	lsr.l		#4,d1
.long_transfer:
	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	subq.l		#1,d1
	bne.s		.long_transfer
.long_done:
*-------------------------------------------------------*
*	0->15 byte postamble				*
*-------------------------------------------------------*
	moveq		#-4,d1
	and.l		d0,d1
	sub.l		d1,d0
	lsr.l		#2,d1
	dbra		d1,.postlong_loop
	bra.s		.postlong_done
.postlong_loop:
	move.l		(a0)+,(a1)+
	dbra		d1,.postlong_loop
.postlong_done:
	bclr		#1,d0
	beq.s		.postlong_1
	move.w		(a0)+,(a1)+
.postlong_1:
	bclr		#0,d0
	beq.s		.postlong_0
	move.b		(a0)+,(a1)+
.postlong_0:
	bra		.copy_complete
*-------------------------------------------------------*
.line_copy:
*-------------------------------------------------------*
	cmp.l		#40,cpu
	bmi		.long_copy
	moveq		#16-1,d1
	add.l		a0,d1
	and.w		#-16,d1
	sub.l		a0,d1
	sub.l		d1,d0	
	bpl.s		.no_clipline
	add.l		d0,d1
	moveq		#0,d0
.no_clipline:
*-------------------------------------------------------*
*	0->15 byte preamble				*
*-------------------------------------------------------*
	lsr.l		d1
	bcc.s		.preline_0
	move.b		(a0)+,(a1)+
.preline_0:
	lsr.l		d1
	bcc.s		.preline_start
	move.w		(a0)+,(a1)+
	bra.s		.preline_start
.preline_loop:
	move.l		(a0)+,(a1)+
.preline_start:
	dbra		d1,.preline_loop
*-------------------------------------------------------*
*	Aligned line-transfer				*
*-------------------------------------------------------*
	moveq		#-16,d1
	and.l		d0,d1
	beq.s		.long_done	
	sub.l		d1,d0
	lsr.l		#4,d1
.line_transfer:
	move16		(a0)+,(a1)+
	subq.l		#1,d1
	bne.s		.line_transfer
.line_done:
*-------------------------------------------------------*
*	0->15 byte postamble				*
*-------------------------------------------------------*
	moveq		#-4,d1
	and.l		d0,d1
	sub.l		d1,d0
	lsr.l		#2,d1
	bra.s		.postline_start
.postline_loop:
	move.l		(a0)+,(a1)+
.postline_start:
	dbra		d1,.postline_loop
.postline_done:
	bclr		#1,d0
	beq.s		.postline_1
	move.w		(a0)+,(a1)+
.postline_1:
	bclr		#0,d0
	beq.s		.postline_0
	move.b		(a0)+,(a1)+
.postline_0:
*-------------------------------------------------------*
.copy_complete:
*-------------------------------------------------------*
	movem.l		(sp)+,d0-d1/a0-a1
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
turbo_memclr:
*-------------------------------------------------------*
	movem.l		d0-d2/a0,-(sp)
*-------------------------------------------------------*
	moveq		#0,d2
	move.l		d2,d1
	swap		d2
	or.l		d2,d1
	move.l		d1,d2
	rol.l		#8,d1
	or.l		d1,d2
*-------------------------------------------------------*
.long_fill:
*-------------------------------------------------------*
	moveq		#16-1,d1
	add.l		a0,d1
	and.w		#-16,d1
	sub.l		a0,d1
	sub.l		d1,d0	
	bpl.s		.no_cliplong
	add.l		d0,d1
	moveq		#0,d0
.no_cliplong:
*-------------------------------------------------------*
*	0->15 byte preamble				*
*-------------------------------------------------------*
	lsr.l		d1
	bcc.s		.prelong_0
	move.b		d2,(a0)+
.prelong_0:
	lsr.l		d1
	bcc.s		.prelong_start
	move.w		d2,(a0)+
	bra.s		.prelong_start
.prelong_loop:
	move.l		d2,(a0)+
.prelong_start:
	dbra		d1,.prelong_loop
*-------------------------------------------------------*
*	Aligned long-transfer				*
*-------------------------------------------------------*
	moveq		#-16,d1
	and.l		d0,d1
	beq.s		.long_done	
	sub.l		d1,d0
	lsr.l		#4,d1
.long_transfer:
	move.l		d2,(a0)+
	move.l		d2,(a0)+
	move.l		d2,(a0)+
	move.l		d2,(a0)+
	subq.l		#1,d1
	bne.s		.long_transfer
.long_done:
*-------------------------------------------------------*
*	0->15 byte postamble				*
*-------------------------------------------------------*
	moveq		#-4,d1
	and.l		d0,d1
	sub.l		d1,d0
	lsr.l		#2,d1
	bra.s		.postlong_start
.postlong_loop:
	move.l		d2,(a0)+
.postlong_start:
	dbra		d1,.postlong_loop
.postlong_done:
	bclr		#1,d0
	beq.s		.postlong_1
	move.w		d2,(a0)+
.postlong_1:
	bclr		#0,d0
	beq.s		.postlong_0
	move.b		d2,(a0)+
.postlong_0:
*-------------------------------------------------------*
	movem.l		(sp)+,d0-d2/a0
*-------------------------------------------------------*
	rts

*---------------------------------------------------------------*
flush_keybuffer:
*---------------------------------------------------------------*
.all:	push.w		#11
	trap		#1
	addq.l		#2,sp
	tst.w		d0
	beq.s		.exit
	push.w		#7
	trap		#1
	addq.l		#2,sp
	bra.s		.all
.exit:	rts

*-------------------------------------------------------*
restore_dta:
*-------------------------------------------------------*
	move.l		os_dta,d0
	bmi.s		.stop
	move.l		#-1,os_dta
	push.l		d0
	push.w		#26
	trap		#1
	addq.l		#6,sp
.stop:	rts

*---------------------------------------------------------------*
cookie_search:
*---------------------------------------------------------------*
	move.l		cookie_jar.w,a0
.loop:	cmp.l		(a0),d0
	beq.s		.find
	tst.l		(a0)
	beq.s		.fail
	addq.l		#8,a0
	bra.s		.loop
.find:	moveq		#0,d0
	bra.s		.end
.fail:	moveq		#-1,d0
.end:	rts

*---------------------------------------------------------------*
wait_vblank:
*---------------------------------------------------------------*
	move.l		d0,d7
	bra.s		.go
.all:	push.w		#37
	trap		#14
	addq.l		#2,sp
.go:	dbra		d7,.all
	rts

*-------------------------------------------------------*
strcopy_a1_a2:
*-------------------------------------------------------*
.char:	move.b		(a1)+,(a2)+
	bne.s		.char
	subq.l		#1,a1
	subq.l		#1,a2
	rts
	
*-------------------------------------------------------*
strcmp_ci_a0_a1:
*-------------------------------------------------------*
	movem.l		d1-d2/a0-a1,-(sp)
	moveq		#-1,d0
.scmp:	moveq		#0,d1
	move.b		(a0)+,d1
	fixcase		d1
	moveq		#0,d2
	move.b		(a1)+,d2
	fixcase		d2
	cmp.b		d1,d2
	bne.s		.diff
	tst.b		d1
	bne.s		.scmp
.same:	moveq		#0,d0	
.diff:	movem.l		(sp)+,d1-d2/a0-a1
	rts

*-------------------------------------------------------*
strcmp_cs_a0_a1:
*-------------------------------------------------------*
	movem.l		d1-d2/a0-a1,-(sp)
	moveq		#-1,d0
.scmp:	move.b		(a0)+,d1
	move.b		(a1)+,d2
	cmp.b		d1,d2
	bne.s		.diff
	tst.b		d1
	bne.s		.scmp
.same:	moveq		#0,d0	
.diff:	movem.l		(sp)+,d1-d2/a0-a1
	rts

*-------------------------------------------------------*
*	Append decimal number to (a1)			*
*-------------------------------------------------------*
*	d0.i value / d1.i digits			*
*-------------------------------------------------------*
generate_decimal:
*-------------------------------------------------------*
	lea		asciistack,a1
	clr.b		-(a1)
	moveq		#'0',d2
	moveq		#10,d3
.build:	moveq		#0,d5
	divu.l		d3,d5:d0
	add.w		d2,d5
	move.b		d5,-(a1)
	subq.l		#1,d1
	bgt.s		.build
	tst.l		d0
	bne.s		.build
	rts

*-------------------------------------------------------*
*	Append real number to ascii string		*
*-------------------------------------------------------*
append_real:
*-------------------------------------------------------*
*	d0.i = 16:16 real				*
*	a0.i = destination string			*
*-------------------------------------------------------*
	lea		asciistack,a1
*-------------------------------------------------------*
*	Terminate ascii number string			*
*-------------------------------------------------------*
	clr.b		-(a1)
*-------------------------------------------------------*
*	Split real number into int:fract parts		*
*-------------------------------------------------------*
	moveq		#0,d3
	move.w		d0,d3
	swap		d3
	move.l		d0,d5
	clr.w		d5
	swap		d5
	
;	move.l		d0,d3
;	lsl.l		#4,d3
;	rol.l		#4,d0
;	and.b		#$F,d0
;	extb.l		d0
;	move.l		d0,d5
*-------------------------------------------------------*
*	Convert fractional part into decimal		*
*-------------------------------------------------------*
	mulu.l		#decimal_format,d0:d3
*-------------------------------------------------------*
*	Append fraction digits to string		*
*-------------------------------------------------------*
	moveq		#decimal_places,d1
	bsr.s		append_digits
*-------------------------------------------------------*
*	Append decimal point				*
*-------------------------------------------------------*
	move.b		#'.',-(a1)
*-------------------------------------------------------*
*	Append integer digits to string			*
*-------------------------------------------------------*
	move.l		d5,d0
	moveq		#1,d1
	bsr.s		append_digits
*-------------------------------------------------------*
*	Append stacked string to destination string	*
*-------------------------------------------------------*
	moveq		#-1,d0
.copy:	addq.l		#1,d0
	move.b		(a1)+,(a2)+
	bne.s		.copy
	subq.l		#1,a2
	rts

*-------------------------------------------------------*
*	Append decimal number to ascii string		*
*-------------------------------------------------------*
append_decimal:
*-------------------------------------------------------*
*	d0.i = decimal					*
*	a0.i = destination string			*
*-------------------------------------------------------*
	lea		asciistack,a1
*-------------------------------------------------------*
*	Terminate ascii number string			*
*-------------------------------------------------------*
	clr.b		-(a1)
*-------------------------------------------------------*
*	Append digits to string				*
*-------------------------------------------------------*
	moveq		#1,d1
	bsr.s		append_digits
*-------------------------------------------------------*
*	Append stacked string to destination string	*
*-------------------------------------------------------*
	moveq		#-1,d0
.copy:	addq.l		#1,d0
	move.b		(a1)+,(a2)+
	bne.s		.copy
	subq.l		#1,a2
	rts

*-------------------------------------------------------*
*	Convert integer to ascii and append to -(a1)	*
*-------------------------------------------------------*
append_digits:
*-------------------------------------------------------*
*	d0.i = integer to convert			*
*	d1.i = minimum number of digits to convert	*
*	a1.i = stack buffer for ascii digits		*
*-------------------------------------------------------*
	moveq		#'0',d2
	moveq		#10,d3
*-------------------------------------------------------*
*	Check for div/zero case				*
*-------------------------------------------------------*
	move.l		d0,d4
	bne.s		.conv
	moveq		#0,d1
	bra.s		.force
*-------------------------------------------------------*
*	Convert each digit				*
*-------------------------------------------------------*
.conv:	moveq		#0,d4
	divu.l		d3,d4:d0
.force:	add.l		d2,d4
	move.b		d4,-(a1)
	subq.l		#1,d1
	bgt.s		.conv
	tst.l		d0
	bne.s		.conv
	rts

*-------------------------------------------------------*
strsearchend_a1:
*-------------------------------------------------------*
.send:	tst.b		(a1)+
	bne.s		.send
	subq.l		#1,a1
	rts

*-------------------------------------------------------*
*	Create file					*
*-------------------------------------------------------*
*	a0.i name / d0.o handle				*
*-------------------------------------------------------*
create_file:
*-------------------------------------------------------*
	push.w		#0
	pea		(a0)
	push.w		#$3c
	trap		#1
	addq.l		#8,sp
	rts

*-------------------------------------------------------*
*	Open file					* 
*-------------------------------------------------------*
*	a0.i name / d0.i mode / d0.o handle		*
*-------------------------------------------------------*
open_file:
*-------------------------------------------------------*
	push.w		d0
	pea		(a0)
	push.w		#$3d
	trap		#1
	addq.l		#8,sp
	rts

*-------------------------------------------------------*
*	Delete file					* 
*-------------------------------------------------------*
*	a0.i name 					*
*-------------------------------------------------------*
delete_file:
*-------------------------------------------------------*
	pea		(a0)
	push.w		#65
	trap		#1
	addq.l		#6,sp
	rts

*-------------------------------------------------------*
*	Close file					* 
*-------------------------------------------------------*
*	d0.i handle					*
*-------------------------------------------------------*
close_file:
*-------------------------------------------------------*
	tst.w		d0
	bpl.s		.ok
	moveq		#-1,d0
	bra.s		.done
.ok	push.w		d0
	push.w		#$3e
	trap		#1
	addq.l		#4,sp
.done:	rts
	
*-------------------------------------------------------*
*	Write file					* 
*-------------------------------------------------------*
*	d0.i handle / d1.i size / a0.i buff		*
*-------------------------------------------------------*
write_file:
*-------------------------------------------------------*
	push.l		d1
	pea		(a0)
	push.l		d1
	push.w		d0
	push.w		#$40
	trap		#1
	lea		12(sp),sp
	move.l		d0,d1
	cmp.l		(sp)+,d0
	beq.s		.cont
	moveq		#-1,d0
.cont:	rts

*-------------------------------------------------------*
*	Read file					* 
*-------------------------------------------------------*
*	d0.i handle / d1.i size / a0.i buff		*
*-------------------------------------------------------*
read_file:
*-------------------------------------------------------*
	push.l		d1
	pea		(a0)
	push.l		d1
	push.w		d0
	push.w		#$3f
	trap		#1
	lea		12(sp),sp
	move.l		d0,d1
	cmp.l		(sp)+,d0
	beq.s		.cont
	moveq		#-1,d0
.cont:	rts

*-------------------------------------------------------*
*	Seek file					*
*-------------------------------------------------------*
*	d0.i handle / d1.i mode / d2.i size		*
*-------------------------------------------------------*
seek_file:
*-------------------------------------------------------*
	push.w		d1
	push.w		d0
	push.l		d2
	push.w		#$42
	trap		#1
	lea		10(sp),sp
	rts
	
*-------------------------------------------------------*
*	Patch file					*
*-------------------------------------------------------*
*	d0.i handle / d1.i size / d2.i idx / a0.i buff	*
*-------------------------------------------------------*
patch_file:
*-------------------------------------------------------*
	movem.l		d0-d2/a0,-(sp)
	moveq		#0,d1
	bsr		seek_file
	tst.l		d0
	bmi.s		.err
	movem.l		(sp)+,d0-d2/a0
	bsr		write_file
	bra.s		.done
.err:	movem.l		(sp)+,d0-d2/a0
	moveq		#-1,d0
.done:	rts

*-------------------------------------------------------*
*	Examine file					*
*-------------------------------------------------------*
*	d0.i handle / d1.i size / d2.i idx / a0.i buff	*
*-------------------------------------------------------*
examine_file:
*-------------------------------------------------------*
	movem.l		d0-d2/a0,-(sp)
	moveq		#0,d1
	bsr		seek_file
	tst.l		d0
	bmi.s		.err
	movem.l		(sp)+,d0-d2/a0
	bsr		read_file
	bra.s		.done
.err:	movem.l		(sp)+,d0-d2/a0
	moveq		#-1,d0
.done:	rts

*-------------------------------------------------------*
fastvdicall:
*-------------------------------------------------------*
	move.w		grafhandle,12(a0)
*-------------------------------------------------------*
fastvdicall_nohandle:
*-------------------------------------------------------*
	lea		fast_vdipb,a1
	move.l		a0,(a1)
	move.l		a1,d1
	moveq		#115,d0
	trap		#2
	rts

*-------------------------------------------------------*
fastaescall:
*-------------------------------------------------------*
	lea		fast_aespb,a1
	move.l		a0,(a1)
	move.l		a1,d1
	move.w		#200,d0
	trap		#2
	rts

*-------------------------------------------------------*
init_vdi:
*-------------------------------------------------------*
*	Store old VDI attributes			*
*-------------------------------------------------------*
	lea		ctrl_vqf_attributes,a0
	jsr		fastvdicall
	lea		int_out,a0
	move.w		(a0)+,old_vdi_interior
	move.w		(a0)+,old_vdi_color
	move.w		(a0)+,old_vdi_style
	move.w		(a0)+,old_vdi_mode
*-------------------------------------------------------*
*	Store old VDI ink colour			*
*-------------------------------------------------------*
	lea		int_in,a0
	move.w		#0,(a0)+
	move.w		#0,(a0)+
	lea		ctrl_vq_color,a0
	jsr		fastvdicall
	lea		int_out,a0
	move.w		(a0)+,vdi_ink
	move.w		(a0)+,vdi_ink_r
	move.w		(a0)+,vdi_ink_g
	move.w		(a0)+,vdi_ink_b
*-------------------------------------------------------*
*	Select fill style (solid)			*
*-------------------------------------------------------*
	move.w		#1,int_in
	lea		ctrl_vsf_interior,a0
	jsr		fastvdicall
*-------------------------------------------------------*
*	Select fill colour (0)				*
*-------------------------------------------------------*
	move.w		#0,int_in
	lea		ctrl_vsf_color,a0
	jsr		fastvdicall
*-------------------------------------------------------*
*	Select fill index (solid)			*
*-------------------------------------------------------*
	move.w		#0,int_in
	lea		ctrl_vsf_style,a0
	jsr		fastvdicall
*-------------------------------------------------------*
*	Select writing mode (replace)			*
*-------------------------------------------------------*
	move.w		#1,int_in
	lea		ctrl_vswr_mode,a0
	jsr		fastvdicall
*-------------------------------------------------------*
*	Disable clipping rectangle			*
*-------------------------------------------------------*
	move.w		#0,int_in
	lea		pts_in,a0
	clr.w		clip_x1(a0)
	clr.w		clip_y1(a0)
	clr.w		clip_x2(a0)
	clr.w		clip_y2(a0)
	lea		ctrl_vs_clip,a0
	jsr		fastvdicall	
	rts

*-------------------------------------------------------*
restore_vdi:
*-------------------------------------------------------*
*	Restore VDI ink colour				*
*-------------------------------------------------------*
	lea		int_in,a0
	move.w		vdi_ink,(a0)+
	move.w		vdi_ink_r,(a0)+
	move.w		vdi_ink_g,(a0)+
	move.w		vdi_ink_b,(a0)+
	lea		ctrl_vs_color,a0
	jsr		fastvdicall	
*-------------------------------------------------------*
*	Restore fill style				*
*-------------------------------------------------------*
	move.w		old_vdi_interior,int_in
	lea		ctrl_vsf_interior,a0
	jsr		fastvdicall
*-------------------------------------------------------*
*	Restore fill colour				*
*-------------------------------------------------------*
	move.w		old_vdi_color,int_in
	lea		ctrl_vsf_color,a0
	jsr		fastvdicall
*-------------------------------------------------------*
*	Restore fill index				*
*-------------------------------------------------------*
	move.w		old_vdi_style,int_in
	lea		ctrl_vsf_style,a0
	jsr		fastvdicall
*-------------------------------------------------------*
*	Restore writing mode				*
*-------------------------------------------------------*
	move.w		old_vdi_mode,int_in
	lea		ctrl_vswr_mode,a0
	jsr		fastvdicall
	rts

*---------------------------------------------------------------*
*	Detect CPU type						*
*---------------------------------------------------------------*
detect_cpu:
*---------------------------------------------------------------*
	move.l		#'_CPU',d0
	bsr		cookie_search
	move.l		4(a0),cpu
	rts

*---------------------------------------------------------------*

	include		videl.s

*---------------------------------------------------------------*
			data
*---------------------------------------------------------------*
			align
*---------------------------------------------------------------*

debugcli:		dc.b	24,'f:\audio\cba\caf_204.prg',0

err_no_write:		dc.b	'Cannot create SET file!',13,10,0
msg_start:		dc.b	'Videl register file grabber.',13,10,0
msg_done:		dc.b	'VIDEL.SET written to disk.',13,10,0
msg_presskey:		dc.b	'Press any key...',13,10,0

file_name:		dc.b	'videl.set',0
	
*---------------------------------------------------------------*
			data
*---------------------------------------------------------------*
			align
*---------------------------------------------------------------*

;vdipb:			dc.l	control,int_in,pts_in,int_out,pts_out
;aespb:			dc.l	control,global,int_in,int_out,addr_in,addr_out

fast_vdipb:		dc.l	0,int_in,pts_in,int_out,pts_out
fast_aespb:		dc.l	0,global,int_in,int_out,addr_in,addr_out

ctrl_vs_color:		dc.w	014,00,00,04,00,00,00,00
ctrl_vsf_interior:	dc.w	023,00,00,01,01,00,00,00
ctrl_vsf_style:		dc.w	024,00,00,01,01,00,00,00
ctrl_vsf_color:		dc.w	025,00,00,01,01,00,00,00
ctrl_vq_color:		dc.w	026,00,00,02,04,00,00,00
ctrl_vswr_mode:		dc.w	032,00,00,01,01,00,00,00
ctrl_vqf_attributes:	dc.w	037,00,00,00,05,00,00,00
ctrl_v_opnvwk:		dc.w	100,00,00,11,00,00,00,00
ctrl_vq_extnd:		dc.w	102,00,01,00,00,00,00,00
ctrl_v_show_c:		dc.w	122,00,00,01,00,00,00,00
ctrl_v_hide_c:		dc.w	123,00,00,00,00,00,00,00
ctrl_vs_clip:		dc.w	129,02,00,01,00,00,00,00

ctrl_vqt_xfntinfo:	dc.w	229,00,00,05,00,00,00,00

ctrl_v_clrwk:		dc.w	003,00,00,00,00,00,00,00
ctrl_v_gtext:		dc.w	008,01,00,00,00,00,00,00
ctrl_vst_rotation:	dc.w	013,00,00,01,00,00,00,00
ctrl_vst_alignment:	dc.w	039,00,00,02,00,00,00,00
ctrl_vst_font:		dc.w	021,00,00,01,00,00,00,00
ctrl_v_opnbm:		dc.w	100,00,00,20,00,01,00,00
ctrl_v_clsvwk:		dc.w	101,00,00,00,00,00,00,00
ctrl_v_clsbm:		dc.w	101,00,00,00,01,00,00,00
ctrl_vst_point:		dc.w	107,00,00,01,00,00,00,00
ctrl_vst_height:	dc.w	246,00,00,02,00,00,00,00
ctrl_vqt_extent:	dc.w	116,00,00,00,00,00,00,00
ctrl_vqt_real_extent:	dc.w	240,01,00,00,00,4200,00,00
ctrl_vst_load_fonts:	dc.w	119,00,00,01,00,00,00,00
ctrl_vst_unload_fonts:	dc.w	120,00,00,01,00,00,00,00
ctrl_vqt_name		dc.w	130,00,01,00,00,00,00,00
ctrl_v_ftext:		dc.w	241,01,00,00,00,00,00,00

ctrl_APPL_INIT:		dc.w	010,00,01,00,00,00,00,00
ctrl_APPL_EXIT:		dc.w	019,00,01,00,00,00,00,00
ctrl_GRAF_HANDLE:	dc.w	077,00,05,00,00,00,00,00
ctrl_FORM_DIAL:		dc.w	051,09,01,00,00,00,00,00

*---------------------------------------------------------------*
			bss
*---------------------------------------------------------------*
			align
*---------------------------------------------------------------*

			ds.b	256
asciistack:		ds.l	1

cpu:			ds.l	1

cache_flush_rout:	ds.l	1

pmmu_resident:		ds.l	1
pmmu_read_rout:		ds.l	1
pmmu_write_rout:	ds.l	1
pmmu_cbc_rout:		ds.l	1
pmmu_noc_rout:		ds.l	1
stack_handle:		ds.l	1
display_handle:		ds.l	1

new_ssp:		ds.l	1
user_rout:		ds.l	1
keep_stack:		ds.l	1

old_4d2:		ds.l	1
clock200:		ds.l	1

sysfont8x8:		ds.l	1
sysfont8x16:		ds.l	1

*---------------------------------------------------------------*

vwork_w:		ds.w	1
vwork_h:		ds.w	1
vwork_c:		ds.w	1

control:
opcode:			ds.w	1
sintin:			ds.w	1
sintout:		ds.w	1
saddrin:		ds.w	1
saddrout:		ds.w	1
			ds.w	6

global:
apversion:		ds.w	1
apcount:		ds.w	1
apid:			ds.w	1
apprivate:		ds.l	1
apptree:		ds.l	1
ap1resv:		ds.l	1	
ap2resv:		ds.l	1
ap3resv:		ds.l	1
ap4resv:		ds.l	1

int_in:			ds.b	256
pts_in:			ds.b	64
int_out:		ds.b	256
pts_out:		ds.b	64
addr_in:		ds.l	4
addr_out		ds.l	4

grafhandle:		ds.w	1
vwkhandle:		ds.w	1

vdi_ink:		ds.w	1
vdi_ink_r:		ds.w	1
vdi_ink_g:		ds.w	1
vdi_ink_b:		ds.w	1

old_vdi_interior:	ds.w	1
old_vdi_color:		ds.w	1
old_vdi_style:		ds.w	1
old_vdi_mode:		ds.w	1

replaced1:		ds.b	1
replaced2:		ds.b	1

*-------------------------------------------------------*
			bss
*-------------------------------------------------------*
			align
*-------------------------------------------------------*

termination_flag:	ds.l		1
os_usp_stack:		ds.l		1
os_ssp_stack:		ds.l		1
os_dta:			ds.l		1

*-------------------------------------------------------*
			bss
*-------------------------------------------------------*
			align
*-------------------------------------------------------*

file_bytes:		ds.l		1
file_handle:		ds.l		1
file_buffer:		ds.l		1

temp_pathspace:		ds.b		256

new_dta:		ds.b		256

register_file:		ds.b		patch_slen

*-------------------------------------------------------*
	include		end.s
*-------------------------------------------------------*
