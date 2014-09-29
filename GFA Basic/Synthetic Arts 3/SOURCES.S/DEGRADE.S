	output	e:\code\synthy.art\curent\fichiers.inl\degrade.inl

*-------------------------------------------------------------------------*
*	SYNTHETIC ARTS			                  V 2.4	          *
*									  *
*	Routine de calcul pour l'autodegrade	(version optimisee)	  *  
*-------------------------------------------------------------------------*

	move.l	4(sp),a0	* Adresse liste
	move.w	8(sp),d1	* Nombre de points
	move.w	10(sp),d2	* Coordonnees du point courant (x & y)  X
	move.w	12(sp),d3	*					Y
	move.l	14(sp),a1	* Adresse table des carres dans A1
	move.l	a1,a2		* Adresse table dans A2
	add.w	d2,d2
	add.w	d2,d2
	add.w	d3,d3
	add.w	d3,d3
	sub.w	d2,a1		* Tient compte abscisse du point courant
	sub.w	d3,a2		* Tient compte ordonnee du point courant
	move.l	#200000,d0	* Valeur de depart
	
loop:	move.w	(a0)+,d4	
	move.w	(a0)+,d5	
	move.l	(a1,d4.w),d6
	add.l	(a2,d5.w),d6
	cmp.l	d6,d0
	blt.s	low
	move.l	d6,d0	
low:	dbra.w	d1,loop

	rts

