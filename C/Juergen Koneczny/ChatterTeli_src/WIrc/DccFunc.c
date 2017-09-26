#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<STDARG.H>
#include	<STDLIB.H>
#include	<STRING.H>
#include	<STDIO.h>

#include	<atarierr.h>
#include	<inet.h>

#include	"main.h"
#include	RSCHEADER
#include	"IConnect.h"
#include	"Irc.h"
#include	"Popup.h"
#include	"TCP.h"
#include	"WDialog.h"

#include	"WIrc\DccFunc.h"
#include	"WIrc\Func.h"
#include	"WIrc\IrcFunc.h"
#include	"WIrc\WDccChat.h"

#include	"Keytab.h"

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern KEYT	*Keytab;
extern WORD	KeytabAnsiExport, KeytabAnsiImport;
extern OBJECT	**TreeAddr;
extern WORD	SessionCounter;

/*-----------------------------------------------------------------------------*/
/* OpenDccChatSession                                                          */
/*-----------------------------------------------------------------------------*/
WORD	OpenDccChatSession( IRC *Irc, UWORD Port, ULONG IP, WORD Global[15] )
{
	DCC_CHAT	*DccChat = malloc( sizeof( DCC_CHAT ));
	if( !DccChat )
		return( ENSMEM );

	DccChat->Port = Port;
	DccChat->IP = IP;
	DccChat->Irc = Irc;

	OpenDccChatWindow( DccChat, Global );
	return( E_OK );
}

DCC_CHAT	*Irc2DccChat( IRC *Irc )
{
/*	DCC_CHAT	*DccChat = malloc( sizeof( DCC_CHAT ));
	if( DccChat )
	{
		WORD	i;
		DccChat->nLines = Irc->nLines;
		DccChat->InputFontId = Irc->InputFontId;
		DccChat->InputFontHt = Irc->InputFontHt;
		DccChat->OutputFontId = Irc->OutputFontId;
		DccChat->OutputFontHt = Irc->OutputFontHt;
		DccChat->FontOverWrite = Irc->FontOverWrite;
		DccChat->ColourOverWrite = Irc->ColourOverWrite;
		for( i = 0; i < COLOUR_MAX; i++ )
			DccChat->ColourTable[i] = Irc->ColourTable[i];
	}
	return( DccChat );	*/
}
