 ; #[ :
	; #[ Quelques MACROs:

;------------------------------
; Liste des routine:	;
;------------------------------
; 'Defp' : def_plot	;
; 'Anim' : anime_plot	;
; 'Inic' : init_color	;
; 'Setc' : set_color	;
; 'Affp' : call_poly	;
; 'F1p ' : face1p	;
; 'F1pt' : face1pt	;
; 'ipti' : faceipti	;
; 'Vert' : vertices	;
; 'Sphr' : sphere	;
; 'Hide' : hide	;
; 'Goto' : goto	;
; 'Enab' : enable	;
; 'Disa' : disable	;
; 'Fin ' : fin_afforme	;
;------------------------------

debut:
TRUE	=	-1
FALSE	=	0

	opt	x-
	
Flab	MACRO
coucou\@:
	ENDM
	
Def_plot	MACRO
	dc.b	'Defp'
	dc.l	\1-*
	ENDM
	
Anime_plot	MACRO
	dc.b	'Anim'
	dc.l	\1-*
	dc.w	0
	ENDM

Plot	MACRO
	dc.w	\1,\2,\3
	ENDM
	
Finplot	MACRO
	dc.w	$8000
	ENDM
	
Finanime	MACRO
	dc.w	$8000
	ENDM
	
Set_color	MACRO
	dc.b	'Setc'
	dc.w	\1
	ENDM
	
Affpoly	MACRO
	dc.b	'Affp'
	ENDM
	
Face1p	MACRO
	dc.b	'F1p '
	ENDM
	
Face1pt	MACRO
	dc.b	'F1pt'
	ENDM
	
Face1pti	MACRO
	dc.b	'1pti'
	ENDM
	
Face1pc	MACRO
	dc.b	'F1p '
	dc.b	'Setc'
	dc.w	\1
	dc.b	'Affp'
	ENDM
	
Face1ptc	MACRO
	dc.b	'F1pt'
	dc.b	'Setc'
	dc.w	\1
	dc.b	'Affp'
	ENDM
	
Face1ptic	MACRO
	dc.b	'1pti'
	dc.b	'Setc'
	dc.w	\1
	dc.b	'Affp'
	ENDM
	
Init_color	MACRO
	dc.b	'Inic'
	dc.w	\1
	ENDM
	
Vertices	MACRO
	dc.b	'Vert'
	
	IFGE	NARG-1
	dc.w	\1
	ENDC
	IFGE	NARG-2
	dc.w	\2
	ENDC
	IFGE	NARG-3
	dc.w	\3
	ENDC
	IFGE	NARG-4
	dc.w	\4
	ENDC
	IFGE	NARG-5
	dc.w	\5
	ENDC
	IFGE	NARG-6
	dc.w	\6
	ENDC
	IFGE	NARG-7
	dc.w	\7
	ENDC
	IFGE	NARG-8
	dc.w	\8
	ENDC
	dc.w	-1
	
	ENDM
	
Sphere	MACRO
	dc.b	'Shpr'
	dc.w	\1,\2
	ENDM
	
Hide	MACRO
	dc.b	'Hide'
	dc.w	\1,\2,\3
	dc.w	\4-*
	ENDM
	
Goto	MACRO
	dc.b	'Goto'
	dc.w	\1-*
	ENDM
	
Enable	MACRO
	dc.b	'Enab'
	dc.w	\1-*
	ENDM
	
Disable	MACRO
	dc.b	'Disa'
	dc.w	\1-*
	ENDM
	
Fin	MACRO
	dc.b	'Fin '
	ENDM
	
Defobjet	MACRO
	dc.l	\1-debut
	ENDM
	
	; #] Quelques MACROs:
	IFNE	FALSE
	; #[ Save file:
	pea	name
	move.w	#$41,-(a7)
	trap	#1
	addq.l	#6,a7

	move.w	#0,-(a7)
	pea	name
	move.w	#$3c,-(a7)
	trap	#1
	addq.l	#8,a7
	move.w	d0,handle
	
	pea	debut
	move.l	#fin-debut,-(a7)
	move.w	handle,-(a7)
	move.w	#$40,-(a7)
	trap	#1
	add.l	#12,a7
	
	move.w	handle,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	
	clr	-(a7)
	trap	#1

handle	dc.w	0	
name:
	dc.b	"objets.bin",0
	even
	; #] Save file:
	ENDC
 ; #] :
; La palette utilis‚e:
;$000,$333,$444,$555,$666,$330,$550,$770,$700,$500,$005,$007,$300,$500,$700,$777
;  0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15

	Defobjet	cube
	Defobjet	alliance
	Defobjet	dodecaedre
	Defobjet	vaisseau
	Defobjet	boule
	Defobjet	pyramide
	Defobjet	deliro_cylindre
	Defobjet	cubet
	
	; #[ Cube:
cube_plot:
	Plot	-100,-100,-100	;0
	Plot	100,-100,-100	;1
	Plot	100,100,-100	;2
	Plot	-100,100,-100	;3
	Plot	-100,-100,100	;4
	Plot	100,-100,100	;5
	Plot	100,100,100	;6
	Plot	-100,100,100	;7
	Finplot
	
cube:
	Flab
	Def_plot	cube_plot
	Init_color	15
	
	Hide	3,2,1,.next3
	Vertices	3,2,1,0
	Face1ptc	2
	
.next1:
	Hide	7,6,2,.next4
	Vertices	7,6,2,3
	Face1pc	4
.next2:
	Hide	4,7,3,.next5
	Vertices	4,7,3,0
	Face1pc	2
	
	Fin
	
.next3:
	Hide	4,5,6,.next1
	Vertices	4,5,6,7
	Face1ptc	2
	Goto	.next1
.next4:
	Hide	0,1,5,.next2
	Vertices	0,1,5,4
	Face1pc	4
	Goto	.next2
.next5:
	Hide	1,2,6,.next6
	Vertices	1,2,6,5
	Face1pc	2
	
.next6:
	Fin
	
	; #] Cube:
	; #[ Alliance:
alliance_plot:
	Plot	-32,80,-32	;0
	Plot	-32,80,32	;1
	Plot	32,80,-32	;2
	Plot	32,80,32	;3
	Plot	112,-80,-32	;4
	Plot	112,-80,32	;5
	Plot	48,-80,-32	;6
	Plot	48,-80,32	;7
	Plot	32,-48,-32	;8
	Plot	32,-48,32	;9
	Plot	-32,-48,-32	;10
	Plot	-32,-48,32	;11
	Plot	-48,-80,-32	;12
	Plot	-48,-80,32	;13
	Plot	-112,-80,-32	;14
	Plot	-112,-80,32	;15
	Plot	-16,-16,-32	;16
	Plot	-16,-16,32	;17
	Plot	16,-16,-32	;18
	Plot	16,-16,32	;19
	Plot	0,16,-32	;20
	Plot	0,16,32	;21

	Finplot

alliance:
	Def_plot	alliance_plot	
	Init_color	15

		; L'interieur du A
	Flab
	Hide	17,19,18,.next
	Vertices	17,19,18,16
	Face1pc	3		;8
.next:
	Flab
	Hide	19,21,20,.next
	Vertices	19,21,20,18
	Face1ptc	3		;9
.next:
	Flab
	Hide	21,17,16,.next
	Vertices	21,17,16,20
	Face1ptc	3		;10
.next:

		; Le dessus	
	Flab
	Hide	1,3,2,.next
	Vertices	1,3,2,0
	Face1pc	3		;0
.next:

		; Le dessous
	Flab
	Hide	5,7,6,.next
	Vertices	5,7,6,4
	Face1ptc	3		;2
.next:
	Flab
	Hide	7,9,8,.next
	Vertices	7,9,8,6
	Face1pc	3		;3
.next:
	Flab
	Hide	9,11,10,.next
	Vertices	9,11,10,8
	Face1ptc	3		;4
.next:
	Flab
	Hide	11,13,12,.next
	Vertices	11,13,12,10
	Face1pc	3		;5
.next:
	Flab
	Hide	13,15,14,.next
	Vertices	13,15,14,12
	Face1ptc	3		;6
.next:

		; Les deux grands bords
	Flab
	Hide	3,5,4,.next
	Vertices	3,5,4,2
	Face1pc	4		;1
.next:
	Flab
	Hide	14,15,1,.next
	Vertices	14,15,1,0
	Face1pc	4		;7
.next:

		; Les deux faces du A
	Flab
	Hide	16,18,8,.next
	Vertices	16,18,8,10
	Set_color	6
	Face1p
	Affpoly
	Vertices	20,2,4,6,8,18
	Affpoly
	Vertices	14,0,2,20,16,10,12
	Affpoly
	Goto	.next2
.next:
	Hide	11,9,19,.next2
	Vertices	11,9,19,17
	Set_color	5
	Face1p
	Affpoly
	Vertices	1,15,13,11,17,21,3
	Affpoly
	Vertices	7,5,3,21,19,9
	Affpoly
.next2:

	Fin	

	; #] Alliance:
	; #[ Dodecaedre:
dodecaedre_plot:
	Plot	283,631,390
	Plot	458,631,-149
	Plot	0,631,-482
	Plot	-458,631,-149
	Plot	-283,631,390
	Plot	-458,149,631
	Plot	0,-149,780
	Plot	458,149,631
	Plot	742,-149,241
	Plot	742,149,-241
	Plot	458,-149,-631
	Plot	0,149,-780
	Plot	-458,-149,-631
	Plot	-742,149,-241
	Plot	-742,-149,241
	Plot	-283,-631,-390
	Plot	-458,-631,149
	Plot	0,-631,482
	Plot	458,-631,149
	Plot	283,-631,-390
	
	Finplot
	
dodecaedre:
	Def_plot	dodecaedre_plot
	Init_color	3

	Flab
	Hide	0,1,2,.next
	Vertices	0,1,2,3,4
	Face1pc	1
.next:
	Flab
	Hide	0,4,5,.next
	Vertices	0,4,5,6,7
	Face1pc	2
.next:
	Flab
	Hide	0,7,8,.next
	Vertices	0,7,8,9,1
	Face1pc	3
.next:
	Flab
	Hide	1,9,10,.next
	Vertices	1,9,10,11,2
	Face1pc	4
.next:
	Flab
	Hide	2,11,12,.next
	Vertices	2,11,12,13,3
	Face1ptc	1
.next:
	Flab
	Hide	3,13,14,.next
	Vertices	3,13,14,5,4
	Face1ptc	2
.next:
	Flab
	Hide	12,15,16,.next
	Vertices	12,15,16,14,13
	Face1ptc	3
.next:
	Flab
	Hide	14,16,17,.next
	Vertices	14,16,17,6,5
	Face1ptc	4
.next:
	Flab
	Hide	6,17,18,.next
	Vertices	6,17,18,8,7
	Face1pc	1
.next:
	Flab
	Hide	8,18,19,.next
	Vertices	8,18,19,10,9
	Face1ptc	2
.next:
	Flab
	Hide	11,10,19,.next
	Vertices	11,10,19,15,12
	Face1pc	3
.next:
	Flab
	Hide	17,16,15,.next
	Vertices	17,16,15,19,18
	Face1pc	4
.next:
	
	Fin
	
	; #] Dodecaedre:
	; #[ Vaisseau:
vaisseau_plot:
	Plot	-200,100,-400		;0
	Plot	-500,00,-400		;1
	Plot	-200,-100,-400		;2
	Plot	200,-100,-400		;3
	Plot	200,100,-400		;4
	Plot	500,00,-400		;5
	Plot	200,00,400		;6
	Plot	-200,00,400		;7

	Finplot

vaisseau:
	Def_plot	vaisseau_plot
	Init_color	3

*********************
	Flab
	Hide	1,7,0,.next
	Vertices	1,7,0
	Face1pc	2		;0
.next:
	Flab
	Hide	0,7,6,.next
	Vertices	0,7,6,4
	Face1pc	3		;1
.next:
	Flab
	Hide	4,6,5,.next
	Vertices	4,6,5
	Face1pc	2		;2
.next:
	Flab
	Hide	2,7,1,.next
	Vertices	2,7,1
	Face1pc	3		;4
.next:
	Flab
	Hide	3,5,6,.next
	Vertices	3,5,6
	Face1pc	3		;5
.next:
	Flab
	Hide	2,3,6,.next
	Vertices	2,3,6,7
	Face1pc	2		;6
.next:
	Flab
	Hide	1,0,4,.next
	Vertices	1,0,4,5,3,2
	Face1ptc	12		;3
.next:
	
	Fin

	; #] Vaisseau:
	; #[ Boule:
boule_plot:
	Plot	0,96,0	;0
	Plot	64,80,0	;1
	Plot	96,48,0	;2
	Plot	112,0,0	;3
	Plot	96,-48,0	;4
	Plot	64,-80,0	;5
	Plot	0,-98,0	;6
	Plot	45,80,45	;7
	Plot	67,48,67	;8
	Plot	79,0,79	;9
	Plot	67,-48,67	;10
	Plot	45,-80,45	;11
	Plot	0,80,64	;12
	Plot	0,48,96	;13
	Plot	0,0,112	;14
	Plot	0,-48,96	;15
	Plot	0,-80,64	;16
	Plot	-46,80,45	;17
	Plot	-68,48,67	;18
	Plot	-80,0,79	;19
	Plot	-68,-48,67	;20
	Plot	-46,-80,45	;21
	Plot	-64,80,0	;22
	Plot	-96,48,0	;23
	Plot	-112,0,0	;24
	Plot	-96,-48,0	;25
	Plot	-64,-80,0	;26
	Plot	-46,80,-46	;27
	Plot	-68,48,-68	;28
	Plot	-80,0,-80	;29
	Plot	-68,-48,-68	;30
	Plot	-46,-80,-46	;31
	Plot	0,80,-64	;32
	Plot	0,48,-96	;33
	Plot	0,0,-112	;34
	Plot	0,-48,-96	;35
	Plot	0,-80,-64	;36
	Plot	45,80,-46	;37
	Plot	67,48,-68	;38
	Plot	79,0,-80	;39
	Plot	67,-48,-68	;40
	Plot	45,-80,-46	;41
	Plot	0,96-32,0	;42, Centre de la sphere
	
	Finplot

boule:
	Def_plot	boule_plot	
	Init_color	11

	IFNE	TRUE
		********************* Interieur
	Set_color	11
	Face1p
	Flab
	Hide	7,12,0,.next
	Vertices	7,12,0
	Disable	boule1
	Affpoly		;0
	Goto	.next2
.next:
	Enable	boule1
.next2:
	Flab
	Hide	17,22,0,.next
	Vertices	17,22,0
	Disable	boule2
	Affpoly		;1
	Goto	.next2
.next:
	Enable	boule2
.next2:
	Flab
	Hide	27,32,0,.next
	Vertices	27,32,0
	Disable	boule3
	Affpoly		;2
	Goto	.next2
.next:
	Enable	boule3
.next2:
	Flab
	Hide	37,1,0,.next
	Vertices	37,1,0
	Disable	boule4
	Affpoly		;3
	Goto	.next2
.next:
	Enable	boule4
.next2:
	Flab
	Hide	2,8,7,.next
	Vertices	2,8,7,1
	Disable	boule5
	Affpoly		;4
	Goto	.next2
.next:
	Enable	boule5
.next2:
	Flab
	Hide	13,18,17,.next
	Vertices	13,18,17,12
	Disable	boule6
	Affpoly		;5
	Goto	.next2
.next:
	Enable	boule6
.next2:
	Flab
	Hide	23,28,27,.next
	Vertices	23,28,27,22
	Disable	boule7
	Affpoly		;6
	Goto	.next2
.next:
	Enable	boule7
.next2:
	Flab
	Hide	33,38,37,.next
	Vertices	33,38,37,32
	Disable	boule8
	Affpoly		;7
	Goto	.next2
.next:
	Enable	boule8
.next2:
	Flab
	Hide	9,14,13,.next
	Vertices	9,14,13,8
	Disable	boule9
	Affpoly		;8
	Goto	.next2
.next:
	Enable	boule9
.next2:
	Flab
	Hide	19,24,23,.next
	Vertices	19,24,23,18
	Disable	boule10
	Affpoly		;9
	Goto	.next2
.next:
	Enable	boule10
.next2:
	Flab
	Hide	29,34,33,.next
	Vertices	29,34,33,28
	Disable	boule11
	Affpoly		;10
	Goto	.next2
.next:
	Enable	boule11
.next2:
	Flab
	Hide	39,3,2,.next
	Vertices	39,3,2,38
	Disable	boule12
	Affpoly		;11
	Goto	.next2
.next:
	Enable	boule12
.next2:
	Flab
	Hide	4,10,9,.next
	Vertices	4,10,9,3
	Disable	boule13
	Affpoly		;12
	Goto	.next2
.next:
	Enable	boule13
.next2:
	Flab
	Hide	15,20,19,.next
	Vertices	15,20,19,14
	Disable	boule14
	Affpoly		;13
	Goto	.next2
.next:
	Enable	boule14
.next2:
	Flab
	Hide	25,30,29,.next
	Vertices	25,30,29,24
	Disable	boule15
	Affpoly		;14
	Goto	.next2
.next:
	Enable	boule15
.next2:
	Flab
	Hide	35,40,39,.next
	Vertices	35,40,39,34
	Disable	boule16
	Affpoly		;15
	Goto	.next2
.next:
	Enable	boule16
.next2:
	Flab
	Hide	11,16,15,.next
	Vertices	11,16,15,10
	Disable	boule17
	Affpoly		;16
	Goto	.next2
.next:
	Enable	boule17
.next2:
	Flab
	Hide	21,26,25,.next
	Vertices	21,26,25,20
	Disable	boule18
	Affpoly		;17
	Goto	.next2
.next:
	Enable	boule18
.next2:
	Flab
	Hide	31,36,35,.next
	Vertices	31,36,35,30
	Disable	boule19
	Affpoly		;18
	Goto	.next2
.next:
	Enable	boule19
.next2:
	Flab
	Hide	41,5,4,.next
	Vertices	41,5,4,40
	Disable	boule20
	Affpoly		;19
	Goto	.next2
.next:
	Enable	boule20
.next2:
	Flab
	Hide	6,11,5,.next
	Vertices	6,11,5
	Disable	boule21
	Affpoly		;20
	Goto	.next2
.next:
	Enable	boule21
.next2:
	Flab
	Hide	6,21,16,.next
	Vertices	6,21,16
	Disable	boule22
	Affpoly		;21
	Goto	.next2
.next:
	Enable	boule22
.next2:
	Flab
	Hide	6,31,26,.next
	Vertices	6,31,26
	Disable	boule23
	Affpoly		;22
	Goto	.next2
.next:
	Enable	boule23
.next2:
	Flab
	Hide	6,41,36,.next
	Vertices	6,41,36
	Disable	boule24
	Affpoly		;23
	Goto	.next2
.next:
	Enable	boule24
.next2:
	ENDC	
	
			********** La boule
	Face1p
	Set_color	3
	Sphere	42,32
	
		********************* Exterieur
	Face1pt
	Set_color	13
	Flab
boule1:
	Hide	0,12,7,.next
	Vertices	0,12,7
	Affpoly	
.next:
	Flab
boule2:
	Hide	0,22,17,.next
	Vertices	0,22,17
	Affpoly		;1
.next:
	Flab
boule3:
	Hide	0,32,27,.next
	Vertices	0,32,27
	Affpoly		;2
.next:
	Flab
boule4:
	Hide	0,1,37,.next
	Vertices	0,1,37
	Affpoly		;3
.next:
	Flab
boule9:
	Hide	8,13,14,.next
	Vertices	8,13,14,9
	Affpoly		;8
.next:
	Flab
boule10:
	Hide	18,23,24,.next
	Vertices	18,23,24,19
	Affpoly		;9
.next:
	Flab
boule11:
	Hide	28,33,34,.next
	Vertices	28,33,34,29
	Affpoly		;10
.next:
	Flab
boule12:
	Hide	38,2,3,.next
	Vertices	38,2,3,39
	Affpoly		;11
.next:
	Flab
boule17:
	Hide	10,15,16,.next
	Vertices	10,15,16,11
	Affpoly		;16
.next:
	Flab
boule18:
	Hide	20,25,26,.next
	Vertices	20,25,26,21
	Affpoly		;17
.next:
	Flab
boule19:
	Hide	30,35,36,.next
	Vertices	30,35,36,31
	Affpoly		;18
.next:
	Flab
boule20:
	Hide	40,4,5,.next
	Vertices	40,4,5,41
	Affpoly		;19
.next:
	
	Set_color	14
	Flab
boule5:
	Hide	1,7,8,.next
	Vertices	1,7,8,2
	Affpoly		;4
.next:
	Flab
boule6:
	Hide	12,17,18,.next
	Vertices	12,17,18,13
	Affpoly		;5
.next:
	Flab
boule7:
	Hide	22,27,28,.next
	Vertices	22,27,28,23
	Affpoly		;6
.next:
	Flab
boule8:
	Hide	32,37,38,.next
	Vertices	32,37,38,33
	Affpoly		;7
.next:
	Flab
boule13:
	Hide	3,9,10,.next
	Vertices	3,9,10,4
	Affpoly		;12
.next:
	Flab
boule14:
	Hide	14,19,20,.next
	Vertices	14,19,20,15
	Affpoly		;13
.next:
	Flab
boule15:
	Hide	24,29,30,.next
	Vertices	24,29,30,25
	Affpoly		;14
.next:
	Flab
boule16:
	Hide	34,39,40,.next
	Vertices	34,39,40,35
	Affpoly		;15
.next:
	Flab
boule21:
	Hide	5,11,6,.next
	Vertices	5,11,6
	Affpoly		;20
.next:
	Flab
boule22:
	Hide	16,21,6,.next
	Vertices	16,21,6
	Affpoly		;21
.next:
	Flab
boule23:
	Hide	26,31,6,.next
	Vertices	26,31,6
	Affpoly		;22
.next:
	Flab
boule24:
	Hide	36,41,6,.next
	Vertices	36,41,6
	Affpoly		;23
.next:
	
	Fin
	
	; #] Boule:
	; #[ Pyramide:
pyramide_plot:
	Plot	0,150,0
	Plot	-100,0,-100
	Plot	100,0,-100
	Plot	100,0,100
	Plot	-100,0,100
	Finplot
	
pyramide:
	Def_plot	pyramide_plot
	Init_color	3
	
	Flab
	Hide	0,2,1,.next1
	Vertices	0,2,1
	Face1pc	8
.next1:
	Flab
	Hide	0,3,2,.next2
	Vertices	0,3,2
	Face1pc	11
.next2:
	Flab
	Hide	0,4,3,.next3
	Vertices	0,4,3
	Face1pc	9
.next3:
	Flab
	Hide	0,1,4,.next4
	Vertices	0,1,4
	Face1pc	11
.next4:
	Flab
	Hide	1,2,3,.next5
	Vertices	1,2,3,4
	Face1pc	4
.next5:
	
	Fin
	
	; #] Pyramide:
	; #[ Deliro cylindre:
		; 26 faces.
deliro_cylindre:
	Anime_plot	deliro_cylindre_plot
	Init_color	15
	
	Flab
	Hide	0,4,5,.next
	Vertices	0,4,5,1
	Face1pc	11
.next:
	Flab
	Hide	1,5,6,.next
	Vertices	1,5,6,2
	Face1pc	10
.next:
	Flab
	Hide	2,6,7,.next
	Vertices	2,6,7,3
	Face1pc	11
.next:
	Flab
	Hide	3,7,4,.next
	Vertices	3,7,4,0
	Face1pc	10
.next:
	Flab
	Hide	4,8,9,.next
	Vertices	4,8,9,5
	Face1pc	10
.next:
	Flab
	Hide	5,9,10,.next
	Vertices	5,9,10,6
	Face1pc	11
.next:
	Flab
	Hide	6,10,11,.next
	Vertices	6,10,11,7
	Face1pc	10
.next:
	Flab
	Hide	7,11,8,.next
	Vertices	7,11,8,4
	Face1pc	11
.next:
	Flab
	Hide	8,12,13,.next
	Vertices	8,12,13,9
	Face1pc	11
.next:
	Flab
	Hide	9,13,14,.next
	Vertices	9,13,14,10
	Face1pc	10
.next:
	Flab
	Hide	10,14,15,.next
	Vertices	10,14,15,11
	Face1pc	11
.next:
	Flab
	Hide	11,15,12,.next
	Vertices	11,15,12,8
	Face1pc	10
.next:
	Flab
	Hide	12,16,17,.next
	Vertices	12,16,17,13
	Face1pc	10
.next:
	Flab
	Hide	13,17,18,.next
	Vertices	13,17,18,14
	Face1pc	11
.next:
	Flab
	Hide	14,18,19,.next
	Vertices	14,18,19,15
	Face1pc	10
.next:
	Flab
	Hide	15,19,16,.next
	Vertices	15,19,16,12
	Face1pc	11
.next:
	Flab
	Hide	16,20,21,.next
	Vertices	16,20,21,17
	Face1pc	11
.next:
	Flab
	Hide	17,21,22,.next
	Vertices	17,21,22,18
	Face1pc	10
.next:
	Flab
	Hide	18,22,23,.next
	Vertices	18,22,23,19
	Face1pc	11
.next:
	Flab
	Hide	19,23,20,.next
	Vertices	19,23,20,16
	Face1pc	10
.next:
	Flab
	Hide	20,24,25,.next
	Vertices	20,24,25,21
	Face1pc	10
.next:
	Flab
	Hide	21,25,26,.next
	Vertices	21,25,26,22
	Face1pc	11
.next:
	Flab
	Hide	22,26,27,.next
	Vertices	22,26,27,23
	Face1pc       	10
.next:
	Flab
	Hide	23,27,24,.next
	Vertices	23,27,24,20
	Face1pc	11
.next:

	Flab
	Hide	0,1,2,.next
	Vertices	0,1,2,3
	Face1ptc	12
	Goto	.next2
.next:
	Hide	27,26,25,.next2
	Vertices	27,26,25,24
	Face1ptc	12
.next2:

	Fin

	; #] Deliro cylindre:
	; #[ Cubet:
cubet_plot:
	Plot	-100,-200,-100	;0
	Plot	100,-200,-100	;1
	Plot	100,200,-100	;2
	Plot	-100,200,-100	;3
	Plot	-100,-200,100	;4
	Plot	100,-200,100	;5
	Plot	100,200,100	;6
	Plot	-100,200,100	;7

	Plot	-100,-100,-400	;8
	Plot	100,-100,-400	;9	
	Plot	100,100,-400	;10
	Plot	-100,100,-400	;11
	
	Plot	400,-100,-100	;12
	Plot	400,-100,100	;13
	Plot	400,100,100	;14
	Plot	400,100,-100	;15

	Plot	-400,-100,-100	;16
	Plot	-400,-100,100	;17
	Plot	-400,100,100	;18
	Plot	-400,100,-100	;19

	Plot	-100,-100,400	;20
	Plot	100,-100,400	;21
	Plot	100,100,400	;22
	Plot	-100,100,400	;23
	
	Plot	0,300,0	;24 : Centre de la sphere haute
	Plot	0,-300,0	;25 : Centre de la sphere basse
	
	Finplot
	
cubet:
	Def_plot	cubet_plot
	Init_color	10

	Set_color	2
	Set_color	4
	Set_color	11
	
			; Le tour de l'objet
		
	Flab
	Hide	8,9,10,.next1
	Vertices	8,9,10,11
	Face1pc	10
	Goto	.next2
.next1:
	Vertices	11,10,9,8
	Face1pc	11
.next2:

	Flab
	Hide	12,13,14,.next1
	Vertices	12,13,14,15
	Face1pc	10
	Goto	.next2
.next1:
	Vertices	15,14,13,12
	Face1pc	11
.next2:

	Flab
	Hide	19,18,17,.next1
	Vertices	19,18,17,16
	Face1pc	10
	Goto	.next2
.next1:
	Vertices	16,17,18,19
	Face1pc	11
.next2:

	Flab
	Hide	23,22,21,.next1
	Vertices	23,22,21,20
	Face1pc	10
	Goto	.next2
.next1:
	Vertices	20,21,22,23
	Face1pc	11
.next2:

	Flab
	Hide	9,12,15,.next1
	Vertices	9,12,15,10
	Face1ptc	2
	Goto	.next2
.next1:
	Vertices	10,15,12,9
	Face1ptic	11
.next2:

	Flab
	Hide	13,21,22,.next1
	Vertices	13,21,22,14
	Face1ptc	2
	Goto	.next2
.next1:
	Vertices	14,22,21,13
	Face1ptic	11
.next2:

	Flab
	Hide	20,17,18,.next1
	Vertices	20,17,18,23
	Face1ptc	2
	Goto	.next2
.next1:
	Vertices	23,18,17,20
	Face1ptic	11
.next2:

	Flab
	Hide	16,8,11,.next1
	Vertices	16,8,11,19
	Face1ptc	2
	Goto	.next2
.next1:
	Vertices	19,11,8,16
	Face1ptic	11
.next2:

			; Le cube centrale

	Flab
	Set_color	2
	Hide	7,6,2,.next2
	Vertices	7,6,2,3
	Face1pt
	Affpoly
	Goto	.next1
.next2:
	Hide	0,1,5,.next1
	Vertices	0,1,5,4
	Face1pt
	Affpoly
.next1:

	Flab
	Set_color	2
	Hide	3,2,1,.next2
	Vertices	3,2,1,0
	Face1p
	Affpoly
	Goto	.next1
.next2:
	Hide	4,5,6,.next1
	Vertices	4,5,6,7
	Face1p
	Affpoly
.next1:

	Flab
	Set_color	4
	Hide	4,7,3,.next2
	Vertices	4,7,3,0
	Face1p
	Affpoly
	Goto	.next1
.next2:
	Hide	1,2,6,.next1
	Vertices	1,2,6,5
	Face1p
	Affpoly
.next1:

			; Les spheres

	Face1p
	Set_color	2
	Sphere	24,100
	Sphere	25,100

	Fin
	
	; #] Cubet:

	dc.b	'Finr'
; A partir d'ici, il n'y a plus relocation
	; #[ Big plot:
		; 28 points.
deliro_cylindre_plot:
	incbin	cylindre.seq
	Finanime

	; #] Big plot:

fin:
