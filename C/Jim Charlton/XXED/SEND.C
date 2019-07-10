
#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "globals.h"

send_vslid(thewin) /* send application slider message */
	windowptr	thewin;
{  
         int msg[8]; 
                    /* the message buffer */ 

	if(slid_flag)
		return;
/* return if there is already a vslid message pending	*/

         msg[0] = WM_VSLID;        /* message type is vslid */ 
         msg[1] = gl_apid;          /* application id*/ 
         msg[2] = 0;                /* message is standard 16 bytes */ 
         msg[3] = thewin->handle;        /* handle of window to refresh */ 
         msg[4] = thewin->vslidepos;       /* position of vslider */ 

         appl_write( gl_apid, 16, msg ); 
		slid_flag = TRUE;

}


send_redraw(thewin) /* send application a redraw message */
	windowptr	thewin;
{  
         int msg[8];
	if(draw_flag)
		return;
/* return if there is already a draw message pending	*/

                    /* the message buffer */ 
         msg[0] = WM_REDRAW;        /* message type is redw */ 
         msg[1] = gl_apid;          /* application id*/ 
         msg[2] = 0;                /* message is standard 16 bytes */ 
         msg[3] = thewin->handle;        /* handle of window to refresh */ 
         msg[4] = thewin->work.g_x;            /* position and size of redraw */ 
         msg[5] = thewin->work.g_y; 
         msg[6] = thewin->work.g_w; 
         msg[7] = thewin->work.g_h; 

         appl_write( gl_apid, 16, msg ); 
		draw_flag = TRUE;

/* 
 This will send a redraw to your own application. The above routine is taken 
from COMPUTES Technical Reference Guide for the Atari ST - Volume 2 AES. Have 
fun. 
*/  
  
}

immed_redraw(thewin) /* bypass event multi and do a screen redraw */
	windowptr thewin;
{
         int msg[8];

                    /* the message buffer */ 
         msg[0] = WM_REDRAW;        /* message type is redw */ 
         msg[1] = gl_apid;          /* application id*/ 
         msg[2] = 0;                /* message is standard 16 bytes */ 
         msg[3] = thewin->handle;        /* handle of window to refresh */ 
         msg[4] = thewin->work.g_x;      /* position and size of redraw */ 
         msg[5] = thewin->work.g_y; 
         msg[6] = thewin->work.g_w; 
         msg[7] = thewin->work.g_h; 
	do_window(msg);
}

send_arrow(thewin,direction) /* send application an arrow message */
	windowptr	thewin;
	int			direction;
{  
         int msg[8]; 
                    /* the message buffer */

	if(arro_flag)
		return;
/* return if there is already a arrow message pending	*/
 
         msg[0] = WM_ARROWED;        /* message type is */ 
         msg[1] = gl_apid;          /* application id*/ 
         msg[2] = 0;                /* message is standard 16 bytes */ 
         msg[3] = thewin->handle;        /* handle of window to refresh */ 
         msg[4] = direction;            /* up = 2, down = 3 */ 
         msg[5] = 0;
         msg[6] = 0; 
         msg[7] = 0; 

         appl_write( gl_apid, 16, msg ); 
		arro_flag = TRUE;
}
