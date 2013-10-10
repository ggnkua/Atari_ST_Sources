		; ************************************************************
		;
		;           Eine handoptimierte Bibliothek fr Pure-C
		;
		; Die MiNTNet-Funktionen
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
		; int32 Faccept( int16 fd, struct sockaddr *name, socklen_t *namelen );		; ************************************************************
		
	EXPORT Faccept
	MODULE Faccept
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A1)					; namelen auf Stack
		PEA (A0)					; name auf Stack
		MOVE.W D0, -(SP)		; fd auf Stack
		GEMDOS $162, 12		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD

		; ************************************************************
		; int32 Fbind( int16 fd, const struct sockaddr *name, socklen_t namelen );		; ************************************************************
		
	EXPORT Fbind
	MODULE Fbind
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D1, -(SP)		; namelen auf Stack
		PEA (A0)					; name auf Stack
		MOVE.W D0, -(SP)		; fd auf Stack
		GEMDOS $164, 12		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD

		; ************************************************************
		; int32 Fconnect( int16 fd, const struct sockaddr *name, socklen_t namelen );		; ************************************************************
		
	EXPORT Fconnect
	MODULE Fconnect
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D1, -(SP)		; namelen auf Stack
		PEA (A0)					; name auf Stack
		MOVE.W D0, -(SP)		; fd auf Stack
		GEMDOS $163, 12		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD

		; ************************************************************
		; int32 Fgetpeername( int16 fd, struct sockaddr *addr, socklen_t *addrlen );		; ************************************************************
		
	EXPORT Fgetpeername
	MODULE Fgetpeername
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D1, -(SP)		; addrlen auf Stack
		PEA (A0)					; addr auf Stack
		MOVE.W D0, -(SP)		; fd auf Stack
		GEMDOS $16C, 12		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD

		; ************************************************************
		; int32 Fgetsockname( int16 fd, sockaddr *addr, socklen_t *addrlen );		; ************************************************************
		
	EXPORT Fgetsockname
	MODULE Fgetsockname
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D1, -(SP)		; addrlen auf Stack
		PEA (A0)					; addr auf Stack
		MOVE.W D0, -(SP)		; fd auf Stack
		GEMDOS $16D, 12		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD

		; ************************************************************
		; int32 Fgetsockopt( int16 fd, int32 level, int32 optname,
		;             void *optval, socklen_t *optlen );		; ************************************************************
		
	EXPORT Fgetsockopt
	MODULE Fgetsockopt
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A1)					; optlen auf Stack
		PEA (A0)					; optval auf Stack
		MOVE.L D2, -(SP)		; optname auf Stack
		MOVE.L D1, -(SP)		; level auf Stack
		MOVE.W D0, -(SP)		; fd auf Stack
		GEMDOS $16B, 20		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD

		; ************************************************************
		; int32 Flisten( int16 fd, int32 backlog );		; ************************************************************
		
	EXPORT Flisten
	MODULE Flisten
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D1, -(SP)		; backlog auf Stack
		MOVE.W D0, -(SP)		; fd auf Stack
		GEMDOS $165, 8			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD

		; ************************************************************
		; int32 Freadv( int16 fd, const iovec *iovp, ssize_t iovcnt);
		; ************************************************************
		
	EXPORT Freadv
	MODULE Freadv
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D1, -(SP)		; backlog auf Stack
		PEA (A0)					; iovp auf Stack
		MOVE.W D0, -(SP)		; fd auf Stack
		GEMDOS $15C, 12		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD

		; ************************************************************
		; int32 Frecvfrom( int16 fd, void *buf, ssize_t buflen, int32 flags,		;                  sockaddr *from, socklen_t *fromlen);		; ************************************************************
		
	EXPORT Frecvfrom
	MODULE Frecvfrom
		
		PCRegSave						; Register fr Pure-C retten
		MOVE.L _rsv+4(SP), -(SP)	; fromlen auf Stack
		PEA (A1)							; from auf Stack
		MOVE.L D2, -(SP)				; flags auf Stack
		MOVE.L D1, -(SP)				; buflen auf Stack
		PEA (A0)							; buf auf Stack
		MOVE.W D0, -(SP)				; fd auf Stack
		GEMDOS $168, 24				; => GEMDOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
	ENDMOD

		; ************************************************************
		; int32 Frecvmsg( int16 fd, msghdr *msg, int32 flags);
		; ************************************************************
		
	EXPORT Frecvmsg
	MODULE Frecvmsg
		
		PCRegSave						; Register fr Pure-C retten
		MOVE.L D1, -(SP)				; flags auf Stack
		PEA (A0)							; msg auf Stack
		MOVE.W D0, -(SP)				; fd auf Stack
		GEMDOS $166, 24				; => GEMDOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
	ENDMOD

		; ************************************************************
		; int32 Fsendmsg( int16 fd, const msghdr *msg, long flags);		; ************************************************************
		
	EXPORT Fsendmsg
	MODULE Fsendmsg
		
		PCRegSave						; Register fr Pure-C retten
		MOVE.L D1, -(SP)				; flags auf Stack
		PEA (A0)							; msg auf Stack
		MOVE.W D0, -(SP)				; fd auf Stack
		GEMDOS $167, 24				; => GEMDOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
	ENDMOD

		; ************************************************************
		; int32 Fsendto( int16 fd, const void *buf, ssize_t buflen, int32 flags,		;						const sockaddrPtr addr, socklen_t addrlen);		; ************************************************************
		
	EXPORT Fsendto
	MODULE Fsendto
		
		PCRegSave						; Register fr Pure-C retten
		MOVE.L _rsv+4(SP), -(SP)	; addrlen auf Stack
		PEA (A1)							; addr auf Stack
		MOVE.L D2, -(SP)				; flags auf Stack
		MOVE.L D1, -(SP)				; buflen auf Stack
		PEA (A0)							; buf auf Stack
		MOVE.W D0, -(SP)				; fd auf Stack
		GEMDOS $169, 24				; => GEMDOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
	ENDMOD

		; ************************************************************
		; int32 Fsetsockopt( int16 fd, int32 level, int32 optname,
		;							void *optval, socklen_t optlen);		; ************************************************************
		
	EXPORT Fsetsockopt
	MODULE Fsetsockopt
		
		PCRegSave						; Register fr Pure-C retten
		MOVE.L _rsv+4(SP), -(SP)	; optlen auf Stack
		PEA (A0)							; optval auf Stack
		MOVE.L D2, -(SP)				; optname auf Stack
		MOVE.L D1, -(SP)				; level auf Stack
		MOVE.W D0, -(SP)				; fd auf Stack
		GEMDOS $16A, 20				; => GEMDOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
	ENDMOD

		; ************************************************************
		; int32 Fshutdown( int16 fh, int32 how);		; ************************************************************
		
	EXPORT Fshutdown
	MODULE Fshutdown
		
		PCRegSave						; Register fr Pure-C retten
		MOVE.L D1, -(SP)				; how auf Stack
		MOVE.W D0, -(SP)				; fd auf Stack
		GEMDOS $16E, 8					; => GEMDOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
	ENDMOD

		; ************************************************************
		; int32 Fsocket( int32 domain, int32 type, int32 protocol);		; ************************************************************
		
	EXPORT Fsocket
	MODULE Fsocket
		
		PCRegSave						; Register fr Pure-C retten
		MOVE.L D2, -(SP)				; protocol auf Stack
		MOVE.L D1, -(SP)				; type auf Stack
		MOVE.W D0, -(SP)				; domain auf Stack
		GEMDOS $160, 14				; => GEMDOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
	ENDMOD

		; ************************************************************
		; int32 Fsocketpair( int32 domain, int32 type, int32 protocol, int16 rsv[2] );		; ************************************************************
		
	EXPORT Fsocketpair
	MODULE Fsocketpair
		
		PCRegSave						; Register fr Pure-C retten
		PEA (A0)							; rsv[2] auf Stack
		MOVE.L D2, -(SP)				; protocol auf Stack
		MOVE.L D1, -(SP)				; type auf Stack
		MOVE.W D0, -(SP)				; domain auf Stack
		GEMDOS $161, 18				; => GEMDOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
	ENDMOD

		; ************************************************************
		; int32 Fwritev( int16 fd, const iovec *iov, ssize_t niov );		; ************************************************************
		
	EXPORT Fwritev
	MODULE Fwritev
		
		PCRegSave						; Register fr Pure-C retten
		MOVE.L D1, -(SP)				; niov auf Stack
		PEA (A0)							; iov auf Stack
		MOVE.W D0, -(SP)				; fd auf Stack
		GEMDOS $15B, 12				; => GEMDOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
	ENDMOD
