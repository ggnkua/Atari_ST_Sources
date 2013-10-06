/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: SCRNGRAB.C
::
:: Screengrabbing routines
::
:: [c] 2001 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"SCRNGRAB.H"

#include	<STRING.H>

#include	<GODLIB\FILE\FILE.H>
#include	<GODLIB\IKBD\IKBD.H>
#include	<GODLIB\MEMORY\MEMORY.H>
#include	<GODLIB\PICTYPES\DEGAS.H>
#include	<GODLIB\PROGRAM\PROGRAM.H>
#include	<GODLIB\SYSTEM\SYSTEM.H>
#include	<GODLIB\VBL\VBL.H>
#include	<GODLIB\VIDEO\VIDEO.H>


/* ###################################################################################
#  DATA
################################################################################### */

U8		gScreenGrabEnableFlag;
U8		gScreenGrabKeyIndex;
U8		gScreenGrabKeyState;
U16		gScreenGrabIndex;
char	gScreenGrabDirectory[ 256 ];

/* ###################################################################################
#  PROTOTYPES
################################################################################### */

extern	void	ScreenGrab_Vbl( void );


/* ###################################################################################
#  CODE
################################################################################### */


/*-----------------------------------------------------------------------------------*
* FUNCTION : ScreenGrab_Init( void )
* ACTION   : initialisation
* CREATION : 13.09.01 PNK
*-----------------------------------------------------------------------------------*/

void	ScreenGrab_Init( void )
{
	gScreenGrabEnableFlag     = 0;
	gScreenGrabIndex          = 0;
	gScreenGrabKeyState       = 0;
	gScreenGrabKeyIndex       = eIKBDSCAN_F8;
	gScreenGrabDirectory[ 0 ] = 0;

	Vbl_AddCall( ScreenGrab_Vbl );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : ScreenGrab_DeInit( void )
* ACTION   : deinit - removes screengrab call from vbl list
* CREATION : 13.09.01 PNK
*-----------------------------------------------------------------------------------*/

void	ScreenGrab_DeInit( void )
{
	Vbl_RemoveCall( ScreenGrab_Vbl );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : ScreenGrab_Enable( void )
* ACTION   : enables screen grabbing
* CREATION : 13.09.01 PNK
*-----------------------------------------------------------------------------------*/

void	ScreenGrab_Enable( void )
{
	gScreenGrabKeyState   = 0;
	gScreenGrabEnableFlag = 1;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : ScreenGrab_Disable( void )
* ACTION   : disables screen grabbing
* CREATION : 13.09.01 PNK
*-----------------------------------------------------------------------------------*/

void	ScreenGrab_Disable( void )
{
	gScreenGrabEnableFlag = 1;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : ScreenGrab_SetDirectory( const char * apDirectory )
* ACTION   : sets base directory for screengrabs
* CREATION : 13.09.01 PNK
*-----------------------------------------------------------------------------------*/

void	ScreenGrab_SetDirectory( const char * apDirectory )
{
	if( apDirectory )
	{
		strcpy( gScreenGrabDirectory, apDirectory );
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : ScreenGrab_SetKeyIndex( const U8 aIndex )
* ACTION   : sets key index to trigger screen grabs
* CREATION : 13.09.01 PNK
*-----------------------------------------------------------------------------------*/

void	ScreenGrab_SetKeyIndex( const U8 aIndex )
{
	gScreenGrabKeyIndex = aIndex;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : ScreenGrab_Update( void )
* ACTION   : should be called from interrupt handler
* CREATION : 13.09.01 PNK
*-----------------------------------------------------------------------------------*/

void	ScreenGrab_Update( void )
{
	char			lFileName[ 264 ];
	sDegasHeader	lHeader;
	sFileHandle		lHandle;

	if( IKBD_GetKeyStatus( gScreenGrabKeyIndex ) )
	{
		if( !gScreenGrabKeyState )
		{
			sprintf( lFileName, "%sGRAB%04x.PI1", gScreenGrabDirectory, gScreenGrabIndex );
			
			lHandle = File_Create( lFileName );

			if( lHandle > 0 )
			{
				lHeader.Mode = 0;
				Video_GetPalST( &lHeader.Palette[ 0 ] );
				File_Write( lHandle, sizeof(sDegasHeader), &lHeader );
				File_Write( lHandle, 32000, Video_GetpPhysic() );
				File_Close( lHandle );
				gScreenGrabIndex++;
			}

			gScreenGrabKeyState = 1;
		}
	}
	else
	{
		gScreenGrabKeyState = 0;
	}
}


/* ################################################################################ */
