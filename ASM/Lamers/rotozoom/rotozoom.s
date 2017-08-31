	section text

ROTOZOOM_TX_H_SIZE		equ	128
ROTOZOOM_TX_V_SIZE		equ	128

ROTOZOOM_SCR_H_SIZE		equ	160
ROTOZOOM_SCR_V_SIZE		equ	100

ROTOZOOM_MIN	equ	32
ROTOZOOM_MAX	equ	800

ROTOZOOM_STEP	equ 5

rotozoomInit:
	firstRunOrReturn
	bsr 	clearScreenBuffer3
	bsr 	clearScreenBuffer2
	bsr 	clearScreenBuffer1

	move.l	#rotozoomTexture,rotozoomTextureIn
	bsr	rotozoomInitIInner
	rts

rotozoomInit2:
	firstRunOrReturn
	bsr 	clearScreenBuffer3
	bsr 	clearScreenBuffer1

	move.l	#rotozoomTexture2,rotozoomTextureIn
	bsr	rotozoomInitIInner
	rts
	
rotozoomInitIInner:

	move.w	#ROTOZOOM_MAX/2,rotozoomZoom
	move.w	#ROTOZOOM_STEP,rotozoomStep
	
	move.l	ramBufferPtr,a1
	move.l	a1,rotozoomOffsetsXPtr
	add.l	#ROTOZOOM_SCR_H_SIZE*2,a1
	move.l	a1,rotozoomOffsetsYPtr
	add.l	#ROTOZOOM_SCR_V_SIZE*2,a1

	add.l	#256*256,a1	; align
	sub.w	a1,a1
	
	move.l	a1,a2
	add.l	#ROTOZOOM_TX_H_SIZE*ROTOZOOM_TX_V_SIZE*2*2,a2

	move.l	a2,a3
	add.l	#ROTOZOOM_TX_H_SIZE*ROTOZOOM_TX_V_SIZE*2*2,a3

	move.l	a3,a4
	add.l	#ROTOZOOM_TX_H_SIZE*ROTOZOOM_TX_V_SIZE*2*2,a4

	move.l	a4,a5
	add.l	#ROTOZOOM_TX_H_SIZE*ROTOZOOM_TX_V_SIZE*2*2,a5

	move.l	a5,a0
	add.l	#ROTOZOOM_TX_H_SIZE*ROTOZOOM_TX_V_SIZE*2*2,a0


	move.l	a4,rotozoomTexturePtr

	;lea		rotozoomTexture,a6
	move.l		rotozoomTextureIn,a6
	move.l	#ROTOZOOM_TX_H_SIZE*ROTOZOOM_TX_V_SIZE-1,d7
_zoomCopy1	
	move.w	(a6)+,d0
	move.w	d0,(a1)+
	move.w	d0,(a1)+
	move.w	d0,(a2)+
	move.w	d0,(a2)+
	move.w	d0,(a3)+
	move.w	d0,(a3)+	
	move.w	d0,(a4)+
	move.w	d0,(a4)+		
	move.w	d0,(a5)+
	move.w	d0,(a5)+			
	move.w	d0,(a0)+
	move.w	d0,(a0)+			

	dbf 	d7,_zoomCopy1

	cmp.w	#0,monitor
	bne.s	_rotozoomRgbInit
	; vga init

	bsr		video_vga_160x200x16
	bra.s	_rotozoomInitDone

_rotozoomRgbInit
	; rgb init

	bsr		video_rgb_320x100x16
_rotozoomInitDone
	rts

	
rotozoomMain:
	;bsr	waitVSync
	bsr 	switchScreens

	moveq.l	#0,d0
	cmp.w	#0,monitor
	bne		rotozoomMainRgb
	;go to vga
	
rotozoomMainVga:
	;vga fx
	rts

rotozoomMainRgb:
	;rgb fx
	
	move.w	rotozoomStep,d7
	add.w	d7,rotozoomZoom
	move.w	rotozoomZoom,d6

	cmp.w	#ROTOZOOM_MAX,d6
	blt.s	_rotoZoomScale1
	neg.w	rotozoomStep
_rotoZoomScale1	

	cmp.w	#ROTOZOOM_MIN,d6
	bge.s	_rotoZoomScale2
	neg.w	rotozoomStep
_rotoZoomScale2	
	ext.l	d6

	;A
	moveq.l	#0,d0
	moveq.l	#0,d1	
	;B
	move.w	d6,d2
	moveq.l	#0,d3	
	;C
	moveq.l	#0,d4
	move.w	d6,d5

	lea		rotozoomPointsIn(pc),a5
	lea		rotozoomPointsOut(pc),a6
	movem.w	d0-d5,(a5)
	bsr	rotPointZ
	lea		rotozoomPointsOut(pc),a6
	movem.l	(a6),d0-d5

	move.l	scr1,a0
	move.l	rotozoomTexturePtr,a1
	
	;AB
	sub.l	d0,d2	
	sub.l	d1,d3
	
	;AC	
	sub.l	d0,d4	
	sub.l	d1,d5

	; calc x step
	move.w	#0,d3
	swap	d3
	add.l	d3,d3					;	dxdy	____YYyy	(step*2) 
	asr.l	#6,d2					;	dxdx	__XXxxxx	(step*2)

	; start point
	; d0  			A X  __XX ____
	; d1  			A Y  ____ YY__
	asr.l	#8,d0
	move.w	#0,d1
	swap	d1

	; backup start point
	movem.l	d0/d1/d4/d5,-(a7)
	
	; 1
	lea	_rotozoomRgbLoop2_1+2,a6
	move.l	#53-1,d7
_rotozoomRgbCalcXLoop
	; add x deltas
	add.l	d2,d0
	add.w	d3,d1
	
	move.l	d0,d4
	swap	d4
	move.w	d1,d5
	move.b	d4,d5
	add.w	d5,d5

	move.w	d5,(a6)
	addq.l	#4,a6
	dbf d7,_rotozoomRgbCalcXLoop

	; 2
	lea	_rotozoomRgbLoop2_2+2,a6
	move.l	#53-1,d7
_rotozoomRgbCalcXLoop2
	; add x deltas
	add.l	d2,d0
	add.w	d3,d1
	
	move.l	d0,d4
	swap	d4
	move.w	d1,d5
	move.b	d4,d5
	add.w	d5,d5

	move.w	d5,(a6)
	addq.l	#4,a6
	dbf d7,_rotozoomRgbCalcXLoop2

	; 3
	lea	_rotozoomRgbLoop2_3+2,a6
	move.l	#54-1,d7
_rotozoomRgbCalcXLoop3
	; add x deltas
	add.l	d2,d0
	add.w	d3,d1
	
	move.l	d0,d4
	swap	d4
	move.w	d1,d5
	move.b	d4,d5
	add.w	d5,d5

	move.w	d5,(a6)
	addq.l	#4,a6
	dbf d7,_rotozoomRgbCalcXLoop3

	; restore start point
	movem.l	(a7)+,d0/d1/d4/d5

	move.w	#0,d5
	swap	d5
	add.l	d5,d5					;	dydy	____YYyy	(step*2) 
	asr.l	#6,d4					;	dydx	__XXxxxx	(step*2)

	moveq.l	#0,d6
	move.l	rotozoomOffsetsYPtr,a3
	move.l	#ROTOZOOM_SCR_V_SIZE-1,d7
_rotozoomRgbCalcYLoop
	; add y deltas
	add.l	d4,d0
	add.w	d5,d1
	
	move.l	d0,d2
	swap	d2
	move.w	d1,d3
	move.b	d2,d3
	add.w	d3,d3
	move.w	d3,a6
	sub.w	d6,d3
	move.w	d3,(a3)+
	move.w	a6,d6
	dbf d7,_rotozoomRgbCalcYLoop
	lea		-ROTOZOOM_SCR_V_SIZE*2(a3),a3

	moveq.l	#0,d0
	; backup texture ptr
	move.l	a1,a6

	; render 1
	move.l	#ROTOZOOM_SCR_V_SIZE-1,d7
_rotozoomRgbLoop1_1
	; add y deltas
	add.w	(a3)+,a1
_rotozoomRgbLoop2_1
	rept	53
	move.l	0(a1),(a0)+
	endr
	lea		160*4-53*4(a0),a0
	dbf d7,_rotozoomRgbLoop1_1	
	lea		-ROTOZOOM_SCR_V_SIZE*2(a3),a3
	lea		-640*100+53*4(a0),a0

	; render 2
	move.l	a6,a1
	move.l	rotozoomOffsetsYPtr,a3
	move.l	#ROTOZOOM_SCR_V_SIZE-1,d7
_rotozoomRgbLoop1_2
	; add y deltas
	add.w	(a3)+,a1
_rotozoomRgbLoop2_2
	rept	53
	move.l	0(a1),(a0)+
	endr
	lea		160*4-53*4(a0),a0
	dbf d7,_rotozoomRgbLoop1_2	
	lea		-ROTOZOOM_SCR_V_SIZE*2(a3),a3
	lea		-640*100+53*4(a0),a0
	
	; render 3
	move.l	a6,a1
	move.l	rotozoomOffsetsYPtr,a3
	move.l	#ROTOZOOM_SCR_V_SIZE-1,d7
_rotozoomRgbLoop1_3
	; add y deltas
	add.w	(a3)+,a1	
_rotozoomRgbLoop2_3
	rept	54
	move.l	0(a1),(a0)+
	endr
	lea		160*4-54*4(a0),a0
	dbf d7,_rotozoomRgbLoop1_3	

	rts

;new x := x*cos(phi) - y*sin(phi)
;new y := x*sin(phi) + y*cos(phi)
rotPointZ:
		lea		rotozoomSin,a0
		lea		rotozoomCos,a1

		move.w	rotozoomAngle,d2 ; angle!
		
		move.w	(a0,d2.w*2),d5	;	sin
		move.w	(a1,d2.w*2),d6	;	cos

		addq.b	#1,d2	; update angle
		move.w	d2,rotozoomAngle

		moveq.l	#3-1,d7
_rotPointsLoop
		move.w	(a5)+,d0
		move.w	(a5)+,d1

		; x*cos
		move.w	d6,d2	; cos	
		muls.w	d0,d2	; x*cos	d2.l	

		; y*sin
		move.w	d5,d3	; sin
		muls.w	d1,d3	; y*sin	d3.l

		; new x
		sub.l	d3,d2
		move.l	d2,(a6)+			

		; x*sin
		muls.w	d5,d0	; x*sin	d0.l

		; y*cos
		muls.w	d6,d1	; y*cos d1.l

		; new y
		add.l	d0,d1
		move.l	d1,(a6)+	
		dbf d7,_rotPointsLoop
				
		rts
		
	section data
	cnop 0,4
rotozoomTexture
			;incbin 'rotozoom/sxb2.dat'
			incbin 'rotozoom/mineta.dat'
	cnop 0,4
rotozoomTexture2
			;incbin 'rotozoom/zoomrot_atari.dat'
			incbin 'rotozoom/euro.dat'

	cnop 0,4
rotozoomCos			equ rotozoomSin+64*2
rotozoomSin			dc.w 0,804,1607,2410,3211,4011,4807,5601,6392,7179,7961,8739,9511,10278,11038,11792,12539,13278,14009,14732,15446,16150,16845,17530,18204,18867,19519,20159,20787,21402,22004,22594,23169,23731,24278,24811,25329,25831,26318,26789,27244,27683,28105,28510,28897,29268,29621,29955,30272,30571,30851,31113,31356,31580,31785,31970,32137,32284,32412,32520,32609,32678,32727,32757,32767,32757,32727,32678,32609,32520,32412,32284,32137,31970,31785,31580,31356,31113,30851,30571,30272,29955,29621,29268,28897,28510,28105,27683,27244,26789,26318,25831,25329,24811,24278,23731,23169,22594,22004,21402,20787,20159,19519,18867,18204,17530,16845,16150,15446,14732,14009,13278,12539,11792,11038,10278,9511,8739,7961,7179,6392,5601,4807,4011,3211,2410,1607,804,0,-804,-1607,-2410,-3211,-4011,-4807,-5601,-6392,-7179,-7961,-8739,-9511,-10278,-11038,-11792,-12539,-13278,-14009,-14732,-15446,-16150,-16845,-17530,-18204,-18867,-19519,-20159,-20787,-21402,-22004,-22594,-23169,-23731,-24278,-24811,-25329,-25831,-26318,-26789,-27244,-27683,-28105,-28510,-28897,-29268,-29621,-29955,-30272,-30571,-30851,-31113,-31356,-31580,-31785,-31970,-32137,-32284,-32412,-32520,-32609,-32678,-32727,-32757,-32767,-32757,-32727,-32678,-32609,-32520,-32412,-32284,-32137,-31970,-31785,-31580,-31356,-31113,-30851,-30571,-30272,-29955,-29621,-29268,-28897,-28510,-28105,-27683,-27244,-26789,-26318,-25831,-25329,-24811,-24278,-23731,-23169,-22594,-22004,-21402,-20787,-20159,-19519,-18867,-18204,-17530,-16845,-16150,-15446,-14732,-14009,-13278,-12539,-11792,-11038,-10278,-9511,-8739,-7961,-7179,-6392,-5601,-4807,-4011,-3211,-2410,-1607,-804,0,804,1607,2410,3211,4011,4807,5601,6392,7179,7961,8739,9511,10278,11038,11792,12539,13278,14009,14732,15446,16150,16845,17530,18204,18867,19519,20159,20787,21402,22004,22594,23169,23731,24278,24811,25329,25831,26318,26789,27244,27683,28105,28510,28897,29268,29621,29955,30272,30571,30851,31113,31356,31580,31785,31970,32137,32284,32412,32520,32609,32678,32727,32757
	even
	section bss
rotozoomOffsetsXPtr	ds.w 	ROTOZOOM_SCR_H_SIZE
rotozoomOffsetsYPtr	ds.w 	ROTOZOOM_SCR_V_SIZE
rotozoomTextureIn	dc.l	0	
rotozoomTexturePtr	dc.l	0						
rotozoomPointsIn	ds.l	16
rotozoomPointsOut	ds.l	16	
rotozoomAngle		dc.w	0
rotozoomZoom		dc.w	0
rotozoomStep		dc.w	0
					dc.w	0

	section text
