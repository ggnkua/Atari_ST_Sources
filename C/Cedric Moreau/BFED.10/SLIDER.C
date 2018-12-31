/*
	file: slider.c
	utility:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
	comments: 
*/
#include <stdio.h>
#include <stdlib.h>

#ifdef __PUREC__ 
#include <aes.h>
#include <vdi.h>
#include <compend.h>
#else
#include <aesbind.h>
#include <vdibind.h>
#endif

#include "init.h"
#include "onepage.h"
#include "send.h"
#include "slider.h"
#include "wind.h"

/*
	locals functions
*/
static void scroll(windowptr thewin,int upflag,int dnflag);
static void size_vslider(int wihandle);

/*
	name: vhandler
	utility: takes care of displaying the correct text in the
		window after the slider has been moved or the window
		resized
	comment: 
	parameters:
	return: none
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void vhandler(const int *message, const windowptr thewin)
{
	const int vslideold = thewin->vslidepos;  /* save the old slider position  */
	int		vslide; 
	const long winlines = thewin->work.g_h/gl_hchar; /* no of lines can put in window  */
	const long totallines = 1 + thewin->flen/16;
		/* calculate the line number (from the top of the file) for the top
			line displayed on the screen when the last full page of text
			is being displayed in the window	*/
	long topwlnmax = ((totallines - winlines)>0) ? (totallines-winlines) : 0;
		/* topwline is the top line of the currently displayed page */
 	long topwline = (thewin->topchar/16 < topwlnmax) ? thewin->topchar/16 : topwlnmax;

	if (thewin->topchar > topwline*16)
		send_redraw(thewin);

	thewin->topchar = topwline*16;

	if (topwlnmax)
		thewin->vslidepos = (int)((1000*topwline)/topwlnmax);
	else
		thewin->vslidepos = 1;

	switch (message[0]) {
		case WM_ARROWED	:		
			switch (message[4]) {
				case WA_UPPAGE :	 /* uppage */
					topwline = (topwline-winlines+1>0) ? topwline-winlines+1 : 0;
					thewin->topchar = topwline*16;
					if (topwline == 0)
						thewin->vslidepos = 1;
					else
						thewin->vslidepos = (int)((1000*topwline)/topwlnmax);
					send_redraw(thewin); 
					break;
				case WA_DNPAGE :	  /* dnpage  */
					topwline += winlines - 1;
					if (topwline>topwlnmax)
						topwline = topwlnmax;
					thewin->topchar = topwline*16;
					if (!topwline)
						thewin->vslidepos = 1;
					else
						thewin->vslidepos = (int)((1000*topwline)/topwlnmax);
					send_redraw(thewin); 
					break;
				case WA_UPLINE :	  /* upline  */  
					if (--topwline<0)
						topwline++;
					else
					{
						thewin->topchar = topwline*16;
						if(!topwline)
							thewin->vslidepos = 1;
			 			else
			 				thewin->vslidepos = (int)((1000*topwline)/topwlnmax);
						scroll(thewin,0,1);
						redraw_vslider(thewin);
					}  
					break;
				case WA_DNLINE :	  /* dnline  */
					if (++topwline>topwlnmax)
						topwline--;
					else
				 	{
				 		thewin->topchar = topwline*16;
						if(!topwline)
							thewin->vslidepos = 1;
			 		  	else
			 		  		thewin->vslidepos = (int)((1000*topwline)/topwlnmax);
						scroll(thewin,1,0);
						redraw_vslider(thewin);
					}  
					break;		 }  /* end of switch message[4]  */
			break; /* from WM_ARROWED */
				
	case WM_VSLID :
			  /* the sliderbox was "pulled" up or down  */
		vslide = message[4];
		  /* if the slider box was moved by less than 5 units do nothing */
		if (abs(vslideold-vslide) < 5) 
		{
			vslide = vslideold;
		}
		else
		{
			topwline = vslide*topwlnmax/1000;
			thewin->topchar = topwline*16;
	 		thewin->vslidepos = vslide;
			send_redraw(thewin);
		}	
		
		break; /* from WM_VSLID	*/
	}	/* end of switch message[0]  */
}

/*
	name: redraw_vslider
	utility: redraws vslider in new postion  
	comment: 
	parameters: int wihandle: window handle
				windowptr thewin: ptr on window structure
	return: none
	date: 1989
	author: Jim Charlton
	modifications:
		aug 96: C. Moreau: added windowptr parameter
*/
void redraw_vslider(const windowptr thewin)
{
	int vslide_size, dummy;
	long totallines, seenlines;
	const int handle = thewin->handle;
	
	if (!thewin->form)
	{
		totallines = 1 + thewin->flen/16;
		
		seenlines = min(totallines, (thewin->work.g_h/gl_hchar));
		vslide_size = (int)min(1000, 1000*seenlines/totallines);
		
	  /* redraw the slider  to its new position and with new size */				
		wind_update(BEG_UPDATE);			
		wind_set(handle, WF_VSLSIZE, vslide_size, 0, 0, 0);
		wind_set(handle, WF_VSLIDE, thewin->vslidepos,		\
				&dummy, &dummy, &dummy);		
		wind_update(END_UPDATE);
	}
}

/*
	name: size_vslider
	utility: set slider size  and redraws it 
	comment: 
	parameters:
	return: none
	date: 1989
	author: Jim Charlton
	modifications:
*/
static void size_vslider(int wihandle)
{
	windowptr thewin = findwindowptr(wihandle);
	const long totallines = 1 + thewin->flen/16;
	const long seenlines = min(totallines,(thewin->work.g_h/gl_hchar));
	const int vslide_size = (int)min(1000,1000*seenlines/totallines);
	
	wind_set(wihandle, WF_VSLSIZE, vslide_size, 0, 0, 0);
}

/*
	name: scroll
	utility: 
	comment: the scroll routine which moves text up if the up flag
		is set and down if the dnflag is set.  The other flag must
		be zero. Finally blanks the space for the new line at top or
		bottom and sets the clipping rectangle for just that line in
		preparation for the text in the window to be redrawn. 
		Be sure to reset the clipping to the full window work area
		after redrawing the	text.		  
	parameters:
	return: none
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
static void scroll(windowptr thewin,int upflag,int dnflag)
{
	int pxyc[4];	/* pxy copy */
	const int lines_onscrn=thewin->work.g_h/gl_hchar;

		  /* upflag=1 dnflag=0 for scroll up one line  */
		  /* upflag=0 dnflag=1 for scroll down one line  */

	pxyarray[0] = thewin->work.g_x;
	pxyarray[2] = thewin->work.g_x + thewin->work.g_w;
	pxyarray[4] = thewin->work.g_x;
	pxyarray[6] = thewin->work.g_x + thewin->work.g_w;

	if (upflag)
	{
		pxyarray[1] = thewin->work.g_y + gl_hchar;
		pxyarray[3] = thewin->work.g_y + thewin->work.g_h - 1;
		pxyarray[5] = thewin->work.g_y;
		pxyarray[7] = thewin->work.g_y + thewin->work.g_h - 1 - gl_hchar;
	}
	
	if (dnflag)
	{	pxyarray[1] = thewin->work.g_y;
		pxyarray[3] = thewin->work.g_y + thewin->work.g_h - 1 - gl_hchar;
		pxyarray[5] = thewin->work.g_y + gl_hchar;
		pxyarray[7] = thewin->work.g_y + thewin->work.g_h - 1;
	} 
		/* scroll window */
		
	vro_cpyfm(thewin->graf.handle, S_ONLY, pxyarray,
			 	&thewin->graf.mfdb, &thewin->graf.mfdb);
	  /* now blank the top or bottom line as appropriate  */
	pxyc[0] = thewin->work.g_x;
	pxyc[2] = thewin->work.g_x + thewin->work.g_w - 1;


 /* if scroll up/dwn then blank out the
							  last/first line on the screen  */
	if (upflag)  
	{
		pxyc[1] = thewin->work.g_y + (lines_onscrn-1)*gl_hchar + 1;
		pxyc[3] = thewin->work.g_y + thewin->work.g_h - 1;
 /* set the clip rect to the line to be redrawn */ 
		vs_clip(thewin->graf.handle,1,pxyc);
		vr_recfl(thewin->graf.handle,pxyc);
		graf_mouse(M_OFF, 0L);
		one_line2(thewin,thewin->topchar+(thewin->work.g_h/gl_hchar)*16-8); 
		graf_mouse(M_ON, 0L);
 /* the pos passed to one_line2 is topchar+g_h/16*16	*/
	}
	
	if (dnflag)
	{
		pxyc[1] = thewin->work.g_y;
		pxyc[3] = thewin->work.g_y + gl_hchar;
 /* set the clip rect to the line to be redrawn */ 
		vs_clip(thewin->graf.handle,1,pxyc);
		vr_recfl(thewin->graf.handle,pxyc);
		graf_mouse(M_OFF, 0L);
		one_line2(thewin,thewin->topchar); 
		graf_mouse(M_ON, 0L);
	}
}
