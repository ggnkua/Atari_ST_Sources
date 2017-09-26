#define UCHAR unsigned char 
 
typedef struct 
 
{ 
 
char kennung[4];    /* ESM¸kennung: "TMS\0"         */ 
int head_size;      /* groesse des headers in bytes     */ 
int breite;     /* bildbreite in punkten        */ 
int hoehe;      /* hoehe in punkten des ges. bildes */ 
            /* also bei streifenspeicherung     */ 
            /* summe aller teilstreifen     */ 
 
int tiefe;      /* bildtiefe in bit 1,8 oder 24     */ 
 
int bildart;        /* 1: Bitmap                */ 
            /* 2: Grautonbild           */ 
            /* 3: Farbbild              */ 
            /* 4: CMY-Trennung          */ 
            /* 5: CMYK-Trennung         */ 
            /* 6: RGB-Trennung          */ 
 
int tiefe_rot;      /* Tiefe in Bit Rotanteil, bei      */ 
            /* CMY/CMYK Cyan            */ 
 
int tiefe_gruen;    /* Tiefe in Bit Gruen, bei      */ 
            /* CMY/CMYK Magenta         */ 
 
int tiefe_blau;     /* Tiefe in Bit Blau, bei       */ 
            /* CMY/CMYK Gelb            */ 
 
int tiefe_schwarz;  /* Tiefe in Bit Schwarzanteil       */ 
            /* Diese Werte werden nur bei       */ 
            /* trennungen belegt, sonst mit 0   */ 
 
int version;        /* version 5 seit 18.04.91      */ 
 
int xdpi;       /* x/y¸Aufloesung des Bildes in dpi */ 
int ydpi; 
 
            /* ab version 3: streifenabspeichern    */ 
 
int file_hoehe;     /* teilhoehe des streifens =        */ 
            /* einschl. start_zeile bis     */ 
            /* einschl. end_zeile. wenn nicht   */ 
            /* in streifen gespeichert wurde,   */ 
            /* gleicher wert wie hoehe      */ 
 
int start_zeile;    /* start-zeile des bildstreifens    */ 
 
int end_zeile;      /* end-zeile des bildstreifens      */ 
            /* ab version 4:            */ 
 
int maske;      /* wenn != 0 dann folgt 1-bit tiefe */ 
            /* maske auf die bilddaten.     */ 
            /* maskengroesse in bytes:((brei-   */ 
            /*te+7)>>3)*file_hoehe          */ 
 
UCHAR red_tab[256]; 
 
            /* ab version 4: clut des bildes    */ 
 
UCHAR green_tab[256]; 
            /* graubild: nur red_index wichtig  */ 
 
UCHAR blue_tab[256]; 
            /* beibitmap/farbtrennung unwichtig */ 
 
char copyright[36];  /* "CRANACHætrademark by tms    */ 
            /* regensburg/0"    */ 
 
int reserved[4];    /* fuer spaetere Verwendung ab  */ 
            /* version 3 mit 0 auffÅllen    */ 
}ESM_HEADERTYP; 
