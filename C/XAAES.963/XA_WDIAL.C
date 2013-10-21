/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#define WDIAL_CALLBACK 1

#include <osbind.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>			/* We use the version without macros!! */

#include "xa_types.h"
#include "xa_globl.h"
#include "xa_nkcc.h"
#include "xa_form.h"

#include "objects.h"
#include "c_window.h"
#include "widgets.h"
#include "xa_graf.h"
#include "xa_rsrc.h"
#include "xa_form.h"
#include "objects.h"
#include "scrlobjc.h"

/*
 *	WDIALOG FUNCTIONS (wdial & lbox)
 *
 * HR 050402: implementation.
 */

#if WDIAL
global
AES_function XA_wdlg_create /* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_WINDOW *wind;
	XA_TREE *wt;
							
	CONTROL(2,0,4)

DIAG((D_wdlg,client,"XA_wdlg_create\n"));
DIAG((D_wdlg,client,"  --  exit %lx, tree %lx, user_data %lx, data %lx\n", pb->addrin[0], pb->addrin[1], pb->addrin[2], pb->addrin[3]));

	if (pb->addrin[0] and pb->addrin[1] and pb->addrout)
	{
		XA_WIND_ATTR tp = MOVE|NAME;
		RECT r;
		OBJECT *tree = pb->addrin[1];

		pb->addrout[0] = nil;

		tree->ob_state &= ~OUTLINED;
		if (tree->r.x <= 0 and tree->r.y <= 0)
			center_form(tree, ICON_H);

		r =
		calc_window(lock, client, WC_BORDER,
								tp,
								MG,
								false, false,
								tree->r);
		wind = create_window(lock, send_app_message, client, false,
								tp,
								created_for_WDIAL,
								MG,
								false, false,
								r, nil, nil);
		if (wind)
		{
			short rep;
			wt = set_toolbar_widget(lock, wind, tree, 0);
			wt->exit_form = exit_wdial;
			wt->exit_handler = nil;
			(long)
			wt->wdlg.handle = wind->handle;
			wt->wdlg.wind = wind;
			wt->wdlg.code = pb->intin[0];
			wt->wdlg.flag = pb->intin[1];
			wt->wdlg.user_data = pb->addrin[2];
			wt->wdlg.data      = pb->addrin[3];

#if WDIAL_CALLBACK
			wt->wdlg.exit      = pb->addrin[0];
			rep = wt->wdlg.exit(nil, nil, HNDL_INIT, wt->wdlg.code, wt->wdlg.data);
			if (rep == 0)
				delete_window(lock, wind);
			else
				(long)pb->addrout[0] = 0xae000000 + wind->handle;
#else
				(long)pb->addrout[0] = 0xae000000 + wind->handle;
			wt->wdlg.exit = nil;
#endif
		}			
	}

	return XAC_DONE;
}

global
AES_function XA_wdlg_open /* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_WINDOW *wind;
	XA_TREE *wt;
	short handle;

	CONTROL(4,1,3)

	pb->intout[0] = 0;

	if (*(unsigned char *)pb->addrin != 0xae)
		return XAC_DONE;

	handle = (short)pb->addrin[0];

DIAG((D_wdlg,client,"(%d)XA_wdlg_open, title %lx, data %lx\n", handle, pb->addrin[1],pb->addrin[2]));
DIAG((D_wdlg,client,"  --  tp=%x, x=%d, y=%d\n", pb->intin[0], pb->intin[1], pb->intin[2]));

	wind = get_wind_by_handle(lock, handle);		/* Get the window */
	if (wind)
	{
		RECT r = wind->r;
		XA_WIND_ATTR tp = pb->intin[0];

		tp &= CLOSE|MOVE|NAME;

	/* HR: The following if is a result of the clumsiness of the WDIALOG interface. So dont blame me. */
		if ((short)tp != (short)wind->active_widgets)		/* recreate window with final widget set. */
		{
			WDLG_INFO save;
			OBJECT *tree;

			wt = get_widget(wind, XAW_TOOLBAR)->stuff;
			save = wt->wdlg;
			tree = wt->tree;
			delete_window(lock, wind);
			r =
			calc_window(lock, client, WC_BORDER,
									tp,
									MG,
									false, false,
									tree->r);
			wind = create_window(lock, send_app_message, client, false,
									tp,
									created_for_WDIAL,
									MG,
									false, false,
									r, nil, nil);
			if (wind)
			{
				wt = set_toolbar_widget(lock, wind, tree, 0);
				wt->exit_form = exit_wdial;
				wt->wdlg = save;
			}
		}
	
		r.x = pb->intin[1];
		r.y = pb->intin[2];
		if (r.x == -1 or r.y == -1)
		{
			r.x = (root_window->wa.w - r.w) / 2;		/* HR: desktop work area */
			r.y = (root_window->wa.h - r.h) / 2;
		}
		if (pb->addrin[1])
			get_widget(wind, XAW_TITLE)->stuff = pb->addrin[1];
		open_window(lock, wind, r);
		wt = get_widget(wind, XAW_TOOLBAR)->stuff;
		wt->wdlg.data = pb->addrin[2];

#if WDIAL_CALLBACK
		wt->wdlg.exit(wt->wdlg.handle, nil, HNDL_OPEN, pb->intin[3], wt->wdlg.data);
#endif
		pb->intout[0] = handle;
	}

	return XAC_DONE;
}

global
AES_function XA_wdlg_close /* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_WINDOW *wind;
	short handle;

	CONTROL(0,3,1)

	pb->intout[0] = 0;

	if (*(unsigned char *)pb->addrin != 0xae)
		return XAC_DONE;

	handle = (short)pb->addrin[0];

DIAG((D_wdlg,client,"(%d)XA_wdlg_close\n", handle));

	wind = get_wind_by_handle(lock, handle);		/* Get the window */
	if (wind)
	{
		pb->intout[1] = wind->r.x;
		pb->intout[2] = wind->r.y;
		close_window(lock, wind);
		pb->intout[0] = 1;
	}

	return XAC_DONE;
}

global
AES_function XA_wdlg_delete /* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_WINDOW *wind;
	short handle;

	CONTROL(0,1,1)

	pb->intout[0] = 0;

	if (*(unsigned char *)pb->addrin != 0xae)
		return XAC_DONE;

	handle = (short)pb->addrin[0];

DIAG((D_wdlg,client,"(%d)XA_wdlg_delete\n", handle));

	wind = get_wind_by_handle(lock, handle);		/* Get the window */
	if (wind)
	{
		delete_window(lock, wind);
		pb->intout[0] = 1;
	}

	return XAC_DONE;
}

global
AES_function XA_wdlg_get /* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_WINDOW *wind;
	XA_TREE *wt;
	short handle;
	RECT *r;

	CONTROL(1,0,1)

	pb->intout[0] = 0;

	if (*(unsigned char *)pb->addrin != 0xae)
		return XAC_DONE;

	handle = (short)pb->addrin[0];

DIAG((D_wdlg,client,"(%d)XA_wdlg_get %d\n", handle, pb->intin[0]));

	wind = get_wind_by_handle(lock, handle);		/* Get the window */
	if (wind)
	{
		pb->intout[0] = 1;
		wt = get_widget(wind, XAW_TOOLBAR)->stuff;
		if (wt == nil)				/* Not the correct window */
		{
			DIAG((D_wdlg,client," -- widget gone\n"));
			pb->intout[0] = 0;
		} else
		{
			switch(pb->intin[0])
			{
			case 0:						/* wdlg_get_tree */
				r = pb->addrin[2];
				if (r)
					*r = wind->wa;
				if (pb->addrin[1])
					*(OBJECT **)pb->addrin[1] = wt->tree;
				DIAG((D_wdlg,client," -- tree %lx (%d/%d,%d/%d)\n", wt->tree, *r));		
			break;
			case 1:					/* wdlg_get_edit */
				pb->intout[0] = wt->edit_obj;
				if (wt->edit_obj < 0)
					pb->intout[0] = 0;
				pb->intout[1] = wt->edit_pos;
				DIAG((D_wdlg,client," ---> edit_obj %d, edit_pos %d\n", pb->intout[0], pb->intout[1]));		
			break;
			case 2:					/* wdlg_get_udata */
				if (pb->addrout)
				{
					pb->addrout[0] = wt->wdlg.user_data;
					DIAG((D_wdlg,client," -- udata %lx\n", pb->addrout[0]));
				}
			break;
			case 3:					/* wdlg_get_handle */
				pb->intout[0] = handle;
				DIAG((D_wdlg,client," -- handle %d\n", handle));
			break;
			default:
				DIAG((D_wdlg,client," -- error\n"));
			}
		}
	} else
	{
		DIAG((D_wdlg,client," -- window gone\n"));
	}

	return XAC_DONE;
}

global
AES_function XA_wdlg_set /* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_WINDOW *wind;
	XA_TREE *wt;
	OBJECT *tree;
	short handle;

	CONTROL(2,1,1)

	pb->intout[0] = 0;

	if (*(unsigned char *)pb->addrin != 0xae)
		return XAC_DONE;

	handle = (short)pb->addrin[0];

DIAG((D_wdlg,client,"(%d)XA_wdlg_set %d\n", handle, pb->intin[0]));

	wind = get_wind_by_handle(lock, handle);		/* Get the window */
	if (wind)
	{
		pb->intout[0] = 1;
		wt = get_widget(wind, XAW_TOOLBAR)->stuff;
		if (wt)				/* Not the correct window */
		{
			switch(pb->intin[0])
			{
			case 0:					/* wdlg_set_edit */
				edit_object(lock,
						pb->intin[1] ? ED_INIT : ED_END,
						wt, wt->tree, pb->intin[1], 0, &pb->intout[0]);
			break;
			case 1:					/* wdlg_set_tree */
#if 0
				/* HR: rubbish! a new tree is a new dialogue is a new window! */

				tree = pb->addrin[1];
				if (tree and tree != wt->tree)
				{
					RECT r = tree->r;
					WDLG_INFO keep = wt->wdlg;
					wt = set_toolbar_widget(lock, wind, tree, 0);
					wt->wdlg = keep;
					wt->exit_form = exit_edial;
					wt->exit_handler = nil;
			
					tree->ob_state &= ~OUTLINED;

					move_window(lock, wind, -1, r.x, r.y, r.w, r.h);
				}
				else
					display_window(lock, 200, wind, nil);
			break;
#endif
			case 2:					/* wdlg_set_size */
			case 3:					/* wdlg_iconify */
			case 4:					/* wdlg_uniconify */
				pb->intout[0] = 0;		/* Not implemented. Will be, but by proper widget settings! */
			break;
			default:
				pb->intout[0] = 0;
			}
		}
	}

	return XAC_DONE;
}

global
AES_function XA_wdlg_event /* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_WINDOW *wind;
	short handle;

	CONTROL(0,1,0)

	pb->intout[0] = 0;

	if (*(unsigned char *)pb->addrin != 0xae)
		return XAC_DONE;

	handle = (short)pb->addrin[0];
	pb->intout[0] = 1;

DIAG((D_wdlg,client,"(%d)XA_wdlg_event\n", handle));

	wind = get_wind_by_handle(lock, handle);		/* Get the window */
	if (wind)
	{
		XA_TREE *wt = get_widget(wind, XAW_TOOLBAR)->stuff;
		if (wt)
		{
			EVNT *ev = pb->addrin[1];
			if (ev)
			{
				short rep = 999;		/* I wnat to see if the programs react. */
	
				wt->wdlg.evnt = ev;
				DIAG((D_wdlg,client,"  --  mwhich %d\n", ev->mwhich));
				if (wt->which)			/* There must have been a exit condition. See exit_form() in XA_FORM.C */
				{
#if WDIAL_CALLBACK
					short ob = wt->current&0xff,
					      dbl = wt->current < 0 ? 2 : 1;

					rep = wt->wdlg.exit(wt->wdlg.handle,
										ev,
										ob,
										dbl,
										wt->wdlg.user_data);
					DIAG((D_wdlg,client," obj ---> %d\n",rep));
#endif
					ev->mwhich &= ~wt->which;
					wt->which = 0;
				}
#if WDIAL_CALLBACK
				else
				if (    (ev->mwhich & MU_MESAG)
				    and (ev->msg[0] == WM_CLOSED)
				   )
				{
					rep = wt->wdlg.exit(wt->wdlg.handle,
										ev,
										HNDL_CLSD,
										0,
										wt->wdlg.data);

					DIAG((D_wdlg,client," HNDL_CLSD ---> %d\n",rep));
					ev->mwhich &= ~MU_MESAG;
				}

				if (rep == 0)
				{
					close_window(lock, wt->wdlg.wind);
					delete_window(lock, wt->wdlg.wind);
					pb->intout[0] = 0;
				}
#endif
			}
		}
	}

	return XAC_DONE;
}

global
AES_function XA_wdlg_redraw /* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_WINDOW *wind;
	short handle;

	CONTROL(2,0,2)

	pb->intout[0] = 0;

	if (*(unsigned char *)pb->addrin != 0xae)
		return XAC_DONE;

	handle = (short)pb->addrin[0];

DIAG((D_wdlg,client,"(%d)XA_wdlg_redraw\n", handle));

	wind = get_wind_by_handle(lock, handle);		/* Get the window */
	if (wind)
	{
		XA_WIDGET *widg = get_widget(wind, XAW_TOOLBAR);

		widg->start = pb->intin[0];
		display_widget(lock, wind, widg);		/* We ignore the additional rectangle of the wdlg interface. */
		widg->start = 0;
		pb->intout[0] = 1;
	}
	return XAC_DONE;
}

#endif


#if LBOX

global
AES_function XA_lbox_create /* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(4,0,8)

DIAG((D_lbox,client,"XA_lbox_create\n"));

	pb->intout[0] = 0;
	return XAC_DONE;
}

global
AES_function XA_lbox_update /* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(0,0,2)

DIAG((D_lbox,client,"XA_lbox_update\n"));

	pb->intout[0] = 0;
	return XAC_DONE;
}

global
AES_function XA_lbox_do /* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(1,1,1)

DIAG((D_lbox,client,"XA_lbox_do\n"));

	pb->intout[0] = 0;
	return XAC_DONE;
}

global
AES_function XA_lbox_delete /* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(0,1,1)

DIAG((D_lbox,client,"XA_lbox_delete\n"));

	pb->intout[0] = 0;
	return XAC_DONE;
}

global
AES_function XA_lbox_get /* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(1,0,1)

DIAG((D_lbox,client,"XA_lbox_get\n"));

	pb->intout[0] = 0;
	return XAC_DONE;
}

global
AES_function XA_lbox_set /* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(2,0,2)

DIAG((D_lbox,client,"XA_lbox_set\n"));

	pb->intout[0] = 0;
	return XAC_DONE;
}
#endif
