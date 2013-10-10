// Emacs style mode select   -*- C++ -*- 
//-----------------------------------------------------------------------------
//
// $Id:$
//
// Copyright (C) 1993-1996 by id Software, Inc.
//
// This source is available for distribution and/or modification
// only under the terms of the DOOM Source Code License as
// published by id Software. All rights reserved.
//
// The source is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// FITNESS FOR A PARTICULAR PURPOSE. See the DOOM Source Code License
// for more details.
//
// DESCRIPTION:
//	Endianess handling, swapping 16bit and 32bit.
//
//-----------------------------------------------------------------------------

#ifndef __M_SWAP__
#define __M_SWAP__

#include <SDL_endian.h>

// Endianess handling.
// WAD files are stored little endian.
#if SDL_BYTEORDER == SDL_BIG_ENDIAN

#if defined(__GNUC__) && (defined(__M68000__) || defined(__M68020__))

/*RA: The two 'extended asm' macros below allow  byteswaps	*/
/*    to be performed without function call overhead costs.	*/
/*    The code used gives Gnu C optimizer maximum freedom.	*/

#define	SwapSHORT(x)				\
__extension__						\
({	register unsigned short retv;	\
	__asm__							\
	(	"rorw	#8,%0"				\
		/* end of code */			\
	:	"=d"	(retv)				\
	:	"0"		(x)					\
	:	"cc"						\
	);	/* end of asm */			\
	retv;							\
})

#define	SwapLONG(x)					\
__extension__						\
({	register unsigned long retv;	\
	__asm__							\
	(	"rorw	#8,%0\n\t"			\
		"swap	%0\n\t"				\
		"rorw	#8,%0"				\
		/* end of code */			\
	:	"=d"	(retv)				\
	:	"0"		(x)					\
	:	"cc"						\
	);	/* end of asm */			\
	retv;							\
})

#else

unsigned short	SwapSHORT(unsigned short);
unsigned long	SwapLONG(unsigned long);

#endif

#define SHORT(x)	((short)SwapSHORT((unsigned short) (x)))
#define LONG(x)         ((long)SwapLONG((unsigned long) (x)))

#else
#define SHORT(x)	(x)
#define LONG(x)         (x)
#endif

#endif
