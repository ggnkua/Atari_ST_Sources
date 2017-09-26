#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<STDARG.H>
#include	<STDLIB.H>
#include	<STRING.H>
#include	<STDIO.h>

#include	<atarierr.h>

#include	"main.h"
#include	RSCHEADER
#include	"Irc.h"
#include	"WIrc\IrcFunc.h"

#include	"MapKey.h"

/*-----------------------------------------------------------------------------*/
/* Globale Variablen                                                           */
/*-----------------------------------------------------------------------------*/
WORD	ColourTableObj[COLOUR_MAX] = { COLOURTABLE_MSG, COLOURTABLE_MSGWITHNICK, COLOURTABLE_MYSELF, COLOURTABLE_OP_MSG, COLOURTABLE_SERVER_MSG, COLOURTABLE_ACTION, COLOURTABLE_AWAY_MSG, COLOURTABLE_MSG_BACK, COLOURTABLE_INPUT, COLOURTABLE_INPUT_BACK, COLOURTABLE_USER, COLOURTABLE_USER_VOICE, COLOURTABLE_USER_OP, COLOURTABLE_USER_IRCOP, COLOURTABLE_USER_BACK, COLOURTABLE_CHANNEL, COLOURTABLE_CHANNEL_BACK };
WORD	ColourTableIdx[COLOUR_MAX] = { COLOUR_MSG, COLOUR_MSGWITHNICK, COLOUR_MSG_MYSELF, COLOUR_MSG_OP, COLOUR_MSG_SERVER, COLOUR_ACTION, COLOUR_MSG_AWAY, COLOUR_MSG_BACK, COLOUR_INPUT, COLOUR_INPUT_BACK, COLOUR_USER, COLOUR_USER_VOICE, COLOUR_USER_OP, COLOUR_USER_IRCOP, COLOUR_USER_BACK, COLOUR_CHANNEL, COLOUR_CHANNEL_BACK };
WORD	ColourTableRef[COLOUR_MAX] = { COLOURTABLE_INPUT, COLOURTABLE_INPUT_BACK, COLOURTABLE_MSG, COLOURTABLE_MYSELF, COLOURTABLE_OP_MSG, COLOURTABLE_SERVER_MSG, COLOURTABLE_MSG_BACK, COLOURTABLE_USER, COLOURTABLE_USER_OP, COLOURTABLE_USER_IRCOP, COLOURTABLE_USER_BACK, COLOURTABLE_CHANNEL, COLOURTABLE_CHANNEL_BACK, COLOURTABLE_AWAY_MSG, COLOURTABLE_USER_VOICE, COLOURTABLE_MSGWITHNICK, COLOURTABLE_ACTION };
WORD	IrcFlags = 0;

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/

WORD	OpenIrc( IRC *Irc, WORD Global[15] )
{
	WORD	Ret;
	MT_graf_mouse( M_SAVE, NULL, Global );
	MT_graf_mouse( BUSYBEE, NULL, Global );
#ifdef	DEMO
	if( Irc->Realname )
		free( Irc->Realname );
	Irc->Realname = strdup( "Chatter Demo-Version" );
#endif
	Ret = OpenIrcSession( Irc, Global );
	MT_graf_mouse( M_RESTORE, NULL, Global );
	return( Ret );
}

IRC	*CopyIrc( IRC *Irc )
{
	WORD	i;
	IRC	*New = malloc( sizeof( IRC ));
	if( !New )
		return( NULL );
	memcpy( New, Irc, sizeof( IRC ));

	for( i = 0; i < COLOUR_MAX; i++ )
		New->ColourTable[i] = Irc->ColourTable[i];

	if( Irc->Host )
	{
		New->Host = strdup( Irc->Host );
		if( !New->Host )
			return( NULL );
	}
	if( Irc->Nickname )
	{
		New->Nickname = strdup( Irc->Nickname );
		if( !New->Nickname )
			return( NULL );
	}
	if( Irc->Username )
	{
		New->Username = strdup( Irc->Username );
		if( !New->Username )
			return( NULL );
	}
	if( Irc->Password )
	{
		New->Password = strdup( Irc->Password );
		if( !New->Password )
			return( NULL );
	}
	else
		New->Password = NULL;
	if( Irc->Realname )
	{
		New->Realname = strdup( Irc->Realname );
		if( !New->Realname )
			return( NULL );
	}
	else
		New->Realname = NULL;
	if( Irc->Autojoin )
	{
		New->Autojoin = strdup( Irc->Autojoin );
		if( !New->Autojoin )
			return( NULL );
	}
	else
		New->Autojoin = NULL;

	return( New );
}

void	FreeIrc( IRC *Irc )
{
	FreeContentIrc( Irc );
	free( Irc );
}
void	FreeContentIrc( IRC *Irc )
{
	if( Irc->Host )
		free( Irc->Host );
	if( Irc->Nickname )
		free( Irc->Nickname );
	if( Irc->Username )
		free( Irc->Username );
	if( Irc->Password )
		free( Irc->Password );
	if( Irc->Realname )
		free( Irc->Realname );
	if( Irc->Autojoin )
		free( Irc->Autojoin );
}

/*-----------------------------------------------------------------------------*/
/* ColourTable fÅr Fenster einlesen                                            */
/*-----------------------------------------------------------------------------*/
void	ReadColourTable( double Version, BYTE *Puf, WORD ColourTable[] )
{
	WORD	i, j = COLOUR_MAX;
	BYTE	*Pos = Puf;

	for( i = 0; i < COLOUR_MAX; i++ )
		ColourTable[i] = 1;

	if( Version >= 0.12 && Version < 0.21 )
		j = 13;
	if( Version >= 0.21 && Version < 0.24 )
		j = 14;
	if( Version >= 0.24 && Version < 0.31 )
		j = 15;
	if( Version >= 0.31 && Version < 1.1 )
		j = 16;

	for( i = 0; i < j; i++ )
	{
		ColourTable[i] = atoi( Pos );
		while( *Pos != '\n' )
		{
			if( *Pos == ',' )
				break;
			Pos++;
		}
		if( *Pos != ',' )
			break;
		Pos++;
	}
}
