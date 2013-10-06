/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"CLI.H"

#ifdef	dCLI_ACTIVE

#include	<GODLIB\ASSERT\ASSERT.H>
#include	<GODLIB\DEBUGLOG\DEBUGLOG.H>
#include	<GODLIB\FONT8X8\FONT8X8.H>
#include	<GODLIB\IKBD\IKBD.H>
#include	<GODLIB\MEMORY\MEMORY.H>
#include	<GODLIB\VIDEO\VIDEO.H>


/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dCLI_CMD_LIMIT			128
#define	dCLI_STRING_LIMIT		40
#define	dCLI_HISTORY_LIMIT		128
#define	dCLI_DISPLAYLINES_LIMIT	25


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef struct
{
	char *			pCommandString;
	fCliCommandFunc	fCommand;
	char *			pHelpTxt;
} sCliCommand;


/* ###################################################################################
#  DATA
################################################################################### */

sCliCommand	gCliCommand[ dCLI_CMD_LIMIT ];
char		gCliDisplayLine[ dCLI_DISPLAYLINES_LIMIT ][ dCLI_STRING_LIMIT ];
char		gCliHistoryLine[ dCLI_HISTORY_LIMIT ][ dCLI_STRING_LIMIT ];
char		gCliCurrentLine[ dCLI_STRING_LIMIT ];
char		gCliTabStub[ dCLI_STRING_LIMIT ];
S16			gCliTabIndex;
S16			gCliTabbingFlag;
U16			gCliCursorX;
S16			gCliCurrentLineIndex;
S16			gCliHistoryLineIndex;
S16			gCliDisplayLineIndex;
U16			gCliDisplayLoopedFlag;
U16			gCliHistoryLoopedFlag;
S16			gCliCommandCount;
U16 *		gpCliSavedScreen;
U16			gCliPal[ 16 ] =
{
	0x000, 0xFFF, 0xFFF, 0xFFF,
	0xFFF, 0xFFF, 0xFFF, 0xFFF,
	0xFFF, 0xFFF, 0xFFF, 0xFFF,
	0xFFF, 0xFFF, 0xFFF, 0xFFF
};
U16		gCliSavedPal[ 16 ];


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void			Cli_Main( void );
sCliCommand *	Cli_GetpCommand( char * apCommandString );

void			Cli_StringClear( char * apString );
void			Cli_StringCopy( char * apDst, const char * apSrc );
U32				Cli_StringLength( const char * apString );
U8				Cli_StringsAreEqual( const char * apStr0, const char * apStr1 );
void			Cli_InitCurrentLine( void);
void			Cli_DrawCli( void );
void			Cli_DrawHistory( void );
void			Cli_DrawCurrentLine( void );		
void			Cli_ProcessCurrentLine( void );
void			Cli_DeleteChar( void );
void			Cli_BackSpaceChar( void );
void			Cli_TabExpand( void );
void			Cli_GetPrevLineHistory( void );
void			Cli_GetNextLineHistory( void );
void			Cli_GetPrevCharHistory( void );
void			Cli_GetNextCharHistory( void );
void			Cli_InsertChar( U8 aChar );

void			Cli_ClearScreen( U16 * apScreen );
void			Cli_CopyScreen(  U16 * apSrc, U16 * apDst );
void			Cli_DrawBox( U16 * apScreen, U16 aX, U16 aY, U16 aWidth, U16 aHeight );


/* ###################################################################################
#  CODE
################################################################################### */

/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_Init( void )
* ACTION   : called at start of app
* CREATION : 26.01.01 PNK
*-----------------------------------------------------------------------------------*/

void			Cli_Init( void )
{
	U16	i;
	

	for( i=0; i<dCLI_CMD_LIMIT; i++ )
	{
		gCliCommand[ i ].pCommandString = 0;
		gCliCommand[ i ].fCommand       = 0;
		gCliCommand[ i ].pHelpTxt       = 0;
	}

	for( i=0; i<dCLI_HISTORY_LIMIT; i++ )
	{
		Cli_StringClear( &gCliHistoryLine[ i ][ 0 ] );
	}

	for( i=0; i<dCLI_DISPLAYLINES_LIMIT; i++ )
	{
		Cli_StringClear( &gCliDisplayLine[ i ][ 0 ] );
	}

	Cli_StringClear( &gCliCurrentLine[ 0 ] );
	Cli_StringClear( &gCliTabStub[ 0 ] );

	gCliCursorX           = 0;
	gCliCurrentLineIndex  = 0;
	gCliDisplayLineIndex  = 0;
	gCliDisplayLoopedFlag = 0;
	gCliHistoryLineIndex  = 0;
	gCliHistoryLoopedFlag = 0;
	gCliCommandCount      = 0;
	gCliTabIndex          = 0;
	gCliTabbingFlag       = 0;

	gpCliSavedScreen = Memory_Alloc( 32000L );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_AppDeInit( void )
* ACTION   : called at end of app
* CREATION : 26.01.01 PNK
*-----------------------------------------------------------------------------------*/

void			Cli_DeInit( void )
{
	U16	i;

	for( i=0; i<dCLI_CMD_LIMIT; i++ )
	{
		gCliCommand[ i ].pCommandString = 0;
		gCliCommand[ i ].fCommand       = 0;
		gCliCommand[ i ].pHelpTxt       = 0;
	}

	Memory_Release( gpCliSavedScreen );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_CmdInit( char * apCommandString, fCliCommandFunc afCmd, char * apHelpTxt )
* ACTION   : registers a command
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void			Cli_CmdInit( char * apCommandString, fCliCommandFunc afCmd, char * apHelpTxt )
{
	U16	i;
	
	Cli_CmdDeInit( apCommandString );

	for( i=0; i<dCLI_CMD_LIMIT; i++ )
	{
		if( !gCliCommand[ i ].pCommandString )
		{
			gCliCommand[ i ].pCommandString = apCommandString;
			gCliCommand[ i ].fCommand       = afCmd;
			gCliCommand[ i ].pHelpTxt       = apHelpTxt;
			gCliCommandCount++;
			return;
		}
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_GetpCommand( char * apCommandString )
* ACTION   : finds sCliCommand structure for apCommandString
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

sCliCommand *	Cli_GetpCommand( char * apCommandString )
{
	U16	i;

	if( apCommandString )
	{
		for( i=0; i<dCLI_CMD_LIMIT; i++ )
		{
			if( gCliCommand[ i ].pCommandString )
			{
				if( Cli_StringsAreEqual( apCommandString, gCliCommand[ i ].pCommandString ) )
				{
					return( &gCliCommand[ i ] );
				}
			}
		}
	}
	return( 0 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_CmdDeInit( char * apCommandString )
* ACTION   : removes command from CLI
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void			Cli_CmdDeInit( char * apCommandString )
{
	sCliCommand *	apCmd;

	apCmd = Cli_GetpCommand( apCommandString );
	if( apCmd )
	{
		apCmd->pCommandString = 0;
		apCmd->fCommand       = 0;
		apCmd->pHelpTxt       = 0;
		gCliCommandCount--;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_Update( void )
* ACTION   : called every game frame
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	Cli_Update( void )
{
	if( eIKBDSCAN_ESC == IKBD_GetLastKeyPress() )
	{
		IKBD_ClearLastKeyPress();
		Cli_Main();
		IKBD_ClearLastKeyPress();
	}

}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_Main( void )
* ACTION   : cli processing loop
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	Cli_Main()
{
	U8		lExitFlag;
	U8		lChar;

	Cli_CopyScreen(  Video_GetpPhysic(), gpCliSavedScreen );
	Cli_ClearScreen( Video_GetpPhysic() );

	Video_GetPalST( &gCliSavedPal[ 0 ] );
	Video_SetPalST( &gCliPal[ 0 ] );

	lExitFlag = 0;
	
	Cli_ClearScreen( Video_GetpPhysic() );
	Cli_InitCurrentLine();
	Cli_DrawCli();

	while( IKBD_GetKeyStatus( eIKBDSCAN_ESC ) );
	while( IKBD_GetKbdBytesWaiting() ) IKBD_PopKbdByte();

	IKBD_ClearKeyPressedFlag();

	while( !lExitFlag )
	{

		while( !IKBD_GetKeyPressedFlag() );
		lChar = IKBD_GetLastKeyPress();
		IKBD_ClearKeyPressedFlag();

		switch( lChar )
		{
		case	eIKBDSCAN_ESC:
			lExitFlag = 1;
			break;
		case	eIKBDSCAN_NUMPADENTER:
		case	eIKBDSCAN_RETURN:
			Cli_ProcessCurrentLine();
			break;
		case	eIKBDSCAN_DELETE:
			Cli_DeleteChar();
			break;
		case	eIKBDSCAN_BACKSPACE:
			Cli_BackSpaceChar();
			break;
		case	eIKBDSCAN_TAB:
			Cli_TabExpand();
			break;
		case	eIKBDSCAN_UPARROW:
			Cli_GetPrevLineHistory();
			break;
		case	eIKBDSCAN_DOWNARROW:
			Cli_GetNextLineHistory();
			break;
		case	eIKBDSCAN_LEFTARROW:
			Cli_GetPrevCharHistory();
			break;
		case	eIKBDSCAN_RIGHTARROW:
			Cli_GetNextCharHistory();
			break;
		default:
			lChar = IKBD_ConvertScancodeAscii( lChar );
			Cli_InsertChar( lChar );
			break;
		}
		Cli_DrawCurrentLine();
	}

	while( IKBD_GetKbdBytesWaiting() ) IKBD_PopKbdByte();
	IKBD_ClearLastKeyPress();

	Video_SetPalST( &gCliSavedPal[ 0 ] );
	Cli_CopyScreen( gpCliSavedScreen, Video_GetpPhysic() );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_InitCurrentLine()
* ACTION   : inits the current cli line
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void		Cli_InitCurrentLine()
{
	Cli_StringClear( &gCliCurrentLine[ 0 ] );
	Cli_StringClear( &gCliTabStub[ 0 ] );
	gCliTabIndex    = 0;
	gCliTabbingFlag = 0;
	gCliCursorX     = 0;
	gCliHistoryLineIndex = gCliCurrentLineIndex;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_InsertChar( U8 aChar )
* ACTION   : inserts character aChar into command line
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void		Cli_InsertChar( U8 aChar )
{
	if( ( aChar >= ' ' ) &&  ( aChar <128 ) )
	{
		gCliCurrentLine[ gCliCursorX   ] = aChar;
		gCliCurrentLine[ gCliCursorX+1 ] = 0;

		if( gCliCursorX + 2 < dCLI_STRING_LIMIT )
			gCliCursorX++;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_DeleteChar()
* ACTION   : deletes char at current cursor position on command line
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void		Cli_DeleteChar()
{
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_BackSpaceChar()
* ACTION   : deletes char before cursor position
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void		Cli_BackSpaceChar()
{
	gCliCurrentLine[ gCliCursorX ] = 0;
	if( gCliCursorX > 0 )
	{
		gCliCursorX--;
		gCliCurrentLine[ gCliCursorX   ] = 0;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_ProcessCurrentLine()
* ACTION   : parses command line and processes relevant commands
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void		Cli_ProcessCurrentLine()
{
	char			lString[ dCLI_STRING_LIMIT+2 ];
	sCliCommand *	apCmd;
	U16				lIndex;

	Cli_PrintLine( &gCliCurrentLine[ 0 ] );

	lIndex = 0;
	while( (lIndex<dCLI_STRING_LIMIT) && (gCliCurrentLine[lIndex]) && (gCliCurrentLine[lIndex]!=' ') )
	{
		lString[ lIndex ] = gCliCurrentLine[ lIndex ];
		lIndex++;
	}
	lString[ lIndex ] = 0;

	while( gCliCurrentLine[ lIndex ] == ' ' )
		lIndex++;

	if( Cli_StringLength( lString ) )
	{
		apCmd = Cli_GetpCommand( lString );
		if( apCmd )
		{
			apCmd->fCommand( &gCliCurrentLine[ lIndex ] );
		}
	}

	Cli_StringCopy( &gCliHistoryLine[ gCliCurrentLineIndex ][ 0 ], &gCliCurrentLine[ 0 ] );
	gCliCurrentLineIndex++;
	if( gCliCurrentLineIndex >= dCLI_HISTORY_LIMIT )
	{
		gCliCurrentLineIndex  = 0;
		gCliHistoryLoopedFlag = 1;
	}
	Cli_InitCurrentLine();
	Cli_DrawCli();
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_TabExpand()
* ACTION   : tab expands current line
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void		Cli_TabExpand()
{
	U32		lLen;
	U16		i,j;

	if( !gCliTabbingFlag )
	{
		Cli_StringCopy( &gCliTabStub[ 0 ], &gCliCurrentLine[ 0 ] );
		gCliTabIndex    = -1;
		gCliTabbingFlag = 1;
	}

	lLen = Cli_StringLength( &gCliTabStub[ 0 ] );
	for( i=0; i<dCLI_CMD_LIMIT; i++ )
	{
		gCliTabIndex++;
		if( gCliTabIndex >= dCLI_CMD_LIMIT )
			gCliTabIndex = 0;

		if( gCliCommand[ gCliTabIndex ].pCommandString )
		{
			j = 0;
			while( ( j<lLen ) && ( gCliTabStub[ j ] == gCliCommand[ gCliTabIndex ].pCommandString[ j ] ) )
				j++;

			if( j==lLen )
			{
				Cli_StringCopy( &gCliCurrentLine[ 0 ], gCliCommand[ gCliTabIndex ].pCommandString );
				gCliCursorX = (U16)Cli_StringLength( &gCliCurrentLine[ 0 ] );
				Cli_DrawCurrentLine();
				return;
			}
		}
	}

}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_GetPrevLineHistory()
* ACTION   : grabs a char from history and places in current command line
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void		Cli_GetPrevCharHistory()
{
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_GetPrevLineHistory()
* ACTION   : grabs a char from history and places in current command line
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void		Cli_GetNextCharHistory()
{
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_GetPrevLineHistory()
* ACTION   : grabs a command from history and places in current command line
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void		Cli_GetPrevLineHistory()
{
	gCliHistoryLineIndex--;
	if( gCliHistoryLineIndex < 0 )
	{
		if( gCliHistoryLoopedFlag )
		{
			gCliHistoryLineIndex = dCLI_HISTORY_LIMIT - 1;
		}
		else
		{
			gCliHistoryLineIndex = 0;
		}
	}


	Cli_StringCopy( &gCliCurrentLine[ 0 ], & gCliHistoryLine[ gCliHistoryLineIndex ][ 0 ] );
	gCliCursorX = (U16)Cli_StringLength( &gCliCurrentLine[ 0 ] );
	Cli_DrawCurrentLine();
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_GetNextLineHistory()
* ACTION   : grabs a command from history and places in current command line
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void		Cli_GetNextLineHistory()
{
	gCliHistoryLineIndex++;
	if( gCliHistoryLineIndex > gCliCurrentLineIndex )
	{
		if( !gCliHistoryLoopedFlag )
		{
			gCliHistoryLineIndex = gCliCurrentLineIndex;
		}
	}
	if( gCliHistoryLineIndex >= dCLI_HISTORY_LIMIT )
	{
		gCliHistoryLineIndex = 0;
	}

	Cli_StringCopy( &gCliCurrentLine[ 0 ], & gCliHistoryLine[ gCliHistoryLineIndex ][ 0 ] );
	gCliCursorX = (U16)Cli_StringLength( &gCliCurrentLine[ 0 ] );
	Cli_DrawCurrentLine();
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_ClearString( char * apString )
* ACTION   : clears a string
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void			Cli_StringClear( char * apString )
{
	U16	i;

	for( i=0; i<dCLI_STRING_LIMIT; i++ )
	{
		apString[ i ] = 0;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_StringLength( const char * apString )
* ACTION   : returns length of a string
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

U32				Cli_StringLength( const char * apString )
{
	U32	lLen;

	lLen = 0;

	if( apString )
	{
		while( *apString++ )
		{
			lLen++;
		}
	}

	return( lLen );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_StringsAreEqual( const char * apStr0, const char * apStr1 )
* ACTION   : compares two strings, returns 1 if they are equal
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

U8				Cli_StringsAreEqual( const char * apStr0, const char * apStr1 )
{
	if( !apStr0 )
	{
		if( !apStr1 )
			return( 1 );
		return( 0 );
	}
	if( !apStr1 )
	{
		return( 0 );
	}

	while( (*apStr0) && (*apStr1) )
	{
		if( *apStr0++ != * apStr1++ )
		{
			return( 0 );
		}
	}

	if( *apStr0 != * apStr1 )
	{
		return( 0 );
	}
	
	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_StringCopy( char * apDst, const char * apSrc )
* ACTION   : copires string apSrc to apDst
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void		Cli_StringCopy( char * apDst, const char * apSrc )
{
	U16	i;

	Cli_StringClear( apDst );

	if( apSrc )
	{
		i = 0;
		while( (i<dCLI_STRING_LIMIT) && (apSrc[i]) )
		{
			apDst[ i ] = apSrc[ i ];
			i++;
		}
	}
}

/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_DrawCli()
* ACTION   : draws CLI
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void		Cli_DrawCli()
{
	Cli_ClearScreen( Video_GetpPhysic() );
	Cli_DrawHistory();
	Cli_DrawCurrentLine();
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_PrintLine( char * apTxt )
* ACTION   : prints string apTxt on CLI screen
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void		Cli_PrintLine( char * apTxt )
{
	Cli_StringCopy( &gCliDisplayLine[ gCliDisplayLineIndex ][ 0 ], apTxt );
	gCliDisplayLineIndex++;
	if( gCliDisplayLineIndex >= dCLI_DISPLAYLINES_LIMIT )
	{
		gCliDisplayLoopedFlag = 1;
		gCliDisplayLineIndex  = 0;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_DrawHistory( void )
* ACTION   : prints all previous CLI text
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void		Cli_DrawHistory( void )
{
	S16	lLineIndex;
	S16	lLineY;


	lLineIndex = gCliDisplayLineIndex;

	for( lLineY = dCLI_DISPLAYLINES_LIMIT-2; lLineY >=0; lLineY-- )
	{
		lLineIndex--;
		if( lLineIndex < 0 )
		{
			if( gCliDisplayLoopedFlag )
				lLineIndex = dCLI_DISPLAYLINES_LIMIT-1;
			else
				return;
		}
		Font8x8_Print( &gCliDisplayLine[ lLineIndex ][ 0 ], Video_GetpPhysic(), 0, lLineY*8 );
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_DrawCurrentLine( void )
* ACTION   : prints current line
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void		Cli_DrawCurrentLine( void )
{
	S16		lY;
	char	lString[ dCLI_STRING_LIMIT+4 ];

	lY = (dCLI_DISPLAYLINES_LIMIT-1)*8;

	Cli_DrawBox( Video_GetpPhysic(), 0, lY, 320, 8 );
	sprintf( lString, ">%s*", &gCliCurrentLine[0] );
	Font8x8_Print( lString, Video_GetpPhysic(), 0, lY );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_GrabNumber( char * apTxt )
* ACTION   : prints current line
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

S32				Cli_GrabNumber( const char * apTxt )
{
	S32	lVal;
	S32	lSign;
	U8	lMode;

	while( *apTxt == ' ' )
	{
		apTxt++;
	}

	if( *apTxt == '-' )
	{
		lSign = -1;
		apTxt++;
	}
	else
	{
		lSign = 1;
	}

	lMode = 0;
	if( *apTxt == '$' )
	{
		lMode = 1;
		apTxt++;
	}
	if( apTxt[ 1 ] == 'x' )
	{
		lMode = 1;
		apTxt += 2;
	}

	lVal = 0;
	if( lMode )
	{
		while( 
				( (*apTxt >= '0') && (*apTxt <= '9') )
			||	( (*apTxt >= 'a') && (*apTxt <= 'f') )
			||	( (*apTxt >= 'A') && (*apTxt <= 'F') )
			)
		{
			lVal *= 16L;
			if( (*apTxt >= '0') && (*apTxt <= '9') )
			{
				lVal += *apTxt - '0';
			}
			else if( (*apTxt >= 'a') && (*apTxt <= 'f') )
			{
				lVal += (*apTxt - 'a')+10;
			}
			else if( (*apTxt >= 'A') && (*apTxt <= 'F') )
			{
				lVal += (*apTxt - 'A')+10;
			}
			apTxt++;
		}
	}
	else
	{
		while( (*apTxt >= '0') && (*apTxt <= '9') )
		{
			lVal *= 10L;
			lVal += *apTxt - '0';
			apTxt++;
		}
	}

	lVal *= lSign;
	return( lVal );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_GetpSavedPal( void )
* ACTION   : returns pointer to saved palette
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

U16 *			Cli_GetpSavedPal( void )
{
	return( &gCliSavedPal[ 0 ] );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_GetpPal( void )
* ACTION   : returns pointer to CLI palette
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

U16 *			Cli_GetpPal( void )
{
	return( &gCliPal[ 0 ] );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_ClearScreen( U16 * apScreen )
* ACTION   : clears screen apScreen
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void			Cli_ClearScreen( U16 * apScreen )
{
	U16	i;

	for( i=0; i<(32000/2); i++ )
	{
		*apScreen++ = 0;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_CopyScreen( U16 * apSrc, const U16 * apDst )
* ACTION   : copies screen apSrc to apDst
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void			Cli_CopyScreen( U16 * apSrc, U16 * apDst )
{
	U16	i;

	for( i=0; i<(32000/2); i++ )
	{
		*apDst++ = *apSrc++;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Cli_DrawBox( U16 * apScreen, U16 aX, U16 aY, U16 aWidth, U16 aHeight )
* ACTION   : clears a box on apScreen at aX,aY of width aWidth and height aHeight
* CREATION : 30.01.01 PNK
*-----------------------------------------------------------------------------------*/

void			Cli_DrawBox( U16 * apScreen, U16 aX, U16 aY, U16 aWidth, U16 aHeight )
{
	U16	*	lpScreen;
	U16		lY;
	U16		i;

	for( lY = aY; lY<(aY+aHeight); lY++ )
	{
		lpScreen  = apScreen;
		lpScreen += (lY*80);
		lpScreen += (aX>>4)<<2;
		for( i=0; i<(aWidth>>4); i++ )
		{
			*lpScreen++ = 0;
			*lpScreen++ = 0;
			*lpScreen++ = 0;
			*lpScreen++ = 0;
		}
	}

}


/* ################################################################################ */

#endif