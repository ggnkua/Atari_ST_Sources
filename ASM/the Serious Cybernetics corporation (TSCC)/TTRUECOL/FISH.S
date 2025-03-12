*******************************************************************************
*
* 12 bit RGB truecolor C2P for Atari TT (1x1 version)
* ray@tscc.de 
*
* 12-30-2014 Initial revision
* 12-31-2014 Optimized c2p
* 01-02-2015 Fixes, added 2x2 version
*
* Coded using HATARI, so this is untested on the real thing.
*
* The idea is quite simple, each scanline is split into a red and a green+blue
* component which are interlaced to comprise a 12 bit RGB scanline. Actually,
* we sacrifice 16*16 of the 4096 possible colors in order to map the red
* component into colors 0..15 without visual quality loss, however.
*
* As a demonstration I am converting a 320x480 24 bit RGB picture which is
* quantized to 12 bit RGB and dithered, additionally. Each pixel in vscreen
* is 16(12) bit packed as rgb-. Keeping the 4 LSBs clear also serves as a
* preshift by 16, so each pixel can be used as an offset into the c2p table,
* directly.
*
* Fastram should be supported.
*
* Feel free to contact me if you need any more specific info.
*
*******************************************************************************

			   OPT d-,o+,ow+
			   OPT p=68030
			   COMMENT HEAD=%111
			   OUTPUT FISH.PRG

SCREENWIDTH	   EQU 320
SCREENHEIGHT   EQU 480

*******************************************************************************

				SECTION TEXT
main:			bsr.s	initialize
				bsr		generateC2P
				bsr		convertPicture
				bsr		rgbC2P1x1
				bsr		generateCLUT

.mainloop:		cmpi.b	#$39,$FFFFFC02.w
				bne.s	.mainloop

				bra		uninitialize

				
*******************************************************************************
*
* initialize
*
*******************************************************************************

initialize:		move.l	(SP)+,.saveret

				movea.l	sp,a5
				movea.l	4(a5),a5				  ; Address to basepage

				move.l	$c(a5),d0				  ; TEXT
				add.l	$14(a5),d0				  ; DATA
				add.l	$1c(a5),d0				  ; BSS
				addi.l	#$200,d0				  ; Stack

				move.l	d0,d1
				add.l	a5,d1
				bclr.l	#0,d1					  ; Even address
				movea.l	d1,sp

				move.l	d0,-(sp)
				pea.l	(a5)
				pea.l	$4a0000					  ; MShrink()
				trap	#1
				lea.l	12(sp),sp
		
; Reserve and clear screens

				clr.w	 -(SP)					  ; Mxalloc()
				move.l	 #SCREENWIDTH*SCREENHEIGHT*2+256,-(SP)
				move.w	 #$44,-(SP)
				trap	 #1
				addq.l	 #8,SP

				addi.l	 #256,D0				  ; Align
				clr.b	D0

				move.l	D0,pscreen

				movea.l D0,A0
				move.l	#SCREENWIDTH*SCREENHEIGHT,D1

.clrloop:		clr.l	(A0)+
				subq.l	#2,D1
				bne.s	.clrloop

				clr.l	-(SP)					  ; Super()
				move.w	#$20,-(SP)
				trap	#1
				addq.l	#6,SP

				lea		syssave,A0
				move.l	D0,(A0)+				  ; Save USP

; Save video/system registers

				move	#$2700,SR
				move.w	$0484.w,(A0)+
				move.l	$70.w,(A0)+
				move.w	$FFFF8260.w,(A0)+
				move.w	$FFFF8262.w,(A0)+
				move.l	$FFFF8200.w,(A0)+
				move.w	$FFFF820C.w,(A0)+

				lea		$FFFF8240.w,A1
				moveq	#8-1,D0

.stpalette:		move.l	(A1),(A0)+
				clr.l	(A1)+
				dbra	D0,.stpalette

				lea		$FFFF8400.w,A1
				moveq	#128-1,D0
				
.ttpalette:		move.l	(A1),(A0)+
				clr.l	(A1)+
				dbra	D0,.ttpalette

				clr.b	$0484.w					  ; Keyclick off
				move.w	#%111<<8,$FFFF8262.w	  ; Set 320x480x8bpp

				move.l	#vbl,$70.w
				move	#$2300,SR

				move.l	.saveret(PC),-(SP)
				rts

.saveret:		DC.L 0


*******************************************************************************
*
* uninitialize
*
*******************************************************************************

uninitialize:	lea		syssave,A2
				lea		4(A2),A0

; Restore video/system registers

				move	#$2700,SR
				move.w	(A0)+,$0484.w
				move.l	(A0)+,$70.w
				move.w	(A0)+,$FFFF8260.w
				move.w	(A0)+,$FFFF8262.w
				move.l	(A0)+,$FFFF8200.w
				move.w	(A0)+,$FFFF820C.w
				move	#$2300,SR

				lea		$FFFF8240.w,A1
				moveq	#8-1,D0
.stpalette:		move.l	(A0)+,(A1)+
				dbra	D0,.stpalette

				lea		$FFFF8400.w,A1
				moveq	#128-1,D0
.ttpalette:		move.l	(A0)+,(A1)+
				dbra	D0,.ttpalette

				move.l	(A2),-(SP)
				move.w	#$20,-(SP)
				trap	#1
				addq.l	#6,SP

				clr.w	-(SP)
				trap	#1


*******************************************************************************
*
* generateCLUT
*
*******************************************************************************

generateCLUT:	lea		$FFFF8400.w,A0
				lea		32(A0),A1

				moveq	#0,D0
.greenblue:		move.w	D0,(A0)+
				addq.b	#1,D0
				bcc.s	.greenblue

				moveq	#16-1,D0
.red:			move.w	D0,D1
				lsl.w	#8,D1
				move.w	D1,-(A1)
				dbra	D0,.red
				rts


*******************************************************************************
*
* generateC2P
*
*******************************************************************************

generateC2P		lea		c2ptable,A0
				
				moveq	#$01,D4
				moveq	#$10,D6
				
				moveq	#0,D0

.rgbtableloop:	move.w	D0,D1

				cmp.b	D6,D1		; b<=15 && g==0 -> g |= 1 (colors 0..15 -> red)
				bhs.s	.blueok
				or.b	D6,D1
				
.blueok:		moveq	#12-1,D2
.bitloop:		lsr.w	#1,D1
				scs.b	D3
				and.b	D4,D3
				move.b	D3,(A0)+
				dbra	D2,.bitloop

				clr.l	(A0)+

				addq.w	#1,D0
				cmpi.w	#$FFF,D0
				bls.s	.rgbtableloop
				rts

				
*******************************************************************************
*
* random
*
*******************************************************************************

random:			move.l	.seed(PC),D3
				rol.l	D3,D3
				addq.l	#5,D3
				move.l	D3,.seed
				rts

.seed:			DC.L 0


*******************************************************************************
*
* convertPicture
*
*******************************************************************************

convertPicture: lea		picture(PC),A0
				lea		vscreen,A1

				move.l	#SCREENWIDTH*SCREENHEIGHT-1,D0
.picloop:		moveq	#0,D1

				move.b	(A0)+,D2				  ; rr
				bsr.s	.dither
				move.b	D2,D1
				lsl.w	#4,D1

				move.b	(A0)+,D2				  ; gg
				bsr.s	.dither
				move.b	D2,D1
				lsl.w	#4,D1

				move.b	(A0)+,D2				  ; bb
				bsr.s	.dither
				move.b	D2,D1
				andi.w	#$FFF0,D1

				move.w	D1,(A1)+				  ; rgb-

				subq.l	#1,D0
				bne.s	.picloop
				rts

.dither:		bsr.s	random
				andi.b	#$0F,D3
				add.b	D3,D2
				scs		D3
				or.b	D3,D2
				rts

				
*******************************************************************************
*
* rgbC2P1x1
*
*******************************************************************************

rgbC2P1x1:		lea		vscreen,A0
				move.l	pscreen,A1
				movea.l	A1,A2
				adda.l	#SCREENWIDTH*SCREENHEIGHT,A2

				lea		c2ptable,A3

				moveq	#0,D6
				move.l	#$0F0001,D7

				move.w	#SCREENHEIGHT-1,D0

.yloop:			moveq	#SCREENWIDTH/8-1,D1

.xloop:			moveq	#0,D2
				moveq	#0,D4
				moveq	#0,D5

				moveq	#8,D3
.c2pblock:		add.l	D2,D2
				add.l	D4,D4
				add.l	D5,D5

				move.w	(A0)+,D6
				movem.l	(A3,D6.l),A4-A6
				add.l	A4,D4
				add.l	A5,D5
				add.l	A6,D2

				subq.w	#1,D3
				bne.s	.c2pblock

				movep.l D2,0(A1)	; r
				movep.l	D3,8(A1)	; -
				movep.l D4,0(A2)	; g
				movep.l D5,8(A2)	; b

				adda.w	D7,A1
				adda.w	D7,A2
				swap	D7
				dbra	D1,.xloop

				exg		A1,A2
				dbra	D0,.yloop

				rts


*******************************************************************************
*
* vbl
*
*******************************************************************************

vbl:			move.l	D0,-(SP)

				move.l	pscreen,D0
				btst.b	#0,$469.w			; Interlace
				bne.s	.odd
				addi.l	#SCREENWIDTH*SCREENHEIGHT,D0

.odd			lsr.w	#8,D0
				move.l	D0,$FFFF8200.w

				addq.l	#1,$466.w
				move.l (SP)+,D0
				rte


*******************************************************************************

			   SECTION DATA
picture:	   INCBIN 'FISH.RAW'
			   EVEN


*******************************************************************************

			   SECTION BSS
syssave:	   DS.L 1
			   DS.L 1
			   DS.W 1
			   DS.L 1
			   DS.L 1
			   DS.L 1
			   DS.W 1
			   DS.W 16
			   DS.W 256

pscreen:	   DS.L 1
c2ptable:	   DS.B 16*4096

vscreen:	   DS.W SCREENWIDTH*SCREENHEIGHT
			   END
