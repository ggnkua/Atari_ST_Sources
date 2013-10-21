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

#include <fcntl.h>
#include <mintbind.h>
#include <string.h>

#include "xa_types.h"
#include "xa_globl.h"

#include "xalloc.h"
#include "c_window.h"
#include "rectlist.h"
#include "desktop.h"
#include "menuwidg.h"
#include "widgets.h"
#include "xa_rsrc.h"
#include "xa_shel.h"
#include "xa_clnt.h"
#include "app_man.h"
#include "taskman.h"

/*
 *	Client list handling
*/
global
bool is_client(XA_CLIENT *client)
{
	return     client						/* HR 021101 */
	       and client->client_end != 0
	       and client->pid > 0
	       and client->pid != C.AESpid;
}

#if GENERATE_DIAGS
global
XA_CLIENT *pid2client(int pid, char *f, int l)
{
	XA_CLIENT *client = nil;

	if (pid > 0 and pid < MAX_PID)
		client = S.Clients[pid];
	else
		display("** Invalid pid:%d, %s, %d\n",pid,f,l);

	return client;
}
#else
global
XA_CLIENT *pid2client(int pid)		/* If its not a macro */
{
	XA_CLIENT *client;
	client = S.Clients[(pid >= 0 or pid < MAX_PID) ? pid : 0];
	return client;
}
#endif

static
void NoClient(XA_CLIENT *client)
{
	if (client)
	{
		client->client_end = 0;			/* HR */
		client->kernel_end = 0;			/* You must save this one before calling! */
		client->init = false;
		client->pid = 0;
		client->cmd_tail = "\0";
		client->tail_is_heap = false;
		*client->cmd_name = 0;
		client->rsrc = nil;
		client->resources = nil;
		client->fmd.wind = nil;			/* HR 250602: fmd */
		client->fmd.state = 0;
		client->wt.edit_obj = -1;
		client->wt.edit_pos = 0;
		client->desktop.tree = nil;
		client->half_screen_buffer = nil;
		*client->proc_name = 0;
		*client->name = 0;
		client->attach = nil;
	} else
	{
		DIAGS(("Clients array corrupted\n"));
	}
}

global
XA_CLIENT *NewClient(int clnt_pid)
{
	XA_CLIENT *new, *last = S.client_list;

	if (clnt_pid < 0 or clnt_pid >= MAX_PID)
	{
		display("** Invalid new client; pid=%d\n",clnt_pid);
		return nil;
	}

	new = xcalloc(1, sizeof(*new), 110);

	if (new)
	{
		NoClient(new);
		new->options = default_options;
		if (!S.client_list)			/* also used for the 1st client !! (Aes itself) */
		{
			S.client_list = new;
			new->prior = nil;
		}
		else
		{
			while (last->next)	/* find last of list */
				last = last->next;
			last->next = new;	/* add new */
			new->prior = last;
		}
		new->next = nil;			/* it is the last of the list */
		new->pid = clnt_pid;
		if (clnt_pid == C.AESpid)
			XA_set_base(&new->base, 16384, -1, MX_PREFTTRAM);
		else
			XA_set_base(&new->base, 16384, -1, MX_GLOBAL | MX_PREFTTRAM);
		S.Clients[clnt_pid] = new;
	}
	return new;
}

global
void FreeClient(LOCK lock, XA_CLIENT *client)
{
	XA_CLIENT *check;
	int pid = client->pid;

	if (pid < 0 or pid >= MAX_PID)
		return;

	Sema_Up(clients);

	check = S.client_list;
	while (check)
		if (check != client)
			check = check->next;
		else
			break;
		
	if (check)
	{
		if (!client->killed)
			remove_attachments(lock|clients, client, client->std_menu.tree);
		if (client == S.client_list)
			S.client_list = client->next;
		if (client->prior)
			client->prior->next = client->next;
		if (client->next)
			client->next->prior = client->prior;
		NoClient(client);
		free(client);
		S.Clients[pid] = nil;
	}

/* HR: If no client using the quart screen buffer is left, free it! */
#if HALF_SCREEN
	if (client->half_screen_buffer)
	{
		Mfree(client->half_screen_buffer);
		client->half_screen_buffer = nil;
	}
#endif

	Sema_Dn(clients);
}

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
char *chsuf(char *f, char *suf)		/* suf incl '.' */
{
	char *pt;
	static Path s;

	strcpy(s,f);
	if ((pt = strrchr(s,'.')) != 0)
		if ( strchr (pt,slash) == 0)
		{
			strcpy(pt,suf);		/* er is een suf */
			return s;
		}
	strcat(s,suf);
	return s;
}

global
void pname_to_string(char *to, char *name)
{
	int i = 8;
	strcpy(to, name);
	while (i)
	{
		if (to[i] == ' ' || to[i] == 0)
			to[i] = 0;
		else
			break;
		i--;
	}
}

/*
display("Options:\n");
for (i = 0; i < D_max; i++)
	display("i %d = %d\n", i, client->options.point[i]);
*/

global
void get_app_options(XA_CLIENT *client)
{
	OPT_LIST *op = S.app_options;
	char proc_name[10]; int i;
	
	pname_to_string(proc_name, client->proc_name);
	DIAGS(("get_app_options '%s'\n", proc_name));
	while (op)
	{
		if (   stricmp(proc_name,        op->name) == 0
		    || stricmp(client->name + 2, op->name) == 0
		   )
		{
			client->options = op->options;
			DIAGS(("Found '%s'\n", op->name));
			break;
		}
		op = op->next;
	}
}

global
char *get_procname(short pid)
{
#include "ipff.h"
/*	static
*/	Path name;
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
	char *fmt = "u:" sbslash "pipe" sbslash "XaClnt.%d\0";
	char *pname;
	short f;  long clock(void);

DIAG((D_appl,nil,"XA_new_client for %d\n",client->pid));
DIAG((D_appl,nil," - client_end %d\n",client->client_end));

	if (!client->client_end)	/* If this occurs, then we've got a problem */
	{
		DIAG((D_appl,nil,"Init client - Error: client pipe does not exist yet?\n"));
		/* PANIC - opening a global handle won't help because global
			handles can't be used in an Fselect mask... */
		return XAC_BLOCK ;
	}

DIAG((D_appl,nil," - kernel_end %d\n",client->kernel_end));
	if (!client->kernel_end)
	{
		sdisplay(pipe_name, fmt, client->pid);						/* Open the clients reply pipe for writing to */
		client->kernel_end = Fopen(pipe_name, O_RDWR|O_DENYNONE);		/* Kernal's end of pipe*/
		insert_client_handle(client);
	}

/*	HR 040401: This field must be nil if no menu bar.
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
		get_app_options(client);				/* HR 240901: Individual option settings. */
		DIAGS(("get_procname for %d: '%s'\n",client->pid, client->proc_name));
	}
#if 0
	else if (*client->cmd_name)
		isolate_procname(client)
#endif
	sdisplay(client->name, "  %s", client->proc_name);  /* awaiting menu_register */
	update_tasklist(lock);				/* HR 250102 */

#if MEASURE_LINES_APP
	if (strcmp(client->proc_name, "LINES   ") == 0)
		wind_gets = 0, gclk = clock();
#endif

	DIAG((D_appl,nil,"Init client '%s' pid=%d, client_end=%d, kernel_end=%d\n", client->proc_name, client->pid, client->client_end, client->kernel_end));

	client->init = true;
	return XAC_DONE;	/* We now unblock the client, 'coz we've setup our end */
}

short owner_top_wm(void);

static
void remove_wind_refs(XA_WINDOW *wl, XA_CLIENT *client)
{
	while (wl)
	{
		if (wl->owner == client)
		{			
			remove_widget(0, wl, XAW_TOOLBAR);
			remove_widget(0, wl, XAW_MENU   );
			wl->redraw = nil;
		}
		wl = wl->next;
	}
}

/* HR 100701: remove all references to a clients memory. */
global
void remove_refs(XA_CLIENT *client, bool secure)
{
	XA_TREE *menu_bar = get_menu();
	
	DIAGS(("remove_refs for %s mtree %lx %s\n",
		c_owner(client), client->std_menu.tree, secure ? "secure" : ""));

	root_window->owner = C.Aes;

	if (client->std_menu.tree)
		if (client->std_menu.tree == menu_bar->tree)
			*menu_bar = C.Aes->std_menu;

	client->std_menu.tree = nil;

	if (secure)			/* Not called from within signal handler. */
	{
		remove_wind_refs(window_list, client);
		remove_wind_refs(S.closed_windows.first, client);
	}

	if (client->desktop.tree)
		if (get_desktop()->tree == client->desktop.tree)
		{
			set_desktop(&C.Aes->desktop);
			client->desktop.tree = nil;
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
	XA_CLIENT *top_owner, *new;

#if MEASURE_LINES_APP
	if (strcmp(client->proc_name, "LINES   ") == 0)
	{
		long clock(void);
		char al[512]; long cdif = clock() - gclk;
		long psec = (wind_gets*1000)/(cdif*5);
		sdisplay(al,"LINES_APP= wind_gets : %ld, clock %ld, :: %ld", wind_gets, cdif, psec);
		put_env(lock, 1, 0, al);
	}
#endif

	DIAG((D_appl,nil,"XA_client_exit: %s %s\n", c_owner(client), client->killed ? "killed" : ""));

	/* Because of the window list, these cannot be done in the signal handler. */
	if (!client->secured)
	{
		remove_wind_refs(window_list, client);
		remove_wind_refs(S.closed_windows.first, client);
	}

/* Go through and check that all windows belonging to this client are closed */
	remove_windows(lock, client);

	top_owner = window_list->owner;

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
			while (at->to_tree)
			{
				DIAGS(("tree left in attachments %lx\n", at->to_tree));
				at++;
			}
		}
#endif
		free(client->attach);
		client->attach = nil;
	}

	new = top_owner;

#if 1
	app_in_front(lock, new);

#else
	if (any_hidden(lock, new))			/* HR 150102: unhide the new app. */
		app_in_front(lock, new);
	else
	{
		XA_TREE *menu_bar, *new_menu;

		menu_bar = get_menu();

		DIAGS((" -= top_owner %d, menu_bar %lx =-\n", top_owner->pid, menu_bar));

/* HR: std_menu is now widget tree */
/* HR 030401: It doesnt matter if the menu bar wasnt removed,
              there must be a swap anyhow.  */

		new_menu = &new->std_menu;
		DIAGS((" -= new_menu %lx =-\n", new_menu));

		if (new_menu->tree == nil)				/* HR: must check tree. */
			*menu_bar = *find_menu_bar(lock);
		else
			*menu_bar = *new_menu;

/* Did the exiting app forget to remove a custom desktop? */
/* HR 160701: It doesnt matter if the desktop wasnt removed. */

		new = menu_bar->owner;
		if (new->desktop.tree == nil)
			new = find_desktop(lock);
		set_desktop(&new->desktop);

		display_window(lock, 71, root_window, nil);

		DIAG((D_appl,nil,"top_owner: %d, menu_owner: %d, focus->owner: %d\n",
		                 top_owner->pid, menu_bar->owner->pid, focus_owner()->pid));
		if (top_owner == menu_bar->owner and window_list != root_window)
		{
			C.focus = window_list;
			display_window(lock, 72, window_list, nil);  /* This mainly to get the title displayed correctly. */
		}
	}
#endif

/* If the client forgot to free its resources, we do it for him. */
	DIAG((D_appl, nil, "Freeing client xmalloc base\n"));
	XA_free_all(&client->base, -1, -1);		/* HR: free all blocks allocated on behalf of the client. */
	client->rsrc = nil;
	client->resources = nil;
	
	/* Free name *only if* it is malloced: */
	/* HR dont compare with a pointer!!!! */
	if (client->tail_is_heap)		/* HR what if another constant was used? */
	{
		free(client->cmd_tail);
		client->cmd_tail = nil;
		client->tail_is_heap = false;
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
	DIAG((D_appl,nil,"client exit done\n"));
	return XAC_DONE;	 	/* Closed down, let the client move on & exit */
}

