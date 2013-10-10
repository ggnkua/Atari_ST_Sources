		; ************************************************************
		;
		;           Eine handoptimierte Bibliothek fr Pure-C
		;
		; Die GEMDOS-Funktionen
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
		; INT32 gemdos( INT16 fkt_nr, ... );
		; ************************************************************
		
	EXPORT gemdos
	MODULE gemdos
		
		MOVE.L save_ptr, A0	; Stand der "Save-Area" laden
		MOVE.L (SP)+, -(A0)	; Return-Adresse retten
		MOVE.L A2, -(A0)		; Register A2 fr Pure-C retten
		MOVE.L A0, save_ptr	; Stand der "Save-Area" merken
		MOVE.W D0, -(SP)		; Fkt.Nr. auf Stack
		TRAP #1					; GEMDOS aufrufen
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
		; INT16 Cauxin( void );
		; ************************************************************
		
	EXPORT Cauxin
	MODULE Cauxin
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS 3, 2				; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Cauxis( void );
		; ************************************************************
		
	EXPORT Cauxis
	MODULE Cauxis
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $12, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Cauxos( void );
		; ************************************************************
		
	EXPORT Cauxos
	MODULE Cauxos
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $13, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Cauxout( INT16 c );
		; ************************************************************
		
	EXPORT Cauxout
	MODULE Cauxout
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; c auf Stack
		GEMDOS 4, 4				; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Cconin( void );
		; ************************************************************
		
	EXPORT Cconin
	MODULE Cconin
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS 1, 2				; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Cconis( void );
		; ************************************************************
		
	EXPORT Cconis
	MODULE Cconis
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $B, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Cconos( void );
		; ************************************************************
		
	EXPORT Cconos
	MODULE Cconos
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $10, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Cconout( INT16 c );
		; ************************************************************
		
	EXPORT Cconout
	MODULE Cconout
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; c auf Stack
		GEMDOS 2, 4				; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Cconrs( LINE *buf );
		; ************************************************************
		
	EXPORT Cconrs
	MODULE Cconrs
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; str auf Stack
		GEMDOS $A, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Cconws( char *str );
		; ************************************************************
		
	EXPORT Cconws
	MODULE Cconws
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; str auf Stack
		GEMDOS 9, 6				; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Cnecin( void );
		; ************************************************************
		
	EXPORT Cnecin
	MODULE Cnecin
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS 8, 2				; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Cprnos( void );
		; ************************************************************
		
	EXPORT Cprnos
	MODULE Cprnos
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $11, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Cprnout( INT16 c );
		; ************************************************************
		
	EXPORT Cprnout
	MODULE Cprnout
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; c auf Stack
		GEMDOS 5, 4				; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Crawcin( void );
		; ************************************************************
		
	EXPORT Crawcin
	MODULE Crawcin
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS 7, 2				; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Crawio( INT16 c );
		; ************************************************************
		
	EXPORT Crawio
	MODULE Crawio
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; c auf Stack
		GEMDOS 6, 4				; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Dclosedir( INT32 dirhandle );
		; ************************************************************
		
	EXPORT Dclosedir
	MODULE Dclosedir
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D0, -(SP)		; dirhandle auf Stack
		GEMDOS $12B, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Dcntl( INT16 cmd, char *name, INT32 arg );
		; ************************************************************
		
	EXPORT Dcntl
	MODULE Dcntl
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D1, -(SP)		; arg auf Stack
		PEA (A0)					; name auf Stack
		MOVE.W D0, -(SP)		; cmd auf Stack
		GEMDOS $130, 12		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Dcreate( char *path );
		; ************************************************************
		
	EXPORT Dcreate
	MODULE Dcreate
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; path auf Stack
		GEMDOS $39, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Ddelete( char *path );
		; ************************************************************
		
	EXPORT Ddelete
	MODULE Ddelete
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; path auf Stack
		GEMDOS $3A, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Dfree( DISKINFO *buf, INT16 drive );
		; ************************************************************
		
	EXPORT Dfree
	MODULE Dfree
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; drive auf Stack
		PEA (A0)					; buf auf Stack
		GEMDOS $36, 8			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Dgetcwd( char *path, INT16 drv, INT16 size );
		; ************************************************************
		
	EXPORT Dgetcwd
	MODULE Dgetcwd
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; size auf Stack
		MOVE.W D0, -(SP)		; drv auf Stack
		PEA (A0)					; path auf Stack
		GEMDOS $13B, 10		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Dgetdrv( void );
		; ************************************************************
		
	EXPORT Dgetdrv
	MODULE Dgetdrv
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $19, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Dgetpath( char *buf, INT16 drive );
		; ************************************************************
		
	EXPORT Dgetpath
	MODULE Dgetpath
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; drive auf Stack
		PEA (A0)					; buf auf Stack
		GEMDOS $47, 8			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Dlock( INT16 mode, INT16 drv );
		; ************************************************************
		
	EXPORT Dlock
	MODULE Dlock
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; drv auf Stack
		MOVE.W D0, -(SP)		; mode auf Stack
		GEMDOS $135, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Dopendir( char *name, INT16 flag );
		; ************************************************************
		
	EXPORT Dopendir
	MODULE Dopendir
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; flag auf Stack
		PEA (A0)					; name auf Stack
		GEMDOS $128, 8			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Dpathconf( char *name, INT16 mode );
		; ************************************************************
		
	EXPORT Dpathconf
	MODULE Dpathconf
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; mode auf Stack
		PEA (A0)					; name auf Stack
		GEMDOS $124, 8			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Dreaddir( INT16 len, INT32 dirhandle, char *buf );
		; ************************************************************
		
	EXPORT Dreaddir
	MODULE Dreaddir
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; buf auf Stack
		MOVE.L D1, -(SP)		; dirhandle auf Stack
		MOVE.W D0, -(SP)		; len auf Stack
		GEMDOS $129, 12		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Dreadlabel( const char *path, char *label,
		;                   INT16 maxlen );
		; ************************************************************
		
	EXPORT Dreadlabel
	MODULE Dreadlabel
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; maxlen auf Stack
		PEA (A1)					; label auf Stack
		PEA (A0)					; path auf Stack
		GEMDOS $152, 12		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Dwritelabel( const char *path, const char *label );
		; ************************************************************
		
	EXPORT Dwritelabel
	MODULE Dwritelabel
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A1)					; label auf Stack
		PEA (A0)					; path auf Stack
		GEMDOS $153, 10		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Dxreaddir( INT16 buflen, INT32 dir, char *buf,
		;                  XATTR *xbuf, INT32 *xr );
		; ************************************************************
		
	EXPORT Dxreaddir
	MODULE Dxreaddir
		
		PCRegSave						; Register fr Pure-C retten
		MOVE.L _rsv+4(SP), -(SP)	; xr auf Stack
		PEA (A1)							; xbuf auf Stack
		PEA (A0)							; buf auf Stack
		MOVE.L D1, -(SP)				; dirhandle auf Stack
		MOVE.W D0, -(SP)				; len auf Stack
		GEMDOS $142, 20				; => GEMDOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Drewinddir( INT32 handle );
		; ************************************************************
		
	EXPORT Drewinddir
	MODULE Drewinddir
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D0, -(SP)		; handle auf Stack
		GEMDOS $12A, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Dsetdrv( INT16 drive );
		; ************************************************************
		
	EXPORT Dsetdrv
	MODULE Dsetdrv
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; drive auf Stack
		GEMDOS $E, 4			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Dsetpath( char *path );
		; ************************************************************
		
	EXPORT Dsetpath
	MODULE Dsetpath
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; path auf Stack
		GEMDOS $3B, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 F_lock( INT16 handle, INT32 count );
		; ************************************************************
		
	EXPORT F_lock
	MODULE F_lock
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D1, -(SP)		; count auf Stack
		MOVE.W D0, -(SP)		; handle auf Stack
		GEMDOS $64, 8			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Fattrib( char *fname, INT16 flag, INT16 attr );
		; ************************************************************
		
	EXPORT Fattrib
	MODULE Fattrib
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; attr auf Stack
		MOVE.W D0, -(SP)		; flag auf Stack
		PEA (A0)					; fname auf Stack
		GEMDOS $43, 10			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Fchmod( char *name, INT16 mode );
		; ************************************************************
		
	EXPORT Fchmod
	MODULE Fchmod
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; mode auf Stack
		PEA (A0)					; name auf Stack
		GEMDOS $132, 8			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Fchown( char *name, INT16 uid, INT16 gid );
		; ************************************************************
		
	EXPORT Fchown
	MODULE Fchown
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; gid auf Stack
		MOVE.W D0, -(SP)		; uid auf Stack
		PEA (A0)					; name auf Stack
		GEMDOS $131, 10		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Fclose( INT16 handle );
		; ************************************************************
		
	EXPORT Fclose
	MODULE Fclose
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; handle auf Stack
		GEMDOS $3E, 4			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Fcntl( INT16 handle, INT32 arg, INT16 cmd );
		; ************************************************************
		
	EXPORT Fcntl
	MODULE Fcntl
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D2, -(SP)		; cmd auf Stack
		MOVE.L D1, -(SP)		; arg auf Stack
		MOVE.W D0, -(SP)		; handle auf Stack
		GEMDOS $104, 10		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Fcreate( char *fname, INT16 attr );
		; ************************************************************
		
	EXPORT Fcreate
	MODULE Fcreate
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; attr auf Stack
		PEA (A0)					; fname auf Stack
		GEMDOS $3C, 8			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; ACSTOS:
		; INT32 Fdatime( DATETIME *timeptr, INT16 handle, INT16 flag );
		;
		; PCTOSLIB:
		; INT32 Fdatime( DOSTIME *timeptr, INT16 handle, INT16 flag );
		; ************************************************************
		
	EXPORT Fdatime
	MODULE Fdatime
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; flag auf Stack
		MOVE.W D0, -(SP)		; handle auf Stack
		PEA (A0)					; timeptr auf Stack
		GEMDOS $57, 10			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Fdelete( char *fname );
		; ************************************************************
		
	EXPORT Fdelete
	MODULE Fdelete
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; fname auf Stack
		GEMDOS $41, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Fdup( INT16 shandle );
		; ************************************************************
		
	EXPORT Fdup
	MODULE Fdup
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; shandle auf Stack
		GEMDOS $45, 4			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Fflush( INT16 handle );
		; ************************************************************
		
	EXPORT Fflush
	MODULE Fflush
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; handle auf Stack
		GEMDOS $66, 4			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Fforce( INT16 shandle, INT16 nhandle );
		; ************************************************************
		
	EXPORT Fforce
	MODULE Fforce
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; nhandle auf Stack
		MOVE.W D0, -(SP)		; shandle auf Stack
		GEMDOS $46, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Fgetchar( INT16 handle, INT16 mode );
		; ************************************************************
		
	EXPORT Fgetchar
	MODULE Fgetchar
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; mode auf Stack
		MOVE.W D0, -(SP)		; handle auf Stack
		GEMDOS $107, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; DTA *Fgetdta( void );
		; ************************************************************
		
	EXPORT Fgetdta
	MODULE Fgetdta
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $2F, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		MOVEA.L D0, A0			; Wert auch als Zeiger liefern
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Finstat( INT16 handle );
		; ************************************************************
		
	EXPORT Finstat
	MODULE Finstat
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; handle auf Stack
		GEMDOS $105, 4			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Flink( char *oldname, char *newname );
		; ************************************************************
		
	EXPORT Flink
	MODULE Flink
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A1)					; newname auf Stack
		PEA (A0)					; oldname auf Stack
		GEMDOS $12D, 10		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Flock( INT16 handle, INT16 mode,
		;              INT32 start, INT32 length );
		; ************************************************************
		
	EXPORT Flock
	MODULE Flock
		
		PCRegSave						; Register fr Pure-C retten
		MOVE.L _rsv+4(SP), -(SP)	; length auf Stack
		MOVE.L D2, -(SP)				; start auf Stack
		MOVE.W D1, -(SP)				; mode auf Stack
		MOVE.W D0, -(SP)				; handle auf Stack
		GEMDOS $5C, 14					; => GEMDOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Fmidipipe( INT16 pid, INT16 in, INT16 out );
		; ************************************************************
		
	EXPORT Fmidipipe
	MODULE Fmidipipe
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D2, -(SP)		; out auf Stack
		MOVE.W D1, -(SP)		; in auf Stack
		MOVE.W D0, -(SP)		; pid auf Stack
		GEMDOS $126, 8			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Fopen( char *fname, INT16 mode );
		; ************************************************************
		
	EXPORT Fopen
	MODULE Fopen
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; mode auf Stack
		PEA (A0)					; fname auf Stack
		GEMDOS $3D, 8			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Foutstat( INT16 handle );
		; ************************************************************
		
	EXPORT Foutstat
	MODULE Foutstat
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; handle auf Stack
		GEMDOS $106, 4			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Fpipe( INT16 fhandle[2] );
		; ************************************************************
		
	EXPORT Fpipe
	MODULE Fpipe
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; fhandle auf Stack
		GEMDOS $100, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Fputchar( INT16 handle, INT32 lchar, INT16 mode );
		; ************************************************************
		
	EXPORT Fputchar
	MODULE Fputchar
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D2, -(SP)		; mode auf Stack
		MOVE.L D1, -(SP)		; lchar auf Stack
		MOVE.W D0, -(SP)		; handle auf Stack
		GEMDOS $108, 10		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Fread( INT16 handle, INT32 length, void *buf );
		; ************************************************************
		
	EXPORT Fread
	MODULE Fread
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; buf auf Stack
		MOVE.L D1, -(SP)		; length auf Stack
		MOVE.W D0, -(SP)		; handle auf Stack
		GEMDOS $3F, 12			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Freadlink( INT16 bufsiz, char *buf, char *name );
		; ************************************************************
		
	EXPORT Freadlink
	MODULE Freadlink
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A1)					; name auf Stack
		PEA (A0)					; buf auf Stack
		MOVE.W D0, -(SP)		; bufsiz auf Stack
		GEMDOS $12F, 12		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; ACSTOS:
		; INT32 Frename( char *oldname, char *newname );
		;
		; CATTOS, PCTOSLIB:
		; INT32 Frename( INT16 zero, char *oldname, char *newname );
		; ************************************************************
		
	EXPORT Frename
	MODULE Frename
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A1)					; newname auf Stack
		PEA (A0)					; oldname auf Stack
IF __ACSTOS__
		MOVE.W #0, -(SP)		; dummy auf Stack
ELSE
		MOVE.W D0, -(SP)		; zero auf Stack
ENDIF
		GEMDOS $56, 12			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Frlock( INT16 handle, INT32 start, INT32 count );
		; ************************************************************
		
	EXPORT Frlock
	MODULE Frlock
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D2, -(SP)		; zero auf Stack
		MOVE.L D1, -(SP)		; zero auf Stack
		MOVE.W D0, -(SP)		; zero auf Stack
		GEMDOS $62, 12			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Frunlock( INT16 handle, INT32 start );
		; ************************************************************
		
	EXPORT Frunlock
	MODULE Frunlock
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D1, -(SP)		; start auf Stack
		MOVE.W D0, -(SP)		; handle auf Stack
		GEMDOS $63, 8			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Fseek( INT32 offset, INT16 handle, INT16 mode );
		; ************************************************************
		
	EXPORT Fseek
	MODULE Fseek
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D2, -(SP)		; mode auf Stack
		MOVE.W D1, -(SP)		; handle auf Stack
		MOVE.L D0, -(SP)		; offset auf Stack
		GEMDOS $42, 10			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Fselect( UINT16 timeout, INT32 *rfds,
		;                INT32 *wfds, INT32 *xfds );
		; ************************************************************
		
	EXPORT Fselect
	MODULE Fselect
		
		PCRegSave						; Register fr Pure-C retten
		MOVE.L _rsv+4(SP), -(SP)	; xfds auf Stack
		PEA (A1)							; wfds auf Stack
		PEA (A0)							; rfds auf Stack
		MOVE.W D0, -(SP)				; timeout auf Stack
		GEMDOS $11D, 16				; => GEMDOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Fsetdta( DTA *ndta );
		; ************************************************************
		
	EXPORT Fsetdta
	MODULE Fsetdta
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; ndta auf Stack
		GEMDOS $1A, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Fsfirst( char *fspec, INT16 attribs );
		; ************************************************************
		
	EXPORT Fsfirst
	MODULE Fsfirst
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; attribs auf Stack
		PEA (A0)					; fspec auf Stack
		GEMDOS $4E, 8			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Fsetdta( void );
		; ************************************************************
		
	EXPORT Fsnext
	MODULE Fsnext
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $4F, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Fsymlink( char *oldname, char *newname );
		; ************************************************************
		
	EXPORT Fsymlink
	MODULE Fsymlink
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A1)					; newname auf Stack
		PEA (A0)					; oldname auf Stack
		GEMDOS $12E, 10		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Funlock( INT16 handle );
		; ************************************************************
		
	EXPORT Funlock
	MODULE Funlock
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; handle auf Stack
		GEMDOS $65, 4			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Fwrite( INT16 handle, INT32 count, void *buf );
		; ************************************************************
		
	EXPORT Fwrite
	MODULE Fwrite
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; buf auf Stack
		MOVE.L D1, -(SP)		; count auf Stack
		MOVE.W D0, -(SP)		; handle auf Stack
		GEMDOS $40, 12			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Fxattr( INT16 flag, char *name, XATTR *xattr );
		; ************************************************************
		
	EXPORT Fxattr
	MODULE Fxattr
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A1)					; xattr auf Stack
		PEA (A0)					; name auf Stack
		MOVE.W D0, -(SP)		; flag auf Stack
		GEMDOS $12C, 12		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Lock( const char *path );
		; ************************************************************
		
	EXPORT Lock
	MODULE Lock
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; name auf Stack
		GEMDOS $7C, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Maddalt( void *start, INT32 size );
		; ************************************************************
		
	EXPORT Maddalt
	MODULE Maddalt
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D0, -(SP)		; size auf Stack
		PEA (A0)					; start auf Stack
		GEMDOS $14, 10			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void *Malloc( INT32 amount );
		; ************************************************************
		
	EXPORT Malloc
	MODULE Malloc
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D0, -(SP)		; amount auf Stack
		GEMDOS $48, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		MOVEA.L D0, A0			; Wert als Zeiger liefern
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Mblavail( void *block );
		; ************************************************************
		
	EXPORT Mblavail
	MODULE Mblavail
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L #-1, -(SP)		; newsize auf Stack
		PEA (A0)					; block auf Stack
		MOVE.W #0, -(SP)		; Dummy auf Stack
		GEMDOS $4A, 12			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		MOVEA.L D0, A0			; Wert auch als Zeiger liefern
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Mfree( void *startadr );
		; ************************************************************
		
	EXPORT Mfree
	MODULE Mfree
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; startadr auf Stack
		GEMDOS $49, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		;  INT32 Mgrow( void *block, INT32 newsize );
		; ************************************************************
		
	EXPORT Mgrow
	MODULE Mgrow
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D0, -(SP)		; newsize auf Stack
		PEA (A0)					; block auf Stack
		MOVE.W #0, -(SP)		; Dummy auf Stack
		GEMDOS $4A, 12			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; ACSTOS, CATTOS:
		; INT16 Mshrink( void *startadr, INT32 newsize );
		;
		; PCTOSLIB:
		; INT16 Mshrink( INT16 zero, void *startadr, INT32 newsize );
		; ************************************************************
		
	EXPORT Mshrink
	MODULE Mshrink
		
		PCRegSave				; Register fr Pure-C retten
IFF __ACSTOS__+__CATTOS__
		MOVE.L D1, -(SP)		; newsize auf Stack
ELSE
		MOVE.L D0, -(SP)		; newsize auf Stack
ENDIF
		PEA (A0)					; startadr auf Stack
IFF __ACSTOS__+__CATTOS__
		MOVE.W D0, -(SP)		; Dummy auf Stack
ELSE
		MOVE.W #0, -(SP)		; Dummy auf Stack
ENDIF
		GEMDOS $4A, 12			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void *Mxalloc( INT32 amount, INT16 mode );
		; ************************************************************
		
	EXPORT Mxalloc
	MODULE Mxalloc
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; mode auf Stack
		MOVE.L D0, -(SP)		; amount auf Stack
		GEMDOS $44, 8			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		MOVEA.L D0, A0			; Wert auch als Zeiger liefern
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Pause( void );
		; ************************************************************
		
	EXPORT Pause
	MODULE Pause
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $121, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Pdomain( INT16 domain );
		; ************************************************************
		
	EXPORT Pdomain
	MODULE Pdomain
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; domain auf Stack
		GEMDOS $119, 4			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Pexec( INT16 mode, const char *fname,
		;              const COMMAND *cmdline, const char *envstr );
		; ************************************************************
		
	EXPORT Pexec
	MODULE Pexec
		
		PCRegSave					; Register fr Pure-C retten
		MOVE.L _rsv+4(SP), -(SP); envstr auf Stack
		PEA (A1)						; cmdline auf Stack
		PEA (A0)						; fname auf Stack
		MOVE.W D0, -(SP)			; mode auf Stack
		GEMDOS $4B, 16				; => GEMDOS-Aufruf
		PCRegLoad					; Register fr Pure-C reparieren
		RTS							; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; WORK Pfork( void );
		; ************************************************************
		
	EXPORT Pfork
	MODULE Pfork
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $11B, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Pgetauid( void );
		; ************************************************************
		
	EXPORT Pgetauid
	MODULE Pgetauid
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $145, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Pgetegid( void );
		; ************************************************************
		
	EXPORT Pgetegid
	MODULE Pgetegid
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $139, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Pgeteuid( void );
		; ************************************************************
		
	EXPORT Pgeteuid
	MODULE Pgeteuid
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $138, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Pgetgid( void );
		; ************************************************************
		
	EXPORT Pgetgid
	MODULE Pgetgid
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $114, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Pgetgroups( INT16 gidsetlen, UINT16 gidset[] );
		; ************************************************************
		
	EXPORT Pgetgroups
	MODULE Pgetgroups
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; gidset auf Stack
		MOVE.W D0, -(SP)		; gidsetlen auf Stack
		GEMDOS $147, 8			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Pgetpgrp( void );
		; ************************************************************
		
	EXPORT Pgetpgrp
	MODULE Pgetpgrp
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $10D, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Pgetpid( void );
		; ************************************************************
		
	EXPORT Pgetpid
	MODULE Pgetpid
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $10B, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Pgetppid( void );
		; ************************************************************
		
	EXPORT Pgetppid
	MODULE Pgetppid
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $10C, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Pgetpriority( INT16 which, INT16 who );
		; ************************************************************
		
	EXPORT Pgetpriority
	MODULE Pgetpriority
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; who auf Stack
		MOVE.W D0, -(SP)		; which auf Stack
		GEMDOS $158, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Pgetuid( void );
		; ************************************************************
		
	EXPORT Pgetuid
	MODULE Pgetuid
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $10F, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Pkill( INT16 pid, INT16 sig );
		; ************************************************************
		
	EXPORT Pkill
	MODULE Pkill
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; sig auf Stack
		MOVE.W D0, -(SP)		; pid auf Stack
		GEMDOS $111, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Pmsg( INT16 mode, INT32 mboxid, MSG *msgptr );
		; ************************************************************
		
	EXPORT Pmsg
	MODULE Pmsg
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; msgptr auf Stack
		MOVE.L D1, -(SP)		; mboxid auf Stack
		MOVE.W D0, -(SP)		; mode auf Stack
		GEMDOS $125, 12		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Pnice( INT16 delta );
		; ************************************************************
		
	EXPORT Pnice
	MODULE Pnice
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; delta auf Stack
		GEMDOS $10A, 4			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Prenice( INT16 pid, INT16 delta );
		; ************************************************************
		
	EXPORT Prenice
	MODULE Prenice
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; delta auf Stack
		MOVE.W D0, -(SP)		; pid auf Stack
		GEMDOS $127, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Prusage( INT32 *rusg );
		; ************************************************************
		
	EXPORT Prusage
	MODULE Prusage
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; rusg auf Stack
		GEMDOS $11E, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Psemaphore( INT16 mode, INT32 id, INT32 timeout );
		; ************************************************************
		
	EXPORT Psemaphore
	MODULE Psemaphore
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D2, -(SP)		; timeout auf Stack
		MOVE.L D1, -(SP)		; id auf Stack
		MOVE.W D0, -(SP)		; mode auf Stack
		GEMDOS $134, 12		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Psetauid( INT16 id );
		; ************************************************************
		
	EXPORT Psetauid
	MODULE Psetauid
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; id auf Stack
		GEMDOS $146, 4			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Psetegid( INT16 id );
		; ************************************************************
		
	EXPORT Psetegid
	MODULE Psetegid
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; id auf Stack
		GEMDOS $144, 4			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Pseteuid( INT16 id );
		; ************************************************************
		
	EXPORT Pseteuid
	MODULE Pseteuid
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; id auf Stack
		GEMDOS $143, 4			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Psetgid( INT16 gid );
		; ************************************************************
		
	EXPORT Psetgid
	MODULE Psetgid
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; gid auf Stack
		GEMDOS $115, 4			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Psetgroups( INT16 ngroups, UINT16 gidset[] );
		; ************************************************************
		
	EXPORT Psetgroups
	MODULE Psetgroups
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; gidset auf Stack
		MOVE.W D0, -(SP)		; ngroups auf Stack
		GEMDOS $148, 8			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Psetlimit( INT16 limit, INT32 value );
		; ************************************************************
		
	EXPORT Psetlimit
	MODULE Psetlimit
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D1, -(SP)		; value auf Stack
		MOVE.W D0, -(SP)		; limit auf STack
		GEMDOS $11F, 8			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Psetpgrp( INT16 pid, INT16 newgrp );
		; ************************************************************
		
	EXPORT Psetpgrp
	MODULE Psetpgrp
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; newgrp auf Stack
		MOVE.W D0, -(SP)		; pid auf Stack
		GEMDOS $10E, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Psetpriority( INT16 which, INT16 who, INT16 pri );
		; ************************************************************
		
	EXPORT Psetpriority
	MODULE Psetpriority
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D2, -(SP)		; pri auf Stack
		MOVE.W D1, -(SP)		; who auf Stack
		MOVE.W D0, -(SP)		; which auf Stack
		GEMDOS $159, 8			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Psetregid( INT16 rid, INT16 eid );
		; ************************************************************
		
	EXPORT Psetregid
	MODULE Psetregid
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; eid auf Stack
		MOVE.W D0, -(SP)		; rid auf Stack
		GEMDOS $14F, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Psetreuid( INT16 rid, INT16 eid );
		; ************************************************************
		
	EXPORT Psetreuid
	MODULE Psetreuid
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; eid auf Stack
		MOVE.W D0, -(SP)		; rid auf Stack
		GEMDOS $14E, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Psetuid( INT16 uid );
		; ************************************************************
		
	EXPORT Psetuid
	MODULE Psetuid
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; uid auf Stack
		GEMDOS $110, 4			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; ACSTOS, PCTOSLIB:
		; INT32 Psigaction( INT16 sig, SIGACTION *act,
		;                   SIGACTION *oact );
		; CATOS.LIB:
		; INT32 Psigaction( INT16 sig, INT32 act, INT32 oact );
		************************************************************
		
	EXPORT Psigaction
	MODULE Psigaction
		
		PCRegSave				; Register fr Pure-C retten
IF __CATTOS__
		MOVE.L A1, -(SP)		; oact auf Stack
		MOVE.L A0, -(SP)		; act auf Stack
ELSE
		MOVE.L D2, -(SP)		; oact auf Stack
		MOVE.L D1, -(SP)		; act auf Stack
ENDIF
		MOVE.W D0, -(SP)		; sig auf Stack
		GEMDOS $137, 12		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Psigblock( INT32 mask );
		; ************************************************************
		
	EXPORT Psigblock
	MODULE Psigblock
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D0, -(SP)		; mask auf Stack
		GEMDOS $116, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Psigintr( INT16 vec, INT16 sig );
		; ************************************************************
		
	EXPORT Psigintr
	MODULE Psigintr
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; sig auf Stack
		MOVE.W D0, -(SP)		; vec auf Stack
		GEMDOS $13E, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; ACSTOS:
		; INT32 Psignal( INT16 sig, cdecl void (*handler)(INT32 sig) );
		;
		; CATTOS.LIB:
		; INT32 Psignal( INT16 sig, long handler );
		;
		; PCTOSLIB:
		; INT32 Psignal( INT16 sig, void *handler );
		; ************************************************************
		
	EXPORT Psignal
	MODULE Psignal
		
		PCRegSave				; Register fr Pure-C retten
IFF __CATTOS__
		MOVE.L A0, -(SP)		; handler auf Stack
ELSE
		MOVE.L D1, -(SP)		; handler auf Stack
ENDIF
		MOVE.W D0, -(SP)		; sig auf Stack
		GEMDOS $112, 8			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		MOVEA.L D0, A0			; Wert auch als Zeiger liefern
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Psigpause( INT32 mask );
		; ************************************************************
		
	EXPORT Psigpause
	MODULE Psigpause
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D0, -(SP)		; mask auf Stack
		GEMDOS $136, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Psigpending( void );
		; ************************************************************
		
	EXPORT Psigpending
	MODULE Psigpending
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $123, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Psigreturn( void );
		; ************************************************************
		
	EXPORT Psigreturn
	MODULE Psigreturn
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $11A, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Psigsetmask( INT32 mask );
		; ************************************************************
		
	EXPORT Psigsetmask
	MODULE Psigsetmask
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D0, -(SP)		; mask auf Stack
		GEMDOS $117, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Pterm( INT16 retcode );
		; ************************************************************
		
	EXPORT Pterm
	MODULE Pterm
		
		MOVE.W D0, -(SP)		; retcode auf Stack
		MOVE.W #$4C, -(SP)	; Fkt.-Code
		TRAP #1					; Programm beenden, der Aufruf kehrt NIE
									; zurck, da ja das Programm beendet wird!
		
	ENDMOD
		
		; ************************************************************
		; void Pterm0( void );
		; ************************************************************
		
	EXPORT Pterm0
	MODULE Pterm0
		
		CLR.W -(SP)				; Fkt.-Code
		TRAP #1					; Programm beenden, der Aufruf kehrt NIE
									; zurck, da ja das Programm beendet wird!
		
	ENDMOD
		
		; ************************************************************
		; void Ptermres( INT32 keep, INT16 retcode );
		; ************************************************************
		
	EXPORT Ptermres
	MODULE Ptermres
		
		MOVE.W D1, -(SP)		; retcode auf Stack
		MOVE.L D0, -(SP)		; keep auf Stack
		MOVE.W #$31, -(SP)	; Fkt.-Code
		TRAP #1					; Programm beenden, der Aufruf kehrt NIE
									; zurck, da ja das Programm beendet wird!
		
	ENDMOD
		
		; ************************************************************
		; INT16 Pumask( INT16 mode );
		; ************************************************************
		
	EXPORT Pumask
	MODULE Pumask
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; mode auf Stack
		GEMDOS $133, 4			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Pusrval( INT32 val );
		; ************************************************************
		
	EXPORT Pusrval
	MODULE Pusrval
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D0, -(SP)		; val auf Stack
		GEMDOS $118, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Pvfork( void );
		; ************************************************************
		
	EXPORT Pvfork
	MODULE Pvfork
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W $113, -(SP)	; Funktionsnummer Pvfork
		TRAP #1					; => GEMDOS
		TST.L D0					; Ergebnis prfen
		BEQ.S .childPvfork	; Child-Proze springt anders

.parentPvfork:
		ADDQ.L #2, SP			; Stack fr Parent korrigieren
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck

.childPvfork:					; Der hild-Proze darf dem Parent-Proze
									; nichts auf dem Stack zerst”ren!
		MOVEA.L 2(SP), A2		; Register fr Pure-C reparieren		
		MOVEA.L 6(SP), A0		; Return-Adresse fr Child laden ...
		JMP (A0)					; ... und direkt anspringen
	ENDMOD
		
		; ************************************************************
		; INT32 Pwait( void );
		; ************************************************************
		
	EXPORT Pwait
	MODULE Pwait
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $109, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Pwait3( INT16 flag, INT32 *rusage );
		; ************************************************************
		
	EXPORT Pwait3
	MODULE Pwait3
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; rusage auf Stack
		MOVE.W D0, -(SP)		; flag auf Stack
		GEMDOS $11C, 8			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Pwaitpid( INT16 pid, INT16, flag, INT32 *rusage );
		; ************************************************************
		
	EXPORT Pwaitpid
	MODULE Pwaitpid
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; rusage auf Stack
		MOVE.W D1, -(SP)		; flag auf Stack
		MOVE.W D0, -(SP)		; pid auf Stack
		GEMDOS $13A, 10		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Salert( char *str );
		; ************************************************************
		
	EXPORT Salert
	MODULE Salert
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; str auf Stack
		GEMDOS $13C, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Sconfig( INT16 mode, INT32 value );
		; ************************************************************
		
	EXPORT Sconfig
	MODULE Sconfig
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D1, -(SP)		; value auf Stack
		MOVE.W D0, -(SP)		; mode auf Stack
		GEMDOS $33, 8			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		MOVEA.L D0, A0			; Wert auch als Zeiger liefern
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Scookie( INT16 action, void *yummy );
		; ************************************************************
		
	EXPORT Scookie
	MODULE Scookie
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; yummy auf Stack
		MOVE.W D0, -(SP)		; action auf Stack
		GEMDOS $14A, 8			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Shutdown( INT32 restart );
		; ************************************************************
		
	EXPORT Shutdown
	MODULE Shutdown
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D0, -(SP)		; restart auf Stack
		GEMDOS $151, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Slbopen( char *name, char *path, INT32 min_ver,
		;                SHARED_LIB *sl, SLB_EXEC *fn );
		; ************************************************************
		
	EXPORT Slbopen
	MODULE Slbopen
		
		PCRegSave						; Register fr Pure-C retten
		MOVE.L _rsv+8(SP), -(SP)	; fn auf Stack
		MOVE.L _rsv+8(SP), -(SP)	; sl auf Stack
		MOVE.L D0, -(SP)				; min_ver auf Stack
		PEA (A1)							; path auf Stack
		PEA (A0)							; name auf Stack
		GEMDOS $16, 22					; => GEMDOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Slbclose( SHARED_LIB *sl );
		; ************************************************************
		
	EXPORT Slbclose
	MODULE Slbclose
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; sl auf Stack
		GEMDOS $17, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Srealloc( INT32 size );
		; ************************************************************
		
	EXPORT Srealloc
	MODULE Srealloc
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; size auf Stack
		GEMDOS $15, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Ssystem( INT16 mode, INT32 arg1, INT32 arg2 );
		; ************************************************************
		
	EXPORT Ssystem
	MODULE Ssystem
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D2, -(SP)		; arg2 auf Stack
		MOVE.L D1, -(SP)		; arg1 auf Stack
		MOVE.W D0, -(SP)		; mode auf Stack
		GEMDOS $154, 12		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Super( void *stack );
		; ************************************************************
		
	EXPORT Super
	MODULE Super
		
		; Prfen, ob der Fall Super(0) oder Super(1) vorliegt
		MOVE.L A0, D0					; Implizierter Test auf 0 ("USP->SSP")
		BEQ.S .SuperUsp2Ssp			; Ja => Super(0) wird gesondert behandelt
		CMPI.L #1, D0					; Test auf Wert 1 (Inquire)
		BEQ.S .SuperInquire			; Ja => Super(1) wird gesondert behandelt
		
		; Die Kennung prfen, d.h. ermitteln ob dies der alte Supervisorstack ist
		CMPI.L #$FEEDBEEF, 4(A0)	; Kennung fr alten SSP mu $FEEDBEEF sein
		BNE.S .SuperNewSSP			; Nein => Neuer SSP wird gesetzt
		CMPI.L #'USSS', (A0)			; Wie wurde in den Supervisormode gewechselt
		BEQ.S .SuperFromUsp2Ssp		; Fall "USP->SSP" => Rcksprung gesondert behandeln
		CMPI.L #'NSSP', (A0)			; Test auf Fall "Neuer SSP->SSP"
		BEQ.S .SuperFromNewSsp		; Fall "Neuer SSP->SSP" => Rcksprung gesondert behandeln
		BRA.S .SuperNewSSP			; Neuen SSP im Supervisormode verwenden
		
		; Aus dem Supervisormode mit USP als SSP in den Usermode schalten
.SuperFromUsp2Ssp:
		ADDQ.L #8, A0					; Die Kennungen "USP->SSP" vom alten SSP entfernen
		
		; Optimierung: Nun geht es weiter wie bei Super(1)
		
		; Abfrage, in welchem Modus wir uns befinden
.SuperInquire:
		PCRegSave						; Register fr Pure-C retten
		PEA (A0)							; Wert 1 (in A0) auf Stack schieben
											; oder den alten SSP, der von Super(0) stammt
											; In A0 steht 1 oder der alte SSP
											; Hinweis: PEA ist schneller als MOVE.L (oder MOVEI.L)
		GEMDOS $20, 6					; => GEMDOS-Aufruf mit Stack-Korrektur
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
		; Mit USP als SSP in den Supervisormode schalten
.SuperUsp2Ssp:
		PCRegSave						; Register fr Pure-C retten
		PEA (A0)							; Wert 0 (in A0) auf Stack schieben
											; Hinweis: PEA ist schneller als MOVE.L oder CLR.L
		GEMDOS $20, 6					; => GEMDOS-Aufruf mit Stack-Korrektur
		PCRegLoad						; Register fr Pure-C reparieren
		
		; Auf dem alten SSP vermerken, da wir mit dem USP in den Supervisormode geschaltet haben
		MOVEA.L D0, A0					; Ergebnis in Adreregister fr Zugriff auf alten SSP
		MOVE.L #$FEEDBEEF, -(A0)	; Erster Wert der Kennung, da es ein alter SSP ist
		MOVE.L #'USSS', -(A0)		; Zweiter Wert der Kennung fr "USP->SSP"
		MOVE.L A0, D0					; Neuer Wert des alten SSP zurckgeben
		RTS								; ... und zurck
		
		; Mit neuem SSP in den Supervisormode schalten
.SuperNewSSP:
		MOVE.L (SP)+, -(A0)			; Rcksprungadresse auf neuen Stack
		MOVE.L SP, -(A0)				; Bisherigen USP ohne die Rcksprungadresse auf neuen Stack schieben
		MOVE.L A2, -(A0)				; Register A2 fr Pure-C auf neuen Stack retten
		PEA (A0)							; Neuen SSP auf Stack schieben
		MOVE.W #$20, -(SP)			; Funktionscode Super
		TRAP #1							; => GEMDOS-Aufruf ohne(!) Stack-Korrektur
		MOVE.L (SP)+, A2				; Register A2 fr Pure-C restaurieren
		
		; Auf dem alten SSP werden ein paar Daten vermerkt, die beim Zurckschalten ben”tigt werden
		MOVEA.L D0, A0					; Ergebnis in Adreregister fr Zugriff auf alten SSP
		
		MOVE.L (SP)+, -(A0)			; Alten USP vom neuen SSP auf den alten SSP schieben
		
		; Auf dem alten SSP vermerken, da wir mit neuem SSP in den Supervisormode geschaltet haben
		MOVE.L #$FEEDBEEF, -(A0)	; Erster Wert der Kennung, da es ein alter SSP ist
		MOVE.L #'NSSP', -(A0)		; Zweiter Wert der Kennung fr "neuen SSP->SSP"
		MOVE.L A0, D0					; Neuen Wert des alten SSP zurckgeben
		RTS								; ... und zurck
		
		; Aus dem Supervisormode mit neuem SSP in den Usermode mit altem(!) USP
.SuperFromNewSsp:
		ADDQ.L #8, A0					; Die Kennungen "Neuer SSP->SSP" vom alten SSP entfernen
		MOVEA.L (A0)+, A1				; Alten USP laden
		MOVE.L (SP)+, -(A1)			; Rcksprungadresse bertragen
		MOVE.L A2, -(A1)				; Register A2 fr Pure-C retten
		MOVE.L (A3), -(A1)			; Register A3 retten, damit dort der USP ber den Trap gerettet werden kann
		MOVE.L A1, A3					; Alten USP in A3 ber Trap retten
		PEA (A0)							; Parameterwert stack auf Stack schieben
		GEMDOS $20, 6					; => GEMDOS-Aufruf mit Stack-Korrektur
		
		; Nun die Daten wieder passend restaurieren
		MOVE.L A3, SP					; Den alten USP wieder verwenden
		MOVEA.L (SP)+, A3				; Register A3 wieder restaurieren
		MOVEA.L (SP)+, A2				; Register A2 wieder restaurieren
		
		RTS								; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Suptime( UINT32 *cur_uptime, UINT32 loadave[3] );
		; ************************************************************
		
	EXPORT Suptime
	MODULE Suptime
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A1)					; loeadave auf Stack
		PEA (A0)					; cur_uptime auf Stack
		GEMDOS $13F, 10		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; UINT16 Sversion( void );
		; ************************************************************
		
	EXPORT Sversion
	MODULE Sversion
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $30, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Syield( void );
		; ************************************************************
		
	EXPORT Syield
	MODULE Syield
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $FF, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Sync( void );
		; ************************************************************
		
	EXPORT Sync
	MODULE Sync
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $150, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Sysconf( INT16 inq );
		; ************************************************************
		
	EXPORT Sysconf
	MODULE Sysconf
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; inq auf Stack
		GEMDOS $122, 4			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Tadjtime( INT32 delta, INT32 olddelta );
		; ************************************************************
		
	EXPORT Tadjtime
	MODULE Tadjtime
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D1, -(SP)		; olddelta auf Stack
		MOVE.L D0, -(SP)		; delta auf Stack
		GEMDOS $157, 10		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Talarm( INT32 time );
		; ************************************************************
		
	EXPORT Talarm
	MODULE Talarm
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D0, -(SP)		; time auf Stack
		GEMDOS $120, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; UINT16 Tgetdate( void );
		; ************************************************************
		
	EXPORT Tgetdate
	MODULE Tgetdate
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $2A, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; UINT16 Tgettime( void );
		; ************************************************************
		
	EXPORT Tgettime
	MODULE Tgettime
		
		PCRegSave				; Register fr Pure-C retten
		GEMDOS $2C, 2			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Tgettimeofday( struct timeval *tv, struct timezone *tz );
		; ************************************************************
		
	EXPORT Tgettimeofday
	MODULE Tgettimeofday
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A1)					; tz auf Stack
		PEA (A0)					; tv auf Stack
		GEMDOS $155, 10			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; UINT32 Tmalarm( UINT32 millisecs );
		; ************************************************************
		
	EXPORT Tmalarm
	MODULE Tmalarm
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D0, -(SP)		; millisecs auf Stack
		GEMDOS $13D, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Tsetdate( UINT16 date );
		; ************************************************************
		
	EXPORT Tsetdate
	MODULE Tsetdate
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; date auf Stack
		GEMDOS $2B, 4			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Tsetitimer( INT16 which, INT32 *interval, INT32 *value,
		;                   INT32 *ointeral, INT32 *ovalue );
		; ************************************************************
		
	EXPORT Tsetitimer
	MODULE Tsetitimer
		
		PCRegSave						; Register fr Pure-C retten
		MOVE.L _rsv+8(SP), -(SP)	; ovalue auf Stack
		MOVE.L _rsv+8(SP), -(SP)	; ointeral auf Stack
		MOVE.L A1, -(SP)				; value auf Stack
		MOVE.L A0, -(SP)				; interval auf Stack
		MOVE.W D0, -(SP)				; which auf Stack
		GEMDOS $149, 22				; => GEMDOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Tsettime( UINT16 time );
		; ************************************************************
		
	EXPORT Tsettime
	MODULE Tsettime
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; time auf Stack
		GEMDOS $2D, 4			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Tsettimeofday( struct timeval *tv, struct timezone *tz );
		; ************************************************************
		
	EXPORT Tsettimeofday
	MODULE Tsettimeofday
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A1)					; tz auf Stack
		PEA (A0)					; tv auf Stack
		GEMDOS $156, 10			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Unlock( const char *path );
		; ************************************************************
		
	EXPORT Unlock
	MODULE Unlock
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; path auf Stack
		GEMDOS $7B, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; int32 Dchroot( const char *path );   /* MiNT only */
		; ************************************************************
		
	EXPORT Dchroot
	MODULE Dchroot
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; path auf Stack
		GEMDOS $14A, 6			; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD

		; ************************************************************
		; int32 Dsetkey( int32 hidev, int32 lowdev, char *key, int16 cipher);
		; ************************************************************
		
	EXPORT Dsetkey
	MODULE Dsetkey
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D2, -(SP)		; cipher auf Stack
		PEA (A0)					; key auf Stack
		MOVE.L D1, -(SP)		; lowdev auf Stack
		MOVE.L D0, -(SP)		; highdev auf Stack
		GEMDOS $14D, 16		; => GEMDOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
