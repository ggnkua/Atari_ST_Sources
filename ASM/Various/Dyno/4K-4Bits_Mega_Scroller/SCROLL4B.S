; +======================================================================+
; | 4K 4-BITS MEGA SCROLLER, by DYNO                  SILLY VENTURE 2K17 |
; +======================================================================+
; | Copyright (c) 2017 Frederic Poeydomenge <dyno@aldabase.com>          |
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

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION BSS
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
start_bss:

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION TEXT
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

SIZE 	= 1		; Tile weight: 0=Basic / 1=Intermediate / 2= Black Cats
SONG	= 2		; 1=Jess (412b) / 2=TAO (2258b)
FULLLINES	= 274-6		; Visible lines with 1+5 syncscroll

	INCLUDE	ASM\MACRO.S
	INCLUDE	ASM\MACROVER.S

	IFEQ	PROD-1
	opt	m+,o+,d-,x-,p=68000
	OUTPUT	.BIN
	ORG	$2000
	ELSE
	opt	m+,o+,d+,x+,p=68000
	OUTPUT	.PRG
	SUPER
	ENDC

;#==============#
;# Main program #
;#==============#

start_main:
	;-----------------
	; Initializations
	;-----------------

	; Manually clear BSS (it's not done by the loader)
	lea	start_bss(pc),a0
	move.l	#160000/4,d0
.clrmem:	clr.l	(a0)+
	dbra	d0,.clrmem

	; Disable MFP timers
	clr.l	$FFFFFA06.w		; No timer A-B (FFFA07) C-D (FFFA09)
	
	; Set new stack
	lea	STACK@,sp

	; Test if machine is a STF/STE
	TEST_STE

	; Palettes shown during the sync scroll
	lea	palette_top+20*4(pc),a0
	movem.l	tile+18(pc),d2-d5
	movem.l	d2-d5,(a0)

	; Set screen parameters
	move.b	#FIFTY_HZ,SCREEN_FREQ.w
	move.b	#LOW_RES,SCREEN_RES.w

	; Initialise screen with default pattern
	lea	SCREEN@,a2
	lea	sync_logical(pc),a0
	move.l	a2,(a0)		; Base address for sync-scroll
	lea	tile+34(pc),a1
	move.w	#FULLLINES+2*16-1,d1
.init_row:	moveq	#28-1,d0
.init_col:	move.l	(a1),(a2)+
	move.l	4(a1),(a2)+
	dbra	d0,.init_col
	addq.l	#6,a2
	dbra	d1,.init_row

	; Generate sinus LUT
	INCLUDE	ASM\SINUS.S

	; Initialize bouncing scroller
	bsr	init_scroller
	
	; Initialize background pattern
	bsr	init_background

	; Initialize SNDH music
	jsr	music(pc)

	; 4 buffers of generated code (shifts 0/4/8/12)
	bsr	generate_buffers

	; Install Fullscreen VBL routine
	move.l	#vbl,VBL.w		; Fullscreen VBL routine
	stop	#$2300
	move.w	#$2300,sr
	st	$466.w		; Marker for end of VBL routine

	;-----------
	; Main loop
	;-----------
main_loop:
	; Wait for Vsync
.vsync:	tst.w	$466.w		; Wait until VBL routine has ended
	beq.s	.vsync
	clr.w	$466.w		; Toggle marker

	; Clear whole palette
	movem.l	palette_top(pc),d0-d7
	movem.l	d0-d7,PALETTE.w

	; Shift hardscroll 4 bits
	lea	sync_logical(pc),a2
	lea	update_front(pc),a1
	clr.w	(a1)		; Front text does not need to be updated
	lea	shift4b(pc),a0	; 4bit Shift :
	subq.w	#4,(a0)		;   loop through 12/8/4/0 values
	bge.s	.noScroll		; When < 0, get back to 12
	addq.l	#8,(a2)		; Sync_logical += 8
	addq.w	#1,(a1)		; Front text needs to be updated
.noScroll:	and.w	#$000F,(a0)		; -4 ($FFFC) becomes 12 ($000C)

	; Shift STE with Horizontal scroll register
	moveq	#13,d0
	sub.w	shift4b(pc),d0
	move.b	d0,SHIFT_STE.w

	; Reset screen address ?
	move.w	empty_counter(pc),d1
	cmpi.w	#28*4,d1
	bne.s	.noReset
	move.l	(a2),a1		; current screen @
	cmpa.l	#SCREEN@+230*16,a1
	ble.s	.noReset
	sub.l	#230*16,(a2)	; Init base address for sync-scroll
.noReset:
	; Compute bounce offset
	lea	sinus(pc),a1
	move.w	pos_sine(pc),d1
	move.w	(a1,d1.w),d2
	mulu	#230,d2
	lea	sync_logical_offset(pc),a0
	move.l	d2,(a0)

	; Set hardscroll
	bsr	sync_scroll

	; Update bouncing scroller
	bsr	update_scroller

	; Play SNDH music
	jsr	music+8(pc)

	; Update background pattern
	bsr.s	update_background

	; Next sine position
	lea	pos_sine(pc),a0
	add.w	#18,(a0)
	and.w	#$3FE,(a0)		; pos sin modulo 1024
	
	; Loop
	bra	main_loop

	;-----------------------
	; Include external libs
	;-----------------------

	INCLUDE	P_BACKG.S
	INCLUDE	P_FRONT.S
	INCLUDE	ASM\SYNCSCR.S
	
;#=============#
;# VBL routine #
;#=============#

vbl:	move.l	#full_vbl,HBL.w	; HBL for the upper border
	move.w	#34,vbl_cnt		; Set line counter
	clr.b	STE_HSCROLL_NP.w	; Horizontal scroll register = 0 (STe)
	SET_SP_2100			; SR set = $21xx, keep CCR
rte:	rte

;#========================#
;# Fullscreen VBL routine #
;#========================#

full_vbl:	subq.w	#1,vbl_cnt		; [ 5] Count lines
	bne.s	rte		; [ 2] At line 34, open top border

	move.w	#$2700,sr		; [ 4] Disable interruptions
	lea	SCREEN_FREQ.w,a0	; [ 2] Video synchronization mode (0=60hz, 2=50hz)
	lea	SCREEN_RES.w,a1	; [ 2] Shifter resolution (0=Low, 2=High)
	lea	$1000.w,a4		; [ 2] Front text parameters
	move.w	#FULLLINES-1,d7	; [ 2] Set line counter
	background_init		; [ 4]
	lea	palette_top(pc),a2	; [ 2]
	moveq	#1,d1		; [ 1] Medium-res switch
	fill_nop_67			; [67]

	move.b	d0,(a0)		; [ 2] Set synchronization mode to 60 Hz
	fill_nop_19
	move.w	a0,(a0)		; [ 2] Set synchronization mode to 50 Hz
	; From here the top border is opened
	
.wait_sync:	move.b	VIDEO_COUNTER.w,d0	; Video address pointer (Low byte)
	beq.s	.wait_sync
	not.w	d0		; Negate value
	lsr.w	d0,d0		; Synchronization with the beam
	; From here the code is synchronous with the scanning beam

;#========================#
;# Synchro-line (73 nops) #
;#========================#

	; Set Horizontal scroll register without prefetch (STe)
	move.b	SHIFT_STE.w,STE_HSCROLL_NP.w	; [ 5]

	; Jump to sync-scroll + buffer
	lea	sync_exec(pc),a6	; [ 2]
	move.l	(a6)+,a5		; [ 3]
	jmp	(a5)		; [ 2]

;#======#
;# Data #
;#======#

shift4b:	dc.w	4

buffer4b:	dc.l	buffer00
	dc.l	buffer04
	dc.l	buffer08
	dc.l	buffer12

;#==============================#
;# Full-line routine (128 nops) #
;#==============================#
; Routine executed at each scanline,
; duplicated into the four buffers (shifts 0/4/8/12)

full_line:	move.w	a1,(a1)		; [ 2] Change the resolution to high-res
	move.w	a0,(a0)		; [ 2] Get back to 50 Hz
patch_ste:	move.b	d1,(a1)		; [ 2] Get back to medium-res
patch_4b:	nop			; [ 1] Hardscroll 4 bits
	or.l	d0,d0		; [ 2] Hardscroll 4 bits
	or.l	d0,d0		; [ 2] Hardscroll 4 bits
	fill_nop_8			; [84]
	front_set			;     -[65]
	background_load		;     -[11]
	move.b	d0,(a0)		; [ 2] Change the display frequency to 60Hz
	move.w	a0,(a0)		; [ 2] Get back to 50Hz
	;fill_nop_13		; [13]
	cmp.w	#61,d7		;     -[ 2] Open bottom border ? [1st]
	beq.s	.bottom1		;     -[ 3/2]
	cmp.w	#45,d7		;     -[ 2] Open bottom border ? [2nd]
	beq.s	.bottom2		;     -[ 3/2]
	bra.s	.bottom3		;     -[ 3]
.bottom1:	fill_nop_4			;     -[ 4]
.bottom2:	move.b	d0,(a0)		;     -[ 2]
.bottom3:	sub.l	d1,d7		;     -[ 2] line-- (subq.w #1 is faster, but +2b : needs another nop)
	move.w	a1,(a1)		; [ 2] Change the resolution to high-res
	nop			; [ 1]
	move.b	d0,(a1)		; [ 2] Get back to low-res
	;fill_nop_11		; [11]
	background_set		;     -[11]

;#===================================#
;# End of the fullscreen VBL routine #
;#===================================#
; Copied at the end of the four buffers (shifts 0/4/8/12)

full_end:	addq.w	#1,$466.w		; Denotes the end of VBL routine
	SET_SP_2300			; SR set
	rte
full_stop:

;#========================================================#
;# Generate 4 buffers of generated code (shifts 0/4/8/12) #
;#========================================================#

generate_buffers:

	lea	buffer4b(pc),a6
	moveq	#0,d0
	bsr.s	generate_buffer
	moveq	#4,d0
	bsr.s	generate_buffer
	moveq	#8,d0
	bsr.s	generate_buffer
	moveq	#12,d0

;#==========================#
;# Generate a single buffer #
;#==========================#

generate_buffer:

	; Get address of the next buffer
	move.l	(a6)+,a0

	;--------------------------------------------
	; Patch full-line routine with 4-bits shifts
	;--------------------------------------------

	lea	is_ste(pc),a1
	tst.w	(a1)
	beq.s	.is_stf

	; If STE
.is_ste:	lea	patch_ste(pc),a1
	move.w	#$1280,(a1)		; = move.b d0,(a1) ; get back to low-res
	bra.s	.end_patch

	; If STF
.is_stf:	move.w	#$4E71,d1		; nop
	move.w	#$8080,d2		; or.l d0,d0
	move.w	#$1280,d3		; move.b d0,(a1)

	lea	patch_4b(pc),a1

	tst.w	d0
	bne.s	.n0
	move.w	d2,(a1)+
	move.w	d1,(a1)+
	move.w	d3,(a1)+
.n0:	subq.w	#4,d0
	bne.s	.n4
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	move.w	d1,(a1)+
.n4:	subq.w	#4,d0
	bne.s	.n8
	move.w	d1,(a1)+
	move.w	d3,(a1)+
	move.w	d2,(a1)+
.n8:	subq.w	#4,d0
	bne.s	.n12
	move.w	d3,(a1)+
	move.w	d2,(a1)+
	move.w	d1,(a1)+
.n12:
	; End of patch
.end_patch:
	;-----------------------------
	; Duplicate full-line routine
	;-----------------------------

	move.w	#FULLLINES-1,d0
.copybuf:	lea	full_line(pc),a2
	lea	full_end(pc),a3
.copyword:	move.w	(a2)+,(a0)+
	cmpa.l	a2,a3
	bne.s	.copyword
	dbra	d0,.copybuf

	;-----------------------------
	; Copy end of the VBL routine
	;-----------------------------

	lea	full_stop(pc),a4
.copyend:	move.w	(a3)+,(a0)+
	cmpa.l	a3,a4
	bne.s	.copyend
	
	rts

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION DATA
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	IFEQ SONG-1
music:	incbin INC\JESS.SND		; Jess / Overlanders :: The_Music_Bootsector.sndh
	ENDC

	IFEQ SONG-2
music:	incbin INC\TAO.SND		; Tao / Cream :: Madness_Loader.sndh
	ENDC

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION BSS
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

vbl_cnt:		ds.w 1

palette_top:	ds.b 6*8*2		; 6 lines x 8 colors x 2 bytes

buffer00:		ds.b 28500
buffer04:		ds.b 28500
buffer08:		ds.b 28500
buffer12:		ds.b 28500

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION TEXT
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
end_main:
