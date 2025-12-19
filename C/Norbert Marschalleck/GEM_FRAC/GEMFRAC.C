/********************************************************************/
/*                                                                  */
/*                 (c) by   Norbert Marschalleck                    */
/*                                                                  */
/*             Wer diesen Namen hier entfernt, wird mit             */
/*             einer Strafe von  nicht unter 24 Stunden             */
/*             Dauerberieselung von Modern Schwuchtling             */
/*             bestraft (u„„„hhhhh, miiiiiies, bel)             */
/*                                                                  */
/********************************************************************/
/*                                                                  */
/*              This one, who deletes my name here, must            */
/*              is a shit-fan from Modern anxiety !!!!!!            */  
/*                                                                  */
/********************************************************************/

#define ARROW         0
#define FALSE         0
#define MIN_WIDTH     80
#define MIN_HEIGHT    50
#define MU_KEYBD      0x0001
#define MU_BUTTON     0x0002
#define MU_MESAG      0x0010
#define TRUE          1
#define WC_BORDER     0
#define WC_WORK       1
#define WF_WORKXYWH   4
#define WF_CURRXYWH   5
#define WF_FIRSTXYWH  11
#define WF_NEXTXYWH   12
#define WF_NAME       2
#define WF_TOP        10
#define WI_KIND       (MOVER|NAME|CLOSER|FULLER)
#define WM_REDRAW     20
#define WM_TOPPED     21
#define WM_CLOSED     22
#define WM_FULLED     23
#define WM_SIZED      27
#define WM_MOVED      28
#define WM_NEWTOP     29
#define MN_SELECTED   10

#define NAME    0x0001
#define CLOSER  0x0002
#define FULLER  0x0004
#define MOVER   0x0008
#define INFO    0x0010
#define SIZER   0x0020
#define UPARROW 0x0040
#define DNARROW 0x0080
#define VSLIDE  0x0100
#define LFARROW 0x0200
#define RTARROW 0x0400
#define HSLIDE  0x0800

#include "gemfrac.h"

#define hardcopy()                      
#define create(name,mode)               gemdos(0x3c,name,mode)
#define open(name,att)                  gemdos(0x3d,name,att)
#define close(hndl)                     gemdos(0x3e,hndl)
#define read(hndl,size,buff)  (long)    gemdos(0x3f,hndl,size,buff)
#define write(hndl,size,buff) (long)    gemdos(0x40,hndl,size,buff)
#define setscr(log,phy,res)   (long)    xbios(0x5,log,phy,res)
#define getdrv()              (int)     gemdos(0x19)
#define getpath(a,b)                    gemdos(0x47,a,b)
#define wait()                          gemdos(0x1)
#define exit()                          gemdos(0x0)

extern long xbios();
extern long gemdos();
extern int gl_apid;

typedef struct grect    /* Struct fr Rechteckliste */
{                       /* Struct for the Quader-list */
  int     g_x;
  int     g_y;
  int     g_w;
  int     g_h;
} GRECT;

typedef struct fdbstr                /* Struct fr Rasterfunktionen */
{                                    /* Struct for rasterfunktions  */
        long            fd_addr;
        int             fd_w;
        int             fd_h;
        int             fd_wd;
        int             fd_flag;
        int             fd_planes;
        int             fd_res1;
        int             fd_res2;
        int             fd_res3;
} MFDB;

struct windows                       /* Struct fr Fensterwerte */
{                                    /* Struct for Window-vars  */
  int          wi_handle;
  int          windx;
  int          windy;
  int          windw;
  int          windh;
  double       xmax;
  double       xmin;
  double       ymax;
  double       ymin;
} win[4];

char name[64] = "";
char extension[] = "*.PIC";

int   contrl[12], intin[128],  ptsin[128], intout[128],
      ptsout[128],work_in[12],work_out[57], msgbuff[8],
      dummy, handle,phys_handle,mausx,mausy,maxiter,nr,
      charw,charh,charw_box,charh_box,lasth,lastw, anz,
      fflag;

long *screen1, *screen2, *screen3, menue_addr;

main()
{
 char    *malloc(), *hilf;
 int i, fileret;

 nr = anz = 0;
 maxiter = 50;
 fflag = 1;
 win[0].windx = win[2].windx = 32;
 win[1].windx = win[3].windx = 352;
 win[0].windy = win[1].windy = 38;
 win[2].windy = win[3].windy = 229;
 win[0].windw = win[1].windw = win[2].windw = win[3].windw = 256;
 win[0].windh = win[1].windh = win[2].windh = win[3].windh = 160;
 screen1 = (long *) xbios(0x3);
 if((hilf = malloc(32511)) == (char *) 0)
  {
  form_alert(1,"[1][kann keinen Speicher|fr die zweite|Bildschirmseite|allocieren !][ OK ]");
  wait();
  exit();
  }
 screen2 = (long *) ((long) hilf + (512L - (long) hilf % 512));
 if((hilf = malloc(32511)) == (char *) 0)
  {
  form_alert(1,"[1][kann keinen Speicher|fr die dritte|Bildschirmseite|allocieren !][ OK ]");
  wait();
  exit();
  }
 screen3 = (long *) ((long) hilf + (512L - (long) hilf % 512));
 open_scr();
 set_attr();
 graf_mouse(ARROW,&dummy);
 hide_mouse();
 fileret=open("TITEL",0);
 if (fileret > 0)
  read(fileret,32000L,screen2);
 close(fileret);
 setscr(screen2,screen2,-1);
 for(i=0;i<=398;i++)
  scroll_down(screen2);
 setscr(screen1,screen1,-1);
 if (!rsrc_load("GEMFRAC.RSC"))
  {
  form_alert(1,"[3][ Das .RSC-File ist nicht vorhanden ][Abbruch]");
  gemdos(0x0);
  }
 rsrc_gaddr(0,MENUE,&menue_addr);
 menu_bar(menue_addr,1);
 open_window(win[nr].windx,win[nr].windy,win[nr].windw,win[nr].windh);
 menu_icheck(menue_addr,LOW,0);
 menu_icheck(menue_addr,HIGH,0);
 menu_icheck(menue_addr,BW,0);
 win[nr].xmin = -0.7;
 win[nr].xmax =  2.1;
 win[nr].ymin = -1.0;
 win[nr].ymax =  1.0;
 show_mouse();
 multi();
}

open_scr()
{
 int i;
 appl_init();
 for (i=0;i<10;work_in[i++]=1);
 work_in[10] = 2;
 phys_handle=graf_handle(&charw,&charh,&charw_box,&charh_box);
 handle=phys_handle;
 v_opnvwk(work_in,&handle,work_out);
}

close_scr()
{
 v_clsvwk(handle);
 appl_exit();
}

clear_scr(screen)
register long *screen;
{
  asm
 {
          move.l    screen, A0
          move.w    #7999, D0
 loop:    andi.l    #0, (A0)+
          dbf       D0, loop
 }
}

set_attr()
{
 vswr_mode(handle,1);
 vsm_type(handle,1);
 vsm_height(handle,1);
 vsf_color(handle,0);
 vsf_perimeter(handle,0);
}

set_clip(x,y,w,h)
unsigned int x,y,w,h;
{
 int clip[4];
 clip[0]=x;
 clip[1]=y;
 clip[2]=x+w;
 clip[3]=y+h;
 vs_clip(handle,1,clip);
}

hide_clip(x,y,w,h)
unsigned int x,y,w,h;
{
 int clip[4];
 clip[0]=x;
 clip[1]=y;
 clip[2]=x+w;
 clip[3]=y+h;
 vs_clip(handle,0,clip);
}

plotl(x,y,screen)
register unsigned int x,y;
register long screen;
{
  register int *addr;
  addr = (int *) screen + y*40 +(x >> 4);
  *addr |= (1 << (15 - (x & 15)));
}

scroll_down(screen)
register long *screen;
{
 asm
   {
          move.l         screen, A1
          adda.w         #31920, A1
          move.l         A1, A0
          adda.w         #80, A0
          move.w         #7959, D0
    loop: move.l         -(A1), -(A0)
          dbf            D0, loop
          move.w         #39,D0
    schl: clr.l          -(A0)
          dbf            D0, schl
   }
}

show_mouse()
{
 graf_mouse(257,&dummy);
}

hide_mouse()
{
 graf_mouse(256,&dummy);
}

open_window(setwx,setwy,setww,setwh)
int setwx,setwy,setww,setwh;
{
 wind_calc(WC_BORDER,WI_KIND,setwx,setwy,setww,setwh,
                             &setwx,&setwy,&setww,&setwh);
 win[nr].wi_handle=wind_create(WI_KIND,setwx,setwy,setww,setwh);
 switch(nr)
  {
  case 0: wind_set(win[nr].wi_handle,WF_NAME,"Fractal 0",0,0);
          break;
  case 1: wind_set(win[nr].wi_handle,WF_NAME,"Fractal 1",0,0);
          break;
  case 2: wind_set(win[nr].wi_handle,WF_NAME,"Fractal 2",0,0);
          break;
  case 3: wind_set(win[nr].wi_handle,WF_NAME,"Fractal 3",0,0);
          break;
  }
 graf_growbox(setwx+setww/2,setwy+setwh/2,charw_box,charh_box,
              setwx,setwy,setww,setwh);
 wind_open(win[nr].wi_handle,setwx,setwy,setww,setwh);
 wind_get(win[nr].wi_handle,WF_WORKXYWH,&win[nr].windx,
          &win[nr].windy,&win[nr].windw,&win[nr].windh);
 clear_wind();
}

close_wind()
{
 wind_close(win[nr].wi_handle);
 graf_shrinkbox(win[nr].windx+win[nr].windw/2,
                win[nr].windy+win[nr].windh/2,charw_box,
                charh_box,win[nr].windx,win[nr].windy,
                win[nr].windw,win[nr].windh);
 wind_delete(win[nr].wi_handle);
 anz--;
 nr = anz;
 wind_set(win[nr].wi_handle,WF_TOP,0,0,0,0);
}

clear_wind()
{
 int pxyarray[4];

 pxyarray[0]=win[nr].windx;
 pxyarray[1]=win[nr].windy;
 pxyarray[2]=win[nr].windx+win[nr].windw;
 pxyarray[3]=win[nr].windy+win[nr].windh;
 vsf_interior(handle,1);
 hide_mouse();
 v_bar(handle,pxyarray);
 show_mouse();
}

checkmark()
{
 if(msgbuff[4]==LOW || msgbuff[4]==MEDIUM || msgbuff[4]==HIGH)
  { 
  menu_icheck(menue_addr,LOW,0);
  menu_icheck(menue_addr,MEDIUM,0);
  menu_icheck(menue_addr,HIGH,0);
  menu_icheck(menue_addr,msgbuff[4],1);
  }
 if(msgbuff[4]==GREY || msgbuff[4]==BW)
  { 
  menu_icheck(menue_addr,GREY,0);
  menu_icheck(menue_addr,BW,0);
  menu_icheck(menue_addr,msgbuff[4],1);
  }
}

desktop()
{
 int anzahl;

 for (anzahl=anz;anzahl>=0;anzahl--)
  {
  wind_get(win[nr].wi_handle,WF_TOP,&win[nr].wi_handle,
           &dummy,&dummy,&dummy);
  wind_get(win[nr].wi_handle,WF_WORKXYWH,&win[nr].windx,
           &win[nr].windy,&win[nr].windw,&win[nr].windh);
  close_wind();    
  }
 anz = -1;
}

get_path(tmp_path, spec)
char *tmp_path, *spec;
{
 int cur_drv;

 cur_drv = getdrv();
 tmp_path[0] = cur_drv +'A';
 tmp_path[1] = ':';
 tmp_path[2] = '\\';
 dos_gdir(cur_drv+1, &tmp_path[3]);
 if (strlen(tmp_path) > 3)
  strcat(tmp_path, "\\");
 else
  tmp_path[2] = '\0';
 strcat(tmp_path, spec);
}

dos_gdir(drive, pdrvpath)
int drive;
char *pdrvpath;
{
 char ret;

 ret = getpath(pdrvpath,drive);
 if (pdrvpath[0] == '\\')
  strcpy(pdrvpath, &pdrvpath[1]);
 return(ret);
}

get_file()
{
 int fs_iexbutton;
 char fs_iinsel[13];

 get_path(name, extension);
 fs_iinsel[0] = '\0';
 fsel_input(name, fs_iinsel, &fs_iexbutton);
 if (fs_iexbutton)
  add_name(name, fs_iinsel);
}

add_name(dname, fname)
char *dname, *fname;
{
 char c;
 int ii;

 ii = strlen(dname);
 while(ii && (((c = dname[ii-1]) != '\\') && (c != ':')))
  ii--;
 dname[ii] = '\0';
 strcat(dname, fname);
}

change(remax,immax,remin,immin,xpos,ypos)
double remax,immax,remin,immin;
int xpos,ypos;
{
 if(lastw>(win[nr].windx+win[nr].windw)-mausx)
  lastw=(win[nr].windx+win[nr].windw)-mausx;
 if(lasth>(win[nr].windy+win[nr].windh)-mausy)
  lasth=(win[nr].windy+win[nr].windh)-mausy;
 if((lasth<lastw) && (lasth != lastw/1.6))
  lastw=lasth*1.6;
 else
  lasth=lastw/1.6;
 anz++;
 nr = anz;
 open_window(win[nr].windx,win[nr].windy,win[nr].windw,win[nr].windh);
 win[nr].xmax = remax -(((remax-remin)/256)*(256-(lastw+(mausx-xpos))));
 win[nr].ymax = immax -(((immax-immin)/160)*(160-(lasth+(mausy-ypos))));
 win[nr].xmin = remin +(((remax-remin)/256)*(mausx-xpos));
 win[nr].ymin = immin +(((immax-immin)/160)*(mausy-ypos));
 clear_wind();
 if (fflag ==1)
  grey_frac(win[nr].xmax,win[nr].xmin,win[nr].ymax,
            win[nr].ymin,maxiter,win[nr].windw/2,win[nr].windh/2,2);
 else
  bw_frac(win[nr].xmax,win[nr].xmin,win[nr].ymax,win[nr].ymin,
          maxiter,win[nr].windw,win[nr].windh,2);
}

grey_frac(rmax,rmin,imax,imin,maxit,xscope,yscope,modus)
double rmax,rmin,imax,imin;
int maxit,xscope,yscope,modus;
{ 
 double dx,dy,cx,cy;
 int spalte,zeile;
 register double xwert,ywert,xquad,yquad;
 register int iter;

 hide_mouse();
 dx = (rmax-rmin)/xscope;
 dy = (imax-imin)/yscope;
 cx = rmin;
 cy = imin;
 for(zeile = 0; zeile <= (yscope<<1); zeile += 2)
  {
  for(spalte = 0; spalte < (xscope<<1) + 2; spalte += 2)
   {
   iter = 0;
   xwert = ywert = xquad = yquad = 0.0;
   while (++iter < maxit && xquad + yquad < 8.0)
    {
    ywert = 2.0 * xwert * ywert - cy;
    xwert = xquad - yquad - cx;
    xquad = xwert * xwert;
    yquad = ywert * ywert;
    }
   if (iter != maxit)
    {
    switch(modus)
     {
     case 1:
            setpoint(spalte,zeile,iter % 4 + 1,screen2);
            break;
     case 2:
            setpoint(spalte+win[nr].windx,zeile+win[nr].windy,
                     iter % 4 +1,screen1);
            break;
     }
    }
    cx += dx;
   }
   cx = rmin;
   cy += dy;
   if (gemdos(0x6,0xFF) != 0)
    break;
  }
 copy_wind(screen1,screen3);
 show_mouse();
}

setpoint(x,y,farbe,screen)
register int x,y,farbe;
long screen;
{
 switch(farbe)
  {
  case 1:
        plotl(x,y,screen);
        break;
  case 2:
        plotl(x,y,screen);
        plotl(x+1,y+1,screen);
        break;
  case 3:
        plotl(x+1,y,screen);
        plotl(x,++y,screen);
        plotl(x+1,y,screen);
        break;
  case 4:
        plotl(x,y,screen);
        plotl(x+1,y,screen);
        plotl(x,++y,screen);
        plotl(x+1,y,screen);
        break;
  }
}

bw_frac(rmax,rmin,imax,imin,maxit,xscope,yscope,modus)
double rmax,rmin,imax,imin;
int maxit,xscope,yscope,modus;
{ 
 double dx,dy,cx,cy;
 int spalte,zeile;
 register double xwert,ywert,xquad,yquad;
 register int iter;

 hide_mouse();
 dx = (rmax-rmin)/xscope;
 dy = (imax-imin)/yscope;
 cx = rmin;
 cy = imin;
 for(zeile = 0; zeile <= yscope; zeile ++)
  {
  for(spalte = 0; spalte <= xscope; spalte ++)
   {
   iter = 0;
   xwert = ywert = xquad = yquad = 0.0;
   while (++iter < maxit && xquad + yquad < 8.0)
    {
    ywert = 2.0 * xwert * ywert - cy;
    xwert = xquad - yquad - cx;
    xquad = xwert * xwert;
    yquad = ywert * ywert;
    }
   if (iter != maxit && (iter %4 != 0))
    {
    switch(modus)
     {
     case 1:
            plotl(spalte,zeile,screen2);
            break;
     case 2:
            plotl(spalte+win[nr].windx,zeile+win[nr].windy,screen1);
            break;
     }
    }
   cx += dx;
   }
  cx = rmin;
  cy += dy;
  if (gemdos(0x6,0xFF) != 0)
   break;
  }
 copy_wind(screen1,screen3);
 show_mouse();
}

redraw(han,xc,yc,wc,hc,source,destination)
int han,xc,yc,wc,hc;
long source,destination;
{
 GRECT t1,t2;
 MFDB psrc, pdest;
 int pxyarray[8],x,y,w,h;
 int mode = 3;

 hide_mouse();
 wind_update(TRUE);
 t2.g_x=xc;
 t2.g_y=yc;
 t2.g_w=wc;
 t2.g_h=hc;
 wind_get(han,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
 while (t1.g_w && t1.g_h)
  {
  if(rc_intersect(&t2,&t1))
   {
   wind_get(han,WF_WORKXYWH,&x,&y,&w,&h);
   set_clip(t1.g_x,t1.g_y,t1.g_w,t1.g_h);
   pxyarray[4]=t1.g_x;
   pxyarray[5]=t1.g_y;
   pxyarray[6]=t1.g_x + t1.g_w - 1;
   pxyarray[7]=t1.g_y + t1.g_h - 1;
   if (han == win[0].wi_handle)
    {
    pxyarray[0] = pxyarray[4] - (x-32);
    pxyarray[1] = pxyarray[5] - (y-38);
    pxyarray[2] = pxyarray[6] - (x-32);
    pxyarray[3] = pxyarray[7] - (y-38);
    }
   else
    {
    if (han == win[1].wi_handle)
     {
     pxyarray[0] = pxyarray[4] - (x-352);
     pxyarray[1] = pxyarray[5] - (y-38);
     pxyarray[2] = pxyarray[6] - (x-352);
     pxyarray[3] = pxyarray[7] - (y-38);
     }
    else
     {
     if (han == win[2].wi_handle)
      {
      pxyarray[0] = pxyarray[4] - (x-32);
      pxyarray[1] = pxyarray[5] - (y-229);
      pxyarray[2] = pxyarray[6] - (x-32);
      pxyarray[3] = pxyarray[7] - (y-229);
      }
     else
      {
      if (han == win[3].wi_handle)
       {
       pxyarray[0] = pxyarray[4] - (x-352);
       pxyarray[1] = pxyarray[5] - (y-229);
       pxyarray[2] = pxyarray[6] - (x-352);
       pxyarray[3] = pxyarray[7] - (y-229);
       }
      else
       form_alert(2,"[1][ Schweine im| Weltall][OK]");
      }
     }
    }
   psrc.fd_addr  = source; 
   pdest.fd_addr = destination;
   psrc.fd_w = pdest.fd_w = 640;
   psrc.fd_h = pdest.fd_h = 400;
   psrc.fd_wd = pdest.fd_wd = 40;
   psrc.fd_flag = pdest.fd_flag = 0;
   psrc.fd_planes = pdest.fd_planes =1;
   vro_cpyfm(handle,mode,pxyarray,&psrc,&pdest);
   hide_clip(t1.g_x,t1.g_y,t1.g_w,t1.g_h);
  }
  wind_get(han,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
 }
 wind_update(FALSE);
 show_mouse();
}

copy_wind(source,destination)
long source, destination;
{
 MFDB psrc, pdest;
 int pxyarray[8];
 int mode = 3;

 hide_mouse();
 pxyarray[0]=win[nr].windx;
 pxyarray[1]=win[nr].windy;
 pxyarray[2]=win[nr].windx + win[nr].windw;
 pxyarray[3]=win[nr].windy + win[nr].windh;
 switch(nr)
  {
   case 0:
          pxyarray[4]=32;
          pxyarray[5]=38;
          pxyarray[6]=32+256;
          pxyarray[7]=38+160;
          break;
   case 1:
          pxyarray[4]=352;
          pxyarray[5]=38;
          pxyarray[6]=352+256;
          pxyarray[7]=38+160;
          break;
   case 2:
          pxyarray[4]=32;
          pxyarray[5]=229;
          pxyarray[6]=32+256;
          pxyarray[7]=229+160;
          break;
   case 3:
          pxyarray[4]=352;
          pxyarray[5]=229;
          pxyarray[6]=352+256;
          pxyarray[7]=229+160;
          break;
  default:
          form_alert(2,"[1][ Schweine im| Weltall][OK]");
          break;
  }   
 psrc.fd_addr  = source; 
 pdest.fd_addr = destination;
 psrc.fd_w = pdest.fd_w = 640;
 psrc.fd_h = pdest.fd_h = 400;
 psrc.fd_wd = pdest.fd_wd = 40;
 psrc.fd_flag = pdest.fd_flag = 0;
 psrc.fd_planes = pdest.fd_planes =1;
 vro_cpyfm(handle,mode,pxyarray,&psrc,&pdest);
 show_mouse();
}

multi()
{
 int event,albutton,filereturn,xobj,yobj,wobj,hobj;
 int butdown = TRUE;
 do
  {
  event=evnt_multi(MU_MESAG|MU_BUTTON|MU_KEYBD,1,1,butdown,
                   0,0,0,0,0,0,0,0,0,0,msgbuff,0,0,&mausx,&mausy,
                   &dummy,&dummy,&dummy,&dummy);
  wind_update(TRUE);
  wind_get(win[nr].wi_handle,WF_TOP,&win[nr].wi_handle,&dummy,
           &dummy,&dummy);
  wind_get(win[nr].wi_handle,WF_WORKXYWH,&win[nr].windx,&win[nr].windy,
           &win[nr].windw,&win[nr].windh);
  if (event & MU_MESAG)
   {
   switch (msgbuff[0])
    {
    case WM_NEWTOP:
     win[nr].wi_handle=msgbuff[3];
     wind_set(win[nr].wi_handle,WF_TOP,0,0,0,0);
     break;
    case WM_TOPPED:
     if (msgbuff[3] == win[0].wi_handle)
      nr = 0;
     else
      {
      if (msgbuff[3] == win[1].wi_handle)
       nr = 1;
      else
       {
       if (msgbuff[3] == win[2].wi_handle)
        nr = 2;
       else
        {
        if (msgbuff[3] == win[3].wi_handle)
         nr = 3;
        else
         form_alert(2,"[1][Schweine im|Weltall ! ][OK]");
        }
       }
      }
     wind_set(win[nr].wi_handle,WF_TOP,0,0,0,0);
     break;
    case WM_MOVED:
     if(msgbuff[4]+msgbuff[6] > 640)
      msgbuff[4] = 375;
     if(msgbuff[5]+msgbuff[7] > 400)
      msgbuff[5] = 215;
      wind_set(msgbuff[3],WF_CURRXYWH,msgbuff[4],msgbuff[5],
               msgbuff[6],msgbuff[7]);
      break;
    case WM_REDRAW:
     redraw(msgbuff[3],msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7],
            screen3,screen1);
     break;
    case WM_FULLED:
     setscr(screen2,screen2,-1);
     wait();
     setscr(screen1,screen1,-1);
     break;
    case WM_CLOSED:
     if(nr!=anz)
      form_alert(1,"[1][Nur das zuletzt|ge”ffnete Fenster|l„žt sich hiermit schliežen !][ OK ]");
     else 
      close_wind();
     break;
    case MN_SELECTED:
     switch(msgbuff[4])
      {
      case NEU:
       albutton=form_alert(1,"[1][Soll das Fractal|neu gezeichnet werden ?][ OK |Nein]");
       if(albutton==1)
        {
        clear_wind();
        if(fflag == 1)
         grey_frac(win[nr].xmax,win[nr].xmin,win[nr].ymax,win[nr].ymin,
                   maxiter,win[nr].windw/2,win[nr].windh/2,2);
        else
         bw_frac(win[nr].xmax,win[nr].xmin,win[nr].ymax,win[nr].ymin,
                 maxiter,win[nr].windw,win[nr].windh,2);
        }
        break;
      case QUIT:
       albutton=form_alert(1,"[1][Zurck zum Desktop ?][ OK |Nein]");
       if(albutton==1)  
        desktop();
       break;
      case BLOWUP:
       albutton = form_alert(1,"[2][Soll das Fractal|als Blowup|dargestellt werden ?][ OK |Nein]");
       if(albutton == 1)
        {
        hide_mouse();
        setscr(screen2,screen2,-1);
        clear_scr(screen2);
        if(fflag==1)
         grey_frac(win[nr].xmax,win[nr].xmin,win[nr].ymax,win[nr].ymin,
                   maxiter,319,199,1);
        else
         bw_frac(win[nr].xmax,win[nr].xmin,win[nr].ymax,win[nr].ymin,
                 maxiter,640,400,1);
        wait();
        setscr(screen1,screen1,-1);
        show_mouse();
        }
       break;
      case LOW:
       maxiter = 50;
       break;
      case MEDIUM:
       maxiter = 100;
       break;
      case HIGH:
       maxiter = 500;
       break;
      case GREY:
       fflag = 1;
       break;
      case BW:
       fflag = 2;
       break;
      case LOAD:
       get_file();
       filereturn = open(name,0);
       if (filereturn > 0)
        read(filereturn,32000L,screen2);
       close(filereturn);
       break;
      case SAVE:
       get_file();
       filereturn = create(name,0);
       if(filereturn > 0)
        write(filereturn,32000L,screen2);
       close(filereturn);
       break;
      case DRUCKE:
       albutton = form_alert(1,"[2][Soll das Blow-Up|gedruckt werden ?][ OK |Nein]");
       if(albutton == 1)
        hardcopy();
       break;
      case ABOUT:
       form_alert(2,"[1][GemFrac ST| |½ by Norbert|Marschalleck][OK]");
      break;
      }
     checkmark();
     menu_tnormal(menue_addr,msgbuff[3],1);
     break;  
     }
    }
 wind_update(FALSE); 
 if((event & MU_BUTTON))
  {
  if(butdown)
   {
   if ((mausx>=win[nr].windx)&&(mausx<=win[nr].windx+win[nr].windw)&&(mausy>=win[nr].windy)&&(mausy<=win[nr].windy+win[nr].windh))
    {
    graf_rubberbox(mausx,mausy,8,5,&lastw,&lasth);
    albutton=form_alert(1,"[1][Soll der Ausschnitt neu|berechnet werden ?][ OK |Nein]");
    if(albutton==1)
     {
     if (anz==3)
      form_alert(1,"[1][Mehr Fenster gibt es nicht !][ Na Gut]");
     else
      change(win[nr].xmax,win[nr].ymax,win[nr].xmin,win[nr].ymin,
             win[nr].windx,win[nr].windy);
     }
    }
    butdown = FALSE;
   }
  else
  butdown = TRUE;
  }
 }
 while(anz>=0);
 menu_bar(menue_addr,0);
 close_scr();
}
