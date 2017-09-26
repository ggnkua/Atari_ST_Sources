#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<STRING.H>
#include	<stdio.h>

#include	<atarierr.h>

#include	"main.h"
#include	RSCHEADER
#include	"ExtObj\ListObj.h"
#include	"Irc.h"
#include	"Help.h"
#include	"Menu.h"
#include	"Popup.h"
#include	"Rsc.h"
#include	"WDialog.h"
#include	"Window.h"
#include	"WIrc\Func.h"
#include	"WIrc\IrcFunc.h"
#include	"WIrc\WDccChat.h"
#include	"WIrc\WInput.h"
#include	"WIrc\WNames.h"
#include	"WIrc\WPut.h"

#include	"Keytab.h"
#include	"MapKey.h"

#define	NAMES_WINDOW_KINDS		NAME + FULLER + MOVER + CLOSER + ICONIFIER + VSLIDE + UPARROW + DNARROW + SIZER + INFO

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	Global[15];
extern OBJECT	**TreeAddr;
extern GRECT	ScreenRect;
extern WORD	isScroll;
extern WORD	ColourTableRef[], ColourTableObj[];
extern WORD IrcFlags;

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
BYTE	*CtcpCmd[6] = { "PING", "FINGER", "VERSION", "TIME", "USERINFO", "CLIENTINFO" };

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static WORD	cdecl	HandleDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
static WORD	HndlEditDialog( void *DialogData, EVNT *Events, WORD Global[15] );
static WORD	HndlMesagDialog( void *DialogData, EVNT *Events, WORD Global[15] );
static WORD	HndlClsDialog( void *DialogData, WORD Global[15] );
static void	SetInfo( NAMES_WINDOW *NamesWindow, WORD Global[15] );
static void SetSort( DIALOG_DATA *DialogData, WORD SortNew, WORD Global[15] );
static void	SwitchDialog( DIALOG_DATA *DialogData, WORD Global[15] );
static void SizeDialog( DIALOG_DATA *DialogData, GRECT *New, WORD Global[15] );
static void	SetVSlide( DIALOG_DATA *DialogData, WORD Global[15] );
static void SetColumns( DIALOG_DATA *DialogData, WORD Global[15] );
static void SetButtons( DIALOG_DATA *DialogData, WORD Global[15] );
static WORD	NamesWindowRead( IRC_CHANNEL *IrcChannel, GRECT *Work, WORD *Id, WORD *Ht, WORD ColourTable[], LONG *yScroll, WORD Width[7], WORD *Sort, WORD *Switch, WORD Global[15] );
static WORD	NamesWindowWrite( IRC_CHANNEL *IrcChannel, WORD Global[15] );

WORD	OpenNamesWindow( IRC_CHANNEL *IrcChannel, WORD Global[15] )
{
	IRC_SESSION		*IrcSession = IrcChannel->IrcSession;
	IRC				*Irc = IrcSession->Irc;
	WORD				Ret, i;
	NAMES_WINDOW	*NamesWindow;
	DIALOG_DATA		*DialogData;
	GRECT	Curr;

	if( IrcChannel->ListWindow )
		return( E_OK );

	if(( NamesWindow = malloc( sizeof( NAMES_WINDOW ))) == NULL )
		return( ENSMEM );
	NamesWindow->NextFuller.g_x = ScreenRect.g_x;
	NamesWindow->NextFuller.g_y = ScreenRect.g_y;
	NamesWindow->NextFuller.g_w = ScreenRect.g_w;
	NamesWindow->NextFuller.g_h = ScreenRect.g_h;

	NamesWindow->IrcChannel = IrcChannel;

	NamesWindow->Title = malloc( strlen( TreeAddr[TITLES][TITLE_WINDOW].ob_spec.free_string ) + 1 + strlen( IrcChannel->Name ) + 1 );
	if( !NamesWindow->Title )
	{
		free( NamesWindow );
		return( ENSMEM );
	}
	sprintf( NamesWindow->Title, "%s %s", TreeAddr[TITLES][TITLE_WINDOW].ob_spec.free_string, IrcChannel->Name );

	if(( DialogData = malloc( sizeof( DIALOG_DATA ))) == NULL )
	{
		free( NamesWindow->Title );
		free( NamesWindow );
		return( ENSMEM );
	}	
	NamesWindow->DialogData = DialogData;
	DialogData->Dialog = NULL;
	DialogData->HndlDdDialog = NULL;
	DialogData->HndlClsDialog = HndlClsDialog;
	DialogData->HndlMesagDialog = HndlMesagDialog;
	DialogData->HndlEditDialog = HndlEditDialog;
	DialogData->HndlHelpDialog = NULL;
	DialogData->HndlTimerDialog = NULL;
	DialogData->HndlCheckDialog = HndlCheckDialogWIrc;
	DialogData->UserData = NamesWindow;
	DialogData->TreeIndex = WNAMES;

	if(( DialogData->Tree = CopyTree( TreeAddr[WNAMES] )) == NULL )
	{
		free( NamesWindow->Title );
		free( NamesWindow );
		free( DialogData );
		return( ENSMEM );
	}

	if(( Ret = mt_list_create( DialogData->Tree, WNAMES_OUTPUT, 7, Global )) != E_OK )
	{
		FreeTree( DialogData->Tree );
		free( DialogData );
		free( NamesWindow->Title );
		free( NamesWindow );
		return( Ret );
	}

	mt_list_set_font( DialogData->Tree, WNAMES_OUTPUT, Irc->UserFontId, Irc->UserFontHt, 0, 0, Global );
	mt_list_set_colour( DialogData->Tree, WNAMES_OUTPUT, Irc->ColourTable[COLOUR_USER], Irc->ColourTable[COLOUR_USER_BACK], Global );
	for( i = 0; i < COLOUR_MAX; i++ )
		mt_list_set_colourtable( DialogData->Tree, WNAMES_OUTPUT, Irc->ColourTable[i], i, Global );

	IrcChannel->ListWindow = NamesWindow;

	SetSort( DialogData, 1, Global );
	{
		GRECT	Work;
		LONG	yScroll = 0;
		WORD	Id, Ht, Width[7], Sort, Switch, ColourTable[COLOUR_MAX];
		if( NamesWindowRead( IrcChannel, &Work, &Id, &Ht, ColourTable, &yScroll, Width, &Sort, &Switch, Global ) == E_OK )
		{
			WORD	i;
			MT_wind_calc( WC_BORDER, NAMES_WINDOW_KINDS, &Work, &Curr, Global );
			if( IrcFlags & WINDOW_OVERWRITE )
			{
				mt_list_set_font( DialogData->Tree, WNAMES_OUTPUT, Id, Ht, 1, 0, Global );
				mt_list_set_colour( DialogData->Tree, WNAMES_OUTPUT, ColourTable[COLOUR_USER], ColourTable[COLOUR_USER_BACK], Global );
				for( i = 0; i < COLOUR_MAX; i++ )
					mt_list_set_colourtable( DialogData->Tree, WNAMES_OUTPUT, ColourTable[i], i, Global );
			}
			SetSort( DialogData, Sort, Global );
			if( Switch )
				SwitchDialog( DialogData, Global );
			SizeDialog( DialogData, &Curr, Global );
			mt_list_set_dirty( DialogData->Tree, WNAMES_OUTPUT, 0 , Global );
			DialogData->Tree[WNAMES_NICKNAME].ob_width = Width[0];
			DialogData->Tree[WNAMES_USERNAME].ob_x = Width[0];
			DialogData->Tree[WNAMES_USERNAME].ob_width = Width[1];
			DialogData->Tree[WNAMES_REALNAME].ob_x = Width[0] + Width[1];
			DialogData->Tree[WNAMES_REALNAME].ob_width = Width[2];
			DialogData->Tree[WNAMES_CHANNELS].ob_x = Width[0] + Width[1] + Width[2];
			DialogData->Tree[WNAMES_CHANNELS].ob_width = Width[3];
			DialogData->Tree[WNAMES_SERVER].ob_x = Width[0] + Width[1] + Width[2] + Width[3];
			DialogData->Tree[WNAMES_SERVER].ob_width = Width[4];
			DialogData->Tree[WNAMES_HOST].ob_x = Width[0] + Width[1] + Width[2] + Width[3] + Width[4];
			DialogData->Tree[WNAMES_HOST].ob_width = Width[5];
			DialogData->Tree[WNAMES_IDLE].ob_x = Width[0] + Width[1] + Width[2] + Width[3] + Width[4] + Width[5];
			DialogData->Tree[WNAMES_IDLE].ob_width = Width[6];
		}
		else
		{
			Work.g_x = -1;
			Work.g_y = -1;
		}
		SetColumns( DialogData, Global );
		SetButtons( DialogData, Global );
		MT_wind_calc( WC_BORDER, NAMES_WINDOW_KINDS, &Work, &Curr, Global );
		PlaceIntelligent( &Curr );
		MT_wind_calc( WC_WORK, NAMES_WINDOW_KINDS, &Curr, &Work, Global );
		OpenDialogX( NamesWindow->Title, WIN_NAMES_IRC, NAMES_WINDOW_KINDS, Work.g_x, Work.g_y, HandleDialog, DialogData, Global );
		NamesWindow->WinId = MT_wdlg_get_handle( DialogData->Dialog, Global );
	}
	SetVSlide( DialogData, Global );
	return( E_OK );
}

static WORD cdecl	HandleDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData )
{
	OBJECT			*DialogTree;
	GRECT				Rect;
	DIALOG_DATA		*DialogData = ( DIALOG_DATA * ) MT_wdlg_get_udata( Dialog, Global );
	NAMES_WINDOW	*NamesWindow = ( NAMES_WINDOW * ) DialogData->UserData;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_INIT:
				break;
			case	HNDL_EDIT:
			{
				break;
			}
			case	HNDL_EDDN:
			{
				break;
			}
			case	HNDL_MESG:
			{
				switch( Events->msg[0] )
				{
					case	WM_SIZED:
					{
						SizeDialog( DialogData, ( GRECT *) &( Events->msg[4] ), Global );
						break;
					}
					case	WM_FULLED:
					{
						GRECT	Pos;
						EVNT	lEvents;
						MT_wind_get_grect( Events->msg[3], WF_CURRXYWH, &Pos, Global );
						lEvents.mwhich = MU_MESAG;
						lEvents.msg[0] = WM_MOVED;
						lEvents.msg[1] = Global[2];
						lEvents.msg[2] = 0;
						lEvents.msg[3] = Events->msg[3];
						lEvents.msg[4] = NamesWindow->NextFuller.g_x;
						lEvents.msg[5] = NamesWindow->NextFuller.g_y;
						lEvents.msg[6] = NamesWindow->NextFuller.g_w;
						lEvents.msg[7] = NamesWindow->NextFuller.g_h;
						HandleWindow( &lEvents, Global );
						lEvents.mwhich = MU_MESAG;
						lEvents.msg[0] = WM_SIZED;
						lEvents.msg[1] = Global[2];
						lEvents.msg[2] = 0;
						lEvents.msg[3] = Events->msg[3];
						lEvents.msg[4] = NamesWindow->NextFuller.g_x;
						lEvents.msg[5] = NamesWindow->NextFuller.g_y;
						lEvents.msg[6] = NamesWindow->NextFuller.g_w;
						lEvents.msg[7] = NamesWindow->NextFuller.g_h;
						HandleWindow( &lEvents, Global );
						NamesWindow->NextFuller.g_x = Pos.g_x;
						NamesWindow->NextFuller.g_y = Pos.g_y;
						NamesWindow->NextFuller.g_w = Pos.g_w;
						NamesWindow->NextFuller.g_h = Pos.g_h;
						break;
					}
					case	WM_ARROWED:
					{
						if( Events->msg[4] == WA_UPPAGE )
						{
							LONG	nLines, yScroll;
							WORD	yVis, nCols, xScroll, xVis;
							mt_list_get_scrollinfo( DialogTree, WNAMES_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
							mt_list_scroll( DialogTree, WNAMES_OUTPUT, Events->msg[3], -yVis, 0, Global );
						}
						else	if( Events->msg[4] == WA_DNPAGE )
						{
							LONG	nLines, yScroll;
							WORD	yVis, nCols, xScroll, xVis;
							mt_list_get_scrollinfo( DialogTree, WNAMES_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
							mt_list_scroll( DialogTree, WNAMES_OUTPUT, Events->msg[3], yVis, 0, Global );
						}
						else	if( Events->msg[4] == WA_UPLINE )
							mt_list_scroll( DialogTree, WNAMES_OUTPUT, Events->msg[3], -1, 0, Global );
						else	if( Events->msg[4] == WA_DNLINE )
							mt_list_scroll( DialogTree, WNAMES_OUTPUT, Events->msg[3], 1, 0, Global );
						SetVSlide( DialogData, Global );
						break;
					}
					case	WM_VSLID:
					{
						LONG	nLines, yScroll;
						WORD	yVis, nCols, xScroll, xVis, dyPos;
						mt_list_get_scrollinfo( DialogTree, WNAMES_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
						dyPos = nLines - yVis > 0 ? Events->msg[4] * ( nLines - yVis ) / 1000 - yScroll : 0;
						mt_list_scroll( DialogTree, WNAMES_OUTPUT, Events->msg[3], dyPos, 0, Global );
						SetVSlide( DialogData, Global );
						break;
					}
				}
				break;
			}
			case	HNDL_CLSD:
				return( 0 );
		}
	}
	else
	{
		Obj &= 0x7fff;
		if( Obj == WNAMES_OUTPUT && mt_list_evnt( DialogTree, WNAMES_OUTPUT, NamesWindow->WinId, Events, Global ) == -1 )
		{
		}
		if( Obj == WNAMES_OUTPUT )
			SetButtons( DialogData, Global );

		if( Obj != WNAMES_UPDATE && Obj != WNAMES_SWITCH && HandleWDialogIcon( &Obj, Dialog, Global ))
			return( 1 );
		if( DialogTree[Obj].ob_state & DISABLED )
		{
			DialogTree[Obj].ob_state &= ~SELECTED;
			return( 1 );
		}
		if( DialogTree[Obj].ob_type & 0x0100 )
		{
			StGuide_Action( DialogTree, WNAMES, Global );
			return( 1 );
		}
		switch( Obj )
		{
			case	WNAMES_CTCP:
			{
				WORD	Slct = mt_list_get_selected( DialogTree, WNAMES_OUTPUT, Global );
				IRC_CHANNEL	*IrcChannel = NamesWindow->IrcChannel;
				IRC_SESSION	*IrcSession = IrcChannel->IrcSession;
				if( Slct != -1 && !Events->kstate )
				{
					WORD	Ret, x, y;
					MT_objc_offset( DialogTree, WNAMES_CTCP, &x, &y, Global );
					if(( Ret = Popup( TreeAddr[POPUP_CTCP], 0, x, y, Global )) > 0 )
					{
						BYTE	Puf[512],	**Item;
						WORD	Colour;
						Item = mt_list_get_item( DialogTree, WNAMES_OUTPUT, Slct, &Colour, Global );
						sprintf( Puf, "/CTCP %s %s", Item[0], CtcpCmd[Ret-1] );
						SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
					}
				}
				else
				{
					if( Slct == -1 )
						OpenAlertIrc( IrcSession, IrcChannel, CtcpDialog( IrcChannel, NULL, Global ), MODWIN_NORMAL );
					else
					{
						BYTE	**Item;
						WORD	Colour;
						Item = mt_list_get_item( DialogTree, WNAMES_OUTPUT, Slct, &Colour, Global );
						OpenAlertIrc( IrcSession, IrcChannel, CtcpDialog( IrcChannel, Item[0], Global ), MODWIN_NORMAL );
					}
				}
				DialogTree[Obj].ob_state &= ~SELECTED;
				DoRedraw( Dialog, &Rect, Obj, Global );
				break;
			}
			case	WNAMES_MSG:
			case	WNAMES_INVITE:
			case	WNAMES_DCCCHAT:
			{
				BYTE	**Item;
				WORD	Colour, Slct = mt_list_get_selected( DialogTree, WNAMES_OUTPUT, Global );
				IRC_CHANNEL	*IrcChannel = NamesWindow->IrcChannel;
				IRC_SESSION	*IrcSession = IrcChannel->IrcSession;
				if( Slct != -1 )
				{
					Item = mt_list_get_item( DialogTree, WNAMES_OUTPUT, Slct, &Colour, Global );
					if( Obj == WNAMES_MSG )
					{
						if( OpenIrcChannel( IrcSession, Item[0], Global ) != E_OK )
							MT_form_alert( 1, TreeAddr[ALERTS][MEMORY].ob_spec.free_string, Global );
					}
					else	if( Obj == WNAMES_INVITE )
						OpenAlertIrc( IrcSession, IrcChannel, InviteDialog( IrcChannel, Item[0], Global ), MODWIN_NORMAL );
					else	if( Obj == WNAMES_DCCCHAT )
					{
						if( OpenDccChatSession( IrcSession, Item[0], Global ) != E_OK )
							MT_form_alert( 1, TreeAddr[ALERTS][MEMORY].ob_spec.free_string, Global );
					}
				}
				else
				{
					if( Obj == WNAMES_MSG )
						OpenAlertIrc( IrcSession, IrcChannel, MsgDialog( IrcChannel, MSGDIALOG_CHAT, Global ), MODWIN_NORMAL );
					else	if( Obj == WNAMES_INVITE )
						OpenAlertIrc( IrcSession, IrcChannel, InviteDialog( IrcChannel, NULL, Global ), MODWIN_NORMAL );
					else	if( Obj == WNAMES_DCCCHAT )
						OpenAlertIrc( IrcSession, IrcChannel, MsgDialog( IrcChannel, MSGDIALOG_DCCCHAT, Global ), MODWIN_NORMAL );
				}
				DialogTree[Obj].ob_state &= ~SELECTED;
				DoRedraw( Dialog, &Rect, Obj, Global );
				break;
			}
			case	WNAMES_OP:
			case	WNAMES_DEOP:
			case	WNAMES_BAN:
			case	WNAMES_DEBAN:
			case	WNAMES_VOICE:
			case	WNAMES_DEVOICE:
			{
				BYTE	**Item, Puf[512];
				WORD	Colour, Slct = mt_list_get_selected( DialogTree, WNAMES_OUTPUT, Global );
				IRC_CHANNEL	*IrcChannel = NamesWindow->IrcChannel;
				IRC_SESSION	*IrcSession = IrcChannel->IrcSession;
				if( Slct != -1 )
				{
					Item = mt_list_get_item( DialogTree, WNAMES_OUTPUT, Slct, &Colour, Global );
					if( Obj == WNAMES_OP )
						sprintf( Puf, "/MODE %s +o %s", IrcChannel->Name, Item[0] );
					else	if( Obj == WNAMES_DEOP )
						sprintf( Puf, "/MODE %s -o %s", IrcChannel->Name, Item[0] );
					else	if( Obj == WNAMES_BAN )
						sprintf( Puf, "/MODE %s +b %s", IrcChannel->Name, Item[0] );
					else	if( Obj == WNAMES_DEBAN )
						sprintf( Puf, "/MODE %s -b %s", IrcChannel->Name, Item[0] );
					else	if( Obj == WNAMES_VOICE )
						sprintf( Puf, "/MODE %s +v %s", IrcChannel->Name, Item[0] );
					else	if( Obj == WNAMES_DEVOICE )
						sprintf( Puf, "/MODE %s -v %s", IrcChannel->Name, Item[0] );
					strcat( Puf, "" );
					SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
					mt_list_set_selected( DialogTree, WNAMES_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), -1, Global );
				}
				else
				{
					if( Obj == WNAMES_OP )
						OpenAlertIrc( IrcSession, IrcChannel, OpDialog( IrcChannel, OPDIALOG_OP, Global ), MODWIN_NORMAL );
					else	if( Obj == WNAMES_DEOP )
						OpenAlertIrc( IrcSession, IrcChannel, OpDialog( IrcChannel, OPDIALOG_DEOP, Global ), MODWIN_NORMAL );
					else	if( Obj == WNAMES_BAN )
						OpenAlertIrc( IrcSession, IrcChannel, KickDialog( IrcChannel, KICKDIALOG_BAN, NULL, Global ), MODWIN_NORMAL );
					else	if( Obj == WNAMES_DEBAN )
						OpenAlertIrc( IrcSession, IrcChannel, KickDialog( IrcChannel, KICKDIALOG_DEBAN, NULL, Global ), MODWIN_NORMAL );
					else	if( Obj == WNAMES_VOICE )
						OpenAlertIrc( IrcSession, IrcChannel, OpDialog( IrcChannel, OPDIALOG_VOICE, Global ), MODWIN_NORMAL );
					else	if( Obj == WNAMES_DEVOICE )
						OpenAlertIrc( IrcSession, IrcChannel, OpDialog( IrcChannel, OPDIALOG_DEVOICE, Global ), MODWIN_NORMAL );
				}
				DialogTree[Obj].ob_state &= ~SELECTED;
				DoRedraw( Dialog, &Rect, Obj, Global );
				break;
			}
			case	WNAMES_KICK:
			case	WNAMES_BANKICK:
			{
/* Wenn Shift-Taste gedrckt, dann noch M”glichkeit zur Texteingabe vorsehen */
				BYTE	**Item, *Nickname = NULL, Puf[512];
				WORD	Colour, Slct = mt_list_get_selected( DialogTree, WNAMES_OUTPUT, Global );
				IRC_CHANNEL	*IrcChannel = NamesWindow->IrcChannel;
				IRC_SESSION	*IrcSession = IrcChannel->IrcSession;
				if( Slct != -1 )
				{
					Item = mt_list_get_item( DialogTree, WNAMES_OUTPUT, Slct, &Colour, Global );
					Nickname = Item[0];
				}
				
				if( Slct != -1 && !Events->kstate )
				{
					if( Obj == WNAMES_BANKICK )
					{
						sprintf( Puf, "/MODE %s +b %s", IrcChannel->Name, Item[0] );
						strcat( Puf, "" );
						SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
					}
					sprintf( Puf, "/KICK %s %s", IrcChannel->Name, Item[0] );
					strcat( Puf, "" );
					SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
					mt_list_set_selected( DialogTree, WNAMES_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), -1, Global );
				}
				else
				{
					if( Obj == WNAMES_KICK )
						OpenAlertIrc( IrcSession, IrcChannel, KickDialog( IrcChannel, KICKDIALOG_KICK, Nickname, Global ), MODWIN_NORMAL );
					else	if( Obj == WNAMES_BANKICK )
						OpenAlertIrc( IrcSession, IrcChannel, KickDialog( IrcChannel, KICKDIALOG_BANKICK, Nickname, Global ), MODWIN_NORMAL );
				}
				DialogTree[Obj].ob_state &= ~SELECTED;
				DoRedraw( Dialog, &Rect, Obj, Global );
				break;
			}
			case	WNAMES_DCCFILE:
			{
				BYTE	**Item, Puf[512];
				WORD	Colour, Slct = mt_list_get_selected( DialogTree, WNAMES_OUTPUT, Global );
				IRC_CHANNEL	*IrcChannel = NamesWindow->IrcChannel;
				IRC_SESSION	*IrcSession = IrcChannel->IrcSession;
				if( Slct != -1 )
				{
					Item = mt_list_get_item( DialogTree, WNAMES_OUTPUT, Slct, &Colour, Global );
					OpenAlertIrc( IrcSession, IrcChannel, OpenPutWindow( IrcChannel, Item[0], Global ), MODWIN_NORMAL );
				}
				else
					OpenAlertIrc( IrcSession, IrcChannel, OpenPutWindow( IrcChannel, NULL, Global ), MODWIN_NORMAL );
				DialogTree[Obj].ob_state &= ~SELECTED;
				DoRedraw( Dialog, &Rect, Obj, Global );
				break;
			}
			case	WNAMES_SWITCH:
			{
				SwitchDialog( DialogData, Global );
				MT_wdlg_set_tree( Dialog, DialogTree, Global );
				break;
			}
			case	WNAMES_UPDATE:
			{
				IRC_CHANNEL	*IrcChannel = NamesWindow->IrcChannel;
				IRC_SESSION	*IrcSession = IrcChannel->IrcSession;
				BYTE	Puf[128];
				sprintf( Puf, "/NAMES %s\0\0", IrcChannel->Name );
				SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
				DialogTree[WNAMES_UPDATE].ob_state &= ~SELECTED;
				DoRedraw( Dialog, &Rect, WNAMES_UPDATE, Global );
				break;
			}
			case	WNAMES_NICKNAME:
			case	WNAMES_USERNAME:
			case	WNAMES_REALNAME:
			case	WNAMES_CHANNELS:
			case	WNAMES_SERVER:
			case	WNAMES_HOST:
			case	WNAMES_IDLE:
			{
				EVNTDATA	EvData;
				MT_graf_mkstate( &EvData, Global );
				if( EvData.bstate == 1 )
				{
					WORD	xNickname, xUsername, xRealname, xChannels, xServer, xHost, xIdle, Dummy, C;
					MT_objc_offset( DialogTree, WNAMES_NICKNAME, &xNickname, &Dummy, Global );
					xUsername = xNickname + DialogTree[WNAMES_NICKNAME].ob_width;
					xRealname = xUsername + DialogTree[WNAMES_USERNAME].ob_width;
					xChannels = xRealname + DialogTree[WNAMES_REALNAME].ob_width;
					xServer = xChannels + DialogTree[WNAMES_CHANNELS].ob_width;
					xHost = xServer + DialogTree[WNAMES_SERVER].ob_width;
					xIdle = xHost + DialogTree[WNAMES_HOST].ob_width;
					if( !( DialogTree[WNAMES_SWITCH].ob_state & SELECTED ) && ( Obj == WNAMES_NICKNAME && EvData.x >= xUsername - 8 ) || ( Obj == WNAMES_USERNAME && EvData.x <= xUsername + 8 ))
						C = 1;
					else	if(( Obj == WNAMES_USERNAME && EvData.x >= xRealname - 8 ) || ( Obj == WNAMES_REALNAME && EvData.x <= xRealname + 8 ))
						C = 2;
					else	if(( Obj == WNAMES_REALNAME && EvData.x >= xChannels - 8 ) || ( Obj == WNAMES_CHANNELS && EvData.x <= xChannels + 8 ))
						C = 3;
					else	if(( Obj == WNAMES_CHANNELS && EvData.x >= xServer - 8 ) || ( Obj == WNAMES_SERVER && EvData.x <= xServer + 8 ))
						C = 4;
					else	if(( Obj == WNAMES_SERVER && EvData.x >= xHost - 8 ) || ( Obj == WNAMES_HOST && EvData.x <= xHost + 8 ))
						C = 5;
					else	if(( Obj == WNAMES_HOST && EvData.x >= xIdle - 8 ) || ( Obj == WNAMES_IDLE && EvData.x <= xIdle + 8 ))
						C = 6;
					else
						C = 0;
					if( C )
					{
						WORD	x = EvData.x, Dx;
						MT_graf_mouse( M_SAVE, NULL, Global );
						MT_graf_mouse( POINT_HAND, NULL, Global );
						while( EvData.bstate == 1 )
						{
							Dx = EvData.x - x;
							if( C == 1 )
							{
								if( DialogTree[WNAMES_NICKNAME].ob_width + Dx < TreeAddr[WNAMES][WNAMES_NICKNAME].ob_width )
									Dx = TreeAddr[WNAMES][WNAMES_NICKNAME].ob_width - DialogTree[WNAMES_NICKNAME].ob_width;
								if( DialogTree[WNAMES_IDLE].ob_width - Dx < TreeAddr[WNAMES][WNAMES_IDLE].ob_width )
									Dx = DialogTree[WNAMES_IDLE].ob_width - TreeAddr[WNAMES][WNAMES_IDLE].ob_width;
								DialogTree[WNAMES_NICKNAME].ob_width += Dx;
								DialogTree[WNAMES_USERNAME].ob_x += Dx;
								DialogTree[WNAMES_REALNAME].ob_x += Dx;
								DialogTree[WNAMES_CHANNELS].ob_x += Dx;
								DialogTree[WNAMES_SERVER].ob_x += Dx;
								DialogTree[WNAMES_HOST].ob_x += Dx;
								DialogTree[WNAMES_IDLE].ob_x += Dx;
								DialogTree[WNAMES_IDLE].ob_width -= Dx;
							}
							else	if( C == 2 )
							{
								if( DialogTree[WNAMES_USERNAME].ob_width + Dx < TreeAddr[WNAMES][WNAMES_USERNAME].ob_width )
									Dx = TreeAddr[WNAMES][WNAMES_USERNAME].ob_width - DialogTree[WNAMES_USERNAME].ob_width;
								if( DialogTree[WNAMES_IDLE].ob_width - Dx < TreeAddr[WNAMES][WNAMES_IDLE].ob_width )
									Dx = DialogTree[WNAMES_IDLE].ob_width - TreeAddr[WNAMES][WNAMES_IDLE].ob_width;
								DialogTree[WNAMES_USERNAME].ob_width += Dx;
								DialogTree[WNAMES_REALNAME].ob_x += Dx;
								DialogTree[WNAMES_CHANNELS].ob_x += Dx;
								DialogTree[WNAMES_SERVER].ob_x += Dx;
								DialogTree[WNAMES_HOST].ob_x += Dx;
								DialogTree[WNAMES_IDLE].ob_x += Dx;
								DialogTree[WNAMES_IDLE].ob_width -= Dx;
							}
							else	if( C == 3 )
							{
								if( DialogTree[WNAMES_REALNAME].ob_width + Dx < TreeAddr[WNAMES][WNAMES_REALNAME].ob_width )
									Dx = TreeAddr[WNAMES][WNAMES_REALNAME].ob_width - DialogTree[WNAMES_REALNAME].ob_width;
								if( DialogTree[WNAMES_IDLE].ob_width - Dx < TreeAddr[WNAMES][WNAMES_IDLE].ob_width )
									Dx = DialogTree[WNAMES_IDLE].ob_width - TreeAddr[WNAMES][WNAMES_IDLE].ob_width;
								DialogTree[WNAMES_REALNAME].ob_width += Dx;
								DialogTree[WNAMES_CHANNELS].ob_x += Dx;
								DialogTree[WNAMES_SERVER].ob_x += Dx;
								DialogTree[WNAMES_HOST].ob_x += Dx;
								DialogTree[WNAMES_IDLE].ob_x += Dx;
								DialogTree[WNAMES_IDLE].ob_width -= Dx;
							}
							else	if( C == 4 )
							{
								if( DialogTree[WNAMES_CHANNELS].ob_width + Dx < TreeAddr[WNAMES][WNAMES_CHANNELS].ob_width )
									Dx = TreeAddr[WNAMES][WNAMES_CHANNELS].ob_width - DialogTree[WNAMES_CHANNELS].ob_width;
								if( DialogTree[WNAMES_IDLE].ob_width - Dx < TreeAddr[WNAMES][WNAMES_IDLE].ob_width )
									Dx = DialogTree[WNAMES_IDLE].ob_width - TreeAddr[WNAMES][WNAMES_IDLE].ob_width;
								DialogTree[WNAMES_CHANNELS].ob_width += Dx;
								DialogTree[WNAMES_SERVER].ob_x += Dx;
								DialogTree[WNAMES_HOST].ob_x += Dx;
								DialogTree[WNAMES_IDLE].ob_x += Dx;
								DialogTree[WNAMES_IDLE].ob_width -= Dx;
							}
							else	if( C == 5 )
							{
								if( DialogTree[WNAMES_SERVER].ob_width + Dx < TreeAddr[WNAMES][WNAMES_SERVER].ob_width )
									Dx = TreeAddr[WNAMES][WNAMES_SERVER].ob_width - DialogTree[WNAMES_SERVER].ob_width;
								if( DialogTree[WNAMES_IDLE].ob_width - Dx < TreeAddr[WNAMES][WNAMES_IDLE].ob_width )
									Dx = DialogTree[WNAMES_IDLE].ob_width - TreeAddr[WNAMES][WNAMES_IDLE].ob_width;
								DialogTree[WNAMES_SERVER].ob_width += Dx;
								DialogTree[WNAMES_HOST].ob_x += Dx;
								DialogTree[WNAMES_IDLE].ob_x += Dx;
								DialogTree[WNAMES_IDLE].ob_width -= Dx;
							}
							else	if( C == 6 )
							{
								if( DialogTree[WNAMES_HOST].ob_width + Dx < TreeAddr[WNAMES][WNAMES_HOST].ob_width )
									Dx = TreeAddr[WNAMES][WNAMES_HOST].ob_width - DialogTree[WNAMES_HOST].ob_width;
								if( DialogTree[WNAMES_IDLE].ob_width - Dx < TreeAddr[WNAMES][WNAMES_IDLE].ob_width )
									Dx = DialogTree[WNAMES_IDLE].ob_width - TreeAddr[WNAMES][WNAMES_IDLE].ob_width;
								DialogTree[WNAMES_HOST].ob_width += Dx;
								DialogTree[WNAMES_IDLE].ob_x += Dx;
								DialogTree[WNAMES_IDLE].ob_width -= Dx;
							}
							x += Dx;
							if( Dx )
								SetColumns( DialogData, Global );
							MT_graf_mkstate( &EvData, Global );
						}
						MT_graf_mouse( M_RESTORE, NULL, Global );
						break;
					}
				}
			}
			case	WNAMES_NICKNAME_SORT:
			case	WNAMES_USERNAME_SORT:
			case	WNAMES_REALNAME_SORT:
			case	WNAMES_CHANNELS_SORT:
			case	WNAMES_SERVER_SORT:
			case	WNAMES_HOST_SORT:
			case	WNAMES_IDLE_SORT:
			{
				WORD	Sort = mt_list_get_sort( DialogTree, WNAMES_OUTPUT, Global ), Button;
				if( !( DialogData->Tree[Obj].ob_state & SELECTED ))
				{
					EVNTDATA	EvData;
					WORD	a;
					DialogData->Tree[Obj].ob_state |= SELECTED;
					DoRedraw( Dialog, &Rect, Obj, Global );
				
					do
					{
						MT_graf_mkstate( &EvData, Global );
						a = MT_objc_find( DialogTree, ROOT, MAX_DEPTH, EvData.x, EvData.y, Global );
						if( a != Obj )
						{
							DialogTree[Obj].ob_state &= ~SELECTED;
							DoRedraw( Dialog, &Rect, Obj, Global );
							return( 1 );
						}
					}
					while( EvData.bstate & 1 );
				}
				DialogData->Tree[Obj].ob_state &= ~SELECTED;
				if( Obj == WNAMES_NICKNAME || Obj == WNAMES_NICKNAME_SORT )
				{
					if( Sort == 1 )
						SetSort( DialogData, 2, Global );
					else
						SetSort( DialogData, 1, Global );
				}
				else	if( Obj == WNAMES_USERNAME || Obj == WNAMES_USERNAME_SORT )
				{
					if( Sort == 3 )
						SetSort( DialogData, 4, Global );
					else
						SetSort( DialogData, 3, Global );
				}
				else	if( Obj == WNAMES_REALNAME || Obj == WNAMES_REALNAME_SORT )
				{
					if( Sort == 5 )
						SetSort( DialogData, 6, Global );
					else
						SetSort( DialogData, 5, Global );
				}
				else	if( Obj == WNAMES_CHANNELS || Obj == WNAMES_CHANNELS_SORT )
				{
					if( Sort == 7 )
						SetSort( DialogData, 8, Global );
					else
						SetSort( DialogData, 7, Global );
				}
				else	if( Obj == WNAMES_SERVER || Obj == WNAMES_SERVER_SORT )
				{
					if( Sort == 9 )
						SetSort( DialogData, 10, Global );
					else
						SetSort( DialogData, 9, Global );
				}
				else	if( Obj == WNAMES_HOST || Obj == WNAMES_HOST_SORT )
				{
					if( Sort == 11 )
						SetSort( DialogData, 12, Global );
					else
						SetSort( DialogData, 11, Global );
				}
				else	if( Obj == WNAMES_IDLE || Obj == WNAMES_IDLE_SORT )
				{
					if( Sort == 13 )
						SetSort( DialogData, 14, Global );
					else
						SetSort( DialogData, 13, Global );
				}
				DoRedraw( Dialog, &Rect, WNAMES_OUTPUT_PARENT1, Global );
				if( mt_list_get_selected( DialogTree, WNAMES_OUTPUT, Global ) != -1 )
				{
/*					BYTE	**Item = mt_list_get_item( DialogTree, WNAMES_OUTPUT, mt_list_get_selected( DialogTree, WNAMES_OUTPUT, Global ), Global );
					MT_wdlg_set_edit( Dialog, 0, Global );
					strcpy( DialogTree[WNAMES_EDIT].ob_spec.tedinfo->te_ptext, Item[0] );
					MT_wdlg_set_edit( Dialog, WNAMES_EDIT, Global );
					DoRedraw( Dialog, &Rect, WNAMES_EDIT, Global );
*/				}
				break;
			}
		}
	}
	return( 1 );
}

static WORD	HndlEditDialog( void *DialogData, EVNT *Events, WORD Global[15] )
{
	if( Events->mwhich & MU_KEYBD )
	{
		WORD	Key = MapKey( Events->key );
		if( Key & KbSCAN )
		{
			DIALOG	*Dialog = (( DIALOG_DATA * ) DialogData )->Dialog;
			OBJECT	*DialogTree;
			LONG	nLines, yScroll;
			WORD	yVis, nCols, xScroll, xVis, Colour, Sort, Slct;
			BYTE	**Item;
			GRECT	Rect;
			MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
			Sort = mt_list_get_sort( DialogTree, WNAMES_OUTPUT, Global );
			Slct = mt_list_get_selected( DialogTree, WNAMES_OUTPUT, Global );
			mt_list_get_scrollinfo( DialogTree, WNAMES_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );	

			if( Key & KbALT )
			{
				NAMES_WINDOW	*NamesWindow = ( NAMES_WINDOW * )(( DIALOG_DATA * ) DialogData )->UserData;
				IRC_CHANNEL	*IrcChannel = NamesWindow->IrcChannel;
				if(( Key & 0xff ) == KbF1 )
				{
					HandleDialog( Dialog, Events, WNAMES_DCCCHAT, 1, NULL );
					Events->mwhich &= ~MU_KEYBD;
				}
				if(( Key & 0xff ) == KbF2 )
				{
					HandleDialog( Dialog, Events, WNAMES_MSG, 1, NULL );
					Events->mwhich &= ~MU_KEYBD;
				}
				if(( Key & 0xff ) == KbF3 )
				{
					if( IrcChannel->ChannelFlag & MODE_OP )
						HandleDialog( Dialog, Events, WNAMES_OP, 1, NULL );
					Events->mwhich &= ~MU_KEYBD;
				}
				if(( Key & 0xff ) == KbF4 )
				{
					if( IrcChannel->ChannelFlag & MODE_OP )
						HandleDialog( Dialog, Events, WNAMES_BAN, 1, NULL );
					Events->mwhich &= ~MU_KEYBD;
				}
				if(( Key & 0xff ) == KbF5 )
				{
					if( IrcChannel->ChannelFlag & MODE_OP )
						HandleDialog( Dialog, Events, WNAMES_KICK, 1, NULL );
					Events->mwhich &= ~MU_KEYBD;
				}
				if(( Key & 0xff ) == KbF6 )
				{
					if( IrcChannel->ChannelFlag & MODE_MODERATED )
						HandleDialog( Dialog, Events, WNAMES_VOICE, 1, NULL );
					Events->mwhich &= ~MU_KEYBD;
				}
				if(( Key & 0xff ) == KbF7 )
				{
					HandleDialog( Dialog, Events, WNAMES_CTCP, 1, NULL );
					Events->mwhich &= ~MU_KEYBD;
				}
				if(( Key & 0xff ) == KbF11 )
				{
					HandleDialog( Dialog, Events, WNAMES_DCCFILE, 1, NULL );
					Events->mwhich &= ~MU_KEYBD;
				}
				if(( Key & 0xff ) == KbF12 )
				{
					HandleDialog( Dialog, Events, WNAMES_INVITE, 1, NULL );
					Events->mwhich &= ~MU_KEYBD;
				}	
				if(( Key & 0xff ) == KbF13 )
				{
					if( IrcChannel->ChannelFlag & MODE_OP )
						HandleDialog( Dialog, Events, WNAMES_DEOP, 1, NULL );
					Events->mwhich &= ~MU_KEYBD;
				}
				if(( Key & 0xff ) == KbF14 )
				{
					if( IrcChannel->ChannelFlag & MODE_OP )
						HandleDialog( Dialog, Events, WNAMES_DEBAN, 1, NULL );
					Events->mwhich &= ~MU_KEYBD;
				}
				if(( Key & 0xff ) == KbF15 )
				{
					if( IrcChannel->ChannelFlag & MODE_OP )
						HandleDialog( Dialog, Events, WNAMES_BANKICK, 1, NULL );
					Events->mwhich &= ~MU_KEYBD;
				}
				if(( Key & 0xff ) == KbF16 )
				{
					if(( IrcChannel->ChannelFlag & MODE_OP ))
						HandleDialog( Dialog, Events, WNAMES_DEVOICE, 1, NULL );
					Events->mwhich &= ~MU_KEYBD;
				}
			}
			if( Key & KbCONTROL )
			{
				if(( Key & 0xff ) == KbDOWN )
				{
					if( Key & KbSHIFT )
						mt_list_scroll( DialogTree, WNAMES_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), yVis, 0, Global );
					else
						mt_list_scroll( DialogTree, WNAMES_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), +1, 0, Global );
					SetVSlide( DialogData, Global );
					Events->mwhich &= ~MU_KEYBD;
				}
				if(( Key & 0xff ) == KbUP )
				{
					if( Key & KbSHIFT )
						mt_list_scroll( DialogTree, WNAMES_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), -yVis, 0, Global );
					else
						mt_list_scroll( DialogTree, WNAMES_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), -1, 0, Global );
					SetVSlide( DialogData, Global );
					Events->mwhich &= ~MU_KEYBD;
				}
			}
			else
			{
				if(( Key & 0xff ) == KbLEFT || ( Key & 0xff ) == KbRIGHT )
				{
					SwitchDialog( DialogData, Global );
					MT_wdlg_set_tree( Dialog, DialogTree, Global );
					Events->mwhich &= ~MU_KEYBD;
				}
				if(( Key & 0xff ) == KbHOME || (( Key & 0xff ) == 0x4f ))
				{
						if((( Key & 0xff ) == KbHOME && ( Key & KbSHIFT )) || (( Key & 0xff ) == 0x4f ))
					{
						mt_list_set_selected( DialogTree, WNAMES_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), nLines - 1, Global );
						if( yScroll <= nLines - yVis - 1 )
						{
							mt_list_scroll( DialogTree, WNAMES_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), nLines - 1 - yScroll, 0, Global );
							SetVSlide( DialogData, Global );
						}
					}
					else
						{
						mt_list_set_selected( DialogTree, WNAMES_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), 0, Global );
						if( yScroll > 0 )
						{
							mt_list_scroll( DialogTree, WNAMES_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), -yScroll, 0, Global );
							SetVSlide( DialogData, Global );
						}
					}
					Events->mwhich &= ~MU_KEYBD;
				}
				if(( Key & 0xff ) == KbDOWN || ( Key & 0xff ) == 0x51 )
				{
					if( Slct == -1 )
						mt_list_set_selected( DialogTree, WNAMES_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), yScroll, Global );
					else
					{
						if(( Key & KbSHIFT ) || ( Key & 0xff ) == 0x51 )
							Slct += yVis;
						else
							Slct++;
						if( Slct >= nLines )
							Slct = nLines - 1;
	
						mt_list_set_selected( DialogTree, WNAMES_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), Slct, Global );
						if( yScroll + yVis <= Slct || yScroll > Slct )
						{
							mt_list_scroll( DialogTree, WNAMES_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), Slct - yScroll - yVis + 1, 0, Global );
							SetVSlide( DialogData, Global );
						}
					}
					Events->mwhich &= ~MU_KEYBD;	
				}
				if(( Key & 0xff ) == KbUP || ( Key & 0xff ) == 0x49 )
				{
					if( Slct == -1 )
						mt_list_set_selected( DialogTree, WNAMES_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), yScroll + yVis -1, Global );
					else
					{
						if(( Key & KbSHIFT ) || ( Key & 0xff ) == 0x49 )
							Slct -= yVis;
						else	
							Slct--;
						if( Slct < 0 )
							Slct = 0;
						mt_list_set_selected( DialogTree, WNAMES_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), Slct, Global );
						if( yScroll + yVis <= Slct || yScroll > Slct )
						{
							mt_list_scroll( DialogTree, WNAMES_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), Slct - yScroll, 0, Global );
							SetVSlide( DialogData, Global );
						}
					}
					Events->mwhich &= ~MU_KEYBD;
				}
			}
		}
		else
		{
			if(( Key & 0xff ) == 'd' && ( Key & KbCONTROL ))
			{
				DIALOG	*Dialog = (( DIALOG_DATA * ) DialogData )->Dialog;
				OBJECT	*DialogTree;
				GRECT	Rect;
				MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
				mt_list_set_selected( DialogTree, WNAMES_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), -1, Global );
				Events->mwhich &= ~MU_KEYBD;
			}
		}
	}
	return( E_OK );
}

static void SetSort( DIALOG_DATA *DialogData, WORD SortNew, WORD Global[15] )
{
	OBJECT	*DialogTree;
	GRECT		Rect;
	WORD		SortOld = mt_list_get_sort( DialogData->Tree, WNAMES_OUTPUT, Global );

	mt_list_set_sort( DialogData->Tree, WNAMES_OUTPUT, SortNew, Global );
	if( DialogData->Dialog )
		MT_wdlg_get_tree( DialogData->Dialog, &DialogTree, &Rect, Global );

	if( SortOld == 0 || ( SortNew / 2 ) * 2 != ( SortOld / 2 ) * 2 )
	{
		switch( SortOld )
		{
			case	0:
				SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_NICKNAME_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_NO].ob_spec.iconblk );
				SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_USERNAME_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_NO].ob_spec.iconblk );
				SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_REALNAME_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_NO].ob_spec.iconblk );
				SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_CHANNELS_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_NO].ob_spec.iconblk );
				SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_SERVER_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_NO].ob_spec.iconblk );
				SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_HOST_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_NO].ob_spec.iconblk );
				SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_IDLE_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_NO].ob_spec.iconblk );
				break;
			case	1:
			case	2:
				SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_NICKNAME_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_NO].ob_spec.iconblk );
				if( DialogData->Dialog )
					DoRedraw( DialogData->Dialog, &Rect, WNAMES_NICKNAME, Global );
				break;
			case	3:
			case	4:
				SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_USERNAME_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_NO].ob_spec.iconblk );
				if( DialogData->Dialog )
					DoRedraw( DialogData->Dialog, &Rect, WNAMES_USERNAME, Global );
				break;
			case	5:
			case	6:
				SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_REALNAME_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_NO].ob_spec.iconblk );
				if( DialogData->Dialog )
					DoRedraw( DialogData->Dialog, &Rect, WNAMES_REALNAME, Global );
				break;
			case	7:
			case	8:
				SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_CHANNELS_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_NO].ob_spec.iconblk );
				if( DialogData->Dialog )
					DoRedraw( DialogData->Dialog, &Rect, WNAMES_CHANNELS, Global );
				break;
			case	9:
			case	10:
				SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_SERVER_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_NO].ob_spec.iconblk );
				if( DialogData->Dialog )
					DoRedraw( DialogData->Dialog, &Rect, WNAMES_SERVER, Global );
				break;
			case	11:
			case	12:
				SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_HOST_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_NO].ob_spec.iconblk );
				if( DialogData->Dialog )
					DoRedraw( DialogData->Dialog, &Rect, WNAMES_HOST, Global );
			case	13:
			case	14:
				SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_IDLE_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_NO].ob_spec.iconblk );
				if( DialogData->Dialog )
					DoRedraw( DialogData->Dialog, &Rect, WNAMES_IDLE, Global );
		}
	}
	switch( SortNew )
	{
		case	1:
			SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_NICKNAME_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AUF].ob_spec.iconblk );
			if( DialogData->Dialog )
				DoRedraw( DialogData->Dialog, &Rect, WNAMES_NICKNAME, Global );
			break;
		case	2:
			SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_NICKNAME_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AB].ob_spec.iconblk );
			if( DialogData->Dialog )
				DoRedraw( DialogData->Dialog, &Rect, WNAMES_NICKNAME, Global );
			break;
		case	3:
			SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_USERNAME_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AUF].ob_spec.iconblk );
			if( DialogData->Dialog )
				DoRedraw( DialogData->Dialog, &Rect, WNAMES_USERNAME, Global );
			break;
		case	4:
			SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_USERNAME_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AB].ob_spec.iconblk );
			if( DialogData->Dialog )
				DoRedraw( DialogData->Dialog, &Rect, WNAMES_USERNAME, Global );
			break;
		case	5:
			SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_REALNAME_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AUF].ob_spec.iconblk );
			if( DialogData->Dialog )
				DoRedraw( DialogData->Dialog, &Rect, WNAMES_REALNAME, Global );
			break;
		case	6:
			SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_REALNAME_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AB].ob_spec.iconblk );
			if( DialogData->Dialog )
				DoRedraw( DialogData->Dialog, &Rect, WNAMES_REALNAME, Global );
			break;
		case	7:
			SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_CHANNELS_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AUF].ob_spec.iconblk );
			if( DialogData->Dialog )
				DoRedraw( DialogData->Dialog, &Rect, WNAMES_CHANNELS, Global );
			break;
		case	8:
			SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_CHANNELS_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AB].ob_spec.iconblk );
			if( DialogData->Dialog )
				DoRedraw( DialogData->Dialog, &Rect, WNAMES_CHANNELS, Global );
			break;
		case	9:
			SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_SERVER_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AUF].ob_spec.iconblk );
			if( DialogData->Dialog )
				DoRedraw( DialogData->Dialog, &Rect, WNAMES_SERVER, Global );
			break;
		case	10:
			SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_SERVER_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AB].ob_spec.iconblk );
			if( DialogData->Dialog )
				DoRedraw( DialogData->Dialog, &Rect, WNAMES_SERVER, Global );
			break;
		case	11:
			SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_HOST_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AUF].ob_spec.iconblk );
			if( DialogData->Dialog )
				DoRedraw( DialogData->Dialog, &Rect, WNAMES_HOST, Global );
			break;
		case	12:
			SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_HOST_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AB].ob_spec.iconblk );
			if( DialogData->Dialog )
				DoRedraw( DialogData->Dialog, &Rect, WNAMES_HOST, Global );
			break;
		case	13:
			SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_IDLE_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AUF].ob_spec.iconblk );
			if( DialogData->Dialog )
				DoRedraw( DialogData->Dialog, &Rect, WNAMES_IDLE, Global );
			break;
		case	14:
			SetIconBlk( FreeIconBlk( DialogData->Tree[WNAMES_IDLE_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AB].ob_spec.iconblk );
			if( DialogData->Dialog )
				DoRedraw( DialogData->Dialog, &Rect, WNAMES_IDLE, Global );
			break;
	}
}

static WORD	HndlMesagDialog( void *DialogData, EVNT *Events, WORD Global[15] )
{
	switch( Events->msg[0] )
	{
		case	WIN_CMD:
		{
			if( Events->msg[4] == WIN_KONTEXT_1 )
			{
				WORD	ColourTable[COLOUR_MAX], i;
				for( i = 0; i < COLOUR_MAX; i++ )
				{
					ColourTable[i] = mt_list_get_colourtable((( DIALOG_DATA * ) DialogData )->Tree, WNAMES_OUTPUT, i, Global );
					TreeAddr[POPUP_COLOURTABLE][ColourTableObj[i]].ob_state |= DISABLED;
				}
				TreeAddr[POPUP_COLOURTABLE][ColourTableRef[COLOUR_USER]].ob_state &= ~DISABLED;
				TreeAddr[POPUP_COLOURTABLE][ColourTableRef[COLOUR_USER_OP]].ob_state &= ~DISABLED;
				TreeAddr[POPUP_COLOURTABLE][ColourTableRef[COLOUR_USER_IRCOP]].ob_state &= ~DISABLED;
				TreeAddr[POPUP_COLOURTABLE][ColourTableRef[COLOUR_USER_BACK]].ob_state &= ~DISABLED;
				if( ColourTablePopup( ColourTable, Global ) == E_OK )
				{
					GRECT		Rect;
					OBJECT	*DialogTree;
					MT_wdlg_get_tree((( DIALOG_DATA * ) DialogData )->Dialog, &DialogTree, &Rect, Global );
					mt_list_set_colour((( DIALOG_DATA * ) DialogData )->Tree, WNAMES_OUTPUT, ColourTable[COLOUR_USER], ColourTable[COLOUR_USER_BACK], Global );
					for( i = 0; i < COLOUR_MAX; i++ )
						mt_list_set_colourtable((( DIALOG_DATA * ) DialogData )->Tree, WNAMES_OUTPUT, ColourTable[i], i, Global );
					DoRedraw((( DIALOG_DATA * ) DialogData )->Dialog, &Rect, WNAMES_OUTPUT, Global );
				}
			}
			break;
		}
		case	COLOR_ID:
		{
			WORD	Obj;
			OBJECT		*DialogTree;
			GRECT			Rect;
			MT_wdlg_get_tree((( DIALOG_DATA * ) DialogData)->Dialog, &DialogTree, &Rect, Global );
			mt_list_set_colour( DialogTree, WNAMES_OUTPUT, -1, Events->msg[5], Global );
			DoRedraw((( DIALOG_DATA * ) DialogData)->Dialog, &Rect, WNAMES_OUTPUT, Global );
/* Test, ob Einstellungsdialog offen ist */
			return( E_OK );
		}
		case	FONT_CHANGED:
		{
			WORD	Obj;
			OBJECT		*DialogTree;
			GRECT			Rect;
			WORD			Id, Ht, Pix, Mono, BColour, TColour;
			MT_wdlg_get_tree((( DIALOG_DATA * ) DialogData)->Dialog, &DialogTree, &Rect, Global );
			mt_list_get_font( DialogTree, WNAMES_OUTPUT, &Id, &Ht, &Pix, &Mono, Global );
			mt_list_get_colour( DialogTree, WNAMES_OUTPUT, &TColour, &BColour, Global );
			Id = Events->msg[4] ? Events->msg[4] : Id;
			if( Events->msg[5] )
			{
				if(( Ht = Events->msg[5] ) < 0 )
				{
					Pix = 1;
					Ht *= -1;
				}
				else
					Pix = 0;
			}
			TColour = Events->msg[6] != -1 ? Events->msg[6] : TColour;
			if( Events->msg[7] != -1 && ( Events->msg[7] & 0x1000 ))
				Mono = 1;
			else
				Mono = 0;
			mt_list_set_font( DialogTree, WNAMES_OUTPUT, Id, Ht, Pix, Mono, Global );
			mt_list_set_colour( DialogTree, WNAMES_OUTPUT, TColour, BColour, Global );
			DoRedraw((( DIALOG_DATA * ) DialogData)->Dialog, &Rect, WNAMES_OUTPUT, Global );
			SetVSlide( DialogData, Global );
			return( E_OK );
		}
	}
	return( E_OK );
}
static WORD	HndlClsDialog( void *DialogData, WORD Global[15] )
{
	NAMES_WINDOW	*NamesWindow = ( NAMES_WINDOW * )(( DIALOG_DATA * ) DialogData )->UserData;
	IRC_CHANNEL	*IrcChannel = NamesWindow->IrcChannel;
	NamesWindowWrite( IrcChannel, Global );
	mt_list_delete((( DIALOG_DATA *) DialogData)->Tree, WNAMES_OUTPUT, Global );
	if( NamesWindow->Title )
		free( NamesWindow->Title );
	FreeTree((( DIALOG_DATA *) DialogData)->Tree );
	free( DialogData );
	IrcChannel->ListWindow = NULL;
	free( NamesWindow );
	CloseIrcChannel( IrcChannel );
	return( E_OK );
}

static void	SwitchDialog( DIALOG_DATA *DialogData, WORD Global[15] )
{
	OBJECT	*DialogTree = DialogData->Tree;
	WORD	Dx, NewRh, OldRh;
	( DialogTree[WNAMES_SWITCH].ob_state & SELECTED ) ? ( DialogTree[WNAMES_SWITCH].ob_state &= ~SELECTED ) : ( DialogTree[WNAMES_SWITCH].ob_state |= SELECTED );
	if( DialogTree[WNAMES_SWITCH].ob_state & SELECTED )
	{
		WORD	Min = DialogTree[WNAMES_WIDTH].ob_width + DialogTree[WNAMES_HELP].ob_width + DialogTree[WNAMES_OUTPUT_PARENT1].ob_x;
		Dx = DialogTree[ROOT].ob_width - Min;

		DialogTree[ROOT].ob_width -= Dx;
		DialogTree[WNAMES_HELP].ob_x -= Dx;

		DialogTree[WNAMES_OUTPUT_PARENT1].ob_width -= Dx;
		DialogTree[WNAMES_OUTPUT_PARENT2].ob_width -= Dx;
		DialogTree[WNAMES_OUTPUT].ob_width -= Dx;

		DialogTree[WNAMES_NICKNAME].ob_width = DialogTree[ROOT].ob_width - 2 * DialogTree[WNAMES_OUTPUT_PARENT1].ob_x;

		DialogTree[WNAMES_USERNAME].ob_x = DialogTree[WNAMES_NICKNAME].ob_width;
		DialogTree[WNAMES_REALNAME].ob_x = DialogTree[WNAMES_USERNAME].ob_x + DialogTree[WNAMES_USERNAME].ob_width;
		DialogTree[WNAMES_CHANNELS].ob_x = DialogTree[WNAMES_REALNAME].ob_x + DialogTree[WNAMES_REALNAME].ob_width;
		DialogTree[WNAMES_SERVER].ob_x = DialogTree[WNAMES_CHANNELS].ob_x + DialogTree[WNAMES_CHANNELS].ob_width;
		DialogTree[WNAMES_HOST].ob_x = DialogTree[WNAMES_SERVER].ob_x + DialogTree[WNAMES_SERVER].ob_width;
		DialogTree[WNAMES_IDLE].ob_x = DialogTree[WNAMES_HOST].ob_x + DialogTree[WNAMES_HOST].ob_width;

		DialogTree[WNAMES_USERNAME].ob_flags |= HIDETREE;
		DialogTree[WNAMES_REALNAME].ob_flags |= HIDETREE;
		DialogTree[WNAMES_CHANNELS].ob_flags |= HIDETREE;
		DialogTree[WNAMES_SERVER].ob_flags |= HIDETREE;
		DialogTree[WNAMES_HOST].ob_flags |= HIDETREE;
		DialogTree[WNAMES_IDLE].ob_flags |= HIDETREE;

	}
	else
	{
		Dx = DialogTree[WNAMES_USERNAME].ob_width + DialogTree[WNAMES_REALNAME].ob_width + DialogTree[WNAMES_CHANNELS].ob_width + DialogTree[WNAMES_SERVER].ob_width + DialogTree[WNAMES_HOST].ob_width + DialogTree[WNAMES_IDLE].ob_width;
		DialogTree[ROOT].ob_width += Dx;
		DialogTree[WNAMES_HELP].ob_x += Dx;
		DialogTree[WNAMES_OUTPUT_PARENT1].ob_width += Dx;
		DialogTree[WNAMES_OUTPUT_PARENT2].ob_width += Dx;
		DialogTree[WNAMES_OUTPUT].ob_width += Dx;

		DialogTree[WNAMES_USERNAME].ob_flags &= ~HIDETREE;
		DialogTree[WNAMES_REALNAME].ob_flags &= ~HIDETREE;
		DialogTree[WNAMES_CHANNELS].ob_flags &= ~HIDETREE;
		DialogTree[WNAMES_SERVER].ob_flags &= ~HIDETREE;
		DialogTree[WNAMES_HOST].ob_flags &= ~HIDETREE;
		DialogTree[WNAMES_IDLE].ob_flags &= ~HIDETREE;

		DialogTree[WNAMES_CTCP].ob_flags &= ~HIDETREE;
		DialogTree[WNAMES_VOICE].ob_flags &= ~HIDETREE;
		DialogTree[WNAMES_DEVOICE].ob_flags &= ~HIDETREE;
		DialogTree[WNAMES_KICK].ob_flags &= ~HIDETREE;
		DialogTree[WNAMES_BANKICK].ob_flags &= ~HIDETREE;
		DialogTree[WNAMES_BAN].ob_flags &= ~HIDETREE;
		DialogTree[WNAMES_DEBAN].ob_flags &= ~HIDETREE;
		DialogTree[WNAMES_OP].ob_flags &= ~HIDETREE;
		DialogTree[WNAMES_DEOP].ob_flags &= ~HIDETREE;
		DialogTree[WNAMES_MSG].ob_flags &= ~HIDETREE;
		DialogTree[WNAMES_INVITE].ob_flags &= ~HIDETREE;
		DialogTree[WNAMES_DCCCHAT].ob_flags &= ~HIDETREE;
		DialogTree[WNAMES_DCCFILE].ob_flags &= ~HIDETREE;
	}
	mt_list_resize( DialogData->Tree, WNAMES_OUTPUT, &NewRh, &OldRh, Global );
	SetColumns( DialogData, Global );
}

static void SizeDialog( DIALOG_DATA *DialogData, GRECT *Pos, WORD Global[15] )
{
	GRECT	New;
	WORD	Dw, Dh, NewRh, OldRh;

	MT_wind_calc( WC_WORK, NAMES_WINDOW_KINDS, Pos, &New, Global );

	Dw = New.g_w - DialogData->Tree[ROOT].ob_width;
	Dh = New.g_h - DialogData->Tree[ROOT].ob_height;

	if( DialogData->Tree[WNAMES_SWITCH].ob_state & SELECTED )
	{
		WORD	Min = TreeAddr[WNAMES][WNAMES_NICKNAME].ob_width + 2 * TreeAddr[WNAMES][WNAMES_OUTPUT_PARENT1].ob_x;
		if( DialogData->Tree[ROOT].ob_width + Dw < Min )
			Dw = Min - DialogData->Tree[ROOT].ob_width;

		DialogData->Tree[WNAMES_NICKNAME].ob_width += Dw;
		DialogData->Tree[WNAMES_USERNAME].ob_x += Dw;
		DialogData->Tree[WNAMES_REALNAME].ob_x += Dw;
		DialogData->Tree[WNAMES_CHANNELS].ob_x += Dw;
		DialogData->Tree[WNAMES_SERVER].ob_x += Dw;
		DialogData->Tree[WNAMES_HOST].ob_x += Dw;
		DialogData->Tree[WNAMES_IDLE].ob_x += Dw;
	}
	else
	{
		if( New.g_w < TreeAddr[WNAMES][ROOT].ob_width )
			Dw = TreeAddr[WNAMES][ROOT].ob_width - DialogData->Tree[ROOT].ob_width;
		{
			WORD	R = 0, D = Dw;
			if( DialogData->Tree[WNAMES_IDLE].ob_width + D >= TreeAddr[WNAMES][WNAMES_IDLE].ob_width )
				DialogData->Tree[WNAMES_IDLE].ob_width += D;
			else
			{
				R = TreeAddr[WNAMES][WNAMES_IDLE].ob_width - DialogData->Tree[WNAMES_IDLE].ob_width;
				DialogData->Tree[WNAMES_IDLE].ob_width += R;
				D -= R;
				if( DialogData->Tree[WNAMES_HOST].ob_width + D >= TreeAddr[WNAMES][WNAMES_HOST].ob_width )
					DialogData->Tree[WNAMES_HOST].ob_width += D;
				else
				{
					R = TreeAddr[WNAMES][WNAMES_HOST].ob_width - DialogData->Tree[WNAMES_HOST].ob_width;
					DialogData->Tree[WNAMES_HOST].ob_width += R;
					D -= R;
					if( DialogData->Tree[WNAMES_SERVER].ob_width + D >= TreeAddr[WNAMES][WNAMES_SERVER].ob_width )
						DialogData->Tree[WNAMES_SERVER].ob_width += D;
					else
					{
						R = TreeAddr[WNAMES][WNAMES_SERVER].ob_width - DialogData->Tree[WNAMES_SERVER].ob_width;
						DialogData->Tree[WNAMES_SERVER].ob_width += R;
						D -= R;
						if( DialogData->Tree[WNAMES_CHANNELS].ob_width + D >= TreeAddr[WNAMES][WNAMES_CHANNELS].ob_width )
							DialogData->Tree[WNAMES_CHANNELS].ob_width += D;
						else
						{
							R = TreeAddr[WNAMES][WNAMES_CHANNELS].ob_width - DialogData->Tree[WNAMES_CHANNELS].ob_width;
							DialogData->Tree[WNAMES_CHANNELS].ob_width += R;
							D -= R;
							if( DialogData->Tree[WNAMES_REALNAME].ob_width + D >= TreeAddr[WNAMES][WNAMES_REALNAME].ob_width )
								DialogData->Tree[WNAMES_REALNAME].ob_width += D;
							else
							{
								R = TreeAddr[WNAMES][WNAMES_REALNAME].ob_width - DialogData->Tree[WNAMES_REALNAME].ob_width;
								DialogData->Tree[WNAMES_REALNAME].ob_width += R;
								D -= R;
								if( DialogData->Tree[WNAMES_USERNAME].ob_width + D >= TreeAddr[WNAMES][WNAMES_USERNAME].ob_width )
									DialogData->Tree[WNAMES_USERNAME].ob_width += D;
								else
								{
									R = TreeAddr[WNAMES][WNAMES_USERNAME].ob_width - DialogData->Tree[WNAMES_USERNAME].ob_width;
									DialogData->Tree[WNAMES_USERNAME].ob_width += R;
									D -= R;
									if( DialogData->Tree[WNAMES_NICKNAME].ob_width + D >= TreeAddr[WNAMES][WNAMES_NICKNAME].ob_width )
										DialogData->Tree[WNAMES_NICKNAME].ob_width += D;
									else
									{
										R = TreeAddr[WNAMES][WNAMES_NICKNAME].ob_width - DialogData->Tree[WNAMES_NICKNAME].ob_width;
										DialogData->Tree[WNAMES_NICKNAME].ob_width += R;
										D -= R;
									}
								}
							}
						}
					}
				}
				DialogData->Tree[WNAMES_USERNAME].ob_x = DialogData->Tree[WNAMES_NICKNAME].ob_x + DialogData->Tree[WNAMES_NICKNAME].ob_width;
				DialogData->Tree[WNAMES_REALNAME].ob_x = DialogData->Tree[WNAMES_USERNAME].ob_x + DialogData->Tree[WNAMES_USERNAME].ob_width;
				DialogData->Tree[WNAMES_CHANNELS].ob_x = DialogData->Tree[WNAMES_REALNAME].ob_x + DialogData->Tree[WNAMES_REALNAME].ob_width;
				DialogData->Tree[WNAMES_SERVER].ob_x = DialogData->Tree[WNAMES_CHANNELS].ob_x + DialogData->Tree[WNAMES_CHANNELS].ob_width;
				DialogData->Tree[WNAMES_HOST].ob_x = DialogData->Tree[WNAMES_SERVER].ob_x + DialogData->Tree[WNAMES_SERVER].ob_width;
				DialogData->Tree[WNAMES_IDLE].ob_x = DialogData->Tree[WNAMES_HOST].ob_x + DialogData->Tree[WNAMES_HOST].ob_width;
			}
		}
	}

	if( New.g_h < TreeAddr[WNAMES][ROOT].ob_height )
		Dh = TreeAddr[WNAMES][ROOT].ob_height - DialogData->Tree[ROOT].ob_height;

	DialogData->Tree[ROOT].ob_width += Dw;
	DialogData->Tree[ROOT].ob_height += Dh;

	DialogData->Tree[WNAMES_OUTPUT_PARENT1].ob_width += Dw;
	DialogData->Tree[WNAMES_OUTPUT_PARENT1].ob_height += Dh;
	DialogData->Tree[WNAMES_OUTPUT_PARENT2].ob_width += Dw;
	DialogData->Tree[WNAMES_OUTPUT_PARENT2].ob_height += Dh;
	DialogData->Tree[WNAMES_OUTPUT].ob_width += Dw;
	DialogData->Tree[WNAMES_OUTPUT].ob_height += Dh;

	DialogData->Tree[WNAMES_HELP].ob_x += Dw;

	if( Dh || Dw )
	{
		mt_list_resize( DialogData->Tree, WNAMES_OUTPUT, &NewRh, &OldRh, Global );
		if( Dw )
		{
			if( DialogData->Tree[ROOT].ob_width - DialogData->Tree[WNAMES_HELP].ob_width < DialogData->Tree[WNAMES_CTCP].ob_x + DialogData->Tree[WNAMES_CTCP].ob_width + 16 )
				DialogData->Tree[WNAMES_CTCP].ob_flags |= HIDETREE;
			else
				DialogData->Tree[WNAMES_CTCP].ob_flags &= ~HIDETREE;
			if( DialogData->Tree[ROOT].ob_width - DialogData->Tree[WNAMES_HELP].ob_width < DialogData->Tree[WNAMES_VOICE].ob_x + DialogData->Tree[WNAMES_VOICE].ob_width + 16 )
			{
				DialogData->Tree[WNAMES_VOICE].ob_flags |= HIDETREE;
				DialogData->Tree[WNAMES_DEVOICE].ob_flags |= HIDETREE;
			}
			else
			{
				DialogData->Tree[WNAMES_VOICE].ob_flags &= ~HIDETREE;
				DialogData->Tree[WNAMES_DEVOICE].ob_flags &= ~HIDETREE;
			}
			if( DialogData->Tree[ROOT].ob_width - DialogData->Tree[WNAMES_HELP].ob_width < DialogData->Tree[WNAMES_KICK].ob_x + DialogData->Tree[WNAMES_KICK].ob_width + 16 )
			{
				DialogData->Tree[WNAMES_KICK].ob_flags |= HIDETREE;
				DialogData->Tree[WNAMES_BANKICK].ob_flags |= HIDETREE;
			}
			else
			{
				DialogData->Tree[WNAMES_KICK].ob_flags &= ~HIDETREE;
				DialogData->Tree[WNAMES_BANKICK].ob_flags &= ~HIDETREE;
			}
			if( DialogData->Tree[ROOT].ob_width - DialogData->Tree[WNAMES_HELP].ob_width < DialogData->Tree[WNAMES_BAN].ob_x + DialogData->Tree[WNAMES_BAN].ob_width + 16 )
			{
				DialogData->Tree[WNAMES_BAN].ob_flags |= HIDETREE;
				DialogData->Tree[WNAMES_DEBAN].ob_flags |= HIDETREE;
			}
			else
			{
				DialogData->Tree[WNAMES_BAN].ob_flags &= ~HIDETREE;
				DialogData->Tree[WNAMES_DEBAN].ob_flags &= ~HIDETREE;
			}
			if( DialogData->Tree[ROOT].ob_width - DialogData->Tree[WNAMES_HELP].ob_width < DialogData->Tree[WNAMES_OP].ob_x + DialogData->Tree[WNAMES_OP].ob_width + 16 )
			{
				DialogData->Tree[WNAMES_OP].ob_flags |= HIDETREE;
				DialogData->Tree[WNAMES_DEOP].ob_flags |= HIDETREE;
			}
			else
			{
				DialogData->Tree[WNAMES_OP].ob_flags &= ~HIDETREE;
				DialogData->Tree[WNAMES_DEOP].ob_flags &= ~HIDETREE;
			}
			if( DialogData->Tree[ROOT].ob_width - DialogData->Tree[WNAMES_HELP].ob_width < DialogData->Tree[WNAMES_MSG].ob_x + DialogData->Tree[WNAMES_MSG].ob_width + 16 )
			{
				DialogData->Tree[WNAMES_MSG].ob_flags |= HIDETREE;
				DialogData->Tree[WNAMES_INVITE].ob_flags |= HIDETREE;
			}
			else
			{
				DialogData->Tree[WNAMES_MSG].ob_flags &= ~HIDETREE;
				DialogData->Tree[WNAMES_INVITE].ob_flags &= ~HIDETREE;
			}
			if( DialogData->Tree[ROOT].ob_width - DialogData->Tree[WNAMES_HELP].ob_width < DialogData->Tree[WNAMES_DCCCHAT].ob_x + DialogData->Tree[WNAMES_DCCCHAT].ob_width + 16 )
			{
				DialogData->Tree[WNAMES_DCCCHAT].ob_flags |= HIDETREE;
				DialogData->Tree[WNAMES_DCCFILE].ob_flags |= HIDETREE;
			}
			else
			{
				DialogData->Tree[WNAMES_DCCCHAT].ob_flags &= ~HIDETREE;
				DialogData->Tree[WNAMES_DCCFILE].ob_flags &= ~HIDETREE;
			}
			SetColumns( DialogData, Global );
		}

		if( DialogData->Dialog )
		{
			MT_wdlg_set_tree( DialogData->Dialog, DialogData->Tree, Global );
			SetVSlide( DialogData, Global );
		}
	}
}
static void	SetVSlide( DIALOG_DATA *DialogData, WORD Global[15] )
{
	LONG	nLines, yScroll;
	WORD	yVis, nCols, xScroll, xVis;
	WORD	WinId = MT_wdlg_get_handle( DialogData->Dialog, Global );
	WORD	Pos, Size;
	mt_list_get_scrollinfo( DialogData->Tree, WNAMES_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
	Size = nLines - yVis > 0 ? ( WORD ) (( yVis * 1000 ) / nLines ) : 1000;
	Pos = nLines - yVis > 0 ? ( WORD ) (( yScroll *1000 ) / ( nLines - yVis )) : 0;
	MT_wind_set_int( WinId, WF_VSLSIZE, Size, Global );
	MT_wind_set_int( WinId, WF_VSLIDE, Pos, Global );
}

static void	SetInfo( NAMES_WINDOW *NamesWindow, WORD Global[15] )
{
	LONG	nLines, yScroll;
	WORD	yVis, nCols, xScroll, xVis;
	mt_list_get_scrollinfo( NamesWindow->DialogData->Tree, WNAMES_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );

	sprintf( NamesWindow->Info, " %li %s", nLines, TreeAddr[INFOS][N_USERS].ob_spec.free_string );
	MT_wind_set_string( NamesWindow->WinId, WF_INFO, NamesWindow->Info, Global );
}

static void SetColumns( DIALOG_DATA *DialogData, WORD Global[15] )
{
	WORD	Width[6];
	Width[0] = DialogData->Tree[WNAMES_NICKNAME].ob_width;
	Width[1] = DialogData->Tree[WNAMES_USERNAME].ob_width;
	Width[2] = DialogData->Tree[WNAMES_REALNAME].ob_width;
	Width[3] = DialogData->Tree[WNAMES_CHANNELS].ob_width;
	Width[4] = DialogData->Tree[WNAMES_SERVER].ob_width;
	Width[5] = DialogData->Tree[WNAMES_HOST].ob_width;
	Width[6] = DialogData->Tree[WNAMES_IDLE].ob_width;
	mt_list_set_format( DialogData->Tree, WNAMES_OUTPUT, Width, Global );
	if( DialogData->Dialog )
	{
		OBJECT		*DialogTree;
		GRECT			Rect;
		MT_wdlg_get_tree( DialogData->Dialog, &DialogTree, &Rect, Global );
		DoRedrawX( DialogData->Dialog, &Rect, Global, WNAMES_NICKNAME, WNAMES_USERNAME, WNAMES_REALNAME, WNAMES_CHANNELS, WNAMES_SERVER, WNAMES_HOST, WNAMES_IDLE, WNAMES_OUTPUT, EDRX );
	}
}

static WORD	NamesWindowRead( IRC_CHANNEL *IrcChannel, GRECT *Work, WORD *Id, WORD *Ht, WORD ColourTable[], LONG *yScroll, WORD Width[7], WORD *Sort, WORD *Switch, WORD Global[15] )
{
	FILE	*File = NULL;
	XATTR	Xattr;
	BYTE	*Path, *HomePath, *DefaultPath;
	GetFilename( "User", IrcChannel->Name, &Path, &HomePath, &DefaultPath );

	if( DefaultPath && Fxattr( 0, DefaultPath, &Xattr ) == E_OK )
		File = fopen( DefaultPath, "r" );
	else	if( HomePath && Fxattr( 0, HomePath, &Xattr ) == E_OK )
		File = fopen( HomePath, "r" );
	else	if( Path && Fxattr( 0, Path, &Xattr ) == E_OK )
		File = fopen( Path, "r" );

	if( Path )
		free( Path );
	if( HomePath )
		free( HomePath );
	if( DefaultPath )
		free( DefaultPath );

	if( File )
	{
		BYTE	Puf[512], Version[32];

		fscanf( File, "%s\n", Version );
		fscanf( File, "%i, %i, %i, %i\n", &( Work->g_x ), &( Work->g_y ), &( Work->g_w ), &( Work->g_h ));
		fscanf( File, "%i, %i\n", Id, Ht );
		fgets( Puf, 512, File );

		ReadColourTable( atof( Version ), Puf, ColourTable );

		fscanf( File, "%li, %i, %i, %i, %i, %i, %i, %i, %i\n", yScroll, &Width[0], &Width[1], &Width[2], &Width[3], &Width[4], &Width[5], &Width[6], Sort );
		fscanf( File, "%i\n", Switch );
		fclose( File );

		return( E_OK );
	}
	return( ERROR );
}
static WORD	NamesWindowWrite( IRC_CHANNEL *IrcChannel, WORD Global[15] )
{
	NAMES_WINDOW	*NamesWindow = IrcChannel->ListWindow;
	IRC_SESSION	*IrcSession = IrcChannel->IrcSession;
	IRC	*Irc = IrcSession->Irc;
	FILE	*File = NULL;
	BYTE	*Path, *HomePath, *DefaultPath;

	GetFilename( "User", IrcChannel->Name, &Path, &HomePath, &DefaultPath );

	if( DefaultPath )
		File = fopen( DefaultPath, "w" );
	else	if( HomePath )
		File = fopen( HomePath, "w" );
	else
		File = fopen( Path, "w" );

	if( Path )
		free( Path );
	if( HomePath )
		free( HomePath );
	if( DefaultPath )
		free( DefaultPath );

	if( File )
	{
		BYTE	**Item;
		LONG	nLines, yScroll, i;
		WORD	yVis, nCols, xScroll, xVis;
		WORD	Id, Ht, Pix, Mono, Sort;
		DIALOG_DATA	*DialogData = NamesWindow->DialogData;
		mt_list_get_scrollinfo( DialogData->Tree, WNAMES_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
		mt_list_get_font( DialogData->Tree, WNAMES_OUTPUT, &Id, &Ht, &Pix, &Mono, Global );
		Sort = mt_list_get_sort( DialogData->Tree, WNAMES_OUTPUT, Global );

		fprintf( File, "%s\n", VERSION );
		fprintf( File, "%i, %i, %i, %i\n", DialogData->Tree[ROOT].ob_x, DialogData->Tree[ROOT].ob_y, DialogData->Tree[ROOT].ob_width, DialogData->Tree[ROOT].ob_height );
		fprintf( File, "%i, %i\n", Id, Ht );
		for( i = 0; i < COLOUR_MAX - 1; i++ )
			fprintf( File, "%i, ", mt_list_get_colourtable( DialogData->Tree, WNAMES_OUTPUT, i, Global ));
		fprintf( File, "%i\n", 	mt_list_get_colourtable( DialogData->Tree, WNAMES_OUTPUT, i, Global ));
		fprintf( File, "%li, %i, %i, %i, %i, %i, %i, %i, %i\n", yScroll, DialogData->Tree[WNAMES_NICKNAME].ob_width, DialogData->Tree[WNAMES_USERNAME].ob_width, DialogData->Tree[WNAMES_REALNAME].ob_width, DialogData->Tree[WNAMES_CHANNELS].ob_width, DialogData->Tree[WNAMES_SERVER].ob_width, DialogData->Tree[WNAMES_HOST].ob_width, DialogData->Tree[WNAMES_IDLE].ob_width, Sort );
		fprintf( File, "%i\n", ( DialogData->Tree[WNAMES_SWITCH].ob_state & SELECTED ) ? 1 : 0 );

		fclose( File );

		return( E_OK );
	}
	MT_form_alert( 1, TreeAddr[ALERTS][ERROR_WRITING_USER].ob_spec.free_string, Global );
	return( ERROR );
}

WORD	NamesWindowAppend( IRC_CHANNEL *IrcChannel, WORD Flag, BYTE *Nickname, BYTE *Username, BYTE *Realname, BYTE *Channels, BYTE *Server, BYTE *Host, BYTE *Idle, WORD Colour, WORD Global[15] )
{
	NAMES_WINDOW *NamesWindow = IrcChannel->ListWindow;
	if( NamesWindow )
	{
		DIALOG_DATA	*DialogData = NamesWindow->DialogData;
		BYTE	*Item[7], **Tmp;
		LONG	nLines, yScroll, i;
		WORD	yVis, nCols, xScroll, xVis, lColour;

		mt_list_get_scrollinfo( DialogData->Tree, WNAMES_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
		for( i = 0; i < nLines; i++ )
		{
			Tmp = mt_list_get_item( DialogData->Tree, WNAMES_OUTPUT, i, &lColour, Global );
			if( !strcmp( Tmp[0], Nickname ))
			{
/* Channels kann eigentlich mehrmals gesendet werden -> nicht l”schen, sondern anh„ngen */
				BYTE	*U = NULL, *R = NULL, *C = NULL, *S = NULL, *H = NULL, *I = NULL;
				if( !Username && Tmp[1] )
					U = strdup( Tmp[1] );
				if( !Realname && Tmp[2] )
					R = strdup( Tmp[2] );
				if( !Channels && Tmp[3] )
					C = strdup( Tmp[3] );
				if( !Server && Tmp[4] )
					S = strdup( Tmp[4] );
				if( !Host && Tmp[5] )
					H = strdup( Tmp[5] );
				if( !Idle && Tmp[6] )
					I = strdup( Tmp[6] );
				mt_list_delete_item( DialogData->Tree, WNAMES_OUTPUT, i, Global );

				if( Flag )
				{
					Item[0] = Nickname;
					Item[1] = Username ? Username : U;
					Item[2] = Realname ? Realname : R;
					Item[3] = Channels ? Channels : C;
					Item[4] = Server ? Server : S;
					Item[5] = Host ? Host : H;
					Item[6] = Idle ? Idle : I;
					mt_list_attach_item( DialogData->Tree, WNAMES_OUTPUT, Item, lColour, 1, Global );

					{
						LONG	yScrollOld = yScroll;
						mt_list_get_scrollinfo( DialogData->Tree, WNAMES_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
						if( yScroll != yScrollOld )
							mt_list_scroll( DialogData->Tree, WNAMES_OUTPUT, NamesWindow->WinId, yScrollOld - yScroll, 0, Global );
					}

					if( U )
						free( U );
					if( R )
						free( R );
					if( C )
						free( C );
					if( S )
						free( S );
					if( H )
						free( H );
					if( I )
						free( I );
					return( E_OK );
				}
				else
					break;
			}
		}

		if( !Flag )
		{
			Item[0] = Nickname;
			Item[1] = Username;
			Item[2] = Realname;
			Item[3] = Channels;
			Item[4] = Server;
			Item[5] = Host;
			Item[6] = Idle;
			mt_list_attach_item( DialogData->Tree, WNAMES_OUTPUT, Item, Colour, 1, Global );
			if( !strcmp( Nickname, (( IRC_SESSION * )( IrcChannel->IrcSession ))->Irc->Nickname ))
			{
				if( Colour == COLOUR_USER_OP && !( IrcChannel->ChannelFlag & MODE_OP ))
				{
					IrcChannel->ChannelFlag |= MODE_OP;
					SetButtons( DialogData, Global );
				}
				if( Colour == COLOUR_USER && ( IrcChannel->ChannelFlag & MODE_OP ))
				{
					IrcChannel->ChannelFlag &= ~MODE_OP;
					SetButtons( DialogData, Global );
				}
			}
		}
	}
	return( E_OK );
}

static void SetButtons( DIALOG_DATA *DialogData, WORD Global[15] )
{
	NAMES_WINDOW	*NamesWindow = ( NAMES_WINDOW * ) DialogData->UserData;
	IRC_CHANNEL	*IrcChannel = ( IRC_CHANNEL * ) NamesWindow->IrcChannel;
	OBJECT			*DialogTree;
	GRECT				Rect;

	if( DialogData->Dialog )
		MT_wdlg_get_tree( DialogData->Dialog, &DialogTree, &Rect, Global );

	if(( IrcChannel->ChannelFlag & MODE_OP ))
	{
		if(( DialogData->Tree[WNAMES_OP].ob_state & DISABLED ))
		{
			DialogData->Tree[WNAMES_OP].ob_state &= ~DISABLED;
			DialogData->Tree[WNAMES_OP].ob_flags |= SELECTABLE;
			DialogData->Tree[WNAMES_DEOP].ob_state &= ~DISABLED;
			DialogData->Tree[WNAMES_DEOP].ob_flags |= SELECTABLE;
			DialogData->Tree[WNAMES_KICK].ob_state &= ~DISABLED;
			DialogData->Tree[WNAMES_KICK].ob_flags |= SELECTABLE;
			DialogData->Tree[WNAMES_BAN].ob_state &= ~DISABLED;
			DialogData->Tree[WNAMES_BAN].ob_flags |= SELECTABLE;
			DialogData->Tree[WNAMES_DEBAN].ob_state &= ~DISABLED;
			DialogData->Tree[WNAMES_DEBAN].ob_flags |= SELECTABLE;
			DialogData->Tree[WNAMES_BANKICK].ob_state &= ~DISABLED;
			DialogData->Tree[WNAMES_BANKICK].ob_flags |= SELECTABLE;
			if( DialogData->Dialog )
				DoRedrawX( DialogData->Dialog, &Rect, Global, WNAMES_OP, WNAMES_DEOP, WNAMES_KICK, WNAMES_BAN, WNAMES_BANKICK, EDRX );
		}
		if( IrcChannel->ChannelFlag & MODE_MODERATED )
		{
			if(( DialogData->Tree[WNAMES_VOICE].ob_state & DISABLED ))
			{
				DialogData->Tree[WNAMES_VOICE].ob_state &= ~DISABLED;
				DialogData->Tree[WNAMES_VOICE].ob_flags |= SELECTABLE;
				DialogData->Tree[WNAMES_DEVOICE].ob_state &= ~DISABLED;
				DialogData->Tree[WNAMES_DEVOICE].ob_flags |= SELECTABLE;
				if( DialogData->Dialog )
					DoRedrawX( DialogData->Dialog, &Rect, Global, WNAMES_VOICE, WNAMES_DEVOICE, EDRX );
			}
		}
		else
		{
			if( !( DialogData->Tree[WNAMES_VOICE].ob_state & DISABLED ))
			{
				DialogData->Tree[WNAMES_VOICE].ob_state |= DISABLED;
				DialogData->Tree[WNAMES_VOICE].ob_flags &= ~SELECTABLE;
				DialogData->Tree[WNAMES_DEVOICE].ob_state |= DISABLED;
				DialogData->Tree[WNAMES_DEVOICE].ob_flags &= ~SELECTABLE;
				if( DialogData->Dialog )
					DoRedrawX( DialogData->Dialog, &Rect, Global, WNAMES_VOICE, WNAMES_DEVOICE, EDRX );
			}
		}
	}
	if( !( IrcChannel->ChannelFlag & MODE_OP ))
	{
		if( !( DialogData->Tree[WNAMES_OP].ob_state & DISABLED ))
		{
			DialogData->Tree[WNAMES_OP].ob_state |= DISABLED;
			DialogData->Tree[WNAMES_OP].ob_flags &= ~SELECTABLE;
			DialogData->Tree[WNAMES_DEOP].ob_state |= DISABLED;
			DialogData->Tree[WNAMES_DEOP].ob_flags &= ~SELECTABLE;
			DialogData->Tree[WNAMES_KICK].ob_state |= DISABLED;
			DialogData->Tree[WNAMES_KICK].ob_flags &= ~SELECTABLE;
			DialogData->Tree[WNAMES_BAN].ob_state |= DISABLED;
			DialogData->Tree[WNAMES_BAN].ob_flags &= ~SELECTABLE;
			DialogData->Tree[WNAMES_DEBAN].ob_state |= DISABLED;
			DialogData->Tree[WNAMES_DEBAN].ob_flags &= ~SELECTABLE;
			DialogData->Tree[WNAMES_BANKICK].ob_state |= DISABLED;
			DialogData->Tree[WNAMES_BANKICK].ob_flags &= ~SELECTABLE;
			DialogData->Tree[WNAMES_VOICE].ob_state |= DISABLED;
			DialogData->Tree[WNAMES_VOICE].ob_flags &= ~SELECTABLE;
			DialogData->Tree[WNAMES_DEVOICE].ob_state |= DISABLED;
			DialogData->Tree[WNAMES_DEVOICE].ob_flags &= ~SELECTABLE;
			if( DialogData->Dialog )
				DoRedrawX( DialogData->Dialog, &Rect, Global, WNAMES_OP, WNAMES_DEOP, WNAMES_KICK, WNAMES_BAN, WNAMES_BANKICK, WNAMES_VOICE, WNAMES_DEVOICE, WNAMES_CTCP, EDRX );
		}
	}
}

WORD	IsInNamesWindow( IRC_CHANNEL *IrcChannel, BYTE *Nickname, WORD *Colour, WORD Global[15] )
{
	NAMES_WINDOW *NamesWindow = IrcChannel->ListWindow;
	if( NamesWindow )
	{
		LONG	nLines, yScroll, i;
		WORD	yVis, nCols, xScroll, xVis;
		DIALOG_DATA	*DialogData = NamesWindow->DialogData;
		BYTE	**Item;
		mt_list_get_scrollinfo( DialogData->Tree, WNAMES_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
		for( i = 0; i < nLines; i++ )
		{
			Item = mt_list_get_item( DialogData->Tree, WNAMES_OUTPUT, i, Colour, Global );
			if( !strcmp( Item[0], Nickname ))
				return( 1 );
		}
	}
	return( 0 );
}
void	NamesWindowDelete( IRC_CHANNEL *IrcChannel, BYTE *Nickname, WORD Global[15] )
{
	NAMES_WINDOW *NamesWindow = IrcChannel->ListWindow;
	if( NamesWindow )
	{
		LONG	nLines, yScroll, i;
		WORD	yVis, nCols, xScroll, xVis;
		DIALOG_DATA	*DialogData = NamesWindow->DialogData;
		BYTE	**Item;
		WORD	Colour;
		mt_list_get_scrollinfo( DialogData->Tree, WNAMES_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
		for( i = 0; i < nLines; i++ )
		{
			Item = mt_list_get_item( DialogData->Tree, WNAMES_OUTPUT, i, &Colour, Global );
			if( !strcmp( Item[0], Nickname ))
			{
				mt_list_delete_item( DialogData->Tree, WNAMES_OUTPUT, i, Global );
				break;
			}
		}
	}	
}
void	NamesWindowReset( IRC_CHANNEL *IrcChannel, WORD Global[15] )
{
	NAMES_WINDOW *NamesWindow = IrcChannel->ListWindow;
	if( NamesWindow )
	{
		LONG	nLines, yScroll, i;
		WORD	yVis, nCols, xScroll, xVis;
		DIALOG_DATA	*DialogData = NamesWindow->DialogData;
		mt_list_get_scrollinfo( DialogData->Tree, WNAMES_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
		for( i = 0; i < nLines; i++ )
			mt_list_delete_item( DialogData->Tree, WNAMES_OUTPUT, 0, Global );
	}
}

void	NamesWindowRedraw( IRC_CHANNEL *IrcChannel, WORD Global[15] )
{
	NAMES_WINDOW	*NamesWindow = IrcChannel->ListWindow;
	if( NamesWindow )
	{
		DIALOG_DATA	*DialogData = NamesWindow->DialogData;
		if( mt_list_get_dirty( DialogData->Tree, WNAMES_OUTPUT, Global ))
		{
			OBJECT		*DialogTree;
			GRECT			Rect;
			MT_wdlg_get_tree( DialogData->Dialog, &DialogTree, &Rect, Global );
			SetVSlide( DialogData, Global );
			mt_list_set_dirty( DialogData->Tree, WNAMES_OUTPUT, 0 , Global );
			DoRedraw( DialogData->Dialog, &Rect, WNAMES_OUTPUT, Global );
			SetInfo( NamesWindow, Global );
		}
		SetButtons( DialogData, Global );
	}
}

void	NamesWindowWhois( IRC_CHANNEL *IrcChannel, WORD Global[15] )
{
	NAMES_WINDOW *NamesWindow = IrcChannel->ListWindow;
	IRC_SESSION	*IrcSession = IrcChannel->IrcSession;
	if( NamesWindow )
	{
		DIALOG_DATA	*DialogData = NamesWindow->DialogData;
		BYTE	**Item;
		LONG	nLines, yScroll, i = 0, j;
		WORD	yVis, nCols, xScroll, xVis, lColour;
		BYTE	Puf[512];

		if( DialogData->Tree[WNAMES_SWITCH].ob_state & SELECTED )
			return;

		mt_list_get_scrollinfo( DialogData->Tree, WNAMES_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );

		while( i < nLines )
		{
			j = i;
			strcpy( Puf, "/WHOIS " );
			while( j < nLines && j < i + 4 )
			{
				Item = mt_list_get_item( DialogData->Tree, WNAMES_OUTPUT, j++, &lColour, Global );
				if( Item && Item[0] )
				{
					strcat( Puf, Item[0] );
					strcat( Puf, "," );
				}
			}
			i = j;
			Puf[strlen( Puf )-1] = 0;
			SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
		}
/*		for( i = 0; i < nLines; i++ )
		{
			Item = mt_list_get_item( DialogData->Tree, WNAMES_OUTPUT, i, &lColour, Global );
			sprintf( Puf, "/WHOIS %s", Item[0] );
			strcat( Puf, "" );
			SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession->Irc ), Global );
		}	*/
	}
}
