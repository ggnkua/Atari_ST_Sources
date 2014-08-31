/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*

	- PORTAB.H vom 3.7.96
	- (U)WORD ist jetzt als short definiert
	- Damit Aufrufe, bei denen (int *) erwartet werden und (WORD *)
	  Åbergeben wurden, mit der neuen Form keine Probleme erzeugen,
	  wird int als short definiert.
*/

#if !defined( __PORTAB__ )
#define __PORTAB__

#ifndef __2B_UNIVERSAL_TYPES__										/* schon vorhanden? */
	#include	<TYPES2B.H>
#endif

#undef	int
#define	int	short														/* int durch short ersetzen */

typedef void				VOID;
typedef int8				BYTE;
typedef int16				WORD;
typedef int32				LONG;
typedef uint8				UBYTE;
typedef uint16				UWORD;
typedef uint32				ULONG;
typedef uint8				BOOLEAN;

#endif
