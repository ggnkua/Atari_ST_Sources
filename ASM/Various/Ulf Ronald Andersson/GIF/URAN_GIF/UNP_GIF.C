/*
;----------------------------------------------------------------------------
; File name:	UNP_GIF.C			Revision date:	1995.06.24
; Revised by:	Ulf Ronald Andersson		Revision start:	1993.09.19
; Created by:	Steven A. Bennett		Creation date:	1987.xx.yy
; File purpose:	LZW decoder for GIF87
;----------------------------------------------------------------------------
*/
#define	MAX_CODES	4095
#define	end_case	break;
typedef	long	( * READ_FN_p )( int fh, long cnt, void *buff );

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
;	Static arrays
*/
LOCAL WORD	code_mask_t[13] =	/*  Table of all code masks	*/
{
	0,
	0x0001, 0x0003,
	0x0007, 0x000F,
	0x001F, 0x003F,
	0x007F, 0x00FF,
	0x01FF, 0x03FF,
	0x07FF, 0x0FFF
};
LOCAL UBYTE	pixel_buf[MAX_CODES + 1];  /* for unpacking		*/
LOCAL UBYTE	suffix[MAX_CODES + 1];	   /* Suffix table (pixel data)	*/
LOCAL UWORD	prefix[MAX_CODES + 1];	   /* Prefix table (macro link)	*/
/*
;----------------------------------------------------------------------------
;	The following static variables are used
;	for seperating out codes in 'read_code'
*/
READ_FN_p	GIF_read_p;		/*  -> User def'd read routine	*/
LOCAL UBYTE	*read_buf_p;		/*  -> Byte pos in input buffer	*/
LOCAL WORD	rem_byte_cnt;		/*  Remaining bytes in block	*/
LOCAL UBYTE	cur_byte;		/*  Current byte		*/
LOCAL WORD	rem_bits_cnt;		/*  Remaining bits in byte	*/
LOCAL WORD	code_mask;		/*  Code mask for current size	*/
LOCAL UBYTE	block_buf[257];		/*  Current block		*/
LOCAL UBYTE	*block_pos_p;		/*  -> Next block byte		*/
/*
;----------------------------------------------------------------------------
*/
void	init_GIF_decode ( READ_FN_p GIF_reader )
{	code_state = 0;
	GIF_read_p = GIF_reader;
}
/*
;----------------------------------------------------------------------------
;End of:	init_GIF_decode ( READ_FN_p GIF_reader )
;----------------------------------------------------------------------------
*/
/*
;----------------------------------------------------------------------------
;	WORD	GIF_decode ( WORD pic_size, UBYTE *pic_base_p )
;	- This function decodes an LZW image, according to the method used
;	in the GIF spec.
;	The function gets it's codes from
;	read_code() which is responsible for reading blocks of data and
;	seperating them into the proper size codes.  Finally, get_byte() is
;	the global routine to read the next byte from the GIF file.
;
;	It is generally a good idea to have pic_size correspond to the actual
;	width of a line (as specified in the Image header) to make your own
;	code a bit simpler, but it can also be the entire image size.
;
;	Returns: positive code_state if successful, else negative error_code.
;
;	error -(256 + size) means that GIF has illegal code size.
;	error -256 means that decoding was already complete
;	error -1..-255 are GEMDOS error codes
;	state 0 is never returned, but only exists before the first call,
;	state 1 is normal return when no special actions are pending
;	state 2 is normal return when output expansion incomplete
;	state 3 is returned at completion of GIF, and only at that call
;
;
;
*/
WORD GIF_decode ( WORD pic_size, UBYTE *pic_base_p )
{	UBYTE	*sp, *pic_pos_p;
	WORD	lnk_code, suff_code, pref_code, buf_cnt;
	WORD	cur_code, min_size, ret;
/**/
	switch ( code_state )
	{
	case	0:	/* Complete reset needed */
		if ((min_size = get_byte()) < 0)	return( min_size );
		if (min_size < 2 || 9 < min_size)	return( -(1<<8+minsize) );
/**/
		cur_size = min_size + 1;
		lim_code = 1 << cur_size;
		clr_code = 1 << min_size;
		end_code = clr_code + 1;
		und_code = def_code = end_code + 1;
		rem_byte_cnt = rem_bits_cnt = 0;
/**/
		pref_code = suff_code = 0;
		sp = stack;
		pic_pos_p = pic_base_p;
		buf_cnt = pic_size;
		code_state = 1;
	end_case
	case	1:	/* Normal reentry state */
	end_case
	case	2:	/* Reentry with ongoing output expansion */
		while (sp > stack)	/* output LOOP start*/
		{	*pic_pos_p++ = *(--sp);
			if (--buf_cnt == 0)		/* line FULL */
			{	pic_pos_p = pic_base_p;
				buf_cnt = pic_size;
				return ( code_state );
			}/* end_if */
		}/* end_while */
		code_state = 1;
	end_case
	case	3:	/* Illegal reentry at EOF */
		return ( -256 );
	end_case
/*
;	Here is the main loop.  For each code we get we pass through the
;	linked list of prefix codes, pushing the corresponding "character" for
;	each code onto the stack.  When the list reaches a single "character"
;	we push that on the stack too, and then start unstacking each
;	character for output in the correct order.  Special handling is
;	included for the clear code, and the whole thing ends when we get
;	an ending code.
*/
	while ( 1 )
	{	cur_code = read_code();
		if( cur_code == end_code )
		{	code_state = 3;
			return ( code_state );
		}
		if (cur_code < 0)	return( cur_code );
		if (cur_code == clr_code)
		{	cur_size = min_size + 1;
			und_code = def_code;
			lim_code = 1 << cur_size;
			while ((cur_code = read_code()) == clr_code)
			;
			if (cur_code == end_code)
				break;
			if (cur_code >= und_code)	/* error in GIF */
				cur_code = 0;
			pref_code = suff_code = cur_code;
			*pic_pos_p++ = cur_code;
			if (--buf_cnt == 0)		/* line FULL */
			{	pic_pos_p = pic_base_p;
				buf_cnt = pic_size;
				return( 0 );
			}
		}/* if (cur_code == clr_code) */
		else
		{	/* pixel_data or macro */
			lnk_code = cur_code;
			if (lnk_code >= und_code)	/* error in GIF */
			{	if (lnk_code > und_code)
					++bad_code_count;
				lnk_code = pref_code;
				*sp++ = suff_code;
			}
/* scan & push */
			while (lnk_code >= def_code)	/* loop for macro */
			{	*sp++ = suffix[lnk_code];
				lnk_code = prefix[lnk_code];
			}
/* push last, and save (if needed) */
			*sp++ = lnk_code;
			if (und_code < lim_code)
			{	suffix[und_code] = suff_code = lnk_code;
				prefix[und_code++] = pref_code;
				pref_code = cur_code;
			}
			if (und_code >= lim_code)
				if (cur_size < 12)
				{	lim_code <<= 1;
					++cur_size;
				} 
			while (sp > stack)	/* output LOOP start*/
			{	*pic_pos_p++ = *(--sp);
				if (--buf_cnt == 0)		/* line FULL */
				{	pic_pos_p = pic_base_p;
					buf_cnt = pic_size;
					if ( sp > stack )
						code_state = 2;
					return ( code_state );
				}/* end_if */
			}/* end_while */
		}/* end_if */
	}/* end_while */	
}
/*
;----------------------------------------------------------------------------
;End of:	WORD GIF_decode(WORD pic_size, UBYTE *pic_base_p)
;----------------------------------------------------------------------------
*/
/*
;----------------------------------------------------------------------------
;	read_code()
;	- gets the next code from the GIF file.  Returns the code, or else
;	a negative number in case of file errors...
*/
LOCAL WORD read_code()
{	WORD i, x;
	ULONG ret;
	if (rem_bits_cnt == 0)
	{	if (rem_byte_cnt <= 0)		/* block EMPTY */
		{	block_pos_p = block_buf;
			if ((rem_byte_cnt = get_byte()) < 0)
				return(rem_byte_cnt);
			else if (rem_byte_cnt)
			{	for (i = 0; i < rem_byte_cnt; ++i)
				{	if ((x = get_byte()) < 0)
						return(x);
					block_buf[i] = x;
				}
			}
		}
		cur_byte = *block_pos_p++;
		rem_bits_cnt = 8;
		--rem_byte_cnt;
	}
	ret = cur_byte >> (8 - rem_bits_cnt);
	while (cur_size > rem_bits_cnt)
	{	if (rem_byte_cnt <= 0)		/* block EMPTY */
		{	block_pos_p = block_buf;
			if ((rem_byte_cnt = get_byte()) < 0)
				return(rem_byte_cnt);
			else if (rem_byte_cnt)
			{	for (i = 0; i < rem_byte_cnt; ++i)
				{	if ((x = get_byte()) < 0)
						return(x);
					block_buf[i] = x;
				}
			}
		}
		cur_byte = *block_pos_p++;
		ret |= cur_byte << rem_bits_cnt;
		rem_bits_cnt += 8;
		--rem_byte_cnt;
	}
	rem_bits_cnt -= cur_size;
	ret &= (LONG) code_mask_t[cur_size];
	return((WORD)(ret));
}
/*
;----------------------------------------------------------------------------
;End of:	LOCAL WORD read_code()
;----------------------------------------------------------------------------
*/
/*
;----------------------------------------------------------------------------
;End of file:	UNP_GIF.C
;----------------------------------------------------------------------------
*/
