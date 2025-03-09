************************************************
*
*		Click.S											fÅr Clicker.ACC
*
*		written 1992 by Uli
*
************************************************

			EXPORT	asm_init
			EXPORT	asm_click

************************************************
*
*	Sucht die Adresse der Mausroutine
*

asm_init:
	movem.l	d0-a6,-(sp)
	
	move.w	#34,-(sp)			; Kbdvbase()
	trap	#14
	addq.l	#2,sp
	
	add.l	#16,d0					; KBDVECS.mousevec
	move.l	d0,mouse_vec	; -> mouse_vec
	
	pea		asm_init_2			; Supexec(asm_init_2)
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	
	movem.l	(sp)+,d0-a6
	rts

asm_init_2:
	lea		mouse_adr,a0		; Adr. der Mausroutine
	move.l	mouse_vec,a2	; -> mouse_adr
	move.l	(a2),(a0)
	
	rts

************************************************
*
*	Simuliert einen Mausklick der linke Taste
*	an der aktuelle Position
*
*	Aufruf durch Supexec(asm_click)
*

asm_click:
	movem.l	d0-a6,-(sp)
	move.w	sr,-(sp)
	ori		#$700,sr				; bitte nicht stîren
	
	move.l	mouse_adr,a2	; Taste drÅcken
	lea		druecken,a0
	jsr		(a2)
	
	move.l	mouse_adr,a2	; Taste loslassen
	lea		loslassen,a0
	jsr		(a2)
	
	move.w	(sp)+,sr
	movem.l	(sp)+,d0-a6
	rts

************************************************

			DATA

druecken:
			DC.B	$FA,0,0		; Mauspaket 'DrÅcken'
			EVEN
loslassen:
			DC.B	$F8,0,0		; Mauspaket 'Loslassen'
			EVEN
mouse_vec:
			DC.L	0					; Vektor auf Mausroutine
mouse_adr:
			DC.L	0					; Adresse der Mausroutine

			END

************************************************
