/* Heatmap program */

#include "obdefs.h"
#include "define.h"
#include "gemdefs.h"
#include "osbind.h"

#define WI_KIND (MOVER|CLOSER|NAME)

int h[16][16];

extern int  gl_apid;

int   gl_hchar;
int   gl_wchar;
int   gl_wbox;
int   gl_hbox;

int   phys_handle;
int   handle;
int   wi_handle;
int   ci_handle;

int   xdesk,ydesk,hdesk,wdesk;
int   xwork,ywork,hwork,wwork;
int   cxwork,cywork,chwork,cwwork;
int   xold, yold, wold, hold;

int   msgbuff[8];
int   keycode;
int   mx,my;
int   butdown;
int   ret;

int   hidden;
int   fulled;

int   contrl[12];
int   intin[128];
int   ptsin[128];
int   intout[128];
int   ptsout[128];

int   work_in[11];
int   work_out[57];

char path[128];
char currpath[128];
char file[13];

hide_mouse()
{
   if (!hidden)
   {
      graf_mouse(M_OFF, 0x0L);
      hidden=TRUE;
   }
}

show_mouse()
{
   if (hidden)
   {
      graf_mouse(M_ON,0x0L);
      graf_mouse(ARROW,0x0L);
      hidden=FALSE;
   }
}

setup()
{
   int i;

   short p[3];

   hidden=FALSE;
   fulled=FALSE;
   butdown=TRUE;

   for (i=0;i<10;work_in[i++]=1);
   work_in[10]=2;

   phys_handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
   handle=phys_handle;

   wind_get(0, WF_WORKXYWH,
            &xdesk, &ydesk, &wdesk, &hdesk);

   v_opnvwk(work_in,&handle,work_out);

   wi_handle=wind_create(WI_KIND, xdesk, ydesk, 160, 160);
   wind_set(wi_handle, WF_NAME, "Heatmap", 0, 0);
   graf_growbox(xdesk+wdesk/2, ydesk+hdesk/2,
                gl_wbox, gl_hbox,
                xdesk, ydesk, wdesk, hdesk);
   wind_open(wi_handle, xdesk, ydesk, 160, 160);
   wind_get(wi_handle, WF_WORKXYWH, &xwork, &ywork, &wwork, &hwork);

   ci_handle=wind_create(WI_KIND, xdesk+162, ydesk, 128, 160);
   wind_set(ci_handle, WF_NAME, "Alerts", 0, 0);
   wind_open(ci_handle, xdesk+162, ydesk, 128, 160);
   wind_get(ci_handle, WF_WORKXYWH, &cxwork, &cywork, &cwwork, &chwork);

   for (i=2;i<7;i++)
   {
      p[0]=0;
      p[1]=i*150;
      p[2]=0;
      vs_color(handle, i, &p);
   }

   for (i=7;i<16;i++)
   {
      p[0]=i*150;
      p[1]=0;
      p[2]=0;
      vs_color(handle, i, &p);
   }

}

teardown()
{
   int i;

   if (wi_handle == 0)
      return;

   wind_close(wi_handle);
   graf_shrinkbox(xwork+wwork/2, ywork+hwork/2,
                  gl_wbox, gl_hbox,
                  xwork, ywork, wwork, hwork);
   wind_delete(wi_handle);

   wind_close(ci_handle);
   graf_shrinkbox(cxwork+cwwork/2, cywork+chwork/2,
                  gl_wbox, gl_hbox,
                  cxwork, cywork, cwwork, chwork);
   wind_delete(ci_handle);

   v_clsvwk(handle);
}

set_clip(x,y,w,h)
int x,y,w,h;
{
   int clip[4];
   clip[0]=x;
   clip[1]=y;
   clip[2]=x+w;
   clip[3]=y+h;
   vs_clip(handle,1,clip);
}

do_redraw(xc,yc,wc,hc)
int xc,yc,wc,hc;
{
   GRECT t1,t2;

   hide_mouse();

   wind_update(TRUE);

   t2.g_x=xc;
   t2.g_y=yc;
   t2.g_w=wc;
   t2.g_h=hc;

   wind_get(wi_handle, WF_FIRSTXYWH,
            &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);

   while (t1.g_w && t1.g_h)
   {
      /* clip and redraw if rectangle intersects */
      if (rc_intersect(&t2, &t1))
      {
         set_clip(t1.g_x, t1.g_y, t1.g_w, t1.g_h);
         draw_heatmap();
      }

      /* get next rect and loop */
      wind_get(wi_handle, WF_NEXTXYWH,
               &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
   }

   wind_update(FALSE);

   show_mouse();

}

do_alerts_redraw(xc,yc,wc,hc)
int xc,yc,wc,hc;
{
   GRECT t1,t2;

   hide_mouse();

   wind_update(TRUE);

   t2.g_x=xc;
   t2.g_y=yc;
   t2.g_w=wc;
   t2.g_h=hc;

   wind_get(ci_handle, WF_FIRSTXYWH,
            &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);

   while (t1.g_w && t1.g_h)
   {
      /* clip and redraw if rectangle intersects */
      if (rc_intersect(&t2, &t1))
      {
         set_clip(t1.g_x, t1.g_y, t1.g_w, t1.g_h);
         draw_alerts();
      }

      /* get next rect and loop */
      wind_get(ci_handle, WF_NEXTXYWH,
               &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
   }

   wind_update(FALSE);

   show_mouse();

}

calculate_heatmap()
{
#include "heatmap.h"
}

draw_alerts()
{
   int barcoords[4];
   int i,j,k,p;
   char out[24];

   vsf_interior(handle,1);
   vsf_style(handle,1);
   vsf_color(handle,0);

   barcoords[0]=cxwork;
   barcoords[1]=cywork;
   barcoords[2]=cxwork+cwwork-1; /* VDI coords are 0 based. */
   barcoords[3]=cywork+chwork-1;
   v_bar(handle,barcoords);

   p=0;

   for (j=0;j<16;j++)
      for (i=0;i<16;i++)
      {
         if (h[j][i]>6)
         {
            vst_color(handle,h[j][i]);
            sprintf(out,"%d: %d,%d",p+1,i,j);
            v_gtext(handle,cxwork+4, (p*10)+cywork+10, out);
            p++;
         }
      }
}

draw_heatmap()
{
   int barcoords[4];
   int i,j;

   /* blank the window */

   vsf_interior(handle,1);
   vsf_style(handle,1);
   vsf_color(handle,0);
   barcoords[0]=xwork;
   barcoords[1]=ywork;
   barcoords[2]=xwork+wwork-1; /* VDI coords are 0 based. */
   barcoords[3]=ywork+hwork-1;
   v_bar(handle,barcoords);

   for (j=0;j<16;j++)
   {
      for (i=0;i<16;i++)
      {
         vsf_color(handle,h[j][i]);
         vsl_color(handle,0);
         vsf_perimiter(handle,1);
         barcoords[0]=i*10+xwork;
         barcoords[1]=j*10+ywork;
         barcoords[2]=i*10+xwork+10;
         barcoords[3]=j*10+ywork+10;
         v_bar(handle,barcoords);
      }
   }
   vsf_perimiter(handle,0);
}

multi()
{
   int event;

   do
   {
      event = evnt_multi(MU_MESAG | MU_BUTTON | MU_KEYBD,
                         1,1,butdown,
                         0,0,0,0,0,
                         0,0,0,0,0,
                         msgbuff, 0, 0, &mx, &my, &ret, &ret, &keycode, &ret);

   wind_update(TRUE);

   if (event & MU_MESAG)
      switch(msgbuff[0])
      {
         case WM_REDRAW:
            if (msgbuff[3]==wi_handle)
               do_redraw(msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
            else
               do_alerts_redraw(msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
            break;
         case WM_NEWTOP:
         case WM_TOPPED:
            if (msgbuff[3]==wi_handle)
               wind_set(wi_handle, WF_TOP,0,0,0,0);
            else
               wind_set(ci_handle, WF_TOP,0,0,0,0);
            break;
         case WM_MOVED:
            if (msgbuff[3]==wi_handle)
            {
               wind_set(wi_handle, WF_CURRXYWH, msgbuff[4], msgbuff[5], msgbuff[6], msgbuff[7]);
               wind_get(wi_handle, WF_WORKXYWH, &xwork, &ywork, &wwork, &hwork);
            }
            else
            {
               wind_set(ci_handle, WF_CURRXYWH, msgbuff[4], msgbuff[5], msgbuff[6], msgbuff[7]);
               wind_get(ci_handle, WF_WORKXYWH, &cxwork, &cywork, &cwwork, &chwork);
            }
            break;
      }

   wind_update(FALSE);


   } while (!((event & MU_MESAG) && (msgbuff[0] == WM_CLOSED)));
}

main()
{
   appl_init();
   setup();
   calculate_heatmap();
   multi();
   teardown();
   appl_exit();
}

