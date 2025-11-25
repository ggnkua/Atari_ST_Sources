; Waits for blitter to finish
Wait_Blitter
	Move.l	d0,-(sp)
	Move.l	B_Cmd+Hardware,d0
	Btst	#0,d0
	Beq.s	Wait_Blitter
	Move.l	(sp)+,d0
	Rts


; Fills memory with a pattern
; a0 - Memory to fill
; d0 - Byte count
; d1-d2 - Fill pattern

Blitter_Fill_Pattern
	Lea	Hardware,a5
	Move.l	a0,d6
	Move.l	d6,d7
	And.l	#-8,d6
	Sub.l	d6,d7
	Move.l	d6,A1_Base(a5)
	Move.l	d7,a1_Pixel(a5)
	Move.l	#XADDPHR+PIXEL8,A1_Flags(a5)
	Swap	d0
	Move.w	#1,d0
	Swap	d0
	Movem.l	d1-d2,B_PATD(a5)
	Move.l	d0,B_Count(a5)
	Move.l	#$01800000+PATDSEL,B_Cmd(a5)
	Rts

; Copys phrase aligned data
; a0->a1 with a d0 count

Blitter_Copy_Phrase_Mode
	Bsr	Wait_Blitter
	Lea	Hardware,a5
	Move.l	a1,d6
	Move.l	a1,d7
	And.l	#-8,d6
	Move.l	a6,A1_Base(a5)
	Sub.l	d6,d7
	Move.l	d7,A1_Pixel(a5)	
	Move.l	#$00000018,A1_Flags(a5)
	Move.l	a0,d6
	Move.l	a0,d7
	And.l	#-8,d6
	Move.l	d6,A2_Base(a5)
	Sub.l	d6,d7
	Move.l	d7,A2_Pixel(a5)	
	Move.l	#$00000018,A2_Flags(a5)
	Swap	d0
	Move.w	#1,d0
	Swap	d0
	Move.l	d0,B_Count(a5)
	Move.l	#$01800001,B_Cmd(a5)
	Rts

; a0-Souce a1-Dest
; d0-Pixel height
; d1-Bits per pixel (Coded as 0/1/2/3/4/5)
; d2-Width in pixels

; This will also flip horizontaly as well as vertically !!!!
; Makesure when displaying the object, you flip it on the X axis (SET REFLECTBIT!)

Blitter_Vertical_Flip
	Bsr	Wait_Blitter
	Lea	Hardware,a5
	Move.w	d2,d3
	Lsl.w	d1,d3
	Lsr.w	#3,d3			; Width of a line in bytes !
	Move.w	d3,d4			; Save in work register
	Mulu	d0,d4			; Multiplied by pixel height
	Move.l	a1,a6
	Lea	(a1,d4),a1		; Pointer to next graphic

	Move.l	a6,A1_Base(a5)		; Set destination base
	Moveq	#0,d4
	Move.w	d1,d4
	Lsl.w	#3,d4
	Add.l	#XADDPIX+XSIGNSUB,d4		; Phrase mode add 
	Move.l	d4,A1_Flags(a5)
	Move.w	d0,d4
	Mulu	d2,d4
	Move.l	d4,A1_Pixel(a5)		; Pixel always zero for copys
		
	Move.l	a0,A2_Base(a5)		; Set source pointer
	Move.l	#0,A2_Pixel(a5)		; ZERO Copy
	Move.w	d1,d4
	Lsl.w	#3,d4
	Or.l	#XADDPIX,d4
	Move.l	d4,A2_Flags(a5)		; Phrase mode
	Mulu	d0,d2
	Swap	d2
	Move.w	#1,d2
	Swap	d2
	Move.l	d2,B_Count(a5)		; Set count
	Move.l	#$01800001,B_Cmd(a5) ; Start blitter
	Rts

; Parameters
; d0 - X into destination window
; d1 - Y into destination window
; d2 - Source sprite number
; a0 - JHD header for sprites
; a1 - JSP GFX file
; a6 - Destination address of window

Blit_To_Scoreboard_Window
	Move.l	Score_Board_Mem_Pointer(a4),a6
	Move.l	Player_Sprite_Base(a4),a0
	Move.l	Player_GFX_Base(a4),a1

Blitter_Block_Copy
	Bsr	Wait_Blitter
	Lea	Hardware,a5

	Lsl.w	#4,d2
	Add.l	Spr_Data(a0,d2),a1
	
	Move.l	a1,A2_Base(a5)
	Move.l	#0,A2_Pixel(a5)
	Move.l	#PIXEL16+XADDPHR,a2_Flags(a5)

	Move.l	a6,A1_Base(a5)
	Swap	d1
	Move.w	d0,d1
	Move.l	d1,A1_Pixel(a5)
	Move.l	#PIXEL16+XADDPHR+WID320,a1_Flags(a5)
	Move.w	Spr_Pixel_Width(a0,d2),d4
	Add.w	d0,d4
	Addq.w	#4,d4
	And.w	#$fffc,d4
	Sub.w	d0,d4
	Moveq	#1,d3
	Swap	d3
	Sub.w	d4,d3
	Move.l	d3,A1_Step(a5)	

	Move.w	Spr_Sheight(a0,d2),d3
	Swap	d3
	Move.w	Spr_Pixel_Width(a0,d2),d3
	Move.l	d3,B_Count(a5)
	Move.l	#SRCEN+UPDA1+LFU_AN+LFU_A,B_CMD(a5)
	Rts