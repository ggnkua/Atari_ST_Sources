local_raz	MACRO
__localOffset	SET	0
__localSize	SET	0
		ENDM
;----------------------------------------------------------
local		MACRO
__size		set	2
		IFC	"\0","w" 
__size		set	2
		ENDC
		IFC	"\0","W" 
__size		set	2
		ENDC
		IFC	"\0","l" 
__size		set	4
		ENDC
		IFC	"\0","L" 
__size		set	4
		ENDC
				
		IFEQ	\#-2
__localOffset	SET	__localOffset-\2*__size
__localSize	SET	__localSize+\2*__size
		ELSE
__localOffset	SET	__localOffset-__size
__localSize	SET	__localSize+__size
		ENDC
\1		SET	__localOffset
		ENDM

;----------------------------------------------------------
local_reserve	MACRO
		IFNE	(__localSize)
		IFNE	\#
		link	\1,#-__localSize
		ELSE
		link	a6,#-__localSize
		ENDC
		ENDC
		ENDM
;----------------------------------------------------------
local_free	MACRO
		IFNE	(__localSize)
		IFNE	\#
		unlk	\1
		ELSE
		unlk	a6
		ENDC
		ENDC
		ENDM
;----------------------------------------------------------
		ifne	0
d'abord la doc:
---------------

local_raz		init des variables utilis‚es, ne pas oublier


local[.w.l] VAR[,n]	precise une variable locale la taille (.w .l) 
			est optionnelle le nombre de valeurs r‚serv‚es est 
			optionnelle			
EXEMPLES:
local.l .TOTO		variable .TOTO longue
local	 H		variable H word 
local 	.TITI,12	variable .TITI de 12 word
local.l TATA,10	variable TATA de 10 long

	
local_reserve [Ax]	reservation de l'espace sur la pile le registre par
			defaut est a6 mais on peut en choisir un autre
EXEMPLES:
local_reserve
local_reserve a5



local_free [Ax]	libere l'espace sur la pile. Attention a mettre le meme 
			registre que lors de la reservation
EXEMPLES:
local_free
local_free a5



;exemple d'utilisaton de ces macros.....
START
	local_raz		;obligatoire
	local.l	.TOTO		
	local_reserve	a5	;r‚servation

	move	d0,.TOTO(a5)	;utilise .la variable .TOTO
	local_free	a5	;libere l'espace
	
	endc