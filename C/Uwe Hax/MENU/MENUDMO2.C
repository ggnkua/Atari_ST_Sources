/******************************************************************************/
/*                           MenÅdemo II V3.02                                */
/*                   - Jedem Fenster seine MenÅleiste -                       */
/*                          (C) 1990 by Uwe Hax                               */
/******************************************************************************/

#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>
#include <portab.h>

#include "menudmo2.h"

#define DESKTOP 0

WORD contrl[12];
WORD intin[128];
WORD ptsin[128];
WORD intout[128];
WORD ptsout[128];
WORD int_in[11];
WORD int_out[57];

WORD dummy;

FDB memory,screen;                   /* zum Sichern der MenÅzeile als Grafik */
WORD vdi_handle;                     /* Handle fÅr VDI-Routinen              */
WORD w1_handle,w2_handle;            /* Fenster-Kennungen                    */
LONG adr1,adr2;                      /* Speicheradressen fÅr Grafik          */

main()
{
  OBJECT *menu;                      /* Zeiger auf den MenÅbaum              */
  OBJECT *about;                     /* Zeiger auf die Info-Box              */
  REG WORD mesg_buff[8];             /* Message-Buffer                       */
  WORD x_desk,y_desk,w_desk,h_desk;  /* Koordinaten und Grîûe des Desktop    */
  REG WORD ende=FALSE;               /* Programmende                         */
  WORD x,y,w,h;                      /* Koordinaten fÅr Dialogbox            */

  /* Programm anmelden */
  appl_init();
  vdi_handle=graf_handle(&dummy,&dummy,&dummy,&dummy);
  open_vwork();
  hide_mouse();

  /* Resource-File mit MenÅzeile und Info-Box laden */
  if (!rsrc_load("menudmo2.rsc"))
  {
    form_alert(1,"[3][MENUDMO2.RSC nicht gefunden!][ Abbruch ]");
    appl_exit();
    exit();
  }
  rsrc_gaddr(R_TREE,MENU,&menu);
  rsrc_gaddr(R_TREE,DABOUT,&about);

  /* Fenster 1 erzeugen und îffnen */
  wind_get(DESKTOP,WF_WORKXYWH,&x_desk,&y_desk,&w_desk,&h_desk);
  w1_handle=wind_create(NAME | CLOSER | MOVER | SIZER,
                        x_desk,y_desk,w_desk,h_desk);
  wind_set(w1_handle,WF_NAME," Fenster 1 mit MenÅleiste ",0,0);
  wind_open(w1_handle,50,50,400,200);  /* Fenstergrîûe fÅr hîchste Auflîsung */

  /* MenÅzeile in Fenster 1 installieren */
  install_menu(w1_handle,menu,0,0,0,0);

  /* Fenster 1 mit Inhalt fÅllen */
  fill_window(w1_handle,menu);

  /* Fenster 2 erzeugen und îffnen */
  w2_handle=wind_create(NAME | CLOSER | MOVER | SIZER,
                        x_desk,y_desk,w_desk,h_desk);
  wind_set(w2_handle,WF_NAME," Fenster 2 mit MenÅleiste ",0,0);
  wind_open(w2_handle,100,100,500,250); /* Fenstergrîûe fÅr hîchste Auflîsung */

  /* MenÅzeile in Fenster 2 installieren */
  install_menu(w2_handle,menu,0,0,0,0);

  /* Fenster 2 mit Inhalt fÅllen */
  fill_window(w2_handle,menu);

  graf_mouse(ARROW,&dummy);
  show_mouse();

  /* Nachrichten verarbeiten, bis Programm beendet wird */
  do
  {
    evnt_mesag(mesg_buff);

    hide_mouse();
    wind_update(BEG_UPDATE);

    switch (mesg_buff[0])
    {
      case WM_REDRAW:    /* Fenster neuzeichnen */
                         redraw(mesg_buff[3],menu,mesg_buff[4],
                                mesg_buff[5],mesg_buff[6],mesg_buff[7]);
                         break;

      case WM_MOVED:     /* Fenster auf neue Koordinaten setzen */
                         wind_set(mesg_buff[3],WF_CURRXYWH,mesg_buff[4],
                                  mesg_buff[5],mesg_buff[6],mesg_buff[7]);

                         /* ACHTUNG: kein BREAK!! */
                         /* die folgenden Routinen mÅssen auch noch
                            ausgefÅhrt werden: */

      case WM_SIZED:    /* MenÅzeile anpassen und... */
                         install_menu(mesg_buff[3],menu,mesg_buff[4],
                                      mesg_buff[5],mesg_buff[6],mesg_buff[7]);

                         /* ...Fenster neu ausfÅllen */
                         fill_window(mesg_buff[3],menu);

                         break;

      case WM_TOPPED:    /* Fenster in den Vordergrund bringen */
                         wind_set(mesg_buff[3],WF_TOP,0,0,0,0);

                         /* und MenÅzeile installieren */
                         install_menu(mesg_buff[3],menu,0,0,0,0);
                         break;

      case WM_CLOSED:    /* Programmende */
                         ende=TRUE;
                         break;

      case MN_SELECTED:  /* MenÅeintrag wurde angewÑhlt */
                         if (mesg_buff[4]==ABOUT)
                         {
                           /* Info-Box zeichnen und wieder beenden */
                           about[OK].ob_state &= ~SELECTED;
                           form_center(about,&x,&y,&w,&h);
                           form_dial(FMD_START,x,y,w,h,x,y,w,h);
                           objc_draw(about,ROOT,MAX_DEPTH,x,y,w,h);
                           show_mouse();
                           form_do(about,0);
                           hide_mouse();
                           form_dial(FMD_FINISH,x,y,w,h,x,y,w,h);
                         }
                         /* MenÅtitel wieder zurÅcksetzen */
                         menu_tnormal(menu,mesg_buff[3],TRUE);
                         break;
    }

    wind_update(END_UPDATE);
    show_mouse();
  }
  while (!ende);

  /* Fenster schlieûen und lîschen */
  wind_close(w1_handle);
  wind_close(w2_handle);
  wind_delete(w1_handle);
  wind_delete(w2_handle);

  /* MenÅzeile entfernen und Programm verlassen */
  menu_bar(menu,FALSE);
  Mfree(adr1);
  Mfree(adr2);
  v_clsvwk(vdi_handle);
  appl_exit();
}


install_menu(w_handle,menu,x,y,width,height)
REG WORD w_handle;                   /* Fenster-Kennung                      */
REG OBJECT *menu;                    /* Adresse der MenÅleiste               */
WORD x,y,width,height;               /* neue Grîûe des Fensters; enthalten
                                        alle Werte 0, wird die augenblick-
                                        liche Grîûe und Position beibehalten */
{
  WORD wx,wy,ww,wh;                  /* Koordinaten des Arbeitsbereiches     */
  WORD cx,cy,cw,ch;                  /* Koordinaten der Fenster-Gesamtgrîûe  */
  WORD x_desk,y_desk,w_desk,h_desk;  /* Bildschirmausmaûe                    */
  REG WORD index1,index2;            /* MenÅ-Indices                         */
  REG WORD array[8];                 /* Eingabefeld fÅr diverse Routinen     */
  WORD m_width;                      /* MenÅ-Breite                          */
  WORD resolution;                   /* Auflîsung                            */
  WORD rows,cols;                    /* Bildschirmgrîûe                      */
  WORD tail=menu[0].ob_tail;         /* diverse AbkÅrzungen                  */
  WORD tail2=menu[tail].ob_head;
  WORD head=menu[0].ob_head;
  WORD head2=menu[head].ob_head;
  WORD temp1,temp2;

  static WORD first=TRUE;            /* erster Aufruf dieser Funktion?       */

  /* Grîûe des Arbeitsbereiches und Gesamtgrîûe des Fensters ermitteln */
  wind_get(w_handle,WF_WORKXYWH,&wx,&wy,&ww,&wh);
  wind_get(w_handle,WF_CURRXYWH,&cx,&cy,&cw,&ch);

  /* sind alle Åbergebenen Werte Null, wird die augenblickliche Grîûe und
     Position beibehalten */
  if (!x && !y && !width && !height)
  {
    x=cx;
    y=cy;
    width=cw;
    height=ch;
  }

  /* Minimalhîhe und -breite: willkÅrlich gewÑhlt */
  if (height<60)
    height=60;
  if (width<100)
    width=100;

  /* neue Fenstergrîûe setzen */
  wind_set(w_handle,WF_CURRXYWH,x,y,width,height);

  /* neue Position der MenÅzeile */
  menu[0].ob_x=x+1;
  menu[0].ob_y=y+(ch-wh)/2;     /* "/2" entfÑllt, falls das Fenster keine
                                   untere Leiste enthÑlt */

  /* geht die MenÅzeile Åber das Bildschirmende hinaus? */
  wind_get(DESKTOP,WF_WORKXYWH,&x_desk,&y_desk,&w_desk,&h_desk);
  if (menu[0].ob_x+width-cw+ww>x_desk+w_desk)
    width=x_desk+w_desk-menu[0].ob_x+cw-ww-1; /* Breite nur bis Bildschirmende */

  /* Breite der MenÅzeile = Breite des Fensters bzw. bis Bildschirmende */
  menu[head].ob_width=width-cw+ww;

  index1=menu[head2].ob_head;
  index2=tail2;
  menu[head2].ob_width=0 ;
  while (menu[index1].ob_type==G_TITLE)
  {
    /* Breite des MenÅtitels */
    temp1=menu[0].ob_x+menu[head].ob_x+menu[head2].ob_x+menu[index1].ob_x+
          menu[index1].ob_width;

    /* Breite des MenÅs */
    temp2=menu[0].ob_x+menu[tail].ob_x+menu[index2].ob_x+menu[index2].ob_width;

    /* welche MenÅs passen noch auf den Bildschirm bzw. ins Fenster? */
    if ((temp1>=x_desk+w_desk) || (temp2>=x_desk+w_desk) ||
        (temp1>=x+width-cw+ww) || (temp2>=x+width-cw+ww))
    {
      /* alle nicht mehr auf den Bildschirm passenden MenÅs abschalten */
      while (menu[index1].ob_type==G_TITLE)
      {
        menu[index1].ob_flags=HIDETREE;
        index1=menu[index1].ob_next;
      }
      break;
    }
    else
    {
      /* Breite der MenÅzeile anpassen */
      menu[head2].ob_width=menu[index1].ob_x+menu[index1].ob_width;

      /* MenÅ eingeschaltet */
      menu[index1].ob_flags=NONE;

      index1=menu[index1].ob_next;
      index2=menu[index2].ob_next;
    }
  }

  /* modifizierte MenÅzeile installieren */
  menu_bar(menu,TRUE);

  if (first)    /* erster Aufruf dieser Funktion? */
  {
    /* Breite des Bildschirms = maximale LÑnge der MenÅzeile */
    vq_chcells(vdi_handle,&rows,&cols);

    adr1=Malloc((LONG)(++cols*(menu[head].ob_height+2))); /* maximale Grîûe  */
    adr2=Malloc((LONG)(cols*(menu[head].ob_height+2)));

    /* sonstige Initialisierungen fÅr vro_cpyfm */
    resolution=Getrez();
    screen.fd_addr=0L;
    memory.fd_stand=0;
    memory.fd_nplanes=resolution ? 2/resolution : 4;

    first=FALSE;
  }

  /* MenÅzeile als Grafik fÅr Redraw sichern: */
  /* Quell-Koordinaten */
  array[0]=menu[0].ob_x+menu[head].ob_x;
  array[1]=menu[0].ob_y+menu[head].ob_y;
  array[2]=array[0]+menu[head].ob_width-1;
  array[3]=array[1]+menu[head].ob_height-1;

  /* Zielkoordinaten */
  array[4]=0;
  array[5]=0;
  array[6]=menu[head].ob_width-1;
  array[7]=menu[head].ob_height-1;

  /* sonstige jedesmal notwendige Initialisierungen */
  memory.fd_addr=(w_handle==w1_handle) ? adr1 : adr2;
  memory.fd_wdwidth=array[6]/16+1;
  vro_cpyfm(vdi_handle,3,array,&screen,&memory);
}


fill_window(w_handle,menu)
REG WORD w_handle;                   /* Fenster-Kennung                      */
OBJECT *menu;                        /* Adresse der MenÅzeile                */
{
  REG WORD array[4];                 /* Eingabefeld fÅr diverse Routinen     */
  WORD wx,wy,ww,wh;                  /* Koordinaten des Arbeitsbereichs      */
  WORD head=menu[0].ob_head;         /* als AbkÅrzung                        */

  /* Grîûe des Arbeitsbereiches des Fensters ermitteln */
  wind_get(w_handle,WF_WORKXYWH,&wx,&wy,&ww,&wh);

  /* Fenster und Hintergrund der MenÅzeile mit weiûer FlÑche fÅllen */
  vsf_color(vdi_handle,0);
  array[0]=wx;
  array[1]=wy+menu[head].ob_height+1;
  array[2]=wx+ww-1;
  array[3]=wy+wh-1;
  vr_recfl(vdi_handle,array);

  /* Linie unter der MenÅzeile zeichnen */
  array[0]=wx;
  array[1]=array[3]=wy+menu[head].ob_height;
  array[2]=wx+ww-1;
  vsf_color(vdi_handle,1);
  v_pline(vdi_handle,2,array);
}


redraw(w_handle,menu,x,y,width,height)
REG WORD w_handle;               /* Fenster-Kennung                          */
REG WORD x,y,width,height;       /* Koordinaten des zu erneuernden Bereiches */
OBJECT *menu;                    /* Adresse der MenÅzeile                    */
{
  GRECT rect1,rect2;             /* Strukturen fÅr Rechteck-Koordinaten      */
  WORD array[8];                 /* Eingabefeld fÅr diverse Routinen         */
  WORD wx,wy,ww,wh;              /* Koordinaten des Arbeitsbereiches         */
  WORD head=menu[0].ob_head;     /* als AbkÅrzung                            */
  WORD x_desk,y_desk,w_desk,h_desk; /* Bildschirmgrîûe                       */

  rect2.g_x=x;                   /* Redraw-Rechteck initialisieren           */
  rect2.g_y=y;
  rect2.g_w=width;
  rect2.g_h=height;

  /* Koordinaten und Grîûe des Arbeitsbereiches ermitteln */
  wind_get(w_handle,WF_WORKXYWH,&wx,&wy,&ww,&wh);

  /* Bildschirmgrîûe ermitteln... */
  wind_get(DESKTOP,WF_WORKXYWH,&x_desk,&y_desk,&w_desk,&h_desk);

  /* ...und damit Breite fÅr vro_cpyfm anpassen */
  if (wx+ww>x_desk+w_desk)
    ww=x_desk+w_desk-wx;

  /* Koordinaten und Grîûe des ersten neu zu zeichnenden Rechtecks aus
     der Rechteck-Liste holen */
  wind_get(w_handle,WF_FIRSTXYWH,&rect1.g_x,&rect1.g_y,&rect1.g_w,&rect1.g_h);

  while (rect1.g_w && rect1.g_h)  /* fertig? */
  {
    /* Åberlappen sich beide Rechtecke? */
    if (rc_intersect(&rect2,&rect1))
    {
      /* Clip-Koordinaten setzen */
      array[0]=rect1.g_x;
      array[1]=rect1.g_y;
      array[2]=rect1.g_x+rect1.g_w-1;
      array[3]=rect1.g_y+rect1.g_h-1;
      vs_clip(vdi_handle,TRUE,array);

      /* Fenster-Inhalt neu zeichnen */
      fill_window(w_handle,menu);

      /* Grafik der MenÅzeile neu zeichnen */
      /* Quellkoordinaten */
      array[0]=0;
      array[1]=0;
      array[2]=ww-1;
      array[3]=menu[head].ob_height-1;

      /* Zielkoordinaten */
      array[4]=wx;
      array[5]=wy;
      array[6]=wx+array[2];
      array[7]=wy+array[3];

      /* sonstige jedesmal notwendige Initialisierungen */
      memory.fd_addr=(w_handle==w1_handle) ? adr1 : adr2;
      memory.fd_wdwidth=array[2]/16+1;

      /* alle anderen Parameter sind bereits gesetzt */
      vro_cpyfm(vdi_handle,3,array,&memory,&screen);
    }

    /* Koordinaten und Grîûe des nÑchsten Rechtecks aus der Rechteck-
       Liste holen */
    wind_get(w_handle,WF_NEXTXYWH,&rect1.g_x,&rect1.g_y,&rect1.g_w,&rect1.g_h);
  }
}


open_vwork()      /* Virtuelle Workstation einrichten */
{
  REG WORD i;

  for (i=1; i<10; i++)
    int_in[i]=1;
  int_in[10]=2;
  v_opnvwk(int_in,&vdi_handle,int_out);
}


hide_mouse()       /* Maus ausschalten */
{
  graf_mouse(M_OFF,&dummy);
}


show_mouse()       /* Maus einschalten */
{
  graf_mouse(M_ON,&dummy);
}


