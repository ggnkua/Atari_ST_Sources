		; *********************************************************************
		;
		;      Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C
		;
		; Die VDI-Funktionen
		;
		; (c)1998 by Martin ElsÑsser
		; *********************************************************************
		
		; Der GEM-Dispatcher im ROM retten alle Register (lt. Profibuch ;-),
		; aber das muû nicht immer so sein! (wer weiû, was diverse Erweiterungen
		; wie dieses NVDI tun ;-)
		;
		; Pure-C mîchte D3-D7 und A2-A7 gerettet bekommen,
		; wir retten einfach alle Register, die nicht fÅr
		; RÅkgabewerte benîtigt werden

	_rsv EQU 5*4									; Anzahl der Byte, die fÅr das Retten der Register
														; auf dem Stack benîtigt werden (dies ist wichtig,
														; um die auf dem Stack Åbergebenen Parameter
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
		; void CDECL vdi( INT16 *contrl, INT16 *intin, INT16 *ptsin,
		;                 INT16 *intout, INT16 *ptsout );
		; ************************************************************
		
	EXPORT vdi
	MODULE vdi
		
		PCRegSave									; Register fÅr Pure-C retten
		
		; Der Parameterblock ist durch die öbergabe als CDECL bereits
		; auf dem Stack zusammengesetzt, das ist "etwas" multitasking-
		; freundlicher ;-)
		
		; Nun ab in's VDI!
		LEA _rsv+4(SP), A0						; Adresse des Parameterblockes auf dem Stack
		MOVE.L A0, D1								; Parameterblock in D1
		MOVE.L #$73, D0							; Das VDI bitte!
		TRAP #2										; => ab in's GEM
		
		PCRegLoad									; Register fÅr Pure-C reparieren
		MOVEQ #0, D0								; D0 initialiseren
		RTS											; ... und zurÅck
		
	ENDMOD
		
		; ************************************************************
		; void vdi_( VDIPB *vdipb );
		; ************************************************************
		
	EXPORT vdi_
	MODULE vdi_
		
		PCRegSave									; Register fÅr Pure-C retten
		
		; Nun ab in's VDI!
		MOVE.L A0, D1								; Parameterblock in D1
		MOVE.L #$73, D0							; Das VDI bitte!
		TRAP #2										; => ab in's GEM
		
		PCRegLoad									; Register fÅr Pure-C reparieren
		MOVEQ #0, D0								; D0 initialiseren
		RTS											; ... und zurÅck
		
	ENDMOD
		
		; ************************************************************
		; INT16 vq_gdos( void );
		; ************************************************************
		
	EXPORT vq_gdos
	MODULE vq_gdos
		
		PCRegSave									; Register fÅr Pure-C retten
		MOVE.W	#-2, D0							; Fragen, ob GDOS da ist
		TRAP 		#2									; => GEM-Dispatcher
		CMP.W		#-2, D0							; Ist GDOS da?
		SNE		D0									; Flag entsprechend setzen
		EXT.W		D0									; Von BYTE auf WORD erweitern
		PCRegLoad									; Register fÅr Pure-C reparieren
		RTS											; ... und zurÅck
		
	ENDMOD

