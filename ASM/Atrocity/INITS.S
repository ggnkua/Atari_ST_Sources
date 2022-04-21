*************************************************************************
************ Routine Soundtrack DEMOMAKER au DSP ************************
*************************************************************************

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
	incbin 	"d:\brain\rps_3.MOD"
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
