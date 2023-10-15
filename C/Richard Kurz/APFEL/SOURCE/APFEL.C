/* APFEL.C
 *
 * GEM-Basteleien zur FPU-Demonstration
 *
 * (c) April 1993 by Richard Kurz, Vogelherdbogen 62, 7992 Tettnang
 * Fido 2:241/7232.5
 * Maus UN
 * CompuServe 100025,2263
 *
 * Erstellt mit Pure C  
 * Vertrieb nur durch das TOS-Magazin!
 */

#include <vdi.h>
#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h> 
#include <string.h> 
#include <math.h> 
#include <time.h> 
#include "apfel.h"

#define TRUE 1
#define FALSE 0

#define min(a,b) ((a)<(b)?(a):(b))
#define max(a,b) ((a)>(b)?(a):(b))

/*  Die Åblichen GEM-Basteleien                     */
static int vdi_handle,vdi_col,apid;
static int max_x, max_y;
static int workin[12], workout[57], px[128], msgbuff[8];
static OBJECT *menu,*dialog,*info;
static int fertig=FALSE;
static struct {int handle,wx,wy,ww,wh,ox,oy,ow,oh,fulled;} win;

/*  Buffer-Verwaltung           */
static MFDB buffer;
static MFDB schirm={NULL};
static long bufsize;

/*  Fractal-Parameter           */
static double r_max=1.2,i_max=1.25;
static double r_min=-2, i_min=-1.25;
static int tiefe=50;
static long grenze=4;

/*  Prototypen                  */
void do_mandel(int ww,int wh,double r_max,double r_min,double i_max,double i_min, long grenze, int tiefe);
void _fpuinit(void); /* Aufruf um die FPU zu initialisieren (PC881LIB.LIB) */

static int buffer_init(void)
/*  Hier wird Speicher fÅr einen Puffer geholt  */
/*  und die MFDB's initialisiert, um den        */
/*  Bildschirminhalt sichern zu kînnen.         */
/*  Dies ist nîtig um die Redraw-Aufrufe in     */
/*  akzeptablem Speed ablaufen zu lassen.      */
/*  Ja, ich bin mir der Verschwendung von       */
/*  Speicher (cirka 6kB) bewuût, hatte aber     */
/*  keine Lust es zu Ñndern! Selber machen ist  */
/*  angesagt.                                   */
{
    int x,y,p;
    
    x=max_x+1;
    y=max_y+1;
    vq_extnd(vdi_handle,1,workout);
    p=workout[4];
    
    buffer.fd_wdwidth=(x+16)/16; 
    bufsize=((long)buffer.fd_wdwidth)*(2L)*((long)y)*((long)p);
    buffer.fd_addr=malloc(bufsize);
    if(buffer.fd_addr==NULL)
    {
        Cconout('\a');
        form_alert(1,"[3][ |Leider ist der Speicher|zu knapp][ Schade ]");
        return(FALSE);
    }
    buffer.fd_w=x;
    buffer.fd_h=y;
    buffer.fd_stand=1;
    buffer.fd_nplanes=p;
    return(TRUE);
} /* buffer_init */

static void handle_buffer(int f)
/*  Wird TRUE Åbergeben, sichert handle_buffer  */
/*  den Bildschirminhalt, bei FALSE geht's      */
/*  umgekehrt.                                  */
{
    graf_mouse(M_OFF,0);

    if(f)
    {
        px[0]=win.wx;
        px[1]=win.wy;
        px[2]=win.wx+win.ww-1;
        px[3]=win.wy+win.wh-1;
        px[4]=px[5]=0;
        px[6]=win.ww-1;
        px[7]=win.wh-1;
        memset(buffer.fd_addr,0,bufsize);
        vs_clip(vdi_handle,0,px);
        vro_cpyfm(vdi_handle,S_ONLY,px,&schirm,&buffer); 
    }
    else
    {
        px[0]=px[1]=0;
        px[2]=win.ww-1;
        px[3]=win.wh-1;
        px[4]=win.wx;
        px[5]=win.wy;
        px[6]=win.wx+win.ww-1;
        px[7]=win.wy+win.wh-1;
        vro_cpyfm(vdi_handle,S_ONLY,px,&buffer,&schirm); 
    }
    graf_mouse(M_ON,0);
} /* handle_buffer */

void set_info_zeile(int f)
{
    static char infozeile[128];
    
    if(f)   strcpy(infozeile,"Zum Abbrechen, Taste drÅcken");
    else    sprintf(infozeile,"%f,%f,%f,%f",r_max,i_max,r_min,i_min);
    wind_set(win.handle,WF_INFO,infozeile,0,0);
}/* set_info_zeile */

static int open_window(void)
/* ôffnet ein Fenster   */
{
    static char name[]=" FPU68882 Mandelbrot ";
    int x,y,w,h;
    
    wind_get(0,WF_WORKXYWH,&x,&y,&w,&h);
    if ((win.handle=wind_create(NAME|CLOSER|INFO|MOVER|SIZER|FULLER,x,y,w,h))<0)
    {
        form_alert(1,"[3][Kann kein Fenster îffnen.][ Abbruch ]");
        return(FALSE);
    }
    graf_mouse(M_OFF,0);
    wind_set(win.handle,WF_NAME,name,0,0);
    set_info_zeile(FALSE);
    graf_growbox(0,0,0,0,x,y,w,h);
    wind_open(win.handle,x+w/4,y+h/4,w/2,h/2);
    wind_get(win.handle,WF_WORKXYWH,&win.wx,&win.wy,&win.ww,&win.wh);
    wind_get(win.handle,WF_CURRXYWH,&win.ox,&win.oy,&win.ow,&win.oh);
    win.fulled=FALSE;
    graf_mouse(M_ON,0);
    return(TRUE);
} /* open_window */

static void close_window(void)
/* Macht das Gegenteil von open_window  */
{
    int x,y,w,h;

    wind_get(win.handle,WF_CURRXYWH,&x,&y,&w,&h);
    graf_shrinkbox(0,0,0,0,x,y,w,h);
    wind_close(win.handle);
    wind_delete(win.handle);
} /* close_window */

static int rc_intersect(GRECT *r1,GRECT *r2)
/* Stellt fest, ob sich zwei Rechtecke schneiden    */
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
   return((w>x)&&(h>y));
} /* rc_intersect */

static void clipping(int x,int y,int w,int h,int m)
/* Vereinfachung des vs_clip-Aufrufs    */
{
   px[0]=x; px[1]=y;
   px[2]=x+w-1; px[3]=y+h-1;
   vs_clip(vdi_handle,m,px);
} /* clipping */

static void new_size(int x,int y,int w,int h)
{
    wind_set(win.handle,WF_CURRXYWH,x,y,w,h);
    wind_get(win.handle,WF_WORKXYWH,&win.wx,&win.wy,&win.ww,&win.wh);
    win.fulled=FALSE;
} /* new_size */

static void redraw_window(int x,int y,int w,int h)
/*  Die REDRAW-Meldungen vom AES werden abgearbeitet    */
{
   GRECT r1,r2;

   r2.g_x=px[0]=x; 
   r2.g_y=px[1]=y;
   r2.g_w=w;
   r2.g_h=h;
   px[2]=x+w-1;
   px[3]=y+h-1;

   graf_mouse(M_OFF,0);
   wind_get(win.handle,WF_FIRSTXYWH,&r1.g_x,&r1.g_y,&r1.g_w,&r1.g_h);
   while (r1.g_w && r1.g_h)
   {
      if (rc_intersect(&r2,&r1)==TRUE)
      { 
         clipping(r1.g_x,r1.g_y,r1.g_w,r1.g_h,TRUE);
         handle_buffer(FALSE);
         clipping(r1.g_x,r1.g_y,r1.g_w,r1.g_h,FALSE);
      }
      wind_get(win.handle,WF_NEXTXYWH,&r1.g_x,&r1.g_y,&r1.g_w,&r1.g_h);
   }
   graf_mouse(M_ON,0);
} /* redraw_window */

static void w_cls(void)
/* Der Fensterinhalt wird gelîscht */
/* ACHTUNG! Kein Clipping!         */
{
    vsf_color(vdi_handle,0);
    px[0]=win.wx; px[1]=win.wy; 
    px[2]=win.ww+win.wx-1; px[3]=win.wh+win.wy-1;

    graf_mouse(M_OFF,0);
    v_bar(vdi_handle,px);
    graf_mouse(M_ON,0);  
} /* w_cls */

static int handle_dialog(OBJECT *o)
/* Vereinfachung der Dialogbearbeitung  */
{
    int x,y,w,h,e;
    
    form_center(o,&x,&y,&w,&h); 
    form_dial(FMD_START,0,0,0,0,x,y,w,h);
    form_dial(FMD_GROW,0,0,0,0,x,y,w,h);
    objc_draw(o,0,2,x,y,w,h);
    e=form_do(o,0) & 0x7fff;
    o[e].ob_state &= ~SELECTED;
    form_dial(FMD_SHRINK,0,0,0,0,x,y,w,h);
    form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
    return(e);
} /* handle_dialog */

static void show_time(long z)
{
    char alert[80];
    double d;
    
    d=(double)z/(double)CLK_TCK;
    sprintf(alert,"[1][ |Die letzte Berechnung dauerte|%.2f Sekunden.][ Okay ]",d);
    form_alert(1,alert);
}/* show_time */

static void schleife(void)
/*  Hier nun die Hauptschleife, das ganze dreht */
/*  sich um einen event_mesag Aufruf            */
{
    static long rechenzeit=0;
    int rx,ry;
    int mx,my,mb,mk,ax,ay;
    double xd,yd;
    
    do
    {
        evnt_mesag(msgbuff);
        wind_update(BEG_UPDATE); 
        switch(msgbuff[0])
        {
            case MN_SELECTED:
                switch(msgbuff[4])
                {
                    case MPARA:
                        wind_update(BEG_MCTRL);
                        graf_mouse(POINT_HAND,NULL);
                        for(mb=0;;)
                        {
                            graf_mkstate(&mx,&my,&mb,&mk);
                            if(mx<win.wx || my<win.wy || mx>win.wx+win.ww || my>win.wy+win.wh)
                            {
                                mb=0;
                                continue;
                            }
                            if(mb) break;
                        }
                        graf_rubbox(mx,my,8,8,&ax,&ay);
                        graf_mouse(ARROW,NULL);
                        wind_update(END_MCTRL);
                        xd=fabs(r_max+(-r_min))/win.ww;
                        yd=fabs(i_max+(-i_min))/win.wh;
                        r_max=r_max-(xd*(mx-win.wx));
                        i_max=i_max-(yd*(my-win.wy));
                        r_min=r_max-(xd*ax);
                        i_min=i_max-(yd*ay);
                        set_info_zeile(FALSE);
                        break;      

                    case MEPARA:
                        sprintf(dialog[RTIEFE].ob_spec.tedinfo->te_ptext,
                                "%20i",tiefe);
                        sprintf(dialog[RGRENZE].ob_spec.tedinfo->te_ptext,
                                "%20li",grenze);
                        sprintf(dialog[REALMAX].ob_spec.tedinfo->te_ptext,
                                "%20.14f",r_max);
                        sprintf(dialog[IMAGMAX].ob_spec.tedinfo->te_ptext,
                                "%20.14f",i_max);
                        sprintf(dialog[REALMIN].ob_spec.tedinfo->te_ptext,
                                "%20.14f",r_min);
                        sprintf(dialog[IMAGMIN].ob_spec.tedinfo->te_ptext,
                                "%20.14f",i_min);
                        if(handle_dialog(dialog)==EOK)
                        {
                            tiefe=atoi(dialog[RTIEFE].ob_spec.tedinfo->te_ptext);
                            if(tiefe<=0) tiefe=50;
                            grenze=atol(dialog[RGRENZE].ob_spec.tedinfo->te_ptext);
                            if(grenze<=0) grenze=4;
                            r_max=atof(dialog[REALMAX].ob_spec.tedinfo->te_ptext);
                            i_max=atof(dialog[IMAGMAX].ob_spec.tedinfo->te_ptext);
                            r_min=atof(dialog[REALMIN].ob_spec.tedinfo->te_ptext);
                            i_min=atof(dialog[IMAGMIN].ob_spec.tedinfo->te_ptext);
                        }
                        set_info_zeile(FALSE);
                        break;
                    
                    case MZEIT:
                        show_time(rechenzeit);
                        break;
                            
                    case MINFO:
                        handle_dialog(info);
                        break;

                    case MENDE:
                        close_window();
                        fertig=TRUE;
                        break;

                    case MSTART:
                        set_info_zeile(TRUE);
                        wind_set(win.handle,WF_TOP,0,0,0,0);
                        wind_get(win.handle,WF_WORKXYWH,&win.wx,&win.wy,&win.ww,&win.wh);
                        while(Cconis())Cconin();
                        w_cls();                        
                        graf_mouse(M_OFF,0); 
                        rechenzeit=clock(); 
                        do_mandel(win.ww,win.wh,r_max,r_min,i_max,i_min,grenze,tiefe);
                        rechenzeit=clock()-rechenzeit;
                        handle_buffer(TRUE);
                        graf_mouse(M_ON,0);  
                        set_info_zeile(FALSE);
                        Cconout('\a');

                    default:
                        break;
                }
                menu_tnormal(menu,msgbuff[3],1);
                break;

            case WM_REDRAW:
                redraw_window(msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
                break;

            case WM_CLOSED:               
                close_window();
                fertig=TRUE;
                break;

            case WM_MOVED: 
                /* Das Fenster darf den Bildschirm nicht verlassen! */
                rx=msgbuff[4]+msgbuff[6];
                ry=msgbuff[5]+msgbuff[7];
                if(rx>max_x)msgbuff[4]-=rx-max_x;
                if(ry>max_y)msgbuff[5]-=ry-max_y;
            case WM_SIZED:                
                new_size(msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
            break;

            case WM_FULLED:               
            if(win.fulled)
            {
                wind_set(msgbuff[3],WF_CURRXYWH,win.ox,win.oy,win.ow,win.oh);
                wind_get(msgbuff[3],WF_WORKXYWH,&win.wx,&win.wy,&win.ww,&win.wh);
                win.fulled=FALSE;
            }
            else
            {
                wind_get(msgbuff[3],WF_FULLXYWH,&msgbuff[4],&msgbuff[5],&msgbuff[6],&msgbuff[7]);
                wind_set(msgbuff[3],WF_CURRXYWH,msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
                wind_get(msgbuff[3],WF_WORKXYWH,&win.wx,&win.wy,&win.ww,&win.wh);
                win.fulled=TRUE;
            }

            case WM_TOPPED:
            case WM_NEWTOP:
                wind_set(msgbuff[3],WF_TOP,0,0,0,0);
                wind_get(msgbuff[3],WF_WORKXYWH,&win.wx,&win.wy,&win.ww,&win.wh);
                break;
            default:
                break;
        }
        wind_update(END_UPDATE);
    } while (!fertig);
} /* schleife */

int get_cookie(unsigned long cookie,unsigned long *value)
{
    long old_stack;
    long *jar;
    
    old_stack=Super(0L);
    jar=*((long **)0x5a0L);
    Super((void *) old_stack);
    
    if(!jar) return(FALSE);
    do
    {
        if(*jar==cookie)
        {
            if(value) *value=jar[1];
            return(TRUE);
        }
        else
            jar= &(jar[2]);
    }while(jar[0]);
    return(FALSE);
} /* get_cookie */

void main(void)
/* Der Nabel des C-Programmes   */
{
    int i;
    unsigned long ck;

    apid=appl_init();
    if(apid<0)
    {
        Cconout('\a');
        fprintf(stderr,"Fehler bei der Programminitialisierung!");
        exit(1);
    }
    ck=0;
    get_cookie('_FPU',&ck);
    if(!(ck&0x60000L))
    {
        form_alert(1,"[0][APFEL lÑuft nur mit  |    68881/68882|        und| 68020/68030/68040][ Abbruch ]");
        appl_exit();
        exit(1);
    }
    _fpuinit(); /* Nun darf die FPU initiallisiert werden! */
    vdi_handle=graf_handle(&i,&i,&i,&i);
    for (i=1;i<10;workin[i++]=1);
    workin[10]=2;
    workin[0]=vdi_handle;
    v_opnvwk(workin,&vdi_handle,workout);
    if(vdi_handle<=0)
    {
        Cconout('\a');
        form_alert(1,"[3][ |VDI-Workstation konnte|nicht geîffnet werden!][ Abbruch ]");
        appl_exit();
        exit(1);
    }
    max_x=workout[0];
    max_y=workout[1];
    vdi_col=workout[13];
    if(vdi_col<0 || vdi_col>256) vdi_col=256;
    else if(vdi_col==0) vdi_col=2;
    
    if(!rsrc_load("APFEL.RSC"))
    {
        Cconout('\a');
        form_alert(1,"[3][ |APFEL.RSC nicht gefunden.][ Abbruch ]");
        v_clsvwk(vdi_handle);
        appl_exit();
        exit(1);
    }
    rsrc_gaddr(0,MENU,&menu);
    rsrc_gaddr(0,DIALOG,&dialog);
    rsrc_gaddr(0,EINFO,&info);
    menu_bar(menu,1); 
    graf_mouse(ARROW,0);
    if(open_window())
    {
        w_cls();
        if(buffer_init())
        {
            handle_buffer(TRUE);
            schleife();
            free(buffer.fd_addr);
        }
    }
    menu_bar(menu,0);   
    rsrc_free();      
    v_clsvwk(vdi_handle);
    appl_exit();
    exit(0);
} /* main */

void draw_zeile(int *z,int mx, int y)
/* Zeichnet eine errechnete Mandelbrot-Zeile */
/* ACHTUNG! Kein Clipping!                   */
{
    int x,f,i,px[4];

    px[1]=px[3]=y+win.wy;
    
    for(x=0;x<=mx;x++)
    {
        f=z[mx-x];
        px[0]=x+win.wx;
        for(i=x+1;i<=mx;i++)
        {
            if(z[mx-i]!=f) break;
            else x++;
        }
        px[2]=x+win.wx;
        if(f<0) vsl_color(vdi_handle,1);
        else vsl_color(vdi_handle,f%vdi_col);
        v_pline(vdi_handle,2,px);
    }
}/* draw_zeile */
