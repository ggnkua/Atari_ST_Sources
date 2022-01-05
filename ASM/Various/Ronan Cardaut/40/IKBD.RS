*-------------------------------------------------------------------------*
*		STRUCTURES SOUS IKBD
*-------------------------------------------------------------------------*

		*----------*
		* ParamŠtres ‚tendues de IKBD
		
		RSSET	sys_extend

ikbd_vars		rs.l	1	;variables globales

*-------------------------------------------------------------------------*

		*-------------*
		* description des variables globables
		
		RSRESET

ikbd_on		rs.b	1	;clavier actif
ikbd_kbd_ok	rs.b	1	;r‚veil clavier
ikbd_mouse_ok	rs.b	1	;r‚veil souris
ikbd_joy_ok	rs.b	1	;r‚veil joystick
ikbd_keys_eco	rs.b	1	;combinaison de touche pour l'‚conomiseur

		rs.b	1	;r‚serv‚ (arrondi)

ikbd_deadkeys	rs.b	1	;touches mortes:
				;  bit 0: shift droit
				;  bit 1: shift gauche
				;  bit 2: control
				;  bit 3: alternate
				;  bit 4: capslock
				;  bit 5: clr home->bouton droit de la souris
				;  bit 6: insert->bouton gauche de la souris
				;  bit 7: r‚serv‚ (0)
		rs.b	1	;r‚serv‚ (0)

*-------------------------------------------------------------------------*

		*----------*
		* Tables des correspondances entre scan et ascii
		
		RSRESET
		
key_unshift	rs.l	1	;...
key_shift		rs.l	1	;...
key_capslock	rs.l	1	;...
key_alt		rs.l	1	;...
key_altshift	rs.l	1	;...
key_altcapslock	rs.l	1	;...
key_autocomb	rs.l	1	;combinaison automatique
key_manucomb	rs.l	1	;combinaison manuelle

*-------------------------------------------------------------------------*

		*----------*
		* ParamŠtres pour KbdConf
		
		RSRESET

Kbd_OkRepeat	rs.b	1	;R‚p‚tition clavier
Kbd_DelayAuto	rs.b	1	;D‚lai pour la composition automatique
Kbd_DelayCm	rs.b	1	;D‚lai pour la composition manuelle
Kbd_WakeUp	rs.b	1	;R‚veil de l'‚cran
Kbd_KeysEco	rs.b	1	;Touches pour l'extinction de l'‚cran

*-------------------------------------------------------------------------*

		*----------*
		* ParamŠtres pour INITJOYSTICK
		
		RSRESET

joy_vec0		rs.l	1	;vecteur pour le joy0
joy_vec1		rs.l	1	;vecteur pour le joy1

*-------------------------------------------------------------------------*

		*----------*
		* ParamŠtres pour JoyConf
		
		RSRESET

Joy_Run		rs.b	1	;Active les joysticks 0 et 1
Joy_WakeUp	rs.b	1	;R‚veil de l'‚cran

Joy_OkRepeat0	rs.b	1	;R‚p‚tition joystick 0
Joy_Delay0	rs.b	1	;Amorce de la r‚p‚tion joystick 0
Joy_Repeat0	rs.b	1	;D‚lai de r‚p‚tion du joystick 0

Joy_OkRepeat1	rs.b	1	;R‚p‚tition joystick 1
Joy_Delay1	rs.b	1	;Amorce de la r‚p‚tion joystick 1
Joy_Repeat1	rs.b	1	;D‚lai de r‚p‚tion du joystick 1


*-------------------------------------------------------------------------*

		*----------*
		* ParamŠtres pour MsConf
		
		RSRESET

Ms_WakeUp		rs.b	1	;R‚veil de l'‚cran

*-------------------------------------------------------------------------*
		*----------*
		* Adresse hardware

mfpkbd		equ	4
_mfpkbd		equ	%00010000
_mfpkbd_es	equ	%01000000		;IERB, IPRB, ISRB, IMRB

	* Acia clavier

aciakbd_base	equ	$fffffc00

	* registres
acia_ctrl		equ	0
acia_data		equ	2

	* bit de control
	
	* lecture de acia_ctrl
ACIA_RDRF		equ	0
ACIA_TDRE		equ	1
ACIA_DCD		equ	2
ACIA_CTS		equ	3
ACIA_FE		equ	4
ACIA_OVRN		equ	5
ACIA_PE		equ	6
ACIA_IRQ		equ	7
	* masques

_ACIARDRF		equ	%00000001
_ACIATDRE		equ	%00000010
_ACIADCD		equ	%00000100
_ACIARTS		equ	%00001000
_ACIAFE		equ	%00010000
_ACIAOVRN		equ	%00100000
_ACIAPE		equ	%01000000
_ACIAIRQ		equ	%10000000

*-------------------------------------------------------------------------*
