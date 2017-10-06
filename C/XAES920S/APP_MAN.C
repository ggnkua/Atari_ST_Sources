/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <osbind.h>
#include <mintbind.h>
#include <signal.h>

#include "xa_types.h"
#include "xa_globl.h"

#include "app_man.h"
#include "xa_codes.h"
#include "c_window.h"
#include RSCHNAME
#include "desktop.h"
#include "objects.h"
#include "widgets.h"
#include "menuwidg.h"
#include "xa_rsrc.h"
#include "new_clnt.h"
#include "kernel.h"

/*
 *	Application Manager
 *	This module handles various ways of swapping the current application...
*/

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
		short pid = client->pid;
		if (pid > 0 and pid != C.AESpid)
		{
	/* HR: We dont look at client_end, because it is possible that a app is started by shell_write,
	    but never performed appl_init. */
			if (Pkill(pid, SIGNULL))	/* Poll to see if the client has died since we last looked... */
			{
				Pwaitpid(-1, 1, nil);
	
				DIAGS(("Dead client %s(%d) - cleaning up\n",client->proc_name, pid));
			
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
	DIAG((D.appl,-1,"Attempting to recover control.....\n"));

	if ((S.update_lock) and (S.update_lock != C.AESpid))
	{
		DIAG((D.appl,-1,"Killing owner of update lock\n"));
		Pkill(S.update_lock, SIGKILL);
	}
	
	if (((S.mouse_lock) and (S.mouse_lock != S.update_lock)) and (S.mouse_lock != C.AESpid))
	{
		DIAG((D.appl,-1,"Killing owner of mouse lock\n"));
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
void swap_menu(LOCK lock, short pid, bool desk)
{
	XA_CLIENT *new = Pid2Client(pid);
	XA_TREE *menu_bar = root_window->widgets[XAW_MENU].stuff;
DIAG((D.menu,-1,"swap_menu to '%s'(%d)\n", new->name, pid));

	if (new->std_menu.tree)		/* HR: If the new client has no menu bar, no need for a change */
	{

/* HR menu widget.tree */
		if (new->std_menu.tree != menu_bar->tree)		/* Different menu? */
		{
			if (new->std_menu.pid == C.AESpid)
			{
				DIAG((D.menu,-1,"swapped to AES\n"));
				*menu_bar = C.Aes->std_menu;	/* Apps with no menu get the default menu, and that's owned by the AES */
			}
			else
			{
				DIAG((D.menu,-1,"swapped to pid %d\n",pid));
				*menu_bar = new->std_menu;	/* Apps with menus own their own menu */
			}
/* HR 060801 */
			DIAG((D.menu,-1,"window_list->pid: %d\n", window_list->pid));

			if (    window_list != root_window
			    and window_list->pid != pid)
			{
				/* untop other pids windows */
				C.focus = root_window;
				DIAG((D.menu,-1,"Focus to root_window %d\n", root_window->pid));
				display_non_topped_window(lock, 110, window_list, nil);   /* Redisplay titles */
				send_untop(lock, window_list);
			}
			else
			if (    C.focus == root_window
			    and window_list->pid == pid)
			{
				C.focus = window_list;
				DIAG((D.menu,-1,"Focus to top_window %d\n", root_window->pid));
				display_non_topped_window(lock, 111, window_list, nil);   /* Redisplay titles */
				send_ontop(lock);
			}

		}
		else
		{
			DIAG((D.menu,-1,"Same menu %d\n",pid));
		}
	}

	if (    desk
	    and new->desktop						/* Change desktops? */
		and new->desktop != get_desktop()
		and new->desktop != get_xa_desktop()
		)
	{
		set_desktop(new->desktop);
		root_window->pid = pid;
		root_window->owner = new;
		display_non_topped_window(lock, 30, root_window, nil);
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

	if unlocked(clients)
		Sema_Up(CLIENTS_SEMA);
		
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

	if unlocked(clients)
		Sema_Dn(CLIENTS_SEMA);
	return rtn;
}

global
XA_CLIENT *find_desktop(LOCK lock)
{
	XA_CLIENT *last, *rtn = C.Aes;		/* default */

	if unlocked(clients)
		Sema_Up(CLIENTS_SEMA);
		
	last = S.client_list;
	while(last->next)
		last = last->next;

	while (last)
	{
		if (!last->killed)
			if (last->client_end and last->desktop)
			{
				rtn = last;
				DIAGS(("found desktop %lx\n", rtn));
				break;
			}
		last = last->prior;
	}

	if unlocked(clients)
		Sema_Dn(CLIENTS_SEMA);
	return rtn;
}

global
short next_app(void)
{
	XA_TREE *menu_bar = root_window->widgets[XAW_MENU].stuff;
	XA_CLIENT *client;
	short pid, start_app;
	
	start_app = C.focus == root_window ? menu_bar->pid : window_list->pid;
	
	pid = start_app + 1;
	
	do
	{
		if (pid >= MAX_PID)
			pid = 0;
		client = S.Clients[pid];
		if (client)
			if (client->client_end or pid == C.AESpid)		/* Valid client ? */
				return pid;
		pid++;
	} while (pid != start_app);
	return 0;
}

global
void app_in_front(LOCK lock, short pid)
{
    XA_WINDOW *wl,*pr,*wf;

	swap_menu(lock, pid, true);

	if unlocked(winlist)
		Sema_Up(WIN_LIST_SEMA);

	wf = root_window->prev;
	while(wf)
		if (wf->pid == pid)
			break;
		else
			wf = wf->prev;

	if (wf)
	{
		wl = wf;
		while (wl)
		{
			pr = wl->prev;
			if (wl->pid == pid)
				top_window(lock|winlist, wl, menu_owner());
			wl = pr;
			if (wl == wf)
				break;
		}
	}
	if unlocked(winlist)
		Sema_Dn(WIN_LIST_SEMA);
}

global
void list_apps(void)
{
	short f;
	
	DIAGS(("========== XaAES Client Applications List ===========\n"));
	/* HR: static pid array */
	for (f = 0; f < MAX_PID; f++)
	{
		XA_CLIENT *client = S.Clients[f];
		if (client and client->client_end)
		{
			DIAGS(("%d:%s..Wait[", f, client->name));
			if (client->waiting_for & MU_BUTTON)
				DIAGS(("B"));
			if (client->waiting_for & MU_KEYBD)
				DIAGS(("K"));
			if (client->waiting_for & MU_M1)
				DIAGS(("1"));
			if (client->waiting_for & MU_M2)
				DIAGS(("2"));
			if (client->waiting_for & MU_MX)
				DIAGS(("X"));
			if (client->waiting_for & MU_MESAG)
				DIAGS(("M"));
			if (client->waiting_for & MU_TIMER)
				DIAGS(("T"));
			if (client->waiting_for & XAWAIT_CHILD)
				DIAGS(("C"));
			if (client->waiting_for & XAWAIT_MULTI)
				DIAGS(("{MULTI}"));
			DIAGS(("]:AESparent=%d", client->parent));
			if (client->std_menu.tree)		/* HR: now widget */
				DIAGS((":HasMenubar"));
			if (((XA_TREE *)root_window->widgets[XAW_MENU].stuff)->pid == f)
				DIAGS(("(current)"));
			if (client->desktop)
				DIAGS((":OwnsDesktop"));
			if (client->msg)
				DIAGS((":MsgPending"));
			if (S.mouse_lock == f)
				DIAGS((":OwnsMouseLock"));
			if (S.update_lock == f)
				DIAGS((":OwnsUpdateLock"));
			
			DIAGS(("\n"));
		}
	}
}

global
void status_dump(void)
{
	DIAGS(("========== XaAES Status ===========\n"));

	DIAGS(("AESpid=%d\n", C.AESpid));
	DIAGS(("DSKpid=%d\n", C.DSKpid));

	DIAGS(("Display Device: Phys_handle=%d, Virt_handle=%d\n", C.P_handle, C.vh));
	DIAGS((" size=[%d,%d], colours=%d, bitplanes=%d\n", screen.r.w, screen.r.h, screen.colours, screen.planes));

	DIAGS(("mouse_lock=%d, mouse_cnt=%d\n", S.mouse_lock, S.mouse_cnt));
	DIAGS(("update_lock=%d, update_cnt=%d\n", S.update_lock, S.update_cnt));

	DIAGS(("root window menu : owner=%d\n", ((XA_TREE *)root_window->widgets[XAW_MENU].stuff)->pid));
}
