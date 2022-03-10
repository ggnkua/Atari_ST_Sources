/************************************************************/
/* FILE.C                                                   */
/************************* Includes *************************/
#ifdef __PUREC__
#include <ext.h>
#endif
#ifdef __GNUC__
#define __TCC_COMPAT__
#include <support.h>
#include <unistd.h>
#include <ostruct.h>
#include <mintbind.h>
#include <fcntl.h>
#endif
#include <portab.h>
#include <stdlib.h>
#include <string.h>
#include <osbind.h>
#include <vdibind.h>
#include <aesbind.h>
#include "gprint.h"
#include "gdos.h"

/************************* Variablen ************************/
extern OBJECT *dial_tree, *font_tree, *opt_tree, *pop_tree, *ppop_tree;
extern int id_akt_font;

/************************* Prototypen ***********************/
int  bestimme_datei (char *n, char *dn, char *dp);
int  bestimme_datei_v(char *name, char *pfad);
long load_datei     (const char *name, unsigned long *laenge, unsigned long *z_mem);
int  save_opt       (void);
int  load_opt       (void);
int  save_fontliste (FONT *fonts, int anzahl);
int  load_fontliste (FONT *fonts, int *anzahl);

/************************* Program **************************/
/* Datei Åber Fileselect-Box bestimmen                      */
/* In n steht die Datei mit Pfad                            */
/*    dn Dateiname                                          */
/*    dp Dateipfad                                          */
/************************************************************/
int bestimme_datei(char *n, char *dn, char *dp)
{
  char fs_iinpath[128], fs_iinsel[40];
  int  fs_iexbutton;

  *fs_iinpath = 0x0;
  *fs_iinsel = 0x0;
  *n = 0x0;
  *dn = 0x0;
  *dp = 0x0;

  if(PF.s_pfad)
  {
#ifdef __PUREC__
    setdisk(ldrive);
#endif
#ifdef __GNUC__
    Dsetdrv(ldrive);
#endif
    chdir(lpath);
  }

  fsel_input(fs_iinpath, fs_iinsel, &fs_iexbutton);

  if(fs_iexbutton == 1 && *fs_iinsel != 0x0)
  {
    int h;
    h = (int)strlen(fs_iinpath);
    while(*(fs_iinpath + h) != 92) h--;
    strncpy(n, fs_iinpath, ++h);
    n[h] = 0x00;
    strcpy(dp, n);                /* Pfad der Datei             */
    strcpy(dn, fs_iinsel);        /* Name der Datei             */
    strcpy(lpath, n+2);           /* Pfad ohne Laufwerk         */
    strcat(n, fs_iinsel);         /* Korrekten Pfadnamen bilden */
    ldrive = (int)*fs_iinpath-65;
    return(TRUE);
  }
  return(FALSE);
} /* bestimme_datei() */

/******************************************************/
/* Dateinamen und Pfad getrennt ermitteln             */
/******************************************************/
int bestimme_datei_v(char *name, char *pfad)
{
  char fs_iinpath[128], fs_iinsel[40];
  int  fs_iexbutton;

  *fs_iinpath = 0x0;
  *fs_iinsel = 0x0;

  if(PF.s_pfad)
  {
#ifdef __PUREC__
    setdisk(ldrive);
#endif
#ifdef __GNUC__
    Dsetdrv(ldrive);
#endif
    chdir(lpath);
  }

  fsel_input(fs_iinpath, fs_iinsel, &fs_iexbutton);

  if(fs_iexbutton == 1)   /*  && *fs_iinsel != 0x0) */
  {
    int h;
    h = (int)strlen(fs_iinpath);
    while(*(fs_iinpath + h) != 92) h--;
    strncpy(pfad, fs_iinpath, ++h);
    pfad[h] = 0x00;
    strcpy(name, fs_iinsel);
    strcpy(lpath, pfad+2);  /* Pfad ohne Laufwerk */
    ldrive = (int)*pfad-65;
    return(TRUE);
  }
  return(FALSE);
} /* bestimme_datei_v() */

/******************************************************/
/* Eine beliebige Datei laden.                        */
/******************************************************/
long load_datei(const char *name, unsigned long *laenge, unsigned long *z_mem)
{
  int fhandle, exit;
  long memavail, mem, zusaetz_mem;
#ifdef __PUREC__
  DTA *dta;
#endif
#ifdef __GNUC__
  _DTA *dta;
#endif

  exit = 0;
#ifdef __PUREC__
  setdisk(ldrive);
#endif
#ifdef __GNUC__
  Dsetdrv(ldrive);
#endif
  chdir(lpath);

#ifdef __PUREC__
  dta = (DTA *) Fgetdta();
#endif
#ifdef __GNUC__
  dta = (_DTA *) Fgetdta();
#endif

  exit = Fsfirst(name, 0);    /* feststellen, ob es die Datei gibt */
  if(exit != FALSE)
  {
    return(0L);
  }
#ifdef __PUREC__
  *laenge = (*dta).d_length;            /* Dateilaenge  */
#endif
#ifdef __GNUC__
  *laenge = (*dta).dta_size;
#endif
  if(PF.dyna_mem)      /* dynamische Speicherverwaltung */
  {
    (long)zusaetz_mem = 3072 + (*laenge >> 10) * (20 + PF.tabspace * 50);
    /*                 1K + 2K                Umlaute       Tab's
                       sowieso                20 / KB      50 / KB   */
    /* 1K fÅr Absatzformatierung */
  }
  else
  {
    zusaetz_mem = 16384L;
  }
  *z_mem = zusaetz_mem;
  memavail = (long) malloc((unsigned long)-1) - 20000L; /* freier Speicher */
  if (*laenge < memavail)
    mem = (long) malloc(*laenge + zusaetz_mem); /* Platz fÅr Umlaute */
  else
  {
    return(0L);
  }

#ifdef __PUREC__
  fhandle = Fopen(name, FO_READ);
#else
  fhandle = Fopen(name, O_RDONLY);
#endif
  if(fhandle <= 0)                /* Fehler beim îffnen ?    */
  {
    return(0L);
  }

  if(Fread(fhandle, *laenge, (void *)(mem + zusaetz_mem)) < 0L)
  {
    return(0L);
  }

  if(Fclose(fhandle) < 0)        /* Datei schlieûen */
  {
    return(0L);
  }

  return(mem);

} /* load_datei() */

/**********************************************/
/* Einstellungen Laden                        */
/**********************************************/
int load_opt(void)
{
  int buffer[52], fhandle, *buf;
  long b;
  buf = buffer;

#ifdef __PUREC__
  setdisk(ldrive);
#endif
#ifdef __GNUC__
  Dsetdrv(ldrive);
#endif
  chdir(spath);

#ifdef __PUREC__
  fhandle = Fopen("GPRINT.INF", FO_READ);
#else
  fhandle = Fopen("GPRINT.INF", O_RDONLY);
#endif
  if(fhandle <= 0)                /* Fehler beim îffnen ?    */
  {
    return(0);
  }

  b = Fread(fhandle, 100, (void *)buf);
  if(b != 100)
  {
    return(0);
  }

  if(Fclose(fhandle) < 0)        /* Datei schlieûen */
  {
    return(0);
  }

  font_tree[ZH6].ob_state       = buf[0];
  font_tree[ZH8].ob_state       = buf[1];     /* bis v 1.30 in dial_tree */
/*  font_tree[ZH9].ob_state       = buf[2]; */
  font_tree[ZH10].ob_state      = buf[3];

  dial_tree[UMLAUTE].ob_state   = buf[5];
  dial_tree[TAB2SPACE].ob_state = buf[6];
  dial_tree[HEFTRAND].ob_state  = buf[7];
  dial_tree[DATEINAME].ob_state = buf[8];
  dial_tree[DATUM].ob_state     = buf[9];
  dial_tree[PAGENUM].ob_state   = buf[10];
  dial_tree[PAGEBREAK].ob_state = buf[11];
  dial_tree[PAGEQUER].ob_state  = buf[12];
  dial_tree[UNTERSTRICH].ob_state  = buf[13];
  dial_tree[LOCHERMARKE].ob_state  = buf[14];
  dial_tree[SEITENRAHMEN].ob_state = buf[15];
/*  dial_tree[].ob_state  = buf[12];*/

  if(buf[30] != 0x0)
    id_akt_font                   = buf[30];

  ppop_tree[PPAGEALL].ob_state      = buf[30];
  ppop_tree[PPAGEGERADE].ob_state   = buf[31];
  ppop_tree[PPAGEUNGERADE].ob_state = buf[32];

/*opt_tree[AUTOCHK].ob_state    = buf[40];*/
  opt_tree[SAVEPFAD].ob_state   = buf[41];
  opt_tree[ABSATZMODE].ob_state = buf[42];
  opt_tree[MEMDYN].ob_state     = buf[43];
  opt_tree[SPARMODE].ob_state   = buf[44];
/*opt_tree[STATFONT].ob_state   = buf[45];*/
  opt_tree[FROMPAGE].ob_state   = buf[46];
#ifdef __PUREC__
  itoa(buf[47], opt_tree[FROMPAGENUM].ob_spec.tedinfo->te_ptext, 10);
#endif
#ifdef __GNUC__
  _itoa(buf[47], opt_tree[ANZCOPYS].ob_spec.tedinfo->te_ptext, 10);
#endif

  opt_tree[COPYS].ob_state      = buf[48];
#ifdef __PUREC__
  itoa(buf[49], opt_tree[ANZCOPYS].ob_spec.tedinfo->te_ptext, 10);
#endif
#ifdef __GNUC__
  _itoa(buf[49], opt_tree[ANZCOPYS].ob_spec.tedinfo->te_ptext, 10);
#endif

  return(TRUE);
} /* load_opt() */

/*******************************************/
/* Einstellungen in "GPRINT.INF" sichern   */
/*******************************************/
int save_opt(void)
{
  int buffer[52], fhandle, *buf;
  long b;

  buf = buffer;

  buf[0]  = font_tree[ZH6].ob_state;
  buf[1]  = font_tree[ZH8].ob_state;
/*  buf[2]  = font_tree[ZH9].ob_state; */
  buf[3]  =  font_tree[ZH10].ob_state;

  buf[5]  = dial_tree[UMLAUTE].ob_state;
  buf[6]  = dial_tree[TAB2SPACE].ob_state;
  buf[7]  = dial_tree[HEFTRAND].ob_state;
  buf[8]  = dial_tree[DATEINAME].ob_state;
  buf[9]  = dial_tree[DATUM].ob_state;
  buf[10] = dial_tree[PAGENUM].ob_state;
  buf[11] = dial_tree[PAGEBREAK].ob_state;
  buf[12] = dial_tree[PAGEQUER].ob_state;
  buf[13] = dial_tree[UNTERSTRICH].ob_state;
  buf[14] = dial_tree[LOCHERMARKE].ob_state;
  buf[15] = dial_tree[SEITENRAHMEN].ob_state;

  if(afp != NULL)
    buf[30] = afp->font_id;

  buf[30] = ppop_tree[PPAGEALL].ob_state;
  buf[31] = ppop_tree[PPAGEGERADE].ob_state;
  buf[32] = ppop_tree[PPAGEUNGERADE].ob_state;

/*buf[40] = opt_tree[AUTOCHK].ob_state;   */
  buf[41] = opt_tree[SAVEPFAD].ob_state;
  buf[42] = opt_tree[ABSATZMODE].ob_state;
  buf[43] = opt_tree[MEMDYN].ob_state;
  buf[44] = opt_tree[SPARMODE].ob_state;
/*buf[45] = opt_tree[STATFONT].ob_state;   */
  buf[46] = opt_tree[FROMPAGE].ob_state;
  buf[47] = atoi(opt_tree[FROMPAGENUM].ob_spec.tedinfo->te_ptext);

  buf[48] = opt_tree[COPYS].ob_state;
  buf[49] = atoi(opt_tree[ANZCOPYS].ob_spec.tedinfo->te_ptext);

#ifdef __PUREC__
  setdisk(ldrive);
#endif
#ifdef __GNUC__
  Dsetdrv(ldrive);
#endif
  chdir(spath);

#ifdef __PUREC__
  fhandle = Fopen("GPRINT.INF", FO_WRITE);
#else
  fhandle = Fopen("GPRINT.INF", O_RDONLY);
#endif
  if(fhandle <= 0)                /* Fehler beim îffnen ?    */
  {
    fhandle = Fcreate("GPRINT.INF", 0);
    if( fhandle <= 0)
      return(0);
  }

  b = Fwrite(fhandle, 100, buf);
  if(b != 100)
  {
    return(0);
  }

  if(Fclose(fhandle) < 0)        /* Datei schlieûen */
  {
    return(0);
  }
  return(TRUE);
} /* save_opt() */
