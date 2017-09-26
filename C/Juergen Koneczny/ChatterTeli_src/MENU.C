#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<VDI.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include  <STDDEF.H>
#include  <STDLIB.H>
#include	<STRING.H>
#include	<CTYPE.H>
#include	<stdio.h>

#include	<atarierr.h>

#include	"main.h"
#include	RSCHEADER
#include	"Config.h"
#include	"Help.h"
#include	"Menu.h"
#ifdef	IRC_CLIENT
#include "Irc.h"
#endif
#ifdef	TELNET_CLIENT
#include	"Telnet.h"
#endif
#include	"Wdialog.h"
#include	"WDialog\About.h"
#include	"WDialog\CGeneral.h"
#include	"WDialog\CIc.h"
#include	"WDialog\CSession.h"
#ifdef	TELNET_CLIENT
#include	"WDialog\CTransfe.h"
#endif
#include	"WDialog\Hotlist.h"
#include	"WDialog\New.h"
#include	"Window.h"

#include	"AdaptRsc.h"
#include	"MapKey.h"

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	Global[15], AppId, AesFlags;
extern OBJECT	**TreeAddr;
extern OBJECT	*HtPopup;

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
MENU	HtMenu;


WORD	HandleMenu( EVNT *Events )
{
	WORD	Ret = 0;
	if( *(( OBJECT ** )(&Events->msg[5])) != NULL && *(( OBJECT ** )(&Events->msg[5])) != TreeAddr[MENUE] )
	{
		if( *(( OBJECT ** )(&Events->msg[5])) == HtPopup )
		{
#ifdef	IRC_CLIENT
			OpenIrc( CopyIrc( GetIrcHotlist( Events->msg[4] )), Global );
#endif
#ifdef	TELNET_CLIENT
			OpenTelnet( CopyTelnet( GetTelnetHotlist( Events->msg[4] )), Global );
#endif
			*(( OBJECT ** )(&Events->msg[5])) = TreeAddr[MENUE];
		}
	}
	else
	{
		switch( Events->msg[4] )
		{
			case	MENUE_ABOUT:
			OpenAboutDialog( Global );
				break;
			case	MENUE_NEW:
#ifdef	DEBUG
	DebugMsg( Global, "OpenNewDialog()\n" );
#endif
				OpenNewDialog( Global );
				break;			
			case	MENUE_OPEN:
			{
				WORD	a1, a2, a3, a4;
				if(( AesFlags & GAI_INFO ) && MT_appl_getinfo( 9, &a1, &a2, &a3, &a4, Global ) && a2 )
				{
					MENU	Popup;
					EVNTDATA Ev;
					Popup.mn_tree = HtPopup;
					Popup.mn_menu = 0;
					Popup.mn_item = 0;
					Popup.mn_scroll = 1;
					Popup.mn_keystate = 0;
					MT_graf_mkstate( &Ev, Global );
					if( HtPopup )
					{
						MT_menu_popup( &Popup, Ev.x, Ev.y, &Popup, Global );
						if( Popup.mn_item > 0 )
#ifdef	IRC_CLIENT
							OpenIrc( CopyIrc( GetIrcHotlist( Popup.mn_item )), Global );
#endif
#ifdef	TELNET_CLIENT
							OpenTelnet( CopyTelnet( GetTelnetHotlist( Popup.mn_item )), Global );
#endif
					}
					else
						OpenNewDialog( Global );
				}
				break;
			}			
			case	MENUE_QUIT:
				Ret = 1;
				break;
#ifdef	TELNET_CLIENT
			case	MENUE_SESSION:
			{
				WORD	w1, w2, w3, w4;
				EVNT	Evnt;
				MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, Global );
				Evnt.mwhich = MU_MESAG;
				Evnt.msg[0] = WIN_CMD;
				Evnt.msg[1] = Global[2];
				Evnt.msg[2] = 0;
				Evnt.msg[3] = w1;
				Evnt.msg[4] = WIN_KONTEXT_2;
				HandleWindow( &Evnt, Global );
				break;
			}
#endif
			case	MENUE_COPY:
			{
				WORD	w1, w2, w3, w4;
				EVNT	Evnt;
				MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, Global );
				Evnt.mwhich = MU_MESAG;
				Evnt.msg[0] = WIN_CMD;
				Evnt.msg[1] = Global[2];
				Evnt.msg[2] = 0;
				Evnt.msg[3] = w1;
				Evnt.msg[4] = WIN_COPY;
				HandleWindow( &Evnt, Global );
				break;
			}
			case	MENUE_CUT:
			{
				WORD	w1, w2, w3, w4;
				EVNT	Evnt;
				MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, Global );
				Evnt.mwhich = MU_MESAG;
				Evnt.msg[0] = WIN_CMD;
				Evnt.msg[1] = Global[2];
				Evnt.msg[2] = 0;
				Evnt.msg[3] = w1;
				Evnt.msg[4] = WIN_CUT;
				HandleWindow( &Evnt, Global );
				break;
			}
			case	MENUE_PASTE:
			{
				WORD	w1, w2, w3, w4;
				EVNT	Evnt;
				MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, Global );
				Evnt.mwhich = MU_MESAG;
				Evnt.msg[0] = WIN_CMD;
				Evnt.msg[1] = Global[2];
				Evnt.msg[2] = 0;
				Evnt.msg[3] = w1;
				Evnt.msg[4] = WIN_PASTE;
				HandleWindow( &Evnt, Global );
				break;
			}
			case	MENUE_MARK_ALL:
			{
				WORD	w1, w2, w3, w4;
				EVNT	Evnt;
				MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, Global );
				Evnt.mwhich = MU_MESAG;
				Evnt.msg[0] = WIN_CMD;
				Evnt.msg[1] = Global[2];
				Evnt.msg[2] = 0;
				Evnt.msg[3] = w1;
				Evnt.msg[4] = WIN_MARK_ALL;
				HandleWindow( &Evnt, Global );
				break;
			}

			case	MENUE_CLOSE_WIND:
			{
				WORD	w1, w2, w3, w4;
				EVNT	Evnt;
				MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, Global );
				Evnt.mwhich = MU_MESAG;
				Evnt.msg[0] = WM_CLOSED;
				Evnt.msg[1] = Global[2];
				Evnt.msg[2] = 0;
				Evnt.msg[3] = w1;
				Evnt.msg[4] = 0;
				Evnt.msg[5] = 0;
				Evnt.msg[6] = 0;
				Evnt.msg[7] = 0;
				HandleWindow( &Evnt, Global );
				break;
			}
			case	MENUE_CLOSE_ALL_WIND:
			{
				EVNT	Evnt;
				WORD	w = GetFirstWindow(), w_next;
				while( w != -1 )
				{
					w_next = GetNextWindow( w );
					if( isOpenWindow( w ))
					{
						Evnt.mwhich = MU_MESAG;
						Evnt.msg[0] = WM_CLOSED;
						Evnt.msg[1] = Global[2];
						Evnt.msg[2] = 0;
						Evnt.msg[3] = w;
						Evnt.msg[4] = 0;
						Evnt.msg[5] = 0;
						Evnt.msg[6] = 0;
						Evnt.msg[7] = 0;
						HandleWindow( &Evnt, Global );
					}
					w = w_next;
				}
/*				WORD	w1, w2, w3, w4;
				MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, Global );
				if( isWindow( w1 ))
				{
					EVNT	Evnt;
					do
					{
						w2 = w1;
						w1 = GetNextWindow( w1 );
						if( isOpenWindow( w2 ))
						{
							Evnt.mwhich = MU_MESAG;
							Evnt.msg[0] = WM_CLOSED;
							Evnt.msg[1] = Global[2];
							Evnt.msg[2] = 0;
							Evnt.msg[3] = w2;
							Evnt.msg[4] = 0;
							Evnt.msg[5] = 0;
							Evnt.msg[6] = 0;
							Evnt.msg[7] = 0;
							HandleWindow( &Evnt, Global );
						}
						if( w1 == -1 )
							w1 = GetFirstWindow();
					}
					while( w1 != -1 );
				}	*/
				break;
			}
			case	MENUE_CYC_WIND:
			{
				WORD	w1, w2, w3, w4;
				EVNT	Evnt;
				MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, Global );
				if( isWindow( w1 ))
				{
					do
					{
						if(( w1 = GetNextWindow( w1 )) == -1 )
							w1 = GetFirstWindow();
						if( isOpenWindow( w1 ))
							break;
					}
					while( 1 );
					Evnt.mwhich = MU_MESAG;
					Evnt.msg[0] = WM_TOPPED;
					Evnt.msg[1] = Global[2];
					Evnt.msg[2] = 0;
					Evnt.msg[3] = w1;
					Evnt.msg[4] = 0;
					Evnt.msg[5] = 0;
					Evnt.msg[6] = 0;
					Evnt.msg[7] = 0;
					HandleWindow( &Evnt, Global );
				}
				break;
			}
			case	MENUE_FULL_WIND:
			{
				WORD	w1, w2, w3, w4;
				EVNT	Evnt;
				MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, Global );
				Evnt.mwhich = MU_MESAG;
				Evnt.msg[0] = WM_FULLED;
				Evnt.msg[1] = Global[2];
				Evnt.msg[2] = 0;
				Evnt.msg[3] = w1;
				HandleWindow( &Evnt, Global );
				break;
			}
#ifdef	TELNET_CLIENT
			case	MENUE_KONTEXT:
			{
				WORD	w1, w2, w3, w4;
				EVNT	Evnt;
				MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, Global );
				Evnt.mwhich = MU_MESAG;
				Evnt.msg[0] = WIN_CMD;
				Evnt.msg[1] = Global[2];
				Evnt.msg[2] = 0;
				Evnt.msg[3] = w1;
				Evnt.msg[4] = WIN_KONTEXT_1;
				HandleWindow( &Evnt, Global );
				break;
			}
			case	MENUE_RX:
			{
				WORD	w1, w2, w3, w4;
				EVNT	Evnt;
				MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, Global );
				Evnt.mwhich = MU_MESAG;
				Evnt.msg[0] = WIN_CMD;
				Evnt.msg[1] = Global[2];
				Evnt.msg[2] = 0;
				Evnt.msg[3] = w1;
				Evnt.msg[4] = RX;
				HandleWindow( &Evnt, Global );
				break;
			}

			case	MENUE_TX:
			{
				WORD	w1, w2, w3, w4;
				EVNT	Evnt;
				MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, Global );
				Evnt.mwhich = MU_MESAG;
				Evnt.msg[0] = WIN_CMD;
				Evnt.msg[1] = Global[2];
				Evnt.msg[2] = 0;
				Evnt.msg[3] = w1;
				Evnt.msg[4] = TX;
				HandleWindow( &Evnt, Global );
				break;
			}
#endif
			case	MENUE_HOTLIST:
				OpenHotlistDialog( Global );
				break;			

			case	MENUE_CONFIG_GENERAL:
				OpenCGeneralDialog( Global );
				break;			

			case	MENUE_CONFIG_ICONNECT:
				OpenCIcDialog( Global );
				break;			

			case	MENUE_CONFIG_SESSION:
				OpenCSessionDialog( Global );
				break;

#ifdef	TELNET_CLIENT
			case	MENUE_CONFIG_TRANSFER:
				OpenCTransferDialog( Global );
				break;
#endif

			case	MENUE_CONFIG_SAVE:
				WriteConfig( Global );
				break;

			case	MENUE_HELP_ABOUT:
				StGuide( "*:\\ST-GUIDE.HYP", Global );
				break;
			case	MENUE_HELP_HELP:
			{
				WORD	w1, w2, w3, w4;
				EVNT	Evnt;
				MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, Global );
				if( isWindow( w1 ))
				{
					Evnt.mwhich = MU_MESAG;
					Evnt.msg[0] = WIN_CMD;
					Evnt.msg[1] = Global[2];
					Evnt.msg[2] = 0;
					Evnt.msg[3] = w1;
					Evnt.msg[4] = WIN_HELP;
					HandleWindow( &Evnt, Global );
				}
				else
					StGuide_Action( NULL, 0, Global );
				break;
			}
			case	MENUE_HELP_CONTENT:
			{
				StGuide_ActionDirect( TreeAddr[HELP], HELP, HELP_CONTENT, Global );
				break;
			}
			case	MENUE_HELP_INDEX:
			{
				StGuide_ActionDirect( TreeAddr[HELP], HELP, HELP_INDEX, Global );
				break;
			}
		}
	}
	MT_menu_tnormal( *( OBJECT ** ) &( Events->msg[5] ), Events->msg[3], 1, Global );
	return( Ret );
}

/*-----------------------------------------------------------------------------*/
/* Verarbeitet Tasten, die Menbefehle sind                                    */
/* Funktionsergebnis: -                                                        */
/*  Key:              Tastatur-Code gem. evnt_keybd                            */
/*-----------------------------------------------------------------------------*/
WORD	KeyEvent( WORD	Key )
{
	WORD	Title, Entry, Ret = 0;
	if( isMenuKey( Key, &Title, &Entry ))
	{
		if( !( TreeAddr[MENUE][Entry].ob_state & DISABLED || 
		       TreeAddr[MENUE][Title].ob_state & DISABLED ))
		{
			EVNT	Events;
			MT_menu_tnormal( TreeAddr[MENUE], Title, 0, Global );
			Events.msg[0] = MN_SELECTED;
			Events.msg[2] = 0;
			Events.msg[3] = Title;
			Events.msg[4] = Entry;
			*( OBJECT ** ) ( &( Events.msg[5] )) = TreeAddr[MENUE];
			Ret = HandleMenu( &Events );
		}
	}
	return( Ret );
}

/*-----------------------------------------------------------------------------*/
/* Prft, ob eine Taste einem Men-Eintrag zugeordnet ist                      */
/* Funktionsergebnis: 0: Kein Men-Eintrag zugeordnet                          */
/*  Key:              Tastatur-Code gem. evnt_keybd                            */
/*  *Title:           Zeiger auf den Index des Men-Eintrags                   */
/*  *Entry:           Zeiger auf den Index des Men-Titels                     */
/*-----------------------------------------------------------------------------*/
WORD	isMenuKey( WORD Key, WORD *Title, WORD *Entry )
{
	WORD	a, b, c, d = 0;
	BYTE	Str[6];

	Key = MapKey( Key );
	if( Key & KbCONTROL )
			{
				Str[0] = '^';
				Str[1] = toupper( Key & 0xff );
				Str[2] = 0;
			}
	else if( Key & KbALT )
			{
				Str[0] = '';
				Str[1] = toupper( Key & 0xff );
				Str[2] = 0;
			}
	else if( Key & KbSCAN )
			{
				Str[0] = 0;
        		if(( Key & 0xff ) >= KbF1 && ( Key & 0xff ) <= KbF9 )
        		{
	       		Str[0] = 'F';
					Str[1] = Key - KbF1 + '1';
					Str[2] = 0;
				}
				if(( Key & 0xff ) == KbF10 )
				{
					Str[0] = 'F';
					Str[1] = '1';
					Str[2] = '0';
					Str[3] = 0;
				}
				if(( Key & 0xff ) >= KbF11 && ( Key & 0xff ) <= KbF19 )
				{
					Str[0] = 'F';
					Str[1] = '1';
					Str[2] = Key - KbF11 + '1';
					Str[3] = 0;
				}
				if(( Key & 0xff ) == KbF20 )
				{
					Str[0] = 'F';
					Str[1] = '2';
					Str[2] = '0';
					Str[3] = 0;
				}
				if(( Key & 0xff ) == KbHELP )
				{
					if( Key & KbSHIFT )
					{
						Str[0] = '';
						Str[1] = 'H';
						Str[2] = 'E';
						Str[3] = 'L';
						Str[4] = 'P';
						Str[5] = 0;
					}
					else
					{
						Str[0] = 'H';
						Str[1] = 'E';
						Str[2] = 'L';
						Str[3] = 'P';
						Str[4] = 0;
					}
				}
        }
	else	return( 0 );

	a = TreeAddr[MENUE][0].ob_tail;

		b = TreeAddr[MENUE][a].ob_head;
		do
		{
			c = TreeAddr[MENUE][b].ob_head;
			if( c != -1 )
			{
				do
				{
					if( strstr( TreeAddr[MENUE][c].ob_spec.free_string, Str ))
					{
						WORD	i;
						*Entry = c;
						a = TreeAddr[MENUE][0].ob_head;
						b = TreeAddr[MENUE][a].ob_head;
						c = TreeAddr[MENUE][b].ob_head;
						for( i = 0; i < d; i++ )
							c = TreeAddr[MENUE][c].ob_next;
						*Title = c;
						return( 1 );
					}
				}
				while(( c = TreeAddr[MENUE][c].ob_next ) != b );
			}
			d++;
		}
		while(( b = TreeAddr[MENUE][b].ob_next ) != a );

	return( 0 );
}

void	KontextMenu( void )
{
	ULONG	Kontext = 0;
	WORD	w1, w2, w3, w4;
	MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, Global );
	if( isWindow( w1 ))
		Kontext = GetKontextWindow( w1, Global );

	if( Kontext & MENUE_KONTEXT_COPY )
		MT_menu_ienable( TreeAddr[MENUE], MENUE_COPY, 1, Global );
	else
		MT_menu_ienable( TreeAddr[MENUE], MENUE_COPY, 0, Global );
	if( Kontext & MENUE_KONTEXT_CUT )
		MT_menu_ienable( TreeAddr[MENUE], MENUE_CUT, 1, Global );
	else
		MT_menu_ienable( TreeAddr[MENUE], MENUE_CUT, 0, Global );
	if( Kontext & MENUE_KONTEXT_PASTE )
		MT_menu_ienable( TreeAddr[MENUE], MENUE_PASTE, 1, Global );
	else
		MT_menu_ienable( TreeAddr[MENUE], MENUE_PASTE, 0, Global );
	if( Kontext & MENUE_KONTEXT_MARK_ALL )
		MT_menu_ienable( TreeAddr[MENUE], MENUE_MARK_ALL, 1, Global );
	else
		MT_menu_ienable( TreeAddr[MENUE], MENUE_MARK_ALL, 0, Global );

	MT_menu_ienable( TreeAddr[MENUE], MENUE_CYC_WIND, 0, Global );
	if( Kontext & MENUE_KONTEXT_WINDOW_CYCLE )
	{
		WORD	WinId = GetFirstWindow(), Flag = 0;
		while( WinId != -1 )
		{
			if( isOpenWindow( WinId ))
			{
				if( Flag )
				{
					MT_menu_ienable( TreeAddr[MENUE],MENUE_CYC_WIND, 1, Global );
					break;
				}
				Flag = 1;
			}
			WinId = GetNextWindow( WinId );
		}
	}
#ifdef	TELNET_CLIENT
	if( Kontext & MENUE_KONTEXT_KONTEXT )
	{
		MT_menu_ienable( TreeAddr[MENUE], MENUE_SESSION, 1, Global );
		MT_menu_ienable( TreeAddr[MENUE], MENUE_KONTEXT, 1, Global );
		MT_menu_ienable( TreeAddr[MENUE], MENUE_TX, 1, Global );
		MT_menu_ienable( TreeAddr[MENUE], MENUE_RX, 1, Global );
	}
	else
	{
		MT_menu_ienable( TreeAddr[MENUE], MENUE_SESSION, 0, Global );
		MT_menu_ienable( TreeAddr[MENUE], MENUE_KONTEXT, 0, Global );
		MT_menu_ienable( TreeAddr[MENUE], MENUE_TX, 0, Global );
		MT_menu_ienable( TreeAddr[MENUE], MENUE_RX, 0, Global );
	}
#endif
	if( Kontext & MENUE_KONTEXT_WINDOW_CLOSE )
	{
		MT_menu_ienable( TreeAddr[MENUE], MENUE_CLOSE_WIND, 1, Global );
		MT_menu_ienable( TreeAddr[MENUE], MENUE_CLOSE_ALL_WIND, 1, Global );
	}
	else
	{
		MT_menu_ienable( TreeAddr[MENUE], MENUE_CLOSE_WIND, 0, Global );
		MT_menu_ienable( TreeAddr[MENUE], MENUE_CLOSE_ALL_WIND, 0, Global );
	}
	if( Kontext & MENUE_KONTEXT_WINDOW_FULL )
		MT_menu_ienable( TreeAddr[MENUE], MENUE_FULL_WIND, 1, Global );
	else
		MT_menu_ienable( TreeAddr[MENUE], MENUE_FULL_WIND, 0, Global );

}

void	InstallHtPopup( void )
{
	if( HtPopup )
	{
		WORD	a1, a2, a3, a4;
		MT_menu_ienable( TreeAddr[MENUE], MENUE_OPEN, 1, Global );
		if(( AesFlags & GAI_INFO ) && MT_appl_getinfo( 9, &a1, &a2, &a3, &a4, Global ) && a1 );
		{
			HtMenu.mn_menu = 0;
			HtMenu.mn_item = 0;
			HtMenu.mn_scroll = 1;
			HtMenu.mn_keystate = 0;
			HtMenu.mn_tree = HtPopup;
			MT_menu_attach( 1, TreeAddr[MENUE], MENUE_OPEN, &HtMenu, Global );
		}
	}
	else
		MT_menu_ienable( TreeAddr[MENUE], MENUE_OPEN, 0, Global );
}