*********************************************
***** Appels par macro des inits du TOS *****
*********************************************
*** Initialisation du GEMDOS ***

GEMDOSinit		macro	; stack_size
	text
	XREF		GEMDOSinit_START
	jmp		GEMDOSinit_START
	XDEF		GEMDOSinit_END
GEMDOSinit_END
	XDEF		stack_end,stack_start
	XDEF		ligne_de_commande_adr,base_page_adr
	bss
base_page_adr		ds.l	1
ligne_de_commande_adr	ds.l	1
stack_end		ds.b	\1
stack_start		even
	text
	endm

*** Initialisation de la VDI et de l'AES ***

AESVDIinit	macro
	XREF	AESVDIinit_START
	jmp	AESVDIinit_START
	XDEF	AESVDIinit_END
AESVDIinit_END
	endm

*** Initialisation TOS (GEMDOS + AES/VDI) ***
TOSinit		macro		; stack_size
		GEMDOSinit	\1
		AESVDIinit
		endm
