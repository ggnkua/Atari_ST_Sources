/* AESDEMO.C
 *
 * GEM-Basteleien
 *
 * Oktober 1992 by Richard Kurz, Vogelherdbogen 62, 7992 Tettnang
 * Fido 2:241/7232.5
 * FÅr's TOS-Magazin
 */

#include <tos.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "new_aes.h"
#include "aesd.h"

/* Diese Event's brauchen wir.                                  */
#define E_KIND      MU_MESAG|MU_BUTTON|MU_KEYBD
#define E_TIME      1000

#define min(a,b)    ((a)<(b)?(a):(b)) /* Findet das Minimum.    */
#define max(a,b)    ((a)>(b)?(a):(b)) /* Findet das Maximum.    */

int Done=FALSE;     /* Flag fÅr's Ende                          */

HWINDOW *win[MAX_WINDOW];   /* Area fÅr die Window-Pointer      */

/* GEM-Basteleien */
int appl_id;
int gl_wchar,gl_hchar,gl_wbox,gl_hbox;
static int Msgbuff[8];

void main(void)
/* Der Anfang */
{
    appl_id=appl_init();
    if(appl_id<0)
    {
        Cconout('\a');
        puts(" AES-Anmeldung fehlgeschlagen");
        exit(1);
    }
    if(_GemParBlk.global[0]<0x400)
    {
        form_alert(1,"[1][ |AES-DEMO lÑuft erst|ab AES Version >= 4.0][ OK ]");
        appl_exit();
        exit(1);
    }
    else
    {
        graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
        graf_mouse(ARROW,0);
        init_dialog();
        gem_main();
        appl_exit();
    }
    exit(0);
} /* main */

/* Nun folgen die Routinen zur Verwaltung eines Dialoges im Fenster */

int get_win(int h)
/* Sucht den Pointer zum Handle */
{
    int i;
    
    for(i=0;i<MAX_WINDOW;i++)
    {
        if(win[i] && win[i]->handle==h && win[i]->wopen) return(i);
    }

    /* Notlîsung!!!!! Wenn die Fensterverwaltung aus dem Tritt kommt */
    return(0);
}/* get_win */

int open_window(HWINDOW *w)
/* ôffnet ein Fenster */
{
    int new,xdesk,ydesk,wdesk,hdesk,i;
       
    for(i=0;i<MAX_WINDOW;i++)
    {
        if(!win[i])
        {
            win[i]=w;
            win[i]->nr=i;
            break;
        }
        else if(!win[i]->wopen)
        {
            win[i]=w;
            win[i]->nr=i;
            break;
        }
    }
    if(i>=MAX_WINDOW)
    {
        form_alert(1,"[3][AES-Demo| |Kann kein Fenster|mehr îffnen][ OK ]");
        return(FALSE);
    }

    wind_get(0,WF_WORKXYWH,&xdesk,&ydesk,&wdesk,&hdesk);
    if((new=wind_create(w->kind,xdesk,ydesk,wdesk,hdesk))<0)
    {
        form_alert(1,"[3][AES-Demo| |Kann kein Fenster îffnen][ OK ]");
        return(FALSE);
    }

    wind_calc(WC_BORDER,w->kind,xdesk,ydesk+gl_hbox,w->obj->ob_width,w->obj->ob_height,
                &xdesk,&ydesk,&w->w,&w->h);
    if(w->y==0)
    {
        w->x=xdesk+(wdesk-w->w)/2;
        w->y=ydesk+(hdesk-w->h)/2;
    }
    graf_mouse(M_OFF,0);

    graf_growbox(0,0,0,0,w->x,w->y,w->w,w->h); 

    if(w->kind&NAME) wind_set(new,WF_NAME,w->title,0,0);

    w->wopen=TRUE;
    wind_open(new,w->x,w->y,w->w,w->h);

    wind_get(new,WF_WORKXYWH,&w->wx,&w->wy,&w->ww,&w->wh);
    w->obj->ob_x=w->wx;    
    w->obj->ob_y=w->wy;    
    w->handle=new;

    graf_mouse(M_ON,0);
    graf_mouse(ARROW,0);

    return(TRUE);
} /* open_window */

void close_window(int w_handle)
/* Schlieût ein Fenster */
{
    int x,y,w,h;
    
    win[get_win(w_handle)]->wopen=FALSE;

    if(wind_get(w_handle,WF_CURRXYWH,&x,&y,&w,&h))
    {
        graf_shrinkbox(0,0,0,0,x,y,w,h); 
        wind_close(w_handle);
    }
    wind_delete(w_handle);
} /* close_window */

static int rc_intersect(GRECT *r1,GRECT *r2)
/* Berechnet die öberscheidungen von Rechtecken */
{
    int x,y,w,h;

    x=max(r2->g_x,r1->g_x);
    y=max(r2->g_y,r1->g_y);
    w=min(r2->g_x+r2->g_w,r1->g_x+r1->g_w);
    h=min(r2->g_y+r2->g_h,r1->g_y+r1->g_h);

    r2->g_x=x;
    r2->g_y=y;
    r2->g_w=w-x;
    r2->g_h=h-y;

    return((int)((w>x)&&(h>y)));
} /* rc_intersect */

void draw_obj(OBJECT *obj,int o,int ti,int wi)
/* Zeichnet ein Objekt im Fenster, unter BerÅcksichtigung   */
/* der aktuellen Rechteckliste                              */
{
    GRECT t1, t2;
    
    objc_offset(obj,o,&t2.g_x,&t2.g_y);

    t2.g_w=obj[o].ob_width;
    t2.g_h=obj[o].ob_height;

    wi=win[wi]->handle;

    graf_mouse(M_OFF,0);
    wind_get(wi,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
    while(t1.g_w && t1.g_h)
    {
        if(rc_intersect(&t2,&t1)==TRUE)
            objc_draw(obj,o,ti,t1.g_x,t1.g_y,t1.g_w,t1.g_h);
        wind_get(wi,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
    }
    graf_mouse(M_ON,0);
} /* draw_obj   */

static void do_redraw(int w_handle,int x,int y,int w,int h)
/* Kommt der REDRAW-Aufforderung des AES nach */
{
    GRECT t1, t2;
    int wi;
    
    wi=get_win(w_handle);
    
    t2.g_x=x;t2.g_y=y;t2.g_w=w;t2.g_h=h;

    graf_mouse(M_OFF,0);
    wind_get(w_handle,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
    while(t1.g_w && t1.g_h)
    {
        if(rc_intersect(&t2,&t1)==TRUE)
            objc_draw(win[wi]->obj,0,8,t1.g_x,t1.g_y,t1.g_w,t1.g_h);
        wind_get(w_handle,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
    }
    graf_mouse(M_ON,0);
} /* do_redraw  */

static void new_size(int w_handle,int x,int y,int w,int h)
/* Das Fenster wurde bewegt, die Werte werden angepasst */
{
    int wi;
    
    wi=get_win(w_handle);
    wind_set(w_handle,WF_CURRXYWH,x,y,w,h);
    wind_get(w_handle,WF_CURRXYWH,&win[wi]->x,&win[wi]->y,&win[wi]->w,&win[wi]->h);
    wind_get(w_handle,WF_WORKXYWH,&win[wi]->wx,&win[wi]->wy,&win[wi]->ww,&win[wi]->wh);
    win[wi]->obj[0].ob_x=win[wi]->wx;
    win[wi]->obj[0].ob_y=win[wi]->wy;
} /* new_size */

static void hndl_window(void)
/* Verarbeitet die AES-Meldungen */
{
    int win_akt;

    switch(Msgbuff[0])
    {
        case AP_TERM:
            /* Diese Nachricht kommt z.B. vom AES bei einem     */
            /* Auflîsungswechsel                                */
            Done=TRUE;
            break;
            
        case MN_SELECTED:
            Done=!handle_menu(Msgbuff);
            break;
            
        case WM_REDRAW:
            do_redraw(Msgbuff[3],Msgbuff[4],Msgbuff[5],Msgbuff[6],Msgbuff[7]);
            break;

        case WM_CLOSED:
            Done=win[get_win(Msgbuff[3])]->end;
            close_window(Msgbuff[3]);
            break;

        case WM_MOVED:
            new_size(Msgbuff[3],Msgbuff[4],Msgbuff[5],Msgbuff[6],Msgbuff[7]);
            break;

        case WM_TOPPED:
        case WM_NEWTOP:
            win_akt=get_win(Msgbuff[3]);
            wind_set(win[win_akt]->handle,WF_TOP,0,0,0,0);
            wind_get(win[win_akt]->handle,WF_WORKXYWH,&win[win_akt]->wx
                    ,&win[win_akt]->wy,&win[win_akt]->ww,&win[win_akt]->wh);
            break;

        default:
            break;
    }
} /* handle_window */

void loop(void)
/* Die eigentliche Hauptschleife des Programmes */
{
    int nobj,which,win_akt,cont;
    int mx,my,mb,ks,kr,br,i;

    for(cont=TRUE,Done=FALSE;!Done && cont;)
    {
        which=evnt_multi(E_KIND,
                 2, 1, 1,
                 0, 0, 0, 0, 0,
                 0, 0, 0, 0, 0,
                 Msgbuff,
                 E_TIME, 0,  
                 &mx, &my,
                 &mb, &ks,
                 &kr, &br);

        wind_update(BEG_UPDATE); 

        if(which & MU_TIMER)  do_timer();
        else if(which & MU_MESAG) hndl_window();
        else
        {
            wind_get(0,WF_TOP,&win_akt);
            win_akt=get_win(win_akt);
            
            if(which & MU_KEYBD)
            {
                if(!form_keybd(win[win_akt]->obj,0,0,kr,&nobj,&i))
                {
                    if(win[win_akt]->do_button)
                        cont=win[win_akt]->do_button(nobj,win_akt);
                }
                else if(win[win_akt]->do_wtast)
                    cont=win[win_akt]->do_wtast(kr,win_akt);
            }
            else if(which & MU_BUTTON)
            {

                nobj=objc_find(win[win_akt]->obj,0,8,mx,my);
                if(nobj==-1)
                {
                    Cconout('\a');
                    nobj=0;
                }
                else
                {
                    if(!form_button(win[win_akt]->obj,nobj,br,&nobj))
                    {
                        if(win[win_akt]->do_button)
                            cont=win[win_akt]->do_button(nobj,win_akt);
                    }
                }
            }
        }
        wind_update(END_UPDATE); 
    }
    for(i=0;i<MAX_WINDOW;i++)
    {
        if(win[i] && win[i]->wopen) close_window(win[i]->handle);
    }
} /* loop */

