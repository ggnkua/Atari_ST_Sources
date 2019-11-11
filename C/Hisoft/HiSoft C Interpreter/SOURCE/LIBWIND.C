/**************************************************************************/
/**************************************************************************/
/*
**                      Window Library
*/
/**************************************************************************/
/**************************************************************************/
 
#include "define.h"

extern WORD handle;
extern WORD gl_hchar,gl_wchar;
static WORD w_open[20];
             /* indicates whether a window is open */
#define OPEN 42
#define CLOSED  0

static WORD x_pos[20], y_pos[20];
             /* position of graphics cursor */
 
static WORD xwork[20], ywork[20], wwork[20], hwork[20];
             /* coords of work area */
/*----------------------*/
/*      clip            */
/*----------------------*/
VOID clip(window)     
WORD window;
{
WORD pxyarray[4];
WORD top_wind;
        wind_get(window,WF_TOP,&top_wind,&top_wind,&top_wind,&top_wind);
        if (top_wind == window)
                return;
        wind_set(window,WF_TOP,0,0,0,0);
        pxyarray[0] = xwork[window];
        pxyarray[1] = ywork[window];
        pxyarray[2] = xwork[window] + wwork[window] - 1;
        pxyarray[3] = ywork[window] + hwork[window] - 1;
        vs_clip(handle,TRUE,pxyarray);
}
/*----------------------*/
/*      open_window     */
/*----------------------*/
LONG open_window(type,x,y,w,h,title,comment)
LONG type,x,y,w,h;
BYTE *title,*comment;
{
LONG window;
WORD xmin,ymin;
WORD xx,yy,ww,hh;
WORD arr[6];
        if (type >= 0)
        {
                if (x < 0)
                        x = 0;
                if (y < gl_hchar + 3)
                        y = gl_hchar + 3;
                if (!(w && h))
                {
                        wind_get(0,WF_WORKXYWH,&xx,&yy,&ww,&hh);
                        x=xx;
                        y=yy;
                        w=ww;
                        h=hh;
                }
                if (w <= 40)
                        w = 40;
                if (h <= 40)
                        h = 40;
                window = wind_create(type,x,y,w,h);
                if (window > 0)
                {
                        w_open[window]=OPEN;
                        graf_mouse(M_OFF,0x0L);
                        wind_update(BEG_UPDATE);
                        if (type & 1)
                                wind_set(window, WF_NAME,((LONG)title)>>16,
                                              ((LONG)title),((WORD)0),((WORD)0));
                        if (type & 0x10)
                                wind_set(window, WF_INFO,((LONG)comment)>>16,
                                          ((LONG)comment),((WORD)0),((WORD)0));
                        wind_open(window,x,y,w,h);
                        wind_get(window,WF_WORKXYWH,&(xwork[window]),
                         &(ywork[window]),&(wwork[window]),&(hwork[window]));
                        vst_alignment(handle, 0, 5, &xmin, &ymin);
                        clear_window(window);
                        wind_update(END_UPDATE);
                        event(0,0,arr,0,0,0);/* wait for a re-draw event */
                        graf_mouse(M_ON,0x0L);
                }
        }
        else
                window = 0;
        return(window);
}
/*----------------------*/
/*      close_window    */
/*----------------------*/
LONG close_window(window)
LONG window;
{
LONG status;
        if (window > 0 && w_open[window])
        {
                w_open[window] = CLOSED;
                graf_mouse(M_OFF,0x0L);
                wind_update(BEG_UPDATE);
                if (status = wind_close(window))
                        status = wind_delete(window);
                wind_update(END_UPDATE);
                graf_mouse(M_ON,0x0L);
        }
        return(status);
}
/*----------------------*/
/*      clear_window    */
/*----------------------*/
LONG clear_window(window)
LONG window;
{
WORD temp[4];
        if (window <= 0 || !w_open[window])
                return(FALSE);
        clip(window);
        vsf_interior(handle,1);
        vsf_color(handle,0);
        temp[0]=xwork[window];
        temp[1]=ywork[window];
        temp[2]=xwork[window] + wwork[window] - 1;
        temp[3]=ywork[window] + hwork[window] - 1;
        vr_recfl(handle,temp);             /* blank the interior */
        vsf_color(handle,1);
        pos_window(window,0,0);
        return(TRUE);
}
/*----------------------*/
/*      print_window    */
/*----------------------*/
LONG print_window(window,str)
WORD window;
BYTE *str;
{
        if (window > 0 && w_open[window])
        {
                clip(window);
                v_gtext(handle,x_pos[window],y_pos[window],str);
                y_pos[window] += gl_hchar;
                return (TRUE);
        }
        else
                return (FALSE);
}
/*----------------------*/
/*      pos_window      */
/*----------------------*/
LONG pos_window(window,x,y)
WORD window,x,y;
{
        if (window > 0 && w_open[window])
        {
                x_pos[window] = x * gl_wchar + xwork[window];
                y_pos[window] = y * gl_hchar + ywork[window];
                return (TRUE);
        }
        else
                return (FALSE);
}
 
/*----------------------*/
/*      size_window     */
/*----------------------*/
LONG size_window(window,x,y,w,h)
LONG window,*x,*y,*w,*h;
{
WORD xx,yy,ww,hh;
LONG cr;
        if (window >= 0 && w_open[window])
        {
                cr = wind_get(window,WF_WORKXYWH,&xx,&yy,&ww,&hh);
                *x=xx;
                *y=yy;
                *w=ww;
                *h=hh;
                return(cr);
        }
        else
                return (FALSE);
}
 
/*----------------------*/
/*      close_all       */
/*----------------------*/
VOID close_all()     /* close all the opened windows */
{
int i;
        for (i=0;i<20;i++)
                if (w_open[i] == OPEN)
                        close_window(i);
}
/***********************************************************************/
/***********************************************************************/
/*
**                      misc functions
*/
/***********************************************************************/
/***********************************************************************/
/*----------------------*/
/*      draw            */
/*----------------------*/
VOID draw(xd,yd,xf,yf)
WORD xf,yf,xd,yd;
{
WORD tab[4];
        tab[0]=xd;
        tab[1]=yd;
        tab[2]=xf;
        tab[3]=yf;
        v_pline(handle,2,tab);
}
/*----------------------*/
/*      mouse           */
/*----------------------*/
LONG mouse(x,y,wait_fl)
LONG *x,*y;
BOOLEAN wait_fl;
{
WORD dummy;
WORD xx,yy;
WORD buttons;
        if (wait_fl < 4 && wait_fl > 0)
        {
                graf_mouse(M_ON,0);
                wind_update(BEG_MCTRL);
                evnt_button(1,wait_fl,wait_fl,&xx,&yy,&buttons,&dummy);
                wind_update(END_MCTRL);
                graf_mouse(M_OFF,0);
        }
        else
                graf_mkstate(&xx,&yy,&buttons,&dummy);
        *x=xx;
        *y=yy;
        return((LONG)buttons);
}
/*----------------------*/
/*      event           */
/*----------------------*/
LONG event(menu1,menu2,window,key,clickx,clicky)
LONG *menu1,*menu2,*key,*clickx,*clicky;
WORD window[6];
{
LONG evnt_type, ret, i, type;
WORD mx,my,key_code,junk;
WORD msgbuf[8];
        evnt_type = 0;
        if ((menu1 && menu2) || window)
                evnt_type |= MU_MESAG;
        if (key)
                evnt_type |= MU_KEYBD;
        if (clickx && clicky)
                evnt_type |= MU_BUTTON;
        if (!evnt_type)
                return(0);
        ret = 0;
        if (evnt_type & (MU_MESAG|MU_BUTTON))
                graf_mouse(M_ON, 0);
        do
        {
                type = evnt_multi(evnt_type,
                        1,1,1,
                        0,0,0,0,0,
                        0,0,0,0,0,
                        msgbuf,0,0,&mx,&my,&junk,
                        &junk,&key_code,&junk);
                switch(type)
                {
                case MU_KEYBD:
                        *key = key_code;
                        ret = 1;
                        break;
                case MU_BUTTON:
                        *clickx = mx;
                        *clicky = my;
                        ret = 2;
                        break;
                case MU_MESAG:
                        if (msgbuf[0] == MN_SELECTED)
                        {
                                if (menu1 && menu2)
                                {
                                        *menu1 = msgbuf[3];
                                        *menu2 = msgbuf[4];
                                        ret = 3;
                                }
                                else
                                        select_menu(menu1);
                        }
                        else
                                if (window)
                                {
                                        window[0] = msgbuf[0];
                                        for (i = 1; i < 6; i++)
                                                window[i] = msgbuf[i+2];
                                        ret = 4;
                                }
                        break;
                }
        }
        while(!ret);
        if (evnt_type & (MU_MESAG|MU_BUTTON))
                graf_mouse(M_OFF, 0);
        return(ret);
}
