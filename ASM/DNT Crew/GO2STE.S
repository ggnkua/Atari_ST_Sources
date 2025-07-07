;Ce mini-programme permet de passer votre Falcon en mode compatible
;STE hard.
;Il ne vous reste plus qu'… passer dans une r‚solution compatible
;STE pour voir vos programmes r‚calcitrants marcher un peu mieux.
;Evidemment, mieux vaut utiliser le VCB 1.4 pour faire marcher
;vos jeux, hein !!.
;
;(C)oderight Nullos//DNT-Crew 1993
	include	tos_030.s
	
	clr.l	-(sp)
	Gemdos	Super
	move.b	#$45,$ffff8007.w
	move.l	d0,-(sp)
	Gemdos	Super
	Gemdos	Pterm0
