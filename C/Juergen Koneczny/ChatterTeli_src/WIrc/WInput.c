#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<STRING.H>
#include	<STDIO.H>

#include	<atarierr.h>

#include	"main.h"
#include	RSCHEADER
#include	"Irc.h"
#include	"Help.h"
#include	"Menu.h"
#include	"Popup.h"
#include	"Rsc.h"
#include	"Tcp.h"
#include	"WDialog.h"
#include	"Window.h"
#include	"WIrc\IrcFunc.h"
#include	"WIrc\WDccChat.h"
#include	"WIrc\WInput.h"
#include	"ExtObj\TextObj.h"

#include	"EdScroll.h"
#include	"MapKey.h"

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	Global[15];
extern OBJECT	**TreeAddr;
extern WORD	isScroll;

extern BYTE	*CtcpCmd[];
/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
static XTED	NiuXted;
static BYTE	NiuTmplt[EDITLEN+1], NiuTxt[EDITLEN+1];
static XTED	NnXted;
static BYTE	NnTmplt[EDITLEN+1], NnTxt[EDITLEN+1];
static XTED	OpXted;
static BYTE	OpTmplt[EDITLEN+1], OpTxt[EDITLEN+1];
static XTED	KickXted;
static BYTE	KickTmplt[EDITLEN+1], KickTxt[EDITLEN+1];
static XTED	CommentXted;
static BYTE	CommentTmplt[EDITLEN+1], CommentTxt[EDITLEN+1];
static XTED	InviteNickXted, InviteChannelXted;
static BYTE	InviteNickTmplt[EDITLEN+1], InviteChannelTmplt[EDITLEN+1], InviteNickTxt[EDITLEN+1], InviteChannelTxt[EDITLEN+1];
static XTED	TopicXted;
static BYTE	TopicTmplt[EDITLEN+1], TopicTxt[EDITLEN+1];
static XTED	AwayXted;
static BYTE	AwayTmplt[EDITLEN+1], AwayTxt[EDITLEN+1];
static XTED	MsgXted;
static BYTE	MsgTmplt[EDITLEN+1], MsgTxt[EDITLEN+1];
static XTED	CtcpNickXted, CtcpCmdXted;
static BYTE	CtcpNickTmplt[EDITLEN+1], CtcpNickTxt[EDITLEN+1], CtcpCmdTmplt[EDITLEN+1], CtcpCmdTxt[EDITLEN+1];

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static WORD cdecl	HandleNiuDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData );
static WORD HndlClsNiuDialog( void *DialogData, WORD Global[15] );
static WORD cdecl	HandleNnDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData );
static WORD HndlClsNnDialog( void *DialogData, WORD Global[15] );
static WORD cdecl	HandleOpDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData );
static WORD HndlClsOpDialog( void *DialogData, WORD Global[15] );
static WORD cdecl	HandleKickDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData );
static WORD HndlClsKickDialog( void *DialogData, WORD Global[15] );
static WORD cdecl	HandleInviteDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData );
static WORD HndlClsInviteDialog( void *DialogData, WORD Global[15] );
static WORD cdecl	HandleTopicDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData );
static WORD HndlClsTopicDialog( void *DialogData, WORD Global[15] );
static WORD cdecl	HandleCModeDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData );
static WORD HndlClsCModeDialog( void *DialogData, WORD Global[15] );
static WORD cdecl	HandleUModeDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData );
static WORD HndlClsUModeDialog( void *DialogData, WORD Global[15] );
static WORD cdecl	HandleAwayDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData );
static WORD HndlClsAwayDialog( void *DialogData, WORD Global[15] );
static WORD cdecl	HandleInvitedDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData );
static WORD HndlClsInvitedDialog( void *DialogData, WORD Global[15] );
static WORD cdecl	HandleInfoDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData );
static WORD HndlClsInfoDialog( void *DialogData, WORD Global[15] );
static WORD cdecl	HandleMsgDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData );
static WORD HndlClsMsgDialog( void *DialogData, WORD Global[15] );
static WORD cdecl	HandleCtcpDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData );
static WORD HndlClsCtcpDialog( void *DialogData, WORD Global[15] );

WORD	NiuDialog( IRC_SESSION *IrcSession, BYTE *Nickname, WORD Global[15] )
{
	IRC	*Irc = IrcSession->Irc;
	DIALOG_DATA		*DialogData;

	if( TreeAddr[NIU][NIU_NEW].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
		InitScrlted( &TreeAddr[NIU][NIU_NEW], isScroll, &NiuXted, NiuTxt, NiuTmplt, EDITLEN );

	if(( DialogData = malloc( sizeof( DIALOG_DATA ))) == NULL )
		return( ENSMEM );

	DialogData->Dialog = NULL;
	DialogData->HndlDdDialog = NULL;
	DialogData->HndlClsDialog = HndlClsNiuDialog;
	DialogData->HndlMesagDialog = NULL;
	DialogData->HndlTimerDialog = NULL;
	DialogData->HndlEditDialog = NULL;
	DialogData->HndlHelpDialog = NULL;
	DialogData->HndlCheckDialog = HndlCheckDialogWIrc;
	DialogData->UserData = IrcSession;
	DialogData->TreeIndex = NIU;

	if(( DialogData->Tree = CopyTree( TreeAddr[NIU] )) == NULL )
	{
		free( DialogData );
		return( ENSMEM );
	}

	strcpy( DialogData->Tree[NIU_NICKNAME].ob_spec.free_string, Nickname );
	DialogData->Tree[NIU_OK].ob_state |= DISABLED;
	DialogData->Tree[NIU_OK].ob_flags &= ~SELECTABLE;

	if( OpenDialogX( IrcSession->IrcChannel->ChatWindow->Title, WIN_ALERT_WINDOW, NAME + MOVER, -1, -1, HandleNiuDialog, DialogData, Global ) != E_OK )
	{
		FreeTree( DialogData->Tree );
		free( DialogData );
		return( ERROR );
	}
	return( MT_wdlg_get_handle( DialogData->Dialog, Global ));
}
static WORD cdecl	HandleNiuDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_EDIT:
			{
				break;
			}
			case	HNDL_CLSD:
				if( Events->msg[4] == WIN_CLOSE_WITHOUT_DEMAND )
				{
					CloseSessionAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
					return( 0 );
				}
				else
					return( 1 );
			case	HNDL_EDDN:
			{
				if( strlen( DialogTree[NIU_NEW].ob_spec.tedinfo->te_ptext ))
				{
					if( DialogTree[NIU_OK].ob_state & DISABLED )
					{
						DialogTree[NIU_OK].ob_state &= ~DISABLED;
						DialogTree[NIU_OK].ob_flags |= SELECTABLE;
						DoRedraw( Dialog, &Rect, NIU_OK, Global );
					}
				}
				else
				{
					if( DialogTree[NIU_OK].ob_flags & SELECTABLE )
					{
						DialogTree[NIU_OK].ob_state |= DISABLED;
						DialogTree[NIU_OK].ob_flags &= ~SELECTABLE;
						DoRedraw( Dialog, &Rect, NIU_OK, Global );
					}
				}
				break;
			}
		}
	}
	else
	{
		IRC_SESSION	*IrcSession = ( IRC_SESSION * ) (( DIALOG_DATA *) UserData)->UserData;
		switch( Obj )
		{
			case	NIU_OK:
			{
				BYTE	Puf[512];
				if( !strcmp( DialogTree[NIU_NICKNAME].ob_spec.free_string, IrcSession->Irc->Nickname ))
				{
					free( IrcSession->Irc->Nickname );
					IrcSession->Irc->Nickname = strdup( DialogTree[NIU_NEW].ob_spec.tedinfo->te_ptext );
					sprintf( Puf, "/NICK %s", DialogTree[NIU_NEW].ob_spec.tedinfo->te_ptext );
					strcat( Puf, "" );
				}
				else
				{
					sprintf( Puf, "/NICK %s", DialogTree[NIU_NEW].ob_spec.tedinfo->te_ptext );
					strcat( Puf, "" );
				}
				SendMessage( IrcSession, GenerateMessage( Puf, NULL, IrcSession, Global ), Global );
				break;
			}
			case	NIU_CANCEL:
			{
				if( !strcmp( DialogTree[NIU_NICKNAME].ob_spec.free_string, IrcSession->Irc->Nickname ))
				{
			  		CloseSessionAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
					CloseIrcSessionWindow( IrcSession, Global );
					return( 0 );
				}
				break;
			}
		}
  		CloseSessionAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
		return( 0 );
	}
	return( 1 );
}
static WORD HndlClsNiuDialog( void *DialogData, WORD Global[15] )
{
	FreeTree((( DIALOG_DATA *) DialogData)->Tree );
	free( DialogData );
	return( E_OK );
}

/* NnDialog ================================================================= */

WORD	NnDialog( IRC_SESSION *IrcSession, WORD Global[15] )
{
	IRC	*Irc = IrcSession->Irc;
	DIALOG_DATA		*DialogData;

	if( TreeAddr[NN][NN_NEW].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
		InitScrlted( &TreeAddr[NN][NN_NEW], isScroll, &NnXted, NnTxt, NnTmplt, EDITLEN );

	if(( DialogData = malloc( sizeof( DIALOG_DATA ))) == NULL )
		return( ENSMEM );

	DialogData->Dialog = NULL;
	DialogData->HndlDdDialog = NULL;
	DialogData->HndlClsDialog = HndlClsNnDialog;
	DialogData->HndlMesagDialog = NULL;
	DialogData->HndlTimerDialog = NULL;
	DialogData->HndlEditDialog = NULL;
	DialogData->HndlHelpDialog = NULL;
	DialogData->HndlCheckDialog = HndlCheckDialogWIrc;
	DialogData->UserData = IrcSession;
	DialogData->TreeIndex = NN;

	if(( DialogData->Tree = CopyTree( TreeAddr[NN] )) == NULL )
	{
		free( DialogData );
		return( ENSMEM );
	}

	DialogData->Tree[NN_OK].ob_state |= DISABLED;
	DialogData->Tree[NN_OK].ob_flags &= ~SELECTABLE;

	if( OpenDialogX( IrcSession->IrcChannel->ChatWindow->Title, WIN_ALERT_WINDOW, NAME + MOVER, -1, -1, HandleNnDialog, DialogData, Global ) != E_OK )
	{
		FreeTree( DialogData->Tree );
		free( DialogData );
		return( ERROR );
	}
	return( MT_wdlg_get_handle( DialogData->Dialog, Global ));
}

static WORD cdecl	HandleNnDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_EDIT:
			{
				WORD	a, b;
				if((( Events->kstate & KsCONTROL ) || ( Events->kstate & KsALT )) && isMenuKey( Events->key, &a, &b ))
					return( 0 );
				break;
			}
			case	HNDL_CLSD:
				if( Events->msg[4] == WIN_CLOSE_WITHOUT_DEMAND )
				{
					CloseSessionAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
					return( 0 );
				}
				else
					return( 1 );
			case	HNDL_EDDN:
			{
				if( strlen( DialogTree[NN_NEW].ob_spec.tedinfo->te_ptext ))
				{
					if( DialogTree[NN_OK].ob_state & DISABLED )
					{
						DialogTree[NN_OK].ob_state &= ~DISABLED;
						DialogTree[NN_OK].ob_flags |= SELECTABLE;
						DoRedraw( Dialog, &Rect, NN_OK, Global );
					}
				}
				else
				{
					if( DialogTree[NN_OK].ob_flags & SELECTABLE )
					{
						DialogTree[NN_OK].ob_state |= DISABLED;
						DialogTree[NN_OK].ob_flags &= ~SELECTABLE;
						DoRedraw( Dialog, &Rect, NN_OK, Global );
					}
				}
				break;
			}
		}
	}
	else
	{
		IRC_SESSION	*IrcSession = ( IRC_SESSION * ) (( DIALOG_DATA *) UserData)->UserData;
		switch( Obj )
		{
			case	NN_OK:
			{
				BYTE	Puf[512];
				sprintf( Puf, "/NICK %s", DialogTree[NN_NEW].ob_spec.tedinfo->te_ptext );
				strcat( Puf, "" );
				SendMessage( IrcSession, GenerateMessage( Puf, NULL, IrcSession, Global ), Global );
				break;
			}
			case	NN_CANCEL:
				break;
		}
		
		CloseSessionAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
		return( 0 );
	}
	return( 1 );
}
static WORD HndlClsNnDialog( void *DialogData, WORD Global[15] )
{
	FreeTree((( DIALOG_DATA *) DialogData)->Tree );
	free( DialogData );
	return( E_OK );
}

/* OpDialog ================================================================= */

WORD	OpDialog( IRC_CHANNEL *IrcChannel, WORD Flag, WORD Global[15] )
{
	DIALOG_DATA		*DialogData;

	if( TreeAddr[OP][OP_NICK].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
		InitScrlted( &TreeAddr[OP][OP_NICK], isScroll, &OpXted, OpTxt, OpTmplt, EDITLEN );

	if(( DialogData = malloc( sizeof( DIALOG_DATA ))) == NULL )
		return( ENSMEM );

	DialogData->Dialog = NULL;
	DialogData->HndlDdDialog = NULL;
	DialogData->HndlClsDialog = HndlClsOpDialog;
	DialogData->HndlMesagDialog = NULL;
	DialogData->HndlTimerDialog = NULL;
	DialogData->HndlEditDialog = NULL;
	DialogData->HndlHelpDialog = NULL;
	DialogData->HndlCheckDialog = HndlCheckDialogWIrc;
	DialogData->UserData = IrcChannel;
	DialogData->TreeIndex = OP;

	if(( DialogData->Tree = CopyTree( TreeAddr[OP] )) == NULL )
	{
		free( DialogData );
		return( ENSMEM );
	}

	DialogData->Tree[OP_OK].ob_state |= DISABLED;
	DialogData->Tree[OP_OK].ob_flags &= ~SELECTABLE;

	DialogData->Tree[OP_OP].ob_flags |= HIDETREE;
	DialogData->Tree[OP_DEOP].ob_flags |= HIDETREE;
	DialogData->Tree[OP_VOICE].ob_flags |= HIDETREE;
	DialogData->Tree[OP_DEVOICE].ob_flags |= HIDETREE;
	if( Flag == OPDIALOG_OP )
		DialogData->Tree[OP_OP].ob_flags &= ~HIDETREE;
	else	if( Flag == OPDIALOG_DEOP )
		DialogData->Tree[OP_DEOP].ob_flags &= ~HIDETREE;
	else	if( Flag == OPDIALOG_VOICE )
		DialogData->Tree[OP_VOICE].ob_flags &= ~HIDETREE;
	else	if( Flag == OPDIALOG_DEVOICE )
		DialogData->Tree[OP_DEVOICE].ob_flags &= ~HIDETREE;

	if( OpenDialogX( IrcChannel->ChatWindow->Title, WIN_ALERT_WINDOW, NAME + MOVER, -1, -1, HandleOpDialog, DialogData, Global ) != E_OK )
	{
		FreeTree( DialogData->Tree );
		free( DialogData );
		return( ERROR );
	}
	return( MT_wdlg_get_handle( DialogData->Dialog, Global ));
}
static WORD cdecl	HandleOpDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_EDIT:
			{
				WORD	a, b;
				if((( Events->kstate & KsCONTROL ) || ( Events->kstate & KsALT )) && isMenuKey( Events->key, &a, &b ))
					return( 0 );
				break;
			}
			case	HNDL_CLSD:
				if( Events->msg[4] == WIN_CLOSE_WITHOUT_DEMAND )
				{
					CloseChannelAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
					return( 0 );
				}
				else
					return( 1 );
			case	HNDL_EDDN:
			{
				if( strlen( DialogTree[OP_NICK].ob_spec.tedinfo->te_ptext ))
				{
					if( DialogTree[OP_OK].ob_state & DISABLED )
					{
						DialogTree[OP_OK].ob_state &= ~DISABLED;
						DialogTree[OP_OK].ob_flags |= SELECTABLE;
						DoRedraw( Dialog, &Rect, OP_OK, Global );
					}
				}
				else
				{
					if( DialogTree[OP_OK].ob_flags & SELECTABLE )
					{
						DialogTree[OP_OK].ob_state |= DISABLED;
						DialogTree[OP_OK].ob_flags &= ~SELECTABLE;
						DoRedraw( Dialog, &Rect, OP_OK, Global );
					}
				}
				break;
			}
		}
	}
	else
	{
		switch( Obj )
		{
			case	OP_OK:
			{
				BYTE	Puf[512];
				IRC_CHANNEL	*IrcChannel = ( IRC_CHANNEL * )(( DIALOG_DATA *) UserData)->UserData;
				IRC_SESSION *IrcSession = IrcChannel->IrcSession;
				if( !( DialogTree[OP_OP].ob_flags & HIDETREE ))
					sprintf( Puf, "/MODE %s +o %s", IrcChannel->Name, DialogTree[OP_NICK].ob_spec.tedinfo->te_ptext );
				else	if( !( DialogTree[OP_DEOP].ob_flags & HIDETREE ))
					sprintf( Puf, "/MODE %s -o %s", IrcChannel->Name, DialogTree[OP_NICK].ob_spec.tedinfo->te_ptext );
				else	if( !( DialogTree[OP_VOICE].ob_flags & HIDETREE ))
					sprintf( Puf, "/MODE %s +v %s", IrcChannel->Name, DialogTree[OP_NICK].ob_spec.tedinfo->te_ptext );
				else	if( !( DialogTree[OP_DEVOICE].ob_flags & HIDETREE ))
					sprintf( Puf, "/MODE %s -v %s", IrcChannel->Name, DialogTree[OP_NICK].ob_spec.tedinfo->te_ptext );
				strcat( Puf, "" );
				SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
				break;
			}
			case	OP_CANCEL:
			{
			}
		}
		
		CloseChannelAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
		return( 0 );
	}
	return( 1 );
}
static WORD HndlClsOpDialog( void *DialogData, WORD Global[15] )
{
	FreeTree((( DIALOG_DATA *) DialogData)->Tree );
	free( DialogData );
	return( E_OK );
}

/* KickDialog =============================================================== */

WORD	KickDialog( IRC_CHANNEL *IrcChannel, WORD Flag, BYTE *Nickname, WORD Global[15] )
{
	DIALOG_DATA		*DialogData;

	if( TreeAddr[KICK][KICK_NICK].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
		InitScrlted( &TreeAddr[KICK][KICK_NICK], isScroll, &KickXted, KickTxt, KickTmplt, EDITLEN );
	if( TreeAddr[KICK][KICK_TEXT].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
		InitScrlted( &TreeAddr[KICK][KICK_TEXT], isScroll, &CommentXted, CommentTxt, CommentTmplt, EDITLEN );

	if(( DialogData = malloc( sizeof( DIALOG_DATA ))) == NULL )
		return( ENSMEM );

	DialogData->Dialog = NULL;
	DialogData->HndlDdDialog = NULL;
	DialogData->HndlClsDialog = HndlClsKickDialog;
	DialogData->HndlMesagDialog = NULL;
	DialogData->HndlTimerDialog = NULL;
	DialogData->HndlEditDialog = NULL;
	DialogData->HndlHelpDialog = NULL;
	DialogData->HndlCheckDialog = HndlCheckDialogWIrc;
	DialogData->UserData = IrcChannel;
	DialogData->TreeIndex = OP;

	if(( DialogData->Tree = CopyTree( TreeAddr[KICK] )) == NULL )
	{
		free( DialogData );
		return( ENSMEM );
	}

	if( !Nickname )
	{
		DialogData->Tree[KICK_OK].ob_state |= DISABLED;
		DialogData->Tree[KICK_OK].ob_flags &= ~SELECTABLE;
	}
	else
		strcpy( DialogData->Tree[KICK_NICK].ob_spec.tedinfo->te_ptext, Nickname );

	if( Flag == KICKDIALOG_KICK )
	{
		DialogData->Tree[KICK_BAN].ob_flags |= HIDETREE;
		DialogData->Tree[KICK_DEBAN].ob_flags |= HIDETREE;
		DialogData->Tree[KICK_BANKICK].ob_flags |= HIDETREE;
	}
	else	if( Flag == KICKDIALOG_BAN )
	{
		DialogData->Tree[KICK_KICK].ob_flags |= HIDETREE;
		DialogData->Tree[KICK_DEBAN].ob_flags |= HIDETREE;
		DialogData->Tree[KICK_BANKICK].ob_flags |= HIDETREE;
		DialogData->Tree[KICK_COMMENT].ob_flags |= HIDETREE;
	}
	else	if( Flag == KICKDIALOG_DEBAN )
	{
		DialogData->Tree[KICK_KICK].ob_flags |= HIDETREE;
		DialogData->Tree[KICK_BAN].ob_flags |= HIDETREE;
		DialogData->Tree[KICK_BANKICK].ob_flags |= HIDETREE;
		DialogData->Tree[KICK_COMMENT].ob_flags |= HIDETREE;
	}
	else	if( Flag == KICKDIALOG_BANKICK )
	{
		DialogData->Tree[KICK_KICK].ob_flags |= HIDETREE;
		DialogData->Tree[KICK_BAN].ob_flags |= HIDETREE;
		DialogData->Tree[KICK_DEBAN].ob_flags |= HIDETREE;
	}

	if( OpenDialogX( IrcChannel->ChatWindow->Title, WIN_ALERT_WINDOW, NAME + MOVER, -1, -1, HandleKickDialog, DialogData, Global ) != E_OK )
	{
		FreeTree( DialogData->Tree );
		free( DialogData );
		return( ERROR );
	}
	return( MT_wdlg_get_handle( DialogData->Dialog, Global ));
}
static WORD cdecl	HandleKickDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_EDIT:
			{
				WORD	a, b;
				if((( Events->kstate & KsCONTROL ) || ( Events->kstate & KsALT )) && isMenuKey( Events->key, &a, &b ))
					return( 0 );
				break;
			}
			case	HNDL_CLSD:
				if( Events->msg[4] == WIN_CLOSE_WITHOUT_DEMAND )
				{
					CloseChannelAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
					return( 0 );
				}
				else
					return( 1 );
			case	HNDL_EDDN:
			{
				if( strlen( DialogTree[KICK_NICK].ob_spec.tedinfo->te_ptext ))
				{
					if( DialogTree[KICK_OK].ob_state & DISABLED )
					{
						DialogTree[KICK_OK].ob_state &= ~DISABLED;
						DialogTree[KICK_OK].ob_flags |= SELECTABLE;
						DoRedraw( Dialog, &Rect, KICK_OK, Global );
					}
				}
				else
				{
					if( DialogTree[KICK_OK].ob_flags & SELECTABLE )
					{
						DialogTree[KICK_OK].ob_state |= DISABLED;
						DialogTree[KICK_OK].ob_flags &= ~SELECTABLE;
						DoRedraw( Dialog, &Rect, KICK_OK, Global );
					}
				}
				break;
			}
		}
	}
	else
	{
		switch( Obj )
		{
			case	KICK_OK:
			{
				BYTE	Puf[512];
				IRC_CHANNEL	*IrcChannel = ( IRC_CHANNEL * )(( DIALOG_DATA *) UserData)->UserData;
				IRC_SESSION *IrcSession = IrcChannel->IrcSession;

				if( !( DialogTree[KICK_BANKICK].ob_flags & HIDETREE ) || !( DialogTree[KICK_KICK].ob_flags & HIDETREE ))
				{
					sprintf( Puf, "/KICK %s %s", IrcChannel->Name, DialogTree[KICK_NICK].ob_spec.tedinfo->te_ptext );
					if( strlen( DialogTree[KICK_TEXT].ob_spec.tedinfo->te_ptext ))
					{
						strcat( Puf, " :" );
						strcat( Puf, DialogTree[KICK_TEXT].ob_spec.tedinfo->te_ptext );
					}
					strcat( Puf, "" );
					SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
				}
				if( !( DialogTree[KICK_BANKICK].ob_flags & HIDETREE ) || !( DialogTree[KICK_BAN].ob_flags & HIDETREE ))
				{
					sprintf( Puf, "/MODE %s +b %s", IrcChannel->Name, DialogTree[KICK_NICK].ob_spec.tedinfo->te_ptext );
					strcat( Puf, "" );
					SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
				}
				if( !( DialogTree[KICK_DEBAN].ob_flags & HIDETREE ))
				{
					sprintf( Puf, "/MODE %s -b %s", IrcChannel->Name, DialogTree[KICK_NICK].ob_spec.tedinfo->te_ptext );
					strcat( Puf, "" );
					SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
				}
				break;
			}
			case	KICK_CANCEL:
			{
			}
		}
		
		CloseChannelAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
		return( 0 );
	}
	return( 1 );
}
static WORD HndlClsKickDialog( void *DialogData, WORD Global[15] )
{
	FreeTree((( DIALOG_DATA *) DialogData)->Tree );
	free( DialogData );
	return( E_OK );
}

/* InviteDialog ============================================================= */

WORD	InviteDialog( IRC_CHANNEL *IrcChannel, BYTE *Nick, WORD Global[15] )
{
	DIALOG_DATA		*DialogData;

	if( TreeAddr[INVITE][INVITE_NICK].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
		InitScrlted( &TreeAddr[INVITE][INVITE_NICK], isScroll, &InviteNickXted, InviteNickTxt, InviteNickTmplt, EDITLEN );
	if( TreeAddr[INVITE][INVITE_CHANNEL].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
		InitScrlted( &TreeAddr[INVITE][INVITE_CHANNEL], isScroll, &InviteChannelXted, InviteChannelTxt, InviteChannelTmplt, EDITLEN );

	if(( DialogData = malloc( sizeof( DIALOG_DATA ))) == NULL )
		return( ENSMEM );

	DialogData->Dialog = NULL;
	DialogData->HndlDdDialog = NULL;
	DialogData->HndlClsDialog = HndlClsInviteDialog;
	DialogData->HndlMesagDialog = NULL;
	DialogData->HndlTimerDialog = NULL;
	DialogData->HndlEditDialog = NULL;
	DialogData->HndlHelpDialog = NULL;
	DialogData->HndlCheckDialog = HndlCheckDialogWIrc;
	DialogData->UserData = IrcChannel;
	DialogData->TreeIndex = INVITE;

	if(( DialogData->Tree = CopyTree( TreeAddr[INVITE] )) == NULL )
	{
		free( DialogData );
		return( ENSMEM );
	}

	if( Nick )
		strcpy( DialogData->Tree[INVITE_NICK].ob_spec.tedinfo->te_ptext, Nick );
	else	if( IrcChannel->Name )
		strcpy( DialogData->Tree[INVITE_CHANNEL].ob_spec.tedinfo->te_ptext, IrcChannel->Name );
	DialogData->Tree[INVITE_OK].ob_state |= DISABLED;
	DialogData->Tree[INVITE_OK].ob_flags &= ~SELECTABLE;

	if( OpenDialogX((( IRC_SESSION * ) IrcChannel->IrcSession )->IrcChannel->ChatWindow->Title, WIN_ALERT_WINDOW, NAME + MOVER, -1, -1, HandleInviteDialog, DialogData, Global ) != E_OK )
	{
		FreeTree( DialogData->Tree );
		free( DialogData );
		return( ERROR );
	}
	return( MT_wdlg_get_handle( DialogData->Dialog, Global ));
}
static WORD cdecl	HandleInviteDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_EDIT:
			{
				WORD	a, b;
				if((( Events->kstate & KsCONTROL ) || ( Events->kstate & KsALT )) && isMenuKey( Events->key, &a, &b ))
					return( 0 );
				break;
			}
			case	HNDL_CLSD:
				if( Events->msg[4] == WIN_CLOSE_WITHOUT_DEMAND )
				{
					CloseChannelAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
					return( 0 );
				}
				else
					return( 1 );
			case	HNDL_EDDN:
			{
				if( strlen( DialogTree[INVITE_NICK].ob_spec.tedinfo->te_ptext ) && strlen( DialogTree[INVITE_CHANNEL].ob_spec.tedinfo->te_ptext ))
				{
					if( DialogTree[INVITE_OK].ob_state & DISABLED )
					{
						DialogTree[INVITE_OK].ob_state &= ~DISABLED;
						DialogTree[INVITE_OK].ob_flags |= SELECTABLE;
						DoRedraw( Dialog, &Rect, INVITE_OK, Global );
					}
				}
				else
				{
					if( DialogTree[INVITE_OK].ob_flags & SELECTABLE )
					{
						DialogTree[INVITE_OK].ob_state |= DISABLED;
						DialogTree[INVITE_OK].ob_flags &= ~SELECTABLE;
						DoRedraw( Dialog, &Rect, INVITE_OK, Global );
					}
				}
				break;
			}
		}
	}
	else
	{
		switch( Obj )
		{
			case	INVITE_OK:
			{
				BYTE	Puf[512];
				IRC_CHANNEL	*IrcChannel = ( IRC_CHANNEL * )(( DIALOG_DATA *) UserData)->UserData;
				IRC_SESSION *IrcSession = IrcChannel->IrcSession;

				sprintf( Puf, "/INVITE %s %s", DialogTree[INVITE_NICK].ob_spec.tedinfo->te_ptext, DialogTree[INVITE_CHANNEL].ob_spec.tedinfo->te_ptext );
				strcat( Puf, "" );
				SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
				break;
			}
			case	INVITE_CANCEL:
			{
			}
		}
		
		CloseChannelAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
		return( 0 );
	}
	return( 1 );
}

static WORD HndlClsInviteDialog( void *DialogData, WORD Global[15] )
{
	FreeTree((( DIALOG_DATA *) DialogData)->Tree );
	free( DialogData );
	return( E_OK );
}

/* TopicDialog ============================================================== */

WORD	TopicDialog( IRC_CHANNEL *IrcChannel, WORD Global[15] )
{
	DIALOG_DATA		*DialogData;

	if( TreeAddr[TOPIC][TOPIC_TEXT].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
		InitScrlted( &TreeAddr[TOPIC][TOPIC_TEXT], isScroll, &TopicXted, TopicTxt, TopicTmplt, EDITLEN );

	if(( DialogData = malloc( sizeof( DIALOG_DATA ))) == NULL )
		return( ENSMEM );

	DialogData->Dialog = NULL;
	DialogData->HndlDdDialog = NULL;
	DialogData->HndlClsDialog = HndlClsTopicDialog;
	DialogData->HndlMesagDialog = NULL;
	DialogData->HndlTimerDialog = NULL;
	DialogData->HndlEditDialog = NULL;
	DialogData->HndlHelpDialog = NULL;
	DialogData->HndlCheckDialog = HndlCheckDialogWIrc;
	DialogData->UserData = IrcChannel;
	DialogData->TreeIndex = TOPIC;

	if(( DialogData->Tree = CopyTree( TreeAddr[TOPIC] )) == NULL )
	{
		free( DialogData );
		return( ENSMEM );
	}

	if( OpenDialogX( IrcChannel->ChatWindow->Title, WIN_ALERT_WINDOW, NAME + MOVER, -1, -1, HandleTopicDialog, DialogData, Global ) != E_OK )
	{
		FreeTree( DialogData->Tree );
		free( DialogData );
		return( ERROR );
	}
	return( MT_wdlg_get_handle( DialogData->Dialog, Global ));
}
static WORD cdecl	HandleTopicDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_EDIT:
			{
				WORD	a, b;
				if((( Events->kstate & KsCONTROL ) || ( Events->kstate & KsALT )) && isMenuKey( Events->key, &a, &b ))
					return( 0 );
				break;
			}
			case	HNDL_CLSD:
				if( Events->msg[4] == WIN_CLOSE_WITHOUT_DEMAND )
				{
					CloseChannelAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
					return( 0 );
				}
				else
					return( 1 );
		}
	}
	else
	{
		switch( Obj )
		{
			case	TOPIC_OK:
			{
				BYTE	Puf[512];
				IRC_CHANNEL	*IrcChannel = ( IRC_CHANNEL * )(( DIALOG_DATA *) UserData)->UserData;
				IRC_SESSION *IrcSession = IrcChannel->IrcSession;

				sprintf( Puf, "/TOPIC %s", DialogTree[TOPIC_TEXT].ob_spec.tedinfo->te_ptext );
				strcat( Puf, "" );
				SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
				break;
			}
			case	TOPIC_CANCEL:
			{
			}
		}
		CloseChannelAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
		return( 0 );
	}
	return( 1 );
}
static WORD HndlClsTopicDialog( void *DialogData, WORD Global[15] )
{
	FreeTree((( DIALOG_DATA *) DialogData)->Tree );
	free( DialogData );
	return( E_OK );
}

/* ========================================================================== */

WORD	CModeDialog( IRC_CHANNEL *IrcChannel, WORD Global[15] )
{
	DIALOG_DATA		*DialogData;

	if(( DialogData = malloc( sizeof( DIALOG_DATA ))) == NULL )
		return( ENSMEM );

	DialogData->Dialog = NULL;
	DialogData->HndlDdDialog = NULL;
	DialogData->HndlClsDialog = HndlClsCModeDialog;
	DialogData->HndlMesagDialog = NULL;
	DialogData->HndlTimerDialog = NULL;
	DialogData->HndlEditDialog = NULL;
	DialogData->HndlHelpDialog = NULL;
	DialogData->HndlCheckDialog = HndlCheckDialogWIrc;
	DialogData->UserData = IrcChannel;
	DialogData->TreeIndex = CMODE;

	if(( DialogData->Tree = CopyTree( TreeAddr[CMODE] )) == NULL )
	{
		free( DialogData );
		return( ENSMEM );
	}

	( IrcChannel->ChannelFlag & MODE_INVITE ) ? ( DialogData->Tree[CMODE_INVITE].ob_state |= SELECTED ) : ( DialogData->Tree[CMODE_NOTINVITE].ob_state |= SELECTED );
	( IrcChannel->ChannelFlag & MODE_MODERATED ) ? ( DialogData->Tree[CMODE_MOD].ob_state |= SELECTED ) : ( DialogData->Tree[CMODE_NOTMOD].ob_state |= SELECTED );
	( IrcChannel->ChannelFlag & MODE_PRIVATE ) ? ( DialogData->Tree[CMODE_PRIVAT].ob_state |= SELECTED ) : ( DialogData->Tree[CMODE_NOTPRIVAT].ob_state |= SELECTED );
	( IrcChannel->ChannelFlag & MODE_SECRET ) ? ( DialogData->Tree[CMODE_SECRET].ob_state |= SELECTED ) : ( DialogData->Tree[CMODE_NOTSECRET].ob_state |= SELECTED );
	( IrcChannel->ChannelFlag & MODE_TOPIC ) ? ( DialogData->Tree[CMODE_TOPIC].ob_state |= SELECTED ) : ( DialogData->Tree[CMODE_NOTTOPIC].ob_state |= SELECTED );
	( IrcChannel->ChannelFlag & MODE_MESSAGE ) ? ( DialogData->Tree[CMODE_MES].ob_state |= SELECTED ) : ( DialogData->Tree[CMODE_NOTMES].ob_state |= SELECTED );
	( IrcChannel->ChannelFlag & MODE_LIMIT ) ? ( DialogData->Tree[CMODE_LIMIT].ob_state |= SELECTED ) : ( DialogData->Tree[CMODE_NOTLIMIT].ob_state |= SELECTED );
	if( IrcChannel->ChannelFlag & MODE_LIMIT )
		sprintf( DialogData->Tree[CMODE_LIMIT_N].ob_spec.tedinfo->te_ptext, "%li", IrcChannel->ChannelLimit );
	else
		strcpy( DialogData->Tree[CMODE_LIMIT_N].ob_spec.tedinfo->te_ptext, "" );

	if( OpenDialogX( IrcChannel->ChatWindow->Title, WIN_ALERT_WINDOW, NAME + MOVER, -1, -1, HandleCModeDialog, DialogData, Global ) != E_OK )
	{
		FreeTree( DialogData->Tree );
		free( DialogData );
		return( ERROR );
	}
	return( MT_wdlg_get_handle( DialogData->Dialog, Global ));
}
static WORD cdecl	HandleCModeDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_EDDN:
			{
				if( strlen( DialogTree[CMODE_LIMIT_N].ob_spec.tedinfo->te_ptext ))
				{
					if( DialogTree[CMODE_OK].ob_state & DISABLED )
					{
						DialogTree[CMODE_OK].ob_state &= ~DISABLED;
						DialogTree[CMODE_OK].ob_flags |= SELECTABLE;
						DoRedraw( Dialog, &Rect, CMODE_OK, Global );
					}
				}
				else	if(( DialogTree[CMODE_LIMIT_SET].ob_state & SELECTED ) && ( DialogTree[CMODE_LIMIT].ob_state & SELECTED ))
				{
					if( !( DialogTree[CMODE_OK].ob_state & DISABLED ))
					{
						DialogTree[CMODE_OK].ob_state |= DISABLED;
						DialogTree[CMODE_OK].ob_flags &= ~SELECTABLE;
						DoRedraw( Dialog, &Rect, CMODE_OK, Global );
					}
				}
				break;
			}
			case	HNDL_EDIT:
			{
				WORD	a, b;
				if((( Events->kstate & KsCONTROL ) || ( Events->kstate & KsALT )) && isMenuKey( Events->key, &a, &b ))
					return( 0 );
				break;
			}
			case	HNDL_CLSD:
				if( Events->msg[4] == WIN_CLOSE_WITHOUT_DEMAND )
				{
					CloseChannelAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
					return( 0 );
				}
				else
					return( 1 );
		}
	}
	else
	{
		if( DialogTree[Obj].ob_type & 0x0100 )
		{
			StGuide_Action( DialogTree, CMODE, Global );
			return( 1 );
		}
		switch( Obj )
		{
			case	CMODE_LIMIT_SET:
			case	CMODE_LIMIT:
			case	CMODE_NOTLIMIT:
			{
				if( DialogTree[CMODE_LIMIT_SET].ob_state & SELECTED )
				{
					if(( DialogTree[CMODE_LIMIT].ob_state & SELECTED ) && !strlen( DialogTree[CMODE_LIMIT_N].ob_spec.tedinfo->te_ptext ))
					{
						if( !( DialogTree[CMODE_OK].ob_state & DISABLED ))
						{
							DialogTree[CMODE_OK].ob_state |= DISABLED;
							DialogTree[CMODE_OK].ob_flags &= ~SELECTABLE;
							DoRedraw( Dialog, &Rect, CMODE_OK, Global );
						}
					}
					if(( DialogTree[CMODE_NOTLIMIT].ob_state & SELECTED ) || strlen( DialogTree[CMODE_LIMIT_N].ob_spec.tedinfo->te_ptext ))
					{
						if( DialogTree[CMODE_OK].ob_state & DISABLED )
						{
							DialogTree[CMODE_OK].ob_state &= ~DISABLED;
							DialogTree[CMODE_OK].ob_flags |= SELECTABLE;
							DoRedraw( Dialog, &Rect, CMODE_OK, Global );
						}
					}
				}
				else
				{
					if( DialogTree[CMODE_OK].ob_state & DISABLED )
					{
						DialogTree[CMODE_OK].ob_state &= ~DISABLED;
						DialogTree[CMODE_OK].ob_flags |= SELECTABLE;
						DoRedraw( Dialog, &Rect, CMODE_OK, Global );
					}
				}
				return( 1 );
			}
			case	CMODE_OK:
			{
				BYTE	Puf[512], Mode[64];
				IRC_CHANNEL	*IrcChannel = ( IRC_CHANNEL * )(( DIALOG_DATA *) UserData)->UserData;
				IRC_SESSION *IrcSession = IrcChannel->IrcSession;

				strcpy( Mode, "" );
				if( DialogTree[CMODE_INVITE_SET].ob_state & SELECTED )
					( DialogTree[CMODE_INVITE].ob_state & SELECTED ) ? strcat( Mode, "+i" ) : strcat( Mode, "-i" );
				if( DialogTree[CMODE_MOD_SET].ob_state & SELECTED )
					( DialogTree[CMODE_MOD].ob_state & SELECTED ) ? strcat( Mode, "+m" ) : strcat( Mode, "-m" );
				if( DialogTree[CMODE_MES_SET].ob_state & SELECTED )
					( DialogTree[CMODE_MES].ob_state & SELECTED ) ? strcat( Mode, "+n" ) : strcat( Mode, "-n" );
				if( DialogTree[CMODE_PRIVAT_SET].ob_state & SELECTED )
					( DialogTree[CMODE_PRIVAT].ob_state & SELECTED ) ? strcat( Mode, "+p" ) : strcat( Mode, "-p" );
				if( DialogTree[CMODE_SECRET_SET].ob_state & SELECTED )
					( DialogTree[CMODE_SECRET].ob_state & SELECTED ) ? strcat( Mode, "+s" ) : strcat( Mode, "-s" );
				if( DialogTree[CMODE_TOPIC_SET].ob_state & SELECTED )
					( DialogTree[CMODE_TOPIC].ob_state & SELECTED ) ? strcat( Mode, "+t" ) : strcat( Mode, "-t" );
				if( DialogTree[CMODE_LIMIT_SET].ob_state & SELECTED )
				{
					( DialogTree[CMODE_LIMIT].ob_state & SELECTED ) ? strcat( Mode, "+l " ) : strcat( Mode, "-l" );
					if( DialogTree[CMODE_LIMIT].ob_state & SELECTED )
						strcat( Mode, DialogTree[CMODE_LIMIT_N].ob_spec.tedinfo->te_ptext );
				}

				sprintf( Puf, "/MODE %s %s", IrcChannel->Name, Mode );
				strcat( Puf, "" );
				SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
				break;
			}
		}
		CloseChannelAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
		return( 0 );
	}
	return( 1 );
}
static WORD HndlClsCModeDialog( void *DialogData, WORD Global[15] )
{
	FreeTree((( DIALOG_DATA *) DialogData)->Tree );
	free( DialogData );
	return( E_OK );
}

/* UModeDialog ============================================================== */

WORD	UModeDialog( IRC_SESSION *IrcSession, WORD Global[15] )
{
	DIALOG_DATA		*DialogData;

	if(( DialogData = malloc( sizeof( DIALOG_DATA ))) == NULL )
		return( ENSMEM );

	DialogData->Dialog = NULL;
	DialogData->HndlDdDialog = NULL;
	DialogData->HndlClsDialog = HndlClsUModeDialog;
	DialogData->HndlMesagDialog = NULL;
	DialogData->HndlTimerDialog = NULL;
	DialogData->HndlEditDialog = NULL;
	DialogData->HndlHelpDialog = NULL;
	DialogData->HndlCheckDialog = HndlCheckDialogWIrc;
	DialogData->UserData = IrcSession;
	DialogData->TreeIndex = UMODE;

	if(( DialogData->Tree = CopyTree( TreeAddr[UMODE] )) == NULL )
	{
		free( DialogData );
		return( ENSMEM );
	}

	( IrcSession->SessionFlag & MODE_INVISIBLE ) ? ( DialogData->Tree[UMODE_VISIBLE].ob_state |= SELECTED ) : ( DialogData->Tree[UMODE_NOTVISIBLE].ob_state |= SELECTED );
	( IrcSession->SessionFlag & MODE_NOTICE ) ? ( DialogData->Tree[UMODE_NOTICE].ob_state |= SELECTED ) : ( DialogData->Tree[UMODE_NOTNOTICE].ob_state |= SELECTED );
	( IrcSession->SessionFlag & MODE_WALLOPS ) ? ( DialogData->Tree[UMODE_WALLOPS].ob_state |= SELECTED ) : ( DialogData->Tree[UMODE_NOTWALLOPS].ob_state |= SELECTED );

	if( OpenDialogX( IrcSession->IrcChannel->ChatWindow->Title, WIN_ALERT_WINDOW, NAME + MOVER, -1, -1, HandleUModeDialog, DialogData, Global ) != E_OK )
	{
		FreeTree( DialogData->Tree );
		free( DialogData );
		return( ERROR );
	}
	return( MT_wdlg_get_handle( DialogData->Dialog, Global ));
}
static WORD cdecl	HandleUModeDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_EDIT:
			{
				WORD	a, b;
				if((( Events->kstate & KsCONTROL ) || ( Events->kstate & KsALT )) && isMenuKey( Events->key, &a, &b ))
					return( 0 );
				break;
			}
			case	HNDL_CLSD:
				if( Events->msg[4] == WIN_CLOSE_WITHOUT_DEMAND )
				{
					CloseSessionAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
					return( 0 );
				}
				else
					return( 1 );
		}
	}
	else
	{
		if( DialogTree[Obj].ob_type & 0x0100 )
		{
			StGuide_Action( DialogTree, CMODE, Global );
			return( 1 );
		}
		switch( Obj )
		{
			case	UMODE_OK:
			{
				BYTE	Puf[512], Mode[64];
				IRC_SESSION *IrcSession = ( IRC_SESSION * )(( DIALOG_DATA *) UserData)->UserData;

				strcpy( Mode, "" );
				if( DialogTree[UMODE_VISIBLE_SET].ob_state & SELECTED )
					( DialogTree[UMODE_VISIBLE].ob_state & SELECTED ) ? strcat( Mode, "+i" ) : strcat( Mode, "-i" );
				if( DialogTree[UMODE_NOTICE_SET].ob_state & SELECTED )
					( DialogTree[UMODE_NOTICE].ob_state & SELECTED ) ? strcat( Mode, "+s" ) : strcat( Mode, "-s" );
				if( DialogTree[UMODE_WALLOPS_SET].ob_state & SELECTED )
					( DialogTree[UMODE_WALLOPS].ob_state & SELECTED ) ? strcat( Mode, "+w" ) : strcat( Mode, "-w" );
				sprintf( Puf, "/MODE %s %s", IrcSession->Irc->Nickname, Mode );
				strcat( Puf, "" );
				SendMessage( IrcSession, GenerateMessage( Puf, NULL, IrcSession, Global ), Global );
				break;
			}
		}
		CloseSessionAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
		return( 0 );
	}
	return( 1 );
}
static WORD HndlClsUModeDialog( void *DialogData, WORD Global[15] )
{
	FreeTree((( DIALOG_DATA *) DialogData)->Tree );
	free( DialogData );
	return( E_OK );
}

/* AwayDialog =============================================================== */

WORD	AwayDialog( IRC_SESSION *IrcSession, WORD Global[15] )
{
	DIALOG_DATA		*DialogData;

	if( TreeAddr[AWAY][AWAY_TEXT].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
		InitScrlted( &TreeAddr[AWAY][AWAY_TEXT], isScroll, &AwayXted, AwayTxt, AwayTmplt, EDITLEN );

	if(( DialogData = malloc( sizeof( DIALOG_DATA ))) == NULL )
		return( ENSMEM );

	DialogData->Dialog = NULL;
	DialogData->HndlDdDialog = NULL;
	DialogData->HndlClsDialog = HndlClsTopicDialog;
	DialogData->HndlMesagDialog = NULL;
	DialogData->HndlTimerDialog = NULL;
	DialogData->HndlEditDialog = NULL;
	DialogData->HndlHelpDialog = NULL;
	DialogData->HndlCheckDialog = HndlCheckDialogWIrc;
	DialogData->UserData = IrcSession;
	DialogData->TreeIndex = AWAY;

	if(( DialogData->Tree = CopyTree( TreeAddr[AWAY] )) == NULL )
	{
		free( DialogData );
		return( ENSMEM );
	}
	
	if( IrcSession->Away )
		strcpy( DialogData->Tree[AWAY_TEXT].ob_spec.tedinfo->te_ptext, IrcSession->Away );

	if( OpenDialogX( IrcSession->IrcChannel->ChatWindow->Title, WIN_ALERT_WINDOW, NAME + MOVER, -1, -1, HandleAwayDialog, DialogData, Global ) != E_OK )
	{
		FreeTree( DialogData->Tree );
		free( DialogData );
		return( ERROR );
	}
	return( MT_wdlg_get_handle( DialogData->Dialog, Global ));
}
static WORD cdecl	HandleAwayDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_EDIT:
			{
				WORD	a, b;
				if((( Events->kstate & KsCONTROL ) || ( Events->kstate & KsALT )) && isMenuKey( Events->key, &a, &b ))
					return( 0 );
				break;
			}
			case	HNDL_CLSD:
				if( Events->msg[4] == WIN_CLOSE_WITHOUT_DEMAND )
				{
					CloseSessionAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
					return( 0 );
				}
				else
					return( 1 );
		}
	}
	else
	{
		switch( Obj )
		{
			case	AWAY_OK:
			{
				BYTE	Puf[512];
				IRC_SESSION *IrcSession = ( IRC_SESSION * )(( DIALOG_DATA *) UserData)->UserData;
				sprintf( Puf, "/AWAY %s", DialogTree[AWAY_TEXT].ob_spec.tedinfo->te_ptext );
				strcat( Puf, "" );
				SendMessage( IrcSession, GenerateMessage( Puf, NULL, IrcSession, Global ), Global );
				break;
			}
		}
		CloseSessionAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
		return( 0 );
	}
	return( 1 );
}
static WORD HndlClsAwayDialog( void *DialogData, WORD Global[15] )
{
	FreeTree((( DIALOG_DATA *) DialogData)->Tree );
	free( DialogData );
	return( E_OK );
}

/* InvitedDialog ============================================================ */
WORD	InivtedDialog( IRC_SESSION *IrcSession, BYTE *Nick, BYTE *Channel, WORD Global[15] )
{
	DIALOG_DATA		*DialogData;
	if(( DialogData = malloc( sizeof( DIALOG_DATA ))) == NULL )
		return( ENSMEM );

	DialogData->Dialog = NULL;
	DialogData->HndlDdDialog = NULL;
	DialogData->HndlClsDialog = HndlClsInvitedDialog;
	DialogData->HndlMesagDialog = NULL;
	DialogData->HndlTimerDialog = NULL;
	DialogData->HndlEditDialog = NULL;
	DialogData->HndlHelpDialog = NULL;
	DialogData->HndlCheckDialog = HndlCheckDialogWIrc;
	DialogData->UserData = IrcSession;
	DialogData->TreeIndex = INVITED;

	if(( DialogData->Tree = CopyTree( TreeAddr[INVITED] )) == NULL )
	{
		free( DialogData );
		return( ENSMEM );
	}
	
	strcpy( DialogData->Tree[INVITED_NICK].ob_spec.free_string, Nick );
	strcpy( DialogData->Tree[INVITED_CHANNEL].ob_spec.free_string, Channel );

	if( OpenDialogX( IrcSession->IrcChannel->ChatWindow->Title, WIN_ALERT_WINDOW, NAME + MOVER, -1, -1, HandleInvitedDialog, DialogData, Global ) != E_OK )
	{
		FreeTree( DialogData->Tree );
		free( DialogData );
		return( ERROR );
	}
	return( MT_wdlg_get_handle( DialogData->Dialog, Global ));
}
static WORD cdecl	HandleInvitedDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_EDIT:
			{
				WORD	a, b;
				if((( Events->kstate & KsCONTROL ) || ( Events->kstate & KsALT )) && isMenuKey( Events->key, &a, &b ))
					return( 0 );
				break;
			}
			case	HNDL_CLSD:
				if( Events->msg[4] == WIN_CLOSE_WITHOUT_DEMAND )
				{
					CloseSessionAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
					return( 0 );
				}
				else
					return( 1 );
		}
	}
	else
	{
		Obj &= 0x7fff;
		if( HandleWDialogIcon( &Obj, Dialog, Global ))
			return( 1 );

		if( DialogTree[Obj].ob_state & DISABLED )
		{
			DialogTree[Obj].ob_state &= ~SELECTED;
			return( 1 );
		}
		switch( Obj )
		{
			case	INVITED_OK:
			{
				BYTE	Puf[512];
				IRC_SESSION *IrcSession = ( IRC_SESSION * )(( DIALOG_DATA *) UserData)->UserData;
				sprintf( Puf, "/JOIN %s", DialogTree[INVITED_CHANNEL].ob_spec.free_string );
				strcat( Puf, "" );
				SendMessage( IrcSession, GenerateMessage( Puf, NULL, IrcSession, Global ), Global );
				break;
			}
		}
		CloseSessionAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
		return( 0 );
	}
	return( 1 );
}
static WORD HndlClsInvitedDialog( void *DialogData, WORD Global[15] )
{
	FreeTree((( DIALOG_DATA *) DialogData)->Tree );
	free( DialogData );
	return( E_OK );
}

/* ========================================================================== */
WORD	MsgDialog( IRC_CHANNEL *IrcChannel, WORD Flag, WORD Global[15] )
{
	DIALOG_DATA		*DialogData;
	if(( DialogData = malloc( sizeof( DIALOG_DATA ))) == NULL )
		return( ENSMEM );

	if( TreeAddr[MSG][MSG_NICK].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
		InitScrlted( &TreeAddr[MSG][MSG_NICK], isScroll, &MsgXted, MsgTxt, MsgTmplt, EDITLEN );

	DialogData->Dialog = NULL;
	DialogData->HndlDdDialog = NULL;
	DialogData->HndlClsDialog = HndlClsMsgDialog;
	DialogData->HndlMesagDialog = NULL;
	DialogData->HndlTimerDialog = NULL;
	DialogData->HndlEditDialog = NULL;
	DialogData->HndlHelpDialog = NULL;
	DialogData->HndlCheckDialog = HndlCheckDialogWIrc;
	DialogData->UserData = IrcChannel;
	DialogData->TreeIndex = MSG;

	if(( DialogData->Tree = CopyTree( TreeAddr[MSG] )) == NULL )
	{
		free( DialogData );
		return( ENSMEM );
	}
	
	DialogData->Tree[MSG_OK].ob_state |= DISABLED;
	DialogData->Tree[MSG_OK_I].ob_state |= DISABLED;
	DialogData->Tree[MSG_OK].ob_flags &= ~SELECTABLE;

	if( Flag == MSGDIALOG_DCCCHAT )
		DialogData->Tree[MSG_CHAT].ob_flags |= HIDETREE;
	else	if( Flag == MSGDIALOG_CHAT )
		DialogData->Tree[MSG_DCCCHAT].ob_flags |= HIDETREE;
	
	if( OpenDialogX((( IRC_SESSION * ) IrcChannel->IrcSession )->IrcChannel->ChatWindow->Title, WIN_ALERT_WINDOW, NAME + MOVER, -1, -1, HandleMsgDialog, DialogData, Global ) != E_OK )
	{
		FreeTree( DialogData->Tree );
		free( DialogData );
		return( ERROR );
	}
	return( MT_wdlg_get_handle( DialogData->Dialog, Global ));
}
static WORD cdecl	HandleMsgDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_EDDN:
			{
				if( strlen( DialogTree[MSG_NICK].ob_spec.tedinfo->te_ptext ))
				{
					if( DialogTree[MSG_OK].ob_state & DISABLED )
					{
						DialogTree[MSG_OK].ob_state &= ~DISABLED;
						DialogTree[MSG_OK_I].ob_state &= ~DISABLED;
						DialogTree[MSG_OK].ob_flags |= SELECTABLE;
						DoRedraw( Dialog, &Rect, MSG_OK, Global );
					}
				}
				else
				{
					if( DialogTree[MSG_OK].ob_flags & SELECTABLE )
					{
						DialogTree[MSG_OK].ob_state |= DISABLED;
						DialogTree[MSG_OK_I].ob_state |= DISABLED;
						DialogTree[MSG_OK].ob_flags &= ~SELECTABLE;
						DoRedraw( Dialog, &Rect, MSG_OK, Global );
					}
				}
				break;
			}
			case	HNDL_EDIT:
			{
				WORD	a, b;
				if((( Events->kstate & KsCONTROL ) || ( Events->kstate & KsALT )) && isMenuKey( Events->key, &a, &b ))
					return( 0 );
				break;
			}
			case	HNDL_CLSD:
				if( Events->msg[4] == WIN_CLOSE_WITHOUT_DEMAND )
				{
					CloseChannelAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
					return( 0 );
				}
				else
					return( 1 );
		}
	}
	else
	{
		Obj &= 0x7fff;
		if( HandleWDialogIcon( &Obj, Dialog, Global ))
			return( 1 );

		if( DialogTree[Obj].ob_state & DISABLED )
		{
			DialogTree[Obj].ob_state &= ~SELECTED;
			return( 1 );
		}
		switch( Obj )
		{
			case	MSG_OK:
			{
				IRC_CHANNEL	*IrcChannel = ( IRC_CHANNEL * )(( DIALOG_DATA *) UserData)->UserData;
				IRC_SESSION *IrcSession = ( IRC_SESSION * ) IrcChannel->IrcSession;
				if( !( DialogTree[MSG_CHAT].ob_flags & HIDETREE ))
				{
					if( OpenIrcChannel( IrcSession, DialogTree[MSG_NICK].ob_spec.tedinfo->te_ptext, Global ) != E_OK )
						MT_form_alert( 1, TreeAddr[ALERTS][MEMORY].ob_spec.free_string, Global );
				}
				else	if( !( DialogTree[MSG_DCCCHAT].ob_flags & HIDETREE ))
				{
					if( OpenDccChatSession( IrcSession, DialogTree[MSG_NICK].ob_spec.tedinfo->te_ptext, Global ) != E_OK )
						MT_form_alert( 1, TreeAddr[ALERTS][MEMORY].ob_spec.free_string, Global );
				}
				break;
			}
		}
		CloseChannelAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
		return( 0 );
	}
	return( 1 );
}
static WORD HndlClsMsgDialog( void *DialogData, WORD Global[15] )
{
	FreeTree((( DIALOG_DATA *) DialogData)->Tree );
	free( DialogData );
	return( E_OK );
}

WORD	InfoDialog( CHAT_WINDOW *ChatWindow, WORD Global[15] )
{
	DIALOG_DATA		*DialogData;
	if(( DialogData = malloc( sizeof( DIALOG_DATA ))) == NULL )
		return( ENSMEM );

	DialogData->Dialog = NULL;
	DialogData->HndlDdDialog = NULL;
	DialogData->HndlClsDialog = HndlClsInfoDialog;
	DialogData->HndlMesagDialog = NULL;
	DialogData->HndlTimerDialog = NULL;
	DialogData->HndlEditDialog = NULL;
	DialogData->HndlHelpDialog = NULL;
	DialogData->HndlCheckDialog = HndlCheckDialogWIrc;
	DialogData->UserData = ChatWindow;
	DialogData->TreeIndex = INFOD;

	if(( DialogData->Tree = CopyTree( TreeAddr[INFOD] )) == NULL )
	{
		free( DialogData );
		return( ENSMEM );
	}

	sprintf( DialogData->Tree[INFOD_NLINES].ob_spec.tedinfo->te_ptext, "%li", mt_text_get_pufline( ChatWindow->DialogData->Tree, WCHAT_OUTPUT, Global ));
	if( ChatWindow->LogFile )
		DialogData->Tree[INFOD_LOG].ob_state |= SELECTED;

	if( (( IRC_SESSION * )((IRC_CHANNEL *) ChatWindow->UserData )->IrcSession )->Irc->PingPong )
		DialogData->Tree[INFOD_PINGPONG].ob_state |= SELECTED;
	if( (( IRC_SESSION * )((IRC_CHANNEL *) ChatWindow->UserData )->IrcSession )->Irc->CtcpReply )
		DialogData->Tree[INFOD_CTCP].ob_state |= SELECTED;
		
	if( OpenDialogX( ChatWindow->Title, WIN_ALERT_WINDOW, NAME + MOVER, -1, -1, HandleInfoDialog, DialogData, Global ) != E_OK )
	{
		FreeTree( DialogData->Tree );
		free( DialogData );
		return( ERROR );
	}
	return( MT_wdlg_get_handle( DialogData->Dialog, Global ));
}
static WORD cdecl	HandleInfoDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_EDIT:
			{
				WORD	a, b;
				if((( Events->kstate & KsCONTROL ) || ( Events->kstate & KsALT )) && isMenuKey( Events->key, &a, &b ))
					return( 0 );
				break;
			}
			case	HNDL_CLSD:
				if( Events->msg[4] == WIN_CLOSE_WITHOUT_DEMAND )
				{
					CloseChannelAlertIrc((( CHAT_WINDOW * )(( DIALOG_DATA *) UserData)->UserData )->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
					return( 0 );
				}
				else
					return( 1 );
		}
	}
	else
	{
		Obj &= 0x7fff;
		if( HandleWDialogIcon( &Obj, Dialog, Global ))
			return( 1 );

		if(( DialogTree[Obj].ob_type & 0x0100 ) == 0x0100 )
		{
			StGuide_Action( DialogTree, INFOD, Global );
			return( 1 );
		}
		if( DialogTree[Obj].ob_state & DISABLED )
		{
			DialogTree[Obj].ob_state &= ~SELECTED;
			return( 1 );
		}
		switch( Obj )
		{
			case	INFOD_OK:
			{
				CHAT_WINDOW	*ChatWindow = ( CHAT_WINDOW * )(( DIALOG_DATA *) UserData)->UserData;
				IRC_CHANNEL *IrcChannel = ( IRC_CHANNEL * ) ChatWindow->UserData;
				IRC_SESSION *IrcSession = IrcChannel->IrcSession;
				if(( DialogTree[INFOD_LOG].ob_state & SELECTED ) && !ChatWindow->LogFile )
				{
					BYTE	*Dirname, *Filename;
					if( IrcChannel->Name )
					{
						Dirname = "Channel";
						Filename = IrcChannel->Name;
					}
					else
					{
						Dirname = IrcSession->Irc->Host;
						Filename = "Console";
					}
					if(( ChatWindow->LogFile = OpenLog( Dirname, Filename )) == NULL )
						MT_form_alert( 1, TreeAddr[ALERTS][ALERT_ERROR_LOG].ob_spec.free_string, Global );
				}
				if( !( DialogTree[INFOD_LOG].ob_state & SELECTED ) && ChatWindow->LogFile )
				{
					CloseLog( ChatWindow->LogFile );
					ChatWindow->LogFile = NULL;
				}
				mt_text_set_pufline( ChatWindow->DialogData->Tree, WCHAT_OUTPUT, atol( DialogTree[INFOD_NLINES].ob_spec.tedinfo->te_ptext ), Global );
				if( DialogTree[INFOD_PINGPONG].ob_state & SELECTED )
					IrcSession->Irc->PingPong = 1;
				else
					IrcSession->Irc->PingPong = 0;
				if( DialogTree[INFOD_CTCP].ob_state & SELECTED )
					IrcSession->Irc->CtcpReply = 1;
				else
					IrcSession->Irc->CtcpReply = 0;
				break;
			}
			case	INFOD_CANCEL:
				break;
		}
		CloseChannelAlertIrc((( CHAT_WINDOW * )(( DIALOG_DATA *) UserData)->UserData )->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
		return( 0 );
	}
	return( 1 );
}
static WORD HndlClsInfoDialog( void *DialogData, WORD Global[15] )
{
	FreeTree((( DIALOG_DATA *) DialogData)->Tree );
	free( DialogData );
	return( E_OK );
}

/* ========================================================================== */

WORD	CtcpDialog( IRC_CHANNEL *IrcChannel, BYTE *Nickname, WORD Global[15] )
{
	DIALOG_DATA		*DialogData;

	if( TreeAddr[CTCP][CTCP_NICKNAME].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
		InitScrlted( &TreeAddr[CTCP][CTCP_NICKNAME], isScroll, &CtcpNickXted, CtcpNickTxt, CtcpNickTmplt, EDITLEN );
	if( TreeAddr[CTCP][CTCP_CMD].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
		InitScrlted( &TreeAddr[CTCP][CTCP_CMD], isScroll, &CtcpCmdXted, CtcpCmdTxt, CtcpCmdTmplt, EDITLEN );

	if(( DialogData = malloc( sizeof( DIALOG_DATA ))) == NULL )
		return( ENSMEM );

	DialogData->Dialog = NULL;
	DialogData->HndlDdDialog = NULL;
	DialogData->HndlClsDialog = HndlClsCtcpDialog;
	DialogData->HndlMesagDialog = NULL;
	DialogData->HndlTimerDialog = NULL;
	DialogData->HndlEditDialog = NULL;
	DialogData->HndlHelpDialog = NULL;
	DialogData->HndlCheckDialog = HndlCheckDialogWIrc;
	DialogData->UserData = IrcChannel;
	DialogData->TreeIndex = CTCP;

	if(( DialogData->Tree = CopyTree( TreeAddr[CTCP] )) == NULL )
	{
		free( DialogData );
		return( ENSMEM );
	}

	DialogData->Tree[CTCP_OK].ob_state |= DISABLED;
	DialogData->Tree[CTCP_OK].ob_flags &= ~SELECTABLE;
	if( Nickname )
		strcpy( DialogData->Tree[CTCP_NICKNAME].ob_spec.tedinfo->te_ptext, Nickname );

	if( OpenDialogX((( IRC_SESSION * ) IrcChannel->IrcSession )->IrcChannel->ChatWindow->Title, WIN_ALERT_WINDOW, NAME + MOVER, -1, -1, HandleCtcpDialog, DialogData, Global ) != E_OK )
	{
		FreeTree( DialogData->Tree );
		free( DialogData );
		return( ERROR );
	}
	return( MT_wdlg_get_handle( DialogData->Dialog, Global ));
}
static WORD cdecl	HandleCtcpDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_EDIT:
			{
				WORD	a, b;
				if((( Events->kstate & KsCONTROL ) || ( Events->kstate & KsALT )) && isMenuKey( Events->key, &a, &b ))
					return( 0 );
				break;
			}
			case	HNDL_CLSD:
				if( Events->msg[4] == WIN_CLOSE_WITHOUT_DEMAND )
				{
					CloseChannelAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
					return( 0 );
				}
				else
					return( 1 );
			case	HNDL_EDDN:
			{
				if( strlen( DialogTree[CTCP_NICKNAME].ob_spec.tedinfo->te_ptext ) && strlen( DialogTree[CTCP_CMD].ob_spec.tedinfo->te_ptext ))
				{
					if( DialogTree[CTCP_OK].ob_state & DISABLED )
					{
						DialogTree[CTCP_OK].ob_state &= ~DISABLED;
						DialogTree[CTCP_OK].ob_flags |= SELECTABLE;
						DoRedraw( Dialog, &Rect, CTCP_OK, Global );
					}
				}
				else
				{
					if( DialogTree[CTCP_OK].ob_flags & SELECTABLE )
					{
						DialogTree[CTCP_OK].ob_state |= DISABLED;
						DialogTree[CTCP_OK].ob_flags &= ~SELECTABLE;
						DoRedraw( Dialog, &Rect, CTCP_OK, Global );
					}
				}
				break;
			}
		}
	}
	else
	{
		switch( Obj )
		{
			case	CTCP_POPUP:
			{
				WORD	Ret, x, y;
				MT_objc_offset( DialogTree, CTCP_CMD, &x, &y, Global );
				if(( Ret = Popup( TreeAddr[POPUP_CTCP], 0, x, y, Global )) > 0 )
				{
					strcpy( DialogTree[CTCP_CMD].ob_spec.tedinfo->te_ptext, CtcpCmd[Ret-1] );
					DoRedraw( Dialog, &Rect, CTCP_CMD, Global );
					if( strlen( DialogTree[CTCP_NICKNAME].ob_spec.tedinfo->te_ptext ))
					{
						if( DialogTree[CTCP_OK].ob_state & DISABLED )
						{
							DialogTree[CTCP_OK].ob_state &= ~DISABLED;
							DialogTree[CTCP_OK].ob_flags |= SELECTABLE;
							DoRedraw( Dialog, &Rect, CTCP_OK, Global );
						}
					}
				}
				DialogTree[Obj].ob_state &= ~SELECTED;
				DoRedraw( Dialog, &Rect, Obj, Global );
				break;
			}
			case	CTCP_OK:
			{
				BYTE	Puf[512];
				IRC_CHANNEL	*IrcChannel = ( IRC_CHANNEL * )(( DIALOG_DATA *) UserData)->UserData;
				IRC_SESSION *IrcSession = ( IRC_SESSION * ) IrcChannel->IrcSession;
				sprintf( Puf, "/CTCP %s %s", DialogTree[CTCP_NICKNAME].ob_spec.tedinfo->te_ptext, DialogTree[CTCP_CMD].ob_spec.tedinfo->te_ptext );
				strcat( Puf, "" );
				SendMessage( IrcSession, GenerateMessage( Puf, NULL, IrcSession, Global ), Global );
			}
			case	CTCP_CANCEL:
			{
				CloseChannelAlertIrc((( DIALOG_DATA *) UserData)->UserData, 0, MT_wdlg_get_handle( Dialog, Global ), Global );
				return( 0 );
			}
		}
		
	}
	return( 1 );
}
static WORD HndlClsCtcpDialog( void *DialogData, WORD Global[15] )
{
	FreeTree((( DIALOG_DATA *) DialogData)->Tree );
	free( DialogData );
	return( E_OK );
}

/* ========================================================================== */

WORD	HndlCheckDialogWIrc( void *DialogData, EVNT *Events, WORD Global[15] )
{
	WORD	WinId = MT_wdlg_get_handle((( DIALOG_DATA * ) DialogData )->Dialog, Global );
	WORD	Type = GetTypeWindow( WinId );
	WORD	Ret = E_OK, SessionWinId = 0, ChannelWinId = 0;

	IRC_SESSION	*IrcSession;
	IRC_CHANNEL	*IrcChannel;

	switch( Type )
	{
		case	WIN_CHAT_IRC_CONSOLE:
		case	WIN_CHAT_IRC_CHANNEL:
		case	WIN_CHAT_IRC_USER:
		{
			CHAT_WINDOW	*ChatWindow = ( CHAT_WINDOW *)(( DIALOG_DATA * ) DialogData )->UserData;
			IrcChannel = ( IRC_CHANNEL * ) ChatWindow->UserData;
			break;
		}
		case	WIN_CHANNEL_IRC:
		{
			CHANNEL_WINDOW	*ChannelWindow = ( CHANNEL_WINDOW *)(( DIALOG_DATA * ) DialogData)->UserData;
			IrcChannel = ChannelWindow->IrcChannel;
			break;
		}
		case	WIN_NAMES_IRC:
		{
			NAMES_WINDOW	*NamesWindow = ( NAMES_WINDOW *)(( DIALOG_DATA * ) DialogData)->UserData;
			IrcChannel = NamesWindow->IrcChannel;
			break;
		}
		case	WIN_ALERT_WINDOW:
		{
		}
		default:
			return( E_OK );
	}
	IrcSession = IrcChannel->IrcSession;

	if( IrcSession->ModWin )
		SessionWinId = IrcSession->ModWin->WinId;
	if( IrcChannel->ModWin )
		ChannelWinId = IrcChannel->ModWin->WinId;

	if( SessionWinId || ChannelWinId )
	{
		WORD	TopWinId, TopAppId, Dummy;
		MT_wind_get( 0, WF_TOP, &TopWinId, &TopAppId, &Dummy, &Dummy, Global );
		if( SessionWinId )
		{
			IRC_CHANNEL	*Tmp = IrcSession->IrcChannel;
			if( TopWinId == Tmp->ChatWindow->WinId || ( Tmp->ListWindow && TopWinId == (( CHANNEL_WINDOW * ) Tmp->ListWindow )->WinId ))
				MT_wind_set_int( SessionWinId, WF_TOP, 0, Global );
			else
			{
				IrcChannel = Tmp->next;
				while( Tmp )
				{
					if( TopWinId == Tmp->ChatWindow->WinId || ( Tmp->ListWindow && TopWinId == (( CHANNEL_WINDOW * ) Tmp->ListWindow )->WinId ))
					{
						MT_wind_set_int( SessionWinId, WF_TOP, 0, Global );
						break;
					}
					Tmp = Tmp->next;
				}
			}
		}
		else	if( ChannelWinId )
		{
			if( TopWinId == IrcChannel->ChatWindow->WinId || ( IrcChannel->ListWindow && TopWinId == (( NAMES_WINDOW * ) IrcChannel->ListWindow )->WinId ))
				MT_wind_set_int( ChannelWinId, WF_TOP, 0, Global );
		}
			
		if( Events->mwhich & MU_MESAG )
		{
			switch( Events->msg[0] )
			{
				case	WM_CLOSED:
					if( Events->msg[4] != WIN_CLOSE_WITHOUT_DEMAND )
					{
						if(( SessionWinId && SessionWinId != Events->msg[3] ) ||
						   ( ChannelWinId && ChannelWinId != Events->msg[3] ))
						{
							Ret = ERROR;
							Events->mwhich &= ~MU_MESAG;
						}
					}
					break;
				case	WM_ONTOP:
				case	WM_TOPPED:
					if(( SessionWinId && SessionWinId != Events->msg[3] ) ||
					   ( ChannelWinId && ChannelWinId != Events->msg[3] ))
					{
						if( SessionWinId )
							MT_wind_set_int( SessionWinId, WF_TOP, 0, Global );
						else	if( ChannelWinId )
							MT_wind_set_int( ChannelWinId, WF_TOP, 0, Global );
						Events->mwhich &= ~MU_MESAG;
					}
					break;
			}
		}
		if( Events->mwhich & MU_BUTTON )
		{
			WORD	WinId = MT_wind_find( Events->mx, Events->my, Global );
			if(( SessionWinId && WinId != SessionWinId ) ||
			   ( ChannelWinId && WinId != SessionWinId ))
			{
				Events->mwhich &= ~MU_BUTTON;
				if( SessionWinId )
					MT_wind_set_int( SessionWinId, WF_TOP, 0, Global );
				else	if( ChannelWinId )
					MT_wind_set_int( ChannelWinId, WF_TOP, 0, Global );
			}
		}
	}
/*	if( Ret != E_OK )
		Cconout( '\a' );
*/	return( Ret );
}
