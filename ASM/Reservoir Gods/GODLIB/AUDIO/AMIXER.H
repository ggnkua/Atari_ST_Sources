#ifndef	INCLUDED_AMIXER_H
#define	INCLUDED_AMIXER_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>

#include	<GODLIB\AUDIO\AUDIO.H>


/* ###################################################################################
#  ENUMS
################################################################################### */



/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	void *	pStart;
	void *	pCurrent;
	U32		Length;
	U8		Type;
	U8		Volume;
	U8		StereoPos;
	U8		ActiveFlag;
} sAmixerSpl;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void	AudioMixer_Init( void );
void	AudioMixer_DeInit( void );

void	AudioMixer_Enable( void );
void	AudioMixer_Disable( void );

U8		AudioMixer_CanPlayNewSpl( void );
U8		AudioMixer_PlaySample( sAudioDmaSound * apSpl, const U8 aPan );
U8		AudioMixer_PlaySampleDirect( sAudioDmaSound * apSpl, const U8 aPan );


/* ################################################################################ */

#endif	/*	INCLUDED_AMIXER_H	*/