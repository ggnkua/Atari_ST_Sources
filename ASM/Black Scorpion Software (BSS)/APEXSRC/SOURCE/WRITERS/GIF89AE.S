*-----------------------------------------------------------------------*
*	GIF89a incremental encoder					*
*-----------------------------------------------------------------------*

*-----------------------------------------------------------------------*
_MAXBITS	=	12
_MAXCODE	=	(1<<_MAXBITS)-1
_CLEARCODE	=	256
_EOFCODE	=	257
_FREECODE	=	258
_HASHSIZE	=	5003
*-----------------------------------------------------------------------*
OPENERROR	=	-1
WRITEERROR	=	-2
CLOSEERROR	=	-3
*-----------------------------------------------------------------------*
;TEST:
*-----------------------------------------------------------------------*

			rsreset
FILE_BUFFER_SIZE:	rs.b	1024
HASH_CODE_SIZE:		rs.w	_HASHSIZE
HASH_PREFIX_SIZE:	rs.w	_HASHSIZE
HASH_SUFFIX_SIZE:	rs.b	_HASHSIZE
GIFWRITE_BUFLEN:	rs.b	0

*-----------------------------------------------------------------------*

Init_GIF_Writer:
	lea		FILE_BUFFER_SIZE(a0),a1
	move.l		a1,FILE_BUFFER
	lea		HASH_CODE_SIZE(a0),a1
	move.l		a1,HASH_CODE
	lea		HASH_PREFIX_SIZE(a0),a1
	move.l		a1,HASH_PREFIX
	lea		HASH_SUFFIX_SIZE(a0),a1
	move.l		a1,HASH_SUFFIX
	rts

*-------------------------------------------------------*

ascii_signature:	dc.b	'GIF89a',0
ascii_application:	dc.b	'<anonymous>',0
			even
			
*-------------------------------------------------------*
open_gif:
*-------------------------------------------------------*
	tst.b		gif_open
	bne		.done
*-------------------------------------------------------*
*	Create file					*
*-------------------------------------------------------*
	move.l		GIF_NAME,a0
	jsr		CreateFile
	move.w		d0,F_HANDLE
	bpl.s		.nxt1
	moveq		#-1,d0
	bra		.done
*-------------------------------------------------------*
*	Output buffer pointer				*
*-------------------------------------------------------*
.nxt1:	move.l		FILE_BUFFER,a6
*-------------------------------------------------------*
*	Output signature				*
*-------------------------------------------------------*
	lea		ascii_signature,a0
	bsr		output_string
*-------------------------------------------------------*
*	Screen descriptor				*
*-------------------------------------------------------*
	move.w		GIFWIDTH,d0
	bsr		output_word
	move.w		GIFHEIGHT,d0
	bsr		output_word
	move.b		#%11110111,d0
	bsr		output_byte			; flags (mccc0ppp)
	move.b		bgcolour,d0
	bsr		output_byte			; bg colour
	moveq		#0,d0
	bsr		output_byte			; aspect ratio
*-------------------------------------------------------*
*	Global colour table				*	
*-------------------------------------------------------*
	move.w		#256-1,d7
	move.l		GIFPAL_P,a0
.loop:	addq.l		#1,a0
	move.b		(a0)+,d0
	bsr		output_byte
	move.b		(a0)+,d0
	bsr		output_byte
	move.b		(a0)+,d0
	bsr		output_byte
	dbra		d7,.loop
*-------------------------------------------------------*
*	Application extension block			*
*-------------------------------------------------------*
	moveq		#'!',d0
	bsr		output_byte			; extension block introducer
	move.b		#$FF,d0
	bsr		output_byte			; application extension identifier
*-------------------------------------------------------*
	moveq		#11,d0
	bsr		output_byte			; block size
	lea		ascii_application,a0
	bsr		output_string
*-------------------------------------------------------*
	moveq		#0,d0
	bsr		output_byte			; block terminator
*-------------------------------------------------------*
*	Flush buffer					*
*-------------------------------------------------------*
	bsr		FlushFile
*-------------------------------------------------------*
	st		gif_open
*-------------------------------------------------------*
.done:	rts	
	

*-------------------------------------------------------*
close_gif:
*-------------------------------------------------------*
	tst.b		gif_open
	beq		.done
*-------------------------------------------------------*
*	Output buffer pointer				*
*-------------------------------------------------------*
	move.l		FILE_BUFFER,a6
*-------------------------------------------------------*
*	Terminate stream				*
*-------------------------------------------------------*
	moveq		#';',d0
	bsr		output_byte
*-------------------------------------------------------*
*	Flush buffer					*
*-------------------------------------------------------*
	bsr		FlushFile
*-------------------------------------------------------*
*	Close file					*
*-------------------------------------------------------*
	move.w		F_HANDLE,d0
	jsr		CloseFile		* Close file
*-------------------------------------------------------*
	sf		gif_open
*-------------------------------------------------------*
.done:	rts

GifError:
	move.l		STACK_P,sp		* Restore stack pointer
	rts



*-------------------------------------------------------*
append_gif:
*-------------------------------------------------------*
	move.l		sp,STACK_P
*-------------------------------------------------------*
	move.l		FILE_BUFFER,a6
*-------------------------------------------------------*
*	Graphic control extension block			*
*-------------------------------------------------------*
	moveq		#'!',d0
	bsr		output_byte			; extension block introducer
	move.b		#$F9,d0
	bsr		output_byte			; graphic extension identifier
*-------------------------------------------------------*
	moveq		#4,d0
	bsr		output_byte			; block size	
	move.b		disposal,d0
	lsl.b		#2,d0
	tst.b		transparent_flag
	beq.s		.nt	
	or.b		#%00000001,d0
.nt:	bsr		output_byte			; packed fields
	move.l		gif_delay,d0	
	bsr		output_word			; delay period
	move.b		bgcolour,d0
	bsr		output_byte			; transparent index
*-------------------------------------------------------*
	moveq		#0,d0
	bsr		output_byte			; block terminator
*-------------------------------------------------------*
*	Image descriptor block				*
*-------------------------------------------------------*
	moveq		#',',d0
	bsr		output_byte			; image separator
*-------------------------------------------------------*
	move.w		gif_xoff,d0
	bsr		output_word			; x
	move.w		gif_yoff,d0
	bsr		output_word			; y
	move.w		GIFWIDTH,d0
	bsr		output_word			; w
	move.w		GIFHEIGHT,d0
	bsr		output_word			; h
	moveq		#0,d0
	tst.b		interlace_flag
	beq.s		.ni
	or.b		#1<<6,d0
.ni:	bsr		output_byte			; packed fields
*-------------------------------------------------------*
*	LZW code size leader				*
*-------------------------------------------------------*
	moveq		#8,d0
	bsr		output_byte			; minimum code size
*-------------------------------------------------------*
*	Flush everything so far				*
*-------------------------------------------------------*
	bsr		FlushFile
*-------------------------------------------------------*
*	Initialise compressor				*
*-------------------------------------------------------*
	bsr		CompressInit
*-------------------------------------------------------*
*	Compress rectangle				*
*-------------------------------------------------------*
	bsr		compress_rectangle
*-------------------------------------------------------*
*	Close compressor				*
*-------------------------------------------------------*
	bsr		CompressTerm
*-------------------------------------------------------*
*	Head last block (and terminate if non-zero)	*
*-------------------------------------------------------*
	move.w		BYTECOUNT,d0
	move.l		PACKET_P,a0
	move.b		d0,(a0)		* Head last packet.
	beq.s		.stop
	moveq		#0,d0
	bsr		output_byte
*-------------------------------------------------------*
*	Flush last block				*
*-------------------------------------------------------*
.stop:	bsr		FlushFile
	move.l		STACK_P,sp
	rts

*-------------------------------------------------------*
compress_rectangle:
*-------------------------------------------------------*
	tst.b		interlace_flag
	beq.s		.compress_normal
*-------------------------------------------------------*
.compress_interlaced:
*-------------------------------------------------------*
*	Group #1					*
*-------------------------------------------------------*
	lea		group1_cinfo,a5
	bsr		compress_lines
*-------------------------------------------------------*
*	Group #2					*
*-------------------------------------------------------*
	lea		group2_cinfo,a5
	bsr		compress_lines
*-------------------------------------------------------*
*	Group #3					*
*-------------------------------------------------------*
	lea		group3_cinfo,a5
	bsr		compress_lines
*-------------------------------------------------------*
*	Group #4					*
*-------------------------------------------------------*
	lea		group4_cinfo,a5
	bsr		compress_lines
*-------------------------------------------------------*
	bra.s		.compress_done
*-------------------------------------------------------*
.compress_normal:
*-------------------------------------------------------*
	lea		normal_cinfo,a5
	bsr		compress_lines
*-------------------------------------------------------*
.compress_done:
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*

normal_cinfo:	dc.w		0,0
group1_cinfo:	dc.w		3,0
group2_cinfo:	dc.w		3,4
group3_cinfo:	dc.w		2,2
group4_cinfo:	dc.w		1,1

*-------------------------------------------------------*
compress_lines:
*-------------------------------------------------------*
	move.w		d1,-(sp)
*-------------------------------------------------------*
	move.w		(a5)+,d1
*-------------------------------------------------------*
	moveq		#1,d5
	lsl.w		d1,d5
	move.w		d5,cinc
*-------------------------------------------------------*
	moveq		#0,d5
	move.w		gif_linewidth,d5
	lsl.l		d1,d5
	move.l		d5,cskip
*-------------------------------------------------------*
	move.w		(a5)+,d1
*-------------------------------------------------------*
	move.w		d1,cline		; line index
*-------------------------------------------------------*
	move.l		GIFPIC_P,a5
	move.w		gif_yoff,d5
	add.w		d1,d5			; index data
	mulu.w		gif_linewidth,d5
	add.l		d5,a5
	add.w		gif_xoff,a5
*-------------------------------------------------------*
	move.w		(sp)+,d1
*-------------------------------------------------------*
	bra.s		.yst
.ylp:	move.l		a5,-(sp)
	move.w		GIFWIDTH,d5
	subq.w		#1,d5
.xlp:	move.b		(a5)+,d0
	bsr		CompressByte
	dbra		d5,.xlp
	move.l		(sp)+,a5
	add.l		cskip,a5
	move.w		cline,d5
	add.w		cinc,d5
	move.w		d5,cline
.yst:	move.w		cline,d5
	cmp.w		GIFHEIGHT,d5
	bmi.s		.ylp
	rts
	
cinc:			ds.w	1
cline:			ds.w	1
cskip:			ds.l	1

*-------------------------------------------------------*
output_string:
*-------------------------------------------------------*
.cont:	move.b		(a0)+,d0
	beq.s		.stop
	move.b		d0,(a6)+
	bra.s		.cont
.stop:	rts

*-------------------------------------------------------*
output_long:
*-------------------------------------------------------*
	ror.w		#8,d0
	move.w		d0,(a6)+
	swap		d0
	ror.w		#8,d0
	move.w		d0,(a6)+
	rts

*-------------------------------------------------------*
output_word:
*-------------------------------------------------------*
	ror.w		#8,d0
	move.w		d0,(a6)+
	rts

*-------------------------------------------------------*
output_byte:
*-------------------------------------------------------*
	move.b		d0,(a6)+
	rts

*--------------------------------------------------------------------------*
* Init compressor.
*--------------------------------------------------------------------------*
CompressInit:
		clr.w		FIRSTBYTE
		clr.w		WAITINGCODE
		clr.w		TOPBITS
		clr.l		OUTDAT
		bsr		SetupBytesInPacket
		move.w		#9,NUMBITS
		bsr		ClearTable
		rts

*--------------------------------------------------------------------------*
* Finish compression.
*--------------------------------------------------------------------------*
CompressTerm:
		tst.w		FIRSTBYTE
		beq.s		.skp
		move.w		WAITINGCODE,d0
		bsr		OutputNbits
.skp:		move.w		#_EOFCODE,d0
		bsr		OutputNbits
		bsr		OutputForce
		rts

*--------------------------------------------------------------------------*
* Code to clear tables and set up vars for going again.
*--------------------------------------------------------------------------*
ClearTable:	bsr		ClearHashTable
		move.w		#_CLEARCODE,d0
		bsr		OutputNbits		; output clear code into gif stream.
		move.w		#9,NUMBITS
		move.w		#_FREECODE,FREECODE
		rts

*--------------------------------------------------------------------------*
* Code to clear hash table.
*--------------------------------------------------------------------------*
ClearHashTable:
		move.l	HASH_CODE,a0
		moveq		#0,d0
		move.w	#_HASHSIZE-1,d1
.wp:		move.w	d0,(a0)+
		dbra		d1,.wp
		rts

*--------------------------------------------------------------------------*
* Setup space for byte size details in the packet.
*--------------------------------------------------------------------------*
SetupBytesInPacket:
		move.w		#0,BYTECOUNT
		move.l		a6,PACKET_P
		move.b		#0,(a6)+
		rts

*--------------------------------------------------------------------------*
* Accept and compress one 8 bit byte in d0
*--------------------------------------------------------------------------*
CompressByte:
		and.w		#$ff,d0
		tst.w		FIRSTBYTE
		bne.s		.notfirstcall
		move.w	d0,WAITINGCODE
		not.w		FIRSTBYTE
		rts
.notfirstcall:
		move.l	HASH_CODE,a0
		move.l	HASH_PREFIX,a1
		move.l	HASH_SUFFIX,a2
		moveq		#0,d1			* i
		move.b	d0,d1
		lsl.w		#_MAXBITS-8,d1
		add.w		WAITINGCODE,d1	* i = c<<(maxbits-8)+waitingcode
		cmp.w		#_HASHSIZE,d1
		blt.s		.skp
		sub.w		#_HASHSIZE,d1	* i -= _HASHSIZE
.skp:
*
* Do first hash.
*
		tst.w		(a0,d1.w*2)		* hash_code[i] == 0L
		beq.s		.wend
		move.w	WAITINGCODE,d2
		cmp.w		(a1,d1.w*2),d2	* hash_prefix[i] == WAITINGCODE
		bne.s		.skp2
		cmp.b		(a2,d1.w),d0	* hash_suffix[i] == c
		bne.s		.skp2
		move.w	(a0,d1.w*2),WAITINGCODE
		rts
.skp2:
*
* Secondary hash.
*
		moveq		#1,d2
		tst.w		d1
		beq.s		.while
		move.w	#_HASHSIZE,d2
		sub.w		d1,d2			* d1 = i d2 = disp
.while:	sub.w		d2,d1			* i -= disp
		cmp.w		#0,d1
		bge.s		.skp3
		add.w		#_HASHSIZE,d1	* if i < 0 then i += HSIZE
.skp3:	tst.w		(a0,d1.w*2)		* hash_code[i] == 0
		beq.s		.wend				* empty slot!
		move.w	WAITINGCODE,d3
		cmp.w		(a1,d1.w*2),d3	* hash_prefix[i] == WAITINGCODE
		bne.s		.while			* else loop
		cmp.b		(a2,d1.w),d0	* hash_suffix[i] == c
		bne.s		.while			* else loop
		move.w	(a0,d1.w*2),WAITINGCODE
		rts
*
* Desired symbol not in table.
*
.wend:	movem.l	d0-d1/a0-a2,-(sp)
		move.w	WAITINGCODE,d0
		bsr		OutputNbits
		movem.l	(sp)+,d0-d1/a0-a2

		move.w	d0,-(sp)		* push c onto stack
*
* Have we run out of table entry's?
*
		move.w	FREECODE,d7
		cmp.w		#_MAXCODE,d7
		bgt.s		.out_of_tab
*
* Enter new code's into hash table.
*
		move.w	d7,(a0,d1.w*2)		* hash_code[i] = freecode
		addq.w	#1,FREECODE
		move.w	WAITINGCODE,(a1,d1.w*2) * hash_prefix[i]=waitingcode
		move.b	d0,(a2,d1.w)		* hash_suffix[i]=c
		bra.s		.end
*
* Run out of table..
*
.out_of_tab:bsr		ClearTable
.end:		move.w	(sp)+,WAITINGCODE
		rts


;*--------------------------------------------------------------------------*
;* Output intel style word. ( wot fun! )
;*--------------------------------------------------------------------------*
;PutWord:	movem.l	d0/d1,-(sp)
;		move.w	d0,d1
;		PUTBYTE	d1
;		lsr.w		#8,d1
;		PUTBYTE	d1
;		movem.l	(sp)+,d0/d1
;		rts

*--------------------------------------------------------------------------*
* Output a n bit code byte.
*--------------------------------------------------------------------------*
OutputNbits:moveq		#0,d2
		move.w	d0,d2
		move.l	OUTDAT,d0
		moveq		#0,d1
		move.w	TOPBITS,d1
		lsl.l		d1,d2
		or.l		d2,d0
		move.w	NUMBITS,d2
		add.w		d2,d1
		move.w	BYTECOUNT,d7

.outlp:	cmp.w		#8,d1
		blt.s		.out
		subq.w	#8,d1

		move.b	d0,(a6)+
;		PUTBYTE	d0

		lsr.l		#8,d0
		addq.w	#1,d7

		cmp.w		#256-1,d7
		bne.s		._skp
		move.l	PACKET_P,a0
		move.b	#$ff,(a0)		* Head packet.

		bsr		FlushFile		* Wap it out onto the disk.
		bsr		SetupBytesInPacket
		moveq		#0,d7
._skp:	bra.s		.outlp

.out:		move.w	d7,BYTECOUNT
		move.w	d1,TOPBITS
		move.l	d0,OUTDAT
*
* See about increasing code length
*
		moveq		#1,d7
		move.w	NUMBITS,d6
		cmp.w		#_MAXBITS,d6
		beq.s		.skp
		lsl.w		d6,d7
		cmp.w		FREECODE,d7
		bne.s		.skp
.oy:		addq.w	#1,NUMBITS
.skp:		rts

*--------------------------------------------------------------------------*
* Force out last few bits..
*--------------------------------------------------------------------------*
OutputForce:move.w	TOPBITS,d7
		move.l	OUTDAT,d0
.lp		tst.w		d7
		ble.s		.out

		move.b	d0,(a6)+
;		PUTBYTE	d0

		addq.w	#1,BYTECOUNT
		cmp.w		#256-1,BYTECOUNT
		bne.s		._skp
		movem.l	a0-a5/d0-d7,-(sp)
		move.l	PACKET_P,a0
		move.b	#$ff,(a0)		* Head packet.
		bsr		FlushFile		* Wap it out onto the disk.
		bsr		SetupBytesInPacket
		movem.l	(sp)+,a0-a5/d0-d7
._skp		lsr.l		#8,d0
		subq.w	#8,d7
		bra.s		.lp
.out		rts

*--------------------------------------------------------------------------*
* Flush file buffer.
*--------------------------------------------------------------------------*
FlushFile:	movem.l		a0-a6/d0-d7,-(sp)
		move.l		FILE_BUFFER,d2		* buffer pointer
		move.l		a6,d1
		sub.l		d2,d1			* size
		move.l		d2,a0
		move.w		F_HANDLE,d0		* file handle.
		jsr		WriteFile
		tst.l		d0
		bpl.s		.nxt
		move.w		F_HANDLE,d0
		jsr		CloseFile		* on write error we must close file.
		move.l		#WRITEERROR,d0
		bra		GifError
.nxt:		movem.l		(sp)+,a0-a6/d0-d7
		move.l		FILE_BUFFER,a6		* Reset buffer pointer.
		rts

*--------------------------------------------------------------------------*
* Vars..
*--------------------------------------------------------------------------*

		BSS


gif_registers:	ds.l		15		
gif_open:	ds.l		1
gif_xoff:	ds.w		1
gif_yoff:	ds.w		1
gif_linewidth:	ds.w		1

FILE_BUFFER:	ds.l		1

GIFWIDTH	ds.w		1
GIFHEIGHT	ds.w		1
GIF_NAME:	ds.l		1
GIFPAL_P:	ds.l		1
GIFPIC_P:	ds.l		1
F_HANDLE:	ds.w		1
STACK_P:	ds.l		1
BYTECOUNT:	ds.w		1
PACKET_P:	ds.l		1
FIRSTBYTE:	ds.w		1
WAITINGCODE:	ds.w		1
FREECODE:	ds.w		1
NUMBITS:	ds.w		1
TOPBITS		ds.w		1
OUTDAT		ds.l		1

HASH_CODE	ds.l		1
HASH_PREFIX	ds.l		1
HASH_SUFFIX	ds.l		1

transparent_flag:	ds.b	1
interlace_flag:		ds.b	1
bgcolour:		ds.b	1
disposal:		ds.b	1
gif_delay:		ds.l	1

		EVEN

		TEXT
*
