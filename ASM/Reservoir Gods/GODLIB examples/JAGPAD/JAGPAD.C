/*************************************************************************************
 * GodLib Example Progam Suite
 * 
 * Demonstrates basic JagPad functionality
 *
 * PINK 01.01.03
 *************************************************************************************
*/

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\GEMDOS\GEMDOS.H>
#include	<GODLIB\IKBD\IKBD.H>
#include	<GODLIB\SYSTEM\SYSTEM.H>
#include	<GODLIB\VBL\VBL.H>


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void	Hardware_Init( void );
void	Hardware_DeInit( void );

void	Test_Loop( void );
void	JagPad_PacketDisplay( const U8 aPacket );


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
	IKBD_Init();
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Hardware_DeInit( void )
* ACTION   : Hardware_DeInit
* CREATION : 18.12.2002 PNK
*-----------------------------------------------------------------------------------*/

void	Hardware_DeInit( void )
{
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
	while( !IKBD_GetKeyStatus(eIKBDSCAN_SPACE) )
	{

		printf(  "PADA: " );
		JagPad_PacketDisplay( IKBD_GetPad0Dir() );
		printf( " PADB: " );
		JagPad_PacketDisplay( IKBD_GetPad1Dir() );
		printf( "\n" );
	}
	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : JagPad_PacketDisplay( const U8 aPacket )
* ACTION   : JagPad_PacketDisplay
* CREATION : 02.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	JagPad_PacketDisplay( const U8 aPacket )
{
	if( aPacket & 1 )
	{
		printf( "U" );
	}
	else
	{
		printf( " " );
	}

	if( aPacket & 2 )
	{
		printf( "D" );
	}
	else
	{
		printf( " " );
	}

	if( aPacket & 4 )
	{
		printf( "L" );
	}
	else
	{
		printf( " " );
	}

	if( aPacket & 8 )
	{
		printf( "R" );
	}
	else
	{
		printf( " " );
	}

	if( aPacket & 32 )
	{
		printf( "C" );
	}
	else
	{
		printf( " " );
	}

	if( aPacket & 64 )
	{
		printf( "B" );
	}
	else
	{
		printf( " " );
	}

	if( aPacket & 128 )
	{
		printf( "A " );
	}
	else
	{
		printf( "  " );
	}
}



/* ################################################################################ */
