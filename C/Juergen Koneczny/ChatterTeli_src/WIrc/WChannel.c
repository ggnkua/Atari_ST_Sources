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
#include	"Rsc.h"
#include	"WDialog.h"
#include	"Window.h"
#include	"WIrc\Func.h"
#include	"WIrc\IrcFunc.h"
#include	"WIrc\WChannel.h"
#include	"WIrc\WInput.h"

#include	"EdScroll.h"
#include	"Keytab.h"
#include	"MapKey.h"

#define	CHANNEL_WINDOW_KINDS		NAME + INFO + FULLER + MOVER + CLOSER + ICONIFIER + VSLIDE + UPARROW + DNARROW + SIZER

#define	THREAD_READ_1	0x0001
#define	THREAD_READ_2	0x0002
#define	THREAD_WRITE	0x0004
#define	THREAD_RECEIVE	0x0008
#define	THREAD_SORT		0x0010
#define	THREAD_CLOSE	0x0100

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
static XTED	ChannelXted;
static BYTE	ChannelTmplt[EDITLEN+1], ChannelTxt[EDITLEN+1];

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static WORD	cdecl	HandleDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
static WORD	HndlEditDialog( void *DialogData, EVNT *Events, WORD Global[15] );
static WORD	HndlMesagDialog( void *DialogData, EVNT *Events, WORD Global[15] );
static WORD HndlTimerDialog( void *DialogData, WORD Global[15] );
static WORD	HndlClsDialog( void *DialogData, WORD Global[15] );
static void SizeDialog( DIALOG_DATA *DialogData, GRECT *New, WORD Global[15] );
static void	SetVSlide( DIALOG_DATA *DialogData, WORD Global[15] );
static void SetColumns( DIALOG_DATA *DialogData, WORD Global[15] );
static void	SetInfo( CHANNEL_WINDOW *ChannelWindow, BYTE *Str, WORD Global[15] );
static void	SetInfoNChannels( CHANNEL_WINDOW *ChannelWindow, WORD Global[15] );
static void	Disable( CHANNEL_WINDOW *ChannelWindow, WORD Global[15] );
static WORD	ChannelWindowRead( IRC_CHANNEL *IrcChannel, GRECT *Work, WORD *Id, WORD *Ht, WORD ColourTable[], LONG *yScroll, WORD Width[3], WORD *Sort, WORD Global[15] );
static void ChannelWindowReadThread( IRC_CHANNEL *IrcChannel, WORD Global[15] );
static LONG	cdecl	ChannelWindowReadItem( IRC_CHANNEL *IrcChannel, WORD Global[15] );
static void ChannelWindowWriteThread( IRC_CHANNEL *IrcChannel, WORD Global[15] );
static LONG	cdecl ChannelWindowWrite( IRC_CHANNEL *IrcChannel, WORD Global[15] );
static void	ChannelWindowReset( IRC_CHANNEL *IrcChannel, WORD Global[15] );

static void	StartSortThread( DIALOG_DATA *DialogData, WORD Global[15] );
static LONG	cdecl	SortThread( void *Parameter );

static WORD	StrCmp( BYTE *Str1, BYTE *Str2 );

WORD	cdecl OpenChannelWindow( IRC_CHANNEL *IrcChannel, WORD Flag, WORD Global[15] )
{
	IRC_SESSION		*IrcSession = IrcChannel->IrcSession;
	IRC				*Irc = IrcSession->Irc;
	WORD				Ret, i;
	CHANNEL_WINDOW	*ChannelWindow;
	DIALOG_DATA		*DialogData;
	GRECT	Curr;

	if( IrcChannel->ListWindow )
		return( E_OK );

	IrcChannel->ListWindow = NULL;

	if( TreeAddr[WCHANNEL][WCHANNEL_EDIT].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
		InitScrlted( &TreeAddr[WCHANNEL][WCHANNEL_EDIT], isScroll, &ChannelXted, ChannelTxt, ChannelTmplt, EDITLEN );

	if(( ChannelWindow = malloc( sizeof( CHANNEL_WINDOW ))) == NULL )
		return( ENSMEM );
	ChannelWindow->NextFuller.g_x = ScreenRect.g_x;
	ChannelWindow->NextFuller.g_y = ScreenRect.g_y;
	ChannelWindow->NextFuller.g_w = ScreenRect.g_w;
	ChannelWindow->NextFuller.g_h = ScreenRect.g_h;

	ChannelWindow->IrcChannel = IrcChannel;

	ChannelWindow->Title = malloc( strlen( TreeAddr[TITLES][TITLE_WINDOW].ob_spec.free_string ) + 1 + strlen( Irc->Host ) + 1 );
	if( !ChannelWindow->Title )
	{
		free( ChannelWindow );
		return( ENSMEM );
	}
	sprintf( ChannelWindow->Title, "%s %s", TreeAddr[TITLES][TITLE_WINDOW].ob_spec.free_string, Irc->Host );
	ChannelWindow->Info = NULL;
	ChannelWindow->AppId = 0;
	ChannelWindow->ThreadFlag = 0;
	ChannelWindow->UpdateFlag = 0;
	ChannelWindow->ModWinId = 0;

	if(( DialogData = malloc( sizeof( DIALOG_DATA ))) == NULL )
	{
		free( ChannelWindow->Title );
		free( ChannelWindow );
		return( ENSMEM );
	}	
	ChannelWindow->DialogData = DialogData;
	DialogData->Dialog = NULL;
	DialogData->HndlDdDialog = NULL;
	DialogData->HndlClsDialog = HndlClsDialog;
	DialogData->HndlMesagDialog = HndlMesagDialog;
	DialogData->HndlTimerDialog = HndlTimerDialog;
	DialogData->HndlEditDialog = HndlEditDialog;
	DialogData->HndlHelpDialog = NULL;
	DialogData->HndlCheckDialog = HndlCheckDialogWIrc;
	DialogData->UserData = ChannelWindow;
	DialogData->TreeIndex = WCHANNEL;

	if(( DialogData->Tree = CopyTree( TreeAddr[WCHANNEL] )) == NULL )
	{
		free( ChannelWindow->Title );
		free( ChannelWindow );
		free( DialogData );
		return( ENSMEM );
	}

	if(( Ret = mt_list_create( DialogData->Tree, WCHANNEL_OUTPUT, 3, Global )) != E_OK )
	{
		FreeTree( DialogData->Tree );
		free( DialogData );
		free( ChannelWindow->Title );
		free( ChannelWindow );
		return( Ret );
	}

	mt_list_set_font( DialogData->Tree, WCHANNEL_OUTPUT, Irc->ChannelFontId, Irc->ChannelFontHt, 0, 0, Global );
	mt_list_set_colour( DialogData->Tree, WCHANNEL_OUTPUT, Irc->ColourTable[COLOUR_CHANNEL], Irc->ColourTable[COLOUR_CHANNEL_BACK], Global );
	
	for( i = 0; i < COLOUR_MAX; i++ )
		mt_list_set_colourtable( DialogData->Tree, WCHANNEL_OUTPUT, Irc->ColourTable[i], i, Global );
	
	SetIconBlk( FreeIconBlk( DialogData->Tree[WCHANNEL_CHANNEL_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AUF].ob_spec.iconblk );
	SetIconBlk( FreeIconBlk( DialogData->Tree[WCHANNEL_N_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_NO].ob_spec.iconblk );
	mt_list_set_sort( DialogData->Tree, WCHANNEL_OUTPUT, 1, Global );

	IrcChannel->ListWindow = ChannelWindow;
	{
		GRECT	Work;
		LONG	yScroll = 0;
		WORD	Id, Ht, Width[3], Sort, ColourTable[COLOUR_MAX];
		if( ChannelWindowRead( IrcChannel, &Work, &Id, &Ht, ColourTable, &yScroll, Width, &Sort, Global ) == E_OK )
		{
			WORD	i;
			MT_wind_calc( WC_BORDER, CHANNEL_WINDOW_KINDS, &Work, &Curr, Global );

			if( IrcFlags & WINDOW_OVERWRITE )
			{
				mt_list_set_font( DialogData->Tree, WCHANNEL_OUTPUT, Id, Ht, 1, 0, Global );
				mt_list_set_colour( DialogData->Tree, WCHANNEL_OUTPUT, ColourTable[COLOUR_CHANNEL], ColourTable[COLOUR_CHANNEL_BACK], Global );
				for( i = 0; i < COLOUR_MAX; i++ )
					mt_list_set_colourtable( DialogData->Tree, WCHANNEL_OUTPUT, ColourTable[i], i, Global );
			}
			SetIconBlk( FreeIconBlk( DialogData->Tree[WCHANNEL_CHANNEL_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_NO].ob_spec.iconblk );
			SetIconBlk( FreeIconBlk( DialogData->Tree[WCHANNEL_N_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_NO].ob_spec.iconblk );
			if( Sort == 1 )
				SetIconBlk( FreeIconBlk( DialogData->Tree[WCHANNEL_CHANNEL_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AUF].ob_spec.iconblk );
			else	if( Sort == 2 )
				SetIconBlk( FreeIconBlk( DialogData->Tree[WCHANNEL_CHANNEL_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AB].ob_spec.iconblk );
			else	if( Sort == 3 )
				SetIconBlk( FreeIconBlk( DialogData->Tree[WCHANNEL_N_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AUF].ob_spec.iconblk );
			else	if( Sort == 4 )
				SetIconBlk( FreeIconBlk( DialogData->Tree[WCHANNEL_N_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AB].ob_spec.iconblk );
			mt_list_set_sort( DialogData->Tree, WCHANNEL_OUTPUT, Sort, Global );
			SizeDialog( DialogData, &Curr, Global );
			DialogData->Tree[WCHANNEL_CHANNEL].ob_width = Width[0];
			DialogData->Tree[WCHANNEL_N].ob_x = Width[0];
			DialogData->Tree[WCHANNEL_N].ob_width = Width[1];
			DialogData->Tree[WCHANNEL_TOPIC].ob_x = Width[0] + Width[1];
			DialogData->Tree[WCHANNEL_TOPIC].ob_width = Width[2];
			mt_list_set_dirty( DialogData->Tree, WCHANNEL_OUTPUT, 0 , Global );
		}
		else
		{
			Work.g_x = -1;
			Work.g_y = -1;
		}
		SetColumns( DialogData, Global );
		MT_wind_calc( WC_BORDER, CHANNEL_WINDOW_KINDS, &Work, &Curr, Global );
		PlaceIntelligent( &Curr );
		MT_wind_calc( WC_WORK, CHANNEL_WINDOW_KINDS, &Curr, &Work, Global );
		OpenDialogX( ChannelWindow->Title, WIN_CHANNEL_IRC, CHANNEL_WINDOW_KINDS, Work.g_x, Work.g_y, HandleDialog, DialogData, Global );
		ChannelWindow->WinId = MT_wdlg_get_handle( DialogData->Dialog, Global );
		SetVSlide( DialogData, Global );
		if( Flag )
			ChannelWindowReadThread( IrcChannel, Global );
	}
	return( E_OK );
}

static WORD cdecl	HandleDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	DIALOG_DATA	*DialogData = ( DIALOG_DATA * ) MT_wdlg_get_udata( Dialog, Global );
	CHANNEL_WINDOW	*ChannelWindow = ( CHANNEL_WINDOW * ) DialogData->UserData;

	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_INIT:
				DialogTree[WCHANNEL_OPEN_I].ob_state |= DISABLED;
				DialogTree[WCHANNEL_OPEN].ob_state |= DISABLED;
				DialogTree[WCHANNEL_OPEN].ob_flags &= ~SELECTABLE;
				break;
			case	HNDL_EDIT:
			{
				break;
			}
			case	HNDL_EDDN:
			{
				if( strlen( DialogTree[WCHANNEL_EDIT].ob_spec.tedinfo->te_ptext ))
				{
					BYTE	**Item;
					LONG	nLines, yScroll, i = 0, j, min, max;
					WORD	yVis, nCols, xScroll, xVis, Colour, Ret;
					WORD	Sort = mt_list_get_sort( DialogTree, WCHANNEL_OUTPUT, Global );
					mt_list_get_scrollinfo( DialogTree, WCHANNEL_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
					if(( Sort == 1 || Sort == 2 ) && nLines )
					{
						min = 0;
						max = nLines - 1;
						while( 1 )
						{
							if( min + ( max - min + 1 ) / 2 == i )
							{
								min++;
								i = min + ( max - min + 1 ) / 2;
							}
							else
								i = min + ( max - min + 1 ) / 2;
							if( Sort == 1 )
								Item = mt_list_get_item( DialogTree, WCHANNEL_OUTPUT, i, &Colour, Global );
							else
								Item = mt_list_get_item( DialogTree, WCHANNEL_OUTPUT, nLines - i - 1, &Colour, Global );
							if( Item )
								Ret = StrCmp( Item[0], DialogTree[WCHANNEL_EDIT].ob_spec.tedinfo->te_ptext );
							if( Ret == -1 )
								min = i;
							else	if( Ret == 1 )
								max = i;
							else
							{
								if( strlen( Item[0] ) == strlen( DialogTree[WCHANNEL_EDIT].ob_spec.tedinfo->te_ptext ) || ( min == max && min == i ))
								{
									if( max == min && min == 1 )
									{
										if( Sort == 1 )
											Item = mt_list_get_item( DialogTree, WCHANNEL_OUTPUT, 0, &Colour, Global );
										else
											Item = mt_list_get_item( DialogTree, WCHANNEL_OUTPUT, nLines - 1, &Colour, Global );
										if( !StrCmp( Item[0], DialogTree[WCHANNEL_EDIT].ob_spec.tedinfo->te_ptext ))
											i = 0;
									}
									if( Sort == 2 )
										i = nLines - i - 1;
									mt_list_set_selected( DialogTree, WCHANNEL_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), i, Global );
									if( i < yScroll || i >= yVis + yScroll )
									{
										mt_list_scroll( DialogTree, WCHANNEL_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), i - ( WORD ) yScroll, 0, Global );
										SetVSlide( DialogData, Global );
									}
									break;
								}
								else	if( strlen( Item[0] ) < strlen( DialogTree[WCHANNEL_EDIT].ob_spec.tedinfo->te_ptext ))
									min = i;
								else
									max = i;
							}
							if( min == max )
							{
								if( min == 1 )
								{
									min = -1;
									max = 0;
									continue;
								}
								mt_list_set_selected( DialogTree, WCHANNEL_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), -1, Global );
								break;
							}
						}
					}
					else
						mt_list_set_selected( DialogTree, WCHANNEL_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), -1, Global );
					if( !( DialogTree[WCHANNEL_OPEN].ob_flags & SELECTABLE ))
					{
						DialogTree[WCHANNEL_OPEN_I].ob_state &= ~DISABLED;
						DialogTree[WCHANNEL_OPEN].ob_state &= ~DISABLED;
						DialogTree[WCHANNEL_OPEN].ob_flags |= SELECTABLE;
						DoRedraw( Dialog, &Rect, WCHANNEL_OPEN, Global );
					}
				}
				else
				{
					if( mt_list_get_selected( DialogTree, WCHANNEL_OUTPUT, Global ) != -1 )
						mt_list_set_selected( DialogTree, WCHANNEL_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), -1, Global );
					if(( DialogTree[WCHANNEL_OPEN].ob_flags & SELECTABLE ))
					{
						DialogTree[WCHANNEL_OPEN_I].ob_state |= DISABLED;
						DialogTree[WCHANNEL_OPEN].ob_state |= DISABLED;
						DialogTree[WCHANNEL_OPEN].ob_flags &= ~SELECTABLE;
						DoRedraw( Dialog, &Rect, WCHANNEL_OPEN, Global );
					}
				}
				break;
			}
			case	HNDL_MESG:
			{
				switch( Events->msg[0] )
				{
					case	WM_SIZED:
					{
						if( ChannelWindow->ThreadFlag )
						{
							if( ChannelWindow->ModWinId )
							{
								EVNT	lEvents;
								lEvents.mwhich = MU_MESAG;
								lEvents.msg[0] = WM_TOPPED;
								lEvents.msg[1] = Global[2];
								lEvents.msg[2] = 0;
								lEvents.msg[3] = ChannelWindow->ModWinId;
								HandleWindow( &lEvents, Global );
							}
							else
								OpenAlertIrc( ChannelWindow->IrcChannel->IrcSession, NULL, ( ChannelWindow->ModWinId = AlertDialog( 1, TreeAddr[ALERTS][CHANNEL_WINDOW_BUSY].ob_spec.free_string, ChannelWindow->Title, CloseSessionAlertIrc, ChannelWindow->IrcChannel->IrcSession, Global )), MODWIN_CHANNEL );
						}
						else
							SizeDialog( DialogData, ( GRECT *) &( Events->msg[4] ), Global );
						break;
					}
					case	WM_FULLED:
					{
						if( ChannelWindow->ThreadFlag )
						{
							if( ChannelWindow->ModWinId )
							{
								EVNT	lEvents;
								lEvents.mwhich = MU_MESAG;
								lEvents.msg[0] = WM_TOPPED;
								lEvents.msg[1] = Global[2];
								lEvents.msg[2] = 0;
								lEvents.msg[3] = ChannelWindow->ModWinId;
								HandleWindow( &lEvents, Global );
							}
							else
								OpenAlertIrc( ChannelWindow->IrcChannel->IrcSession, NULL, ( ChannelWindow->ModWinId = AlertDialog( 1, TreeAddr[ALERTS][CHANNEL_WINDOW_BUSY].ob_spec.free_string, ChannelWindow->Title, CloseSessionAlertIrc, ChannelWindow->IrcChannel->IrcSession, Global )), MODWIN_CHANNEL );
						}
						else
						{
							GRECT	Pos;
							EVNT	lEvents;
							MT_wind_get_grect( Events->msg[3], WF_CURRXYWH, &Pos, Global );
							lEvents.mwhich = MU_MESAG;
							lEvents.msg[0] = WM_MOVED;
							lEvents.msg[1] = Global[2];
							lEvents.msg[2] = 0;
							lEvents.msg[3] = Events->msg[3];
							lEvents.msg[4] = ChannelWindow->NextFuller.g_x;
							lEvents.msg[5] = ChannelWindow->NextFuller.g_y;
							lEvents.msg[6] = ChannelWindow->NextFuller.g_w;
							lEvents.msg[7] = ChannelWindow->NextFuller.g_h;
							HandleWindow( &lEvents, Global );
							lEvents.mwhich = MU_MESAG;
							lEvents.msg[0] = WM_SIZED;
							lEvents.msg[1] = Global[2];
							lEvents.msg[2] = 0;
							lEvents.msg[3] = Events->msg[3];
							lEvents.msg[4] = ChannelWindow->NextFuller.g_x;
							lEvents.msg[5] = ChannelWindow->NextFuller.g_y;
							lEvents.msg[6] = ChannelWindow->NextFuller.g_w;
							lEvents.msg[7] = ChannelWindow->NextFuller.g_h;
							HandleWindow( &lEvents, Global );
							ChannelWindow->NextFuller.g_x = Pos.g_x;
							ChannelWindow->NextFuller.g_y = Pos.g_y;
							ChannelWindow->NextFuller.g_w = Pos.g_w;
							ChannelWindow->NextFuller.g_h = Pos.g_h;
						}
						break;
					}
					case	WM_ARROWED:
					{
						if( ChannelWindow->ThreadFlag )
						{
							if( ChannelWindow->ModWinId )
							{
								EVNT	lEvents;
								lEvents.mwhich = MU_MESAG;
								lEvents.msg[0] = WM_TOPPED;
								lEvents.msg[1] = Global[2];
								lEvents.msg[2] = 0;
								lEvents.msg[3] = ChannelWindow->ModWinId;
								HandleWindow( &lEvents, Global );
							}
							else
								OpenAlertIrc( ChannelWindow->IrcChannel->IrcSession, NULL, ( ChannelWindow->ModWinId = AlertDialog( 1, TreeAddr[ALERTS][CHANNEL_WINDOW_BUSY].ob_spec.free_string, ChannelWindow->Title, CloseSessionAlertIrc, ChannelWindow->IrcChannel->IrcSession, Global )), MODWIN_CHANNEL );
						}
						else
						{
							if( Events->msg[4] == WA_UPPAGE )
							{
								LONG	nLines, yScroll;
								WORD	yVis, nCols, xScroll, xVis;
								mt_list_get_scrollinfo( DialogTree, WCHANNEL_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
								mt_list_scroll( DialogTree, WCHANNEL_OUTPUT, Events->msg[3], -yVis, 0, Global );
							}
							else	if( Events->msg[4] == WA_DNPAGE )
							{
								LONG	nLines, yScroll;
								WORD	yVis, nCols, xScroll, xVis;
								mt_list_get_scrollinfo( DialogTree, WCHANNEL_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
								mt_list_scroll( DialogTree, WCHANNEL_OUTPUT, Events->msg[3], yVis, 0, Global );
							}
							else	if( Events->msg[4] == WA_UPLINE )
								mt_list_scroll( DialogTree, WCHANNEL_OUTPUT, Events->msg[3], -1, 0, Global );
							else	if( Events->msg[4] == WA_DNLINE )
								mt_list_scroll( DialogTree, WCHANNEL_OUTPUT, Events->msg[3], 1, 0, Global );
							SetVSlide( DialogData, Global );
						}
						break;
					}
					case	WM_VSLID:
					{
						if( ChannelWindow->ThreadFlag )
						{
							if( ChannelWindow->ModWinId )
							{
								EVNT	lEvents;
								lEvents.mwhich = MU_MESAG;
								lEvents.msg[0] = WM_TOPPED;
								lEvents.msg[1] = Global[2];
								lEvents.msg[2] = 0;
								lEvents.msg[3] = ChannelWindow->ModWinId;
								HandleWindow( &lEvents, Global );
							}
							else
								OpenAlertIrc( ChannelWindow->IrcChannel->IrcSession, NULL, ( ChannelWindow->ModWinId = AlertDialog( 1, TreeAddr[ALERTS][CHANNEL_WINDOW_BUSY].ob_spec.free_string, ChannelWindow->Title, CloseSessionAlertIrc, ChannelWindow->IrcChannel->IrcSession, Global )), MODWIN_CHANNEL );
						}
						else
						{
							LONG	nLines, yScroll;
							WORD	yVis, nCols, xScroll, xVis, dyPos;
							mt_list_get_scrollinfo( DialogTree, WCHANNEL_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
							dyPos = nLines - yVis > 0 ? Events->msg[4] * ( nLines - yVis ) / 1000 - yScroll : 0;
							mt_list_scroll( DialogTree, WCHANNEL_OUTPUT, Events->msg[3], dyPos, 0, Global );
							SetVSlide( DialogData, Global );
						}
						break;
					}
				}
				break;
			}
			case	HNDL_CLSD:
				if( Events->msg[4] == WIN_CLOSE_WITHOUT_DEMAND )
				{
					if( !ChannelWindow->ThreadFlag || ( ChannelWindow->ThreadFlag & THREAD_RECEIVE ))
						ChannelWindowWriteThread( ChannelWindow->IrcChannel, Global );
					ChannelWindow->ThreadFlag |= THREAD_CLOSE;
				}
				else
				{
					if( ChannelWindow->ThreadFlag )
					{
						if( ChannelWindow->ModWinId )
						{
							EVNT	lEvents;
							lEvents.mwhich = MU_MESAG;
							lEvents.msg[0] = WM_TOPPED;
							lEvents.msg[1] = Global[2];
							lEvents.msg[2] = 0;
							lEvents.msg[3] = ChannelWindow->ModWinId;
							HandleWindow( &lEvents, Global );
						}
						else
							OpenAlertIrc( ChannelWindow->IrcChannel->IrcSession, NULL, ( ChannelWindow->ModWinId = AlertDialog( 1, TreeAddr[ALERTS][CHANNEL_WINDOW_BUSY].ob_spec.free_string, ChannelWindow->Title, CloseSessionAlertIrc, ChannelWindow->IrcChannel->IrcSession, Global )), MODWIN_CHANNEL );
					}
					else
					{
						ChannelWindow->ThreadFlag |= THREAD_CLOSE;
						ChannelWindowWriteThread( ChannelWindow->IrcChannel, Global );
					}
				}
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
		if( DialogTree[Obj].ob_type & 0x0100 )
		{
			StGuide_Action( DialogTree, WCHANNEL, Global );
			return( 1 );
		}
		if( Obj == WCHANNEL_OUTPUT && mt_list_evnt( DialogTree, WCHANNEL_OUTPUT, ChannelWindow->WinId, Events, Global ) == -1 )
		{
			IRC_CHANNEL	*IrcChannel = ChannelWindow->IrcChannel;
			IRC_SESSION	*IrcSession = IrcChannel->IrcSession;
			BYTE	**Item, Puf[512];
			WORD	Colour;
			Item = mt_list_get_item( DialogTree, WCHANNEL_OUTPUT, mt_list_get_selected( DialogTree, WCHANNEL_OUTPUT, Global ), &Colour, Global );
			sprintf( Puf, "/JOIN %s", Item[0] );
			strcat( Puf, "" );
			SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
			mt_list_set_selected( DialogTree, WCHANNEL_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), -1, Global );
			if( strlen( DialogTree[WCHANNEL_EDIT].ob_spec.tedinfo->te_ptext ))
			{
				MT_wdlg_set_edit( Dialog, 0, Global );
				strcpy( DialogTree[WCHANNEL_EDIT].ob_spec.tedinfo->te_ptext, "" );
				MT_wdlg_set_edit( Dialog, WCHANNEL_EDIT, Global );
				DoRedraw( Dialog, &Rect, WCHANNEL_EDIT, Global );
			}
		}
	 	if( mt_list_get_selected( DialogTree, WCHANNEL_OUTPUT, Global ) == -1 )
		{
			if(( DialogTree[WCHANNEL_OPEN].ob_flags & SELECTABLE ) && !strlen( DialogTree[WCHANNEL_EDIT].ob_spec.tedinfo->te_ptext ))
			{
				DialogTree[WCHANNEL_OPEN_I].ob_state |= DISABLED;
				DialogTree[WCHANNEL_OPEN].ob_state |= DISABLED;
				DialogTree[WCHANNEL_OPEN].ob_flags &= ~SELECTABLE;
				DoRedraw( Dialog, &Rect, WCHANNEL_OPEN, Global );
			}
		}
		else
		{
			WORD	Colour;
			BYTE	**Item = mt_list_get_item( DialogTree, WCHANNEL_OUTPUT, mt_list_get_selected( DialogTree, WCHANNEL_OUTPUT, Global ), &Colour, Global );
			if( strcmp( DialogTree[WCHANNEL_EDIT].ob_spec.tedinfo->te_ptext, Item[0] ))
			{
				MT_wdlg_set_edit( Dialog, 0, Global );
				strcpy( DialogTree[WCHANNEL_EDIT].ob_spec.tedinfo->te_ptext, Item[0] );
				MT_wdlg_set_edit( Dialog, WCHANNEL_EDIT, Global );
				DoRedraw( Dialog, &Rect, WCHANNEL_EDIT, Global );
			}
			if( !( DialogTree[WCHANNEL_OPEN].ob_flags & SELECTABLE ))
			{
				DialogTree[WCHANNEL_OPEN_I].ob_state &= ~DISABLED;
				DialogTree[WCHANNEL_OPEN].ob_state &= ~DISABLED;
				DialogTree[WCHANNEL_OPEN].ob_flags |= SELECTABLE;
				DoRedraw( Dialog, &Rect, WCHANNEL_OPEN, Global );
			}
		}



		if( Obj != WCHANNEL_UPDATE && HandleWDialogIcon( &Obj, Dialog, Global ))
			return( 1 );
		if( DialogTree[Obj].ob_state & DISABLED )
		{
			DialogTree[Obj].ob_state &= ~SELECTED;
			return( 1 );
		}
		switch( Obj )
		{
			case	WCHANNEL_UPDATE:
			{
				IRC_CHANNEL	*IrcChannel = ChannelWindow->IrcChannel;
				IRC_SESSION	*IrcSession = IrcChannel->IrcSession;
				BYTE	*Puf = "/LIST -n\0\0";
				SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
				DialogTree[WCHANNEL_UPDATE].ob_state &= ~SELECTED;
				DoRedraw( Dialog, &Rect, WCHANNEL_UPDATE, Global );
				break;
			}
			case	WCHANNEL_OPEN:
			{
				IRC_CHANNEL	*IrcChannel = ChannelWindow->IrcChannel;
				IRC_SESSION	*IrcSession = IrcChannel->IrcSession;
				BYTE	Puf[512];
				sprintf( Puf, "/JOIN %s", DialogTree[WCHANNEL_EDIT].ob_spec.tedinfo->te_ptext );
				strcat( Puf, "" );
				SendMessage( IrcSession, GenerateMessage( Puf, IrcChannel->Name, IrcSession, Global ), Global );
				MT_wdlg_set_edit( Dialog, 0, Global );
				strcpy( DialogTree[WCHANNEL_EDIT].ob_spec.tedinfo->te_ptext, "" );
				MT_wdlg_set_edit( Dialog, WCHANNEL_EDIT, Global );
				DialogTree[WCHANNEL_OPEN].ob_state &= ~SELECTED;
				DialogTree[WCHANNEL_OPEN_I].ob_state |= DISABLED;
				DialogTree[WCHANNEL_OPEN].ob_state |= DISABLED;
				DialogTree[WCHANNEL_OPEN].ob_flags &= ~SELECTABLE;
				DoRedrawX( Dialog, &Rect, Global, WCHANNEL_OPEN, WCHANNEL_EDIT, EDRX );
				mt_list_set_selected( DialogTree, WCHANNEL_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), -1, Global );
				break;
			}
			case	WCHANNEL_CHANNEL:
			case	WCHANNEL_N:
			case	WCHANNEL_TOPIC:
			{
				EVNTDATA	EvData;
				MT_graf_mkstate( &EvData, Global );
				if( EvData.bstate == 1 )
				{
					WORD	xChannel, xN, xTopic, Dummy, C;
					MT_objc_offset( DialogTree, WCHANNEL_CHANNEL, &xChannel, &Dummy, Global );
					xN = xChannel + DialogTree[WCHANNEL_CHANNEL].ob_width;
					xTopic = xN + DialogTree[WCHANNEL_N].ob_width;
					if(( Obj == WCHANNEL_CHANNEL && EvData.x >= xN - 8 ) || ( Obj == WCHANNEL_N && EvData.x <= xN + 8 ))
						C = 1;
					else	if(( Obj == WCHANNEL_N && EvData.x >= xTopic - 8 ) || ( Obj == WCHANNEL_TOPIC && EvData.x <= xTopic + 8 ))
						C = 2;
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
								if( DialogTree[WCHANNEL_CHANNEL].ob_width + Dx < TreeAddr[WCHANNEL][WCHANNEL_CHANNEL].ob_width )
									Dx = TreeAddr[WCHANNEL][WCHANNEL_CHANNEL].ob_width - DialogTree[WCHANNEL_CHANNEL].ob_width;
								if( DialogTree[WCHANNEL_TOPIC].ob_width - Dx < TreeAddr[WCHANNEL][WCHANNEL_TOPIC].ob_width )
									Dx = DialogTree[WCHANNEL_TOPIC].ob_width - TreeAddr[WCHANNEL][WCHANNEL_TOPIC].ob_width;
								DialogTree[WCHANNEL_CHANNEL].ob_width += Dx;
								DialogTree[WCHANNEL_N].ob_x += Dx;
								DialogTree[WCHANNEL_TOPIC].ob_x += Dx;
								DialogTree[WCHANNEL_TOPIC].ob_width -= Dx;
							}
							else	if( C == 2 )
							{
								if( DialogTree[WCHANNEL_N].ob_width + Dx < TreeAddr[WCHANNEL][WCHANNEL_N].ob_width )
									Dx = TreeAddr[WCHANNEL][WCHANNEL_N].ob_width - DialogTree[WCHANNEL_N].ob_width;
								if( DialogTree[WCHANNEL_TOPIC].ob_width - Dx < TreeAddr[WCHANNEL][WCHANNEL_TOPIC].ob_width )
									Dx = DialogTree[WCHANNEL_TOPIC].ob_width - TreeAddr[WCHANNEL][WCHANNEL_TOPIC].ob_width;
								DialogTree[WCHANNEL_N].ob_width += Dx;
								DialogTree[WCHANNEL_TOPIC].ob_x += Dx;
								DialogTree[WCHANNEL_TOPIC].ob_width -= Dx;
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
			case	WCHANNEL_CHANNEL_SORT:
			case	WCHANNEL_N_SORT:
			{
				WORD	Sort = mt_list_get_sort( DialogTree, WCHANNEL_OUTPUT, Global ), Button;
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
				if( Obj == WCHANNEL_CHANNEL || Obj == WCHANNEL_CHANNEL_SORT )
				{
					if( Sort == 1 )
					{
						mt_list_set_sort( DialogTree, WCHANNEL_OUTPUT, 2, Global );
						SetIconBlk( FreeIconBlk( DialogData->Tree[WCHANNEL_CHANNEL_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AB].ob_spec.iconblk );
						DoRedrawX( Dialog, &Rect, Global, WCHANNEL_CHANNEL, WCHANNEL_OUTPUT, EDRX );
					}
					else	if( Sort == 2 )
					{
						mt_list_set_sort( DialogTree, WCHANNEL_OUTPUT, 1, Global );
						SetIconBlk( FreeIconBlk( DialogData->Tree[WCHANNEL_CHANNEL_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AUF].ob_spec.iconblk );
						DoRedrawX( Dialog, &Rect, Global, WCHANNEL_CHANNEL, WCHANNEL_OUTPUT, EDRX );
					}
					else
					{
						StartSortThread( DialogData, Global );
						SetIconBlk( FreeIconBlk( DialogData->Tree[WCHANNEL_CHANNEL_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AUF].ob_spec.iconblk );
						SetIconBlk( FreeIconBlk( DialogData->Tree[WCHANNEL_N_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_NO].ob_spec.iconblk );
						DoRedrawX( Dialog, &Rect, Global, WCHANNEL_CHANNEL, WCHANNEL_N, EDRX );
					}
				}
				if( Obj == WCHANNEL_N || Obj == WCHANNEL_N_SORT )
				{
					if( Sort == 3 )
					{
						mt_list_set_sort( DialogTree, WCHANNEL_OUTPUT, 4, Global );
						SetIconBlk( FreeIconBlk( DialogData->Tree[WCHANNEL_N_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AB].ob_spec.iconblk );
						DoRedrawX( Dialog, &Rect, Global, WCHANNEL_N, WCHANNEL_OUTPUT, EDRX );
					}
					else	if( Sort == 4 )
					{
						mt_list_set_sort( DialogTree, WCHANNEL_OUTPUT, 3, Global );
						SetIconBlk( FreeIconBlk( DialogData->Tree[WCHANNEL_N_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AUF].ob_spec.iconblk );
						DoRedrawX( Dialog, &Rect, Global, WCHANNEL_N, WCHANNEL_OUTPUT, EDRX );
					}
					else
					{
						StartSortThread( DialogData, Global );
						SetIconBlk( FreeIconBlk( DialogData->Tree[WCHANNEL_N_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AUF].ob_spec.iconblk );
						SetIconBlk( FreeIconBlk( DialogData->Tree[WCHANNEL_CHANNEL_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_NO].ob_spec.iconblk );
						DoRedrawX( Dialog, &Rect, Global, WCHANNEL_CHANNEL, WCHANNEL_N, EDRX );
					}
				}
				break;
			}
		}
	}
	return( 1 );
}

static WORD HndlTimerDialog( void *DialogData, WORD Global[15] )
{
	CHANNEL_WINDOW	*ChannelWindow = ( CHANNEL_WINDOW * )(( DIALOG_DATA * ) DialogData )->UserData;
	if( ChannelWindow->AppId )
	{
		if( ChannelWindow->ThreadFlag & THREAD_READ_2 )
		{
			LONG	nLines, yScroll;
			WORD	yVis, nCols, xScroll, xVis;
			WORD	Pos, Size;
			BYTE	Puf[128];
			mt_list_get_scrollinfo((( DIALOG_DATA * ) DialogData )->Tree, WCHANNEL_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
			sprintf( Puf, "%s (%li)", TreeAddr[INFOS][READ_CHANNELS].ob_spec.free_string, nLines );
			SetInfo( ChannelWindow, Puf, Global );
		}
		else	if( ChannelWindow->ThreadFlag & THREAD_WRITE )
		{
			LONG	nLines, yScroll;
			WORD	yVis, nCols, xScroll, xVis;
			WORD	Pos, Size;
			BYTE	Puf[128];
			mt_list_get_scrollinfo((( DIALOG_DATA * ) DialogData )->Tree, WCHANNEL_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
			sprintf( Puf, "%s (%li)", TreeAddr[INFOS][WRITE_CHANNELS].ob_spec.free_string, nLines );
			SetInfo( ChannelWindow, Puf, Global );
		}
	}
	return( E_OK );
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
			Sort = mt_list_get_sort( DialogTree, WCHANNEL_OUTPUT, Global );
			Slct = mt_list_get_selected( DialogTree, WCHANNEL_OUTPUT, Global );
			mt_list_get_scrollinfo( DialogTree, WCHANNEL_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
			if( Key & KbCONTROL )
			{
				if(( Key & 0xff ) == KbDOWN )
				{
					if( Key & KbSHIFT )
						mt_list_scroll( DialogTree, WCHANNEL_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), yVis, 0, Global );
					else
						mt_list_scroll( DialogTree, WCHANNEL_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), +1, 0, Global );
					SetVSlide( DialogData, Global );
					Events->mwhich &= ~MU_KEYBD;
				}
				if(( Key & 0xff ) == KbUP )
				{
					if( Key & KbSHIFT )
						mt_list_scroll( DialogTree, WCHANNEL_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), -yVis, 0, Global );
					else
					mt_list_scroll( DialogTree, WCHANNEL_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), -1, 0, Global );
					SetVSlide( DialogData, Global );	
					Events->mwhich &= ~MU_KEYBD;
				}
			}
			else
			{
				if(( Key & 0xff ) == KbHOME || (( Key & 0xff ) == 0x4f ))
				{
					if((( Key & 0xff ) == KbHOME && ( Key & KbSHIFT )) || (( Key & 0xff ) == 0x4f ))
					{
						mt_list_set_selected( DialogTree, WCHANNEL_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), nLines - 1, Global );
						if( yScroll <= nLines - yVis - 1 )
						{
							mt_list_scroll( DialogTree, WCHANNEL_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), nLines - 1 - yScroll, 0, Global );
							SetVSlide( DialogData, Global );
						}
					}
					else
					{
						mt_list_set_selected( DialogTree, WCHANNEL_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), 0, Global );
						if( yScroll > 0 )
						{
							mt_list_scroll( DialogTree, WCHANNEL_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), -yScroll, 0, Global );
							SetVSlide( DialogData, Global );
						}
					}
					Events->mwhich &= ~MU_KEYBD;
				}
				if(( Key & 0xff ) == KbDOWN || ( Key & 0xff ) == 0x51 )
				{
					if( Slct == -1 )
						mt_list_set_selected( DialogTree, WCHANNEL_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), yScroll, Global );
					else
					{
						if(( Key & KbSHIFT ) || ( Key & 0xff ) == 0x51 )
							Slct += yVis;
						else
							Slct++;
						if( Slct >= nLines )
							Slct = nLines - 1;	

						mt_list_set_selected( DialogTree, WCHANNEL_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), Slct, Global );
						if( yScroll + yVis <= Slct || yScroll > Slct )
						{
							mt_list_scroll( DialogTree, WCHANNEL_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), Slct - yScroll - yVis + 1, 0, Global );
							SetVSlide( DialogData, Global );
						}
					}
					Events->mwhich &= ~MU_KEYBD;
				}
				if(( Key & 0xff ) == KbUP || ( Key & 0xff ) == 0x49 )
				{
					if( Slct == -1 )
						mt_list_set_selected( DialogTree, WCHANNEL_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), yScroll + yVis -1, Global );
					else
					{
						if(( Key & KbSHIFT ) || ( Key & 0xff ) == 0x49 )
							Slct -= yVis;
						else
							Slct--;
						if( Slct < 0 )
							Slct = 0;
						mt_list_set_selected( DialogTree, WCHANNEL_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), Slct, Global );
						if( yScroll + yVis <= Slct || yScroll > Slct )
						{
							mt_list_scroll( DialogTree, WCHANNEL_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), Slct - yScroll, 0, Global );
							SetVSlide( DialogData, Global );
						}
					}
					Events->mwhich &= ~MU_KEYBD;
				}
				
				if(( Slct = mt_list_get_selected( DialogTree, WCHANNEL_OUTPUT, Global )) != -1 )
				{
					Item = mt_list_get_item( DialogTree, WCHANNEL_OUTPUT, Slct, &Colour, Global );
					if( strcmp( Item[0], DialogTree[WCHANNEL_EDIT].ob_spec.tedinfo->te_ptext ))
					{
						MT_wdlg_set_edit( Dialog, 0, Global );
						strcpy( DialogTree[WCHANNEL_EDIT].ob_spec.tedinfo->te_ptext, Item[0] );
						DoRedraw( Dialog, &Rect, WCHANNEL_EDIT, Global );
						MT_wdlg_set_edit( Dialog, WCHANNEL_EDIT, Global );
					}
					if( !( DialogTree[WCHANNEL_OPEN].ob_flags & SELECTABLE ))
					{
						DialogTree[WCHANNEL_OPEN_I].ob_state &= ~DISABLED;
						DialogTree[WCHANNEL_OPEN].ob_state &= ~DISABLED;
						DialogTree[WCHANNEL_OPEN].ob_flags |= SELECTABLE;
						DoRedraw( Dialog, &Rect, WCHANNEL_OPEN, Global );
					}
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
				mt_list_set_selected( DialogTree, WCHANNEL_OUTPUT, MT_wdlg_get_handle( Dialog, Global ), -1, Global );
				Events->mwhich &= ~MU_KEYBD;
			}
		}	
	}
	return( E_OK );
}

static WORD	HndlMesagDialog( void *DialogData, EVNT *Events, WORD Global[15] )
{
	switch( Events->msg[0] )
	{
		case	THR_EXIT:
		{
			DIALOG	*Dialog = (( DIALOG_DATA * ) DialogData )->Dialog;
			OBJECT	*Tree = (( DIALOG_DATA * ) DialogData )->Tree;
			CHANNEL_WINDOW	*ChannelWindow = ( CHANNEL_WINDOW * )(( DIALOG_DATA * ) DialogData )->UserData;
			if( ChannelWindow->ModWinId )
			{
				EVNT	lEvents;
				lEvents.mwhich = MU_MESAG;
				lEvents.msg[0] = WM_CLOSED;
				lEvents.msg[1] = Global[2];
				lEvents.msg[2] = 0;
				lEvents.msg[3] = ChannelWindow->ModWinId;
				lEvents.msg[4] = WIN_CLOSE_WITHOUT_DEMAND;
				HandleWindow( &lEvents, Global );
			}
			if( ChannelWindow->ThreadFlag & THREAD_CLOSE )
			{
				if( !( ChannelWindow->ThreadFlag & THREAD_WRITE ))
				{
					ChannelWindow->ThreadFlag = THREAD_CLOSE;
					ChannelWindowWriteThread( ChannelWindow->IrcChannel, Global );
					return( 0 );
				}
				else
					return( 1 );
			}

			if( strlen( Tree[WCHANNEL_EDIT].ob_spec.tedinfo->te_ptext ))
			{
				Tree[WCHANNEL_OPEN].ob_state &= ~DISABLED;
				Tree[WCHANNEL_OPEN].ob_flags |= SELECTABLE;
				Tree[WCHANNEL_OPEN].ob_flags |= SELECTABLE;
				Tree[WCHANNEL_OPEN_I].ob_state &= ~DISABLED;
				Tree[WCHANNEL_OPEN_I].ob_flags |= TOUCHEXIT;
			}
			Tree[WCHANNEL_UPDATE].ob_state &= ~DISABLED;
			Tree[WCHANNEL_UPDATE].ob_flags |= TOUCHEXIT;
			Tree[WCHANNEL_EDIT].ob_flags |= EDITABLE;
			Tree[WCHANNEL_CHANNEL].ob_flags |= TOUCHEXIT;
			Tree[WCHANNEL_CHANNEL_SORT].ob_flags |= TOUCHEXIT;
			Tree[WCHANNEL_N].ob_flags |= TOUCHEXIT;
			Tree[WCHANNEL_N_SORT].ob_flags |= TOUCHEXIT;
			Tree[WCHANNEL_OUTPUT].ob_flags &= ~HIDETREE;
			if( Dialog )
			{
				OBJECT		*DialogTree;
				GRECT			Rect;
				MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
				MT_wdlg_set_edit( Dialog, WCHANNEL_EDIT, Global );
				DoRedraw( Dialog, &Rect, ROOT, Global );
			}
			SetInfoNChannels( ChannelWindow, Global );
			SetVSlide( DialogData, Global );
			mt_list_set_dirty( Tree, WCHANNEL_OUTPUT, 0 , Global );
			ChannelWindow->ThreadFlag = 0;
			ChannelWindow->AppId = 0;
			return( E_OK );
		}
		case	WIN_CMD:
		{
			if( Events->msg[4] == WIN_KONTEXT_1 )
			{
				WORD	ColourTable[COLOUR_MAX], i;
				for( i = 0; i < COLOUR_MAX; i++ )
				{
					ColourTable[i] = mt_list_get_colourtable((( DIALOG_DATA * ) DialogData )->Tree, WCHANNEL_OUTPUT, i, Global );
					TreeAddr[POPUP_COLOURTABLE][ColourTableObj[i]].ob_state |= DISABLED;
				}
				TreeAddr[POPUP_COLOURTABLE][ColourTableRef[COLOUR_CHANNEL]].ob_state &= ~DISABLED;
				TreeAddr[POPUP_COLOURTABLE][ColourTableRef[COLOUR_CHANNEL_BACK]].ob_state &= ~DISABLED;
				if( ColourTablePopup( ColourTable, Global ) == E_OK )
				{
					GRECT		Rect;
					OBJECT	*DialogTree;
					MT_wdlg_get_tree((( DIALOG_DATA * ) DialogData )->Dialog, &DialogTree, &Rect, Global );
					mt_list_set_colour((( DIALOG_DATA * ) DialogData )->Tree, WCHANNEL_OUTPUT, ColourTable[COLOUR_CHANNEL], ColourTable[COLOUR_CHANNEL_BACK], Global );
					for( i = 0; i < COLOUR_MAX; i++ )
						mt_list_set_colourtable((( DIALOG_DATA * ) DialogData )->Tree, WCHANNEL_OUTPUT, ColourTable[i], i, Global );
					DoRedraw((( DIALOG_DATA * ) DialogData )->Dialog, &Rect, WCHANNEL_OUTPUT, Global );
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
			mt_list_set_colour( DialogTree, WCHANNEL_OUTPUT, -1, Events->msg[5], Global );
			DoRedraw((( DIALOG_DATA * ) DialogData)->Dialog, &Rect, WCHANNEL_OUTPUT, Global );
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
			mt_list_get_font( DialogTree, WCHANNEL_OUTPUT, &Id, &Ht, &Pix, &Mono, Global );
			mt_list_get_colour( DialogTree, WCHANNEL_OUTPUT, &TColour, &BColour, Global );
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
			mt_list_set_font( DialogTree, WCHANNEL_OUTPUT, Id, Ht, Pix, Mono, Global );
			mt_list_set_colour( DialogTree, WCHANNEL_OUTPUT, TColour, BColour, Global );
			mt_list_scroll( DialogTree, WCHANNEL_OUTPUT, Events->msg[3], 0, 0, Global );
			DoRedraw((( DIALOG_DATA * ) DialogData)->Dialog, &Rect, WCHANNEL_OUTPUT, Global );
			SetVSlide( DialogData, Global );
			return( E_OK );
		}
	}
	return( E_OK );
}
static WORD	HndlClsDialog( void *DialogData, WORD Global[15] )
{
	CHANNEL_WINDOW	*ChannelWindow = ( CHANNEL_WINDOW * )(( DIALOG_DATA * ) DialogData )->UserData;
	IRC_CHANNEL	*IrcChannel = ChannelWindow->IrcChannel;
	mt_list_delete((( DIALOG_DATA *) DialogData)->Tree, WCHANNEL_OUTPUT, Global );
	if( ChannelWindow->Title )
		free( ChannelWindow->Title );
	if( ChannelWindow->Info )
		free( ChannelWindow->Info );
	FreeTree((( DIALOG_DATA *) DialogData)->Tree );
	free( DialogData );
	IrcChannel->ListWindow = NULL;
	free( ChannelWindow );
	CloseIrcChannel( IrcChannel );
	return( E_OK );
}

static void SizeDialog( DIALOG_DATA *DialogData, GRECT *Pos, WORD Global[15] )
{
	GRECT	New;
	WORD	Dw, Dh, NewRh, OldRh;

	MT_wind_calc( WC_WORK, CHANNEL_WINDOW_KINDS, Pos, &New, Global );

	Dw = New.g_w - DialogData->Tree[ROOT].ob_width;
	Dh = New.g_h - DialogData->Tree[ROOT].ob_height;

	if( New.g_w < TreeAddr[WCHANNEL][ROOT].ob_width )
		Dw = TreeAddr[WCHANNEL][ROOT].ob_width - DialogData->Tree[ROOT].ob_width;
	if( New.g_h < TreeAddr[WCHANNEL][ROOT].ob_height )
		Dh = TreeAddr[WCHANNEL][ROOT].ob_height - DialogData->Tree[ROOT].ob_height;

	{
		WORD	R = 0, D = Dw;
		if( DialogData->Tree[WCHANNEL_TOPIC].ob_width + D >= TreeAddr[WCHANNEL][WCHANNEL_TOPIC].ob_width )
			DialogData->Tree[WCHANNEL_TOPIC].ob_width += D;
		else
		{
			R = TreeAddr[WCHANNEL][WCHANNEL_TOPIC].ob_width - DialogData->Tree[WCHANNEL_TOPIC].ob_width;
			DialogData->Tree[WCHANNEL_TOPIC].ob_width += R;
			D -= R;
			if( DialogData->Tree[WCHANNEL_N].ob_width + D >= TreeAddr[WCHANNEL][WCHANNEL_N].ob_width )
				DialogData->Tree[WCHANNEL_N].ob_width += D;
			else
			{
				R = TreeAddr[WCHANNEL][WCHANNEL_N].ob_width - DialogData->Tree[WCHANNEL_N].ob_width;
				DialogData->Tree[WCHANNEL_N].ob_width += R;
				D -= R;
				if( DialogData->Tree[WCHANNEL_CHANNEL].ob_width + D >= TreeAddr[WCHANNEL][WCHANNEL_CHANNEL].ob_width )
					DialogData->Tree[WCHANNEL_CHANNEL].ob_width += D;
				else
				{
					R = TreeAddr[WCHANNEL][WCHANNEL_CHANNEL].ob_width - DialogData->Tree[WCHANNEL_CHANNEL].ob_width;
					DialogData->Tree[WCHANNEL_CHANNEL].ob_width += R;
					D -= R;
				}
			}
			DialogData->Tree[WCHANNEL_N].ob_x = DialogData->Tree[WCHANNEL_CHANNEL].ob_x + DialogData->Tree[WCHANNEL_CHANNEL].ob_width;
			DialogData->Tree[WCHANNEL_TOPIC].ob_x = DialogData->Tree[WCHANNEL_N].ob_x + DialogData->Tree[WCHANNEL_N].ob_width;
		}
	}

/*	if( DialogData->Tree[WCHANNEL_TOPIC].ob_width + Dw < TreeAddr[WCHANNEL][WCHANNEL_TOPIC].ob_width )
		Dw = TreeAddr[WCHANNEL][WCHANNEL_TOPIC].ob_width - DialogData->Tree[WCHANNEL_TOPIC].ob_width;
*/

	DialogData->Tree[ROOT].ob_width += Dw;
	DialogData->Tree[ROOT].ob_height += Dh;

	DialogData->Tree[WCHANNEL_OUTPUT_PARENT1].ob_width += Dw;
	DialogData->Tree[WCHANNEL_OUTPUT_PARENT1].ob_height += Dh;
	DialogData->Tree[WCHANNEL_OUTPUT_PARENT2].ob_width += Dw;
	DialogData->Tree[WCHANNEL_OUTPUT_PARENT2].ob_height += Dh;
	DialogData->Tree[WCHANNEL_OUTPUT].ob_width += Dw;
	DialogData->Tree[WCHANNEL_OUTPUT].ob_height += Dh;

	DialogData->Tree[WCHANNEL_HELP].ob_x += Dw;

	if( Dh || Dw )
	{
		mt_list_resize( DialogData->Tree, WCHANNEL_OUTPUT, &NewRh, &OldRh, Global );
		if( Dw )
			SetColumns( DialogData, Global );

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
	mt_list_get_scrollinfo( DialogData->Tree, WCHANNEL_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
	Size = nLines - yVis > 0 ? ( WORD ) (( yVis * 1000 ) / nLines ) : 1000;
	Pos = nLines - yVis > 0 ? ( WORD ) (( yScroll *1000 ) / ( nLines - yVis )) : 0;
	MT_wind_set_int( WinId, WF_VSLSIZE, Size, Global );
	MT_wind_set_int( WinId, WF_VSLIDE, Pos, Global );
}

static void	SetInfo( CHANNEL_WINDOW *ChannelWindow, BYTE *Str, WORD Global[15] )
{
	if( ChannelWindow->Info )
		free( ChannelWindow->Info );
	ChannelWindow->Info = malloc( strlen( Str ) + 2 );
	if( ChannelWindow->Info )
	{
		strcpy( ChannelWindow->Info, " " );
		strcat( ChannelWindow->Info, Str );
	}
	MT_wind_set_string( ChannelWindow->WinId, WF_INFO, ChannelWindow->Info, Global );
}

static void	SetInfoNChannels( CHANNEL_WINDOW *ChannelWindow, WORD Global[15] )
{
	LONG	nLines, yScroll;
	WORD	yVis, nCols, xScroll, xVis;
	BYTE	Puf[128];
	mt_list_get_scrollinfo( ChannelWindow->DialogData->Tree, WCHANNEL_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
	sprintf( Puf, "%li %s", nLines, TreeAddr[INFOS][N_CHANNELS].ob_spec.free_string );
	SetInfo( ChannelWindow, Puf, Global );
}

static void	Disable( CHANNEL_WINDOW *ChannelWindow, WORD Global[15] )
{
	DIALOG_DATA *DialogData = ChannelWindow->DialogData;
	DialogData->Tree[WCHANNEL_OPEN].ob_state |= DISABLED;
	DialogData->Tree[WCHANNEL_OPEN].ob_flags &= ~SELECTABLE;
	DialogData->Tree[WCHANNEL_OPEN].ob_flags &= ~SELECTABLE;
	DialogData->Tree[WCHANNEL_OPEN_I].ob_state |= DISABLED;
	DialogData->Tree[WCHANNEL_OPEN_I].ob_flags &= ~TOUCHEXIT;
	DialogData->Tree[WCHANNEL_UPDATE].ob_state |= DISABLED;
	DialogData->Tree[WCHANNEL_UPDATE].ob_flags &= ~TOUCHEXIT;
	DialogData->Tree[WCHANNEL_EDIT].ob_flags &= ~EDITABLE;
	DialogData->Tree[WCHANNEL_CHANNEL].ob_flags &= ~TOUCHEXIT;
	DialogData->Tree[WCHANNEL_CHANNEL_SORT].ob_flags &= ~TOUCHEXIT;
	DialogData->Tree[WCHANNEL_N].ob_flags &= ~TOUCHEXIT;
	DialogData->Tree[WCHANNEL_N_SORT].ob_flags &= ~TOUCHEXIT;
	DialogData->Tree[WCHANNEL_OUTPUT].ob_flags |= HIDETREE;
	if( DialogData->Dialog )
	{
		OBJECT		*DialogTree;
		GRECT			Rect;
		MT_wdlg_get_tree( DialogData->Dialog, &DialogTree, &Rect, Global );
		MT_wdlg_set_edit( DialogData->Dialog, 0, Global );
		DoRedraw( DialogData->Dialog, &Rect, ROOT, Global );
	}
}

static void SetColumns( DIALOG_DATA *DialogData, WORD Global[15] )
{
	WORD	Width[3];
	Width[0] = DialogData->Tree[WCHANNEL_CHANNEL].ob_width;
	Width[1] = DialogData->Tree[WCHANNEL_N].ob_width;
	Width[2] = DialogData->Tree[WCHANNEL_TOPIC].ob_width;
	mt_list_set_format( DialogData->Tree, WCHANNEL_OUTPUT, Width, Global );
	if( DialogData->Dialog )
	{
		OBJECT		*DialogTree;
		GRECT			Rect;
		MT_wdlg_get_tree( DialogData->Dialog, &DialogTree, &Rect, Global );
		DoRedrawX( DialogData->Dialog, &Rect, Global, WCHANNEL_CHANNEL, WCHANNEL_N, WCHANNEL_TOPIC, WCHANNEL_OUTPUT, EDRX );
	}
}

void	ChannelWindowRedraw( IRC_CHANNEL *IrcChannel, WORD Global[15] )
{
	CHANNEL_WINDOW	*ChannelWindow = IrcChannel->ListWindow;
	if( ChannelWindow )
	{
		DIALOG_DATA	*DialogData = ChannelWindow->DialogData;
		if( ChannelWindow->AppId == 0 && mt_list_get_dirty( DialogData->Tree, WCHANNEL_OUTPUT, Global ))
		{
			OBJECT		*DialogTree;
			GRECT			Rect;
			MT_wdlg_get_tree( DialogData->Dialog, &DialogTree, &Rect, Global );
			SetVSlide( DialogData, Global );
			mt_list_set_dirty( DialogData->Tree, WCHANNEL_OUTPUT, 0 , Global );
			DoRedraw( DialogData->Dialog, &Rect, WCHANNEL_OUTPUT, Global );
		}
	}
}

WORD	cdecl ChannelWindowCheckDisable( IRC_CHANNEL *IrcChannel, WORD Global[15] )
{
	CHANNEL_WINDOW	*ChannelWindow = IrcChannel->ListWindow;
	if( ChannelWindow )
	{
		if( ChannelWindow->ThreadFlag )
		{
			if( ChannelWindow->ModWinId )
			{
				EVNT	lEvents;
				lEvents.mwhich = MU_MESAG;
				lEvents.msg[0] = WM_TOPPED;
				lEvents.msg[1] = Global[2];
				lEvents.msg[2] = 0;
				lEvents.msg[3] = ChannelWindow->ModWinId;
				HandleWindow( &lEvents, Global );
			}
			else
				OpenAlertIrc( ChannelWindow->IrcChannel->IrcSession, NULL, ( ChannelWindow->ModWinId = AlertDialog( 1, TreeAddr[ALERTS][CHANNEL_WINDOW_BUSY].ob_spec.free_string, ChannelWindow->Title, CloseSessionAlertIrc, ChannelWindow->IrcChannel->IrcSession, Global )), MODWIN_CHANNEL );
			return( ERROR );
		}
		Disable( ChannelWindow, Global );
		ChannelWindow->ThreadFlag = THREAD_RECEIVE;
		SetInfo( ChannelWindow, TreeAddr[INFOS][GET_CHANNELS].ob_spec.free_string, Global );
	}
	return( E_OK );
}

void	ChannelWindowUpdate( IRC_CHANNEL *IrcChannel, WORD Global[15] )
{
	CHANNEL_WINDOW	*ChannelWindow = IrcChannel->ListWindow;
	if( ChannelWindow )
	{
		ChannelWindow->ThreadFlag &= ~THREAD_RECEIVE;
		if( !( ChannelWindow->ThreadFlag & THREAD_CLOSE ))
			ChannelWindowReadThread( IrcChannel, Global );
	}
}

static WORD	ChannelWindowRead( IRC_CHANNEL *IrcChannel, GRECT *Work, WORD *Id, WORD *Ht, WORD ColourTable[], LONG *yScroll, WORD Width[3], WORD *Sort, WORD Global[15] )
{
	CHANNEL_WINDOW	*ChannelWindow = IrcChannel->ListWindow;
	IRC_SESSION	*IrcSession = IrcChannel->IrcSession;
	IRC	*Irc = IrcSession->Irc;
	FILE	*File = NULL;
	XATTR	Xattr;
	BYTE	*Path, *HomePath, *DefaultPath;

	GetFilename( Irc->Host, "Channel", &Path, &HomePath, &DefaultPath );
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
		DIALOG_DATA	*DialogData = ChannelWindow->DialogData;
		BYTE	Puf[512], Version[32];

		fscanf( File, "%s\n", Version );
		fscanf( File, "%i, %i, %i, %i\n", &( Work->g_x ), &( Work->g_y ), &( Work->g_w ), &( Work->g_h ));
		fscanf( File, "%i, %i\n", Id, Ht );

		fgets( Puf, 512, File );
		ReadColourTable( atof( Version ), Puf, ColourTable );
		
		fscanf( File, "%li, %i, %i, %i, %i\n", yScroll, &Width[0], &Width[1], &Width[2], Sort );
		fclose( File );
		return( E_OK );
	}
	return( ERROR );
}

static void ChannelWindowReadThread( IRC_CHANNEL *IrcChannel, WORD Global[15] )
{
	CHANNEL_WINDOW	*ChannelWindow = IrcChannel->ListWindow;
	THREADINFO	Thread;
	if( ChannelWindow )
	{
		Thread.proc = (void *) ChannelWindowReadItem;
		Thread.user_stack = NULL;
		Thread.stacksize = 4096L;
		Thread.mode = 0;
		Thread.res1 = 0L;
		Disable( IrcChannel->ListWindow, Global );
		SetInfo( IrcChannel->ListWindow, TreeAddr[INFOS][READ_CHANNELS].ob_spec.free_string, Global );
		ChannelWindow->ThreadFlag |= THREAD_READ_1;
		ChannelWindow->AppId = MT_shel_write( SHW_THR_CREATE, 1, 0, ( char * ) &Thread, ( void * ) IrcChannel, Global );
	}
}

static LONG	cdecl	ChannelWindowReadItem( IRC_CHANNEL *IrcChannel, WORD Global[15] )
{
	CHANNEL_WINDOW	*ChannelWindow = IrcChannel->ListWindow;
	IRC_SESSION	*IrcSession = IrcChannel->IrcSession;
	IRC	*Irc = IrcSession->Irc;
	DIALOG_DATA	*DialogData = ChannelWindow->DialogData;
	FILE	*File = NULL;
	XATTR	Xattr;
	BYTE	*Path, *HomePath, *DefaultPath;
	WORD	lGlobal[15], AppId, TmpFlag = 1;
	LONG	nLines, yScroll, i;
	WORD	yVis, nCols, xScroll, xVis, Sort;

	AppId = MT_appl_init( lGlobal );

	Sort = mt_list_get_sort( DialogData->Tree, WCHANNEL_OUTPUT, Global );
	mt_list_get_scrollinfo( DialogData->Tree, WCHANNEL_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
	for( i = 0; i < nLines; i++ )
	{
		if( Sort == 2 || Sort == 4 )
			mt_list_delete_item( DialogData->Tree, WCHANNEL_OUTPUT, nLines - 1 - i, Global );
		else
			mt_list_delete_item( DialogData->Tree, WCHANNEL_OUTPUT, 0, Global );
	}
	ChannelWindow->ThreadFlag |= THREAD_READ_2;

	GetFilename( Irc->Host, "Tmp", &Path, &HomePath, &DefaultPath );
	if( DefaultPath && Fxattr( 0, DefaultPath, &Xattr ) == E_OK )
		File = fopen( DefaultPath, "r" );
	else	if( HomePath && Fxattr( 0, HomePath, &Xattr ) == E_OK )
		File = fopen( HomePath, "r" );
	else	if( Fxattr( 0, Path, &Xattr ) == E_OK )
		File = fopen( Path, "r" );

	if( !File )
	{
		if( Path )
			free( Path );
		if( HomePath )
			free( HomePath );
		if( DefaultPath )
			free( DefaultPath );
		GetFilename( Irc->Host, "List", &Path, &HomePath, &DefaultPath );
		if( DefaultPath && Fxattr( 0, DefaultPath, &Xattr ) == E_OK )
			File = fopen( DefaultPath, "r" );
		else	if( HomePath && Fxattr( 0, HomePath, &Xattr ) == E_OK )
			File = fopen( HomePath, "r" );
		else	if( Fxattr( 0, Path, &Xattr ) == E_OK )
			File = fopen( Path, "r" );
		TmpFlag = 0;
	}

	if( File )
	{
		BYTE	*Item[3], Puf[512], *Pos;
		WORD	i;
		Item[0] = malloc( 512 );
		Item[1] = malloc( 512 );
		Item[2] = malloc( 512 );
		if( Item[0] && Item[2] )
		{
			while( fgets( Item[0], 512, File ) != NULL )
			{
				fgets( Item[1], 512, File );
				fgets( Item[2], 512, File );
				Item[0][strlen(Item[0])-1]=0;
				Item[1][strlen(Item[1])-1]=0;
				Item[2][strlen(Item[2])-1]=0;
				if( strcmp( Item[0], "*" ))
				{
					if( mt_list_attach_item( DialogData->Tree, WCHANNEL_OUTPUT, Item, -1, TmpFlag, Global ) == ENSMEM )
					{
						MT_form_alert( 1, TreeAddr[ALERTS][MEMORY].ob_spec.free_string, lGlobal );
						TmpFlag = 0;
						break;
					}
				}
				MT_appl_yield( lGlobal );
			}
			free( Item[0] );
			free( Item[1] );
			free( Item[2] );
		}
		fclose( File );

		if( TmpFlag )
		{
			ChannelWindow->UpdateFlag = 1;
			if( DefaultPath && Fxattr( 0, DefaultPath, &Xattr ) == E_OK )
				Fdelete( DefaultPath );
			else	if( HomePath && Fxattr( 0, HomePath, &Xattr ) == E_OK )
				Fdelete( HomePath );
			else	if( Fxattr( 0, Path, &Xattr ) == E_OK )
				Fdelete( Path );
		}		

		if( Path )
			free( Path );
		if( HomePath )
			free( HomePath );
		if( DefaultPath )
			free( DefaultPath );
	}
	MT_appl_exit( lGlobal );
	return(( LONG ) ChannelWindow->WinId );
}

static void ChannelWindowWriteThread( IRC_CHANNEL *IrcChannel, WORD Global[15] )
{
	CHANNEL_WINDOW	*ChannelWindow = IrcChannel->ListWindow;
	THREADINFO	Thread;
	Thread.proc = (void *) ChannelWindowWrite;
	Thread.user_stack = NULL;
	Thread.stacksize = 4096L;
	Thread.mode = 0;
	Thread.res1 = 0L;
	Disable( IrcChannel->ListWindow, Global );
	SetInfo( IrcChannel->ListWindow, TreeAddr[INFOS][WRITE_CHANNELS].ob_spec.free_string, Global );
	ChannelWindow->ThreadFlag |= THREAD_WRITE;
	ChannelWindow->AppId = MT_shel_write( SHW_THR_CREATE, 1, 0, ( char * ) &Thread, ( void * ) IrcChannel, Global );
}
static LONG	cdecl ChannelWindowWrite( IRC_CHANNEL *IrcChannel, WORD Global[15] )
{
	CHANNEL_WINDOW	*ChannelWindow = IrcChannel->ListWindow;
	IRC_SESSION	*IrcSession = IrcChannel->IrcSession;
	IRC	*Irc = IrcSession->Irc;
	FILE	*File = NULL;
	BYTE	*Path, *HomePath, *DefaultPath;
	DIALOG_DATA	*DialogData = ChannelWindow->DialogData;
	WORD	lGlobal[15], AppId;
	LONG	nLines, yScroll, i;
	WORD	yVis, nCols, xScroll, xVis, Sort;

	AppId = MT_appl_init( lGlobal );

	mt_list_get_scrollinfo( DialogData->Tree, WCHANNEL_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
	Sort = mt_list_get_sort( DialogData->Tree, WCHANNEL_OUTPUT, Global );

	GetFilename( Irc->Host, "Channel", &Path, &HomePath, &DefaultPath );
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
		WORD	Id, Ht, Pix, Mono;
		LONG	Del = 0;
		mt_list_get_font( DialogData->Tree, WCHANNEL_OUTPUT, &Id, &Ht, &Pix, &Mono, Global );
		fprintf( File, "%s\n", VERSION );
		fprintf( File, "%i, %i, %i, %i\n", DialogData->Tree[ROOT].ob_x, DialogData->Tree[ROOT].ob_y, DialogData->Tree[ROOT].ob_width, DialogData->Tree[ROOT].ob_height );
		fprintf( File, "%i, %i\n", Id, Ht );
		for( i = 0; i < COLOUR_MAX - 1; i++ )
			fprintf( File, "%i, ", mt_list_get_colourtable( DialogData->Tree, WCHANNEL_OUTPUT, i, Global ));
		fprintf( File, "%i\n", 	mt_list_get_colourtable( DialogData->Tree, WCHANNEL_OUTPUT, i, Global ));
		fprintf( File, "%li, %i, %i, %i, %i\n", yScroll, DialogData->Tree[WCHANNEL_CHANNEL].ob_width, DialogData->Tree[WCHANNEL_N].ob_width, DialogData->Tree[WCHANNEL_TOPIC].ob_width, Sort );

		fclose( File );
	}
	else
		MT_form_alert( 1, TreeAddr[ALERTS][ERROR_WRITING_CHANNEL].ob_spec.free_string, lGlobal );

	if( ChannelWindow->UpdateFlag )
	{
		GetFilename( Irc->Host, "List", &Path, &HomePath, &DefaultPath );
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
			WORD	Colour;
			for( i = 0; i < nLines; i++ )
			{
				if( Sort == 2 || Sort == 4 )
				{
					Item = mt_list_get_item( DialogData->Tree, WCHANNEL_OUTPUT, nLines - 1 - i, &Colour, Global );
					if( Item )
						fprintf( File, "%s\n\n%s\n", Item[0], Item[2] );
					mt_list_delete_item( DialogData->Tree, WCHANNEL_OUTPUT, nLines - 1 - i, Global );
				}
				else
				{
					Item = mt_list_get_item( DialogData->Tree, WCHANNEL_OUTPUT, 0, &Colour, Global );
					if( Item )
						fprintf( File, "%s\n\n%s\n", Item[0], Item[2] );
					mt_list_delete_item( DialogData->Tree, WCHANNEL_OUTPUT, 0, Global );
				}
				MT_appl_yield( lGlobal );
			}
			fclose( File );
		}
		else
			MT_form_alert( 1, TreeAddr[ALERTS][ERROR_WRITING_CHANNEL].ob_spec.free_string, lGlobal );
	}
	MT_appl_exit( lGlobal );
	return(( LONG ) ChannelWindow->WinId );
}

static void	StartSortThread( DIALOG_DATA *DialogData, WORD Global[15] )
{
	CHANNEL_WINDOW *ChannelWindow = ( CHANNEL_WINDOW *) DialogData->UserData;
	THREADINFO	Thread;
	Thread.proc = (void *) SortThread;
	Thread.user_stack = NULL;
	Thread.stacksize = 4096L;
	Thread.mode = 0;
	Thread.res1 = 0L;

	Disable(( CHANNEL_WINDOW * ) DialogData->UserData, Global );
	SetInfo( ChannelWindow, TreeAddr[INFOS][SORT_CHANNELS].ob_spec.free_string, Global );
	ChannelWindow->ThreadFlag |= THREAD_SORT;
	ChannelWindow->AppId = MT_shel_write( SHW_THR_CREATE, 1, 0, ( char * ) &Thread, ( void * ) DialogData, Global );
}
static LONG	cdecl	SortThread( void *Parameter )
{
	DIALOG_DATA	*DialogData = Parameter;
	CHANNEL_WINDOW *ChannelWindow = ( CHANNEL_WINDOW *) DialogData->UserData;
	WORD	Sort = mt_list_get_sort( DialogData->Tree, WCHANNEL_OUTPUT, Global );
	if( Sort == 0 || Sort == 3 || Sort == 4 )
		mt_list_set_sort( DialogData->Tree, WCHANNEL_OUTPUT, 1, Global );
	else	if( Sort == 1 || Sort == 2 )
		mt_list_set_sort( DialogData->Tree, WCHANNEL_OUTPUT, 3, Global );
	ChannelWindow->UpdateFlag = 1;
	return(( LONG ) ChannelWindow->WinId );
}

static WORD	StrCmp( BYTE *Str1, BYTE *Str2 )
{
	long len, i;
	len = strlen( Str1 ) < strlen( Str2 ) ? strlen( Str1 ) : strlen( Str2 );
	for( i = 0; i < len; i++ )
	{
		if( Str1[i] == Str2[i] )
			continue;
		else	if( Str1[i] < Str2[i] )
			return( -1 );
		else
			return( 1 );
	}
	return( 0 );
}