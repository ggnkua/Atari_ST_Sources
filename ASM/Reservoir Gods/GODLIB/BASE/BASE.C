/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: BASE.C
::
:: common routines
::
:: [c] 2000 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"BASE.H"


/* ###################################################################################
#  CODE
################################################################################### */

/*-----------------------------------------------------------------------------------*
* FUNCTION    : sTagString_GetString( const S32 aID, const sTagString * apTagStrings, const U32 aLimit )
* DESCRIPTION : returns the sTagString string from an id. 
* AUTHOR      : 09.01.00 PNK
*-----------------------------------------------------------------------------------*/

char *	sTagString_GetpString( const U32 aID, const sTagString * apTagStrings, const U32 aLimit )
{
	const sTagString *	lpTagString;
	U32				i;


	lpTagString = apTagStrings;

	for( i=0; i<aLimit; i++ )
	{
		if( lpTagString->ID == aID )
		{
			return( lpTagString->pString );
		}
		lpTagString++;
			
	}

	return( 0 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : sTagString_GetString( const S32 aID, const sTagString * apTagStrings, const U32 aLimit )
* DESCRIPTION : returns the id from a sTagString
* AUTHOR      : 09.01.00 PNK
*-----------------------------------------------------------------------------------*/

U32		sTagString_GetID( const char * apString, const sTagString * apTagStrings, const U32 aLimit )
{
	const	sTagString *	lpTagString;
	U32				i,j;


	lpTagString = apTagStrings;

	for( i=0; i<aLimit; i++ )
	{
		j = 0;

		while( (lpTagString->pString[j]) && (apString[j]) && (lpTagString->pString[j]==apString[j]) )
		{
			j++;
		}

		if( !(lpTagString->pString[j] | apString[j]) )
		{
			return( lpTagString->ID );
		}

		lpTagString++;			
	}

	return( 0 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : sTagValue_GetValue( const U32 aID, const sTagValue * apTagStrings, const U32 aLimit )
* DESCRIPTION : returns the value string from an id. 
* AUTHOR      : 09.01.00 PNK
*-----------------------------------------------------------------------------------*/

U32		sTagValue_GetValue( const U32 aID, const sTagValue * apTagValues, const U32 aLimit )
{
	const	sTagValue *	lpTagValue;
	U32			i;


	lpTagValue = apTagValues;

	for( i=0; i<aLimit; i++ )
	{
		if( lpTagValue->ID == aID )
		{
			return( lpTagValue->Value );
		}
		lpTagValue++;
	}

	return( 0 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : sTagValue_GetID( const U32 aValue, const sTagValue * apTagValues, const U32 aLimit )
* DESCRIPTION : returns the id from a sTagValue
* AUTHOR      : 09.01.00 PNK
*-----------------------------------------------------------------------------------*/

U32		sTagValue_GetID( const U32 aValue, const sTagValue * apTagValues, const U32 aLimit )
{
	const	sTagValue *	lpTagValue;
	U32			i;


	lpTagValue = apTagValues;

	for( i=0; i<aLimit; i++ )
	{
		if( lpTagValue->Value == aValue )
		{
			return( lpTagValue->ID );
		}

		lpTagValue++;			
	}

	return( 0 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : EndianSwap_S16( U8 * apS16 )
* DESCRIPTION : swaps endianess of S16 pointed to by apS16
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

S16		EndianSwap_S16( U8 * apS16 )
{
	S16	lWord;

	lWord   = apS16[ 1 ];
	lWord <<= 8;
	lWord  |= (apS16[ 0 ] & 0xFF);

	return( lWord );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : EndianSwap_U16( U8 * apU16 )
* DESCRIPTION : swaps endianess of S16 pointed to by apS16
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

U16		EndianSwap_U16( U8 * apU16 )
{
	U16	lWord;

	lWord   = apU16[ 1 ];
	lWord <<= 8;
	lWord  |= (apU16[ 0 ] & 0xFF);

	return( lWord );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : EndianSwap_S32( U8 * apS24 )
* DESCRIPTION : swaps endianess of S24 pointed to by apS24
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

S32		EndianSwap_S24( U8 * apS24 )
{
	S32	lLong;

	lLong   = (apS24[ 2 ] & 0xFF);
	lLong <<= 16;
	lLong >>= 8;
	lLong   = (apS24[ 1 ] & 0xFF);
	lLong <<= 8;
	lLong  |= (apS24[ 0 ] & 0xFF);

	return( lLong );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : EndianSwap_S32( U8 * apU24 )
* DESCRIPTION : swaps endianess of U24 pointed to by apU24
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

U32		EndianSwap_U24( U8 * apU24 )
{
	U32	lLong;

	lLong   = (apU24[ 2 ] & 0xFF);
	lLong <<= 8;
	lLong   = (apU24[ 1 ] & 0xFF);
	lLong <<= 8;
	lLong  |= (apU24[ 0 ] & 0xFF);

	return( lLong );
}

/*-----------------------------------------------------------------------------------*
* FUNCTION    : EndianSwap_S32( U8 * apS32 )
* DESCRIPTION : swaps endianess of S16 pointed to by apS16
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

S32		EndianSwap_S32( U8 * apS32 )
{
	S32	lLong;

	lLong   = apS32[ 3 ];
	lLong <<= 8;
	lLong   = (apS32[ 2 ] & 0xFF);
	lLong <<= 8;
	lLong   = (apS32[ 1 ] & 0xFF);
	lLong <<= 8;
	lLong  |= (apS32[ 0 ] & 0xFF);

	return( lLong );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : EndianSwap_U32( U8 * apU16 )
* DESCRIPTION : swaps endianess of S16 pointed to by apS16
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

U32		EndianSwap_U32( U8 * apU16 )
{
	U32	lLong;

	lLong   = apU16[ 3 ];
	lLong <<= 8;
	lLong   = (apU16[ 2 ] & 0xFF);
	lLong <<= 8;
	lLong   = (apU16[ 1 ] & 0xFF);
	lLong <<= 8;
	lLong  |= (apU16[ 0 ] & 0xFF);

	return( lLong );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : AsciiToS32( const char * apTxt )
* ACTION   : AsciiToS32
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	AsciiToS32( const char * apTxt )
{
	S32	lVal;
	S32	lSign;
	U8	lMode;

	while( *apTxt == ' ' )
	{
		apTxt++;
	}

	if( *apTxt == '-' )
	{
		lSign = -1;
		apTxt++;
	}
	else
	{
		lSign = 1;
	}

	lMode = 0;
	if( *apTxt == '$' )
	{
		lMode = 1;
		apTxt++;
	}
	if( apTxt[ 1 ] == 'x' )
	{
		lMode = 1;
		apTxt += 2;
	}

	lVal = 0;
	if( lMode )
	{
		while( 
				( (*apTxt >= '0') && (*apTxt <= '9') )
			||	( (*apTxt >= 'a') && (*apTxt <= 'f') )
			||	( (*apTxt >= 'A') && (*apTxt <= 'F') )
			)
		{
			lVal *= 16L;
			if( (*apTxt >= '0') && (*apTxt <= '9') )
			{
				lVal += *apTxt - '0';
			}
			else if( (*apTxt >= 'a') && (*apTxt <= 'f') )
			{
				lVal += (*apTxt - 'a')+10;
			}
			else if( (*apTxt >= 'A') && (*apTxt <= 'F') )
			{
				lVal += (*apTxt - 'A')+10;
			}
			apTxt++;
		}
	}
	else
	{
		while( (*apTxt >= '0') && (*apTxt <= '9') )
		{
			lVal *= 10L;
			lVal += *apTxt - '0';
			apTxt++;
		}
	}

	lVal *= lSign;
	return( lVal );
}
