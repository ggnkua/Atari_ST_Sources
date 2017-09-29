/*----------------------------------------------------------------------------------------*
 * MControl                                                                               *
 *----------------------------------------------------------------------------------------*
 * Copyright (c) 2000 - 2002 Joachim Fornallaz                                            *
 *----------------------------------------------------------------------------------------*
 * This source file is subject to the BSD license.                                        *
 *----------------------------------------------------------------------------------------*
 * Authors: Joachim Fornallaz <jf@omnis.ch>                                               *
 *----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
/* global includes																								*/
/*----------------------------------------------------------------------------------------*/

#include	<types2b.h>
#include <cflib.h>
#include <ext.h>
#include	<mgx_dos.h>

/*----------------------------------------------------------------------------------------*/
/* local includes																									*/
/*----------------------------------------------------------------------------------------*/

#include	"shared\appcomm.h"
#include "mcontrol.h"
#include	"dialog.h"
#include	"config.h"
#include	"rsrc.h"

/*----------------------------------------------------------------------------------------*/
/* local defines																									*/
/*----------------------------------------------------------------------------------------*/

#ifndef FALSE
#define FALSE	0
#define TRUE	1
#endif

#ifdef __MTAES__
#define wind_create_grect(a,b)	wind_create(a,b)
#define wind_calc_grect(a,b,c,d)	wind_calc(a,b,c,d)
#define wind_open_grect(a,b)		wind_open(a,b)
#define wind_set_str(a,b,c)		wind_set_string(a,b,c)
extern int16 rc_intersect(GRECT *r1, GRECT *r2);
#endif

/*----------------------------------------------------------------------------------------*/
/* global variables																								*/
/*----------------------------------------------------------------------------------------*/

int16		event, msx, msy, mbutton, kstate, mclick, kreturn;
int16		quit;
int16		msg[8];
int16		id = 1, pts = 10;

/*----------------------------------------------------------------------------------------*/
/* functions																										*/
/*----------------------------------------------------------------------------------------*/



void handle_menu(int16 title, int16 item)
{
	switch (item)
	{
		case MENDE :
			quit = TRUE;
			break;

		case MOPEN :
			open_wdial( wdial, -1, -1 );
			break;

		case MABOUT :
			simple_mdial( about, 0 );
			break;

		default:
			break;
	}
	menu_tnormal(menu, title, 1);
}

static void handle_msg(int *msg)
{
	if (!message_wdial(msg))
	{
		switch (msg[0])
		{
			case MN_SELECTED:
				handle_menu(msg[3], msg[4]);
				break;

			case WM_CLOSED :
			case WM_BOTTOMED:
			case WM_REDRAW:
			case WM_NEWTOP:
			case WM_TOPPED:
			case WM_MOVED:
			case WM_SIZED:
				break;

			case AC_OPEN:
				open_wdial( wdial, -1, -1 );
				break;

			case AP_TERM :
				quit = TRUE;
				break;
		}
	}
}

/* --------------------------------------------------------------------------- */

int16 main(void)
{
	GRECT		n = {0,0,0,0};
	GRECT		r1;
	EVNTDATA	ev;
	int16		bclicks, bmask, bstate;
	boolean	leave;
	quit = FALSE;

	debug_init("MControl", null, NULL);

	init_app("mcontrol.rsc");
	init_rsrc();
	init_conf();
	init_dial();
	init_comm();

	set_mdial_wincb(handle_msg);

	graf_mkstate( &ev );
	wdial_hover( ev.x, ev.y, &r1, &leave );

	while (!quit)
	{
		mbutton = 0;

		if( !((ev.bstate) & 3) )
			bclicks = 258;
		else
			bclicks = 0;

		bmask = 3;
		bstate = 0;

		event = evnt_multi( MU_BUTTON|MU_M1|MU_MESAG|MU_KEYBD,
									bclicks, bmask, bstate,
									leave, &r1, 0, &n,
									msg,
									0l,
									&ev,
									&kreturn, &mclick );
		msx = ev.x;
		msy = ev.y;
		mbutton = ev.bstate;
		kstate = ev.kstate;

		if (event & MU_MESAG)
		{
			if( msg[0] == WM_MOVED )
				wdial_hover( msx, msy, &r1, &leave );		

			handle_msg(msg);			
		}

		if (event & MU_BUTTON) 
		{
			if( mbutton == 2 )
				menu_context( msx, msy );
			else if (!click_wdial(mclick, msx, msy, kstate, mbutton))
				;
		}

		if (event & MU_M1)
			wdial_hover( msx, msy, &r1, &leave );
		
		if (event & MU_KEYBD)
		{
			int16	title, item;

			if (is_menu_key(kreturn, kstate, &title, &item))
				handle_menu(title, item);
			else
			{
				key_wdial(kreturn, kstate);
				key_sdial(kreturn, kstate);
			}
		}
	}
	
	exit_comm();
	exit_dial();
	exit_rsrc();
	debug_exit();
	exit_app(0);
	return 0;
}
