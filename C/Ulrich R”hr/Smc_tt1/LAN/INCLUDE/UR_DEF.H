/*----------------------------------------------------------------------*/
/* Anbindung der gemeinsamen Programmschnittstelle an OS/2              */
/*----------------------------------------------------------------------*/
#ifndef TRUE
#define TRUE    1
#define FALSE   0
#endif

short   ur_intel_mode( void );
void    ur_help(char* keyword);

short   ur_init(char* progname);
void    ur_exit(void);
short   ur_res_init(void);
void    ur_main_loop(void);

short   ur_menue_init(void (proc(short)));

long    ur_dlg_open(long (proc(long,short,long,long,void**)),long id,short type,char *titel,long flags);
void    ur_modal_loop(long hand);
long    ur_dlg_default(long hand,short msg,long p1,long p2,void **data);
long    ur_dlg_default_leer(long hand,short msg,long p1,long p2,void **data);

void    ur_dlg_set_text(long hand,long id,char *str);
void    ur_dlg_query_text(long hand,long id,char *str);

void    ur_dlg_set_select(long hand,long id,short state);
short   ur_dlg_query_select(long hand,long id);

void	ur_dlg_clr_lbox(long hand,long id);
void	ur_dlg_insert_lbox(long hand,long id,char *text);
short	ur_dlg_query_lbox(long hand,long id);
void 	ur_dlg_query_ltext(long hand,long id,long index,char *str);
void	ur_dlg_begin_lbox(long hand,long id);
void	ur_dlg_end_lbox(long hand,long id);

void    ur_dlg_set_top(long hand);
void    ur_dlg_set_headline(long hand, char *text);

void    ur_draw_text(long hand,long x,long y,char *str);
void    ur_draw_line(long hand,long x,long y,long x1, long y1);
void    ur_draw_rect(long hand,long x,long y,long w,long h,short filltype);
void    ur_draw_circle(long hand,long x,long y,long r,short alfa1,short alfa2);
void    ur_draw_invert(long hand,long x,long y,long w,long h);
void    ur_draw_color(long hand,short color);
void    ur_draw_type(long hand,short type);
void    ur_draw_plane(long hand,long x,long y,long words,long lines,void *data);

long    ur_send_msg(long hand,short msg,long p1,long p2);

void    ur_query_winsize(long hand, short *x,short *y,short *w,short *h);
void    ur_query_framesize(long hand, short *x,short *y,short *w,short *h);
void    ur_set_frame(long hand, short x,short y,short w,short h);
void    ur_set_vsize(long hand,long x,long y);
void    ur_set_vpos(long hand,long x,long y);
void    ur_query_vpos(long hand,long *x,long *y);
void    ur_set_default_framesize(short x,short y,short w,short h);
void    ur_set_default_dlgpos(short x,short y);

long    ur_list_index(long hand);

void    ur_redraw_all(long hand);
void    ur_redraw_region(long hand,long x,long y,long w,long h);

void    ur_timer_start(long hand,short nummer,long msec);
void    ur_timer_stop(long hand,short nummer);
void    ur_timer_indi(long msec,void (proc(void)) );
void    ur_timer_indi_stop(void (proc(void)) );

short   ur_msg(char *msg,short art,short icon);
short   ur_get_file(char *titel,char *pfad, char *name);

short   ur_find_first(char *pfad,char *gefunden);
short   ur_find_next(char *gefunden);

/*----------------------------------------------------------------------*/
/* x_pos ist die Position des Sliders x_len ist die sichtbare laenge    */
/*----------------------------------------------------------------------*/
void    ur_set_slider_x(long hand, long x_pos, long x_len);
void    ur_set_slider_y(long hand, long y_pos, long y_len);

typedef struct
  {
  long  x;
  long  y;
  } point_typ;
  
/*----------------------------------------------------------------------*/
/* Art des zu îffnenden Fensters                                        */
/*----------------------------------------------------------------------*/
#define         UR_TYPE_DIALOG          1
#define         UR_TYPE_WINDOW          2
#define         UR_TYPE_LIST            3

/*----------------------------------------------------------------------*/
/* Flags fÅr das Fenster                                                */
/*----------------------------------------------------------------------*/
#define         UR_FLAGS_NONE           0
#define         UR_FLAGS_MODAL          1      /* Modales Fenster       */
#define         UR_FLAGS_CURSOR         2      /* Cursor wird von appl. gezeichnet */
#define			UR_FLAGS_TOOLBOX		4	   /* Toolbox wird nicht getoppt	*/

/*----------------------------------------------------------------------*/
/* Farben zum Zeichnen                                                  */
/*----------------------------------------------------------------------*/
#define         UR_COLOR_WHITE          0
#define         UR_COLOR_BLACK          1

/*----------------------------------------------------------------------*/
/* Linientypen                                                          */
/*----------------------------------------------------------------------*/
#define         UR_TYPE_BREIT_DURCH     0
#define         UR_TYPE_BREIT_PUNKT     1
#define         UR_TYPE_BREIT_STRICH    2
#define         UR_TYPE_BREIT_STRIPU    3
#define         UR_TYPE_SCHMAL_DURCH     4
#define         UR_TYPE_SCHMAL_PUNKT     5
#define         UR_TYPE_SCHMAL_STRICH    6
#define         UR_TYPE_SCHMAL_STRIPU    7

/*----------------------------------------------------------------------*/
/* Message Box Defines                                                  */
/*----------------------------------------------------------------------*/
#define                 UR_MSG_OK       1       /* nur OK Button        */
#define                 UR_MSG_CANCEL   2       /* Cancel Button        */
#define                 UR_MSG_OKCANCEL 3       /* Beide Knîpfe         */

#define                 UR_MSG_KEINS    0       /* Kein Icon Darstellen */
#define                 UR_MSG_FRAG     2       /* Fragezeichen         */
#define                 UR_MSG_STOP     3       /* Stopschild           */

short ur_msg(char *msg,short art,short icon);

/*----------------------------------------------------------------------*/
/* Definition der Messages an eine Client Prozedur                      */
/*----------------------------------------------------------------------*/

/*----------------------------------------------------------------------*/
/* Diese Message dient zum Neuzeichnen des Fensters. Alle rahmenbed.    */
/* sind erfÅllt ; mit den ur_draw_.. Funktionen kann dann gezeichnet    */
/* werden.                                                              */
/*----------------------------------------------------------------------*/
#define         UR_WM_PAINT     1

/*----------------------------------------------------------------------*/
/* Create wird nach erzeugen der Dialogbox bzw des Fensters aufgerufen  */
/* hier kînnen Daten initialisiert werden                               */
/*----------------------------------------------------------------------*/
#define         UR_WM_CREATE    2

/*----------------------------------------------------------------------*/
/* Nach einem Mausklick auf ein Kontrollelement wird WM_COMMAND gesendet*/
/* p1 = ID des gedrÅckten Knopfes                                       */
/*----------------------------------------------------------------------*/
#define         UR_WM_COMMAND   3

/*----------------------------------------------------------------------*/
/* destroy passiert, bevor das Fenster geschossen wird                  */
/* evtl freigeben von Speicher ...                                      */
/*----------------------------------------------------------------------*/
#define         UR_WM_DESTROY   4

/*----------------------------------------------------------------------*/
/* char passiert, wenn eine Taste gedrueckt wurde                       */
/* p1 = ascii Code der Taste, mit vordefinierten Funktionscodes         */
/*----------------------------------------------------------------------*/
#define         UR_WM_CHAR      5

/*----------------------------------------------------------------------*/
/* mouse passiert, wenn eine MausTaste gedrueckt wurde                  */
/* p1 = Zeiger auf eine Struktur aus zwei longs  (polong_typ)           */
/* p2 = anzahl der Mausklicks                                           */
/*      1 = klick liks 2 = 2mal links  11 = rechts 12 = 2 mal rechts    */
/*----------------------------------------------------------------------*/
#define         UR_WM_MOUSE     6

/*----------------------------------------------------------------------*/
/* move passiert, wenn der Mauszeiger bewegt wird,und das Flag CURSOR   */
/* gesetzt ist.                                                         */
/* p1 = x pos des Mauszeigers                                           */
/* p2 = y pos des Mauszeigers                                           */
/*----------------------------------------------------------------------*/
#define         UR_WM_MOVE      7

/*----------------------------------------------------------------------*/
/* Timer passiert, wenn ein timer abgelaufen ist                        */
/* p1 = Nummer des Timers, der abgelaufen ist                           */
/*----------------------------------------------------------------------*/
#define         UR_WM_TIMER      8

/*----------------------------------------------------------------------*/
/* Diese Message wird dann gesendet, wenn ein Fenster aktiviert wird    */
/* entweder durch anklicken oder durch schliessen eines anderen Fensters*/
/* hier kann das aktuelle Arbeitsfenster bestimmt werden                */
/*----------------------------------------------------------------------*/
#define         UR_WM_TOP        9

/*----------------------------------------------------------------------*/
/* Diese Message zeigt der Clientprozedur an, daû der sichtbare 		*/
/* Bildausschnitt verÑndert wurde. die neuen Abmessungen kînnen			*/
/* dann erfragt werden (Ursache : Slider, oder Size)					*/
/*----------------------------------------------------------------------*/
#define         UR_WM_VIEW        10

/*----------------------------------------------------------------------*/
/* die folgenden Events gehîren zu einem Listfenster                    */
/*----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/
/* Abfragen des selektierten Eintrages                                  */
/*----------------------------------------------------------------------*/

/* select wird durch Doppelklick auf einen Eintrag ausgefÅhrt           */
/* p1 = Selektiertes Listenelement                                      */
/*----------------------------------------------------------------------*/
#define                 UR_WM_LIST_SELECT       100

/*----------------------------------------------------------------------*/
/* read liest den angegebenen Listeneintrag ein                         */
/* p1 = gefragtes Listenelement                                         */
/* p2 = Zeiger auf einen 255 Zeichen langen String fÅr den Text         */
/*----------------------------------------------------------------------*/
#define                 UR_WM_LIST_READ         101

/*----------------------------------------------------------------------*/
/* size fragt die LÑnge der Liste an                                    */
/* p1 = gefragtes Listenelement                                         */
/* returnwert = lÑnge der Liste in Zeilen                               */
/*----------------------------------------------------------------------*/
#define                 UR_WM_LIST_SIZE         102

