;
;
;
;
; SCREEN.S
;
; code to handle setting of resolutions, size of screens,
; swapping etc.
;
;

scr_screensize		equ	2*384*240	;max size in bytes

;-----------------------------------------------------------------
			section	text
;-----------------------------------------------------------------
			rsreset
scr_rgb50		rs.l	1
scr_rgb60		rs.l	1
scr_vga60		rs.l	1
scr_vga100		rs.l	1

;-----------------------------------------------------------------
scr_init:
; discover monitor type here?
		move.w	#0,monitor_type		;assume rgb
		move.w	#10,bytesperline
		move.w	#10,lines
		move.w	#10,pixelsperline
		bsr	scr_init_screens
		rts

scr_init_screens:
		move.l	$44e.w,d0
		sub.l	#scr_screensize,d0
		sub.b	d0,d0
		move.l	d0,third
		sub.l	#scr_screensize,d0
		sub.b	d0,d0
		move.l	d0,logic
		sub.l	#scr_screensize,d0
		sub.b	d0,d0
		move.l	d0,physic
		rts

;-----------------------------------------------------------------
scr_set_monitor:
		move.w	d0,monitor_type
		rts

; call with a0=address of res routine
; in future we'll do this via vbl
scr_set_resolution:
		move.w	monitor_type,d0
		move.l	(a0,d0.w*4),a1
		jsr	(a1)
		moveq	#0,d0			;calc screen size
		move.w	bytesperline(pc),d0
		mulu.w	lines(pc),d0
		move.l	d0,screensize
		rts

;-----------------------------------------------------------------
scr_swap_screens_two:
		MOVE.L	logic,D0
		MOVE.L	physic,logic
		MOVE.L	D0,physic
		rts
;-----------------------------------------------------------------
scr_swap_screens_three:
		MOVE.L	logic,D0
		MOVE.L	third,logic
		MOVE.L	physic,third
		MOVE.L	D0,physic
		rts
;-----------------------------------------------------------------
scr_set_screen:
		MOVE.L	physic,-(A7)
		MOVE.B	1(A7),$ffff8201.W
		MOVE.B	2(A7),$ffff8203.W
		MOVE.B	3(A7),$ffff820d.W
		ADDQ.L	#4,A7
		rts


;-----------------------------------------------------------------
scr_384x100tc:
		dc.l	.rgb50
		dc.l	.rgb60
		dc.l	.vga60
		dc.l	.vga100
.rgb50:
.rgb60:

* Monitor: RGB/TV
* 384*100, True Color, 50.0 Hz, 15625 Hz
	        MOVE.L   #$FE00CC,$FFFF8282.W
	        MOVE.L   #$280019,$FFFF8286.W
	        MOVE.L   #$BA00D9,$FFFF828A.W
	      	MOVE.L   #$2710265,$FFFF82A2.W
	        MOVE.L   #$2F0081,$FFFF82A6.W
	        MOVE.L   #$211026B,$FFFF82AA.W
	        MOVE.W   #$200,$FFFF820A.W
	        MOVE.W   #$181,$FFFF82C0.W
	        CLR.W    $FFFF8266.W
	        MOVE.W   #$100,$FFFF8266.W
	        MOVE.W   #$1,$FFFF82C2.W
	        MOVE.W   #$180,$FFFF8210.W
		move.w	#384,pixelsperline
		move.w	#384*2,bytesperline
		move.w	#100,lines
		rts

.vga60:
.vga100:
		include	system\res\v3810tc.s
		move.w	#64,$ffff820e.w
		move.w	#384,pixelsperline
		move.w	#384*2,bytesperline
		move.w	#100,lines
		rts

;-----------------------------------------------------------------
scr_320x2408:
		dc.l	.rgb50
		dc.l	.rgb60
		dc.l	.vga60
		dc.l	.vga100
.rgb50:
.rgb60:
		rts

.vga60:
.vga100:
		include	system\res\3224v256.s
		move.w	#0,$ffff820e.w
		move.w	#320,BytesPerLine
		move.w	#240,Lines
		move.w	#320,PixelsPerLine	
		rts

;-----------------------------------------------------------------
; d0 = colour of background
; a0 = screen address
scr_reptval 	equ	4

scr_clearscreen_fast:
		move.l	a0,a6
		add.l	screensize,a6
		move.l	d0,d1
		move.l	d1,d2
		move.l	d1,d3
		move.l	d1,d4
		move.l	d1,d5
		move.l	d1,d6
		move.l	d1,d7
		move.l	d1,a0
		move.l	d1,a1
		move.l	d1,a2
		move.l	d1,a3
		move.l	d1,a4
		move.l	d1,a5
		move.l	#$0001,d0
		movec	d0,cacr

; calculate the repeat size:
		move.l	screensize,d0
		divu	#13*4*scr_reptval,d0
		;subq.w	#1,d0
		;bne.s	.nowipe	
.wipe:		rept	scr_reptval
		movem.l	d1-a5,-(a6)
		endr
		dbf	d0,.wipe
.nowipe:
		move.l	#$1919,d0
		movec	d0,cacr
		rts
;-----------------------------------------------------------------
scr_clearscreens_three:
		move.l	third,A0
		bsr	scr_clrscr
scr_clearscreens_two:
		move.l	physic,A0
		bsr	scr_clrscr
		move.l	logic,A0
		;bsr	scr_clrscr
scr_clrscr:
		move.l	screensize,d1
		asr.l	#4,d1
.clearit:
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		subq.l	#1,d1
		bne.s	.clearit
		rts


;-----------------------------------------------------------------
monitor_type:		ds.w	1
logic:			ds.l	1
physic:			ds.l	1
third:			ds.l	1
bytesperline:		ds.w	1
pixelsperline:		ds.w	1
lines:			ds.w	1
screensize:		ds.l	1		;in BYTES
;-----------------------------------------------------------------
			section	text
