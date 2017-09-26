/*----------------------------------------------------------------------------------------
	portab.h, part of TOS Linker for CodeWarrior
	
	21.10.1998 by Manfred Lippert, Sven & Wilfried Behne

	last change: 31.1.2000

	Don't edit this file - use target.h for project specific configurations!

	If you have to make any changes on this file, please contact:
	mani@mani.de
----------------------------------------------------------------------------------------*/

#ifndef __PORTAB__
#define __PORTAB__

#include	<Types2B.h>

/*----------------------------------------------------------------------------------------
	macros for function definitions and declarations
	C_CALL		- definition of C function (without C++ name mangling)
	CDECL		- definition/declaration of function with parameters on stack
----------------------------------------------------------------------------------------*/

#if __cplusplus															/* Definition für externe C-Funktionen */
	#define C_CALL "C"
#else
	#define C_CALL
#endif

#if __MWERKS__																/* Metrowerks CodeWarrior */

#if __INTEL__
	#define	CDECL	__cdecl
#else
	#define	CDECL
#endif

#elif __PUREC__															/* Pure C */

	#define	CDECL	cdecl
	
#elif _MSC_VER																/* MSVC */

	#define	CDECL	__cdecl

#elif __GNUC__																/* GNU */

	#define	CDECL

#else
	#error Unknown compiler
#endif

/*----------------------------------------------------------------------------------------
	bool definition
----------------------------------------------------------------------------------------*/
#if __MWERKS__
	#if !__cplusplus || !__option(bool)
		#define	bool	boolean
	#endif
#elif __PUREC__
		#define	bool	boolean
#else
	#error Unknown Compiler
#endif

/*----------------------------------------------------------------------------------------
	Macros for callbacks and parameter passing via registers
----------------------------------------------------------------------------------------*/
#include	<Types68k.h>

/*----------------------------------------------------------------------------------------
	old types, if wanted
----------------------------------------------------------------------------------------*/
#if USE_OLD_TYPES
#include <oldtypes.h>
#endif

#endif
