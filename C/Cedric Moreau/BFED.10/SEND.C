/*
	file: search.c
	utility:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
	comments: 
*/
#include <stdio.h>

#ifdef __PUREC__ 
#include <aes.h>
#include <compend.h>
#else
#include <aesbind.h>
#endif

#include "events.h"
#include "send.h"
#include "wind.h"
#include "main.c"

/*
	name: send_vslid
	utility: send application slider message
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void send_vslid(windowptr	thewin)
{  
	if (!slid_flag) /* return if there is already a vslid message pending	*/
	{
		message[0] = WM_VSLID;		  /* message type is vslid */ 
		message[1] = gl_apid;			 /* application id*/ 
		message[2] = 0;					 /* message is standard 16 bytes */ 
		message[3] = thewin->handle;		  /* handle of window to refresh */ 
		message[4] = thewin->vslidepos;		 /* position of vslider */ 
	
		appl_write( gl_apid, 16, message ); 
		slid_flag = TRUE;
	}
}

/*
	name: send_redraw
	utility: send application a redraw message
	comment:  This will send a redraw to your own application.
		The above routine is taken from COMPUTES Technical Reference
		Guide for the Atari ST - Volume 2 AES. Have fun. 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void send_redraw(windowptr	thewin)
{  
	if (!draw_flag) /* return if there is already a draw message pending	*/
 	{
			  /* the message buffer */ 
		message[0] = WM_REDRAW;		  /* message type is redw */ 
		message[1] = gl_apid;			 /* application id*/ 
		message[2] = 0;					 /* message is standard 16 bytes */ 
		message[3] = thewin->handle;		  /* handle of window to refresh */ 
		message[4] = thewin->work.g_x;				/* position and size of redraw */ 
		message[5] = thewin->work.g_y; 
		message[6] = thewin->work.g_w; 
		message[7] = thewin->work.g_h; 
	
		appl_write( gl_apid, 16, message ); 
		draw_flag = TRUE;
	}  
}

/*
	name: immed_redraw
	utility: bypass event multi and do a screen redraw
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void immed_redraw(windowptr thewin)
{
	  /* the message buffer */ 
	message[0] = WM_REDRAW;		  /* message type is redw */ 
	message[1] = gl_apid;			 /* application id*/ 
	message[2] = 0;					 /* message is standard 16 bytes */ 
	message[3] = thewin->handle;		  /* handle of window to refresh */ 
	message[4] = thewin->work.g_x;		/* position and size of redraw */ 
	message[5] = thewin->work.g_y; 
	message[6] = thewin->work.g_w; 
	message[7] = thewin->work.g_h; 
	window_do(message);
}

/*
	name: send_arrow
	utility: send application an arrow message
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void send_arrow(windowptr	thewin,int	direction)
{  
	if (!arro_flag)/* return if there is already a arrow message pending	*/
	{
		  /* the message buffer */
		message[0] = WM_ARROWED;		  /* message type is */ 
		message[1] = gl_apid;			 /* application id*/ 
		message[2] = 0;					 /* message is standard 16 bytes */ 
		message[3] = thewin->handle;		  /* handle of window to refresh */ 
		message[4] = direction;				/* up = 2, down = 3 */ 
		message[5] = 0;
		message[6] = 0; 
		message[7] = 0; 
	
		appl_write( gl_apid, 16, message ); 
		arro_flag = TRUE;
	}
}

/*
	name: send_redraw_all
	utility: send a redraw to all windows
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void send_redraw_all(void)
{
	windowptr thewindow = firstwindow;

	while (thewindow)
	{
		immed_redraw(thewindow);
		thewindow = thewindow->next;
	}
}
