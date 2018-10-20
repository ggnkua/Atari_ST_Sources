/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#ifndef __2B_UNIVERSAL_TYPES__										/* schon vorhanden? */
#define __2B_UNIVERSAL_TYPES__

/*----------------------------------------------------------------------------------------*/
/* Systemumgebung																									*/
/*----------------------------------------------------------------------------------------*/
#define	LITTLE_ENDIAN	0												/* 0: Motorola-Format, 1: Intel-Format */
#define	INTEL	0															/* Intel-CPU */
#define	USE_INLINE	0													/* ggf. Inline-Assembler benutzen */

#define	IS_MACOS		0													/* MacOS */
#define	IS_WINOS		0													/* Windows */
#define	IS_ATARI		1													/* MagiC */

#if ( defined( FALSE ))
	#if ( FALSE != 0 )
		#error	FALSE bereits anderslautend definiert
	#endif
#else
	#define	FALSE	0
#endif

#if ( defined( TRUE ))
	#if ( TRUE != 1 )
		#error	TRUE bereits anderslautend definiert
	#endif
#else
	#define	TRUE	1
#endif

/*----------------------------------------------------------------------------------------*/
/* Standarddatentypen fÅr 8, 16, 32 und 64 Bit															*/
/*----------------------------------------------------------------------------------------*/
typedef signed char		int8;											/* 8 Bit vorzeichenbehaftet */
typedef unsigned char	uint8;										/* 8 Bit vorzeichenlos */

typedef signed short		int16;										/* 16 Bit vorzeichenbehaftet */
typedef unsigned short	uint16;										/* 16 Bit vorzeichenlos */

typedef signed long		int32;										/* 32 Bit vorzeichenbehaftet */
typedef unsigned long	uint32;										/* 32 Bit vorzeichenlos */


#if __MWERKS__ >= 0x0710												/* CodeWarrior 11 mit C-Compiler >= 7.1 ? */

#define	__2B_HAS64_SUPPORT											/* Compiler unterstÅtzt int64/uint64 */
typedef signed long long	int64;									/* 64 Bit vorzeichenbehaftet */
typedef unsigned long long	uint64;									/* 64 Bit vorzeichenlos */

#elif _MSC_VER >= 900													/* MSVC 2.0? */

#define	__2B_HAS64_SUPPORT											/* Compiler unterstÅtzt int64/uint64 */
typedef signed __int64	int64;										/* 64 Bit vorzeichenbehaftet */
typedef unsigned __int64	uint64;									/* 64 Bit vorzeichenlos */

#else																			/* Compiler ohne UnterstÅtzung von 64 Bit Integers */

typedef struct
{
	int32		hi;
	uint32	lo;
} int64;																		/* 64 Bit vorzeichenbehaftet */

typedef struct
{
	uint32	hi;
	uint32	lo;
} uint64;																	/* 64 Bit vorzeichenlos */

#endif

/*----------------------------------------------------------------------------------------*/
/* Diverse Abkîmmlinge																							*/
/*----------------------------------------------------------------------------------------*/
typedef uint8	boolean;													/* aus KompatibilitÑtsgrÅnden - besser int16 oder int32 verwenden */
typedef int32	fixed;													/* 16.16 vorzeichenbehaftet */
typedef int64	fixed64;													/* 32.32 vorzeichenbehaftet */
typedef int32	fixed2p30;												/* 2.30 vorzeichenbehaftet (fÅr Berechnungen im Zahlenbereich von -1.0 bis +1.0) */

/*----------------------------------------------------------------------------------------*/
/* Wandelmakros fÅr Festpunktformate																		*/
/*----------------------------------------------------------------------------------------*/

/* Makros fÅr 16.16 */
#define	int_to_fixed( i )				(((fixed) i ) << 16 )
#define	double_to_fixed( f )			((fixed) ( f * ( 1L << 16 )))

#define	fixed_to_int16( x )			((int16) ( x >> 16 ))
#define	fixed_to_int32( x )			((int32) ( x >> 16 ))
#define	fixed_to_double( x )			(((double) x ) / ( 1L << 16 ))

/* Makros fÅr 32.32 */
#ifdef	__2B_HAS64_SUPPORT											/* nur fÅr Compiler mit UnterstÅtzung von int64 */

#define	int_to_fixed64( i )			(((fixed64) i ) << 32 )
#define	double_to_fixed64( f )		((fixed64) ( f * ( 1L << 32 )))

#define	fixed64_to_int16( x )			((int16) ( x >> 32 ))
#define	fixed64_to_int32( x )			((int32) ( x >> 32 ))
#define	fixed64_to_int64( x )			((int64) ( x >> 32 ))
#define	fixed64_to_double( x )			(((double) x ) / ( 1L << 32 ))

#endif

/* Makros fÅr 2.30 */
#define	int_to_fixed2p30( i )		(((fixed2p30) i ) << 30 )
#define	double_to_fixed2p30( f )	((fixed2p30) ( f * ( 1L << 30 )))

#define	fixed2p30_to_int16( x )		((int16) ( x >> 30 ))
#define	fixed2p30_to_int32( x )		((int32) ( x >> 30 ))
#define	fixed2p30_to_double( x )	(((double) x ) / ( 1L << 30 ))

/*----------------------------------------------------------------------------------------*/
/* Wandelmakros fÅr Little-Endian (Intel)																	*/
/*----------------------------------------------------------------------------------------*/
#define	REVERSE16( a ) 	(int16) (((uint16)(a) >> 8 ) | ((uint16)(a) << 8 ))
#define	REVERSEu16( a )	(((uint16)(a) >> 8 ) | ((uint16)(a) << 8 ))

#define	REVERSE32( a )		(int32) (((uint32)(a) << 24 ) | (((uint32)(a) & 0xff00L ) << 8 ) | \
											  (((uint32)(a) >> 8 ) & 0xff00L ) | ((uint32)(a) >> 24 ))

#define	REVERSEu32( a )	(((uint32)(a) << 24 ) | (((uint32)(a) & 0xff00L ) << 8 ) | \
									(((uint32)(a) >> 8 ) & 0xff00L ) | ((uint32)(a) >> 24 ))

#if INTEL																	/* Intel-CPU? */
#if USE_INLINE																/* Inline-Assembler benutzen? */
#undef	REVERSE16
#undef	REVERSEu16
#undef	REVERSE32
#undef	REVERSEu32

#if 0
	Die untenstehende Inline-Funktionen in Intel-Assembler benutzen die folgenden
	MSVC Eigenschaften:
	
	__declspec( naked ):	Die Funktion enthält nur die angegebenen Befehle - keinen Header.
	__fastcall:				Die Variable wird in ecx und nicht auf dem Stack übergeben.
	
	Integer-Werte werden in eax bzw. ax zurückgeliefert.
#endif

static int16 __fastcall REVERSE16( int16 value );
static uint16 __fastcall REVERSEu16( uint16 value );
static int32 __fastcall REVERSE32( int32 value );
static uint32 __fastcall REVERSEu32( uint32 value );

__declspec( naked ) int16 __fastcall REVERSE16( int16 value )
{
	__asm	ror	cx,8
	__asm	mov	ax,cx
	__asm	ret
}
__declspec( naked ) uint16 __fastcall REVERSEu16( uint16 value )
{
	__asm	ror	cx,8
	__asm	mov	ax,cx
	__asm	ret
}

__declspec( naked ) int32 __fastcall REVERSE32( int32 value )
{
	__asm	bswap	ecx
	__asm	mov	eax,ecx
	__asm	ret
}
__declspec( naked ) uint32 __fastcall REVERSEu32( uint32 value )
{
	__asm	bswap	ecx
	__asm	mov	eax,ecx
	__asm	ret
}

#endif
#endif

/*----------------------------------------------------------------------------------------*/
/* PrÅffunktion																									*/
/*----------------------------------------------------------------------------------------*/
#if ENABLE_2BTYPES_CHECK

extern boolean	are_2Btypes_ok( void );

/*----------------------------------------------------------------------------------------*/
/* Grîûe der Standarddatentypen ÅberprÅfen																*/
/* Funktionsresultat:	FALSE: Grîûenfehler TRUE: alles in Ordnung								*/
/*----------------------------------------------------------------------------------------*/
boolean	are_2Btypes_ok( void )
{
	if ( sizeof( int8 ) != 1 )
		return( FALSE );

	if ( sizeof( uint8 ) != 1 )
		return( FALSE );
	
	if ( sizeof( int16 ) != 2 )
		return( FALSE );

	if ( sizeof( uint16 ) != 2 )
		return( FALSE );

	if ( sizeof( int32 ) != 4 )
		return( FALSE );

	if ( sizeof( uint32 ) != 4 )
		return( FALSE );

	if ( sizeof( int64 ) != 8 )
		return( FALSE );

	if ( sizeof( uint64 ) != 8 )
		return( FALSE );

	return( TRUE );														/* alle Datentypen haben die korrekte LÑnge */
}

#endif
#endif																		/* __2B_UNIVERSAL_TYPES__ */
