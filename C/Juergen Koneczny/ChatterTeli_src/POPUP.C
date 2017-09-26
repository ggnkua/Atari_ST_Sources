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
#include	"Popup.h"
#include	"Wdialog.h"
#include	"WDialog\About.h"
#include	"WDialog\CView.h"
#include	"WDialog\CInt.h"
#include	"WDialog\New.h"
#include	"Window.h"

#include	"AdaptRsc.h"
#include	"MapKey.h"

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static WORD	cdecl ColorPopupUbCode( PARMBLK *ParmBlock );

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	Global[15], AppId, VdiHandle, AesFlags;
extern OBJECT	**TreeAddr;
extern GRECT	ScreenRect;

WORD	Popup( OBJECT *PopupTree, WORD Selected, WORD x, WORD y, WORD Global[15] )
{
	WORD	OldSelected = Selected, Max = 0, i;
	GRECT	Rect;
	MOBLK	M1;
	EVNT	Events;
	EVNTDATA	Ev;
	void	*FlyInf;

	do
	{
		MT_graf_mkstate( &Ev, Global );
	}
	while( Ev.bstate );

	while( PopupTree[Max++].ob_next != 0 )
		PopupTree[Max].ob_state &= ~( SELECTED + CHECKED );
	if( Selected > 0 )
		PopupTree[Selected].ob_state |= CHECKED;
	Selected = -1;

	if( x < ScreenRect.g_x )
		x = ScreenRect.g_x;
	if( y < ScreenRect.g_y )
		y = ScreenRect.g_y;
	if( x + PopupTree[ROOT].ob_width > ScreenRect.g_w ) 
		x = ScreenRect.g_w - PopupTree[ROOT].ob_width;
	if( y + PopupTree[ROOT].ob_height > ScreenRect.g_h ) 
		y = ScreenRect.g_h - PopupTree[ROOT].ob_height;
	Rect.g_x = x - 3;
	Rect.g_y = y - 3;
	Rect.g_w = PopupTree[ROOT].ob_width + 6;
	Rect.g_h = PopupTree[ROOT].ob_height + 6;
	PopupTree[ROOT].ob_x = x;
	PopupTree[ROOT].ob_y = y;
	M1.m_out = 1;
	M1.m_x = 0;
	M1.m_y = 0;
	M1.m_w = 1;
	M1.m_h = 1;

	MT_form_xdial( FMD_START, &Rect, &Rect, &FlyInf, Global );
	MT_wind_update( BEG_UPDATE, Global );
	MT_wind_update( BEG_MCTRL, Global );

	MT_graf_mkstate( &Ev, Global );
	if(( i = MT_objc_find( PopupTree, ROOT, MAX_DEPTH, Ev.x, Ev.y, Global )) != -1 )
		if( !( PopupTree[i].ob_state & DISABLED ))
		{
			PopupTree[i].ob_state |= SELECTED;
			Selected = i;
		}

	MT_objc_draw( PopupTree, ROOT, MAX_DEPTH, &Rect, Global );


	while( 1 )
	{
		MT_EVNT_multi( MU_KEYBD + MU_BUTTON + MU_M1, 0x101, 1, Ev.bstate ? 1: 0, &M1, NULL, 0, &Events, Global );
		OldSelected = Selected;
		if( Events.mwhich & MU_KEYBD )
		{
			WORD	Code = MapKey( Events.key );
			WORD	Key = Code & 0xff;

			if( Code & KbSCAN )
			{
				if( Key == KbUP )
				{
					WORD	i = Selected > 0 ? Selected : Max;
					while(( PopupTree[--i].ob_state & DISABLED ) && i >= 0 );
					Selected = i > 0 ? i : Selected;
				}
				else	if( Key == KbDOWN )
				{
					WORD	i = Selected > 0 ? Selected : 0;
					while(( PopupTree[++i].ob_state & DISABLED ) && i <= Max );
					Selected = i < Max ? i : Selected;
				}
				else	if( Key == KbHOME )
				{
					if( Code & KbSHIFT )
					{
						WORD	i = Max;
						while(( PopupTree[--i].ob_state & DISABLED ) && i >= 0 );
						Selected = i > 0 ? i : Selected;
					}
					else
					{
						WORD	i = 0;
						while(( PopupTree[++i].ob_state & DISABLED ) && i <= Max );
						Selected = i < Max ? i : Selected;
					}
				}
				else	if( Key == 0x4f )
				{
					WORD	i = Max;
					while(( PopupTree[--i].ob_state & DISABLED ) && i >= 0 );
					Selected = i > 0 ? i : Selected;
				}
				else	if( Key == KbUNDO )
				{
					Selected = -1;
					break;
				}
			}
			else	if( Key == 27 )
			{
				Selected = -1;
				break;
			}
			else	if( Key == 13 )
				break;
			else
			{
				BYTE	Str[4];
				WORD	i, Flag = 0;
				if( Code & KbCONTROL )
				{
					Str[0] = '^';
					Str[1] = toupper( Code & 0xff );
					Str[2] = 0;
				}
				else	if( Code & KbALT )
				{
					Str[0] = '';
					Str[1] = toupper( Code & 0xff );
					Str[2] = 0;
				}
				for( i = 1; i < Max; i++ )
					if( strstr( PopupTree[i].ob_spec.free_string, Str ))
					{
						if( !( PopupTree[i].ob_state & DISABLED ))
						{
							Selected = i;
							Flag = 1;
						}
						break;
					}
				if( Flag )
					break;
			}
		}
		else
		{	
			Selected = MT_objc_find( PopupTree, ROOT, MAX_DEPTH, Events.mx, Events.my, Global );
			if( Events.mwhich & MU_BUTTON )
			{
					break;
			}
/*			if( Selected == -1 )
				Selected = OldSelected;
			else*/	if( PopupTree[Selected].ob_state & DISABLED )
				Selected = -1;
			M1.m_x = Events.mx;
			M1.m_y = Events.my;
		}
		if( OldSelected != Selected )
		{
			if( OldSelected != -1 )
			{
				GRECT	Rect;
				MT_objc_offset( PopupTree, OldSelected, &Rect.g_x, &Rect.g_y, Global );
				Rect.g_w = PopupTree[OldSelected].ob_width;
				Rect.g_h = PopupTree[OldSelected].ob_height;
				PopupTree[OldSelected].ob_state &= ~SELECTED;
				MT_objc_draw( PopupTree, ROOT, MAX_DEPTH, &Rect, Global );
			}
			if( Selected != -1 )
			{
				GRECT	Rect;
				MT_objc_offset( PopupTree, Selected, &Rect.g_x, &Rect.g_y, Global );
				Rect.g_w = PopupTree[Selected].ob_width;
				Rect.g_h = PopupTree[Selected].ob_height;
				PopupTree[Selected].ob_state |= SELECTED;
				MT_objc_draw( PopupTree, ROOT, MAX_DEPTH, &Rect, Global );
			}
		}
	}

	MT_wind_update( END_MCTRL, Global );
	MT_wind_update( END_UPDATE, Global );
	MT_form_xdial( FMD_FINISH, &Rect, &Rect, &FlyInf, Global );

	if( Selected != -1 )
		PopupTree[Selected].ob_state &= ~SELECTED;
	return( Selected );

}

WORD	ColorPopup( WORD Color, WORD CenterFlag, WORD x, WORD y, WORD Global[15] )
{
	GRECT	Rect;
	MOBLK	M1;
	EVNT	Events;
	EVNTDATA	Ev;
	void	*FlyInf;
	WORD	Selected = Color + 1, OldSelected, i;

	static USERBLK	*UserBlk = NULL;

	if( !UserBlk )
	{
		UserBlk = malloc( sizeof( USERBLK ));
		UserBlk->ub_code = ColorPopupUbCode;
	}
	for( i = 1; i <= 256; i++ )
	{
		TreeAddr[POPUP_COLOR][i].ob_type = G_USERDEF;
		TreeAddr[POPUP_COLOR][i].ob_spec.userblk = UserBlk;
		TreeAddr[POPUP_COLOR][i].ob_state &= ~( SELECTED + CROSSED );
	}
	while( Selected > 256 )
		Selected -= 256;
	TreeAddr[POPUP_COLOR][Selected].ob_state |= CROSSED + SELECTED;

	if( CenterFlag )
	{
		x -= TreeAddr[POPUP_COLOR][Selected].ob_x + TreeAddr[POPUP_COLOR][Selected].ob_width / 2;
		y -= TreeAddr[POPUP_COLOR][Selected].ob_y + TreeAddr[POPUP_COLOR][Selected].ob_height / 2;
	}
	if( x < ScreenRect.g_x )
		x = ScreenRect.g_x;
	if( y < ScreenRect.g_y )
		y = ScreenRect.g_y;
	if( x + TreeAddr[POPUP_COLOR][ROOT].ob_width > ScreenRect.g_w ) 
		x = ScreenRect.g_w - TreeAddr[POPUP_COLOR][ROOT].ob_width;
	if( y + TreeAddr[POPUP_COLOR][ROOT].ob_height > ScreenRect.g_h ) 
		y = ScreenRect.g_h - TreeAddr[POPUP_COLOR][ROOT].ob_height;
	Rect.g_x = x - 4;
	Rect.g_y = y - 4;
	Rect.g_w = TreeAddr[POPUP_COLOR][ROOT].ob_width + 8;
	Rect.g_h = TreeAddr[POPUP_COLOR][ROOT].ob_height + 8;
	TreeAddr[POPUP_COLOR][ROOT].ob_x = x;
	TreeAddr[POPUP_COLOR][ROOT].ob_y = y;

	MT_form_xdial( FMD_START, &Rect, &Rect, &FlyInf, Global );
	MT_wind_update( BEG_UPDATE, Global );
	MT_wind_update( BEG_MCTRL, Global );

	MT_graf_mkstate( &Ev, Global );
	MT_objc_draw( TreeAddr[POPUP_COLOR], ROOT, MAX_DEPTH, &Rect, Global );

	M1.m_out = 1;
	M1.m_x = 0;
	M1.m_y = 0;
	M1.m_w = 1;
	M1.m_h = 1;

	while( 1 )
	{
		MT_EVNT_multi( MU_KEYBD + MU_BUTTON + MU_M1, 0x101, 1, Ev.bstate ? 1: 0, &M1, NULL, 0, &Events, Global );

		OldSelected = Selected;
		if( Events.mwhich & MU_KEYBD )
		{
			WORD	Code = MapKey( Events.key );
			WORD	Key = Code & 0xff;

			if( Code & KbSCAN )
			{
				if( Key == KbLEFT )
					Selected--;
				else	if( Key == KbRIGHT )
					Selected++;
				else	if( Key == KbUP )
					Selected -= 16;
				else	if( Key == KbDOWN )
					Selected += 16;
				else	if( Key == KbHOME )
				{
					if( Code & KbSHIFT )
						Selected = 256;
					else
						Selected = 1;
				}
				else	if( Key == KbUNDO )
				{
					Selected = -1;
					break;
				}

				if( Selected > 256 )
					Selected = 256;
				if( Selected < 1 )
					Selected = 1;
			}
			else	if( Key == 27 )
			{
				Selected = -1;
				break;
			}
			else	if( Key == 13 )
				break;
			
		}
		else
		{	
			Selected = MT_objc_find( TreeAddr[POPUP_COLOR], ROOT, MAX_DEPTH, Events.mx, Events.my, Global );
			if( Events.mwhich & MU_BUTTON )
				break;
			if( Selected == -1 )
				Selected = OldSelected;
			M1.m_x = Events.mx;
			M1.m_y = Events.my;
		}

		if( OldSelected != Selected )
		{
			if( OldSelected != -1 )
			{
				TreeAddr[POPUP_COLOR][OldSelected].ob_state &= ~SELECTED;
				MT_objc_draw( TreeAddr[POPUP_COLOR], OldSelected, MAX_DEPTH, &Rect, Global );
			}
			if( Selected != -1 )
			{
				TreeAddr[POPUP_COLOR][Selected].ob_state |= SELECTED;
				MT_objc_draw( TreeAddr[POPUP_COLOR], Selected, MAX_DEPTH, &Rect, Global );
			}
		}
	}

	MT_wind_update( END_MCTRL, Global );
	MT_wind_update( END_UPDATE, Global );
	MT_form_xdial( FMD_FINISH, &Rect, &Rect, &FlyInf, Global );
	if( Selected != -1 )
		return( Selected - 1 );
	else
		return( Color );
}
static WORD	cdecl ColorPopupUbCode( PARMBLK *ParmBlock )
{
	WORD	Cxy[4], Pxy[4];

	Cxy[0] = ParmBlock->pb_xc;
	Cxy[1] = ParmBlock->pb_yc;
	Cxy[2] = Cxy[0] + ParmBlock->pb_wc - 1;
	Cxy[3] = Cxy[1] + ParmBlock->pb_hc - 1;

	vs_clip( VdiHandle, 1, Cxy );
	vswr_mode( VdiHandle, MD_REPLACE );
	vsf_perimeter( VdiHandle, 0 );
	vsf_interior( VdiHandle, FIS_SOLID );

	Pxy[0] = ParmBlock->pb_x + 1;
	Pxy[1] = ParmBlock->pb_y + 1;
	Pxy[2] = Pxy[0] + ParmBlock->pb_w - 3;
	Pxy[3] = Pxy[1] + ParmBlock->pb_h - 3;
	vsf_color( VdiHandle, ( !( AesFlags & GAI_3D ) && !( ParmBlock->pb_currstate & SELECTED )) ? WHITE : BLACK );
	v_bar( VdiHandle, Pxy );
	vsf_interior( VdiHandle, FIS_SOLID );

	if( ParmBlock->pb_currstate & CROSSED )
	{
		vsf_interior( VdiHandle, FIS_PATTERN );
		vsf_style( VdiHandle, 4 );
		vsf_color( VdiHandle, BLACK );
		v_bar( VdiHandle, Pxy );
		vsf_interior( VdiHandle, FIS_SOLID );
	}

	Pxy[0] += 1;
	Pxy[1] += 1;
	Pxy[2] -= 1;
	Pxy[3] -= 1;
	if( ParmBlock->pb_currstate & SELECTED )
		vsf_color( VdiHandle, ( AesFlags & GAI_3D ) ? LBLACK : BLACK );
	else
		vsf_color( VdiHandle, ( AesFlags & GAI_3D ) ? LWHITE : WHITE );
	v_bar( VdiHandle, Pxy );

	Pxy[0] += 1;
	Pxy[1] += 1;
	if( ParmBlock->pb_currstate & SELECTED )
		vsf_color( VdiHandle, ( AesFlags & GAI_3D ) ? LWHITE : BLACK );
	else
		vsf_color( VdiHandle, ( AesFlags & GAI_3D ) ? LBLACK : WHITE );
	v_bar( VdiHandle, Pxy );

	Pxy[2] -= 1;
	Pxy[3] -= 1;

	vsf_color( VdiHandle, ParmBlock->pb_obj - 1 );
	v_bar( VdiHandle, Pxy );


	vs_clip( VdiHandle, 0, Cxy );
	return( 0 );
}

