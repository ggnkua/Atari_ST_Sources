*-------------------------------------------------------------------------*
*	SYNTHETIC ARTS 2          TEST MEGA STE        CYBERNETICS 1992   *
*-------------------------------------------------------------------------*

	output	"e:\code\synthy.art\curent\fichiers.inl\testmega.inl"

	opt	o+,p+,a+
	
	move.l	sp,a6		* ON SAUVE LA PILE

	clr.l	-(sp)		* SUPERVISEUR
	move.w	#32,-(sp)
	trap	#1			
	addq.l	#6,sp
	
	moveq.l	#0,d2		* FLAG A ZERO 

	move.l	$8.w,d1		* REDIRECTIONNE LE VECTEUR BOMBE
	lea	newbomb(pc),a0
	move.l	a0,$8.w
	
	move.b	$ffff8e21.w,d2	* GET SYNCHRO
	or.l	#$ffff0000,d2	* FLAG A TRUE (Si mega ste)

newbomb:

	move.l	d1,$8.w		* RESTORE VECTEUR BOMBE
	
	move.l	d0,-(sp)	* UTILISATEUR
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	d2,d0		* RESULTAT

	move.l	a6,sp		* RESTAURE LA PILE
	
	rts			* FIN

	