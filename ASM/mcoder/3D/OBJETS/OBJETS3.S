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
	dc.w	\3,\1,-(\2)
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
	IFGE	NARG-9
	dc.w	\9
	ENDC
	IFGE	NARG-10
	dc.w	\A
	ENDC
	dc.w	-1
	Face1pc	1
	ENDM

Vertices2	MACRO
	dc.b	'Vert'
	
	IFGE	NARG-3
	dc.w	\3-1
	ENDC
	IFGE	NARG-4
	dc.w	\4-1
	ENDC
	IFGE	NARG-5
	dc.w	\5-1
	ENDC
	IFGE	NARG-6
	dc.w	\6-1
	ENDC
	IFGE	NARG-7
	dc.w	\7-1
	ENDC
	IFGE	NARG-8
	dc.w	\8-1
	ENDC
	IFGE	NARG-9
	dc.w	\9-1
	ENDC
	IFGE	NARG-10
	dc.w	\A-1
	ENDC
	dc.w	-1
	Face1pc	1
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
FFACE2:	MACRO
	Hide	(\1-1),(\2-1),(\3-1),\4
	ENDM
RET	macro
	Fin
	endm
ENTETE	macro
	Def_plot	\1
	Init_color	1
	endm

SKIP	macro
	Goto	\1
	endm

	Defobjet	prga
	Defobjet	prgb
	Defobjet	prgc
	Defobjet	prgd
	Defobjet	prge
	Defobjet	prgf
	Defobjet	prgg
	Defobjet	prgh
	Defobjet	prgi
	Defobjet	prgj
	Defobjet	prgk
	Defobjet	prgl
	Defobjet	prgm
	Defobjet	prgn
	Defobjet	prgo
	Defobjet	prgp
	Defobjet	prgq
	Defobjet	prgr
	Defobjet	prgs
	Defobjet	prgt
	Defobjet	prgu
	Defobjet	prgv
	Defobjet	prgw
	Defobjet	prgx
	Defobjet	prgy
	Defobjet	prgz
;
; Alphabet Kefrens
;
lettrea:
	Plot	-25,-48,0
	Plot	-50,-32,0
	Plot	-50,48,0
	Plot	-25,-32,0
	Plot	-25,0,0
	Plot	-25,32,0
	Plot	-25,48,0
	Plot	25,-32,0
	Plot	25,0,0
	Plot	25,32,0
	Plot	25,48,0
	Plot	25,-48,0
	Plot	50,-32,0
	Plot	50,48,0
	Finplot
lettreb:
	Plot	-50,-48,0
	Plot	-50,48,0
	Plot	-25,-32,0
	Plot	-25,-16,0
	Plot	-25,16,0
	Plot	-25,32,0
	Plot	25,-32,0
	Plot	25,-16,0
	Plot	25,16,0
	Plot	25,32,0
	Plot	25,-48,0
	Plot	50,-32,0
	Plot	50,32,0
	Plot	25,48,0
	Finplot
lettrec:
	Plot	-25,-48,0
	Plot	-50,-32,0
	Plot	-50,32,0
	Plot	-25,48,0
	Plot	-25,-32,0
	Plot	-25,32,0
	Plot	50,-48,0
	Plot	50,-32,0
	Plot	50,32,0
	Plot	50,48,0
	Finplot
lettred:
	Plot	-50,-48,0
	Plot	-50,48,0
	Plot	-25,-32,0
	Plot	-25,32,0
	Plot	25,-32,0
	Plot	25,32,0
	Plot	25,-48,0
	Plot	50,-32,0
	Plot	50,32,0
	Plot	25,48,0
	Finplot
lettree:
	Plot	-25,-48,0
	Plot	-50,-32,0
	Plot	-50,32,0
	Plot	-25,48,0
	Plot	-25,-32,0
	Plot	-25,-16,0
	Plot	-25,16,0
	Plot	-25,32,0
	Plot	25,-16,0
	Plot	25,16,0
	Plot	50,-48,0
	Plot	50,-32,0
	Plot	50,32,0
	Plot	50,48,0
	Finplot
lettref:
	Plot	-25,-48,0
	Plot	-50,-32,0
	Plot	-50,48,0
	Plot	-25,-32,0
	Plot	-25,-16,0
	Plot	-25,16,0
	Plot	-25,48,0
	Plot	25,-16,0
	Plot	25,16,0
	Plot	50,-48,0
	Plot	50,-32,0
	Finplot
lettreg:
	Plot	-25,-48,0
	Plot	-50,-32,0
	Plot	-50,32,0
	Plot	-25,48,0
	Plot	-25,-32,0
	Plot	-25,32,0
	Plot	50,-48,0
	Plot	50,-32,0
	Plot	50,0,0
	Plot	50,48,0
	Plot	25,0,0
	Plot	25,32,0
	Finplot
lettreh:
	Plot	-50,-48,0
	Plot	-50,48,0
	Plot	-25,-48,0
	Plot	-25,-16,0
	Plot	-25,16,0
	Plot	-25,48,0
	Plot	25,-48,0
	Plot	25,-16,0
	Plot	25,16,0
	Plot	25,48,0
	Plot	50,-48,0
	Plot	50,48,0
	Finplot
lettrei:
	Plot	-25,-48,0
	Plot	-25,-32,0
	Plot	25,-48,0
	Plot	25,-32,0
	Plot	-25,32,0
	Plot	-25,48,0
	Plot	25,32,0
	Plot	25,48,0
	Plot	-13,-32,0
	Plot	-13,32,0
	Plot	12,-32,0
	Plot	12,32,0
	Finplot
lettrej:
	Plot	-50,-48,0
	Plot	-50,-32,0
	Plot	25,-32,0
	Plot	25,32,0
	Plot	50,-48,0
	Plot	50,32,0
	Plot	-50,0,0
	Plot	-50,32,0
	Plot	-25,0,0
	Plot	-25,32,0
	Plot	-50,32,0
	Plot	-25,48,0
	Plot	50,32,0
	Plot	25,48,0
	Finplot
lettrek:
	Plot	-50,-48,0
	Plot	-50,48,0
	Plot	-25,-48,0
	Plot	-25,-16,0
	Plot	25,-48,0
	Plot	-25,-16,0
	Plot	50,-48,0
	Plot	0,-16,0
	Plot	-25,16,0
	Plot	-25,48,0
	Plot	-25,16,0
	Plot	25,48,0
	Plot	0,16,0
	Plot	50,48,0
	Plot	0,-16,0
	Plot	0,16,0
	Finplot
lettrel:
	Plot	-50,-48,0
	Plot	-50,48,0
	Plot	-25,-48,0
	Plot	-25,32,0
	Plot	50,32,0
	Plot	50,48,0
	Finplot
lettrem:
	Plot	-50,-48,0
	Plot	-50,48,0
	Plot	50,-48,0
	Plot	50,48,0
	Plot	-25,-32,0
	Plot	-25,48,0
	Plot	25,-32,0
	Plot	25,48,0
	Plot	-25,-48,0
	Plot	0,-32,0
	Plot	25,-48,0
	Plot	0,-32,0
	Plot	-25,-32,0
	Plot	0,0,0
	Plot	25,-32,0
	Plot	0,0,0
	Finplot
lettren:
	Plot	-50,-48,0
	Plot	-50,48,0
	Plot	50,-48,0
	Plot	50,48,0
	Plot	-25,-32,0
	Plot	-25,48,0
	Plot	25,-48,0
	Plot	25,32,0
	Plot	-25,-48,0
	Plot	25,32,0
	Plot	-25,-32,0
	Plot	25,48,0
	Finplot
lettreo:
	Plot	-25,-48,0
	Plot	-50,-32,0
	Plot	-50,32,0
	Plot	-25,48,0
	Plot	25,-48,0
	Plot	50,-32,0
	Plot	50,32,0
	Plot	25,48,0
	Plot	-25,-32,0
	Plot	-25,32,0
	Plot	25,-32,0
	Plot	25,32,0
	Finplot
lettrep:
	Plot	-50,-48,0
	Plot	-50,48,0
	Plot	25,-48,0
	Plot	50,-32,0
	Plot	-25,-32,0
	Plot	-25,0,0
	Plot	25,-32,0
	Plot	25,0,0
	Plot	50,-32,0
	Plot	50,0,0
	Plot	25,32,0
	Plot	-25,32,0
	Plot	-25,48,0
	Finplot
lettreq:
	Plot	-25,-48,0
	Plot	-50,-32,0
	Plot	-50,32,0
	Plot	-25,48,0
	Plot	25,-48,0
	Plot	50,-32,0
	Plot	50,48,0
	Plot	-25,-32,0
	Plot	-25,32,0
	Plot	25,-32,0
	Plot	25,0,0
	Plot	0,0,0
	Plot	25,32,0
	Finplot
lettrer:
	Plot	-50,-48,0
	Plot	-50,48,0
	Plot	25,-48,0
	Plot	50,-32,0
	Plot	-25,-32,0
	Plot	-25,0,0
	Plot	25,-32,0
	Plot	25,0,0
	Plot	50,-32,0
	Plot	50,0,0
	Plot	25,32,0
	Plot	-25,32,0
	Plot	-25,48,0
	Plot	-25,32,0
	Plot	12,48,0
	Plot	12,32,0
	Plot	50,48,0
	Finplot
lettres:
	Plot	-25,-48,0
	Plot	-50,-32,0
	Plot	25,-48,0
	Plot	50,-32,0
	Plot	-50,-32,0
	Plot	-50,16,0
	Plot	-25,-32,0
	Plot	-25,-16,0
	Plot	50,-16,0
	Plot	50,32,0
	Plot	25,16,0
	Plot	25,32,0
	Plot	-50,32,0
	Plot	-25,48,0
	Plot	50,32,0
	Plot	25,48,0
	Finplot
lettret:
	Plot	-50,-48,0
	Plot	-50,-32,0
	Plot	50,-48,0
	Plot	50,-32,0
	Plot	-13,-32,0
	Plot	-13,48,0
	Plot	12,-32,0
	Plot	12,48,0
	Finplot
lettreu:
	Plot	-50,-48,0
	Plot	-50,32,0
	Plot	50,-48,0
	Plot	50,32,0
	Plot	-25,-48,0
	Plot	-25,32,0
	Plot	25,-48,0
	Plot	25,32,0
	Plot	-50,32,0
	Plot	-25,48,0
	Plot	50,32,0
	Plot	25,48,0
	Finplot
lettrev:
	Plot	-50,-48,0
	Plot	-13,48,0
	Plot	-25,-48,0
	Plot	0,32,0
	Plot	25,-48,0
	Plot	0,32,0
	Plot	50,-48,0
	Plot	12,48,0
	Finplot
lettrew:
	Plot	-50,-48,0
	Plot	-25,48,0
	Plot	50,-48,0
	Plot	25,48,0
	Plot	-25,-48,0
	Plot	-7,32,0
	Plot	25,-48,0
	Plot	6,32,0
	Plot	-7,32,0
	Plot	0,-16,0
	Plot	6,32,0
	Plot	0,-16,0
	Finplot
lettrex:
	Plot	-50,-48,0
	Plot	-13,0,0
	Plot	-50,48,0
	Plot	-13,0,0
	Plot	50,-48,0
	Plot	12,0,0
	Plot	50,48,0
	Plot	12,0,0
	Plot	-25,-48,0
	Plot	0,-32,0
	Plot	-25,48,0
	Plot	0,32,0
	Plot	25,-48,0
	Plot	0,-32,0
	Plot	25,48,0
	Plot	0,32,0
	Finplot
lettrey:
	Plot	-50,-48,0
	Plot	-13,0,0
	Plot	50,-48,0
	Plot	12,0,0
	Plot	-25,-48,0
	Plot	0,-32,0
	Plot	25,-48,0
	Plot	0,-32,0
	Plot	-13,0,0
	Plot	-13,48,0
	Plot	12,0,0
	Plot	12,48,0
	Finplot
lettrez:
	Plot	-50,-48,0
	Plot	-50,-32,0
	Plot	-50,32,0
	Plot	-50,48,0
	Plot	50,-48,0
	Plot	50,-32,0
	Plot	50,32,0
	Plot	50,48,0
	Plot	12,-32,0
	Plot	-50,32,0
	Plot	50,-32,0
	Plot	-13,32,0
	Finplot
prga:
	ENTETE	lettrea
	FFACE2	1,2,4,pra
	Vertices2	0,-1,1,2,4,8,13,12
	Vertices2	0,-1,2,3,7,6,5,4
	Vertices2	0,-1,5,6,10,9
	Vertices2	0,-1,8,9,10,11,14,13
	RET
pra:
	Vertices2	0,-1,1,12,13,8,4,2
	Vertices2	0,-1,2,4,5,6,7,3
	Vertices2	0,-1,5,9,10,6
	Vertices2	0,-1,8,13,14,11,10,9
	RET
prgb:
	ENTETE	lettreb
	FFACE2	1,3,7,prb
	Vertices2	0,-1,1,3,7,12,11
	Vertices2	0,-1,1,2,6,5,4,3
	Vertices2	0,-1,2,14,13,10,6
	Vertices2	0,-1,7,8,9,10,13,12
	Vertices2	0,-1,4,5,9,8
	RET
prb:
	Vertices2	0,-1,1,11,12,7,3
	Vertices2	0,-1,1,3,4,5,6,2
	Vertices2	0,-1,2,6,10,13,14
	Vertices2	0,-1,7,12,13,10,9,8
	Vertices2	0,-1,4,8,9,5
	RET
prgc:
	ENTETE	lettrec
	FFACE2	1,2,5,prc
	Vertices2	0,-1,1,2,5,8,7
	Vertices2	0,-1,2,3,4,6,5
	Vertices2	0,-1,6,4,10,9
	RET
prc:
	Vertices2	0,-1,1,7,8,5,2
	Vertices2	0,-1,2,5,6,4,3
	Vertices2	0,-1,6,9,10,4
	RET
prgd:
	ENTETE	lettred
	FFACE2	1,3,5,prd
	Vertices2	0,-1,1,3,5,8,7
	Vertices2	0,-1,1,2,4,3
	Vertices2	0,-1,2,10,9,6,4
	Vertices2	0,-1,5,6,9,8
	RET
prd:
	Vertices2	0,-1,1,7,8,5,3
	Vertices2	0,-1,1,3,4,2
	Vertices2	0,-1,2,4,6,9,10
	Vertices2	0,-1,5,8,9,6
	RET
prge:
	ENTETE	lettree
	FFACE2	1,2,5,pre
	Vertices2	0,-1,1,2,5,12,11
	Vertices2	0,-1,2,3,4,8,7,6,5
	Vertices2	0,-1,8,4,14,13
	Vertices2	0,-1,6,7,10,9
	RET
pre:
	Vertices2	0,-1,1,11,12,5,2
	Vertices2	0,-1,2,5,6,7,8,4,3
	Vertices2	0,-1,8,13,14,4
	Vertices2	0,-1,6,9,10,7
	RET
prgf:
	ENTETE	lettref
	FFACE2	1,2,4,prf
	Vertices2	0,-1,1,2,4,11,10
	Vertices2	0,-1,2,3,7,6,5,4
	Vertices2	0,-1,5,6,9,8
	RET
prf:
	Vertices2	0,-1,1,10,11,4,2
	Vertices2	0,-1,2,4,5,6,7,3
	Vertices2	0,-1,5,8,9,6
	RET
prgg:
	ENTETE	lettreg
	FFACE2	1,2,5,prg
	Vertices2	0,-1,1,2,5,8,7
	Vertices2	0,-1,2,3,4,6,5
	Vertices2	0,-1,6,4,10,12
	Vertices2	0,-1,11,12,10,9
	RET
prg:
	Vertices2	0,-1,1,7,8,5,2
	Vertices2	0,-1,2,5,6,4,3
	Vertices2	0,-1,6,12,10,4
	Vertices2	0,-1,11,9,10,12
	RET
prgh:
	ENTETE	lettreh
	FFACE2	1,2,6,prh
	Vertices2	0,-1,1,2,6,5,4,3
	Vertices2	0,-1,4,5,9,8
	Vertices2	0,-1,7,8,9,10,12,11
	RET
prh:
	Vertices2	0,-1,1,3,4,5,6,2
	Vertices2	0,-1,4,8,9,5
	Vertices2	0,-1,7,11,12,10,9,8
	RET
prgi:
	ENTETE	lettrei
	FFACE2	1,2,9,pri
	Vertices2	0,-1,1,2,9,11,4,3
	Vertices2	0,-1,9,10,12,11
	Vertices2	0,-1,5,6,8,7,12,10
	RET
pri:
	Vertices2	0,-1,1,3,4,11,9,2
	Vertices2	0,-1,9,11,12,10
	Vertices2	0,-1,5,10,12,7,8,6
	RET
prgj:
	ENTETE	lettrej
	FFACE2	1,2,3,prj
	Vertices2	0,-1,1,2,3,5
	Vertices2	0,-1,3,4,14,13,5
	Vertices2	0,-1,7,11,10,9
	Vertices2	0,-1,11,12,14,4,10
	RET
prj:
	Vertices2	0,-1,1,5,3,2
	Vertices2	0,-1,3,5,13,14,4
	Vertices2	0,-1,7,9,10,11
	Vertices2	0,-1,11,10,4,14,12
	RET
prgk:
	ENTETE	lettrek
	FFACE2	1,2,10,prk
	Vertices2	0,-1,1,2,10,11,6,3
	Vertices2	0,-1,5,6,15,7
	Vertices2	0,-1,6,11,16,15
	Vertices2	0,-1,11,12,14,16
	RET
prk:
	Vertices2	0,-1,1,3,6,11,10,2
	Vertices2	0,-1,5,7,15,6
	Vertices2	0,-1,6,15,16,11
	Vertices2	0,-1,11,16,14,12
	RET
prgl:
	ENTETE	lettrel
	FFACE2	1,2,4,prl
	Vertices2	0,-1,1,2,4,3
	Vertices2	0,-1,2,6,5,4
	RET
prl:
	Vertices2	0,-1,1,3,4,2
	Vertices2	0,-1,2,4,5,6
	RET
prgm:
	ENTETE	lettrem
	FFACE2	1,2,6,prm
	Vertices2	0,-1,1,2,6,13,9
	Vertices2	0,-1,9,13,16,12
	Vertices2	0,-1,12,16,15,11
	Vertices2	0,-1,11,15,8,4,3
	RET
prm:
	Vertices2	0,-1,1,9,13,6,2
	Vertices2	0,-1,9,12,16,13
	Vertices2	0,-1,12,11,15,16
	Vertices2	0,-1,11,3,4,8,15
	RET
prgn:
	ENTETE	lettren
	FFACE2	1,2,6,prn
	Vertices2	0,-1,1,2,6,11,9
	Vertices2	0,-1,9,11,12,10
	Vertices2	0,-1,7,10,12,4,3
	RET
prn:
	Vertices2	0,-1,1,9,11,6,2
	Vertices2	0,-1,9,10,12,11
	Vertices2	0,-1,7,3,4,12,10
	RET
prgo:
	ENTETE	lettreo
	FFACE2	1,2,3,pro
	Vertices2	0,-1,1,2,3,4,10,9
	Vertices2	0,-1,1,9,11,5
	Vertices2	0,-1,10,4,8,12
	Vertices2	0,-1,5,11,12,8,7,6
	RET
pro:
	Vertices2	0,-1,1,9,10,4,3,2
	Vertices2	0,-1,1,5,11,9
	Vertices2	0,-1,10,12,8,4
	Vertices2	0,-1,5,6,7,8,12,11
	RET
prgp:
	ENTETE	lettrep
	FFACE2	1,2,13,prp
	Vertices2	0,-1,1,2,13,12,6,5
	Vertices2	0,-1,1,5,7,9,3
	Vertices2	0,-1,6,12,11,10,8
	Vertices2	0,-1,7,8,10,9
	RET
prp:
	Vertices2	0,-1,1,5,6,12,13,2
	Vertices2	0,-1,1,3,9,7,5
	Vertices2	0,-1,6,8,10,11,12
	Vertices2	0,-1,7,9,10,8
	RET
prgq:
	ENTETE	lettreq
	FFACE2	1,2,3,prq
	Vertices2	0,-1,1,2,3,4,9,8
	Vertices2	0,-1,1,8,10,6,5
	Vertices2	0,-1,11,12,13
	Vertices2	0,-1,10,11,13,7,6
	Vertices2	0,-1,9,4,7,13
	RET
prq:
	Vertices2	0,-1,1,8,9,4,3,2
	Vertices2	0,-1,1,5,6,10,8
	Vertices2	0,-1,11,13,12
	Vertices2	0,-1,10,6,7,13,11
	Vertices2	0,-1,9,13,7,4
	RET
prgr:
	ENTETE	lettrer
	FFACE2	1,2,13,prr
	Vertices2	0,-1,1,2,13,14,6,5
	Vertices2	0,-1,1,5,7,9,3
	Vertices2	0,-1,14,15,17,16
	Vertices2	0,-1,6,14,16,11,10,8
	Vertices2	0,-1,7,8,10,9
	RET
prr:
	Vertices2	0,-1,1,5,6,14,13,2
	Vertices2	0,-1,1,3,9,7,5
	Vertices2	0,-1,14,16,17,15
	Vertices2	0,-1,6,8,10,11,16,14
	Vertices2	0,-1,7,9,10,8
	RET
prgs:
	ENTETE	lettres
	FFACE2	1,5,6,prs
	Vertices2	0,-1,1,5,6,8,7
	Vertices2	0,-1,1,7,4,3
	Vertices2	0,-1,8,6,11,9
	Vertices2	0,-1,13,14,16,15,12
	Vertices2	0,-1,11,12,15,9
	RET
prs:
	Vertices2	0,-1,1,7,8,6,5
	Vertices2	0,-1,1,3,4,7
	Vertices2	0,-1,8,9,11,6
	Vertices2	0,-1,13,12,15,16,14
	Vertices2	0,-1,11,9,15,12
	RET
prgt:
	ENTETE	lettret
	FFACE2	1,2,5,prt
	Vertices2	0,-1,1,2,5,7,4,3
	Vertices2	0,-1,5,6,8,7
	RET
prt:
	Vertices2	0,-1,1,3,4,7,5,2
	Vertices2	0,-1,5,7,8,6
	RET
prgu:
	ENTETE	lettreu
	FFACE2	1,9,10,pru
	Vertices2	0,-1,1,9,10,6,5
	Vertices2	0,-1,6,10,12,8
	Vertices2	0,-1,7,8,12,11,3
	RET
pru:
	Vertices2	0,-1,1,5,6,10,9
	Vertices2	0,-1,6,8,12,10
	Vertices2	0,-1,7,3,11,12,8
	RET
prgv:
	ENTETE	lettrev
	FFACE2	1,2,6,prv
	Vertices2	0,-1,1,2,6,3
	Vertices2	0,-1,6,2,8
	Vertices2	0,-1,5,6,8,7
	RET
prv:
	Vertices2	0,-1,1,3,6,2
	Vertices2	0,-1,6,8,2
	Vertices2	0,-1,5,7,8,6
	RET
prgw:
	ENTETE	lettrew
	FFACE2	1,2,9,prw
	Vertices2	0,-1,1,2,9,5
	Vertices2	0,-1,12,9,11
	Vertices2	0,-1,9,2,4,11
	Vertices2	0,-1,7,11,4,3
	RET
prw:
	Vertices2	0,-1,1,5,9,2
	Vertices2	0,-1,12,11,9
	Vertices2	0,-1,9,11,4,2
	Vertices2	0,-1,7,3,4,11
	RET
prgx:
	ENTETE	lettrex
	FFACE2	1,4,14,prx
	Vertices2	0,-1,1,4,14,9
	Vertices2	0,-1,4,3,11,16
	Vertices2	0,-1,8,16,15,7
	Vertices2	0,-1,13,14,8,5
	Vertices2	0,-1,14,4,16,8
	RET
prx:
	Vertices2	0,-1,1,9,14,4
	Vertices2	0,-1,4,16,11,3
	Vertices2	0,-1,8,7,15,16
	Vertices2	0,-1,13,5,8,14
	Vertices2	0,-1,14,8,16,4
	RET
prgy:
	ENTETE	lettrey
	FFACE2	1,9,8,pry
	Vertices2	0,-1,1,9,8,5
	Vertices2	0,-1,7,8,11,3
	Vertices2	0,-1,8,9,10,12,11
	RET
pry:
	Vertices2	0,-1,1,5,8,9
	Vertices2	0,-1,7,3,11,8
	Vertices2	0,-1,8,11,12,10,9
	RET
prgz:
	ENTETE	lettrez
	FFACE2	1,2,9,prz
	Vertices2	0,-1,1,2,9,11,5
	Vertices2	0,-1,9,10,12,11
	Vertices2	0,-1,10,4,8,7,12
	RET
prz:
	Vertices2	0,-1,1,5,11,9,2
	Vertices2	0,-1,9,11,12,10
	Vertices2	0,-1,10,12,7,8,4
	RET

	dc.b	'Finr'
fin:
