;----------------------------------------------------------------------------
;File name:	READ_GIF.S		Revision date:	1995.06.24
;Creator:	Ulf Ronald Andersson	Creation date:	1995.06.23
;(c)1992 by:	Ulf Ronald Andersson	All rights reserved
;Released as:	FREEWARE		(NB: commercial sales forbidden!)
;File purpose:	Code library for GIF reading
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	READ_GIF_defined
READ_GIF_defined	set	1
;
;----------------------------------------------------------------------------
	include	URAn_DOS.S
	include	scan_GIF.S
;----------------------------------------------------------------------------
;Start of:	'init_GIF_vars'
;----------------------------------------------------------------------------
;
init_GIF_vars:		;get ready for next image...
	movem.l	d0/a0/a1,-(sp)
	clr.w	remnant_bits
	clr.w	remnant_cnt
	clr.w	XC
	clr.w	YC
	clr.w	Pass
	clr.w	OutCount
	clr.w	CodeSize
	clr.w	InitCodeSize
	clr.w	MaxCode
	clr.w	ClearCode
	clr.w	EOFCode
	clr.w	CurCode
	clr.w	OldCode
	clr.w	InCode
	clr.w	FirstFree
	clr.w	FreeCode
	clr.w	FinChar
	clr.w	ReadMask
	clr.w	BitMask
;
	lea	prefix,a0
	lea	suffix,a1
	move.l	#HASHSIZE-1,d0
.iz_xxxfix:
	clr.w	(a0)+
	clr.w	(a1)+
	dbra	d0,.iz_xxxfix
;
	lea	OutCode,a0
	move.l	#OUTSIZE-1,d0
.iz_OutCode:
	clr.w	(a0)+
	dbra	d0,.iz_OutCode
;
	movem.l	(sp)+,d0/a0/a1
	rts
;
;----------------------------------------------------------------------------
;End of:	'init_GIF_vars'
;----------------------------------------------------------------------------
;Start of:	'read_raster'
;----------------------------------------------------------------------------
;int read_raster (infile_h,code_maxlen,rast_maxlen,code_p,rast_p)
;int		infile_h;
;long		code_maxlen,	rast_maxlen;
;uchar_t	*code_p,	*rast_p;
;
;	Start reading the raster data. First we get the intial code size
;	and compute decompressor constant values, based on this code size.
;
read_raster:
;
	bsr	init_GIF_vars
;
	movem.l	d3-d6/a3/a4,-(sp)
	move	d0,d3			;d3 =  infile_h
	move.l	d1,d4			;d4 =  code_maxlen
	move.l	d2,d5			;d5 =  rast_maxlen
	move.l	a0,a3			;a3 -> code array
	move.l	a1,rast_p		;store rast_p for add_pixel
	move.l	a1,rast_add_p		;store rast_add_p for add_pixel
	move.l	a3,code_p		;store code_p for read_code
	move.l	d4,code_maxlen
	move.l	d5,rast_maxlen
	tst.b	scan_ID_f
	beq	.range_error
	move.l	scan_ID_p(pc),a4	;a4 -> image descriptor
	move	GIF_id_bits(a4),d0
	moveq	#1,d1
	asl	d0,d1
	subq	#1,d1
	move	d1,BitMask		;bit mask for colour indexes
;
.start_read:
	gemdos	Fread,d3,#1,.read_bf(pc)
	tst.l	d0
	ble	.read_error
	clr	d0
	move.b	.read_bf(pc),d0
	move	d0,CodeSize		;CodeSize = read data
	moveq	#1,d1
	asl	d0,d1
	move	d1,ClearCode		;ClearCode = (1 << CodeSize)
	addq	#1,d1
	move	d1,EOFCode		;EOFCode   = ClearCode + 1;
	addq	#1,d1
	move	d1,FreeCode
	move	d1,FirstFree		;FreeCode  = FirstFree = ClearCode + 2;
;
;	The GIF spec has it that the code size is the code size used to
;	compute the above values is the code size given in the file, but
;	the code size used in compression/decompression is the code size
;	given in the file plus one.
;
	addq	#1,CodeSize		;CodeSize = read size + 1
	move	CodeSize(pc),d0
	move	d0,InitCodeSize		;InitCodeSize = CodeSize
	moveq	#1,d1
	asl	d0,d1
	move	d1,MaxCode		;MaxCode = (1 << CodeSize)
	subq	#1,d1
	move	d1,ReadMask		;ReadMask = MaxCode - 1
;
;   Read the raster data. Then we just transpose it from the GIF array
;   to the Raster array, turning it from a series of blocks into one
;   long data stream, which makes life much easier for read_code().
;
.unblock_loop:
	gemdos	Fread,d3,#1,.read_bf(pc)
	tst.l	d0
	ble	.read_error
	clr.l	d6
	move.b	.read_bf(pc),d6		;d6 = block length
	beq.s	.unblocked
	gemdos	Fread,d3,d6,(a3)	;read block data to *code_p
	cmp.l	d6,d0
	bne	.read_error
	add	d6,a3			;code_p += block length
	move.l	a3,a0
	sub.l	code_p(pc),a0
	add	#255,a0			;a0 = max data in code after next block
	cmp.l	d4,a0			;a0 > code_maxlen ?
	bls.s	.unblock_loop
	bra	.range_error
;
.unblocked:
;
;   Decompress the file, continuing until you see the GIF EOF code.
;   One obvious enhancement is to add checking for corrupt files here.
;
;NB: since we are finished reading from disk, 'read_code' can smash d3
;NB: we are also finished with 'code_maxlen' in d4, so it too is free
;
.decompress:
	move.l	code_p(pc),a3		;a3 is ptr for 'read_code'
.next_code:
	bsr	read_code		;d0 = read_code()
	cmp	EOFCode,d0		;EOFCode ?
	beq	.finished
	cmp	ClearCode,d0		;ClearCode ?
	bne.s	.not_clear
;
;   Clear code sets everything back to its initial value,
;   then reads the immediately subsequent code as
;   uncompressed data.
;
	move	InitCodeSize(pc),d0
	move	d0,CodeSize
	moveq	#1,d1
	asl	d0,d1
	move	d1,MaxCode
	subq	#1,d1
	move	d1,ReadMask
	move	FirstFree(pc),FreeCode
	bsr	read_code		;d0 = read_code()
	move	d0,CurCode
	move	d0,OldCode
	and	BitMask,d0
	move	d0,FinChar
	bsr	add_pixel		;add_pixel(FinChar)
	tst	d0
	bmi	.exit
	bra.s	.next_code
;
.not_clear:
;
;   If not a clear code, then must be data: save
;   same as CurCode and InCode
;
	move	d0,CurCode
	move	d0,InCode
;
;   If greater or equal to FreeCode, not in
;   the hash table yet;
;   repeat the last character decoded
;
	cmp	FreeCode,d0
	blo.s	.is_hashed
	move	OldCode,CurCode		;CurCode = OldCode
	lea	OutCode,a0
	move	OutCount,d0
	add	d0,d0
	addq	#1,OutCount
	move	FinChar(pc),(a0,d0)	;OutCode[OutCount++] = FinChar
.is_hashed:
;
;   Unless this code is raw data, pursue the chain
;   pointed to by CurCode through the hash table
;   to its end; each code in the chain puts its
;   associated output code on the output queue.
;
.chain_loop:
	move	CurCode(pc),d0
	cmp	BitMask(pc),d0
	bls.s	.raw_data
	cmpi	#1024,OutCount
	bhi	.range_error
	lea	OutCode,a0
	move	OutCount,d1
	add	d1,d1			;fix d1 to index words in OutCode
	addq	#1,OutCount
	lea	Suffix,a1
	add	d0,d0			;fix d0 to index words in Suffix & Prefix
	move	(a1,d0),(a0,d1)		;OutCode[OutCount++] = Suffix[CurCode]
	lea	Prefix,a1
	move	(a1,d0),CurCode		;CurCode = Prefix[CurCode]
	bra.s	.chain_loop
;
.raw_data:
;
;   The last code in the chain is treated as raw data
;
	move	CurCode(pc),d0
	and	BitMask,d0
	move	d0,FinChar	;FinChar = CurCode & BitMask;
	lea	OutCode,a0
	move	OutCount,d1
	add	d1,d1
	addq	#1,OutCount
	move	d0,(a0,d1)	;OutCode[OutCount++] = FinChar
;
;   Now we put the data out to the Output routine.
;   It's been stacked LIFO, so deal with it that way
;
	lea	OutCode,a5
	move	OutCount(pc),d3
	subq	#1,d3		;i = OutCount -1
	add	d3,d3		;fix d3 to index words
	blt.s	.out_done
.out_loop:
	move	(a5,d3),d0
	bsr	add_pixel	;add_pixel( OutCode[i]
	tst	d0
	bmi.s	.exit
	subq	#2,d3		;i--
	bge.s	.out_loop
.out_done:
	clr	OutCount	;OutCount = 0
;
;   Build the hash table on-the-fly.
;   No table is stored in the file.
;
	lea	Prefix,a0
	lea	Suffix,a1
	move	FreeCode(pc),d0
	add	d0,d0
	move	OldCode(pc),(a0,d0)	;Prefix[FreeCode] = OldCode;
	move	FinChar(pc),(a1,d0)	;Suffix[FreeCode] = FinChar;
	move	InCode(pc),OldCode	;OldCode = InCode
;
;   Point to the next slot in the table.  If we
;   exceed the current MaxCode value, increment
;   the code size unless it's already 12.  If it
;   is, do nothing: the next code decompressed
;   better be CLEAR
;
	addq	#1,FreeCode		;FreeCode++
	move	FreeCode(pc),d0
	cmp	MaxCode(pc),d0
	blo.s	.keep_MaxCode
	cmpi	#12,CodeSize
	bhs.s	.keep_MaxCode
	move	CodeSize(pc),d0
	addq	#1,d0
	move	d0,CodeSize		;CodeSize++;
	asl	MaxCode			;MaxCode *= 2;
	moveq	#1,d1
	asl	d0,d1
	subq	#1,d1
	move	d1,ReadMask		;ReadMask = (1 << CodeSize) - 1;
.keep_MaxCode:
	bra	.next_code
;
.finished:
	clr.l	d0
.exit:
	movem.l	(sp)+,d3-d6/a3-a5
	rts
;
.range_error:
	moveq	#E_RANGE,d0
	bra.s	.exit
;
.read_error:
	moveq	#E_READF,d0
	bra.s	.exit
;
.read_bf:
	ds.b	2
;
;----------------------------------------------------------------------------
;End of:	'read_raster'
;----------------------------------------------------------------------------
;	Common data block of deep unpacker routines
;
BitMask:	ds.w	1	; AND mask for data size
;
Pass:		ds.w	1	; Used by output routine if interlaced pic
OutCount:	ds.w	1	; Decompressor output 'stack count'
InitCodeSize:	ds.w	1	; Start code size, used during Clear
MaxCode:	ds.w	1	; limit value for current code size
ClearCode:	ds.w	1	; GIF clear code
EOFCode:	ds.w	1	; GIF end-of-information code
CurCode:	ds.w	1	; Decompressor variables
OldCode:	ds.w	1
InCode:		ds.w	1
FirstFree:	ds.w	1	; First free code, gen'd per GIF spec
FreeCode:	ds.w	1	; Decompr, next free slot in hash table
FinChar:	ds.w	1	; Decompr variable
CodeSize:	ds.w	1	;Code size, read from GIF header
ReadMask:	ds.w	1	;Code AND mask for cur code size
code_p:		ds.l	1	;-> coded array
code_maxlen:	ds.l	1	;max length of coded array  (bytes)
;
;-------- unpacking arrays --------------------------------------------------
;
Prefix:		ds.w	HASHSIZE	; hash table used by the decompr
Suffix:		ds.w	HASHSIZE	; hash table used by the decompr
OutCode:	ds.w	OUTSIZE		; output array used by the decompr
;
;-------- add_pixel variables -----------------------------------------------
;
XC:		ds.w	1	; Output X coord of current pixel
YC:		ds.w	1	; Output Y coord of current pixel
rast_p:		ds.l	1	;-> raster array
rast_maxlen:	ds.l	1	;max length of raster array  (bytes)
rast_add_p:	ds.l	1	;pointer in raster array for 'add_pixel'
;
;-------- read_code variables -----------------------------------------------
;
remnant_bits:	ds.w	1	;Code bits fetched but still unused
remnant_cnt:	ds.w	1	;Bit count of remnant_bits 
;----------------------------------------------------------------------------
;Start of:	'read_code'
;----------------------------------------------------------------------------
;read_code ()
;
;	Fetch the next code from the raster data stream.  The codes can be
;	any length from 3 to 12 bits, packed into 8-bit bytes, so we have to
;	maintain our location in the Raster array as a BIT Offset.  We compute
;	the byte Offset into the raster array by dividing this by 8, pick up
;	three bytes, compute the bit Offset into our 24-bit chunk, shift to
;	bring the desired code to the bottom, then mask it off and return it. 
;
;Nope!	New method uses a word for 'remnant_bits', so that each byte in the
;	array is fetched only once, in consecutive order.  This method can
;	later be adapted for decoding line by line, while processing files.
;
;NB:	For efficiency the code ptr is resident in a3 at entry & exit
;
read_code:	;returns d0 = code,  steps a3,  destroys d1-d3/a0
	move	CodeSize,d3
	move	remnant_cnt(pc),d0
	move	d0,d1			;save old count for later shifts
	clr.l	d2			;d0 high word = zero
	move	remnant_bits(pc),d2	;d2 = remnant bits
	sub	d3,d0			;d0 = new count, unless negative
	bpl.s	.gotcha_1
	ror.l	d1,d2			;save remnant in top bits of high word
	move.b	(a3)+,d2		;fetch next byte to remnant
	addq	#8,d0			;adjust remnant count up by 8
	bpl.s	.gotcha_2
	addq	#8,d1			;adjust old count for later shifts
	ror.l	#8,d2			;roll recent 8 bits with old bits
	move.b	(a3)+,d2		;fetch next byte to remnant
	addq	#8,d0			;adjust remnant count up by 8
;We now have enough bits, since max CodeSize is 12, and we have at least 16
.gotcha_2:
	rol.l	d1,d2			;realign old bits with new bits
.gotcha_1:
	move	d0,remnant_cnt		;store new remnant_cnt
	move	d2,d0			;d0 = remnant for return value
	lsr.l	d3,d2			;remove CodeSize bits from new remnant
	move	d2,remnant_bits		;store new remnant bits
	and	ReadMask(pc),d0	;mask CodeSize bits of return value
	rts
;
;----------------------------------------------------------------------------
;End of:	'read_code'
;----------------------------------------------------------------------------
;Start of:	'add_pixel'
;----------------------------------------------------------------------------
;add_pixel (indx,id_p)
;uchar_t	indx;
;GIF_id_t	*id_p;
;
;NB: For assembly version efficiency, id_p is not passed normally
;    but is simply assumed to be in a4, where 'read_raster' put it.
;
add_pixel:
	movem.l	d3-d4,-(sp)
	move	d0,d4			;d4 = indx
;
	move	XC(pc),d0		;d0 = current XC
	move	YC(pc),d1		;d1 = current YC
	move	d0,d2			;d2 = current XC
	move	d1,d3			;d3 = current YC
	addq	#1,d0			;d0 = next XC
	cmp	GIF_id_dx(a4),d0	;next XC = width ?
	blo.s	.keep_YC
	clr	d0		;d0 = next XC = zero  for new line
;
;   If a non-interlaced picture, just increment YC to the
;   next scan line. If it's interlaced, deal with the
;   interlace as described in the GIF spec.  Put the
;   decoded scan line out to the screen if we haven't gone
;   past the bottom of it
;
	tst.b	GIF_id_lace(a4)		;Interlaced ?
	beq.s	.next_line
	cmpi	#3,Pass
	beq.s	.pass_3_fix
	cmpi	#2,Pass
	beq.s	.pass_2_fix
	cmpi	#1,Pass
	beq.s	.pass_1_fix
.pass_0_fix:
	addq	#8,d1
	cmp	GIF_id_dy(a4),d1
	blo.s	.fix_ptr
	addq	#1,Pass
	moveq	#4,d1
	bra.s	.fix_ptr
;
.pass_1_fix:
	addq	#8,d1
	cmp	GIF_id_dy(a4),d1
	blo.s	.fix_ptr
	addq	#1,Pass
	moveq	#2,d1
	bra.s	.fix_ptr
;
.pass_2_fix:
	addq	#4,d1
	cmp	GIF_id_dy(a4),d1
	blo.s	.fix_ptr
	addq	#1,Pass
	moveq	#1,d1
	bra.s	.fix_ptr
;

.pass_3_fix:
	addq	#1,d1
.fix_ptr:
	mulu	GIF_id_dx(a4),d3	;d3 = current YC * Width
	move.l	rast_p(pc),a0		;a0 -> base of raster area
	lea	(a0,d3),a0		;a0 -> current line
	add	d2,a0			;a0 -> current pixel
	bra.s	.store_pixel
;

.next_line:
	addq	#1,d1
.keep_YC:				;d1 = next YC
	move.l	rast_add_p(pc),a0	;a0 -> current pixel
.store_pixel:
	move.l	a0,a1
	sub.l	rast_p(pc),a1		;a1 = current pixel index
	cmp.l	rast_maxlen(pc),a1
	bhi.s	.range_error
	move.b	d4,(a0)+		;store color index for pixel
	move.l	a0,rast_add_p		;store updated pointer
	move	d0,XC			;store next XC
	move	d1,YC			;store next YC
.exit_ok:
	clr.l	d0
.exit:
	movem.l	(sp)+,d3-d4
	rts
;
.range_error:
	moveq	#E_RANGE,d0
	bra.s	.exit
;
;----------------------------------------------------------------------------
;End of:	'add_pixel'
;----------------------------------------------------------------------------
	endc	;READ_GIF_defined
;----------------------------------------------------------------------------
;End of file:	READ_GIF.S
;----------------------------------------------------------------------------
