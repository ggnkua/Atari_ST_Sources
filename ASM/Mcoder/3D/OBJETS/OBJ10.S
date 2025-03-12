FACE3	MACRO
	ENDM
FACE4	MACRO
	ENDM
FACE5	MACRO
	ENDM
FACE6	MACRO
	ENDM
FACE7	MACRO
	ENDM

		* Exemple de forme 3D ---> un cube
cube:
	dc.w	8		* 8 points
	dc.w	-100,-100,-100
	dc.w	100,-100,-100
	dc.w	100,100,-100
	dc.w	-100,100,-100
	dc.w	-100,-100,100
	dc.w	100,-100,100
	dc.w	100,100,100
	dc.w	-100,100,100
	
	FACE4	0,-1,4,5,6,7
	FACE4	1,-1,7,6,2,3
	FACE4	2,-1,0,1,5,4
	FACE4	0,-1,4,7,3,0
	FACE4	1,-1,1,2,6,5
	FACE4	2,-1,3,2,1,0
	
cube2:
	dc.w	8		* 8 points
	dc.w	-100,-100,-100
	dc.w	100,-100,-100
	dc.w	100,100,-100
	dc.w	-100,100,-100
	dc.w	-100,-100,100
	dc.w	100,-100,100
	dc.w	100,100,100
	dc.w	-100,100,100
	
	FACE4	0,-1,3,7,4,0
	FACE4	1,-1,0,4,5,1
	FACE4	0,-1,1,5,6,2
	FACE4	1,-1,2,6,7,3
	FACE4	2,-1,0,4,7,3
	FACE4	3,-1,1,5,4,0
	FACE4	2,-1,2,6,5,1
	FACE4	3,-1,3,7,6,2

				* un tetraede
tri:
	dc.w	5
	dc.w	0,150,0
	dc.w	-100,0,-100
	dc.w	100,0,-100
	dc.w	100,0,100
	dc.w	-100,0,100
	
	FACE3	0,-1,0,2,1
	FACE3	1,-1,0,3,2
	FACE3	2,-1,0,4,3
	FACE3	3,-1,0,1,4
	FACE4	0,-1,1,2,3,4
	
carre:
	dc.w	4
	dc.w	-300,-300,-300
	dc.w	-300,-300,300
	dc.w	300,-300,300
	dc.w	300,-300,-300

	FACE4	0,-1,0,1,2,3
	FACE4	0,-1,3,2,1,0
	
OBJET	MACRO
	dc.l	\1
	dc.w	\2,\3,\4,\5,\6,\7
	endm
	
alliance:
	dc.w	22		;22 points.
*********************
	dc.w	-32,80,-32	;Points No 0
	dc.w	-32,80,32		;Points No 1
	dc.w	32,80,-32		;Points No 2
	dc.w	32,80,32		;Points No 3
	dc.w	112,-80,-32	;Points No 4
	dc.w	112,-80,32	;Points No 5
	dc.w	48,-80,-32	;Points No 6
	dc.w	48,-80,32		;Points No 7
	dc.w	32,-48,-32	;Points No 8
	dc.w	32,-48,32		;Points No 9
	dc.w	-32,-48,-32	;Points No 10
	dc.w	-32,-48,32	;Points No 11
	dc.w	-48,-80,-32	;Points No 12
	dc.w	-48,-80,32	;Points No 13
	dc.w	-112,-80,-32	;Points No 14
	dc.w	-112,-80,32	;Points No 15
	dc.w	-16,-16,-32	;Points No 16
	dc.w	-16,-16,32	;Points No 17
	dc.w	16,-16,-32	;Points No 18
	dc.w	16,-16,32		;Points No 19
	dc.w	0,16,-32		;Points No 20
	dc.w	0,16,32		;Points No 21


	dc.w	17		;17 faces.
*********************
	FACE4	0,-1,19,21,20,18
	FACE4	1,-1,21,17,16,20
	FACE4	0,-1,17,19,18,16
	FACE4	1,-1,1,3,2,0
	FACE4	1,-1,5,7,6,4
	FACE4	1,-1,9,11,10,8
	FACE4	1,-1,13,15,14,12
	FACE4	0,-1,3,5,4,2
	FACE4	0,-1,7,9,8,6
	FACE4	0,-1,11,13,12,10
	FACE4	0,-1,15,1,0,14
	FACE4	2,-1,16,18,8,10
	FACE7	2,-1,0,2,20,16,10,12,14
	FACE6	2,-1,2,4,6,8,18,20
	FACE4	3,-1,11,9,19,17
	FACE7	3,-1,1,15,13,11,17,21,3
	FACE6	3,-1,7,5,3,21,19,9

craft:
	dc.w	14		;14 points.
*********************
	dc.w	0,0,100		;Points No 0
	dc.w	0,10,10		;Points No 1
	dc.w	0,-10,10		;Points No 2
	dc.w	-21,0,10		;Points No 3
	dc.w	19,0,10		;Points No 4
	dc.w	0,19,-21		;Points No 5
	dc.w	0,12,-100		;Points No 6
	dc.w	0,-6,-100		;Points No 7
	dc.w	-12,0,-100	;Points No 8
	dc.w	12,0,-100		;Points No 9
	dc.w	-165,0,-61	;Points No 10
	dc.w	-168,0,-85	;Points No 11
	dc.w	168,0,-85		;Points No 12
	dc.w	168,0,-61		;Points No 13


	dc.w	15		;14 faces.
*********************
	FACE3	0,-1,3,1,5
	FACE3	0,-1,1,4,5
	FACE3	1,-1,3,0,1
	FACE3	2,-1,0,4,1
	FACE3	3,-1,2,0,3
	FACE3	1,-1,2,4,0
	FACE4	1,-1,8,3,5,6
	FACE4	2,-1,4,9,6,5
	FACE4	3,-1,7,2,3,8
	FACE4	1,-1,4,2,7,9
	FACE4	0,-1,9,7,8,6
	FACE4	0,-1,3,8,11,10
	FACE4	0,-1,4,13,12,9
	FACE4	0,-1,10,11,8,3
	FACE4	0,-1,9,12,13,4

DODE	MACRO	
	DC.W	\1,\2,\3
	ENDM


dodecaedre
	DC.W	20

	DODE	283,631,390
	DODE	458,631,-149
	DODE	0,631,-482
	DODE	-458,631,-149
	DODE	-283,631,390
	DODE	-458,149,631
	DODE	0,-149,780
	DODE	458,149,631
	DODE	742,-149,241
	DODE	742,149,-241
	DODE	458,-149,-631
	DODE	0,149,-780
	DODE	-458,-149,-631
	DODE	-742,149,-241
	DODE	-742,-149,241
	DODE	-283,-631,-390
	DODE	-458,-631,149
	DODE	0,-631,482
	DODE	458,-631,149
	DODE	283,-631,-390


fdodecaedre
	DC.W	12	

	FACE5	0,-1,0,1,2,3,4
	FACE5	1,-1,0,4,5,6,7
	FACE5	2,-1,0,7,8,9,1
	FACE5	3,-1,1,9,10,11,2
	FACE5	0,-1,2,11,12,13,3
	FACE5	1,-1,3,13,14,5,4
	FACE5	2,-1,12,15,16,14,13
	FACE5	3,-1,14,16,17,6,5
	FACE5	0,-1,6,17,18,8,7
	FACE5	1,-1,8,18,19,10,9
	FACE5	2,-1,11,10,19,15,12
	FACE5	3,-1,17,16,15,19,18
