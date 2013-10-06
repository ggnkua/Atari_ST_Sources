/*
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: GFX.C
::
:: Routines for manipulating art director GFX images
::
:: [c] 2000 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/

/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dGFX_VERSION	1
#define	dGFX_ID			mSTRING_TO_U32( 'G', 'F', 'X', ' ' )


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"GFX.H"

#include	<GODLIB\MEMORY\MEMORY.H>
#include	<GODLIB\FILE\FILE.H>


/* ###################################################################################
#  FUNCTIONS
################################################################################### */



/*-----------------------------------------------------------------------------------*
* FUNCTION    : Gfx_Create( U16 aWidth, U16 aHeight, U16 aPlaneCount, U32 aLineSize, U16 * apSrc )
* DESCRIPTION : creates a GFX image
* AUTHOR      : 31.12.00 PNK
*-----------------------------------------------------------------------------------*/

sGfx *		Gfx_Create( U16 aWidth, U16 aHeight, U8 aPlaneCount, U32 aLineSize, U16 * apSrc )
{
	U32		lSize;
	U16 *	lpSrc;
	U16 *	lpPixels;
	sGfx *	lpGfx;
	U16		x,y,i;
	U16		lMask;

	lSize  = ((aWidth+15)>>4) << 1;
	lSize *= aPlaneCount + 1;
	lSize *= aHeight;
	lSize += sizeof(sGfxHeader);

	lpGfx = (sGfx*)Memory_Alloc( lSize );

	if( lpGfx )
	{
		lpGfx->Header.Height      = aHeight;
		lpGfx->Header.Width       = aWidth;
		lpGfx->Header.PlaneCount  = aPlaneCount;
		lpGfx->Header.Version     = dGFX_VERSION;
		lpGfx->Header.ID          = dGFX_ID;
		lpGfx->Header.HasMaskFlag = 1;

		lpPixels = &lpGfx->Pixels[ 0 ];

		for( y=0; y<aHeight; y++ )
		{

			lpSrc = &apSrc[ (aLineSize*y)>>1 ];

			for( x=0; x<((aWidth+15)>>4); x++ )
			{
				lMask  = ~lpSrc[ 0 ];
				for( i=1; i<aPlaneCount; i++ )
				{
					lMask &= ~lpSrc[ i ];
				}

				*lpPixels++ = lMask;
				for( i=0; i<aPlaneCount; i++ )
					*lpPixels++ = *lpSrc++;
			
			}
		}
	}

	return( lpGfx );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Gfx_Delete( sGfx * apGfx )
* DESCRIPTION : deletes a GFX image
* AUTHOR      : 31.12.00 PNK
*-----------------------------------------------------------------------------------*/

void		Gfx_Delete( sGfx * apGfx )
{
	Memory_Release( apGfx );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Gfx_Save( sGfx * apGfx, char * apFileName )
* DESCRIPTION : saves a GFX image
* AUTHOR      : 31.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8			Gfx_Save( sGfx * apGfx, char * apFileName )
{
	U32	lSize;

	lSize  = ((apGfx->Header.Width+15)>>4) << 1;
	lSize *= apGfx->Header.PlaneCount + 1;
	lSize *= apGfx->Header.Height;
	lSize += sizeof(sGfxHeader);

	return( File_Save( apFileName, apGfx, lSize ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Gfx_UnMaskInteriorBlack( sGfx * apGfx )
* DESCRIPTION : masks out interior points
* AUTHOR      : 02.01.00 PNK
*-----------------------------------------------------------------------------------*/

void		Gfx_UnMaskInteriorBlack( sGfx * apGfx )
{
	U16		x,y;
	U16 *	lpMask;

	if( apGfx )
	{
		lpMask = apGfx->Pixels;
		for( y=0; y < apGfx->Header.Height; y++ )
		{
			for( x=0; x < ((apGfx->Header.Width+15)>>4); x++ )
			{
				*lpMask &= 0;
				lpMask += (apGfx->Header.PlaneCount+1);
			}
		}
	}
}