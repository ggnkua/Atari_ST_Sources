#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "mkrsc.h"
#include "globals.h"


int TaskMaster()
{
	windowptr thewin;

	int event;			/* The event code.					*/
	int button = TRUE;	/* desired Button state				*/
	int mousebutton;	/* The state of the mouse button    */
    int	message[8];		/* Event message buffer.			*/
	int mousex, mousey;
	int keycode;		/*  The code for the key pressed.	*/
	int keymods;		/*  The state of the keyboard modifiers.
							(shift, ctrl, etc). */
	int clicks;			/*	The number of mouse clicks that occurred in the 
							given time. */
	OBJECT *inwinptr;
	int i, select;

	do {
	if(thefrontwin)
	{		inwinptr = thefrontwin->inwindow->objt;
			select = FALSE;

		for(i=0;i<(thefrontwin->inwindow->count + 1);i++)
			if(inwinptr[i].ob_state & SELECTED)
				select = TRUE;

		if (thefrontwin->inwindow == &thefrontwin->maintree)
			{	onleft = treicont;
				wind_set(0,WF_NEWDESK,hightreadr,lowtreadr, 0);
				if(tempm == NULL)
					mkrscmnu[PASTE].ob_state = DISABLED;
				else
					mkrscmnu[PASTE].ob_state = NORMAL;
			}
			else
			{	if(thefrontwin->inwindow->kind[0] == TMENU)
				{	onleft = mnuicont;
					wind_set(0,WF_NEWDESK,highmnuadr,lowmnuadr, 0);
				}
				else
				{	onleft = obicont;
					wind_set(0,WF_NEWDESK,highobadr,lowobadr, 0);
					mkrscmnu[SNAP].ob_state = NORMAL;
					mkrscmnu[SALL].ob_state = NORMAL;
					mkrscmnu[SSEL].ob_state = NORMAL;
					if(select)
						mkrscmnu[SORT].ob_state = NORMAL;
				}

				if(spaste)
					mkrscmnu[PASTE].ob_state = NORMAL;
				else
					mkrscmnu[PASTE].ob_state = DISABLED;
			}

			if (select)
			{	mkrscmnu[CUT].ob_state = NORMAL;
				mkrscmnu[COPY].ob_state = NORMAL;
				mkrscmnu[ERASE].ob_state = NORMAL;
				mkrscmnu[NAM].ob_state = NORMAL;
			}
			else
			{	mkrscmnu[CUT].ob_state = DISABLED;
				mkrscmnu[COPY].ob_state = DISABLED;
				mkrscmnu[ERASE].ob_state = DISABLED;
				mkrscmnu[SORT].ob_state = DISABLED;
				mkrscmnu[NAM].ob_state = DISABLED;
			}
	}	/* end of if(thefrontwin)	*/
	else
	{	mkrscmnu[CUT].ob_state = DISABLED;
		mkrscmnu[COPY].ob_state = DISABLED;
		mkrscmnu[ERASE].ob_state = DISABLED;
		mkrscmnu[PASTE].ob_state = DISABLED;
		mkrscmnu[SNAP].ob_state = DISABLED;
		mkrscmnu[SALL].ob_state = DISABLED;
		mkrscmnu[SSEL].ob_state = DISABLED;
		mkrscmnu[SORT].ob_state = DISABLED;
	}
	


		event = evnt_multi(
			MU_MESAG | MU_BUTTON | MU_KEYBD,   /* set messages to respond to. */
			2,				/* Time frame for events.					*/
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


		if (event & MU_MESAG) {
			switch (message[0]) {
				/*
					Window Support
				*/
				case WM_REDRAW:
       do_redraw(message);
        break;
				case WM_TOPPED:
					wind_set(message[3], WF_TOP, 0, 0, 0, 0);
					break;
				case WM_FULLED:
				case WM_ARROWED:
				case WM_HSLID:
				case WM_VSLID:
				case WM_MOVED:
				case WM_SIZED:   	break;

				case WM_NEWTOP:		
					wind_set(message[3], WF_TOP, 0, 0, 0, 0);
					break;
				case WM_CLOSED:		message[3] = FILE;
									message[4] = CLOSE;
									do_menu(message);
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

		if (event & MU_BUTTON)
				if(button)
					do_button(mousex, mousey, clicks);
				button ^= TRUE;

		if (event & MU_KEYBD)
			do_update(keycode,keymods);

	} while(1);
}

