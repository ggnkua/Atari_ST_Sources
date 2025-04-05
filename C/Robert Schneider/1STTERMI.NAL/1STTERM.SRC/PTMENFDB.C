#define STRING01 "Datei senden"
#define STRING02 "Datei empfangen"
#define STRING03 "Auto-Logon lÑuft - Undo = Abbruch"
#define STRING031 "\15\12Auto-Logon lÑuft - Undo = Abbruch\15\12"

#define FORM01 "[1][Schau,  Schau,|da ist ja noch 'ne|Taste an der Maus !][Toll]"
#define FORM02 "[1][Sie sind ein wahrer KÅnstler !][Richtig]"
static char FORM03[] = "[2][Programm beenden ?][Ja|Nein]";
#define FORM04 "[1][laden/speichern -> Diskette|Eingeben:|Computer = String senden|Floppy = Datei senden (wie Online)][OK]"
#define FORM05 "[1][Also a bisserl was|kînntn's scho selber macha][Faulpelz]"
#define FORM06 "[0][Dateien senden und|empfangen wie im|MenÅpunkt 'öbertragungsart'|eingestellt.][Abbruch|Senden|Empfangen]"

#define FORM09 "[2][Dateiname fÅr Senden :|'%s'"
static char FORM10[] =
"||öbertragungsabbruch :|Beide Maustasten oder Taste !][Ohne Echo|Mit Echo|Abbruch]";
#define FORM11 "[1][Sendung beendet !][OK]"
#define FORM12 "[2][Dateiname fÅr Empfangen :|'%s'"
#define FORM13 "[1][Sendung wird abgebrochen !][OK]"
#define FORM15 "[2][Abbrechen ?][Ja|Nein]"
#define FORM16 "[1][Nur im Online-Modus|mit eingeladenem .LOG !][OK]"
overlay "menfdb"

#include <megatadd.h>
#include <osbind.h>
#include <gembind.h>
#include "ptvars.h"

#ifdef COLOR
   #include "1STTERMC.H"
#else
   #include "1STTERMM.H" 
#endif

extern long fil_len();

main()
{
   int ex;

   ex=init_pb();
   if(ex==1)
   {
      multi();

      if(online)
         wind_update(END_MCTRL);

      ptexit(-2);
   }
   ptexit(ex);
}


multi()
{
   int a,b,x_old,y_old;
   int msgbuff[20];
   int event,butdown,mx,my,dummy,keycode;
   GRECT work;
   char *p_string;
   int start = 1;
   save_screen();

   do
   {
      if(online&&start)
      {
         p_string=OB_SPEC(mainmenu,ONLINE);
         if(p_string[1]!=8)
         {
            wind_update(BEG_MCTRL);
            p_string[1]=8;
            clr_window();
            x_old=y_old=0;
         }
      }

      if(onli_vt52&&start)
      {           
         p_string=OB_SPEC(mainmenu,VT__MODE);

/**************************************************************************

        Dies habe ich geÑndert, nachdem Alfred mich am 04.05.87
        angerufen hat, und mir mitteilte, daû der Start mit ein-
        geschaltenem VT52 nicht funktioniert. Noch nicht compiliert.
        Vielleicht geht es mit patchen.

         onli_vt52=0;
         vt_norm(p_string);

***************************************************************************/
/**************************************************************************
        Das ist der Fehler, den wir nicht beachtet haben, als wir
        den VT52 auf Window umgestellt haben. */

         if(p_string[1]!=8)
         {
            *(p_string+1)=8;
#ifdef COLOR
            screenline=1120l;
#else
            screenline=1200l;
#endif
            wind_close(wi_han1);
            graf_shrinkbox(SMXY,SMWH,window_box);
            set_xy_cur();
            graf_growbox(SMXY,SMWH,window_box);
            clr_window();
         }
/**************************************************************************/
      }

      if(profibox&&start)
      {
         p_string=OB_SPEC(mainmenu,BOX_MODE);
         if(p_string[1]!=8)
         {
            *(p_string+1)=8;
            boxstart=buf_point;
            login=0;
            main_da=sub_da=0;
         }
      }
   
      start = 0;                  

      if(!irq_menu&&!online)
      {
         event = evnt_multi(MU_MESAG | MU_TIMER,
                            1,1,butdown,
                            0,0,0,0,0,
                            0,0,0,0,0,
                            msgbuff,30,0,&mx,&my,&dummy,&dummy,&keycode,&dummy);
      }
      else
         event=MU_TIMER;

      if(event&MU_TIMER&&irq_menu==1)
      {
         wind_get(0,WF_TOP,&a,&b,&b,&b);
         if(a!=wi_han1)
         {
            wind_set(wi_han1,WF_TOP);
            do_redraw();
         }
         event=do_menu(msgbuff);
      }

      irq_menu=0;

      if(event & MU_MESAG)
         switch (msgbuff[0])
         {
            case MN_SELECTED:
               alert_akt=1;
               buf=msgbuff[3];
               switch(msgbuff[4])
               {
                  case MN___ACC : show_acc(); break;
                  case ABOUT    : do_about(); break;
                  case RS232    : do_rs232(); break;
                  case MN_BREMS : brems_wie_die_sau(); break;
                  case SETUPSET : do_setup(); break;
                  case TRANSSET : do_transfer(); break;
                  case PAR_DISK : if(!para_disk())
                                  {
                                    alert_akt=0;
                                    start=1;  
                                    continue;
                                  }
                                    break;
                  case QUIT     : if(brain_alert(2,FORM03)==1)
                                     return;
                                  break;
                  case JORNAL   : do_jornal(); break;
                  case MNEDITOR : if(ed_a_msg())
                                  { 
                                    clr_window();
                                    save_screen();
                                    x_old=y_old=0;
                                  }  
                                  break;
                  case LOGSTART : 
                                 if(online&&autoda)
                                 {
                                    auto_on=1; code=0; waiter=0;
#ifndef COLOR
                                    if(onli_vt52)
                                    {
                                       out_s(STRING031);
                                       save_screen();
                                       x_old=xcur;
                                       y_old=ycur;
                                    }
                                    else
#endif      
                                       wind_set(wi_han1,WF_NAME,
                                    STRING03);
                                    such1[0]=such2[0]=0;
                                 }
                                 else
                                 {
                                    mouseset(0,0);
                                    brain_alert(1,FORM16);
                                    mouseset(1,1);
                                 }
                                 break;
                                 
                  case LOG_COMP : do_compiler();
                                  x_old=y_old=0;
                                  break;
                  case LOG_LOAD : load_auto(0); PFEIL; break;
                  case F___INFO : brain_alert(1,FORM04); break;
                  case F____KEY : do_fkey(); break;
                  case F___SHOW : do_fshow();break;
                  case F___DISK : do_fdisk();break;
                  case MN_MODEM : do_modem(); break;
                  case MN__EXEC : if(do_exec(0))
                                    x_old=y_old=0;
                                  break;

                  case FILEINFO : file_info(); break;
                  case FILESHOW : file_out(); break;
                  case FILE_REN : file_ren(); break;
                  case FILECOPY : file_copy(); break;
                  case FILE_DEL : file_del(); break;
                  case FILE__RS : switch(brain_alert(1,FORM06))
                                  {
                                    case 2:  send_file();break;
                                    case 3:  receive_file();
                                  }
                                  break;
                  case FILE_SEN : send_file(); break;
                  case FILE_REC : receive_file(); break;
                  case BUF___RS : buf_rs(); break;
                  case BUF__OUT : buf_out(); break;
                  case BUF_INFO : buf_info(); break;
                  case BUF__DIL : if(buf_del())
                                    x_old=y_old=0;      
                                  break;
                  case BUF_LOAD : buf_load(); break;
                  case BUF_SAVE : buf_save(); break;
                  case BOX_MODE : p_string=OB_SPEC(mainmenu,BOX_MODE);
                                  if(profibox)
                                  {
                                     *(p_string+1)=32;
                                     profibox=0;
                                     login=1;
                                  }
                                  else
                                  {
                                     *(p_string+1)=8;
                                     profibox=1;
                                     boxstart=buf_point;
                                     login=0;
                                     main_da=sub_da=0;
                                  }
                                  break;

                  case VT__MODE : p_string=OB_SPEC(mainmenu,VT__MODE);
                                  x_old=y_old=0;
                                  vt_norm(p_string);
                                  clr_window();
                                  save_screen();
                                  break;

                  case ONLINE   : p_string=OB_SPEC(mainmenu,ONLINE);
                                  if(online)
                                  {
                                    p_string[1]=32;
                                    online=0;
                                    wind_update(END_MCTRL);
                                  }
                                  else
                                  {
                                    p_string[1]=8;
                                    online=1;
                                    clr_window();
                                    alert_akt=0;
                                    wind_update(BEG_MCTRL);
                                    do_online();
                                    x_old=xcur;
                                    y_old=ycur;
                                    save_screen();
                                  }
                                  break;
               }
               do_redraw();
               alert_akt=0;
               break;

            case WM_TOPPED:
               wind_set(wi_han1,WF_TOP,0,0,0,0);
               set_xy_cur(wi_han1);
            case WM_REDRAW:
               do_redraw();
               break;

            case WM_SIZED:
               wind_calc(1,WI_KIND,msgbuff[4],msgbuff[5],msgbuff[6],
                         msgbuff[7],&work.g_x,&work.g_y,&work.g_w,&work.g_h);
               work.g_w = (work.g_w < 80) ? 80 : work.g_w;
#ifdef COLOR
               work.g_h = (work.g_h < 40) ? 40 : work.g_h;
#else
               work.g_h = (work.g_h < 80) ? 80 : work.g_h;
#endif
               work.g_x=align_x(work.g_x);
               work.g_w=align_x(work.g_w);
               wind_calc(0,WI_KIND,work.g_x,work.g_y,work.g_w,work.g_h,
                         &msgbuff[4],&msgbuff[5],&msgbuff[6],&msgbuff[7]);
               wind_set(top_window,WF_CXYWH,msgbuff[4],msgbuff[5],
                        msgbuff[6],msgbuff[7]);
               set_xy_cur(wi_han1);
               do_redraw();
               break;

            case WM_MOVED:
               wind_get(top_window,WF_CXYWH,&work.g_x,&work.g_y,
                                            &work.g_w,&work.g_h);
               work.g_x    = (work.g_w+msgbuff[4]>640)
                            ? 640-work.g_w : msgbuff[4];
#ifdef COLOR
               work.g_y    = (work.g_h+msgbuff[5]>200)
                            ? 200-work.g_h : msgbuff[5];
#else
               work.g_y    = (work.g_h+msgbuff[5]>400)
                            ? 400-work.g_h : msgbuff[5];
#endif
               work.g_x=align_x(work.g_x);
               wind_set(top_window,WF_CXYWH,align_x(work.g_x)-1,
                        work.g_y,msgbuff[6],msgbuff[7]);
               set_xy_cur(wi_han1);
               do_redraw();
               break;

            case WM_FULLED:
               do_full(top_window,1);
               break;

            case WM_CLOSED:
               if(brain_alert(2,FORM03)==1)
                  return;

         } /* switch (msgbuff[0]) */

         if(online)
         {
            xcur=x_old;
            ycur=y_old;
            do_online();
            x_old=xcur;
            y_old=ycur;
            save_screen();
         }      
   }while(1);
}

do_about()
{
   GRECT menbox;
   int exit;

   TASSE;
   objc_xywh(mainmenu,DESK,&menbox);
   exit=hndl_dial(about_di,0,menbox.g_x,menbox.g_y,menbox.g_w,menbox.g_h);
   undo_objc(about_di,exit,SELECTED);
   PFEIL;
}



show_acc()
{
   int msgbuf[16];


   if(online)
      wind_update(END_MCTRL);

   menu_bar(deskmenu,1);
   do
   {
      evnt_mesage(msgbuf);

      if(msgbuf[0]==WM_REDRAW)
         do_redraw();

      if(msgbuf[0]==MN_SELECTED&&msgbuf[4]==ACCABOUT)
      {
         do_about();
         menu_tnormal(deskmenu,msgbuf[3],1);
      }
   }while(msgbuf[0]!=10||msgbuf[4]!=ACC_BACK);

   menu_tnormal(deskmenu,msgbuf[3],1);
   menu_bar(deskmenu,0);

   init_menu();
   wind_set(wi_han1,WF_TOP);

   if(online)
      wind_update(BEG_MCTRL);

}

send_file()
{
   char pfad[80];
   char name[80];
   int x;

   save_screen();
   if(mode!=2)
   {
      pfad[0]=name[0];
      if(!file_select(STRING01,pfad,name,"*.*"))
      {
         do_redraw();
         return;
      }

      do_redraw();

      strcat(pfad,name);
   }

   switch(mode)
   {
      case 0 : send_raw(pfad); break;
      case 1 : if(xmode)
                  Rsconf(-1,0,-1,-1,-1,-1);
               xmodem(1,pfad);
               if(xmode)
                  Rsconf(-1,xmode,-1,-1,-1,-1);
               break;
      case 2 : kermit(1); break;
      case 3 : send_1st(pfad); break;
      default: break;
   }
   if(!online)
      do_redraw();
}

receive_file()
{
   int x;
   char pfad[80];
   char name[80];

   save_screen();
   if(mode!=2)
   {
      pfad[0]=name[0];
      if(!file_select(STRING02,pfad,name,"*.*"))
      {
         do_redraw();
         return;
      }

      do_redraw();
 
      strcat(pfad,name);
   }

   switch(mode)
   {
      case 3 :
      case 0 : receive_raw(pfad); break;
      case 1 : if(xmode)
                  Rsconf(-1,0,-1,-1,-1,-1);
               xmodem(0,pfad);
               if(xmode)
                  Rsconf(-1,xmode,-1,-1,-1,-1);
               break;
      case 2 : kermit(0); break;
      default: break;
   }
   if(!online)
      do_redraw();
}

send_raw(name)
char *name;
{
   int e;
   int a,handle;
   long len,r_len;
   char c;
   char *p;
   char string[300];

   len=fil_len(name);
   if(len<0)
   {
      brain_alert(1,ALNOTOPEN);
      return;
   }

   handle=Fopen(name,0);
   if(handle<6)
   {
      brain_alert(1,ALNOTOPEN);
      return;
   }

   sprintf(string,FORM09,name);
   strcat(string,FORM10);


   e=brain_alert(1,string)-1;
   if(e==2)
      return;

   if(e)
      hide_mouse();

   while(Bconstat(2))
      Bconin(2);

   while(len>0)
   {
      r_len=(len>19999)?19999:len;
    
      if(Fread(handle,r_len,box_space)!=r_len)
      {
         if(e)
            show_mouse();
         brain_alert(1,ALREAERR);
         Fclose(handle);
         return;
      }
      len-=r_len;

      box_space[r_len]=0;
      p=box_space;
      while(p<box_space+r_len)
      {
         if(mouse_but==3||Bconstat(2))
         {
            while(Bconstat(2))
               Bconin(2);
            if(e)
               show_mouse();
            Fclose(handle);
            save_screen();
            brain_alert(1,FORM13);
            return;
         }
         switch(transfer)
         {
            case 0 : c = *p++; break;
            case 1 : c = *(p++)&127; break;
            default: if(!(c=own_table[*p++]))
                        continue;
                     else
                        break;
         }
         portc(c);
         if(e)
            out_c(c);
      }
   }

   Fclose(handle);

   save_screen();

   if(e)
      show_mouse();

   brain_alert(1,FORM11);
}

receive_raw(name)
char *name;
{
   int e;
   int a,handle;
   char c;
   long len,r_len;
   char string[300];

   handle=Fcreate(name,0);
   if(handle<6)
   {
      brain_alert(1,ALNOTOPEN);
      return;
   }

   sprintf(string,FORM12,name);
   strcat(string,FORM10);

   e=brain_alert(1,string)-1;
   if(e==2)
      return;

   if(e)
      hide_mouse();

   while(Bconstat(2))
      Bconin(2);

   len =0;
   while(1)
   {
      while(len<20000)
      {

         if(mouse_but==3||Bconstat(2))
         {
            while(Bconstat(2))
               Bconin(2);
            save_screen();
            if(e)
               show_mouse();
            Fwrite(handle,len,box_space);
            len=0;
            if(brain_alert(1,FORM15)==1)
            {
               Fclose(handle);
               return;
            }
            else
               if(e)
                  hide_mouse();

         }

         if(Cauxis())
         {
            c=Cauxin();
            switch(transfer)
            {
               case 0 : break;
               case 1 : c&=127;
                        break;
               default: if(!(c=iwn_table[c]))
                           continue;
                        else
                           break;
            }
            *(box_space+len++)=c;
            if(e)
               out_c(c);
         }
      }
      Fwrite(handle,len,box_space);
   }
}

do_compiler()
{
   char pf[80],na[80];

   pf[0]=na[0]=0;
   if(!file_select("Logon-Source",pf,na,"*.SRC"))
      return;

   strcat(pf,na);
   do_exec(1,pf);
}

vt_norm(p_string)
char *p_string;
{
   if(onli_vt52)
   {
      *(p_string+1)=32;
      onli_vt52=0;
      screenline=1280l;
      graf_shrinkbox(SMXY,SMWH,window_box);
      wind_close(wi_han1);
      wind_delete(wi_han1);
      form_dial(3,0l,0l,SXY,SWH);
      wi_han1=wind_create(47,gl_xfull-1,gl_yfull,gl_wfull,gl_hfull);
      do_open(wi_han1,SMXY,align_x(gl_xfull)-1,gl_yfull,gl_wfull,gl_hfull);
      set_xy_cur(wi_han1);
      do_full(wi_han1,0);
   }
   else
   {
      *(p_string+1)=8;
      onli_vt52=1;
      wind_close(wi_han1);
      wind_delete(wi_han1);
      form_dial(3,0l,0l,SXY,SWH);
#ifdef COLOR
      wi_han1=wind_create(1,gl_xfull-1,gl_yfull,gl_wfull,gl_hfull);
      screenline=1120l;
#else
      wi_han1=wind_create(0,gl_xfull-1,gl_yfull,gl_wfull,gl_hfull);
      screenline=1200l;
#endif
      do_open(wi_han1,SMXY,align_x(gl_xfull)-1,gl_yfull,gl_wfull,gl_hfull);
      set_xy_cur();
      do_full(wi_han1,0);
   }
}
   
