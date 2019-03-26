***************************************************************
*  ST Format Assembler Column                                 *
*                                                             *
*  Palette Transformation Routines (stf0002a.s)               *
*                                                             *
*  'Transform_Palette'                                        *
*  SUPERVISOR execution only.                                 *
*  This routine requires the following register settings on   *
*  entry:-                                                    *
*                                                             *
*  A0	= Pointer to Final Palette                            *
*  D0.w = Screen Cycle Duration of Transformation             *
*                                                             *
*  The following important variables (storage) are used.      *
*  If needed, these can be dynamically set before calling     *
*  the routine.                                               *
*                                                             *
*  'frame_palette' - Working palette (cycle by cycle)         *
*                                                             *
*  'frame_regs'    - Data structure of working registers      *
*                                                             * 
*  'awesome_4096'  - Set this word to '1' to take advantage   *
*                    of 4096 colour hardware (STe)            *
*                                                             * 
*  This routine gradually transforms a colour palette from    *
*  the current to the palette pointed to be 'A0'. The dura-   *
*  tion of the change is governed by a screen cycle count     *
*  held in D0. The maximum period is 32768 cycles (10.9 mins).*
*                                                             *
*                                                             *
*                                                             *
*  Assume all registers are trashed on exit.                  *
*                                                             *
***************************************************************

SCALE		EQU	10	: <--- Whole Maths Bit Shift

Transform_Palette

		BSR 	Transform_Palette_Init  ; Initialise 

		move.w	frame_cycle,-(sp)	; Frames to do	
		BRA		.next_frame
.loop			movem.w	d0,-(sp)

		BSR		Transform_Colours	; Change each attribute

* Wait till Next VBlank Interupt...

		move.w	#37,-(sp)
		TRAP	#14
		LEA		2(sp),sp

.next_frame	movem.w	(sp)+,d0
		DBRA	d0,.loop

* Set to target palette...

		move.l	frame_final,-(sp)
		move.w	#6,-(sp)
		TRAP	#14
		LEA		6(sp),sp

		RTS
		
***************************************************************
Transform_Colours

; Process each colour in turn 
; (building the next 'frame_palette')

		LEA		frame_regs,a0		; Working vals
		LEA		frame_palette,a1	; Working palette
		move.l	#SCALE,d3

		moveq.l	#15,d0
.loop	movem.w	d0,-(sp)
	
; Increment work registers...

		move.l	(a0),d0			; Scaled Red Value
		add.l	4(a0),d0		; Increment
		move.l	d0,(a0)			; Store
	
		move.l	8(a0),d1		; Scaled Green Value
		add.l	12(a0),d1		; Increment
		move.l	d1,8(a0)		; Store
	
		move.l	16(a0),d2		; Scaled Blue Value
		add.l	20(a0),d2		; Increment
		move.l	d2,16(a0)		; Store
		
; Take each of the scaled up red, green and blue values 
; (d0,d1 and d2) and Scale them down ready for mixing together to make
; a palette entry for relevant colour in this frame...

		asr.l	d3,d0			; Scale Down Red
		asr.l	d3,d1			; Scale Down Green
		asr.l	d3,d2			; Scale Down Blue

; Do we need to fix the 4096 colour 4th bit quirk?

		tst.w	awesome_4096		; STe 4th bit correction?
		BEQ		.ST_512			; Only 512 (ST) cols
	
		move.w	d0,nibble_data
		BSR		role_nibble_right	; Correct 4th Bit
		move.w	nibble_data,d0

		move.w	d1,nibble_data
		BSR		role_nibble_right	; Correct 4th Bit
		move.w	nibble_data,d1

		move.w	d2,nibble_data
		BSR		role_nibble_right	; Correct 4th Bit
		move.w	nibble_data,d2

.ST_512				

; Mix the Red, Green and Blue elements together...

		lsl.w	#8,d0			; Move to Red nibble
		lsl.w	#4,d1			; Move to Green nibble
		or.w	d0,d2			; Mix red with blue
		or.w	d1,d2			; mix green with red and blue

; Store frame/colour palette entry (D2) in 'frame_palette'...

		move.w	d2,(a1)+
	
.next_colour	
		LEA		24(a0),a0		; next regs
		movem.w	(sp)+,d0
		DBRA	d0,.loop

; All done, so set next frame_palette...

		PEA		frame_palette
		move.w	#6,-(sp)
		TRAP	#14
		LEA		6(sp),sp

		RTS

***************************************************************

Transform_Palette_Init

		move.w	d0,frame_cycle		; Store cycle duration

		move.l	A0,frame_final		; Final Palette Values

; Taking each of the current palette attribute values in turn.
; Calculate the whole mathematic start in increment values for
; the red, green and blue elements of each palette entry.

		LEA		$FFF8240,a0		; Hardware Palette.
		LEA		frame_regs,a1		; Working registers
		move.l	frame_final,a2		; Ultimate Palette Vals
		moveq.l	#SCALE,d1		; Whole maths scaler 

		move.w	#15,d0			; 16 palette entries
.loop	movem.w	d0,-(sp)

; Get current palette entry...

		move.w	(A0)+,d2		; D2 = Start RGB mix

; Get final palette entry...

		move.w	(A2)+,d3		; D3 = Final RGB mix

; If this is running on an ST colour (512 colours), we must
; make sure only active bits are used to calculate increments

		tst.w	awesome_4096
		BNE.s	.STe
		andi.l	#$777,d2
		andi.l	#$777,d3
.STe

; ***  R E D   M I X  ***

; Strip out current red...

		move.w	d2,d4
		andi.l	#$0F00,d4		; Place red value in d4
		lsr.w	#8,d4			; low order nibble.

		tst.w	awesome_4096		; STe 4th bit correction?
		BEQ		.red_1			; Only 512 (ST) cols
		move.w	d4,nibble_data
		BSR		role_nibble_left	; Correct 4th Bit
		move.w	nibble_data,d4
.red_1	
		asl.l	d1,d4			; Scale up value!
		move.l	d4,0(a1)		; Scaled up red start
	
; Strip out final red...

		move.w	d3,d5
		andi.l	#$0F00,d5
		lsr.w	#8,d5

		tst.w	awesome_4096		; STe 4th bit correction?
		BEQ		.red_2				; Only 512 (ST) cols
		move.w	d5,nibble_data
		BSR		role_nibble_left	; Correct 4th Bit
		move.w	nibble_data,d5
.red_2	
		asl.l	d1,d5		; Scaled up value!

; Increment = (d5 - d4) / frame_cycles

		sub.l	d4,d5
		movem.w	frame_cycle,d4
		DIVS	d4,d5			
		ext.l	D5				; Loose remainder
		move.l	d5,4(a1)		; Store scaled up
								;  red increment




; ***  G R E E N   M I X  ***

; Strip out current green...

		move.w	d2,d4
		andi.l	#$00F0,d4		; Place green value in 
		lsr.w	#4,d4			; low order nibble.

		tst.w	awesome_4096		; STe 4th bit correction?
		BEQ	.green_1		; Only 512 (ST) cols
		move.w	d4,nibble_data
		BSR	role_nibble_left	; Correct 4th Bit
		move.w	nibble_data,d4
.green_1	
		asl.l	d1,d4			; Scale up value!
		move.l	d4,8(a1)		; Scaled up green start
	
; Strip out final green...

		move.w	d3,d5
		andi.l	#$00F0,d5
		lsr.w	#4,d5

		tst.w	awesome_4096		; STe 4th bit correction?
		BEQ		.green_2			; Only 512 (ST) cols
		move.w	d5,nibble_data
		BSR		role_nibble_left	; Correct 4th Bit
		move.w	nibble_data,d5
.green_2	
		asl.l	d1,d5			; Scaled up value!

; Green increment = (d5 - d4) / frame_cycles

		sub.l	d4,d5
		movem.w	frame_cycle,d4
		DIVS	d4,d5			
		ext.l	D5			; Loose remainder
		move.l	d5,12(a1)	; Store scaled up
							;  green increment



; *** B L U E   M I X  ***

; Strip out current blue...

		move.w	d2,d4
		andi.l	#$000F,d4		; blue value already in 
								; low order nibble.
	
		tst.w	awesome_4096	; STe 4th bit correction?
		BEQ		.blue_1				; Only 512 (ST) cols
		move.w	d4,nibble_data
		BSR		role_nibble_left	; Correct 4th Bit
		move.w	nibble_data,d4
.blue_1	
		asl.l	d1,d4			; Scale up value!
		move.l	d4,16(a1)		; Scaled up blue start
	
; Strip out final blue...

		move.w	d3,d5
		andi.l	#$000F,d5

		tst.w	awesome_4096		; STe 4th bit correction?
		BEQ		.blue_2			; Only 512 (ST) cols
		move.w	d5,nibble_data
		BSR		role_nibble_left	; Correct 4th Bit
		move.w	nibble_data,d5
.blue_2	
		asl.l	d1,d5			; Scaled up value!

; Green increment = (d5 - d4) / frame_cycles

		sub.l	d4,d5
		movem.w	frame_cycle,d4
		DIVS	d4,d5			
		ext.l	D5			; Loose remainder
		move.l	d5,20(a1)		; Store scaled up
					;  blue increment

; Increase the frame_regs pointer to the next set up registers...

		LEA		24(a1),a1

		move.w	(sp)+,d0
		DBRA	d0,.loop

		RTS	 

***************************************************************
* There is no simple 68000 command to role a nibble left, so we
* need a routine to do it...

role_nibble_left
	move.w	d0,-(sp)	* Preserve Register!	
	move.w	nibble_data,d0
	BTST	#3,d0
	BEQ	.fourth_is_off

.fourth_is_on
	lsl.w	#1,d0
	andi.w	#$F,d0
	BSET	#0,d0
	move.w	d0,nibble_data
	move.w	(sp)+,d0		; Restore register
	RTS

.fourth_is_off
	lsl.w	#1,d0
	andi.w	#$F,d0
	move.w	d0,nibble_data
	move.w	(sp)+,d0		; Restore Register
	RTS

***************************************************************
* There is no simple 68000 command to role a nibble right, so we
* need a routine to do it...

role_nibble_right
	move.w	d0,-(sp)	; Reserve Register!	
	move.w	nibble_data,d0
	BTST	#0,d0
	BEQ	.first_is_off

.first_is_on
	lsr.w	#1,d0
	andi.w	#$F,d0
	BSET	#3,d0
	move.w	d0,nibble_data
	move.w	(sp)+,d0	; Restore register	
	RTS

.first_is_off
	lsr.w	#1,d0
	andi.w	#$F,d0
	move.w	d0,nibble_data
	move.w	(sp)+,d0	; Restore register	
	RTS


***************************************************************
* VARIABLE STORAGE                                            *
***************************************************************

nibble_data		dc.w	0	

awesome_4096	dc.w	1	; 0 = ST
							; 1 = STe
frame_final		dc.l	0		; Ptr target Palette

frame_cycle		dc.w	0		; VBL's to do

frame_regs			; Whole Maths Colour Mix
		rept	16	; Registers... 
		dc.l	0,0	; (0) red,  (4) red increment
		dc.l	0,0	; (8) green, (12) green increment
		dc.l	0,0	; (16) blue, (20) blue increment
		endr		; ...<24> byte blocks

frame_palette	ds.w	16







