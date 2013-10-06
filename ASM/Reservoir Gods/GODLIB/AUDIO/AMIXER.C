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

#include	"AMIXER.H"

#include	<GODLIB\AUDIO\AUDIO.H>
#include	<GODLIB\MEMORY\MEMORY.H>
#include	<GODLIB\MFP\MFP.H>
#include	<GODLIB\SYSTEM\SYSTEM.H>
#include	<GODLIB\VBL\VBL.H>


/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dAMIXER_BUFFER_SIZE		(8*1024)
#define	dAMIXER_CHANNEL_LIMIT	2


/* ###################################################################################
#  DATA
################################################################################### */

U16					gAudioMixerDMAHardWareFlag;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

extern	U8 *		gpAudioMixerSilence;
extern	U8 *		gpAudioMixerBuffer;
extern	U8 *		gpAudioMixerMulTable;
extern	U32			gAudioMixerBufferOffset;
extern	U8			gAudioMixerLockFlag;
extern	U8			gAudioMixerEnableFlag;
extern	sAmixerSpl	gAudioMixerSamples[ dAMIXER_CHANNEL_LIMIT ];

extern	void		AudioMixer_Vbl( void );


/* ###################################################################################
#  CODE
################################################################################### */


/*-----------------------------------------------------------------------------------*
* FUNCTION : AudioMixer_Init( void )
* ACTION   : inits mixer
* CREATION : 15.09.01 PNK
*-----------------------------------------------------------------------------------*/

void	AudioMixer_Init( void )
{
	S16		i,j;
	S16		lX,lY;
	S8 *	lpMul;

	switch( System_GetMCH() )
	{
	case	MCH_STE:
	case	MCH_MEGASTE:
	case	MCH_TT:
	case	MCH_FALCON:
		gAudioMixerDMAHardWareFlag = 1;
		break;
	default:
		gAudioMixerDMAHardWareFlag = 0;
		break;
	}

	gpAudioMixerSilence        = (U8*)Memory_ScreenCalloc( 4*1024 );
	gpAudioMixerBuffer         = (U8*)Memory_ScreenCalloc( dAMIXER_BUFFER_SIZE+(2*1024) );
	gpAudioMixerMulTable       = (U8*)Memory_Calloc( 0x10000L );
	gAudioMixerBufferOffset    = (4*1024);
	gAudioMixerLockFlag        = 0;

	lpMul = (S8*)gpAudioMixerMulTable;
	for( i=0; i<256; i++ )
	{
		lX   = i;
		if( i > 128 )
		{
			lX++;
		}
		for( j=0; j<256; j++ )
		{
			lY   = j;
			lY <<= 8;
			lY >>= 8;
			*lpMul++ = (S8)((lX*lY)>>8);
		}
	}

	for( i=0; i<dAMIXER_CHANNEL_LIMIT; i++ )
	{
		gAudioMixerSamples[ i ].ActiveFlag = 0;
		gAudioMixerSamples[ i ].pCurrent   = gpAudioMixerSilence;
		gAudioMixerSamples[ i ].pStart     = gpAudioMixerSilence;
		gAudioMixerSamples[ i ].Length     = 1024;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : AudioMixer_DeInit( void )
* ACTION   : deinits mixer
* CREATION : 15.09.01 PNK
*-----------------------------------------------------------------------------------*/

void	AudioMixer_DeInit( void )
{
	U16	i;

	AudioMixer_Disable();
	for( i=0; i<dAMIXER_CHANNEL_LIMIT; i++ )
	{
		gAudioMixerSamples[ i ].ActiveFlag = 0;
		gAudioMixerSamples[ i ].pCurrent   = gpAudioMixerSilence;
	}
	Memory_Release( gpAudioMixerSilence );
	Memory_Release( gpAudioMixerBuffer  );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : AudioMixer_Enable( void )
* ACTION   : enables mixer
* CREATION : 15.09.01 PNK
*-----------------------------------------------------------------------------------*/

void	AudioMixer_Enable( void )
{
	sAudioDmaSound	lSound;
	U16				i;

	if( gAudioMixerDMAHardWareFlag )
	{
		lSound.Bits        = eAUDIO_BITS_8;
		lSound.Freq        = eAUDIO_FREQ_50;
		lSound.Length      = dAMIXER_BUFFER_SIZE;
		lSound.LoopingFlag = 1;
		lSound.StereoFlag  = 1;
		lSound.pSound      = gpAudioMixerBuffer;


		Vbl_AddCall( AudioMixer_Vbl );
		gAudioMixerBufferOffset    = (4*1024);

		for( i=0; i<dAMIXER_CHANNEL_LIMIT; i++ )
		{
			gAudioMixerSamples[ i ].ActiveFlag = 0;
			gAudioMixerSamples[ i ].pCurrent   = gpAudioMixerSilence;
		}

		gAudioMixerEnableFlag      = 1;
		Vbl_WaitVbl();
		Audio_DmaPlaySound( &lSound );
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : AudioMixer_Disable( void )
* ACTION   : disables mixer
* CREATION : 15.09.01 PNK
*-----------------------------------------------------------------------------------*/

void	AudioMixer_Disable( void )
{
	U8 *	lpCR;
	U8		lOff;

	if( gAudioMixerEnableFlag )
	{
		gAudioMixerEnableFlag = 0;
		lpCR                  = (U8*)0xFFFF8901L;
		lOff                  = *lpCR;
		lOff                 &= 0xFE;
		*lpCR                 = lOff;

		Vbl_RemoveCall( AudioMixer_Vbl );
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : AudioMixer_PlaySample( sAudioDmaSound * apSpl, const U8 aPan )
* ACTION   : adds sample to queue
* CREATION : 15.09.01 PNK
*-----------------------------------------------------------------------------------*/

U8		AudioMixer_PlaySample( sAudioDmaSound * apSpl, const U8 aPan )
{
	sAmixerSpl *	lpMix;
	U16				i;

	for( i=0; i<dAMIXER_CHANNEL_LIMIT; i++ )
	{
		lpMix = &gAudioMixerSamples[ i ];

		if( !lpMix->ActiveFlag )
		{
			lpMix->ActiveFlag = 0;
			lpMix->Length     = apSpl->Length;
			lpMix->pStart     = apSpl->pSound;
			lpMix->pCurrent   = apSpl->pSound;
			lpMix->StereoPos  = aPan;
			lpMix->Volume     = 0xFF;
			lpMix->ActiveFlag = 1;
			return( 1 );
		}
	}
	return( 0 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : AudioMixer_PlaySampleDirect( sAudioDmaSound * apSpl, const U8 aPan )
* ACTION   : plays sample without queueing
* CREATION : 15.09.01 PNK
*-----------------------------------------------------------------------------------*/

U8		AudioMixer_PlaySampleDirect( sAudioDmaSound * apSpl, const U8 aPan )
{
	sAmixerSpl *	lpMix;
	U32				lLeft;
	U32				lBest;
	U16				i;

	lpMix = (sAmixerSpl*)0;
	lBest = 0x7FFFFFFFL;
	
	for( i=0; i<dAMIXER_CHANNEL_LIMIT; i++ )
	{
		if( !gAudioMixerSamples[ i ].ActiveFlag )
		{
			lpMix = &gAudioMixerSamples[ i ];
			lBest = 0;
		}
		else
		{
			lLeft  = (U32)gAudioMixerSamples[i].pStart;
			lLeft += gAudioMixerSamples[i].Length;
			lLeft -= (U32)gAudioMixerSamples[i].pCurrent;

			if( lLeft < lBest )
			{
				lBest = lLeft;
				lpMix = &gAudioMixerSamples[ i ];
			}
		}
	}

	if( lpMix )
	{
		lpMix->ActiveFlag = 0;
		lpMix->Length     = apSpl->Length;
		lpMix->pStart     = apSpl->pSound;
		lpMix->pCurrent   = apSpl->pSound;
		lpMix->StereoPos  = aPan;
		lpMix->Volume     = 0xFF;
		lpMix->ActiveFlag = 1;
	}

	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : AudioMixer_CanPlayNewSpl( void )
* ACTION   : returns true if channels are available to play new sample on
* CREATION : 15.09.01 PNK
*-----------------------------------------------------------------------------------*/

U8		AudioMixer_CanPlayNewSpl( void )
{
	U16	i;

	for( i=0; i<dAMIXER_CHANNEL_LIMIT; i++ )
	{
		if( !gAudioMixerSamples[ i ].ActiveFlag )
		{
			return( 1 );
		}
	}

	return( 0 );
}


/* ################################################################################ */
