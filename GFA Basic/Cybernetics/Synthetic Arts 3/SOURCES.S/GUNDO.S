*-------------------------------------------------------------------------*
*	SYNTHETIC ARTS 2		  	- CYBERNETICS 1992 -      *
*									  *
*          Echange le contenu de deux ecrans (gestion undo)		  *
*-------------------------------------------------------------------------*

	move.L	4(sp),a0
	move.l	8(sp),a1
	move.w	12(sp),d0

loop:
	rept	40
	move.l	(a1),d1
	move.l	(a0),(a1)+
	move.l	d1,(a0)+
	endr
	
	dbra.w	d0,loop

	rts

	
		