;**********************************************************************
;	Filename:	    Eiffel.asm
;	Date:          	18 Juillet 2001
;	Update:         27 Novembre 2004
;
;	Authors:		Favard Laurent, Didier Mequignon
;
;  This program is free software; you can redistribute it and/or modify
;  it under the terms of the GNU General Public License as published by
;  the Free Software Foundation; either version 2 of the License, or
;  (at your option) any later version.
;
;  This program is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;  GNU General Public License for more details.
;
;  You should have received a copy of the GNU General Public License
;  along with this program; if not, write to the Free Software
;  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
;
;**********************************************************************
;	HARDWARE DESCRIPTION:
;
;	Processor:		16F876
;	Crystal:		4MHz
;	WDT:			Disable
;	RS-232C:		MAX 232A converter, TxD/RxD wired
;	Alimentation:	Via RJ-11 cable/TxD,RxD
;	Revision soft:	1.10
;	Revision board:	C	
;
;**********************************************************************
;   Remarque logicielle:
;
;   - Compatible avec le pilote realise par la societe Oxo.
;
;   - Compatible par defaut avec le protocole souris atari. Le PIC
;     transforme les trames souris PS/2 en trames normales souris Atari,
;     quelque soit la souris branchee.
;
;   - Ajout des scan-codes supplementaires pour Atari pour les nouvelles
;     touches PS/2 et fonctions nouvelles souris.
;
;   Voir le fichier /Docs/ExtensionAtari.txt
;
;**********************************************************************
;
;   Ce programme permet de traduires les scan-codes du jeu 3 (ou 2 
;   depuis la version 1.0.5) d'un clavier PS/2 vers les scan-codes 
;   Atari IKBD et de gerer une souris PS/2 standard ou Intellimouse
;   a roulette 3 boutons et double roulette 5 boutons. Les boutons
;   4 et 5 sont affectes a des scan-codes.
;
;   Les 2 joysticks prevus d'origine dans l'IKBD de l'Atari peuvent egalement
;   etre connectes (depuis la version 1.0.4) :
;     Le Joystick 0 est branche sur le port A du PIC:
;       RA1: Haut
;       RA2: Bas
;       RA3: Gauche
;       RA4: Droite
;       RA5: Tir
;    Le Joystick 1 est branche sur le port C du PIC:
;       RC0: Haut
;       RC1: Bas
;       RC2: Gauche
;       RC3: Droite
;       RC4: Tir
;
;   La commande d'un ventilateur est egalement possible (depuis la version
;   1.0.4) :
;       RC5: commande moteur courant continu en tout ou rien via un MOSFET.
;       RA0: entree analogique temperature AN0, une CTN 10Kohms a 25
;            deg C est raccordee entre AN0 et Vss (0V) avec un rappel a
;            Vdd (+4,3V) de 10Kohms. Soit VAN0 = (4.3 * RCTN)/(10E3+RCTN).
;            Val_AN0 = valeur ADC sur AN0 soit 0 pour 0V et 255 pour 4,3V soit :
;             Val_AN0 = (256 * RCTN)/(10E3+RCTN)
;
;   Le soft permet la connection de la carte a un port serie RS-232C
;   ou directement a un ordinateur type Atari ST (RJ-12 ou HE-14).
;
;   Si le programme est compile avec LCD (depuis la version 1.0.9), le 
;   SERIAL_DEBUG est supprime et un afficheur LCD prend sa place en RB4/5 
;   compatible HD44780 pilote par 2 bits RB4 et RB5 via un 74LS174. Dans ce
;   cas les jumpers de debug qui suivent sont inutilisables.
;
;   Les deux jumpers permettent:
;
;   Jumper4, permettant d'activer ou non:
;
;   5V sur PORTB4: Mode Atari  (Translation des scan-codes clavier/souris)
;   0V sur PORTB4: Mode direct (Pas de translation, Scan-codes PS/2 direct)
;
;   Jumper 5, permettant d'activer ou non:
;
;   5V sur PORTB5: Mode normal (Connexion a un Atari)
;   0V sur PORTB5: Mode debug  (Connexion RS-232C)
;
;                                       debug          normal
;
;La frequence de transmission serie     9600 bps       7812.5 bps.
;La transmission des octets clavier      ASCII          binaires.
;La transmission des octets souris       ASCII          binaires.
;L'emission de la chaine texte          'debug'        non
;**********************************************************************
;	Notes:
;	Crystal 4 Mhz, Bps rate for Atari = 7812.5
;	               Bps rate for RS232 = 9600
;
;	Serial frame:  1 Start bit, 8 bits Data, 1 bit Stop
;
;	Jumper4 	=	Pin 4 Port B	(Disable state at 5V with pull-up)
;	Jumper5 	=	Pin 5 Port B	(Disable state at 5V with pull-up)
;	LED green	=	Pin 6 Port B	(Enable state at 0V)
;	LED yellow	=	Pin 7 Port B	(Enable state at 0V)
;**********************************************************************
; Voir le fichier technik.txt et evolution.txt
;**********************************************************************

		PROCESSOR p16f876
		RADIX dec
		
#include <p16f876.inc>					; processor specific variable definitions
#include <eiffel.inc>					; macros

		LIST      P=16F876			; list directive to define processor

		__CONFIG _CP_OFF & _DEBUG_OFF & _WRT_ENABLE_ON & _CPD_OFF & _LVP_OFF & _BODEN_OFF & _PWRTE_ON & _WDT_OFF & _XT_OSC

;----- Flags compilation -------------------------------------------------

SERIAL_DEBUG                 EQU     0; si 0, PORTB4 & PORTB5 enleves, mode Atari seulement
                                      ;       laisser a 0 pour les cartes a Lyndon 
SCROOL_LOCK_ERR              EQU     0; si 1, utilise pour afficher les erreurs parite souris PS/2
                                      ;       sur la led Scroll Lock du clavier
NON_BLOQUANT                 EQU     1; si 1, routines PS/2 non bloquantes (time-out)
PS2_ALTERNE                  EQU     1; si 1, gestion alternee clavier et souris PS/2 
LCD                          EQU     1; si 1, afficheur LCD a la place du joystick 0 compatible HD44780
LCD_DEBUG                    EQU     0; si 1, afficheur LCD utilise pour voir les codes envoyes a l'Atari
INTERRUPTS                   EQU     1; si 1, timer 2 gere par interruptions => besoin d'un residant 1.10

;----- Variables ---------------------------------------------------------

; page 0 (utilisable a partir de 0x20)
Status_Boot                  EQU    0x20; remis a 0 au reset
Info_Boot                    EQU    0x21; mis a 0xFF si le programme demarre sur la page 2 en Flash
Val_AN0                      EQU    0x22; lecture CTN sur AN0
BUTTONS                      EQU    0x23; etat des boutons souris
OLD_BUTTONS                  EQU    0x24; ancien etat des boutons souris
OLD_BUTTONS_ABS              EQU    0x25; ancien etat des boutons souris en mode absolu
JOY0                         EQU    0x26; lecture joystick 0
JOYB                         EQU    0x26; = JOY0, juste pour tester eventuellement avec JOY1
JOY1                         EQU    0x27; lecture joystick 1
BUTTON_ACTION                EQU    0x28; mode button action IKBD
Counter_MState_Temperature   EQU    0x29; machine d'etat lecture temperature (reduction charge CPU)
RCTN                         EQU    0x2A; valeur resistance CTN / 100
Idx_Temperature              EQU    0x2B; index lecture tableau temperature par interpolation
Counter_LOAD                 EQU    0x2C; compteur octets recus par commande LOAD dans boucle principale
Counter_Debug_Lcd            EQU    0x2E

DEB_INDEX_EM                 EQU    0x38; index courant donnee a envoyer buffer circulaire liaison serie
FIN_INDEX_EM                 EQU    0x39; fin index donnee a envoyer buffer circulaire liaison serie
PTRL_LOAD                    EQU    0x3A; poids fort adresse commande LOAD
PTRH_LOAD                    EQU    0x3B; poids faible commande LOAD
TEMP5                        EQU    0x3C
TEMP6                        EQU    0x3D
Flags4                       EQU    0x3E  
Flags5                       EQU    0x3F
HEADER_IKBD                  EQU    0x40; entete trame envoyee au host IKBD
KEY_MOUSE_WHEEL              EQU    0x41; scan-code movement des molettes (Wheel&Wheel+)
KEY2_MOUSE_WHEEL             EQU    0x42; octet supplementaire: Scan-code bouton 4 ou 5 (Wheel+)
CLIC_MOUSE_WHEEL             EQU    0x43; octet supplementaire: Scan-code bouton central
Value_0                      EQU    0x44; 1er octet reception trame souris PS/2
Value_X                      EQU    0x45; 2eme octet reception trame souris PS/2
Value_Y                      EQU    0x46; 3eme octet reception trame souris PS/2
Value_Z                      EQU    0x47; 4eme octet eventuel reception trame souris PS/2
Counter_Mouse                EQU    0x48; compteur octet reception trame souris PS/2
Temperature                  EQU    0x49; lecture temperature CTN sur AN0
Rate_Joy                     EQU    0x4A; temps monitoring joystick IKBD
Counter_5MS                  EQU    0x4B; prediviseur horloge et base de temps 5 mS
Counter_10MS_Joy_Monitor     EQU    0x4C; compteur delais envoi monitoring joysticks
Counter3                     EQU    0x4D; compteur boucles
Counter_10MS_Joy             EQU    0x4E; prediviseur envoi mode keycode joystick 0 (pas de 100 mS)
Counter_100MS_Joy            EQU    0x4F; compteur 100 mS mode keycode joystick 0
RX_JOY                       EQU    0x50; temps RX mode keycode joystick 0 IKBD
RY_JOY                       EQU    0x51; temps RY mode keycode joystick 0 IKBD
TX_JOY                       EQU    0x52; temps TX mode keycode joystick 0 IKBD
TY_JOY                       EQU    0x53; temps TY mode keycode joystick 0 IKBD
VX_JOY                       EQU    0x54; temps VX mode keycode joystick 0 IKBD
VY_JOY                       EQU    0x55; temps VY mode keycode joystick 0 IKBD
Status_Joy                   EQU    0x56; flags joystick 0 mode keycode
OLD_JOY                      EQU    0x57; ancien etat boutons joystick 0 mode keycode
START_RX_JOY                 EQU    0x58; valeur de demarrage tempo RX mode keycode joystick 0
START_RY_JOY                 EQU    0x59; valeur de demarrage tempo RY mode keycode joystick 0
START_TX_JOY                 EQU    0x5A; valeur de demarrage tempo TX mode keycode joystick 0
START_TY_JOY                 EQU    0x5B; valeur de demarrage tempo TY mode keycode joystick 0
X_SCALE                      EQU    0x5C; facteur d'echelle en X souris mode absolu
Y_SCALE                      EQU    0x5D; facteur d'echelle en Y souris mode absolu
X_POSH                       EQU    0x5E; position X absolue souris poids fort
X_POSL                       EQU    0x5F; position X absolue souris poids faible
Y_POSH                       EQU    0x60; position Y absolue souris poids fort
Y_POSL                       EQU    0x61; position Y absolue souris poids faible
X_POSH_SCALED                EQU    0x62; position X absolue souris avec facteur d'echelle poids fort
X_POSL_SCALED                EQU    0x63; position X absolue souris avec facteur d'echelle poids faible
Y_POSH_SCALED                EQU    0x64; position Y absolue souris avec facteur d'echelle poids fort
Y_POSL_SCALED                EQU    0x65; position Y absolue souris avec facteur d'echelle poids faible
X_MAX_POSH                   EQU    0x66; position X absolue maximale souris poids fort
X_MAX_POSL                   EQU    0x67; position X absolue maximale souris poids faible
Y_MAX_POSH                   EQU    0x68; position Y absolue maximale souris poids fort
Y_MAX_POSL                   EQU    0x69; position Y absolue maximale souris poids faible
X_MOV                        EQU    0x6A; deplacement relatif souris en X
Y_MOV                        EQU    0x6B; deplacement relatif souris en Y
X_INC_KEY                    EQU    0x6C; increment en X mode keycode souris
Y_INC_KEY                    EQU    0x6D; increment en X mode keycode souris
DELTA_X                      EQU    0x6E; deltax mode keycode souris IKBD
DELTA_Y                      EQU    0x6F; deltay mode keycode souris IKBD

; communes a toutes les pages
TEMP3                        EQU    0x70
TEMP4                        EQU    0x71
Counter                      EQU    0x72; compteur boucles
Value                        EQU    0x73; octet recu
TEMP1                        EQU    0x74
Counter2                     EQU    0x75; compteur boucles
PARITY                       EQU    0x76; parite ecriture/lecture PS/2 et Flashage
TEMP2                        EQU    0x77
Flags                        EQU    0x78
Flags2                       EQU    0x79
Flags3                       EQU    0x7A
Counter_5MS_Inter            EQU    0x7B; inter, affectation a conserver depuis Eiffel 1.10
Save_STATUS                  EQU    0x7C; inter, affectation a conserver depuis Eiffel 1.10
Save_W                       EQU    0x7D; inter, affectation a conserver depuis Eiffel 1.10
BUFFER_FLASH                 EQU    0x7E; buffer 2 octets

; page 2 en zone non remise a 0 au reset par Start_Flash si < 0x120
YEAR                         EQU    0x110; annee, conserver cet ordre pour les 6 variables horloge
MONTH                        EQU    0x111; mois
DAY                          EQU    0x112; jour
HRS                          EQU    0x113; heures
MIN                          EQU    0x114; minutes
SEC                          EQU    0x115; secondes
YEAR_BCD                     EQU    0x116; annee, conserver cet ordre pour les 6 variables BCD
MONTH_BCD                    EQU    0x117; mois
DAY_BCD                      EQU    0x118; jour
HRS_BCD                      EQU    0x119; heures
MIN_BCD                      EQU    0x11A; minutes
SEC_BCD                      EQU    0x11B; secondes

USER_LCD                     EQU    0x120; message 8 caracteres LCD

;page 3 en zone non remise a 0 au reset par Start_Flash si < 0x1A0
TAMPON_EM                    EQU    0x190; buffer circulaire liaison serie (TAILLE_TAMPON_EM dans eiffel.inc)

;----- Programme ---------------------------------------------------------

		ORG	0x000
		
		clrf Status_Boot; remise a 0 lors de la mise sous tension ou reset hard 
Reset_Prog
		bsf PCLATH,3; page 1 (0x800 - 0xFFF)
		bcf PCLATH,4
		goto Start_Flash; saute au programme de lancement de la page 0 ou 2

Inter
		btfss INTCON,PEIE; Peripheral Interrupt Enable est a 1 lors de l'interruption
		                 ; donc on saute le goto
;-----------------------------------------------------------------------------
;   		Startup, initialisation (saut ici apres le boot !)
;               passage oblige pour les interruptions depuis Eiffel 1.10
;-----------------------------------------------------------------------------
Startup
			goto Startup2		
		movwf Save_W; sauvegarde de W
		swapf STATUS,W
		clrf STATUS; page 0
		movwf Save_STATUS; sauvegarde de STATUS
		bcf PIR1,TMR2IF; acquitte timer 2
		incf Counter_5MS_Inter,F
		swapf Save_STATUS,W; restitution de W et STATUS
		movwf STATUS
		swapf Save_W,F
		swapf Save_W,W
		retfie
	
Startup2
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)
		call Init
		bcf PCLATH,3; page 0 ou 2
		goto Init_Flags

;-----------------------------------------------------------------------------
;   Chaine de caracteres de bienvenue ! (testee sur la CT60)
;-----------------------------------------------------------------------------

WelcomeText
		addwf PCL,F
		DT "Eiffel 1.10"
		IF INTERRUPTS
		DT "i"
		ENDIF
		DT" 11/2004"
		DT 0

;------------------------------------------------------------------------------
;		Boucle principale d'attente de donnees:
;		On regarde si une donnee clavier arrrive, puis souris
;------------------------------------------------------------------------------

Main
		;--------------------------------------------------------------
		;   Boucle d'attente sur les horloges: Polling sur KCLC ET MCLK
		;   puis bloquage oppose et appel au traitement de l'element
		IF INTERRUPTS
		bsf INTCON,GIE; autorise interruptions
		ENDIF
		IF PS2_ALTERNE
		movf Counter_5MS,W
		andlw 3 	
		btfss STATUS,Z; gestion alternee toutes les 5 mS clavier et 15 mS souris PS/2
			goto EnableMouse
		ENABLEKEYB
		goto Main_Loop
EnableMouse
		ENABLEMOUSE
		ELSE
		ENABLEPS2; autorise transferts clavier et souris en meme temps
		ENDIF
Main_Loop
			IF PS2_ALTERNE	
			movf Counter_5MS,W
			andlw 3 	
			btfss STATUS,Z; gestion alternee toutes les 5 mS clavier et 15 mS souris PS/2
				goto TstMouse; gestion souris
			btfsc PORTB,KCLOCK; front descendant de CLK
				goto TstAtariSend
			ELSE
			btfsc PORTB,KCLOCK; front descendant de CLK
				goto TstMouse; le clavier ne se manifeste pas, on passe a la souris
			ENDIF
			IF INTERRUPTS
			bcf INTCON,GIE; interdit interruptions
			ENDIF
			DISABLEMOUSE; bloque souris
			call KPSGet2; => Value , on recupere l'octet clavier
			goto doKeyboard; On appel le traitement Clavier complet
TstMouse
			btfsc PORTB,MCLOCK; front descendant de CLK
				goto TstAtariSend; le souris ne se manifeste pas, on passe en controle commande Atari
			IF INTERRUPTS
			bcf INTCON,GIE; interdit interruptions
			ENDIF
			DISABLEKEYB; bloque clavier
			call MPSGet2; => Value, on recupere l'octet souris
			goto doMouse; On appel le traitement Souris complet
TstAtariSend
			btfss Flags2,DATATOSEND
				goto TstAtariReceive; rien a envoyer par la liaison serie
	 		btfss PIR1,TXIF; check that buffer is empty 
				goto TstAtariReceive; registre d'emission plein
			DISABLEPS2; bloque clavier et souris
			movf DEB_INDEX_EM,W; teste buffer circulaire
			subwf FIN_INDEX_EM,W
			btfss STATUS,Z
				goto SendData; FIN_INDEX_EM <> DEB_INDEX_EM
			bcf Flags2,DATATOSEND
			goto Main
SendData
			bsf STATUS,IRP; page 3
			incf DEB_INDEX_EM,W; incremente buffer cirulaire donnees envoyees
			movwf FSR; pointeur index
			movlw TAILLE_TAMPON_EM
			subwf FSR,W
			btfsc STATUS,C
				clrf FSR; buffer circulaire
			movf FSR,W
			movwf DEB_INDEX_EM
			movlw LOW TAMPON_EM
			addwf FSR,F; pointeur index
			movf INDF,W; lecture dans le tampon 
			movwf TXREG; transmit byte
			goto Main
TstAtariReceive
			btfss PIR1,RCIF; Controle commande atari arrivee
				goto TstTimer; reception liaison asynchrone
			DISABLEPS2; bloque clavier et souris
			btfss RCSTA,OERR
				goto FramingErrorTest
			bcf RCSTA,CREN; acquitte erreur Overrun
			bsf RCSTA,CREN; enable reception
			goto Main
FramingErrorTest
			btfss RCSTA,FERR 
				goto ReceiveOK
			movf RCREG,W; acquitte erreur Framing Error
			goto Main
ReceiveOK
			movf RCREG,W; get received data into W
			movwf Value; => Value, on teste les commandes clavier Atari
			btfss Flags3,RE_TIMER_IKBD
				goto doAtariCommand; Traiter la commande Atari clavier recue
			call Receive_Bytes_Load				
			goto Main	
TstTimer
		IF !INTERRUPTS
			btfss PIR1,TMR2IF
                ELSE
                	movf Counter_5MS_Inter,W
                	subwf Counter_5MS,W
			btfsc STATUS,Z
		ENDIF
			goto Main_Loop
				
;-----------------------------------------------------------------------------
;               Gestion sous Timer 2 a 5 mS
;-----------------------------------------------------------------------------

doTimer
		DISABLEPS2; bloque clavier et souris
		IF !INTERRUPTS
		bcf PIR1,TMR2IF; acquitte timer 2
		incf Counter_5MS,F
		movlw 200
		subwf Counter_5MS,W		
		btfss STATUS,Z
			goto NotIncClock
		clrf Counter_5MS
		ELSE
		bcf INTCON,GIE; interdit interruptions
		movlw 200
		subwf Counter_5MS_Inter,W; Counter_5MS_Inter - 200
		btfss STATUS,C
			goto NotIncClockInt; Counter_5MS_Inter < 200
		movwf Counter_5MS_Inter
		movwf Counter_5MS			
		bsf INTCON,GIE; autorise interruptions
		ENDIF
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)
		call Inc_Clock; increment horloge toutes les secondes
		IF LCD
		IF !LCD_DEBUG
		call Time_Lcd
		call Temperature_Lcd
		ENDIF
		ENDIF
		bcf PCLATH,3; page 0 ou 2
		movlw 1
		movwf Counter_MState_Temperature; lance la lecture de la temperature
		btfss Flags2,RESET_KEYB
			goto NotResetKeyb
		bcf Flags2,RESET_KEYB; flag demande reset clavier remis a 0	
		call KbBAT; preferable a cmdResetKey avec certains claviers
		movlw 0xF0; code de retour reset clavier
		call SerialTransmit_Host
                goto NotIncClock
                IF INTERRUPTS    
NotIncClockInt
		movf Counter_5MS_Inter,W
		movwf Counter_5MS		
		bsf INTCON,GIE; autorise interruptions
                goto NotIncClock
		ENDIF
NotResetKeyb		
		btfss Flags2,RESET_MOUSE
			goto NotIncClock
		call cmdResetMouse
NotIncClock
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)
		call Read_Temperature; lecture temperature toutes les secondes via Counter_MState_temperature
		bcf PCLATH,3; page 0 ou 2
		btfsc Counter_5MS,0
			goto Main

;-----------------------------------------------------------------------------
;      Gestion LCD toutes les 10 mS
;-----------------------------------------------------------------------------

		IF LCD
		IF !LCD_DEBUG
		btfss Flags4,LCD_ENABLE; gestion timer LCD inhibe
			goto Joysticks_10MS
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)
		call Message_User_Lcd
		bcf PCLATH,3; page 0 ou 2
		ENDIF
		ENDIF      

;-----------------------------------------------------------------------------
;               Gestion sous Timer 2 toutes les 10 mS des joysticks
;-----------------------------------------------------------------------------

Joysticks_10MS		
		btfss Flags,JOY_ENABLE; gestion par timer joysticks
			goto Main; pas de gestion des joysticks
		btfsc Flags2,JOY_MONITOR
			goto Joy_Monitoring; monitoring des joysticks	
		btfsc Flags2,JOY_EVENT
			goto Not_100MS; evenements joysticks
		btfss Flags2,JOY_KEYS; envoi touches fleches
			goto Main; rien a gerer sous le timer au niveau des joysticks
		decfsz Counter_10MS_Joy,F
			goto Not_100MS
		movlw 10
		movwf Counter_10MS_Joy
		incf Counter_100MS_Joy,F
		call SendAtariJoysticks_Fleches; mode keycode du joystick 0
Not_100MS
		comf PORTA,W; gestion evenements joysticks ou keycode action sur fire
		movwf TEMP1
		rrf TEMP1,W
		andlw 0x1F; 000FDGBH (Fire, Droite, Gauche, Bas, Haut)
		movwf TEMP1
		subwf JOY0,W; lecture joystick 0
		btfsc STATUS,Z
			goto Not_Joy0_Change; pas de changement joystick 0
		movf TEMP1,W		
		movwf JOY0; lecture joystick 0
		movlw HEADER_JOYSTICK0; header joystick 0
		goto SerialTransmit_Joy
Not_Joy0_Change
		comf PORTC,W
		andlw 0x1F; 000FDGBH (Fire, Droite, Gauche, Bas, Haut)
		movwf TEMP1
		subwf JOY1,W; lecture joystick 1
		btfsc STATUS,Z
			goto Main; pas de changement joystick 1
		movf TEMP1,W	
		movwf JOY1; lecture joystick 1
		movlw HEADER_JOYSTICK1; header joystick 1
SerialTransmit_Joy
		movwf HEADER_IKBD
		call Leds_Eiffel_On
		call SendAtariJoysticks
		goto End_Read
		
;-----------------------------------------------------------------------------
;      Gestion sous Timer 2 toutes les 10 mS envoi trames Joystick en continu
;-----------------------------------------------------------------------------

Joy_Monitoring
		decfsz Counter_10MS_Joy_Monitor,F
			goto Main
		movf Rate_Joy,W
		movwf Counter_10MS_Joy_Monitor
		call Leds_Eiffel_On
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)
		call Read_Joysticks
		bcf PCLATH,3; page 0 ou 2
		clrf TEMP1
		btfsc JOY0,4; bouton joytick 0
			bsf TEMP1,1
		btfsc JOY1,4; bouton joytick 1
			bsf TEMP1,0
		movf TEMP1,W; 000000xy avec y pour fire joystick 1 et x pour fire joystick 0
		call SerialTransmit_Host
		swapf JOY0,W; lecture joystick 0
		andlw 0xF0; 4 bits de poids fort
		movwf TEMP1
		movf JOY1,W; lecture joystick 1
		andlw 0x0F;    DGBHDGBH (Droite, Gauche, Bas, Haut)
		iorwf TEMP1,W; nnnnmmmm  avec m pour le joystick 1 et n pour le joystick 0
		call SerialTransmit_Host
		goto End_Read
		
;-----------------------------------------------------------------------------
;               Commande Clavier Atari recue
;-----------------------------------------------------------------------------

doAtariCommand
		bsf Flags,IKBD_ENABLE; transferts IKBD autorises	
		bcf Flags2,JOY_MONITOR; monitoring joysticks desactive
		;--------------------------------------------------------------
		;   Temperature
		movf Value,W
		sublw IKBD_GETTEMP; lecture temperature
		btfss STATUS,Z
			goto Not_Get_Temperature
		movlw HEADER_STATUS; header d'etat
		call SerialTransmit_Host
		movlw IKBD_GETTEMP
		call SerialTransmit_Host
		movf Temperature,W; temperature
		call SerialTransmit_Host
		movf Val_AN0,W; lecture CTN sur AN0
		call SerialTransmit_Host
		clrw
		btfsc PORTC,MOTORON
			movlw 1
		call SerialTransmit_Host
		movlw Tab_Temperature-EEProm+IDX_LEVELHTEMP
		call Lecture_EEProm
		call SerialTransmit_Host
		movlw Tab_Temperature-EEProm+IDX_LEVELLTEMP
		call Lecture_EEProm
		call SerialTransmit_Host
		movf RCTN,W; valeur resistance CTN / 100
		call SerialTransmit_Host		
		goto Main		
Not_Get_Temperature
		movf Value,W
		sublw IKBD_PROGTEMP; programmation seuil temperature
		btfss STATUS,Z
			goto Not_Prog_Temperature
		clrf Val_AN0; lecture CTN sur AN0 => actualise la mesure et la commande du ventilateur
		call SerialReceive; code programmation temperature
		sublw IDX_TAB_CTN+24; soustraire l'offset MAX
		btfss STATUS,C; si carry =1 pas de problemes on passe
			goto Not_Prog_EEProm; ignore code > IDX_TAB_CTN+24
		movf Value,W
		addlw Tab_Temperature-EEProm; pour pointer le debut des octets temperature dans la table
		goto Prog_EEProm
Not_Prog_Temperature
		;--------------------------------------------------------------
		;   Programmation souris et clavier
		movf Value,W
		sublw IKBD_PROGMS; programmation souris
		btfss STATUS,Z
			goto Not_Prog_Mouse
		; Indiquer le mode programmation par allumages des trois LEDs
		movlw LEDS_ON
		call cmdLedOnOff
		call SerialReceive; code programmation souris
		sublw IDX_WHREPEAT; soustraire l'offset MAX
		btfss STATUS,C; si carry =1 pas de problemes on passe
			goto Not_Prog_EEProm; ignore code > IDX_WHREPEAT
		movf Value,W
		addlw Tab_Mouse-EEProm; pour pointer le debut des octets souris dans la table
		goto Prog_EEProm
Not_Prog_Mouse
		movf Value,W
		sublw IKBD_PROGKB; programmation clavier
		btfss STATUS,Z
			goto Not_ProgKB
		; Indiquer le mode programmation par allumages des trois LEDs
		movlw LEDS_ON
		call cmdLedOnOff
		call SerialReceive; code programmation clavier
		comf Value,W		
		btfsc STATUS,Z
			goto ChangeSet; 0xFF	
		movf Value,W		
		sublw MAX_VALUE_LOOKUP; soustraire l'offset MAX
		btfss STATUS,C; si carry =1 pas de problemes on passe
			goto Not_Prog_EEProm; ignore code > MAX_VALUE_LOOKUP
		movf Value,W
		addlw Tab_Scan_Codes-EEProm; pour pointer le debut des octets CLAVIER dans la table
		goto Prog_EEProm
ChangeSet
		movlw Tab_Config-EEProm
Prog_EEProm
		movwf Counter
		call SerialReceive
		WREEPROM Counter,Value
		goto Main
Not_ProgKB
		;--------------------------------------------------------------
		;   Mode de fonctionnement IKBD souris
		movf Value,W
		sublw IKBD_SET_MOUSE_BUTTON_ACTION; mode boutons souris
		btfss STATUS,Z
			goto Not_Set_Mouse_Button_Action
		call SerialReceive
		movwf BUTTON_ACTION
		goto Main
Not_Set_Mouse_Button_Action
		movf Value,W
		sublw IKBD_REL_MOUSE_POS_REPORT; souris mode relatif
		btfss STATUS,Z
			goto Not_Rel_Mouse
		bcf Flags2,MOUSE_KEYS
		bcf Flags,MOUSE_ABS
		goto Mouse_Enable
Not_Rel_Mouse
		movf Value,W
		sublw IKBD_ABS_MOUSE_POSITIONING; souris mode absolu
		btfss STATUS,Z
			goto Not_Abs_Mouse
		call SerialReceive; XMSB, X maximum
		movwf X_MAX_POSH; position X absolue souris maximale poids fort
		call SerialReceive; XLSB
		movwf X_MAX_POSL; position X absolue souris maximale poids faible
		call SerialReceive; YMSB, Y maximum
		movwf Y_MAX_POSH; position Y absolue souris maximale poids fort
		call SerialReceive; YLSB
		movwf Y_MAX_POSL; position Y absolue souris maximale poids faible
		call Init_X_Y_Abs
		bcf Flags2,MOUSE_KEYS
		bsf Flags,MOUSE_ABS
		goto Mouse_Enable
Not_Abs_Mouse
		movf Value,W
		sublw IKBD_SET_MOUSE_KEYCODE_CODE; mode touches fleches souris
		btfss STATUS,Z
			goto Not_Mouse_KeyCode
		call SerialReceive; deltax
		call Change_0_To_1
		movwf DELTA_X; deltax mode keycode souris IKBD
		call SerialReceive; deltay
		call Change_0_To_1
		movwf DELTA_Y; deltay mode keycode souris IKBD
		clrf X_INC_KEY; increment en X mode keycode souris
		clrf Y_INC_KEY; increment en Y mode keycode souris
		bsf Flags2,MOUSE_KEYS
		goto Mouse_Enable
Not_Mouse_KeyCode
		movf Value,W
		sublw IKBD_SET_MOUSE_THRESHOLD; non gere
		btfsc STATUS,Z
			goto Receive2Bytes; X & Y seuil
		movf Value,W
		sublw IKBD_SET_MOUSE_SCALE; facteur d'echelle souris mode absolu
		btfss STATUS,Z
			goto Not_Mouse_Scale
		call SerialReceive; X
		call Change_0_To_1
		movwf X_SCALE
		call SerialReceive; Y
		call Change_0_To_1
		movwf Y_SCALE
		goto Conv_Not_Scaled
Not_Mouse_Scale
		movf Value,W
		sublw IKBD_INTERROGATE_MOUSE_POS; demande position absolue souris
		btfss STATUS,Z
			goto Not_Mouse_Pos
		btfss Flags,MOUSE_ABS
			goto Main; <> mode absolu
		btfsc Flags2,JOY_MONITOR
			goto Main
		movlw HEADER_ABSOLUTE_MOUSE; header souris mode absolu
		movwf HEADER_IKBD
		bcf PORTB,LEDYELLOW; allume LED souris
		call SendAtariMouse
		bsf PORTB,LEDYELLOW; eteint LED souris			
		goto Main
Not_Mouse_Pos
		movf Value,W
		sublw IKBD_LOAD_MOUSE_POS; initialisation coords souris absolue
		btfss STATUS,Z
			goto Not_Load_Mouse_Pos
		call SerialReceive; 0
		call SerialReceive; XMSB, X coord
		movwf X_POSH_SCALED; position X absolue souris avec facteur d'echelle poids fort
		call SerialReceive; XLSB
		movwf X_POSL_SCALED; position X absolue souris avec facteur d'echelle poids faible
		call SerialReceive; YMSB, Y coord
		movwf Y_POSH_SCALED; position Y absolue souris avec facteur d'echelle poids fort
		call SerialReceive; YLSB
		movwf Y_POSL_SCALED; position Y absolue souris avec facteur d'echelle poids faible
Conv_Not_Scaled
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)
		call Conv_Inv_Scale_X
		call Conv_Inv_Scale_Y
		bcf PCLATH,3; page 0 ou 2		
		goto Main
Not_Load_Mouse_Pos
		movf Value,W
		sublw IKBD_SET_Y0_AT_BOTTOM; 0 de Y souris en bas
		btfss STATUS,Z
			goto Not_Y0_At_Bottom
		bsf Flags,SIGN_Y
		goto Main
Not_Y0_At_Bottom
		movf Value,W
		sublw IKBD_SET_Y0_AT_TOP; 0 de Y souris en haut (par defaut)
		btfss STATUS,Z
			goto Not_Y0_At_Top
		bcf Flags,SIGN_Y
		goto Main
Not_Y0_At_Top
		movf Value,W
		sublw IKDB_RESUME; autorisation transferts
		btfss STATUS,Z
			goto Not_Resume
		goto Main
Not_Resume
		movf Value,W
		sublw IKDB_DISABLE_MOUSE; inhibe la souris
		btfss STATUS,Z
			goto Not_Disable_Mouse
		bcf Flags,MOUSE_ENABLE
		goto Main
Not_Disable_Mouse
		movf Value,W
		sublw IKDB_PAUSE_OUTPUT; arret transferts
		btfss STATUS,Z
			goto Not_Pause
		bcf Flags,IKBD_ENABLE
		goto Main
Not_Pause
		;--------------------------------------------------------------
		;   Mode de fonctionnement IKBD joysticks
		movf Value,W
		sublw IKBD_SET_JOY_EVNT_REPORT; joystick transferts automatiques
		btfss STATUS,Z
			goto Not_Joy_On
		bcf Flags2,JOY_KEYS
		bsf Flags2,JOY_EVENT
		bsf Flags,JOY_ENABLE
		goto Main
Not_Joy_On
		movf Value,W
		sublw IKBD_SET_JOY_INTERROG_MODE; arret transferts joystick automatiques
		btfss STATUS,Z
			goto Not_Joy_Off
		bcf Flags2,JOY_KEYS
		bcf Flags2,JOY_EVENT
		bsf Flags,JOY_ENABLE
		goto Main
Not_Joy_Off
		movf Value,W
		sublw IKBD_JOY_INTERROG; interroge joysticks
		btfss STATUS,Z
			goto Not_Joy_Interrog
		btfss Flags,JOY_ENABLE
			goto Main; joysticks inhibes
		btfsc Flags2,JOY_KEYS
			goto Main; mode keycode joystick 0
		btfsc Flags2,JOY_MONITOR
			goto Main; mode monitoring joysticks
		comf PORTA,W
		movwf JOY0
		rrf JOY0,W
		andlw 0x1F
		movwf JOY0; 000FDGBH (Fire, Droite, Gauche, Bas, Haut) joystick 0
		comf PORTC,W
		andlw 0x1F
		movwf JOY1; 000FDGBH (Fire, Droite, Gauche, Bas, Haut) joystick 1
		movlw HEADER_JOYSTICKS; header joysticks
		goto SerialTransmit_Joy
Not_Joy_Interrog
		movf Value,W
		sublw IKBD_SET_JOY_MONITOR
		btfss STATUS,Z
			goto Not_Joy_Monitor; lecture joyticks en continu
		call SerialReceive; rate
		call Change_0_To_1
		movwf Rate_Joy
		movwf Counter_10MS_Joy_Monitor
		bsf Flags2,JOY_MONITOR
		bsf Flags,JOY_ENABLE
		goto Main
Not_Joy_Monitor
		movf Value,W
		sublw IKBD_SET_FIRE_BUTTON_MONITOR
		btfss STATUS,Z
			goto Not_Fire_Button
		goto Main
Not_Fire_Button
		movf Value,W
		sublw IKBD_SET_JOY_KEYCODE_MODE; mode touches fleches joystick 0
		btfss STATUS,Z
			goto Not_Joy_KeyCode
		call SerialReceive; RX
		movwf RX_JOY
		call SerialReceive; RY
		movwf RY_JOY
		call SerialReceive; TX
		movwf TX_JOY
		call SerialReceive; TY
		movwf TY_JOY
		call SerialReceive; VX
		movwf VX_JOY
		call SerialReceive; VY
		movwf VY_JOY
		clrf Status_Joy
		movlw 0xFF
		movwf OLD_JOY
		bsf Flags2,JOY_KEYS
		bcf Flags2,JOY_EVENT
		bsf Flags,JOY_ENABLE
		goto Main
Not_Joy_KeyCode
		movf Value,W
		sublw IKDB_DISABLE_JOYSTICKS; inhibe les joysticks
		btfss STATUS,Z
			goto Not_Disable_Joysticks
		bcf Flags,JOY_ENABLE
		goto Main
Not_Disable_Joysticks
		movf Value,W
		sublw IKBD_TIME_OF_DAY_CLOCK_SET; initialise l'horloge
		btfss STATUS,Z
			goto Not_Time_Set
		;--------------------------------------------------------------
		;   Programmation horloge IKBD
		movlw LOW YEAR_BCD
		movwf FSR
		movlw 6
		movwf Counter
Loop_Get_Time
			call SerialReceive; YY, MM, DD, hh, mm, ss
			bsf STATUS,IRP; page 2
			movwf INDF
			incf FSR,F
			decfsz Counter,F
		goto Loop_Get_Time
		clrf Counter_5MS
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)
		call Conv_Inv_Bcd_Time
		bcf PCLATH,3; page 0 ou 2
		goto Main
Not_Time_Set
		movf Value,W
		sublw IKBD_INTERROG_TIME_OF_DAY; demande horloge
		btfss STATUS,Z
			goto Not_Interrog_Time
		;--------------------------------------------------------------
		;   Lecture horloge IKBD
		call Leds_Eiffel_On
		call SendAtariClock
		goto End_Read
Not_Interrog_Time
		movf Value,W
		sublw IKBD_MEMORY_LOAD; chargement memoire
		btfss STATUS,Z
			goto Not_Memory_Load
		;--------------------------------------------------------------
		;   Chargement memoire possible de 
		;   $00A0 a $00EF, et de $0120 a $016F
		;   si l'adresse de base de la commande et le nbre d'octet sont a 0
		;   => programmation Flash en page 2 ($1000 a $1FFF) format Motorola
		call SerialReceive
		movwf PTRH_LOAD; ADRMSB
		call SerialReceive
		movwf PTRL_LOAD; ADRLSB
		call SerialReceive
		movwf Counter_LOAD; NUM
		iorwf PTRL_LOAD,W; ADRLSB
		iorwf PTRH_LOAD,W; ADRMSB
		btfsc STATUS,Z
			goto Prog_Flash; adresse $0000 taille $00 => programmation FLASH
		bsf Flags3,RE_TIMER_IKBD; flag reception donnees IKBD dans boucle principale
		goto Main
Prog_Flash
		; Indiquer le mode programmation par allumages des trois LEDs
	 	movlw LEDS_ON
		call cmdLedOnOff
		call cmdDisableKey
		call cmdDisableMouse
		clrf STATUS; corrige bug init_page ram avant Eiffel 1.10 (IRP=0)
		bsf PCLATH,3; page 1 (0x800 - 0xFFF) programme Flashage
		bcf PCLATH,4
		goto Ecriture_Flash
Not_Memory_Load
		movf Value,W
		sublw IKBD_MEMORY_READ; lecture memoire
		btfss STATUS,Z
			goto Not_Memory_Read
		;--------------------------------------------------------------
		;   Lecture memoire possible partout 
		;   de $0000 a $01FF (registres PIC et RAM)
		;   de $2100 a $20FF (EEPROM)
		;   de $8000 a $FFFF (pour voir toute la FLASH de $0000 a $1FFF
		;                     octet par octet au format Mororola)
		call SerialReceive
		movwf TEMP1; ADRMSB
		bcf STATUS,IRP; pages 0-1
		btfsc Value,0; ADRMSB
			bsf STATUS,IRP; pages 2-3
		call SerialReceive
		movwf Counter2
		movwf FSR; ADRLSB
		call Leds_Eiffel_On
		movlw HEADER_STATUS; header d'etat
		call SerialTransmit_Host
		movlw IKBD_MEMORY_LOAD; memoire
		call SerialTransmit_Host
		btfsc TEMP1,7
			goto Dump_Flash; lecture FLASH si adresse >= 0x8000
		movlw 6; 6 octets
		movwf Counter
		movf TEMP1,W
		sublw 0x21
		btfsc STATUS,Z
			goto Dump_EEProm; lecture EEProm si adresse 0x21xx
Loop_Dump_Ram
			movf INDF,W
			call SerialTransmit_Host; data
			incf FSR,F
			btfsc STATUS,Z
				bsf STATUS,IRP; pages 2-3
			decfsz Counter,F
		goto Loop_Dump_Ram	
		goto End_Read
Dump_EEProm
			movf Counter2,W
			call Lecture_EEProm
			call SerialTransmit_Host; data
			incf Counter2,F
			decfsz Counter,F
		goto Dump_EEProm	
		goto End_Read
Dump_Flash
		bcf TEMP1,7; adresse FLASH poids fort
		movlw 3; 3 mots (6 octets)
		movwf Counter	
Loop_Dump_Flash
			READ_FLASH TEMP1,Counter2,BUFFER_FLASH; lecture 2 octets
			movf BUFFER_FLASH+1,W
			call SerialTransmit_Host; data poids faible
			movf BUFFER_FLASH,W
			call SerialTransmit_Host; data poids fort
			incf Counter2,F
			btfsc STATUS,Z
				incf TEMP1,F
			decfsz Counter,F
		goto Loop_Dump_Flash
End_Read
		call Leds_Eiffel_Off
		goto Main
Not_Memory_Read
		movf Value,W
		sublw IKBD_CONTROLLER_EXECUTE; non gere
		btfss STATUS,Z
			goto Not_Execute
Receive2Bytes
		call SerialReceive; ADRMSB
		; ADRLSB
Not_Prog_EEProm
		call SerialReceive
		goto Main
Not_Execute
		;--------------------------------------------------------------
		;   Afficheur Lcd
		IF LCD
		IF !LCD_DEBUG
		movf Value,W
		sublw IKBD_LCD; envoi commande ou donnees au LCD
		btfss STATUS,Z
			goto Not_Lcd
		call SerialReceive
                btfss STATUS,Z
                	goto Test_Data_Lcd; <> 0
		call SerialReceive
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)
		call SendINS
		bcf PCLATH,3; page 0 ou 2
		bcf Flags4,LCD_ENABLE; inhibe gestion timer LCD	
		goto Main
Test_Data_Lcd
		movwf Counter_LOAD; nombre d'octets
		comf Counter_LOAD,W		
		btfss STATUS,Z
			goto Data_Lcd; <> 0xFF
		bsf Flags4,LCD_ENABLE; autorise gestion timer LCD	
		goto Not_Prog_EEProm; dernier octet
Data_Lcd
		bsf Flags4,RE_LCD_IKBD; flag reception donnees LCD
		bsf Flags3,RE_TIMER_IKBD; flag reception donnees IKBD dans boucle principale
		goto Main		
Not_Lcd
		ENDIF
		ENDIF
		movf Value,W
		sublw IKBD_RESET; reset
		btfss STATUS,Z
			goto Not_Reset
		call SerialReceive
		sublw 1; code reset
		btfss STATUS,Z
			goto Main
		;--------------------------------------------------------------
		;  Commande RESET => Reinitialise Eiffel
		;   - On annule l'indicateur CAPS dans le mot d'etat.
		;   - On arrete les evenements souris et clavier PS/2. 
		;   - On envoi la commande reset au clavier et a la souris PS/2.
		;   - On autorise les transferts IKBD, souris et joystick.
		clrf Flags
		clrf Flags2
		clrf Flags3
		clrf Flags4
		clrf Flags5
		clrf Status_Joy
		clrf DEB_INDEX_EM; index courant donnee a envoyer buffer circulaire liaison serie
		clrf FIN_INDEX_EM; fin index donnee a envoyer buffer circulaire liaison serie
		bcf PORTC,MOTORON; arret ventilateur
		call Leds_Eiffel_On
		IF LCD
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)
		call Init_Lcd
		bcf PCLATH,3; page 0 ou 2
		ENDIF
		btfss Status_Boot,POWERUP_MOUSE
			goto NotResetMouse
		call cmdDisableMouse
		bsf Flags2,RESET_MOUSE; valide reset souris dans traitement timer
NotResetMouse
		btfss Status_Boot,POWERUP_KEYB
			goto Init_Flags
		movlw LEDS_ON
		call cmdLedOnOff
		bsf Flags2,RESET_KEYB; valide reset clavier dans traitement timer
Init_Flags
		call Init_X_Y_Abs; position absolue souris
		movlw Tab_Config-EEProm
		call Lecture_EEProm
		sublw 2; jeu 2 clavier demande
		btfsc STATUS,Z
			bsf Flags3,KEYB_SET_2
		IF LCD
		IF !LCD_DEBUG
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)
		call Init_Message_User_Lcd
		bcf PCLATH,3; page 0 ou 2
		bsf Flags4,LCD_ENABLE; autorise gestion timer LCD
		ENDIF
		ENDIF
		bsf Flags2,JOY_EVENT
		bsf Flags,JOY_ENABLE
		bsf Flags,IKBD_ENABLE
Mouse_Enable
		bsf Flags,MOUSE_ENABLE
		goto Main
Not_Reset
		;--------------------------------------------------------------
		;  Commandes de status
		movf Value,W
		sublw IKBD_STATUS_MOUSE_BUT_ACTION; status
		btfss STATUS,Z
			goto Not_Mouse_Action
		movlw HEADER_STATUS; header d'etat
		call SerialTransmit_Host
		movlw IKBD_SET_MOUSE_BUTTON_ACTION
		call SerialTransmit_Host
		movf BUTTON_ACTION,W
		call SerialTransmit_Host
		movlw 5
		goto Send_Null_Bytes
Not_Mouse_Action
		movf Value,W
		sublw IKBD_STATUS_MOUSE_MODE_R
		btfsc STATUS,Z
			goto Mouse_Mode
		movf Value,W
		sublw IKBD_STATUS_MOUSE_MODE_A
		btfsc STATUS,Z
			goto Mouse_Mode
		movf Value,W
		sublw IKBD_STATUS_MOUSE_MODE_K
		btfss STATUS,Z
			goto Not_Mouse_Mode
Mouse_Mode
		movlw HEADER_STATUS; header d'etat
		call SerialTransmit_Host
		btfsc Flags2,MOUSE_KEYS
			goto Mouse_Mode_Keys
		btfsc Flags,MOUSE_ABS
			goto Mouse_Mode_Abs
		movlw IKBD_REL_MOUSE_POS_REPORT
		goto Send_End_Status_6_Null
Mouse_Mode_Abs
	 	movlw IKBD_ABS_MOUSE_POSITIONING
		call SerialTransmit_Host
		movf X_MAX_POSH,W; position X absolue maximale souris poids fort
		call SerialTransmit_Host; XMSB, X maximum
		movf X_MAX_POSL,W; position X absolue maximale souris poids faible
		call SerialTransmit_Host; XLSB
		movf Y_MAX_POSH,W; position Y absolue maximale souris poids fort
		call SerialTransmit_Host; YMSB, Y maximum
		movf Y_MAX_POSL,W; position Y absolue maximale souris poids faible
		call SerialTransmit_Host; YLSB
		movlw 2
		goto Send_Null_Bytes		
Mouse_Mode_Keys
		movlw IKBD_SET_MOUSE_KEYCODE_CODE
		call SerialTransmit_Host
		movf DELTA_X,W; deltax mode keycode souris IKBD
		call SerialTransmit_Host
		movf DELTA_Y,W; deltay mode keycode souris IKBD
		goto Send_End_Status_4_Null
Not_Mouse_Mode
		movf Value,W
		sublw IKBD_STATUS_MOUSE_THRESHOLD
		btfss STATUS,Z
			goto Not_Threshold
		movlw HEADER_STATUS; header d'etat
		call SerialTransmit_Host
		movlw IKBD_SET_MOUSE_THRESHOLD
		call SerialTransmit_Host
		movlw 1
		call SerialTransmit_Host
		movlw 1
		goto Send_End_Status_4_Null
Not_Threshold
		movf Value,W
		sublw IKBD_STATUS_MOUSE_SCALE
		btfss STATUS,Z
			goto Not_Scale
		movlw HEADER_STATUS; header d'etat
		call SerialTransmit_Host
		movlw IKBD_SET_MOUSE_SCALE
		call SerialTransmit_Host
		movf X_SCALE,W
		call SerialTransmit_Host
		movf Y_SCALE,W
Send_End_Status_4_Null
		call SerialTransmit_Host
		movlw 4
		goto Send_Null_Bytes
Not_Scale
		movf Value,W
		sublw IKBD_STATUS_MOUSE_Y0_AT_B
		btfsc STATUS,Z
			goto Mouse_Vert
		movf Value,W
		sublw IKBD_STATUS_MOUSE_Y0_AT_T
		btfss STATUS,Z
			goto Not_Mouse_Vert
Mouse_Vert
		movlw HEADER_STATUS; header d'etat
		call SerialTransmit_Host
		movlw IKBD_SET_Y0_AT_BOTTOM
		btfss Flags,SIGN_Y
			movlw IKBD_SET_Y0_AT_TOP
		goto Send_End_Status_6_Null
Not_Mouse_Vert
		movf Value,W
		sublw IKDB_STATUS_DISABLE_MOUSE
		btfss STATUS,Z
			goto Not_Mouse_Enable
		movlw HEADER_STATUS; header d'etat
		call SerialTransmit_Host
		clrw; enabled
		btfss Flags,MOUSE_ENABLE
			movlw IKDB_DISABLE_MOUSE
		goto Send_End_Status_6_Null
Not_Mouse_Enable
		movf Value,W
		sublw IKBD_STATUS_JOY_MODE_E
		btfsc STATUS,Z
			goto Joy_Mode
		movf Value,W
		sublw IKBD_STATUS_JOY_MODE_I
		btfsc STATUS,Z
			goto Joy_Mode
		movf Value,W
		sublw IKBD_STATUS_JOY_MODE_K
		btfss STATUS,Z
			goto Not_Joy_Mode
Joy_Mode	
		movlw HEADER_STATUS; header d'etat
		call SerialTransmit_Host
		btfsc Flags2,JOY_KEYS
			goto Joy_Mode_Keys
		movlw IKBD_SET_JOY_EVNT_REPORT
		btfss Flags2,JOY_EVENT
			movlw IKBD_SET_JOY_INTERROG_MODE
		goto Send_End_Status_6_Null		
Joy_Mode_Keys	
		movlw IKBD_SET_JOY_KEYCODE_MODE
		call SerialTransmit_Host
		movf RX_JOY,W
		call SerialTransmit_Host; RX
		movf RY_JOY,W
		call SerialTransmit_Host; RY
		movf TX_JOY,W
		call SerialTransmit_Host; TX
		movf TY_JOY,W
		call SerialTransmit_Host; TY
		movf VX_JOY,W
		call SerialTransmit_Host; VX
		movf VY_JOY,W
		call SerialTransmit_Host; VY
		goto Main
Not_Joy_Mode
		movf Value,W
		sublw IKDB_STATUS_DISABLE_JOY
		btfss STATUS,Z
			goto Main
		movlw HEADER_STATUS; header d'etat
		call SerialTransmit_Host
		clrw; enabled
		btfss Flags,JOY_ENABLE
			movlw IKDB_DISABLE_JOYSTICKS
Send_End_Status_6_Null
		call SerialTransmit_Host
		movlw 6
Send_Null_Bytes
		call TransmitNullBytes; end status
		goto Main

;-----------------------------------------------------------------------------
;				Erreurs CLAVIER
;-----------------------------------------------------------------------------

Error_Keyboard
		call Remove_Key_Forced
		call cmdResetKey
		goto Main

Error_Parity_Keyboard
		call cmdResendKey
		goto Main

;-----------------------------------------------------------------------------
;				Donnees arrivees du CLAVIER
;-----------------------------------------------------------------------------

doKeyboard
		; Interdire toutes emissions des peripheriques PS/2 (Mouse and Keyboard)
		DISABLEKEYB
		btfss PARITY,7
			goto Error_Parity_Keyboard; erreur parite
		; Est ce l'octet de la commande BAT clavier ?
		movf Value,W
		sublw CMD_BAT; Self-test passed (keyboard controller init)
		btfsc STATUS,Z; Est ce que W contient $AA ?
			goto OnKbBAT
		movf Value,W
		sublw BAT_ERROR; Erreur clavier
		btfsc STATUS,Z
			goto Error_Keyboard
		movf Value,W
		sublw ACK_ERROR; Erreur clavier
		btfsc STATUS,Z
			goto Error_Keyboard

		; Non, octet autre, on poursuit suivant le mode
		; PS/2 direct OU tranlation ATARI

		IF SERIAL_DEBUG
		btfsc PORTB,JUMPER4; si jumper4 (+5V): Mode ATARI
			goto ModeKeyAtari
;-----------------------------------------------------------------------------
;	Mode PC: Pas de translation, envoi direct des Scan-Codes en texte
;	ASCII (BCD) ou binaires directement

		bcf PORTB,LEDGREEN; allume LED clavier
		movf Value,W; code clavier
		call SerialTransmit_Host
		bsf PORTB,LEDGREEN; eteint LED clavier
		goto Main
		ENDIF
		
;-----------------------------------------------------------------------------
;	Mode Atari: Translation des Scan-Codes PC => Scan-Codes ATARI

ModeKeyAtari
		btfss Flags3,KEYB_SET_2
			goto Set3
		btfsc Flags3,PAUSE_SET_2
			goto TraiterPause
		movf Value,W
		sublw ESCAPE; est ce que W contient $E0 ?
		btfss STATUS,Z; si oui on passe
			goto TestPauseSet2; cas special pause du jeu 2
		bsf Flags3,NEXT_CODE; on doit traiter le code suivant
		IF LCD
		IF !LCD_DEBUG
		btfss Flags4,LCD_ENABLE; gestion timer LCD inhibe
			goto Main
		movlw 0x8E; ligne 1, colonne 15
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)
		call Send_Value_Lcd
		bcf PCLATH,3; page 0 ou 2
		ENDIF
		ENDIF
                goto Main
TestPauseSet2
		movf Value,W
		sublw ESCAPE1; est ce que W contient $E1 ?
		btfss STATUS,Z; si oui on passe
			goto Set3
		bsf Flags3,NEXT_CODES; on doit traiter les codes suivants
		bsf Flags3,PAUSE_SET_2
		goto Main
TraiterPause
		btfsc Flags3,NEXT_CODES
			goto TraiterPause2
		movf Value,W
		sublw CMD_RELEASED; est ce que W contient $F0 ?
		btfsc STATUS,Z; si non on passe
			goto BreakCode
		bcf Flags3,NEXT_CODES
		bcf Flags2,BREAK_CODE; touche enfoncee par defaut
		bsf Flags3,NEXT_CODE; on doit traiter le code suivant
                goto Main
TraiterPause2
		movf Value,W
		sublw CMD_RELEASED; est ce que W contient $F0 ?
		btfsc STATUS,Z; si non on passe
			goto BreakCode
		movf Value,W
		sublw 0x77; est ce que W contient $77 ?
                btfss STATUS,Z; si oui on passe
                	goto Not_SendKey
		btfsc Flags2,JOY_MONITOR
			goto Not_SendPause
		bcf PORTB,LEDGREEN; allume LED clavier
            	movlw DEF_PAUSE; touche enfoncee
		btfsc Flags2,BREAK_CODE
	            	iorlw 0x80; relachement (BreakCode Bit7=1)
		call SerialTransmit_Host
		bsf PORTB,LEDGREEN; eteint LED clavier
Not_SendPause
		bcf Flags3,PAUSE_SET_2
		goto Not_SendKey
Set3
		movf Value,W
		sublw CMD_RELEASED; est ce que W contient $F0 ?
		btfss STATUS,Z; si oui on passe
			goto Not_BreakCode
BreakCode
		bsf Flags2,BREAK_CODE; on doit traiter un break code (touche relachee)
                goto Main
Not_BreakCode
		btfsc Flags2,JOY_MONITOR
			goto Not_SendKey
		IF LCD
		IF !LCD_DEBUG
		btfss Flags4,LCD_ENABLE; gestion timer LCD inhibe
			goto ByPass_Lcd
		movlw 0xCE; ligne 2, colonne 15
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)
		call Send_Value_Lcd
		bcf PCLATH,3; page 0 ou 2
ByPass_Lcd
		ENDIF
		ENDIF
		bcf PORTB,LEDGREEN; allume LED clavier
		call SendAtariKeyboard
		bsf PORTB,LEDGREEN; eteint LED clavier
Not_SendKey
		bcf Flags2,BREAK_CODE; touche enfoncee par defaut
		bcf Flags3,NEXT_CODE; flag 2eme code apres 0xE0
		goto Main

;-----------------------------------------------------------------------------
; Reception de la commande BAT CLAVIER
;-----------------------------------------------------------------------------

OnKbBAT
		call KbBAT
		bsf Status_Boot,POWERUP_KEYB
		goto Main

KbBAT
; Apres un reset delay: 500 mS, rate; 10.9 cps, set 2, typematic/make/break
		call cmdScanSet
		btfss Flags3,KEYB_SET_2
			call cmdMakeBreak
;		btfsc Flags3,KEYB_SET_2
;			call cmdTypeRate
		movlw CAPS_OFF; Allumer Verr.Num., pas de CAPS lock
		call cmdLedOnOff
		call cmdEnableKey
		bsf PORTB,LEDGREEN; Eteindre la LED VERTE pour montrer le onBAT
		return

;-----------------------------------------------------------------------------
;				Erreurs SOURIS
;-----------------------------------------------------------------------------

Error_Mouse
		call cmdResetMouse
		goto Main
		
Error_Parity_Mouse
		IF SCROOL_LOCK_ERR
		call UpdateLedOnOff
		ENDIF
		call cmdResendMouse
		clrf Counter_Mouse; toute la trame est envoyee de nouveau
		goto Main

;-----------------------------------------------------------------------------
;				Donnees arrivees de la SOURIS
;-----------------------------------------------------------------------------
		
doMouse
		; Interdire toutes emissions des peripheriques PS/2 (Mouse and Keyboard)
		DISABLEMOUSE
		btfss PARITY,7
			goto Error_Parity_Mouse
		movf Counter_Mouse,W
		btfss STATUS,Z
			goto Not_BatMouse; <> 1st byte
		; Est ce l'octet de la commande BAT souris ?
		movf Value,W
		sublw CMD_BAT; Self-test passed
		btfsc STATUS,Z; Est ce que W contient $AA ?
			goto OnMsBAT
		movf Value,W
		sublw BAT_ERROR; Erreur souris
		btfsc STATUS,Z
			goto Error_Mouse
		movf Value,W
		sublw ACK_ERROR; Erreur souris
		btfsc STATUS,Z
			goto Error_Mouse
Not_BatMouse
		IF SERIAL_DEBUG
		btfsc PORTB,JUMPER4; si jumper4 (+5V): Mode ATARI
			goto ModeMsAtari
;-----------------------------------------------------------------------------
;	Mode souris PC: envoit direct des codes en texte ASCII (BCD) ou 
;	binaires directement

		bcf PORTB,LEDYELLOW; allume LED souris
		movf Value,W
		call SerialTransmit_Host
		bsf PORTB,LEDYELLOW; eteint LED souris
		goto Main
		ENDIF

;-----------------------------------------------------------------------------
;	Mode souris Atari: On convertie les paquets d'octets en trame Atari

ModeMsAtari
		incf Counter_Mouse,F; compteur pour traiter chaque octet recu via la boucle principale (Main)
		movf Counter_Mouse,W
		sublw 1
		btfsc STATUS,Z
			goto First_Byte; 1er octet
		movf Counter_Mouse,W
		sublw 2
		btfsc STATUS,Z
			goto Second_Byte; 2eme octet (X)
		movf Counter_Mouse,W
		sublw 3
		btfsc STATUS,Z
			goto Third_Byte; 3eme octet (Y)
		goto Fourth_Byte; 4eme octet eventuel (Z)
First_Byte		
		movf Value,W
		movwf Value_0; test de validite de Value_0
		btfsc Value_0,7
			goto Pb_Trame_Mouse; Y overflow
		btfsc Value_0,6
			goto Pb_Trame_Mouse; X overflow
		btfsc Value_0,3
			goto Main
		; le bit 3 doit toujours etre a 1
Pb_Trame_Mouse
		clrf Counter_Mouse; decalage dans la lecture de la trame
		goto Main
Second_Byte
		movf Value,W
		movwf Value_X; Value X mouvement
		goto Main
Third_Byte		
		movf Value,W
		movwf Value_Y; Value Y mouvement
		btfss Flags,MSWHEEL
			goto Normal_Mouse
		clrf Value_Z
		goto Main
Fourth_Byte
		movf Value,W
		movwf Value_Z; Value Z mouvement (-8 a 7)
Normal_Mouse
		clrf Counter_Mouse
		clrf BUTTONS; etat des boutons souris
		btfsc Value_0,PC_LEFT; tester si bouton gauche souris a 1
			bsf BUTTONS,AT_LEFT; si 1 mettre mettre celui Atari a 1
		btfsc Value_0,PC_RIGHT; tester si bouton droit souris a 1
			bsf BUTTONS,AT_RIGHT; si 1 mettre celui Atari a 1
		movf BUTTONS,W
		iorlw HEADER_RELATIVE_MOUSE; header souris mode relatif (0xF8 - 0xFB)
		movwf HEADER_IKBD		

		;-------------------------------------------------------------
		;   Au lieu de simuler un appui droit et gauche, on genere un scan-code
                ; on ecrit des 0 pour ne pas transmettre ensuite
		clrf CLIC_MOUSE_WHEEL; touche bouton 3
		clrf KEY_MOUSE_WHEEL; touche roulette bouton 3
		clrf KEY2_MOUSE_WHEEL; touche boutons 4 & 5
		btfss Value_0,PC_MIDDLE; tester si bouton central souris a 1
			goto Compteurs_Mouse
		movlw Tab_Mouse-EEProm+IDX_BUTTON3
		call Lecture_EEProm
		movwf CLIC_MOUSE_WHEEL
		;-------------------------------------------------------------
Compteurs_Mouse
		;-------------------------------------------------------------
		;   traiter le compteur X
		bcf Value_X,AT_SIGN; Ramener la valeur sur 7 bits
		btfsc Value_0,PC_SIGNX; tester le bit de signe PC pour X
			bsf Value_X,AT_SIGN; est leve alors on leve le signe Atari
		movf Value_X,W
		movwf X_MOV; ecrire le resultat dans le compteur X Atari
		btfss Flags,MOUSE_ABS
			goto Not_Max_X; <> mode absolu		
		clrf TEMP2; positif
		btfsc Value_X,7
			comf TEMP2,F; negatif
		addwf X_POSL,F; position X absolue souris poids faible
		movf TEMP2,W
		btfsc STATUS,C
			incfsz TEMP2,W
		addwf X_POSH,F; X_POS = X_POS + X_MOV
		btfsc X_POSH,7; signe position X absolue souris poids fort
			goto Dep_Min_X; si X_POS < 0 -> X_POS = 0
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)
		call Conv_Scale_X
		bcf PCLATH,3; page 0 ou 2
		movf X_MAX_POSH,W; position X absolue maximale souris poids fort
		subwf X_POSH_SCALED,W; position X absolue souris avec facteur d'echelle poids fort
		btfsc STATUS,Z
			goto XCompl
		btfss STATUS,C
			goto Not_Max_X; X_POS < X_MAX_POS 
		goto Dep_Max_X; X_POS > X_MAX_POS 		
XCompl		movf X_MAX_POSL,W; position X absolue maximale souris poids faible
		subwf X_POSL_SCALED,W; position X absolue souris avec facteur d'echelle poids faible
		btfsc STATUS,Z
			goto Dep_Max_X; X_POS = X_MAX_POS
		btfss STATUS,C
			goto Not_Max_X; X_POS < X_MAX_POS 	
Dep_Max_X
		movf X_MAX_POSL,W
		movwf X_POSL_SCALED
		movf X_MAX_POSH,W
		movwf X_POSH_SCALED; si X_POS >= X_MAX_POS -> X_POS = X_MAX_POS
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)
		call Conv_Inv_Scale_X
		bcf PCLATH,3; page 0 ou 2
		goto Not_Max_X
Dep_Min_X
		call Init_X_Abs
Not_Max_X
		;-------------------------------------------------------------
		;   traiter le compteur Y 
		bcf Value_Y,AT_SIGN; Ramener la valeur sur 7 bits 
		btfsc Value_0,PC_SIGNY; tester le bit de signe PC pour Y
			bsf Value_Y,AT_SIGN; est leve alors on leve le signe Atari
                ; Le mouvement PS/2 et Atari est inverse par defaut
		btfsc Flags,SIGN_Y
			goto Not_Inv_Y; inversion de sens Y IKBD
		;complement a deux pour inverser le mouvement Y: on ne traite que +127/-128
		;ex: $FF %11111111 d-1 => $01 %00000001 d+1
		comf Value_Y,F
		incf Value_Y,F
Not_Inv_Y
		movf Value_Y,W
		movwf Y_MOV; ecrire le resultat dans le compteur Y Atari
		btfss Flags,MOUSE_ABS
			goto Not_Max_Y; <> mode absolu
		clrf TEMP2; positif
		btfsc Value_Y,7
			comf TEMP2,F; negatif
		addwf Y_POSL,F; position Y absolue souris poids faible
		movf TEMP2,W
		btfsc STATUS,C
			incfsz TEMP2,W
		addwf Y_POSH,F; Y_POS = Y_POS + Y_MOV
		btfsc Y_POSH,7; signe position Y absolue souris poids fort
			goto Dep_Min_Y; si Y_POS < 0 -> Y_POS = 0
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)		
		call Conv_Scale_Y
		bcf PCLATH,3; page 0 ou 2
		movf Y_MAX_POSH,W; position Y absolue maximale souris poids fort
		subwf Y_POSH_SCALED,W; position Y absolue souris avec facteur d'echelle poids fort
		btfsc STATUS,Z
			goto YCompl
		btfss STATUS,C
			goto Not_Max_Y; Y_POS < Y_MAX_POS 
		goto Dep_Max_Y; Y_POS > Y_MAX_POS 		
YCompl
		movf Y_MAX_POSL,W; position Y absolue maximale souris poids faible
		subwf Y_POSL_SCALED,W; position Y absolue souris avec facteur d'echelle poids faible
		btfsc STATUS,Z
			goto Dep_Max_Y; X_POS = Y_MAX_POS
		btfss STATUS,C
			goto Not_Max_Y; Y_POS < Y_MAX_POS 	
Dep_Max_Y
		movf Y_MAX_POSL,W
		movwf Y_POSL_SCALED
		movf Y_MAX_POSH,W
		movwf Y_POSH_SCALED; si Y_POS >= Y_MAX_POS -> Y_POS = Y_MAX_POS
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)
		call Conv_Inv_Scale_Y
		bcf PCLATH,3; page 0 ou 2
		goto Not_Max_Y
Dep_Min_Y
		call Init_Y_Abs
Not_Max_Y
		;------------------------------------------------------------
		; On recoit le compteur Z, si c'est une souris a roulette
		btfss Flags,MSWHEEL
			goto TransmitHost; si bit souris a roulette a zero on transmet maintenant
		; Cas de l'InteliMouse, traiter le compteur Z
		btfsc Value_Z,PC_SIGNZ; Est ce une valeur negative
			goto ZNegatif
		; tester si la valeur sur les 4bits [3-0] est egale a 0 ou pas
		movf Value_Z,W; charger w avec la valeur
		andlw 0x0F; masquer et traiter le compteur Z sur 4 bits
		btfsc STATUS,Z
			goto ZZero
		;-------------------------------------------------------------
		; Valeur positive: Molette verticale vers LE BAS
		; ou molette horizontale vers LA DROITE
		btfss Value_Z,PC_BITLSBZ; si le BIT 0 est a 1 on donc 0x1 => Molette verticale
			goto ZGauche; aller en molette horizontale
		movlw Tab_Mouse-EEProm+IDX_WHEELDN
		call Lecture_EEProm
		movwf KEY_MOUSE_WHEEL; valeur positive donc EN BAS toute
		goto ZZero
ZGauche
		movlw Tab_Mouse-EEProm+IDX_WHEELLT
		call Lecture_EEProm
		movwf KEY_MOUSE_WHEEL; valeur positive donc A GAUCHE toute
		goto ZZero
ZNegatif
		;-------------------------------------------------------------
		; Valeur negative: Molette verticale vers LE HAUT
		; ou molette horizontale vers LA GAUCHE
		btfss Value_Z,PC_BITLSBZ;si le BIT 0 est a 1 on donc 0xF => Molette verticale
			goto ZDroit; aller en molette horizontale
		movlw Tab_Mouse-EEProm+IDX_WHEELUP
		call Lecture_EEProm
		movwf KEY_MOUSE_WHEEL; valeur negative -1 donc EN HAUT toute
		goto ZZero
ZDroit
		movlw Tab_Mouse-EEProm+IDX_WHEELRT
		call Lecture_EEProm
		movwf KEY_MOUSE_WHEEL; valeur negative -2 donc A DROITE toute
ZZero
		;-------------------------------------------------------------
		; Si la InteliMouse ET 5 boutons tester l'etat
		btfss Flags,MSWHEELPLUS;si bit WheelPlus a zero on transmet maintenant, il n'a pas de
			goto TransmitHost; boutons 4&5 et 2eme molette
		btfss Value_Z,PC_BUTTON4; bouton 4 actif ?
			goto Prochain_Bouton; tester le prochain bouton (le 5)
		movlw Tab_Mouse-EEProm+IDX_BUTTON4
		call Lecture_EEProm
		movwf KEY2_MOUSE_WHEEL; Scan-code associe au bouton 4
		goto TransmitHost; on transmet maintenant
Prochain_Bouton
		btfss Value_Z,PC_BUTTON5; ;bouton 5 actif ?
			goto TransmitHost; on transmet maintenant
		movlw Tab_Mouse-EEProm+IDX_BUTTON5
		call Lecture_EEProm
		movwf KEY2_MOUSE_WHEEL; Scan-code associe au bouton 5
TransmitHost
		;-------------------------------------------------------------
		; Envoyer enfin le paquet souris au host
		btfss Flags,MOUSE_ENABLE
			goto Main; pas d'autorisation de l'Atari
		btfsc Flags2,JOY_MONITOR
			goto Main; monitoring joysticks en cours demande par l'Atari
		bcf PORTB,LEDYELLOW; allume LED souris
		call SendAtariMouse; relative
		;-------------------------------------------------------------
		; Test mode IKBD button action
		btfss BUTTON_ACTION,0; bouton enfonce => envoi position absolue
			goto Not_Action_0
		movf BUTTONS,W; etat des boutons souris
		xorwf OLD_BUTTONS,W; ancien etat des boutons souris
		andlw 1		
		btfsc STATUS,Z
			goto Not_Change_A
		btfsc BUTTONS,0
			goto Env_Action; bouton droit enfonce
Not_Change_A
		movf BUTTONS,W; etat des boutons souris
		xorwf OLD_BUTTONS,W; ancien etat des boutons souris
		andlw 2		
		btfsc STATUS,Z
			goto Not_Action_0
		btfsc BUTTONS,1
			goto Env_Action; bouton gauche enfonce
Not_Action_0
		btfss BUTTON_ACTION,1; bouton relache => envoi position absolue
			goto Not_Action_1	
		movf BUTTONS,W; etat des boutons souris
		xorwf OLD_BUTTONS,W; ancien etat des boutons souris
		andlw 1		
		btfsc STATUS,Z
			goto Not_Change_B
		btfss BUTTONS,0
			goto Env_Action; bouton droit relache
Not_Change_B
		movf BUTTONS,W; etat des boutons souris
		xorwf OLD_BUTTONS,W; ancien etat des boutons souris
		andlw 2		
		btfsc STATUS,Z
			goto Not_Action_1
		btfsc BUTTONS,1; bouton gauche relache
			goto Not_Action_1
Env_Action
		movf BUTTONS,W; etat des boutons souris
		movwf OLD_BUTTONS_ABS; ancien etat des boutons souris en mode absolu
		comf OLD_BUTTONS_ABS,F; force l'envoi des changements d'etat
		movlw HEADER_ABSOLUTE_MOUSE; header souris mode absolu
		movwf HEADER_IKBD
		call SendAtariMouse
Not_Action_1
		bsf PORTB,LEDYELLOW; eteint LED souris
		movf BUTTONS,W; etat des boutons souris
		movwf OLD_BUTTONS; ancien etat des boutons souris		
		goto Main

;-----------------------------------------------------------------------------
; Reception de la commande BAT SOURIS
;-----------------------------------------------------------------------------

OnMsBAT
		call TryWheel; detecter si la souris est a roulette
		btfsc Flags,MSWHEEL; si c'est un souris a roulette
			call TryWheelPlus; Detecter si est pluse encore
		call cmdEnableMous
		bsf PORTB,LEDYELLOW; Eteindre la LED JAUNE pour montrer le onBAT
		bsf Status_Boot,POWERUP_MOUSE
		goto Main
		
;=============================================================================
;                               PROCEDURES ET FONCTIONS
;=============================================================================

;-----------------------------------------------------------------------------
;               Forcage a 1 si 0
;-----------------------------------------------------------------------------
		
Change_0_To_1
		iorlw 0
		btfsc STATUS,Z
			movlw 1
		return
		
;-----------------------------------------------------------------------------
;               Remise a 0 variables 
;-----------------------------------------------------------------------------
		
Init_X_Y_Abs
		call Init_X_Abs

Init_Y_Abs
		clrf Y_POSL
		clrf Y_POSH
		clrf Y_POSL_SCALED; position Y absolue souris avec facteur d'echelle poids faible
		clrf Y_POSH_SCALED; position Y absolue souris avec facteur d'echelle poids fort
		return
		
Init_X_Abs	
		clrf X_POSL
		clrf X_POSH
		clrf X_POSL_SCALED; position X absolue souris avec facteur d'echelle poids faible
		clrf X_POSH_SCALED; position X absolue souris avec facteur d'echelle poids fort
		return

;-----------------------------------------------------------------------------
;	Procedure de transmission des octets a propos de l'horloge
;-----------------------------------------------------------------------------
		
SendAtariClock
		movlw HEADER_TIME_OF_DAY; header horloge
		call SerialTransmit_Host
		movlw LOW YEAR_BCD
		movwf FSR; pointe sur le 1er element envoye c'est a dire l'annee
		movlw 6; 6 octets
		movwf Counter
Loop_Env_Time
			bsf STATUS,IRP; page 2
			movf INDF,W
			call SerialTransmit_Host; YY, MM, DD, hh, mm, ss
			incf FSR,F
			decfsz Counter,F
		goto Loop_Env_Time; element suivant
		return

;-----------------------------------------------------------------------------
;	Procedure de transmission des octets a propos du (ou des) joystick(s)
;-----------------------------------------------------------------------------
		
SendAtariJoysticks
		movf HEADER_IKBD,W
		sublw HEADER_JOYSTICKS; header joysticks
		btfss STATUS,Z
			goto Not_Joy01
		;-------------------------------------------------------------
		; TRANSMETTRE le paquet Atari (3 octets) des joysticks
		movf HEADER_IKBD,W
		call SerialTransmit_Host
	 	movf JOY0,W; lecture joystick 0
		call SerialTransmit_Host_Joy
	 	movf JOY1,W; lecture joystick 1
		goto SerialTransmit_Host_Joy
Not_Joy01
		movf HEADER_IKBD,W
		sublw HEADER_JOYSTICK0; header joystick 0
		btfss STATUS,Z
			goto Not_Joy0
		btfss Flags2,JOY_KEYS; envoi touches fleches
			goto Not_ButAct0
		;-------------------------------------------------------------
		; TRANSMETTRE button action joystick 0
		movlw 0x74; bouton joytick 0 enfonce
		btfss JOY0,4
			movlw 0xF4; bouton joytick 0 relache
		goto SerialTransmit_Host
Not_ButAct0
		;-------------------------------------------------------------
		; TRANSMETTRE le paquet standard Atari (2 octets) du joystick 0
		movf HEADER_IKBD,W
		call SerialTransmit_Host
		movf JOY0,W; lecture joystick 0
		goto SerialTransmit_Host_Joy
Not_Joy0
		btfss Flags2,JOY_KEYS; envoi touches fleches
			goto Not_ButAct1
		;-------------------------------------------------------------
		; TRANSMETTRE button action joystick 1
		movlw 0x75; bouton joytick 1 enfonce
		btfss JOY1,4
			movlw 0xF5; bouton joytick 1 relache
		goto SerialTransmit_Host
Not_ButAct1
		;-------------------------------------------------------------
		; TRANSMETTRE le paquet standard Atari (2 octets) du joystick 1
		movf HEADER_IKBD,W
		call SerialTransmit_Host
		movf JOY1,W; lecture joystick 1	
SerialTransmit_Host_Joy
		; deplacement du bit fire du joystick (4 -> 7)
		movwf TEMP1
		btfsc TEMP1,4
			bsf TEMP1,7; bouton fire
		bcf TEMP1,4
		movf TEMP1,W
		goto SerialTransmit_Host
		
;-----------------------------------------------------------------------------
;	Procedure de transmission des octets a propos de l'emulation
;	des fleches du clavier via le joystick 0 soit le mode IKBD
;	joystick keycodes
;	- Temps initial RX/RY declenche lors de l'appui sur une direction le
;	  scan-code de la fleche clavier est alors envoye une 1ere fois suivant
;	  la direction choisie sur le joystick 0
;	- Temps repetition TX/TY (X fois suivant VX/VY)
;	- Temps total VX/VY provoquant l'arret de l'envoi du scan-code de la 
;	  fleche du clavier (idem si relachement de la direction choisie du
;	  joystick 0)
;-----------------------------------------------------------------------------

SendAtariJoysticks_Fleches
		btfsc Status_Joy,RY_H
			goto Not_H
		movf JOYB,W; joystick 0
		xorwf OLD_JOY,W
		andlw 1		
		btfsc STATUS,Z
			goto Not_H; pas de changement d'etat
		btfss JOYB,0
			goto Not_H
		bsf Status_Joy,RY_H; bouton haut enfonce
		bcf Status_Joy,TY_H
		movf Counter_100MS_Joy,W
		movwf START_RY_JOY
		movf RY_JOY,W
		btfsc STATUS,Z
			goto Not_H; temps RY nul
		call SerialTransmit_Haut; 1er envoi
Not_H
		btfsc Status_Joy,RY_B
			goto Not_B
		movf JOYB,W
		xorwf OLD_JOY,W
		andlw 2		
		btfsc STATUS,Z
			goto Not_B; pas de changement d'etat
		btfss JOYB,1
			goto Not_B
		bsf Status_Joy,RY_B; bouton bas enfonce
		bcf Status_Joy,TY_B
		movf Counter_100MS_Joy,W
		movwf START_RY_JOY
		movf RY_JOY,W
		btfsc STATUS,Z
			goto Not_B; temps RY nul
		call SerialTransmit_Bas; 1er envoi
Not_B
		btfsc Status_Joy,RX_G
			goto Not_G
		movf JOYB,W
		xorwf OLD_JOY,W
		andlw 4		
		btfsc STATUS,Z
			goto Not_G; pas de changement d'etat
		btfss JOYB,2
			goto Not_G
		bsf Status_Joy,RX_G; bouton gauche enfonce
		bcf Status_Joy,TX_G
		movf Counter_100MS_Joy,W
		movwf START_RX_JOY
		movf RX_JOY,W
		btfsc STATUS,Z
			goto Not_G; temps RX nul
		call SerialTransmit_Gauche; 1er envoi
Not_G
		btfsc Status_Joy,RX_D
			goto Not_D
		movf JOYB,W
		xorwf OLD_JOY,W
		andlw 8		
		btfsc STATUS,Z
			goto Not_D; pas de changement d'etat
		btfss JOYB,3
			goto Not_D
		bsf Status_Joy,RX_D; bouton droit enfonce
		bcf Status_Joy,TX_D
		movf Counter_100MS_Joy,W
		movwf START_RX_JOY
		movf RX_JOY,W
		btfsc STATUS,Z
			goto Not_D; temps RX nul
		call SerialTransmit_Droite; 1er envoi
Not_D
		btfss Status_Joy,RY_H
			goto Not_H2
		btfss JOYB,0
			goto End_H; bouton haut relache
		movf START_RY_JOY,W
		subwf Counter_100MS_Joy,W
		subwf VY_JOY,W; VY - temps ecoule
		btfsc STATUS,C
			goto Not_H3
End_H
		bcf Status_Joy,RY_H; fin temps total
		bcf Status_Joy,TY_H
		goto Not_H2
Not_H3
		btfsc Status_Joy,TY_H
			goto Not_H4; temps repetition
		movf START_RY_JOY,W
		subwf Counter_100MS_Joy,W
		subwf RY_JOY,W; RY - temps ecoule
		btfsc STATUS,C
			goto Not_H2; <> fin 1er temps
		goto Delay_TY_H
Not_H4
		movf START_TY_JOY,W
		subwf Counter_100MS_Joy,W
		subwf TY_JOY,W; TY - temps ecoule
		btfsc STATUS,C
			goto Not_H2
Delay_TY_H
		bsf Status_Joy,RY_H
		bsf Status_Joy,TY_H
		movf Counter_100MS_Joy,W
		movwf START_TY_JOY
		call SerialTransmit_Haut; repetition		
Not_H2
		btfss Status_Joy,RY_B
			goto Not_B2
		btfss JOYB,1
			goto End_B; bouton bas relache
		movf START_RY_JOY,W
		subwf Counter_100MS_Joy,W
		subwf VY_JOY,W; VY - temps ecoule
		btfsc STATUS,C
			goto Not_B3
End_B
		bcf Status_Joy,RY_B; fin temps total
		bcf Status_Joy,TY_B
		goto Not_B2
Not_B3
		btfsc Status_Joy,TY_B
			goto Not_B4; temps repetition
		movf START_RY_JOY,W
		subwf Counter_100MS_Joy,W
		subwf RY_JOY,W; RY - temps ecoule
		btfsc STATUS,C
			goto Not_B2; <> fin 1er temps
		goto Delay_TY_B
Not_B4
		movf START_TY_JOY,W
		subwf Counter_100MS_Joy,W
		subwf TY_JOY,W; TY - temps ecoule
		btfsc STATUS,C
			goto Not_B2
Delay_TY_B
		bsf Status_Joy,RY_B
		bsf Status_Joy,TY_B
		movf Counter_100MS_Joy,W
		movwf START_TY_JOY
		call SerialTransmit_Bas; repetition
Not_B2
		btfss Status_Joy,RX_G
			goto Not_G2
		btfss JOYB,2
			goto End_G; bouton gauche relache
		movf START_RX_JOY,W
		subwf Counter_100MS_Joy,W
		subwf VX_JOY,W; VX - temps ecoule
		btfsc STATUS,C
			goto Not_G3
End_G
		bcf Status_Joy,RX_G; fin temps total
		bcf Status_Joy,TX_G
		goto Not_G2
Not_G3
		btfsc Status_Joy,TX_G
			goto Not_G4; temps repetition
		movf START_RX_JOY,W
		subwf Counter_100MS_Joy,W
		subwf RX_JOY,W; RX - temps ecoule
		btfsc STATUS,C
			goto Not_G2; <> fin 1er temps
		goto Delay_TX_G
Not_G4
		movf START_TX_JOY,W
		subwf Counter_100MS_Joy,W
		subwf TX_JOY,W; TX - temps ecoule
		btfsc STATUS,C
			goto Not_G2
Delay_TX_G
		bsf Status_Joy,RX_G
		bsf Status_Joy,TX_G
		movf Counter_100MS_Joy,W
		movwf START_TX_JOY
		call SerialTransmit_Gauche; repetition	
Not_G2
		btfss Status_Joy,RX_D
			goto Not_D2
		btfss JOYB,3
			goto End_D; bouton droit relache
		movf START_RX_JOY,W
		subwf Counter_100MS_Joy,W
		subwf VX_JOY,W; VX - temps ecoule
		btfsc STATUS,C
			goto Not_D3
End_D
		bcf Status_Joy,RX_D; fin temps total
		bcf Status_Joy,TX_D
		goto Not_D2
Not_D3
		btfsc Status_Joy,TX_D
			goto Not_D4; temps repetition
		movf START_RX_JOY,W
		subwf Counter_100MS_Joy,W
		subwf RX_JOY,W; RX - temps ecoule
		btfsc STATUS,C
			goto Not_D2; <> fin 1er temps
		goto Delay_TX_D
Not_D4
		movf START_TX_JOY,W
		subwf Counter_100MS_Joy,W
		subwf TX_JOY,W; TX - temps ecoule
		btfsc STATUS,C
			goto Not_D2
Delay_TX_D
		bsf Status_Joy,RX_D
		bsf Status_Joy,TX_D
		movf Counter_100MS_Joy,W
		movwf START_TX_JOY
		call SerialTransmit_Droite; repetition	
Not_D2
		movf JOYB,W
		movwf OLD_JOY	
		return

;-----------------------------------------------------------------------------
;	Procedure de transmission des octets a propos de la souris. On envoit
;	le paquet souris standard Atari, sur 3 octets puis si les octets sont non
;	nul, on envoit deux supplementaires qui contiennent des Scan-codes pour
;	les molettes et boutons 4 & 5.
;
;	Entrees:	HEADER, X_MOV, Y_MOV en mode IKBD souris relative
;                       HEADER, BUTTONS, X_POSH, X_POSL, Y_POSH, Y_POSL en absolu
;	Sorties:	w detruit
;-----------------------------------------------------------------------------

SendAtariMouse
		movf HEADER_IKBD,W
		sublw HEADER_ABSOLUTE_MOUSE; header souris mode absolu
		btfsc STATUS,Z
			goto SendAtariMouse_Abs; envoi mode absolu
		btfsc Flags,MOUSE_ABS
			goto Not_trame_Rel; souris en mode absolu
		btfsc Flags2,MOUSE_KEYS; envoi touches fleches
			goto Not_trame_Rel
		;-------------------------------------------------------------
		; TRANSMETTRE le paquet standard souris Atari (3 octets) mode relatif
		movf HEADER_IKBD,W
		call SerialTransmit_Host; envoyer l'octet commande vers le Host
		movf X_MOV,W; deplacement relatif souris en X
		call SerialTransmit_Host; envoyer l'octet compteur X vers le Host
		movf Y_MOV,W; deplacement relatif souris en Y
		call SerialTransmit_Host; envoyer l'octet compteur Y vers le Host
		;-------------------------------------------------------------
Not_trame_Rel                      
		;-------------------------------------------------------------
		; Test mode IKBD mouse keycodes
		btfss Flags2,MOUSE_KEYS; envoi touches fleches
			goto Not_Keys_Mouse
		movf X_MOV,W; deplacement relatif souris en X
		addwf X_INC_KEY,F; increment en X mode keycode souris
		btfsc X_INC_KEY,7
			goto Loop_Moins_H
Loop_Plus_H
			movf DELTA_X,W; deltax mode keycode souris IKBD
			subwf X_INC_KEY,W
			btfsc STATUS,C
				goto Not_Key_Mouse_H
			movwf X_INC_KEY
			call SerialTransmit_Droite
		goto Loop_Plus_H	
Loop_Moins_H
			movf DELTA_X,W; deltax mode keycode souris IKBD
			addwf X_INC_KEY,W
			btfsc STATUS,C
				goto Not_Key_Mouse_H
			movwf X_INC_KEY
			call SerialTransmit_Gauche
		goto Loop_Moins_H	
Not_Key_Mouse_H
		movf Y_MOV,W; deplacement relatif souris en Y
		addwf Y_INC_KEY,F; increment en Y mode keycode souris
		btfsc Y_INC_KEY,7
			goto Loop_Moins_V
Loop_Plus_V
			movf DELTA_Y,W; deltay mode keycode souris IKBD
			subwf Y_INC_KEY,W
			btfsc STATUS,C
				goto Not_Keys_Mouse
			movwf Y_INC_KEY
			btfss Flags,SIGN_Y	
				call SerialTransmit_Bas
			btfsc Flags,SIGN_Y	
				call SerialTransmit_Haut
		goto Loop_Plus_V	
Loop_Moins_V
			movf DELTA_Y,W; deltay mode keycode souris IKBD
			addwf Y_INC_KEY,W
			btfsc STATUS,C
				goto Not_Keys_Mouse
			movwf Y_INC_KEY
			btfss Flags,SIGN_Y	
				call SerialTransmit_Haut
			btfsc Flags,SIGN_Y	
				call SerialTransmit_Bas
		goto Loop_Moins_V
Not_Keys_Mouse
		;-------------------------------------------------------------
		; Test mode IKBD button action
		btfss BUTTON_ACTION,2; envoi touches boutons
			goto Not_Clic_Mouse
		movf BUTTONS,W; etat des boutons souris
		xorwf OLD_BUTTONS,W; ancien etat des boutons souris
		andlw 1		
		btfsc STATUS,Z
			goto Not_Change_C
		movlw 0x75; bouton droit enfonce
		btfss BUTTONS,0
			movlw 0xF5; bouton droit relache
		call SerialTransmit_Host
Not_Change_C
		movf BUTTONS,W; etat des boutons souris
		xorwf OLD_BUTTONS,W; ancien etat des boutons souris
		andlw 2		
		btfsc STATUS,Z
			goto Not_Clic_Mouse
		movlw 0x74; bouton gauche enfonce
		btfss BUTTONS,1
			movlw 0xF4; bouton gauche relache
		call SerialTransmit_Host
Not_Clic_Mouse
		;-------------------------------------------------------------
		; TRANSMETTRE le Scan code pour le bouton central (si celui-ci est non nul)
		movf CLIC_MOUSE_WHEEL,W; Tester le scan-code eventuel a transmettre
		btfsc STATUS,Z
			goto Roulettes
		; TRANSMISSION EFFECTIVE: Envoi du scan-code pour le bouton central
		call SerialTransmit_KeyUpDown; envoyer l'octet Molette
Roulettes
		;-------------------------------------------------------------
		; TRANSMETTRE le Scan code des Molettes (si celui-ci est non nul)
		movlw Tab_Mouse-EEProm+IDX_WHREPEAT
		call Lecture_EEProm; nbre repetitions touche Mouse Wheel
		movwf Counter
Repeat
			movf KEY_MOUSE_WHEEL,W ; Tester le scan-code eventuel a transmettre
			btfsc STATUS,Z
				goto Buttons45
			; TRANSMISSION EFFECTIVE: Envoi du scan-code pour la molette
			call SerialTransmit_KeyUpDown; envoyer l'octet Molette
			decfsz Counter,F; repeter l'emision
		goto Repeat
Buttons45
		;-------------------------------------------------------------
		; TRANSMETTRE le Scan code des boutons 4&5 (si celui-ci est non nul)
		movf KEY2_MOUSE_WHEEL,W; ;Tester le scan-code eventuel a transmettre
		btfsc STATUS,Z
			return
		goto SerialTransmit_KeyUpDown; envoyer l'octet bouton 4&5
		;-------------------------------------------------------------
SendAtariMouse_Abs
		;-------------------------------------------------------------
		; TRANSMETTRE le paquet souris Atari (5 octets) en mode absolu
		movf HEADER_IKBD,W
		call SerialTransmit_Host
		clrf TEMP1
		movf BUTTONS,W; etat des boutons souris
		; test changement d'etat du bouton droit
		xorwf OLD_BUTTONS_ABS,W; ancien etat des boutons souris en mode absolu
		andlw 1		
		btfsc STATUS,Z
			goto Not_Change_0
		btfsc BUTTONS,0
			bsf TEMP1,0; bouton droit enfonce
		btfss BUTTONS,0
			bsf TEMP1,1; bouton droit relache
Not_Change_0
		; test changement d'etat du bouton gauche
		movf BUTTONS,W; etat des boutons souris
		xorwf OLD_BUTTONS_ABS,W; ancien etat des boutons souris en mode absolu
		andlw 2		
		btfsc STATUS,Z
			goto Not_Change_1
		btfsc BUTTONS,1
			bsf TEMP1,2; bouton gauche enfonce
		btfss BUTTONS,1
			bsf TEMP1,3; bouton gauche relache
Not_Change_1
		; envoi de la trame mode IKBD souris absolue
		movf BUTTONS,W; etat des boutons souris
		movwf OLD_BUTTONS_ABS; ancien etat des boutons souris en mode absolu
		movf TEMP1,W
		call SerialTransmit_Host; changements boutons: B3/2: gauche relache/enfonce, B1/0: droit relache/enfonce
		movf X_POSH_SCALED,W; position X absolue souris avec facteur d'echelle poids fort
		call SerialTransmit_Host; XMSB
		movf X_POSL_SCALED,W; position X absolue souris avec facteur d'echelle poids faible
		call SerialTransmit_Host; XLSB
		movf Y_POSH_SCALED,W; position Y absolue souris avec facteur d'echelle poids fort
		call SerialTransmit_Host; YMSB
		movf Y_POSL_SCALED,W; position Y absolue souris avec facteur d'echelle poids faible
		goto SerialTransmit_Host; YLSB
	
;-----------------------------------------------------------------------------
;	Detection d'une souris InteliMouse simple. On tente la detection et on
;	positionne le bit MSWHEEL a UN si a roulette.
;
;	Methode:	Emettre Set Sample Rate 200
;				Emettre Set Sample Rate 100
;				Emettre Set Sample Rate 80
;
;				Emettre Get Device ID
;				Si retourne 	0x03 => Souris etendue a roulette
;				Sinon retourne	0x00 => Souris PS/2 standard
;-----------------------------------------------------------------------------

TryWheel
		; Envoyer le sequence de parametrage pour detecter le type
		movlw 200
		call cmdSetSmpRate
		movlw 100
		call cmdSetSmpRate
		movlw 80
		call cmdSetSmpRate; entre dans le mode Scrolling Wheel
		; Envoyer la commande pour identification
		movlw GET_DEVICE_ID
		call MPSCmd
		; Attendre maintenant la reponse d'IDENTIFICATION de la souris
		call MPSGet; Wait and get next byte
		; Analyser l'octet de retour: 0x00 = PS/2 standard/ 0x03 InteliMouse 3 boutons
		bcf Flags,MSWHEEL
		movf Value,W
		sublw MS_WHEEL; soustraire le code InteliMouse 3 boutons
		btfsc STATUS,Z
			bsf Flags,MSWHEEL; MS scrolling mouse
		; JUST for test: si affichage BCD afficher le code ID de la souris
		IF SERIAL_DEBUG
		movf Value,W
		btfss PORTB,JUMPER5; si mode debug
			call SerialTransmit_Host
		ENDIF
		movlw 100; remettre le taux d'echantillonnage initial
		goto cmdSetSmpRate; quitte le mode

;-----------------------------------------------------------------------------
;       Detection d'une souris InteliMouse etendue, c'est a dire 5 boutons et
;       eventuellement avec deuxieme roulette. On tente la detection et on positionne
;       le bit MSWHEELPLUS a UN si a roulette.
;
;       Methode: Emettre Set Sample Rate 200
;                Emettre Set Sample Rate 200
;                Emettre Set Sample Rate 80
;
;                Emettre Get Device ID
;                Si retourne 0x04 => Souris etendue a roulette
;                Sinon retourne	0x00 => Souris PS/2 standard
;-----------------------------------------------------------------------------

TryWheelPlus
		; Envoyer le sequence de parametrage pour detecter le type
		movlw 200
		call cmdSetSmpRate
		movlw 200
		call cmdSetSmpRate
		movlw 80
		call cmdSetSmpRate; entre dans le mode Scrolling Wheel + 5 boutons
		; Envoyer la commande pour identification
		movlw GET_DEVICE_ID
		call MPSCmd
		; Attendre maintenant la reponse d'IDENTIFICATION de la souris
		call MPSGet; Wait and get next byte
		; Analyser l'octet de retour: 0x00 = PS/2 standard/ 0x04 Etendue a roulette
		bcf Flags,MSWHEELPLUS
		movf Value,W
		sublw MS_WHEELPLUS; soustraire le code InteliMouse 5 boutons
		btfsc STATUS,Z
			bsf Flags,MSWHEELPLUS; MS Intellimouse
		; JUST for test: si affichage BCD afficher le code ID de la souris
		IF SERIAL_DEBUG
		movf Value,W
		btfss PORTB,JUMPER5; si mode debug
			call SerialTransmit_Host
		ENDIF
		movlw 100; remettre le taux d'echantillonnage initial
		goto cmdSetSmpRate; quitte le mode

;-----------------------------------------------------------------------------
;   Traduction des touches AT vers ATARI. Cette procedure traite les
;	Scan-codes du jeu 2 ou 3 du clavier PS/2.
;
;	Make code: 	<Octet touche>
;	Break code:	<$F0><Octet touche> pour le jeu 3
;
;   Entree: Value = Octet keyboard recu, et flag BREAK_CODE a 1 pour BreakCode
;   Sortie: W = detruit
;
;   Global: Value qui contient l'octet
;-----------------------------------------------------------------------------

SendAtariKeyboard
		; controller pour ne pas depasser la taille de la table
		; La bit Carry pour un sublw positionne a ZERO le bit
		; si le soustraction donne un reste donc un depassement
		movf Value,W			
		sublw MAX_VALUE_LOOKUP; soustraire l'offset MAX
		btfss STATUS,C; si carry =1 pas de problemes on passe
			return; ignore code > MAX_VALUE_LOOKUP
		bcf Flags4,FORCE_ALT_SHIFT; pas de forcage ALT / SHIFT vers l'unite centrale
		btfss Flags3,KEYB_SET_2
			goto GetSet3
		; traitement jeu 2
		btfsc Flags3,NEXT_CODE
			goto NextCode
		movf Value,W; recharge w avec la valeur
		sublw 0x11; LEFT ALT code jeu 2, traitement particulier
		btfss STATUS,Z
			goto NoAltSet2
		bcf Flags3,ALT_PS2; relachement Alt
		btfss Flags2,BREAK_CODE
			bsf Flags3,ALT_PS2
		movlw DEF_ALTGR; Atari
                goto SaveValue
NoAltSet2
		movlw HIGH Get_Set2_ScanCode_1
	        movwf PCLATH
		btfsc Info_Boot,7
			bsf PCLATH,4; page 2-3 (0x1000 - 0x1FFF)
		movf Value,W; recharge w avec la valeur
		call Get_Set2_ScanCode_1
		bcf PCLATH,3; page 0 ou 2
		goto TestIdxEeprom
NextCode
		movlw HIGH Get_Set2_ScanCode_2
	        movwf PCLATH
		btfsc Info_Boot,7
			bsf PCLATH,4; page 2-3 (0x1000 - 0x1FFF)
		movf Value,W; recharge w avec la valeur
		call Get_Set2_ScanCode_2
		bcf PCLATH,3; page 0 ou 2
TestIdxEeprom		
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)
		call Search_Code_Set3
		bcf PCLATH,3; page 0 ou 2
		iorlw 0
		btfsc STATUS,Z
			goto TestCode; scan-code EEPROM non trouve
GetSet3		; traitement jeu 3
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)
		call Test_Shift_Alt_AltGr
		bcf PCLATH,3; page 0 ou 2
		btfsc Flags3,ALT_PS2
			goto No_Modifier; Alt enfonce, utilise uniquement la table en EEPROM
		movlw HIGH Get_Modifier
		movwf PCLATH
		btfsc Info_Boot,7
			bsf PCLATH,4; page 2-3 (0x1000 - 0x1FFF)
		movf Value,W
		call Get_Modifier
		bcf PCLATH,3; page 0 ou 2
		movwf Counter
		btfss Counter,7
			clrf Counter; pas de forcage ALT / SHIFT vers l'unite centrale
		btfsc Counter,7
			bsf Flags4,FORCE_ALT_SHIFT	
                btfss Flags5,ALTGR_PS2_BREAK
                	goto NoAltGr
		movlw HIGH Get_Scan_Codes_AltGr
		movwf PCLATH
		btfsc Info_Boot,7
			bsf PCLATH,4; page 2-3 (0x1000 - 0x1FFF)
		movf Value,W
		call Get_Scan_Codes_AltGr
		bcf PCLATH,3; page 0 ou 2
		iorlw 0
		btfsc STATUS,Z
			goto NoAltGr
		swapf Counter,F; bit 1: ALT, bit 0: SHIFT states for the AltGr table
		bcf Counter,6
		btfsc Counter,2
			bsf Counter,6; recopie forcage bit 6 CTRL eventuel
		goto SaveValue; code avec AltGr
NoAltGr
                btfss Flags5,SHIFT_PS2_BREAK
                	goto No_Modifier
		movlw HIGH Get_Scan_Codes_Shift
		movwf PCLATH
		btfsc Info_Boot,7
			bsf PCLATH,4; page 2-3 (0x1000 - 0x1FFF)
		movf Value,W
		call Get_Scan_Codes_Shift
		bcf PCLATH,3; page 0 ou 2
		iorlw 0
		btfsc STATUS,Z
			goto No_Modifier
		rrf Counter,F			
		rrf Counter,F; bit 1: ALT, bit 0: SHIFT states for the Shift table
		bcf Counter,6
		btfsc Counter,4
			bsf Counter,6; recopie forcage bit 6 CTRL eventuel 
		goto SaveValue; code avec Shift
No_Modifier
		movf Value,W
GetValueEEProm
		call Lecture_EEProm; scan-code EEPROM jeu 3 eventuellement modifie
SaveValue	; partie commune jeu 2 & 3
		movwf Value; sauvegarder le resultat dans Value
TestCode
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)
		call Test_Shift_Alt_Ctrl_Host
		bcf PCLATH,3; page 0 ou 2
		btfsc Flags2,BREAK_CODE
			goto NoForceHostCtrlAltShift; relachement
		btfss Flags4,FORCE_ALT_SHIFT
			goto TestKeyForced; pas de forcage d'apres la table Modidier
		bsf Flags4,KEY_FORCED
		btfss Counter,6; CTRL
			goto NoForceHostCtrl
		movlw 0x1D; CTRL
		btfss Flags4,CTRL_HOST
			call SerialTransmit_Host
NoForceHostCtrl
		btfsc Counter,0; SHIFT
			goto ForceShiftOn
		movlw 0xAA; relachement LEFT SHIFT
		btfsc Flags4,LEFT_SHIFT_HOST
			call SerialTransmit_Host
		movlw 0xB6; relachement RIGHT SHIFT
		btfsc Flags4,RIGHT_SHIFT_HOST
			call SerialTransmit_Host
		goto TestAltHost
ForceShiftOn
		movlw 0x2A; LEFT SHIFT
		btfss Flags4,LEFT_SHIFT_HOST
			call SerialTransmit_Host
		movf Value,W
		sublw 0x60; <
		btfsc STATUS,Z
			goto TestAltHost
		movlw 0x36; RIGHT SHIFT
		btfss Flags4,RIGHT_SHIFT_HOST
			call SerialTransmit_Host
TestAltHost
		btfsc Counter,1; ALT
			goto ForceAltOn
		movlw 0xB8; relachement ALT
		btfsc Flags4,ALT_HOST
			call SerialTransmit_Host
		goto NoForceHostCtrlAltShift	
ForceAltOn
		movlw 0x38; ALT
		btfss Flags4,ALT_HOST
			call SerialTransmit_Host
		goto NoForceHostCtrlAltShift
TestKeyForced	
		call Remove_Key_Forced; cas anormal d'un CTRL, SHIFT ou ALT encore force
NoForceHostCtrlAltShift
		movf Value,W; tester si translation a donne 0
		btfsc STATUS,Z; Z=1 si w contient 0
			return; pas d'affectation
		btfss Value,7
			goto NoSpecialCodeWithStatus; code < 0x80
; >= 0x80 => envoyes via 0xF6 0x05 0x00 0x00 0x00 0x00 0x00 0xXX-0x80
; ou 0xF6 0x05 0x00 0x00 0x00 0x00 0x00 0xXX si relachement
		bcf Value,7
		movf Value,W
		sublw MAX_VALUE_ATARI; soustraire l'offset MAX
		btfss STATUS,C; si carry =1 pas de problemes on passe
			return; ignore code > MAX_VALUE_ATARI
		movlw HEADER_STATUS; header d'etat
		call SerialTransmit_Host
		movlw IKBD_PROGKB; code Eiffel
		call SerialTransmit_Host
		movlw 5
		call TransmitNullBytes
NoSpecialCodeWithStatus
		movf Value,W
		sublw MAX_VALUE_ATARI; soustraire l'offset MAX
		btfss STATUS,C; si carry =1 pas de problemes on passe
			return; ignore code > MAX_VALUE_ATARI
		movf Value,W
		btfsc Flags2,BREAK_CODE
			iorlw 0x80; relachement (BreakCode Bit7=1)
		movwf TEMP3
                ; Detecter si CAPS LOCK appuye pour allumer/eteindre la LED
		sublw KEY_CAPSLOCK; Caps Lock
		btfsc STATUS,Z
			call CapsLock
		movf TEMP3,W
		call SerialTransmit_Host; Atari scan-code
		btfss Flags2,BREAK_CODE
			return; enfoncement
		; relachement (break code)
		btfss Flags4,FORCE_ALT_SHIFT
			return; pas de forcage d'apres la table Modifier
		bcf Flags4,KEY_FORCED
		btfss Counter,6; CTRL
			goto NoForceHostCtrl2
		movlw 0x9D; relachement CTRL
		btfss Flags4,CTRL_HOST
			call SerialTransmit_Host
NoForceHostCtrl2
		btfsc Counter,0; SHIFT
			goto RestoreShift
		movlw 0x2A; LEFT SHIFT
		btfsc Flags4,LEFT_SHIFT_HOST
			call SerialTransmit_Host
		movlw 0x36; RIGHT SHIFT
		btfsc Flags4,RIGHT_SHIFT_HOST
			call SerialTransmit_Host
		goto TestAltHost2
RestoreShift
		movlw 0xAA; relachement LEFT SHIFT
		btfss Flags4,LEFT_SHIFT_HOST
			call SerialTransmit_Host
		movlw 0xB6; relachement RIGHT SHIFT
		btfss Flags4,RIGHT_SHIFT_HOST
			call SerialTransmit_Host
TestAltHost2
		btfsc Counter,1; ALT
			goto RestoreAlt
		movlw 0x38; ALT
		btfsc Flags4,ALT_HOST
			call SerialTransmit_Host
		return	
RestoreAlt
		movlw 0xB8; relachement ALT
		btfss Flags4,ALT_HOST
			call SerialTransmit_Host
		return

;-----------------------------------------------------------------------------
;  Cas anormal d'un CTRL, SHIFT ou ALT encore force
;-----------------------------------------------------------------------------	

Remove_Key_Forced
		btfss Flags4,KEY_FORCED
			return
		btfsc Flags4,CTRL_HOST
			goto UnforceHostCtrlAltShift
		btfsc Flags4,LEFT_SHIFT_HOST
			goto UnforceHostCtrlAltShift
		btfsc Flags4,RIGHT_SHIFT_HOST
			goto UnforceHostCtrlAltShift
		btfss Flags4,ALT_HOST
			return
UnforceHostCtrlAltShift
		bcf Flags4,KEY_FORCED
		movlw 0x9D; relachement CTRL
		call SerialTransmit_Host
		movlw 0xAA; relachement LEFT SHIFT
		call SerialTransmit_Host
		movlw 0xB6; relachement RIGHT SHIFT
		call SerialTransmit_Host
		movlw 0xB8; relachement ALT
		goto SerialTransmit_Host

;-----------------------------------------------------------------------------
;  Reception USART octet par octet sur une commande LOAD
;-----------------------------------------------------------------------------		
		
Receive_Bytes_Load		
		IF LCD
		IF !LCD_DEBUG		
		btfsc Flags4,RE_LCD_IKBD; fin reception donnees LCD
			goto Receive_Load_Lcd
		ENDIF
		ENDIF
		; reception en cours des octets via la commande LOAD
		btfsc PTRH_LOAD,0
			goto Not_Page_0_1; pages 2-3
		bcf STATUS,IRP; pages 0-1
		btfss PTRL_LOAD,7
			goto Not_Load; ignore page 0 (utilisee pour les variables)
		goto Load_Page
Not_Page_0_1
		bsf STATUS,IRP; pages 2-3
		btfsc PTRL_LOAD,7
			goto Not_Load; ignore page 3 (utilisee pour le tampon d'emission)
Load_Page
		movf PTRL_LOAD,W
		andlw 0x60
		btfsc STATUS,Z
			goto Not_Load; ignore adresse < 0x20 (registres)
		movf PTRL_LOAD,W
		movwf FSR	
		andlw 0x70
		sublw 0x70
		btfsc STATUS,Z
			goto Not_Load; ignore adresse >= 0x70 (variables communes aux 4 pages)
		movf Value,W
		movwf INDF
Not_Load        
		incf PTRL_LOAD,F
		btfsc STATUS,Z
			incf PTRH_LOAD,F
		IF LCD
		IF !LCD_DEBUG
		goto Next_Byte_Load
Receive_Load_Lcd
		movf Value,W
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)
		call SendCHAR
		bcf PCLATH,3; page 0 ou 2
Next_Byte_Load
		ENDIF
		ENDIF
		decfsz Counter_LOAD,F
			return
		bcf Flags4,RE_LCD_IKBD; fin reception donnees LCD
		bcf Flags3,RE_TIMER_IKBD; fin reception donnees IKBD dans la boucle principale
		return

;-----------------------------------------------------------------------------
;   Wait for byte to be received in USART and return with byte in Value
;-----------------------------------------------------------------------------

SerialReceive
		btfss PIR1,RCIF ; check if data received
			goto SerialReceive; wait until new data
		btfss RCSTA,OERR
			goto TestFramingError
		bcf RCSTA,CREN; acquitte erreur Overrun
		bsf RCSTA,CREN; enable reception
		goto SerialReceive
TestFramingError
		btfss RCSTA,FERR 
			goto GetByteReceived
		movf RCREG,W; acquitte erreur Framing Error
                goto SerialReceive
GetByteReceived
		movf RCREG,W; get received data into W
		movwf Value; put w into Value (result)
		return

;-----------------------------------------------------------------------------
;   Transmit byte in W register from USART
;
; Entree: W = donnee binaire
; Sortie: Rien
;
; Global: TEMP2, TEMP3, TEMP4, TEMP5, TEMP6
;         DEB_INDEX_EM, FIN_INDEX_EM, TAMPON_EM utilises
;-----------------------------------------------------------------------------
		
SerialTransmit_Host
		IF SERIAL_DEBUG
		btfsc PORTB,JUMPER5
			goto Mode_Binaire; if jumper5 disable (5V) normal
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)	
		call SendHexa; if mode debug
		bcf PCLATH,3; page 0 ou 2
		return
Mode_Binaire
		ENDIF
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)		
		call SerialTransmit; envoyer l'octet commande vers le Host
		bcf PCLATH,3; page 0 ou 2
		return
		
;-----------------------------------------------------------------------------
;   Transmit null bytes from USART
;
; Entree: W = nombre d'octets nuls a envoyer
; Sortie: Rien
;
; Global: Counter
;-----------------------------------------------------------------------------

TransmitNullBytes
		movwf Counter	
Loop_SerialTransmit_Status
			clrw
			call SerialTransmit_Host
			decfsz Counter,F
		goto Loop_SerialTransmit_Status
		return		

;-----------------------------------------------------------------------------
;   Envoi des fleches
;-----------------------------------------------------------------------------

SerialTransmit_Haut
		movlw 0x48; bouton fleche haut
		goto SerialTransmit_KeyUpDown
		
SerialTransmit_Bas
		movlw 0x50; bouton fleche bas
		goto SerialTransmit_KeyUpDown
		
SerialTransmit_Gauche
		movlw 0x4B; bouton fleche gauche
		goto SerialTransmit_KeyUpDown
		
SerialTransmit_Droite
		movlw 0x4D; bouton fleche droite

;-----------------------------------------------------------------------------
;   Envoi du code d'une touche et son relachement juste apres
;
; Entree: W = donnee binaire
; Sortie: Rien
;
; Global: Value utilise
;-----------------------------------------------------------------------------

SerialTransmit_KeyUpDown
		movwf Value
		call SerialTransmit_Host; touche enfonce
		movf Value,W
		iorlw 0x80; relachement
		goto SerialTransmit_Host

;-----------------------------------------------------------------------------
;   Changement d'etat led Caps Lock
;
; Entree: W = donnee binaire
; Sortie: Rien
;
; Global: Flags, Flags3
;-----------------------------------------------------------------------------
		
CapsLock
		IF SCROOL_LOCK_ERR
		bsf PARITY,7
		ENDIF
		btfss Flags,CAPS_LOCK; tester le bit CapsLock est active
			goto CapsToOn; on execute le goto si bit=0
		; CapsLock etait deja enclenche: On desactive sa LED et annule son bit
		bcf Flags,CAPS_LOCK
		goto UpdateLedOnOff
CapsToOn
		; CapsLock n'etait pas enclenche: on active sa LED et on active son bit
		bsf Flags,CAPS_LOCK

UpdateLedOnOff
		movlw CAPS_OFF
		btfsc Flags,CAPS_LOCK
			movlw CAPS_ON
		IF SCROOL_LOCK_ERR
		btfss PARITY,7  	
			iorlw LED_SCROLL
		ENDIF

;-----------------------------------------------------------------------------
;   Allumer LEDs clavier AT
;
;   Entree: Var LED contient le champ de bits
;   Sortie: W = detruit
;
;   Global: Var LED
;-----------------------------------------------------------------------------

cmdLedOnOff
		IF !SCROOL_LOCK_ERR
		btfsc Flags3,KEYB_SET_2
			iorlw LED_SCROLL; jeu no 2
		ENDIF
		movwf TEMP2
		movlw SET_RESET_LEDS; envoyer la commande d'allumage
		call KPSCmd
		movf TEMP2,W; Allumer LEDs choisies
		goto KPSCmd

;-----------------------------------------------------------------------------
;   Activer le mode Make/Break des scan-codes.
;   Ce mode doit etre selectionne car le delais et la repetition des touches
;   sont geres par le XBIOS de l'Atari.
;
;   Entree: Rien
;   Sortie: W = detruit
;
;   Global: Aucune
;-----------------------------------------------------------------------------

cmdMakeBreak
		movlw SET_ALL_KEYS_MAKE_BREAK; envoyer la commande make/break
		goto KPSCmd

;-----------------------------------------------------------------------------
;   Envoi la commande Set Typematic Rate au clavier, pour fixer la 
;   vitesse de repetition
;
;   Entree: Rien
;   Sortie: W = detruit
;
;   Global: Aucune
;-----------------------------------------------------------------------------

;cmdTypeRate
;		movlw SET_TYPEMATIC_RATE_DELAY
;		call KPSCmd
;		movlw 0x20; delais 250 mS 30 caracteres par secondes
;		goto KPSCmd
 
;-----------------------------------------------------------------------------
;   Passage en scan-code jeu 2 ou 3 clavier
;
;   Entree: Rien
;   Sortie: W = detruit
;
;   Global: Aucune
;-----------------------------------------------------------------------------

cmdScanSet
		movlw SET_SCAN_CODE_SET; envoyer la commande de selection
		call KPSCmd
		movlw SCANCODESET3
		btfsc Flags3,KEYB_SET_2
			movlw SCANCODESET2
		goto KPSCmd

;-----------------------------------------------------------------------------
;   Envoi de la commande reset au CLAVIER
;
;   Entree: Rien
;   Sortie: W = detruit
;
;   Global: Aucune
;-----------------------------------------------------------------------------

cmdResetKey
		bcf Flags2,RESET_KEYB; flag demande reset clavier remis a 0
		movlw RESET
		goto KPSCmd

;-----------------------------------------------------------------------------
;   Envoi de la commande resend au CLAVIER
;
;   Entree: Rien
;   Sortie: W = detruit
;
;   Global: Aucune
;-----------------------------------------------------------------------------

cmdResendKey
		movlw RESEND
		goto KPS2cmd; pas d'acknoledge
		
;-----------------------------------------------------------------------------
;   Envoi de la commande enable au CLAVIER
;
;   Entree: Rien
;   Sortie: W = detruit
;
;   Global: Aucune
;-----------------------------------------------------------------------------

cmdEnableKey
		movlw ENABLE; envoyer la commande
		goto KPSCmd

;-----------------------------------------------------------------------------
;   Envoi de la commande disable au CLAVIER
;
;   Entree: Rien
;   Sortie: W = detruit
;
;   Global: Aucune
;-----------------------------------------------------------------------------

cmdDisableKey
		movlw DEFAULT_DISABLE
		goto KPSCmd

;-----------------------------------------------------------------------------
;   Envoi de la commande reset a la SOURIS
;
;   Entree: Rien
;   Sortie: W = detruit
;
;   Global: Aucune
;-----------------------------------------------------------------------------

cmdResetMouse
		bcf Flags2,RESET_MOUSE; flag demande reset souris remis a 0
		movlw RESET
		goto MPSCmd

;-----------------------------------------------------------------------------
;   Envoi de la commande resend a la SOURIS
;
;   Entree: Rien
;   Sortie: W = detruit
;
;   Global: Aucune
;-----------------------------------------------------------------------------

cmdResendMouse
		movlw RESEND
		goto MPS2cmd; pas d'Acknowledge

;-----------------------------------------------------------------------------
;   Envoi de la commande enable a la SOURIS
;
;   Entree: Rien
;   Sortie: W = detruit
;
;   Global: Aucune
;-----------------------------------------------------------------------------

cmdEnableMous
		movlw ENABLE_DATA_REPORTING
		goto MPSCmd

;-----------------------------------------------------------------------------
;   Envoi de la commande disable a la SOURIS
;
;   Entree: Rien
;   Sortie: W = detruit
;
;   Global: Aucune
;-----------------------------------------------------------------------------

cmdDisableMouse
		movlw DISABLE_DATA_REPORTING
		goto MPSCmd

;-----------------------------------------------------------------------------
;   Emission de la commande set sample rate sur la souris
;
;   Entree: Rien
;   Sortie: W = detruit
;
;   Global: Aucune
;-----------------------------------------------------------------------------

cmdSetSmpRate
		movwf TEMP2
		movlw SET_SAMPLE_RATE
		call MPSCmd
		movf TEMP2,W
		goto MPSCmd
		
;-----------------------------------------------------------------------------
;   Emission d'une commande sur le clavier
;
;   Entree: W
;   Sortie: W = detruit
;
;   Global: Aucune
;-----------------------------------------------------------------------------

KPSCmd
		call KPS2cmd; => atente Value Acknowledge
		
;-----------------------------------------------------------------------------
;   KEYBOARD: Routine de lecture d'un octet du port DIN5 et MiniDIN6
;
;   Entree: Rien
;   Sortie: W = 1 si octet recu sinon 0
;           VAR Value = octet recu
;-----------------------------------------------------------------------------

KPSGet
		; Test l'horloge, si etat bas, le clavier communique
		IF NON_BLOQUANT	
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)	
		call Wait_Kclock
		bcf PCLATH,3; page 0 ou 2
		movf Counter,W
		btfsc STATUS,Z
			return; time-out
		ELSE
		WAIT_KCLOCK_L; attente front descendant de CLK
		ENDIF	
KPSGet2
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)		
		call _KPSGet2
		bcf PCLATH,3; page 0 ou 2
		return

;-----------------------------------------------------------------------------
;This routine sends a byte in w to a PS/2 mouse or keyboard. TEMP1, TEMP2,
;and PARITY are general purpose registers. CLOCK and DATA are assigned to
;port bits, and "Delay" is a self-explainatory macro. DATA and CLOCK are
;held high by setting their I/O pin to input and allowing an external pullup
;resistor to pull the line high. The lines are brought low by setting the
;I/O pin to output and writing a "0" to the pin.
;-----------------------------------------------------------------------------

KPS2cmd
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)		
		call _KPS2cmd
		bcf PCLATH,3; page 0 ou 2
		return

;-----------------------------------------------------------------------------
;   Emission d'une commande sur la souris
;
;   Entree: W
;   Sortie: W = detruit
;
;   Global: Aucune
;----------------------------------------------------------------------------

MPSCmd
		call MPS2cmd; => atente Value Acknowledge
		
;-----------------------------------------------------------------------------
;   Routine de lecture d'un octet sur le port SOURIS. Elle ATTEND qu'un paquet
;   soit disponible.
;
;   Entree: Rien
;   Sortie: W = 1 si octet recu sinon 0
;           VAR Value = octet recu
;-----------------------------------------------------------------------------

MPSGet
		; Test l'horloge, si etat bas, la souris communique
		IF NON_BLOQUANT
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)	
		call Wait_Mclock
		bcf PCLATH,3; page 0 ou 2
		movf Counter,W
		btfsc STATUS,Z
			return; time-out
		ELSE
		WAIT_MCLOCK_L; attente front descendant de CLK
		ENDIF
MPSGet2
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)		
		call _MPSGet2
		bcf PCLATH,3; page 0 ou 2
		return
		
;-----------------------------------------------------------------------------
;This routine sends a byte in w to a PS/2 mouse
;-----------------------------------------------------------------------------

MPS2cmd
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)		
		call _MPS2cmd
		bcf PCLATH,3; page 0 ou 2
		return

;-----------------------------------------------------------------------------
;Some routine for reduce the code size
;-----------------------------------------------------------------------------

Lecture_EEProm
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)
		call Lecture_EEProm2
		bcf PCLATH,3; page 0 ou 2
		return
		
Leds_Eiffel_On
		bcf PORTB,LEDGREEN; allume les deux LEDs
		bcf PORTB,LEDYELLOW
		return

Leds_Eiffel_Off
		bsf PORTB,LEDGREEN; eteint les deux LEDs
		bsf PORTB,LEDYELLOW
		return

;-----------------------------------------------------------------------------

		ORG   0x8C8; zone de 0x800 a 0x8C7 pour le programme de flashage

;=============================================================================
;                               PROCEDURES ET FONCTIONS
;-----------------------------------------------------------------------------
; Zone en page 1 ou 3 pour des fonctions 
;
; du programme en page 0, appel: 
;		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)
;		call fonction
;		bcf PCLATH,3; page 0 ou 2
; ou avec table avec PCL:
;		movlw HIGH fonction
;	        movwf PCLATH
;		btfsc Info_Boot,7
;			bsf PCLATH,4; page 2-3 (0x1000 - 0x1FFF)
;		call fonction
;		bcf PCLATH,3; page 0 ou 2
; Si une fonction appelle une autre fonction dans la meme page un call est 
; suffisant sauf si c'est une fonction avec table PCL:
;		movlw HIGH fonction
;	        movwf PCLATH
;		btfsc Info_Boot,7
;			bsf PCLATH,4; page 2-3 (0x1000 - 0x1FFF)
;		call fonction
;=============================================================================

;-----------------------------------------------------------------------------
;               Division Counter3:Counter2 / W (TEMP3) 
;		         resultat dans Counter3:Counter2
;			 reste dans Value
;-----------------------------------------------------------------------------
	
Div_1608
		movwf TEMP3	
		UDIV1608L Counter3,Counter2,TEMP3,Value
		return	

;-----------------------------------------------------------------------------
;  Lecture des deux joysticks dans JOY0 et JOY1
;-----------------------------------------------------------------------------	

Read_Joysticks
		comf PORTA,W
		movwf JOY0
		rrf JOY0,W
		andlw 0x1F
		movwf JOY0; lecture joystick 0
		comf PORTC,W
		andlw 0x1F
		movwf JOY1; lecture joystick 1
		return

;-----------------------------------------------------------------------------
; Delais 4w+4 cycles (avec call,return, et movlw) (0=256)
;
;   Entree: W = delais en uS
;   Sortie: Rien
;
;-----------------------------------------------------------------------------

Delay_Routine
			addlw -1; Precise delays used in I/O
			btfss STATUS,Z
				goto Delay_Routine
		return
		
;-----------------------------------------------------------------------------

		ORG   0x900

;-----------------------------------------------------------------------------
;   Implementation d'une table de correspondance pour donner le nombre de
;   jour dans le mois, w contient le mois et retourne le nombre de jours 
;
;   Entree: W = Mois
;   sortie: W = Nombre de jours du mois
;
;   Global: Aucune
;-----------------------------------------------------------------------------

Days_In_Month
		addwf PCL,F
		nop
		retlw 31; janvier
		retlw 28; fevrier
		retlw 31; mars
		retlw 30; avril
		retlw 31; mai
		retlw 30; juin
		retlw 31; juillet
		retlw 31; aout
		retlw 30; septembre
		retlw 31; octobre
		retlw 30; novembre
		retlw 31; decembre		
		retlw 31
		retlw 31
		retlw 31
		
;------------------------------------------------------------------------
;   Retoune le scan code pour le jeu 2
;
;   Entree: W = Scan code jeut 2 a convertir si 0xE0 => 2eme code
;   sortie: W = Scan code Atari
;
;   Global: Aucune
;------------------------------------------------------------------------

Get_Set2_ScanCode_1
		addwf PCL,F
		retlw 0x00; offset + 0x00  jamais utilise: "Error or Buffer Overflow"
		retlw 0x43; offset + 0x01 F9
		retlw 0x00; offset + 0x02  jamais utilise
		retlw 0x3F; offset + 0x03 F5
		retlw 0x3D; offset + 0x04 F3
		retlw 0x3B; offset + 0x05 F1
		retlw 0x3C; offset + 0x06 F2
		retlw DEF_F12; offset + 0x07 F12          <= UNDO ATARI (Fr)
		retlw 0x00; offset + 0x08  jamais utilise
		retlw 0x44; offset + 0x09 F10
		retlw 0x42; offset + 0x0A F8
		retlw 0x40; offset + 0x0B F6
		retlw 0x3E; offset + 0x0C F4
		retlw 0x0F; offset + 0x0D TABULATION
		retlw DEF_RUSSE; offset + 0x0E touche <2> (`) ( a cote de 1 )
		retlw 0x00; offset + 0x0F  jamais utilise
		retlw 0x00; offset + 0x10  jamais utilise
		retlw DEF_ALTGR; offset + 0x11 LEFT ALT (Atari en n'a qu'un)
		retlw 0x2A; offset + 0x12 LEFT SHIFT
		retlw 0x00; offset + 0x13  jamais utilise
		retlw 0x1D; offset + 0x14 LEFT CTRL (Atari en n'a qu'un)
		retlw 0x10; offset + 0x15 A (Q)
		retlw 0x02; offset + 0x16 1
		retlw 0x00; offset + 0x17  jamais utilise
		retlw 0x00; offset + 0x18  jamais utilise
		retlw 0x00; offset + 0x19  jamais utilise
		retlw 0x2C; offset + 0x1A W (Z)
		retlw 0x1F; offset + 0x1B S
		retlw 0x1E; offset + 0x1C Q (A) 
		retlw 0x11; offset + 0x1D Z (W)
		retlw 0x03; offset + 0x1E 2
		retlw 0x00; offset + 0x1F  jamais utilise
		retlw 0x00; offset + 0x20  jamais utilise
		retlw 0x2E; offset + 0x21 C
		retlw 0x2D; offset + 0x22 X
		retlw 0x20; offset + 0x23 D
		retlw 0x12; offset + 0x24 E
		retlw 0x05; offset + 0x25 4
		retlw 0x04; offset + 0x26 3
		retlw 0x00; offset + 0x27  jamais utilise
		retlw 0x00; offset + 0x28  jamais utilise
		retlw 0x39; offset + 0x29 SPACE BAR
		retlw 0x2F; offset + 0x2A V
		retlw 0x21; offset + 0x2B F
		retlw 0x14; offset + 0x2C T
		retlw 0x13; offset + 0x2D R
		retlw 0x06; offset + 0x2E 5
		retlw 0x00; offset + 0x2F  jamais utilise
		retlw 0x00; offset + 0x30  jamais utilise
		retlw 0x31; offset + 0x31 N		
		retlw 0x30; offset + 0x32 B
		retlw 0x23; offset + 0x33 H
		retlw 0x22; offset + 0x34 G
		retlw 0x15; offset + 0x35 Y
		retlw 0x07; offset + 0x36 6
		retlw 0x00; offset + 0x37  jamais utilise
		retlw 0x00; offset + 0x38  jamais utilise
		retlw 0x00; offset + 0x39  jamais utilise
		retlw 0x32; offset + 0x3A <,> (M)
		retlw 0x24; offset + 0x3B J
		retlw 0x16; offset + 0x3C U
		retlw 0x08; offset + 0x3D 7
		retlw 0x09; offset + 0x3E 8
		retlw 0x00; offset + 0x3F  jamais utilise
		retlw 0x00; offset + 0x40  jamais utilise
		retlw 0x33; offset + 0x41 <;> (,)
		retlw 0x25; offset + 0x42 K
		retlw 0x17; offset + 0x43 I
		retlw 0x18; offset + 0x44 O
		retlw 0x0B; offset + 0x45 0 (chiffre ZERO)
		retlw 0x0A; offset + 0x46 9
		retlw 0x00; offset + 0x47  jamais utilise
		retlw 0x00; offset + 0x48  jamais utilise
		retlw 0x34; offset + 0x49 <:> (.)
		retlw 0x35; offset + 0x4A <!> (/)
		retlw 0x26; offset + 0x4B L
		retlw 0x27; offset + 0x4C M   (;)
		retlw 0x19; offset + 0x4D P
		retlw 0x0C; offset + 0x4E <)> (-)
		retlw 0x00; offset + 0x4F  jamais utilise
		retlw 0x00; offset + 0x50  jamais utilise
		retlw 0x00; offset + 0x51  jamais utilise
		retlw 0x28; offset + 0x52 <—> (')
		retlw 0x2B; offset + 0x53 <*> (\) touche sur COMPAQ
		retlw 0x1A; offset + 0x54 <^> ([)
		retlw 0x0D; offset + 0x55 <=> (=)
		retlw 0x00; offset + 0x56  jamais utilise
		retlw 0x00; offset + 0x57  jamais utilise
		retlw 0x3A; offset + 0x58 CAPS
		retlw 0x36; offset + 0x59 RIGHT SHIFT
		retlw 0x1C; offset + 0x5A RETURN
		retlw 0x1B; offset + 0x5B <$> (])
		retlw 0x00; offset + 0x5C  jamais utilise
		retlw 0x2B; offset + 0x5D <*> (\) touche sur SOFT KEY		
		retlw 0x00; offset + 0x5E  jamais utilise
		retlw 0x00; offset + 0x5F  jamais utilise
		retlw 0x00; offset + 0x60  jamais utilise
		retlw 0x60; offset + 0x61 ><
		retlw 0x00; offset + 0x62  jamais utilise
		retlw 0x00; offset + 0x63  jamais utilise
		retlw 0x00; offset + 0x64  jamais utilise
		retlw 0x00; offset + 0x65  jamais utilise
		retlw 0x0E; offset + 0x66 BACKSPACE
		retlw 0x00; offset + 0x67  jamais utilise
		retlw 0x00; offset + 0x68  jamais utilise
		retlw 0x6D; offset + 0x69 KP 1
		retlw 0x00; offset + 0x6A  jamais utilise
		retlw 0x6A; offset + 0x6B KP 4	
		retlw 0x67; offset + 0x6C KP 7
		retlw 0x00; offset + 0x6D  jamais utilise
		retlw 0x00; offset + 0x6E  jamais utilise
		retlw 0x00; offset + 0x6F  jamais utilise
		retlw 0x70; offset + 0x70 KP 0 (ZERO)
		retlw 0x71; offset + 0x71 KP .
		retlw 0x6E; offset + 0x72 KP 2
		retlw 0x6B; offset + 0x73 KP 5
		retlw 0x6C; offset + 0x74 KP 6
		retlw 0x68; offset + 0x75 KP 8
		retlw 0x01; offset + 0x76 ESC
		retlw DEF_VERRNUM; offset + 0x77 VERR NUM     (unused on Atari before)		
		retlw 0x62; offset + 0x78 F11          <= HELP ATARI (Fr)
		retlw 0x4E; offset + 0x79 KP +
		retlw 0x6F; offset + 0x7A KP 3
		retlw 0x4A; offset + 0x7B KP - 
		retlw 0x66; offset + 0x7C KP *
		retlw 0x69; offset + 0x7D KP 9
		retlw DEF_SCROLL; offset + 0x7E SCROLL
		retlw 0x00; offset + 0x7F  jamais utilise
		retlw 0x00; offset + 0x80  jamais utilise
		retlw 0x00; offset + 0x81  jamais utilise
		retlw 0x00; offset + 0x82  jamais utilise
		retlw 0x41; offset + 0x83 F7
		retlw DEF_PRINTSCREEN; offset + 0x84 PRINT SCREEN + ALT
		retlw 0x00; offset + 0x85  jamais utilise
		retlw 0x00; offset + 0x86  jamais utilise
		retlw 0x00; offset + 0x87  jamais utilise
		retlw 0x00; offset + 0x88  jamais utilise
		retlw 0x00; offset + 0x89  jamais utilise
		retlw 0x00; offset + 0x8A  jamais utilise
		retlw 0x00; offset + 0x8B  jamais utilise
		retlw 0x00; offset + 0x8C  jamais utilise
		retlw 0x00; offset + 0x8D  jamais utilise
		retlw 0x00; offset + 0x8E  jamais utilise
		retlw 0x00; offset + 0x8F  jamais utilise
		
;------------------------------------------------------------------------
; Initialisation registres et variables
;------------------------------------------------------------------------

Init
		bsf STATUS,RP0; page 1
		bcf STATUS,RP1
		movlw 0x0E
		movwf ADCON1; entrees digitales sauf AN0
		movlw 0xFF
		movwf TRISA; 6 entrees
		movlw 0xDF; MOTORON en sortie
		movwf TRISC; 7 entrees
		IF LCD
		movlw 0x05; RB4 & RB5 utilises pour le LCD
		ELSE	
		movlw KM_DISABLE; LEDYELLOW,LEDGREEN,MCLOCK,KCLOCK en sortie
		ENDIF
		movwf TRISB
		movlw 125
		movwf PR2; timer 2 a 5 mS (1 MHz /4 /125 /10 )
		bcf STATUS,RP0; page 0
		movlw 0xC5; RC osc, GO, ADON, lance la conversion A/D sur AN0
		movwf ADCON0
		clrf PORTA
		; set latchs B to 0 and set On LEDs
		clrf PORTB; allow to disable devices communications	
		movlw 0x49; timer 2 prediviseur par 4 et diviseur par 10
		movwf T2CON
		clrf TMR2
		bsf T2CON,TMR2ON; lance le timer 2						
		; setup RS-232 port at 9600 or 7812.
		IF SERIAL_DEBUG
		movlw BAUD_9600; set baud rate 9600 for 4Mhz clock (fosc/16*(X+1))
		btfsc PORTB,JUMPER5; if Jumper5 enable (0V) skip
		ENDIF
		movlw BAUD_7812_5; else set baud rate 7812.5 for 4Mhz clock
		bsf STATUS,RP0; page 1
		movwf SPBRG
		IF INTERRUPTS
		bsf PIE1,TMR2IE; Timer 2 Interrupt Enable
		ENDIF
		bsf TXSTA,BRGH; baud rate high speed option, Asynchronous High Speed
		bsf TXSTA,TXEN; enable transmission
		bcf STATUS,RP0; page 0
		bsf RCSTA,CREN; enable reception
		bsf RCSTA,SPEN; enable serial port (RC6/7)
		clrf Flags
		clrf Flags2
		clrf Flags3
		clrf Flags4
		clrf Flags5
		call Read_Joysticks
		clrf Val_AN0; lecture CTN sur AN0
		clrf Temperature; lecture temperature CTN sur AN0
		clrf X_MAX_POSH; position X absolue maximale souris poids fort
		clrf X_MAX_POSL; position X absolue maximale souris poids faible
		clrf Y_MAX_POSH; position Y absolue maximale souris poids fort
		clrf Y_MAX_POSL; position Y absolue maximale souris poids faible
		movlw 1
		movwf X_SCALE; facteur d'echelle en X souris mode absolu
		movwf Y_SCALE; facteur d'echelle en Y souris mode absolu
		clrf DELTA_X; deltax mode keycode souris IKBD
		clrf DELTA_Y; deltay mode keycode souris IKBD
		clrf BUTTONS; etat des boutons souris
		clrf OLD_BUTTONS; ancien etat des boutons souris
		clrf OLD_BUTTONS_ABS; ancien etat des boutons souris mode absolu
		clrf BUTTON_ACTION; mode button action IKBD
		movlw 10
		movwf Counter_10MS_Joy; prediviseur envoi mode keycode joystick 0 (pas de 100 mS)
		clrf Counter_100MS_Joy; compteur 100 mS mode keycode joystick 0
		clrf Counter_Mouse; compteur octet reception trame souris PS/2
		clrf Counter_MState_Temperature; machine d'etat lecture temperature (reduction charge CPU)
		clrf DEB_INDEX_EM; index courant donnee a envoyer buffer circulaire liaison serie
		clrf FIN_INDEX_EM; fin index donnee a envoyer buffer circulaire liaison serie
		IF SERIAL_DEBUG
		btfss PORTB,JUMPER5; if jumper5 disable (5V) no message
			call SerialWelcome; else send this string
		ENDIF
		; Le clavier et la souris PS/2 ont ete inhibes pendant le flashage
		; le reset a chaud envoi donc un reset clavier et a la souris.
		; En cas de demarrage a froid (mise sous tension), les commandes BAT
		; arrivent naturellement du clavier et de la souris PS/2.
		btfsc Status_Boot,POWERUP_LCD
			goto Clock_Ok		
		bsf STATUS,RP1; page 2
		clrf SEC; RAZ horloge a la mise sous tension
		clrf SEC_BCD
		clrf MIN
		clrf MIN_BCD
		clrf HRS
		clrf HRS_BCD
		movlw 1
		movwf DAY
		movwf DAY_BCD
		movwf MONTH
		movwf MONTH_BCD		
		clrf YEAR
		clrf YEAR_BCD
		bcf STATUS,RP1; page 0
		IF LCD
		call Init_Lcd
		ENDIF
		bsf Status_Boot,POWERUP_LCD
Clock_Ok
		IF LCD
		IF LCD_DEBUG
		clrf Counter_Debug_Lcd
		ENDIF
		ENDIF
		btfsc Status_Boot,POWERUP_KEYB; mis a 1 des reception BAT clavier
			bsf Flags2,RESET_KEYB; valide reset clavier dans traitement timer
		btfsc Status_Boot,POWERUP_MOUSE; mis a 1 des reception BAT souris
			bsf Flags2,RESET_MOUSE; valide reset souris dans traitement timer
		bcf PIR1,TMR2IF; acquitte timer 2
		IF INTERRUPTS
		bsf INTCON,PEIE; Peripheral Interrupt Enable
		bsf INTCON,GIE; Global Interrupt Enable, autorise interruptions
		ENDIF
		return

;-----------------------------------------------------------------------------
; Delais en 1/10 de mS
;
;   Entree: W = delais en 1/10 de mS
;   Sortie: Rien
;
;   Global: Counter
;-----------------------------------------------------------------------------
	
		IF LCD
Delay_Routine_Ms

		movwf Counter
Loop_Delay_Routine_Ms
			Delay 100; uS
			decfsz Counter,F
				goto Loop_Delay_Routine_Ms
                return
                ENDIF
		
;-----------------------------------------------------------------------------
		
		ORG   0xA00

;------------------------------------------------------------------------
;   Retoune le scan code pour le jeu 2
;
;   Entree: W = Scan code jeu 2 a convertir si 0xE0 => 2eme code
;   sortie: W = Scan code Atari
;
;   Global: Aucune
;------------------------------------------------------------------------
		
Get_Set2_ScanCode_2
		addwf PCL,F
		retlw 0x00; offset + 0x00  jamais utilise
		retlw 0x00; offset + 0x01  jamais utilise
		retlw 0x00; offset + 0x02  jamais utilise
		retlw 0x00; offset + 0x03  jamais utilise
		retlw 0x00; offset + 0x04  jamais utilise
		retlw 0x00; offset + 0x05  jamais utilise
		retlw 0x00; offset + 0x06  jamais utilise
		retlw 0x00; offset + 0x07  jamais utilise
		retlw 0x00; offset + 0x08  jamais utilise
		retlw 0x00; offset + 0x09  jamais utilise
		retlw 0x00; offset + 0x0A  jamais utilise
		retlw 0x00; offset + 0x0B  jamais utilise
		retlw 0x00; offset + 0x0C  jamais utilise
		retlw 0x00; offset + 0x0D  jamais utilise
		retlw 0x00; offset + 0x0E  jamais utilise
		retlw 0x00; offset + 0x0F  jamais utilise
		retlw DEF_WWW_SEARCH; offset + 0x10 WWW SEARCH
		retlw DEF_ALTGR; offset + 0x11 RIGHT ALT GR (Atari en n'a qu'un)
		retlw 0x00; offset + 0x12  jamais utilise
		retlw 0x00; offset + 0x13  jamais utilise
		retlw 0x1D; offset + 0x14 RIGHT CTRL   (Atari en n'a qu'un)
		retlw DEF_PREVIOUS_TRACK; offset + 0x15 PREVIOUS TRACK
		retlw 0x00; offset + 0x16  jamais utilise
		retlw 0x00; offset + 0x17  jamais utilise
		retlw DEF_WWW_FAVORITES; offset + 0x18 WWW FAVORITES
		retlw 0x00; offset + 0x19  jamais utilise
		retlw 0x00; offset + 0x1A  jamais utilise
		retlw 0x00; offset + 0x1B  jamais utilise
		retlw 0x00; offset + 0x1C  jamais utilise
		retlw 0x00; offset + 0x1D  jamais utilise
		retlw 0x00; offset + 0x1E  jamais utilise
		retlw DEF_WINLEFT;  offset + 0x1F LEFT WIN
		retlw DEF_WWW_REFRESH; offset + 0x20 WWW REFRESH
		retlw DEF_VOLUME_DOWN; offset + 0x21 VOLUME DOWN
		retlw 0x00; offset + 0x22  jamais utilise
		retlw DEF_MUTE; offset + 0x23 MUTE
		retlw 0x00; offset + 0x24  jamais utilise
		retlw 0x00; offset + 0x25  jamais utilise
		retlw 0x00; offset + 0x26  jamais utilise
		retlw DEF_WINRIGHT; offset + 0x27 RIGHT WIN
		retlw DEF_WWW_STOP; offset + 0x28 WWW STOP
		retlw 0x00; offset + 0x29  jamais utilise
		retlw 0x00; offset + 0x2A  jamais utilise
		retlw DEF_CACULATOR; offset + 0x2B CALCULATOR
		retlw 0x00; offset + 0x2C  jamais utilise
		retlw 0x00; offset + 0x2D  jamais utilise
		retlw 0x00; offset + 0x2E  jamais utilise
		retlw DEF_WINAPP;   offset + 0x2F POPUP WIN
		retlw DEF_WWW_FORWARD; offset + 0x30 WWW FORWARD
		retlw 0x00; offset + 0x31  jamais utilise
		retlw DEF_VOLUME_UP; offset + 0x32 VOLUME UP
		retlw 0x00; offset + 0x33  jamais utilise
		retlw DEF_PLAY_PAUSE; offset + 0x34 PLAY/PAUSE
		retlw 0x00; offset + 0x35  jamais utilise
		retlw 0x00; offset + 0x36  jamais utilise
		retlw DEF_POWER; offset + 0x37 POWER
		retlw DEF_WWW_BACK; offset + 0x38 WWW BACK
		retlw 0x00; offset + 0x39  jamais utilise
		retlw DEF_WWW_HOME; offset + 0x3A WWW HOME
		retlw DEF_STOP; offset + 0x3B STOP
		retlw 0x00; offset + 0x3C  jamais utilise
		retlw 0x00; offset + 0x3D  jamais utilise
		retlw 0x00; offset + 0x3E  jamais utilise
		retlw DEF_SLEEP; offset + 0x3F SLEEP
		retlw DEF_MY_COMPUTER; offset + 0x40 MY COMPUTER
		retlw 0x00; offset + 0x41  jamais utilise
		retlw 0x00; offset + 0x42  jamais utilise
		retlw 0x00; offset + 0x43  jamais utilise
		retlw 0x00; offset + 0x44  jamais utilise
		retlw 0x00; offset + 0x45  jamais utilise
		retlw 0x00; offset + 0x46  jamais utilise
		retlw 0x00; offset + 0x47  jamais utilise
		retlw DEF_EMAIL; offset + 0x48 E-MAIL
		retlw 0x00; offset + 0x49  jamais utilise
		retlw 0x65; offset + 0x4A KP /
		retlw 0x00; offset + 0x4B  jamais utilise
		retlw 0x00; offset + 0x4C  jamais utilise
		retlw DEF_NEXT_TRACK; offset + 0x4D NEXT TRACK
		retlw 0x00; offset + 0x4E  jamais utilise
		retlw 0x00; offset + 0x4F  jamais utilise
		retlw DEF_MEDIA_SELECT; offset + 0x50 MEDIA SELECT
		retlw 0x00; offset + 0x51  jamais utilise
		retlw 0x00; offset + 0x52  jamais utilise
		retlw 0x00; offset + 0x53  jamais utilise
		retlw 0x00; offset + 0x54  jamais utilise
		retlw 0x00; offset + 0x55  jamais utilise
		retlw 0x00; offset + 0x56  jamais utilise
		retlw 0x00; offset + 0x57  jamais utilise
		retlw 0x00; offset + 0x58  jamais utilise
		retlw 0x00; offset + 0x59  jamais utilise				
		retlw 0x72; offset + 0x5A KP ENTER
		retlw 0x00; offset + 0x5B  jamais utilise
		retlw 0x00; offset + 0x5C  jamais utilise
		retlw 0x00; offset + 0x5D  jamais utilise
		retlw DEF_WAKE; offset + 0x5E WAKE
		retlw 0x00; offset + 0x5F  jamais utilise
		retlw 0x00; offset + 0x60  jamais utilise
		retlw 0x00; offset + 0x61  jamais utilise
		retlw 0x00; offset + 0x62  jamais utilise
		retlw 0x00; offset + 0x63  jamais utilise
		retlw 0x00; offset + 0x64  jamais utilise
		retlw 0x00; offset + 0x65  jamais utilise
		retlw 0x00; offset + 0x66  jamais utilise
		retlw 0x00; offset + 0x67  jamais utilise
		retlw 0x00; offset + 0x68  jamais utilise		
		retlw 0x55; offset + 0x69 END
		retlw 0x00; offset + 0x6A  jamais utilise
		retlw 0x4B; offset + 0x6B LEFT ARROW
		retlw 0x47; offset + 0x6C CLEAR HOME
		retlw 0x00; offset + 0x6D  jamais utilise
		retlw 0x00; offset + 0x6E  jamais utilise
		retlw 0x00; offset + 0x6F  jamais utilise		
		retlw 0x52; offset + 0x70 INSERT
		retlw 0x53; offset + 0x71 DELETE
		retlw 0x50; offset + 0x72 DOWN ARROW
		retlw 0x00; offset + 0x73  jamais utilise
		retlw 0x4D; offset + 0x74 RIGHT ARROW
		retlw 0x48; offset + 0x75 UP ARROW
		retlw 0x00; offset + 0x76  jamais utilise
		retlw 0x00; offset + 0x77  jamais utilise
		retlw 0x00; offset + 0x78  jamais utilise
		retlw 0x00; offset + 0x79  jamais utilise
		retlw DEF_PAGEDN; offset + 0x7A PAGE DOWN    (unused on Atari before)
		retlw 0x00; offset + 0x7B  jamais utilise
		retlw DEF_PRINTSCREEN; offset + 0x7C PRINT SCREEN
		retlw DEF_PAGEUP; offset + 0x7D PAGE UP      (unused on Atari before)
		retlw DEF_PAUSE; offset + 0x7E PAUSE + CTRL
		retlw 0x00; offset + 0x7F  jamais utilise
		retlw 0x00; offset + 0x80  jamais utilise
		retlw 0x00; offset + 0x81  jamais utilise
		retlw 0x00; offset + 0x82  jamais utilise
		retlw 0x00; offset + 0x83  jamais utilise
		retlw 0x00; offset + 0x84  jamais utilise
		retlw 0x00; offset + 0x85  jamais utilise
		retlw 0x00; offset + 0x86  jamais utilise
		retlw 0x00; offset + 0x87  jamais utilise
		retlw 0x00; offset + 0x88  jamais utilise
		retlw 0x00; offset + 0x89  jamais utilise
		retlw 0x00; offset + 0x8A  jamais utilise
		retlw 0x00; offset + 0x8B  jamais utilise
		retlw 0x00; offset + 0x8C  jamais utilise
		retlw 0x00; offset + 0x8D  jamais utilise
		retlw 0x00; offset + 0x8E  jamais utilise
		retlw 0x00; offset + 0x8F  jamais utilise

;-----------------------------------------------------------------------------
;               Lecture temperature CTN sur AN0
;-----------------------------------------------------------------------------

Read_Temperature
		movf Counter_MState_Temperature,W; machine d'etat lecture temperature (reduction charge CPU)
		addlw 255
		btfsc STATUS,Z
			goto Calcul_RCTN
		addlw 255
		btfsc STATUS,Z
			goto Find_Table_Temperature
		addlw 255
		btfss STATUS,Z
			return
Calcul_Temperature
		; Etape 3
		movlw Tab_CTN-EEProm+1
		call Lecture_EEProm3
		movwf TEMP4; tab_rctn+1 = temperature(n)
		movlw Tab_CTN-EEProm-2
		call Lecture_EEProm3
		movwf TEMP1; tab_rctn-2 = rctn(n-1)
		movlw Tab_CTN-EEProm-1
		call Lecture_EEProm3
		movwf TEMP5; tab_rctn-1 = temperature(n-1)
		;Temperature = TEMP5 - (RCTN-TEMP1) * (TEMP5-TEMP4)
		;                      ----------------------------
		;                              TEMP3-TEMP1
		movf TEMP1,W
		subwf RCTN,W; RCTN - TEMP1
		movwf Counter3
		movf TEMP4,W
		subwf TEMP5,W; TEMP5 - TEMP4
		call Mul_0816; Counter3:Counter2 = (RCTN-TEMP1) * (TEMP5-TEMP4)
		movf TEMP1,W
		subwf TEMP3,W; TEMP3 - TEMP1
		call Div_1608; Counter3:Counter2 = (rctn-TEMP1) * (TEMP5-TEMP4) / (TEMP3-TEMP1)
		movf Counter2,W
		subwf TEMP5,W; TEMP5 - Counter2
Cmd_Motor
		movwf Temperature
		movlw Tab_Temperature-EEProm+IDX_LEVELHTEMP
		call Lecture_EEProm2
		subwf Temperature,W; Temperature - IDX_LEVELHTEMP
		btfsc STATUS,C
			bsf PORTC,MOTORON; Temperature >= IDX_LEVELHTEMP -> marche ventilateur	
		movlw Tab_Temperature-EEProm+IDX_LEVELLTEMP
		call Lecture_EEProm2
		subwf Temperature,W; Temperature - IDX_LEVELLTEMP
		btfss STATUS,C
			bcf PORTC,MOTORON; Temperature < IDX_LEVELTEMP -> arret ventilateur	
New_Temperature
		clrf Counter_MState_Temperature
		bsf ADCON0,GO_DONE; relance la conversion
		return
Find_Table_Temperature
		; Etape 2
		clrf Idx_Temperature
		movlw 12; nbre de valeurs du tableau
		movwf Counter3
Loop_Find_Rctn
			movlw Tab_CTN-EEProm
			call Lecture_EEProm3
			movwf TEMP3; tab_rctn = rctn(n)
			subwf RCTN,W; valeur resistance CTN / 100
			btfss STATUS,C
				goto Exit_Loop_Rctn; tab_rctn > RCTN
			incf Idx_Temperature,F
			incf Idx_Temperature,F
			decfsz Counter3,F
		goto Loop_Find_Rctn
		decf Idx_Temperature,F
		decf Idx_Temperature,F
End_Tab_Rctn
		movlw Tab_CTN-EEProm+1; temperature(n)
		call Lecture_EEProm3; valeur extreme du tableau
		goto Cmd_Motor
Exit_Loop_Rctn
		movf Idx_Temperature,W
		btfsc STATUS,Z
			goto End_Tab_Rctn
		movf Counter3,W
		sublw 1
		btfsc STATUS,Z
			goto End_Tab_Rctn
		goto Next_MState_Temperature
Calcul_RCTN
		; Etape 1
		movf ADRESH,W; 8 bits poids fort
		subwf Val_AN0,W; lecture CTN sur AN0
		btfsc STATUS,Z
			goto New_Temperature; pas de changement => relance la mesure
		movf ADRESH,W; 8 bits poids fort
		movwf Val_AN0; lecture CTN sur AN0
		movwf Counter3
		movlw 100
		call Mul_0816; Counter3:Counter2 = Val_AN0 * 100
		comf Val_AN0,W; 255 - Val_AN0
		call Div_1608; Y_POS = (Val_AN0 * 100) / (255 - Val_AN0)
		movf Counter2,W; poids faible valeur CTN en ohms / 100
		movwf RCTN; valeur resistance CTN / 100
Next_MState_Temperature
		incf Counter_MState_Temperature,F
		return

Lecture_EEProm3
		addwf Idx_Temperature,W
		goto Lecture_EEProm2

Mul_0816
		movwf Value
		UMUL0808L Counter3,Counter2,Value
		return

;-----------------------------------------------------------------------------

		ORG   0xB00
		
;-----------------------------------------------------------------------------
;               Listes de liens de la zone EEPROM de stokage des Scan-Codes
;               du jeu 3 avec le jeu 2 en Flash
;-----------------------------------------------------------------------------

Get_List_Idx_Set3
		addwf PCL,F
		nop
		retlw 0x07; F1
		retlw IDX_RUSSE
		retlw 0x0F; F2
		retlw 0x11; LEFT CTRL (Atari en n'a qu'un)
		retlw 0x12; LEFT SHIFT
		retlw 0x13; ><
		retlw 0x15; A (Q)
		retlw 0x16; 1
		retlw 0x17; F3
		retlw 0x1E; 2
		retlw 0x1F; F4
		retlw 0x24; E
		retlw 0x25; 4
		retlw 0x26; 3
		retlw 0x27; F5
		retlw 0x2E; 5
		retlw 0x2F; F6
		retlw 0x36; 6
		retlw 0x37; F7
		retlw IDX_ALTGR
		retlw 0x3A; <,> (M)
		retlw 0x3D; 7
		retlw 0x3E; 8
		retlw 0x3F; F8
		retlw 0x41; <;> (,)
		retlw 0x45; 0 (ZERO)
		retlw 0x46; 9
		retlw 0x47; F9
		retlw 0x49; <:> (.)
		retlw 0x4A; <!> (/)
		retlw 0x4C; M   (;)
		retlw 0x4E; <)> (-)
		retlw 0x4F; F10
		retlw 0x52; <—> (')
		retlw 0x53; <*> (\) COMPAQ
		retlw 0x54; <^> ([)
		retlw 0x55; <=> (=)
		retlw IDX_F11
		retlw IDX_PRNTSCREEN
		retlw 0x59; RIGHT SHIFT
		retlw 0x5B; <$> (])
		retlw IDX_F12
		retlw IDX_SCROLL
		retlw IDX_PAUSE
		retlw IDX_END
		retlw IDX_PAGEDN
		retlw IDX_PAGEUP
		retlw IDX_VERRN
		retlw IDX_SLEEP
		retlw IDX_POWER
		retlw IDX_WAKE
		retlw IDX_WLEFT
		retlw IDX_WRIGHT
		retlw IDX_WAPP
End_Get_List_Idx_Set3

Get_List_Def_Set3
		addwf PCL,F
		nop; demarre a 1
		retlw 0x3B; F1
		retlw DEF_RUSSE
		retlw 0x3C; F2
		retlw 0x1D; LEFT CTRL (Atari en n'a qu'un)
		retlw 0x2A; LEFT SHIFT	
		retlw 0x60; ><
		retlw 0x10; A (Q)
		retlw 0x02; 1
		retlw 0x3D; F3
		retlw 0x03; 2
		retlw 0x3E; F4
		retlw 0x12; E
		retlw 0x05; 4
		retlw 0x04; 3
		retlw 0x3F; F5
		retlw 0x06; 5
		retlw 0x40; F6
		retlw 0x07; 6
		retlw 0x41; F7
		retlw DEF_ALTGR
		retlw 0x32; <,> (M)
		retlw 0x08; 7
		retlw 0x09; 8
		retlw 0x42; F8	
		retlw 0x33; <;> (,)
		retlw 0x0B; 0 (ZERO)
		retlw 0x0A; 9
		retlw 0x43; F9
		retlw 0x34; <:> (.)
		retlw 0x35; <!> (/)
		retlw 0x27; M   (;)
		retlw 0x0C; <)> (-)
		retlw 0x44; F10
		retlw 0x28; <—> (')
		retlw 0x2B; <*> (\) COMPAQ
		retlw 0x1A; <^> ([)
		retlw 0x0D; <=> (=)
		retlw DEF_F11
		retlw DEF_PRINTSCREEN
		retlw 0x36; RIGHT SHIFT
		retlw 0x1B; <$> (])
		retlw DEF_F12
		retlw DEF_SCROLL
		retlw DEF_PAUSE
		retlw DEF_END
		retlw DEF_PAGEDN
		retlw DEF_PAGEUP
		retlw DEF_VERRNUM
		retlw DEF_SLEEP
		retlw DEF_POWER
		retlw DEF_WAKE
		retlw DEF_WINLEFT
		retlw DEF_WINRIGHT
		retlw DEF_WINAPP
End_Get_List_Def_Set3

;-----------------------------------------------------------------------------
;               Cherche un code pour le jeu 3 a partir d'un code du jeu 2
;
;   Entree: W = Scan code jeu 2
;   sortie: Value, W = Scan code jeu 3
;
;   Global: Value, Counter
;-----------------------------------------------------------------------------
 
Search_Code_Set3
		movwf Value
		movlw HIGH Get_List_Def_Set3
	        movwf PCLATH
		btfsc Info_Boot,7
			bsf PCLATH,4; page 2-3 (0x1000 - 0x1FFF)
		movlw End_Get_List_Def_Set3-Get_List_Def_Set3-2
		movwf Counter; verifie si le scan-code Atari n'est pas dans la liste modifiable en EEPROM 
LoopIdxEeeprom
			movf Counter,W
			call Get_List_Def_Set3
                        subwf Value,W
                        btfsc STATUS,Z
                        	goto FoundValueEeprom
			decfsz Counter,F	
		goto LoopIdxEeeprom
		clrw; fin de tableau => scan-code EEPROM non trouve
		return
FoundValueEeprom
		movlw HIGH Get_List_Idx_Set3
	        movwf PCLATH
		btfsc Info_Boot,7
			bsf PCLATH,4; page 2-3 (0x1000 - 0x1FFF)
		movf Counter,W; index jeu 3
		call Get_List_Idx_Set3
		movwf Value; sauvegarder le resultat dans Value
		return

;-----------------------------------------------------------------------------
;   Transmit byte in W register from USART
;
; Entree: W = donnee binaire
; Sortie: Rien
;
; Global: TEMP4, TEMP5, TEMP6, DEB_INDEX_EM, FIN_INDEX_EM, TAMPON_EM utilises
;-----------------------------------------------------------------------------
		
SerialTransmit
		btfss Flags,IKBD_ENABLE
			return
		movwf TEMP4
		IF LCD
		IF LCD_DEBUG
		bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)	
		call Send_Debug_Hexa_Lcd
		bcf PCLATH,3; page 0 ou 2
		ENDIF
		ENDIF
		movf FIN_INDEX_EM,W 
		btfss PIR1,TXIF; check that buffer is empty 
			goto TxReg_Full
		subwf DEB_INDEX_EM,W
		btfss STATUS,Z
			goto TxReg_Full; FIN_INDEX_EM <> DEB_INDEX_EM => caractere encore present dans le buffer circulaire
		movf TEMP4,W
		movwf TXREG; transmit byte
		bcf Flags2,DATATOSEND; flag rien a envoyer dans la boucle principale Main
		return
TxReg_Full
		movf STATUS,W
		movwf TEMP6; sauve IRP
		movf FSR,W
		movwf TEMP5; sauve FSR
		bsf STATUS,IRP; page 3
		incf FIN_INDEX_EM,W; incremente index buffer cirulaire donnees a envoyer
		movwf FSR; pointeur index
		movlw TAILLE_TAMPON_EM
		subwf FSR,W
		btfsc STATUS,C
			clrf FSR; buffer circulaire
		movf DEB_INDEX_EM,W
		subwf FSR,W
		btfsc STATUS,Z
			goto End_SerialTransmit; tampon plein
		movf FSR,W
		movwf FIN_INDEX_EM
		movlw LOW TAMPON_EM
		addwf FSR,F; pointeur index
		movf TEMP4,W
		movwf INDF; ecriture dans le tampon
		bsf Flags2,DATATOSEND; flag donnees a envoyer dans la boucle prinipale Main
End_SerialTransmit
		movf TEMP5,W
		movwf FSR; restitue FSR
		movf TEMP6,W
		movwf STATUS; restitue IRP
		return	
		
;-----------------------------------------------------------------------------
;               Increment horloge
;              
;               SEC, MIN, HRS, DAY, MONTH, YEAR sont dans une zone en page 2
;               non reinitialisee au Reset.
;               La fonction ne tient pas compte des annees bissextiles. 
;-----------------------------------------------------------------------------

Inc_Clock
		bsf STATUS,RP1; page 2
		incf SEC,F; seconde suivante
		movf SEC,W
		call Conv_Bcd_Value
		movwf SEC_BCD
		movlw 60
		subwf SEC,W
		btfss STATUS,C
			goto End_Inc_Clock
		clrf SEC
		clrf SEC_BCD
		incf MIN,F; minute suivante
		movf MIN,W
		call Conv_Bcd_Value
		movwf MIN_BCD
		movlw 60
		subwf MIN,W
		btfss STATUS,C
			goto End_Inc_Clock
		clrf MIN
		clrf MIN_BCD
		incf HRS,F; heure suivante
		movf HRS,W
		call Conv_Bcd_Value
		movwf HRS_BCD
		movlw 24
		subwf HRS,W
		btfss STATUS,C
			goto End_Inc_Clock
		clrf HRS
		clrf HRS_BCD
		incf DAY,F; jour suivant
		movf DAY,W
		call Conv_Bcd_Value
		movwf DAY_BCD
		bcf STATUS,RP1; page 0
		movlw HIGH Days_In_Month
	        movwf PCLATH
		btfsc Info_Boot,7
			bsf PCLATH,4; page 2-3 (0x1000 - 0x1FFF)
		bsf STATUS,RP1; page 2
		movf MONTH,W
		andlw 0x0F
		call Days_In_Month; nombre de jours dans le mois
		subwf DAY,W
		btfss STATUS,C
			goto End_Inc_Clock
		movlw 1
		movwf DAY
		movwf DAY_BCD
		incf MONTH,F; mois suivant
		movf MONTH,W
		call Conv_Bcd_Value
		movwf MONTH_BCD
		movlw 13
		subwf MONTH,W
		btfss STATUS,C
			goto End_Inc_Clock
		movlw 1
		movwf MONTH
		movwf MONTH_BCD
		incf YEAR,F; annes suivante
		movf YEAR,W
		call Conv_Bcd_Value
		movwf YEAR_BCD
		movlw 100
		subwf YEAR,W
		btfss STATUS,C
			goto End_Inc_Clock
		clrf YEAR
		clrf YEAR_BCD
End_Inc_Clock
		bcf STATUS,RP1; page 0
		return

;------------------------------------------------------------------------
; Conversion d'une valeur en BCD
;
; Entree: W
; Sortie: W
;
; Global: TEMP1, TEMP2 sont utilises
;------------------------------------------------------------------------
		
Conv_Bcd_Value
		movwf TEMP1;poids faible BCD
		clrf TEMP2; poids fort BCD
Loop_Bcd
			movlw 10
			subwf TEMP1,W
			btfss STATUS,C
				goto Exit_Bcd
			movwf TEMP1; poids faible BCD
			incf TEMP2,F; poids fort BCD
		goto Loop_Bcd
Exit_Bcd
		swapf TEMP2,W
		andlw 0xF0; 4 bits de poids fort
		iorwf TEMP1,W
		return

;------------------------------------------------------------------------
; Conversion BCD en binaire de l'horloge
; YEAR_BCD, MONTH_BCD, DAY_BCD, HRS_BCD, MIN_BCD, et SEC_BCD en page 2
; => YEAR, MONTH, DAY, HRS, MIN, et SEC en page 2
;
; Global: TEMP1, Counter sont utilises
;------------------------------------------------------------------------

Conv_Inv_Bcd_Time
		movlw LOW YEAR
		movwf FSR
		bsf STATUS,IRP; page 2
		movlw 6
		movwf Counter
Loop_Bcd_Time
			movlw YEAR_BCD-YEAR
			addwf FSR,F
			movf INDF,W; valeur BCD
			movwf TEMP1
			movlw YEAR_BCD-YEAR
			subwf FSR,F
			clrw
			btfsc TEMP1,0
				addlw 1
			btfsc TEMP1,1
				addlw 2
			btfsc TEMP1,2
				addlw 4
			btfsc TEMP1,3
				addlw 8
			btfsc TEMP1,4
				addlw 10
			btfsc TEMP1,5
				addlw 20
			btfsc TEMP1,6
				addlw 40
			btfsc TEMP1,7
				addlw 80
			movwf INDF; valeur decimale
			incf FSR,F
			decfsz Counter,F	
		goto Loop_Bcd_Time
		return

;-----------------------------------------------------------------------------
;               Conversion inverse echelle souris en X mode absolu 
;               X_POS = X_POS_SCALED * X_SCALE
;-----------------------------------------------------------------------------

Conv_Inv_Scale_X
		clrf X_POSL; X_POS = X_POS_SCALED * X_SCALE
		clrf X_POSH
		movf X_SCALE,W
		movwf Counter
Loop_Inv_Scale_X
			movf X_POSL_SCALED,W; position X absolue souris avec facteur d'echelle poids faible
			addwf X_POSL,F
			movf X_POSH_SCALED,W; position X absolue souris avec facteur d'echelle poids fort
			btfsc STATUS,C
				incfsz X_POSH_SCALED,W
			addwf X_POSH,F
			decfsz Counter,F
		goto Loop_Inv_Scale_X
		return	

;-----------------------------------------------------------------------------
;               Conversion inverse echelle souris en Y mode absolu
;               Y_POS = Y_POS_SCALED * Y_SCALE  
;-----------------------------------------------------------------------------

Conv_Inv_Scale_Y
		clrf Y_POSL; Y_POS = Y_POS_SCALED * Y_SCALE
		clrf Y_POSH
		movf Y_SCALE,W
		movwf Counter
Loop_Inv_Scale_Y
			movf Y_POSL_SCALED,W; position Y absolue souris avec facteur d'echelle poids faible
			addwf Y_POSL,F
			movf Y_POSH_SCALED,W; position Y absolue souris avec facteur d'echelle poids fort
			btfsc STATUS,C
				incfsz Y_POSH_SCALED,W
			addwf Y_POSH,F
			decfsz Counter,F
		goto Loop_Inv_Scale_Y
		return		

;-----------------------------------------------------------------------------
;               Conversion echelle souris en X mode absolu
;               X_POS = X_POS_SCALED / X_SCALE
;-----------------------------------------------------------------------------
		
Conv_Scale_X
		movf X_POSL,W
		movwf Counter2
		movf X_POSH,W
		movwf Counter3
		movf X_SCALE,W
		call Div_1608; X_POS = X_POS_SCALED / X_SCALE
		movf Counter2,W
		movwf X_POSL_SCALED; position X absolue souris avec facteur d'echelle poids faible
		movf Counter3,W
		movwf X_POSH_SCALED; position X absolue souris avec facteur d'echelle poids fort
		return
		
;-----------------------------------------------------------------------------
;               Conversion echelle souris en Y mode absolu
;               Y_POS = Y_POS_SCALED / Y_SCALE
;-----------------------------------------------------------------------------

Conv_Scale_Y
		movf Y_POSL,W
		movwf Counter2
		movf Y_POSH,W
		movwf Counter3
		movf Y_SCALE,W
		call Div_1608; Y_POS = Y_POS_SCALED / Y_SCALE
		movf Counter2,W
		movwf Y_POSL_SCALED; position Y absolue souris avec facteur d'echelle poids faible
		movf Counter3,W
		movwf Y_POSH_SCALED; position Y absolue souris avec facteur d'echelle poids fort
		return

;-----------------------------------------------------------------------------
;   KEYBOARD: Routine de lecture d'un octet du port DIN5 et MiniDIN6
;
;   Entree: Rien
;   Sortie: W = 1 si octet recu sinon 0
;           VAR Value = octet recu
;-----------------------------------------------------------------------------

_KPSGet2
		clrf PARITY; used for parity calc
		call KPSGetBit; get start bit (for nothing)
		clrf Value; clear value
		movlw 8; 8 bits
		movwf Counter; set counter to 8 bits to read
KGetLoop
			rrf Value,F; rotate to right to get a shift
			bcf Value,7; force MSB to zero to disable Carry state used
			call KPSGetBit; get a bit from keyboard
			iorwf Value,F; logical OR with previous value
			xorwf PARITY,F; parity calc
			decfsz Counter,F; check if we should get another one
		goto KGetLoop
		call KPSGetBit; get parity bit
		xorwf PARITY,F
		call KPSGetBit; get stop bit
		iorlw 0
		btfsc STATUS,Z
			clrf PARITY; stop bit = 0 => erreur
		btfss PARITY,7
			clrf Value; erreur
		return
		
;-----------------------------------------------------------------------------
;This routine sends a byte in w to a PS/2 mouse or keyboard.  TEMP1, TEMP2,
;and PARITY are general purpose registers.  CLOCK and DATA are assigned to
;port bits, and "Delay" is a self-explainatory macro.  DATA and CLOCK are
;held high by setting their I/O pin to input and allowing an external pullup
;resistor to pull the line high.  The lines are brought low by setting the
;I/O pin to output and writing a "0" to the pin.
;-----------------------------------------------------------------------------

_KPS2cmd
		movwf TEMP1; store to-be-sent byte
		IF !NON_BLOQUANT
		movlw 8; 8 bits
		movwf Counter; initialize a counter		
		ENDIF
		clrf PARITY; used for parity calc
		bsf STATUS,RP0; page 1
		bcf TRISB,KCLOCK; en sortie
		bcf STATUS,RP0; page 0
		bcf PORTB,KCLOCK; inhibit communication
		Delay 100; for at least 100 microseconds
		bsf STATUS,RP0; page 1
		bcf TRISB,KDATA; en sortie
		bcf STATUS,RP0; page 0
		bcf PORTB,KDATA; valide l'ecriture, pull DATA low
		Delay 5
		bsf STATUS,RP0; page 1
		bsf TRISB,KCLOCK; en entree, release CLOCK
		bcf STATUS,RP0; page 0
		IF NON_BLOQUANT
		call Wait_Kclock; utilise Counter
		movf Counter,W
		btfsc STATUS,Z
			return; time-out
		movlw 8; 8 bits
		movwf Counter; initialize a counter
		ENDIF
KPS2cmdLoop
			movf TEMP1,W
			xorwf PARITY,F; parity calc
			call KPS2cmdBit; output 8 data bits
			rrf TEMP1,F
			decfsz Counter,F
		goto KPS2cmdLoop
		comf PARITY,W
		call KPS2cmdBit; output parity bit
		movlw 1
		call KPS2cmdBit; output stop bit (1)
		WAIT_KCLOCK_L; attente front descendant de CLK
		WAIT_KCLOCK_H; attente front montant de CLK (ACK)
		return

;-----------------------------------------------------------------------------
;   Routine de lecture d'un octet sur le port SOURIS. Elle ATTEND qu'un paquet
;   soit disponible.
;
;   Entree: Rien
;   Sortie: W = 1 si octet recu sinon 0
;           VAR Value = octet recu
;-----------------------------------------------------------------------------

_MPSGet2
		clrf PARITY; used for parity calc
		call MPSGetBit; get start bit (for nothing)
		clrf Value; clear value
		movlw 8; 8 bits
		movwf Counter; set counter to 8 bits to read
MGetLoop
			rrf Value,F; rotate to right to get a shift
			bcf Value,7; force MSB to zero to disable Carry state used
			call MPSGetBit; get a bit from mouse
			iorwf Value,F; logical OR with previous value
			xorwf PARITY,F; parity calc
			decfsz Counter,F; check if we should get another one
		goto MGetLoop
		call MPSGetBit; get parity bit
		xorwf PARITY,F
		call MPSGetBit; get stop bit
		iorlw 0
		btfsc STATUS,Z
			clrf PARITY; stop bit = 0 => erreur
		btfss PARITY,7
			clrf Value; erreur
		return

;-----------------------------------------------------------------------------
;This routine sends a byte in w to a PS/2 mouse
;-----------------------------------------------------------------------------
		
_MPS2cmd
		movwf TEMP1; store to-be-sent byte
		IF !NON_BLOQUANT
		movlw 8; 8 bits
		movwf Counter; initialize a counter		
		ENDIF
		clrf PARITY; used for parity calc
		bsf STATUS,RP0; page 1
		bcf TRISB,MCLOCK; en sortie
		bcf STATUS,RP0; page 0
		bcf PORTB,MCLOCK; inhibit communication
		Delay 100; for at least 100 microseconds
		bsf STATUS,RP0; page 1
		bcf TRISB,MDATA; en sortie
		bcf STATUS,RP0; page 0
		bcf PORTB,MDATA; valide l'ecriture, pull DATA low
		Delay 5
		bsf STATUS,RP0; page 1
		bsf TRISB,MCLOCK; en entree, release CLOCK
		bcf STATUS,RP0; page 0
		IF NON_BLOQUANT
		call Wait_Mclock; utilise Counter
		movf Counter,W
		btfsc STATUS,Z
			return; time-out
		movlw 8; 8 bits
		movwf Counter; initialize a counter
		ENDIF
MPS2cmdLoop
			movf TEMP1,W
			xorwf PARITY,F; Parity calc
			call MPS2cmdBit; Output 8 data bits
			rrf TEMP1,F
			decfsz Counter,F
		goto MPS2cmdLoop
		comf PARITY,W
		call MPS2cmdBit; output parity bit
		movlw 1
		call MPS2cmdBit; output stop bit (1)
		WAIT_MCLOCK_L; attente front descendant de CLK
		WAIT_MCLOCK_H; attente front montant de CLK (ACK)
		return

;-----------------------------------------------------------------------------
; Init message utilisateur de 8 caracteres pour l'afficheur LCD
;
; Entree: Rien
; Sortie: Rien
;
; Global: Counter2
;-----------------------------------------------------------------------------	

		IF LCD
		IF !LCD_DEBUG		
Init_Message_User_Lcd
		call Init_Message_User_Ptr
Loop_Init_Message_Lcd
			movlw ' '
			bsf STATUS,IRP; page 2
			movwf INDF
			incf FSR,F
			decfsz Counter2,F
		goto Loop_Init_Message_Lcd
		return
		ENDIF
		ENDIF
		
;-----------------------------------------------------------------------------
; Envoi d'un message utilisateur de 8 caracteres sur l'afficheur LCD
;
; Entree: Rien
; Sortie: Rien
;
; Global: Counter, Counter2, TEMP1, TEMP2
;-----------------------------------------------------------------------------	

		IF LCD
		IF !LCD_DEBUG		
Message_User_Lcd
		movlw 0xC6; ligne 2, colonne 7
		call SendINS
		call Init_Message_User_Ptr
Loop_Message_Lcd
			bsf STATUS,IRP; page 2
			movf INDF,W
			call SendCHAR
			incf FSR,F
			decfsz Counter2,F
		goto Loop_Message_Lcd
		return
		ENDIF
		ENDIF

;------------------------------------------------------------------------
;   Correspondance pour convertir en hexa le contenu du registre
;   W et l'envoyer vers la laison serie ou l'afficheur LCD
;
;   Entree: W = Quartet a convertir (LSB)
;   sortie: W = Code ASCII
;
;   Global: TEMP1
;------------------------------------------------------------------------
		
Conv_Hexa
		movwf TEMP1
		movlw 10
		subwf TEMP1,W
		btfsc STATUS,C
			addlw 7; A a F
		addlw '0'+10
		return
		
;-----------------------------------------------------------------------------
; Lecture EEPROM
;-----------------------------------------------------------------------------

Lecture_EEProm2
		RDEEPROM
		return
		
;-----------------------------------------------------------------------------
	
		ORG   0xD00

;-----------------------------------------------------------------------------
; Modifier CTTRL, ALT, SHIFT table utilisateur
;-----------------------------------------------------------------------------	
		
Get_Modifier
		addwf PCL,F
		FILL 0x3400,MAX_VALUE_LOOKUP+1; retlw 0x00

;-----------------------------------------------------------------------------
; PS2 Keyboard subroutines
;-----------------------------------------------------------------------------	

KPSGetBit
		clrw
		WAIT_KCLOCK_L; attente front descendant de CLK
		btfsc PORTB,KDATA
			movlw BIT_UN
		WAIT_KCLOCK_H; attente front montant de CLK	
		return

KPS2cmdBit
		WAIT_KCLOCK_L; attente front descendant de CLK
		bsf STATUS,RP0; page 1
		andlw 1
		btfss STATUS,Z ; Set/Reset DATA line
			bsf TRISB,KDATA; en entree
		btfsc STATUS,Z
			bcf TRISB,KDATA; en sortie
		bcf STATUS,RP0; page 0
		WAIT_KCLOCK_H; attente front montant de CLK
		return

		IF NON_BLOQUANT
Wait_Kclock
		movlw 16
		movwf Counter; time-out
		clrf Counter2
		clrf Counter3
WCK
					btfss PORTB,KCLOCK; attente front descendant de CLK
						return
					decfsz Counter3,F
				goto WCK
				decfsz Counter2,F
			goto WCK
			decfsz Counter,F
		goto WCK
		return
		ENDIF

;-----------------------------------------------------------------------------
; PS2 Mouse subroutines
;-----------------------------------------------------------------------------	

MPSGetBit
		clrw
		WAIT_MCLOCK_L; attente front descendant de CLK
		btfsc PORTB,MDATA
			movlw BIT_UN
		WAIT_MCLOCK_H; attente front montant de CLK
		return

MPS2cmdBit
		WAIT_MCLOCK_L; attente front descendant de CLK
		bsf STATUS,RP0; page 1
		andlw 1
		btfss STATUS,Z; Set/Reset DATA line
			bsf TRISB,MDATA; en entree
		btfsc STATUS,Z
			bcf TRISB,MDATA; en sortie
		bcf STATUS,RP0; page 0
		WAIT_MCLOCK_H; attente front montant de CLK
		return

		IF NON_BLOQUANT
Wait_Mclock
		movlw 16
		movwf Counter; time-out
		clrf Counter2
		clrf Counter3
WCM
					btfss PORTB,MCLOCK; attente front descendant de CLK
						return
					decfsz Counter3,F
				goto WCM
				decfsz Counter2,F
			goto WCM
			decfsz Counter,F
		goto WCM
		return
		ENDIF

;------------------------------------------------------------------------
; Envoi le contenu de W en hexa sur la liaison serie
; C'est a dire: W = 0x41 => Emission de l'ASCII '4' puis ASCII '1'
;
; Entree: W = valeur
; Sortie: Rien
;
; Global: TEMP3
;------------------------------------------------------------------------
		IF SERIAL_DEBUG
SendHexa
		movwf TEMP3; sauver la valeur a traiter
                ; Just to have 0x printed on screen
		movlw '$'
		call SerialTransmit; envoyer l'octet vers le Host
		swapf TEMP3,W
		andlw 0x0F; 4 bits de poids fort
		call Conv_Hexa; chercher le code ASCII
		call SerialTransmit
		movf TEMP3,W
		andlw 0x0F; 4 bits de poids faible
		call Conv_Hexa; chercher le code ASCII
		goto SerialTransmit
		ENDIF
		
;------------------------------------------------------------------------
; Envoi le contenu de W en hexa vers l'afficheur LCD
; C'est a dire: W = 0x41 => Emission de l'ASCII '4' puis ASCII '1'
;
; Entree: W = valeur
; Sortie: Rien
;
; Global: Counter, TEMP1, TEMP2, TEMP3
;------------------------------------------------------------------------
		IF LCD
Send_Hexa_Lcd
		movwf TEMP3; sauver la valeur a traiter
		swapf TEMP3,W
		andlw 0x0F; 4 bits de poids fort
		call Conv_Hexa; chercher le code ASCII
		call SendCHAR
		movf TEMP3,W
		andlw 0x0F; 4 bits de poids faible
		call Conv_Hexa; chercher le code ASCII
		goto SendCHAR
		ENDIF
		
;-----------------------------------------------------------------------------
; Init variables pour message utilisateur de 8 caracteres sur l'afficheur LCD
;
; Entree: Rien
; Sortie: Rien
;
; Global: Counter2
;-----------------------------------------------------------------------------	

		IF LCD
		IF !LCD_DEBUG		
Init_Message_User_Ptr
		movlw LOW USER_LCD
		movwf FSR
		movlw 8
		movwf Counter2
		return
		ENDIF
		ENDIF
		
;-----------------------------------------------------------------------------
		
		ORG   0xE00

;-----------------------------------------------------------------------------
; Shift table utilisateur
;-----------------------------------------------------------------------------	
		
Get_Scan_Codes_Shift
		addwf PCL,F
		FILL 0x3400,MAX_VALUE_LOOKUP+1; retlw 0x00

;-----------------------------------------------------------------------------
;   Test changement d'etat touches Shifts, Alt & AltGr du set 3 
;
; Entree: Value = donnee binaire
; Sortie: Rien
;
; Global: Flags2, Flags3
;-----------------------------------------------------------------------------

Test_Shift_Alt_AltGr
		movf Value,W
		sublw 0x59; RIGHT SHIFT code set 3
		btfsc STATUS,Z
			goto Test_Shift
		movf Value,W
		sublw 0x12; LEFT SHIFT code set 3
		btfss STATUS,Z
			goto No_Shift
Test_Shift
		bcf Flags3,SHIFT_PS2; relachement Shift droit
		btfsc Flags2,BREAK_CODE
			return
		bsf Flags3,SHIFT_PS2
		bsf Flags5,SHIFT_PS2_BREAK
		return
No_Shift         
		movf Value,W
		sublw 0x19; ALT code set 3
		btfss STATUS,Z
			goto No_Alt
		bcf Flags3,ALT_PS2; relachement Alt
		btfss Flags2,BREAK_CODE
			bsf Flags3,ALT_PS2
		return
No_Alt
		movf Value,W
		sublw 0x39; ALT GR code set 3
		btfss STATUS,Z
			goto No_AltGr
		bcf Flags3,ALTGR_PS2; relachement AltGr
		btfsc Flags2,BREAK_CODE
			return
		bsf Flags3,ALTGR_PS2
		bsf Flags5,ALTGR_PS2_BREAK
		return
No_AltGr
		btfsc Flags2,BREAK_CODE
			return; relachement
		btfss Flags3,ALTGR_PS2 		
			bcf Flags5,ALTGR_PS2_BREAK; si la touche AltGr est relachee
		btfss Flags3,SHIFT_PS2 		
			bcf Flags5,SHIFT_PS2_BREAK; si la touche Shift est relachee
		return

;-----------------------------------------------------------------------------
;  Test changement d'etat touches SHIFT, ALT & CTRL envoyes a l'unite centrale 
;
; Entree: Value = donnee binaire
; Sortie: Rien
;
; Global: Flags2, Flags4
;-----------------------------------------------------------------------------

Test_Shift_Alt_Ctrl_Host
		movf Value,W
		sublw 0x1D; CTRL
		btfss STATUS,Z
			goto No_CtrlHost
		bcf Flags4,CTRL_HOST; relachement CTRL		
		btfss Flags2,BREAK_CODE
			bsf Flags4,CTRL_HOST
		return
No_CtrlHost
		movf Value,W
		sublw 0x36; RIGHT SHIFT
		btfss STATUS,Z
			goto No_RightShiftHost
		bcf Flags4,RIGHT_SHIFT_HOST; relachement SHIFT droit
		btfss Flags2,BREAK_CODE
			bsf Flags4,RIGHT_SHIFT_HOST
		return
No_RightShiftHost	
		movf Value,W
		sublw 0x2A; LEFT SHIFT
		btfss STATUS,Z
			goto No_LeftShiftHost
		bcf Flags4,LEFT_SHIFT_HOST; relachement SHIFT gauche
		btfss Flags2,BREAK_CODE
			bsf Flags4,LEFT_SHIFT_HOST
		return
No_LeftShiftHost         
		movf Value,W
		sublw 0x38; ALT
		btfss STATUS,Z
			return
		bcf Flags4,ALT_HOST; relachement ALT
		btfss Flags2,BREAK_CODE
			bsf Flags4,ALT_HOST
		return
		
;-----------------------------------------------------------------------------
; Envoi de la chaine de bienvenue sur la RS232
;
; Entree: Rien
; Sortie: Rien
;
; Global: Counter, TEMP4, TEMP5, TEMP6, DEB_INDEX_EM, FIN_INDEX_EM, TAMPON_EM
;-----------------------------------------------------------------------------

		IF SERIAL_DEBUG
SerialWelcome
		clrf Counter
		movlw HIGH WelcomeText
		movwf PCLATH
		btfsc Info_Boot,7
			bsf PCLATH,4; page 2-3 (0x1000 - 0x1FFF)
Loop_SerialWelcome
			movf Counter,W
			call WelcomeText
			bsf PCLATH,3; page 1 ou 3 (0x800 - 0xFFF)
			iorlw 0
			btfsc STATUS,Z
				return         
			call SerialTransmit
			incf Counter,F
		goto Loop_SerialWelcome
		ENDIF
		
;-----------------------------------------------------------------------------
; Envoi de l'heure sur l'afficheur LCD
;
; Entree: Rien
; Sortie: Rien
;
; Global: Counter, Counter2, TEMP1, TEMP2, TEMP3
;-----------------------------------------------------------------------------

		IF LCD
		IF !LCD_DEBUG
Time_Lcd
		btfss Flags4,LCD_ENABLE; gestion timer LCD inhibe
			return
		movlw 0x80; ligne 1, colonne 1
		call SendINS
		movlw LOW MONTH_BCD
		movwf FSR
		movlw 4
		movwf Counter2
		call Send_Indf_Hexa_Lcd
		movlw '/'
		goto Separator_Time
Loop_Time_Lcd
			call Send_Indf_Hexa_Lcd
			movf Counter2,W
			sublw 2
			movlw ' '
			btfss STATUS,Z
				goto Separator_Time
			bsf STATUS,RP1; page 2
			btfss SEC_BCD,0
				goto Separator_Time
			movlw ':'
Separator_Time
			bcf STATUS,RP1; page 0
			call SendCHAR; separateur
			incf FSR,F
			decfsz Counter2,F	
		goto Loop_Time_Lcd
Send_Indf_Hexa_Lcd
		bsf STATUS,IRP; page 2
		movf INDF,W; valeur BCD
		goto Send_Hexa_Lcd
		ENDIF
		ENDIF	

;-----------------------------------------------------------------------------
; Envoi de Value en hexa sur l'afficheur LCD
;
; Entree: W = position LCD + 0x80
; Sortie: Rien
;
; Global: Counter, Counter2, TEMP1, TEMP2, TEMP3
;-----------------------------------------------------------------------------
		IF LCD
		IF !LCD_DEBUG		
Send_Value_Lcd
		btfsc Flags2,BREAK_CODE
			goto Clear_Hex_Lcd
		call SendINS
		movf Value,W
		goto Send_Hexa_Lcd
Clear_Hex_Lcd
		movlw 0x8E; ligne 1, colonne 15
		call Spaces_Lcd
		movlw 0xCE; ligne 2, colonne 15
		goto Spaces_Lcd
		ENDIF
		ENDIF

;------------------------------------------------------------------------
; Envoi valeur dans W en hexa sur tout l'afficheur LCD
;
; Entree: W = valeur
; Sortie: Rien
;
; Global: Counter2, TEMP2, TEMP3, TEMP4, TEMP5, TEMP6
;-----------------------------------------------------------------------------

		IF LCD
		IF LCD_DEBUG
Send_Debug_Hexa_Lcd
		movwf TEMP4; sauve valeur
		movf Counter,W
		movwf TEMP5
		movf TEMP1,W
		movwf TEMP6
		call Cursor_Debug_Lcd
		movf TEMP4,W
		call Send_Hexa_Lcd
		incf Counter_Debug_Lcd,F
		movlw 15
		andwf Counter_Debug_Lcd,F
		call Cursor_Debug_Lcd
		movlw ' '
		call SendCHAR
		movlw ' '
		call SendCHAR
		movf TEMP5,W
		movwf Counter 
		movf TEMP6,W
		movwf TEMP1
		return
		
Cursor_Debug_Lcd
                movf Counter_Debug_Lcd,W
		addwf Counter_Debug_Lcd,W
		btfsc Counter_Debug_Lcd,3
			goto Debug_Ligne2_Lcd; => 2eme ligne
		addlw 0x80; ligne 1, colonne 1
		goto Debug_Ligne_Lcd
Debug_Ligne2_Lcd
		andlw 15
		addlw 0xC0; ligne 2, colonne 1
Debug_Ligne_Lcd
		goto SendINS
		ENDIF
		ENDIF

;-----------------------------------------------------------------------------			
				
		ORG   0xF00
		
;-----------------------------------------------------------------------------
; AltGr table utilisateur
;-----------------------------------------------------------------------------	
		
Get_Scan_Codes_AltGr
		addwf PCL,F
		FILL 0x3400,MAX_VALUE_LOOKUP+1; retlw 0x00
	
;-----------------------------------------------------------------------------
; Envoi de la temperature sur l'afficheur LCD
;
; Entree: Rien
; Sortie: Rien
;
; Global: Counter, TEMP1, TEMP2, TEMP3, TEMP4
;-----------------------------------------------------------------------------

		IF LCD
		IF !LCD_DEBUG
Temperature_Lcd
		btfss Flags4,LCD_ENABLE; gestion timer LCD inhibe
			return
		movlw 0xC0; ligne 2, colonne 1
		call SendINS
		movf Temperature,W
		movwf TEMP4
		movlw '0'
		movwf TEMP3
Lcd_Dec10
			movlw 10
			subwf TEMP4,W
			btfss STATUS,C
				goto Lcd_Dec1
			movwf TEMP4
			incf TEMP3,F
		goto Lcd_Dec10
Lcd_Dec1
		movf TEMP3,W
		call SendCHAR
		movlw '0'
		addwf TEMP4,W
		call SendCHAR
		movlw 0xDF
		call SendCHAR
		movlw 'C'
		call SendCHAR
		movlw ' '
		call SendCHAR
		movlw '-'
		btfsc PORTC,MOTORON
			movlw '+'
		goto SendCHAR
		ENDIF
		ENDIF

;-----------------------------------------------------------------------------
; Envoi 2 espaces sur l'afficheur LCD
;
; Entree: W = position LCD + 0x80
; Sortie: Rien
;
; Global: Counter, TEMP1, TEMP2
;-----------------------------------------------------------------------------			

		IF LCD
		IF !LCD_DEBUG		
Spaces_Lcd
		call SendINS
		movlw ' '
		call SendCHAR
		movlw ' '
		goto SendCHAR
		ENDIF
		ENDIF
		
;------------------------------------------------------------------------
;   Initialisation de l'afficheur LCD
;
;   Entree: Rien
;   Sortie: Rien
;
;   Global: Counter, TEMP1, TEMP2
;------------------------------------------------------------------------

		IF LCD
Init_Lcd
		Delay_Ms 200; attente 20 mS avant reset afficheur LCD
		bcf STATUS,C; efface Carry (Instruction Out)
		movlw 0x03; commande Reset
		call NybbleOut; Send Nybble
		Delay_Ms 50; attente 5 mS avant d'envoyer la suite
		EStrobe
		Delay 160; attente 160 uS
		EStrobe
		Delay 160; attente 160 uS
		bcf STATUS,C              
		movlw 0x02; mode 4 bits
		call NybbleOut              
		Delay 160
		movlw 0x28; 2 lignes d'affichages
		call SendINS
		movlw 0x08; coupe l'afficheur
		call SendINS
		movlw 0x01; efface l'affichage
		call SendINS
		Delay_Ms 50; 4.1 mS maxi
		movlw 0x06; autorisation deplacement curseur
		call SendINS
		movlw 0x0C; LCD Back On
		goto SendINS
		
;------------------------------------------------------------------------
;   Envoi d'un caractere vers le LCD
;
;   Entree: W = Caractere
;   Sortie: Rien
;
;   Global: Counter, TEMP1, TEMP2
;------------------------------------------------------------------------

SendCHAR
		movwf TEMP1; save la valeur
		swapf TEMP1,W; envoi les 4 bits de poids fort
		bsf STATUS,C; RS = 1
		call NybbleOut
		movf TEMP1,W; envoi les 4 bits de poids faible
		bsf STATUS,C
		goto NybbleOut

;------------------------------------------------------------------------
;   Envoi d'une instruction vers le LCD
;
;   Entree: W = Code
;   Sortie: Rien
;
;   Global: Counter, TEMP1, TEMP2
;------------------------------------------------------------------------

SendINS
		movwf TEMP1; sauve la valeur
		swapf TEMP1,W; envoi les 4 bits de poids fort
		bcf STATUS,C; RS = 0
		call NybbleOut
		movf TEMP1,W; envoi les 4 bits de poids faible
		bcf STATUS,C
		
;------------------------------------------------------------------------
;   Envoi de 4 bits vers le LCD
;   utilisation d'un registre a decalage externe 74LS174 ou
;   1Q = D4, 2Q = D5, 3Q = D6, 4Q = D7, 5Q = RS, 6Q = E
;
;   Entree: W = Valeur, C = RS
;   Sortie: Rien
;
;   Global: Counter, TEMP2
;------------------------------------------------------------------------

NybbleOut
		movwf TEMP2 ; sauve les 4 bits a envoyer
		swapf TEMP2 ; place les 4 bits a gauche
		movlw 6	; efface le registre a decalage (74LS714)
		movwf Counter
NOLoop1
			ClockStrobe
			decfsz Counter
		goto NOLoop1
		bsf PORTB,LCD_DATA; positionne Gate E Bit a 1
		ClockStrobe
		bcf PORTB,LCD_DATA; positionne RS Bit a 0
		btfsc STATUS,C
			bsf PORTB,LCD_DATA; RS a 1
		ClockStrobe
		movlw 4; envoi les bits Data
		movwf Counter
NOLoop2
			rlf TEMP2; decalage des 4 bits a envoyer
			bcf PORTB,LCD_DATA; efface le bit data
			btfsc STATUS,C
				bsf PORTB,LCD_DATA; bit data a 1
			ClockStrobe
			decfsz Counter
		goto NOLoop2
		EStrobe; Strobe LCD Data
		return
		
		ENDIF
		
;-----------------------------------------------------------------------------

		ORG   0xFFF
Banks_2_3_OK
		DW    0x3FFF; banks 2 & 3 invalides
		
		ORG   0x800

;-----------------------------------------------------------------------------
; Programme de boot en page 0 ou 2 et de telechargement en Flash
;-----------------------------------------------------------------------------

Start_Flash
		goto Start_Flash_2
		
Ecriture_Flash	
		IF LCD
		movlw 0x01; efface l'affichage
		call SendINS
		ENDIF
		movlw LOW Banks_2_3_OK
		movwf Counter2; adresse FLASH poids faible
		movlw HIGH Banks_2_3_OK
		movwf Counter; adresse FLASH poids fort
		movlw 0xFF
		movwf BUFFER_FLASH
		movlw 0x3F
		movwf BUFFER_FLASH+1
		movlw 'W'; validation
		call Write_Flash; ecriture 2 octet => programme mauvais (0x3FFF) en 0x0FFF	
		clrf Value; checkum
		clrf Counter2; adresse FLASH poids faible
		clrf Counter; adresse FLASH poids fort
		bsf Counter,4; pages 2-3 (0x1000 - 0x1FFF)		
Loop_Flash_1
				btfss PIR1,RCIF
					goto Loop_Flash_1
				movf RCREG,W
				andlw 0x3F
				movwf BUFFER_FLASH+1; poids fort
				addwf Value,F
Loop_Flash_2
				btfss PIR1,RCIF
					goto Loop_Flash_2
				movf RCREG,W
				movwf BUFFER_FLASH; poids faible
				addwf Value,F
				movlw 'W'; validation
				call Write_Flash; ecriture 2 octets
				btfss Counter2,2
					bcf PORTB,LEDGREEN; allume les deux LEDs
				btfss Counter2,2
					bcf PORTB,LEDYELLOW
				btfsc Counter2,2
					bsf PORTB,LEDGREEN; eteint les deux LEDs
				btfsc Counter2,2
					bsf PORTB,LEDYELLOW
				IF LCD	
				movf Counter,W
				movwf TEMP4; sauve Counter
				movlw 0x80; ligne 1, colonne 1
				call SendINS
				movf TEMP4,W; adresse FLASH poids fort
				call Send_Hexa_Lcd
				movf Counter2,W; adresse FLASH poids faible
				call Send_Hexa_Lcd
				movf TEMP4,W
				movwf Counter
				ENDIF
				incf Counter2,F
				btfss STATUS,Z
			goto Loop_Flash_1
			incf Counter,F
			btfss Counter,5
		goto Loop_Flash_1
Loop_Flash_3
		btfss PIR1,RCIF
			goto Loop_Flash_3
		movf RCREG,W; lecture checksum
		subwf Value,W; checksum octets en prevenance du port serie
		btfss STATUS,Z
			goto Fin_Prog_Flag; checksum mauvais				
		clrf PARITY; checkum
		clrf Counter2; adresse FLASH poids faible
		clrf Counter; adresse FLASH poids fort
		bsf Counter,4; pages 2-3 (0x1000 - 0x1FFF)
Loop_Flash_4                                               
				call Read_Flash; lecture 2 octets
				movf BUFFER_FLASH+1,W; poids fort
				addwf PARITY,F
				movf BUFFER_FLASH,W; poids faible
				addwf PARITY,F
				incf Counter2,F
				btfss STATUS,Z
			goto Loop_Flash_4
			incf Counter,F
			btfss Counter,5
		goto Loop_Flash_4
		movf PARITY,W; lecture checksum octets flash
		subwf Value,W
		btfss STATUS,Z
			goto Fin_Prog_Flag; checksum mauvais
		movlw LOW Banks_2_3_OK
		movwf Counter2; adresse FLASH poids faible
		movlw HIGH Banks_2_3_OK
		movwf Counter; adresse FLASH poids fort
		clrf BUFFER_FLASH
		clrf BUFFER_FLASH+1
		movlw 'W'; validation
		call Write_Flash; ecriture 2 octets => programme OK (0) en 0x0FFF
		IF LCD
		movlw ' '
		call SendCHAR
		movlw 'O'
		call SendCHAR
		movlw 'K'
		call SendCHAR
		ENDIF
Fin_Prog_Flag
		clrf PCLATH
		clrf STATUS
		goto Reset_Prog

Read_Flash
		READ_FLASH Counter,Counter2,BUFFER_FLASH
		return
		
Write_Flash
		sublw 'W'
		btfss STATUS,Z
			return
		WRITE_FLASH Counter,Counter2,BUFFER_FLASH
                return

Start_Flash_2
		clrf INTCON; interdit interruptions
		bsf STATUS,IRP; pages 2-3
		movlw 0xA0; page 3
		movwf FSR
Init_Page_3
			clrf INDF; initialisation RAM
			incf FSR,F
			btfsc FSR,7
		goto Init_Page_3
		movlw 0x20; page 2
		movwf FSR
Init_Page_2
			clrf INDF
			incf FSR,F
			btfss FSR,7
		goto Init_Page_2
		bcf STATUS,IRP; pages 0-1
		movlw 0xA0; page 1
		movwf FSR
Init_Page_1
			clrf INDF
			incf FSR,F
			btfsc FSR,7
		goto Init_Page_1
		movlw Status_Boot+1; page 0
		movwf FSR
Init_Page_0
			clrf INDF
			incf FSR,F
			btfss FSR,7
		goto Init_Page_0
		bsf STATUS,RP0; page 1
		bcf STATUS,RP1
		movlw 0xFF
		movwf TRISC; 8 entrees
		bcf STATUS,RP0; page 0
		clrf PCLATH
		clrf Info_Boot
		btfss PORTC,4; fire joystick 1
			goto Startup; force lancement programme en page page 0
		movlw LOW Banks_2_3_OK
		movwf Counter2; adresse FLASH poids faible
		movlw HIGH Banks_2_3_OK
		movwf Counter; adresse FLASH poids fort
		bsf PCLATH,3; page 1 (0x800 - 0xFFF)
		call Read_Flash; lecture 2 octets en 0x0FFF	
		bcf PCLATH,3; page 0
		movf BUFFER_FLASH,W
		iorwf BUFFER_FLASH+1,W
		btfss STATUS,Z
			goto Startup; lance programme en page page 0 si programme en page 2 invalide (0x1000 - 0x17FF)
		movlw 0xFF
		movwf Info_Boot
		bsf PCLATH,4; page 2 (0x1000 - 0x17FF)
		goto Startup; lance programme en page page 2 valide (0x1000 - 0x17FF)

;-----------------------------------------------------------------------------

		ORG   0x2100
EEProm

;-----------------------------------------------------------------------------
;               Zone EEPROM de stockage des Scan-Codes Souris
;               Ces codes sont la valeurs par defaut a renvoyer
;-----------------------------------------------------------------------------
Tab_Scan_Codes
		DE 0x00; offset + 0x00  jamais utilise: "Error or Buffer Overflow"
		DE 0x00; offset + 0x01  jamais utilise
		DE 0x00; offset + 0x02  jamais utilise
		DE 0x00; offset + 0x03  jamais utilise
		DE 0x00; offset + 0x04  jamais utilise
		DE 0x00; offset + 0x05  jamais utilise
		DE 0x00; offset + 0x06  jamais utilise
		DE 0x3B; offset + 0x07 F1
		DE 0x01; offset + 0x08 ESC
		DE 0x00; offset + 0x09  jamais utilise
		DE 0x00; offset + 0x0A  jamais utilise
		DE 0x00; offset + 0x0B  jamais utilise
		DE 0x00; offset + 0x0C  jamais utilise
		DE 0x0F; offset + 0x0D TABULATION
		DE DEF_RUSSE; offset + 0x0E <2> (`) ( a cote de 1 )
		DE 0x3C; offset + 0x0F F2
		DE 0x00; offset + 0x10  jamais utilise
		DE 0x1D; offset + 0x11 LEFT CTRL (Atari en n'a qu'un)
		DE 0x2A; offset + 0x12 LEFT SHIFT
		DE 0x60; offset + 0x13 ><
		DE 0x3A; offset + 0x14 CAPS
		DE 0x10; offset + 0x15 A (Q) 
		DE 0x02; offset + 0x16 1 
		DE 0x3D; offset + 0x17 F3
		DE 0x00; offset + 0x18  jamais utilise
		DE DEF_ALTGR; offset + 0x19 LEFT ALT (Atari en n'a qu'un)
		DE 0x2C; offset + 0x1A W (Z)
		DE 0x1F; offset + 0x1B S
		DE 0x1E; offset + 0x1C Q (A)
		DE 0x11; offset + 0x1D Z (W)
		DE 0x03; offset + 0x1E 2 
		DE 0x3E; offset + 0x1F F4
		DE 0x00; offset + 0x20  jamais utilise
		DE 0x2E; offset + 0x21 C
		DE 0x2D; offset + 0x22 X
		DE 0x20; offset + 0x23 D
		DE 0x12; offset + 0x24 E
		DE 0x05; offset + 0x25 4
		DE 0x04; offset + 0x26 3
		DE 0x3F; offset + 0x27 F5
		DE 0x00; offset + 0x28  jamais utilise
		DE 0x39; offset + 0x29 SPACE BAR
		DE 0x2F; offset + 0x2A V
		DE 0x21; offset + 0x2B F
		DE 0x14; offset + 0x2C T
		DE 0x13; offset + 0x2D R
		DE 0x06; offset + 0x2E 5 
		DE 0x40; offset + 0x2F F6
		DE 0x00; offset + 0x30  jamais utilise
		DE 0x31; offset + 0x31 N
		DE 0x30; offset + 0x32 B
		DE 0x23; offset + 0x33 H
		DE 0x22; offset + 0x34 G
		DE 0x15; offset + 0x35 Y
		DE 0x07; offset + 0x36 6 
		DE 0x41; offset + 0x37 F7
		DE 0x00; offset + 0x38  jamais utilise
		DE DEF_ALTGR; offset + 0x39 RIGHT ALT GR (Atari en n'a qu'un)
		DE 0x32; offset + 0x3A <,> (M)
		DE 0x24; offset + 0x3B J
		DE 0x16; offset + 0x3C U
		DE 0x08; offset + 0x3D 7
		DE 0x09; offset + 0x3E 8
		DE 0x42; offset + 0x3F F8
		DE 0x00; offset + 0x40  jamais utilise
		DE 0x33; offset + 0x41 <;> (,)
		DE 0x25; offset + 0x42 K
		DE 0x17; offset + 0x43 I
		DE 0x18; offset + 0x44 O (lettre O )
		DE 0x0B; offset + 0x45 0 (chiffre ZERO)
		DE 0x0A; offset + 0x46 9
		DE 0x43; offset + 0x47 F9
		DE 0x00; offset + 0x48  jamais utilise
		DE 0x34; offset + 0x49 <:> (.)
		DE 0x35; offset + 0x4A <!> (/)
		DE 0x26; offset + 0x4B L
		DE 0x27; offset + 0x4C M   (;)
		DE 0x19; offset + 0x4D P
		DE 0x0C; offset + 0x4E <)> (-)
		DE 0x44; offset + 0x4F F10
		DE 0x00; offset + 0x50  jamais utilise
		DE 0x00; offset + 0x51  jamais utilise
		DE 0x28; offset + 0x52 <—> (')
		DE 0x2B; offset + 0x53 <*> (\) touche sur COMPAQ
		DE 0x1A; offset + 0x54 <^> ([)
		DE 0x0D; offset + 0x55 <=> (=)
		DE 0x62; offset + 0x56 F11          <= HELP ATARI (Fr)
		DE DEF_PRINTSCREEN; offset + 0x57 PRINT SCREEN
		DE 0x1D; offset + 0x58 RIGHT CTRL   (Atari en n'a qu'un)
		DE 0x36; offset + 0x59 RIGHT SHIFT
		DE 0x1C; offset + 0x5A RETURN
		DE 0x1B; offset + 0x5B <$> (])
		DE 0x2B; offset + 0x5C <*> (\) touche sur SOFT KEY
		DE 0x00; offset + 0x5D  jamais utilise
		DE DEF_F12; offset + 0x5E F12          <= UNDO ATARI (Fr)
		DE DEF_SCROLL; offset + 0x5F SCROLL
		DE 0x50; offset + 0x60 DOWN ARROW
		DE 0x4B; offset + 0x61 LEFT ARROW
		DE DEF_PAUSE; offset + 0x62 PAUSE
		DE 0x48; offset + 0x63 UP ARROW
		DE 0x53; offset + 0x64 DELETE
		DE 0x55; offset + 0x65 END
		DE 0x0E; offset + 0x66 BACKSPACE
		DE 0x52; offset + 0x67 INSERT
		DE 0x00; offset + 0x68  jamais utilise
		DE 0x6D; offset + 0x69 KP 1
		DE 0x4D; offset + 0x6A RIGHT ARROW
		DE 0x6A; offset + 0x6B KP 4 )
		DE 0x67; offset + 0x6C KP 7 
		DE DEF_PAGEDN; offset + 0x6D PAGE DOWN    (unused on Atari before)
		DE 0x47; offset + 0x6E CLEAR HOME
		DE DEF_PAGEUP; offset + 0x6F PAGE UP      (unused on Atari before)
		DE 0x70; offset + 0x70 KP 0 (ZERO)
		DE 0x71; offset + 0x71 KP . 
		DE 0x6E; offset + 0x72 KP 2 
		DE 0x6B; offset + 0x73 KP 5 
		DE 0x6C; offset + 0x74 KP 6 
		DE 0x68; offset + 0x75 KP 8 )
		DE DEF_VERRNUM; offset + 0x76 VERR NUM     (unused on Atari before)
		DE 0x65; offset + 0x77 KP /
		DE 0x00; offset + 0x78  jamais utilise
		DE 0x72; offset + 0x79 KP ENTER
		DE 0x6F; offset + 0x7A KP 3 
		DE 0x00; offset + 0x7B  jamais utilise
		DE 0x4E; offset + 0x7C KP +
		DE 0x69; offset + 0x7D KP 9 
		DE 0x66; offset + 0x7E KP *
		DE DEF_SLEEP; offset + 0x7F SLEEP            Eiffel 1.0.5
		DE DEF_POWER; offset + 0x80  jamais utilise  Eiffel 1.0.8
		DE DEF_WAKE; offset + 0x81  jamais utilise   Eiffel 1.0.8
		DE 0x00; offset + 0x82  jamais utilise
		DE 0x00; offset + 0x83  jamais utilise
		DE 0x4A; offset + 0x84 KP -
		DE 0x00; offset + 0x85  jamais utilise
		DE 0x00; offset + 0x86  jamais utilise
		DE 0x00; offset + 0x87  jamais utilise
		DE 0x00; offset + 0x88  jamais utilise
		DE 0x00; offset + 0x89  jamais utilise
		DE 0x00; offset + 0x8A  jamais utilise
		DE DEF_WINLEFT;  offset + 0x8B LEFT WIN
		DE DEF_WINRIGHT; offset + 0x8C RIGHT WIN
		DE DEF_WINAPP;   offset + 0x8D POPUP WIN
		DE 0x00; offset + 0x8E  jamais utilise
		DE 0x00; offset + 0x8F  jamais utilise
;-----------------------------------------------------------------------------
Tab_Mouse
		DE DEF_WHEELUP; offset + 0x90 AT_WHEELUP     Eiffel 1.0.0
		DE DEF_WHEELDN; offset + 0x91 AT_WHEELDOWN   Eiffel 1.0.1 ( v1.0.0 retournait 0x60 )
		DE DEF_WHEELLT; offset + 0x92 AT_WHEELLEFT   Eiffel 1.0.3 seulement
		DE DEF_WHEELRT; offset + 0x93 AT_WHEELRIGHT  Eiffel 1.0.3 seulement
		DE DEF_BUTTON3; offset + 0x94 AT_BUTTON3     Eiffel 1.0.3 scan-code bouton 3 Central
		DE DEF_BUTTON4; offset + 0x95 AT_BUTTON4     Eiffel 1.0.3 scan-code bouton 4
		DE DEF_BUTTON5; offset + 0x96 AT_BUTTON5     Eiffel 1.0.3 scan-code bouton 5
		DE DEF_WHREPEAT; offset + 0x97 ADR_WHEELREPEAT Eiffel 1.0.3 Nombre de repetition

		DE "Eiffel 3"
		DE " LCD    "
;-----------------------------------------------------------------------------
Tab_Temperature
		DE 40; seuil maxi de temperature     Eiffel 1.0.4
		DE 35; seuil mini de temperature     Eiffel 1.0.4
Tab_CTN
		DE 27; 2700 ohms                     Eiffel 1.0.6
		DE 64; 63.6 deg C
		DE 33; 3300 ohms
		DE 57; 57.5 deg C
		DE 39; 3900 ohms
		DE 52; 52.3 deg C
		DE 47; 4700 ohms
		DE 47; 46.7 deg C
		DE 56; 5600 ohms
		DE 41; 41.5 deg C
		DE 68; 6800 ohms
		DE 36; 35.7 deg C
		DE 82; 8200 ohms
		DE 30; 30.5 deg C
		DE 100; 10000 ohms
		DE 25; 25.1 deg C
		DE 120; 12000 ohms
		DE 20; 20.1 deg C
		DE 150; 15000 ohms
		DE 15; 14.7 deg C
		DE 180; 18000 ohms
		DE 11; 10.6 deg C
		DE 220; 22000 ohms
		DE 6; 5.6 deg C
;-----------------------------------------------------------------------------
Tab_Config
		DE 3; jeu 2 ou 3 clavier             Eiffel 1.0.5
;-----------------------------------------------------------------------------
		END
