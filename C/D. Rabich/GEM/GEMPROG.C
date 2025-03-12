/******************************************************************************/
/* GEM-Rahmen-Programm                                            Vers. 1.00c */
/* ========================================================================== */
/* Autor: D. Rabich            *** Entwickelt mit Turbo C.                    */
/* ========================================================================== */
/* Quelldatei: GEMPROG.C                                                      */
/* ========================================================================== */
/* (c) 1992 MAXON Computer GmbH																								*/
/******************************************************************************/


/* Include-Dateien */
# include "gemprog.h"    /* Resource-Datei */
# include "interna.h"    /* ST-Interna     */
# include "scankey.h"    /* Scancodes      */
# include <aes.h>        /* AES-Routinen   */


/* Definition zweier Funktionen */
# define min(a,b)  ((a) < (b) ? (a) : (b))  /* Minimum */
# define max(a,b)  ((a) > (b) ? (a) : (b))  /* Maximum */


/* Handle des Desktops definieren */
# define DESK 0


/* Definitionen */
# define MAXSTRING 80

# define INIT_OK     0
# define NO_INIT     1
# define NO_RESOURCE 2


/* Strings */
char no_resource[] = "[3][ |  GEMPROG.RSC|  nicht gefunden.  | ][ OK ]";
char no_init[]     = "[3][ |  Initialisierung |  erfolglos.| ][ OK ]";
char rsc_name[]    = "GEMPROG.RSC";
char std_scrap[]   = "x:\\CLIPBRD";
/* hier auch Parameter-Datei angeben! */
/*  Format  : <Programm-Name>.INF     */
/*  Beispiel: GEMPROG.INF             */


/* Struktur(en) */
typedef struct { int x,y;       /* kennzeichnet einen Punkt  */
               } POINT;


/* Prototypen */
static int  init_prg(void);
static void exit_prg(int);
static void draw_objc(int, OBJECT*, int);
static void clip(GRECT*, GRECT*);
static void draw2_objc(int, OBJECT*, int);
static void move_objc(int, OBJECT*, int);
static void do_info(void);
static void hdle_menu(int, int);
static void hdle_mouse(int, POINT*);
static void hdle_key(int, int);


/* Variablen */
int       apl_id,            /* Applikations-ID */
          finish = 0;        /* Flag fÅr Ende   */
OBJECT    *menu,             /* MenÅ            */
          *desktop,          /* Desktop         */
          *infodial,         /* Dialogbox       */
          *aktion,           /* Alert-Boxen     */
          *laden,            /*        "        */
          *speichern,        /*        "        */
          *ausgabe;          /*        "        */
GRECT     desksize;          /* Desk-Grîsse     */


/******************************************************************************/
/* Anmeldung des Programms                                                    */
/* Aufgabe: Anmeldung beim AES, laden und auswerten der Resource-Datei,       */
/*          Scrap-Pfad setzen, MenÅ ausgeben, Desktop setzen,                 */
/*          Mauszeiger auf Pfeil setzen                                       */
/******************************************************************************/

static int init_prg (void)

{ char scrp_path[MAXSTRING];

  /* anmelden */
  apl_id = appl_init();
  if (apl_id < 0)                    /* korrekte ID? */
    return(NO_INIT);

  /* Maus als Biene/Sanduhr */
  graf_mouse(HOURGLASS,0L);

  /* Resource-Datei laden */
  if (!rsrc_load(rsc_name))        /* nicht gefunden? */
    { form_alert(1,no_resource);
      return(NO_RESOURCE);
    }
  /* Accessories, die unter GEM 2.x laufen sollen, */
  /* dÅrfen keine Resource-Dateien laden.          */

  /* Anfangsadressen ermitteln */
  rsrc_gaddr(R_TREE,  MENUE,   &menu);      /* MenÅ    */
  rsrc_gaddr(R_TREE,  DESKTOP, &desktop);   /* Desktop */
  rsrc_gaddr(R_TREE,  INFODIAL,&infodial);  /* Dialog  */

  rsrc_gaddr(R_STRING,DOPPEL,  &aktion);    /* Alert-Boxen */
  rsrc_gaddr(R_STRING,LADEN,   &laden);
  rsrc_gaddr(R_STRING,SPEICHER,&speichern);
  rsrc_gaddr(R_STRING,AUSGABE, &ausgabe);

  /* Grîsse des Desktops ermitteln */
  wind_get(DESK,WF_WORKXYWH,
           &desksize.g_x,&desksize.g_y,
           &desksize.g_w,&desksize.g_h);

  /* Object-Struktur anpassen */
  desktop[ROOT].ob_x      = desksize.g_x;
  desktop[ROOT].ob_y      = desksize.g_y;
  desktop[ROOT].ob_width  = desksize.g_w;
  desktop[ROOT].ob_height = desksize.g_h;

  /* Default-Objektbaum setzen (Desktop) */
  objc_draw(desktop,ROOT,MAX_DEPTH,
            desksize.g_x,desksize.g_y,
            desksize.g_w,desksize.g_h);
  wind_set(DESK,WF_NEWDESK,(long) desktop,0);

  /* Scrap-Pfad setzen */
  scrp_read(scrp_path);
  if (scrp_path[0] == 0)
    { std_scrap[0] = 'A' + (char) boot_dev();
      scrp_write(std_scrap);
    }

  /* hier kann die INF-Datei geladen werden! */
  /* Der Pfad wird mit shel_find ermittelt.  */

  /* MenÅ ausgeben */
  menu_bar(menu,1);

  /* Maus als Pfeil */
  graf_mouse(ARROW,0L);

  return(INIT_OK);
}


/******************************************************************************/
/* Abmeldung des Programms                                                    */
/* Aufgabe: MenÅ abmelden, Desktop zurÅcksetzen,                              */
/*          Resource-Speicher freigeben, Abmeldung beim AES                   */
/******************************************************************************/

static void exit_prg (int rc)

{

  if (rc == INIT_OK)
    { /* MenÅ abmelden */
      menu_bar(menu,0);

      /* Leerer Default-Objektbaum */
      wind_set(DESK,WF_NEWDESK,0L,0);

      /* Resource-Speicher freigeben */
      rsrc_free();
    }

  if ((rc == INIT_OK) || (rc == NO_RESOURCE))
    /* abmelden */
    appl_exit();
}


/******************************************************************************/
/* Objekt ausgeben                                                            */
/* Aufgabe: Objekt unter BerÅcksichtigung der Rechteckliste ausgeben          */
/******************************************************************************/

static void draw_objc (int handle, OBJECT *tree, int child)

{ int wi_gw1,wi_gw2,wi_gw3,wi_gw4;

  wind_update(BEG_UPDATE);                       /* Fenster wird erneuert     */

  /* Rechteckliste abarbeiten */
  wind_get(handle,WF_FIRSTXYWH,&wi_gw1,&wi_gw2,
                               &wi_gw3,&wi_gw4); /* erster Rechteck der Liste */
  while (wi_gw3 && wi_gw4)
    { objc_draw(tree,child,MAX_DEPTH,wi_gw1,
                        wi_gw2,wi_gw3,wi_gw4);   /* Objekt ausgeben           */
      wind_get(handle,WF_NEXTXYWH,&wi_gw1,
                      &wi_gw2,&wi_gw3,&wi_gw4);  /* nÑchstes Rechteck         */
    }

  wind_update(END_UPDATE);                       /* Erneuerung beendet        */
}


/******************************************************************************/
/* Clipping                                                                   */
/* Aufgabe: Clippt das Rechteck a unter BerÅcksichtigung von b                */
/******************************************************************************/

static void clip (GRECT *a, GRECT *b)

{ a->g_x = max(a->g_x,b->g_x);                     /* linke obere Ecke   */
  a->g_y = max(a->g_y,b->g_y);
  a->g_w = min(a->g_x + a->g_w, b->g_x + b->g_w);  /* rechte untere Ecke */
  a->g_h = min(a->g_y + a->g_h, b->g_y + b->g_h);

  a->g_w -= a->g_x;                                /* Breite */
  a->g_h -= a->g_y;                                /* Hîhe   */
}


/******************************************************************************/
/* Object ausgeben                                                            */
/* Aufgabe: Object auch unter BerÅcksichtigung von HIDETREE ausgeben          */
/******************************************************************************/

static void draw2_objc (int handle, OBJECT *tree, int child)

{ GRECT a, b;

  wind_update(BEG_UPDATE);                       /* Fenster erneuern          */

  /* Rechteckliste abarbeiten */
  wind_get(handle,WF_FIRSTXYWH,
           &a.g_x,&a.g_y,&a.g_w,&a.g_h);         /* erstes Rechteck der Liste */
  while (a.g_w && a.g_h)
    { objc_offset(tree,child,&b.g_x,&b.g_y);     /* Position des Objekts      */
      b.g_w = tree[child].ob_width;
      b.g_h = tree[child].ob_height;
      clip(&a,&b);                               /* Clipping                  */
      objc_draw(tree,ROOT,MAX_DEPTH,
                a.g_x,a.g_y,a.g_w,a.g_h);        /* Objekt ausgeben           */
      wind_get(handle,WF_NEXTXYWH,
               &a.g_x,&a.g_y,&a.g_w,&a.g_h);     /* nÑchstes Rechteck         */
    }

  wind_update(END_UPDATE);                       /* Erneuerung beendet        */

  /* In dieser Funktion kînnte auch form_dial(FMD_FINISH,...) Verwendung      */
  /*  finden.                                                                 */
}


/******************************************************************************/
/* Objekt bewegen                                                             */
/* Aufgabe: Objekt verstecken, bewegen und wieder darstellen                  */
/******************************************************************************/

static void move_objc (int handle, OBJECT *tree, int child)

{ int x,y,ox,oy,nx,ny;

  /* Objekt verstecken */
  tree[child].ob_flags |= HIDETREE;
  draw2_objc(handle,tree,child);

  /* Objekt child innerhalb des Objekts ROOT bewegen */
  objc_offset(tree,ROOT,&x,&y);               /* Offset berechnen             */
  objc_offset(tree,child,&ox,&oy);
  wind_update(BEG_UPDATE);                    /* Fenstererneuerung            */
  wind_update(BEG_MCTRL);                     /* Mauskontrolle                */
  graf_mouse(FLAT_HAND,0);                    /* Maus auf "flache Hand"       */
  graf_dragbox(tree[child].ob_width,  tree[child].ob_height, /* bewegen       */
               ox,                    oy,
               x,                     y,
               tree[ROOT].ob_width,   tree[ROOT].ob_height,
               &nx,                   &ny);
  graf_mouse(ARROW,0);                        /* Maus wieder Pfeil            */
  wind_update(END_MCTRL);                     /* keine Mauskontrolle          */
  wind_update(END_UPDATE);                    /* Erneuerung beendet           */
  tree[child].ob_x += nx - ox;                /* Verschub addieren            */
  tree[child].ob_y += ny - oy;

  /* Objekt darstellen */
  tree[child].ob_flags &= ~HIDETREE;
  draw_objc(handle,tree,child);
}


/******************************************************************************/
/* Information ausgeben                                                       */
/* Aufgabe: Dialogbox ausgeben                                                */
/******************************************************************************/

static void do_info (void)

{ GRECT a, b;
  int   ret;

  /* Position des MenÅ-Titels berechnen */
  objc_offset(menu,MNINFO,&b.g_x,&b.g_y);
  b.g_w = menu[MNINFO].ob_width;
  b.g_h = menu[MNINFO].ob_height;

  /* Vorbereitung */
  wind_update(BEG_UPDATE);                    /* Fenstererneuerung            */
  form_center(infodial,
              &a.g_x,&a.g_y,&a.g_w,&a.g_h);   /* Dialogbox zentrieren         */
  form_dial(FMD_START,
            a.g_x,a.g_y,a.g_w,a.g_h,
            a.g_x,a.g_y,a.g_w,a.g_h);         /* Hintergrund reservieren      */
  form_dial(FMD_GROW,
            b.g_x,b.g_y,b.g_w,b.g_h,
            a.g_x,a.g_y,a.g_w,a.g_h);         /* vergrîsserndes Rechteck      */
  objc_draw(infodial,ROOT,MAX_DEPTH,
            a.g_x,a.g_y,a.g_w,a.g_h);         /* Dialogbox ausgeben           */

  /* DurchfÅhrung */
  ret=form_do(infodial,0);                    /* Dialog durchfÅhren           */
  infodial[ret].ob_state &= ~SELECTED;        /* SELECTED zurÅcksetzen        */

  /* Nachbereitung */
  form_dial(FMD_SHRINK,
            b.g_x,b.g_y,b.g_w,b.g_h,
            a.g_x,a.g_y,a.g_w,a.g_h);         /* verkleinerndes Rechteck      */
  form_dial(FMD_FINISH,
            a.g_x,a.g_y,a.g_w,a.g_h,
            a.g_x,a.g_y,a.g_w,a.g_h);         /* Hintergrund freigeben        */
  wind_update(END_UPDATE);                    /* Erneuerung beendet           */

  /* Vorbereitung und Nachbereitung kînnen auch in eigene Routinen            */
  /* ausgelagert werden.                                                      */
}


/******************************************************************************/
/* MenÅ-Handler                                                               */
/* Aufgabe: Auswertung des ausgewÑhlten MenÅ-Eintrags                         */
/******************************************************************************/

static void hdle_menu (int title, int item)

{
  /* Welches Drop-Down-MenÅ? */
  switch (title)
    {
      /* Info-MenÅ? */
      case MNINFO  :
                     /* Hier gibt es nur einen Eintrag */
                     if (item == ITINFO)
                       do_info();

                     break;

      /* Datei-MenÅ? */
      case MNDATEI :
                     /* Welcher Eintrag? */
                     switch (item)
                       {
                         /* Datei neu anlegen? (nicht laden!) */
                         case ITNEU    : /* Eigene Routine... */
                                         form_alert(1,(char*) laden);
                                         break;

                         /* Datei îffnen? */
                         case ITOEFFNE : /* Eigene Routine... */
                                         form_alert(1,(char*) laden);
                                         break;

                         /* Datei sichern? */
                         case ITSICHER : /* Eigene Routine... */
                                         form_alert(1,(char*) speichern);
                                         break;

                         /* Datei unter neuem Namen sichern? */
                         case ITSICALS : /* Eigene Routine... */
                                         form_alert(1,(char*) speichern);
                                         break;

                         /* Ausgabe-Programm starten? */
                         case ITAUSGAB : /* Eigene Routine... */
                                         form_alert(1,(char*) ausgabe);
                                         break;

                         /* Programm-Ende? */
                         case ITENDE   : finish = 1;
                                         break;

                       }
    }
  menu_tnormal(menu,title,1);  /* Invertierung aufheben */
}


/******************************************************************************/
/* Maus-Handler                                                               */
/* Aufgabe: Auswertung des Mausklicks (linke Taste)                           */
/******************************************************************************/

static void hdle_mouse (int clicks, POINT *where)

{ int obj,
      dummy,
      but_state;

  /* Welches Object? */
  obj = objc_find(desktop,ROOT,MAX_DEPTH,where->x,where->y);

  /* Doppelklick? */
  if (clicks == 2)
    {
      /* Welches Objekt? */
      switch (obj)
        { case BSPICON : /* invers darstellen */
                         if (!(SELECTED & desktop[obj].ob_state))
                           { desktop[obj].ob_state |= SELECTED;
                             draw_objc(DESK,desktop,obj);
                           }

                         /* Hier kînnen eigene Routinen */
                         /* aufgerufen werden...        */
                         form_alert(1,(char*) aktion);

                         /* normal darstellen */
                         desktop[obj].ob_state &= ~SELECTED;
                         draw_objc(DESK,desktop,obj);
                         /* Es kînnte auch objc_change benutzt werden! */

                         break;

          /* Platz fÅr weitere Auwertungen und Icons... */

        }
    }

  /* Einfachklick? */
  else if (clicks == 1)
    {
      /* Status der Maustasten abfragen */
      graf_mkstate(&dummy,&dummy,&but_state,&dummy);

      /* linke Maustaste festgehalten? */
      if (but_state & 0x01)
        {
          /* Welches Object? */
          switch (obj)
            {
              /* Objekt bewegen */
              case BSPICON : move_objc(DESK,desktop,obj);
                             break;

              /* FÅr weitere Icons... */

            }
        }

      /* einfach geklickt? */
      else
        {
          /* Welches Object? */
          switch (obj)
            {
              /* Objekt invertieren */
              case BSPICON : if (!(SELECTED & desktop[obj].ob_state))
                               { desktop[obj].ob_state |= SELECTED;
                                 draw_objc(DESK,desktop,obj);
                               }
                             break;

              /* Platz fÅr weitere Aktionen... */

              /* Invertierungen aufheben */
              default      : if (SELECTED & desktop[BSPICON].ob_state)
                               { desktop[BSPICON].ob_state &= ~SELECTED;
                                 draw_objc(DESK,desktop,BSPICON);
                               }
                             break;

            }

        }
    }
}


/******************************************************************************/
/* Key-Handler                                                                */
/* Aufgabe: Auswertung des Tastendrucks                                       */
/******************************************************************************/

static void hdle_key (int key, int special_key)

{
  /* Control gedrÅckt? */
  if (K_CTRL & special_key)

    {
      /* Welche Taste? */
      switch(key >> 8)    /* Scancode in den oberen 8 Bit */
        {
          /* N gedrÅckt? */
          case K_N : menu_tnormal(menu,MNDATEI,0); /* Titel invertieren       */

                     /* Eigene Routine... */
                     form_alert(1,(char*) laden);

                     menu_tnormal(menu,MNDATEI,1); /* Titel normal darstellen */

                     break;

          /* O gedrÅckt? */
          case K_O : menu_tnormal(menu,MNDATEI,0); /* Titel invertieren       */

                     /* Eigene Routine... */
                     form_alert(1,(char*) laden);

                     menu_tnormal(menu,MNDATEI,1); /* Titel normal darstellen */

                     break;

          /* S gedrÅckt? */
          case K_S : menu_tnormal(menu,MNDATEI,0); /* Titel invertieren       */

                     /* Eigene Routine... */
                     form_alert(1,(char*) speichern);

                     menu_tnormal(menu,MNDATEI,1); /* Titel normal darstellen */

                     break;

          /* A gedrÅckt? */
          case K_A : menu_tnormal(menu,MNDATEI,0); /* Titel invertieren       */

                     /* Eigene Routine... */
                     form_alert(1,(char*) speichern);

                     menu_tnormal(menu,MNDATEI,1); /* Titel normal darstellen */

                     break;

          /* Q gedrÅckt? */
          case K_Q : finish = 1;
                     break;
        }
    }
}


/******************************************************************************/
/* Hauptprogramm                                                              */
/* Aufgabe: Initialisierung, Auswertung der Events, Abmeldung                 */
/******************************************************************************/

int main (void)

{ int     events,            /* fÅr Multi-Event     */
          mouse_button,      /*        "            */
          sp_key,key,clicks, /*        "            */
          msg_buffer[8];     /*        "            */
  POINT   mouse_pos;         /*        "            */
  int     ret_code;          /* aus Initialisierung */

  if ((ret_code = init_prg()) == INIT_OK)

    { while (!finish)

        { events=evnt_multi(
                            /* Message-, Maustasten- und Tastatatur-Ereignis  */
                            MU_MESAG|MU_BUTTON|MU_KEYBD,

                            /* Doppelklick und linke Maustaste */
                            0x02,0x01,0x01,

                            /* Keine öberwachung von Rechtecken */
                            0,0,0,0,0,0,0,0,0,0,

                            /* Message-Buffer */
                            msg_buffer,

                            /* Kein Timer */
                            0,0,

                            /* Maus-Position und -Taste */
                            &mouse_pos.x,&mouse_pos.y,&mouse_button,

                            /* Sondertaste und Taste */
                            &sp_key,&key,

                            /* Anzahl der Mausklicks */
                            &clicks);

          /* Message-Event? */
          if (events & MU_MESAG)

            { switch (msg_buffer[0])
                {
                  /* MenÅ angeklickt? */
                  case MN_SELECTED : hdle_menu(msg_buffer[3],msg_buffer[4]);
                                     break;

                  /* Platz fÅr weitere Message-Auswertungen...   */
                  /* Z.B. fÅr Fenster: WM_REDRAW, WM_TOPPED, ... */

                }
            }

          else

            {
              /* Maus-Button-Event? */
              if (events & MU_BUTTON)

                hdle_mouse(clicks,&mouse_pos);

              /* Tastatur-Event? */
              if (events & MU_KEYBD)

                hdle_key(key,sp_key);

            }
        }
    }

  else
    form_alert(1,no_init); /* Fehlermeldung */

 exit_prg(ret_code);

 return(0);
}


/******************************************************************************/

