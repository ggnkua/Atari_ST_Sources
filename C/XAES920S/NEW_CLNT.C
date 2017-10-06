/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <fcntl.h>
#include <osbind.h>
#include <mintbind.h>
#include <string.h>

#include "xa_types.h"
#include "xa_globl.h"

#include "c_window.h"
#include RSCHNAME
#include "rectlist.h"
#include "desktop.h"
#include "menuwidg.h"
#include "widgets.h"
#include "xa_rsrc.h"
#include "xa_shel.h"
#include "app_man.h"

#if MEASURE_LINES_APP
global long wind_gets = 0, gclk = 0;
#endif

global
char *getsuf(char *f)
{
	char *p;
	
	if ((p = strrchr(f, '.')) != 0L)
		if (    strchr(p,slash ) == 0L
			and strchr(p,bslash) == 0L
		   )		/* didnt ran over slash? */
			return p+1;
	return 0L;					/* no suffix  */
}

global
char *get_procname(short pid)
{
#include "ipff.h"
	static
	char name[PATH_MAX];
	char *suf,*nm = name + 4;
	long i = Dopendir("u:\\proc", 0);
	if (i > 0)
	{
		while (Dreaddir(NAME_MAX,i,name) eq 0)
		{
			suf = getsuf(nm);
			if (suf)
			{
				short d;
				ipff_in(suf);
				d = idec();
				if (d == pid)		/* gotcha */
				{
					*(suf - 1) = 0;
					Dclosedir(i);
					return nm;
				}
			}
		}
		Dclosedir(i);
	}
	return nil;
}

#if 0
#include "obsolete/isolatem.h"
#endif

/*
 *	Open the clients comms pipe in response to an XA_NEW_CLIENT message
 */
global
AES_function XA_new_client	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	char pipe_name[50];
	char fmt[] = "u:" sbslash "pipe" sbslash "XaClnt.%d\0";
	char *pname;
	short f;  long clock(void);

DIAG((D.appl,-1,"XA_new_client for %d\n",client->pid));
DIAG((D.appl,-1," - client_end %d\n",client->client_end));

	if (!client->client_end)	/* If this occurs, then we've got a problem */
	{
		DIAG((D.appl,-1,"Init client - Error: client pipe does not exist yet?\n"));
		/* PANIC - opening a global handle won't help because global
			handles can't be used in an Fselect mask... */
		return XAC_BLOCK ;
	}

DIAG((D.appl,-1," - kernel_end %d\n",client->kernel_end));
	if (!client->kernel_end)
	{
		sdisplay(pipe_name, fmt, client->pid);						/* Open the clients reply pipe for writing to */
		client->kernel_end = Fopen(pipe_name, O_RDWR|O_DENYNONE);		/* Kernal's end of pipe*/
		insert_client_handle(client);
	}

/*	HR 040401: This field must nil if no menu bar.
	client->std_menu = C.Aes->std_menu;
*/
	pname = get_procname(client->pid);		/* HR: 211200 */
	if (pname)
	{
		strncpy(client->proc_name, pname, 8);
		for (f = strlen(client->proc_name); f < 8; f++)		/* tssj! HR; 021200 */
			client->proc_name[f] = ' ';
		client->proc_name[8] = '\0';
		strnupr(client->proc_name,8);
		DIAGS(("get_procname for %d: '%s'\n",client->pid, client->proc_name));
	}
#if 0
	else if (*client->cmd_name)
		isolate_procname(client)
#endif
	sdisplay(client->name, "  %s", client->proc_name);  /* awaiting menu_register */

#if MEASURE_LINES_APP
	if (strcmp(client->proc_name, "LINES   ") == 0)
		wind_gets = 0, gclk = clock();
#endif

	DIAG((D.appl,-1,"Init client '%s' pid=%d, client_end=%d, kernel_end=%d\n", client->proc_name, client->pid, client->client_end, client->kernel_end));

	client->init = true;
	return XAC_DONE;	/* We now unblock the client, 'coz we've setup our end */
}

short owner_top_wm(void);

static
void remove_wind_refs(XA_WINDOW *wl, XA_CLIENT *client)
{
	while (wl)
	{
		if (wl->pid == client->pid)
		{
			XA_WIDGET *wt;
			
			remove_widget(0, wl, XAW_TOOLBAR);
			remove_widget(0, wl, XAW_MENU   );

			wl->tree_info.tree = nil;
			wl->redraw = nil;		/* only used for client desktop */
		}
		wl = wl->next;
	}
}

/* HR 100701: remove all references to a clients memory. */
global
void remove_refs(XA_CLIENT *client, bool secure)
{
	XA_TREE *menu_bar = root_window->widgets[XAW_MENU].stuff;
	
	DIAGS(("remove_refs: rwpid = %d mtree %lx %s\n",
		root_window->pid, client->std_menu.tree, secure ? "secure" : ""));

	root_window->pid = C.AESpid;

	if (client->std_menu.tree)
		if (client->std_menu.tree == menu_bar->tree)
			*menu_bar = C.Aes->std_menu;

	client->std_menu.tree = nil;

	if (secure)			/* Not called from within signal handler. */
	{
		remove_wind_refs(window_list, client);
		remove_wind_refs(S.closed_windows.first, client);
	}

	if (client->desktop)
		if (get_desktop() == client->desktop)
		{
			set_desktop(C.Aes->desktop);
			client->desktop = nil;
		}

	remove_client_handle(client);
	client->killed = true;
	client->secured = secure;
}

/*
 *	Close down the client reply pipe in response to an XA_CLIENT_EXIT message
 *     HR: No!! it doesnt!
 *	- Also does a tidy-up and deletes all the clients windows (in case some untidy programs
 *	  fail to close them for themselves).
 *	- Also disposes of any pending messages.
 *
 */
global
AES_function XA_client_exit	/* (LOCK lock, XA_CLIENT *client, nil) */
{
	short top_owner;

#if MEASURE_LINES_APP
	if (strcmp(client->proc_name, "LINES   ") == 0)
	{
		long clock(void);
		short do_form_alert(LOCK lock, short default_button, char *alert, short owner);
		char al[512]; long cdif = clock() - gclk;
		long psec = (wind_gets*1000)/(cdif*5);
		sdisplay(al,"LINES_APP= wind_gets : %ld, clock %ld, :: %ld", wind_gets, cdif, psec);
		put_env(lock, 1, 0, al);
	}
#endif

	DIAG((D.appl,-1,"XA_client_exit: '%s'(%d) %s\n",
	       client->proc_name, client->pid, client->killed ? "killed" : ""));

	/* Because of the window list, these cannot be done in the signal handler. */
	if (!client->secured)
	{
		remove_wind_refs(window_list, client);
		remove_wind_refs(S.closed_windows.first, client);
	}

/* Go through and check that all windows belonging to this client are closed */
	wind_new(lock, client->pid);

	top_owner = window_list->pid;

/* Dispose of any pending messages for the client */

	while (client->msg)		/* HR */
	{
		XA_AESMSG_LIST *nm = client->msg->next;
		free(client->msg);
		client->msg = nm;
	}

	if (client->attach)				/* if menu attachments */
	{
#if GENERATE_DIAGS
		if (!client->killed)
		{
			XA_MENU_ATTACHMENT *at = client->attach;
			while (at->text)
			{
				DIAGS(("text left in attachments '%s'\n", at->text));
				at++;
			}
		}
#endif
		free(client->attach);
		client->attach = nil;
	}


	{
		XA_TREE *menu_bar, *new_menu;
		XA_CLIENT *new = Pid2Client(top_owner);

		menu_bar = root_window->widgets[XAW_MENU].stuff;

		DIAGS((" -= top_owner %d, menu_bar %lx =-\n", top_owner, menu_bar));

/* HR: std_menu is now widget tree */
/* HR 030401: It doesnt matter if the menu bar wasnt removed,
              there must be a swap anyhow.  */

		new_menu = &new->std_menu;
		DIAGS((" -= new_menu %lx =-\n", new_menu));

		if (new_menu->tree == nil)				/* HR: must check tree. */
			*menu_bar = *find_menu_bar(lock);

/* Did the exiting app forget to remove a custom desktop? */
/* HR 160701: It doesnt matter if the desktop wasnt removed. */

		new = Pid2Client(menu_bar->pid);
		if (new->desktop == nil)
			new = find_desktop(lock);
		set_desktop(new->desktop);
		root_window->pid = new->pid;
		root_window->owner = new;

		display_non_topped_window(lock, 71, root_window, nil);

		DIAG((D.appl,-1,"top_owner: %d, menu_owner: %d, focus->owner: %d\n",
		                 top_owner, menu_bar->pid, C.focus->pid));
		if (top_owner == menu_bar->pid and window_list != root_window)
		{
			C.focus = window_list;
			display_window(lock, window_list);  /* This mainly to get the title displayed correctly. */
		}
	}

/* If the client forgot to free its resources, we do it for them. */
	DIAG((D.appl, client->pid, "Freeing client xmalloc base\n"));
	XA_free_all(&client->base, -1, -1);		/* HR: free all blocks allocated on behalf of the client. */
	client->std_resource = nil;
	client->resources = nil;
	
	/* Free command tail and name *only if* they were malloced: */
	/* HR dont compare with a pointer!!!! */
	if (client->heap_tail)		/* HR what if another constant was used? */
	{
		free(client->cmd_tail);
		client->cmd_tail = nil;
		client->heap_tail = false;
	}

	if (client->heap_name)
	{
		free(client->cmd_name);
		client->cmd_name = nil;
		client->heap_name = false;
	}

	if (S.update_lock == client->pid)
	{					/* Unlock mouse & screen */
		S.update_lock = 0;
		S.update_cnt = 0;
	}

	if (S.mouse_lock == client->pid)
	{
		S.mouse_lock = FALSE;
		S.mouse_cnt = 0;
	}

	/* HR: FreeClient() theoratically destroys all information about a client. */
	/* so we postpone the physical destruction until SIGCHILD */

#if 0	/* HR: See also XA_appl_exit; Here it is under the wrong pid. :-) */
	if (client->client_end)
	{
		Fclose(client->client_end);
		client->client_end = 0;  	/* Do not reenter */
	}
#endif

	client->init = false;
	DIAG((D.appl,-1,"client exit done\n"));
	return XAC_DONE;	 	/* Closed down, let the client move on & exit */
}

