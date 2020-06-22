/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <memory.h>
#include "XA_DEFS.H"
#include "XA_TYPES.H"
#include "XA_GLOBL.H"
#include "K_DEFS.H"
#include "RECTLIST.H"
#include "OBJECTS.H"

/*
	AES message handling
*/
unsigned long XA_evnt_mesag(short clnt_pid, AESPB *pb)
{
	short *clnt_buf=(short*)(pb->addrin[0]);
	short f;
	short rtn;
	XA_AESMSG_LIST *msg;
	WidgetCallback wc,disp;
	XA_PENDING_WIDGET *pending;
	XA_WIDGET *widg;
	XA_WINDOW *wind;

/* Is there a widget still active (like a scroll arrow)? If so, check with the action first */
/* as it may result in some messages (just in case we've not got any already) */
	if (!clients[clnt_pid].msg)
	{
		if (clients[clnt_pid].widget_active)
		{
			pending=clients[clnt_pid].widget_active;
			wc=pending->action;
			widg=pending->widg;
			wind=pending->wind;
			rtn=(*wc)(pending->wind, pending->widg);	/* Call the pending action */

			if (rtn)	/* If the widget click/drag function returned TRUE we reset the state of the widget */
			{
#if JOHAN_RECTANGLES
				XA_RECT_LIST *rl, *drl;
#else
				XA_RECT_LIST *rl=generate_rect_list(wind);
				XA_RECT_LIST *drl;
#endif
					
#if JOHAN_RECTANGLES
				if (!(rl = wind->rl_full))
					rl = wind->rl_full = generate_rect_list(wind);
#endif
				widg->stat=XAW_PLAIN;					/* Flag the widget as de-selected */
				disp=widg->behaviour[XACB_DISPLAY];		/* get the redraw function for this widget */

				v_hide_c(V_handle);
				for(drl=rl; drl; drl=drl->next)	/* Walk the rectangle list */
				{
					set_clip(drl->x,drl->y,drl->w,drl->h);
					(*disp)(wind, widg);
				}
				v_show_c(V_handle, 1);
#if JOHAN_RECTANGLES
#else
				while(rl)	/* Dispose of rectangle list */
				{
					drl=rl;
					rl=rl->next;
					free(drl);
				}
#endif
			}
		}
	}

	if (clients[clnt_pid].msg)	/* Are there any messages pending? */
	{
		msg=clients[clnt_pid].msg;
		clients[clnt_pid].msg=msg->next;
		
		for(f=0; f<8; f++)		/* Copy the message into the clients buffer */
			clnt_buf[f]=msg->message[f];

		pb->intout[0]=1;
		return XAC_DONE;		/* Return TRUE to unblock the client */
	}
	
	clients[clnt_pid].waiting_for=XAWAIT_MESSAGE;	/* Mark the client as waiting for messages */
	clients[clnt_pid].waiting_pb=pb;
	
	return XAC_BLOCK;
}
