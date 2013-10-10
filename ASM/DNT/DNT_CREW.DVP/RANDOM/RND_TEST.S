; Un exemple d'utilisation du Random. On demande d'abord un random
; optimis‚ (a=1, cf article dans le DNT-Paper 4) avec __RND_TYPE equ 0
; puis on initialise la routine (InitRandom). Il ne reste plus qu'…
; appeler quand on le veut la routine Random !.
;
; (C)oderight Nullos/DNT-Crew 1992.
;
__RND_TYPE	equ	0
	move.l	#0,d0		;Initialisation automatique
	bsr	InitRandom		;(essayez une autre valeur!)
	;...       votre programme    ...;
	bsr	Random		;
	;...       votre programme    ...;


	clr.w	(sp)
	trap	#1
	
	include	random.s		;inclure le fichier RANDOM.S
