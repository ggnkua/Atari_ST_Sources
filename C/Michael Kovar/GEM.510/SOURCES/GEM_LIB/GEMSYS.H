/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
/* ::::::::::::::::::::     g e m s y s . h     :::::::::::::::::::: */
/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
/* 
 * Headerdatei f�r den   G E M - M a n a g e r
 */

/* Version 2.00 vom 29. November 1992
 * (c) 1991 by Volker Nawrath
 */


#ifndef GEMSYS_H
#define GEMSYS_H GEMSYS_H

#include  <gemdefs.h>
#include  <obdefs.h>


/* Makros:
 *   (1) Eine 32-Bit-Zahl als 16-Bit-Zahlen zur�ckgeben
 *   (2) Zwei Zahlen vergleichen
 * ---------------------------------------------------- */

#define   ADDR(a) ((long)(a)>>16),((long)(a)&0xFFFF)   /*   (1)  */

#define   _max(a,b) ((a)>(b)?(a):(b))                  /*   (2)  */
#define   _min(a,b) ((a)<=(b)?(a):(b))                 /*   (2)  */


/* Konstanten
 * ---------- */
#define   DESK           0    /* Handle des Desktops             */
#define   MAXSTRING      80   /* Max. L�nge eines Strings        */
#define   INIT_OK        0    /* Programminitialisierung OK      */
#define   NO_INIT        1    /* Programminitialisierung nicht OK*/
#define   NO_RESOURCE    2    /* kein Resourcefile vorhanden     */

/* Typendefinitionen
 * ----------------- */

typedef   struct dokupos
{
     long    g_x;
     long    g_y;
     long    g_w;
     long    g_h;
} DOKUPOS;


typedef   struct image
{
     int  breite;
     int  hoehe;
     long getbuf;
} IMAGE;


typedef   struct rect
{
     int  g_x;
     int  g_y;
     int  g_w;
     int  g_h;
} RECT;


typedef   struct point
{
        int x,y;              /* kennzeichnet einen Punkt        */
} POINT;


typedef   struct akt
{
     int       multitsk;      /* Kennz. f�r Multitasking TRUE/FALSE   */
     int       max_user_wind; /* vom User vorgegeb. max. Fensteranz.  */
     int       windanz;       /* Anzahl der angelegten Fenster        */
     int       anzahl;        /* Anzahl der ge�ffneten Fenster        */
     int       handle;        /* Handle des gerade ge�ffneten Fensters*/
     int       text_x;        /* Breite der Zeichen in Pixel          */
     int       text_y;        /* H�he der Zeichen in Pixel            */
     int       menu_y;        /* H�he der Menuzeile                   */
     int       aufloesung;    /* Bildschirmaufl�sung:   2 = hoch
                                                        1 = mittel
                                                        0 = gering
                                                       -1 = sonstiges */
     int       screen_w;      /* Breite des Bildschirms in Pixel      */
     int       screen_h;      /* H�he des Bildschirms in Pixel        */
     RECT      neu_pix;       /* neu zu zeichnender Bereich in Pixel  */
     DOKUPOS   neu_doc;       /* Dokumentenposition in Zeilen/Spalten */
     FDB       monitor;       /* MFDB f�r virtuellen Bildschirm       */
} ACT;


typedef   struct ck
{
     long cookie;
     long cookiejar;
} COOKIE;


typedef	struct
{
     OBJECT	*tree;		/* Zeiger auf Resource-Baum */
     int	next_obj;	/* interne Daten der exform_do() */
     int	edit_obj;
     int	idx;
     int	ed_flag;	/* War letztes Objekt editierbar? */
} RSCDATA;


/* Konstanten
 * ---------- */
#ifndef   TRUE                /*                                      */
#define   TRUE      1         /* Schalterwert f�r "Wahr"              */
#endif                        /*                                      */

#ifndef   FALSE               /*                                      */
#define   FALSE     0         /* Schalterwert f�r "Falsch"            */
#endif                        /*                                      */

#define   TT_HIGH_REZ    5    /* Arten der Aufl�sung:  TT-Hoch        */
#define   TT_MID_REZ     4    /*                       TT-Mittel      */
#define   TT_LOW_REZ     3    /*                       TT-Gering      */
#define   HIGH_REZ       2    /*                       ST-Hoch        */
#define   MID_REZ        1    /*                       ST-Mittel      */
#define   LOW_REZ        0    /*                       ST-Gering      */
#define   OTHERREZ       -1   /*                       sonstige       */

#define   TT_HIGH_W      1280 /* Hohe TT-Aufl�sung:   Breite i.Pixel  */
#define   TT_HIGH_H       960 /*                      H�he in Pixel   */
#define   TT_MID_W        640 /* Mittl. TT-Aufl�sung: Breite i.Pixel  */
#define   TT_MID_H        480 /*                      H�he in Pixel   */
#define   TT_LOW_W        320 /* Ger. TT-Aufl�sung:   Breite i.Pixel  */
#define   TT_LOW_H        480 /*                      H�he in Pixel   */
#define   HIGH_W          640 /* Hohe ST-Aufl�sung:   Breite i.Pixel  */
#define   HIGH_H          400 /*                      H�he in Pixel   */
#define   MID_W           640 /* Mittl. ST-Aufl�sung: Breite i.Pixel  */
#define   MID_H           200 /*                      H�he in Pixel   */
#define   LOW_W           320 /* Ger. ST-Aufl�sung:   Breite i.Pixel  */
#define   LOW_H           200 /*                      H�he in Pixel   */

/* Cookies
 * ------- */
#define   COOKIE_MGEM 0x4d47454dL       /* MultiGem                   */
#define   COOKIE_NVDI 0x4e564449L       /* NVDI                       */


#endif

