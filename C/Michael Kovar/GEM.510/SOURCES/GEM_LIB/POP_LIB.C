/*--------------------------------------------------------*/
/*              p o p _ l i b . c                         */
/*        ------------------------------                  */
/*                                                        */
/*   Funktion zum Programmieren von Popup-Menus unter     */
/*   Benutzung des Event-Managers.                        */
/*                                                        */
/*   Version 2.10   vom 29.11.92                          */
/*                                                        */
/*   entwickelt auf ATARI 1040 ST                         */
/*               ATARI TT 030                             */
/*           mit Mark Williams C   Version 3.09           */
/*                                                        */
/*   (c) 1991  by Volker Nawrath                          */
/*--------------------------------------------------------*/


#include <aesbind.h>
#include <event.h>
#include <gemsys.h>
#include <vdibind.h>


/* Funktionen in dieser Programmdatei
 * ---------------------------------- */
int  draw_menu();
void get_parameter();
int  popup_menu();
void save_parameter();
void zeichne_invers_box();
void zeichne_menubox();
void zeichne_linie();


/* Externe Funktionen
 * ------------------ */
extern    int  get_image();
extern    int  graf_mouse();
extern    int  put_image();
extern    int  release_image();
extern    int  strlen();
extern    char *strncat();
/*   void v_bar();       */
/*   int  v_dspcur();         */
extern    void v_event();
extern    void v_evntinit();
/*   void p_line();      */
/*   void vsf_color();        */
/*   void vsf_interior();          */
/*   void vsf_perimeter();    */
/*   void vsf_style();        */
/*   void vsl_ends();         */
/*   int  vsl_type();         */
/*   void vsl_width();        */
/*   void vst_alignment();    */
/*   int  vst_effects();      */
/*   int  vswr_mode();        */


/* Globale Felder
 * -------------- */
extern    int  ap_id,vdi_handle;                  /* Globale Felder    */
extern    int  work_in[12],work_out[57];          /* fr die Benutzung */
extern    int  contrl[12],intin[128],ptsin[128];  /* des VDI           */
extern    int  intout[128],ptsout[128];           /*                   */

extern    EVNT           event;         /* šbergabe- , Rckgabefelder  */
extern    EVNT_RETURN    event_return;  /* des Event-Managers          */

extern    ACT  aktuell;                 /* Bereich fr Systemwerte     */


/* Globale Felddefinitionen
 * ------------------------ */
static    int  m_zeile;                 /* Anzahl Zeilen, ohne Menzeile   */
static    int  m_columns;               /* Anzahl Spalten                  */
static    int  m_x,m_y,m_b,m_h;         /* Koordinaten, Gr”e fr Menbox  */
static    int  m_wx1,m_wy1,m_wx2,m_wy2; /* Bereich der Meneintr„ge        */
static    int  m_maxlength;             /* Breite Menzelle in Zeichen     */
static    int  m_b1;                    /* Breite  Menzelle in Pixel      */
static    char *m_text;                 /* Zeiger auf String der Meneintr.*/
static    char m_tabelle[100][82];      /* Array fr Meneintr„ge          */
static    IMAGE     m_backround;        /* Gespeicherter Hintergrund       */
static    EVNT m_event_save;            /* gesicherte šbergabewerte fr den
                                         * Event-Manager                   */


/* Popup-Men kontrollieren
 * ######################## */
int  popup_menu(x,y,columns,text)
     int  x,y;      /* Koordinaten fr Popup-Menu           */
     int  columns;  /* Anzahl von Textspalten des Mens     */
     char *text;    /* Text fr Menzeilen                  */
{
     int  fehler;        /* Returnwert von draw_menu()      */
     int  menu;          /* selektierter Meneintrag        */
     int  nmenu;         /* Neuer Meneintrag               */
     int  n1;            /* Zeile, in der Mauszeiger steht  */
     int  n2;            /* Spalte, in der der Mausz. steht */
     int  menubox[4];    /* Rechteck des Meneintrages, der
                          * zuletzt selektiert wurde        */
     int  xyarray[4];    /* Koordinaten neuer Meneintrag   */
     int  mx,my;         /* Mausdatenkoordinaten            */
 
     /* Parameterkontrolle
      * ------------------ */
     if (columns <= 0)
     {
          return(-1);
     }
     else if ((x > (aktuell.screen_w - 1))   ||
           (x < 0)                           ||
           (y > (aktuell.screen_h - 1))      ||
           (y < aktuell.menu_y)         )
     {
          return(-5);
     }
     
     /* Allgemeine Initialisierungen
      * ---------------------------- */
     save_parameter();
     menu      = 0;
     nmenu     = 0;
     n1        = 0;
     n2        = 0;
     m_x       = x;
     m_y       = y;
     m_columns = columns;
     m_text    = text;

     /* Menbox zeichnen
      * ---------------- */
     wind_update(BEG_UPDATE);
     wind_update(BEG_MCTRL);
     fehler = draw_menu();
     if (fehler != 0)
          return(fehler);

     /* Event-Manager initialisieren; warten, bis linker Maus-
      * knopf gedrckt oder das Rechteck mit den Meneintr„gen
      * betreten wird
      * ------------------------------------------------------ */
     v_evntinit(0);
     v_evntinit(1);
     event.event       = (MU_BUTTON | MU_MESAG | MU_M1 | MU_M2);
     event.clicks      = 1;
     event.state       = 1;
     event.button      = 1;
     event.m1inout     = 0;
     event.m2inout     = 1;
     event.rectangle1.x = m_wx1;
     event.rectangle1.y = m_wy1;
     event.rectangle1.w = m_wx2 - m_wx1 + 1;
     event.rectangle1.h = m_wy2 - m_wy1 + 1;
     event.rectangle2.x = m_x;
     event.rectangle2.y = m_y;
     event.rectangle2.w = m_b;
     event.rectangle2.h = m_h;

     for(;;)
     {
          v_event();
          
          if (EVNT_BUTTON())
          {
               /* Mausknopf wurde gedrckt, die Endlosschleife
			 * kann also verlassen werden.
                * --------------------------------------------- */
               break;
          }
          
          /* Mauskoordinaten
           * --------------- */
          mx = event_return.mouse_x;
          my = event_return.mouse_y;

          if (EVNT_M2())
          {
               if (mx < m_x)
                    mx = m_x;
               if (my < m_y)
                    my = m_y;
               if (mx > (m_x + m_b - 1))
                    mx = m_x + m_b - 1;
               if (my > (m_y + m_h)- 1)
                    my = m_y + m_h - 1;
               graf_mouse(M_OFF,0L);
               v_dspcur(vdi_handle,mx,my);
               graf_mouse(M_ON,0L);
               continue;
          }

          /* Mauszeiger verl„t des Bereich eines Meneintrages
           * -------------------------------------------------- */
          if ((mx<=m_wx1)||(mx>=m_wx2)||(my<=m_wy1)||(my>=m_wy2))
          {
               /* Mauszeiger befindet sich auerhalb des
                * Rechtecks fr die Meneintr„ge. Alten
                * Eintrag deselektieren.
                * -------------------------------------- */
               if ((menu != 0)                  &&
                   (m_tabelle[menu][0] != '-')  &&
                   (m_tabelle[menu][0] != '\0')   )
               {
                    /* Mauszeiger ausschalten
                     * ---------------------- */
                    graf_mouse(M_OFF,0L);

                    /* Letzten angew„hlten Menpunkt wieder
                     * normal darstellen
                     * ----------------------------------- */
                    zeichne_invers_box(menubox);
                    menu = 0;

                    /* Mauszeiger einschalten
                     * ---------------------- */
                    graf_mouse(M_ON,0L);
               }

               /* Event-Manager initialisieren; warten, bis
                * der Mauszeiger sich im Rechteck mit den
                * Meneintr„gen befinden
                * ----------------------------------------- */
               event.m1inout      = 0;
               event.rectangle1.x = m_wx1;
               event.rectangle1.y = m_wy1;
               event.rectangle1.w = m_wx2 - m_wx1 + 1;
               event.rectangle1.h = m_wy2 - m_wy1 + 1;

               /* An den Anfang der Warteschleife gehen
                * ------------------------------------- */
               continue;
               
          }

          /* Der Mauszeiger befindet sich ber einem neuen
           * Meneintrag. Alle anderen M”glichkeiten sind
           * vorher abgefangen.
           * --------------------------------------------- */
          n1    = (my-m_wy1)/aktuell.text_y+1;
          nmenu = n1+(int)((mx-m_x)/(int)(m_b/m_columns))*m_zeile;

          /* Den vorher angew„hlten Meneintrag deselektieren
           * ------------------------------------------------ */
          if ((menu != 0)                &&
              (m_tabelle[menu][0] != '-')  &&
              (m_tabelle[menu][0] != '\0')   )
          {
               /* Mauszeiger ausschalten
                * ---------------------- */
               graf_mouse(M_OFF,0L);

               /* Vorigen Meneintrag wieder normal zeichnen
                * ------------------------------------------ */
               zeichne_invers_box(menubox);

               /* Mauszeiger einschalten
                * ---------------------- */
               graf_mouse(M_ON,0L);

          }

          /* Koordinaten und Gr”e des neuen Eintrages
           * ----------------------------------------- */
          n1 = (my-m_wy1)/aktuell.text_y+1;
          n2 = (int)((mx-m_x)/(int)(m_b/m_columns))+1;
          xyarray[0] = m_x+((n2-1)*(m_b/m_columns))+1;
          xyarray[1] = m_wy1+((n1-1)*aktuell.text_y);
          xyarray[2] = xyarray[0]+m_b1-2;
          xyarray[3] = xyarray[1]-1+aktuell.text_y;

          /* Auswahlbalken nur dann zeichnen, wenn es sich um
           * einen anw„hlbaren Meneintrag handelt
           * ------------------------------------------------ */
          if ((m_tabelle[nmenu][0] != '-') &&
              (m_tabelle[nmenu][0] != '\0')  )
          {
               /* Mauszeiger ausschalten
                * ---------------------- */
               graf_mouse(M_OFF,0L);

               /* Schwarzen Auswahlbalken zeichnen
                * -------------------------------- */
               menubox[0] = xyarray[0];
               menubox[1] = xyarray[1];
               menubox[2] = xyarray[2];
               menubox[3] = xyarray[3];
               zeichne_invers_box(menubox);

               /* Mauszeiger einschalten
                * ---------------------- */
               graf_mouse(M_ON,0L);
          }

                         
          /* Ausgew„hlten Meneintrag zwischenspeichern
           * ------------------------------------------ */
          menu = nmenu;

          /* Event-Manager initialisieren; warten, bis der Maus-
           * zeiger das Rechteck des selektierten Meneintrages
           * verl„t
           * --------------------------------------------------- */
          event.m1inout     = 1;
          event.rectangle1.x = xyarray[0];
          event.rectangle1.y = xyarray[1];
          event.rectangle1.w = xyarray[2]-xyarray[0]+1;
          event.rectangle1.h = xyarray[3]-xyarray[1]+1;

     } /* ENDE for(;;) */

     /* Mauszeiger ausschalten
      * ---------------------- */
     graf_mouse(M_OFF,0L);

     /* Hintergrund restaurieren
      * ------------------------ */
     put_image(m_x,m_y,0,0,0,0,&m_backround,3);
     release_image(&m_backround);

     /* Mauszeiger einschalten
      * ---------------------- */
     graf_mouse(M_ON,0L);
     wind_update(END_MCTRL);
     wind_update(END_UPDATE);

     /* Prfen, ob Meneintrag selektierbar ist. Wenn ja, wir
      * die Nummer des Eintrages zurckgegeben, ansonsten Null.
      * ------------------------------------------------------- */
     if ((menu != 0)  &&
         ((m_tabelle[menu][0] == '-')  ||
          (m_tabelle[menu][0] == '\0')   ) )
     {
          menu = 0;
     }

     get_parameter();
     return(menu);

} /* ENDE popup_menu() */


/* Popup-Men zeichnen und aufbauen
 * ################################ */
int  draw_menu()
{
     int  m_eintraege;        /* Anzahl der Meneintr„ge         */
     int  xyarray[4];         /* Koorinaten, Gr”e               */
     int  i,ii,k;             /* Z„hlfelder                      */
     int  s_horiz,s_vert;     /* Felder fr VDI-Funktion         */
     int  fehler;             /* Fehlernummer fr Fkt-Rckgabe   */
     char *p;                 /* Zeiger auf Zeichen              */
     char *hellmenu;          /* Zeiger auf hellen Menueintrag   */

     /* Allgemeine Initialisierungen
      * ---------------------------- */
     for (i=0;i<=99;i++)
     {
          for (ii=0;ii<=81;ii++)
               m_tabelle[i][ii] = '\0';
     }
     fehler        = 0;
     m_eintraege = 0;
     m_maxlength = 0;
     p = m_text;
          
     /* Meneintr„ge trennen und im Array unterbringen. Im Element
      * mit dem Index Null wird der Titel des Mens untergebracht
      * ---------------------------------------------------------- */
     for (i=0;i<=99;i++)
     {
          /* Einen Meneintrag zusammenstellen
           * --------------------------------- */
          while((*p != '|') && (*p != '\0'))
          {
               strncat(m_tabelle[i],p,(unsigned)1);
               p++;
          }

          /* Wenn es sich um die Men-šberschrift handelt,
           * n„chsten Eintrag lesen
           * --------------------------------------------- */
          if ((m_eintraege == 0) && (*p != '\0'))
          {
               p++;
               m_eintraege++;
               continue;
          }

          /* Zuordnung der Eintr„ge beenden, wenn Zeiger am
           * Textende angelangt ist
           * ---------------------------------------------- */
          if (*p == '\0')
               break;

          /* Maximale L„nge der Meneintr„ge feststellen
           * ------------------------------------------- */
          if (*m_tabelle[m_eintraege] == '-')
          {
               m_maxlength = _max(m_maxlength,
                    strlen(m_tabelle[m_eintraege]) - 1);
          }
          else
          {    m_maxlength = _max(m_maxlength,
                    strlen(m_tabelle[m_eintraege]));
          }
          
          m_eintraege++;
          p++;
     }

     /* Parameterkontrolle
      * ------------------ */
     if (m_eintraege == 0)
          fehler = -2;
     else if (m_eintraege < m_columns)
          fehler = -4;
     if (fehler != 0)
          return(fehler);
          
     /* Boxgr”e errechnen
      * ------------------ */
     m_zeile = (int)((double)m_eintraege/(double)m_columns+0.999999);
     m_maxlength = _max(((strlen(m_tabelle[0])/m_columns)-m_columns+2),
                           m_maxlength);
     m_b1 = m_maxlength * aktuell.text_x;
     m_b  = m_b1 * m_columns;
     m_h  = (m_zeile * aktuell.text_y) + aktuell.menu_y + 1;
     m_x  = _max(_min(aktuell.screen_w-1-m_b,m_x),0);
     m_y  = _max(_min(aktuell.screen_h-1-m_h,m_y),0);

     /* Parameterkontrolle
      * ------------------ */
     if ((m_b > (aktuell.screen_w - 1)) ||
         (m_h > (aktuell.screen_h - aktuell.menu_y - 1)))
          return(-3);

     /* Bereich in Menbox ermitteln, in der die Eintr„ge stehen
      * -------------------------------------------------------- */
     m_wx1 = m_x;
     m_wx2 = m_x + m_b;
     m_wy1 = m_y + aktuell.menu_y + 1;
     m_wy2 = m_y + m_h;

     /* Mauszeiger ausschalten
      * ---------------------- */
     graf_mouse(M_OFF,0L);

     /* Hintergrund unter Menubox retten
      * -------------------------------- */
     xyarray[0] = m_x;
     xyarray[1] = m_y;
     xyarray[2] = m_x + m_b;
     xyarray[3] = m_y + m_h;
     fehler = get_image(xyarray[0],xyarray[1],xyarray[2],xyarray[3],
                  &m_backround);
     if (fehler == -2)
     {
          /* Nicht gengend Speicher fr den Hintergrund
           * ------------------------------------------- */
          return(-6);
     }
     
     /* Menbox zeichnen
      * ---------------- */
     zeichne_menubox(xyarray);

     /* Trennlinie zwischen Titel und Menueintr„gen
      * ------------------------------------------- */
     xyarray[1] = m_wy1 - 1;
     xyarray[3] = xyarray[1];
     zeichne_linie(xyarray);
     
     /* Trennlinien zwischen Spalten
      * ---------------------------- */
     if (m_columns > 1)
     {
          for (i=1;i<=(m_columns-1);i++)
          {
               xyarray[0] = m_x + (m_b / m_columns)*i;
               xyarray[1] = m_wy1;
               xyarray[2] = xyarray[0];
               xyarray[3] = m_wy2;
               zeichne_linie(xyarray);
          }
     }

     /* Ausrichtung des Grafiktextes nach der Baseline
      * schwarze Schrift, normaler Schrifttyp
      * ---------------------------------------------- */
     vst_alignment(vdi_handle,0,0,&s_horiz,&s_vert);
     vst_color(vdi_handle,1);
     vst_effects(vdi_handle,0);
     vswr_mode(vdi_handle,2);
     
     /* Titeltext ausgeben
      * ------------------ */
     xyarray[0] = m_x+((m_b-(strlen(m_tabelle[0])*aktuell.text_x))/2);
     xyarray[1] = m_y+aktuell.text_y;
     v_gtext(vdi_handle,xyarray[0],xyarray[1],m_tabelle[0]);

     /* Ausrichtung des Grafiktextes nach der Bottom Line
      * ------------------------------------------------- */
     vst_alignment(vdi_handle,0,3,&s_horiz,&s_vert);

     /* Meneintr„ge ausgeben
      * --------------------- */
     k = 1;
     for (i=1;i<=m_columns;i++)
     {
          for (ii=1;ii<=m_zeile;ii++)
          {
               xyarray[0] = m_x + (m_b / m_columns) * (i - 1);
               xyarray[1] = m_wy1 + (ii * aktuell.text_y) - 1;

               if (m_tabelle[k][0] == '-')
               {
                    /* Menueintrag mit heller Schrift
                     * ------------------------------ */
                    hellmenu = m_tabelle[k];
                    hellmenu++;
                    vst_effects(vdi_handle,2);
                    v_gtext(vdi_handle,xyarray[0],xyarray[1],
                                 hellmenu);
               }
               else
               {
                    /* Menueintrag mit schwarzer Schrift
                     * --------------------------------- */
                    vst_effects(vdi_handle,0);
                    v_gtext(vdi_handle,xyarray[0],xyarray[1],
                                 m_tabelle[k]);
               }

               /* N„chster Meneintrag
                * -------------------- */
               k++;

          } /* ENDE for(ii=1;ii<_m_zeile;i++) */

     } /* ENDE for(i=1;i<=m_columns;i++) */

     /* Mauszeiger ausschalten
      * ---------------------- */
	graf_mouse(M_ON,0L);

     return(0);

} /* ENDE draw_menu() */


/* Werte des Event-Managers und Attribute des VDI wiederherstellen
 * ############################################################### */
void get_parameter()
{
     event.event         = m_event_save.event;
     event.clicks        = m_event_save.clicks;
     event.state         = m_event_save.state;
     event.button        = m_event_save.button;
     event.m1inout       = m_event_save.m1inout;
     event.rectangle1.x  = m_event_save.rectangle1.x;
     event.rectangle1.y  = m_event_save.rectangle1.y;
     event.rectangle1.w  = m_event_save.rectangle1.w;
     event.rectangle1.h  = m_event_save.rectangle1.h;
     event.m2inout       = m_event_save.m2inout;
     event.rectangle2.x  = m_event_save.rectangle2.x;
     event.rectangle2.y  = m_event_save.rectangle2.y;
     event.rectangle2.w  = m_event_save.rectangle2.w;
     event.rectangle2.h  = m_event_save.rectangle2.h;
     event.lowtime       = m_event_save.lowtime;
     event.hightime      = m_event_save.hightime;
}


/* Werte des Event-Managers und  VDI-Attribute sichern
 * ################################################### */
void save_parameter()
{
     m_event_save.event            = event.event;
     m_event_save.clicks           = event.clicks;
     m_event_save.state            = event.state;
     m_event_save.button           = event.button;
     m_event_save.m1inout          = event.m1inout;
     m_event_save.rectangle1.x     = event.rectangle1.x;
     m_event_save.rectangle1.y     = event.rectangle1.y;
     m_event_save.rectangle1.w     = event.rectangle1.w;
     m_event_save.rectangle1.h     = event.rectangle1.h;
     m_event_save.m2inout          = event.m2inout;
     m_event_save.rectangle2.x     = event.rectangle2.x;
     m_event_save.rectangle2.y     = event.rectangle2.y;
     m_event_save.rectangle2.w     = event.rectangle2.w;
     m_event_save.rectangle2.h     = event.rectangle2.h;
     m_event_save.lowtime          = event.lowtime;
     m_event_save.hightime         = event.hightime;
}


/* Zeichenfunktionen fr das Popup-Men
 * #################################### */
void zeichne_menubox(xyarray)
     int  xyarray[4];
{
     /* Rechteck mit weiem Hintergrund zeichnen
      * ---------------------------------------- */
     vsf_color(vdi_handle,0);
     vsf_interior(vdi_handle,1);
     vsf_style(vdi_handle,8);
     vsf_perimeter(vdi_handle,0);
     vswr_mode(vdi_handle,1);
     v_bar(vdi_handle,xyarray);

     /* Rahmen um das Rechteck zeichnen
      * ------------------------------- */
     vsf_color(vdi_handle,1);
     vsf_interior(vdi_handle,0);
     vsf_perimeter(vdi_handle,1);
     v_bar(vdi_handle,xyarray);
}


void zeichne_linie(xyarray)
     int  xyarray[4];
{
     /* Linie zeichnen
      * -------------- */
     vsf_interior(vdi_handle,0);
     vsl_color(vdi_handle,1);
     vsl_type(vdi_handle,1);
     vsl_width(vdi_handle,1);
     vsl_ends(vdi_handle,0,0);
     vswr_mode(vdi_handle,1);
     v_pline(vdi_handle,2,xyarray);
}


void zeichne_invers_box(xyarray)
     int  xyarray[4];
{
     /* Rechteck mit inversem Farbhintergrund zeichnen
      * ---------------------------------------------- */
     vsf_color(vdi_handle,1);   
     vsf_interior(vdi_handle,1);
     vsf_perimeter(vdi_handle,0);
     vsf_style(vdi_handle,8);
     vswr_mode(vdi_handle,3);
     v_bar(vdi_handle,xyarray);
}

