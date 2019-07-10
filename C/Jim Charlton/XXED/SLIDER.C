
#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "globals.h"


/* takes care of displaying the correct text in the window after
      the slider has been moved or the window resized  */
vhandler(message)
	int *message;
{	int	vslideold, vslide; 
	long	totallines, topwlnmax, topwline, winlines, topchar;
	int		handle, ret;
	windowptr	thewin;

	handle = message[3];
	thewin = findwindowptr(handle);


	totallines = 1 + thewin->flen/16;

	winlines = thewin->work.g_h/gl_hchar; /* no of lines can put in window  */

	vslideold = thewin->vslidepos;  /* save the old slider position  */

 /* calculate the line number (from the top of the file) for the top
    line displayed on the screen when the last full page of text
    is being displayed in the window   */

	topwlnmax = ((totallines - winlines)>0) ? (totallines-winlines) : 0;

  /* topwline is the top line of the currently displayed page */

  	topwline = (thewin->topchar/16 < topwlnmax) ? thewin->topchar/16 : topwlnmax;

	if(thewin->topchar > topwline*16)
		send_redraw(thewin);
	thewin->topchar = topwline*16;
	if(topwlnmax)
		thewin->vslidepos = (1000*topwline)/topwlnmax;
	else
		thewin->vslidepos = 1;

  switch (message[0]) {
	case WM_ARROWED	:		
            switch (message[4]) {
                case 0 :    /* uppage */
                 	topwline = (topwline-winlines+1>0) ? topwline-winlines+1 : 0;
					thewin->topchar = topwline*16;
		          if(topwline == 0) thewin->vslidepos = 1;
          		  else    thewin->vslidepos = (1000*topwline)/topwlnmax;
					send_redraw(thewin); 
            		break;
                case 1 :     /* dnpage  */
                 	topwline += winlines - 1;
                  	if(topwline>topwlnmax)topwline = topwlnmax;
					thewin->topchar = topwline*16;
		          if(topwline == 0) thewin->vslidepos = 1;
          		  else    thewin->vslidepos = (1000*topwline)/topwlnmax;
					send_redraw(thewin); 
                    break;
                case 2 :     /* upline  */  
					if(--topwline<0) topwline++;
					else
					{	thewin->topchar = topwline*16;
			          if(topwline == 0) thewin->vslidepos = 1;
          			  else    thewin->vslidepos = (1000*topwline)/topwlnmax;
							scroll(thewin,0,1);
							redraw_vslider(thewin->handle);
					}  
                    break;
                case 3 :     /* dnline  */
					if(++topwline>topwlnmax) topwline--;
					else
				 	{	thewin->topchar = topwline*16;
		          	  if(topwline == 0) thewin->vslidepos = 1;
          		  	  else    thewin->vslidepos = (1000*topwline)/topwlnmax;
							scroll(thewin,1,0);
							redraw_vslider(thewin->handle);
					}  
					break;		 }  /* end of switch message[4]  */

					break; /* from WM_ARROWED */
				
	case WM_VSLID :
			  /* the sliderbox was "pulled" up or down  */
	   vslide = message[4];
		  /* if the slider box was moved by less than 5 units do nothing */
        	if (abs(vslideold-vslide)<5) 
				{	vslide = vslideold;
				}
			else  {	topwline = vslide*topwlnmax/1000;
					thewin->topchar = topwline*16;
    				thewin->vslidepos = vslide;
					send_redraw(thewin);
			  	  }	
      
				break; /* from WM_VSLID   */
					}	/* end of switch message[0]  */
}

redraw_vslider(wihandle)    /* redraws vslider in new postion  */
	int	wihandle;
{
	windowptr	thewin;
	int vslide_size, ret;
	long totallines, seenlines;
	
	thewin = findwindowptr(wihandle);

	totallines = 1 + thewin->flen/16;
   
    seenlines = min(totallines,(thewin->work.g_h/gl_hchar));
    vslide_size = min(1000,1000*seenlines/totallines);
	
  /* redraw the slider  to its new position and with new size */				
	wind_update(BEG_UPDATE);			
	wind_set(thewin->handle,WF_VSLSIZE,vslide_size,0,0,0);
	wind_set(wihandle,WF_VSLIDE,thewin->vslidepos,&ret,&ret,&ret);      
	wind_update(END_UPDATE);
 
}

size_vslider(wihandle)  /* set slider size  and redraws it */
	int wihandle;
{   int vslide_size;
	long totallines, seenlines;
	windowptr thewin;
	
	thewin = findwindowptr(wihandle);

	totallines = 1 + thewin->flen/16;
   
    seenlines = min(totallines,(thewin->work.g_h/gl_hchar));
    vslide_size = min(1000,1000*seenlines/totallines);
    wind_set(thewin->handle,WF_VSLSIZE,vslide_size,0,0,0);
}

   /* the scroll routine which moves text up if the up flag is set
      and down if the dnflag is set.  The other flag must be zero.
      Finally blanks the space for the new line at top or bottom
      and sets the clipping rectangle for just that line in preparation
      for the text in the window to be redrawn.  Be sure to reset
      the clipping to the full window work area after redrawing the
      text        */

scroll(thewin,upflag,dnflag)
	windowptr thewin;
   int upflag, dnflag;

{	int pxy[8], pxyc[4], i, lines_onscrn;
	int xwork, ywork, hwork, wwork;   
	long totallines,seenlines;

        /* upflag=1 dnflag=0 for scroll up one line  */
        /* upflag=0 dnflag=1 for scroll down one line  */

	xwork = thewin->work.g_x;
	ywork = thewin->work.g_y;
	hwork = thewin->work.g_h;
	wwork = thewin->work.g_w;

		lines_onscrn=hwork/gl_hchar;

        pxy[0] = xwork;
        pxy[2] = xwork+wwork;
        pxy[4] = xwork;
        pxy[6] = xwork+wwork;

    if(upflag==1)
     {  pxy[1] = ywork+gl_hchar;
        pxy[3] = ywork+hwork-1;
        pxy[5] = ywork;
        pxy[7] = ywork+hwork-1-gl_hchar;
     } 
    if(dnflag==1)
     {  pxy[1] = ywork;
        pxy[3] = ywork+hwork-1-gl_hchar;
        pxy[5] = ywork+gl_hchar;
        pxy[7] = ywork+hwork-1;
     } 
      /* scroll window */
      
      vro_cpyfm(thewin->graf.handle,S_ONLY,pxy,
          				&thewin->graf.mfdb,&thewin->graf.mfdb);
     /* now blank the top or bottom line as appropriate  */
        pxyc[0] = xwork;
        pxyc[2] = xwork + wwork - 1;


 /* if scroll up/dwn then blank out the
                       last/first line on the screen  */
     if(upflag == 1)  
      {  pxyc[1] = ywork + (lines_onscrn-1)*gl_hchar + 1;
         pxyc[3] = ywork + hwork - 1;
 /* set the clip rect to the line to be redrawn */ 
         vs_clip(thewin->graf.handle,1,pxyc);
         vr_recfl(thewin->graf.handle,pxyc);
		graf_mouse(M_OFF, 0L);
		one_line2(thewin,thewin->topchar+(thewin->work.g_h/gl_hchar)*16-8); 
		graf_mouse(M_ON, 0L);
 /* the pos passed to one_line2 is topchar+g_h/16*16   */
      }
     if(dnflag == 1)
      {  pxyc[1] = ywork;
         pxyc[3] = ywork + gl_hchar;
 /* set the clip rect to the line to be redrawn */ 
         vs_clip(thewin->graf.handle,1,pxyc);
         vr_recfl(thewin->graf.handle,pxyc);
		graf_mouse(M_OFF, 0L);
         one_line2(thewin,thewin->topchar); 
		graf_mouse(M_ON, 0L);
      }

}
