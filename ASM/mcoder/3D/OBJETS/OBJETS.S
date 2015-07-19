	include	defmacro.s
debut:
 ; #[ :
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

 ; #[ Def objet:
	Defobjet	cube
	Defobjet	alliance
	Defobjet	dodecaedre
	Defobjet	vaisseau
	Defobjet	boule
	Defobjet	pyramide
	Defobjet	deliro_cylindre
	Defobjet	cubet
	Defobjet	interphase

	Fin_defobjet
 ; #] Def objet:
	
	; #[ Cube:
cube_plot:
	Debut_plot
	Plot	-100,-100,-100	;0
	Plot	100,-100,-100	;1
	Plot	100,100,-100	;2
	Plot	-100,100,-100	;3
	Plot	-100,-100,100	;4
	Plot	100,-100,100	;5
	Plot	100,100,100	;6
	Plot	-100,100,100	;7
	Fin_plot
	
cube:
	Flab
	Def_plot	cube_plot
	Init_color	15
	
	Hide	3,2,1,.next3
	Face1ptc	2
	Affpoly	3,2,1,0
	
.next1:
	Hide	7,6,2,.next4
	Face1pc	4
	Affpoly	7,6,2,3
.next2:
	Hide	4,7,3,.next5
	Face1pc	2
	Affpoly	4,7,3,0
	
	Fin
	
.next3:
	Hide	4,5,6,.next1
	Face1ptc	2
	Affpoly	4,5,6,7
	Goto	.next1
.next4:
	Hide	0,1,5,.next2
	Face1pc	4
	Affpoly	0,1,5,4
	Goto	.next2
.next5:
	Hide	1,2,6,.next6
	Face1pc	2
	Affpoly	1,2,6,5
.next6:
	Fin
	
	; #] Cube:
	; #[ Alliance:
alliance_plot:
	Debut_plot
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

	Fin_plot

alliance:
	Def_plot	alliance_plot	
	Init_color	15

		; L'interieur du A
	Flab
	Hide	17,19,18,.next
	Face1pc	3		;8
	Affpoly	17,19,18,16
.next:
	Flab
	Hide	19,21,20,.next
	Face1ptc	3		;9
	Affpoly	19,21,20,18
.next:
	Flab
	Hide	21,17,16,.next
	Face1ptc	3		;10
	Affpoly	21,17,16,20
.next:

		; Le dessus	
	Flab
	Hide	1,3,2,.next
	Face1pc	3		;0
	Affpoly	1,3,2,0
.next:

		; Le dessous
	Flab
	Hide	5,7,6,.next
	Face1ptc	3		;2
	Affpoly	5,7,6,4
.next:
	Flab
	Hide	7,9,8,.next
	Face1pc	3		;3
	Affpoly	7,9,8,6
.next:
	Flab
	Hide	9,11,10,.next
	Face1ptc	3		;4
	Affpoly	9,11,10,8
.next:
	Flab
	Hide	11,13,12,.next
	Face1pc	3		;5
	Affpoly	11,13,12,10
.next:
	Flab
	Hide	13,15,14,.next
	Face1ptc	3		;6
	Affpoly	13,15,14,12
.next:

		; Les deux grands bords
	Flab
	Hide	3,5,4,.next
	Face1pc	4		;1
	Affpoly	3,5,4,2
.next:
	Flab
	Hide	14,15,1,.next
	Face1pc	4		;7
	Affpoly	14,15,1,0
.next:

		; Les deux faces du A
	Flab
	Hide	16,18,8,.next
	Set_color	6
	Face1p
	Affpoly	16,18,8,10
	Affpoly	20,2,4,6,8,18
	Affpoly	14,0,2,20,16,10,12
	Goto	.next2
.next:
	Hide	11,9,19,.next2
	Set_color	5
	Face1p
	Affpoly	11,9,19,17
	Affpoly	1,15,13,11,17,21,3
	Affpoly	7,5,3,21,19,9
.next2:

	Fin	

	; #] Alliance:
	; #[ Dodecaedre:
dodecaedre_plot:
	Debut_plot
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
	
	Fin_plot
	
dodecaedre:
	Def_plot	dodecaedre_plot
	Init_color	3

	Flab
	Hide	0,1,2,.next
	Face1pc	1
	Affpoly	0,1,2,3,4
.next:
	Flab
	Hide	0,4,5,.next
	Face1pc	2
	Affpoly	0,4,5,6,7
.next:
	Flab
	Hide	0,7,8,.next
	Face1pc	3
	Affpoly	0,7,8,9,1
.next:
	Flab
	Hide	1,9,10,.next
	Face1pc	4
	Affpoly	1,9,10,11,2
.next:
	Flab
	Hide	2,11,12,.next
	Face1ptc	1
	Affpoly	2,11,12,13,3
.next:
	Flab
	Hide	3,13,14,.next
	Face1ptc	2
	Affpoly	3,13,14,5,4
.next:
	Flab
	Hide	12,15,16,.next
	Face1ptc	3
	Affpoly	12,15,16,14,13
.next:
	Flab
	Hide	14,16,17,.next
	Face1ptc	4
	Affpoly	14,16,17,6,5
.next:
	Flab
	Hide	6,17,18,.next
	Face1pc	1
	Affpoly	6,17,18,8,7
.next:
	Flab
	Hide	8,18,19,.next
	Face1ptc	2
	Affpoly	8,18,19,10,9
.next:
	Flab
	Hide	11,10,19,.next
	Face1pc	3
	Affpoly	11,10,19,15,12
.next:
	Flab
	Hide	17,16,15,.next
	Face1pc	4
	Affpoly	17,16,15,19,18
.next:
	
	Fin
	
	; #] Dodecaedre:
	; #[ Vaisseau:
vaisseau_plot:
	Debut_plot
	Plot	-200,100,-400		;0
	Plot	-500,00,-400		;1
	Plot	-200,-100,-400		;2
	Plot	200,-100,-400		;3
	Plot	200,100,-400		;4
	Plot	500,00,-400		;5
	Plot	200,00,400		;6
	Plot	-200,00,400		;7

	Fin_plot

vaisseau:
	Def_plot	vaisseau_plot
	Init_color	3

*********************
	Flab
	Hide	1,7,0,.next
	Face1pc	2		;0
	Affpoly	1,7,0
.next:
	Flab
	Hide	0,7,6,.next
	Face1pc	3		;1
	Affpoly	0,7,6,4
.next:
	Flab
	Hide	4,6,5,.next
	Face1pc	2		;2
	Affpoly	4,6,5
.next:
	Flab
	Hide	2,7,1,.next
	Face1pc	3		;4
	Affpoly	2,7,1
.next:
	Flab
	Hide	3,5,6,.next
	Face1pc	3		;5
	Affpoly	3,5,6
.next:
	Flab
	Hide	2,3,6,.next
	Face1pc	2		;6
	Affpoly	2,3,6,7
.next:
	Flab
	Hide	1,0,4,.next
	Face1ptc	12		;3
	Affpoly	1,0,4,5,3,2
.next:
	
	Fin

	; #] Vaisseau:
	; #[ Boule:
boule_plot:
	Debut_plot
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
	Fin_plot

boule:
	Def_plot	boule_plot	
	Init_color	11

	IFNE	TRUE
		********************* Interieur
	Set_color	11
	Face1p
	Flab
	Hide	7,12,0,.next
	Affpoly	7,12,0
	Disable	boule1
	Goto	.next2
.next:
	Enable	boule1
.next2:
	Flab
	Hide	17,22,0,.next
	Affpoly	17,22,0
	Disable	boule2
	Goto	.next2
.next:
	Enable	boule2
.next2:
	Flab
	Hide	27,32,0,.next
	Affpoly	27,32,0
	Disable	boule3
	Goto	.next2
.next:
	Enable	boule3
.next2:
	Flab
	Hide	37,1,0,.next
	Affpoly	37,1,0
	Disable	boule4
	Goto	.next2
.next:
	Enable	boule4
.next2:
	Flab
	Hide	2,8,7,.next
	Affpoly	2,8,7,1
	Disable	boule5
	Goto	.next2
.next:
	Enable	boule5
.next2:
	Flab
	Hide	13,18,17,.next
	Affpoly	13,18,17,12
	Disable	boule6
	Goto	.next2
.next:
	Enable	boule6
.next2:
	Flab
	Hide	23,28,27,.next
	Affpoly	23,28,27,22
	Disable	boule7
	Goto	.next2
.next:
	Enable	boule7
.next2:
	Flab
	Hide	33,38,37,.next
	Affpoly	33,38,37,32
	Disable	boule8
	Goto	.next2
.next:
	Enable	boule8
.next2:
	Flab
	Hide	9,14,13,.next
	Affpoly	9,14,13,8
	Disable	boule9
	Goto	.next2
.next:
	Enable	boule9
.next2:
	Flab
	Hide	19,24,23,.next
	Affpoly	19,24,23,18
	Disable	boule10
	Goto	.next2
.next:
	Enable	boule10
.next2:
	Flab
	Hide	29,34,33,.next
	Affpoly	29,34,33,28
	Disable	boule11
	Goto	.next2
.next:
	Enable	boule11
.next2:
	Flab
	Hide	39,3,2,.next
	Affpoly	39,3,2,38
	Disable	boule12
	Goto	.next2
.next:
	Enable	boule12
.next2:
	Flab
	Hide	4,10,9,.next
	Affpoly	4,10,9,3
	Disable	boule13
	Goto	.next2
.next:
	Enable	boule13
.next2:
	Flab
	Hide	15,20,19,.next
	Affpoly	15,20,19,14
	Disable	boule14
	Goto	.next2
.next:
	Enable	boule14
.next2:
	Flab
	Hide	25,30,29,.next
	Affpoly	25,30,29,24
	Disable	boule15
	Goto	.next2
.next:
	Enable	boule15
.next2:
	Flab
	Hide	35,40,39,.next
	Affpoly	35,40,39,34
	Disable	boule16
	Goto	.next2
.next:
	Enable	boule16
.next2:
	Flab
	Hide	11,16,15,.next
	Affpoly	11,16,15,10
	Disable	boule17
	Goto	.next2
.next:
	Enable	boule17
.next2:
	Flab
	Hide	21,26,25,.next
	Affpoly	21,26,25,20
	Disable	boule18
	Goto	.next2
.next:
	Enable	boule18
.next2:
	Flab
	Hide	31,36,35,.next
	Affpoly	31,36,35,30
	Disable	boule19
	Goto	.next2
.next:
	Enable	boule19
.next2:
	Flab
	Hide	41,5,4,.next
	Affpoly	41,5,4,40
	Disable	boule20
	Goto	.next2
.next:
	Enable	boule20
.next2:
	Flab
	Hide	6,11,5,.next
	Affpoly	6,11,5
	Disable	boule21
	Goto	.next2
.next:
	Enable	boule21
.next2:
	Flab
	Hide	6,21,16,.next
	Affpoly	6,21,16
	Disable	boule22
	Goto	.next2
.next:
	Enable	boule22
.next2:
	Flab
	Hide	6,31,26,.next
	Affpoly	6,31,26
	Disable	boule23
	Goto	.next2
.next:
	Enable	boule23
.next2:
	Flab
	Hide	6,41,36,.next
	Affpoly	6,41,36
	Disable	boule24
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
	Affpoly	0,12,7
.next:
	Flab
boule2:
	Hide	0,22,17,.next
	Affpoly	0,22,17
.next:
	Flab
boule3:
	Hide	0,32,27,.next
	Affpoly	0,32,27
.next:
	Flab
boule4:
	Hide	0,1,37,.next
	Affpoly	0,1,37
.next:
	Flab
boule9:
	Hide	8,13,14,.next
	Affpoly	8,13,14,9
.next:
	Flab
boule10:
	Hide	18,23,24,.next
	Affpoly	18,23,24,19
.next:
	Flab
boule11:
	Hide	28,33,34,.next
	Affpoly	28,33,34,29
.next:
	Flab
boule12:
	Hide	38,2,3,.next
	Affpoly	38,2,3,39
.next:
	Flab
boule17:
	Hide	10,15,16,.next
	Affpoly	10,15,16,11
.next:
	Flab
boule18:
	Hide	20,25,26,.next
	Affpoly	20,25,26,21
.next:
	Flab
boule19:
	Hide	30,35,36,.next
	Affpoly	30,35,36,31
.next:
	Flab
boule20:
	Hide	40,4,5,.next
	Affpoly	40,4,5,41
.next:
	
	Set_color	14
	Flab
boule5:
	Hide	1,7,8,.next
	Affpoly	1,7,8,2
.next:
	Flab
boule6:
	Hide	12,17,18,.next
	Affpoly	12,17,18,13
.next:
	Flab
boule7:
	Hide	22,27,28,.next
	Affpoly	22,27,28,23
.next:
	Flab
boule8:
	Hide	32,37,38,.next
	Affpoly	32,37,38,33
.next:
	Flab
boule13:
	Hide	3,9,10,.next
	Affpoly	3,9,10,4
.next:
	Flab
boule14:
	Hide	14,19,20,.next
	Affpoly	14,19,20,15
.next:
	Flab
boule15:
	Hide	24,29,30,.next
	Affpoly	24,29,30,25
.next:
	Flab
boule16:
	Hide	34,39,40,.next
	Affpoly	34,39,40,35
.next:
	Flab
boule21:
	Hide	5,11,6,.next
	Affpoly	5,11,6
.next:
	Flab
boule22:
	Hide	16,21,6,.next
	Affpoly	16,21,6
.next:
	Flab
boule23:
	Hide	26,31,6,.next
	Affpoly	26,31,6
.next:
	Flab
boule24:
	Hide	36,41,6,.next
	Affpoly	36,41,6
.next:
	
	Fin
	
	; #] Boule:
	; #[ Pyramide:
pyramide_plot:
	Debut_plot
	Plot	0,150,0
	Plot	-100,0,-100
	Plot	100,0,-100
	Plot	100,0,100
	Plot	-100,0,100
	Fin_plot
	
pyramide:
	Def_plot	pyramide_plot
	Init_color	3
	
	Flab
	Hide	0,2,1,.next1
	Affpoly	0,2,1
	Face1pc	8
.next1:
	Flab
	Hide	0,3,2,.next2
	Affpoly	0,3,2
	Face1pc	11
.next2:
	Flab
	Hide	0,4,3,.next3
	Affpoly	0,4,3
	Face1pc	9
.next3:
	Flab
	Hide	0,1,4,.next4
	Affpoly	0,1,4
	Face1pc	11
.next4:
	Flab
	Hide	1,2,3,.next5
	Affpoly	1,2,3,4
	Face1pc	4
.next5:
	
	Fin
	
	; #] Pyramide:
	; #[ Deliro cylindre:
		; 28 points.
deliro_cylindre_plot:
	incbin	cylindre.seq
	Fin_anime

		; 26 faces.
deliro_cylindre:
	Anime_plot	deliro_cylindre_plot
	Init_color	15
	
	Flab
	Hide	0,4,5,.next
	Face1pc	11
	Affpoly	0,4,5,1
.next:
	Flab
	Hide	1,5,6,.next
	Face1pc	10
	Affpoly	1,5,6,2
.next:
	Flab
	Hide	2,6,7,.next
	Face1pc	11
	Affpoly	2,6,7,3
.next:
	Flab
	Hide	3,7,4,.next
	Face1pc	10
	Affpoly	3,7,4,0
.next:
	Flab
	Hide	4,8,9,.next
	Face1pc	10
	Affpoly	4,8,9,5
.next:
	Flab
	Hide	5,9,10,.next
	Face1pc	11
	Affpoly	5,9,10,6
.next:
	Flab
	Hide	6,10,11,.next
	Face1pc	10
	Affpoly	6,10,11,7
.next:
	Flab
	Hide	7,11,8,.next
	Face1pc	11
	Affpoly	7,11,8,4
.next:
	Flab
	Hide	8,12,13,.next
	Face1pc	11
	Affpoly	8,12,13,9
.next:
	Flab
	Hide	9,13,14,.next
	Face1pc	10
	Affpoly	9,13,14,10
.next:
	Flab
	Hide	10,14,15,.next
	Face1pc	11
	Affpoly	10,14,15,11
.next:
	Flab
	Hide	11,15,12,.next
	Face1pc	10
	Affpoly	11,15,12,8
.next:
	Flab
	Hide	12,16,17,.next
	Face1pc	10
	Affpoly	12,16,17,13
.next:
	Flab
	Hide	13,17,18,.next
	Face1pc	11
	Affpoly	13,17,18,14
.next:
	Flab
	Hide	14,18,19,.next
	Face1pc	10
	Affpoly	14,18,19,15
.next:
	Flab
	Hide	15,19,16,.next
	Face1pc	11
	Affpoly	15,19,16,12
.next:
	Flab
	Hide	16,20,21,.next
	Face1pc	11
	Affpoly	16,20,21,17
.next:
	Flab
	Hide	17,21,22,.next
	Face1pc	10
	Affpoly	17,21,22,18
.next:
	Flab
	Hide	18,22,23,.next
	Face1pc	11
	Affpoly	18,22,23,19
.next:
	Flab
	Hide	19,23,20,.next
	Face1pc	10
	Affpoly	19,23,20,16
.next:
	Flab
	Hide	20,24,25,.next
	Face1pc	10
	Affpoly	20,24,25,21
.next:
	Flab
	Hide	21,25,26,.next
	Face1pc	11
	Affpoly	21,25,26,22
.next:
	Flab
	Hide	22,26,27,.next
	Face1pc       	10
	Affpoly	22,26,27,23
.next:
	Flab
	Hide	23,27,24,.next
	Face1pc	11
	Affpoly	23,27,24,20
.next:

	Flab
	Hide	0,1,2,.next
	Face1ptc	12
	Affpoly	0,1,2,3
	Goto	.next2
.next:
	Hide	27,26,25,.next2
	Face1ptc	12
	Affpoly	27,26,25,24
.next2:

	Fin

	; #] Deliro cylindre:
	; #[ Cubet:
cubet_plot:
	Debut_plot
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

	Fin_plot
	
cubet:
	Def_plot	cubet_plot
	Init_color	10

	Set_color	2
	Set_color	4
	Set_color	11
	
			; Le tour de l'objet
		
	Flab
	Hide	8,9,10,.next1
	Face1pc	10
	Affpoly	8,9,10,11
	Goto	.next2
.next1:
	Face1pc	11
	Affpoly	11,10,9,8
.next2:

	Flab
	Hide	12,13,14,.next1
	Face1pc	10
	Affpoly	12,13,14,15
	Goto	.next2
.next1:
	Face1pc	11
	Affpoly	15,14,13,12
.next2:

	Flab
	Hide	19,18,17,.next1
	Face1pc	10
	Affpoly	19,18,17,16
	Goto	.next2
.next1:
	Face1pc	11
	Affpoly	16,17,18,19
.next2:

	Flab
	Hide	23,22,21,.next1
	Face1pc	10
	Affpoly	23,22,21,20
	Goto	.next2
.next1:
	Face1pc	11
	Affpoly	20,21,22,23
.next2:

	Flab
	Hide	9,12,15,.next1
	Face1ptc	2
	Affpoly	9,12,15,10
	Goto	.next2
.next1:
	Face1ptic	11
	Affpoly	10,15,12,9
.next2:

	Flab
	Hide	13,21,22,.next1
	Face1ptc	2
	Affpoly	13,21,22,14
	Goto	.next2
.next1:
	Face1ptic	11
	Affpoly	14,22,21,13
.next2:

	Flab
	Hide	20,17,18,.next1
	Face1ptc	2
	Affpoly	20,17,18,23
	Goto	.next2
.next1:
	Face1ptic	11
	Affpoly	23,18,17,20
.next2:

	Flab
	Hide	16,8,11,.next1
	Face1ptc	2
	Affpoly	16,8,11,19
	Goto	.next2
.next1:
	Face1ptic	11
	Affpoly	19,11,8,16
.next2:

			; Le cube centrale

	Flab
	Set_color	2
	Hide	7,6,2,.next2
	Face1pt
	Affpoly	7,6,2,3
	Goto	.next1
.next2:
	Hide	0,1,5,.next1
	Face1pt
	Affpoly	0,1,5,4
.next1:

	Flab
	Set_color	2
	Hide	3,2,1,.next2
	Face1p
	Affpoly	3,2,1,0
	Goto	.next1
.next2:
	Hide	4,5,6,.next1
	Face1p
	Affpoly	4,5,6,7
.next1:

	Flab
	Set_color	4
	Hide	4,7,3,.next2
	Face1p
	Affpoly	4,7,3,0
	Goto	.next1
.next2:
	Hide	1,2,6,.next1
	Face1p
	Affpoly	1,2,6,5
.next1:

			; Les spheres

	Face1p
	Set_color	2
	Sphere	24,100
	Sphere	25,100

	Fin
	
	; #] Cubet:
	; #[ Interphase:

plot_interphase:
		;#[ Plot:	
	Debut_plot
	Plot	-$14,+$0a,+$0a
	Plot	+$14,+$0a,+$0a
	Plot	+$14,-$0a,+$0a
	Plot	-$14,-$0a,+$0a
	Plot	-$1e,+$14,+$00
	Plot	+$1e,+$14,+$00
	Plot	+$1e,-$14,+$00
	Plot	-$1e,-$14,+$00
	Plot	-$14,+$00,+$32
	Plot	+$14,+$00,+$32
	Plot	+$01,+$00,+$0a
	Plot	-$14,+$00,+$0a
	Plot	+$14,+$00,+$0a
	Fin_plot

	Debut_plot
	Plot	-$14,+$0a,+$0a
	Plot	+$14,+$0a,+$0a
	Plot	+$14,-$0a,+$0a
	Plot	-$14,-$0a,+$0a
	Plot	-$1e,+$14,+$00
	Plot	+$1e,+$14,+$00
	Plot	+$1e,-$14,+$00
	Plot	-$1e,-$14,+$00
	Plot	-$14,+$00,+$32
	Plot	+$14,+$00,+$32
	Plot	+$01,+$00,+$0a
	Plot	-$14,+$00,+$0c
	Plot	+$14,+$00,+$0c
	Fin_plot

	Debut_plot
	Plot	-$14,+$0a,+$0a
	Plot	+$14,+$0a,+$0a
	Plot	+$14,-$0a,+$0a
	Plot	-$14,-$0a,+$0a
	Plot	-$1e,+$14,+$00
	Plot	+$1e,+$14,+$00
	Plot	+$1e,-$14,+$00
	Plot	-$1e,-$14,+$00
	Plot	-$14,+$00,+$32
	Plot	+$14,+$00,+$32
	Plot	+$01,+$00,+$0a
	Plot	-$14,+$00,+$0e
	Plot	+$14,+$00,+$0e
	Fin_plot

	Debut_plot
	Plot	-$14,+$0a,+$0a
	Plot	+$14,+$0a,+$0a
	Plot	+$14,-$0a,+$0a
	Plot	-$14,-$0a,+$0a
	Plot	-$1e,+$14,+$00
	Plot	+$1e,+$14,+$00
	Plot	+$1e,-$14,+$00
	Plot	-$1e,-$14,+$00
	Plot	-$14,+$00,+$32
	Plot	+$14,+$00,+$32
	Plot	+$01,+$00,+$0a
	Plot	-$14,+$00,+$10
	Plot	+$14,+$00,+$10
	Fin_plot

	Debut_plot
	Plot	-$14,+$0a,+$0a
	Plot	+$14,+$0a,+$0a
	Plot	+$14,-$0a,+$0a
	Plot	-$14,-$0a,+$0a
	Plot	-$1e,+$14,+$00
	Plot	+$1e,+$14,+$00
	Plot	+$1e,-$14,+$00
	Plot	-$1e,-$14,+$00
	Plot	-$14,+$00,+$32
	Plot	+$14,+$00,+$32
	Plot	+$01,+$00,+$0a
	Plot	-$14,+$00,+$12
	Plot	+$14,+$00,+$12
	Fin_plot

	Debut_plot
	Plot	-$14,+$0a,+$0a
	Plot	+$14,+$0a,+$0a
	Plot	+$14,-$0a,+$0a
	Plot	-$14,-$0a,+$0a
	Plot	-$1e,+$14,+$00
	Plot	+$1e,+$14,+$00
	Plot	+$1e,-$14,+$00
	Plot	-$1e,-$14,+$00
	Plot	-$14,+$00,+$32
	Plot	+$14,+$00,+$32
	Plot	+$01,+$00,+$0a
	Plot	-$14,+$00,+$14
	Plot	+$14,+$00,+$14
	Fin_plot

	Debut_plot
	Plot	-$14,+$0a,+$0a
	Plot	+$14,+$0a,+$0a
	Plot	+$14,-$0a,+$0a
	Plot	-$14,-$0a,+$0a
	Plot	-$1e,+$14,+$00
	Plot	+$1e,+$14,+$00
	Plot	+$1e,-$14,+$00
	Plot	-$1e,-$14,+$00
	Plot	-$14,+$00,+$32
	Plot	+$14,+$00,+$32
	Plot	+$01,+$00,+$0a
	Plot	-$14,+$00,+$16
	Plot	+$14,+$00,+$16
	Fin_plot

	Debut_plot
	Plot	-$14,+$0a,+$0a
	Plot	+$14,+$0a,+$0a
	Plot	+$14,-$0a,+$0a
	Plot	-$14,-$0a,+$0a
	Plot	-$1e,+$14,+$00
	Plot	+$1e,+$14,+$00
	Plot	+$1e,-$14,+$00
	Plot	-$1e,-$14,+$00
	Plot	-$14,+$00,+$32
	Plot	+$14,+$00,+$32
	Plot	+$01,+$00,+$0a
	Plot	-$14,+$00,+$18
	Plot	+$14,+$00,+$18
	Fin_plot

	Debut_plot
	Plot	-$14,+$0a,+$0a
	Plot	+$14,+$0a,+$0a
	Plot	+$14,-$0a,+$0a
	Plot	-$14,-$0a,+$0a
	Plot	-$1e,+$14,+$00
	Plot	+$1e,+$14,+$00
	Plot	+$1e,-$14,+$00
	Plot	-$1e,-$14,+$00
	Plot	-$14,+$00,+$32
	Plot	+$14,+$00,+$32
	Plot	+$01,+$00,+$0a
	Plot	-$14,+$00,+$1a
	Plot	+$14,+$00,+$1a
	Fin_plot

	Debut_plot
	Plot	-$14,+$0a,+$0a
	Plot	+$14,+$0a,+$0a
	Plot	+$14,-$0a,+$0a
	Plot	-$14,-$0a,+$0a
	Plot	-$1e,+$14,+$00
	Plot	+$1e,+$14,+$00
	Plot	+$1e,-$14,+$00
	Plot	-$1e,-$14,+$00
	Plot	-$14,+$00,+$32
	Plot	+$14,+$00,+$32
	Plot	+$01,+$00,+$0a
	Plot	-$14,+$00,+$1c
	Plot	+$14,+$00,+$1c
	Fin_plot

	Debut_plot
	Plot	-$14,+$0a,+$0a
	Plot	+$14,+$0a,+$0a
	Plot	+$14,-$0a,+$0a
	Plot	-$14,-$0a,+$0a
	Plot	-$1e,+$14,+$00
	Plot	+$1e,+$14,+$00
	Plot	+$1e,-$14,+$00
	Plot	-$1e,-$14,+$00
	Plot	-$14,+$00,+$32
	Plot	+$14,+$00,+$32
	Plot	+$01,+$00,+$0a
	Plot	-$14,+$00,+$1e
	Plot	+$14,+$00,+$1e
	Fin_plot

	Debut_plot
	Plot	-$14,+$0a,+$0a
	Plot	+$14,+$0a,+$0a
	Plot	+$14,-$0a,+$0a
	Plot	-$14,-$0a,+$0a
	Plot	-$1e,+$14,+$00
	Plot	+$1e,+$14,+$00
	Plot	+$1e,-$14,+$00
	Plot	-$1e,-$14,+$00
	Plot	-$14,+$00,+$32
	Plot	+$14,+$00,+$32
	Plot	+$01,+$00,+$0a
	Plot	-$14,+$00,+$20
	Plot	+$14,+$00,+$20
	Fin_plot

	Debut_plot
	Plot	-$14,+$0a,+$0a
	Plot	+$14,+$0a,+$0a
	Plot	+$14,-$0a,+$0a
	Plot	-$14,-$0a,+$0a
	Plot	-$1e,+$14,+$00
	Plot	+$1e,+$14,+$00
	Plot	+$1e,-$14,+$00
	Plot	-$1e,-$14,+$00
	Plot	-$14,+$00,+$32
	Plot	+$14,+$00,+$32
	Plot	+$01,+$00,+$0a
	Plot	-$14,+$00,+$22
	Plot	+$14,+$00,+$22
	Fin_plot

	Debut_plot
	Plot	-$14,+$0a,+$0a
	Plot	+$14,+$0a,+$0a
	Plot	+$14,-$0a,+$0a
	Plot	-$14,-$0a,+$0a
	Plot	-$1e,+$14,+$00
	Plot	+$1e,+$14,+$00
	Plot	+$1e,-$14,+$00
	Plot	-$1e,-$14,+$00
	Plot	-$14,+$00,+$32
	Plot	+$14,+$00,+$32
	Plot	+$01,+$00,+$0a
	Plot	-$14,+$00,+$24
	Plot	+$14,+$00,+$24
	Fin_plot

	Debut_plot
	Plot	-$14,+$0a,+$0a
	Plot	+$14,+$0a,+$0a
	Plot	+$14,-$0a,+$0a
	Plot	-$14,-$0a,+$0a
	Plot	-$1e,+$14,+$00
	Plot	+$1e,+$14,+$00
	Plot	+$1e,-$14,+$00
	Plot	-$1e,-$14,+$00
	Plot	-$14,+$00,+$32
	Plot	+$14,+$00,+$32
	Plot	+$01,+$00,+$0a
	Plot	-$14,+$00,+$26
	Plot	+$14,+$00,+$26
	Fin_plot

	Debut_plot
	Plot	-$14,+$0a,+$0a
	Plot	+$14,+$0a,+$0a
	Plot	+$14,-$0a,+$0a
	Plot	-$14,-$0a,+$0a
	Plot	-$1e,+$14,+$00
	Plot	+$1e,+$14,+$00
	Plot	+$1e,-$14,+$00
	Plot	-$1e,-$14,+$00
	Plot	-$14,+$00,+$32
	Plot	+$14,+$00,+$32
	Plot	+$01,+$00,+$0a
	Plot	-$14,+$00,+$28
	Plot	+$14,+$00,+$28
	Fin_plot

	Debut_plot
	Plot	-$14,+$0a,+$0a
	Plot	+$14,+$0a,+$0a
	Plot	+$14,-$0a,+$0a
	Plot	-$14,-$0a,+$0a
	Plot	-$1e,+$14,+$00
	Plot	+$1e,+$14,+$00
	Plot	+$1e,-$14,+$00
	Plot	-$1e,-$14,+$00
	Plot	-$14,+$00,+$32
	Plot	+$14,+$00,+$32
	Plot	+$01,+$00,+$0a
	Plot	-$14,+$00,+$2a
	Plot	+$14,+$00,+$2a
	Fin_plot
	
	Debut_plot
	Plot	-$14,+$0a,+$0a
	Plot	+$14,+$0a,+$0a
	Plot	+$14,-$0a,+$0a
	Plot	-$14,-$0a,+$0a
	Plot	-$1e,+$14,+$00
	Plot	+$1e,+$14,+$00
	Plot	+$1e,-$14,+$00
	Plot	-$1e,-$14,+$00
	Plot	-$14,+$00,+$32
	Plot	+$14,+$00,+$32
	Plot	+$01,+$00,+$0a
	Plot	-$14,+$00,+$2c
	Plot	+$14,+$00,+$2c
	Fin_plot

	Debut_plot
	Plot	-$14,+$0a,+$0a
	Plot	+$14,+$0a,+$0a
	Plot	+$14,-$0a,+$0a
	Plot	-$14,-$0a,+$0a
	Plot	-$1e,+$14,+$00
	Plot	+$1e,+$14,+$00
	Plot	+$1e,-$14,+$00
	Plot	-$1e,-$14,+$00
	Plot	-$14,+$00,+$32
	Plot	+$14,+$00,+$32
	Plot	+$01,+$00,+$0a
	Plot	-$14,+$00,+$2e
	Plot	+$14,+$00,+$2e
	Fin_plot

	Debut_plot
	Plot	-$14,+$0a,+$0a
	Plot	+$14,+$0a,+$0a
	Plot	+$14,-$0a,+$0a
	Plot	-$14,-$0a,+$0a
	Plot	-$1e,+$14,+$00
	Plot	+$1e,+$14,+$00
	Plot	+$1e,-$14,+$00
	Plot	-$1e,-$14,+$00
	Plot	-$14,+$00,+$32
	Plot	+$14,+$00,+$32
	Plot	+$01,+$00,+$0a
	Plot	-$14,+$00,+$30
	Plot	+$14,+$00,+$30
	Fin_plot

	Debut_plot
	Plot	-$14,+$0a,+$0a
	Plot	+$14,+$0a,+$0a
	Plot	+$14,-$0a,+$0a
	Plot	-$14,-$0a,+$0a
	Plot	-$1e,+$14,+$00
	Plot	+$1e,+$14,+$00
	Plot	+$1e,-$14,+$00
	Plot	-$1e,-$14,+$00
	Plot	-$14,+$00,+$32
	Plot	+$14,+$00,+$32
	Plot	+$01,+$00,+$0a
	Plot	-$14,+$00,+$32
	Plot	+$14,+$00,+$32
	Fin_plot
		;#] Plot:	
	Fin_anime

interphase:
	Ani_loop_plot	plot_interphase
	Init_color	2

	Flab
	Hide	10,12,11,.next		;Electron beam
	Face1pc	8
	Affpoly	10,12,11
	Goto	.next2
.next:
	Face1pc	8
	Affpoly	11,12,10
.next2:
	
	Flab
	Hide	3,2,1,.next		;Box Top
	Face1ptic	2
	Affpoly	3,2,1,0
.next:

	Flab
	Hide	0,4,7,.next		;Dark sides 0
	Face1pc	3
	Affpoly	0,4,7,3
.next:
	Flab
	Hide	2,6,5,.next		;Dark sides 1
	Face1pc	3
	Affpoly	2,6,5,1
.next:

	Flab
	Hide	8,0,3,.next		;Arms 0 external
	Face1ptc	11
	Affpoly	8,0,3
.next:

	Flab
	Hide	1,2,9,.next		;Arms 1 internal sides
	Face1pc	2
	Affpoly	1,2,9
	Goto	.next2
.next:
	Face1ptc	11
	Affpoly	9,2,1		;Arms 1 external sides
.next2:

	Flab
	Hide	3,0,8,.next
	Face1pc	2
	Affpoly	3,0,8		;Arms 0 internal sides
.next:
	
	Flab
	Hide	4,5,6,.next
	Face1pc	3
	Affpoly	4,5,6,7		;Box bottom
.next:

	Flab
	Hide	3,7,6,.next
	Face1ptc	3
	Affpoly	3,7,6,2		;Enlighted sides 0
.next:
	Flab
	Hide	1,5,4,.next
	Face1ptc	3
	Affpoly	1,5,4,0		;Enlighted sides 1
.next:

	Fin
	
	; #] Interphase:
	 
fin:
