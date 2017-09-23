		; ************************************************************
		;
		;           Eine handoptimierte Bibliothek fr Pure-C
		;
		; Die BIOS-Funktionen
		;
		; (c)1998-2004 by Martin Els„sser
		; ************************************************************

		; Als Makro mit Stack-Reparatur die BIOS-Aufrufe
	MACRO BIOS Nr, AddStack
		
		MOVE.W #Nr, -(SP)		; Fkt.-Nr auf Stack
		TRAP #13					; BIOS aufrufen
		
		; Stack reparieren, wenn es geht per ADDQ, sonst per LEA
		IF AddStack>1
			IF AddStack<=8
				ADDQ.L #AddStack, SP
			else
				LEA AddStack(SP), SP
			endif
		else
			LEA AddStack(SP), SP
		endif
		
	ENDM
	
		; ------------------------------------------------------------
		
		; Die Register D3-D7 und A3-A7 werden vom BIOS-Dispatcher
		; gerettet, Pure-C m”chte D3-D7 und A2-A7 gerettet bekommen
		; => A2 mu gerettet werden!
_rsv EQU 4
		
	MACRO PCRegSave
		
		PEA (A2)					; Register retten
		
	ENDM

		; ------------------------------------------------------------
	
	MACRO PCRegLoad
		
		MOVEA.L (SP)+, A2		; Register reparieren
		
	ENDM

		; ************************************************************
		; INT32 bios( INT16 fkt_nr, ... );
		; ************************************************************
		
	EXPORT bios
	MODULE bios
		
		MOVE.L save_ptr, A0	; Stand der "Save-Area" laden
		MOVE.L (SP)+, -(A0)	; Return-Adresse retten
		MOVE.L A2, -(A0)		; Register A2 fr Pure-C retten
		MOVE.L A0, save_ptr	; Stand der "Save-Area" merken
		MOVE.W D0, -(SP)		; Fkt.Nr. auf Stack
		TRAP #13					; BIOS aufrufen
		ADDQ.L #2, SP			; Fkt.Nr. vom Stack r„umen
		MOVE.L save_ptr, A0	; Stand der "Save-Area" laden
		MOVEA.L (A0)+, A2		; Register A2 restaurieren
		MOVE.L (A0)+, -(SP)	; Return-Adresse wieder ablegen
		MOVE.L A0, save_ptr	; Stand der "Save-Area" merken
		RTS
		
		BSS
save_a2_pc:
		DS.L 2*10
save_end:
		DATA
save_ptr:
		DC.L	save_end
		TEXT
		
	ENDMOD

		; ************************************************************
		; INT32 Bconin( INT16 dev );
		; ************************************************************
		
	EXPORT Bconin
	MODULE Bconin
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; dev auf Stack
		BIOS 2, 4				; => BIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Bconout( INT16 dev, INT16 c );
		; ************************************************************
		
	EXPORT Bconout
	MODULE Bconout
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; c auf Stack
		MOVE.W D0, -(sp)		; dev auf Stack
		BIOS 3, 6				; => BIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Bconstat( INT16 dev );
		; ************************************************************
		
	EXPORT Bconstat
	MODULE Bconstat
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; dev auf Stack
		BIOS 1, 4				; => BIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; Und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Bcostat( INT16 dev );
		; ************************************************************
		
	EXPORT Bcostat
	MODULE Bcostat
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; dev auf Stack
		BIOS 8, 4				; => BIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Drvmap( void );
		; ************************************************************
		
	EXPORT Drvmap
	MODULE Drvmap
		
		PCRegSave				; Register fr Pure-C retten
		BIOS $A, 2				; => BIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; BPB *Getbpb( INT16 dev );
		; ************************************************************
		
	EXPORT Getbpb
	MODULE Getbpb
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; dev auf Stack
		BIOS 7, 4				; => BIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		MOVEA.L D0, A0			; Wert als Zeiger liefern
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Getmpb( MPB *p_mpb );
		; ************************************************************
		
	EXPORT Getmpb
	MODULE Getmpb
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; p_mpb auf Stack
		BIOS 0, 6				; => BIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Kbshift( INT16 mode );
		; ************************************************************
		
	EXPORT Kbshift
	MODULE Kbshift
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; mode auf Stack
		BIOS $B, 4				; => BIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Mediach( INT16 dev );
		; ************************************************************
		
	EXPORT Mediach
	MODULE Mediach
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; dev auf Stack
		BIOS 9, 4				; => BIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Rwabs( INT16 rwflag, VOID *buf, INT16 count, INT16 recno,
		;             INT16 dev, INT32 lrecno )
		; ************************************************************
	
	EXPORT Rwabs
	MODULE Rwabs
		
		PCRegSave						; Register fr Pure-C retten
		MOVE.L _rsv+6(SP), -(SP)	; lrecno auf Stack
		MOVE.W _rsv+8(SP), -(SP)	; dev auf Stack
		MOVE.W D2, -(SP)			   ; reno auf Stack
		MOVE.W D1, -(SP)				; count auf Stack
		PEA (A0)							; buf auf Stack
		MOVE.W D0, -(SP)				; rwflag auf Stack
		BIOS 4, 18						; => BIOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Setexc( INT16 vecnum, void (*vec)(void) );
		; ************************************************************
		
	EXPORT Setexc
	MODULE Setexc
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; vec auf Stack
		MOVE.W D0, -(SP)		; vecnum auf Stack
		BIOS 5, 8				; => BIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		MOVEA.L D0, A0			; Wert auch als Zeiger liefern
		RTS
		
	ENDMOD
		
		; ************************************************************
		; INT32 Tickcal( void )
		; ************************************************************
		
	EXPORT Tickcal
	MODULE Tickcal
		
		PCRegSave				; Register fr Pure-C retten
		BIOS 6, 2				; => BIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		