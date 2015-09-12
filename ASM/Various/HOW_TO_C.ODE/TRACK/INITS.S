; *********************************************************************** ;
; *********           Routines de base pour demos...           ********** ;
; *********************************************************************** ;
; * - Initialisations et programme principal par DEMOMAKER/ABSTRACT.    * ;
; * - Routine DSP par CHAOS/SANITY.                                     * ;
; * - Adaptation effets ProTracker 2.1A par LEADER ONE.                 * ;
; *********************************************************************** ;

SndTrack	 EQU 	1		; Si =0,pas de musique
					; Si =1,play Yvette !

; *********************************************************************** ;
; **********              Definition des macros                ********** ;
; *********************************************************************** ;

Swap_Screens Macro
	lea 	Adr_Screen1(pc),a0		; Debut adresses ecrans
	movem.l	(a0),d0-d1			; Charge les 2 donnees
	move.l 	d1,(a0)+			; Donnees ecran 1
	move.l 	d0,(a0)+			; Donnees ecran 2
 EndM
 
move_dmacon	MACRO
.setdma\@	MOVE.W D4,-(Sp)			; save D4
		MOVE.W \1,D4
		BTST #15,D4			; set or clear?
		BNE.S .setbits\@		
.clearbits\@	NOT.W D4			; zero so clear
		AND.W D4,shadow_dmacon		; mask bits in dmacon
		BRA.S .dmacon_set\@		; and exit...
.setbits\@	OR.W D4,shadow_dmacon		; not zero so set 'em
.dmacon_set\@	MOVE.W (sp)+,D4			; restore D4
		ENDM
 
; *********************************************************************** ;
; **********               Programme principal                 ********** ;
; *********************************************************************** ;

	TEXT

	pea 	Main(pc)
	move.w 	#38,-(sp)
	trap 	#14
	addq.l 	#6,sp
	clr.w 	-(sp)
	trap 	#1
	 
Main
	move.l 	usp,a0				; Pile utilisateur
	move.l 	a0,Save_User_Stack		; Sauvee
	move.l 	sp,Save_Super_Stack		; Pile superviseur sauvee
	move.w 	#$2500,sr			; Ipl 5
	bsr 	Save_System			; Sauve registres systeme
 IfNe SndTrack	
 	bsr 	Init_Music			; Initialise soundtrack
 EndC
	move.w 	#$2700,sr			; Ipl 7
	bsr 	Init_Screens_Adr		; Initialise adresses ecrans
	bsr 	Init_System			; initialise registres systeme
	move.w 	#$2300,sr			; Ipl 3
Wait_Space
	cmpi.b 	#$1d,$fffffc02.w		; Touche Control appuyee ?
	seq 	Test_Time			; Si oui,le signaler...
	tst.w 	Test_Time			; Test temps machine ?
	beq.s 	No_Test_Time1			; Si non,saut
	move.l 	#$fcfc00fc,$ffff9800.w		; Si oui,fond blanc !
No_Test_Time1
	clr.w 	N_Vbl				; Pas de Vbl passee...
	bsr.s 	Demo				; Execute la demo
	Swap_Screens				; Swappe ecrans logique/phys
	tst.w 	Test_Time			; Test temps machine ?
	beq.s 	Wait_Vbl			; Si non,saut
	clr.l 	$ffff9800.w			; Si oui,fond noir !
Wait_Vbl
	tst.w 	N_Vbl				; Vbl passee ?
	beq.s 	Wait_Vbl			; Si non,on attend !
	move.l 	d1,d0				; Sauve adresse ecran
	lsr.w 	#8,d1				; Decalage mot poids faible
	move.l 	d1,$ffff8200.w			; Adresse ecran (moyen/fort)
	move.b 	d0,$ffff820D.w			; Adresse ecran (faible)
	tst.w 	Space_Pressed			; Touche Espace appuyee ?
	beq.s 	Wait_Space			; Si non,on boucle...
Reset
	move.w 	#$2700,sr			; Ipl 7
	move.l 	Save_User_Stack(pc),a0		; Pile utilisateur
	move.l 	a0,usp				; Restauree
	move.l 	Save_Super_Stack(pc),sp		; Pile superviseur restauree
	move.l 	Error(pc),d0			; Erreur
	beq.s 	No_Error			; Si nulle,pas d'erreur !
	move.l 	d0,$ffff9800.w			; Couleur de l'erreur
Wait_Escape
	cmpi.b 	#$1,$fffffc02.w			; Touche Escape pressee ?
	bne.s 	Wait_Escape			; Si non,on boucle...
No_Error
	bsr 	Restore_System			; Restaure registres systeme
	move.w 	#$2500,sr			; Ipl 5
 IfNe SndTrack	
 	bsr 	Stop_Music			; Arrete soundtrack
 EndC
	move.w 	#$2300,sr			; Ipl 3
	rts	
	
Save_User_Stack
	ds.l 	1
Save_Super_Stack
	ds.l 	1
Test_Time
	ds.w 	1
Space_Pressed
	ds.w 	1
Error
	ds.l 	1
		
; *********************************************************************** ;
; **********           Routine principale de la demo           ********** ;
; *********************************************************************** ;

Demo
	rts
	
; *********************************************************************** ;
; **********        Routines d'initialisation du FALCON        ********** ;
; *********************************************************************** ;

Save_System
	lea 	Old_System(pc),a0		; Espace de sauvegarde
	movec 	cacr,d0				; Valeur du cache
	move.w 	d0,(a0)+			; Sauvee !
	move.b 	$ffff8007.w,(a0)+		; Configuration 68030
	move.b 	$ffff8201.w,(a0)+		; Video (poids fort)
	move.b 	$ffff8203.w,(a0)+		; Video (poids moyen)
	move.b 	$ffff820d.w,(a0)+		; Video (poids faible)
	move.b 	$ffff820a.w,(a0)+		; Synchronisation video
	move.w 	$ffff820e.w,(a0)+		; Offset pour prochaine ligne
	move.w 	$ffff8210.w,(a0)+		; Largeur d'une ligne en mots
	move.b 	$ffff8260.w,(a0)+		; Resolution ST
	move.w 	$ffff8266.w,(a0)+		; Resolution FALCON
	move.w 	$ffff8282.w,(a0)+		; HHT-Synchro
	move.w 	$ffff8284.w,(a0)+		; Fin du decodage de la ligne
	move.w 	$ffff8286.w,(a0)+		; Debut du decodage de la ligne
	move.w 	$ffff8288.w,(a0)+		; Overscan gauche
	move.w 	$ffff828a.w,(a0)+		; Overscan droit
	move.w 	$ffff828c.w,(a0)+		; HSS-Synchro
	move.w 	$ffff828e.w,(a0)+		; HFS
	move.w 	$ffff8290.w,(a0)+		; HEE
	move.w 	$ffff82a2.w,(a0)+		; VFT-Synchro
	move.w 	$ffff82a4.w,(a0)+		; Fin du decodage de l'image
	move.w 	$ffff82a6.w,(a0)+		; Debut du decodage de l'image
	move.w 	$ffff82a8.w,(a0)+		; Overscan haut
	move.w 	$ffff82aa.w,(a0)+		; Overscan bas
	move.w 	$ffff82ac.w,(a0)+		; VSS-Synchro
	move.w 	$ffff82c0.w,(a0)+		; Reconnaissance ST/FALCON
	move.w 	$ffff82c2.w,(a0)+		; Informations resolution
	move.b 	$fffffa01.w,(a0)+		; Registre gpip
	move.b 	$fffffa03.w,(a0)+		; Registre aer
	move.b 	$fffffa05.w,(a0)+		; Registre ddr
	move.b 	$fffffa07.w,(a0)+		; Registre iera
	move.b 	$fffffa09.w,(a0)+		; Registre ierb
	move.b 	$fffffa0b.w,(a0)+		; Registre ipra
	move.b 	$fffffa0d.w,(a0)+		; Registre iprb
	move.b 	$fffffa0f.w,(a0)+		; Registre isra
	move.b 	$fffffa11.w,(a0)+		; Registre isrb
	move.b 	$fffffa13.w,(a0)+		; Registre imra
	move.b 	$fffffa15.w,(a0)+		; Registre imrb
	move.b 	$fffffa17.w,(a0)+		; Registre vr
	move.b 	$fffffa19.w,(a0)+		; Controle Timer A
	move.b 	$fffffa1b.w,(a0)+		; Controle Timer B
	move.b 	$fffffa1d.w,(a0)+		; Controle Timer C et D
	move.b 	$fffffa1f.w,(a0)+		; Donnee Timer A
	move.b 	$fffffa21.w,(a0)+		; Donnee Timer B
	move.b 	$fffffa23.w,(a0)+		; Donnee Timer C
	move.b 	$fffffa25.w,(a0)+		; Donnee Timer D
	move.b 	$fffffa27.w,(a0)+		; Registre ucr
	move.b 	$fffffa2b.w,(a0)+		; Registre rsr
	move.b 	$fffffa2d.w,(a0)+		; Registre tsr
	move.b 	$fffffa2f.w,(a0)+		; Registre udr
	move.l 	$8.w,(a0)+			; Bus error
	move.l 	$10.w,(a0)+			; Illegal error
	move.l 	$14.w,(a0)+			; Div0 error
	move.l 	$68.w,(a0)+			; Adresse HBL
	move.l 	$70.w,(a0)+			; Adresse VBL
	move.l 	$110.w,(a0)+			; Adresse Timer D
	move.l 	$114.w,(a0)+			; Adresse Timer C
	move.l 	$120.w,(a0)+			; Adresse Timer B
	move.l 	$134.w,(a0)+			; Adresse Timer A
	lea 	$ffff8240.w,a1			; Palette ST
	moveq 	#7,d0				; 8 longs...
Save_ST_Palette	
	move.l	(a1)+,(a0)+			; Sauve 2 couleurs
	dbf 	d0,Save_ST_Palette		; Boucle les 16 mots !
	lea 	$ffff9800.w,a1			; Palette FALCON
	move.w 	#255,d0				; 256 longs...
Save_FALCON_Palette
	move.l	(a1)+,(a0)+			; Sauve 1 couleur
	dbf 	d0,Save_FALCON_Palette		; Boucle les 256 longs !
	rts
	
Init_Music
	move.w 	#1,-(sp)
	move.w 	#1,-(sp)
	move.w 	#0,-(sp)
	move.w 	#8,-(sp)
	move.w 	#1,-(sp)
	move.w 	#$8b,-(sp)
	trap 	#14
	lea 	12(sp),sp
	move.w 	#0,-(sp)
	move.w 	#1,-(sp)
	move.w 	#$89,-(sp)
	trap 	#14
	addq.w 	#6,sp
	lea 	Dsp_Rout,a0
	move.l 	a0,a1
	move.l 	#$5ec,d0
	lsr.l 	#2,d0
	subq.w 	#1,d0
lbc000054
	addq.l 	#1,a1
	move.b 	(a1)+,(a0)+
	move.b 	(a1)+,(a0)+
	move.b 	(a1)+,(a0)+
	dbf 	d0,lbc000054
	move.w 	#1,-(sp)
	move.l 	#$17b,-(sp)
	pea 	Dsp_Rout(pc)
	move.w 	#$6e,-(sp)
	trap 	#14
	lea 	12(sp),sp
	bsr.s 	Init_Buffer
	bsr.s 	Init_Module
	bsr 	Init_voices
	rts

Init_Buffer
	lea 	mt_FreqTable,a0
	move.w 	#$4f,d0
Loop_Clear_Buffer
	clr.l 	(a0)+
	dbf 	d0,Loop_Clear_Buffer
	move.w 	#$31f,d0
	move.l 	#$50,d1
	move.l 	#$24665268,d2
Loop_Fill_Buffer
	move.l 	d2,d4
	divu.l 	d1,d4
	move.l 	d4,(a0)+
	addq.l 	#1,d1
	dbf 	d0,Loop_Fill_Buffer
	rts

Init_Module
	lea 	Module,a0
	lea 	$3b6(a0),a1
	lea 	$86(a1),a2
	moveq 	#$1e,d0
	cmp.l 	#"M.K.",$438(a0)
	beq.s 	Instr31
	lea 	$1d6(a0),a1
	lea 	$82(a1),a2
	moveq 	#14,d0
Instr31
	move.l 	a1,Sequence_adr		; Adresse de la sequence.
	move.l 	a2,Patterns_adr		; Adresse des "patterns".
	move.w 	d0,Nb_samples		; Nombre d'instruments.
	move.l 	Sequence_adr,a1
	addq.l 	#2,a1
	moveq 	#$7f,d0
	moveq 	#0,d1
mt_loop
	move.b 	(a1)+,d2
	cmp.b 	d2,d1
	bcc.s 	mt_minus
	move.b 	d2,d1
mt_minus
	dbf 	d0,mt_loop
	addq.w 	#1,d1
	mulu 	#$400,d1
	move.l 	Patterns_adr,a1
	lea 	(a1,d1.l),a1		; A1 => Adresse SAMPLES.
	lea 	$2a(a0),a2		; Pointe sur longueur 1er sample.     
	moveq 	#0,d2
	move.w 	Nb_samples,d0
mt_Clength
	move.w 	(a2),d3
	ext.l 	d3
	add.l 	d3,d3
	add.l 	d3,d2
	add.w 	#$1e,a2
	dbf 	d0,mt_Clength		; Calcule longueur totale des SAMPLES.
	move.l 	#$64000,a2		; Un peu de place pour les precalculs.
					; Cette valeur varie suivant les 
					; modules, mais $64000 semble convenir
					; pour la plupart...
	add.l 	a0,a2
	move.l 	a1,a3
	add.l 	d2,a1
mt_Move
	move.w 	-(a1),-(a2)
	subq.l 	#2,d2
	bne.s 	mt_Move
	lea 	Samples_adr,a1
	move.w 	Nb_samples,d0
mt_NextSample
	move.l 	a3,(a1)+
	tst.w 	$2a(a0)
	beq.s 	mt_NulLength
	tst.w 	$2e(a0)
	bne.s 	mt_RepeatTrue
	move.w 	$2a(a0),d1
	move.w 	d1,d3
	subq.w 	#1,d1
	move.l 	a3,a4
lbc0002b2
	move.w 	(a2)+,(a3)+
	dbf 	d1,lbc0002b2
	bra.s 	lbc0002d2
mt_RepeatTrue
	move.w 	$2e(a0),d1
	move.w 	d1,d3
	subq.w 	#1,d1
	move.l 	a2,a4
lbc0002c4
	move.w 	(a4)+,(a3)+
	dbf 	d1,lbc0002c4
	add.w 	$2a(a0),a2
	add.w 	$2a(a0),a2
lbc0002d2
	move.l 	a3,a5
	moveq 	#0,d1
lbc0002d6
	move.l 	a4,a6
	move.w 	$30(a0),d2
	subq.w 	#1,d2
lbc0002de
	move.w 	(a6)+,(a3)+
	addq.w 	#2,d1
	dbf 	d2,lbc0002de
	cmp.w 	#$384,d1
	bcs.s 	lbc0002d6
	move.w 	#$1c1,d2
lbc0002f0
	move.w 	(a5)+,(a3)+
	dbf 	d2,lbc0002f0
	add.w 	d3,d3
	move.w 	d3,$2a(a0)
	move.w 	d1,$30(a0)
	clr.w 	$2e(a0)
mt_NulLength
	lea 	$1e(a0),a0
	dbf 	d0,mt_NextSample
	rts

Init_voices
	lea 	NullSample,a0
	move.l 	a0,a1
	lea 	$384(a1),a2
	move.w 	#$383,d0
lbc00034e
	clr.w 	(a0)+
	dbf 	d0,lbc00034e
	lea 	DSP_datas,a0	
	move.w 	#3,d0
lbc00035e
	move.l 	a1,(a0)
	move.l 	a2,4(a0)
	move.l 	#$384,8(a0)
	move.w 	#$320,12(a0)
	clr.w 	14(a0)
	move.w 	#$ffff,$10(a0)
	add.w 	#$12,a0
	dbf 	d0,lbc00035e
	
	move_dmacon #$F
	
	rts

Init_Screens_Adr
	lea 	Screens,a0		        ; Espace pour ecrans
	lea 	Adr_Screen1(pc),a1		; Premiere adresse
	moveq 	#1,d0				; 2 ecrans
Init_Screen_Adr
	move.l 	a0,d1				; Adresse ecran
	addi.l 	#256,d1				; +256
	andi.l 	#$ffffff00,d1			; Multiple de 256
	move.l 	d1,(a1)+			; Adresse sauvee !
	adda.l 	#64256,a0			; Prochain ecran
	dbf 	d0,Init_Screen_Adr		; Boucle les 2 ecrans
	rts
	
Adr_Screen1
	ds.l 	1
Adr_Screen2
	ds.l 	1

Init_System
	movec 	cacr,d0			; Valeur du cache
	move.w 	#$2d0d,d0		; Caches actives
	movec 	d0,cacr			; Nouvelle valeur
	move.b 	#5,$ffff8007.w		; 68030 et Blitter a 16 Mhz
	move.l 	Adr_Screen1(pc),d0	; Adresse ecran...
	lsr.w 	#8,d0			; Adresse hardware
	move.l 	d0,$ffff8200.w		; Fixee !
	move.l 	Adr_Screen1(pc),d0	; Adresse ecran...
	move.b 	d0,$ffff820d.w		; Fixee ! (poid faible)
	move.b 	#2,$ffff820a.w		; 50 Hz
	clr.w 	$ffff820e.w		; Offset pour prochaine ligne nul
	move.w 	#160,$ffff8210.w	; Largeur d'une ligne en mots=160
	move.w 	#16,$ffff8266.w		; Resolution FALCON=256 couleurs
	cmpi.b 	#128,$ffff8006.w	; Ecran VGA ?
	bhs.s 	Vga_Screen		; Si oui,saut...
	move.w 	#254,$ffff8282.w	; HHT-Synchro
	move.w 	#203,$ffff8284.w	; Fin du decodage de la ligne
	move.w 	#39,$ffff8286.w		; Debut du decodage de la ligne
	move.w 	#28,$ffff8288.w		; Overscan gauche
	move.w 	#125,$ffff828a.w	; Overscan droit
	move.w 	#216,$ffff828c.w	; HSS-Synchro
	clr.w 	$ffff828e.w		; HFS
	clr.w 	$ffff8290.w		; HEE
	move.w 	#625,$ffff82a2.w	; VFT-Synchro
	move.w 	#613,$ffff82a4.w	; Fin du decodage de l'image
	move.w 	#47,$ffff82a6.w		; Debut du decodage de l'image
	move.w 	#127,$ffff82a8.w	; Overscan haut
	move.w 	#527,$ffff82aa.w	; Overscan bas
	move.w 	#619,$ffff82ac.w	; VSS-Synchro
	move.w 	#385,$ffff82c0.w	; Indique resolution FALCON
	clr.w 	$ffff82c2.w		; Informations resolution
	bra.s 	TV_Screen		; Sauter VGA infos
Vga_Screen
	move.w 	#198,$ffff8282.w	; HHT-Synchro
	move.w 	#141,$ffff8284.w	; Fin du decodage de la ligne
	move.w 	#21,$ffff8286.w		; Debut du decodage de la ligne
	move.w 	#666,$ffff8288.w	; Overscan gauche
	move.w 	#123,$ffff828a.w	; Overscan droit
	move.w 	#150,$ffff828c.w	; HSS-Synchro
	clr.w 	$ffff828e.w		; HFS
	clr.w 	$ffff8290.w		; HEE
	move.w 	#1049,$ffff82a2.w	; VFT-Synchro
	move.w 	#1023,$ffff82a4.w	; Fin du decodage de l'image
	move.w 	#63,$ffff82a6.w		; Debut du decodage de l'image
	move.w 	#63,$ffff82a8.w		; Overscan haut
	move.w 	#1023,$ffff82aa.w	; Overscan bas
	move.w 	#1045,$ffff82ac.w	; VSS-Synchro
	move.w 	#390,$ffff82c0.w	; Indique resolution FALCON
	clr.w 	$ffff82c2.w		; Informations resolution
TV_Screen
	clr.b 	$fffffa07.w		; Registre iera nul
	clr.b 	$fffffa09.w		; Registre ierb nul
	clr.b 	$fffffa0b.w		; Registre ipra nul
	clr.b 	$fffffa0d.w		; Registre iprb nul
	clr.b 	$fffffa0f.w		; Registre isra nul
	clr.b 	$fffffa11.w		; Registre isrb nul
	clr.b 	$fffffa13.w		; Registre imra nul
	clr.b 	$fffffa15.w		; Registre imrb nul
	bclr 	#3,$fffffa17.w		; Fin interruptions automatique
	clr.b 	$fffffa19.w		; Timer A stoppe
	clr.b 	$fffffa1b.w		; Timer B stoppe
	clr.b 	$fffffa1d.w		; Timer C et D stoppes
	clr.b 	$fffffa1f.w		; Donnee Timer B nulle
	clr.b 	$fffffa21.w		; Donnee Timer B nulle
	clr.b 	$fffffa23.w		; Donnee Timer C nulle
	clr.b 	$fffffa25.w		; Donnee Timer D nulle
	move.l 	#Bus_Error,$8.w		; Deroute erreur bus
	move.l 	#Ilg_Error,$10.w	; Deroute erreur illegal
	move.l 	#Div_Error,$14.w	; Deroute erreur div0
	move.l 	#New_Hbl,$68.w		; Nouvelle routine HBL !
	move.l 	#New_Vbl,$70.w		; Nouvelle routine VBL !
	clr.l 	$110.w			; Pas de Timer D
	clr.l 	$114.w			; Pas de Timer C
	clr.l 	$120.w			; Pas de Timer B
	clr.l 	$134.w			; Pas de Timer A
 IfNe SndTrack	
 	move.l 	#Timer_A,$134.w		; Routine de SoundTrack
	ori.b 	#32,$fffffa07.w		; Timer A active
	ori.b 	#32,$fffffa13.w		; Timer A non masque
	move.b 	#7,$fffffa19.w		; Base Timer A = 12288 Hz
	move.b 	#$cc,$fffffa1f.w	; Frequence Timer A = 60 Hz
 EndC
	moveq 	#0,d0			; d0 nul
	lea 	$ffff8240.w,a0		; Palette ST
	moveq 	#7,d1			; 8 longs...
Init_ST_Palette
	move.l 	d0,(a0)+		; 2 couleurs noires
	dbf 	d1,Init_ST_Palette	; Boucle les 16 mots !
	lea 	$ffff9800.w,a0		; Palette FALCON
	move.w 	#255,d1			; 256 longs...
Init_FALCON_Palette	
	move.l 	d0,(a0)+		; 1 couleur noire
	dbf 	d1,Init_FALCON_Palette	; Boucle les 256 longs !
	rts	
	
Restore_System
	lea 	Old_System(pc),a0	; Espace de sauvegarde
	move.w 	(a0)+,d0		; Valeur du cache
	movec 	d0,cacr			; Restauree !
	move.b 	(a0)+,$ffff8007.w	; Configuration 68030
	move.b 	(a0)+,$ffff8201.w	; Video (poids fort)
	move.b 	(a0)+,$ffff8203.w	; Video (poids moyen)
	move.b 	(a0)+,$ffff820d.w	; Video (poids faible)
	move.b 	(a0)+,$ffff820a.w	; Synchronisation video
	move.w 	(a0)+,$ffff820e.w	; Offset pour prochaine ligne
	move.w 	(a0)+,$ffff8210.w	; Largeur d'une ligne en mots
	move.b 	(a0)+,d0		; Resolution ST
	move.w 	(a0)+,d1		; Resolution FALCON
	move.w 	(a0)+,$ffff8282.w	; HHT-Synchro
	move.w 	(a0)+,$ffff8284.w	; Fin du decodage de la ligne
	move.w 	(a0)+,$ffff8286.w	; Debut du decodage de la ligne
	move.w 	(a0)+,$ffff8288.w	; Overscan gauche
	move.w 	(a0)+,$ffff828a.w	; Overscan droit
	move.w 	(a0)+,$ffff828c.w	; HSS-Synchro
	move.w 	(a0)+,$ffff828e.w	; HFS
	move.w 	(a0)+,$ffff8290.w	; HEE
	move.w 	(a0)+,$ffff82a2.w	; VFT-Synchro
	move.w 	(a0)+,$ffff82a4.w	; Fin du decodage de l'image
	move.w 	(a0)+,$ffff82a6.w	; Debut du decodage de l'image
	move.w 	(a0)+,$ffff82a8.w	; Overscan haut
	move.w 	(a0)+,$ffff82aa.w	; Overscan bas
	move.w 	(a0)+,$ffff82ac.w	; VSS-Synchro
	move.w 	(a0)+,$ffff82c0.w	; Reconnaissance ST/FALCON
	move.w 	(a0)+,$ffff82c2.w	; Informations resolution
	move.b 	(a0)+,$fffffa01.w	; Registre gpip
	move.b 	(a0)+,$fffffa03.w	; Registre aer
	move.b 	(a0)+,$fffffa05.w	; Registre ddr
	move.b 	(a0)+,$fffffa07.w	; Registre iera
	move.b 	(a0)+,$fffffa09.w	; Registre ierb
	move.b 	(a0)+,$fffffa0b.w	; Registre ipra
	move.b 	(a0)+,$fffffa0d.w	; Registre iprb
	move.b 	(a0)+,$fffffa0f.w	; Registre isra
	move.b 	(a0)+,$fffffa11.w	; Registre isrb
	move.b 	(a0)+,$fffffa13.w	; Registre imra
	move.b 	(a0)+,$fffffa15.w	; Registre imrb
	move.b 	(a0)+,$fffffa17.w	; Registre vr
	move.b 	(a0)+,$fffffa19.w	; Controle Timer A
	move.b 	(a0)+,$fffffa1b.w	; Controle Timer B
	move.b 	(a0)+,$fffffa1d.w	; Controle Timer C et D
	move.b 	(a0)+,$fffffa1f.w	; Donnee Timer A
	move.b 	(a0)+,$fffffa21.w	; Donnee Timer B
	move.b 	(a0)+,$fffffa23.w	; Donnee Timer C
	move.b 	(a0)+,$fffffa25.w	; Donnee Timer D
	move.b 	(a0)+,$fffffa27.w	; Registre ucr
	move.b 	(a0)+,$fffffa2b.w	; Registre rsr
	move.b 	(a0)+,$fffffa2d.w	; Registre tsr
	move.b 	(a0)+,$fffffa2f.w	; Registre udr
	move.l 	(a0)+,$8.w		; Bus error
	move.l 	(a0)+,$10.w		; Illegal error
	move.l 	(a0)+,$14.w		; Div0 error
	move.l 	(a0)+,$68.w		; Adresse HBL
	move.l 	(a0)+,$70.w		; Adresse VBL
	move.l 	(a0)+,$110.w		; Adresse Timer D
	move.l 	(a0)+,$114.w		; Adresse Timer C
	move.l 	(a0)+,$120.w		; Adresse Timer B
	move.l 	(a0)+,$134.w		; Adresse Timer A
	btst 	#0,$ffff82c0		; Resolution FALCON ?
	bne.s 	Falcon_Rez		; Si oui,saut !
	move.w 	d1,$ffff8266.w		; Fixe resolution FALCON...
	move.b 	d0,$ffff8260.w		; Fixe resolution ST...
	bra.s 	St_Rez			; Saut
Falcon_Rez
	move.w 	d1,$ffff8266.w		; Fixe resolution FALCON...
St_Rez	
	lea 	$ffff8240.w,a1		; Palette ST
	moveq 	#7,d0			; 8 longs...
Restore_ST_Palette	
	move.l 	(a0)+,(a1)+		; Restaure 2 couleurs
	dbf 	d0,Restore_ST_Palette	; Boucle les 16 mots !
	lea 	$ffff9800.w,a1		; Palette FALCON
	move.w 	#255,d0			; 256 longs...
Restore_FALCON_Palette
	move.l 	(a0)+,(a1)+		; Restaure 1 couleur
	dbf 	d0,Restore_FALCON_Palette	; Boucle les 256 longs !
Wait_No_Key
	move.b 	$fffffc02.w,d0		; Code clavier
	btst 	#0,$fffffc00.w		; Buffer vide ?
	bne.s 	Wait_No_Key		; Sinon,on continue...
	rts	
	
Stop_Music
	move.w 	#1,-(sp)
	move.w 	#0,-(sp)
	move.w 	#0,-(sp)
	move.w 	#8,-(sp)
	move.w 	#0,-(sp)
	move.w 	#$8b,-(sp)
	trap 	#14
	lea 	12(sp),sp
	move.w 	#0,-(sp)
	move.w 	#$84,-(sp)
	trap 	#14
	addq.w 	#4,sp
	rts

Old_System
	ds.l 	50+8+256

; *********************************************************************** ;
; **********               Gestion des erreurs !               ********** ;
; *********************************************************************** ;

Bus_Error
	move.l 	#$fc000000,Error		; Rouge
	jmp 	Reset
	
Ilg_Error
	move.l 	#$00fc0000,Error		; Vert
	jmp 	Reset
	
Div_Error
	move.l 	#$000000fc,Error		; Bleu
	jmp 	Reset

; *********************************************************************** ;
; **********        Routines tournant sous interruption        ********** ;
; *********************************************************************** ;

New_Hbl
	rte

New_Vbl
	addq.w 	#1,N_Vbl			; Signale Vbl
	cmpi.b 	#$39,$fffffc02.w		; Touche Espace appuyee ?
	bne.s 	End_Vbl				; Si non,saut !
	st 	Space_Pressed			; Si oui,le signaler...
End_Vbl
	rte
	
N_Vbl
	ds.w 	1
	
; *********************************************************************** ;
; **********               Gestion du SoundTrack               ********** ;
; *********************************************************************** ;

n_note		EQU	0  ; W
n_cmd		EQU	2  ; W
n_cmdlo		EQU	3  ; B
n_start		EQU	4  ; L
n_length	EQU	8  ; W
n_loopstart	EQU	10 ; L
n_replen	EQU	14 ; W
n_period	EQU	16 ; W
n_finetune	EQU	18 ; B
n_volume	EQU	19 ; B
n_dmabit	EQU	20 ; W
n_toneportdirec	EQU	22 ; B
n_toneportspeed	EQU	23 ; B
n_wantedperiod	EQU	24 ; W
n_vibratocmd	EQU	26 ; B
n_vibratopos	EQU	27 ; B
n_tremolocmd	EQU	28 ; B
n_tremolopos	EQU	29 ; B
n_wavecontrol	EQU	30 ; B
n_glissfunk	EQU	31 ; B
n_sampleoffset	EQU	32 ; B
n_pattpos	EQU	33 ; B
n_loopcount	EQU	34 ; B
n_funkoffset	EQU	35 ; B
n_wavestart	EQU	36 ; L
n_reallength	EQU	40 ; L

sam_start	EQU	0  ; L
sam_length	EQU	4  ; W
sam_period	EQU	6  ; W
sam_vol		EQU	8  ; W
sam_lpstart	EQU	10 ; L
sam_lplength	EQU	14 ; W

DSP_start	EQU	0  ; L
DSP_end		EQU	4  ; L
DSP_repstart	EQU	8  ; L
DSP_period	EQU	12 ; W
DSP_vol		EQU	14 ; W
DSP_repeat	EQU	16 ; W

Timer_A
	movem.l	d0-a6,-(sp)
	lea 	$ffffa200,a6
	lea 	mt_FreqTable,a0
	lea 	DSP_datas,a1
	clr.b 	7(a6)
	bsr.s 	Play_A_Voice
	bsr.s 	Play_A_Voice
	bsr.s 	Play_A_Voice
	bsr.s 	Play_A_Voice
	bsr.s 	Play_Patterns
	movem.l	(sp)+,d0-a6
	rte

Play_A_Voice
	move.b 	DSP_vol+1(a1),5(a6)
	clr.w 	6(a6)
	move.w 	DSP_period(a1),d0
	lea 	(a0,d0.w*4),a3
	move.l 	(a3),4(a6)
	moveq 	#0,d0
wait_DSP1
	btst 	#0,2(a6)
	beq.s 	wait_DSP1
	move.l 	4(a6),d0
	tst.w 	DSP_repeat(a1)
	beq.s 	lbc0001a8
	clr.w 	DSP_repeat(a1)
	move.l 	DSP_start(a1),a2
	bra.s 	lbc0001bc
lbc0001a8
	add.l 	(a1),d0
	cmp.l 	DSP_end(a1),d0
	bcs.s 	lbc0001b6
	sub.l 	DSP_repstart(a1),d0
lbc0001b6
	move.l 	d0,(a1)
	move.l 	d0,a2
lbc0001bc
	moveq 	#0,d0
wait_DSP2
;	btst 	#0,2(a6)	; Pas la peine...
;	beq.s 	wait_DSP2	; DSP works very fast !!!
				; Enlever les points-virgule si problemes...
	move.l 	4(a6),d0
	divu 	#3,d0
	addq.w 	#2,d0
	move.w 	d0,d2
	clr.b 	5(a6)
	move.w 	d0,6(a6)
	subq.w 	#1,d2
transmit_loop
	move.b 	(a2)+,5(a6)
	move.w 	(a2)+,6(a6)
	dbf 	d2,transmit_loop
	add.w 	#18,a1
	rts

Play_Patterns
	lea 	Module,a0
	ADDQ.B	#1,mt_counter
	MOVE.B	mt_counter(PC),D0
	CMP.B	mt_speed(PC),D0
	BNE.S	mt_NoNewNote
	MOVE.B	#$FF,mt_counter
	TST.B	mt_PattDelTime2
	BEQ.S	mt_GetNewNote
	BSR.S	mt_NoNewAllChannels
	BRA	mt_dskip

mt_NoNewNote
	BSR.S	mt_NoNewAllChannels
	BRA	mt_NoNewPosYet

mt_NoNewAllChannels
	LEA	ch1s(PC),A5
	LEA	mt_chan1temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch2s(PC),A5
	LEA	mt_chan2temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch3s(PC),A5
	LEA	mt_chan3temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch4s(PC),A5
	LEA	mt_chan4temp(PC),A6
	BRA	mt_CheckEfx

mt_GetNewNote
	LEA	Module(PC),A3
	LEA	$2A(A3),A3
	MOVE.L	Sequence_adr,A2				;pattpo
	ADDQ.l	#2,A2
	MOVE.L	Patterns_adr,A0				;patterndata
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	mt_SongPos(PC),D0
	MOVE.B	(A2,D0.W),D1
	ASL.L	#8,D1
	ASL.L	#2,D1
	ADD.W	mt_PatternPos(PC),D1
	CLR.W	mt_DMACONtemp

	LEA	ch1s(PC),A5
	LEA	mt_chan1temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch2s(PC),A5
	LEA	mt_chan2temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch3s(PC),A5
	LEA	mt_chan3temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch4s(PC),A5
	LEA	mt_chan4temp(PC),A6
	BSR.S	mt_PlayVoice
	BRA	mt_SetDMA

mt_PlayVoice
	TST.L	(A6)
	BNE.S	mt_plvskip
	BSR	mt_PerNop
mt_plvskip
	MOVE.L	(A0,D1.L),(A6)
	ADDQ.L	#4,D1
	MOVEQ	#0,D2
	MOVE.B	n_cmd(A6),D2
	AND.B	#$F0,D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0
	AND.B	#$F0,D0
	OR.B	D0,D2
	TST.B	D2
	BEQ.S	mt_SetRegs
	MOVEQ	#0,D3
	SUBQ.L	#1,D2
	MOVE	D2,D4
	ASL.L	#2,D2
	MULU	#30,D4
	LEA	Samples_adr,A1
	MOVE.L	(A1,D2.L),n_start(A6)
	MOVE.W	(A3,D4.L),n_length(A6)
	MOVE.W	(A3,D4.L),n_reallength(A6)
	MOVE.W	2(A3,D4.L),n_finetune(A6)
	MOVE.W	4(A3,D4.L),D3 ; Get repeat
	TST.W	D3
	BEQ.S	mt_NoLoop
	MOVE.L	n_start(A6),D2				; Get start
	ASL.W	#1,D3
	ADD.L	D3,D2					; Add repeat
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	4(A3,D4.L),D0				; Get repeat
	ADD.W	6(A3,D4.L),D0				; Add replen
	MOVE.W	D0,n_length(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)			; Save replen
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,sam_vol(A5)				; Set volume
	BRA.S	mt_SetRegs

mt_NoLoop
	MOVE.L	n_start(A6),D2
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)			; Save replen
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,sam_vol(A5)				; Set volume
mt_SetRegs
	MOVE.W	(A6),D0
	AND.W	#$0FFF,D0
	BEQ	mt_CheckMoreEfx				; If no note
	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0E50,D0
	BEQ.S	mt_DoSetFineTune
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#3,D0					; TonePortamento
	BEQ.S	mt_ChkTonePorta
	CMP.B	#5,D0
	BEQ.S	mt_ChkTonePorta
	CMP.B	#9,D0					; Sample Offset
	BNE.S	mt_SetPeriod
	BSR	mt_CheckMoreEfx
	BRA.S	mt_SetPeriod

mt_DoSetFineTune
	BSR	mt_SetFineTune
	BRA.S	mt_SetPeriod

mt_ChkTonePorta
	BSR	mt_SetTonePorta
	BRA	mt_CheckMoreEfx

mt_SetPeriod
	MOVEM.L	D0-D1/A0-A1,-(SP)
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	LEA	mt_PeriodTable(PC),A1
	MOVEQ	#0,D0
	MOVEQ	#36,D2
mt_ftuloop
	CMP.W	(A1,D0.W),D1
	BHS.S	mt_ftufound
	ADDQ.L	#2,D0
	DBRA	D2,mt_ftuloop
mt_ftufound
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#36*2,D1
	ADD.L	D1,A1
	MOVE.W	(A1,D0.W),n_period(A6)
	MOVEM.L	(SP)+,D0-D1/A0-A1

	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0ED0,D0 ; Notedelay
	BEQ	mt_CheckMoreEfx

	move_dmacon n_dmabit(A6)
	
	BTST	#2,n_wavecontrol(A6)
	BNE.S	mt_vibnoc
	CLR.B	n_vibratopos(A6)
mt_vibnoc
	BTST	#6,n_wavecontrol(A6)
	BNE.S	mt_trenoc
	CLR.B	n_tremolopos(A6)
mt_trenoc
	MOVE.L	n_start(A6),sam_start(A5)		; Set start
	MOVE.W	n_length(A6),sam_length(A5)		; Set length
	
	MOVE.W	n_period(A6),D0
	MOVE.W	D0,sam_period(A5)			; Set period
	
	MOVE.w	n_dmabit(A6),D0
	OR.W	D0,mt_DMACONtemp

	BRA	mt_CheckMoreEfx
	
mt_SetDMA
	lea 	DSP_datas,a0
	
	move.w 	mt_DMACONtemp(pc),d0
	btst 	#0,d0
	beq.s 	ch1_OFF
	
	lea	ch1s(PC),a5
	lea	mt_chan1temp(PC),a6
	moveq 	#0,d1
	moveq 	#0,d2
	move.w 	sam_length(a5),d1
	move.w 	n_replen(a6),d2
	add.l 	d2,d1
	move.l 	sam_start(a5),(a0)
	add.l 	sam_start(a5),d1
	move.l 	d1,DSP_end(a0)
	move.l 	d2,DSP_repstart(a0)
	move.w 	#$ffff,DSP_repeat(a0)
	
ch1_OFF
	lea 	18(a0),a0
	btst 	#1,d0
	beq.s 	ch2_OFF
	
	lea	ch2s(PC),a5
	lea	mt_chan2temp(PC),a6
	moveq 	#0,d1
	moveq 	#0,d2
	move.w 	sam_length(a5),d1
	move.w 	n_replen(a6),d2
	add.l 	d2,d1
	move.l 	sam_start(a5),(a0)
	add.l 	sam_start(a5),d1
	move.l 	d1,DSP_end(a0)
	move.l 	d2,DSP_repstart(a0)
	move.w 	#$ffff,DSP_repeat(a0)
	
ch2_OFF
	lea 	18(a0),a0
	btst 	#2,d0
	beq.s 	ch3_OFF
	
	lea	ch3s(PC),a5
	lea	mt_chan3temp(PC),a6
	moveq 	#0,d1
	moveq 	#0,d2
	move.w 	sam_length(a5),d1
	move.w 	n_replen(a6),d2
	add.l 	d2,d1
	move.l 	sam_start(a5),(a0)
	add.l 	sam_start(a5),d1
	move.l 	d1,DSP_end(a0)
	move.l 	d2,DSP_repstart(a0)
	move.w 	#$ffff,DSP_repeat(a0)
	
ch3_OFF
	lea 	18(a0),a0
	btst 	#3,d0
	beq.s 	ch4_OFF
	
	lea	ch4s(PC),a5
	lea	mt_chan4temp(PC),a6
	moveq 	#0,d1
	moveq 	#0,d2
	move.w 	sam_length(a5),d1
	move.w 	n_replen(a6),d2
	add.l 	d2,d1
	move.l 	sam_start(a5),(a0)
	add.l 	sam_start(a5),d1
	move.l 	d1,DSP_end(a0)
	move.l 	d2,DSP_repstart(a0)
	move.w 	#$ffff,DSP_repeat(a0)
	
ch4_OFF
mt_dskip
	add.w 	#$10,mt_PatternPos
	move.b	mt_PattDelTime,d0
	beq.s	mt_dskc
	move.b	d0,mt_PattDelTime2
	clr.b	mt_PattDelTime
mt_dskc
	tst.b	mt_PattDelTime2
	beq.s	mt_dska
	subq.b	#1,mt_PattDelTime2
	beq.s	mt_dska
	sub.w	#16,mt_PatternPos
mt_dska
	tst.b	mt_PBreakFlag
	beq.s	mt_nnpysk
	sf	mt_PBreakFlag
	moveq	#0,d0
	move.b	mt_PBreakPos(PC),d0
	clr.b	mt_PBreakPos
	lsl.w	#4,d0
	move.w	d0,mt_PatternPos
mt_nnpysk
	cmp.w 	#$400,mt_PatternPos
	blo.s 	mt_NoNewPosYet
mt_NextPosition
	moveq	#0,d0
	move.b	mt_PBreakPos(pc),d0
	lsl.w	#4,d0
	move.w	d0,mt_PatternPos
	clr.b	mt_PBreakPos
	clr.b 	mt_PosJumpFlag
	addq.b 	#1,mt_SongPos
	and.b 	#$7f,mt_SongPos
	move.b 	mt_SongPos(pc),d1
	move.l 	Sequence_adr,a0
	cmp.b 	(a0),d1
	blo.s 	mt_NoNewPosYet
	clr.b	mt_SongPos
mt_NoNewPosYet
	tst.b 	mt_PosJumpFlag
	bne.s 	mt_NextPosition
	
	lea 	DSP_datas,a6
	lea	ch1s(pc),a5
	
	move.w 	sam_period(a5),DSP_period(a6)
	move.w	sam_vol(a5),DSP_vol(a6)
	lea 	16(a5),a5
	lea	18(a6),a6
	move.w 	sam_period(a5),DSP_period(a6)
	move.w	sam_vol(a5),DSP_vol(a6)
	lea 	16(a5),a5
	lea	18(a6),a6
	move.w 	sam_period(a5),DSP_period(a6)
	move.w	sam_vol(a5),DSP_vol(a6)
	lea 	16(a5),a5
	lea	18(a6),a6
	move.w 	sam_period(a5),DSP_period(a6)
	move.w	sam_vol(a5),DSP_vol(a6)
mt_exit	
	rts

mt_CheckEfx
	BSR	mt_UpdateFunk
	MOVE.W	n_cmd(A6),D0
	AND.W	#$0FFF,D0
	BEQ.S	mt_PerNop
	MOVE.B	n_cmd(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_Arpeggio
	CMP.B	#1,D0
	BEQ	mt_PortaUp
	CMP.B	#2,D0
	BEQ	mt_PortaDown
	CMP.B	#3,D0
	BEQ	mt_TonePortamento
	CMP.B	#4,D0
	BEQ	mt_Vibrato
	CMP.B	#5,D0
	BEQ	mt_TonePlusVolSlide
	CMP.B	#6,D0
	BEQ	mt_VibratoPlusVolSlide
	CMP.B	#$E,D0
	BEQ	mt_E_Commands
SetBack	MOVE.W	n_period(A6),sam_period(A5)
	CMP.B	#7,D0
	BEQ	mt_Tremolo
	CMP.B	#$A,D0
	BEQ	mt_VolumeSlide
mt_Return
	RTS

mt_PerNop
	MOVE.W	n_period(A6),sam_period(A5)
	RTS

mt_Arpeggio
	MOVEQ	#0,D0
	MOVE.B	mt_counter(PC),D0
	DIVS	#3,D0
	SWAP	D0
	CMP.W	#0,D0
	BEQ.S	mt_Arpeggio2
	CMP.W	#2,D0
	BEQ.S	mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	BRA.S	mt_Arpeggio3

mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#15,D0
	BRA.S	mt_Arpeggio3

mt_Arpeggio2
	MOVE.W	n_period(A6),D2
	BRA.S	mt_Arpeggio4

mt_Arpeggio3
	ASL.W	#1,D0
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#36*2,D1
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D1,A0
	MOVEQ	#0,D1
	MOVE.W	n_period(A6),D1
	MOVEQ	#36,D3
mt_arploop
	MOVE.W	(A0,D0.W),D2
	CMP.W	(A0),D1
	BHS.S	mt_Arpeggio4
	ADDQ.L	#2,A0
	DBRA	D3,mt_arploop
	RTS

mt_Arpeggio4
	MOVE.W	D2,sam_period(A5)
	RTS

mt_FinePortaUp
	TST.B	mt_counter
	BNE.S	mt_Return
	MOVE.B	#$0F,mt_LowMask
mt_PortaUp
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	SUB.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#113,D0
	BPL.S	mt_PortaUskip
	AND.W	#$F000,n_period(A6)
	OR.W	#113,n_period(A6)
mt_PortaUskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,sam_period(A5)
	RTS	
 
mt_FinePortaDown
	TST.B	mt_counter
	BNE	mt_Return
	MOVE.B	#$0F,mt_LowMask
mt_PortaDown
	CLR.W	D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	ADD.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#856,D0
	BMI.S	mt_PortaDskip
	AND.W	#$F000,n_period(A6)
	OR.W	#856,n_period(A6)
mt_PortaDskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,sam_period(A5)
	RTS

mt_SetTonePorta
	MOVE.L	A0,-(SP)
	MOVE.W	(A6),D2
	AND.W	#$0FFF,D2
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#37*2,D0
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D0,A0
	MOVEQ	#0,D0
mt_StpLoop
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_StpFound
	ADDQ.W	#2,D0
	CMP.W	#37*2,D0
	BLO.S	mt_StpLoop
	MOVEQ	#35*2,D0
mt_StpFound
	MOVE.B	n_finetune(A6),D2
	AND.B	#8,D2
	BEQ.S	mt_StpGoss
	TST.W	D0
	BEQ.S	mt_StpGoss
	SUBQ.W	#2,D0
mt_StpGoss
	MOVE.W	(A0,D0.W),D2
	MOVE.L	(SP)+,A0
	MOVE.W	D2,n_wantedperiod(A6)
	MOVE.W	n_period(A6),D0
	CLR.B	n_toneportdirec(A6)
	CMP.W	D0,D2
	BEQ.S	mt_ClearTonePorta
	BGE	mt_Return
	MOVE.B	#1,n_toneportdirec(A6)
	RTS

mt_ClearTonePorta
	CLR.W	n_wantedperiod(A6)
	RTS

mt_TonePortamento
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_TonePortNoChange
	MOVE.B	D0,n_toneportspeed(A6)
	CLR.B	n_cmdlo(A6)
mt_TonePortNoChange
	TST.W	n_wantedperiod(A6)
	BEQ	mt_Return
	MOVEQ	#0,D0
	MOVE.B	n_toneportspeed(A6),D0
	TST.B	n_toneportdirec(A6)
	BNE.S	mt_TonePortaUp
mt_TonePortaDown
	ADD.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BGT.S	mt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)
	BRA.S	mt_TonePortaSetPer

mt_TonePortaUp
	SUB.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BLT.S	mt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)

mt_TonePortaSetPer
	MOVE.W	n_period(A6),D2
	MOVE.B	n_glissfunk(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_GlissSkip
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#36*2,D0
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D0,A0
	MOVEQ	#0,D0
mt_GlissLoop
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_GlissFound
	ADDQ.W	#2,D0
	CMP.W	#36*2,D0
	BLO.S	mt_GlissLoop
	MOVEQ	#35*2,D0
mt_GlissFound
	MOVE.W	(A0,D0.W),D2
mt_GlissSkip
	MOVE.W	D2,sam_period(A5) 			; Set period
	RTS

mt_Vibrato
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_Vibrato2
	MOVE.B	n_vibratocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_vibskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_vibskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_vibskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_vibskip2
	MOVE.B	D2,n_vibratocmd(A6)
mt_Vibrato2
	MOVE.B	n_vibratopos(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	AND.B	#$03,D2
	BEQ.S	mt_vib_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_vib_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_vib_set
mt_vib_rampdown
	TST.B	n_vibratopos(A6)
	BPL.S	mt_vib_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_rampdown2
	MOVE.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_sine
	MOVE.B	(A4,D0.W),D2
mt_vib_set
	MOVE.B	n_vibratocmd(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#7,D2
	MOVE.W	n_period(A6),D0
	TST.B	n_vibratopos(A6)
	BMI.S	mt_VibratoNeg
	ADD.W	D2,D0
	BRA.S	mt_Vibrato3
mt_VibratoNeg
	SUB.W	D2,D0
mt_Vibrato3
	MOVE.W	D0,sam_period(A5)
	MOVE.B	n_vibratocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_vibratopos(A6)
	RTS

mt_TonePlusVolSlide
	BSR	mt_TonePortNoChange
	BRA	mt_VolumeSlide

mt_VibratoPlusVolSlide
	BSR.S	mt_Vibrato2
	BRA	mt_VolumeSlide

mt_Tremolo
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_Tremolo2
	MOVE.B	n_tremolocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_treskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_treskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_treskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_treskip2
	MOVE.B	D2,n_tremolocmd(A6)
mt_Tremolo2
	MOVE.B	n_tremolopos(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	LSR.B	#4,D2
	AND.B	#$03,D2
	BEQ.S	mt_tre_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_tre_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_tre_set
mt_tre_rampdown
	TST.B	n_vibratopos(A6)
	BPL.S	mt_tre_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_rampdown2
	MOVE.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_sine
	MOVE.B	(A4,D0.W),D2
mt_tre_set
	MOVE.B	n_tremolocmd(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#6,D2
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	TST.B	n_tremolopos(A6)
	BMI.S	mt_TremoloNeg
	ADD.W	D2,D0
	BRA.S	mt_Tremolo3
mt_TremoloNeg
	SUB.W	D2,D0
mt_Tremolo3
	BPL.S	mt_TremoloSkip
	CLR.W	D0
mt_TremoloSkip
	CMP.W	#$40,D0
	BLS.S	mt_TremoloOk
	MOVE.W	#$40,D0
mt_TremoloOk
	MOVE.W	D0,sam_vol(A5)
	MOVE.B	n_tremolocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_tremolopos(A6)
	RTS

mt_SampleOffset
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_sononew
	MOVE.B	D0,n_sampleoffset(A6)
mt_sononew
	MOVE.B	n_sampleoffset(A6),D0
	LSL.W	#7,D0
	CMP.W	n_length(A6),D0
	BGE.S	mt_sofskip
	SUB.W	D0,n_length(A6)
	LSL.W	#1,D0
	ADD.L	D0,n_start(A6)
	RTS
mt_sofskip
	MOVE.W	#$0001,n_length(A6)
	RTS

mt_VolumeSlide
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.S	mt_VolSlideDown
mt_VolSlideUp
	ADD.B	D0,n_volume(A6)
	CMP.B	#$40,n_volume(A6)
	BMI.S	mt_vsuskip
	MOVE.B	#$40,n_volume(A6)
mt_vsuskip
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,sam_vol(A5)
	RTS

mt_VolSlideDown
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
mt_VolSlideDown2
	SUB.B	D0,n_volume(A6)
	BPL.S	mt_vsdskip
	CLR.B	n_volume(A6)
mt_vsdskip
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,sam_vol(A5)
	RTS

mt_PositionJump
	MOVE.B	n_cmdlo(A6),D0
	SUBQ.B	#1,D0
	MOVE.B	D0,mt_SongPos
mt_pj2	CLR.B	mt_PBreakPos
	ST 	mt_PosJumpFlag
	RTS

mt_VolumeChange
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	CMP.B	#$40,D0
	BLS.S	mt_VolumeOk
	MOVEQ	#$40,D0
mt_VolumeOk
	MOVE.B	D0,n_volume(A6)
	MOVE.W	D0,sam_vol(A5)
	RTS

mt_PatternBreak
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	MOVE.L	D0,D2
	LSR.B	#4,D0
	MULU	#10,D0
	AND.B	#$0F,D2
	ADD.B	D2,D0
	CMP.B	#63,D0
	BHI.S	mt_pj2
	MOVE.B	D0,mt_PBreakPos
	ST	mt_PosJumpFlag
	RTS

mt_SetSpeed
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	BEQ.s	mt_end
	CLR.B	mt_counter
	MOVE.B	D0,mt_speed	
mt_end		
	RTS

mt_CheckMoreEfx
	BSR	mt_UpdateFunk
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#$9,D0
	BEQ	mt_SampleOffset
	CMP.B	#$B,D0
	BEQ	mt_PositionJump
	CMP.B	#$D,D0
	BEQ	mt_PatternBreak
	CMP.B	#$E,D0
	BEQ.S	mt_E_Commands
	CMP.B	#$F,D0
	BEQ	mt_SetSpeed
	CMP.B	#$C,D0
	BEQ	mt_VolumeChange
	BRA	mt_PerNop

mt_E_Commands
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	LSR.B	#4,D0
	BEQ.S	mt_FilterOnOff
	CMP.B	#1,D0
	BEQ	mt_FinePortaUp
	CMP.B	#2,D0
	BEQ	mt_FinePortaDown
	CMP.B	#3,D0
	BEQ.S	mt_SetGlissControl
	CMP.B	#4,D0
	BEQ.s	mt_SetVibratoControl
	CMP.B	#5,D0
	BEQ.s	mt_SetFineTune
	CMP.B	#6,D0
	BEQ.s	mt_JumpLoop
	CMP.B	#7,D0
	BEQ	mt_SetTremoloControl
	CMP.B	#9,D0
	BEQ	mt_RetrigNote
	CMP.B	#$A,D0
	BEQ	mt_VolumeFineUp
	CMP.B	#$B,D0
	BEQ	mt_VolumeFineDown
	CMP.B	#$C,D0
	BEQ	mt_NoteCut
	CMP.B	#$D,D0
	BEQ	mt_NoteDelay
	CMP.B	#$E,D0
	BEQ	mt_PatternDelay
	CMP.B	#$F,D0
	BEQ	mt_FunkIt
	RTS

mt_FilterOnOff
	RTS	

mt_SetGlissControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	RTS

mt_SetVibratoControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

mt_SetFineTune
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	MOVE.B	D0,n_finetune(A6)
	RTS

mt_JumpLoop
	TST.B	mt_counter
	BNE	mt_Return
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_SetLoop
	TST.B	n_loopcount(A6)
	BEQ.S	mt_jumpcnt
	SUBQ.B	#1,n_loopcount(A6)
	BEQ	mt_Return
mt_jmploop	
	MOVE.B	n_pattpos(A6),mt_PBreakPos
	ST	mt_PBreakFlag
	RTS

mt_jumpcnt
	MOVE.B	D0,n_loopcount(A6)
	BRA.S	mt_jmploop

mt_SetLoop
	MOVE.W	mt_PatternPos(PC),D0
	LSR.W	#4,D0
	MOVE.B	D0,n_pattpos(A6)
	RTS

mt_SetTremoloControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

mt_RetrigNote
	MOVE.L	D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.s	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
	BNE.S	mt_rtnskp
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	BNE.s	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
mt_rtnskp
	DIVU	D0,D1
	SWAP	D1
	TST.W	D1
	BNE.S	mt_rtnend
mt_DoRetrig

	move_dmacon n_dmabit(A6)		; Channel DMA off
	
	MOVE.L	n_start(A6),sam_start(A5) 	; Set sampledata pointer     
	MOVE.W	n_length(A6),sam_length(A5)	; Set length
	
	MOVE.W	n_dmabit(A6),D0
	BSET	#15,D0
	move_dmacon d0
	
	MOVE.L	n_loopstart(A6),sam_lpstart(A5)
	MOVE.L	n_replen(A6),sam_lplength(A5)
	MOVE.W	n_period(A6),sam_period(A5)
mt_rtnend
	MOVE.L	(SP)+,D1
	RTS

mt_VolumeFineUp
	TST.B	mt_counter
	BNE	mt_Return
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F,D0
	BRA	mt_VolSlideUp

mt_VolumeFineDown
	TST.B	mt_counter
	BNE	mt_Return
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BRA	mt_VolSlideDown2

mt_NoteCut
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_counter(PC),D0
	BNE	mt_Return
	CLR.B	n_volume(A6)
	MOVE.W	#0,sam_vol(A5)
	RTS

mt_NoteDelay
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_counter,D0
	BNE	mt_Return
	MOVE.W	(A6),D0
	BEQ	mt_Return
	MOVE.L	D1,-(SP)
	BRA	mt_DoRetrig

mt_PatternDelay
	TST.B	mt_counter
	BNE	mt_Return
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	TST.B	mt_PattDelTime2
	BNE	mt_Return
	ADDQ.B	#1,D0
	MOVE.B	D0,mt_PattDelTime
	RTS

mt_FunkIt
	TST.B	mt_counter
	BNE	mt_Return
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	TST.B	D0
	BEQ	mt_Return
mt_UpdateFunk
	MOVEM.L	A0/D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_glissfunk(A6),D0
	LSR.B	#4,D0
	BEQ.S	mt_funkend
	LEA	mt_FunkTable(PC),A0
	MOVE.B	(A0,D0.W),D0
	ADD.B	D0,n_funkoffset(A6)
	BTST	#7,n_funkoffset(A6)
	BEQ.S	mt_funkend
	CLR.B	n_funkoffset(A6)

	MOVE.L	n_loopstart(A6),D0
	MOVEQ	#0,D1
	MOVE.W	n_replen(A6),D1
	ADD.L	D1,D0
	ADD.L	D1,D0
	MOVE.L	n_wavestart(A6),A0
	ADDQ.L	#1,A0
	CMP.L	D0,A0
	BLO.S	mt_funkok
	MOVE.L	n_loopstart(A6),A0
mt_funkok
	MOVE.L	A0,n_wavestart(A6)
	MOVEQ	#-1,D0
	SUB.B	(A0),D0
	MOVE.B	D0,(A0)
mt_funkend
	MOVEM.L	(SP)+,A0/D1
	RTS


mt_FunkTable dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_VibratoTable	
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24

mt_PeriodTable
; Tuning 0, Normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114



Dsp_Rout
	dc.w 	10,$f080,0,$40,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 	0,0,0,0,0,0,0,0,0,0,11,$f080,0,$145,0,0,0,0,0,0,0,0
	dc.w 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w 	0,0,0,0,0,0,8,$f4be,0,0,8,$f4a0,0,1,$66,$f400,0
	dc.w 	$1000,$67,$f400,0,$133e,5,$f426,0,$671,4,$67a6,$20
	dc.w 	$1b,6,$72a6,$49,$5e00,$20,$13,$56,$600,$56,$500,$56
	dc.w 	$d00,$56,$c00,$56,$1400,$56,$1300,$56,$1b00,$56
	dc.w 	$1a00,$56,$f400,0,0,$57,$f400,0,0,$56,$100,$57,$200
	dc.w 	$57,$800,$56,$900,$57,$f00,$56,$1000,$56,$1600,$57
	dc.w 	$1700,8,$f4bf,0,$3000,8,$f4ac,0,$4100,8,$f4ad,0
	dc.w 	$5800,8,$f4a1,0,$1f0,8,$f4a3,0,8,0,$fcb8,10,$a980,0
	dc.w 	$6e,8,$452b,10,$a523,$22,$ef00,$22,$c400,$20,$4c
	dc.w 	$20,$2e,$57,$1c00,$22,$d500,$60,$f400,0,$200,$61
	dc.w 	$f400,0,3,11,$f080,0,$14b,$60,$f400,0,$32c,$61
	dc.w 	$f400,0,10,11,$f080,0,$14b,$60,$f400,0,$458,$61
	dc.w 	$f400,0,$11,11,$f080,0,$14b,$60,$f400,0,$584,$61
	dc.w 	$f400,0,$18,11,$f080,0,$14b,10,$a503,$46,$f400,$70
	dc.w 	0,$47,$f400,0,0,$44,$8300,$20,$d0,$56,$100,$20,$c0
	dc.w 	$56,$200,$44,$8a00,$20,$d0,$56,$900,$20,$c0,$56
	dc.w 	$800,$44,$9100,$20,$d0,$56,$1000,$20,$c0,$56,$f00
	dc.w 	$44,$9800,$20,$d0,$56,$1600,$20,$c0,$56,$1700,$60
	dc.w 	$f400,0,$200,11,$f080,0,$163,$60,$f400,0,$6b0,$57
	dc.w 	$8600,$44,$8400,$45,$d800,$46,$8100,$46,$82e0,$21
	dc.w 	$c700,$20,$e0,$21,$c600,$70,$9c00,6,$d800,0,$c4,$20
	dc.w 	$48,10,$f0a5,0,$c4,10,$cd57,$45,$d800,$46,$8100,$46
	dc.w 	$82e0,$21,$c700,$20,$e0,$21,$c600,$43,$5e00,$57
	dc.w 	$600,$22,$f00,$44,$f400,0,$6b1,$20,$4c,$57,$500,$60
	dc.w 	$f400,0,$32c,11,$f080,0,$163,$22,$b600,$60,$f400,0
	dc.w 	$6b0,$57,$8d00,$44,$8b00,$45,$d800,$46,$8800,$46
	dc.w 	$89e0,$21,$c700,$20,$e0,$21,$c600,$70,$9c00,6,$d800
	dc.w 	0,$ec,$20,$48,10,$f0a5,0,$e7,10,$cd57,$45,$d800,$46
	dc.w 	$8800,$46,$89e0,$21,$c700,$20,$e0,$21,$c600,$56
	dc.w 	$e600,$20,$70,$56,$6600,$5e,$e600,$20,$50,$5e,$5e00
	dc.w 	$57,$d00,$22,$f00,$44,$f400,0,$6b1,$20,$4c,$57,$c00
	dc.w 	$60,$f400,0,$458,11,$f080,0,$163,$22,$b600,$60
	dc.w 	$f400,0,$6b0,$57,$9400,$44,$9200,$45,$d800,$46
	dc.w 	$8f00,$46,$90e0,$21,$c700,$20,$e0,$21,$c600,$70
	dc.w 	$9c00,6,$d800,0,$114,$20,$48,10,$f0a5,0,$10f,10
	dc.w 	$cd57,$45,$d800,$46,$8f00,$46,$90e0,$21,$c700,$20
	dc.w 	$e0,$21,$c600,$56,$e600,$20,$70,$56,$6600,$5e,$e600
	dc.w 	$20,$50,$5e,$5e00,$57,$1400,$22,$f00,$44,$f400,0
	dc.w 	$6b1,$20,$4c,$57,$1300,$60,$f400,0,$584,11,$f080,0
	dc.w 	$163,$22,$b600,$60,$f400,0,$6b0,$57,$9b00,$44,$9900
	dc.w 	$45,$d800,$46,$9600,$46,$97e0,$21,$c700,$20,$e0,$21
	dc.w 	$c600,$70,$9c00,6,$d800,0,$13c,$20,$48,10,$f0a5,0
	dc.w 	$137,10,$cd57,$45,$d800,$46,$9600,$46,$97e0,$21
	dc.w 	$c700,$20,$e0,$21,$c600,$56,$e600,$20,$70,$56,$6600
	dc.w 	$5e,$e600,$20,$50,$5e,$5e00,$57,$1b00,$22,$f00,$44
	dc.w 	$f400,0,$6b1,$20,$4c,$57,$1a00,10,$f080,0,$6e,10
	dc.w 	$ae82,0,$149,8,$e7ef,0,4,8,$dfaf,0,4,10,$a980,0
	dc.w 	$14b,8,$59ab,10,$a980,0,$14e,8,$452b,$45,$5900,$44
	dc.w 	$9c00,$20,$a8,10,$a981,0,$154,8,$e1ab,10,$a981,0
	dc.w 	$157,8,$cf2b,10,$a980,0,$15a,8,$442b,6,$c400,0,$161
	dc.w 	10,$a980,0,$15f,8,$58ab,0,12,$61,$f400,0,$6b0,6
	dc.w 	$2c81,0,$179,$57,$e000,$44,$f400,$ff,0,$45,$f44e,0
	dc.w 	$80,$55,$5900,$44,$e000,$44,$f4a8,$ff,0,$21,$2f00
	dc.w 	$45,$f44e,0,$8000,$55,$5900,$44,$d800,$44,$f4a8,$ff
	dc.w 	0,$21,$2f00,$20,$4e,$55,$5900,0,12

ch1s
	dc.l 	NullSample
	ds.w 	1
	ds.w 	1
	ds.w 	1
	ds.l	1
	ds.w	1
ch2s
	dc.l 	NullSample
	ds.w 	1
	ds.w 	1
	ds.w 	1
	ds.l	1
	ds.w	1
ch3s
	dc.l 	NullSample
	ds.w 	1
	ds.w 	1
	ds.w 	1
	ds.l	1
	ds.w	1
ch4s
	dc.l 	NullSample
	ds.w 	1
	ds.w 	1
	ds.w 	1
	ds.l	1
	ds.w	1
	
shadow_dmacon
	dc.w 	0	
mt_speed
	dc.b 	6
mt_counter
	dc.b 	0
mt_SongPos
	dc.b	0
mt_PBreakPos
	dc.b	0
mt_PosJumpFlag
	dc.b 	0
mt_PBreakFlag
	dc.b	0
mt_LowMask
	dc.b	0
mt_PattDelTime
	dc.b	0
mt_PattDelTime2
	dc.b	0
	
	EVEN
	
mt_PatternPos
	dc.w 	0
mt_DMACONtemp
	dc.w 	0
	
mt_chan1temp
	dc.l	0,0,0,0,0,$00010000,0, 0,0,0,0
mt_chan2temp
	dc.l	0,0,0,0,0,$00020000,0, 0,0,0,0
mt_chan3temp
	dc.l	0,0,0,0,0,$00040000,0, 0,0,0,0
mt_chan4temp
	dc.l	0,0,0,0,0,$00080000,0, 0,0,0,0

*******************************************************************************

** ATTENTION, le module doit etre le DERNIER objet en segment DATA... *******
*****************************************************************************

Module
	incbin 	"F:\SNDTRK\ENIGMA.MOD"
	BSS
	ds.l	100000
	
** ATTENTION, la zone libre de 400000 octets doit etre la premiere en BSS. **
** Cette zone libre est utilisee pour le precalcul des samples. Sa taille  **
** peut varier selon les modules, mais 400000 semble fonctionner pour 99%  **
** des modules.                                                            **
*****************************************************************************

Sequence_adr
	ds.l	1
Patterns_adr
	ds.l	1
Nb_samples
	ds.w	1
Samples_adr
	ds.l	32
DSP_datas
	ds.b	80
mt_FreqTable
	ds.l	900
NullSample
	ds.w	900

*****************************************************************************

Screens
	ds.b 	2*64256
L.hHWãn*r¸`.Ý­ÁßúxË[²3>Aiû2¤sBd:íƒÜÆÑ· }ãe~$M.R¦;íR$£¬]i¸NtÒô¡†¶,U]#céuž¬A‰0?	É²URjB‡U.|/ýãçW¯_ü ‰þwY¹­n…×ù+/'ØÜÉ-#"äl 4Æ½æÂÅŸ
²èaºk‚0¬*ÔTÖ9,úi{ETZ#µ‡óš‹L&o8Ï°ù—c8‰µ:6*$†Wãù|vý‡{}Ïóç=†Þ3¡rç´Œ¦ˆ&c—Dxg¯6:H]`ÿPnƒ d)¹cé\'% Dt¬¢˜	œÎÚX¤é°ˆ&uœ¦h&ÀW>ÒöÚò«¦ÁÄ³: 8ÚZ¿'@è˜m!Û¸*I=èju{PÂbEWBsy¬§¬äWÊX£V¬+bhØh{¿ç-–mT¤X3·¥(ÊšwåÑÈnöŒ|"§É¤qªBk„ù§âó7ÎÖBG¢…Y0fÕÒré„
+Äáa“¹$Áç1(±Èòˆ-BðµÎŒ’""NMH§žg	CÉÃ=ÐgˆÉœ1¸¤ð&è÷Áµç²½¹ÏôÕh—„ÔðAïì³KïN# ½”xäƒçŠƒˆ'iâœ€”âµô,Aöæ6¦H‚¸;)FbLØã^RðYš€D©‚âK	¹j >;×E¥#òÖœç±îŒˆÓ1Ùe˜º€•çÊ–+Lƒ0F»ªÄC;¿Qè	Ö­œ\óæµzûJÁ+ƒüMöj”	‚vÁnÓ6këÀ˜ ¼*35bM»kŸòrXd'"-ùpŒ¹~/*à¿CX°kºÊÍf6Ì¢ˆb¬ãßÒ›t!ôwm]©ŠüEïÞ½‹D³0•@)¢úPÚ	 ·ìu„R„Hdh„jÃ­³h5xÙïÅ4ÄZ¤Ôâ]v:nHÈ}›ûRËŸ„<ÑSä®]3Î‚ ×Èµ2ÜôùŽ4%"Ž¤quÎr'ÔdÏŽe~zEk'ÜÒQKf†ÈDæFäRÃiÌQšßL'³Åôßô¯Û)}e1„?—øû£Ž9OŽ˜°Ûã‰×Ž0è
iœq&ã÷I×ãÙû”Æ—Óo³ÅC!H ¼ Eª³ŸŸ%¸“ Oì×ÅøÓ-¶|aÊë³¿¿zÅªï˜F¡÷õ@C–{Šr¢dn–ÓË3†Ê
•tú%)É]Âa!: pºmåGÇÕ†»†RÚO^í8 ÷»þG7eçô‡Öß‡@ßîÝ†ë†ÌþZ¦°Õ¦•æKq¤óØo½|ÃÈ}>š!£ßü•	;üî±üoƒzTáÚ*ÜÔÜèír NyÕ¢r:ñÐ^rÙµk%ƒéèË(•,æ[5	ý-ž$òð—k;üU=òÓÄiÕ€ùù
¼è¾ñÓò:³â'¹Åç„þùö—x;
©±•RÉÍ"Ræ”÷ú¸~ØmÄS/ôúK±æ7Wh¾Qâª#;†aË,·<ä]÷9#ƒõ#ääŒ‡Í®æãÉ’N"Íq_y{½˜.O‘Zã•qA/ö{Ÿti5Œˆ17Y	MÇ/¡ÓtÚ(:°eÉÊ"s/ÅDe²Öy> éûyŠãOÑôßk¡Âž«v˜ân‰pxSÑôÛü2]@£¦´¬Ð˜Ï¾àö/Æ“ôöæ7:yKe!ÀU·ó÷épo¶'4ƒ06|ózvöÓðçszKãez*ºýE ŽÅòÆ6ôŒ~ÎA?ÿPK   RRqÏÿ½  Ú3      HOW_TO_C.ODE/JOYSTICK/BLIT_JOY.Så[_wÛ6²fÎñw@6¾×¶,«$%KvÎÉEQ¶Kr,ÙI{úBK”ÃT"URò&ûéïo Úr“îfo{v´&€Á`0˜ÿ@jßégçE­&¾ÃÏ6L7ëxçá:N1ÛˆÓ/ù:žþ*þ—ZÝE¼^G™ûãIðKß»ôGÃÓ8ÝdÓH<DI˜¬iÂ§h#f‘x.ê¿möâ…Xî…èY†	ºñØ–qEuÆIkL¿m"‘‡b•¥ëh*‰IòS$’HLÓå*‹’™X…¹XDÂù¡	\øŒïüj4M½t¹ï#!—Oö¢|ÍóæqK$NÃŒP¯¢$xéEei…)Üda¼Ñ:wÑ:MhK¬w?ÿ,¢D¬›\ä›Œ(šÅù¯"'Šç4eüÞb˜–Ñò.ãýÂÙÞmœÓ*¿mbŠ0Ëha&ÃÈâb!ˆv°/LòÓb/Ì–Q$÷ìG8,Ë‡@°Ót†±¶s—m0F4¼Æ‡Æ12'â&æ	/nÖY´Œ’u}Æ¹ˆÆ!öÂ+ñÔ-Ãlú¢áœÅ~abÁ§<þ!òx¹ZÜâCët³f"ý½hM«†›ÇÍ|Ž–q”I¾Úcñ°)0)nÞ)±ÛLÐoHñ0’´ÑNgÑŠ–•;\géJÜ¥Ù,:*0-bà¯‹‡4Îx+¤s«+|ƒ¶`ï‹½èó”–Æùú×7	n®isAï¾›ŸW‹x*˜än°wÆ½Aãmc$žÇ$ž Ú2…Åñ6Lî!XéF¤Ù=	àÁÿßö†ÐÄüµ”ÛX7Q wÄ"ÁmS®4öÊ/_¾|Š©']K"©œYå}ùRÁ÷ÒdJ–'_EÓ8„XDO0‰ï»½ïåè5ºšX½C Å_ë"‰×´iÎÜ˜žßxoíz¶íYVMø!ô˜y‡ãs†ð/¯r´?¾: .©–È¢<]l ®Ï:rïñ9ÝK‹€ë<¥è{o½:Ö=“kïÊzå´ðy‰¹»þ¾×9¨{^°í¶lS°Ü VŠ¹Š²‡8Údº]×~Œ_
À»-€@kÕ.ãe,)öví ž&çøôô´Þ³w^ýï÷ûIÄŸîµgõì:FÊíy†.šöÆ>Ú^¯‡æ«ÝcÛOã=¢ízDœ|uòxòn?'n±eo>§É´>Ä³(5ð8Ô—  îBœH8Ã™ä‘É ã5uÔÄh>Ïa£W)º\äþML¶<Òg­&µ[r‘Ûr…à*þ-*ìð\>;:Í‹Á™s¸{žØe+{‚ªájâ*ƒ•ÎTl¿æŠ˜\s®¨‹ÄÇ0›åÓ,],þ–Œ5ü08Óq>z/&#ázœ³–^Ž<Ç„@hL_ÁðúÈáCùqhEçjaÏ-[ÌS˜’ý>ß8m[¤Óu´> xÇ2äÜ³ëûž{phY†´ J½+ÐÒT·2Õ)¦V&ººåÔ‰¸R¦˜V6[@wÔë€Îq¸yˆî±ÏB¶Wá‚ü¾1ƒA9hÙ¦–îvÐ¬ª):çäqo›h)aê{öi‰„FWø¶Ëb6ŒUØTX‘÷«óîeð’
¶®¥:Ý
RG/ÖÙÞï4Í¼b¾°ˆõÆJên»—ûWþÃBR±‰Ž\@~ý´„YÀÖ’„}ÀÓ­˜ŠOé
îhÆ“ÑnÓ&™©p¤ýˆ#×LR@J‘Tg|Rá4fÒ¢S
/(,b¬1ÏEþâZQ¶ÊâdÓé‹Úóð;/~þùç×Dêd<aýË3Iy7x×[ä&!ÀÚ~–áo$vÝcÄQáJÀfk÷Šv<ƒU•á(ŒØ€’‡;VWRˆÀ“çR]1CRS—ÑŒ1Ïá=âIG°EÞy!´m’Vü±w[€XÝñµ…¶+‡Ï õ…ÉÁ†5ý–Í`$yuÀz—j«c6Gl.>¦Yü„êá¢/cì³u0Lwà»0"•.XÒ`o(=A_6Ç7]t¥¸“‡y%r4Ñ6\ˆÓ²k»í–ì>œIOÁÈJÍþ0m£OyÔs¾#Iªë¹õ?æŽþ9Ç'õ#u!cËßŽqÏçÈW’u!5ñ#vœnr™ù!ITù#û­Hº¦cÊ	ÚÇ8_§œÛí¥e­K)%dy”­9ÉãBþ‰Ó´œó³Y$Ñý€”ŽWàåœŽu‰bUŸr\Â…Ë)U¥ô­È™³¨Ž4xŽrGž:'ô›‚PJc”yBp¯•	X}¥ÂcMÓUL)`BÉí¨a•ºJs|m/(\Éô«È½TÒ¥'ùž?vçÌ	uˆ<š¼ó_Ìàvü–1§”ùirôèˆHÿ]»<áüac˜bÂçHo/Î£peovû@ªƒ™òà
`‚Û›2 Ñ×9>CÑÔB¶Jó˜,Ó¾ƒÃ‘i?äAæzNGÇ;w0åi¢ÌŽ ºýÁ“Ýn×'£ÿ\ÌÖY4ëšØÝî‹Ò0FFGÖÒžS!<ÎT®:ÍÂ„òô,Ba†øšäëÆv7#úqR‡à¬Ã;ª©ÔÓ£í>Fp¸"Ì<àÐð§×Hï+ç	™| KÙçÕìáP:jšt¥šÓ>"aÄîÌœÖ3qÉ‰yÖc[Òâmñ®¡óGÎ¶¨	Ú¸´ÚOã3^¡ÔBRœÖ8ýÛ¶¿CžTæm§ÕÍL†žÄä<Á°'¾–A"$	×a!¡9éD-,¢¬ÂÍ"þ ,Ë©w27„#úDì¥dvO!±¿š|@ôåà+Ì‘à¶‚¯ïÚ
_
_
¾WðRðô%áéKÂàž†$<1<1¼d…IÌoL‡ƒ•ðÿ/¿‘ pË•Í&‘õ„ùf¸†ØtKœF“0ò40æÔ<MæñýžA´)a§ ü¤"ù§…F¸Žœ‹¤¹â©,nÑ”"Ÿ.²Æß­Ý9~XøÿN^føƒ‰fÄWvxþìw^`ÌRÈ{¦V’“ÅŽ÷¼¢?¢Óê‚-Zù h}žÄtIY-#3,d–©ƒái©Ì°A‰8`Óga¦Yªê½æ½ŽAŠâÒ‰çVÍAÙTú))FÈÛ˜Cž}h7mcçáê¯r®Ý_I–zMÝß“©Íø’“\lAY(¡Jt æˆàœñŽ\¿)œÓbbãýþèü±’‡…Y+_¥C5M‡ë3ã÷0DLÃSˆ“*¯¨Wyfj‡„®Þk—AéEÿL¶‹ÔÑžÝÂ^hôXs¤mâê•t+ým½¶ôwyfQD"—}GË`…ei,4Š)Õáö–á3AøYðz2f&½“idÖý_J¡cSB}¯­eú5î”Â±Ñ
›S°Úã¹E¢À7ÿãØòÃÑãr_ƒŠhÍŠfà±ju±ä˜•î*¢âþ«@Šüø!Œ)¥ð$IW´§$jä´+— ÆtçT‚ÝÁ!Þ›"ÛŒ“)`¶ÎÕ˜c}üÍé
ƒÊ­*¥€—Ó÷šOÑv›fMZ5Täuêúœ=sÿ =s¿³5k}k¶Ýjý»MÒ«ÁøíŸfƒþëWøªÙºj´ýbO¤¥Ösê %¼H¦™YR7©Ët&Ü­Ó‚rÚŒjR‰¬mHk=YÝàKX¸`²ì‚9ŸãZ-Ó0v<´[æ¦­oGfÐa`|u=<“ÁF•™e¿ãîzÕðEîì!"––ìÛXÑ48HL:ª•ÒŠmÀ”aJEÐøhÅ¨Ë²iZ	™âRHòx‘rl€Û¦±È^&¸^lKïXñuX”oñ¾âWAH‡iqµÏ1.^Q?EòèþeŠÀÑrPå?2(†nX†°““ØâÜÊ ²Ý/5‚e½oDîµßKü”îdº²M£YDÇQûÊL^Ç-ËË¼ªá<óP»Ï=œ½ýøÊ{W®Qé&5uJ«öñ5—ånsYOÝmU,‰©W¦‘ù]WWUŒouuÍí®®*¥ÏÊæ³ù¬þ¾$U¬&±»”3ƒCpá‡‹éfA_*g¨)ÛIÕ¹×V5H÷ìj®¯ÿÈ[zæ}XK–Ä)6 /Ò¸þÊåå?Ð®bh>‚ø–vCëÄ·´«ŽA|K»Š¡ýâ[Ú2Ö£"ö¼$]/e#ò¸Ý9¡iò€Š‹G:i1¸Ä+ëÒbXU¹ÐåO”òDQÎ£ŸJ©Ê'_Öè‡5ü¶éSš} åçêxùrÏƒ¨(Ì/f¤âÖË¸tÐ/ÌËNªºì'ªô¢h09ëòš·Z!C•õQãÒŽLL’Ž9Q=àÊˆ®ö3*^#þù5•³7Ø]R­£åŠ,¾,?´u©Ä1õOV,évˆkœ0ñ|9¢ŠlTG›yTÝo¹®â7YƒðC,¾„êåXñ^*Î9š™†ôä›¡Êü*ZSÑ=¦ç\3f#ß*•|ùn‹«¤|w2<Pƒ„%Ý…¬”¨;—Ü¤©!ëêÀ,¦²noed``ük}gø¨››LQBã°¼­"¿ÔµX¸qo‡’ù!¨¡ûIù%f¡KQŠ–Y‡ï·%–îù…mZ§¨×ÈglY¼/Ý1«ßÓ‘•ÅÞÉ«nE§IO»²	×à¶.ECU
ÜCG­Ñ6Ökò½ ÌwäîTYNïVav‡HºÐE9–æ âNy¨Éé”C§j¨ØÄ±Z»c\ë+š¹ÿ¸ k’êZúqÝUÚøÏ©;ÒF¹:ª¹ùÉ¬M7%æ°”?4Û-Sõ•„Rœ¿ÂmDÝS«ˆ
›Ô<z¾<­w2æ{:¦¸ˆ†¥-`§”¾#êŽn&£áŽ¼2»Æ3‘á†i«Å’¯.a­ÁôxŸfI„å‚ÍÇ^õô˜ûdìl+%ÀzÕ{î­GqcîBwTâànÿB‰á%×)
)Š@êš¡Rç	Wr• Z@ãJ;n°ÿë}+Agš b•ºÍ7×ì^]#]edX¦f”Ûé_jCúzÍëÑÅ$x´]ïDí³T^Ài»tæÝh1¤ùŽæß¾}«MCñ0wÿv²óøYÅŽ~£ø²©Ì	n[d»{FLóoKPŒ}ôUz\­A<¬µë”2††V&·.i•<ôo;Õ= £à(c+ŽÓÑk”5+‘¸–¸$§*xu(Ž1iùlf“þæÿ<xNÊ3‘Ø•sâó‘gBó·Ÿ	Cñð?q&­âL.åÎŠ½>“v¥Ç-9×t7áéœE2/èû¹s9yÌ¿Í—¥Z£Ý²NÊRd¶ŒªBTð¶*GÆt=ÊŠÙ¦cŸ{7“RiC¿íQ¶š›ŠuAÿæèöbbúÈžß/Ó%5~$gaÈˆ%;Ô¡¨ôÐêÝ‹|ñyi©¨ä‰Å
ÍzÙŒÚ ¡<ãÙ5vb÷=í¢§Sôœ§Å‡cë/G¹ôÚöÆ
nxoy«ŠGò»Ž’G«7¦XÎ=©íR„£é>núè¹	^½-6²¾ò?´ G5Ò…ï¼ —¨ÖÅÐï^­¿…¯Ah1ž\øo¹y½Æ0ýaÜ­0ïG×oK˜æV˜àC0¸‚$I0YmØyñPK   RR‘S–Â  €}  !   HOW_TO_C.ODE/JOYSTICK/EXEMPLE.NEOå\oxåµ?ïÌîÎ&Y²›I!;üQ®I"v "<!¶¢°"¨”5@ /Ø(‹R[
{KÚúØ”¢Ä0@ÊM!Uñie„h©¬H€¹gf’ÔÍÎÌ¦OïÝ|Ø3Ï<ìn~œ÷7çýwÞóžyAÂýÈ’kÎ4õe¤?s¿iªy®%Ÿƒ~L–åE¾MÒð¦©Ðþ_8ÿ‘L7¹oÇ5:ˆ_F”+ü¸ aê‰ÏzØÞJ_qªðàÆ»°?uŠ+©Ô «/ü8U¾?\†›—„F¸¸Ê¿®¾ðãT97á‘*…âAW_øqª¬$kð>}’OçñT__øq*ØB8¼×!$ˆôuN•(bÁÿbœßàK3ªðãT‰3!ä•ùî2÷VêÖ×~œ*«€ê^öîfºy}}áÇ©b„¼OE3Üäô…×Žf¡V]÷Mæ«DÐ×~œ*&Äq`òˆ‡ÜÙÔ@_øqíÂáÓàî#}áÇ©Â€YÆUÒûh-è?®ŸIÆ}.*RC}áÆ©bF,Ž”˜>#}áÇ©bÃvÐ ë!ô…§J2a K`?~0Ð~œ
Ç³+ª°'Í3Ð÷ÿ…Ûé›î˜oàÝÇ|œP›’#Û¹'¤èûwq>¡·/4îÌ’>çúløÄ[çqƒ#]§ø¹ Ò\a¬¨¯ïßÅíñŽmÈMyþìü@¸Ÿ=ž›ÖóÂå¤X¥Ÿ;Óù*€]ÞRºÐmPm¸Ý^Jÿ»¸?-Zç_hÃ_³ âpSÖýc!òOJ•ZÕUÅë_2ûÑÑ+ÇìAþ|“?Î£_n;.¿V(ãUo=Ü í¿I™Ž¿f õfà65~,×³õQéb‘›(/9;$óúÐôÉ€·=çÝq}~¸*Ä!?FÊ
ú¸m]ÚžT ¢G¿nþ¥ï“pMŸøhÓëey9Lø=þE2[€üo÷4¹Á€_šš¡u³¢…×Ç%AÓûVä7{ZmÚÀË¸ç›j­wäÛò÷$ÛoØ¼™åO¼ðz•1¿\NSl”Ý³Èðú¸¥2¿9k?Û™]l€;%ýÆŠý„¡‡JÛûa³™wÃÎ–äøÎ;.”›‹zwÖ×»r>õalOÑn“hçõq£v\è=e€ß½UtáøÂ:ü”ÎòöÄUÍø{xœ‘!sË€	ü:p¥ÇgŽpã´-ô—¨ûKt}éˆ—Þ 3Äs‚N¨§#(èÊÂ‚çâ<¯ü½º_á$¶Špi¬¯Ç÷“Îì £ ×WÚÎ° ¯Â!¸×G§OVÿåý’k ®–*óa¹ÿLƒmú:p[RÍO`ìŠÑ=7À¡sbÆ›·ª8=yg¾oCÂ¬gïñŒäw²¡VC_.íø‚„‡q\Pf:‡ÐoÏqzró‹9Üš,€Â¶¨=×eûù±Žƒõµã¸-nOš<mÕÃàfàìÑ.²«8EþzdPÚÂL€¿­z­®Xæçë<Ì(úÚq/0U½ëzÊ6á‘¡=˜:~]À)òÈ¬í|¥ÃX}—ì-¼ø›OC_Î¼$ªÇ)wÜçèÙ•ðëN‘ÍSÇ©Äö³ïŠŠV­ev5ôuà È´Š{)xøwqŠY=´e
Ž“gYõk}}8(bW±¡qy!øu§ÈÝÏØ¶f¡—¾Rm«Õ××ƒ+`ƒÐ¸¢ÿ§HL.+ÉÿC•G(,Ô××£(„Ð¸·á?Æ©ò(¼ $}„ºžé"ŽüßáT)Qÿ°åKFüÂS%
¦ÈØxœeõ…§Ê³ð6 ûa(^Gõõ…§ÊI8€™KPz¹¤¯/ü8Uþ~+ äw´–Rj /ü8U~	âz¢d\ÃÇ‘¨®¾ðãTp9ÙKÊ¡äÚøš¾nÀ©à¡	×ƒb“0V0Ð~œ*ÈÏ`)9èDÝú?N•;FIˆ4P8F9#}áÇ©ààìb—'úì^Î«¯¯pŠ0ƒØÌ–¢§ÅCÔåÓÓ×8•_,‡VêëI¯ïëqêë?N/c\0Šmí_5°¾¿¾nÀ©öÉæ0Ùl«CLð9D»n¾E7àa×²{ØµÜòžú4ôœ ¯¯pŠXö³G™ý\Îm|¼è ý|nÀ)Âm³PåŠ™	d-XõŸ·p*8‰›G¬–+¶Çlçl÷³ºÏÛ8E˜ÃL3Á|Å2ÇRl™CtõuNŸ4ƒZ{3“Éìf2Í-ºÏ~œj?oFºíÍ¦j“ßTÅ¶ê>oøqŠDå³^‚ý‡;gö›}Œ®¾nÀ©àj¶TbÿùóŽJºúº§‚×àô“i0’XIW_øqŠÄ‰¬ˆN?SÎÖ0å¤DO_7à‰ò%ˆ2“™0ì¥ö¿ÚõuN‘x©‡ÓGÆ0¦@öª¿Ò }Ý€SÄŠ?ÙåŸûb(DÛÊŠ¾nÀ)’,ÄbPvo²•tUÍ¸h7àáy;ÍpƒœHáÄ7Æ½ IC_7àqù"/oP¸TÜL
ÕÐ×8ULxÇ!F_Ôõ`»½AÞk‰3P€“»Ã³>ÝÒ{îÄ$¥lŸ±>üw'FŒ‡Å¥ÚÕRTËë¯ßÚ¿ÈùÏ¦ZN×?P²ÈXH_kõÛJ­­)!ô‘ÁES%~w@„Àç	(}w?[šÞjÅè·50A"Ð~Ï@+š%ü‰Ž4¨t9Ïh,Ü)uKêÂ-ÎC~0éE6Â"þ–ÔK¯\ó%²eìÂû©
[ FŸß‡0ÌúuåYñ€xBlƒJ7©»Âw_S³t8'…ª¾ÓsF±§ÀU…ÜªÛa`û»›[ƒ›Üpä6<°=ò[Šì È­@”|A¥Ëy–VÜç*=~`H)ÛŠßØ=£_³ œP­‹³>Â·¶Ã¤¥Ð¤‹#Ñpƒà«_ÈvW	Ë}šöC~ïíÛ°oÁ>öl(~w¼—óJn8­ _Iúö{Û`] ì>¯³úöÛ—IÜ‡ã³ù
¾ØTz”l]€çùø}À}ŠßÄßmâµä‡Rnm\Ôóöxr9Ù|¥o¿4rúÈûÉÓx€>¨ôJ¦ö‰-¤ýæ?Uì¬€¹ °Ó·_Á¶l#Ø¼ØË‰ýÈ[¤#1d#f“¹ùÍÁö‹ÁÆ¦ÙcËèUj-ÅoFü€¬¹oC®ºGœ¡‹‹™m*³]ëXÅo*Ðç· <d	B=ö7›Tºä½ø”#Öl³Î	Åoø£cºª¦FðÀëâ,Ÿ’1Q5`åqÖßstqðü¤„“ÔFƒJ·#;‹<~M“Kq$ÁoqóäÁ'q$yjwèâì®¨¯-Éò'
ÔÚïÉÁ.Ž#}äVAÃ~=äÒâ…CôÞÀÔ"M}¯.Ì‰;ªò3ÂYâ{bîUó©:©´ß~RãsnühA«†Z•_œÓE­?wz^ïÂ-qËCã «Ç	&]þ júÿ²Ùãd+i{r–>Ê ºKß~q?êó3:4ŽÄî’í¢—Ðñm¼(›-³At¼"V¶ß$Ú,p]à½È¹ßÑ~dÛÌp]àwz÷`.ˆt‚0r®4Ü&|Ñ]à¿³¯uLí.Ž\ebõýûŽo®Ç ZÏ‹¹:zQÒÜgiO_ìòœ=¶w_9+'¹Ñ‚>#œrdûÔáfëf ]†{ªÖÌ›_º\ó×¦ûbòºPo{`™/çÏƒ
#\"RCäiøŸr:´®8Ç9ŠïZ)Ò^Ow|»o]åÉõq®sžq n)ÙH^–›1]Iõqä“É~yˆÞõž*ƒD‰?lwŒ÷ÉùCAùö[¥>Ç(È¡Ê5‹ÎˆÅéo»w¼§¨0G¦0y,®Ê?Ûuäàèp}tÅzÙ®µ@b±àü±¤zõˆÕuòœÐÜy”(·÷_ß•…ùa"Ý+º…`#…L'zIÚê¡«ª#šë¬Á¸è>	×S°ÜA“ÏÔ÷Áçx„ù´k…¿lèŒ±ò›‹Ê|ä×ä'Ïd²70ýxOç\7–“i½¿ièTÉiÊÿÒÙß}`|ãOÖà—j™%¡ˆÿÓÕs±è_=à[†	Çü¬¸Ä¼†§KKÊÑ~&~ÙmyŸãÇµ¶T`ýns'ŠŸóÁ¸$Råhí*OoåÑ;ËK›—š‚qSWµHrsOý±¿1ëµ×ÿ,»;8?<l¸P…§GûÆÿV OwNƒßa¬5Lg…ÓJÖ¢‚+âq½¿JËy6ù,šxìR|tÅ7Iqç‚q›vÿô¾×0ŸêŽugo¥b=Ï=q«?îÉ)À/ç_¬¼Œ÷OËS ,
ÎÇSôÙ`Y‹v¹}õw-gÄ¼fzÐŒË*o¿ó0mŸÎFþï/¢UEuÁ¸<æ†mzî¿/[{óy|ž^ßù{Ùo×°_o•_æ/g“×dûåk©öcçÍ8ŽžÚ°°‘"`˜è­Ðà×/oÆgÅï™2åãÖ|;{HÅì+¯Ù‚qná—‚^/¹Ž)&ãþT73ó	Õz?ä‡ï8’°}Õ[±óšãh¯5®=Î W‚ÏÙøç²âoâkÃn;8|vNå­Èçõ¢wMÂ<îšÁ+|³µÞ_À4[þ’»à¦ÿìÏ)Ï¶_’%)j Úµ ¦Wî)à'8SÖà×Ó4p|6þ}Ø=kwLÂtŸÆüTJ4òê™—¸¦É˜VSPÚëÉSÈï'¹õâè`\Ç··ÑyÅ~ùÙ_/Éæ‚çë~÷å¤Œ€y uëâÖgÊù»›;½¡ê‹%aBìŒ÷ÎM°Û³»Üçñh”û*9HÐ/]ù¬£ëq^½·93Þ€ßBìØ/Oýºß°ócÕÚ~ 6™³’ˆþý\qp×ßðö`}æÁì.×~{s“i	>çHÇC…¥åŽÆ„g,‡¸@Ä`îØuïÜ¨2à7|î‹q÷8§BÐ¬¾0:ûößÓƒã= ßbÎ£Áy„<Çà “;}^õÛ˜§:7ßS¸Y‹Ÿ¼ä”ï§I"AEƒ¿môðëý ëí©_Ÿ“úl0?“ÙÉ÷Çö±óý‰â|Ÿ¤3B÷kð#±PMÐ÷VéÌ\lÏú÷Q‡~¹ˆ›ˆ©¹ð~˜7}¿¿áj„`SSQÔÄl¹íuªß?Ø_u`Þóß&7 #4*±jè«…‡`.¾¡Ÿ­Ä¼ê‘Uã„CnƒrÿŽoá²wàÔ†ÊŠ‹¸Þè`ßöíã·è£öVKL¹‹ã÷ˆ«{¢öÇÊévÁ -~?Áç|ã{Í>Úíï¤ügòÊ ÚíêÉ¨bà,èb{hÝ½âÞ1VýÊÚ¹dÊáPÏ'GÌÍ–Ókµù9°`;èÑ‹|Ãàxô¦g4¿Ïˆßê'ŸX›mÄ¯§Ÿzô•mÍsÍÁï÷wá‚íòëÜœ’\4ì<|˜ ©Ï&×ƒ}9ËàxÛ[hM^ƒrŸB¿ùåÎ+I¢p6•_åO×Ÿ-l‡~X¿0Fú‡ö™uÙõ[‰+†i ¯¯G#ÉÒ
¯Á³¢A¹£ðÅO7@ŸJT;Í Ç¡‡‡Ïýæ»­y˜Ó,½ÑB{ücu‚$OC^dï6àç|¶Êž!Ð¬žFÏ®öJv_”xáÎ?ÕJÔnC¶î$™D;M50®rûIlèu iU¿½‹ƒÛQ£çp©ÿ|ê½SÀøŠ^ù`nyt6‰õ¥÷pÈÙ ¾P83y9BK(œZAŽ{© wJƒ‚ÞÀ¥–ÐüLë¢Mv%Üí5^×n A½­Å³›K~Ÿ)žd«BòæÛS’R.øBñ³ž´¶Šn¼øù‘dr;f ^ØŒ0Å`Ÿú+WÊÃ´?e©î61MÍ-‹ò¼<q[½]ªRÞDõq&yt!ÒT|ûÄb°jÛõ’Xˆ.íF¹Èï£Çï`©%¿Û¦År$Ù¥|ì»0¿gÆ3,‘¢qRdk8ßqÙ…ñö'„k‚[+OVE²–§—X2Có³Þc¹	C’ýX?<ä4XXi:	™Füxáð-…O…KÂA½|_ä÷å“ÒM¼Cò³4Ú%K£SJÂhS’Q»ú{Ç—¬ô$“ó¤¿ÞØ;zCI[rãÌO~=Ïšxkûé/W—I×Cñ»gHZë€ÁN)×ñ\>Ç[æÓ¦Õ¬´¾Äx]ŸßIø +¢d§ï¦X%J¼Fé,ÞÜ/â½¹†‘n…âg«N]fËvaýÊû[º8òöYÃIñð&¶¿[úü2a1>¨tF¸âö	’7¨t³ÊïÈ„óC1>äþ`ÚƒÎ¡±à’å->ý~i>Âž'"'MÀÝb0ÚÜ…ëlî‚ƒh;ýA;ÎÏ1Àÿà«åûF¶¶=(ÕÕ·üåY13£\MŸcýÖz²óàñ˜¯böq­àæÐH¸Euí|ƒ“"F¸ÓÅÂéª ~êþ´ýà×n|öz›"}~©Ã\ï§+9¶Sé¿úüØƒÜ5ö ýúôú”úü0fÑ
ED:ZZ8*¸‚ù% ÿš vkQC‹µè{)¿ŠÜ½ã+rKÖ×bßúe‚5±!Ájÿ¾ç„¢À÷ÇÉ'˜[Ì¤ÕîpbF€+8Ï³·ÊoÝ²#ÍëŠü’F$@ßß&ÖLÞ<±dMúÙFüz¯K<’°Îî_ÍÔˆûsy†´¦{]Žtpó³`´à~sµg±#Û'©yPúü2V¯ÌX!qµEª5àgqØ=Ì_ª¦‹i6Õç‡ûG—a?Û’è°gp~ og~ÿÂ¥ùý}·Tvbp¹mZû­Xº²òK¿á¼ÿ.¿ùé…ò¾þt)Îü·D=œé%ów¦—ØS¡½ÐTè¬â§ì‚+¿ÌsÁQæ[,êñkûüàª¬5°Jb‡ãò"+Ðó(7*ß‚´ËW&^ et±.?2£C×âø<Åï¨·gkØ¯?ÎN:Qö|ËD;ï˜Øo #$v&&Îô2²UÔú&Š^Ëôíç1¹qúj‰*ÂeÏ4{°ýá«ä÷ƒË=Ô=ÄÝ—ÎTWÈüXÕÏy“<Gú“f-v¬øæ^¹‹Ü“Ü÷»]t(ûÂL]~±åQuÖrÎoáÍÕ&>&x)Çï<<*àN1G ³hP©M£0$ä<ÞÍLFàfˆ^¹yb±˜'ºàNšCÐY‚n;¨°WDUp>S=ç1yb‚Ï)¬€Ýò{^ô:‰> ¸Ôœ/¸\“êGÔ2'™ZænÚ>+O›ºü*ènZAK„G`’ð ä9Ž“ŽÄü‡½!Ú%ûåÁþÓHLðIIˆ8¡˜‡ÅkóS5rŸ`žÙ'ÐB~„§8øR…dôç¢)Ç3ü¸	ìavæÉæc…ü&ãþ‚ZÅÛ„P¯Œ}>­úUÔ-Ç:]WÈo1zl5à7Yt
v¡•ÞÆÇPbÀ/ªYÉã­g¶áÆÌì yDv0î£ép7u‚¿x"æyÈüÖ‚Þi1v8IËÎJé; Iô>H§wƒS—ßpá.ös?çÆ<m7l¿{ÐIÊ@_7]¾ÚùùµÊåð¶W‘P"Ï©ÅFó*QÔâße¥æ­ÀyÆëÄØ…9är¹FžöltÀg“[”£v|óªtøµù9=qÞè‰~i6UÜ6]~³éM:›ÞÎ¡¨ÕågËwÚò]^8ƒÑv~øÐU&‹ÜÄ6(Ÿ×æä•è®¿ÛÑˆ»#HòN÷bÜ¿Ôä×6NæÀUœ_P-ÏyŒøÍ¥3½P—›œÃŽ§Áü£œ&ö&vFy§Ø®†Š5ø)YPà¬TNŽøVÑj´t	ÕhÊc+j‘ŸÃ£¨Õå—éÅœ!Zâfâ#Gm:ó³‚‰È­RîŸÈ€ís!”U´]Õ,Ð8™¬Ž(ŸnR¼ùŒNÙ¥üp‹‰*É¥ò	­Å$fˆyV–÷9y?^ûüªÆ*K	Pg¿;°Uu:WPÅµû&G{µ¨3ˆ£W"êüaºCÁ$9Òýjªœ§¶"?­|eÜÍ(‘Ï“jŸýÁ	nQ—„ã@†¼Ï­î#[­¬Ï–¤kÛg@=öŠ(&+ƒùÍjÞê÷Y•ÊâdbÍ:ûÓŒd’8øWü_ñÜ>A£ÜYjü²]³™ó'iìOãšL‰_Jmüð‹V–@ÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄKÄK„ÉÿPK   RRÐG †S  Ý     HOW_TO_C.ODE/JOYSTICK/JOY.DOC­XÛrÜ6}w•ÿ¡«¢ª‘R.Gv•7ñÖDr6v¤(+ioO[#!K4 ÒR¾~O7ÀËXro™¾Èž!Ý§OŸnàËåçýõô	ÏòÛoþLe¼
Æ6TvôöâßW×oN~$ÝÐÚ{]o*Ý9j•£sõ‹uËýéõ¯¾…•Ïï<ûfýŠÞ4ÁÙ²+Ø§,y»œ?ò&žSMÁvA“îM©›BS¥Éßû kM%þ·PA9CW×´O'Ò>p$ÚTäÔ÷ë³“‹Ÿè Æš)|åIÃZa›¢£Öâ•­* OÐŽ*EA·šTwG­³7NÕ5 ñô®3ämw«ð^`¬Hy¦_,Ü1Å)2xÁÆ£ï:¼¤GØf
M­&à#Þ†SÐ5š6N÷ÆT/Ø!díV¹ò=_n´ ŠJõ&zëÎpp;.¡ÆÇÆ¬+©Ò:eYLÄw¯èL–ËCJÃÙ´‡&ÛGg©6|´œO¡Ñ‹gùŠö“ßË!Ý‹ã<—4¼µ¼Å8taxz£$òÊ(ãAS@ëÑë‚7YŸ¼YÃÄW¹D_áÜ€±Ò8]0š€Ðœö^Ìâ~ðž9í[ÙýY.„Øª
Î²#ÈÇR‚	qÁÂ4`A­Køàrp,mÌPvžTUÙÆÏœwœ)v´JqE ×•u>å: Öz{øà\Ö½5‚ž…÷ø²6atš-ü…èç>02oUÈ+YÇ®Hxp«µ¨`¸úfoŒGª=•‹Ñrq«Š®yÓ¸ä<^Ÿ^2I.ñc7M{[~ŠüHÒ$Ï•!äBî•ŠƒÖã6ò‚B–ÆÝT'îgiae$×°6_d7Á0"CìæÔã(d=2²i3¶gkªóõhê¶ârX žfqÏKï`­ÓÂc¥C"Ú ¸mù-Á±1¡ð. ÓGVUøKÓþ×Ç«£ì+Ú¨®ô©ÈÀ»Ö3Mï«Yt—²¦ìRü-5jWäA[Bl”pÂÑƒìhÀXŒìž“¤éê’²YO$‰WËa>åð¢!ULd‡—Å„öJH9[‘Ñ›ŠQ@©¶¥Ùš(oˆYB+
³ªÈ†ä@{P¸i!0l%Qµ£¡"öµÁgFRÈ¥ˆèÛ
n¨Mˆ†B16:æfÁ\iX»˜xP¹ðPò)¹Ó±5A[JPä!•ÆoË‹Ñ ë‘Oìª:ÞØzu`Ãü×Ñ;M‡,· KydÂÎ›B	òÁ¶0V3F@.HBjncÈ]WI)˜‡8Èò£	½’„rwzc.³¤mh`(…$…TcZÛÀXL“  z|¸ó */à`àÊUÒ7¡]Í_c al7nÎ]$”>N;Ìl²Ï3Ìè-RÄH™Â°ªƒ¦ªÄœr^kKD—Âô±˜ Ö1{’ÊÅá”åRR5ì*Z1Øë­5ln1©V*zvÈ¡9¶yÖ~ÕÎÂ/ƒëp£0	‹ª›ÐQ¶»ùjgóÁÄCÑqÛ‰ÖŸ>väõ]VÅ·v,5±ÔE±›;Ån‰k—\} Ýúê<²lHÚL¿ïd+ ¹üÄ;<}²Okéƒ‰K$‘GšÇ©¨ÿb¥ÿOemûRÛDE_¬'¿\ÿ’TÀÄUØE`‡ü¬âjý.ó4š”ÏjÛëlƒ”ùá„ÅûÆ~¿!ÿ€Ì(¶ß>pþÇÎxft7äY¼‡e.6/$(!”d¢Ì‰Ÿxœé1iñ<#µ„QºL}'v#ãF8+«[Ì}.¾)SóÐ"ýÓ'‚›8ÉHw2,ž`±\×¦¹Ÿ‡ÐBã ¤®“Ô>;ìŒ¥gÓ)}žÓ‡¡ÚÑÌy²ËRê­i’‚£Ü%ï´ŒŸ¤-Fî™Ìg€ÅýA¸&É‚HTú	–ö"YËW´wœÓB™Û.µ‡/¹ÚuZ[µ–	G·WãÉaàÉ{ùñ¬cÄ^°*uï©¦±rþ¨xœ¤³Içš (yT*¤WÏ0A)ëØýC˜ NC€tÓÙ&j'Ÿü¼ëh1ÎhÌ¬ñ@D¿á\ônf&ùyÈÝ%¢®Œ˜$Î½W;ËKUÇèI_vª98£ÿ{«£ÁÕÑN×a¨œû‹©é}ÅÉÞóí]C‡ð.f BsãÛéàÖË4+tKà<ÈÉè;üY²áØ,ÏIìxó-!xfnI/g¯¯’Nü UÉ©ØÛNÓîò¨-óV¬žæ$„3TÏ|›ï¸Ÿ³±”Œ;ÏŠ_PþÃ9UŽ”~óWÎšðà‹¯a ó•x¬»D‚)’û§|~Â9ï M²Rèq˜M"u
‘ZÌÅk8ÿ®JÑšqi‚¢r<§EIlë4nñµm=ý§½âP5ŠÒ~2«R/gÞÍØüœ(-™Ê:.ªô88Ë)˜Û÷žM-Þ?ÈÒ‰äCÕ†ö5P¿ñ}þýÏR|<Çi¹v@åqåÓŸù ÇrØó¬Í'öXÿ¼(ÎßÂñ„Êp­ sçÿxý“¾Ø;z‘ç‡W—Ùp¦‘ãrð&¦8¡%£ì®Ãñª 	·_§£s~‡éð=-è‡!"ˆ0;UÉCÕjué gsÑrf»H?_ðôÜO!˜^s+ˆMóÅTó¡«l‘@"g¥áÈ!¤Ã½NÏø ŠÜ°>–3GGÛ
	Åït©Ä·ZFÎG<#ü:6"¨¢¬‚9loj¹õÂ_uñæ—Ëë×g8gTÃµeƒŸúœ«{
rßÃg MïM¸¥{Û‰½ÿPK   RRpÑgŸ’  ¼     HOW_TO_C.ODE/JOYSTICK/JOY.S½VÛnÛF}¦ÿÃ vÑX‘Ò-ê@h8Ž¦E›ÀÊCó,¹#w#ŠËì…nþ¾3{‘(÷b!v³69Ü=s9gf59}¬59<˜Àh]kïT‡ nÐ:¥;øåêÝ³Ÿ_¿ƒ^øU|Ð~‡^ö?Dváv!“¢°ÖR-°^¢s`é3}l•¼uöE"ƒÊAIá|½öZAÿ­
±î¹î€G š%ba‰à3À¾"Ø÷“áMÈ¡iÅÀ5ÿl°°.¤AkAzX¶â~€~ªµ0ž‚mD×hJû^°Çdóð èQe9»-Š	,|fP½¡/k= ÙŽÏÊééÛŸÍÑG=	)?ÎÚâè»©í÷ŽŠxµ¢qj@’­7Êf75¹©Î¦²$CmMa±“ïWµÜùRwKuãÂý‰ú·YÁø·ÕY'Zé¼Ó~@~Î=™ÄAà-Õò¸ªžOE™}·ÅQžLu<¾°qÛOGÙ4åMLÔrõ'®{òQKâX*ƒ¬ÉjÅSV”h³š4ë^qž_U%¯ªLöºÃ™-øÔþÉ^óøs>ô2ñÅãO¬¹#%Òã(üqRSÎ{Tðç)÷‡fM§›Ö ÿ¦½Gh_'*½»öMøª´Bð\þtÂC£{£·ÊÊ%œsIuT†éñ’W“{7Ü’F
Ï«Þ`ƒ’îÆã3ø‘dQx»Õ4s™Nµ%M–Ð³Š1.BŒ8ÆYN+“>ßN	¹IbcÙ0)Ë­³‘§(J‹¶ô¢Y!k,)—<±ì’1Ëüx‰I_!1ÞEÍPîìXnväïUjÑ<vc›ÆzžÓî‚R>……§}ó58¶8ÐÔ¨	…¢–cq˜õ½¡#ÏÈH±×EI]L0³Û“PaÕQYŒ74OüÃ"`>šT§£Yq›,1n*O×X'QU™	z	ª£ñ½œ`æ„k0ÏÑÄ¢qN›«¹‹âÐ|Úó/©ly ñët…-CqFP®äsƒ_Í‹= «Ý vTÿî SœÐoš€la	'@~M}GYÝu’àG•ÚŽ3vë²ˆ>™ÅäÏ*ð‰}š‚Y:Î#7ìö.Ý/Ow©§6ùÏ1Q,®.ß¾zý[ñòâíÅ}›÷{±XÜ·7ÕšIKe$ÒRå’©eSÐ¿Õé­ÊoT¿;×Z>“,áÐÞ3ºþPK   RR&†ÍÁC#  €}     HOW_TO_C.ODE/JOYSTICK/ROAD.NEOå}xTÕÙî·ç2d&`b.3A‹ú“‚PöFÉO£„šÖög¤*Ö?	Ù{2`Fm¨Ö„j+¥þ5ˆÕ¨h&Ü+ZkÍPÔ`‹ÉÄ ™!“Yç]{&ÁÑüä9Yë™ìÌäÛß~÷·¾õÝÖÚ
7Á8×p~‚.Ek.Õdë~ _hÈ&ÒhÍ•†eŽH—’L=§HÔ@ß¨Ýpí)4èÛ oƒ¾ú6èÛ oƒ¾ú6èÛ oƒ¾ú6èÛ oƒ¾ú6èÛ oƒ¾ê6Œþƒ$zðÃAÞ‡ïFª¥
b>:îpð„TIñ+¶åpø4L`Ä´l:°M£Ð€ÃglÕ2m«‘1šŽÎ>-³°h¼>¡g”ß*LhøbV[?>¥‚ÖÐÀÃ7´;ùžÄÅvö©b÷Œô0Ï@Ã—Ì,Q1Qvöª‡)¯*Ÿå;ã¯°… >#KèÐvp|Ýžà Ä—Ä¢ýQ~;›î	(™q|™-dÙY·’à‰€óÃÒdè4¶°ùÊqºf Úm£Åí±°bjTn€öY\Ë„ãF¶
¾·h ú7M·°”–hÙiÄþ2máñÕ{@ç€ñ-¤ª"¶î$Ó ŒOÉNièˆï«Ð½4èÛ oƒ¾úöÿiÐnÓ¨/Í F¨#Ã Æ§Ãðê€q€6`³
‰‚y â£:Òo6X|Ud¥jü¨Í	ýóà JR_ž‡K«¾´êï
úÀk H1‘i â(ìÙ8²ˆO›l$íX(_@yqàá»’L1Ñø5š¢<JW_™:d1pÀgÛ€qvVt‹á3ø.zë‰¦"³B£ªâÙ–®Šö"6‰Ûd%#;wDùŠÛÅo¼* ×?s/|¸ïÅÅ§`8l­jÞýøÃÙÝYÕ—5è&Ri Ô 1hñÖ3£¥‹ÝlêËñ……"CŒ*PU«Ñ/be‹¡!CÒD—X”{M­2›Ô¿é Ša³sñš—¿(Mºv‡à2æ:¬-?®Ï¥(“ÕJ˜Î‹nAßãÚ#ÓûmWˆl‚ Ô€BnxÂÆÐ,ï¢E”@¼ißG”Ýœý¹uðÿ[‡g¢8JÄÏTÊFa>ãKÃI£P¶ô7iÃùôÿ×ù{dþžy/á•…þÅM íÅÏßçåWÍgUDWÍùDRK´ŸùÃè"š~æíxA½æ9GÈÿRˆÞœ}85­‹hî¼!š>ßþÑÖ’EkB«…•ø¿{áÓAÐ{ûÑ2
óH0;£ÿÍNáýKÛOÓ€kûê­Åó±^$)±¸1ÜyUÛ¼\Ã¾ˆ³- ¯§ý‡OÒTi½DyqÛÆù§Ÿç7©z¡e
ÑºÑRÞ¡¥De@øX¯óS!¿;ñ³ßÚ:A.Ë‹[úØùxòæÎ°>[@4B¿:åÑ1|Ú˜>óØd:´o¦{¿µPžG!·¬Ó˜×ÎÇ³ùwVÝ‰ÓDc×	4½e ¬ROTÃÅHXaë?|À>¨ü	ðà?1^‡(ÛÿÒY<9sò©:½[óµWÇêå"5TãUØu“ÁÔ‰@}‡®&Z“²vAŒû|<«·Æê>Â|N•e-næ²’P6:‹D‰éSÿ™˜TØàb¢YÃ¬ÙÍ/œ'÷¦ŸlÚÊñî»ýÈýÉ\ß«òããÊZŽÌ¤ëG|qt;ÝO´/ãÈ}É¥çãY½u„þÃÓ*Þ¼âJŽ+/¢&h•t¿¡X33·ö¿üòæV>u>žÜ›®ÿÅŽ“ïmGV&‡eæÁi6‰¿l’¡*è6¸5úWúC~·ÑJU~“’ëÏÇ·FŸ¿Ÿ(%'oîØŸ<ÈÌÉ¥'éf¯É7¢h­ú™³?Ê…)¸ä>/æŽxláùxÌZ½+
2"3ß¹™ËÏªÎ-ä§õh9¾H9.loú¡9ùÍ{ÒóGns>ž'Çê…c0¿CfHy7GYºÊJ
“ÂiøPó ‹£4iLýÍ¤!)ó¢òâ†¯>ÏÜyYÖ?Ý{}mvì-? šGÒ_ªÕSy/	cx¦bâ?¿Ý<eîkvÁ-D×ÎŽÕýàÍóñœë?l–¬OœP¥®JžëŸ ¨a©psßz
õ»±:á4â‚uHªxâ|<çÚë”œùî*âŠhžôžrp$œvDÔå[ksâùÎ‰ðÃVg[_ÀüÆ>hB¾—¬‰àÓ94dpêœ}k3EU›­©º¬®ð¹÷ý¸´J¥ÖYüêF×Auâ¡È´ù–ðÝ·éöà?†­ž÷Ô‰³L\‹uš5»}CJHˆq[J8ÞHî›V¯#òÓg¾ ÿ‘‘;)·¾šÎÄ÷›t’ã­i›I³€iÌŠø!²ðÍå÷‹ÛN^€ÿ˜7B·‡{á	¡ÍF!éÝ˜`ŒšþilšÁñ€!ý›â[“’•·ÿBü‡y¤n·u<â3’ÑDG»¹Z[©s)˜Úö¿g~c|Zr9Kœà?žŒÓ­öbüQüÍT×¯%i,'
>,ØõÄ	üèý&Ë‹U@wvnˆpaþc®Nzó9|n²R™Ì‘²á¶Ü!{ð€^KÝ}^e	;÷ÂÜÝÿñ;³ŽNß¹eJ4»µ¨dõ/¡¡¯UkÍf²jOôÝÌÑ=¢9aàÓ ‹%d:ÏCÖ¬¿eí§Š¢´‘¬ Vü›>!G“¯­ê“ÿˆ}á#Ø%½Žº0?Ì.Å¸Ì.Ž€kÝß®0QsAç™‹fR”fE¾pù­ÖÅ?ê“ÿøIéVØ%ÚD'P!r»uTêvóŒÞ,¡Ê*-NÑ»×³˜"…]•Éj®Öy/X~¹†Ÿ·öÉŒxêCÜéé4,€ótÆÝù	X–Õ)‰Jï„¡¡/òaü°OþãúzÌ«›´¿ “\yÜunm•ÞD'ô^£j˜õ°Œ‘(Óy†vÆ…—ÿ!¿ë;úä?ôã¡¯º,a¿^ÍÎ£LÑÃD«3Ë„ÜÒ+Ž Xñ‚å§×ãûä?ôc°ü vYKìdÑŒÃï/iOGÁµE7íµa68ˆú´QÕlÐ¢¾Úè½ zyIÊ“`†­º8=¶‘0¥¿bº_ógrh[µ¨0}A`ÏÓ½Å}ˆ«uºðuøÒ•„Ë[óâ¬ºóñèðN/¨ï­RÇ§âô8/_}-Gn$…¯ÐkŸð	:½ª¿’ â³êòâÎÇóU-¶9?¿¤Ùú³¼µo}k}«&sÂÿNØvÕÍð‡Ûi.£ÑÎ\›ì§m™ýQÿÛ¬5jqg”ë`!~Ýy´ïÿtÝ§X	WO/‹Å½ÂÐáOßøôÌãÁ¬9?›}×3™´}îÜí7ƒ>KyÕÙå5S^ŠB‡Sãgê–Êç]©o«—Q#êâiCeZg›Ù6nÞ¸qóþ;øÐÃ7°C¤}0çÒ‚K‚“M)ÿ[…±%”ø´ôû¬›‹hö6Ý<^0Kãé
U±Z}“¼c¾uùã»ÔIwÙ¬æW3YG¬{ØÁåwUêº?²?’qÅ(­SëÉw¬ä{#Ý¾œ9÷Ì^ðÌtÚ>[·Áÿ¥cÊ†`Ÿ{Iãlõ~û
¾-È½LË?åú´nÞ,Ç›8Îºïáel	É×—ÀîEÏÓž"O‘öð¥WL;õæDš]õtÞ3>âsR Q4²ÎITç­óR?7ý:ýUC>!º²c]G¨uª1ÞÉÞÉ»â{É[­¯“Uì3huþ÷wÓÌÖèôŒ¯gÄ}æ©ŽôütºßRUs°»¡ûï3i^ù¶Ü? íÈñÓÅéâ‰Øß%T§ô7>a»0BƒøygRtíÊZúç%f;ºÞ—-,á!·.Xç-k+VÖÅ:6³Íd1Ý¹o~A§½‰[ÅÛïøh6L3äwÝ¾Q±±BHY°Í°Í wo}m_Ý±H÷¯ÒÂ<óÒiK'‹#'°ðVg³hâYšâë…ÏÔ+š¾öëx‘u¸'§…AËJoÚêÞêžL-G4—È|‡=OxÜÄÁ³Ôxé•ÆT£#hŸ¨øU{ú_~ÜUÁMi-Ú:m…2â2…LÁÂ†ÛX&Ë<é¡XÐÈf“Œ>u¿þö63¹ I`­ït&¬Ô ¶!õÑÙY"3N¾P6ºÈëB›&òúÂGß…½>¯µ/jgíŒ6šÓw¡û,ù5þnwÕÌ½»÷4î‰–'æ¨9PÃzUŒúZ?ý
½E$™£OéVºÉrß¶ž­_³ñmÓÛ¦lF¶é§&gHLybDÙˆ²£ra}kcJæ¾&ægþ«½%Ø·Åš¯pÓVTòÏ5C°º¬ÄÖÚ¬ùÖ|æ]þöŠKlÎ½žÌ×©.$ºïÿzRÄ.£“èáèÉÖrÐõO¦¿¡þ
øÑE.Ìä‰’-Ï–×¶¡!=~cüÆö¶ômÈ·• \~8ñ‰D·Onö¢›ÉeuÙ\¶³Cc›¨>Hw¤è”/•Ÿ:¾.³Pçª#fN_[µ¶ªsÃFÝŽõ;Ö;»²o2ËfÙ…mD¦%Óâ½¿LZþyøÌêÞ·Çg8g¿á9-ñŸ»¡>Ê’ª%UÍŽ/æ‡t\2IdB«ë 3®3¤ãk@&¤ÿ²ñµÑåŸBÔ“wq;,]n›Åf›ß­w[Ü:ý`yÅÑŠ£ºÅqR"ß.#¹xpwŸû‚O‹3{ãË8<Õ7ÕsV>—aðé¼¥]¥]Z»Oò‘oCø}®.W'vfÏ¸.ã:ÁÝ}É¤üõùëëýX\°¼ ‘ÆÃ0=lbšGõaß*/µë”³y|AþÛ›Ý{æƒqX§¶£î·VY«YªRæ)óø¤ëî¸~s.Me¹¦ÜWsmîÎaš¾›ÓLGò”GNÉÅkF×™æóúP×Õ+(9ðW¤]Ó°Ø¶Ø&úÎ|0/ÈÏÔ¨â“ºrlÎ:gÈæ”5	MB;hþó´†iFŸ"ñ‡€—ÁQåP"ùx4Ù«bé>‹Ç$•ž÷é¾iÖiVËYù‰@ˆZÀZ­ÙVn3²(e
º&¤ˆFÑ84´1£²£²#æë‡J@	«$R$EòH¨ñ®®yxÀ&Øú‚Ïì1*½ñ]¢`séÏâã{ë®‚~g½¥^¡6ƒ¸þÕ}+^·æ•kéZE‚ER»¢â“hhåg8G~ç5.=Õÿ†ÇI3Z»L;OýÐ‡*i–Ï)Ûe»#ÊÛÞ…E•~‰® ™[q«\Ã´`nôi~`n¨ó#ž’Ðû'µŠ­bfT|Ñ”à” âßC“Ú(#£zI`IÀsãnÚ­nUlzäèø£ãþ½kV¬š*&Ž…z®íôy$u<%—Z_v©U{^·¯ØÐ\Ý\½Øy¡øf666e¦Ód5Ý·$,˜¹xæâ ý–a/Ozy’÷¤P#ìv“üaS×L]ãÅ/ìG7ÐŒ¼7Ÿ>l®Ü5.õá§\[YåÞœ?”)&Ñ‡’Tž7OâúÇÇWèÑ¿Ÿ:fzg:§y._Æ†K}—V';á'8>û±!FÉ(…déÄÃCGH°`QÀCÌ4çjáj¡ƒéÔýº
•|´!iC’Ýw…ÛµÅµ…%kM¶L[fÈ·å£<	’\Z—–ïcëEªg"ºý‚Ç7Îï÷ZŒo2ºÑ0äÝÙ#%¿üÜ³÷î3ì	bŸbúO>Ö~¬Ý*£rtE	–-–-¼µËÖeûÀ’îõy}µžL)ÝJ@w³ëfÚd¯Œü`y»ìãÓ£
ÖÑ÷u€]B¤Ë}áó<f1„z‹öéËŠ¦M?œ »máÉ…'oÆ.˜¥èÉ·:ŽuëPš£ï3×šk¯}áýJ‰è&rÖ<ü9ŽÝôuwe)ßl[úoï>ÞU±œ§ÁéÊ™ø¹Ì=€µ$ØïùÃWU®ª¼¼|xú(ß(ŸÙS…oÇ:ùuÖ©S©F¨!ë×É3å™ñ.éïÙAV1¶âw--”•`“Ä¤÷Œ'ûÑ¬iNŸ³ÛÙ­Xî¹"4=4½|ø'C®ô\éÙÃâ®Ë¾5Ûé…'Fü”¤è«9:å©7üÅó±bÛØçŽ<o÷ýœNÑó_c¥_“+i(½ê÷G
ê
äú¿dåïÊwT°a“n™|ËäƒuŸ¿¦æššå
íCÒCR;‹‘aÍ°zÙšâøÛâo%ÄÝþ?½Òs¼ö²Ý{ßÑÕùÅ:ÝŸ^äñ³CŸ„7„n¿iø°ñDÃ|ãØ?¼°#áq_6í=úu4ðÃ!Ã!ZþtU}áÞ;W6þjô¯»7?mlÎ¦¾‘?¬²ã—)ø>ˆVùÞÕCÍCÍÎ-b<¦—eÌŽ¿7þÞÖ´Õ®1æ1æãlMj’+Iñ35~.ñÉõ×6¾Ôø’‰=ø|QqQqgC\Ú¬©@ÞóÄ„êŽê¥öº_*wÓPå«¿_"j–þù¡PðŽ´å?[ü3ûþ­ÙÏn©Ž·³aßß’°9¡Âw¯My\yœ•®(‹òDy|òoÍCë†ÖùY”Åíp;Bâ5£÷øöø”æøá+Ø
æ=Ù?¯O¨`Lx%3>ß¼cNMîœÜ¯µL^–¼ÌxÌ@ã=ã=_O«Mx*á)
JuKë—Ö‹†•ùVùV]ãÚ²‡K¢†VZ*-Ÿj¤ýJ‹Òâ›’½;èújÄ1Ã‹Ššúþ|­“ÃùuÈ¬ßè¹![SM°&è½üööôZdaµ¬v£Ïm°ìÂ©Q6{½Æämº=Øl¹¼¤}¡š/oŽUÚ«Û«½_Éß<³@.)óÊUA9(7hÒ›¦ø§ø-ŽúëÚêÛê3]nãô"r?×lå¬J—§ÈS4–¦z›¿Í‘yýÚïíNÚí“rN¾}òm÷Î3LhŒ•yÊ5å#»òîI;’*|kvŸÜ}Rvçüù2íd?–5-kÚª|¾ásš7/6§ål,9¢9ZôÜC/%½”dñípî½kï]r…mP&”1c\ŽR¢”°ÐÆçŽ¼tä¥E–‡v$íMÚë“W§þäI`šÑ¯ýªá’Æ@yöjlÔÉ6Ï}tÂf«±%eõóß«NªÄŽé¯Sk,)»ú.±:MU­‹
Z<_MÝ_ªì|egµ]\gºçƒž"FÂcŸlÖW£R>¸Ës'küÛkÎgC­1ð+°°¢ñ:ÏfÏfV¹Õ¢÷è=Af¿BX!cm8ßoiOOßèÞènc¿­Ž®ÖÚCÛ6¬Ø0Årlü_^71KÎ„-¿ŽßÒÞöãÿ¸¯iRé—°º-ï?ÿzß;Î£¢Åùó<»ä[ªŽêŽêJƒu>¾Áwƒè¾6ÏR,bõN§9×œËvýêÏQÏQ¹´jÎ§óÅê¾€/ Æn¬ÜQ‰DXwÍzËzKWpôOÅ±%é1M5¯'Y¤±Ê@eáúÂ÷·3—ßßeù2ù©OËîî·»u¹æBs¡¢”sÀÀ_Q}—¡ÈXdåš0†_ç`]¬Î]î.ùs¥Â…&VäÜå/òU¢ÞxmŸñ†5avšuåŽ':°«18©VÚi¡{°F†ÈšÅŒFn9!FÌÆÔ9r Ew%Ñ÷–žr`qÂãbeŒKBÿö³*X¬vÕ[8Ï!;t“=oüÔGLÄJ±røøDŸ¸c_ÑQÁžÄž’iÁiÁ'Á¯åT‹ÊO|ü.Åsi~ñ5¼N5áþêº6_[ÇüÉ|qTÐäûqvÂ2ã2”ÁDVRFTZ^Q!@âkwVv˜±¿íÆC­N'pÊ2é¦wýÛÜ¨öÓÚP
è&îUºÆ[‘pQ­\+ãA'òË~Ù±¯Õ†Fã	”ñ«¦¯âtm­m­ðK+ežÁúí~Qcïu‡Ø±Ê‚BoáI_¹yÍÿPðˆŠbA^ëK`v¶r{tkå1þÞŽïÃeèõßÐöG˜ÌÌUnùR¿%d	©tkd<¸…aeðÚ<¨HðÊxF±^tàWÛ:0,°Np{¼âæ7‹ñð¿b‘åëÂ
ä C~e‘ól·Ê`eËórÈK%Ôjcé‘ëòí‚ír;Ã×*|†ê‚é	:
Óþ ¹üÛßÆï[¥KÿGLÇäca:à3Ô€®ËÏæ¯âgyKär¦°‡xr|eªüN²àe ¿µ0	Ï§}ÿÓÆV~¾~€EkB¥êƒU›X%ãtBÇ9½j©t¡0›…éì 3B¾CÀÀ÷pÏ®Êòãt.v–Ÿµò@\`Ô2ur”Q§_+:Ù$¢NCì·XáD‘X r>f!övÞ<x”Û\ðmˆð9Œã?BÍ,ÇCsôÿæû›Cœn~—¦û L×Ìš™ôt{ÐÕ3•îF&ŸáÇ—¤ßât×€nO÷žÚNŽO2…¤…
‘)ä ×AÖÈ÷w2 Ã£"ôšü»LçRÞîŽ"nÓF…ì!øNîÕñ˜¨B®`ü‰«òŽF&®°U9pŸ“ß	Óq¹k¡wÐýy·ýpqºù!9Ìçò³àûCµÐ§î¢î *>|Äe°“˜~p¡2­Ü½{Ÿµ8<¤ñ¾åíž‘ú[jñ“ß„¤c¨ßâ¿zšð¸=…GØ-µà‡ÒÕ²…»`'vµìÊ]Q¾ì·­@-ãÇÜH NJÄ}%NO´ÓÔoÂó0*‚ÏºîàY|˜Jês[¬9b?
›/òWØõàë(õQÇ&-»õm¢¥Ír³áNÜ_AHõ3¢WïÓî#ö1ôç*¾þ-.1cìË„Hï}ø +UÔ{Gìi)„Áát¯ÈØ {W|W$Ü7ßŠžks}`u¬Ž"çñ=c!1ÌÓ¥´ß{/}2†ø£„ó•+yj‚bè2›ƒ«Px€1e¢ªÏ.ÙEª½`ê¸~z9øÁu÷¾.èB.v†.K‰àLƒÊÞt¬/L…&‡ù±rÜI_ƒÆC¯Ã®º ƒ¢j0þ0ŒW<aæ¹TXŠì›o•­\N•ê™D§ÓB¢ k*…Èu9]·•©t°#È·0â«¢¿`ˆÔ‹ŽEè#üB¸_-·s\!#ø6@P›ºíÝÈ­¸0$ö¿œ„å[D1½‚ÆyX@øž÷5¾iºšxˆ˜®×ëé8½=h×py§ùC*]èÔûkEžQóHºŸó9”ZÎßÏðcS˜h†	Z‚–||ÉÀâ·tà|7ÈôÀÿŽ½Û|ñÀ÷Þs0–ÐìÀu¯¬™¦^Wîá79Ìï(øñÊ[ëTà+'ú8R—ÂÅn™eNeÑÌù³ ëÁ§¿`SÐÿ<žÙÏà©ùq¿.vˆ±Ü?¾`|ïŽÿ­@³:¾pÐH&‰á:«ÁàKœß«üÎ°‡«û–[„8¢¾½~, ¾Ø`‰ «…}çúÕ¼t_¼‹óÚk‘ÁÂø¸]éZÑ¥ò{—óÃR©Å¢8¿vðcüfp—üÉ§äÎïBŽ® ›…ãº×_n4bßx°6RýÞ¬“ûã‡ü~¾âß†
ŽÒ3ãø¼¥µ…åà¼ƒ62îs!Rª:Üw×#,„R'ÍdãÐ—3>^pËûâè=‹Ê¯­2Ì¯R`a:vœñ¦NÜ9´°–7ð(ãcßh{uç;[bð ó®·‚Lƒ½„›Š•a”ù*|ìÂ?-–þ÷[)WºµÜÏºY"ìQr¡½Í”ÉõÅâ—ö‚.X¼qÑ"}±ñ\÷±”þ™Š¯Í~C}Ÿ³¨±˜-ÄL.tÉn¾…­ü˜÷³öP¢Õ˜—wìÃB\ðæ˜î–xì4}ñõ@×Hìœ´°³eß Y¹‡EA>S!!sŠ9å²Ë±Wà©–ïŽñ®“¨f©_æß¨ÕuþîZØwÄW .n;ÕvŠÏ+±B¬Ðœ?¯†K&ŸDœÝòiË§ÜîÙ´WÄ‡þ·ùó0õ[vK _/ßÃ:¢Ìáùaš€ë”°=<¾‚f‰‡¬£wXÚMˆ¾ûç®V/pu2ÙÁûçûe•æÖË#ó•Ç­¬Õù›–&Š=ñ³tà×?s~]­]gèx<îo>7ì®›´Yð÷«^–»øBÑÒeŒ ûØ¾aÐÍÜ¨*k¯A1†?1ê	îg%ÞC­hKb|eˆÛ½:çß~’Ó±:9‰ñ#Ÿ’<Žj†pb¯ºüŠüJoº$9Ì›fFÜ7”,
þPûNm7ŸeÀ÷Ÿ ¿ž5šàü£üvžËr{Žñ|L<ÆíFq7Sí• êñ4n•®vâ;Ï÷Å÷UÿÅ"tøîzmäºœ®qêå(–‡ùõ¦ãÇ/[÷Â¢Ïkðn™²…a9<È*Žˆ?¤ðùU0`ÏÀ€ñ÷Ü_Âí±Ùx_/ºÚë¡ca:ŽËÇ¡½ù5ŸK|ÁÄ}iá•žoð…Ô¡ˆ¿PÕ&ö(«"~°ç:ühñÚÕ;•ðïì¬eF0ü´6ŒO†\ÓÁHD\§ôà…ž¾€L¢gÜ †TxÛ
:J×¡{¥‡þß/!î›¸YàþŠ©q6ÂF‡Ãq€Å0Küyž”€ü“óÇ´`¼FŽÛ`\ï›Šý2c>ü§ƒ;z"øl¾QŠk²o#3_4ì$§k‰Ðm‰Ï£B¿ì;e‡ ©úðVgøï‰·Ø™€_º’˜]ûÆ	v›ËåQÜøð‹Ynñóx=ã”¨Ò?>¿R{3ÇúÅ*ž7ÿ»V½®jŸ)ì§ù¸¨O|à+D]
øJ#ùÖgôIª^…éÖr:}i>ÑkI‹ÄÉöÈ1¡áØAµÕýÞCu/
n þLýšŽ‡ì ŽiÌÁ¼<¥+0”ëÝƒÈ3¯=ó#¼_9~%3Á/5ñ3uŸöñÈu`þs:î™æàýR¶”YAçkö1y‘"+2_Uó Ê­d¶º°ÝãÏ€*m
+AÀVrZÛÅwèþwwSý¨BµOGxžw	Ñ¿Nwu!Ü§»á0ù¢«aª>¿ÎÂþääøàt ¢ ÎKž§«tªg¯øƒiA1Kày®KÇƒ¼^¡SÔùæ?>¡3Ä¦Cœ¡ï62Lz-ÔÈ8ŽGOjæùÖš®Ò‘xÿwÖÉzòö½âv542dŸ÷»Ù5N®½aºà9tö³tu>´|†îÆ^t×áý~V¯ÞGt§…ñoˆàó	î‘þ‰¸†ß÷&¹’Å žùçw?NÃÚ"kn?Ã/¬«ÈW]a;Éåþ äŽOòÈØ¨×‹Žç½|Ó:†ÓÂéÔyâ	×kzÓñ:‡€ ¬Æ²È<±jÂù6^§Që*rÿÊzF¬eC¡ííLµÓa§#~„Ëû¿q¿j>ˆê9è’ÅäÏÐqù©ñòêžzÒô´xú3tË8]jØ_sû æë‘zÏ›Ù|ÆãÈžzSZ­È’Áçã6è;·.äªŒÔMqñƒ?‚Ëí«tb©ø:Ž‡çeðô<üTñp~ì~ŸGÇëâ1ÀÇùûÀUz—Š³¸MfHóécîáXLÂyV<þžÐ|Ç"ùa$¾Á’1a%V¥c:~Ý3t‘ë~.?N‡¸
1‹»‡î^(\ñùø¥àì‘c!êzÙÈnÅDYV$ËÓpþ+;ÕñÙ„yæMãx+Áß5«4² {ñÜyyDª¬a{áHëJ'ƒŽãA/Œ'Eêœ_[?N×ÎË{èþPK   RR¸Ù¹Rƒ"  €}     HOW_TO_C.ODE/JOYSTICK/WORK.NEOå}xTÕ¹ö·gö\3€¹Ì-D$`!Þ˜Œ’c£…Jk{¨–Ö“JP€ö& @ Võ’AÚJ)=ÕjªÖL Iz‚·6xÐLêdb™Ivöúßµg¨X)Ñ8O¾õL&3|{­wë»­o­(A‚e¶ùjÓd1Ëè.0ˆß6-0ShœáRóbw’&â¥Œ¥Ô%5ÒW¢®¹1‹<xð4àiÀÓ€§Ož<xð4àiÀÓ€§Ož<xð4àiÀÓ€§Ož<xð4àiÀÓ€§Ož<xð4àéÿ&	hç.ô—áF(’ùÆ'bzE`<G	ØÂhÁv®â£"™6Uç,¾ 9¨?ÏUòBÿB:gñIú+xÎá2ê/£þ»‚vî‘èR¬d=ñ	”ˆlÙ¹ˆÏ Ÿl!ãEP¾¸ò§sß ø•±4t0~LƒÏ9x”£¿òD²ÒPàtÎ;šŽÅüwøÎ:¥²©¤UtU<A9ºhÏ"IÜ'+I€ÙçgÔvö)€ &×?ÛIøÜ%¡³‹OŸÀDÚ<N×¼ãú'ð‡!Îr¸sè/GÐM¡\2 ¨Ù`6â£nÆHg›œúË™™”Fp.‚ÙnªTd9ÚY¤AP¶¡4hB†Á+ìÊ½V–Y—[õ¡Š	·söÈ€áÏJÁcÜ.ø,EnGø{E”fuX!P	¶á=ÛéÖ ´xßI;…aò¿ãÓÈ)Bit¶)a°Cé:¼ßIwÑ(¼»Èõ*QAKû¢+þwž•2h4~fS•Qæ;†“A¡é-iÃ©üÿÛë÷¤ýÿ,á•öI ãÙ_¿Ï™¸ˆ¾yÓgÒ :¢-ø.–@—¬Ðôó4oÅê5Ç;BþH!z{ÖþìI=D³ç2hø~ë'3X/XîZ©•à{ü®ž„O„ wõ£gæ À:ÿq0;ŠÏ/nífŠ×ÖòMËo#2	ƒVØý˜îâÀ–—AÓô“®/ÈëiOÿá“cˆ¨8cËÅ±é§ây:Û$„/#Z3N*ÞwÑ* |â¤ë³!¿ág¿ÑAö[UœqÏ§â)ž=Ãñ‡¢¦ò¬ÇÇs³±þÝc“9Ð¾+aîýF# <CnùYÖñ9OÕ¯b[7ÑEkš^‰²ôõt1™V8ûßdt?‰hífQøéÿ`¾öQAìÅx
ošûH z·ò«/Jz”SˆôLPÏWá×­fkÿ-2èt9ÑÊ¬Õó‡úOÅS¾)]üöœ}]¾cy—•„²Ñ	|H VX´öŸ‹É†^NtÝ0GAË§â)ºùûnâx_½ãÀýc¹¾•êòãóÊZŽÌ*ö#¾ºƒî'z5÷À}c+NÅS¾i„ép·Ž·xy5ÇUœÔ?+´ÎAâÓ”nc¶#ý/¿âÙÕÏœŠ§èæëÚÞÎñÞ~à±	™q™Sâ/§d^ô›ýŠžý+ý!¿Ûé]~SÇ6œŠ'c¥)?s7QVañìEð?Å™—KOÝ¶5ˆ0¢£þ·?Ê…Yr·‹Ù#žXp*›ÑäKƒŒ(èë­âòsè¶a„üŒA#Ç—,Ç%üM?—ß|0gîÈªñ§âùåE&¡îwÐ©ø†á(K¤p1)œ‡O5O²8J«ÁÚÙLö ’òn š±¡8cxù©xfÏÉwüñ'ð××¤ßúm¢YÅ$½^£_Ê—ñÒñ4†¯T¬üç×»N™=ÂQPr+Ñ5³ÒÅo¿}*žÏÇùU’cs›.u]ò\ÿEßËF˜ûÚ—P¿¾Hº‘¬™ORåæSñ|Þ_gÎŸëWD+ðä¤ÊÁÉtÚT—¯nÊxämg?†•8^€}Ó0¼Î§±†$>Ñm ³WôJôµYŠ®6›²Åüž3ˆ¹E÷}¯" ƒÒë¬
~õ£‰ÐE1(*AJšÍ×„ïæŒGïh;ƒø1¬|vÆ3m':ñ•Š†•Ÿú#ƒV0Ôo_Áñ&t_µz”Ÿ)¿ûâGnÑÔ¢†:žß?*Jî¿]ùèh2Ì§»6%ãˆÜøêò{èöö3ˆ7eŒðt/aÆ’ÞªÕ—§!%8ž0EûªøVfåï>“øa)Žç¾Žg|²(h7ÀkŒ5É:—Ó–hÉWË«u|FòyWxÏ ~ü2C,aþQüÍÓ÷¯%;il'
lØ¥òþú*Û‹ k…Ÿ$œYü˜-Jo?‡ï­*±‘-Y6<Þ-ÈA!(ü ×Qoß…WLùÂv¬{?~Ò‡øñk›HÝÀ÷ù²	+;Œ¨d—ö‘ÐØ×ªµ¡ŠÆ¶¾Ç›ÄGmfnØ,!ë	xArä¿•¿›æ+ŠÒA²‚ZñÓ}p4B¡a®1Ð§ø‘þÂ'ðK&‘z`6Ÿ†úl>Ž€kÝ[—X©¥$ª¦Æ±‘¢´(ò™Ë¯\L·|Ò§øñýŠMðKô(µ¡Bä÷‹Tá÷ó½MB•U*Í[ï–R²0#¬[:cù™¿oÙÔ§ø1â™Ã¸/2Q7<€vºÓàOe~¶eEe´rò‚‰¡¹/òa9Ü§øq}ìêfãCÔŽÄÀ'PÐ_ï7LVj3…,ºc6Á3&³˜óãŒ3/ÿC~×[¶÷)~˜dB_Å|a·I_§Yn+•ç=‘¹)å¤<Z `2Ä3–_†ÉdÉìSü0Çöƒq°Ï±ÂEvÃÅøýEcwBÛàæ!±#$Ó7%¶¤Î”lf“9íôñCL‚å%©X‚vˆ&-"á:”þ–Óý†ÿ"·ñˆ¦Øóå^iòjQLŒÃ·®$ï(Îpˆ§âñÉ$èŸR1Ç'
&\7W-ÁÚH°§ÑGŸð	¢I×_IÐñ9ÄâŒSñœŽ2à›Gãç—³?Ë[¯în8ÒpÄ7ùw“·|óÄÃ­4‡¡î;Î[ä”c‰e[^ÔÿªŒ#ÆùÃw‹ÜLããÎ¡­øüÇk=ÃÂ$\>}¹g¹g—0dø¶·Í<¤æßôãYwþ>¶Îž½õðç+¯x{B6*ÎRhV)~¢n©|ÑH}Û…¸šP7Kª'E;lÎ‹ç\|ñœà×=|ÛGÆŸ^PrA‰:Íšõ»†K,amô6é7ù·”Ñ¬-â^0¿ˆžR˜"R`¼Ã™ÿµËoª’/¼®åÏŒY#Ö<ìæòûföšÿdÿI–¥ç½F¯&ÿpý#ßéÞt÷¬ù¿ŸN[g‰[â_LVƒvï"ƒ÷HHýÚñ	H¾íX{Y—ãú´fÎuî·ñ~Ý}/f‹I{ý
øÕÜ,–÷_pÉ]qËhšØVüûq›è<Yï%ªÕ‡¨ŸÉ´ÆôÍAŸ]Úµ¦KëBj|hZhÚË™'É[¯¯‘ÜöwhÝþû›³¢‰ñýŒ:y²rææÄrbö@íÞÞÆÞ¿Î¤9k·ývGNœî™îiKÏ…ó]DõJã¶
#ÈŸŸ3¸î:úŸóm.4S¤@˜?Â;Â£nš¿&´ªc¹²&Ý]ÅªÈnýÑ«óMó£®fî]”P¿ã£YpÍßµ¯ž—M4eþó³GÝ±é/¯Ö¯ô”‰ß¨)aœ“C“YÙÝ…ñó¼-+_¥)‘“ðYOÊ¦Ï„N³—Ü‡ûå•!,YÅÍ›ü›üÓÕìµÈæF³Èþàæ ?ˆ<ø:½ ä¹àRK¶Å­º¦(wW`gÿË‡*„)£ÝXo¬'-7#OÈìl¸“å±¼öÐÅŽ†D¶€d´+v›ö÷óÆ–`ØAëû;5X‡[°ŒÐ¿9G³ÑÌ2íL»“¯3%Còõ)ƒþüõ)ÔyW'ëd´Ñ–ó2ZÄ>·6ÖëÌÜõrÓÎ¦ƒå)Å{j÷Ô²“*F}­ŸžFoÓ‘Iæâ=¢ô*½d¿o%[ÏÖ¯\¸ñë;ÖgÙŒë¬^Í“µyÄª«Ê:XSò^mf1»Ü}²û¶Ysš0í@%ø|3‡ÏAlµÓ1×1—Ç­}géùÎxtW0ï5ª×<>÷O®TÊØ…ÔŽÖ˜Èžœ'£³AbÐñÅô— t#^Ÿàñ‘–<Er;‹;64ædnÌÜØÙ‘³ëmE•×î½y´?"7J»Ðläsøœ>ç‰©±¢›´>Hw¤ˆÊ—ÊOŸ_ŸM¨÷Õ³å¬¬D7l·¯ß¾ÞÛSp³M¶É±Kœ#òìyöÐý«¤r´/ÂgÓÏ¾9>óçÎ~Ž²/pûØŒÇ­,
,
´¸ÿqXŽKV‰œ@èðdÃ8ƒú0¿f¬„L_6¿NšÀñ)D©u÷ÃÒ‹§ÅÓâŒùM~»ßNÝ?][y°ò Xš!æÇe$Oî3Nà3a_ðqåÉør÷_¹"2ô„|.Ä):àC==FWDŠP„CøM‘X$z¢3®Í½Vð÷ž?uîú¹ëbØ\°½ ‘Á7”`RÝÅÒ<­çVy©]TN¬ãKæ.r.rºBÇ¿¸ûÔ.Ôý2V+«ËVVW#Òµ?¼¾ªˆ®`EÖ¢WŠœþè0ÃwÞ›;´IÍÁâ©˜¼’×
,¾ã7>˜ÌëC]×¤ äÀ_Iºº±ÔYêôDŽ1/ÈÏÚ¤ã“+Z„
Þzo½‡Ý´ªYh*Ù^Û]Ùx¥%¢HüáàãepT9”äz|0¹‡bï>{Ð*Y”ÔçœÈ•Ž+öòó !j«6çZ§…¥)—¡Ehr–Çâ±Ñ6æVwUwÝçûŽWâ–€DŠ¤HA	"Þô= ºÉ¶¾à³-ÊÉøÎWp8L'ðñ³uß„~XB!¡.—¸þÕQW¼nÍ*×Ð5Š¤7EÇ'Ñ>ÊÏü9ùB\zzüMÌ“aœq±qŽ0nÝƒ•û*÷–Ü6RvÉ.wZ¨³Š*ýM2¿â×{MHÐÛè“}À6tûÈ¤1hæÝSxŽxòÒ2Ë.S/S‘ÿîCšÔA¹¹5‹â‹âÁwÐý¨bó#'œh‰íZ½7°7p…gôEPÏÕÑHPÒçSòéõeŸ^µçuûÊ-5-5¥Þ3Å7³qaóÂæ¼š¦/÷í£æÏ,YªºnöÒÔ—¦†Ú…Za‡°ƒäÿvÅÊ+V†Xv£™iFñÛÛöÛª_¾8ûág|›Xõ®Âß®R¬žJRÅ¡b‰ëŸ_!¥?pÏÍô^<S|¹.ˆ\P3Ö‹8Áñ¹ZY$‹¤ÉRÛdóds—&Ø±)$f½érár¡‹‰úy]…V|²aÌ†1®È%~ßc¾ÇØX£Õ™çÌÓ"¥(Kœà3úŒücB/²ƒSÐ\g<¿ÞÌPfÈ®`~Ç¢YÌƒÞ›5RŠÉÏýá>ó}æ*Ž qƒðä|ÿSã§ÆÚ*Z‹&Rš`Ìþ˜9–éèqö8?´ä„"¡H]0OÊFsÐÝâ»ŒN9$c}°¤SŽpóÀ;Fþ`—€Ë†%‘ÄuA›GC½Å¸íÂ²éeÓ÷o_Ð¾ ýPNÁÜƒ6vž»µ«µKi|Ÿ­ÎVgùË?¼_i4š•|æ‡A`·þ³§²”¯v,ýéÒC½‡zó+—ðepŽr<n¤=³÷`/	þÅÌÛÜáËª—UOX;<ç¼Èy[0@mÈ¥ÓMµB-9~x­<Sž™é“þº—íe•Uþº2\¦üQNÏÏ˜÷-mûc Ç$oÄÛëíUìw_¢M×¦¯þÙ Kƒ—w²ŒkæxcaóÃÈŸU¹DjC+çèDË£ßk|=øº§rËEÏx.Óù¥çÿ‰~C‘Pf,¡œÀo”Ô—È¯çÏ}y®»’›zë´[§í­ßøüÕµW×jöKŒë¤uR'KŸ‘ëÈu„ØÊå™·gÞ®Ê¸ã?Þ¸4x¨îÂ»Þëcžzñâù³[ÏŸ÷$7¤nO7njk¼ÍrÑo_µ}ÔS‘BÚ{üŸÑÀGÌûÌûhÉ¶@ÃÂ]?z éãžì­Úfi) ï¼9wXu×Ï³¨–jYõû—±±Å£y2aB!–;+óÞÌ{L*÷··b+³ÇøÆ(1¦çÏ+"rÃ5M/6½he?}¾lyÙòhcÆ¤ëJ¤yçæÉ5]5÷¸ê®ü„†(±ÓÂK»ÎôüIýá¤%?.ý±k÷¦‚?<V“ébÃ¾õØ¨ªQ•‘{ÊSÊS¬béª´`Z0"ÿÊ6¤~H}Œ¥Ùýn¿[ó\=ngdgDiÉ¾”-e¡öTþ¼~T%«dÂûl,ãötZtZ4Óè9vñØÅ–V3MNžŸÑ8ê™QÏ*ÕßÓpOƒÇü€[ž'Ï›V¯Z_7/JRm¯¶3H»•°Ž\V°C¨‘ZÏøáËG-ÕÜ÷çkÝ0ï?ÃæøJÏ9›kÕZ54áŽÎ0Ú
ºËÎêXÝÆˆy°Ùev	GÏsºj]µÖPójXOXÑ¹@_/W¥+55¡Óöo›Y"—È”wé2UVåFCNóe±ËbvwÃµy>¿e'ZùŸëP;Ô²Âe9òeòe{sC¬#ÖáÎ»~õU;ÆìˆÈ%…íï´¿ãvã+ˆ±UÁµ†µ»ô'ÛÇlSY]²£}G»ì/üÖËô,û¶´¸yqó&åtø†ßÔRÚRj›T¸qÅÃí®çÖ½8æÅ1öÈvï®;wÝ)W:×«„UÌ’Q¨¬PV0mãs^<ðâ]öuÛÇì³+"—gÿ¡1g†qùEãùMñµß­uR”UÍ~|r•ÃÎ*þªš1Õ81½ô5jdM+V]þç;âQkàHÉ]%áà—@ÓÏd+ÏþùÙ—gõîgË	O|VeªVÓ²>¼3ø#ÖôÖ_¼ÞÆ:Kü<aaeÅ`U°ŠUo²›‚¦ Êœ—
K…VöFãÁÌæL{gNÎFÿFûUzÍà£K{Ê¹aé†Ëì­ß@zÝÌì…“{2ó±ÎŽïmøïûš§V|ÙëÇòþõûÞõôØ½?ÛÓ¸'ø²|kà xP¬Pë÷|zCäÿšl<KqkðzmE¶"öò/n”+;ÅˆQ=5"ñH\Z˜¾±z{5ÂâÕëíëí=ê¸xÂžð˜'5¼žd—6¤Ç«ãÕ×o¶û·û½ZF^fOfýËä§?5ÔZ îVw»üb‘m¡malŠT¸'¶'VYs§¹ÌRf9Ï7y<go}ºè_ë_«ÅŠ¤…{î™RYxg¬,VVsã´:âyÓÃvá÷†îæFŽ±ø%ÖcÂÞö/±ºçPÌ¨ûM]¼ ÏØU{2…¸WKÜDCCâ1ª¨râ‰ybì¬G]Ì•™ä»|“Z'µ–ÃÞó”ò)ø÷¢Rµ4€3%1xÖH¸û¨|ôÞÉDWMñtÝ†é6ÖÂøž~ Ž¡_ÕÃøƒ õ¬žñ¥#{“uñÐß¶ Æ©û¬®×€GX4—æ2`OOëÕzhq×â®6œYiR›T°“—ãF„¼à3cniš¦ó}
>…hïÆ¦x:Êmíìä[ËÔ î_Þ+3ì/“§Íó±G›¢íÝ›^bQý·"ŽÝ1'î«yqL°gÝ›ÄÇ–á.®ÆuQscÜcÕÑj¾µÈz±ÃdHÞúå8·3!?e->#ô…SùšÀW<+TÄõëP»ããOb ß£ÝÕÚÔ¸åØ´c¹ö˜$×ÉuŒƒCfúïPã6Üÿ!vˆûvc("üŠ¬½í%ú›+êâO¢éãâa~‡ºŽ2Õq=qO:>á‹øÞgjŽ3É—žÀ­Ë]“ßJmÁ¼þ­Q¬®ºå¼y¸˜}ô/¬Ø™ñp­•2&ú,½w8×Mö""/ú‘ÿ&G½øwoµ·Zÿ>Îâ:þVÖªãU™*áþå¹§™‰5°†/ã[ð†Ü…z±_³0—ß4Èãøkb¹šÀ¶³ˆðJ7¿»|Ë*|¿7Œ³’ÄÞa=Ö"¢¶±Åú¼t3=eŸ1f€üŒcäšõ`‡òb‡Y\á8 çƒ’ø ç¬óùE|¦òâ°çSO—.çY2«šU£Jô+fb±v¦:Øn”~-·[¹¡¸DìÖûäÿèÛÑ¨ŽïCàÃ{ËGLs¡§u®º”6ðùBG^ƒ>??2 ãÂÿ˜… Ý™âSR||Ûä˜@þe‚'Ì‚Ñb&&ãÇIŸEì“5êèåø?Ð÷3¬cèÞ2¦^ˆ³P¦MˆòÏË®„}a¾?úS³šqßÕžjªJØÃSÎ„~;!w˜µvÕ‡ðá«ÂX#²àþº¼"Å8' 7Ë1'äæªqE2Àç
»ÂFàþØÂ,ã1?Ï¼f³D‹Ø"fñ§ÃÃtßÂ¾à±¼)Éï´ä‘%ë¿Ë÷p9½¯'ùÎxYÆEÇñ‰Ø³±<aÑ·]Ç\,~d)ÛÅ½kšæá~æX>«ÇÑ(êÙÉL¯µ? >ƒ1¾sÃ3YÝ@ðæÀxå‡gT)>äeÜfTùyÇ×ÌL{;Ï/Óä‘˜ø©eš|ëƒÀ¸¯Gkm"ûá&Ì@ßZøÑÊc•šî§aGü$ÕA8lCËRÄ?° kå5ñÇ€[€¢MáƒŽp½÷1Ÿ~÷¼Çt~P@>ÏÇñ¥ø>õiJ’OÀ|ö`@^XìÆ8iøå@w\“&E^ ‡Rø¸ÿÉWwêÏ‡r|üö1æAÁ€Žq|Ž„Þ‹ïý•q?¦.S—¥ä5|Vfe¼¸À?ÛÀw†ÁûÓñÌ×mMŽƒ•>øze&g@ÞEl*´÷ªLNFùM9’Â7×ÿ ÷ã8ÁÆø_¬éÁó~Žòþ9¾·Y”ãîž¤yx?G{Uýà$÷+é¸…/™ïaãrù|ð!ŒxDàQ“8S|£îu•)º?©ÓïGãü\×¡G®GË59FBÝáºX
_r´M=­,')?cðÁ®.Äõíuèß¡ûù¨ G*b~÷hª–7ýzdÌ×"ß0ðE<‘SñAîc.q]éMÎo
Ÿó{)V'à¾  ¾wæŠTÇç˜A´ýîÎûuû@¶¼~ïQïáÿm=m‰þ7ãD
y/ùR|®ÒªŽë‘’—ð¯ÞŸã3~™¾C•‡*ñˆ5kÍÇõR_|r^uk"ž2}~ë€oôîcWOµ×ý×Kb"ßàsÉë=÷K©Ž$¾”¿¾ý‹#ŒÇ¡Ž;€Ž\CÜt…i’?¡nðñÓ1,éŸˆ÷0óCT!b‚?)/Žk»«“Ç±×°³—;ìåòº‰èÍY]ï:ÞB >œ¦IŸvh|.=|~qÁ<[«-8¦/Fž¿;}.‹ýéDz<Þ“óœ©GÃ4èåy¬5€ñ÷…–_€~pÀgùhîw#®È#c4Q2FšVÿ'øá¸×V€O[®-·Ÿ=ÝÞù(ô!z8Ê6#_úø*æ¹ýzÄã½á½ð[?-úÚDdÌáº0séÎúÜÖÏYµŽ—’—_½c?âY÷2–}èþ&Ö”‰æ;]ñ®k°gwGî²ÎÜw;òg®çj§zÉ¥˜‡è¤èÓw½RöJYŽ’°/si"MåÏïc^Â„ÃåÐ£òœòœ â^ü ôzŸÁv~ø#¢KÂõðo>ÙR}!ÎßþÛpLõBôÓÐÞ ‚îf0Ç’D^ÁãÊÑ·ÔhùTä¿a9Ìóç»1®þ£GUUÏ‹Ùbö>ü¾
{|]‘>3¶b`¶¬ó¿øàâ–-À¿.TIñéùN‚áßó[v²œ	û°"¿¾áÝ&fÔêÐ¿ðÜpŒÒB~Æí@¢Èýswƒ^…ûî¸öHè3×¶°Zìêãü;âOÖ£û}ÜPÂÏp>V›äƒ#ÉÇ8¯6¾Ú–âs!qélêlBºH›;63(ŽìcMÅð_ï¾Ò¢Õ3j$x+¾UÑÄk¡ºÅ¸u?ÑbÀ#¿ÚDmÏÓÞ{5¥ü½'pr,å_~‰÷gÔgÔ ðkìó|cåÈ·*Ú+Žó¥Anm®˜ëgøü¾žï_Ïš°û—zëzsÂÔ°‰H¬|·BßhÀ&ÇgæýÃßäÞû(â‰’ÀÇã&ÜFˆ’ã¬BÞXÙ[ÙKŸÃ÷w|½I¾ÏNð‰^ès2>¿Î+:ô|óCþ,‚Œ¬²ž.ÒÕègÇôúÎM%€ñùeXàY[Ã<ÀÛƒLjÞÌÉ<6W‹Ku©©q•$Ÿx2_<‘ÉY"öXŠÛŠøÑ¤Ýt zœâ£„>”#<êQõã·Þ²Ìßù:	s“ûÕãôÕ %òË.‰Åõu…11NNjÝfHÄ±Ô:ô8ÿþÓt¾fð%ñÇ/¥H`ù_hŠs|i	þ”>v»4¾½FÁƒzüŒ}Ì_áÙåßU×U›`ï×ßHÈczTcz>c×ìú}òü=‰Ç‘ôÏASr½|ç	|¶Ä:×ù[êJÈç€Ì@Ã½aæD¿µ-1ÆùßÉc1®Ÿ3vžìû©Ú“üê“TÝOùsS²ÿx*oNŽ“Êéc¾ïŒ"ü™¥Ý¢šÐ-qK\A|êF|JÃ}>g³1ß—\ò ôH4Á;ëkçÇƒícû†“ëSEÁ2§‰o”¨h~Èµgôá»X×¼ÇÞÓù> „×±.Ù <O¼[ÝBÏÂŸò¸{ù—…üˆÃ/°èÃ~2>é¯Öúó‰¶bþÿ«=®ÛÑ/Ùû|=…å3³½GíQà—&ûD(*ôV·'>¿úõ<R·†DÊ‘
¿ÂãEÙ´2no2ÆùÆp¾‘øü<‹ÎžÛniiÁ®/±Ç±áëìíÐ¬ÇêþÊ¢R>	·å·½\Íð¼áKåÏÖ_"a<¯?,c`ØÕl'÷·19&§ôÏMI¿Éój„¤/ããëpnìßYG~SukßÇÀÇqÿuø{ù!ÖåÆu8É)þœçW™G]ªÂëUÈ¯x´ÆÃöÜ¦'ì‚;\LO"¯CšÂÇÿž‘fÄ‰Ú$ÌN_‡$të ±§‚Uf N¿5óèºŽc<œ›#6u‡)É<€:öÃß$ý“¸až—ƒŒÄ>Uá'Ç¡,Uâ÷Á×©ü>¹\‚I!òúÛuIŠëÇ=ìžß_OâÃ„íÁ„…vp}€Ý«Ÿ%ê4¯ÓðëÛX[ºƒæ~«ãdá=ë¾,M¯£Àáqù†Þó¿lñæ9åùÆ¿€Ø˜ÂÁý—ÿ<ÜW«Úª*I>ý¹Rá9_ÞI| :¯¥•‰ÈC¢ÈCx=¬õ%!UçâóýëÖåz?™öìí]sEKÊÊôørHf9àw¡ …å¿^/¤äýã}=)$ë)<"ø-šåxs2_Ws’¯|ø^ÏœòyÇ]Ž:
×:Ý¿B¡xýäqµZMäÏóla7oâÈb6ò¾é«Åy”'þ\Ý{þ}Ò“X07‰ƒ±{$ò
MÒ¤£bB­¦„Ÿqç&ôìAð)¯):ß+œÏ¢ãÑõÜuØÅ”+‘w|Â:F"?›~DÓöCN·r\!WLÄYÙåÚÿPK   RRdM¾Ùa  á     HOW_TO_C.ODE/POLYGO/ARTICLE.AST•Y[sÛÆ~.gøÖO´f(TJ·ñK‡–…‰Dª$åŠ}ñ¬À%¹.ô`äüú~ßÙXrÇešÀîž=×ï\Üï©îçööß³ÙL©ky±
_WWWõÂ”¯ð5Æç%þ™qk—À•<ø…éT|Çaµâ‡y{8Ì«§êÕ»É|çøñî«æ¸Pxõîï9Læ¿q8¨ŸÀ÷÷«íÓÿùyA ßãj\ªƒ}óæZšD™¢T‰QEõhJµ®Ôc^¹(Š®M¡öyòe›g¦ˆpFIîŠáz r·jõ¹Ê­Šµ*Œ+£q¦¶&3N'CÐkæòÁd ®³¢ßãšË«ÒrimÔ—*¯øã‡Kœ«œÚäY\Ú<SäÇ¨ÒéØ8!¹¶›q …ßýÞïñnPe* ódRMóªP:É3¬€hTk‹ãº¢\ëÁ®²ªÊ*5å.ça7©HÔl66a°VÂÝ¸¡–FE¿%kHßëAiµw&¶²ßû\ƒoíJC«TnfŒMð¤åÚwV\~ÑTŠyÔÂÑÞ”¶4ààyo. ÷º|ëtšjÑÈ»œÁ4*±¸U:Žót¯·Iµ.™B´—ÙƒÑ•Jó/&ƒU'‰ÂU<“»U1dÛºj¾6Oh&­66ë÷ÖS:ãõÂÎì µ}HLÜH]Žêvv½ºšMÇ‹¡ºMð<Z¨é`rs;›/±ü¯»ñuk“‚×½¡Âº°e	WÑµøSn+lº‡¶ÞÂ']	OiœÞ[ì;`ý^°ÍÚm#ZÄþ°Dc¬;žx1›~ßGw¯9äßÅTmCÓl°ˆÐP%þ–gC¡ZØ~ï@O{Ìí63bKõŒ£6+a×ýV0b£$•=íP‚ÌlS¨¸ßÓªT±3|ç48±[]æÖ™ÔÛ €nˆ¨¬ÙŠ¼æùÿÅìæf<]ªÙTý2š,•×¬:}ùñ¯®ª¦!)(­ +à\ÜNäãe¢?:•€@¿w=R·óñÍd<«÷êz¬–óÑÅx®>NæK˜Z]ÞQ¡ËÙÝÛV†¥†]ë¢€â‚IÛÑ&Iµ,v¹³æY©¢C…80ÚòØ¬½éá…xò{5“Åµç–`ÌrqàÚ Ë“Umª
Dt:@Ø%jªÌC1Q`›".ÝÐóï46¯Qj›Iüºß‹s Dže0ó=Ù]SÁP‡Ÿî®´sVá³ˆuFÿñh	·C¸ÎÑÅ€Jô<™D{‹Ú*Ñ6ÀÙNW%EøŸFê÷nID,^ÐL¥@gÖ¨èè»¡’«åUà3ø¿ømjÖVÃ›…HpûH.*Ê<~
€~Ô€¨/2Ýû‚§6KÒÕ3áì@Ìé~¡^wÕÒ{[š G  'WVÎËp4„$=ØðYKøªoõŒ!€cns0ÎcÂ„uýw×W’\[²ãDA2ðAgS¾ ?˜[TkEHÉKZbvˆ­Àøhþà øˆï”2Nh‘¡OŒð9@-˜g#ˆûÉï¡	D2J@Àí—Ä)1ÚáUD†²®dN+	­í÷íýù™Z½?ùÝTõ†3mµ@ ·çg'jˆëÏß‰ô„R'éD*±_0‚øí%äè„åwxkÇýÞJáµM«,„$žõ3ŸYÎÔQ(.Ê„µË-SU›Üy4OL£]ø4è÷Þ2eî:åÒÍdŠgÊ°/¸#ÒáýÍèž+GçòÊž¾òiÚÒ{|+™Žåz_Žïî'ã›€Þ€òÛëÉb1ºê<-›ÅÀ©f8‹¨`/Ñu¢lÕ‰­Dw¡/0"ü¯M“£iK?¢ì Hîu¬iŸ}ìkòp„W>‰¾‚#ß‹Ò‘´
&rÁ×X€	t~®º]z¾F‰>²M&Öj×Ëu4ý›™Yýg¬ èådz½ž¥=ÚŒ&nrC¤ÄM­uí9Ï’r½uòAÛ
ÐßAº(úõîßÑÓúÉTÁíÌž¨)5KS×IÇ©Ô oQÚ‹³ÖLp3^É¹ìó(Âµ[f¾ˆ‘ÚÁÙ,¶{Ý­ú‘@'6‘/LÆ¬sMÊ:=AÁÓ†žC„"­<è¬Ñº åç
å	*š”6s(Åäþ­ÀWB™ÌAÜ%ÎÁy\šZ¸#8æÒ>5…)xþj<],£ÀaQ!î‡-¬àæ(·ãO“éd¹¶£ãÈ7€4¶ä5y)­‚NâŠë(p­¢${&5Á h Öõ¦è$”8Aqíï~ÃŽœ˜ÆØº-N-#%ŠÒ$.Ü–Ö0óå§Ò°Õ2otÌ¶(ô6”›¾ï#'Í6uóû§ùìn©Xt5”áêHØ‡Îçý^»ák“gE ]dé{¡£ü®ñÁ  ïØ{ SH¦R¡¿	!*ùí`½äŠPwÄ#o;vC_&¡k|™êâ©U*hö;)Æfs5¤Ê°	WAÏ>8/ÍC’Çõn‡—‚¾w1¸ÌAûê ·­‹oQáH@¾uyô59ƒäZ×Ò¨¨iX Œcc,Aç«šhœHËÑ²zC¹j´â»PÐ¹¼yãŒlÿä‹šê€u@ñrÀ’ Y3o|(…|]Â®¾Ž6®Ùa€Iô¢xù:kû,uE;ÁyFFÉðÒ~¢Y¯Oâí­¯“fŒ„LÜ¤Ð2• ÛC¹´Ök;2|Ý^åyòÆwoG<TþìÑBQ(ª°–Á…ÃyBc²{5lT+n¨wvhyÀÕf¡Myêeq2i(|óå¯ÛRÔf,Ý,U
åx”!~Ê[°„cu`8à3ÃÿcnÙ€SƒRåsNQ´9jÀT\rŠ$c ›Âuˆ™‚ÖC×VÀwv†›½î9n ¨ŸÎÎžra$ Ÿ´&HK„ÓV¢ÛˆØ,¿I÷/€H¢‰>B¢wÚÇcÂb˜„‚1¤u‚¹OrÑIH¡ÈR÷!«Ù¢™ì”-?Á˜˜ ~ÁÞåô¼S"½HÂ˜~øt;›L—çp_U/ªÛù£3`ÁÂž—2ÇÖC6¿­}›9H@Éô¦nä‚Uû½B&WŒ=»­ÄU‚ç¦¹ÄÔ[ÆÉàe’oYFœøâq2«:˜ O[9£1„ï9LÚ‰~Ú3›ƒu˜«$Ái_¯ž Úõ .ö$Æ­¶¢]T~»ç«§å­D<¹þr­¯î_\rvÀ•ÅkbX¼"¾Öö`íE ±½/—@-çH’SB,òÍ¦`'þ6À’^¯­/“š¶î«®îxs»Aê$²‹À[3“<Î"ÕK‡åM‰E™áC¤=úÚ‡«¬ôd&Å©Ð©xÑq<L¼çüeÇ,JÔºª|ÁÁ[à4D3Rÿž¨F~7åûƒ•B²7AÅšqžˆ’}‹Ecæt;—~¡¹~[ÌEÑ¡g•M¥Úbæ¯‰8Aü%Nüè
¶’¿
`ék´/–dòCIê&T´õsY S=¨WÍ6y#§ç²ûáíûÊúÜ÷‰2(üºpöT6}T‡ï³cjNn†¬»½5•ª¨÷aZa¸ UÞI¨˜á;Üžú€Ò1UGDþñÝùßÆ±×ç¨¢Q±þ¾šŽ—-–*4*þÍéèÃ‚“¢e¿÷¢70^¼W·wÔ›ú»“T¦’ñ±@¯Ë¤Ta¼?¥‚êGÚ™Ì/æ£Å¯
1üëÿbJ¡A ž ?(7H¦Pe"CW¬?ÀN&;`ídÚ³¶
/õ¾ßû‹|Žøç¿ÿ0TóJˆ­uµß!ê¥w?Ÿý¨®W³©ì¿PK   RR%Ê#Ïj  µE     HOW_TO_C.ODE/POLYGO/HTC_POLY.S½<sÚH²k«òf+®ÛQXI€qœÝ»ÂFÎñbÀ°cßÏ%ìhƒ‘ÀqöË¿×Ýó«% Nr¹£¶X<êžééßÝ3ÊþÏû<ûe_ü¬Ï¶ÉòlµLç‰ˆ±Èf_î2ø=ÍæÉ£ðÅbÍ¿g2ý9ôÎÛãîñY(FãÓ¤Œ>Ó,Nb1ù"Fï®ûáøUûx4¶OÆ?4Ù÷~p²Ÿ)M¤mÜ>¾8Þúb4¸‰·a4G¢ŽŸýÒ;=w’O+gç?‘çÑP7¶i~¿ÜñZzð˜¾–ƒ£ä­d¾/{Ò¯ëAÙ¤ÁË!’kÛ'|P®=>.Nd‡Þ*H>ø¸sÇ‡WcüõFŒ.ÎÃáew^éÑt–×fÎ«Ýb±ÝgIí³ó|'ð\=¶Ì£…ã<‡™œ(Ž?ôó·XÀŸ4_ûâ2|ÛvBÿ½Çí±è\€rÒô“"wFíËðfã¡$¡biŸ‰³p$úÀ>Ã_Ýþ8^œ£ôFSBžÝÐÃ5än¿;‰ÑyxÒmÃßv½óð†žáÈûvw|3:oŸ„G¸ÛûEZ›Àþê¯]©S/¨}FÄyR+mpûƒè/w½íSh$b’`lmyž$:oÄ}T|Z%b–"/“<_-–i6/_O»}dãùðmM€BÃ^8dô¢Óî4§øô¬-ÆCd¥áÁ0CÃv§$Û:!ŠY4ý ‰ˆæÓ4™Ï·‹üÏEw<‘†óáàí°ÝëÉåIäxÄ Ò”ç¤r?Û¸ŸðãÝyºL£YZDH´uWE´z€í½H–ÑöE@ÉW®föˆk9)Ý0|Û?	¿PÉÿÑ=%ÍtfÀÒ†ÃÀf¸Ñr7Šsôþ“¨€(°Å‡ôX«Àg55×ÀìHÒåð—–àÌÙöÜØ³±çîFÍ½—8‡Þ±§žx0Í£¹U…{@Üixj²W-6ŒÒŒ'\ —ËDí¢  l ¤d;râÊ$‘È“"›­PHkœ-{ ½·²yuy|¶NxH¦Ëd•xÊ|ÿPa½;î0¬ÄÀÃ¸†Ÿ8*(ŽS}zlŸ¾ôÍŒ`ÅÑ.côø|/ƒê„½Ò„uzÿ¥×ªËmªZÛhÀÒy±Œf3æ|Š`Ûí£ä–¤_q2€Ø‚¾¢ï°;äÔ–Ÿïøw—ÀÀ8)¢é2&ÆêU‘­òýM<E‚ 9(º)¨oºe÷¤b""¥óé$KHÁ’‚“Ñð\#Or€	Š¯@ó,‰Ð@ö4$üôd}2‹Ò$ÿ­—Æ©Ý$ÄEPÂ›a8vIiG§€ð@<¤”‚îE`>ó8G*–ÙB¹dG’&²D  è6J‹i­Dü"ù?Ý¦h4ÁÁÈC
| úãdÍ¢;úE‰%€½çQÝ'K°8A¦_¯aœ1VšXL2%{=ŽŠ"©Z­qçw!& ÿˆ+$n¹Ê»lšvžñ žgÂØ8:†aÿeÐ<€™×Ñ…n$KÞÉ]p7š/!Á½_ÐÔÖMBÆt³Á/okèÆ
LžZŸº ® ôŽôo³Jñ-6ÉŒ’G¦5 –Öˆ­@íþI7ì÷µ¯mÚb²Õ|`£Æj}´
Éü K_¸a+æ2ëã®ÎxLfuëO×xLL›<{±Å·—É¬“Bß0•oÚ¬¿µBùOuÓ!~+mÏÔ÷¯…p÷ö˜áQ,ÞÍ™-®M¿= +ÁÓ€ñfŒæe2Åš&s]‚%4D›U¾!f³,A™ïÜŠG±þÙ/cÐé›wáõ‘Ìz—Åý¶ÍÊ¥FO’O•CBV‹X(’f?É# ÓSâŒE…·'Òlž^KW<CßýL¼†bsô!û,zÙªHX,9,…>¹9ûÀE›èg² TÁ-/™¿­|¶$´”ÊòZh_La]òCñ‹øÉh2ÃðM	å2©€ÈN¿ÀåQí¦"(T
ØçÝ\†£ˆJe ð¾9ëöÃp¯nä)­ÇIÐ@Ô*VÒÊ	»‘_‚\Spð8þë×®òîóì~’K0"äÔµû70½:òÁ"<™	Ã.!Ñ™æ))»2¡HøI®¦PÔû¨Øþž"‡žˆb•> ?$žÜ¢¡©¥ÔÄy2ÉVSˆD@ ¸ÍÒB²—u|,§gØjÑj™½ºKæ	FdÌƒâýý¶;í$	£‹îe»O5_ÿxˆÅõñÙà„ïn Ø—Øß>=u£À;|CÏÖ…J”(
îÕ§Hu¤ëi÷;µ÷àü:žÛ	8Ì¡ ñ‘84Â<î¶½RÛà°‰`A	,X«ûßëÖ\†Øñ5²øö	É¬œ<âì§U*
ÒÉùõ"º½M¡‚ÍÅj®¤*ÕÕ»sÉ ä?Ðmwå7k$¸Õ<E®cpA~ÇÉ"Ê— “å9˜$¤5\Îw¸{À=…U‚Z€èRT'EÝ"yf_êa‰§à!d
ø¥´1\=ML^9ËýŠ4-mõ(ƒ`­˜ô*]¥ÊnX¶«ØS«ÕûmxÂE4eÐ ©h%´hÊ¥ÖHZM‹J>Ê©
ë_–U€¢¨5FÎ7I+xJXÈÍ×aùØ¸®Ü?Æ¶m2r+³òÙ7Ï ù_‘Êv¡XËß&Æeé÷‘Ñ.HÆú]\ù£ØU¾‘Izbð­`¬§Ð’^|BòÐnè•/Ã<¸*aì]!~B–Ç) ”H3%7vCF¥½»šUÊÜü“	DÎ“Öm†‘	ø)ÉÛ¬7_S×­Ö`/°Ô„
`*oJ*7isÊKa“±WDg‘Ì§´QàÐÍdöñˆ‘W·+¡^ÊaöœsÜKJ
F½^N,™ë’4‘( Iƒ,XŒTD(h(_UðY-sr¸M¬©g'™¥È¤Õ¡ŽfÛÝS¦ËEPaizC¾V*òàJYK[kVdT&šOèª
AÞšÄàµHÕ‰-×(œ¢ ä‚Qýš2Ô§R2Òl™ƒ‰+ªi!OTÎÒ#g‰gû›½$ÕÊeû…‡+˜`†C“Õ’ç5•]`BquÄ²‹+%<±›d2Õ¨)È^{ôŽÒ?cFÃÒÛ[`À|©Ê¹ZÉ¸MÏƒÙ÷…¥tr²Cøöª†–ióÁ<Y,!³ã5Œ··¦u›v…¦:½=nÄuå;;B¹‡6Ø²yI€{höX]#E›eéÜè–ïšÝ}¿Ú¬«K¼î®µä.ù€ûÅ•x‹ªw“ó“Ì·Û3	Ð«
PË@×DèTsùDwYQ¤°ïmBŽ£9i‘ÖÓuAÒÌ`ÇóØ˜dm]’fŸ%QªÈcí›äW¬6,GèºR‰³H–)˜º’h6]Á0AG~häa»ë?ÁÚ·Æ{e²ßa+gª
†¦ÞÃÂžºÅ‹l:]-T1—m¸‡<Jé±K»@]™b[îÕ4%lØ# N°öF§Ëßg°käŽ]×©´“ÎÏÚ×šÕ^Bib1…“Â1Öå {ÒÅFñ?gÝÈƒÃ%qÙÆóÀ‘ÀSh(o±ð®ro KIHD?œ]¿ôCR½œmHa ð=Õ8u”¦/ É’‚v°l›Â¯ûªÒôƒÌU"ÞÜ'Ï Ø~ÍT]ƒãÿOÆ7>*æ %Ÿ^lð}Ó‹•a÷<3¥™™
±˜3CÑ`”þÀAÛ4É	CZF„X›áÀÎP Æ.?–y*ÛËúÇ7çÀñ1åG¸Ï“@?ðFLV¸'‘­¶ðGorOŒ¢”îÏ¨ÎrÝêˆ©þ~ÊÞo#õ:«…íÎXV+š¬&®¾þZåËW•mq˜-*m3­õ[dÆÕa«ÖI,ö õøO÷ƒó_ýÏDH—éÌTë-¯ãxçfD‰Ãô,›`¢Å÷²Ô{úLª@D£:5ÞØ/q=5}Ô’¨`Í¡ìg”ní÷§ÔQÅµ60LU¯ÁìB~OžÔâ¢<Å@Vˆ9¤VEA¡€BvÃ§|å•Ðj+vËê^Pø½Í8Z³ç±ö¹ûþg´sOãü žý¢å­ü>8xiª$²‡ü°ìu¯}…VIì±FÓ÷2Ø]L÷˜ŸIÈÑ\û¥#WŠ}*¸ÆžøC\[COe@³¹ŽÊ¢bà$0’2{ç¸@ÂHÕp›Ò"\LÑ”èÓ¢½Äu<kXMtB^Wú¹Ê#ôF²x”B»s,•òC`®}¹Oç÷Ñã¼_ämY¥©¡ßAüön	ÍÞ Ó”%\wàb(±Ä#@Öb…:~Šä‹).rtŠæ]úô2›—–ºœù¢“˜HÛ~ÝÕÛ+7M§º†–\NEéla•¢z¤*ä)s¯IÊCÆèQ2dF‰î ¢I¡I ·Ï.«vdçû/–öTN|¡Åä\v¡0IñèøÔÒMeH0>¨:¹²}˜	7¡Ìhž}v±ð¥‹²õh×(ïJÔâ³1iŸH”ù ì1ÃZE
pYážCž#­PsˆK¨4¿Cîüw©9xÇ§–}4ÀdmŠ¹Q¹´ñ]Í!ÍVzŠIÙG}«H7»íšU’µæâYzE[má6È:´Ìíäœ<züö­å†fjCfK.ÛSµO<¤¶;UÞÕ”Ph2ËE³èïžÖ5¾ÒAÜ+ðX™\E jZÖvAÑ%Y:‹ÊƒÀE}©&jøÚEJMã
QÛâ$Ÿ§”BM³¿x/ÅdWT$­tW)Èû”ŽÌÈrÕÃšÃÐ²£óžÃÁêxnÁM©eûWäD– Á•  Ý?>B%A§2€ØLªÜß(•XrÏxÐVù’N¼gl„ÜoT®Á Ö>ÓÙð¸îR
T£ìþÌV25VL—	pó!Í—+,)°l  /-ÞF9ç
„iÜúÁí,BûJ"ø’ ˜ÊtY‰â‡ZO¤L‚õYßšzU7ŠSNû®@­|÷ŠúÏ×AÅoðð¦â/ý²@\O^XÉŒÕ#'•Ú)+çI5Õ* zïb6yÙÖÅ$•§í^xqÅ
¢êá¿³ñ€N+Ó×Ï‰¤”¬¦^k!ÉSò½:cÉJÍôºNXÑe[uŒúIHœ´8.mx#Ã·žâq2•jPéTÊ«$•s("[ºmËú=*Ùþ²Øí\ï•Sƒ¹
KU|u¢±)S±¥)&äèã¡Ý“-Ó[	GÇxþ§s”˜5
ß1¢Ò†P3@Ú‚*PûªfùY'©iFüAä³vnÆÔ6‘Ó)Ã³Á“rmÞD’DÖ¼W)^Šìö¶ äÇö$NcG5–’r‹«|*‘›ßxj
•Š¨<j}¿‘ëÒjÙd™LR<Á÷«Ù2]P“Rø°ãÓîÙYõLVÓQö¨/K3{ä«O7ž…Sq«â‰Šy‚Ç2Î^©àÇ#Œ”}\‡ô½Œˆ™ 4´ø€¶¯6‡«²uÂõº•t61íùl®´‚pZ5²ºÙUjYs |%ö>CžÑA)…Ô;HâåáÚ:ï5’qKbŸÚÃö`,@°Öy¬Á~æ7ôµ2ÉÇÐ
°½àÄÛæÆÓ(kðFŽ%Róº²‚áÀv m7®DN!@f)w«\öÀ*µ²©A)IéŒjïø¡Óy>mû8”u_“%­M ÑÏœ&t3d¶FM!Yß—Ì±Kjl]tß/J7à•«fƒÇ£¦#À×=È±8Î¯P99a	°gp'JcÑËÍöê‘–&fyö¸_?ÒpƒÝÅÃYýúr–]ÑóÅ‰^°'7à¸M±9P=ò#Ä1õB®kÄÖx/ayyXõúI¬€°
Bk™øOâÕÞÁ«?‰×`x-ƒ×|¯ÉðÞÓ\9`x¯ÞÓ|i1<ßÓˆÁÓŒ9äˆÆ*ƒ§9óš#ñiÖøÇ4|ƒÊøÓhMð4{|®7¾QœúÓüñ¹æøFuêO3Èçºãå©‡¸öøF}êßÀ!®?¾Q ú7pˆkP`4¨ñâ*j|‡Œ9ÒýÁˆ~éwqBüªãW¿šøu€_-ü:Ä¯×.)½k4Xã®OÈ>aû„î¾Oø4ƒOS4…|¥M%2R¿Ð·«äÅ8?Ð¹¥C/:ˆ£¨öHm˜%5þ¨­¯-UúÐÉ\°&G¦Št¯ƒR¬ÜÚºåøÉ²Á«^ŸÞíß`ôÃ”êÂš¨ÝºŠÙÆæ~´×²…ö3~	3ª«®†­–¥|X•Ø™gãj«ÜÊgãLdäõÝÚ‡,Oÿ¢é½¶Ø¬‘5&=Và»]pî‚X‹bAœ¾QM^h	v®ÿæQ÷Puâ9I@µ·jÝ‚Pê–<Þá¯ËÉ€Ãk_¶,ˆik+¡³õyr‡[•ûD¢ Å¥(-çæòÞMÜüãŠqÈcã+Ë¡hb¤ô`‚ý-Èó°Gç*ÑÓ©eJ³}}píóºÐ0“mÈB^®’×”¤îè» ´å%nYR…=;sòœ„Òð6Ów "(-à”¸¥· ·þT•ÊžšBÂüoKPz›>À'½Û¹Ú€½ß:×P­,y?wÃêÕµ‘yŸáÕD4Å‹ëd7VrD•xíÍ&Ñ˜—h”4ÑÀéª§ë~yû€O¯»Õ¬4èk¢ÝA¡	ÞQhÈSÐÙúÒº¹ËDÞa†Ù%ñ–
˜l%‹m}ÈðH|ÐeœA¢¬¡{Ý¥™êz¡á²ÕrlJÝùn­`W×T×NngÛ¼uB€Ôÿ¦¬‘¤ð€$‡5°û/@e¥0Ôh*H¢QžmØÃ‰]Ü›é³	v¼ƒþ6¶™¯œËÍ<»!A’¯ î·«ûÄ`iØvèîÜËž
~eëx z§ëå7õ¥ÇÄ’ÉÖ»ÿxõ®89k_Â5_¹ûo/àÍlÇ^¿øÉ/æîÃ½ ¥Ó·×è/ž;>Äßú¾Þ+Ãà½ãxögÝþ„ûø®çÂ5%Nð<yðàŠéê•36ËŽ‡÷=Z-xÉÅóà«ÙlÂë.†»S¯×Ý ðe¿„@°øÕÄ¯~Õñ+À/¾Zž|ñoþz¹ý¼=ãí•Î‹öpØ½Ä#ý‹¡¸èÓ½üwtu`d‚óÞÙ9…ÎFÉˆjÑÐ!ªÓÐ	òi(äC–†Z4tÈ‡ê4tÂ‡|
ùGC§¥¡ò¡:ð!Ÿ†B>äÑÐii¨EC‡|¨NC'|È§¡ðß§–Ç£µ7c¤RÂÒHû®Ö‘N_ªYå6Xÿ÷	ÔëJGêÚÐÆ·‘©ó€	õRÔà©|´Š ¯·mAïÃð±ã4˜Ó³öÛ#á˜Aé½oáPwì"Nx‚Roá˜%Ô¹¼–Dç5å¤!L¾šyÄ–:ðö!ßÆ—5{?(¶oý?PK   RRë§ä5¦  ,     HOW_TO_C.ODE/ROLLER/FONT.BASc`rOströtf@  æ#3Þa``ê‚âE@¼ŽXÌèÈèÄèÌÂèÉèÅèmñÉõž£“³‹«›»‡§—·¯Ÿ@`PpHhXxDd”¡‘±‰©™¹…¥¢½ž†¦º–®•ŽßC×†ûU.@ùÜ„Zïq¤åç•èd*V=d Š<dtµ}Èàp—¡Š¢†múCF7ó{ŒùŠ¾;¡RKÜ2»6Þ§â7¦Ù6\wº›=dRpÓªzÈ¬À¶‹ÝÜþ!“Ã#‡

Š÷@êÙÙ•1°îT`»Ë ÑïÆÀÅÉÁ4›åƒ›;Ðž‡ÌJnî"  MÜá~_¤ŽÅÍ,¶ë#HÌ $Æìv,¶á²˜
È'¨ùLì1Ø!nea{Ä¤øˆQAAÉlgÓ#&  VÞ#F(+
ä©s|0mŸã„iûTÛõðÚ²ÁÎ û}Üoàî¸wÇˆ;Àæ¹€ÅNaqÇ2ÜÁŠâŽ˜;æ”ÀÜ1'ä6ßnNL÷ˆ  PK   RRÑö%V        HOW_TO_C.ODE/ROLLER/FONT.DATå˜¹qÛ@†ÿñ1F {V2t#@  „]‚Jp	*Á%¨—ÀTKP	,ÁØóý„ä.`Îø‰}ƒ@úæçò¢Í7À§-Œ}Þ}xÑçõq£Ï¬ÅA»þ!þ}{§î~ß¿åóÃÓÍOûöâõòéòíûsâåªºÚ<¼7;àö×õ3íÛ‹Ø×-þk{$«äuUˆ_”â—J|uK–ç¹ŸgYæý¬®kï×MÓx¿éºÎû]Û†4k…¦‡4=D é!Mhú|Šã	Ö’MèÒ¤HÍ|âñ€x@<8È£e©,‘>ŠÂõgYz¢²TJq¼Zd¼Réãì$}‚†<ÁO‘?	êKô‘?õîE’J°BRk’R°(©c‹,ø´™jbjˆ©#¦ñx=J?ì=((JÊÅýÉú3IT‘¿B?þD½;ótùlž.ŸÍÓå³y*W]æayrÒ'#}jÒ§!}:Ò§µúüÅâñ€x@< ˆÄâñX©À<’Æ¥qAi¼È¼ €aTŸLh
Ñ§¥&ò9®Ôcâ§O°1}„‡Ô—>Ãt‡Ô—>GõéÀ£ûçÑýÇóèþãõ±ý'uä~81OE¨œ„ÊH¨šúaCýð½},°zÒGä<Tg1ßI%RfÈãj(‹cÅ	-ÑetÐç‘x*â9ÐŸ>ñýy¯¾ŽÔG÷gH/ïGÅÃúJ‘Ï3ê¬ñLì‡sPŽ½_ü³ú²¯Nß‚R¯«1ñ"_ë,í>f5*fâçÅ{"-¾?‹< vhæ–·#uBšûiB}Í÷~O ÿ4Udå(Í1Ñ§.‰#YEq”¢–Ñ'f_Å‘ù3[£¥ïïlKÌ/?ààYÛâéˆ§å|3±r3±r3Ár3ÂpÄR›AñÛü$¬Á#ù\ÑûY-šüøŸ8F€â NGbžYõ¾ßœ—‹ÖÐ<ŽFñ_9öca”¤ÏÄÝ”†{/ýhiäkåIË>øÚÖ°’ú3É³§Ûðîî}î?kÚœlö—Sm>›ÿ PK   RRa}ôa.  B}     HOW_TO_C.ODE/ROLLER/FONT.PI1åY½nóF\KŽ Ä.)X]€TI“ €¨K›"@ZW_Z"?H:üdz”ƒŸ€oàð¸;wäRÌgXŠehæ°^Üòî8ºré‘Õß«ß>ùõú§å÷‹¯®¾jõ×êÏÕ«ß—«ÕÏ×KéñÜšß»zpuçC­¾Ccñ­y?Ç±˜«‹¿O¨SéFÚ¥’Fý¨qŸJ©O¼õ«úÒ3K¥c–Ji÷X§RÚÇ:•®Þ¤Râ¡G©_÷EìN½ïù‰Ûtï‡õ‰·~f¯ÑÙS~¥ò+í•Ÿ2Ý¿çWêÊ¯çÞÏŸ™­JüFõ‰Y¿
«Û¨õs·-í·Çº´fýÜ5ƒû3ëwm6ÜE:e×Äz\Ÿøî¾ÇzÜ>Û¸û‡q¿Äï¹Õ½»2\…ç½žøØÆQ{¿ºÏQ÷<Æ™[ÝÜÎÕ'ãæ_“½ÌÔgÚûÙóýžêÞÇúK;÷}³ÃuÌrç­÷¤îãæ+ÍÎbãû)¿§ú£÷iŒ¥òk«Ì2ÖÎì×Mê>n†Œéû%†OõîÓ¨…VMÇÕ_kÝ—é¯zÄ£“=âæ+Çž¶ï÷T+?ß×óýåZåW•'W9Cî,Ïí\·~8k>Žºr,ñ‡¨ï3Œ—ë®òôÓƒçEpoHÿÆ„÷ùßB\<Zûíáö¸þã^=ò¾Êü°Ïù—yŸ¯ÍùE_qä}.ÿÃu©û"Û]*Óü1·3|Rä_æý}Î/löryŸËÿò}{~ÊpÇSdÌOò/3Ÿ¯ÁÄõV×¶j>ÿƒázâ¦óçòGŒ“WVíÐ.ÃîÃîÈ¿ËµÃîËãní:¼Œ½ì¬Ùn<v_5Ù}ƒlÛfwò¬oÆï‹¯»2\µM»i‡«ëß=XnÔ1.Vwþ]goþi&ƒŠ®½ñ+gÎeÏ>ãºrýq=ÏÞ²‹¯d‡8îæÙ¢ýòUìJþ×ö¾­}¾†ÙÆñµ±DÜî×ä€Õ'ãX=·ÿ(ý³UóùN˜ÏßÖ6‹Ñù>ôãà‹qØÆì´ýÝîn'r·óùZåòDøµñC‡üŸúqì{ªA~ãøéžÑ]snCò9›Éïàq†'gÕ;÷ãà›ÏŸáãGzœ_îÕßZ}ÔWï€Y*9=Ë‰Nüª/çf˜|Ó}“ã´¸ÿpNvj9ý
jémžì»½0}zþÿ@˜ÓÃ ïôÛ0nŽ§§_ÝÂEÙàr¾gûùeÇÁÙôûb7·¶ë³ð»1~…¥žrB6öwýæ,oÌ·á,¦§Ëð	ƒ¼~S~7ÆoÆüôé<}B/Êæ›ùß&lÂKÚ¯ß|¾WÐëƒôúàÄjz}^TÐëƒ"ôú ½>x0N¯ÒãR@¯Òëƒôú Ðëƒ.{¦×EèõAz}ð`œ^¤Ç¥^<’aòôúà«A¯žôúà	øÑëƒG°£×/ôú ½>8±š^¤×ôú ½>H¯ŒÓëƒô¸Ðëƒôú ½>(ôú ËžéõAz}^<§×éqi ×d˜<½>øjÐëƒ'½>x~ôúàìèõÁ½>H¯N¬¦×éõA½>(B¯Òëƒãôú =.ôú ½>H¯
½>è²gz}P„^¤×ÆéõAz\èõÁ#&O¯¾ôúàI@¯ž€½>x;z}ô =èAzÐƒô =èqB\Ë§òy÷Ï J>ë>l¯¬ùE¾ùPK   RRœWT/n  œ      HOW_TO_C.ODE/ROLLER/LEMNISCA.BAS¥UAhWþßÛ7cÜ.©ADÖ™ÐÊj°"TJÝÔy“$³$Yo&¶…HlCë)EÈ¡oí©=h·ž<i	2³¹ˆàÅ›ž¼ìÎd{/Š„õÿ›ÝlrˆŠ¾yïýÿÿ¾÷½ÿÿ'Üû©4Zš.ú) †§R|b´vƒ_0kˆˆg)^hÞƒÂ¿bSl†•Ø4sÙ,;ÏÝ	vŽ•ùùªQ.Ozè)ãzX…óÙ*`ô”1åW'Ï¡OÙKFÅ/OÎ>9›)U=^–¼2Ê+%Èo0w%Zþ5æm9ðg³oáòÒÜÅ+#K_8ËÌ–GÿRƒˆ,¼
7œkë¶-«y^óEÇq¢ŠZe$äcî6.¨+s&¡?Î¸¾ÕSkSÂñá¤+ËvZ¬gÎ»s)pyÜ~}3fn(éœ{¾é™gÆâŒ:Ü˜¨›Ãu3F¥Å$`»QŽN)É˜1˜Ãè6ôîŒ´‹-Fq´FOÜ‰]qvEª ãÐ>Ññƒ8“€tûXüú¥˜IUßPõºÙÕêE6æ^õöÛÔÃ;©šÿƒÔß(*õâŸÆ Þ¡VTEð¢Nåòèµí¯T|½VE/sÿ÷U‡i$ŒbEhj4Bì°„S$Ù˜¶Y9Ü3ŽŠ0>ÄàøÎ~$¸®%ì“@†4ÿ5áÈZØg¾U×ûVd½×eðÔ.²Þ“2‡ÖÏn%,Uµš°ÙRÑ17|yRE+œnqÊhZ©ÏtÆX[ÄÜòÍF?u¾Êä‘OóÈW³hR:E3'õ[šuP{ó£b$åû)fÞ;üe“ýâL„N3·øãåŸ~»87òÃÜI¸«+à­_k*qó”a³¶î*ÃÁ::¶‡æÉÑRg‘vË¤Ã­ô†ö¥£6ƒ:@œ±VxêÿÁ®º7Å¿ØvAyV“¬}Kyð‚±î‰Žb6é¢Iùu~LßPÕè?{„ªê==I-"ÕØõˆÆ’¶Èñùc;Q°7ªÛÍ°Ç’~	Yü\øÎ†®÷z©
µçIVæhöXÕƒG.?æ¼Üþ}úÉøv:xøý7ÛpgëïpÞ÷1Ý¿ŠÿÀGëWÕoÁI„Hívûõ¾{ùÍE`Ào­©÷í-|ïó¼PK   RRž–"Cm  `	      HOW_TO_C.ODE/ROLLER/LEMNISCA.DATåÔ«wâZðò$!2Ü6L¹pú …2@€>˜W3]”>Y9YY‰D92rä‘•È‘GV"+ïNþ‹»j~++â¬}öÞç;ˆ Žx‹Áñc{˜txÃä“	u˜ô^a†ñàå0¦(„ñx	m®a¢óî ºxƒÒÃç	Ì>ûò„rŸ}(tå·zW~§3{¸Œàuåå+ÔqõŒR‡“N‡G!Š¹z;!í\œ@Í5ã«Ê-v Å.c¨-ö]À ìûFÕîË¯S÷å—ßÐöåç_0Ÿ´a3~þ
·™œ¥@#>] ØLÆ!´f2ÜÀØEèÃÜEŸî²‹OØè¦(¢³†ˆön ŽRxÛÉá^5:Xfî¥™MúSÁ¿¸ž¨§p<ñq²'jKØžØIa9Éö¦“T—0œäÃZ	Åü5`1ïn	î¶!¦!íh·Û(j¼$á‘l%69P•Øˆ%Öÿ L0ŒTÝ‡—kçê¹ÅŸRÿ'·ôSS¨Â “ï¹™À¾KJú=·bî¹M}¾ËaÞÆn å.ñæpgÑVkUÐfQuŽÂÛn£|Ãªù†Õh¦SÔcxS4¨Ú)MçZîs¨×ò0Aá‡8z„÷C¯à\ËÎ¬kyòæÝ7hSô&P¦è?SÒ¬!!Íâ6.aÎ¢Ñú,/²zN}`M³ªÎ^a?Ò|çÏÐî’‹6”A‚ps©¤™«ç*Åè‚¡ Ä¼btN›k)ñÝ]ãgè?]AÕøø-›Åø0äˆæNúp®a[,¤Î”ãþ%‹õç0,Ö£Î»¼»†VŽ»!TOt6P}ÙN¡¸ü˜6Ð—G´óÕèp“yæú™{ëL¶ÌlÎ3ô‡××Pjrw	u‡œCD-…VgÁzMî„0ñö¥FüÏVUSØøÃãÚRr0¾µÊÞˆÿ•|„¾/=šÀj1²|¹OðHšZ‹9ÊQDÒÛ$Í\;×=î3«œ¯­ï&}¿À>þ¯,¶èÝ¢Ê<Ë‡Êú ª†0Iê^Ÿmûp‡Éõv˜+(Ã¤öÚ0Ù¥­&õGX#Þ˜Àñ&U5{´¥cñîóêÝçÕ»Ï«wŸWÿ§¼úPK   RR/Ñp0’
  £     HOW_TO_C.ODE/ROLLER/ROLLER_C.SÍYÝoÛFf€ü{¶Z)ŠŽä ×Qƒ nÝsÒÞ=0Vä*aË™Kú£ýýfvI.eçšNQ=PÜÙÝÙùžÙáô‘~OŸL§â~–ßE•çªºm„/
Y'•Ðm-t³ùJÔ6Yži%R¥E*©ERÑ»*Ä'^Ï¾ˆµÔY"tÕÖ	o,µÈ¤Ò:Ãqï/ÎÏÎVïÅŒ~“OÒwŠ£ÄkUªZ‰ƒ7e£êZi-ËFlZ•á¿ªZƒh¼eZd%‘­ŸÁÔ¯—m~"k‘åâNH¢+‘Ûßžœžÿ &IîKé@œ.½­³†þ+páFb›“Ôt&®«t*Ï*È!QM£D]ÃR(ãu`ôZý&JzÏ÷Uy]ÝAà>°)	5BÜ„²ÇæÔùýçü‡W«‹o:;§ç¯VâÇ“ñýÉ«ýŸß¼}‡ Ÿ£9èvRh–‚,
ñO±š}7;ÇÿgÒ·º…ùøŽ<$i²k%Îë²Ì´l²ªÿÀï/•ß	ô^òÑ¹ÛºJ>J²€MƒÿEÁå`/‰b#ïý®…H_¿9§?}³á;×~°úïd«†ßIÑ–ìã°Â„n›CŒÄÛ=Ž¿$¿7Ÿ>ñÞ’þ 7ŠrPðþÆSW­xÁóEu­f¹÷lîÈ£I¹ñží…¬©åÖ{ëÓ¹¯/µÞŽpè¤ýtˆLSB.c3ÖÿÝI-Óz íENµàçÑ½	9wH;:>>fÄI®½$¯±ì@Î'Ï=o*V›$S¢@xÌ ºë,Uv§ëZÒÑØ„b¶^"À79˜Ùñy–öœË¬ÌšŽ&øæ¼©xp&9MàHÂfò¸@¸Vzt®A2í‹Ò&6+&™b4,ºL±Å#NÔ5¢"2ž.à À,D?BP%VvRY{{ü^„ñœÄx©?f›¦HïMÏ¥™¾+“‡fž½FSïÏ.†ÙÂÎ¤"3ÑÉéü0=ræxŒM[™;PŒ>±ÒÁåØÀÑÜžœôhCª:aÅŽxè;ì;„>#g;^ëÚ#]6r­¡ ›})IRL µÚÜC¹ºC¸Õƒ0IKÒÌào^Rl3"`oqlHØ$óIX—j¦=³nyËË?ÅZî1ó­_½šf»SóCÌ¯½NÍ¾£û{³…ïèÞQ+ôsTèr€xñ™QñãŠôû’ð“‹ßx÷–=}bÂz.\žLŽƒôP~0é –E ,!ìº¾â§ãðF0•ó‰‡@-–±HîÂ~ðR$1H-`L
4MAšbÍEbÍŽJ97ÀíøÀV7ŠD"äTuó5‡ŒW<HEÏiE.eÜ™„µn7e…%ç/ÍÐÄ¢Tmªºà4ï øMÕÕ'´íÈi .ÂÁqô ø8fÑNá;¬¥‘°QˆÅÞT/y`ó
ÌôÕY‚Ù³áK;ì£›YÜ«6W-¸\xS84@-üxJÉ‘TÆ’.Ô
©`IBj[2óFövä2±mj®·è½WŒlÂo²Œ°&úIÆÁKçµ6©¦LÑqÔi<ˆ(ÓÐâ BýKq%ßv¶s ²XÈBDSËÖ€Y qX`v_FXœ•©º];¬†dH8CÆYV„ÎÄ8påªŸ±FX¸ƒ5Ì’´XýK±¥¥bBã®Ñê,š§O Þ>‚7¬¤K”t8†`È12Ùç>Û/<[ry/Üþ<|Áºco‚oÊÚÌyð<²â=i›ª¨Òl“)cñYyû“2ú6® !íd-¦&Ë
%ã»‹Õ[ÐƒÒ*ã{äPˆ»‰Óp¨fn(Ž-èâˆŒ„ãbdé™¼>eòÊª±´u%…¨ZŠ.U×µìk9®ŒM`´v€ù™vì‘ñÔkÕÛè¶Òö¦Õf£IIÓ*'ÇÂ_ch=tõ`ÿÍþáþÉþd
CõÉÈ¹ˆ‹?â†œî›âÆ\R®ŠØHØãÌ1ÚÂ;ÀfM(cY›Wc†4gîˆìL›M†c?\<ã¢vŠdÿé;¤wÑ×œ6:êO`?ù¢Øßý}hv’uÿa²?êŽj!Ê˜r§d}šlF`ŒW²ÁÍ­w…ø|HØW|ÊWånZR¬ ÄW+³ ÞIç¡B^ÄóÃ &ˆ9E•iÍI7ˆ§Ëøð_/Žã¾Ø?òm–k¼äÓ6&Â”¶±×*A~È“6§«k!õUKzœÂ+Ý@Ë^Cg²°Ú ]›„;´âtŸ&6HhñðöjÛdœ“üÑ,•N±fË© 7%c4NÄ— å °*q°&uL-µæ K¶F*`¬"s]³¸÷EÜØ­f\ÎelÉj‡ÜÆvAJ8%s«×£©`4
G£…›ME<ªØæ™ƒh˜îAÂ{ÅÈ|ÒˆI“PªB7âí¿Za¾ªMA™Fý t3@à§½Öf"¶¼¾‚Wá[c?ŠúW5ZŒFáh´¢^àiÄöN'|ÏæÇù­¦LÌíLÖPzã:ÈC?üÎ|ø;ó‹~^ß æ7­~ú·°[ôoÑ'1þuÛ l¢†±ë.6@Š]Ü8Bà8
ã—Ça€· ˆ
Røq­&Cüè/¥»¥íÜv D0*ñL¸šrµÍ%´8¨\\Q“L¶·¶¿z¾²òdìar\vÅç¨ÙqÚ|\IgR@°[GŸidŽ¦º‹ºÁW–ü	ïãn¥©©^‰¡`:TÙÈII[~-œb›C±ºm›mv;êÛÌ‡0ä°vlYX°²0ØY¡bG¦eÐè¦?m­®ã¶Rîw>_« ?Õ–[	\ÙUu†[à³½[üüÔ½ošÀÈÁCÎKK¾ßWË­-U9”æÆ4ÍûÁþ›Í¥Æ|-èK*§¼µöK¤ÙäƒºŒŠZÒ‹s?éë¶mf>h(X‘IKOŸÓVÁŽ0ÂO
ÆWP“¿T	}Ú ^ýVaod¦;2ó{Ÿ‘û$;ÅIè†Æ]‰.Ko¸CïâÿÐ;{Lj"—š…¥f±CMô05IGìÒq•Òµ¾ÐÇ­NPžr98=4¤ïŠu•ó¥íéÐ†$*#•.­Ìz}ëEÎ¹/L*2?Û·†Ô‡„ÐLÛ˜è½]¾£¯%¯NÞp‘Å%‹—&³\Ì}jÚÒÝÃjËá]æ`ñ›;ñÃê<ùXW°´ŸÃY‰õ8ý(QÒ"¨&¤kÞ±£¯8ðÌ#ð÷À=ÐX\,ø±è—G¸Êãù{Ë%?–þ^ó#Fïˆ¨c6e³Á—:´“uVŠ÷5|O;ÃçFâ‰oHÜ­·‹Ÿ/ƒ&lËcwo]5²Q—Ën¿¹ùí®ÊUO9‰ìVõ	¾Ñ¦\¥N—j2à‘i2¢s1[[÷€i%î
@BÇèF,B3Ÿ÷'Ø›¯Ã|©ÝdG° èÌfÊjØ`È°¤{›r1ùÀã³—G‹(bã`šL£¨Ñþ?PK   RRDZ.Ç`  ~      HOW_TO_C.ODE/ROLLER/ROTATE_5.BASc`rOströtf€  æbXˆUP1ã: Þ Ä'€ø
Á0001 cFGFgÆ`Æ  íÄèÉèÅèÍÁ	`f
qef0¿Ç˜¯è»SñOQ~IbIj¼©^Jb‰›È¥Ø]w¸ß7l šÆáq_d*“³€‚[~‘‚§ª­BH¾‚¡)¯†€B@Qf^‰‚c‰†™Ž™¶§ª¦µ’.P²æåðK­(êäyÀèªõˆÝŸã.ƒ	È\v7‘L®šèbL³ß<b ¹Ã $ÆìÆ {ôˆYLï³ëÝ‚°Ù”1²Bd˜Ø0²*?b@â3T³àRâ#«ftcPP „µ#TžŒyÒè+%>`ø%ÝG0»2”ÅÂþˆ…í³‚‚’'Ól«GŒnl`–Ú#7wkÖ²GìnwÙ,|wº%1Ýg 2  PK   RRònÃÉ~   Q      HOW_TO_C.ODE/ROLLER/ROTATE_5.DATÕÜ\lmðýA00‚ 8ðÂ```` ‚‚ ‚ <AAA<ð^ëZë¾÷º÷Ôáçùeƒÿßu­½÷jï;;ÉN³³l’M³ól–Í³‹ì2»Ê®³»ì>{È³§ì9{ÉÙk¶ÌÞ²÷|=ßÈ7óFÞÌ·òV¾ËwòÝ|/oç¼›÷òƒ¼Ÿæƒ|˜òq~”Ÿä§ùY>É§ùy>ËçùE~™_å×ù]~Ÿ?äùSþœ¿ä‹ü5_æoù{±^l›E£h[E«Ø.¾;Ån±W´‹NÑ-zÅAÑ/‹A1,FÅ¸8*NŠÓâ¬˜Óâ¼˜óâ¢¸,®Šëâ®¸/ŠÇâ©x.^ŠEñZ,‹·â½\/7ÊÍ²Q6Ë­²Un—ßÊr·Ü+Ûe§ì–½ò ì—‡å –£r\eí¬“u³^võïæ|¼[âãÝ¼wó>ÞÍùä·•\"´æä¼Ð¾“óBÇNÎÝVr‰Ðš“sB¦S÷yÿÜ'ßûÂçè_ç³ÿ…Ïñç>ÅíŠ…²•ôHJ>è–è0%{T{L|è n+>â nuq·š8Ð­îq[ñq«ûˆƒºyŸ…HÀG’•
Á¡¸‘d­$è2ÛÌÔ	>:e¾×}¬E?ÍÇëˆÏµ¦
:ÁGsæ•÷YFŸ®÷ÑœX®¼Ï0øä÷‰s’ßZ®‚ÏÌ’²FŸDˆ>?¬yuŸ_Ú¼è#Bóò"úF´>š*™Ùð‰-úi­KÓsŸSóQAÈ	Så}$'˜·pÓÞ™õh7í]ðÑ]åÇC®$%æª…à‡5Š>Ú$ø„æ‰Li&>Ò¼ t}Y3Û‚Nôü/¸MÏ§ÉoKÕ³ù„}Ô|.4'ÅžäŠ­[õÙXñÑ§³âsù‰4	9Áïš«ÍÔ'¿‰ÍSŸgMJ‘±y§š ès7
>åy9+ÐQÕYjJò¿-U3ñazÆÌÉo¨©ÏtÄG[ô¡©J}Ä!úôé#=’i;f®RÍÉºõÎûHNÚlzGŸ¾ó9©ù0)ù5O|&r•§Ï >’«¶&>:kæø]“u…ÄçÅtêñùŸ¦ùHzb‹à ©RŸ!}ä®e/¶.ø,és$ÓÊ|fÑgd>àcsæ’>6—‚ÏÜ|:Ñ§i>˜(ù>su}¬IpÓæu)$>L
sš§	Ÿ|2úœ˜OB/ÐiÑ§JR’ÿ™I¡]Ú¢÷â;t8³_,=—Ò"øô*J‡:…™“#æ•§rb¹:¨ù,á–úZNÖésæ|^¢Ï©Mî›4-8Kóà³a>Oô9Ì!WÚ¼Ð0™53¸I²ª‰Ï´|†N‹:šž1}>ŠÿÅ™¤í¤„>}ñ‰íâ”C/N¥ML[8Lè³å|Ø#¸¥>Ö#×;çí]åsNŸmüÞÖ;øôâ¤ÀM'Sl|úô9fó:Ö0›5øý†>mKMË'èl»ôŒ©ó>-êÌ­]WæónÒºª]Ò"ÜçÃmJóÑ«}¦Ñga>’íLíà3>èÓ§rb¹‚M sæ$øœEŸ)}áÓædŠc“Îóæ³®ƒMá£Bm— 	|¶³oÙw…AG}þbª ÛÅ”¿™+™Ùâ¦Ì¸¸Ö©”øŒàðfn2•fv•RŸ	¯v©rb¹ò>3ÉIô™Ð‡“F²;üÞ©ù Iùšú°yâ£M:Ï3MVlØgÍn¿âl’màiì¬|4Ê‡)ƒ¦JÓs}®]ë†6e8hëZ¼÷ù“Ý·ØÕ.õYÐçqÅç…>zõgb“ð»5>±Ip>– &nš¬Ê‡BðE¹RW>CúìÐçMSR¼«Nâ32Ÿ™ù¨Žú,é¦S»ò‘œLín øh¶™+Kê£Wìså}4'}æJ|ª±IôéxÊn-Ywô9¥O·òa÷‚P>;ôy>š’â:CÎìºÏ –ž‘ù„ÖNÛr'æªò™æªò™EŸfâó}‰æäÔ&zð±&™O§– ÞŠÏ=}ºÙ%+øÜÑç:W5#:èLò:P(wcë*ŸK:¨[ê#‡–+ï#š«ÔG¦Ö;çC‡‰õÎûˆƒæ*õ‡SKVåÃ&a/¡ÍóBhÝökBëe'¯ø@§Ü³Ö­úÿÓ>Ý/|:Ù±	¥>mlÂÞñÄud“Ùt°7«ÔœöE•šÓÁž¤Rs:åÐ©9ràÔœæm¥öœøx7ïãÝ¼wó>ÞÍûx·¯|¼ƒ÷ñÞÇ;xïà}¼ƒ÷ñ>WN‚×Á ä$ø<„œž£+!'½M%ä$°G­„ny§xŒÙšéÔ}F_ø¿ðüë|z_øt¿ðé¬øP(ûXIR‚½™¸¥:H	|Dm”ø¨ƒ¸Õ}ÄAÜê>â n5:È¾©î#âV÷q«ûˆƒºyŸŽHÀG’•
‰ƒ&«ž ìz~ŠNôa‹°ªû°EåÜ|œ}-UÑGsÒ·\yŸçè³øLƒÜ¼Ï$ú<'>š“0™‚Ï¦&%ãdª	‰OÃšW÷Ù´æ™…°
>˜ÍA-*/,U2›ÅÇZd>ãZzð\ŒßÕGu1'’*ï#=’¹za½>Ú£Ü´wÁG{´Éë äÊû )1W½($>wÜ3¤	j›OhžøÈ4fR²M6/GŸ¿°ÍøEôN¹€[ðazàƒa ©Zšµ¨<¯ùÌ,'Ì•´nÕçuÅç‘>‹Ÿ‡O|¤I’“CËU³æ³›G1)ØÛHó,AÁçÜ6m6©Ï17?ò¿Í‡:œ2HIùb©Ú¥Ïu$'3¨Ñ©Ò‡-ÂsŸ¦*õi:Ÿ}¤Gr]n0W©æäÂzç}$'s6Oz7å3|å3«ù0)Ü3HóÄ§Ë«¹øìsï7!&èÄfÍü®ÉºBâ“Áçƒ÷=šžoôÁ^jê#é‰-‚Se>súÈ^å ´.ú<Ó§ÇiEè˜s¢Ó<øèœy Ï«Í¥àÓ5ŸEô™š&J&wRÏ¢OhÜ´y
É†ˆIa®Bó4Aâ“qÏ,>gæ³¯Bù?ØfˆO•¤¤|†Ì¤Ð.mQ{€k¶nÇ|^è#ÏÅGH•N¥mÂÌIÏ¦yå3¥Ï¦åjžúÀaYóiXN.èÓr>ÑçÅ&÷Ä&Í:Ù¼'KÐ)g1¶ØÛôµy±a2k2¸I²ª‰l<þÑÑôlÓç¼|Š3‰í¢OŸ{$¹Ö½UíÒ)‡£8•:edÚ–›H•ø¼:ön©OèQÕ;ïsb½‹>h’ø´ñûÜî 0iöáÆÉäv'IáÞ¯o>Ò0›5ø}‹>KagŸŸ.=ÛÔÁ^‘©ãOÛÕ2ŸIþÁÖÅv±E¸Ÿ‡Ûu‚Ï4ú\EŸ¾ù 'Ö;LíèÓ>ÃàÃI¬=Ò\µøà³|xG >gôYãóàÌ|4ArÕ¾ÁÞF}¦Ö°6…~qÏ¼ÅæU	ÂÎ¬ø«øg®·¨£>L•è„v1%ås%­Ÿ0ee×¦’÷yÄ<ÙP7N¥–]¥ÔgÌ«]êƒœX®¼Ï&s|é£“F.±ã\¤>Ò¤lh>Ò<ñÑ&Ý`ß¥É
Ûà¬ù·VœM"t‡§Uì„L§òaJÊ3KÓÃk”út]ëæ6e8hë¾ñÞçO>vßbW»Ô§CŸÑŠÏ†øØ}ÔŸ}DˆMÂï¡yâ›·àód	bRà¦ÉŠ>*Ÿ÷¨ÓâÿƒÏ5}^é³¥));¦ã|dšˆ[W¥‡>px·\yÉÉ•ÞDíQ›¹Ò¹D»b¯3WÞ‡9ÃÒ|ª±IôY$>ÂÞF“%³[´‡ÊGº„náó!>¸+>LIy
kN¥ºÏQšî-á[|8m‹»˜«Ê§}–‰Ïfô¹ð>zEŠ½«|4'o6Ñƒ5É|µí×}8iÖò5ìQ5YÁçT|²l{vk:=:p&%:P(×cë*Ÿq0·Ôt«ûˆsUó‡+ëóËUê#Es•úˆÃ›&Ëù°IØKhóœ4‰nƒšÐIv‹]ØîJz:e[[÷‰ÏõÚgís$elB©Ïqy„·ìFxæØl6ŸÄÍû8·ÄÇ»yïæ|7ïãÜðfb%tÈUBG‰\%´—ÈE!¼ûåäœÐu"…¨€·ñœŽS¸Mt*…ãD§RØOt¢îdN’ïã¼wð>ÎÁû$ÞÇ9$>}Þ)v±ñh›NÍ›ÅÏ}Ž¿ðÙÿ×ù}îƒ7?÷y_ñ¡PyYOSrC·TGRr,j²s>ê nuq·šïôÅ­îq[ñq«ûˆƒ¸Õ|è nÞçQ$äÊ|·&$Iù`²ê	ÚÀ®gNó±ýZñÑý0¯#>k–ªYôÑirk¹r>šË•÷9>Å·Ä§}–‰æäÝr|švÕ¾¦O*$>?µyu¼Q¨Í>"„Pô9ˆ:Ò¢_–*Lfú„ýÐÖÕÒƒçb¼Ù§>ªÓ‹9YòÿíÑ‡9ÁunÚ»à£=jÃ½‹>Ú£u™çÌ•÷ARb®Aˆ>§Ü3¤	š˜5>2‹™ì¥yAè0ú,°Í8ç;0Á:p¸ˆ>šžS¶(ÓTÉs}¬EùMÍgÓrrÌ\IëV}.W|:ô­øl|âƒ&INð&£æê¢æó›§>Ïšìm¤y;– à³‰=êw›MêsÈG£|1Õ¹×”Àan3©iéi3'ÔÔç‰ouµEðÑT¥>'ÎGžÝ›ì‘LÛ6s•úhN4W©r7™LÒ»Ÿá£Ý¼“"{6O|¶y-Ÿ÷~c
}£Îšö„L–¼eBâÓ„Ï9ïzÔç„>Ø+B>LOl˜*ó‘7Ø¢ü8¶Î|d‡}N+õiFŸŽùÌ£Î™ú\ê\Š>óEŸ™ù`¢àþJ|–Á'4	¹ÒæÉ[\êÃ¤0WÖ<Kø4¹g–æíšÏ@…Êgl3Ä§JR‡gRh—¶è6ÿÅˆÌì'Køà¹n-›J6…O£Ï‹ó9£Ïºåê0õÃ²æs`9‘\ÉäŽ>:qÅ‡W<™Ü‡6i¦YOöô¹4Ÿúßá¦Í“YÓÌÿa²ª‰6å|zò¾udÆ %p°™díê°EÇôéÓÇÚ¥Sƒ8•z6e0móu¤J|Î{·Ô'ô(ö.ñ9³ÞU>[ô™à÷±ÝÌ‘ 0izpÓÉT5ì\’"{?6od³YSüÉ’Ù¤	!ìÌà3qéi«¦œIk×ºùü€[Ÿ×´Ð.ižwàÖ¢Nð9>ÌÕ¹MõAN¬w2µƒO#úÌ£OŸ>’Í•ø,¢Ï4øðŽ€>šÂAžkvÍG$MÚÂÞF}®¬as
µdÏL¡±Kvfå#Þ²ëâ®ÐtÌçS%:Ö.MIž1WÒ:ñ	S¦¯ÙTò>8Ü™›L¥¦]¥Ôg›W»ÄGrb¹ò>MæÄ|8¹g6iÄá¿j>hžÇq2‰6iû.MVhØ+gM{Ôïq6‰Ð%žV±RÊGSM•¦g#ú¬¹ÖumÊ %pÐÖMyïó'»o±«]êóHŸÅŠÏ}ô>êÏ>Ò06	¿‡æ‰OlÜ‚Ï¥%ˆI›&«ò¡|:QG:Tùté#é‘Ì”`¢:Þ§c>MóQõ¹§›NíèÃœ´ìn øh&Ìç’ùè{Ê\yÍIŸ¹’;¦˜ m}F‰…°Ðd½Ñg‡>Cç#ÝB#øœÒç.ú0%Ù¼“Ç©T÷éÕÒÓ1ŸÐºàÃi›Æ\U>èóœø4£ÏÌûè)ö®òaNp_ª=øX“ÌgTKÐ`ÅgIŸ!ö¨š¬àóFŸè¬×töé 3Éë@ûÐºÊgƒê–úˆÃåÊûˆƒæ*õ‡–õÎûˆÃ¶õÎûÀÁr•úÀn—‰›„/µy^M¢ÛQMè*a¶¾’ž[ìÍ:_øtÿÓ>Ã/|Fåž	¥>ãÄÇ;xïà}¼ƒ÷ñÞÇ;xŸçJ‚ó¼Šò\ã„¢ž½P”ÀþÁE	ì½P”ÀÕÉÐžè¯Ë5l3ŽyWx[éd©ZÔÉRµ¨“¥jQ'KÕ¢N–ªùœx7ïãÝ¼wó>ÞÍûx7ïãÝœéÔ}:_øt¿ðéýë|_ø¿ð­øPßíÖÓƒ”dtKuÎäÝ=ªuu·º8ˆ[ÝGÄ­î#M~ÑŸúˆƒ¸Õ}ÄAÜê>â nÞg$ò%äR!8”š¬z‚>d×CàÃe›+>lQÖ0¯#>–ªÍè£9é[®¼Ïsô™xË‰æÊûlGŸçÄGsÒ·\ŸM
Ü¶¹öBâ&VÝ'L¬à#B?óïÑç8ê EðÑTÝñë¼Nh‘ù´ké‘çâ;õ1^È	Så}$'rÝÙ´ÞíÑnÚ»à£=ºàœ—\9IJÌÕ 
‰Ï÷i‚Ææš7â÷äoš”R&ÖNÚ‹>?d›Áw`‚OW¾ù†[ðÑô<H‹²¦¥êÞ|¬Ex®I}š–“Cæª+_?®ø<¬ø,èó¸âóú‰4Irr`¹šÕ|ÎcóÔg©I)õJøj	
>ß±G½°ÙD}`ãñß±»‰:÷š8ü°™tbé™0'M~¸Î+~—>l|˜ªšÏ¬òá³û”sFî[æÌUê£9Ù´Þ9æ¤ÁæIïZ|†¯|š5&…{iÞœorí˜Ï÷~Û’íÚ¬ù‰=¡&k$>›Î¾ùœÑ{EùZ•>9ÿ ´š*õiÐGö*‡±uaú<ÓgÀi¥>Óè³0ŸnôÑ9óJŸKÑg¨><‹…>ºà·÷»¸ïjrï|¬Iüêv‹>sóaR˜«Ð<Møüæžy ï_šÏ…þæ6C|ªôÈ7ßp»å·åÚ.mQ{€5úœª¼ß'-‚Ï¾|‘ÇÖMl
¿DŸçÓ¢Ï…åªQóYòdï3·œlÒgê|.£Ï“Mîm›4Wp8`ó^,A;œÅØ^”S~ÏÝâ)ôá¬ù=êŒ'„É×ÈØ*Êw©ûò¾u&ôÁ7ßq&i»Ù"Ù#­ñ$Œª]œ2pØS©gSæE¾©ç—æ<OÃ|´G<ãÁûXªÞy8hï*ŸWúŒå[u»#3'Â¤9â÷Ù[<w#4LNý¸æÞ¯o><†³{Âsúl[‚Dß)Ë.Ì¥g¢:ðùE¶µkj>Ûr.¯i¡]Ï<×d ß”SÇ|ôjDŸõèÓ7É‰ö®Á’Î«U½£Ï‚>È‰åjÊÿƒŸ«è3>Â·úüCÓ|4AÒ¤r¢>’†)ô{æsÎ¦*A?áƒ]žHï¢Žúl3U¢ÚÅ”dß˜«~‹ÞˆSfŽç_JÞGNÅ¹4·~ñÏ«”ù´y·”ú '–+ï#W¤qô9`‚tÒˆÃObI}Ð$<'6âdšó›û]æäL“vÉYó{Ôi˜MzÃ³Øïâ/Ó©|˜80U–ž§è3¬Zg>/zjµîŒ÷>ò±û½ÚÕ|Fôé¬ø\ÒGï£þì#Bl’žäc“i^5ÉÎÐÚâµmag)!)p›Ø©-Á‡By†mFÐ™òÿÎÁgM|ì¬(=›l˜LÇû,ÌçÄ|¨c>K;ê,ñ‘œ¬ÛÝ@ðÑí4¨FôÑ+ö•I},'ïvÒÑÔ%ˆM;},øPˆ§Œñô1;SJO+«|úz¦”žV†ï¸oès}˜’lGÞÉãTªûì×Ò³0ŸÐºàÃi‹¯VB®*Ÿað‰'´…“Û‚Ïfâ³Œ>]ï£9áiYá|¶pêšd>µ­ø,és]žÆÓÙìÌ-ú|@ç¤¦3 Ãš;iÌlZç|ôd²}wÒ˜?ÙîØ4æO¶sçŒù“íüùuÉ¹vþü:®?¿ÎŸkçÏ¯«N%;òç×¹SÉ®íôºDOôïøn÷d%=#¼wû…ÏÚÚçúŸ÷ä|?wîßÿPK   RRþaO›,  ö#     HOW_TO_C.ODE/ST/REGISTER.ASC­Yí’ÚFÖþï*ßC;åÊÀ˜Q$`6ã*`›w3/d÷Ïº„Ô0r@"’Àã”ÿæöv÷9§»ÅÇˆMª\„ú9}úôùèBüßŸÿ¼|A|ÄŸýðù%%ò ÎÅ&ÈÅ/ÛXbÄ…ÑkÈcú±QÛBq¤2ª¬â£èB%E¦Ä.ÝæâÕ«Wb&â#^‚ <2EJÌÓ<u¾%¹²"Wxh”
}¼ >ŠI%>*±ˆ“8#"µ&z¦ëM¡ÄJ‘žà¼IÁ°P@–|Öàª’e°Tk(–_Š¡Ðcä1f«òB`¶Ÿƒ„f™	Òa£²<M¥M`ù¨0‹wà ùú’ÁR¼$ƒ¥óU¼äÙÑ+t9¼ 	[À,Ÿ<Í
‰uZÄ» ˆaŸ|»Ù¬XÁý4~Ù^ˆxEŒ`*’»…Õ’’O‘» ^‘	ÖŠ¥H±(°Ä:MÀÖ°–EœÓ
^Š
¶aºÝä¥Jòß™W *2”¨ñìÖiÌËYÉ…°SŽöóÂã]°
¡¡*À4MÒuÌzódðg—bUrç"U¡²KíA‹J>»la~6LÞ ³œð¿²Àý>²—f`ü4Ð{I¢>âÑò!Oƒr"ë¡Yù_iåiµÙÇ6i
Wß¬¶y¬¶Y~´1½á‚Ö#Ø‚)IÛ&´ˆ}A|yyù;ì¯Ø¨EàÐÿ,ãï0µL-ã»6ï‚,úÐþ•—®xea£'µ†‡^‹Eè¸ÖB‰fóx½ Þ\~*ùm`×{µÄ_ûI·¢ù$zùâDq?ºOFb4Ówã»Ùh"žk¼VkxÔÌnD×qd£¹xâe¼Ä‚ð.
>¦^¾ØÍƒ\=Æî<bøÃå»wèEeäûAbàë82ðÁ#†¯Uo×Ï	°“’‚0Gs<3w“àó;ÈTÔ&uK@"˜ C=<þG$«ô“&èA‡$ñ|¥*òÏI¸N)¬0A@>žïéÅŒ?fiçl+3i 	B"hk‘QNWÔ¦³$¬°k>‘‘4Á‚$,9v)bÂZIpÎ“kOMé;õ+W¤ÿO7«4Yu‚…ÓUš9ÂÈh;:¼ÎÛMW8#=ƒñ0{€‘¬ñ/ŠµÕÕ'>ñ™¨<]mµó0KW+‹¡EìÑ"&óŒ¶‰ŸÔ
çç©0X!¯èùŠš#~ƒðz…“³£ßÞ÷)4ÞŽ§•ÛÉîç°ÈV¬ï´Þ"d¥—ü±
(LS„z· ¿|žzÑ5‰O$žñ¾9*‚âŠ–ŸañòÑÂzëh˜À¾±þt-§ùòRk‚9xÕÀ1ž]Éà#Â·ªñÀU[HÈNÇiNFoÇÓâA•…Âu„H¥Å¼î²Ÿà‰è®îÆwd)c¥­^¾@šf""qÏ“lð|®Â"Íˆ€ðíóxbBX¶ ´VDáŸ§ ¬¦T®£o•‡Ç“ácÄÁ‡ï«=äýô-ö,“™üÁsí§ºöR‹ÆÙÁÎT`6Á!zRÚêR¬TøOY\(ƒwâ¼æ>B•PEP¤‰êShÅÇ®Ç0H‚•è_“J¼?PºíÁ¡Ësàe–îYk÷=¨f=0¬[çÀG¬‡†uû=¬f=4¬½sà’u‚²„-ˆõ…·*A!R˜;Ï¶qÁØ5BLf°Ëå\@Üøê¡!î	ÁØ`½éƒížÚ®ÜŒå¡­®¡íÚâth¡ÁéÜŽ¡*Ù­6Æfs%;¤ÍF=·ÃÕÂóðÒn¤Î¾ÑDüû‡ÉLôE-MVŸQÃsé«z‰üâ?@8f
}
IæU1Yâ"§¸ú••þUEá1™M©¬Ö{ÈÄ}DäÙÔ(ƒÐ7›”ˆ×Òî¼-gƒ‘A¸å.)µˆéi¤œßÃ³RÖë¶¥øj›³ÉØ›V_à¦'fÇÀjW*ŒqBð·Í7ïÔS ÊÙíáàƒ½KRbóàAb>$^Á…ð€',ã—=‰Ä&$Þ·5‰„	hM"Q›ïIðÞÕ$ûˆ™;°)“H¸‘ £ˆÄNf
å)‡|-¾»
Ùë¹6ÙNg÷ý·ÂsêûÙt{Téù\é™€„ÈÌIUh«Î ¨KÁq\ÒEÂb GÀy	\§Ÿá„•È!{{–\A"EmƒUÐ:ôˆ SQ’r¢×¹’szº=‘‚ŒÙ:¨àª‡:,ˆ@ž·oånO’QÕâ˜ÁÉ°*:¶‚:Ehàçèp¹¸˜A»•"ÓÔ¾‘n—jdü<©&iAhCêhBj¾ëuÒõd§ázN«ÕðÇ÷ëâÝ¯,Ã%”Æ²2ÛÆªâ~<œ<ü„D¹Pd7Ò•þ7µ§›oÛ’Å4»Îßê„¢SÚT‹åšèÇtu)ÞÞÈV»ÍD®!jÑ†Dã˜`ãÝBR×9K„Z—ßu@å½è£ßÉÅ”žËDR[¡)Ý¿I×PÑ™­ KÒD:CÈo¤ÓíV™©ÇOˆ0€¹˜ÛØÂ¢Aã_÷ß`+6ð_/^›Ö®bÚBéú¡eÏÔ<ÃÈ1°÷™Îöå‹ù‡Œ„#pÀŒôéì$×'XÀe¯¨Ö›È³ðÃSœ„u	Ššº’P]ÎQ¡5¥s—©/Åû¯§–æ³¥qiXB æj{H2mŠ&"Ÿf"j›ðCÁÆÆ¥rÐ!iå¤Îög6m¤Ù%Ne•Å¹œâB>T³¸–Å…§¸(K©¸˜ˆòbo	õÇ,A4Ö-çZ‚ˆ¬%Zî3KàT©ˆõa›ãéw¶N*N¼V—Ÿ4?Þš ¸Ä¿ñ=¯å×‰æó!™ð1Ør0û.·‰q’d¢ÂÍcº1i4dNç:£#Œ˜ã-ˆ¼fâÒ{žõw7Â5t‰[×z]‘Ž˜ˆä1Zå
§ùfN•…#$NH¦ÀÞ
·ù†j¯n«Ûâ·›o^Õ-ì5ßÜ
Ÿ^ÿ[ÜVÒthð˜ëOÂ49IÁ)]%QPHžÄµn__‡‚ßO+iæ</à»§‰´®_=!e´ùbµáÏÂ˜F’át§kG~Œ!¯%®E’²óX8»@‚i¼kçø…5ðÛW~û,Mç:/ÒÍÕ‘+1¯±Z¨H®Þcº§ÖºEGº•M?ï4Rïé¬ÿúû»éä™è»N'ç›ÀþpÜ¿È…ßõœê& ?«Ïl?œ½96E|9Ý†Óþ*@ÊÉJ"Þ§åÞmåžAÑÔÇaÆÐ6 a%ÿûñíx4ÜœO g:ì¾JÝlã<§Ã‡É®8šªÀÉW‰%b»ëu|á¹m·Û®ïÊv[È–t:®àM/ZnÇïÒR¸W´\_ÒwWµõê1=dWÏ•æ[{“Ô“ÔE¿äöLrCGçK/_H¿…Ó®DEÚvz>ÈÚ]A‰SxÈ¨®‡7]á·¡‘uQ$»DJ°
ºú%X3zG¯ð?Ié”DIMª¤¨/)EH_¤')ÙåæÑçæò`CYíY>È¢v÷¾^íYYnâàsFÔÒ—ÒhDy( ¬‡Pcq½Èè" ÀyÃB'ˆð‘å¹#3rÿ§kDbÄx$´ˆR¼F}‡$S°Œ(*ex1ç”é¾ (Ï~GÂˆÒ%âüõÔ4aˆÇo)Ÿ­ ~oßaTŠ[ÜX9<®¶Hb“©Û¢5põ“¢ó«W
ÇÛ³TL1	
€-[ÅÐ‹q‚§l»afäÿtì7´ÛËt¸»6QSaÀ72&q²ÄÏÎ±J0SÌIêa:Ê]+6YL=Úd˜ŒšdÇ4£cˆØ
}‹lØN5v ±›’ïXjAöºÍ£kõ-ÚrŽ€nCÞyÉ{´<Eãòj‡%ïÜòF+âq'R‰6¼×–7úÛ*™žÛb]r…«©ùsø®Ùs8ü—~3ºš²³Õ§Î®CÃ²b¸]gÏ¡a·b¸«]‡†[Ãa½i¯±ñnO½&Y¶g†‡Ï†Y¶ÏÌÛÏ™K–ÝÑù³b˜d÷õÜµ€Á© ×Ì}„³R:×ºÀJÎ‡zØÌ}†&òßý0ßX¸fî–š/ô”ÞD=4s7ÔvWt*Nj­£¹÷OUkÌÝ>¹ÖÁÜ;Ã$þ±Ë„	Eh,=ÕÓñ¦ƒÜŠ>þÅÌÆ3°c;7}ªà>kº`üÇ·©¶¯æþŸ˜¡ËM‹‚U4¦H…¿5ÚZ~„™‘½ª:‡)x+
=uœ—HìTåU!¥¼ò$ k‚{_{+nlyC:ì=èºof¡,fps§1º@{7øÎðvšî5nSq¥µ‹y©é*°Öl´½¤¾¼áÓ³ÓpõÎ4ê#“Ó«6ò;`HåTÒôõÈ°v>¿±L…™ž/bj'¹žpŽ-ñ5WÎF³cÅ(W™µ_¼s¡YÈZ1KÉãêéx=,Ÿo<CìL,±*ŠªFzT"­¢yò–‘yhS¨¿ÈoqÕ]y‚íž ŽutGoNùE×|?Lû“SdyI‡‹ÈáøœMw|åNÖŠï±X¬¨uŒÅíL’›È •) VŽ­¬»}«†)qèØžr†ú×÷?ÞŽ¯FÃIß\£«Ñácá =ï¡fêárŽÃÆ§Çe‚†î´5V2µ(:%:6ºsLÐƒÛ ¶ ·àÀ9Ò5ùTÿPK   RRúÆç½¥	  ¹     HOW_TO_C.ODE/TRACK/INITS.DO­X]oG|'ÀÿÐ	È
(F–?èå°¢è3/¤(ˆ”‘<†»Cz„ýòÌ.aå×_UÏ.))BÃ6?vgº««ª{V~üg^ÃW’Ãë®jWZ¹½[®ï’É¯Ó;ÙËÅøu2ü»`ÊFr+×«[yòúÆJÿçë¸Ò™Ì2k¥ònçJƒ=m#i•éÞ—2ù˜,W?­’›Ùú÷ñß¯TºÆ†ß¸ª”É|²¼á‚µ¯vcüëÊÔÕ&¿”ëéb¹H÷OÉÕŠ¬Ÿ¯Ô´ZÞß\÷½ÿùüü\Lfê×ÆË|š\ã‡åÍT^•Ç§/cJ|ãR¤õ*u’Ùª6œ¾¼×´!8ÁÝÝ?Ãþy}v*]h€ø—Ö^g/^¼¨Û>ió¦mFâry³7Ny±º{gÛ¯²Zá{›JÀwÀ9EŽ¶õüXy+ÃÁïÉ"Y,×K‘W¶ý¬Yò«ÉéXn+\¹5¢âT¹³ïŠ*ŒËu\Ô=Ãp°5…m®˜|œÝÊâ~5›¬$k¥ñønçM™É"¹ÆßßÆrmqO«ÆÊóè±R²˜ý;YOï‹¡ë•·Éý<IMm6¹Æ“z“~¶žo7Ö Yä„ð@Ô†$³aŒô’¼òÁf6u™^íma3‡;¤67#Rû*¯[ÏegK§›äFBjK"•¬“»™@ê#¸‘¦•ºrQ5–æÂÏxýj=¾õ/˜ŸÈÜjAÊÛ0ëÚè®ŠŠ‡í¾´È¡±]lÒØ¢R aÒ~gBíòœAÅû]QW¾+Œ¹òjÎ6w•g†¶1×ßòZT"µŒšÜN¬øp°0.Äb”,Ü‹]ãVMÕ>TD	¹ 1¦H uàDD(Ø66ÁÐÄ”ô«\r“Nù‘—Hù­ì+G`Võ¶V¬Z7’ŸãŒ¶©PÕR(jƒ¡Ü$àYUBœ+Û2ô²5©»3>C5ZŸVEÛÙ8¢ÚÓŠH´ôµõÛÊ¦L•áàÿ~võpPj©bÄ@=H¬>ê.bË­+E¼Û+ïð®ßSà
ˆ·[DÖ¹y”Üm¼E	bF’™2!ê…Ä y­"Ø–áŽèÿcYE?0v±¡Kn|iOpsybH@…0¦-ãÎÜvëÒ6o˜4a çcÒG@L“,È¯	7q*l±!IÁŽ¯ÚªùË+Õìevdô`Kv©(’á æs*Š¤-Cdöl¾’ùÉòf|gkùî»ï¢	^Àoc;P°¶U™²g”šÇ7Lñ[&972¦{qÛã"Xà».ÂUz:Ê-˜´&Ô
Ç—Á§¸ÓúRÝ ·iÓúÞÐ)§ÝŒŸ`!~Èˆ¬ÝnmÃÿ±>~òrýjÒ&#.PPk}˜Jj0ªÃ’:®Zz‡È‹ª|cì 8w¶t¬ŽZ“ä`yí(
|"çZÏt5Ø{—ŽV\íXã o§QôOÎáýË0Â>§	S7l¹oÎ¹…0€59
Î»…Š+©,Ð«X˜ Þî«¼-¨ËÖE#D­c]óD*è^®„ËuHèc¬¼Òñ­Ã’Æ [²~¬Þ'£ ˜ÒÏÆï¬¨v4<¶>±#QëÞ¦&O£(ÖÂ}å[.Û¯-ÜÙ Å˜æR@¬ž:±Z„Ida‰%kdË½ó€ìÝùÚ ÕF{LÚ¦¸LïÈžêåõ9xJ	¡¥„~!õ‡áàU¼¾´•ë(¼·>°8ÿú[MtŠèo8tÐáW ÊúÇ
¯§w‹ÙM2—÷“_åþV[f/sâœ#…ÌnMt#¶#­‡rPÊŠåDÂ²WƒQ
(NtåÓNÓ”ËH‡;Ç…¢¢ÅÂÌclõ4r‚æ©âŽã#¼XD³m£W+­©	Ó×27›ãÿØu©ÁhêàtìA½ŽÇð§–€à8ééÀ W(ñ¥Ž}Nó>Œ¾%Šr\yŒöæ²R»Î‡RY/ïWPçO¦|Îøc™X8$æºËp£ÞC4 [RN½…ÀÂ5p£sb :•Éƒ¡ƒ=t”©ftŽ®Å ¸VÞ£§AàqeôoÞ¿~+wëé\®ÆÉx>~2“IoAÅCÞæ/™`}6
·¦ŸÕÃZæ–SN#U©Šÿtv`v$Ž¡A[¡íf$÷ü<¥õ]óè9wñu—úÆ„ƒf#³òãD‹;6SºÎÙYkÚ1†¸ÒaòÖ•{$GGŠF˜iC‡áN´ðÒ9µ6ÚFíFÇ„øËpp8ë<iªý©ç”^CÛBŸ«Ð7u Á!¦Í#gµG)[	SÒ¾é¥žWåÇ~w<iY2G±R°âôm™NË"¼€8ðÐúÔªnÍ(ö=Ñõ|”¬×Ó›õlyVÌOþ\¢O³kŠcIDƒ¶¶Û_u€øøîîÓÕˆ—iv[·kcá1°‡âˆ“ÙŠ.úæâüÇœýðöâÝ{š´››óhBgá«BSD?Ã€jÕúÔnTq€¨æ|åtbRé`òk£Íõ8aÚÓã‚ò4oã°rØ!T”«v|Äò‹s@y> Å šn(µq£ì8„‡Îøç'ÝQ«ñÙù"²áÉ ‡Hùå—ºAË^ŠÌr¶L~jÈá„esÍ¢ÊÚþ^úæ÷àÈÆ•ßÇž˜iuÜÞ÷ÙÃ*\Ú±‚¢Ñ¾ŠÙ<*Dà*Ñ8œsðˆÄÉ9ªªa_õ#ôâ‚†”Çc‘WÏÀˆç¤îRÓ©yeîê6 ÄfO?Ñc3’íP¦ÝQ<Ô«„S›RÍnt¢«Ê]Ëza³ð±žýfÇ 
9€+¸–ƒ~ÖöÆöJõö$s<;8ê‰#YÏ’Ö£õñYÈònç¡ô‡> ÚßHŽÃ¨ê#t©~½WÅžzò`Ñc9Cœ³°cûµ#Ó;X÷f[pñ€aÕªÚW×+ÏfáÑ.¢•£Û:ÔèÎ0¬Æ+ƒ~ÏI¡ƒ
V¥O­ªÍƒUþñ\jâÃ—£_s‚8ÐA ÑéPWz~í\\ÛoGÝÞRHš¥–\’ñ5âÒóltWœä;{e«}²_¦zc¯¦J®le²\Ü&ëÙÕ|Š±MIÊž0à!õ&9yñU²ZMånºZÎïé€
÷§ÊñÆÀˆYo_zHˆÊ	´î³—ÝöY³=“+‚YñÜÔ6gß+ Åq‰áJ
'ÁˆSuP>`8ãlxúå¬e9'fWW+ÑçGÿ`M§{eïðúŒfñ$ÚüJÉt¾˜ÓË—/áS×)‡C"îYbžOŒ1€Î¯’°|Xü›/nb²å}ms7ÒàgºJÿa6ÖUì„VóFòR¹;J”bßJ²c*ömÕV©†äPæšä0RJòë¯¯†¤Ûû!yžlD »Ñh4@wócðÝçù'øñè	!˜Þ–ÛÍlYTÁ¤FyU«r»†‹²:99!€Ä>gÁ‹àÕr¶™åóY•ofå²
ŠM°Z—wë|± ®Ö³åx¶ÊçÁ*_ƒó«×Wýž¿ý¡:¼yÛ?»áœb²[Á`ø†cœ½ì¿þ0ì_¿ºùíUó?„X’¯6œ« ˜N‹M¼Y—7ë|ü±XÑ	ëó&.Ïûƒó·Áëëó“FbŸOfGO†Ë	ç¡œÿòkÐb­ÖÁpü¶W9ÎÅ¶šý¶-Žž´ðQÉÚ«yþGð¯ûb³)‚ /¥dßÙ"ÓŽ0qê¶ÈÇë²ªÉ©‘ØçØC¾ºŽ×EÚu…íƒhæE´ú“µ¬`ÏVãçí<DyŠÑvä“uQUÀq1^çË
På}±8™·žåáóö$|1a\¼gòõ]Ì4
&årY
úd´&¬ßsØ¨4FÁÂF°èèIp¾œ\ÁŽž üí¤X.[Wý³·¯žœTÅJþýZW¯ßŸ¼IûÅ³áê9§Uå÷0ÔYýoÖ¿Oo†7ÁS–ÂO
S¯\cÍús Ðéa€ôG³M´ 5^-_¿¾áíqô?‹uT¥ÀGôþõ@pS}È'åƒb@yõ1@ÁÔ‚óöÞö±=QpÍb“?ùr¿Ï6`˜Doeë¯ß6_–ÍvêÛbˆY)‹gÕêù÷ªÿ0à›r­¤u~="ÿJKÍê}Õ‰Òº9ÿ7üÎŽ«|¶Äi¡´ô!h=» Z 3(Û¬ó”0V>™ü†Zü4kW+ø=ž¯Ü…?AžH—hþ¶Zñ‰‡#ðf6/°à|5(¶k–‡í!¨òí¯U“vƒm[¾½/
Ä8Øp»¢pœp…e÷³
Ã´ ˆØµã(ÃvµæŒ¼ZÍƒjGÕ:h	‚T›bÑÒ‚¶ÜÍªèLPñ* ¼š^6ÐP àw{fy,ˆ«X*·ËÉ¡Å$?³9êØuGœ 4i·`ÅªuÛE°L?fÃÓÊGló=yŸ#­U>FÈñb5;!$›´§øÏ8ŒNþ¦ÜŽ?ÁY¹Ü¬Ëy¯VÛ?Š"@ûR¿­˜t·7³E¡Öªr;kã`Íî–ù¼XóIßÚTdÅÆ_0»âËÊ\÷‘ì¨øí¤
Z×å­gŠø²\¶aè7DcžOÇÀn8Ö{Ý0¬Kf¦%ØŸÑ<_Žqá´ÈU¿¾}7šK%Ë0ü†ýC!º C€l`‹%àÎ/Æ[Xç9ßw]©äÚ%«BŽc0/ïpeÿaõáêÓ„Â‡MpêÊ;â°dàaYÎÖ(EÅð@ºoú½¯aØä°Âÿ°Ì‰4b¢ImBÀ¥»âÚmó˜¯Øã|žÃ"¼ Ã¿*g“*˜æ³Ñ¼°Éò®u#Ýµ>%<[”Ë¦åz£MÞˆ/Ì
oàÇM=7ÂàÓâöš´È$8¯°ÆšT<ÏÐ0çBƒÞ°tíµª¿Ž±$û›ÝFÌ±*4·É·kËºº¦•SE…]{ðÏ×ërÍ‘øÃX¯fÒr-…í|^ˆí·‡µu%l»úzVnç?Ês‰"ö¼ç+Ç\ÙÖŠŽÂÂB\E^z¤DuóP©n(ËûVì,¨ñUâÝgzë‹RÓ*3Ü”+²Êô¡ï›½+LÝ²·Ö›
ˆÂÿ;*e“
¥ÎdQZ§í‘(|tNÐ
%'Ž›Ì¯±åRGE½Ù*¸Îcüµ¶\aøAä\â_¼ßæØÿíÌ:w“mpÑ¿<{}ýuÎdfK¥c¯çYBl•´˜00|Ãv—¯'j~ŒƒÖsz±x—‹y¿ øEÖÙJìÉ%,HçäA¢YNgwÛµNÖã°†…Œ¢¼›MŠ2x& gQq#_|(“æFôÒãâägøÇrüa].ÕXß#" …TP¤×Ó)ž¸_2ã9Î–9lËŠ:*)ê%žˆq,¾Ý*” Xâê\ÕYÍ,T0‹å|Ë¹ÞÔÛÉ²`¡»u„nD^¾¼y!…áM(èÅŒÏ‰I1.'¸µ¶¡¡û]‹-á@8¹k‰ý¾XÃê²îò­­Æ
<÷‚OÖålã[ýwôßþ—Ã:HÏ«—ççuÜø»‹Ï÷
üÛÙþô` ïF\¿¸?Sö<¦XKÔïv‰zìè<ø%–ù¬ªàŒ+ûÍMÚ<¶„ûj	Ff!Ý¦k=Ü)6Ím3õVn8‚»ÕlåŽ½Ày±öÀ¦^ØÉÄÛñÂÎŠuîî5<À#?ðÊKyÒì£<õW>ÊŒ5{(3¿”g/å´	ØGÙ/ç{Ï°ž³âá½pï¶úøÑøSüdüzú$KæÂÚÌRÄ¡=Eq#ô™:m„öðùå¾{ù5v]ù`ý
»ñÂúõu;¡‡¼cb êt~"¹	× t=GK§°;pGÖán0»ë@™Ý :>¿<½¤PÐõÎ†bÌæ‹ Mv€žY Ñ.ª§h¼‹j_íf¥ÁNnÎ¤_hÎ£/z_Þ¯§½í‚{gyWñó£ØßÜJ”–f ‚ÖÎvcqìÅei2šò=¯KÇšQy¬‚e|?Æ7Â†cqv9®-GO£4ÕŒGiæ².TËû¸gŠ{—y›ŒÓÝ,ï‚:AW+e—i¯õ®¢°^Ô=ñ¸;òºÅ¹\Y„5Â/¾«)/Ý^³»ýÁ¸Ûy;ƒju‹Ç;89ÙœYÞÎ´ÃÐI?–Dâgµý&ÁßóøDÃ0µÜûŒ«C†ó‘¥j˜i+M’à\³ŽñŠv×PgÅac!ý±\aN·ß];…WådË]ˆÆy~_ÎÆ<ºÇÕMj›FæM,6·ëâ·›fd(8kÉ”‹ö²GÍFÉ®ô¾ºòñz1éè†àµJ¢$ËÒ(oi$›¾˜Íç9ô¥  &³û­òÃ&´>Ñ£Gô7fqkS§‚Òå‚¿„ˆ„ŠG­rEÝõ¦GÄd³Bôüxœ‹o®NþyòMû8‰»ˆo¼‰¯–°üÅ†›Ôˆê°„Ó7Øz2±ö° <ìÒosuQæ_œð*Y{B‘¢öts¯!TSCª‚oV²ò›Ûeq=º­òÅ
L¢\—‹î¬Ám\mÅrSÑV(_¢z"3i¹ø:Di~ã¶ôvÃW›±¨5\Ò#¡"Hj4£xe1[né™^B¥†¾¶^R{Ûù–ÏŽÐÑ]*62fÀÀÌŸóe
¤É‚Ÿþ—–é°õæò|x¢G8ÊÅ˜G|E+gKtŠ‚s×Ž-z)Xá@”´Hà°E‘Q1CÂ%]‚©¹¼Û| 0Ïò¼ÛèG-~ßðy‹>‹¿ÛîÏHþ|šÍ5‘M¶À7Ðù|¼ÅÕOq¾)7ÂmYÑn›©ŸHCÙó_—ÁªÀ#r ™ c™ïƒë(ø¸Çœ0×'±¤Ÿñeÿ^xÔîóõE6»Ï—Ž¢á|Wm5Íª@´“`¶Öôå}±œ­5°h1‡ö·7#¢ùJ¸LEöLË© „/Ð†ÜÓ3ý>{_ ÐÕ&—´È¸ì×ˆ¡B£UÍÃ{c(À)oq›Oð‘:f¢nç—J74X¡À4coXÍ67ë­å©:;¡Ü¡=ŽušÙlå‰Z·£Qäè$®½1Y[X›BŽÖ92$‹PxÍ¼ŸÀ[Dy'oI3oãÄÌ3‘ýe„wK&iÍÔ)ÈŒB&í<£ÝŒCÑÍÈéi©°º‘‘nhÑ2jSL´©bï&Ê¬Vt2k­gc«ñih5žÖd¨ãR^Êþèq‹ÛFwÉ`ÊÞéð¶V]G³åº*T‚/åÄtY³‡nô6Š£½¹ óo]åæ ›Ø+µ^L¶«qRžý{M"vÌÃ7·“|“Wl T-’iaÛ%*-¡Ú‰S$†´ëˆJ£°;PK°,©á9¬'pYa‡È–0åO9PÁÓãQH¥NòE´)E<Ø¢â>:èÂíµÎ ñ'Ìñ¢zðÌéH=ÝJ™S¢&E˜‘¼W!ý¾ô)Ì„iO3ô=üÀº¥¬^i(Éü\mç›ÙJDö¬•–Çœ3|ebCÐ^.2šl1áê72¢ÙRcáôÉ=ª1ªs*‘ä	~šâˆ+¡©€Y-þµ+üG