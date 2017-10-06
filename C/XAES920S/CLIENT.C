/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

/* HR dec 1999 Henk Robbers: dynamic client pool */

#include <mintbind.h>

#include "xa_types.h"
#include "xa_globl.h"

#include "menuwidg.h"

/*
 *	Client list handling
*/
global
bool is_client(XA_CLIENT *client)
{
	return client->client_end != 0 and client->pid > 0 and client->pid != C.AESpid;
}

#if GENERATE_DIAGS
global
XA_CLIENT *pid2client(short pid, char *f, int l)
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
XA_CLIENT *pid2client(short pid)		/* If its not a macro */
{
	XA_CLIENT *client;
	client = S.Clients[(pid >= 0 or pid < MAX_PID) ? pid : 0];
	return client;
}
#endif

global
void NoClient(XA_CLIENT *client)
{
	if (client)
	{
		client->client_end = 0;			/* HR */
		client->kernel_end = 0;			/* You must save this one before calling! */
		client->init = false;
		client->pid = 0;
		client->cmd_tail = "\0";
		client->heap_tail = false;
		client->cmd_name = "";
		client->heap_name = false;
		client->std_resource = nil;
		client->resources = nil;
		client->zen = nil;
		client->wt.edit_obj = -1;
		client->wt.edit_pos = 0;
		client->desktop = nil;
		client->half_screen = false;
		*client->proc_name = 0;
		*client->name = 0;
		client->attach = nil;
	} else
	{
		DIAGS(("Clients array corrupted\n"));
	}
}

global
XA_CLIENT *NewClient(short clnt_pid)
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
			XA_set_base(&new->base, 16384, MX_PREFTTRAM);
		else
			XA_set_base(&new->base, 16384, MX_GLOBAL | MX_PREFTTRAM);
		S.Clients[clnt_pid] = new;
	}
	return new;
}

global
void FreeClient(LOCK lock, XA_CLIENT *client)
{
	XA_CLIENT *check;
	short pid = client->pid;

	if (pid < 0 or pid >= MAX_PID)
		return;

	if unlocked(clients)
		Sema_Up(CLIENTS_SEMA);

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

/* HR: If no client using the half screen buffer is left, free it! */
#if HALFSCREEN
	if (cfg.half_screen_buffer)
	{
		client = S.client_list;
		while (client)
		{
			if (client->half_screen)
				break;
			client = client->next;
		}
		if (!client)
		{
			Mfree(cfg.half_screen_buffer);
			cfg.half_screen_buffer = nil;
		}
	}
#endif

	if unlocked(clients)
		Sema_Dn(CLIENTS_SEMA);
}
