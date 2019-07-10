#include <osbind.h>
#include <gemdefs.h>
#include <obdefs.h>

#include "globals.h"

/*
	External references for window update procs.
*/
extern one_page();

/*
	do_window - determines the type of window event and then calls
		the appropriate function to handle the event.
*/
do_window(message)
	int *message;
{
	int handle;
	windowptr	thewin;

	handle = message[3];

	graf_mouse(M_OFF, 0L);
	wind_update(BEG_UPDATE);

	switch (message[0]) {
		case WM_REDRAW:
			draw_flag = FALSE;
			do_update(message);
		break;

		case WM_NEWTOP:
		case WM_TOPPED:
			make_frontwin(findwindowptr(handle));
		break;

		case WM_MOVED:
		case WM_SIZED:
			do_resize(message);
			redraw_vslider(handle);
		break;

		case WM_FULLED:
			do_fullsize(handle);
			redraw_vslider(handle);
		break;

		case WM_CLOSED:
			thewin = findwindowptr(handle);
			dispose_window(thewin);
			dispose_buf(thewin);
		break;
		
		case WM_ARROWED:
			arro_flag = FALSE;
		case WM_VSLID:
			slid_flag = FALSE;
			vhandler(message);
	}

	wind_update(END_UPDATE);
	graf_mouse(M_ON, 0L);

}


/*
	do_resize - redraws the window at it's new postion and updates all
		of the window's position records.
*/
do_resize(message)
	int *message;
{
	int x, y, w, h;
	int handle;

	handle	= message[3];
	x		= (message[4]&~0x7);
	y		= message[5];
	w		= ((message[6]&~0x7)+4);
	h		= message[7];

	/*
		Make sure that the window doesn't become too small.
	*/
	if (w < 80) w = 80;
	if (h < 80) h = 84;

	/*
		Redraw the window at it's new size.
	*/
	wind_set(handle, WF_CURRXYWH, x, y, w, h);
	wind_get(handle, WF_WORKXYWH, &x, &y, &w, &h);

	{
		/*
			Set the Window record data.
		*/
		windowptr	thewin;

		thewin = findwindowptr(handle);

		rect_set(&thewin -> work, x, y, w, h);
		rect_set(&thewin -> box, x, y, w, h);
		thewin -> fullsize = FALSE;
	}
}


/*
	do_fullsize - draws the window at it's fully defined size.  If the window
		is at it's full size then this routines restores the window to it's
		previous size.
*/
do_fullsize(handle)
	int handle;
{
	register windowptr	thewin;

	int x, y, w, h;
	int d;

	thewin = findwindowptr(handle);

	if (thewin -> fullsize) {
		/*
			Back to normal size
		*/
		wind_calc(WC_WORK, thewin -> kind, thewin -> box,
			&thewin -> work.g_x, &thewin -> work.g_y,
			&thewin -> work.g_w, &thewin -> work.g_h);

/* note here that thewin->box, a GRECT structure of 4 ints  */
/* is passed to wind_calc in place of four ints     jlc     */
 
		wind_set(handle, WF_CURRXYWH, thewin -> box);
		thewin -> fullsize = FALSE;
	} else {
		/*
			Draw window at full size;
		*/
		wind_get(handle, WF_FULLXYWH, &x, &y, &w, &h);
		wind_set(handle, WF_CURRXYWH, x, y, w, h);
		wind_calc(WC_WORK, thewin -> kind, x, y, w, h,
			&thewin -> work.g_x, &thewin -> work.g_y,
			&thewin -> work.g_w, &thewin -> work.g_h);

		thewin -> fullsize = TRUE;
	}
}


/*
	do_update - Update all of the rectangles affected by the update event.
*/
do_update(message)
	int *message;
{
	int	 thewindow, grafhandle;
	GRECT r1, therect;

	thewindow = message[3];

	rect_set(&therect, message[4], message[5], message[6], message[7]);

	wind_get(thewindow, WF_FIRSTXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);

	while (r1.g_w && r1.g_h) {
		if (rect_intersect(therect, r1, &r1))
		{
			setclip(thewindow, &r1);
			redraw_vslider(thewindow);
			update_window(thewindow);
		}

		wind_get(thewindow, WF_NEXTXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
	}

	{
		int x, y, w, h;

		/*
			Restore clip rectangle of the desktop rectangle.
		*/
		wind_get(0, WF_WORKXYWH, &x, &y, &w, &h);
		rect_set(&r1, x, y, x+w, y+h);
		grafhandle = findwindowptr(thewindow) -> graf.handle;
		vs_clip(grafhandle, 1, &r1);
	}
}


/*
	update_window  -  execute the update procedure associated with the window.
*/
update_window(windhandle)
	int			windhandle;
{
	windowptr	thewin;

	thewin = findwindowptr(windhandle);

	(*thewin -> updateproc)(thewin,1);
}


/*
	setclip  -  set the windows clipping rectangle.
*/
setclip(thewindow, r1)
	int   thewindow;
	GRECT *r1;
{
	GRECT cliprect;
	int  grafhandle;

	grafhandle = findwindowptr(thewindow) -> graf.handle;

	rect_set(&cliprect, r1->g_x, r1->g_y, r1->g_x+r1->g_w-1, r1->g_y+r1->g_h-1);

	vs_clip(grafhandle, 1, &cliprect);
}


/*
				Window support routines.
*/

/*
	findwindowptr  -  find the window record associated with the window
		handle and return a pointer to that window record.
*/
windowptr findwindowptr(handle)
	int handle;
{
	register windowptr thewin = firstwindow;
    int button;

	for (thewin = firstwindow; thewin; thewin = thewin -> next)
/* tricky for-loop.  When thewin becomes a NULL the loop terminates  */
		if (thewin -> handle == handle)
			break;

	if (!thewin) {
		button = form_alert(1, "[1][ Internal Error: | No window found for handle ][OK]");
		shutdown(2);
	}

	return thewin;
}


/*
	new_window  -  create & draw a new window.

	1.)  create the window.
	2.)  draw the window with the wind_open()
	3.)  create and setup the window record.
*/
windowptr new_window(thekind)
	int			thekind;
{
	int			handle, button, dummy, i;
	int			xdesk, ydesk, wdesk, hdesk;
	windowptr	thewin;
	static		window_count = 1;

	/*
		Get the desktop coordinates.
	*/
	wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);

	/*
		Create the information for the window.  Max size is the desktop.
	*/
	handle = wind_create(thekind, xdesk, ydesk, wdesk, hdesk);

	/*
		Check for error.
	*/
	if (handle < 0) {
		button = form_alert(1, "[1][ Sorry! | No more windows available. ][OK]");
		return NULL;
	}

	/*
		Allocate space for window record.
	*/
	thewin				  = (windowptr) malloc(sizeof(windowrec));
	if (thewin == NULL)
	{	button = form_alert(1, "[1][ Sorry! | Out of memory creating window. ][OK]");
		wind_delete(handle); /* delete the window created above  */
		return NULL;
	}
 

	/*
		Initialize window data structure.
	*/
	thewin -> next		  = NULL;
	thewin -> handle	  = handle;
	thewin -> kind		  = thekind;
	thewin -> fullsize	  = TRUE;
	thewin -> graf.handle = open_vwork(&thewin -> graf.mfdb);
	strcpy(thewin->title,"untitled");
	strcpy(fs_insel,"untitled");
	wind_set(thewin->handle, WF_NAME, thewin -> title, 0, 0);

 /* set text alignment to bottom left  for all windows   */
   vst_alignment(thewin->graf.handle,0,3,&dummy,&dummy);

	thewin -> updateproc  = one_page;

	thewin -> headptr	  = NULL;
	thewin -> startmark   = 1;
	thewin -> endmark	  = 0;
	thewin -> markson     = FALSE;
	thewin -> xcur		  = 0;
	thewin -> ycur		  = 0;
	thewin -> topchar	  = 0;
	thewin -> flen		  = 0;
	thewin -> position	  = 0;
	thewin -> vslidepos   = 0;
	thewin -> icount	  = 0;
	thewin -> changed	  = 0;	
	thewin -> prot		  = TRUE;
	/*
		Insert into windowlist.
	*/
	{
		register windowptr	winptr = (windowptr) &firstwindow;  

/* firstwindow is a pointer to the first windowrec in the linked list and  */
/* is initialized to NULL.  Since the first thing in a windowrec is 	  */
/* 'next', the pointer to the next windowrec, then 						 */
/* '(windowptr)&firstwindow->next' or windptr->next starts at firstwindow */
/* What a kludge to save a bit of code!  Below is some commented out      */
/* tested code that is clearer.                                           */
/*      if(!firstwindow)
          firstwindow = thewin;  
        else					
        {   winptr = firstwindow;  
     		while(winptr -> next) 
			winptr = winptr -> next;
		winptr -> next = thewin;
        }
        
*/        
		while(winptr -> next) 
			winptr = winptr -> next;
	
		winptr -> next = thewin;
	}   
		return(thewin);
}


open_window(thewin)
	windowptr	thewin;

{	int			xdesk, ydesk, wdesk, hdesk;

	/*
		Get the desktop coordinates.
	*/
	wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);

	/*
		A little flim-flammery.
	*/
	graf_growbox(0, 0, 0, 0, xdesk, ydesk, wdesk, hdesk);

	/*
		Draw the window.
	*/
	wind_open(thewin->handle, xdesk, ydesk, wdesk, hdesk);

	wind_get(thewin->handle, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
	rect_set(&thewin -> work, xdesk, ydesk, wdesk, hdesk);

	wind_get(thewin->handle, WF_CURRXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
	rect_set(&thewin ->  box, xdesk, ydesk, wdesk, hdesk);


	make_frontwin(thewin);

}

/*
	dispose_window - Closes the window and disposes the storage for
		the window record.
*/
dispose_window(thewin)
	windowptr	thewin;
{
	int x, y, w, h;
	int handle;

	handle = thewin -> handle;


	wind_close(handle);

	wind_get(handle, WF_CURRXYWH, &x, &y, &w, &h);

	graf_shrinkbox(0, 0, 0, 0, x, y, w, h);

	dispose_win_resources(thewin);

}

dispose_win_resources(thewin)
	windowptr	thewin;
{
		/*
			Remove window record from window list.
		*/
		register windowptr	winptr = (windowptr) &firstwindow;
        int button;

		wind_delete(thewin->handle);

		while(winptr -> next)
			if (winptr -> next == thewin)
				break;
			else
				winptr = winptr -> next;

		if (winptr -> next)
			winptr -> next = winptr -> next -> next;
		else {
		button = form_alert(1, "[1][ Internal Error: | Window pointer not in list. ][OK]");
			shutdown(2);
			 }

		/*
			Update the front window pointer.
		*/
		if (!firstwindow)
			thefrontwin = NULL;
		else
			if (winptr == (windowptr) &firstwindow)
				make_frontwin(winptr -> next);
			else
				make_frontwin(winptr);
		
		if(thefrontwin)
			immed_redraw(thefrontwin);  /* see send.c  */

		/*
			Close workstation associated with window.
		*/
		v_clsvwk(thewin -> graf.handle);

		/*
			Release window storage.
		*/
		free(thewin);
	
}


/*
	make_frontwin - Force a window to the front.
*/
make_frontwin(thewin)
	windowptr thewin;
{
	wind_set(thewin -> handle, WF_TOP, 0, 0, 0, 0);
	thefrontwin = thewin;
}

rot_wind()
{	windowptr winptr, thewin;


	if(thewin = thefrontwin)
    {	winptr = firstwindow;  
    	while(winptr != thewin) 
			winptr = winptr->next;
    	if((winptr =  winptr->next)!=NULL)
			make_frontwin(winptr);
		else
			make_frontwin(firstwindow);
	}
}

wind_blank(thewin)
	windowptr thewin;
{
	int			grafhandle;
	GRECT		windrect;
	int			x, y, w, h;

	grafhandle = thewin -> graf.handle;
	x = thewin->work.g_x;
	y = thewin->work.g_y;
	w = thewin->work.g_w;
	h = thewin->work.g_h;

	rect_set(&windrect, x, y, x+w, y+h);

	vsf_interior(grafhandle, 1);  /* set for solid fill */
	vsf_color(grafhandle, 0);    /*  blank to white  */

	v_bar(grafhandle, &windrect);		/* blank the interior */
}
