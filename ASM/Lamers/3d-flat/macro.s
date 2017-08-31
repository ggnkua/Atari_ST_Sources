			macro rot3dSortVert
			cmp.w	d\2,d\4
			bge.s	_rot3dDrawFaceSort\@1
			exg		d\1,d\3
			exg		d\2,d\4
_rot3dDrawFaceSort\@1				
			endm

			macro rot3dPrepInter1
			cmp.l	#0,\1
			bmi.s	_rot3dPrepInter\@1
			move.b	#$52,\4-2-2	;add
			move.b	#$54,\4-2	;add
			bra.s	_rot3dPrepInter\@2
_rot3dPrepInter\@1
			move.b	#$53,\4-2-2	;sub
			move.b	#$55,\4-2	;sub
			add.l	#$0000ffff,\1
			neg.w	\1
_rot3dPrepInter\@2
				
			swap	\1
			exg		\1,\2
			move.w	\2,\3
			add.w	\3,\3
			ext.l	\3
			endm

			macro rot3dPrepInter2
			cmp.l	#0,\1
			bmi.s	_rot3dPrepInter2\@1
			move.b	#$52,\3-2	;add
			bra.s	_rot3dPrepInter2\@2
_rot3dPrepInter2\@1
			move.b	#$53,\3-2	;sub
			add.l	#$0000ffff,\1
			neg.w	\1
_rot3dPrepInter2\@2

			swap	\1
			exg		\1,\2
			endm

			macro rot3dInter
			lea		ROT_SCR_H*2(\1),\1
			add.l	\4,\1
			add.l	\3,\2
			bcc.s	_rot3dDrawFaceIterNoCarry\@1
			addq.l	#1,\2	; add 52, sub 53
			addq.l	#2,\1	; add 54, sub 55
_rot3dDrawFaceIterNoCarry\@1
			endm

			macro rot3dInter2
			add.l	\2,\1
			bcc.s	_rot3dDrawFaceIterNoCarry2\@1
			addq.l	#1,\1	; add 52, sub 53
_rot3dDrawFaceIterNoCarry2\@1
			endm

			macro rot3dDivOrSkip
			cmp.w	#0,\2
			beq.s	_rot3dDivOrSkip\@1
			ext.l	\1
			ext.l	\2
			swap	\1
			divs.l	\2,\1
			bra.s	_rot3dDivOrSkip\@2
_rot3dDivOrSkip\@1		
			moveq.l	#0,\1
_rot3dDivOrSkip\@2		
			endm

			macro rot3dDrawFaceLine
			move.l	a0,a1
			move.w	d2,d6
			sub.w	d0,d6
			subq.w	#1,d6
			bmi.s	_rot3dDrawFaceLineEnd\@1
_rot3dDrawFaceLineLoop\@1
			move.w	#$ffff,(a1)+	
			dbf	d6,_rot3dDrawFaceLineLoop\@1
_rot3dDrawFaceLineEnd\@1			
			endm

			macro rot3dDrawFaceLine2
			move.l	a0,a1
			move.w	d0,d6
			sub.w	d2,d6
			subq.w	#1,d6
			bmi.s	_rot3dDrawFaceLineEnd\@2
_rot3dDrawFaceLineLoop\@2
			move.w	#$ffff,(a1)+	
			dbf	d6,_rot3dDrawFaceLineLoop\@2
_rot3dDrawFaceLineEnd\@2			
			endm
			
			macro	rot3dDrawFaceExg
			cmp.w	#0,d7
			bgt.s	_rot3dDrawFaceNotExg\@1
			; a0 <-> a5
			; d0 <-> d4
			; a3 <-> a4
			cmp.w	a3,a4
			\1.s	_rot3dDrawFaceNotExg\@1
			exg	a0,a5
			exg	d0,d4
			exg	a3,a4
_rot3dDrawFaceNotExg\@1

			move.l	a5,-(a7)	;B scr
			move.w	a4,-(a7)	;Bx
			move.l	d4,-(a7)	;dBC

			move.w	a3,a2
			endm

			macro rot3dDrawFaceMacro
			rot3dDrawFaceExg bge
			; d0	dAC
			; a2	Ax
			; d2	dAB
			; a3	Ax

			rot3dPrepInter1	d0,a2,d1,_rot3dDrawFacePart1_1\@1	;dAC
			rot3dPrepInter2	d2,a3,_rot3dDrawFacePart1_2\@1	;dAB

			; a0 	left side addr
			; d0 	dAC curr FM
			; a2	dAC	step FM
			; d1	dAC step  M*2
						
			; d2	dAB	curr FM
			; a3	dAB step FM

			subq.w	#1,d7
			bmi.s	_rot3dDrawFacePart2\@1

_rot3dDrawFaceLoop1\@1
			rot3dInter	a0,d0,a2,d1
_rot3dDrawFacePart1_1\@1
			rot3dInter2	d2,a3
_rot3dDrawFacePart1_2\@1
			rot3dDrawFaceLine		
			move.w	#$f00f,(a0)
			dbf	d7,_rot3dDrawFaceLoop1\@1
_rot3dDrawFacePart2\@1

			move.l	(a7)+,d2
			move.w	(a7)+,a3
			lea		4(a7),a7
			move.w	(a7)+,d7
			
			rot3dPrepInter2	d2,a3,_rot3dDrawFacePart2_2\@1	;i
			move.b	_rot3dDrawFacePart1_1\@1-2,_rot3dDrawFacePart2_1\@1-2	
			move.b	_rot3dDrawFacePart1_1\@1-4,_rot3dDrawFacePart2_1\@1-4	

			subq.w	#1,d7
			bmi.w	_rot3dDrawFaceEnd
				
			; d2 	dBC	3
_rot3dDrawFaceLoop2\@1			
			rot3dInter	a0,d0,a2,d1
_rot3dDrawFacePart2_1\@1
			rot3dInter2	d2,a3
_rot3dDrawFacePart2_2\@1
			rot3dDrawFaceLine		
			move.w	#$00ff,(a0)
			dbf	d7,_rot3dDrawFaceLoop2\@1	
			endm

			; *** MACRO 2 ***
			macro rot3dDrawFaceMacro2
			rot3dDrawFaceExg ble
			
			; d2	dAB
			; a3	Ax
			; d0	dAC
			; a2	Ax
			rot3dPrepInter1 d2,a3,d1,_rot3dDrawFacePart1_1\@2	;dAB
			rot3dPrepInter2	d0,a2,_rot3dDrawFacePart1_2\@2	;dAC

			; a0 	left side addr
			; d0 	dAC curr FM
			; a2	dAC	step FM

			; d1	dAB step  M*2
			; d2	dAB	curr FM
			; a3	dAB step FM

			subq.w	#1,d7
			bmi.s	_rot3dDrawFacePart2\@2

_rot3dDrawFaceLoop1\@2
			rot3dInter	a0,d2,a3,d1 ;dAB
_rot3dDrawFacePart1_1\@2
			rot3dInter2	d0,a2		;dAC
_rot3dDrawFacePart1_2\@2
			rot3dDrawFaceLine2		
			move.w	#$f00f,(a0)
			dbf	d7,_rot3dDrawFaceLoop1\@2
_rot3dDrawFacePart2\@2
			
			move.l	(a7)+,d2
			move.w	(a7)+,a3
			move.l	(a7)+,a0
			move.w	(a7)+,d7
			
			rot3dPrepInter1	d2,a3,d1,_rot3dDrawFacePart2_1\@2	;i
			move.b	_rot3dDrawFacePart1_2\@2-2,_rot3dDrawFacePart2_2\@2-2	

			subq.w	#1,d7
			bmi.w	_rot3dDrawFaceEnd
				
			; d2 	dBC	3
_rot3dDrawFaceLoop2\@2			
			rot3dInter	a0,d2,a3,d1
_rot3dDrawFacePart2_1\@2
			rot3dInter2	d0,a2
_rot3dDrawFacePart2_2\@2
			rot3dDrawFaceLine2		
			move.w	#$00ff,(a0)
			dbf	d7,_rot3dDrawFaceLoop2\@2	
			endm
