/*
*********************************************************************
*	File name:	PCR_CONV.C				Revision date:	1992.07.18	*
*	Author:		Ulf Ronald Andersson	Creation date:	1992.07.18	*
*	Copyright:	Released as PD FREEWARE without conditions.			*
*	Purpose:	Convert numbers from PC-basic 4-byte real format	*
*	  -''-		to 4-byte longword (68000 byte order), as needed to	*
*	  -''-		handle QWK-format mail packets on Atari ST/STE.		*
*********************************************************************
*/


/*
 *	'pcr2l' converts from PC-real format to standard longword.
 *	Any obviously illegal values (from erroneous .NDX files) will be
 *  converted to negative values, or to zero.
 *	Thus converted value can be tested for legality, simply by
 *	testing that it is larger than zero.
 */

long cdecl pcr2l(long pcr)
{	register long	expo,sign;
	if	((expo = pcr & 0xFFL) == 0)  return 0L;
	sign = pcr & 0x8000L;
	pcr = (((pcr&0xFF00L)|0x8000L)<<8)|((pcr&0xFF0000L)>>8)|((pcr&0xFF000000L)>>24);
	if	((expo -= 0x98L) <= 0)
	{	if	(-expo > 24)	return 0L;		/* Value too small (pcr < 1) */
		pcr >>= -expo;
	}	/* end if */
	else
		return 0x80000000L;	/* Value too large (abs(pcr) > 2**23) */
	if	(sign)
		return -pcr;		/* Value negative */
	else
		return pcr;
}	/* End func long pcr_to_long(long pcr) */


/*
 *	'l2pcr' converts from standard longword to PC-real format.
 *	No error checking is done here, but for QWK use all index
 *	values should be limited to 24 bit values.
 */

long cdecl l2pcr(long pcr)
{	register long	expo,sign;
	if	(pcr==0)  return 0;
	sign = (pcr>>16) & 0x8000L;
	if	(sign)
	{	pcr = -pcr;
		if	(pcr < 0)  return 0x80A0L;
	}
	for	(expo = 0x9F; (pcr <<= 1) >= 0; expo--);
	return sign|expo|((pcr&0x7F000000L)>>16)|(pcr&0xFF0000L)|((pcr&0xFF00L)<<16);
}	/* End func long long_to_pcr(long pcr) */


/*	End of file:	PCR_CONV.C	*/