		; *********************************************************************
		;
		;      Eine handoptimierte Bibliothek fr Pure-C, Pure-Pascal und GNU-C
		;
		; Die VDI-Funktionen
		;
		; (c)1998 by Martin Els„sser
		; *********************************************************************
		
		; Der GEM-Dispatcher im ROM retten alle Register (lt. Profibuch ;-),
		; aber das mu nicht immer so sein! (wer wei, was diverse Erweiterungen
		; wie dieses NVDI tun ;-)
		;
		; Pure-C m”chte D3-D7 und A2-A7 gerettet bekommen,
		; wir retten einfach alle Register, die nicht fr
		; Rkgabewerte ben”tigt werden

	_rsv EQU 5*4									; Anzahl der Byte, die fr das Retten der Register
														; auf dem Stack ben”tigt werden (dies ist wichtig,
														; um die auf dem Stack bergebenen Parameter
														; wieder zu finden ;-)
		
		; ------------------------------------------------------------
				
	MACRO PCRegSave
		
		MOVEM.L D1-D2/A0-A2, -(SP)				; Register retten
		
	ENDM

		; ------------------------------------------------------------
	
	MACRO PCRegLoad
		
		MOVEM.L (SP)+, D1-D2/A0-A2				; Register reparieren
		
	ENDM

		; ************************************************************
		; void CDECL vdi_( INT16 *contrl, INT16 *intin, INT16 *ptsin,
		;                  INT16 *intout, INT16 *ptsout );
		; ************************************************************
		
	EXPORT vdi_
	MODULE vdi_
		
		PCRegSave									; Register fr Pure-C retten
		
		; Der Parameterblock ist durch die šbergabe als CDECL bereits
		; auf dem Stack zusammengesetzt, das ist "etwas" multitasking-
		; freundlicher ;-)
		
		; Nun ab in's VDI!
		LEA _rsv+4(SP), A0						; Adresse des Parameterblockes auf dem Stack
		MOVE.L A0, D1								; Parameterblock in D1
		MOVE.L #$73, D0							; Das VDI bitte!
		TRAP #2										; => ab in's GEM
		
		PCRegLoad									; Register fr Pure-C reparieren
		MOVEQ #0, D0								; D0 initialiseren
		RTS											; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void vdi( VDIPB *vdipb );
		; ************************************************************
		
	EXPORT vdi
	MODULE vdi
		
		PCRegSave									; Register fr Pure-C retten
		
		; Nun ab in's VDI!
		MOVE.L A0, D1								; Parameterblock in D1
		MOVE.L #$73, D0							; Das VDI bitte!
		TRAP #2										; => ab in's GEM
		
		PCRegLoad									; Register fr Pure-C reparieren
		MOVEQ #0, D0								; D0 initialiseren
		RTS											; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 vq_gdos( void );
		; ************************************************************
		
	EXPORT vq_gdos
	MODULE vq_gdos
		
		PCRegSave									; Register fr Pure-C retten
		MOVE.W	#-2, D0							; Fragen, ob GDOS da ist
		TRAP 		#2									; => GEM-Dispatcher
		CMP.W		#-2, D0							; Ist GDOS da?
		SNE		D0									; Flag entsprechend setzen
		EXT.W		D0									; Von BYTE auf WORD erweitern
		PCRegLoad									; Register fr Pure-C reparieren
		RTS											; ... und zurck
		
	ENDMOD

		; ************************************************************
		; INT16 vq_vgdos( void );
		; ************************************************************
		
	EXPORT vq_vgdos
	MODULE vq_vgdos
		
		PCRegSave									; Register fr Pure-C retten
		MOVE.W	#-2, D0							; Fragen, ob GDOS da ist
		TRAP 		#2									; => GEM-Dispatcher
		PCRegLoad									; Register fr Pure-C reparieren
		RTS											; ... und zurck
		
	ENDMOD

