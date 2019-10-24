;***************************************************************************
;       Petit Exemple de Communication 68030-DSP
;       Programme DSP
;***************************************************************************

	org	p:$0			; Vecteur RESET
	jmp	>Start

	org	p:$40			; Debut de la RAM
Start

Get_From_68030
	jclr	#<0,X:<<$FFE9,Get_From_68030	
	movep	X:<<$FFEB,x0

;***************************************************************************
; on pourrait mettre   jclr #<0,X:<<$FFE9,*   pour eviter les labels
; mˆme effet           jclr #<1,X:<<$FFE9,*   … la longue ‡a peut ˆtre utile
;***************************************************************************

Send_to_68030
	jclr	#<1,X:<<$FFE9,Send_to_68030
	movep	#12345678,X:<<$FFEB


Null	jmp	<Null			; Boucle infinie
