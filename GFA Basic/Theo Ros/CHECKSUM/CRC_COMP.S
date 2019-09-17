; =============================================================================
;
; CRC_COMP()
;
; This routine returns the CRC checksum for a given block of bytes.
; It provides (I think) the best of both worlds:
; Where CRC_CALC() creates a table each time it is called and
; CRC_TABL() has built in tables, using a lot of bytes all the time,
; CRC_COMP() first lets the calling program claim space for a table
; and initialise it using C:crc_comp%(FALSE,..)
; This table is then used for as often as needed with C:crc_comp%(TRUE,..)
; When CRC checking is done, the program can simply free the memory used 
; for the table(s).
;
; CRC checksums are used in modem programs to check if a block is
; transferred properly (usually 16-bit CCITT or 32-bit ANSI) and
; also in file-crunch programs:
;
; 16-bit CCITT	used in higher modem protocols (Ymodem, Zmodem)
; 16-bit Arctype	used in ARC, ZOO, LHARC and DC_CRC.PRG
; 16-bit XMDM	used in Xmodem protocol (I think..)
; 32-bit ANSI	used in ZIP,ARJ and Zmodem protocol
;
; You COULD also use crc's to check the files on your disk to keep
; them absolutely virus-free (DC_CRC). In that case, remember that
; SOME programs have self-modifying code...
;
; Calling this routine from GfA is a three-step process:
;
; 1) claim memory and initialise it:
;    table%=MALLOC(512)	! claim memory for table
;			!  512 bytes for 16-bit CRC's,
;			! 1024 bytes for 32-bit CRC
;    ~C:crc_comp%(FALSE,type&,L:table%)
;
; 2) after this you can use this table again and again:
;
;    crc%=C:crc_comp%(TRUE,type&,L:previous%,L:length%,L:block%,L:table%)
;
; 3) when you're finished clear up memory with ~MFREE(table%)
;
; where:	first parameter is a WORD value:
;		= FALSE (0) , means CREATE table at address table%
;		= TRUE (<>0), means USE table at address table% 
;	type&	= 0: return CRC-16-CCITT checksum
;		= 1: return CRC-16 Arctype checksum
;		= 2: return CRC-16 Xmodem checksum
;		=>3: return CRC-32 ANSI checksum
; (*)	previous% the checksum calculated from earlier block(s)
;		normally 0, when the full block is in memory,
;		or at the start of computation.
;		If memory is short, you can cut a file in
;		several shorter chunks. (see the GFA listing for this)
; (*)	length%	the length of the block in bytes
; (*)	block%	the address of the block in memory
;	table%	the address of the CRC-table, filled in earlier
;		with routine CRC_INIT()
;
; parameters preceeded by (*) are ONLY passed when function is called
; to USE a table for CRC calculation. (so when 1st parameter is TRUE)
;
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> WARNING <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; To save execution time, CRC_COMP() does NOT check if a table
; matches the desired type& or indeed if the table exists !!
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> WARNING <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;
; CRC_COMP() was written in Devpac3 assembler to produce an Atari
; Executable file CRC_COMP.PRG of 292 bytes. Stripping off the
; first 28 bytes leaves you with the CRC_COMP.INL of 264 bytes.
;
; Theo Ros  15/10/1997 
; 
; =============================================================================

crc_comp:	tst.w	4(sp)		; check if CREATE or USE table
	beq	init_table	; FALSE --> create table

	movem.l	8(sp),d0-d1/a0-a1	; previous%,length%,block%,table%
	move.w	6(sp),d2		; check opcode type&
	beq.s	crc16_ccitt	; type& = 0: CRC-16-CCITT
	cmpi.w	#1,d2		; type& = 1: CRC-16 ARC
	beq.s	crc16_arc
	cmpi.w	#2,d2		; type& = 2: CRC-16 XMODEM
	beq.s	crc16_xmdm
	; falls through to CRC32 	; type&  =>3

; =============================================================================
; crc32	XOR: x^32+x^26+x^23+x^22+x^16+x^12+x^11+x^10+x^8+x^7+x^5+x^4+x^2+x+1
; =============================================================================

crc_32:	not.l	d0		; init previous%

next_32:	subq.l	#1,d1		; any bytes left to do?
	bmi.s	exit_32
	moveq	#0,d2   
	move.b	(a0)+,d2
	eor.b	d0,d2
	lsr.l	#8,d0
	lsl.w	#2,d2
	move.l	(a1,d2.w),d2
	eor.l	d2,d0
	bra.s	next_32

exit_32:	not.l	d0
	rts
	
; =============================================================================
; crc16_ccitt	XOR: x^16+x^12+x^5+1
; =============================================================================

crc16_ccitt:
	subq.l	#1,d1		; any bytes left to do?
	bmi.s	exit_16
	moveq	#0,d2   
	move.b	(a0)+,d2	
	ror.w	#8,d0
	eor.b	d0,d2
	add.w	d2,d2
	move.w	(a1,d2.w),d2
	clr.b	d0
	eor.w	d2,d0
	bra.s	crc16_ccitt
	
exit_16:	andi.l	#$ffff,d0		; return 16 bit value
	rts

; =============================================================================
; crc16_arc	XOR: x^16+x^15+x^13+1
; =============================================================================

crc16_arc:
	cmpi.l	#$4001,d1		; max. chunklength = &H4000
	blt.s	do_a16		; so, if length% > 16384
	lea	$4000(a0),a0	; move pointer to last part
	subi.l	#$4000,d1		; and adjust length
	bra.s	crc16_arc

do_a16:	ror.w	#8,d0		; init previous% (intel-->motorola)
	bsr.s	crc_16
	ror.w	#8,d0		; return INTEL format, since this
	bra.s	exit_16		; is used in ARC, ZOO and LHARC

; =============================================================================
; crc16_xmdm	XOR: x^16+x^15+x^2+1
; =============================================================================

crc16_xmdm:
	not.w	d0		; init previous%
	bsr.s	crc_16
	not.w	d0
	bra.s	exit_16

; =============================================================================
; subroutine crc_16 handles both 16-bit ARC type and 16-bit XMODEM type
; =============================================================================

crc_16:	subq.l	#1,d1		; any bytes left to do?
	bmi.s	return
	moveq	#0,d2   
	move.b	(a0)+,d2
	eor.b	d0,d2
	add.w	d2,d2
	move.w	(a1,d2.w),d2
	lsr.w	#8,d0
	eor.w	d2,d0
	bra.s	crc_16
return:	rts

; =============================================================================
; *****************************************************************************
; From here, it all has to do with CREATING a CRC table
; *****************************************************************************
; =============================================================================

init_table:
	move.l	8(sp),a0		; get address for table
	moveq	#0,d0		; init to 0
	move.w	6(sp),d2		; check CRC type&
	beq.s	tab16_ccitt	; type& = 0: CRC-16-CCITT
	cmpi.w	#1,d2		; type& = 1: CRC-16 ARC
	beq.s	tab16_arc
	cmpi.w	#2,d2		; type& = 2: CRC-16 XMODEM
	beq.s	tab16_xmdm
	; falls through to tab_32 	; type&  =>3

; =============================================================================
; create table 1024 bytes for CRC 32-bit
; =============================================================================

tab_32:	move.l	d0,d2
	moveq	#7,d1
t32_bit:	lsr.l	#1,d2
	bcc.s	t32_next
	eori.l	#$edb88320,d2
t32_next:	dbra	d1,t32_bit
	move.l	d2,(a0)+
	addq.b	#1,d0
	bne.s	tab_32
	rts
	
; =============================================================================
; create table 512 bytes for CRC 16-bit CCITT
; =============================================================================

tab16_ccitt:
	move.l	d0,d2	
	moveq	#7,d1
t16_bit:	add.w	d2,d2		; or: lsl.w #1,d2
	bcc.s	t16_next 
	eori.w	#$1021,d2
t16_next:	dbra 	d1,t16_bit
	move.w	d2,(a0)+
	addi.w	#$100,d0		; count in WORDS:
	bne.s	tab16_ccitt	; (0-$FF00, then back to 0)
	rts

; =============================================================================
; create table 512 bytes for CRC 16-bit ARC
; =============================================================================

tab16_arc:
	move.w	#$a001,d3
	bra.s	table_16

; =============================================================================
; create table 512 bytes for CRC 16-bit XMODEM
; =============================================================================

tab16_xmdm:
	move.w	#$8408,d3
	; falls through to subroutine crc16_tab
	
; =============================================================================
; subroutine table_16 handles both 16-bit ARC type and 16-bit XMODEM type
; =============================================================================

table_16:	move.l	d0,d2	
	moveq	#7,d1
tab_bit:	lsr.w	#1,d2
	bcc.s	tab_next
	eor.w	d3,d2		; $A001 for ARC type, $8408 for XMODEM
tab_next:	dbra 	d1,tab_bit
	move.w	d2,(a0)+
	addq.b	#1,d0		; count in BYTES:
	bne.s	table_16		; (0-255, then back to 0)
	rts
	