/*
;----------------------------------------------------------------------------
; File name:	DECODER.C			Revision date:	1993.09.19
; Revised by:	Ulf Ronald Andersson		Revision start:	1993.09.19
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
*/

#include "std.h"
#include "errs.h"

IMPORT TEXT *malloc();                 /* Standard C library allocation */

IMPORT INT get_byte();
/*
;	This external (machine specific) function is expected to return
;	either the next byte from the GIF file, or a negative number, as
;	defined in ERRS.H.
*/


IMPORT INT out_line(UBYTE pixels[], INT linelen);
/*
;	This function takes a full line of pixels (one byte per pixel) and
;	displays them (or does whatever your program wants with them...).  It
;	should return zero, or negative if an error or some other event occurs
;	which would require aborting the decode process...  Note that the length
;	passed will almost always be equal to the line length passed to the
;	decoder function, with the sole exception occurring when an ending code
;	occurs in an odd place in the GIF file...  In any case, linelen will be
;	equal to the number of pixels passed...
*/

IMPORT INT bad_code_count;
/*
;	This value is the only other global required by the using program, and
;	is incremented each time an out of range code is read by the decoder.
;	When this value is non-zero after a decode, your GIF file is probably
;	corrupt in some way...
*/

/*
;----------------------------------------------------------------------------
*/

#define NULL   0L
#define MAX_CODES   4095

/*
;----------------------------------------------------------------------------
;	Static variables
*/

LOCAL WORD	cur_size;	/*  The current code size		*/
LOCAL WORD	clr_code;	/*  Clear code for current size		*/
LOCAL WORD	end_code;	/*  End code for current size		*/
LOCAL WORD	def_code;	/*  First available code definition	*/
LOCAL WORD	lim_code;	/*  Highest code for current size + 1	*/
LOCAL WORD	und_code;	/*  Next code to be defined		*/

/*
;----------------------------------------------------------------------------
;	The following static variables are used
;	for seperating out codes
*/

LOCAL WORD	navail_bytes = 0;	/*  # bytes left in block	*/
LOCAL WORD	nbits_left = 0;		/*  # bits left in current byte	*/
LOCAL UTINY	b1;			/*  Current byte		*/
LOCAL UTINY	byte_buff[257];		/*  Current block		*/
LOCAL UTINY	*pbytes;		/*  Pointer to next block byte	*/

LOCAL LONG code_mask[13] =
{
	0,
	0x0001, 0x0003,
	0x0007, 0x000F,
	0x001F, 0x003F,
	0x007F, 0x00FF,
	0x01FF, 0x03FF,
	0x07FF, 0x0FFF
};

/*
;----------------------------------------------------------------------------
;	void init_exp(WORD min_size)
;	This function initializes the decoder for reading a new image.
*/

LOCAL void init_exp(WORD min_size)
{
	cur_size = min_size + 1;
	lim_code = 1 << cur_size;
	clr_code = 1 << min_size;
	end_code = clr_code + 1;
	und_code = def_code = end_code + 1;
	navail_bytes = nbits_left = 0;
	return(0);
}

/*
;----------------------------------------------------------------------------
;	get_next_code()
;	- gets the next code from the GIF file.  Returns the code, or else
;	a negative number in case of file errors...
*/
LOCAL WORD get_next_code()
{
	WORD i, x;
	ULONG ret;

	if (nbits_left == 0)
	{
		if (navail_bytes <= 0)
		{

/*
;	Out of bytes in current block, so read next block
*/
			pbytes = byte_buff;
			if ((navail_bytes = get_byte()) < 0)
				return(navail_bytes);
			else if (navail_bytes)
			{
				for (i = 0; i < navail_bytes; ++i)
				{
					if ((x = get_byte()) < 0)
						return(x);
					byte_buff[i] = x;
				}
			}
		}
		b1 = *pbytes++;
		nbits_left = 8;
		--navail_bytes;
	}

	ret = b1 >> (8 - nbits_left);
	while (cur_size > nbits_left)
	{
		if (navail_bytes <= 0)
		{

/*
;	Out of bytes in current block, so read next block
*/
			pbytes = byte_buff;
			if ((navail_bytes = get_byte()) < 0)
				return(navail_bytes);
			else if (navail_bytes)
			{
				for (i = 0; i < navail_bytes; ++i)
				{
					if ((x = get_byte()) < 0)
						return(x);
					byte_buff[i] = x;
				}
			}
		}
		b1 = *pbytes++;
		ret |= b1 << nbits_left;
		nbits_left += 8;
		--navail_bytes;
	}
	nbits_left -= cur_size;
	ret &= code_mask[cur_size];
	return((WORD)(ret));
}

/*
;----------------------------------------------------------------------------
;	The reason we have these seperated like this instead of using
;	a structure like the original Wilhite code did, is because this
;	stuff generally produces significantly faster code when compiled...
;	This code is full of similar speedups...  (For a good book on writing
;	C for speed or for space optomisation, see Efficient C by Tom Plum,
;	published by Plum-Hall Associates...)
;----------------------------------------------------------------------------
*/

LOCAL UTINY	stack[MAX_CODES + 1];	/* Stack for storing bytes */
LOCAL UTINY	suffix[MAX_CODES + 1];	/* Suffix table */
LOCAL UWORD	prefix[MAX_CODES + 1];	/* Prefix linked list */

/*
;----------------------------------------------------------------------------
;	WORD decoder(WORD linewidth)
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
*/

WORD decoder(WORD linewidth)
{
	FAST UTINY	*sp, *bufptr;
	UTINY		*buf;
	FAST WORD	link_code, suff_code, prev_code, bufcnt;
	WORD		next_code, min_size, ret;

/*
;	Initialize for decoding a new image...
*/

	if ((min_size = get_byte()) < 0)
		return(min_size);
	if (min_size < 2 || 9 < min_size)
		return(BAD_CODE_SIZE);
	init_exp(min_size);

/*
;	Initialize in case they forgot to put in a clear code.
;	(This shouldn't happen, but we'll try and decode it anyway...)
*/

	prev_code = suff_code = 0;

/*
;	Allocate space for the decode buffer
*/

	if ((buf = (UTINY *)malloc(linewidth + 1)) == NULL)
		return(OUT_OF_MEMORY);

/*
;	Set up the stack pointer and decode buffer pointer
*/

	sp = stack;
	bufptr = buf;
	bufcnt = linewidth;

/*
;	This is the main loop.  For each code we get we pass through the
;	linked list of prefix codes, pushing the corresponding "character" for
;	each code onto the stack.  When the list reaches a single "character"
;	we push that on the stack too, and then start unstacking each
;	character for output in the correct order.  Special handling is
;	included for the clear code, and the whole thing ends when we get
;	an ending code.
*/
	while ((next_code = get_next_code()) != end_code)
	{

/*
;	If we had a file error, return without completing the decode
*/
		if (next_code < 0)
		{
			free(buf);
			return(0);
		}

/*
;	If the code is a clear code, reinitialize all necessary items.
*/
		if (next_code == clr_code)
		{
			cur_size = min_size + 1;
			und_code = def_code;
			lim_code = 1 << cur_size;

/*
;	Continue reading codes until we get a non-clear code
;	(Another unlikely, but possible case...)
*/
			while ((next_code = get_next_code()) == clr_code)
			;

/*
;	If we get an ending code immediately after a clear code
;	(Yet another unlikely case), then break out of the loop.
*/
			if (next_code == end_code)
				break;

/*
;	Finally, if the code is beyond the range of already set codes,
;	(This one had better NOT happen...  I have no idea what will
;	result from this, but I doubt it will look good...) then set it
;	to color zero.
*/
			if (next_code >= und_code)
				next_code = 0;

			prev_code = suff_code = next_code;

/*
;	And let us not forget to put the char into the buffer... And
;	if, on the off chance, we were exactly one pixel from the end
;	of the line, we have to send the buffer to the out_line()
;	routine...
*/
			*bufptr++ = next_code;
			if (--bufcnt == 0)
			{
				if ((ret = out_line(buf, linewidth)) < 0)
				{
					free(buf);
					return(ret);
				}
				bufptr = buf;
				bufcnt = linewidth;
			}
		}
		else
		{

/*
;	In this case, it's not a clear code or an ending code, so
;	it must be a code code...  So we can now decode the code into
;	a stack of character codes. (Clear as mud, right?)
*/
			link_code = next_code;

/*
;	Here we go again with one of those off chances...  If, on the
;	off chance, the code we got is beyond the range of those already
;	set up (Another thing which had better NOT happen...) we trick
;	the decoder into thinking it actually got the last code read.
;	(Hmmn... I'm not sure why this works...  But it does...)
*/
			if (link_code >= und_code)
			{
				if (link_code > und_code)
					++bad_code_count;
				link_code = prev_code;
				*sp++ = suff_code;
			}

/*
;	Here we scan back along the linked list of prefixes, pushing
;	helpless characters (ie. suffixes) onto the stack as we do so.
*/
			while (link_code >= def_code)
			{
				*sp++ = suffix[link_code];
				link_code = prefix[link_code];
			}

/*
;	Push the last character on the stack, and set up the new
;	prefix and suffix, and if the required slot number is greater
;	than that allowed by the current bit size, increase the bit
;	size.  (NOTE - If we are all full, we *don't* save the new
;	suffix and prefix...  I'm not certain if this is correct...
;	it might be more proper to overwrite the last code...
*/
			*sp++ = link_code;
			if (und_code < lim_code)
			{
				suffix[und_code] = suff_code = link_code;
				prefix[und_code++] = prev_code;
				prev_code = next_code;
			}
			if (und_code >= lim_code)
				if (cur_size < 12)
				{
					lim_code <<= 1;
					++cur_size;
				} 

/*
;	Now that we've pushed the decoded string (in reverse order)
;	onto the stack, lets pop it off and put it into our decode
;	buffer...  And when the decode buffer is full, write another
;	line...
*/
			while (sp > stack)
			{
				*bufptr++ = *(--sp);
				if (--bufcnt == 0)
				{
					if ((ret = out_line(buf, linewidth)) < 0)
					{
						free(buf);
						return(ret);
					}
					bufptr = buf;
					bufcnt = linewidth;
				}
			}
		}
	}
	ret = 0;
	if (bufcnt != linewidth)
		ret = out_line(buf, (linewidth - bufcnt));
	free(buf);
	return(ret);
}
/*
;----------------------------------------------------------------------------
;	End of file:	DECODER.C
;----------------------------------------------------------------------------
*/
