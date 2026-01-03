/* NOTEPAD.ACC 3/87 last update 2.4.87 B.Rockmann/Postbox 610356/1000 BERLIN 61*/

#include <stdio.h>
#include <osbind.h>
#include <gemdefs.h>
#define TEXT "A:\\NOTEPAD.TXT"
#define CHARS 40
#define LINE 15
#define PAGE 8

typedef
struct grect
        { int g_x;
          int g_y;
          int g_w;
          int g_h;
        }
  GRECT;
int contrl[12],intin[128],intout[128],ptsin[128],ptsout[128];
int handle,work_in[12],work_out[57];
int pxyarray[12];
extern gl_apid;
int menu_id;
int msgbuf[8];
int window,x,y,b,h,xa,ya,ba,ha;

int xmin,ymin,xmax,ymax,le1,i1,i2;
int key,cx,cy,cs,datei,result;

int auf,xmouse,ymouse,prin;
char db[44];
char t[LINE*CHARS*PAGE],fs_iinpath[80];
char *fn=" ØØ NOTEPAD ÆÆ  page #1 ";
open_work()
{
 int i;
 for(i=0;i<10;work_in[i++]=1);
 work_in[10]=2;
 v_opnvwk(work_in,&handle,work_out);
}
main()
{
 int i,width,height;
 appl_init();
 menu_id=menu_register(gl_apid,"  NOTEPAD");
 wind_get(0,WF_WORKXYWH,&xmin,&ymin,&width,&height);
 xmax=xmin+width-1; ymax=ymin+height-1;
 window= -1;
 x=30; y=15; b=CHARS*8+28; h=LINE*9+40;
 cx=0; cy=0; cs=0;
 auf=0; prin=0;
 for(i=0;i<sizeof(t);t[i++]=32);
 ev_ld();
 multi();
}
multi()
{
 int d,ereignis;
 while (1)
  { ereignis=evnt_multi(MU_MESAG|MU_BUTTON|MU_KEYBD|MU_M1,
                        1,1,1,auf,xa,ya,ba,ha,0,0,0,0,0,
                        msgbuf,0,0,&xmouse,&ymouse,&d,&d,&key,&d);
    if (ereignis & MU_MESAG)
     switch (msgbuf[0])
      { case AC_OPEN:
         open();
         break;
        case AC_CLOSE:
         if (msgbuf[3]==menu_id && window>=0)
          { v_clsvwk(handle);
            window= -1;
          }
        case WM_CLOSED:
         if (msgbuf[3]==window)
          close();
         break;
        case WM_REDRAW:
                 redraw();
                 break;
                case WM_MOVED:
                 x=msgbuf[4]; y=msgbuf[5];
                 wind_set(window,WF_CURRXYWH,x,y,b,h);
                 wind_get(window,WF_WORKXYWH,&xa,&ya,&ba,&ha);
                 break;
                case WM_NEWTOP:
                case WM_TOPPED:
                 wind_set(window,WF_TOP,msgbuf[4],msgbuf[5],msgbuf[6],
                                        msgbuf[7]);
                 break;
                case WM_VSLID:
                 neue_seite(1);
                 break;
                case WM_ARROWED:
                 neue_seite(2);
        }
if (ereignis & MU_KEYBD)
        zeichen();
if (ereignis & MU_M1)
        rout();
        if (ereignis & MU_BUTTON)
                button();
        }
}
open()
{
        if (window>=0)
                wind_set(window,WF_TOP,x,y,b,h);
        else
        { open_work();
                fenster();
        }
}
fenster()
{
        window=wind_create(NAME|INFO|CLOSER|MOVER|VSLIDE,xmin,ymin,xmax,ymax);
        fn[22]=cs+49;
        wind_set(window,WF_NAME,fn,0,0);
        wind_set(window,WF_INFO," [HELP] [F1] [F2] [F3] [F4] [F5] [F9] [F10]",0,0);
        wind_set(window,WF_VSLSIZE,(1000/PAGE),0,0,0);
        wind_set(window,WF_VSLIDE,cs*(1000/PAGE-1),0,0,0);
        wind_update(1);
        graf_mouse(256,0);
        graf_growbox(16,1,32,16,x,y,b,h);
        wind_open(window,x,y,b,h);
        wind_get(window,WF_WORKXYWH,&xa,&ya,&ba,&ha);
        graf_mouse(257,0);
        wind_update(0);
}
clip(xc,yc,bc,hc)
        int xc,yc,bc,hc;
        {
        pxyarray[0]=xc; pxyarray[1]=yc;
        pxyarray[2]=xc+bc-1; pxyarray[3]=yc+hc-1;
        vs_clip(handle,1,pxyarray);
        }
clip_aus()
        {
        vs_clip(handle,0,pxyarray);
        }
text()
{
        int d;
        register int i,j,c;
        char buf[CHARS+2];
        register char *b=buf;
        vsf_interior(handle,1);
        vsf_color(handle,0);
        vsf_perimeter(handle,0);
        pxyarray[0]=xa; pxyarray[1]=ya;
        pxyarray[2]=xa+ba-1; pxyarray[3]=ya+ha-1;
        graf_mouse(256,0);
        v_bar(handle,pxyarray);
        fn[22]=cs+49;
        wind_set(window,WF_NAME,fn,0,0,0);
        height();
        c=cs*LINE*CHARS;
        for(i=0;i<=(LINE-1);i++)
        {       for(j=0;j<=(CHARS-1);*(b+j)=t[c+i*CHARS+j++]);
                *(b+j+1)=0;
                v_gtext(handle,xa+2,ya+i*9+9,b+1);
        }
        cursor();
        graf_mouse(257,0);
}
height()
{       int d;
        vst_point(handle,9,&d,&d,&d,&d);
}
close()
{       wind_update(1);
        graf_mouse(256,0);
        wind_close(window);
        graf_shrinkbox(16,1,32,16,x,y,b,h);
        wind_delete(window);
        graf_mouse(257,0);
        wind_update(0);
        v_clsvwk(handle);
        window= -1;
}
redraw()
{       GRECT t1,t2;
        wind_update(1);
        graf_mouse(256,0);
        t2.g_x=msgbuf[4]; t2.g_y=msgbuf[5];
        t2.g_w=msgbuf[6]; t2.g_h=msgbuf[7];
        wind_get(window,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
        while(t1.g_w && t1.g_h)
        {       if (rc_intersect(&t2,&t1))
                { clip(t1.g_x,t1.g_y,t1.g_w,t1.g_h);
                        text();
                }
                wind_get(window,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
        }
clip_aus();
graf_mouse(257,0);
wind_update(0);
}
zeichen()
{
        int top,d,t1,t2;
        char b[2];
        b[1]=0;
        wind_get(window,WF_TOP,&top,&d,&d,&d);
        if (top!=window) return;
        clip(xa,ya,ba,ha);
        t1=key & 255;
        t2=key/256;
        switch(t2)
        { case 0x48:
                cursor();
                if (cy>0)  cy--;
                cursor();
                break;
          case 0x50:
                cursor();
                if (cy<(LINE-1)) cy++;
                cursor();
                break;
          case 0x4B:
                cursor();
                cx--;
                if (cx<0) { cx=(CHARS-1); cy--; }
                if (cy<0) { cy=0; cx=0; }
                cursor();
                break;
          case 0x4D:
                cursor();
                cx++;
                if (cx>(CHARS-1)) { cy++; cx=0; }
                if (cy>(LINE-1)) { cy=(LINE-1); cx=(CHARS-1); }
                cursor();
                break;
          case 0x62:
                help();
                break;
          case 0x3B:
                speichern();
                break;
          case 0x3C:
                laden(0);
                text();
                break;
          case 0x3D:
                t_clr();
                break;
          case 0x3E:
                clr();
                break;
          case 0x3F:
                if(form_alert(1,"[2][ |Print text ?][yes|no]")==2) return;
                if(prin==0) prin=form_alert(0,"[2][ |Kind of PRINTER:][EPSON|IBM]");
                while(Cprnos()==0)  if(form_alert(1,"[3][ |Printer not ready ?][now OK|break]")==2) return;
                le1=sizeof(t)-1;
                while(t[le1]==32) le1--;
                for(i1=0;i1<le1;) { for(i2=0;i2<40;i2++) {
                if(i1>le1) { Cprnout(10); Cprnout(13); break; }
                if(prin==1) epson(t[i1]);
                else Cprnout(t[i1]);
                i1++; }
                Cprnout(10);
                Cprnout(13); }
                break;

          case 0x43:
                if (cs>0) cs--;
                neue_seite(3);
                break;
          case 0x44:
                if (cs<(PAGE-1)) cs++;
                neue_seite(3);       
        }
        switch(t1)
        { case 0: break;
          case 8:
                cursor();
                cx--;
                if (cx<0) { cx=(CHARS-1); cy--; if (cy<0) { cy=0; cx=0;
                                        cursor(); break; }
                                  }
                t[cs*CHARS*LINE+cy*CHARS+cx]=32;
                b[0]=32;
                height();
                v_gtext(handle,xa+2+cx*8,ya+9+cy*9,b);
                cursor();
                break;
          case 13:
                if (cy<(LINE-1))
                {       cursor();
                        cx=0; cy++;
                        cursor();
                }
                break;
          default:
                cursor();
                t[cs*CHARS*LINE+cy*CHARS+cx]=t1;
                b[0]=t1;
                height();
                graf_mouse(256,0);
                v_gtext(handle,xa+2+cx*8,ya+9+cy*9,b);
                graf_mouse(257,0);
                cx++;
                if (cx>(CHARS-1))
                {       if (cy!=(LINE-1))
                        {       cx=0; cy++; }
                        else cx=(CHARS-1);
                }
                cursor();
        }
        clip_aus();
}
cursor()
{       vswr_mode(handle,3);
        pxyarray[0]=xa+cx*8+2; pxyarray[1]=ya+cy*9+2;
        pxyarray[2]=pxyarray[0]+7; pxyarray[3]=pxyarray[1]+8;
        graf_mouse(256,0);
        v_bar(handle,pxyarray);
        graf_mouse(257,0);
        vswr_mode(handle,1);
}
epson(zei)          /* Druckeranpassung EPSON */
char zei;
{
     switch (zei) {
     case 64: usa(); break;
     case 91: usa(); break;
     case 92: usa(); break;
     case 93: usa(); break;
     case 123: usa(); break;
     case 124: usa(); break;
     case 125: usa(); break;
     case 126: usa(); break;
     case 'Å': ger(); zei=125; break;
     case 'Ñ': ger(); zei=123; break;
     case 'é': ger(); zei=91; break;
     case 'î': ger(); zei=124; break;
     case 'ô': ger(); zei=92; break;
     case 'ö': ger(); zei=93; break;
     case '›': ger(); zei=64; break;
     case 'û': ger(); zei=126; }
     Cprnout(zei); ger();
}
usa()
{
     Cprnout(27);
     Cprnout('R');
     Cprnout(0);
}
ger()
{
     Cprnout(27);
     Cprnout('R');
     Cprnout(2);
}
speichern()
{       char *buf;
        long b;
        int i3;
        if (form_alert(1,"[2][ |Save text ?][yes|no]")==2) return;
        sel_file();
        if (result == 0) return;
        Fsetdta(db);
        Fdelete(fs_iinpath);
        datei=Fcreate(fs_iinpath,0);
        if (datei<0)
        { diskfehler(); return; }
        le1=sizeof(t)-1;
        while(t[le1]==32) le1--;
        buf=malloc(le1+((le1/40)*2)+2);
        i1=0; i2=0;
        while(i1<le1+((le1/40)*2)+2) {
        for(i3=0;i3<40;i3++) {
        buf[i1++]=t[i2++]; }
        buf[i1++]=10;
        buf[i1++]=13; }
        --i1;
        b=Fwrite(datei,(long)i1,buf);
        Fclose(datei);
        if (b<i1) { Fdelete(fs_iinpath); voll(); }
        free(buf);
}
laden(modus)
int modus;
{
        char *buf;
        unsigned f_len;
        if (modus==0) {
        if (form_alert(1,"[2][ |Load text ?][yes|no]")==2) return;
        sel_file(); if (result == 0) return; }
        Fsetdta(db);
        if (modus == 1) datei=Fopen(TEXT,0);
        else      datei=Fopen(fs_iinpath,0);
        if (datei<0)
        { diskfehler(); return; }
        for(i1=0;i1<sizeof(t);t[i1++]=32);
        f_len=(unsigned)lseek(datei,0L,2);
        buf=malloc(f_len);
        lseek(datei,0L,0);
        read(datei,buf,f_len);
        Fclose(datei);
        i1=0; i2=0;
        while(i1<f_len) {
        if(i1>sizeof(t)) break;
        if(buf[i1]==13 || buf[i1]==10) i1++;
        else t[i2++]=buf[i1++]; }
        free(buf);
}

sel_file()
{
     char fs_iinsel[80];
     int  *fs_iexbutton, i;
     wind_update(1);
     strcpy(fs_iinpath," :\*.TXT");
     strcpy(fs_iinsel,"NOTEPAD.TXT");
     fs_iinpath[0] = Dgetdrv()+'A';
     result=fsel_input(fs_iinpath,fs_iinsel,&fs_iexbutton);
     if (result == 0 || fs_iexbutton == 0 || strlen(fs_iinsel) <1)
     {
      result=0; wind_update(0); return;
     }
     else
     {
      i=strlen(fs_iinpath);
      while(fs_iinpath[i] != '\\') i-- ;
      fs_iinpath[++i]='\0';
      strcat(fs_iinpath, fs_iinsel);
      wind_update(0);
     }
}

clr()
{       register int i;
        if (form_alert(2,"[2][ |Delete text ?][yes|no]")==2) return;
        for(i=0;i<sizeof(t);t[i++]=32);
        cx=0; cy=0;
        clip(xa,ya,ba,ha);
        text();
        clip_aus();
}
t_clr()
{       register int i;
        if (form_alert(2,"[2][ |Delete page ?][yes|no]")==2) return;
        for(i=cs*CHARS*LINE;i<(cs+1)*CHARS*LINE;t[i++]=32);
        cx=0; cy=0;
        clip(xa,ya,ba,ha);
        text();
        clip_aus();
}
voll()
{       form_alert(1,"[3][ |Disk full ?][return]"); }

diskfehler()
{       switch(datei)
        { case -13:
                break;
          default:
                form_alert(1,"[3][ |Disk- or File-ERROR !][return]");
        }
}
ev_ld()
{       Fsetdta(db);
        if (Fsfirst(TEXT,0)) return;
        laden(1);
}
help()
{       form_alert(1,"[0][F1=Save text     F2=Load text|F3=Delete page   F4=Delete all|F5=Print text|F9=precede page  F10=next page][OK]");
        form_alert(1,"[1][NOTEPAD by B.Rockmann|Postbox 610356|D-1000 BERLIN 61| ][Okay]");
}
rout()
{       int top,d;
        switch(auf)
        { case 0:
                wind_get(window,WF_TOP,&top,&d,&d,&d);
                if (top!=window) return;
                graf_mouse(3,0);
                auf=1;
                break;
          case 1:
                graf_mouse(0,0);
                auf=0;
        }
}
button()
{       if (wind_find(xmouse,ymouse)!=window) return;
        if (ymouse<ya) return;
        cursor();
        cx=(xmouse-xa)/8;
        if (cx>=CHARS) cx=CHARS-1;
        cy=(ymouse-ya-1)/9;
        if (cy>=LINE) cy=LINE-1;
        clip(xa,ya,ba,ha);
        cursor();
        clip_aus();
}
neue_seite(modus)
int modus;
{       if (msgbuf[3]!=window) return;
        switch(modus)
        { case 1:
                cs=msgbuf[4]/((1000/PAGE)+1);
                break;
          case 2:
                switch(msgbuf[4])
                { case 0:
                        if (cs>0) cs--;
                        break;
                  case 1:
                        if (cs<(PAGE-1)) cs++;
                        break;
                }
        }
        wind_set(window,WF_VSLIDE,cs*1000/(PAGE-1),0,0,0);
        cx=0; cy=0;
        clip(xa,ya,ba,ha);
        text();
        clip_aus();
}
