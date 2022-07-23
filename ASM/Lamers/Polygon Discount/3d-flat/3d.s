ROT_STEP_3D	equ 2
ROT_SCR_H	equ	320
ROT_SCR_V	equ	200
ROT_3D_TRI	equ	1
ROT_3D_CUBE	equ	0
ROT_3D_FACE_THR equ 10

	section text
rot3d1Init:
	firstRunOrReturn
	bsr 	clearScreenBuffer
	move.l	ramBufferPtr,a1

	move.w	#0,rot3dAngleZ
	move.w	#0,rot3dAngleY
	move.w	#0,rot3dAngleX
	move.w	#0,rotMode3d
	
	; calc line offsets
	moveq.l	#0,d0
	move.l	#ROT_SCR_H*2,d1
	lea		rot3dLineOffsets(pc),a6
	move.l	#ROT_SCR_V-1,d7
	
_rot3dCalcLineOffsets	
	move.l	d0,(a6)+
	add.l	d1,d0
	dbf		d7,_rot3dCalcLineOffsets
	
	; set up video
	bsr 	video_320x200x16
	
	rts
	
rot3d1Main:
	bsr 	switchScreens
			
	bsr 	clrScr3d
	bsr		rotPoints3d
	bsr 	rot3dDrawFaces
	
	rts

rot3dDrawFaces:
			lea 	points3dOut(pc),a5
			lea		faces3d(pc),a6	

			move.l	faces3dCnt,d7
_rot3dDrawFacesLoop
			; 0 point
			move.w	(a6)+,d6
			move.w	(a5,d6.w*4),d0
			move.w	2(a5,d6.w*4),d1

			; 1 point
			move.w	(a6)+,d6
			move.w	(a5,d6.w*4),d2
			move.w	2(a5,d6.w*4),d3

			; 2 point
			move.w	(a6)+,d6
			move.w	(a5,d6.w*4),d4
			move.w	2(a5,d6.w*4),d5

			movem.w	d0-d5,-(a7)	

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
			
			movem.w	(a7)+,d0-d5

			cmp.w	#ROT_3D_FACE_THR,d6
			ble.s	_rot3dSkipFace

			; draw face - d0-d5 vertexes
			movem.l	d7/a5/a6,-(a7)
			bsr rot3dDrawFace
			movem.l	(a7)+,d7/a5/a6
_rot3dSkipFace
			dbf		d7,_rot3dDrawFacesLoop
			rts

			include	'3d/macro.s'

			
rot3dDrawFace:
			; sort vertexes Y (d1,d3,d5)
			rot3dSortVert	2,3,4,5
			rot3dSortVert	0,1,2,3
			rot3dSortVert	2,3,4,5
			
			; get to first pixel
			move.l	scr1,a0
			move.l	a0,a5
			lea		rot3dLineOffsets(pc),a4
			add.l	(a4,d1.w*4),a0
			ext.l	d0
			add.l	d0,a0
			add.l	d0,a0

			add.l	(a4,d3.w*4),a5
			ext.l	d2
			add.l	d2,a5
			add.l	d2,a5
			
			move.w	d0,a3		;Ax	
			move.w	d2,a4		;Bx

			; calc deltas	AB,AC,BC
			ext.l	d4
			move.w	d4,a1	;Cx
			move.w	d5,a2	;Cy
			
			sub.w	d2,d4	;dxBC
			sub.w	d3,d5	;dyBC
			move.w	d5,-(a7)	; -||-

			sub.w	d0,a1	;dxAC
			sub.w	d1,a2	;dyAC
			
			sub.w	d0,d2	;dxAB
			sub.w	d1,d3	;dyAB
			moveq.l	#0,d7
			move.w	d3,d7	; -||-
			
			move.w	a1,d0	;dxAC
			move.w	a2,d1	;dyAC

			rot3dDivOrSkip d0,d1;dAC	2
			rot3dDivOrSkip d2,d3;dAB	1
			rot3dDivOrSkip d4,d5;dBC	3

			; a0    left edge draw ptr
			; d0 	dAC	2
			; d2	dAB	1
			
			; d7 	line iter

			cmp.l	d0,d2
			ble		_rot3dDrawFaceD1D2
_rot3dDrawFaceD2D1
			;  *** dAB>dAC ***
			rot3dDrawFaceMacro
			;lea	2(a7),a7
			bra.w _rot3dDrawFaceEnd
_rot3dDrawFaceD1D2
			;  *** dAB<dAC ***
			rot3dDrawFaceMacro2
			;lea	2(a7),a7
_rot3dDrawFaceEnd
			rts

; d0,d1 (x,y)	
;putPixel:
;	move.l	scr1,a0
;	lea		rot3dLineOffsets(pc),a4
;	add.l	(a4,d1.w*4),a0
;	ext.l	d0
;	add.l	d0,a0
;	add.l	d0,a0

;	move.w	#$00ff,(a0)
;	rts
	
clrScr3d:
		move.l	scr1,a0
		moveq.l	#0,d0
		move.l	#ROT_SCR_H*ROT_SCR_V/2-1,d7
_clrScr3dLoop
		move.l	d0,(a0)+
		dbf		d7,_clrScr3dLoop

		rts

	include	'3d/rot.s'

		
	section data
	cnop 0,4
cos3d	equ sin3d+64*2
sin3d	dc.w 0,804,1607,2410,3211,4011,4807,5601,6392,7179,7961,8739,9511,10278,11038,11792,12539,13278,14009,14732,15446,16150,16845,17530,18204,18867,19519,20159,20787,21402,22004,22594,23169,23731,24278,24811,25329,25831,26318,26789,27244,27683,28105,28510,28897,29268,29621,29955,30272,30571,30851,31113,31356,31580,31785,31970,32137,32284,32412,32520,32609,32678,32727,32757,32767,32757,32727,32678,32609,32520,32412,32284,32137,31970,31785,31580,31356,31113,30851,30571,30272,29955,29621,29268,28897,28510,28105,27683,27244,26789,26318,25831,25329,24811,24278,23731,23169,22594,22004,21402,20787,20159,19519,18867,18204,17530,16845,16150,15446,14732,14009,13278,12539,11792,11038,10278,9511,8739,7961,7179,6392,5601,4807,4011,3211,2410,1607,804,0,-804,-1607,-2410,-3211,-4011,-4807,-5601,-6392,-7179,-7961,-8739,-9511,-10278,-11038,-11792,-12539,-13278,-14009,-14732,-15446,-16150,-16845,-17530,-18204,-18867,-19519,-20159,-20787,-21402,-22004,-22594,-23169,-23731,-24278,-24811,-25329,-25831,-26318,-26789,-27244,-27683,-28105,-28510,-28897,-29268,-29621,-29955,-30272,-30571,-30851,-31113,-31356,-31580,-31785,-31970,-32137,-32284,-32412,-32520,-32609,-32678,-32727,-32757,-32767,-32757,-32727,-32678,-32609,-32520,-32412,-32284,-32137,-31970,-31785,-31580,-31356,-31113,-30851,-30571,-30272,-29955,-29621,-29268,-28897,-28510,-28105,-27683,-27244,-26789,-26318,-25831,-25329,-24811,-24278,-23731,-23169,-22594,-22004,-21402,-20787,-20159,-19519,-18867,-18204,-17530,-16845,-16150,-15446,-14732,-14009,-13278,-12539,-11792,-11038,-10278,-9511,-8739,-7961,-7179,-6392,-5601,-4807,-4011,-3211,-2410,-1607,-804,0,804,1607,2410,3211,4011,4807,5601,6392,7179,7961,8739,9511,10278,11038,11792,12539,13278,14009,14732,15446,16150,16845,17530,18204,18867,19519,20159,20787,21402,22004,22594,23169,23731,24278,24811,25329,25831,26318,26789,27244,27683,28105,28510,28897,29268,29621,29955,30272,30571,30851,31113,31356,31580,31785,31970,32137,32284,32412,32520,32609,32678,32727,32757

	include	'3d/data.s'

	section bss
	cnop 0,4
rot3dAngleX		dc.w	0
rot3dAngleY		dc.w	0
rot3dAngleZ		dc.w	0
rotMode3d		dc.w	0
points3dOut		ds.l	64	
rot3dLineOffsets		ds.l	240

	section text
