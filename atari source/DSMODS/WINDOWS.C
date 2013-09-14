/**************************************************************************/
/*  FILE:  WINDOWS.C		PROGRAM TITLE: DeskSET II Alpha Version   */
/*  Date Created: 12/15/87						  */ 
/*  Last Modified: 01/26/89						  */
/*									  */
/*  Description: Window Handler Routines				  */
/*  Routines: o  open_windows() - open initial text and preview window	  */
/*	      o  shut _windows()- close text and preview, if open	  */
/*            o  do_window()	- create a window and open it		  */ 
/*	      o  top_window()   - top a window				  */
/*	      o  close_window() - close and delete a window		  */
/*	      o  full_window()  - full size a window			  */
/*	      o  arrow_window() - arrow handling of a window		  */
/*	      o  hslide_window()- horizontal slider			  */
/*	      o  vslide_window()- vertical slider of a window		  */
/*	      o  size_window()  - size a window				  */
/*	      o  move_window()  - move a window				  */
/*	      o  slider_chk()   - Update Slider Info			  */
/*	      o  get_work()     - Returns work area of window...          */
/*	      o  sliderv()	- size vertical slider bar		  */
/*	      o  sliderh()	- size horizontal slider bar		  */
/*	      o  wupline()	- up arrow function			  */
/*	      o  wdnline()	- down arrow function			  */
/*	      o  wrtline()	- right arrow function			  */
/*	      o  wlftline()	- left arrow function			  */
/*	      o  prev_cleanup() - Cleanup preview window		  */
/*	      o  size_fit_handle- Calc page area for size to fit and alt  */
/**************************************************************************/


/**************************************************************************/
/* INCLUDE FILES							  */
/**************************************************************************/
#include "define.h"
#include "gemdefs.h"
#include <obdefs.h>
#include "deskset2.h"
#include "alert.h"

/**************************************************************************/
/* DEFINES								  */
/**************************************************************************/
#define max(x,y)   (((x) > (y)) ? (x) :  (y))	/* Max function	          */
#define	min(x,y)   (((x) < (y)) ? (x) :  (y))	/* Min function		  */

/**************************************************************************/
/* EXTERNALS								  */
/**************************************************************************/
extern int hpage_size;				/* width and height of    */
extern int vpage_size;				/* paper in MU units      */

extern int pagew;				/* current page width and */
extern int pageh;				/* height in pixels.      */

extern int shandle;				/* Screen Handle...	  */

extern int view_size;				/* Current scale size...  */
extern FDB page_MFDB;				/* MFDB of preview area   */
extern int ptsin[];				/* PTSIN[] array...       */
extern unsigned long gl_region_ptr;		/* Ptr to current active  */
						/* text region		  */
extern unsigned long gl_grregion_ptr;
extern unsigned long region_ptr;

extern GRECT page_area; 			/* GRECT of Preview MFDB  */
extern GRECT page;

extern int BSTATE;
extern int BREAL;
extern int nada();
extern int dummy;
extern int pxy[];
extern int blit_flag;
extern int force_draw_flag;
extern int ruler_flag;
extern int xruler_offset;
extern int yruler_offset;
extern int cur_scale;

extern long TWart_ptr;				/* TW current article     */

extern OBJECT *ad_menu;
extern int article_flag;
extern char pfname[];				/* preview window title	 */
extern char basefname[];			/* base page window title*/

extern int unit_type;
extern int active_prim;
	
/**************************************************************************/
/* GLOBAL VARIABLES							  */
/**************************************************************************/
int txt_handle;					/* text window handle     */
int prev_handle;				/* preview window handle  */

GRECT curr;					/* Current area of window */
GRECT prev;					/* Previous area of window*/
GRECT full;					/* Full-size of window	  */

GRECT pwork;					/* Preview work area...   */
GRECT twork;					/* txt work area...	  */
GRECT cpwork;					/* work area of 	  */
						/* preview window	  */
GRECT dpwork;					/* blit area of preview   */
						/* work window		  */

GRECT scrn_area;				/* GRECT of ScreenMFDB... */
GRECT clip2;					/* GRECT of clip area...  */

long location = 0x0L;				/* Screen to Screen Blit  */


char *winfo[][4] = {				/* Size Message		  */
		 {" Size To Fit - Inches                ",
		  " Size To Fit - Picas                 ",
		  " Size To Fit - Centimeters           ",
		  " Size To Fit - Ciceros               "},

		 {" 50% Size - Inches                   ",
		  " 50% Size - Picas                    ",
		  " 50% Size - Centimeters              ",
		  " 50% Size - Ciceros                  "},

		 {" 75% Size - Inches                   ",
		  " 75% Size - Picas                    ",
		  " 75% Size - Centimeters              ",
		  " 75% Size - Ciceros                  "},

                 {" Actual Size - Inches                ",
                  " Actual Size - Picas                 ",
                  " Actual Size - Centimeters           ",
                  " Actual Size - Ciceros               "},

                 {" 200% Size - Inches                  ",
                  " 200% Size - Picas                   ",
                  " 200% Size - Centimeters             ",
                  " 200% Size - Ciceros                 "},

                 {" Alternate Pages - Left Page Active - Inches     ",
                  " Alternate Pages - Left Page Active - Picas      ",
                  " Alternate Pages - Left Page Active - Centimeters",
                  " Alternate Pages - Left Page Active - Ciceros    "},

		 {" Alternate Pages - Right Page Active - Inches     ",
		  " Alternate Pages - Right Page Active - Picas      ",
		  " Alternate Pages - Right Page Active - Centimeters",
		  " Alternate Pages - Right Page Active - Ciceros    "},

		 {"  "," "," "," "}
                };


char	*TWmesg[] = {				/* Text window Messages   */
		     "Article :",
		     " >> "
		    };

int (*arrow_funcs)();
int (*slide_arrow)();
int sliderv();
int sliderh();
int wupline();
int wdnline();
int wrtline();
int wlfline();

int pixx,pixy;
int xruler_offset;
int yruler_offset;

/**************************************************************************/
/* Function:    open_windows()						  */
/* Description: Create and open preview and text window.                  */
/* IN: none								  */
/* OUT: none								  */
/**************************************************************************/
open_windows()
{
    int wind_type;
    int tmp;

    wind_type = (NAME | INFO | FULLER | SIZER | MOVER |
		 UPARROW | DNARROW | VSLIDE | LFARROW |
		 RTARROW | HSLIDE);

    wind_get(0,WF_WORKXYWH,&full.g_x,&full.g_y,&full.g_w,&full.g_h);
    txt_handle = wind_create(wind_type,full.g_x,full.g_y,full.g_w,full.g_h);
    prev_handle= wind_create(wind_type,full.g_x,full.g_y,full.g_w,full.g_h);

    tmp = ((full.g_w/10)-2) + ((full.g_w/20)*9) + 24;

    if(txt_handle >= 0)
    {
	set_TWrows();
       do_window(txt_handle,TWmesg[0],TWmesg[1],
	         tmp,full.g_y+1,(full.g_w/20)*9-30,(full.g_h/2));
       get_work(txt_handle);
    }


    if(prev_handle >=0)
    {
       strcpy(pfname," Preview Window ");
       strcpy(basefname," Base Page Window ");
       do_window(prev_handle,pfname,winfo[7][unit_type],
  	      (full.g_w/10)-2,full.g_y+1,(full.g_w/20)*9+20,full.g_h-7);
       get_work(prev_handle);
       update_preview_blit();
    }
}



/**************************************************************************/
/* Function:    close_windows()						  */
/* Description: Close and delete preview and text window.		  */
/* IN:  none								  */
/* OUT: none								  */
/**************************************************************************/
shut_windows()
{
    if(txt_handle)
    {
	wind_close(txt_handle);
	wind_delete(txt_handle);
    }

    if(prev_handle)
    {
	wind_close(prev_handle);
        wind_delete(prev_handle);
    }
}



/**************************************************************************/
/* Function:    do_window()						  */
/* Description: Open a window						  */
/* IN:  wi_handle - window handle					  */
/*	name	  - name for title bar					  */
/*	info	  - text for info bar					  */
/*	x,y,w,h   - size to open window to				  */
/* OUT: none								  */
/**************************************************************************/
do_window(wi_handle,name,info,x,y,w,h)
int wi_handle;
char *name;
char *info;
int x,y;
int w,h;
{
      wind_set(wi_handle,WF_NAME,name,0,0);
      wind_set(wi_handle,WF_INFO,info,0,0);
      wind_set(wi_handle,WF_HSLIDE,1,0,0,0);
      wind_set(wi_handle,WF_VSLIDE,1,0,0,0);
      wind_set(wi_handle,WF_HSLSIZE,1000,0,0,0);
      wind_set(wi_handle,WF_VSLSIZE,1000,0,0,0);
      graf_growbox(10,10,20,20,x,y,w,h);
      wind_open(wi_handle,x,y,w,h);
}



/**************************************************************************/
/* Function:    top_window()  						  */
/* Description: Top a window :-)					  */
/* IN:  wi_handle - handle of window					  */
/**************************************************************************/
top_window(wi_handle,txtptr)
int wi_handle;
char *txtptr;
{
 	register int i;

	if(wi_handle == txt_handle && article_flag == 1)
	{
	   alert_cntre(ALERT25);	/* Article still open    */
	   return;
	}
	wind_set(wi_handle,WF_TOP,0,0,0,0);
	if(wi_handle == txt_handle)
	{
	   for(i = TFILE;i <= TOPTIONS;i++)
		menu_ienable(ad_menu,0x8000|i,FALSE);	/* Disable menus */
	   menu_ienable(ad_menu,0x8000|TEXT,TRUE);
	   menu_ienable(ad_menu,OADDPRIM,FALSE);
	   menu_ienable(ad_menu,ODELPRIM,FALSE);
	   menu_ienable(ad_menu,OPCOORD,FALSE);
	   menu_ienable(ad_menu,OMOVEFNT,FALSE);
	   menu_ienable(ad_menu,OMOVEBAK,FALSE);

	   menu_ienable(ad_menu,RUNLINK,FALSE);
	   menu_ienable(ad_menu,RDELETE,FALSE);
	   menu_ienable(ad_menu,RCOORD,FALSE);
	   menu_ienable(ad_menu,RMOVEFNT,FALSE);
	   menu_ienable(ad_menu,RMOVEBAK,FALSE);

	   if (gl_region_ptr)
			setTWArticle(gl_region_ptr,txtptr);
	}
	else
	{
	   for(i = TFILE;i <= TOPTIONS;i++)
		menu_ienable(ad_menu,0x8000|i,TRUE);
	   menu_ienable(ad_menu,0x8000|TEXT,FALSE);
	   if(TWart_ptr)
			saveTWptrs();
	}
        active_prim = FALSE;
}



/**************************************************************************/
/* Function:    close_window()						  */
/* Description: Close a window						  */
/* IN: wi_handle - handle of window					  */
/**************************************************************************/
close_window(wi_handle)
int wi_handle;
{
     wind_get(wi_handle,WF_CURRXYWH,&curr.g_x,&curr.g_y,&curr.g_w,&curr.g_h);
     wind_close(wi_handle);
     graf_shrinkbox(10,10,20,20,curr.g_x,curr.g_y,curr.g_w,curr.g_h);
     wind_delete(wi_handle);

     if(wi_handle == txt_handle) txt_handle = FALSE;
     else if(wi_handle == prev_handle) prev_handle = FALSE;
}



/**************************************************************************/
/* Function:    full_window()						  */
/* Description: full size a window					  */
/* IN: wi_handle - handle of window to full				  */
/**************************************************************************/
full_window(wi_handle)
register int wi_handle;
{
     wind_get(wi_handle,WF_CURRXYWH,&curr.g_x,&curr.g_y,&curr.g_w,&curr.g_h);
     wind_get(wi_handle,WF_FULLXYWH,&full.g_x,&full.g_y,&full.g_w,&full.g_h);

     if( rc_equal(&curr,&full))
     {
       wind_get(wi_handle,WF_PREVXYWH,&prev.g_x,&prev.g_y,&prev.g_w,&prev.g_h);
       graf_shrinkbox(prev.g_x,prev.g_y,prev.g_w,prev.g_h,
		      full.g_x,full.g_y,full.g_w,full.g_h);
       wind_set(wi_handle,WF_CURRXYWH,prev.g_x,prev.g_y,prev.g_w,prev.g_h);
     }
     else
     {
       graf_growbox(curr.g_x,curr.g_y,curr.g_w,curr.g_h,
		    full.g_x,full.g_y,full.g_w,full.g_h);
       wind_set(wi_handle,WF_CURRXYWH,full.g_x,full.g_y,full.g_w,full.g_h);
     }
     get_work(wi_handle);
     if(wi_handle == prev_handle)
     {
	if( (view_size == PSIZE)  ||
	    (view_size == PADJCNT))
        {
	   gsx_moff();
	   size_fit_handle();
	   gsx_mon();
	   if(ruler_flag)
		init_rulers();
        }
	else
	  prev_cleanup();
     }
	else TWslider_chk();
}



/**************************************************************************/
/* Function:     arrow_window()						  */
/* Description:  arrow button control of a window			  */
/* NOTE: limits must be put in so that the arrows don't exceed them       */
/* IN: wi_handle - handle of window					  */
/*     action    - button pressed - arrow, slider, scroll bar		  */
/* OUT: none								  */
/**************************************************************************/
arrow_window(wi_handle,action)
int wi_handle;
int action;
{
     int tmp_buff[8];
     int event;

     if(wi_handle == txt_handle)		/* To TWindow handler */
		return(TW_arrow(action));
     
     region_ptr = gl_region_ptr = gl_grregion_ptr = 0L;
     if((wi_handle == prev_handle) && (view_size != PSIZE)
				   && (view_size != PADJCNT))
     {
      set_clip(TRUE,&pwork);
      scrntomu(16,16,&pixx,&pixy,1);		/* should be in do_view_size*/


      arrow_funcs = &nada;
      slide_arrow = &sliderv;

      switch(action)
       {
         case WA_UPPAGE:  
		   page_area.g_y = max(page_area.g_y - page_area.g_h,0L);
		   break;

         case WA_DNPAGE: 
/* 		   page_area.g_y += page_area.g_h;*/
		   page_area.g_y = min(vpage_size - page_area.g_h,page_area.g_y + page_area.g_h);
 		   break;

         case WA_UPLINE:
		   page_area.g_y = max(page_area.g_y - pixy,0L);
                   arrow_funcs = &wupline;
		   break;

         case WA_DNLINE:
		   page_area.g_y += pixy;
                   arrow_funcs = &wdnline;
		   break;

         case WA_LFPAGE:
		   page_area.g_x = max(page_area.g_x - page_area.g_w,0L);
		   break;

         case WA_RTPAGE:
/*		   page_area.g_x += page_area.g_w;*/
		   page_area.g_x = min(hpage_size - page_area.g_w,page_area.g_x + page_area.g_w);
		   break;

         case WA_LFLINE:
		   page_area.g_x = max(page_area.g_x - pixx,0L);
                   arrow_funcs = &wlfline;
		   slide_arrow = &sliderh;
		   break;

         case WA_RTLINE:
		   page_area.g_x += pixx;
		   arrow_funcs = &wrtline;
		   slide_arrow = &sliderh;
		break;
       }
       if( ((BREAL == 1) || (BREAL == 2))&& (arrow_funcs != &nada))
       {
	   do
 	   {
		(*arrow_funcs)();
		(*slide_arrow)();
		do_blit();
	   }while( (BREAL == 1) || (BREAL == 2));
       }
       else
       {
          slider_chk();
          do_blit();
       }
       BSTATE = 0;
	  
           for(;;)	/* used to bleed off unwanted messages...*/
           {
		event = evnt_multi((MU_MESAG|MU_TIMER),
				    0,0,0,
				    0,0,0,0,0,
				    0,0,0,0,0,
				    tmp_buff,
				    0,0,		/* timer == 0 */
				    &dummy,&dummy,
				    &dummy,&dummy,
				    &dummy,&dummy);

		if(event == MU_TIMER)
				break;
           }
           BSTATE = 0;

    }
    else
	do_blit();
}



/**************************************************************************/
/* Function:     hslide_window()					  */
/* Description:  Horizontal Slider Control				  */
/* IN: wi_handle - handle of window					  */
/*     position  - position of slider in window				  */
/* OUT: none								  */
/**************************************************************************/
hslide_window(wi_handle,position)
int wi_handle;
int position;
{
    if(wi_handle == prev_handle)
    {
	region_ptr = gl_region_ptr = gl_grregion_ptr = 0L;
        if((view_size != PSIZE) && (view_size != PADJCNT))
        {
          page_area.g_x = scale_iv(position,hpage_size - page_area.g_w,1000);
	  sliderh();
        }
        send_redraw(prev_handle);
    }
	else TWhslide(position);
}



/**************************************************************************/
/* Function:     vslide_window()					  */
/* Description:  Vertical Slider Control				  */
/* IN: wi_handle - handle of window					  */
/*     position  - position of slider in window				  */
/* OUT: none								  */
/**************************************************************************/
vslide_window(wi_handle,position)
int wi_handle;
int position;
{
    if(wi_handle == prev_handle)
    {
	region_ptr = gl_region_ptr = gl_grregion_ptr = 0L;
	if((view_size != PSIZE) && (view_size != PADJCNT))
	{
	  page_area.g_y = scale_iv(position,vpage_size - page_area.g_h,1000);
	  sliderv();
        }
	send_redraw(prev_handle);
    }
     else TWvslide(position);
}



/**************************************************************************/
/* Function:     size_window()						  */
/* Description:  Window Sizer Routine					  */
/* IN: info - handle, x,y,w,h of window					  */
/* OUT: none								  */
/**************************************************************************/
size_window(info)
register int info[];
{
       wind_set(info[3],WF_CURRXYWH,info[4],info[5],info[6],info[7]);
       get_work(info[3]);

       if(info[3] == txt_handle)
       {
	  TWslider_chk();
          wind_get(info[3],WF_PREVXYWH,&prev.g_x,&prev.g_y,&prev.g_w,&prev.g_h);
          if((prev.g_w > info[6]) && (prev.g_h >= info[7]) ||
          (prev.g_w >= info[6]) && (prev.g_h > info[7]) )
              do_redraw(info);
       }
       else
       {
          if((view_size != PSIZE) && (view_size != PADJCNT))
          {
	    set_clip(TRUE,&pwork);
            wind_get(info[3],WF_PREVXYWH,&prev.g_x,&prev.g_y,
					 &prev.g_w,&prev.g_h);
	    clear_window(prev_handle,2,1);

            wind_set(prev_handle,WF_VSLSIZE,scale_iv(1000,page_area.g_h,
	      					vpage_size),0,0,0);
	    wind_set(prev_handle,WF_HSLSIZE,scale_iv(1000,page_area.g_w,
	      					hpage_size),0,0,0);
     	    sliderv();
     	    sliderh();

            if((prev.g_w > info[6]) && (prev.g_h >= info[7]) ||
            (prev.g_w >= info[6]) && (prev.g_h > info[7]) )
            {
                send_redraw(prev_handle);
            }

       }
       else
       {
	  gsx_moff();
	  size_fit_handle();
	  gsx_mon();
	  if(ruler_flag)
		init_rulers();
	  send_redraw(prev_handle);
       }
      }
}



/**************************************************************************/
/* Function:     move_window()						  */
/* Description:  Window Mover Routine					  */
/* IN:  info  - handle,x,y,w,h of window				  */
/**************************************************************************/
move_window(info)
register int info[];
{
	wind_set(info[3],WF_CURRXYWH,info[4],info[5],info[6],info[7]);
	get_work(info[3]);
        if(info[3] == prev_handle)
        {
	   clear_window(prev_handle,2,1);
           update_preview_blit();
        }
}



/**************************************************************************/
/* Function:     slider_chk()						  */
/* Description:  Slider Update						  */
/* IN: none								  */
/* OUT: none								  */
/* GLOBAL:  page_area - modified to blit preview to screen		  */
/**************************************************************************/
slider_chk()
{
   if( (view_size == PSIZE) || (view_size == PADJCNT))
   {
     page_area.g_x = page_area.g_y = 0;
     wind_set(prev_handle,WF_VSLSIZE,1000,0,0,0);
     wind_set(prev_handle,WF_HSLSIZE,1000,0,0,0);
     wind_set(prev_handle,WF_VSLIDE,0,0,0,0);
     wind_set(prev_handle,WF_HSLIDE,0,0,0,0);
   }
   else
   {
     wind_set(prev_handle,WF_VSLSIZE,scale_iv(1000,page_area.g_h,
	      vpage_size),0,0,0);
     wind_set(prev_handle,WF_HSLSIZE,scale_iv(1000,page_area.g_w,
	      hpage_size),0,0,0);
     sliderv();
     sliderh();
   }
}




/**************************************************************************/
/* Function:     get_work()						  */
/* Description:  Get work area of window				  */
/* IN: handle - handle of window					  */
/* OUT: none								  */
/* GLOBAL:  work area variables of window updated.			  */
/**************************************************************************/
get_work(handle)
int handle;
{
      if(prev_handle == handle)
      {
          wind_get(prev_handle,WF_WORKXYWH,&pwork.g_x,&pwork.g_y,
                                      &pwork.g_w,&pwork.g_h);

	  wind_get(prev_handle,WF_CURRXYWH,&cpwork.g_x,&cpwork.g_y,
					   &cpwork.g_w,&cpwork.g_h);
	  dpwork.g_x = pwork.g_x;
	  dpwork.g_y = pwork.g_y;
          
	  if(ruler_flag)
	  {
		if(view_size == P200)
			mutoscrn(324,288,&xruler_offset,&yruler_offset,1);
		else
			mutoscrn(648,576,&xruler_offset,&yruler_offset,1);
		dpwork.g_x += xruler_offset;
		dpwork.g_y += yruler_offset;
	  	dpwork.g_w  = min(pwork.g_w-xruler_offset,pagew);
	  	dpwork.g_h  = min(pwork.g_h-yruler_offset,pageh);
	  }
          else
          {	 
	     dpwork.g_w = min(pwork.g_w,pagew);
	     dpwork.g_h = min(pwork.g_h,pageh);
	  }
	  
	  scrntomu(dpwork.g_w,dpwork.g_h,&page_area.g_w,&page_area.g_h,1);
          update_preview_blit();
	  screen_clip();
      }
      else
      if(txt_handle == handle)
      {
           wind_get(txt_handle,WF_WORKXYWH,&twork.g_x,&twork.g_y,
	                               &twork.g_w,&twork.g_h);
	   setMrowcol();
      }
}





/**************************************************************************/
/* Function: sliderv()							  */
/* Description: size vertical slider bar				  */
/**************************************************************************/
sliderv()
{
     if(vpage_size < (page_area.g_y + page_area.g_h))
		page_area.g_y = vpage_size - page_area.g_h;
	
     wind_set(prev_handle,WF_VSLIDE,scale_iv(1000,page_area.g_y,
	      vpage_size - page_area.g_h),0,0,0);

}




/**************************************************************************/
/* Function: sliderh()							  */
/* Description: size horizontal slider bar				  */
/**************************************************************************/
sliderh()
{
   if(hpage_size < (page_area.g_x + page_area.g_w))
		page_area.g_x = max(hpage_size - page_area.g_w,0);
   if(page_area.g_w > hpage_size)
		page_area.g_w = hpage_size;
   wind_set(prev_handle,WF_HSLIDE,scale_iv(1000,page_area.g_x,
	      hpage_size - page_area.g_w),0,0,0); 
}





/**************************************************************************/
/* Function: wupline()							  */
/* Description: up arrow function					  */
/**************************************************************************/
wupline()
{
   page_area.g_y = max(page_area.g_y - pixy,0L);
}




/**************************************************************************/
/* Function: wdnline()							  */
/* Description: down arrow function					  */
/**************************************************************************/
wdnline()
{
   page_area.g_y += pixy;
}





/**************************************************************************/
/* Function: wrtline()							  */
/* Description: right arrow function					  */
/**************************************************************************/
wrtline()
{
   page_area.g_x += pixx;
}




/**************************************************************************/
/* Function: wlfline()							  */
/* Description: left arrow function					  */
/**************************************************************************/
wlfline()
{
   page_area.g_x = max(page_area.g_x - pixx,0L);
}





/**************************************************************************/
/* Function: prev_cleanup()						  */
/* Description: Cleanup preview window					  */
/**************************************************************************/
prev_cleanup()
{
        clear_window(prev_handle,2,1);
        slider_chk();
	update_preview_blit();
}





/**************************************************************************/
/* Function: size_fit_handle()						  */
/* Description: Calc page area for size to fit and PADJCNT		  */
/**************************************************************************/
size_fit_handle()
{
	   force_draw_flag = TRUE;
           vsf_interior(shandle,0);
	   pdraw_fit(view_size);
           zoom_setup();
	   cur_scale = get_scale_num(view_size);
	   get_work(prev_handle);
	   update_preview_blit();
	   set_clip(TRUE,&pwork);
/*	   gsx_moff();*/
           vr_recfl(shandle,pxy);
	   clear_window(prev_handle,2,1);
/*	   gsx_mon();*/
	   slider_chk();
	   set_clip(TRUE,&dpwork);
}

