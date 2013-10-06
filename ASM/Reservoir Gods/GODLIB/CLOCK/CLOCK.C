/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"CLOCK.H"

#include	<GODLIB\SYSTEM\SYSTEM.H>
#include	<GODLIB\VBL\VBL.H>


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	U8	Result;
	U8	Rem;
} sClockDiv;


/* ###################################################################################
#  DATA
################################################################################### */

sClockDiv	gClockDiv60[ 512 ];
sClockDiv	gClockDiv200[ 512 ];
sTime		gClockTime;
U32			gClockTicks;
U16			gClockSubTicks;
U32			gClockTickAdd;
U16			gClockSubTickAdd;
U8			gClockFrameRate;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void	Clock_Cli_GameSeconds( const char * apArgs );
void	Clock_Cli_Info( const char * apArgs );

extern	void		Clock_TimeVbl( void );


/* ###################################################################################
#  CODE
################################################################################### */


/*-----------------------------------------------------------------------------------*
* FUNCTION : Clock_Init( void )
* ACTION   : Clock_Init
* CREATION : 08.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Clock_Init( void )
{
	uU32	lVal;
	U16		i;

	for( i=0; i<512; i++ )
	{
		gClockDiv60[ i ].Result = i/60;
		gClockDiv60[ i ].Rem    = i%60;

		gClockDiv200[ i ].Result = i/200;
		gClockDiv200[ i ].Rem    = i%200;
	}

	gClockFrameRate     = (U8)System_GetRefreshRate()->w.w1;

	lVal.w.w1           = 200;
	lVal.w.w0           = 0;

	lVal.l             /= System_GetRefreshRate()->w.w1;

	gClockSubTickAdd = lVal.w.w0;
	gClockTickAdd    = (U32)lVal.w.w1;

	gClockTicks      = 0;
	gClockSubTicks   = 0;

	Vbl_AddCall( Clock_TimeVbl );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Clock_DeInit( void )
* ACTION   : Clock_DeInit
* CREATION : 08.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Clock_DeInit( void )
{
	Vbl_RemoveCall( Clock_TimeVbl );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Clock_Update( sClock * apClock )
* ACTION   : Clock_Update
* CREATION : 08.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Clock_Update( sClock * apClock )
{
	if( apClock->State == eCLOCK_STATE_ACTIVE )
	{
		Time_Sub( &gClockTime,                  &apClock->StartTime,   &apClock->ElapsedTime );
		Time_Sub( &apClock->CountDownStartTime, &apClock->ElapsedTime, &apClock->CountDownTime );

		apClock->ElapsedTicks = gClockTicks - apClock->StartTicks;
	}	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Clock_Start( sClock * apClock )
* ACTION   : Clock_Start
* CREATION : 08.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Clock_Start( sClock * apClock )
{
	apClock->State                      = eCLOCK_STATE_ACTIVE;
	apClock->StartTime                  = gClockTime;
	apClock->PauseTime                  = apClock->StartTime;

	apClock->ElapsedTime.Hours          = 0;
	apClock->ElapsedTime.Minutes        = 0;
	apClock->ElapsedTime.Seconds        = 0;
	apClock->ElapsedTime.MicroSeconds   = 0;

	apClock->CountDownTime.Hours        = 0;
	apClock->CountDownTime.Minutes      = 0;
	apClock->CountDownTime.Seconds      = 0;
	apClock->CountDownTime.MicroSeconds = 0;

	apClock->StartTicks                 = gClockTicks;
	apClock->PauseTicks                 = apClock->StartTicks;
	apClock->ElapsedTicks               = 0;	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Clock_Stop( sClock * apClock )
* ACTION   : Clock_Stop
* CREATION : 08.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Clock_Stop( sClock * apClock )
{
	apClock->State = eCLOCK_STATE_INACTIVE;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Clock_Pause( sClock * apClock )
* ACTION   : Clock_Pause
* CREATION : 08.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Clock_Pause( sClock * apClock )
{
	apClock->PauseTime  = gClockTime;
	apClock->State      = eCLOCK_STATE_PAUSE;
	apClock->PauseTicks = gClockTicks;	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Clock_UnPause( sClock * apClock )
* ACTION   : Clock_UnPause
* CREATION : 08.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Clock_UnPause( sClock * apClock )
{
	sTime	lTime;

	Time_Sub( &gClockTime,         &apClock->PauseTime, &lTime             );
	Time_Add( &apClock->StartTime, &lTime,             &apClock->StartTime );
	apClock->StartTicks += (gClockTicks - apClock->PauseTicks);
	apClock->State       = eCLOCK_STATE_ACTIVE;
	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Time_ToU32( sTime * apTime )
* ACTION   : Time_ToU32
* CREATION : 08.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U32	Time_ToU32( sTime * apTime )
{
	U32	lTicks;

	lTicks  = apTime->MicroSeconds;
	lTicks += (U32)apTime->Seconds * 200L;
	lTicks += (U32)apTime->Minutes * 60L * 200L;
	lTicks += (U32)apTime->Hours * 60L * 60L * 200L;

	return( lTicks );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Time_FromU32( sTime * apTime,U32 aTicks )
* ACTION   : Time_FromU32
* CREATION : 08.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Time_FromU32( sTime * apTime,U32 aTicks )
{
	U32	lTicks;

	lTicks           = aTicks / (60L * 60L * 200L);
	apTime->Hours    = (U8)lTicks;
	aTicks          -= lTicks * (60L * 60L * 200L);

	lTicks           = aTicks / (60L * 200L);
	apTime->Minutes  = (U8)lTicks;
	aTicks          -= lTicks * (60L * 200L);

	lTicks           = aTicks / 200L;
	apTime->Seconds  = (U8)lTicks;
	aTicks          -= lTicks * 200L;

	apTime->MicroSeconds = (U8)aTicks;
	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Time_Add( sTime * apSrc0,sTime * apSrc1,sTime * apDst )
* ACTION   : Time_Add
* CREATION : 08.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Time_Add( sTime * apSrc0,sTime * apSrc1,sTime * apDst )
{
	U16	lWord;

	lWord  = apSrc0->MicroSeconds;
	lWord += apSrc1->MicroSeconds;

	apDst->MicroSeconds = gClockDiv200[ lWord ].Rem;

	lWord  = gClockDiv200[ lWord ].Result;
	lWord += apSrc0->Seconds;
	lWord += apSrc1->Seconds;

	apDst->Seconds = gClockDiv60[ lWord ].Rem;

	lWord  = gClockDiv60[ lWord ].Result;
	lWord += apSrc0->Minutes;
	lWord += apSrc1->Minutes;

	apDst->Minutes = gClockDiv60[ lWord ].Rem;

	lWord  = gClockDiv60[ lWord ].Result;
	lWord += apSrc0->Hours;
	lWord += apSrc1->Hours;

	apDst->Hours = gClockDiv60[ lWord ].Rem;
	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Time_Sub( sTime * apSrc0,sTime * apSrc1,sTime * apDst )
* ACTION   : Time_Sub
* CREATION : 08.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Time_Sub( sTime * apSrc0,sTime * apSrc1,sTime * apDst )
{
	S16	lWord;
	S16	lFlow;

	lWord  = apSrc0->MicroSeconds;
	lWord -= apSrc1->MicroSeconds;

	if( lWord < 0 )
	{
		lWord += 200;
		lFlow  = 1;
	}
	else
	{
		lFlow  = 0;
	}

	apDst->MicroSeconds = gClockDiv200[ lWord ].Rem;

	lWord  = apSrc0->Seconds;
	lWord -= apSrc1->Seconds;
	lWord -= lFlow;

	if( lWord < 0 )
	{
		lWord += 60;
		lFlow  = 1;
	}
	else
	{
		lFlow = 0;
	}
	apDst->Seconds = gClockDiv60[ lWord ].Rem;

	lWord  = apSrc0->Minutes;
	lWord -= apSrc1->Minutes;
	lWord -= lFlow;

	if( lWord < 0 )
	{
		lWord += 60;
		lFlow  = 1;
	}
	else
	{
		lFlow = 0;
	}
	apDst->Minutes = gClockDiv60[ lWord ].Rem;

	lWord  = apSrc0->Hours;
	lWord -= apSrc1->Hours;
	lWord -= lFlow;

	apDst->Hours = lWord;
	
}




/* ################################################################################ */
