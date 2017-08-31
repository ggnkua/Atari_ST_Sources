			macro tex3dSortVert
			cmp.w	d\2,d\4
			bge.s	_tex3dDrawFaceSort\@1
			exg		d\1,d\3
			exg		d\2,d\4
			exg		a\5,a\6
_tex3dDrawFaceSort\@1				
			endm

			macro tex3dPrepInter1
			cmp.l	#0,\1
			bmi.s	_tex3dPrepInter\@1
			move.b	#$52,\4-2-2	;add
			move.b	#$54,\4-2	;add
			bra.s	_tex3dPrepInter\@2
_tex3dPrepInter\@1
			move.b	#$53,\4-2-2	;sub
			move.b	#$55,\4-2	;sub
			add.l	#$0000ffff,\1
			neg.w	\1
_tex3dPrepInter\@2
				
			move.l	#0,\3	
			swap	\1
			exg		\1,\2
			move.w	\2,\3
			add.w	\3,\3
			;ext.l	\3
			endm

			macro tex3dPrepInter2
			cmp.l	#0,\1
			bmi.s	_tex3dPrepInter2\@1
			move.b	#$52,\3-2	;add
			bra.s	_tex3dPrepInter2\@2
_tex3dPrepInter2\@1
			move.b	#$53,\3-2	;sub
			add.l	#$0000ffff,\1
			neg.w	\1
_tex3dPrepInter2\@2

			swap	\1
			exg		\1,\2
			endm

			macro tex3dInter
			lea		TEX_SCR_H*2(\1),\1
			add.l	\4,\1
			add.l	\3,\2
			bcc.s	_tex3dDrawFaceIterNoCarry\@1
			addq.l	#1,\2	; add 52, sub 53
			addq.l	#2,\1	; add 54, sub 55
_tex3dDrawFaceIterNoCarry\@1
			endm

			macro tex3dInter2
			add.l	\2,\1
			bcc.s	_tex3dDrawFaceIterNoCarry2\@1
			addq.l	#1,\1	; add 52, sub 53
_tex3dDrawFaceIterNoCarry2\@1
			endm

			macro tex3dDivOrSkip
			cmp.w	#0,\2
			beq.s	_tex3dDivOrSkip\@1
			ext.l	\1
			ext.l	\2
			swap	\1
			divs.l	\2,\1
			bra.s	_tex3dDivOrSkip\@2
_tex3dDivOrSkip\@1		
			moveq.l	#0,\1
_tex3dDivOrSkip\@2		
			endm

			macro tex3dDiv
			ext.l	\1
			swap	\1
			divs.l	\2,\1
			endm

			macro tex3dDrawFaceLineInner
			move.w	d\1,d6
			sub.w	d\2,d6
		
			subq.w	#1,d6
			bmi.s	_tex3dDrawFaceLineEnd\@1
			move.l	a0,a1

			; d3	T_XXxxYYyy_V curr
			; a4	T_XXxxYYyy_V step - shit
			move.l	d3,d4	;XXxxYYyy
			move.w	#0,d4	;XXxx____
			swap	d4		;____XXxx
			ror.l	#8,d4	;xx____XX
			move.b	d4,d5	;______XX
			move.w	d3,d4	;xx__YYyy

			; d4	T_xx__YYyy_H curr
			; d5	T_______XX_H curr
			
			; a5	T_xx__YYyy_H step
			; d1	T_______XX_H step

			movem.l d3/a4,-(a7)	
			;lea		tex3d,a4
			move.l	tex_bgTexPtr,a4
			moveq.l	#0,d3
	
_tex3dDrawFaceLineLoop\@1
			add.l	a5,d4
			addx.b	d1,d5
			move.w	d4,d3
			move.b	d5,d3		
			move.w	(a4,d3.l*2),(a1)+

			dbf	d6,_tex3dDrawFaceLineLoop\@1
			movem.l (a7)+,d3/a4
_tex3dDrawFaceLineEnd\@1			
			endm

			macro tex3dDrawFaceLine
			tex3dDrawFaceLineInner 2,0
			endm

			macro tex3dDrawFaceLine2
			tex3dDrawFaceLineInner 0,2
			endm

			macro tex3dDrawFaceMacro
			; d0	dAC
			; a2	Ax
			; d2	dAB
			; a3	Ax

			tex3dPrepInter1	d0,a2,a6,_tex3dDrawFacePart1_1\@1	;dAC
			tex3dPrepInter2	d2,a3,_tex3dDrawFacePart1_2\@1	;dAB

			; a0 	left side addr
			; a1	left side curr
			; d0 	dAC curr FM
			; a2	dAC	step FM
			; a6	dAC step  M*2
						
			; d2	dAB	curr FM
			; a3	dAB step FM

			; d3	T_XXxxYYyy_V curr
			; a4	T_XXxxYYyy_V step
			; a5	Txx__YYyy_H step
			; d1	T______XX_H step

			; d6	h iter
			; d7	v iter

			move.l	tex_TstepAC,a4	; V step

			subq.w	#1,d7
			bmi.s	_tex3dDrawFacePart2\@1

_tex3dDrawFaceLoop1\@1
			add.l	a4,d3
			tex3dInter	a0,d0,a2,a6
_tex3dDrawFacePart1_1\@1
			tex3dInter2	d2,a3
_tex3dDrawFacePart1_2\@1
			tex3dDrawFaceLine		
			dbf	d7,_tex3dDrawFaceLoop1\@1
_tex3dDrawFacePart2\@1

			move.l	(a7)+,d2
			move.w	(a7)+,a3
			lea		4(a7),a7
			move.w	tex_dyBC,d7
			
			tex3dPrepInter2	d2,a3,_tex3dDrawFacePart2_2\@1	;i
			move.b	_tex3dDrawFacePart1_1\@1-2,_tex3dDrawFacePart2_1\@1-2	
			move.b	_tex3dDrawFacePart1_1\@1-4,_tex3dDrawFacePart2_1\@1-4	

			subq.w	#1,d7
			bmi.w	_tex3dDrawFaceEnd
				
			; d2 	dBC	3
_tex3dDrawFaceLoop2\@1	
			add.l	a4,d3
			tex3dInter	a0,d0,a2,a6
_tex3dDrawFacePart2_1\@1
			tex3dInter2	d2,a3
_tex3dDrawFacePart2_2\@1
			tex3dDrawFaceLine		
			dbf	d7,_tex3dDrawFaceLoop2\@1	
			endm

			; *** MACRO 2 ***
			macro tex3dDrawFaceMacro2
			; d2	dAB
			; a3	Ax
			; d0	dAC
			; a2	Ax
			tex3dPrepInter1 d2,a3,a6,_tex3dDrawFacePart1_1\@2	;dAB
			tex3dPrepInter2	d0,a2,_tex3dDrawFacePart1_2\@2	;dAC

			; a0 	left side addr
			; a1	left side curr	
			; d0 	dAC curr FM
			; a2	dAC	step FM

			; d1	dAB step  M*2
			; d2	dAB	curr FM
			; a3	dAB step FM

			; d6	h iter
			; d7	v iter

			move.l	tex_TstepAB,a4	; V step

			subq.w	#1,d7
			bmi.s	_tex3dDrawFacePart2\@2

_tex3dDrawFaceLoop1\@2
			add.l	a4,d3
			tex3dInter	a0,d2,a3,a6 ;dAB
_tex3dDrawFacePart1_1\@2
			tex3dInter2	d0,a2		;dAC
_tex3dDrawFacePart1_2\@2
			tex3dDrawFaceLine2		
			dbf	d7,_tex3dDrawFaceLoop1\@2
_tex3dDrawFacePart2\@2
			
			move.l	(a7)+,d2
			move.w	(a7)+,a3
			move.l	(a7)+,a0
			move.w	tex_dyBC,d7

			move.l	tex_TstepBC,a4	; V step

			tex3dPrepInter1	d2,a3,a6,_tex3dDrawFacePart2_1\@2	;i
			move.b	_tex3dDrawFacePart1_2\@2-2,_tex3dDrawFacePart2_2\@2-2	

			subq.w	#1,d7
			bmi.w	_tex3dDrawFaceEnd
				
			; d2 	dBC	3
_tex3dDrawFaceLoop2\@2	
			add.l	a4,d3
			tex3dInter	a0,d2,a3,a6
_tex3dDrawFacePart2_1\@2
			tex3dInter2	d0,a2
_tex3dDrawFacePart2_2\@2
			tex3dDrawFaceLine2		
			dbf	d7,_tex3dDrawFaceLoop2\@2	
			endm
