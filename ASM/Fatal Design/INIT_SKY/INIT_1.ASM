;*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*
;*                                     *
;*  Initialisation pour les programmes *
;*  Gem ou Tos (partie DSP)            *
;*                                     *
;*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*
;*  Par Skynet From Fatal Design       *
;*  BAUMANN Loic                       *
;*  72, Rue du dauphine                *
;*  69003 Lyon                         *
;*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*:*

PBC		equ		$ffe0												; Port B Control Register
HSR		equ		$ffe9												; Host Status Register
HRX		equ		$ffeb												; Host Receive Register
HTX		equ		$ffeb												; Host Transmit Register
HRDF		equ		0													; Host Receive Data Full
HTDE		equ		1													; Host Transmit Data Empty

Host_Send_Data		Macro		Data
_Host_Request
		jclr		#<HTDE,X:<<HSR,_Host_Request			; On attend la dispo du port Host
		movep		Data,X:<<HTX								; On transfert la valeur sp‚cifi‚e
	EndM

Host_Get_Data		Macro		Data
_Host_Request
		jclr		#<HRDF,X:<<HSR,_Host_Request			
		movep		X:<<HRX,Data								
	EndM

;********************
;*      DEBUT       *
;********************

		ORG		P:0
	
		jmp		Start

		ORG		P:$40

Start	
	movep	#1,X:<<PBC									; Port B en Host

; Pour v‚rifier la connexion
Conct_Get	
	Host_Get_Data		x0
	move		#>$4321,A								; Valeur qui doit normalement se trouver dans x0
	cmp		x0,A										; On compare le Magic Number
	jne		Conct_Get								; C pas le bon, on reboucle
	Host_Send_Data		#12345678


Synchro_VBL												; Routine synchro VBL
	Host_Get_Data		x0
	move		#>$1213,A
	cmp		x0,A
	Jne		Synchro_VBL

	nop
	nop
	nop

	Jmp		Synchro_VBL


;******************************************************************************************
	Org	X:$100

;******************************************************************************************
	ORG	Y:$100


