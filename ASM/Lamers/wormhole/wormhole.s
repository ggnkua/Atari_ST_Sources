	section text
WORMHOLE_TX_SIZE		equ	64

WORMHOLE_ANIM_SPEED	equ WORMHOLE_TX_SIZE+1

wormholeInit:
	firstRunOrReturn
	bsr 	clearScreenBuffer
	move.l	ramBufferPtr,a1
	move.l	a1,wormholeTextureDataPtr

_wormholeRgbInit
	; wormhole rgb init
	lea wormholeTexture,a0
	move.l	wormholeTextureDataPtr,a1
	move.l	#WORMHOLE_TX_SIZE*WORMHOLE_TX_SIZE-1,d7
_wormholeTxInitRgbLoop
	move.w	(a0),WORMHOLE_TX_SIZE*WORMHOLE_TX_SIZE*4(a1)
	move.w	(a0),WORMHOLE_TX_SIZE*WORMHOLE_TX_SIZE*4+2(a1)

	move.w	(a0),(a1)+
	move.w	(a0)+,(a1)+
	dbf	d7,_wormholeTxInitRgbLoop

	bsr		video_rgb_320x100x16
_wormholeInitDone	

	move.l	#0,wormholeTexturePtr
	rts
	
wormholeMain:
	;bsr	waitVSync
	bsr 	switchScreens

	move.l	#wormholeOffsets,a0
	move.l	scr1,a2
	move.l	wormholeTexturePtr,d5

	;rgb fx
	move.l	wormholeTextureDataPtr,a1
	add.l	d5,a1
	add.l	#2*4*WORMHOLE_ANIM_SPEED,d5
	cmp.w	#WORMHOLE_TX_SIZE*WORMHOLE_TX_SIZE*2*2,d5
	blt.s	_wormholeNoUpdateTextureShiftRgb
	sub.w	#WORMHOLE_TX_SIZE*WORMHOLE_TX_SIZE*2*2,d5		
_wormholeNoUpdateTextureShiftRgb			
	move.l	d5,wormholeTexturePtr

	lea	80+25*480(a0),a0

	move.l	#100-1,d6
_wormholeRgbLoop1
	move.l	#4-1,d7
_wormholeRgbLoop2
	rept 4
	movem.w (a0)+,d0-d5/a3-a6
	move.l (a1,d0.l*2),(a2)+
	move.l (a1,d1.l*2),(a2)+
	move.l (a1,d2.l*2),(a2)+
	move.l (a1,d3.l*2),(a2)+
	move.l (a1,d4.l*2),(a2)+

	move.l (a1,d5.l*2),(a2)+
	move.l (a1,a3.l*2),(a2)+
	move.l (a1,a4.l*2),(a2)+
	move.l (a1,a5.l*2),(a2)+
	move.l (a1,a6.l*2),(a2)+
	endr
	dbf d7,_wormholeRgbLoop2
	lea	160(a0),a0
	dbf d6,_wormholeRgbLoop1	

	rts
		
	section data
	cnop 0,4
wormholeOffsets	include 'wormhole/offsets.s'
	cnop 0,4
;wormholeTexture 	incbin 'wormhole/sxb1.dat'
;wormholeTexture 	incbin 'wormhole/texture3.dat'
;wormholeTexture 	incbin 'wormhole/at_04.dat'
wormholeTexture 	incbin 'wormhole/at_05.dat'
;wormholeTexture 	incbin 'wormhole/at_06.dat'
;wormholeTexture 	incbin 'wormhole/at_07.dat'
;wormholeTexture 	incbin 'wormhole/at_08.dat'

	section bss
	even
wormholeTextureDataPtr	dc.l	0 ; size WORMHOLE_TX_SIZE*WORMHOLE_TX_SIZE*8
wormholeTexturePtr	dc.l	0
	section text
