/******************************/
/* GDOS.H                     */
/******************************/

typedef struct
{
  char font_name[35];
  int  font_id;          /* GDOS-ID           */
  int  font_spd;         /* Speedo-Font       */
  int  font_prop;        /* Proportional-Font */
} FONT;

/***********************/
/* Programm-Flags      */
/***********************/
typedef struct
{
  int absatz;
  int abs_mode;
  int amc;
  int anz_copies;
  int ask;
  int beginpage; /* ab dieser Seite          */
  int copies;
  int datum;     /* Datum            drucken */
  int dev_chk;
  int dev_typ;
  int dyna_mem;
  int headline;  /* Dateiname                */
  int height;    /* gewuenschte Zeichenhoehe */
  int leftspace; /* linker Rand in mm        */
  int lh;        /* Handle der aktuellen WKS */
  int locher;    /* Lochermarke drucken      */
  int memory;
  int pagebreak;
  int pagenum;   /* Seitennummer             */
  int pagequer;  /* Seite quer bedrucken     */
  int print_all; /* alles drucken            */
  int print_even;
  int print_odd; /* ungerade Seiten          */
  int rahmen;    /* Rahmen um die Seite      */
  int res;       /* Aufloesung der WKS in dpi*/
  int s_pfad;
  int sparmod;
  int stat_fontl;/* statische Fontliste      */
  int strich;    /* Unterstrichene Kopfzeile */
  int tab2space; /* Tab -> Space             */
  int tabspace;  /* ein TAB = xx Space       */
  int umlaut_ers;
  int xo;        /* linker Rand in Pixel     */
} PROGRAMFLAGS;

extern PROGRAMFLAGS PF;
extern FONT *fontp, *afp;
extern char datei[], fname[], fpath[];
extern char lpath[], spath[], null_string[];
extern int  work_in[12], work_out[57], ldrive, sdrive;
extern int  pagen, einr;

extern void print_vek_on_workstation (int wk_handle, char *pmem, long tlen);
extern void print_pix_on_workstation (int wk_handle, char *pmem, long tlen);
extern int  open_wkst(int wk_handle);
extern void m_v_clswk(int handle);
