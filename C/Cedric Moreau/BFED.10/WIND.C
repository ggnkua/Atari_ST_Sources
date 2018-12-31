/********************************************
	file: wind.c
	utility:
	date: 1989
	author: Jim Charlton
	modifications:
		17 aug 96: C. Moreau: suppressed file_str var. 
	comments: 
*********************************************/

/********************************************
	includes
*********************************************/
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef __PUREC__ 
#include <aes.h>
#include <vdi.h>
#include <compend.h>
#else
#include <aesbind.h>
#include <vdibind.h>
#endif

#include "e:\proging\c\libs\malib\alert.h"

#include "bufman.h"
#include "files.h"
#include "init.h"
#include "events.h"
#include "main.h"
#include "menu.h"
#include "onepage.h"
#include "send.h"
#include "slider.h"
#include "wind.h"

#include "bfed_rsc.h"

/********************************************
	defines
*********************************************/

/********************************************
	locals vars declarations & definitions
*********************************************/
static char pos_str[32];

/********************************************
	globals vars declarations
*********************************************/
int	partial = FALSE;
int	draw_flag = FALSE;
int	slid_flag = FALSE;
int	arro_flag = FALSE;
int black_white = FALSE;
int grow_shrink = FALSE;
int	info_hexa = FALSE;
windowptr firstwindow = NULL;
windowptr thefrontwin = NULL;

/********************************************
	locals functions declarations
*********************************************/
static void window_resize(const int *message, const windowptr thewin);
static void window_fullsize(const windowptr thewin);
static void do_update(const int *message, const windowptr thewin);
static int rc_intersect (GRECT *p1, GRECT *p2);
static void window_update(const windowptr window, GRECT *r1);
static int window_count(void);

/********************************************
	globals functions definitions
*********************************************/
/*
	name: window_do
	utility: determines the type of window event and then calls
		the appropriate function to handle the event.
	comment: 
	parameters:
	return: none
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void window_do(int *message)
{
	const int handle = message[3];
	const windowptr thewin = findwindowptr(handle);

	graf_mouse(M_OFF, 0L);
	wind_update(BEG_UPDATE);

	switch (message[0])
	{
		case WM_REDRAW:
			draw_flag = 0;
			do_update(message, thewin);
			break;

		case WM_NEWTOP:
		case WM_TOPPED:
			window_put_top(thewin);
			break;

		case WM_MOVED:
		case WM_SIZED:
			window_resize(message, thewin);
			redraw_vslider(thewin);
			break;

		case WM_FULLED:
			window_fullsize(thewin);
			redraw_vslider(thewin);
			break;

		case WM_CLOSED:
			window_dispose(thewin);
			dispose_buf(thewin);
			break;
		
		case WM_ARROWED:
			arro_flag = 0;
			
		case WM_VSLID:
			slid_flag = 0;
			vhandler(message, thewin);
			break;
			
		case WM_BOTTOM:
			if (ver_aes >= 0x410)
				wind_set (handle, WF_BOTTOM); 
			break;

		case WM_ALLICONIFY:
			window_iconify_all();
			break;
			
		case WM_ICONIFY:
			window_iconify(thewin);
			break;

		case WM_UNICONIFY:
			window_uniconify(thewin);
			break;
	}

	wind_update(END_UPDATE);
	graf_mouse(M_ON, 0L);
}

/*
	name: window_resize
	utility: move and resize a window
	comment: redraws the window at it's new postion and updates all
		of the window's position records.
	parameters: int message: contain new window sizes
				windowptr thewin: contain old window sizes 
	return: none
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
		12 may 96: C.Moreau: Take off thewin->fullsize=FALSE
		16 aug 96: C.Moreau: Added parameter to optimize
*/
static void window_resize(const int *message, const windowptr thewin)
{
#if 0
	int x = (message[4] & ~0x7);
	int y = message[5];
	int w = ((message[6] & ~0x7) + 4);
	int h = message[7];
#else
	int x = message[4];
	int y = message[5];
	int w = message[6];
	int h = message[7];
#endif
	const int handle = message[3];

		/* Make sure that the window doesn't become too small. */
	if (w < 80)
		w = 80;
	if (h < 80)
		h = 80;

		/* Or too big */
	{
		int w_ful, h_ful, dummy;
		
		wind_get(handle, WF_FULLXYWH, &dummy, &dummy, &w_ful, &h_ful);
		if (w > w_ful)
			w = w_ful;
		if (h > h_ful)
			h = h_ful;
	}
	
	/*
		Redraw the window at it's new size.
		And set the Window record data.
	*/
	wind_set(handle, WF_CURRXYWH, x, y, w, h);

	wind_get(handle, WF_WORKXYWH,					\
			 &thewin->work.g_x, &thewin->work.g_y,	\
			 &thewin->work.g_w, &thewin->work.g_h);

	if (thewin->form)	/* move also the form */
	{
		thewin->form->ob_x = thewin->work.g_x;
		thewin->form->ob_y = thewin->work.g_y;
	}
}

/*
	name: window_fullsize
	utility: draws the window at it's fully defined size.  If the window
		is at it's full size then this routines restores the window to it's
		previous size.
	comment: 
	parameters:
	return: none
	date: 1989
	author: Jim Charlton
	modifications:
		12 may 96: C. Moreau: changed code to come back to old size
			when unfulled. Also take off thewin->box. 
		16 aug 96: C. Moreau: Changed parameter from handle to thewin
*/
static void window_fullsize(const windowptr thewin)
{
	const int handle = thewin->handle;	/* window handle */
	int x, y, w, h;	/* window sizes */
	int dummy;

	wind_get(handle, WF_CURRXYWH, &x, &y, &dummy, &dummy);

	if (thewin->fullsize)
	{
			/*		Back to normal size	*/
		wind_get(handle, WF_PREVXYWH, &dummy, &dummy, &w, &h);
		thewin->fullsize = FALSE;
	}
	else
	{
			/*		Draw window at full size;	*/
		wind_get(handle, WF_FULLXYWH, &dummy, &dummy, &w, &h);
		thewin->fullsize = TRUE;
	}
					
	wind_set(handle, WF_CURRXYWH, x, y, w, h);
				
	wind_calc(WC_WORK, thewin->kind, x, y, w, h,	\
			&thewin->work.g_x, &thewin->work.g_y,	\
			&thewin->work.g_w, &thewin->work.g_h);
}

/*
	name: do_update
	utility: Update all of the rectangles affected
		by the update event.
	comment: 
	parameters:
	return: none
	date: 1989
	author: Jim Charlton
	modifications:
		12 may 96: C. Moreau: include update_window function. 
		16 aug 96: C. Moreau: REplace handle by findwinhandle(handle)
								Added thewin to optimize.
*/
static void do_update(const int *message, const windowptr thewin)
{
	const int handle = message[3];
	GRECT r1, therect;

	therect.g_x = message[4];
	therect.g_y = message[5];
	therect.g_w = message[6];
	therect.g_h = message[7];

	wind_get(handle, WF_FIRSTXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);

	while (r1.g_w && r1.g_h)
	{
		if (rc_intersect(&therect, &r1))
		{
			window_update(thewin, &r1);
		}
		wind_get(handle, WF_NEXTXYWH, &r1.g_x, &r1.g_y,	\
					 &r1.g_w, &r1.g_h);
	}

	redraw_vslider(thewin);
}

/*
	name: rc_intersect
	utility: calculate the intersection of 2 rectangles.
	comment: 
	parameters:
	return: 
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
static int rc_intersect (GRECT *p1, GRECT *p2)
{   
	const int tx = max(p2->g_x, p1->g_x);
	const int ty = max(p2->g_y, p1->g_y);
	const int tw = min(p2->g_x + p2->g_w, p1->g_x + p1->g_w);
	const int th = min(p2->g_y + p2->g_h, p1->g_y + p1->g_h);

	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th - ty;
	
	return ((tw > tx) && (th > ty));
}

/*
	name: window_update
	utility: execute the update procedure associated with the window.
	comment: 
	parameters:
	return: none
	date: 1989
	author: Jim Charlton
	modifications:
		12 may 96: C. Moreau: added parameter to redraw only a rect.
*/
static void window_update(const windowptr thewin, GRECT *rect)
{
	(*thewin->updateproc)(thewin, rect);
}

/*
	name: findwindowptr
	utility: find the window record associated with the window
		handle and return a pointer to that window record.
	comment: 
	parameters:
	return: none
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
windowptr findwindowptr(int handle)
{
	register windowptr thewin = firstwindow;

	for (thewin = firstwindow; thewin; thewin = thewin -> next)
			/* tricky for-loop.  When thewin becomes a NULL the loop terminates  */
		if (thewin->handle == handle)
			break;

	if (!thewin)	/* if window not found */
	{
		if (handle != 0)
		{
			rsc_alert(NOWIND_2);
			shutdown(2);
		}
		else
			return NULL;
	}

	return thewin;
}

/*
	name: window_new
	utility: create & draw a new window.
	comment: 	
				1.)  create the window.
				2.)  draw the window with the wind_open()
				3.)  create and setup the window record.
	parameters:
	return: 
	date: 1989
	author: Jim Charlton
	modifications:
		12 may 96: C. Moreau: Extracted window insertion
		in insertwindowptr.
*/
windowptr window_new(int thekind)
{
	int			handle;	/* window handle */
	windowptr	thewin = NULL;	/* window ptr */
		/* max window width and height */
	const int	wwind = min(wdesk, gl_wchar*WIDTH_WIN);
 	const int	hwind = hdesk;
	
		/* take off SMALLER button if AES < 4.10 */
	if (ver_aes < 0x410 && (thekind & SMALLER))
		thekind ^= SMALLER;
	
		/*	Create the information for the window.  
			Max size is the desktop. */
/***
	do smthg for window to not override
***/

	handle = wind_create(thekind, xdesk, ydesk,	wwind, hwind);
	if (handle < 0)
	{
		rsc_alert(NOWIND_3);
	}
	else
	{
			/*	Allocate space for window record. */
		thewin = (windowptr) malloc(sizeof(windowrec));
		if (!thewin)
		{
			wind_delete(handle); /* delete the window created above  */
			rsc_alert(NOMEM_5);
		}
 		else
 		{
				/* Initialize window data structure. */
			thewin->next			= NULL;
			thewin->handle			= handle;
			thewin->kind			= thekind;
			thewin->fullsize		= TRUE;
			thewin->graf.handle 	= open_vwork(&thewin->graf.mfdb);
			thewin->updateproc	= (one_page);
			thewin->headptr	  	= NULL;
			thewin->startmark   	= 1;
			thewin->endmark	  	= 0;
			thewin->markson     	= 0;
			thewin->xcur		  	= 0;
			thewin->ycur		  	= 0;
			thewin->topchar	  	= 0;
			thewin->flen		  	= 0;
			thewin->position	  	= 0;
			thewin->vslidepos   	= 0;
			thewin->icount	  		= 0;
			thewin->changed	  	= FALSE;	
			thewin->prot		  	= TRUE;
			thewin->form			= NULL;
			thewin->icon			= FALSE;

			{
				char *string;
		
				rsrc_gaddr(R_STRING, S_NOINFO, &string);
				strcpy(thewin->info, string);
				wind_set(handle, WF_INFO, thewin->info, 0, 0);
				rsrc_gaddr(R_STRING, S_UNTITLED, &string);
				strcpy(thewin->title, string);
				wind_set(handle, WF_NAME, thewin->title, 0, 0);
			}
			
		 		/* set text alignment to bottom left  for all windows   */
			{
				int dummy;
				vst_alignment(thewin->graf.handle, 0, 3, &dummy, &dummy);
			}
					
			insertwindowptr(thewin);
		}
	}
	
	return thewin;
}

/*
	name: insertwindowptr
	utility: 	Insert into windowlist.
	comment: 
	parameters: windowptr: window struct  to add
	return: none
	date: 12 may 96
	author: C. Moreau
	modifications: This was extracted from wind_new function.
*/
void insertwindowptr(windowptr thewin)
{
	register windowptr winptr = (windowptr)&firstwindow;  

/* firstwindow is a pointer to the first windowrec in the linked list and  */
/* is initialized to NULL.  Since the first thing in a windowrec is 	  */
/* 'next', the pointer to the next windowrec, then 						 */
/* '(windowptr)&firstwindow->next' or windptr->next starts at firstwindow */
/* What a kludge to save a bit of code!  Below is some commented out      */
/* tested code that is clearer.                                           */
/*  if(!firstwindow)
      firstwindow = *thewin;  
    else					
    {   winptr = firstwindow;  
 		while(winptr -> next) 
		winptr = winptr -> next;
		winptr -> next = *thewin;
    }
    
*/        
	while(winptr -> next)
		winptr = winptr -> next;

	winptr->next = thewin;
}

/*
	name: window_open
	utility: 
	comment: 
	parameters:
	return: none
	date: 1989
	author: Jim Charlton
	modifications:
		aug 96: C. Moreau: added const handle to look better 
*/
void window_open(windowptr thewin)
{
	const int handle = thewin->handle;	/* window handle */
	int x_full, y_full, w_full, h_full;	/* window full sizes */

	wind_get(handle, WF_FULLXYWH, &x_full, &y_full, &w_full, &h_full);
	
		/*	A little flim-flammery. */
	if (grow_shrink)
		graf_growbox(0, 0, 0, 0, x_full, y_full, w_full, h_full);

		/*	Draw the window. */
	wind_open(handle, x_full, y_full, w_full, h_full);
		
	wind_get(handle, WF_WORKXYWH,							\
				&thewin->work.g_x, &thewin->work.g_y,	\
				&thewin->work.g_w, &thewin->work.g_h);
	window_put_top(thewin);
	window_info(thewin);
}

/*
	name: window_dispose
	utility: Closes the window and disposes the storage for
		the window record.
	comment: 
	parameters:
	return: none
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: added grow_shrink option
*/
void window_dispose(windowptr thewin)
{
	wind_close(thewin->handle);

	if (grow_shrink)
		graf_shrinkbox(0, 0, 0, 0, 							\
						thewin->work.g_x, thewin->work.g_y,	\
						thewin->work.g_w, thewin->work.g_h);
	
	window_resources_dispose(thewin);
}

/*
	name: window_resources_dispose
	utility: 
	comment: 
	parameters:
	return: none
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void window_resources_dispose(windowptr thewin)
{
	register windowptr winptr = (windowptr) &firstwindow;

		/*		Remove window record from window list. */
	wind_delete(thewin->handle);

	while(winptr->next)
	{
		if (winptr->next == thewin)
			break;
		else
			winptr = winptr->next;
	}
	
	if (!winptr->next)
	{
		rsc_alert(NOWIND_4);
		shutdown(2);
	}
	else
	{
		winptr->next = winptr->next->next;

			/*	Update the front window pointer. */
		if (!firstwindow)
			thefrontwin = NULL;
		else
		{
			if (winptr == (windowptr) &firstwindow)
				window_put_top(winptr->next);
			else
				window_put_top(winptr);
		}
	
			/*		Close workstation associated with window. */
		if (!thewin->form)
			v_clsvwk(thewin->graf.handle);
	
			/*		Release window storage. */
		free(thewin);
	}
}

/*
	name: window_put_top
	utility: Force a window to the front.
	comment: 
	parameters:
	return: none
	date: 1989
	author: Jim Charlton
	modifications:
		10 may 96: C.Moreau: Added code to update info in menu 
*/
void window_put_top(windowptr thewin)
{
	thefrontwin = thewin;
	wind_set(thewin->handle, WF_TOP, 0, 0, 0, 0);
	update_menu();
}

/*
	name: window_rot
	utility: Rotate windows
	comment: 
	parameters:
	return: none
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void window_rot(void)
{
	if (thefrontwin)
    {
		windowptr winptr;

    	if (thefrontwin->next) 
			winptr = thefrontwin->next;
		else
			winptr = firstwindow;
		
    	window_put_top(winptr);
	}
}

/*
	name: window_blank
	utility: Fill in blank the window
	comment: 
	parameters:
	return: none
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void window_blank(windowptr thewin)
{
	const int grafhandle = thewin->graf.handle;

	pxyarray[0] = thewin->work.g_x;
	pxyarray[1] = thewin->work.g_y;
	pxyarray[2] = thewin->work.g_x + thewin->work.g_w;
	pxyarray[3] = thewin->work.g_y + thewin->work.g_h;
	vsf_interior(grafhandle, FIS_SOLID);  /* set for solid fill */

	if (black_white)
		vsf_color(grafhandle, 1);    /*  blank to black  */
	else
		vsf_color(grafhandle, 0);    /*  blank to white  */
	
	v_bar(grafhandle, pxyarray);		/* blank the interior */
}

/*
	name: window_info
	utility: Update information in info bar
	comment: 
		Need to print in the info bar of the window, the actual position
		of the cursor, the size of the file, the state of the file
		(protected).
		We use text in RSC. The string is made by a sprintf.
	parameters:
	return: none
	date: 1995
	author: C. Moreau
	modifications:
*/
void window_info(windowptr thewin)
{	
	char *prot_str, *notprot_str;
	
	rsrc_gaddr(R_STRING, S_PROTECTED, &prot_str);	
	rsrc_gaddr(R_STRING, S_NOTPROTECTED, &notprot_str);	

	sprintf(thewin->info, " %s %ld/%ld %s ",				\
			 pos_str, thewin->position, thewin->flen,		\
			 (thewin->prot?prot_str:notprot_str) );
			 
	wind_set(thewin->handle, WF_INFO, &thewin->info);
}

/*
	name: window_title
	utility: Update information in title bar
	comment: 
	parameters: pointer on window structure
	return: none
	date: 1995
	author: C. Moreau
	modifications:
*/
void window_title(windowptr thewin)
{
	wind_set(thewin->handle, WF_NAME, &thewin->title);
}

/*
	name: window_count
	utility: count the number of windows on the screen
	comment: 
	parameters: none
	return: int
	date: 14 august 96
	author: C.Moreau
	modifications:
*/
static int window_count(void)
{
	int nb = 0;
	windowptr thewindow = firstwindow;
	
	do
	{
		if (!thewindow->form)
			nb++;
		thewindow = thewindow->next;
	} while (thewindow);
	
	return nb;
}

/*
	name: window_tile
	utility: Tile windows horizontaly or verticaly
	comment: 
		This first count the number of windows to know the divide factor
		to apply to the screen (variable nb_of_windows). (The size of a
		window is size of the screen (wdesk or hdesk) divided by the
		number of windows (nb_windows) ). We call count_windows to know
		the number of work windows.
		We resize and move all windows with the new parameters by using
		do_resize function.
		w_full and h_full are the maximum size of a window (thewindow).
		The first window will be at 0,0 the second at his right, and so
		on. window_nb * ( wdesk or hdesk / nb_of_windows )
	parameters: int horiz_verti 
					0 tile horiz
					1 tile verti
	return: none
	date: 1995
	author: C. Moreau
	modifications:
*/
void window_tile(int horiz_verti)
{
	int window_nb = 0;		/* window number in opens windows */
	int dummy;
	int w_full, h_full;		/* window full sizes */
		/* number of open window */
	int nb_of_windows = window_count();
	int w_wind = (wdesk/nb_of_windows)-1,
		h_wind = (hdesk/nb_of_windows)-1;	/* window sizes */
	windowptr thewindow = firstwindow;	/* window ptr */
		
	do
	{
		if (!thewindow->form)
		{
			wind_get(thewindow->handle, WF_FULLXYWH, 	\
					&dummy, &dummy, &w_full, &h_full);
		
			message[3] = thewindow->handle;
			if (horiz_verti)		/* tile verti */
			{ 
				message[4] = 0;
				message[5] = window_nb * h_wind;
				message[6] = w_full;
				message[7] = h_wind;
			}
			else
			{ 
				message[4] = window_nb * w_wind;
				message[5] = 0;
				message[6] = w_wind;
				message[7] = h_full;
			}
			window_resize(message, thewindow);
			
			window_nb++;
		}
		thewindow = thewindow->next;
	} while (thewindow);
}

/*
	name: window_init
	utility: initialize vars of wind.c module
	comment: 
	parameters: none
	return: none
	date: 10 may 96
	author: C.Moreau
	modifications:
*/
void window_init(void)
{
	rsrc_gaddr(R_STRING, S_POSSTR, &pos_str);	
}

/*
	name: find_workwind
	utility: find the working window.
	comment:
		called from dialog.c.
		This return to a dialog the windowptr of the working window
		witch is under. Useful for search and go_pos dialog.
	parameters: none
	return: windowptr
	date: 11 may 96
	author: C.Moreau
	modifications:
*/
windowptr find_workwind(void)
{
	
	return NULL;
}

/*
	name: window_iconify
	utility: iconify a window
	comment: 
	parameters:
		windowptr thewin: window to iconify.
	return: none
	date: 23 jan 97
	author: C.Moreau
	modifications:
*/
void window_iconify(windowptr thewin)
{
	if ( !thewin->form && !thewin->icon && ver_aes >= 0x410)
	{
		wind_set (thewin->handle, WF_ICONIFY, message[4], message[5], message[6], message[7]);
		thewin->icon = TRUE;
	}
}

/*
	name: window_iconify_all
	utility: iconify all windows
	comment: 
	parameters: none
	return: none
	date: 23 jan 97
	author: C.Moreau
	modifications:
*/
void window_iconify_all(void)
{
	if (ver_aes >= 0x410)
	{
		windowptr thewindow = firstwindow;

		while (thewindow)
		{
			if (!thewindow->form && !thewindow->icon)
				window_iconify(thewindow);
				
			thewindow = thewindow->next;
		}
	}
}

/*
	name: window_uniconify
	utility: uniconify a window
	comment: 
	parameters:
		windowptr thewin: window to iconify.
	return: none
	date: 23 jan 97
	author: C.Moreau
	modifications:
*/
void window_uniconify(windowptr thewin)
{
	if ( !thewin->form && thewin->icon && ver_aes >= 0x410 )
	{
		wind_set (thewin->handle, WF_UNICONIFY, message[4], message[5], message[6], message[7]);
		thewin->icon = FALSE;
		send_redraw(thewin);
	}
}

