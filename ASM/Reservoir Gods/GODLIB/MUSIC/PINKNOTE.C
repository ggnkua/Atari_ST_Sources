/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: SND.C
::
:: SND chip routines
::
:: [c] 2001 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"PINKNOTE.H"

#include	<GODLIB\ASSERT\ASSERT.H>
#include	<GODLIB\MUSIC\SND.H>
#include	<GODLIB\MFP\MFP.H>
#include	<GODLIB\SYSTEM\SYSTEM.H>


/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dPINKNOTE_QUEUE_LIMIT	16


/* ###################################################################################
#  DATA
################################################################################### */


sPinkNoteQueueEntry	gPinkNoteQueue[ dPINKNOTE_CHANNEL_LIMIT][ dPINKNOTE_QUEUE_LIMIT ];
U16					gPinkNoteQueueIndex[ dPINKNOTE_CHANNEL_LIMIT ];
sMfpTimer			gPinkNoteInterruptTimer;

sPinkNote			gPinkNoteSilence[2] =
{
	mPINKNOTE_VOLUME( 0, 0 ), 
	mPINKNOTE_END 
};

extern	sPinkNoteChannel	gPinkNoteChannel[ dPINKNOTE_CHANNEL_LIMIT ];


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void	PinkNote_ChannelInit( U16 aIndex );
void	PinkNote_ChannelDeInit( U16 aIndex );
void	PinkNote_QueueInit( void );

extern	void	PinkNote_Player( void );
extern	void	PinkNote_NotePlayChannelA( sPinkNoteChannel * apChannel );
extern	void	PinkNote_NotePlayChannelB( sPinkNoteChannel * apChannel );
extern	void	PinkNote_NotePlayChannelC( sPinkNoteChannel * apChannel );


/* ###################################################################################
#	CODE
################################################################################### */


/*-----------------------------------------------------------------------------------*
* FUNCTION : PinkNote_Init( void )
* ACTION   : inits pinknote stuffs
* CREATION : 04.02.01 PNK
*-----------------------------------------------------------------------------------*/

void	PinkNote_Init()
{
	U16	i;

	for( i=0; i<dPINKNOTE_CHANNEL_LIMIT; i++ )
	{
		PinkNote_ChannelInit( i );
	}
	PinkNote_QueueInit();


	gPinkNoteInterruptTimer.Data      = 0;
	gPinkNoteInterruptTimer.Freq      = 0;
	gPinkNoteInterruptTimer.Mode      = 0;
	gPinkNoteInterruptTimer.TimerFunc = PinkNote_Player;

	Snd_SetpChaserFunc( PinkNote_Player );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : PinkNote_DeInit( void )
* ACTION   : deinits all pinknote channels
* CREATION : 04.02.01 PNK
*-----------------------------------------------------------------------------------*/

void	PinkNote_DeInit()
{
	U16					i;

	for( i=0; i<dPINKNOTE_CHANNEL_LIMIT; i++ )
	{
		PinkNote_ChannelDeInit( i );
	}

}

/*-----------------------------------------------------------------------------------*
* FUNCTION : PinkNote_ReInit( void )
* ACTION   : reinits all pinknote channels
* CREATION : 04.02.01 PNK
*-----------------------------------------------------------------------------------*/

void	PinkNote_ReInit()
{
	U16	i;

	for( i=0; i<dPINKNOTE_CHANNEL_LIMIT; i++ )
	{
		PinkNote_ChannelDeInit( i );
		PinkNote_ChannelInit( i );
	}
	PinkNote_QueueInit();

}


/*-----------------------------------------------------------------------------------*
* FUNCTION : PinkNote_Update( void )
* ACTION   : plays queued sounds
* CREATION : 04.02.01 PNK
*-----------------------------------------------------------------------------------*/

void	PinkNote_Update( void )
{
	U16	c,q,i,j;

	for( c=0; c<dPINKNOTE_CHANNEL_LIMIT; c++ )
	{
		q = gPinkNoteQueueIndex[ c ];
		i = 0;
		while( (i < dPINKNOTE_QUEUE_LIMIT) && (!gPinkNoteQueue[c][q].ActiveFlag) )
		{
			i++;
			q++;
			if( q >= dPINKNOTE_QUEUE_LIMIT )
				q=0;
		}
		if( i<dPINKNOTE_QUEUE_LIMIT )
		{
			if( (!gPinkNoteChannel[ c ].ActiveFlag) || (gPinkNoteChannel[ c ].LoopingFlag) )
			{
				gPinkNoteChannel[ c ].ActiveFlag  = 0;
				gPinkNoteChannel[ c ].pNotes      = gPinkNoteQueue[ c ][ q ].pNotes;
				gPinkNoteChannel[ c ].Index       = 0;
				gPinkNoteChannel[ c ].LoopingFlag = 0;
				gPinkNoteChannel[ c ].ActiveFlag  = 1;

				gPinkNoteQueue[ c ][ q ].ActiveFlag = 0;
				q++;
				if( q >= dPINKNOTE_QUEUE_LIMIT )
					q = 0;
				gPinkNoteQueueIndex[ c ] = q;
			}
		}
	}

	for( i=0; i<dPINKNOTE_CHANNEL_LIMIT; i++ )
	{
		for( j=0; j<dPINKNOTE_QUEUE_LIMIT; j++ )
		{
			if( gPinkNoteQueue[ i ][ j ].ActiveFlag )
				gPinkNoteQueue[ i ][ j ].ActiveFlag--;
		}
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : PinkNote_QueueInit( void )
* ACTION   : inits note queues on all channels
* CREATION : 04.02.01 PNK
*-----------------------------------------------------------------------------------*/

void	PinkNote_QueueInit( void )
{
	U16	i,j;

	for( i=0; i<dPINKNOTE_CHANNEL_LIMIT; i++ )
	{
		for( j=0; j<dPINKNOTE_CHANNEL_LIMIT; j++ )
		{
			gPinkNoteQueue[ i ][ j ].ActiveFlag = 0;
			gPinkNoteQueue[ i ][ j ].pNotes     = 0;
			gPinkNoteQueue[ i ][ j ].Priority   = 0;
		}
		gPinkNoteQueueIndex[ i ] = 0;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : PinkNote_ChannelInit( U16 aIndex )
* ACTION   : inits a channel
* CREATION : 04.02.01 PNK
*-----------------------------------------------------------------------------------*/

void	PinkNote_ChannelInit( U16 aIndex )
{
	sPinkNoteChannel *	lpChannel;

	lpChannel = &gPinkNoteChannel[ aIndex ];

	lpChannel->ActiveFlag  = 0;
	lpChannel->EnvFreq     = 0;
	lpChannel->EnvType     = 0;
	lpChannel->Index       = 0;
	lpChannel->LoopingFlag = 0;
	lpChannel->NoiseFreq   = 0;
	lpChannel->NoiseTone   = (1<<3)|1;
	lpChannel->Pause       = 0;
	lpChannel->pNotes      = 0;
	lpChannel->ToneFreq    = 0;
	lpChannel->Volume      = 0;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : PinkNote_ChannelDeInit( U16 aIndex )
* ACTION   : deinits a channel
* CREATION : 04.02.01 PNK
*-----------------------------------------------------------------------------------*/

void	PinkNote_ChannelDeInit( U16 aIndex )
{
	sPinkNoteChannel *	lpChannel;

	lpChannel = &gPinkNoteChannel[ aIndex ];
	if( lpChannel->ActiveFlag )
	{
		PinkNote_ChannelInit( aIndex );

		switch( aIndex )
		{
		case	0:
			PinkNote_NotePlayChannelA( lpChannel );
			break;
		case	1:
			PinkNote_NotePlayChannelB( lpChannel );
			break;
		case	2:
			PinkNote_NotePlayChannelC( lpChannel );
			break;
		}
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : PinkNote_ChannelEnable( U16 aIndex )
* ACTION   : enables PinkNote processing on channel aIndex
* CREATION : 04.02.01 PNK
*-----------------------------------------------------------------------------------*/

void	PinkNote_ChannelEnable( U16 aIndex )
{
	gPinkNoteChannel[ aIndex ].ActiveFlag = 1;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : PinkNote_Channel_Disable( U16 aIndex)
* ACTION   : disables PinkNote processing on channel aIndex
* CREATION : 04.02.01 PNK
*-----------------------------------------------------------------------------------*/

void	PinkNote_Channel_Disable( U16 aIndex)
{
	gPinkNoteChannel[ aIndex ].ActiveFlag = 0;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : PinkNote_PlayNote( sPinkNote * apNote, U16 aChannel, U16 aPriority )
* ACTION   : adds note to the queue on channel aChannel
* CREATION : 04.02.01 PNK
*-----------------------------------------------------------------------------------*/

void	PinkNote_PlayNote( sPinkNote * apNote, U16 aChannel, U16 aPriority )
{
	U16	i,j;

	j = gPinkNoteQueueIndex[ aChannel ];
	for( i=0; i<dPINKNOTE_QUEUE_LIMIT; i++ )
	{
		if( (!gPinkNoteQueue[ aChannel ][ j ].ActiveFlag) || (aPriority>gPinkNoteQueue[ aChannel ][ j ].Priority) )
		{
			gPinkNoteQueue[ aChannel ][ j ].ActiveFlag = 1;
			gPinkNoteQueue[ aChannel ][ j ].pNotes     = apNote;
			gPinkNoteQueue[ aChannel ][ j ].Priority   = aPriority;
			return;
		}
		j++;
		if( j >= dPINKNOTE_QUEUE_LIMIT )
		{
			j=0;
		}
	}

}


/* ################################################################################ */
