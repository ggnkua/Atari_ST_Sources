/*--------------------------------------------------------*/
/*                 G E M _ W I N D . C                    */
/*           ------------------------------               */
/*                                                        */
/*      Beispielprogramm zum GEM-Manager                  */
/*                                                        */
/*      Modul fÅr Fensterverwaltung (Ausgabe der Inhalte, */
/*      Umrechnung der Fenstergrîûe auf Auflîsung und     */
/*      ôffnen von Fenstern)                              */
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
#include  <aesbind.h>
#include  <event.h>
#include  <gemdefs.h>
#include  <gemprog.h>
#include  <gemprog1.h>
#include  <gemsys.h>
#include  <obdefs.h>
#include  <osbind.h>
#include  <vdibind.h>
#include  <window.h>


/* Prototypen - GEM-Manager
 * ------------------------ */
extern    void get_dialogtext();
extern    void neupix();
extern    int  open_window();
extern    int  wind_info_set();
extern    int  wm_call();


/* Prototypen - Programm
 * --------------------- */
void afterfkt();
void change_infotext();
void fenster_aktion();
void fenster_anlegen();
void fenster_init();
extern    int  menu_ienable();
extern    int  umwandlung();
void xywh_calc();
extern    void fehler_ausgabe();


/* Felder - GEM-Manager
 * -------------------- */
extern    int  ap_id,vdi_handle,work_in[12],work_out[57],contrl[12];
extern    int  intin[128],ptsin[128],intout[128],ptsout[128];
extern    ACT            aktuell,before;
extern    EVNT           event;
extern    EVNT_RETURN    event_return;
extern    WIND_DATA      *windows;


/* sonstige Felder
 * --------------- */
EXT  fenster[10];             /* EnhÑlt die Definitionen und die 
                               * Handle von 10 Fenstern          */

extern    OBJECT    *menu,         /* MenÅbaumadresse            */
                    *infozeil;     /* Dialogboxadresse           */

/*   >>> Fensterinhalte sind hier als Texte im Programm abgelegt */

char *text1[] = {
          "Dies soll ein Beispieltext sein",
          "der die Funktion der Slider",
          "und der Rollpfeile",
          "demonstrieren soll.",
          "",
          "Sie kînnen ihn beliebig umherschieben",
          "",
          "Die Geschwindigkeit der Textausgabe ist",
          "nicht besonders hoch,",
          "aber das ganze ist auch noch ",
          "nicht optimiert...",
          "---------------------------------------",
          "Dies soll ein Beispieltext sein",
          "der die Funktion der Slider",
          "und der Rollpfeile",
          "demonstrieren soll.",
          "",
          "Sie kînnen ihn beliebig umherschieben",
          "",
          "Die Geschwindigkeit der Textausgabe ist",
          "nicht besonders hoch,",
          "aber das ganze ist auch noch ",
          "nicht optimiert..."
          };

char *text2[] = {
          "Wie gesagt, dies soll ein Beispieltext sein.",
          "Sollte sich dieses Programm so verhalten, wie",
          "Du es erwartest (zeichen- und zeilenweises Scrollen)",
          "kannst Du die Sektkorken knallen lassen. Anderfalls",
          "schmei·e des Computer bitte nicht aus dem Fenster,",
          "er kann noch als TÅrstopper oder Aschenbecher genutzt",
          "werden. So jetzt fÑllt mir nichts mehr ein, daher er-",
          "scheint dieser Text noch ein paarmal!!!",
          "-----------------------------------------------------",
          "Wie gesagt, dies soll ein Beispieltext sein.",
          "Sollte sich dieses Programm so verhalten, wie",
          "Du es erwartest (zeichen- und zeilenweises Scrollen)",
          "kannst Du die Sektkorken knallen lassen. Anderfalls",
          "schmei·e des Computer bitte nicht aus dem Fenster,",
          "er kann noch als TÅrstopper oder Aschenbecher genutzt",
          "werden. So jetzt fÑllt mir nichts mehr ein, daher er-",
          "scheint dieser Text noch ein paarmal!!!",
          "-----------------------------------------------------",
          "Wie gesagt, dies soll ein Beispieltext sein.",
          "Sollte sich dieses Programm so verhalten, wie",
          "Du es erwartest (zeichen- und zeilenweises Scrollen)",
          "kannst Du die Sektkorken knallen lassen. Anderfalls",
          "schmei·e des Computer bitte nicht aus dem Fenster,",
          "er kann noch als TÅrstopper oder Aschenbecher genutzt",
          "werden. So jetzt fÑllt mir nichts mehr ein, daher er-",
          "scheint dieser Text noch ein paarmal!!!",
          "-----------------------------------------------------",
          "Wie gesagt, dies soll ein Beispieltext sein.",
          "Sollte sich dieses Programm so verhalten, wie",
          "Du es erwartest (zeichen- und zeilenweises Scrollen)",
          "kannst Du die Sektkorken knallen lassen. Anderfalls",
          "schmei·e des Computer bitte nicht aus dem Fenster,",
          "er kann noch als TÅrstopper oder Aschenbecher genutzt",
          "werden. So jetzt fÑllt mir nichts mehr ein, daher er-",
          "scheint dieser Text noch ein paarmal!!!",
          "-----------------------------------------------------"
          };



/* ###########################################################
 * Ausgaberoutine Nr. 1 fÅr Fenster
 * Aufgabe: Text in einem Fenster bzw. Fensterbereich ausgeben
 * ########################################################### */

void output1(w_index)
int  w_index;
{
     register  int  i,ii,iii; /* SchleifenzÑhler                 */
     register  int  x,y;      /* Koordinaten                     */
     int       zwsp_x,        /* Dokumentenposition Spalte       */
               zwsp_y;        /* Dokumentenposition Zeile        */
     char *zeiger;            /* Zeiger auf Zeichen in Text      */
     char ausgabe[80];        /* Zeile wird in diesem Feld auf-
                               * gebaut und zum Schlu· ausge-
                               * geben                           */

     /* X,Y-Koordinaten des linken oberen Zeichen errechnen
      * --------------------------------------------------- */
     neupix(w_index);

     /* X-,Y-Koordinate des neu zu zeichnenden Rechtecks;
      * - sie sind auf das linke, obere Zeichen ausgerichtet
      * - die Y-Koordinate mu· um die Pixelhîhe einer Zeile -1
      *   erhîht werden, da die Ausgabefunktion von der untersten
      *   Pixelzeile eines Zeichen ausgeht
      * ---------------------------------------------------------- */
     x      = aktuell.neu_pix.g_x;
     y      = aktuell.neu_pix.g_y + aktuell.text_y - 1;
     zwsp_x = aktuell.neu_doc.g_x;
     zwsp_y = aktuell.neu_doc.g_y;

     /* Die auszugebende Zeile aufbauen und ausgeben
      * ---------------------------------------------------- */
     for (i=zwsp_y;i<=zwsp_y+aktuell.neu_doc.g_h;i++,
         y+=aktuell.text_y)
     {
          /* Ausgabe abbrechen, wenn Dokumentenende erreicht
           * ----------------------------------------------- */
          if (i >= windows[w_index].doc_length)
               break;

          /* Ausgabestring lîschen
           * --------------------- */
          for (iii=0;iii<=80;iii++)
               ausgabe[iii] = '\0';

          /* Zeiger auf erstes Zeichen der Zeile positionieren
           * ------------------------------------------------- */
          zeiger    = text1[i];
          
          /* Zeiger auf erstes auszugebendes Zeichen einstellen;
           * Ende, wenn Zeilenende vor erste auszugebender Spalte
           * -------------------------------------------------- */
          for (iii=0;iii<zwsp_x;iii++)
          {
               if (*zeiger == '\0')
                    break;
               zeiger++;
          }

          /* wenn Text nicht vor dem Redraw-Rechteck endet,
           * wird er ausgegeben ausgeben
           * ---------------------------------------------- */
          if (*zeiger != '\0')
          {
               /* auszugebende Zeile solange aufbauen, bis
                * Ende des Redraw-Rechtecks oder der Zeile
                * erreicht
                * ---------------------------------------- */
               for (ii=0;ii<=aktuell.neu_doc.g_w;ii++,zeiger++)
               {
                    /* Aufbau des Ausgabestrings
                     * ------------------------- */
                    if (*zeiger != '\0')
                         ausgabe[ii] = *zeiger;
                    else
                         ii = aktuell.neu_doc.g_w;
               }
               /* aufgebaute Zeile ausgeben
                * ------------------------- */
               v_justified(vdi_handle,x,y,ausgabe,200,0,0);
          }
     }

} /* ENDE: output1() */


/* ###########################################################
 * Ausgaberoutine Nr. 2 fÅr Fenster
 * Aufgabe: Text in einem Fenster bzw. Fensterbereich ausgeben
 * ########################################################### */

void output2(w_index)
int  w_index;
{
     register  int  i,ii,iii; /* SchleifenzÑhler                 */
     register  int  x,y;      /* Koordinaten                     */
     int       zwsp_x,        /* Dokumentenposition Spalte       */
               zwsp_y;        /* Dokumentenposition Zeile        */
     char *zeiger;
     char ausgabe[80];


     neupix(w_index);

     x = aktuell.neu_pix.g_x;
     y = aktuell.neu_pix.g_y + aktuell.text_y - 1;
     zwsp_x = aktuell.neu_doc.g_x;
     zwsp_y = aktuell.neu_doc.g_y;
     
     for (i=zwsp_y;i<=zwsp_y+aktuell.neu_doc.g_h;i++,
          y+=aktuell.text_y)
     {
          /* Ausgabe abbrechen, wenn Dokumentenende erreicht */
          if (i >= windows[w_index].doc_length)
               break;

          for (iii=0;iii<=80;iii++)
               ausgabe[iii] = '\0';

          /* Zeilenweise Ausgabe des Textes, Zeiger auf
           * Textzeile                       */
          zeiger    = text2[i];

          /* auf erstes auszugebendes Zeichen einstellen */
          for (iii=0;iii<zwsp_x;iii++)
          {
               if (*zeiger == '\0')
                    break;
               zeiger++;
          }

          /* wenn Text nicht vor dem Redraw-Rechteck endet,
           * wird er ausgegeben ausgeben               */
          if (*zeiger != '\0')
          {
               for (ii=0;ii<=aktuell.neu_doc.g_w;ii++,zeiger++)
               {
                    /* Aufbau des Ausgabestrings */
                    if (*zeiger != '\0')
                         ausgabe[ii] = *zeiger;
                    else
                         ii =aktuell.neu_doc.g_w;
               }
               v_justified(vdi_handle,x,y,ausgabe,200,0,0);
          }
     }

} /* ENDE: output2() */


/* ############################################################
 * Nachbereitungsfunktion
 * Aufgabe: Wird nach jeder Fensteraktion aufgerufen, wenn Flag
 *          des jeweiligen Fensters auf TRUE steht
 * ############################################################ */

void afterfkt(was,w_index)
     int  was;      /* Art des Ereignisses */
     int  w_index;  /* Fenster, fÅr das ein Ereignis bearbeitet wurde */
{
     char alert[200];
     char zeile1[31],zeile2[31],zeile3[31],zeile4[31],zeile5[31];
     int  i;
     
     switch(was)
     {
          case WM_CLOSE:
          case WM_CLOSED:
          {
               strcpy(zeile1, "------- Nachbereitung --------|");
               strcpy(zeile2, " |");
               sprintf(zeile3," Fensterindex %d geschlossen |",w_index);
               strcpy(zeile4," |");
               strcpy(zeile5," ");
               for (i=1;i<=9;i++)
               {
                    if ((fenster[i].w_index == w_index) &&
                        windows[w_index].delclose      )
                    {
                         sprintf(zeile4," u n d    g e l î s c h t");
                         fenster[i].w_index = -1;
                         fenster[i].offen   = FALSE;
                         break;
                    }
               }
               sprintf(alert,"[1][%s%s%s%s%s][OKAY]",
                    zeile1,zeile2,zeile3,zeile4,zeile5);
               form_alert(1,alert);
               break;
          }
          case WM_DEL:
          {
               strcpy(zeile1, "------- Nachbereitung --------|");
               strcpy(zeile2," |");
               sprintf(zeile3,"   Fensterindex %d gelîscht",w_index);
               for (i=1;i<=9;i++)
               {
                    if (fenster[i].w_index == w_index)
                    {
                         fenster[i].w_index = -1;
                         fenster[i].offen   = FALSE;
                         break;
                    }
               }
               sprintf(alert,"[1][%s%s%s][OKAY]",
                    zeile1,zeile2,zeile3);
               form_alert(1,alert);
               break;
          }
     } /* ENDE switch(was) */
     
     /* PrÅfen, ob MenÅeintrÑge aktiv sein dÅrfen
      * ----------------------------------------- */
     if (aktuell.anzahl == 0)
     {
          menu_ienable(menu,FEAKTCLO,0);
          menu_ienable(menu,FEAKTDEL,0);
     }
     else
     {
          menu_ienable(menu,FEAKTCLO,1);
          menu_ienable(menu,FEAKTDEL,1);
     }

} /* ENDE: afterfkt() */


/* ###############################################################
 * Anpassung Fenstergrîûe an Auflîsung
 * Aufgabe: Umrechnung von Koordinaten oder Fenstergrîûen abhÑngig
 * in die aktuelle Bildschirmauflîsung. Bei den Åbergebenen Werten
 * wird davon ausgegangen, daû sie sich auf die hohe ST-Auflîsung
 * (640*400 Pixel) beziehen.
 * ################################################################ */

void xywh_calc(x,y,w,h,w_min,h_min,x_max,y_max,w_max,h_max)
     int  *x,*y,*w,*h;
     int  *w_min,*h_min;
     int  *x_max,*y_max,*w_max,*h_max;      
{
     int  std_w     = 640;    /* Es wird von der hohen Auflîsung */
     int  std_h     = 400;    /* ausgegangen              */
     double    w_proz;   /* VerhÑltnis hohe zu aktueller Auf-
                     * lîsung (Breite)          */
     double    h_proz;   /* VerhÑltnis hohe zu aktueller Auf-
                     * lîsung (Hîhe)            */

     w_proz = (double)aktuell.screen_w / (double)std_w;
     h_proz = (double)aktuell.screen_h / (double)std_h;

     *x     = (int)(*x) * w_proz;
     *w     = (int)(*w) * w_proz;
     *y     = (int)(*y) * h_proz;
     *h     = (int)(*h) * h_proz;
     *w_min = (int)(*w_min) * w_proz;
     *h_min = (int)(*h_min) * h_proz;
     *x_max = (int)(*x_max) * w_proz;
     *w_max = (int)(*w_max) * w_proz;
     *y_max = (int)(*y_max) * h_proz;
     *h_max = (int)(*h_max) * h_proz;

} /* ENDE: xywh_calc */



/* #########################################
 * Neues Fenster
 * Aufgabe: Neues Fenster anlegen und îffnen
 * ######################################### */

void fenster_anlegen(fensternr)
     int  fensternr;
{
     char t[200],alert[200];
     
     if (fenster[fensternr].w_index < 0)
     {
          strcpy(t,"== WM meldet Fehler ==|----------------------|");

          switch (fensternr)
          {
          case 1:
          {
               fenster[1].w_index = open_window(
                          "Demofenster -1-",
                          "Dies ist eine Infozeile",
                          output1,TRUE,
                          NAME    + CLOSER   + MOVER +
                          SIZER   + FULLER   + INFO    +
                          UPARROW + DNARROW +
                          VSLIDE  + HSLIDE   +
                          LFARROW + RTARROW,
                          8,FALSE,TRUE,
                          8,aktuell.text_y,
                          23L,39L,5L,3L,
                          fenster[1].x,
                          fenster[1].y,
                          fenster[1].w,
                          fenster[1].h,
                          fenster[1].w_min,
                          fenster[1].h_min,
                          fenster[1].x_max,
                          fenster[1].y_max,
                          fenster[1].w_max,
                          fenster[1].h_max,
                          afterfkt,TRUE);
               break;

          } /* ENDE case 1 */

          case 2:
          {
               fenster[2].w_index = open_window(
                          "Demofenster -2-",
                          "Infozeile eine ist dies",
                          output2,FALSE,
                          NAME    + CLOSER   + MOVER +
                          SIZER   + FULLER   + INFO    +
                          UPARROW + DNARROW +
                          VSLIDE  + HSLIDE   +
                          LFARROW + RTARROW,
                          8,FALSE,FALSE,
                          8,aktuell.text_y,
                          36L,53L,15L,15L,
                          fenster[2].x,
                          fenster[2].y,
                          fenster[2].w,
                          fenster[2].h,
                          fenster[2].w_min,
                          fenster[2].h_min,
                          fenster[2].x_max,
                          fenster[2].y_max,
                          fenster[2].w_max,
                          fenster[2].h_max,
                          afterfkt,TRUE);
               break;

          } /* ENDE case 2 */

          case 3:
          {
               fenster[3].w_index = open_window(
                          "Demofenster -3-",
                          "Schon wieder eine Infozeile",
                          output2,TRUE,
                          NAME    + CLOSER   + MOVER +
                          SIZER   + FULLER   + INFO    +
                          UPARROW + DNARROW +
                          VSLIDE  + HSLIDE   +
                          LFARROW + RTARROW,
                          8,FALSE,FALSE,
                          8,aktuell.text_y,
                          36L,53L,0L,0L,
                          fenster[3].x,
                          fenster[3].y,
                          fenster[3].w,
                          fenster[3].h,
                          fenster[3].w_min,
                          fenster[3].h_min,
                          fenster[3].x_max,
                          fenster[3].y_max,
                          fenster[3].w_max,
                          fenster[3].h_max,
                          afterfkt,TRUE);
               break;

          } /* ENDE case 3 */

          case 4:
          {
               fenster[4].w_index = open_window(
                          "Demofenster -4-",
                          "Infozeile eine ist dies",
                          output1,TRUE,
                          NAME    + CLOSER   + MOVER +
                          SIZER   + FULLER   + INFO    +
                          UPARROW + DNARROW +
                          VSLIDE  + HSLIDE   +
                          LFARROW + RTARROW,
                          0,TRUE,TRUE,
                          8,aktuell.text_y,
                          23L,39L,0L,0L,
                          fenster[4].x,
                          fenster[4].y,
                          fenster[4].w,
                          fenster[4].h,
                          fenster[4].w_min,
                          fenster[4].h_min,
                          fenster[4].x_max,
                          fenster[4].y_max,
                          fenster[4].w_max,
                          fenster[4].h_max,
                          afterfkt,TRUE);
               break;

          } /* ENDE case 4 */

          case 5:
          {
               fenster[5].w_index = open_window(
                          "Demofenster -5-",
                          "Rate mal, was das hier ist",
                          output2,TRUE,
                          NAME    + SIZER,
                          0,FALSE,FALSE,
                          8,aktuell.text_y,
                          36L,53L,15L,15L,
                          fenster[5].x,
                          fenster[5].y,
                          fenster[5].w,
                          fenster[5].h,
                          fenster[5].w_min,
                          fenster[5].h_min,
                          fenster[5].x_max,
                          fenster[5].y_max,
                          fenster[5].w_max,
                          fenster[5].h_max,
                          afterfkt,TRUE);
               break;

          } /* ENDE case 5 */

          case 6:
          {
               fenster[6].w_index = open_window(
                          "Demofenster -6-",
                          "Infozeile, die Sechste",
                          output2,TRUE,
                          NAME    + CLOSER   + MOVER +
                          SIZER   + FULLER   + INFO    +
                          UPARROW + DNARROW +
                          VSLIDE  + HSLIDE   +
                          LFARROW + RTARROW,
                          0,TRUE,FALSE,
                          8,aktuell.text_y,
                          36L,53L,0L,0L,
                          fenster[6].x,
                          fenster[6].y,
                          fenster[6].w,
                          fenster[6].h,
                          fenster[6].w_min,
                          fenster[6].h_min,
                          fenster[6].x_max,
                          fenster[6].y_max,
                          fenster[6].w_max,
                          fenster[6].h_max,
                          afterfkt,TRUE);
               break;

          } /* ENDE case 6 */

          case 7:
          {
               fenster[7].w_index = open_window(
                          "Demofenster -7-",
                          "Und noch eine Infozeile",
                          output2,TRUE,
                          NAME    + CLOSER   + MOVER +
                          SIZER   + FULLER   + INFO    +
                          UPARROW + DNARROW +
                          VSLIDE  + HSLIDE   +
                          LFARROW + RTARROW,
                          8,TRUE,TRUE,
                          8,aktuell.text_y,
                          36L,53L,0L,0L,
                          fenster[7].x,
                          fenster[7].y,
                          fenster[7].w,
                          fenster[7].h,
                          fenster[7].w_min,
                          fenster[7].h_min,
                          fenster[7].x_max,
                          fenster[7].y_max,
                          fenster[7].w_max,
                          fenster[7].h_max,
                          afterfkt,TRUE);
               break;

          } /* ENDE case 7 */

          case 8:
          {
               fenster[8].w_index = open_window(
                          "Demofenster -8-",
                          "Oh nein, nicht schon wieder eine Infozeile!!",
                          output1,FALSE,
                          NAME    + CLOSER   + MOVER +
                          SIZER   + FULLER   + INFO    +
                          UPARROW + DNARROW +
                          VSLIDE  + HSLIDE   +
                          LFARROW + RTARROW,
                          0,FALSE,FALSE,
                          8,aktuell.text_y,
                          23L,39L,0L,0L,
                          fenster[8].x,
                          fenster[8].y,
                          fenster[8].w,
                          fenster[8].h,
                          fenster[8].w_min,
                          fenster[8].h_min,
                          fenster[8].x_max,
                          fenster[8].y_max,
                          fenster[8].w_max,
                          fenster[8].h_max,
                          afterfkt,TRUE);
               break;

          } /* ENDE case 8 */

          case 9:
          {
               fenster[9].w_index = open_window(
                          "Demofenster -9-",
                          "...  k e i n  K o m m e n t a r",
                          output2,FALSE,0,
                          8,TRUE,TRUE,
                          8,aktuell.text_y,
                          36L,53L,0L,0L,
                          fenster[9].x,
                          fenster[9].y,
                          fenster[9].w,
                          fenster[9].h,
                          fenster[9].w_min,
                          fenster[9].h_min,
                          fenster[9].x_max,
                          fenster[9].y_max,
                          fenster[9].w_max,
                          fenster[9].h_max,
                          afterfkt,TRUE);
               break;

          } /* ENDE case 9 */
          } /* ENDE switch (fensternr) */

          if   (fenster[fensternr].w_index == - 1)
          {
               strcat(t,"Max. Anzahl von Fenstern schon|!");
               strcat(t,"angelegt!");
               sprintf(alert,"[1][%s][Schade]",t);
               form_alert(1,alert);
          }
          else if (fenster[fensternr].w_index == - 2)
          {
               strcat(t,"AES konnte kein Fenster îffnen");
               sprintf(alert,"[1][%s][Nanu]",t);
               form_alert(1,alert);
               fenster[fensternr].w_index = -1;
          }
          
     } /* ENDE "true-Zweig": if (fenster[fensternr].w_index < 0) */

     else

     {
          /* Dieses Fenster ist schon geîffnet
           * --------------------------------- */
          strcpy(t,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!|");
          strcat(t,"   Hey, dieses Fenster ist   |");
          strcat(t,"   schon vom AES angelegt!   |");
          strcat(t,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
          sprintf(alert,"[1][%s][JaJa]",t);
          form_alert(1,alert);

     } /* ENDE "false-Zweig": if (fenster[fensternr].w_handle < 0) */

} /* ENDE: fenster_anlegen() */


/* ################################################################
 * Programminterne Fensterdaten initialisieren
 * Aufgabe: Die Fensterdaten dieses Programms initialisieren und an
 *          die aktuelle Auflîsung anpassen
 * ################################################################ */

void fenster_init()
{
     int  i;
     
     fenster[1].w_index  = -1;
     fenster[1].x        = 50;
     fenster[1].y        = 10;
     fenster[1].w        = 280;
     fenster[1].h        = 280;
     fenster[1].w_min    = 0;
     fenster[1].h_min    = 0;
     fenster[1].x_max    = 0;
     fenster[1].y_max    = 0;
     fenster[1].w_max    = 0;
     fenster[1].h_max    = 0;
     fenster[2].w_index  = -1;
     fenster[2].x        = 300;
     fenster[2].y        = 100;
     fenster[2].w        = 330;
     fenster[2].h        = 230;
     fenster[2].w_min    = 0;
     fenster[2].h_min    = 0;
     fenster[2].x_max    = 0;
     fenster[2].y_max    = 0;
     fenster[2].w_max    = 0;
     fenster[2].h_max    = 0;
     fenster[3].w_index  = -1;
     fenster[3].x        = 200;
     fenster[3].y        = 200;
     fenster[3].w        = 430;
     fenster[3].h        = 100;
     fenster[3].w_min    = 50;
     fenster[3].h_min    = 30;
     fenster[3].x_max    = 0;
     fenster[3].y_max    = 0;
     fenster[3].w_max    = 0;
     fenster[3].h_max    = 0;
     fenster[4].w_index  = -1;
     fenster[4].x        = 450;
     fenster[4].y        = 70;
     fenster[4].w        = 150;
     fenster[4].h        = 300;
     fenster[4].w_min    = 0;
     fenster[4].h_min    = 0;
     fenster[4].x_max    = 0;
     fenster[4].y_max    = 0;
     fenster[4].w_max    = 0;
     fenster[4].h_max    = 0;
     fenster[5].w_index  = -1;
     fenster[5].x        = 10;
     fenster[5].y        = 300;
     fenster[5].w        = 630;
     fenster[5].h        = 50;
     fenster[5].w_min    = 100;
     fenster[5].h_min    = 100;
     fenster[5].x_max    = 0;
     fenster[5].y_max    = 0;
     fenster[5].w_max    = 0;
     fenster[5].h_max    = 0;
     fenster[6].w_index  = -1;
     fenster[6].x        = 250;
     fenster[6].y        = 140;
     fenster[6].w        = 140;
     fenster[6].h        = 120;
     fenster[6].w_min    = 200;
     fenster[6].h_min    = 150;
     fenster[6].x_max    = 100;
     fenster[6].y_max    = 50;
     fenster[6].w_max    = 400;
     fenster[6].h_max    = 300;
     fenster[7].w_index  = -1;
     fenster[7].x        = 10;
     fenster[7].y        = 20;
     fenster[7].w        = 620;
     fenster[7].h        = 300;
     fenster[7].w_min    = 0;
     fenster[7].h_min    = 0;
     fenster[7].x_max    = 50;
     fenster[7].y_max    = 20;
     fenster[7].w_max    = 500;
     fenster[7].h_max    = 200;
     fenster[8].w_index  = -1;
     fenster[8].x        = 5;
     fenster[8].y        = 20;
     fenster[8].w        = 630;
     fenster[8].h        = 360;
     fenster[8].w_min    = 0;
     fenster[8].h_min    = 0;
     fenster[8].x_max    = 0;
     fenster[8].y_max    = 0;
     fenster[8].w_max    = 0;
     fenster[8].h_max    = 0;
     fenster[9].w_index  = -1;
     fenster[9].x        = 250;
     fenster[9].y        = 180;
     fenster[9].w        = 50;
     fenster[9].h        = 50;
     fenster[9].w_min    = 0;
     fenster[9].h_min    = 200;
     fenster[9].x_max    = 0;
     fenster[9].y_max    = 0;
     fenster[9].w_max    = 0;
     fenster[9].h_max    = 0;

     /* Fensterposition und -grîûe an aktuelle Bildschirm-
      * auflîsung anpassen
      * -------------------------------------------------- */
     for (i=1;i<=MAXWIND;i++)
     {
          xywh_calc(&fenster[i].x,
                 &fenster[i].y,
                 &fenster[i].w,
                 &fenster[i].h,
                 &fenster[i].w_min,
                 &fenster[i].h_min,
                 &fenster[i].x_max,
                 &fenster[i].y_max,
                 &fenster[i].w_max,
                 &fenster[i].h_max);
     }

} /* ENDE: fenster_init() */



/* ##########################################################
 * Fensteraktionen anstoûen
 * Aufgabe: Je nach Flagnummer entsprechende Aktion zum einem
 *          Fenster ausfÅhren
 * ########################################################## */

void fenster_aktion(fensternr,flag)
     int  fensternr,flag;
{
     int  i;
     int  param[5];
     long lparam[4];
     int  fehler;

     /* Aktion:     1 = Fenster anlegen
      *             2 = Fenster îffnen
      *             3 = Fenster schlieûen
      *             4 = Fenster lîschen
      *             5 = Fenster nach oben holen */

     /* Initialisierungen
      * ----------------- */
     fehler    = 0;
     for (i=0;i<=4;i++)
          param[i] = 0;
     for (i=0;i<=3;i++)
          lparam[i] = 0L;

     /* Aktionen am Fenster ausfÅhren
      * ----------------------------- */
     switch(flag)
     {
     case 1: /* Fenster anlegen + îffnen
              * ------------------------ */
          fenster_anlegen(fensternr);
          fenster[fensternr].offen = TRUE;
          break;
     case 2: /* Fenster îffnen
              * -------------- */
          param[0] = fenster[fensternr].w_index;
          fehler = wm_call(WM_OPEN,param,lparam);
          fehler_ausgabe(fehler);
          break;
     case 3: /* aktuelles Fenster schlieûen
              * --------------------------- */
          fehler = wm_call(WM_CLOSE,param,lparam);
          fehler_ausgabe(fehler);
          break;
     case 4: /* Fenster lîschen
              * --------------- */
          param[0] = fenster[fensternr].w_index;
          fehler = wm_call(WM_DEL,param,lparam);
          fenster[fensternr].offen = FALSE;
          fehler_ausgabe(fehler);
          break;
     case 5: /* Fenster nach oben holen
              * ----------------------- */
          param[0] = fenster[fensternr].w_index;
          fehler = wm_call(WM_TOP,param,lparam);
          fehler_ausgabe(fehler);
          break;
     }
}



/* ########################################################
 * Text der Infozeile Ñndern
 * Aufgabe: Zu einem vorzugebenen Fenster soll der Text der
 *          Infozeile geÑndert werden
 * ######################################################## */

void change_infotext()
{
     int  button,fensternr;
     char numtext[2],text[81];

     put_dialogtext(infozeil,ZEFENUMM,"");
     put_dialogtext(infozeil,ZETEXT,"");
     button = do_movedial(infozeil,ZEDRAG,ZEFENUMM);

     if (button==ZEOKAY)
     {
          /* Fensternummer wurde eingegeben
           * ------------------------------ */
          get_dialogtext(infozeil,ZEFENUMM,numtext);
          get_dialogtext(infozeil,ZETEXT,text);
          if (strcmp(numtext,"@") && strcmp(text,"@"))
          {
               fensternr = umwandlung(numtext);
               wind_info_set(fenster[fensternr].w_index,text);
          }
     }

} /* ENDE: change_infotext() */

