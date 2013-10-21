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

#include <mintbind.h>
#include <signal.h>
#include <string.h>

#include "xa_types.h"
#include "xa_globl.h"

#include "app_man.h"
#include "xa_codes.h"
#include "c_window.h"
#include "desktop.h"
#include "objects.h"
#include "widgets.h"
#include "menuwidg.h"
#include "xa_rsrc.h"
#include "xa_clnt.h"

/*
 *	Application Manager
 *	This module handles various ways of swapping the current application...
 */

global
bool taskbar(XA_CLIENT *client)
{
#if AP_TASKBAR
	if (   strcmp(client->proc_name, "TASKBAR ") == 0
		or strcmp(client->proc_name, "MLTISTRP") == 0
	   )
		return true;
	return false;
#else
	return true;
#endif
}

global
XA_CLIENT *focus_owner(void)
{
	if (C.focus == root_window)
		return menu_owner();
	return C.focus->owner;
}


/*
 *	Go round and check whether any clients have died & we didn't notice.
 *	- Useful for cleaning up clients that weren't launched via a shell_write.
 */
global
void find_dead_clients(LOCK lock)
{
/* FIX_PC use of r eliminated; int?long? who wants to know? */
/* HR: use proper loop. */
	XA_CLIENT *client = S.client_list;
	while (client)
	{
		XA_CLIENT *next = client->next;			/* HR before FreeClient :-) */
		int pid = client->pid;
		if (pid > 0 and pid != C.AESpid)
		{
	/* HR: We dont look at client_end, because it is possible that a app is started by shell_write,
	    but never performed appl_init. */
			if (Pkill(pid, SIGNULL))	/* Poll to see if the client has died since we last looked... */
			{
				Pwaitpid(-1, 1, nil);
	
				DIAGS(("Dead client %s - cleaning up\n",c_owner(client)));
			
				if (client->init)
				{
					remove_refs(client, true);				/* HR 100701 */
					XA_client_exit(lock, client, nil);	/* Run the application exit cleanup */
				}
				if (client->kernel_end)
					close_client(lock, client);
			}
		}
		client = next;
	}
}

/*
 *	Attempt to recover a system that has locked up
 */
global
void recover(void)
{	
	DIAG((D_appl,nil,"Attempting to recover control.....\n"));

	if ((S.update_lock) and (S.update_lock != C.AESpid))
	{
		DIAG((D_appl,nil,"Killing owner of update lock\n"));
		Pkill(S.update_lock, SIGKILL);
	}
	
	if (((S.mouse_lock) and (S.mouse_lock != S.update_lock)) and (S.mouse_lock != C.AESpid))
	{
		DIAG((D_appl,nil,"Killing owner of mouse lock\n"));
		Pkill(S.mouse_lock, SIGKILL);
	}
	
	forcem();
}

/*
 *	Swap the main root window's menu-bar to be another application's
 *	NOTE: This only swaps the menu-bar, it doesn't swap the topped window.
 *
 *  HR: static pid array.
 *  See also click_menu_widget() for APP's
 */
global
void swap_menu(LOCK lock, XA_CLIENT *new, bool desk, int which)
{
	XA_WINDOW *top;
	XA_TREE *menu_bar = get_menu();

DIAG((D_appl,nil,"[%d]swap_menu\n", which));

	if (new->std_menu.tree)		/* HR: If the new client has no menu bar, no need for a change */
	{

DIAG((D_appl,nil,"  --   to %s\n", c_owner(new)));

/* HR menu widget.tree */
		if (new->std_menu.tree != menu_bar->tree)		/* Different menu? */
		{
			DIAG((D_appl,nil,"swapped to %s\n",c_owner(new)));

			*menu_bar = new->std_menu;

/* HR 060801 */
			top = window_list;

			DIAG((D_appl,nil,"top: %s\n", w_owner(top)));

			if (    top        != root_window
			    and top->owner != new        )
			{
				/* untop other pids windows */
				C.focus = root_window;
				DIAG((D_appl,nil,"Focus to root_window.\n"));
				display_window(lock, 110, top, nil);   /* Redisplay titles */
				send_untop(lock, top);
			}
			else
			if (    C.focus    == root_window
			    and top->owner == new        )
			{
				C.focus = top;
				DIAG((D_appl,nil,"Focus to top_window %s\n", w_owner(top)));
				display_window(lock, 111, top, nil);   /* Redisplay titles */
				send_ontop(lock);
			}
			else
			if (top->owner ne new)
				C.focus = root_window;			/* HR 111201 */
		}
		else
		{
			DIAG((D_appl,nil,"Same menu %s\n", c_owner(new)));
		}
	}

	/* Change desktops? HR 270801: now widget tree. */
	if (    desk
	    and new->desktop.tree
		and new->desktop.tree != get_desktop()->tree
		and new->desktop.tree != get_xa_desktop()
		)
	{
DIAG((D_appl,nil,"  --   with desktop\n"));
		set_desktop(&new->desktop);
		display_window(lock, 30, root_window, nil);
	}
	else
	if (new->std_menu.tree)		/* No - just change menu bar */
		redraw_menu(lock);
}

global
XA_TREE *find_menu_bar(LOCK lock)
{
	XA_CLIENT *last;
	XA_TREE *rtn = &C.Aes->std_menu;		/* default */

	Sema_Up(clients);
		
	last = S.client_list;
	while(last->next)
		last = last->next;

	while (last)
	{
		if (!last->killed)
			if (last->client_end and last->std_menu.tree)
			{
				rtn = &last->std_menu;
				DIAGS(("found std_menu %lx\n", rtn));
				break;
			}
		last = last->prior;
	}

	Sema_Dn(clients);

	return rtn;
}

global
XA_CLIENT *find_desktop(LOCK lock)
{
	XA_CLIENT *last, *rtn = C.Aes;		/* default */

	Sema_Up(clients);
		
	last = S.client_list;
	while(last->next)
		last = last->next;

	while (last)
	{
		if (!last->killed)
			if (last->client_end and last->desktop.tree)
			{
				rtn = last;
				DIAGS(("found desktop %lx\n", rtn));
				break;
			}
		last = last->prior;
	}

	Sema_Dn(clients);
	return rtn;
}

global
void unhide_app(LOCK lock, XA_CLIENT *client)
{
	XA_WINDOW *w;

	IFWL(Sema_Up(winlist);)

	w = window_list;
	while (w)
	{
		if (w == root_window)
			break;
		if (w->owner == client)
			unhide_window(lock|winlist, w);
		w = w->next;
	}

	app_in_front(lock, client);

	IFWL(Sema_Dn(winlist);)
}

global
void hide_app(LOCK lock, XA_CLIENT *client)
{
	XA_WINDOW *w;
	XA_CLIENT *focus = focus_owner();

	IFWL(Sema_Up(winlist);)

	DIAG((D_appl,nil,"hide_app for %s\n", c_owner(client) ));
	DIAG((D_appl,nil,"   focus is  %s\n", c_owner(focus_owner()) ));
	
	w = window_list;
	while (w)
	{
		if (    w != root_window
		    and w->owner == client
		    and !is_hidden(w)
		    and (w->active_widgets&MOVE) != 0			/* fail save */
		    and (w->active_widgets&HIDE) != 0			/* fail save */
		   )
		{
			RECT r = w->r, d = root_window->r;
#if HIDE_TO_HEIGHT
			r.y += d.h;			/* HR: Dead simple, isnt it? ;-) */
#else
			if (r.x > 0)		/* HR 140102 */
				while (r.x < d.w)
					r.x += d.w;
			else
				while (r.x + r.w > 0)
					r.x -= d.w;
#endif
			if (w->send_message)
				w->send_message(lock|winlist, w, nil,
					WM_MOVED, 0, 0, w->handle,
					r.x, r.y, r.w, r.h);
			else
				move_window(lock|winlist, w, -1, r.x, r.y, r.w, r.h);
		}
		w = w->next;
	}

	DIAG((D_appl,nil,"   focus now %s\n", c_owner(focus_owner()) ));

	if (client == focus)
		app_in_front(lock, next_app(lock));

	IFWL(Sema_Dn(winlist);)
}

global
void hide_other(LOCK lock, XA_CLIENT *client)
{
	XA_CLIENT *list = S.client_list;
	while (list)
	{
		if (list != client)
			hide_app(lock, list);
		list = list->next;
	}
	app_in_front(lock, client);
}

global
void unhide_all(LOCK lock, XA_CLIENT *client)
{
	XA_CLIENT *list = S.client_list;
	while (list)
	{
		unhide_app(lock, list);
		list = list->next;
	}
	app_in_front(lock, client);
}

global
bool any_hidden(LOCK lock, XA_CLIENT *client)
{
	bool ret = false;
	XA_WINDOW *w;
	
	IFWL(Sema_Up(winlist);)

	w = window_list;
	while (w)
	{
		if (w == root_window)
			break;
		if (w->owner == client and is_hidden(w))
		{
			ret = true;
			break;
		}
		w = w->next;
	}

	IFWL(Sema_Dn(winlist);)

	return ret;
}

global
bool any_window(LOCK lock, XA_CLIENT *client)
{
	XA_WINDOW *w;
	bool ret = false;

	IFWL(Sema_Up(winlist);)

	w = window_list;
	while (w)
	{
		if (	w != root_window
		    and w->is_open
		    and w->r.w
		    and w->r.h
		    and w->owner == client)
		{
			ret = true;
			break;
		}
		w = w->next;
	}

	IFWL(Sema_Dn(winlist);)

	return ret;
}

global
XA_CLIENT *next_app(LOCK lock)
{
	XA_CLIENT *foc;
	int pid, start_app;

	foc = focus_owner();
	if (!foc)
	{
		DIAGS(("No focus_owner()\n"));
		start_app = 1;
	}
	else
		start_app = foc->pid;
	
	pid = start_app + 1;
	DIAG((D_appl,nil,"next_app: %d\n", start_app));
	do
	{
		XA_CLIENT *client;

		if (pid >= MAX_PID)
			pid = 0;

		client = S.Clients[pid];

		if (client)
		{
			DIAG((D_appl,nil,"client_end %d, pid %d\n", client->client_end, pid));
			if (   client->client_end
			    or pid == C.AESpid		/* Valid client ? */
			   )
			{
				bool anywin = any_window(lock, client);
				DIAG((D_appl,nil,"anywin %d, menu %lx\n", anywin, client->std_menu.tree));
				if (   client->std_menu.tree
					or anywin
				   )
				{
					XA_CLIENT *ret = Pid2Client(pid);
					DIAG((D_appl,nil,"  --  return %s\n", c_owner(client)));
					return ret;
				}
			}
			DIAG((D_appl,nil,"  --  step --> %d\n",pid+1));
		}
		pid++;
	} while (pid != start_app);
	DIAG((D_appl,nil,"  --  fail\n"));
	return nil;
}

global
void app_in_front(LOCK lock, XA_CLIENT *client)
{
    XA_WINDOW *wl,*pr,*wf;

	if (client)
	{
		DIAG((D_appl, client, "app_in_front: %s\n", c_owner(client)));
	
		swap_menu(lock, client, true, 1);

		IFWL(Sema_Up(winlist);)
	
		wf = root_window->prev;
		while(wf)
			if (wf->owner == client)
				break;
			else
				wf = wf->prev;
	
		if (wf)
		{
			wl = wf;
			while (wl)
			{
				pr = wl->prev;
				if (wl->owner == client)
				{
					unhide_window(lock|winlist, wl);		/* HR 210801 */
					top_window(lock|winlist, wl, client);  /* HR 270801: client!!! */
				}
				wl = pr;
				if (wl == wf)
					break;
			}
		}
		IFWL(Sema_Dn(winlist);)
	}
}
