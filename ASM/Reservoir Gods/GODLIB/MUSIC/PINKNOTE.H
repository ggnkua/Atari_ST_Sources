#ifndef	INCLUDED_PINKNOTE_H
#define	INCLUDED_PINKNOTE_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>

/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dPINKNOTE_CHANNEL_LIMIT	3


/* ###################################################################################
#  ENUMS
################################################################################### */

enum
{
	ePINKNOTE_CONTROL_VOLUME,
	ePINKNOTE_CONTROL_NOISETONE,
	ePINKNOTE_CONTROL_TONEFREQ,
	ePINKNOTE_CONTROL_NOISEFREQ,
	ePINKNOTE_CONTROL_ENVELOPE,

	ePINKNOTE_CONTROL_PAUSE,
	ePINKNOTE_CONTROL_LOOP,
	ePINKNOTE_CONTROL_END
};


/* ###################################################################################
#  MACROS
################################################################################### */

#define	mPINKNOTE_VOLUME( aEnvMode, aVol )				{	ePINKNOTE_CONTROL_VOLUME,		((aEnvMode&1)<<4) | (aVol&15),					0,						0					}
#define	mPINKNOTE_NOISETONE( aNoiseFlag, aToneFlag )	{	ePINKNOTE_CONTROL_NOISETONE,	(((aNoiseFlag^1)&1)<<3) | ((aToneFlag^1)&1),	0,						0					}
#define	mPINKNOTE_TONEFREQ( aToneFreq )					{	ePINKNOTE_CONTROL_TONEFREQ,		0,												((aToneFreq>>8)&0x0F),	(aToneFreq&0xFF)	}
#define	mPINKNOTE_NOISEFREQ( aNoiseFreq )				{	ePINKNOTE_CONTROL_NOISEFREQ,	(aNoiseFreq&0x1F),								0,						0					}
#define	mPINKNOTE_ENVELOPE( aEnvType, aEnvFreq )		{	ePINKNOTE_CONTROL_ENVELOPE,		(aEnvType&0x0F),								((aEnvFreq>>8)&0xFF),	(aEnvFreq&0xFF)		}

#define	mPINKNOTE_PAUSE( aTime )						{	ePINKNOTE_CONTROL_PAUSE,		0,												((aTime>>8)&0xFF),		(aTime&0xFF)		}
#define	mPINKNOTE_LOOP									{	ePINKNOTE_CONTROL_LOOP,			0,												0,						0					}
#define	mPINKNOTE_END									{	ePINKNOTE_CONTROL_END,			0,												0,						0					}


/* ###################################################################################
#  STRUCTS
################################################################################### */


typedef	struct
{
	U8	Control;
	U8	Data0;
	U8	Data1;
	U8	Data2;
} sPinkNote;


typedef	struct
{
	U32			Index;
	sPinkNote *	pNotes;

	S16			Pause;
	U8			ActiveFlag;
	U8			LoopingFlag;

	U16			ToneFreq;
	U16			EnvFreq;

	U8			Volume;
	U8			NoiseTone;
	U8			NoiseFreq;
	U8			EnvType;

} sPinkNoteChannel;


typedef	struct
{
	sPinkNote *	pNotes;
	U16			Priority;
	U16			ActiveFlag;
} sPinkNoteQueueEntry;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void	PinkNote_Init( void );
void	PinkNote_ReInit( void );
void	PinkNote_DeInit( void );
void	PinkNote_Update( void );

void	PinkNote_PlayNote( sPinkNote * apNote, U16 aChannel, U16 aPriority );


/* ################################################################################ */

#endif	/*	INCLUDED_PINKNOTE_H */