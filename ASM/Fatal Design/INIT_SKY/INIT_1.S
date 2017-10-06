*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*
*                                     *
*  Initialisation pour les programmes *
*  Gem ou Tos (partie 030)            *
*                                     *
*  Options :                          *
*   -Debugger integre                 *
*   -Routine clavier sous Inter       *
*   -Start Up pour programmes Gem     *
*   -Protection contre les erreurs    *
*    avec detournement des exceptions *
*   -Proctection contre les erreurs   *
*    de type Host Port ou boucle dans *
*    le vide                          *
*                                     *
*                                     *
*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*
*  Par Skynet From Fatal Design       *
*  BAUMANN Loic                       *
*  72, Rue du dauphine                *
*  69003 Lyon                         *
* Compuser, iD : 100620,2673          *
*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*

; Tabulation = 3

	Opt O+

; Options systeme
Stack_Size			equ	10000				; Taille en octet de la Pile
StartUp				equ	1					; Si 1, on effectue un StartUp
Mouse					equ	0					; Si 1, la souris est active
Joystick				equ	0					; Si 1, le joystick est active

; Options HardWare
Data_Cache			equ	1					; Si 1, cache de donnee actif
Instruction_Cache	equ	1					; Si 1, cache d'instruction actif
Keyboard_Inter		equ	1					; Si 1, routine clavier sous interruption
	IfNe	Keyboard_Inter
Exit_Priority		equ	1					; Si 1, on traite la touche espace sous Inter et
	EndC											; des qu'on appuie dessus, quoi qu'il arrive, on quitte

; Options graphique
VBL_Number			equ	0					; Si 1, on affiche le nombre de VBL (True color uniquement)
Screen_Size			equ	320*200*2		; Taille de l'ecran en octet
Nbr_Screen			equ	2					; Nombre d'ecrans

; Option du DSP
Exec_P56				equ	0					; Si 1, charge et execute un Prg DSP realise avec INIT_1.ASM
	IfNe	Exec_P56
Break_Host_Error	equ	0					; Si 1, on interrompe le prg quand le 
	EndC													; DSP ne repond pas au bout de 1sec

; Options de protection
Protec_Mode			equ	1					; Si 1, detournement des execeptions + mode proteger
Break_Div_By_0		equ	0					; Si 0, une fois l'exception finie, on continue.
Break_Illegal		equ	0					; Si 0, une fois l'exception finie, on continue.

; Option de debug
Debug					equ	0					; Si 1, coupe les inters MFP

	Bra		Start
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;				Fichier Init				  |
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Include	'INIT_SYS.S'

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Section TEXT
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Start
; Sauvegarde et initialisation du System
	Bra		Init_System
Setting
; On met en place la bonne resolution
	lea		Videl_320_200_True,a0
	Bsr		Set_Res
; On installe les nouveau ecrans
	lea		Adr_Screen1,a0
	move.l	#Screens,d0
	move.w	#Nbr_Screen,d1
	move.l	#Screen_Size,d2	
	bsr		Instal_Screens
	move.l	Adr_Screen1,d0
	lsr.w		#8,d0
	move.l	d0,$ffff8200.w
; On met en place notre Interruption VBL
	Ifeq		Debug
	move.l	#VBL,$70.w
		IfNe	Keyboard_Inter
	move.l	#Kbd_Rout,$118.w				; En mode debug, on autorise cette Inter
	or.b		#$40,$fffffa09.w				; On rend l'inter clavier possible
	or.b		#$40,$fffffa15.w
		EndC
	EndC

; On execute les initialisations particulieres	
	Bsr.s		Specials_Inits

; Gestion principale	
Main_Loop
	clr.w		C_VBL
.Wait_VBL
	IfEq		Debug
	tst.w		C_VBL								; mode normal, on peux se synchroniser sur la VBL
	beq.s		.Wait_VBL
	ElseIf
	Bsr		VBL								; Mode debug, on execute la VBL comme une routine
		IfNe		Keyboard_Inter
	
	Bsr		Kbd_Rout							; Pareille pour le clavier, ca limite les degats
		EndC
	EndC

	bsr.s		Main_Synchro

	cmpi.b	#$39+$80,$fffffc02.w
	bne.s		Main_Loop

	Bra.s		Restore_It

Exception
; Restauration du System
	nop
Restore_It
	Bsr		Restore_System

	tst.w		EXP
	beq.s		.No_Errors
.Wa
	cmpi.b	#$66+$80,$fffffc02.w
	bne.s		.Wa
.No_Errors
	move.l	Old_Stack_Adr,SP
; Pterm	
	clr.w		-(sp)
	trap		#1


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;				Inits Specifiques			  |
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Specials_Inits
	Rts

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;				Routine VBL					  |
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VBL
	IfNe		Exec_P56
	IfNe		Break_Host_Error
	btst		#HTDE,HSR						; Le DSP est en etat de repondre ?
	Beq.s		.Not_Responding				; Non, ben c'est louche
	Bra.s		.End_Control
	btst		#HRDF,HSR						; Pareille, il peux repondre ?
	Bne.s		.End_Control					; Ouaip, c oki
.Not_Responding
	addq.w	#1,DSP_Wait						; Le DSP ne repond pas, ca fait combien de fois de suite ?
	cmpi.w	#50,DSP_Wait					; 50?
	Blo.s		.End_Checking					; Non, c pas encore alarmant
	move.w	#$2700,(sp)						; On cut toutes les interruptions car le DSP est foutu
	move.l	#Host_Error,2(sp)				; On modifie l'addresse de retour
.End_Control	
	clr.w		DSP_Wait
.End_Checking
	EndC
	EndC

	addq.w	#1,C_VBL

	IfEq		Debug
	Rte
	ElseIf
	Rts
	EndC

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;			Routine principale			  |
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Main_Synchro

	IfNe		Exec_P56
	Host_Send_Data		#$1213				; On active la synchro VBL-030/DSP
	EndC
	
	move.w	#10000,d7
	dbf		d7,*
	
	move.l	#$ff000040,$ffff9800.w
	move.w	#10000,d7
	dbf		d7,*


	IfNe		VBL_Number
	move.l	#$a0c00060,$ffff9800.w
	Bsr		Draw_VBL_Number
	clr.w		C_VBL
	EndC
	clr.l		$ffff9800.w
	Rts

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
	Section DATA
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
Super_ID				dc.l		0
C_VBL					dc.w		0

		IfNe	Exec_P56
DSP_Wait				dc.w		0
DSP_Code				IncBin	'INIT_1.P56'
DSP_Code_Size		Equ		(*-DSP_Code)/3
		Even
		EndC
		
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
	Section BSS
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
Old_Stack_Adr		ds.l		1
BasePage				ds.l		1

Adr_Screen1			ds.l		1
Adr_Screen2			ds.l		1
	
Screens				ds.l		Screen_Size*Nbr_Screen/4+256

						ds.l		Stack_Size/4
Pile

