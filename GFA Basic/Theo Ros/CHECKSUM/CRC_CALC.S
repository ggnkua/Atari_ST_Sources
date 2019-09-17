; =============================================================================
;
; CRC_CALC()
;
; This routine returns the CRC checksum for a given block of bytes.
; It does this by reading the mask_values from tables it first creates.
; This method doesn't take as much memory as CRC_TABL(), but is a bit
; slower. Because this method builds the appropriate table everytime
; you call it, it is recommended you use CRC_TABL() or CRC_COMP()
; if your program needs to do repeated CRC-ing.
; The tables are built on the stack, so there is no need to allocate
; memory for them, but you DO need to have a stack of at least 1Kb.
; (GfA claims a stack of 4 Kb, so no need to worry)
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
; Call from GfA: crc%=C:crc_calc%(W:type&,L:previous%,L:length%,L:block%)
;
; where:	type&	= 0: return CRC-16-CCITT checksum
;		= 1: return CRC-16 Arctype checksum
;		= 2: return CRC-16 Xmodem checksum
;		=>3: return CRC-32 ANSI checksum
;	previous% the checksum calculated from earlier block(s)
;		normally 0, when the full block is in memory,
;		or at the start of computation.
;		If memory is short, you can cut a file in
;		several shorter chunks. (see crc_file() for this)
;	length%	the length of the block in bytes
;	block%	the address of the block in memory
;
; CRC_CALC() was written in Devpac3 assembler to produce an Atari
; Executable file CRC_CALC.PRG of 314 bytes. Stripping off the
; first 28 bytes leaves you with the CRC_CALC.INL of 286 bytes.
;
; Theo Ros  15/10/1997
; 
; =============================================================================

crc_calc:	moveq	#0,d0		; initialise d0 to build tables
	subq.b	#1,d0		; and have a1 point at stack, from
	lea	(sp),a1		; where tables are built backwards

	move.w	4(sp),d2		; check opcode type&
	beq.s	crc16_ccitt	; type& = 0: CRC-16-CCITT
	cmpi.w	#1,d2		; type& = 1: CRC-16 ARC
	beq	crc16_arc
	cmpi.w	#2,d2		; type& = 2: CRC-16 XMODEM
	beq	crc16_xmdm
	; falls through to CRC32 	; type&  =>3

; =============================================================================
; crc32	XOR: x^32+x^26+x^23+x^22+x^16+x^12+x^11+x^10+x^8+x^7+x^5+x^4+x^2+x+1
; =============================================================================

crc_32:	move.l	d0,d2		; build table 1024 bytes
	moveq	#7,d1
c32_bit:	lsr.l	#1,d2
	bcc.s	c32_next
	eori.l	#$edb88320,d2
c32_next:	dbra	d1,c32_bit
	move.l	d2,-(a1)		; buffer BACKWARDS leaves a1
	dbra	d0,crc_32		; pointing at start of table

	; ===========================================
	; as of here, calculate CRC:
	; d0=previous crc value or 0 (no previous)
	; d1=length of filebuffer
	; d2=byte taken from file
	; a0=filebuffer
	; a1=address of table
	; ===========================================

	movem.l	6(sp),d0-d1/a0	; get previous%,length% and block%
	not.l	d0		; init previous%
				; a1 already holds address of table
loop_32:	subq.l	#1,d1		; any bytes left to do?
	bmi.s	exit_32
	moveq	#0,d2   
	move.b	(a0)+,d2
	eor.b	d0,d2
	lsr.l	#8,d0
	lsl.w	#2,d2
	move.l	(a1,d2.w),d2
	eor.l	d2,d0
	bra.s	loop_32

exit_32:	not.l	d0
	rts
	
; =============================================================================
; crc16_ccitt	XOR: x^16+x^12+x^5+1
; =============================================================================

crc16_ccitt:
	move.l	d0,d2		; build table 512 bytes
	lsl.w	#8,d2
	moveq	#7,d1
c16_bit:	add.w	d2,d2		; or: lsl.w #1,d2
	bcc.s	c16_next 
	eori.w	#$1021,d2
c16_next:	dbra 	d1,c16_bit
	move.w	d2,-(a1)
	dbra	d0,crc16_ccitt

	; ===========================================
	; as of here, calculate CRC:
	; d0=previous crc value or 0 (no previous)
	; d1=length of filebuffer
	; d2=byte taken from file
	; a0=filebuffer
	; a1=address of table
	; ===========================================

	movem.l	6(sp),d0-d1/a0	; get previous%,length% and block%
	
loop_c16:	subq.l	#1,d1		; any bytes left to do?
	bmi.s	exit_16
	moveq	#0,d2   
	move.b	(a0)+,d2	
	ror.w	#8,d0
	eor.b	d0,d2
	add.w	d2,d2
	move.w	(a1,d2.w),d2
	clr.b	d0
	eor.w	d2,d0
	bra.s	loop_c16
	
exit_16:	andi.l	#$ffff,d0		; return 16 bit value
	rts

; =============================================================================
; crc16_arc	XOR: x^16+x^15+x^13+1
; =============================================================================

crc16_arc:
	move.l	d0,d2		; build table 512 bytes
	moveq	#7,d1
a16_bit:	lsr.w	#1,d2
	bcc.s	a16_next
	eori.w	#$a001,d2		
a16_next:	dbra 	d1,a16_bit
	move.w	d2,-(a1)		; buffer BACKWARDS leaves a1
	dbra	d0,crc16_arc	; pointing at start of table
	
	; ===========================================
	; as of here, calculate CRC:
	; d0=previous crc value or 0 (no previous)
	; d1=length of filebuffer
	; d2=byte taken from file
	; a0=filebuffer
	; a1=address of table
	; ===========================================

	movem.l	6(sp),d0-d1/a0	; get previous%,length% and block%
	ror.w	#8,d0		; init previous% (intel<>motorola)
	
a16_size:	cmpi.l	#$4001,d1		; max. chunklength = &H4000
	blt.s	loop_a16		; so, if length% > 16384
	lea	$4000(a0),a0	; move pointer to last part
	subi.l	#$4000,d1		; and adjust length
	bra.s	a16_size
	
loop_a16:	subq.l	#1,d1		; any bytes left to do?
	bmi.s	exit_a16		; although this loop is the
	moveq	#0,d2		; same as for 16-bit Xmodem,
	move.b	(a0)+,d2		; you cannot bsr to a shared
	eor.b	d0,d2		; subroutine, because this will
	add.w	d2,d2		; affect the StackPointer and
	move.w	0(a1,d2.w),d2	; destroy the table held there..
	lsr.w	#8,d0
	eor.w	d2,d0
	bra.s	loop_a16

exit_a16:	ror.w	#8,d0		; return INTEL format, since
	bra.s	exit_16		; this is used in ARC, ZOO and LHARC

; =============================================================================
; crc16_xmdm	XOR: x^16+x^15+x^2+1
; =============================================================================

crc16_xmdm:
	move.l	d0,d2		; build table 512 bytes
	moveq	#7,d1
x16_bit:	lsr.w	#1,d2
	bcc.s	x16_next
	eori.w	#$8408,d2		; or use: -$7bf8
x16_next:	dbra 	d1,x16_bit
	move.w	d2,-(a1)		; buffer BACKWARDS leaves a1
	dbra	d0,crc16_xmdm	; pointing at start of table

	; ===========================================
	; as of here, calculate CRC:
	; d0=previous crc value or 0 (no previous)
	; d1=length of filebuffer
	; d2=byte taken from file
	; a0=filebuffer
	; a1=address of table
	; ===========================================

	movem.l	6(sp),d0-d1/a0	; get previous%,length% and block%
	not.w	d0		; init previous%
	
loop_x16:	subq.l	#1,d1		; any bytes left to do?
	bmi.s	exit_x16
	moveq	#0,d2   
	move.b	(a0)+,d2
	eor.b	d0,d2
	add.w	d2,d2
	move.w	(a1,d2.w),d2
	lsr.w	#8,d0
	eor.w	d2,d0
	bra.s	loop_x16

exit_x16:	not.w	d0
	bra	exit_16
