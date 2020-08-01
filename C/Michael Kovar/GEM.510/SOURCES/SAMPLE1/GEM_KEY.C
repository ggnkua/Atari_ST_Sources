/*--------------------------------------------------------*/
/*                 G E M _ K E Y  . C                     */
/*           ------------------------------               */
/*                                                        */
/*      Beispielprogramm zum GEM-Manager                  */
/*                                                        */
/*      Modul fÅr die Auswertung der Tastaturereignisse,  */
/*      um Fenster zu îffnen, schlieûen und manipulieren  */
/*                                                        */
/*      Version 1.00    vom 04.10.1992                    */
/*                                                        */
/*      entwickelt auf ATARI TT030                        */
/*                 mit Mark Williams C  Version 3.09      */
/*                                                        */
/*      (c) 1992  by Volker Nawrath                       */
/*--------------------------------------------------------*/

#include  <aesbind.h>
#include  <event.h>
#include  <gemprog1.h>
#include  <gemsys.h>
#include  <obdefs.h>
#include  <osbind.h>
#include  <vdibind.h>
#include  <window.h>

/* Prototypen - GEM-Manager
 * ------------------------ */
extern    int  do_movedial();
extern    int  get_dialogtext();
extern    void handle_window();
extern    int  handle_to_index();
extern    void put_dialogtext();
extern    int  wind_info_set();
extern    int  wm_call();
extern    void v_evntinit();
extern    void v_event();

/* VorwÑrtsdefinition von Funktionen
 * --------------------------------- */
void buchstabe();
void crsrposition();
void fehler_ausgabe();
void fkttaste();
void zahl();
extern    void afterfkt();
extern    void fenster_anlegen();
extern    void xywh_calc();


/* Felder - GEM-Manager
 * -------------------- */
extern    int            ap_id,vdi_handle,work_in[12],work_out[57];
extern    int            contrl[12],intin[128],ptsin[128],intout[128];
extern    int            ptsout[128],global[15];
extern    WIND_DATA      *windows;
extern    ACT            aktuell,before;
extern    EVNT           event;
extern    EVNT_RETURN    event_return;


/* Felder - Programm
 * ----------------- */
extern    EXT  fenster[10];



/* ###################################################
 * Cursortasten
 * Aufgabe: Cursortasten auswerten und Fensteraktionen
 * ################################################### */

void crsrposition()
{
     int  fehler,param[5],w_index,i;
     long lparam[4];

     w_index = handle_to_index(aktuell.handle);

     switch(event_return.high_key)
     {
          case KC_crsrup:
          {
               if (EVNT_CTRL())
               {
                    /* 1 Seite nach oben
                     * ----------------- */
                    fehler = wm_call(WM_SUP,param,lparam);
                    fehler_ausgabe(fehler);
               }
               else
               {
                    /* 1 Zeile nach oben
                     * ----------------- */
                    fehler = wm_call(WM_LUP,param,lparam);
                    fehler_ausgabe(fehler);
               }
               break;
          }
          case KC_crsrdown:
          {
               if (EVNT_CTRL())
               {
                    /* 1 Seite nach unten
                     * ------------------ */
                    fehler = wm_call(WM_SDOWN,param,lparam);
                    fehler_ausgabe(fehler);
               }
               else
               {
                    /* 1 Zeile nach unten
                     * ------------------ */
                    fehler = wm_call(WM_LDOWN,param,lparam);
                    fehler_ausgabe(fehler);
               }
               break;
          }
          case KC_crsrleft:
          {
               /* 1 Spalte nach links
                * ------------------- */
               fehler = wm_call(WM_LLEFT,param,lparam);
               fehler_ausgabe(fehler);
               break;
          }
          case KCT_crsrleft:
          {
               /* 1 Seite nach links
                * ------------------ */
               fehler = wm_call(WM_SLEFT,param,lparam);
               fehler_ausgabe(fehler);
               break;
          }
          case KC_crsrright:
          {
               /* 1 Spalte nach rechts
                * -------------------- */
               fehler = wm_call(WM_LRIGHT,param,lparam);
               fehler_ausgabe(fehler);
               break;
          }
          case KCT_crsrright:
          {
               /* 1 Seite nach links
                * ------------------ */
               fehler = wm_call(WM_SRIGHT,param,lparam);
               fehler_ausgabe(fehler);
               break;
          }
          case KC_home:
          {
               if (EVNT_LSHIFT() ||
                   EVNT_RSHIFT()   )
               {
                    /* Text auf letzte Zeile/Spalte positionieren
                     * ------------------------------------------ */
                    lparam[0] = windows[w_index].doc_width;
                    lparam[1] = windows[w_index].doc_length;
                    fehler = wm_call(WM_TEXT,param,lparam);
                    fehler_ausgabe(fehler);
               }
               else
               {
                    /* Text auf erste Zeile/Spalte positionieren
                     * ----------------------------------------- */
                    lparam[0] = 0;
                    lparam[1] = 0;
                    fehler = wm_call(WM_TEXT,param,lparam);
                    fehler_ausgabe(fehler);
               }
               break;
          }
          case KC_insert:
          {
               /* Fenster auf volle bzw. ursprÅngliche Grîûe
                * ------------------------------------------ */
               fehler = wm_call(WM_FULL,param,lparam);
               fehler_ausgabe(fehler);
               break;
          }
          case KX_undo:
          {
               /* Arbeitsbereich eines Fensters lîschen
                * ------------------------------------- */
               w_index = -1;
               for(i=1;i<=9;i++)
               {
                    if ((fenster[i].w_index != -1) &&
                        (fenster[i].offen))
                    {
                         if (fenster[i].w_index !=
                              handle_to_index(aktuell.handle))
                         {
                              w_index = fenster[i].w_index;
                              break;
                         }
                    }
               }
               if ((w_index == -1) && (aktuell.handle >= 1))
                    w_index = handle_to_index(aktuell.handle);
               
               if (w_index != -1)
               {
                    param[0] = w_index;
                    fehler = wm_call(WM_CLEAR,param,lparam);
                    fehler_ausgabe(fehler);
               }
          }
          
     } /* ENDE switch (event_return.high_key) */
}



/* ##################################################################
 * Normale Tasten
 * Aufgabe: Normale Tasten (Buchstaben) auswerten und Fensteraktionen
 * ################################################################## */

void buchstabe()
{
     int  fehler,param[5],w_index;
     long lparam[4];

     w_index = handle_to_index(aktuell.handle);

     switch (event_return.high_key)
     {
     case K_u:
     {
          if (EVNT_LSHIFT() || EVNT_RSHIFT())
          {
               /* Fenster um 10 Pixel nach oben bewegen
                * ------------------------------------- */
               param[1] = windows[w_index].allpix.g_x;
               param[2] = windows[w_index].allpix.g_y-10;
               fehler = wm_call(WM_POS,param,lparam);
               fehler_ausgabe(fehler);
          }
          else if (EVNT_CTRL())
          {
               /* Fensterhîhe um 5 Pixel verkleinern
                * ---------------------------------- */
               param[1] = windows[w_index].allpix.g_w;
               param[2] = windows[w_index].allpix.g_h-5;
               fehler = wm_call(WM_SIZE,param,lparam);
               fehler_ausgabe(fehler);
          }
          else
          {
               /* Fenster um 20 Pixel nach oben bewegen
                * ------------------------------------- */
               param[1] = windows[w_index].allpix.g_x;
               param[2] = windows[w_index].allpix.g_y-20;
               fehler = wm_call(WM_POS,param,lparam);
               fehler_ausgabe(fehler);
          }
          break;
     }

     case K_n:
     {
          if (EVNT_LSHIFT() || EVNT_RSHIFT())
          {
               /* Fenster um 10 Pixel nach unten bewegen
                * -------------------------------------- */
               param[1] = windows[w_index].allpix.g_x;
               param[2] = windows[w_index].allpix.g_y+10;
               fehler = wm_call(WM_POS,param,lparam);
               fehler_ausgabe(fehler);
          }
          else if (EVNT_CTRL())
          {
               /* Fensterhîhe um 5 Pixel vergrîûern
                * --------------------------------- */
               param[1] = windows[w_index].allpix.g_w;
               param[2] = windows[w_index].allpix.g_h+5;
               fehler = wm_call(WM_SIZE,param,lparam);
               fehler_ausgabe(fehler);
          }
          else
          {
               /* Fenster um 20 Pixel nach unten bewegen
                * -------------------------------------- */
               param[1] = windows[w_index].allpix.g_x;
               param[2] = windows[w_index].allpix.g_y+20;
               fehler = wm_call(WM_POS,param,lparam);
               fehler_ausgabe(fehler);
          }
          break;
     }

     case K_j:
     {
          if (EVNT_LSHIFT() || EVNT_RSHIFT())
          {
               /* Fenster um 10 Pixel nach rechts bewegen
                * --------------------------------------- */
               param[1] = windows[w_index].allpix.g_x+10;
               param[2] = windows[w_index].allpix.g_y;
               fehler = wm_call(WM_POS,param,lparam);
               fehler_ausgabe(fehler);
          }
          else if (EVNT_CTRL())
          {
               /* Fensterbreite um 5 Pixel vergrîûern
                * ----------------------------------- */
               param[1] = windows[w_index].allpix.g_w+5;
               param[2] = windows[w_index].allpix.g_h;
               fehler = wm_call(WM_SIZE,param,lparam);
               fehler_ausgabe(fehler);
          }
          else
          {
               /* Fenster um 20 Pixel nach rechts bewegen
                * --------------------------------------- */
               param[1] = windows[w_index].allpix.g_x+20;
               param[2] = windows[w_index].allpix.g_y;
               fehler = wm_call(WM_POS,param,lparam);
               fehler_ausgabe(fehler);
          }
          break;
     }

     case K_h:
     {
          if (EVNT_LSHIFT() || EVNT_RSHIFT())
          {
               /* Fenster um 10 Pixel nach links bewegen
                * -------------------------------------- */
               param[1] = windows[w_index].allpix.g_x-10;
               param[2] = windows[w_index].allpix.g_y;
               fehler = wm_call(WM_POS,param,lparam);
               fehler_ausgabe(fehler);
          }
          else if (EVNT_CTRL())
          {
               /* Fensterbreite um 5 Pixel verkleinern
                * ------------------------------------ */
               param[1] = windows[w_index].allpix.g_w-5;
               param[2] = windows[w_index].allpix.g_h;
               fehler = wm_call(WM_SIZE,param,lparam);
               fehler_ausgabe(fehler);
          }
          else
          {
               /* Fenster um 20 Pixel nach links bewegen
                * -------------------------------------- */
               param[1] = windows[w_index].allpix.g_x-20;
               param[2] = windows[w_index].allpix.g_y;
               fehler = wm_call(WM_POS,param,lparam);
               fehler_ausgabe(fehler);
          }
          break;
     }
          
     } /* ENDE switch(event_return.high_key) */
}


/* ####################################################
 * Ziffern
 * Aufgabe: Zifferntasten auswerten und Fensteraktionen
 * #################################################### */

void zahl()
{
     int  fehler;

     switch(event_return.high_key)
     {
     case K_1:
     {
          /* Text fÅr Fenster 1 setzen
           * ------------------------- */
          if (EVNT_LSHIFT() || EVNT_RSHIFT())
          {
               fehler=wind_info_set(fenster[1].w_index,
                    "600.000.000 Bytes free");
               fehler_ausgabe(fehler);
          }
          else
          {
               fehler=wind_info_set(fenster[1].w_index,
                    "Tolle Fensterdemo,was?");
               fehler_ausgabe(fehler);
          }
          break;
     }

     case K_2:
     {
          /* Text fÅr Fenster 2 setzen
           * ------------------------- */
          if (EVNT_LSHIFT() || EVNT_RSHIFT())
          {
               fehler=wind_info_set(fenster[2].w_index,
                    "Infozeile - Fenster 2");
               fehler_ausgabe(fehler);
          }
          else
          {
               fehler=wind_info_set(fenster[2].w_index,
                    "BlaBlaBlaBlaBlaBlaBla");
               fehler_ausgabe(fehler);
          }
          break;
     }
     } /* ENDE switch(event_return.high_key) */
}



/* #####################################################################
 * Fehlermeldungen bei Fensteraktionen
 * Aufgabe: Je nach Fehlernummer eine Alertbox mit Fehlermeldung ausgeben
 * ###################################################################### */

void fehler_ausgabe(fehler)
     int  fehler;
{
     char t[200],alert[200];
     
     strcpy(t,"== WM meldet Fehler ==|----------------------|");
     
     switch(fehler)
     {
     case 1:
     {
          strcat(t,"Es ist kein Fenster ge-|îffnet!");
          break;
     }
     case 2:
     {
          strcat(t,"Dies ist kein Fenster!");
          break;
     }
     case 3:
     {
          strcat(t,"Fenster ist offen!");
          break;
     }
     case 4:
     {
          strcat(t,"Fenster ist nicht offen!");
          break;
     }
     case 5:
     {
          strcat(t,"Koordinaten sind falsch!");
          break;
     }
     case 6:
     {
          strcat(t,"Fenstergrîûe falsch!");
          break;
     }
     case 7:
     {
          strcat(t,"Max. Anzahl von Fenstern schon|angelegt!");
          break;
     }
     case 8:
     {
          strcat(t,"Fenster schon aktuell !");
          break;
     }
     } /* ENDE switch(fehler) */

     if (fehler != 0)
     {
          sprintf(alert,"[1][%s][schade]",t);
          form_alert(1,alert);
     }
}

