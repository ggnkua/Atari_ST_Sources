/*--------------------------------------------------------*/
/*             W i n d o w - M a n a g e r                */
/*           -------------------------------              */
/*    Funktionssammlung zur UnterstÅtzung der Windows.    */
/*    Entnommen der ST Computer 05/89 - 10/89.            */
/*                                                        */
/*      Version 3.20    vom 29.11.1992                    */
/*                                                        */
/*      Autor fÅr ST Computer      :    Andreas Lîtscher  */
/*      angepa·t an Mark Williams C:    Michael Kovar     */
/*      Åberarbeitet und erweitert :    Volker Nawrath    */
/*      Entwicklungscomputer       :    ATARI 1040 STF    */
/*                                      ATARI TT 030      */
/*                                                        */
/*--------------------------------------------------------*/

/* Include-Dateien
 * --------------- */
#include  <aesbind.h>
#include  <gemsys.h>
#include  <obdefs.h>
#include  <osbind.h>
#include  <vdibind.h>
#include  "window.h"


/* Prototypen - Window-Manager
 * --------------------------- */
int  align();
void bef_init();
void clear_window();
void close_all_window();
int  close_window();
void delete_all_window();
int  delete_window();
void doku_pos();
void do_redraw();
void full_clear();
void full_redraw();
void handle_full();
void handle_window();
void neupix();
int  open_window();
void scroll_wind();
void set_slider_pos();
void set_slider_size();
void save_window();
void snap();
int  wh_pruef();
int  windopen();
int  windownr();
int  win_init();
void win_exit();
void wind_calc_work();
void wind_hslide();
void wind_vslide();
int  wind_info_set();
int  wm_call();
void work_clipping();
void work_size();
int  xy_pruef();
void xywh_korr();


/* Externe Funktionen
 * ------------------ */
extern    int  get_image();
extern    int  graf_growbox();
extern    int  graf_mouse();
extern    int  graf_shrinkbox();
extern    int  put_image();
extern    int  rect_equal();
extern    int  rect_overlay();
extern    int  release_image();
extern    char *strcpy();
/*   void v_bar();            */
/*   void vs_clip();          */
/*   void vsf_color();        */
/*   void vsf_interior();     */
/*   void vsf_perimeter();    */
/*   void vsf_style();        */
/*   int  vswr_mode();        */
extern    int  wind_calc();
extern    int  wind_close();
extern    int  wind_create();
extern    int  wind_get();
extern    int  wind_open();
extern    int  wind_set();
extern    int  wind_update();


/* Globale Felder, die vom VDI benutzt werden und im Programm, daû den 
 * Window-Manager benutzt, global definiert werden mÅssen.
 * ------------------------------------------------------------------- */
extern    int  ap_id,vdi_handle,work_in[12],work_out[57],contrl[12];
extern    int  intin[128],ptsin[128],intout[128],ptsout[128];


/* Globale Felder, die fÅr Kommunikation zwischen dem Window-Manager
 * und dem Programm benîtigt werden. Sie mÅssen im Programm, daû den 
 * Window-Manager benutzt, global definiert werden.
 * ----------------------------------------------------------------- */
extern    WIND_DATA      *windows;
extern    ACT            aktuell,before;


/* ###################################
 * Initialisierung des Window-Bereichs
 * ################################### */

int  win_init(max_window)
     int  max_window;
{
     register  int  i;
     register  long memory;
     
     if   (max_window == 0)
          return(-1);
     
     /* Speicher reservieren
      * -------------------- */
     memory = Malloc((long)(max_window * sizeof(WIND_DATA)));
     if ((memory == 0L) || (memory < 0L))
     {
          /* Fehler, da nicht genÅgend Speicherplatz vorhanden
           * ------------------------------------------------- */
          return(-2);
     }

     /* Zeiger auf Speicher fÅr WIND_DATA Struktur speichern
      * ---------------------------------------------------- */
     windows = (WIND_DATA *)memory;
     aktuell.max_user_wind = max_window;

     for (i=0;i<max_window;i++)
     {
          windows[i].handle       = -1;
          windows[i].fenster      = FALSE;
          windows[i].offen        = FALSE;
     }
     
     return(0);

} /* ENDE: win_init() */


/* ##################################################################
 * Durch Window-Manager belegten Speicher freigeben / Fenster lîschen
 * ################################################################## */

void win_exit()
{
     register  long memory;

     if (aktuell.max_user_wind > 0)
     {
          /* Alle Fenster lîschen
           * -------------------- */
          delete_all_window();

          /* Speicherbereich freigeben
           * ------------------------- */
          memory = (long)windows;
          Mfree(memory);
     }

} /* ENDE: win_exit() */


/* ##################################
 * PrÅfroutinen zur Fensterverwaltung
 * ################################## */

int  windopen(w_index)
     int  w_index;
{
     if ((w_index < aktuell.max_user_wind) && (w_index >= 0))
     {
          if ((windows[w_index].fenster) && (windows[w_index].offen))
               return(TRUE);
          else
               return(FALSE);
     }
     else
     {
          return(FALSE);
     }
} /* ENDE: windopen() */


int  windownr(w_index)
     int  w_index;
{
     if ((w_index < aktuell.max_user_wind)   &&
         (w_index >= 0)                      &&
         (windows[w_index].fenster))
          return(TRUE);
     else
          return(FALSE);
}


/* ##########################################
 * Fenster mit wei·er Hintergrundfarbe fÅllen
 * ########################################## */
 
/* Komplettes Fenster lîschen
 * ########################## */
void clear_window(w_index)
     int  w_index;
{
     int  clip[4];

     wind_get(windows[w_index].handle,WF_WORKXYWH,
              &clip[0],&clip[1],&clip[2],&clip[3]);
     clip[2] += clip[0];
     clip[2]--;
     clip[3] += clip[1];
     clip[3]--;
     v_hide_c(vdi_handle);              /* Maus verstecken       */
     vsf_color(vdi_handle,0);           /* FÅllfarbe weiû        */
     vsf_perimeter(vdi_handle,0);       /* kein Rahmen           */
     vsf_style(vdi_handle,8);           /* dunkelste Grautînung  */
     vsf_interior(vdi_handle,1);        /* massiv (FÅlltyp)      */
     vswr_mode(vdi_handle,1);           /* Ersetzen-Modus        */
     work_clipping(w_index,TRUE);       /* Clipping ArbeitsflÑche*/
     v_bar(vdi_handle,clip);            /* Fenster fÅllen        */
     work_clipping(w_index,FALSE);      /* Clipping lîschen      */
     v_show_c(vdi_handle);              /* Maus wieder zeigen    */
     
} /* ENDE: clear_window() */


/* Fenster Åber Rechtecksliste lîschen
 * ################################### */
void full_clear(w_index)
     int  w_index;
{
     int  clip[4],work[4];
     RECT p;

     /* Mauszeiger unsichtbar
      * --------------------- */
     graf_mouse(M_OFF,0L);
     
     /* Arbeitsbereich des Fenster ermitteln
      * ------------------------------------ */
     wind_get(windows[w_index].handle,WF_WORKXYWH,
              &work[0],&work[1],&work[2],&work[3]);
     
     wind_update(BEG_UPDATE);
     
     /* Rechtecksliste abarbeiten
      * ------------------------- */
     wind_get(windows[w_index].handle,WF_FIRSTXYWH,
               &p.g_x,&p.g_y,&p.g_w,&p.g_h);

     /* Rechteckliste wird abgearbeitet
      * ------------------------------- */
     while ((p.g_w>0) && (p.g_h>0))
     {
          clip[0] = work[0];
          clip[1] = work[1];
          clip[2] = work[2];
          clip[3] = work[3];
          if (rect_overlay(clip,&p))
          {
               clip[2] += clip[0]-1;
               clip[3] += clip[1]-1;
               vs_clip(vdi_handle,TRUE,clip);
               vsf_color(vdi_handle,0);      /* FÅllfarbe weiû        */
               vsf_perimeter(vdi_handle,0);  /* kein Rahmen           */
               vsf_style(vdi_handle,8);      /* dunkelste Grautînung  */
               vsf_interior(vdi_handle,1);   /* massiv (FÅlltyp)      */
               vswr_mode(vdi_handle,1);      /* Ersetzen-Modus        */
               v_bar(vdi_handle,clip);       /* Rechteckzeichnen      */
               vs_clip(vdi_handle,FALSE,clip);
          }
          /* NÑchstes Rechteck einlesen
           * -------------------------- */
          wind_get(windows[w_index].handle,
                    WF_NEXTXYWH,&p.g_x,&p.g_y,&p.g_w,&p.g_h);

     } /* ENDE: Lesen der Rechtecksliste */

     /* Mauszeiger sichtbar
      * ------------------- */
     graf_mouse(M_ON,0L);
     
     wind_update(END_UPDATE);

} /* ENDE: full_clear() */


/* #############################################################
 * Clipping Åber Arbeitsbereich des Fensters setzen bzw. lîschen
 * ############################################################# */

void work_clipping(w_index,was)
     int  w_index,was;
{
     int  clip[4];

     wind_get(windows[w_index].handle,WF_WORKXYWH,
              &clip[0],&clip[1],&clip[2],&clip[3]);
     clip[2] += clip[0];
     clip[2]--;
     clip[3] += clip[1];
     clip[3]--;
     if (was)
     {
          /* Clipping setzen
           * --------------- */
          vs_clip(vdi_handle,TRUE,clip);
     }
     else
     {
          /* Clipping lîschen
           * ---------------- */
          vs_clip(vdi_handle,FALSE,clip);
     }
} /* ENDE: work_clipping() */



/* #############################################
 * Arbeitsbereich des Fensters zwischenspeichern
 * ############################################# */

void save_window(w_index)
     int  w_index;  /* Index des zu sichernden Fensters     */
{
     int  x0,y0,x1,y1;   /* Koordinaten des Arbeitsbereiches     */

     x0 = windows[w_index].workpix.g_x;
     y0 = windows[w_index].workpix.g_y;
     x1 = windows[w_index].workpix.g_x +
          windows[w_index].workpix.g_w - 1;
     y1 = windows[w_index].workpix.g_y +
          windows[w_index].workpix.g_h -1;
     xywh_korr(&x0,&y0,&x1,&y1);
     
     release_image(&windows[w_index].wsave);
     get_image(x0,y0,x1,y1,&windows[w_index].wsave);

} /* ENDE: save_window() */


/* ######################################################
 * Mit Hilfe der Fenster-ID (Handle) den Index des dazu-
 * gehîrigen Eintrages in der Tabelle "windows" ermitteln
 * ###################################################### */

int  handle_to_index(w_handle)
     int  w_handle;
{
     register  int  i;
     
     for (i=0;i<aktuell.max_user_wind;i++)
     {
          if (windows[i].handle == w_handle)
               return(i);
     }
     
     return(-1);

} /* ENDE: handle_to_index() */


/* ##########################################
 * Fenster îffnen und nîtige Parameter setzen
 * ########################################## */

int  open_window(w_name,w_info,redraw,fl_wsave,was,algn,snp,delclose,
                 s_x,s_y,doc_l,doc_w,doc_x,doc_y,x1,y1,w1,h1,
                 wmin,hmin,xmax,ymax,wmax,hmax,userfkt,fl_userfkt)
char *w_name;                 /* Fenstertitel                         */
char *w_info;                 /* Text fÅr Infozeile                   */
void (*redraw)();             /* Pointer auf Redraw-Funktion          */
int  fl_wsave;                /* Flag fÅr redraw()                    */
int  was;                     /* Elemente des Fensters                */
int  algn,snp;                /* align-Wert, snap j/n                 */
int  delclose;                /* Fenster lîschen, wenn close?         */
int  s_x, s_y;                /* Scrollwerte horizontal/vertikal      */
long doc_l;                   /* DokumentenlÑnge in Zeilen            */
long doc_w;                   /* Dokumentenbreite in Spalten          */
long doc_x,doc_y;             /* Dokumentenposition in Zeile/Spalte   */
int  x1,y1,w1,h1;             /* Startkoordinaten des Fensters        */
int  wmin,hmin;               /* Minimalwerte eines Fensters; 
                               * wmin/hmin = 0   ==>  beliebig klein  */
int  xmax,ymax,wmax,hmax;     /* Maximalkoordinaten eines Fensters;
                               * wmax = 0  ==> Max-Grî·e ist Desktops */
void (*userfkt)();            /* Pointer auf Nachbereitungsfunktion   */
int  fl_userfkt;              /* Flag fÅr userfkt()                   */

{
     register  int  w_handle;
     register  int  w_index;
     register  int  i;
     RECT zwsp1,zwsp2;
        
     if (aktuell.windanz == aktuell.max_user_wind)
     {
          /* Die max. Anzahl der Fenster wurde schon erreicht
           * ------------------------------------------------ */
          return(-1);
     }

     /* Grî·e des Desktops
      * ------------------ */
     if (wmax == 0)
          wind_get(0,WF_WORKXYWH,&xmax,&ymax,&wmax,&hmax);

     /* Fenster anmelden und Handle zwischenspeichern
      * --------------------------------------------- */
     w_handle = wind_create(was,xmax,ymax,wmax,hmax);
     if (w_handle < 0)
     {
          /* Das AES konnte kein Fenster angelegen
           * ------------------------------------- */
          return(-2);
     }

     /* Bereich "aktuell" setzen
      * ------------------------ */
     aktuell.anzahl  += 1;
     aktuell.windanz += 1;
     aktuell.handle   = w_handle;
        

     /* 1) Minimalgrîûe unterschritten ?
      * 2) Koordinaten und Fenstergrîûe auûerhalb Grenzen?
      * 3) Fensterposition (X-Koordinate) an Alignwert ausrichten
      * 4) Max. Rechteck Åberschritten ?
      * -------------------------------------------------------- */
     if ((wmin != 0)  &&  (w1 < wmin))
          w1 = wmin;
     if ((hmin != 0)  &&  (h1 < hmin))
          h1 = hmin;

     xywh_korr(&x1,&y1,&w1,&h1);
     xywh_korr(&xmax,&ymax,&wmax,&hmax);
        
     if (algn)
          x1 = align(x1,algn);

     if (snp)
     {
          zwsp1.g_x = xmax;
          zwsp1.g_y = ymax;
          zwsp1.g_w = wmax;
          zwsp1.g_h = hmax;
          zwsp2.g_x = x1;
          zwsp2.g_y = y1;
          zwsp2.g_w = w1;
          zwsp2.g_h = h1;
          snap(&zwsp1,&zwsp2);
          x1 = zwsp2.g_x;
          y1 = zwsp2.g_y;
          w1 = zwsp2.g_w;
          h1 = zwsp2.g_h;
     }
     
     /* Ersten freien Tabellenindex ermitteln
      * ------------------------------------- */
     for (i=0;i<aktuell.max_user_wind;i++)
     {
          if (windows[i].fenster == FALSE)
          {
               w_index = i;
               break;
          }
     }
             
     /* trÑgt wichtige Daten in Struktur ein
      * ------------------------------------ */
     windows[w_index].fenster      = TRUE;
     windows[w_index].offen        = TRUE;   
     windows[w_index].delclose     = delclose;
     windows[w_index].handle       = w_handle;
     windows[w_index].max.g_x      = xmax;
     windows[w_index].max.g_y      = ymax;
     windows[w_index].max.g_w      = wmax;
     windows[w_index].max.g_h      = hmax;
     windows[w_index].allpix.g_x   = x1;
     windows[w_index].allpix.g_y   = y1;
     windows[w_index].allpix.g_w   = w1;
     windows[w_index].allpix.g_h   = h1;
     windows[w_index].wsave.breite = 0;
     windows[w_index].wsave.hoehe  = 0;
     windows[w_index].wsave.getbuf = 0L;
     windows[w_index].wmin         = wmin;
     windows[w_index].hmin         = hmin;
     windows[w_index].elements     = was;
     windows[w_index].align        = algn;
     windows[w_index].snap         = snp;
     windows[w_index].w_redraw     = redraw;
     windows[w_index].scroll_x     = s_x;
     windows[w_index].scroll_y     = s_y;
     windows[w_index].doc_x        = doc_x;
     windows[w_index].doc_y        = doc_y;
     windows[w_index].doc_length   = (long) (doc_l);
     windows[w_index].doc_width    = doc_w;
     windows[w_index].userfkt      = userfkt;
     windows[w_index].fl_userfkt   = fl_userfkt;
     strcpy(windows[w_index].name, w_name);
     strcpy(windows[w_index].info, w_info);
     windows[w_index].full =
          (x1==xmax && y1==ymax && w1==wmax && h1==hmax);
     
     /* Bei installiertem Multitasting-System darf kein automatischer
      * Redraw durchgefÅhrt werden
      * ------------------------------------------------------------- */
     if (aktuell.multitsk)
          windows[w_index].fl_wsave = FALSE;
     else
          windows[w_index].fl_wsave = fl_wsave;

     /* Fenstername und Infozeile setzen
      * -------------------------------- */
     wind_set(w_handle,WF_NAME,windows[w_index].name,0,0);
     wind_set(w_handle,WF_INFO,windows[w_index].info,0,0);

     /* Arbeitsbereich des Fensters und Dokumentenposition berechnen
      * ------------------------------------------------------------ */
     work_size(w_index);
        
     /* Sliderposition und Grî·e setzen
      * ------------------------------- */
     set_slider_size(w_index);
     set_slider_pos(w_index);

     /* îffnende Box zeichnen, Fenster îffnen und Arbeitsbereich
      * lîschen
      * -------------------------------------------------------- */
     graf_growbox(0,0,0,0,x1,y1,w1,h1);
     wind_open(w_handle,x1,y1,w1,h1);
     clear_window(w_index);

     /* Index vom Fenster zurÅckgeben
      * ----------------------------- */
     return(w_index);
}


/* ########################
 * Schlie·en eines Fensters
 * ######################## */

int  close_window(w_index)
     int  w_index;
{
     if ((windows[w_index].fenster) &&
         (w_index < aktuell.max_user_wind))
     {
          if (windows[w_index].offen)
          {
               /* Handle ist offenes Fenster; wird geschlossen
                * ------------------------------------------- */
               windows[w_index].offen = FALSE;
               graf_shrinkbox(0,0,0,0,windows[w_index].allpix.g_x,
                                      windows[w_index].allpix.g_y,
                                      windows[w_index].allpix.g_w,
                                      windows[w_index].allpix.g_h);
               wind_close(windows[w_index].handle);
               aktuell.anzahl -= 1;
               if (aktuell.anzahl == 0)
                    aktuell.handle = -1;
               if (windows[w_index].delclose)
                    delete_window(w_index);
               if (windows[w_index].fl_wsave &&
                   windows[w_index].delclose  )
                    release_image(&windows[w_index].wsave);
               return(0);
          }
          else
          {
               /* Fenster ist nicht offen
                * ----------------------- */
               return(-1);
          }
     }
     else
     {
          /* Handle ist kein Fenster
           * ----------------------- */
          return(-2);
     }
} /* ENDE: close_window() */


/* ######################
 * Lîschen eines Fensters
 * ###################### */

int  delete_window(w_index)
     int  w_index;
{
     if ((windows[w_index].fenster) &&
         (w_index < aktuell.max_user_wind))
     {
          if (windows[w_index].offen)
          {
               /* Ein offenes Fenster muû geschlossen werden
                * ------------------------------------------ */
               windows[w_index].offen = FALSE;
               graf_shrinkbox(0,0,0,0,windows[w_index].allpix.g_x,
                                      windows[w_index].allpix.g_y,
                                      windows[w_index].allpix.g_w,
                                      windows[w_index].allpix.g_h);
               wind_close(windows[w_index].handle);
               aktuell.anzahl -= 1;
               if (aktuell.anzahl == 0)
                    aktuell.handle = -1;
          }
          if (windows[w_index].fl_wsave)
               release_image(&windows[w_index].wsave);
          wind_delete(windows[w_index].handle);
          windows[w_index].handle   = -1;
          windows[w_index].fenster  = FALSE;
          aktuell.windanz           -= 1;
          return(0);
     }
     else
     {
          /* Handle ist kein Fenster
           * ----------------------- */
          return(-1);
     }
} /* ENDE: delete_window() */
                        

/* ####################################
 * Schlie·en aller noch offenen Fenster
 * #################################### */

void close_all_window()
{
     register  int  i;

     for (i=0; i<aktuell.max_user_wind; i++)
     {
          close_window(i);
          if (aktuell.anzahl == 0)
               break;
     }
}


/* ######################################
 * Lîschen aller noch vorhandenen Fenster
 * ###################################### */

void delete_all_window()
{
     register  int  i;
        
     for (i=0; i<aktuell.max_user_wind; i++)
     {
          delete_window(i);
          if (aktuell.anzahl == 0)
               break;
     }
}


/* ##############################
 * allgemeine Berechnungsroutinen
 * ############################## */

/* Grîûe des Fensterarbeitsbereiches berechnen
 * ------------------------------------------- */
void work_size(w_index)
     int  w_index;       /* Fensteridentifikation */
{
     int  zwsp_w,zwsp_l;
     register  int  x1,y1,w1,h1;
        
     x1 = windows[w_index].allpix.g_x;
     y1 = windows[w_index].allpix.g_y;
     w1 = windows[w_index].allpix.g_w;
     h1 = windows[w_index].allpix.g_h;

     /* Grî·e des Arbeitsbereichs in Pixel holen
      * ---------------------------------------- */
     wind_calc(WC_WORK,windows[w_index].elements,x1,y1,w1,h1,
                       &windows[w_index].work.g_x,
                       &windows[w_index].work.g_y,
                       &zwsp_w,&zwsp_l             );

     /* Breite und Hîhe des Arbeitsbereichs in Spalten / Zeilen
      * ------------------------------------------------------- */
     windows[w_index].work.g_w    = zwsp_w / windows[w_index].scroll_x;
     windows[w_index].work.g_h    = zwsp_l / windows[w_index].scroll_y;

     /* Koordinaten und Breite / Hîhe des Arbeitsbereichs in Pixel
      * --------------------------------------------------------- */
     windows[w_index].workpix.g_x = windows[w_index].work.g_x;
     windows[w_index].workpix.g_y = windows[w_index].work.g_y;
     windows[w_index].workpix.g_w = zwsp_w;
     windows[w_index].workpix.g_h = zwsp_l;

     /* Dokumentenposition innerhalb der erlaubten Grenzen?
      * --------------------------------------------------- */
     doku_pos(w_index);

} /* ENDE: work_size() */


/* aktuell.neupix... auf tatsÑchlich neu zu zeichnenden Bereich
 * umrechnen. Normalerweise enthÑlt es die Werte des zu restaurierenden
 * Rechtecks in Pixel. Wird aber in Zeilen und Spalten gerechnet, wird
 * ein grî·erer Bereich restauriert, der an Zeilen und Spalten angepa·t
 * ist. Dieser Bereich wird in Pixel umgerechnet.
 * ------------------------------------------------------------------- */
void neupix(w_index)
     int  w_index;
{
     if (aktuell.neu_doc.g_x != windows[w_index].doc_x)
     {
          /* Wenn die erste neu zu zeichnende Spalte nicht gleich
           * der 1. dargestellten Spalte im Fenster ist, wird die 
           * X-Koordinate aus der Spaltenposition errechnet
           * --------------------------------------------------- */
          aktuell.neu_pix.g_x = (aktuell.neu_doc.g_x -
                                 windows[w_index].doc_x)  *
                                windows[w_index].scroll_x +
                                windows[w_index].work.g_x;
     }
     else
     {
          /* Die X-Koordinate entspricht dem linken Rand des
           * Arbeitsbereichs des Fensters
           * ----------------------------------------------- */
          aktuell.neu_pix.g_x = windows[w_index].work.g_x;
     }

     if (aktuell.neu_doc.g_y != windows[w_index].doc_y)
     {
          /* Wenn die erste neu zu zeichnende Zeile nicht gleich
           * der 1. dargestellten Zeile im Fenster ist, wird die 
           * Y-Koordinate aus der Zeilenposition errechnet
           * --------------------------------------------------- */
          aktuell.neu_pix.g_y = (aktuell.neu_doc.g_y -
                                 windows[w_index].doc_y)  *
                                windows[w_index].scroll_y +
                                windows[w_index].work.g_y;
     }
     else
     {
          /* Die Y-Koordinate entspricht dem linken Rand des
           * Arbeitsbereichs des Fensters
           * ----------------------------------------------- */
          aktuell.neu_pix.g_y = windows[w_index].work.g_y;
     }

     /* Die Anzahl der neuzuzeichnenden Zeilen und Spalten wird in
      * Anzahl von Pixel umgerechnet
      * ---------------------------------------------------------- */
     aktuell.neu_pix.g_w = aktuell.neu_doc.g_w * windows[w_index].scroll_x;
     aktuell.neu_pix.g_h = aktuell.neu_doc.g_h * windows[w_index].scroll_y;

} /* ENDE: neupix() */

        
/* Arbeitsbereich des Fensters berechnen und bereitstellen
 * ------------------------------------------------------- */
void wind_calc_work(w_index,x,y,w,h)
     int  w_index,x,y,w,h;
{
     int  zwsp_w,zwsp_l;

     wind_calc(WC_WORK, windows[w_index].elements,x,y,w,h,
                        &windows[w_index].work.g_x,
                        &windows[w_index].work.g_y,
                        &zwsp_w,&zwsp_l                   );

     windows[w_index].work.g_w = zwsp_w / windows[w_index].scroll_x;
     windows[w_index].work.g_h = zwsp_l / windows[w_index].scroll_y;
     windows[w_index].workpix.g_x = windows[w_index].work.g_x;
     windows[w_index].workpix.g_y = windows[w_index].work.g_y;
     windows[w_index].workpix.g_w = zwsp_w;
     windows[w_index].workpix.g_h = zwsp_l;

} /* ENDE: wind_calc_work() */


/* Routine, die dafÅr sorgt, da· ein Fenster vollstÑndig innerhalb
 * eines spezifizierten Rechtecks liegt (z.B. DESKTOP)
 * --------------------------------------------------------------- */
void snap(w1,w2)
     RECT *w1, *w2;
{
     if(w2->g_x < w1->g_x)         w2->g_x = w1->g_x;

     if(w2->g_y < w1->g_y)         w2->g_y = w1->g_y;

     if((w2->g_x + w2->g_w) > (w1->g_x + w1->g_w))
          w2->g_x = (w1->g_x + w1->g_w) - w2->g_w;

     if((w2->g_y + w2->g_h) > (w1->g_y + w1->g_h))
          w2->g_y = (w1->g_y + w1->g_h) - w2->g_h;

     if(w2->g_x < w1->g_x)
     {
          w2->g_x = w1->g_x;
          w2->g_w = w1->g_w;
     }

     if(w2->g_y < w1->g_y)
     {
          w2->g_y = w1->g_y;
          w2->g_h = w1->g_h;
     }
} /* ENDE: snap() */


/* Routine, die die Koordinate k auf ein Vielfaches von n snappt
 * ------------------------------------------------------------- */
int  align(k,n)
     int  k,n;
{
     k += (n>>1) -1;
     k = n * (k / n);
     return(k);
}


/* #########################
 * Text fÅr Infozeile setzen
 * ######################### */

int  wind_info_set(w_index,text)
     int  w_index;  /* Index des Fensters    */
     char *text;    /* Text fÅr Infozeile    */
{
     if (!windownr(w_index))  return(2);
          strncpy(windows[w_index].info,text,80);
     wind_set(windows[w_index].handle,WF_INFO,windows[w_index].info,0,0);
     return(0);
}


/* ##################
 * Slidergrî·e setzen
 * ################## */

void set_slider_size(w_index)
     int  w_index;
{
     register  int  h_size,v_size;

     h_size = windows[w_index].work.g_w * 1000L / 
               windows[w_index].doc_width;
     v_size = windows[w_index].work.g_h * 1000L / 
               windows[w_index].doc_length;

     wind_set(windows[w_index].handle,WF_HSLSIZE,h_size,0,0,0);
     wind_set(windows[w_index].handle,WF_VSLSIZE,v_size,0,0,0);
}


/* #####################
 * Sliderposition setzen
 * ##################### */

void set_slider_pos(w_index)
     int  w_index;
{
     register  int  x_pos,y_pos;

     if (windows[w_index].doc_width <= windows[w_index].work.g_w)
          x_pos = 0;
     else 
          x_pos = windows[w_index].doc_x * 1000L / 
                  (windows[w_index].doc_width - windows[w_index].work.g_w);

     if (windows[w_index].doc_length <= windows[w_index].work.g_h)
          y_pos = 0;
     else
          y_pos = windows[w_index].doc_y * 1000L /
                  (windows[w_index].doc_length - windows[w_index].work.g_h);

     wind_set(windows[w_index].handle,WF_HSLIDE,x_pos,0,0,0);
     wind_set(windows[w_index].handle,WF_VSLIDE,y_pos,0,0,0);

} /* ENDE: set_slider_pos() */


/* #########################################################
 * Fenster auf volle Grî·e bzw. ursprÅngliche Grî·e schalten
 * ######################################################### */

void handle_full(w_index)
     int  w_index;
{
     RECT  prev;
     RECT  curr;
     RECT  full;

     wind_get(windows[w_index].handle,WF_CURRXYWH,&curr.g_x,&curr.g_y,
                                                  &curr.g_w,&curr.g_h);
     wind_get(windows[w_index].handle,WF_PREVXYWH,&prev.g_x,&prev.g_y,
                                                  &prev.g_w,&prev.g_h);
     wind_get(windows[w_index].handle,WF_FULLXYWH,&full.g_x,&full.g_y,
                                                  &full.g_w,&full.g_h);

     /* Koordinaten fÅr volle Grîûe korrigieren, da es passieren
      * kann, daû die y-Koordinate in die Menuzeile reicht
      * -------------------------------------------------------- */
     xywh_korr(&full.g_x,&full.g_y,&full.g_w,&full.g_h);

     if(rect_equal(&curr,&full)) 
     {
          /* Window ist auf voller Grîûe, daher auf alte
           * Grîûe zurÅcksetzen
           * ------------------------------------------- */
          graf_shrinkbox(prev.g_x,prev.g_y,prev.g_w,prev.g_h,
                         full.g_x,full.g_y,full.g_w,full.g_h);
          wind_set(windows[w_index].handle,WF_CURRXYWH,prev.g_x,prev.g_y,
                                                       prev.g_w,prev.g_h);
          windows[w_index].full = FALSE;
          wind_calc_work(w_index,prev.g_x,prev.g_y,prev.g_w,prev.g_h);
     }
     else
     {
          /* Fenster auf volle Grî·e setzen
           * ------------------------------ */
          graf_growbox(curr.g_x,curr.g_y,curr.g_w,curr.g_h,
                       full.g_x,full.g_y,full.g_w,full.g_h);
          wind_set(windows[w_index].handle,WF_CURRXYWH,full.g_x,full.g_y,
                                                       full.g_w,full.g_h);
          windows[w_index].full = TRUE;
          wind_calc_work(w_index,full.g_x,full.g_y,full.g_w,full.g_h);
     }
} /* ENDE: handle_full() */


/* ###################################
 * FÅhrt den Redraw eines Fensters aus
 * ################################### */

/* gesamtes Fenster soll neu gezeichnet werden
 * ########################################### */
void full_redraw(w_index)
     int  w_index;
{
     int  buffer[8];
     register  int  aktuell_index;
     
     aktuell_index = handle_to_index(aktuell.handle);
     
     if ((aktuell.multitsk) || (w_index != aktuell_index))
     {
          /* Ein Fenster muû unter folgenden Bedingungen Åber die
           * Rechteckliste ausgegeben werden:
           * - auf einem Multitasking-System.
           * - Fenster ist nicht das aktuelle vom Prozeû.
           * In beiden FÑllen kînnen nÑmlich noch andere Fenster
           * darÅber liegen und wÅrden bei einem vollstÑndigen Neu-
           * zeichnen Åberpinselt werden.
           * ------------------------------------------------------ */
          buffer[0] = 0;
          buffer[1] = 0;
          buffer[2] = 0;
          buffer[3] = w_index;
          wind_get(windows[w_index].handle,WF_WORKXYWH,
                    &buffer[4],&buffer[5],&buffer[6],&buffer[7]);
          do_redraw(buffer);
     }
     else
     {
          /* Komplettes Fenster neu ausgeben
           * ------------------------------- */
          graf_mouse(M_OFF,0L);

          /* Werte des Fensterarbeitsbereichs in Schnittstelle "aktuell"
           * fÅr REDRAW-Programm schreiben
           * ---------------------------------------------------------- */
          aktuell.neu_doc.g_x = windows[w_index].doc_x;
          aktuell.neu_doc.g_y = windows[w_index].doc_y;
          aktuell.neu_doc.g_w = windows[w_index].work.g_w;
          aktuell.neu_doc.g_h = windows[w_index].work.g_h;
          aktuell.neu_pix.g_x = windows[w_index].workpix.g_x;
          aktuell.neu_pix.g_y = windows[w_index].workpix.g_y;
          aktuell.neu_pix.g_w = windows[w_index].workpix.g_w;
          aktuell.neu_pix.g_h = windows[w_index].workpix.g_h;

          /* gesamtes Fenster neu zeichnen
           * ----------------------------- */
          clear_window(w_index);
          work_clipping(w_index,TRUE);
          (*windows[w_index].w_redraw)(w_index);
          work_clipping(w_index,FALSE);

          /* Wenn der automatische Redraw benutzt werden soll, mu· der
           * neue Fensterinhalt zwischengespeichert werden
           * --------------------------------------------------------- */
          if (windows[w_index].fl_wsave)
               save_window(w_index);

          /* Mauszeiger sichtbar
           * ------------------- */
          graf_mouse(M_ON,0L);
     }

} /* ENDE: full_redraw() */


/* Teile des Fensters sollen restauriert werden (Rechteckliste)
 * ############################################################ */
void do_redraw(buffer)
     int  buffer[8];
{
     RECT      p;
     short     work[4];
     register  int  all_redraw;
     int       zwsp_w,zwsp_h;

     all_redraw = FALSE;
        
     /* Mauszeiger unsichtbar
      * --------------------- */
     graf_mouse(M_OFF,0L);
     
     /* Achtung, im buffer[3] wird nicht das Fensterhandle, sondern
      * der Index von der Tabelle "windows" mitgeliefert !!!!!!!!!!
      * ----------------------------------------------------------- */
     wind_update(BEG_UPDATE);
     wind_get(windows[buffer[3]].handle,WF_FIRSTXYWH,
               &p.g_x,&p.g_y,&p.g_w,&p.g_h);

     /* Rechteckliste wird abgearbeitet
      * ------------------------------- */
     while ((p.g_w>0) && (p.g_h>0))
     {
          work[0] = buffer[4];
          work[1] = buffer[5];
          work[2] = buffer[6];
          work[3] = buffer[7];
          if (rect_overlay(work,&p))
          {
               /* Folgende Berechnungen mÅssen zuerst durchge-
                * fÅhrt werden, bevor work[2/3] verÑndert
                * werden:
                * a) Spalte, ab der Redraw durchgefÅhrt wird
                * b) Zeile, ab der Redraw durchgefÅhrt wird
                * c) Breite, fÅr die Redraw durchgefÅhrt wird
                * d) LÑnge, fÅr die Redraw durchgefÅhrt wird
                * ------------------------------------------ */
               aktuell.neu_doc.g_x = windows[buffer[3]].doc_x +
                                     ((work[0] -
                                       windows[buffer[3]].work.g_x) /
                                      windows[buffer[3]].scroll_x);
               aktuell.neu_doc.g_y = windows[buffer[3]].doc_y +
                                     ((work[1] -
                                       windows[buffer[3]].work.g_y) /
                                      windows[buffer[3]].scroll_y);
               aktuell.neu_doc.g_w = (work[2] +
                                      windows[buffer[3]].scroll_x) /
                                     windows[buffer[3]].scroll_x;
               aktuell.neu_doc.g_h = (work[3] +
                                      windows[buffer[3]].scroll_y) /
                                     windows[buffer[3]].scroll_y;

               /* neu zu zeichnenden Bereich in Pixel dem
                * Schnittstellenbereich "aktuell" zuweisen
                * ----------------------------------------- */
               aktuell.neu_pix.g_x = work[0];
               aktuell.neu_pix.g_y = work[1];
               aktuell.neu_pix.g_w = work[2];
               aktuell.neu_pix.g_h = work[3];

               /* Der Programm-Redraw soll benutzt werden, wenn
                * - vom Programmierer erwÅnscht
                *   oder
                * - der ges. Arbeitsbereich restauriert werden soll
                *   oder
                * - das Fenster Åber den Bildschirmrand hinausragt
                *   und der gesamte sichtbare Arbeitsbereich restau-
                *   riert werden soll
                * Ansonsten wird der automatische Redraw aufgerufen!
                * ------------------------------------------------- */
               zwsp_w = aktuell.screen_w - windows[buffer[3]].workpix.g_x;
               if (windows[buffer[3]].workpix.g_w < zwsp_w)
                    zwsp_w = windows[buffer[3]].workpix.g_w;
               zwsp_h = aktuell.screen_h - windows[buffer[3]].workpix.g_y;
               if (windows[buffer[3]].workpix.g_h < zwsp_h)
                    zwsp_h = windows[buffer[3]].workpix.g_h;

               if ((work[2] >= zwsp_w) && (work[3] >= zwsp_h))
                    all_redraw = TRUE;
               else
                    all_redraw = FALSE;

               work[2] += work[0]-1;
               work[3] += work[1]-1;

               vs_clip(vdi_handle,TRUE,work);
               vsf_color(vdi_handle,0);      /* FÅllfarbe weiû        */
               vsf_perimeter(vdi_handle,0);  /* kein Rahmen           */
               vsf_style(vdi_handle,8);      /* dunkelste Grautînung  */
               vsf_interior(vdi_handle,1);   /* massiv (FÅlltyp)      */
               vswr_mode(vdi_handle,1);      /* Ersetzen-Modus        */
               v_bar(vdi_handle,work);

               if (windows[buffer[3]].fl_wsave          &&
                   windows[buffer[3]].wsave.getbuf > 0L &&
                   !all_redraw                            )
               {
                    /* Automatischen Redraw durchfÅhren, da Fenster
                     * gespeichert wurde
                     * ------------------------------------------- */
                    put_image(work[0],work[1],
                              work[0]-windows[buffer[3]].workpix.g_x,
                              work[1]-windows[buffer[3]].workpix.g_y,
                              work[2]-windows[buffer[3]].workpix.g_x,
                              work[3]-windows[buffer[3]].workpix.g_y,
                              &windows[buffer[3]].wsave,S_ONLY     );
               }
               else
               {
                    /* Programmredraw, da entweder kein automatischer
                     * Redraw erwÅnscht oder wegen Speichermangel
                     * nicht mîglich
                     * ------------------------------------------- */
                    (*windows[buffer[3]].w_redraw)(buffer[3]);
               }

          }
          /* NÑchstes Rechteck einlesen
           * -------------------------- */
          wind_get(windows[buffer[3]].handle,
                    WF_NEXTXYWH,&p.g_x,&p.g_y,&p.g_w,&p.g_h);
     }

     /* Der automatische Redraw sollte benutzt werden, aber der
      * Programm-Redraw wurde eingesetzt, weil der ges. Arbeits-
      * bereich restauriert wurde. Da es sich hierbei um das
      * Folgeereignis zum ôffnen des Fensters handeln kann, muû
      * der Fensterinhalt komplett gesichert werden.
      * -------------------------------------------------------- */

     if ((windows[buffer[3]].fl_wsave)  && (all_redraw))
          save_window(buffer[3]);

     vs_clip(vdi_handle,FALSE,work);
     wind_update(END_UPDATE);

     /* Mauszeiger sichtbar
      * ------------------- */
     graf_mouse(M_ON,0L);

} /* ENDE: do_redraw() */


/* ####################################################
 * Dokumentenposition mittels der Sliderposition setzen
 * #################################################### */

void wind_hslide(w_index,newpos)
     int  w_index,newpos;
{
     windows[w_index].doc_x = (long)(newpos) *
                                   (windows[w_index].doc_width - 
                                    windows[w_index].work.g_w) / 1000;
     wind_set(windows[w_index].handle,WF_HSLIDE,newpos,0,0,0);

}


void wind_vslide(w_index,newpos)
     int  w_index,newpos;
{
     windows[w_index].doc_y = (long)(newpos) *
                                   (windows[w_index].doc_length -
                                    windows[w_index].work.g_h) / 1000;
     wind_set(windows[w_index].handle,WF_VSLIDE,newpos,0,0,0);
}


/* #######################################################
 * PrÅfen, ob Koordinaten innerhalb des Bildschirms liegen
 * RÅckgabewert der Funktion: 0 = Koordinaten falsch
 *                            1 = Koordinaten ok
 * ####################################################### */

int  xy_pruef(param)
     int  param[5];      /* énderungsparameter    */
{
     register  int  breite,hoehe;  /* Anzahl Pixel (Auflîsung)   */

     breite = aktuell.screen_w;
     hoehe  = aktuell.screen_h;
        
     if ((param[1] > (breite - 1)) || (param[2] > (hoehe - 1)) ||
         (param[1] < 0           ) || (param[2] < aktuell.menu_y))
          return(0);
     else
          return(1);

} /* ENDE xy_pruef() */


/* #############################################################
 * PrÅfen, ob Grîûe des Fensters die Grîûe des Bildschirms Åber-
 * schreitet. RÅckgabewert der Funktion: 0 = Werte falsch
 *                                       1 = Werte ok
 * ############################################################# */

int  wh_pruef(param)
     int  param[5];      /* énderungsparameter    */
{
     register  int  breite,hoehe;  /* Anzahl Pixel (Auflîsung)   */

     breite = aktuell.screen_w;
     hoehe  = aktuell.screen_h;
        
     if ((param[1] > breite) || (param[2] > hoehe) ||
         (param[1] < 0     ) || (param[2] < 0    )   )
          return(0);
     else
          return(1);

} /* ENDE: wh_pruef() */


/* ########################################################
 * Koordinaten und Fenstergrîûe korrigieren, wenn auûerhalb
 * der erlaubten Grenzen
 * ######################################################## */

void xywh_korr(x,y,w,h)
     int  *x,*y,*w,*h;   /* Koordinaten und Fenstergrîûe    */
{
     if (*x < 0)                        *x = 0;
     if (*y < aktuell.menu_y)           *y = aktuell.menu_y;
     if (*w > (aktuell.screen_w - 1))   *w = aktuell.screen_w - 1;
     if (*h > (aktuell.screen_h - 1))   *h = aktuell.screen_h - 1;
}


/* ##################################################
 * Dokumentenposition an verÑnderte Fenstergrîûe oder
 * Fensterinhaltsposition anpassen.                     
 * ################################################## */

void doku_pos(w_index)
     int  w_index;  /* Fensteridentifikation      */
{
     /* Dokumentenposition mu· neu angepa·t werden, da evtl. das
      * Ende des Dokumentes vor dem  Fensterende liegt
      * -------------------------------------------------------- */
     if (windows[w_index].doc_y >
         (windows[w_index].doc_length - windows[w_index].work.g_h))
          windows[w_index].doc_y = windows[w_index].doc_length -
                                   windows[w_index].work.g_h;
     if(windows[w_index].doc_x >
        (windows[w_index].doc_width - windows[w_index].work.g_w))
          windows[w_index].doc_x = windows[w_index].doc_width -
                                   windows[w_index].work.g_w;

     /* Ist das Dokument kleiner als der Arbeits-
      * bereich, am Anfang des Dok. positionieren
      * ----------------------------------------- */
     if(windows[w_index].doc_x < 0)
          windows[w_index].doc_x = 0;
     if(windows[w_index].doc_y < 0)
          windows[w_index].doc_y = 0;

} /* ENDE: doku_pos() */


/* ##########################################################
 * Den Bereich "before." aus dem Bereich "aktuell." versorgen
 * ########################################################## */

void bef_init()
{
     before.multitsk               = aktuell.multitsk;
     before.max_user_wind          = aktuell.max_user_wind;
     before.windanz                = aktuell.windanz;
     before.anzahl                 = aktuell.anzahl;
     before.handle                 = aktuell.handle;
     before.text_y                 = aktuell.text_y;
     before.menu_y                 = aktuell.menu_y;
     before.aufloesung             = aktuell.aufloesung;
     before.screen_w               = aktuell.screen_w;
     before.screen_h               = aktuell.screen_h;
     before.neu_pix.g_x            = aktuell.neu_pix.g_x;
     before.neu_pix.g_y            = aktuell.neu_pix.g_y;
     before.neu_pix.g_w            = aktuell.neu_pix.g_w;
     before.neu_pix.g_h            = aktuell.neu_pix.g_h;
     before.neu_doc.g_x            = aktuell.neu_doc.g_x;
     before.neu_doc.g_y            = aktuell.neu_doc.g_y;
     before.neu_doc.g_w            = aktuell.neu_doc.g_w;
     before.neu_doc.g_h            = aktuell.neu_doc.g_h;
     before.monitor.fd_addr        = aktuell.monitor.fd_addr;
     before.monitor.fd_w           = aktuell.monitor.fd_w;
     before.monitor.fd_h           = aktuell.monitor.fd_h;
     before.monitor.fd_wdwidth     = aktuell.monitor.fd_wdwidth;
     before.monitor.fd_stand       = aktuell.monitor.fd_stand;
     before.monitor.fd_nplanes     = aktuell.monitor.fd_nplanes;
     before.monitor.fd_r1          = aktuell.monitor.fd_r1;
     before.monitor.fd_r2          = aktuell.monitor.fd_r2;
     before.monitor.fd_r3          = aktuell.monitor.fd_r3;

} /* ENDE: bef_init() */


/* ####################################################################
 * Scrollpfeile, Scrollbalken oder Slider wurde angeklickt, Dokumenten-
 * position mu· neu angepa·t werden.
 * #################################################################### */

void scroll_wind(w_index,what)
     int  w_index,what;
{
     switch(what)
     {
          case W_UPPAGE :
          {
               windows[w_index].doc_y -= windows[w_index].work.g_h+1;
               /* Dokumentenposition auf öberschreitung prÅfen
                * -------------------------------------------- */
               doku_pos(w_index);
               break;
          }
          case W_DNPAGE :
          {
               windows[w_index].doc_y += windows[w_index].work.g_h-1;
               /* Dokumentenposition auf öberschreitung prÅfen
                * -------------------------------------------- */
               doku_pos(w_index);
               break;
          }
          case W_UPLINE :
          {
               windows[w_index].doc_y -= 1;
               /* Dokumentenposition auf öberschreitung prÅfen
                * -------------------------------------------- */
               doku_pos(w_index);
               break;
          }
          case W_DNLINE :
          {
               windows[w_index].doc_y += 1;
               /* Dokumentenposition auf öberschreitung prÅfen
                * -------------------------------------------- */
               doku_pos(w_index);
               break;
          }
          case W_LFPAGE :
          {
               windows[w_index].doc_x -= windows[w_index].work.g_w+1;
               /* Dokumentenposition auf öberschreitung prÅfen
                * -------------------------------------------- */
               doku_pos(w_index);
               break;
          }
          case W_RTPAGE :
          {
               windows[w_index].doc_x += windows[w_index].work.g_w-1;
               /* Dokumentenposition auf öberschreitung prÅfen
                * -------------------------------------------- */
               doku_pos(w_index);
               break;
          }
          case W_LFLINE :
          {
               windows[w_index].doc_x -= 1;
               /* Dokumentenposition auf öberschreitung prÅfen
                * ------------------------------------------ */
               doku_pos(w_index);
               break;
          }
          case W_RTLINE :
          {
               windows[w_index].doc_x += 1;
               /* Dokumentenposition auf öberschreitung prÅfen
                * -------------------------------------------- */
               doku_pos(w_index);
               break;
          }
     } /* ENDE switch(was) */
        
     set_slider_pos(w_index);

} /* ENDE: scroll_wind() */


/* ###############################################
 * Programmierte énderungen am Fenster durchfÅhren
 * ############################################### */

int  wm_call(was,param,lparam)
     int  was;           /* Was soll geÑndert werden        */
     int  param[5];      /* énderungsparameter - Integer    */
     long lparam[4];     /* énderungsparameter - Long       */
{
     int  buffer[8];     /* Meldungspuffer fÅr Aufruf von handle_window */
     register  int  i;   /* Schleifenvariable                           */
     int  zwsp1,zwsp2;   /* Zwischenspeicher                            */
     int  zwsp3,zwsp4;   /* Zwischenspeicher                            */

     /* Nachrichtenbuffer initialisieren
      * -------------------------------- */
     for (i=0;i<=7;i++)
          buffer[i] = 0;

     /* Handle des aktuelles Fensters in Pufferspeicher fÅr Nach-
      * richten speichern; sollte ein anderer Handle als dieser
      * benîtigt werden, muû er nachtrÑglich eingetragen werden
      * --------------------------------------------------------- */
     buffer[3] = aktuell.handle;
        
     /* énderungen abfragen
      * ------------------- */
     switch(was)
     {
          case WM_OPEN:
          {
               /* Fenster îffnen
                * -------------- */
               if (!windownr(param[0]))        return(2);
               if (windopen(param[0]))         return(3);
               bef_init();
               work_size(param[0]);
               set_slider_size(param[0]);
               set_slider_pos(param[0]);
               graf_growbox(windows[param[0]].handle,0,0,0,0,
                              windows[param[0]].allpix.g_x,
                              windows[param[0]].allpix.g_y,
                              windows[param[0]].allpix.g_w,
                              windows[param[0]].allpix.g_h);
               wind_open(windows[param[0]].handle,
                              windows[param[0]].allpix.g_x,
                              windows[param[0]].allpix.g_y,
                              windows[param[0]].allpix.g_w,
                              windows[param[0]].allpix.g_h);
               clear_window(param[0]);
               aktuell.anzahl          += 1;
               aktuell.handle           = windows[param[0]].handle;
               windows[param[0]].offen  = TRUE;
               if (windows[param[0]].fl_userfkt)
                    (*windows[param[0]].userfkt)(was,param[0]);
               break;
          }

          case WM_CLOSE:
          {
               /* Fenster schlieûen
                * ----------------- */
               if (!ANZWIND())                 return(1);
               buffer[0] = WM_CLOSED;
               handle_window(buffer);
               break;
          }

          case WM_DEL:
          {
               /* Fenster lîschen
                * --------------- */
               bef_init();
               if (!windownr(param[0]))        return(2);
               delete_window(param[0]);
               if (windows[param[0]].fl_userfkt)
                    (*windows[param[0]].userfkt)(was,param[0]);
               if (aktuell.anzahl > 0)
               {
                    /* Es ist noch mindestens 1 Fenster geîffnet;
                     * das Handle des jetzt aktuellen Fensters muû
                     * ermittelt werden!
                     * ------------------------------------------- */
                    wind_get(0,WF_TOP,&zwsp1,&zwsp2,&zwsp3,&zwsp4);
                    aktuell.handle = zwsp1;
               }
               break;
          }
          
          case WM_FREDRAW:
          {
               if (!windownr(param[0]))        return(2);
               if (!windopen(param[0]))        return(3);
               full_redraw(param[0]);
               break;
          }
          
          case WM_CLEAR:
          {
               if (!windownr(param[0]))        return(2);
               if (!windopen(param[0]))        return(3);
               full_clear(param[0]);
               break;
          }
        
          case WM_POS:
          {
               /* Fenster positionieren
                * --------------------- */
               if (!ANZWIND())                 return(1);
               param[0] = handle_to_index(aktuell.handle);
               if (xy_pruef(param))
               {
                    /* Fenster neu positionieren
                     * ------------------------- */
                    buffer[0] = WM_MOVED;
                    buffer[4] = param[1];
                    buffer[5] = param[2];
                    buffer[6] = windows[param[0]].allpix.g_w;
                    buffer[7] = windows[param[0]].allpix.g_h;
                    handle_window(buffer);
               }
               else
               {
                    /* Koordinaten falsch
                     * ------------------ */
                    return(5);
               }
               break;
          }
        
          case WM_SIZE:
          {
               /* Fenstergrîûe verÑndern
                * ---------------------- */
               if (!ANZWIND())                 return(1);
               param[0] = handle_to_index(aktuell.handle);
               if (wh_pruef(param))
               {
                    /* neue Fenstergrîûe einstellen
                     * ---------------------------- */
                    buffer[0] = WM_SIZED;
                    buffer[4] = windows[param[0]].allpix.g_x;
                    buffer[5] = windows[param[0]].allpix.g_y;
                    buffer[6] = param[1];
                    buffer[7] = param[2];
                    handle_window(buffer);
               }
               else
               {
                    /* falsche Fenstergrîûe
                     * -------------------- */
                    return(6);
               }
               break;
          }
        
          case WM_FULL:
          {
               /* Fenster auf volle bzw. ursprÅngliche Grîûe
                * ------------------------------------------ */
               if (!ANZWIND())                 return(1);
               buffer[0] = WM_FULLED;
               handle_window(buffer);
               break;
          }
        
          case WM_TOP:
          {
               /* Fenster nach oben bringen
                * ------------------------- */
               if (!windownr(param[0]))        return(2);
               if (!windopen(param[0]))        return(4);
               if (param[0] != handle_to_index(aktuell.handle))
               {
                    /* Fenster wird nach oben gebracht
                     * ------------------------------- */
                    buffer[0] = WM_TOPPED;
                    buffer[3] = windows[param[0]].handle;
                    handle_window(buffer);
               }
               else
               {
                    /* Fenster ist schon aktuell
                     * ------------------------- */
                    return(8);
               }
               break;
          }

          case WM_SDOWN:
          {
               /* nÑchste Seite des Fensterinhaltes
                * --------------------------------- */
               if (!ANZWIND())                 return(1);
               buffer[0] = WM_ARROWED;
               buffer[4] = 1;
               handle_window(buffer);
               break;
          }
        
          case WM_SUP:
          {
               /* vorige Seite des Fensterinhaltes
                * -------------------------------- */
               if (!ANZWIND())                 return(1);
               buffer[0] = WM_ARROWED;
               buffer[4] = 0;
               handle_window(buffer);
               break;
          }
        
          case WM_SLEFT:
          {
               /* linke Seite des Fensterinhaltes
                * ------------------------------- */
               if (!ANZWIND())                 return(1);
               buffer[0] = WM_ARROWED;
               buffer[4] = 4;
               handle_window(buffer);
               break;
          }
        
          case WM_SRIGHT:
          {
               /* rechte Seite des Fensterinhaltes
                * -------------------------------- */
               if (!ANZWIND())                 return(1);
               buffer[0] = WM_ARROWED;
               buffer[4] = 5;
               handle_window(buffer);
               break;
          }
        
          case WM_LDOWN:
          {
               /* nÑchste Zeile des Fensterinhaltes
                * --------------------------------- */
               if (!ANZWIND())                 return(1);
               buffer[0] = WM_ARROWED;
               buffer[4] = 3;
               handle_window(buffer);
               break;
          }
        
          case WM_LUP:
          {
               /* vorige Zeile des Fensterinhaltes
                * -------------------------------- */
               if (!ANZWIND())                 return(1);
               buffer[0] = WM_ARROWED;
               buffer[4] = 2;
               handle_window(buffer);
               break;
          }
        
          case WM_LLEFT:
          {
               /* linke Spalte des Fensterinhaltes
                * -------------------------------- */
               if (!ANZWIND())                 return(1);
               buffer[0] = WM_ARROWED;
               buffer[4] = 6;
               handle_window(buffer);
               break;
          }
        
          case WM_LRIGHT:
          {
               /* nÑchste Spalte des Fensterinhaltes
                * ---------------------------------- */
               if (!ANZWIND())                 return(1);
               buffer[0] = WM_ARROWED;
               buffer[4] = 7;
               handle_window(buffer);
               break;
          }
        
          case WM_TEXT:
          {
               /* Fensterinhalt neu positionieren
                * ------------------------------- */
               if (!ANZWIND())                 return(1);
               bef_init();
               param[0] = handle_to_index(aktuell.handle);
               windows[param[0]].doc_x = lparam[0];
               windows[param[0]].doc_y = lparam[1];

               /* Dokumentenposition ÅberprÅfen
                * ----------------------------- */
               doku_pos(param[0]);

               /* Fensterinhalt neu ausgeben
                * -------------------------- */
               full_redraw(param[0]);

               /* Sliderposition und -grîûe neu berechnen
                * --------------------------------------- */
               set_slider_pos(param[0]);
               set_slider_size(param[0]);

               if (windows[param[0]].fl_userfkt)
                    (*windows[param[0]].userfkt)(was,param[0]);

               break;
          }
        
          case WM_MAX_V:
          {
               /* Max. Anzahl der Zeilen verÑndern
                * -------------------------------- */
               if (!ANZWIND())                 return(1);
               bef_init();
               windows[param[0]].doc_length = lparam[0];
               set_slider_pos(param[0]);
               set_slider_size(param[0]);
               if (windows[param[0]].fl_userfkt)
                    (*windows[param[0]].userfkt)(was,param[0]);
               break;
          }
        
          case WM_MAX_H:
          {
               /* Max. Anzahl der Spalten verÑndern
                * --------------------------------- */
               if (!ANZWIND())                 return(1);
               bef_init();
               windows[param[0]].doc_width = lparam[0];
               set_slider_pos(param[0]);
               set_slider_size(param[0]);
               if (windows[param[0]].fl_userfkt)
                    (*windows[param[0]].userfkt)(was,param[0]);
               break;
          }
     } /* ENDE switch(was) */

     return(0);
     
} /* ENDE: () */


/* #################################################################
 * Fensterereignis abfragen (ereignisgesteuerte Fenstermanipulation)
 * ################################################################# */

void handle_window(buffer)
     int  buffer[8];
{
     register  int  window_smaller;     /* Schalter         */
     register  int  algn;               /* Align-Wert       */
     int  zwsp1,zwsp2,zwsp3,zwsp4;      /* Zwischenspeicher */

     /* Bereich "before" versorgen
      * -------------------------- */
     bef_init();
     
     /* Im buffer[3] wurde die Fenster-ID (Handle) mitgegeben. Der
      * Window-Manager benîtigt aber den Index fÅr seine Tabelle
      * "windows". Daher wird ab hier der buffer[3] in den ent-
      * sprechenden Index umgerechnet und an alle Funktionen des
      * Window-Managers weitergegeben. Die Fenster-ID ist dann
      * dementsprechend mit "windows[buffer[3]].handle" anzugeben.
      * ---------------------------------------------------------- */
     buffer[3] = handle_to_index(buffer[3]);

     switch(buffer[0])
     {
          case MN_SELECTED:
          {
               break;
          }
          case WM_REDRAW:
          {
               do_redraw(buffer);
               break;
          }
          case WM_CLOSED:
          {
               close_window(buffer[3]);
               if (aktuell.anzahl > 0)
               {
                    /* Es ist noch mindestens 1 Fenster geîffnet;
                     * das Handle des jetzt aktuellen Fensters muû
                     * ermittelt werden!
                     * ------------------------------------------- */
                    wind_get(0,WF_TOP,&zwsp1,&zwsp2,&zwsp3,&zwsp4);
                    aktuell.handle = zwsp1;
               }
               break;
          }
          case WM_FULLED:
          {
               handle_full(buffer[3]);

               /* Dokumentenposition mu· neu angepa·t werden
                * da evtl. das Ende des Dokumentes vor dem 
                * Fensterende liegt
                * ------------------------------------------ */
               doku_pos(buffer[3]);

               /* Sliderposition und -grîûe neu berechnen
                * --------------------------------------- */
               set_slider_pos(buffer[3]);
               set_slider_size(buffer[3]);
               break;
          }
          case WM_TOPPED:
          {
               wind_set(windows[buffer[3]].handle,WF_TOP,buffer[3],0,0,0);
               aktuell.handle = windows[buffer[3]].handle;
               break;
          }
          case WM_ARROWED:
          {
               scroll_wind(buffer[3],buffer[4]);
               full_redraw(buffer[3]);
               break;
          }
          case WM_HSLID:
          {
               wind_hslide(buffer[3],buffer[4]);
               full_redraw(buffer[3]);
               break;
          }
          case WM_VSLID:
          {
               wind_vslide(buffer[3],buffer[4]);
               full_redraw(buffer[3]);
               break;
          }
          case WM_MOVED:
          case WM_SIZED:
          {
               /* Feststellen, ob Fenster verkleinert wurde; wichtig
                * fÅr den automatischen Redraw
                * -------------------------------------------------- */
               if ((buffer[0] == WM_SIZED) &&
                   (windows[buffer[3]].workpix.g_w > buffer[6]) ||
                   (windows[buffer[3]].workpix.g_h > buffer[7])   )
                    window_smaller = TRUE;
               else
                    window_smaller = FALSE;

               /* Wenn Fenster schon "full" und es noch vergrîûert
                * werden soll, kann die Routine abgebrochen werden
                * ------------------------------------------------ */
               if(windows[buffer[3]].full &&
                  (buffer[6]>windows[buffer[3]].max.g_w ||
                   buffer[7]>windows[buffer[3]].max.g_h))
                    break;

               /* PrÅfen, ob Minimalgrî·e unterschritten
                * -------------------------------------- */
               if (windows[buffer[3]].wmin != 0)
               {
                    if (buffer[6] < windows[buffer[3]].wmin)
                         buffer[6] = windows[buffer[3]].wmin;
               }
               if (windows[buffer[3]].hmin != 0)
               {
                    if (buffer[7] < windows[buffer[3]].hmin)
                         buffer[7] = windows[buffer[3]].hmin;
               }
                
               /* X-Koordinate des Fensters an Alignwert ausrichten
                * ------------------------------------------------- */
               algn = windows[buffer[3]].align;
               if (algn) 
                    buffer[4]=align(buffer[4], algn);

               /* PrÅfen, ob auûerhalb der max. Grîûe
                * ----------------------------------- */
               if(windows[buffer[3]].snap)
                    snap(&windows[buffer[3]].max,&buffer[4]);

               /* Fenster neu positionieren
                * ------------------------- */
               wind_set(windows[buffer[3]].handle,WF_CURRXYWH,
                         buffer[4],buffer[5],
                         buffer[6],buffer[7]);
               wind_calc_work(buffer[3],buffer[4],
                              buffer[5],buffer[6],buffer[7]);

               /* Dokumentenposition mu· neu angepa·t werden
                * da evtl. das Ende des Dokumentes vor dem 
                * Fensterende liegt
                * ------------------------------------------ */
               doku_pos(buffer[3]);

               /* Sliderposition und -grîûe neu berechnen
                * --------------------------------------- */
               set_slider_pos(buffer[3]); 
               set_slider_size(buffer[3]);

               /* Wenn das Fenster verkleinert wurde, muû dessen
                * Arbeitsbereich gesichert werden, da die Fenster-
                * verkleinerung kein Folgeereignis auslîst, in dem
                * der Arbeitsbereich des Fensters neu gezeichnet
                * und gesichert wird.
                * ------------------------------------------------ */
               if (window_smaller)
               {
                    save_window(buffer[3]);
               }
                
               break;

          } /* ENDE case WM_SIZED, case WM_MOVED  */

          case WM_NEWTOP:
          {
               clear_window(buffer[3]);
               break;
          }
          default:
          {
               break;
          }
     } /* ENDE switch(buffer[0]) */

     /* Rahmenbereich des Fensters zwischenspeichern
      * -------------------------------------------- */
     if (windows[buffer[3]].fenster && windows[buffer[3]].offen)
     {
          /* Werte dÅrfen nur berechnet werden, wenn es sich bei
           * der ID-Nummer um ein geîffnetes Fenster handelt, da
           * ansonsten Nullen zurÅckgegeben werden.
           * --------------------------------------------------- */
          wind_get(windows[buffer[3]].handle,WF_CURRXYWH,
                         &windows[buffer[3]].allpix.g_x,
                         &windows[buffer[3]].allpix.g_y,
                         &windows[buffer[3]].allpix.g_w,
                         &windows[buffer[3]].allpix.g_h);
     }

     /* Nachbereitungsfunktion aufrufen
      * ------------------------------- */
     (*windows[buffer[3]].userfkt)(buffer[0],buffer[3]);

} /* ENDE: handle_window() */

