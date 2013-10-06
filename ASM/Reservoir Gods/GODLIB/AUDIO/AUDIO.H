#ifndef	INCLUDED_AUDIO_H
#define	INCLUDED_AUDIO_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>


/* ###################################################################################
#  ENUMS
################################################################################### */

enum
{
	eAUDIO_FREQ_6,
	eAUDIO_FREQ_12,
	eAUDIO_FREQ_25,
	eAUDIO_FREQ_50,

	eAUDIO_FREQ_LIMIT
};


enum
{
	eAUDIO_BITS_8,
	eAUDIO_BITS_16
};


enum
{
	eAUDIO_STEREO,
	eAUDIO_MONO
};


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef struct
{
	U8 *	pSound;
	U32		Length;
	U8		Freq;
	U8		Bits;
	U8		LoopingFlag;
	U8		StereoFlag;
} sAudioDmaSound;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void	Audio_Init( void );
void	Audio_DeInit( void );

void	Audio_SoundChipOff( void );

U16		Audio_GetKeyClickState( void );
void	Audio_SetKeyClickState( const U16 aState );

U16		Audio_GetInternalSpeakerState( void );
void	Audio_SetInternalSpeakerState( const U16 aState );

U8		Audio_GetLeftVolume( void );
U8		Audio_GetRightVolume( void );
void	Audio_SetLeftVolume( const U8 aVol );
void	Audio_SetRightVolume( const U8 aVol );
void	Audio_SetVolume( const U8 aVol );

void	Audio_DmaPlaySound( sAudioDmaSound * apSound );
U8		Audio_DmaIsSoundPlaying( void );
void	Audio_DmaToggleSign( sAudioDmaSound * apSound );
void	Audio_DmaMaximiseUnsignedVol( sAudioDmaSound * apSound );
void	Audio_DmaMaximiseSignedVol( sAudioDmaSound * apSound );
void	Audio_DmaScaleSignedVol( sAudioDmaSound * apSound, const U16 aScale );
void	Audio_DmaScaleUnsignedVol( sAudioDmaSound * apSound, const U16 aScale );

sAudioDmaSound *	Audio_GetpDmaCurrentSound( void );


/* ################################################################################ */

#endif	/*	INCLUDED_AUDIO_H	*/