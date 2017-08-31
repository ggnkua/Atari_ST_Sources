GOU_VBL_WT	equ 0
GOU_STEP_3D	equ 2
GOU_SCR_H	equ	320
GOU_SCR_V	equ	200
GOU_3D_TRI	equ	0
GOU_3D_TOR	equ	0
GOU_3D_TOR2	equ	1
GOU_3D_FACE_THR equ 10

GOU_POS_H	equ	230
	ifne GOU_3D_TOR2
GOU_OBJ_H	equ	140
GOU_OBJ_V	equ	139
GOU_OBJ_R	equ	220
GOU_OBJ_B	equ	170
GOU_OBJ_LR	equ	(GOU_SCR_H-GOU_OBJ_H)/2
	endif
	ifeq GOU_3D_TOR2
GOU_OBJ_H	equ	140
GOU_OBJ_V	equ	135
GOU_OBJ_R	equ	220
GOU_OBJ_B	equ	169
GOU_OBJ_LR	equ	(GOU_SCR_H-GOU_OBJ_H)/2
	endif

GOU_ZBUFF	equ	1

	section text
gou3dInit:
	;firstRunOrReturn
	;bsr 	clearScreenBuffer
	;move.l	ramBufferPtr,a1

	move.w	#0,gou3dAngleZ
	move.w	#0,gou3dAngleY
	move.w	#0,gou3dAngleX
	move.w	#0,gouMode3d
	
	; calc line offsets
	moveq.l	#0,d0
	move.l	#GOU_SCR_H*2,d1
	lea		gou3dLineOffsets(pc),a6
	move.l	#GOU_SCR_V-1,d7
	
_gou3dCalcLineOffsets	
	move.l	d0,(a6)+
	add.l	d1,d0
	dbf		d7,_gou3dCalcLineOffsets
	
	; calc upscale colors
	lea	    gouColor3d,a5	
	move.l	ramBufferPtr,gouUpscaleColorPtr
	move.l	gouUpscaleColorPtr,a6
	move.l	#256-1,d7
_gou3dCalcUpscaleColors
	move.w	(a5)+,d0
	move.l	#256-1,d6	
_gou3dCalcUpscaleColors1
	move.w	d0,(a6)+	
	dbf		d6,_gou3dCalcUpscaleColors1
	dbf		d7,_gou3dCalcUpscaleColors
	move.l	gouUpscaleColorPtr,a6
	
	; set up video
	;bsr 	video_320x200x16
	
	rts
	
gou3dMain:
	ifne GOU_VBL_WT	
	bsr		waitVSync
	endif
	bsr 	switchScreens
			
	bsr 	gouClrScr3d
	bsr		gouPoints3d
	ifne	GOU_ZBUFF
	bsr		gou3dZbuffClr
	endif
	bsr 	gou3dCullFaces
	bsr 	gou3dSortFacesRadix	

	bsr 	gou3dDrawFaces
	;move.l	#$ff00,$ffff9800.w
	rts

gou3dZbuffClr:
			lea 	gouPointsColor3d,a4
			lea 	gouPoints3dOutZ(pc),a5
			lea		gouColorMap,a6
			move.w	gouCoordShift,d1
			move.l	gouPoints3dCnt,d7
_gou3dZbuffClrLoop	
			move.w	(a5)+,d0
			add.w	d1,d0
			;add.w	d0,d0
			;move.w	d0,(a4)+
			move.w	(a6,d0.w*2),(a4)+

			dbf		d7,_gou3dZbuffClrLoop

			rts

gou3dCullFaces:
			lea		gouFacesRadix0A,a3
			lea 	gouPoints3dOutZ,a4
			lea 	gouPoints3dOut(pc),a5
			lea		gouFaces3d,a6	
			move.w	#128+128+128,a2

			moveq.l	#0,d7
_gou3dCullFacesLoop
			; 0 point
			move.w	(a6)+,d6
			move.w	(a5,d6.w*4),d0
			move.w	2(a5,d6.w*4),d1
			move.w	(a4,d6.w*2),a0

			; 1 point
			move.w	(a6)+,d6
			move.w	(a5,d6.w*4),d2
			move.w	2(a5,d6.w*4),d3
			add.w	(a4,d6.w*2),a0

			; 2 point
			move.w	(a6)+,d6
			move.w	(a5,d6.w*4),d4
			move.w	2(a5,d6.w*4),d5
			add.w	(a4,d6.w*2),a0 ; Z sum

			; (d0,d1)
			; (d2,d3)
			; (d4,d5)

			; check if draw face
			;(x2-x1)*(y3-y2)-(x3-x2)*(y2-y1)
			
			sub.w	d2,d4	;x3-x2	d4
			sub.w	d0,d2	;x2-x1	d2
			sub.w	d3,d5	;y3-y2	d5
			sub.w	d1,d3	;y2-y1	d3
			muls.w	d2,d5
			muls.w	d4,d3
			sub.w	d3,d5
			move.w  d5,d6
			
			lea     2(a6),a6
			
			cmp.w	#GOU_3D_FACE_THR,d6
			ble.s	_gou3dSkipCullFace
			add.w	a2,a0
			move.w	a0,d6
			swap	d6
			move.w	d7,d6
			
			move.l	d6,(a3)+
_gou3dSkipCullFace
			
			addq.l	#1,d7	
			cmp.l	gouFaces3dCnt,d7
			
			blt.s	_gou3dCullFacesLoop
			move.l	#-1,(a3)
			rts

			macro gouRadixOut
_gou3dSortOutLoop\@1
			;move.l	(a5)+,d0
			move.l	(a\1)+,d0
			cmp.w	#0,d0
			blt.s	_gou3dSortOutLoopEnd\@1
			move.w	d0,(a6)+
			bra.s	_gou3dSortOutLoop\@1
_gou3dSortOutLoopEnd\@1
			endm

			macro gouRadixMacro
_gouRadixBitCmpLoop\@1
			move.l	(a\1)+,d1
			cmp.w	#0,d1
			blt.s	_gouRadixBitCmpLoopEnd\@1
			
			btst.l	d0,d1
			bne.s	_gouRadixBitCmp1\@1
			move.l	d1,(a2)+	;0			
			bra.s	_gouRadixBitCmp2\@1			
_gouRadixBitCmp1\@1			
			move.l	d1,(a3)+; 1
_gouRadixBitCmp2\@1			
			bra.s	_gouRadixBitCmpLoop\@1
_gouRadixBitCmpLoopEnd\@1			
			endm

gou3dSortFacesRadix:
			lea		gouFacesRadix0A,a0
			lea		gouFacesRadix1A,a1
			lea		gouFacesRadix0B,a2
			lea		gouFacesRadix1B,a3

			move.l	#-1,(a1)
			
			move.l	#16,d0	; bit
_gouSortRadixBitChgLoop			
			move.l	a0,d3
			move.l	a1,d4
			move.l	a2,d5
			move.l	a3,d6

			gouRadixMacro 0
			gouRadixMacro 1
			move.l	#-1,(a2)+
			move.l	#-1,(a3)+

			move.l	d5,a0
			move.l	d6,a1
			move.l	d3,a2
			move.l	d4,a3

			addq.l	#1,d0
			cmp.l	#26,d0
			beq.s	_gouSortRadixBitChgLoopEnd
			bra.s	_gouSortRadixBitChgLoop
_gouSortRadixBitChgLoopEnd

			lea 	gouFacesSortOut,a6
			gouRadixOut	0
			gouRadixOut	1
			move.w	#-1,(a6)

			rts

gou3dDrawFaces:
			lea 	gouFacesSortOut,a0
_gou3dDrawFacesLoop
			lea 	gouPointsColor3d,a4
			lea 	gouPoints3dOut(pc),a5
			lea		gouFaces3d,a6	

			move.w	(a0)+,d0
			blt.s	_gou3dDrawFacesEnd	
			
			ext.l	d0
			asl.l	#3,d0
			add.l	d0,a6
		
			; 0 point
			move.w	(a6)+,d6
			move.w	(a5,d6.w*4),d0
			move.w	2(a5,d6.w*4),d1
			move.w	(a4,d6.w*2),a1 ; color

			; 1 point
			move.w	(a6)+,d6
			move.w	(a5,d6.w*4),d2
			move.w	2(a5,d6.w*4),d3
			move.w	(a4,d6.w*2),a2 ; color

			; 2 point
			move.w	(a6)+,d6
			move.w	(a5,d6.w*4),d4
			move.w	2(a5,d6.w*4),d5
			move.w	(a4,d6.w*2),a3 ; color

			; draw face - d0-d5 vertexes
			movem.l	a0,-(a7)
			bsr gou3dDrawFace
			movem.l	(a7)+,a0
			bra.w _gou3dDrawFacesLoop
_gou3dDrawFacesEnd			
			rts

			include	'3d-gou/macro.s'


; (x1,y1,x2,y2,x3,y3,c1,c2,c3)
; (d0,d1,d2,d3,d4,d5,a1,a2,a3)			
gou3dDrawFace: 
			; sort vertexes Y (d1,d3,d5)
			gou3dSortVert	2,3,4,5,2,3 ;(x1,y1,x2,y2,c1,c2)
			gou3dSortVert	0,1,2,3,1,2
			gou3dSortVert	2,3,4,5,2,3
	
			cmp.w	d1,d3
			bne.s	_gou3dDrawFaceNotSortH
			cmp.w	d0,d2
			bgt.s	_gou3dDrawFaceNotSortH
			exg		d0,d2
			exg		d1,d3
			exg		a1,a2			
_gou3dDrawFaceNotSortH			

			ext.l	d1
			ext.l	d3

			; get to first pixel
			move.l	scr1,a0
			move.l	a0,a6
			lea		gou3dLineOffsets(pc),a4
			add.l	(a4,d1.w*4),a0
			ext.l	d0
			add.l	d0,a0
			add.l	d0,a0

			add.l	(a4,d3.w*4),a6
			ext.l	d2
			add.l	d2,a6
			add.l	d2,a6
			move.l	a6,-(a7)
			
			movem.w	d0/d2/d4,-(a7)
			; calc longest
			move.w	d5,d7	
			sub.w	d1,d7	; d7 = dyAC
			cmp.w	#0,d7
			beq.w	_gou3dDrawFaceEnd
			
			move.w	d5,a5
			sub.w	d3,a5	; a0 = dyBC
			move.w	a5,gou_dyBC
			moveq.l	#0,d6
			move.w	d4,d6
			sub.w	d0,d6	; d6 = dxAC
			ext.l	d7
			gou3dDiv		d6,d7 ; d6 = dAC	16.16
			move.l	d6,gou_dAC

			sub.w	d1,d3	; d3 = dyAB
			move.w	d3,gou_dyAB
			muls.l	d3,d6 

			swap	d6		
			add.w	d0,d6	; d6 longest edge x2
			sub.w	d2,d6	; d6 longest edge len
		
			; a1	Ac
			; a2	Bc
			; a3	Cc
			move.w	a2,a4
			sub.w	a1,a2	; a2 - dcAB
			move.w	a3,a5
			sub.w	a1,a3	; a3 - dcAC
			sub.w	a4,a5	; a5 - dcBC
							; a1 - Ac
							; a4 - Bc
			
			move.w			a3,d5
			gou3dDiv		d5,d7 ; d5 = gou_dCAC
			muls.l	d3,d5 
			swap	d5		; d5 longest edge color 2
			add.w	a1,d5
			sub.w	a4,d5	; d5 longest edge color dist
		
			gou3dDivOrSkip	d5,d6 ; d5 color step 16.16
			asr.l	#8,d5	; color step 24.8

			move.w	a1,d0	;	Ac
			move.w	a3,d2	;	dcAC	
			move.w	a2,d3	;	dcAB
			move.w	a5,d4	;	dcBC

			ext.l	d0	
			asl.l	#8,d0
			
			gou3dDiv	d2,d7	;	gou_dCAC	
			move.w	gou_dyAB,d7
			gou3dDiv	d3,d7	;	gou_dCAB *
			move.w 	gou_dyBC,d7
			gou3dDiv	d4,d7	;	gou_dCBC *		 
			asr.l	#8,d2
			asr.l	#8,d3
			asr.l	#8,d4

			add.l	d2,d2
			add.l	d3,d3
			add.l	d4,d4

			add.l	d0,d0
			add.l	d5,d5
			
			lea		gou_dCAC(PC),a5
			movem.l	d2-d4,(a5) ;gou_dCAC,gou_dCAB,gou_dCBC

			move.l	d5,a5	;cXstep
			move.l	d0,d3	;Ac

			movem.w	(a7)+,d0/d2/d4
			
			move.w	d0,a3		;Ax	
			move.w	d2,-(a7)	;Bx

			; calc deltas	AB,AC,BC
			sub.w	d2,d4	;dxBC
			move.w	gou_dyBC,d5
			
			sub.w	d0,d2	;dxAB
			move.w	gou_dyAB,d7

			move.l	gou_dAC,d0
			gou3dDivOrSkip d2,d7;dAB
			gou3dDivOrSkip d4,d5;dBC
			move.l	d4,-(a7)	;dBC

			; a0    draw ptr A
			; d0 	dAC	2
			; d2	dAB	1

			move.l	gouUpscaleColorPtr,a6
			move.w	a3,a2
			
			; d7 	line iter
			cmp.w	#0,d7
			ble.w	_gou3dDrawFaceABSameLine
			cmp.l	d0,d2
			blt.w	_gou3dDrawFaceBLeft
_gou3dDrawFaceBRight
			gou3dDrawFaceMacro
			;lea	2(a7),a7
			bra.w _gou3dDrawFaceEnd
_gou3dDrawFaceBLeft
			gou3dDrawFaceMacro2
			;lea	2(a7),a7
			bra.w _gou3dDrawFaceEnd
_gou3dDrawFaceABSameLine
			gou3dDrawFaceMacro
			;lea	2(a7),a7
_gou3dDrawFaceEnd
			rts
	
gouClrScr3d:
		move.l	scr1,a0
		lea		gou3dLineOffsets(pc),a1
		move.w	#GOU_OBJ_B,d1
		add.l	(a1,d1.w*4),a0
		;sub.l	#2*GOU_OBJ_LR,a0
		sub.l	#2*(GOU_SCR_H-GOU_POS_H-GOU_OBJ_H/2),a0

		moveq.l	#0,d0
		move.l	d0,d1
		move.l	d0,d2
		move.l	d0,d3
		move.l	d0,d4
		move.l	d0,d5
		move.l	d0,d6		
		move.l	d0,a1
		move.l	d0,a2
		move.l	d0,a3
		move.l	d0,a4
		move.l	d0,a5
		move.l	d0,a6
							
		move.l	#GOU_OBJ_V-1,d7
_gouClrScr3dLoop
		; 140 * w = 70 * l
		movem.l	d0-d6/a1-a6,-(a0)
		movem.l	d0-d6/a1-a6,-(a0)
		movem.l	d0-d6/a1-a6,-(a0)
		movem.l	d0-d6/a1-a6,-(a0)
		movem.l	d0-d6/a1-a6,-(a0)
		movem.l	d0-d4,-(a0)

;		move.l	#GOU_OBJ_H-1,d6
;_clrScr3dLoop1
;		move.w	d0,(a0)
;		sub.l	#2,a0
;		dbf		d6,_clrScr3dLoop1

		sub.l	#4*GOU_OBJ_LR,a0
		dbf		d7,_gouClrScr3dLoop

		rts

	include	'3d-gou/rot.s'

		
	section data
	cnop 0,4
gou_cos3d	equ gou_sin3d+64*2
gou_sin3d	dc.w 0,804,1607,2410,3211,4011,4807,5601,6392,7179,7961,8739,9511,10278,11038,11792,12539,13278,14009,14732,15446,16150,16845,17530,18204,18867,19519,20159,20787,21402,22004,22594,23169,23731,24278,24811,25329,25831,26318,26789,27244,27683,28105,28510,28897,29268,29621,29955,30272,30571,30851,31113,31356,31580,31785,31970,32137,32284,32412,32520,32609,32678,32727,32757,32767,32757,32727,32678,32609,32520,32412,32284,32137,31970,31785,31580,31356,31113,30851,30571,30272,29955,29621,29268,28897,28510,28105,27683,27244,26789,26318,25831,25329,24811,24278,23731,23169,22594,22004,21402,20787,20159,19519,18867,18204,17530,16845,16150,15446,14732,14009,13278,12539,11792,11038,10278,9511,8739,7961,7179,6392,5601,4807,4011,3211,2410,1607,804,0,-804,-1607,-2410,-3211,-4011,-4807,-5601,-6392,-7179,-7961,-8739,-9511,-10278,-11038,-11792,-12539,-13278,-14009,-14732,-15446,-16150,-16845,-17530,-18204,-18867,-19519,-20159,-20787,-21402,-22004,-22594,-23169,-23731,-24278,-24811,-25329,-25831,-26318,-26789,-27244,-27683,-28105,-28510,-28897,-29268,-29621,-29955,-30272,-30571,-30851,-31113,-31356,-31580,-31785,-31970,-32137,-32284,-32412,-32520,-32609,-32678,-32727,-32757,-32767,-32757,-32727,-32678,-32609,-32520,-32412,-32284,-32137,-31970,-31785,-31580,-31356,-31113,-30851,-30571,-30272,-29955,-29621,-29268,-28897,-28510,-28105,-27683,-27244,-26789,-26318,-25831,-25329,-24811,-24278,-23731,-23169,-22594,-22004,-21402,-20787,-20159,-19519,-18867,-18204,-17530,-16845,-16150,-15446,-14732,-14009,-13278,-12539,-11792,-11038,-10278,-9511,-8739,-7961,-7179,-6392,-5601,-4807,-4011,-3211,-2410,-1607,-804,0,804,1607,2410,3211,4011,4807,5601,6392,7179,7961,8739,9511,10278,11038,11792,12539,13278,14009,14732,15446,16150,16845,17530,18204,18867,19519,20159,20787,21402,22004,22594,23169,23731,24278,24811,25329,25831,26318,26789,27244,27683,28105,28510,28897,29268,29621,29955,30272,30571,30851,31113,31356,31580,31785,31970,32137,32284,32412,32520,32609,32678,32727,32757

	ifne	GOU_3D_TRI
	include	'3d-gou/data.s'
	endif

	ifne	GOU_3D_TOR
	include	'3d-gou/data-torus48.s'
	endif

	ifne	GOU_3D_TOR2
	include	'3d-gou/data-torus64.s'
	endif

	section bss
	cnop 0,4
gou3dAngleX		dc.w	0
gou3dAngleY		dc.w	0
gou3dAngleZ		dc.w	0
gouMode3d		dc.w	0
gouPoints3dOut		ds.w	64*2	
gouPoints3dOutZ	ds.w	64
gouFacesSortOut	ds.w	128
gou3dLineOffsets		ds.l	240
gouUpscaleColorPtr dc.l	0

gou_dAC		dc.l	0
gou_dyBC	dc.w	0
gou_dyAB	dc.w	0
gou_dCAC		dc.l	0
gou_dCAB		dc.l	0
gou_dCBC		dc.l	0

gouFacesRadix0A		ds.l	128
gouFacesRadix0B		ds.l	128
gouFacesRadix1A		ds.l	128
gouFacesRadix1B		ds.l	128

	section text
