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

#include "xalloc.h"
#include "taskman.h"
#include "objects.h"
#include "c_window.h"
#include "widgets.h"
#include "xa_form.h"
#include "xa_shel.h"
#include "xa_rsrc.h"
#include "xa_fsel.h"
#include "xa_clnt.h"
#include "scrlobjc.h"

/*
 *	General system dialogs
 *	(Error Log and Task Manager)
 */

global
void refresh_tasklist(LOCK lock)
{
	OBJECT *form = ResourceTree(C.Aes_rsc, TASK_MANAGER);
	XA_CLIENT *client;
	OBJECT *icon;			/* HR */
	int cpid;
	OBJECT *tl = form + TM_LIST;
	SCROLL_INFO *list = tl->ob_spec.listbox;
	char *tx;
/* Empty the task list */
	empty_scroll_list(form, TM_LIST, -1);

	Sema_Up(clients);		/* HR */

/* Add all current tasks to the list */

	client = S.client_list;						/* HR */
	while (client)
	{
#if 0
		if (client->msg)
			icon = form + TM_ICN_MESSAGE;
		else
		if (   client->pid == S.mouse_lock
		    or client->pid == S.update_lock
		   )
			icon = form + TM_ICN_LOCK;
		else
#endif

		if (client->type == APP_ACCESSORY)
			icon = form + TM_ICN_MENU;
		else
			icon = form + TM_ICN_XAAES;

#if 1
		tx = xmalloc(128,11);
		if (tx)
		{
			long prio = Pgetpriority(0, client->pid);
			if (prio >= 0)
				sdisplay(tx, " %d/%ld %s", client->pid, prio-20, client->name);
			else
				sdisplay(tx, " %d/E%ld %s", client->pid, prio, client->name);
				
			add_scroll_entry(form, TM_LIST, icon, tx, FLAG_MAL);
		}
		else
#endif
			add_scroll_entry(form, TM_LIST, icon, client->name, 0);
		client = client->next;
	}

	list->slider(list);				/* HR */

	Sema_Dn(clients);		/* HR */
}

global
XA_WINDOW *task_man_win = nil;

static
WindowDisplay taskmanager_destructor  /* HR */
{
	OBJECT *ob = ResourceTree(C.Aes_rsc, TASK_MANAGER) + TM_LIST;
	SCROLL_INFO *list = ob->ob_spec.listbox;
	delete_window(lock, list->wi);					/* HR */
	task_man_win = nil;
	return true;
}

XA_CLIENT *cur_client(SCROLL_INFO *list)
{
	SCROLL_ENTRY *this = list->start;
	XA_CLIENT *client = S.client_list;			/* HR */
		
	while(this != list->cur)
	{
		this = this->next;
		client = client->next;
	}
	return client;
}

static
void send_terminate(LOCK lock, XA_CLIENT *client)	/* HR 230102 */
{
	if (is_client(client))
	{
		if (client->type == APP_ACCESSORY)
		{
			/* Due to ambiguities in documentation the pid is filled out in both msg[3] and msg[4] */
			DIAGS(("   --   AC_CLOSE\n"));
			send_app_message(lock, nil, client,
					AC_CLOSE,    0, 0, client->pid,
					client->pid, 0, 0, 0);
			remove_windows(lock, client);
		}
		DIAGS(("   --   AP_TERM\n"));
		send_app_message(lock, nil, client,
					AP_TERM,     0,       0, client->pid,
					client->pid, AP_TERM, 0, 0);
	}
}

/* HR 300101: double click now also available for internal handlers. */
static
ObjectHandler handle_taskmanager /* (LOCK lock, XA_TREE *wt) */
{
	SCROLL_INFO *list;
	OBJECT *ob = wt->tree + TM_LIST;
	XA_CLIENT *client;

	list = ob->ob_spec.listbox;
	
	wt->current&=0xff; 			/* HR 300101: double click. */

	Sema_Up(clients);

	lock |= clients;
	
	switch(wt->current)
	{
	case TM_TERM:
		client = cur_client(list);		
		DIAGS(("TM_TERM for %s\n", c_owner(client)));
		send_terminate(lock, client);					/* HR 230102 */
		deselect(wt->tree, TM_TERM);
		display_toolbar(lock, task_man_win, TM_TERM);
		break;
	case TM_SHUT:
		DIAGS(("shutdown by taskmanager\n"));
		deselect(wt->tree, TM_SHUT);
		shutdown(lock);
		break;
	case TM_KILL:
		client = cur_client(list);		
		if (is_client(client))	/* HR */
		{
			Pkill(client->pid, SIGKILL);
			Fselect(200, nil, nil, nil);
			refresh_tasklist(lock);
			display_toolbar(lock, task_man_win, TM_LIST);
		}
		deselect(wt->tree, TM_KILL);
		display_toolbar(lock, task_man_win, TM_KILL);
		break;
	case TM_OK:
		deselect(wt->tree, TM_OK);
		display_toolbar(lock, task_man_win, TM_OK);
		close_window(lock, task_man_win);
		delete_window(lock, task_man_win);
		break;
	case TM_QUIT:
		C.shutdown = true;
		break;
	}

	Sema_Dn(clients);
}

global
void open_taskmanager(LOCK lock, bool shutdown)
{
	XA_WINDOW *dialog_window;
	XA_TREE *wt;
	OBJECT *form = ResourceTree(C.Aes_rsc, TASK_MANAGER);
	static RECT remember = {0,0,0,0};

	if (shutdown)
		form[TM_QUIT].ob_flags &= ~HIDETREE;
	else
		form[TM_QUIT].ob_flags |=  HIDETREE;

	if (!task_man_win)
	{
		form[TM_ICONS].ob_flags |= HIDETREE;			/* HR */

	/* Work out sizing */
		if (!remember.w)
		{
			center_form(form, ICON_H);
			remember =
			calc_window(lock, C.Aes, WC_BORDER,
									CLOSE|NAME,
									MG,
									C.Aes->options.thinframe,
									C.Aes->options.thinwork,
									form->r);	/* HR */
		}

	/* Create the window */
		dialog_window = create_window(lock, nil,
									C.Aes,
									false,
									CLOSE|NAME|TOOLBAR|hide_move(&default_options),
									created_for_AES,
									MG,
									C.Aes->options.thinframe,
									C.Aes->options.thinwork,
									remember, nil, &remember);

	/* Set the window title */
		get_widget(dialog_window, XAW_TITLE)->stuff = " Task Manager";

		wt = set_toolbar_widget(lock, dialog_window, form, -1);
		wt->exit_form = XA_form_exit;		/* HR 250602 */
		wt->exit_handler = handle_taskmanager;

	/* HR: set a scroll list widget */
		set_slist_object(lock, wt, form, TM_LIST, nil, nil, nil, nil, "Client Applications", nil, NICE_NAME);

	/* Set the window destructor */
		dialog_window->destructor = taskmanager_destructor;
	
		refresh_tasklist(lock);				/* HR: better position (to get sliders correct initially) */
		open_window(lock, dialog_window, dialog_window->r);
		task_man_win = dialog_window;
	}
	else if (task_man_win != window_list)   /* HR */
	{
		C.focus = pull_wind_to_top(lock, task_man_win);			/* HR */
		after_top(lock, true);
		display_window(lock, 100, task_man_win, nil);
	}
}

static
fsel_handler handle_launcher	/* (LOCK lock, char *path, char *file) */
{
	extern char fs_slash[], fs_pattern[];		/* HR */
	char parms[200], *t;
	
	sdisplay(parms + 1, "%s%s", path, file);		/* HR: no extra slash */
	parms[0] = '\0';
	for(t = parms + 1; *t; t++)
	{
		if(*t == slash)
			*t = bslash;
	}		

	close_fileselector(lock);

	DIAGS(("launch:%s\n", parms + 1));

	sdisplay(cfg.launch_path, "%s%s", path, fs_pattern);	/* HR */

	launch(lock, 0, 0, 0, parms + 1, parms, C.Aes);
}

#if FILESELECTOR
static
void open_launcher(LOCK lock)
{
	if (!*cfg.launch_path)					/* HR */
	{
		cfg.launch_path[0] = Dgetdrv() + 'a';
		cfg.launch_path[1] = ':';
		cfg.launch_path[2] = bslash;
		cfg.launch_path[3] = '*';
		cfg.launch_path[4] = 0;
	}

/* HR 060202: char *file */
	open_fileselector(lock, C.Aes, cfg.launch_path, nil, "Launch Program", handle_launcher, nil);
}
#endif

static
XA_WINDOW *systemalerts_win = nil;

/* HR 300101: double click now also available for internal handlers. */
static
ObjectHandler handle_systemalerts	/* (LOCK lock, XA_TREE *wt) */
{
	OBJECT *form = wt->tree;
	int item = wt->current&0xff;	 /* HR 300101: double click. */

	switch(item)
	{
	case SALERT_CLEAR:		/* Empty the task list */
		empty_scroll_list(form, SYSALERT_LIST, -1);
		deselect(wt->tree, item);
		display_toolbar(lock, systemalerts_win, SYSALERT_LIST);		/* HR */
		display_toolbar(lock, systemalerts_win, item);
		break;
	case SALERT_OK:
		deselect(wt->tree, item);
		display_toolbar(lock, systemalerts_win, item);
		close_window(lock, systemalerts_win);
		delete_window(lock, systemalerts_win);	
	}
}

static
WindowDisplay systemalerts_destructor	/* HR */
{
	OBJECT *ob = ResourceTree(C.Aes_rsc, SYS_ERROR) + SYSALERT_LIST;
	SCROLL_INFO *list = ob->ob_spec.listbox;
	delete_window(lock, list->wi);					/* HR */
	systemalerts_win = nil;
	return true;
}

static
void refresh_systemalerts(OBJECT *form)
{
	OBJECT *sl = form + SYSALERT_LIST;
	SCROLL_INFO *list = sl->ob_spec.listbox;

	list->slider(list);
}

static
void open_systemalerts(LOCK lock)
{
	XA_WINDOW *dialog_window;
	XA_TREE *wt;
	OBJECT *form = ResourceTree(C.Aes_rsc, SYS_ERROR);
	static RECT remember = {0,0,0,0};
	
	if (!systemalerts_win)	/* HR */
	{
		form[SALERT_ICONS].ob_flags |= HIDETREE;			/* HR */

	/* Work out sizing */
		if (!remember.w)
		{
			center_form(form, ICON_H);
			remember =
			calc_window(lock, C.Aes, WC_BORDER,
											CLOSE|NAME,
											MG,
											C.Aes->options.thinframe,
											C.Aes->options.thinwork,
											form->r);	/* HR */
		}

	/* Create the window */
		dialog_window = create_window(lock, nil,
											C.Aes,
											false,
											CLOSE|NAME|TOOLBAR|hide_move(&default_options),
											created_for_AES,
											MG,
											C.Aes->options.thinframe,
											C.Aes->options.thinwork,
											remember, nil, &remember);

	/* Set the window title */
		get_widget(dialog_window, XAW_TITLE)->stuff = " System window & Alerts Log";
		wt = set_toolbar_widget(lock, dialog_window, form, -1);
		wt->exit_form = XA_form_exit;		/* HR 250602 */
		wt->exit_handler = handle_systemalerts;

	/* HR: set a scroll list widget */
		set_slist_object(lock, wt, form, SYSALERT_LIST, nil, nil, nil, nil, nil, nil, 256);

	/* Set the window destructor */
		dialog_window->destructor = systemalerts_destructor;

		refresh_systemalerts(form);

		open_window(lock, dialog_window, dialog_window->r);
		systemalerts_win = dialog_window;
	}
	else if (systemalerts_win != window_list)
	{
		C.focus = pull_wind_to_top(lock, systemalerts_win);			/* HR */
		after_top(lock, true);
		display_window(lock, 101, systemalerts_win, nil);
	}
}

void open_about(LOCK lock);

/*
 *	Handle clicks on the system default menu
 */
global
void do_system_menu(LOCK lock, int clicked_title, int menu_item)
{
	switch(menu_item)
	{
	case MN_ABOUT:	/* Open the "About XaAES..." dialog */
		open_about(lock);
	break;
	case SHUTDOWN:			/* Shutdown the system */
		DIAGS(("shutdown by menu\n"));
		shutdown(lock);
	break;
	case MN_TASK_MANAGER:	/* Open the "Task Manager" window */
		open_taskmanager(lock, false);
	break;
	case MN_SALERT:			/* Open system alerts log window */
		open_systemalerts(lock);
	break;
#if MN_ENV
	case MN_ENV:
	{
		OBJECT *form = ResourceTree(C.Aes_rsc, SYS_ERROR);
		empty_scroll_list(form, SYSALERT_LIST, FLAG_ENV);
#if GENERATE_DIAGS
		{
			char *e = C.strings[0];
			while (*e)
			{
				add_scroll_entry(form, SYSALERT_LIST, nil, e, FLAG_ENV);
				e += strlen(e)+1;
			}
		}
#else
		{
			int i = 0;
			while (C.strings[i])
			{
				add_scroll_entry(form, SYSALERT_LIST, nil, C.strings[i], FLAG_ENV);
				i++;
			}
		}
#endif
		open_systemalerts(lock);
	}
	break;
#endif
#if FILESELECTOR
	case MN_LAUNCH:	/* Launch a new app */
		open_launcher(lock);
	break;
#endif
	case MN_DESK:	/* Launch desktop. */
		if (*C.desk)
			C.DSKpid = launch(lock, 0, 0, 0, C.desk, "\0", C.Aes);
	break;
	}
}

/* HR 231002: find a pending alert */
global
void *pendig_alerts(OBJECT *form, int item)
{
	SCROLL_INFO *list;
	OBJECT *ob = form + item;
	SCROLL_ENTRY *cur;

	list = get_ob_spec(ob)->listbox;
	cur = list->start;
	while (cur)
	{
		if (cur->flag & FLAG_PENDING)
		{
			cur->flag &= ~FLAG_PENDING;
			return cur->text;
		}
		cur = cur->next;
	}
	return nil;
}

/* HR 230102: simple but mostly effective shutdown using the taskmanager. */
global
void shutdown(LOCK lock)
{
	XA_CLIENT *client;

	Sema_Up(clients);

	lock |= clients;

	open_taskmanager(lock, true);

	client = S.client_list;
	while (client)
	{
		DIAGS(("shutting down %s\n", c_owner(client)));
		send_terminate(lock, client);
		client = client->next;
	}

	Sema_Dn(clients);
}

/* HR 250102 */
global
void update_tasklist(LOCK lock)
{
	if (task_man_win)
	{
		DIAGS(("update_tasklist\n"));
		refresh_tasklist(lock);
		display_toolbar(lock, task_man_win, TM_LIST);
	}
}
