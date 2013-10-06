/*
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: GOD.C
::
:: Routines for manipulating godpaint GOD images
::
:: [c] 2000 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"GOD.H"

#include	<GODLIB\MEMORY\MEMORY.H>


/* ###################################################################################
#  FUNCTIONS
################################################################################### */

/*-----------------------------------------------------------------------------------*
* FUNCTION    : God_ToCanvas( sGod * apGod )
* DESCRIPTION : converts a godpaint image to a canvas
* AUTHOR      : 28.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvas *		God_ToCanvas( sGod * apGod )
{
	sCanvas *	lpCanvas;

	lpCanvas = Canvas_Create();

	if( !lpCanvas )
		return( 0 );

	Canvas_ImageFrom565( lpCanvas, apGod->Header.Width, apGod->Header.Height, apGod->Pixels );

	return( lpCanvas );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : God_FromCanvas( sCanvas * apCanvas )
* DESCRIPTION : converts to a godpaint file from canvas
* AUTHOR      : 28.12.00 PNK
*-----------------------------------------------------------------------------------*/

sGod *		God_FromCanvas( sCanvas * apCanvas )
{
	sGod *		lpGod;
	U32			lSize;

	lSize   = apCanvas->Width;
	lSize  *= apCanvas->Height;
	lSize <<= 1;
	lSize  += sizeof(sGodHeader);

	lpGod = (sGod*)Memory_Calloc( lSize );

	if( !lpGod )
		return( 0 );

	Canvas_ImageTo565( apCanvas, apCanvas->Width, apCanvas->Height, lpGod->Pixels );

	return( lpGod );
}


