#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>
#include "xxed.h"

#include "globals.h"

/*
	Handle Application Events.
*/

TaskMaster()
{
	int event;			/* The event code.					*/
	int button = TRUE;	/* desired Button state				*/
	int	message[8];		/* Event message buffer.			*/
	int	mousex, mousey;	/* The current mouse position.		*/
	int mousebutton;	/* The state of the mouse button    */

	int keycode;		/*  The code for the key pressed.	*/
	int keymods;		/*  The state of the keyboard modifiers.
							(shift, ctrl, etc). */
	int clicks;			/*	The number of mouse clicks that occurred in the 
							given time. */
	windowptr	thewin;
	int	c;

			sprintf(fsize_str," File size:%ld",0L);
			sprintf(pos_str," Position:%ld",0L);
	do {
		if(thewin = thefrontwin)
		{	graf_mouse(M_OFF, 0L);
			putcur(thewin);	/* cursor on	*/
			if(thewin->prot) /* set protect check mark in edit menu */
			menubar[PROTECT].ob_state = CHECKED;
			else
			menubar[PROTECT].ob_state = NORMAL;
			graf_mouse(M_ON, 0L);
		}
		wr_ins_rpl(ins);

		event = evnt_multi(
			MU_MESAG | MU_BUTTON | MU_KEYBD,   /* set messages to respond to. */
                      /* MU_MESAG    is a message event    */
			1,				/* Time frame for events.					*/
			1,				/* Keyboard Event mask.						*/
			button,			/* desired key state						*/
			0, 0, 0, 0, 0,	/* rectangle one information (ignored)		*/
			0, 0, 0, 0, 0,	/* rectangle two information (ignored)		*/
			message,		/* The message buffer 						*/
			0, 0,			/* Number of Ticks for Timer event. 		*/
			&mousex,		/* The x-coordinate of the mouse at event.  */
			&mousey,		/* The y-coordinate of the mouse at event.  */
			&mousebutton,	/* The state of the mouse buttons at event. */
			&keymods,		/* The state of the keyboard modifiers.     */
			&keycode,		/* The key code for the key pressed.        */
			&clicks			/* The number of times the event occurred	*/
		);

		if(thewin = thefrontwin)
		{	graf_mouse(M_OFF, 0L);
			putcur(thewin);	/* cursor off	*/
			graf_mouse(M_ON, 0L);
		}


		if (event & MU_KEYBD)
				{
					if (thewin = thefrontwin)
/*  if repos is true.  eg. cursor is off the page, redraw page */
						if (repos(thewin))
						{	partial = FALSE;
							one_page(thewin,1);
							redraw_vslider(thewin->handle);
						}
					draw_flag = FALSE;
					arro_flag = FALSE;
					slid_flag = FALSE;
					do_kbd(keycode, keymods);
				}	
		else if (event & MU_MESAG) {
			switch (message[0]) {
				/*
					Window Support
				*/
				case WM_REDRAW:
				case WM_TOPPED:
				case WM_FULLED:
				case WM_ARROWED:
				case WM_HSLID:
				case WM_VSLID:
				case WM_SIZED:
				case WM_MOVED:
				case WM_NEWTOP:
				case WM_CLOSED:
					do_window(message);
					break;

				/*
					Menu Support
				*/
				case MN_SELECTED:
					do_menu(message);
					button ^= TRUE;	
				break;

				/*
					Desk Accessory Support
				*/
				case AC_OPEN:
				case AC_CLOSE:
				break;
			}
		}

		else if (event & MU_BUTTON)
		{
				if(button)
					do_button(mousex, mousey);
				button ^= TRUE;
		}
		if(thewin = thefrontwin)
		{	sprintf(fsize_str," File size:%ld",thewin->flen-1);
			sprintf(pos_str," Position:%ld",thewin->position);
		}

	}
 	while(1);
}
