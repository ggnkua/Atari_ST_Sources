/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: AUDIO.C
::
:: Low level audio routines
::
:: This file contains all the platform specific audio routines
::
:: [c] 2000 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"AUDIO.H"

#include	<GODLIB\MFP\MFP.H>
#include	<GODLIB\SYSTEM\SYSTEM.H>



/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	U8	KeyClick;
	U8	InternalSpeaker;
} sAudioState;


/* ###################################################################################
#  DATA
################################################################################### */

U16				gAudioDMAHardWareFlag;
sAudioState		gAudioOldState;
sAudioDmaSound	gAudioCurrentSound;
extern	U8		gAudioDmaPlayingFlag;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

extern	void	Audio_MicroWireWrite( const U16 aValue );

extern	void	Audio_ReplayEndInt( void );
extern	void	Audio_SaveYM( void );
extern	void	Audio_RestoreYM( void );
extern	void	Audio_SaveDmaSte( void );
extern	void	Audio_RestoreDmaSte( void );
extern	void	Audio_SaveDmaFalcon( void );
extern	void	Audio_RestoreDmaFalcon( void );


/* ###################################################################################
#  CODE
################################################################################### */


/*-----------------------------------------------------------------------------------*
* FUNCTION : Audio_Init( void )
* ACTION   : inits audio
* CREATION : 23.03.01 PNK
*-----------------------------------------------------------------------------------*/

void	Audio_Init( void )
{
	gAudioDMAHardWareFlag = 0;

	Audio_SaveYM();
	switch( System_GetMCH() )
	{
	case	MCH_STE:
	case	MCH_MEGASTE:
	case	MCH_TT:
		Audio_SaveDmaSte();
		gAudioDMAHardWareFlag = 1;
		break;
	case	MCH_FALCON:
		Audio_SaveDmaFalcon();
		gAudioDMAHardWareFlag = 1;
		break;
	}

	gAudioOldState.KeyClick        = (U8)Audio_GetKeyClickState();
	gAudioOldState.InternalSpeaker = (U8)Audio_GetInternalSpeakerState();

	Audio_SetKeyClickState( 0 );
	Audio_SetInternalSpeakerState( 1 );

	gAudioDmaPlayingFlag   = 0;
	Audio_SoundChipOff();
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Audio_DeInit( void )
* ACTION   : deinits audio
* CREATION : 23.03.01 PNK
*-----------------------------------------------------------------------------------*/

void	Audio_DeInit( void )
{
	Audio_SetKeyClickState( gAudioOldState.KeyClick );
	Audio_SetInternalSpeakerState( gAudioOldState.InternalSpeaker );
	Audio_SoundChipOff();


	switch( System_GetMCH() )
	{
	case	MCH_STE:
	case	MCH_MEGASTE:
	case	MCH_TT:
		Audio_RestoreDmaSte();
		break;
	case	MCH_FALCON:
		Audio_RestoreDmaFalcon();
		break;
	}
	Audio_RestoreYM();
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Audio_GetKeyClickState( void )
* ACTION   : returns keyclick state
* CREATION : 23.03.01 PNK
*-----------------------------------------------------------------------------------*/

U16		Audio_GetKeyClickState( void )
{
	U8 *	lpKC;

	lpKC = (U8*)0x484L;

	return( *lpKC & 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Audio_SetKeyClickState( const U16 aState )
* ACTION   : set keyclick state
* CREATION : 23.03.01 PNK
*-----------------------------------------------------------------------------------*/

void	Audio_SetKeyClickState( const U16 aState )
{
	U8 *	lpKC;

	lpKC = (U8*)0x484L;

	*lpKC &= 0xFE;
	*lpKC |= (aState&1);
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Audio_GetInternalSpeakerState( void )
* ACTION   : returns internal speaker state
* CREATION : 23.03.01 PNK
*-----------------------------------------------------------------------------------*/

U16		Audio_GetInternalSpeakerState( void )
{
	U8 *	lpPSG;

	lpPSG      = (U8*)0xFFFF8800L;
	lpPSG[ 0 ] = 14;

	return( (lpPSG[ 0 ]>>6) & 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Audio_SetInternalSpeakerState( const U16 aState )
* ACTION   : set internal speaker state
* CREATION : 23.03.01 PNK
*-----------------------------------------------------------------------------------*/

void	Audio_SetInternalSpeakerState( const U16 aState )
{
	U8 *	lpPSG;
	U8		lVal;

	lpPSG      = (U8*)0xFFFF8800L;
	lpPSG[ 0 ] = 14;

	lVal  = lpPSG[ 0 ];
	lVal &= 0xBF;
	lVal |= (aState&1)<<6;

	lpPSG[ 2 ] = lVal;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Audio_DmaPlaySound( sAudioDmaSound * apSound )
* ACTION   : plays a sound defined by apSound
* CREATION : 23.03.01 PNK
*-----------------------------------------------------------------------------------*/

void	Audio_DmaPlaySound( sAudioDmaSound * apSound )
{
	U8 *	lpDMAc;
	U8 *	lpMode;
	U8 *	lpStart;
	U8 *	lpEnd;
	U32		lAdr;
	U8		lMode;
	U8		lDMAc;

	if( gAudioDMAHardWareFlag )
	{
		lpDMAc  = (U8*)0xFFFF8901L;
		lpMode  = (U8*)0xFFFF8921L;
		lpStart = (U8*)0xFFFF8903L;
		lpEnd   = (U8*)0xFFFF890FL;

		*lpDMAc &= 0xFE;

		lMode  = (U8)(((apSound->StereoFlag^1)&1)<<7);
		lMode |= (apSound->Bits&1)<<6;
		lMode |= (apSound->Freq&3);

		lDMAc  = (U8)(1 | ((apSound->LoopingFlag&1)<<1));

		lAdr   = (U32)apSound->pSound;

		lpStart[ 0 ] = (U8)((lAdr >> 16L)&0xFF);
		lpStart[ 2 ] = (U8)((lAdr >>  8L)&0xFF);
		lpStart[ 4 ] = (U8)((lAdr       )&0xFF);

		lAdr += apSound->Length;

		lpEnd[ 0 ] = (U8)((lAdr >> 16L)&0xFF);
		lpEnd[ 2 ] = (U8)((lAdr >>  8L)&0xFF);
		lpEnd[ 4 ] = (U8)((lAdr       )&0xFF);

		gAudioDmaPlayingFlag   = 1;

		*lpMode  = lMode;
		*lpDMAc  = lDMAc;
	}

	gAudioCurrentSound     = *apSound;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Audio_DmaIsSoundPlaying( void )
* ACTION   : returns true if sound is playing
* CREATION : 23.03.01 PNK
*-----------------------------------------------------------------------------------*/

U8		Audio_DmaIsSoundPlaying( void )
{
	U8	lDMAc;

	if( gAudioDMAHardWareFlag )
	{
		lDMAc  = *(U8*)0xFFFF8901L;

		if( !(lDMAc & 1) )
		{
			return( 0 );
		}

		lDMAc  = (U8)(*(U8*)0xFFFF890FL - *(U8*)0xFFFF8909L);
		lDMAc |= *(U8*)0xFFFF8911L - *(U8*)0xFFFF890BL;
		lDMAc |= *(U8*)0xFFFF8913L - *(U8*)0xFFFF890DL;
	}
	else
	{
		lDMAc =0;
	}

	return( lDMAc );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Audio_DmaToggleSign( sAudioDmaSound * apSound )
* ACTION   : toggles audio between signed and unsigned
* CREATION : 23.03.01 PNK
*-----------------------------------------------------------------------------------*/

void	Audio_DmaToggleSign( sAudioDmaSound * apSound )
{
	U32	i;
	U8 *	lpSrc;
	U8		lSam;

	lpSrc = apSound->pSound;

	if( lpSrc )
	{
		for( i=0; i<apSound->Length; i++ )
		{
			lSam     = *lpSrc;
			lSam    += 0x80;
			*lpSrc++ = lSam;
		}
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Audio_DmaMaximiseSignedVol( sAudioDmaSound * apSound )
* ACTION   : boosts volume of a sample to maximum level
* CREATION : 23.03.01 PNK
*-----------------------------------------------------------------------------------*/

void	Audio_DmaMaximiseSignedVol( sAudioDmaSound * apSound )
{
	FP32	lScaleF;
	FP32	lMuled;
	S8		lMax,lMin;
	S8		lByte;
	S8 *	lpSam;
	U32		i;

	lMax = (S8)0x81;
	lMin = (S8)0x7F;

	lpSam = (S8*)apSound->pSound;
	for( i=0; i<apSound->Length; i++ )
	{
		lByte = *lpSam++;

		if( lByte < lMin )
		{
			lMin = lByte;
		}
		if( lByte > lMax )
		{
			lMax = lByte;
		}
	}

	if( (U8)lMin == (U8)0x80 )
	{
		lMin = (S8)0x81;
	}

	lMin = -lMin;
	if( lMin > lMax )
	{
		lMax = lMin;
	}

	if( lMax < 0x7F )
	{
		lScaleF  = 127.f;
		lScaleF /= (FP32)lMax;

		lpSam = (S8*)apSound->pSound;
		for( i=0; i<apSound->Length; i++ )
		{
			lByte    = *lpSam;
			lMuled   = (FP32)lByte;
			lMuled  *= lScaleF;
			lByte    = (S8)lMuled;
			*lpSam++ = lByte;
		}
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Audio_DmaScaleSignedVol( sAudioDmaSound * apSound,const U16 aScale )
* ACTION   : Audio_DmaScaleSignedVol
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Audio_DmaScaleSignedVol( sAudioDmaSound * apSound,const U16 aScale )
{
	S16		lVol;
	S8 *	lpByte;
	U32		i;

	lpByte = (S8*)apSound->pSound;
	for( i=0; i<apSound->Length; i++ )
	{
		lVol   = *lpByte;
		lVol <<= 8;
		lVol >>= 8;
		lVol *=  aScale;

		lVol >>= 8;

		*lpByte = (S8)lVol;

		lpByte++;
	}

}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Audio_DmaScaleUnsignedVol( sAudioDmaSound * apSound,const U16 aScale )
* ACTION   : Audio_DmaScaleUnsignedVol
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Audio_DmaScaleUnsignedVol( sAudioDmaSound * apSound,const U16 aScale )
{
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Audio_GetpDmaCurrentSound( void )
* ACTION   : returns pointer to current sound
* CREATION : 23.03.01 PNK
*-----------------------------------------------------------------------------------*/

sAudioDmaSound *	Audio_GetpDmaCurrentSound( void )
{
	return( &gAudioCurrentSound );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Audio_GetLeftVolume( void )
* ACTION   : Audio_GetLeftVolume
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U8	Audio_GetLeftVolume( void )
{
	U8	lVol;

	lVol = 0;

	switch( System_GetMCH() )
	{
	case	MCH_STE:
	case	MCH_MEGASTE:
	case	MCH_TT:
		lVol   = 0xF;
		lVol  *= (255/15);
		break;

	case	MCH_FALCON:
		lVol   = *(U8*)0xFFFF8939L;
		lVol >>= 4;
		lVol  &= 0xF;
		lVol  *= (255/15);
		break;
	}

	return( lVol );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Audio_GetRightVolume( void )
* ACTION   : Audio_GetRightVolume
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U8	Audio_GetRightVolume( void )
{
	U8	lVol;

	lVol = 0;

	switch( System_GetMCH() )
	{
	case	MCH_STE:
	case	MCH_MEGASTE:
	case	MCH_TT:
		lVol = 0xF;
		lVol  *= (255/15);
		break;

	case	MCH_FALCON:
		lVol  = *(U8*)0xFFFF8939L;
		lVol &= 0xF;
		lVol  *= (255/15);
		break;
	}

	return( lVol );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Audio_SetLeftVolume( const U8 aVol )
* ACTION   : Audio_SetLeftVolume
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Audio_SetLeftVolume( const U8 aVol )
{
	U16	lVal;
	U16	lNewVol;
	U8	lVol;


	switch( System_GetMCH() )
	{
	case	MCH_STE:
	case	MCH_MEGASTE:
	case	MCH_TT:
		lNewVol  = aVol;
		lNewVol *= 20;
		lNewVol /= 255;

		lVal  = 0x540;
		lVal |= lNewVol;
		Audio_MicroWireWrite( lVal );
		break;

	case	MCH_FALCON:
		lNewVol  = aVol;
		lNewVol *= 15;
		lNewVol /= 255;
		lNewVol  = 15-lNewVol;

		lVol  = *(U8*)0xFFFF893AL;
		lVol &= 0xF;
		lVol |= ((lNewVol&0xF)<<4);
		*(U8*)0xFFFF893AL = lVol;
		*(U8*)0xFFFF893BL = lVol;
		break;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Audio_SetRightVolume( const U8 aVol )
* ACTION   : Audio_SetRightVolume
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Audio_SetRightVolume( const U8 aVol )
{
	U16	lVal;
	U16	lNewVol;
	U8	lVol;

	switch( System_GetMCH() )
	{
	case	MCH_STE:
	case	MCH_MEGASTE:
	case	MCH_TT:
		lNewVol  = aVol;
		lNewVol *= 20;
		lNewVol /= 255;


		lVal  = 0x500;
		lVal |= lNewVol;
		Audio_MicroWireWrite( lVal );
		break;

	case	MCH_FALCON:
		lNewVol  = aVol;
		lNewVol *= 15;
		lNewVol /= 255;
		lNewVol  = 15-lNewVol;

		lVol  = *(U8*)0xFFFF893AL;
		lVol &= 0xF0;
		lVol |= (lNewVol&0xF);
		*(U8*)0xFFFF893AL = lVol;
		*(U8*)0xFFFF893BL = lVol;
		break;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Audio_SetVolume( const U8 aVol )
* ACTION   : Audio_SetVolume
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Audio_SetVolume( const U8 aVol )
{
	Audio_SetLeftVolume( aVol );
	Audio_SetRightVolume( aVol );
}


/* ################################################################################ */
