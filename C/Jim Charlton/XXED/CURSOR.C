#include <osbind.h>
#include <gemdefs.h>
#include <obdefs.h>

#include "globals.h"


putcur(thewin,type)
	windowptr	thewin;
	int			type;  /* actually, type is never used */

{   int			xpos, ypos; 
	int diff, num, rect[4];
	int	x,y,w,h;
	int	xacur, yacur;
	long winlines, bottomchar;
	
	winlines = thewin->work.g_h/gl_hchar; /* no of lines can put in window  */
	bottomchar = thewin->topchar + (winlines * 16) - 1;

	if( (thewin->position < thewin->topchar) ||
					(thewin->position > bottomchar) )
		return;	/* don't try to draw cursor unless on page  */ 

/* set the clipping rectange in case it was not set    */

	wind_get(thewin->handle, WF_WORKXYWH, &x, &y, &w, &h);
	rect[0] = x;
	rect[1] = y;
	rect[2] = x+w-1;
	rect[3] = y+h-1;
	
	vs_clip(thewin->graf.handle,1,rect);

	if (thewin = thefrontwin)  /*  cursor action for frontwin only */
  {
		diff = thewin->position - thewin->topchar;	
		num = diff % 16;
		thewin->ycur = (diff/16)*gl_hchar + thewin->work.g_y + 1;
		thewin->xcur = xoffset[num]*gl_wchar + gl_wchar -1
											 + thewin->work.g_x;
		yacur = thewin->ycur;
		xacur = thewin->work.g_x + 49*gl_wchar + num*gl_wchar; 

	rect[0] = thewin->xcur+1;
	rect[1] = thewin->ycur;
	rect[2] = rect[0]+gl_wchar*2-1;
	rect[3] = rect[1]+gl_hchar-1;
	
	vsf_perimeter(thewin->graf.handle,0);
	vsf_interior(thewin->graf.handle,1);
	vsf_style(thewin->graf.handle,1);
	vswr_mode(thewin->graf.handle,3);
	v_bar(thewin->graf.handle,rect);

	rect[0] = xacur -1;
	rect[1] = yacur;
	rect[2] = rect[0] + gl_wchar-1;
	rect[3] = rect[1] + gl_hchar-1;
	v_bar(thewin->graf.handle,rect);

	vswr_mode(thewin->graf.handle,1);
  }
}    

