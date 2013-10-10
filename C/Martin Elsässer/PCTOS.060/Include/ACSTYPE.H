/******************************************************************************/
/*																										*/
/*		ACS				Application Construction System									*/
/*		REVISION:		17. November 2002														*/
/*		DESCRIPTION:	Headerdatei 															*/
/*							Die grundlegenden Datentypen & Strukturen						*/
/*																										*/
/* (c) 1991-2004 Stefan Bachert, Oliver Michalak, Martin ElsÑsser					*/
/******************************************************************************/

#ifndef __ACSTYPE__
#define __ACSTYPE__

/******************************************************************************/
/*																										*/
/* Ggf. die Datentypen aus dem NVDI-Header Types2B.H definieren, falls dieses	*/
/*	Headerfile nicht bereits eingelesen wurde												*/
/*																										*/
/******************************************************************************/

#ifndef __2B_UNIVERSAL_TYPES__
	#define __2B_UNIVERSAL_TYPES__

	/*-------------------------------------------------------------------------*/
	/* Standarddatentypen fÅr 8, 16, 32 und 64 Bit										*/
	/*-------------------------------------------------------------------------*/

	/* Falls PORTAB bereits eingelesen wurde, werden diese Daten verwendet */
	#if defined(__PORTAB__)			/* Die PORTAB-Definitionen Åbernehmen */
		
		/* Die Grîûe der Datentypen prÅfen */
		#if sizeof(BYTE)!=1
			#error "BYTE hat keine 8 Bit!"
		#endif
		#if sizeof(UBYTE)!=1
			#error "UBYTE hat keine 8 Bit!"
		#endif
		#if sizeof(WORD)!=2
			#error "WORD hat keine 16 Bit!"
		#endif
		#if sizeof(UWORD)!=2
			#error "UWORD hat keine 16 Bit!"
		#endif
		#if sizeof(LONG)!=4
			#error "LONG hat keine 32 Bit!"
		#endif
		#if sizeof(ULONG)!=4
			#error "ULONG hat keine 32 Bit!"
		#endif
		
		typedef BYTE	int8;
		typedef UBYTE	uint8;
		typedef WORD	int16;
		typedef UWORD	uint16;
		typedef LONG	int32;
		typedef ULONG	uint32;
		typedef BOOLEAN boolean;
		
	#elif defined(__PORTAB_H__)	/* Die PORTAB-Definitionen von CAT Åbernehmen */
		
		/* Die Grîûe der Datentypen prÅfen */
		#if sizeof(_BYTE)!=1
			#error "_BYTE hat keine 8 Bit!"
		#endif
		#if sizeof(_UBYTE)!=1
			#error "_UBYTE hat keine 8 Bit!"
		#endif
		#if sizeof(_WORD)!=2
			#error "_WORD hat keine 16 Bit!"
		#endif
		#if sizeof(_UWORD)!=2
			#error "_UWORD hat keine 16 Bit!"
		#endif
		#if sizeof(_LONG)!=4
			#error "_LONG hat keine 32 Bit!"
		#endif
		#if sizeof(_ULONG)!=4
			#error "_ULONG hat keine 32 Bit!"
		#endif
		
		typedef _BYTE	int8;
		typedef _UBYTE	uint8;
		typedef _WORD	int16;
		typedef _UWORD	uint16;
		typedef _LONG	int32;
		typedef _ULONG	uint32;
		
	#elif defined(__STDINT__)	/* Die Definitionen aus ISO-C Åbernehmen */
		
		/* Die Grîûe der Datentypen prÅfen */
		#if sizeof(int8_t)!=1
			#error "int8_t hat keine 8 Bit!"
		#endif
		#if sizeof(uint_8)!=1
			#error "uint8_t hat keine 8 Bit!"
		#endif
		#if sizeof(int16_t)!=2
			#error "int16_t hat keine 16 Bit!"
		#endif
		#if sizeof(uint16_t)!=2
			#error "uint16_t hat keine 16 Bit!"
		#endif
		#if sizeof(int32_t)!=4
			#error "int32_t hat keine 32 Bit!"
		#endif
		#if sizeof(uint32_t)!=4
			#error "uint32_t hat keine 32 Bit!"
		#endif
		#if sizeof(int64_t)!=4
			#error "int64_t hat keine 64 Bit!"
		#endif
		#if sizeof(uint64_t)!=4
			#error "uint64_t hat keine 64 Bit!"
		#endif
		
		typedef int8_t		int8;
		typedef uint8_t	uint8;
		typedef int16_t	int16;
		typedef uint16_t	uint16;
		typedef int32_t	int32;
		typedef uint32_t	uint32;
		typedef int64_t	int64;
		typedef uint64_t	uint64;
		
	#else
		
		/* FÅr Pure-C short auf int mappen - nur dann gehen Bitfelder mit int16 in structs */
		#ifdef __PUREC__
			#define short int
		#endif
		
		/* 8 Bit vorzeichenbehaftet und vorzeichenlos */
		typedef signed char		int8;
		typedef unsigned char	uint8;
	
		/* 16 Bit vorzeichenbehaftet und vorzeichenlos */
		typedef signed short		int16;
		typedef unsigned short	uint16;
		
		/* 32 Bit vorzeichenbehaftet und vorzeichenlos */
		typedef signed long		int32;
		typedef unsigned long	uint32;
		
		/* Logische Werte */
		typedef int16	boolean;
		
	#endif
	
	/* Bei gelesenem ISO-C-Header wurde int64/uint64 bereits definiert! */
	#ifndef __STDINT__
		#if __MWERKS__ >= 0x0710		/* CodeWarrior 11 mit C-Compiler >= 7.1 ? */
			
			/* Compiler unterstÅtzt int64/uint64 */
			#define	__2B_HAS64_SUPPORT
			
			/* 64 Bit vorzeichenbehaftet und vorzeichenlos */
			typedef signed long long	int64;
			typedef unsigned long long	uint64;
	
		#elif _MSC_VER >= 900									/* MSVC 2.0? */
			
			/* Compiler unterstÅtzt int64/uint64 */
			#define	__2B_HAS64_SUPPORT
			
			/* 64 Bit vorzeichenbehaftet und vorzeichenlos */
			typedef signed __int64		int64;
			typedef unsigned __int64	uint64;
				
		#else
			
			/* Compiler ohne UnterstÅtzung von 64 Bit Integers */
			#ifdef __2B_HAS64_SUPPORT
				#undef	__2B_HAS64_SUPPORT
			#endif
			
			/* 64 Bit vorzeichenbehaftet */
			typedef struct
			{
				int32		hi;
				uint32	lo;
			} int64;
	
			/* 64 Bit vorzeichenlos */
			typedef struct
			{
				uint32	hi;
				uint32	lo;
			} uint64;
			
		#endif
	#endif
		
	/* Flieûkomma-Zahlen */
	typedef long double real;
	
	/* 16.16 vorzeichenbehaftet */
	typedef int32	fixed;
	
	/* 32.32 vorzeichenbehaftet */
	typedef int64	fixed64;
	
	/* 2.30 vorzeichenbehaftet (fÅr Berechnungen im Zahlenbereich von -1.0 bis +1.0) */
	typedef int32	fixed2p30;
	
	/*-------------------------------------------------------------------------*/
	/* Ggf. die Grîûe der Datentypen prÅfen												*/
	/*-------------------------------------------------------------------------*/
	
	#if defined(DEBUG) || defined(_DEBUG)
		#if sizeof(int8)!=1
			#error "int8 hat keine 8 Bit!"
		#endif
		#if sizeof(uint8)!=1
			#error "uint8 hat keine 8 Bit!"
		#endif
		#if sizeof(int16)!=2
			#error "int16 hat keine 16 Bit!"
		#endif
		#if sizeof(uint16)!=2
			#error "uint16 hat keine 16 Bit!"
		#endif
		#if sizeof(int32)!=4
			#error "int32 hat keine 32 Bit!"
		#endif
		#if sizeof(uint32)!=4
			#error "uint32 hat keine 32 Bit!"
		#endif
		#if sizeof(int64)!=8
			#error "int64 hat keine 64 Bit!"
		#endif
		#if sizeof(uint64)!=8
			#error "uint64 hat keine 64 Bit!"
		#endif
		#if sizeof(real)!=10
			#error "real hat keine 80 Bit!"
		#endif
		#if sizeof(boolean)!=2
			#error "boolean hat keine 16 Bit!"
		#endif
	#endif
	
	/*-------------------------------------------------------------------------*/
	/* Wandelmakros fÅr Festpunktformate													*/
	/*-------------------------------------------------------------------------*/
	
	/* Makros fÅr 16.16 */
	#define	int_to_fixed( i )					(((fixed) i ) << 16 )
	#define	double_to_fixed( f )				((fixed) ( f * ( 1L << 16 )))
	
	#define	fixed_to_int16( x )				((int16) ( x >> 16 ))
	#define	fixed_to_int32( x )				((int32) ( x >> 16 ))
	#define	fixed_to_double( x )				(((double) x ) / ( 1L << 16 ))
	
	/* Makros fÅr 32.32 - nur fÅr Compiler mit UnterstÅtzung von int64 */
	#ifdef	__2B_HAS64_SUPPORT	
		
		#define	int_to_fixed64( i )			(((fixed64) i ) << 32 )
		#define	double_to_fixed64( f )		((fixed64) ( f * ( 1L << 32 )))
		
		#define	fixed64_to_int16( x )		((int16) ( x >> 32 ))
		#define	fixed64_to_int32( x )		((int32) ( x >> 32 ))
		#define	fixed64_to_int64( x )		((int64) ( x >> 32 ))
		#define	fixed64_to_double( x )		(((double) x ) / ( 1L << 32 ))
		
	#endif
	
	/* Makros fÅr 2.30 */
	#define	int_to_fixed2p30( i )		(((fixed2p30) i ) << 30 )
	#define	double_to_fixed2p30( f )	((fixed2p30) ( f * ( 1L << 30 )))
	
	#define	fixed2p30_to_int16( x )		((int16) ( x >> 30 ))
	#define	fixed2p30_to_int32( x )		((int32) ( x >> 30 ))
	#define	fixed2p30_to_double( x )	(((double) x ) / ( 1L << 30 ))
	
	/*-------------------------------------------------------------------------*/
	/* Wandelmakros fÅr Little-Endian (Intel)												*/
	/*-------------------------------------------------------------------------*/
	
	#define	REVERSE16( a ) 	(int16)(((uint16)(a) >> 8 ) | ((uint16)(a) << 8 ))
	#define	REVERSEu16( a )	(((uint16)(a) >> 8 ) | ((uint16)(a) << 8 ))
	
	#define	REVERSE32( a )		(int32)(((uint32)(a) << 24 ) | (((uint32)(a) & 0xff00L ) << 8 ) | \
												  (((uint32)(a) >> 8 ) & 0xff00L ) | ((uint32)(a) >> 24 ))
	
	#define	REVERSEu32( a )	(((uint32)(a) << 24 ) | (((uint32)(a) & 0xff00L ) << 8 ) | \
										(((uint32)(a) >> 8 ) & 0xff00L ) | ((uint32)(a) >> 24 ))
	
#endif

/******************************************************************************/
/*																										*/
/* Die "alten" ACS-Datentypen auf die neuen mappen										*/
/*																										*/
/******************************************************************************/

/* SchlÅsselwort cdecl gibt's nur in Turbo-C bzw. Pure C */
#ifdef __TURBOC__
	#ifndef CDECL
		#define CDECL	cdecl
	#endif
	#ifndef CONST
		#define CONST	const
	#endif
	#ifndef CHAR
		#define CHAR	int8
	#endif
	#ifndef UCHAR
		#define UCHAR	int8
	#endif
	#ifndef VOID
		#define VOID	void
	#endif
	#ifndef INT16
		#define INT16	int16
	#endif
	#ifndef UINT16
		#define UINT16	uint16
	#endif
	#ifndef WCHAR
		#define WCHAR	uint16
	#endif
	#ifndef INT32
		#define INT32	int32
	#endif
	#ifndef UINT32
		#define UINT32 uint32
	#endif
	#ifndef INT64
		#define INT64	int64
	#endif
	#ifndef UINT64
		#define UINT64 uint64
	#endif
#else
	#ifdef LATTICE
		#ifndef CDECL
			#define CDECL			__stdargs
			#define cdecl			CDECL
		#endif
		#ifndef CONST
			#define CONST	const
		#endif
		typedef void				VOID;
		typedef signed char		CHAR;
		typedef unsigned char	UCHAR;
		typedef short				INT16;
		typedef unsigned int		UINT16;
		typedef long				INT32;
		typedef unsigned long	UINT32;
	#else
		#define CDECL
		#define cdecl				CDECL
		#ifndef CONST
			#define CONST	const
		#endif
		typedef void				VOID;
		typedef signed char		CHAR;
		typedef unsigned char	UCHAR;
		typedef short				INT16;
		typedef unsigned short	UINT16;
		typedef long				INT32;
		typedef unsigned long	UINT32;
	#endif
#endif
	
/******************************************************************************/
/*																										*/
/* Die Datentypen des ISO-Standards ISO/IEC 9899:1999 definieren					*/
/*																										*/
/******************************************************************************/

#ifndef __STDINT__
	#define __STDINT__
	
	#define int8_t				int8
	#define int16_t			int16
	#define int32_t			int32
	#define int64_t			int64
	
	#define uint8_t			uint8
	#define uint16_t			uint16
	#define uint32_t			uint32
	#define uint64_t			uint64
	
	#define int_least8_t		int8
	#define int_least16_t	int16
	#define int_least32_t	int32
	#define int_least64_t	int64
	
	#define uint_least8_t	uint8
	#define uint_least16_t	uint16
	#define uint_least32_t	uint32
	#define uint_least64_t	uint64
	
	#define int_fast8_t		int8
	#define int_fast16_t		int16
	#define int_fast32_t		int32
	#define int_fast64_t		int64
	
	#define uint_fast8_t		uint8
	#define uint_fast16_t	uint16
	#define uint_fast32_t	uint32
	#define uint_fast64_t	uint64
	
	typedef int16				*intptr_t;
	typedef uint16				*uintptr_t;
	
	#define intmax_t			int64_t;
	#define uintmax_t			uint64_t;
#endif
	
/******************************************************************************/

/* Die Grenzwerte der Datentypen definieren, falls sie es noch nicht sind */
#ifndef __LIMITS
	#define __LIMITS
	
	#ifdef __PUREC__
		#define CHAR_BIT			8
		#define SCHAR_MIN			(-128)
		#define SCHAR_MAX			127
		#define UCHAR_MAX			255u
		#if( '\x80' < 0 )
			#define  CHAR_MIN		(-128)
			#define  CHAR_MAX		127
		#else
			#define  CHAR_MIN		0
			#define  CHAR_MAX		255
		#endif
		#define MB_LEN_MAX		1
		#define SHRT_MIN			(-32767-1)
		#define SHRT_MAX			32767
		#define USHRT_MAX			65535u
		#define INT_MIN			(-32767-1)
		#define INT_MAX			32767
		#define UINT_MAX			65535u
		#define LONG_MIN			(-2147483647l-1)
		#define LONG_MAX			2147483647l
		#define ULONG_MAX			4294967295lu
		#define LLONG_MIN			-9223372036854775807L
		#define LLONG_MAX			+9223372036854775808L
		#define ULLONG_MAX		18446744073709551615LU
	#else
		#error "Konstanten bislang nur Pure-C-Daten implementiert!"
	#endif
#endif

/******************************************************************************/
/*																										*/
/* Die Datentypen der "klassischen" PORTAB definieren									*/
/*																										*/
/******************************************************************************/

/* Auch die Datentypen von PORTAB deklarieren */
#ifndef __PORTAB__
	#define __PORTAB__
	
	/* "Datentypen" nur definieren, wenn sie nicht existieren */
	#ifndef BYTE
		#define BYTE		int8
	#endif
	#ifndef UBYTE
		#define UBYTE		uint8
	#endif
	#ifndef WORD
		#define WORD		int16
	#endif
	#ifndef UWORD
		#define UWORD		uint16
	#endif
	#ifndef LONG
		#define LONG		int32
	#endif
	#ifndef ULONG
		#define ULONG		uint32
	#endif
	#ifndef BOOLEAN
		#define BOOLEAN	boolean
	#endif
	#ifndef FLOAT
		#define FLOAT		float
	#endif
	#ifndef DOUBLE
		#define DOUBLE		double
	#endif
#endif

/* Auch die Datentypen einer anderen Variante der PORTAB deklarieren */
#ifndef __PORTAB_H__
	#define __PORTAB_H__
	
	/* "Datentypen" nur definieren, wen sie nicht existieren */
	#ifndef _BYTE
		#define _BYTE		int8
	#endif
	#ifndef _UBYTE
		#define _UBYTE		uint8
	#endif
	#ifndef _WORD
		#define __WORD		int16
	#endif
	#ifndef _UWORD
		#define _UWORD		uint16
	#endif
	#ifndef _LONG
		#define _LONG		int32
	#endif
	#ifndef _ULONG
		#define _ULONG		uint32
	#endif
	#ifndef _BOOLEAN
		#define _BOOLEAN	boolean
	#endif
	#ifndef _FLOAT
		#define _FLOAT		float
	#endif
	#ifndef _DOUBLE
		#define _DOUBLE	double
	#endif
#endif

/******************************************************************************/
/*																										*/
/* Ein paar wichtige Konstanten definieren												*/
/*																										*/
/******************************************************************************/

/* Ggf. wird NULL definiert */
#ifndef NULL
	#define NULL ((void *) 0l)
#endif

/* Die boolschen Werte sollten auch verfÅgbar sein */
#ifdef FALSE
	#if FALSE != 0
		#error FALSE bereits anderslautend definiert
	#endif
#else
	#define FALSE	(0)
#endif

#ifdef TRUE
	#if TRUE != 1
		#error TRUE bereits anderslautend definiert
	#endif
#else
	#define TRUE	(1)
#endif

/* RÅckgabewerte von diversen Funktionen */
#ifdef FAIL
	#if FAIL != -1
		#error FAIL bereits anderslautend definiert
	#endif
#else
	#define FAIL	(-1)
#endif

#ifdef OK
	#if OK != 0
		#error OK bereits anderslautend definiert
	#endif
#else
	#define OK	(0)
#endif

/******************************************************************************/
/*																										*/
/* Einige zentrale Datenstrukturen definieren											*/
/*																										*/
/******************************************************************************/

/* Position eines Runktes */
typedef struct
{
	int16 x;
	int16 y;
} Axy;

/* Struktur dafÅr aus GEMLIB */
typedef struct point_coord{	int16 p_x;
	int16 p_y;
} PXY;
/******************************************************************************/

/* Breite und Hîhe eines Rechteckes */
typedef struct
{
	int16 w;
	int16 h;
} Awh;

/******************************************************************************/

/* Beschreibung eines Rechteckes */
typedef struct
{
	int16 x;
	int16 y;
	int16 w;
	int16 h;
} Axywh;

/******************************************************************************/

/* Rechteck fÅr 16-Bit-Koordinaten */
typedef struct
{
	int16	x1;
	int16	y1;
	int16	x2;
	int16	y2;
} RECT16;

/******************************************************************************/

/* Rechteck fÅr 32-Bit-Koordinaten */
typedef struct
{
	int32	x1;
	int32	y1;
	int32	x2;
	int32	y2;
} RECT32;

/******************************************************************************/

/* Beschreibung eines Rechteckes */
typedef struct
{
	int16 g_x;
	int16 g_y;
	int16 g_w;
	int16 g_h;
} GRECT;

/******************************************************************************/

/* Beschreibung einer Rechteck-Liste */
typedef struct _orect
{
	struct _orect *link;
	int16 o_x;
	int16 o_y;
	int16 o_w;
	int16 o_h;
} ORECT;

/******************************************************************************/

/* Farbbeschreibungen */
typedef struct
{
	int16 red;
	int16 green;
	int16 blue;
} RGB1000;

/* AbwÑrts-KompatibilitÑt: bisherigen Namen in den NVDI-Namen umsetzen */
#define RGBColor RGB1000

/******************************************************************************/

/* Schnelle Wandlung int32 <-> 2 x int16 */
typedef union
{
	int32 val32;
	struct
	{
		int16 highWord;
		int16 lowWord;
	} val16;
} ConvInt32To2Int16;

/******************************************************************************/

#endif
