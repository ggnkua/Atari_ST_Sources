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

RET	macro
	Fin
	endm
ENTETE	macro
	Flab
	Def_plot	\1
	Init_color	15
	endm
BIG	MACRO
	Plot	\1*2,\2*2,\3*2
	ENDM
INV3	MACRO
	Hide	\3,\4,\5,.\@
	Vertices	\3,\4,\5
	Face1pc	\1
.\@
	ENDM

INV4	MACRO
	Hide	\3,\4,\5,.\@
	Vertices	\3,\4,\5,\6
	Face1pc	\1
.\@
	ENDM
INV5	MACRO
	Hide	\3,\4,\5,.\@
	Vertices	\3,\4,\5,\6,\7
	Face1pc	\1
.\@
	ENDM
FACE3	MACRO
	Hide	\5,\4,\3,.\@
	Vertices	\5,\4,\3
	Face1pc	\1
.\@
	ENDM

FACE4	MACRO
	Hide	\5,\4,\3,.\@
	Vertices	\6,\5,\4,\3
	Face1pc	\1
.\@
	ENDM

SKIP	macro
	Goto	\1
	endm
INITDRAW	macro
	endm
TEST	macro
	Hide	\1,\2,\3,\5
	endm

AFF4	MACRO
	Vertices	\6,\5,\4,\3
	Face1pc	\1
.\@
	ENDM
	Defobjet	fvcube
	Defobjet	fspider2
	Defobjet	frcube
	Defobjet	fmine
	Defobjet	ftorus
	Defobjet	dodecaedre
	Defobjet	grille
	Defobjet	tetraedre
	Defobjet	cube
	Defobjet	spider

coords_spider
	Plot	-15,25,0
	Plot	25,30,0
	Plot	-65,10,0
	Plot	-15,10,5
	Plot	25,10,5
	Plot	40,10,0
	Plot	-65,-10,0
	Plot	-15,-10,5
	Plot	25,-10,5
	Plot	40,-10,0
	Plot	-15,-25,0
	Plot	25,-30,0
	Plot	-15,25,-5
	Plot	25,30,-5
	Plot	-75,5,-5
	Plot	40,10,-5
	Plot	-75,-5,-5
	Plot	40,-10,-5
	Plot	-15,-25,-5
	Plot	25,-30,-5
	Plot	-10,0,-15
	Plot	20,0,-15
	Finplot
spider:
	ENTETE	coords_spider
	FACE3	0,-1,2,0,3
	FACE4	1,-1,0,1,4,3
	FACE3	2,-1,1,5,4
	FACE4	3,-1,2,3,7,6
	FACE4	0,-1,3,4,8,7
	FACE4	1,-1,4,5,9,8
	FACE3	2,-1,6,7,10
	FACE4	3,-1,7,8,11,10
	FACE3	0,-1,8,9,11
	FACE4	1,-1,12,0,2,14
	FACE4	2,-1,12,13,1,0
	FACE4	3,-1,5,1,13,15
	FACE4	0,-1,9,5,15,17
	FACE4	1,-1,11,9,17,19
	FACE4	2,-1,10,11,19,18
	FACE4	3,-1,6,10,18,16
	FACE4	0,-1,2,6,16,14
	FACE4	1,-1,20,21,13,12
	FACE3	2,-1,12,14,20
	FACE3	3,-1,20,14,16
	FACE3	0,-1,20,16,18
	FACE4	1,-1,18,19,21,20
	FACE3	2,-1,21,19,17
	FACE3	3,-1,15,21,17
	FACE3	0,-1,13,21,15
	RET

;
; affichage d'un cube
;
coords_cube
	Plot	-50,50,-50	;1
	Plot	-50,-50,-50	;2
	Plot	50,-50,-50	;3
	Plot	50,50,-50	;4

	Plot	-50,50,50	;5
	Plot	-50,-50,50	;6
	Plot	50,-50,50	;7
	Plot	50,50,50	;8
	Finplot
cube:
	ENTETE	coords_cube
	TEST	0,1,2,3,not0

	AFF4	0,$055,0,1,2,3
	SKIP	not1
not0
	FACE4	0,$022,7,6,5,4
not1
	TEST	0,3,7,4,not2
	AFF4	1,$066,0,3,7,4
	SKIP	not3
not2
	FACE4	1,$033,2,1,5,6
not3
	TEST	3,2,6,7,not4
	AFF4	2,$077,3,2,6,7
	SKIP	not5
not4
	FACE4	2,$044,0,4,5,1
not5
	RET
;
; affichage d'un t‚traŠdre
;
coords_tetra:
	Plot	0,50,0
	Plot	43,-25,0
	Plot	-43,-25,0
	Plot	0,0,50
	Finplot
tetraedre:
	ENTETE	coords_tetra
	FACE3	0,-1,0,2,1
	FACE3	1,-1,0,3,2
	FACE3	2,-1,0,1,3
	FACE3	3,-1,1,2,3
	RET
coords_grille:
	Plot	-50,-50,0
	Plot	-25,-50,0
	Plot	0,-50,0
	Plot	25,-50,0
	Plot	50,-50,0
	Plot	-50,-25,0
	Plot	-25,-25,0
	Plot	0,-25,0
	Plot	25,-25,0
	Plot	50,-25,0
	Plot	-50,0,0
	Plot	-25,0,0
	Plot	0,0,0
	Plot	25,0,0
	Plot	50,0,0
	Plot	-50,25,0
	Plot	-25,25,0
	Plot	0,25,0
	Plot	25,25,0
	Plot	50,25,0
	Plot	-50,50,0
	Plot	-25,50,0
	Plot	0,50,0
	Plot	25,50,0
	Plot	50,50,0
	Finplot
grille:
	ENTETE	coords_grille
	INITDRAW
	TEST	0,20,24,4,laba0

	AFF4	0,$700,0,5,6,1
	AFF4	0,-1,8,13,14,9
	AFF4	0,-1,12,17,18,13
	AFF4	0,-1,16,21,22,17

	AFF4	1,$070,1,6,7,2
	AFF4	2,$007,2,7,8,3
	AFF4	3,$777,3,8,9,4
	AFF4	1,-1,5,10,11,6
	AFF4	2,-1,6,11,12,7
	AFF4	3,-1,7,12,13,8
	AFF4	2,-1,10,15,16,11
	AFF4	3,-1,11,16,17,12
	AFF4	1,-1,13,18,19,14
	AFF4	3,-1,15,20,21,16
	AFF4	1,-1,17,22,23,18
	AFF4	2,-1,18,23,24,19
	RET
laba0:
	AFF4	0,$777,0,1,6,5
	AFF4	0,-1,8,9,14,13
	AFF4	0,-1,12,13,18,17
	AFF4	0,-1,16,17,22,21

	AFF4	1,$007,1,2,7,6
	AFF4	2,$070,2,3,8,7
	AFF4	3,$700,3,4,9,8
	AFF4	1,-1,5,6,11,10
	AFF4	2,-1,6,7,12,11
	AFF4	3,-1,7,8,13,12
	AFF4	2,-1,10,11,16,15
	AFF4	3,-1,11,12,17,16
	AFF4	1,-1,13,14,19,18
	AFF4	3,-1,15,16,21,20
	AFF4	1,-1,17,18,23,22
	AFF4	2,-1,18,19,24,23
	RET

DODE	MACRO
	Plot	\1/8/2,\2/8/2,\3/8/2
	ENDM

coords_dodecaedre
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
	Finplot

dodecaedre:
	ENTETE	coords_dodecaedre

	INV5	0,-1,0,1,2,3,4
	INV5	1,-1,0,4,5,6,7
	INV5	2,-1,0,7,8,9,1
	INV5	3,-1,1,9,10,11,2
	INV5	0,-1,2,11,12,13,3
	INV5	1,-1,3,13,14,5,4
	INV5	2,-1,12,15,16,14,13
	INV5	3,-1,14,16,17,6,5
	INV5	0,-1,6,17,18,8,7
	INV5	1,-1,8,18,19,10,9
	INV5	2,-1,11,10,19,15,12
	INV5	3,-1,17,16,15,19,18
	RET

ptorus
	BIG	-10,20,5
	BIG	10,20,5
	BIG	20,10,5
	BIG	20,-10,5
	BIG	10,-20,5
	BIG	-10,-20,5
	BIG	-20,-10,5
	BIG	-20,10,5

	BIG	-15,35,0
	BIG	15,35,0
	BIG	35,15,0
	BIG	35,-15,0
	BIG	15,-35,0
	BIG	-15,-35,0
	BIG	-35,-15,0
	BIG	-35,15,0

	BIG	-10,20,-5
	BIG	10,20,-5
	BIG	20,10,-5
	BIG	20,-10,-5
	BIG	10,-20,-5
	BIG	-10,-20,-5
	BIG	-20,-10,-5
	BIG	-20,10,-5
	Finplot

ftorus
	ENTETE	ptorus
	;faces internes

	INV4	0,-1,16,0,7,23
	INV4	1,-1,17,1,0,16
	INV4	0,-1,18,2,1,17
	INV4	1,-1,19,3,2,18
	INV4	0,-1,20,4,3,19
	INV4	1,-1,21,5,4,20
	INV4	0,-1,22,6,5,21
	INV4	1,-1,23,7,6,22
	INV4	0,-1,16,0,7,23

	;faces dessus

	INV4	2,-1,0,1,9,8
	INV4	3,-1,1,2,10,9
	INV4	2,-1,2,3,11,10
	INV4	3,-1,3,4,12,11
	INV4	2,-1,4,5,13,12
	INV4	3,-1,5,6,14,13
	INV4	2,-1,6,7,15,14
	INV4	3,-1,7,0,8,15

	;faces dessous

	INV4	2,-1,9,17,16,8
	INV4	3,-1,10,18,17,9
	INV4	2,-1,11,19,18,10
	INV4	3,-1,12,20,19,11
	INV4	2,-1,13,21,20,12
	INV4	3,-1,14,22,21,13
	INV4	2,-1,15,23,22,14
	INV4	3,-1,8,16,23,15
	RET
pmine
	BIG	-10,20,0
	BIG	10,20,0
	BIG	20,10,0
	BIG	20,-10,0
	BIG	10,-20,0
	BIG	-10,-20,0
	BIG	-20,-10,0
	BIG	-20,10,0
	BIG	0,0,30
	Finplot
fmine
	ENTETE	pmine
	INV3	0,-1,0,1,8
	INV3	1,-1,2,3,8
	INV3	0,-1,4,5,8
	INV3	1,-1,6,7,8
	INV3	2,-1,0,8,1
	INV3	3,-1,2,8,3
	INV3	2,-1,4,8,5
	INV3	3,-1,6,8,7
	RET

pvcube
	Plot	 40,-40,-40
	Plot	 40, 40,-40
	Plot	-40, 40,-40
	Plot	-40,-40,-40
	Plot	 40,-40, 40
	Plot	 40, 40, 40
	Plot	-40, 40, 40
	Plot	-40,-40, 40
	Finplot

fvcube
	ENTETE	pvcube
	;faces internes

	INV4	0,-1,5,1,0,4
	INV4	0,-1,0,3,7,4
	INV4	1,-1,3,2,6,7
	INV4	1,-1,2,1,5,6

	;faces externes

	INV4	2,-1,5,4,0,1
	INV4	2,-1,0,4,7,3
	INV4	3,-1,3,7,6,2
	INV4	3,-1,2,6,5,1
	RET

pspider2
	Plot	-15,40,0
	Plot	15,40,0
	Plot	10,-20,0
	Plot	-10,-20,0
	Plot	-50,-30,-50
	Plot	-50,-50,-50
	Plot	50,-30,-50
	Plot	50,-50,-50
	Plot	5,-80,-20
	Plot	-5,-80,-20
	Plot	-10,40,-10
	Plot	10,40,-10
	Finplot

fspider2
	ENTETE	pspider2

;	ailes dessous

	INV4	0,-1,7,2,11,6
	INV4	0,-1,4,10,3,5

;	cotes

	INV3	1,-1,3,10,9
	INV3	1,-1,11,2,8

;	dessous

	INV4	2,-1,11,8,9,10

;	reacteurs

	INV4	1,-1,10,0,1,11
	INV3	2,-1,6,11,1
	INV3	2,-1,4,0,10

;	dessus

	INV4	2,-1,1,0,3,2

;	ailes dessus

	INV4	3,-1,6,1,2,7
	INV4	3,-1,3,0,4,5

;	cockpit

	INV4	3,-1,2,3,9,8
	RET

prcube
	Plot	 40,-40,-40
	Plot	 40, 40,-40
	Plot	-40, 40,-40
	Plot	-40,-40,-40
	Plot	 40,-40, 40
	Plot	 40, 40, 40
	Plot	-40, 40, 40
	Plot	-40,-40, 40

frcube
	;faces externes

	INV4	0,-1,1,0,3,2
	INV4	1,-1,5,6,7,4
	INV4	2,-1,5,4,0,1
	INV4	0,-1,0,4,7,3
	INV4	1,-1,3,7,6,2
	INV4	2,-1,2,6,5,1
	RET

	dc.b	'Finr'

	END
	
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


INITDRAW:MACRO
	dc.w	prg_init
	ENDM

TEST	MACRO
	dc.w	prg_test
	dc.w	\1*4+segments,\3*4+segments,\2*4+segments
	dc.w	\5-*-2
	ENDM

DRAW	MACRO
	dc.w	prg_draw
	dc.w	\1*4+segments,\2*4+segments
	ENDM

SKIP	MACRO
	dc.w	prg_skip
	dc.l	\1
	ENDM

AFFPOLY:MACRO
	ifeq	\1
	ifeq	\2+1
	dc.w	prg_poly0
	elseif
	dc.w	prg_poly00
	dc.w	\2
	endc
	endc

	ifeq	\1-1
	ifeq	\2+1
	dc.w	prg_poly1
	elseif
	dc.w	prg_poly10
	dc.w	\2
	endc
	endc

	ifeq	\1-2
	ifeq	\2+1
	dc.w	prg_poly2
	elseif
	dc.w	prg_poly20
	dc.w	\2
	endc
	endc

	ifeq	\1-3
	ifeq	\2+1
	dc.w	prg_poly3
	elseif
	dc.w	prg_poly30
	dc.w	\2
	endc
	endc

	ENDM

RET	MACRO
	dc.w	prg_rts
	ENDM

AFF3	MACRO
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\3
	AFFPOLY	\1,\2
	ENDM

AFF4	MACRO
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\3
	AFFPOLY	\1,\2
	ENDM

FACE3	MACRO
	TEST	\3,\4,\5,-1,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\3
	AFFPOLY	\1,\2
\@
	ENDM
FACE4	MACRO
	TEST	\3,\4,\5,\6,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\3
	AFFPOLY	\1,\2
\@
	ENDM

FACE5	MACRO
	TEST	\3,\4,\5,\6,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\7
	DRAW	\7,\3
	AFFPOLY	\1,\2
\@
	ENDM

FACE6	MACRO
	TEST	\3,\4,\5,\6,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\7
	DRAW	\7,\8
	DRAW	\8,\3
	AFFPOLY	\1,\2
\@
	ENDM

FACE7	MACRO
	TEST	\3,\4,\5,\6,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\7
	DRAW	\7,\8
	DRAW	\8,\9
	DRAW	\9,\3
	AFFPOLY	\1,\2
\@
	ENDM

FACE8	MACRO
	TEST	\3,\4,\5,\6,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\7
	DRAW	\7,\8
	DRAW	\8,\9
	DRAW	\9,\A
	DRAW	\A,\3
	AFFPOLY	\1,\2
\@
	ENDM

INV3	MACRO
	FACE3	\1,\2,\5,\4,\3
	ENDM
INV4	MACRO
	FACE4	\1,\2,\6,\5,\4,\3
	ENDM
INV5	MACRO
	FACE5	\1,\2,\7,\6,\5,\4,\3
	ENDM
INV6	MACRO
	FACE6	\1,\2,\8,\7,\6,\5,\4,\3
	ENDM
INV7	MACRO
	FACE7	\1,\2,\9,\8,\7,\6,\5,\4,\3
	ENDM
INV8	MACRO
	FACE8	\1,\2,\A,\9,\8,\7,\6,\5,\4,\3
	ENDM
;
; structure utilis‚e :
;
;	0.L=liste des coordonn‚es
;	4.L=adresse routine affichage
;	8.L=palette objet
;	12.L=fin
;
; … impl‚menter :
;	- sc‚nario (X,Y,Z) d‚part+arriv‚e+nb images
;	- zoom maximal … stocker
;
NBOBJETS = 13+14
all_objects:
	dc.l	coords_spider,spider,palette1
	dc.l	coords_cube,cube,palette2
	dc.l	coords_tetra,tetraedre,palette3
	dc.l	coords_grille,grille,palette4
	dc.l	coords_spacecraft,spacecraft,palette5

	dc.l	coords_cube2,cube2,palette6
	dc.l	coords_cube3,cube3,palette7
	dc.l	coords_pyramide,pyramide,palette8
	dc.l	coords_carre,carre,palette1
	dc.l	coords_alliance,alliance,palette2
	dc.l	coords_craft,craft,palette3
	dc.l	coords_dodecaedre,dodecaedre,palette4

	dc.l	pspider2,fspider2,palette5
	dc.l	pvcube,fvcube,palette6
	dc.l	prcube,frcube,palette7
	dc.l	pmine,fmine,palette8
	dc.l	ptorus,ftorus,palette1
	dc.l	pchiffre8,fchiffre8,palette2
	dc.l	plettrea,flettrea,palette3
	dc.l	pdalle,fdalle,palette4
	dc.l	puncube,funcube,palette5
	dc.l	pdeuxcube,fdeuxcube,palette6
	dc.l	ppyramide,fpyramide,palette7
	dc.l	pglider2,fglider2,palette8
	dc.l	pdodecaedre,fdodecaedre,palette1
	dc.l	pnscarre,fnscarre,palette2
	dc.l	picosaedre,ficosaedre,palette3


pchiffre8
	dc.w	14

	BIG	-20,30,0
	BIG	20,30,0
	BIG	-10,20,0
	BIG	10,20,0
	BIG	-10,5,0
	BIG	10,5,0
	BIG	-20,0,0
	BIG	20,0,0
	BIG	-10,-5,0
	BIG	10,-5,0
	BIG	-10,-20,0
	BIG	10,-20,0
	BIG	-20,-30,0
	BIG	20,-30,0

fchiffre8
	INV4	0,-1,1,0,2,3
	INV4	0,-1,0,6,4,2
	INV4	0,-1,1,3,5,7
	INV6	0,-1,5,4,6,8,9,7
	INV4	0,-1,6,12,10,8
	INV4	0,-1,9,11,13,7
	INV4	0,-1,10,12,13,11
	RET

plettrea
	dc.w	11

	BIG	-5,20,5
	BIG	5,20,5
	BIG	0,10,5
	BIG	-8,-5,5
	BIG	8,-5,5
	BIG	-10,-10,5
	BIG	10,-10,5
	BIG	-25,-20,5
	BIG	-15,-20,5
	BIG	15,-20,5
	BIG	25,-20,5

flettrea
	INV4	0,-1,0,7,8,1
	INV4	0,-1,9,10,1,0
	INV4	0,-1,3,5,6,4

	INV4	1,-1,0,1,8,7
	INV4	1,-1,9,0,1,10
	INV4	1,-1,3,4,6,5
	RET

pdalle
	dc.w	4
	Plot	50,50,0
	Plot	50,-50,0
	Plot	-50,-50,0
	Plot	-50,50,0

fdalle
	INV4	0,-1,3,2,1,0
	INV4	1,-1,0,1,2,3
	RET

puncube
	dc.w	8

	Plot	-35,35,15
	Plot	-5,35,15
	Plot	-5,5,15
	Plot	-35,5,15
	Plot	-35,35,-15
	Plot	-5,35,-15
	Plot	-5,5,-15
	Plot	-35,5,-15

funcube
	INV4	0,-1,1,2,6,5
	INV4	1,-1,3,2,1,0
	INV4	0,-1,1,5,4,0
	INV4	2,-1,0,4,7,3
	INV4	3,-1,3,7,6,2
	INV4	1,-1,4,5,6,7
	RET

pdeuxcube
	dc.w	16

	Plot	-40,40,15
	Plot	-10,40,15
	Plot	-10,10,15
	Plot	-40,10,15
	Plot	-40,40,-15
	Plot	-10,40,-15
	Plot	-10,10,-15
	Plot	-40,10,-15

	Plot	10,40,15
	Plot	40,40,15
	Plot	40,10,15
	Plot	10,10,15
	Plot	10,40,-15
	Plot	40,40,-15
	Plot	40,10,-15
	Plot	10,10,-15

fdeuxcube
	INV4	0,-1,1,2,6,5
	INV4	0,-1,8,12,15,11
	INV4	1,-1,3,2,1,0
	INV4	0,-1,1,5,4,0
	INV4	2,-1,0,4,7,3
	INV4	3,-1,3,7,6,2
	INV4	0,-1,4,5,6,7		;6
	INV4	1,-1,11,10,9,8
	INV4	0,-1,9,13,12,8
	INV4	3,-1,11,15,14,10
	INV4	0,-1,12,13,14,15	;6
	INV4	0,-1,9,10,14,13
	RET

ppyramide
	dc.w	13

	Plot	-30,30,0
	Plot	30,30,0
	Plot	30,-30,0
	Plot	-30,-30,0
	Plot	-20,20,20
	Plot	20,20,20
	Plot	20,-20,20
	Plot	-20,-20,20
	Plot	-15,15,30
	Plot	15,15,30
	Plot	15,-15,30
	Plot	-15,-15,30
	Plot	0,0,60

fpyramide

	INV4	0,-1,7,6,5,4
	INV4	0,-1,8,9,10,11
	INV4	1,-1,0,1,2,3
	INV3	2,-1,12,9,8
	INV4	2,-1,5,1,0,4
	INV3	3,-1,12,10,9
	INV4	3,-1,6,2,1,5
	INV3	1,-1,12,11,10	;4
	INV4	2,-1,7,3,2,6	;4
	INV3	3,-1,12,8,11	;4
	INV4	1,-1,4,0,3,7	;4
	RET

pglider2
	dc.w	8

	Plot	-20,40,0
	Plot	20,40,0
	Plot	-40,-40,0
	Plot	40,-40,0
	Plot	-20,-40,10
	Plot	20,-40,10
	Plot	-20,-40,-10
	Plot	20,-40,-10

fglider2
	INV4	0,-1,0,4,5,1
	INV3	1,-1,0,2,4
	INV3	1,-1,1,5,3
	INV4	2,-1,0,1,7,6
	INV3	3,-1,0,6,2
	INV3	3,-1,1,3,7
	INV6	2,-1,4,2,6,7,3,5
	RET

DODEC	MACRO
	Plot	\1/6/2,\2/6/2,\3/6/2
	ENDM

pdodecaedre:
	DC.W	20

	DODEC	283,631,390
	DODEC	458,631,-149
	DODEC	0,631,-482
	DODEC	-458,631,-149
	DODEC	-283,631,390
	DODEC	-458,149,631
	DODEC	0,-149,780
	DODEC	458,149,631
	DODEC	742,-149,241
	DODEC	742,149,-241
	DODEC	458,-149,-631
	DODEC	0,149,-780
	DODEC	-458,-149,-631
	DODEC	-742,149,-241
	DODEC	-742,-149,241
	DODEC	-283,-631,-390
	DODEC	-458,-631,149
	DODEC	0,-631,482
	DODEC	458,-631,149
	DODEC	283,-631,-390

fdodecaedre
	INV5	0,-1,0,1,2,3,4
	INV5	1,-1,0,4,5,6,7
	INV5	2,-1,0,7,8,9,1
	INV5	1,-1,1,9,10,11,2
	INV5	2,-1,2,11,12,13,3
	INV5	3,-1,3,13,14,5,4
	INV5	0,-1,12,15,16,14,13
	INV5	2,-1,14,16,17,6,5
	INV5	3,-1,6,17,18,8,7
	INV5	0,-1,8,18,19,10,9
	INV5	3,-1,11,10,19,15,12
	INV5	1,-1,17,16,15,19,18
	RET

pnscarre
	DC.W	28

	Plot	-10,10,-30
	Plot	10,10,-30
	Plot	10,-10,-30
	Plot	-10,-10,-30

	Plot	-20,20,-20
	Plot	20,20,-20
	Plot	20,-20,-20
	Plot	-20,-20,-20

	Plot	-30,30,-10
	Plot	30,30,-10
	Plot	30,-30,-10
	Plot	-30,-30,-10

	Plot	-40,40,0
	Plot	40,40,0
	Plot	40,-40,0
	Plot	-40,-40,0

	Plot	-30,30,10
	Plot	30,30,10
	Plot	30,-30,10
	Plot	-30,-30,10

	Plot	-20,20,20
	Plot	20,20,20
	Plot	20,-20,20
	Plot	-20,-20,20

	Plot	-10,10,30
	Plot	10,10,30
	Plot	10,-10,30
	Plot	-10,-10,30

fnscarre:
	INV4	0,-1,3,2,1,0
	INV4	1,-1,7,6,5,4
	INV4	2,-1,11,10,9,8
	INV4	3,-1,15,14,13,12
	INV4	2,-1,19,18,17,16
	INV4	1,-1,23,22,21,20
	INV4	0,-1,27,26,25,24

	;faces autre cote

	INV4	0,-1,24,25,26,27
	INV4	1,-1,20,21,22,23
	INV4	2,-1,16,17,18,19
	INV4	3,-1,12,13,14,15
	INV4	2,-1,8,9,10,11
	INV4	1,-1,4,5,6,7
	INV4	0,-1,0,1,2,3
	RET
DIM	MACRO
	Plot	\1/2,\2/2,\3/2
	ENDM

picosaedre
	Plot	12

	DIM	89,0,44
	DIM	27,85,44
	DIM	-72,52,44
	DIM	-72,-52,44
	DIM	27,-85,44
	DIM	0,0,100
	DIM	0,0,-100
	DIM	72,52,-44
	DIM	-27,85,-44
	DIM	-89,0,-44
	DIM	-27,-85,-44
	DIM	72,-52,-44
;
; BUG ICOSAEDRE :
;	SOUSTRAIRE 1 A CHAQUE NUMERO DE SOMMET !!!!
;
FAC3	MACRO
	INV3	\1,\2,(\3-1),(\4-1),(\5-1)
	ENDM
ficosaedre:
	FAC3	0,-1,1,2,6
	FAC3	1,-1,2,3,6
	FAC3	2,-1,3,4,6
	FAC3	3,-1,4,5,6
	FAC3	0,-1,5,1,6
	FAC3	1,-1,12,1,5
	FAC3	2,-1,12,8,1
	FAC3	3,-1,8,2,1
	FAC3	0,-1,9,2,8
	FAC3	1,-1,9,3,2
	FAC3	2,-1,9,10,3
	FAC3	3,-1,10,4,3
	FAC3	0,-1,10,11,4
	FAC3	1,-1,11,5,4
	FAC3	0,-1,11,12,5
	FAC3	1,-1,7,8,12
	FAC3	3,-1,7,9,8
	FAC3	0,-1,7,10,9
	FAC3	1,-1,7,11,10
	FAC3	2,-1,7,12,11
	RET



spacecraft
	FACE4	0,-1,0,1,4,3	;ABED
	FACE3	1,-1,1,5,4,-1	;BFE
	FACE3	1,-1,0,3,2,-1	;ADC
	FACE3	2,-1,5,1,7,-1	;FBH
	FACE3	2,-1,6,0,2,-1	;GAC
	FACE4	0,-1,6,7,1,0	;GHBA
	FACE4	3,-1,3,4,7,6	;DEHG
	FACE3	0,-1,2,3,6,-1	;CDG
	FACE3	0,-1,4,5,7,-1	;EFH
	RET
RED	MACRO
	Plot	\1/2,\2/2,\3/2
	ENDM
		* Exemple de forme 3D ---> un cube
coords_cube2:
	dc.w	8
	RED	-100,-100,-100
	RED	100,-100,-100
	RED	100,100,-100
	RED	-100,100,-100
	RED	-100,-100,100
	RED	100,-100,100
	RED	100,100,100
	RED	-100,100,100
cube2:
	INV4	0,-1,4,5,6,7
	INV4	1,-1,7,6,2,3
	INV4	2,-1,0,1,5,4
	INV4	0,-1,4,7,3,0
	INV4	1,-1,1,2,6,5
	INV4	2,-1,3,2,1,0
	RET

coords_cube3:
	dc.w	8
	RED	-100,-100,-100
	RED	100,-100,-100
	RED	100,100,-100
	RED	-100,100,-100
	RED	-100,-100,100
	RED	100,-100,100
	RED	100,100,100
	RED	-100,100,100
cube3:
	INV4	0,-1,3,7,4,0
	INV4	1,-1,0,4,5,1
	INV4	0,-1,1,5,6,2
	INV4	1,-1,2,6,7,3
	INV4	2,-1,0,4,7,3
	INV4	3,-1,1,5,4,0
	INV4	2,-1,2,6,5,1
	INV4	3,-1,3,7,6,2
	RET

coords_pyramide:
	dc.w	5
	RED	0,150,0
	RED	-100,0,-100
	RED	100,0,-100
	RED	100,0,100
	RED	-100,0,100
pyramide:
	INV3	0,-1,0,2,1
	INV3	1,-1,0,3,2
	INV3	2,-1,0,4,3
	INV3	3,-1,0,1,4
	INV4	0,-1,1,2,3,4
	RET

coords_carre:
	dc.w	4
	RED	-100,-100,-100
	RED	-100,-100,100
	RED	100,-100,100
	RED	100,-100,-100
carre:
	INV4	0,-1,0,1,2,3
	INV4	0,-1,3,2,1,0
	RET

coords_alliance:
	dc.w	22		;22 points.
	RED	-32,80,-32	;Points No 0
	RED	-32,80,32	;Points No 1
	RED	32,80,-32	;Points No 2
	RED	32,80,32	;Points No 3
	RED	112,-80,-32	;Points No 4
	RED	112,-80,32	;Points No 5
	RED	48,-80,-32	;Points No 6
	RED	48,-80,32	;Points No 7
	RED	32,-48,-32	;Points No 8
	RED	32,-48,32	;Points No 9
	RED	-32,-48,-32	;Points No 10
	RED	-32,-48,32	;Points No 11
	RED	-48,-80,-32	;Points No 12
	RED	-48,-80,32	;Points No 13
	RED	-112,-80,-32	;Points No 14
	RED	-112,-80,32	;Points No 15
	RED	-16,-16,-32	;Points No 16
	RED	-16,-16,32	;Points No 17
	RED	16,-16,-32	;Points No 18
	RED	16,-16,32	;Points No 19
	RED	0,16,-32	;Points No 20
	RED	0,16,32		;Points No 21

alliance:
	INV4	0,-1,19,21,20,18
	INV4	1,-1,21,17,16,20
	INV4	0,-1,17,19,18,16
	INV4	1,-1,1,3,2,0
	INV4	1,-1,5,7,6,4
	INV4	1,-1,9,11,10,8
	INV4	1,-1,13,15,14,12
	INV4	0,-1,3,5,4,2
	INV4	0,-1,7,9,8,6
	INV4	0,-1,11,13,12,10
	INV4	0,-1,15,1,0,14
	INV4	2,-1,16,18,8,10
;	INV7	2,-1,0,2,20,16,10,12,14
	FACE7	2,-1,20,2,0,14,12,10,16

;	INV6	2,-1,2,4,6,8,18,20
	FACE6	2,-1,6,4,2,20,18,8

	INV4	3,-1,11,9,19,17
;	INV7	3,-1,1,15,13,11,17,21,3
	FACE7	3,-1,13,15,1,3,21,17,11

;	INV6	3,-1,7,5,3,21,19,9
	FACE6	3,-1,3,5,7,9,19,21
	RET

coords_craft:
	dc.w	14		;14 points.
	RED	0,0,100		;Points No 0
	RED	0,10,10		;Points No 1
	RED	0,-10,10	;Points No 2
	RED	-21,0,10	;Points No 3
	RED	19,0,10		;Points No 4
	RED	0,19,-21	;Points No 5
	RED	0,12,-100	;Points No 6
	RED	0,-6,-100	;Points No 7
	RED	-12,0,-100	;Points No 8
	RED	12,0,-100	;Points No 9
	RED	-165,0,-61	;Points No 10
	RED	-168,0,-85	;Points No 11
	RED	168,0,-85	;Points No 12
	RED	168,0,-61	;Points No 13

craft:
	INV3	0,-1,3,1,5
	INV3	0,-1,1,4,5
	INV3	1,-1,3,0,1
	INV3	2,-1,0,4,1
	INV3	3,-1,2,0,3
	INV3	1,-1,2,4,0
	INV4	1,-1,8,3,5,6
	INV4	2,-1,4,9,6,5
	INV4	3,-1,7,2,3,8
	INV4	1,-1,4,2,7,9
	INV4	0,-1,9,7,8,6
	INV4	0,-1,3,8,11,10
	INV4	0,-1,4,13,12,9
	INV4	0,-1,10,11,8,3
	INV4	0,-1,9,12,13,4
	RET

;
XYZ	MACRO
	Plot	\1*10,\2*10,\3*20
	ENDM

coords_spacecraft
	DC.W	8
	XYZ	-2,5,0
	XYZ	2,5,0
	XYZ	-6,-5,0
	XYZ	-2,-5,1
	XYZ	2,-5,1
	XYZ	6,-5,0
	XYZ	-2,-5,-1
	XYZ	2,-5,-1

