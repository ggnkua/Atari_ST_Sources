;FINAL  

	include	stdmac.s
	include	stdequ.s
	include	video.s
	include	cache.s
	include	mfp.s

*-----------------------------------------*

lprint		macro
	bra.s		.s\@
.t\@	dc.b		\1,13,10,0
	even
.s\@	pea		.t\@
	push.w	#9
	trap		#1
	addq		#6,sp
	endm

lprintr		macro
	push.l	\1
	push.w	#9
	trap		#1
	addq		#6,sp
	endm

*-----------------------------------------*

MAIN:	move.l	sp,a5
	move.l	a5,old_usp
	lea		new_usp,sp
	move.l	4(a5),a0
	IFD		FINAL
	lea		128(a0),a0
	move.b	(a0)+,d0
	ble		exit_direct
	push.l	a5
	bsr		get_filename
	pop.l		a5
	ENDC
*-----------------------------------------------------*
	move.l	$04(a5),a5
	move.l	$0C(a5),d0
	add.l		$14(a5),d0
	add.l		$1C(a5),d0
	add.l		#256,d0
	push.l	d0
	push.l	a5
	push.w	d0
	push.w	#$4A
	trap		#1
	add.w		#12,sp
	hidemouse
*-----------------------------------------------------*
	moveq		#-1,d0
	moveq		#STRAM_only,d1
	jsr		mxalloc
	tst.l		d0
	ble		exit_direct
	move.l	d0,ram_length
	moveq		#STRAM_only,d1
	jsr		mxalloc
	tst.l		d0
	ble		exit_direct
	move.l	d0,ram_start
*-----------------------------------------------------*
	pea		new_ssp
	move.w	#32,-(sp)
	trap		#1
	move.l	d0,-(sp)
*-----------------------------------------------------*
	st		force_hard
	push.w	#2
	trap		#14
	addq		#2,sp
	move.l	d0,old_scr
	bsr		keep_video
	bsr		keep_palette
*-----------------------------------------------------*
	lea		filename,a0
	lea		script_buffer,a1
	move.l	#16000,d0
	jsr		load
	tst.l		d0
	bmi		exit
	bsr		tokenize
	lea		script_buffer,a0
	bsr		parse_script
*-----------------------------------------------------*
	jsr		x_waitkey
*-----------------------------------------------------*
exit:	move.l	old_scr,a0
	bsr		unkeep_video
	bsr		reset_palette
exit2	;bsr		mrelease
	move.w	#32,-(sp)
	trap		#1
	lea		10(sp),sp
	showmouse
exit_direct:
	move.l	error_msg,d0
	beq.s		.ok
	lprintr	d0	
	lprintr	pkey_msg
	jsr		x_waitkey
.ok

;	pea		exit_msg
;	push.w	#9
;	trap		#1
;	addq		#6,sp

	clr.w		-(sp)
	trap		#1

line_counter:	ds.w	1
error_msg:		dc.l	0

exit_msg:		dc.b	13,10,13,10
			dc.b	27,'e',0
pkey_msg:		dc.b	13,10,"Press any key to exit...",13,10,0
			even

			rsreset
STRAM_only		rs.b	1
VRAM_only		rs.b	1
STRAM_preferred	rs.b	1
VRAM_preferred	rs.b	1

mxalloc:
	push.w	d1
	push.l	d0
	push.w	#68
	trap		#1
	addq.l	#8,sp
	rts

mfree:
	push.l	d0
	push.w	#73
	trap		#1
	addq.l	#6,sp
	rts

blocktrack_ptr:	dc.l	blocks

*-----------------------------------------*

parse_script:
	move.l	a0,script_ptr
read_command:
	move.l	script_ptr,a0
.look	moveq		#0,d0
	move.b	(a0),d0
	beq.s		script_done
	cmp.w		#'*',d0
	beq.s		.cc
	cmp.w		#';',d0
	bne.s		.nc
.cc	jsr		skip_comment
	bra.s		.look
.nc	bsr		clipcase
	cmp.w		#'A',d0
	blt.s		.ctrl
	cmp.w		#'Z',d0
	ble.s		find_hash
.ctrl	addq.l	#1,a0
	bra.s		.look
script_done:
	moveq		#0,d0
	rts

skip_comment:
.nxt	move.b	(a0),d0
	beq.s		.done
	addq.l	#1,a0
	cmp.b		#13,d0
	bne.s		.nxt
	addq		#1,line_counter
.done	rts

find_hash:
	moveq		#0,d0
	moveq		#0,d7
	lea		command,a1
.hash	move.b	(a0),d0
	beq.s		script_done
	bsr		clipcase
	cmp.w		#'A',d0
	blt.s		.stop
	cmp.w		#'Z',d0
	bgt.s		.stop
	move.b	d0,(a1)+
	add.w		d0,d7
	addq.l	#1,a0
	bra.s		.hash
.stop	clr.b		(a1)
	move.l	a0,script_ptr
	and.w		#4096-1,d7
	lea		([command_ptr.l],d7.w*8),a1
	jsr		search_and_call
	bra		read_command

search_and_call:
.next	move.l	(a1)+,d0
	beq.s		.err
	move.l	(a1)+,a6
	move.l	d0,a2
	lea		command,a3
	bsr		strcmp23
	tst.l		d0
	bmi.s		.next
	jsr		(a6)
	moveq		#0,d0
	rts
.err	moveq		#-1,d0
	rts

strcmp23:
.next	moveq		#0,d0
	move.b	(a2)+,d0
	beq.s		.stop
	bsr		clipcase
	move.b	d0,d2
	move.b	(a3)+,d0
	beq.s		.stop
	bsr		clipcase
	move.b	d0,d3
	cmp.b		d2,d3
	beq.s		.next
	moveq		#-1,d0
	rts
.stop	moveq		#0,d0
	rts

clipcase:
	cmp.w		#'a',d0
	blt.s		.up
	cmp.w		#'z',d0
	bgt.s		.up
	sub.w		#'a'-'A',d0
.up	cmp.b		#13,d0
	bne.s		.rts
	addq		#1,line_counter
.rts	rts

read_equate:
	move.l	script_ptr,a2
	moveq		#0,d0
.l1	move.b	(a2),d0
	beq.s		.err
	cmp.b		#13,d0
	beq.s		.err
	addq.l	#1,a2
	cmp.b		#'=',d0
	bne.s		.l1
	move.l	a2,script_ptr
	moveq		#0,d0
	rts
.err	move.l	a2,script_ptr
	moveq		#-1,d0
	rts

read_string:
	move.l	script_ptr,a2
.l2	move.b	(a2),d0
	beq.s		.err
	cmp.b		#13,d0
	beq.s		.err
	cmp.b		#' ',d0
	bgt.s		.gs
	addq.l	#1,a2
	bra.s		.l2
.gs	moveq		#0,d0
.copy	move.b	(a2),d0
	beq.s		.err
	bsr		clipcase
	cmp.w		#' ',d0
	ble.s		.stop
	move.b	d0,(a0)+
	addq.l	#1,a2
	bra.s		.copy	
.stop	clr.b		(a0)
	moveq		#0,d0
	bra.s		.out
.err	moveq		#-1,d0
.out	move.l	a2,script_ptr
	rts

read_value:
	move.w	#1,sign
	moveq		#0,d7
	move.l	script_ptr,a2
	moveq		#0,d0
.l2	move.b	(a2),d0
	beq.s		.err
	cmp.w		#13,d0
	beq.s		.err
	cmp.w		#',',d0
	beq.s		.ngs
	cmp.w		#' ',d0
	bgt.s		.gs
.ngs	addq.l	#1,a2
	bra.s		.l2
.gs	cmp.w		#'-',d0
	bne.s		.copy
	neg.w		sign
	addq.l	#1,a2
.copy	move.b	(a2),d0
	beq.s		.err
	bsr		clipcase
	cmp.w		#' ',d0
	ble.s		.stop
	sub.w		#'0',d0
	bmi.s		.err
	mulu		#10,d7
	add.w		d0,d7
	addq.l	#1,a2
	bra.s		.copy	
.stop	muls		sign,d7
	move.w	d7,(a0)
	moveq		#0,d0
	bra.s		.out
.err	moveq		#-1,d0
.out	move.l	a2,script_ptr
	rts

clip_range:
	move.w	(a0),d2
	cmp.w		d0,d2
	bge.s		.o1
	move.w	d0,(a0)
	rts
.o1	cmp.w		d1,d2
	ble.s		.o2
	move.w	d1,(a0)
.o2	rts

flush:
.lp	push.w	#11
	trap		#1
	addq		#2,sp
	tst.w		d0
	beq.s		.ok
	push.w	#7
	trap		#1
	addq		#2,sp
	bra.s		.lp
.ok	rts

*-----------------------------------------*

tokenize:
	lea		command_list,a0
	moveq		#0,d0
.next	moveq		#0,d7
	move.l	(a0)+,d2	; text
	beq.s		.done
	move.l	(a0)+,d3	; routine 
	move.l	(a0)+,a0	; next slot
	move.l	d2,a1
.loop	move.b	(a1)+,d0
	beq.s		.stor
	bsr		clipcase
	add.w		d0,d7
	bra.s		.loop
.stor	and.w		#4096-1,d7
	lea		([command_ptr.l],d7.w*8),a1
	bra.s		.slot
.nslt	addq.l	#8,a1
.slot	tst.l		(a1)
	bne.s		.nslt
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	bra.s		.next
.done	rts

*-----------------------------------------*

x_waitkey:
	push.w	#7
	trap		#1
	addq		#2,sp
	rts

x_waitframe:
	lprint	<"waitframe">
	lea		temp_word,a0
	jsr		read_value
	tst.l		d0
	bmi.s		.err
	move.w	temp_word,d0
	bra.s		.elp
.lp	push.w	d0
	push.w	#37
	trap		#14
	addq		#2,sp
	pop.w		d0
.elp	dbra		d0,.lp
.err	rts

x_setvideo:
	lprint	<"setvideo">
	rts

*-----------------------------------------*

x_showflic:
	lprint	<"showflic">
	rts

x_startflic:
	lprint	<"startflic">
	rts

x_link2flic:
	lprint	<"link2flic">
	rts

*-----------------------------------------*

x_showtarga:
	lprint	<"showtarga">
	rts
	
x_showjpeg:
	lprint	<"showjpeg">
	rts

*-----------------------------------------*

x_filepath:
	lprint	<"filepath">
	jsr		read_equate
	lea		filepath_string,a0
	jsr		read_string
	rts
	
x_flicrate:
	lprint	<"flicrate">
	jsr		read_equate
	lea		flicrate,a0
	jsr		read_value
	rts
	
			rsreset
playmode_disk	rs.b	1
playmode_ram	rs.b	1
	
x_playmode:
	lprint	<"playmode">
	jsr		read_equate
	lea		temp_string,a0
	jsr		read_string
	lea		s_ram,a2
	lea		temp_string,a3
	jsr		strcmp23
	tst.l		d0
	bmi.s		.no_ram
	move.b	#playmode_ram,playmode
	bra.s		.done
.no_ram
	lea		s_disk,a2
	lea		temp_string,a3
	jsr		strcmp23
	tst.l		d0
	bmi.s		.no_disk
	move.b	#playmode_disk,playmode
.no_disk
.done	rts

x_horizontal:
	lprint	<"horizontal">
	jsr		read_equate
	lea		temp_string,a0
	jsr		read_string
	lea		s_high,a2
	lea		temp_string,a3
	jsr		strcmp23
	tst.l		d0
	bmi.s		.no
	st		horizontal
	bra.s		.done
.no	lea		s_low,a2
	lea		temp_string,a3
	jsr		strcmp23
	tst.l		d0
	bmi.s		.done
	sf		horizontal
.done	rts

x_vertical:
	lprint	<"vertical">
	jsr		read_equate
	lea		temp_string,a0
	jsr		read_string
	lea		s_high,a2
	lea		temp_string,a3
	jsr		strcmp23
	tst.l		d0
	bmi.s		.no
	st		vertical
	bra.s		.done
.no	lea		s_low,a2
	lea		temp_string,a3
	jsr		strcmp23
	tst.l		d0
	bmi.s		.done
	sf		vertical
.done	rts

x_widescreen:
	lprint	<"widescreen">
	jsr		read_equate
	lea		temp_string,a0
	jsr		read_string
	lea		s_on,a2
	lea		temp_string,a3
	jsr		strcmp23
	tst.l		d0
	bmi.s		.no
	st		widescreen
	bra.s		.done
.no	lea		s_off,a2
	lea		temp_string,a3
	jsr		strcmp23
	tst.l		d0
	bmi.s		.done
	sf		widescreen
.done	rts

x_imagelines:
	lprint	<"imagelines">
	jsr		read_equate
	lea		image_lines,a0
	jsr		read_value
	move.w	#0,d0
	move.w	max_width,d1
	lea		image_lines,a0
	jsr		clip_range
	rts

x_viewlines:
	lprint	<"viewlines">
	jsr		read_equate
	lea		view_lines,a0
	jsr		read_value
	move.w	#0,d0
	move.w	max_width,d1
	lea		view_lines,a0
	jsr		clip_range
	rts

x_colour:
	lprint	<"colour">
	jsr		read_equate
	lea		video_red,a0
	jsr		read_value
	lea		video_green,a0
	jsr		read_value
	lea		video_blue,a0
	jsr		read_value
	move.w	#0,d0
	move.w	#255,d1
	lea		video_red,a0
	jsr		clip_range
	move.w	#0,d0
	move.w	#255,d1
	lea		video_green,a0
	jsr		clip_range
	move.w	#0,d0
	move.w	#255,d1
	lea		video_blue,a0
	jsr		clip_range
	rts

s_ram:		dc.b	"run",0
s_disk:		dc.b	"disk",0
s_on:			dc.b	"on",0
s_off:		dc.b	"off",0
s_high:		dc.b	"high",0
s_low:		dc.b	"low",0

horizontal:		dc.b	0
vertical:		dc.b	0
widescreen:		dc.b	0
			even

image_lines:	dc.w	320
view_lines:		dc.w	200

video_red:		dc.w	0
video_green:	dc.w	0
video_blue:		dc.w	0

max_width:		dc.w	768
max_height:		dc.w	576

*-----------------------------------------*

keep_palette:
	bsr		get_numcols
	pea		old_palette
	push.w	d0
	push.w	#0
	push.w	#94
	trap		#14
	lea		10(sp),sp
	rts

reset_palette:
	bsr		get_numcols
	pea		old_palette
	push.w	d0
	push.w	#0
	push.w	#93
	trap		#14
	lea		10(sp),sp
	rts

get_numcols:
	move.w	GEM_MODECODE,d0
	and.w		#%111,d0
	beq.s		.bpl1
	subq		#1,d0
	beq.s		.bpl2
	subq		#1,d0
	beq.s		.bpl4
.bpl8	move.w	#256,d0
	bra.s		.keep
.bpl4	moveq		#16,d0
	bra.s		.keep
.bpl2	moveq		#4,d0
	bra.s		.keep
.bpl1	moveq		#2,d0
.keep	rts

get_filename:
	lea		filename,a1
.copy	move.b	(a0)+,d1
	cmp.b		#'A',d1
	blt.s		.ok
	sub.b		#'A',d1
	and.b		#31,d1
	add.b		#'A',d1
.ok	move.b	d1,(a1)+
	dbra		d0,.copy
	clr.b		(a1)+
	lea		filename,a0
.lp	cmp.b		#'.',(a0)+
	bne.s		.lp
	rts

*--------------------------------------------------------------------------*
* Open file.  INPUT a0 = filename, OUTPUT d0=handle
*--------------------------------------------------------------------------*
OpenFile:	move.w	#0,-(sp)
		move.l	a0,-(sp)
		move.w	#$3D,-(sp)
		trap		#1
		addq.w	#8,sp
		rts

*--------------------------------------------------------------------------*
* Close file. INPUT d0 = handle..
*--------------------------------------------------------------------------*
CloseFile:	move.w	d0,-(sp)
		move.w	#$3E,-(sp)
		trap		#1
		addq.w	#4,sp
		rts

*--------------------------------------------------------------------------*
* Write file. INPUT d0=handle, d1=size, a0=buffer, d0=error..
*--------------------------------------------------------------------------*
WriteFile:	move.l	a0,-(sp)
		move.l	d1,-(sp)
		move.w	d0,-(sp)
		move.w	#$40,-(sp)	* Fwrite
		trap		#1
		lea		12(sp),sp
		rts

*--------------------------------------------------------------------------*
* Read file.  INPUT d0=handle, d1=size, a0=buffer, d0=error..
*--------------------------------------------------------------------------*
ReadFile:	move.l	a0,-(sp)
		move.l	d1,-(sp)
		move.w	d0,-(sp)
		move.w	#$3F,-(sp)
		trap		#1
		lea		12(sp),sp
		rts

*--------------------------------------------------------------------------*
* Seek file.  INPUT d0=handle, d1=mode, d2=size, d0=error..
*--------------------------------------------------------------------------*
SeekFile:	move.w	d1,-(sp)
		move.w	d0,-(sp)
		move.l	d2,-(sp)
		move.w	#$42,-(sp)	* Fwrite
		trap		#1
		lea		10(sp),sp
		rts	

get_filesize:
	push.w	#0
	push.l	a0
	push.w	#47
	trap		#1
	addq		#2,sp
	move.l	d0,DTA
	push.w	#78
	trap		#1
	addq.l	#8,sp
	move.l	DTA,a0
	move.l	26(a0),d0
	rts

load:	push.l	a0
	push.l	a1
	push.l	d0
	jsr		get_filesize
	pop.l		d1
	pop.l		a1
	pop.l		a0
	cmp.l		d1,d0
	bgt.s		.err
	push.l	d0
	push.l	a1
	jsr		OpenFile
	pop.l		a0
	pop.l		d1
	tst.l		d0
	ble.s		.err
	push.l	d0
	jsr		ReadFile
	pop.l		d1
	tst.l		d0
	ble.s		.err
	move.l	d1,d0
	jsr		CloseFile
.err	rts

DTA:	ds.l		1

*-----------------------------------------------------------------*
keep_video:
*-----------------------------------------------------------------*
	jsr		Get_KV_monitor
	tst.b		KV_VGA_FLAG
	bne.s		.no0
	st		compat_mode
.no0	push.w	#-1
	push.w	#88
	trap		#14
	addq		#4,sp
	move.w	d0,GEM_MODECODE
	and.w		#7,d0
	cmp.w		#bpl2,d0
	bne.s		.no1
	st		compat_mode
.no1	move.w	GEM_MODECODE,d0
	and.w		#compat,d0
	beq.s		.no2
	st		compat_mode
.no2	tst.b		force_hard
	beq.s		.nx
	sf		compat_mode
.nx	push.l	$70.w
	push.b	ENABLE_A.w
	push.b	ENABLE_B.w
	move.l	#vvbi,$70.w
	move.b	#1<<6,ENABLE_B.w
	move.b	#0,ENABLE_A.w
	move.w	#2,vvbi_t
	move.w	#$2300,sr
.wv	tst.w		vvbi_t
	bne.s		.wv
	move.l	$FFFF820E.w,d0
	move.l	$FFFF8264.w,d1
	movem.l	$FFFF8282.w,d2-5 
	movem.l	$FFFF82A2.w,a0/d6-d7
	move.l	$FFFF82C0.w,a1
	move.w	$FFFF820A.w,a2
	movem.l	a0-2/d0-7,video_kept
	pop.b		ENABLE_B.w
	pop.b		ENABLE_A.w
	pop.l		$70.w
	rts

vvbi:	tst.w		vvbi_t
	beq.s		.done
	subq		#1,vvbi_t
.done	rte

Get_KV_monitor:
	sf		KV_VGA_FLAG
	push.w	#89
	trap		#14
	addq		#2,sp
	tst.w		d0
	beq.s		.mono
	cmp.w		#2,d0
	seq		KV_VGA_FLAG
	moveq		#0,d0
	rts
.mono	moveq		#-1,d0
	rts

*-----------------------------------------------------------------*
unkeep_video:
*-----------------------------------------------------------------*
	tst.b		compat_mode
	bne.s		.compset
	push.l	a0
	push.w	#37
	trap		#14
	addq		#2,sp
	pop.l		d0
	move.b	d0,d1
	lsr.w		#8,d0
	move.l	d0,$FFFF8200.w
	move.b	d1,$FFFF820D.w
	movem.l	video_kept,a0-2/d0-7
	jsr		setmode
	jsr		setmode
	bra.s		.rts
.compset
	push.w	GEM_MODECODE
	push.w	#-1
	push.l	a0
	push.l	a0
	push.w	#5
	trap		#14
	lea		12(sp),sp
	push.w	#88
	trap		#14
	addq		#4,sp
.rts	rts

setmode:
	push.l	$70.w
	push.b	ENABLE_A.w
	push.b	ENABLE_B.w
	move.b	#0,ENABLE_A.w
	move.b	#1<<6,ENABLE_B.w
	move.l	#vvbi,$70.w
	move.w	#2,vvbi_t
	move.w	#$2300,sr
.wv	tst.w		vvbi_t
	bne.s		.wv
	move.l	d0,$FFFF820E.w
	move.l	d1,$FFFF8264.w
	movem.l	d2-5,$FFFF8282.w
	movem.l	a0/d6-7,$FFFF82A2.w
	move.l	a1,$FFFF82C0.w
	move.w	a2,$FFFF820A.w

	move.l	d0,$FFFF820E.w
	move.l	d1,$FFFF8264.w
	movem.l	d2-5,$FFFF8282.w
	movem.l	a0/d6-7,$FFFF82A2.w
	move.l	a1,$FFFF82C0.w
	move.w	a2,$FFFF820A.w

	pop.b		ENABLE_B.w
	pop.b		ENABLE_A.w
	pop.l		$70.w
	rts

*-----------------------------------------------------------------*
set_video:
*-----------------------------------------------------------------*
	tst.b		compat_mode
	bne.s		.compset
	bclr		#pal_bit,d0
	bclr		#os_bit,d0
	lea		video_modes,a1
.next	move.w	(a1)+,d1
	cmp.w		#-1,d1
	beq.s		.rts
	bclr		#pal_bit,d1
	bclr		#os_bit,d1
	cmp.w		d0,d1
	beq.s		.go
	lea		44(a1),a1
	bra.s		.next	
.go	move.l	a1,video_list
	move.l	a0,d0
	move.b	d0,d1
	lsr.w		#8,d0
	move.l	d0,$FFFF8200.w
	move.b	d1,$FFFF820D.w
	movem.l	([video_list.l]),a0-2/d0-7
	jsr		setmode
	bra.s		.rts
.compset
	push.w	d0
	push.w	#-1
	push.l	a0
	push.l	a0
	push.w	#5
	trap		#14
	lea		12(sp),sp
	push.w	#88
	trap		#14
	addq		#4,sp
.rts	rts


*-----------------------------------------------------------------*

GEM_MODECODE:	ds.w	1

vvbi_t:		ds.w	1
video_data:		ds.w	1
video_list:		ds.l	1
video_kept:		ds.l	11
compat_mode:	ds.b	1
force_hard:		ds.b	1
KV_VGA_FLAG:	ds.b	1
			even

*-----------------------------------------------------------------*

*-----------------------------------------*

command		macro
	ifnd		commands
commands		set	0
	endc
	dc.l		.r\@
	dc.l		x_\2
	dc.l		.n\@
.r\@	dc.b		\1,0
	even
s_\2	=		.r\@
.n\@
commands	set	commands+1
	endm

*-----------------------------------------*
	section	data
*-----------------------------------------*
command_ptr:	dc.l	command_buffer
*-----------------------------------------*
command_list:
*-----------------------------------------*
*	Actual commands				*
*-----------------------------------------*
	command	<"waitkey">,waitkey
	command	<"waitframe">,waitframe
	command	<"setvideo">,setvideo
*-----------------------------------------*
	command	<"startflic">,startflic
	command	<"link2flic">,link2flic
*-----------------------------------------*
	command	<"flic">,showflic
	command	<"targa">,showtarga
	command	<"jpeg">,showjpeg
*-----------------------------------------*
*	Standard variables			*
*-----------------------------------------*
	command	<"filepath">,filepath
	command	<"flicrate">,flicrate
	command	<"playmode">,playmode
	command	<"horizontal">,horizontal
	command	<"vertical">,vertical
	command	<"widescreen">,widescreen
	command	<"imagelines">,imagelines
	command	<"viewlines">,viewlines
	command	<"colour">,colour
*-----------------------------------------*
*	End of list					*
*-----------------------------------------*
	dc.l		0

video_modes:
	incbin	f:\inc\vgatrue.vid
	incbin	f:\inc\rgbtclow.vid
	incbin	f:\inc\vga4c.vid
	dc.w		-1

filename:	dc.b	"f:\test.asp",0
		ds.b	256
		even
		
*-----------------------------------------*
	section		bss
*-----------------------------------------*

script_ptr:			ds.l	1

command:			ds.b	32
old_palette:		ds.l	256
old_scr:			ds.l	1

temp_word:			ds.w	1
flicrate:			ds.w	1
sign:				ds.w	1
filepath_string:		ds.b	256
temp_string:		ds.b	256
playmode:			ds.b	1
				even

				ds.l	512
new_usp:			ds.l	1
				ds.l	512
new_ssp:			ds.l	1
old_usp:			ds.l	1

command_buffer:		ds.l	2*(4096+commands)

script_buffer:		ds.b	16000

