/* Header fÅr Scrollroutinen          */

/* Struktur fÅr die 4 Eckpunkte des zu scrollenden Bereichs, wird */
/* fÅr die Initialisierung der Parameter */
/* der SCROLLER-Struktur benîtigt */

typedef struct
{
  int x1;
  int y1;
  int x2;
  int y2;
}RECT;

/* Struktur, die zum Scrollen    */    
/* nîtigen Parameter enthÑlt */

typedef struct
{
   int words;      /* Wortbreite des Bereichs */
   long offset;    /* Breite in Bytes */
   int zeilen;     /* Hîhe in Pixelzeilen */
   char *adr;      /* Adresse auf dem Monitor */
   int pixel;      /* Breite in Pixel,wird fÅr */
                   /* Links-Rechts benîtigt */
}SCROLLER;

void cdecl scroll_lr(SCROLLER *scroll,long warten,int pixel,int richtung);

void cdecl scroll_ou(SCROLLER *scroll,long warten,int anzahl,int richtung);

void scrollinit(RECT *k,SCROLLER *scroll,int links_oder_oben);
