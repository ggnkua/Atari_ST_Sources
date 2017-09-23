#ifndef __WINDDIAL__
#define __WINDDIAL__

#include <aes.h>

/* div. flags */

typedef struct
{
	unsigned drawed:	1;   /* Flag fÅr erstes Redraw */
	unsigned auto_top:	1;	 /* andere Fenster toppen */
	unsigned ltmf:		1;	 /* let 'em fly nutzen */
}
wi_flags;

/* struct zum Verwalten der Windows */
typedef struct
{
   int wi_handle; /* Window-Handle */
   OBJECT *obj;   /* Zugehîriger Object-Baum */
   int *m,*n,*o,*p;  /* Clipping-Koordinaten */
   wi_flags flags;
}
wi_data;


/* initialisieren und zeichnen des Fensterrahmens */
/* erste 4 Parameter: wie form_center
   wind :   Zeiger auf zu bearbeitende Window-Struktur
   title:  Titel des Fensters
   return:  im Fehlerfall !=0 , sonst 0
*/
int form_wind(OBJECT *ptr,int *center_x,int *center_y,
           int *center_w,int *center_h,
           wi_data *wind,char *title);

/* Dialog beenden, Fenster schlieûen */
int form_wclose(wi_data *wind);

/* form_do() in Fenstern: wind_do() */
/* Parameter:
   wind       : von form_wind() bearbeitetes wind-Objekt
   start_field: Objektnummer, in dem sich der Textcursor zuerst
               befinden soll
   buf[8]     : Messagepuffer
   return     : Nummer des angesprochenen Objektes oder
               -1 Nach Eintreffen einer Message
*/
/* aus dem Profibuch (form_do()), erweitert um Message-Handling */

int wind_do(wi_data *wind,int start_field,int *buf);

void wi_redraw(wi_data *wind,int *buf) ;
void wi_moved(wi_data *wind, int *buf) ;


#endif