; Macros de communication avec le DSP

; Macro d'envoi et de r‚ception de donn‚es (DSP)
; \1 est un registre d'adresse initialis‚ … $ffffa200.w
; \3 est un flag qui force ou non le handshaking
SEND_DSP	macro
	IF	\?3
	  IFNE	\3
	    btst	#1,2(\1)
	    beq.s	*-6
	  ENDC
	ENDIF
	IFC	'\0','L'
	  move.l	\2,4(\1)
	ELSE
	  IFC	'\0','B'
	    move.b	\2,7(\1)
	  ELSE
	    move.w	\2,6(\1)
	  ENDC
	ENDC
	endm

RECEIVE_DSP	macro
	IF	\?3
	  IFNE	\3
	    btst	#0,2(\1)
	    beq.s	*-6
	  ENDC
	ENDIF
	IFC	'\0','L'
	  move.l	4(\1),\2
	ELSE
	  IFC	'\0','B'
	    move.b	7(\1),\2
	  ELSE
	    move.w	6(\1),\2
	  ENDC
	ENDC
	endm

WAIT_DSP	macro
	btst	#\2,2(\1)
	beq.s	*-6
	endm
