/*------------------------------------------------------*/
/* HELP.H                                               */
/* Definitionen / Prototypen fÅr Online-Hilfe "Help!"   */
/* Sprache:  Turbo-C 2.0                                */
/* Autor:    (C)1990 Mathias Tobollik                   */
/*------------------------------------------------------*/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <tos.h>
#include <ext.h>
#include <vdi.h>
#include <aes.h>
#include <gem_init.h>


/*------------------------------------------------------*/
/* Konstanten:                                          */
/*------------------------------------------------------*/
#define FALSE   0
#define TRUE    1

#define EXTERN  1    /* Modi fÅr Hilfefunktion          */
#define INTERN  0  

#define LINE_LEN 81  /* max. LÑnge einer Textzeile      */

#define MAX_REF 80   /* max. Anzahl von Verweisen im 
                        Fenster */
#define REF_LEN 31   /* max. LÑnge des SchlÅsselwortes
                        eines Verweises */
#define H_DEPTH 30   /* max. Verschachtelungstiefe      */
                              
#define MAX_SRT 300 /* max. Anzahl EintrÑge fÅr Index-
                       Sortierfunktion */
#define MBKSIZE 15L /* Gesamtgrîûe des Speichers, der mit
                       get_mem() und fre_mem() verwaltet
                       werden kann ( in kByte ! ) */
                    /* Attribute des Hilfefensters: */
#define HW_ATTRIB  511
      /* Entspricht: NAME+CLOSER+FULLER+MOVER+INFO+SIZER
                     +UPARROW+DNARROW+VSLIDE */

/* Endungen fÅr Dateinamen: ----------------------------*/
#define HSRC ".TXT"             /* Hilfetext-Quelldatei */
#define HHLP ".AID"             /* Hilfetextdatei       */
#define HNDX ".AIX"             /* Indexdatei           */
#define HCNT ".CNT"             /* Inhaltsverzeichnis   */
#define HERR ".ERR"             /* Fehlerdatei          */


/*------------------------------------------------------*/
/* Globale Variable:                                    */
/*------------------------------------------------------*/

int h_depth;                /* aktuelle Verschachtelung */

/* Help-Window: ----------------------------------------*/
int hlp_win;                         /* Window-Handle   */
int hww_x, hww_y,                    /* aktiver Bereich */
    hww_w, hww_h;
int hwo_x, hwo_y,                    /* Auûenmaûe       */
    hwo_w, hwo_h;
    
/* Maus: -----------------------------------------------*/
int m_x, m_y, m_but;           /* -Koordinaten, -Tasten,*/
int clicks;                    /* -Klicks               */
int key;                       /* Sondertasten          */
int taste;                     /* Tastencode            */

/* VDI-Grafik: -----------------------------------------*/
int clip[4];                       /* Clipping-Rechteck */


typedef struct  /* Verweis: */
{
    char s[REF_LEN];   /* SchlÅsselwort                 */
    int  x,y,w,h;      /* Maûe des umgebenden Rechtecks */
}refer;
refer ref[MAX_REF];   /* Liste von Verweisen            */
int refno;            /* gÅltige Verweise               */


/* FÅr get_mem() und fre_mem() reserviert: -------------*/
char *Mem_AreA;      /* Groûer, reservierter Block      */
char *Mem_NexT;      /* Anfang des nÑchsten Teilblocks  */
long LefT=0L;        /* restlicher freier Speicher      */
/*------------------------------------------------------*/


/*------------------------------------------------------*/
/* Funktionsprototypen:                                 */
/*------------------------------------------------------*/

/* Hauptfunktion: */

int help( char *what, char *datei, int mode );


/* Compilerfunktionen: .................................*/

int check_help( char *datei );
int make_help( char *datei );
int make_contents( char *datei, char **lines, char *mem );


/* Grafikfunktionen: ...................................*/

void cls_wind( int w_handle );
void display_help( char *buf, long buflen, int begline, 
int lines );
void display_line( char *buf, long buflen, int begline, 
int line, int lines );
void mark_ref( refer *ref );
int set_clip( int w_handle, int x, int y, int w, int h );
void wind_vmove( int w_handle, int delta_y );


/* Dateifunktionen: ....................................*/

int get_help( char *file, char *buf, long start,
long length );
int get_index( char *file, char *key, long *start,
long *length );


/* Fensterfunktionen: ..................................*/

void close_helpw( void );
void h_fullwind( char *buf, long buflen, int line,
int lines );
void h_newdim( char *buf, long buflen, int line, 
int lines, int ox, int oy, int ow, int oh );
void h_vscr_line( int up_down, char *buf, long buflen, 
int *line,int lines );
void h_vscr_page( int up_down, char *buf, long buflen, 
int *line, int lines );
int open_helpw( void );
void send_redraw( int w_handle );
void set_vslider( int b_lin, int to_lin );
int vslider( int slidepos, int to_lin );


/* Stringfunktionen: ...................................*/

char *change_ext( char *name, const char *ext );
char *keycpy( char *to, char *from );
size_t keylen( char *keywd );
char *keyw( char *to, char *from );
void offset( char *zeile, long *index, long *length );


/* Speicherverwaltung: .................................*/

void fre_mem( char *where );
char *get_mem( long amount );


/* Sonstige: ...........................................*/

int count_lin( char *puf, long puf_len );
char *find_ref( int x, int y );
char *go_line( int n, char *p );
int is_inside(int a, int b, int x, int y, int w, int h);
void locate_ref( char *buf, long buflen, int begline );

/*-------------------  Ende HELP.H ---------------------*/
