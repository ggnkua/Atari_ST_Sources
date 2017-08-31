	section text
TUNNEL_TX_SIZE		equ	64

TUNNEL_ANIM_SPEED	equ TUNNEL_TX_SIZE+1
TUNNEL_X_MOVE_SIZE	equ 200
TUNNEL_Y_MOVE_SIZE	equ 100

TUNNEL_X_MOVE_SIZE2	equ 200
TUNNEL_Y_MOVE_SIZE2	equ 100

tunnelInit:
	firstRunOrReturn
	bsr 	clearScreenBuffer
	move.l	ramBufferPtr,a1
	move.l	a1,tunnelTextureDataPtr

	move.w	#TUNNEL_X_MOVE_SIZE,tunnelXmoveSize
	move.w	#TUNNEL_Y_MOVE_SIZE,tunnelYmoveSize

;	cmp.w	#0,monitor
;	bne.s	_tunnelRgbInit
	; tunnel vga init
;	lea tunnelTexture,a0
;	move.l	tunnelTextureDataPtr,a1
	
;	move.l	#TUNNEL_TX_SIZE*TUNNEL_TX_SIZE-1,d7
;_tunnelTxInitVgaLoop
;	move.w	(a0),TUNNEL_TX_SIZE*TUNNEL_TX_SIZE*2(a1)
;	move.w	(a0)+,(a1)+
;	dbf	d7,_tunnelTxInitVgaLoop
	
;	bsr		video_vga_160x200x16
;	bra.s	_tunnelInitDone
;_tunnelRgbInit
	; tunnel rgb init
	lea tunnelTextureData1,a0
	move.l	tunnelTextureDataPtr,a1
	move.l	#TUNNEL_TX_SIZE*TUNNEL_TX_SIZE-1,d7
_tunnelTxInitRgbLoop
	move.w	(a0),TUNNEL_TX_SIZE*TUNNEL_TX_SIZE*4(a1)
	move.w	(a0),TUNNEL_TX_SIZE*TUNNEL_TX_SIZE*4+2(a1)

	move.w	(a0),(a1)+
	move.w	(a0)+,(a1)+
	dbf	d7,_tunnelTxInitRgbLoop

	bsr		video_rgb_320x100x16
;_tunnelInitDone	

	move.l	#0,tunnelTexturePtr
	move.l	#tunnelOffsetX1,tunnelOffsetX
	move.l	#tunnelOffsetY1,tunnelOffsetY
	
	move.w	#50,tunnelOffsetXnow
	rts

tunnelInit2:
	firstRunOrReturn
	bsr 	clearScreenBuffer
	move.l	ramBufferPtr,a1
	move.l	a1,tunnelTextureDataPtr

	move.w	#TUNNEL_X_MOVE_SIZE2,tunnelXmoveSize
	move.w	#TUNNEL_Y_MOVE_SIZE2,tunnelYmoveSize

	; tunnel rgb init
	lea tunnelTextureData2,a0
	move.l	tunnelTextureDataPtr,a1
	move.l	#TUNNEL_TX_SIZE*TUNNEL_TX_SIZE-1,d7
_tunnelTxInitRgbLoop2
	move.w	(a0),TUNNEL_TX_SIZE*TUNNEL_TX_SIZE*4(a1)
	move.w	(a0),TUNNEL_TX_SIZE*TUNNEL_TX_SIZE*4+2(a1)

	move.w	(a0),(a1)+
	move.w	(a0)+,(a1)+
	dbf	d7,_tunnelTxInitRgbLoop2

	bsr		video_rgb_320x100x16

	move.l	#0,tunnelTexturePtr
	move.l	#tunnelOffsetX1,tunnelOffsetX
	move.l	#tunnelOffsetY1,tunnelOffsetY

	rts

tunnelInit2B:
	firstRunOrReturn
	move.l	ramBufferPtr,a1
	move.l	a1,tunnelTextureDataPtr

	; tunnel rgb init
	lea tunnelTextureData2B,a0
	move.l	tunnelTextureDataPtr,a1
	move.l	#TUNNEL_TX_SIZE*TUNNEL_TX_SIZE-1,d7
_tunnelTxInitRgbLoop2B
	move.w	(a0),TUNNEL_TX_SIZE*TUNNEL_TX_SIZE*4(a1)
	move.w	(a0),TUNNEL_TX_SIZE*TUNNEL_TX_SIZE*4+2(a1)

	move.w	(a0),(a1)+
	move.w	(a0)+,(a1)+
	dbf	d7,_tunnelTxInitRgbLoop2B

	rts
	
tunnelMain:
	bsr 	switchScreens

	move.l	#tunnelOffsets,a0
	move.l	scr1,a2
	move.l	tunnelTexturePtr,d5

	move.l	tunnelOffsetX,a4
	move.w	tunnelOffsetXnow,d4
	add.l	(a4,d4.w*4),a0
	addq.w	#1,d4
	cmp.w	tunnelXmoveSize,d4
	blt.s	_tunnelOffsetXok
	moveq.w	#0,d4
_tunnelOffsetXok	
	move.w	d4,tunnelOffsetXnow

	move.l	tunnelOffsetY,a4
	move.w	tunnelOffsetYnow,d4
	add.l	(a4,d4.w*4),a0
	addq.w	#1,d4
	cmp.w	tunnelYmoveSize,d4
	blt.s	_tunnelOffsetYok
	moveq.w	#0,d4
_tunnelOffsetYok	
	move.w	d4,tunnelOffsetYnow

	moveq.l	#0,d0
	cmp.w	#0,monitor
	bne		tunnelMainRgb
	;go to vga
	
tunnelMainVga:
	;vga fx
	move.l	tunnelTextureDataPtr,a1
	add.l	d5,a1
	add.l	#4*TUNNEL_ANIM_SPEED,d5
	cmp.w	#TUNNEL_TX_SIZE*TUNNEL_TX_SIZE*2,d5
	blt.s	_tunnelNoUpdateTextureShiftVga
	sub.w	#TUNNEL_TX_SIZE*TUNNEL_TX_SIZE*2,d5		
_tunnelNoUpdateTextureShiftVga			
	move.l	d5,tunnelTexturePtr
	lea		320(a2),a3

	move.l	#100-1,d6
_tunnelVgaLoop1
	move.l	#160/20-1,d7
_tunnelVgaLoop2
	rept 20/5
	movem.w (a0)+,d0-d4
	
	move.w (a1,d0.l),d5
	move.w d5,(a2)+
	move.w d5,(a3)+
	
	move.w (a1,d1.l),d5
	move.w d5,(a2)+
	move.w d5,(a3)+

	move.w (a1,d2.l),d5
	move.w d5,(a2)+
	move.w d5,(a3)+

	move.w (a1,d3.l),d5
	move.w d5,(a2)+
	move.w d5,(a3)+
	
	move.w (a1,d4.l),d5
	move.w d5,(a2)+
	move.w d5,(a3)+
	endr
	dbf d7,_tunnelVgaLoop2
	lea	160(a0),a0
	lea	320(a2),a2
	lea	320(a3),a3
	dbf d6,_tunnelVgaLoop1

	rts
	
	
tunnelMainRgb:
	;rgb fx
	move.l	tunnelTextureDataPtr,a1
	add.l	d5,a1
	add.l	#2*4*TUNNEL_ANIM_SPEED,d5
	cmp.w	#TUNNEL_TX_SIZE*TUNNEL_TX_SIZE*2*2,d5
	blt.s	_tunnelNoUpdateTextureShiftRgb
	sub.w	#TUNNEL_TX_SIZE*TUNNEL_TX_SIZE*2*2,d5		
_tunnelNoUpdateTextureShiftRgb			
	move.l	d5,tunnelTexturePtr

	move.l	#100-1,d6
_tunnelRgbLoop1
	move.l	#4-1,d7
_tunnelRgbLoop2
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
	dbf d7,_tunnelRgbLoop2
	lea	160(a0),a0
	dbf d6,_tunnelRgbLoop1	

	rts

tunnelMain2:
	bsr 	tunnelInit2B
	bsr 	switchScreens

	move.l	#tunnelOffsets,a0
	move.l	scr1,a2
	move.l	tunnelTexturePtr,d5

	move.l	tunnelOffsetX,a4
	move.w	tunnelOffsetXnow,d4
	add.l	(a4,d4.w*4),a0
	subq.w	#1,d4
	cmp.w	#0,d4
	bge.s	_tunnelOffsetXok2
	move.w	tunnelXmoveSize,d4
	sub.w	#1,d4
_tunnelOffsetXok2	
	move.w	d4,tunnelOffsetXnow

	move.l	tunnelOffsetY,a4
	move.w	tunnelOffsetYnow,d4
	add.l	(a4,d4.w*4),a0
	sub.w	#1,d4
	cmp.w	#0,d4
	bgt.s	_tunnelOffsetYok2
	move.w	tunnelYmoveSize,d4
	sub.w	#1,d4
_tunnelOffsetYok2	
	move.w	d4,tunnelOffsetYnow

	;rgb fx
	move.l	tunnelTextureDataPtr,a1
	add.l	d5,a1
	add.l	#2*4*TUNNEL_ANIM_SPEED,d5
	;sub.l	#2*4*TUNNEL_ANIM_SPEED,d5
	cmp.w	#TUNNEL_TX_SIZE*TUNNEL_TX_SIZE*2*2,d5
	;cmp.l	#0,d5
	;bge.s	_tunnelNoUpdateTextureShiftRgb2
	blt.s	_tunnelNoUpdateTextureShiftRgb2
	sub.l	#TUNNEL_TX_SIZE*TUNNEL_TX_SIZE*2*2,d5
	;sub.l	#TUNNEL_TX_SIZE*2*2,d5	
_tunnelNoUpdateTextureShiftRgb2			
	move.l	d5,tunnelTexturePtr

	move.l	#100-1,d6
_tunnelRgbLoop1_2
	move.l	#4-1,d7
_tunnelRgbLoop2_2
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
	dbf d7,_tunnelRgbLoop2_2
	lea	160(a0),a0
	dbf d6,_tunnelRgbLoop1_2	

	rts
		
	section data
	cnop 0,4
tunnelOffsetX1 dc.l 80,82,84,86,90,92,94,96,98,102,104,106,108,110,114,116,118,120,122,124,126,128,130,132,134,136,138,140,140,142,144,146,146,148,150,150,152,152,154,154,156,156,156,158,158,158,158,158,158,158,160,158,158,158,158,158,158,158,156,156,156,154,154,152,152,150,150,148,146,146,144,142,140,140,138,136,134,132,130,128,126,124,122,120,118,116,114,110,108,106,104,102,98,96,94,92,90,86,84,82,80,78,76,74,70,68,66,64,62,58,56,54,52,50,46,44,42,40,38,36,34,32,30,28,26,24,22,20,20,18,16,14,14,12,10,10,8,8,6,6,4,4,4,2,2,2,2,2,2,2,0,2,2,2,2,2,2,2,4,4,4,6,6,8,8,10,10,12,14,14,16,18,20,20,22,24,26,28,30,32,34,36,38,40,42,44,46,50,52,54,56,58,62,64,66,68,70,74,76,78
	cnop 0,4
tunnelOffsetY1 dc.l 12000,12480,13440,13920,14880,15360,16320,16800,17760,18240,18720,19200,20160,20640,21120,21600,22080,22080,22560,23040,23040,23520,23520,23520,23520,24000,23520,23520,23520,23520,23040,23040,22560,22080,22080,21600,21120,20640,20160,19200,18720,18240,17760,16800,16320,15360,14880,13920,13440,12480,12000,11520,10560,10080,9120,8640,7680,7200,6240,5760,5280,4800,3840,3360,2880,2400,1920,1920,1440,960,960,480,480,480,480,0,480,480,480,480,960,960,1440,1920,1920,2400,2880,3360,3840,4800,5280,5760,6240,7200,7680,8640,9120,10080,10560,11520
	cnop 0,4
tunnelOffsets	include 'tunnel/offsets.s'
	cnop 0,4
;tunnelTexture 	incbin 'tunnel/texture3.dat'
;tunnelTexture 	incbin 'tunnel/at_02.dat'
;tunnelTexture 	incbin 'tunnel/at_06.dat'
;tunnelTexture 	incbin 'tunnel/at_13.dat'
;tunnelTexture 	incbin 'tunnel/at_03.dat'
tunnelTextureData1 	incbin 'tunnel/sxb1.dat'
tunnelTextureData2 	incbin 'tunnel/str9.dat'
tunnelTextureData2B	incbin 'tunnel/str94.dat'

	section bss
	even
tunnelTextureDataPtr	dc.l	0 ; size TUNNEL_TX_SIZE*TUNNEL_TX_SIZE*8
tunnelOffsetX		dc.l	0
tunnelOffsetY		dc.l	0
tunnelOffsetXnow	dc.w	0
tunnelOffsetYnow	dc.w	0
tunnelTexturePtr	dc.l	0
tunnelXmoveSize		dc.w	0
tunnelYmoveSize		dc.w	0
	section text
