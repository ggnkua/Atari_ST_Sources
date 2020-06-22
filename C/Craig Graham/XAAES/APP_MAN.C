/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <OSBIND.H>
#include <FILESYS.H>
#include <MINTBIND.H>
#include <SIGNAL.H>
#include "XA_DEFS.H"
#include "XA_TYPES.H"
#include "XA_GLOBL.H"
#include "K_DEFS.H"
#include "XA_CODES.H"
#include "NEW_CLNT.H"
#include "C_WINDOW.H"
#include "DESKTOP.H"
#include "SYSTEM.H"
#include "RESOURCE.H"
#include "STD_WIDG.H"

/*
	Application Manager
	This module handles various ways of swapping the current application...
*/

short dead_exit_contrl[]={XA_CLIENT_EXIT,0,0,0,0};
AESPB dead_client_pb;

/*
	Go round and check whether any clients have died & we didn't notice.
	- Useful for cleaning up clients that weren't launched via a shell_write.
*/
void find_dead_clients(void)
{
	short app;
	long r;
	K_CMD_PACKET dead_client_packet;
	XA_CLIENT *client;
	
	for(app=0; app<MAX_PID; app++)
	{
		client=Pid2Client(app);
		if (client)
		{
			if ((app!=AESpid)&&(client->clnt_pipe_rd))		/* Is this a valid application? */
			{
				r=Pkill(app,SIGNULL);	/* poll to see if the client has died since we last looked.... */
	
				if (r)
				{
					Pwait3(1,NULL);

					DIAGS(("Dead client [%s:pid=%d] - cleaning up\n",clients[app].name,app));
				
					dead_client_pb.contrl=dead_exit_contrl;	/* If client is dead, send ourselves a message to clean up.... */
					dead_client_packet.pid=app;				/* client pid */
					dead_client_packet.cmd=AESCMD_NOREPLY;	/* no reply */
					dead_client_packet.pb=&dead_client_pb;	/* pointer to AES parameter block */

					XA_client_exit(app,&dead_client_pb);	/* Run the application exit cleanup */
				
					Fclose(client->clnt_pipe_wr);			/* Close the kernal end of client reply pipe */
					client_handle_mask&=~(1L<<client->clnt_pipe_wr);
				
					client->clnt_pipe_wr=client->clnt_pipe_rd=0; 
				}
			}
		}
	}
}

/*
	Attempt to recover a system that has locked up
*/
void recover(void)
{
	K_CMD_PACKET dead_client_packet;
	long r;
	
	DIAGS(("Attempting to recover control.....\n"));

	if ((update_lock)&&(update_lock!=AESpid))
	{
		DIAGS(("Killing owner of update lock\n"));
		r=Pkill(update_lock,SIGKILL);
	}
	
	if (((mouse_lock)&&(mouse_lock!=update_lock))&&(mouse_lock!=AESpid))
	{
		DIAGS(("Killing owner of mouse lock\n"));
		r=Pkill(mouse_lock,SIGKILL);
	}
	
	v_show_c(V_handle, 0);
}

/*
	Swap the main root window's menu-bar to be the next application's
	(cycle's which app own's the main menu-bar).
	NOTE: This only swap's the menu-bar, it doesn't swap the topped window.
*/
void next_app_menu(void)
{
	XA_WIDGET_TREE *menu_bar=(XA_WIDGET_TREE*)(root_window->widgets[XAW_MENU].stuff);
	short next_app,start_app;
	
	start_app=menu_bar->owner;
	
	next_app=start_app+1;
	
	do {
		if (next_app>=MAX_PID)
			next_app=0;
			
		if ((clients[next_app].clnt_pipe_rd)||(next_app==AESpid))	/* Valid client ? */
		{
			if (clients[next_app].std_menu!=menu_bar->tree)	/* Different menu? */
			{
				GRECT clip;
		
				menu_bar->tree=clients[next_app].std_menu;
				
				if (clients[next_app].std_menu==clients[AESpid].std_menu)
					menu_bar->owner=AESpid;		/* Apps with no menu get the default menu, and that's owned by the AES */
				else
					menu_bar->owner=next_app;	/* Apps with menu's own their own menu */
			
				rp_2_ap(root_window, root_window->widgets+XAW_MENU, &clip.g_x, &clip.g_y);

				clip.g_w=root_window->widgets[XAW_MENU].w;
				clip.g_h=root_window->widgets[XAW_MENU].h;

				v_hide_c(V_handle);
				display_non_topped_window(root_window,&clip);
				v_show_c(V_handle,1);
			}else{											/* Same menu, just a different owner... */
				menu_bar->owner=next_app;
			}
			
			if ((clients[next_app].desktop)					/* Change desktops? */
				&&((clients[next_app].desktop!=desktop)&&(clients[next_app].desktop!=ResourceTree(system_resources,DEF_DESKTOP))))
			{
				set_desktop(clients[next_app].desktop);
				root_window->owner=next_app;

				v_hide_c(V_handle);
				display_non_topped_window(root_window,NULL);
				v_show_c(V_handle,1);
			}
			
			return;
		}
		next_app++;
	} while (next_app!=start_app);

}

void list_apps(void)
{
	short f;
	
	DIAGS(("========== XaAES Client Applications List ===========\n"));
	
	for(f=0; f<MAX_PID; f++)
	{
		if (clients[f].clnt_pipe_rd)
		{
			DIAGS(("%d:%s..Wait[",f,clients[f].name));
			if (clients[f].waiting_for&XAWAIT_BUTTON)
				DIAGS(("B"));
			if (clients[f].waiting_for&XAWAIT_KEY)
				DIAGS(("K"));
			if (clients[f].waiting_for&XAWAIT_MOUSE1)
				DIAGS(("1"));
			if (clients[f].waiting_for&XAWAIT_MOUSE2)
				DIAGS(("2"));
			if (clients[f].waiting_for&XAWAIT_MESSAGE)
				DIAGS(("M"));
			if (clients[f].waiting_for&XAWAIT_TIMER)
				DIAGS(("T"));
			if (clients[f].waiting_for&XAWAIT_CHILD)
				DIAGS(("C"));
			if (clients[f].waiting_for&XAWAIT_MULTI)
				DIAGS(("{MULTI}"));
			DIAGS(("]:AESparent=%d",clients[f].parent));
			if (clients[f].std_menu)
				DIAGS((":HasMenubar"));
			if (((XA_WIDGET_TREE*)root_window->widgets[XAW_MENU].stuff)->owner==f)
				DIAGS(("(current)"));
			if (clients[f].desktop)
				DIAGS((":OwnsDesktop"));
			if (clients[f].msg)
				DIAGS((":MsgPending"));
			if (mouse_lock==f)
				DIAGS((":OwnsMouseLock"));
			if (update_lock==f)
				DIAGS((":OwnsUpdateLock"));
			
			DIAGS(("\n"));
		}
	}
}

void status_dump(void)
{
	DIAGS(("========== XaAES Status ===========\n"));

	DIAGS(("AESpid=%d\n",AESpid));
	
	DIAGS(("Display Device: P_handle=%d, V_handle=%d\n",P_handle,V_handle));
	DIAGS((" size=[%d,%d], colours=%d, bitplanes=%d\n",display.w,display.h,display.colours,display.planes));

	DIAGS(("mouse_lock=%d, mouse_cnt=%d\n",mouse_lock,mouse_cnt));
	DIAGS(("updae_lock=%d, update_cnt=%d\n",update_lock,update_cnt));
	
	DIAGS(("root window menu : owner=%d\n",((XA_WIDGET_TREE*)root_window->widgets[XAW_MENU].stuff)->owner));
}