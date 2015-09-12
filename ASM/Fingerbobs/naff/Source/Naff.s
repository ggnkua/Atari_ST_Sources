;-------------------------------------------------------------------------------
; Naff Demo
; By Oberje'
; Original Release: December 1990
;
; Depacked, Easy Rider-ed, Analysed & Commented by Oberje' 2009
; (Well, it's not like I have the original source anymore...)
;
; NOTE: View this file with Tabs set to 4.
;
; 20090217	Modifed Enter/Exit code to fix return to Desktop
;
;			Changed 16x16 sprite preshifter, the original was weird
;			and not a little wasteful of memory
;
;			Tuned down some overly generous memory areas
;
;-------------------------------------------------------------------------------
; Approx CPU Utilisation:
;
;					cycles	CPU
; Sprite Clear		4476	(2.8%)
; Sprite Draw		16600	(10.4%)
; Scroll Update		9600	(6%)
; Scroll Draw		36000	(22.5%)
; Tile Draw			64768	(40.4%)
;	Total			131444	(82%)
;
; NOTE. This is only the big ticket items, all the other faffing about accounts
; for most/much of the remaining 18% (28k cycles)
;-------------------------------------------------------------------------------

SysVsync	macro
	move.l    d0,-(a7)
	move      sr,-(a7)
	andi.w    #~$700,sr 
	move.l    $466.w,d0 
WaitVBL\@:
	cmp.l     $466.w,d0 
	beq       WaitVBL\@
	move      (a7)+,sr
	move.l    (a7)+,d0
	endm

	opt	O+
	opt	OW-

BigScrollBufferWidth	equ	40		; In Bytes
BigScrollBufferHeight	equ	16		; In Lines

BigFontExpandedWidth	equ	32		; In Bytes
BigFontFirstChar		equ	$20		; Space
BigFontNumChars			equ	60		; Num chars in set

	TEXT 
	
Begin:
	dc.w	$a00a					; Hide Mouse Cursor
	
	jsr     ExpandFont 
	jsr     PreshiftTile 

	jsr     SysStart 

	jsr     PreshiftSprites32 
	jsr     PreshiftSprites16 
	jsr     PreprocessSpriteSines 
	jsr     ClearScreenData 
	jsr     InitRasterBars 
	jsr     Flip 
	jsr     ScrollTextInit 
	jsr		MusicInit

	move.b  #$12,$fffffc02.w		; Mouse Off

	jsr		SaveVectors

	jsr		MainLoop 

	jsr		RestoreVectors 

	move.b	#8,$fffffc02.w			; Mouse On (Relative mode)

	jsr		SysStop 

	clr.w   -(a7) 	;pterm0
	trap    #1
	  


KeyHandler:
	move.b	$fffffc02.w,LastKey		; KYBD Data
	bclr	#6,$fffffa11.w			; Clear IISB
	rte 
	  


MyVBL:
	movem.l	a0-a6/d0-d7,-(a7) 

	move.b	#0,$fffffa1b.w		; TimerB Off
	move.b	#24,$fffffa21.w		; TimerB Data - First Raster on line 24
	move.b	#8,$fffffa1b.w		; TimerB On (Event Mode)

	move.l	#MyHBL,$120.w		; Restore HBL 

	; Flip
	move.l	ScreenPtrA,d0
	move.l	ScreenPtrB,ScreenPtrA 
	move.l	d0,ScreenPtrB
	move.l	ScreenPtrB,d0
	asr.w	#8,d0 
	move.b	d0,$ffff8203.w
	swap	d0
	move.b	d0,$ffff8201.w

	clr.b	SyncVBL 

	; Configure the 4 Raster Bars for this frame
	lea		RasterBarPositions,A0
	moveq	#2,d0				; Animate bar positions ( 8 Bit )
	add.b	d0,(a0)+	
	add.b	d0,(a0)+
	add.b	d0,(a0)+
	add.b	d0,(a0)+
	lea		-4(a0),a0			; "Draw" Bars into raster area
	lea		RasterSineTable,a1
	lea		RasterBarCols,a3
	rept 4
		move.b	(a0)+,d0
		move.b	(a1,d0.w),d0	; Sined Pos ( 0-$7d )
		asr.w	#1,d0 
		add.w	d0,d0			; Index for .W
		lea		Rasters,a2
		adda.l	d0,a2			; Store bar
		move.l	(a3)+,(a2)+ 
		move.l	(a3)+,(a2)+ 
		move.l	(a3)+,(a2)+ 
		move.l	(a3)+,(a2)+ 
		move.l	(a3)+,(a2)+ 
		move.l	(a3)+,(a2)+ 
	endr
	
	; Music Playback
	; Note: Music is a recording of the YM registers. This method is
	;       bulky but ridiculously fast
	;		(14 bytes per frame)
	movea.w	#$8800,a1			; YM Reg Select
	movea.w	#$8802,a2			; YM Data
	movea.l	MusicPos,a0

	move.b	#0,(a1)
	move.b	(a0)+,(a2)
	move.b	#2,(a1) 
	move.b	(a0)+,(a2)
	move.b	#4,(a1) 
	move.b	(a0)+,(a2)
	move.b	#6,(a1) 
	move.b	(a0)+,(a2)
	move.b	#7,(a1) 
	move.b  (a0)+,(a2)
	move.b  #1,(a1) 
	move.b  (a0)+,(a2)
	move.b  #3,(a1) 
	move.b  (a0)+,(a2)
	move.b  #5,(a1) 
	move.b  (a0)+,(a2)
	move.b  #8,(a1) 
	move.b  (a0)+,(a2)
	move.b  #9,(a1) 
	move.b  (a0)+,(a2)
	move.b  #$a,(a1)
	move.b  (a0)+,(a2)
	move.b  #$b,(a1)
	move.b  (a0)+,(a2)
	move.b  #$c,(a1)
	move.b  (a0)+,(a2)
	move.b  #$d,(a1)
	move.b  (a0)+,(a2)

	cmpa.l	#MusicDataEnd,a0 
	blt		.noWrap
	lea		MusicData,a0
.noWrap:
	move.l	a0,MusicPos
	
	movem.l	(a7)+,a0-a6/d0-d7 
	rte 



MyHBL:
	move.b	#0,$fffffa1b.w
	move.b  #2,$fffffa21.w		; 2 HBL per raster
	move.b  #8,$fffffa1b.w
	move.l  #MyHBL_2,$120.w 
	move.w  #$49,RasterCount
	move.l  #RastersVisible,RasterPtr
	bclr    #0,$fffffa0f.w		; Clear IISA
	rte
	
MyHBL_2:
	move.l	a0,-(a7)
	movea.l	RasterPtr,a0
	move.w	(a0),$ffff824a.w	; colour05
	move.w	(a0),$ffff824c.w	; colour06
	move.w  (a0)+,$ffff824e.w	; colour07
	move.l  a0,RasterPtr
	movea.l (a7)+,a0
	subq.w  #1,RasterCount
	beq     .done 
	bclr    #0,$fffffa0f.w
	rte 
.done:
	move.b	#0,$fffffa1b.w		; TimerB Off
	bclr	#0,$fffffa0f.w
	rte 



; Ok, I have no idea why we're doing this
; (Work it out later..)
PreprocessSpriteSines:
	lea       SpriteSines_1,a0
	lea       SpriteSines_3,a1
	move.w    #512-1,d0			; Copy table for 16x16 sprites
.copy:
		move.w    (a0)+,(a1)+ 
	dbf       d0,.copy
	
	lea       SpriteSines_2,a0	; ? Adjust 32x32 sprite table
	move.w    #256-1,d0 
.addone:
		addq.w    #1,(a0)+
	dbf       d0,.addone
	
	lea       SpriteSines_3,a0	; Adjust sines for 16x16 sprite (Table is for 32x32)
	move.w    #512-1,d0
.addeight:
		addq.w    #8,(a0)+
	dbf       d0,.addeight
	rts 



ClearScreenData:
	; Init Sprite Rubout Data
	lea		SpriteTraces_1,a0
	move.l	ScreenPtrB,d0
	move.w	#((4*5)/2)-1,d1 
.traceloop:
	move.l	d0,(a0)+
	dbf		d1,.traceloop

	move.l	#SpriteTraces_1,SpriteTracePtrA
	move.l	#SpriteTraces_2,SpriteTracePtrB

	; Clear Screens
	lea		ScreenMem,a0
	move.w	#((ScreenMem_End-ScreenMem)/4)-1,d7
.scrloop:
	clr.l	(a0)+ 
	dbf		d7,.scrloop

	rts 



SysStart:
	clr.l	-(a7) 
	move.w	#$20,-(a7) 	;super
	trap	#1
	addq.l	#6,a7 
	move.l	d0,SaveSP	
	  
	move.w	#4,-(a7)
	trap	#14
	addq.l	#2,a7
	move.w	d0,SaveRes
	
	move.w	#2,-(a7)
	trap	#14
	addq.l	#2,a7
	move.l	d0,SaveScreen
	
	move.w	#0,-(a7)
	pea		-1
	pea		-1
	move.w	#5,-(a7)
	trap	#14
	lea		12(a7),a7
	  
	move.l	#ScreenMem,d0 
	addi.l	#$100-1,d0
	andi.w	#-$100,d0 
	move.l	d0,ScreenPtrA
	add.l	#32000,d0
	move.l	d0,ScreenPtrB

	SysVsync

	move.l	ScreenPtrA,d0		; Set Screen
	asr.w	#8,d0 
	move.b	d0,$ffff8203.w
	swap	d0
	move.b	d0,$ffff8201.w

	movem.l	$ffff8240.w,d0-d7 
	movem.l	d0-d7,SavePalette 
	movem.l	MainPalette,d0-d7 
	movem.l	d0-d7,$ffff8240.w 

	rts 



SysStop:
	SysVsync

	movem.l	SavePalette,d0-d7 
	movem.l	d0-d7,$ffff8240.w 

	move.w	SaveRes,-(a7)
	move.l	SaveScreen,-(a7)
	move.l	(a7),-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea		12(a7),a7

	SysVsync
	  
	move.l	SaveSP,-(a7) 
	move.w	#$20,-(a7) 	;super
	trap	#1
	addq.l	#6,a7 
	rts 



MusicInit:
	move.l	#MusicData,MusicPos	
	rts



SaveVectors:
	move	sr,-(a7)
	ori.w	#$700,sr			; Disable IRQ

	lea		SaveMFP,a0

	move.b	$fffffa09.w,(a0)+	; Save IENB
	move.b	$fffffa07.w,(a0)+	; Save IENA
	move.b	$fffffa13.w,(a0)+	; Save IMA
	adda.l	#1,a0 

	move.l	$118.w,(a0)+		; Save KYBD Vector
	move.l	$120.w,(a0)+		; Save TimerB(HBL) Vector
	move.l	$70.w,(a0)+			; Save VBL Vector

	andi.b	#$fe,$fffffa07.w	; IENA: Disable HBL
	andi.b	#$df,$fffffa09.w	; IENB: Disable TimerC

	move.l	#MyHBL,$120.w		; Install HBL

	ori.b	#1,$fffffa07.w		; IENA: Enable HBL
	ori.b	#1,$fffffa13.w		; IMA: Unmask HBL

	move.l	#KeyHandler,$118.w	; Install Key Handler

	move.l	#MyVBL,$70.w		; Install VBL

	move	(a7)+,sr
	rts 
	  


RestoreVectors:
	move	sr,-(a7)
	ori.w	#$700,sr			; Disable IRQ

	lea		SaveMFP,a0

	move.b	(a0)+,$fffffa09.w	; Restore IENB
	move.b	(a0)+,$fffffa07.w	; Restore IENA
	move.b	(a0)+,$fffffa13.w	; Restore IMA
	adda.l	#1,a0 

	move.l	(a0)+,$118.w		; Restore KYBD Vector
	move.l	(a0)+,$120.w		; Restore TimerB(HBL) Vector
	move.l	(a0)+,$70.w			; Restore VBL Vector

	move.b	#7,$ffff8800.w		; Select YM Register: Mixer Control
	move.b	#$ff,$ffff8802.w	; Everything Off

	move	(a7)+,sr
	rts 



Flip:
	move.l	ScreenPtrB,d0
	asr.w	#8,d0 
	move.b	d0,$ffff8203.w
	swap	d0
	move.b	d0,$ffff8201.w

	move.l	ScreenPtrA,d0
	move.l	ScreenPtrB,ScreenPtrA 
	move.l	d0,ScreenPtrB

	move.l	SpriteTracePtrA,d0
	move.l	SpriteTracePtrB,SpriteTracePtrA 
	move.l	d0,SpriteTracePtrB

	rts 



; Expand the Scroller font
; Source font is 16x16 Single Plane
; Expanded font is 256x16 Single Plane (1 word per input pixel)
ExpandFont:
	lea		BigFontData,a0
	lea		BigFontExpanded,a1
	move.w	#(BigFontNumChars*16)-1,d6
.lineloop:
		move.w	(a0)+,d0			; Get Source Line
		move.w	#16-1,d7			; 16 pixels
.pixloop:
			rol.w	#1,d0			
			bcc		.clear 
			move.w	#-1,(a1)+		; Bit is set
.nextpix:
		dbf		d7,.pixloop
	dbf		d6,.lineloop
	rts 
.clear:
			move.w	#0,(a1)+		; Bit is clear
			bra		.nextpix 



; Preshifting the 32x32 Tile.
; Tile is 2x original Height. (512 Bytes per preshift)
PreshiftTile:
	lea		TileData,a0
	lea		PreshiftTile_0,a1
	move.w	#32-1,d0 
.copy:
		move.l	(a0),(a1) 
		move.l	(a0),256(a1) 
		move.l	4(a0),4(a1) 
		move.l	4(a0),256+4(a1)
		adda.l	#8,a0 
		adda.l	#8,a1 
	dbf		d0,.copy

	lea		PreshiftTile_0,a0
	lea		PreshiftTile_1,a1
	move.w	#32-2,d7			; 32 Preshifts (Tile is 32x32)
.shiftloop:
		move.w	#512-1,d0		; Copy previous preshift
.copy0:	move.b	(a0)+,(a1)+ 
		dbf		d0,.copy0
		move.l	a0,a1
		
		move.w	#64-1,d3		; 64 Lines 
.shiftline:
			move.l	(a1),d0		; d0=Word0 (P0+1)
			move.l	4(a1),d1	; d1=Word1 (P0+1)
			move.l	d1,d2		; d2=Word1 (P0+1)

			roxr.w	#1,d2		; Shift Plane 1
			roxr.w	#1,d0 
			roxr.w	#1,d1		; Word1 > Word0 > Word1 (d2/d0/d1)
			
			swap	d0			; Get Plane 0
			swap	d1
			
			move.l	d1,d2 
			roxr.w	#1,d2		; Shift Plane 0
			roxr.w	#1,d0 
			roxr.w	#1,d1		; Word1 > Word0 > Word1 (d2/d0/d1)

			swap	d0			; Restore plane order
			swap	d1
			
			move.l	d0,(a1)		; Store rotated Line
			move.l	d1,4(a1)
			
			adda.l	#8,a1 
		dbf		d3,.shiftline
	dbf		d7,.shiftloop

	move.l	#TileWaveData,TileWavePtr
	move.l	#FadePalette,FadePalettePtr

	rts 



; Setting up the 2 32x32 "IC" Sprites
PreshiftSprites32:
	lea		Sprite32_I,a0
	lea		Preshift32_I,a1
	bsr		PreshiftOneSprite32 
	
	lea		Sprite32_C,a0
	lea		Preshift32_C,a1
	bsr		PreshiftOneSprite32 
	rts 

PreshiftScratchClear32:
	lea		ScratchArea,a3
	move.w	#24*32,d0
.loop:
	clr.w	(a3)+ 
	dbf		d0,.loop
	rts 

PreshiftOneSprite32:
	bsr		PreshiftScratchClear32
	
	lea		ScratchArea,a3		; Copy source to scratch	
	move.w	#32-1,d0			; 01 01 -> 01 01 __ mm mm mm
.copy:
		move.l	(a0)+,(a3)	
		move.l	(a0)+,4(a3) 
		move.l	#0,8(a3)
		adda.l	#24,a3 
	dbf		d0,.copy
	
	lea       ScratchArea,a3	; Preshifting
	move.w    #16-1,d7			; 16 Shifts
.shiftloop:
		move.w    #32-1,d6			; 32 Lines 
.maskloop:
			move.w    (a3),d0		; Make mask & Copy Mask+Data to output
			or.w      2(a3),d0		
			not.w     d0			
			move.w    d0,(a1)+		
			move.w    d0,(a1)+		; mm
			move.w    4(a3),d0
			or.w      6(a3),d0
			not.w     d0
			move.w    d0,(a1)+
			move.w    d0,(a1)+		; mm mm
			move.w    8(a3),d0
			or.w      $a(a3),d0 
			not.w     d0
			move.w    d0,(a1)+
			move.w    d0,(a1)+		; mm mm mm
			move.l    (a3),(a1)+
			move.l    4(a3),(a1)+ 
			move.l    8(a3),(a1)+	; mm mm mm 01 01 01
			adda.l    #24,a3 
		dbf       d6,.maskloop

		lea       ScratchArea,a3	; 32 Lines
		move.w    #32-1,d6			
.shiftline:
			roxr      0(a3)			; Plane 0 Shift right 1 px
			roxr      4(a3)			
			roxr      8(a3) 
			
			roxr      2(a3)			; Plane 1 Shift right 1 px
			roxr      6(a3) 
			roxr      $a(a3)
			
			adda.l    #24,a3 
		dbf       d6,.shiftline
		
		lea       ScratchArea,a3	; Reset ptr
	dbf       d7,.shiftloop

	rts 



; Setting up the 3 16x16 "TFB" Sprites
PreshiftSprites16:
	lea		Preshift16_T,a1
	lea		Sprite16_T,a0
	bsr		PreshiftOneSprite16 

	lea		Preshift16_F,a1
	lea		Sprite16_F,a0
	bsr		PreshiftOneSprite16 

	lea		Preshift16_B,a1
	lea		Sprite16_B,a0
	bsr		PreshiftOneSprite16 

	rts 

PreshiftScratchClear16:
	lea		ScratchArea,a3
	move.w	#8*16,d0
.loop:
	clr.w	(a3)+ 
	dbf		d0,.loop
	rts 

; Preshift a 16x16 sprite
PreshiftOneSprite16:
	bsr		PreshiftScratchClear16

	lea		ScratchArea,a3	; Copy source to scratch
	move.w	#16-1,d0		; 01 __ -> 01 __ xx xx
.copy:
		move.w	(a0)+,(a3)		
		move.w	(a0)+,2(a3) 
		adda.l	#8,a3 
	dbf		d0,.copy

	lea		ScratchArea,a3		; Preshifting
	move.w	#16-1,d7			; 16 Preshifts
.shiftloop:
		move.w	#16-1,d6		; 16 lines
.maskloop:
			move.w	(a3),d0			; Make mask & Copy Mask+Data to output
			or.w	2(a3),d0
			not.w	d0
			move.w	d0,(a1)+
			move.w	d0,(a1)+		; mm
			move.w	4(a3),d0
			or.w	6(a3),d0 
			not.w	d0
			move.w	d0,(a1)+
			move.w	d0,(a1)+		; mm mm
			move.w	(a3),(a1)+
			move.w	2(a3),(a1)+ 
			move.w	4(a3),(a1)+ 
			move.w	6(a3),(a1)+		; mm mm 01 01
			adda.l	#8,a3 
		dbf		d6,.maskloop
		
		lea		ScratchArea,a3
		move.w	#16-1,d6
.shiftline:
			roxr      0(a3)			; Plane 0 Shift right 1 px
			roxr      4(a3)			
			
			roxr      2(a3)			; Plane 1 Shift right 1 px
			roxr      6(a3) 

			adda.l	#8,a3 
		dbf		d6,.shiftline
		
		lea		ScratchArea,a3		; Reset Ptr
	dbf		d7,.shiftloop
	rts 



ScrollTextInit:
	move.l	#ScrollText,ScrollTextCurPtr
	move.w	#1,ScrollSlice
	rts

ScrollerNextChar:
	movea.l	ScrollTextCurPtr,A0
	adda.l	#1,a0 
	tst.b	(a0)					; EOT
	beq	.restart 
	move.l	a0,ScrollTextCurPtr
	move.w	#1,ScrollSlice
	bra		DoScroller_2 
.restart:
	move.l	#ScrollText,ScrollTextCurPtr
	move.w	#1,ScrollSlice
	bra		DoScroller_2 



; d0=0 (a6)=trace address
; (1500 cycles)
ClearSprite32	macro
	movea.l	(a6)+,a1
	
.Offset	set	0
	
	rept	31							; Hmm 31, not 32

		move.l	d0,.Offset+0(a1)
		move.l	d0,.Offset+8(a1)
		move.l	d0,.Offset+16(a1)

.Offset	set	$a0+.Offset

	endr

	endm



; d0=0 (a6)=trace address
; (492 cycles)
ClearSprite16	macro
	movea.l	(a6)+,a1

.Offset	set	0
	
	rept	15							; Hmm 15, not 16
	
		move.l	d0,.Offset+0(a1)
		move.l	d0,.Offset+8(a1)

.Offset	set	$a0+.Offset

	endr

	endm

; \1=XStep, \1=YStep, a5=X/Y Offsets, d0/d1=New Offsets
UpdateSpriteOffset	macro
	
	move.w	(a5)+,d0	; X offset
	move.w	(a5)+,d1	; Y offset
	addq.b	#\1,d0 
	addq.b	#\2,d1 
	move.w	d0,-4(a5)	; Store New
	move.w	d1,-2(a5) 
	
	endm

; a4=Sine Table, d0/d1=Offsets, out d0/d1=X/Y Coords
GetSpriteCoords	macro
	
	add.w	d0,d0 
	add.w	d1,d1 
	move.w	(a4,d0.w),d0 
	addi.w	#$200,d1
	move.w	(a4,d1.w),d1 

	endm

; \1=In/Out Data Reg, \2=Work Reg(Trashed)
FastMulu160	macro
	lsl.w	#5,\1 
	move.l	\1,\2 
	add.w	\1,\1 
	add.w	\1,\1 
	add.w	\2,\1 
	endm

; In: d0=X coord, Out: d0=Offset to word containing X
; Equivalent to	d0=((d0>>4)<<3)
WordOffset	macro
	andi.w	#$fff0,d0
	lsr.w	#1,d0 
	endm
	
; a2=Preshifted Sprite Data, a0=Screen, a4=SineTab, a5=Sine Data, a6=Trace Ptr
; (Approx. 5600 cycles)
DrawSprite32	macro

	moveq	#0,d0 
	moveq	#0,d1 
	
	UpdateSpriteOffset	2,1
	
	GetSpriteCoords	
	
	move.l	d0,d2		; Save X Coord
	
	FastMulu160	d1,d3	; Y Coord to screen offset
	
	movea.l	a0,a1 
	adda.l	d1,a1		; a1 = Ptr to Screen line
	
	WordOffset	
	adda.l	d0,a1		; a1 = Ptr to screen word
	
	move.l	a1,(a6)+	; Save trace address

	andi.w	#$f,d2		
	lsl.w	#8,d2 
	move.l	d2,d3 
	add.w	d2,d2 
	add.w	d3,d2 
	movea.l	a2,a3 
	adda.l	d2,a3		; a3 = Selected Preshift

.Offset	set	0
	
	rept	31							; Hmm 31, not 32

		movem.l	(a3)+,d0-d5 
		and.l	d0,.Offset+0(a1)
		and.l	d1,.Offset+8(a1)
		and.l	d2,.Offset+16(a1)
		or.l	d3,.Offset+0(a1)
		or.l	d4,.Offset+8(a1)
		or.l	d5,.Offset+16(a1)

.Offset	set	$a0+.Offset

	endr

	endm
		


; a2=Preshifted Sprite Data, a0=Screen, a4=SineTab, a5=Sine Data, a6=Trace Ptr
; (Approx. 1800 cycles)
DrawSprite16	macro

	moveq	#0,d0
	moveq	#0,d1 
	
	UpdateSpriteOffset	1,3
	
	GetSpriteCoords	
	
	move.l	d0,d2		; Save X Coord
	
	FastMulu160	d1,d3	; Y Coord to screen offset
	
	movea.l	a0,a1 
	adda.l	d1,a1		; a1 = Ptr to Screen line
	
	WordOffset	
	adda.l	d0,a1		; a1 = Ptr to screen word
	
	move.l	a1,(a6)+	; Save trace address
	
	andi.w	#$f,d2
	asl.l	#8,d2 
	movea.l	a2,a3 
	adda.l	d2,a3		; a3 = Selected Preshift
	
.Offset	set	0
	
	rept	7							; Hmm 15, not 16

		movem.l	(a3)+,d0-d7 
		and.l	d0,.Offset+0(a1)
		and.l	d1,.Offset+8(a1)
		or.l	d2,.Offset+0(a1)
		or.l	d3,.Offset+8(a1)
		and.l	d4,.Offset+$a0(a1)
		and.l	d5,.Offset+$a8(a1)
		or.l	d6,.Offset+$a0(a1)
		or.l	d7,.Offset+$a8(a1)

.Offset	set	$140+.Offset

	endr

	movem.l	(a3)+,d0-d3 
	and.l	d0,.Offset+0(a1)
	and.l	d1,.Offset+8(a1)
	or.l	d2,.Offset+0(a1)
	or.l	d3,.Offset+8(a1)

	endm

; Renders 10 words, in 10 consecutive lines
; \1=Current Offset, a0=Source, a1=Screen Addr
; (1200 cycles)
RenderScrollerBlock10	macro	

.Offset	set	\1
	movem.w	(a0)+,a2-a4/d0-d6
	move.w	d0,.Offset+$00(a1)
	move.w	d1,.Offset+$08(a1)
	move.w	d2,.Offset+$10(a1)
	move.w	d3,.Offset+$18(a1)
	move.w	d4,.Offset+$20(a1)
	move.w	d5,.Offset+$28(a1)
	move.w	d6,.Offset+$30(a1)
	move.w	a2,.Offset+$38(a1)
	move.w	a3,.Offset+$40(a1)
	move.w	a4,.Offset+$48(a1)
.Offset	set	$a0+.Offset
	move.w	d0,.Offset+$00(a1)
	move.w	d1,.Offset+$08(a1)
	move.w	d2,.Offset+$10(a1)
	move.w	d3,.Offset+$18(a1)
	move.w	d4,.Offset+$20(a1)
	move.w	d5,.Offset+$28(a1)
	move.w	d6,.Offset+$30(a1)
	move.w	a2,.Offset+$38(a1)
	move.w	a3,.Offset+$40(a1)
	move.w	a4,.Offset+$48(a1)
.Offset	set	$a0+.Offset
	move.w	d0,.Offset+$00(a1)
	move.w	d1,.Offset+$08(a1)
	move.w	d2,.Offset+$10(a1)
	move.w	d3,.Offset+$18(a1)
	move.w	d4,.Offset+$20(a1)
	move.w	d5,.Offset+$28(a1)
	move.w	d6,.Offset+$30(a1)
	move.w	a2,.Offset+$38(a1)
	move.w	a3,.Offset+$40(a1)
	move.w	a4,.Offset+$48(a1)
.Offset	set	$a0+.Offset
	move.w	d0,.Offset+$00(a1)
	move.w	d1,.Offset+$08(a1)
	move.w	d2,.Offset+$10(a1)
	move.w	d3,.Offset+$18(a1)
	move.w	d4,.Offset+$20(a1)
	move.w	d5,.Offset+$28(a1)
	move.w	d6,.Offset+$30(a1)
	move.w	a2,.Offset+$38(a1)
	move.w	a3,.Offset+$40(a1)
	move.w	a4,.Offset+$48(a1)
.Offset	set	$a0+.Offset
	move.w	d0,.Offset+$00(a1)
	move.w	d1,.Offset+$08(a1)
	move.w	d2,.Offset+$10(a1)
	move.w	d3,.Offset+$18(a1)
	move.w	d4,.Offset+$20(a1)
	move.w	d5,.Offset+$28(a1)
	move.w	d6,.Offset+$30(a1)
	move.w	a2,.Offset+$38(a1)
	move.w	a3,.Offset+$40(a1)
	move.w	a4,.Offset+$48(a1)
.Offset	set	$a0+.Offset
	move.w	d0,.Offset+$00(a1)
	move.w	d1,.Offset+$08(a1)
	move.w	d2,.Offset+$10(a1)
	move.w	d3,.Offset+$18(a1)
	move.w	d4,.Offset+$20(a1)
	move.w	d5,.Offset+$28(a1)
	move.w	d6,.Offset+$30(a1)
	move.w	a2,.Offset+$38(a1)
	move.w	a3,.Offset+$40(a1)
	move.w	a4,.Offset+$48(a1)
.Offset	set	$a0+.Offset
	move.w	d0,.Offset+$00(a1)
	move.w	d1,.Offset+$08(a1)
	move.w	d2,.Offset+$10(a1)
	move.w	d3,.Offset+$18(a1)
	move.w	d4,.Offset+$20(a1)
	move.w	d5,.Offset+$28(a1)
	move.w	d6,.Offset+$30(a1)
	move.w	a2,.Offset+$38(a1)
	move.w	a3,.Offset+$40(a1)
	move.w	a4,.Offset+$48(a1)
.Offset	set	$a0+.Offset
	move.w	d0,.Offset+$00(a1)
	move.w	d1,.Offset+$08(a1)
	move.w	d2,.Offset+$10(a1)
	move.w	d3,.Offset+$18(a1)
	move.w	d4,.Offset+$20(a1)
	move.w	d5,.Offset+$28(a1)
	move.w	d6,.Offset+$30(a1)
	move.w	a2,.Offset+$38(a1)
	move.w	a3,.Offset+$40(a1)
	move.w	a4,.Offset+$48(a1)
.Offset	set	$a0+.Offset
	move.w	d0,.Offset+$00(a1)
	move.w	d1,.Offset+$08(a1)
	move.w	d2,.Offset+$10(a1)
	move.w	d3,.Offset+$18(a1)
	move.w	d4,.Offset+$20(a1)
	move.w	d5,.Offset+$28(a1)
	move.w	d6,.Offset+$30(a1)
	move.w	a2,.Offset+$38(a1)
	move.w	a3,.Offset+$40(a1)
	move.w	a4,.Offset+$48(a1)
.Offset	set	$a0+.Offset
	move.w	d0,.Offset+$00(a1)
	move.w	d1,.Offset+$08(a1)
	move.w	d2,.Offset+$10(a1)
	move.w	d3,.Offset+$18(a1)
	move.w	d4,.Offset+$20(a1)
	move.w	d5,.Offset+$28(a1)
	move.w	d6,.Offset+$30(a1)
	move.w	a2,.Offset+$38(a1)
	move.w	a3,.Offset+$40(a1)
	move.w	a4,.Offset+$48(a1)

	endm



; \1=Current Offset, a6=tile Data, a5=Screen
; Copies across screen & 7 times down the screen
; (2264 cycles)
RenderTileLine	macro

.Offset	set	\1
	move.l	(a6)+,d0
	move.l	(a6)+,d1

	move.l	d0,.Offset+$00(a5)
	move.l	d1,.Offset+$08(a5)
	move.l	d0,.Offset+$10(a5)
	move.l	d1,.Offset+$18(a5)
	move.l	d0,.Offset+$20(a5)
	move.l	d1,.Offset+$28(a5)
	move.l	d0,.Offset+$30(a5)
	move.l	d1,.Offset+$38(a5)
	move.l	d0,.Offset+$40(a5)
	move.l	d1,.Offset+$48(a5)
	move.l	d0,.Offset+$50(a5)
	move.l	d1,.Offset+$58(a5)
	move.l	d0,.Offset+$60(a5)
	move.l	d1,.Offset+$68(a5)
	move.l	d0,.Offset+$70(a5)
	move.l	d1,.Offset+$78(a5)
	move.l	d0,.Offset+$80(a5)
	move.l	d1,.Offset+$88(a5)
	move.l	d0,.Offset+$90(a5)
	move.l	d1,.Offset+$98(a5)

.Offset	set	(32*$a0)+.Offset
	move.l	d0,.Offset+$00(a5)
	move.l	d1,.Offset+$08(a5)
	move.l	d0,.Offset+$10(a5)
	move.l	d1,.Offset+$18(a5)
	move.l	d0,.Offset+$20(a5)
	move.l	d1,.Offset+$28(a5)
	move.l	d0,.Offset+$30(a5)
	move.l	d1,.Offset+$38(a5)
	move.l	d0,.Offset+$40(a5)
	move.l	d1,.Offset+$48(a5)
	move.l	d0,.Offset+$50(a5)
	move.l	d1,.Offset+$58(a5)
	move.l	d0,.Offset+$60(a5)
	move.l	d1,.Offset+$68(a5)
	move.l	d0,.Offset+$70(a5)
	move.l	d1,.Offset+$78(a5)
	move.l	d0,.Offset+$80(a5)
	move.l	d1,.Offset+$88(a5)
	move.l	d0,.Offset+$90(a5)
	move.l	d1,.Offset+$98(a5)

.Offset	set	(32*$a0)+.Offset
	move.l	d0,.Offset+$00(a5)
	move.l	d1,.Offset+$08(a5)
	move.l	d0,.Offset+$10(a5)
	move.l	d1,.Offset+$18(a5)
	move.l	d0,.Offset+$20(a5)
	move.l	d1,.Offset+$28(a5)
	move.l	d0,.Offset+$30(a5)
	move.l	d1,.Offset+$38(a5)
	move.l	d0,.Offset+$40(a5)
	move.l	d1,.Offset+$48(a5)
	move.l	d0,.Offset+$50(a5)
	move.l	d1,.Offset+$58(a5)
	move.l	d0,.Offset+$60(a5)
	move.l	d1,.Offset+$68(a5)
	move.l	d0,.Offset+$70(a5)
	move.l	d1,.Offset+$78(a5)
	move.l	d0,.Offset+$80(a5)
	move.l	d1,.Offset+$88(a5)
	move.l	d0,.Offset+$90(a5)
	move.l	d1,.Offset+$98(a5)

.Offset	set	(32*$a0)+.Offset
	move.l	d0,.Offset+$00(a5)
	move.l	d1,.Offset+$08(a5)
	move.l	d0,.Offset+$10(a5)
	move.l	d1,.Offset+$18(a5)
	move.l	d0,.Offset+$20(a5)
	move.l	d1,.Offset+$28(a5)
	move.l	d0,.Offset+$30(a5)
	move.l	d1,.Offset+$38(a5)
	move.l	d0,.Offset+$40(a5)
	move.l	d1,.Offset+$48(a5)
	move.l	d0,.Offset+$50(a5)
	move.l	d1,.Offset+$58(a5)
	move.l	d0,.Offset+$60(a5)
	move.l	d1,.Offset+$68(a5)
	move.l	d0,.Offset+$70(a5)
	move.l	d1,.Offset+$78(a5)
	move.l	d0,.Offset+$80(a5)
	move.l	d1,.Offset+$88(a5)
	move.l	d0,.Offset+$90(a5)
	move.l	d1,.Offset+$98(a5)

.Offset	set	(32*$a0)+.Offset
	move.l	d0,.Offset+$00(a5)
	move.l	d1,.Offset+$08(a5)
	move.l	d0,.Offset+$10(a5)
	move.l	d1,.Offset+$18(a5)
	move.l	d0,.Offset+$20(a5)
	move.l	d1,.Offset+$28(a5)
	move.l	d0,.Offset+$30(a5)
	move.l	d1,.Offset+$38(a5)
	move.l	d0,.Offset+$40(a5)
	move.l	d1,.Offset+$48(a5)
	move.l	d0,.Offset+$50(a5)
	move.l	d1,.Offset+$58(a5)
	move.l	d0,.Offset+$60(a5)
	move.l	d1,.Offset+$68(a5)
	move.l	d0,.Offset+$70(a5)
	move.l	d1,.Offset+$78(a5)
	move.l	d0,.Offset+$80(a5)
	move.l	d1,.Offset+$88(a5)
	move.l	d0,.Offset+$90(a5)
	move.l	d1,.Offset+$98(a5)

.Offset	set	(32*$a0)+.Offset
	move.l	d0,.Offset+$00(a5)
	move.l	d1,.Offset+$08(a5)
	move.l	d0,.Offset+$10(a5)
	move.l	d1,.Offset+$18(a5)
	move.l	d0,.Offset+$20(a5)
	move.l	d1,.Offset+$28(a5)
	move.l	d0,.Offset+$30(a5)
	move.l	d1,.Offset+$38(a5)
	move.l	d0,.Offset+$40(a5)
	move.l	d1,.Offset+$48(a5)
	move.l	d0,.Offset+$50(a5)
	move.l	d1,.Offset+$58(a5)
	move.l	d0,.Offset+$60(a5)
	move.l	d1,.Offset+$68(a5)
	move.l	d0,.Offset+$70(a5)
	move.l	d1,.Offset+$78(a5)
	move.l	d0,.Offset+$80(a5)
	move.l	d1,.Offset+$88(a5)
	move.l	d0,.Offset+$90(a5)
	move.l	d1,.Offset+$98(a5)

.Offset	set	(32*$a0)+.Offset
	move.l	d0,.Offset+$00(a5)
	move.l	d1,.Offset+$08(a5)
	move.l	d0,.Offset+$10(a5)
	move.l	d1,.Offset+$18(a5)
	move.l	d0,.Offset+$20(a5)
	move.l	d1,.Offset+$28(a5)
	move.l	d0,.Offset+$30(a5)
	move.l	d1,.Offset+$38(a5)
	move.l	d0,.Offset+$40(a5)
	move.l	d1,.Offset+$48(a5)
	move.l	d0,.Offset+$50(a5)
	move.l	d1,.Offset+$58(a5)
	move.l	d0,.Offset+$60(a5)
	move.l	d1,.Offset+$68(a5)
	move.l	d0,.Offset+$70(a5)
	move.l	d1,.Offset+$78(a5)
	move.l	d0,.Offset+$80(a5)
	move.l	d1,.Offset+$88(a5)
	move.l	d0,.Offset+$90(a5)
	move.l	d1,.Offset+$98(a5)

	endm


; \1=Current Offset, a6=tile Data, a5=Screen
; Copies across screen & 6 times down the screen
; (1944 cycles)
RenderTileLineShort	macro

.Offset	set	\1
	move.l	(a6)+,d0
	move.l	(a6)+,d1

	move.l	d0,.Offset+$00(a5)
	move.l	d1,.Offset+$08(a5)
	move.l	d0,.Offset+$10(a5)
	move.l	d1,.Offset+$18(a5)
	move.l	d0,.Offset+$20(a5)
	move.l	d1,.Offset+$28(a5)
	move.l	d0,.Offset+$30(a5)
	move.l	d1,.Offset+$38(a5)
	move.l	d0,.Offset+$40(a5)
	move.l	d1,.Offset+$48(a5)
	move.l	d0,.Offset+$50(a5)
	move.l	d1,.Offset+$58(a5)
	move.l	d0,.Offset+$60(a5)
	move.l	d1,.Offset+$68(a5)
	move.l	d0,.Offset+$70(a5)
	move.l	d1,.Offset+$78(a5)
	move.l	d0,.Offset+$80(a5)
	move.l	d1,.Offset+$88(a5)
	move.l	d0,.Offset+$90(a5)
	move.l	d1,.Offset+$98(a5)

.Offset	set	(32*$a0)+.Offset
	move.l	d0,.Offset+$00(a5)
	move.l	d1,.Offset+$08(a5)
	move.l	d0,.Offset+$10(a5)
	move.l	d1,.Offset+$18(a5)
	move.l	d0,.Offset+$20(a5)
	move.l	d1,.Offset+$28(a5)
	move.l	d0,.Offset+$30(a5)
	move.l	d1,.Offset+$38(a5)
	move.l	d0,.Offset+$40(a5)
	move.l	d1,.Offset+$48(a5)
	move.l	d0,.Offset+$50(a5)
	move.l	d1,.Offset+$58(a5)
	move.l	d0,.Offset+$60(a5)
	move.l	d1,.Offset+$68(a5)
	move.l	d0,.Offset+$70(a5)
	move.l	d1,.Offset+$78(a5)
	move.l	d0,.Offset+$80(a5)
	move.l	d1,.Offset+$88(a5)
	move.l	d0,.Offset+$90(a5)
	move.l	d1,.Offset+$98(a5)

.Offset	set	(32*$a0)+.Offset
	move.l	d0,.Offset+$00(a5)
	move.l	d1,.Offset+$08(a5)
	move.l	d0,.Offset+$10(a5)
	move.l	d1,.Offset+$18(a5)
	move.l	d0,.Offset+$20(a5)
	move.l	d1,.Offset+$28(a5)
	move.l	d0,.Offset+$30(a5)
	move.l	d1,.Offset+$38(a5)
	move.l	d0,.Offset+$40(a5)
	move.l	d1,.Offset+$48(a5)
	move.l	d0,.Offset+$50(a5)
	move.l	d1,.Offset+$58(a5)
	move.l	d0,.Offset+$60(a5)
	move.l	d1,.Offset+$68(a5)
	move.l	d0,.Offset+$70(a5)
	move.l	d1,.Offset+$78(a5)
	move.l	d0,.Offset+$80(a5)
	move.l	d1,.Offset+$88(a5)
	move.l	d0,.Offset+$90(a5)
	move.l	d1,.Offset+$98(a5)

.Offset	set	(32*$a0)+.Offset
	move.l	d0,.Offset+$00(a5)
	move.l	d1,.Offset+$08(a5)
	move.l	d0,.Offset+$10(a5)
	move.l	d1,.Offset+$18(a5)
	move.l	d0,.Offset+$20(a5)
	move.l	d1,.Offset+$28(a5)
	move.l	d0,.Offset+$30(a5)
	move.l	d1,.Offset+$38(a5)
	move.l	d0,.Offset+$40(a5)
	move.l	d1,.Offset+$48(a5)
	move.l	d0,.Offset+$50(a5)
	move.l	d1,.Offset+$58(a5)
	move.l	d0,.Offset+$60(a5)
	move.l	d1,.Offset+$68(a5)
	move.l	d0,.Offset+$70(a5)
	move.l	d1,.Offset+$78(a5)
	move.l	d0,.Offset+$80(a5)
	move.l	d1,.Offset+$88(a5)
	move.l	d0,.Offset+$90(a5)
	move.l	d1,.Offset+$98(a5)

.Offset	set	(32*$a0)+.Offset
	move.l	d0,.Offset+$00(a5)
	move.l	d1,.Offset+$08(a5)
	move.l	d0,.Offset+$10(a5)
	move.l	d1,.Offset+$18(a5)
	move.l	d0,.Offset+$20(a5)
	move.l	d1,.Offset+$28(a5)
	move.l	d0,.Offset+$30(a5)
	move.l	d1,.Offset+$38(a5)
	move.l	d0,.Offset+$40(a5)
	move.l	d1,.Offset+$48(a5)
	move.l	d0,.Offset+$50(a5)
	move.l	d1,.Offset+$58(a5)
	move.l	d0,.Offset+$60(a5)
	move.l	d1,.Offset+$68(a5)
	move.l	d0,.Offset+$70(a5)
	move.l	d1,.Offset+$78(a5)
	move.l	d0,.Offset+$80(a5)
	move.l	d1,.Offset+$88(a5)
	move.l	d0,.Offset+$90(a5)
	move.l	d1,.Offset+$98(a5)

.Offset	set	(32*$a0)+.Offset
	move.l	d0,.Offset+$00(a5)
	move.l	d1,.Offset+$08(a5)
	move.l	d0,.Offset+$10(a5)
	move.l	d1,.Offset+$18(a5)
	move.l	d0,.Offset+$20(a5)
	move.l	d1,.Offset+$28(a5)
	move.l	d0,.Offset+$30(a5)
	move.l	d1,.Offset+$38(a5)
	move.l	d0,.Offset+$40(a5)
	move.l	d1,.Offset+$48(a5)
	move.l	d0,.Offset+$50(a5)
	move.l	d1,.Offset+$58(a5)
	move.l	d0,.Offset+$60(a5)
	move.l	d1,.Offset+$68(a5)
	move.l	d0,.Offset+$70(a5)
	move.l	d1,.Offset+$78(a5)
	move.l	d0,.Offset+$80(a5)
	move.l	d1,.Offset+$88(a5)
	move.l	d0,.Offset+$90(a5)
	move.l	d1,.Offset+$98(a5)

	endm


;-------------------------------------------------------------------------------
MainLoop:
	move.b	#-1,SyncVBL 
.WaitLock:
	tst.w	SyncVBL 
	bne.s	.WaitLock

	; Swap traces
	move.l	SpriteTracePtrA,D0
	move.l	SpriteTracePtrB,SpriteTracePtrA 
	move.l	d0,SpriteTracePtrB

	; Clear Sprites
	movea.l   SpriteTracePtrA,a6
	moveq     #0,d0
		
		; Clear IC 32x32 Sprites 
		ClearSprite32
		ClearSprite32

		; Clear TFB 16x16 Sprites 
		ClearSprite16
		ClearSprite16
		ClearSprite16
	
	; Total Sprite Clear: 4476 cycles (2.8% CPU)

DoScroller:
	moveq	#0,d1 
	move.w	ScrollSlice,d1
	tst.w	d1
	beq		ScrollerNextChar 
DoScroller_2:

	; Byte-Scroll the buffer 
	; NOTE. Only scrolling 15 lines since that's all we're displaying
	lea		ScrollBuffer,a0				
	rept	(BigScrollBufferWidth*(BigScrollBufferHeight-1))
		move.b    1(a0),(a0)+ 
	endr
	; (9600 cycles, 6% CPU) 

	; Scroller slice update probably
	moveq     #0,d0				
	movea.l   ScrollTextCurPtr,a0
	move.b    (a0),d0					; Current char

	subi.b    #BigFontFirstChar,d0
	swap      d0
	asr.l     #7,d0						; <<9 ( x 512 )			
	
	lea       BigFontExpanded,a0		; a0=font
	adda.l    d0,a0						; a0=char
	adda.l    d1,a0						; a0=slice
	
	addq.l    #1,d1 
	andi.w    #$1f,d1 
	move.w    d1,ScrollSlice			; Update slice
	
	lea       ScrollBuffer,a1			
	move.b    (0*BigFontExpandedWidth)(a0),(1*BigScrollBufferWidth)-1(a1) 
	move.b    (1*BigFontExpandedWidth)(a0),(2*BigScrollBufferWidth)-1(a1) 
	move.b    (2*BigFontExpandedWidth)(a0),(3*BigScrollBufferWidth)-1(a1) 
	move.b    (3*BigFontExpandedWidth)(a0),(4*BigScrollBufferWidth)-1(a1) 
	move.b    (4*BigFontExpandedWidth)(a0),(5*BigScrollBufferWidth)-1(a1) 
	move.b    (5*BigFontExpandedWidth)(a0),(6*BigScrollBufferWidth)-1(a1) 
	move.b    (6*BigFontExpandedWidth)(a0),(7*BigScrollBufferWidth)-1(a1)
	move.b    (7*BigFontExpandedWidth)(a0),(8*BigScrollBufferWidth)-1(a1)
	move.b    (8*BigFontExpandedWidth)(a0),(9*BigScrollBufferWidth)-1(a1) 
	move.b    (9*BigFontExpandedWidth)(a0),(10*BigScrollBufferWidth)-1(a1) 
	move.b    (10*BigFontExpandedWidth)(a0),(11*BigScrollBufferWidth)-1(a1) 
	move.b    (11*BigFontExpandedWidth)(a0),(12*BigScrollBufferWidth)-1(a1) 
	move.b    (12*BigFontExpandedWidth)(a0),(13*BigScrollBufferWidth)-1(a1) 
	move.b    (13*BigFontExpandedWidth)(a0),(14*BigScrollBufferWidth)-1(a1) 
	move.b    (14*BigFontExpandedWidth)(a0),(15*BigScrollBufferWidth)-1(a1) 
	move.b    (15*BigFontExpandedWidth)(a0),(16*BigScrollBufferWidth)-1(a1) 

	; Draw the scroller
	movea.l   ScreenPtrB,a1	
	adda.l    #(26*160)+4,a1	; 26th Line, Plane 2
	lea       ScrollBuffer,a0				

.BlockOffset	set	0

	rept	15	; 15 High 

		RenderScrollerBlock10	.BlockOffset+$00	; Left
		RenderScrollerBlock10	.BlockOffset+$50	; Right

.BlockOffset	set	(160*10)+.BlockOffset

	endr

	; 1200*2*15 cycles
	; Total for scroller draw => 36000 cycles
	; (22.5% CPU)


; Draw Tiles
DoTiles:
	moveq	#0,d0 
	moveq	#0,d1 
	movea.l	TileWavePtr,a0
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	cmpa.l	#TileWaveEnd,a0 
	bne		.noreset
	movea.l	#TileWaveData,a0 
.noreset:
	move.l	a0,TileWavePtr

	eori.l	#$1f,d0 
	andi.l	#$1f,d0 
	swap	d0
	asr.l	#7,d0 
	andi.l	#$1f,d1 
	asl.l	#3,d1 
	lea		PreshiftTile_0,a6
	adda.l	d0,a6 
	adda.l	d1,a6 
	movea.l	ScreenPtrB,a5		

.TileLineOffset	set	0

	rept	8

		RenderTileLine		.TileLineOffset

.TileLineOffset	set	$a0+.TileLineOffset
		
	endr

	rept	32-8
	
		RenderTileLineShort	.TileLineOffset
		
.TileLineOffset	set	$a0+.TileLineOffset
	
	endr

	; 8*2264 cycles
	; 24*1944 cycles
	; Total for tile draw => 64768 cycles
	; (40.4% CPU)

; Clear raster bars
	moveq	#0,d5 
	lea		Rasters,A2
	rept	37
		move.l	d5,(a2)+
	endr

; sprites
; Note: Drawn back to front
DoSprites:
	movea.l	SpriteTracePtrA,a6
	movea.l	ScreenPtrB,a0
	lea		4(A0),a0
	lea		SpriteSines_1,a4
	lea		SpriteOffsets,a5

	lea		Preshift32_C,a2
	DrawSprite32

	lea		Preshift32_I,a2
	DrawSprite32

	lea		SpriteSines_3,A4

	lea		Preshift16_B,a2
	DrawSprite16

	lea		Preshift16_F,a2
	DrawSprite16

	lea		Preshift16_T,a2
	DrawSprite16

	; Total Sprite Draw (Approx): 16600 cycles (10.4% CPU)

; Palette Fade
	subq.w	#1,FadeDelay
	bmi		.endfade 
	bne		.skipfade

	movea.l	FadePalettePtr,a0	; Load next set of colours 00-03
	movem.w	(a0)+,d0-d3 
	movem.w	d0-d3,$ffff8240.w 

	cmpa.l	#FadePaletteEnd,a0 
	beq		.endfade			; Last one?

	move.l	a0,FadePalettePtr
	move.w	#9,FadeDelay		; Next fade in 9 frames
	  
.skipfade:
	cmpi.b    #$39,LastKey
	beq       .ExitMainLoop
	jmp       MainLoop 
.ExitMainLoop:
	rts 
.endfade:
	move.w	#0,FadeDelay
	bra.s	.skipfade

InitRasterBars:
	; Set initial bar positions
	lea       RasterBarPositions,a0
	move.b    #0,(a0)+
	move.b    #$19,(a0)+
	move.b    #$32,(a0)+
	move.b    #$4b,(a0)+
	rts 
	  
	DATA
	
; "Big" font source data. 1PL 16x16. ( 60 chars from space onwards )
BigFontData:
	incbin Nfont.bin

ScrollText:
	dc.b	'                               #$ TFB #$        '
	dc.b	'  WELCOME TO THE FINGERBOBS NAFF DEMO   '
	dc.b	'  SPECIAL RELEASE EXCLUSIVE TO   RIPPED OFF!    '
	dc.b	'     CODE BY OBERJE     GFX BY PIXAR      MUSIC BY MAX-E-POOS   '
	dc.b	'  THIS SCREEN WAS ORIGINALLY CODED FOR INCLUSION IN THE '
	dc.b	'INNER CIRCLE DECADE DEMO.   HOWEVER IT WAS NOT  INCLUDED'
	dc.b	'!! SO NOW IN DECEMBER, 9 MONTHS AFTER ITS CREATION, I HAVE DECIDED TO RELEASE IT'
	dc.b	' TO THE WORLD VIA THE WONDERS OF THE RIPPED OFF COMPACT DEMOS COLLECTION'
	dc.b	'....... NOW I SEND MY GREETINGS.'
	dc.b	'...... BIG HI TO        '
	dc.b	'ELECTRONIC IMAGES/RESISTANCE  RED HERRINGS AND ST SQUAD '
	dc.b	'     LONG LIVE THE INNER CIRCLE!!   EXTRA SPECIAL ',$27,'YO DUDES!',$27
	dc.b	' TO     STICK AND BILBO , VANTAGE OF ST CONNEXION, '
	dc.b	'THE LOST BOYS ( HI SAMMY JOE! ) '
	dc.b	' THE DEMO CLUB, CALEDONIA PDL, ESD, DEFBOY, THE BOMB SQUAD, ST FORMAT, MARK FAE CANADA!!'
	dc.b	', ANYONE I',$27,'VE MISSED!   '
	dc.b	' STANDARD TYPE OF GREETS TO   THE CAREBEARS, THE UNION, ULM, TEX, THE ALLIANCE, '
	dc.b	' THE GERMAN ALLIANCE, SYNC, GHOST, VECTOR ETC...'
	dc.b	'      HUGS AND KISSES ( OOH ER ) TO THE FOLLOWING SEXY BABES   PATSY KENSIT, MEG RYAN, '
	dc.b	'WINONA RYDER, ELIZABETH SHUE, MARY STUART MASTERSON, LEA THOMSON, PAULINA PORISKOVA, ALISON DOODY'
	dc.b	' AND BELINDA CARLISLE!!!! THE SEXIEST WOMEN ON SCREEN!  '
	dc.b	'  A HUGE ',$27,'GET TO FUCK',$27,' TO THE BLUE RONDO CREW ( AS ALWAYS! )    '
	dc.b	' WELL BOYS ( OR POSSIBLY EVEN GIRLS! ) CONGRATULATIONS ON READING THIS FAR, NOT EASY IS '
	dc.b	'IT?  STILL ITS BETTER THAN SETTING FIRE TO YOUR UNDERWEAR! - OR IS IT?  '
	dc.b	' NO POINT HURTING YOUR EYES, SO I',$27,'LL WRAPP THIS UP NOW, '
	dc.b	' CIAO!    #$ TFB #$                '
	dc.b	$00 
	
TileData:
	dc.b	$ee,$ee,$3f,$77,$b5,$bb,$7a,$cc
	dc.b	$f7,$bd,$7b,$ce,$eb,$7e,$f5,$bb
	dc.b	$ed,$f6,$f6,$39,$de,$dd,$6b,$67
	dc.b	$ff,$dd,$ed,$e6,$af,$bf,$dc,$c3
	dc.b	$b6,$fb,$df,$4d,$d7,$fd,$39,$be
	dc.b	$6b,$77,$bc,$9b,$ae,$d7,$f3,$7b
	dc.b	$f6,$fd,$79,$de,$dd,$ad,$e6,$f6
	dc.b	$af,$7b,$d3,$bd,$bb,$5b,$dd,$ec
	dc.b	$7e,$ee,$ef,$73,$f7,$b6,$3b,$d9
	dc.b	$b5,$dd,$da,$ee,$de,$ed,$e7,$37
	dc.b	$6e,$bb,$b1,$5f,$7d,$be,$b6,$c3
	dc.b	$ff,$7e,$6e,$bf,$db,$5b,$7d,$ec
	dc.b	$bb,$ed,$dd,$f6,$af,$be,$f2,$cb
	dc.b	$77,$db,$bb,$ed,$5f,$6f,$e7,$97
	dc.b	$eb,$be,$75,$c3,$af,$dd,$df,$2e
	dc.b	$d7,$7f,$eb,$9d,$7d,$fb,$9e,$7c
	dc.b	$6f,$f7,$96,$1b,$db,$57,$fc,$f8
	dc.b	$db,$6f,$6d,$bf,$f6,$ee,$fb,$f1
	dc.b	$f6,$df,$9b,$7f,$6f,$7d,$97,$82
	dc.b	$6d,$be,$b6,$ff,$fa,$bb,$4f,$45
	dc.b	$df,$f5,$61,$7e,$75,$7e,$be,$93
	dc.b	$7e,$aa,$8f,$fd,$da,$fd,$6d,$7e
	dc.b	$bd,$dd,$7e,$62,$bd,$ee,$c2,$f9
	dc.b	$db,$bb,$ec,$cd,$7f,$d5,$99,$fe
	dc.b	$be,$fe,$d1,$03,$f3,$ab,$7f,$fc
	dc.b	$6d,$77,$b7,$98,$8f,$5f,$f7,$e1
	dc.b	$fa,$ef,$cf,$75,$ed,$f7,$b7,$9b
	dc.b	$f7,$b6,$98,$cf,$be,$eb,$df,$77
	dc.b	$bf,$7b,$c1,$bf,$bb,$b5,$7c,$cf
	dc.b	$6e,$dd,$97,$6e,$d7,$eb,$f9,$3f
	dc.b	$dd,$bb,$2e,$dd,$ae,$f5,$d3,$7e
	dc.b	$b7,$77,$59,$bb,$7f,$de,$af,$e3

FadeDelay:	
	dc.w	$020e

FadePalette:	
	dc.w	$0000,$0000,$0111,$0111
	dc.w	$0000,$0111,$0111,$0222
	dc.w	$0000,$0111,$0222,$0333
	dc.w	$0000,$0222,$0333,$0444
	dc.w	$0000,$0222,$0444,$0555
	dc.w	$0000,$0333,$0555,$0666
FadePaletteEnd	equ	*

MainPalette:
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0300,$0300,$0300
	dc.w	$0000,$0300,$0300,$0300
	dc.w	$0000,$0700,$0700,$0700 

; Tile "Sine" Table
TileWaveData:
	incbin NTileWav.bin
TileWaveEnd	equ	*

MusicData:
	incbin NMusic.bin
MusicDataEnd	equ	*
	
RasterBarCols:
RasterBarCols_1:
	dc.w	$0200,$0300,$0400,$0500,$0600,$0700
	dc.w	$0700,$0600,$0500,$0400,$0300,$0200
RasterBarCols_2:
	dc.w	$0220,$0330,$0440,$0550,$0660,$0770
	dc.w	$0770,$0660,$0550,$0440,$0330,$0220
RasterBarCols_3:
	dc.w	$0020,$0030,$0040,$0050,$0060,$0070
	dc.w	$0070,$0060,$0050,$0040,$0030,$0020
RasterBarCols_4:
	dc.w	$0002,$0003,$0004,$0005,$0006,$0007
	dc.w	$0007,$0006,$0005,$0004,$0003,$0002

RasterSineTable:      
	dc.b	$3f,$40,$42,$43,$45,$46,$48,$49		; Range 0->127
	dc.b	$4b,$4c,$4e,$4f,$51,$52,$54,$55
	dc.b	$57,$58,$5a,$5b,$5c,$5e,$5f,$60
	dc.b	$62,$63,$64,$65,$67,$68,$69,$6a
	dc.b	$6b,$6c,$6d,$6e,$6f,$70,$71,$72
	dc.b	$73,$74,$75,$75,$76,$77,$78,$78
	dc.b	$79,$79,$7a,$7a,$7b,$7b,$7c,$7c
	dc.b	$7c,$7d,$7d,$7d,$7d,$7d,$7d,$7d
	dc.b	$7d,$7d,$7d,$7d,$7d,$7d,$7d,$7c
	dc.b	$7c,$7c,$7c,$7b,$7b,$7a,$7a,$79
	dc.b	$79,$78,$77,$77,$76,$75,$74,$73
	dc.b	$73,$72,$71,$70,$6f,$6e,$6d,$6c
	dc.b	$6b,$6a,$68,$67,$66,$65,$64,$62
	dc.b	$61,$60,$5e,$5d,$5c,$5a,$59,$57
	dc.b	$56,$55,$53,$52,$50,$4f,$4d,$4c
	dc.b	$4a,$49,$47,$45,$44,$42,$41,$3f
	dc.b	$3e,$3c,$3b,$39,$38,$36,$34,$33
	dc.b	$31,$30,$2e,$2d,$2b,$2a,$28,$27
	dc.b	$26,$24,$23,$21,$20,$1f,$1d,$1c
	dc.b	$1b,$19,$18,$17,$16,$15,$13,$12
	dc.b	$11,$10,$0f,$0e,$0d,$0c,$0b,$0a
	dc.b	$0a,$09,$08,$07,$06,$06,$05,$04
	dc.b	$04,$03,$03,$02,$02,$01,$01,$01
	dc.b	$01,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$01
	dc.b	$01,$01,$02,$02,$03,$03,$04,$04
	dc.b	$05,$05,$06,$07,$08,$08,$09,$0a
	dc.b	$0b,$0c,$0d,$0e,$0f,$10,$11,$12
	dc.b	$13,$14,$15,$16,$18,$19,$1a,$1b
	dc.b	$1d,$1e,$1f,$21,$22,$23,$25,$26
	dc.b	$28,$29,$2b,$2c,$2e,$2f,$31,$32
	dc.b	$34,$35,$37,$38,$3a,$3b,$3d,$3f


SpriteSines_1:	
	dc.w	$008f,$0092,$0096,$0099
	dc.w	$009d,$00a0,$00a3,$00a7
	dc.w	$00aa,$00ae,$00b1,$00b5
	dc.w	$00b8,$00bb,$00bf,$00c2
	dc.w	$00c5,$00c8,$00cc,$00cf
	dc.w	$00d2,$00d5,$00d8,$00db
	dc.w	$00de,$00e1,$00e4,$00e6
	dc.w	$00e9,$00ec,$00ef,$00f1
	dc.w	$00f4,$00f6,$00f8,$00fb
	dc.w	$00fd,$00ff,$0101,$0103
	dc.w	$0105,$0107,$0109,$010b
	dc.w	$010d,$010e,$0110,$0111
	dc.w	$0113,$0114,$0115,$0116
	dc.w	$0117,$0118,$0119,$011a
	dc.w	$011b,$011b,$011c,$011c
	dc.w	$011d,$011d,$011d,$011d
	dc.w	$011e,$011d,$011d,$011d
	dc.w	$011d,$011c,$011c,$011b
	dc.w	$011b,$011a,$0119,$0118
	dc.w	$0117,$0116,$0115,$0114
	dc.w	$0113,$0111,$0110,$010e
	dc.w	$010d,$010b,$0109,$0107
	dc.w	$0105,$0103,$0101,$00ff
	dc.w	$00fd,$00fb,$00f8,$00f6
	dc.w	$00f4,$00f1,$00ef,$00ec
	dc.w	$00e9,$00e6,$00e4,$00e1
	dc.w	$00de,$00db,$00d8,$00d5
	dc.w	$00d2,$00cf,$00cc,$00c8
	dc.w	$00c5,$00c2,$00bf,$00bb
	dc.w	$00b8,$00b5,$00b1,$00ae
	dc.w	$00aa,$00a7,$00a3,$00a0
	dc.w	$009d,$0099,$0096,$0092
	dc.w	$008f,$008b,$0087,$0084
	dc.w	$0080,$007d,$007a,$0076
	dc.w	$0073,$006f,$006c,$0068
	dc.w	$0065,$0062,$005e,$005b
	dc.w	$0058,$0055,$0051,$004e
	dc.w	$004b,$0048,$0045,$0042
	dc.w	$003f,$003c,$0039,$0037
	dc.w	$0034,$0031,$002e,$002c
	dc.w	$0029,$0027,$0025,$0022
	dc.w	$0020,$001e,$001c,$001a
	dc.w	$0018,$0016,$0014,$0012
	dc.w	$0010,$000f,$000d,$000c
	dc.w	$000a,$0009,$0008,$0007
	dc.w	$0006,$0005,$0004,$0003
	dc.w	$0002,$0002,$0001,$0001
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0001,$0001,$0002
	dc.w	$0002,$0003,$0004,$0005
	dc.w	$0006,$0007,$0008,$0009
	dc.w	$000a,$000c,$000d,$000f
	dc.w	$0010,$0012,$0014,$0016
	dc.w	$0018,$001a,$001c,$001e
	dc.w	$0020,$0022,$0025,$0027
	dc.w	$0029,$002c,$002e,$0031
	dc.w	$0034,$0037,$0039,$003c
	dc.w	$003f,$0042,$0045,$0048
	dc.w	$004b,$004e,$0051,$0055
	dc.w	$0058,$005b,$005e,$0062
	dc.w	$0065,$0068,$006c,$006f
	dc.w	$0073,$0076,$007a,$007d
	dc.w	$0080,$0084,$0087,$008b
SpriteSines_2:	
	dc.w	$0053,$0055,$0057,$0059
	dc.w	$005b,$005d,$005f,$0061
	dc.w	$0063,$0065,$0067,$0069
	dc.w	$006b,$006d,$006e,$0070
	dc.w	$0072,$0074,$0076,$0078
	dc.w	$007a,$007b,$007d,$007f
	dc.w	$0081,$0082,$0084,$0086
	dc.w	$0087,$0089,$008a,$008c
	dc.w	$008d,$008f,$0090,$0091
	dc.w	$0093,$0094,$0095,$0096
	dc.w	$0098,$0099,$009a,$009b
	dc.w	$009c,$009d,$009e,$009e
	dc.w	$009f,$00a0,$00a1,$00a1
	dc.w	$00a2,$00a2,$00a3,$00a3
	dc.w	$00a4,$00a4,$00a5,$00a5
	dc.w	$00a5,$00a5,$00a5,$00a5
	dc.w	$00a6,$00a5,$00a5,$00a5
	dc.w	$00a5,$00a5,$00a5,$00a4
	dc.w	$00a4,$00a3,$00a3,$00a2
	dc.w	$00a2,$00a1,$00a1,$00a0
	dc.w	$009f,$009e,$009e,$009d
	dc.w	$009c,$009b,$009a,$0099
	dc.w	$0098,$0096,$0095,$0094
	dc.w	$0093,$0091,$0090,$008f
	dc.w	$008d,$008c,$008a,$0089
	dc.w	$0087,$0086,$0084,$0082
	dc.w	$0081,$007f,$007d,$007b
	dc.w	$007a,$0078,$0076,$0074
	dc.w	$0072,$0070,$006e,$006d
	dc.w	$006b,$0069,$0067,$0065
	dc.w	$0063,$0061,$005f,$005d
	dc.w	$005b,$0059,$0057,$0055
	dc.w	$0053,$0050,$004e,$004c
	dc.w	$004a,$0048,$0046,$0044
	dc.w	$0042,$0040,$003e,$003c
	dc.w	$003a,$0038,$0037,$0035
	dc.w	$0033,$0031,$002f,$002d
	dc.w	$002b,$002a,$0028,$0026
	dc.w	$0024,$0023,$0021,$001f
	dc.w	$001e,$001c,$001b,$0019
	dc.w	$0018,$0016,$0015,$0014
	dc.w	$0012,$0011,$0010,$000f
	dc.w	$000d,$000c,$000b,$000a
	dc.w	$0009,$0008,$0007,$0007
	dc.w	$0006,$0005,$0004,$0004
	dc.w	$0003,$0003,$0002,$0002
	dc.w	$0001,$0001,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0001
	dc.w	$0001,$0002,$0002,$0003
	dc.w	$0003,$0004,$0004,$0005
	dc.w	$0006,$0007,$0007,$0008
	dc.w	$0009,$000a,$000b,$000c
	dc.w	$000d,$000f,$0010,$0011
	dc.w	$0012,$0014,$0015,$0016
	dc.w	$0018,$0019,$001b,$001c
	dc.w	$001e,$001f,$0021,$0023
	dc.w	$0024,$0026,$0028,$002a
	dc.w	$002b,$002d,$002f,$0031
	dc.w	$0033,$0035,$0037,$0038
	dc.w	$003a,$003c,$003e,$0040
	dc.w	$0042,$0044,$0046,$0048
	dc.w	$004a,$004c,$004e,$0050

Sprite16_T:	
	dc.w	$1fff,$1fff
	dc.w	$2000,$3ffe
	dc.w	$4000,$7ffc
	dc.w	$8000,$fff8
	dc.w	$0020,$0030
	dc.w	$0040,$0060
	dc.w	$0080,$00e0
	dc.w	$0300,$03e0
	dc.w	$0200,$03e0
	dc.w	$0200,$03e0
	dc.w	$0200,$03e0
	dc.w	$0200,$03e0
	dc.w	$0200,$03c0
	dc.w	$0200,$0380
	dc.w	$0200,$0300
	dc.w	$0200,$0200

Sprite16_F:	
	dc.w	$0fff,$0fff
	dc.w	$1000,$1ffe
	dc.w	$2000,$3ffc
	dc.w	$4000,$7ff8
	dc.w	$8000,$fff0
	dc.w	$8000,$fc00
	dc.w	$83ff,$ffff
	dc.w	$8000,$fffe
	dc.w	$8000,$fffc
	dc.w	$8000,$fff8
	dc.w	$8000,$fff0
	dc.w	$8000,$f800
	dc.w	$8000,$f000
	dc.w	$8000,$e000
	dc.w	$8000,$c000
	dc.w	$8000,$8000

Sprite16_B:	
	dc.w	$fdfe,$fdfe
	dc.w	$8100,$fdff
	dc.w	$8110,$fd1f
	dc.w	$8010,$fc1f
	dc.w	$8020,$fc3e
	dc.w	$8040,$fc7c
	dc.w	$8080,$fcf8
	dc.w	$8100,$fdf0
	dc.w	$820f,$ffff
	dc.w	$8000,$ffff
	dc.w	$8010,$fc1f
	dc.w	$8010,$fc1f
	dc.w	$8020,$fc3e
	dc.w	$80c0,$fcfc
	dc.w	$8300,$fff8
	dc.w	$8000,$ffe0

Sprite32_I:
	dc.b	$18,$01,$ff,$ff,$ff,$80,$ff,$ff
	dc.b	$00,$03,$ff,$ff,$ff,$fc,$ff,$ff
	dc.b	$00,$03,$ff,$ff,$ff,$fe,$ff,$ff
	dc.b	$78,$3f,$ff,$ff,$fc,$00,$ff,$ff
	dc.b	$00,$1f,$00,$7f,$80,$00,$ff,$00
	dc.b	$00,$01,$00,$3f,$fe,$00,$fe,$00
	dc.b	$00,$00,$00,$3f,$3e,$00,$fe,$00
	dc.b	$00,$0f,$00,$3f,$fc,$00,$fe,$00
	dc.b	$00,$3f,$00,$3f,$e0,$00,$fe,$00
	dc.b	$00,$00,$00,$3f,$3e,$00,$fe,$00
	dc.b	$00,$03,$00,$3f,$fe,$00,$fe,$00
	dc.b	$00,$20,$00,$3f,$0e,$00,$fe,$00
	dc.b	$00,$20,$00,$3f,$00,$00,$fe,$00
	dc.b	$00,$00,$00,$3f,$7e,$00,$fe,$00
	dc.b	$00,$3e,$00,$3f,$fe,$00,$fe,$00
	dc.b	$00,$3f,$00,$3f,$f0,$00,$fe,$00
	dc.b	$00,$00,$00,$3f,$7e,$00,$fe,$00
	dc.b	$00,$3f,$00,$3f,$fe,$00,$fe,$00
	dc.b	$00,$3f,$00,$3f,$fe,$00,$fe,$00
	dc.b	$00,$00,$00,$3f,$fe,$00,$fe,$00
	dc.b	$00,$0f,$00,$3f,$fc,$00,$fe,$00
	dc.b	$00,$00,$00,$3f,$00,$00,$fe,$00
	dc.b	$00,$00,$00,$3f,$3e,$00,$fe,$00
	dc.b	$00,$00,$00,$3f,$00,$00,$fe,$00
	dc.b	$00,$3f,$00,$3f,$fe,$00,$fe,$00
	dc.b	$00,$3f,$00,$3f,$f8,$00,$fe,$00
	dc.b	$00,$20,$00,$3f,$00,$00,$ff,$00
	dc.b	$00,$7f,$00,$7f,$00,$00,$ff,$00
	dc.b	$60,$01,$ff,$ff,$c0,$00,$ff,$ff
	dc.b	$00,$00,$ff,$ff,$7f,$ff,$ff,$ff
	dc.b	$7c,$00,$ff,$ff,$00,$00,$ff,$ff
	dc.b	$7f,$e3,$ff,$ff,$80,$00,$ff,$ff

Sprite32_C:	
	dc.b	$00,$03,$00,$03,$f0,$00,$f0,$00
	dc.b	$00,$1c,$00,$1f,$fe,$00,$fe,$00
	dc.b	$00,$7f,$00,$7f,$e3,$80,$ff,$80
	dc.b	$00,$fe,$01,$fe,$00,$00,$1f,$e0
	dc.b	$03,$fc,$03,$fc,$0c,$00,$0f,$f0
	dc.b	$03,$fc,$07,$fc,$00,$00,$0f,$f8
	dc.b	$00,$00,$0f,$fc,$0f,$fc,$0f,$fc
	dc.b	$03,$fc,$0f,$fc,$00,$00,$0f,$fc
	dc.b	$00,$1c,$1f,$fc,$08,$00,$0f,$fe
	dc.b	$18,$00,$1f,$fc,$00,$0e,$0f,$fe
	dc.b	$00,$3c,$3f,$fc,$00,$01,$0f,$ff
	dc.b	$03,$fc,$3f,$fc,$0c,$03,$0f,$ff
	dc.b	$3f,$00,$3f,$fc,$0f,$f0,$0f,$ff
	dc.b	$00,$00,$7f,$fc,$00,$f0,$0f,$ff
	dc.b	$1f,$f8,$7f,$fc,$00,$00,$00,$00
	dc.b	$7c,$00,$7f,$fc,$00,$00,$00,$00
	dc.b	$01,$fc,$7f,$fc,$00,$00,$00,$00
	dc.b	$7f,$f4,$7f,$fc,$00,$00,$00,$00
	dc.b	$7c,$00,$7f,$fc,$00,$03,$0f,$ff
	dc.b	$00,$00,$3f,$fc,$01,$ff,$0f,$ff
	dc.b	$00,$00,$3f,$fc,$00,$00,$0f,$ff
	dc.b	$00,$1c,$3f,$fc,$01,$ff,$0f,$ff
	dc.b	$00,$3c,$1f,$fc,$00,$3e,$0f,$fe
	dc.b	$00,$00,$1f,$fc,$0f,$86,$0f,$fe
	dc.b	$00,$00,$0f,$fc,$00,$c0,$0f,$fc
	dc.b	$0f,$e0,$0f,$fc,$00,$fc,$0f,$fc
	dc.b	$07,$f0,$07,$fc,$0f,$f8,$0f,$f8
	dc.b	$00,$00,$03,$fc,$00,$00,$0f,$f0
	dc.b	$00,$7e,$01,$fe,$1f,$e0,$1f,$e0
	dc.b	$00,$00,$00,$7f,$00,$80,$ff,$80
	dc.b	$00,$00,$00,$1f,$06,$00,$fe,$00
	dc.b	$00,$03,$00,$03,$f0,$00,$f0,$00

SpriteOffsets:
	dc.w	$0010,$0080		; C
	dc.w	$0018,$0088		; I
	dc.w	$0000,$0040		; B
	dc.w	$0008,$0048		; F
	dc.w	$0010,$0050		; T

	
	BSS
 
LastKey:			ds.b	1
					even
					
SyncVBL:			ds.b	6 
SavePalette:		ds.b	32

ScrollSlice:		ds.w	1	; 32 Slices ( Byte-Scroller )
ScrollTextCurPtr:	ds.l	1 

ScreenPtrA:			ds.l	1 
ScreenPtrB:			ds.l	1 
SaveRes:			ds.w	1 

SaveScreen:			ds.l	1
SaveSP:				ds.l	1
 
BigFontExpanded:	ds.b	(BigFontExpandedWidth*16*BigFontNumChars)	; 30k

ScrollBuffer:		ds.b	(BigScrollBufferWidth*BigScrollBufferHeight)	; 640 Bytes

RasterBarPositions:	ds.b	4
	
SaveMFP:			ds.b    16

MusicPos:			ds.l	1

TileWavePtr:		ds.l	1

FadePalettePtr:		ds.l	1

RasterPtr:			ds.l	1 
RasterCount:		ds.w	1 

Rasters:			ds.w	2		; 1 .W colour per raster
RastersVisible:		ds.w	198		; (NOTE. Only using fraction of this, it's wasteful!)
	
SpriteTracePtrA:	ds.l	1
SpriteTracePtrB:	ds.l	1
	
SpriteTraces_1:		ds.l	5		; Order is: CIBFT
SpriteTraces_2:		ds.l	5

Preshift16_T:		ds.b	4096	; Preshifted 16x16 TFB sprites
Preshift16_F:		ds.b	4096
Preshift16_B:		ds.b	4096

Preshift32_I:		ds.b	12288	; Preshifted 32x32 IC sprites
Preshift32_C:		ds.b	12288 
					
SpriteSines_3:		ds.w	512

PreshiftTile_0:		ds.w	256		; Preshifted Tile. 
PreshiftTile_1:		ds.w	7936

ScreenMem:			ds.b	(32000*2)+256 
ScreenMem_End:		equ		*

ScratchArea:		equ		ScreenMem+(32000+256)

	END

