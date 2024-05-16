*=======================================================*
*	Display module: updated 12/06/97		*
*=======================================================*

*-------------------------------------------------------*
			rsset	-($186*2)
*-------------------------------------------------------*
VGemCStep		rs.w	3
VGemPlanes		rs.w	41
VGemX			rs.w	1
VGemY			rs.w	12
VGemCol			rs.w	310
VCelHT			rs.w	1
VCelMX			rs.w	1
VCelMY			rs.w	1
VCelWR			rs.w	14
VXMax			rs.w	4
VYMax			rs.w	1
VBytesLin		rs.w	1
*-------------------------------------------------------*
*		LineA base (0)				*
*-------------------------------------------------------*
VPlanes			rs.w	1
VWrap			rs.w	1
*-------------------------------------------------------*

*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
mt_mono			rs.b	1
mt_rgb			rs.b	1
mt_vga			rs.b	1
mt_tv			rs.b	1

*-------------------------------------------------------*
monitor_detect:
*-------------------------------------------------------*
	push.w		#89
	trap		#14
	addq		#2,sp
	move.b		d0,monitor_type
	rts
	
*-------------------------------------------------------*
*	Back up old GEM / TOS screen for clean exit	*
*-------------------------------------------------------*
save_screen:
*-------------------------------------------------------*
*	Store original settings				*
*-------------------------------------------------------*
	push.w		#2
	trap		#14
	addq.l		#2,sp
	move.l		d0,os_screen
	push.w		#-1
	push.w		#88
	trap		#14
	addq.l		#4,sp
	move.w		d0,os_modecode
	push.w		d0
	push.w		#91
	trap		#14
	addq.l		#4,sp
	move.l		d0,os_screen_size
	rts

*-------------------------------------------------------*
restore_screen:
*-------------------------------------------------------*
	tst.b		display_on
	bne.s		.go
	rts
.go:	sf		display_on

	cmp.l		#-1,phys_handle
	beq.s		.err
	move.l		os_screen,a0
	move.w		os_modecode,d0
	bsr		set_video
.err:	rts

*-------------------------------------------------------*
save_palette:
*-------------------------------------------------------*
	tst.b		palette_on
	beq.s		.go
	rts
.go:	st		palette_on

	move.w		os_modecode,d0
	btst		#true_bit,d0
	bne.s		.err
	and.w		#%111,d0
	moveq		#2,d1
	bra.s		.strt
.shft:	mulu.w		d1,d1
.strt:	dbra		d0,.shft
	pea		os_palette
	push.w		d1
	push.w		#0
	push.w		#94
	trap		#14
	lea		10(sp),sp
.err:	rts

*-------------------------------------------------------*
restore_palette:
*-------------------------------------------------------*
	tst.b		palette_on
	bne.s		.go
	rts
.go:	sf		palette_on

	move.w		os_modecode,d0
	btst		#true_bit,d0
	bne.s		.err
	and.w		#%111,d0
	moveq		#2,d1
	bra.s		.strt
.shft:	mulu.w		d1,d1
.strt:	dbra		d0,.shft
	pea		os_palette
	push.w		d1
	push.w		#0
	push.w		#93
	trap		#14
	lea		10(sp),sp
.err:	rts

*-------------------------------------------------------*
default_video:
*-------------------------------------------------------*
	tst.b		display_on
	beq.s		.go
	rts
.go:	st		display_on
*-------------------------------------------------------*
	dc.w		$A000
	move.l		d0,a0
	cmp.w		#16,VPlanes(a0)
	beq		.system_mode
*-------------------------------------------------------*
.videl_mode:
*-------------------------------------------------------*
*	Custom display - use double/triple-buffering	*
*-------------------------------------------------------*
	move.b		#3,clearcount
	bsr		setup_videl_screen
	bra.s		.mode_done
*-------------------------------------------------------*
.system_mode:
*-------------------------------------------------------*
*	System display - no double/triple-buffering	*
*-------------------------------------------------------*
	move.b		#1,clearcount
	bsr		setup_system_screen
*-------------------------------------------------------*
.mode_done:
*-------------------------------------------------------*
*	Calculate useful screen variables		*
*-------------------------------------------------------*
	move.w		screen_w,d1
	move.w		d1,scrwidth
	add.w		d1,d1
	move.w		d1,bytewidth
*-------------------------------------------------------*
*	Create optional fastram screenbuffer		*
*-------------------------------------------------------*
	ifd		frsb
	move.w		bytewidth,d0
	mulu.w		#max_columns,d0
	add.l		#8192*2,d0
	moveq		#VRAM_preferred,d1
	bsr		allocate_chunk
	add.l		#8192-1,d0
	and.l		#-8192,d0
	move.l		d0,ScreenLog
	endc
	rts
	
*-------------------------------------------------------*
*	Configure screen output for system display	*
*-------------------------------------------------------*
setup_system_screen:
*-------------------------------------------------------*
*	Custom video mode does not exist		*
*-------------------------------------------------------*
	move.l		#-1,phys_handle
	move.w		#-1,modecode
	sf		videl_mode
*-------------------------------------------------------*
*	Set up display variables			*
*-------------------------------------------------------*
	move.l		os_screen,ScreenPhy
	move.l		os_screen,ScreenLog
	move.l		os_screen,ScreenBak
	move.l		os_screen_size,phys_size
	move.w		os_screen_w,screen_w
	move.w		os_screen_h,screen_h
*-------------------------------------------------------*
*	Clear screen					*
*-------------------------------------------------------*
	move.l		os_screen,a0
	move.l		os_screen_size,d0
	lsr.l		#2,d0
	jsr		clearlongs
	rts	

*-------------------------------------------------------*
*	Configure screen output for custom display	*
*-------------------------------------------------------*
setup_videl_screen:
*-------------------------------------------------------*
*	Tune relevant modecode for this monitor		*
*-------------------------------------------------------*
	move.w		#vga|pal,d0
	move.w		d0,d1
	not.w		d0
	and.w		os_modecode,d1
	and.w		default_modecode,d0
	or.w		d1,d0
	btst		#vga_bit,d0
	beq.s		.nvga
	bclr		#pal_bit,d0
	eor.w		#lace,d0
.nvga:	move.w		d0,modecode
*-------------------------------------------------------*
*	Interrogate screen size (memory)		*
*-------------------------------------------------------*
	push.w		d0
	push.w		#91
	trap		#14
	addq.l		#4,sp
	move.l		d0,phys_size
*-------------------------------------------------------*
*	Allocate space for 2 or 3 screen buffers	*
*-------------------------------------------------------*
	move.l		phys_size,d0
	jsr		allocate_screens
*-------------------------------------------------------*
*	Switch to new video mode			*
*-------------------------------------------------------*
	move.l		ScreenPhy,a0
	move.w		modecode,d0
	jsr		set_video
*-------------------------------------------------------*
*	Work out screen dimensions from size & span	*
*-------------------------------------------------------*
	moveq		#0,d1
	move.w		$FFFF8210.w,d1
	move.w		d1,screen_w
	add.l		d1,d1
	move.l		phys_size,d0
	divu.l		d1,d0
	move.w		d0,screen_h
*-------------------------------------------------------*
*	No brick-bat fix for TV/RGB			*
*-------------------------------------------------------*
	sf		brick_bat
*-------------------------------------------------------*
*	Brick-bat determination - avoid 4:6 ratios	*
*-------------------------------------------------------*
	moveq		#0,d1
	move.w		screen_w,d1
	moveq		#0,d2
	move.w		screen_h,d2
	swap		d1
	swap		d2
	divu.l		#640,d1
	divu.l		#480,d2
	lsr.l		#8,d1
	lsl.l		#8,d2
	divu.l		d1,d2
	cmp.l		#$18000,d2
	ble		.normal_mode
*-------------------------------------------------------*
*	Check ilace & dline				*
*-------------------------------------------------------*
	move.w		$FFFF82C2.w,d0
	bclr		#1,d0
	bne.s		.new_mode	
	bset		#0,d0
	bne.s		.normal_mode
*-------------------------------------------------------*
*	Update ilace/dline				*
*-------------------------------------------------------*
.new_mode:
*-------------------------------------------------------*
	move.w		d0,$FFFF82C2.w
*-------------------------------------------------------*
*	Half screen-height (4:6 -> 4:3)			*
*-------------------------------------------------------*
	lsr.w		screen_h
*-------------------------------------------------------*
*	Deallocate screen				*
*-------------------------------------------------------*
	move.l		phys_handle,d0
	bsr		deallocate_chunk
*-------------------------------------------------------*
*	Reallocate half-sized screen buffers		*
*-------------------------------------------------------*
	move.l		phys_size,d0
	lsr.l		d0
	jsr		allocate_screens
*-------------------------------------------------------*
*	Set new screenbase				*
*-------------------------------------------------------*
	move.l		ScreenPhy,a0
	bsr		set_base	
*-------------------------------------------------------*
*	Brick-bat flag					*	
*-------------------------------------------------------*
	st		brick_bat
*-------------------------------------------------------*
.normal_mode:
*-------------------------------------------------------*
*	Calculate number of scanlines			*
*-------------------------------------------------------*
	bsr		calculate_video_lines
*-------------------------------------------------------*
*	Finish setting up videl				*
*-------------------------------------------------------*
	move.w		SCAN_START.w,upper_border
	move.w		SCAN_STOP.w,lower_border
	bsr		adjust_scanlines
	st		videl_mode
*-------------------------------------------------------*
*	Set background colour				*
*-------------------------------------------------------*
	move.l		#(bg_colour<<8),d0
	lsr.w		#8,d0
	move.l		d0,$FFFF9800.w
	rts

*-------------------------------------------------------*
calculate_video_lines:
*-------------------------------------------------------*
	sf		dline_active
	sf		ilace_active
	move.w		screen_h,d0
	moveq		#1,d2		; start with halflines
	move.w		$FFFF82C2.w,d0
	btst		#0,d0
	beq.s		.nodl
	addq.w		#1,d2		; dline = 2x normal scanlines
	st		dline_active
.nodl:	btst		#1,d0
	beq.s		.noil
	subq.w		#1,d2		; ilace = 1/2 normal scanlines
	st		ilace_active
.noil:	move.w		d2,scan_shift
	rts

*-------------------------------------------------------*
allocate_screens:
*-------------------------------------------------------*
	ifd		frsb
*-------------------------------------------------------*
*	Allocate 2 screenbuffers for 'FRSB' mode	*
*-------------------------------------------------------*
	mulu.l		#2,d0
	move.l		d0,display_size
	add.l		#8192*2,d0
	moveq		#STRAM_only,d1
	bsr		allocate_chunk
	move.l		d0,phys_handle
	ble		err_display
	add.l		#8192-1,d0
	and.l		#-8192,d0
	move.l		d0,display_start
	move.l		d0,ScreenPhy
	add.l		phys_size,d0
	move.l		d0,ScreenBak
*-------------------------------------------------------*
	elseif
*-------------------------------------------------------*
*	Allocate 3 screenbuffers for 'direct' mode	*
*-------------------------------------------------------*
	mulu.l		#3,d0
	move.l		d0,display_size
	add.l		#8192*2,d0
	moveq		#STRAM_only,d1
	bsr		allocate_chunk
	move.l		d0,phys_handle
	ble		err_display
	add.l		#8192-1,d0
	and.l		#-8192,d0
	move.l		d0,display_start
	move.l		d0,ScreenLog
	add.l		phys_size,d0
	move.l		d0,ScreenPhy
	add.l		phys_size,d0
	move.l		d0,ScreenBak
*-------------------------------------------------------*
	endc
*-------------------------------------------------------*
*	Clear screenbuffers				*
*-------------------------------------------------------*
	move.l		display_start,a0
	move.l		display_size,d0
	lsr.l		#2,d0
	jsr		clearlongs
	rts
	
*-------------------------------------------------------*
set_video:
*-------------------------------------------------------*
	move.w		d0,temp_modecode
	move.l		a0,temp_physbase
*-------------------------------------------------------*
	push.w		#37
	trap		#14
*-------------------------------------------------------*
	push.w		#-1
	push.w		#-1
	push.l		temp_physbase
	push.l		temp_physbase
	push.w		#5
	trap		#14
*-------------------------------------------------------*
	push.w		#37
	trap		#14
*-------------------------------------------------------*
	push.w		temp_modecode
	push.w		#88
	trap		#14
*-------------------------------------------------------*
	push.w		#37
	trap		#14
*-------------------------------------------------------*
	lea		2+2+2+14+4(sp),sp
	rts

*-------------------------------------------------------*
set_base:
*-------------------------------------------------------*
	push.w		#-1
	push.l		a0
	push.l		a0
	push.w		#5
	trap		#14
	lea		12(sp),sp
	rts

*-------------------------------------------------------*
*	Wipe framebuffer				*
*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
clearscreen:
*-------------------------------------------------------*
	tst.b		refresh
	bne.s		.go
	rts
.go:	subq.b		#1,refresh
	move.w		screen_w,d0
	tst.b		videl_mode
	bne.s		.videl
	mulu.w		screen_h,d0
	bra.s		.ok
.videl:	mulu.w		viewport_height,d0
.ok:	lsr.l		d0
*-------------------------------------------------------*
clearlongs:
*-------------------------------------------------------*
	movem.l		d0-d4/a0,-(sp)
*---------------------------------------------------------------*
	lsl.l		#2,d0		; size in bytes
	beq.s		.done		; check for zero
*---------------------------------------------------------------*
	move.l		a0,d4
	add.l		d0,d4		; block end
*---------------------------------------------------------------*
	moveq		#0,d2
*---------------------------------------------------------------*
*	Clear initial segment (bytes: 0->7)			*
*---------------------------------------------------------------*
	moveq		#8-1,d1
	add.l		a0,d1
	and.w		#-8,d1
	sub.l		a0,d1		; initial segment size (0-7)
	sub.l		d1,d0
	bpl.s		.c1g		; initial segment <= total size
	add.l		d0,d1		; initial segment = total size
.c1l:	move.b		d2,(a0)+
.c1g:	dbra		d1,.c1l
	tst.l		d0
	beq.s		.done		; job done	
*---------------------------------------------------------------*
	move.l		d0,d3
	lsr.l		#2,d3
*---------------------------------------------------------------*
*	Clear main segment (longwords)				*
*---------------------------------------------------------------*
	moveq		#8-1,d1
	and.l		d3,d1
	lsr.l		#3,d3
	neg.l		d1
	jmp		.jmp(pc,d1.l*2)
.loop:	move.l		d2,(a0)+
	move.l		d2,(a0)+
	move.l		d2,(a0)+
	move.l		d2,(a0)+
	move.l		d2,(a0)+
	move.l		d2,(a0)+
	move.l		d2,(a0)+
	move.l		d2,(a0)+
.jmp:	subq.l		#1,d3
	bpl.s		.loop
*---------------------------------------------------------------*
*	Clear remaining segment (bytes: 0->7)			*
*---------------------------------------------------------------*
	move.l		d4,d0
	sub.l		a0,d0
	bra.s		.c2g
.c2l:	move.b		d2,(a0)+
.c2g:	dbra		d0,.c2l
*---------------------------------------------------------------*
.done:	movem.l		(sp)+,d0-d4/a0
	rts

*-------------------------------------------------------*
*	Adjust vertical screen height			*
*-------------------------------------------------------*
adjust_scanlines:
*-------------------------------------------------------*	
	tst.b		adjust
	bne.s		.go
.err:	rts
.go:	subq.b		#1,adjust
*-------------------------------------------------------*	
*	Don't adjust scanlines unless VIDEL is used	*
*-------------------------------------------------------*	
	tst.b		videl_mode
	beq.s		.err
*-------------------------------------------------------*	
*	Remove unused scanlines on VIDEL modes		*
*-------------------------------------------------------*	
	move.w		scan_shift,d0
	move.w		height,d6
	tst.b		halflines
	beq.s		.vcont
	add.w		d6,d6
.vcont:	move.w		screen_h,d7
	lsl.w		d0,d6
	lsl.w		d0,d7
	sub.w		d6,d7
	lsr.w		d7
	move.w		upper_border,d1
	move.w		lower_border,d2
	add.w		d7,d1
	sub.w		d7,d2	

;	subq.w		#1,d1
;	subq.w		#1,d2
;	and.w		#-2,d1
;	and.w		#-2,d2
;	addq.w		#1,d1
;	addq.w		#1,d2

	move.w		d2,SCAN_STOP.w
	move.w		d1,SCAN_START.w
*-------------------------------------------------------*	
*	Set up relevant 'detail' bits			*
*-------------------------------------------------------*
	move.w		$FFFF82C2.w,d0
	move.w		d0,d1
	and.w		#~%11,d0
	tst.b		dline_active
	beq.s		.nodl
	bset		#0,d0
.nodl:	tst.b		ilace_active
	beq.s		.noil
	bset		#1,d0
.noil:	cmp.w		d0,d1
	beq.s		.same
	move.w		d0,$FFFF82C2.w
.same:	rts

*-------------------------------------------------------*
centre_screen:
*-------------------------------------------------------*
	move.l		ScreenLog,d0
	move.w		width,d2
	move.w		screen_w,d1
	tst.b		halfrows
	beq.s		.no
	add.w		d2,d2
.no:	sub.w		d2,d1
	lsr.w		d1
	ext.l		d1
	add.l		d1,d1
	add.l		d1,d0

	tst.b		videl_mode
	bne.s		.cont

	move.w		height,d2
	move.w		screen_h,d1
	tst.b		halflines
	beq.s		.no2
	add.w		d2,d2
.no2:	sub.w		d2,d1
	lsr.w		d1
	mulu.w		bytewidth,d1
	add.l		d1,d0
	
.cont:	move.l		d0,screen
	rts


*---------------------------------------------------------------*
			datlong
*---------------------------------------------------------------*
	
;default_modecode:	dc.w	bpl8|hires|lace
;default_modecode:	dc.w	bpl4|hires|lace
;default_modecode:	dc.w	bpl8

default_modecode:	dc.w	true
;default_modecode:	dc.w	true|lace
;default_modecode:	dc.w	true|lace|hires

;default_modecode:	dc.w	true|pal|os
;default_modecode:	dc.w	true|lace|hires|pal|os
	
*---------------------------------------------------------------*
			bsslong
*---------------------------------------------------------------*

sys_default_width:	ds.w	1	;320	; default width
sys_default_height:	ds.w	1	;168	; vertical normal mode (status bar)
sys_expanded_height:	ds.w	1	;200	; vertical fullscreen mode
sys_base_aspect:	ds.w	1	;200	; base reference (unadjusted) ratio.
sys_vga_aspect:		ds.w	1	;200	; relative VGA aspect ratio.
sys_rgb_aspect:		ds.w	1	;168	; relative PAL aspect ratio.

os_palette:		ds.l	256
xb_palette:		ds.l	256

os_screen:		ds.l	1
os_screen_size:		ds.l	1
os_screen_clone:	ds.l	1

temp_physbase:		ds.l	1
phys_size:		ds.l	1
phys_handle:		ds.l	1

temp_modecode:		ds.w	1
modecode:		ds.w	1
screen_w:		ds.w	1
screen_h:		ds.w	1

os_modecode:		ds.w	1
os_screen_w:		ds.w	1
os_screen_h:		ds.w	1

brick_bat:		ds.b	1
monitor_type:		ds.b	1
			even

screen_ptrs:					; cyclic screen pointers
ScreenLog:		ds.l	1	
ScreenBak:		ds.l	1	
ScreenPhy:		ds.l	1	
screen:			ds.l	1		; back screen for drawing

display_start:		ds.l	1
display_size:		ds.l	1

old_screen:		ds.l	1		; old screen info
old_border:		ds.l	1

bytewidth:		ds.w	1		; bytes / line in screen
scrwidth:		ds.w	1		; pixels / line in screen
upper_border:		ds.w	1		; custom border sizes
lower_border:		ds.w	1
scan_shift:		ds.w	1

clearcount:		ds.b	1
refresh:		ds.b	1		; force #n successive screen-clears
adjust:			ds.b	1		; force video scanline readjustments
halflines:		ds.b	1		; vertical low-detail
halfrows:		ds.b	1		; horizontal low-detail
fullscreen:		ds.b	1		; 320x200 'super' screen mode
videl_mode:		ds.b	1

dline_active:		ds.b	1
ilace_active:		ds.b	1
dpixel_active:		ds.b	1

palette_on:		ds.b	1
display_on:		ds.b	1
			even

*---------------------------------------------------------------*
			txtlong
*---------------------------------------------------------------*
