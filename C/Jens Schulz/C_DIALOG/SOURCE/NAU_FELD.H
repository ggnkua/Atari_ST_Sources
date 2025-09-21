
/************ Typendefinition. ************************************/
typedef enum
{
  FALSE,
  TRUE
}
boolean;

typedef struct
{ 
    int   V_MODE;       /* Video-Mode 1-4            */     
    int   X_PIXEL;      /* X-Bildschirm-Aufl”sung    */
    int   Y_PIXEL;      /* Y-Bildschirm-Aufl”sung    */
    int   PLANES;       /* Anzahl Bitplanes          */
    int   X_OFFS;       /* Start-Punkt der Grafik    */
    int   Y_OFFS;       /* ( obere linke Ecke )      */
    int   BREITE;       /* Breite eines Steines      */
    int   HOEHE;        /* Hoehe eines Steines       */
    int   CPY_BREITE;   /* Breite des Kopier-Musters */
    int   CPY_HOEHE;    /* Hoehe des Kopier-Musters  */
    int   WIDTH_LEFT;   /* Schattenbreite Links      */
    int   WIDTH_BOTTOM; /* Schattenbreite Unten      */
    int   WIDTH_RIGHT;  /* Schattenbreite Rechts     */
    int   VIRT_BREITE;  /* Breite des virtuellen Bildschirms */
    int   VIRT_HOEHE;   /* Hoehe des virtuellen Bildschirms  */
    int   DELTAX;       /* Versatz der Steine bei    */
    int   DELTAY;       /* hoeheren Ebenen           */
    int   QUELL_L;      /* Laenge der Grafik-Datei   */
    int   MENUKOPF;     /* Menue-Hoehe               */
    char *QUELLE;       /* Grafik-Datei              */
} screen_param;

