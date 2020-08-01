/*--------------------------------------------------------*/
/*                  f k t p o o l . c                     */
/*           ------------------------------               */
/*                                                        */
/*  Allgemeine Funktionen fÅr die GEM-Programmierung.     */
/*                                                        */
/*                                                        */
/*      letzte énderung am 29.11.92                       */
/*                                                        */
/*      entwickelt auf ATARI 1040 ST                      */
/*                     ATARI TT 030                       */
/*                 mit Mark Williams C  Version 3.09      */
/*                                                        */
/*--------------------------------------------------------*/

#include  <aesbind.h>
#include  <gemdefs.h>
#include  <gemsys.h>
#include  <osbind.h>
#include  <vdibind.h>


/* In dieser Datei definierte Funktionen
 * ------------------------------------- */
int  gem_init();
void gem_exit();
int  get_image();
int  is_cookie();
int  put_image();
int  rect_equal();
int  rect_overlay();
int  release_image();


/* In dieser Datei aufgerufene Funktionen
 * -------------------------------------- */
extern    int  appl_init();
/*        void appl_exit(); */
extern    int  graf_handle();
extern    int  graf_mouse();
/*        long Malloc(); */
/*        long Mfree(); */
/*        void v_clsvwk(); */
/*        void v_opnvwk(); */
/*        void vq_extnd(); */
/*        void vro_cpyfm(); */


/* Globale Felder, die vom VDI benutzt werden
 * ------------------------------------------ */
extern    int  ap_id,vdi_handle,work_in[12],work_out[57],contrl[12];
extern    int  intin[128],ptsin[128],intout[128],ptsout[128],global[15];


/* allgemeine globale Felder
 * ------------------------- */
int       Prog_End;
int       fd_nplanes;
extern    ACT  aktuell,before;


/* #########################################
 * G E M - I n i t i a l i s i e r u n g e n
 * #########################################
 *
 * Autor:  Volker Nawrath
 * 
 *         Version 1.10  vom 01.08.91
 *
 * RÅckgabewerte:  0 = kein Fehler
 *                -1 = Applikation konnte nicht angemeldet werden
 * -------------------------------------------------------------- */
int  gem_init()
{
     int  gr_1,gr_2,gr_3,gr_4,i;
        
     /* Anwendung anmelden
      * ------------------ */
     ap_id = appl_init();
     if (ap_id == -1)
     {
          /* Applikation konnte nicht angemeldet werden
           * ------------------------------------------ */
          return(-1);
     }

     Prog_End = FALSE;

     /* Handle des Bildschirms, wird vom Windowmanager benîtigt
      * ------------------------------------------------------- */
     vdi_handle = graf_handle(&gr_1,&gr_2,&gr_3,&gr_4);

     /* virtuelle Arbeitsstation fÅr VDI îffnen
      * --------------------------------------- */
     for (i=0;i<10;work_in[i++] = 1);
          work_in[10] = 2;
     v_opnvwk(work_in,&vdi_handle,work_out);

     /* Bildschirmauflîsung feststellen
      * ------------------------------- */
     aktuell.screen_w = work_out[0] + 1;
     aktuell.screen_h = work_out[1] + 1;

     if (aktuell.screen_w==HIGH_W && aktuell.screen_h==HIGH_H)
          aktuell.aufloesung = HIGH_REZ;
     else if (aktuell.screen_w==MID_W && aktuell.screen_h==MID_H)
          aktuell.aufloesung = MID_REZ;
     else if (aktuell.screen_w==LOW_W && aktuell.screen_h==LOW_H)
          aktuell.aufloesung = LOW_REZ;
     else if (aktuell.screen_w==TT_HIGH_W && aktuell.screen_h==TT_HIGH_H)
          aktuell.aufloesung = TT_HIGH_REZ;
     else if (aktuell.screen_w==TT_MID_W && aktuell.screen_h==TT_MID_H)
          aktuell.aufloesung = TT_MID_REZ;
     else if (aktuell.screen_w==TT_LOW_W && aktuell.screen_h==TT_LOW_H)
          aktuell.aufloesung = TT_LOW_REZ;
     else
          aktuell.aufloesung = OTHERREZ;

     /* Den MFDB des Bildschirms initialisieren
      * --------------------------------------- */
     vq_extnd(vdi_handle,1,work_out);
     fd_nplanes = work_out[4];
     aktuell.monitor.fd_addr       = 0L;
     aktuell.monitor.fd_w          = 0;
     aktuell.monitor.fd_h          = 0;
     aktuell.monitor.fd_wdwidth    = 0;
     aktuell.monitor.fd_stand      = 0;
     aktuell.monitor.fd_nplanes    = 0;
     aktuell.monitor.fd_r1         = 0;
     aktuell.monitor.fd_r2         = 0;
     aktuell.monitor.fd_r3         = 0;

     /* restl. aktuell - Bereich initialisieren
      * --------------------------------------- */
     aktuell.neu_pix.g_x      = 0;
     aktuell.neu_pix.g_y      = 0;
     aktuell.neu_pix.g_w      = 0;
     aktuell.neu_pix.g_h      = 0;
     aktuell.neu_doc.g_x      = 0L;
     aktuell.neu_doc.g_y      = 0L;
     aktuell.neu_doc.g_w      = 0L;
     aktuell.neu_doc.g_h      = 0L;
     aktuell.max_user_wind    = 0;
     aktuell.anzahl           =  0;
     aktuell.windanz          =  0;
     aktuell.handle           = -1;
     aktuell.text_x  = gr_1; /* horizontale Grîûe des Zeichensatzes  */
     aktuell.text_y  = gr_2; /* vertikale Grîûe des Zeichensatzes       */
     aktuell.menu_y  = gr_4; /* vertikale Grîûe einer Zeichenzelle   */
     
     /* Feststellen, ob Multitasking-Betriebssystem vorliegt
      * ---------------------------------------------------- */
     if (global[1] != 1)
          aktuell.multitsk = TRUE;
     else
          aktuell.multitsk = FALSE;

     /* Bereich "before." initialisieren
      * -------------------------------- */
     before.multitsk               = aktuell.multitsk;
     before.max_user_wind          = before.max_user_wind;
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

     return(0);

} /* ENDE gem_init() */



/* ##################################################
 * P r o g r a m m    v o m   A E S   a b m e l d e n
 * ##################################################
 *
 * Autor:  Volker Nawrath
 * 
 *         Version 1.01  vom 22.09.91
 *
 * RÅckgabewerte:  keine
 * -------------------------------------------------- */
void gem_exit()
{
     /* Virtuellen Bildschirm schlieûen
      * ------------------------------- */
     v_clsvwk(vdi_handle);

     /* Applikation abmelden
      * -------------------- */
     appl_exit();

} /* ENDE gem_exit() */



/* ###########################################################
 * g e t _ i m a g e ( )   --   Bildschirmausschnitt speichern
 * ###########################################################
 *
 * Autor                  : Egbert Bîmers
 *                          ST-Computer Februar '90, Seite 91 ff.
 *                          entwickelt mit Turbo-C
 *
 * Anpassung "GEM-Manager",
 * und erweitert          : Volker Nawrath
 *
 *                          Version 1.00  vom 01.08.91
 *
 * RÅckgabewerte:   0 = kein Fehler
 *                 -1 = fehlerhafte Koordinaten
 *                 -2 = nicht genÅgend Speicher
 * ----------------------------------------------------------- */
int  get_image(x0,y0,x1,y1,g_image)
     int       x0,y0;    /* linke, obere Ecke des Ausschnitts    */
     int       x1,y1;    /* rechte, untere Ecke des Ausschnitts  */
     IMAGE     *g_image; /* Zeiger auf Strukt.f.gesp.Ausschnitt  */
{
     FDB  getbuf;        /* Zwischenspeicher fÅr Bildausschnitt  */
     long memory;        /* Zeiger auf Bildausschnitt            */
     long anzahl_byte;   /* Grîûe d.z.reserv.Speichers in Byte   */
     int  pixhoehe;      /* Pixelhîhe des Rechtecks              */
     int  pixbreite;     /* Pixelbreite des Rechtecks            */
     int  pix;           /* Anzahl Pixel pro Byte                */
     int  pxyar[8];      /* Koordinaten fÅr vro_cpyfm()          */

     /* Struktur fÅr Bildschirmausschnitt initialisieren, damit
      * im Fehlerfall definierte Werte darin stehen
      * ------------------------------------------------------- */
     g_image->getbuf = 0L;
     g_image->breite = 0;
     g_image->hoehe  = 0;
        
     /* Anzahl Pixel pro Byte berechnen
      * ------------------------------- */
     pix = 8 / fd_nplanes;

     /* Pixelbreite, durch 16 teilbar, und Pixelhîhe ausrechnen
      * ------------------------------------------------------- */
     pixbreite = ((x1-x0)+16) & 0xFFF0;
     pixhoehe  = y1-y0;
     
     if ((pixbreite <= 0)        ||  (pixhoehe <= 0)         ||
         (x1 >= aktuell.screen_w) ||  (y1 >= aktuell.screen_h)   )
     {
          /* fehlerhafte Koordinaten, Funktion abbrechen
           * ------------------------------------------- */
          return(-1);
     }

     /* Grîûe des benîtigten Speichers errechnen und reservieren
      * -------------------------------------------------------- */
     pxyar[0] = x0;
     pxyar[1] = y0;
     pxyar[2] = x1;
     pxyar[3] = y1;
     pxyar[4] = 0;
     pxyar[5] = 0;
     pxyar[6] = x1-x0;
     pxyar[7] = pixhoehe;

     anzahl_byte=(long)(pixbreite / pix) * (long)(pixhoehe + 1) + (long)8;
     memory = Malloc((long)(anzahl_byte * sizeof(char)));          

     if ((memory == 0L) || (memory < 0L))
     {
          /* Fehler, da nicht genÅgend Speicherplatz vorhanden
           * ------------------------------------------------- */
          return(-2);
     }

     /* Bildschirmausschnitt speichern
      * ------------------------------ */
     g_image->breite     = x1-x0;
     g_image->hoehe      = pixhoehe;
     g_image->getbuf     = memory;
     getbuf.fd_addr      = memory;
     getbuf.fd_w         = pixbreite;
     getbuf.fd_h         = pixhoehe + 1;
     getbuf.fd_wdwidth   = pixbreite / 16;
     getbuf.fd_stand     = 1;
     getbuf.fd_nplanes   = fd_nplanes;
     getbuf.fd_r1        = 0;
     getbuf.fd_r2        = 0;
     getbuf.fd_r3        = 0;

     vro_cpyfm(vdi_handle,3,pxyar,&aktuell.monitor,&getbuf);

     return(0);

} /* ENDE get_image() */



/* #############################################################
 * p u t _ i m a g e ( )   --   gesp. Ausschnitt zurÅckschreiben
 * #############################################################
 *
 * Autor                  : Egbert Bîmers
 *                          ST-Computer Februar '90, Seite 91 ff.
 *                          entwickelt mit Turbo-C
 *
 * Anpassung Mark Williams
 * C und den"GEM-Manager",
 * Erweiterung d. Fkt.    : Volker Nawrath
 *
 *                          Version 1.10  vom 29.11.92
 *
 * RÅckgabewerte:   0 = kein Fehler
 *                 -2 = Koordinaten f.gewÑhlten Ausschn.falsch
 *                 -3 = keine Adresse fÅr Ausschnitt vorhanden
 * ------------------------------------------------------------- */
int  put_image(x0,y0,x1,y1,x2,y2,p_image,mode)
     int       x0,y0;         /* Zielkoordinaten                 */
     int       x1,y1,x2,y2;   /* Rechteck im Ausschnitt          */
     IMAGE     *p_image;      /* Zeiger auf gesp. Ausschnitt     */
     int       mode;          /* log. VerknÅpfung Quell- und
                               * Zielraster                      */
{
     FDB  getbuf;        /* Zwischensp. f. Ausschnitt       */
     int  pxyar[8];      /* Koordinaten fÅr vro_cpyfm()     */
     int  breite,hoehe;  /* Zwischenspeicher                */

     if ((x1 == 0) && (y1 == 0) && (x2 == 0) && (y2 == 0))
     {
          /* Der gesamte Ausschnitt soll kopiert werden
           * ------------------------------------------ */
          breite = p_image->breite;
          hoehe  = p_image->hoehe;
          x2     = breite;
          y2     = hoehe;
     }
     else
     {
          /* Teil des Ausschnitts soll kopiert werden
           * ---------------------------------------- */
          breite = x2 - x1;
          hoehe  = y2 - y1;
     }

     /* Breite und Hîhe anpassen, wenn Ausschnitt aus Bildschirm ragt
      * ------------------------------------------------------------- */
     if ((x0 + breite > aktuell.screen_w))
     {
          breite = aktuell.screen_w - x0;
          x2 = x1 + breite;
     }
     if ((y0 + hoehe > aktuell.screen_h))
     {
          hoehe = aktuell.screen_h - y0;
          y2 = y1 + hoehe;
     }


     if ((breite < 0) || (hoehe < 0)     ||
         (x1 + breite > p_image->breite) ||
         (y1 + hoehe  > p_image->hoehe)      )
     {
          /* Koordinaten fÅr gewÑhlten Ausschnitt falsch
           * ------------------------------------------- */
          return(-2);
     }
     
     if ((p_image->getbuf == 0L) || (p_image->getbuf < 0L))
     {
          /* Kein Zeiger auf Ausschnitt vorhanden, Funktion
           * muû abgebrochen werden
           * ---------------------------------------------- */
          return(-3);
     }
     /* Ausschnitt auf Bildschirm bringen
      * --------------------------------- */
     pxyar[0] = x1;
     pxyar[1] = y1;
     pxyar[2] = x2;  /* Wurden angepaût, wenn gesamter Ausschnitt */
     pxyar[3] = y2;  /* kopiert werden soll                       */
     pxyar[4] = x0;
     pxyar[5] = y0;
     pxyar[6] = x0 + breite;
     pxyar[7] = y0 + hoehe;
                
     getbuf.fd_addr      = p_image->getbuf;
     getbuf.fd_w         = (p_image->breite + 16) & 0xFFF0;
     getbuf.fd_h         = p_image->hoehe + 1;
     getbuf.fd_wdwidth   = getbuf.fd_w / 16;
     getbuf.fd_nplanes   = fd_nplanes;
                
     vro_cpyfm(vdi_handle,mode,pxyar,&getbuf,&aktuell.monitor);
                
     return(0);
        
} /* ENDE put_image() */



/* #######################################################
 * r e l e a s e _ i m a g e ( )   --   Speicher freigeben
 * #######################################################
 *
 * Autor:  Volker Nawrath
 *
 *         Version 1.00  vom 01.08.91
 *
 * RÅckgabewerte:   0 = kein Fehler
 *                 -1 = kein Zeiger auf Ausschnitt vorhanden
 *                 -2 = Speicher konnte nicht freigegeben werden
 * ------------------------------------------------------------- */
int  release_image(r_image)
     IMAGE     *r_image; /* Zeiger auf gespeich. Ausschnitt  */
{
     long  fehler;
        
     if ((r_image->getbuf == 0L) || (r_image->getbuf < 0L))
     {
          /* Keine Adresse fÅr Ausschnitt; Funktion abbrechen
           * ------------------------------------------------ */
          return(-1);
     }

     /* Speicher freigeben
      * ------------------ */
     fehler = Mfree(r_image->getbuf);

     if (fehler != 0L)
     {
          /* Speicher konnte nicht freigegeben werden
           * ---------------------------------------- */
          return(-2);
     }
     else
     {
          /* Speicher freigegeben; nicht mehr benîtigte Struktur
           * "leeren" = initialisieren
           * -------------------------------------------------- */
          r_image->getbuf = 0L;
          r_image->breite = 0;
          r_image->hoehe  = 0;
          return(0);
     }

} /* ENDE release_image() */



/* #####################################################
 * r e c t _ e q u a l  --   Gleichheit zweier Rechtecke
 * #####################################################
 *
 * Autor:  Volker Nawrath
 *
 *         Version 1.00  vom 29.11.92
 *
 * RÅckgabewerte:    0 (FALSE) = keine Gleichheit
 *                   1 (TRUE)  = Rechtecke stimmen exakt Åberein
 * ----------------------------------------------------------------- */

int  rect_equal(p1, p2)
     RECT *p1, *p2;
{
     if((p1->g_x != p2->g_x) ||
        (p1->g_y != p2->g_y) ||
        (p1->g_w != p2->g_w) ||
        (p1->g_h != p2->g_h)) return(FALSE);
          return(TRUE);

} /* ENDE: rect_equal() */


/* ##########################################################
 * r e c t _ o v e r l a y  --   öberlappung zweier Rechtecke
 * ##########################################################
 *
 * Autor:  Volker Nawrath
 *
 *         Version 1.00  vom 29.11.92
 *
 * RÅckgabewerte:    0 (FALSE) = keine öberlappung
 *                   1 (TRUE)  = öberlappung; Koordinaten und Grîûe
 *                               der gemeinsamen FlÑche wird im
 *                               ersten öbergabeparameter mitgegeben
 * ----------------------------------------------------------------- */

int  rect_overlay(a,b)
     RECT *a,*b;
{
     RECT aa;
     
     aa.g_x = a->g_x;
     aa.g_y = a->g_y;
     aa.g_w = a->g_w;
     aa.g_h = a->g_h;
     
     /* linke obere Ecke
      * ---------------- */
     aa.g_x = _max(a->g_x,b->g_x);
     aa.g_y = _max(a->g_y,b->g_y);

     /* rechte untere Ecke
      * ------------------ */
     aa.g_w = _min((a->g_x + a->g_w), (b->g_x + b->g_w));
     aa.g_h = _min((a->g_y + a->g_h), (b->g_y + b->g_h));

     if ((aa.g_w > aa.g_x) && (aa.g_h > aa.g_y))
     {
          aa.g_w -= aa.g_x;   /* Breite */
          aa.g_h -= aa.g_y;   /* Hîhe   */
          a->g_x = aa.g_x;
          a->g_y = aa.g_y;
          a->g_w = aa.g_w;
          a->g_h = aa.g_h;
          return(TRUE);
     }
     else
     {
          return(FALSE);
     }

} /* ENDE: rect_overlay() */


/* #####################################################
 * i s _ c o o k i e ( )   --   Abfrage auf Cookie-Werte
 * #####################################################
 *
 * Autor:      Volker Nawrath
 *
 *             Version 1.00 vom 29.11.92
 *
 * öbergabewerte:   cookie = Kennung des Eintrages (32 Bit)
 *                  value  = Nullpointer (0L) oder Pointer auf Wert
 *                           des Cookiejar's (Inhalt abhÑngig von
 *                           Cookie-Anwendung)
 *
 * RÅckgabewerte:   TRUE  = Cookie ist installiert
 *                  FALSE = Cookie nicht installert
 *
 *                  value = Wert des Cookies (AbhÑngig von Anwendung),
 *                          Wurde 0L Åbergeben, bleibt value leer
 * ------------------------------------------------------------------ */

int  is_cookie(cookie,value)
     long cookie;
     long *value;
{
     long      old_stack;
     COOKIE    *cookiejar;

     /* Zeiger auf Cookiejar holen
      * -------------------------- */
     old_stack = Super(0L);
     cookiejar = (COOKIE *)(*((long *)(0x5a0L)));
     Super(old_stack);

     /* Cookiejar Åberhaupt vorhanden ?
      * ------------------------------- */
     if (cookiejar->cookie == 0L)
          return(FALSE);

     do
     {    
          /* Liste nach gewÅnschter Kennung durchsuchen
           * ------------------------------------------ */
          if(cookiejar->cookie == cookie)
          {
               /* nur eintragen, wenn "value" kein Nullpointer
                * -------------------------------------------- */
               if (value)
                    *value =  cookiejar->cookiejar;
               return(TRUE);
          }

          /* NÑchster Eintrag in Cookiejar-Liste
           * ----------------------------------- */
          cookiejar++;
     
     } while(cookiejar->cookie != 0L);

     return(FALSE);

} /* ENDE: is_cookie() */

