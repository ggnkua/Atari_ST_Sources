;########################################################################	
;#----------------------------------------------------------------------#
;#						#
;#   MACROS D'INITIALISATION D'UN FALCON 030  (C)opyright GASTON 1995	#
;#   """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""	#
;#----------------------------------------------------------------------#
;########################################################################	
;#----------------------------------------------------------------------#
;#  SUPER		Passe en mode Superviseur		#
;#  USER		Passe en mode Utilisateur		#
;#----------------------------------------------------------------------#
;########################################################################	
;#----------------------------------------------------------------------#
;#  ADR_ECRAN	< adr_pas_divisible,adr_divisible >		#
;#		Renvoie une adresse d'‚cran divisible par 256	#
;#----------------------------------------------------------------------#
;#  GET_SCREEN	Sauvegarde de l'‚cran actuel (r‚solution et @)	#
;#  PUT_SCREEN	Restauration de l'‚cran initial (r‚solution et	#
;#		adresse)				#
;#  SET_SCREEN	< adr_logique,adr_physique,valeur_modecode >	#
;#		Positionnement des caract‚ristiques d'un nouvel	#
;#		‚cran (adresse et r‚solution)		#
;#  SET_SCREEN2	< valeur_modecode,adr_physique >		#
;#		Positionnement des caract‚ristiques d'un nouvel	#
;#		‚cran (adresse et r‚solution) sans effacage	#
;#----------------------------------------------------------------------#
;#  GET_PHYSBASE	Sauvegarde de l'adresse physique de l'‚cran	#
;#		actuel				#
;#  PUT_PHYSBASE	Restauration de l'adresse physique de l'‚cran	#
;#		initial				#
;#  SET_PHYSBASE	< adr_physique >			#
;#		Positionnement de l'adresse physique de l'‚cran	#
;#  CLR_OLDPHYSBASE	Effa‡age de l'ancien ‚cran physique		#
;#----------------------------------------------------------------------#
;#  GET_LOGBASE	Sauvegarde de l'adresse logique de l'‚cran	#
;#		actuel				#
;#  PUT_LOGBASE	Restauration de l'adresse logique de l'‚cran	#
;#		initial				#
;#  SET_LOGBASE	< adr_logique >			#
;#		Positionnement de l'adresse logique de l'‚cran	#
;#  CLR_OLDLOGBASE	Effa‡age de l'ancien ‚cran logique		#
;#----------------------------------------------------------------------#
;#  CLRSCR		< adresse,nombre_mots_longs >		#
;#		Efface la zone m‚moire dont on donne l'adresse	#
;#		et la taille			#
;#----------------------------------------------------------------------#
;#  GET_MODECODE	Sauvegarde du modecode actuel		#
;#  PUT_MODECODE	Restauration du modecode initial		#
;#  SET_MODECODE	< valeur_modecode >			#
;#		Mise en place d'une nouvelle r‚solution	#
;#----------------------------------------------------------------------#
;########################################################################	
;#----------------------------------------------------------------------#
;#  GET_COLORS	Sauvegarde de la palette de couleurs	#
;#  PUT_COLORS	Restauration de la palette de couleurs	#
;#  SET_COLORS16	< adr_palette_16 >			#
;#		Mise en place d'une nouvelle palette de 16	#
;#		couleurs				#
;#  SET_COLORS256	< adr_palette_256 >			#
;#		Mise en place d'une nouvelle palette de 256	#
;#		couleurs				#
;#----------------------------------------------------------------------#
;########################################################################	
;#----------------------------------------------------------------------#
;#  GET_VIDEL	Sauvegarde des parametres du Videl		#
;#  PUT_VIDEL	Restauration des parametres du Videl	#
;#  SET_VIDEL	< adr_params_videl >			#
;#		Mise en place de nouveaux parametres	#
;#----------------------------------------------------------------------#
;########################################################################	
;#----------------------------------------------------------------------#
;#  GET_MFP		Sauvegarde des vecteurs/registres MFP	#
;#  PUT_MFP		Restauration des vecteurs/registrers MFP	#
;#----------------------------------------------------------------------#
;#  GET_VBL		Sauvegarde de l'interruption VBL		#
;#  PUT_VBL		Restauration de l'interruption VBL		#
;#  SET_VBL		< adresse_routine >			#
;#		Mise en place d'une nouvelle routine VBL	#
;#  INI_VBL		Mise en place d'une routine VBL vide	#
;#----------------------------------------------------------------------#
;########################################################################	
;#----------------------------------------------------------------------#
;#  GET_CACR	Sauvegarde du registre de controle du cache	#
;#  PUT_CACR	Restauration du registre de controle du cache	#
;#  SET_CACR	S‚lection du mode de fonctionnement du cache	#
;#----------------------------------------------------------------------#
;########################################################################	
;#----------------------------------------------------------------------#
;#  MOUSE_ON	Autorise l'utilisation de la souris		#
;#  MOUSE_OFF	Interdit l'utilisation de la souris		#
;#----------------------------------------------------------------------#
;########################################################################	
;#----------------------------------------------------------------------#
;#  EMISSION_AU_DSP	Attend que le DSP soit prˆt … recevoir ce que	#
;#		l'on veut lui envoyer			#
;#  EMET_L		< mot_long >			#
;#		Envoie un mot long au DSP par le port Host	#
;#  EMET_W		< mot >				#
;#		Envoie un mot au DSP par le port Host	#
;#  RECEPTION_DU_DSP	Attend que le DSP nous ait envoy‚ une donn‚e	#
;#  RECOIT_L	< mot_long >			#
;#		Re‡oie un mot long du DSP par le port Host	#
;#  RECOIT_W	< mot >				#
;#		Re‡oie un mot du DSP par le port Host	#
;#  CHARGE_P56	< adresse_executable_dsp,taille >			#
;#		Charge dans le DSP une programme au format	#
;#		binaire (P56)			#
;#----------------------------------------------------------------------#
;########################################################################	
;#----------------------------------------------------------------------#
;#  FLUSH_KEYBOARD	Vide le tampon clavier			#
;#----------------------------------------------------------------------#
;#  PTERM		Termine un programme			#
;#----------------------------------------------------------------------#
;########################################################################	
	include	init.cte



;########################################################################
;#----------------------------------------------------------------------#
;#  Passage en mode Superviseur/Utilisateur si on n'y est pas d‚j….	#
;#----------------------------------------------------------------------#
;########################################################################

SUPER:	MACRO
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,old_ssp
	section bss
old_ssp:	ds.l	1
	section text
	ENDM

USER:	MACRO
	move.l	old_ssp,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM



;########################################################################	
;#----------------------------------------------------------------------#
;# Renvoie une adresse d'‚cran divisible par 256.		#
;#----------------------------------------------------------------------#
;########################################################################	

ADR_ECRAN:	MACRO	ADR_PAS_DIVISIBLE,ADR_DIVISIBLE
	move.l	\1,d0
	clr.b	d0
	add.l	#256,d0
	move.l	d0,\2
	ENDM



;########################################################################
;#----------------------------------------------------------------------#
;#  Sauvegarde et restitution des caract‚ristiques de l'‚cran initial.	#
;#----------------------------------------------------------------------#
;########################################################################

GET_SCREEN:	MACRO
	GET_PHYSBASE
	GET_LOGBASE
	GET_MODECODE
	ENDM
		
PUT_SCREEN:	MACRO
	PUT_PHYSBASE
	PUT_LOGBASE
	PUT_MODECODE
	WAIT_SYNC
	ENDM

SET_SCREEN:	MACRO	ADR_LOGIQUE,ADR_PHYSIQUE,VALEUR_MODECODE
	SET_LOGBASE	 \1
	SET_PHYSBASE \2
	SET_MODECODE \3
	ENDM

SET_SCREEN2:MACRO	VALEUR_MODECODE,ADR_ECRAN
	SET_PHYSBASE \2
	SET_MODECODE \1
	ENDM

WAIT_SYNC:	MACRO
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	ENDM



;########################################################################
;#----------------------------------------------------------------------#
;#  Sauvegarde et restitution de l'adresse physique de l'‚cran. 	#
;#----------------------------------------------------------------------#
;########################################################################

GET_PHYSBASE: MACRO
	clr.b	old_physbase
	move.b	$ffff8201.w,old_physbase+1
	move.b	$ffff8203.w,old_physbase+2
	move.b	$ffff820d.w,old_physbase+3
	section bss
old_physbase:ds.l	1
	section text
	ENDM
	
PUT_PHYSBASE: MACRO
	CLR_OLDPHYSBASE
	move.b	old_physbase+1,$ffff8201.w
	move.b	old_physbase+2,$ffff8203.w
	move.b	old_physbase+3,$ffff820d.w
	ENDM

SET_PHYSBASE: MACRO	ADR_PHYSIQUE
	move.l	d0,-(sp)
	move.l	\1,d0
	move.b	d0,$ffff820d.w
	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.l	#8,d0
	move.b	d0,$ffff8201.w
	move.l	(sp)+,d0
	ENDM

CLR_OLDPHYSBASE: MACRO
	move.l	old_physbase,a0
	move.w	#32000/4-1,d0
clrphy:	clr.l	(a0)+
	dbra	d0,clrphy
	ENDM


	
;########################################################################
;#----------------------------------------------------------------------#
;#  Sauvegarde et restitution de l'adresse logique de l'‚cran. 	#
;#----------------------------------------------------------------------#
;########################################################################

GET_LOGBASE: MACRO
	move.l	$44e.w,old_logbase
	section bss
old_logbase:ds.l	1
	section text
	ENDM

PUT_LOGBASE: MACRO
	CLR_OLDLOGBASE
	move.l	old_logbase,$44e.w
	ENDM

SET_LOGBASE: MACRO	ADR_LOGIQUE
	move.l	\1,$44e.w
	ENDM

CLR_OLDLOGBASE: MACRO
	move.l	old_logbase,a0
	move.w	#32000/4-1,d0
clrlog:	clr.l	(a0)+
	dbra	d0,clrlog
	ENDM



;########################################################################
;#----------------------------------------------------------------------#
;#  Effacement d'une zone m‚moire.				#
;#----------------------------------------------------------------------#
;########################################################################

CLRSCR:	MACRO	ADRESSE,NOMBRE_MOTS_LONGS
	move.l	\1,a0
	move.l	\2,d0
clr\@:	clr.l	(a0)+
	subq.l	#1,d0
	bne.s	clr\@
	ENDM



;########################################################################
;#----------------------------------------------------------------------#
;#  Sauvegarde et restitution du modecode. 			#
;#----------------------------------------------------------------------#
;########################################################################

GET_MODECODE: MACRO
	move.w	#-1,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp
	move.w	d0,old_modecode
	section bss
old_modecode:ds.w	1
	section text
	ENDM
	
PUT_MODECODE: MACRO
	move.w	old_modecode,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp
	ENDM

SET_MODECODE: MACRO	VALEUR_MODECODE
	move.w	\1,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp
	ENDM



;########################################################################
;#----------------------------------------------------------------------#
;#  Sauvegarde et restitution de la palette. 			#
;#----------------------------------------------------------------------#
;########################################################################

GET_COLORS:	MACRO
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,old_palette16
	lea	$ffff9800.w,a0
	lea	old_palette256,a1
	move.w	#256-1,d0
get_col\@:	move.l	(a0)+,(a1)+
	dbra	d0,get_col\@
	section bss
old_palette16:  ds.w	16
old_palette256: ds.l	256
	section text
	ENDM
	
PUT_COLORS:	MACRO
	movem.l	old_palette16,d0-d7
	movem.l	d0-d7,$ffff8240.w
	lea	old_palette256,a0
	lea	$ffff9804.w,a1
	move.w	#256-1,d0
put_col\@:	move.l	(a0)+,(a1)+
	dbra	d0,put_col\@
	ENDM
	
SET_COLORS16: MACRO	ADRESSE_PALETTE
	movem.l	\1,d0-d7
	movem.l	d0-d7,$ffff8240.w
	ENDM

SET_COLORS256: MACRO	ADRESSE_PALETTE
	lea	\1,a0
	lea	$ffff9800.w,a1
	move.w	#256-1,d0
set_col\@:	move.l	(a0)+,(a1)+
	dbra	d0,set_col\@
	ENDM



;########################################################################	
;#----------------------------------------------------------------------#
;#  Sauvegarde et restitution des registres du Videl.		#
;#----------------------------------------------------------------------#
;########################################################################	

GET_VIDEL:	MACRO
	lea	old_videl,a0
	move.l	$ffff820e.w,(a0)+
	movem.l	$ffff8282.w,d0-d3
	movem.l	d0-d3,(a0)
	lea	16(a0),a0
	movem.l	$ffff82a2.w,d0-d3
	movem.l	d0-d3,(a0)
	lea	16(a0),a0
	move.l	$ffff82c0.w,(a0)+
	move.w	$ffff8266.w,(a0)+
	section bss
old_videl:  ds.w	16
	section text
	ENDM
	
PUT_VIDEL:	MACRO
	lea	old_videl,a0
	move.l	(a0)+,$ffff820e.w
	movem.l	(a0)+,d0-d3
	movem.l	d0-d3,$ffff8282.w
	movem.l	(a0)+,d0-d3
	movem.l	d0-d3,$ffff82a2.w
	move.l	(a0)+,$ffff82c0.w
	move.w	(a0)+,$ffff8266.w
	ENDM

SET_VIDEL:	MACRO
	lea	\1,a0
	move.l	(a0)+,$ffff820e.w
	movem.l	(a0)+,d0-d3
	movem.l	d0-d3,$ffff8282.w
	movem.l	(a0)+,d0-d3
	movem.l	d0-d3,$ffff82a2.w
	move.l	(a0)+,$ffff82c0.w
	move.w	(a0)+,$ffff8266.w
	ENDM
	
	
	
;########################################################################	
;#----------------------------------------------------------------------#
;#  Sauvegarde et restitution des vecteurs et registres MFP.	#
;#----------------------------------------------------------------------#
;########################################################################	

GET_MFP:	MACRO
	move.w	sr,-(sp)
	move.w	#$2700,sr
	lea	$fffffa01.w,a0
	lea	old_mfp,a1
	moveq.w	#16,d0
get_m\@:	move.b	(a0),(a1)+
	addq.l	#2,a0
	dbra	d0,get_m\@
	movem.l	$58.w,d0-d7
	movem.l	d0-d7,old_vecteurs	
	movem.l	$100.w,d0-d7
	movem.l	d0-d7,old_vecteurs+32
	movem.l	$120.w,d0-d7
	movem.l	d0-d7,old_vecteurs+64
	GET_VBL
	move.w	(sp)+,sr	
	section bss
old_mfp:	  ds.w	24/2
old_vecteurs: ds.l	24
	section text
	ENDM

PUT_MFP:	MACRO
	move.w	sr,-(sp)
	move.w	#$2700,sr
	lea	old_mfp,a0
	lea	$fffffa01.w,a1
	move.w	#16,d0
put_m\@:	move.b	(a0)+,(a1)
	addq.l	#2,a1
	dbra	d0,put_m\@
	movem.l	old_vecteurs,d0-d7
	movem.l	d0-d7,$58.w
	movem.l	old_vecteurs+32,d0-d7
	movem.l	d0-d7,$100.w
	movem.l	old_vecteurs+64,d0-d7
	movem.l	d0-d7,$120.w
	PUT_VBL
	move.w	(sp)+,sr	
	ENDM



;########################################################################	
;#----------------------------------------------------------------------#
;#  Gestion de la routine VBL $70.w.			#
;#----------------------------------------------------------------------#
;########################################################################	

GET_VBL:	MACRO
	move.l	$70.w,old_vbl
	section bss
old_vbl:	ds.l	1
	section text
	ENDM
	
PUT_VBL:	MACRO
	move.l	old_vbl,$70.w
	ENDM
	
INI_VBL:	MACRO
	move.l	#init_vbl,$70.w
	section data
init_vbl:	addq.l	#1,$466.w
	rte
	section text
	ENDM

SET_VBL:	MACRO	ADRESSE_ROUTINE
	move.l	\1,$70.w
	ENDM



;########################################################################
;#----------------------------------------------------------------------#
;#  Sauvegarde, restitution et modification de l'‚tat des caches.	#
;#----------------------------------------------------------------------#
;########################################################################

GET_CACR:	MACRO
	movec.l	cacr,d0
	move.l	d0,old_cacr
	section bss
old_cacr:	ds.l	1
	section text
	ENDM
	
PUT_CACR:	MACRO
	move.l	old_cacr,d0
	movec.l	d0,cacr
	ENDM

SET_CACR:	MACRO	VALEUR_CACR
	move.l	\1,d0
	movec.l	d0,cacr
	ENDM



;########################################################################
;#----------------------------------------------------------------------#
;#  Activation/D‚sactivation de la souris. 			#
;#----------------------------------------------------------------------#
;########################################################################

MOUSE_OFF:	MACRO
off\@:	btst	#1,$fffffc00.w
	beq.s	off\@
	move.b	#$12,$fffffc02.w
	ENDM

MOUSE_ON:	MACRO
on\@:	btst	#1,$fffffc00.w
	beq.s	on\@
	move.b	#$8,$fffffc02.w
	ENDM



;########################################################################	
;#----------------------------------------------------------------------#
;#  Gestion des programmes utilisant le DSP.			#
;#----------------------------------------------------------------------#
;########################################################################	

EMISSION_AU_DSP: MACRO
	btst.b	#1,$ffffa202.w
	beq.s	*-6
	ENDM
	
EMET_L:	MACRO
	move.l	\1,$ffffa204.w
	ENDM

EMET_W:	MACRO
	move.w	\1,$ffffa206.w
	ENDM
	
RECEPTION_DU_DSP: MACRO
	btst.b	#0,$ffffa202.w
	beq.s	*-6
	ENDM

RECOIT_L:	MACRO
	move.l	$ffffa204.w,\1
	ENDM

RECOIT_W:	MACRO
	move.w	$ffffa206.w,\1
	ENDM

CHARGE_P56:	MACRO 	ADRESSE_EXECUTABLE_DSP,TAILLE
	move.w	#3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#109,-(sp)
	trap	#14
	lea	12(sp),sp
	ENDM



;########################################################################	
;#----------------------------------------------------------------------#
;#  Vidage du tampon clavier.				#
;#----------------------------------------------------------------------#
;########################################################################	

FLUSH_KEYBOARD: MACRO
vide_buffer\@:
	btst	#5,$fffffc00.w
	beq.s	pas_d_erreur\@
	tst.b	$fffffc02.w
	bra.s	vide_buffer\@
pas_d_erreur\@:
	btst	#0,$fffffc00.w
	beq.s	c_vide\@
	tst.b	$fffffc02.w
	bra.s	vide_buffer\@
c_vide\@:	
	ENDM



;########################################################################	
;#----------------------------------------------------------------------#
;#  Fin du programme. 					#
;#----------------------------------------------------------------------#
;########################################################################	

PTERM:	MACRO
	clr.w	(sp)
	trap	#1
	ENDM



;########################################################################	
;########################################################################	
;########################################################################	
;########################################################################	
;########################################################################	



;########################################################################	
;#----------------------------------------------------------------------#
;#						#
;#  ROUTINES D'INITIALISATION D'UN FALCON 030  (C)opyright GASTON 1995	#
;#  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""	#
;#----------------------------------------------------------------------#
;########################################################################	
;#----------------------------------------------------------------------#
;#  SAUVEGARDE_CONTEXTE	Sauvegarde le contexte d'origine		#
;#  RESTAURE_CONTEXTE	Remet en place le contexte d'origine	#
;#  CHARGE_PROG_DSP	Charge un programme dans le DSP		#
;#  NOUVEAU_CONTEXTE	Installe un nouveau contexte pour la d‚mo	#
;#----------------------------------------------------------------------#
;#  VSYNC		Attente de la VBL suivante		#
;#----------------------------------------------------------------------#
;########################################################################	



;#----------------------------------------------------------------------#	
;# Saute le code des routines qui suivent ...			#
;#----------------------------------------------------------------------#	
	bra	FIN_INIT_ROUTS
	
;#----------------------------------------------------------------------#
;#  Attente de la VBL suivante.				#
;#----------------------------------------------------------------------#
VSYNC:	move.l	$466.w,d0
	cmp.l	$466.w,d0
	beq.s	*-4
	RTS

;#----------------------------------------------------------------------#
;#  Echange ecran logique/physique.				#
;#----------------------------------------------------------------------#
FLIP_SCREEN:
	move.l	adr_ecran1,d0
	move.l	adr_ecran2,adr_ecran1
	move.l	d0,adr_ecran2
	RTS

;#----------------------------------------------------------------------#	
;# Voici la fin des routines d'initialisation ...		#
;#----------------------------------------------------------------------#	
FIN_INIT_ROUTS:



;########################################################################	
;########################################################################	
;########################################################################	
;########################################################################	
;########################################################################	
