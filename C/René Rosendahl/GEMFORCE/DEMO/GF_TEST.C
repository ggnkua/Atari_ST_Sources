/*   GEM-Force-Testprogramm by Ren‚ Rosendahl, (C) 1993   */

# include "GFIMPORT.H"
# include "GFGLOBAL.H"
# include "GFWINDWS.H"
# include <aes.h>
# include <stdio.h>
# include <string.h>
# include "gf_test.h"

void  exit ( int );

# include "GFEXPORT.H"

/*-----------------------------------------------------------------*/

# define TW_MAX_W 60
# define TW_MAX_H 20

/*--------------------- globals -----------------------------------*/

GLOBAL OBJECT *userimg, *menu, *infoform, *demoform, *sysinfo;
GLOBAL OBJECT *popup, *winobj;
GLOBAL BOOLEAN topmes = FALSE, prg_ende = FALSE;
GLOBAL WINDOWP txtwin1, txtwin2, objwin;

/*---------------------- locals -----------------------------------*/

LOCAL	char lines[TW_MAX_H][TW_MAX_W];

/*---------------------- prototypes -------------------------------*/

LOCAL void fill_sysinfo ( void );
LOCAL void hndl_menu ( int );
LOCAL void top_alert ( WINDOWP );
LOCAL void untop_alert ( WINDOWP );
LOCAL void flip_menu ( int, BOOLEAN * );

/*-----------------------------------------------------------------*/

void main ( void )
{
	int msg[8], mk_state, mk_return, ev_ret, dummy, title, item, s;
	KEYINFO ki;
	RECT r;
	char buf [TW_MAX_W + 1];
	
	init_gem ();
	
	if ( ! init_windows ( "[3][Keine Fenster mehr !][Abbruch]", 10 ) )
	{
		form_alert ( 1, "[3][Modul WINDOWS lies sich|nicht korrekt ini-|tialisieren...][Shit !]" );
		exit_gem ();
		exit ( 1 );
	}
		
	if ( ! rsc_load ( "[3][Fehler beim Laden der |RSC-Datei !][Abbruch]",
							"GF_TEST.RSC" ) )
	{
		exit_gem ();
		exit ( 1 );
	}
	
	init_tree ( USERIMG,  &userimg,  FALSE );
	init_tree ( MENU,     &menu,     FALSE );
	init_tree ( SYSINFO,  &sysinfo,  TRUE );
	init_tree ( DEMOFORM, &demoform, TRUE );
	init_tree ( INFOFORM, &infoform, TRUE );
	init_tree ( WINOBJ,   &winobj,   FALSE );
	init_tree ( POPUP,    &popup,    FALSE );

	fill_sysinfo ();

	menu_bar ( menu, TRUE );

	xywh2rect ( 55, 83, 302, 197, &r );
	txtwin1 = create_textwindow ( ( char *) lines, TW_MAX_W - 1, 
				 TW_MAX_H, ALL, &r );
	if ( txtwin1 != NULL )
	{
		strcpy ( txtwin1->name, " Textfenster 1 " );
		strcpy ( txtwin1->info, " dies ist die Info-Zeile in Textfenster 1" );
		txtwin1->top = top_alert;
		txtwin1->untop = untop_alert;
	}

	xywh2rect ( 221, 159, 313, 147, &r );
	txtwin2 = create_textwindow ( ( char *) lines, TW_MAX_W - 1, 
				 TW_MAX_H, ALL, &r );
	if ( txtwin2 != NULL )
	{
		strcpy ( txtwin2->name, " Textfenster 2 " );
		strcpy ( txtwin2->info, " dies ist die Info-Zeile in Textfenster 2" );
		txtwin2->top = top_alert;
		txtwin2->untop = untop_alert;
	}

	for ( s = 0; s < TW_MAX_H; s++ )
	{
		sprintf ( buf, "Dies ist die Text-Zeile mit der Nummer %d.", s + 1);
		strcpy ( lines[s], buf );
	}
	
	objwin = create_window ( NAME|CLOSER|MOVER, 0 );
	if ( objwin != NULL )
	{
		objwin->flags |= WI_RESIDENT;
		objwin->object = winobj;
		objwin->work.x = 280;
		objwin->work.y = 100;
		objwin->work.w = winobj->ob_width;
		objwin->work.h = winobj->ob_height;
		objwin->scroll = objwin->work;
		objwin->doc.w  = winobj->ob_width;
		objwin->doc.h  = winobj->ob_height;
		objwin->xfac   =	objwin->yfac = 1;
		strcpy ( objwin->name, " Objektfenster " );
		objwin->top = top_alert;
		objwin->untop = untop_alert;
	}		

	open_window ( txtwin1 );
	open_window ( txtwin2 );
	open_window ( objwin );
	
	do
	{
		ev_ret = evnt_multi ( MU_KEYBD | MU_MESAG, 0,0,0,0,0,0,0,0,0,0,0,0,0,
						 msg, 0,0,&dummy,&dummy,&dummy, &mk_state, &mk_return,
						 &dummy );
						 
		if ( ev_ret & MU_KEYBD )
		{
			get_keyinfo ( mk_state, mk_return, &ki );
			if ( find_menu_item ( menu, &ki, &title, &item ) )
				hndl_menu ( item );
		}
		
		if ( ( ev_ret & MU_MESAG ) && ( msg[0] == MN_SELECTED ) )
		{
			hndl_menu ( msg[4] );
			menu_tnormal ( menu, msg[3], TRUE );
		}
		
		handle_window_events ( msg );
		
	} while ( !prg_ende );
	
	menu_bar ( menu, FALSE );
	
	exit_windows ();
	exit_gem ();
}

/*-----------------------------------------------------------------*/

void fill_sysinfo ( void )
{
	sprintf ( TE_PTEXT ( sysinfo, TOS ), "%d", tos );
	sprintf ( TE_PTEXT ( sysinfo, PHYS ), "%d", phys_handle );
	sprintf ( TE_PTEXT ( sysinfo, VDI ), "%d", vdi_handle );
	sprintf ( TE_PTEXT ( sysinfo, APPLID ), "%d", appl_id );
	sprintf ( TE_PTEXT ( sysinfo, GDOS ), "%ld", gdos );
	sprintf ( TE_PTEXT ( sysinfo, COLORS ), "%d", colors );
	sprintf ( TE_PTEXT ( sysinfo, WBOX ), "%d", gl_wbox );
	sprintf ( TE_PTEXT ( sysinfo, HBOX ), "%d", gl_hbox );
	sprintf ( TE_PTEXT ( sysinfo, WCHAR ), "%d", gl_wchar );
	sprintf ( TE_PTEXT ( sysinfo, HCHAR ), "%d", gl_hchar );
	sprintf ( TE_PTEXT ( sysinfo, WATTR ), "%d", gl_wattr );
	sprintf ( TE_PTEXT ( sysinfo, HATTR ), "%d", gl_hattr );
	sprintf ( TE_PTEXT ( sysinfo, DESKX ), "%d", desk.x );
	sprintf ( TE_PTEXT ( sysinfo, DESKY ), "%d", desk.y );
	sprintf ( TE_PTEXT ( sysinfo, DESKW ), "%d", desk.w );
	sprintf ( TE_PTEXT ( sysinfo, DESKH ), "%d", desk.h );
}

/*-----------------------------------------------------------------*/

LOCAL void hndl_menu ( int item )
{
	int ex_obj;
	static int sel_popup = HEADING;
	
	switch ( item )
	{
		case ENDE:
			prg_ende = TRUE;
			break;
		case INFOPRG:
			do_dialog ( infoform, 0 );
			break;
		case SYSTEM:
			do_dialog ( sysinfo, 0 );
			break;
		case FORMDO:
			do_dialog ( demoform, 0 );
			break;
		case FORMDIAL:
			dialog_on ( demoform );
			do
			{
				ex_obj = form_dialog ( demoform, 0 );
				if ( ex_obj == TOUCHBUT ) 
				{
					objc_draw ( demoform, TOUCHBUT, 1, 0, 0, 0, 0 );
					bell ();
				}
			} while ( ex_obj == TOUCHBUT );
			dialog_off ( demoform );
			break;
		case GROW:
			flip_menu ( GROW, &grow_shrink );
			break;
		case SAVE:
			flip_menu ( SAVE, &save_bg );
			break;
		case TOPMES:
			flip_menu ( TOPMES, &topmes );
			break;
		case TEXT1:
			open_window ( txtwin1 );
			break;
		case TEXT2:
			open_window ( txtwin2 );
			break;
		case OBJEKT:
			open_window ( objwin );
			break;
		case SHOPOPUP:
			sel_popup = popup_menu ( popup, POPUPMEN, 0, 0, sel_popup, TRUE, 1 );
			break;
		case LOCK:
			lock_all ( objwin );
			break;
		case UNLOCK:
			unlock_all ();
			break;
	}
}

/*-----------------------------------------------------------------*/

LOCAL void top_alert ( WINDOWP wp )
{	
	char buf[128];
	
	if ( topmes )
	{
		sprintf ( buf, "[1][Das%s|wurde getoppt !][ OK ]", wp->name );
		form_alert ( 1, buf );
	}
}

/*-----------------------------------------------------------------*/

LOCAL void untop_alert ( WINDOWP wp )
{	
	char buf[128];
	
	if ( topmes )
	{
		sprintf ( buf, "[1][Das%s|wurde ge-un-toppt !][ OK ]", wp->name );
		form_alert ( 1, buf );
	}
}

/*-----------------------------------------------------------------*/

LOCAL void flip_menu ( int item, BOOLEAN *var )
{
	flip_state ( menu, item, CHECKED );
	*var = ( *var == FALSE );
}