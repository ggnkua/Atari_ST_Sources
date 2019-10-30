;
; Macros d'aide Ö la programmation.
; Necessite la bibliotheque de macros MACROSYS.
;
; Auteur : Pierre-Jean Goulier.
;


charhex	macro			; Recherche d'un caractäre hexa.
				; charex D? (<> D0).
				; => D0 : caractäre hexa.
	move.b	\1,d0
	cmp.b	#9,d0
	bgt.s	ch1\@
	add.b	#'0',d0
	bra.s	ch2\@
ch1\@	sub.b	#10,d0
	add.b	#'A',d0
ch2\@	nop
	endm
	

printhex macro			; Affichage hexa d'un registre (<> D0).
				; printhex(.b/.w/.l) registre
				; La macro utilise les registres D0-D3.
	ifc	'b','\0'	
	move.b	\1,d0
	and	#$FF,d0
	move.b	d0,d1
	ror.b	#4,d0
	and	#$F,d0
	charhex d0
	cconout d0
	move.b	d1,d0
	and	#$F,d0
	charhex d0
	cconout d0
	endc
	ifc	'w','\0'
	move	\1,d0
	and	#$FFFF,d0
	move	#12,d2
	move	#3,d3
phex\@	ror	d2,d0
	move	d0,d1
	and	#$F,d0
	charhex	d0
	cconout	d0
	move	d1,d0
	dbra	d3,phex\@
	endc
	ifc	'l','\0'
	move.l	\1,d0
	move	#28,d2
	move	#7,d3
phex\@	ror.l	d2,d0
	move.l	d0,d1
	and	#$F,d0
	charhex	d0
	cconout	d0
	move.l	d1,d0
	dbra	d3,phex\@
	endc
	endm
	
printbin macro			; Affichage binaire d'un registre (<> D0).
				; printbin(.b/.w/.l) registre
				; La macro utilise les registes D0-D3.
	ifc	'b','\0'
	move.b	\1,d0
	move	#7,d1
	endc
	ifc	'w','\0'
	move	\1,d0
	move	#15,d1
	endc
	ifc	'l','\0'
	move.l	\1,d0
	move	#31,d1
	endc
	move.l	d0,d2
pbin2\@	move	#'0',d3
	btst	d1,d0
	beq	pbin1\@
	addq	#1,d3
pbin1\@	cconout	d3
	move.l	d2,d0
	dbra	d1,pbin2\@
	endm
	
printdec macro			; Affichage dÇcimal d'un registre (<> D0).
				; printdec(.b/.w/.l) registre
				; La macro utilise les registres D0-D4.
				; Nb maxi en .l : 655359999 ($270FFFFF)
	ifc	'b','\0'
	move.b	\1,d0
	move.l	#100,d1
	move.l	#2,d2
	endc
	ifc	'w','\0'
	move	\1,d0
	move.l	#10000,d1
	move.l	#4,d2
	endc
	ifc	'l','\0'
	move.l	\1,d0
	move.l	#10000,d1
	divu	d1,d0
	move.l	d0,d3
	clr.l	d0
	move	d3,d0
	move.l	#4,d2
	moveq	#1,d4
	endc
	
pdec3\@	divs	d1,d0
	beq	pdec1\@
	add	#'0',d0
	move.l	d0,-(sp)
	cconout d0
	move.l	(sp)+,d0
	sub	#'0',d0
	bra	pdec2\@
pdec1\@	move.l	d0,-(sp)
	cconout #'0'
	move.l	(sp)+,d0
pdec2\@	swap	d0
	ext.l	d0
	divu	#10,d1
	dbra	d2,pdec3\@
	
	ifc	'l','\0'
	tst	d4
	beq	pdec4\@
	swap	d3
	move	d3,d0
	move.l	#1000,d1
	move	#3,d2
	subq	#1,d4
	bra	pdec3\@
pdec4\@	nop
	endc
	endm
	
inc	macro			; IncrÇmentation d'un registre
				; Registre de donnÇe, d'adresse ou
				; adresse absolue.
				; inc(.b/.w/.l)
	ifc	'','\1'
	fail	Il manque un paramätre !!
	mexit
	endc
	addq.\0	#1,\1
	endm
	
dec	macro			; DÇcrÇmentation d'un registre
				; Registre de donnÇe, d'adresse ou
				; adresse absolue.
				; dec(.b/.w/.l)
	ifc	'','\1'
	fail	Il manque un paramätre !!
	mexit
	endc
	subq.\0	#1,\1
	endm

init_prg	macro		; Initialisation d'un programme.
				; Calcul de son besoin de mÇmoire,
				; restitution du reste, prÇparation
				; de la pile...
				; init_prg pile
				; => D0 : Si <> 0, tout va mal !
				; => D1 : Taille du prg.
	movea.l	4(sp),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	addi.l	#$100,d0
	addi.l	\1,d0
	move.l	d0,d1
	add.l	a5,d1
	andi.l	#-2,d1
	movea.l	d1,sp
	mshrink	a5,d0
	endm
	
init_prgres	macro		; Initialisation d'un programme
				; rÇsident.
				; Pas de pile, ni de Mshrink !
				; => D0 : Taille du prg Ö sauver.
	movea.l	4(sp),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	addi.l	#$100,d0
	endm
	