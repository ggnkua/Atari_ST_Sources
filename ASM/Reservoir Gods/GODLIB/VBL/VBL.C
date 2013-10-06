/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: VBL.C
::
:: VBL routine handlers
::
:: [c] 2000 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"VBL.H"

#include	<GODLIB\DEBUG\DEBUG.H>
#include	<GODLIB\DEBUGLOG\DEBUGLOG.H>
#include	<GODLIB\SYSTEM\SYSTEM.H>


/* ###################################################################################
#  VARIABLES
################################################################################### */

void	(*gVblOldHandler)();
sVBL	gVbl;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

extern	void	(*Vbl_GetHandler( void ) ) ();
extern	void	Vbl_SetHandler( void (*apHandler)() );

extern	void	Vbl_DummyFunc( void );
extern	void	Vbl_Handler( void );


/* ###################################################################################
#  CODE
################################################################################### */


/*-----------------------------------------------------------------------------------*
* FUNCTION : Vbl_Init( void )
* ACTION   : saves old vbl handler / sets machine specific handler
* CREATION : 25.03.00 PNK
*-----------------------------------------------------------------------------------*/

void	Vbl_Init()
{
	gVblOldHandler   = Vbl_GetHandler();
	gVbl.LockFlag    = 0;
	gVbl.CallCount   = 0;
	gVbl.pTimerBFunc = 0;

	gVbl.pVideoFunc  = Vbl_DummyFunc;

	Vbl_SetHandler( Vbl_Handler );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Vbl_DeInit( void )
* ACTION   : restores old vbl handler
* CREATION : 25.03.00 PNK
*-----------------------------------------------------------------------------------*/

void	Vbl_DeInit()
{
	Vbl_SetHandler( gVblOldHandler );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Vbl_AddCall( void (*apCall)() )
* ACTION   : installs a FUNCTION to be called every vbl
* CREATION : 25.03.00 PNK
*-----------------------------------------------------------------------------------*/

U8		Vbl_AddCall( void (*apCall)() )
{
	if( gVbl.CallCount >= dVBL_MAX_CALLS )	
	{
		DebugLog_Printf0( "Vbl_AddCall() : error too many vbl queue functions\n" );
		return( 0 );
	}

	gVbl.pCalls[ gVbl.CallCount ] = apCall;
	gVbl.CallCount++;

	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Vbl_RemoveCall( void (*apCall)() )
* ACTION   : removes a FUNCTION on vbl list
* CREATION : 25.03.00 PNK
*-----------------------------------------------------------------------------------*/

U8		Vbl_RemoveCall( void (*apCall)() )
{
	U16	i;

	i = 0;
	while( (i < gVbl.CallCount) && (gVbl.pCalls[i] != apCall) )
	{
		i++;
	}

	if( i < gVbl.CallCount )
	{
		gVbl.CallCount--;
		for( ; i<gVbl.CallCount; i++ )
		{
			gVbl.pCalls[ i ] = gVbl.pCalls[ i+ 1 ];
		}
		return( 1 );
	}

	return( 0 );
}

/*-----------------------------------------------------------------------------------*
* FUNCTION : Vbl_InstallTimerB( sMfpTimer * apTimer )
* ACTION   : Vbl_InstallTimerB
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Vbl_InstallTimerB( sMfpTimer * apTimer )
{
	*(U8*)0xFFFFFA1BL    = 0;
	Mfp_InstallTimerB( apTimer );

	gVbl.TimerBScanLine = apTimer->Data;
	gVbl.pTimerBFunc    = apTimer->TimerFunc;

}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Vbl_InstallHbi( sMfpTimer * apTimer )
* ACTION   : Vbl_InstallHbi
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Vbl_InstallHbi( sMfpTimer * apTimer )
{
	gVbl.HbiCounterStart = apTimer->Data;
	gVbl.pHbi            = apTimer->TimerFunc;
	System_SetIML( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Vbl_GetpVbl( void )
* ACTION   : Vbl_GetpVbl
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

sVBL *	Vbl_GetpVbl( void )
{
	return( &gVbl );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Vbl_WaitVbls( const U16 aCount )
* ACTION   : Vbl_WaitVbls
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Vbl_WaitVbls( const U16 aCount )
{
	U16	i;

	for( i=0; i<aCount; i++ )
	{
		Vbl_WaitVbl();
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Vbl_SetVideoFunc( void (* apFunc)() )
* ACTION   : Vbl_SetVideoFunc
* CREATION : 02.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Vbl_SetVideoFunc( void (* apFunc)() )
{
	gVbl.pVideoFunc = apFunc;	
}


/* ################################################################################ */
