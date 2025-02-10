*--------------------------------------------------------------------------*
* Hey Dug, here's the fixed Gif saver.. Apart from hopefully fixing the
* termination sequence completely it has also been speeded up by about 30%
* this was done by converting the screen to byte per pixel first before
* packing and then turning it back to byte per pixel afterwards, as opposed
* to doing it on the fly whilst compressing the bytes..
*
* It could be speeded up a bit more by optimising the OutputNBits routine
* and making the disk flushes less frequent or Output to memory and then
* flush it at that end.. However I certainly can't be bothered!
*--------------------------------------------------------------------------*

*--------------------------------------------------------------------------*
* 68030' GIF 87A write routines...
*						Copyright 1/9/93 Andrew L. Younger.
*--------------------------------------------------------------------------*
* "The Graphics Interchange Format(c) is the Copyright property of
* CompuServe Incorporated. GIF(sm) is a Service Mark property of CompuServe
* Incorporated."
*--------------------------------------------------------------------------*
_MAXBITS	equ	12
_MAXCODE	equ	(1<<_MAXBITS)-1
_CLEARCODE	equ	256
_EOFCODE	equ	257
_FREECODE	equ	258
_HASHSIZE	equ	5003
*--------------------------------------------------------------------------*
OPENERROR	equ		-1	* Possible errors return'd from save gif
WRITEERROR	equ		-2	* in register d0. If 0 is returned then save
CLOSEERROR	equ		-3	* went okay.
*--------------------------------------------------------------------------*
;TEST:
*--------------------------------------------------------------------------*
PUTBYTE	MACRO
		move.b	\1,(a6)+
		ENDM

PUTWORD	MACRO
		move.w	\1,d0
		bsr		PutWord
		ENDM

*--------------------------------------------------------------------------*

			rsreset
FILE_BUFFER_SIZE:	rs.b	1024
HASH_CODE_SIZE:	rs.w	_HASHSIZE
HASH_PREFIX_SIZE:	rs.w	_HASHSIZE
HASH_SUFFIX_SIZE:	rs.b	_HASHSIZE
GIFWRITE_BUFLEN:	rs.b	0

*--------------------------------------------------------------------------*

Init_GIF_Writer:
		lea		FILE_BUFFER_SIZE(a0),a1
		move.l	a1,FILE_BUFFER
		lea		HASH_CODE_SIZE(a0),a1
		move.l	a1,HASH_CODE
		lea		HASH_PREFIX_SIZE(a0),a1
		move.l	a1,HASH_PREFIX
		lea		HASH_SUFFIX_SIZE(a0),a1
		move.l	a1,HASH_SUFFIX
		rts

*--------------------------------------------------------------------------*
* Create Gif file, expects screen to be in byte per pixel format.
*--------------------------------------------------------------------------*
SaveGif:	move.l	sp,STACK_P		* Store stack pointer so we can
							* end on any error's anywhere..
*
* Open up file..
*
		move.l	GIF_NAME,a0
		jsr		CreateFile		* Create normal file..
		move.w	d0,F_HANDLE
		bpl.s		.nxt1
		move.l	#OPENERROR,d0
		bra		GifError		***** Fatal error.
*
* Now create header and write it out.
*
.nxt1:	move.l	FILE_BUFFER,a6	***** a6=output buffer pointer.
							***** So make sure not to smash.
		PUTBYTE	#'G'
		PUTBYTE	#'I'
		PUTBYTE	#'F'
		PUTBYTE	#'8'
		PUTBYTE	#'7'
		PUTBYTE	#'a'			* File id..

		PUTWORD	GIFWIDTH
		PUTWORD	GIFHEIGHT
		PUTBYTE	#($87|((8-1)<<4))	* Output flag
		PUTBYTE	#0			* background colour index
		PUTBYTE	#0			* RESERVED ( aspect ratio )
*
* Dump palette.
*
		move.w	#256-1,d7
		move.l	GIFPAL_P,a0
.colormap:	addq.w	#1,a0			* skip zero
		PUTBYTE	(a0)+			* red
		PUTBYTE	(a0)+			* green
		PUTBYTE	(a0)+			* blue
		dbra		d7,.colormap
*
* Image details
*
		moveq		#',',d7	* devpac is a bit on the poor side!
		PUTBYTE	d7
		PUTWORD	#0		* x
		PUTWORD	#0		* y
		PUTWORD	GIFWIDTH	* x size
		PUTWORD	GIFHEIGHT	* y size
		PUTBYTE	#0		* Not interlaced/no local colour map
		PUTBYTE	#8		* Initial code size in bits per pixel
		bsr		FlushFile	* Flush buffer to disk.
		bsr		CompressInit	* Initialise lzw packer.
*
*  Write out Gif stream.
*
* a5 and d5 are free so we can use them without any worry's.
*
		move.l	GIFPIC_P,a5
		move.w	GIFHEIGHT,d5
		bra.s		.ylps
.ylp:		push.l	a5
		push.w	d5
		move.w	GIFWIDTH,d5
		bra.s		.xlps
.xlp:		move.b	(a5)+,d0
		bsr		CompressByte
.xlps:	dbra		d5,.xlp
		pop.w		d5
		pop.l		a5
		add.w		gif_linewidth,a5
.ylps:	dbra		d5,.ylp

*
* Terminate gif stream..
*

.TermGif:	bsr		CompressTerm
		move.w	BYTECOUNT,d0
		move.l	PACKET_P,a0
		move.b	d0,(a0)		* Head last packet.
		bsr		FlushFile		* Empty last buffer.

		move.l	FILE_BUFFER,a0
		clr.b		(a0)+			* Null length packet..
		move.b	#';',(a0)+		* terminater code..
		move.l	FILE_BUFFER,a0
		moveq		#2,d1			* length to write.
		move.w	F_HANDLE,d0		* file handle.
		jsr		WriteFile

*
* Close the file.
*
		push.l	d0
		move.w	F_HANDLE,d0
		jsr		CloseFile		* Close file
		pop.l		d0
		tst.l		d0
		bpl.s		.nxt3
		move.l	#CLOSEERROR,d0	*** Fatal error in closing file.
		bra.s		GifError
.nxt3:	moveq		#0,d0			* Worked!!
GifError:	move.l	STACK_P,sp		* Restore stack pointer
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
		move.w	#9,NUMBITS
		bsr		ClearTable
		rts

*--------------------------------------------------------------------------*
* Finish compression.
*--------------------------------------------------------------------------*
CompressTerm:
		tst.w		FIRSTBYTE
		beq.s		.skp
		move.w	WAITINGCODE,d0
		bsr		OutputNbits
.skp:		move.w	#_EOFCODE,d0
		bsr		OutputNbits
		bsr		OutputForce
		rts

*--------------------------------------------------------------------------*
* Code to clear tables and set up vars for going again.
*--------------------------------------------------------------------------*
ClearTable:	bsr		ClearHashTable
		move.w	#_CLEARCODE,d0
		bsr		OutputNbits		; output clear code into gif stream.
		move.w	#9,NUMBITS
		move.w	#_FREECODE,FREECODE
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
		move.w	#0,BYTECOUNT
		move.l	d0,-(sp)
		PUTBYTE	#0
		move.l	(sp)+,d0
		move.l	a6,PACKET_P
		subq.l	#1,PACKET_P
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

*--------------------------------------------------------------------------*
* Output intel style word. ( wot fun! )
*--------------------------------------------------------------------------*
PutWord:	movem.l	d0/d1,-(sp)
		move.w	d0,d1
		PUTBYTE	d1
		lsr.w		#8,d1
		PUTBYTE	d1
		movem.l	(sp)+,d0/d1
		rts

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
		PUTBYTE	d0
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
		PUTBYTE	d0
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
FlushFile:	movem.l	a0-a6/d0-d7,-(sp)
		move.l	FILE_BUFFER,d2	* buffer pointer
		move.l	a6,d1
		sub.l		d2,d1			* size
		move.l	d2,a0
		move.w	F_HANDLE,d0		* file handle.
		jsr		WriteFile
		tst.l		d0
		bpl.s		.nxt
		move.w	F_HANDLE,d0
		jsr		CloseFile		* on write error we must close file.
		move.l	#WRITEERROR,d0
		bra		GifError
.nxt:		movem.l	(sp)+,a0-a6/d0-d7
		move.l	FILE_BUFFER,a6		* Reset buffer pointer.
		rts

*--------------------------------------------------------------------------*
* Vars..
*--------------------------------------------------------------------------*

		BSS

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
WAITINGCODE:ds.w		1
FREECODE:	ds.w		1
NUMBITS:	ds.w		1
TOPBITS	ds.w		1
OUTDAT	ds.l		1

HASH_CODE	ds.l		1
HASH_PREFIX	ds.l		1
HASH_SUFFIX	ds.l		1

		EVEN

		TEXT
*
