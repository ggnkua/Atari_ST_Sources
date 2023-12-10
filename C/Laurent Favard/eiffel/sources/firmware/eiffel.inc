;**********************************************************************
;	Filename:	    Eiffel.inc
;	Date:          	18 Juillet 2001
;	File Version:  	27 Novembre 2004
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
;	Revision soft:	1.10
;	Revision board:	C	
;
;	29/01/2004 -Ajout set 2
;	25/02/2002 -Ajout des macros  DISABLEKEYB and DISABLEMOUSE.
;       10/08/2002 -Ajout des macros  READ_FLASH, WRITE_FLASH, UDIV1608L
;                  -Ajout de toutes les commandes IKBD Atari
;       12/10/2002 -Ajout des macros  WAIT_KCLOCK_L, WAIT_KCLOCK_H
;                                     WAIT_MCLOCK_L, WAIT_MCLOCK_H
;**********************************************************************

BAUD_9600			EQU		0x19		; Constant for baud generator 9600 baud at 4 Mhz
BAUD_7812_5			EQU		0x1F		; Constant for baud generator 7812.5 bauds at 4 Mhz
TAILLE_TAMPON_EM		EQU		80		; Taille tampon emission

;-----------------------------------------------------------------------------
; Pins assignements

RA0                 EQU     0
RA1                 EQU     1
RA2                 EQU     2
RA3                 EQU     3
RA4                 EQU     4
RA5                 EQU     5
RB0                 EQU     0
RB1                 EQU     1
RB2                 EQU     2
RB3                 EQU     3
RB4                 EQU     4
RB5                 EQU     5
RB6                 EQU     6
RB7                 EQU     7
RC0                 EQU     0
RC1                 EQU     1
RC2                 EQU     2
RC3                 EQU     3
RC4                 EQU     4
RC5                 EQU     5

;-----------------------------------------------------------------------------
; Pins affectation

LCD_DATA            EQU     RB4
LCD_CLOCK           EQU     RB5

KCLOCK              EQU     RB1
KDATA               EQU     RB0

MCLOCK              EQU     RB3
MDATA               EQU     RB2

MOTORON             EQU     RC5

KM_DISABLE          EQU     0x35                ;b0011.0101 No devices communications (disable all clocks)

;-----------------------------------------------------------------------------

JUMPER4             EQU     RB4			;Choix mode PS/2 (0V) directe OU tranlation ATARI (+5V)
JUMPER5             EQU     RB5					

LEDGREEN            EQU     RB6
LEDYELLOW           EQU     RB7

;-----------------------------------------------------------------------------

BIT_UN              EQU     0x80
BIT_ZERO            EQU     0x00

MAX_VALUE_LOOKUP    EQU     0x8F 

MAX_VALUE_ATARI     EQU     0x75

KEY_CAPSLOCK        EQU     0x3A                ;scancode PS2 touche Caps

LED_CAP             EQU     0x04
LED_NUM             EQU     0x02
LED_SCROLL          EQU     0x01

LEDS_OFF            EQU     0x00
LEDS_ON             EQU     LED_SCROLL | LED_CAP | LED_NUM

CAPS_ON             EQU     LED_CAP | LED_NUM   ;CAPS on, NUM on, scroll Off
CAPS_OFF                      EQU     LED_NUM	;CAPS off, NUM on, scroll Off

;----- Flags Bits -------------------------------------------------------------

CAPS_LOCK                    EQU    0x00; memorise l'etat du CAPS LOCK
MSWHEEL                      EQU    0x01; memorise si souris a roulette
MSWHEELPLUS                  EQU    0x02; roulette a 5 boutons/et 2eme roulette
MOUSE_ABS                    EQU    0x03; mode souris absolue IKBD
SIGN_Y                       EQU    0x04; sens axe Y souris
MOUSE_ENABLE                 EQU    0x05; autorisatin IKBD souris
JOY_ENABLE                   EQU    0x06; autorisation IKBD joysticks
IKBD_ENABLE                  EQU    0x07; autorisation envoi IKBD

;----- Flags2 Bits ------------------------------------------------------------

MOUSE_KEYS                   EQU    0x00; mode keycode souris IKBD
JOY_KEYS                     EQU    0x01; mode keycode joystick 0 IKBD
JOY_EVENT                    EQU    0x02; mode evemenents joysticks IKBD
JOY_MONITOR                  EQU    0x03; mode monitorig joysticks IKBD
BREAK_CODE                   EQU    0x04; touche enfonce(0)/relachee(1)
DATATOSEND                   EQU    0x05; donnees a envoyer sur la liaison serie
RESET_KEYB                   EQU    0x06; demande d'envoi commante reset clavier PS/2
RESET_MOUSE                  EQU    0x07; demande d'envoi commante reset souris PS/2

;----- Flags3 Bits ------------------------------------------------------------

NEXT_CODE                    EQU    0x00; Eiffel 1.0.5 flag 2eme code apres 0xE0 avec set 2
NEXT_CODES                   EQU    0x01; Eiffel 1.0.5 flag 2eme et 3eme code apres 0xE1 avec set 2
PAUSE_SET_2                  EQU    0x02; Eiffel 1.0.5 flag pause set 2 (longue trame 0xE1 0x14 0x77)
KEYB_SET_2                   EQU    0x03; Eiffel 1.0.5 mis a 1 si utilisation du set 2
ALTGR_PS2                    EQU    0x04; Eiffel 1.0.7 memorise l'etat de AltGr
SHIFT_PS2                    EQU    0x05; Eiffel 1.0.7 memorise l'etat de Shift
ALT_PS2                      EQU    0x06; Eiffel 1.0.8 memorise l'etat de Alt
RE_TIMER_IKBD                EQU    0x07; Eiffel 1.10 flag reception donnees IKBD dans la boucle principale 

;----- Flags4 Bits ------------------------------------------------------------

FORCE_ALT_SHIFT              EQU    0x00; Eiffel 1.0.7 force l'etat ALT et SHIFT vers l'unite centrale
RIGHT_SHIFT_HOST             EQU    0x01; Eiffel 1.0.7 memorise l'etat du SHIFT droit
LEFT_SHIFT_HOST              EQU    0x02; Eiffel 1.0.7 memorise l'etat du SHIFT gauche
ALT_HOST                     EQU    0x03; Eiffel 1.0.7 memorise l'etat de ALT
CTRL_HOST                    EQU    0x04; Eiffel 1.0.8 memorise l'etat de CTRL
KEY_FORCED                   EQU    0x05; Eiffel 1.0.8 flag forcage CTRL SHIFT ALT vers unite centrale 
LCD_ENABLE                   EQU    0x06; Eiffel 1.10 autorisation gestion timer de l'afficheur LCD
RE_LCD_IKBD                  EQU    0x07; Eiffel 1.10 flag reception donnees LCD dans la boucle principale

;----- Flags5 Bits ------------------------------------------------------------

ALTGR_PS2_BREAK              EQU    0x04; Eiffel 1.10 memorise l'etat de AltGr jusqu'au break code
SHIFT_PS2_BREAK              EQU    0x05; Eiffel 1.10 memorise l'etat de Shift jusqu'au break code

;----- Status_Boot Bits -------------------------------------------------------

POWERUP_LCD                  EQU    0x05; mis a 1 lors de l'init LCD a la mise sous tension
POWERUP_KEYB                 EQU    0x06; mis a 1 des reception commande BAT clavier
POWERUP_MOUSE                EQU    0x07; mis a 1 des reception commande BAT souris 
                                                                          
;----- Flags_JOY Bits ---------------------------------------------------------

RY_H                         EQU    0x00
RY_B                         EQU    0x01
RX_G                         EQU    0x02
RX_D                         EQU    0x03
TY_H                         EQU    0x04
TY_B                         EQU    0x05
TX_G                         EQU    0x06
TX_D                         EQU    0x07    

;----- IKBD commandes ---------------------------------------------------------
;                                          * = gere   ** = ajout pour Eiffel
IKBD_GETTEMP                 EQU    0x03 ; ** Eiffel 1.0.4
IKBD_PROGTEMP                EQU    0x04 ; ** Eiffel 1.0.4
IKBD_PROGKB                  EQU    0x05 ; **
IKBD_PROGMS                  EQU    0x06 ; **
IKBD_SET_MOUSE_BUTTON_ACTION EQU    0x07 ; *
IKBD_REL_MOUSE_POS_REPORT    EQU    0x08 ; *
IKBD_ABS_MOUSE_POSITIONING   EQU    0x09 ; *
IKBD_SET_MOUSE_KEYCODE_CODE  EQU    0x0A ; *
IKBD_SET_MOUSE_THRESHOLD     EQU    0x0B
IKBD_SET_MOUSE_SCALE         EQU    0x0C ; *
IKBD_INTERROGATE_MOUSE_POS   EQU    0x0D ; *
IKBD_LOAD_MOUSE_POS          EQU    0x0E ; *
IKBD_SET_Y0_AT_BOTTOM        EQU    0x0F ; *
IKBD_SET_Y0_AT_TOP           EQU    0x10 ; *
IKDB_RESUME                  EQU    0x11 ; *
IKDB_DISABLE_MOUSE           EQU    0x12 ; *
IKDB_PAUSE_OUTPUT            EQU    0x13 ; *
IKBD_SET_JOY_EVNT_REPORT     EQU    0x14 ; *
IKBD_SET_JOY_INTERROG_MODE   EQU    0x15 ; *
IKBD_JOY_INTERROG            EQU    0x16 ; *
IKBD_SET_JOY_MONITOR         EQU    0x17 ; *
IKBD_SET_FIRE_BUTTON_MONITOR EQU    0x18
IKBD_SET_JOY_KEYCODE_MODE    EQU    0x19 ; *
IKDB_DISABLE_JOYSTICKS       EQU    0x1A ; *
IKBD_TIME_OF_DAY_CLOCK_SET   EQU    0x1B ; *
IKBD_INTERROG_TIME_OF_DAY    EQU    0x1C ; *
IKBD_MEMORY_LOAD             EQU    0x20 ; *
IKBD_MEMORY_READ             EQU    0x21 ; *
IKBD_CONTROLLER_EXECUTE      EQU    0x22
IKBD_LCD                     EQU    0x23 ; ** Eiffel 1.10
IKBD_RESET                   EQU    0x80 ; *
IKBD_STATUS_MOUSE_BUT_ACTION EQU    0x87 ; *
IKBD_STATUS_MOUSE_MODE_R     EQU    0x88 ; *
IKBD_STATUS_MOUSE_MODE_A     EQU    0x89 ; *
IKBD_STATUS_MOUSE_MODE_K     EQU    0x8A ; *
IKBD_STATUS_MOUSE_THRESHOLD  EQU    0x8B ; *
IKBD_STATUS_MOUSE_SCALE      EQU    0x8C ; *
IKBD_STATUS_MOUSE_Y0_AT_B    EQU    0x8F ; *
IKBD_STATUS_MOUSE_Y0_AT_T    EQU    0x90 ; *
IKDB_STATUS_DISABLE_MOUSE    EQU    0x92 ; *
IKBD_STATUS_JOY_MODE_E       EQU    0x94 ; *
IKBD_STATUS_JOY_MODE_I       EQU    0x95 ; *
IKBD_STATUS_JOY_MODE_K       EQU    0x99 ; *
IKDB_STATUS_DISABLE_JOY      EQU    0x9A ; *

;----- IKBD trames ------------------------------------------------------------

HEADER_STATUS                EQU    0xF6 ; status report
HEADER_ABSOLUTE_MOUSE        EQU    0xF7 ; absolute mouse position record
HEADER_RELATIVE_MOUSE        EQU    0xF8 ; relative mouse position records
HEADER_TIME_OF_DAY           EQU    0xFC ; time-of-day
HEADER_JOYSTICKS             EQU    0xFD ; joystick report (both sticks)
HEADER_JOYSTICK0             EQU    0xFE ; joystick 0 event
HEADER_JOYSTICK1             EQU    0xFF ; joystick 1 event

;----- Commandes Clavier PS2 --------------------------------------------------

SET_RESET_LEDS               EQU    0xED
ECHO                         EQU    0xEE
SET_SCAN_CODE_SET            EQU    0xF0
READ_ID                      EQU    0xF2
SET_TYPEMATIC_RATE_DELAY     EQU    0xF3
ENABLE                       EQU    0xF4
DEFAULT_DISABLE              EQU    0xF5
SET_DEFAULT                  EQU    0xF6
SET_ALL_KEYS_TYPEMATIC       EQU    0xF7
SET_ALL_KEYS_MAKE_BREAK      EQU    0xF8
SET_ALL_KEYS_MAKE            EQU    0xF9
SET_ALL_KEYS_TYP_MAKE_BRK    EQU    0xFA
SET_KEY_TYPE_TYPEMATIC       EQU    0xFB
SET_KEY_MAKE_BREAK           EQU    0xFC
SET_KEY_TYPE_MAKE            EQU    0xFD
RESEND                       EQU    0xFE
RESET                        EQU    0xFF

;----- Commandes Souris PS2 ---------------------------------------------------

STATUS_REQUEST               EQU    0xE9
SET_STREAM_MODE              EQU    0xEA
READ_DATA                    EQU    0xEB
SET_WRAP_MODE                EQU    0xEE
SET_REMOTE_MODE              EQU    0xF0
GET_DEVICE_ID                EQU    0xF2
SET_SAMPLE_RATE              EQU    0xF3
ENABLE_DATA_REPORTING        EQU    0xF4
DISABLE_DATA_REPORTING       EQU    0xF5
SET_DEFAULTS                 EQU    0xF6
;RESEND                      EQU    0xFE
;RESET                       EQU    0xFF

;------------------------------------------------------------------------------
;   PS/2 Devices commands

CMD_LED                      EQU    0xED ; allumage des LEDs
CMD_SET                      EQU    0xF0
CMD_GETDEVID                 EQU    0xF2 ; get device ID
CMD_STTPMTRATE               EQU    0xF3 ; vitesse de repetition clavier
CMD_SETSMPRT                 EQU    0xF3 ; vitesse echantillonnage souris
CMD_MKBRK                    EQU    0xF8
CMD_TMMKBRK                  EQU    0xFA ; all key typematic/make/break
CMD_ENABLE                   EQU    0xF4

KEYB_ERROR                   EQU    0x00 ; Erreur clavier
CMD_BAT                      EQU    0xAA ; Commande BAT OK du clavier/souris
ESCAPE                       EQU    0xE0 ; Escape Set 2
ESCAPE1                      EQU    0xE1 ; Escape Set 2 touche Pause
CMD_RELEASED                 EQU    0xF0 ; Break code
ACK                          EQU    0xFA ; Acknoledge
BAT_ERROR                    EQU    0xFC ; Commande BAT erreur du clavier/souris
FAILURE                      EQU    0xFD 
ACK_ERROR                    EQU    0xFE ; Acknoledge failure

SCANCODESET2                 EQU    0x02 ; Eiffel 1.0.5 scan-codes set 2
SCANCODESET3                 EQU    0x03 ; scan-codes set 3

MS_PS2                       EQU    0x00 ; ID retournee par une souris standard
MS_WHEEL                     EQU    0x03 ; ID retournee par une souris molette 3 b.
MS_WHEELPLUS                 EQU    0x04 ; ID retournee par une souris molette(s) 5 b.

;-----------------------------------------------------------------------------
;	definitions souris PS/2 et atari

;Position bits et scan-codes Atari
AT_MOUSE                     EQU    0xF8
AT_LEFT                      EQU    1
AT_RIGHT                     EQU    0
AT_SIGN                      EQU    7

;----- Sous-commandes Eiffel Program Temp Flash Data ---------------------

IDX_LEVELHTEMP               EQU    0x00; seuil maxi de temperature
IDX_LEVELLTEMP               EQU    0x01; seuil mini de temperature
IDX_TAB_CTN                  EQU    0x02; Eiffel 1.0.6 2*12 valeurs (Rctn/100, temperature)

;----- Sous-commandes Eiffel Program Mouse Flash Data --------------------

IDX_WHEELUP                  EQU    0x00; Eiffel 1.0.0
IDX_WHEELDN                  EQU    0x01; Eiffel 1.0.1 ( v1.0.0 retournait 0x60 )
IDX_WHEELLT                  EQU    0x02; Eiffel 1.0.3 seulement
IDX_WHEELRT                  EQU    0x03; Eiffel 1.0.3 seulement
IDX_BUTTON3                  EQU    0x04; Eiffel 1.0.3 scan-code bouton Central
IDX_BUTTON4                  EQU    0x05; Eiffel 1.0.3 scan-code bouton 4
IDX_BUTTON5                  EQU    0x06; Eiffel 1.0.3 scan-code bouton 5
IDX_WHREPEAT                 EQU    0x07; Eiffel 1.0.3 Nombre de repetition 

;----- Sous-commandes Eiffel Program Keyboard Flash Data ( 0x00 - 0x8F) --

IDX_SCROLL                   EQU    0x5F
IDX_PAGEUP                   EQU    0x6F
IDX_PAGEDN                   EQU    0x6D
IDX_END                      EQU    0x65
IDX_PRNTSCREEN               EQU    0x57
IDX_PAUSE                    EQU    0x62
IDX_VERRN                    EQU    0x76
IDX_WLEFT                    EQU    0x8B
IDX_WRIGHT                   EQU    0x8C
IDX_WAPP                     EQU    0x8D
IDX_RUSSE                    EQU    0x0E
IDX_ALTGR                    EQU    0x39
IDX_F11                      EQU    0x56
IDX_F12                      EQU    0x5E

IDX_POWER                    EQU    0x80   ; Eiffel 1.0.8 Set 2
IDX_SLEEP                    EQU    0x7F   ; Eiffel 1.0.5
IDX_WAKE                     EQU    0x81   ; Eiffel 1.0.8 Set 2 

;----- Valeurs par defaut scan-code souris -------------------------------

DEF_WHEELUP                  EQU    0x59
DEF_WHEELDN                  EQU    0x5A
DEF_WHEELLT                  EQU    0x5C
DEF_WHEELRT                  EQU    0x5D
DEF_BUTTON3                  EQU    0x37
DEF_BUTTON4                  EQU    0x5E
DEF_BUTTON5                  EQU    0x5F
DEF_WHREPEAT                 EQU    0x03

DEF_SCROLL                   EQU    0x4C
DEF_PAGEUP                   EQU    0x45
DEF_PAGEDN                   EQU    0x46
DEF_END                      EQU    0x55
DEF_PRINTSCREEN              EQU    0x49
DEF_PAUSE                    EQU    0x4F
DEF_VERRNUM                  EQU    0x54
DEF_WINLEFT                  EQU    0x56
DEF_WINRIGHT                 EQU    0x57
DEF_WINAPP                   EQU    0x58
DEF_RUSSE                    EQU    0x5B
DEF_ALTGR                    EQU    0x38   ; Alt Atari
DEF_F11                      EQU    0x62   ; Help Atari
DEF_F12                      EQU    0x61   ; Undo Atari

DEF_POWER                    EQU    0x73   ; Eiffel 1.0.5 Set 2
DEF_SLEEP                    EQU    0x74   ; Eiffel 1.0.5
DEF_WAKE                     EQU    0x75   ; Eiffel 1.0.5 Set 2 
; >= 0x80 => envoyes via 0xF6 0x05 0x00 0x00 0x00 0x00 0x00 0xXX-0x80
; ou 0xF6 0x05 0x00 0x00 0x00 0x00 0x00 0xXX si relachement
DEF_NEXT_TRACK               EQU    0xCD   ; Eiffel 1.0.5 Set 2
DEF_PREVIOUS_TRACK           EQU    0x95   ; Eiffel 1.0.5 Set 2
DEF_STOP                     EQU    0xBB   ; Eiffel 1.0.5 Set 2
DEF_PLAY_PAUSE               EQU    0xB4   ; Eiffel 1.0.5 Set 2
DEF_MUTE                     EQU    0xA3   ; Eiffel 1.0.5 Set 2
DEF_VOLUME_UP                EQU    0xB2   ; Eiffel 1.0.5 Set 2
DEF_VOLUME_DOWN              EQU    0xA1   ; Eiffel 1.0.5 Set 2
DEF_MEDIA_SELECT             EQU    0xD0   ; Eiffel 1.0.5 Set 2
DEF_EMAIL                    EQU    0xC8   ; Eiffel 1.0.5 Set 2
DEF_CACULATOR                EQU    0xAB   ; Eiffel 1.0.5 Set 2
DEF_MY_COMPUTER              EQU    0xC0   ; Eiffel 1.0.5 Set 2
DEF_WWW_SEARCH               EQU    0x90   ; Eiffel 1.0.5 Set 2
DEF_WWW_HOME                 EQU    0xBA   ; Eiffel 1.0.5 Set 2
DEF_WWW_BACK                 EQU    0xB8   ; Eiffel 1.0.5 Set 2
DEF_WWW_FORWARD              EQU    0xB0   ; Eiffel 1.0.5 Set 2
DEF_WWW_STOP                 EQU    0xA8   ; Eiffel 1.0.5 Set 2
DEF_WWW_REFRESH              EQU    0xA0   ; Eiffel 1.0.5 Set 2
DEF_WWW_FAVORITES            EQU    0x98   ; Eiffel 1.0.5 Set 2

;-----------------------------------------------------------------------------
;   Scan-code inactivite

AT_WHEELNOT                  EQU    0x00            ;Eiffel 1.0.0

;-----------------------------------------------------------------------------
;Position bits PS/2 dans les paquets

PC_BITLSBZ                   EQU    0				;BIT 0 pour vertical/horizontal molete detection
PC_LEFT	                     EQU    0				;BIT bouton souris
PC_RIGHT                     EQU    1				;BIT bouton souris
PC_MIDDLE                    EQU    2				;BIT bouton souris
PC_BUTTON4                   EQU    4				;BIT bouton souris molette plus
PC_BUTTON5                   EQU    5				;BIT bouton souris molette plus
PC_SIGNX                     EQU    4				;BIT signe mouvement souris en X
PC_SIGNY                     EQU    5				;BIT signe mouvement souris en Y
PC_SIGNZ                     EQU    3				;BIT signe mouvement souris molette et combine

;-----------------------------------------------------------------------------

ClockStrobe     MACRO
		bsf PORTB,LCD_CLOCK; Strobe Data Bit
		bcf PORTB,LCD_CLOCK
		ENDM

EStrobe         MACRO
		bsf PORTB,LCD_DATA; Strobe "E" Bit
		bcf PORTB,LCD_DATA
                ENDM

DISABLEPS2	MACRO
		bsf STATUS,RP0; page 1
		bcf TRISB,KCLOCK; en sortie
		bcf TRISB,MCLOCK; en sortie
		bcf STATUS,RP0; page 0
		bcf PORTB,KCLOCK
		bcf PORTB,MCLOCK
		ENDM
		
ENABLEPS2	MACRO
		bsf STATUS,RP0; page 1
		bsf TRISB,KCLOCK; en entree
		bsf TRISB,MCLOCK; en entree
		bcf STATUS,RP0; page 0
		ENDM

ENABLEMOUSE	MACRO
		bsf STATUS,RP0; page 1
		bsf TRISB,MCLOCK; en entree
		bcf STATUS,RP0; page 0
		ENDM

ENABLEKEYB	MACRO
		bsf STATUS,RP0; page 1
		bsf TRISB,KCLOCK; en entree
		bcf STATUS,RP0; page 0
		ENDM

DISABLEMOUSE	MACRO
		bsf STATUS,RP0; page 1
		bcf TRISB,MCLOCK; en sortie
		bcf STATUS,RP0; page 0
		bcf PORTB,MCLOCK
		ENDM
		
DISABLEKEYB	MACRO
		bsf STATUS,RP0; page 1
		bcf TRISB,KCLOCK; en sortie
		bcf STATUS,RP0; page 0
		bcf PORTB,KCLOCK
		ENDM	

;-----------------------------------------------------------------------------
;Macros to select the register bank
;Many bank changes can be optimised when only one STATUS bit changes

Bank0	            MACRO			;macro to select data RAM bank 0
		            bcf	STATUS,RP0
		            bcf	STATUS,RP1
		            ENDM

Bank1	            MACRO			;macro to select data RAM bank 1
		            bsf	STATUS,RP0
		            bcf	STATUS,RP1
		            ENDM

Bank2	            MACRO			;macro to select data RAM bank 2
		            bcf	STATUS,RP0
		            bsf	STATUS,RP1
		            ENDM

Bank3	            MACRO			;macro to select data RAM bank 3
		            bsf	STATUS,RP0
		            bsf	STATUS,RP1
		            ENDM

;-----------------------------------------------------------------------------

CheckG              MACRO   PIN
                    btfsc   PORTB,PIN
                    goto    $ + 3
                    bcf     PORTB,RB6
                    goto    $ + 2
                    bsf     PORTB,RB6
                    ENDM
        
;-----------------------------------------------------------------------------

CheckY              MACRO   PIN
                    btfsc   PORTB,PIN
                    goto    $ + 3
                    bcf     PORTB,RB7
                    goto    $ + 2
                    bsf     PORTB,RB7
                    ENDM

;-----------------------------------------------------------------------------
; Attente fronts horloge clavier
                    
WAIT_KCLOCK_L	MACRO
		LOCAL WKCL1,WKCL2
                IF NON_BLOQUANT
		clrf Counter2; time-out
WKCL1
			btfss PORTB,KCLOCK; attente front descendant de CLK
				goto WKCL2
			decfsz Counter2,F
		goto WKCL1
WKCL2
		ELSE
		btfsc PORTB,KCLOCK; attente front descendant de CLK
			goto $ -1
		ENDIF
		ENDM
		
WAIT_KCLOCK_H	MACRO
		LOCAL WKCH1,WKCH2
                IF NON_BLOQUANT
		clrf Counter2; time-out
WKCH1
			btfsc PORTB,KCLOCK; attente front montant de CLK
				goto WKCH2
			decfsz Counter2,F
		goto WKCH1
WKCH2
		ELSE
		btfss PORTB,KCLOCK; attente front montant de CLK
			goto $ -1
		ENDIF
		ENDM
		
;-----------------------------------------------------------------------------
; Attente fronts horloge souris
                    
WAIT_MCLOCK_L	MACRO
		LOCAL WMCL1,WMCL2
                IF NON_BLOQUANT
		clrf Counter2; time-out
WMCL1
			btfss PORTB,MCLOCK; attente front descendant de CLK
				goto WMCL2
			decfsz Counter2,F
		goto WMCL1
WMCL2
		ELSE
		btfsc PORTB,MCLOCK; attente front descendant de CLK
			goto $ -1
		ENDIF
		ENDM
		
WAIT_MCLOCK_H	MACRO
		LOCAL WMCH1,WMCH2
                IF NON_BLOQUANT
		clrf Counter2; time-out
WMCH1
			btfsc PORTB,MCLOCK; attente front montant de CLK
				goto WMCH2
			decfsz Counter2,F
		goto WMCH1
WMCH2
		ELSE
		btfss PORTB,MCLOCK; attente front montant de CLK
			goto $ -1
		ENDIF
		ENDM
                        
;-----------------------------------------------------------------------------
;	Lit dans l'EEPROM DATA la valeur stockee a l'Adresse presente dans W
;   et retourne dans W le resultat.

RDEEPROM	MACRO
		bsf STATUS,RP1; page 2
		bcf STATUS,RP0;
		movwf EEADR
		bsf STATUS,RP0; page 3
		bcf EECON1,EEPGD; EEPROM
		bsf EECON1,RD; lecture
		bcf STATUS,RP0; page 2
		movf EEDATA,W
		bcf STATUS,RP1; page 0
		ENDM

;-----------------------------------------------------------------------------
;	Ecrit dans l'EEPROM DATA la valeur dans DATA, a l'adresse dans ADR

WREEPROM	MACRO ADR,DATA
		LOCAL WE1,WE2
		bsf STATUS,RP1; page 3
		bsf STATUS,RP0 
WE		btfsc EECON1,WR; attente ecriture
			goto WE
		bcf STATUS,RP0; page 2
		movf ADR,W; adresse
		movwf EEADR
		movf DATA,W; donnee a ecrire
		movwf EEDATA
		bsf STATUS,RP0; page 3
		bcf EECON1,EEPGD; EEPROM
		IF INTERRUPTS
		bcf STATUS,C; efface Carry
		btfsc INTCON,GIE; Global Interrupt Enable
			bsf STATUS,C; sauve etat GIE
		bcf INTCON,GIE; interdit interruptions
		ENDIF
		bsf EECON1,WREN; autorise ecriture
		movlw 0x55
		movwf EECON2
		movlw 0xAA
		movwf EECON2
		bsf EECON1,WR; commence ecriture
		IF INTERRUPTS
		btfsc STATUS,C; etat GIE avant masquage interruptions
			bsf INTCON,GIE; autorise interruptions
		ENDIF
		bcf EECON1,WREN; enleve autorisation ecriture
		bcf STATUS,RP0; page 0
		bcf STATUS,RP1
		ENDM

;-----------------------------------------------------------------------------

READ_FLASH	MACRO ADRH,ADRL,DATAADR
		bsf STATUS,RP1; page 2
		bcf STATUS,RP0;
		movf ADRH,W
		movwf EEADRH; adresse en FLASH
		movf ADRL,W
		movwf EEADR
		bsf STATUS,RP0; page 3
		bsf EECON1,EEPGD; FLASH
		bsf EECON1,RD; lecture
		nop
		nop
		bcf STATUS,RP0; page 2
		movf EEDATA,W
		movwf DATAADR; 1er octet a lire (poids faible)
		movf EEDATH,W
		movwf DATAADR+1; 2eme octet a lire (poids fort)
		bcf STATUS,RP1; page 0
		ENDM

;-----------------------------------------------------------------------------

WRITE_FLASH	MACRO ADRH,ADRL,DATAADR
		bsf STATUS,RP1; page 2
		bcf STATUS,RP0 
		movf ADRH,W
		movwf EEADRH; adresse en FLASH
		movf ADRL,W
		movwf EEADR
		movf DATAADR,W; 1er octet a ecrire (poids faible)
		movwf EEDATA
		movf DATAADR+1,W; 2eme octet a ecrire (poids fort)
		movwf EEDATH
		bsf STATUS,RP0; page 3
		bsf EECON1,EEPGD; FLASH
		bcf STATUS,C; efface Carry
		btfsc INTCON,GIE; Global Interrupt Enable
			bsf STATUS,C; sauve etat GIE
		bcf INTCON,GIE; interdit interruptions
		bsf EECON1,WREN; autorise ecriture
		movlw 0x55
		movwf EECON2
		movlw 0xAA
		movwf EECON2
		bsf EECON1,WR; commence ecriture
		nop
		nop
		bcf EECON1,WREN; enleve autorisation ecriture
		btfsc STATUS,C; etat GIE avant masquage interruptions
			bsf INTCON,GIE; autorise interruptions
		bcf STATUS,RP0; page 0
		bcf STATUS,RP1
		ENDM
		
;-----------------------------------------------------------------------------
Delay_Ms   	macro   Time            ; Delais en 1/10 mS

          movlw Time
          call Delay_Routine_Ms
          endm

;-----------------------------------------------------------------------------
Delay   	macro   Time            ; Delais "Cycles" instruction cycles

    if (Time==1)
          nop
          exitm
    endif
    if (Time==2)
          goto $ + 1
          exitm
    endif
    if (Time==3)
          nop
          goto $ + 1
          exitm
    endif
    if (Time==4)
          goto $ + 1
          goto $ + 1
          exitm
    endif
    if (Time==5)
          goto $ + 1
          goto $ + 1
          nop
          exitm
    endif
    if (Time==6)
          goto $ + 1
          goto $ + 1
          goto $ + 1
          exitm
    endif
    if (Time==7)
          goto $ + 1
          goto $ + 1
          goto $ + 1
          nop
          exitm
    endif
    if (Time%4==0)
          movlw (Time-4)/4
          call Delay_Routine
          exitm
    endif
    if (Time%4==1)
          movlw (Time-5)/4
          call Delay_Routine
          nop
          exitm
    endif
    if (Time%4==2)
          movlw (Time-6)/4
          call Delay_Routine
          goto $ + 1
          exitm
    endif
    if (Time%4==3)
          movlw (Time-7)/4
          call Delay_Routine
          goto $ + 1
          nop
          exitm
    endif
    endm

;------------------------------------------------------------------------
UMUL0808L	MACRO AARGB0,AARGB1,BARGB0 ; AARGB0 * BARGB0 -> AARGB0-1
		LOCAL LOOPUM0808A,LUM0808NAP,LOOPUM0808,LOOPUM0808,LUM0808NA,END0808
		clrf AARGB1
		movlw 8
		movwf Counter
		movf AARGB0,W
LOOPUM0808A
			rrf BARGB0,F
                	btfsc STATUS,C
				goto LUM0808NAP
			decfsz Counter,F
		goto LOOPUM0808A
		clrf AARGB0
                goto END0808
LUM0808NAP
		bcf STATUS,C
		goto LUM0808NA
LOOPUM0808
			rrf BARGB0,F
			btfsc STATUS,C
				addwf AARGB0,F
LUM0808NA
			rrf AARGB0,F
			rrf AARGB1,F
			decfsz Counter,F
		goto LOOPUM0808
END0808
		ENDM
;------------------------------------------------------------------------

UDIV1608L	MACRO AARGB0,AARGB1,BARGB0,REMB0; AARGB0-1 / BARGB0 -> AARGB0-1
		LOCAL LOOPU1608A,UOK68A,LOOPU1608B,UOK68B
		clrf REMB0
		movlw 8
		movwf Counter
LOOPU1608A		rlf AARGB0,W
			rlf REMB0,F
			movf BARGB0,W
			subwf REMB0,F
			btfsc STATUS,C
				goto UOK68A
			addwf REMB0,F
			bcf STATUS,C
UOK68A			rlf AARGB0,F
			decfsz Counter,F
		goto  LOOPU1608A
		clrf  TEMP1
		movlw 8
		movwf Counter
LOOPU1608B		rlf AARGB1,W
			rlf REMB0,F
			rlf TEMP1,F
			movf BARGB0,W
			subwf REMB0,F
			clrf TEMP2
			clrw
			btfss STATUS,C
				incfsz TEMP2,W
			subwf TEMP1,F
			btfsc STATUS,C
				goto UOK68B
			movf BARGB0,W
			addwf REMB0,F
			clrf TEMP2
			clrw
			btfsc STATUS,C
				incfsz TEMP2,W
			addwf TEMP1,F
			bcf STATUS,C
UOK68B			rlf AARGB1,F
			decfsz Counter,F
		goto  LOOPU1608B
		ENDM
		


