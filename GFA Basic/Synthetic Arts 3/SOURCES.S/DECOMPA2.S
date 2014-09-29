*-------------------------------------------------------------------------*
*	SYNTHETIC ARTS 2			- CYBERNETICS 1992 -	  *	
*									  *
*   Affiche un tableau de parametrage stocke en 2 plans a l'ecran	  * 
*-------------------------------------------------------------------------*

	move.l	4(sp),a0			* Adr tableau
	move.l	8(sp),a1			* Adr ecran

	moveq.l		#0,d7
	moveq.l		#27,d0

loop:	rept	20
	move.l	(a0)+,(a1)+
	move.l	d7,(a1)+
	endr

	dbra.w	d0,loop

	rts