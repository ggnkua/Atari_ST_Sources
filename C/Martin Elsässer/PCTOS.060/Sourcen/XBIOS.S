		; ************************************************************
		;
		;           Eine handoptimierte Bibliothek fr Pure-C
		;
		; Die XBIOS-Funktionen
		;
		; (c)1998-2004 by Martin Els„sser
		; ************************************************************

		; Als Makro mit Stack-Reparatur die BIOS-Aufrufe
	MACRO XBIOS Nr, AddStack
		
		MOVE.W #Nr, -(SP)		; Fkt.-Nr auf Stack
		TRAP #14					; XBIOS aufrufen
		
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
		
		; Die Register D3-D7 und A3-A7 werden vom XBIOS-Dispatcher
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
		; INT32 xbios( INT16 fkt_nr, ... );
		; ************************************************************
		
	EXPORT xbios
	MODULE xbios
		
		MOVE.L save_ptr, A0	; Stand der "Save-Area" laden
		MOVE.L (SP)+, -(A0)	; Return-Adresse retten
		MOVE.L A2, -(A0)		; Register A2 fr Pure-C retten
		MOVE.L A0, save_ptr	; Stand der "Save-Area" merken
		MOVE.W D0, -(SP)		; Fkt.Nr. auf Stack
		TRAP #14					; XBIOS aufrufen
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
		; INT32 Bconmap( INT16 devno );
		; ************************************************************
		
	EXPORT Bconmap
	MODULE Bconmap
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(sp)		; devno auf Stack
		XBIOS $2C, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 HasBconmap( void );
		; ************************************************************
		
	EXPORT HasBconmap
	MODULE HasBconmap
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W #0, -(sp)		; 0 auf Stack
		XBIOS $2C, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		CMPI.W #0, D0			; Testen, ob 0 herauskommt
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Bioskeys( void );
		; ************************************************************
		
	EXPORT Bioskeys
	MODULE Bioskeys
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS $18, 2			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Blitmode( INT16 mode );
		; ************************************************************
		
	EXPORT Blitmode
	MODULE Blitmode
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; mode auf Stack
		XBIOS $40, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Buffoper( INT16 mode);
		; ************************************************************
		
	EXPORT Buffoper
	MODULE Buffoper
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; mode auf Stack
		XBIOS $88, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Buffptr( SBUFPTR *sptr );
		; ************************************************************
		
	EXPORT Buffptr
	MODULE Buffptr
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; sptr auf Stack
		XBIOS $8D, 6			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Cursconf( INT16 function, INT16 operand );
		; ************************************************************
		
	EXPORT Cursconf
	MODULE Cursconf
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; operand auf Stack
		MOVE.W D0, -(SP)		; function auf Stack
		XBIOS $15, 6			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Dbmsg( INT16 rsrvd, INT16 msg_num, INT32 msg_arg );
		; ************************************************************
		
	EXPORT Dbmsg
	MODULE Dbmsg
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D2, -(SP)		; msg_arg auf Stack
		MOVE.W D1, -(SP)		; msg_num auf Stack
		MOVE.W #5, -(SP)		; rsrvd wird ignoriert, 5 mu es sein!
		XBIOS $B, 10			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Devconnect( INT16 source, INT16 dest, INT16 clk, 
		;                  INT16 prescale, INT16 protocol );
		; ************************************************************
		
	EXPORT Devconnect
	MODULE Devconnect
		
		PCRegSave						; Register fr Pure-C retten
		;
		; Optimierung!
		;
		; Statt:
		;
		; MOVE.W _rsv+4(SP), -(SP)	; protocol auf Stack
		; MOVE.W _rsv+4(SP), -(SP)	; prescale auf Stack
		;
		; heit es nun
		MOVE.L _rsv+4(SP), -(SP)	; protocol & prescale auf Stack
		MOVE.W D2, -(SP)				; clk auf Stack
		MOVE.W D1, -(SP)				; dest auf Stack
		MOVE.W D0, -(SP)				; source auf Stack
		XBIOS $8B, 12					; => XBIOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 DMAread( INT32 sector, INT16 count,
		;               void *buffer, INT16 devno );
		; ************************************************************
		
	EXPORT DMAread
	MODULE DMAread
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D2, -(SP)		; devno auf Stack
		PEA (A0)					; buffer auf Stack
		MOVE.W D1, -(SP)		; count auf Stack
		MOVE.L D0, -(SP)		; sector auf Stack
		XBIOS $2A, 14			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS
		
	ENDMOD
		
		; ************************************************************
		; INT32 DMAwrite( INT32 sector, INT16 count,
		;                void *buffer, INT16 devno );
		; ************************************************************
		
	EXPORT DMAwrite
	MODULE DMAwrite
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D2, -(SP)		; devno auf Stack
		PEA (A0)					; buffer auf Stack
		MOVE.W D1, -(SP)		; count auf Stack
		MOVE.L D0, -(SP)		; sector auf Stack
		XBIOS $2B, 14			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS
		
	ENDMOD
		
		; ************************************************************
		; void *Dosound( const char *ptr );
		; ************************************************************
		
	EXPORT Dosound
	MODULE Dosound
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; ptr auf Stack
		XBIOS $20, 6			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		MOVEA.L D0, A0			; Wert auch als Zeiger zurckgeben
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Dsp_Available( INT32 *xavail, *yavail );
		; ************************************************************
		
	EXPORT Dsp_Available
	MODULE Dsp_Available
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A1)					; yavail auf Stack
		PEA (A0)					; xavail auf Stack
		XBIOS $6A, 10			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Dsp_BlkBytes( UBYTE *data_in, INT32 size_in,
		;                    UBYTE *data_out, INT32 size_out );
		; ************************************************************
		
	EXPORT Dsp_BlkBytes
	MODULE Dsp_BlkBytes
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D1, -(SP)		; size_out auf Stack
		PEA (A1)					; data_out auf Stack
		MOVE.L D0, -(SP)		; size_in auf Stack
		PEA (A0)					; data_in auf Stack
		XBIOS $7C, 18			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Dsp_BlkHandShake( UBYTE *data_in, INT32 size_in,
		;                        UBYTE *data-out, INT32 size_out );
		; ************************************************************
		
	EXPORT Dsp_BlkHandShake
	MODULE Dsp_BlkHandShake
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D1, -(SP)		; size_out auf Stack
		PEA (A1)					; data_out auf Stack
		MOVE.L D0, -(SP)		; size_in auf Stack
		PEA (A0)					; data_in auf Stack
		XBIOS $61, 18			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Dsp_BlkUnpacked( INT32 *data_in, INT32 size_in,
		;                       INT32 *data_out, INT32 size_out );
		; ************************************************************
		
	EXPORT Dsp_BlkUnpacked
	MODULE Dsp_BlkUnpacked
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D1, -(SP)		; size_out auf Stack
		PEA (A1)					; data_out auf Stack
		MOVE.L D0, -(SP)		; size_in auf Stack
		PEA (A0)					; data_in auf Stack
		XBIOS $62, 18			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Dsp_BlkWords( INT16 *data_in, INT32 size_in,
		;                    INT16 *data_out, INT32 size_out );
		; ************************************************************
		
	EXPORT Dsp_BlkWords
	MODULE Dsp_BlkWords
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D1, -(SP)		; size_out auf Stack
		PEA (A1)					; data_out auf Stack
		MOVE.L D0, -(SP)		; size_in auf Stack
		PEA (A0)					; data_in auf Stack
		XBIOS $7B, 18			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
				
		; ************************************************************
		; void Dsp_DoBlock( char *data_in, INT32 size_in,
		;                   char *data_out, INT32 size_out );
		; ************************************************************
		
	EXPORT Dsp_DoBlock
	MODULE Dsp_DoBlock
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D1, -(SP)		; size_out auf Stack
		PEA (A1)					; data_out auf Stack
		MOVE.L D0, -(SP)		; size_in auf Stack
		PEA (A0)					; data_in auf Stack
		XBIOS $60, 18			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
				
		; ************************************************************
		; void Dsp_ExecBoot( char *codeptr, INT32 codesize, INT16 ability );
		; ************************************************************
		
	EXPORT Dsp_ExecBoot
	MODULE Dsp_ExecBoot
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; ability auf Stack
		MOVE.L D0, -(SP)		; codesize auf Stack
		PEA (A0)					; codeptr auf Stack
		XBIOS $6E, 12			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Dsp_ExecProg( char *codeptr, INT32 codesize, INT16 ability );
		; ************************************************************
		
	EXPORT Dsp_ExecProg
	MODULE Dsp_ExecProg
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; ability auf Stack
		MOVE.L D0, -(SP)		; codesize auf Stack
		PEA (A0)					; codeptr auf Stack
		XBIOS $6D, 12			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Dsp_FlushSubroutines( void );
		; ************************************************************
		
	EXPORT Dsp_FlushSubroutines
	MODULE Dsp_FlushSubroutines
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS $73, 2			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Dsp_GetProgAbility( void );
		; ************************************************************
		
	EXPORT Dsp_GetProgAbility
	MODULE Dsp_GetProgAbility
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS $72, 2			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Dsp_GetWordSize( void );
		; ************************************************************
		
	EXPORT Dsp_GetWordSize
	MODULE Dsp_GetWordSize
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS $67, 2			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Dsp_Hf0( INT16 flag );
		; ************************************************************
		
	EXPORT Dsp_Hf0
	MODULE Dsp_Hf0
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; flag auf Stack
		XBIOS $77, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Dsp_Hf1( INT16 flag );
		; ************************************************************
		
	EXPORT Dsp_Hf1
	MODULE Dsp_Hf1
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; flag auf Stack
		XBIOS $78, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Dsp_Hf2( void );
		; ************************************************************
		
	EXPORT Dsp_Hf2
	MODULE Dsp_Hf2
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS $79, 2			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Dsp_Hf3( void );
		; ************************************************************
		
	EXPORT Dsp_Hf3
	MODULE Dsp_Hf3
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS $7A, 2			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; BYTE Dsp_HStat( void );
		; ************************************************************
		
	EXPORT Dsp_HStat
	MODULE Dsp_HStat
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS $7D, 2			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; BYTE Dsp_InqSubrAbility( INT16 ability );
		; ************************************************************
		
	EXPORT Dsp_InqSubrAbility
	MODULE Dsp_InqSubrAbility
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; ability auf Stack
		XBIOS $75, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Dsp_InStream( char *data_in, INT32 block_size,
		;                    INT32 num_blocks, INT32 *blocks_done );
		; ************************************************************
		
	EXPORT Dsp_InStream
	MODULE Dsp_InStream
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A1)					; blocks_done auf Stack
		MOVE.L D1, -(SP)		; num_blocks auf Stack
		MOVE.L D0, -(SP)		; block_size auf Stack
		PEA (A0)					; data_in auf Stack
		XBIOS $63, 18			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Dsp_IOStream( char *data_in, char *data_out,
		;                    INT32 block_insize, INT32 block_outsize,
		;                    INT32 num_blocks, INT32 *blocks_done );
		; ************************************************************
		
	EXPORT Dsp_IOStream
	MODULE Dsp_IOStream
		
		PCRegSave						; Register fr Pure-C retten
		MOVE.L _rsv+4(SP), -(SP)	; blocks_done auf Stack
		MOVE.L D2, -(SP)				; num_blocks auf Stack
		MOVE.L D1, -(SP)				; block_outsize auf Stack
		MOVE.L D0, -(SP)				; block_insize auf Stack
		PEA (A1)							; data_out auf Stack
		PEA (A0)							; data_in auf Stack
		XBIOS $65, 26					; => XBIOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Dsp_LoadProg( char *file, INT16 ability, char *buf );
		; ************************************************************
		
	EXPORT Dsp_LoadProg
	MODULE Dsp_LoadProg
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A1)					; buf auf Stack
		MOVE.W D0, -(SP)		; ability auf Stack
		MOVE.L A0, -(SP)		; file auf Stack
		XBIOS $6C, 12			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Dsp_LoadSubroutine( char *ptr, INT32 size,
		;                          INT16 ability );
		; ************************************************************
		
	EXPORT Dsp_LoadSubroutine
	MODULE Dsp_LoadSubroutine
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; ability auf Stack
		MOVE.L D0, -(SP)		; size auf Stack
		PEA (A0)					; ptr auf Stack
		XBIOS $74, 12			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; BYTE Dsp_Lock( void );
		; ************************************************************
		
	EXPORT Dsp_Lock
	MODULE Dsp_Lock
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS $68, 2			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Dsp_LodToBinary( char *file, char *codeptr );
		; ************************************************************
		
	EXPORT Dsp_LodToBinary
	MODULE Dsp_LodToBinary
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A1)					; codeptr auf Stack
		PEA (A0)					; file auf Stack
		XBIOS $6F, 10			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; BYTE Dsp_MultBlocks( INT32 numsend, INT32 numreceive,
		;                      DSPBLOCK *sendblk,
		;                      DSPBLOCK *receiveblock );
		; ************************************************************
		
	EXPORT Dsp_MultBlocks
	MODULE Dsp_MultBlocks
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A1)					; receiveblock auf Stack
		PEA (A0)					; sendblk auf Stack
		MOVE.L D1, -(SP)		; numreceive auf Stack
		MOVE.L D0, -(SP)		; numsend auf Stack
		XBIOS $7F, 18			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Dsp_OutStream( char *data_out, INT32 block_size,
		;                     INT32 num_blocks INT32 *blocks_done );
		; ************************************************************
		
	EXPORT Dsp_OutStream
	MODULE Dsp_OutStream
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A1)					; blocks_done auf Stack
		MOVE.L D1, -(sp)		; num_blocks auf Stack
		MOVE.L D0, -(SP)		; block_size auf Stack
		PEA (A0)					; data_out auf Stack
		XBIOS $64, 18			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Dsp_RemoveInterrupts( INT16 mask );
		; ************************************************************
		
	EXPORT Dsp_RemoveInterrupts
	MODULE Dsp_RemoveInterrupts
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; mask auf Stack
		XBIOS $66, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Dsp_RequestUniqueAbility( void );
		; ************************************************************
		
	EXPORT Dsp_RequestUniqueAbility
	MODULE Dsp_RequestUniqueAbility
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS $71, 2			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Dsp_Reserve( INT32 xreserve, INT32 yreserve );
		; ************************************************************
		
	EXPORT Dsp_Reserve
	MODULE Dsp_Reserve
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D1, -(SP)		; yreserve auf Stack
		MOVE.L D0, -(SP)		; xreserve auf Stack
		XBIOS $6B, 10			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Dsp_RunSubroutine( INT16 handle );
		; ************************************************************
		
	EXPORT Dsp_RunSubroutine
	MODULE Dsp_RunSubroutine
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; handle auf Stack
		XBIOS $76, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Dsp_SetVectors( void (*receiver)(),
		;                      INT32 (*transmitter)() );
		; ************************************************************
		
	EXPORT Dsp_SetVectors
	MODULE Dsp_SetVectors
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A1)					; transmitter auf Stack
		PEA (A0)					; receiver auf Stack
		XBIOS $7E, 10			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Dsp_TriggerHC( INT16 vector );
		; ************************************************************
		
	EXPORT Dsp_TriggerHC
	MODULE Dsp_TriggerHC
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; vector auf Stack
		XBIOS $70, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Dsp_Unlock( void );
		; ************************************************************
		
	EXPORT Dsp_Unlock
	MODULE Dsp_Unlock
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS $69, 2			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Dsptristate( INT16 dspxmit, INT16 dsprec );
		; ************************************************************
		
	EXPORT Dsptristate
	MODULE Dsptristate
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; dsprec auf Stack
		MOVE.W D0, -(SP)		; dspxmit auf Stack
		XBIOS $89, 6			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void EgetPalette( INT16 colorNum, INT16 count,
		;                   INT16 *palettePtr );
		; ************************************************************
		
	EXPORT EgetPalette
	MODULE EgetPalette
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; palettePtr auf Stack
		MOVE.W D1, -(SP)		; count auf Stack
		MOVE.W D0, -(SP)		; colorNum auf Stack
		XBIOS $55, 10			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 EgetShift( void );
		; ************************************************************
		
	EXPORT EgetShift
	MODULE EgetShift
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS $51, 2			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 EsetBank( INT16 bankNum );
		; ************************************************************
		
	EXPORT EsetBank
	MODULE EsetBank
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; bankNum auf Stack
		XBIOS $52, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 EsetColor( INT16 colorNum, INT16 color );
		; ************************************************************
		
	EXPORT EsetColor
	MODULE EsetColor
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; color auf Stack
		MOVE.W D0, -(SP)		; colorNum auf Stack
		XBIOS $53, 6			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS
		
	ENDMOD
		
		; ************************************************************
		; INT16 EsetGray( INT16 switch );
		; ************************************************************
		
	EXPORT EsetGray
	MODULE EsetGray
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; switch auf Stack
		XBIOS $56, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und tsch
		
	ENDMOD
		
		; ************************************************************
		; void EsetPalette( INT16 colorNum, INT16 count,
		;                   INT16 *palettePtr );
		; ************************************************************
		
	EXPORT EsetPalette
	MODULE EsetPalette
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; palettePtr auf Stack
		MOVE.W D1, -(SP)		; count auf Stack
		MOVE.W D0, -(SP)		; colorNum auf Stack
		XBIOS $54, 10			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 EsetShift( INT16 shftMode );
		; ************************************************************
		
	EXPORT EsetShift
	MODULE EsetShift
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; shftMode auf Stack
		XBIOS $50, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 EsetSmear( INT16 switch );
		; ************************************************************
		
	EXPORT EsetSmear
	MODULE EsetSmear
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; switch auf Stack
		XBIOS $57, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Flopfmt( void *buf, void *sect, INT16 devno, INT16 spt,
		;               INT16 trackno, INT16 sideno, INT16 interlv,
		;               INT32 magic, INT16 virgin );
		; ************************************************************
		
	EXPORT Flopfmt
	MODULE Flopfmt
		
		PCRegSave						; Register fr Pure-C retten
		MOVE.W _rsv+12(SP), -(SP)	; virgin auf Stack
		MOVE.L _rsv+10(SP), -(SP)	; magic auf Stack
		;
		; Optimierung!
		;
		; Statt
		;
		; MOVE.W _rsv+12(SP), -(SP)	; interlv auf Stack
		; MOVE.W _rsv+12(SP), -(SP)	; sideno auf Stack
		;
		; nun
		;
		MOVE.L _rsv+12(SP), -(SP)	; interlv & sideno auf Stack
		MOVE.W D2, -(SP)				; trackno auf Stack
		MOVE.W D1, -(SP)				; spt auf Stack
		MOVE.W D0, -(SP)				; devno auf Stack
		PEA (A1)							; sect auf Stack
		PEA (A0)							; buf auf Stack
		XBIOS $A, 26					; => XBIOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Floprate( INT16 drive, INT16 seekrate );
		; ************************************************************
		
	EXPORT Floprate
	MODULE Floprate
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; seekrate auf Stack
		MOVE.W D0, -(SP)		; drive auf Stack
		XBIOS $29, 6			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Floprd( void *buf, INT32 filler, INT16 devno, INT16 sectno,
		;              INT16 trackno, INT16 sideno, INT16 count );
		; ************************************************************
		
	EXPORT Floprd
	MODULE Floprd
		
		PCRegSave						; Register fr Pure-C retten
		;
		; Optimierung!
		;
		; Statt
		;
		; MOVE.W _rsv+4(SP), -(SP)	; count auf Stack
		; MOVE.W _rsv+4(SP), -(SP)	; sideno auf Stack
		;
		; nun:
		;
		MOVE.L _rsv+4(SP), -(SP)	; count & sideno auf Stack
		MOVE.W D2, -(SP)				; trackno auf Stack
		MOVE.W D1, -(SP)				; sectno auf Stack
		MOVE.W D0, -(SP)				; devno auf Stack
		MOVE.L #0, -(SP)				; filler wird ignoriert!
		PEA (A0)							; buf auf Stack
		XBIOS 8, 20						; => XBIOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Flopver( void *buf, INT32 filler, INT16 devno, INT16 sectno,
		;               INT16 trackno, INT16 sideno, INT16 count );
		; ************************************************************
		
	EXPORT Flopver
	MODULE Flopver
		
		PCRegSave						; Register fr Pure-C retten
		;
		; Optimierung!
		;
		; Statt:
		;
		; MOVE.W _rsv+6(SP), -(SP)	; count auf Stack
		; MOVE.W _rsv+6(SP), -(SP)	; sideno auf Stack
		;
		; nun:
		;
		MOVE.L _rsv+4(SP), -(SP)	; count & sideno auf Stack
		MOVE.W D2, -(SP)				; trackno auf Stack
		MOVE.W D1, -(SP)				; sectno auf Stack
		MOVE.W D0, -(SP)				; devno auf Stack
		MOVE.L #0, -(SP)				; filler wird ignoriert!
		PEA (A0)							; buf auf Stack
		XBIOS $13, 20					; => XBIOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Flopwr( void *buf, INT32 filler, INT16 devno, INT16 sectno,
		;              INT16 trackno, INT16 sideno, INT16 count );
		; ************************************************************
		
	EXPORT Flopwr
	MODULE Flopwr
		
		PCRegSave						; Register fr Pure-C retten
		;
		; Optimierung!
		;
		; Statt:
		;
		; MOVE.W _rsv+6(SP), -(SP)	; count auf Stack
		; MOVE.W _rsv+6(SP), -(SP)	; sideno auf Stack
		;
		; nun:
		;
		MOVE.L _rsv+8(SP), -(SP)	; count & sideno auf Stack
		MOVE.W D2, -(SP)				; trackno auf Stack
		MOVE.W D1, -(SP)				; sectno auf Stack
		MOVE.W D0, -(SP)				; devno auf Stack
		MOVE.L #0, -(SP)				; filler wird ignoriert!
		PEA (A0)							; buf auf Stack
		XBIOS $9, 20					; => XBIOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Getrez( void );
		; ************************************************************
		
	EXPORT Getrez
	MODULE Getrez
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS 4, 2				; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Gettime( void );
		; ************************************************************
		
	EXPORT Gettime
	MODULE Gettime
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS $17, 2			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; char Giaccess( INT16 c, INT16 recno );
		; ************************************************************
		
	EXPORT Giaccess
	MODULE Giaccess
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; recno auf Stack
		MOVE.W D0, -(SP)		; c auf Stack
		XBIOS $1C, 6			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Gpio( INT16 mode, INT16 data );
		; ************************************************************
		
	EXPORT Gpio
	MODULE Gpio
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; data auf Stack
		MOVE.W D0, -(SP)		; mode auf Stack
		XBIOS $8A, 6			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Ikbdws( INT16 cnt, const char *ptr );
		; ************************************************************
		
	EXPORT Ikbdws
	MODULE Ikbdws
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; ptr auf Stack
		MOVE.W D0, -(SP)		; cnt auf Stack
		XBIOS $19, 8			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Initmouse( INT16 type, PARAM *param, void *(*vec)() );
		; ************************************************************
		
	EXPORT Initmouse
	MODULE Initmouse
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A1)					; vec auf Stack
		PEA (A0)					; param auf Stack
		MOVE.W D0, -(SP)		; Type auf Stack
		XBIOS 0, 12				; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; IOREC *Iorec( INT16 devno );
		; ************************************************************
		
	EXPORT Iorec
	MODULE Iorec
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; devno auf Stack
		XBIOS $E, 4				; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Jdisint( WIRD intno );
		; ************************************************************
		
	EXPORT Jdisint
	MODULE Jdisint
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; intno auf Stack
		XBIOS $1A, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Jenabint( INT16 intno );
		; ************************************************************
		
	EXPORT Jenabint
	MODULE Jenabint
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; intno auf Stack
		XBIOS $1B, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; KBDVECS *Kbdvbase( void );
		; ************************************************************
		
	EXPORT Kbdvbase
	MODULE Kbdvbase
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS $22, 2			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		MOVEA.L D0, A0			; Wert als Zeiger liefern
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Kbrate( INT16 initial, INT16 repeat );
		; ************************************************************
		
	EXPORT Kbrate
	MODULE Kbrate
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; repeat auf Stack
		MOVE.W D0, -(SP)		; initial auf Stack
		XBIOS $23, 6			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; ACSTOS:
		; KEYTAB *Keytbl( char *unshift, char *shift, char *capslock );
		;
		; CATTOS, PCTOSLIB:
		; KEYTAB *Keytbl( void *unshift, void *shift, void *capslock );
		; ************************************************************
		
	EXPORT Keytbl
	MODULE Keytbl
		
		PCRegSave						; Register fr Pure-C retten
		MOVE.L _rsv+4(SP), -(SP)	; capslock auf Stack
		PEA (A1)							; shift auf Stack
		PEA (A0)							; unshift auf Stack
		XBIOS $10, 14					; => XBIOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		MOVEA.L D0, A0					; Wert auch als Zeiger liefern
		RTS								; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Locksnd( void );
		; ************************************************************
		
	EXPORT Locksnd
	MODULE Locksnd
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS $80, 2			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void *Logbase( void );
		; ************************************************************
		
	EXPORT Logbase
	MODULE Logbase
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS $3, 2				; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		MOVEA.L D0, A0			; Wert als Zeiger liefern
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Metaclose( INT16 drive );
		; ************************************************************
		
	EXPORT Metaclose
	MODULE Metaclose
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; drive auf Stack
		XBIOS $32, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Metadiscinfo( INT16 drive, CD_DISC_INFO *p );
		; ************************************************************
		
	EXPORT Metadiscinfo
	MODULE Metadiscinfo
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; p auf Stack
		MOVE.W D0, -(SP)		; drive auf Stack
		XBIOS $3F, 8			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Metagettoc( INT16 drive, INT16 flag,  CD_TOC_ENTRY *buffer );
		; ************************************************************
		
	EXPORT Metagettoc
	MODULE Metagettoc
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; buffer auf Stack
		MOVE.W D1, -(SP)		; flag auf Stack
		MOVE.W D0, -(SP)		; drive auf Stack
		XBIOS $3E, 10			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Metainit( METAINFO *buffer );
		; ************************************************************
		
	EXPORT Metainit
	MODULE Metainit
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; buffer auf Stack
		XBIOS $30, 6			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Metaioctl( INT16 drive, INT32 magic,
      ;                  INT16 opcode, void *buffer );
		; ************************************************************
		
	EXPORT Metaioctl
	MODULE Metaioctl
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; buffer auf Stack
		MOVE.W D2, -(SP)		; opcode auf Stack
		MOVE.W D1, -(SP)		; magic auf Stack
		MOVE.W D0, -(SP)		; drive auf Stack
		XBIOS $37, 14			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Metaopen ( INT16 drive, META_DRVINFO *buffer );
		; ************************************************************
		
	EXPORT Metaopen
	MODULE Metaopen
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; buffer auf Stack
		MOVE.W D0, -(SP)		; drive auf Stack
		XBIOS $31, 8			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Metaread( INT16 drive, void *buffer,
		;                 INT32 blockno, INT16 count );
		; ************************************************************
		
	EXPORT Metaread
	MODULE Metaread
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D2, -(SP)		; count auf Stack
		MOVE.W D1, -(SP)		; blockno auf Stack
		PEA (A0)					; buffer auf Stack
		MOVE.W D0, -(SP)		; drive auf Stack
		XBIOS $33, 14			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Metasetsongtime( INT16 drive, INT16 repeat, 
      ;                        INT32 starttime, INT32 endtime );
		; ************************************************************
		
	EXPORT Metasetsongtime
	MODULE Metasetsongtime
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W _rsv+4(SP), -(SP)		; endtime auf Stack
		MOVE.L D2, -(SP)		; starttime auf Stack
		MOVE.W D1, -(SP)		; repeat auf Stack
		MOVE.W D0, -(SP)		; drive auf Stack
		XBIOS $3D, 14			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Metastartaudio( INT16 drive, INT16 flag, UCHAR *bytearray );
		; ************************************************************
		
	EXPORT Metastartaudio
	MODULE Metastartaudio
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; bytearray auf Stack
		MOVE.W D1, -(SP)		; flag auf Stack
		MOVE.W D0, -(SP)		; drive auf Stack
		XBIOS $3B, 10			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Metastopaudio( INT16 drive );
		; ************************************************************
		
	EXPORT Metastopaudio
	MODULE Metastopaudio
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; drive auf Stack
		XBIOS $3C, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Metastatus( INT16 drive, void *buffer );
		; ************************************************************
		
	EXPORT Metastatus
	MODULE Metastatus
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; buffer auf Stack
		MOVE.W D0, -(SP)		; drive auf Stack
		XBIOS $36, 8			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Metawrite( INT16 drive, void *buffer,
		;                  INT32 blockno, INT16 count );
		; ************************************************************
		
	EXPORT Metawrite
	MODULE Metawrite
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D2, -(SP)		; count auf Stack
		MOVE.W D1, -(SP)		; blockno auf Stack
		PEA (A0)					; buffer auf Stack
		MOVE.W D0, -(SP)		; drive auf Stack
		XBIOS $34, 14			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Mfpint( INT16 intno, void (*vector)() );
		; ************************************************************
		
	EXPORT Mfpint
	MODULE Mfpint
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; vector auf Stack
		MOVE.W D0, -(SP)		; intno auf Stack
		XBIOS $D, 8				; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Midiws( INT16 cnt, const char *buffer );
		; ************************************************************
		
	EXPORT Midiws
	MODULE Midiws
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; buffer auf Stack
		MOVE.W D0, -(SP)		; cnt auf Stack
		XBIOS $C, 8				; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 NVMaccess( INT16 op, INT16 start,
		;                 INT16 count, BYTE *buffer );
		; ************************************************************
		
	EXPORT NVMaccess
	MODULE NVMaccess
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L A0, -(SP)		; buffer auf Stack
		MOVE.W D2, -(SP)		; count auf Stack
		MOVE.W D1, -(SP)		; start auf Stack
		MOVE.W D0, -(SP)		; op auf Stack
		XBIOS $2E, $C			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Offgibit( INT16 bitno );
		; ************************************************************
		
	EXPORT Offgibit
	MODULE Offgibit
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; bitno auf Stack
		XBIOS $1D, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Ongibit( INT16 bitno );
		; ************************************************************
		
	EXPORT Ongibit
	MODULE Ongibit
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; bitno auf Stack
		XBIOS $1E, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void *Physbase( void );
		; ************************************************************
		
	EXPORT Physbase
	MODULE Physbase
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS 2, 2				; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		MOVEA.L D0, A0			; Wert als Zeiger liefern
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Protobt( void *buf, INT32 serialno,
		;               INT16 disktype, INT16 execflag );
		; ************************************************************
		
	EXPORT Protobt
	MODULE Protobt
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D2, -(SP)		; execflag auf Stack
		MOVE.W D1, -(SP)		; disktype auf Stack
		MOVE.L D0, -(SP)		; serialno auf Stack
		PEA (A0)					; buf auf Stack
		XBIOS $12, 14			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Prtblk( PBDEF *defptr );
		; ************************************************************
		
	EXPORT Prtblk
	MODULE Prtblk
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; defptr auf Stack
		XBIOS $24, 6			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Puntaes( void );
		; ************************************************************
		
	EXPORT Puntaes
	MODULE Puntaes
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS $27, 2			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Random( void );
		; ************************************************************
		
	EXPORT Random
	MODULE Random
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS $11, 2			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; UINT32 Rsconf( INT16 speed, INT16 flowctl, INT16 ucr, INT16 rsr,
		;               INT16 tsr, INT16 scr );
		; ************************************************************
		
	EXPORT Rsconf
	MODULE Rsconf
		
		PCRegSave						; Register fr Pure-C retten
		;
		; Optimierung!
		;
		; Statt
		;
		; MOVE.W _rsv+8(SP), -(SP)	; scr auf Stack
		; MOVE.W _rsv+8(SP), -(SP)	; tsr auf Stack
		;
		; nun:
		;
		MOVE.L _rsv+8(SP), -(SP)	; scr & tsr auf Stack
		MOVE.W _rsv+8(SP), -(SP)	; rsr auf Stack
		MOVE.W D2, -(SP)				; ucr auf Stack
		MOVE.W D1, -(SP)				; flowctl auf Stack
		MOVE.W D0, -(SP)				; speed auf Stack
		XBIOS $F, 14					; => XBIOS-Aufruf
		PCRegLoad						; Register fr Pure-C reparieren
		RTS								; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Scrdmp( void );
		; ************************************************************
		
	EXPORT Scrdmp
	MODULE Scrdmp
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS $14, 2			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Setbuffer( INT16 reg, void *begaddr, void *endaddr );
		; ************************************************************
		
	EXPORT Setbuffer
	MODULE Setbuffer
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A1)					; xyz auf Stack
		PEA (A0)					; xyz auf Stack
		MOVE.W D0, -(SP)		; xyz auf Stack
		XBIOS $83, 12			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Setcolor( INT16 colornum, INT16 color );
		; ************************************************************
		
	EXPORT Setcolor
	MODULE Setcolor
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; color auf Stack
		MOVE.W D0, -(SP)		; colorNum auf Stack
		XBIOS 7, 6				; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Setinterrupt( INT16 mode, INT16 cause );
		; ************************************************************
		
	EXPORT Setinterrupt
	MODULE Setinterrupt
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; cause auf Stack
		MOVE.W D0, -(SP)		; mode auf Stack
		XBIOS $87, 6			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Setmode( INT16 mode );
		; ************************************************************
		
	EXPORT Setmode
	MODULE Setmode
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; mode auf Stack
		XBIOS $84, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Setmontracks( INT16 track );
		; ************************************************************
		
	EXPORT Setmontracks
	MODULE Setmontracks
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; track auf Stack
		XBIOS $86, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Setpalette( INT16 *palettePtr );
		; ************************************************************
		
	EXPORT Setpalette
	MODULE Setpalette
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; palettePtr auf Stack
		XBIOS $6, 6				; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 Setprt( INT16 config );
		; ************************************************************
		
	EXPORT Setprt
	MODULE Setprt
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; config auf Stack
		XBIOS $21, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Setscreen( void *logLoc, void *physLoc, INT16 res );
		; ************************************************************
		
	EXPORT Setscreen
	MODULE Setscreen
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; res auf Stack
		MOVE.L A1, -(SP)		; physLoc auf Stack
		MOVE.L A0, -(SP)		; logLoc auf Stack
		XBIOS 5, 12				; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Settime( INT32 datetime );
		; ************************************************************
		
	EXPORT Settime
	MODULE Settime
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D0, -(SP)		; datetime auf Stack
		XBIOS $16, 6			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Settracks( INT16 playtrack, INT16 rectrack );
		; ************************************************************
		
	EXPORT Settracks
	MODULE Settracks
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; rectrack auf Stack
		MOVE.W D0, -(SP)		; playtrack auf Stack
		XBIOS $85, 6			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Sndstatus( INT16 reset );
		; ************************************************************
		
	EXPORT Sndstatus
	MODULE Sndstatus
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; reset auf Track
		XBIOS $8C, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Soundcmd( INT16 mode, INT16 data );
		; ************************************************************
		
	EXPORT Soundcmd
	MODULE Soundcmd
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; data auf Stack
		MOVE.W D0, -(SP)		; mode auf Stack
		XBIOS $82, 6			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Ssbrk( INT16 amount );
		; ************************************************************
		
	EXPORT Ssbrk
	MODULE Ssbrk
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; amount auf Stack
		XBIOS $1, 4				; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		MOVEA.L D0, A0			; Wert als Zeiger liefern
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Supexec( INT32 (*codeptr)() );
		; ************************************************************
		
	EXPORT Supexec
	MODULE Supexec
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; codeptr auf Stack
		XBIOS $26, 6			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 Unlocksnd( void );
		; ************************************************************
		
	EXPORT Unlocksnd
	MODULE Unlocksnd
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS $81, 2			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32(?) ValidMode( INT16 xyz(?) );
		; ************************************************************
		
	MODULE	ValidMode
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; xyz auf Stack
		XBIOS $5F, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
				
		; ************************************************************
		; INT16 VgetMonitor( void );
		; ************************************************************
		
	EXPORT VgetMonitor
	MODULE VgetMonitor
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS $59, 2			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void VgetRGB( INT16 index, INT16 count, RGB *rgb );
		; ************************************************************
		
	EXPORT VgetRGB
	MODULE VgetRGB
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; rgb auf Stack
		MOVE.W D1, -(SP)		; count auf Stack
		MOVE.W D0, -(SP)		; index auf Stack
		XBIOS $5E, 10			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT32 VgetSize( INT16 mode );
		; ************************************************************
		
	EXPORT VgetSize
	MODULE VgetSize
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; mode auf Stack
		XBIOS $5B, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void VsetMask( INT16 ormask, INT16 andmask, INT16 overlay );
		; ************************************************************
		
	EXPORT VsetMask
	MODULE VsetMask
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D2, -(SP)		; overlay auf Stack
		MOVE.W D1, -(SP)		; andmask auf Stack
		MOVE.W D0, -(SP)		; ormask auf Stack
		XBIOS $5C, 8			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 VsetMode( INT16 mode );
		; ************************************************************
		
	EXPORT VsetMode
	MODULE VsetMode
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; mode auf Stack
		XBIOS $58, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void VsetRGB( INT16 index, INT16 count, RGB *rgb );
		; ************************************************************
		
	EXPORT VsetRGB
	MODULE VsetRGB
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; rgb auf Stack
		MOVE.W D1, -(SP)		; count auf Stack
		MOVE.W D0, -(SP)		; index auf Stack
		XBIOS $5D, 10			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void VsetScreen( void *log, void *phys,
		;                  INT16 mode, INT16 modecode );
		; ************************************************************
		
	EXPORT VsetScreen
	MODULE VsetScreen
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; modecode auf Stack
		MOVE.W D0, -(SP)		; mode auf Stack
		MOVE.L A1, -(SP)		; phys auf Stack
		MOVE.L A0, -(SP)		; log auf Stack
		XBIOS $05, 14			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void _( INT16 external );
		; ************************************************************
		
	EXPORT VsetSync
	MODULE VsetSync
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D0, -(SP)		; external auf Stack
		XBIOS $5A, 4			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Vsync( void );
		; ************************************************************
		
	EXPORT Vsync
	MODULE Vsync
		
		PCRegSave				; Register fr Pure-C retten
		XBIOS $25, 2			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Waketime( UINT16 date, UINT16 time );
		; ************************************************************
		
	EXPORT Waketime
	MODULE Waketime
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.W D1, -(SP)		; rate auf Stack
		MOVE.W D0, -(SP)		; flags auf Stack
		XBIOS $2F, 6			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; INT16 WavePlay( INT16 flags, INT32 rate,
		;                void *sptr, INT32 slen );
		; ************************************************************
		
	EXPORT WavePlay
	MODULE WavePlay
		
		PCRegSave				; Register fr Pure-C retten
		MOVE.L D2, -(SP)		; slen auf Stack
		MOVE.L A0, -(SP)		; sptr auf Stack
		MOVE.L D1, -(SP)		; rate auf Stack
		MOVE.W D0, -(SP)		; flags auf Stack
		XBIOS $A5, 16			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void Xbtimer( INT16 timer, INT16 control, INT16 data,
		;               void (*vec)() );
		; ************************************************************
		
	EXPORT Xbtimer
	MODULE Xbtimer
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; vec auf Stack
		MOVE.W D2, -(SP)		; data auf Stack
		MOVE.W D1, -(SP)		; control auf Stack
		MOVE.W D0, -(SP)		; timer auf Stack
		XBIOS $1F, 12			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void CacheCtrl( int16 opcode, int16 param );
		; ************************************************************
		
	EXPORT CacheCtrl
	MODULE CacheCtrl
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; vec auf Stack
		MOVE.W D1, -(SP)		; control auf Stack
		MOVE.W D0, -(SP)		; timer auf Stack
		XBIOS $A0, 12			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void WdgCtrl( int16 opcode );
		; ************************************************************
		
	EXPORT WdgCtrl
	MODULE WdgCtrl
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; vec auf Stack
		MOVE.W D0, -(SP)		; timer auf Stack
		XBIOS $A1, 12			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
		; ************************************************************
		; void ExtRsConf( int16 command, int16 dev, int32 param );
		; ************************************************************
		
	EXPORT ExtRsConf
	MODULE ExtRsConf
		
		PCRegSave				; Register fr Pure-C retten
		PEA (A0)					; vec auf Stack
		MOVE.L D2, -(SP)		; timer auf Stack
		MOVE.W D1, -(SP)		; timer auf Stack
		MOVE.W D0, -(SP)		; timer auf Stack
		XBIOS $A2, 12			; => XBIOS-Aufruf
		PCRegLoad				; Register fr Pure-C reparieren
		RTS						; ... und zurck
		
	ENDMOD
		
