	
*** ILLUSTRATION DES OPERATIONS SUR LA RAM VIDEO ET L'ECRAN LOGIQUE ***
	

           move.l     a7,a5		;Initialise le TOS 
           lea        pile,a7
           move.l     4(a5),a5     
           move.l     $c(a5),d0    
           add.l      $14(a5),d0
           add.l      $1c(a5),d0
           add.l      #$100,d0
           move.l     d0,-(sp)
           move.l     a5,-(sp)
           move       #0,-(sp)
           move       #$4a,-(sp)		;SETBLOCK
           trap       #1
           add.l      #12,sp


	clr.l	-(sp)		;super
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,ssp
	
	
	* ECRIRE sur PHYS puis LOG et poser LOG sur PHYS *
	
	move.l	#INTRO,-(sp)	;Texte sur PHYS
	move.w	#$09,-(sp)
	trap	#1
	addq.l	#6,sp

	move	#7,-(sp)		;TOUCHE
	trap	#1
	addq.l	#2,sp
	
	move.l	#ecran+256,d0	;adresse LOG
	and.l	#$ffffff00,d0	;divisible par 256
	move.l	d0,a0		;a0=LOG
	move.l	$44e,a5		;a5=PHYS

	
	
	*** On ecrit sur le PHYS ***
	

		
	move.l	#7999,d0		;Write of PHYS
	moveq.l	#-1,d1
	move.l	a5,a6
cr:
	move.l	d1,(a6)+
	dbf	d0,cr


	move.l	#TEXTE,-(sp)	;Texte sur PHYS
	move.w	#$09,-(sp)
	trap	#1
	addq.l	#6,sp
	
	move	#7,-(sp)		;TOUCHE
	trap	#1
	addq.l	#2,sp


	*** On ecrit sur le LOG ***


		
	move.l	#7999,d0		;Write of LOG
	moveq.l	#-1,d1
	move.l	a0,a6
acr:
	move.l	d1,(a6)+
	dbf	d0,acr
	
	move.l	a0,d5		;a0= LOG
	lsr.l	#8,d5		;MMU -->  PHYS devient LOG
	move.b	d5,$ff8203		;on travaille sur LOG
	lsr.l	#8,d5		;(On change le PHYS sous LOG)
	move.b	d5,$ff8201		;¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹
	
	
	move	#7,-(sp)		;TOUCHE
	trap	#1
	addq.l	#2,sp
	
	
	
	*** On pose LOG sur PHYS ***
		
	move.l	a5,d5		;a5= PHYS
	lsr.l	#8,d5		;MMU  --> LOG devient PHYS
	move.b	d5,$ff8203		;on d‚pose le LOG sur PHYS
	lsr.l	#8,d5		;(le PHYS chang‚ revient)
	move.b	d5,$ff8201		;¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹

	move	#7,-(sp)		;TOUCHE
	trap	#1
	addq.l	#2,sp
	
	
	move.l	ssp,-(sp)		;USER
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
		
	clr.w	-(sp)		;PTERM
	trap	#1
	
	
	SECTION    DATA
	
TEXTE	DC.B	27,'Y',32,32,' TEXTE ‚crit sur l',39,'‚cran LOGIQUE et pos‚ sur',10,13
	DC.B	' l',39,'‚cran PHYSIQUE  ... blablabla :',10,13
	
	REPT	22
	DC.B	'textetextetextetextetextetextetextetextetexte',10,13
	ENDR
	
	DC.B       0

INTRO	DC.B	27,'E','Compare l',39,'affichage normal avec celui'
	DC.B	' LOG sur PHYS  (L-P, 1/89)',0
	
		
	SECTION    BSS
		
	ds.b	500		;USP
pile	ds.b	1

ecran	ds.b	32256		;LOG SCREEN (1*32000+256)

ssp	ds.l	1


	END
	
		