/********************************************/
/* VFONT.C                                  */
/* by Bernhard Baier am 19.03.90            */
/* (c) MAXON Computer                       */
/* BGI-Vektor-Fonts (TURBO-PASCAL/C)        */
/* auf dem Atari ST unter C ansprechen      */
/* verwendeter Compiler: TURBO-C ST         */
/* letzte énderung am 24.10.90              */
/********************************************/

#include <math.h>
#include <stdio.h>
#include <tos.h>
#include <string.h>
#include <vdi.h>
#include <aes.h>
         
/* maximale Anzahl der gleichzeitig verfÅgbaren ZeichensÑtze */
#define N_FONTS 4  

/* diese Struktur existiert fÅr jeden Zeichensatz */
typedef struct
 {
        char  f_name[14];          /* Namen des Fonts */
        long  f_length;            /* LÑnge in Bytes */
        unsigned char *f_start;    /* Anfangsadresse im Speicher */
        unsigned char *f_header;   /* Zeiger auf Font-Header */
        int  *f_offset;            /* ab hier stehen die Offset-Daten */
        unsigned char *f_dat;      /* ab hier stehen die Vektor-Daten */
        int  f_ix;                 /* ASCII-Code erstes Zeichen */
        int  f_xw;                 /* Breite Font in Pixel */
        int  f_yh;                 /* Hîhe Font in Pixel   */
        int  f_ul;                 /* Font-UnterlÑnge */
 } font_def;

#define MAX_CO 128  /* maximale Anzahl Koordinaten eines Fonts */

/* folgende Struktur enthÑlt die transformatierten Koordinaten des */
/* aktuellen Zeichensatzes */

typedef struct font_par
 {
        int ix;            /* Fontnummer */
        int xwidth;        /* Breite und  */
        int yheight;       /* Hîhe eines Zeichens */
        int phi;           /* Rotationswinkel */
        int prop_flag;     /* proportionale Zeichenausggabe ja/nein */
        int x_cos[MAX_CO]; /* transformierte Koordinaten */
        int x_sin[MAX_CO];
        int y_cos[MAX_CO];
        int y_sin[MAX_CO];
        
 } FONT_PAR;

/**************************** Prototypen ******************************/
int loadfile( char *f_name, char **f_adress, long *f_length );
int load_font( char *font_name, int ix );
void unload_font( int ix );
void vf_settext( int ix, int xwidth, int yheight, int phi, 
    int prop_flag );
void vf_string( int vdi_handle, int xs, int ys, char *text );
void vf_char( int vdi_handle, int xc, int yc, FONT_PAR *actfont, 
    unsigned char c, int *xmax, int *ymax );
void test_font( int ix );
void gem_init( void );
void gem_exit( void );
void main( void );
/***********************************************************************/

FONT_PAR actfont;             /* bescheibt den aktuellen Zeichensatz */
font_def font_tab[N_FONTS];   /* Font-Tabelle */
int f_co[256];                /* nimmt Linienzug auf */

/* allgemeine GEM-Definitionen */
int gl_apid, gem_handle, vdi_handle, work_out[57];
int scrn_width, scrn_height;

#define MIN(a, b) ((a) < (b)?(a):(b))
#define TRUE 1
#define FALSE 0

/****************** Vektor-Font-Funktionen **********************/

int load_font(font_name, ix)
char *font_name;   /* Datei-Name */
int ix;            /* Font-Nummer */
{
   int offset0, offset1;
   char t;
   unsigned char *font_start, *font_header, *font_ptr, *font_dat;
   long font_length;
   int  *font_offset, font_ix, font_xw, font_yh, font_ul;

   if (loadfile(font_name, (char **) &font_start, &font_length))
      return (1);
   strcpy(font_tab[ix].f_name, font_name);
   offset0 = 0x80;
   offset1 = 0x10;

   font_header = font_start  + offset0;
   font_offset = (int *)(font_header + offset1);

   font_dat = font_header + font_header[5] + ((int) font_header[6] << 8);
   font_ix  = font_header[4];
   font_xw  = font_header[8];

   font_ul  = font_header[10];
   if (font_ul >= 0x80) font_ul -= 0x100;
  
   font_yh = font_xw - font_ul;

/* Wandlung der Offsetdaten vom Intel zum Motorola-Format */

   for (font_ptr = (unsigned char *) font_offset; 
                      font_ptr < font_dat; font_ptr += 2)
    {
       t = *font_ptr;
       *font_ptr = *(font_ptr + 1);
       *(font_ptr + 1) = t;
    }

   font_tab[ix].f_length = font_length;
   font_tab[ix].f_start  = font_start;
   font_tab[ix].f_header = font_header;
   font_tab[ix].f_offset = font_offset;
   font_tab[ix].f_dat    = font_dat;
   font_tab[ix].f_ix     = font_ix;
   font_tab[ix].f_xw     = font_xw;
   font_tab[ix].f_yh     = font_yh;
   font_tab[ix].f_ul     = font_ul;

   return (0);  /* Kein Fehler */
}

void unload_font(ix)
int ix;
{
     Mfree(font_tab[ix].f_start);
}

/* Bestimmt einen Zeichensatz als den aktuellen und legt seine */
/* Grîûe und Ausgaberichtung fest */

void vf_settext(ix, xwidth, yheight, phi, prop_flag)
int ix;                      /* Font-Nummer */
int xwidth, yheight;         /* Hîhe/breite eines Zeichens in Pixel */
int phi;                     /* Winkel in Grad/10 */
int prop_flag;               /* Proportionalschrift ja/nein */
{
    int i, max_co;
    int font_xw, font_yh, font_ul;
    double x, y, co, si;

    actfont.ix = ix;
    actfont.xwidth = xwidth;
    actfont.yheight = yheight;
    actfont.phi = phi;
    actfont.prop_flag = prop_flag;
    si = sin((double) phi * M_PI / 1800.0);
    co = cos((double) phi * M_PI / 1800.0);  
     
    font_xw = font_tab[ix].f_xw;
    font_yh = font_tab[ix].f_yh;
    font_ul = font_tab[ix].f_ul;

    max_co = MIN(font_xw + font_xw/2, MAX_CO);
                           /* ^ wegen öberbreiten von manchen Buchstaben */
    for (i = 0; i < max_co; ++i)
     {
        x = (double) xwidth * (double) i / (double) font_xw;
        actfont.x_cos[i] = (int) (x * co);
        actfont.x_sin[i] = (int) (x * si);
     }

    max_co = MIN(font_yh - 2 * font_ul, MAX_CO);
                        /* ^ wg. öberlÑngen "" */
    for (i = 0; i < max_co; ++i)
     {
        y = (double) yheight * (double) (i + font_ul) / (double) font_yh;
        actfont.y_cos[i] = (int) (y * co);
        actfont.y_sin[i] = (int) (y * si);
     }
}

/* Gibt einen Text an der angegebenen Stelle aus; verwendet dabei den */
/* aktuellen Zeichensatz (durch vf_settext festgelegt) */

void vf_string(vdi_handle, xs, ys, text)
int vdi_handle; /* Handle der VDI-Workstation */
int xs, ys;     /* Startposition */
char *text;     /* auszugebender Text */
{
     int ix, font_xw;
     int xtmax, ytmax;
     unsigned char c;

     ix = actfont.ix;
     font_xw = font_tab[ix].f_xw;
     while (*text)
      {
           c = *text++;
           if (c == 158) c = 225; /* Wandlung scharfes ss Atari -> IBM */
           vf_char(vdi_handle, xs, ys, &actfont,
                   (unsigned char) c, &xtmax, &ytmax);
           if (actfont.prop_flag)
            {
               xs += actfont.x_cos[xtmax];
               ys -= actfont.x_sin[xtmax];
            }
           else
            {
               xs += actfont.x_cos[font_xw];
               ys -= actfont.x_sin[font_xw];
            }
      }
}

void vf_char(vdi_handle, xc, yc, actfont, c, xmax, ymax)
int vdi_handle;      /* Handle fÅr VDI-Workstation */
int xc, yc;          /* (x,y)-Koordinaten des Zeichens */
FONT_PAR *actfont;   /* transformierte Koordinaten */
unsigned char c;     /* auszugebendes Zeichen */
int *xmax, *ymax;    /* RÅckgabe: Maximale Zeichenkoordianten */
{
    int x_s, y_s, x, y, xx, yy;
    int ix;
    unsigned char *c_ptr;
    int font_ix, font_ul, startflag, offset;

    *xmax = 0;
    *ymax = 0;

    ix = actfont->ix;
    font_ix = font_tab[ix].f_ix;
    if (c < font_ix) return;
    offset = font_tab[ix].f_offset[c - font_ix];
    c_ptr = font_tab[ix].f_dat + offset;
    font_ul = font_tab[ix].f_ul;
    ix = 0;
  
    do
     {
       startflag = FALSE;

       x_s = *c_ptr;
       y_s = *(c_ptr + 1);
       x = x_s;
       y = y_s;

       if (x == 0 && y == 0)
          startflag = TRUE;
    
       if (x >= 0x80) x -= 0x80;
       if (x >= 0x40) x -= 0x80;
       if (y >= 0x80) y -= 0x80;
       else
          startflag = TRUE;
       if (y >= 0x40) y = y - 0x80;

       if (x > *xmax) *xmax = x;
       if (y > *ymax) *ymax = y;

       xx = x;
       yy = y - font_ul;
       x = actfont->x_cos[xx] - actfont->y_sin[yy];
       y = actfont->x_sin[xx] + actfont->y_cos[yy];
       f_co[ix++] = xc + x;
       f_co[ix++] = yc - y;

       if (startflag)
          if (ix > 2)
           {
             v_pline(vdi_handle, (ix-1) >> 1, f_co);
             f_co[0] = f_co[ix-2];
             f_co[1] = f_co[ix-1];
             ix = 2;
           }
    
      c_ptr += 2;
     }
    while (x_s || y_s);
}

int  loadfile(f_name, f_adress, f_length) /* Datei laden */
char *f_name, **f_adress; /* Dateiname, Adreese im Speicher */
long *f_length;           /* LÑnge der Datei */
{
     DTA  dtabuffer;
     int  f_handle;

     Fsetdta(&dtabuffer);
     if (Fsfirst(f_name, 0) || (f_handle = Fopen(f_name, 0)) < 0)
      {
        form_alert(1, "[1][Datei nicht gefunden!][Abbruch]");
        return (1);
      }

     *f_length = dtabuffer.d_length;
     if ((*f_adress = (char *) Malloc(*f_length)) == NULL)
      {
        form_alert(1, "[1][Nicht genug Speicher!][Abbruch]");
        return (1);
      }
 
     Fread(f_handle, *f_length, *f_adress);
     Fclose(f_handle);
     return (0);
}

/********* Funktionen bis hierher in eigenen Programmen verwenden *****/

void test_font(ix)  /* Zeichensatz testen */
int ix;             /* Font-Nummer */
{
    int winkel, i, j, ii, zeile;
    int co[4];
    char line[255];

    graf_mouse(M_OFF, NULL);
    co[0] = 0;               co[1] = 0;
    co[2] = scrn_width - 1;  co[3] = scrn_height - 1;
    vs_clip(vdi_handle, TRUE, co);

    /* alle Zeichen werden ausgegeben */

    Cconws("\33ETeste Font (unproportional) "); Cconws(font_tab[ix].f_name);
    zeile = scrn_height/8;
    vf_settext(ix, scrn_width/34, scrn_height/10, 0, FALSE);
    for (i = 32; i < 256; i += 32)
     {
        ii = 0;
        for (j = i; j < i + 32; ++j)
            line[ii++] = (char) j;
        line[ii++] = '\0';
        vf_string(vdi_handle, 10, zeile, line);
        zeile += scrn_height/9;
     }
    Cnecin();
     
    Cconws("\33ETeste Font (proportional) "); Cconws(font_tab[ix].f_name);
    for (winkel = 0; winkel < 3600; winkel += 300)
     {
        vf_settext(ix, scrn_width/22, scrn_height/18, winkel, TRUE);
        vf_string(vdi_handle, scrn_width/2, scrn_height/2,
                  "Dies ist ein Test!");
     } 
    Cnecin();
    graf_mouse(M_ON, NULL);
}


void gem_init()  /* GEM wird initialisert */
{
    int work_in[11];
    int i, ret;

    gl_apid = appl_init();
    for (i = 0; i < 10; work_in[i++] = 1)
        ;
    work_in[10] = 2;

    gem_handle = graf_handle(&ret, &ret, &ret, &ret);
    vdi_handle = gem_handle;
    v_opnvwk(work_in, &vdi_handle, work_out);

    scrn_width   = work_out[0] + 1;
    scrn_height  = work_out[1] + 1;
}

void gem_exit()   /* GEM wird verlassen */
{
     v_clsvwk(vdi_handle);
     appl_exit();
}

void main()
{
    int i, err;
    int nfonts = 0;
    DTA dtabuffer;

    gem_init();
    /* Suche alle BGI-Fonts im aktuellen Verzeichnis */
    Fsetdta(&dtabuffer);
    err = Fsfirst("*.CHR", 0);
    if (err)
     {
       Cconws("\33EIm aktuellen Verzeichnis keine TURBO-PASCAL-Vektor-Fonts ");
       Cconws("(*.CHR) gefunden!");
       Cnecin();
     }
    while (!err && nfonts < N_FONTS)
     {
          load_font(dtabuffer.d_fname, nfonts);
          Fsetdta(&dtabuffer);
          ++nfonts;
          err = Fsnext();
     }
    for (i = 0; i < nfonts; ++i)
     {
        test_font(i);
        unload_font(i);
     }
    gem_exit();
}




