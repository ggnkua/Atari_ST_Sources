; ALLGEIMEINGšLTIGE MAKROS.
; Started 1993 by BDCannibal/AURA aka Jochen Knaus.

;	     /============\
; ========= HOSTHANDLING ===========
;	     \============/

; "periphal.asm" MUž eingebunden sein.

TX_HOST	MACRO	adr_mode		; Macro zum Senden an den
		jclr	#1,X:<<HSR,*		; Host. Beliebige Adressier-
		movep	adr_mode,X:<<HTX	; ungsart (aužer L) erlaubt.
		ENDM

RX_HOST	MACRO	adr_mode		; Macro zum Empfangen vom
		jclr	#0,X:<<HSR,*		; Host, Para. ~ TX_HOST
		movep	X:<<HRX,adr_mode
		ENDM

TX_PNT2Di	MACRO	adr_reg			; 2D-Punkt schicken, (adr_reg)++
		TX_HOST	X:(adr_reg)
		TX_HOST	Y:(adr_reg)+
		ENDM

RX_PNT2Di	MACRO	adr_reg			; 2D-Punkt holen, (adr_reg)++
		RX_HOST	X:(adr_reg)
		RX_HOST	Y:(adr_reg)+
		ENDM

TX_PNT3D	MACRO	adr_reg			; 3D-Punkt schicken, [adr_reg] fest.
		TX_HOST	X:(adr_reg)
		TX_HOST	Y:(adr_reg)+
		TX_HOST	X:(adr_reg)-
		ENDM

TX_PNT3Di	MACRO	adr_reg			; 3D-Punkt schicken, (adr_reg)++
		TX_HOST	X:(adr_reg)
		TX_HOST	Y:(adr_reg)+
		TX_HOST	X:(adr_reg)+
		ENDM

RX_PNT3D	MACRO	adr_reg			; 3D-Punkt holen, [adr] unver„ndert.
		RX_HOST	X:(adr_reg)
		RX_HOST	Y:(adr_reg)+
		RX_HOST	X:(adr_reg)-
		ENDM

RX_PNT3Di	MACRO	adr_reg			; 3D-Punkt holen, (adr_reg)++
		RX_HOST	X:(adr_reg)
		RX_HOST	Y:(adr_reg)+
		RX_HOST	X:(adr_reg)+
		ENDM