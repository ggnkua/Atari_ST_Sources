/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <FILESYS.H>
#include <OSBIND.H>
#include <MINTBIND.H>
#include <stdio.h>
#include <memory.h>
#include "XA_DEFS.H"
#include "XA_TYPES.H"
#include "XA_GLOBL.H"
#include "C_WINDOW.H"
#include "SYSTEM.H"
#include "RESOURCE.H"
#include "events.h"
#include "DESKTOP.H"

/*
	Open the clients comms pipe in response to an XA_NEW_CLIENT message
*/
unsigned long XA_new_client(short clnt_pid,AESPB *pb)
{
	char pipe_name[50];
	char fmt[]="u:\\pipe\\XaClnt.%d\0";
	short f;
	XA_CLIENT *client=Pid2Client(clnt_pid);

	if (!client->clnt_pipe_rd)	/* If this occurs, then we've got a problem */
	{
		DIAGS(("New Client - Error: client pipe does not exist yet?\n"));
		/* PANIC - opening a global handle won't help because global
			handles can't be used in an Fselect mask... */
		return XAC_BLOCK ;
	}

	if (!client->clnt_pipe_wr)
	{
		sprintf(pipe_name,fmt,clnt_pid);						/* Open the clients reply pipe for writing to */
		client->clnt_pipe_wr=(int)Fopen(pipe_name,O_RDWR);		/* Kernals end of pipe*/
		client_handle_mask|=1L<<(client->clnt_pipe_wr);
	}
	
	client->std_menu=ResourceTree(system_resources,SYSTEM_MENU);

	sprintf(client->name,"Foreign client ?");
	sprintf(client->proc_name,"XACLIENT");

	for(f=0; ((client->cmd_name[f]!='\0')&&(client->cmd_name[f]!='.'))&&(f<8); f++)
		client->proc_name[f]=client->cmd_name[f];
	
	for(; f<8; f++)
		client->proc_name[f]=' ';

	client->proc_name[8]='\0';

	return XAC_DONE;	/* We now unblock the client, 'coz we've setup our end */
}

/*
	Close down the client reply pipe in response to an XA_CLIENT_EXIT message
	- also does a tidy-up and delete's all the clients windows (in case some untidy programs
	  fail to close them for themselves).
	- also disposes of any pending messages.
*/
unsigned long XA_client_exit(short clnt_pid,AESPB *pb)
{
	XA_WINDOW *wl,*dwl;
	XA_AESMSG_LIST *nm,*dnm;
	XA_WIDGET_TREE *menu_bar=(XA_WIDGET_TREE*)(root_window->widgets[XAW_MENU].stuff);
	XA_CLIENT *client=Pid2Client(clnt_pid);

#if 0
	Fclose(client->clnt_pipe_wr);	/* Close the kernal end of client reply pipe */
	client_handle_mask&=~(1L<<client->clnt_pipe_wr);

	client->clnt_pipe_wr=0;
#endif

/* Go through and check that all windows belonging to this client are */
/* closed and deleted (in case of sloppy programming). */
	for(wl=window_list; wl;)
	{
		if ((wl->owner==clnt_pid)&&(wl!=root_window))
		{
			dwl=wl;

			/* No need to redraw anything if window is already closed... */
			if (wl->is_open)
			{

				v_hide_c(V_handle);
			
				display_windows_below(wl);				/* Redisplay any windows below the one we are closing */
			
				v_show_c(V_handle, 1);
			}
			
			wl=wl->next;
			
			if (window_list==dwl)					/* Actually delete the window */
				window_list=dwl->next;

			if (dwl->prev) dwl->prev->next=dwl->next;
			if (dwl->next) dwl->next->prev=dwl->prev;

			free(dwl);
		}else{
			wl=wl->next;
		}
	}

/* Dispose of any pending messages for the client */
	for(nm=client->msg; nm;)
	{
		dnm=nm;
		nm=nm->next;
		free(dnm);
	}
	client->msg=NULL;

/* If the client forgot to remove it's menu bar, better do it now */
	if (menu_bar->tree==client->std_menu)
	{
		menu_bar->tree=ResourceTree(system_resources,SYSTEM_MENU);
		menu_bar->owner=AESpid;
		v_hide_c(V_handle);
		display_non_topped_window(root_window,NULL); 
		v_show_c(V_handle,1);
	}

/* Did the exiting app forget to remove a custom desktop? */
	if ((desktop==client->desktop)&&(desktop!=ResourceTree(system_resources,DEF_DESKTOP)))
	{
		set_desktop(Pid2Client(menu_bar->owner)->desktop);

		v_hide_c(V_handle);
		display_non_topped_window(root_window,NULL);
		v_show_c(V_handle,1);
	}

#if 0
/* If the client forgot to free it's resources, we do it for them. */
	if (client->std_resource)
	{
		FreeResources(client->std_resource);
		clients->std_resource=NULL;
	}
#endif

	/* Free command tail and name *only if* they were malloced: */
	if (client->cmd_tail != dummy_cmd_tail)
		free(client->cmd_tail);
	if (client->cmd_name != dummy_cmd_name)
		free(client->cmd_name);

	client->std_resource=NULL;
	client->cmd_tail=(char*)dummy_cmd_tail;
	client->cmd_name=(char*)dummy_cmd_name;
	client->zen=NULL;
	client->desktop=NULL;
	
	if (update_lock==clnt_pid)					/* unlock mouse & screen */
	{
		update_lock=FALSE;
		update_cnt=0;
	}

	if (mouse_lock==clnt_pid)
	{
		mouse_lock=FALSE;
		mouse_cnt=0;
	}

#if 0		/* Zombies are cleaned up by the child signal handler... */
	Pwait3(1,NULL);
#endif

	return XAC_DONE;	/* Closed down, let the client move on & exit */
}
