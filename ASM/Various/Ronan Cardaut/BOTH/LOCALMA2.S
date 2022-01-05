	ifne	0	
	
d'abord la doc:
---------------

	l_clear			init des variables utilis‚es, ne pas oublier

TOTO	rs.w	1
BIBI	rs.b	100		;les variables locales

	l_reserve		;reserve la place ds la pile, frame ptr par d‚faut
	l_reserve	a5	;le frame ptr est a5
	

	move	#1,TOTO(a6)	;accede aux variables
	move	#1,TOTO(a5)	;accede aux variables


	l_free			;libere la RAM
		
	
	endc
	



l_clear		MACRO
		rsreset
		
		ENDM


l_reserve	MACRO
__localSize	rs	0
		
		IFNE	(__localSize)
		
		IFNE	\#
		link	\1,#-__localSize
		lea	-__localSize(\1),\1
		ELSE
		link	a6,#-__localSize
		lea	-__localSize(a6),a6
		ENDC
		
		ENDC
		
		ENDM
		






;----------------------------------------------------------
;----------------------------------------------------------
l_free		MACRO
		IFNE	(__localSize)
		IFNE	\#
		lea	__localSize(\1),\1
		unlk	\1
		ELSE
		lea	__localSize(a6),a6
		unlk	a6
		ENDC
		ENDC
		ENDM
;----------------------------------------------------------
	