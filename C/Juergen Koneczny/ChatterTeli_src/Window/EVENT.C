#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDLIB.H>
#include  <STDDEF.H>
#include  <STRING.H>
#include	<stdio.h>

#include	<atarierr.h>

#include	"main.h"
#include	RSCHEADER
#include	"Help.h"
#include	"Window.h"
#include	"Window\Event.h"
#include	"Window\Iconify.h"
#include	"Window\Item.h"

#include	"MapKey.h"

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD		ModWinId;
extern DIALOG	*IconifyDialog;
extern OBJECT	**TreeAddr;

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
static DIALOG	*IconifyDialog = NULL;

WORD	HandleWindow( EVNT *Events, WORD Global[15] )
{
	WORD	Ret;
	EVNT	lEvents;
	memcpy( &lEvents, Events, sizeof( EVNT ));
	
	if( Events->mwhich & MU_KEYBD )
	{
		WORD	w1, w2, w3, w4;
		MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, Global );
		if( GetWindow( w1 ))
		{
			if( !isShadedWindow( w1 ) && !isIconifiedWindow( w1 ))
			{
				HNDL_WINDOW	HndlWin = GetHandleWindow( w1 );
				if( HndlWin )
				{
					lEvents.mwhich = MU_KEYBD;
					Ret = HndlWin( w1, &lEvents, GetWindowData( w1 ), Global );
					if( !( lEvents.mwhich & MU_KEYBD ))
						Events->mwhich &= ~MU_KEYBD;
				}
			}
		}
	}
	if( Events->mwhich & MU_BUTTON )
	{
		WORD	w;
		w = MT_wind_find( Events->mx, Events->my, Global );
		if( w != -1 && GetWindow( w ))
		{
			GRECT	Work;
			MT_wind_get_grect( w, WF_WORKXYWH, &Work, Global );
			if( Events->mx >= Work.g_x && Events->mx <= Work.g_x + Work.g_w &&
			    Events->my >= Work.g_y && Events->my <= Work.g_y + Work.g_h )
			{
				HNDL_WINDOW HndlWin = GetHandleWindow( w );
				if( HndlWin )
				{
					if( ModWinId && w != ModWinId )
						Events->mwhich &= ~MU_BUTTON;
					else
					{
						lEvents.mwhich = MU_BUTTON;
						Ret = HndlWin( w, &lEvents, GetWindowData( w ), Global );
						if( Ret == E_OK )
							Events->mwhich &= ~MU_BUTTON;
					}
				}
			}
		}
	}
	if( Events->mwhich & MU_MESAG )
	{
		if( Events->msg[0] == WM_SHADED )
			ShadedWindow( Events->msg[3] );
		if( Events->msg[0] == WM_UNSHADED )
			UnShadedWindow( Events->msg[3] );

		if( ModWinId )
		{
			WORD	TopWinId, TopAppId, Dummy;
			MT_wind_get( 0, WF_TOP, &TopWinId, &TopAppId, &Dummy, &Dummy, Global );
			if( TopWinId != ModWinId && TopAppId == Global[2] )
				MT_wind_set_int( ModWinId, WF_TOP, 0, Global );
			switch( Events->msg[0] )
			{
				case	WM_CLOSED:
					if( Events->msg[4] != WIN_CLOSE_WITHOUT_DEMAND )
					{
						if( ModWinId != Events->msg[3] )
						{
							Events->mwhich &= ~MU_MESAG;
/*							return( E_OK );*/
						}
					}
					break;
				case	WM_ONTOP:
				case	WM_TOPPED:
					if( ModWinId != Events->msg[3] )
					{
						MT_wind_set_int( ModWinId, WF_TOP, 0, Global );
						Events->mwhich &= ~MU_MESAG;
					}
					break;
			}
		}

		if( IconifyDialog )
		{
			if( MT_wdlg_evnt( IconifyDialog, Events, Global ) == 0 )
			{
				WORD		i, j;
				GRECT		Rect;
				UnAllIconifyWindow( MT_wdlg_get_handle( IconifyDialog, Global ), &Rect );
				MT_wdlg_set_uniconify( IconifyDialog, &Rect, NULL, NULL, Global );
				MT_wdlg_close( IconifyDialog, &i, &j, Global );
				DelWindow( MT_wdlg_get_handle( IconifyDialog, Global ));
				MT_wdlg_delete( IconifyDialog, Global );				
				IconifyDialog = NULL;
				{
					WORD	WinId = GetFirstWindow();
					while( WinId != -1 )
					{
						GRECT	CurrRect;
						UnAllIconifyWindow( WinId, &CurrRect );
						OpenWindow( WinId );
						MT_wind_open( WinId, &CurrRect, Global );
						WinId = GetNextWindow( WinId );
					}
				}
			}
		}
		if( Events->msg[0] == WM_ALLICONIFY )
		{
			WORD	WinId = GetFirstWindow();
			while( WinId != -1 )
			{
				if( !( IconifyDialog && MT_wdlg_get_handle( IconifyDialog, Global ) == WinId ))
				{
					if( !isAllIconifiedWindow( WinId ))
					{
						GRECT	CurrRect;
						MT_wind_get_grect( WinId, WF_CURRXYWH, &CurrRect, Global );
						MT_wind_close( WinId, Global );
						AllIconifyWindow( WinId, &CurrRect );
						CloseWindow( WinId );
					}
				}
				WinId = GetNextWindow( WinId );
			}
				if( !IconifyDialog )
			{
				GRECT	CurrRect;
				IconifyDialog = MT_wdlg_create( HandleIconifyDialog, TreeAddr[ICONIFY], NULL, 0, NULL, 0, Global );
				MT_wdlg_open( IconifyDialog, TreeAddr[TITLES][TITLE_WINDOW].ob_spec.free_string, NAME + MOVER + CLOSER + ICONIFIER, 10000, 10000, 0, NULL, Global );
				NewWindow( MT_wdlg_get_handle( IconifyDialog, Global ), -1, ( HNDL_WINDOW ) NULL, MenuKontextIconify, IconifyDialog );
				MT_wind_get_grect( MT_wdlg_get_handle( IconifyDialog, Global ), WF_CURRXYWH, &CurrRect, Global );
				AllIconifyWindow( MT_wdlg_get_handle( IconifyDialog, Global ), &CurrRect );
			}
			MT_wdlg_set_iconify( IconifyDialog, ( GRECT *) &( Events->msg[4] ), NULL, TreeAddr[ICONIFY], ICONIFY_ICON, Global );
			IconifyWindow( MT_wdlg_get_handle( IconifyDialog, Global ));
			Events->mwhich &= ~MU_MESAG;
		}
		else	if(( Events->msg[0] >= 20 && Events->msg[0] <= 36 ) || Events->msg[0] == THR_EXIT ||
	  		 	     ( UWORD ) Events->msg[0] == FONT_CHANGED || ( UWORD ) Events->msg[0] == COLOR_ID || Events->msg[0] == AP_DRAGDROP || Events->msg[0] == BUBBLEGEM_REQUEST ||
		  	         Events->msg[0] == WIN_CMD || Events->msg[0] == WIN_ACK ||
     			   ( Events->msg[0] >= WIN_USER_LOW && Events->msg[0] <= WIN_USER_HIGH ))
		{
			if( Events->msg[0] == COLOR_ID )
			{
				WORD	w = MT_wind_find( Events->msg[3], Events->msg[4], Global );
				HNDL_WINDOW HndlWin = GetHandleWindow( w );
				if( HndlWin )
				{
					lEvents.mwhich = MU_MESAG;
					Ret = HndlWin( w, &lEvents, GetWindowData( w ), Global );
					if( Ret == E_OK )
						Events->mwhich &= ~MU_MESAG;
				}
			}
			else if( GetWindow( Events->msg[3] ))
			{
				HNDL_WINDOW	HndlWin = GetHandleWindow( Events->msg[3] );
				if( HndlWin )
				{
					lEvents.mwhich = MU_MESAG;
					Ret = HndlWin( Events->msg[3], &lEvents, GetWindowData( Events->msg[3] ), Global );
					if( Ret == E_OK )
						Events->mwhich &= ~MU_MESAG;
				}
			}
		}
	}
	if( Events->mwhich & MU_TIMER )
	{
		WORD	WinId = GetFirstWindow();
		while( WinId != -1 )
		{
			HNDL_WINDOW HndlWin = GetHandleWindow( WinId );
			if( HndlWin )
			{
				lEvents.mwhich = MU_TIMER;
				HndlWin( WinId, &lEvents, GetWindowData( WinId ), Global );
			}
			WinId = GetNextWindow( WinId );
		}
	}

	return( E_OK );
}
