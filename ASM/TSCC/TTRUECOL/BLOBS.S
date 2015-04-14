*******************************************************************************
*
* 12 bit RGB truecolor C2P for Atari TT (2x2 version)
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
* As a demonstration I am drawing 3 moving blobs (red, green and blue). Each
* pixel in vscreen is 16(12) bit packed as rgb-. Keeping the 4 LSBs clear also
* serves as a preshift by 16, so each pixel can be used as an offset into the
* c2p tables directly.
*
* Fastram should be supported.
*
* Feel free to contact me if you need any more specific info.
*
*******************************************************************************

				OPT	d-,o+,ow+
				OPT	p=68030/68882
				COMMENT	HEAD=%111
				OUTPUT	BLOBS.PRG

SCREENWIDTH		EQU	320
SCREENHEIGHT	EQU	480

VSCREENWIDTH	EQU	160
VSCREENHEIGHT	EQU	100

BLOBSIZE		EQU	48


*******************************************************************************

				SECTION TEXT
main:			bsr.w	initialize
				bsr		generateC2P
				bsr		generateBlobs
				bsr		generateCLUT

.mainloop:		bsr		clearScreen
				bsr		drawBlobs
				bsr		rgbC2P2x2
				bsr		cycleScreens

				cmpi.b	#$39,$FFFFFC02.w
				bne.w	.mainloop

				bra		uninitialize


*******************************************************************************
*
* initialize
*
*******************************************************************************

initialize:		move.l	(SP)+,.saveret

				movea.l	sp,a5
				movea.l	4(a5),a5				; Address to basepage

				move.l	$c(a5),d0				; TEXT
				add.l	$14(a5),d0				; DATA
				add.l	$1c(a5),d0				; BSS
				addi.l	#$200,d0				; Stack

				move.l	d0,d1
				add.l	a5,d1
				bclr.l	#0,d1					; Even address
				movea.l	d1,sp

				move.l	d0,-(sp)
				pea.l	(a5)
				pea.l	$4a0000					; MShrink()
				trap	#1
				lea.l	12(sp),sp
		
; Reserve and clear 3 screens

				clr.w	 -(SP)					; Mxalloc()
				move.l	 #SCREENWIDTH*SCREENHEIGHT*2*3+256,-(SP)
				move.w	 #$44,-(SP)
				trap	 #1
				addq.l	 #8,SP

				addi.l	 #256,D0				; Align
				clr.b	D0

				lea		pscreens,A0
				move.l	#SCREENWIDTH*SCREENHEIGHT*2,D1
				move.l	D0,(A0)+
				add.l	D1,D0
				move.l	D0,(A0)+
				add.l	D1,D0
				move.l	D0,(A0)+

				movea.l	pscreens,A0
.clrloop:		
				REPT	3
				clr.l	(A0)+
				ENDR
				subq.l	#2,D1
				bne.s	.clrloop

				clr.l	-(SP)					; Super()
				move.w	#$20,-(SP)
				trap	#1
				addq.l	#6,SP

				lea		syssave,A0
				move.l	D0,(A0)+				; Save USP

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

				clr.b	$0484.w					; Keyclick off
				move.w	#%111<<8,$FFFF8262.w	; Set 320x480x8bpp

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

generateC2P:	lea		c2ptable,A0
				
				move.b	#%11000000,D4

				moveq	#$10,D6
				
				moveq	#4-1,D5
				
.preshiftloop:	moveq	#0,D0

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

				lsr.b	#2,D4
				dbra	D5,.preshiftloop

				rts

				
*******************************************************************************
*
* random
*
*******************************************************************************

random:			move.l	.seed(PC),D7
				rol.l	D7,D7
				addq.l	#5,D7
				move.l	D7,.seed
				rts

.seed:			DC.L 0


*******************************************************************************
*
* generateBlobs
*
*******************************************************************************

generateBlobs:	lea		rblob,A0
				lea		gblob,A1
				lea		bblob,A2
		
				move.w	#BLOBSIZE*BLOBSIZE/4,D4
				moveq	#BLOBSIZE/2,D5

				moveq	#BLOBSIZE-1,D0

.yloop:			moveq	#BLOBSIZE-1,D1

.xloop:			move.w	D0,D2
				move.w	D1,D3
				sub.w	D5,D2
				sub.w	D5,D3
				muls.w	D2,D2
				muls.w	D3,D3
				add.l	D2,D3
				
				move.l	D4,D6
				sub.l	D3,D6
				bpl.s	.ok
				moveq.l	#0,D6

.ok:			mulu.w	#15<<8/(BLOBSIZE*BLOBSIZE/4),D6
				bsr.w	random
				and.l	#$FF,D7
				add.l	D7,D6
				lsr.l	#8,D6
				cmpi.w	#$F,D6
				bls.s	.ok2
				moveq.l	#$F,D6
				
.ok2:			lsl.w	#4,D6
				move.w	D6,(A2)+		; b
				lsl.w	#4,D6
				move.w	D6,(A1)+		; g
				lsl.w	#4,D6
				move.w	D6,(A0)+		; r
				
				dbra	D1,.xloop

				dbra	D0,.yloop
				rts


*******************************************************************************
*
* clearScreen
*
*******************************************************************************

clearScreen:	lea.l	vscreen+2*VSCREENWIDTH*VSCREENHEIGHT,a0

				moveq	#0,d1
				moveq	#0,d2
				moveq	#0,d3
				moveq	#0,d4
				moveq	#0,d5
				moveq	#0,d6
				moveq	#0,d7
				suba.l	a1,a1
				
				move.w	#VSCREENWIDTH*VSCREENHEIGHT*2/128-1,d0
.clrloop:		
				REPT	4
				movem.l	d1-d7/a1,-(a0)
				ENDR
				dbra	d0,.clrloop

				rts

				
*******************************************************************************
*
* drawBlobs
*
*******************************************************************************

drawBlobs:		lea		rblob,A0
				lea		gblob,A1
				lea		bblob,A2

				fmove.l	$466.w,FP0		; _framecount
				
				fmove.x	#0.031415926,FP1
				fmul.x	FP0,FP1
				fsin.x	FP1,FP2
				fadd.x	#0.2,FP1
				fcos.x	FP1,FP1
				fmul.w	#VSCREENWIDTH/10,FP1
				fmul.w	#VSCREENHEIGHT/10,FP2
				fadd.w	#(VSCREENWIDTH-BLOBSIZE)/2,FP1
				fadd.w	#(VSCREENHEIGHT-BLOBSIZE)/2,FP2
				fmove.w	FP2,D0
				mulu.w	#VSCREENWIDTH,D0
				fmove.l	FP1,D1
				add.l	D1,D0
				lea		vscreen,A3
				lea		(A3,D0.L*2),A3

				fmove.x	#-0.0231415926,FP1
				fmul.x	FP0,FP1
				fadd.x	#0.02,FP1
				fsin.x	FP1,FP2
				fadd.x	#-0.2,FP1
				fmul.x	#0.6,FP1
				fcos.x	FP1,FP1
				fmul.w	#VSCREENWIDTH/10,FP1
				fmul.w	#VSCREENHEIGHT/10,FP2
				fadd.w	#(VSCREENWIDTH-BLOBSIZE)/2,FP1
				fadd.w	#(VSCREENHEIGHT-BLOBSIZE)/2,FP2
				fmove.w	FP2,D0
				mulu.w	#VSCREENWIDTH,D0
				fmove.l	FP1,D1
				add.l	D1,D0
				lea		vscreen,A4
				lea		(A4,D0.L*2),A4

				fmove.x	#0.0431415926,FP1
				fmul.x	FP0,FP1
				fadd.x	#0.2,FP1
				fsin.x	FP1,FP2
				fadd.x	#0.4,FP1
				fmul.x	#0.3,FP1
				fcos.x	FP1,FP1
				fmul.w	#VSCREENWIDTH/10,FP1
				fmul.w	#VSCREENHEIGHT/10,FP2
				fadd.w	#(VSCREENWIDTH-BLOBSIZE)/2,FP1
				fadd.w	#(VSCREENHEIGHT-BLOBSIZE)/2,FP2
				fmove.w	FP2,D0
				mulu.w	#VSCREENWIDTH,D0
				fmove.l	FP1,D1
				add.l	D1,D0
				lea		vscreen,A5
				lea		(A5,D0.L*2),A5


				lea		(VSCREENWIDTH-BLOBSIZE)*2.w,A6
				
				moveq	#BLOBSIZE-1,D0
.yloop:			moveq	#BLOBSIZE/8-1,D1

.xloop:			movem.l	(A0)+,D2-D5
				or.l	D2,(A5)+
				or.l	D3,(A5)+
				or.l	D4,(A5)+
				or.l	D5,(A5)+
				
				movem.l	(A1)+,D2-D5
				or.l	D2,(A3)+
				or.l	D3,(A3)+
				or.l	D4,(A3)+
				or.l	D5,(A3)+
				
				movem.l	(A2)+,D2-D5
				or.l	D2,(A4)+
				or.l	D3,(A4)+
				or.l	D4,(A4)+
				or.l	D5,(A4)+
				
				dbra	D1,.xloop
				
				adda.l	A6,A3
				adda.l	A6,A4
				adda.l	A6,A5
				dbra	D0,.yloop
				rts

.counter:		dc.w	0

				
*******************************************************************************
*
* rgbC2P2x2
*
*******************************************************************************

rgbC2P2x2:		lea		vscreen,A0
				move.l	pscreens+2*4,A1
				movea.l	A1,A2
				adda.l	#SCREENWIDTH*SCREENHEIGHT,A2
				
				move.l	#(SCREENHEIGHT-VSCREENHEIGHT*2)/2*SCREENWIDTH,D0
				adda.l	D0,A1
				adda.l	D0,A2

				lea		c2ptable,A3

				move.l	#$0F0001,D7

				move.w	#VSCREENHEIGHT-1,D0

.yloop:			moveq	#VSCREENWIDTH/4-1,D1

.xloop:			moveq	#0,D2
				moveq	#0,D4
				moveq	#0,D5

				moveq	#0,D6
				moveq	#1,D3
				swap	D3

				REPT	3
				move.w	(A0)+,D6
				movem.l	(A3,D6.l),A4-A6
				add.l	A4,D4
				add.l	A5,D5
				add.l	A6,D2
				add.l	D3,D6
				ENDR

				move.w	(A0)+,D6
				movem.l	(A3,D6.l),A4-A6
				add.l	A4,D4
				add.l	A5,D5
				add.l	A6,D2
				moveq.l	#0,D3

				movep.l D2,0(A1)	; r
				movep.l	D3,8(A1)	; -
				movep.l D4,0(A2)	; g
				movep.l D5,8(A2)	; b

				adda.w	D7,A1
				adda.w	D7,A2
				swap	D7
				dbra	D1,.xloop

				lea		-SCREENWIDTH(A1),A4
				lea		-SCREENWIDTH(A2),A5
				lea		20.w,A6
				
				moveq	#SCREENWIDTH/20-1,D1
.linedouble:	movem.l	(A4)+,D2-D6
				movem.l	D2-D6,(A2)
				movem.l	(A5)+,D2-D6
				movem.l	D2-D6,(A1)
				adda.l	A6,A1
				adda.l	A6,A2
				dbra	D1,.linedouble

				dbra	D0,.yloop

				rts


*******************************************************************************
*
* cycleScreens
*
*******************************************************************************

cycleScreens:	movem.l pscreens,D0-D2
				exg		D1,D2
				exg		D0,D1
				movem.l D0-D2,pscreens
				rts


*******************************************************************************
*
* vbl
*
*******************************************************************************

vbl:			move.l	D0,-(SP)

				move.l	pscreens,D0
				btst.b	#0,$469.w			; Interlace
				bne.s	.odd
				addi.l	#SCREENWIDTH*SCREENHEIGHT,D0

.odd			lsr.w	#8,D0
				move.l	D0,$FFFF8200.w

				addq.l	#1,$466.w
				move.l (SP)+,D0
				rte


*******************************************************************************

				SECTION BSS
syssave:		DS.L 1
				DS.L 1
				DS.W 1
				DS.L 1
				DS.L 1
				DS.L 1
				DS.W 1
				DS.W 16
				DS.W 256

pscreens:		DS.L 3
c2ptable:		DS.B 4*16*4096

rblob:			DS.W BLOBSIZE*BLOBSIZE
gblob:			DS.W BLOBSIZE*BLOBSIZE
bblob:			DS.W BLOBSIZE*BLOBSIZE

vscreen:		DS.W VSCREENWIDTH*VSCREENHEIGHT
				END
