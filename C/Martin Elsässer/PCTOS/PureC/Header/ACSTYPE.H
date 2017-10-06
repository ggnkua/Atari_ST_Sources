/******************************************************************************/
/*																										*/
/*		ACS				Application Construction System									*/
/*		REVISION:		17. Juni 2000															*/
/*		DESCRIPTION:	Headerdatei 															*/
/*							Die grundlegenden Datentypen & Strukturen						*/
/*																										*/
/* (c) 1991-1999 Stefan Bachert, Oliver Michalak, Martin ElsÑsser					*/
/******************************************************************************/

#ifndef __ACSTYPE__
#define __ACSTYPE__

/* SchlÅsselwort cdecl gibt's nur in Turbo-C bzw. Pure C */
#ifdef __TURBOC__
	#define CDECL	cdecl
	typedef signed char		CHAR;
	typedef unsigned char	UCHAR;
	typedef int					INT16;
	typedef unsigned int		UINT16;
	typedef long				INT32;
	typedef unsigned long	UINT32;
#else
	#ifdef LATTICE
		#define CDECL	__stdargs
		typedef signed char		CHAR;
		typedef unsigned char	UCHAR;
		typedef short				INT16;
		typedef unsigned int		UINT16;
		typedef long				INT32;
		typedef unsigned long	UINT32;
	#else
		#define CDECL
		typedef signed char		CHAR;
		typedef unsigned char	UCHAR;
		typedef short				INT16;
		typedef unsigned short	UINT16;
		typedef long				INT32;
		typedef unsigned long	UINT32;
	#endif
#endif

/* Ggf. muû NULL definiert werden */
#ifndef NULL
	#define NULL ((void *) 0L)
#endif

/* Die boolschen Werte sollten auch verfÅgbar sein */
#ifndef FALSE
	#define FALSE (0)
#endif

#ifndef TRUE
	#define TRUE (1)
#endif

/* RÅckgabewerte von diversen Funktionen */
#ifndef FAIL
	#define FAIL (-1)
#endif

#ifndef OK
	#define OK (0)
#endif

/******************************************************************************/

/* Position eines Runktes */
typedef struct
{
	INT16 x;
	INT16 y;
} Axy;

/******************************************************************************/

/* Breite und Hîhe eines Rechteckes */
typedef struct
{
	INT16 w;
	INT16 h;
} Awh;

/******************************************************************************/

/* Beschreibung eines Rechteckes */
typedef struct
{
	INT16 x;
	INT16 y;
	INT16 w;
	INT16 h;
} Axywh;

/******************************************************************************/

/* Farbbeschreibungen */
typedef struct
{
	INT16 red;
	INT16 green;
	INT16 blue;
} RGB;

/******************************************************************************/

#endif
