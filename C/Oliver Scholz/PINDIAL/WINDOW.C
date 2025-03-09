/*
 * WINDOW.C
 * by Oliver Scholz
 * Copyright (c) 1991 MAXON
 */

#include <aes.h>
#include <portab.h>
#include <vdi.h>

#include "defs.h"

#define GLOBAL extern
#include "globals.h"

VOID clipping(GRECT *rect,WORD mode);
WORD rc_intersect(GRECT *r1,GRECT *r2);

VOID open_window(VOID)
{
  WORD x,y,w,h;
  
  wind_get(DESKTOP,WF_WORKXYWH,&x,&y,&w,&h);

  window.handle = wind_create(ELEMENTS,x,y,w,h);
  if (window.handle >= 0)
  {
    window.x=x;
    window.y=y;
    window.w=w;
    window.h=h;
      
    wind_set(window.handle,WF_NAME,
            "Pinbare Dialogboxen - Testfenster");

    wind_open(window.handle, window.x, window.y,
              window.w, window.h);     
  }
  else
  {
    form_alert(1,NO_WINDOW);
  }
}

/* Fensterinhalt neuzeichnen */

VOID wm_redraw(WORD whandle,WORD wx,WORD wy,
               WORD ww,WORD wh)
{
  GRECT t1,t2;
  WORD x,y,h,w;
  WORD pxy[4];
  
  t2.g_x=wx;
  t2.g_y=wy;
  t2.g_w=ww;
  t2.g_h=wh;

  wind_get(whandle,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,
           &t1.g_w,&t1.g_h);
  wind_get(whandle,WF_WORKXYWH,&x,&y,&w,&h);

  while (t1.g_w && t1.g_h)
  {
    if (rc_intersect(&t2,&t1))
    {                            
      clipping(&t1,TRUE); 
      
      /* Rechteck zeichnen */
      vsf_interior(vdi_handle,FIS_SOLID);
      pxy[0]=x; pxy[1]=y;
      pxy[2]=x+w; pxy[3]=y+h;
      vsf_color(vdi_handle,0);
      v_bar(vdi_handle, pxy);
      
      /* Kreis zeichnen */
      vsf_color(vdi_handle,1);
      vsf_interior(vdi_handle,FIS_PATTERN);
      v_ellipse(vdi_handle,x+w/2,y+h/2,w/2,h/2);
    }
    wind_get(whandle,WF_NEXTXYWH,&t1.g_x,&t1.g_y,
             &t1.g_w,&t1.g_h);
  }
  clipping(&t1,FALSE);
}

WORD rc_intersect(GRECT *r1,GRECT *r2)
{
   WORD x,y,w,h;

   x=max(r2->g_x,r1->g_x);
   y=max(r2->g_y,r1->g_y);
   w=min(r2->g_x+r2->g_w,r1->g_x+r1->g_w);
   h=min(r2->g_y+r2->g_h,r1->g_y+r1->g_h);

   r2->g_x=x;
   r2->g_y=y;
   r2->g_w=w-x;
   r2->g_h=h-y;

   return((w>x) && (h>y));
}

VOID clipping(GRECT *rect,WORD mode)
{
  WORD pxyarray[4];
  
  pxyarray[0]=rect->g_x;
  pxyarray[1]=rect->g_y;
  pxyarray[2]=rect->g_x+rect->g_w-1;
  pxyarray[3]=rect->g_y+rect->g_h-1;

  vs_clip(vdi_handle,mode,pxyarray);
}
