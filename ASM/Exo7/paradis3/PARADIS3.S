; +======================================================================+
; | PARADIS3 - PARALLAX DISTORTER - STNICC 2015                          |
; +======================================================================+
; | Copyright (c) 2015 Frederic Poeydomenge <dyno@aldabase.com>          |
; +----------------------------------------------------------------------+
; | This program is free software: you can redistribute it and/or modify |
; | it under the terms of the GNU General Public License as published by |
; | the Free Software Foundation, either version 3 of the License, or    |
; | (at your option) any later version.                                  |
; |                                                                      |
; | This program is distributed in the hope that it will be useful,      |
; | but WITHOUT ANY WARRANTY; without even the implied warranty of       |
; | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the         |
; | GNU General Public License for more details.                         |
; |                                                                      |
; | You should have received a copy of the GNU General Public License    |
; | along with this program. If not, see <http://www.gnu.org/licenses/>. |
; +======================================================================+

	opt	m+,o+,d+,x+,p=68000	

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION TEXT
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	include	P_BASE.S

	SUPER
	bsr	save_all
	jmp	start_intro
	;jmp	run_demo

end_demo:
	bsr	restore_all
	USER
	PTERM

;#====================#
;# Start of the intro #
;#====================#

INTRO_BIG_DST 	= 180*230+8
INTRO_BACKG 	= 22*36*230
INTRO_TEXT_BUFF	= 24*36*230
INTRO_SNDH_BUFF	= 26*36*230

start_intro:

	; Initialize sound subsystem
	bsr	RESET_YM_REGISTERS

	; Fade palette to black
	move.l	#$777,d0
fade_palette:
	bsr	vsync
	bsr	vsync
	bsr	vsync
	lea	PALETTE.w,a0
	moveq	#15,d1
fade_color:
	move.w	d0,(a0)+
	dbra	d1,fade_color
	sub.w	#$111,d0
	bne.s	fade_palette
	bsr	clr_palette

	; Clear whole screen
	lea	screen_buf,a0
	move.l	#32*36-1,d0
ri_scr:	moveq.l	#115-1,d1
ri_wrd: clr.w	(a0)+
	dbra	d1,ri_wrd
	dbra	d0,ri_scr

	; Unpack chiptune (end of screen)
	lea	zikIntro,a0
	move.l	#screen_buf+INTRO_SNDH_BUFF,a1
	bsr	atm_decrunch

	; Init music
	move.w	#1,chiptune_started
	moveq.l	#0,d0
	move.l	#screen_buf+INTRO_SNDH_BUFF,a1
	jsr	(a1)
	
	; Define chiptune VBL
	move.l	#chip_vbl,VBL.w
	stop	#$2300
	bsr	vsync
	
	; Delay loop
	move.w	#375,intro_iteration
ri_loo:	bsr	vsync
	cmpi.b	#$01,KEYBOARD_DATA.w
	beq	start_demo
	cmpi.b	#$39,KEYBOARD_DATA.w
	beq	end_demo
	subq.w	#1,intro_iteration
	bne.s	ri_loo

;#================#
;# Runs the intro #
;#================#

run_intro:

	move.w	#-4,intro_iteration

	; Clear palette
	bsr	clr_palette

	; Generated-code for the overscan
	lea	genc_table_intro,a0
	bsr	INIT_GENERATED_CODE

	; Disable sample replay code
	lea	genc_generated,a0
	lea	genc_generated_end,a1
	bsr	GENC_DISABLE_SAMPLE
	lea	sync_L54,a0
	lea	sync_F160,a1
	bsr	GENC_DISABLE_SAMPLE

	; Initialize sound
	bsr	INIT_SOUND
	; Initialize background
	bsr 	INIT_BACKGROUND
	; Initialize text curve
	bsr 	INIT_TEXT_CURVE

	; Initialize text buffer
	move.w	textIntroSize,d0
	move.l	textIntroWidthX2,d1
	lea	textIntro,a0
	move.l	#screen_buf+INTRO_TEXT_BUFF,a1
	bsr	INIT_TEXT_BUFFER

	; Set screen address
	move.l	#screen_buf,sync_logical
	bsr	SET_PHYSICAL
	bsr	SET_HARDSCROLL

	bsr.s	scroll_intro

	bsr	vsync
	move.l	#full_vbl,VBL.w		; Fullscreen-VBL-Routine

intro_loop:

	stop	#$2300
	bsr	vsync

	; Play chiptune
	move.l	#screen_buf+INTRO_SNDH_BUFF,a1
	jsr	8(a1)

	bsr.s	scroll_intro

	cmpi.b	#$01,KEYBOARD_DATA.w
	beq.s	start_demo
	cmpi.b	#$39,KEYBOARD_DATA.w
	beq	end_demo

	move.l	textIntroWidthRawX16,d0
	cmp.w	intro_iteration,d0
	bgt.s	intro_loop

	jmp	start_demo

;#----------------#
;# Intro scroller #
;#----------------#

scroll_intro:

	; Scroll intro text
	addq.w	#4,intro_iteration
	move.w	intro_iteration,d0
	and.w	#%1111,d0
	tst.w	d0
	bne.s	not_inc
	addq.w	#2,intro_pos
not_inc:

	; Initialize dark background
	move.l	#screen_buf+INTRO_BACKG,pos_palette_color
	; Initialize big buffer
	bsr	COMPUTE_INTRO_BUFFER
	; Initialize destination addresses
	move.l	sync_logical,d0
	add.l	#INTRO_BIG_DST,d0
	move.l	d0,buffer_big_dst
 
	rts

;#==============#
;# Chiptune VBL #
;#==============#

chip_vbl:
	; Set VBL-Flag
	st vbl_flag
	; Play chiptune
	move.l	a1,-(sp)
	move.l	#screen_buf+INTRO_SNDH_BUFF,a1
	jsr	8(a1)
	move.l	(sp)+,a1
	rte

;#===================#
;# Start of the demo #
;#===================#

start_demo:

	; Set screen address
	bsr	clr_palette
	move.l	#screen_buf+8*36*230,sync_logical
	bsr	SET_PHYSICAL
	bsr	SET_HARDSCROLL

	; Delay loop with music
	move.w	#40,intro_iteration
tm_lop2:move.l	#screen_buf+8*36*230,sync_logical
	bsr	clr_palette
	stop	#$2300
	bsr	vsync
	; Play chiptune
	move.l	#screen_buf+INTRO_SNDH_BUFF,a1
	jsr	8(a1)
	cmpi.b	#$39,KEYBOARD_DATA.w
	beq	end_demo
	subq.w	#1,intro_iteration
	bne.s	tm_lop2

	; Define temporary VBL
	move.l	#tmp_vbl,VBL.w
	bsr	clr_palette
	stop	#$2300
	bsr	vsync

	; Stop music
	move.w	#0,chiptune_started
	move.l	#screen_buf+INTRO_SNDH_BUFF,a1
	jsr	4(a1)

	; Restore sound subsystem
	bsr	SOUND_OFF
	bsr 	set_mfp
	bsr	RESET_YM_REGISTERS

	; Delay loop
	move.w	#50,intro_iteration
tm_lop3:bsr	clr_palette
	bsr	vsync
	cmpi.b	#$39,KEYBOARD_DATA.w
	beq	end_demo
	subq.w	#1,intro_iteration
	bne.s	tm_lop3

;#===============#
;# Runs the demo #
;#===============#

run_demo:

	; Initialize sound subsystem
	bsr	RESET_YM_REGISTERS

	; Clear palette
	bsr	clr_palette

	; Generated-code for the overscan
	lea	genc_table_demo,a0
	bsr	INIT_GENERATED_CODE

	; Restore sample replay code
	lea	sync_L54,a0
	lea	sync_F160,a1
	bsr	GENC_ENABLE_SAMPLE

	; Fill screen with background pattern
	lea	screen_buf,a0
	move.l	#32*36-1,d0
rd_scr:	moveq.l	#28-1,d1
rd_wrd:	move.l	#$AAAA6666,(a0)+
	move.l	#$1E1E0101,(a0)+
	dbra	d1,rd_wrd
	clr.l	(a0)+
	clr.w	(a0)+
	dbra	d0,rd_scr

	; Initialize sound
	bsr	INIT_SOUND
	; Initialize background
	bsr 	INIT_BACKGROUND
	; Initialize text curve
	bsr 	INIT_TEXT_CURVE

	; Initialize text buffer
	move.w	textDemoSize,d0
	move.l	textDemoWidthX2,d1
	lea	textDemo,a0
	lea	textDemo,a1
	bsr	INIT_TEXT_BUFFER

	; Initialize first screen
	move.l	#screen_buf+01*FONT_HEIGHT*230,sync_logical
	sub.l	#8*FONT_HEIGHT*230,sync_logical
	bsr.s	scroll_down

	move.l	#full_vbl,VBL.w		; Fullscreen-VBL-Routine
	stop	#$2300

demo_loop:

	bsr	vsync

	bsr.s	scroll_down
 
	cmpi.b	#$39,KEYBOARD_DATA.w
	beq	end_demo

	bra.s	demo_loop

;#--------------------#
;# Scroll down screen #
;#--------------------#

scroll_down:

	; Compute sound
	bsr	COMPUTE_SOUND
	bsr	PLAY_SAMPLE

	; Shift screen address
	move.l	sync_logical,a0
	add.l	#8*FONT_HEIGHT*230,a0
	addq.w	#1,iteration_x3
	cmpi.w	#3,iteration_x3
	bne.s	sd_not_x3
	add.l	#1*FONT_HEIGHT*230,a0
	clr.w	iteration_x3
sd_not_x3:
	cmp.l	#screen_buf+25*FONT_HEIGHT*230,a0
	blt.s	sd_not_end
	sub.l	#24*FONT_HEIGHT*230,a0
sd_not_end:
	move.l	a0,sync_logical
	bsr	SET_PHYSICAL
	bsr	PLAY_SAMPLE

	; Compute curve
	bsr	COMPUTE_TEXT_CURVE
	bsr	PLAY_SAMPLE

	; Next iteration
	addq.w	#2,iteration_x43
	cmpi.w	#43*2,iteration_x43
	bne.s	sd_not_x43
	clr.w	iteration_x43
sd_not_x43:
	addq.w	#2,iteration_x72
	cmpi.w	#72*2,iteration_x72
	bne.s	sd_not_x72
	clr.w	iteration_x72
sd_not_x72:
	; Perform every 3 iterations
	cmpi.w	#0,iteration_x3
	bne.s	sd_sup0
	bsr	SET_TEXT_EVERY_3_VBL
sd_sup0:
	; Perform at each iteration
	bsr	SET_TEXT_EVERY_VBL
	bsr	PLAY_SAMPLE

	; Compute big text buffer (1 full scroll line, copied after screen)
	bsr	COMPUTE_BIG_BUFFER
	bsr	PLAY_SAMPLE

	; Compute small text buffer (1/3 scroll line, copied on 1st screen)
	bsr	COMPUTE_SMALL_BUFFER
	bsr	PLAY_SAMPLE

	; Bounce parallax background
	bsr	COMPUTE_BACKGROUND
	bsr	PLAY_SAMPLE

	; Set syncscroll
	bsr	SET_HARDSCROLL
	bsr	PLAY_SAMPLE

	rts
  
;#------------------------------------#
;# Initializes all hardware registers #
;#------------------------------------#

save_all:
	move.w	#$2700,sr		; Mask all interrupts
	SAVE_SYNC
	SAVE_RES
	SAVE_PALETTE
	SAVE_PHYSBASE
	SAVE_MFP
	bsr 	set_mfp
	move.w	#$2300,sr		; Enable interrupts
	MOUSE_OFF
	bsr 	vsync
	SET_SYNC #FIFTY_HZ
	bsr 	vsync
	SET_RES #LOW_RES
	rts

;#--------------------------------#
;# Restore all hardware registers #
;#--------------------------------#

restore_all:

	; Stop music
	tst.w	chiptune_started
	beq.s	chiptune_stopped
	move.l	#screen_buf+INTRO_SNDH_BUFF,a1
	jsr	4(a1)
chiptune_stopped:

	bsr	SOUND_OFF

	move.l #tmp_vbl,VBL.w

	bsr 	vsync
	RESTORE_PALETTE

	; Reset shifter, to resolve sync-errors :
	; 50Hz => 60 Hz => Old sync value
	bsr 	vsync
	SET_SYNC #FIFTY_HZ
	bsr 	vsync
	SET_SYNC #SIXTY_HZ
	bsr 	vsync
	RESTORE_SYNC

	RESTORE_RES
	RESTORE_MFP
	MOUSE_ON
	RESTORE_PHYSBASE

	rts

;#-------------------------------#
;# Set new MFP vectors/registers #
;#-------------------------------#

set_mfp:
	move.b	#1,MFP_ENABLE_A.w	; Only timer B
	move.b	#1,MFP_MASK_A.w		;
	clr.b	MFP_ENABLE_B.w		; No timer C-D
	clr.b	MFP_MASK_B.w		;
	bclr	#3,MFP_VR.w		; Automatic End Of Interrupt
	move.l	#tmp_vbl,VBL.w		; Define temporary VBL
	move.l	#timer_b,TIMER_B_HBL.w	; Define temporary Timer B
	rts

;#---------------#
;# Clear palette #
;#---------------#

clr_palette:
	clr.l	PALETTE+$00.w
	clr.l	PALETTE+$04.w
	clr.l	PALETTE+$08.w
	clr.l	PALETTE+$0C.w
	clr.l	PALETTE+$10.w
	clr.l	PALETTE+$14.w
	clr.l	PALETTE+$18.w
	clr.l	PALETTE+$1C.w
	rts

;#--------------------#
;# DISTORTER ROUTINES #
;#--------------------#

	include	P_SCRTXT.S
	include	P_CURVE.S
	include	P_BACKG.S
	include	P_SOUND.S
	include	INC\UNPACK.S

;#--------------------#
;# FULLSCREEN ROUTINE #
;#--------------------#

	include	P_GENCOD.S
	include	P_FULLSC.S
	include	P_SYNCSC.S

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION DATA
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

palette:		dc.w $0000			; dummy  (loaded with movem but not used)
			dc.w $0444,$0555,$0666,$0777 	; border (palette 9-12)
			dc.w $0237,$0125,$0013		; center (palette 13-15)

iteration_x3:		dc.w -1
iteration_x72:		dc.w -2
iteration_x43:		dc.w 40

intro_iteration:	dc.w -4
intro_pos:		dc.w -2
chiptune_started:	dc.w 0

pos_palette_color:	dc.l palette_color
palette_color:		incbin INC\PALETTE.BIN

			dc.w 0	; dummy, used for first screen
screen_bounce:		incbin INC\BOUNCESC.BIN
			dc.w 0	; dummy, used for first screen
palette_bounce:		incbin INC\BOUNCEBG.BIN

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION BSS
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

screen_buf:		ds.b 32*36*230		; 32 scroll lines * 36 lines font * 230 bytes

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 END
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@