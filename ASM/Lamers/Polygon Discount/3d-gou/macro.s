			macro gou3dSortVert
			cmp.w	d\2,d\4
			bge.s	_gou3dDrawFaceSort\@1
			exg		d\1,d\3
			exg		d\2,d\4
			exg		a\5,a\6
_gou3dDrawFaceSort\@1				
			endm

			macro gou3dPrepInter1
			cmp.l	#0,\1
			bmi.s	_gou3dPrepInter\@1
			move.b	#$52,\4-2-2	;add
			move.b	#$54,\4-2	;add
			bra.s	_gou3dPrepInter\@2
_gou3dPrepInter\@1
			move.b	#$53,\4-2-2	;sub
			move.b	#$55,\4-2	;sub
			add.l	#$0000ffff,\1
			neg.w	\1
_gou3dPrepInter\@2
				
			swap	\1
			exg		\1,\2
			move.w	\2,\3
			add.w	\3,\3
			ext.l	\3
			endm

			macro gou3dPrepInter2
			cmp.l	#0,\1
			bmi.s	_gou3dPrepInter2\@1
			move.b	#$52,\3-2	;add
			bra.s	_gou3dPrepInter2\@2
_gou3dPrepInter2\@1
			move.b	#$53,\3-2	;sub
			add.l	#$0000ffff,\1
			neg.w	\1
_gou3dPrepInter2\@2

			swap	\1
			exg		\1,\2
			endm

			macro gou3dInter
			lea		GOU_SCR_H*2(\1),\1
			add.l	\4,\1
			add.l	\3,\2
			bcc.s	_gou3dDrawFaceIterNoCarry\@1
			addq.l	#1,\2	; add 52, sub 53
			addq.l	#2,\1	; add 54, sub 55
_gou3dDrawFaceIterNoCarry\@1
			endm

			macro gou3dInter2
			add.l	\2,\1
			bcc.s	_gou3dDrawFaceIterNoCarry2\@1
			addq.l	#1,\1	; add 52, sub 53
_gou3dDrawFaceIterNoCarry2\@1
			endm

			macro gou3dDivOrSkip
			cmp.w	#0,\2
			beq.s	_gou3dDivOrSkip\@1
			ext.l	\1
			ext.l	\2
			swap	\1
			divs.l	\2,\1
			bra.s	_gou3dDivOrSkip\@2
_gou3dDivOrSkip\@1		
			moveq.l	#0,\1
_gou3dDivOrSkip\@2		
			endm

			macro gou3dDiv
			ext.l	\1
			swap	\1
			divs.l	\2,\1
			endm


			macro gou3dDrawFaceLine
			move.l	a0,a1
			move.l	a6,a5
			move.w	d2,d6
			sub.w	d0,d6
			subq.w	#1,d6
			bmi.s	_gou3dDrawFaceLineEnd\@1
_gou3dDrawFaceLineLoop\@1
			move.w	(a5),(a1)+
			;move.w	#$ffff,(a1)+
			add.l	d4,a5
			dbf	d6,_gou3dDrawFaceLineLoop\@1
_gou3dDrawFaceLineEnd\@1			
			endm

			macro gou3dDrawFaceLine2
			move.l	a0,a1
			move.l	a6,a5
			move.w	d0,d6
			sub.w	d2,d6
			subq.w	#1,d6
			bmi.s	_gou3dDrawFaceLineEnd\@2
_gou3dDrawFaceLineLoop\@2
			move.w	(a5),(a1)+
			;move.w	#$ffff,(a1)+
			add.l	d4,a5
			dbf	d6,_gou3dDrawFaceLineLoop\@2
_gou3dDrawFaceLineEnd\@2			
			endm

			macro gou3dDrawFaceMacro
			; d0	dAC
			; a2	Ax
			; d2	dAB
			; a3	Ax

			gou3dPrepInter1	d0,a2,d1,_gou3dDrawFacePart1_1\@1	;dAC
			gou3dPrepInter2	d2,a3,_gou3dDrawFacePart1_2\@1	;dAB

			; a0 	left side addr
			; d0 	dAC curr FM
			; a2	dAC	step FM
			; d1	dAC step  M*2
						
			; d2	dAB	curr FM
			; a3	dAB step FM

			; d3	dAC	curr C
			; a4	dAC step C
			; d4	dH	step C
			; a5	color table	H curr
			; a6	color table	V curr
			move.l	gou_dCAC,a4
			move.l	a5,d4	;cXstep
			add.l	d3,a6

			subq.w	#1,d7
			bmi.s	_gou3dDrawFacePart2\@1

_gou3dDrawFaceLoop1\@1
			add.l	a4,a6
			gou3dInter	a0,d0,a2,d1
_gou3dDrawFacePart1_1\@1
			gou3dInter2	d2,a3
_gou3dDrawFacePart1_2\@1
			gou3dDrawFaceLine		
			dbf	d7,_gou3dDrawFaceLoop1\@1
_gou3dDrawFacePart2\@1

			move.l	(a7)+,d2
			move.w	(a7)+,a3
			lea		4(a7),a7
			move.w	gou_dyBC,d7
			
			gou3dPrepInter2	d2,a3,_gou3dDrawFacePart2_2\@1	;i
			move.b	_gou3dDrawFacePart1_1\@1-2,_gou3dDrawFacePart2_1\@1-2	
			move.b	_gou3dDrawFacePart1_1\@1-4,_gou3dDrawFacePart2_1\@1-4	

			subq.w	#1,d7
			bmi.w	_gou3dDrawFaceEnd
				
			; d2 	dBC	3
_gou3dDrawFaceLoop2\@1	
			add.l	a4,a6
			gou3dInter	a0,d0,a2,d1
_gou3dDrawFacePart2_1\@1
			gou3dInter2	d2,a3
_gou3dDrawFacePart2_2\@1
			gou3dDrawFaceLine		
			dbf	d7,_gou3dDrawFaceLoop2\@1	
			endm

			; *** MACRO 2 ***
			macro gou3dDrawFaceMacro2
			; d2	dAB
			; a3	Ax
			; d0	dAC
			; a2	Ax
			gou3dPrepInter1 d2,a3,d1,_gou3dDrawFacePart1_1\@2	;dAB
			gou3dPrepInter2	d0,a2,_gou3dDrawFacePart1_2\@2	;dAC

			; a0 	left side addr
			; d0 	dAC curr FM
			; a2	dAC	step FM

			; d1	dAB step  M*2
			; d2	dAB	curr FM
			; a3	dAB step FM

			; d3	dAC	curr C
			; a4	dAB step C
			; d4	dH	step C
			; a5	color table	H curr
			; a6	color table	V curr
			move.l	gou_dCAB,a4
			move.l	a5,d4	;cXstep
			add.l	d3,a6

			subq.w	#1,d7
			bmi.s	_gou3dDrawFacePart2\@2

_gou3dDrawFaceLoop1\@2
			add.l	a4,a6
			gou3dInter	a0,d2,a3,d1 ;dAB
_gou3dDrawFacePart1_1\@2
			gou3dInter2	d0,a2		;dAC
_gou3dDrawFacePart1_2\@2
			gou3dDrawFaceLine2		
			dbf	d7,_gou3dDrawFaceLoop1\@2
_gou3dDrawFacePart2\@2
			
			move.l	(a7)+,d2
			move.w	(a7)+,a3
			move.l	(a7)+,a0
			move.w	gou_dyBC,d7

			move.l	gou_dCBC,a4
			
			gou3dPrepInter1	d2,a3,d1,_gou3dDrawFacePart2_1\@2	;i
			move.b	_gou3dDrawFacePart1_2\@2-2,_gou3dDrawFacePart2_2\@2-2	

			subq.w	#1,d7
			bmi.w	_gou3dDrawFaceEnd
				
			; d2 	dBC	3
_gou3dDrawFaceLoop2\@2	
			add.l	a4,a6	
			gou3dInter	a0,d2,a3,d1
_gou3dDrawFacePart2_1\@2
			gou3dInter2	d0,a2
_gou3dDrawFacePart2_2\@2
			gou3dDrawFaceLine2		
			dbf	d7,_gou3dDrawFaceLoop2\@2	
			endm
