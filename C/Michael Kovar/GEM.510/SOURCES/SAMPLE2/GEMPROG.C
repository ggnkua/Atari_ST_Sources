/*--------------------------------------------------------*/
/*                 G E M P R O G . C                      */
/*           ------------------------------               */
/*                                                        */
/*      Beispielprogramm zum GEM-Manager                  */
/*                                                        */
/*                                                        */
/*      Version 1.00    vom 29.11.1992                    */
/*                                                        */
/*      entwickelt auf ATARI TT030                        */
/*                 mit Mark Williams C  Version 3.09      */
/*                                                        */
/*      (c) 1992  by Volker Nawrath                       */
/*--------------------------------------------------------*/


/* Include-Dateien
 * --------------- */
#include  <gemprog.h>    /* Resource-Datei */
#include  <gemprog1.h>   /* Definitionen fÅr das Beispielprogramm */
#include  <aesbind.h>
#include  <event.h>
#include  <gemdefs.h>
#include  <gemsys.h>
#include  <obdefs.h>
#include  <osbind.h>
#include  <stdio.h>
#include  <vdibind.h>
#include  <window.h>


/* Strings 
 * -------*/
char rsc_name[]    = "GEMPROG.RSC";
char std_scrap[]   = "x:\\CLIPBRD";
/* hier auch Parameter-Datei angeben! */
/*  Format  : <Programm-Name>.INF     */
/*  Beispiel: GEMPROG.INF             */


/* Prototypen - GEM-Manager
 * ------------------------ */
extern    int  clip();
extern    int  do_movedial();
extern    void draw_deskobjc();
extern    int  gem_exit();
extern    int  gem_init();
extern    int  handle_to_index();
extern    void handle_window();
extern    void init_buttons();
extern    int  menu_search();
extern    void move_deskobjc();
extern    void neupix();
extern    int  open_window();
extern    int  popup_menu();
extern    void v_evntinit();
extern    void v_event();
extern    void wind_info_set();
extern    void win_exit();
extern    void win_init();
extern    int  wm_call();

/* Prototypen - Programm
 * --------------------- */
static    int  init_prg();
static    void exit_prg();
static    void hdle_key();
static    void hdle_menu();
static    void hdle_mouse();
extern    void buchstabe();
extern    void change_infotext();
extern    void crsrposition();
extern    void icon_dclick();
extern    void fenster_init();
extern    void systeminfo();
extern    int  umwandlung();
extern    void zahl();


/* Variablen - GEM-Manager
 * ---------------------- */
int            ap_id,vdi_handle,work_in[12],work_out[57],contrl[12];
int            intin[128],ptsin[128],intout[128],ptsout[128],global[15];
EVNT           event;
EVNT_RETURN    event_return;
WIND_DATA      *windows;
ACT            aktuell,before;


/* Variablen - Programm
 * -------------------- */
extern    int  Prog_End;
extern    EXT  fenster[10];
OBJECT    *menu,              /* MenÅ                            */
          *desktop,           /* Desktop                         */
          *infodial,          /* Dialogbox                       */
          *fechoice,          /* Dialogbox zur Fensternr.Eingabe */
          *buttdial,          /* Dialogbox fÅr Icon-Doppelklick  */
          *sysdial,           /* Dialogbox fÅr Systeminfo        */
          *infozeil,          /* Dialogbox                       */
          *tree08,            /* Fensterbox                      */
          *aktion,            /* Alert-Boxen                     */
          *laden,             /*        "                        */
          *speichern,         /*        "                        */
          *ausgabe;           /*        "                        */
GRECT     desksize;           /* Desk-Grîsse                     */


/* ########################################################################
 * Anmeldung des Programms
 * Aufgabe: Anmeldung beim AES, laden und auswerten der Resource-Datei,
 *          Scrap-Pfad setzen, MenÅ ausgeben, Desktop setzen,
 *          Mauszeiger auf Pfeil setzen
 * ######################################################################## */

static    int  init_prg ()
{
     int       fehler;
     OBJECT    *trees[99];
/*   char      scrp_path[MAXSTRING]; */

     /* Programm beim anmelden
      * ---------------------- */
     fehler = gem_init();
     if (fehler == -1)
          return(NO_INIT);
     
     /* Maus als Biene/Sanduhr
      * ---------------------- */
     graf_mouse(HOURGLASS,0L);
     dial_init("GEMPROG");    /* FÅr Fensterdialoge */
     wind_update(BEG_UPDATE);
     
     /* Resource-Datei laden
      * -------------------- */
     if (!rsrc_load(rsc_name))
          return(NO_RESOURCE);
     /* !!! Accessories, die unter GEM 2.x laufen sollen,
      * !!! dÅrfen keine Resource-Dateien laden */

     /* Anfangsadressen ermitteln
      * ------------------------- */
     rsrc_gaddr(R_TREE  ,MENUE   ,&menu);         /* MenÅ        */
     rsrc_gaddr(R_TREE  ,DESKTOP ,&desktop);      /* Desktop     */
     rsrc_gaddr(R_TREE  ,INFODIAL,&infodial);     /* Dialog      */
     rsrc_gaddr(R_TREE  ,FECHOICE,&fechoice);     /* Dialog      */
     rsrc_gaddr(R_TREE  ,BUTTDIAL,&buttdial);     /* Dialog      */
     rsrc_gaddr(R_TREE  ,SYSDIAL ,&sysdial);      /* Dialog      */
     rsrc_gaddr(R_TREE  ,INFOZEIL,&infozeil);     /* Dialog      */
     rsrc_gaddr(R_TREE  ,TREE08  ,&tree08);       /* Dialog      */
     rsrc_gaddr(R_STRING,DOPPEL  ,&aktion);       /* Alert-Boxen */
     rsrc_gaddr(R_STRING,LADEN   ,&laden);
     rsrc_gaddr(R_STRING,SPEICHER,&speichern);
     rsrc_gaddr(R_STRING,AUSGABE ,&ausgabe);

     /* Dialogboxen durch Button-Manager anpassen
      * ----------------------------------------- */
     trees[0] = fechoice;
     trees[1] = infodial;
     trees[2] = buttdial;
     trees[3] = sysdial;
     trees[4] = infozeil;
     trees[5] = NULL;
     init_buttons(trees);
     
     /* Grîsse des Desktops ermitteln und Object-Struktur anpassen
      * ---------------------------------------------------------- */
     wind_get(DESK,WF_WORKXYWH,
              &desksize.g_x,&desksize.g_y,
              &desksize.g_w,&desksize.g_h);
     desktop[ROOT].ob_x      = desksize.g_x;
     desktop[ROOT].ob_y      = desksize.g_y;
     desktop[ROOT].ob_width  = desksize.g_w;
     desktop[ROOT].ob_height = desksize.g_h;

     /* Default-Objektbaum setzen (Desktop)
      * ----------------------------------- */
     objc_draw(desktop,ROOT,MAX_DEPTH,
               desksize.g_x,desksize.g_y,
               desksize.g_w,desksize.g_h);
     wind_set(DESK,WF_NEWDESK,desktop,ROOT);

     /* Scrap-Pfad setzen
       scrp_read(scrp_path);
       if (scrp_path[0] == 0)
         { std_scrap[0] = 'A' + (char) boot_dev();
           scrp_write(std_scrap);
         }
     */

     /* hier kann die INF-Datei geladen werden! */
     /* Der Pfad wird mit shel_find ermittelt.  */

     /* MenÅ ausgeben und einige MenÅtitel inaktivieren
      * ----------------------------------------------- */
     menu_ienable(menu,FEAKTCLO,0);
     menu_ienable(menu,FEAKTDEL,0);
     menu_bar(menu,1);
     
     wind_update(END_UPDATE);

     /* Maus als Pfeil
      * -------------- */
     graf_mouse(ARROW,0L);

     return(INIT_OK);

} /* ENDE: init_prg() */


/* ##################################################################
 * Abmeldung des Programms
 * Aufgabe: MenÅ abmelden, Desktop zurÅcksetzen,
 *          Resource-Speicher freigeben
 * ################################################################## */

static    void exit_prg()
{
     /* MenÅ abmelden
      * ------------- */
     menu_bar(menu,0);

     /* Leerer Default-Objektbaum
      * ------------------------- */
     wind_set(DESK,WF_NEWDESK,0L,0);

     /* Resource-Speicher freigeben
      * --------------------------- */
     rsrc_free();

} /* ENDE: exit_prg() */


/* ####################################################################
 * Tastatur-Handler
 * Aufgabe: Auswertung der gedrÅckten Tastenkombination
 * #################################################################### */

static    void hdle_key()
{
     /* Hier wird nur die Funktionsgruppe der gedrÅckten Taste
      * ermittelt. Da alle Tastenfunktionen nur Fenster betreffen,
      * befinden sich die weiteren Auswertungsfunktionen in der
      * Datei mit den Modulen zur Fensterbearbeitung
      * ---------------------------------------------------------- */
     if (event_return.fl_crsrpos)
          crsrposition();
     else if(event_return.fl_alpha)
          buchstabe();
     else if(event_return.fl_num)
          zahl();

} /* ENDE: hdle_key() */


/* ####################################################################
 * MenÅ-Handler
 * Aufgabe: Auswertung des ausgewÑhlten MenÅ-Eintrags
 * #################################################################### */

static    void hdle_menu(title,item)
          int  title,item;
{
     int  button,dialtype,fensternr,i;
     char numtext[2];
     
     /* PrÅfen, welches Drop-Down-MenÅ ausgewÑhlt wurde
      * ----------------------------------------------- */
     switch (title)
     {
          case MNINFO:
          {
               /* MenÅeintrag zum Copyright bzw. zur Infobox
                * ------------------------------------------ */
               if (item == ITINFO)
               {
                    dialtype = (vor_dial(infodial,1) == 0L) ? 0 : 1;
                    if (dialtype == 0)
                    {
                         draw_dial(infodial,dialtype);
                         button = exform_do(infodial,0) & 0x7fff;
                         undo_objc(infodial,button,SELECTED);
                    }
                    else
                    {
                         button = do_movedial(infodial,INFODRAG,CHNUMMER);
                    }

                    nach_dial(infodial,1);
               }
               break;
          }


          case MNDATEI:
          {
               /* MenÅtitel zu Datei
                * ------------------ */
               switch (item)
               {
                    case ITNEU:
                    {
                         /* Datei neu anlegen (nicht laden!)
                          * -------------------------------- */
                         form_alert(1,(char*) laden);
                         break;
                    }

                    case ITOEFFNE:
                    {
                         /* Datei îffnen
                          * ------------ */
                         form_alert(1,(char*) laden);
                         break;
                    }

                    case ITSICHER:
                    {
                         /* Datei sichern
                          * ------------- */
                         form_alert(1,(char*) speichern);
                         break;
                    }

                    case ITSICALS:
                    {
                         /* Datei unter neuem Namen sichern
                          * ------------------------------- */
                         form_alert(1,(char*) speichern);
                         break;
                    }

                    case ITAUSGAB:
                    {
                         /* Ausgabe-Programm starten
                          * ------------------------ */
                         form_alert(1,(char*) ausgabe);
                         break;
                    }

                    case ITENDE:
                    {
                         /* Programm-Ende
                          * ------------- */
                         Prog_End = TRUE;
                         break;
                    }
               }
               
               break;
               
          } /* ENDE: MenÅtitel MNDATEI */
          
          case FENSTER:
          {
               if(item == FDIALOG)
               {
                    /* Zeichnet eine Box im Fenster
                     * ---------------------------- */
                    wbox_draw(tree08);
                    break;
               }


               if ((item == FEAKTCLO) || (item == FEAKTDEL))
               {
                    /* Aktionen am aktuellen Fenster durchfÅhren
                     * ----------------------------------------- */
                    fensternr = -1;
                    for (i=1;i<=9;i++)
                    {
                         if (fenster[i].w_index ==
                              handle_to_index(aktuell.handle))
                         {
                              fensternr = i;
                              break;
                         }
                    }
                    
                    if (fensternr != -1)
                    {
                         switch (item)
                         {
                              case FEAKTCLO:
                              {
                                   /* aktuelles Fenster schlieûen
                                    * --------------------------- */
                                   fenster_aktion(fensternr,3);
                                   break;
                              }
                              case FEAKTDEL:
                              {
                                   /* aktuelles Fenster lîschen
                                    * ------------------------- */
                                   fenster_aktion(fensternr,4);
                                   break;
                              }
                         }
                    }
               }
               else
               {
                    /* Aktionen an einem vom Benutzer zu
                     * bestimmenden Fenster
                     * --------------------------------- */
                    button = do_movedial(fechoice,FEDRAG,CHNUMMER);

                    if (button==CHOKAY)
                    {
                         /* Fensternummer wurde eingegeben
                          * ------------------------------ */
                         get_dialogtext(fechoice,CHNUMMER,numtext);
                         fensternr = umwandlung(numtext);
                         
                         switch (item)
                         {
                              case FENEU:
                              {
                                   /* Neues Fenster anlegen + îffnen
                                    * ------------------------------ */
                                   fenster_aktion(fensternr,1);
                                   break;
                              }
                              case FEOEFFNE:
                              {
                                   /* Fenster îffnen
                                    * -------------- */
                                   fenster_aktion(fensternr,2);
                                   break;
                              }
                              case FETOPPEN:
                              {
                                   /* Fenster nach oben holen
                                    * ----------------------- */
                                   fenster_aktion(fensternr,5);
                                   break;
                              }
                         }
                    }
                    else
                    {
                         /* Abbruch des Dialoges
                          * -------------------- */
                         undo_objc(fechoice,CHABBRUC,SELECTED);
                    }
               }
          
               break;

          } /* ENDE: case fenster */
          
          case SYSTEM:
          {
               if (item == SYSINFO)
               {
                    systeminfo();
               }
               
               break;
               
          } /* ENDE: case SYSTEM */
          
     }
     /* Invertierung aufheben
      * --------------------- */
     menu_tnormal(menu,title,1);
}


/* ####################################################################
 * Maus-Handler
 * Aufgabe: Auswertung des Mausklicks (linke Taste)
 * #################################################################### */

static    void hdle_mouse(clicks,taste,x,y)
          int       clicks,taste,x,y;
{
     int  obj,dummy,but_state,choice;
     char popup_text[255],alert[255],help[255];
     
     /* Welches Object?
      * --------------- */
     obj = objc_find(desktop,ROOT,MAX_DEPTH,x,y);

     /* Doppelklick linke Maustaste?
      * ---------------------------- */
     if ((clicks == 2) && (taste == 1))
     {
          /* Aktionen je nach ausgewÑhltem Objekt durchfÅhren
           * ------------------------------------------------ */
          switch (obj)
          {
               case BSPICON:
               {
                    /* invers darstellen
                     * ----------------- */
                    if (!(SELECTED & desktop[obj].ob_state))
                    {
                         /* Nach dem setzen des Flags wird Objekt
                          * Åber Rechtecksliste neu ausgegeben
                          * ------------------------------------- */
                         desktop[obj].ob_state |= SELECTED;
                         draw_deskobjc(desktop,obj);
                    }

                    /* Icon-Aktion bei Doppelklick aufrufen
                     * ------------------------------------ */
                    icon_dclick();

                    /* Nach dem Lîschen des Flags SELECTED wird
                     * Objekt Åber Rechtecksliste neu ausgegeben
                     * ----------------------------------------- */
                    desktop[obj].ob_state &= ~SELECTED;
                    draw_deskobjc(desktop,obj);

                    break;
               }

          /* Platz fÅr weitere Auwertungen und Icons... */
          }

     } /* ENDE: Aktion bei Doppelklick */

     /* Einfachklick linke Maustaste?
      * ----------------------------- */
     else if ((clicks == 1) && (taste == 1))
     {
          /* Status der Maustasten abfragen
           * ------------------------------ */
          graf_mkstate(&dummy,&dummy,&but_state,&dummy);

          /* linke Maustaste festgehalten?
           * ----------------------------- */
          if (but_state & 0x01)
          {
               /* Welches Object soll bewegt werden?
                * ---------------------------------- */
               switch (obj)
               {
                    case BSPICON :
                    {
                         move_deskobjc(desktop,obj);
                         break;
                    }
                    
                    /* FÅr weitere Icons... */
               }
          }

          /* linke Maustaste losgelassen */
          else
          {
               /* Welches Object soll invertiert werden?
                * -------------------------------------- */
               switch (obj)
               {
                    case BSPICON:
                    {
                         if (!(SELECTED & desktop[obj].ob_state))
                         {
                              /* Nach dem setzen des Flags wird Objekt
                               * Åber Rechtecksliste neu ausgegeben
                               * ------------------------------------- */
                              desktop[obj].ob_state |= SELECTED;
                              draw_deskobjc(desktop,obj);
                         }
                         break;
                    }
                    
                    /* Platz fÅr weitere Aktionen... */

                    /* Invertierungen aufheben
                     * ----------------------- */
                    default:
                    {
                         if (SELECTED & desktop[BSPICON].ob_state)
                         {
                              /* Nach dem Lîschen des Flags SELECTED
                               * wird Objekt Åber Rechtecksliste
                               * neu ausgegeben
                               * ----------------------------------- */
                              desktop[BSPICON].ob_state &= ~SELECTED;
                              draw_deskobjc(desktop,BSPICON);
                         }
                         break;
                    }
               }

          } /* ENDE: Statusabfrage der Maustaste */
     }
     
     /* Einfachklick rechte Maustaste?
      * ------------------------------ */
     else if ((clicks == 1) && (taste == 2))
     {
          /* Popup-MenÅ aufrufen
           * ------------------- */
          strcpy(popup_text,"POPUP-MENU|");
          strcat(popup_text,"  Infozeile Ñndern ... |");
          strcat(popup_text,"------------------------|");
          strcat(popup_text,"  Systeminfo ...       |");
          strcat(popup_text,"  Hilfestellung ...    |");
          strcat(popup_text,"------------------------|");
          strcat(popup_text,"  Programm verlassen   ");
          choice = popup_menu(x,y,1,popup_text);

          /* Auswerten, welcher Eintrag ausgewÑhlt wurde
           * ------------------------------------------- */
          switch (choice)
          {
               case 1:
               {
                    /* Text zur Infozeile eines Fensters Ñndern
                     * ---------------------------------------- */
                    change_infotext();
                    break;
               }
               case 3:
               {
                    /* Systeminfo zeigen
                     * ----------------- */
                    systeminfo();
                    break;
               }
               case 4:
               {
                    /* Hilfestellung
                     * ------------- */
                    strcpy(help,"HILFESTELLUNG:|");
                    strcat(help,"Insert       = Volle/norm. Gr.|");
                    strcat(help,"u/j/n/h      = Fenster bewegen|");
                    strcat(help,"Shift u/j/n/h= Fenster bewegen|");
                    strcat(help,"Ctrl u/j/n/h = Fenstergrîûe");
                    sprintf(alert,"[1][%s][OK]",help);
                    form_alert(1,alert);
                    break;
               }
               case 6:
               {
                    /* Programm beenden
                     * ---------------- */
                    Prog_End = TRUE;
                    break;
               }
          } /* ENDE: Auswertung des Popup-MenÅs */

     } /* ENDE: Abfrage der Anzahl Mausklicks */

} /* ENDE: hdle_mouse() */


/* ##########################################################
 * Hauptprogramm
 * Aufgabe: Initialisierung, Auswertung der Events, Abmeldung
 * ########################################################## */

int main()
{
     int       ret_code;           /* Allgemeines Feld fÅr RÅckgabewerte */
     char      t[200],alert[200];
     int       fnr;
     unsigned long adr;
     OBJECT    *tree;

     if ((ret_code = init_prg()) == INIT_OK)
     {
          /* Window-Manager initialisieren
           * ----------------------------- */
          win_init(7);
          
          /* Event-Manager initialisieren
           * ---------------------------- */
          v_evntinit(0);
          v_evntinit(1);
          event.event  = (MU_MESAG|MU_BUTTON|MU_KEYBD);
          event.clicks = 258;
          event.state  = 0;
          event.button = 3;

          /* Programminterne Initialisierung der Fensterdaten
           * ------------------------------------------------ */
          fenster_init();
          
          do
          {
               v_event();
               
               if (wexform_do() == 2)
                    continue;

               if (EVNT_MESAG())
               {
                    /* Nachricht auswerten
                     * ------------------- */
                    switch (event_return.buffer[0])
                    {
                         case MSG_DIALOG:
                         {
                              /* Fensterdialog schlieûen */
                              fnr = handle_to_index(event_return.buffer[3]);
                              adr = (unsigned long)(event_return.buffer[4]);
                              adr = (adr << 16) + event_return.buffer[5];
                              tree = (OBJECT *)(adr);
                              wbox_undraw(fnr);
                              undo_objc(tree, event_return.buffer[6],
                               SELECTED); 
                              break;
                         }

                         case MN_SELECTED:
                         {
                              /* MenÅ wurde angewÑhlt
                               * -------------------- */
                              hdle_menu(event_return.buffer[3],
                                        event_return.buffer[4]);
                              break;
                         }
                         
                         default:
                         {
                              /* PrÅfen, ob Meldung Fenster betrifft
                               * ----------------------------------- */
                              handle_window(event_return.buffer);
                         }
                         
                         /* Platz fÅr weitere Message-Auswertungen
                          * -------------------------------------- */
                    }
               }
               
               if (EVNT_BUTTON())
               {
                    /* Mausknopfereignis
                     * ----------------- */
                    hdle_mouse(event_return.times,
                               event_return.mouse_b,
                               event_return.mouse_x,
                               event_return.mouse_y);
               }
               
               if (EVNT_KEYBD())
               {
                    /* Tastaturereignis; Zuerst muû geprÅft werden, ob
                     * ein MenÅeintrag selektiert wurde
                     * ----------------------------------------------- */
                    ret_code = menu_search(ap_id,menu,
                                             event_return.mouse_k,
                                             event_return.key     );
                    if (!ret_code)
                    {
                         /* Kein MenÅeintrag selectiert, Taste auswerten
                          * -------------------------------------------- */
                         hdle_key();
                    }
               }
          } while(!Prog_End);

     } /* ENDE: Programmschleife */

     else
     {
          /* Schwerer Fehler beim Programmstart
           * ---------------------------------- */
          if (ret_code==NO_INIT)
          {
               strcpy(t,"!!!!!  Schwerer Fehler  !!!!!|");
               strcat(t,"-----------------------------|");
               strcat(t," Das AES konnte Applikation  |");
               strcat(t," nicht anmelden =>  Abbruch  ");
          }
          else if (ret_code==NO_RESOURCE)
          {
               strcpy(t,"!!!!!  Schwerer Fehler  !!!!!|");
               strcat(t,"-----------------------------|");
               strcat(t,"Resource-Datei nicht gefunden|");
          }
          sprintf(alert,"[1][%s][Abbruch]",t);
          form_alert(1,alert);
          exit(1);
     }
     
     win_exit();
     exit_prg();
     gem_exit();

} /* ENDE: main() */

