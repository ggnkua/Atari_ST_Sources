		; ************************************************************
		;
		;           Eine handoptimierte Bibliothek fr Pure-C
		;
		; Die PAMsNet-Funktionen
		;
		; (c)1998-2004 by Martin Els„sser
		; ************************************************************

		; Als Makro mit Stack-Reparatur die GEMDOS-Aufrufe
	MACRO GEMDOS Nr, AddStack
		
		MOVE.W #Nr, -(SP)	; Fkt.-Nr auf Stack
		TRAP #1				; GEMDOS aufrufen
		
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
		
		; Die Register D3-D7 und A3-A7 werden vom GEMDOS-Dispatcher
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
		; INT16 Nactive( void );
		; ************************************************************
		
	EXPORT Nactive
	MODULE Nactive
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $7F, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Ndisable( void );
		; ************************************************************
		
	EXPORT Ndisable
	MODULE Ndisable
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $74, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Nenable( void );
		; ************************************************************
		
	EXPORT Nenable
	MODULE Nenable
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $73, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Nlock( const char *file );
		; ************************************************************
		
	EXPORT Nlock
	MODULE Nlock
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; file auf Stack
		GEMDOS $7C, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Nlocked( void );
		; ************************************************************
		
	EXPORT Nlocked
	MODULE Nlocked
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $7A, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Nlogged( INT16 nn );
		; ************************************************************
		
	EXPORT Nlogged
	MODULE Nlogged
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; nn auf Stack
		GEMDOS $7D, 4			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Nmsg( INT16 rw, char *buf, char *id,
		;             INT16 node, INT16 leng );
		; ************************************************************
		
	EXPORT Nmsg
	MODULE Nmsg
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D2, -(SP)		; leng auf Stack
		MOVE.W D1, -(SP)		; node auf Stack
		PEA (A1)					; id auf Stack
		PEA (A0)					; buf auf Stack
		MOVE.W D0, -(SP)		; rw auf Stack
		GEMDOS $76, 16			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Nnodeid( void );
		; ************************************************************
		
	EXPORT Nnodeid
	MODULE Nnodeid
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $7E, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Nprinter( int nn, int kopf, int dd );
		; ************************************************************
		
	EXPORT Nprinter
	MODULE Nprinter
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L _rsv+4(SP), -(SP)	; leng auf Stack
		MOVE.L D2, -(SP)		; dd auf Stack
		MOVE.W D1, -(SP)		; kopf auf Stack
		MOVE.W D0, -(SP)		; nn auf Stack
		GEMDOS $79, 8			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Nrecord( INT16 handle, INT16 mm, INT32 offset, INT32 leng );
		; ************************************************************
		
	EXPORT Nrecord
	MODULE Nrecord
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L _rsv+4(SP), -(SP)	; leng auf Stack
		MOVE.L D2, -(SP)		; offset auf Stack
		MOVE.W D1, -(SP)		; mm auf Stack
		MOVE.W D0, -(SP)		; handle auf Stack
		GEMDOS $77, 14			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Nremote( INT16 nn );
		; ************************************************************
		
	EXPORT Nremote
	MODULE Nremote
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; nn auf Stack
		GEMDOS $75, 4			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Nreset( void );
		; ************************************************************
		
	EXPORT Nreset
	MODULE Nreset
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $78, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Nunlock( const char *file );
		; ************************************************************
		
	EXPORT Nunlock
	MODULE Nunlock
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; file auf Stack
		GEMDOS $7B, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Nversion( void );
		; ************************************************************
		
	EXPORT Nversion
	MODULE Nversion
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $60, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		