/* Header fr Scrollroutinen          */

/* Struktur fr die 4 Eckpunkte des zu */ 
/* scrollenden Bereichs, wird */
/* fr die Initialisierung der Parameter */
/* der SCROLLER-Struktur ben”tigt */

typedef struct
{
  int x1;
  int y1;
  int x2;
  int y2;
}RECT;

/* Struktur, die zum Scrollen    */    
/* n”tigen Parameter enth„lt */

typedef struct
{
   int words;      /* Wortbreite des Bereichs */
   long offset;    /* Breite in Bytes */
   int zeilen;     /* H”he in Pixelzeilen */
   char *adr;      /* Adresse auf dem Monitor */
   int pixel;      /* Breite in Pixel,wird fr */
                   /* Links-Rechts ben”tigt */
}SCROLLER;
