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
#include	"Dd.h"
#include	"ExtObj\ListObj.h"
#include	"Fsel.h"
#include	"Irc.h"
#include	"Help.h"
#include	"Menu.h"
#include	"Rsc.h"
#include	"WDialog.h"
#include	"Window.h"
#include	"WIrc\Func.h"
#include	"WIrc\IrcFunc.h"
#include	"WIrc\WDccData.h"
#include	"WIrc\WPut.h"

#include	"EdScroll.h"
#include	"Keytab.h"
#include	"MapKey.h"

#define	PUT_WINDOW_KINDS		NAME + FULLER + MOVER + ICONIFIER + VSLIDE + UPARROW + DNARROW + SIZER + INFO

typedef	struct
{
	WORD			WinId;
	GRECT			NextFuller;
	IRC_CHANNEL	*IrcChannel;
}	PUT_WINDOW;

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	Global[15];
extern OBJECT	**TreeAddr;
extern GRECT	ScreenRect;
extern WORD	isScroll;
extern BYTE	*UploadPath;

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
static XTED	Xted;
static BYTE	Tmplt[EDITLEN+1], Txt[EDITLEN+1];

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static WORD cdecl	HandleDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData );
static WORD	HndlDdDialog( void *DialogData, EVNT *Events, WORD Global[15] );
static WORD	HndlClsDialog( void *DialogData, WORD Global[15] );

static void	SetVSlide( DIALOG_DATA *DialogData, WORD Global[15] );
static void SizeDialog( DIALOG_DATA *DialogData, GRECT *New, WORD Global[15] );
static void SetColumns( DIALOG_DATA *DialogData, WORD Global[15] );
static void	CheckButton( DIALOG_DATA *DialogData, WORD Global[15] );

static void	Insert( DIALOG_DATA *DialogData, BYTE *Path, WORD Global[15] );
static void	Calc( DIALOG_DATA *DialogData, WORD Global[15] );
static BYTE	*Space( BYTE *Puf );
static LONG ReCalc( BYTE *Puf );

/*-----------------------------------------------------------------------------*/
/* OpenPutWindow                                                               */
/*-----------------------------------------------------------------------------*/
WORD	OpenPutWindow( IRC_CHANNEL *IrcChannel, BYTE *Nickname, WORD Global[15] )
{
	WORD	Ret;
	PUT_WINDOW	*PutWindow = malloc( sizeof( PUT_WINDOW ));
	DIALOG_DATA	*DialogData = malloc( sizeof( DIALOG_DATA ));
	
	if( !DialogData || !PutWindow )
		return( ENSMEM );
	
	if( TreeAddr[PUT][PUT_NICK].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
		InitScrlted( &TreeAddr[PUT][PUT_NICK], isScroll, &Xted, Txt, Tmplt, EDITLEN );

	PutWindow->IrcChannel = IrcChannel;
	PutWindow->NextFuller.g_x = ScreenRect.g_x;
	PutWindow->NextFuller.g_y = ScreenRect.g_y;
	PutWindow->NextFuller.g_w = ScreenRect.g_w;
	PutWindow->NextFuller.g_h = ScreenRect.g_h;

	DialogData->Dialog = NULL;
	DialogData->HndlDdDialog = HndlDdDialog;
	DialogData->HndlClsDialog = HndlClsDialog;
	DialogData->HndlMesagDialog = NULL;
	DialogData->HndlEditDialog = NULL;
	DialogData->HndlHelpDialog = NULL;
	DialogData->HndlTimerDialog = NULL;
	DialogData->HndlCheckDialog = NULL;
	DialogData->UserData = PutWindow;
	DialogData->TreeIndex = PUT;

	if(( DialogData->Tree = CopyTree( TreeAddr[PUT] )) == NULL )
	{
		free( PutWindow );
		free( DialogData );
		return( ENSMEM );
	}

	if(( Ret = mt_list_create( DialogData->Tree, PUT_OUTPUT, 2, Global )) != E_OK )
	{
		FreeTree( DialogData->Tree );
		free( DialogData );
		free( PutWindow );
		return( Ret );
	}
	SetIconBlk( FreeIconBlk( DialogData->Tree[PUT_NAME_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AUF].ob_spec.iconblk );
	SetIconBlk( FreeIconBlk(  DialogData->Tree[PUT_SIZE_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_NO].ob_spec.iconblk );
	mt_list_set_sort( DialogData->Tree, PUT_OUTPUT, 1, Global );
	mt_list_set_mode( DialogData->Tree, PUT_OUTPUT, LISTOBJ_MULTIPLE, Global );
	SetColumns( DialogData, Global );

	Nickname ? strcpy( DialogData->Tree[PUT_NICK].ob_spec.tedinfo->te_ptext, Nickname ) : strcpy( DialogData->Tree[PUT_NICK].ob_spec.tedinfo->te_ptext, "" );
	sprintf( DialogData->Tree[PUT_PACKET_SIZE].ob_spec.tedinfo->te_ptext, "%u", 512 );
	strcpy( DialogData->Tree[PUT_N].ob_spec.free_string, "0" );
	strcpy( DialogData->Tree[PUT_SIZEOVERALL].ob_spec.free_string, "0" );
	DialogData->Tree[PUT_OK_I].ob_flags &= ~TOUCHEXIT;
	DialogData->Tree[PUT_OK_I].ob_state |= DISABLED;
	DialogData->Tree[PUT_OK].ob_flags &= ~SELECTABLE;
	DialogData->Tree[PUT_OK].ob_state |= DISABLED;
	DialogData->Tree[PUT_DEL_I].ob_flags &= ~TOUCHEXIT;
	DialogData->Tree[PUT_DEL_I].ob_state |= DISABLED;
	DialogData->Tree[PUT_DEL].ob_flags &= ~SELECTABLE;
	DialogData->Tree[PUT_DEL].ob_state |= DISABLED;

	OpenDialogX( IrcChannel->ChatWindow->Title, WIN_ALERT_WINDOW, PUT_WINDOW_KINDS, -1, -1, HandleDialog, DialogData, Global );
	PutWindow->WinId = MT_wdlg_get_handle( DialogData->Dialog, Global );
	SetVSlide( DialogData, Global );
	return( PutWindow->WinId );
}

/*-----------------------------------------------------------------------------*/
/* HandleDialog                                                                */
/*-----------------------------------------------------------------------------*/
static WORD cdecl	HandleDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UserData )
{
	OBJECT			*DialogTree;
	GRECT				Rect;
	DIALOG_DATA		*DialogData = ( DIALOG_DATA * ) MT_wdlg_get_udata( Dialog, Global );
	PUT_WINDOW		*PutWindow = ( PUT_WINDOW * ) DialogData->UserData;
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
			case	HNDL_CLSD:
				if( Events->msg[4] == WIN_CLOSE_WITHOUT_DEMAND )
					return( 0 );
				else
					break;
			case	HNDL_EDDN:
				CheckButton( DialogData, Global );
				break;
			case	HNDL_MESG:
			{
				switch( Events->msg[0] )
				{
					case	WM_SIZED:
						SizeDialog( DialogData, ( GRECT *) &( Events->msg[4] ), Global );
						break;
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
						lEvents.msg[4] = PutWindow->NextFuller.g_x;
						lEvents.msg[5] = PutWindow->NextFuller.g_y;
						lEvents.msg[6] = PutWindow->NextFuller.g_w;
						lEvents.msg[7] = PutWindow->NextFuller.g_h;
						HandleWindow( &lEvents, Global );
						lEvents.mwhich = MU_MESAG;
						lEvents.msg[0] = WM_SIZED;
						lEvents.msg[1] = Global[2];
						lEvents.msg[2] = 0;
						lEvents.msg[3] = Events->msg[3];
						lEvents.msg[4] = PutWindow->NextFuller.g_x;
						lEvents.msg[5] = PutWindow->NextFuller.g_y;
						lEvents.msg[6] = PutWindow->NextFuller.g_w;
						lEvents.msg[7] = PutWindow->NextFuller.g_h;
						HandleWindow( &lEvents, Global );
						PutWindow->NextFuller.g_x = Pos.g_x;
						PutWindow->NextFuller.g_y = Pos.g_y;
						PutWindow->NextFuller.g_w = Pos.g_w;
						PutWindow->NextFuller.g_h = Pos.g_h;
						break;
					}
					case	WM_ARROWED:
					{
						if( Events->msg[4] == WA_UPPAGE )
						{
							LONG	nLines, yScroll;
							WORD	yVis, nCols, xScroll, xVis;
							mt_list_get_scrollinfo( DialogTree, PUT_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
							mt_list_scroll( DialogTree, PUT_OUTPUT, Events->msg[3], -yVis, 0, Global );
						}
						else	if( Events->msg[4] == WA_DNPAGE )
						{
							LONG	nLines, yScroll;
							WORD	yVis, nCols, xScroll, xVis;
							mt_list_get_scrollinfo( DialogTree, PUT_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
							mt_list_scroll( DialogTree, PUT_OUTPUT, Events->msg[3], yVis, 0, Global );
						}
						else	if( Events->msg[4] == WA_UPLINE )
							mt_list_scroll( DialogTree, PUT_OUTPUT, Events->msg[3], -1, 0, Global );
						else	if( Events->msg[4] == WA_DNLINE )
							mt_list_scroll( DialogTree, PUT_OUTPUT, Events->msg[3], 1, 0, Global );
						SetVSlide( DialogData, Global );
						break;
					}
					case	WM_VSLID:
					{
						LONG	nLines, yScroll;
						WORD	yVis, nCols, xScroll, xVis, dyPos;
						mt_list_get_scrollinfo( DialogTree, PUT_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
						dyPos = nLines - yVis > 0 ? Events->msg[4] * ( nLines - yVis ) / 1000 - yScroll : 0;
						mt_list_scroll( DialogTree, PUT_OUTPUT, Events->msg[3], dyPos, 0, Global );
						SetVSlide( DialogData, Global );
						break;
					}
				}
				break;
			}
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
			StGuide_Action( DialogTree, NEW, Global );
			return( 1 );
		}
		if( Obj == PUT_OUTPUT && mt_list_evnt( DialogTree, PUT_OUTPUT, PutWindow->WinId, Events, Global ) == -1 )
		{
		}
		CheckButton( DialogData, Global );
		if( DialogTree[Obj].ob_state & DISABLED )
		{
			DialogTree[Obj].ob_state &= ~SELECTED;
			return( 1 );
		}
		switch( Obj )
		{
			case	PUT_CANCEL:
				return( 0 );
			case	PUT_ADD:
			{
				BYTE	*Path;
				Path = Fsel( UploadPath, "*", TreeAddr[TITLES][FSEL_PUTADD].ob_spec.free_string, Global );
				if( Path )
				{
					Insert( DialogData, Path, Global );
					free( Path );
					Calc( DialogData, Global );
					DoRedraw( Dialog, &Rect, PUT_OUTPUT, Global );
					SetVSlide( DialogData, Global );
					CheckButton( DialogData, Global );
				}
				DialogTree[PUT_ADD].ob_state &= ~SELECTED;
				DoRedraw( Dialog, &Rect, PUT_ADD, Global );
				break;
			}
			case	PUT_DEL:
			{
				LONG	nLines, yScroll, i;
				WORD	yVis, nCols, xScroll, xVis;
				mt_list_get_scrollinfo( DialogTree, PUT_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
				for( i = nLines - 1; i >= 0; i-- )
				{
					if( mt_list_is_selected( DialogTree, PUT_OUTPUT, i, Global ))
						mt_list_delete_item( DialogTree, PUT_OUTPUT, i, Global );
				}
				Calc( DialogData, Global );
				DoRedraw( Dialog, &Rect, PUT_OUTPUT, Global );
				SetVSlide( DialogData, Global );
				CheckButton( DialogData, Global );
				DialogTree[PUT_DEL].ob_state &= ~SELECTED;
				DoRedraw( Dialog, &Rect, PUT_DEL, Global );
				break;
			}
			case	PUT_OK:
			{
				LONG	nLines, yScroll, i;
				WORD	yVis, nCols, xScroll, xVis, lColour;
				BYTE	**Tmp;

				mt_list_get_scrollinfo( DialogTree, PUT_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
				for( i = 0; i < nLines; i++ )
				{
					Tmp = mt_list_get_item( DialogTree, PUT_OUTPUT, i, &lColour, Global );
					StartDccTx( PutWindow->IrcChannel->IrcSession, DialogTree[PUT_NICK].ob_spec.tedinfo->te_ptext, atol( DialogTree[PUT_PACKET_SIZE].ob_spec.tedinfo->te_ptext ), Tmp[0], ReCalc( Tmp[1] ), Global );
				}
				return( 0 );
			}
			case	PUT_NAME:
			case	PUT_SIZE:
			{
				EVNTDATA	EvData;
				MT_graf_mkstate( &EvData, Global );
				if( EvData.bstate == 1 )
				{
					WORD	xName, xSize, Dummy;
					MT_objc_offset( DialogTree, PUT_NAME, &xName, &Dummy, Global );
					xSize = xName + DialogTree[PUT_NAME].ob_width;
					if(( Obj == PUT_NAME && EvData.x >= xSize - 8 ) || ( Obj == PUT_SIZE && EvData.x <= xSize + 8 ))
					{
						WORD	x = EvData.x, Dx;
						MT_graf_mouse( M_SAVE, NULL, Global );
						MT_graf_mouse( POINT_HAND, NULL, Global );
						while( EvData.bstate == 1 )
						{
							Dx = EvData.x - x;

							if( DialogTree[PUT_NAME].ob_width + Dx < TreeAddr[PUT][PUT_NAME_SORT].ob_x + TreeAddr[PUT][PUT_NAME_SORT].ob_width )
								Dx = TreeAddr[PUT][PUT_NAME_SORT].ob_x + TreeAddr[PUT][PUT_NAME_SORT].ob_width - DialogTree[PUT_NAME].ob_width;
							if( DialogTree[PUT_SIZE].ob_width - Dx < TreeAddr[PUT][PUT_SIZE].ob_width )
								Dx = DialogTree[PUT_SIZE].ob_width - TreeAddr[PUT][PUT_SIZE].ob_width;
							DialogTree[PUT_NAME].ob_width += Dx;
							DialogTree[PUT_SIZE].ob_x += Dx;
							DialogTree[PUT_SIZE].ob_width -= Dx;

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
			case	PUT_NAME_SORT:
			case	PUT_SIZE_SORT:
			{
				WORD	Sort = mt_list_get_sort( DialogTree, PUT_OUTPUT, Global ), Button;
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
				if( Obj == PUT_NAME || Obj == PUT_NAME_SORT )
				{
					if( Sort == 1 )
					{
						mt_list_set_sort( DialogTree, PUT_OUTPUT, 2, Global );
						SetIconBlk( FreeIconBlk( DialogData->Tree[PUT_NAME_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AB].ob_spec.iconblk );
						DoRedrawX( Dialog, &Rect, Global, PUT_NAME, PUT_OUTPUT, EDRX );
					}
					else	if( Sort == 2 )
					{
						mt_list_set_sort( DialogTree, PUT_OUTPUT, 1, Global );
						SetIconBlk( FreeIconBlk( DialogData->Tree[PUT_NAME_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AUF].ob_spec.iconblk );
						DoRedrawX( Dialog, &Rect, Global, PUT_NAME, PUT_OUTPUT, EDRX );
					}
					else
					{
						mt_list_set_sort( DialogData->Tree, PUT_OUTPUT, 1, Global );
						SetIconBlk( FreeIconBlk( DialogData->Tree[PUT_NAME_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AUF].ob_spec.iconblk );
						SetIconBlk( FreeIconBlk( DialogData->Tree[PUT_SIZE_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_NO].ob_spec.iconblk );
						DoRedrawX( Dialog, &Rect, Global, PUT_NAME, PUT_SIZE, PUT_OUTPUT, EDRX );
					}
				}
				if( Obj == PUT_SIZE || Obj == PUT_SIZE_SORT )
				{
					if( Sort == 3 )
					{
						mt_list_set_sort( DialogTree, PUT_OUTPUT, 4, Global );
						SetIconBlk( FreeIconBlk( DialogData->Tree[PUT_SIZE_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AB].ob_spec.iconblk );
						DoRedrawX( Dialog, &Rect, Global, PUT_SIZE, PUT_OUTPUT, EDRX );
					}
					else	if( Sort == 4 )
					{
						mt_list_set_sort( DialogTree, PUT_OUTPUT, 3, Global );
						SetIconBlk( FreeIconBlk( DialogData->Tree[PUT_SIZE_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AUF].ob_spec.iconblk );
						DoRedrawX( Dialog, &Rect, Global, PUT_SIZE, PUT_OUTPUT, EDRX );
					}
					else
					{
						mt_list_set_sort( DialogData->Tree, PUT_OUTPUT, 3, Global );
						SetIconBlk( FreeIconBlk( DialogData->Tree[PUT_SIZE_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_AUF].ob_spec.iconblk );
						SetIconBlk( FreeIconBlk( DialogData->Tree[PUT_NAME_SORT].ob_spec.iconblk ), TreeAddr[ICONS][SORT_NO].ob_spec.iconblk );
						DoRedrawX( Dialog, &Rect, Global, PUT_NAME, PUT_SIZE, PUT_OUTPUT, EDRX );
					}
				}
				break;
			}
		}
	}
	return( 1 );
}

/*-----------------------------------------------------------------------------*/
/* HndlDdDialog                                                                */
/*-----------------------------------------------------------------------------*/
static WORD	HndlDdDialog( void *DialogData, EVNT *Events, WORD Global[15] )
{
	PUT_WINDOW	*PutWindow = ( PUT_WINDOW * )(( DIALOG_DATA * ) DialogData )->UserData;
	if(( Events->mwhich & MU_MESAG ) && ( Events->msg[0] == AP_DRAGDROP || ( Events->msg[0] == WIN_CMD && Events->msg[4] == WIN_DRAGDROP )))
	{
		BYTE	*Puf, *Tmp;
		OBJECT			*DialogTree;
		GRECT				Rect;
		MT_wdlg_get_tree((( DIALOG_DATA * ) DialogData )->Dialog, &DialogTree, &Rect, Global );
		if( Events->msg[0] == AP_DRAGDROP )
		{
			LONG	Size;
			ULONG	FormatRcvr[8], Format;
			FormatRcvr[0] = 'ARGS';	FormatRcvr[1] = '.TXT';	FormatRcvr[2] = 0;	FormatRcvr[3] = 0;
			FormatRcvr[4] = 0;	FormatRcvr[5] = 0;	FormatRcvr[6] = 0;	FormatRcvr[7] = 0;
			if( GetDragDrop( Events, FormatRcvr, &Format, &Puf, &Size ) != E_OK )
				return( E_OK );
		}
		if( Events->msg[4] == WIN_DRAGDROP )
		{
			DD_INFO	*DdInfo = *( DD_INFO ** )&( Events->msg[5] );
			if( DdInfo->format == '.TXT' || DdInfo->format == 'ARGS' )
				Puf = DdInfo->puf;
			else
				return( E_OK );
		}
		Tmp = Puf;
		while( *Tmp )
		{
			Insert(( DIALOG_DATA * ) DialogData, Tmp, Global );
			Tmp += strlen( Tmp ) + 1;
		}
		free( Puf );
		Calc(( DIALOG_DATA * ) DialogData, Global );
		DoRedraw((( DIALOG_DATA * ) DialogData )->Dialog, &Rect, PUT_OUTPUT, Global );
		SetVSlide(( DIALOG_DATA * ) DialogData, Global );
		CheckButton( ( DIALOG_DATA * ) DialogData, Global );
		return( E_OK );
	}
	return( ERROR );
}

/*-----------------------------------------------------------------------------*/
/* HndlClsDialog                                                               */
/*-----------------------------------------------------------------------------*/
static WORD	HndlClsDialog( void *DialogData, WORD Global[15] )
{
	PUT_WINDOW	*PutWindow = ( PUT_WINDOW * )(( DIALOG_DATA * ) DialogData )->UserData;

	CloseChannelAlertIrc( PutWindow->IrcChannel, 0, PutWindow->WinId, Global );
	free( PutWindow );

	mt_list_delete((( DIALOG_DATA *) DialogData)->Tree, PUT_OUTPUT, Global );
	FreeTree((( DIALOG_DATA *) DialogData)->Tree );
	free( DialogData );
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* SetVSlide                                                                   */
/*-----------------------------------------------------------------------------*/
static void	SetVSlide( DIALOG_DATA *DialogData, WORD Global[15] )
{
	PUT_WINDOW	*PutWindow = ( PUT_WINDOW * )(( DIALOG_DATA * ) DialogData )->UserData;
	LONG	nLines, yScroll;
	WORD	yVis, nCols, xScroll, xVis;
	LONG	Pos, Size;
	mt_list_get_scrollinfo( DialogData->Tree, PUT_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
	Size = nLines - yVis > 0 ? (((( LONG ) yVis ) * 1000 ) / nLines ) : 1000;
	Pos = nLines - yVis > 0 ? (((( LONG ) yScroll ) * 1000 ) / ( nLines - yVis )) : 0;
	MT_wind_set_int( PutWindow->WinId, WF_VSLSIZE, Size, Global );
	MT_wind_set_int( PutWindow->WinId, WF_VSLIDE, Pos, Global );
}

/*-----------------------------------------------------------------------------*/
/* SizeDialog                                                                   */
/*-----------------------------------------------------------------------------*/
static void SizeDialog( DIALOG_DATA *DialogData, GRECT *Pos, WORD Global[15] )
{
	GRECT	New;
	WORD	Dw, Dh, NewRh, OldRh;

	MT_wind_calc( WC_WORK, PUT_WINDOW_KINDS, Pos, &New, Global );

	Dw = New.g_w - DialogData->Tree[ROOT].ob_width;
	Dh = New.g_h - DialogData->Tree[ROOT].ob_height;

	if( New.g_w < TreeAddr[PUT][ROOT].ob_width )
		Dw = TreeAddr[PUT][ROOT].ob_width - DialogData->Tree[ROOT].ob_width;
	if( New.g_h < TreeAddr[PUT][ROOT].ob_height )
		Dh = TreeAddr[PUT][ROOT].ob_height - DialogData->Tree[ROOT].ob_height;

	DialogData->Tree[ROOT].ob_width += Dw;
	DialogData->Tree[ROOT].ob_height += Dh;

	DialogData->Tree[PUT_OUTPUT_PARENT1].ob_width += Dw;
	DialogData->Tree[PUT_OUTPUT_PARENT1].ob_height += Dh;
	DialogData->Tree[PUT_OUTPUT_PARENT2].ob_width += Dw;
	DialogData->Tree[PUT_OUTPUT_PARENT2].ob_height += Dh;
	DialogData->Tree[PUT_OUTPUT_BOTTOM].ob_width += Dw;
	DialogData->Tree[PUT_OUTPUT_BOTTOM].ob_y += Dh;
	DialogData->Tree[PUT_OUTPUT].ob_width += Dw;
	DialogData->Tree[PUT_OUTPUT].ob_height += Dh;
	DialogData->Tree[PUT_NAME].ob_width += Dw;
	DialogData->Tree[PUT_SIZE].ob_x += Dw;

	DialogData->Tree[PUT_BOTTOM].ob_width += Dw;
	DialogData->Tree[PUT_BOTTOM].ob_y += Dh;
	DialogData->Tree[PUT_OK].ob_x += Dw;
	DialogData->Tree[PUT_CANCEL].ob_x += Dw;

	DialogData->Tree[PUT_HELP].ob_x += Dw;

	if( Dh || Dw )
	{
		mt_list_resize( DialogData->Tree, PUT_OUTPUT, &NewRh, &OldRh, Global );
		if( Dw )
			SetColumns( DialogData, Global );

		if( DialogData->Dialog )
		{
			MT_wdlg_set_tree( DialogData->Dialog, DialogData->Tree, Global );
			SetVSlide( DialogData, Global );
		}
	}
}

/*-----------------------------------------------------------------------------*/
/* SizeDialog                                                                   */
/*-----------------------------------------------------------------------------*/
static void SetColumns( DIALOG_DATA *DialogData, WORD Global[15] )
{
	WORD	Width[2];
	Width[0] = DialogData->Tree[PUT_NAME].ob_width;
	Width[1] = DialogData->Tree[PUT_SIZE].ob_width;
	mt_list_set_format( DialogData->Tree, PUT_OUTPUT, Width, Global );
	if( DialogData->Dialog )
	{
		OBJECT		*DialogTree;
		GRECT			Rect;
		MT_wdlg_get_tree( DialogData->Dialog, &DialogTree, &Rect, Global );
		DoRedrawX( DialogData->Dialog, &Rect, Global, PUT_NAME, PUT_SIZE, PUT_OUTPUT, EDRX );
	}
}

/*-----------------------------------------------------------------------------*/
/* CheckButton                                                                 */
/*-----------------------------------------------------------------------------*/
static void	CheckButton( DIALOG_DATA *DialogData, WORD Global[15] )
{
	LONG	nLines, yScroll;
	WORD	yVis, nCols, xScroll, xVis;
	OBJECT			*DialogTree;
	GRECT				Rect;
	MT_wdlg_get_tree( DialogData->Dialog, &DialogTree, &Rect, Global );
	mt_list_get_scrollinfo( DialogTree, PUT_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
	if( nLines && strlen( DialogTree[PUT_NICK].ob_spec.tedinfo->te_ptext ) && strlen( DialogTree[PUT_PACKET_SIZE].ob_spec.tedinfo->te_ptext ))
	{
		if( DialogTree[PUT_OK].ob_state & DISABLED )
		{
			DialogData->Tree[PUT_OK_I].ob_flags |= TOUCHEXIT;
			DialogData->Tree[PUT_OK_I].ob_state &= ~DISABLED;
			DialogData->Tree[PUT_OK].ob_flags |= SELECTABLE;
			DialogData->Tree[PUT_OK].ob_state &= ~DISABLED;
			DoRedraw( DialogData->Dialog, &Rect, PUT_OK, Global );
		}
	}
	else
	{
		if( DialogTree[PUT_OK].ob_flags & SELECTABLE )
		{
			DialogData->Tree[PUT_OK_I].ob_flags &= ~TOUCHEXIT;
			DialogData->Tree[PUT_OK_I].ob_state |= DISABLED;
			DialogData->Tree[PUT_OK].ob_flags &= ~SELECTABLE;
			DialogData->Tree[PUT_OK].ob_state |= DISABLED;
			DoRedraw( DialogData->Dialog, &Rect, PUT_OK, Global );
		}
	}
	if( mt_list_get_selected( DialogTree, PUT_OUTPUT, Global ) > 0 )
	{
		if( DialogTree[PUT_DEL].ob_state & DISABLED )
		{
			DialogData->Tree[PUT_DEL_I].ob_flags |= TOUCHEXIT;
			DialogData->Tree[PUT_DEL_I].ob_state &= ~DISABLED;
			DialogData->Tree[PUT_DEL].ob_flags |= SELECTABLE;
			DialogData->Tree[PUT_DEL].ob_state &= ~DISABLED;
			DoRedraw( DialogData->Dialog, &Rect, PUT_DEL, Global );
		}
	}
	else
	{
		if( DialogTree[PUT_DEL].ob_flags & SELECTABLE )
		{
			DialogData->Tree[PUT_DEL_I].ob_flags &= ~TOUCHEXIT;
			DialogData->Tree[PUT_DEL_I].ob_state |= DISABLED;
			DialogData->Tree[PUT_DEL].ob_flags &= ~SELECTABLE;
			DialogData->Tree[PUT_DEL].ob_state |= DISABLED;
			DoRedraw( DialogData->Dialog, &Rect, PUT_DEL, Global );
		}
	}
}

/*-----------------------------------------------------------------------------*/
/* Insert                                                                      */
/*-----------------------------------------------------------------------------*/
static void	Insert( DIALOG_DATA *DialogData, BYTE *Path, WORD Global[15] )
{
	XATTR	Xattr;
	if( Fxattr( 0, Path, &Xattr ) == E_OK )
	{
		if( Xattr.attr & FA_SUBDIR )
		{
			LONG	DirHandle;
			BYTE	Puf[512], Tmp[512];
			DirHandle = Dopendir( Path, 0 );
			if( DirHandle & 0xff000000L )
			{
			}
			else
			{
				while( Dreaddir( 512, DirHandle, Puf ) == E_OK )
				{
					strcpy( Tmp, Path );
					if( Path[strlen(Path)-1] != '\\' )
						strcat( Tmp, "\\" );
					strcat( Tmp, &Puf[4] );
					Insert( DialogData, Tmp, Global );
				}
				Dclosedir( DirHandle );
			}
		}
		else
		{
			BYTE	*Item[2], **Cmp, Puf[128];
			LONG	nLines, yScroll, i;
			WORD	yVis, nCols, xScroll, xVis, lColour;
			OBJECT			*DialogTree;
			GRECT				Rect;
			MT_wdlg_get_tree((( DIALOG_DATA * ) DialogData )->Dialog, &DialogTree, &Rect, Global );
			mt_list_get_scrollinfo( DialogTree, PUT_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
			for( i = 0; i < nLines; i++ )
			{
				Cmp = mt_list_get_item( DialogData->Tree, PUT_OUTPUT, i, &lColour, Global );
				if( !strcmp( Path, Cmp[0] ))
				{
					mt_list_delete_item( DialogData->Tree, PUT_OUTPUT, i, Global );
					break;
				}
			}
			Item[0] = Path;
			Item[1] = Space( Decimal(( ULONG ) Xattr.size, Puf ));
			mt_list_attach_item( DialogData->Tree, PUT_OUTPUT, Item, -1, 1, Global );
		}
	}
}

/*-----------------------------------------------------------------------------*/
/* Calc                                                                        */
/*-----------------------------------------------------------------------------*/
static void	Calc( DIALOG_DATA *DialogData, WORD Global[15] )
{
	LONG	nLines, yScroll, i, Size = 0;
	WORD	yVis, nCols, xScroll, xVis, lColour;
	BYTE	**Tmp, Puf[128];
	OBJECT			*DialogTree;
	GRECT				Rect;
	MT_wdlg_get_tree((( DIALOG_DATA * ) DialogData )->Dialog, &DialogTree, &Rect, Global );
	mt_list_get_scrollinfo( DialogTree, PUT_OUTPUT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
	sprintf( DialogTree[PUT_N].ob_spec.free_string, "%li", nLines );
	for( i = 0; i < nLines; i++ )
	{
		Tmp = mt_list_get_item( DialogData->Tree, PUT_OUTPUT, i, &lColour, Global );
		Size += ReCalc( Tmp[1] );
	}
	strcpy( DialogTree[PUT_SIZEOVERALL].ob_spec.free_string, Decimal(( ULONG ) Size, Puf ));
	DoRedraw( DialogData->Dialog, &Rect, PUT_OUTPUT_BOTTOM, Global );
}

static BYTE	*Space( BYTE *Puf )
{
	WORD	i, j = 10;
	BYTE	Tmp[12];
	strcpy( Tmp, "           " );
	for( i = (WORD)strlen( Puf ) - 1; i >= 0; i-- )
		Tmp[j--] = Puf[i];
	strcpy( Puf, Tmp );
	return( Puf );
}

static LONG ReCalc( BYTE *Puf )
{
	WORD	i, j = 0;
	BYTE	Tmp[20];
	for( i = 0; i < strlen( Puf ); i++ )
	{
		if( Puf[i] != ' ' && Puf[i] != '.' )
			Tmp[j++] = Puf[i];
	}
	Tmp[j++] = 0;
	return( atol( Tmp ));
}