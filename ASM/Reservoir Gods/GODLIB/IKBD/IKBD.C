/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: IKBD.C
::
:: Functions for controlling the IKBD chip - keyboard, joystick, mouse + midi
::
:: [c] 2000 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"IKBD.H"

#include	<GODLIB\MEMORY\MEMORY.H>
#include	<GODLIB\SYSTEM\SYSTEM.H>
#include	<GODLIB\VBL\VBL.H>
#include	<GODLIB\XBIOS\XBIOS.H>


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	U8 *	pUnshiftTable;
	U8 *	pShiftTable;
	U8 *	pCapsTable;

	U16	MidiHead;
	U16	MidiTail;

	U16	KbdHead;
	U16	KbdTail;

	U8	KbdOverflowFlag;
	U8	MidiOverflowFlag;

	U8	Joy0Packet;
	U8	Joy1Packet;
	U8	MouseMovedFlag;
	U8	MouseKeys;

	U8	KeyPressedFlag;
	U8	LastKeypress;

	S16	MouseX;
	S16	MouseY;

	U8	TeamTapActiveFlag;
	U8	TeamTapActiveBits;

	U8	Pad0Dir;
	U8	Pad1Dir;
	U16	Pad0Key;
	U16	Pad1Key;

	U8	TeamTapDirs[ 8 ];
	U16	TeamTapKeys[ 8 ];

	U8	KbdPressTable[ 128 ];
	U8	MidiBuffer[ 2048 ];
	U8	KbdBuffer[ 2048 ];
	U8	StatusData[ 8 ];
	U8	TimeOfDay[ 6 ];
	U8	Temp[ 2 ];
} sIKBD;


/* ###################################################################################
#  VARIABLES
################################################################################### */

sIKBD	gIKBD;
void 	(*gIKBDOldHandler)(void);


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

extern	void 	(*IKBD_GetHandler( void ))(void);
extern	void	IKBD_SetHandler( void (*apHandler)(void) );

extern	void	IKBD_SendCmd( U8 aCmd );

extern	void	IKBD_MainHandler( void );
extern	void	IKBD_PowerpadHandler( void );

extern	void	IKBD_InitTosLink( U32 apBuffer, U32 aFunction );


/* ###################################################################################
#  CODE
################################################################################### */

/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_Init()
* ACTION   : gets keyboard tables, saves old kbd handler, 
*			 installs new kbd/midi handler
* CREATION : 25.03.00 PNK
*-----------------------------------------------------------------------------------*/

void	IKBD_Init()
{
	sXbiosKeyTab *	lpKeyTab;
	U16				i;

	Memory_Clear( sizeof(sIKBD), &gIKBD );
	lpKeyTab = Xbios_Keytbl( (void *)0xFFFFFFFFL, (void *)0xFFFFFFFFL, (void *)0xFFFFFFFFL );
	gIKBD.pUnshiftTable = (U8 *)lpKeyTab->pNormal;
	gIKBD.pShiftTable   = (U8 *)lpKeyTab->pShift;
	gIKBD.pCapsTable    = (U8 *)lpKeyTab->pCaps;
	gIKBD.TeamTapActiveBits = 0;

	gIKBDOldHandler = IKBD_GetHandler();
	IKBD_FlushGemdos();
	IKBD_SetHandler( IKBD_MainHandler );
	IKBD_Flush();

	IKBD_ClearBuffer();

	gIKBD.Pad0Dir = 0;
	gIKBD.Pad0Key = 0;
	gIKBD.Pad1Dir = 0;
	gIKBD.Pad1Key = 0;
	for( i=0; i<8; i++ )
	{
		gIKBD.TeamTapDirs[ i ] = 0;
		gIKBD.TeamTapKeys[ i ] = 0;
	}

	switch( System_GetMCH() )
	{
	case	MCH_FALCON:
	case	MCH_STE:
		Vbl_AddCall( IKBD_PowerpadHandler );
		break;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_DeInit()
* ACTION   : restores old kbd/midi handler
* CREATION : 25.03.00 PNK
*-----------------------------------------------------------------------------------*/

void	IKBD_DeInit()
{
	IKBD_Flush();
	IKBD_SetHandler( gIKBDOldHandler );
	IKBD_FlushGemdos();
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_GetKbdOverflowFlag()
* ACTION   : returns a flag indicating keyboard buffer has overflowed
* CREATION : 25.03.00 PNK
*-----------------------------------------------------------------------------------*/

U8		IKBD_GetKbdOverflowFlag()
{
	return( gIKBD.KbdOverflowFlag );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_GetMidiOverflowFlag()
* ACTION   : returns a flag indicating midi buffer has overflowed
* CREATION : 25.03.00 PNK
*-----------------------------------------------------------------------------------*/

U8		IKBD_GetMidiOverflowFlag()
{
	return( gIKBD.MidiOverflowFlag );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_GetPad0Dir()
* ACTION   : gets direction packet for jagpad0
* CREATION : 25.03.00 PNK
*-----------------------------------------------------------------------------------*/

U8		IKBD_GetPad0Dir()
{
	return( gIKBD.Pad0Dir );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_GetPad0Key()
* ACTION   : gets key data packet for jagpad0
* CREATION : 25.03.00 PNK
*-----------------------------------------------------------------------------------*/

U16		IKBD_GetPad0Key()
{
	return( gIKBD.Pad0Key );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_GetPad1Dir()
* ACTION   : gets direction packet for jagpad1
* CREATION : 25.03.00 PNK
*-----------------------------------------------------------------------------------*/

U8		IKBD_GetPad1Dir()
{
	return( gIKBD.Pad1Dir );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_GetPad1Key()
* ACTION   : gets key data packet for jagpad1
* CREATION : 25.03.00 PNK
*-----------------------------------------------------------------------------------*/

U16		IKBD_GetPad1Key()
{
	return( gIKBD.Pad1Key );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_GetKeyStatus( U8 aScanCode )
* ACTION   : returns keypress value for aScanCode
* CREATION : 06.01.01 PNK
*-----------------------------------------------------------------------------------*/

U8			IKBD_GetKeyStatus( U8 aScanCode )
{
	return( gIKBD.KbdPressTable[ aScanCode ] );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_GetMouseX()
* ACTION   : returns mouse x position
* CREATION : 06.01.01 PNK
*-----------------------------------------------------------------------------------*/

S16		IKBD_GetMouseX()
{
	return( gIKBD.MouseX );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_SetMouseX( S16 aX )
* ACTION   : sets mouse x position
* CREATION : 14.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	IKBD_SetMouseX( S16 aX )
{
	gIKBD.MouseX  = aX;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_GetMouseY()
* ACTION   : returns mouse y position
* CREATION : 06.01.01 PNK
*-----------------------------------------------------------------------------------*/

S16		IKBD_GetMouseY()
{
	return( gIKBD.MouseY );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_SetMouseY( S16 aY )
* ACTION   : sets mouse y position
* CREATION : 14.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	IKBD_SetMouseY( S16 aY )
{
	gIKBD.MouseY  = aY;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_SetMousePosition( S16 aX, S16 aY )
* ACTION   : sets mouse position to (aX,aY)
* CREATION : 25.03.00 PNK
*-----------------------------------------------------------------------------------*/

void	IKBD_SetMousePosition( S16 aX, S16 aY )
{
	gIKBD.MouseX = aX;
	gIKBD.MouseY = aY;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_GetMouseKeys()
* ACTION   : returns mouse key state
* CREATION : 06.01.01 PNK
*-----------------------------------------------------------------------------------*/

U8		IKBD_GetMouseKeys()
{
	return( gIKBD.MouseKeys );
}

/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_GetMouseButtonLeft( void )
* ACTION   : IKBD_GetMouseButtonLeft
* CREATION : 02.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U8	IKBD_GetMouseButtonLeft( void )
{
	return( (gIKBD.MouseKeys >> 1) & 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_GetMouseButtonRight( void )
* ACTION   : IKBD_GetMouseButtonRight
* CREATION : 02.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U8	IKBD_GetMouseButtonRight( void )
{
	return( gIKBD.MouseKeys & 1 );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_
* ACTION   : 
* CREATION : 06.01.01 PNK
*-----------------------------------------------------------------------------------*/

U8		IKBD_GetLastKeyPress( void )
{
	return( gIKBD.LastKeypress );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_
* ACTION   : 
* CREATION : 06.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	IKBD_ClearLastKeyPress( void )
{
	gIKBD.LastKeypress = 0;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_
* ACTION   : 
* CREATION : 06.01.01 PNK
*-----------------------------------------------------------------------------------*/

U8		IKBD_GetKeyPressedFlag( void )
{
	return( gIKBD.KeyPressedFlag );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_
* ACTION   : 
* CREATION : 06.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	IKBD_ClearKeyPressedFlag( void )
{
	gIKBD.KeyPressedFlag = 0;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_
* ACTION   : 
* CREATION : 06.01.01 PNK
*-----------------------------------------------------------------------------------*/

U8		IKBD_GetJoy0Packet( void )
{
	return( gIKBD.Joy0Packet );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_
* ACTION   : 
* CREATION : 06.01.01 PNK
*-----------------------------------------------------------------------------------*/

U8				IKBD_GetJoy1Packet( void )
{
	return( gIKBD.Joy1Packet );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_EnableDebugging()
* ACTION   : patches my IKBD handler to jump into tos
* CREATION : 06.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	IKBD_EnableDebugging()
{
	switch( System_GetTosVersion() )
	{
	case	0x104:
		IKBD_InitTosLink( 0xDA0L, 0xFC3C70L );
		break;

	case	0x206:
		IKBD_InitTosLink( 0xED8L, 0xE03044L );
		break;

	case	0x404:
		IKBD_InitTosLink( 0xF96L, 0xE0340AL );
		break;


	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_EnableJoysticks()
* ACTION   : turns on joysticks, turns off mouse
* CREATION : 25.03.00 PNK
*-----------------------------------------------------------------------------------*/

void	IKBD_EnableJoysticks()
{
	IKBD_SendCmd( 0x12 );
	IKBD_SendCmd( 0x14 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_EnableMouse()
* ACTION   : turns on mouse, turns off joystick
* CREATION : 25.03.00 PNK
*-----------------------------------------------------------------------------------*/

void	IKBD_EnableMouse()
{
	IKBD_SendCmd( 0x8 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_ConvertScancodeAscii( U8 aScan )
* ACTION   : returns the ascii value of key with scancode aScan
* CREATION : 25.03.00 PNK
*-----------------------------------------------------------------------------------*/

U8		IKBD_ConvertScancodeAscii( U8 aScan )
{
	U8 *	lpKeyTable;

	if( gIKBD.KbdPressTable[0x2A] || gIKBD.KbdPressTable[0x36] )
	{
		lpKeyTable = gIKBD.pShiftTable;
	}
	else
	{
		lpKeyTable = gIKBD.pUnshiftTable;
	}

	return( lpKeyTable[ aScan ] );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_ConvertScancodeAsciiCaps( U8 aScan )
* ACTION   : returns the capitalised ascii value of key with scancode aScan
* CREATION : 25.03.00 PNK
*-----------------------------------------------------------------------------------*/

U8		IKBD_ConvertScancodeAsciiCaps( U8 aScan )
{
	U8 *	lpKeyTable;

	if( gIKBD.KbdPressTable[0x2A] || gIKBD.KbdPressTable[0x36] )
	{
		lpKeyTable = gIKBD.pShiftTable;
	}
	else
	{
		lpKeyTable = gIKBD.pCapsTable;
	}

	return( lpKeyTable[ aScan ] );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_WaitForKey( const U8 aKey )
* ACTION   : blocks until aKey is pressed
* CREATION : 04.12.00 PNK
*-----------------------------------------------------------------------------------*/

void	IKBD_WaitForKey( const U8 aKey )
{
	do
	{
		while( !IKBD_GetKbdBytesWaiting() );
	} while( IKBD_PopKbdByte() != aKey );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_WaitForKey( const U8 aKey )
* ACTION   : blocks until aKey is pressed
* CREATION : 04.12.00 PNK
*-----------------------------------------------------------------------------------*/

void	IKBD_WaitAnyKey()
{
	while( !IKBD_GetKbdBytesWaiting() );
	IKBD_PopKbdByte();
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_ClearBuffer( void )
* ACTION   : 
* CREATION : 04.12.00 PNK
*-----------------------------------------------------------------------------------*/

void	IKBD_ClearBuffer( void )
{
	U16	i;

	IKBD_Flush();
	for( i=0; i<128; i++)
	{
		gIKBD.KbdPressTable[ i ] = 0;
	}
	IKBD_Flush();
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_EnableTeamTap0( void )
* ACTION   : enables team tap 0
* CREATION : 06.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	IKBD_EnableTeamTap0( void )
{
	gIKBD.TeamTapActiveBits |= 1;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_EnableTeamTap1( void )
* ACTION   : enables team tap 1
* CREATION : 06.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	IKBD_EnableTeamTap1( void )
{
	gIKBD.TeamTapActiveBits |= 2;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_DisableTeamTap0( void )
* ACTION   : disables teamp tap 0
* CREATION : 06.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	IKBD_DisableTeamTap0( void )
{
	gIKBD.TeamTapActiveBits &= ~1;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_DisableTeamTap1( void )
* ACTION   : disables team tap 1
* CREATION : 06.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	IKBD_DisableTeamTap1( void )
{
	gIKBD.TeamTapActiveBits &= ~2;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_GetTeamTapPadDir( const U8 aTap, const U8 aPad )
* ACTION   : gets direction keys status for pad aPad in team tap aTap
* CREATION : 06.01.01 PNK
*-----------------------------------------------------------------------------------*/

U8		IKBD_GetTeamTapPadDir( const U8 aTap, const U8 aPad )
{
	return( gIKBD.TeamTapDirs[ (aTap<<2)+aPad ] );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : IKBD_GetTeamTapPadKey( const U8 aTap, const U8 aPad )
* ACTION   : gets keys status for pad aPad in team tap aTap
* CREATION : 06.01.01 PNK
*-----------------------------------------------------------------------------------*/

U16		IKBD_GetTeamTapPadKey( const U8 aTap, const U8 aPad )
{
	return( gIKBD.TeamTapKeys[ (aTap<<2)+aPad ] );
}


/* ################################################################################ */
