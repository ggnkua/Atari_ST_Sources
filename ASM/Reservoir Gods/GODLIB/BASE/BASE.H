#ifndef	INCLUDED_BASE_H
#define INCLUDED_BASE_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<STDIO.H>
#include	<STDLIB.H>


/* ###################################################################################
#  TYPEDEFS
################################################################################### */

typedef unsigned char			U8;
typedef signed char				S8;
typedef unsigned int 			U16;
typedef signed int          	S16;
typedef unsigned long           U32;
typedef signed long            	S32;
typedef	float					F32;
typedef float                   FP32;


typedef	union
{
struct { S8 b1,b0; } b;
S16					 w;
} uS16;


typedef	union
{
struct { U8 b1,b0; } b;
struct { U16 w; }	 w;
} uU16;


typedef union
{
struct {S8 b3,b2,b1,b0;} b;
struct {S16 w1,w0;} 	 w;
S32 					 l;
} uS32;


typedef union
{
struct {U8 b3,b2,b1,b0;} b;
struct {U16 w1,w0;} 	 w;
U32						 l;
} uU32;


/* ###################################################################################
#  MACROS
################################################################################### */

#define	mSTRING_TO_U32(a,b,c,d)	( (((U32)a)<<24) | (((U32)b)<<16) | (((U32)c)<<8) | ((U32)d) )


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef struct
{
	U32		ID;
	char *	pString;
} sTagString;

typedef struct
{
	U32		ID;
	U32		Value;
} sTagValue;

/* ###################################################################################
#  PROTOTYPES
################################################################################### */

char *	sTagString_GetpString( const U32 aID, const sTagString * apTagStrings, const U32 aLimit );
U32		sTagString_GetID( const char * apString, const sTagString * apTagStrings, const U32 aLimit );

U32		sTagValue_GetValue( const U32 aID,    const sTagValue * apTagValues, const U32 aLimit );
U32		sTagValue_GetID(    const U32 aValue, const sTagValue * apTagValues, const U32 aLimit );

S16		EndianSwap_S16( U8 * apS16 );
U16		EndianSwap_U16( U8 * apU16 );
S32		EndianSwap_S24( U8 * apS24 );
U32		EndianSwap_U24( U8 * apU24 );
S32		EndianSwap_S32( U8 * apS32 );
U32		EndianSwap_U32( U8 * apU16 );

S32		AsciiToS32( const char * apTxt );


/* ################################################################################ */

#endif	/* INCLUDED_BASE_H */