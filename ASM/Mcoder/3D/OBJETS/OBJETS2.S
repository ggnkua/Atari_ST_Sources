	include	"defmacro.s"
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
	Defobjet	fvcube
	Defobjet	fspider2
	Defobjet	frcube
	Defobjet	fmine
	Defobjet	ftorus
	Defobjet	grille
	Defobjet	tetraedre
	Defobjet	spider
	
	Fin_defobjet
 ; #] Def objet:
	
RET	MACRO
	Fin
	ENDM
	
ENTETE	macro
	Flab
	Def_plot	\1
	Init_color	1
	endm
BIG	MACRO
	Plot	\1*2,\2*2,\3*2
	ENDM
INV3	MACRO
	Hide	\3,\4,\5,.\@
	Face1pc	\1+1
	Affpoly	\3,\4,\5
.\@
	ENDM

INV4	MACRO
	Hide	\3,\4,\5,.\@
	Face1pc	\1+1
	Affpoly	\3,\4,\5,\6
.\@
	ENDM
INV5	MACRO
	Hide	\3,\4,\5,.\@
	Face1pc	\1+1
	Affpoly	\3,\4,\5,\6,\7
.\@
	ENDM
FACE3	MACRO
	Hide	\5,\4,\3,.\@
	Face1pc	\1+1
	Affpoly	\5,\4,\3
.\@
	ENDM

FACE4	MACRO
	Hide	\5,\4,\3,.\@
	Face1pc	\1+1
	Affpoly	\6,\5,\4,\3
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
	Face1pc	\1+1
	Affpoly	\6,\5,\4,\3
.\@
	ENDM

coords_spider
	Debut_plot
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
	Fin_plot
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
; affichage d'un t‚traŠdre
;
coords_tetra:
	Debut_plot
	Plot	0,50,0
	Plot	43,-25,0
	Plot	-43,-25,0
	Plot	0,0,50
	Fin_plot
tetraedre:
	ENTETE	coords_tetra
	FACE3	0,-1,0,2,1
	FACE3	1,-1,0,3,2
	FACE3	2,-1,0,1,3
	FACE3	3,-1,1,2,3
	RET
coords_grille:
	Debut_plot
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
	Fin_plot
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

ptorus
	Debut_plot
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
	Fin_plot

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
	Debut_plot
	BIG	-10,20,0
	BIG	10,20,0
	BIG	20,10,0
	BIG	20,-10,0
	BIG	10,-20,0
	BIG	-10,-20,0
	BIG	-20,-10,0
	BIG	-20,10,0
	BIG	0,0,30
	Fin_plot
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
	Plot	 40,40,-40
	Plot	-40,40,-40
	Plot	-40,-40,-40
	Plot	 40,-40,40
	Plot	 40,40,40
	Plot	-40,40,40
	Plot	-40,-40,40
	Fin_plot

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
	Debut_plot
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
	Fin_plot

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
	Debut_plot
	Plot	 40,-40,-40
	Plot	 40,40,-40
	Plot	-40,40,-40
	Plot	-40,-40,-40
	Plot	 40,-40,40
	Plot	 40,40,40
	Plot	-40,40,40
	Plot	-40,-40,40
	Fin_plot

frcube
	;faces externes

	INV4	0,-1,1,0,3,2
	INV4	1,-1,5,6,7,4
	INV4	2,-1,5,4,0,1
	INV4	0,-1,0,4,7,3
	INV4	1,-1,3,7,6,2
	INV4	2,-1,2,6,5,1
	RET

fin:
