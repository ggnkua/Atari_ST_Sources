#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "mkrsc.h"
#include "globals.h"


 /*   redraws the info window    */
int do_redraw(message)
	int message[];
{
	GRECT t1,t2;
	windowptr thewin;
	int  xc, yc, wc, hc;

	v_hide_c(handle);
	wind_update(BEG_UPDATE);

	xc = message[4];
	yc = message[5];
	wc = message[6];
	hc = message[7];

/*	the windows are not resizable so 'work' is constant

	thewin = findwindowptr(message[3]);
	wind_get(message[3],WF_WORKXYWH,&thewin->work.g_x,
			&thewin->work.g_y,&thewin->work.g_w,&thewin->work.g_h);
*/

	t2.g_x=xc;
	t2.g_y=yc;
	t2.g_w=wc;
	t2.g_h=hc;
	wind_get(message[3],WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	while (t1.g_w && t1.g_h) {
	  if (rc_intersect(&t2,&t1)) {
	    set_clip(t1.g_x,t1.g_y,t1.g_w-1,t1.g_h-1);
		update_win(t1.g_x,t1.g_y,t1.g_w-1,t1.g_h-1);
	  }
	  wind_get(message[3],WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	}
/*	reset clipping to desktop	*/

	set_clip(xdesk,ydesk,wdesk,hdesk); /* set_clip to desktop */

	wind_update(END_UPDATE);
	v_show_c(handle,1);
}

int set_clip(x,y,w,h)
int x,y,w,h;
{
int clip[4];
	clip[0]=x;
	clip[1]=y;
	clip[2]=x+w;
	clip[3]=y+h;
	vs_clip(handle,1,clip);
}

windowptr new_window()
{
	int			wihandle, button, dummy, i;
	windowptr	thewin;

	/*
		Create the information for the window.  Max size is the desktop.
	*/
	wihandle = wind_create(WI_KIND, xdesk, ydesk, wdesk, hdesk);

	/*
		Check for error.
	*/
	if (wihandle < 0) {
		button = form_alert(1, "[1][ Sorry! | No more windows available. ][OK]");
		return NULL;
	}

	/*
		Allocate space for window record.
	*/
	thewin				  = (windowptr) malloc(sizeof(windowrec));
	if (thewin == NULL)
	{	button = form_alert(1, "[1][ Sorry! | Out of memory creating window. ][OK]");
		wind_delete(wihandle); /* delete the window created above  */
		return NULL;
	}
 

	/*
		Initialize window data structure.
	*/
	thewin -> next		  = NULL;
	thewin -> wihandle	  = wihandle;
	thewin->saved 		  = TRUE;

	thewin -> maintree.objt[0] = *mtbox1;
	thewin -> maintree.objt[0].ob_state = LASTOB;
	thewin -> maintree.count = 0;
	for(i=0;i<MAXONUM;i++)
	{	thewin -> maintree.treelink[i] = NULL;
		thewin -> maintree.kind[i] = 0;
		thewin -> maintree.name[i][0] = NULL;
	}
	thewin -> inwindow = &thewin -> maintree;

	sprintf(newtitle,"\\RSC%d.RSC", windowcount++);
	strcpy(thewin->title,newtitle);
	wind_set(thewin->wihandle, WF_NAME, thewin -> title, 0, 0);

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

{	graf_growbox(0, 0, 0, 0, xdesk, ydesk, wdesk, hdesk);
	wind_open(thewin->wihandle,160,rez*10,470,rez*185);

	wind_get(thewin->wihandle, WF_WORKXYWH, &thewin->work.g_x,
			 &thewin->work.g_y, &thewin->work.g_w, &thewin->work.g_h);

/*  put the maintree.objt[0] into the window  */

	thewin->maintree.objt[0].ob_x = thewin->work.g_x;
	thewin->maintree.objt[0].ob_y = thewin->work.g_y;
	thewin->maintree.objt[0].ob_width = thewin->work.g_w-1;
	thewin->maintree.objt[0].ob_height = thewin->work.g_h-1;
	
	thefrontwin = thewin;
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

	wind_close(thewin->wihandle);
	wind_get(thewin->wihandle, WF_CURRXYWH, &x, &y, &w, &h);
	graf_shrinkbox(0, 0, 0, 0, x, y, w, h);
	dispose_win_resources(thewin);
	windowcount--;

}

dispose_win_resources(thewin)
	windowptr	thewin;
{
		/*
			Remove window record from window list.
		*/
		register windowptr	winptr = (windowptr) &firstwindow;
        int button, i;

		wind_delete(thewin->wihandle);

		while(winptr -> next)
			if (winptr -> next == thewin)
				break;
			else
				winptr = winptr -> next;

		if (winptr -> next)
			winptr -> next = winptr -> next -> next;
		else {
		button = form_alert(1, "[1][ Internal Error: | Window pointer not in list. ][OK]");
			shutdown(1);
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

		/*  Release storage used by linked object tree structure 	*/
		
	if(thewin->maintree.count >0)
	for(i = 1;i < (thewin->maintree.count + 1); i++)
			free(thewin->maintree.treelink[i]);
		
		/*	Release window storage.	*/

		free(thewin);
	
}

windowptr findwindowptr(wihandle)
	int wihandle;
{
	register windowptr thewin = firstwindow;
    int button;

	for (thewin = firstwindow; thewin; thewin = thewin -> next)
		if (thewin -> wihandle == wihandle)
			break;

	if (!thewin) {
		button = form_alert(1, "[1][ Internal Error: | No window found for handle ][OK]");
	}

	return thewin;
}


  /* blank the current window work area */
int whiterect(thewin)
	windowptr thewin;
{
	int pxyarray[4];

    v_hide_c(handle);
    vsf_style(handle,4);  
   /* blank to white - may want to change for colour monitor */
    vsf_interior(handle,2);
    pxyarray[0]=thewin->work.g_x;
    pxyarray[3]=thewin->work.g_y;
    pxyarray[2]=thewin->work.g_x+thewin->work.g_w-1;
    pxyarray[1]=thewin->work.g_y+thewin->work.g_h-1;
    vr_recfl(handle,pxyarray);
    v_show_c(handle,1);   
} 

/*
	make_frontwin - Force a window to the front.
*/
make_frontwin(thewin)
	windowptr thewin;
{
	wind_set(thewin -> wihandle, WF_TOP, 0, 0, 0, 0);
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

update_win(cx, cy, cw, ch)
	int	cx, cy, cw, ch;
{
	OBJECT *inwind;

	inwind = thefrontwin->inwindow->objt;
	whiterect(thefrontwin);

	if(thefrontwin->inwindow->kind[0] == TMENU)
	{
		objc_draw(inwind,1,2,cx,cy,cw,ch);
		if(thefrontwin->inwindow->mbox > 0) 	
			objc_draw(inwind,thefrontwin->inwindow->mbox,10,cx,cy,cw,ch);
	}
	else

	objc_draw(inwind, 0, 10, cx, cy, cw+1, ch+1);
}
