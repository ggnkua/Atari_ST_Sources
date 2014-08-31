;----------------------------------------------------------------------------
; File name:	DECODER.S			Revision date:	1993.09.19
; Ported by:	Ulf Ronald Andersson		Port start:	1993.09.19
; Created by:	Steven A. Bennett		Creation date:	1987.xx.yy
; File purpose:	LZW decoder for GIF87
;----------------------------------------------------------------------------
; Copyright:	(C)1987 Steven A. Bennett
;   -''-	Released as PD FREEWARE provided copyright shown, as above.
;----------------------------------------------------------------------------
; Remarks:
;
;	GIF and 'Graphics Interchange Format' are trademarks (tm) of
;	Compuserve, Incorporated, an H&R Block Company.
;
;	This file contains a decoder routine for GIF images which is similar,
;	structurally, to the original routine by Steve Wilhite.
;	It is, however, somewhat noticably faster in most cases.
;----------------------------------------------------------------------------
;
;
	include	URAn_DOS.S
;
get_byte:
	jmp	$feedface
;
;	IMPORT int get_byte();
;	This external (machine specific) function is expected to return
;	either the next byte from the GIF file, or a negative number, as
;	defined in ERRS.H.
;
out_line:
	jmp	$feedface
;
;	IMPORT int out_line(BYTE *pixels, long linelen);
;	This function takes a full line of pixels (one byte per pixel) and
;	displays them (or does whatever your program wants with them...).  It
;	should return zero, or negative if an error or some other event occurs
;	which would require aborting the decode process...  Note that the length
;	passed will almost always be equal to the line length passed to the
;	decoder function, with the sole exception occurring when an ending code
;	occurs in an odd place in the GIF file...  In any case, linelen will be
;	equal to the number of bytes passed...
;
bad_code_count:
	dc.w	0
;
;	IMPORT int bad_code_count;
;	This value is the only other global required by the using program, and
;	is incremented each time an out of range code is read by the decoder.
;	When this value is non-zero after a decode, your GIF file is probably
;	corrupt in some way...
;
;
;----------------------------------------------------------------------------
;	Constants
;
NULL		=	0
MAX_CODES	=	4095
BAD_CODE_SIZE	=	-64
OUT_OF_MEMORY	=	-39
;
;
;----------------------------------------------------------------------------
;	Static variables
;
	section	data
;
curr_size:	ds.w	1	;The current code size
clear:		ds.w	1	;Value for a clear code
ending:		ds.w	1	;Value for a ending code
newcodes:	ds.w	1	;First available code
top_slot:	ds.w	1	;Highest code for current size
slot:		ds.w	1	;Last read code
;
;
;----------------------------------------------------------------------------
;	The following static variables are used
;	for seperating out codes
;
	section	data
;
navail_bytes:	dc.w	0	;# bytes left in block
nbits_left:	dc.w	0	;# bits left in current byte
b1:		ds.b	1	;Current byte
		even
byte_buff:	ds.b	257	;Current block
		even
pbytes:		ds.l	1	;Pointer to next block byte
code_mask:			;LOCAL LONG code_mask[13] =
		dc.w	$0000
		dc.w	$0001,$0003,$0007,$000F
		dc.w	$001F,$003F,$007F,$00FF
		dc.w	$01FF,$03FF,$07FF,$0FFF
		dc.w	$1FFF,$3FFF,$7FFF,$FFFF
;
;
;----------------------------------------------------------------------------
;
	section	text
;
;	void init_exp(WORD size)
;	This function initializes the decoder for reading a new image.
;
init_exp:
	move	4(sp),d0	;d0 = size
	moveq	#1,d1
	lsl	d0,d1
	move	d1,clear	;clear = 1 << size;
	addq	#1,d1
	move	d1,ending	;ending = clear + 1;
	addq	#1,d1
	move	d1,newcodes
	move	d1,slot		;slot = newcodes = ending + 1;
	addq	#1,d0
	move	d0,curr_size	;curr_size = size + 1;
	moveq	#1,d1
	lsl	d0,d1
	move	d1,top_slot	;top_slot = 1 << curr_size;
	clr	nbits_left
	clr	navail_bytes	;navail_bytes = nbits_left = 0;
	rts
;
;
;----------------------------------------------------------------------------
;
	section	text
;
;	WORD	get_next_code()
;	- gets the next code from the GIF file.  Returns the code, or else
;	a negative number in case of file errors...
;
get_next_code:
	movem.l	d3-d4/a3,-(sp)
;
	tst	nbits_left
	bne.s	.endif_1	;if (nbits_left == 0)
;	{
	tst	navail_bytes
	bgt.s	.endif_2	;  if (navail_bytes <= 0)
;				;  {
;	Out of bytes in current block, so read next block
	lea	byte_buff,a0
	move.l	a0,pbytes	;    pbytes = byte_buff;
	jsr	get_byte
	move	d0,navail_bytes
	bmi	.exit		;    if ((navail_bytes = get_byte()) < 0)
;				;      return(navail_bytes);
	beq.s	.endif_3	;    else if (navail_bytes)
;				     {
	move	d0,d3
	subq	#1,d3
	lea	byte_buff,a3
.loop_1:			;      for (i = 0; i < navail_bytes; ++i)
;				       {
	jsr	get_byte
	tst	d0
	bmi	.exit		;        if ((x = get_byte()) < 0) return(x);
	move.b	(a3)+,d0	;        byte_buff[i] = x;
	dbra	d3,.loop_1	;      }
.endif_3:			;    }
.endif_2:			;  }
	move.l	pbytes,a0
	move.b	(a0)+,b1
	move.l	a0,pbytes	;  b1 = *pbytes++;
	move	#8,nbits_left	;  nbits_left = 8;
	subq	#1,navail_bytes	;  --navail_bytes;
.endif_1:			;}
	moveq	#8,d0
	sub	nbits_left,d0
	move.b	b1,d1
	lsr	d0,d1
	clr.l	d4
	move.b	d1,d4		;ret = b1 >> (8 - nbits_left);
.loop_2:
	move	curr_size,d0
	cmp	nbits_left,d0
	ble.s	.exit_loop_2	;while (curr_size > nbits_left)
;	{
	tst	navail_bytes
	bgt.s	.endif_4	;  if (navail_bytes <= 0)
;				;  {
;	Out of bytes in current block, so read next block
	lea	byte_buff,a0
	move.l	a0,pbytes	;    pbytes = byte_buff;
	jsr	get_byte
	move	d0,navail_bytes
	bmi.s	.exit		;    if ((navail_bytes = get_byte()) < 0)
;				;      return(navail_bytes);
	beq.s	.endif_5	;    else if (navail_bytes)
;				;    {
	move	d0,d3
	subq	#1,d3
	lea	byte_buff,a3
.loop_3:			;      for (i = 0; i < navail_bytes; ++i)
;				       {
	jsr	get_byte
	tst	d0
	bmi.s	.exit		;        if ((x = get_byte()) < 0) return(x);
	move.b	(a3)+,d0	;        byte_buff[i] = x;
	dbra	d3,.loop_3	;      }
.endif_5:			;    }
.endif_4:			;  }
	move.l	pbytes,a0
	move.b	(a0)+,b1
	move.l	a0,pbytes	;  b1 = *pbytes++;
	clr.l	d1
	move.b	b1,d1
	move	nbits_left,d0
	lsl.l	d0,d1
	or.l	d1,d4		;  ret |= b1 << nbits_left;
	addq	#8,nbits_left	;  nbits_left += 8;
	subq	#1,navail_bytes	;  --navail_bytes;
	bra.s	.loop_2
;				;}
.exit_loop_2:
	move	curr_size,d0
	sub	d0,nbits_left
	add	d0,d0
	lea	code_mask,a0
	and	(a0,d0),d4	;ret &= code_mask[curr_size];
	move	d4,d0
.exit:
	movem.l	(sp)+,d3-d4/a3
	rts
;
;
;----------------------------------------------------------------------------
;
	section	bss
;
;	The reason we have these seperated like this instead of using
;	a structure like the original Wilhite code did, is because this
;	stuff generally produces significantly faster code when compiled...
;	This code is full of similar speedups...  (For a good book on writing
;	C for speed or for space optomisation, see Efficient C by Tom Plum,
;	published by Plum-Hall Associates...)
;
stack:	ds.b	MAX_CODES+1	;Stack for storing bytes
suffix:	ds.b	MAX_CODES+1	;Suffix table
prefix:	ds.w	MAX_CODES+1	;Prefix linked list
;
;
;----------------------------------------------------------------------------
;
	section	text
;
;	WORD decoder(long linewidth)
;	- This function decodes an LZW image, according to the method used
;	in the GIF spec.  Every *linewidth* "characters" (ie. pixels) decoded
;	will generate a call to out_line(), which is a user specific function
;	to display a line of pixels.  The function gets it's codes from
;	get_next_code() which is responsible for reading blocks of data and
;	seperating them into the proper size codes.  Finally, get_byte() is
;	the global routine to read the next byte from the GIF file.
;
;	It is generally a good idea to have linewidth correspond to the actual
;	width of a line (as specified in the Image header) to make your own
;	code a bit simpler, but it isn't absolutely necessary.
;
;	Returns: 0 if successful, else negative.  (See ERRS.H)
;
decoder:		;WORD decoder(long linewidth)
	link	a6,#-2
a_linewidth	set	8
l_bufcnt	set	-4
	movem.l	d3-d7/a3-a5,-(sp)
;
;	d3 := next_code,  d4 := size.ret
;	d5 := link_code,   d6 := suff_code,  d7 := prev_code
;	a3 := *bufptr,  a4:=*buf,  a5:=*stp
;
;	Initialize for decoding a new image...
	jsr	get_byte
	move	d0,d4
	bmi	.exit		;if ((size = get_byte()) < 0) return(size);
	swap	d4
	move	#BAD_CODE_SIZE,d4
	cmp	#2,d0
	blt	.exit_d4
	cmp	#9,d0
	bgt	.exit_d4	;if (size < 2 || 9 < size) return(BAD_CODE_SIZE);
	bsr	init_exp	;init_exp(size);
;
;	Initialize in case they forgot to put in a clear code.
;	(This shouldn't happen, but we'll try and decode it anyway...)
	clr	d6
	clr	d7		;prev_code = suff_code = 0;
;
;	Allocate space for the decode buffer
	move.l	a_linewidth(a6),d0
	addq	#1,d0
	gemdos	Malloc,d0
	move.l	d0,a4
	move	#OUT_OF_MEMORY,d4
	tst.l	d0
	ble	.exit_d4	;if ((buf = (UTINY *)malloc(linewidth + 1)) == NULL) return(OUT_OF_MEMORY);
;
;	Set up the stack pointer and decode buffer pointer
	move.l	#stack,a5	;stp = stack;
	move.l	a4,a3		;bufptr = buf;
	move.l	a_linewidth(a6),l_bufcnt(a6)	;bufcnt = linewidth;
;
;	This is the main loop.  For each code we get we pass through the
;	linked list of prefix codes, pushing the corresponding "character" for
;	each code onto the stack.  When the list reaches a single "character"
;	we push that on the stack too, and then start unstacking each
;	character for output in the correct order.  Special handling is
;	included for the clear code, and the whole thing ends when we get
;	an ending code.
;
.loop_1:
	jsr	get_next_code
	move	d0,d3
	cmp	ending,d3
	beq	.exit_loop_1	;while ((next_code = get_next_code()) != ending)
;				;{
;	If we had a file error, return without completing the decode
	move	d0,d4
	bmi	.free_exit_d4	;  if (next_code < 0) {free(buf); return(0);}
;
;	If the code is a clear code, reinitialize all necessary items.
	cmp	clear,d3
	bne.s	.else_not_clear	;  if (next_code == clear)
;				;  {
	swap	d4
	move	d4,d0
	swap	d4
	addq	#1,d0
	move	d0,curr_size	;    curr_size = size + 1;
	move	newcodes,slot	;    slot = newcodes;
	moveq	#1,d1
	lsl	d0,d1
	move	d1,top_slot	;    top_slot = 1 << curr_size;
;
;	Continue reading codes until we get a non-clear code
;	(Another unlikely, but possible case...)
;
.loop_2:
	jsr	get_next_code
	cmp	clear,d0
	beq.s	.loop_2
	move	d0,d3		;    while ((next_code = get_next_code()) == clear);
;
;	If we get an ending code immediately after a clear code, break loop
	cmp	ending,d3
	beq	.exit_loop_1	;    if (next_code == ending) break;
;
;	Finally, if the code is beyond the range of already set codes,
;	(This one had better NOT happen...  I have no idea what will
;	result from this, but I doubt it will look good...) then set it
;	to color zero.
	cmp	slot,d3
	blt.s	.endif_2	;    if (next_code >= slot)
	clr	d3		;      next_code = 0;
.endif_2:
	move	d3,d6
	move	d3,d7		;    prev_code = suff_code = next_code;
;
;	And let us not forget to put the char into the buffer... And
;	if, on the off chance, we were exactly one pixel from the end
;	of the line, we have to send the buffer to the out_line()
;	routine...
	move.b	d3,(a3)+	;    *bufptr++ = next_code;
	subq.l	#1,l_bufcnt(a6)
	bne.s	.endif_3	;    if (--bufcnt == 0)
;				;    {
	move.l	a_linewidth(a6),-(sp)
	move.l	a4,-(sp)
	jsr	out_line
	addq	#8,sp
	move	d0,d4
	bmi	.free_exit_d4	;      if ((ret = out_line(buf, linewidth)) < 0) { free(buf); return(ret); }
	move.l	a4,a3		;      bufptr = buf;
	move.l	a_linewidth(a6),l_bufcnt(a6)	;bufcnt = linewidth;
.endif_3:			;    }
	bra	.endif_1
				;  }
.else_not_clear:		;  else
;				;  {
;	In this case, it's not a clear code or an ending code, so
;	it must be a code code...  So we can now decode the code into
;	a stack of character codes. (Clear as mud, right?)
;
	move	d3,d5		;    link_code = next_code;
;
;	Here we go again with one of those off chances...  If, on the
;	off chance, the code we got is beyond the range of those already
;	set up (Another thing which had better NOT happen...) we trick
;	the decoder into thinking it actually got the last code read.
;	(Hmmn... I'm not sure why this works...  But it does...)
;
	move	slot,d2		;;;;;d2=slot
	cmp	d2,d5
	blt.s	.endif_4	;    if (link_code >= slot)
;				;    {
	beq.s	.endif_5	;      if (link_code > slot)
	addq	#1,bad_code_count	;++bad_code_count;
.endif_5:
	move	d7,d5		;      link_code = prev_code;
	move.b	d6,(a5)+	;      *stp++ = suff_code;
.endif_4:			;    }

;
;	Here we scan back along the linked list of prefixes, pushing
;	helpless characters (ie. suffixes) onto the stack as we do so.
;
	lea	prefix,a1
	lea	suffix,a2
.loop_3:
	cmp	newcodes,d5
	blt.s	.exit_loop_3	;    while (link_code >= newcodes)
;				;    {
	move.b	(a2,d5),(a5)+	;      *stp++ = suffix[link_code];
	add	d5,d5
	move	(a1,d5),d5	;      link_code = prefix[link_code];
.exit_loop_3:			;    }
;
;	Push the last character on the stack, and set up the new
;	prefix and suffix, and if the required slot number is greater
;	than that allowed by the current bit size, increase the bit
;	size.  (NOTE - If we are all full, we *don't* save the new
;	suffix and prefix...  I'm not certain if this is correct...
;	it might be more proper to overwrite the last code...
;
	move.b	d5,(a5)+	;    *stp++ = link_code;
	cmp	top_slot,d2
	bge.s	.endif_6	;    if (slot < top_slot)
;				;    {
	move	d5,d7
	move.b	d5,(a2,d2)	;      suffix[slot] = suff_code = link_code;
	add	d2,d2
	addq	#1,slot
	move	d7,(a1,d2)	;      prefix[slot++] = prev_code;
	move	d3,d7		;      prev_code = next_code;
.endif_6:			;    }
	move	slot,d2
	cmp	top_slot,d2
	blt.s	.endif_7	;    if (slot >= top_slot)
	move	curr_size,d1
	cmp	#12,d1
	bge.s	.endif_8	;      if (curr_size < 12)
;				;      {
	lsl	top_slot	;        top_slot <<= 1;
	addq	#1,curr_size	;        ++curr_size;
.endif_8			;      }
.endif_7:
;
;	Now that we've pushed the decoded string (in reverse order)
;	onto the stack, lets pop it off and put it into our decode
;	buffer...  And when the decode buffer is full, write another
;	line...
;
.loop_4:
	cmp.l	#stack,a5
	ble.s	.exit_loop_4	;    while (stp > stack)
;				;    {
	move.b	-(a5),(a3)+	;      *bufptr++ = *(--stp);
	subq.l	#1,l_bufcnt(a6)
	bne.s	.endif_9	;      if (--bufcnt == 0)
;				;      {
	move.l	a_linewidth(a6),-(sp)
	move.l	a4,-(sp)
	jsr	out_line
	move	d0,d4
	bmi.s	.free_exit_d4	;        if ((ret = out_line(buf, linewidth)) < 0) { free(buf); return(ret); }
	move.l	a4,a3		;        bufptr = buf;
	move.l	a_linewidth(a6),l_bufcnt(a6)	;bufcnt = linewidth;
.endif_9:			;      }
.exit_loop_4:			;    }
.endif_1:			;  }
	bra	.loop_1
;				;}
.exit_loop_1:
	clr	d4		;ret = 0;
	move.l	a_linewidth(a6),d0
	sub.l	l_bufcnt(a6),d0
	beq.s	.free_exit_d4	;if (bufcnt != linewidth)
	move.l	d0,-(sp)
	move.l	a4,-(sp)
	jsr	out_line
	addq	#8,sp
	move	d0,d4		;ret = out_line(buf, (linewidth - bufcnt));
.free_exit_d4:
	gemdos	Mfree,(a4)	;free(buf);
.exit_d4:
	move	d4,d0		;return(ret);
.exit:
	movem.l	(sp)+,d3-d7/a3-a5
	unlk	a6
	rts

;----------------------------------------------------------------------------
;	End of file:	DECODER.C
;----------------------------------------------------------------------------
