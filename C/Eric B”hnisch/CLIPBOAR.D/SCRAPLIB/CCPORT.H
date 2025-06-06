/**********
*
*	Headerfile zur Erzeugung portabler C-Programme auf dem ST
*	---------------------------------------------------------
*
*	Unterst�tzt werden die Compiler-Systeme:
*		- Mark Williams C V1.1
*		- Lattice C V3.03.04
*		- Alcyon C (Entwicklungssystem)
*		- Megamax C V1.1
*
*	Dieser Header ist f�r die Einbindung in GEM-Programme gedacht.
*	Enthalten sind:
*		- Definitionen portabler Datengr��en
*		- Die je nach System unterschiedlichen Includes
*		- Einige h�ufig benutzte Funktionsdeklarationen
*
*	02/87	Gerd M�llmann
*
***********/





/* 
 * Compilerauswahl.
 * ----------------
 * Nicht alle Compiler unterst�tzen die Definition von Pr�prozessor-
 * Konstanten und Makros in einer Kommandozeile, deshalb hier eine
 * gesonderte Auflistung. Nicht zutreffendes auskommentieren oder -
 * besser noch - mit "#ifdef" oder "#ifndef" ausklammern. Nicht "#if"
 * verwenden, wenn die Quelltexte mit "Megamax" kompiliert werden
 * sollen (funktioniert dort nicht). 
 */

#define 	LATTICE




/*
 * Portable Datengr��en
 * --------------------
 * Normalerweise verwendet man auf dem ST Makros, um portable 
 * Datengr��en zu erhalten (BYTE, WORD, ...). Da diese aber alle gro�-
 * geschrieben werden m�ssen, was einen zus�tzicher Aufwand bei der Eingabe
 * bedeutet, schlage ich alternativ "typedef"-Vereinbarungen vor.
 * Ich selbst verwende mal das eine, mal das andere.
 */

#define	REG	register		/* Verwendet man Makros f�r	*/
#define EXTERN	extern			/* die Typ-Bezeichnung, mu� man	*/
#define LOCAL	auto			/* auch die Speicherklassen	*/
#define MLOCAL	static			/* gro�schreiben k�nnen, alles	*/
					/* andere sieht nicht aus	*/
#ifdef 	MARK_WILLIAMS

#	define	BYTE	char		/* 8 Bits mit Vorzeichen	*/
#	define	UBYTE	unsigned char	/* 8 Bits ohne Vorzeichen	*/
#	define 	WORD	int		/* 16 Bits mit			*/
#	define	UWORD	unsigned	/*	und ohne Vorzeichen	*/
#	define  LONG	long		/* 32 Bits mit			*/
#	define  ULONG	unsigned long	/* 	und ohne Vorzeichen	*/
#	define	VOID	void		/* Typ "statement" o. "expr."	*/

typedef	char		byte;		/* das gleiche als Typ-		*/
typedef unsigned char	ubyte;		/* 	Variablen		*/
typedef	int		word;
typedef	unsigned 	uword;
typedef	unsigned long	ulong;

#endif

#ifdef	LATTICE
#	define	BYTE	char
#	define	UBYTE	unsigned char
#	define 	WORD	short		/* bei Lattice ist "int" 32	*/
#	define	UWORD	unsigned short	/* Bits lang			*/
#	define  LONG	int
#	define  ULONG	unsigned
#	define	VOID	void

typedef	char		byte;
typedef unsigned char	ubyte;
typedef	short		word;
typedef	unsigned short 	uword;
typedef	unsigned 	ulong;

#endif

#ifdef	DIGITAL

#	define	BYTE	char		/* Vorsicht! Alcyon kennt nur	*/
#	define	UBYTE	char		/* "signed char", also immer 	*/
#	define 	WORD	int		/* Casts verwenden, wenn es auf	*/
#	define	UWORD	unsigned int	/* "unsigned char" ankommt!	*/
#	define  LONG	long		/* gleiches gilt f�r "long"	*/
#	define  ULONG	long
#	define	VOID	int		/* kein "void" (?)		*/

typedef	char		byte;
typedef char		ubyte;
typedef	int		word;
typedef	unsigned int 	uword;
typedef	long		ulong;
typedef int		void;

#endif

#ifdef	MEGAMAX

#	define	BYTE	char
#	define	UBYTE	unsigned char
#	define 	WORD	int
#	define	UWORD	unsigned int
#	define  LONG	long
#	define  ULONG	unsigned long
#	define	VOID	int

typedef	char		byte;
typedef unsigned char	ubyte;
typedef	int		word;
typedef	unsigned int 	uword;
typedef	unsigned long	ulong;
typedef int		void;		/* kein "void"			*/
	
#endif





/*
 * Konstanten
 * ----------
 * Die am h�ufigsten gebrauchten und bekanntesten Konstanten kann man 	
 * an dieser Stelle auch gleich einf�gen:
 */

#define	NULL	((byte*)0L)	/* Ein Mu� bei Alcyon, wenn portab.h	*/
#define EOS	((byte)0)	/* nicht mit "#include" eingeschlossen	*/
#define TRUE	1		/* wird					*/
#define FALSE	0
#define ON	1
#define OFF	0
#define	YES	1
#define	NO	0
#define	FOREVER	for(;;)





/*
 * Include-Files
 * -------------
 * Hier sind alle normalerweise zur GEM-Programmierung ben�tigten
 * Include-Files aufgef�hrt.
 */

#ifdef MARK_WILLIAMS			/* Mark-Williams V1.1	*/
#	include <stdio.h>	
#	include <osbind.h>	
#	include <aesbind.h>
#	include <vdibind.h>
#	include <obdefs.h>
#	include <gemdefs.h>
#	include <scraplib.h>
#endif

#ifdef	DIGITAL				/* Alcyon-C		*/
#	include <stdio.h>
#	include <gembind.h>
#	include <gemdefs.h>
#	include <obdefs.h>
#	include <vdibind.h>
#	include <osbind.h>
#	include <scraplib.h>
#endif

#ifdef MEGAMAX				/* Megamax V1.1		*/
#	include <stdio.h>
#	include <osbind.h>
#	include <gembind.h>
#	include <obdefs.h>
#	include <gemdefs.h>
#	include <scraplib.h>
#endif

#ifdef	LATTICE				/* Lattice V3.04 mit Digilib */
# 	include "stdio.h"
#	include "stdlib.h"
#	include "string.h"
#	include "osbind.h"
#	include "dos.h"
#	include "gemlib.h"
#	include "math.h"
#	include "scraplib.h"
#endif
