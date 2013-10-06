/*************************************************************************************
 * GodLib Example Progam Suite
 * 
 * Demonstrates basic screen functionality
 *
 * PINK 01.01.03
 *************************************************************************************
*/

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\GEMDOS\GEMDOS.H>
#include	<GODLIB\GRAPHIC\GRAPHIC.H>
#include	<GODLIB\IKBD\IKBD.H>
#include	<GODLIB\MEMORY\MEMORY.H>
#include	<GODLIB\SYSTEM\SYSTEM.H>
#include	<GODLIB\VBL\VBL.H>
#include	<GODLIB\VIDEO\VIDEO.H>


/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dBOX_X			10
#define	dBOX_Y			80
#define	dBOX_WIDTH		200
#define	dBOX_HEIGHT		60
#define	dBOX_COLOUR		1


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void	Hardware_Init( void );
void	Hardware_DeInit( void );

void	Test_Loop( void );
void	JagPad_PacketDisplay( const U8 aPacket );

void	Screen_Init( void );
void	Screen_DeInit( void );
void	Screen_Swap( void );
void	Box_Render( void );


/* ###################################################################################
#  DATA
################################################################################### */

void *			gpScreenMem;
U16 *			gpPhysic;
U16 *			gpLogic;


/* ###################################################################################
#  CODE
################################################################################### */

/*-----------------------------------------------------------------------------------*
* FUNCTION : main( void )
* ACTION   : it begins  ...
* CREATION : 18.02.2002 PNK
*-----------------------------------------------------------------------------------*/

S16	main( S16 aArgCount, char * apArgs[] )
{
	GemDos_Super( 0 );

	Hardware_Init();

	Test_Loop();

	Hardware_DeInit();

	return( 0 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Hardware_Init( void )
* ACTION   : Hardware_Init
* CREATION : 18.12.2002 PNK
*-----------------------------------------------------------------------------------*/

void	Hardware_Init( void )
{
	System_Init();
	Vbl_Init();
	Video_Init();
	IKBD_Init();
	Graphic_Init();
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Hardware_DeInit( void )
* ACTION   : Hardware_DeInit
* CREATION : 18.12.2002 PNK
*-----------------------------------------------------------------------------------*/

void	Hardware_DeInit( void )
{
	Graphic_DeInit();
	Video_DeInit();
	IKBD_DeInit();
	Vbl_DeInit();
	System_DeInit();	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Test_Loop( void )
* ACTION   : Test_Loop
* CREATION : 18.12.2002 PNK
*-----------------------------------------------------------------------------------*/

void	Test_Loop( void )
{
	Screen_Init();


	while( !IKBD_GetKeyStatus(eIKBDSCAN_SPACE) )
	{
		Screen_Swap();
	}

	Screen_DeInit();
}

/*-----------------------------------------------------------------------------------*
* FUNCTION : Screen_Init( void )
* ACTION   : Screen_Init
* CREATION : 02.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Screen_Init( void )
{
	U32		lAligned;

	gpScreenMem = Memory_ScreenCalloc( 64000L + 255L );

	lAligned    = (U32)gpScreenMem;
	lAligned   += 255L;
	lAligned   &= 0xFFFFFF00L;
	
	gpPhysic    = (U16*)lAligned;

	lAligned   += 32000L;

	gpLogic     = (U16*)lAligned;

	Video_SetPhysic( gpPhysic );
	Video_SetMode( 320, 200, eVIDEO_MODE_4PLANE, 320, 0, 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Screen_DeInit( void )
* ACTION   : Screen_DeInit
* CREATION : 02.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Screen_DeInit( void )
{
	Memory_Release( gpScreenMem );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Screen_Swap( void )
* ACTION   : Screen_Swap
* CREATION : 02.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Screen_Swap( void )
{
	U16	*	lpTemp;
	
	lpTemp   = gpPhysic;
	gpPhysic = gpLogic;
	gpLogic  = lpTemp;

	Video_SetPhysic( gpPhysic );
	Vbl_WaitVbl();
}






/* ################################################################################ */
