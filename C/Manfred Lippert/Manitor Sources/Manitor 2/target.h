/*--------------------------------------------------------
	target.h
	
	21.10.1998 Manfred Lippert

	last change: 12.11.1998

	Place a copy of this file in a reachable path of
	your project. Edit this copy to set target options.

	This file is then included by "portab.h".
	
--------------------------------------------------------*/

/*--------------------------------------------------------
	Target platform
--------------------------------------------------------*/

#define	TARGET_TOS			1
#define	TARGET_MACOS		0
#define	TARGET_WINOS		0

/*--------------------------------------------------------
	Target options
--------------------------------------------------------*/

#define USE_OLD_TYPES		0	/* define old types (INT, LONG, ...) */
#define USE_INLINE			1	/* use inline assembler */
