;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Macros pour acc‚der aux ports Host & SSI en polling ;;;;;;;;;;;;;;;
ReadHost	MACRO	dest
	jclr	#M_HRDF,x:<<M_HSR,*
	movep	x:<<M_HRX,dest
	ENDM

WritHost	MACRO	srce
	jclr	#M_HTDE,x:<<M_HSR,*
	movep	srce,x:<<M_HTX
	ENDM

ReadSSI	MACRO	dest
	jclr	#M_RDF,x:<<M_SR,*
	movep	x:<<M_RX,dest
	ENDM

WritSSI	MACRO	srce
	jclr	#M_TDE,x:<<M_SR,*
	movep	srce,x:<<M_TX
	ENDM

