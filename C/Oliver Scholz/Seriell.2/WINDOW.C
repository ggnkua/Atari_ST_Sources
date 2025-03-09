
/*
 * WINDOW.C
 * Fensterroutinen fÅr TT44TT
 * Copyright (c) 1991 by MAXON
 * Autoren: Oliver Scholz & Uwe Hax
 */

#include <aes.h>
#include <portab.h>
#include <vdi.h>
#include <stdlib.h>
#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "tt44tt.h"
#include "termdefs.h"
#include "proto.h"

#define GLOBAL extern
#include "variable.h"

/*
 * Fenster îffnen
 */

WORD open_window(WORD wind_index)
{
  WORD x,y,w,h,iconidx;
  
  wind_get(DESKTOP,WF_WORKXYWH,&x,&y,&w,&h);
  
  if (window[wind_index].handle==-1)
  { 
    window[wind_index].handle=
        wind_create(elements,x,y,w,h);
    if (window[wind_index].handle >= 0)
    {
      if (curr_icon == -1)
      {
        curr_device = wind_index;
        ienable(TRUE);
      }
      top_window = wind_index;
      window[wind_index].x_corner=0;
      window[wind_index].y_corner=0;
      init_terminal(wind_index);
      wind_set(window[wind_index].handle,WF_NAME,
               window[wind_index].title);
      wind_set(window[wind_index].handle,WF_INFO,
               window[wind_index].info);
      wind_snap(&window[wind_index].x,
                &window[wind_index].y,
                &window[wind_index].w,
                &window[wind_index].h);
      iconidx=iconlist[wind_index];

      if (zoomflag)
        graf_growbox(newdesk[iconidx].ob_x,
                     newdesk[iconidx].ob_y,
                     newdesk[iconidx].ob_width,
                     newdesk[iconidx].ob_height,
                     window[wind_index].x,
                     window[wind_index].y,
                     window[wind_index].w,
                     window[wind_index].h);

      wind_info(wind_index);
      wind_open(window[wind_index].handle,
                window[wind_index].x,
                window[wind_index].y,
                window[wind_index].w,
                window[wind_index].h);     

      size_slider(window[wind_index].handle);
      pos_slider(wind_index,VERTICAL);
      pos_slider(wind_index,HORIZONTAL);
    }
    else
    {
      form_alert(1,NO_WINDOW);
      return(FALSE);
    }
  }
  else
    wm_topped(window[wind_index].handle);
  return(TRUE);  
}

/*
 * Koordinaten des Fensterarbeitsbereiches
 * auf Zeichengrenzen ausrichten
 */
 
VOID wind_snap(WORD *x,WORD *y,WORD *w,WORD *h)
{
  WORD wx,wy,ww,wh;
  
  wind_calc(WC_WORK,elements,*x,*y,*w,*h,
            &wx,&wy,&ww,&wh);

  wx &= 0xfff8;
  ww &= 0xfff8;
  if (hchar==8)
    wh &= 0xfff8;
  else
    wh &= 0xfff0;

  wind_calc(WC_BORDER,elements,wx,wy,ww,wh,
            x,y,w,h);
}

/*
 * Fenster nach vorne bringen
 */

VOID wm_topped(WORD whandle)
{
  WORD index;

  index=get_index(whandle);
  wind_set(whandle,WF_TOP);
  if (curr_icon == -1)
  {
    curr_device = index;
    ienable(TRUE);
  }
  top_window = index;
}

/*
 * Fensterinhalt neuzeichnen
 */

VOID wm_redraw(WORD whandle,WORD wx,WORD wy,
               WORD ww,WORD wh)
{
  GRECT t1,t2;
  WORD i,k;
  CHAR out[TERM_WIDTH+1];
  WORD index;
  WORD x,y,h,w;
    
  t2.g_x=wx;
  t2.g_y=wy;
  t2.g_w=ww;
  t2.g_h=wh;

  index=get_index(whandle);
  cursor(index,CURSOR_OFF);

  wind_get(whandle,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,
           &t1.g_w,&t1.g_h);
  wind_get(whandle,WF_WORKXYWH,&x,&y,&w,&h);
  
  while (t1.g_w && t1.g_h)
  {
    if (rc_intersect(&t2,&t1))
    {                            
      /* schnellere Ausgabe */
      if (t1.g_x+t1.g_w==x+w)
        t1.g_w += wchar;
      clipping(&t1,TRUE);
      
      for (i=window[index].y_corner,k=0;
           i<=TERM_HEIGHT;
           i++,k++)
      {
        /* schnellere Ausgabe */
        strcpy(out,&terminal[index]
            .screen[i][window[index].x_corner]);
        out[w/wchar]=EOS;    
        v_gtext(vdi_handle,x,
                y+k*hchar+distances[4],out);
      }
    }
    wind_get(whandle,WF_NEXTXYWH,&t1.g_x,&t1.g_y,
             &t1.g_w,&t1.g_h);
  }
  clipping(&t1,FALSE);
  cursor(index,CURSOR_ON);
}

/*
 * na, die kennt wohl jeder... 
 */

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

/*
 * Clipping Rectangle setzen/lîschen
 */

VOID clipping(GRECT *rect,WORD mode)
{
  WORD pxyarray[4];
  
  pxyarray[0]=rect->g_x;
  pxyarray[1]=rect->g_y;
  pxyarray[2]=rect->g_x+rect->g_w-1;
  pxyarray[3]=rect->g_y+rect->g_h-1;

  vs_clip(vdi_handle,mode,pxyarray);
}

/*
 * Fenster verschieben
 */

VOID wm_moved(WORD *mesg_buff)
{
  wind_snap(&mesg_buff[4],&mesg_buff[5],
            &mesg_buff[6],&mesg_buff[7]);
  wind_set(mesg_buff[3],WF_CURRXYWH,
           mesg_buff[4],mesg_buff[5],
           mesg_buff[6],mesg_buff[7]);
}          
 
/*
 * Fenster schlieûen
 */

VOID wm_closed(WORD whandle)
{
  WORD iconidx;
  WORD widx;
  WORD top_hnd;
  
  widx=get_index(whandle);
  window[widx].handle=-1;

  /* fÅr's nÑchste ôffnen: alte Pos. merken */
  wind_get(whandle,WF_CURRXYWH,
           &window[widx].x,&window[widx].y,
           &window[widx].w,&window[widx].h);

  wind_close(whandle);
  iconidx=iconlist[widx];
  if (zoomflag)
    graf_shrinkbox(newdesk[iconidx].ob_x,
                  newdesk[iconidx].ob_y,
                  newdesk[iconidx].ob_width,
                  newdesk[iconidx].ob_height,
                  window[widx].x,window[widx].y,
                  window[widx].w,window[widx].h);
  wind_delete(whandle);

  wind_get(whandle,WF_TOP,&top_hnd,
           &dummy,&dummy,&dummy);

  top_window=get_index(top_hnd);

  if (curr_icon == -1)
    curr_device=top_window;

  if (curr_device == -1)
    ienable(FALSE);
}

/* 
 * Fenster auf volle Grîûe
 */

VOID wm_fulled(WORD *mesg_buff)
{
  WORD x,y,w,h;
  WORD index;
  
  index=get_index(mesg_buff[3]);
  
  if (window[index].fulled)
    wind_get(mesg_buff[3],WF_PREVXYWH,
             &x,&y,&w,&h);
  else
    wind_get(DESKTOP,WF_WORKXYWH,&x,&y,&w,&h);

  wind_max(&x,&y,&w,&h);
  wind_snap(&x,&y,&w,&h);
  wind_set(mesg_buff[3],WF_CURRXYWH,x,y,w,h);
  size_slider(mesg_buff[3]);
  window[index].fulled=!window[index].fulled;
  adjust(mesg_buff[3]);
}

/*
 * Einer der Pfeile wurde angeklickt
 */
         
VOID wm_arrowed(WORD *mesg_buff)
{
  WORD wind_index;
  WORD x,y,w,h;
  WORD xpage,ypage;
  
  wind_index=get_index(mesg_buff[3]);
  wind_get(mesg_buff[3],WF_WORKXYWH,&x,&y,&w,&h);
  xpage=w/wchar;
  ypage=h/hchar;
 
  switch (mesg_buff[4])
  {
    case WA_UPLINE:
      if (window[wind_index].y_corner>0)
      {
        cursor(wind_index,CURSOR_OFF);
        window[wind_index].y_corner--; 
              
        scroll(wind_index,SCROLL_DOWN);
        pos_slider(wind_index,VERTICAL);  
        cursor(wind_index,CURSOR_ON);
      }
      break;
    
    case WA_DNLINE:
      if (window[wind_index].y_corner+ypage
          < TERM_HEIGHT)
      {
        cursor(wind_index,CURSOR_OFF);
        window[wind_index].y_corner++; 
            
        scroll(wind_index,SCROLL_UP);
        pos_slider(wind_index,VERTICAL);  
        cursor(wind_index,CURSOR_ON);
      }
      break;

    case WA_LFLINE:
      if (window[wind_index].x_corner > 0)
      {
        window[wind_index].x_corner--; 
              
        wm_redraw(mesg_buff[3],x,y,w,h);
        pos_slider(wind_index,HORIZONTAL);  
      }
      break;
    
    case WA_RTLINE:  
      if (window[wind_index].x_corner+xpage
          < TERM_WIDTH)
      {
        window[wind_index].x_corner++; 
            
        wm_redraw(mesg_buff[3],x,y,w,h);
        pos_slider(wind_index,HORIZONTAL);  
      }
      break;
    
    case WA_UPPAGE:
      if (window[wind_index].y_corner-ypage<0)
        window[wind_index].y_corner=0;
      else
        window[wind_index].y_corner -= ypage;
      wm_redraw(mesg_buff[3],x,y,w,h);
      pos_slider(wind_index,VERTICAL);
      break;
    
    case WA_DNPAGE:
      if (window[wind_index].y_corner+2*ypage
          > TERM_HEIGHT)
        window[wind_index].y_corner=
                           TERM_HEIGHT-ypage;
      else
        window[wind_index].y_corner += ypage;
      wm_redraw(mesg_buff[3],x,y,w,h);
      pos_slider(wind_index,VERTICAL);
      break;
                     
    case WA_LFPAGE:
      if (window[wind_index].x_corner-xpage<0)
        window[wind_index].x_corner=0;
      else
        window[wind_index].x_corner -= xpage;
      wm_redraw(mesg_buff[3],x,y,w,h);
      pos_slider(wind_index,HORIZONTAL);
      break;
    
    case WA_RTPAGE:
      if (window[wind_index].x_corner+2*xpage
          > TERM_WIDTH)
        window[wind_index].x_corner=
                             TERM_WIDTH-xpage;
      else
        window[wind_index].x_corner += xpage;
      wm_redraw(mesg_buff[3],x,y,w,h);
      pos_slider(wind_index,HORIZONTAL);
      break;
  }
}

/*
 * Vertikalen Slider setzen
 */
                                     
VOID wm_vslid(WORD *mesg_buff)
{
  WORD x,y,w,h;
  WORD index;
  
  index=get_index(mesg_buff[3]);
    
  wind_get(mesg_buff[3],WF_WORKXYWH,&x,&y,&w,&h);
  window[index].y_corner=
    (WORD)((TERM_HEIGHT-h/hchar) *
           (LONG)mesg_buff[4]/1000L);

  wind_set(mesg_buff[3],WF_VSLIDE,mesg_buff[4]);
  wm_redraw(mesg_buff[3],x,y,w,h);
  pos_slider(index,VERTICAL);
}

/*
 * Horizontalen Slider setzen
 */
                            
VOID wm_hslid(WORD *mesg_buff)
{
  WORD index;
  WORD x,y,w,h;
  
  index=get_index(mesg_buff[3]);
  wind_get(mesg_buff[3],WF_WORKXYWH,&x,&y,&w,&h);
  window[index].x_corner=
        (WORD)((TERM_WIDTH-w/wchar) *
               (LONG)mesg_buff[4]/1000L);

  wind_set(mesg_buff[3],WF_HSLIDE,mesg_buff[4]);
  wm_redraw(mesg_buff[3],x,y,w,h);
  pos_slider(index,HORIZONTAL);
}

/*
 * Fenstergrîûe verÑndern
 */
          
VOID wm_sized(WORD *mesg_buff)
{
  wind_max(&mesg_buff[4],&mesg_buff[5],
       &mesg_buff[6],&mesg_buff[7]);
  wind_snap(&mesg_buff[4],&mesg_buff[5],
        &mesg_buff[6],&mesg_buff[7]);
  wind_set(mesg_buff[3],WF_CURRXYWH,
       mesg_buff[4],mesg_buff[5],
       mesg_buff[6],mesg_buff[7]);
  size_slider(mesg_buff[3]);
  adjust(mesg_buff[3]);
  window[get_index(mesg_buff[3])].fulled=FALSE;
}

/*
 * Fenster nicht Åber Terminalgrîûe setzen
 */

VOID wind_max(WORD *x,WORD *y,WORD *w,WORD *h)
{
  WORD wx,wy,ww,wh;
  
  wind_calc(WC_WORK,elements,*x,*y,*w,*h,
        &wx,&wy,&ww,&wh);

  if (ww>wchar*TERM_WIDTH)
    ww=wchar*TERM_WIDTH;
    
  if (wh>hchar*TERM_HEIGHT)
    wh=hchar*TERM_HEIGHT;

  wind_calc(WC_BORDER,elements,wx,wy,ww,wh,
        x,y,w,h);
}

/*
 * Informationszeile im Fenster setzen
 */

VOID wind_info(WORD device)
{
  CHAR buffer[20];
  CHAR *p;

  read_port(device);

  get_baud_string(port[device].baudrate, buffer);
  strcpy(window[device].info," ");
  strcat(window[device].info,buffer);
  strcat(window[device].info," Baud  ");

  if ( ((port[device].ucr) & 0x60) == 0x20 )
    buffer[0]='7';
  else
    buffer[0]='8';

  switch((port[device].ucr) & 0x06)
  { 
    case 0x00:
    case 0x02:  buffer[1]='N';
                break;
                    
    case 0x04:  buffer[1]='O';
                break;

    case 0x06:  buffer[1]='E';
  }
  
  if ( ((port[device].ucr) & 0x18) == 0x18 )
    buffer[2]='2';
  else
    buffer[2]='1';
                    
  buffer[3]='\0';
  strcat(window[device].info,buffer);
    
  switch(port[device].flowctrl)
  {
    case P_NONE: p="  kein Protokoll";
                 break;

    case P_XON:  p="  XON/XOFF";
                 break;

    case P_RTS:  p="  RTS/CTS";
  }

  strcat(window[device].info,p);
  if (window[device].handle >= 0)
    wind_set(window[device].handle,WF_INFO,
             window[device].info);
}

/*
 * Slidergrîûe einstellen
 */

VOID size_slider(WORD wind_handle)
{
  WORD x,y,w,h;
  
  wind_get(wind_handle,WF_WORKXYWH,&x,&y,&w,&h);
  
  wind_set(wind_handle,WF_VSLSIZE,
          (WORD)min(1000,
          (ULONG)((1000L*h)/hchar)/TERM_HEIGHT));

  wind_set(wind_handle,WF_HSLSIZE,
          (WORD)min(1000,
          (ULONG)((1000L*w)/wchar)/TERM_WIDTH));
}

/*
 * Slider positionieren
 */

VOID pos_slider(WORD wind_index, WORD vh_flag)
{
  WORD x,y,w,h;
  UWORD pos;
  
  wind_get(window[wind_index].handle,WF_WORKXYWH,
           &x,&y,&w,&h);
  
  if (vh_flag==VERTICAL)
  {
    if (TERM_HEIGHT-h/hchar==0)
      pos=1000;
    else
      pos=(UWORD)(1000L*window[wind_index]
          .y_corner/(TERM_HEIGHT-h/hchar));
    
    wind_set(window[wind_index].handle,
             WF_VSLIDE,pos);
  }
  else
  {
    if (TERM_WIDTH-w/wchar==0)
      pos=1000;
    else
      pos=(UWORD)(1000L*window[wind_index]
          .x_corner/(TERM_WIDTH-w/wchar));
    
    wind_set(window[wind_index].handle,
             WF_HSLIDE,pos);
  }
}

/*
 * Fensternummer zur Handle ermitteln
 */

WORD get_index(WORD whandle)
{
  WORD i;
  
  for (i=0; i<num_aux; i++)
    if(window[i].handle==whandle)
      return(i);
  return(-1);    
}                

/*
 * Bei seitenweisem Scrolling nicht Åber die
 * Terminalgrenzen hinausgehen
 */
 
VOID adjust(WORD whandle)
{
  WORD x,y,w,h;
  WORD c_height,c_width;
  WORD wind_index;
  
  wind_index=get_index(whandle);
  wind_get(window[wind_index].handle,WF_WORKXYWH,
           &x,&y,&w,&h);

  c_height=h/hchar;
  c_width=w/wchar;

  if (window[wind_index].y_corner+c_height
      > TERM_HEIGHT)
    window[wind_index].y_corner=
                      TERM_HEIGHT-c_height;

  if (window[wind_index].x_corner+c_width
      > TERM_WIDTH)
    window[wind_index].x_corner=
                       TERM_WIDTH-c_width;

  pos_slider(wind_index,VERTICAL);
  pos_slider(wind_index,HORIZONTAL);
}


