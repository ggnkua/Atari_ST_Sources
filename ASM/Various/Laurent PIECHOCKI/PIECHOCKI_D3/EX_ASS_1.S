	
*** ILLUSTRATION DES OPERATIONS SUR LA RAM VIDEO ET L'ECRAN LOGIQUE ***
	

	clr.l	-(sp)		;super
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,ssp
	
	* ECRIRE sur PHYS puis LOG et poser LOG sur PHYS *
	
	move.l	#ecran+256,d0	;adresse LOG
	and.l	#$ffffff00,d0	;divisible par 256
	move.l	d0,a0		;a0=LOG
	move.l	$44e,a5		;a5=PHYS

	
	
	*** On ecrit sur le PHYS ***
	
	move.l	#7999,d0		;clear PHYS SCREEN
	moveq.l	#-1,d1
	move.l	a5,a6	
clear_scr:
	move.l	d1,(a6)+
	dbf	d0,clear_scr

	move	#7,-(sp)		;TOUCHE
	trap	#1
	addq.l	#2,sp


	*** On ecrit sur le LOG ***
		
	move.l	#7999,d0		;Write of LOG
	moveq.l	#0,d1
	move.l	a0,a6
cr:
	move.l	d1,(a6)+
	dbf	d0,cr

	move	#7,-(sp)		;TOUCHE
	trap	#1
	addq.l	#2,sp
	
	
	*** On pose LOG sur PHYS ***
		
	move.l	a0,d5		;a0= LOG
	lsr.l	#8,d5		;MMU --> ECHANGE
	move.b	d5,$ff8203
	lsr.l	#8,d5
	move.b	d5,$ff8201

	move	#7,-(sp)		;TOUCHE
	trap	#1
	addq.l	#2,sp
	
	
	move.l	ssp,-(sp)		;USER
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
		
	clr.l	-(sp)		;PTERM
	trap	#1
	
	
	SECTION    BSS

ecran	ds.l	32000		;PHYS SCREEN
ssp	ds.l	1
log	ds.l	1

	END
	
		