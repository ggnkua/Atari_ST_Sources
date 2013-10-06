*=======================================================*
*	Screen module: latest update 25/03/96		*
*=======================================================*
*	Handle video modes and screenbuffers		*
*=======================================================*

*-------------------------------------------------------*
*	Select new video mode & store old values	*
*-------------------------------------------------------*
select_video:
*-------------------------------------------------------*
*	Set up screen variables				*
*-------------------------------------------------------*
	move.w		#max_xres,scrwidth
*-------------------------------------------------------*
*	Store old video mode				*
*-------------------------------------------------------*
	push.w		#-1
	push.w		#88
	trap		#14
	addq.l		#4,sp
	move.w		d0,old_video
*-------------------------------------------------------*
*	Store old screen base				*
*-------------------------------------------------------*
	push.w		#2
	trap		#14
	addq.l		#2,sp
	move.l		d0,old_screen
*-------------------------------------------------------*
*	Create new video mode for correct monitor	*
*-------------------------------------------------------*
	move.w		old_video,d0
	and.w		#vga,d0
	beq.s		.rgb
.vga:	move.w		#true|lace|vga,d1
	move.w		#240,scanlines
	bra.s		.set
.rgb:	move.w		#200,scanlines
	move.w		old_video,d1
	and.w		#pal,d1
	or.w		#true,d1
*-------------------------------------------------------*
*	Set new video mode				*
*-------------------------------------------------------*
.set:	push.w		d1
	push.w		#-1
	push.l		ScreenPhy
	push.l		ScreenLog
	push.w		#5
	trap		#14
	lea		12(sp),sp
	push.w		#88
	trap		#14
	addq.l		#4,sp
*-------------------------------------------------------*
*	Calculate screen height				*
*-------------------------------------------------------*
	move.w		SCAN_START.w,upper_border
	move.w		SCAN_STOP.w,lower_border
	bsr		adjust_scanlines
*-------------------------------------------------------*
*	Set background/border colour to black		*
*-------------------------------------------------------*
	move.l		$ffff9800.w,old_border
	clr.l		$ffff9800.w

;	include		video\rgb_pal\256-200c.50
;	move.w		#320-256,$FFFF820E.w

	rts
	
*-------------------------------------------------------*
*	Reset video mode & screens to old values	*
*-------------------------------------------------------*
restore_video:
*-------------------------------------------------------*
*	Reset screen base				*
*-------------------------------------------------------*
	move.l		old_screen,d0
	move.l		d0,d1
	lsr.w		#8,d0
	move.l		d0,$ffff8200.w
	move.b		d1,$ffff820d.w
*-------------------------------------------------------*
*	Reset border colour				*
*-------------------------------------------------------*
	move.l		old_border,$ffff9800.w
*-------------------------------------------------------*
*	Reset video mode & TOS screens			*
*-------------------------------------------------------*
	push.w		old_video
	push.w		#-1
	push.l		old_screen
	push.l		old_screen
	push.w		#5
	trap		#14
	lea		12(sp),sp
	push.w		#88
	trap		#14
	addq.l		#4,sp
	rts

*-------------------------------------------------------*
*	Adjust vertical screen height			*
*-------------------------------------------------------*
adjust_scanlines:
*-------------------------------------------------------*
	tst.b		adjust
	bne.s		.go
	rts
.go:	subq.b		#1,adjust
	move.w		height,d7
	move.w		old_video,d3
	and.w		#vga,d3
	bne.s		.cont
	tst.b		halflines
	beq.s		.cont
	add.w		d7,d7
.cont:	move.w		scanlines,d0
	sub.w		d7,d0
	tst.w		d3
	beq.s		.nvg
	add.w		d0,d0
.nvg:	move.w		upper_border,d1
	move.w		lower_border,d2
	add.w		d0,d1
	sub.w		d0,d2
	tst.w		d3
	bne.s		.v2
	and.w		#-2,d1
	and.w		#-2,d2
	or.w		#1,d1
	or.w		#1,d2
.v2:
	move.w		d2,SCAN_STOP.w
	move.w		d1,SCAN_START.w
	tst.w		d3
	bne.s		.con2
	bclr		#0,$FFFF82C3.w
	tst.b		halflines
	beq.s		.con2
	bset		#0,$FFFF82C3.w
.con2:	rts

*-------------------------------------------------------*
*	Allocate space for screenbuffers		*	
*-------------------------------------------------------*
allocate_screens:
*-------------------------------------------------------*
	Mxalloc		#(max_xres*max_yres*2)+256,STRAM_only
	add.l		#255,d0
	sub.b		d0,d0
	move.l		d0,ScreenLog	
	Mxalloc		#(max_xres*max_yres*2)+256,STRAM_only
	add.l		#255,d0
	sub.b		d0,d0
	move.l		d0,ScreenPhy
	Mxalloc		#(max_xres*max_yres*2)+256,STRAM_only
	add.l		#255,d0
	sub.b		d0,d0
	move.l		d0,ScreenBak
.end:	move.b		#3,refresh
	move.l		ScreenLog,a0
	move.l		#(max_xres*max_yres)/2,d0
	bsr		clearlongs
	move.l		ScreenPhy,a0
	move.l		#(max_xres*max_yres)/2,d0
	bsr		clearlongs
	move.l		ScreenBak,a0
	move.l		#(max_xres*max_yres)/2,d0
	bsr		clearlongs
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
	move.w		#320/2,d0
	mulu.w		viewport_height,d0
*-------------------------------------------------------*
clearlongs:
*-------------------------------------------------------*
	moveq		#0,d1
	move.l		d1,d2
	move.l		d2,d3
	move.l		d2,d4
	move.l		d2,d5
	move.l		d2,d6
	move.l		d2,d7
	move.l		d2,a2
	move.l		d2,a3
	moveq		#128-1,d1
	and.l		d0,d1
	bra.s		.strt
.long	move.l		d2,(a0)+
.strt	dbra		d1,.long
	lsr.l		#7,d0
	move.l		d0,d1
	lsl.l		#8,d1				; *256
	lsl.l		#1,d1				; *2	=  *512
	add.l		d1,a0
	bra.s		.next
.clr	movem.l		d2-d7/a2-a3,-(a0)		; 4*8*16 = 512
	movem.l		d2-d7/a2-a3,-(a0)
	movem.l		d2-d7/a2-a3,-(a0)
	movem.l		d2-d7/a2-a3,-(a0)
	movem.l		d2-d7/a2-a3,-(a0)
	movem.l		d2-d7/a2-a3,-(a0)
	movem.l		d2-d7/a2-a3,-(a0)
	movem.l		d2-d7/a2-a3,-(a0)
	movem.l		d2-d7/a2-a3,-(a0)
	movem.l		d2-d7/a2-a3,-(a0)
	movem.l		d2-d7/a2-a3,-(a0)
	movem.l		d2-d7/a2-a3,-(a0)
	movem.l		d2-d7/a2-a3,-(a0)
	movem.l		d2-d7/a2-a3,-(a0)
	movem.l		d2-d7/a2-a3,-(a0)
	movem.l		d2-d7/a2-a3,-(a0)
.next	dbra		d0,.clr
	rts

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

screen_ptrs:					; cyclic screen pointers
ScreenLog:		ds.l	1	
ScreenBak:		ds.l	1	
ScreenPhy:		ds.l	1	
screen:			ds.l	1		; back screen for drawing

old_screen:		ds.l	1		; old screen info
old_border:		ds.l	1

scrwidth:		ds.w	1		; pixels / line in screen
scanlines:		ds.w	1		; current scanlines in screen
upper_border:		ds.w	1		; custom border sizes
lower_border:		ds.w	1
old_video:		ds.w	1		; original video mode

refresh:		ds.b	1		; force #n successive screen-clears
adjust:			ds.b	1		; force video scanline readjustments
halflines:		ds.b	1		; vertical low-detail
halfrows:		ds.b	1		; horizontal low-detail
fullscreen:		ds.b	1		; 320x240 'super' screen mode

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*
			