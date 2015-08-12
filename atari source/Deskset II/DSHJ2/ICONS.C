#include "osbind.h"
#include "deskset2.h"
#include "gemdefs.h"
#include "alert.h"

#define BOOKW 0x0180
#define BOOKH 0x002c

#define MAXPAGE 999

typedef	struct	mfdb
	{
	int	*data;
	int	width;
	int	height;
	int	wwidth;
	int	format;
	int	planes;
	int	res1;
	int	res2;
	int	res3;
	}MFDB;

extern	int bookd[];
extern 	int bookm[];

extern  int shandle;
extern  int sxres,syres;
extern  int splane;
extern  int curr_page;
extern  int prev_handle;
extern  int txt_handle;
extern  char *get_lmem();
extern  int tmplate_flag;

MFDB	mskmfdb;		/* Mask memory form definition block  	*/
MFDB	objmfdb;		/* Object ......			*/
MFDB	scrmfdb;		/* Screen .... Data is always 0L	*/
MFDB	bufmfdb;


int	color_index[2];			/* Used by vrt_cpyfm		 */
int 	bltpxy[20];
int 	savepxy[8];
int	restpxy[8];

int 	xbook;
int 	ybook;

int 	tmpxy[4];

int objw;
int *bltbuffer;
long buffsize;

int pageside;

set_icon_pos()
{
   objw =  (BOOKW)/6;
   xbook = sxres - objw - 10;
   ybook = syres - BOOKH - 5;
}

icon_setup()
{

   buffsize = 4000L * (long)splane;			/* For now */
   bltbuffer = (int *)get_lmem(buffsize);	/* cjg  05-18-88 */
   if(!bltbuffer)
   {
        alert_cntre(ALERT14);
	close_work();			/* blow us away from DeskSET! */
   }

   color_index[0] = 0;
   color_index[1] = 1;
   scrmfdb.data = 0L;

   savepxy[0] = xbook;
   savepxy[1] = ybook;
   savepxy[2] = savepxy[0] + objw - 1;
   savepxy[3] = savepxy[1] + BOOKH - 1;
   savepxy[4] = 0;
   savepxy[5] = 0;
   savepxy[6] = objw - 1;
   savepxy[7] = BOOKH - 1;

   restpxy[0] = 0;
   restpxy[1] = 0;
   restpxy[2] = objw - 1;
   restpxy[3] = BOOKH - 1;
   restpxy[4] = xbook;
   restpxy[5] = ybook;
   restpxy[6] = restpxy[4] + objw - 1;
   restpxy[7] = restpxy[5] + BOOKH - 1;

   bufmfdb.width = objw;
   bufmfdb.height = BOOKH;
   bufmfdb.wwidth = (objw + 15)/16;
   bufmfdb.format = 0;
   bufmfdb.planes = splane;

   objmfdb.width = BOOKW;
   objmfdb.height = BOOKH;
   objmfdb.wwidth = (BOOKW + 15) / 16;
   objmfdb.format = 0;
   objmfdb.planes	= 1;
   
   mskmfdb.width = BOOKW;
   mskmfdb.height = BOOKH;
   mskmfdb.wwidth = (BOOKW + 15) / 16;
   mskmfdb.format = 0;
   mskmfdb.planes	= 1;		

   objmfdb.data = bookd;		/* Set up data for mfdb	     */
   mskmfdb.data = bookm;
   bufmfdb.data = bltbuffer;
   vro_cpyfm(shandle,3,savepxy,&scrmfdb.data,&bufmfdb.data);    
}


page_bk_book()
{
   register int i,j;

   bltpxy[4] = xbook;
   bltpxy[5] = ybook;
   bltpxy[6] = bltpxy[4] + objw - 1;
   bltpxy[7] = bltpxy[5] + BOOKH - 1;
   objmfdb.data = bookd;		/* Set up data for mfdb	     */
   mskmfdb.data = bookm;
   tmpxy[0] = 0;
   tmpxy[1] = 0;
   tmpxy[2] = tmpxy[0] + objw - 1;
   tmpxy[3] = tmpxy[1] + BOOKH - 1;
   for(i = 0;i < 6;i++)
   {
      draw_obj(tmpxy);
      tmpxy[0] += objw;
      tmpxy[2] += objw;
      for(j = 0;j < 3000;j++);
   }
   tmpxy[0] = 0;
   tmpxy[1] = 0;
   tmpxy[2] = tmpxy[0] + objw - 1;
   tmpxy[3] = tmpxy[1] + BOOKH - 1;
   draw_obj(tmpxy);			/* Draw final open book  */
}


page_fd_book()
{
   register int i,j;

   bltpxy[4] = xbook;
   bltpxy[5] = ybook;
   bltpxy[6] = bltpxy[4] + objw - 1;
   bltpxy[7] = bltpxy[5] + BOOKH - 1;
   objmfdb.data = bookd;		/* Set up data for mfdb	     */
   mskmfdb.data = bookm;
   tmpxy[0] = 5*objw;
   tmpxy[1] = 0;
   tmpxy[2] = tmpxy[0] + objw - 1;
   tmpxy[3] = tmpxy[1] + BOOKH - 1;

   for(i = 0;i < 6;i++)
   {
      draw_obj(tmpxy);
      tmpxy[0] -= objw;
      tmpxy[2] -= objw;
      for(j = 0;j < 3000;j++);
   }
}


draw_obj(src)
register int src[];
{
	bltpxy[0] = src[0];
	bltpxy[1] = src[1];
	bltpxy[2] = src[2];
	bltpxy[3] = src[3];
	Vsync();
        vro_cpyfm(shandle,3,restpxy,&bufmfdb.data,&scrmfdb.data);	
	vrt_cpyfm(shandle,2,bltpxy,&mskmfdb.data,&scrmfdb.data,
		color_index);
        color_index[0] = 1;
	color_index[1] = 0;
	vrt_cpyfm(shandle,2,bltpxy,&objmfdb.data,&scrmfdb.data,color_index);
	color_index[0] = 0;
	color_index[1] = 1;
}

icon_clicked(mx,my)
int mx,my;
{
   if(mx > xbook && mx < xbook + objw &&
      my > ybook && my < ybook + BOOKH)
	return(1);
   else 
	return(0);
}

animate_icon(mx,direction)
int mx;
int *direction;
{
   int ret;
   int x,y,w,h;

   wind_get(prev_handle,WF_CURRXYWH,&x,&y,&w,&h);
   if(x + w >= xbook && y + h >= ybook)
	return(0);
   wind_get(txt_handle,WF_CURRXYWH,&x,&y,&w,&h);
   if(x + w >= xbook && y + h >= ybook)
	return(0);
   ret = 1;
   vs_clip(shandle,0,tmpxy);
   gsx_moff();
   if(mx > xbook + (objw/2))
   {
        if(tmplate_flag)
        {
          if(curr_page == -1)
                ret = 0;
          else if(pageside == 0)
          {
            do_pagenum(curr_page+1,1);
          }
        }
        else
        {
	  if(curr_page == MAXPAGE)
	     ret = 0;
	  else if(pageside == 0)			/* Left side */
	  {
	    do_pagenum(curr_page+1,1);	   /* Place text on right side */   
          }
	  else 
	  {
	    page_fd_book();
	    do_pagenum(curr_page+1,0);
	  }
        }
        *direction = PNEXT;
   }
   else
   {
        if(tmplate_flag)
        {
          if(curr_page == -2)
              ret = 0;
          else if(pageside == 1)
          {
	     do_pagenum(curr_page - 1,0);
          }
        }
        else
        {
	  if(curr_page == 0)
	     ret = 0;
	  else if(pageside == 1)
	  {
	     do_pagenum(curr_page - 1,0);
          } 
	  else
	  {
	     page_bk_book();
	     do_pagenum(curr_page - 1,1);
	  }
        }
        *direction = PPREV;
   }
   gsx_mon();
   screen_clip();
   return(ret);
}
