; Falcon demosystem
; September 11, 2011
;
; common.s

		section	text


;---------------------------------------------------------------
;		Palette stuff
;---------------------------------------------------------------


black_palette:	lea	$ffff9800.w,a0				;Black palette
		move.w	#256-1,d7				;
.loop:		clr.l	(a0)+					;
		dbra	d7,.loop				;
dummy:		rts						;


white_palette:	lea	$ffff9800.w,a0				;White palette
		move.l	#$ffff00ff,d0				;
		move.w	#256-1,d7				;
.loop:		move.l	d0,(a0)+				;
		dbra	d7,.loop				;
		rts						;

;---------------------------------------------------------------
;		Clear workscreens
;---------------------------------------------------------------

clear_all_screens:						;Clear all three workscreens
		move.l	screen_adr1,a0				;Clears the size of the current resolution
		move.l	screen_adr2,a1
		move.l	screen_adr3,a2
		move.w	video_height,d7
		subq.w	#1,d7
.y:		move.w	video_width,d6
		cmp.w	#16,video_depth
		bne.s	.eight
		lsr.w	#1,d6
		bra.s	.sub
.eight:		lsr.w	#2,d6
.sub:		subq.w	#1,d6
.x:		clr.l	(a0)+
		clr.l	(a1)+
		clr.l	(a2)+
		dbra	d6,.x
		dbra	d7,.y
		rts


;---------------------------------------------------------------
;		Generate lookup table for hicolour alpha
;---------------------------------------------------------------

	ifne	lutp_enable
lutp_generate:
; input
; a0 = address to BMP file with 54byte header and 1024 byte palette
		move.l	a0,a6
		lea	54(a6),a6
		lea	lutp,a0
		move.w	#128-1,d7
.shade:		move.l	a6,a1					;bmp palette: RRGGBB00
		move.w	#256-1,d6
.col:
		move.l	(a1)+,d0				;RRGGBB00
		lsr.l	#8,d0					;b
		move.l	d0,d1
		lsr.l	#8,d1					;g
		move.l	d1,d2
		lsr.l	#8,d2					;r
		and.l	#$ff,d0					;r
		and.l	#$ff,d1					;g
		and.l	#$ff,d2					;b
		movem.w	d0-d2,-(sp)
		eor.w	#$7f,d7					;0->127 : 0->rgb
		mulu	d7,d0
		mulu	d7,d1
		mulu	d7,d2
		lsr.w	#7,d0
		lsr.w	#7,d1
		lsr.w	#7,d2
		lsr.w	#3,d0					;5
		lsr.w	#2,d1					;6
		lsr.w	#3,d2					;5
		lsl.w	#6,d0
		or.w	d1,d0
		lsl.w	#5,d0
		or.w	d2,d0
		move.w	d0,(a0)+

		movem.w	(sp)+,d0-d2				;rgb
		move.w	d0,d3
		move.w	d1,d4
		move.w	d2,d5
		eor.b	#$ff,d0					;255-r
		eor.b	#$ff,d1
		eor.b	#$ff,d2
		rept	2
		mulu	d7,d0
		mulu	d7,d1
		mulu	d7,d2
		lsr.w	#7,d0
		lsr.w	#7,d1
		lsr.w	#7,d2
		endr
		eor.w	#$7f,d7
		add.b	d3,d0
		add.b	d4,d1
		add.b	d5,d2
		lsr.w	#3,d0					;5
		lsr.w	#2,d1					;6
		lsr.w	#3,d2					;5
		lsl.w	#6,d0
		or.w	d1,d0
		lsl.w	#5,d0
		or.w	d2,d0
		move.w	d0,2*256*128-2(a0)
		dbra	d6,.col
		dbra	d7,.shade
		rts
	endc

;---------------------------------------------------------------
;		Under/overflow for hicolour alpha
;---------------------------------------------------------------

	ifne	lutp_enable
lutp_blackwhite:
		lea	lutp_white,a0				;White buffer for fadeout
		lea	lutp_black,a1				;Black buffer for fadein
		move.l	#$ffffffff,d0
		move.w	#256*256*2/4-1,d7
.l:		move.l	d0,(a0)+
		clr.l	(a1)+
		dbra	d7,.l
		rts
	endc

;---------------------------------------------------------------
;		Generate sin/cos table
;---------------------------------------------------------------

make_sintab:
; 48byte Sine approximation
; (50 bytes with FPU register init)
; Copyleft 2004 NervE ^ Ephidrena

		lea	sincos4000,a0
		fmove.w	#0,fp2
		fsub	fp2,fp2
		fmove.w	#16383,fp0				;sin (90ø) = 1 = 32767 (top of wave)
		fmove.s	#0.003067961577128,fp3			;PI/180ø = PI/1024 (wave step)
		fdiv.x	#2,fp3					;ok this is lame, but works for now
		move.w	#(4096+1024)-1,d7			;5120 values
.loop:		fsin	fp2,fp1
		fmul	fp0,fp1
		fmove.w	fp1,(a0)+
		fadd	fp3,fp2
		dbra	d7,.loop
		rts


		section	data

;-------------- Core demosystem variables ----------------------
current_fx:	dc.l	demo_parts				;Current
sys_param:	dc.l	0					;Demo system parameter
timer_routine:	dc.l	dummy					;Timer
timer_param:	dc.l	0					;Timer parameter
vbl_routine:	dc.l	dummy					;VBL
vbl_param:	dc.l	0					;VBL parameter
main_routine:	dc.l	dummy					;Main
main_param:	dc.l	0					;Main parameter
swapscreens:	dc.l	0					;Screens
vblsync:	dc.l	0					;VBL-wait

;-------------- Video parameters -------------------------------
monitor:	dc.w	0					;0=VGA 1=RGB/TV (init.s auto detect)
vga_freq:	dc.w	def_vga_freq				;60/100 Hz
rgb_freq:	dc.w	def_rgb_freq				;50/60 Hz

;-------------- Restore flags ----------------------------------
do_restore_snd:		dc.w	0
do_restore_dsp:		dc.w	0
do_restore_mod:		dc.w	0
do_restore_mp2:		dc.w	0
do_restore_wav:		dc.w	0
do_restore_ace:		dc.w	0
do_restore_gfx:		dc.w	0
do_restore_mouse:	dc.w	0
do_restore_key:		dc.w	0
do_restore_dta:		dc.w	0
do_restore_mfp:		dc.w	0
do_restore_sup:		dc.w	0


error_adr:	dc.l	0

debugtxt:	dc.b	"debug",13,10,0
		even

text_nl:	dc.b	13,10,0
		even

exit_nostram_text_music:
		dc.b	13,10
		dc.b	"Sorry, you don't have enough free ST-RAM",13,10
		dc.b	"for the music file.",13,10,13,10
		dc.b	"Press any key to exit.",13,10,13,10,0
		even

exit_nostram_text_screen:
		dc.b	13,10
		dc.b	"Sorry, you don't have enough free ST-RAM",13,10
		dc.b	"for the video buffers.",13,10,13,10
		dc.b	"Press any key to exit.",13,10,13,10,0
		even

exit_mono_text:	dc.b	13,10
		dc.b	"Sorry, this demo does not work with",13,10
		dc.b	"monochrome monitors.",13,10,13,10
		dc.b	"Press any key to exit.",13,10,13,10,0
		even

exit_dsplocked_text:
		dc.b	13,10
		dc.b	"The DSP is already in use by anohter",13,10
		dc.b	"application.",13,10,13,10
		dc.b	"Press any key to exit.",13,10,13,10,0
		even

exit_sndlocked_text:
		dc.b	13,10
		dc.b	"The Falcon audio subsystem already in",13,10
		dc.b	"use by another application.",13,10,13,10
		dc.b	"Press any key to exit.",13,10,13,10,0
		even

	ifne	dspmodmusic
exit_nomodram_text:
		dc.b	13,10
		dc.b	"Sorry, you don't have enough free",13,10
		dc.b	"ST-RAM or TT-RAM to run this demo.",13,10,13,10
		dc.b	"Press any key to exit.",13,10,13,10,0
		even
	endc

exit_musicnotfound_text:
		dc.b	13,10
		dc.b	"Sorry, the musicfile was not found.",13,10,13,10
		dc.b	"Press any key to exit.",13,10,13,10,13,10,0
		even

exit_filenotfound_text:
		dc.b	13,10
		dc.b	"Sorry, the file was not found.",13,10,13,10
		dc.b	"Press any key to exit.",13,10,13,10,0
		even


		section	bss

sincos4000:	ds.b	10240					;sin/cos table

	ifne	lutp_enable
lutp_black:	ds.w	256*256	;black				;palette lookup for hicolour alpha
lutp:		ds.w	256*256	;real pal
lutp_white:	ds.w	256*256	;white
	endc


vblwait:	ds.w	1					;for fx in less than 1vbl
screen_adr1:	ds.l	1					;screen address 1
screen_adr:							;WORK ADDRESS!
screen_adr2:	ds.l	1					;screen address 2
screen_adr3:	ds.l	1					;screen address 3
video_width:	ds.w	1					;current X resolution
video_height:	ds.w	1					;current Y resolution
video_depth:	ds.w	1					;current number of bits/pixel on screen
save_stack:	ds.l	1					;old stackpointer
save_timer_d:	ds.l	1					;old timer-d
save_vbl:	ds.l	1					;old vbl
save_mfp:	ds.l	1					;old mfp
save_dta:	ds.l	1					;old dta address
save_video:	ds.b	32+12+2					;videl save
save_keymode:	ds.w	1					;old keyclick mode
dta:		ds.l	11					;new dta buffer
save_pal:	ds.l	256+8					;old colours (falcon+st/e)


		section	text
