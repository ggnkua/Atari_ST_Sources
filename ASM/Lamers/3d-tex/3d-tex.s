TEX_STEP_3D	equ 2
TEX_SCR_H	equ	320
TEX_SCR_V	equ	200
TEX_3D_TRI	equ	0
TEX_3D_CUBE	equ	1
TEX_3D_FACE_THR equ 10

TEX_OBJ_H	equ	140
TEX_OBJ_V	equ	135
TEX_OBJ_R	equ	220
TEX_OBJ_B	equ	169
TEX_OBJ_LR	equ	(TEX_SCR_H-TEX_OBJ_H)/2

TEX_ZBUFF	equ	0

	section text
tex3dInit:
	firstRunOrReturn
	bsr	texCalcOffsets
	; set up video
	;bsr 	video_320x200x16
	
	rts

tex3dInitGrey:
	firstRunOrReturn
	bsr 	video_320x200x16
	move.w	#0,tex3dAngleZ
	move.w	#0,tex3dAngleY
	move.w	#0,tex3dAngleX
	move.w	#0,texMode3d
	move.w	#204,tex_objX
	move.w	#100,tex_objY
	move.l	#imageGrey,tex_bgImgPtr
	move.l	#tex3dGrey,tex_bgTexPtr
	move.w	#0,tex_stepY
	rts


tex3dInitCode:
	firstRunOrReturn
	bsr 	video_320x200x16
	move.w	#0,tex3dAngleZ
	move.w	#0,tex3dAngleY
	move.w	#0,tex3dAngleX
	move.w	#0,texMode3d
	move.w	#90,tex_objX
	move.w	#100,tex_objY
	move.l	#imageCode,tex_bgImgPtr
	move.l	#tex3d,tex_bgTexPtr
	move.w	#0,tex_stepY
	rts

tex3dInitVisuals:
	firstRunOrReturn
	;move.w	#0,tex3dAngleZ
	;move.w	#0,tex3dAngleY
	;move.w	#0,tex3dAngleX
	;move.w	#0,texMode3d
	move.w	#80,tex_objX
	move.w	#100,tex_objY
	move.l	#imageVisuals,tex_bgImgPtr
	move.l	#tex3d,tex_bgTexPtr
	;move.w	#0,tex_stepY
	rts

tex3dInitMsx:
	firstRunOrReturn
	;move.w	#0,tex3dAngleZ
	;move.w	#0,tex3dAngleY
	;move.w	#0,tex3dAngleX
	;move.w	#0,texMode3d
	move.w	#230,tex_objX
	move.w	#100,tex_objY
	move.l	#imageMsx,tex_bgImgPtr
	move.l	#tex3d,tex_bgTexPtr
	;move.w	#0,tex_stepY
	rts

	
texCalcOffsets:
	; calc line offsets
	moveq.l	#0,d0
	move.l	#TEX_SCR_H*2,d1
	lea		tex3dLineOffsets(pc),a6
	move.l	#TEX_SCR_V-1,d7
	
_tex3dCalcLineOffsets	
	move.l	d0,(a6)+
	add.l	d1,d0
	dbf		d7,_tex3dCalcLineOffsets
	rts
	
tex3dMain:
	;bsr		waitVSync
	bsr 	switchScreens
	
	bsr		texRestoreBg		
	bsr		texSetupY
	;bsr 	texClrScr3d
	bsr		texPoints3d
	bsr 	tex3dDrawFaces
	;move.l	#$ff00,$ffff9800.w
	rts


texSetupY:
	move.w	tex_stepY,d0
	addq.w	#1,d0
	cmp.w	#300,d0
	blt.s	_texSetupYNo
	move.w	#0,d0
_texSetupYNo	
	lea		texTrackY,a0
	move.w	(a0,d0.w*2),d1
	move.w	d1,tex_objY
	move.w	d0,tex_stepY
	rts

tex3dDrawFaces:
			lea		texUV3d,a4
			lea 	texPoints3dOut,a5
			lea		texFaces3d,a6

			move.l	texFaces3dCnt,d7
_tex3dDrawFacesLoop
			; 0 point
			move.w	(a6)+,d6
			move.w	(a5,d6.w*4),d0
			move.w	2(a5,d6.w*4),d1
			move.l	(a4)+,a1

			; 1 point
			move.w	(a6)+,d6
			move.w	(a5,d6.w*4),d2
			move.w	2(a5,d6.w*4),d3
			move.l	(a4)+,a2

			; 2 point
			move.w	(a6)+,d6
			move.w	(a5,d6.w*4),d4
			move.w	2(a5,d6.w*4),d5
			move.l	(a4)+,a3
			lea		4(a4),a4

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

			cmp.w	#TEX_3D_FACE_THR,d6
			ble.s	_tex3dSkipFace

			; draw face - d0-d5 vertexes
			movem.l	d7/a4-a6,-(a7)
			bsr tex3dDrawFace
			movem.l	(a7)+,d7/a4-a6
_tex3dSkipFace
			dbf		d7,_tex3dDrawFacesLoop
			rts

			include	'3d-tex/macro-tex.s'	
	
; (x1,y1,x2,y2,x3,y3,Txy1,Txy2,Txy3)
; (d0,d1,d2,d3,d4,d5,a1,a2,a3)			
tex3dDrawFace: 
			; sort vertexes Y (d1,d3,d5)
			tex3dSortVert	2,3,4,5,2,3 ;(x1,y1,x2,y2,Txy1,Txy2)
			tex3dSortVert	0,1,2,3,1,2
			tex3dSortVert	2,3,4,5,2,3
	
			cmp.w	d1,d3
			bne.s	_tex3dDrawFaceNotSortH
			cmp.w	d0,d2
			bgt.s	_tex3dDrawFaceNotSortH
			exg		d0,d2
			exg		d1,d3
			exg		a1,a2			
_tex3dDrawFaceNotSortH			

			; get to first pixel
			move.l	scr1,a0
			move.l	a0,a6
			lea		tex3dLineOffsets(pc),a4
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
			beq.w	_tex3dDrawFaceEnd
			
			move.w	d5,a5
			sub.w	d3,a5	; a0 = dyBC
			move.w	a5,tex_dyBC
			moveq.l	#0,d6
			move.w	d4,d6
			sub.w	d0,d6	; d6 = dxAC
			ext.l	d7
			move.l	d7,tex_dyAC
			tex3dDiv		d6,d7 ; d6 = dAC	16.16
			move.l	d6,tex_dAC

			sub.w	d1,d3	; d3 = dyAB
			move.w	d3,tex_dyAB
			muls.l	d3,d6 

			swap	d6		
			add.w	d0,d6	; d6 longest edge x2
			sub.w	d2,d6	; d6 longest edge len
		
			; a1	TA_XXxxYYyy
			; a2	TB_XXxxYYyy
			; a3	TC_XXxxYYyy
			move.l	a1,tex_TA
			movem.l	a1-a3,-(a7)
			move.l	a1,d0
			swap	d0
			move.w	d0,a1

			move.l	a2,d0
			swap	d0
			move.w	d0,a2

			move.l	a3,d0
			swap	d0
			move.w	d0,a3
			move.w	a2,a4
			sub.w	a1,a2	; a2 - dTxAB
			move.w	a3,a5
			sub.w	a1,a3	; a3 - dTxAC
			sub.w	a4,a5	; a5 - dTxBC
							; a1 - TxA
							; a4 - TxB

			move.w			a3,d5
			tex3dDiv		d5,d7 ; d5 = tex_TstepACx
			muls.l	d3,d5 
			swap	d5		; 
			add.w	a1,d5
			sub.w	a4,d5	; d5 longest edge Tx dist
		
			tex3dDivOrSkip	d5,d6 ; d5 Tx step 8.24

			move.w	a3,d2	;	dTxAC	
			move.w	a2,d3	;	dTxAB
			move.w	a5,d4	;	dTxBC

			tex3dDiv	d2,d7	;	tex_dACx	
			move.w	tex_dyAB,d7
			tex3dDiv	d3,d7	;	tex_dABx *
			move.w 	tex_dyBC,d7
			tex3dDiv	d4,d7	;	tex_dBCx *		 
			; 8.24

			lea		tex_TstepACx(pc),a1
			movem.l	d2-d4,(a1)	;tex_TstepACx,tex_TstepABx,tex_TstepBCx
			move.l	d5,a6	;tex_TstepHx cXstep
			movem.l	(a7)+,a1-a3
			
			move.w	a2,a4
			sub.w	a1,a2	; a2 - dTyAB
			move.w	a3,a5
			sub.w	a1,a3	; a3 - dTyAC
			sub.w	a4,a5	; a5 - dTyBC
							; a1 - TyA
							; a4 - TyB

			move.w			a3,d5
			move.l			tex_dyAC,d7
			tex3dDiv		d5,d7 ; d5 = tex_TstepACy
			move.w	tex_dyAB,d3
			ext.l	d3
			muls.l	d3,d5 
			swap	d5		; 
			add.w	a1,d5
			sub.w	a4,d5	; d5 longest edge Ty dist
		
			tex3dDivOrSkip	d5,d6 ; d5 Ty step 8.24	tex_TstepHy

			move.w	a3,d2	;	dTyAC	
			move.w	a2,d3	;	dTyAB
			move.w	a5,d4	;	dTxBC
			
			tex3dDiv	d2,d7	;	tex_dACx	
			move.w	tex_dyAB,d7
			tex3dDiv	d3,d7	;	tex_dABx *
			move.w 	tex_dyBC,d7
			tex3dDiv	d4,d7	;	tex_dBCx *		 

			; ****
			swap d2
			swap d3
			swap d4
			
			lea	tex_TstepACx(pc),a1
			movem.l	(a1),d0/d1/d6 ;tex_TstepACx,tex_TstepABx,tex_TstepBCx

			move.w	d2,d0
			move.w	d3,d1
			move.w	d4,d6
			
			lea	tex_TstepAC(pc),a1
			movem.l	d0/d1/d6,(a1)

			move.l	a6,d3	;tex_TstepHx
			moveq.l	#0,d4	; 00000000
			swap	d3		; xxxxXXxx
			move.w	d3,d4	; 0000XXxx
			ror.l	#8,d4   ; xx0000XX
			move.l	d4,d1	; H step 2	tex_Th_b

			move.l	d4,d2
			swap	d5
			move.w	d5,d2
			move.l	d2,a5	;H step1	tex_Th_l

			movem.w	(a7)+,d0/d2/d4
			
			move.w	d0,a3		;Ax	
			move.w	d2,-(a7)	;Bx

			; calc deltas	AB,AC,BC
			sub.w	d2,d4	;dxBC
			move.w	tex_dyBC,d5
			
			sub.w	d0,d2	;dxAB
			move.w	tex_dyAB,d7

			move.l	tex_dAC,d0
			tex3dDivOrSkip d2,d7;dAB
			tex3dDivOrSkip d4,d5;dBC
			move.l	d4,-(a7)	;dBC

			; a0    draw ptr A
			; d0 	dAC	2
			; d2	dAB	1

			move.w	a3,a2
		
			move.l	tex_TA,d3	; V curr
			
			; d7 	line iter
			cmp.w	#0,d7
			ble.w	_tex3dDrawFaceABSameLine
			cmp.l	d0,d2
			blt.w	_tex3dDrawFaceBLeft
_tex3dDrawFaceBRight
			tex3dDrawFaceMacro
			;lea	2(a7),a7
			bra.w _tex3dDrawFaceEnd
_tex3dDrawFaceBLeft
			tex3dDrawFaceMacro2
			;lea	2(a7),a7
			bra.w _tex3dDrawFaceEnd
_tex3dDrawFaceABSameLine
			tex3dDrawFaceMacro
			;lea	2(a7),a7
_tex3dDrawFaceEnd
			rts
	
	
texClrScr3d:
		move.l	scr1,a0
		lea		tex3dLineOffsets(pc),a1
		move.w	#TEX_OBJ_B,d1
		add.l	(a1,d1.w*4),a0
		sub.l	#2*TEX_OBJ_LR,a0

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
							
		move.l	#TEX_OBJ_V-1,d7
_texClrScr3dLoop
		; 140 * w = 70 * l
		movem.l	d0-d6/a1-a6,-(a0)
		movem.l	d0-d6/a1-a6,-(a0)
		movem.l	d0-d6/a1-a6,-(a0)
		movem.l	d0-d6/a1-a6,-(a0)
		movem.l	d0-d6/a1-a6,-(a0)
		movem.l	d0-d4,-(a0)

;		move.l	#TEX_OBJ_H-1,d6
;_clrScr3dLoop1
;		move.w	d0,(a0)
;		sub.l	#2,a0
;		dbf		d6,_clrScr3dLoop1

		sub.l	#4*TEX_OBJ_LR,a0
		dbf		d7,_texClrScr3dLoop

		rts	

texRestoreBg:
		; a5 - bg
		; a6 - screen
		move.l	tex_bgImgPtr,a5

		move.l	scr1,a6
		lea		tex3dLineOffsets(pc),a1
		move.w	tex_objY,d1
		sub.w	#TEX_OBJ_V/2,d1
		add.l	(a1,d1.w*4),a6
		;sub.l	#10,d1
		add.l	(a1,d1.w*4),a5
	
		move.w	tex_objX,d1
		ext.l	d1
		add.l	d1,a5
		add.l	d1,a5	
		sub.l	#TEX_OBJ_H,a5

		add.l	d1,a6
		add.l	d1,a6	
		sub.l	#TEX_OBJ_H,a6
		
		move.l	#36-1,d7
_texRestoreBgLoop1
		rept 6
		movem.l	(a5)+,d0-d6/a0-a4	; 12 regs = 24 w = 48 b
		movem.l	d0-d6/a0-a4,(a6)
		lea		48(a6),a6
		endr
		add.l	#(TEX_SCR_H-144)*2,a5
		add.l	#(TEX_SCR_H-144)*2,a6
		dbf		d7,_texRestoreBgLoop1

		move.l	#64-1,d7
_texRestoreBgLoop2
		rept 2
		movem.l	(a5)+,d0-d6/a0-a4	; 12 regs = 24 w = 48 b
		movem.l	d0-d6/a0-a4,(a6)
		lea		48(a6),a6
		endr
		lea		48*2(a5),a5
		lea		48*2(a6),a6
		rept 2
		movem.l	(a5)+,d0-d6/a0-a4	; 12 regs = 24 w = 48 b
		movem.l	d0-d6/a0-a4,(a6)
		lea		48(a6),a6
		endr

		add.l	#(TEX_SCR_H-144)*2,a5
		add.l	#(TEX_SCR_H-144)*2,a6
		dbf		d7,_texRestoreBgLoop2

		move.l	#35-1,d7
_texRestoreBgLoop3
		rept 6
		movem.l	(a5)+,d0-d6/a0-a4	; 12 regs = 24 w = 48 b
		movem.l	d0-d6/a0-a4,(a6)
		lea		48(a6),a6
		endr
		add.l	#(TEX_SCR_H-144)*2,a5
		add.l	#(TEX_SCR_H-144)*2,a6
		dbf		d7,_texRestoreBgLoop3

		rts
	
	include	'3d-tex/rot-tex.s'	
		
	section data
	cnop 0,4
tex_cos3d	equ tex_sin3d+64*2
tex_sin3d	dc.w 0,804,1607,2410,3211,4011,4807,5601,6392,7179,7961,8739,9511,10278,11038,11792,12539,13278,14009,14732,15446,16150,16845,17530,18204,18867,19519,20159,20787,21402,22004,22594,23169,23731,24278,24811,25329,25831,26318,26789,27244,27683,28105,28510,28897,29268,29621,29955,30272,30571,30851,31113,31356,31580,31785,31970,32137,32284,32412,32520,32609,32678,32727,32757,32767,32757,32727,32678,32609,32520,32412,32284,32137,31970,31785,31580,31356,31113,30851,30571,30272,29955,29621,29268,28897,28510,28105,27683,27244,26789,26318,25831,25329,24811,24278,23731,23169,22594,22004,21402,20787,20159,19519,18867,18204,17530,16845,16150,15446,14732,14009,13278,12539,11792,11038,10278,9511,8739,7961,7179,6392,5601,4807,4011,3211,2410,1607,804,0,-804,-1607,-2410,-3211,-4011,-4807,-5601,-6392,-7179,-7961,-8739,-9511,-10278,-11038,-11792,-12539,-13278,-14009,-14732,-15446,-16150,-16845,-17530,-18204,-18867,-19519,-20159,-20787,-21402,-22004,-22594,-23169,-23731,-24278,-24811,-25329,-25831,-26318,-26789,-27244,-27683,-28105,-28510,-28897,-29268,-29621,-29955,-30272,-30571,-30851,-31113,-31356,-31580,-31785,-31970,-32137,-32284,-32412,-32520,-32609,-32678,-32727,-32757,-32767,-32757,-32727,-32678,-32609,-32520,-32412,-32284,-32137,-31970,-31785,-31580,-31356,-31113,-30851,-30571,-30272,-29955,-29621,-29268,-28897,-28510,-28105,-27683,-27244,-26789,-26318,-25831,-25329,-24811,-24278,-23731,-23169,-22594,-22004,-21402,-20787,-20159,-19519,-18867,-18204,-17530,-16845,-16150,-15446,-14732,-14009,-13278,-12539,-11792,-11038,-10278,-9511,-8739,-7961,-7179,-6392,-5601,-4807,-4011,-3211,-2410,-1607,-804,0,804,1607,2410,3211,4011,4807,5601,6392,7179,7961,8739,9511,10278,11038,11792,12539,13278,14009,14732,15446,16150,16845,17530,18204,18867,19519,20159,20787,21402,22004,22594,23169,23731,24278,24811,25329,25831,26318,26789,27244,27683,28105,28510,28897,29268,29621,29955,30272,30571,30851,31113,31356,31580,31785,31970,32137,32284,32412,32520,32609,32678,32727,32757

	ifne TEX_3D_TRI
	include	'3d-tex/data-tex.s'
	endif

	ifne TEX_3D_CUBE
	include	'3d-tex/data-cube.s'
	endif

	cnop 0,4
;texTrackY dc.w 100,100,100,101,101,102,102,102,103,103,104,104,104,105,105,106,106,106,107,107,108,108,108,109,109,109,110,110,111,111,111,112,112,112,113,113,113,113,114,114,114,115,115,115,115,116,116,116,116,117,117,117,117,117,118,118,118,118,118,118,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119,120,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119,118,118,118,118,118,118,117,117,117,117,117,116,116,116,116,115,115,115,115,114,114,114,113,113,113,113,112,112,112,111,111,111,110,110,109,109,109,108,108,108,107,107,106,106,106,105,105,104,104,104,103,103,102,102,102,101,101,100,100,100,100,100,99,99,98,98,98,97,97,96,96,96,95,95,94,94,94,93,93,92,92,92,91,91,90,90,90,89,89,89,88,88,88,87,87,87,87,86,86,86,85,85,85,85,84,84,84,84,83,83,83,83,83,82,82,82,82,82,82,81,81,81,81,81,81,81,81,81,81,81,81,81,81,81,80,81,81,81,81,81,81,81,81,81,81,81,81,81,81,81,82,82,82,82,82,82,83,83,83,83,83,84,84,84,84,85,85,85,85,86,86,86,87,87,87,87,88,88,88,89,89,89,90,90,90,91,91,92,92,92,93,93,94,94,94,95,95,96,96,96,97,97,98,98,98,99,99,100,100
texTrackY dc.w 100,100,101,101,102,103,103,104,105,105,106,106,107,108,108,109,109,110,111,111,112,112,113,113,114,114,115,116,116,117,117,118,118,119,119,120,120,120,121,121,122,122,123,123,123,124,124,124,125,125,125,126,126,126,127,127,127,127,128,128,128,128,128,129,129,129,129,129,129,129,129,129,129,129,129,130,129,129,129,129,129,129,129,129,129,129,129,129,128,128,128,128,128,127,127,127,127,126,126,126,125,125,125,124,124,124,123,123,123,122,122,121,121,120,120,120,119,119,118,118,117,117,116,116,115,114,114,113,113,112,112,111,111,110,109,109,108,108,107,106,106,105,105,104,103,103,102,101,101,100,100,100,99,99,98,97,97,96,95,95,94,94,93,92,92,91,91,90,89,89,88,88,87,87,86,85,85,84,84,83,83,82,82,81,81,80,80,80,79,79,78,78,77,77,77,76,76,76,75,75,75,74,74,74,73,73,73,73,72,72,72,72,72,71,71,71,71,71,71,71,71,71,71,71,71,70,71,71,71,71,71,71,71,71,71,71,71,71,72,72,72,72,72,73,73,73,73,74,74,74,75,75,75,76,76,76,77,77,77,78,78,79,79,80,80,80,81,81,82,82,83,83,84,84,85,85,86,87,87,88,88,89,89,90,91,91,92,92,93,94,94,95,95,96,97,97,98,99,99,100

	cnop 0,4

	section bss
	cnop 0,4
tex3dAngleX		dc.w	0
tex3dAngleY		dc.w	0
tex3dAngleZ		dc.w	0
texMode3d		dc.w	0
texPoints3dOut		ds.w	64*2	
texPoints3dOutZ	ds.w	64
tex3dLineOffsets		ds.l	240

tex_dAC		dc.l	0
tex_dyAC	dc.l	0
tex_dyBC	dc.w	0
tex_dyAB	dc.w	0

tex_TstepACx	dc.l	0
tex_TstepABx	dc.l	0
tex_TstepBCx	dc.l	0

tex_TA		dc.l	0
tex_TstepAC	dc.l	0
tex_TstepAB	dc.l	0
tex_TstepBC	dc.l	0

tex_objX	dc.w	0
tex_objY	dc.w	0
tex_bgImgPtr	dc.l	0
tex_bgTexPtr	dc.l	0	
tex_stepY	dc.w	0
			dc.w	0
	section text
