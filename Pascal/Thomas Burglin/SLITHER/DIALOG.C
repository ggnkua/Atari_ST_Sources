/***   open the virtual screen workstation and get handle   *********/

#include "extern.h"

WORD open_workstation(form)

	MFDB *form;
	
	{
	int x;
	int work_in[11];
	int work_out[57];
	int handle;
	int dum;

 	gdos = 0;

	asm 
		{
			move.w    #-2,D0
			trap      #2
			cmp.w     #-2, D0
			beq       no_gdos
			move.w    #1, gdos
no_gdos:
      }
      
   /* Initialize workstation variables  */
   
   if (gdos)
   	work_in[0] = Getrez() + 2;
   else
   	work_in[0] = 1;
   for (x = 1; x < 10; x++)
   	work_in[x] = 1;   
   work_in[10] = 2;      /* set RC coordinates   */
   
   handle = graf_handle (&dum,&dum,&dum,&dum);
   v_opnvwk (work_in, &handle, work_out);
   
   /*  set up MFDB  screen raster    */
   
   form -> fd_addr = Logbase ();     /* formerly the xbios call to screen */
                                     /* here you have to get the screenadr*/
   form -> fd_w    = work_out[0] + 1;  /* screenwidth in pixel  */
   form -> fd_h    = work_out[1] + 1;  /* heigth of screen in pixel */
   form -> fd_wdwidth = (work_out[0] + 1) / 16;
   form -> fd_stand = 0;    /* RC coordinate system  */
   switch (work_out[13])
      {
      case 16: form -> fd_nplanes = 4; break;
      case 08: form -> fd_nplanes = 3; break;
      case 04: form -> fd_nplanes = 2; break;
      default: form -> fd_nplanes = 1; break;
      }
      
   return (handle);
   }

/***********************save screen into buffer**************/

void screencopy (from,to)       /* copy screen to buffer and back */

   MFDB *from, *to;
  {
   int i;
   int pxy[8];
   
   v_hide_c (handle);

   pxy[0] = pxy[4] = wi_1; pxy[1] = pxy[5] = wi_2;
   pxy[2] = pxy[6] = wi_1 + wi_3 - 1;
   pxy[3] = pxy[7] = wi_2 + wi_4 - 1;

   vro_cpyfm (handle, S_ONLY, pxy, from, to); 

   v_show_c (handle,1);
  }

/* save screen to buffer  */

void screensave ()          

  {
   screencopy (&screen,&screenbuffer);
  }

/* restore screen from buffer */

void screenrestore ()

  {
  screencopy (&screenbuffer,&screen);
  }

/*****************general dialog box handler***********************/

WORD dodialog (objcadr,index)

   LWORD objcadr;
   WORD index;
  {
   WORD x, y, w, h;
   WORD item;
   
   form_center (objcadr,&x,&y,&w,&h);
   objc_draw (objcadr,0,10,x,y,w,h);
   item = form_do (objcadr,index);
   screenrestore();
   return (item);
  }

/****************************************************************/
/* find and redraw all clipping rectangles			*/
/****************************************************************/

do_redraw(xc,yc,wc,hc)

   int xc,yc,wc,hc;
  {
   GRECT t1,t2;
   int   pxy[8];
   
   v_hide_c (handle);
	wind_update(1);
	t2.g_x=xc;
	t2.g_y=yc;
	t2.g_w=wc;
	t2.g_h=hc;
	wind_get(w_handle,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	while (t1.g_w && t1.g_h) 
	   {
	   if (rect_intersect(t2,t1,&t1)) 
	      {
         pxy[0] = pxy[4] = t1.g_x; pxy[1] = pxy[5] = t1.g_y;
         pxy[2] = pxy[6] = t1.g_x + t1.g_w - 1;
         pxy[3] = pxy[7] = t1.g_y + t1.g_h - 1;
         vro_cpyfm (handle,S_ONLY,pxy,&screenbuffer,&screen); 
	      }
	   wind_get(w_handle,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	   }
	wind_update(0);
   v_show_c (handle,1);
  }

