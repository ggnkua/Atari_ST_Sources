#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<STRING.H>
#include	<STDIO.H>
#include	<TIME.H>

#include	<atarierr.h>

#include	"Clipbrd.h"
#include	"DD.h"
#include	"main.h"
#include	RSCHEADER
#include	"Irc.h"
#include	"Help.h"
#include	"IConnect.h"
#include	"Menu.h"
#include	"Popup.h"
#include	"Rsc.h"
#include	"ExtObj\TextObj.h"
#include	"TCP.h"
#include	"WDialog.h"
#include	"Window.h"
#include	"WIrc\IrcFunc.h"
#include	"WIrc\Func.h"
#include	"WIrc\WChat.h"
#include	"WIrc\WDccChat.h"
#include	"WIrc\WInput.h"


#include	"Keytab.h"
#include	"MapKey.h"

#define	WINDOW_KINDS	NAME + FULLER + MOVER + CLOSER + ICONIFIER + VSLIDE + UPARROW + DNARROW + SIZER + INFO
#define	EDITPUF		512

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	Global[15], VdiHandle;
extern OBJECT	**TreeAddr;
extern GRECT	ScreenRect;
extern KEYT	*Keytab;
extern WORD	KeytabAnsiExport, KeytabAnsiImport;
extern WORD	ColourTableObj[], ColourTableRef[];
extern BYTE	*LogPath;
extern WORD	IrcFlags;

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static WORD cdecl	HandleDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData );
static WORD	HndlMesagDialog( void *DialogData, EVNT *Events, WORD Global[15] );
static WORD	HndlEditDialog( void *DialogData, EVNT *Events, WORD Global[15] );
static WORD	HndlTimerDialog( void *DialogData, WORD Global[15] );
static WORD	HndlCheckDialog( void *DialogData, EVNT *Events, WORD Global[15] );
static WORD	HndlClsDialog( void *DialogData, WORD Global[15] );

static void SizeDialog( DIALOG_DATA *DialogData, GRECT *Pos, WORD Global[15] );
static void SizeInput( DIALOG_DATA *DialogData, WORD Height, WORD Global[15] );
static void	SetVSlide( DIALOG_DATA *DialogData, WORD Global[15] );

static WORD	ReadConfig( BYTE *Dirname, BYTE *Filename, GRECT *Work, WORD *Height, WORD *IdO, WORD *HtO, WORD *IdI, WORD *HtI, LONG *n, WORD *LogFlag, WORD ColourTable[] );

/*-----------------------------------------------------------------------------*/
/* OpenChatWindow                                                              */
/*-----------------------------------------------------------------------------*/
WORD	OpenChatWindow( BYTE *Dirname, BYTE *Filename, WORD Type, LONG nLines, WORD OutputFontId, WORD OutputFontHt, WORD InputFontId, WORD InputFontHt, WORD ColourTable[], WORD OverWrite, WORD LogFlag, CHAT_WINDOW *ChatWindow, WORD Global[15] )
{
	DIALOG_DATA	*DialogData;
	BYTE			*XEditPuf;
	WORD			i, Ret;
	GRECT	Curr;

	if(( DialogData = malloc( sizeof( DIALOG_DATA ))) == NULL )
	{
		free( ChatWindow );
		return( ENSMEM );
	}
	ChatWindow->DialogData = DialogData;

	DialogData->Dialog = NULL;
	DialogData->HndlDdDialog = NULL;
	DialogData->HndlClsDialog = HndlClsDialog;
	DialogData->HndlMesagDialog = HndlMesagDialog;
	DialogData->HndlEditDialog = HndlEditDialog;
	DialogData->HndlHelpDialog = NULL;
	if( ChatWindow->TimerChatWindow )
		DialogData->HndlTimerDialog = HndlTimerDialog;
	else
		DialogData->HndlTimerDialog = NULL;
	DialogData->HndlCheckDialog = HndlCheckDialog;
	DialogData->UserData = ChatWindow;
	DialogData->TreeIndex = WCHAT;

	if(( DialogData->Tree = CopyTree( TreeAddr[WCHAT] )) == NULL )
	{
		free( DialogData );
		free( ChatWindow );
		return( ENSMEM );
	}


	if(( Ret = mt_text_create( DialogData->Tree, WCHAT_OUTPUT, Global )) != E_OK )
	{
		FreeTree( DialogData->Tree );
		free( DialogData );
		free( ChatWindow );
		return( Ret );
	}

	mt_text_set_pufline( DialogData->Tree, WCHAT_OUTPUT, nLines, Global );
	mt_text_set_smicons( DialogData->Tree, WCHAT_OUTPUT, ( IrcFlags & USE_SMICONS ) ? 1 : 0, Global );

	if(( ChatWindow->XEdit = mt_edit_create( Global )) == NULL )
	{
		mt_text_delete( DialogData->Tree, WCHAT_OUTPUT, Global );
		FreeTree( DialogData->Tree );
		free( DialogData );
		free( ChatWindow );
		return( ENSMEM );
	}
	DialogData->Tree[WCHAT_INPUT].ob_type = G_EDIT;
	DialogData->Tree[WCHAT_INPUT].ob_spec.tedinfo = ChatWindow->XEdit;

	if(( XEditPuf = calloc( EDITPUF + 1, 1 )) == NULL )
	{
		mt_edit_delete( ChatWindow->XEdit, Global );
		mt_text_delete( DialogData->Tree, WCHAT_OUTPUT, Global );
		FreeTree( DialogData->Tree );
		free( DialogData );
		free( ChatWindow );
		return( ENSMEM );
	}
	mt_edit_set_buf( DialogData->Tree, WCHAT_INPUT, XEditPuf, EDITPUF, Global );

	mt_edit_set_font( DialogData->Tree, WCHAT_INPUT, InputFontId, InputFontHt, 0, 0, Global );
	mt_edit_set_colour( DialogData->Tree, WCHAT_INPUT, ColourTable[COLOUR_INPUT], ColourTable[COLOUR_INPUT_BACK], Global );
	mt_edit_set_format( DialogData->Tree, WCHAT_INPUT, -1, DialogData->Tree[WCHAT_INPUT].ob_width, Global );
	mt_edit_open( DialogData->Tree, WCHAT_INPUT, Global );

	DialogData->Tree[WCHAT_CONSOLE].ob_flags |= HIDETREE;
	DialogData->Tree[WCHAT_CHANNEL].ob_flags |= HIDETREE;
	DialogData->Tree[WCHAT_USER].ob_flags |= HIDETREE;
	DialogData->Tree[WCHAT_DCC].ob_flags |= HIDETREE;
	ChatWindow->SetButtonChatWindow( ChatWindow->UserData, Global );
	switch( Type )
	{
		case	WIN_CHAT_IRC_CONSOLE:
			DialogData->Tree[WCHAT_CONSOLE].ob_flags &= ~HIDETREE;
			DialogData->Tree[WCHAT_AWAY].ob_state |= DISABLED;
			DialogData->Tree[WCHAT_AWAY].ob_flags &= ~SELECTABLE;
			DialogData->Tree[WCHAT_LIST].ob_state |= DISABLED;
			DialogData->Tree[WCHAT_LIST].ob_flags &= ~SELECTABLE;
			DialogData->Tree[WCHAT_USERMODE].ob_state |= DISABLED;
			DialogData->Tree[WCHAT_USERMODE].ob_flags &= ~SELECTABLE;
			DialogData->Tree[WCHAT_NICK].ob_state |= DISABLED;
			DialogData->Tree[WCHAT_NICK].ob_flags &= ~SELECTABLE;
			mt_edit_cursor( DialogData->Tree, WCHAT_INPUT, -1, 0, Global );
			break;
		case	WIN_CHAT_IRC_CHANNEL:
			DialogData->Tree[WCHAT_CHANNEL].ob_flags &= ~HIDETREE;
			break;
		case	WIN_CHAT_IRC_USER:
			DialogData->Tree[WCHAT_USER].ob_flags &= ~HIDETREE;
			break;
		case	WIN_CHAT_DCC:
			DialogData->Tree[WCHAT_DCC].ob_flags &= ~HIDETREE;
			mt_edit_cursor( DialogData->Tree, WCHAT_INPUT, -1, 0, Global );
			break;
	}


	ChatWindow->NextFuller.g_x = ScreenRect.g_x;
	ChatWindow->NextFuller.g_y = ScreenRect.g_y;
	ChatWindow->NextFuller.g_w = ScreenRect.g_w;
	ChatWindow->NextFuller.g_h = ScreenRect.g_h;

	mt_text_set_font( DialogData->Tree, WCHAT_OUTPUT, OutputFontId, OutputFontHt, 0, 0, Global );
	mt_text_set_colour( DialogData->Tree, WCHAT_OUTPUT, ColourTable[COLOUR_MSG], ColourTable[COLOUR_MSG_BACK], Global );
	mt_text_set_format( DialogData->Tree, WCHAT_OUTPUT, -1, DialogData->Tree[WCHAT_INPUT].ob_width, Global );
	for( i = 0; i < COLOUR_MAX; i++ )
		mt_text_set_colourtable( DialogData->Tree, WCHAT_OUTPUT, ColourTable[i], i, Global );


	{
		GRECT	Work;
		WORD	IdO, HtO, IdI, HtI, ColourTable[COLOUR_MAX], Height;
		LONG	n = nLines;
		if( ReadConfig( Dirname, Filename, &Work, &Height, &IdO, &HtO, &IdI, &HtI, &n, &LogFlag, ColourTable ) == E_OK )
		{
			WORD	i;
			if( OverWrite )
			{
				mt_text_set_font( DialogData->Tree, WCHAT_OUTPUT, IdO, HtO, 1, 0, Global );
				mt_edit_set_font( DialogData->Tree, WCHAT_INPUT, IdI, HtI, 0, 0, Global );
				mt_text_set_colour( DialogData->Tree, WCHAT_OUTPUT, ColourTable[COLOUR_MSG], ColourTable[COLOUR_MSG_BACK], Global );
				mt_edit_set_colour( DialogData->Tree, WCHAT_INPUT, ColourTable[COLOUR_INPUT], ColourTable[COLOUR_INPUT_BACK], Global );
				mt_text_set_pufline( DialogData->Tree, WCHAT_OUTPUT, n, Global );
				for( i = 0; i < COLOUR_MAX; i++ )
					mt_text_set_colourtable( DialogData->Tree, WCHAT_OUTPUT, ColourTable[i], i, Global );
			}
			MT_wind_calc( WC_BORDER, WINDOW_KINDS, &Work, &Curr, Global );
			SizeDialog( DialogData, &Curr, Global );
			SizeInput( DialogData, Height, Global );
		}
		else
		{
			Work.g_x = -1;
			Work.g_y = -1;
		}
		MT_wind_calc( WC_BORDER, WINDOW_KINDS, &Work, &Curr, Global );
		PlaceIntelligent( &Curr );
		MT_wind_calc( WC_WORK, WINDOW_KINDS, &Curr, &Work, Global );
		OpenDialogX( ChatWindow->Title, Type, WINDOW_KINDS, Work.g_x, Work.g_y, HandleDialog, DialogData, Global );
		ChatWindow->WinId = MT_wdlg_get_handle( DialogData->Dialog, Global );
	}
	SetVSlide( DialogData, Global );

	if( LogFlag )
	{
		if(( ChatWindow->LogFile = OpenLog( Dirname, Filename )) == NULL )
			MT_form_alert( 1, TreeAddr[ALERTS][ALERT_ERROR_LOG].ob_spec.free_string, Global );
	}
	else
		ChatWindow->LogFile = NULL;
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* HndlDialog                                                                  */
/*-----------------------------------------------------------------------------*/
static WORD cdecl	HandleDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	DIALOG_DATA	*DialogData = ( DIALOG_DATA * ) UserData;
	CHAT_WINDOW	*ChatWindow = ( CHAT_WINDOW * ) DialogData->UserData;

	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_EDIT:
			{
				break;
			}
			case	HNDL_MESG:
			{
				switch( Events->msg[0] )
				{
					case	WM_SIZED:
					{
						GRECT	Pos;
						SizeDialog( DialogData, ( GRECT *) &( Events->msg[4] ), Global );
						MT_wind_get_grect( Events->msg[3], WF_CURRXYWH, &Pos, Global );
						SetPosWindow( Events->msg[3], &Pos );
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
						lEvents.msg[4] = ChatWindow->NextFuller.g_x;
						lEvents.msg[5] = ChatWindow->NextFuller.g_y;
						lEvents.msg[6] = ChatWindow->NextFuller.g_w;
						lEvents.msg[7] = ChatWindow->NextFuller.g_h;
						HandleWindow( &lEvents, Global );
						lEvents.mwhich = MU_MESAG;
						lEvents.msg[0] = WM_SIZED;
						lEvents.msg[1] = Global[2];
						lEvents.msg[2] = 0;
						lEvents.msg[3] = Events->msg[3];
						lEvents.msg[4] = ChatWindow->NextFuller.g_x;
						lEvents.msg[5] = ChatWindow->NextFuller.g_y;
						lEvents.msg[6] = ChatWindow->NextFuller.g_w;
						lEvents.msg[7] = ChatWindow->NextFuller.g_h;
						HandleWindow( &lEvents, Global );
						ChatWindow->NextFuller.g_x = Pos.g_x;
						ChatWindow->NextFuller.g_y = Pos.g_y;
						ChatWindow->NextFuller.g_w = Pos.g_w;
						ChatWindow->NextFuller.g_h = Pos.g_h;
						break;
					}
					case	WM_ARROWED:
					{
						if( Events->msg[4] == WA_UPPAGE )
						{
							LONG	nLines, yScroll;
							WORD	yVis, yVal, nCols, xScroll, xVis;
							mt_text_get_scrollinfo( DialogTree, WCHAT_OUTPUT, &nLines, &yScroll, &yVis, &yVal, &nCols, &xScroll, &xVis, Global );
							mt_text_scroll( DialogTree, WCHAT_OUTPUT, Events->msg[3], -yVal, 0, Global );
						}
						else	if( Events->msg[4] == WA_DNPAGE )
						{
							LONG	nLines, yScroll;
							WORD	yVis, yVal, nCols, xScroll, xVis;
							mt_text_get_scrollinfo( DialogTree,  WCHAT_OUTPUT, &nLines, &yScroll, &yVis, &yVal, &nCols, &xScroll, &xVis, Global );
							mt_text_scroll( DialogTree, WCHAT_OUTPUT, Events->msg[3], yVal, 0, Global );
						}
						else	if( Events->msg[4] == WA_UPLINE )
							mt_text_scroll( DialogTree, WCHAT_OUTPUT, Events->msg[3], -1, 0, Global );
						else	if( Events->msg[4] == WA_DNLINE )
							mt_text_scroll( DialogTree, WCHAT_OUTPUT, Events->msg[3], 1, 0, Global );
						SetVSlide( DialogData, Global );
						break;
					}
					case	WM_VSLID:
					{
						LONG	nLines, yScroll;
						WORD	yVis, yVal, nCols, xScroll, xVis, dyPos;
						mt_text_get_scrollinfo( DialogTree, WCHAT_OUTPUT, &nLines, &yScroll, &yVis, &yVal, &nCols, &xScroll, &xVis, Global );
						dyPos = nLines - yVal > 0 ? Events->msg[4] * ( nLines - yVal ) / 1000 - yScroll : 0;
						mt_text_scroll( DialogTree, WCHAT_OUTPUT, Events->msg[3], dyPos, 0, Global );
						SetVSlide( DialogData, Global );
						break;
					}
				}
				break;
			}
			case	HNDL_CLSD:
				if( ChatWindow->MessageChatWindow( Events, ChatWindow->UserData, Global ) == E_OK )
					return( 1 );
				else
					return( 0 );
		}
	}
	else
	{
		Obj &= 0x7fff;
/*		if( HandleWDialogIcon( &Obj, Dialog, Global ))
			return( 1 );
*/		if( DialogTree[Obj].ob_state & DISABLED )
		{
			DialogTree[Obj].ob_state &= ~SELECTED;
			return( 1 );
		}
		if(( DialogTree[Obj].ob_type & 0x0100 ) == 0x0100 )
		{
			StGuide_Action( DialogTree, WCHAT, Global );
			return( 1 );
		}
		if( Obj == WCHAT_OUTPUT_PARENT2 || Obj == WCHAT_INPUT_PARENT2 )
		{
			WORD	y, y1, Dy, Dummy;
			MT_objc_offset( DialogTree, WCHAT_OUTPUT_PARENT2, &Dummy, &y1, Global );
			y1 += DialogTree[WCHAT_OUTPUT_PARENT2].ob_height;
			if( y1 - 8 <= Events->my && y1 + 8 >= Events->my )
			{
				EVNTDATA	EvData;
				MT_graf_mouse( M_SAVE, NULL, Global );
				MT_graf_mouse( POINT_HAND, NULL, Global );

				y = Events->my;
				MT_graf_mkstate( &EvData, Global );
				while( EvData.bstate == 1 )
				{
					Dy = EvData.y - y;

					if( Dy )
					{
						WORD	NewRh, OldRh;
						if( DialogTree[WCHAT_INPUT].ob_height - Dy < 8 )
							Dy = DialogTree[WCHAT_INPUT].ob_height - 8;
						if( DialogTree[WCHAT_OUTPUT].ob_height + Dy < 8 )
							Dy = 8 - DialogTree[WCHAT_OUTPUT].ob_height;
						SizeInput( DialogData, DialogTree[WCHAT_INPUT_PARENT2].ob_height - Dy, Global );
/*						DialogTree[WCHAT_OUTPUT_PARENT2].ob_height += Dy;
						DialogTree[WCHAT_OUTPUT_PARENT1].ob_height += Dy;
						DialogTree[WCHAT_OUTPUT].ob_height += Dy;

						DialogTree[WCHAT_INPUT_PARENT2].ob_y += Dy;
						DialogTree[WCHAT_INPUT_PARENT2].ob_height -= Dy;
						DialogTree[WCHAT_INPUT_PARENT1].ob_height -= Dy;
						DialogTree[WCHAT_INPUT].ob_height -= Dy;

						mt_text_resized( DialogTree, WCHAT_OUTPUT, &NewRh, &OldRh, Global );
						mt_edit_resized( DialogTree, WCHAT_INPUT, &NewRh, &OldRh, Global );
*/
						SetVSlide( DialogData, Global );
						DoRedrawX( Dialog, &Rect, Global, WCHAT_OUTPUT_PARENT2, WCHAT_INPUT_PARENT2, EDRX );
						y += Dy;
					}

					MT_graf_mkstate( &EvData, Global );
				}
				MT_graf_mouse( M_RESTORE, NULL, Global );
			}
			return( 1 );
		}
		else	if( Obj == WCHAT_INFO )
		{
			IRC_SESSION	*IrcSession = NULL;
			IRC_CHANNEL *IrcChannel = NULL;
			if( !( DialogTree[WCHAT_CONSOLE].ob_flags & HIDETREE ) || !( DialogTree[WCHAT_CHANNEL].ob_flags & HIDETREE ) || !( DialogTree[WCHAT_USER].ob_flags & HIDETREE ))
			{
				IrcChannel = ( IRC_CHANNEL * ) ChatWindow->UserData;
				IrcSession = IrcChannel->IrcSession;
				OpenAlertIrc( IrcSession, IrcChannel, InfoDialog( ChatWindow, Global), MODWIN_NORMAL );
			}
			else	if( !( DialogData->Tree[WCHAT_DCC].ob_flags & HIDETREE ))
				InfoDccDialog( ChatWindow, Global );

			return( 1 );
		}
		ChatWindow->ButtonChatWindow( Obj, ChatWindow->UserData, Global );
	}
	return( 1 );
}

/*-----------------------------------------------------------------------------*/
/* HndlMesagDialog                                                             */
/*-----------------------------------------------------------------------------*/
static WORD	HndlMesagDialog( void *DialogData, EVNT *Events, WORD Global[15] )
{
	CHAT_WINDOW	*ChatWindow = ( CHAT_WINDOW * )((( DIALOG_DATA * ) DialogData )->UserData );
	switch( Events->msg[0] )
	{
		case	WIN_CMD:
		{
			if( Events->msg[4] == WIN_KONTEXT_1 )
			{
				WORD	ColourTable[COLOUR_MAX], i;
				for( i = 0; i < COLOUR_MAX; i++ )
				{
					ColourTable[i] = mt_text_get_colourtable((( DIALOG_DATA * ) DialogData )->Tree, WCHAT_OUTPUT, i, Global );
					TreeAddr[POPUP_COLOURTABLE][ColourTableObj[i]].ob_state |= DISABLED;
				}
				TreeAddr[POPUP_COLOURTABLE][ColourTableRef[COLOUR_INPUT]].ob_state &= ~DISABLED;
				TreeAddr[POPUP_COLOURTABLE][ColourTableRef[COLOUR_INPUT_BACK]].ob_state &= ~DISABLED;
				TreeAddr[POPUP_COLOURTABLE][ColourTableRef[COLOUR_MSG]].ob_state &= ~DISABLED;
				TreeAddr[POPUP_COLOURTABLE][ColourTableRef[COLOUR_MSGWITHNICK]].ob_state &= ~DISABLED;
				TreeAddr[POPUP_COLOURTABLE][ColourTableRef[COLOUR_MSG_MYSELF]].ob_state &= ~DISABLED;
				TreeAddr[POPUP_COLOURTABLE][ColourTableRef[COLOUR_MSG_OP]].ob_state &= ~DISABLED;
				TreeAddr[POPUP_COLOURTABLE][ColourTableRef[COLOUR_MSG_SERVER]].ob_state &= ~DISABLED;
				TreeAddr[POPUP_COLOURTABLE][ColourTableRef[COLOUR_MSG_AWAY]].ob_state &= ~DISABLED;
				TreeAddr[POPUP_COLOURTABLE][ColourTableRef[COLOUR_MSG_BACK]].ob_state &= ~DISABLED;
				TreeAddr[POPUP_COLOURTABLE][ColourTableRef[COLOUR_ACTION]].ob_state &= ~DISABLED;
				if( ColourTablePopup( ColourTable, Global ) == E_OK )
				{
					GRECT		Rect;
					OBJECT	*DialogTree;
					MT_wdlg_get_tree((( DIALOG_DATA * ) DialogData )->Dialog, &DialogTree, &Rect, Global );
					mt_text_set_colour((( DIALOG_DATA * ) DialogData )->Tree, WCHAT_OUTPUT, ColourTable[COLOUR_MSG], ColourTable[COLOUR_MSG_BACK], Global );
					mt_edit_set_colour((( DIALOG_DATA * ) DialogData )->Tree, WCHAT_INPUT, ColourTable[COLOUR_INPUT], ColourTable[COLOUR_INPUT_BACK], Global );
					for( i = 0; i < COLOUR_MAX; i++ )
						mt_text_set_colourtable((( DIALOG_DATA * ) DialogData )->Tree, WCHAT_OUTPUT, ColourTable[i], i, Global );
					DoRedrawX((( DIALOG_DATA * ) DialogData )->Dialog, &Rect, Global, WCHAT_OUTPUT, WCHAT_INPUT, EDRX );
				}
				break;
			}
			else
				return( ChatWindow->MessageChatWindow( Events, ChatWindow->UserData, Global ));
		}
		case	FONT_CHANGED:
		{
			WORD	Obj;
			EVNTDATA	Ev;
			OBJECT		*DialogTree;
			GRECT			Rect;
			MT_graf_mkstate( &Ev, Global );
			MT_wdlg_get_tree((( DIALOG_DATA *) DialogData)->Dialog, &DialogTree, &Rect, Global );
			if(( Obj = MT_objc_find( DialogTree, ROOT, MAX_DEPTH, Ev.x, Ev.y, Global )) == WCHAT_OUTPUT || Obj == WCHAT_INPUT )
			{
				WORD	Id, Ht, Pix, Mono, BColour, TColour;
				if( Obj == WCHAT_OUTPUT )
				{
					mt_text_get_font( DialogTree, Obj, &Id, &Ht, &Pix, &Mono, Global );
					mt_text_get_colour( DialogTree, Obj, &TColour, &BColour, Global );
				}
				else
				{
					mt_edit_get_font( DialogTree, Obj, &Id, &Ht, &Pix, &Mono, Global );
					mt_edit_get_colour( DialogTree, Obj, &TColour, &BColour, Global );
				}
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
				if( Obj == WCHAT_OUTPUT )
				{
					mt_text_set_font( DialogTree, WCHAT_OUTPUT, Id, Ht, Pix, Mono, Global );
					mt_text_set_colour( DialogTree, WCHAT_OUTPUT, TColour, -1, Global );
					SetVSlide( DialogData, Global );
					DoRedraw( (( DIALOG_DATA *) DialogData)->Dialog, &Rect, WCHAT_OUTPUT, Global );
				}
				else	if( Obj == WCHAT_INPUT )
				{
					mt_edit_set_font( DialogTree, WCHAT_INPUT, Id, Ht, Pix, Mono, Global );
					mt_edit_set_colour( DialogTree, WCHAT_INPUT, TColour, -1, Global );
					DoRedraw((( DIALOG_DATA *) DialogData)->Dialog, &Rect, WCHAT_INPUT, Global );
				}
			}
			else
				Cconout( '\a' );
			break;
		}
		case	COLOR_ID:
		{
			WORD	Obj;
			OBJECT		*DialogTree;
			GRECT			Rect;
			MT_wdlg_get_tree((( DIALOG_DATA *) DialogData)->Dialog, &DialogTree, &Rect, Global );
			if(( Obj = MT_objc_find( DialogTree, ROOT, MAX_DEPTH, Events->msg[3], Events->msg[4], Global )) == WCHAT_OUTPUT || Obj == WCHAT_INPUT )
			{
				if( Obj == WCHAT_OUTPUT )
				{
					mt_text_set_colour( DialogTree, WCHAT_OUTPUT, -1, Events->msg[5], Global );
					DoRedraw((( DIALOG_DATA *) DialogData)->Dialog, &Rect, WCHAT_OUTPUT, Global );
				}
				else	if( Obj == WCHAT_INPUT )
				{
					mt_edit_set_colour( DialogTree, WCHAT_INPUT, -1, Events->msg[5], Global );
					DoRedraw((( DIALOG_DATA *) DialogData)->Dialog, &Rect, WCHAT_INPUT, Global );
				}
			}
			else
				Cconout( '\a' );
			break;
		}
		default:
			return( ChatWindow->MessageChatWindow( Events, ChatWindow->UserData, Global ));
	}
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* HndlEditDialog                                                              */
/*-----------------------------------------------------------------------------*/
static WORD	HndlEditDialog( void *DialogData, EVNT *Events, WORD Global[15] )
{
	LONG	Err, StartOutput, EndOutput;
	BYTE	*StartInput, *EndInput;
	CHAT_WINDOW	*ChatWindow = ( CHAT_WINDOW * )((( DIALOG_DATA * ) DialogData )->UserData );

	if( Events->mwhich & MU_KEYBD )
	{
		WORD	Key = MapKey( Events->key );
		if(( Key & KbSCAN ) && ( Key & KbALT ))
		{
			OBJECT	*Tree = ChatWindow->DialogData->Tree;
			DIALOG	*Dialog = ChatWindow->DialogData->Dialog;
			if(( Key & 0xff ) == KbF1 )
			{
				if( !( Tree[WCHAT_CONSOLE].ob_flags & HIDETREE ))
					HandleDialog( Dialog, Events, WCHAT_AWAY, 1, DialogData );
				if( !( Tree[WCHAT_CHANNEL].ob_flags & HIDETREE ))
					HandleDialog( Dialog, Events, WCHAT_INVITE, 1, DialogData );
				Events->mwhich &= ~MU_KEYBD;
			}
			if(( Key & 0xff ) == KbF2 )
			{
				if( !( Tree[WCHAT_CONSOLE].ob_flags & HIDETREE ))
					HandleDialog( Dialog, Events, WCHAT_LIST, 1, DialogData );
				if( !( Tree[WCHAT_CHANNEL].ob_flags & HIDETREE ))
					HandleDialog( Dialog, Events, WCHAT_CHANNELMODE, 1, DialogData );
				Events->mwhich &= ~MU_KEYBD;
			}
			if(( Key & 0xff ) == KbF3 )
			{
				if( !( Tree[WCHAT_CONSOLE].ob_flags & HIDETREE ))
					HandleDialog( Dialog, Events, WCHAT_USERMODE, 1, DialogData );
				if( !( Tree[WCHAT_CHANNEL].ob_flags & HIDETREE ))
					HandleDialog( Dialog, Events, WCHAT_TOPIC, 1, DialogData );
				Events->mwhich &= ~MU_KEYBD;
			}
			if(( Key & 0xff ) == KbF4 )
			{
				if( !( Tree[WCHAT_CONSOLE].ob_flags & HIDETREE ))
					HandleDialog( Dialog, Events, WCHAT_NICK, 1, DialogData );
				if( !( Tree[WCHAT_CHANNEL].ob_flags & HIDETREE ))
					HandleDialog( Dialog, Events, WCHAT_WHO, 1, DialogData );
				Events->mwhich &= ~MU_KEYBD;
			}
		}
/* SmileKeys */
		else	if(( Key & KbSHIFT ) && ( Key & KbALT ))
		{
			OBJECT	*DialogTree;
			GRECT		Rect;
			BYTE		*Puf, *Cursor, Text[4];
			LONG		PufLen, TextLen;
			MT_wdlg_get_tree((( DIALOG_DATA *) DialogData)->Dialog, &DialogTree, &Rect, Global );
			mt_edit_get_buf( DialogTree, WCHAT_INPUT, &Puf, &PufLen, &TextLen, Global );
			mt_edit_get_cursor((( DIALOG_DATA *) DialogData)->Tree, WCHAT_INPUT, &Cursor, Global );
			strcpy( Text, "" );
			if(( Key & 0x00ff ) == '/' )
				strcpy( Text, ":-/" );
			if(( Key & 0x00ff ) == '(' )
				strcpy( Text, ":-(" );
			if(( Key & 0x00ff ) == ')' || ( Key & 0x00ff ) == ':' )
				strcpy( Text, ":-)" );
			if(( Key & 0x00ff ) == ';' )
				strcpy( Text, ";-)" );
			if( strlen( Text ))
			{
				strcat( Puf, Text );
				mt_edit_set_buf( DialogTree, WCHAT_INPUT, Puf, EDITPUF, Global );
				Cursor += strlen( Text );
				mt_edit_set_cursor((( DIALOG_DATA *) DialogData)->Tree, WCHAT_INPUT, Cursor, Global );
				DoRedraw((( DIALOG_DATA *) DialogData)->Dialog, &Rect, WCHAT_INPUT, Global );
				Events->mwhich &= ~MU_KEYBD;
			}
		}
		if( Events->key == 0x2e03 )
		{
			if( mt_text_get_slct((( DIALOG_DATA *) DialogData)->Tree, WCHAT_OUTPUT, &StartOutput, &EndOutput, Global ) == E_OK )
			{
				BYTE	*Puf, *Tmp;
				LONG	l = 0, i;
				for( i = StartOutput; i <= EndOutput; i++ )
				{
					Tmp = mt_text_get_line( (( DIALOG_DATA *) DialogData)->Tree, WCHAT_OUTPUT, i, Global );
					if( Tmp )
					{
						l += strlen( Tmp ) + 2;
					}
				}
				if(( Puf = malloc( l + 1 )) != NULL )
				{
					*Puf = 0;
					for( i = StartOutput; i <= EndOutput; i++ )
					{
						Tmp = mt_text_get_line( (( DIALOG_DATA *) DialogData)->Tree, WCHAT_OUTPUT, i, Global );
						strcat( Puf, Tmp );
						strcat( Puf, "\r\n" );
					}
					PutClipboard( "TXT", Puf, l, Global );
					free( Puf );
				}
				Events->mwhich &= ~MU_KEYBD;
			}
		}
		if(( Events->key & 0xff ) == 13 )
		{
			OBJECT	*DialogTree;
			GRECT		Rect;
			BYTE		*Puf;
			LONG		PufLen, TextLen;
			MT_wdlg_get_tree((( DIALOG_DATA *) DialogData)->Dialog, &DialogTree, &Rect, Global );
			mt_edit_get_buf( DialogTree, WCHAT_INPUT, &Puf, &PufLen, &TextLen, Global );
			if( TextLen )
			{
				Puf[TextLen] = 0;
				Puf[TextLen+1] = 0;
				ChatWindow->SendChatWindow( Puf, ChatWindow->UserData, Global );
				Puf[0] = 0;
				mt_edit_set_buf( DialogTree, WCHAT_INPUT, Puf, EDITPUF, Global );
				DoRedraw((( DIALOG_DATA *) DialogData)->Dialog, &Rect, WCHAT_INPUT, Global );
			}
			Events->mwhich &= ~MU_KEYBD;
		}
	}	

	if( mt_text_evnt((( DIALOG_DATA *) DialogData)->Tree, WCHAT_OUTPUT, ChatWindow->WinId, Events, Global ) == 1 )
	{
		if( ChatWindow->DoubleClickChatWindow && mt_text_get_slct((( DIALOG_DATA *) DialogData)->Tree, WCHAT_OUTPUT, &StartOutput, &EndOutput, Global ) == E_OK )
		{
			BYTE	*Line = mt_text_get_line( (( DIALOG_DATA *) DialogData)->Tree, WCHAT_OUTPUT, StartOutput, Global );
			ChatWindow->DoubleClickChatWindow( Line, Events, ChatWindow->UserData, Global );
		}
		mt_text_deslct((( DIALOG_DATA *) DialogData)->Tree, WCHAT_OUTPUT, ChatWindow->WinId, Global );
	}
	if( mt_text_get_slct((( DIALOG_DATA *) DialogData)->Tree, WCHAT_OUTPUT, &StartOutput, &EndOutput, Global ) == E_OK )
	{
		SetVSlide( DialogData, Global );
		mt_edit_get_sel((( DIALOG_DATA *) DialogData)->Tree, WCHAT_INPUT, &StartInput, &EndInput, Global );
		if( StartInput )
		{
			BYTE		*Puf, *Cursor;
			LONG		PufLen, TextLen;
			OBJECT	*DialogTree;
			GRECT		Rect;
			MT_wdlg_get_tree((( DIALOG_DATA *) DialogData)->Dialog, &DialogTree, &Rect, Global );
			mt_edit_get_cursor((( DIALOG_DATA *) DialogData)->Tree, WCHAT_INPUT, &Cursor, Global );
			mt_edit_get_buf((( DIALOG_DATA *) DialogData)->Tree, WCHAT_INPUT, &Puf, &PufLen, &TextLen, Global );
			mt_edit_set_buf((( DIALOG_DATA *) DialogData)->Tree, WCHAT_INPUT, Puf, PufLen, Global );
			mt_edit_set_cursor((( DIALOG_DATA *) DialogData)->Tree, WCHAT_INPUT, Cursor, Global );
			DoRedraw((( DIALOG_DATA *) DialogData)->Dialog, &Rect, WCHAT_INPUT_PARENT1, Global );	/* Wenn WCHAT_INPUT dann wird das Edit-Objekt nicht neu gezeichnet :-( */
		}
	}
	mt_edit_evnt((( DIALOG_DATA *) DialogData)->Tree, WCHAT_INPUT, ChatWindow->WinId, Events, &Err, Global );
	mt_edit_get_sel( (( DIALOG_DATA *) DialogData)->Tree, WCHAT_INPUT, &StartInput, &EndInput, Global );
	if( StartInput )
		mt_text_deslct((( DIALOG_DATA *) DialogData)->Tree, WCHAT_OUTPUT, MT_wdlg_get_handle( (( DIALOG_DATA *) DialogData)->Dialog, Global ), Global );

	return( E_OK );	
}

/*-----------------------------------------------------------------------------*/
/* HndlTimerDialog                                                             */
/*-----------------------------------------------------------------------------*/
static WORD	HndlTimerDialog( void *DialogData, WORD Global[15] )
{
	CHAT_WINDOW	*ChatWindow = ( CHAT_WINDOW * )((( DIALOG_DATA * ) DialogData )->UserData );
	if( ChatWindow->TimerChatWindow )
		return( ChatWindow->TimerChatWindow( ChatWindow->UserData, Global ));
	else
		return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* CheckDialog                                                                 */
/*-----------------------------------------------------------------------------*/
static WORD	HndlCheckDialog( void *DialogData, EVNT *Events, WORD Global[15] )
{
	CHAT_WINDOW	*ChatWindow = ( CHAT_WINDOW * )((( DIALOG_DATA * ) DialogData )->UserData );
	return( ChatWindow->CheckChatWindow( Events, ChatWindow->UserData, Global ));
}

/*-----------------------------------------------------------------------------*/
/* ClsDialog                                                                   */
/*-----------------------------------------------------------------------------*/
static WORD	HndlClsDialog( void *DialogData, WORD Global[15] )
{
	BYTE		*Puf;
	LONG		PufLen, TextLen;
	CHAT_WINDOW	*ChatWindow = ( CHAT_WINDOW * )((( DIALOG_DATA * ) DialogData )->UserData );
	CloseLog( ChatWindow->LogFile );
	ChatWindow->ClosedChatWindow( ChatWindow->UserData, Global );
	mt_edit_get_buf((( DIALOG_DATA *) DialogData)->Tree, WCHAT_INPUT, &Puf, &PufLen, &TextLen, Global );
	mt_edit_delete( ChatWindow->XEdit, Global );
	free( Puf );
	mt_text_delete((( DIALOG_DATA *) DialogData)->Tree, WCHAT_OUTPUT, Global );
	if( ChatWindow->Title );
		free( ChatWindow->Title );
	if( ChatWindow->Info )
		free( ChatWindow->Info );
	FreeTree((( DIALOG_DATA *) DialogData)->Tree );
	free( DialogData );
	free( ChatWindow );
	return( E_OK );	
}

/*-----------------------------------------------------------------------------*/
/* SetInfo                                                                     */
/*-----------------------------------------------------------------------------*/
void	SetInfoChatWindow( BYTE *Str, CHAT_WINDOW *ChatWindow, WORD Global[15] )
{
	if( ChatWindow->Info )
		free( ChatWindow->Info );
	ChatWindow->Info = malloc( strlen( Str ) + 2 );
	if( ChatWindow->Info )
	{
		strcpy( ChatWindow->Info, " " );
		strcat( ChatWindow->Info, Str );
	}
	MT_wind_set_string( ChatWindow->WinId, WF_INFO, ChatWindow->Info, Global );
}
/*-----------------------------------------------------------------------------*/
/* SetInfo                                                                     */
/*-----------------------------------------------------------------------------*/
void	SetTitleChatWindow( BYTE *Str, CHAT_WINDOW *ChatWindow, WORD Global[15] )
{
	if( ChatWindow->Title )
		free( ChatWindow->Title );
	ChatWindow->Title = strdup( Str );
	MT_wind_set_string( ChatWindow->WinId, WF_NAME, ChatWindow->Title, Global );
}

/*-----------------------------------------------------------------------------*/
/* SizeDialog                                                                  */
/*-----------------------------------------------------------------------------*/
static void SizeDialog( DIALOG_DATA *DialogData, GRECT *Pos, WORD Global[15] )
{
	GRECT	New;
	WORD	Dw, Dh, NewRh, OldRh;

	MT_wind_calc( WC_WORK, WINDOW_KINDS, Pos, &New, Global );

	Dw = New.g_w - DialogData->Tree[ROOT].ob_width;
	Dh = New.g_h - DialogData->Tree[ROOT].ob_height;
	if( New.g_w < TreeAddr[WCHAT][ROOT].ob_width )
		Dw = TreeAddr[WCHAT][ROOT].ob_width - DialogData->Tree[ROOT].ob_width;
	if( New.g_h < TreeAddr[WCHAT][ROOT].ob_height )
		Dh = TreeAddr[WCHAT][ROOT].ob_height - DialogData->Tree[ROOT].ob_height;

	DialogData->Tree[ROOT].ob_width += Dw;
	DialogData->Tree[ROOT].ob_height += Dh;

	DialogData->Tree[WCHAT_OUTPUT_PARENT1].ob_width += Dw;
	DialogData->Tree[WCHAT_OUTPUT_PARENT1].ob_height += Dh;
	DialogData->Tree[WCHAT_OUTPUT_PARENT2].ob_width += Dw;
	DialogData->Tree[WCHAT_OUTPUT_PARENT2].ob_height += Dh;
	DialogData->Tree[WCHAT_OUTPUT].ob_width += Dw;
	DialogData->Tree[WCHAT_OUTPUT].ob_height += Dh;

	DialogData->Tree[WCHAT_INPUT_PARENT1].ob_width += Dw;
	DialogData->Tree[WCHAT_INPUT_PARENT2].ob_y += Dh;
	DialogData->Tree[WCHAT_INPUT_PARENT2].ob_width += Dw;
	DialogData->Tree[WCHAT_INPUT].ob_width += Dw;

	DialogData->Tree[WCHAT_HELP].ob_x += Dw;
	DialogData->Tree[WCHAT_INFO].ob_x += Dw;
	DialogData->Tree[WCHAT_CONSOLE].ob_width += Dw;
	DialogData->Tree[WCHAT_CHANNEL].ob_width += Dw;
	DialogData->Tree[WCHAT_USER].ob_width += Dw;
	DialogData->Tree[WCHAT_DCC].ob_width += Dw;

	if( Dw )
	{
		mt_text_set_format( DialogData->Tree, WCHAT_OUTPUT, -1, DialogData->Tree[WCHAT_OUTPUT].ob_width, Global );
		mt_edit_set_format( DialogData->Tree, WCHAT_INPUT, -1, DialogData->Tree[WCHAT_INPUT].ob_width, Global );
	}
	if( Dh )
		mt_text_resized( DialogData->Tree, WCHAT_OUTPUT, &NewRh, &OldRh, Global );

	if( DialogData->Dialog && ( Dh || Dw ))
	{
		MT_wdlg_set_tree( DialogData->Dialog, DialogData->Tree, Global );
		SetVSlide( DialogData, Global );
	}
}

static void SizeInput( DIALOG_DATA *DialogData, WORD Height, WORD Global[15] )
{
	OBJECT *DialogTree = DialogData->Tree;
	WORD	Dy = DialogTree[WCHAT_INPUT_PARENT2].ob_height - Height;
	WORD	NewRh, OldRh;
	DialogTree[WCHAT_OUTPUT_PARENT2].ob_height += Dy;
	DialogTree[WCHAT_OUTPUT_PARENT1].ob_height += Dy;
	DialogTree[WCHAT_OUTPUT].ob_height += Dy;

	DialogTree[WCHAT_INPUT_PARENT2].ob_y += Dy;
	DialogTree[WCHAT_INPUT_PARENT2].ob_height -= Dy;
	DialogTree[WCHAT_INPUT_PARENT1].ob_height -= Dy;
	DialogTree[WCHAT_INPUT].ob_height -= Dy;

	mt_text_resized( DialogTree, WCHAT_OUTPUT, &NewRh, &OldRh, Global );
	mt_edit_resized( DialogTree, WCHAT_INPUT, &NewRh, &OldRh, Global );
}

/*-----------------------------------------------------------------------------*/
/* SetVsSlide                                                                  */
/*-----------------------------------------------------------------------------*/
static void	SetVSlide( DIALOG_DATA *DialogData, WORD Global[15] )
{
	LONG	nLines, yScroll;
	WORD	yVis, yVal, nCols, xScroll, xVis;
	WORD	WinId = MT_wdlg_get_handle( DialogData->Dialog, Global );
	LONG	Pos, Size;
	mt_text_get_scrollinfo( DialogData->Tree, WCHAT_OUTPUT, &nLines, &yScroll, &yVis, &yVal, &nCols, &xScroll, &xVis, Global );
	Size = nLines - yVis > 0 ? (((( LONG ) yVis ) * 1000 ) / nLines ) : 1000;
	Pos = nLines - yVis > 0 ? (((( LONG ) yScroll ) * 1000 ) / ( nLines - yVis )) : 0;
	MT_wind_set_int( WinId, WF_VSLSIZE, Size, Global );
	MT_wind_set_int( WinId, WF_VSLIDE, Pos, Global );
}

/*-----------------------------------------------------------------------------*/
/* ReadConfig                                                                  */
/*-----------------------------------------------------------------------------*/
static WORD	ReadConfig( BYTE *Dirname, BYTE *Filename, GRECT *Work, WORD *Height, WORD *IdO, WORD *HtO, WORD *IdI, WORD *HtI, LONG *n, WORD *LogFlag, WORD ColourTable[] )
{
	FILE	*File = NULL;
	XATTR	Xattr;
	BYTE	*Path, *HomePath, *DefaultPath;

	GetFilename( Dirname, Filename, &Path, &HomePath, &DefaultPath );

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
		if( atof( Version ) >= 1.03 )
			fscanf( File, "%i, %i, %i, %i, %i\n", &( Work->g_x ), &( Work->g_y ), &( Work->g_w ), &( Work->g_h ), Height );
		else
		{
			fscanf( File, "%i, %i, %i, %i\n", &( Work->g_x ), &( Work->g_y ), &( Work->g_w ), &( Work->g_h ));
			*Height = TreeAddr[WCHAT][WCHAT_INPUT_PARENT2].ob_height;
		}
		fscanf( File, "%i, %i\n", IdO, HtO );
		fscanf( File, "%i, %i\n", IdI, HtI );
		if( atof( Version ) >= 1.1 )
		{
			fscanf( File, "%li\n", n );
			fscanf( File, "%i\n", LogFlag );
		}
		fgets( Puf, 512, File );
		ReadColourTable( atof( Version ), Puf, ColourTable );

		fclose( File );
		return( E_OK );
	}
	return( ERROR );
}

/*-----------------------------------------------------------------------------*/
/* WriteConfig                                                                 */
/*-----------------------------------------------------------------------------*/
WORD	WriteConfigChatWindow( BYTE *Dirname, BYTE *Filename, CHAT_WINDOW *ChatWindow, WORD Global[15] )
{
	FILE	*File = NULL;
	BYTE	*Path, *HomePath, *DefaultPath;

	GetFilename( Dirname, Filename, &Path, &HomePath, &DefaultPath );

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
		DIALOG_DATA	*DialogData = ChatWindow->DialogData;
		WORD	Id, Ht, Pix, Mono, i;

		fprintf( File, "%s\n", VERSION );

		fprintf( File, "%i, %i, %i, %i, %i\n", DialogData->Tree[ROOT].ob_x, DialogData->Tree[ROOT].ob_y, DialogData->Tree[ROOT].ob_width, DialogData->Tree[ROOT].ob_height, DialogData->Tree[WCHAT_INPUT_PARENT2].ob_height );

		mt_text_get_font( DialogData->Tree, WCHAT_OUTPUT, &Id, &Ht, &Pix, &Mono, Global );
		fprintf( File, "%i, %i\n", Id, Ht );

		mt_edit_get_font( DialogData->Tree, WCHAT_INPUT, &Id, &Ht, &Pix, &Mono, Global );
		fprintf( File, "%i, %i\n", Id, Ht );
		fprintf( File, "%li\n", mt_text_get_pufline( DialogData->Tree, WCHAT_OUTPUT, Global ));
		fprintf( File, "%i\n", ChatWindow->LogFile ? 1 : 0 );

		for( i = 0; i < COLOUR_MAX - 1; i++ )
			fprintf( File, "%i, ", mt_text_get_colourtable( DialogData->Tree, WCHAT_OUTPUT, i, Global ));
		fprintf( File, "%i\n", mt_text_get_colourtable( DialogData->Tree, WCHAT_OUTPUT, i, Global ));

		fclose( File );
		return( E_OK );
	}
	MT_form_alert( 1, TreeAddr[ALERTS][ERROR_WRITING_IRC].ob_spec.free_string, Global );
	return( ERROR );
}

FILE *OpenLog( BYTE *Dirname, BYTE *Filename )
{
	XATTR	Xattr;
	BYTE	Path[1024], DirnameK[1024], FilenameK[1024];
	LONG	Len, Id;
	FILE	*Handle;
	time_t timer;

	strcpy( Path, LogPath );
	if( Fxattr( 0, Path, &Xattr ) != 0 )
		return( NULL );
	if(( Xattr.mode & S_IFMT ) != S_IFDIR )
		return( NULL );

	strcpy( DirnameK, Dirname );
	strcpy( FilenameK, Filename );

	Len = Dpathconf( LogPath, 3 );
	Id = Dpathconf( LogPath, 5 );

	strcpy( DirnameK, Dirname );
	if( strlen( DirnameK ) > Len || Id == 2 )
		ShortFilename( DirnameK );
	strcpy( FilenameK, Filename );
	if( strlen( FilenameK ) > Len || Id == 2 )
		ShortFilename( FilenameK );
	strcat( FilenameK, ".log" );

	if( Path[strlen( Path ) - 1] != '\\' )
		strcat( Path, "\\" );
	strcat( Path, DirnameK );
	if( Fxattr( 0, Path, &Xattr ) == EFILNF )
		if( Dcreate( Path ) != E_OK )
			return( NULL );
	strcat( Path, "\\" );
	strcat( Path, FilenameK );

	if( IrcFlags & APPEND_LOG )
		Handle = fopen( Path, "ab" );
	else
		Handle = fopen( Path, "wb" );
	if( !Handle )
		return( NULL );

/*	setbuf( Handle, NULL );	*/
   time( &timer );
	fprintf( Handle, "\n*** %s\n", ctime( &timer ));
	return( Handle );
}

void	CloseLog( FILE *Handle )
{
	if( Handle )
		fclose( Handle );
}

/*-----------------------------------------------------------------------------*/
/* AppendChatWindow                                                            */
/*-----------------------------------------------------------------------------*/
WORD	AppendChatWindow( BYTE *Msg, WORD Colour, CHAT_WINDOW *ChatWindow, WORD Global[15] )
{
	if( ChatWindow )
	{
		DIALOG_DATA	*DialogData = ChatWindow->DialogData;
		mt_text_attach_line( DialogData->Tree, WCHAT_OUTPUT, Msg, Colour, Global );

		if( ChatWindow->LogFile )
			fprintf( ChatWindow->LogFile, "%s\n", Msg );
		return( E_OK );
	}
	else
		return( ERROR );
}
void	RedrawChatWindow( CHAT_WINDOW *ChatWindow, WORD Global[15] )
{
	if( ChatWindow )
	{
		DIALOG_DATA	*DialogData = ChatWindow->DialogData;
		if( mt_text_get_dirty( DialogData->Tree, WCHAT_OUTPUT, Global ))
		{
			OBJECT		*DialogTree;
			GRECT			Rect;
			MT_wdlg_get_tree( DialogData->Dialog, &DialogTree, &Rect, Global );
			mt_text_scroll( DialogData->Tree, WCHAT_OUTPUT, ChatWindow->WinId, 0x7fff, 0, Global );
			SetVSlide( DialogData, Global );
			mt_text_set_dirty( DialogData->Tree, WCHAT_OUTPUT, 0 , Global );
			DoRedraw( DialogData->Dialog, &Rect, WCHAT_OUTPUT, Global );
		}
		ChatWindow->SetButtonChatWindow( ChatWindow->UserData, Global );
	}
}
