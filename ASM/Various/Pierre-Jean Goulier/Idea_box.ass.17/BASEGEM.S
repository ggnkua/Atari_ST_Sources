;
; Initialisation de base pour un programme GEM.
; Assembleur : DEVPAC Ω HiSoft
; A assembler en PRG ou en ACC. Pour utiliser le programme
; indiffÇremment en ACC ou en PRG, l'assembler en ACC.
;
; Programmation : P-Jean Goulier.
; Ω Start Micro & P-Jean Goulier / 1994.
	
type	equ	1			; 1 pour .PRG, 0 pour .ACC

	ifeq	type			; Si type = 0, sortie Ö l'assemblage en ACC.
	output	.acc
	elseif
	output	.prg
	endc

	include	gemmacro.s
	include	macrosys.s
	include	utiles.s

	ifeq	type			; Si ACC, on place une nouvelle pile
start	move.l	#pile,a7		; et c'est tout...
	elseif
start	init_prg #4096			; Sinon, on initialise le programme en
	endc				; en prÇparant la mÇmoire + 4 Ko de pile.
	
	appl_init			; On initialise l'AES.
	move.w	d0,ap_id		; On sauve l'ap_id.
	
	graf_handle			; Quel handle pour l'Çcran ?
	move.w	d0,v_handle		; On le sauve pour l'ouverture de la station
					; virtuelle et les fonctions VDI...
					; (v_handle est dÇclarÇ dans VDILIB.S)
					
	lea	intin,a0		; Ouverture d'une station virtuelle.
	moveq	#9,d0
.loop:	move.w	#1,(a0)+
	dbf	d0,.loop
	move.w	#2,(a0)+
	v_opnvwk
	
	ifeq	type			; Assemblage conditionnel pour un ACC.
	move	ap_id,d0		; Est-ce un ACC renommÇ en PRG ?
	beq.s	prog			; si ap_id = 0 => c'est un PRG !
	menu_register ap_id,#acc_name	; on met son nom au menu.
	move	int_out,acc_id		; On sauve l'acc_id.
	
evnt_gem:
	evnt_mesag #buffer		; Gestion des Çvänements.
	move.l	#buffer,a0
	move	(a0),d0
	cmp	#40,d0			; Un accessoire choisi ?
	bne.s	evnt_gem		; Non, retour.
	move	8(a0),d0
	cmp	acc_id,d0		; Est-ce le nìtre ?
	bne.s	evnt_gem		; Non, retour.
	jsr	program			; Oui, on saute au programme.
	bra.s	evnt_gem		; On boucle...
	endc
	
prog:					; Si c'est un programme,
	graf_mouse #0			; Une belle souris...
	jsr program			; On y va...
	v_clsvwk			; On ferme la workstation,
	appl_exit			; et on retourne au bureau.
	pterm	#0

***************************************************************************
*                           Programme principal
***************************************************************************

program:

					; Votre programme principal
					; doit se loger ici, et se terminer
					; par un RTS.
					
					
	rts
	

	section data


	section bss

ap_id:	ds.w	1
acc_id:	ds.w	1
buffer:	ds.b	16

	ifeq	type
	ds.l	1023			; Notre pile de 4 Ko si ACC.
pile:	ds.l	1			; (1024+1)*4=4096
	endc


	ifeq	__LK			; Si c'est du code exÇcutable,
	include	aeslib.s		; inclure les bibliothäques AES et VDI.
	include vdilib.s
	endc
