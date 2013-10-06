/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: FADE.C
::
:: Fade routines
::
:: [c] 2000 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"FADE.H"

#include	<GODLIB\VBL\VBL.H>
#include	<GODLIB\VIDEO\VIDEO.H>


/* ###################################################################################
#  VARIABLES
################################################################################### */

U16	gFadeTableFromSTE[ 16 ] =
{
	0x0,
	0x2,
	0x4,
	0x6,
	0x8,
	0xA,
	0xC,
	0xE,
	0x1,
	0x3,
	0x5,
	0x7,
	0x9,
	0xB,
	0xD,
	0xF
};

U16	gFadeTableToSTE[ 16 ] =
{
	0x0,
	0x8,
	0x1,
	0x9,
	0x2,
	0xA,
	0x3,
	0xB,
	0x4,
	0xC,
	0x5,
	0xD,
	0x6,
	0xE,
	0x7,
	0xF
};

U16	gFadeBlackPal[ 16 ] =
{
	0,0,0,0,
	0,0,0,0,
	0,0,0,0,
	0,0,0,0
};

U16	gFadeWhitePal[ 16 ] =
{
	0xFFF,0xFFF,0xFFF,0xFFF,
	0xFFF,0xFFF,0xFFF,0xFFF,
	0xFFF,0xFFF,0xFFF,0xFFF,
	0xFFF,0xFFF,0xFFF,0xFFF
};

U16		gFadeVblOldPal[ 16 ];
U16		gFadeVblTmpPal[ 16 ];

U32		gFadeVblAdd;
U32		gFadeVblScale;
U16 *	gpFadeVblTmpPal;
U16 *	gpFadeVblOldPal;
U16 *	gpFadeVblTargetPal;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

extern	void	Fade_Vbl( void );
extern	U8		gFadeVblActiveFlag;


/* ###################################################################################
#  CODE
################################################################################### */

/*-----------------------------------------------------------------------------------*
* FUNCTION : Fade_Init( void )
* ACTION   : Fade_Init
* CREATION : 07.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Fade_Init( void )
{
	Vbl_AddCall( Fade_Vbl );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Fade_DeInit( void )
* ACTION   : Fade_DeInit
* CREATION : 07.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Fade_DeInit( void )
{
	Vbl_RemoveCall( Fade_Vbl );
}



/*-----------------------------------------------------------------------------------*
* FUNCTION : Fade_PalST( U16 * apDest, U16 * apSrc, U16 * apTarget, U16 aColourCount U16 aPos )
* ACTION   : fades aColourCount colour between pal apSrc and apTarget and stores result in apDest
*			 aPos is in 8.8 fixed point format where 0x0100 = 1.0
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

void	Fade_PalST( U16 * apDest, U16 * apSrc, U16 * apTarget, U16 aColourCount, U16 aPos )
{
	U16	i;
	S16	lR0,lG0,lB0;
	S16	lDiffR,lDiffG,lDiffB;


	for( i=0; i<aColourCount; i++ )
	{
		lDiffR  = ( apTarget[ i ] >> 8) & 7;
		lDiffG  = ( apTarget[ i ] >> 4) & 7;
		lDiffB  = ( apTarget[ i ]     ) & 7;

		lR0     = ( apSrc[ i ] >> 8) & 7;
		lG0     = ( apSrc[ i ] >> 4) & 7;
		lB0     = ( apSrc[ i ]     ) & 7;

		lDiffR -= lR0;
		lDiffG -= lG0;
		lDiffB -= lB0;

		lDiffR *= aPos;
		lDiffG *= aPos;
		lDiffB *= aPos;

		lDiffR >>= 8;
		lDiffG >>= 8;
		lDiffB >>= 8;

		lR0 += lDiffR;
		lG0 += lDiffG;
		lB0 += lDiffB;

		lR0 &=7;
		lG0 &=7;
		lB0 &=7;

		lR0 <<= 8;
		lG0 <<= 4;
		
		apDest[ i ] = lR0 | lG0 | lB0;
	}

}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Fade_PalSTE( U16 * apDest, U16 * apSrc, U16 * apTarget, U16 aColourCount U16 aPos )
* ACTION   : fades aColourCount colour between pal apSrc and apTarget and stores result in apDest
*			 aPos is in 8.8 fixed point format where 0x0100 = 1.0
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

void	Fade_PalSTE( U16 * apDest, U16 * apSrc, U16 * apTarget, U16 aColourCount, U16 aPos )
{
	U16	i;
	S16	lR0,lG0,lB0;
	S16	lDiffR,lDiffG,lDiffB;


	for( i=0; i<aColourCount; i++ )
	{
		lDiffR  = ( apTarget[ i ] >> 8) & 0xF;
		lDiffG  = ( apTarget[ i ] >> 4) & 0xF;
		lDiffB  = ( apTarget[ i ]     ) & 0xF;

		lR0     = ( apSrc[ i ] >> 8) & 0xF;
		lG0     = ( apSrc[ i ] >> 4) & 0xF;
		lB0     = ( apSrc[ i ]     ) & 0xF;

		lDiffR  = gFadeTableFromSTE[ lDiffR ];
		lDiffG  = gFadeTableFromSTE[ lDiffG ];
		lDiffB  = gFadeTableFromSTE[ lDiffB ];

		lR0  = gFadeTableFromSTE[ lR0 ];
		lG0  = gFadeTableFromSTE[ lG0 ];
		lB0  = gFadeTableFromSTE[ lB0 ];

		lDiffR -= lR0;
		lDiffG -= lG0;
		lDiffB -= lB0;

		lDiffR *= aPos;
		lDiffG *= aPos;
		lDiffB *= aPos;

		lDiffR >>= 8;
		lDiffG >>= 8;
		lDiffB >>= 8;

		lR0 += lDiffR;
		lG0 += lDiffG;
		lB0 += lDiffB;

		if( lR0 < 0 )
		{
			lR0 = 0;
		}
		if( lG0 < 0 )
		{
			lG0 = 0;
		}
		if( lB0 < 0 )
		{
			lB0 = 0;
		}
		if( lR0 > 0xF )
		{
			lR0 = 0xF;
		}
		if( lG0 > 0xF )
		{
			lG0 = 0xF;
		}
		if( lB0 > 0xF )
		{
			lB0 = 0xF;
		}


		lR0  = gFadeTableToSTE[ lR0 ];
		lG0  = gFadeTableToSTE[ lG0 ];
		lB0  = gFadeTableToSTE[ lB0 ];

		lR0 <<= 8;
		lG0 <<= 4;
		
		apDest[ i ] = lR0 | lG0 | lB0;
	}

}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Fade_PalFalcon( U32 * apDest, U32 * apSrc, U32 * apTarget, U16 aColourCount U16 aPos )
* ACTION   : fades aColourCount colour between pal apSrc and apTarget and stores result in apDest
*			 aPos is in 8.8 fixed point format where 0x0100 = 1.0
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

void	Fade_PalFalcon( U32 * apDest, U32 * apSrc, U32 * apTarget, U16 aColourCount, U16 aPos )
{
	U16	i;
	S16	lR0,lG0,lB0;
	S16	lDiffR,lDiffG,lDiffB;

	for( i=0; i<aColourCount; i++ )
	{
		lDiffR  = (S16)(( apTarget[ i ] >> 24) & 0xFF );
		lDiffG  = (S16)(( apTarget[ i ] >> 16) & 0xFF );
		lDiffB  = (S16)(( apTarget[ i ]      ) & 0xFF );

		lR0     = (S16)(( apSrc[ i ] >> 24) & 0xFF );
		lG0     = (S16)(( apSrc[ i ] >> 16) & 0xFF );
		lB0     = (S16)(( apSrc[ i ]      ) & 0xFF );

		lDiffR -= lR0;
		lDiffG -= lG0;
		lDiffB -= lB0;

		lDiffR *= aPos;
		lDiffG *= aPos;
		lDiffB *= aPos;

		lDiffR >>= 8;
		lDiffG >>= 8;
		lDiffB >>= 8;

		lR0 += lDiffR;
		lG0 += lDiffG;
		lB0 += lDiffB;

		lR0 &=0xFF;
		lG0 &=0xFF;
		lB0 &=0xFF;

		lR0 <<= 24;
		lG0 <<= 16;
		
		apDest[ i ] = lR0 | lG0 | lB0;
	}

}

/*-----------------------------------------------------------------------------------*
* FUNCTION : Fade_Main( U16 * apPal,U16 aFrames )
* ACTION   : Fade_Main
* CREATION : 07.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Fade_Main( U16 * apPal,U16 aFrames )
{
	U32	lFade;
	U32	lFadeAdd;
	U32	lPos;
	U16	lNewPal[ 16 ];
	U16	lOldPal[ 16 ];
	U16	i;

	Video_GetPalST( lOldPal );

	lFade     = 0;
	lFadeAdd  = 0x1000000L;
	lFadeAdd /= aFrames;

	for( i=0; i<=aFrames; i++ )
	{
		lPos = lFade>>16L;
		if( lPos > 0x100 )
		{
			lPos = 0x100;
		}

		Fade_PalSTE( &lNewPal[0], &lOldPal[0], apPal, 16, (U16)lPos);
		Video_SetNextPalST( lNewPal );
		Vbl_WaitVbl();
		lFade += lFadeAdd;
	}

	Video_SetNextPalST( apPal );
	Vbl_WaitVbl();	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Fade_StartVblFade( U16 * apPal,const U16 aFrames )
* ACTION   : Fade_StartVblFade
* CREATION : 07.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Fade_StartVblFade( U16 * apPal,const U16 aFrames )
{
	gFadeVblActiveFlag = 0;
	Video_GetPalST( &gFadeVblOldPal[ 0 ] );
	gpFadeVblOldPal    = &gFadeVblOldPal[ 0 ];
	gpFadeVblTargetPal = apPal;
	gpFadeVblTmpPal    = &gFadeVblTmpPal[ 0 ];
	gFadeVblScale      = 0;
	gFadeVblAdd        = 0x1000000L;
	gFadeVblAdd       /= aFrames;
	gFadeVblActiveFlag = 1;	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Fade_IsVblFadeFinished( void )
* ACTION   : Fade_IsVblFadeFinished
* CREATION : 07.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U8	Fade_IsVblFadeFinished( void )
{
	return( 0 == gFadeVblActiveFlag );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Fade_GetpBlackPal( void )
* ACTION   : Fade_GetpBlackPal
* CREATION : 07.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U16 *	Fade_GetpBlackPal( void )
{
	return( &gFadeBlackPal[ 0 ] );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Fade_GetpWhitePal( void )
* ACTION   : Fade_GetpWhitePal
* CREATION : 07.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U16 *	Fade_GetpWhitePal( void )
{
	return( &gFadeWhitePal[ 0 ] );	
}



/* ################################################################################ */
