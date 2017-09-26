/*----------------------------------------------------------------------------------------
	oldtypes.h, part of TOS Linker for CodeWarrior
	
	21.10.1998 by Manfred Lippert

	last change: 21.10.1998

	Don't include this file by your own.
	This file is only included by portab.h, if USE_OLD_TYPES is
	defined in target.h.
----------------------------------------------------------------------------------------*/

#ifndef __OLD_TYPES__
#define __OLD_TYPES__


typedef void	VOID;
typedef int8	BYTE;
typedef int16	WORD;
typedef int32	LONG;
typedef uint8	UBYTE;
typedef uint16	UWORD;
typedef uint32	ULONG;
typedef uint8	BOOLEAN;

/*
	int durch int16 ersetzen, da die alten TOS-Bindings int verwenden, und dabei 
	eine vorzeichenbehaftete Variable mit 16 Bit meinen.
*/

#undef	int
#define	int	int16

#endif
