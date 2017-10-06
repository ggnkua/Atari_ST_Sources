/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <osbind.h>
#include <mintbind.h>
#include <signal.h>
#include <string.h>

#include "xa_types.h"
#include "xa_globl.h"

#include "taskman.h"
#include "objects.h"
#include "c_window.h"
#include RSCHNAME
#include "widgets.h"
#include "xa_form.h"
#include "xa_shel.h"
#include "xa_rsrc.h"
#include "xa_fsel.h"
#include "scrlobjc.h"

/*
 *	General system dialogs
 *	(Error Log and Task Manager)
 */

static
void refresh_tasklist(LOCK lock, OBJECT *form)
{
	XA_CLIENT *client;
	OBJECT *icon;			/* HR */
	short cpid;
	OBJECT *tl = form + TM_LIST;
	SCROLL_INFO *list = tl->ob_spec.listbox;
	char *tx;

/* Empty the task list */
	empty_scroll_list(form, TM_LIST, -1);

	if unlocked(clients)
		Sema_Up(CLIENTS_SEMA);		/* HR */

/* Add all current tasks to the list */

	client = S.client_list;						/* HR */
	while (client)
	{
		if (client->msg)
			icon = form + TM_ICN_MESSAGE;
		else
		{
			cpid = Client2Pid(client);
			if ((cpid == S.mouse_lock) or (cpid == S.update_lock))
				icon = form + TM_ICN_LOCK;
			else if (client->type == XA_CT_ACC)
				icon = form + TM_ICN_MENU;
			else
				icon = form + TM_ICN_XAAES;
		}
#if 1
		tx = xmalloc(128,11);
		if (tx)
		{
			long prio = Pgetpriority(0, client->pid);
			if (prio > 0)
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

	if unlocked(clients)
		Sema_Dn(CLIENTS_SEMA);		/* HR */
}

static
XA_WINDOW *task_man_win = nil;

static
WindowDisplay taskmanager_destructor  /* HR */
{
	OBJECT *ob = ResourceTree(C.Aes_rsc, TASK_MANAGER) + TM_LIST;
	SCROLL_INFO *list = ob->ob_spec.listbox;
	delete_window(lock, list->wi);					/* HR */
	task_man_win = nil;
	return TRUE;
}

/* HR 300101: double click now also available for internal handlers. */
static
ObjectHandler handle_taskmanager /* (LOCK lock, XA_TREE *wt) */
{
	SCROLL_INFO *list;
	SCROLL_ENTRY *this;
	OBJECT *ob = wt->tree + TM_LIST;
	XA_CLIENT *client;
	
	list = ob->ob_spec.listbox;
	
	wt->item&=0xff; 			/* HR 300101: double click. */
	switch(wt->item)
	{
	case TM_KILL:
		client = S.client_list;			/* HR */
		this = list->start;
			
		while(this != list->cur)
		{
			this = this->next;
			client = client->next;
		}
		
		if (is_client(client))	/* HR */
		{
			Pkill(client->pid, SIGKILL);
			Fselect(200, nil, nil, nil);
			refresh_tasklist(lock, wt->tree);
			display_toolbar(lock, task_man_win, TM_LIST);
		}
		break;
	}
}

static
SendMessage taskman_msg_handler {}

global
void open_taskmanager(LOCK lock)
{
	XA_WINDOW *dialog_window;
	XA_TREE *wt;
	OBJECT *form = ResourceTree(C.Aes_rsc, TASK_MANAGER);
	static RECT remember = {0,0,0,0};

	if (!task_man_win)
	{
		form[TM_ICONS].ob_flags |= HIDETREE;			/* HR */

	/* Work out sizing */
		if (!remember.w)
			center_form(form, ICON_H),
			calc_window(C.AESpid, WC_BORDER, CLOSE|NAME, &form->r, &remember);	/* HR */

	/* Create the window */
		dialog_window = create_window(lock, taskman_msg_handler,
									C.AESpid,
									false,
									CLOSE|NAME|
									MOVE|
									NO_MESSAGES|NO_WORK,
									MG, remember, nil, &remember);

	/* Set the window title */
		dialog_window->widgets[XAW_TITLE].stuff = " Task Manager";

		wt = set_toolbar_widget(lock, dialog_window, form, -1);
		wt->pid = C.AESpid;
		wt->handler = &handle_taskmanager;

	/* HR: set a scroll list widget */
		set_slist_widget(lock, C.AESpid, dialog_window, form, TM_LIST, nil, nil, nil, nil, "Client Applications", nil, NICE_NAME);

	/* Set the window destructor */
		dialog_window->destructor = &taskmanager_destructor;
	
		refresh_tasklist(lock, form);				/* HR: better position (to get sliders correct initially) */
		open_window(lock, C.AESpid, dialog_window->handle, dialog_window->r);
		task_man_win = dialog_window;
	}
	else if (task_man_win != window_list)   /* HR */
	{
		C.focus = pull_wind_to_top(lock, task_man_win);			/* HR */
		after_top(lock, true);
		display_non_topped_window(lock, 100, task_man_win, nil);
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
		cfg.launch_path[0] = Dgetdrv() + 'A';
		cfg.launch_path[1] = ':';
		cfg.launch_path[2] = bslash;
		cfg.launch_path[3] = '*';
		cfg.launch_path[4] = 0;
	}
	open_fileselector(lock, C.AESpid, cfg.launch_path, "Launch Program", handle_launcher, nil);
}
#endif

static
XA_WINDOW *systemalerts_win = nil;

/* HR 300101: double click now also available for internal handlers. */
static
ObjectHandler handle_systemalerts	/* (LOCK lock, XA_TREE *wt) */
{
	OBJECT *form = wt->tree;
	wt->item&=0xff; 			/* HR 300101: double click. */
	switch(wt->item)
	{
	case SALERT_CLEAR:		/* Empty the task list */
		empty_scroll_list(form, SYSALERT_LIST, -1);
		display_toolbar(lock, systemalerts_win, SYSALERT_LIST);		/* HR */
		break;
	}
}

static
WindowDisplay systemalerts_destructor	/* HR */
{
	OBJECT *ob = ResourceTree(C.Aes_rsc, SYS_ERROR) + SYSALERT_LIST;
	SCROLL_INFO *list = ob->ob_spec.listbox;
	delete_window(lock, list->wi);					/* HR */
	systemalerts_win = nil;
	return TRUE;
}

static
SendMessage sysalert_msg_handler {}

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
			center_form(form, ICON_H),
			calc_window(C.AESpid, WC_BORDER, CLOSE|NAME, &form->r, &remember);	/* HR */

	/* Create the window */
		dialog_window = create_window(lock, sysalert_msg_handler,
											C.AESpid,
											false,
											CLOSE|NAME|
											MOVE|
											NO_MESSAGES|NO_WORK,
											MG, remember, nil, &remember);

	/* Set the window title */
		dialog_window->widgets[XAW_TITLE].stuff = " System window & Alerts Log";
		wt = set_toolbar_widget(lock, dialog_window, form, -1);
		wt->pid = C.AESpid;
		wt->handler = &handle_systemalerts;

	/* HR: set a scroll list widget */
		set_slist_widget(lock, C.AESpid, dialog_window, form, SYSALERT_LIST, nil, nil, nil, nil, nil, nil, 256);

	/* Set the window destructor */
		dialog_window->destructor = &systemalerts_destructor;

		refresh_systemalerts(form);

		open_window(lock, C.AESpid, dialog_window->handle, dialog_window->r);
		systemalerts_win = dialog_window;
	}
	else if (systemalerts_win != window_list)
	{
		C.focus = pull_wind_to_top(lock, systemalerts_win);			/* HR */
		after_top(lock, true);
		display_non_topped_window(lock, 101, systemalerts_win, nil);
	}
}

#if NOTYET
short shutdown_contrl[] = {XA_SHUTDOWN, 0, 0, 0, 0};
AESPB shutdown_pb;
#endif

void open_about(LOCK lock);

/*
 *	Handle clicks on the system default menu
 */
global
void do_system_menu(LOCK lock, short clicked_title, short menu_item)
{
	switch(menu_item)
	{
	case XA_SYSTEM_ABOUT:	/* Open the "About XaAES..." dialog */
		open_about(lock);
	break;
	case SHUTDOWN:			/* Shutdown the system */
		DIAGS(("shutdown by menu\n"));
		C.shutdown = true;
		Psignal(SIGCHLD, 0L);
	break;
	case MN_TASK_MANAGER:	/* Open the "Task Manager" window */
		open_taskmanager(lock);
	break;
	case MN_SALERT:			/* Open system alerts log window */
		open_systemalerts(lock);
	break;
#if MN_ENV
	case MN_ENV:
	{
		SCROLL_ENTRY entry;
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
			short i = 0;
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
	case XA_SYSTEM_LAUNCH:	/* Launch a new app */
		open_launcher(lock);
	break;
#endif
	}
}
