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

#include	"SND.H"

#include	<GODLIB\ASSERT\ASSERT.H>
#include	<GODLIB\MFP\MFP.H>
#include	<GODLIB\SYSTEM\SYSTEM.H>


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

char *	Snd_GetpFromLong( sSndHeader * apHeader, char * apID );
char *	Snd_GetpFromWord( sSndHeader * apHeader, char * apID );
void	Snd_GetTimerInfo( sSndTimer * apTimer, char * apTxt );
void	Snd_CallFunction( void (*aFunc)() );
void	Snd_Player( void );


/* ###################################################################################
#  CODE
################################################################################### */


/*-----------------------------------------------------------------------------------*
* FUNCTION : Snd_Init( void )
* ACTION   : inits mfp
* CREATION : 24.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	Snd_Init()
{
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Snd_DeInit( void )
* ACTION   : deinits mfp
* CREATION : 24.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	Snd_DeInit()
{
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Snd_GetInfo( sSndHeader * apHeader, sSndInfo * apInfo )
* ACTION   : fills in info block structure
* CREATION : 24.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	Snd_GetInfo( sSndHeader * apHeader, sSndInfo * apInfo )
{
	char *	lpTxt;

	Assert( apHeader );

	apInfo->Start = (void(*)(void))&apHeader->Start;
	apInfo->Stop  = (void(*)(void))&apHeader->Stop;
	apInfo->Play  = (void(*)(void))&apHeader->Play;

	apInfo->pComposerTxt   = Snd_GetpFromLong( apHeader, "COMM" );
	apInfo->pConversionTxt = Snd_GetpFromLong( apHeader, "CONV" );
	apInfo->pRipperTxt     = Snd_GetpFromLong( apHeader, "RIPP" );
	apInfo->pTitleTxt      = Snd_GetpFromLong( apHeader, "TITL" );

	if( lpTxt = Snd_GetpFromWord( apHeader, "TA" ) )
	{
		apInfo->Timer.Type = eSND_TIMER_A;
		Snd_GetTimerInfo( &apInfo->Timer, lpTxt );
	}
	else if( lpTxt = Snd_GetpFromWord( apHeader, "TB" ) )
	{
		apInfo->Timer.Type = eSND_TIMER_B;
		Snd_GetTimerInfo( &apInfo->Timer, lpTxt );		
	}
	else if( lpTxt = Snd_GetpFromWord( apHeader, "TC" ) )
	{
		apInfo->Timer.Type = eSND_TIMER_C;
		Snd_GetTimerInfo( &apInfo->Timer, lpTxt );		
	}
	else if( lpTxt = Snd_GetpFromWord( apHeader, "TD" ) )
	{
		apInfo->Timer.Type = eSND_TIMER_D;
		Snd_GetTimerInfo( &apInfo->Timer, lpTxt );		
	}
	else if( lpTxt = Snd_GetpFromWord( apHeader, "V!" ) )
	{
		apInfo->Timer.Type = eSND_TIMER_VBI;
		apInfo->Timer.Freq = 50;
	}
	else
	{
		apInfo->Timer.Type = eSND_TIMER_C;
		apInfo->Timer.Data = 246;
		apInfo->Timer.Div  = 7;
		apInfo->Timer.Freq = 50;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Snd_GetpFromLong( sSndHeader * apHeader, char * apID )
* ACTION   : returns pointer to ascii parameter for field apID
* CREATION : 24.01.01 PNK
*-----------------------------------------------------------------------------------*/

char *	Snd_GetpFromLong( sSndHeader * apHeader, char * apID )
{
	U16		i;

	for( i=0; i<apHeader->Start.Offset; i++ )
	{
		if( 
				( apHeader->Data[ i   ] == apID[ 0 ] )
			&&	( apHeader->Data[ i+1 ] == apID[ 1 ] )
			&&	( apHeader->Data[ i+2 ] == apID[ 2 ] )
			&&	( apHeader->Data[ i+3 ] == apID[ 3 ] )
			)
		{
			return( &apHeader->Data[ i+4 ] );
		}
	}
	return( 0 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Snd_GetpFromWord( sSndHeader * apHeader, char * apID )
* ACTION   : returns pointer to ascii parameter for field apID
* CREATION : 24.01.01 PNK
*-----------------------------------------------------------------------------------*/

char *	Snd_GetpFromWord( sSndHeader * apHeader, char * apID )
{
	U16		i;

	for( i=0; i<apHeader->Start.Offset; i++ )
	{
		if( 
				( apHeader->Data[ i   ] == apID[ 0 ] )
			&&	( apHeader->Data[ i+1 ] == apID[ 1 ] )
			)
		{
			return( &apHeader->Data[ i+2 ] );
		}
	}

	return( 0 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Snd_AsciiToValue( char * apTxt )
* ACTION   : reads ascii decimal number and returns U32 containing value
* CREATION : 24.01.01 PNK
*-----------------------------------------------------------------------------------*/

U32		Snd_AsciiToValue( char * apTxt )
{
	U32	lValue;

	lValue = 0;

	while( *apTxt )
	{
		lValue *= 10;
		lValue += *apTxt++ - '0';
	}

	return( lValue );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Snd_GetTimerInfo( sSndTimer * apTimer, char * apTxt )
* ACTION   : reads timer info from SND header tag
* CREATION : 24.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	Snd_GetTimerInfo( sSndTimer * apTimer, char * apTxt )
{
	U32	lHz;
	U32	lData;

	lHz    = Snd_AsciiToValue( apTxt );
	lData  = 12288L;
	lData /= lHz;
	lData &= 0xFFFFL;

	apTimer->Data = (U8)lData;
	apTimer->Div  = 7;
	apTimer->Freq = lHz;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Snd_TuneInit( sSndInfo * apInfo )
* ACTION   : starts playing tune
* CREATION : 24.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	Snd_TuneInit( sSndInfo * apInfo )
{
	sMfpTimer	lTimer;

	if( apInfo )
	{
		lTimer.Data = apInfo->Timer.Data;
		lTimer.Freq = apInfo->Timer.Freq;
		lTimer.Mode = apInfo->Timer.Div;
		lTimer.TimerFunc = Snd_Player;

		Snd_SetpPlayFunc( apInfo->Play );

		Snd_CallFunction( apInfo->Start );
		Mfp_HookIntoTimerC( &lTimer );
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Snd_TuneDeInit( sSndInfo * apInfo )
* ACTION   : stops playing tune
* CREATION : 24.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	Snd_TuneDeInit( sSndInfo * apInfo )
{
	if( apInfo )
	{
		Mfp_HookDisableTimerC();	
		Snd_CallFunction( apInfo->Stop );
	}
}


/* ################################################################################ */
