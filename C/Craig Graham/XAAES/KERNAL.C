/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <OSBIND.H>
#include <FILESYS.H>
#include <MINTBIND.H>

#ifdef __PUREC__
#include <sys\types.h>
#else
#include <sys/types.h>
#endif

#include <memory.h>
#include "K_DEFS.H"
#include "KERNAL.H"
#include "XA_GLOBL.H"
#include "XA_CODES.H"
#include "XA_DEFS.H"
#include "APP_MAN.H"
#include "APPL_INI.H"
#include "APPL_WRT.H"
#include "APPLSEAR.H"
#include "NEW_CLNT.H"
#include "GETINFO.H"
#include "EVNT_BTN.H"
#include "EVNT_KBD.H"
#include "EVNT_MES.H"
#include "EVNT_MUL.H"
#include "EVNT_TMR.H"
#include "MOUSE_CL.H"
#include "WIND_FNS.H"
#include "GRAF_MOU.H"
#include "GRAF_BOX.H"
#include "GRAFGROW.H"
#include "KEYBOARD.H"
#include "RESOURCE.H"
#include "OBJC_DRW.H"
#include "OBJCEDIT.H"
#include "FORMS.H"
#include "FRM_ALRT.H"
#include "MENUBAR.H"
#include "SHELL.H"
#include "EXTEND.H"
#include "SCRAP.H"
#include "op_names.h"

far AESroutine Ktable[300];		/* The main AES kernal command jump table */
far short Kcall_direct[300];	/* array of flags to indicate that routines should be direct called */
far XA_CLIENT clients[MAX_PID+1];	/* The clients database */

short shutdown=FALSE;			/* When this gets set to true, the system will exit */

/*
	Kernal Message Handler

	This is responsible for accepting requests via the XaAES.cmd pipe and
	sending (most) replies via the client's reply pipe.
	
	We also get keyboard & mouse input data here.
*/
extern unsigned long client_handle_mask;

void kernal(void)
{
	unsigned short cmd;
	unsigned long rtn=XA_OK;
	short client_handle;
	AESPB *parms;
	MOUSE_DATA mdata;
	AESroutine cmd_routine;
	short clnt_pid;
	unsigned long repl;
	unsigned long input_channels;
	short fs_rtn,r,evnt_count=0;

/* Unlock the semaphores....we're ready to go */
	Psemaphore(3,APPL_INIT_SEMAPHORE,0);
	Psemaphore(3,TRAP_HANDLER_SEMAPHORE,0);
	Psemaphore(3,WIN_LIST_SEMAPHORE,0);
	Psemaphore(3,ROOT_SEMAPHORE,0);
	Psemaphore(3,CLIENTS_SEMAPHORE,0);
	Psemaphore(3,UPDATE_LOCK,0);
	Psemaphore(3,MOUSE_LOCK,0);

/* Main kernal loop */
	do {
		input_channels=1L<<KBD_device;					/* We are waiting on all these channels */
		input_channels|=1L<<AES_in_pipe;				/* This is only used for appl_init() now */
		input_channels|=1L<<MOUSE_in_pipe;
		input_channels|=client_handle_mask;				/* Clients send general requests via their own pipes now */
		
		fs_rtn=Fselect(3000,(long *)&input_channels,NULL,NULL);	/* Block via select() on the console & the */
																/* AES command pipe(s). */
		
		if ((!fs_rtn)||(evnt_count==5000))	/* Timeout - do some housekeeping */
		{
			
			evnt_count=0;
			find_dead_clients();
		
		}else{
			
			evnt_count++;
			
			if (input_channels&(1L<<KBD_device))		/* Did we get some keyboard input? */
			{
				do_keyboard();
			}
		
			if (input_channels&(1L<<MOUSE_in_pipe))		/* Did we get a mouse message? */
			{
				Fread(MOUSE_in_pipe, (long)sizeof(MOUSE_DATA), &mdata);	/* get Mouse data packet */
				XA_button_event(&mdata);								/* Call the mouse event handler */
			}
		
			input_channels&=(client_handle_mask|(1L<<AES_in_pipe));
			client_handle=0;
			
			while(input_channels)
			{
				do {
					input_channels=input_channels>>1;
					client_handle++;
				} while((!(input_channels&1L))&&(client_handle<32));
				
				r=Fread(client_handle, (long)sizeof(short), &clnt_pid);	/* pid of the client sending the command */

/* Quick check here to get round a bug in MiNT's Fselect when used with pipes (sometimes a pipe may be reported
   as having data ready for reading, when in-fact it hasn't). */
				if (r==sizeof(short))
				{
					Fread(client_handle, (long)sizeof(unsigned short),  &cmd);	/* command type */

					Fread(client_handle, (long)sizeof(AESPB*),  &parms);	/* get a pointer to AES parameter block */

#if GENERATE_DIAGS
					if (parms->contrl[0]<=MAX_NAMED_DIAG)
					{
/*						if (parms->contrl[0]!=XA_EVNT_MULTI)*/
							DIAGS(("cmd_pipe: pid=%d, %s [=%d]\n",clnt_pid, op_code_names[parms->contrl[0]],parms->contrl[0]));
					}else
						DIAGS(("cmd_pipe: pid=%d, op-code=%d\n",clnt_pid, parms->contrl[0]));
#endif

/* Call AES routine via jump table*/
					repl=XAC_DONE;
					if ((parms->contrl[0]>=0)&&(parms->contrl[0]<300))
					{
						cmd_routine=Ktable[parms->contrl[0]];
						if (cmd_routine!=NULL)		/* Do we support this op-code yet? */
						{
							repl=(*cmd_routine)(clnt_pid,parms);
							rtn=XA_OK;
						}else{
							DIAGS(("cmd_pipe: pid:%d, Opcode not implemented\n",clnt_pid));
							DIAGS(("          op-code=%d\n",parms->contrl[0]));
							rtn=XA_UNIMPLEMENTED;	/* Unimplemented functions :( */
						}
					}else{
						DIAGS(("XaAES: illegal AES opcode=%d\n",parms->contrl[0]));
						rtn=XA_ILLEGAL;				/* Illegal op-code - these may be caused by bugs in the client program */
					}
		
/* If client wants a reply, send it one - standard GEM programs will always do this, 
   but XaAES aware programs don't always need to (depends if they are going to use the reply I suppose)
   Some op-codes (evnt_multi for instance) will want to leave the client blocked until an event occurs.
   I've added some extra blocking modes to support better timeouts..... */
					if ((cmd!=AESCMD_NOREPLY)&&(repl!=XAC_BLOCK))
					{
						r=repl&0xf;
						switch(r)
						{
							case XAC_T_TIMEOUT:
								rtn=XA_T_WAIT|(repl&XAC_TVAL);
								break;
							case XAC_M_TIMEOUT:
								rtn=XA_M_WAIT|(repl&XAC_TVAL);
								break;
							default:
								break;
						}
						Fwrite(clients[clnt_pid].clnt_pipe_wr,sizeof(unsigned long),&rtn);
					}
				}
			}
		}
		
	}while(!shutdown);
}

/*
	Setup the AES kernal jump table
*/

void setup_k_function_table(void)
{
	short f;
	for(f=0; f<300; f++)
	{
		Ktable[f]=NULL;
		Kcall_direct[f]=FALSE;
	}

/* appl_ class functions */
	Ktable[XA_APPL_INIT]=&XA_appl_init;
	Ktable[XA_APPL_EXIT]=&XA_appl_exit;
	Ktable[XA_APPL_GETINFO]=&XA_appl_getinfo;
	Ktable[XA_APPL_FIND]=&XA_appl_find;
	Ktable[XA_APPL_WRITE]=&XA_appl_write;
	Ktable[XA_APPL_SEARCH]=&XA_appl_search;
	Kcall_direct[XA_APPL_INIT]=TRUE;		/* Must always call appl_init/exit directly */
	Kcall_direct[XA_APPL_EXIT]=TRUE;
	
/* Form handlers (form_ xxxx) */
	Ktable[XA_FORM_ALERT]=&XA_form_alert;
	Ktable[XA_FORM_ERROR]=&XA_form_error;
	Ktable[XA_FORM_CENTER]=&XA_form_center;
	Ktable[XA_FORM_DIAL]=&XA_form_dial;
	Ktable[XA_FORM_BUTTON]=&XA_form_button;
	Ktable[XA_FORM_DO]=&XA_form_do;
	Ktable[XA_FORM_KEYBD]=&XA_form_keybd;

/* Event handlers (evnt_ xxx) */
	Ktable[XA_EVNT_BUTTON]=&XA_evnt_button;
	Ktable[XA_EVNT_KEYBD]=&XA_evnt_keybd;
	Ktable[XA_EVNT_MESAG]=&XA_evnt_mesag;
	Ktable[XA_EVNT_MULTI]=&XA_evnt_multi;
	Ktable[XA_EVNT_TIMER]=&XA_evnt_timer;
	CALL_DIRECT(XA_EVNT_BUTTON);
	CALL_DIRECT(XA_EVNT_KEYBD);
	CALL_DIRECT(XA_EVNT_TIMER);

/* graf_ class functions */
	Ktable[XA_GRAF_RUBBERBOX]=&XA_graf_rubberbox;
	Ktable[XA_GRAF_DRAGBOX]=&XA_graf_dragbox;
	Ktable[XA_GRAF_HANDLE]=&XA_graf_handle;
	Ktable[XA_GRAF_MOUSE]=&XA_graf_mouse;
	Ktable[XA_GRAF_MKSTATE]=&XA_graf_mkstate;
	Ktable[XA_GRAF_GROWBOX]=&XA_graf_growbox;
	Ktable[XA_GRAF_SHRINKBOX]=&XA_graf_growbox;
	Ktable[XA_GRAF_MOVEBOX]=&XA_graf_movebox;
	Ktable[XA_GRAF_WATCHBOX]=&XA_graf_watchbox;
	CALL_DIRECT(XA_GRAF_HANDLE);
	CALL_DIRECT(XA_GRAF_MOUSE);
	CALL_DIRECT(XA_GRAF_MKSTATE);
	CALL_DIRECT(XA_GRAF_MOVEBOX);
	CALL_DIRECT(XA_GRAF_GROWBOX);
	CALL_DIRECT(XA_GRAF_SHRINKBOX);

/* Window Handling (wind_ xxxx) */
	Ktable[XA_WIND_CREATE]=&XA_wind_create;
	Ktable[XA_WIND_OPEN]=&XA_wind_open;
	Ktable[XA_WIND_CLOSE]=&XA_wind_close;
	Ktable[XA_WIND_SET]=&XA_wind_set;
	Ktable[XA_WIND_GET]=&XA_wind_get;
	Ktable[XA_WIND_FIND]=&XA_wind_find;
	Ktable[XA_WIND_UPDATE]=&XA_wind_update;
	Ktable[XA_WIND_DELETE]=&XA_wind_delete;
	Ktable[XA_WIND_NEW]=&XA_wind_new;
	Ktable[XA_WIND_CALC]=&XA_wind_calc;
	CALL_DIRECT(XA_WIND_FIND);
	CALL_DIRECT(XA_WIND_GET);
	Kcall_direct[XA_WIND_UPDATE]=TRUE;	/* wind_update must ALWAYS be call direct
											as it uses semaphore locking */

/* Object Tree Handling (objc_ xxxx) */
	Ktable[XA_OBJC_DRAW]=&XA_objc_draw;
	Ktable[XA_OBJC_FIND]=&XA_objc_find;
	Ktable[XA_OBJC_OFFSET]=&XA_objc_offset;
	Ktable[XA_OBJC_CHANGE]=&XA_objc_change;
	Ktable[XA_OBJC_EDIT]=&XA_objc_edit;
	CALL_DIRECT(XA_OBJC_DRAW);
	CALL_DIRECT(XA_OBJC_FIND);
	CALL_DIRECT(XA_OBJC_OFFSET);
	CALL_DIRECT(XA_OBJC_CHANGE);
	
/* Resource Handling */
	Ktable[XA_RSRC_LOAD]=&XA_rsrc_load;
	Ktable[XA_RSRC_FREE]=&XA_rsrc_free;
	Ktable[XA_RSRC_GADDR]=&XA_rsrc_gaddr;
	Ktable[XA_RSRC_OBFIX]=&XA_rsrc_obfix;
	CALL_DIRECT(XA_RSRC_LOAD);
	CALL_DIRECT(XA_RSRC_FREE);
	CALL_DIRECT(XA_RSRC_GADDR);
	CALL_DIRECT(XA_RSRC_OBFIX);

/* Menu Bar Handling */
	Ktable[XA_MENU_BAR]=&XA_menu_bar;
	Ktable[XA_MENU_TNORMAL]=&XA_menu_tnormal;
	Ktable[XA_MENU_ICHECK]=&XA_menu_icheck;
	Ktable[XA_MENU_IENABLE]=&XA_menu_ienable;
	Ktable[XA_MENU_TEXT]=&XA_menu_text;
	Ktable[XA_MENU_REGISTER]=&XA_menu_register;
	CALL_DIRECT(XA_MENU_TNORMAL);
	CALL_DIRECT(XA_MENU_ICHECK);
	CALL_DIRECT(XA_MENU_IENABLE);

/* Shell  */
	Ktable[XA_SHELL_WRITE]=&XA_shell_write;
	Ktable[XA_SHELL_READ]=&XA_shell_read;
	Ktable[XA_SHELL_FIND]=&XA_shell_find;
	Ktable[XA_SHELL_ENVRN]=&XA_shell_envrn;

/* Scrap / Clipboard */
	Ktable[XA_SCRAP_READ]=&XA_scrap_read;
	Ktable[XA_SCRAP_WRITE]=&XA_scrap_write;

/* XaAES specific AES calls */
	Ktable[XA_APPL_PIPE]=&XA_appl_pipe;

/*
  XaAES kernal internal messages - applications should NEVER send these to the kernal,
   they are used internally to pass crucial info from the client pid trap handler to 
   the kernal.
*/
	Ktable[XA_NEW_CLIENT]=&XA_new_client;
	Ktable[XA_CLIENT_EXIT]=&XA_client_exit;
}
